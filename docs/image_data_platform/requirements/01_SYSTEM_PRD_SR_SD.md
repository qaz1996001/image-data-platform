# image_data_platform 系統層 PRD / SR / SD（System-Level PRD/SR/SD）

> 本文件為 image_data_platform 專案在新文檔結構下的**系統層 PRD / SR / SD 主文件**，  
> 後續將整合 `docs/old/requirements/`（使用者需求、功能規格等）與 `01_PROJECT_OVERVIEW.md` 中的相關內容。
>
> 範本結構來源：`templates/TEMPLATE_REQUIREMENTS_SYSTEM_PRD_SR_SD.md`。

---

**文件 ID**: IDP-REQ-SYS-PRD-SR-SD-IMG-001  
**標題**: image_data_platform — 系統層 PRD / SR / SD（整合舊文檔）  
**版本**: v1.0.0-Phase1  
**狀態**: Draft  
**建立日期**: YYYY-MM-DD  
**最後更新**: YYYY-MM-DD  
**作者**: [待填]  
**審核人**: [技術負責人 / 品質負責人 / 產品負責人]  
**適用階段**: Phase 1  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v0.1 | YYYY-MM-DD | [姓名] | 從模板建立，準備整合 docs/old 需求與規格 |

---

## 1. 範圍與系統概述（System Scope & Overview）

### 1.1 專案背景（Project Background）

image_data_platform 建立在 2020–2024 年 PAPA 資料與多源醫療檢查報告之上，  
目標是提供一個 **AI 驅動的報告篩選與管理平臺**，在 PACS 影像下載之前，先對報告做前處理與智慧分析，  
協助研究團隊高效率地篩選、組織臨床研究所需之檢查清單，同時確保資料隱私（本地 LLM、院內部署）。

### 1.2 專案目標（Project Goals）

- **Phase 1 目標（當前版本）**
  1. 整合多來源檢查報告（PAPA 表、Red Report、自訂 Excel/CSV）並統一管理。
  2. 透過本地 LLM（例如 `qwen2.5:7b`）執行報告內容理解與自動標註（高亮、分類、提取、評分）。
  3. 提供全文檢索與多維度篩選（檢查日期、類型、部門、ICD、AI 標註結果等）。
  4. 以「專案」為單位管理篩選結果，支援協作與統計。
  5. 匯出適用於 PACS 影像下載準備的報告清單（Excel/CSV/JSON）。

- **Phase 2 方向（未來擴充）**
  - 加入 DICOM 影像預覽與查看器整合。
  - 影像儲存（MinIO）與 Accssyn 自動同步。
  - 進一步的統計分析與可視化。

### 1.3 系統範圍（System Scope）

- **在範圍內（Phase 1）**
  - 報告資料導入、清洗與統一儲存。
  - 報告全文搜索與多條件篩選。
  - 本地 LLM 驅動的 AI 分析與標註。
  - 專案管理與報告集管理。
  - 報告清單匯出與基礎統計。

- **不在範圍內（Phase 1）**
  - DICOM 影像長期儲存與檢視（預留 Phase 2）。
  - 與外部 PACS / HIS / RIS 的雙向整合（Phase 2+）。
  - 大規模分散式部署與多機房高可用架構。

### 1.4 系統邊界（System Boundaries）

- **內部組件**
  - 前端 Web 應用（React + Ant Design）。
  - 後端 API 服務（目前為 FastAPI / PostgreSQL / Ollama，本變更 proposal 中另有 Django 遷移規劃）。
  - 報告與 AI 標註資料庫。
  - 專案與報告關聯管理。

- **外部介面**
  - 使用者透過瀏覽器操作 Web UI。
  - 系統管理者透過 Docker / CLI 進行部署與維運。

- **假設與依賴**
  - 院內具備 PostgreSQL 14+ 執行環境，且可提供足夠儲存與備份。
  - 可在院內網路中部署 Ollama 並下載對應模型。
  - 研究團隊可提供格式合理的 Excel/CSV 報告檔作為輸入。

---

## 2. 利害關係人與使用者（Stakeholders and Users）

> 本節內容已整合自舊版 `docs/old/requirements/USER_REQUIREMENTS.md`，作為後續詳細規格與追溯矩陣的基準。

### 2.1 利害關係人（Stakeholders）

| 角色               | 利益關聯 / 關心點                                               | 參與程度 |
|--------------------|------------------------------------------------------------------|---------|
| 醫學研究人員代表   | 報告篩選效率、AI 標記品質、專案管理是否符合實際研究工作流       | 高      |
| 數據分析師 / 生統  | 報告與標記資料的結構化程度、可導出性、與後續分析工具的相容性     | 中      |
| 系統管理員 / IT    | 部署方式（本地 / Docker）、維運成本、備份與監控、權限管理       | 高      |
| 資安 / 法遵        | 是否符合醫療資料與隱私規範、AI 推論是否完全在院內執行           | 高      |
| 產品負責人 / PO    | Phase 1 目標是否明確達成、是否為 Phase 2 打好擴充基礎           | 中      |
| 開發與測試團隊     | 需求是否具體可驗證、是否有清楚的 API / UI / 測試標準             | 高      |

### 2.2 使用者角色（User Roles）

| 使用者角色           | 說明                                                                 | 主要需求重點                           |
|----------------------|----------------------------------------------------------------------|----------------------------------------|
| 研究人員（Researcher） | 以研究專案為單位，從大量歷史檢查報告中篩選出符合條件的病例           | 報告搜索 / AI 標記 / 專案管理 / 匯出   |
| 數據分析師           | 針對已篩選之報告集進行統計與進一步分析                               | 結構化匯出、標記與欄位一致性           |
| 系統管理員（Admin）   | 管理帳號、系統設定與 LLM 參數，負責備份與監控                         | 簡化的系統管理界面與明確運維指引       |
| 產品 / 專案管理者     | 追蹤系統發展與使用成效，協調 Phase 1 / Phase 2 需求與排程             | 需求與實作之間清楚的追溯與驗收標準     |

---

## 3. 使用者需求（User Requirements, UR-xxx）

> 本章依照 `docs/image_data_platform/templates/TEMPLATE_REQUIREMENTS_SYSTEM_PRD_SR_SD.md` 的格式，直接以唯一的 `UR-xxx` 編號記錄各項使用者需求；第 3.1 節即為正式內容，避免重複 ID。

### 3.1 功能性使用者需求（Functional User Requirements）

#### UR-001: 使用者登入與基本認證
- **描述**：使用者（研究人員 / 管理員）需要透過帳號與密碼登入系統，以存取授權功能。
- **優先級**：高  
- **關鍵點**：
  - 支援以 Email + 密碼登入。
  - 登入成功後進入主儀表板頁面。
  - 使用 JWT 或等效機制維持 30 分鐘會話。
- **驗收標準**：
  - 正確憑證可以成功登入；錯誤憑證顯示明確錯誤訊息。
  - 會話在 30 分鐘內保持有效且受權限控制。
  - 密碼以安全演算法（例如 bcrypt）加密儲存。

#### UR-002: 檢查資料與報告導入
- **描述**：研究人員需要將外部來源的檢查記錄與報告（Excel / CSV / 資料庫）匯入系統，作為後續篩選與分析基礎。
- **優先級**：高  
- **關鍵點**：
  - 支援 Excel（.xlsx）與 CSV 檔匯入。
  - 提供欄位對應（Field Mapping）與基本資料驗證。
- **驗收標準**：
  - 匯入流程顯示預覽與進度，並回報成功 / 跳過 / 失敗筆數。
  - 匯入速度達到專案同意的目標（例如 ≥ 500 筆 / 分鐘）。

#### UR-003: 報告搜尋與篩選
- **描述**：研究人員需要在大量報告中，以關鍵字與多種條件快速搜尋和篩選記錄。
- **優先級**：高  
- **關鍵點**：
  - 關鍵字搜尋（患者 ID、姓名、報告內容等）。
  - 依檢查日期區間、檢查類型、科別、是否有 AI 標記等條件組合篩選。
- **驗收標準**：
  - 一般搜尋請求在 2 秒內回應。
  - 搜尋結果可分頁、支援依日期 / 相關度排序，且關鍵字高亮顯示。

#### UR-004: 報告詳細檢視
- **描述**：研究人員需要查看單一檢查報告的完整內容與歷史 AI 標記，以便進行判讀與決策。
- **優先級**：高  
- **關鍵點**：
  - 顯示患者與檢查基本資訊。
  - 顯示完整報告內容與相關診斷 / ICD 編碼（如有）。
  - 顯示報告對應的所有 AI 標記歷史。
- **驗收標準**：
  - 報告詳情頁在合理資料量下於 2 秒內載入完成。
  - 可從詳情頁快速啟動 AI 分析、加入專案、導出單一報告。

#### UR-005: 單筆與批次 AI 報告分析
- **描述**：研究人員需要使用本地 LLM 對報告內容進行分析與結構化標記（高亮、分類、提取、評分），支援單筆與批次操作。
- **優先級**：高（核心功能）  
- **關鍵點**：
  - 從報告詳情頁或搜尋結果中觸發 AI 分析。
  - 支援自訂提示詞與常用提示模板。
  - 回傳結構化 JSON 結果並持久化為 AI 標記。
- **驗收標準**：
  - 單筆分析時間一般情況下 < 5 秒；批次分析支援至少 3 個並行報告（可配置）。
  - 失敗案例有明確錯誤訊息（LLM 不可用 / 超時等）。

#### UR-006: AI 標記管理與基於標記的篩選
- **描述**：使用者需要檢視、編輯與刪除 AI 或人工建立的標記，並根據標記內容進行進階篩選與統計。
- **優先級**：高  
- **關鍵點**：
  - 檢視單一報告的所有標記，依標記類型 / 時間排序。
  - 手動調整標記內容與置信度、添加自訂標記。
  - 在搜尋條件中使用標記類型 / 內容 / 嚴重度進行篩選。
- **驗收標準**：
  - 標記 CRUD 操作皆可成功，且具基本變更歷史。
  - 基於標記的篩選結果與期望條件一致（抽樣檢查）。

#### UR-007: 專案建立與管理
- **描述**：研究人員需要以專案為單位維護候選報告清單，支援新增 / 編輯 / 刪除專案及其成員記錄。
- **優先級**：高（核心）  
- **關鍵點**：
  - 建立專案（名稱、描述、標籤等）。
  - 從搜尋結果或報告詳情批次加入 / 移除記錄。
  - 專案內列表支援篩選、排序與基本統計。
- **驗收標準**：
  - 專案 CRUD 與報告關聯操作可順利執行且關聯正確。
  - 專案列表與詳情頁載入時間在可接受範圍內（例如 < 2 秒）。

#### UR-008: 專案資料匯出
- **描述**：研究人員需要將專案內篩選後的報告清單匯出為 Excel / CSV / JSON，供 PACS 下載準備或後續分析使用。
- **優先級**：高  
- **關鍵點**：
  - 匯出格式：Excel（含報告摘要與 AI 標記摘要）、CSV、選用 JSON（含完整標記）。
  - 支援匯出整個專案或套用篩選條件後的子集。
- **驗收標準**：
  - 匯出檔案欄位完整、編碼正確（CSV UTF-8 不亂碼）。
  - 匯出效能達到預期（例如 1000 筆 / 分鐘 級別）。

#### UR-009: 簡潔高效的使用者介面（UI/UX）
- **描述**：系統介面需支援高效率操作與清晰資訊呈現，以滿足研究人員在大量資料上的日常操作需求。
- **優先級**：高（核心 UX）  
- **關鍵點**：
  - 扁平化設計、清楚視覺階層與關鍵操作入口。
  - 提供鍵盤快速鍵（如 Ctrl+K 搜尋、Ctrl+N 新建專案、Ctrl+A 啟動 AI 分析等）。
  - 對大列表採虛擬捲動與懶加載以確保流暢度。
- **驗收標準**：
  - 一般頁面載入時間 < 2 秒；1000+ 筆列表仍可流暢捲動。
  - 使用者訪談 / 問卷中之滿意度指標達成預期（例如 ≥ 80–85%）。

## 4. 系統需求規格（System Requirements Specification）

> 下列僅示意主要系統需求類別，詳細 SYS-PRD / SYS-SR 將在與 OpenSpec 規格對齊後分條補齊。

### 4.1 SYS-PRD: 系統產品需求（System Product Requirements）

#### SYS-PRD-001: 報告資料整合與管理
- 系統 **SHALL** 支援從多種來源（PAPA 表、Red Report、自訂 Excel/CSV）匯入報告資料，並以統一結構儲存。
- 系統 **SHALL** 在匯入時執行欄位驗證與基本資料清洗。

#### SYS-PRD-002: AI 輔助分析能力
- 系統 **SHALL** 透過本地 LLM 提供至少四種標註能力：高亮、分類、提取、評分。
- 系統 **SHALL** 支援單筆與批次報告分析。

#### SYS-PRD-003: 報告檢索與專案管理
- 系統 **SHALL** 提供全文搜索與多維度篩選介面。
- 系統 **SHALL** 允許使用者將報告加到一個或多個專案中，並能匯出該專案報告清單。

### 4.2 SYS-SR: 系統軟體需求（System Software Requirements）

> 本節從舊版 `docs/old/requirements/FUNCTIONAL_SPECIFICATION.md` 中的功能規格（FS-xxx）與相關模組說明  
> 萃取出 Phase 1 必須滿足的系統軟體需求，並與第 3 章 UR-xxx 及 4.1 SYS-PRD-001~003 保持追溯。

#### SYS-SR-010: 認證 API 與會話管理
- **描述**：系統 **SHALL** 提供基於 JWT 的登入與當前使用者查詢 API（對應 `/auth/login`、`/auth/me`），並確保密碼以安全演算法（例如 bcrypt）儲存。  
- **對應 UR**：UR-001（使用者登入與基本認證）  
- **來源功能規格**：FS-AUTH-001（登入功能）、舊 Functional Specification 第 2.1 節  
- **驗證方式**：API 測試 / 安全測試  
- **追溯關係**：
  - Traces to: UR-001
  - Traced by: SYS-SD-001 (前後端分離三層架構設計), SYS-SD-002 (前後端分離架構決策), SYS-SD-007 (RESTful API 設計)  
##### Scenario 1: 成功登入
- **GIVEN** 使用者提供正確的 Email 與密碼  
- **WHEN** 呼叫 `/auth/login`  
- **THEN** 系統 SHALL 回傳有效 JWT，並可透過 `/auth/me` 取得當前使用者資訊。  
##### Scenario 2: 登入失敗與逾時
- **GIVEN** 使用者提供錯誤憑證或使用過期的 JWT  
- **WHEN** 呼叫 `/auth/login` 或受保護 API  
- **THEN** 系統 SHALL 回傳 401 錯誤與明確錯誤訊息，且不洩漏敏感細節。

#### SYS-SR-020: 檢查資料與報告匯入服務
- **描述**：系統 **SHALL** 提供匯入預覽與執行 API（對應 `/import/preview`、`/import/execute`），支援 Excel/CSV 檔案解析、欄位對應、資料驗證與批次寫入資料庫。  
- **對應 UR**：UR-002（檢查資料與報告導入）、UR-003（報告搜尋與篩選，依賴正確資料）  
- **來源功能規格**：FS-IMPORT-001（Excel/CSV 導入功能）  
- **驗證方式**：API 測試 / 匯入壓力測試  
- **追溯關係**：
  - Traces to: UR-002, UR-003
  - Traced by: SYS-SD-001 (前後端分離三層架構設計), SYS-SD-004 (PostgreSQL + JSONB 混合儲存設計), SYS-SD-005 (子系統劃分設計), SYS-SD-007 (RESTful API 設計)  
##### Scenario 1: 匯入預覽
- **GIVEN** 使用者上傳格式正確的 Excel/CSV 檔案  
- **WHEN** 呼叫 `/import/preview`  
- **THEN** 系統 SHALL 回傳預覽資料、來源欄位清單與建議欄位對應。  
##### Scenario 2: 匯入執行與錯誤處理
- **GIVEN** 使用者確認欄位對應並呼叫 `/import/execute`  
- **WHEN** 有重複記錄或資料格式錯誤  
- **THEN** 系統 SHALL 跳過或標記重複資料，並回傳成功 / 跳過 / 失敗筆數與前若干筆錯誤說明。

#### SYS-SR-030: 報告搜尋與詳情 API
- **描述**：系統 **SHALL** 實作報告搜尋與詳情查詢 API（例如 `/reports/search`、`/reports/{report_id}`），支援關鍵字與多條件組合篩選，並回傳分頁結果與詳細內容。  
- **對應 UR**：UR-003（報告搜尋與篩選）、UR-004（報告詳細檢視）  
- **來源功能規格**：FS-SEARCH-001（高級搜索 API）、報告模組說明  
- **驗證方式**：API 測試 / 效能測試  
- **追溯關係**：
  - Traces to: UR-003, UR-004
  - Traced by: SYS-SD-001 (前後端分離三層架構設計), SYS-SD-004 (PostgreSQL + JSONB 混合儲存設計), SYS-SD-005 (子系統劃分設計), SYS-SD-006 (資料模型設計), SYS-SD-007 (RESTful API 設計)  
##### Scenario 1: 多條件搜尋
- **GIVEN** 使用者指定關鍵字與檢查日期區間  
- **WHEN** 呼叫 `/reports/search`  
- **THEN** 系統 SHALL 回傳符合條件的分頁結果，並支援依日期或相關度排序。  
##### Scenario 2: 報告詳情查詢
- **GIVEN** 報告已存在且未被刪除  
- **WHEN** 呼叫 `/reports/{report_id}`  
- **THEN** 系統 SHALL 回傳患者資訊、檢查資訊、完整報告內容與關聯 ICD 編碼（如有）。

#### SYS-SR-040: AI 報告分析與標記管理 API
- **描述**：系統 **SHALL** 提供 AI 分析 API（例如 `/ai/analyze`、`/ai/batch-analyze`）與標記管理 API（`/ai/annotations/{report_id|annotation_id}`），透過本地 Ollama 服務呼叫指定模型（如 `qwen2.5:7b`），並以結構化 JSON 形式儲存標記。  
- **對應 UR**：UR-005（AI 報告分析）、UR-006（AI 標記管理與基於標記的篩選）  
- **來源功能規格**：FS-AI-001（AI Service Layer）、FS-AI-002（AI Analysis API）  
- **驗證方式**：API 測試 / 效能與錯誤處理測試  
- **追溯關係**：
  - Traces to: UR-005, UR-006
  - Traced by: SYS-SD-001 (前後端分離三層架構設計), SYS-SD-003 (本地 LLM 部署設計), SYS-SD-004 (PostgreSQL + JSONB 混合儲存設計), SYS-SD-005 (子系統劃分設計), SYS-SD-006 (資料模型設計), SYS-SD-007 (RESTful API 設計)  
##### Scenario 1: 單筆分析成功
- **GIVEN** 報告內容存在且 Ollama 服務可用  
- **WHEN** 呼叫 `/ai/analyze` 並提供報告 ID、使用者提示詞與標記類型  
- **THEN** 系統 SHALL 觸發 LLM 分析，解析 JSON 結果並建立一筆 AI 標記記錄。  
##### Scenario 2: 批次分析與錯誤處理
- **GIVEN** 使用者提交不超過 50 筆報告 ID 列表  
- **WHEN** 呼叫 `/ai/batch-analyze`  
- **THEN** 系統 SHALL 以受控併發數處理各報告，對失敗的個別報告記錄錯誤原因，且不影響其餘成功結果。  
##### Scenario 3: 標記查詢與編輯
- **GIVEN** 報告已存在多筆 AI 標記  
- **WHEN** 呼叫 `/ai/annotations/{report_id}` 查詢，或對特定 `annotation_id` 執行更新 / 刪除  
- **THEN** 系統 SHALL 回傳最新標記清單，並正確持久化使用者對標記內容的修改。

#### SYS-SR-050: 專案管理與報告關聯 API
- **描述**：系統 **SHALL** 提供專案 CRUD 與報告關聯管理 API（例如 `/projects`、`/projects/{project_id}`、`/projects/{project_id}/reports`），以支援專案內報告清單維護與統計。  
- **對應 UR**：UR-007（專案建立與管理）、UR-008（專案資料匯出，依賴正確專案內容）  
- **來源功能規格**：FS-PROJECT-001（項目 CRUD）、專案模組設計段落  
- **驗證方式**：API 測試 / 資料一致性測試  
- **追溯關係**：
  - Traces to: UR-007, UR-008
  - Traced by: SYS-SD-001 (前後端分離三層架構設計), SYS-SD-005 (子系統劃分設計), SYS-SD-006 (資料模型設計), SYS-SD-007 (RESTful API 設計)  
##### Scenario 1: 建立與查詢專案
- **GIVEN** 使用者提供有效的專案名稱與基本資訊  
- **WHEN** 呼叫 `POST /projects`  
- **THEN** 系統 SHALL 建立一筆專案並可透過 `GET /projects` 或 `GET /projects/{project_id}` 正確查詢。  
##### Scenario 2: 專案與報告關聯維護
- **GIVEN** 報告與專案皆存在  
- **WHEN** 呼叫 `POST /projects/{project_id}/reports` 新增報告 ID 清單  
- **THEN** 系統 SHALL 為尚未關聯的報告建立關聯記錄，避免重複插入，並在專案詳情中正確反映報告數量。

#### SYS-SR-060: 專案資料匯出 API
- **描述**：系統 **SHALL** 提供專案資料匯出 API（例如 `/projects/{project_id}/export`），支援至少 Excel 與 CSV 格式，並可選擇輸出 AI 標記摘要或詳細內容。  
- **對應 UR**：UR-008（專案資料匯出）  
- **來源功能規格**：Functional Specification 第 3.3 節匯出相關說明（含導出格式與欄位需求）  
- **驗證方式**：API 測試 / 匯出效能與內容驗證  
- **追溯關係**：
  - Traces to: UR-008
  - Traced by: SYS-SD-001 (前後端分離三層架構設計), SYS-SD-005 (子系統劃分設計), SYS-SD-007 (RESTful API 設計)  
##### Scenario 1: 匯出完整專案
- **GIVEN** 專案內已有多筆報告與 AI 標記  
- **WHEN** 呼叫 `GET /projects/{project_id}/export?format=xlsx`  
- **THEN** 系統 SHALL 產生含所有報告欄位與 AI 標記摘要的 Excel 檔案，並提供下載。  
##### Scenario 2: 匯出篩選後子集
- **GIVEN** 使用者在前端對專案內報告套用了搜尋 / 篩選條件  
- **WHEN** 以相同篩選條件呼叫匯出 API（由前端傳入條件參數）  
- **THEN** 系統 SHALL 僅匯出符合條件的報告集合，且欄位與編碼正確。

---

## 5. 系統設計（System Design, SYS-SD-xxx）

> 本節概述系統層級設計並追溯至詳細架構文件，完整設計內容請參閱：
> - **系統架構設計**: [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md)
> - **資料庫設計**: 見 [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 4 章
> - **API 設計**: 見 [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章

### 5.1 系統架構概述

Phase 1 採用**前後端分離三層架構**:

- **前端層 (Frontend)**
  - React 18 + TypeScript + Ant Design v5
  - 透過 REST API 與後端通訊
  - 支援報告搜尋、AI 分析觸發、專案管理與匯出操作
  
- **後端層 (Backend)**
  - FastAPI (Python) / 未來遷移至 Django + Django Ninja
  - 提供認證、報告 CRUD、AI 分析、專案管理與匯出 API
  - 對接 PostgreSQL 資料庫與 Ollama AI 服務
  
- **資料層 (Data & AI)**
  - PostgreSQL 14+ (5 張核心表: users, reports, ai_annotations, projects, project_reports)
  - Ollama (本地 LLM 部署, 模型: qwen2.5:7b)

**追溯性**: 
- 本架構對應 SYS-PRD-001 (報告資料整合)、SYS-PRD-002 (AI 輔助分析)、SYS-PRD-003 (專案管理)
- 滿足 NFR-001~NFR-009 之效能、可用性、安全性與可維護性需求

### 5.2 系統設計項目（System Design Items）

> 系統設計項目（SYS-SD-xxx）是具體的設計決策，每個 SYS-SD 必須對應至少一個 SYS-SR。

#### SYS-SD-001: 前後端分離三層架構設計
**描述**：系統採用前後端分離的三層架構，包含前端層（React）、後端層（FastAPI/Django）和資料層（PostgreSQL + Ollama）。

**來源 SYS-SR**：SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060  
**追溯關係**：
- Traces to: SYS-PRD-001, SYS-PRD-002, SYS-PRD-003, SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060
- Traced by: FE-SD-xxx (前端設計), BE-SD-xxx (後端設計) - 詳見子系統文檔
- Verified by: 架構審查、系統測試

**設計內容**：
- 前端層：React 18 + TypeScript + Ant Design v5，透過 REST API 與後端通訊
- 後端層：FastAPI (Python)，提供認證、報告 CRUD、AI 分析、專案管理與匯出 API
- 資料層：PostgreSQL 14+ (5 張核心表)，Ollama (本地 LLM 部署)

---

### 5.3 關鍵設計決策 (ADR)

#### SYS-SD-002: 前後端分離架構決策 (ADR-001)
**描述**：採用前後端分離架構，前端 (React) 與後端 (FastAPI/Django) 完全解耦，透過 REST API 通訊。

**來源 SYS-SR**：SYS-SR-010, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060  
**追溯關係**：
- Traces to: SYS-SR-010, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060
- Traced by: FE-SD-xxx (前端設計), BE-SD-xxx (後端 API 設計)
- Verified by: 架構審查、API 契約驗證

**設計決策**:
- **決策**: 前端 (React) 與後端 (FastAPI/Django) 完全解耦，透過 REST API 通訊
- **理由**: 
  - 允許前後端獨立開發與部署
  - 未來可支援多種前端 (Web / Mobile / Desktop)
  - 符合現代 Web 應用最佳實踐
- **影響**: 需明確定義 API 契約，前後端需協調 API 版本管理

---

#### SYS-SD-003: 本地 LLM 部署設計 (ADR-002)
**描述**：使用 Ollama 在院內環境部署 LLM，不依賴雲端 AI 服務。

**來源 SYS-SR**：SYS-SR-040  
**追溯關係**：
- Traces to: SYS-SR-040
- Traced by: BE-SD-xxx (AI 服務層設計)
- Verified by: 安全審查、效能測試

**設計決策**:
- **決策**: 使用 Ollama 在院內環境部署 LLM，不依賴雲端 AI 服務
- **理由**: 
  - 患者報告涉及敏感醫療資訊，不可傳送至公有雲
  - 本地部署確保資料安全與隱私合規
  - 成本可控，無需支付 API 調用費用
- **影響**: 需準備足夠 GPU 資源，並建立模型更新與管理流程

---

#### SYS-SD-004: PostgreSQL + JSONB 混合儲存設計 (ADR-003)
**描述**：使用 PostgreSQL 關聯式資料庫，並以 JSONB 欄位儲存彈性 AI 標註結構。

**來源 SYS-SR**：SYS-SR-020, SYS-SR-030, SYS-SR-040  
**追溯關係**：
- Traces to: SYS-SR-020, SYS-SR-030, SYS-SR-040
- Traced by: DB-xxx (資料庫設計) - 詳見架構文檔第 4 章
- Verified by: 資料庫設計審查、效能測試

**設計決策**:
- **決策**: 使用 PostgreSQL 關聯式資料庫，並以 JSONB 欄位儲存彈性 AI 標註結構
- **理由**: 
  - 報告基本資訊為結構化資料，適合關聯式模型
  - AI 標註結果結構彈性，不同分析類型可能產生不同 JSON 結構
  - PostgreSQL JSONB 提供高效查詢與索引能力
- **影響**: 需在應用層定義 JSON Schema，確保資料品質

---

### 5.4 子系統與模組劃分

#### SYS-SD-005: 子系統劃分設計
**描述**：系統劃分為 6 個主要子系統：Authentication、Data Ingestion、Report Management、AI Analysis、Project Management、Data Export。

**來源 SYS-SR**：SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060  
**追溯關係**：
- Traces to: SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060
- Traced by: FE-SR-xxx, BE-SR-xxx (子系統需求) - 詳見子系統文檔
- Verified by: 架構審查、模組整合測試

**子系統劃分**：

| 子系統 | 職責 | 對應 SYS-SR | 關鍵技術 |
|--------|------|-------------|----------|
| Authentication | 使用者登入、JWT 驗證、會話管理 | SYS-SR-010 | JWT, bcrypt |
| Data Ingestion | Excel/CSV 匯入、欄位映射、資料驗證 | SYS-SR-020 | Pandas, openpyxl |
| Report Management | 報告 CRUD、全文搜尋、條件篩選 | SYS-SR-030 | PostgreSQL FTS, GIN Index |
| AI Analysis | 對接 Ollama 進行報告分析、標註管理 | SYS-SR-040 | Ollama HTTP API, asyncio |
| Project Management | 專案 CRUD、報告關聯、統計彙總 | SYS-SR-050 | SQLAlchemy ORM |
| Data Export | Excel/CSV/JSON 匯出、格式化輸出 | SYS-SR-060 | openpyxl, pandas |

---

#### SYS-SD-006: 資料模型設計
**描述**：Phase 1 採用 5 張核心資料表，定義使用者、報告、AI 標註、專案及其關聯關係。

**來源 SYS-SR**：SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050  
**追溯關係**：
- Traces to: SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050
- Traced by: DB-xxx (資料庫 Schema 設計) - 詳見架構文檔第 4 章
- Verified by: 資料庫設計審查、資料一致性測試

**資料模型**：

Phase 1 採用 **5 張核心表**:

1. **users**: 使用者帳號與角色 (admin / researcher)
2. **reports**: 檢查報告資料 (含患者資訊、報告內容、全文索引)
3. **ai_annotations**: AI 標註結果 (JSONB 儲存彈性結構)
4. **projects**: 研究專案 (名稱、描述、狀態、標籤)
5. **project_reports**: 專案與報告多對多關聯表

**ER 關係**:
```
users ──< reports ──< ai_annotations
  └──< projects ──< project_reports >── reports
```

完整 Schema、索引與範例資料請參閱 [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 4 章。

---

### 5.6 API 設計摘要

Phase 1 提供 **6 大 API 模組**:

1. **認證 API** (`/api/v1/auth/*`)
   - POST `/login`, GET `/me`, POST `/logout`
   
2. **匯入 API** (`/api/v1/import/*`)
   - POST `/preview`, POST `/execute`
   
3. **報告 API** (`/api/v1/reports/*`)
   - GET `/search`, GET `/{id}`, POST `/`, PUT `/{id}`, DELETE `/{id}`
   
4. **AI 分析 API** (`/api/v1/ai/*`)
   - POST `/analyze`, POST `/batch-analyze`, GET `/annotations/{report_id}`
   
5. **專案 API** (`/api/v1/projects/*`)
   - CRUD 操作 + 報告關聯管理
   
6. **匯出 API** (`/api/v1/export/*`)
   - POST `/project`, POST `/search`

完整 API 規範 (請求/響應格式、狀態碼、錯誤處理) 請參閱 [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章。

#### SYS-SD-007: RESTful API 設計
**描述**：系統提供 6 大 API 模組，採用 RESTful 設計原則，支援認證、匯入、報告、AI 分析、專案管理和匯出功能。

**來源 SYS-SR**：SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060  
**追溯關係**：
- Traces to: SYS-SR-010, SYS-SR-020, SYS-SR-030, SYS-SR-040, SYS-SR-050, SYS-SR-060
- Traced by: API-xxx (API 端點設計) - 詳見架構文檔第 5 章
- Verified by: API 契約測試、整合測試

**API 模組劃分**：

1. **認證 API** (`/api/v1/auth/*`): POST `/login`, GET `/me`, POST `/logout`
2. **匯入 API** (`/api/v1/import/*`): POST `/preview`, POST `/execute`
3. **報告 API** (`/api/v1/reports/*`): GET `/search`, GET `/{id}`, POST `/`, PUT `/{id}`, DELETE `/{id}`
4. **AI 分析 API** (`/api/v1/ai/*`): POST `/analyze`, POST `/batch-analyze`, GET `/annotations/{report_id}`
5. **專案 API** (`/api/v1/projects/*`): CRUD 操作 + 報告關聯管理
6. **匯出 API** (`/api/v1/export/*`): POST `/project`, POST `/search`

完整 API 規範請參閱 [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章。

---

## 6. 追溯矩陣（Traceability Matrix）

> **權威來源指向**：完整的追溯性矩陣請參閱 [`traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md)。  
> 本節提供簡化的需求追溯摘要，用於快速查閱 UR → SYS-PRD → SYS-SR 之間的對應關係。

### 6.1 UR 中心追溯表（User Requirements Traceability）

| UR ID | UR 標題 | 對應 SYS-PRD | 對應 SYS-SR | 對應 SYS-SD | 相關 FE-SR | 相關 BE-SR |
|-------|---------|-------------|------------|-------------|-----------|-----------|
| UR-001 | 使用者登入與基本認證 | SYS-PRD-004 | SYS-SR-010 | SYS-SD-001, SYS-SD-002, SYS-SD-007 | FE-SR-001, FE-SR-002 | BE-SR-001, BE-SR-002 |
| UR-002 | 檢查資料與報告導入 | SYS-PRD-002, SYS-PRD-001 | SYS-SR-020 | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-007 | FE-SR-010 (匯入 UI) | BE-SR-010, BE-SR-011 |
| UR-003 | 報告搜尋與篩選 | SYS-PRD-002 | SYS-SR-030 | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-010, FE-SR-011 | BE-SR-020 |
| UR-004 | 報告詳細檢視 | SYS-PRD-001, SYS-PRD-002 | SYS-SR-030 | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-020, FE-SR-030 | BE-SR-021, BE-SR-030, BE-SR-031 |
| UR-005 | AI 報告分析 | SYS-PRD-002 | SYS-SR-040 | SYS-SD-001, SYS-SD-003, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-040 | BE-SR-040, BE-SR-041 |
| UR-006 | AI 標記管理 | SYS-PRD-002 | SYS-SR-040 | SYS-SD-001, SYS-SD-003, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-030, FE-SR-040, FE-SR-041 | BE-SR-030, BE-SR-031, BE-SR-040, BE-SR-041 |
| UR-007 | 專案建立與管理 | SYS-PRD-003 | SYS-SR-050 | SYS-SD-001, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-050, FE-SR-051 | BE-SR-050, BE-SR-051 |
| UR-008 | 專案資料匯出 | SYS-PRD-003 | SYS-SR-060 | SYS-SD-001, SYS-SD-005, SYS-SD-007 | FE-SR-060 | BE-SR-060, BE-SR-061 |
| UR-009 | 簡潔高效的 UI/UX | SYS-PRD-004 | SYS-SR-010, SYS-SR-NFR-001, SYS-SR-NFR-004, SYS-SR-NFR-005 | SYS-SD-001, SYS-SD-002 | FE-SR-080, FE-SR-090~092 | BE-SR-NFR-001~005 |

**說明**：
- **FE-SR**：前端層軟體需求（Frontend Software Requirements），詳見 [`02_FRONTEND_PRD_SR_SD.md`](02_FRONTEND_PRD_SR_SD.md)
- **BE-SR**：後端層軟體需求（Backend Software Requirements），詳見 [`03_BACKEND_PRD_SR_SD.md`](03_BACKEND_PRD_SR_SD.md)
- 上表為簡化版，完整追溯至設計/程式碼/測試層級的矩陣請參閱 [`../traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md)

### 6.2 SYS-PRD 中心追溯表（Product Requirements Traceability）

| SYS-PRD ID | SYS-PRD 標題 | 來源 UR | 衍生 SYS-SR | 說明 |
|-----------|------------|---------|------------|------|
| SYS-PRD-001 | 報告資料整合與管理 | UR-002, UR-003, UR-004, UR-006 | SYS-SR-020, SYS-SR-030, SYS-SR-040 | 支援多來源報告匯入、儲存、檢索與標註管理 |
| SYS-PRD-002 | AI 輔助分析能力 | UR-003, UR-004, UR-005, UR-006 | SYS-SR-030, SYS-SR-040 | 本地 LLM 提供四種標註能力（高亮/分類/提取/評分） |
| SYS-PRD-003 | 報告檢索與專案管理 | UR-007, UR-008 | SYS-SR-050, SYS-SR-060 | 專案 CRUD 與報告關聯管理、多格式匯出 |
| SYS-PRD-004 | 簡潔高效的研究者工作介面 | UR-001, UR-009, NFR-004, NFR-005 | SYS-SR-010, SYS-SR-NFR-001, SYS-SR-NFR-004, SYS-SR-NFR-005 | 認證機制、鍵盤快捷鍵、響應式 UI |

### 6.3 NFR 追溯表（Non-Functional Requirements Traceability）

| NFR ID | NFR 類別 | 對應 SYS-SR-NFR | 驗證方式 | 說明 |
|--------|---------|----------------|---------|------|
| NFR-001 | 效能：響應時間 | SYS-SR-NFR-001 | 效能測試 | API < 1s, 搜尋 < 2s, AI < 5s |
| NFR-002 | 效能：吞吐量 | SYS-SR-NFR-001 | 壓力測試 | 10+ 並發使用者，500 筆/分匯入 |
| NFR-003 | 效能：資料容量 | SYS-SR-NFR-002 | 容量測試 | 100k+ 報告，500k+ AI 標記 |
| NFR-004 | 可用性：系統可用性 | SYS-SR-NFR-003 | 監控與可用性測試 | 95% 可用性，< 1 分鐘啟動 |
| NFR-005 | 可用性：UI 可用性 | SYS-SR-NFR-004, SYS-SR-NFR-005 | 使用性測試 | 核心操作 ≤ 3 步，清楚錯誤提示 |
| NFR-006 | 安全：認證授權 | SYS-SR-NFR-004 | 安全測試 | JWT 30 分鐘，密碼複雜度，RBAC |
| NFR-007 | 安全：資料保護 | SYS-SR-NFR-004 | 安全審計 | HTTPS, bcrypt, 日誌脫敏 |
| NFR-008 | 可維護性：程式碼品質 | SYS-SR-NFR-005 | 程式碼審查、靜態分析 | PEP 8, ESLint, 70% 測試覆蓋率 |
| NFR-009 | 可維護性：部署配置 | SYS-SR-NFR-005 | 部署測試 | Docker Compose, 環境變數, 結構化日誌 |

### 6.4 追溯性維護原則

#### 向下追溯（Forward Traceability）
- 每個 UR 必須追溯到至少一個 SYS-PRD
- 每個 SYS-PRD 必須追溯到至少一個 SYS-SR
- 每個 SYS-SR 必須追溯到至少一個 SYS-SD（系統設計）
- 每個 SYS-SD 必須追溯到至少一個 FE-SR 或 BE-SR（子系統需求）
- 每個 SR 必須追溯到設計、程式碼與測試

#### 向上追溯（Backward Traceability）
- 每個 SYS-SR 必須追溯到至少一個 SYS-PRD 或 UR
- 每個 SYS-SD 必須追溯到至少一個 SYS-SR
- 每個 FE-SR / BE-SR 必須追溯到至少一個 SYS-SD 或 SYS-SR
- 每個設計/程式碼/測試必須追溯到對應 SR

#### 追溯性更新流程
1. **新增需求時**：
   - 建立向上追溯連結（指向來源需求）
   - 更新上游需求的向下追溯連結
   - 同步更新追溯矩陣

2. **修改需求時**：
   - 識別所有受影響的下游項目（透過追溯矩陣）
   - 同步更新下游需求/設計/程式碼
   - 更新追溯矩陣

3. **刪除需求時**：
   - 檢查是否有下游依賴（透過追溯矩陣）
   - 處理孤立的下游項目（重新映射或刪除）
   - 從追溯矩陣中移除

### 6.5 與 IEC 62304 合規性

本追溯矩陣滿足 IEC 62304:2006 以下要求：

- **§5.2.6 Requirements Traceability**：✅ 建立 UR → SYS-SR → SYS-SD → FE/BE-SR 雙向追溯
- **§5.3.5 Architecture Verification**：✅ 追溯至 [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md)
- **§5.4.2 Design Traceability**：✅ 設計元件追溯至 SR（見各 SR 文件第 5 章）
- **§5.5.5 Software Unit Verification**：✅ 測試追溯至 SR（待補充測試文件）

詳細的追溯性管理指南與 IEC 62304 合規說明請參閱：
- [`traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md)
- [`regulations/IEC-62304/traceability-matrix.md`](../regulations/IEC-62304/traceability-matrix.md)（舊參考文件）

---

## 7. 非功能性需求（Non-Functional Requirements）

> 本節整合舊版 `USER_REQUIREMENTS.md` 中的 NFR-001 ~ NFR-009，並按類別彙總。

### 7.1 效能需求（Performance）— NFR-001, NFR-002, NFR-003

- **NFR-001: 響應時間**
  - API 一般請求 90% 應在 1 秒內完成。
  - 搜尋請求 90% 應在 2 秒內完成。
  - 單筆 AI 分析預期在 5 秒內完成。
  - 主要頁面載入時間應控制在 2 秒以內（在 Phase 1 目標資料量下）。

- **NFR-002: 吞吐量**
  - 支援至少 10 名並行使用者（小團隊場景）。
  - 匯入速度達到 ≥ 500 筆 / 分鐘（依實際硬體可調整）。
  - AI 分析支援 3–5 筆報告並發處理。
  - 專案匯出速度達到 ≥ 1000 筆 / 分鐘級別。

- **NFR-003: 資料容量**
  - 支援 ≥ 100,000 筆檢查記錄與報告。
  - 支援 ≥ 500,000 筆 AI 標記。
  - 支援 ≥ 1,000 個專案記錄。

### 7.2 可用性與使用性（Availability & Usability）— NFR-004, NFR-005

- **NFR-004: 系統可用性**
  - Phase 1 目標環境（開發 / 測試）年可用性至少 95%。
  - Docker Compose 方式啟動時間預期 < 1 分鐘。
  - 系統 **SHALL** 提供每日自動備份機制或等效運維流程。

- **NFR-005: 使用者介面可用性**
  - 主要支援桌面端（Chrome / Edge 現代版本），解析度 1920x1080 為優先。
  - 核心操作路徑（例如搜尋 → 篩選 → 新建專案 → 匯出）步驟數應 ≤ 3–4 步。
  - 錯誤訊息必須清楚指出問題與建議行動（例如重新登入 / 檢查匯入檔格式等）。

### 7.3 安全性（Security）— NFR-006, NFR-007

- **NFR-006: 認證與授權**
  - 密碼長度至少 8 碼，並符合基本複雜度要求（可於實作層具體化）。
  - 會話逾時時間預設 30 分鐘，逾時後須重新登入。
  - 角色與權限模型至少區分一般使用者與系統管理員。

- **NFR-007: 資料與隱私保護**
  - 所有敏感資料傳輸在正式環境 **SHALL** 使用 HTTPS。
  - 密碼等敏感資訊 **SHALL** 以安全演算法（例如 bcrypt）儲存。
  - 日誌中 **SHALL NOT** 記錄完整患者個資與報告全文，只保留必要追蹤資訊。

### 7.4 可維護性與部署（Maintainability & Deployability）— NFR-008, NFR-009

- **NFR-008: 程式碼品質與測試**
  - Python / TypeScript 程式碼應符合專案選定之靜態檢查與風格規範（如 PEP 8、ESLint）。
  - 核心功能（搜尋、AI 分析、專案管理、匯出）之單元測試覆蓋率預期 ≥ 70%。
  - 關鍵業務邏輯與風險點 **SHALL** 有足夠的註解與設計說明。

- **NFR-009: 部署與組態管理**
  - 系統 **SHALL** 以 Docker / Docker Compose 為主要部署方式。
  - 組態（資料庫連線、LLM 端點、權限設定等）應以環境變數或集中配置管理。
  - 應提供健康檢查端點與基礎日誌 / 監控整合能力，以支援院內既有監控系統。

---

## 8. 風險與限制（Risks and Constraints）

---

## 9. 驗收標準（Acceptance Criteria）

---

## 10. 附錄（Appendix）

### 10.1 名詞與縮寫對照（Glossary）

| 縮寫 / 名詞 | 全名 / 說明 |
|-------------|------------|
| **IDP** | *image_data_platform* 專案代碼（Imaging Data Platform）。 |
| **REQ** | Requirements（需求類文件）。 |
| **SYS** | System-level（系統層級）。 |
| **PRD** | Product Requirements Document（產品需求文件）。 |
| **SR** | System Requirements（系統需求）。 |
| **SD** | System Design（系統設計）。 |
| **IDP-REQ-SYS-PRD-SR-SD-IMG-001** | image_data_platform 專案之「系統層 PRD / SR / SD」文件 ID，表示：專案代碼（IDP）+ 需求文件（REQ）+ 系統層（SYS）+ 產品需求（PRD）+ 系統需求（SR）+ 系統設計（SD）+ 專案標識（IMG）+ 編號（001）。 |
| **UR** | User Requirement（使用者需求）。 |
| **SYS-SR** | System Software Requirement / System Requirement（系統軟體 / 系統需求）。 |
| **NFR** | Non-Functional Requirement（非功能性需求）。 |
| **AI** | Artificial Intelligence（人工智慧），本專案多指用於報告理解與標註的模型。 |
| **LLM** | Large Language Model（大型語言模型），例如 `qwen2.5:7b`。 |
| **PACS** | Picture Archiving and Communication System，醫療影像儲存與通訊系統。 |
| **PAPA** | 2020–2024 年既有的報告資料來源表（專案內部命名），做為報告資料匯入的主要來源之一。 |
| **DICOM** | Digital Imaging and Communications in Medicine，醫療影像與通訊標準。 |
| **MinIO** | 物件儲存服務（S3 相容），預計於 Phase 2 用於影像檔案儲存。 |
| **Accssyn** | 院內影像同步 / 檔案同步服務（專案依賴的外部系統，詳細規格另見規範文件）。 |


