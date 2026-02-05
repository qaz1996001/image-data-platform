# unified-list-workbench Specification

## Purpose

為 Image Data Platform 的三個主要列表頁面（Reports、Study Search、Projects）建立統一的佈局與互動模式，透過可重用的 `ListWorkbench` 組件家族，確保：
1. **視覺一致性** - 統一的 Header、FilterCard、ResultsCard 樣式與間距
2. **使用者體驗一致** - 統一的篩選、排序、選取、匯出、欄位設定操作流程
3. **開發效率** - 減少每頁重複實作相同 UI 邏輯，便於未來新列表頁面快速上線
4. **無障礙存取與響應式設計** - 支援桌機與行動版自動調整、深色模式

本規格詳述了 ListWorkbench 組件的結構、slot、CSS 變數、與三頁面的適配方案。
## Requirements
### Requirement: List Workbench Header
所有列表頁 MUST 共享同一個 Header 組件，以維持標題、描述、行動按鈕與 meta 資訊的一致樣式與位置。
#### Scenario: 使用者開啟 Reports、Study Search 或 Projects 任一列表頁
`ListWorkbench.Header` MUST 置頂顯示並同時呈現 Title（24px/600）、Description（14px/regular）、Primary Action（最多 1 個）與 Secondary Action 區（可含多個按鈕或下拉）。Header MUST 覆蓋 `ant-card-head-wrapper` 並套用 `list-workbench-card-head` class，使 padding 固定為 `12px 20px`、背景 `var(--lw-surface)`、底線 `1px solid var(--lw-border-subtle)`。Primary 行動（如「新增專案」「匯出結果」）永遠靠右，Secondary 行動排列於其左；若 Primary 不適用需保留 disabled 狀態按鈕以維持對齊。Header MUST 支援 `meta` slot 並即時顯示總筆數或選取數 badge，三個頁面都必須填入與結果同步的數字。

### Requirement: Filter Card
列表頁的所有搜尋與篩選條件都 MUST 放入標準化的 `FilterCard` 中，以確保操作入口與清除行為一致。
#### Scenario: 使用者在任一列表頁調整篩選條件
篩選 UI MUST 包在 `FilterCard`（基於 Ant `Card`、`variant="outlined"`）內，Card 標題固定為「條件設定」，extra slot 右對齊 `清除篩選` 按鈕。FilterCard MUST 內建「Basic rows + Advanced rows」結構；Study Search 的進階欄位 MUST 改由 `collapse` props 控制，開關按鈕統一位於 Card footer。清除篩選行為 MUST 回復到頁面 `INITIAL_QUERY` 並觸發 `ListViewProvider` refresh，同時使用 `message.success('篩選已重設')` 提示，三頁面都要沿用此流程。輸入元件的 gutter MUST 固定為 12px；行動版時 MUST 自動切換為單欄垂直排列。

### Requirement: Results Card
所有結果、空狀態與分頁資訊 MUST 共用 `ResultsCard`，並限制操作區只能呈現欄位設定與 Selected Drawer 入口，避免批次行為在卡片頭部擁擠。

#### Scenario: 任一列表頁顯示結果或空狀態
- `ResultsCard` MUST 以 `Card variant="outlined"` 呈現，title 顯示「xxx 列表」，extra 顯示「共 N 筆記錄」，並將 `ant-card-head-wrapper` 轉成 `list-workbench-card-head` class。
- `ResultsCard` MUST 提供 `statusBar` slot（顯示 loading/error/selection badges）與 `actions` slot，但 `actions` slot SHALL 只包含：`SettingOutlined` 欄位設定按鈕、Selected Drawer 觸發按鈕（含 badge），以及一個可選的 meta badge；其他批次行為按鈕 MUST NOT 直接顯示於此區域。
- `list-workbench-actions-area` SHALL 維持單列排列，最少間距 8px，若按鈕超過 2 個 SHALL 收斂為 `Dropdown` 或 Drawer 入口；在 360px 行動寬度也不得換行到第二列。
- Body 區域 MUST 容納 Table 或 Grid，Projects 的 grid/list 切換開關 MUST 移入 `actions` slot 的 Drawer 入口內（若仍需要），避免另起懸浮按鈕。
- `ListViewPagination` MUST 放在 ResultsCard footer，並在行動版置中顯示。

#### Scenario: Reports 列表套用統一 actions 行為
- Reports 列表在 `ResultsCard.actions` 內只能顯示欄位設定 icon 與 Selection Drawer 入口；原本位於此區的匯出/列印/歸檔/刪除/清除選擇按鈕 MUST 移除。
- Reports Drawer 內的批次行為（匯出、列印、歸檔、刪除） SHALL 由 Drawer 內容呈現，並同步顯示 `已選 X 筆` badge，以與 Study Search 一致。

### Requirement: 批次選擇與匯出入口
Study Search 的「全選全部」行為 MUST 允許透過設定值控制一次抓取與選取的最大筆數，預設 9,999。

#### Scenario: 使用者在 Study Search 點擊「全選全部」且總筆數 <= 上限
- 給定 `STUDY_SEARCH_FULL_SELECT_CAP = 9,999`
- 且當前查詢的總筆數 `total = 5,485`
- 當使用者點擊 ResultsCard summary 旁的「全選全部」按鈕
- 則前端 MUST 以 `page_size = min(total, cap)` 呼叫後端並成功選取所有 5,485 筆
- 並顯示成功提示「已選取全部 5,485 筆」

#### Scenario: 總筆數超過上限
- 給定 `cap = 9,999`
- 且 `total = 25,000`
- 當使用者點擊「全選全部」
- 則系統 MUST 只抓取並選取 cap 筆資料（9,999）
- 並顯示警示訊息「已選取 9,999 筆，上限已達；請縮小篩選」
- 按鈕文案 MUST 仍提供「取消全選」以清除這 9,999 筆

#### Scenario: 管理者需要調整上限
- 給定 build-time 或 runtime 可覆寫 `STUDY_SEARCH_FULL_SELECT_CAP`
- 當設定為 `cap = 2,000`
- 則 summary 按鈕文案 MUST 改為「全選全部 (最多 2,000 筆)」
- 所有上述成功與超出上限行為 MUST 以新 cap 值為準

