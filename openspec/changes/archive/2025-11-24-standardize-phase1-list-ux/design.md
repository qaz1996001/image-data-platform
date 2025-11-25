---
change-id: standardize-phase1-list-ux
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Architectural Scope

統一列表頁牽涉 `frontend/src/pages/{Reports,StudySearch,Projects}`、共用 `ListViewProvider` store、批次操作工具（`batchActionsRegistry`）、以及多個 Ant Design `Card` + `Table`/`List` 元件。提案透過在 `@components/Common` 新增 `ListWorkbench`、`ListWorkbenchHeader`, `FilterCard`, `ResultsCard` 等可組合組件，並更新各頁使用同一個殼層樣式（CSS token + `ant-card-head-wrapper` class）。

## 1. 現況盤點

| 頁面 | Header/Actions | Filters | Results/Selection |
| ---- | -------------- | ------- | ----------------- |
| Reports | Card + `清除篩選` 按鈕，無主動作 | `ReportSearchForm` 直接放在 Card 內 | `ListViewTable` + 分頁，無批次操作 |
| Study Search | Card + 匯出/加入專案/欄位設定/Selection Drawer 等多個按鈕 | `StudySearchForm`（Basic + Advanced） | `ListViewTable` + Selection Drawer + Drawer 詳情 |
| Projects | Hero 標頭 + Filters + view mode + CRUD 按鈕 | `ProjectFilters`（自訂 layout） | `ProjectList` (grid/list) + 分頁，無 Card 包裝 |

痛點：缺乏一致的標頭 padding、行動排列、狀態標示；Filters 與 Results 無共通 slot；CSS 需多處覆蓋 `ant-card-head-wrapper`。

## 2. List Workbench 提案

```
<ListWorkbench>
  <ListWorkbench.Header
    title="Reports"
    description="..."
    primaryAction={<Button type="primary" />}
    secondaryActions={<Space>...</Space>}
    meta={<Badge />}
  />
  <ListWorkbench.Body>
    <FilterCard>{form}</FilterCard>
    <ResultsCard
      title="報告列表"
      summary={<span>共 X 筆</span>}
      statusBar={<StatusChips />}
      actions={<Space>{batch buttons}</Space>}
    >
      {table | grid}
    </ResultsCard>
  </ListWorkbench.Body>
</ListWorkbench>
```

- `ListWorkbench` 控制整體 padding（desktop 24px、mobile 16px）與背景色。  
- Header 規範 `ant-card-head-wrapper` 風格：高度 64px、title font 20px、描述 14px、actions 右對齊。將對應 CSS class `list-workbench-head` 套用於 `Card`。  
- `FilterCard`：固定使用 Ant `Card`（outlined），body padding 16px，標頭 extra 位置預留給 `Clear filters`。支援 `collapsible` 旗標，供 Study Search advanced filters 使用。  
- `ResultsCard`：同樣 `Card`。`extra` 顯示總數/選取數；`body` 上方有 `statusBar` slot（例如 loading/selection badges），下方 slot 供 table 或 grid；最後 `footer` slot放分頁。

## 3. 行為與差異化

- **批次選擇**：Study Search 原有 selection drawer；Reports 尚未實作，但 UI 上將放置灰化的「批次操作」群組，以提醒此頁未啟用（可在 spec 中標註 optional）。Projects 若暫不支援 selection，可於 `ResultsCard.actions` 只放 CRUD 按鈕。  
- **View Mode**：Projects 可在 `ResultsCard.statusBar` 右側放 Radio 切換，不影響 shell。  
- **欄位設定 / 匯出**：統一放在 `ResultsCard.actions`，以 `Space` 右對齊，Study Search/Reports/Projects 依需求顯示。

## 4. CSS / Tokens

- 新增 `list-workbench.less`：定義 `--lw-header-padding`, `--lw-card-gap`, `--lw-status-bg`。  
- 指定 `ant-card-head-wrapper.list-workbench-card-head { padding: 12px 16px; border-bottom: 1px solid var(--lw-border); }`，避免各頁自行覆蓋。  
- 將現有頁面的自訂 CSS（`StudySearch.css`, `Reports/index.css` 等）調整為引用這些 tokens。

## 5. 互動與狀態

- Loading：`ResultsCard` 頂部顯示 `Spin` + 描述文字，替換現有 scattered spinner。  
- Error：於 `ResultsCard` 內統一 `Alert` 元件（type="error"），使用 spec 定義訊息。  
- Empty：若無查詢條件 → 顯示提示標語；若查詢後無結果 → 顯示 "沒有符合條件"；且 `ListViewTable`/`ProjectList` 共同使用 `ListEmptyState` 組件。

## 6. 遷移策略

1. **基礎元件**：在 Common 套件建立 `ListWorkbench/*`，並撰寫 Storybook/MDX 資訊（如有）。  
2. **Reports 與 Study Search**：因已使用 Card + Table，優先遷移並確認 selection/欄位設定 slot。  
3. **Projects**：最後遷移，將 Hero + Filters + List 匯入 Workbench slots，同步調整 view mode/CRUD 按鈕位置。  
4. **文件與測試**：更新 `docs/requirements/02_FRONTEND_PRD_SR_SD.md` + `frontend/docs` feature guides，並新增 Playwright 流程。

## 7. 待確認事項

- Projects grid/list 切換 UI 是否需要額外設計稿。  
- Reports 是否在此階段啟用批次選擇/匯出；若否，須在 spec 裡標示 optional actions。  
- Selection Drawer 在行動版的放置方式（仍為 Drawer；Header actions 只留入口）。

## 8. Component API 草稿

| 組件 | 主要 props | 說明 |
| --- | --- | --- |
| `ListWorkbench` | `children`, `className?`, `style?` | 控制整體背景與 padding，通常包住 Header + Body。 |
| `ListWorkbench.Header` | `title: string`, `description?: string`, `primaryAction?: ReactNode`, `secondaryActions?: ReactNode`, `meta?: ReactNode` | 渲染於 `ant-card-head-wrapper`，primary 預留 disabled button 以維持結構。 |
| `ListWorkbench.Body` | `children`, `gap?: number` | 以 CSS Grid 控制 FilterCard、ResultsCard 間距。 |
| `FilterCard` | `title?: string`, `extra?: ReactNode`, `collapsible?: boolean`, `defaultExpanded?: boolean`, `onClear?: () => void` | 包裹篩選表單與進階區；預設 title「條件設定」，extra 放清除按鈕。 |
| `ResultsCard` | `title: string`, `summary?: ReactNode`, `statusBar?: ReactNode`, `actions?: ReactNode`, `footer?: ReactNode`, `children: ReactNode` | 呈現結果列表或網格；`summary` 映射到 Card extra。 |
| `StatusBar` | `items: Array<{ type: 'info' | 'success' | 'warning' | 'error'; label: string; icon?: ReactNode }>` | 用於 ResultsCard.statusBar slot，提供統一的 badge/顏色。 |

樣式集中於 `list-workbench.less`，定義 `--lw-surface`, `--lw-border`, `--lw-header-padding`, `--lw-card-gap`, `--lw-status-bg`, `--lw-status-border` 等 token，供各組件引用。Header/FilterCard/ResultsCard 需帶 `list-workbench-card-head` 或 `list-workbench-card` class 讓 token 生效。

## 9. 統一列表頁佈局（Reports / Study / Projects）

> 本節僅為規劃與設計說明，不代表最終採用方案；若與現有頁面使用空間或 UX 衝突，需由 PM/設計確認後再進入 apply 階段。

### 9.1 現況差異（以 2025-11-24 截圖為準）

- **Reports**：較緊湊的搜尋區塊（標題「報告檢索」），下方是報告列表 Card，右上只顯示「共 N 筆報告」與清除篩選；無全選/取消與欄位設定按鈕。  
- **Study**：頁面標題「檢查搜尋」，Header 有加入專案/匯出等主動作；結果區上方有工具列，包含「欄位設定」＋「全選/取消」＋「已選清單」與批次操作，佈局較豐富。  
- **Projects**：Hero + Filters + 列表（grid/list 切換），尚未使用 ListWorkbench，Header 與結果工具列都採自訂結構。

### 9.2 建議的共用佈局（List Layout v2）

為避免未經確認即改動既有使用空間，List Layout v2 僅作為後續協調的統一目標：

1. **頁面 Header（共用）**  
   - Title/Description/Meta（總筆數徽章）置於頁面最上方。  
   - Primary action：單一主按鈕（例如 Reports 的「匯出」、Projects 的「New Project」、Study 的「匯出」）。  
   - Secondary actions：例如「加入專案」「建立專案」等，統一放在 Primary 左側。  
   - 此 Header 需可直接套用到 Projects（將現有 Hero 行為收斂到此區）。

2. **搜尋／篩選區（FilterCard）**  
   - Reports/Study/Projects 均採用同一個 `FilterCard` 佈局：標題列 + 基礎欄位 +（可選）進階區塊。  
   - 清除篩選按鈕一律位於 Card head extra；實際文字/圖示可由 UX 決定（如「清除篩選」「重設」等）。

3. **結果區（ResultsCard + 工具列）**  
   - ResultsCard 頂部為單一工具列 Row，左側主要呈現狀態（`StatusBar`：loading/error/空結果/已選數量），右側放置操作群組。  
   - **操作群組（適用 Reports / Study / Projects）**：  
     - 欄位設定：統一使用齒輪 icon（`SettingOutlined`）按鈕。  
     - 全選/取消：緊鄰欄位設定，以「全選 / 取消」雙鍵呈現（size small），套用在具有選取能力的頁面（Study、Reports 未來如支援選取、Projects 如支援批次操作）。  
     - 其他批次/快捷動作：如「加入專案」「已選清單」「批次操作」等，依頁面功能放在同一列中，但不得再另起一行或漂浮到結果卡片外。

4. **分頁與統計**  
   - 統計文字（共 N 筆）一律放在 ResultsCard title/extra 中，而非頁面其他位置。  
   - 分頁元件 (`ListViewPagination`) 一律放在 ResultsCard footer，桌機版右對齊、行動版置中；三頁面共用。

### 9.3 Projects 頁面優先落實策略

- Projects 將作為 List Layout v2 的首個實作目標：  
  1. 先在設計/原型中將現有 Hero + Filters + List 映射到 ListWorkbench.Header + FilterCard + ResultsCard。  
  2. 確保 grid/list 切換、Export、New Project 等動作，都能自然放進 Header 與 ResultsCard 工具列。  
  3. 經確認後，再以相同佈局套用回 Reports 與 Study（避免重複調整）。  
- 若 Projects 實作過程發現 layout 無法滿足實際需求，須在此設計文件中調整 List Layout v2 再進一步 apply，其間避免直接修改 Study/Reports 的既有佈局。

## 10. Projects 專用 List Layout v2 規格（供後續頁面參照）

> 對應文件：  
> - 系統層 PRD：[`01_SYSTEM_PRD_SR_SD.md#SYS-PRD-003`](01_SYSTEM_PRD_SR_SD.md#SYS-PRD-003) 專案管理與資料匯出  
> - 前端層 PRD：[`02_FRONTEND_PRD_SR_SD.md`](02_FRONTEND_PRD_SR_SD.md) 中 FE-PRD-005 專案管理與匯出操作  
> - 前端層 SR：同文件 FE-SR-050（專案列表）、FE-SR-060（匯出操作）  
> - 前端層 SD：本節與 `02_FRONTEND_PRD_SR_SD.md` 第 5 章「Project 模組」共同構成 Projects 列表頁的 SD

本節定義「Projects 版」List Layout v2 的具體欄位與行為，未來 **Study Search**、**Reports** 或新頁面可以沿用同一組介面，只是替換不同的按鈕與狀態來源（OOP／組合式設計）。

### 10.1 Projects Page 結構樹

```
<ListWorkbench>
  <ListWorkbench.Header
    title="Projects"
    description="Manage and organize your imaging data projects"
    primaryAction={<Button type="primary">New Project</Button>}
    secondaryActions={
      <Space>
        <Button icon={<DownloadOutlined />}>Export</Button>
      </Space>
    }
    meta={<Badge count={totalProjects} />}
  />

  <ListWorkbench.Body>
    <FilterCard
      title="條件設定"
      onClear={handleClearFilters}
    >
      <ProjectFilters ... />
    </FilterCard>

    <ResultsCard
      title="專案列表"
      summary={<span>共 {totalProjects} 個專案</span>}
      statusBar={<StatusBar items={statusItems} />}
      actions={<ProjectsActionsToolbar ... />}
      footer={<ListViewPagination ... />}
    >
      <ProjectList viewMode={viewMode} ... />
    </ResultsCard>
  </ListWorkbench.Body>
</ListWorkbench>
```

### 10.2 Header 行為（Projects 作為範例配置）

- `title` / `description`：每個頁面 MUST 提供語意清楚的標題與一句描述（Projects: 「Projects」＋「Manage and organize your imaging data projects」）。  
- `meta`：顯示總筆數或關鍵統計（Projects: `totalProjects` badge）。  
- `primaryAction`：Projects 為「New Project」，其他頁面可替換為「匯出」或「新增 xxx」，但 **只能有一個 Primary**。  
- `secondaryActions`：Projects 預設包含「Export」按鈕；Study/Reports 可在此放「加入專案」「批次匯出」等。新增頁面只需實作自己的 secondary actions，無須改動 Layout 結構。

> 後續頁面只要實作一個 `buildHeaderActions(config)` 函數（或等效組合），傳入各自的 primary/secondary 內容，即可共用此 Header 槽位。

### 10.3 FilterCard 規格（可沿用至 Study / Reports）

- Projects 使用現有 `ProjectFilters` 元件，直接作為 `FilterCard` 的 `children`。  
- `FilterCard` MUST：  
  - 在 head 顯示 title（預設「條件設定」）。  
  - 將「清除篩選」行為集中在 extra（Projects: 對應現有 ClearButton 行為）。  
  - 對應列表的初始 query／filters，清除時同時 reset ListView 與本地 filter store。  
- Study / Reports 未來只需將各自的 `StudySearchForm`／`ReportSearchForm` 放入 `FilterCard`，並實作相同的 `onClear` 協定即可。

### 10.4 ResultsCard + 工具列（Projects 版）

#### 10.4.1 StatusBar 規格

`statusItems: StatusBarItem[]` 來源建議如下：

- `loading`：`{ type: 'info', label: '資料載入中' }` 當 ListView `loading=true`。  
- `error`：`{ type: 'error', label: '載入失敗' }` 若有 API 錯誤；可加上 Tooltip 顯示詳細訊息。  
- `empty`：`{ type: 'warning', label: '沒有符合條件的專案' }` 查詢後 total=0。  
- `selection`（若之後 Projects 支援選取）：`{ type: 'success', label: '已選 N 筆' }`。

Reports / Study 可直接沿用同一組型別與語彙，只是 label 文案依頁面角色調整（「報告」「檢查」等）。

#### 10.4.2 Actions Toolbar 規格

Projects 工具列建議組成：

- **欄位設定**：齒輪按鈕（`SettingOutlined`），開啟 Columns 管理對話框。  
- **全選 / 取消**（若有 selection）：兩個緊鄰的 small 按鈕，文字固定為「全選」「取消」，點擊行為統一呼叫 ListView 的 `selectAllCurrentPage()` / `clearSelection()`。  
- **其它動作**：  
  - 「Export」：可選擇放在 Header secondary 或 Results actions，規格建議 **二擇一**，以避免重複。  
  - 「New Project」：維持在 Header Primary，以強調為全頁主動作。  

Study / Reports 只需提供自己的 `ActionsToolbar` 實作（例如 `StudyActionsToolbar`, `ReportsActionsToolbar`），並遵守：

- 欄位設定齒輪 + 全選/取消位置固定在最左側。  
- 其餘批次動作依頁面需求添加，保持在同一列右側，避免額外浮動工具列。

### 10.5 Layout Config 介面（供新頁面沿用）

為方便後續新頁面沿用，建議（在實作層）抽象出一個「列表頁配置」介面，設計 doc 中提供參考型別（非強制代碼）：

```ts
type ListPageHeaderConfig = {
  title: string
  description?: string
  buildPrimaryAction?: () => ReactNode
  buildSecondaryActions?: () => ReactNode
  buildMeta?: () => ReactNode
}

type ListPageLayoutConfig = {
  header: ListPageHeaderConfig
  renderFilters: () => ReactNode
  buildStatusItems: () => StatusBarItem[]
  renderResults: () => ReactNode    // Table / Grid / Cards
  renderActionsToolbar: () => ReactNode
  renderFooter: () => ReactNode     // Pagination / summary 等
}
```

Projects 可先實作一個 `projectsListLayoutConfig: ListPageLayoutConfig`，Study / Reports 後續只要定義相同 shape 的 config，並共用一個 `ListPageLayout` 組件，即可在不改變 ListWorkbench 殼層的情況下支援不同頁面的按鈕與行為（OOP／組合延伸）。

