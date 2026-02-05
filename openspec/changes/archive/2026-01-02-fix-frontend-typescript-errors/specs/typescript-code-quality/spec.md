# Spec: TypeScript Code Quality

## Capability ID
`typescript-code-quality`

## Summary
定義 Frontend 專案的 TypeScript 程式碼品質標準，確保型別安全與編譯通過。

---

## ADDED Requirements

### Requirement: Zero TypeScript Compilation Errors
**ID**: REQ-TSCQ-001
**Priority**: Critical

Frontend 專案 MUST 通過 TypeScript 編譯檢查，無任何錯誤。執行 `npx tsc --noEmit` 時 SHALL 輸出為空且退出碼為 0。

#### Scenario: Clean TypeScript Build
- **Given**: Frontend 專案程式碼
- **When**: 執行 `npx tsc --noEmit`
- **Then**: 輸出應為空（無錯誤）
- **And**: 退出碼應為 0

---

### Requirement: No Unused Declarations
**ID**: REQ-TSCQ-002
**Priority**: High

程式碼 MUST NOT 存在未使用的 imports、變數或函數宣告。未使用的宣告 SHALL 被移除或使用 `_` 前綴標記為刻意忽略。

#### Scenario: Unused Import Detection
- **Given**: 任意 TypeScript/TSX 檔案
- **When**: 檔案包含未使用的 import
- **Then**: 應移除該 import
- **And**: 不應產生 TS6133 錯誤

#### Scenario: Unused Variable Detection
- **Given**: 任意 TypeScript/TSX 檔案
- **When**: 檔案包含未使用的變數
- **Then**: 應移除該變數或使用 `_` 前綴標記為刻意忽略

---

### Requirement: Type Definition Consistency
**ID**: REQ-TSCQ-003
**Priority**: High

類型定義 MUST 在整個專案中保持一致，避免類型衝突。當多個模組導出相同名稱時 SHALL 使用明確的 re-export 語法解決衝突。

#### Scenario: Re-export Conflict Prevention
- **Given**: `src/types/index.ts` 作為類型導出中心
- **When**: 多個模組導出相同名稱的類型
- **Then**: 應使用明確的 re-export 語法解決衝突
- **And**: 不應產生 TS2308 錯誤

#### Scenario: Interface Extension Compatibility
- **Given**: 一個 interface 繼承另一個 interface
- **When**: 子 interface 的屬性類型與父 interface 不相容
- **Then**: 應修正類型定義確保相容
- **And**: 不應產生 TS2430 錯誤

---

### Requirement: Proper Type Imports
**ID**: REQ-TSCQ-004
**Priority**: Medium

類型導入 MUST 使用正確的路徑和語法。開發者 SHALL NOT 直接導入 `.d.ts` 檔案，而應導入對應的模組。

#### Scenario: No Direct d.ts Import
- **Given**: 需要導入類型定義
- **When**: 類型來自 `.d.ts` 檔案
- **Then**: 應導入對應的模組而非直接導入 `.d.ts` 檔案
- **And**: 不應產生 TS6137 錯誤

---

### Requirement: Test Type Configuration
**ID**: REQ-TSCQ-005
**Priority**: Medium

測試檔案 MUST 有正確的類型配置。測試 runner 的全域函數（如 `describe`, `it`, `expect`）SHALL 有可用的類型定義。

#### Scenario: Test Runner Types Available
- **Given**: 測試檔案使用 Jest 或 Vitest 語法
- **When**: 編譯測試檔案
- **Then**: `describe`, `it`, `expect` 等全域函數應有類型定義
- **And**: 不應產生 TS2582 或 TS2304 錯誤

---

## MODIFIED Requirements

(None)

---

## REMOVED Requirements

(None)

---

## Dependencies
- React 18
- TypeScript 5.x
- Vite
- Jest or Vitest for testing

## Related Capabilities
- `fe-code-quality` - 前端程式碼品質規範（如存在）
