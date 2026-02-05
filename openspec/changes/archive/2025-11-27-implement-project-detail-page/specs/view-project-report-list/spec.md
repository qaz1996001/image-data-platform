# Spec: View Project Report List

## ADDED Requirements

### Requirement: Project Report List View
The Project Detail page MUST display a list of reports assigned to (or associated with studies in) the project.

#### Scenario: User views reports in a project
- Given the user is on the Project Detail page
- When the "Reports" tab is selected
- Then a `FilterCard` SHALL be displayed allowing filtering of reports.
- And a `ResultsCard` SHALL be displayed showing the list of reports.
- And the layout SHALL be consistent with the "Projects" page.

### Requirement: Project Report Scoped Fetching
The list MUST only show reports linked to the project (either directly or via assigned studies).

#### Scenario: Fetching project reports
- The `ListViewProvider` for this page MUST use `projectService.getReports(projectId, ...)` as its fetcher.
- If direct "Project -> Report" assignment doesn't exist, it SHOULD query reports for all studies assigned to the project. (TBD based on backend capabilities, assuming `getReportsByProject` exists or can be implemented).

#### Scenario: Empty State
- If no reports are found, a standard `Empty` state SHALL be shown within the `ResultsCard`.

