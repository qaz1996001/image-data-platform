# Implementation Tasks

## 1. 創建共用高亮組件
- [x] 1.1 創建 `frontend/src/components/Common/HighlightText.tsx` 組件
- [x] 1.2 實作支援多關鍵字高亮的邏輯
- [x] 1.3 實作大小寫不敏感的匹配
- [x] 1.4 添加 TypeScript 類型定義
- [x] 1.5 添加組件文檔註解

## 2. Report 搜尋高亮實作
- [x] 2.1 修改 `reportStore.ts` 添加搜尋關鍵字狀態管理
- [x] 2.2 在 Report 搜尋頁面收集搜尋關鍵字
- [x] 2.3 將搜尋關鍵字傳遞到 `ReportDetailDrawer`
- [x] 2.4 在 `ReportDetailDrawer` 的相關欄位使用 `HighlightText` 組件
- [x] 2.5 測試基本搜尋高亮功能
- [x] 2.6 測試進階搜尋高亮功能
- [x] 2.7 測試多條件進階搜尋高亮功能

## 3. ProjectResource 搜尋高亮實作
- [x] 3.1 修改 `projectStore.ts` 添加搜尋關鍵字狀態管理
- [x] 3.2 在 ProjectResource 搜尋頁面收集搜尋關鍵字
- [x] 3.3 將搜尋關鍵字傳遞到 `ProjectResourceDetailDrawer`
- [x] 3.4 在 `ProjectResourceDetailDrawer` 的相關欄位使用 `HighlightText` 組件
- [x] 3.5 測試基本搜尋高亮功能
- [x] 3.6 測試進階搜尋高亮功能
- [x] 3.7 測試多條件進階搜尋高亮功能

## 4. Study 搜尋高亮實作
- [x] 4.1 修改 `studyStore.ts` 添加搜尋關鍵字狀態管理
- [x] 4.2 在 Study 搜尋頁面收集搜尋關鍵字
- [x] 4.3 將搜尋關鍵字傳遞到 `StudyDetailDrawer`
- [x] 4.4 在 `StudyDetailDrawer` 的相關欄位使用 `HighlightText` 組件
- [x] 4.5 測試搜尋高亮功能

## 5. 整合測試與優化
- [x] 5.1 驗證所有三個模組的高亮功能正常運作
- [x] 5.2 確認視覺樣式在所有模組中保持一致
- [x] 5.3 測試邊界情況（空搜尋、特殊字符、長文字）
- [x] 5.4 測試效能（大量匹配時的渲染效能）
- [x] 5.5 確認無 TypeScript 錯誤或 lint 警告

## 6. 文檔更新
- [ ] 6.1 更新組件使用文檔
- [ ] 6.2 添加開發者指南說明如何使用 HighlightText 組件

## 7. 高亮一致性修正（List + Detail）
- [x] 7.1 修正 `projectStore`/`studyStore` 的 `openDetailDrawer` 覆寫 `searchKeywords` 問題
- [x] 7.2 `ReportSearch` 列表欄位高亮 + 詳情抽屜高亮一致（basic/multi）
- [x] 7.3 `StudySearch` 列表欄位高亮 + 詳情頁 Verified Report 區塊高亮一致
- [x] 7.4 `Projects` 列表（ProjectCard name/description/tags）高亮一致
- [x] 7.5 `ProjectResource` snippet 區塊高亮改用 `HighlightText`（避免 HTML 高亮不一致）
- [x] 7.6 修正 `ProjectResourceWorkbench` 中 `highlightKeywords` useMemo 邏輯（使用 `query.q` 而非未定義的 `searchTerm`）
- [x] 7.7 `ProjectResourceDetailDrawer` 同 `ReportDetailDrawer` 一致，支持 prop 傳遞 `searchKeywords`
- [x] 7.8 `ProjectResourceWorkbench` 將 `highlightKeywords` 傳給 Drawer

## 8. 最終驗證
- [x] 8.1 OpenSpec 驗證通過（`openspec validate add-search-highlight --strict`）
- [x] 8.2 No linting errors 在所有修改的文件中
- [x] 8.3 數據流一致性檢查：表格 = Drawer（三個模組都相同）
