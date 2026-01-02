# Spec: Project Full-Text Search Backend

## ADDED Requirements

### Requirement: Project search endpoint
The system SHALL expose `GET /projects/{project_id}/search` that performs full-text search across every resource assigned to the project.

#### Scenario: Valid search request
- Given the caller has `view` permission for the project
- When they call `/projects/{id}/search?q=pneumonia&resource_types=studies,reports`
- Then the API SHALL aggregate matches from the registered resources (studies, reports, AI annotations, doctor notes) scoped to that project only.
- And the response SHALL include pagination metadata (`page`, `page_size`, `total`) plus an array of result items.

### Requirement: Result item schema
Each search result item MUST include:
- `accession_number`
- `resource_type`
- `score` (float normalized 0–1)
- `resource_timestamp`
- `snippet` (HTML-safe highlight)
- `resource` payload inheriting the canonical schema for that resource type.

#### Scenario: Report search hit
- Given a report contains the keyword in its processed content
- Then the result item SHALL set `resource_type = 'report'`, include the report’s `ReportDetailResponse` data, and populate `snippet` with the matching sentence wrapped in `<mark>`.

### Requirement: Resource registry + RBAC
The backend MUST use a registry so each resource search provider (studies, reports, AI annotations, doctor notes) can register its handler, and every handler MUST enforce project-level RBAC before returning matches.

#### Scenario: Unauthorized resource
- Given a provider would normally return 3 report hits
- But the user lacks permission to view reports
- Then the provider SHALL return an empty list, and the aggregated search response SHALL omit those items.

### Requirement: Sorting and pagination
Results MUST default to relevance score ordering (desc). When two items share the same score, `resource_timestamp` SHALL break ties (newest first). Pagination parameters (`page`, `page_size`) SHALL apply after sorting.

#### Scenario: Relevance tie
- Given two study hits scored 0.78
- Then the newer `resource_timestamp` SHALL appear earlier before pagination slices the list.

