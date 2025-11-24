---
change-id: standardize-phase1-list-ux
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Summary

以「List Workbench」為核心，統一 Reports (`/reports`)、Study Search (`/study-search`) 與 Projects (`/projects`) 三個關鍵列表頁的 UI/UX。提案將定義共用的標頭、篩選卡片、結果卡片與操作模式（含批次選擇、匯出、檢視/預覽）——確保所有頁面共用一致的 `ant-card-head-wrapper` 樣式、表單佈局與行動按鈕節奏，減少使用者在不同頁面間切換時的認知落差。

## Motivation

- **視覺與佈局不一致**：Reports/Study Search 使用 `Card variant="outlined"` 包住表單與結果；Projects 則採 Hero 區塊 + 自訂 filters + 清單，導致 `ant-card-head-wrapper` 樣式缺乏共通規格。
- **操作流程不同步**：Study Search 具備批次選取、欄位管理與導出；Reports 只有查詢 + 預覽；Projects 則有 filters + view mode + CRUD。缺乏一致的動作區（Primary/Secondary actions、清除篩選、狀態小節）。
- **ListView 體驗碎片化**：雖同樣使用 `ListViewProvider`，但空狀態、loading、錯誤展示與分頁資訊位置皆不同，增加維護成本並影響學習曲線。

## Scope

### In scope
1. 建立 `ListWorkbench` 設計與行為規格（標頭、說明文字、Primary/Secondary actions、統一的 `ant-card-head-wrapper` class）。  
2. 定義 `FilterCard` 模板（`Card` + 表單 + 收合/進階區）與 `ResultsCard` 模板（表格/卡片/網格 slot、頂部狀態列、批次行為入口）。  
3. 統一列表操作：批次選擇/匯出/清除篩選/欄位控制，並界定哪些頁面啟用哪些選項。  
4. 指定空狀態、錯誤狀態、統計文字（如「共 X 筆」）與分頁區塊放置方式。  
5. 產出可驗證的 UI 指南與 E2E 測試要求，確保三頁都符合新模式。

### Out of scope
- 後端 API/資料模型變更（僅針對現有資料顯示層）。  
- 新增與列表無關的功能（如 Reports 內容編輯、Projects 權限重構）。  
- 取代 Ant Design 元件或重新設計整體主題（聚焦於列表工作區）。

## Current gaps (per page)

| 頁面 | 現狀 | 缺口 |
| --- | --- | --- |
| Reports (`/reports`) | 兩張 Card + Table；操作僅有清除篩選、檢視/預覽 | 無批次選取/匯出、Header 樣式與 Study Search 不一致 |
| Study Search (`/study-search`) | Card + Drawer + Selection drawer，功能齊全 | 標頭與 Projects 不同、批次操作/欄位管理無共通入口 |
| Projects (`/projects`) | Hero + filters + grid/list 切換，無 Card 包裝 | 缺乏與其他頁一致的篩選/結果卡片與 `ant-card-head-wrapper` 樣式 |

## Proposed changes

1. **List Workbench 樣板**：新增 `ListWorkbench`（Header / FilterCard / ResultsCard 組合），提供統一 spacing、background、`ant-card-head-wrapper` class 與 actions slot。  
2. **行為矩陣**：定義三頁面共用的核心動作（搜尋、清除、批次選取、匯出、檢視/預覽）與差異化附加動作（Projects CRUD、Study Search 欄位設定等），並規範顯示位置。  
3. **狀態展示**：規範 loading/empty/error/selection badges，確保在結果卡片頂部統一呈現，並將總筆數資訊放入 `Card` extra。  
4. **測試與指南**：在 docs/requirements/02_FRONTEND_PRD_SR_SD.md 與相關 feature docs 中新增 List Workbench 章節；E2E 測試需覆蓋三頁面在統一樣式下的主要操作。

## Success criteria

- 三個頁面皆以 `ListWorkbench` 架構呈現，`ant-card-head-wrapper` 使用統一 class 與 spacing。  
- Reports/Study Search/Projects 提供一致的搜尋/清除/分頁/空狀態體驗，並於 docs/requirements 中記錄。  
- `pnpm lint`, `pnpm test`, `pnpm build` 綠燈，且新增的 UI 規格文件（含截圖或樣式量測）。  
- Playwright 或等效 E2E 腳本覆蓋三頁面操作流程（搜尋→結果→主要動作）。  
- 獲得產品/UX 確認（以 UI review checklist 或截圖比對為證）。

## Risks / Open questions

- Projects 頁面支援 grid/list 切換，需確認新 ResultsCard 是否保留切換功能或僅在內容 slot 內自行處理。  
- Study Search 具備 Selection Drawer 與欄位管理，需確認在統一 Header 下如何展示（獨立按鈕還是 Action Group）。  
- 使用者是否期望 Reports 也加入批次選取/匯出？若僅 UI 統一而功能不同，需在 spec text 清楚標註。  
- 需要 UI 設計稿（Figma）或僅以文字/截圖規範？目前假設以 tokens + CSS 約束即可。

