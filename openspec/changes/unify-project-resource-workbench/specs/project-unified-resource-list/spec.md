# Spec: Project Unified Resource Workbench

## ADDED Requirements

### Requirement: Project Detail SHALL render a single ListWorkbench body
The Project Detail experience MUST remove the Studies/Reports tab structure and instead render one ListWorkbench (FilterCard + ResultsCard) dedicated to the selected project.

#### Scenario: User opens Project Detail
- Given the user navigates to `/projects/:id`
- Then the page SHALL display one FilterCard labeled「條件設定」and one ResultsCard labeled「專案資源」
- And there SHALL be no additional tabs or nested routes for studies/reports; deep links use the same route with query params (e.g., `?resources=studies,reports`).

### Requirement: Resource selector controls
Users MUST be able to decide which resource types appear inside the unified list using selector controls (chips/multiselect) located in the FilterCard header.

#### Scenario: User toggles resource chips
- Given the user toggles the「Reports」chip off
- Then the ListViewProvider SHALL refetch with `resourceTypes=['studies']`
- And the ResultsCard SHALL immediately hide report-only columns.
- Re-enabling「Reports」MUST re-fetch and merge report rows without reloading the entire page shell.

### Requirement: Mixed resource row schema
The unified list MUST present each row with:
- `resource_type` badge (Study / Report / AI Annotation)
- `accession_number`
- A resource-specific column set (Study columns such as modality, patient; Report columns such as title, version)
- Shared timestamp column `resource_timestamp`.

#### Scenario: Mixed resource rendering
- Given both studies and reports are selected
- Then the table SHALL interleave rows ordered by `resource_timestamp`
- And column manager presets SHALL allow switching between「Study columns」and「Report columns」per row context without breaking layout.

### Requirement: Batch actions respect resource mix
The Selection Drawer MUST group actions by resource type and disable actions that do not apply to the current selection.

#### Scenario: Mixed selection
- Given the user selects one study row and one report row simultaneously
- Then the Selection Drawer SHALL show two sections (Studies / Reports) each listing applicable batch actions.
- Attempting to run a study-only action when reports are selected SHALL surface a tooltip instructing the user to filter selection.

