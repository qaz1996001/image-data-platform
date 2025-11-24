---
change-id: standardize-phase1-list-ux
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

1. - [x] **列出三頁面現況與差異**  
     - 擷取 `/reports`, `/study-search`, `/projects` 目前的標頭、篩選、結果卡片與主要動作（含截圖或 DOM 樣式量測）。  
     - 產出一份比較表並附於 `frontend/docs/features/list-workbench-guide.md`（新增）。  
     - **驗證**：文件包含至少 3 個面向（佈局、動作、狀態處理），並由設計/PM 確認。

2. - [x] **建立 ListWorkbench 元件與樣式 tokens**  
     - 在 `@components/Common` 新增 `ListWorkbench`, `FilterCard`, `ResultsCard`, `StatusBar` 等組件，並提供對應 Less/SCSS。  
     - 調整全域樣式，讓 `ant-card-head-wrapper` 使用統一 class 與 spacing。  
     - **驗證**：Storybook/MDX 或對應文檔包含 props 範例；`pnpm lint` 通過。

3. - [x] **遷移 Reports 頁面**  
     - 以 `ListWorkbench` 包裝 Report 搜尋與結果，統一清除篩選/匯出/預覽動作位置。  
     - 加入空狀態與錯誤訊息的標準呈現。  
     - **驗證**：`pnpm test --filter=reports` (或等效) 綠燈，並附上截圖展示前後差異。

4. - [x] **遷移 Study Search 頁面**  
     - 將搜尋 Card、結果 Card、Selection Drawer 入口整合至 `ListWorkbench`。  
     - 確保批次操作（加入專案、匯出、欄位設定）均位於 `ResultsCard.actions` slot。  
     - **驗證**：更新對應的 Vitest/Playwright 腳本（至少覆蓋搜尋 + 批次操作）；測試結果附檔或錄影。

5. - [x] **依統一佈局遷移 Projects 頁面（List Layout v2 首個實作）**  
     - 依 `design.md §9` 將 Projects 既有 Hero + Filters + 列表映射到 `ListWorkbench.Header + FilterCard + ResultsCard`，並保留目前截圖中可見的主要使用空間（不得壓縮列表區域或關鍵資訊）。  
     - 在 Results 區塊導入與 Reports/Study 相同的工具列結構：左側為 `StatusBar`（loading/error/空結果/選取狀態），右側為齒輪「欄位設定」＋「全選/取消」雙鍵＋ Projects 特有動作（如 Export/New Project），但若有衝突需先與 PM/UX 確認後再實作。  
     - Align Clear filters 行為至 `FilterCard` extra，並將 `ListViewPagination` 移入 ResultsCard footer，作為 Reports/Study 後續統一的佈局範本。  
     - **驗證**：提供 Projects 頁面 before/after（桌機＋行動）截圖，由你確認佈局與使用空間後，再標記此任務完成。

6. - [ ] **更新規格與測試文檔**  
     - 在 `docs/requirements/02_FRONTEND_PRD_SR_SD.md` 與 `frontend/docs/features/*` 新增 List Workbench 章節與 UI 準則，明確描述三頁共用佈局（Header / FilterCard / ResultsCard / 工具列 / 分頁）。  
     - 新增或更新 Playwright/E2E 腳本：`reports-list-workbench.spec.ts`, `study-search-workbench.spec.ts`, `projects-workbench.spec.ts`，以 Projects 為基準檢查三頁行為與版面一致。  
     - **驗證**：`pnpm test`（含新腳本）+ `pnpm build` 綠燈；附錄截圖或 review checklist。

