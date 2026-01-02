# Spec Delta: Advanced Report Search

## Purpose
Enhance report search with PostgreSQL full-text search capabilities and a structured query interface.

## ADDED Requirements

### Requirement: SR-SEARCH-001 Full-Text Search Performance
The search functionality MUST use PostgreSQL `tsvector` and GIN index for content fields (`title`, `content_processed`) to improve performance.

- **Old**: Search uses `icontains` on text fields.
- **Rationale**: Improve performance and scalability.

#### Scenario: Full-text match
- Given a report with content "patient has severe headache"
- When I search for "severe & headache" using advanced search
- Then I should see the report in results
- And the query should use the search index


### Requirement: SR-SEARCH-002 Boolean Logic Queries
The system MUST support AND, OR, NOT operators between search conditions to enable complex filtering.

- **Rationale**: Enable complex filtering (e.g. specific modality AND specific finding).

#### Scenario: Complex filter
- When I search for `(Type="CT" OR Type="MRI") AND (Content="tumor")`
- Then I should only see CT or MRI reports containing "tumor"

### Requirement: SR-SEARCH-003 Advanced Search UI
The system MUST provide a visual query builder component for constructing boolean queries.

- **Rationale**: JSON syntax is too complex for end-users.

#### Scenario: Building a query
- Given I am on the search page
- When I toggle the `Multi-condition Advanced Search` tag beside the search bar
- Then I should see a query builder inline that allows me to add rules and groups without opening a modal

### Requirement: SR-SEARCH-004 Mode Tags
The search workspace MUST display two `Tag.CheckableTag` toggles (`Basic Advanced Search`, `Multi-condition Advanced Search`) beside the existing search input so that users can swap between single-line queries and the JSON-rule builder without altering the surrounding layout.

- **Rationale**: Preserve current workspace space usage while exposing advanced capabilities.

#### Scenario: Swapping modes
- Given the report search workbench is open
- When I click the `Multi-condition Advanced Search` tag
- Then the builder expands directly under the search input without pushing other cards away
- And when I click back on `Basic Advanced Search`
- Then the builder collapses and the simple search form becomes the active mode
