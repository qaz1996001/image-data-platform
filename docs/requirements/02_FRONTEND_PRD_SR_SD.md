# 02_FRONTEND_PRD_SR_SD — 前端層 PRD / SR / SD

**文件 ID**: FE-PRD-SR-SD-001  
**標題**: 影像數據平台 Phase 1 — 前端（React + TS）需求與設計  
**版本**: v2.0.0-Phase1  
**狀態**: Draft  
**建立日期**: 2025-11-24  
**最後更新**: 2025-11-24  
**作者 / 審核人**: （待填）

> 本文件聚焦於 **前端 Web 應用（React 18 + TypeScript + Ant Design + Zustand）**，將系統層 PRD / SR 拆解為具體前端職責，並描述與後端 API 及系統層設計的介面關係。
> 需求來源：[`docs/old/requirements/USER_REQUIREMENTS.md`](../old/requirements/USER_REQUIREMENTS.md)、[`docs/old/requirements/FUNCTIONAL_SPECIFICATION.md`](../old/requirements/FUNCTIONAL_SPECIFICATION.md)、[`docs/old/architecture/FRONTEND_BACKEND_INTEGRATION.md`](../old/architecture/FRONTEND_BACKEND_INTEGRATION.md)。

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
  - [SYS-PRD-001 AI 輔助報告篩選與標記](01_SYSTEM_PRD_SR_SD.md#SYS-PRD-001)
  - [SYS-PRD-002 報告資料整合與高效搜尋](01_SYSTEM_PRD_SR_SD.md#SYS-PRD-002)
  - [SYS-PRD-003 專案管理與資料匯出](01_SYSTEM_PRD_SR_SD.md#SYS-PRD-003)
  - [SYS-PRD-004 簡潔高效的研究者工作介面](01_SYSTEM_PRD_SR_SD.md#SYS-PRD-004)
- 對應系統層 SR：
  - SYS-SR-001 ~ SYS-SR-010, SYS-SR-NFR-001 ~ 005（見 `01_SYSTEM_PRD_SR_SD.md` 第 4 章）
- 與後端串接：具體 API 介面詳見 [`docs/old/api/04_API_SPECIFICATION.md`](../old/api/04_API_SPECIFICATION.md)，本文件在 SD 章節中將其視為「外部介面」。

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
- **對應系統需求**：SYS-PRD-004、SYS-SR-001、SYS-SR-NFR-004。

#### FE-PRD-002 報告搜尋與列表瀏覽

- **描述**：在單一頁面提供快速搜尋與多條件篩選 UI，支援：
  - 關鍵字輸入框 + 即時防抖搜尋。
  - 進階篩選條件（日期區間、檢查類型、科別、是否有 AI 標記等）。
  - 分頁列表 + 排序（日期 / 相關度）。
  - 列表中顯示摘要資訊與 AI 標記狀態。
- **對應系統需求**：SYS-PRD-002、SYS-SR-003、SYS-SR-NFR-001。

#### FE-PRD-003 報告詳情與 AI 標記呈現

- **描述**：在報告詳情頁中明確呈現：
  - 基本資訊（患者、檢查、科別）。
  - 報告全文（可高亮 AI 標記片段）。
  - AI 標記列表（卡片形式，支援展開/收合）。
  - 快捷操作：發起 AI 分析、編輯/刪除標記、加入專案。
- **對應系統需求**：SYS-PRD-001、SYS-SR-004, 005, 007。

#### FE-PRD-004 AI 分析觸發與批次操作

- **描述**：
  - 單筆分析：在詳情頁提供表單（提示詞 + 分析類型），呼叫 `/ai/analyze` 後以 loading 狀態提示，完成後即時更新畫面。
  - 批次分析：在搜尋列表支援多選與批次分析操作，顯示每筆進度與錯誤，避免阻塞 UI。
- **對應系統需求**：SYS-PRD-001、SYS-SR-005、SYS-SR-006。

#### FE-PRD-005 專案管理與匯出操作

- **描述**：
  - 專案列表與詳情頁，支援建立 / 編輯 / 刪除 / 變更狀態。
  - 從搜尋列表與詳情頁將報告加入/移出專案。
  - 在專案詳情頁觸發匯出 Excel / CSV / JSON 操作，並提供下載體驗友善的 UI。
- **對應系統需求**：SYS-PRD-003、SYS-SR-008、SYS-SR-009。

#### FE-PRD-006 高效 UI 與鍵盤快捷鍵

- **描述**：為核心作業流程（搜尋、切換報告、發起 AI、建立專案）配置快捷鍵與高效操作：
  - Ctrl+K 打開全域搜尋或焦點移至搜尋框。
  - Ctrl+N 建立新專案。
  - Ctrl+A 對當前報告發起 AI 分析。
  - 上 / 下鍵在列表中切換報告；Enter 打開詳情。
- **對應系統需求**：SYS-PRD-004、SYS-SR-010、NFR-004、NFR-005。

#### FE-PRD-007 統一的 List Workbench 佈局

- **描述**：
  - `/reports`、`/study-search`、`/projects` 等所有「列表 + 篩選」頁面必須使用 `ListWorkbench`殼層，並以固定 slot 呈現 **Header → FilterCard → ResultsCard**。
  - Header 需具備 `title`、`description`、`meta`（統計徽章）與 Primary/Secondary actions 的預留空間。
  - FilterCard 頂部固定 `清除篩選` extra，body 同時容納基本與進階條件；行動版需提供收合開關。
  - ResultsCard 應在 `statusBar` 顯示 loading/error/空結果/選取資訊，在 `actions` 呈現欄位設定＋全選/取消＋頁面專屬批次動作，footer 一律放 `ListViewPagination`。
  - 相同的 spacing / token（`list-workbench.less`）須跨頁共用，避免每頁重新定義 padding 或 `ant-card-head-wrapper` 樣式。
- **對應系統需求**：SYS-PRD-004、SYS-PRD-003、SYS-SR-003、SYS-SR-008、SYS-SR-009。

---

## 4. 前端層 SR（FE-SR - Software Requirements）

> 本節將 FE-PRD-xxx 拆解為可實作與可驗證的前端軟體需求 FE-SR-xxx，並註明其：
> - 對應系統層 SYS-SR-xxx；
> - 主要對應後端 API（僅列出端點與方法，詳細格式依 [`docs/old/api/04_API_SPECIFICATION.md`](../old/api/04_API_SPECIFICATION.md)）。

### 4.1 FE-SR 對應表

| FE-SR ID | 摘要 | 對應 SYS-SR | 主要使用 API |
|---------|------|-------------|--------------|
| FE-SR-001 | 前端必須提供登入表單與錯誤提示，並於成功登入後儲存 access token 及使用者資訊。 | SYS-SR-001 | `POST /api/v1/auth/login`、`GET /api/v1/auth/me` |
| FE-SR-002 | 索引頁應在未登入時自動導向登入頁，偵測 401/403 並清除 token。 | SYS-SR-001, SYS-SR-NFR-004 | 任意受保護 API（全域攔截器） |
| FE-SR-010 | 搜尋頁在使用者輸入關鍵字或調整篩選條件後，300ms 防抖後呼叫搜尋 API，並在 UI 上顯示 loading 與錯誤狀態。 | SYS-SR-003, SYS-SR-NFR-001 | `GET /api/v1/reports` 或 `/studies/search` |
| FE-SR-011 | 搜尋結果列表一次最多顯示 20~50 筆，支援分頁與切換頁碼，確保前端不載入超過必要筆數。 | SYS-SR-003, NFR-001 | 同上 |
| FE-SR-020 | 詳情頁需在路由切換時呼叫報告詳情 API，並在 2 秒內完成顯示（正常載入條件下）。 | SYS-SR-004, NFR-001 | `GET /api/v1/reports/{id}` |
| FE-SR-030 | 詳情頁應從 `/api/v1/ai/annotations/{report_id}` 取得 AI 標記列表，並支援依類型篩選顯示。 | SYS-SR-007 | `GET /api/v1/ai/annotations/{report_id}` |
| FE-SR-040 | 當使用者在詳情頁發起 AI 分析時，前端應組裝 `report_id`、`user_prompt`、`annotation_type` 並呼叫 `/ai/analyze`，完成後自動刷新標記列表。 | SYS-SR-005 | `POST /api/v1/ai/analyze` |
| FE-SR-041 | 在批次分析場景中，前端需追蹤選取的報告 ID 清單，並呼叫 `/ai/batch-analyze`（或等效端點），顯示任務狀態與失敗筆數。 | SYS-SR-006 | `POST /api/v1/ai/batch-analyze` + 狀態查詢 API |
| FE-SR-050 | 專案列表頁應從 `/projects` 取得清單，支援依名稱 / 標籤搜尋與狀態篩選。 | SYS-SR-008 | `GET /api/v1/projects` |
| FE-SR-051 | 專案詳情頁應同時顯示專案資訊與其報告列表（可透過 `/projects/{id}` 或 `/projects/{id}/reports`），並支援移除 / 新增報告。 | SYS-SR-008 | `GET /api/v1/projects/{id}`, `GET /api/v1/projects/{id}/reports`, `POST /projects/{id}/reports`, `DELETE /projects/{id}/reports/{report_id}` |
| FE-SR-060 | 匯出操作時，前端應將選擇的 `project_id` 或搜尋參數傳遞給匯出 API，並處理檔案下載流程。 | SYS-SR-009 | `POST /api/v1/export/project`, `POST /api/v1/export/search` |
| FE-SR-080 | 前端必須實作至少：Ctrl+K, Ctrl+N, Ctrl+A, 上/下/Enter 等快捷鍵，且不影響瀏覽器基本快捷鍵。 | SYS-SR-010, NFR-004 | 與 API 無直接關聯 |
| FE-SR-090 | Reports / Study Search / Projects 必須渲染 `ListWorkbench.Header + FilterCard + ResultsCard`，Header 含 Primary/Secondary actions，FilterCard extra 為「清除篩選」，ResultsCard.summary 顯示「共 N 筆」，footer 為 `ListViewPagination`。 | SYS-SR-003, SYS-SR-008, SYS-PRD-004 | 與 API 無直接關聯（UI 層一致性） |
| FE-SR-091 | ResultsCard.statusBar 要依 loading/error/空結果/選取狀態輸出標準 `StatusBarItem`；actions 列必須包含齒輪「欄位設定」+「全選 / 取消」雙鍵，其餘動作依頁面需求拓展。 | SYS-SR-003, SYS-SR-008 | 與 API 無直接關聯（UI 層一致性） |
| FE-SR-092 | List Workbench 頁面需有對應的 Playwright/E2E 腳本以驗證 Header/Filter/Results/工具列/分頁的一致性，並於 `pnpm test` pipeline 中執行。 | SYS-SR-003, SYS-SR-008 | 與 API 無直接關聯 |

### 4.2 UR‑003 / UR‑004 API 契約連結

- Study Search 與 Report Detail/AI 標記的欄位、查詢參數與錯誤處理 **必須** 以 `docs/requirements/UR003_UR004_API_CONTRACT.md` 為唯一來源；正式環境不得再依賴 mock schema 或舊版 `docs/old/api/04_API_SPECIFICATION.md`。  
- FE‑SR-010、FE‑SR-020、FE‑SR-030 所用的 TypeScript DTO（`StudyListItem`, `StudyDetail`, `AIAnnotation`）應直接對應該契約，並在契約更新時同步調整。

### 4.3 List Workbench UI 規範

> 本節補充 FE-SR-090 ~ 092 的具體呈現規則，適用於 Reports / Study Search / Projects 以及後續所有列表頁。

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

### 4.4 List Workbench 組件技術規範

> 本節詳細描述 `@components/ListWorkbench` 的實作要求，對應 OpenSpec 規格 `list-workbench-components`。

#### 4.4.1 組件匯出清單

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

#### 4.4.2 ListWorkbench 組件規範

**ListWorkbench.Header Props：**
- `title: string`（必填）
- `description?: string`
- `primaryAction?: ReactNode`（未提供時渲染 disabled placeholder）
- `secondaryActions?: ReactNode`
- `meta?: ReactNode`
- `className?: string`

**ListWorkbench.Body Props：**
- `children: ReactNode`（必填）
- `className?: string`
- `gap?: number`（預設 16px）

#### 4.4.3 FilterCard 規範

**Props：**
- `title?: ReactNode`（預設「條件設定」）
- `extra?: ReactNode`（預設「清除篩選」按鈕）
- `collapsible?: boolean`
- `defaultExpanded?: boolean`（預設 true）
- `onClear?: () => void`
- `children: ReactNode`（基本篩選內容）
- `advancedContent?: ReactNode`（進階篩選內容）
- `className?: string`

**行為要求：**
- 必須使用 `variant="outlined"` 的 Ant Design Card
- `collapsible` 為 true 時於底部顯示「顯示進階條件」/「隱藏進階條件」切換按鈕
- 點擊 `extra` 的清除按鈕會觸發 `onClear` callback

#### 4.4.4 ResultsCard 規範

**Props：**
- `title: ReactNode`（必填）
- `summary?: ReactNode`（顯示於 Card extra）
- `statusBar?: ReactNode`
- `actions?: ReactNode`
- `footer?: ReactNode`
- `children: ReactNode`（必填，通常為表格）
- `className?: string`
- `actionsVariant?: 'default' | 'drawer'`（預設 'default'）

**Layout 要求：**
- `statusBar` 與 `actions` 並排於 Card body 頂部
- `actions` 右對齊於同一列
- `children` 為主要內容區域
- `footer` 置於 Card body 下緣

#### 4.4.5 StatusBar 規範

**StatusBarItem 型別：**
```typescript
type StatusBarItemType = 'info' | 'success' | 'warning' | 'error'

interface StatusBarItem {
  key?: React.Key
  type?: StatusBarItemType
  label: ReactNode
  icon?: ReactNode
}
```

**Props：**
- `items: StatusBarItem[]`（必填）
- `dense?: boolean`
- `className?: string`

**樣式對應：**
- `info`: 藍色背景 (#e6f4ff)
- `success`: 綠色背景 (#f6ffed)
- `warning`: 黃色背景 (#fffbe6)
- `error`: 紅色背景 (#fff2f0)

#### 4.4.6 SelectionDrawer 規範

**Props：**
- `open: boolean`（必填）
- `items: T[]`（必填，泛型陣列）
- `renderItem: (item: T, index: number) => ReactNode`（必填）
- `getItemKey?: (item: T, index: number) => React.Key`
- `onClose: DrawerProps['onClose']`（必填）
- `title?: string`（預設「已選清單」）
- `count?: number`（覆寫 badge 顯示數量）
- `primaryActions?: ReactNode`
- `secondaryActions?: ReactNode`
- `actionGroup?: ReactNode`
- `emptyState?: ReactNode`
- `drawerProps?: Omit<DrawerProps, 'open' | 'onClose' | 'title' | 'extra'>`

**SelectionDrawerTrigger Props：**
- `count: number`（必填）
- `onClick: () => void`（必填）
- `label?: string`（預設「已選清單」）
- `disabled?: boolean`
- `buttonProps?: ButtonProps`

**樣式類別：**
- `.list-workbench-drawer-head`：Drawer 標題區域
- `.list-workbench-drawer-extra`：額外操作按鈕區域
- `.list-workbench-drawer-group`：批次操作群組
- `.list-workbench-drawer-list`：項目列表容器
- `.list-workbench-drawer-item`：單一項目容器
- `.list-workbench-selection-trigger`：觸發按鈕
- `.list-workbench-selection-pill`：數量 badge

#### 4.4.7 CSS Token 規範

`list-workbench.css` 必須定義以下 CSS 變數：

```css
:root {
  --lw-surface: #ffffff;
  --lw-border: #f0f0f0;
  --lw-header-padding: 12px 20px;
  --lw-card-gap: 16px;
  --lw-status-bg: #f5f5f5;
  --lw-status-border: #d9d9d9;
}
```

並提供深色模式支援（`@media (prefers-color-scheme: dark)`）。

#### 4.4.8 響應式設計

在 `max-width: 768px` 時：
- Header title 字級從 24px 縮小至 20px
- ResultsCard header 改為垂直堆疊
- Actions 區域寬度 100%，左對齊

#### 4.4.9 實作檔案結構

```
frontend/src/components/ListWorkbench/
├── index.ts                    # 統一匯出點
├── ListWorkbench.tsx           # 主組件、FilterCard、ResultsCard、StatusBar
├── SelectionDrawer.tsx         # 選取抽屜相關組件
├── ColumnSettingsDrawer.tsx    # 欄位設定抽屜
└── list-workbench.css          # 樣式與 token
```

#### 4.4.10 使用範例頁面

已完成導入的頁面：
- `/pages/StudySearch/index.tsx`
- `/pages/ReportSearch/index.tsx`
- `/pages/Projects/index.tsx`
- `/pages/Projects/Detail/ProjectStudyList.tsx`
- `/pages/Projects/Detail/ProjectReportList.tsx`

所有新增的列表頁面必須遵循相同的組件使用模式。

---

## 5. 前端層 SD（設計概要）

> 詳細實作仍以程式碼為準，本節取自 [`docs/old/architecture/FRONTEND_BACKEND_INTEGRATION.md`](../old/architecture/FRONTEND_BACKEND_INTEGRATION.md) 等文件，抽象為軟體設計描述，以對應 IEC 62304 「軟體架構 / 詳細設計」層級。

### 5.1 前端架構與模組劃分

- **核心技術**（來源：[`docs/old/architecture/02_TECHNICAL_ARCHITECTURE.md`](../old/architecture/02_TECHNICAL_ARCHITECTURE.md)）：
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

- 參考：[`docs/old/architecture/FRONTEND_BACKEND_INTEGRATION.md`](../old/architecture/FRONTEND_BACKEND_INTEGRATION.md) 中的 `StudyState` 範例。
- 設計原則：
  - 將「跨頁面共享狀態」（如搜尋條件、選擇的報告、目前專案）放入 store。
  - 每個模組使用各自的 store 檔案，例如 `useAuthStore`, `useStudyStore`, `useProjectStore`。
  - 在 SR 中提到的狀態（如 loading, error, selectedStudy 等）應在 store 模型中有對應欄位與 action。

### 5.3 HTTP 客戶端與錯誤處理

- Axios instance 應：
  - 使用 baseURL = 環境變數 `VITE_API_URL`。
  - 在 request interceptor 中自動帶入 Authorization header（對應 FE-SR-001, FE-SR-002）。
- 在 response interceptor 或呼叫端統一處理 401 / 403 / 500 等錯誤，並根據 [`docs/old/api/04_API_SPECIFICATION.md`](../old/api/04_API_SPECIFICATION.md) 的錯誤格式顯示友善訊息。

### 5.4 與後端 API 串接模式

- 所有 FE-SR 中提到的 API 皆應封裝在 `services/*` 或等價層中，而不是散落在 component：
  - 例如：`authService`, `reportService`, `aiService`, `projectService`, `exportService`。
  - 服務層負責拼接 URL、處理查詢參數與回傳型別（TS 型別定義）。

### 5.5 Study Search 列表欄位定義

- **列表欄位配置**（參考 `frontend/src/pages/StudySearch/index.tsx`）：
  - `exam_id`: Width 100px (Fixed)
  - `medical_record_no`: Width 80px
  - `patient_name`: Width 60px
  - `check_in_datetime`: Width 180px
  - `exam_description`: Width 200px
  - `certified_physician`: Width 60px
  - `exam_source`: Width 60px
  - `exam_status`: Width 60px
  - `report`: Width 180px (顯示 Status Badge)
  - `action`: Width 100px (Fixed Right)

---

## 6. 前端與後端 / 系統層追溯表

> 本節將 FE-PRD / FE-SR 與系統層以及後端層的需求 ID 做鏈結，方便在 IEC 62304 下進行軟體項目與單元的追溯。

| FE-PRD | FE-SR | 對應 SYS-PRD / SYS-SR | 對應 Backend PRD / SR |
|--------|-------|-----------------------|------------------------|
| FE-PRD-001 | FE-SR-001, 002 | SYS-PRD-004 / SYS-SR-001 | BE-PRD-001 / BE-SR-001（auth 模組） |
| FE-PRD-002 | FE-SR-010, 011 | SYS-PRD-002 / SYS-SR-003 | BE-PRD-002 / BE-SR-020（reports/search） |
| FE-PRD-003 | FE-SR-020, 030 | SYS-PRD-001 / SYS-SR-004, 007 | BE-PRD-003 / BE-SR-030, 050 |
| FE-PRD-004 | FE-SR-040, 041 | SYS-PRD-001 / SYS-SR-005, 006 | BE-PRD-004 / BE-SR-040（AI API） |
| FE-PRD-005 | FE-SR-050, 051, 060 | SYS-PRD-003 / SYS-SR-008, 009 | BE-PRD-005 / BE-SR-060, 070 |
| FE-PRD-006 | FE-SR-080 | SYS-PRD-004 / SYS-SR-010, NFR-004 | 與後端無直接對應（僅間接透過效能） |
| FE-PRD-007 統一的 List Workbench 佈局 | FE-SR-090, FE-SR-091, FE-SR-092 | SYS-PRD-003, SYS-PRD-004 / SYS-SR-003, SYS-SR-008, SYS-SR-010 | 前端 UI 層一致性，與後端 API 無直接對應 |

---

*關於後端職責、API 契約與 DB 結構，請參閱 `03_BACKEND_PRD_SR_SD.md`，以取得完整的端到端設計視圖。