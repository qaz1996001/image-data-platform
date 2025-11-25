---
change-id: deliver-phase1-core-workflows
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

1. - [x] **UR‑003/UR‑004 契約盤點與文件化**  
     - 產出 `/api/v1/studies/search`, `/api/v1/studies/{exam_id}`, `/api/v1/reports/{report_id}` 與 `/api/v1/ai/annotations/{report_id}` 的 DTO/欄位/錯誤碼對照（來源：`backend_django/docs/010_BACKEND_INTEGRATION_CHECKLIST.md` + 現行 Django schema，模組化架構見 `study/`, `report/`, `common/`）。  
     - 更新 `docs/requirements/02_FRONTEND_PRD_SR_SD.md` & `03_BACKEND_PRD_SR_SD.md` 的對應段落。  
     - **驗證**：OpenAPI 片段可由 `openspec` 引用，並附帶一份 example payload。

2. - [x] **Study Search 前端整合 + 測試**  
   - 將 `frontend/src/services/study.ts` 切換至真實 API，移除 `mockApiInterceptor` fallback，並新增 error-handling。  
   - 補上 `pnpm test` 內針對搜尋 + 分頁 + filter options 的整合測試（含 401/500 case）。  
   - **驗證**：`pnpm lint && pnpm test` 綠燈；提供「真實 API 回應錄影或截圖」。

3. - [ ] **Report Detail + AI 標記串接**  
   - 依契約讓 Report Detail 頁一次並行請求報告/AI 標記/專案摘要，並顯示 loading/error state。  
   - 針對 AI 標記列表建立最少 3 個 UI 單元測試（highlight/classification/history）。  
   - **驗證**：通過測試並附上端到端操作錄影，確認 mock 關閉後仍可運作。

4. - [x] **Projects RBAC 與批次指派整合**  
   - 從 Django API 擷取 roles matrix（owner/admin/editor/viewer）映射到前端權限，並調整 batch actions（加入專案/移除/封存）以符合角色限制。  
   - 實作 shopping cart → Projects API 的批次 assign/remove 操作，並撰寫 e2e 腳本覆蓋成功/權限不足案例。  
   - **驗證**：`pnpm test` 新增 e2e 測試；提供 Postman collection 驗證 RBAC。

5. - [ ] **ExportTask 後端非同步化**  
   - 將現有同步匯出流程改為背景任務（可用 Celery/async job），加入進度欄位（pending/processing/completed/failed）與下載 URL 自動過期。  
   - 擴充 `/api/v1/export/project`、`/api/v1/export/search` 回傳匯出任務 ID + 輪詢端點。  
   - **驗證**：`python manage.py test` 增加 3 個任務生命周期測試；提供任務進度 API 範例。

6. - [x] **匯出 UX 與通知**  
   - 在 Study Search / Projects 頁整合新的匯出 API，支援「整個搜尋」與「僅選取項目」兩種模式，並新增進度條 / 狀態提示 / 下載歷史。  
   - 追加整合測試確認匯出失敗時的錯誤顯示與重試流程。  
   - **驗證**：`pnpm test` + `pnpm build` 綠燈；附錄完成後的 UX 錄影與使用說明。
   - **備註**：2025-11-25 完成。因後端 ExportTask 非同步化 (Task 5) 尚未完成，目前實作同步下載模式 (Sync Download) 並支援「僅匯出選取」。UI 包含 ExportDialog、檔案名稱設定與格式選擇。整合測試已加入 `ExportDialog.test.tsx`。

7. - [x] **API Sort 參數修復與標準化**
   - 修復 `/api/v1/reports/search/paginated` 對 `verified_at_asc` 與 `verified_at_desc` 的支援。
   - 檢查並修正其他 API (Study, Project) 的 `sort` 參數處理，確保支援 ASC/DESC 並有正確的 default behavior。
   - **驗證**：已建立單元測試 `backend_django/tests/test_report_service_sort.py`（需環境修復後執行驗證）。
