# Enable Project Full-Text Search

## Problem
- Project Detail currently offers filtering per resource (studies/reports) but lacks a single entry point to search all textual fields (patient data, report content, AI annotations, doctor notes) within a project.
- Teams cannot quickly answer questions like “Show every study in this project mentioning pneumonia” or “Find doctor corrections referencing `L3`”, forcing manual exports or cross-page searches.
- Upcoming unified Project Resource Workbench requires a search capability that spans all resource providers; without a canonical API/input, users still need to jump elsewhere.

## Solution
1. Introduce a **Project Resource Search service** that fans out a query across every project-scoped resource (studies, reports, AI annotations, doctor corrections, etc.) using a shared Accession Number key.
2. Surface a **global search input** inside the Project Detail ListWorkbench header; typing a term triggers full-text search and displays ranked results inline with existing filters.
3. Provide contextual metadata (resource type, snippet highlight, timestamps) so users can quickly understand why a row matched and jump to detailed views.

## Scope
- Backend API + service layer for `/projects/{id}/search` returning paginated mixed-resource results.
- Frontend wiring inside Project Detail (and future unified workbench) to issue search queries, show status/loading, highlight matches, and interact with selection/batch actions.
- Schema alignment so all resource providers expose searchable text fields and the canonical `accession_number`.

## Out of Scope
- Implementing brand-new AI annotation or doctor-note authoring tools (only search integration is scoped).
- Organization-wide search outside the project context.
- Advanced analytics (trend charts, saved searches) — future enhancement.

## Risks
- **Performance**: full-text search across multiple tables could be expensive; mitigation via materialized view or search index (e.g., PostgreSQL `tsvector`, Elasticsearch).
- **Consistency**: resources updated asynchronously might produce stale search results; need index refresh strategy.
- **Security**: search must honor project RBAC and filter out resources the user cannot view.

## PRD / SR Mapping
- **PRJ-SEARCH-FT-01**: Project Detail full-text search input & UX.
- **PRJ-SEARCH-FT-02**: Backend aggregation & ranking across studies/reports/annotations.
- **PRJ-SEARCH-FT-03**: Canonical search key + snippet metadata for result clarity.

