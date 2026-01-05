# 02_FRONTEND_PRD_SR_SD — 前端層 PRD / SR / SD

**文件 ID**: IDP-REQ-FE-PRD-SR-SD-001  
**標題**: image_data_platform Phase 1 — 前端（React + TS）需求與設計  
**版本**: v2.1.0-Phase1  
**狀態**: Active  
**建立日期**: 2025-11-24  
**最後更新**: 2025-12-26  
**作者 / 審核人**: （待填）

> 本文件聚焦於 **前端 Web 應用（React 18 + TypeScript + Ant Design + Zustand）**，將系統層 PRD / SR 拆解為具體前端職責，並描述與後端 API 及系統層設計的介面關係。
> 需求來源：舊版需求文檔已整合至 [`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md)。
>
> **相關 OpenSpec Changes**：
> - [`align-phase1-specs-traceability`](../../../openspec/changes/align-phase1-specs-traceability/) - 前端需求追溯矩陣
> - [`deliver-phase1-core-workflows`](../../../openspec/changes/deliver-phase1-core-workflows/) - UR-003/004/007/008 前端整合規範（Study Search、Report Detail、Projects、Export）
> - [`establish-iso-iec-regulations-framework`](../../../openspec/changes/establish-iso-iec-regulations-framework/) - 標準合規性框架

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v2.0.0 | 2025-12-19 | [姓名] | 從舊文檔遷移並更新 |
| v2.1.0 | 2025-12-26 | AI Agent | 遷移至新文檔結構 `docs/image_data_platform/requirements/` |

---

## 1. 範圍與角色

### 1.1 前端範圍

前端負責：
- 提供 **研究人員 / 系統管理員** 的操作介面：登入、搜尋、檢視報告、觸發 AI 分析、管理專案與匯出檔案。
- 管理瀏覽器端狀態（搜尋條件、分頁、已選報告、當前專案、AI 結果暫存等）。
- 與後端 REST API 溝通（HTTP/JSON），不直接存取資料庫或 LLM。

### 1.2 主要使用者

- 研究人員（Researcher）：高頻使用者，主要操作介面。
- 系統管理員（Admin）：偶爾使用者，主要在登入後進行設定與資料檢查（Phase 1 前端無專門管理介面，可共用研究者介面）。

---

## 2. 前端層與系統 / 後端的關係

- 對應系統層 PRD：
  - [SYS-PRD-001 報告資料整合與管理](01_SYSTEM_PRD_SR_SD.md#41-sys-prd-系統產品需求system-product-requirements)
  - [SYS-PRD-002 AI 輔助分析能力](01_SYSTEM_PRD_SR_SD.md#41-sys-prd-系統產品需求system-product-requirements)
  - [SYS-PRD-003 報告檢索與專案管理](01_SYSTEM_PRD_SR_SD.md#41-sys-prd-系統產品需求system-product-requirements)
- 對應系統層 SR：
  - SYS-SR-010 ~ SYS-SR-060, SYS-SR-NFR-001 ~ 005（見 [`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md) 第 4 章）
- 與後端串接：具體 API 介面詳見 [`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章，本文件在 SD 章節中將其視為「外部介面」。

---

## 3. 前端層 PRD（FE-PRD）

> 本節將系統層 PRD 轉化為具體「前端產品需求」，以 FE-PRD-xxx 表示，並註明對應的 SYS-PRD 與 SYS-SR。

### 3.1 需求清單

#### FE-PRD-001 登入與使用者狀態管理

- **描述**：提供簡潔的登入頁，使用者以 email + password 登入成功後進入主介面，前端負責：
  - 收集登入憑證並呼叫 `/auth/login`。
  - 儲存 access token 與使用者資訊（localStorage 或等效安全儲存）。
  - 在後續請求中自動帶入 Authorization header。
  - 處理 401/403 並導向登入頁。
- **對應系統需求**：SYS-PRD-004、SYS-SR-010、SYS-SR-NFR-004。

#### FE-PRD-002 報告搜尋與列表瀏覽

- **描述**：在單一頁面提供快速搜尋與多條件篩選 UI，支援：
  - 關鍵字輸入框 + 即時防抖搜尋。
  - 進階篩選條件（日期區間、檢查類型、科別、是否有 AI 標記等）。
  - 分頁列表 + 排序（日期 / 相關度）。
  - 列表中顯示摘要資訊與 AI 標記狀態。
- **對應系統需求**：SYS-PRD-002、SYS-SR-030、SYS-SR-NFR-001。
- **對應使用者需求**：UR-003（檢查記錄搜尋）
- **OpenSpec Change**: [`deliver-phase1-core-workflows`](../../../openspec/changes/deliver-phase1-core-workflows/) - Study Search 前端整合與 API 契約規範

#### FE-PRD-003 報告詳情與 AI 標記呈現

- **描述**：在報告詳情頁中明確呈現：
  - 基本資訊（患者、檢查、科別）。
  - 報告全文（可高亮 AI 標記片段）。
  - AI 標記列表（卡片形式，支援展開/收合）。
  - 快捷操作：發起 AI 分析、編輯/刪除標記、加入專案。
- **對應系統需求**：SYS-PRD-001、SYS-SR-030, 040。
- **對應使用者需求**：UR-004（報告詳情檢視，含 AI 標記歷史）
- **OpenSpec Change**: [`deliver-phase1-core-workflows`](../../../openspec/changes/deliver-phase1-core-workflows/) - Report Detail + AI 標記串接規範

#### FE-PRD-004 AI 分析觸發與批次操作

- **描述**：
  - 單筆分析：在詳情頁提供表單（提示詞 + 分析類型），呼叫 `/ai/analyze` 後以 loading 狀態提示，完成後即時更新畫面。
  - 批次分析：在搜尋列表支援多選與批次分析操作，顯示每筆進度與錯誤，避免阻塞 UI。
- **對應系統需求**：SYS-PRD-002、SYS-SR-040。

#### FE-PRD-005 專案管理與匯出操作

- **描述**：
  - 專案列表與詳情頁，支援建立 / 編輯 / 刪除 / 變更狀態。
  - 從搜尋列表與詳情頁將報告加入/移出專案。
  - 在專案詳情頁觸發匯出 Excel / CSV / JSON 操作，並提供下載體驗友善的 UI。
- **對應系統需求**：SYS-PRD-003、SYS-SR-050、SYS-SR-060。
- **對應使用者需求**：UR-007（專案建立與管理）、UR-008（專案/搜尋結果匯出）
- **OpenSpec Change**: [`deliver-phase1-core-workflows`](../../../openspec/changes/deliver-phase1-core-workflows/) - Projects RBAC 與批次指派整合、匯出 UX 與通知規範

#### FE-PRD-006 高效 UI 與鍵盤快捷鍵

- **描述**：為核心作業流程（搜尋、切換報告、發起 AI、建立專案）配置快捷鍵與高效操作：
  - Ctrl+K 打開全域搜尋或焦點移至搜尋框。
  - Ctrl+N 建立新專案。
  - Ctrl+A 對當前報告發起 AI 分析。
  - 上 / 下鍵在列表中切換報告；Enter 打開詳情。
- **對應系統需求**：SYS-PRD-004、SYS-SR-010、NFR-004、NFR-005。

#### FE-PRD-007 統一的 List Workbench 佈局

- **描述**：
  - `/reports`、`/study-search`、`/projects` 等所有「列表 + 篩選」頁面必須使用 `ListWorkbench` 殼層，並以固定 slot 呈現 **Header → FilterCard → ResultsCard**。
  - Header 需具備 `title`、`description`、`meta`（統計徽章）與 Primary/Secondary actions 的預留空間。
  - FilterCard 頂部固定 `清除篩選` extra，body 同時容納基本與進階條件；行動版需提供收合開關。
  - ResultsCard 應在 `statusBar` 顯示 loading/error/空結果/選取資訊，在 `actions` 呈現欄位設定＋全選/取消＋頁面專屬批次動作，footer 一律放 `ListViewPagination`。
  - 相同的 spacing / token（`list-workbench.less`）須跨頁共用，避免每頁重新定義 padding 或 `ant-card-head-wrapper` 樣式。
- **對應系統需求**：SYS-PRD-004、SYS-PRD-003、SYS-SR-030、SYS-SR-050、SYS-SR-060。

#### FE-PRD-008 資料匯入精靈

- **描述**：
  - 提供三步驟 wizard（上傳、欄位映射、執行），以 `Step` / `Stepper` 引導研究人員完成 Excel / CSV 資料匯入。
  - Step 1：支援拖曳上傳與檔案驗證（副檔名、大小、欄位數），並呼叫 `/api/v1/import/preview` 顯示前幾筆資料和欄位清單。
  - Step 2：展示來源欄位與目標欄位的映射表格（Patient ID、Exam Date、Department、Report Content 等），提供自動對應、手動調整與映射儲存。
  - Step 3：顯示資料預覽與清單統計（成功/重複/錯誤筆數），按下執行後顯示進度條並揭露結果細節。
- **對應系統需求**：SYS-PRD-001、SYS-SR-020。

---

## 4. 前端層 SR（FE-SR - Software Requirements）

> 本節將 FE-PRD-xxx 拆解為可實作與可驗證的前端軟體需求 FE-SR-xxx，並註明其：
> - 對應系統層 SYS-SR-xxx；
> - 主要對應後端 API（僅列出端點與方法，詳細格式依 [`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章）。

### 4.1 FE-SR 對應表

| FE-SR ID | 摘要 | 對應 SYS-SR | 主要使用 API |
|---------|------|-------------|--------------|
| FE-SR-001 | 前端必須提供登入表單與錯誤提示，並於成功登入後儲存 access token 及使用者資訊。 | SYS-SR-010 | `POST /api/v1/auth/login`、`GET /api/v1/auth/me` |
| FE-SR-002 | 索引頁應在未登入時自動導向登入頁，偵測 401/403 並清除 token。 | SYS-SR-010, SYS-SR-NFR-004 | 任意受保護 API（全域攔截器） |
| FE-SR-010 | 搜尋頁在使用者輸入關鍵字或調整篩選條件後，300ms 防抖後呼叫搜尋 API，並在 UI 上顯示 loading 與錯誤狀態。 | SYS-SR-030, SYS-SR-NFR-001 | `GET /api/v1/reports` 或 `/studies/search` |
| FE-SR-011 | 搜尋結果列表一次最多顯示 20~50 筆，支援分頁與切換頁碼，確保前端不載入超過必要筆數。 | SYS-SR-030, NFR-001 | 同上 |
| FE-SR-020 | 詳情頁需在路由切換時呼叫報告詳情 API，並在 2 秒內完成顯示（正常載入條件下）。 | SYS-SR-030, NFR-001 | `GET /api/v1/reports/{id}` |
| FE-SR-030 | 詳情頁應從 `/api/v1/ai/annotations/{report_id}` 取得 AI 標記列表，並支援依類型篩選顯示。 | SYS-SR-040 | `GET /api/v1/ai/annotations/{report_id}` |
| FE-SR-031 | 詳情頁需在每筆 AI 標記上提供「編輯」與「刪除」操作，編輯時以 modal/inline form 顯示目前內容，刪除則要二次確認，操作成功後刷新列表。 | SYS-SR-040 | `PUT /api/v1/ai/annotations/{id}`, `DELETE /api/v1/ai/annotations/{id}` |
| FE-SR-040 | 當使用者在詳情頁發起 AI 分析時，前端應組裝 `report_id`、`user_prompt`、`annotation_type` 並呼叫 `/ai/analyze`，完成後自動刷新標記列表。 | SYS-SR-040 | `POST /api/v1/ai/analyze` |
| FE-SR-041 | 在批次分析場景中，前端需追蹤選取的報告 ID 清單，並呼叫 `/ai/batch-analyze`（或等效端點），顯示任務狀態與失敗筆數。 | SYS-SR-040 | `POST /api/v1/ai/batch-analyze` + 狀態查詢 API |
| FE-SR-050 | 專案列表頁應從 `/projects` 取得清單，支援依名稱 / 標籤搜尋與狀態篩選。 | SYS-SR-050 | `GET /api/v1/projects` |
| FE-SR-051 | 專案詳情頁應同時顯示專案資訊與其報告列表（可透過 `/projects/{id}` 或 `/projects/{id}/reports`），並支援移除 / 新增報告。 | SYS-SR-050 | `GET /api/v1/projects/{id}`, `GET /api/v1/projects/{id}/reports`, `POST /projects/{id}/reports`, `DELETE /projects/{id}/reports/{report_id}` |
| FE-SR-060 | 匯出操作時，前端應將選擇的 `project_id` 或搜尋參數傳遞給匯出 API，並處理檔案下載流程。 | SYS-SR-060 | `POST /api/v1/export/project`, `POST /api/v1/export/search` |
| FE-SR-070 | 匯入頁面應實作三階段精靈（上傳、欄位映射、執行），在「上傳」步驟上傳 Excel / CSV 並透過 `/import/preview` 取得欄位與樣本資料，在「欄位映射」步驟允許調整對應後，按下「執行」呼叫 `/import/execute`。 | SYS-SR-020 | `POST /api/v1/import/preview`, `POST /api/v1/import/execute` |
| FE-SR-071 | 匯入執行期間應顯示進度條與狀態，完成後呈現成功/重複/失敗筆數與錯誤明細，若匯入為非同步可查詢 `/import/status/{task_id}`。 | SYS-SR-020 | `GET /api/v1/import/status/{task_id}`, `POST /api/v1/import/execute` |
| FE-SR-080 | 前端必須實作至少：Ctrl+K, Ctrl+N, Ctrl+A, 上/下/Enter 等快捷鍵，且不影響瀏覽器基本快捷鍵。 | SYS-SR-010, NFR-004 | 與 API 無直接關聯 |
| FE-SR-090 | Reports / Study Search / Projects 必須渲染 `ListWorkbench.Header + FilterCard + ResultsCard`，Header 含 Primary/Secondary actions，FilterCard extra 為「清除篩選」，ResultsCard.summary 顯示「共 N 筆」，footer 為 `ListViewPagination`。 | SYS-SR-030, SYS-SR-050, SYS-PRD-004 | 與 API 無直接關聯（UI 層一致性） |
| FE-SR-091 | ResultsCard.statusBar 要依 loading/error/空結果/選取狀態輸出標準 `StatusBarItem`；actions 列必須包含齒輪「欄位設定」+「全選 / 取消」雙鍵，其餘動作依頁面需求拓展。 | SYS-SR-030, SYS-SR-050 | 與 API 無直接關聯（UI 層一致性） |
| FE-SR-092 | List Workbench 頁面需有對應的 Playwright/E2E 腳本以驗證 Header/Filter/Results/工具列/分頁的一致性，並於 `pnpm test` pipeline 中執行。 | SYS-SR-030, SYS-SR-050 | 與 API 無直接關聯 |

### 4.2 FE-SR 詳細描述

本節按 FE-SR 編號順序詳細描述每個需求，包含驗收標準、異常處理與相關 API 契約。

#### 4.2.1 FE-SR-001 ~ FE-SR-002：登入與認證

**FE-SR-001：登入表單與 token 管理**

- **需求描述**：前端必須提供登入表單與錯誤提示，並於成功登入後儲存 access token 及使用者資訊。
- **對應系統需求**：SYS-SR-010
- **主要使用 API**：`POST /api/v1/auth/login`、`GET /api/v1/auth/me`
- **驗收標準**：
  - 登入表單包含 email 與 password 欄位
  - 登入成功後將 access token 儲存至 localStorage（或等效安全儲存）
  - 登入成功後呼叫 `/api/v1/auth/me` 取得使用者資訊並儲存
  - 登入失敗時顯示明確的錯誤訊息
- **異常處理**：當 API 請求失敗（網路錯誤、401 認證失敗、500 伺服器錯誤）時，應顯示對應的錯誤訊息並允許使用者重試。

**FE-SR-002：未登入導向與 token 驗證**

- **需求描述**：索引頁應在未登入時自動導向登入頁，偵測 401/403 並清除 token。
- **對應系統需求**：SYS-SR-010, SYS-SR-NFR-004
- **主要使用 API**：任意受保護 API（全域攔截器）
- **驗收標準**：
  - 未登入使用者訪問受保護頁面時自動導向登入頁
  - 偵測到 401/403 回應時自動清除 token 並導向登入頁
  - 在後續請求中自動帶入 Authorization header
- **異常處理**：當 token 過期或無效時，應清除本地 token 並導向登入頁，避免無限重導向循環。

#### 4.2.2 FE-SR-010 ~ FE-SR-011：報告搜尋

**FE-SR-010：搜尋功能與防抖**

- **需求描述**：搜尋頁在使用者輸入關鍵字或調整篩選條件後，300ms 防抖後呼叫搜尋 API，並在 UI 上顯示 loading 與錯誤狀態。
- **對應系統需求**：SYS-SR-030, SYS-SR-NFR-001
- **主要使用 API**：`GET /api/v1/reports` 或 `/studies/search`
- **API 契約**：詳見 [`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章
- **驗收標準**：
  - 使用者輸入關鍵字後，300ms 內無新輸入才觸發搜尋
  - 搜尋過程中顯示 loading 狀態
  - 搜尋結果在 2 秒內顯示（正常網路條件下）
- **異常處理**：當 API 請求失敗（網路錯誤、超時、5xx 錯誤）時，應顯示錯誤訊息並允許使用者重試；當回應時間超過 5 秒時，應顯示超時提示。

**FE-SR-011：搜尋結果分頁**

- **需求描述**：搜尋結果列表一次最多顯示 20~50 筆，支援分頁與切換頁碼，確保前端不載入超過必要筆數。
- **對應系統需求**：SYS-SR-030, NFR-001
- **主要使用 API**：同上
- **驗收標準**：
  - 每頁顯示 20~50 筆結果（可配置）
  - 支援頁碼切換與跳轉
  - 顯示總筆數與當前頁範圍
- **異常處理**：當分頁參數無效時，應使用預設值並顯示提示。

#### 4.2.3 FE-SR-020：報告詳情

**FE-SR-020：報告詳情頁**

- **需求描述**：詳情頁需在路由切換時呼叫報告詳情 API，並在 2 秒內完成顯示（正常載入條件下）。
- **對應系統需求**：SYS-SR-030, NFR-001
- **主要使用 API**：`GET /api/v1/reports/{id}`
- **API 契約**：詳見 [`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 第 5 章
- **驗收標準**：
  - 路由切換時立即顯示 loading 狀態
  - 報告詳情在 2 秒內完成顯示
  - 顯示完整的報告內容與基本資訊
- **異常處理**：當 API 請求失敗（404 報告不存在、500 伺服器錯誤、網路斷線）時，應顯示錯誤訊息並提供返回列表的連結；當載入時間超過 5 秒時，應顯示超時提示並允許重試。

#### 4.2.4 FE-SR-030 ~ FE-SR-031：AI 標記管理

**FE-SR-030：AI 標記列表**

- **需求描述**：詳情頁應從 `/api/v1/ai/annotations/{report_id}` 取得 AI 標記列表，並支援依類型篩選顯示。
- **對應系統需求**：SYS-SR-040
- **主要使用 API**：`GET /api/v1/ai/annotations/{report_id}`
- **驗收標準**：
  - 顯示所有 AI 標記列表
  - 支援依 `annotation_type` 篩選
  - 標記列表依 `created_at` 逆序顯示
- **異常處理**：當 API 請求失敗時，應顯示錯誤訊息；當無標記時，應顯示空狀態提示。

**FE-SR-031：AI 標記編輯與刪除**

- **需求描述**：詳情頁需在每筆 AI 標記上提供「編輯」與「刪除」操作，編輯時以 modal/inline form 顯示目前內容，刪除則要二次確認，操作成功後刷新列表。
- **對應系統需求**：SYS-SR-040
- **主要使用 API**：`PUT /api/v1/ai/annotations/{id}`, `DELETE /api/v1/ai/annotations/{id}`
- **驗收標準**：
  - 每筆標記提供編輯與刪除按鈕
  - 編輯時顯示表單（modal 或 inline）
  - 刪除時顯示二次確認對話框
  - 操作成功後自動刷新標記列表
- **異常處理**：當編輯/刪除失敗時，應顯示錯誤訊息並保持列表狀態不變。

#### 4.2.5 FE-SR-040 ~ FE-SR-041：AI 分析

**FE-SR-040：單筆 AI 分析**

- **需求描述**：當使用者在詳情頁發起 AI 分析時，前端應組裝 `report_id`、`user_prompt`、`annotation_type` 並呼叫 `/ai/analyze`，完成後自動刷新標記列表。
- **對應系統需求**：SYS-SR-040
- **主要使用 API**：`POST /api/v1/ai/analyze`
- **驗收標準**：
  - 提供 AI 分析表單（提示詞 + 分析類型）
  - 發起分析後顯示 loading 狀態
  - 分析完成後自動刷新標記列表
- **異常處理**：當 Ollama 服務不可用（503 錯誤）時，應顯示「AI 服務暫時不可用，請稍後再試」；當分析超時（504 錯誤）時，應顯示「分析超時，建議減少報告長度或降低併發數」並允許重試；當網路斷線時，應顯示網路錯誤提示。

**FE-SR-041：批次 AI 分析**

- **需求描述**：在批次分析場景中，前端需追蹤選取的報告 ID 清單，並呼叫 `/ai/batch-analyze`（或等效端點），顯示任務狀態與失敗筆數。
- **對應系統需求**：SYS-SR-040
- **主要使用 API**：`POST /api/v1/ai/batch-analyze` + 狀態查詢 API
- **驗收標準**：
  - 支援多選報告並發起批次分析
  - 顯示每筆報告的分析進度
  - 顯示成功/失敗筆數統計
- **異常處理**：當批次任務啟動失敗（503 Ollama 服務不可用、400 參數錯誤）時，應顯示錯誤訊息；當任務執行過程中部分報告分析失敗時，應顯示成功/失敗筆數統計；當網路斷線導致任務狀態無法查詢時，應顯示網路錯誤並允許手動刷新狀態。

#### 4.2.6 FE-SR-050 ~ FE-SR-051：專案管理

**FE-SR-050：專案列表**

- **需求描述**：專案列表頁應從 `/projects` 取得清單，支援依名稱 / 標籤搜尋與狀態篩選。
- **對應系統需求**：SYS-SR-050
- **主要使用 API**：`GET /api/v1/projects`
- **驗收標準**：
  - 顯示所有專案列表
  - 支援依名稱/標籤搜尋
  - 支援依狀態篩選
- **異常處理**：當 API 請求失敗時，應顯示錯誤訊息。

**FE-SR-051：專案詳情與報告管理**

- **需求描述**：專案詳情頁應同時顯示專案資訊與其報告列表（可透過 `/projects/{id}` 或 `/projects/{id}/reports`），並支援移除 / 新增報告。
- **對應系統需求**：SYS-SR-050
- **主要使用 API**：`GET /api/v1/projects/{id}`, `GET /api/v1/projects/{id}/reports`, `POST /projects/{id}/reports`, `DELETE /projects/{id}/reports/{report_id}`
- **驗收標準**：
  - 顯示專案基本資訊
  - 顯示專案包含的報告列表
  - 支援新增報告至專案
  - 支援從專案移除報告
- **異常處理**：當操作失敗時，應顯示錯誤訊息；當權限不足時，應顯示權限錯誤提示。

#### 4.2.7 FE-SR-060：匯出功能

**FE-SR-060：資料匯出**

- **需求描述**：匯出操作時，前端應將選擇的 `project_id` 或搜尋參數傳遞給匯出 API，並處理檔案下載流程。
- **對應系統需求**：SYS-SR-060
- **主要使用 API**：`POST /api/v1/export/project`, `POST /api/v1/export/search`
- **驗收標準**：
  - 支援匯出專案資料
  - 支援匯出搜尋結果
  - 支援選擇匯出格式（Excel / CSV / JSON）
  - 檔案下載在 10 秒內開始（正常網路條件下）
- **異常處理**：當匯出失敗時，應顯示錯誤訊息；當下載超過 30 秒未開始時，應顯示超時提示。

#### 4.2.8 FE-SR-070 ~ FE-SR-071：資料匯入

**FE-SR-070：匯入精靈**

- **需求描述**：匯入頁面應實作三階段精靈（上傳、欄位映射、執行），在「上傳」步驟上傳 Excel / CSV 並透過 `/import/preview` 取得欄位與樣本資料，在「欄位映射」步驟允許調整對應後，按下「執行」呼叫 `/import/execute`。
- **對應系統需求**：SYS-SR-020
- **主要使用 API**：`POST /api/v1/import/preview`, `POST /api/v1/import/execute`
- **驗收標準**：
  - 提供三步驟精靈介面
  - Step 1：上傳檔案並預覽欄位
  - Step 2：調整欄位映射
  - Step 3：執行匯入
- **異常處理**：當檔案格式錯誤時，應顯示錯誤訊息；當欄位映射不完整時，應阻止執行並提示。

**FE-SR-071：匯入進度與結果**

- **需求描述**：匯入執行期間應顯示進度條與狀態，完成後呈現成功/重複/失敗筆數與錯誤明細，若匯入為非同步可查詢 `/import/status/{task_id}`。
- **對應系統需求**：SYS-SR-020
- **主要使用 API**：`GET /api/v1/import/status/{task_id}`, `POST /api/v1/import/execute`
- **驗收標準**：
  - 顯示匯入進度條
  - 顯示成功/重複/失敗筆數
  - 顯示錯誤明細（如有）
- **異常處理**：當匯入失敗時，應顯示錯誤明細並允許重新匯入。

#### 4.2.9 FE-SR-080：鍵盤快捷鍵

**FE-SR-080：快捷鍵支援**

- **需求描述**：前端必須實作至少：Ctrl+K, Ctrl+N, Ctrl+A, 上/下/Enter 等快捷鍵，且不影響瀏覽器基本快捷鍵。
- **對應系統需求**：SYS-SR-010, NFR-004
- **主要使用 API**：與 API 無直接關聯
- **驗收標準**：
  - Ctrl+K：開啟全域搜尋或焦點移至搜尋框
  - Ctrl+N：建立新專案
  - Ctrl+A：對當前報告發起 AI 分析
  - 上/下鍵：在列表中切換報告
  - Enter：打開詳情
- **異常處理**：當快捷鍵與瀏覽器衝突時，應優先保留瀏覽器功能。

#### 4.2.10 FE-SR-090 ~ FE-SR-092：List Workbench UI 一致性

**FE-SR-090 ~ FE-SR-092：統一的列表瀏覽介面**

- **需求描述**：Reports / Study Search / Projects 等所有列表頁面應提供統一的介面結構與行為。介面應包含標題區域、篩選條件區域、結果列表區域與分頁控制。標題區域應顯示頁面標題、描述、統計資訊與主要操作按鈕。篩選條件區域應提供清除篩選功能，支援基本與進階條件。結果列表區域應顯示載入狀態、錯誤狀態、空結果提示、選取狀態與批次操作；分頁控制應支援頁碼切換。所有列表頁面應使用一致的間距與樣式規範。
- **對應系統需求**：SYS-SR-030, SYS-SR-050, SYS-PRD-004
- **主要使用 API**：與 API 無直接關聯（UI 層一致性）
- **驗收標準**：
  - 所有列表頁面（Reports、Study Search、Projects）使用統一的介面結構
  - 介面包含標題、篩選、結果、分頁四個主要區域
  - 所有頁面使用一致的間距與樣式
- **異常處理**：當頁面載入失敗時，應顯示錯誤狀態；當無結果時，應顯示空狀態提示。
- **設計規範**：具體 UI 組件實作詳見 §5.5-5.6 設計規範章節。

---

**第 4 章說明**：本章節（§4.1-4.2）為 **Software Requirements Specification (SRS)** 層級，依據 ISO/IEC/IEEE 29148:2018 與 IEC 62304:2006 標準，僅描述「做什麼」（需求行為、驗收標準、異常處理），不包含「如何做」（具體 UI 組件、技術實作細節）。設計規範（Software Design）詳見第 5 章。

---

## 5. 前端層 SD（設計概要）

> **設計文件說明**：本章節為 **Software Design (SD)** 層級，依據 ISO/IEC/IEEE 29148:2018 與 IEC 62304:2006 標準，描述「如何做」（架構設計、組件實作、技術細節）。本章對應 IEC 62304 的「軟體架構設計」（§5.3）與「軟體詳細設計」（§5.4）層級。
>
> 詳細實作仍以程式碼為準，本節描述軟體設計原則與主要組件。

### 5.1 前端架構與模組劃分

- **核心技術**：
  - React 18 + TypeScript
  - UI：Ant Design 5
  - 狀態管理：Zustand
  - HTTP：Axios
  - 建置：Vite 5
- **主要模組**（抽象）：
  - `Auth` 模組：登入表單 / 使用者狀態 store / token 攔截器。
  - `Search` 模組：搜尋表單、結果列表、篩選條件 store。
  - `ReportDetail` 模組：報告內容顯示、AI 標記列表、AI 分析觸發區塊。
  - `Project` 模組：專案列表 / 詳情 / 報告關聯與統計。
  - `Export` 模組：匯出選項對話框與下載流程。

### 5.2 狀態管理（Zustand）

- 設計原則：
  - 將「跨頁面共享狀態」（如搜尋條件、選擇的報告、目前專案）放入 store。
  - 每個模組使用各自的 store 檔案，例如 `useAuthStore`, `useStudyStore`, `useProjectStore`。
  - 在 SR 中提到的狀態（如 loading, error, selectedStudy 等）應在 store 模型中有對應欄位與 action。

### 5.3 HTTP 客戶端與錯誤處理

- Axios instance 應：
  - 使用 baseURL = 環境變數 `VITE_API_URL`。
  - 在 request interceptor 中自動帶入 Authorization header（對應 FE-SR-001, FE-SR-002）。
- 在 response interceptor 或呼叫端統一處理 401 / 403 / 500 等錯誤，並根據 API 規範的錯誤格式顯示明確的錯誤訊息。錯誤訊息應包含：錯誤類型（服務不可用/超時）、建議動作（檢查服務狀態/稍後重試）、錯誤代碼。

### 5.4 與後端 API 串接模式

- 所有 FE-SR 中提到的 API 皆應封裝在 `services/*` 或等價層中，而不是散落在 component：
  - 例如：`authService`, `reportService`, `aiService`, `projectService`, `exportService`。
  - 服務層負責拼接 URL、處理查詢參數與回傳型別（TS 型別定義）。

### 5.5 List Workbench UI 設計規範

> **設計規範說明**：本節屬於設計文件（SD）範疇，描述 FE-SR-090~092 的具體 UI 組件實作規範。需求層級（FE-SR-090~092）僅描述行為（「系統應提供統一的列表瀏覽介面」），具體組件名稱與實作細節（`ListWorkbench.Header`、`FilterCard`、`ResultsCard` 等）在此設計規範中定義。
>
> 本節適用於 Reports / Study Search / Projects 以及後續所有列表頁。

#### 5.5.1 UI 呈現規則

1. **Header**
   - `ListWorkbench.Header` 必填 `title`、`description`，並於 `meta` 顯示主要統計（例如 `Badge count={total}`）。
   - Primary action（右側最後一顆按鈕）僅允許 1 個，Secondary actions 以 `Space` 排列在其左側；若尚未定義行為，需保留 disabled placeholder 以維持結構。
   - 標頭 padding、字級、背景顏色需使用 `list-workbench.css` 提供的 token（`--lw-header-padding` 等）。
2. **FilterCard**
   - 以 `variant="outlined"` 的 Ant Card 呈現；title 預設為「條件設定」。
   - `extra` 一律為「清除篩選」按鈕（或 `ClearButton`），點擊後必須重置 ListView query 與本地 filter store。
   - 支援 `collapsible` 屬性，當設為 true 時於底部顯示切換按鈕以展開/隱藏進階篩選區塊。
   - 行動裝置 (<768px) 需顯示「Show/Hide Filters」切換按鈕，進階篩選區塊應可收合。
3. **ResultsCard**
   - `summary` 需輸出「共 N 筆 xxx」，當有 active filters 時補上 `・ M 個篩選條件`。
   - `statusBar` 只能顯示規範內的 badge：`loading`（info）、`error`、`empty`（warning）、`selection`（success）…；多個狀態可同時存在，順序為 loading → error → empty/hint → selection/filters。
   - `actions` 列左起為：齒輪（欄位設定）→ 全選 / 取消 → 頁面專屬動作；若暫無 selection，即顯示 disabled 或 tooltip。
   - 支援 `actionsVariant` 屬性，當設為 'drawer' 時會以更緊湊的樣式顯示動作按鈕。
   - `footer` 需放置 `ListViewPagination`，桌機版右對齊、行動版置中。
4. **StatusBar**
   - 必須使用標準的 `StatusBarItem` 型別，支援 `type: 'info' | 'success' | 'warning' | 'error'`。
   - 每個狀態項目可包含 `icon` 與 `label`，並使用對應的顏色編碼。
   - 支援 `dense` 模式以減少內邊距。
5. **SelectionDrawer**
   - 提供泛型 `<T>` 支援不同資料類型的選取清單。
   - 必須包含以下 props：`title`, `items`, `renderItem`, `primaryActions`, `secondaryActions`, `actionGroup`, `emptyState`。
   - Drawer header 套用 `list-workbench-drawer-head` 類別，顯示選取數量 badge。
   - `SelectionDrawerTrigger` 使用 `FolderOpenOutlined` icon，預設標籤為「已選清單」，並顯示選取數量的 pill badge。
   - 支援 `actionGroup` slot 用於批次操作按鈕，會自動換行並保持一致間距。
6. **ColumnSettingsDrawer**
   - 提供統一的欄位設定介面，支援拖曳排序與顯示/隱藏切換。
   - 鎖定的欄位（如 'action'）不可拖曳且切換開關為 disabled 狀態。
   - 提供「重置」按鈕以恢復預設欄位配置。
7. **狀態與響應式**
   - 無結果時需同時透過 StatusBar（文字）與內容區（Empty component 或提示）回饋。
   - Mobile layout (`max-width: 768px`) 將 FilterCard / ResultsCard 工具列堆疊，actions 自動換行。
8. **測試與追蹤**
   - 每個頁面必須在 `frontend/e2e/*.spec.ts` 中新增對應的 List Workbench 測試，驗證 Header/Filter/Results/工具列/分頁是否渲染。
   - 規範更新時需同步調整本節、`frontend/docs/features/list-workbench-guide.md` 以及對應測試，以維持文件、程式與自動化驗證的一致性。

### 5.6 List Workbench 組件技術設計規範

> **設計規範說明**：本節屬於設計文件（SD）範疇，詳細描述 `@components/ListWorkbench` 的技術實作要求。這些技術細節不應出現在需求規格（SR）中，僅在設計文件中定義。

#### 5.6.1 組件匯出清單

`@components/ListWorkbench/index.ts` 必須匯出以下組件與型別：

**組件：**
- `ListWorkbench`（複合組件，包含 `.Header` 和 `.Body` 子組件）
- `FilterCard`
- `ResultsCard`
- `StatusBar`
- `SelectionDrawer`
- `SelectionDrawerTrigger`
- `ColumnSettingsDrawer`

**型別定義：**
- `StatusBarItem`
- `StatusBarItemType`
- `SelectionDrawerProps<T>`
- `SelectionDrawerTriggerProps`
- `ColumnSettingsDrawerProps`

#### 5.6.2 響應式設計

在 `max-width: 768px` 時：
- Header title 字級從 24px 縮小至 20px
- ResultsCard header 改為垂直堆疊
- Actions 區域寬度 100%，左對齊

---

## 6. 前端與後端 / 系統層追溯表

> 本節將 FE-PRD / FE-SR 與系統層以及後端層的需求 ID 做鏈結，方便在 IEC 62304 下進行軟體項目與單元的追溯。
>
> **⭐ 權威參考**：完整的追溯矩陣請參考：  
> [`../traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md)

### 6.1 簡表摘要

| FE-PRD | FE-SR | 對應 SYS-PRD / SYS-SR | 對應 Backend PRD / SR |
|--------|-------|-----------------------|------------------------|
| FE-PRD-001 | FE-SR-001, 002 | SYS-PRD-004 / SYS-SR-010 | BE-SR-001~002 |
| FE-PRD-002 | FE-SR-010, 011 | SYS-PRD-002 / SYS-SR-020, 030 | BE-SR-010~011, BE-SR-020 |
| FE-PRD-003 | FE-SR-020, 030, 031 | SYS-PRD-001 / SYS-SR-030, 040 | BE-SR-021, BE-SR-030~031 |
| FE-PRD-004 | FE-SR-040, 041 | SYS-PRD-001 / SYS-SR-040 | BE-SR-040~041 |
| FE-PRD-005 | FE-SR-050, 051, 060 | SYS-PRD-003 / SYS-SR-050, 060 | BE-SR-050~051, BE-SR-060~061 |
| FE-PRD-006 | FE-SR-080 | SYS-PRD-004 / SYS-SR-010, NFR-004, 005 | 與後端無直接對應（效能/穩定性支撐） |
| FE-PRD-007 | FE-SR-090~092 | SYS-PRD-003, SYS-PRD-004 / SYS-SR-030, SYS-SR-050, SYS-SR-010 | 前端 UI 層一致性，與後端 API 無直接對應 |
| FE-PRD-008 | FE-SR-070, 071 | SYS-PRD-002 / SYS-SR-020 | BE-SR-010~011 |

### 6.2 追蹤維護

- 本表反映 FE 層面的需求；詳細的系統級別映射請參考追溯矩陣。
- 若 FE-SR 或 BE-SR ID 有變動，需同時更新規範矩陣以保持一致。

---

## 7. 與標準的對應說明

- **ISO/IEC/IEEE 29148:2018**：
  - 本文件對應標準中的 Software Requirements Specification (SRS)。
  - **詳細合規性對照**：請參閱 [`../regulations/00_REGULATIONS_INDEX.md`](../regulations/00_REGULATIONS_INDEX.md)
- **IEC 62304:2006**：
  - 本文件承接前端軟體的需求規格與設計說明。
  - **詳細合規性對照**：請參閱 [`../regulations/00_REGULATIONS_INDEX.md`](../regulations/00_REGULATIONS_INDEX.md)

---

**變更記錄**：本文件由 `docs/old/image_data_platform/requirements/02_FRONTEND_PRD_SR_SD.md` 遷移而來，並更新所有內部連結指向新文檔結構。

**相關文檔**：
- 系統需求：[`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md)
- 後端需求：[`03_BACKEND_PRD_SR_SD.md`](03_BACKEND_PRD_SR_SD.md)
- 系統架構：[`../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md)
- 追溯矩陣：[`../traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md)

