# Tasks: Enable Project Full-Text Search

## 1. Discovery & Infra
- [x] Audit existing Study/Report search indexes + confirm data fields available for FTS. <!-- id: audit-current-search -->
- [x] Define `ProjectSearchRegistry` interface in `project/services/search_registry.py`. <!-- id: search-registry -->
  - [x] `register_provider(resource_type, provider_func)`
  - [x] `search(project_id, query) -> List[SearchResult]`

## 2. Backend Search API & Providers
- [x] Add Study search provider. <!-- id: study-search-provider -->
  - [x] Add `search_vector` (TSVectorField) to `Study` model in `study/models.py`.
  - [x] Create migration to populate vectors.
  - [x] Implement provider function to query vector and extract snippets.
- [x] Add Report search provider. <!-- id: report-search-provider -->
  - [x] Reuse `report.search_service` but enforce `project_id` filter.
  - [x] Ensure snippet extraction matches Study provider format.
- [x] Implement `/projects/{id}/search` Ninja route in `project/api.py`. <!-- id: project-search-endpoint -->
  - [x] Integrate `ProjectSearchRegistry`.
  - [x] Handle pagination and RBAC.
- [x] Add unit tests for search providers and registry in `project/tests/test_search.py`. <!-- id: backend-tests -->

## 3. Frontend Integration
- [x] Create `SearchInput` component in `frontend/src/pages/Projects/Detail/SearchInput.tsx`. <!-- id: search-input-ui -->
  - [x] Implement 300ms debounce (FE-SR-010).
- [x] Update `ProjectResourceListViewProvider` to handle `q` query param. <!-- id: list-provider-search -->
  - [x] Call `/projects/{id}/search` when `q` is present.
- [x] Update `ResultsCard` to render highlight snippets. <!-- id: results-snippet-ui -->
  - [x] Use `dangerouslySetInnerHTML` (sanitized) or parsing for `<mark>` tags.
  - [x] Show "Full-text search" badge in StatusBar.
- [x] Ensure selection + batch actions work on search results. <!-- id: selection-integration -->

## 4. Validation
- [x] Add Cypress/Playwright test for search flow in `frontend/e2e/project-search.spec.ts`. <!-- id: e2e-search -->
  - [x] Verify search results, highlighting, and selection persistence.
- [x] Run `openspec validate enable-project-fulltext-search --strict`. <!-- id: validate-spec -->
