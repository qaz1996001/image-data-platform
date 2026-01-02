# Spec: Project Full-Text Search UI

## ADDED Requirements

### Requirement: Project header search input
Project Detail’s ListWorkbench header SHALL include a search input that targets the project-level full-text search endpoint.

#### Scenario: User types a query
- Given the user is viewing a project
- When they type text into the header search input and pause for 400 ms
- Then the UI SHALL debounce the query, update the ListViewStore with `search=<term>`, and call `/projects/{id}/search?q=<term>`.
- Clearing the input SHALL remove `search` from the query and revert to the normal resource list.

### Requirement: Search status indicators
While a full-text search is active, the ResultsCard status bar MUST show a badge `全文搜尋："<term>"` and display loading or empty states specific to search.

#### Scenario: No matches
- Given the backend returns zero items for a term
- Then the ResultsCard SHALL show an empty state titled “未找到符合的資源” and provide a “清除搜尋” button resetting the search input.

### Requirement: Highlight + metadata rendering
Each row returned from search MUST show:
- `resource_type` badge (Study, Report, AI Annotation, Doctor Note)
- `accession_number`
- Highlight snippet text (ellipsis + `<mark>` wrappers) explaining why it matched.

#### Scenario: Report match
- Given a report hit contains “肺炎”
- Then the table SHALL show a snippet column like `…右下葉出現 <mark>肺炎</mark> 病灶…`.

### Requirement: Selection + batch actions compatibility
Search results MUST still support row selection, Selection Drawer actions, and quick navigation to detail modals.

#### Scenario: Batch remove after search
- Given the user searches for “duplicate” and selects two studies
- When they open the Selection Drawer and click “從專案移除”
- Then the action SHALL succeed, refresh the search results, and keep the search term applied until manually cleared.

