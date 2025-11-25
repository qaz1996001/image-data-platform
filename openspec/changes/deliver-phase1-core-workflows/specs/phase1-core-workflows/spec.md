## MODIFIED Requirements

> **Backend Architecture Note**: 自 v2.0 起，後端採用模組化架構（`study/`, `project/`, `report/`, `common/`），詳見 `docs/MODULE_REFACTORING.md`。API 路徑保持不變，向後兼容。

### Requirement: UR-003 檢查記錄搜尋
UR-003 **SHALL** 強制 Study Search UI 使用實際 Django 端點與統一分頁/快取契約，並禁止在正式環境落回 mock。

#### Scenario: 統一的 /studies/search 契約
- 給定使用者輸入關鍵字與多個篩選條件時，前端 **SHALL** 呼叫 `GET /api/v1/studies/search`（實作於 `study/api.py`）並傳遞 `page`, `page_size`, `sort`、`filters`（含 `exam_status`, `exam_source`, `exam_item`, `date_range`, `has_annotation`, `project_id` 等）欄位。
- 當後端依 `backend_django/docs/010_BACKEND_INTEGRATION_CHECKLIST.md` 回傳 `code/message/data` 物件（`data` 內含 `total`, `page`, `page_size`, `total_pages`, `studies[]` 與 `filters`），前端 **MUST** 依據該資料更新列表與篩選選項；任何缺失欄位都 **SHALL** 被標記為錯誤並記錄 telemetry。

#### Scenario: 篩選選項快取與降級
- 後端 **SHALL** 使用 Redis/locmem 快取 `/studies/filters/options` 結果（TTL 24h，失敗時回退 DB），前端 **SHALL** 緩存結果並僅在權限或資料版本變化時重新抓取。
- 當快取不可用時，後端仍 **MUST** 回傳完整資料且 `cache_status` 欄位標示 `miss`，前端 **SHALL NOT** 阻止搜尋但需顯示提示。

### Requirement: UR-004 報告詳情與 AI 標記
UR-004 **SHALL** 要求報告詳情視圖整合 AI 標記與專案摘要，並在任一 API 失敗時提供可重試的錯誤處理。

#### Scenario: 報告詳情聚合載入
- 當使用者開啟任一報告時，前端 **SHALL** 併發呼叫 `GET /api/v1/studies/{exam_id}`, `GET /api/v1/reports/{report_id}`, `GET /api/v1/ai/annotations/{report_id}`，並以 `Promise.allSettled` 聚合。
- 若任一請求 404，UI **MUST** 顯示「資源不存在」並提供返回上一頁；若 AI 標記 API 失敗，報告內容仍 **SHALL** 顯示但標示「AI 標記載入失敗，可重試」，並允許使用者重新觸發載入。

#### Scenario: AI 標記與專案摘要呈現
- 成功取得 AI 標記後，前端 **SHALL** 依類型（highlight/classification/extraction/scoring）渲染卡片，並顯示時間與提示詞；同時 **SHALL** 從 `GET /api/v1/projects/{id}/studies` 摘要中顯示該報告屬於哪些專案與角色。
- 任何刪除/編輯行為 **MUST** 呼叫對應 API（PUT/DELETE `/api/v1/ai/annotations/{annotation_id}`），並在成功後即時更新列表。

### Requirement: UR-007 專案管理與批次指派
UR-007 **SHALL** 規範專案 CRUD、RBAC 暴露與 selection cart 批次操作，確保角色權限能在 UI 與 API 之間一致，並以 Projects Workbench 為主要入口呈現。

#### Scenario: 角色感知的專案列表與批次操作權限
- `GET /api/v1/projects` 回傳的每筆資料 **SHALL** 含下列欄位：
  - `user_role`（owner/admin/editor/viewer）
  - `can_assign_studies: boolean`
  - `can_manage_members: boolean`
  - `can_archive: boolean`
- 前端 Projects 列表/卡片 **MUST** 以 badge 顯示 `user_role`，並依布林權限決定操作是否可用：
  - 只有 `owner` 可以刪除專案；`owner`/`admin` 可以封存/還原與編輯專案；
  - `editor` 可以對 studies 進行新增/移除但不得封存或刪除專案；
  - `viewer` 僅能閱讀，不得觸發批次指派/移除或專案狀態變更。
- 任一被禁用的操作按鈕 **SHALL** 顯示 tooltip（如「權限不足」「僅擁有者可刪除」），並確保在嘗試透過 API 執行超權限操作時，前端能正確顯示 403 或 `permission_denied` 訊息。

#### Scenario: Shopping cart → Projects 批次指派與移除
- Study Search 的 selection cart **SHALL** 作為批次指派/移除的唯一來源：當使用者在 Study Search 勾選多筆資料並點「加入專案」時，前端 **SHALL** 透過共用的 Project Assignment 流程：
  - 先呼叫 `GET /api/v1/projects` 取得可用專案清單；
  - 僅允許 `can_assign_studies === true` 的專案可被勾選作為批次目標，無權限專案需以「無權指派」標籤或 tooltip 標示。
- 對單一專案批次指派時，前端 **SHALL** 呼叫 `POST /api/v1/projects/{project_id}/studies`，並 **SHALL** 遵守後端設定的 500 筆批次上限與回傳結構（含 `added_count`, `skipped_count`, `failed_items[]`, `requested_count`, `max_batch_size`）；對多專案批次指派時，前端 **SHALL** 使用 `/api/v1/projects/batch-assign` 合約。
- 成功指派或移除後，selection cart **MUST** 自動清空並重新載入相關列表（Study Search / Projects）；若後端回傳 `failed_items`（例如已存在、未找到或無權限），UI **SHALL** 以列表或對話框列出詳細錯誤（含 `exam_id`, `reason`），讓使用者可重試或調整選擇。

### Requirement: UR-008 匯出功能
UR-008 **SHALL** 覆蓋非同步匯出任務、進度輪詢與「僅匯出選取資料」兩種模式，以確保匯出行為可追蹤。

#### Scenario: 匯出任務生命週期
- 使用者觸發匯出（搜尋條件或專案）時，前端 **SHALL** 呼叫 `POST /api/v1/export/(search|project)` 並取得 `task_id`，之後 **SHALL** 以 `GET /api/v1/export/tasks/{task_id}` 追蹤 `status`（pending/processing/completed/failed）與 `progress`（0~100）。
- 後端 **MUST** 在 5 分鐘內完成 10,000 筆匯出或給出失敗狀態；完成時 **SHALL** 回傳 `download_url`（具過期時間）。前端 **SHALL** 提供進度條、完成通知與失敗後的重試按鈕。

#### Scenario: 僅匯出選取資料
- Study Search selection cart **SHALL** 支援「匯出選取」模式，前端 **SHALL** 將 `exam_id` 列表附於 POST payload；後端 **MUST** 驗證使用者是否對所有選取資料擁有匯出權限，否則回傳 403 並標示哪些項目失敗。
- 當資料量超過 10k 或使用者權限不足時，API **MUST** 回傳明確錯誤碼（如 `export_limit_exceeded`, `permission_denied`），前端 **SHALL** 根據錯誤碼顯示導覽建議（例如請縮小範圍或尋求管理者協助）。

