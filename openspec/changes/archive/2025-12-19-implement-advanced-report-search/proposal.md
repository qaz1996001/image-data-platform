# Proposal: Implement Advanced Report Search

## 1. Background & Problem
Current report search relies on `icontains` across multiple fields, which is performance-intensive (no index usage for leading wildcards) and limited to simple text matching. The database table `one_page_text_report_v2` already includes a `search_vector` (tsvector) column and GIN index, but the application logic does not utilize it.

Additionally, users need to perform complex queries involving multiple conditions with boolean logic (AND/OR), which the current single-string search cannot support.

## 2. Goals
1.  **Performance**: Migrate full-text search to use PostgreSQL `tsvector` and GIN indexes.
2.  **Capabilities**: Enable complex boolean queries (AND/OR groups, specific field constraints).
3.  **Usability**: Provide a user-friendly "Query Builder" UI for constructing complex searches.

## 3. Scope
- **Backend**:
    - Implement `SearchVector` updating mechanism (Signals/Triggers).
    - Refactor `ReportService` to use `django.contrib.postgres.search`.
    - Design and implement Advanced Search API (JSON-based query DSL).
- **Frontend**:
    - Design and implement `AdvancedSearchBuilder` UI component.
    - Integrate with new Search API.

## 5. Success Metrics
- Search response time < 200ms for complex text queries.
- Users can successfully construct and execute multi-condition queries (e.g., "Title contains X AND Type is Y OR Content contains Z").

