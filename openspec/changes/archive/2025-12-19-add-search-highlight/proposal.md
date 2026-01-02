# Change: 添加搜尋文字高亮顯示功能

## Why
目前在 Report、ProjectResource 和 Study 的搜尋功能中，使用者雖然可以輸入搜尋條件並獲得篩選後的結果，但在詳情頁面中無法快速定位哪些文字是符合搜尋條件的。這導致使用者需要自行掃視整個頁面來尋找相關資訊，降低了搜尋功能的實用性和使用者體驗。

添加搜尋文字高亮功能（以顏色標記和加粗）可以讓使用者一目了然地看到搜尋結果中的關鍵資訊，提升資訊查找效率。

## What Changes
- **Report 搜尋高亮**：
  - 在 `/reports` 列表與 `ReportDetailDrawer` 中高亮顯示符合基本搜尋與多條件進階搜尋（QueryBuilder / filters）的文字
  - 使用黃色背景 (#fff566) 和加粗字體來標記匹配文字

- **ProjectResource 搜尋高亮**：
  - 在 `ProjectResourceWorkbench` 列表與 `ProjectResourceDetailDrawer` 中高亮顯示符合搜尋條件的文字（含 snippet）
  - 使用相同的視覺樣式保持一致性

- **Study 搜尋高亮**：
  - 在 `/study-search` 列表與 `StudyDetailDrawer` 中高亮顯示符合搜尋條件的文字
  - `Verified Report` 區塊（`ReportStatusBadge`）內的報告標題/內容也會套用同樣高亮
  - 使用相同的視覺樣式保持一致性

- **Projects 列表高亮**：
  - 在 `/projects` 的 `ProjectCard`（名稱/描述/標籤）中高亮顯示符合搜尋條件的文字

- **共用高亮組件**：
  - 創建可重用的 `HighlightText` 組件
  - 支援多個搜尋關鍵字的高亮顯示
  - 處理大小寫不敏感的匹配

## Impact
- **Affected specs**: 
  - `report-search` - 添加搜尋高亮需求
  - `report-study-search` - 添加搜尋高亮需求（含 Verified Report 區塊）
  - `project-search-ui` - Projects 列表搜尋結果高亮
  - `project-resource-search` - 專案資源列表/詳情搜尋高亮
- **Affected code**:
  - `frontend/src/pages/ReportSearch/index.tsx` - 列表欄位高亮與關鍵字收集（basic/multi）
  - `frontend/src/components/Reports/ReportDetailDrawer.tsx` - 整合高亮功能
  - `frontend/src/pages/StudySearch/index.tsx` - 列表欄位高亮與關鍵字收集
  - `frontend/src/components/Projects/ProjectResourceDetailDrawer.tsx` - 整合高亮功能
  - `frontend/src/pages/Projects/Detail/ProjectResourceWorkbench.tsx` - 列表欄位與 snippet 高亮一致
  - `frontend/src/components/StudySearch/StudyDetailDrawer.tsx` - 整合高亮功能
  - `frontend/src/components/StudySearch/ReportStatusBadge.tsx` - Verified Report 區塊高亮一致
  - `frontend/src/pages/Projects/index.tsx` - Projects 列表傳遞高亮關鍵字
  - `frontend/src/components/Projects/ProjectList.tsx` / `ProjectCard.tsx` - Projects 列表文字高亮
  - `frontend/src/components/Common/HighlightText.tsx` - 新建共用組件
  - `frontend/src/store/reportStore.ts` - 傳遞搜尋關鍵字
  - `frontend/src/store/projectStore.ts` - 傳遞搜尋關鍵字
  - `frontend/src/store/studyStore.ts` - 傳遞搜尋關鍵字
- **Breaking changes**: 無
- **Migration**: 無需遷移，為現有功能的增強

