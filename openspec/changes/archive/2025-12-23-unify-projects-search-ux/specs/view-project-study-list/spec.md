# Spec Delta: Unify Projects Search UX - Project Study List

## Purpose
Add consistent search and filter functionality to the Project Study List page, matching the UX pattern used in ProjectResourceWorkbench.

## MODIFIED Requirements

### Requirement: Project Study List View
The Project Detail page MUST display a list of studies assigned to the project using the standard List Workbench layout.

**Updated behavior**: The `FilterCard` SHALL include a `SearchInput` component that allows users to search studies by text query (e.g., patient name, exam ID, accession number). The search input SHALL use debounced input (300ms default) and SHALL update the query state immediately when the user types. The search functionality SHALL be consistent with the `ProjectResourceWorkbench` page.

#### Scenario: User views studies in a project
**Given** the user is on the Project Detail page

**When** the "Studies" tab is active

**Then** a `FilterCard` SHALL be displayed with:
- A `SearchInput` component for text-based search
- A clear/reset button to clear all search conditions
- The search input SHALL be debounced (300ms) to avoid excessive API calls

**And** a `ResultsCard` SHALL be displayed showing the list of assigned studies in a Table format

**And** the Table SHALL support pagination and sorting

**And** the layout SHALL be consistent with the "Projects" page (using `ListWorkbench` components)

**And** the search UX SHALL match the `ProjectResourceWorkbench` page pattern

---

## ADDED Requirements

### Requirement: Project Study List Search Functionality
The Project Study List page SHALL support text-based search that queries study attributes such as patient name, exam ID, accession number, and exam description.

**Rationale**: Users need to quickly find specific studies within a project, especially when projects contain many studies.

#### Scenario: Searching studies by text
**Given** the user is on the Project Study List page

**When** the user types "張三" in the search input

**Then** the search query SHALL be debounced (300ms delay)

**And** after the debounce delay, the API SHALL be called with the search parameter

**And** the results table SHALL display only studies matching "張三" (e.g., patient name contains "張三")

**And** the total count in the ResultsCard SHALL update to reflect the filtered results

#### Scenario: Clearing search
**Given** the user has entered a search query "張三"

**When** the user clicks the clear button (or clears the input)

**Then** the search query SHALL be reset to empty

**And** the API SHALL be called without search parameters

**And** all studies in the project SHALL be displayed

---

### Requirement: Project Study List Search State Management
The Project Study List page SHALL maintain search state in the query parameters, allowing users to bookmark or share search configurations.

**Rationale**: Users may want to save search configurations for later use or share them with colleagues.

#### Scenario: Preserving search state
**Given** the user has entered a search query "MRI"

**When** the user refreshes the page or navigates away and returns

**Then** the search input SHALL be restored with the value "MRI"

**And** the search results SHALL be automatically fetched with the restored query

**Note**: This requirement can be implemented using URL query parameters or localStorage based on technical feasibility.

---

## RENAMED Requirements
None

---

## REMOVED Requirements
None

