# Implementation Priority & Status

## 已完成任務 ✅

### 1. Results Actions Parity (Foundation)
- ✅ **audit-results-actions**: 已完成清點 Study/Report 的 resultsActions 和 Selection Drawer 流程
  - Study Search: 使用 `useBatchActions` + `batchActionsRegistry` (6個actions)
  - Report Search: 使用 `useReportBatchActions` + `reportBatchActionsRegistry` (5個actions)
  - SelectionDrawer: 通用組件，可重用
  - Column Manager: `useColumnManager` hook，可重用

### 2. Backend Aggregation & Canonical Key
- ✅ **accession-resolver**: `AccessionKeyResolver` 已實作在 `backend_django/project/services/accession_resolver.py`
- ✅ **aggregate-endpoint**: `GET /projects/{id}/resources` 已實作在 `backend_django/project/api.py`
- ✅ **resource-aggregator**: `ResourceAggregator` 已實作在 `backend_django/project/services/resource_aggregator.py`

### 3. Unified Resource Workbench (Frontend)
- ✅ **resource-provider**: `ProjectResourceListViewProvider` 已實作
- ✅ **resource-selector**: `ResourceSelector` 組件已存在
- ✅ **replace-tabs**: `ProjectResourceWorkbench` 組件已存在並在使用中

## 待完成任務

### 優先級 1: 確保 Actions 可重用性
- [ ] **reuse-results-actions**: 確保 StudyList 和 ReportList 的 actions 可以在 unified workbench 中重用
  - 需要：將 `useBatchActions` 泛型化以支援混合資源類型
  - 需要：創建統一的 batch action registry 用於 project resources

### 優先級 2: 完善 Unified Workbench
- [ ] **mixed-results-table**: 更新 ResultsCard 以處理混合欄位
  - 需要：實作基於 active resource types 的 column config merger
  - 需要：確保 column manager 可以處理混合資源類型

### 優先級 3: 清理和驗證
- [ ] **remove-tabs**: 更新 ProjectDetailLayout 移除舊的 tab navigation（當 Workbench 穩定後）
- [ ] **e2e-tests-workbench**: 添加 E2E 測試
- [ ] **validate-spec-workbench**: 運行 openspec validate

## 與 unify-projects-search-ux 的關係

`unify-projects-search-ux` 可以在 `unify-project-resource-workbench` 的基礎上進行，因為：
1. `ProjectResourceWorkbench` 已經有 `SearchInput` 組件
2. 需要將相同的搜索 UX 應用到 `ProjectStudyList` 和 `ProjectReportList`
3. 這兩個任務可以並行進行，因為它們主要影響不同的頁面

## 建議的實作順序

1. **先完成 reuse-results-actions** - 這是 unified workbench 的基礎
2. **然後進行 mixed-results-table** - 完善 unified workbench 的功能
3. **同時進行 unify-projects-search-ux** - 統一搜索 UX（獨立任務）
4. **最後進行清理和驗證** - 移除舊代碼，添加測試

