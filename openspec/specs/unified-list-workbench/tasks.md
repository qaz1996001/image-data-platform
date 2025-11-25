---
spec-id: unified-list-workbench-tasks
version: 1.0.0
status: active
created-at: 2025-11-24
updated-at: 2025-11-24
---

# unified-list-workbench — Tasks & Acceptance Criteria

> 本文件詳列實現 unified-list-workbench 規格所需的具體工作項目及其驗收標準。

---

## Task 總覽

| Task ID | 名稱 | 狀態 | 優先級 | 預估時間 | 負責人 |
|---------|------|------|--------|----------|--------|
| ULW-T-001 | 審核與批准所有規格文件 (spec/prd/sr/sd) | ✅ Completed | P0 | - | PM + Tech Lead |
| ULW-T-010 | ListWorkbench 組件基礎實現 | ✅ Completed | P0 | - | FE |
| ULW-T-020 | FilterCard 與進階篩選支援 | ✅ Completed | P0 | - | FE |
| ULW-T-030 | ResultsCard 與 StatusBar 實現 | ✅ Completed | P0 | - | FE |
| ULW-T-040 | SelectionDrawer 與 SelectionDrawerTrigger 實現 | ✅ Completed | P0 | - | FE |
| ULW-T-050 | ColumnSettingsDrawer 實現 (拖曳排序 + 顯示隱藏) | ✅ Completed | P1 | - | FE |
| ULW-T-060 | CSS 變數與樣式系統實現 | ✅ Completed | P0 | - | FE |
| ULW-T-070 | Reports 頁面遷移至 ListWorkbench | ✅ Completed | P0 | - | FE |
| ULW-T-080 | Study Search 頁面遷移至 ListWorkbench | ✅ Completed | P0 | - | FE |
| ULW-T-090 | Projects 頁面遷移至 ListWorkbench | ✅ Completed | P0 | - | FE |
| ULW-T-100 | 組件單元測試編寫 (80% 覆蓋率) | ✅ Completed | P1 | - | FE/QA |
| ULW-T-110 | Playwright E2E 測試編寫 | ✅ Completed | P1 | - | QA |
| ULW-T-120 | 深色模式支援與驗證 | ✅ Completed | P1 | - | FE |
| ULW-T-130 | 響應式設計驗證 (mobile/tablet/desktop) | ✅ Completed | P1 | - | QA |
| ULW-T-140 | 文件完成 (PRD/SR/SD + usage guide) | ✅ Completed | P1 | - | Tech Writer |
| ULW-T-150 | 效能優化與指標驗證 | ✅ Completed | P1 | - | FE |
| ULW-T-160 | 無障礙性 (a11y) 檢查 | ✅ Completed | P2 | - | QA |
| ULW-T-170 | 程式碼審查與合併 (PR) | ✅ Completed | P0 | - | Tech Lead |

---

## 已完成任務詳細說明

### ULW-T-001: 審核與批准所有規格文件

**狀態**: ✅ Completed

**內容**:
- 所有文件 (spec/prd/sr/sd/tasks/usage-guide) 已完成撰寫
- 經 PM 與 Tech Lead 審核並批准
- 文件已上傳至 OpenSpec

**驗收標準**:
- [ ] spec.md 內容完整，Purpose 更新
- [ ] prd.md 包含產品願景、功能需求、使用者故事、驗收標準
- [ ] sr.md 包含 ULW-SR-001 至 ULW-SR-500 的完整需求
- [ ] sd.md 包含架構、設計細節、資料流程、測試策略
- [ ] tasks.md (本檔案) 清楚列出所有工作項目
- [ ] 文件無重大語法或邏輯錯誤

---

### ULW-T-010: ListWorkbench 組件基礎實現

**狀態**: ✅ Completed

**內容**:
- 實現 `ListWorkbench` 複合組件，包含 `.Header` 與 `.Body` 子組件
- 建立 `frontend/src/components/ListWorkbench/ListWorkbench.tsx`
- 導出 `ListWorkbench`, `FilterCard`, `ResultsCard`, `StatusBar`

**驗收標準**:
- [ ] ListWorkbench.Header 可接收 title, description, primaryAction, secondaryActions, meta
- [ ] ListWorkbench.Body 可接收 children 與 gap 參數
- [ ] FilterCard 基於 Ant Card 實現，支援 variant="outlined"
- [ ] ResultsCard 包含 statusBar, actions, footer 三個區域
- [ ] StatusBar 可顯示 info/success/warning/error 四種狀態
- [ ] 組件無 TypeScript 錯誤，可正確編譯
- [ ] 組件導出自 `@components/ListWorkbench/index.ts`

**實現參考**:
```
frontend/src/components/ListWorkbench/ListWorkbench.tsx (1-239 行)
```

---

### ULW-T-020: FilterCard 與進階篩選支援

**狀態**: ✅ Completed

**內容**:
- FilterCard 支援 collapsible 屬性控制進階篩選展開/隱藏
- 實現「清除篩選」按鈕邏輯
- Study Search 頁面應用進階篩選

**驗收標準**:
- [ ] FilterCard 預設 title 為「條件設定」
- [ ] 當 collapsible=true 時，頁面底部顯示「顯示進階條件」/「隱藏進階條件」切換按鈕
- [ ] advancedContent 根據 expanded 狀態展開/隱藏
- [ ] extra 區顯示「清除篩選」按鈕，點擊時呼叫 onClear callback
- [ ] 行動版 (<768px) 自動變為單欄排列
- [ ] Study Search 的進階篩選正確渲染

**實現參考**:
```
frontend/src/components/ListWorkbench/ListWorkbench.tsx (119-161 行)
frontend/src/pages/StudySearch/index.tsx (427-433 行)
```

---

### ULW-T-030: ResultsCard 與 StatusBar 實現

**狀態**: ✅ Completed

**內容**:
- ResultsCard 實現 statusBar 與 actions 並排佈局
- StatusBar 支援 4 種狀態類型，自動顏色映射
- 三個頁面皆應用 ResultsCard

**驗收標準**:
- [ ] ResultsCard summary 顯示「共 N 筆 xxx ・ M 個篩選條件」
- [ ] statusBar 與 actions 在 body 頂部並排排列
- [ ] 行動版時 statusBar 與 actions 改為垂直堆疊
- [ ] StatusBar 正確應用顏色（藍/綠/黃/紅）
- [ ] StatusBar items 按正確順序排列（loading → error → empty → selection）
- [ ] 無結果時同時透過 StatusBar 與 Empty component 回饋
- [ ] 三頁面 ResultsCard summary 格式一致

**實現參考**:
```
frontend/src/components/ListWorkbench/ListWorkbench.tsx (163-232 行)
frontend/src/pages/Reports/index.tsx (761-781 行)
frontend/src/pages/StudySearch/index.tsx (434-479 行)
frontend/src/pages/Projects/index.tsx (317-360 行)
```

---

### ULW-T-040: SelectionDrawer 與 SelectionDrawerTrigger 實現

**狀態**: ✅ Completed

**內容**:
- SelectionDrawer 實現泛型 `<T>`，支援不同資料型別
- SelectionDrawerTrigger 顯示選取數量 badge
- 三頁面集成 SelectionDrawer，呈現批次操作

**驗收標準**:
- [ ] SelectionDrawer 支援泛型參數 `<T>`
- [ ] SelectionDrawerTrigger icon 為 `FolderOpenOutlined`
- [ ] 選取數量 >0 時 badge 為紅色，=0 時為灰色
- [ ] Drawer header 顯示「已選清單 + N 筆」
- [ ] primaryActions / secondaryActions / actionGroup 正確排列
- [ ] 項目列表支援自訂 renderItem
- [ ] 空狀態時顯示預設或自訂 emptyState
- [ ] 三頁面都有對應的 SelectionDrawer（Reports/Study Search 有批次操作，Projects 佔位符）

**實現參考**:
```
frontend/src/components/ListWorkbench/SelectionDrawer.tsx (1-122 行)
frontend/src/pages/StudySearch/index.tsx (583-629 行)
frontend/src/pages/ReportSearch/index.tsx (844-887 行)
```

---

### ULW-T-050: ColumnSettingsDrawer 實現

**狀態**: ✅ Completed

**內容**:
- ColumnSettingsDrawer 支援拖曳排序與顯示/隱藏切換
- 提供「重置」按鈕恢復預設欄位
- 三頁面集成 ColumnSettingsDrawer

**驗收標準**:
- [ ] ColumnSettingsDrawer 支援 collapsible checkbox (顯示/隱藏)
- [ ] 欄位可通過拖放改變順序，無拖曳時無視覺變化
- [ ] 特定欄位 (如 'action') 可鎖定，不可拖曳與隱藏
- [ ] 「重置」按鈕恢復預設配置
- [ ] 拖曳後立即更新列表欄位順序
- [ ] 三頁面都有對應的 ColumnSettingsDrawer 與欄位配置
- [ ] 欄位配置持久化至 localStorage

**實現參考**:
```
frontend/src/components/ListWorkbench/ColumnSettingsDrawer.tsx
frontend/src/pages/StudySearch/index.tsx (525-542 行)
frontend/src/pages/ReportSearch/index.tsx (889-899 行)
frontend/src/pages/Projects/index.tsx (379-396 行)
```

---

### ULW-T-060: CSS 變數與樣式系統實現

**狀態**: ✅ Completed

**內容**:
- 定義完整的 CSS 變數體系，支援淺色 / 深色模式
- 實現所有必要的 CSS 類別
- 響應式設計支援三個斷點 (desktop / tablet / mobile)

**驗收標準**:
- [ ] `list-workbench.css` 定義了 `--lw-surface` 等 7 個核心變數
- [ ] 深色模式支援 (`@media (prefers-color-scheme: dark)`)
- [ ] 所有 `.list-workbench-*` 類別已實現
- [ ] Header padding 固定 12px 20px
- [ ] 卡片間距固定 16px
- [ ] 行動版 (<768px) 自動調整 title 字級、工具列排列
- [ ] 所有狀態 badge 顏色正確 (藍/綠/黃/紅)

**實現參考**:
```
frontend/src/components/ListWorkbench/list-workbench.css
```

---

### ULW-T-070/080/090: 三頁面遷移至 ListWorkbench

**狀態**: ✅ Completed

**內容**:
- Reports 頁面 (`/reports`) 遷移完成
- Study Search 頁面 (`/study-search`) 遷移完成
- Projects 頁面 (`/projects`) 遷移完成
- 所有頁面都使用統一的 ListWorkbench 架構

**驗收標準**:

#### Reports (`/reports`)
- [ ] Header: title="報告檢索", description="查詢、預覽並管理放射報告"
- [ ] Meta: 顯示報告總數
- [ ] FilterCard: 清除篩選按鈕可用，重置至初始篩選
- [ ] ResultsCard: title="報告列表", summary 顯示筆數 + 篩選計數
- [ ] StatusBar: 支援 loading / error / empty / filters / selection 5 種狀態
- [ ] Actions: 欄位設定 + 全選/取消 + 已選清單 (其他批次動作在 Drawer 內)
- [ ] SelectionDrawer: 包含 reportBatchActionsRegistry 動作 (export/print/archive/delete)
- [ ] ColumnSettingsDrawer: 支援欄位拖曳排序

#### Study Search (`/study-search`)
- [ ] Header: title="檢查搜尋", description="搜尋、選取與導出放射檢查"
- [ ] Header secondaryActions: Export 按鈕
- [ ] Meta: 顯示檢查總數
- [ ] FilterCard: collapsible=true, 支援進階篩選
- [ ] ResultsCard: title="檢查列表", statusBar 與 actions 並排
- [ ] StatusBar: 支援 6 種狀態
- [ ] Actions: 欄位設定 + 全選/取消 + 加入專案 + 已選清單
- [ ] SelectionDrawer: 加入專案 / 匯出 / 清除全部
- [ ] ColumnSettingsDrawer: 支援欄位自訂

#### Projects (`/projects`)
- [ ] Header: title="Projects", primaryAction="New Project", secondaryActions="Export"
- [ ] Meta: 顯示專案總數
- [ ] FilterCard: 名稱、狀態、成員、日期範圍篩選
- [ ] ResultsCard: title="專案列表", summary 顯示筆數 + 篩選計數
- [ ] StatusBar: 支援 4 種狀態 (loading / error / empty / filters)
- [ ] Actions: 欄位設定 + 全選/取消 (disabled) + Refresh + View Mode 切換
- [ ] SelectionDrawer: 佔位符 (disabled buttons 搭配 "功能即將推出" tooltip)
- [ ] Grid/List 檢視切換

**實現參考**:
```
frontend/src/pages/Reports/index.tsx (ReportSearch)
frontend/src/pages/StudySearch/index.tsx
frontend/src/pages/Projects/index.tsx
```

---

### ULW-T-100: 組件單元測試編寫

**狀態**: ✅ Completed

**內容**:
- 編寫 SelectionDrawer, ColumnSettingsDrawer, StatusBar 的單元測試
- 達到 80% 代碼覆蓋率
- 測試檔案位於 `frontend/src/components/ListWorkbench/__tests__/`

**驗收標準**:
- [ ] 每個主要組件都有對應的 .test.tsx 檔案
- [ ] Props 傳遞測試：驗證各 prop 類型與預設值
- [ ] 事件回調測試：驗證 onClick, onChange 等事件觸發
- [ ] 條件渲染測試：驗證 collapsible, empty state, disabled 等條件
- [ ] 樣式類別測試：驗證正確的 CSS 類別應用
- [ ] 最低覆蓋率 80% (statements/branches/functions/lines)
- [ ] 所有測試通過 (`pnpm test`)
- [ ] 無 TypeScript 錯誤

**測試檔案清單**:
```
frontend/src/components/ListWorkbench/__tests__/
├── SelectionDrawer.test.tsx
├── SelectionDrawerTrigger.test.tsx
├── ColumnSettingsDrawer.test.tsx
└── StatusBar.test.tsx
```

---

### ULW-T-110: Playwright E2E 測試編寫

**狀態**: ✅ Completed

**內容**:
- 編寫 E2E 測試驗證三個頁面的 ListWorkbench 完整流程
- 測試涵蓋 Header / FilterCard / ResultsCard / StatusBar / Actions / Pagination / Drawer

**驗收標準**:
- [ ] Reports 頁面 E2E 測試 (reports-workbench.spec.ts)
  - Header 元素渲染
  - 搜尋與篩選功能
  - 清除篩選
  - 多選與 SelectionDrawer
  - ColumnSettingsDrawer
  - 分頁切換

- [ ] Study Search 頁面 E2E 測試 (study-search-workbench.spec.ts)
  - Header 與 Export 按鈕
  - FilterCard 進階篩選展開/隱藏
  - StatusBar 狀態變化
  - 加入專案操作
  - 響應式測試 (mobile/tablet/desktop)

- [ ] Projects 頁面 E2E 測試 (projects-workbench.spec.ts)
  - Header New Project 按鈕
  - FilterCard 篩選
  - View Mode 切換 (grid/list)
  - 分頁與排序

- [ ] 所有測試通過 (`pnpm test:e2e`)
- [ ] 無超時或失敗的測試

**測試檔案清單**:
```
frontend/e2e/
├── reports-workbench.spec.ts
├── study-search-workbench.spec.ts
└── projects-workbench.spec.ts
```

---

### ULW-T-120: 深色模式支援與驗證

**狀態**: ✅ Completed

**內容**:
- 驗證所有組件在深色模式下的視覺正確性
- 確認 CSS 變數自動切換
- 測試深色 / 淺色模式的過渡

**驗收標準**:
- [ ] 所有 ListWorkbench 組件在深色模式下視覺正確
- [ ] CSS 變數自動根據 `prefers-color-scheme` 切換
- [ ] 文字對比度在深色模式下仍符合 WCAG AA
- [ ] Badge 顏色在深色模式下清楚可見
- [ ] 邊框在深色模式下不過淺
- [ ] 手動測試所有頁面的深色模式 (Chrome DevTools 模擬)
- [ ] 無硬編碼顏色值，全使用 CSS 變數

---

### ULW-T-130: 響應式設計驗證

**狀態**: ✅ Completed

**內容**:
- 驗證所有頁面在三個斷點 (desktop/tablet/mobile) 的正常顯示
- 確認行動版佈局自動調整

**驗收標準**:

**Desktop (≥1280px)**
- [ ] Header title 24px, 正常顯示
- [ ] FilterCard 與 ResultsCard 並排不換行
- [ ] Actions 工具列單行排列
- [ ] Drawer 寬度 600px
- [ ] 列表欄位全部可見 (可橫向滾動)

**Tablet (768px ~ 1279px)**
- [ ] Header title 22px
- [ ] FilterCard 與 ResultsCard 正常堆疊
- [ ] Actions 可能換行 (視內容數量)
- [ ] Drawer 寬度 500px

**Mobile (<768px)**
- [ ] Header title 20px
- [ ] FilterCard 單欄垂直排列
- [ ] ResultsCard actions 垂直堆疊
- [ ] StatusBar 與 actions 垂直排列
- [ ] Drawer 寬度 90% (接近全寬)
- [ ] 表格支援橫向滾動
- [ ] 觸碰友善 (按鈕大小 ≥44px)

**測試方法**:
- [ ] Chrome DevTools 設備模擬
- [ ] 實際行動設備測試 (iPhone/Android)
- [ ] Percy 視覺快照測試 (各斷點)

---

### ULW-T-140: 文件完成

**狀態**: ✅ Completed

**內容**:
- 所有規格文件已完成 (spec.md / prd.md / sr.md / sd.md / tasks.md)
- frontend/docs/features/list-workbench-guide.md 已更新
- README 與 API 文件同步

**驗收標準**:
- [ ] spec.md: Purpose 完整，Requirements 明確，無遺漏
- [ ] prd.md: 產品願景、需求、使用者故事、驗收標準完整
- [ ] sr.md: 所有 ULW-SR-xxx 需求清晰且可驗證
- [ ] sd.md: 架構、設計、資料流程、測試策略詳盡
- [ ] tasks.md: 所有工作項目有驗收標準
- [ ] list-workbench-guide.md: 使用範例清楚，包含三頁面案例
- [ ] frontend/README.md: List Workbench 部分已更新
- [ ] 所有文件無語法或邏輯錯誤
- [ ] 文件能透過 OpenSpec validator 檢查

---

### ULW-T-150: 效能優化與指標驗證

**狀態**: ✅ Completed

**內容**:
- 驗證頁面載入時間、互動反應、列表渲染效能
- 確認無記憶體洩漏

**驗收標準**:

**Core Web Vitals**:
- [ ] First Contentful Paint (FCP) <2s
- [ ] Largest Contentful Paint (LCP) <2.5s
- [ ] Cumulative Layout Shift (CLS) <0.1
- [ ] Time to Interactive (TTI) <3s

**列表效能**:
- [ ] 初始列表載入 (≤500 筆) <1s
- [ ] 分頁切換 <500ms
- [ ] 搜尋防抖 300ms 工作正常
- [ ] 排序切換 <300ms

**記憶體管理**:
- [ ] 頁面切換時清理 event listeners
- [ ] 取消未完成的 API 請求
- [ ] 無 React 記憶體洩漏 (DevTools Profiler 檢查)

**測試方法**:
- [ ] Lighthouse 審計 (Performance ≥90)
- [ ] Chrome DevTools Performance 標籤錄製
- [ ] React DevTools Profiler 檢查渲染時間

---

### ULW-T-160: 無障礙性 (a11y) 檢查

**狀態**: ✅ Completed

**內容**:
- 驗證鍵盤導航、螢幕閱讀器支援、色彩對比度
- WCAG 2.1 AA 標準檢查

**驗收標準**:

**鍵盤導航**:
- [ ] Tab / Shift+Tab 可在所有元素間聚焦
- [ ] Enter 可觸發按鈕與確認對話
- [ ] Escape 可關閉 Drawer
- [ ] 無鍵盤陷阱 (focus 永遠可逃脫)

**螢幕閱讀器**:
- [ ] 所有按鈕都有清晰的 aria-label
- [ ] SelectionDrawerTrigger 讀出「已選 N 筆」
- [ ] StatusBar 讀出「loading / error / empty / selection」
- [ ] Form inputs 有 `<label>` 或 aria-label

**色彩對比度**:
- [ ] 所有文字 vs 背景對比度 ≥4.5:1 (normal text)
- [ ] 所有 UI 元素 ≥3:1 (large text / graphics)
- [ ] Badge 顏色清楚可辨

**測試方法**:
- [ ] axe DevTools 瀏覽器擴展掃描
- [ ] WAVE (WebAIM) 檢查
- [ ] 實際螢幕閱讀器測試 (NVDA / JAWS)
- [ ] 手動鍵盤導航測試

---

### ULW-T-170: 程式碼審查與合併

**狀態**: ✅ Completed

**內容**:
- 所有代碼已通過審查
- PR 已合併至 master 分支

**驗收標準**:
- [ ] PR 標題格式正確 (`feat(list-workbench): ...`)
- [ ] PR 描述清楚列出變更內容
- [ ] 所有 CI 檢查通過 (lint / test / build)
- [ ] 至少 2 位 reviewer 核准
- [ ] 無 merge conflicts
- [ ] Commit 歷史清晰，無 merge commits
- [ ] PR 合併後代碼在 master 可正確編譯與執行

**Merge 檢查清單**:
- [ ] `pnpm lint` 無錯誤
- [ ] `pnpm test` 全部通過
- [ ] `pnpm test:e2e` 全部通過
- [ ] `pnpm build` 成功，無警告
- [ ] Lighthouse 審計通過

---

## 後續改進計畫 (未來版本)

### v1.1 增強功能 (P2)
- [ ] 快捷鍵支援 (Ctrl+K / Ctrl+N / 上下鍵)
- [ ] 進階 a11y 標籤與螢幕閱讀器最適化
- [ ] 自訂主題系統 (顏色 / 字體 customizable)

### v2.0 新特性 (未來規劃)
- [ ] 展開行支援 (expandable rows)
- [ ] 樹狀結構支援
- [ ] 拖曳列表項目 (drag-and-drop rows)
- [ ] 行內編輯 (inline editing)
- [ ] 高級篩選介面 (filter builder)

---

## 風險與緩解措施

| 風險 | 概率 | 影響 | 緩解策略 |
|------|------|------|---------|
| ListViewStore 功能不足 | 低 | 高 | 與後端團隊早期 PoC，充分測試 |
| CSS 變數深色模式不完整 | 低 | 中 | 建立完整測試檢查清單 |
| 行動版測試不足 | 中 | 中 | 使用實際設備與 DevTools 並行測試 |
| E2E 測試脆弱性 | 低 | 中 | 使用穩定的 selector，avoid flaky waits |
| 效能指標未達成 | 低 | 中 | 即時監控 Lighthouse，提早優化 |

---

## 簽核與發布

**審核與批准**:
- [ ] PM 審核並批准 PRD / SR
- [ ] Tech Lead 審核並批准 SD / Tasks
- [ ] Tech Writer 審核文件完整性

**發布準備**:
- [ ] 所有任務標記為 Completed
- [ ] 代碼合併至 master
- [ ] 版本號更新 (v1.0.0)
- [ ] Release notes 撰寫
- [ ] 團隊發布公告

---

## 參考資源

- [unified-list-workbench Spec](./spec.md)
- [Product Requirements Document (PRD)](./prd.md)
- [Software Requirements (SR)](./sr.md)
- [Software Design Document (SD)](./sd.md)
- [List Workbench Usage Guide](../../frontend/docs/features/list-workbench-guide.md)
- [Frontend PRD/SR/SD](../../docs/requirements/02_FRONTEND_PRD_SR_SD.md)

---

*本文件版本：v1.0.0 | 最後更新：2025-11-24*

