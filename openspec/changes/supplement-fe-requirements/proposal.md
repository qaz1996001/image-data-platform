---
change-id: supplement-fe-requirements
status: draft
owners:
  - TBD
created-at: 2025-11-25
updated-at: 2025-11-25
extensions: {}
---

## Summary

Supplement `docs/requirements/02_FRONTEND_PRD_SR_SD.md` with missing frontend requirements for **Data Import (UR-002)** and **Annotation Management (UR-006)**. This change is the direct output of **Task 2 (Confirm FE‑PRD / FE‑SR mappings per UR)** from the `align-phase1-specs-traceability` initiative.

## Motivation

- **Traceability Gap Analysis**: A review of `02_FRONTEND_PRD_SR_SD.md` against `01_SYSTEM_PRD_SR_SD.md` (specifically UR-001 through UR-009) revealed two significant gaps where System SRs were defined but Frontend SRs were missing:
  1.  **UR-002 (Data Import)**: `SYS-PRD-002` / `SYS-SR-002` require Excel/CSV import capabilities. The current Frontend doc lacks a PRD item for the "Import Wizard" and corresponding SRs for the upload/map/execute flow.
  2.  **UR-006 (Annotation Management)**: `SYS-SR-007` requires "view, edit, delete" capabilities. While `FE-SR-030` covers "view", there are no specific SRs for the "edit" and "delete" UI actions.
- **Compliance**: To satisfy ISO/IEC 29148 & 62304 traceability requirements, every functional System SR must map to at least one Frontend or Backend SR.

## Scope

### In scope

- **Documentation Updates** (`docs/requirements/02_FRONTEND_PRD_SR_SD.md`):
  - **Add FE-PRD-008 (Data Import Wizard)**: Define the requirements for the 3-step import process (Upload -> Map -> Execute).
  - **Add FE-SR-070 & FE-SR-071**: Define software requirements for the import flow and validation/feedback.
  - **Add FE-SR-031**: Define software requirements for Annotation Edit/Delete actions under `FE-PRD-003`.
  - **Update Section 6 (Traceability)**: Fill in the matrix to link `SYS-SR-002` to `FE-PRD-008` and `SYS-SR-007` to `FE-SR-031`.
  - **Refine Table Formatting**: Ensure the traceability tables are clean and consistent.

### Out of scope

- **Code Implementation**: This proposal is strictly for *requirements documentation alignment*. Actual implementation of the Import Wizard or Annotation Edit UI will be tracked in separate implementation tasks (though the requirements are prerequisites).
- **Backend Spec Updates**: Backend requirements for these features (`BE-PRD-002`, `BE-SR-010` etc.) appear sufficient in `01_SYSTEM_PRD_SR_SD.md` and are out of scope here.

## Proposed Changes

### 1. Add FE-PRD-008: Data Import Wizard

**Location**: `02_FRONTEND_PRD_SR_SD.md` > Section 3.1 > New Item

> #### FE-PRD-008 資料匯入精靈
>
> - **描述**：提供分步引導式介面 (Wizard)，協助研究人員將外部資料（Excel / CSV）匯入系統：
>   - **Step 1 檔案上傳**：支援拖曳上傳，即時檢查檔案格式，並呼叫預覽 API。
>   - **Step 2 欄位映射**：顯示來源檔案欄位與目標系統欄位 (Patient ID, Exam Date, etc.) 的對應關係，支援自動猜測與手動調整。
>   - **Step 3 預覽與執行**：顯示前 5-10 筆資料預覽，確認後執行匯入，並即時顯示成功/失敗/重複筆數統計。
> - **對應系統需求**：SYS-PRD-002、SYS-SR-002。

### 2. Add FE-SR Items

**Location**: `02_FRONTEND_PRD_SR_SD.md` > Section 4.1 > Table Update

| FE-SR ID | 摘要 | 對應 SYS-SR | 主要使用 API |
|----------|------|-------------|--------------|
| **FE-SR-031** | 詳情頁需提供「編輯」與「刪除」AI 標記的操作介面；編輯時彈出對話框修改內容，刪除時需二次確認，成功後刷新標記列表。 | SYS-SR-007 | `PUT /ai/annotations/{id}`, `DELETE /ai/annotations/{id}` |
| **FE-SR-070** | 匯入頁面應實作分步精靈 (Stepper)：上傳檔案 (`POST /import/preview`) -> 設定 Mapping -> 提交執行 (`POST /import/execute`)。 | SYS-SR-002 | `POST /api/v1/import/preview`, `POST /api/v1/import/execute` |
| **FE-SR-071** | 匯入執行期間前端應顯示進度條或 Loading 狀態，並在結束時顯示完整的匯入報告（成功、重複、失敗筆數與錯誤原因）。 | SYS-SR-002 | `GET /api/v1/import/status/{task_id}` (若為非同步) or API 回傳結果 |

### 3. Update Traceability Matrix

**Location**: `02_FRONTEND_PRD_SR_SD.md` > Section 6 > Table Update

| FE-PRD | FE-SR | 對應 SYS-PRD / SYS-SR | 對應 Backend PRD / SR |
|--------|-------|-----------------------|------------------------|
| FE-PRD-003 | FE-SR-020, 030, **031** | SYS-PRD-001 / SYS-SR-004, 007 | BE-PRD-003 / BE-SR-030, 050 |
| **FE-PRD-008** | **FE-SR-070, 071** | **SYS-PRD-002 / SYS-SR-002** | **BE-PRD-002 / BE-SR-010, 011** |

## Risks & Open Questions

- **API Readiness**: Does the current Backend API fully support the "Preview -> Map -> Execute" flow described in `FE-SR-070`? (Assumption: Yes, per `SYS-SR-002` definition, but verification during implementation is needed).
