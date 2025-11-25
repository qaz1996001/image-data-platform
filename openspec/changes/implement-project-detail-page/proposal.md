# Implement Project Detail Page with List Workbench

## Problem
Currently, the Project Detail page is a monolithic component that displays project statistics and a simple table of assigned studies. It lacks the powerful filtering, search, and batch operation capabilities found in the unified "List Workbench" used by Reports, Study Search, and Projects List.
Furthermore, there is a need to integrate diverse resources (Reports, AI Annotations, Doctor Notes) under a project, linked via the `Study` (exam_id), and provide a foundation for full-text search across these resources.

## Solution
Refactor the `ProjectDetail` page to adopt the "List Workbench" pattern and a modular "Resource Tab" architecture.
- **Project Header**: Displays project metadata and context-aware actions. Includes a search entry point for future global search.
- **Tabbed Content**:
  - **Study List**: A fully functional `ListWorkbench` view showing studies assigned to the project.
  - **Report List**: A fully functional `ListWorkbench` view showing reports linked to the project's studies.
  - **Extensible**: Designed to easily add "AI Annotations" or other tabs in the future.
- **Search**: Enable full-text search within each resource tab initially, with architectural support for unified project search later.

## Risks
- **Migration Complexity**: The existing `ProjectDetail.tsx` contains logic for editing/archiving projects that needs to be preserved or moved to the header/actions.
- **Data Fetching**: `projectService` needs to efficiently join `StudyProjectAssignment` with `Report` tables to fetch project-scoped reports.
- **Search Performance**: Full-text search across disparate resources (SQL vs JSON content) will require backend optimization (e.g., specific indexes or a search service).

## PRD/SR Mapping
- **UR-007-DETAIL**: Project Detail View & Resource Management
  - **UR-007-DETAIL-01**: View Project Study List (Extensible)
  - **UR-007-DETAIL-02**: View Project Report List
  - **UR-007-DETAIL-03**: Project Resource Search (Architecture)
