# Spec Delta: Unify Projects Search UX - Project Resource Workbench

## Purpose
Ensure consistent search, filter, and selection UX across the ProjectResourceWorkbench page, matching the patterns used in ReportSearch and other project list pages.

## ADDED Requirements

### Requirement: Project Resource Workbench
The Project Resource Workbench SHALL provide users with a unified interface to search, filter, and manage studies and reports assigned to a project.

**Behavior**: The workbench SHALL use the same UI structure as ReportSearch and other project list pages:
- A `FilterCard` for search and filter conditions
- Support for basic and multi-condition advanced search modes
- A `ResultsCard` displaying the resource list with consistent styling
- A `StatusBar` showing active filters and selection status
- Consistent result action buttons (column settings, selection management, batch actions)
- A "Select all across pages" feature matching ReportSearch implementation

#### Scenario: User accesses project resources
**Given** the user is viewing a project

**When** the user navigates to the Resources tab

**Then** the interface SHALL display:
- A `FilterCard` with search input and filter options
- Mode toggle buttons for "Basic Search" and "Advanced Multi-Condition Search"
- A `ResultsCard` showing the filtered list of resources
- Consistent styling and layout matching the ReportSearch page
- A `StatusBar` showing applied filters and selection count
- Action buttons for column management and selection

#### Scenario: User selects resources
**Given** the user is viewing a list of resources

**When** the user clicks "Select All" button

**Then** all resources on the current page SHALL be selected

**And** the SelectionDrawer SHALL display all selected resources

**And** batch action buttons SHALL become available

#### Scenario: User selects all across pages
**Given** the user has filtered resources and wants to select all matching resources

**When** the user clicks "Select All Across Pages" (shown in ResultsCard summary)

**Then** all resources matching the current filters SHALL be selected (up to UI limit)

**And** the ResultsCard summary SHALL display the total selected count and a "deselect" option

**And** batch actions SHALL be available for the selected resources

### Requirement: Project Resource Workbench Selection Summary
The Project Resource Workbench SHALL display a selection summary in the ResultsCard showing counts and available actions.

**Rationale**: Users need clear feedback on selection state and available batch operations, consistent with ReportSearch.

#### Scenario: Displaying selection summary
**Given** the user has selected some resources

**When** the ResultsCard is rendered

**Then** the summary SHALL display:
- Total resource count
- Applied filter description (if any)
- A "Select All Across Pages" button (or "Deselect All" if already selected)

#### Scenario: No resources selected
**Given** the user has not selected any resources

**When** the ResultsCard is rendered

**Then** the summary SHALL display:
- Total resource count only
- A "Select All Across Pages" button ready to use

---

### Requirement: Project Resource Workbench Batch Actions
The Project Resource Workbench SHALL provide batch action buttons in the selection drawer, consistent with ReportSearch.

**Rationale**: Users need easy access to common bulk operations from the selection interface.

#### Scenario: Executing batch actions
**Given** the user has selected resources

**When** the SelectionDrawer is open

**Then** batch action buttons (if any are available for the selected resources) SHALL be displayed

**And** each button SHALL trigger the corresponding action when clicked

**And** action execution progress SHALL be shown to the user

---

## REMOVED Requirements
None

---

## RENAMED Requirements
None

---

