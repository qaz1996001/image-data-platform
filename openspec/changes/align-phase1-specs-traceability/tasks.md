---
change-id: align-phase1-specs-traceability
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Tasks

1. **Confirm UR / SYS‑PRD / SYS‑SR mappings**
   - Re‑scan `docs/requirements/USER_REQUIREMENTS.md` and `docs/requirements/01_SYSTEM_PRD_SR_SD.md` to ensure:
     - UR‑001 – UR‑009 are correctly mapped to SYS‑PRD‑001 – 005 and SYS‑SR‑001 – 010.
     - No UR is missing from the system‑level tables.
   - Update this proposal if any mismatches are discovered.

2. **Confirm FE‑PRD / FE‑SR mappings per UR**
   - From `docs/requirements/02_FRONTEND_PRD_SR_SD.md`:
     - Verify the FE‑PRD and FE‑SR tables (Sections 3–4) against the UR‑centric matrix in this proposal.
     - For each UR, double‑check that the FE‑PRD / FE‑SR entries listed here really are the primary frontend responsibilities.
   - If needed, propose clarifying notes in 02_FRONTEND_PRD_SR_SD (via a separate OpenSpec change).

3. **Confirm BE‑PRD / BE‑SR mappings per UR**
   - From `docs/requirements/03_BACKEND_PRD_SR_SD.md`:
     - Verify BE‑PRD / BE‑SR tables (Sections 2–3) against the UR‑centric matrix.
     - Ensure that AI, import, search, project, and export responsibilities are correctly aligned with UR‑005 – UR‑008.
   - Flag any ambiguous or overlapping responsibilities for follow‑up.

4. **Reconcile placeholder mappings in `01_SYSTEM_PRD_SR_SD.md` Section 6**
   - Compare the existing UR → SYS‑PRD → SYS‑SR → FE‑SR / BE‑SR table with the finalized IDs from 02/03 and this proposal.
   - Decide (in a follow‑up change) whether to:
     - Replace the placeholder IDs with the finalized FE‑SR / BE‑SR IDs, or
     - Replace that table with a reference/link to this OpenSpec traceability matrix.

5. **Decide where the canonical matrix should live long‑term**
   - Option A: Keep the UR‑centric matrix in this proposal and reference it from 01/02/03.
   - Option B: Extract the matrix into a dedicated OpenSpec spec (e.g., `specs/traceability/phase1/spec.md`) and:
     - Have 01/02/03 link to that spec.
     - Keep this proposal as the historical introduction of that spec.
   - Capture the decision in a follow‑up OpenSpec change if we move it into a spec.

6. **(Optional) Extend traceability to NFR and test artefacts**
   - If needed for IEC 62304:
     - Introduce mappings from SYS‑SR‑NFR‑001 – 005 to FE‑SR / BE‑SR‑NFR and test plans.
     - Plan separate OpenSpec changes for test‑spec traceability (e.g., SYS‑SR → test cases).

7. **Validate with OpenSpec tooling (when project is initialized)**
   - Once `openspec init` / `openspec project.md` is available:
     - Run `openspec validate align-phase1-specs-traceability --strict`.
     - Resolve any structural or metadata issues reported by the tool (filenames, front‑matter, etc.).


