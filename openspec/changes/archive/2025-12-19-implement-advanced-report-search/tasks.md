# Tasks: Implement Advanced Report Search

## 1. Backend: Full-Text Search Infrastructure
- [x] Define `AdvancedSearchRequest` schema in `report/schemas.py`. <!-- id: backend-search-schema -->
- [x] Create `search_vector` update signal in `report/signals.py`. <!-- id: backend-search-signal -->
  - [x] Hook into `post_save` of `Report`.
  - [x] Update `search_vector` using `SearchVector('title', 'content_processed', ...)`.
- [x] Create data migration to populate `search_vector` for existing records. <!-- id: backend-populate-vector -->

## 2. Backend: Advanced Search API
- [x] Implement `AdvancedQueryBuilder` utility in `report/services/query_builder.py`. <!-- id: backend-query-builder -->
  - [x] Parse JSON DSL to Django `Q` objects and `SearchQuery`.
- [x] Implement `POST /reports/search/advanced` in `report/api.py`. <!-- id: backend-search-endpoint -->
- [x] Add unit tests for complex queries in `report/tests/test_advanced_search.py`. <!-- id: backend-tests -->

## 3. Frontend: Advanced Search UI
- [x] Create `QueryBuilder` component in `frontend/src/components/Search/QueryBuilder.tsx`. <!-- id: frontend-query-builder -->
  - [x] Support recursive groups and field/operator selection.
- [x] Integrate `QueryBuilder` into `ReportList` inline using `Tag.CheckableTag` toggles (Basic vs Multi) without altering the existing card layout. <!-- id: frontend-integration -->
- [x] Connect to `advancedSearchReports` API service. <!-- id: frontend-api-connect -->

## 4. Validation
- [x] Verify GIN index usage with `EXPLAIN ANALYZE` on large datasets. <!-- id: perf-validation -->
- [x] Validate boolean logic correctness with test cases. <!-- id: logic-validation -->

