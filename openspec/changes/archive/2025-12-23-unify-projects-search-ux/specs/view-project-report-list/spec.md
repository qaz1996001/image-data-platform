# Spec Delta: Unify Projects Search UX - Project Report List

## Purpose
Add consistent search and filter functionality to the Project Report List page, matching the UX pattern used in ProjectResourceWorkbench.

## MODIFIED Requirements

### Requirement: Project Report List View
The Project Detail page MUST display a list of reports assigned to (or associated with studies in) the project.

**Updated behavior**: The `FilterCard` SHALL include a `SearchInput` component that allows users to search reports by text query (e.g., report title, report ID, exam ID, content). The search input SHALL use debounced input (300ms default) and SHALL update the query state immediately when the user types. The search functionality SHALL be consistent with the `ProjectResourceWorkbench` page.

#### Scenario: User views reports in a project
**Given** the user is on the Project Detail page

**When** the "Reports" tab is selected

**Then** a `FilterCard` SHALL be displayed with:
- A `SearchInput` component for text-based search
- A clear/reset button to clear all search conditions
- The search input SHALL be debounced (300ms) to avoid excessive API calls

**And** a `ResultsCard` SHALL be displayed showing the list of reports

**And** the layout SHALL be consistent with the "Projects" page

**And** the search UX SHALL match the `ProjectResourceWorkbench` page pattern

---

## ADDED Requirements

### Requirement: Project Report List Search Functionality
The Project Report List page SHALL support text-based search that queries report attributes such as report title, report ID, exam ID, and report content.

**Rationale**: Users need to quickly find specific reports within a project, especially when projects contain many reports.

#### Scenario: Searching reports by text
**Given** the user is on the Project Report List page

**When** the user types "CT" in the search input

**Then** the search query SHALL be debounced (300ms delay)

**And** after the debounce delay, the API SHALL be called with the search parameter

**And** the results table SHALL display only reports matching "CT" (e.g., report title or content contains "CT")

**And** the total count in the ResultsCard SHALL update to reflect the filtered results

#### Scenario: Clearing search
**Given** the user has entered a search query "MRI"

**When** the user clicks the clear button (or clears the input)

**Then** the search query SHALL be reset to empty

**And** the API SHALL be called without search parameters

**And** all reports in the project SHALL be displayed

---

### Requirement: Project Report List Search State Management
The Project Report List page SHALL maintain search state in the query parameters, allowing users to bookmark or share search configurations.

**Rationale**: Users may want to save search configurations for later use or share them with colleagues.

#### Scenario: Preserving search state
**Given** the user has entered a search query "tumor"

**When** the user refreshes the page or navigates away and returns

**Then** the search input SHALL be restored with the value "tumor"

**And** the search results SHALL be automatically fetched with the restored query

**Note**: This requirement can be implemented using URL query parameters or localStorage based on technical feasibility.

---

## RENAMED Requirements
None

---

## REMOVED Requirements
None

