# Proposal: Enable Study Fields in Report Search

**ID**: `enable-study-fields-in-report-search`  
**Status**: 📋 Proposal  
**Created**: 2025-11-26  
**Author**: AI Agent  

---

## 1. Background

### Current State
- Report 搜索功能 (`implement-advanced-report-search`) 已完成，支援多條件 JSON DSL 查詢
- `Report.report_id` (CharField) 透過字串 ID 對應 `Study.exam_id` (PK)，但**沒有 ForeignKey 關聯**
- 現有搜索僅支援 Report 自身欄位：`title`, `report_type`, `report_id`, `uid`, `mod`, `verified_at`, `created_at`, `content`

### Problem Statement
使用者在檢索報告時，常需要同時篩選**檢查記錄 (Study)** 的屬性，例如：
- 患者資訊：`patient_name`, `patient_age`, `patient_gender`
- 檢查資訊：`exam_source`, `exam_item`, `exam_status`, `exam_room`, `equipment_type`
- 時間範圍：`order_datetime`, `check_in_datetime`, `report_certification_datetime`

**現狀限制**：
- 使用者必須先在 Study 搜索中篩選，再透過 `exam_id` 手動查找對應報告
- 無法在 Report 搜索 UI 中直接設定「60 歲以上女性患者的 MRI 腦部檢查報告」等複合條件

---

## 2. Goals

### Primary Goals
1. **跨模型查詢能力**：在 Report 搜索中支援查詢 Study 欄位
2. **向後相容**：不破壞現有 `AdvancedQueryBuilder` 與 API 合約
3. **效能可控**：JOIN 查詢維持在可接受範圍 (<500ms @ page_size=20)

### Non-Goals
- 不修改 `Report` 與 `Study` 的資料模型結構（保持現有無 ForeignKey 設計）
- 不提供雙向搜索（Study 搜索中查 Report 欄位另案處理）
- 不支援 Report ↔ Study 的多對多關聯（當前假設 1:1 or 1:0）

---

## 3. Proposed Solution Overview

### 三種實作方案比較

| 方案 | 優點 | 缺點 | 建議 |
|------|------|------|------|
| **方案 A：Django ORM Join** | • 程式碼簡潔<br>• 類型安全<br>• 利用 ORM 快取 | • 需在 Report 模型新增 ForeignKey<br>• 需 Migration<br>• 破壞現有「無關聯」設計 | ❌ 不採用（破壞現有架構） |
| **方案 B：子查詢過濾 (Subquery)** | • 不需修改模型<br>• 利用索引<br>• 向後相容 | • SQL 略複雜<br>• 需擴展 QueryBuilder | ✅ **推薦方案** |
| **方案 C：應用層二次篩選** | • 實作最簡單 | • 效能差（全量載入）<br>• 分頁失準<br>• 不可用於大資料集 | ❌ 不採用 |

### 選定方案：**方案 B - 子查詢過濾**

---

## 4. Technical Approach (方案 B 詳細設計)

### 4.1. Backend: 擴展 `AdvancedQueryBuilder`

#### 新增欄位配置
```python
FIELD_CONFIG: dict[str, dict[str, Any]] = {
    # === 現有 Report 欄位 ===
    'title': {'model': 'report', 'field': 'title', 'operators': TEXT_OPERATORS},
    'report_type': {'model': 'report', 'field': 'report_type', 'operators': TEXT_OPERATORS | LIST_OPERATORS},
    # ...
    
    # === 新增 Study 欄位 ===
    'study.patient_name': {
        'model': 'study',
        'field': 'patient_name',
        'operators': TEXT_OPERATORS,
        'join_field': 'report_id'  # Report.report_id = Study.exam_id
    },
    'study.patient_age': {
        'model': 'study',
        'field': 'patient_age',
        'operators': RANGE_OPERATORS,
        'join_field': 'report_id'
    },
    'study.exam_source': {
        'model': 'study',
        'field': 'exam_source',
        'operators': TEXT_OPERATORS | LIST_OPERATORS,
        'join_field': 'report_id'
    },
    'study.order_datetime': {
        'model': 'study',
        'field': 'order_datetime',
        'operators': RANGE_OPERATORS,
        'join_field': 'report_id'
    },
}
```

#### 查詢生成邏輯
```python
def _build_condition(self, node: dict) -> tuple[Q, SearchQuery | None]:
    field_key = node.get('field')
    field_meta = self.FIELD_CONFIG[field_key]
    
    if field_meta.get('model') == 'study':
        # 使用子查詢過濾
        # Q(report_id__in=Study.objects.filter(...).values_list('exam_id', flat=True))
        return self._build_study_subquery(field_meta, operator, value), None
    
    # 現有 Report 欄位邏輯...
```

#### 子查詢實作
```python
def _build_study_subquery(self, field_meta: dict, operator: str, value: Any) -> Q:
    """Generate subquery filter for Study fields."""
    field_name = field_meta['field']
    
    # 構建 Study 的過濾條件
    if operator in TEXT_OPERATORS:
        lookup = {'contains': 'icontains', 'equals': 'iexact'}[operator]
        study_filter = Q(**{f'{field_name}__{lookup}': value})
    elif operator in RANGE_OPERATORS:
        # ... range logic
    
    # 取得符合條件的 exam_id 清單
    matching_exam_ids = Study.objects.filter(study_filter).values_list('exam_id', flat=True)
    
    # 轉換為 Report 的過濾條件
    return Q(report_id__in=matching_exam_ids)
```

### 4.2. Frontend: 擴展 `QueryBuilder`

#### 新增欄位選項
```typescript
const FIELD_META: Record<string, FieldMetadata> = {
  // === Report 欄位 ===
  title: { label: '報告標題', type: 'text', operators: ['contains', 'equals', 'starts_with'] },
  report_type: { label: '報告類型', type: 'select', operators: ['equals', 'in'] },
  
  // === Study 欄位（新增）===
  'study.patient_name': { 
    label: '患者姓名', 
    type: 'text', 
    operators: ['contains', 'equals'],
    group: 'Study Info' 
  },
  'study.patient_age': { 
    label: '患者年齡', 
    type: 'number', 
    operators: ['gte', 'lte', 'between'],
    group: 'Study Info' 
  },
  'study.exam_source': { 
    label: '檢查來源', 
    type: 'select', 
    operators: ['equals', 'in'],
    group: 'Exam Info',
    options: ['CT', 'MRI', 'X-ray', 'Ultrasound'] 
  },
  'study.order_datetime': { 
    label: '開單時間', 
    type: 'datetime', 
    operators: ['gte', 'lte', 'between'],
    group: 'Time' 
  },
}
```

#### UI 調整
```typescript
// 欄位選擇器分組顯示
<Select.OptGroup label="報告欄位">
  <Select.Option value="title">報告標題</Select.Option>
  <Select.Option value="report_type">報告類型</Select.Option>
</Select.OptGroup>
<Select.OptGroup label="檢查資訊">
  <Select.Option value="study.patient_name">患者姓名</Select.Option>
  <Select.Option value="study.exam_source">檢查來源</Select.Option>
</Select.OptGroup>
```

---

## 5. Success Metrics

### Functional
- [ ] 支援至少 5 個關鍵 Study 欄位（`patient_name`, `patient_age`, `exam_source`, `order_datetime`, `exam_status`）
- [ ] 混合 Report + Study 條件的查詢返回正確結果
- [ ] 現有純 Report 查詢功能不受影響

### Performance
- [ ] 單一 Study 條件查詢：<300ms (page_size=20)
- [ ] 混合 Report + Study 條件：<500ms
- [ ] 複雜巢狀查詢（3 層, 10 條件）：<800ms

### UX
- [ ] 欄位分組清晰，使用者能快速找到 Study 相關欄位
- [ ] 錯誤提示明確（例如不支援的欄位組合）

---

## 6. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| 子查詢效能差（未索引） | 🔴 查詢超時 | 確保 `Study.exam_id` 有 PK 索引，`Report.report_id` 有索引 |
| JOIN 返回重複資料 | 🟡 結果錯誤 | 使用 `values_list('exam_id', flat=True)` + `Q(report_id__in=...)` 避免 JOIN |
| 現有 QueryBuilder 邏輯複雜化 | 🟡 維護困難 | 單獨封裝 `_build_study_subquery` 方法 |
| 使用者誤用導致慢查詢 | 🟡 效能下降 | 保持現有 MAX_NODES=20 限制，監控慢查詢 |

---

## 7. Alternatives Considered

### 方案 A：新增 ForeignKey（已否決）
**理由**：
- 需 Migration 修改生產資料庫
- 破壞現有「鬆耦合」設計哲學
- 若未來 Report 與 Study 變成多對多，需再次重構

### 方案 C：應用層過濾（已否決）
```python
# 錯誤示範
reports = Report.objects.filter(...)  # 先取得所有報告
report_ids = [r.report_id for r in reports]
studies = Study.objects.filter(exam_id__in=report_ids, patient_age__gte=60)
valid_ids = studies.values_list('exam_id')
return [r for r in reports if r.report_id in valid_ids]  # 應用層過濾
```
**缺點**：
- 分頁會錯誤（先取 20 筆再過濾可能剩 5 筆）
- 無法利用 DB 索引
- 記憶體浪費

---

## 8. Open Questions

1. **是否需要支援反向查詢？**
   - 例如：「有報告的 Study」vs「無報告的 Study」
   - **建議**：本提案範圍外，另開 `enable-report-fields-in-study-search`

2. **Report ↔ Study 是否可能多對多？**
   - 現狀假設 1:1 或 1:0
   - **建議**：若未來有需求，使用關聯表 + 調整子查詢邏輯

3. **是否需要快取 Study 欄位到 Report？**
   - 例如：`Report.patient_name_denorm`
   - **建議**：不採用，增加資料不一致風險

---

## 9. Next Steps

1. **Review & Approval** (本階段)
   - 確認方案 B（子查詢）符合架構原則
   - 確認欲支援的 Study 欄位清單

2. **Design & Tasks** (下階段)
   - 編寫 `design.md` 詳細技術規格
   - 制定 `tasks.md` 實作步驟
   - 定義 Spec Deltas（SR/SD）

3. **Implementation**
   - Backend: 擴展 `AdvancedQueryBuilder`
   - Frontend: 擴展 `QueryBuilder` 欄位選項
   - Testing: 單元測試 + 整合測試 + 效能測試

---

## 10. References

- **Related Changes**:
  - `implement-advanced-report-search`: 現有多條件搜索基礎
  - `unify-project-resource-workbench`: Report + Study 整合 UI

- **Models**:
  - `backend_django/report/models.py`: Report 模型
  - `backend_django/study/models.py`: Study 模型

- **Current QueryBuilder**:
  - `backend_django/report/services/query_builder.py`
  - `frontend/src/components/Search/QueryBuilder.tsx`

