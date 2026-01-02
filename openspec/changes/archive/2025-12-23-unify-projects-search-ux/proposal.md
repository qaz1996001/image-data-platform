# Change: Unify Projects Search UX

## Why
Projects 下的各個頁面目前使用不同的搜索 UX：
- `/projects` 列表頁面使用 `ProjectFilters` 組件（完整的搜索和篩選功能）
- `/projects/:projectId/resources` 使用 `SearchInput` + `ResourceSelector`（簡單的全文搜索）
- `/projects/:projectId/studies` 和 `/projects/:projectId/reports` 只有 TODO 註釋，沒有實際的搜索功能

這種不一致的體驗會讓用戶在不同頁面間切換時感到困惑，增加學習成本。用戶需要在 Projects 下的所有頁面都能使用一致的搜索和篩選體驗。

## What Changes
- **統一搜索組件**：
  - 為 Projects 下的所有頁面（resources, studies, reports）實作一致的搜索 UI
  - 參考 `ProjectResourceWorkbench` 的 `SearchInput` + `ResourceSelector` 模式
  - 確保所有頁面都使用相同的搜索輸入框和篩選器組件

- **功能實作**：
  - 在 `ProjectStudyList` 頁面實作搜索和篩選功能
  - 在 `ProjectReportList` 頁面實作搜索和篩選功能
  - 統一 `ProjectResourceWorkbench` 的搜索體驗，確保與其他頁面一致

- **UX 一致性**：
  - 所有頁面使用相同的 `FilterCard` 佈局
  - 所有頁面使用相同的搜索輸入框樣式和行為
  - 所有頁面使用相同的清除和重置功能

## Impact
- **Affected specs**: 
  - `view-project-study-list` - 需要添加搜索功能
  - `view-project-report-list` - 需要添加搜索功能
  - `project-resource-workbench` - 需要統一搜索 UX（如果存在相關規格）
- **Affected code**:
  - `frontend/src/pages/Projects/Detail/ProjectStudyList.tsx` - 添加搜索功能
  - `frontend/src/pages/Projects/Detail/ProjectReportList.tsx` - 添加搜索功能
  - `frontend/src/pages/Projects/Detail/ProjectResourceWorkbench.tsx` - 統一搜索 UX
  - `frontend/src/pages/Projects/Detail/SearchInput.tsx` - 可能需要增強或重構
  - `frontend/src/pages/Projects/Detail/ResourceSelector.tsx` - 可能需要增強或重構
- **Breaking changes**: 無
- **Migration**: 無需遷移，現有功能保持向後相容

