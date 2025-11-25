# 文檔索引（Phase 1 - AI 輔助報告篩選系統）

> 本索引僅針對 **Phase 1：AI 輔助報告篩選與專案管理**，並重新整理 PRD / SR / SD，使其可對應 **ISO/IEC/IEEE 29148:2018** 與 **IEC 62304:2006** 要求。舊版文件保留於 `docs/old/` 做為歷史參考。

---

## 1. 文件分層與命名規則

- **SYSTEM**：整體系統觀點（含產品願景、系統需求、總體設計）
- **FRONTEND**：前端 Web 應用（React + TS）之需求與設計
- **BACKEND**：後端（目前實作：Django / FastAPI + PostgreSQL + Ollama）之需求與設計

文件統一放在 `docs/requirements/` 下：

| 類別 | 檔案 | 說明 |
|------|------|------|
| System | `01_SYSTEM_PRD_SR_SD.md` | 系統層 PRD / SR / SD 匯總與追溯矩陣 |
| Frontend | `02_FRONTEND_PRD_SR_SD.md` | 前端層 PRD / SR / SD 及與系統與後端對應 |
| Backend | `03_BACKEND_PRD_SR_SD.md` | 後端層 PRD / SR / SD 及與系統與前端對應 |

相關舊版文件保留在 `docs/old`，不得直接修改，只能在新文件中以「參考來源」或「追溯關係」方式引用。

---

## 2. 與國際標準的對應

### 2.1 ISO/IEC/IEEE 29148:2018 對應

下表說明本專案文件如何覆蓋標準中主要需求文件型別：

| 標準文件概念 | 本專案對應文件 |
|--------------|----------------|
| Stakeholder / User Requirements | `old/requirements/USER_REQUIREMENTS.md`（來源） + `requirements/01_SYSTEM_PRD_SR_SD.md` 第 3 章（整理與映射） |
| System Requirements Specification (SyRS) | `01_SYSTEM_PRD_SR_SD.md` 第 4 章（系統 SR 級需求清單與可驗證性敘述） |
| Software Requirements Specification (SRS) | `02_FRONTEND_PRD_SR_SD.md` / `03_BACKEND_PRD_SR_SD.md` 第 3–4 章（前後端 SRS） |
| Traceability (需求追溯) | 三份文件中的追溯矩陣章節（UR → SYS-SR → FE/BE-SR → 設計/API/資料表） |

### 2.2 IEC 62304:2006 對應（醫療器材軟體生命週期）

IEC 62304 要求的「軟體需求規格（SRS）」與「軟體架構 / 詳細設計」分別由以下文件承接：

| IEC 62304 成果物 | 本專案對應 |
|------------------|------------|
| Software Requirements Specification | `01_SYSTEM_PRD_SR_SD.md` 之系統 SR + `02_FRONTEND_PRD_SR_SD.md` / `03_BACKEND_PRD_SR_SD.md` 之 FE/BE SR |
| Software Architectural Design | `old/architecture/02_TECHNICAL_ARCHITECTURE.md`（來源） + `requirements/01_SYSTEM_PRD_SR_SD.md` 第 5 章（系統設計整理） |
| Software Detailed Design | `02_FRONTEND_PRD_SR_SD.md` / `03_BACKEND_PRD_SR_SD.md` 第 5 章（模組與介面設計，對應 API / DB / UI 結構） |
| Traceability to Risk / Hazard Controls | 目前僅在 `01_SYSTEM_PRD_SR_SD.md` 中預留「安全與風險相關需求」區段，未完整實作風險管控文件（需未來配合 ISO 14971 / ISO 13485 補齊）。 |

---

## 3. 文件一覽與交叉連結

### 3.1 系統層文件

- `requirements/01_SYSTEM_PRD_SR_SD.md`
  - 整合以下舊檔案內容，形成系統層 PRD / SR / SD 索引：
    - `old/01_PROJECT_OVERVIEW.md`
    - `old/requirements/USER_REQUIREMENTS.md`
    - `old/requirements/FUNCTIONAL_SPECIFICATION.md`
    - `old/architecture/02_TECHNICAL_ARCHITECTURE.md`
    - `old/database/03_DATABASE_DESIGN.md`
    - `old/api/04_API_SPECIFICATION.md`
    - `old/archive/_tasks/2025-11-12-medical-imaging-platform-prd/*.md`

### 3.2 前端層文件

- `requirements/02_FRONTEND_PRD_SR_SD.md`
  - 聚焦 React + TS 前端：Study 搜尋、報告詳情、AI 分析、專案管理、匯入匯出 UI。
  - 來源主要對應：
    - `old/requirements/USER_REQUIREMENTS.md` 中與 UI/UX 有關之需求（如 UR-003, UR-004, UR-009）
    - `old/requirements/FUNCTIONAL_SPECIFICATION.md` 中前端程式碼與流程示例
    - `old/architecture/FRONTEND_BACKEND_INTEGRATION.md` 中之前端結構與 Zustand 狀態模型
  - **近期更新**：新增 FE-PRD-007 / FE-SR-090~092，定義 Study Search / Reports / Projects 共用的 List Workbench、欄位設定 Drawer 與批次操作工具列一致化規範。

### 3.3 後端層文件

- `requirements/03_BACKEND_PRD_SR_SD.md`
  - 聚焦 API / DB / AI Service / 匯入與導出 / 權限等後端職責。
  - 來源主要對應：
    - `old/requirements/USER_REQUIREMENTS.md` 中涉及資料處理與效能/安全的需求
    - `old/requirements/FUNCTIONAL_SPECIFICATION.md` 中 FastAPI 範例（實際已遷移 Django，可在文件中標註差異）
    - `old/architecture/02_TECHNICAL_ARCHITECTURE.md`
    - `old/api/04_API_SPECIFICATION.md`
    - `old/database/03_DATABASE_DESIGN.md`

---

## 4. 文件管制與版本管理

- 所有新文件：
  - 需在首段提供：文件 ID、標題、版本、狀態、建立與更新日期、作者/審核人欄位。
  - 採語意化版本號，例如：`v2.0.0-Phase1`。
  - 重大變更需更新本索引中對應說明。
- 舊文件：
  - 全數保留在 `_old/docs/`，僅供參考與追溯，不再直接修改。
  - 如需實質內容變更，應在新文件層做「差異說明」或「補充條款」。

---

> 後續若新增 Phase 2（DICOM / PACS 整合）相關規格，可在本索引下再開一個 `Phase 2` 小節，並新增對應的 `SYSTEM/FRONTEND/BACKEND` PRD/SR/SD 文件。