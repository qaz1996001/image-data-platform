# Spec: Project Resource Results Actions Parity

## ADDED Requirements

### Requirement: Project resource lists SHALL reuse canonical ResultsCard actions
Project-scoped Study/Report lists MUST display the same `ResultsCard.actions` controls (column manager + selection drawer trigger + meta badges) defined for Study Search and Report Search.

#### Scenario: User views Project Studies
- Given the user is inside a Project Detail resource list with resource type = `studies`
- When the ResultsCard renders
- Then the actions slot SHALL contain the Column Manager icon button and the Selection Drawer trigger identical to Study Search (including the selected count badge).
- And opening the drawer SHALL show the same action group (`Remove from Project`, `Export`, future batch actions) wired to the project context with disabled states when not applicable.

#### Scenario: User views Project Reports
- Given the user views the Project resource list filtered to `reports`
- Then the ResultsCard actions MUST match the Report Search list (Column Manager + Selection Drawer trigger only).
- And the Selection Drawer SHALL expose the same batch action registry (export, print, archive, delete) but scoped to the current project; unavailable actions SHALL appear disabled with tooltips.

### Requirement: Project resource selection SHALL sync with ListViewStore
Project resource tables MUST reuse the shared `ListViewStore` selection state so the Column Manager + drawer reflect the same selection set across Studies and Reports.

#### Scenario: User toggles selection inside Project resources
- Given the user selects rows in the Project resource table
- When they open the Selection Drawer
- Then the drawer SHALL display the exact selected count and row metadata, matching the Study/Report main pages.
- And clearing the selection from the drawer MUST clear the underlying `ListViewStore` state so the table checkboxes reset immediately.

