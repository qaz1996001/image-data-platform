# Design: Project Full-Text Search

## Overview
Extend the Project Resource platform so a single query can retrieve studies, reports, AI annotations, and doctor corrections tied to the same project (and Accession Number). The design builds on the upcoming unified Project Resource Workbench.

## Components

### 1. Search API (`/projects/{project_id}/search`)
- **Input**: `q` (string), optional filters (`resource_types[]`, modality, date range), pagination, sort (`relevance`, `recency`).
- **Processing**:
  - Resolve project + RBAC via existing `require_view`.
  - Fan out to resource search providers:
    - Studies: leverage Postgres `tsvector` on `patient_name`, `exam_description`, `clinical_history`, etc.
    - Reports: reuse `report.search_service` (content, title, findings).
    - AI/doctor annotations: introduce new provider once data available; placeholder stub returns empty list.
  - Normalize each hit to `{ accession_number, resource_type, score, snippet, resource_payload }`.
  - Merge + sort by score (default) or timestamp fallback.
- **Output**: Paginated list with metadata described below.

### 2. Search Index Strategy
- **PostgreSQL Full-Text Search**:
  - Add `TSVECTOR` columns (`search_vector`) to `studies` and `reports` tables.
  - Use `GIN` indexes for high-performance querying.
  - Maintain vectors via DB triggers or Django `SearchVectorField` updates on save.
- **Scoping**:
  - All queries MUST be scoped by `project_id` (via `project_reports` join or similar).
- **Registry Pattern**:
- Provide an abstraction `ProjectSearchRegistry` so future resources register their search implementation without touching the core API.

### 3. Frontend Integration
- Add a `SearchInput` inside `ProjectDetailLayout` header (or `ProjectResourceWorkbench` filter area). Debounced keystrokes update the `ListViewStore` query.
- While search is active:
  - Show “Full-text search results for ‘q’” badge in ResultsCard status bar.
  - Display resource rows with highlight snippet (HTML-safe) and reason for match.
- Clearing search resets dataset to standard ListView filters.

### 4. Data Model
- Response item fields:
  - `accession_number` (string)
  - `resource_type` (`study`, `report`, `ai_annotation`, `doctor_note`, etc.)
  - `score` (float normalized 0-1)
  - `resource_timestamp` (ISO) for deterministic fallback sorting
  - `snippet` (text with `<mark>` wrappers)
  - `resource` object referencing the canonical schema (StudyListItem, ReportResponse, etc.)

### 5. Security & Audit
- Every resource provider enforces RBAC before returning hits.
- Log queries per project for audit (“user X searched project Y with terms Z”).
- Rate-limit search endpoint (simple sliding window per user/project).

## Traceability Mapping

| Layer | Requirements ID | Description | Implementation Details |
|-------|----------------|-------------|------------------------|
| **System** | **SYS-PRD-002** | Efficient Search | Full-text search capability. |
| | **SYS-SR-003** | Check Record Search | Support for keyword search across fields. |
| **Frontend** | **FE-PRD-002** | Search UI | Search input with debouncing. |
| | **FE-SR-010** | Search Debounce | 300ms debounce before API call. |
| | **FE-SR-011** | Pagination | Support paginated search results. |
| **Backend** | **BE-PRD-003** | Search API | Backend support for search queries. |
| | **BE-SR-020** | Full-text Search | Use of full-text index for performance. |
| | **BE-SR-NFR-001** | Performance | Search response < 2s for 10k records. |

## Sequence Flow
1. User enters query in Project Detail.
2. Frontend pushes `q` into `ListViewStore`, which calls `/projects/{id}/search`.
3. API resolves project, dispatches to registered search providers.
4. Providers run FTS queries, returning scored hits.
5. Aggregator merges + sorts results, applies pagination, returns JSON.
6. Frontend renders rows with highlight snippet, enabling selection/batch actions as usual (selection key = `accession_number + resource_type`).

## Trade-offs
- **Index maintenance**: triggers add write overhead; acceptable given moderate study/report volume.
- **Cross-resource sorting**: mixing scores from different search engines may require normalization; plan to standardize to 0-1 scale.
- **Complex filters**: Some filters (e.g., modality) apply only to certain resource types; UI must disable incompatible filters or handle backend gracefully.

## Dependencies
- Requires canonical key alignment from `unify-project-resource-workbench`.
- Needs Report search service hook to support project-scoped filter.
