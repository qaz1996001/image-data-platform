# Spec: Report-Study Cross-Model Search

**Capability**: `report-study-search`  
**Version**: 1.0.0  
**Status**: Draft  

---

## MODIFIED Requirements

### Requirement: BE-SR-110
**Title**: Backend MUST support querying Study fields in Report advanced search

The backend advanced search API SHALL accept Study field conditions in the JSON DSL payload and return Reports that match the specified Study criteria.

**Rationale**: Users need to filter reports by patient demographics, exam details, and timing information stored in the Study model without performing separate searches.

#### Scenario: Filter reports by patient age
**Given** the database contains:
- Study with `exam_id="EXAM001"`, `patient_age=65`
- Report with `report_id="EXAM001"`, `title="MRI Report"`

**When** the user searches with payload:
```json
{
  "mode": "multi",
  "tree": {
    "operator": "AND",
    "conditions": [
      { "field": "study.patient_age", "operator": "gte", "value": 60 }
    ]
  }
}
```

**Then** the API MUST return the report with `report_id="EXAM001"` in the results.

---

### Requirement: BE-SR-111
**Title**: Backend MUST use subquery optimization for cross-model filters

The backend SHALL implement Study field filters using database subqueries (`Q(report_id__in=...)`) rather than application-layer joins to maintain performance.

**Rationale**: Application-layer filtering would require loading all reports into memory, causing poor performance and incorrect pagination.

#### Scenario: Subquery generates correct SQL
**Given** a query with Study field `exam_source = "MRI"`

**When** the backend builds the Django ORM query

**Then** the generated SQL MUST use a subquery pattern:
```sql
SELECT * FROM one_page_text_report_v2
WHERE report_id IN (
  SELECT exam_id FROM medical_examinations_fact WHERE exam_source = 'MRI'
)
```

---

### Requirement: BE-SR-112
**Title**: Mixed Report+Study queries MUST complete within 500ms at p95

The backend SHALL ensure that queries combining Report and Study field filters complete within 500ms for the 95th percentile when fetching 20 results.

**Rationale**: Users expect fast search results; slow queries degrade user experience and may cause timeouts.

#### Scenario: Performance benchmark with mixed conditions
**Given** a database with 10,000 Reports and 10,000 Studies

**When** executing a query with:
- Report field: `title contains "MRI"`
- Study field: `patient_age >= 60`
- Pagination: `page_size=20`

**Then** the query MUST complete in less than 500ms for 95% of executions.

---

### Requirement: BE-SR-113
**Title**: Backend MUST validate Study field keys and operators

The backend SHALL reject queries with invalid Study field names or unsupported operators, returning a 400 error with a descriptive message.

**Rationale**: Invalid queries should fail fast with clear errors rather than causing database errors or incorrect results.

#### Scenario: Invalid Study field name
**Given** a query with `field: "study.invalid_field"`

**When** the backend validates the query

**Then** it MUST return HTTP 400 with message: `"Unsupported field: study.invalid_field"`

#### Scenario: Unsupported operator for field type
**Given** a query with `field: "study.patient_age"`, `operator: "contains"`

**When** the backend validates the query

**Then** it MUST return HTTP 400 with message: `"Operator 'contains' is not allowed for field 'study.patient_age'. Allowed: gte, lte, between"`

---

### Requirement: FE-SR-110
**Title**: Frontend MUST display Study fields grouped separately from Report fields

The field selector dropdown SHALL organize fields into logical groups (Report, Patient Info, Exam Info, Time Range) using `<Select.OptGroup>` components.

**Rationale**: Grouping improves discoverability and reduces cognitive load when selecting from 20+ available fields.

#### Scenario: Field selector shows grouped options
**Given** the QueryBuilder is rendered

**When** the user opens the field selector dropdown

**Then** the dropdown MUST show:
- OptGroup "Report" with fields: title, report_type, content, etc.
- OptGroup "Patient Info" with fields: study.patient_name, study.patient_age, study.patient_gender
- OptGroup "Exam Info" with fields: study.exam_source, study.exam_item, study.exam_status
- OptGroup "Time Range" with fields: study.order_datetime, study.check_in_datetime

---

### Requirement: FE-SR-111
**Title**: Frontend MUST render type-specific value inputs for Study fields

The value input component SHALL render appropriate controls based on field type:
- `datetime` → `<DatePicker>` or `<DatePicker.RangePicker>`
- `number` → `<InputNumber>` or range inputs
- `select` → `<Select>` with single/multiple mode

**Rationale**: Type-specific inputs prevent invalid input and improve usability (e.g., date picker for dates vs. free text).

#### Scenario: Date field renders DatePicker
**Given** the user selects field `study.order_datetime`

**When** the operator is `"gte"`

**Then** the value input MUST render `<DatePicker showTime format="YYYY-MM-DD HH:mm" />`

#### Scenario: Age field renders InputNumber
**Given** the user selects field `study.patient_age`

**When** the operator is `"gte"`

**Then** the value input MUST render `<InputNumber placeholder="例如：60" />`

#### Scenario: Between operator renders range inputs
**Given** the user selects field `study.patient_age` with operator `"between"`

**When** rendering the value input

**Then** it MUST render two `<InputNumber />` components for min and max values

---

### Requirement: FE-SR-112
**Title**: Frontend MUST restrict operators based on field type

The operator selector SHALL only display operators allowed for the selected field's type (as defined in `FIELD_META[field].operators`).

**Rationale**: Prevents user confusion and invalid queries by hiding inapplicable operators.

#### Scenario: Text field shows text operators only
**Given** the user selects field `study.patient_name` (type: text)

**When** the operator dropdown is opened

**Then** it MUST show only: "包含", "等於", "開頭為", "結尾為"

**And** it MUST NOT show: "大於等於", "介於"

#### Scenario: Number field shows range operators only
**Given** the user selects field `study.patient_age` (type: number)

**When** the operator dropdown is opened

**Then** it MUST show only: "大於等於", "小於等於", "介於"

**And** it MUST NOT show: "包含", "開頭為"

---

### Requirement: BE-SR-101
**Title**: Backend MUST expose API for structured boolean queries including cross-model fields

The backend advanced search API SHALL accept conditions for both Report and Study model fields in the same query tree, allowing users to construct filters that span multiple related models.

#### Scenario: Mixed Report and Study conditions
**Given** the database contains matching data

**When** the user sends:
```json
{
  "mode": "multi",
  "tree": {
    "operator": "AND",
    "conditions": [
      { "field": "title", "operator": "contains", "value": "MRI" },
      { "field": "study.exam_source", "operator": "equals", "value": "MRI" },
      { "field": "study.patient_age", "operator": "gte", "value": 60 }
    ]
  }
}
```

**Then** the API MUST return reports matching all three conditions (Report.title AND Study.exam_source AND Study.patient_age).

---

### Requirement: FE-SR-100
**Title**: Frontend MUST provide UI to build nested AND/OR queries with cross-model fields

The QueryBuilder component SHALL support adding conditions for both Report and Study fields within the same nested boolean structure, enabling users to construct complex multi-model queries through the visual interface.

#### Scenario: Nested query with mixed field types
**Given** the QueryBuilder is open

**When** the user builds:
- Group A (AND):
  - Report.title contains "MRI"
  - Study.exam_source equals "MRI"
- OR
- Group B (AND):
  - Report.report_type equals "CT"
  - Study.patient_age >= 70

**Then** the UI MUST allow saving this structure and generate the correct JSON DSL payload.

---

## Traceability

### Backend Requirements
| SR ID | Implements | Related SD |
|-------|-----------|------------|
| BE-SR-110 | Study field query support | BE-SD-110, BE-SD-111 |
| BE-SR-111 | Subquery optimization | BE-SD-111 |
| BE-SR-112 | Performance target (500ms p95) | BE-SD-111, Database indexes |
| BE-SR-113 | Field/operator validation | BE-SD-110 |

### Frontend Requirements
| SR ID | Implements | Related SD |
|-------|-----------|------------|
| FE-SR-110 | Grouped field selector | FE-SD-110 |
| FE-SR-111 | Type-specific value inputs | FE-SD-111 |
| FE-SR-112 | Dynamic operator filtering | FE-SD-111 |

### Modified Requirements
| SR ID | Change Type | Related Change |
|-------|-------------|----------------|
| BE-SR-101 | Extended | `implement-advanced-report-search` |
| FE-SR-100 | Extended | `implement-advanced-report-search` |

