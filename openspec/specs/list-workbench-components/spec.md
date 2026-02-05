# list-workbench-components Specification

## Purpose
定義統一的 List Workbench 組件庫，提供可重複使用的 React 組件與樣式 token，供所有列表頁面（Reports、Study Search、Projects 等）使用。確保前端列表介面的一致性、可維護性與使用者體驗的統一性。

本規格對應前端需求文件 `docs/requirements/02_FRONTEND_PRD_SR_SD.md` 的 FE-PRD-007、FE-SR-090、FE-SR-091、FE-SR-092，以及系統需求 SYS-PRD-004、SYS-SR-003、SYS-SR-008。

**實作狀態：✅ 已完成**
- 所有組件已實作於 `frontend/src/components/ListWorkbench/`
- 已在 5 個頁面成功導入並驗證
- 包含完整的 TypeScript 型別定義與 CSS token 系統
## Requirements
### Requirement: ListWorkbench Component Exports
ListWorkbench shell MUST 暴露一組可供三個頁面共用的 React 組件與型別，以避免各頁重複建構容器。
#### Scenario: 前端頁面需要載入統一的列表工作區
`@components/ListWorkbench` MUST 匯出以下 React 組件（TSX）：`ListWorkbench`, `ListWorkbench.Header`, `ListWorkbench.Body`, `FilterCard`, `ResultsCard`, `StatusBar`。每個組件 MUST 提供 TypeScript 型別定義並支援 `className`/`style` 擴充。`ListWorkbench.Header` SHALL 接受 props：`title: string`, `description?: string`, `primaryAction?: ReactNode`, `secondaryActions?: ReactNode`, `meta?: ReactNode`；若 `primaryAction` 未傳入，組件 MUST 渲染 disabled `Button` placeholder，以符合 UI 對齊需求。`ResultsCard` SHALL 接受 `title: string`, `summary?: ReactNode`, `statusBar?: ReactNode`, `actions?: ReactNode`, `footer?: ReactNode`, `children: ReactNode`，並將 `summary` 套用到 `Card` extra 區域。

### Requirement: FilterCard / ResultsCard Layout Contracts
篩選卡片與結果卡片 MUST 以一致的 slot 與 layout 契約呈現，確保任何列表頁導入後不需額外調整 spacing。
#### Scenario: 任一列表頁以標準組件呈現篩選與結果
`FilterCard` MUST 以 Ant Design `Card`（`variant="outlined"`）為基礎，並提供 `title`（預設「條件設定」）、`extra`（預設 `清除篩選` 按鈕）、`collapsible?: boolean` props。當 `collapsible` 為 true 時，`FilterCard` MUST 於底部呈現 `Collapse` 切換以顯示進階欄位。`ResultsCard` MUST 以 `Card` 呈現，並將 `statusBar` slot 渲染在 Card body 頂部、`actions` slot 右對齊於 `statusBar` 列內。`ListViewPagination` 或其他 footer 內容 SHALL 透過 `footer` slot 插入並置於 Card body 下緣。所有 slot 若為空 MUST 佔位，避免 layout 抖動。

### Requirement: ListWorkbench Style Tokens
List Workbench MUST 以可覆寫的 token 套件提供 `ant-card-head-wrapper` 與狀態列樣式，以便各頁維持一致視覺又能主題化。
#### Scenario: 應用統一樣式與 `ant-card-head-wrapper` 覆寫
專案 MUST 新增 `list-workbench.less`（或等同的 CSS Modules）提供下列 CSS 變數：`--lw-surface`, `--lw-border`, `--lw-header-padding`, `--lw-card-gap`, `--lw-status-bg`, `--lw-status-border`。`ListWorkbench.Header` SHALL 套用 class `list-workbench-card-head` 至內部 `ant-card-head-wrapper`，並以 `--lw-header-padding` 控制 padding（預設 `12px 20px`）。`FilterCard`/`ResultsCard` MUST 共用 `list-workbench-card` class，包含背景、陰影、間距設定；`StatusBar` MUST 使用 `--lw-status-bg`/`border` 來呈現 loading/error/selection 狀態。任何自訂頁面樣式 SHALL 透過覆寫這些 token，而非改寫 Ant Design 全域樣式。

### Requirement: Shared Selection Drawer Component
ListWorkbench shell MUST 提供共用 `SelectionDrawer` 組件與 TypeScript 型別，供 Study Search 與 Reports 一致地呈現選取清單與批次操作。

#### Scenario: 列表頁需要顯示 Selected Drawer
- `@components/ListWorkbench` SHALL 匯出 `SelectionDrawer`（或等效 hook），props 至少包含：
  - `title?: string`（預設「已選清單」）
  - `items: T[]`
  - `renderItem: (item: T) => ReactNode`
  - `primaryActions?: ReactNode`（例如「加入專案」「匯出」）
  - `secondaryActions?: ReactNode`（例如「清除全部」「移除單筆」）
  - `badgeCount?: number`（顯示於 Drawer trigger 與標題）
  - `onClose`, `onRemove`, `onClearAll`
- Drawer header MUST 套用 `list-workbench-drawer-head` 類別，行為包含：顯示 `已選 X 筆` badge、提供右上角 `清除全部` text button、遵循 `Space` 排列。
- `SelectionDrawerTrigger`（或等效 props） MUST 回傳包含 badge 的 `Button`，使用 `FolderOpenOutlined` icon，並且在 Reports/Study Search 兩頁都以相同字詞（`查看選擇清單` / `已選清單`）顯示。
- Drawer 內若提供批次行為，需要以 `ActionGroup` slot 呈現，並允許傳入 `actions: { id, icon, name, danger, loading }[]`，以 `Space wrap` 自動換行；行動寬度時動作會以兩列排列且保持 8px 間距。

#### Scenario: Study Search 與 Reports 導入共用 Drawer
- Study Search MUST 利用共用 Drawer 取代現行 `Selected List` 實作，保持欄位（Exam ID、Exam Item、Status 等）透過 `renderItem` 自行定義；Drawer 入口與 badge SHALL 與 Reports 共享樣式。
- Reports MUST 移除專屬的 `ReportSelectionDrawer`，改用共用組件並透過 `renderItem` 呈現報告資訊（標題、UID、標籤）。任何批次行為按鈕（匯出/列印/歸檔/刪除） SHALL 傳入 `primaryActions` 或 Drawer 內 action group slot。

### Requirement: Column Settings Management
ListWorkbench shell MUST 提供共用 `ColumnSettingsDrawer` 組件，供列表頁面統一管理欄位的顯示、隱藏與排序。

#### Scenario: 列表頁需要欄位設定功能
- `@components/ListWorkbench` SHALL 匯出 `ColumnSettingsDrawer`，props 至少包含：
  - `open: boolean`
  - `columnConfig: ColumnConfig[]`
  - `onClose: () => void`
  - `onVisibilityChange: (key: string, visible: boolean) => void`
  - `onDragStart: (key: string) => void`
  - `onDragOver: (e: React.DragEvent) => void`
  - `onDrop: (targetKey: string) => void`
  - `onReset: () => void`
  - `draggedItem: string | null`
  - `title?: string`（預設「欄位設定」）
  - `description?: string`
  - `lockKeys?: string[]`（預設 `['action']`）
- 欄位項目 MUST 支援拖曳排序，除非該欄位在 `lockKeys` 中。
- 每個欄位 MUST 提供 Switch 切換以控制顯示/隱藏。
- Drawer MUST 提供「重置」按鈕以恢復預設配置。
- 鎖定的欄位（如操作欄）MUST 顯示但不可拖曳或關閉。

#### Scenario: Study Search、Reports、Projects 使用統一的欄位管理
- Study Search、Reports、Projects 列表頁 SHOULD 使用 `ColumnSettingsDrawer` 而非自建欄位設定 UI。
- 各頁面透過 `useColumnManager` hook 管理欄位狀態，並將狀態傳遞給 `ColumnSettingsDrawer`。
- 欄位配置 SHOULD 持久化至 localStorage 或等效儲存，以維持使用者偏好。

