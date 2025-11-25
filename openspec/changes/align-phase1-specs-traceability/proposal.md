---
change-id: align-phase1-specs-traceability
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Summary

Align and formalize Phase 1 specification traceability across **system-level (SYS‑PRD / SYS‑SR)**, **frontend (FE‑PRD / FE‑SR)**, and **backend (BE‑PRD / BE‑SR)** documents, based on:
- `docs/requirements/01_SYSTEM_PRD_SR_SD.md`
- `docs/requirements/02_FRONTEND_PRD_SR_SD.md`
- `docs/requirements/03_BACKEND_PRD_SR_SD.md`

This change introduces a single, authoritative **UR → SYS‑PRD → SYS‑SR → FE‑PRD / FE‑SR → BE‑PRD / BE‑SR** traceability matrix and clarifies minor ID/link inconsistencies between the three documents. No runtime behaviour or code will change in this proposal stage.

## Motivation

- The Phase 1 spec set has been refactored into system / frontend / backend PRD/SR/SD layers, but **fine‑grained traceability is split across multiple files**, and some FE‑SR / BE‑SR IDs in `01_SYSTEM_PRD_SR_SD.md` are explicitly marked as placeholders.
- For IEC 62304 / ISO 29148 alignment and future audits, we want a **single, machine‑readable and human‑readable index** that answers:
  - For each **UR‑00x**, which SYS‑PRD / SYS‑SR does it map to?
  - Which **FE‑PRD / FE‑SR** and **BE‑PRD / BE‑SR** are responsible for satisfying it?
  - Where do we see potential **gaps or overlaps** between frontend and backend?
- Having this index under OpenSpec makes it easier to:
  - Evolve requirement sets incrementally (new deltas can update the same matrix).
  - Attach concrete tasks and validations for future spec or implementation changes.

## Scope

### In scope

- Create an OpenSpec change `align-phase1-specs-traceability` that:
  - Records the **current** Phase 1 traceability for UR‑001–UR‑009, based solely on the three requirements docs above.
  - Resolves obvious placeholder inconsistencies between:
    - Section 6 of `01_SYSTEM_PRD_SR_SD.md` (UR → SYS‑PRD → SYS‑SR → FE‑SR / BE‑SR, some IDs marked as “預留”).
    - The concrete FE‑SR / BE‑SR tables in `02_FRONTEND_PRD_SR_SD.md` and `03_BACKEND_PRD_SR_SD.md`.
  - Captures a **canonical traceability matrix** at the UR granularity (one row per UR).
  - Outlines follow‑up tasks to:
    - Update 01/02/03 requirements docs where IDs or links diverge.
    - Add spec‑level requirements (OpenSpec specs) if/when needed.

### Out of scope

- Any change to runtime behaviour, APIs, database schema, or UI.
- Any change to the textual content of:
  - `docs/requirements/01_SYSTEM_PRD_SR_SD.md`
  - `docs/requirements/02_FRONTEND_PRD_SR_SD.md`
  - `docs/requirements/03_BACKEND_PRD_SR_SD.md`
- New capabilities or requirements beyond those already described in the three docs.

## Current State (as of 2025‑11‑24)

### System‑level specs

- `01_SYSTEM_PRD_SR_SD.md` defines:
  - **SYS‑PRD‑001 – 005** as Phase 1 system‑level product requirements.
  - **SYS‑SR‑001 – 010** (functional) and **SYS‑SR‑NFR‑001 – 005** (non‑functional).
  - A high‑level **UR → SYS‑PRD → SYS‑SR → FE‑SR / BE‑SR** table (Section 6), with a note that FE‑SR / BE‑SR IDs are placeholders to be refined by the frontend/backend docs.

### Frontend specs

- `02_FRONTEND_PRD_SR_SD.md` defines:
  - **FE‑PRD‑001 – 006** (login, search, detail + AI display, AI actions, projects/export, UX/shortcuts).
  - **FE‑SR‑001, 002, 010, 011, 020, 030, 040, 041, 050, 051, 060, 080** with concrete mappings to SYS‑SR and backend APIs.
  - A FE ↔ BE traceability table (Section 6) at the FE‑PRD/FE‑SR granularity.

### Backend specs

- `03_BACKEND_PRD_SR_SD.md` defines:
  - **BE‑PRD‑001 – 005** (auth, import, reports/search, AI, projects/export).
  - **BE‑SR‑001, 002, 010, 011, 020, 021, 030, 031, 040, 041, 050, 051, 060, 061** plus BE‑SR‑NFR‑001 – 005.
  - A BE ↔ FE ↔ SYS traceability table (Section 5).

### Observed inconsistencies / ambiguities

- In `01_SYSTEM_PRD_SR_SD.md` Section 6, the UR → FE‑SR / BE‑SR mapping uses **placeholder FE‑SR/BE‑SR IDs** that do not always match the concrete mappings later defined in 02/03. The file explicitly documents that:
  - “FE‑SR‑xxx / BE‑SR‑xxx 僅為預留 ID，實際內容與鏈結將在 02/03 文件中正式定義。”
- There is currently **no single, fully normalized table** that, for each UR, shows:
  - All relevant SYS‑PRD / SYS‑SR.
  - All relevant FE‑PRD / FE‑SR and BE‑PRD / BE‑SR (using the final IDs from 02/03).

## Proposed Changes

### 1. Establish a canonical UR‑centric traceability matrix

Define a UR‑centric traceability table (one row per UR‑00x) that:
- Uses **UR‑001 – UR‑009** as the primary keys.
- Pulls SYS‑PRD / SYS‑SR mappings from `01_SYSTEM_PRD_SR_SD.md` Sections 3–4.
- Uses only the **final FE‑PRD / FE‑SR IDs** from `02_FRONTEND_PRD_SR_SD.md`.
- Uses only the **final BE‑PRD / BE‑SR IDs** from `03_BACKEND_PRD_SR_SD.md`.

### 2. Document the matrix under OpenSpec

- Store the matrix in `specs/traceability/spec.md` as **the authoritative alignment snapshot** for Phase 1.
- Future OpenSpec changes that materially alter UR / SYS‑SR / FE‑SR / BE‑SR relationships should:
  - Update the spec file (`specs/traceability/spec.md`).
  - Keep 01/02/03 requirements docs and the OpenSpec matrix in sync.

### 3. Plan follow‑up edits to requirements docs (non‑blocking)

In later “apply” stages (not part of this proposal), we expect to:
- Adjust the example/placeholder table in `01_SYSTEM_PRD_SR_SD.md` Section 6 so that:
  - It replaces the placeholder IDs with a direct reference/link to `specs/traceability/spec.md`, ensuring a single source of truth.
- Optionally add **cross‑links** in 02/03 pointing back to:
  - The UR‑centric traceability matrix.
  - The relevant UR/NFR IDs, where currently only SYS‑SR IDs are shown.

## UR‑centric Traceability Matrix (Phase 1 snapshot)

> Source of truth for mappings:
> - UR / NFR: `docs/requirements/USER_REQUIREMENTS.md`
> - SYS‑PRD / SYS‑SR: `docs/requirements/01_SYSTEM_PRD_SR_SD.md`
> - FE‑PRD / FE‑SR: `docs/requirements/02_FRONTEND_PRD_SR_SD.md`
> - BE‑PRD / BE‑SR: `docs/requirements/03_BACKEND_PRD_SR_SD.md`

| UR ID | UR 摘要（簡述） | SYS‑PRD | SYS‑SR | FE‑PRD / FE‑SR（主要） | BE‑PRD / BE‑SR（主要） |
|-------|-----------------|---------|--------|------------------------|------------------------|
| UR‑001 | 使用者登入（JWT，30 分鐘有效會話） | SYS‑PRD‑004 | SYS‑SR‑001 | FE‑PRD‑001 / FE‑SR‑001, FE‑SR‑002 | BE‑PRD‑001 / BE‑SR‑001, BE‑SR‑002 |
| UR‑002 | 檢查 / 報告資料匯入（Excel/CSV + 欄位映射） | SYS‑PRD‑002 | SYS‑SR‑002 | （前端匯入精靈 UI，整體掛在 FE‑PRD‑002 / FE‑SR‑010，尚未完全展開） | BE‑PRD‑002 / BE‑SR‑010, BE‑SR‑011 |
| UR‑003 | 檢查記錄搜尋（全文＋多條件） | SYS‑PRD‑002 | SYS‑SR‑003 | FE‑PRD‑002 / FE‑SR‑010, FE‑SR‑011 | BE‑PRD‑002, BE‑PRD‑003 / BE‑SR‑020 |
| UR‑004 | 報告詳情檢視（含 AI 標記歷史） | SYS‑PRD‑001 | SYS‑SR‑004 | FE‑PRD‑003 / FE‑SR‑020, FE‑SR‑030 | BE‑PRD‑003, BE‑PRD‑004 / BE‑SR‑021, BE‑SR‑030, BE‑SR‑031 |
| UR‑005 | 單筆 AI 報告分析（Ollama、本地 LLM） | SYS‑PRD‑001 | SYS‑SR‑005, SYS‑SR‑006 | FE‑PRD‑004 / FE‑SR‑040 | BE‑PRD‑004 / BE‑SR‑040, BE‑SR‑041 |
| UR‑006 | AI 標記管理與基於標記的篩選 | SYS‑PRD‑001 | SYS‑SR‑007（部分 SYS‑SR‑006 亦相關） | FE‑PRD‑003, FE‑PRD‑004 / FE‑SR‑030, FE‑SR‑040, FE‑SR‑041 | BE‑PRD‑004 / BE‑SR‑030, BE‑SR‑031, BE‑SR‑040, BE‑SR‑041 |
| UR‑007 | 專案建立與管理（報告集合） | SYS‑PRD‑003 | SYS‑SR‑008 | FE‑PRD‑005 / FE‑SR‑050, FE‑SR‑051 | BE‑PRD‑005 / BE‑SR‑050, BE‑SR‑051 |
| UR‑008 | 專案 / 搜尋結果匯出（Excel / CSV / JSON） | SYS‑PRD‑003 | SYS‑SR‑009 | FE‑PRD‑005 / FE‑SR‑060 | BE‑PRD‑005 / BE‑SR‑060, BE‑SR‑061 |
| UR‑009 | 高效 UI / 鍵盤快捷鍵 / 大列表效能 | SYS‑PRD‑004 | SYS‑SR‑010 + SYS‑SR‑NFR‑001, 004, 005 | FE‑PRD‑006, FE‑PRD‑007 / FE‑SR‑080, FE‑SR‑090~092 | BE‑PRD‑001, BE‑PRD‑002, BE‑PRD‑003 / BE‑SR‑NFR‑001 – 005（後端僅以效能／穩定性支撐） |

Notes:
- The FE‑SR / BE‑SR sets above are **not exhaustive**; they list the primary requirements most directly tied to each UR, to keep the matrix readable.
- Where `01_SYSTEM_PRD_SR_SD.md` previously listed placeholder FE‑SR / BE‑SR IDs, this matrix follows the finalized IDs and mappings from 02/03.

## Risks & Open Questions

- **Source of truth drift**: If future edits are made directly to 01/02/03 without updating this matrix (or vice versa), traceability can drift.
  - Mitigation: Treat this OpenSpec matrix as the canonical view and add CI/docs checks in later changes.
- **Granularity**: Some FE‑SR / BE‑SR items contribute to multiple URs (especially UX and NFR‑related ones). This matrix keeps only the primary links for clarity; more detailed many‑to‑many mapping could be introduced later if needed.
- **Implementation status**: This proposal describes **intended mappings**, not current implementation completeness; progress tracking will live in separate status/implementation docs or OpenSpec changes.

## Success Criteria

- There is a single, agreed‑upon UR‑centric traceability matrix for Phase 1, grounded in the existing 01/02/03 requirements documents.
- The matrix resolves the placeholder FE‑SR / BE‑SR IDs from `01_SYSTEM_PRD_SR_SD.md` in favour of the concrete IDs from 02/03.
- Future spec or implementation work that touches requirements can reference this change ID (`align-phase1-specs-traceability`) and extend or refine the same matrix, rather than inventing new ad‑hoc mappings.


