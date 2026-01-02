# Proposal: Fix Frontend TypeScript Errors

## Change ID
`fix-frontend-typescript-errors`

## Summary
修復 frontend 專案中 92 個 TypeScript 編譯錯誤，確保 `npx tsc --noEmit` 無錯誤通過。

## Motivation
當前 frontend 專案執行 `npx tsc --noEmit` 會產生 92 個編譯錯誤，這些錯誤會：
1. 阻礙 CI/CD 流程中的型別檢查
2. 降低程式碼品質與維護性
3. 隱藏潛在的 runtime 錯誤

## Scope

### Error Categories (按數量排序)

| 錯誤碼 | 數量 | 類型 | 修復策略 |
|--------|------|------|----------|
| TS6133 | 22 | 未使用的宣告 | 移除未使用的 imports/variables |
| TS2345 | 14 | 參數類型不相容 | 修正類型定義或使用型別斷言 |
| TS2339 | 14 | 屬性不存在 | 擴展類型定義或修正存取邏輯 |
| TS2322 | 13 | 類型不可賦值 | 修正類型或使用正確的型別轉換 |
| TS2304 | 7 | 找不到名稱 | 安裝缺少的 @types 套件 |
| TS2582 | 5 | 找不到測試 runner 類型 | 配置 tsconfig 或安裝 @types/jest |
| TS2353 | 4 | 物件字面量屬性錯誤 | 修正物件結構符合類型定義 |
| TS6137 | 3 | 不當的 .d.ts 導入 | 修正導入路徑 |
| TS2352 | 2 | 類型轉換錯誤 | 使用正確的型別斷言 |
| TS2308 | 2 | 重複導出 | 修正 re-export 衝突 |
| 其他 | 6 | 雜項 | 逐案修復 |

### Affected Areas (按優先級)

1. **Critical - Type Definitions** (影響多個檔案)
   - `src/types/index.ts` - 重複導出問題
   - `src/types/project.ts` - ProjectStatus 類型不完整
   - `src/types/user.ts` - User 類型缺少 role 屬性
   - `src/@types/projectResource.ts` - 不當的 .d.ts 導入

2. **High - Core Components**
   - `src/components/Search/QueryBuilder.tsx` - 複雜的類型錯誤
   - `src/store/listViewStore.ts` - 泛型類型問題
   - `src/hooks/projects/` - API 回應類型不匹配

3. **Medium - Feature Components**
   - `src/components/AIAssistant/` - 未使用的 imports
   - `src/components/StudySearch/` - 未使用的 imports
   - `src/pages/` - 各種類型錯誤

4. **Low - Test & Utility**
   - `src/pages/StudySearch/__tests__/` - 測試 runner 類型
   - `src/test/mocks/` - Mock 類型錯誤

## Design Principles (Following Linus-CLAUDE.md)

### 1. Good Taste - 消除特殊情況
- 優先修正類型定義，而非到處添加型別斷言
- 統一類型系統，消除類型轉換的需求

### 2. Never Break Userspace - 向後相容
- 所有修復必須保持現有功能正常運作
- 不改變 API 介面或資料結構

### 3. Pragmatism - 實用主義
- 優先解決影響最大的類型錯誤
- 對於外部庫的類型問題，使用型別斷言而非過度工程

### 4. Simplicity - 簡單性
- 保持修復簡潔明瞭
- 避免引入新的複雜性

## Success Criteria
- [ ] `npx tsc --noEmit` 無任何錯誤
- [ ] 所有現有功能保持正常運作
- [ ] 不引入新的 runtime 錯誤

## Related Specs
- `typescript-code-quality` - TypeScript 程式碼品質規範

## Risks & Mitigations
| 風險 | 機率 | 影響 | 緩解措施 |
|------|------|------|----------|
| 修復導致 runtime 錯誤 | 中 | 高 | 每批修復後執行 dev server 驗證 |
| 類型定義改變影響其他檔案 | 中 | 中 | 先處理基礎類型，再處理衍生類型 |
| 外部庫類型不相容 | 低 | 低 | 使用型別斷言處理 |
