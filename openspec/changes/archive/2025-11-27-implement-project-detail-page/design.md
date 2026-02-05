# Design: Project Detail Page Architecture

## Architecture
The Project Detail page will evolve from a simple "Details" view to a "Project Workbench" that acts as a context container for other lists.

### Core Concept: Study as Anchor
The `Study` (identified by `exam_id`) serves as the central anchor for all resources in a project.
- **Integration**: To add any resource (Report, AI Annotation, Doctor Note) to a project, we effectively link its parent `Study` to the project via `StudyProjectAssignment`.
- **Traversal**: Access to resources is derived: `Project` -> `Study` -> `Report/Annotation`.

### Components

1.  **`ProjectDetailLayout`**
    *   **Responsibility**: Fetches `Project` metadata, renders the `ListWorkbench.Header` (customized for Project context), and manages the active Tab (Studies vs Reports).
    *   **Header**: Reuses `ListWorkbench.Header` visual style but displays Project Name, Status Badge, and Project Actions (Edit, Archive).
    *   **Global Search**: The Header should reserve space for a "Project-wide Search" input that can pass query terms to the active tab's filter.
    *   **Navigation**: Tabs or segmented control to switch between "Studies", "Reports", and future "AI Annotations".

2.  **`ProjectStudyList`**
    *   **Context**: Wrapped in `ProjectStudyListViewProvider`.
    *   **Provider**: Uses a specialized `fetcher` that calls `projectService.getStudies(projectId, params)`.
    *   **UI**: Renders `FilterCard` (with project-relevant filters) and `ResultsCard` (Table of studies).
    *   **Actions**: Supports batch actions (Remove from Project) via the Selection Drawer.

3.  **`ProjectReportList`**
    *   **Context**: Wrapped in `ProjectReportListViewProvider`.
    *   **Provider**: Uses a specialized `fetcher` that calls `projectService.getReports(projectId, params)`.
    *   **UI**: Renders `FilterCard` and `ResultsCard` (Table of reports).
    *   **Logic**: Fetches reports where `report_id` matches the project's `exam_ids`.

### Future Extensibility: Resource Registry
To support "gradually adding" resources (e.g., AI Annotations), the page should use a config-driven approach for Tabs:
- **Registry**: A simple map of `{ key: 'ai-annotations', label: 'AI Annotations', component: AIAnnotationList }`.
- **Full Text Search**:
    - **Phase 1 (Current)**: Each Tab (Studies, Reports) implements its own search via `FilterCard`.
    - **Phase 2 (Future)**: A "Unified Project Search" API endpoint will accept a query and return matches from all connected resources (Studies, Reports, Annotations), possibly displayed in a "Search Results" tab or aggregated view.

### URL Structure
- `/projects/:id` -> Redirects to `/projects/:id/studies` (Default)
- `/projects/:id/studies` -> Shows Study List
- `/projects/:id/reports` -> Shows Report List
- `/projects/:id/annotations` -> (Future) Shows AI Annotations

## Trade-offs
- **Deep Linking**: Using sub-routes (`/studies`, `/reports`) allows deep linking to a specific resource tab, which is better than internal state tabs.
- **Performance**: Deriving lists via `exam_id` association requires efficient backend queries (JOINs or pre-aggregated lookups). The backend `project_service` must be optimized to handle large sets of `exam_ids`.
