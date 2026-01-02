# Enable Study Fields in Report Search

## 📋 提案概要

**Status**: ✅ Validated  
**Change ID**: `enable-study-fields-in-report-search`  
**Created**: 2025-11-26  

### 問題陳述

使用者在檢索報告時，經常需要根據**檢查記錄 (Study)** 的屬性進行篩選，例如：
- 患者年齡、性別
- 檢查來源（CT/MRI）
- 檢查項目、狀態
- 開單時間、報告認證時間

**現狀**：Report 搜索僅支援 Report 自身欄位，無法直接查詢 Study 資訊。

---

## 🎯 解決方案

### 方案選擇：**子查詢過濾 (Subquery)**

在現有多條件高級搜索架構下，透過 Django ORM 子查詢支援跨模型查詢：

```python
# 使用者查詢：「60歲以上患者的MRI報告」
Q(title__icontains='MRI') & Q(
    report_id__in=Study.objects.filter(
        patient_age__gte=60, 
        exam_source='MRI'
    ).values_list('exam_id', flat=True)
)
```

### 優勢
✅ **不修改資料模型**：保持現有無 ForeignKey 設計  
✅ **利用索引**：子查詢在 DB 端執行，效能優良  
✅ **向後相容**：不影響現有 Report 欄位查詢  
✅ **易擴展**：未來可支援更多關聯模型  

---

## 📊 三種方案比較

| 方案 | 實作難度 | 效能 | 模型變更 | 向後相容 | 推薦 |
|------|---------|------|---------|---------|------|
| **A. Django ORM Join** | 低 | ⭐⭐⭐ | ❌ 需新增 ForeignKey | ✅ | ❌ 破壞現有架構 |
| **B. 子查詢過濾** | 中 | ⭐⭐⭐⭐ | ✅ 無需變更 | ✅ | ✅ **推薦** |
| **C. 應用層二次篩選** | 低 | ⭐ | ✅ 無需變更 | ✅ | ❌ 效能差、分頁錯誤 |

---

## 🔧 支援的 Study 欄位

### 患者資訊
- `study.patient_name` (文字)
- `study.patient_age` (數字)
- `study.patient_gender` (選項: M/F/U)

### 檢查資訊
- `study.exam_source` (選項: CT/MRI/X-ray/Ultrasound)
- `study.exam_item` (文字)
- `study.exam_status` (選項: pending/completed/cancelled)
- `study.equipment_type` (文字)

### 時間範圍
- `study.order_datetime` (日期時間)
- `study.check_in_datetime` (日期時間)
- `study.report_certification_datetime` (日期時間)

---

## 🎨 UI 改進

### 分組欄位選擇器
```
欄位選擇 ▼
├── Report
│   ├── 報告標題
│   ├── 報告類型
│   └── 內容搜尋
├── Patient Info
│   ├── 患者姓名
│   ├── 患者年齡
│   └── 患者性別
├── Exam Info
│   ├── 檢查來源
│   ├── 檢查項目
│   ├── 檢查狀態
│   └── 設備類型
└── Time Range
    ├── 開單時間
    ├── 簽到時間
    └── 報告認證時間
```

### 類型專屬輸入控件
- **日期時間欄位** → `<DatePicker showTime />`
- **數字欄位** → `<InputNumber />`
- **選項欄位** → `<Select options={...} />`
- **文字欄位** → `<Input />`

---

## 📈 效能目標

| 查詢類型 | 資料規模 | p95 延遲目標 |
|---------|---------|-------------|
| 單一 Study 條件 | 10K reports | **< 300ms** |
| 混合 Report + Study | 10K reports | **< 500ms** |
| 複雜巢狀 (3層10條件) | 10K reports | **< 800ms** |

---

## 📝 實作步驟

### Phase 1: Backend Foundation
1. 擴展 `AdvancedQueryBuilder.FIELD_CONFIG`
2. 實作 `_build_study_condition()` 子查詢方法
3. 整合到現有 `_build_condition()` 流程
4. 單元測試（覆蓋率 >= 90%）

### Phase 2: Frontend UI
1. 更新 `FIELD_META` 定義 Study 欄位
2. 實作分組 `FieldSelector` 元件
3. 實作類型專屬 `ValueInput` 元件
4. TypeScript 類型定義更新

### Phase 3: Integration & Testing
1. Integration tests (API endpoint)
2. Performance benchmarks (10K dataset)
3. End-to-end testing (UI → Backend → DB)

### Phase 4: Documentation & Deployment
1. 更新 API 文件
2. 使用者指南
3. 監控設定
4. 生產部署

---

## 🚀 使用範例

### 案例 1：60歲以上女性患者的MRI腦部檢查報告

**JSON DSL**:
```json
{
  "mode": "multi",
  "tree": {
    "operator": "AND",
    "conditions": [
      { "field": "title", "operator": "contains", "value": "Brain" },
      { "field": "study.patient_gender", "operator": "equals", "value": "F" },
      { "field": "study.patient_age", "operator": "gte", "value": 60 },
      { "field": "study.exam_source", "operator": "equals", "value": "MRI" }
    ]
  }
}
```

### 案例 2：去年完成的CT檢查但報告未認證

**JSON DSL**:
```json
{
  "mode": "multi",
  "tree": {
    "operator": "AND",
    "conditions": [
      { "field": "study.exam_source", "operator": "equals", "value": "CT" },
      { "field": "study.exam_status", "operator": "equals", "value": "completed" },
      { 
        "field": "study.order_datetime", 
        "operator": "between", 
        "value": { "start": "2024-01-01T00:00:00Z", "end": "2024-12-31T23:59:59Z" }
      },
      { "field": "verified_at", "operator": "equals", "value": null }
    ]
  }
}
```

---

## 🔗 相關文件

- **Proposal**: `proposal.md` - 詳細背景、方案評估、風險分析
- **Design**: `design.md` - 技術架構、SQL 範例、效能分析
- **Tasks**: `tasks.md` - 逐步實作清單、驗收標準
- **Spec**: `specs/report-study-search/spec.md` - SR/SD 需求定義

---

## ✅ 驗證狀態

```bash
$ openspec validate enable-study-fields-in-report-search --strict
Change 'enable-study-fields-in-report-search' is valid
```

---

## 🎓 設計原則遵循

### Linus Torvalds' Good Taste
- ✅ **消除特殊情況**：用資料驅動的 `FIELD_CONFIG` 取代 if/else 鏈
- ✅ **扁平邏輯**：子查詢方法獨立封裝，無深度嵌套
- ✅ **簡潔實用**：不過度抽象，直接解決問題

### Django Best Practices
- ✅ **ORM 優先**：使用 Django Q 對象和 QuerySet
- ✅ **索引利用**：子查詢利用現有 PK 索引
- ✅ **向後相容**：不修改已發布的 API 合約

---

## 🙋 常見問題

### Q1: 為什麼不直接新增 ForeignKey？
**A**: 現有設計有意保持 Report 和 Study 的鬆耦合關聯。新增 ForeignKey 需要：
- Migration 修改生產資料庫
- 處理歷史資料的完整性
- 未來可能需支援多對多關聯時再次重構

### Q2: 子查詢效能會不會很差？
**A**: 不會。因為：
- `Study.exam_id` 是主鍵，有索引
- `Report.report_id` 有索引
- `values_list('exam_id', flat=True)` 只查詢單一欄位
- PostgreSQL query planner 會優化 IN 子查詢

### Q3: 支援 Study 搜索 Report 欄位嗎？
**A**: 本提案範圍外。可另開 `enable-report-fields-in-study-search` 變更。

### Q4: 如果 Report 和 Study 不是 1:1 關聯怎麼辦？
**A**: 當前假設 1:1 或 1:0。若未來有多對多需求，子查詢邏輯可以自然擴展（使用 `DISTINCT`）。

---

## 📞 聯絡資訊

如有疑問或建議，請在提案中留言或聯繫開發團隊。

