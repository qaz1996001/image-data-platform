# Design: Fix Frontend TypeScript Errors

## Overview

此變更分為兩個主要階段：
1. **Phase 1-5**: 修復 TypeScript 編譯錯誤 (已完成)
2. **Phase 6**: 重構 `eslint-disable` 使用，符合 Martin Fowler 的程式碼品質標準

---

## Phase 6: eslint-disable Refactoring Design

### 設計原則 (Martin Fowler)

> "Code smell is a surface indication that usually corresponds to a deeper problem in the system."

`eslint-disable` 是一種 Code Smell，應透過重構消除而非掩蓋問題。

### 重構目標

| 檔案 | 問題 | Code Smell | 重構策略 |
|------|------|------------|----------|
| `i18next.d.ts` | `any` 類型過於寬鬆 | Primitive Obsession | `any` → `unknown` |
| `useReportTableColumns.tsx` | 混合導出 hooks + utils | Large Class / Feature Envy | Extract Module |
| `SelectionDrawer.example.tsx` | 未使用的解構變數 | Comments | 移除未用解構 |
| `PromptTemplateManager.tsx` | 隱藏的 useEffect 依賴 | Feature Envy | 用 `useCallback` |
| `ProjectReportListViewProvider.tsx` | `any` 類型不明確 | Primitive Obsession | 使用具體類型 |

### 詳細設計

#### 6.1 i18next.d.ts - `any` → `unknown`

**Before:**
```typescript
(key: string | string[], options?: Record<string, any>): string
```

**After:**
```typescript
(key: string | string[], options?: Record<string, unknown>): string
```

**理由**: `unknown` 比 `any` 更安全，強制使用者在使用前進行類型檢查。

---

#### 6.2 useReportTableColumns.tsx - Extract Module

**Before (1 file, 混合職責):**
```
useReportTableColumns.tsx
├── REPORT_COLUMN_KEYS (constant)
├── DEFAULT_COLUMN_ORDER (constant)
├── useReportColumnConfig (hook)
├── DEFAULT_REPORT_COLUMN_CONFIG (constant)
├── formatDate (util)
├── getReportTypeLabel (util)
├── useReportTypeLabel (hook)
├── getReportTypeColor (util)
└── useReportTableColumns (hook)
```

**After (2 files, 單一職責):**
```
src/utils/reportTableConfig.ts
├── REPORT_COLUMN_KEYS
├── DEFAULT_COLUMN_ORDER
├── DEFAULT_REPORT_COLUMN_CONFIG
├── formatDate
├── getReportTypeLabel
└── getReportTypeColor

src/hooks/useReportTableColumns.tsx
├── useReportColumnConfig
├── useReportTypeLabel
└── useReportTableColumns
```

**理由**: 符合單一職責原則，消除 react-refresh 警告。

---

#### 6.3 SelectionDrawer.example.tsx - 移除未用解構

**Before:**
```typescript
const {
  selectedRowKeys: _selectedRowKeys,  // 解構但未使用
  selectedItems,
  handleSelectionChange: _handleSelectionChange,  // 解構但未使用
  ...
} = useItemSelection(...)
```

**After:**
```typescript
const {
  selectedItems,
  selectedCount,
  deselectAll,
  removeItem,
} = useItemSelection(...)
```

**理由**: 範例程式碼應展示最佳實踐，不應解構不需要的變數。

---

#### 6.4 PromptTemplateManager.tsx - useCallback 重構

**Before:**
```typescript
const loadTemplates = async () => {
  // ... implementation
}

useEffect(() => {
  loadTemplates()
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [filters])
```

**After:**
```typescript
const loadTemplates = useCallback(async () => {
  // ... implementation
}, [filters])

useEffect(() => {
  loadTemplates()
}, [loadTemplates])
```

**理由**: 明確依賴關係，符合 React Hooks 規範。

---

#### 6.5 ProjectReportListViewProvider.tsx - 具體類型

**Before:**
```typescript
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const config = useMemo<ListViewConfig<any, any>>(() => ({...}), [...])
```

**After:**
```typescript
const config = useMemo<ListViewConfig<Report, ReportListQuery>>(() => ({...}), [...])
```

**理由**: 具體類型提供更好的類型檢查和 IDE 支援。

---

## 驗收標準

1. ✅ `pnpm lint` 通過，0 errors, 0 warnings
2. ✅ `npx tsc --noEmit` 通過，0 errors
3. ✅ 所有 `eslint-disable` 使用都有合理理由（僅保留 `ProjectFilters.tsx` 的 debounce 相關）
4. ✅ 程式碼符合 Martin Fowler 的 Simple Design 四規則
