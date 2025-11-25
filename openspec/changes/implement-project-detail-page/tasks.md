# Tasks: Implement Project Detail Page

## 1. Foundation & Layout
- [x] Create `ProjectDetailLayout` component using `ListWorkbench` structure (Header + Tabs/Content). <!-- id: layout-scaffold -->
- [x] Refactor existing `ProjectDetail` logic (Edit, Archive, Delete) into `ProjectDetailHeader`. <!-- id: refactor-header -->
- [x] Define routes/tabs for `projects/:id/studies` (default) and `projects/:id/reports`. <!-- id: define-routes -->
- [x] Implement `useProjectResourceTabs` hook to manage tab configuration (extensibility point). <!-- id: tab-registry -->

## 2. Study List Capability
- [x] Implement `ProjectStudyListViewProvider` to wrap `StudyList` with project-scoped fetcher. <!-- id: study-list-provider -->
- [x] Create `ProjectStudyList` component using `FilterCard` and `ResultsCard`. <!-- id: study-list-ui -->
- [ ] Verify "Study List" behaves like the main Study Search but filtered by Project. <!-- id: verify-study-list -->

## 3. Report List Capability
- [x] Implement `ProjectReportListViewProvider` to wrap `ReportList` with project-scoped fetcher. <!-- id: report-list-provider -->
- [x] Create `ProjectReportList` component using `FilterCard` and `ResultsCard`. <!-- id: report-list-ui -->
- [ ] Verify "Report List" allows viewing/searching reports associated with project studies. <!-- id: verify-report-list -->

## 4. Integration & Validation
- [x] Update `ProjectCard` navigation to point to the new detail page structure. <!-- id: update-nav -->
- [ ] Validate layout consistency with "Projects" page. <!-- id: validate-layout -->
- [ ] E2E Test for Project Detail navigation, tab switching, and list filtering. <!-- id: e2e-test -->
