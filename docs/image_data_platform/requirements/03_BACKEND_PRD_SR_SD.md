# 03_BACKEND_PRD_SR_SD — 後端層 PRD / SR / SD

**文件 ID**: IDP-REQ-BE-PRD-SR-SD-001  
**標題**: image_data_platform Phase 1 — 後端（API / DB / AI Service）需求與設計  
**版本**: v2.1.0-Phase1  
**狀態**: Active  
**建立日期**: 2025-11-24  
**最後更新**: 2025-12-26  
**作者 / 審核人**: （待填）

> 本文件聚焦於 **後端應用與資料庫**：
> - API 層（Django Ninja 樣式 API）、
> - 模組化架構（study / project / report / common）、
> - 商業邏輯與服務層、
> - PostgreSQL 資料庫（reports / ai_annotations / projects / project_reports / users）、
> - 與本地 LLM（Ollama）整合的 AI 分析服務。
>
> **重要**: 自 v2.0 起，後端採用模組化架構。
>
> 內容主要整理自舊版需求與架構文檔。

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v2.0.0 | 2025-11-25 | [姓名] | 從舊文檔遷移並更新 |
| v2.1.0 | 2025-12-26 | AI Agent | 遷移至新文檔結構 `docs/image_data_platform/requirements/` |

---

## 1. 後端範圍與與系統層對應

### 1.1 後端責任邊界

後端負責：
- 提供所有前端所需的 REST API 與驗證機制。
- 管理資料庫 schema、資料一致性與交易處理。
- 封裝對 Ollama LLM 的呼叫與錯誤處理，將結果轉換為結構化 JSON 並儲存。
- 實作匯入 / 匯出 / 搜尋 / 專案管理等核心業務流程。

### 1.2 對應系統層需求

- 系統 PRD 來源：[`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md) 中的：
  - SYS-PRD-001 報告資料整合與管理
  - SYS-PRD-002 AI 輔助分析能力
  - SYS-PRD-003 報告檢索與專案管理
- 系統 SR：SYS-SR-010 ~ SYS-SR-060 與 NFR-001 ~ 005。

---

## 2. 後端層 PRD（BE-PRD）

> 本節將系統層 PRD 具體化為後端層產品需求 BE-PRD-xxx，說明後端在每一項系統需求中的責任與邊界，並與前端層 PRD 建立對應關係。

### 2.1 BE-PRD 清單

#### BE-PRD-001 使用者驗證與權限控制

- **描述**：後端必須提供：
  - 基於 email + password 的登入端點，回傳 JWT access token 與使用者資訊。
  - 驗證 JWT 的 middleware / dependency，保護所有受權限控管之端點。
  - 簡化角色模型（admin, researcher），以 RBAC 控制存取權。
- **對應系統需求**：SYS-SR-010、SYS-SR-NFR-004。
- **對應前端 PRD**：FE-PRD-001。

#### BE-PRD-002 匯入與資料清洗

- **描述**：後端需負責接收 Excel / CSV 檔案，解析後：
  - 提供預覽 API（前 100 行 + 建議欄位對應）。
  - 執行正式匯入，處理欄位映射、型別轉換、重複檢測與錯誤彙整。
- **對應系統需求**：SYS-SR-020、SYS-SR-NFR-001~003。
- **對應前端 PRD**：FE-PRD-002（搜尋前準備）、FE-PRD-008（匯入流程 UI）。

#### BE-PRD-003 報告搜尋與詳情服務

- **描述**：提供可支援全文搜尋與多條件篩選的報告查詢 API，並在詳情端點中回傳完整報告與相關 AI 標記與專案。
- **對應系統需求**：SYS-SR-030。
- **對應前端 PRD**：FE-PRD-002、FE-PRD-003。

#### BE-PRD-004 AI 分析與標記管理

- **描述**：
  - 封裝 Ollama Client：構造 prompt、呼叫 `/api/chat` 或 `/api/generate`、解析 JSON 並處理錯誤。
  - 實作單筆分析與批次分析端點，並將結果存入 `ai_annotations`。
  - 提供 AI 標記查詢 / 更新 / 刪除 API。
- **對應系統需求**：SYS-SR-040。
- **對應前端 PRD**：FE-PRD-003、FE-PRD-004。

#### BE-PRD-005 專案管理與資料匯出

- **描述**：
  - 實作 projects / project_reports 的 CRUD 與查詢。
  - 提供依專案或搜尋條件導出 Excel / CSV / JSON 的端點，確保效能與資料欄位正確性。
- **對應系統需求**：SYS-SR-050、SYS-SR-060。
- **對應前端 PRD**：FE-PRD-005。

---

## 3. 後端層 SR（BE-SR - Software Requirements）

> 下列為可實作、可驗證的後端軟體需求，並指明其：
> - 對應之 SYS-SR、
> - 對應前端 FE-SR、
> - 相關資料表 / 模組。

### 3.1 功能性 BE-SR

| BE-SR ID | 摘要 | 對應 SYS-SR | 相關資料表 / 模組 |
|----------|------|-------------|------------------|
| BE-SR-001 | 後端必須提供 `POST /api/v1/auth/login`，接受表單 `username` 與 `password`，驗證成功後回傳 JWT 與使用者資訊。 | SYS-SR-010 | `users`、`common/auth_api.py` |
| BE-SR-002 | 後端必須提供 `GET /api/v1/auth/me`，根據 Authorization header 中的 JWT 還原使用者資訊。 | SYS-SR-010 | `users`、`common/auth_api.py` |
| BE-SR-010 | 後端必須提供 `POST /api/v1/import/preview`，可解析 CSV / Excel，回傳欄位名稱清單、前 100 行資料與建議映射。 | SYS-SR-020 | `reports`（尚未寫入）|
| BE-SR-011 | 後端必須提供 `POST /api/v1/import/execute`，依給定欄位映射將檔案內容批次寫入 `reports`，並回傳匯入/略過/錯誤筆數。 | SYS-SR-020 | `reports` |
| BE-SR-020 | 後端必須提供 `GET /api/v1/reports`（或等效 `/reports/search`），支援關鍵字、多條件篩選與分頁；使用全文索引優化效能。 | SYS-SR-030 | `reports`、全文索引 |
| BE-SR-021 | 後端必須提供 `GET /api/v1/reports/{id}`，回傳單一報告的完整資訊與關聯 AI 標記與專案摘要。 | SYS-SR-030 | `reports`, `ai_annotations`, `project_reports` |
| BE-SR-030 | 後端必須提供 `GET /api/v1/ai/annotations/{report_id}`，可依 `annotation_type` 篩選，並依 `created_at` 逆序回傳。 | SYS-SR-040 | `ai_annotations` |
| BE-SR-031 | 後端必須提供 `DELETE /api/v1/ai/annotations/{id}`，將指定標記刪除。 | SYS-SR-040 | `ai_annotations` |
| BE-SR-040 | 後端必須提供 `POST /api/v1/ai/analyze`，依 `report_id` 讀取報告內容，呼叫 Ollama 進行分析，將結果寫入 `ai_annotations` 並回傳。 | SYS-SR-040 | `reports`, `ai_annotations`, Ollama Client |
| BE-SR-041 | 後端必須提供 `POST /api/v1/ai/batch-analyze`，限制單批報告數（如 ≤ 50），並以背景任務方式逐筆分析，控制最大併發數（如 3）。 | SYS-SR-040 | 同上 |
| BE-SR-050 | 後端必須提供 `GET /api/v1/projects`、`POST /api/v1/projects`、`PUT /api/v1/projects/{id}`、`DELETE /api/v1/projects/{id}`，管理專案基本資訊與狀態。 | SYS-SR-050 | `projects`、`project/api.py`、`project/service.py` |
| BE-SR-051 | 後端必須提供 `POST /api/v1/projects/{id}/reports` 與 `DELETE /api/v1/projects/{id}/reports/{report_id}`，維護 `project_reports` 關聯，避免重複條目。 | SYS-SR-050 | `project_reports` |
| BE-SR-060 | 後端必須提供 `POST /api/v1/export/project`，接受 `project_id`、輸出格式、欄位選擇等參數，回傳對應檔案串流。 | SYS-SR-060 | `projects`, `project_reports`, `reports`, `ai_annotations` |
| BE-SR-061 | 後端必須提供 `POST /api/v1/export/search`，接受搜尋參數 JSON，執行查詢後回傳匯出檔案。 | SYS-SR-060 | 同上 |

### 3.2 API 契約參考

- API 規範詳見 [`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章。
- 所有 API 的 DTO、欄位與錯誤碼必須與架構文件保持一致。

### 3.3 非功能性 BE-SR（效能 / 安全 / 可維護性）

| BE-SR-NFR ID | 類別 | 摘要 | 對應 SYS-SR-NFR |
|--------------|------|------|------------------|
| BE-SR-NFR-001 | 效能 | 報告搜尋 API 在 10k 筆資料下，P95 回應時間 < 2 秒。 | SYS-SR-NFR-001 |
| BE-SR-NFR-002 | 效能 | 單次匯入 5k 筆報告時，匯入 API 應在合理時間內完成（目標 > 500 筆/分鐘）。 | SYS-SR-NFR-001, 003 |
| BE-SR-NFR-003 | 效能 | 單筆 AI 分析端點的後端處理（不含 LLM 推論時間）應在 1 秒內完成。 | SYS-SR-NFR-001 |
| BE-SR-NFR-004 | 安全 | 所有受保護端點必須檢查 JWT，未授權則回傳 401/403；密碼以 bcrypt 儲存。 | SYS-SR-NFR-004 |
| BE-SR-NFR-005 | 可維護性 | 後端程式碼需通過 ruff/mypy/black 等工具，並維持核心模組單元測試覆蓋率 ≥ 70%。 | SYS-SR-NFR-005 |

---

## 4. 後端設計（SD）概要

> 詳細設計請參考 [`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md)，此處僅整理架構層面的設計決策與其與 BE-SR 的對應。

### 4.1 模組與分層

- **模組化架構**（v2.0 採用）：
  - `study/` - 檢查記錄（Study）相關功能
    - `study/models.py` - Study 模型
    - `study/api.py` - Study API 端點
    - `study/services.py` - Study 業務邏輯
    - `study/schemas.py` - Pydantic schemas
  - `project/` - 專案管理相關功能
    - `project/models.py` - Project, ProjectMember 模型
    - `project/api.py` - Project API 端點
    - `project/service.py` - Project 業務邏輯
    - `project/schemas.py` - Pydantic schemas
  - `report/` - 報告和 AI 標註相關功能
    - `report/models.py` - Report, ReportVersion, AIAnnotation 等模型
    - `report/api.py` - Report API 端點
    - `report/service.py` - Report 業務邏輯
    - `report/schemas.py` - Pydantic schemas
  - `common/` - 跨模組共用功能
    - `common/models.py` - 關聯模型（如 StudyProjectAssignment）
    - `common/permissions.py` - 權限管理
    - `common/auth_api.py` - 認證 API
    - `common/pagination.py` - 分頁輔助
    - `common/exceptions.py` - 自定義異常
    - `common/config.py` - 配置

- **邏輯分層**：
  - **API Layer**：Django Ninja router，僅處理請求解析與回應格式。
  - **Service Layer**：封裝業務邏輯，對應 StudyService、ReportService、ProjectService 等。
  - **Repository / ORM Layer**：透過 Django ORM 操作資料表。
  - **Integration Layer**：Ollama Client、外部服務整合。

### 4.2 資料表與 BE-SR 對應

- 來源：[`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 4 章
- 對應關係（摘要）：
  - `users` ↔ BE-SR-001, 002, BE-SR-NFR-004。
  - `reports` ↔ BE-SR-010, 011, 020, 021。
  - `ai_annotations` ↔ BE-SR-030, 031, 040, 041。
  - `projects`, `project_reports` ↔ BE-SR-050, 051, 060, 061。
- 全文索引（如 `idx_reports_content_fulltext`）支援搜尋效能需求 BE-SR-NFR-001。

### 4.3 Ollama 整合設計

- 設計要點：
  - 使用 httpx AsyncClient 與明確 timeout 設定。
  - 以 `OllamaClient` 類別封裝：`chat()` / `analyze_report()` 等方法。
  - 以 semaphore 控制最大併發數（如 3），避免 LLM 過載。
  - 將 LLM 回傳內容以 JSON 解析後寫入 `ai_annotations.content`，無法解析時仍以 raw_response 儲存。
  - 對於連線錯誤或逾時錯誤，回傳 503/504 並在前端顯示友善訊息（對應 FE-SR-040, 041）。

### 4.4 匯入與匯出流程

- 匯入：
  - 使用 Pandas 解析檔案；
  - 先預覽（不寫入 DB），後正式匯入；
  - 實作批次 commit 策略（每 100 筆一次 commit）；
  - 紀錄錯誤行與原因，以列表形式回傳前端。
- 匯出：
  - 依 project_id 或搜尋條件組合查詢；
  - 以 Pandas DataFrame 產生 Excel / CSV；
  - 以串流方式回傳，避免一次載入過大資料於記憶體。

---

## 5. 前端 / 後端 / 系統層追溯表（摘錄）

> **⭐ 權威參考**：完整的追溯矩陣請參考：  
> [`../traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md)

### 5.1 按系統層 SR 的追溯表摘要

| 系統層 | 前端層 | 後端層 |
|--------|--------|--------|
| SYS-PRD-001 / SYS-SR-030, 040 | FE-PRD-003, 004 / FE-SR-020, 030, 040, 041 | BE-PRD-003, 004 / BE-SR-021, 030~031, 040~041 |
| SYS-PRD-002 / SYS-SR-020, 030 | FE-PRD-002 / FE-SR-010~011 | BE-PRD-002, 003 / BE-SR-010~011, 020 |
| SYS-PRD-003 / SYS-SR-050, 060 | FE-PRD-005 / FE-SR-050~051, 060 | BE-PRD-005 / BE-SR-050~051, 060~061 |
| SYS-PRD-004 / SYS-SR-010 + NFR-001, 004, 005 | FE-PRD-001, 006, 007 / FE-SR-001~002, 080, 090~092 | BE-PRD-001 / BE-SR-001~002, BE-SR-NFR-001~005 |

### 5.2 追蹤維護流程

- 本表反映系統層級的映射；詳細的 **UR → SYS → FE → BE** 映射請參考追溯矩陣。
- 若 BE-SR 或 FE-SR ID 有變動，需同時更新規範矩陣以保持一致。

---

## 6. 標準對應（IEC 62304 / ISO 29148）

- 本文件 + [`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md) + [`02_FRONTEND_PRD_SR_SD.md`](02_FRONTEND_PRD_SR_SD.md) 共同形成：
  - **系統 / 軟體需求規格**（自 UR / NFR 整理而來的 SYS-SR / FE-SR / BE-SR）。
  - **軟體架構與詳細設計**（由架構文件承接，並在此文件中掛上需求 ID 與追溯關係）。
- 後續若需符合醫療器材軟體完整程序：
  - 應再補充：
    - Software Development Plan、
    - Risk Management / Hazard Control Traceability、
    - Unit / Integration / System Test 規格與報告，
  - 但本文件已提供一個可直接掛接到 IEC 62304 要求的 **需求與設計骨幹**。

---

## 7. 與標準的對應說明

- **ISO/IEC/IEEE 29148:2018**：
  - 本文件對應標準中的 Software Requirements Specification (SRS)。
  - **詳細合規性對照**：請參閱 [`../regulations/00_REGULATIONS_INDEX.md`](../regulations/00_REGULATIONS_INDEX.md)
- **IEC 62304:2006**：
  - 本文件承接後端軟體的需求規格與設計說明。
  - **詳細合規性對照**：請參閱 [`../regulations/00_REGULATIONS_INDEX.md`](../regulations/00_REGULATIONS_INDEX.md)

---

**變更記錄**：本文件由 `docs/old/image_data_platform/requirements/03_BACKEND_PRD_SR_SD.md` 遷移而來，並更新所有內部連結指向新文檔結構。

**相關文檔**：
- 系統需求：[`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md)
- 前端需求：[`02_FRONTEND_PRD_SR_SD.md`](02_FRONTEND_PRD_SR_SD.md)
- 系統架構：[`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md)
- 追溯矩陣：[`../traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md)

