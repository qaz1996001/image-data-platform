# 01_SYSTEM_PRD_SR_SD — 系統層 PRD / SR / SD 匯總

**文件 ID**: SYS-PRD-SR-SD-001  
**標題**: 影像數據平台 Phase 1（AI 輔助報告篩選系統）— 系統層 PRD / SR / SD  
**版本**: v2.0.0-Phase1  
**狀態**: Draft（基於 `_old` 文件之整理；待正式核准）  
**建立日期**: 2025-11-24  
**最後更新**: 2025-11-24  
**作者**: （待填）  
**審核人**: （技術負責 / 品質負責 / 使用者代表 待填）  
**適用階段**: Phase 1 — AI 輔助報告篩選與專案管理（不含 DICOM / PACS 整合）

> 本文件不重新撰寫所有需求與設計，而是將 [`docs/old/`](../old/) 中既有的 **PRD、User Requirements、Functional Specification、Architecture、Database、API** 等文件，整理成系統層的 **PRD / SR / SD 索引與追溯矩陣**，以符合 **ISO/IEC/IEEE 29148:2018** 與 **IEC 62304:2006** 對需求與設計文件的結構與可追溯性要求。

---

## 1. 範圍與系統概述（System Scope & Overview）

### 1.1 系統範圍（Phase 1）

- **系統名稱**：影像數據平台 — AI 輔助報告篩選與專案管理系統
- **Phase 1 核心目標**（來源：[`docs/old/01_PROJECT_OVERVIEW.md`](../old/01_PROJECT_OVERVIEW.md)、[`docs/old/requirements/USER_REQUIREMENTS.md`](../old/requirements/USER_REQUIREMENTS.md)）：
  - 在 **PACS 下載影像之前**，以報告為中心，提供：
    - 報告資料匯入（Excel / CSV）
    - 報告全文搜尋與多條件篩選
    - 透過本地 LLM（Ollama, qwen2.5:7b）進行 AI 報告分析與標記
    - 以「專案」為單位組織篩選後的檢查報告
    - 將結果匯出，供後續 PACS 影像下載與研究使用
- **不在 Phase 1 範圍內**（但於 `_old` PRD / 架構中已有規劃）：
  - DICOM 影像上傳 / 儲存 / 預覽（Cornerstone.js, MinIO）
  - PACS / HIS / Accssyn / Red Report 等外部系統自動同步
  - 進階協作功能與多機構部署

### 1.2 系統邊界

- **內部組件**（本文件涵蓋之系統軟體）：
  - Web 前端（React + TS + Ant Design + Zustand）
  - 應用後端（FastAPI / Django + PostgreSQL + Ollama LLM Client）
  - 主資料庫（PostgreSQL：reports / ai_annotations / projects / project_reports / users）
- **外部介面與假設**：
  - 使用者瀏覽器（Chrome / Edge 桌面版）
  - 系統管理員手動匯入歷史報告資料來源檔（Excel / CSV）
  - 本地 LLM 服務 `Ollama` （Port 11434，模型 qwen2.5:7b 等）
  - Phase 1 中 **不直接連線 PACS / HIS**，僅透過匯出清單支援後續流程。

### 1.3 關聯文件

- [`docs/old/01_PROJECT_OVERVIEW.md`](../old/01_PROJECT_OVERVIEW.md)
- [`docs/old/requirements/USER_REQUIREMENTS.md`](../old/requirements/USER_REQUIREMENTS.md)
- [`docs/old/requirements/FUNCTIONAL_SPECIFICATION.md`](../old/requirements/FUNCTIONAL_SPECIFICATION.md)
- [`docs/old/architecture/02_TECHNICAL_ARCHITECTURE.md`](../old/architecture/02_TECHNICAL_ARCHITECTURE.md)
- [`docs/old/database/03_DATABASE_DESIGN.md`](../old/database/03_DATABASE_DESIGN.md)
- [`docs/old/api/04_API_SPECIFICATION.md`](../old/api/04_API_SPECIFICATION.md)
- [`docs/old/archive/_tasks/2025-11-12-medical-imaging-platform-prd/`](../old/archive/_tasks/2025-11-12-medical-imaging-platform-prd/)

---

## 2. 名詞、縮寫與 ID 規則

### 2.1 名詞與縮寫

- **PRD**：Product Requirements Document（產品需求文件）
- **SR / SRS**：System/Software Requirements（系統 / 軟體需求規格）
- **SD / SDD**：Software Design / Software Design Description（軟體設計說明）
- **UR-xxx**：原始使用者需求 ID（出自 [`docs/old/requirements/USER_REQUIREMENTS.md`](../old/requirements/USER_REQUIREMENTS.md)）
- **NFR-xxx**：非功能性需求 ID（同上）
- **SYS-PRD-xxx**：系統層產品需求 ID（本文件新增）
- **SYS-SR-xxx**：系統層軟體需求 ID（本文件新增，對應 UR / NFR）
- **FE-PRD-xxx / FE-SR-xxx**：前端層需求 ID（定義於 `02_FRONTEND_PRD_SR_SD.md`）
- **BE-PRD-xxx / BE-SR-xxx**：後端層需求 ID（定義於 `03_BACKEND_PRD_SR_SD.md`）

### 2.2 ID 與追溯規則

- 使用者需求（UR-xxx）為 **需求來源**，不可修改，只能在新文件中引用。
- 系統層 SR 以 `SYS-SR-xxx` 對 UR 進行重新編組與分類，確保：
  - 每條需求皆具有 **可驗證性**（Verifiability）
  - 標示相關 NFR（效能、安全、維護性等）
- 前端 / 後端層 SR 需在其文件中明確標註：
  - 對應的 `SYS-SR-xxx`
  - 對應的介面（API / 頁面 / 資料表）

---

## 3. 系統層 PRD（Product Requirements）

> 本節將 [`docs/old/archive/_tasks/2025-11-12-medical-imaging-platform-prd/`](../old/archive/_tasks/2025-11-12-medical-imaging-platform-prd/) 與 [`docs/old/01_PROJECT_OVERVIEW.md`](../old/01_PROJECT_OVERVIEW.md) 的產品層敘述，壓縮為數條系統層產品需求（SYS-PRD-xxx），並指明其對應的使用者需求（UR-xxx）。

### 3.1 SYS-PRD 需求列表

<a id="SYS-PRD-001"></a>
#### SYS-PRD-001 AI 輔助報告篩選與標記

- **說明**：系統應協助研究人員，使用本地 LLM 對檢查報告進行結構化分析與標記，支援高亮、分類、提取、評分等型態，以加速符合研究條件之病例篩選。
- **來源 UR**：UR-003、UR-004、UR-005、UR-006（[`docs/old/requirements/USER_REQUIREMENTS.md`](../old/requirements/USER_REQUIREMENTS.md)）
- **來源 PRD**：[`docs/old/archive/_tasks/2025-11-12-medical-imaging-platform-prd/003-core-features-requirements.md`](../old/archive/_tasks/2025-11-12-medical-imaging-platform-prd/003-core-features-requirements.md) 等
- **對應子系統**：
  - 前端：AI 分析觸發與結果顯示 UI（參考 `02_FRONTEND_PRD_SR_SD.md`）
  - 後端：AI Analysis API、Ollama Client、AI 標註持久化（參考 `03_BACKEND_PRD_SR_SD.md`）

<a id="SYS-PRD-002"></a>
#### SYS-PRD-002 報告資料整合與高效搜尋

- **說明**：系統應支援從多來源（Excel / CSV）匯入報告與檢查資訊，並提供全文搜尋與多條件篩選能力，包含患者資訊、日期、檢查類型、科別與 AI 標記條件。
- **來源 UR**：UR-002、UR-003、UR-004
- **對應子系統**：
  - 前端：搜尋介面、列表與詳情頁
  - 後端：匯入 API、報告搜尋 API、PostgreSQL 全文索引

<a id="SYS-PRD-003"></a>
#### SYS-PRD-003 專案管理與資料匯出

- **說明**：系統應允許使用者以「專案」為單位管理篩選後的報告集合，並以 Excel / CSV / JSON 格式匯出，用於後續 PACS 影像下載與研究工作。
- **來源 UR**：UR-007、UR-008
- **對應子系統**：
  - 前端：專案列表 / 詳情 / 匯出操作 UI
  - 後端：projects / project_reports 資料模型與 Export API

<a id="SYS-PRD-004"></a>
#### SYS-PRD-004 簡潔高效的研究者工作介面

- **說明**：系統應提供針對研究者優化的桌面 Web 介面，強調簡潔、快速操作與鍵盤快捷鍵，支援大量列表瀏覽與快速切換。
- **來源 UR**：UR-009、NFR-004、NFR-005
- **對應子系統**：
  - 前端：桌面優化的 React UI、快捷鍵、虛擬滾動
  - 後端：提供效能足夠的 API 響應（參考 NFR-001~003）

<a id="SYS-PRD-005"></a>
#### SYS-PRD-005 安全性與本地部署約束

- **說明**：系統與 LLM 均須在院內本地部署，採用 JWT 驗證、加密儲存帳號密碼，確保報告內容與患者資料不離開受控網路環境。
- **來源 UR**：NFR-006、NFR-007，[`docs/old/01_PROJECT_OVERVIEW.md`](../old/01_PROJECT_OVERVIEW.md) 中之「本地部署」敘述
- **對應子系統**：
  - 前端：基於 JWT 的會話處理與錯誤提示
  - 後端：Auth 模組、HTTPS、密碼雜湊與日誌脫敏

---

## 4. 系統層 SR（System / Software Requirements）

> 本節將 [`docs/old/requirements/USER_REQUIREMENTS.md`](../old/requirements/USER_REQUIREMENTS.md) 中的 UR-001 ~ UR-009 與非功能需求（NFR-001~009），重新整理為系統層需求（SYS-SR-xxx），以符合 ISO 29148 / IEC 62304 的 **可驗證、分類良好且可追溯** 的 SRS 結構。詳細文字敘述仍以原 UR/NFR 文件為準，本處作為索引與分類。

### 4.1 功能性系統需求（Functional SYS-SR）

| SYS-SR ID | 系統需求摘要 | 來源 UR | 鏈結到 PRD | 主要實作位置 |
|-----------|-------------|---------|-----------|--------------|
| SYS-SR-001 | 系統應提供使用者帳號密碼登入與 JWT 驗證，會話時效 30 分鐘。 | UR-001 | [SYS-PRD-004](#SYS-PRD-004) | FE：登入頁 / 狀態管理；BE：auth API / users 表 |
| SYS-SR-002 | 系統應支援 Excel / CSV 匯入檢查與報告資料，包含患者 ID、姓名、檢查日期、檢查類型與報告內容。 | UR-002 | [SYS-PRD-002](#SYS-PRD-002) | FE：匯入精靈 UI；BE：import/preview, import/execute API；DB：reports |
| SYS-SR-003 | 系統應提供關鍵字 + 多條件（日期、檢查類型、科別、AI 標記）搜尋報告的能力，並以分頁方式回傳結果。 | UR-003 | [SYS-PRD-002](#SYS-PRD-002) | FE：搜尋頁 / Study 列表；BE：reports/search API；DB：全文索引 |
| SYS-SR-004 | 系統應提供報告詳情檢視，顯示患者基本資料、檢查資訊、完整報告與所有 AI 標記歷史。 | UR-004 | [SYS-PRD-001](#SYS-PRD-001) | FE：Report Detail 頁；BE：report detail API / ai_annotations |
| SYS-SR-005 | 系統應能針對單一報告進行 AI 分析，依使用者提示詞產生結構化標記，並儲存在資料庫。 | UR-005 | [SYS-PRD-001](#SYS-PRD-001) | FE：AI 觸發與結果呈現；BE：ai/analyze API / Ollama Client |
| SYS-SR-006 | 系統應能針對多份報告進行批次 AI 分析，限制單批數量（例如 ≤ 50），並提供進度與錯誤資訊。 | UR-005, UR-006 | [SYS-PRD-001](#SYS-PRD-001) | FE：批次操作 UI；BE：ai/batch-analyze + 背景任務 |
| SYS-SR-007 | 系統應允許使用者檢視、編輯、刪除 AI 標記，並可依標記內容與分類進行篩選。 | UR-006 | [SYS-PRD-001](#SYS-PRD-001) | FE：標記管理介面；BE：ai/annotations CRUD API；DB：ai_annotations |
| SYS-SR-008 | 系統應支援建立專案、將報告加入/移出專案、檢視專案統計並管理狀態。 | UR-007 | [SYS-PRD-003](#SYS-PRD-003) | FE：Project List/Detail；BE：projects / project_reports API；DB：projects* |
| SYS-SR-009 | 系統應支援將專案或搜尋結果以 Excel / CSV / JSON 匯出，並可選擇包含 AI 標記摘要或詳細內容。 | UR-008 | [SYS-PRD-003](#SYS-PRD-003) | FE：匯出對話框；BE：export APIs；DB：reports / ai_annotations / project_reports |
| SYS-SR-010 | 系統應提供鍵盤快捷鍵與高效率 UI 操作，降低滑鼠點擊次數。 | UR-009 | [SYS-PRD-004](#SYS-PRD-004) | FE：快捷鍵綁定 / 狀態管理 |

> 前端與後端層的具體拆解將在：
> - `02_FRONTEND_PRD_SR_SD.md` 中對應 FE-SR-xxx ← SYS-SR-xxx
> - `03_BACKEND_PRD_SR_SD.md` 中對應 BE-SR-xxx ← SYS-SR-xxx

### 4.2 非功能性系統需求（Non-Functional SYS-SR）

此處直接索引 [`docs/old/requirements/USER_REQUIREMENTS.md`](../old/requirements/USER_REQUIREMENTS.md) 中的 NFR-001 ~ NFR-009，並將其提升為系統層 NFR：

| SYS-SR (NFR) ID | 類別 | 摘要 | 來源 NFR | 覆蓋位置 |
|-----------------|------|------|---------|----------|
| SYS-SR-NFR-001 | 性能 | API 一般回應 < 1s，搜尋 < 2s，AI 分析 < 5s/報告。 | NFR-001 | BE：API / DB 設計；FE：減少不必要請求 |
| SYS-SR-NFR-002 | 容量 | 支援 ≥ 100k 報告與 ≥ 500k AI 標記。 | NFR-003 | DB：索引與結構；BE：查詢設計 |
| SYS-SR-NFR-003 | 可用性 | 開發/測試環境可用度 ≥ 95%，啟動 < 1 分鐘。 | NFR-004 | Docker Compose / health check |
| SYS-SR-NFR-004 | 安全性 | JWT 30 分鐘有效期、HTTPS（生產）、bcrypt 密碼、日誌脫敏。 | NFR-006, NFR-007 | BE：auth / logging；Infra：TLS |
| SYS-SR-NFR-005 | 可維護性 | 測試覆蓋率 ≥ 70%，遵循 PEP 8 / ESLint 規範，具備結構化文件。 | NFR-008, NFR-009 | 開發流程與 CI 配置 |

---

## 5. 系統層 SD（Software Design 概要）

> 詳細技術設計仍以舊文件為主：[`docs/old/architecture/02_TECHNICAL_ARCHITECTURE.md`](../old/architecture/02_TECHNICAL_ARCHITECTURE.md)、[`docs/old/database/03_DATABASE_DESIGN.md`](../old/database/03_DATABASE_DESIGN.md)、[`docs/old/api/04_API_SPECIFICATION.md`](../old/api/04_API_SPECIFICATION.md)。本節目的在於：
> 1. 宣告這些文件在 IEC 62304 上扮演「軟體架構設計」與「詳細設計」的角色。
> 2. 將關鍵設計決策與 SYS-SR-xxx 之間建立對應關係。

### 5.1 架構層級設計（對應 IEC 62304: Software Architectural Design）

- 主要來源：[`docs/old/architecture/02_TECHNICAL_ARCHITECTURE.md`](../old/architecture/02_TECHNICAL_ARCHITECTURE.md)
- 對應 SYS-SR：
  - 認證與授權模組（Auth Module） ↔ SYS-SR-001、SYS-SR-NFR-004
  - 匯入模組（Import Module） ↔ SYS-SR-002
  - 報告搜尋模組（Search Module） ↔ SYS-SR-003、SYS-SR-NFR-001
  - AI 分析模組（AI Analysis Module + Ollama Client） ↔ SYS-SR-005、SYS-SR-006
  - 專案管理模組（Project Module） ↔ SYS-SR-008
  - 匯出模組（Export Module） ↔ SYS-SR-009

### 5.2 資料模型與資料庫設計

- 主要來源：[`docs/old/database/03_DATABASE_DESIGN.md`](../old/database/03_DATABASE_DESIGN.md)
- 關鍵資料表：
  - `users`：支援簡化角色 `admin` / `researcher`（支撐 SYS-SR-001, SYS-SR-NFR-004）
  - `reports`：匯入的檢查與報告主體（支撐 SYS-SR-002, 003, 004, 009）
  - `ai_annotations`：AI 標記結果（支撐 SYS-SR-005, 006, 007）
  - `projects`, `project_reports`：專案與報告關聯（支撐 SYS-SR-008, 009）
- 全文索引與 JSONB 索引對應性能需求（SYS-SR-NFR-001, SYS-SR-NFR-002）。

### 5.3 API 設計與外部介面

- 主要來源：[`docs/old/api/04_API_SPECIFICATION.md`](../old/api/04_API_SPECIFICATION.md)
- API 類別：
  - `/auth/*`：登入與取得目前使用者資訊；對應 SYS-SR-001。
  - `/import/*`：預覽與執行資料匯入；對應 SYS-SR-002。
  - `/reports/*`：列表、搜尋與詳情；對應 SYS-SR-003, 004。
  - `/ai/*`：單筆與批次 AI 分析、標記存取；對應 SYS-SR-005, 006, 007。
  - `/projects/*`、`/export/*`：專案管理與資料匯出；對應 SYS-SR-008, 009。

---

## 6. 需求追溯矩陣（UR → SYS-SR → FE/BE）

> 詳細 FE / BE 映射將在各自文件中展開，這裡先提供系統層總表，以滿足 ISO 29148 與 IEC 62304 對「需求追溯」的要求。

| 使用者需求 (UR) | 系統產品需求 (SYS-PRD) | 系統需求 (SYS-SR) | 前端需求文件 | 後端需求文件 |
|-----------------|-------------------------|--------------------|--------------|--------------|
| UR-001 登入 | SYS-PRD-004 | SYS-SR-001 | `02_FRONTEND_PRD_SR_SD.md` FE-SR-001 | `03_BACKEND_PRD_SR_SD.md` BE-SR-001 |
| UR-002 匯入 | SYS-PRD-002 | SYS-SR-002 | FE-SR-010 | BE-SR-010 |
| UR-003 搜尋 | SYS-PRD-002 | SYS-SR-003 | FE-SR-010, FE-SR-011 | BE-SR-020 |
| UR-004 詳情 | SYS-PRD-001 | SYS-SR-004 | FE-SR-020, FE-SR-030 | BE-SR-021, BE-SR-030 |
| UR-005 AI 分析 | SYS-PRD-001 | SYS-SR-005, 006 | FE-SR-040 | BE-SR-040 |
| UR-006 標記管理 | SYS-PRD-001 | SYS-SR-007 | FE-SR-050 | BE-SR-050 |
| UR-007 專案管理 | SYS-PRD-003 | SYS-SR-008 | FE-SR-050, FE-SR-051 | BE-SR-050, BE-SR-051 |
| UR-008 導出 | SYS-PRD-003 | SYS-SR-009 | FE-SR-060 | BE-SR-060, BE-SR-061 |
| UR-009 UI/UX | SYS-PRD-004 | SYS-SR-010 | FE-SR-080, FE-SR-090~092 | BE：僅間接（效能/錯誤處理） |

> 註：FE-SR-xxx / BE-SR-xxx 僅為預留 ID，實際內容與鏈結將在 `02_FRONTEND_PRD_SR_SD.md` 與 `03_BACKEND_PRD_SR_SD.md` 中正式定義。

---

## 7. 與標準的對應說明（摘要）

- **ISO/IEC/IEEE 29148:2018**：
  - 4.x 節系統層 SR 清單 + 6.x 節追溯矩陣對應該標準對 SyRS/SRS 的核心要求。
  - UR / NFR 來源文件保持不變，本文件提供「結構化索引」與「ID 重整」。
- **IEC 62304:2006**：
  - 本文件扮演：
    - **軟體需求規格（SRS）頂層**：SYS-SR-xxx。
    - **軟體架構設計之索引**：指向 architecture / DB / API 舊文件。
  - 前端 / 後端層文件則承接更細的軟體項目 / 單元需求與設計。

---

*後續步驟：請參閱 `02_FRONTEND_PRD_SR_SD.md` 與 `03_BACKEND_PRD_SR_SD.md`，分別取得前端與後端層面的詳細 PRD / SR / SD 與串接方式。