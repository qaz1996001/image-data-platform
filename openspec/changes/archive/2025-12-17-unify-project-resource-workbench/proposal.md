# Unify Project Resource Workbench

## Problem
- The newly refactored Project Detail page still splits resources into separate "Studies" and "Reports" tabs. Users must switch routes to correlate information, and there is no consolidated timeline or batch action view for all project assets.
- The Project-level Study and Report lists do not expose the same `ResultsCard` actions (column manager, selection drawer, batch ops) that exist on the primary Study Search / Report Search pages, limiting parity and making training harder.
- Backend resources that should join via an Accession Number (`medical_examinations_fact.exam_id`, `study_project_assignments.study_id`, `one_page_text_report_v2.report_id`) are treated as unrelated identifiers, so it is cumbersome to aggregate resources or build AI/doctor annotation integrations.

## Solution
1. **ResultsCard parity** – extend the Project Study / Report experiences so their `resultsActions` mirror the canonical Study/Report list workbenches (column toggles, selection drawer, batch action groups).
2. **Unified Project Resource Workbench** – remove the Studies/Reports tabs and replace them with a single ListWorkbench view scoped to the project. Users choose which resource types (studies, reports, AI annotations in future) to include via a resource selector inside the FilterCard, and the ResultsCard renders a merged timeline/table keyed by `exam_id`.
3. **Canonical Accession Number key** – codify that `exam_id` / `study_id` / `report_id` from the mentioned tables refer to the same Accession Number and MUST be inter-operable. All project resource APIs will accept/return that key so new resources (AI annotations, doctor corrections) can plug in rapidly.

## Scope
- Frontend ListWorkbench refactor for Project Detail (header stays, content becomes a single resource list with configurable resource chips/toggles).
- Backend aggregation endpoint that can return heterogeneous resources keyed by Accession Number plus metadata describing resource type & available actions.
- Schema updates so project-specific Study/Report endpoints inherit the base list schemas and expose identical `resultsActions`.

## Out of Scope
- Implementing the actual AI annotation resource list (only the hooks and selector are required now).
- Full text search engine implementation; proposal only ensures the unified list & APIs can forward `q` to all resource providers.

## Risks
- **Performance**: Joining studies, reports, and future resources per project could be heavy; need pagination + debounced filters.
- **Column consistency**: Showing mixed resource columns in one table requires a column manager that can segment per resource type.
- **Behavior parity**: Ensuring batch actions remain accurate when multiple resource types are selected may require action gating or validation rules.

## PRD / SR Mapping
- **PRJ-DETAIL-RES-ACT-01** – Project resource lists match Study/Report results actions.
- **PRJ-DETAIL-UNIFIED-LIST-02** – Single ListWorkbench aggregates project resources without tabs.
- **PRJ-DETAIL-KEY-LINK-03** – Accession Number is the canonical key across study/report/allied resources.

