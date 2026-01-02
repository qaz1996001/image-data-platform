# Design: Advanced Report Search

## 1. Search Architecture (Backend)

### 1.1. PostgreSQL Full-Text Search
We will leverage the existing `search_vector` column in `Report` model.

*   **Vector Population**:
    *   Use Django `SearchVector` to combine `title`, `content_processed`, `uid`, `report_id`.
    *   Mechanism: Django `post_save` signal (or DB trigger if preferred, but signal is more Pythonic for Django-centric apps) to update `search_vector` on change.
    *   Configuration: Use 'english' config as baseline (or 'simple' if mixed language without dictionaries). Since this is medical text, 'simple' might be safer or specific config if Chinese support is needed (Postgres has limited Chinese support OOTB, usually requires extensions like `zhparser`, but we can stick to simple tokenizer or 'english' if acceptable for now, or assume `jieba` pre-processing in `content_processed`).

### 1.2. Advanced Query DSL
We will define a JSON structure for complex queries.

**Request Schema:**
```json
{
  "operator": "AND",
  "conditions": [
    { "field": "title", "operator": "contains", "value": "MRI" },
    {
      "operator": "OR",
      "conditions": [
        { "field": "report_type", "operator": "equals", "value": "Radiology" },
        { "field": "content", "operator": "search", "value": "fracture" }
      ]
    }
  ]
}
```

**Field Mappings:**
- `content`: Uses `search_vector` (`SearchQuery`).
- `title`, `report_type`, `uid`: Direct field filters or specialized lookups.

**Implementation Notes:**
- No well-maintained Django package currently converts a nested JSON rule-tree into `Q` objects with mixed AND/OR logic. Public libraries such as `django-querybuilder` or `django-rest-framework-filters` either focus on form-based filtering, lack recursive grouping, or have been unmaintained for years, so we will not depend on them.
- Introduce `report.services.advanced_query_builder.AdvancedQueryBuilder` that recursively walks the JSON structure, validates against an allow-list of fields/operators, and produces a composed `Q` expression plus any `SearchQuery`.
- Enforce guardrails (max depth = 5, max conditions = 20) to keep runaway queries from degrading performance. Invalid payloads return `400` with a structured error describing the offending node.

### 1.3. API Design
*   **Endpoint**: `POST /reports/search/advanced`
*   **Input**: `AdvancedSearchRequest` (Pydantic schema matching DSL).
*   **Output**: `PaginatedResponse[ReportResponse]`.

## 2. User Interface (Frontend)

### 2.1. Advanced Search Builder Component
A visual builder allowing users to add rows of conditions.

*   **Structure**: Recursive component rendering rows or groups.
*   **Row**:
    *   Field Select (Title, Content, Type, Date).
    *   Operator Select (Contains, Equals, Full Text, etc.).
    *   Value Input (Text, DatePicker, Select).
*   **Group**:
    *   Logic Toggle (AND/OR).
    *   "Add Condition" / "Add Group" buttons.

### 2.2. Integration
*   Preserve the current workbench layout; no additional drawers or modals that would shrink the list or filters.
*   Place two Ant Design `Tag.CheckableTag` chips beside the existing search input:
    *   `Basic Advanced Search` toggles the simple one-line query (status quo).
    *   `Multi-condition Advanced Search` toggles the recursive builder.
*   When the multi-condition tag is active, render the builder inline beneath the search bar (collapsible) so it reuses current vertical space.
*   Results continue to appear in the existing `ReportList` table; applying either tag simply swaps the query payload sent to the backend.

## 3. SR/SD Traceability

### System Requirements (SR)
*   **BE-SR-100**: Backend MUST support updating `search_vector` automatically.
*   **BE-SR-101**: Backend MUST expose API for structured boolean queries.
*   **BE-SR-102**: Search MUST utilize GIN index for full-text operations.
*   **FE-SR-100**: Frontend MUST provide UI to build nested AND/OR queries.

### Software Design (SD)
*   **BE-SD-100**: `ReportService.advanced_search(query_json)` implementation.
*   **BE-SD-101**: Pydantic Schema `AdvancedSearchQuery`.
*   **FE-SD-100**: `QueryBuilder` React component state management (recursive).

