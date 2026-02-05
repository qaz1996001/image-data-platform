# Spec: View Project Study List

## ADDED Requirements

### Requirement: Project Study List View
The Project Detail page MUST display a list of studies assigned to the project using the standard List Workbench layout.

#### Scenario: User views studies in a project
- Given the user is on the Project Detail page
- When the "Studies" tab is active (default)
- Then a `FilterCard` SHALL be displayed allowing filtering by study attributes (e.g. date, modality).
- And a `ResultsCard` SHALL be displayed showing the list of assigned studies in a Table format.
- And the Table SHALL support pagination and sorting.
- And the layout SHALL be consistent with the "Projects" page (using `ListWorkbench` components).

### Requirement: Project Study Scoped Fetching
The list MUST only show studies that belong to the current `project_id`.

#### Scenario: Fetching project studies
- The `ListViewProvider` for this page MUST use `projectService.getStudies(projectId, ...)` (or equivalent) as its fetcher.
- The `total` count in the `ResultsCard` header MUST reflect the number of studies in this project.

### Requirement: Study Actions in Project Context
Users SHALL be able to perform actions on studies within the project context.

#### Scenario: Removing studies from project
- The `ResultsCard` SHALL support selection of studies.
- The Selection Drawer SHALL provide an action to "Remove from Project".
- Removing a study SHALL refresh the list and update the total count.

### Requirement: Study as Anchor for Resources
The Study List SHALL serve as the primary entry point for adding new resources to the project.

#### Scenario: Adding a resource indirectly
- Users SHALL understand that adding a "Report" or "AI Annotation" to a project is achieved by adding the corresponding `Study` (exam_id) to the project.
