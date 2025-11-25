# Tasks: Unify Project Resource Workbench

## 1. Results Actions Parity (Foundation)
- [ ] Inventory Study/Report `resultsActions` + Selection Drawer flows to reuse in project context. <!-- id: audit-results-actions -->
- [ ] Ensure `StudyList` and `ReportList` actions are importable/reusable for the unified workbench. <!-- id: reuse-results-actions -->

## 2. Backend Aggregation & Canonical Key
- [ ] Implement `AccessionKeyResolver` service in `project/services/accession_resolver.py`. <!-- id: accession-resolver -->
  - [ ] `resolve_accession(resource_id, resource_type) -> accession_number`
  - [ ] `get_resources_by_accession(accession_number)`
- [ ] Create `GET /projects/{id}/resources` in `project/api.py`. <!-- id: aggregate-endpoint -->
  - [ ] Support `resource_types` list, `q` filter, and pagination.
  - [ ] Return mixed list keyed by `accession_number`.
- [ ] Add unit tests for `AccessionKeyResolver` and aggregation logic in `project/tests/test_resource_aggregation.py`. <!-- id: backend-tests -->

## 3. Unified Resource Workbench (Frontend)
- [ ] Create `ProjectResourceListViewProvider` in `frontend/src/pages/Projects/Detail/ProjectResourceListViewProvider.tsx`. <!-- id: resource-provider -->
  - [ ] Support `resourceTypes[]` in state and query params.
  - [ ] Normalize API response to `ListViewStore` items.
- [ ] Implement `ResourceSelector` component (Chips) for `FilterCard`. <!-- id: resource-selector -->
- [ ] Create `ProjectResourceWorkbench` component in `frontend/src/pages/Projects/Detail/ProjectResourceWorkbench.tsx`. <!-- id: replace-tabs -->
  - [ ] Replace existing Tab routes in `frontend/src/routes.tsx` (or `ProjectDetailLayout`).
- [ ] Update `ResultsCard` usage to handle mixed columns. <!-- id: mixed-results-table -->
  - [ ] Implement column config merger based on active resource types.

## 4. Validation & Cleanup
- [ ] Update `ProjectDetailLayout` to remove old tab navigation once Workbench is stable. <!-- id: remove-tabs -->
- [ ] Add E2E test for Resource switching and Batch Actions in `frontend/e2e/project-resources.spec.ts`. <!-- id: e2e-tests -->
- [ ] Run `openspec validate unify-project-resource-workbench --strict`. <!-- id: validate-spec -->
