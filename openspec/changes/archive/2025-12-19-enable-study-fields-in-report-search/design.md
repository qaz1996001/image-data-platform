# Design: Enable Study Fields in Report Search

## 1. Architecture Overview

### 1.1. Query Flow

```
User Input (QueryBuilder UI)
  │
  ├─ Report Field: { field: "title", operator: "contains", value: "MRI" }
  │   └─> Direct Q() filter on Report model
  │
  └─ Study Field: { field: "study.patient_age", operator: "gte", value: 60 }
      └─> Subquery: Q(report_id__in=Study.objects.filter(patient_age__gte=60).values_list('exam_id'))
         │
         └─> Combined with AND/OR logic
             └─> Final QuerySet: Report.objects.filter(combined_Q)
```

### 1.2. Design Principles

1. **無 ForeignKey 依賴**：透過 `report_id = exam_id` 字串關聯
2. **子查詢優先**：利用 DB 索引，避免應用層過濾
3. **向後相容**：現有 Report 欄位查詢邏輯不變
4. **可擴展性**：未來可支援更多關聯模型（如 AIAnnotation）

---

## 2. Backend Implementation

### 2.1. Extended Field Configuration

```python
# backend_django/report/services/query_builder.py

class AdvancedQueryBuilder:
    # === 新增 Study 欄位映射 ===
    STUDY_FIELD_CONFIG: dict[str, dict[str, Any]] = {
        # 患者資訊
        'study.patient_name': {
            'db_field': 'patient_name',
            'operators': TEXT_OPERATORS,
            'type': 'text'
        },
        'study.patient_age': {
            'db_field': 'patient_age',
            'operators': RANGE_OPERATORS,
            'type': 'integer'
        },
        'study.patient_gender': {
            'db_field': 'patient_gender',
            'operators': LIST_OPERATORS,
            'type': 'choice'
        },
        
        # 檢查資訊
        'study.exam_source': {
            'db_field': 'exam_source',
            'operators': TEXT_OPERATORS | LIST_OPERATORS,
            'type': 'text'
        },
        'study.exam_item': {
            'db_field': 'exam_item',
            'operators': TEXT_OPERATORS,
            'type': 'text'
        },
        'study.exam_status': {
            'db_field': 'exam_status',
            'operators': LIST_OPERATORS,
            'type': 'choice'
        },
        'study.equipment_type': {
            'db_field': 'equipment_type',
            'operators': TEXT_OPERATORS | LIST_OPERATORS,
            'type': 'text'
        },
        
        # 時間範圍
        'study.order_datetime': {
            'db_field': 'order_datetime',
            'operators': RANGE_OPERATORS,
            'type': 'datetime'
        },
        'study.check_in_datetime': {
            'db_field': 'check_in_datetime',
            'operators': RANGE_OPERATORS,
            'type': 'datetime'
        },
        'study.report_certification_datetime': {
            'db_field': 'report_certification_datetime',
            'operators': RANGE_OPERATORS,
            'type': 'datetime'
        },
    }
    
    # 合併到主配置
    FIELD_CONFIG: dict[str, dict[str, Any]] = {
        **EXISTING_REPORT_FIELDS,
        **STUDY_FIELD_CONFIG,
    }
```

### 2.2. Subquery Builder

```python
def _build_condition(self, node: Any) -> tuple[Q, SearchQuery | None]:
    """Enhanced to handle cross-model queries."""
    field_key = node.get('field')
    operator = (node.get('operator') or 'equals').lower()
    value = node.get('value')
    
    if not field_key or field_key not in self.FIELD_CONFIG:
        raise AdvancedQueryValidationError(f'Unsupported field: {field_key}')
    
    # === 新增：檢測 Study 欄位 ===
    if field_key.startswith('study.'):
        return self._build_study_condition(field_key, operator, value), None
    
    # === 現有 Report 欄位邏輯 ===
    if field_key == 'content':
        return self._build_search_condition(value)
    
    field_meta = self.FIELD_CONFIG[field_key]
    field_name = field_meta['field']
    
    if operator in self.TEXT_OPERATORS:
        return self._build_text_condition(field_name, operator, value), None
    # ... 其他運算符
```

```python
def _build_study_condition(self, field_key: str, operator: str, value: Any) -> Q:
    """
    Build subquery filter for Study fields.
    
    Example:
        field_key = 'study.patient_age'
        operator = 'gte'
        value = 60
        
        Returns:
            Q(report_id__in=Study.objects.filter(patient_age__gte=60).values_list('exam_id', flat=True))
    """
    from study.models import Study
    
    field_meta = self.STUDY_FIELD_CONFIG[field_key]
    db_field = field_meta['db_field']
    
    # === 1. 構建 Study 的過濾條件 ===
    if operator in self.TEXT_OPERATORS:
        study_q = self._build_text_condition(db_field, operator, value)
    elif operator in self.LIST_OPERATORS:
        study_q = self._build_list_condition(db_field, operator, value)
    elif operator in self.RANGE_OPERATORS:
        study_q = self._build_range_condition(db_field, operator, value)
    else:
        raise AdvancedQueryValidationError(
            f'Operator "{operator}" not supported for Study field "{field_key}"'
        )
    
    # === 2. 執行子查詢取得 exam_id 清單 ===
    matching_exam_ids = Study.objects.filter(study_q).values_list('exam_id', flat=True)
    
    # === 3. 轉換為 Report 的 report_id 過濾 ===
    return Q(report_id__in=matching_exam_ids)
```

### 2.3. Performance Considerations

#### Index Requirements
```python
# Ensure these indexes exist:
# - Study.exam_id (PK, already indexed)
# - Study.patient_age (for range queries)
# - Study.exam_source (for equality/IN queries)
# - Study.order_datetime (for datetime range)
# - Report.report_id (already indexed)
```

#### Query Optimization
```python
# Good: Lazy evaluation, only executes when needed
matching_exam_ids = Study.objects.filter(patient_age__gte=60).values_list('exam_id', flat=True)
# At this point, no DB query yet

report_queryset = Report.objects.filter(report_id__in=matching_exam_ids)
# Executes: SELECT exam_id FROM study WHERE patient_age >= 60
# Then: SELECT * FROM report WHERE report_id IN (...)
```

#### Anti-Pattern to Avoid
```python
# Bad: Executes immediately and loads full objects
matching_studies = list(Study.objects.filter(patient_age__gte=60))  # ❌ Memory waste
matching_ids = [s.exam_id for s in matching_studies]  # ❌ Application layer
```

### 2.4. API Contract (No Changes)

```python
# POST /api/v1/reports/search/advanced
# Request body remains unchanged:
{
  "mode": "multi",
  "tree": {
    "operator": "AND",
    "conditions": [
      { "field": "title", "operator": "contains", "value": "MRI" },
      { "field": "study.patient_age", "operator": "gte", "value": 60 }  // New
    ]
  },
  "page": 1,
  "page_size": 20
}
```

---

## 3. Frontend Implementation

### 3.1. Extended Field Metadata

```typescript
// frontend/src/components/Search/QueryBuilder.tsx

const FIELD_META: Record<string, FieldMetadata> = {
  // === 現有 Report 欄位 ===
  title: { 
    label: '報告標題', 
    type: 'text', 
    operators: ['contains', 'equals', 'starts_with', 'ends_with'],
    group: 'Report' 
  },
  report_type: { 
    label: '報告類型', 
    type: 'select', 
    operators: ['equals', 'in'],
    group: 'Report',
    options: async () => fetchReportTypes()  // Dynamic options
  },
  
  // === 新增 Study 欄位 ===
  'study.patient_name': {
    label: '患者姓名',
    type: 'text',
    operators: ['contains', 'equals', 'starts_with'],
    group: 'Patient Info'
  },
  'study.patient_age': {
    label: '患者年齡',
    type: 'number',
    operators: ['gte', 'lte', 'between'],
    group: 'Patient Info',
    placeholder: '例如：60'
  },
  'study.patient_gender': {
    label: '患者性別',
    type: 'select',
    operators: ['equals', 'in'],
    group: 'Patient Info',
    options: [
      { label: '男', value: 'M' },
      { label: '女', value: 'F' },
      { label: '未知', value: 'U' }
    ]
  },
  
  'study.exam_source': {
    label: '檢查來源',
    type: 'select',
    operators: ['equals', 'in', 'contains'],
    group: 'Exam Info',
    options: ['CT', 'MRI', 'X-ray', 'Ultrasound', 'PET', 'Mammography']
  },
  'study.exam_item': {
    label: '檢查項目',
    type: 'text',
    operators: ['contains', 'equals'],
    group: 'Exam Info',
    placeholder: '例如：Brain MRI'
  },
  'study.exam_status': {
    label: '檢查狀態',
    type: 'select',
    operators: ['equals', 'in'],
    group: 'Exam Info',
    options: [
      { label: '待完成', value: 'pending' },
      { label: '已完成', value: 'completed' },
      { label: '已取消', value: 'cancelled' }
    ]
  },
  'study.equipment_type': {
    label: '設備類型',
    type: 'text',
    operators: ['contains', 'equals', 'in'],
    group: 'Exam Info'
  },
  
  'study.order_datetime': {
    label: '開單時間',
    type: 'datetime',
    operators: ['gte', 'lte', 'between'],
    group: 'Time Range',
    format: 'YYYY-MM-DD HH:mm'
  },
  'study.check_in_datetime': {
    label: '簽到時間',
    type: 'datetime',
    operators: ['gte', 'lte', 'between'],
    group: 'Time Range'
  },
  'study.report_certification_datetime': {
    label: '報告認證時間',
    type: 'datetime',
    operators: ['gte', 'lte', 'between'],
    group: 'Time Range'
  },
}
```

### 3.2. Grouped Field Selector

```typescript
function FieldSelector({ value, onChange }: FieldSelectorProps) {
  // 按 group 分組
  const groupedFields = useMemo(() => {
    const groups: Record<string, Array<{ key: string; label: string }>> = {}
    
    Object.entries(FIELD_META).forEach(([key, meta]) => {
      const group = meta.group || 'Other'
      if (!groups[group]) groups[group] = []
      groups[group].push({ key, label: meta.label })
    })
    
    return groups
  }, [])
  
  return (
    <Select
      value={value}
      onChange={onChange}
      placeholder="選擇欄位"
      style={{ width: 200 }}
    >
      {Object.entries(groupedFields).map(([group, fields]) => (
        <Select.OptGroup key={group} label={group}>
          {fields.map(({ key, label }) => (
            <Select.Option key={key} value={key}>
              {label}
            </Select.Option>
          ))}
        </Select.OptGroup>
      ))}
    </Select>
  )
}
```

### 3.3. Dynamic Operator Selection

```typescript
function OperatorSelector({ field, value, onChange }: OperatorSelectorProps) {
  const fieldMeta = FIELD_META[field]
  const allowedOperators = fieldMeta?.operators || ['equals']
  
  const OPERATOR_LABELS: Record<string, string> = {
    contains: '包含',
    not_contains: '不包含',
    equals: '等於',
    not_equals: '不等於',
    starts_with: '開頭為',
    ends_with: '結尾為',
    in: '屬於',
    not_in: '不屬於',
    gte: '大於等於',
    lte: '小於等於',
    between: '介於',
    search: '全文搜尋'
  }
  
  return (
    <Select value={value} onChange={onChange} style={{ width: 140 }}>
      {allowedOperators.map(op => (
        <Select.Option key={op} value={op}>
          {OPERATOR_LABELS[op] || op}
        </Select.Option>
      ))}
    </Select>
  )
}
```

### 3.4. Value Input Component

```typescript
function ValueInput({ field, operator, value, onChange }: ValueInputProps) {
  const fieldMeta = FIELD_META[field]
  
  // === 日期時間輸入 ===
  if (fieldMeta.type === 'datetime') {
    if (operator === 'between') {
      return (
        <DatePicker.RangePicker
          value={value ? [dayjs(value.start), dayjs(value.end)] : null}
          onChange={dates => onChange({ 
            start: dates?.[0]?.toISOString(), 
            end: dates?.[1]?.toISOString() 
          })}
          showTime
          format="YYYY-MM-DD HH:mm"
        />
      )
    }
    return (
      <DatePicker
        value={value ? dayjs(value) : null}
        onChange={date => onChange(date?.toISOString())}
        showTime
        format="YYYY-MM-DD HH:mm"
      />
    )
  }
  
  // === 數字輸入 ===
  if (fieldMeta.type === 'number') {
    if (operator === 'between') {
      return (
        <Space.Compact>
          <InputNumber
            placeholder="最小值"
            value={value?.start}
            onChange={v => onChange({ ...value, start: v })}
          />
          <InputNumber
            placeholder="最大值"
            value={value?.end}
            onChange={v => onChange({ ...value, end: v })}
          />
        </Space.Compact>
      )
    }
    return (
      <InputNumber
        placeholder={fieldMeta.placeholder}
        value={value}
        onChange={onChange}
      />
    )
  }
  
  // === 下拉選單 ===
  if (fieldMeta.type === 'select') {
    const mode = operator === 'in' || operator === 'not_in' ? 'multiple' : undefined
    const options = typeof fieldMeta.options === 'function' 
      ? useAsync(fieldMeta.options) 
      : fieldMeta.options
    
    return (
      <Select
        mode={mode}
        value={value}
        onChange={onChange}
        options={options}
        placeholder="選擇選項"
        style={{ minWidth: 200 }}
      />
    )
  }
  
  // === 文字輸入 (預設) ===
  return (
    <Input
      placeholder={fieldMeta.placeholder || '輸入值'}
      value={value}
      onChange={e => onChange(e.target.value)}
    />
  )
}
```

---

## 4. Testing Strategy

### 4.1. Backend Unit Tests

```python
# backend_django/report/tests/test_study_field_queries.py

from django.test import TestCase
from report.services import AdvancedQueryBuilder, AdvancedQueryValidationError
from report.models import Report
from study.models import Study

class StudyFieldQueryTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        # Create test Study records
        cls.study1 = Study.objects.create(
            exam_id='EXAM001',
            patient_name='張三',
            patient_age=65,
            patient_gender='M',
            exam_source='MRI',
            exam_item='Brain MRI',
            exam_status='completed',
            order_datetime='2024-01-15T10:00:00Z'
        )
        
        # Create test Report linked to Study
        cls.report1 = Report.objects.create(
            uid='REP001',
            report_id='EXAM001',  # Links to study1.exam_id
            title='Brain MRI Report',
            report_type='Radiology',
            content_raw='Normal brain structure',
            is_latest=True
        )
    
    def test_study_patient_age_filter(self):
        """Test filtering by Study.patient_age."""
        payload = {
            'operator': 'AND',
            'conditions': [
                {'field': 'study.patient_age', 'operator': 'gte', 'value': 60}
            ]
        }
        
        builder = AdvancedQueryBuilder(payload)
        result = builder.build()
        
        reports = Report.objects.filter(result.filters)
        self.assertEqual(reports.count(), 1)
        self.assertEqual(reports.first().uid, 'REP001')
    
    def test_mixed_report_and_study_filters(self):
        """Test combining Report and Study field filters."""
        payload = {
            'operator': 'AND',
            'conditions': [
                {'field': 'title', 'operator': 'contains', 'value': 'MRI'},
                {'field': 'study.exam_source', 'operator': 'equals', 'value': 'MRI'},
                {'field': 'study.patient_age', 'operator': 'gte', 'value': 60}
            ]
        }
        
        builder = AdvancedQueryBuilder(payload)
        result = builder.build()
        
        reports = Report.objects.filter(result.filters)
        self.assertEqual(reports.count(), 1)
    
    def test_study_field_with_or_logic(self):
        """Test OR logic with Study fields."""
        payload = {
            'operator': 'OR',
            'conditions': [
                {'field': 'study.exam_source', 'operator': 'equals', 'value': 'CT'},
                {'field': 'study.exam_source', 'operator': 'equals', 'value': 'MRI'}
            ]
        }
        
        builder = AdvancedQueryBuilder(payload)
        result = builder.build()
        
        reports = Report.objects.filter(result.filters)
        self.assertGreaterEqual(reports.count(), 1)
```

### 4.2. Integration Tests

```python
def test_api_study_field_search(self):
    """Test /reports/search/advanced with Study fields."""
    response = self.client.post('/api/v1/reports/search/advanced', {
        'mode': 'multi',
        'tree': {
            'operator': 'AND',
            'conditions': [
                {'field': 'study.patient_name', 'operator': 'contains', 'value': '張'},
                {'field': 'study.patient_age', 'operator': 'gte', 'value': 18}
            ]
        },
        'page': 1,
        'page_size': 20
    }, content_type='application/json')
    
    self.assertEqual(response.status_code, 200)
    data = response.json()
    self.assertIn('items', data)
    self.assertIn('total', data)
```

### 4.3. Performance Tests

```python
@pytest.mark.performance
def test_study_field_query_performance(self):
    """Ensure Study field queries complete within acceptable time."""
    import time
    
    # Create 1000 Study + Report records
    for i in range(1000):
        study = Study.objects.create(
            exam_id=f'EXAM{i:04d}',
            patient_age=random.randint(18, 90),
            exam_source=random.choice(['CT', 'MRI', 'X-ray'])
        )
        Report.objects.create(
            uid=f'REP{i:04d}',
            report_id=study.exam_id,
            title=f'Report {i}',
            is_latest=True
        )
    
    payload = {
        'operator': 'AND',
        'conditions': [
            {'field': 'study.patient_age', 'operator': 'between', 'value': {'start': 30, 'end': 70}},
            {'field': 'study.exam_source', 'operator': 'in', 'value': ['CT', 'MRI']}
        ]
    }
    
    start = time.time()
    builder = AdvancedQueryBuilder(payload)
    result = builder.build()
    reports = list(Report.objects.filter(result.filters)[:20])
    elapsed = time.time() - start
    
    assert elapsed < 0.5, f'Query took {elapsed:.2f}s, expected < 0.5s'
```

---

## 5. SR/SD Traceability

### System Requirements (SR)

| SR ID | Description | Implementation |
|-------|-------------|----------------|
| **BE-SR-110** | Backend MUST support querying Study fields in Report search | `AdvancedQueryBuilder._build_study_condition()` |
| **BE-SR-111** | Backend MUST use subquery optimization for cross-model filters | `Q(report_id__in=Study.objects.filter(...).values_list())` |
| **BE-SR-112** | Mixed Report+Study queries MUST complete within 500ms (p95, page_size=20) | Index on `Study.exam_id`, `Report.report_id` |
| **FE-SR-110** | Frontend MUST display Study fields grouped separately from Report fields | `FIELD_META` with `group` property |
| **FE-SR-111** | Frontend MUST support dynamic operators based on field type | `OperatorSelector` reads `FIELD_META[field].operators` |

### Software Design (SD)

| SD ID | Description | Component |
|-------|-------------|-----------|
| **BE-SD-110** | `STUDY_FIELD_CONFIG` maps UI keys to DB fields | `report/services/query_builder.py` |
| **BE-SD-111** | `_build_study_condition()` generates subquery Q objects | `report/services/query_builder.py` |
| **FE-SD-110** | `FieldSelector` groups fields by `Report`/`Patient Info`/`Exam Info`/`Time Range` | `components/Search/QueryBuilder.tsx` |
| **FE-SD-111** | `ValueInput` renders type-specific controls (DatePicker, InputNumber, Select) | `components/Search/QueryBuilder.tsx` |

---

## 6. Migration Path

### Phase 1: Backend Foundation
1. Extend `FIELD_CONFIG` with Study fields
2. Implement `_build_study_condition()` method
3. Add unit tests for subquery logic

### Phase 2: Frontend UI
1. Update `FIELD_META` with Study field definitions
2. Implement grouped `FieldSelector` component
3. Update `ValueInput` for datetime/number inputs

### Phase 3: Integration & Testing
1. Integration tests for mixed Report+Study queries
2. Performance benchmarks on realistic dataset (10K+ reports)
3. User acceptance testing

### Phase 4: Monitoring & Optimization
1. Add slow query logging for Study subqueries
2. Monitor `Report.report_id` cardinality and index health
3. Collect user feedback on field selection UX

---

## 7. Future Enhancements

### 7.1. Bidirectional Search
- Support Report fields in Study search
- Unified "Medical Records Search" combining both models

### 7.2. Additional Models
- Support `AIAnnotation` fields (e.g., "Reports with AI-detected anomalies")
- Support `Project` fields (e.g., "Reports in Project X")

### 7.3. Performance Optimization
- Materialized view: `report_study_flat` combining key fields
- Redis cache for frequent Study filter combinations

---

## 8. Appendix

### 8.1. SQL Query Examples

#### Simple Study Field Query
```sql
-- Input: { field: 'study.patient_age', operator: 'gte', value: 60 }
-- Generated Django ORM:
SELECT * FROM one_page_text_report_v2
WHERE report_id IN (
  SELECT exam_id FROM medical_examinations_fact
  WHERE patient_age >= 60
)
AND is_latest = TRUE
LIMIT 20 OFFSET 0
```

#### Mixed Report + Study Query
```sql
-- Input: title contains "MRI" AND study.exam_source = "MRI" AND study.patient_age >= 60
SELECT * FROM one_page_text_report_v2
WHERE title ILIKE '%MRI%'
  AND report_id IN (
    SELECT exam_id FROM medical_examinations_fact
    WHERE exam_source = 'MRI' AND patient_age >= 60
  )
  AND is_latest = TRUE
```

### 8.2. Index Analysis

```sql
-- Required indexes for optimal performance
CREATE INDEX idx_study_exam_id ON medical_examinations_fact(exam_id); -- PK, already exists
CREATE INDEX idx_study_patient_age ON medical_examinations_fact(patient_age);
CREATE INDEX idx_study_exam_source ON medical_examinations_fact(exam_source);
CREATE INDEX idx_study_order_datetime ON medical_examinations_fact(order_datetime);
CREATE INDEX idx_report_report_id ON one_page_text_report_v2(report_id); -- Already exists

-- Check index usage
EXPLAIN ANALYZE
SELECT exam_id FROM medical_examinations_fact
WHERE patient_age >= 60 AND exam_source = 'MRI';
```

