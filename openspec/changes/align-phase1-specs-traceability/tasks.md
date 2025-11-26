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
   - [x] Re‑scan `docs/requirements/USER_REQUIREMENTS.md` and `docs/requirements/01_SYSTEM_PRD_SR_SD.md` to ensure:
     - UR‑001 – UR‑009 are correctly mapped to SYS‑PRD‑001 – 005 and SYS‑SR‑001 – 010.
     - No UR is missing from the system‑level tables.
   - [x] Update this proposal if any mismatches are discovered.

2. **Confirm FE‑PRD / FE‑SR mappings per UR**
   - [x] From `docs/requirements/02_FRONTEND_PRD_SR_SD.md`:
     - Verify the FE‑PRD and FE‑SR tables (Sections 3–4) against the UR‑centric matrix in this proposal.
     - For each UR, double‑check that the FE‑PRD / FE‑SR entries listed here really are the primary frontend responsibilities.
   - [x] If needed, propose clarifying notes in 02_FRONTEND_PRD_SR_SD (via a separate OpenSpec change).
   - **完成時間**: 2025-11-25
   - **完成說明**: 已補充 FE-PRD-007（統一的 List Workbench 佈局）與 FE-SR-090~092 的詳細技術規範（§4.3, §4.4），並與 `openspec/specs/list-workbench-components/spec.md` 建立追溯關係。

3. **Confirm BE‑PRD / BE‑SR mappings per UR**
   - [x] From `docs/requirements/03_BACKEND_PRD_SR_SD.md`:
     - Verify BE‑PRD / BE‑SR tables (Sections 2–3) against the UR‑centric matrix.
     - Ensure that AI, import, search, project, and export responsibilities are correctly aligned with UR‑005 – UR‑008.
   - [x] Flag any ambiguous or overlapping responsibilities for follow‑up.

4. **Reconcile placeholder mappings in `01_SYSTEM_PRD_SR_SD.md` Section 6**
   - [x] Compare the existing UR → SYS‑PRD → SYS‑SR → FE‑SR / BE‑SR table with the finalized IDs from 02/03 and this proposal.
   - [x] Decide (in a follow‑up change) whether to:
     - Replace the placeholder IDs with the finalized FE‑SR / BE‑SR IDs, or
     - Replace that table with a reference/link to this OpenSpec traceability matrix.

5. **Decide where the canonical matrix should live long‑term**
   - Option A: Keep the UR‑centric matrix in this proposal and reference it from 01/02/03.
   - [x] Option B: Extract the matrix into a dedicated OpenSpec spec (e.g., `specs/traceability/spec.md`) and:
     - Have 01/02/03 link to that spec.
     - Keep this proposal as the historical introduction of that spec.
   - [x] Capture the decision in a follow‑up OpenSpec change if we move it into a spec.

6. **(Optional) Extend traceability to NFR and test artefacts**
   - [x] (Skipped - Defer to future quality assurance change)
     - Introduce mappings from SYS‑SR‑NFR‑001 – 005 to FE‑SR / BE‑SR‑NFR and test plans.
     - Plan separate OpenSpec changes for test‑spec traceability (e.g., SYS‑SR → test cases).

7. **Validate with OpenSpec tooling (when project is initialized)**
   - [x] Once `openspec init` / `openspec project.md` is available:
     - Run `openspec validate align-phase1-specs-traceability --strict`.
     - Resolve any structural or metadata issues reported by the tool (filenames, front‑matter, etc.).

## Phase 2: Cross-File Synchronization Tasks (2025-11-26)

8. **Add direct links to OpenSpec traceability spec in 01_SYSTEM_PRD_SR_SD.md**
   - [x] Update Section 6 heading and introduction to reference `specs/traceability/spec.md`
   - [x] Replace placeholder note about FE-SR/BE-SR IDs with link to authoritative spec
   - [x] Update the summary table with corrected mapping information
   - [x] Add Section 6.2 with maintenance guidelines
   - **完成時間**: 2025-11-26
   - **完成說明**: 將第 6 章重構為簡表 (6.1) + 維護說明 (6.2)，明確指向 `openspec/changes/align-phase1-specs-traceability/specs/traceability/spec.md` 作為權威參考

9. **Add reverse references in 02_FRONTEND_PRD_SR_SD.md**
   - [x] Update Section 6 title and add reference to canonical UR-centric matrix
   - [x] Enhance the FE/BE traceability table with complete BE-SR ID ranges
   - [x] Add Section 6.2 for maintenance guidance
   - **完成時間**: 2025-11-26
   - **完成說明**: 在第 6 章添加指向規範矩陣的鏈接並增強表格的 ID 完整性

10. **Add reverse references in 03_BACKEND_PRD_SR_SD.md**
   - [x] Update Section 5 introduction with link to canonical traceability spec
   - [x] Enhance the traceability table with complete SR ID ranges
   - [x] Add Section 5.2 for maintenance and evolution guidance
   - **完成時間**: 2025-11-26
   - **完成說明**: 在第 5 章添加指向規範矩陣的鏈接並增強系統層的映射表

11. **Update tasks.md to reflect completion**
   - [x] Add Phase 2 section documenting cross-file sync work
   - [x] Mark all cross-file sync tasks as complete
   - **完成時間**: 2025-11-26


