---
spec-id: unified-list-workbench-sr
spec-type: SR
version: 1.0.0
status: approved
created-at: 2025-11-24
updated-at: 2025-11-24
---

# unified-list-workbench — 軟體需求規格 (SR)

> 本文件將 PRD 中的功能需求拆解為可實作與可驗證的軟體需求，編號為 ULW-SR-xxx。

---

## 1. 組件架構需求

### 1.1 ListWorkbench 複合組件結構

**ULW-SR-001**: `ListWorkbench` 必須以複合組件模式實現，包含 `.Header` 與 `.Body` 子組件。

**驗收**:
```typescript
// 應支援此使用模式
<ListWorkbench>
  <ListWorkbench.Header title="..." description="..." />
  <ListWorkbench.Body>
    {/* children */}
  </ListWorkbench.Body>
</ListWorkbench>
```

**ULW-SR-002**: 組件必須從 `@components/ListWorkbench/index.ts` 統一匯出，並包含以下型別定義：
- `StatusBarItem`、`StatusBarItemType`
- `SelectionDrawerProps<T>`、`SelectionDrawerTriggerProps`
- `ColumnSettingsDrawerProps`

---

## 2. Header 需求

### 2.1 視覺規範

**ULW-SR-010**: Header 必須渲染包含以下區域的 Ant Design Card：
- 左側：Title (24px, 600 weight) + Description (14px, regular)
- 右側：Secondary Actions + Primary Action (靠右對齐)
- Meta slot: Badge 或統計數字

**實現細節**:
- 使用 `list-workbench-card-head` class 套用統一樣式
- Padding 固定 `12px 20px` (來自 CSS 變數)
- 背景 `var(--lw-surface)`
- 無底線 (border-bottom: none)

### 2.2 Props 規範

**ULW-SR-011**: ListWorkbench.Header 必須支援以下 props：

| Prop | 型別 | 必填 | 預設值 | 說明 |
|------|------|------|--------|------|
| `title` | string | ✅ | - | 頁面標題 |
| `description` | ReactNode | ❌ | undefined | 頁面說明文字 |
| `primaryAction` | ReactNode | ❌ | disabled button | 主要行動按鈕 |
| `secondaryActions` | ReactNode | ❌ | undefined | 輔助行動區 |
| `meta` | ReactNode | ❌ | undefined | Meta 資訊（通常是 Badge） |
| `className` | string | ❌ | undefined | 自訂 CSS 類別 |

### 2.3 Primary Action 預留空間

**ULW-SR-012**: 若未提供 `primaryAction`，Header 必須渲染一個 disabled placeholder 按鈕，以維持結構一致。

**實現**:
```typescript
const primary = primaryAction ?? (
  <Button 
    type="primary" 
    size="middle" 
    disabled 
    className="list-workbench-primary-placeholder"
  >
    Action
  </Button>
)
```

---

## 3. FilterCard 需求

### 3.1 基本結構

**ULW-SR-020**: FilterCard 必須基於 Ant Design Card (`variant="outlined"`) 實現，具備以下元素：
- Card title: 預設「條件設定」
- Card extra: 「清除篩選」按鈕（或 ClearButton）
- Card body: 基本篩選條件區域
- Card footer (可選): 進階篩選切換按鈕

### 3.2 Props 規範

**ULW-SR-021**: FilterCard 必須支援以下 props：

| Prop | 型別 | 必填 | 說明 |
|------|------|------|------|
| `title` | ReactNode | ❌ | 卡片標題，預設「條件設定」 |
| `extra` | ReactNode | ❌ | extra 區內容，預設「清除篩選」按鈕 |
| `onClear` | () => void | ❌ | 清除按鈕點擊回調 |
| `children` | ReactNode | ✅ | 基本篩選內容 |
| `collapsible` | boolean | ❌ | 是否支援展開/隱藏進階篩選，預設 false |
| `defaultExpanded` | boolean | ❌ | 進階篩選初始展開狀態，預設 true |
| `advancedContent` | ReactNode | ❌ | 進階篩選內容 |
| `className` | string | ❌ | 自訂 CSS 類別 |

### 3.3 清除篩選行為

**ULW-SR-022**: 點擊「清除篩選」按鈕時，FilterCard 必須：
1. 呼叫 `onClear()` callback
2. 頁面的搜尋條件應重置至 `INITIAL_QUERY`
3. 觸發 ListViewProvider 的 `fetchList()` 重新載入資料
4. 顯示 `message.success('篩選已重設')`

### 3.4 進階篩選展開/隱藏

**ULW-SR-023**: 當 `collapsible=true` 且提供 `advancedContent` 時，FilterCard 必須：
- 在 body 與 advanced content 之間顯示虛線分隔 (Divider dashed)
- 於 footer 顯示「顯示進階條件」/ 「隱藏進階條件」切換按鈕
- 點擊按鈕時控制 `advancedContent` 的顯示/隱藏

### 3.5 行動版適配

**ULW-SR-024**: 在寬度 <768px 時，FilterCard 應自動：
- 將輸入元件改為單欄垂直排列
- 將 gutter 保持為 12px
- 支援「顯示篩選」/ 「隱藏篩選」的抽屜式收合

---

## 4. ResultsCard 需求

### 4.1 基本結構

**ULW-SR-030**: ResultsCard 必須基於 Ant Design Card (`variant="outlined"`) 實現，包含以下區域：

1. **Header**
   - Title: 「xxx 列表」
   - Extra: Summary（「共 N 筆 xxx ・ M 個篩選條件」）

2. **StatusBar 區** (可選)
   - 位於 body 頂部，顯示 loading/error/empty/selection 狀態

3. **Actions 工具列** (可選)
   - 與 StatusBar 並排於 body 頂部
   - 左端：齒輪按鈕、全選/取消、已選清單
   - 可選：頁面專屬按鈕（Refresh、View Mode、Export 等）

4. **Content Area**
   - 主要內容區，通常為 Table / Grid

5. **Footer**
   - `ListViewPagination`

### 4.2 Props 規範

**ULW-SR-031**: ResultsCard 必須支援以下 props：

| Prop | 型別 | 必填 | 說明 |
|------|------|------|------|
| `title` | ReactNode | ✅ | 卡片標題 |
| `summary` | ReactNode | ❌ | Extra 區內容（統計資訊） |
| `statusBar` | ReactNode | ❌ | StatusBar 組件 |
| `actions` | ReactNode | ❌ | Actions 工具列 |
| `footer` | ReactNode | ❌ | Footer 內容（通常為分頁） |
| `children` | ReactNode | ✅ | 主要內容區 |
| `className` | string | ❌ | 自訂 CSS 類別 |
| `actionsVariant` | 'default' \| 'drawer' | ❌ | Actions 顯示模式，預設 'default' |

### 4.3 Layout 規範

**ULW-SR-032**: ResultsCard 的 body layout 必須遵守以下規則：

```
┌─────────────────────────────────────┐
│ StatusBar          │    Actions      │  <- 並排，statusBar 左、actions 右
├─────────────────────────────────────┤
│                                     │
│           Content Area              │
│                                     │
├─────────────────────────────────────┤
│ Footer (Pagination)                 │
└─────────────────────────────────────┘
```

- StatusBar 與 Actions 之間間距 12px
- 行動版 (<768px) 時改為垂直堆疊
- Actions 列單行排列，最小間距 8px；超過 2 個按鈕時應考慮換行或 Dropdown 收斂

### 4.4 Actions 工具列規範

**ULW-SR-033**: Actions 工具列左起必須包含以下元素（按順序）：

1. **欄位設定按鈕** - SettingOutlined icon，點擊開啟 ColumnSettingsDrawer
2. **全選/取消群組** - Space.Compact 包裝兩顆按鈕
3. **已選清單觸發按鈕** - SelectionDrawerTrigger（含數量 badge）
4. **頁面專屬動作** (可選) - 如 Export、Refresh、View Mode 切換

**限制**：
- MUST NOT 直接顯示批次操作按鈕（匯出、列印、刪除等）於此區
- 批次操作 MUST 移至 SelectionDrawer

### 4.5 Summary 格式規範

**ULW-SR-034**: ResultsCard 的 `summary` 必須遵循以下格式：

```
共 N 筆 <資料類型>
共 N 筆 <資料類型> ・ M 個篩選條件   (當 M > 0 時)
```

例如：
- 「共 1,234 筆報告」
- 「共 567 筆檢查 ・ 3 個篩選條件」

### 4.6 actionsVariant 屬性

**ULW-SR-035**: 當 `actionsVariant="drawer"` 時，ResultsCard 應以更緊湊的樣式渲染 actions：
- 按鈕間距從 8px 縮小至 6px
- 按鈕 padding 從標準值縮小至 `10px inline`

---

## 5. StatusBar 需求

### 5.1 基本結構

**ULW-SR-040**: StatusBar 必須以 pill-style badge 陣列呈現，使用標準的 `StatusBarItem[]` 型別定義。

**型別定義**:
```typescript
type StatusBarItemType = 'info' | 'success' | 'warning' | 'error'

interface StatusBarItem {
  key?: React.Key
  type?: StatusBarItemType
  label: ReactNode
  icon?: ReactNode
}
```

### 5.2 顏色編碼

**ULW-SR-041**: 每個狀態類型必須對應固定的顏色組合：

| Type | 背景色 | 邊框色 | 文字色 | 應用場景 |
|------|--------|--------|--------|---------|
| `info` | #e6f4ff | #91caff | #0958d9 | Loading / Hint |
| `success` | #f6ffed | #b7eb8f | #389e0d | Selection / Filter Active |
| `warning` | #fffbe6 | #ffe58f | #d48806 | Empty Result |
| `error` | #fff2f0 | #ffccc7 | #cf1322 | Error |

### 5.3 狀態優先級與順序

**ULW-SR-042**: 若同時存在多個狀態，StatusBar 必須按以下順序排列：

1. loading (info)
2. error
3. empty / hint (info / warning)
4. selection / filters (success)

**實例**：
- 若同時有 loading 與 error，優先顯示 loading
- 若有 empty 與 selection，error 被清除後顯示兩者

### 5.4 Props 規範

**ULW-SR-043**: StatusBar 必須支援以下 props：

| Prop | 型別 | 必填 | 說明 |
|------|------|------|------|
| `items` | StatusBarItem[] | ✅ | 狀態項目陣列 |
| `dense` | boolean | ❌ | 是否為緊湊模式，預設 false |
| `className` | string | ❌ | 自訂 CSS 類別 |

**Dense 模式**: padding 從 8px 12px 縮小至 4px 8px

### 5.5 空 StatusBar 行為

**ULW-SR-044**: 若 `items` 陣列為空或 undefined，StatusBar 必須不渲染任何內容（返回 null）。

---

## 6. SelectionDrawer 需求

### 6.1 泛型支援

**ULW-SR-050**: SelectionDrawer 必須是泛型組件，支援不同資料類型：

```typescript
<SelectionDrawer<StudyListItem>
  items={selectedStudies}
  renderItem={(study) => <Card>{study.exam_id}</Card>}
/>
```

### 6.2 Header 顯示規範

**ULW-SR-051**: SelectionDrawer 的 Drawer header 必須：
- 顯示「已選清單」標題
- 顯示選取數量 badge（例如「已選清單 5」）
- 使用 `list-workbench-drawer-head` class

### 6.3 Actions 排列

**ULW-SR-052**: Drawer header 的 `extra` 區必須按順序顯示：
1. `primaryActions` (通常為藍色主要按鈕)
2. `secondaryActions` (通常為紅色危險按鈕)

多個按鈕使用 `Space size="small"` 排列，允許換行。

### 6.4 Body 結構

**ULW-SR-053**: SelectionDrawer body 必須包含以下區域（順序固定）：

1. **ActionGroup** (可選)
   - 通常為「批次操作」卡片，包含多個按鈕
   - 使用 `list-workbench-drawer-group` class
   - 按鈕排列方式可為 `Space wrap` 或 `flex`

2. **Item List**
   - 使用 `list-workbench-drawer-list` class
   - 每個項目使用 `list-workbench-drawer-item` class
   - 通過 `renderItem` 自訂項目呈現方式

3. **Empty State** (可選)
   - 若無項目時，顯示 `emptyState` 或預設的 Empty 提示

### 6.5 SelectionDrawerTrigger 規範

**ULW-SR-054**: SelectionDrawerTrigger 必須：
- 使用 `FolderOpenOutlined` icon
- 顯示標籤「已選清單」（或自訂 `label`）
- 顯示 badge 表示選取數量：
  - 數量 > 0: 紅色背景 (#f5222d)
  - 數量 = 0: 灰色背景 (#d9d9d9)
- 當 disabled=true 或 count=0 時，按鈕應呈現 disabled 狀態

### 6.6 Props 規範

**ULW-SR-055**: SelectionDrawer 支援以下 props：

| Prop | 型別 | 必填 | 說明 |
|------|------|------|------|
| `open` | boolean | ✅ | 是否顯示 Drawer |
| `items` | T[] | ✅ | 已選項目陣列 |
| `renderItem` | (item: T, index: number) => ReactNode | ✅ | 項目渲染函式 |
| `getItemKey` | (item: T, index: number) => React.Key | ❌ | 項目 key 提取函式 |
| `onClose` | () => void | ✅ | Drawer 關閉回調 |
| `title` | string | ❌ | Drawer 標題，預設「已選清單」 |
| `count` | number | ❌ | 覆寫 badge 數量 |
| `primaryActions` | ReactNode | ❌ | 主要操作按鈕 |
| `secondaryActions` | ReactNode | ❌ | 輔助操作按鈕 |
| `actionGroup` | ReactNode | ❌ | 批次操作群組 |
| `emptyState` | ReactNode | ❌ | 空狀態提示 |
| `drawerProps` | DrawerProps | ❌ | Drawer 其他 props |

---

## 7. ColumnSettingsDrawer 需求

### 7.1 功能規範

**ULW-SR-060**: ColumnSettingsDrawer 必須支援：
- **顯示/隱藏切換** - 每個欄位旁有 checkbox
- **拖曳排序** - 欄位可通過拖放改變順序
- **重置按鈕** - 恢復預設欄位配置
- **鎖定欄位** - 某些欄位（如 'action'）不可隱藏與拖曳

### 7.2 Props 規範

**ULW-SR-061**: ColumnSettingsDrawer 支援以下 props：

| Prop | 型別 | 必填 | 說明 |
|------|------|------|------|
| `open` | boolean | ✅ | 是否顯示 Drawer |
| `columnConfig` | ColumnConfig[] | ✅ | 欄位配置陣列 |
| `onClose` | () => void | ✅ | 關閉回調 |
| `onVisibilityChange` | (key: string, visible: boolean) => void | ✅ | 欄位顯示/隱藏回調 |
| `onDragStart` | (key: string) => void | ✅ | 拖曳開始回調 |
| `onDragOver` | (e: DragEvent) => void | ✅ | 拖曳覆蓋回調 |
| `onDrop` | (targetKey: string) => void | ✅ | 拖曳放下回調 |
| `onReset` | () => void | ✅ | 重置回調 |
| `draggedItem` | string \| null | ✅ | 當前拖曳項目 |

### 7.3 拖曳行為

**ULW-SR-062**: ColumnSettingsDrawer 的拖曳功能必須：
- 支援 `draggable` 屬性與 drag event handlers
- 提供視覺反饋（拖曳項目高亮或改變背景）
- 支援拖放排序（不能超出範圍）
- 被 drop 後立即更新視覺位置

---

## 8. CSS 與樣式需求

### 8.1 CSS 變數定義

**ULW-SR-070**: 所有 ListWorkbench 相關的樣式必須透過 CSS 變數管理，在 `:root` 中定義：

```css
:root {
  --lw-surface: #ffffff;               /* 卡片背景 */
  --lw-border: #f0f0f0;                /* 邊框 */
  --lw-border-subtle: #d9d9d9;         /* 淡邊框 */
  --lw-header-padding: 12px 20px;      /* Header padding */
  --lw-card-gap: 16px;                 /* 卡片間距 */
  --lw-status-bg: #f5f5f5;             /* StatusBar 背景 */
  --lw-status-border: #d9d9d9;         /* StatusBar 邊框 */
}

@media (prefers-color-scheme: dark) {
  :root {
    --lw-surface: #141414;
    --lw-border: #303030;
    /* ... 其他深色模式變數 */
  }
}
```

### 8.2 CSS 類別規範

**ULW-SR-071**: 所有組件必須使用標準 CSS 類別，便於樣式管理與測試定位：

| 類別名 | 元素 | 說明 |
|--------|------|------|
| `.list-workbench` | 根容器 | 主容器，flex 垂直排列 |
| `.list-workbench-card` | Header/FilterCard/ResultsCard | 統一卡片樣式 |
| `.list-workbench-header` | Header 元件 | - |
| `.list-workbench-filter-card` | FilterCard | - |
| `.list-workbench-results-card` | ResultsCard | - |
| `.list-workbench-status-bar` | StatusBar | - |
| `.list-workbench-status-chip` | 狀態 badge | - |
| `.list-workbench-actions-area` | Actions 工具列 | - |
| `.list-workbench-drawer-*` | Drawer 相關 | 見 SelectionDrawer 規範 |

### 8.3 響應式設計

**ULW-SR-072**: 所有組件必須支援三種斷點的響應式適配：

**Desktop (≥1280px)**
- Header title: 24px
- 工具列單行排列
- Drawer 寬度: 600px

**Tablet (768px ~ 1279px)**
- Header title: 22px
- 工具列可能換行
- Drawer 寬度: 500px

**Mobile (<768px)**
- Header title: 20px
- ResultsCard 工具列垂直堆疊
- FilterCard 單欄排列
- Drawer 寬度: 90%

### 8.4 深色模式支援

**ULW-SR-073**: 所有組件必須支援 `@media (prefers-color-scheme: dark)` 自動適配深色模式，無需使用者手動切換。

---

## 9. 三頁面適配需求

### 9.1 Reports 頁面

**ULW-SR-100**: `/reports` 頁面使用 ListWorkbench 時必須：
- Header title: 「報告檢索」，description: 「查詢、預覽並管理放射報告」
- Header primaryAction: disabled placeholder
- Meta: Badge 顯示報告總數
- FilterCard: 無 collapsible
- ResultsCard summary: 「共 N 筆報告」+ 篩選條件計數
- StatusBar: 支援 loading / error / empty / filters / selection 5 種狀態
- Actions: 欄位設定 + 全選/取消 + 已選清單
- SelectionDrawer: 包含 reportBatchActionsRegistry 的動作（匯出、列印、歸檔、刪除）

### 9.2 Study Search 頁面

**ULW-SR-110**: `/study-search` 頁面使用 ListWorkbench 時必須：
- Header title: 「檢查搜尋」，description: 「搜尋、選取與導出放射檢查」
- Header secondaryActions: Export 按鈕
- Meta: Badge 顯示檢查總數
- FilterCard: collapsible=true，支援進階篩選
- ResultsCard summary: 「共 N 筆檢查」+ 篩選條件計數
- StatusBar: 支援 loading / error / hint / empty / filters / selection 6 種狀態
- Actions: 欄位設定 + 全選/取消 + 加入專案 + 已選清單
- SelectionDrawer: 加入專案、匯出、清除全部

### 9.3 Projects 頁面

**ULW-SR-120**: `/projects` 頁面使用 ListWorkbench 時必須：
- Header title: 「Projects」，description: 「Manage and organize your imaging data projects」
- Header primaryAction: New Project 按鈕
- Header secondaryActions: Export 按鈕
- Meta: Badge 顯示專案總數
- FilterCard: 名稱、狀態、成員、日期範圍篩選
- ResultsCard summary: 「共 N 個專案」+ 篩選條件計數
- StatusBar: 支援 loading / error / empty / filters 4 種狀態
- Actions: 欄位設定 + 全選/取消 (disabled) + Refresh + View Mode 切換
- SelectionDrawer: 佔位符（"功能即將推出"）

---

## 10. 測試需求

### 10.1 單元測試

**ULW-SR-200**: 必須編寫單元測試覆蓋以下組件：
- SelectionDrawer: props 傳遞、renderItem、itemKey 提取
- ColumnSettingsDrawer: 拖曳邏輯、checkbox 狀態、reset 功能
- StatusBar: 狀態排列、顏色映射、icon 渲染

**最低覆蓋率**: 80%

### 10.2 E2E 測試

**ULW-SR-201**: 必須編寫 Playwright E2E 測試，驗證以下流程：
- Header 基本元素（title/description/meta/actions）渲染
- FilterCard 清除篩選功能
- ResultsCard 狀態指示正確更新
- SelectionDrawer 開啟/關閉與項目顯示
- ColumnSettingsDrawer 拖曳排序與顯示/隱藏

**測試檔案**: `frontend/e2e/*-workbench.spec.ts`

### 10.3 視覺回歸測試

**ULW-SR-202**: 建議使用 Percy 或 Chromatic 進行視覺回歸測試，確保：
- Desktop / Tablet / Mobile 各斷點視覺一致
- 深色模式視覺正確
- 所有狀態的 badge / icon / 顏色正確

---

## 11. 效能需求

### 11.1 渲染效能

**ULW-SR-300**: ListWorkbench 頁面必須滿足以下效能指標：
- First Contentful Paint (FCP) <2s
- Largest Contentful Paint (LCP) <2.5s
- Cumulative Layout Shift (CLS) <0.1

### 11.2 列表效能

**ULW-SR-301**: 當顯示 ≥500 筆記錄時：
- 初始渲染不應超過 1s
- 分頁切換不應超過 500ms
- 搜尋防抖應設定為 300ms

### 11.3 無記憶體洩漏

**ULW-SR-302**: 頁面切換時必須：
- 清理所有 event listeners
- 取消未完成的 API 請求
- 清理 store 訂閱

---

## 12. 無障礙性需求

### 12.1 鍵盤導航

**ULW-SR-400**: 所有組件必須支援：
- Tab: 聚焦下一個元素
- Shift+Tab: 聚焦上一個元素
- Enter: 觸發按鈕 / 確認
- Escape: 關閉 Drawer
- Space: 勾選 checkbox / 切換按鈕

### 12.2 螢幕閱讀器

**ULW-SR-401**: 必須為以下元素添加 `aria-label` 或 `aria-describedby`：
- SelectionDrawerTrigger: 「已選 N 筆」
- StatusBar badges: 「loading / error / empty / selection」
- ColumnSettingsDrawer: 「欄位設定」

### 12.3 色彩對比度

**ULW-SR-402**: 所有文字與背景的對比度必須符合 WCAG AA 標準（4.5:1 for normal text）。

---

## 13. 相容性需求

### 13.1 瀏覽器支援

**ULW-SR-500**: 必須支援以下瀏覽器版本：
- Chrome/Edge ≥90
- Firefox ≥88
- Safari ≥14

### 13.2 CSS 特性

**ULW-SR-501**: CSS 變數、Flexbox、Grid 等特性在目標瀏覽器中必須原生支援（IE11 不支援，若有需求需 polyfill）。

---

*本文件版本：v1.0.0 | 最後更新：2025-11-24*

