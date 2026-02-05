---
change-id: raise-study-select-cap
status: draft
---

# Raise Study Select Cap — Server-side 全選批次指派 API 設計

## 背景
- 既有「全選全部」以大量 `exam_ids` 從前端傳回，受 page_size/傳輸限制。
- 需求：全選時改將「搜尋條件」傳給後端，由後端用 SQL 篩選並批次寫入專案資源。

## 範圍
- 新增一支「依查詢條件批次加入專案」API（僅 studies，未涵蓋 reports）。
- 遵守現有批次上限 (`max_batch_size`)，並沿用 RBAC/failed_items 合約。
- 前端只需傳遞目前搜尋條件與 target projects，不再傳巨量 IDs。

## API 合約（提案）
- `POST /api/v1/projects/batch-assign/query`
- Auth: JWT；權限：對每個 `project_id` 需 `can_assign_studies`。
- Request
  ```json
  {
    "project_ids": ["<uuid>", "..."],          // 至少 1 個
    "filters": {                               // 僅接受 Study Search 既有欄位；未知欄位忽略
      "q": "腹部",                             // optional
      "exam_status": ["completed"],            // string | string[]
      "exam_source": ["CT","MRI"],             // string | string[]
      "exam_item": "CT Chest",                 // string
      "patient_gender": "F",                   // string | string[]
      "patient_age_min": 18,                   // number
      "patient_age_max": 80,                   // number
      "start_date": "2024-01-01",              // string (ISO)
      "end_date": "2024-12-31"                 // string (ISO)
      // 如傳入其他欄位：直接忽略，不報錯；sort 一律忽略（僅篩選 + distinct）
    },
    "max_batch_size": 10000                    // optional override; <= SERVER_CAP（預設 10,000）
  }
  ```
- Response (200)
  ```json
  {
    "success": true,
    "matched_count": 845,                      // 符合條件的總筆數（去重後）
    "max_batch_size": 10000,
    "projects_updated": 1,
    "details": [
      {
        "project_id": "<uuid>",
        "added_count": 820,
        "skipped_count": 25,                   // 已存在於該專案
        "failed_items_sample": [
          {"exam_id": "EX123", "reason": "not_found"}
        ],
        "failed_items_truncated": false,
        "failed_items_sample_limit": 20
      }
    ]
  }
  ```
- Error 400 `too_many_items`
  ```json
  {
    "code": "too_many_items",
    "message": "一次最多僅能處理 10000 筆資料",
    "requested_count": 18450,
    "max_batch_size": 10000
  }
  ```
- Error 403 `permission_denied`（針對全無權限時直接 403；若部分無權限專案，該專案 detail 回報 `added_count=0`、`failed_reason=permission_denied`，總體 `success` 仍 true）

## 行為與邊界
- **filters 規則**：僅接受 Study Search 既有欄位（q, exam_status, exam_source, exam_item, patient_gender, patient_age_min/max, start_date, end_date）；未知欄位忽略；`sort` 一律忽略（僅篩選 + distinct exam_id）。
- **資料集**：以 Study Search 同源的 filter builder 產生 QuerySet，僅取 `exam_id` 並 `distinct`。
- **上限**：`effective_max_batch = min(request.max_batch_size or SERVER_CAP, SERVER_CAP)`（SERVER_CAP 預設 10,000）；若 `matched_count > effective_max_batch` 則直接 400 `too_many_items`，不做部分寫入。
- **批次寫入**：對每個 `project`：
  - 驗證權限；無權限則 detail 標記 `failed_reason=permission_denied`、`added_count=0`，整體 success 保持 true；若所有專案皆無權限則 403。
  - 計算已存在集合，插入新集合；`failed_items_sample` 僅保留前 20 筆（以 `failed_items_sample_limit` 常數提供），附 `failed_items_truncated`。
  - 更新 `study_count`。
- **效能**：`iterator(chunk_size=500)` 取 exam_ids；寫入用 `bulk_create` 分批。
- **日誌/Telemetry**：記錄 `matched_count`、`added_count`、`project_ids`、`failed_items_truncated`，避免過度。
- **一致性**：回應沿用 `/projects/{id}/studies` 的 `added_count/skipped_count/failed_items_sample` 結構，避免巨量清單。
- **Selection Drawer 狀態模型**：List View store MUST 維護 `selection_summary`（包含 mode, count, queryPayload, truncated）。UI（`SelectionDrawerTrigger`, `SelectionDrawer`, ProjectAssignmentModal）須以 summary 為權威資料來源，不再以 `selectedItems.length` 推論，以避免「300 筆」顯示上限造成誤判。
- **虛擬選取（Query 選取）**：當使用者執行「全選全部」→「交由後端批次指派」時，前端僅需保留樣本資料供 Drawer 顯示，但 summary 的 `count`/`queryPayload` MUST 與 `batch-assign/query` payload 對齊，並顯示「僅顯示前 N 筆 / 共 X 筆」說明。

## 前端流程（摘要）
- 當 selectionMode = "all"：
  - 將當前 Study Search query params 打包為 `filters`，連同 target `project_ids` 呼叫新 API。
  - 根據回應顯示「新增 X 筆，略過 Y 筆（已存在）」；若 `too_many_items`，提示縮小範圍。
  - 成功後清空 selection store 並刷新列表。

## 待辦與風險
- 待辦：確認 filters 覆蓋全部 Study Search 欄位且無需排序參數；如需 report-based條件需另案處理。
- 風險：極端條件仍可能匹配 >10k 筆，需監控並視需要改為非同步任務。

