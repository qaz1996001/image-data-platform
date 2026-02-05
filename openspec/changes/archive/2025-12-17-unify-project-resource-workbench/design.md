# Design: Unify Project Resource Workbench

## Current State
- `ProjectDetailLayout` hosts two nested routes (`/studies`, `/reports`) that reuse portions of the Study/Report list plumbing but lack full `resultsActions` parity.
- Each tab has its own `ListViewProvider`, so there is no single place to query or visualize how studies and reports relate within a project.
- Backend provides `/projects/{id}/studies` and `/projects/{id}/reports`, but there is no canonical multi-resource endpoint nor explicit statement that `exam_id`, `study_id`, and report IDs reference the same Accession Number.

## Proposed Architecture

### Unified ListWorkbench
- Keep the existing `ProjectDetailLayout` header/actions.
- Replace tabbed routes with a single `ProjectResourceWorkbench` component:
  - Wraps a new `ProjectResourceListViewProvider` that can request multiple resource types in one payload.
  - FilterCard gains a **Resource Selector** (checkbox chips: Studies, Reports, AI Annotations (disabled placeholder until implemented)).
  - Resource selector drives the provider fetcher (`resourceTypes[]` query param).
  - ResultsCard shows mixed resources sorted by `assigned_at` / `verified_at` / `resource_timestamp`.
  - Table columns managed via `useColumnManager`, with column presets per resource type (e.g., study columns vs report columns) merged through a registry keyed by resource type.

### Backend Aggregation
- New endpoint `GET /projects/{project_id}/resources` that accepts:
  - `resource_types`: array (studies, reports, ai_annotations, etc.)
  - Shared filters: `q`, `modality`, `report_type`, date ranges, pagination & sorting.
- Service layer builds a union list keyed by `accession_number` (canonical string), with payload shape:
  ```json
  {
    "resource_type": "study" | "report" | "ai_annotation",
    "accession_number": "A12345",
    "study": { ...StudyListItem fields } | null,
    "report": { ...ReportResponse fields } | null,
    "project_assignment": {
      "assigned_at": "...",
      "assigned_by": { ... }
    }
  }
  ```
- Each nested resource reuses existing serializers (`StudyListItem`, `ReportDetailResponse`, future `AIAnnotationListItem`).
- Sorting defaults to `resource_timestamp` derived per entry (e.g., `study.exam_date` vs `report.verified_at`).

### Results Actions Parity
- `ProjectResourceWorkbench` will plug into the existing `resultsActions` registry so users see:
  - Column manager button (scoped to resource presets).
  - Selection Drawer trigger showing combined selection counts.
  - Drawer actions adapt to selected resource mix (e.g., "Remove from Project" for studies, "Export" for reports); non-applicable actions greyed with tooltips.
- For backward compatibility, the dedicated `/projects/{id}/studies` and `/projects/{id}/reports` APIs/components will also expose their `resultsActions` (until the unified list fully replaces them in navigation).

### Canonical Key Enforcement
- Introduce a small helper (`AccessionKeyResolver`) in the backend service layer to translate between:
  - `medical_examinations_fact.exam_id` (Legacy DB PK)
  - `study_project_assignments.study_id` (FK to exam_id)
  - `one_page_text_report_v2.report_id` (Legacy DB PK, usually matches exam_id but needs verification)
- **Accession Number** is the domain key. The resolver must:
  1. Accept an input ID (study_id or report_id).
  2. Resolve it to the canonical `accession_number` string.
  3. Use that key to join Study and Report records.
- API responses MUST surface `accession_number` explicitly so the frontend can de-duplicate rows when both study & report exist.

## Data Flow
1. `ProjectResourceListViewProvider` assembles query (projectId, resourceTypes[], filters, pagination).
2. Endpoint returns paginated union list.
3. Provider normalizes into `ListViewStore` items with shape `{ accession_number, resource_type, study?, report?, actions }`.
4. Table renders dynamic columns:
   - Always show `resource_type`, `accession_number`, `updated_at`.
   - Conditionally show study/report columns when relevant.
5. Selection Drawer groups actions by resource type; calling backend mutations via existing services (remove study from project, export report, etc.).

## Traceability Mapping

| Layer | Requirements ID | Description | Implementation Details |
|-------|----------------|-------------|------------------------|
| **System** | **SYS-PRD-003** | Project Management | Unified view for project assets. |
| | **SYS-SR-008** | Project Operations | Support for adding/removing resources and viewing lists. |
| **Frontend** | **FE-PRD-005** | Project UI | Project Detail / List Workbench integration. |
| | **FE-PRD-007** | Unified List Workbench | Use of standard `ListWorkbench` layout. |
| | **FE-SR-051** | Project Detail Reports | Display Study/Report lists in project context. |
| | **FE-SR-090~092** | Workbench Consistency | Shared FilterCard, ResultsCard, SelectionDrawer patterns. |
| **Backend** | **BE-PRD-005** | Project API | Aggregation endpoint for project resources. |
| | **BE-SR-050/051** | Project Resources | Maintain relationships between Projects and Studies/Reports. |

## Trade-offs & Open Questions
- **Sorting semantics**: Need a consistent cross-resource timestamp; propose `resource_timestamp` fallback order `report.verified_at || study.exam_date || assignment.assigned_at`.
- **Pagination fairness**: Union list may interleave resources unevenly; consider `resource_type` filter default (studies selected) to avoid empty states.
- **Future search**: Endpoint should pass-through `q` to both study and report search logic; may require asynchronous fan-out.
- **Backward compatibility**: Need to decide when to remove `/studies` + `/reports` routes; during transition, keep them but hide navigation entry once unified view stabilizes.
