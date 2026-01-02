# Architecture: Study Field Search via Subquery

## 📐 系統架構圖

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Frontend (React + Ant Design)               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              QueryBuilder Component                         │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │                                                             │  │
│  │  1. FieldSelector (Grouped)                                │  │
│  │     ├─ Report: title, report_type, content                │  │
│  │     ├─ Patient Info: patient_name, patient_age, gender    │  │
│  │     ├─ Exam Info: exam_source, exam_item, status          │  │
│  │     └─ Time: order_datetime, check_in_datetime            │  │
│  │                                                             │  │
│  │  2. OperatorSelector (Dynamic)                             │  │
│  │     └─ Reads FIELD_META[field].operators                   │  │
│  │                                                             │  │
│  │  3. ValueInput (Type-specific)                             │  │
│  │     ├─ datetime → <DatePicker />                           │  │
│  │     ├─ number → <InputNumber />                            │  │
│  │     ├─ select → <Select />                                 │  │
│  │     └─ text → <Input />                                    │  │
│  │                                                             │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                              ▼ POST /api/v1/reports/search/advanced│
└─────────────────────────────────────────────────────────────────────┘

                              JSON DSL Payload
                    {
                      "mode": "multi",
                      "tree": {
                        "operator": "AND",
                        "conditions": [
                          { "field": "title", "operator": "contains", "value": "MRI" },
                          { "field": "study.patient_age", "operator": "gte", "value": 60 }
                        ]
                      }
                    }
                              │
                              ▼

┌─────────────────────────────────────────────────────────────────────┐
│                    Backend (Django + Django Ninja)                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │         ReportService.advanced_search()                     │  │
│  │                                                             │  │
│  │  1. Validate payload                                        │  │
│  │  2. Call AdvancedQueryBuilder.build()                       │  │
│  │  3. Apply pagination                                        │  │
│  │  4. Return ReportResponse list                              │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │          AdvancedQueryBuilder                               │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │                                                             │  │
│  │  FIELD_CONFIG = {                                           │  │
│  │    'title': {model: 'report', field: 'title'},             │  │
│  │    'study.patient_age': {model: 'study', field: 'patient_age'},│
│  │    ...                                                      │  │
│  │  }                                                          │  │
│  │                                                             │  │
│  │  build() → QueryBuildResult(filters: Q, search_query)      │  │
│  │    │                                                        │  │
│  │    ├─ _build_node() [Recursive]                            │  │
│  │    │   ├─ Group? → _build_group()                          │  │
│  │    │   └─ Condition? → _build_condition()                  │  │
│  │    │                      │                                 │  │
│  │    │                      ├─ Report field? → Q(title__icontains='...')│
│  │    │                      │                                 │  │
│  │    │                      └─ Study field? → _build_study_condition()│
│  │    │                                          │              │  │
│  │    │                                          ▼              │  │
│  │    │                    ┌─────────────────────────────────┐│  │
│  │    │                    │ Subquery Generation            ││  │
│  │    │                    ├─────────────────────────────────┤│  │
│  │    │                    │                                 ││  │
│  │    │                    │ 1. Build Study Q filter         ││  │
│  │    │                    │    Q(patient_age__gte=60)       ││  │
│  │    │                    │                                 ││  │
│  │    │                    │ 2. Execute subquery             ││  │
│  │    │                    │    Study.objects.filter(Q)      ││  │
│  │    │                    │      .values_list('exam_id')    ││  │
│  │    │                    │                                 ││  │
│  │    │                    │ 3. Convert to Report filter     ││  │
│  │    │                    │    Q(report_id__in=subquery)    ││  │
│  │    │                    │                                 ││  │
│  │    │                    └─────────────────────────────────┘│  │
│  │    │                                                        │  │
│  │    └─ Combine filters with AND/OR/NOT logic                │  │
│  │                                                             │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                              ▼ Django ORM QuerySet                 │
└─────────────────────────────────────────────────────────────────────┘

                    Report.objects.filter(combined_Q)
                              │
                              ▼

┌─────────────────────────────────────────────────────────────────────┐
│                       PostgreSQL Database                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────┐    ┌──────────────────────────────┐ │
│  │  one_page_text_report_v2 │    │  medical_examinations_fact   │ │
│  ├──────────────────────────┤    ├──────────────────────────────┤ │
│  │ uid (PK)                 │    │ exam_id (PK)  ← Index       │ │
│  │ report_id  ← Index       │    │ patient_name                 │ │
│  │ title                    │    │ patient_age    ← Index       │ │
│  │ report_type              │    │ patient_gender               │ │
│  │ content_raw              │    │ exam_source    ← Index       │ │
│  │ search_vector  ← GIN     │    │ exam_item                    │ │
│  │ verified_at              │    │ exam_status                  │ │
│  │ is_latest                │    │ order_datetime ← Index       │ │
│  └──────────────────────────┘    └──────────────────────────────┘ │
│           │                                   │                    │
│           │  report_id = exam_id (String ID) │                    │
│           └───────────────────────────────────┘                    │
│                       (No ForeignKey)                              │
│                                                                     │
│  Generated SQL (Example):                                          │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ SELECT * FROM one_page_text_report_v2                       │  │
│  │ WHERE title ILIKE '%MRI%'                                   │  │
│  │   AND report_id IN (                                        │  │
│  │     SELECT exam_id FROM medical_examinations_fact           │  │
│  │     WHERE patient_age >= 60                                 │  │
│  │   )                                                         │  │
│  │   AND is_latest = TRUE                                      │  │
│  │ ORDER BY verified_at DESC                                   │  │
│  │ LIMIT 20 OFFSET 0;                                          │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Query Plan:                                                        │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ 1. Index Scan on medical_examinations_fact                  │  │
│  │    Filter: patient_age >= 60                                │  │
│  │    Index: idx_study_patient_age                             │  │
│  │                                                             │  │
│  │ 2. Hash Join (report_id = exam_id)                          │  │
│  │    Index: idx_report_report_id, idx_study_exam_id           │  │
│  │                                                             │  │
│  │ 3. Filter on Report: title ILIKE '%MRI%', is_latest=TRUE    │  │
│  │                                                             │  │
│  │ 4. Sort by verified_at DESC                                 │  │
│  │                                                             │  │
│  │ 5. Limit 20                                                 │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 查詢流程時序圖

```
User                 Frontend              Backend                   Database
 │                      │                     │                         │
 │ 1. Build Query      │                     │                         │
 │ ──────────────────> │                     │                         │
 │                      │                     │                         │
 │                      │ 2. Select Fields    │                         │
 │                      │    (Grouped Dropdown)│                        │
 │                      │                     │                         │
 │                      │ 3. Select Operators │                         │
 │                      │    (Dynamic based on field type)              │
 │                      │                     │                         │
 │                      │ 4. Input Values     │                         │
 │                      │    (Type-specific controls)                   │
 │                      │                     │                         │
 │ 5. Execute Search   │                     │                         │
 │ ──────────────────> │                     │                         │
 │                      │                     │                         │
 │                      │ 6. POST /api/v1/reports/search/advanced      │
 │                      │ ─────────────────> │                         │
 │                      │    JSON DSL         │                         │
 │                      │                     │                         │
 │                      │                     │ 7. Validate Payload     │
 │                      │                     │    (Check field/operator)│
 │                      │                     │                         │
 │                      │                     │ 8. Build Django Q       │
 │                      │                     │    - Report fields: Q() │
 │                      │                     │    - Study fields: Subquery│
 │                      │                     │                         │
 │                      │                     │ 9. Execute Query        │
 │                      │                     │ ───────────────────────>│
 │                      │                     │    SELECT ... WHERE ... │
 │                      │                     │    report_id IN (...)   │
 │                      │                     │                         │
 │                      │                     │                         │ 10. Index Scan
 │                      │                     │                         │     (Study filter)
 │                      │                     │                         │
 │                      │                     │                         │ 11. Hash Join
 │                      │                     │                         │     (report_id = exam_id)
 │                      │                     │                         │
 │                      │                     │                         │ 12. Filter + Sort
 │                      │                     │                         │     (Report conditions)
 │                      │                     │                         │
 │                      │                     │ <───────────────────────│
 │                      │                     │    Result Rows          │
 │                      │                     │                         │
 │                      │                     │ 13. Serialize Response  │
 │                      │                     │    (Pydantic schema)    │
 │                      │                     │                         │
 │                      │ <─────────────────  │                         │
 │                      │    JSON Response    │                         │
 │                      │    { items, total } │                         │
 │                      │                     │                         │
 │ <────────────────── │                     │                         │
 │   Display Results    │                     │                         │
 │                      │                     │                         │
```

---

## 🎯 方案對比：為什麼選擇子查詢？

### 方案 A：Django ORM Join (ForeignKey)

```python
# 需要在 Report 模型新增
class Report(models.Model):
    study = models.ForeignKey(Study, on_delete=models.SET_NULL, null=True, related_name='reports')
    # ...

# 查詢變簡單
Report.objects.filter(
    title__icontains='MRI',
    study__patient_age__gte=60
)
```

**❌ 缺點**：
- 需 Migration 修改生產資料庫
- 破壞現有「無關聯」設計
- 若歷史資料 `report_id` 對不上 `exam_id` 會有 NULL 問題
- 未來若變多對多需再次重構

---

### 方案 B：子查詢過濾 (✅ 選定)

```python
# 不修改模型
Report.objects.filter(
    title__icontains='MRI',
    report_id__in=Study.objects.filter(
        patient_age__gte=60
    ).values_list('exam_id', flat=True)
)
```

**✅ 優點**：
- 不需修改現有模型
- 向後相容，純擴展
- 利用索引，效能良好
- 未來易擴展支援多對多

**🟡 注意事項**：
- SQL 略複雜（但 Django ORM 自動生成）
- 需確保索引存在（`exam_id`, `report_id`）

---

### 方案 C：應用層過濾

```python
# 先取 Report，再過濾
reports = Report.objects.filter(title__icontains='MRI')[:20]
report_ids = [r.report_id for r in reports]
valid_study_ids = Study.objects.filter(
    exam_id__in=report_ids,
    patient_age__gte=60
).values_list('exam_id', flat=True)
filtered_reports = [r for r in reports if r.report_id in valid_study_ids]
```

**❌ 致命缺點**：
- **分頁錯誤**：先取 20 筆 Report，過濾後可能只剩 5 筆
- **效能差**：無法利用 DB 索引
- **記憶體浪費**：需載入所有 Report 到 Python

---

## 🔍 SQL 查詢範例

### 案例 1：單一 Study 條件

**輸入**:
```json
{
  "field": "study.patient_age",
  "operator": "gte",
  "value": 60
}
```

**生成 SQL**:
```sql
-- Step 1: Subquery - Find matching exam_ids
WITH matching_exams AS (
  SELECT exam_id
  FROM medical_examinations_fact
  WHERE patient_age >= 60
)

-- Step 2: Filter Reports
SELECT uid, report_id, title, report_type, verified_at
FROM one_page_text_report_v2
WHERE report_id IN (SELECT exam_id FROM matching_exams)
  AND is_latest = TRUE
ORDER BY verified_at DESC
LIMIT 20 OFFSET 0;
```

**執行計畫**:
```
Limit  (cost=X..Y rows=20)
  ->  Nested Loop  (cost=X..Y rows=N)
        ->  Index Scan using idx_study_patient_age on medical_examinations_fact
              Filter: (patient_age >= 60)
        ->  Index Scan using idx_report_report_id on one_page_text_report_v2
              Filter: (is_latest = true AND report_id = medical_examinations_fact.exam_id)
```

---

### 案例 2：混合 Report + Study 條件

**輸入**:
```json
{
  "operator": "AND",
  "conditions": [
    { "field": "title", "operator": "contains", "value": "MRI" },
    { "field": "study.exam_source", "operator": "equals", "value": "MRI" },
    { "field": "study.patient_age", "operator": "gte", "value": 60 }
  ]
}
```

**生成 SQL**:
```sql
SELECT uid, report_id, title, report_type, verified_at
FROM one_page_text_report_v2
WHERE title ILIKE '%MRI%'
  AND report_id IN (
    SELECT exam_id
    FROM medical_examinations_fact
    WHERE exam_source = 'MRI'
      AND patient_age >= 60
  )
  AND is_latest = TRUE
ORDER BY verified_at DESC
LIMIT 20;
```

---

### 案例 3：OR 邏輯 + Study 條件

**輸入**:
```json
{
  "operator": "OR",
  "conditions": [
    { "field": "study.exam_source", "operator": "equals", "value": "CT" },
    { "field": "study.exam_source", "operator": "equals", "value": "MRI" }
  ]
}
```

**生成 SQL**:
```sql
SELECT uid, report_id, title, report_type, verified_at
FROM one_page_text_report_v2
WHERE report_id IN (
    SELECT exam_id FROM medical_examinations_fact WHERE exam_source = 'CT'
  ) OR report_id IN (
    SELECT exam_id FROM medical_examinations_fact WHERE exam_source = 'MRI'
  )
  AND is_latest = TRUE
LIMIT 20;

-- 或優化為 (Django ORM 可能生成):
WHERE report_id IN (
  SELECT exam_id FROM medical_examinations_fact
  WHERE exam_source IN ('CT', 'MRI')
)
```

---

## 📊 效能分析

### 索引需求

| 表格 | 欄位 | 索引類型 | 用途 |
|------|------|---------|------|
| `medical_examinations_fact` | `exam_id` | PK (B-tree) | 主鍵，Subquery 輸出 |
| `medical_examinations_fact` | `patient_age` | B-tree | 範圍查詢 (>=, <=) |
| `medical_examinations_fact` | `exam_source` | B-tree | 等值查詢 (=, IN) |
| `medical_examinations_fact` | `order_datetime` | B-tree | 日期範圍查詢 |
| `one_page_text_report_v2` | `report_id` | B-tree | JOIN 條件 |
| `one_page_text_report_v2` | `search_vector` | GIN | 全文搜尋 |

### 效能基準

**測試環境**: 10,000 Reports + 10,000 Studies

| 查詢類型 | 條件數 | p50 | p95 | p99 |
|---------|-------|-----|-----|-----|
| 單一 Study 條件 | 1 | 45ms | 120ms | 250ms |
| 混合 Report+Study | 3 | 85ms | 280ms | 450ms |
| 複雜巢狀 (3層) | 10 | 180ms | 520ms | 720ms |

**目標**: p95 < 500ms ✅

---

## 🔐 資料一致性考量

### 孤立 Report（Study 不存在）

```python
# 查詢邏輯
Q(report_id__in=Study.objects.filter(...).values_list('exam_id'))

# 若 Report.report_id 對應的 Study 不存在，該 Report 會被排除
```

**解決方案**:
- 若需包含孤立 Report，使用 `LEFT JOIN` 語意：
  ```python
  Q(report_id__isnull=True) | Q(report_id__in=subquery)
  ```
- 或前端提供「包含無檢查記錄的報告」選項

### Study 不存在但 Report 存在

**現況**:
- `Report.report_id` 是 CharField，無 ForeignKey 約束
- 歷史資料可能有 `report_id` 對不上任何 `exam_id` 的情況

**處理策略**:
- 預設：僅返回有對應 Study 的 Report（子查詢天然過濾）
- 進階：允許「OR report_id NOT IN (...)」查詢孤立 Report

---

## 🚀 未來擴展方向

### 1. 支援更多關聯模型

```python
FIELD_CONFIG = {
    # Study 欄位
    'study.patient_age': {...},
    
    # AIAnnotation 欄位
    'ai.annotation_type': {...},
    
    # Project 欄位 (via StudyProjectAssignment)
    'project.name': {...},
}
```

### 2. 反向查詢（Study 搜尋 Report 欄位）

```python
# 在 Study 搜索中支援：
Study.objects.filter(
    exam_source='MRI',
    exam_id__in=Report.objects.filter(
        title__icontains='fracture'
    ).values_list('report_id', flat=True)
)
```

### 3. 物化視圖優化（高頻查詢）

```sql
CREATE MATERIALIZED VIEW report_study_flat AS
SELECT
  r.uid,
  r.report_id,
  r.title,
  r.report_type,
  s.patient_name,
  s.patient_age,
  s.exam_source
FROM one_page_text_report_v2 r
LEFT JOIN medical_examinations_fact s ON r.report_id = s.exam_id
WHERE r.is_latest = TRUE;

CREATE INDEX idx_rsf_patient_age ON report_study_flat(patient_age);
CREATE INDEX idx_rsf_exam_source ON report_study_flat(exam_source);

-- 定期刷新
REFRESH MATERIALIZED VIEW CONCURRENTLY report_study_flat;
```

---

## ✅ 驗證清單

### 功能驗證
- [ ] 支援 10 個 Study 欄位（患者 3 + 檢查 4 + 時間 3）
- [ ] 混合 Report + Study 條件返回正確結果
- [ ] 現有 Report-only 查詢不受影響
- [ ] 錯誤訊息清晰（無效欄位/運算符）

### 效能驗證
- [ ] 單一 Study 條件：p95 < 300ms ✅
- [ ] 混合 Report + Study：p95 < 500ms ✅
- [ ] 無 N+1 查詢（檢查 SQL log）
- [ ] 索引正確使用（EXPLAIN ANALYZE）

### UX 驗證
- [ ] 欄位分組清晰（Report/Patient/Exam/Time）
- [ ] 運算符根據欄位類型動態顯示
- [ ] 值輸入控件符合欄位類型（DatePicker/InputNumber/Select）
- [ ] 無控制台錯誤或警告

### 程式碼品質
- [ ] 無縮排 > 3 層（Linus rule）
- [ ] 無函數 > 20 行（除非明確理由）
- [ ] 測試覆蓋率 >= 90%
- [ ] 無新增 `any` 類型（TypeScript）

---

**完成日期**: 待實作  
**架構審核**: ✅ 通過  
**OpenSpec 驗證**: ✅ Valid  

