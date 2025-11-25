# 變更：對齊 Study Search 與 Reports 的 List Workbench UX

## Why
- Study Search 與 Reports 目前在 `ListWorkbench` 的操作佈局不一致：欄位設定按鈕位置、批次操作入口與 Selected Drawer 命名皆不同，造成使用者切換頁面時需要重新學習。
- Reports 在 `list-workbench-actions-area` 內直接顯示匯出/列印/歸檔/刪除按鈕，與 spec 所要求的 Drawer 型批次入口不符，也造成桌面版佈局擠壓與行動版溢出。
- Reports 的 Selection Drawer 與 Study Search 的 Selected List 欄位、按鈕、狀態表示方式不同，導致設計系統無法共用樣式與邏輯。

## What Changes
- 統一 `ListWorkbench.results` 行為：只允許顯示「欄位設定」與「Selected Drawer 入口」，所有批次行為（匯出、列印、歸檔、刪除、加入專案等）都轉移至 Drawer。
- 共用一組 Selection Drawer 組件 API，確保 Study Search 與 Reports 均以一致的 props 命名、行動選單、操作優先順序。
- 將 Reports 的 `list-workbench-actions-area` 內部按鈕改為 Drawer 觸發，並同步使用 `SettingOutlined` icon 按鈕與 badge 樣式。
- 統一欄位設定觸發器、meta badge（顯示總筆數/已選筆數）與 Drawer 行為（支援選擇卡片、批次行為、清空、加入專案/匯出等）。
- 更新 CSS token 與 class 命名以保證所有頁面共用同一個 `list-workbench` 佈局。

## Impact
- 受影響規格：`unified-list-workbench`, `list-workbench-components`
- 受影響程式：`frontend/src/pages/StudySearch/index.tsx`, `frontend/src/pages/ReportSearch/index.tsx`, `@components/ListWorkbench`, `@components/Reports/ReportSelectionDrawer`, `@components/StudySearch/SelectedList`
- 需更新設計紀錄：Selection Drawer 組件 API、`list-workbench-actions-area` 的受限內容、批次操作流程

