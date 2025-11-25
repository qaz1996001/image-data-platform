---
spec-id: unified-list-workbench-sd
spec-type: SD
version: 1.0.0
status: approved
created-at: 2025-11-24
updated-at: 2025-11-24
---

# unified-list-workbench — 軟體設計文件 (SD)

> 本文件提供 ListWorkbench 組件家族的架構設計、實作指引與資料流程圖。對應 IEC 62304 中的「軟體架構與詳細設計」層級。

---

## 1. 架構概述

### 1.1 整體結構

```
frontend/src/components/ListWorkbench/
├── index.ts                    # 統一匯出點
├── ListWorkbench.tsx           # 主組件、FilterCard、ResultsCard、StatusBar
├── SelectionDrawer.tsx         # SelectionDrawer、SelectionDrawerTrigger
├── ColumnSettingsDrawer.tsx    # ColumnSettingsDrawer
└── list-workbench.css          # 樣式與 CSS 變數
```

### 1.2 組件間關係圖

```
ListWorkbench (root)
├── ListWorkbench.Header
├── ListWorkbench.Body
│   ├── FilterCard
│   └── ResultsCard
│       ├── StatusBar
│       ├── [actions]
│       │   ├── ColumnSettingsDrawer (modal)
│       │   └── SelectionDrawer
│       │       ├── SelectionDrawerTrigger (button)
│       │       └── [batch actions]
│       └── [content: Table/Grid]
└── pagination
```

### 1.3 頁面使用模式

每個列表頁面（Reports、Study Search、Projects）遵循統一的結構：

```typescript
function PageContent() {
  return (
    <ListWorkbench>
      <ListWorkbench.Header
        title="..."
        description="..."
        primaryAction={...}
        secondaryActions={...}
        meta={<Badge count={total} />}
      />
      <ListWorkbench.Body>
        <FilterCard onClear={handleClear}>
          {/* 篩選表單 */}
        </FilterCard>
        <ResultsCard
          title="..."
          summary={`共 ${total} 筆`}
          statusBar={<StatusBar items={statusItems} />}
          actions={
            <Space>
              <Button icon={<SettingOutlined />} onClick={...}>欄位設定</Button>
              <SelectionDrawerTrigger count={selectedCount} />
              {/* 其他頁面專屬動作 */}
            </Space>
          }
          footer={<ListViewPagination />}
        >
          <Table dataSource={items} columns={columns} />
        </ResultsCard>
      </ListViewbench.Body>

      <ColumnSettingsDrawer open={...} />
      <SelectionDrawer open={...} items={selectedItems} />
    </ListWorkbench>
  )
}
```

---

## 2. 組件設計細節

### 2.1 ListWorkbench.Header 設計

**實作方式**:

```typescript
interface ListWorkbenchHeaderProps {
  title: string
  description?: ReactNode
  primaryAction?: ReactNode
  secondaryActions?: ReactNode
  meta?: ReactNode
  className?: string
}

const ListWorkbenchHeader = ({
  title,
  description,
  primaryAction,
  secondaryActions,
  meta,
  className,
}: ListWorkbenchHeaderProps) => {
  const primary = primaryAction ?? (
    <Button type="primary" size="middle" disabled className="list-workbench-primary-placeholder">
      Action
    </Button>
  )

  return (
    <div className={cx('list-workbench-header list-workbench-card', className)}>
      <div className="ant-card-head">
        <div className="ant-card-head-wrapper list-workbench-card-head">
          {/* 左側：Title + Description + Meta */}
          <div className="ant-card-head-title">
            <div className="list-workbench-head-main">
              <div className="list-workbench-head-title">{title}</div>
              {description && <div className="list-workbench-head-description">{description}</div>}
            </div>
            {meta && <div className="list-workbench-head-meta">{meta}</div>}
          </div>
          {/* 右側：Secondary + Primary Actions */}
          <div className="ant-card-extra">
            <Space className="list-workbench-head-actions" size={12} wrap>
              {secondaryActions && <div>{secondaryActions}</div>}
              <div className="list-workbench-primary-action">{primary}</div>
            </Space>
          </div>
        </div>
      </div>
    </div>
  )
}
```

**樣式應用**:
- 使用 Ant Design Card 的 head 結構
- 覆蓋 `ant-card-head-wrapper` 類別，套用 `list-workbench-card-head`
- 透過 CSS 變數控制 padding、背景、邊框

### 2.2 FilterCard 設計

**狀態管理**:
```typescript
const [expanded, setExpanded] = useState(defaultExpanded)
```

**展開/隱藏進階條件的邏輯**:
```typescript
{collapsible && advancedContent && (
  <div className="list-workbench-filter-advanced">
    <Divider dashed style={{ margin: '16px 0' }} />
    {expanded && (
      <div className="list-workbench-filter-advanced-content">
        {advancedContent}
      </div>
    )}
    <div className="list-workbench-filter-advanced-toggle">
      <Button 
        type="link" 
        onClick={() => setExpanded(value => !value)}
      >
        {expanded ? '隱藏進階條件' : '顯示進階條件'}
      </Button>
    </div>
  </div>
)}
```

**清除篩選行為**:
- 呼叫 `onClear()` callback（由頁面實現）
- 頁面層負責：
  1. 重置搜尋參數至 `INITIAL_QUERY`
  2. 呼叫 `ListViewProvider.fetchList()` 重新載入
  3. 顯示 `message.success('篩選已重設')`

### 2.3 ResultsCard 設計

**Layout 實作**:
```typescript
const ResultsCard = ({
  title,
  summary,
  statusBar,
  actions,
  footer,
  children,
  className,
  actionsVariant = 'default',
}: ResultsCardProps) => (
  <Card variant="outlined" title={title} extra={summary}>
    {/* StatusBar 與 Actions 並排 */}
    {(statusBar || actions) && (
      <div className="list-workbench-results-header">
        <div className="list-workbench-status-area">{statusBar}</div>
        {actions && (
          <div
            className={cx(
              'list-workbench-actions-area',
              actionsVariant === 'drawer' && 'list-workbench-actions-compact'
            )}
          >
            {actions}
          </div>
        )}
      </div>
    )}
    {/* 主內容 */}
    <div className="list-workbench-results-content">{children}</div>
    {/* 分頁 */}
    {footer && <div className="list-workbench-results-footer">{footer}</div>}
  </Card>
)
```

**CSS Flexbox 排版**:
```css
.list-workbench-results-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.list-workbench-actions-area {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  justify-content: flex-end;
}
```

### 2.4 StatusBar 設計

**顏色映射表**:
```typescript
const statusColorMap: Record<StatusBarItemType, string> = {
  info: 'info',      // 藍色
  success: 'success',// 綠色
  warning: 'warning',// 黃色
  error: 'error',    // 紅色
}

// Ant Design Badge 會自動根據 status 應用顏色
<Badge 
  status={statusColorMap[item.type]} 
  text={item.label}
  icon={item.icon}
/>
```

**排序邏輯**:
```typescript
// 頁面層負責按規定順序構建 statusItems
const statusItems: StatusBarItem[] = []
if (loading) statusItems.push({ type: 'info', label: '資料載入中' })
if (error) statusItems.push({ type: 'error', label: '載入失敗' })
if (!loading && !error && total === 0) {
  statusItems.push({
    type: hasQuery ? 'warning' : 'info',
    label: hasQuery ? '沒有結果' : '請輸入條件'
  })
}
if (hasActiveFilters) {
  statusItems.push({ type: 'success', label: `${filterCount} 個篩選中` })
}
if (selectedCount > 0) {
  statusItems.push({ type: 'success', label: `已選 ${selectedCount} 筆` })
}
```

### 2.5 SelectionDrawer 設計

**泛型實作**:
```typescript
export function SelectionDrawer<T>({
  open,
  items,
  renderItem,
  getItemKey,
  onClose,
  title = '已選清單',
  count,
  primaryActions,
  secondaryActions,
  actionGroup,
  emptyState,
  drawerProps,
}: SelectionDrawerProps<T>) {
  const itemCount = count ?? items.length
  
  return (
    <Drawer
      open={open}
      onClose={onClose}
      title={
        <div className="list-workbench-drawer-head">
          <Text strong>{title}</Text>
          <Badge count={itemCount} showZero overflowCount={999} />
        </div>
      }
      extra={<Space>{primaryActions}{secondaryActions}</Space>}
    >
      {/* 批次操作卡片 */}
      {actionGroup && <div className="list-workbench-drawer-group">{actionGroup}</div>}
      
      {/* 項目列表 */}
      {items.length > 0 ? (
        <div className="list-workbench-drawer-list">
          {items.map((item, index) => (
            <div key={getItemKey?.(item, index) ?? index} className="list-workbench-drawer-item">
              {renderItem(item, index)}
            </div>
          ))}
        </div>
      ) : (
        emptyState ?? <Empty description="未選擇任何項目" />
      )}
    </Drawer>
  )
}
```

**SelectionDrawerTrigger 實作**:
```typescript
export function SelectionDrawerTrigger({
  count,
  label,
  disabled,
  buttonProps,
  onClick,
}: SelectionDrawerTriggerProps) {
  const pillClass = count > 0
    ? 'list-workbench-selection-pill'
    : 'list-workbench-selection-pill list-workbench-selection-pill-zero'

  return (
    <Button
      className="list-workbench-selection-trigger"
      icon={<FolderOpenOutlined />}
      disabled={disabled}
      onClick={onClick}
      {...buttonProps}
    >
      <span>{label ?? '已選清單'}</span>
      <span className={pillClass}>{count}</span>
    </Button>
  )
}
```

### 2.6 ColumnSettingsDrawer 設計

**拖曳狀態管理**:
```typescript
// 在頁面層管理拖曳狀態
const [draggedItem, setDraggedItem] = useState<string | null>(null)

<ColumnSettingsDrawer
  draggedItem={draggedItem}
  onDragStart={(key: string) => setDraggedItem(key)}
  onDragOver={(e: React.DragEvent) => e.preventDefault()}
  onDrop={(targetKey: string) => {
    if (!draggedItem || draggedItem === targetKey) {
      setDraggedItem(null)
      return
    }
    reorderColumns(draggedItem, targetKey)
    setDraggedItem(null)
  }}
/>
```

**拖曳實現邏輯**:
```typescript
columnConfig.map((config) => (
  <div
    key={config.key}
    draggable
    onDragStart={() => onDragStart(config.key)}
    onDragOver={onDragOver}
    onDrop={() => onDrop(config.key)}
    className={draggedItem === config.key ? 'dragging' : ''}
  >
    <Checkbox
      checked={config.visible}
      onChange={(e) => onVisibilityChange(config.key, e.target.checked)}
      disabled={config.locked}
    />
    <span>{config.title}</span>
  </div>
))
```

---

## 3. 資料流程與狀態管理

### 3.1 頁面狀態流轉圖

```
┌─────────────────┐
│   初始化         │
│ 載入初始篩選     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  顯示列表       │
│ statusBar: hint │
└────────┬────────┘
         │
  ┌──────▼──────────────────────┐
  │  使用者操作                  │
  │  (搜尋 / 篩選 / 排序)       │
  └──────┬──────────────────────┘
         │
         ▼
┌─────────────────┐
│  API 呼叫       │◄──── 防抖 300ms
│ statusBar:      │
│ loading         │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌──────────┐
│ 成功   │ │ 失敗     │
└────┬───┘ └────┬─────┘
     │          │
     ▼          ▼
 ┌────────┐ ┌──────────┐
 │刷新列表│ │顯示 error│
 │更新    │ │statusBar │
 │badge   │ └──────────┘
 └────────┘
```

### 3.2 ListViewStore 與 FilterCard 整合

**頁面調用順序**:

```typescript
// 1. 搜尋表單提交
const handleSearch = (params: Record<string, unknown>) => {
  setQuery(params as Partial<StudyListQuery>, { fetch: true })
  // ListViewStore 自動觸發 fetchList()
}

// 2. 清除篩選
const handleClearFilters = () => {
  setQuery(STUDY_LIST_INITIAL_QUERY, { fetch: true, replace: true })
  clearSelection()
  message.success('篩選已重設')
}

// 3. 分頁變更
const handlePageChange = (page: number) => {
  setPageNumber(page)
  // ListViewStore 自動觸發 fetchList()
}
```

### 3.3 批次操作流程

```
使用者在列表中多選
        ↓
selection state 更新
        ↓
SelectionDrawerTrigger badge 更新
        ↓
使用者點擊已選清單按鈕
        ↓
SelectionDrawer 開啟
        ↓
選擇批次動作 (如「匯出」)
        ↓
呼叫後端 API
        ↓
操作完成後，清除選擇 / 刷新列表
```

---

## 4. CSS 架構

### 4.1 CSS 變數體系

**主色調變數** (在 `:root` 中定義):

```css
:root {
  /* 卡片與背景 */
  --lw-surface: #ffffff;
  --lw-border: #f0f0f0;
  --lw-border-subtle: #d9d9d9;
  
  /* 佈局 */
  --lw-header-padding: 12px 20px;
  --lw-card-gap: 16px;
  
  /* 狀態欄 */
  --lw-status-bg: #f5f5f5;
  --lw-status-border: #d9d9d9;
}

@media (prefers-color-scheme: dark) {
  :root {
    --lw-surface: #141414;
    --lw-border: #303030;
    --lw-border-subtle: #434343;
    --lw-status-bg: #1f1f1f;
    --lw-status-border: #3a3a3a;
  }
}
```

### 4.2 CSS 類別層次結構

```css
/* 根容器 */
.list-workbench { }

/* 卡片基礎樣式 */
.list-workbench-card { }
.list-workbench-card-head { }

/* Header */
.list-workbench-header { }
.list-workbench-head-main { }
.list-workbench-head-title { }
.list-workbench-head-description { }
.list-workbench-head-meta { }
.list-workbench-head-actions { }
.list-workbench-primary-placeholder { }

/* Filter Card */
.list-workbench-filter-card { }
.list-workbench-filter-basic { }
.list-workbench-filter-advanced { }
.list-workbench-filter-advanced-toggle { }

/* Results Card */
.list-workbench-results-card { }
.list-workbench-results-header { }
.list-workbench-status-area { }
.list-workbench-actions-area { }
.list-workbench-actions-compact { }
.list-workbench-results-content { }
.list-workbench-results-footer { }

/* Status Bar */
.list-workbench-status-bar { }
.list-workbench-status-bar-dense { }
.list-workbench-status-chip { }
.list-workbench-status-chip.status-info { }
.list-workbench-status-chip.status-success { }
.list-workbench-status-chip.status-warning { }
.list-workbench-status-chip.status-error { }

/* Drawer 相關 */
.list-workbench-drawer-head { }
.list-workbench-drawer-extra { }
.list-workbench-drawer-group { }
.list-workbench-drawer-list { }
.list-workbench-drawer-item { }

/* Selection Trigger */
.list-workbench-selection-trigger { }
.list-workbench-selection-pill { }
.list-workbench-selection-pill-zero { }
```

### 4.3 Responsive Design 實作

**Breakpoint 定義**:

```css
/* Desktop (≥1280px) - 預設 */
.list-workbench-head-title {
  font-size: 24px;
}

/* Tablet & Mobile (<768px) */
@media (max-width: 768px) {
  .list-workbench-head-title {
    font-size: 20px;
  }

  .list-workbench-results-header {
    flex-direction: column;
  }

  .list-workbench-actions-area {
    width: 100%;
    justify-content: flex-start;
  }

  .list-workbench-filter-basic {
    /* 單欄排列 */
  }
}
```

---

## 5. 與頁面層的整合設計

### 5.1 Reports 頁面集成方案

**頁面結構**:
```typescript
export default function ReportsPage() {
  const { items, loading, error, total, selectedKeys } = useListViewStore(...)
  
  return (
    <ListWorkbench>
      <ListWorkbench.Header
        title="報告檢索"
        description="查詢、預覽並管理放射報告"
        meta={<Badge count={total} />}
      />
      <ListWorkbench.Body>
        <FilterCard onClear={handleClearFilters}>
          <ReportSearchForm onSearch={handleSearch} />
        </FilterCard>
        <ResultsCard
          title="報告列表"
          summary={`共 ${total} 筆報告 ・ ${filterCount} 個篩選條件`}
          statusBar={<StatusBar items={statusItems} />}
          actions={/* actions toolbar */}
          footer={<ListViewPagination />}
        >
          <Table dataSource={items} columns={columns} />
        </ResultsCard>
      </ListWorkbench.Body>

      <SelectionDrawer open={...} items={selectedReports} />
      <ColumnSettingsDrawer open={...} />
    </ListWorkbench>
  )
}
```

### 5.2 Study Search 頁面集成方案

**進階篩選支援**:
```typescript
<FilterCard 
  collapsible={true}
  defaultExpanded={false}
  onClear={handleClearFilters}
>
  {/* 基本篩選 */}
  <StudySearchForm />
</FilterCard>
<FilterCard advancedContent={<AdvancedFilters />} />
```

### 5.3 Projects 頁面集成方案

**View Mode 切換在 Actions 內**:
```typescript
const actionsToolbar = (
  <Space size={8}>
    <Button icon={<SettingOutlined />}>欄位設定</Button>
    <Button.Group>
      <Button>全選</Button>
      <Button>取消</Button>
    </Button.Group>
    <Button icon={<ReloadOutlined />}>重新整理</Button>
    <Radio.Group value={viewMode} onChange={(e) => setViewMode(e.target.value)}>
      <Radio.Button value="grid"><AppstoreOutlined /></Radio.Button>
      <Radio.Button value="list"><BarsOutlined /></Radio.Button>
    </Radio.Group>
  </Space>
)
```

---

## 6. 測試策略

### 6.1 單元測試結構

```
frontend/src/components/ListWorkbench/__tests__/
├── ListWorkbench.test.tsx
├── FilterCard.test.tsx
├── ResultsCard.test.tsx
├── StatusBar.test.tsx
├── SelectionDrawer.test.tsx
├── SelectionDrawerTrigger.test.tsx
└── ColumnSettingsDrawer.test.tsx
```

**測試覆蓋項目**:
- Props 傳遞與預設值
- 事件回調觸發
- 條件渲染邏輯
- 樣式類別應用

### 6.2 E2E 測試結構

```
frontend/e2e/
├── reports-workbench.spec.ts
├── study-search-workbench.spec.ts
└── projects-workbench.spec.ts
```

**測試流程**:
1. 訪問頁面，驗證 Header 載入
2. 填寫篩選條件，驗證列表更新
3. 點擊「清除篩選」，驗證重設
4. 多選項目，驗證 SelectionDrawer
5. 切換分頁，驗證資料更新
6. 響應式測試（mobile/tablet/desktop）

### 6.3 視覺回歸測試

使用 Percy 或 Chromatic 進行快照測試：
- 所有組件在各斷點的視覺
- 深色模式的色彩正確性
- 所有狀態（loading/error/empty/selection）的外觀

---

## 7. 效能優化

### 7.1 渲染優化

**避免不必要重新渲染**:
```typescript
// 使用 React.memo 包裝不常變化的組件
export const ColumnSettingsDrawer = React.memo((...) => {...})

// 在大列表中使用虛擬化
<ListViewTable virtualized={true} />
```

### 7.2 搜尋防抖

```typescript
// 300ms 防抖
const debouncedSearch = useMemo(
  () => debounce((params: SearchParams) => {
    setQuery(params, { fetch: true })
  }, 300),
  []
)
```

### 7.3 API 請求最適化

```typescript
// 取消未完成的前一個請求
useEffect(() => {
  const abortController = new AbortController()
  search(searchParams, { signal: abortController.signal })
  return () => abortController.abort()
}, [searchParams])
```

---

## 8. 深色模式支援

### 8.1 CSS 實現

所有顏色值都使用 CSS 變數，透過 `@media (prefers-color-scheme: dark)` 自動切換：

```css
.list-workbench-card {
  background: var(--lw-surface);
  border: 1px solid var(--lw-border);
}
```

### 8.2 無需 JavaScript 切換

深色模式由作業系統偏好設定驅動，無需前端手動切換邏輯。

---

## 9. 無障礙性設計

### 9.1 鍵盤焦點管理

```typescript
// Drawer 開啟時聚焦第一個可互動元素
const drawerRef = useRef<HTMLDivElement>(null)

useEffect(() => {
  if (open) {
    drawerRef.current?.querySelector('button')?.focus()
  }
}, [open])
```

### 9.2 Aria 標籤

```typescript
<SelectionDrawerTrigger
  aria-label={`已選 ${count} 筆項目`}
/>

<StatusBar
  items={statusItems}
  role="region"
  aria-label="列表狀態"
/>
```

### 9.3 焦點順序

確保 Tab 鍵導航順序合理：
1. Header actions
2. FilterCard 輸入框
3. ResultsCard actions
4. Table rows (if selectable)
5. Pagination

---

## 10. 版本管理與向後相容性

### 10.1 Props 版本化

若未來需要修改 Props，使用分版本支援：

```typescript
// 舊版支援
export function ListWorkbench(props: ListWorkbenchPropsV1 | ListWorkbenchPropsV2) {
  if (props.version === 'v2') {
    // 新邏輯
  } else {
    // 舊邏輯
  }
}
```

### 10.2 主要版本更新

- v1.x: 初始版本，支援三個頁面
- v2.x: 新增功能（如展開行、樹狀結構）

---

*本文件版本：v1.0.0 | 最後更新：2025-11-24*

