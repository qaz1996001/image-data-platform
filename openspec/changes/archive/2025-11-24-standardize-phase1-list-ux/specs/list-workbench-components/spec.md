## ADDED Requirements

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

