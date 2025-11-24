## ADDED Requirements

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

