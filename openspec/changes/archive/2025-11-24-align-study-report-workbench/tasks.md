## 1. 共用組件與樣式
- [x] 1.1 調整 `@components/ListWorkbench/ResultsCard`，限制 `list-workbench-actions-area` 只能顯示欄位設定與 Drawer 觸發器，必要時新增 `actionsVariant` props。
- [x] 1.2 新增或重構共用 `SelectionDrawer` 組件（含批次行為群組 slot），讓 Study Search / Reports 以相同 API 使用。
- [x] 1.3 更新 `list-workbench.css` token，確保 `actions-area` 與 Drawer 觸發按鈕在桌面與行動裝置皆不換行。

## 2. Study Search / Reports 串接
- [x] 2.1 Study Search：改用共用 Drawer，將「加入專案」與加選批次按鈕移入 Drawer，`ResultsCard.actions` 只保留欄位設定 + Drawer 入口。
- [x] 2.2 Reports：移除 `list-workbench-actions-area` 的匯出/列印/歸檔/刪除按鈕；改在 Drawer 內提供對應批次行為與可用動作列表。
- [x] 2.3 調整兩頁 Header `meta` 與 Drawer badge 顯示邏輯，保持統一字詞（`Selected List` / `選擇清單`）。

## 3. 驗證
- [x] 3.1 更新/新增 Storybook 或 screenshot 測試，覆蓋 `ListWorkbench` 兩種頁面。
- [x] 3.2 於 WSL + pnpm 執行 `pnpm lint && pnpm test && pnpm build`。
- [x] 3.3 人工驗證 Study Search 與 Reports：桌面/行動視窗切換、批次行為在 Drawer 觸發、欄位設定與 badge 同步。
  - **完成時間**: 2025-11-25
  - **完成說明**: ListWorkbench 組件已完整實作並在 StudySearch、ReportSearch、Projects 等 5 個頁面成功導入；規格文件已更新至 `docs/requirements/02_FRONTEND_PRD_SR_SD.md` 與 `openspec/specs/list-workbench-components/spec.md`。

