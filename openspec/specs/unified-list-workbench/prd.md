---
spec-id: unified-list-workbench-prd
spec-type: PRD
version: 1.0.0
status: approved
created-at: 2025-11-24
updated-at: 2025-11-24
---

# unified-list-workbench — 產品需求文件 (PRD)

## 1. 產品概述

### 1.1 背景與動機

Image Data Platform 擁有三個主要的資料列表頁面：
- `/reports`：報告搜尋與檢視
- `/study-search`：檢查搜尋與篩選
- `/projects`：專案管理與組織

**現狀問題**：
- 各頁面的 Header、FilterCard、ResultsCard 佈局與樣式**各自獨立實作**，導致：
  - 視覺風格不一致（padding、背景顏色、邊框不同）
  - 使用者體驗不統一（搜尋、篩選、排序、分頁行為差異）
  - 開發效率低下（新頁面需重複實作相同 UI）
  - 維護成本高（樣式調整時需修改三個地方）

### 1.2 願景與目標

**願景**：建立可重用的 `ListWorkbench` 組件家族，統一所有「列表 + 篩選」型頁面的佈局、互動與樣式，同時支援行動版與深色模式。

**主要目標**：
1. **一致性** - 統一 Header/FilterCard/ResultsCard/StatusBar/SelectionDrawer 的外觀與行為
2. **效率** - 減少代碼重複，快速建立新列表頁
3. **可維護性** - 修改一處即可影響所有列表頁
4. **無障礙性** - 支援 WCAG 2.1 AA 標準、鍵盤導航、響應式設計

---

## 2. 功能需求

### 2.1 List Workbench 組件家族

#### 2.1.1 ListWorkbench.Header

**用途**：所有列表頁的頂部，統一展現頁面標題、描述、行動按鈕與統計資訊。

**必要元素**：
- **Title** (24px, font-weight: 600) - 例如「報告檢索」、「檢查搜尋」、「專案列表」
- **Description** (14px, regular, gray) - 簡明的頁面功能說明，例如「搜尋、選取與導出放射檢查」
- **Meta Badge** - 即時顯示主要統計，例如「共 1,234 筆」
- **Primary Action** (右對齐) - 最多 1 個按鈕，如「新增專案」、「匯出」；未定義時顯示 disabled placeholder
- **Secondary Actions** (Primary Action 左側) - 多個按鈕或下拉選單

**視覺規範**：
- Padding: 12px 20px（來自 CSS 變數 `--lw-header-padding`）
- Background: `var(--lw-surface)` (白色 / 深色模式下為深灰)
- Border: 1px solid `var(--lw-border-subtle)`
- 圓角: 8px (上邊)

#### 2.1.2 FilterCard

**用途**：集中所有搜尋與篩選條件，提供統一的清除操作。

**必要元素**：
- **Title** (固定為「條件設定」)
- **清除篩選按鈕** (位於 extra，右對齐)
- **基本篩選區域** (children) - 常用的篩選欄位
- **進階篩選區域** (advancedContent) - 可選，透過 collapse 切換
- **進階展開/隱藏切換按鈕** (Card footer)

**行為**：
- 點擊「清除篩選」後，重置所有篩選條件至預設值（INITIAL_QUERY），並觸發資料重新載入
- 顯示 `message.success('篩選已重設')`
- 行動版 (<768px) 自動變為單欄垂直排列，支援收合開關

#### 2.1.3 ResultsCard

**用途**：展示搜尋結果、分頁、狀態指示與操作工具列。

**必要區域**：

1. **Header**
   - Title: 「xxx 列表」（如「報告列表」、「檢查列表」）
   - Summary: 「共 N 筆」，有篩選時補上「・M 個篩選條件」

2. **StatusBar** (可選)
   - 顯示 loading / error / empty / selection 狀態
   - 使用 pill-style badges，顏色編碼（藍 / 綠 / 黃 / 紅）

3. **Actions 工具列**
   - 必要：齒輪「欄位設定」按鈕 → ColumnSettingsDrawer
   - 必要：「全選 / 取消」雙鈕 (Space.Compact)
   - 必要：「已選清單」觸發按鈕 + badge (SelectionDrawerTrigger)
   - 可選：頁面專屬動作（如 Export、Refresh、View Mode 切換）
   - 限制：**不得**在此區直接顯示批次操作按鈕（應放入 SelectionDrawer）

4. **Content Area**
   - 容納 Table、Grid 或 List 元件

5. **Footer**
   - `ListViewPagination` - 桌機版右對齊、行動版置中

#### 2.1.4 StatusBar

**用途**：以直觀的 badge 形式顯示頁面狀態。

**支援的狀態類型**：
- `info` (藍) - 正在載入 / 提示訊息
- `success` (綠) - 已選取 N 筆 / 篩選成功
- `warning` (黃) - 無結果
- `error` (紅) - 載入失敗

**排序規則**：loading → error → empty/hint → selection/filters

#### 2.1.5 SelectionDrawer & SelectionDrawerTrigger

**用途**：集中展示已選取項目與提供批次操作入口。

**SelectionDrawerTrigger**：
- Icon: `FolderOpenOutlined`
- Label: 「已選清單」
- Badge: 顯示選取數量（無選取時為 0，顯示灰色）
- 按鈕尺寸與 actions 工具列一致

**SelectionDrawer**：
- Header 顯示「已選清單 + N 筆」
- 三個 Action 區：primaryActions / secondaryActions / actionGroup
- Drawer body 列出所有已選項目，支援移除單筆
- 支援自訂 `renderItem` 以呈現不同資料型別

#### 2.1.6 ColumnSettingsDrawer

**用途**：統一的欄位設定介面，支援拖曳排序與顯示/隱藏切換。

**功能**：
- 每個欄位含 checkbox (顯示/隱藏) 與拖曳把手
- 「重置」按鈕恢復預設欄位配置
- 某些欄位（如 action）可鎖定不可拖曳

---

### 2.2 三頁面適配方案

#### 2.2.1 Reports (`/reports`)

| 元件 | 配置 | 說明 |
|------|------|------|
| **Header** | title="報告檢索" / description="查詢、預覽並管理放射報告" | - |
| **Header Actions** | primaryAction=disabled / secondaryActions=none | 暫無主動作 |
| **Meta** | `<Badge count={total} />` | 即時顯示報告總數 |
| **FilterCard** | 基本篩選 (關鍵字、日期、類型等) + 進階篩選 | 無進階篩選 (collapsible=false) |
| **ResultsCard** | statusBar + actions + Table + pagination | - |
| **StatusBar** | loading / error / empty / filters / selection | 6 種狀態 |
| **Actions** | 欄位設定 + 全選/取消 + 已選清單 | 批次操作移至 Drawer |
| **SelectionDrawer** | 已選報告列表 + 批次動作 (匯出、列印、歸檔、刪除) | 與 reportBatchActionsRegistry 整合 |

#### 2.2.2 Study Search (`/study-search`)

| 元件 | 配置 | 說明 |
|------|------|------|
| **Header** | title="檢查搜尋" / description="搜尋、選取與導出放射檢查" | - |
| **Header Actions** | primaryAction=disabled / secondaryActions=Export | Export 按鈕 |
| **Meta** | `<Badge count={total} />` | 即時顯示檢查總數 |
| **FilterCard** | 基本篩選 + 進階篩選 (collapsible=true) | Study Search 特有的進階欄位 |
| **ResultsCard** | statusBar + actions + Table + pagination | actionsVariant="drawer" |
| **StatusBar** | loading / error / hint / empty / filters / selection | 6 種狀態 |
| **Actions** | 欄位設定 + 全選/取消 + 加入專案 + 已選清單 | 批次操作在 Drawer |
| **SelectionDrawer** | 已選檢查列表 + 加入專案 / 匯出 / 清除全部 | batchActionsRegistry 整合 |

#### 2.2.3 Projects (`/projects`)

| 元件 | 配置 | 說明 |
|------|------|------|
| **Header** | title="Projects" / description="Manage and organize your imaging data projects" | - |
| **Header Actions** | primaryAction=New Project / secondaryActions=Export | 建立與匯出 |
| **Meta** | `<Badge count={total} />` | 即時顯示專案總數 |
| **FilterCard** | 名稱、狀態、成員、日期範圍 | 無進階篩選 |
| **ResultsCard** | statusBar + actions + Grid/List + pagination | - |
| **StatusBar** | loading / error / empty / filters | 4 種狀態 |
| **Actions** | 欄位設定 + 全選/取消 (disabled) + Refresh + View Mode 切換 | View mode 在 actions 內 |
| **SelectionDrawer** | 未來功能，目前佔位符 (disabled buttons) | "功能即將推出" |

---

## 3. 技術需求

### 3.1 技術棧

- **UI 框架**: React 18 + TypeScript
- **元件庫**: Ant Design 5
- **樣式**: CSS (custom properties) + LESS/SCSS (可選)
- **狀態管理**: Zustand (ListViewStore)
- **圖示**: @ant-design/icons

### 3.2 CSS 變數

所有 List Workbench 相關的樣式應透過 CSS 變數管理，以支援主題切換與深色模式：

```css
--lw-surface          /* 卡片背景 */
--lw-border           /* 邊框顏色 */
--lw-border-subtle    /* 淡邊框 */
--lw-header-padding   /* Header padding */
--lw-card-gap         /* 卡片間距 */
--lw-status-bg        /* StatusBar 背景 */
--lw-status-border    /* StatusBar 邊框 */
```

### 3.3 響應式設計

**Breakpoints**:
- Desktop: ≥1280px
- Tablet: 768px ~ 1279px
- Mobile: <768px

**應適配的變化**:
- Header title 字級調整 (24px → 20px at mobile)
- FilterCard 單欄垂直排列
- ResultsCard actions 自動換行
- Drawer 寬度調整 (600px → 90%)

### 3.4 無障礙性 (A11y)

- 鍵盤導航：Tab、Enter、Escape、方向鍵
- 螢幕閱讀器標籤 (aria-label)
- 色彩對比度 WCAG AA 標準
- 焦點狀態明確可見

---

## 4. 使用者故事

### 4.1 報告列表使用者

**故事**: 「作為一位研究員，我想在統一的介面中搜尋報告、選取多筆並批次匯出，以提高工作效率。」

**驗收條件**:
- 搜尋表單與列表在同一頁，Header 清晰展示
- 能快速套用篩選條件，並透過「清除篩選」一鍵重設
- 支援多選並在 Drawer 中看見已選報告
- 批次匯出、列印、歸檔、刪除都透過 Drawer 觸發
- 行動版仍可進行上述操作

### 4.2 檢查列表使用者

**故事**: 「作為一位研究員，我想搜尋檢查並加入專案，界面應該清晰且操作簡單。」

**驗收條件**:
- 基本與進階篩選區分清楚
- 已選檢查數量即時更新
- 支援「加入專案」的批次操作
- 欄位設定允許自訂列表欄位

### 4.3 專案列表使用者

**故事**: 「作為一位研究員，我想瀏覽所有專案、建立新專案、切換檢視模式（網格 vs 列表）。」

**驗收條件**:
- Header 清晰顯示「新增專案」按鈕
- 列表支援網格與列表檢視切換
- 分頁與篩選功能可用
- 行動版自動調整檢視

---

## 5. 驗收標準

### 5.1 功能驗收

- [ ] 三個頁面都已遷移至 ListWorkbench 架構
- [ ] Header / FilterCard / ResultsCard / StatusBar / SelectionDrawer 都可正常渲染
- [ ] 清除篩選行為正確，重置至 INITIAL_QUERY
- [ ] 欄位設定允許拖曳排序與顯示/隱藏
- [ ] 批次操作（匯出、加入專案等）集中在 Drawer

### 5.2 視覺驗收

- [ ] 所有 List Workbench 頁面視覺一致
- [ ] 行動版 (<768px) 自動調整佈局
- [ ] 深色模式支援正常
- [ ] 所有狀態指示（loading/error/empty/selection）都有清楚的視覺反饋

### 5.3 效能驗收

- [ ] Page Load Time <2s
- [ ] 搜尋防抖工作正常 (300ms)
- [ ] 列表渲染 ≥500 筆記錄時無明顯延遲
- [ ] 無 React 警告 / 錯誤

### 5.4 自動化測試

- [ ] Playwright E2E 測試覆蓋 Header / Filter / Results / Actions / Pagination
- [ ] 單元測試覆蓋 SelectionDrawer、ColumnSettingsDrawer 的主要邏輯
- [ ] 所有測試通過 (`pnpm test`)

### 5.5 文件驗收

- [ ] OpenSpec 規格完整且無遺漏
- [ ] 前端文件 (`frontend/docs/features/list-workbench-guide.md`) 已更新
- [ ] README 與 API 文件已同步

---

## 6. 約束與假設

### 6.1 約束

- 必須使用 Ant Design 5 原生組件（不得自行開發 Header/Card/Table）
- CSS 變數支援需 IE11 以上（實際根據專案需求決定）
- 三個頁面的 ListWorkbench 遷移必須在同一個 release 完成，避免版本不一致

### 6.2 假設

- 後端 API 接口穩定且支援分頁、排序、篩選
- ListViewStore 的設計已敲定，可支援三個頁面的需求
- 深色模式的 CSS 變數已系統地定義

---

## 7. 優先級

### P0 (必須包含)
- ListWorkbench.Header / Body / FilterCard / ResultsCard / StatusBar 基本實現
- 三頁面遷移 (Reports / Study Search / Projects)
- 清除篩選功能
- SelectionDrawer 集中批次操作

### P1 (應包含)
- ColumnSettingsDrawer 欄位設定
- 深色模式支援
- Playwright E2E 測試

### P2 (可包含)
- 快捷鍵支援
- 進階 a11y 標籤

---

## 8. 風險與緩解

| 風險 | 概率 | 影響 | 緩解策略 |
|------|------|------|---------|
| ListViewStore 無法支援三個頁面的差異需求 | 低 | 高 | 提前進行 PoC 驗證 |
| CSS 變數深色模式適配不完全 | 低 | 中 | 建立測試檢查清單 |
| 行動版測試不足 | 中 | 中 | 搭配 Playwright viewport 測試 |
| 批次操作的後端 API 尚未完善 | 低 | 高 | 與後端團隊共同確認契約 |

---

*本文件將在 PR 審核時由 PM / Tech Lead 核簽。最後更新時間：2025-11-24*

