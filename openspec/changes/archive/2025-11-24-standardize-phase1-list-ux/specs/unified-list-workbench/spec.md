## ADDED Requirements

### Requirement: List Workbench Header
所有列表頁 MUST 共享同一個 Header 組件，以維持標題、描述、行動按鈕與 meta 資訊的一致樣式與位置。
#### Scenario: 使用者開啟 Reports、Study Search 或 Projects 任一列表頁
`ListWorkbench.Header` MUST 置頂顯示並同時呈現 Title（24px/600）、Description（14px/regular）、Primary Action（最多 1 個）與 Secondary Action 區（可含多個按鈕或下拉）。Header MUST 覆蓋 `ant-card-head-wrapper` 並套用 `list-workbench-card-head` class，使 padding 固定為 `12px 20px`、背景 `var(--lw-surface)`、底線 `1px solid var(--lw-border-subtle)`。Primary 行動（如「新增專案」「匯出結果」）永遠靠右，Secondary 行動排列於其左；若 Primary 不適用需保留 disabled 狀態按鈕以維持對齊。Header MUST 支援 `meta` slot 並即時顯示總筆數或選取數 badge，三個頁面都必須填入與結果同步的數字。

### Requirement: Filter Card
列表頁的所有搜尋與篩選條件都 MUST 放入標準化的 `FilterCard` 中，以確保操作入口與清除行為一致。
#### Scenario: 使用者在任一列表頁調整篩選條件
篩選 UI MUST 包在 `FilterCard`（基於 Ant `Card`、`variant="outlined"`）內，Card 標題固定為「條件設定」，extra slot 右對齊 `清除篩選` 按鈕。FilterCard MUST 內建「Basic rows + Advanced rows」結構；Study Search 的進階欄位 MUST 改由 `collapse` props 控制，開關按鈕統一位於 Card footer。清除篩選行為 MUST 回復到頁面 `INITIAL_QUERY` 並觸發 `ListViewProvider` refresh，同時使用 `message.success('篩選已重設')` 提示，三頁面都要沿用此流程。輸入元件的 gutter MUST 固定為 12px；行動版時 MUST 自動切換為單欄垂直排列。

### Requirement: Results Card
所有結果、空狀態與分頁資訊 MUST 共用 `ResultsCard`，以統一狀態列、行動列與分頁擺放位置。
#### Scenario: 任一列表頁顯示結果或空狀態
任何結果內容都 MUST 放入 `ResultsCard`（Ant `Card variant="outlined"`），title 顯示「xxx 列表」，extra 顯示「共 N 筆記錄」，並將 `ant-card-head-wrapper` 轉成 `list-workbench-card-head` class。`ResultsCard` MUST 提供 `statusBar` slot（顯示 loading/error/selection badges）與 `actions` slot（右對齊批次操作、欄位設定、view mode 等）；三頁面皆需實作這兩個 slot，至少要覆蓋 loading spinner、API 失敗時的 `Alert`，以及空清單提示。Body 區域 MUST 容納 Table 或 Grid，Projects 的 grid/list 切換開關 MUST 移入 `actions` slot，不得再懸浮於其他區域。`ListViewPagination` MUST 放在 ResultsCard footer，並在行動版置中顯示。

### Requirement: 批次選擇與匯出入口
批次操作（包含選取、匯出、欄位設定、更多動作）MUST 集中在 ResultsCard 的統一入口，避免每頁重新發明互動模式。
#### Scenario: 使用者在列表中進行批次行為
三頁面皆 MUST 於 `ResultsCard.actions` slot 中呈現「批次行為群組」，至少包含 selection indicator（`已選 X 筆`）、Primary 批次動作（依頁面而定）與 Secondary 動作（更多/欄位設定）。Study Search 的 Selection Drawer、Projects 的匯出與 CRUD、Reports 的預覽都 MUST 由此群組觸發，並同步 `ListViewStore` selection 狀態，以確保 badge 數字即時更新。若某頁面暫不提供批次行為（例如 Reports），該群組 SHALL 轉為 disabled button 搭配 Tooltip「功能即將推出」以維持一致佈局。匯出行為 MUST 共用 `ExportFileDialog`（或其抽象層），呼叫方式相同且在下載完成後以 `message.success` 告知。

