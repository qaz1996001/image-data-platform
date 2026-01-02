# Spec: Project Resource Key Alignment

## ADDED Requirements

### Requirement: Accession Number SHALL be the canonical key
`medical_examinations_fact.exam_id`, `study_project_assignments.study_id`, and `one_page_text_report_v2.report_id` MUST all be treated as the same Accession Number string for the purpose of joining project resources.

#### Scenario: Backend aggregation
- Given the backend fetches project studies and reports
- Then it SHALL normalize each record to `accession_number` by reading the relevant field per table
- And aggregation logic MUST de-duplicate rows when the same accession appears across resources.

### Requirement: APIs SHALL expose `accession_number`
Every project resource API response (studies, reports, unified resources) MUST include a top-level `accession_number` field so the frontend can correlate resources without custom mapping.

#### Scenario: Project resources endpoint
- Given the frontend requests `/projects/:id/resources`
- Then each returned item SHALL contain `accession_number`
- And nested resource payloads (study/report) MAY omit their individual IDs if redundant, but the canonical key MUST remain.

### Requirement: Assignments SHALL reject mismatched keys
Whenever a study is assigned to a project (create/update), the system MUST validate that the provided `study_id` / `exam_id` / `report_id` values refer to the same Accession Number.

#### Scenario: Invalid assignment payload
- Given an API call attempts to map `study_project_assignments.study_id = "A123"` to a report whose `report_id = "B999"`
- Then the service SHALL reject the request with a 400-level error explaining the mismatch.
- And no partial assignments SHALL be persisted.

