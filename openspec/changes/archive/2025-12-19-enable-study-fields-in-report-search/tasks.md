# Tasks: Enable Study Fields in Report Search

## Phase 1: Backend Foundation

### Task 1.1: Extend Field Configuration
- [x] Add `STUDY_FIELD_CONFIG` dictionary to `AdvancedQueryBuilder`
- [x] Define mappings for 10 key Study fields:
  - Patient info: `patient_name`, `patient_age`, `patient_gender`
  - Exam info: `exam_source`, `exam_item`, `exam_status`, `equipment_type`
  - Time: `order_datetime`, `check_in_datetime`, `report_certification_datetime`
- [x] Merge `STUDY_FIELD_CONFIG` into main `FIELD_CONFIG`
- [x] Verify no key conflicts with existing Report fields

**Acceptance**: `FIELD_CONFIG` contains all Study fields with correct operators

---

### Task 1.2: Implement Subquery Builder
- [x] Create `_build_study_condition(field_key, operator, value)` method
- [x] Import `Study` model from `study.models`
- [x] Implement logic:
  - Parse `field_key` to extract `db_field` from config
  - Build Django `Q` object for Study filter
  - Execute `Study.objects.filter(Q).values_list('exam_id', flat=True)`
  - Return `Q(report_id__in=subquery)`
- [x] Handle all operator types: TEXT, LIST, RANGE

**Acceptance**: Method returns correct `Q` object for Study field conditions

---

### Task 1.3: Integrate into Main Builder
- [x] Modify `_build_condition()` to detect `study.*` field prefix
- [x] Route Study fields to `_build_study_condition()`
- [x] Ensure Report fields continue to use existing logic
- [x] Test combined Report + Study conditions with AND/OR logic

**Acceptance**: Mixed queries return correct results without errors

---

### Task 1.4: Add Unit Tests
- [x] Create `backend_django/report/tests/test_study_field_queries.py`
- [x] Test single Study field filter (e.g., `patient_age >= 60`)
- [x] Test multiple Study field filters with AND logic
- [x] Test Study field with OR logic
- [x] Test mixed Report + Study filters
- [x] Test nested groups with Study fields
- [x] Test invalid Study field names (expect validation error)
- [x] Test unsupported operators (expect validation error)

**Acceptance**: All unit tests pass, coverage >= 90% for new code

---

## Phase 2: Frontend UI

### Task 2.1: Define Field Metadata
- [x] Update `FIELD_META` in `QueryBuilder.tsx` with 10 Study fields
- [x] Set `group` property for each field:
  - `'Patient Info'`: patient_name, patient_age, patient_gender
  - `'Exam Info'`: exam_source, exam_item, exam_status, equipment_type
  - `'Time Range'`: order_datetime, check_in_datetime, report_certification_datetime
- [x] Define `operators` array for each field
- [x] Add `placeholder` and `options` where applicable

**Acceptance**: `FIELD_META` contains complete metadata for all Study fields

---

### Task 2.2: Implement Grouped Field Selector
- [x] Create `FieldSelector` component (or enhance existing)
- [x] Group fields by `meta.group` property
- [x] Render `<Select.OptGroup>` for each group
- [x] Order groups: Report → Patient Info → Exam Info → Time Range
- [x] Test dropdown renders correctly with all groups visible

**Acceptance**: Field selector displays grouped options correctly

---

### Task 2.3: Enhance Operator Selector
- [x] Modify `OperatorSelector` to read allowed operators from `FIELD_META[field].operators`
- [x] Add Chinese labels for all operators:
  - `contains`: "包含"
  - `gte`: "大於等於"
  - `between`: "介於"
  - etc.
- [x] Disable unavailable operators for current field

**Acceptance**: Operator dropdown shows only valid options for selected field

---

### Task 2.4: Implement Type-Specific Value Inputs
- [x] Create/enhance `ValueInput` component
- [x] Support `type: 'datetime'`:
  - Single value: `<DatePicker showTime />`
  - `between` operator: `<DatePicker.RangePicker showTime />`
- [x] Support `type: 'number'`:
  - Single value: `<InputNumber />`
  - `between` operator: Two `<InputNumber />` (min/max)
- [x] Support `type: 'select'`:
  - Single value: `<Select />`
  - `in` operator: `<Select mode="multiple" />`
- [x] Support `type: 'text'`: `<Input />` (existing)

**Acceptance**: Value input renders correct component for each field type

---

### Task 2.5: Update Type Definitions
- [x] Add Study field keys to `AdvancedSearchFieldKey` union type
- [x] Ensure `AdvancedSearchConditionNode` type supports Study fields
- [x] Update any type guards or validators

**Acceptance**: TypeScript compilation succeeds without type errors

---

## Phase 3: Integration & Testing

### Task 3.1: Integration Tests
- [x] Create test fixtures: 100 Study + Report records
- [x] Test API endpoint with Study field query:
  ```json
  POST /api/v1/reports/search/advanced
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
- [x] Verify response format unchanged (backward compatible)
- [x] Test mixed Report + Study query
- [x] Test pagination with Study filters

**Acceptance**: All integration tests pass

---

### Task 3.2: Performance Testing
- [x] Create dataset: 10,000 Study + 10,000 Report records
- [x] Benchmark Study field queries:
  - Single Study condition: Target <300ms (p95)
  - Mixed Report + Study: Target <500ms (p95)
  - Complex nested (3 levels, 10 conditions): Target <800ms (p95)
- [x] Profile SQL queries with `EXPLAIN ANALYZE`
- [x] Verify index usage on `Study.exam_id`, `Report.report_id`

**Acceptance**: All queries meet performance targets

---

### Task 3.3: End-to-End Testing
- [x] Manual test: Build query with Study fields in UI
- [x] Verify JSON payload sent to backend is correct
- [x] Verify results displayed correctly in list
- [x] Test edge cases:
  - No matching reports
  - Study exists but no report
  - Report exists but no study (orphaned)
- [x] Test error handling (invalid field, unsupported operator)

**Acceptance**: UI → Backend → DB → UI flow works correctly

---

## Phase 4: Documentation & Deployment

### Task 4.1: Update API Documentation
- [x] Add Study field examples to `docs/API_DOCUMENTATION.md`
- [x] Document supported Study fields and operators
- [x] Add example payloads for common use cases

**Acceptance**: API docs include Study field search examples

---

### Task 4.2: Add User Guide
- [x] Create `docs/USER_GUIDE_ADVANCED_SEARCH.md`
- [x] Include screenshots of grouped field selector
- [x] Explain how to combine Report + Study filters
- [x] Provide real-world examples:
  - "60歲以上女性患者的MRI腦部檢查報告"
  - "去年完成的CT檢查但報告未認證"

**Acceptance**: User guide published and reviewed

---

### Task 4.3: Monitoring Setup
- [x] Add logging for Study subquery execution time
- [x] Set up alert if p95 latency > 800ms
- [x] Track Study field usage in analytics

**Acceptance**: Monitoring dashboard shows Study field query metrics

---

### Task 4.4: Deployment
- [x] Review all code changes (Linus checklist)
- [x] Run full test suite (unit + integration + e2e)
- [x] Deploy to staging environment
- [x] Smoke test on staging
- [x] Deploy to production
- [x] Monitor error rates and latency for 24h

**Acceptance**: Production deployment successful, no regressions

---

## Validation Criteria

### Functional
- [x] All 10 Study fields supported in UI and backend
- [x] Mixed Report + Study queries return correct results
- [x] Existing Report-only queries still work (backward compatible)
- [x] Error messages clear when invalid field/operator used

### Performance
- [x] Single Study field query: p95 < 300ms
- [x] Mixed Report + Study query: p95 < 500ms
- [x] No N+1 query issues (verified in logs)

### UX
- [x] Field selector groups clearly labeled
- [x] Operator dropdown shows only valid options
- [x] Value input component matches field type (date picker for dates, etc.)
- [x] No console errors or warnings

### Code Quality
- [x] No indentation > 3 levels (Linus rule)
- [x] No functions > 20 lines without clear reason
- [x] All new code has unit tests (coverage >= 90%)
- [x] Type safety maintained (no `any` types added)

