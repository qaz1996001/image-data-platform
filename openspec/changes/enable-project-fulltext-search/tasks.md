# Tasks: Enable Project Full-Text Search

## 1. Discovery & Infra
- [ ] Audit existing Study/Report search indexes + confirm data fields available for FTS. <!-- id: audit-current-search -->
- [ ] Define `ProjectSearchRegistry` interface in `project/services/search_registry.py`. <!-- id: search-registry -->
  - [ ] `register_provider(resource_type, provider_func)`
  - [ ] `search(project_id, query) -> List[SearchResult]`

## 2. Backend Search API & Providers
- [ ] Add Study search provider. <!-- id: study-search-provider -->
  - [ ] Add `search_vector` (TSVectorField) to `Study` model in `study/models.py`.
  - [ ] Create migration to populate vectors.
  - [ ] Implement provider function to query vector and extract snippets.
- [ ] Add Report search provider. <!-- id: report-search-provider -->
  - [ ] Reuse `report.search_service` but enforce `project_id` filter.
  - [ ] Ensure snippet extraction matches Study provider format.
- [ ] Implement `/projects/{id}/search` Ninja route in `project/api.py`. <!-- id: project-search-endpoint -->
  - [ ] Integrate `ProjectSearchRegistry`.
  - [ ] Handle pagination and RBAC.
- [ ] Add unit tests for search providers and registry in `project/tests/test_search.py`. <!-- id: backend-tests -->

## 3. Frontend Integration
- [ ] Create `SearchInput` component in `frontend/src/pages/Projects/Detail/SearchInput.tsx`. <!-- id: search-input-ui -->
  - [ ] Implement 300ms debounce (FE-SR-010).
- [ ] Update `ProjectResourceListViewProvider` to handle `q` query param. <!-- id: list-provider-search -->
  - [ ] Call `/projects/{id}/search` when `q` is present.
- [ ] Update `ResultsCard` to render highlight snippets. <!-- id: results-snippet-ui -->
  - [ ] Use `dangerouslySetInnerHTML` (sanitized) or parsing for `<mark>` tags.
  - [ ] Show "Full-text search" badge in StatusBar.
- [ ] Ensure selection + batch actions work on search results. <!-- id: selection-integration -->

## 4. Validation
- [ ] Add Cypress/Playwright test for search flow in `frontend/e2e/project-search.spec.ts`. <!-- id: e2e-search -->
  - [ ] Verify search results, highlighting, and selection persistence.
- [ ] Run `openspec validate enable-project-fulltext-search --strict`. <!-- id: validate-spec -->
