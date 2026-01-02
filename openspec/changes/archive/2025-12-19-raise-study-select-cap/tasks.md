# Tasks: Raise Study Select Cap

1. Discovery
   - [x] 審查 `StudySearch/index.tsx` 的 `handleSelectAllAcrossPages` 流程與 `studyService.searchStudies` page_size 限制。
   - [x] 評估是否已有共用設定來源（環境變數或 constants）可覆用，若無則記錄新增位置。

2. Implementation
   - [x] 新增 `STUDY_SEARCH_FULL_SELECT_CAP`（預設 9,999），允許透過 `import.meta.env` 或共用 config 覆寫。
   - [x] 更新 `handleSelectAllAcrossPages` 以 `cap` 取代 `total` 作為 API page size，並在結果 < cap 時紀錄 warning。
   - [x] 在 UI Summary 按鈕顯示 `全選全部 (最多 cap 筆)`，並於成功 / 超過上限時提供訊息。
   - [x] Reports 頁 Summary 增設 `全選全部 (最多 cap 筆)` 按鈕並沿用 cap 邏輯，支援跨頁全選。
   - [x] Reports 頁 `resultsActions` 與 Study Search 對齊：含欄位設定、全選/取消、加入專案、選單觸發與匯出按鈕。
   - [x] 實作跨頁分頁累積功能（`paginatedFetch` helper）：自動分頁請求直到達到 cap 或 total，解決 API page_size 限制問題。
   - [x] 實作 SelectionDrawer 最大選取數量限制（`SELECTION_DRAWER_MAX_ITEMS`，預設 9999）：在選取時檢查並阻止超過限制，改進 SelectionDrawer 使用 List 組件並支援分頁顯示（超過 50 筆自動分頁，支援 50/100/200/500 筆每頁選項）。
   - [x] 新增「全選全部 → 直接傳遞查詢條件」後端批次指派 API 合約（路徑、payload、回應結構、上限/權限/錯誤碼），確保不用前端攜帶巨量 exam_ids。
   - [x] 在後端設計中明確規範 SQL 篩選與批次寫入行為：使用 Study Search 同源的篩選器構建 QuerySet，套用 `max_batch_size`/`matched_cap`，並對每個 target project 逐一檢查 `can_assign_studies`、去重並回傳 `added_count/skipped_count/failed_items`（需截斷樣本避免超量 payload）。
   - [x] 前端全選流程新增 decision：當 selectionMode = all 時改呼叫新 API，傳遞目前搜尋條件 (q + filters + date range + modality 等) 而非 exam_ids 陣列，並在回應顯示 matched/added 數量與 cap 截斷提示。
   - [x] 設計強化：列出允許 filters、忽略未知欄位與 sort；`effective_max_batch = min(request.max_batch_size or SERVER_CAP, SERVER_CAP)` 超量直接 400；failed_items_sample 附 `failed_items_sample_limit` 與 truncated；部分無權限專案回 detail `failed_reason=permission_denied`（全無權限才 403）；Telemetry 僅記錄 matched/added/project_ids/truncated。
   - [x] ListView store MUST 追蹤 `selection_summary`（mode/count/queryPayload/truncated），SelectionDrawerTrigger / SelectionDrawer / 批次動作按鈕 SHALL 以 summary.count 顯示，避免樣本上限（如 300 筆）造成誤判。
   - [x] Study Search / Report Search 全選成功後 SHALL 設定 `selection_summary = { mode: 'query', count: targetCount, queryPayload }`，並在 SelectionDrawer 顯示「僅顯示前 N 筆 / 共 X 筆」；清除或手動調整選取需回到 mode=`manual`。
   - [x] ProjectAssignmentModal MUST 讀取 selection summary：若 `mode=query` 則改送 `/projects/batch-assign/query` 並顯示正確筆數，即使僅儲存樣本資料也要提示「僅顯示前 N 筆」。

3. Validation
   - [x] 撰寫單元測試：模擬 `total=120`、`cap=80` 等情境，驗證訊息與選取筆數。
   - [ ] 手動測試：於測試環境建立超過 100 筆檢查，執行全選確認成功選取 cap 筆。
   - [ ] `pnpm lint && pnpm test && pnpm build`


