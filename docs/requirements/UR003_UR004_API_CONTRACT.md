# UR‑003 / UR‑004 API Contract（Study Search ＆ Report Detail）

本文件將 `backend_django/studies/api.py`、`backend_django/studies/report_api.py` 與 `backend_django/docs/010_BACKEND_INTEGRATION_CHECKLIST.md` 中的實作/規格收斂為一份可引用的契約，供前後端在處理 **UR‑003（檢查記錄搜尋）** 與 **UR‑004（報告詳情與 AI 標記）** 時使用。

---

## 1. 共用約定

| 條目 | 說明 |
| --- | --- |
| 認證 | 所有端點僅接受 `Authorization: Bearer <JWT>`，401 時回傳 `{"detail": "Unauthorized"}`。 |
| Content-Type | `application/json; charset=utf-8`。匯出端點另有檔案回應。 |
| Datetime | 一律為 `YYYY-MM-DDTHH:MM:SS` ISO 8601（`backend_django/studies/config.APIConfig`）。 |
| 失敗回應 | 400 參數錯誤、401 未授權、403 無權操作、404 資源不存在、429 Rate Limit、5xx 伺服器錯誤。 |
| 錯誤格式 | 依 Django Ninja 預設：`{"detail": "<message>"}`；欄位驗證錯誤為 `{"detail": [{"loc": [...], "msg": "..."}]}`。 |

---

## 2. `GET /api/v1/studies/search`

### 查詢參數

| 名稱 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `q` | string (<= 200) | 否 | 關鍵字，搜尋 9 個欄位（`StudyService.TEXT_SEARCH_FIELD_COUNT`）。 |
| `exam_status` | string | 否 | pending / completed / cancelled。 |
| `exam_source` | string | 否 | 資料來源（PACS、HIS…）。 |
| `exam_equipment[]` | array\<string> | 否 | 支援 `exam_equipment=value` 與 `exam_equipment[]=value` 兩種格式。 |
| `application_order_no` | string | 否 | 檢查申請單號。 |
| `patient_gender[]` | array\<string> | 否 | `M/F/U`。 |
| `exam_description[]` | array\<string> | 否 | 常見檢查描述，回應會提供建議清單。 |
| `exam_room[]` | array\<string> | 否 | 檢查房間。 |
| `patient_age_min` / `patient_age_max` | integer | 否 | 病患年齡範圍。 |
| `start_date` / `end_date` | string (`YYYY-MM-DD`) | 否 | 以 `check_in_datetime` 為基準的日期區間。 |
| `sort` | string | 否 | `order_datetime_desc`（預設）、`order_datetime_asc`、`patient_name_asc`。 |
| `page` / `page_size` | integer | 建議 | 新版分頁。`page>=1`、`1<=page_size<=100`。 |
| `limit` / `offset` | integer | 否 | 舊版分頁；缺省時仍支援。後端自動夾限 `limit<=100`。 |

> **授權**：必須附帶 JWT。Rate limit 建議 100 req/min（見 `010_BACKEND_INTEGRATION_CHECKLIST.md`）。

### 回應欄位

Top-level 結構（Django Ninja `@paginate` 預設）：

| 欄位 | 型別 | 說明 |
| --- | --- | --- |
| `items` | array\<`StudyListItem`> | 單頁資料。 |
| `count` | integer | 總筆數。 |
| `filters` | `FilterOptions` | 用於下拉清單的唯一值。 |

`StudyListItem`（來源：`backend_django/studies/schemas.py`）：

| 欄位 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `exam_id` | string | ✅ | 主鍵。 |
| `medical_record_no` | string | 否 | 病歷號。 |
| `application_order_no` | string | 否 | 申請單號。 |
| `patient_name` | string | ✅ | 病患姓名。 |
| `patient_gender` | string | 否 | M/F/U。 |
| `patient_age` | integer | 否 | 年齡。 |
| `exam_status` | string | ✅ | pending/completed/cancelled。 |
| `exam_source` | string | ✅ | HIS/PACS/...。 |
| `exam_item` | string | ✅ | 例如 Chest CT。 |
| `exam_description` | string | 否 | 說明。 |
| `order_datetime` | datetime | ✅ | ISO 8601。 |
| `check_in_datetime` | datetime | 否 | ISO 8601。 |
| `report_certification_datetime` | datetime | 否 | ISO 8601。 |
| `certified_physician` | string | 否 | 報告醫師。 |

`FilterOptions`：

| 欄位 | 型別 | 說明 |
| --- | --- | --- |
| `exam_statuses` | array\<string> | 依據資料庫去重排序。 |
| `exam_sources` | array\<string> | 同上。 |
| `exam_items` | array\<string> | 常見檢查項目。 |
| `equipment_types` | array\<string> | 常見設備型號。 |
| `exam_rooms` | array\<string> | 檢查室（延伸欄位）。 |
| `exam_equipments` | array\<string> | 設備名稱。 |
| `exam_descriptions` | array\<string> | 最多 100 筆熱門描述。 |

#### 成功範例

```json
{
  "items": [
    {
      "exam_id": "EXAM000001",
      "medical_record_no": "MR-0001",
      "patient_name": "李雅婷",
      "patient_gender": "F",
      "patient_age": 42,
      "exam_status": "completed",
      "exam_source": "PACS",
      "exam_item": "Chest CT",
      "exam_description": "High resolution CT",
      "order_datetime": "2025-01-20T10:15:00",
      "check_in_datetime": "2025-01-20T09:55:00",
      "report_certification_datetime": "2025-01-20T13:20:00",
      "certified_physician": "Dr. Chen"
    }
  ],
  "count": 1342,
  "filters": {
    "exam_statuses": ["pending", "completed", "cancelled"],
    "exam_sources": ["HIS", "PACS", "RIS"],
    "exam_items": ["CT", "MRI", "X-Ray"],
    "equipment_types": ["CT Scanner", "MRI"],
    "exam_rooms": ["Room 101", "Room 302"],
    "exam_equipments": ["Siemens SOMATOM"],
    "exam_descriptions": ["Chest CT", "Abdomen CT"]
  }
}
```

#### 失敗情境

| HTTP | 錯誤碼 | 說明 |
| --- | --- | --- |
| 400 | `study_invalid_params` | 非法的日期/分頁參數。 |
| 401 | `unauthorized` | 缺少或過期的 JWT。 |
| 404 | `study_not_found` | 僅在限制性過濾導致無結果時回傳 `items=[], count=0`（不拋 404）。 |
| 500 | `study_query_failed` | `StudyService` 擲出 `DatabaseQueryError`。 |

---

## 3. `GET /api/v1/studies/{exam_id}`

| Path 參數 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `exam_id` | string | ✅ | 例：`EXAM000001`。 |

回應資料採 `StudyDetail` schema（所有欄位來自 `Study.to_dict()`）：

| 欄位 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `exam_id`, `patient_name`, `exam_status`, `exam_source`, `exam_item`, `equipment_type`, `order_datetime` | 與 search 同 | ✅ | 關鍵欄位。 |
| 其餘（`medical_record_no`, `application_order_no`, `patient_gender`, `patient_birth_date`, `patient_age`, `exam_description`, `exam_room`, `exam_equipment`, `check_in_datetime`, `report_certification_datetime`, `certified_physician`, `data_load_time`） |  | 否 | 允許 `null`。 |

#### 例：成功

```json
{
  "exam_id": "EXAM000001",
  "medical_record_no": "MR00000001",
  "application_order_no": "AON000001",
  "patient_name": "John Doe",
  "patient_gender": "M",
  "patient_birth_date": "1979-05-15",
  "patient_age": 45,
  "exam_status": "completed",
  "exam_source": "PACS",
  "exam_room": "Room 101",
  "exam_item": "CT",
  "exam_description": "CT scan of chest",
  "exam_equipment": "Siemens SOMATOM",
  "equipment_type": "CT Scanner",
  "order_datetime": "2024-11-07T14:30:00",
  "check_in_datetime": "2024-11-07T14:15:00",
  "report_certification_datetime": "2024-11-07T15:00:00",
  "certified_physician": "Dr. Smith",
  "data_load_time": "2024-11-07T15:05:00"
}
```

#### 失敗

| HTTP | 錯誤碼 | 說明 |
| --- | --- | --- |
| 404 | `study_not_found` | 找不到 exam_id。 |
| 500 | `study_detail_failed` | 服務層擲出 `DatabaseQueryError`。 |

---

## 4. 報告詳情：`GET /api/v1/reports/{uid}` 與 `/api/v1/reports/study/{exam_id}`

- `/api/v1/reports/{uid}`：以報告 UID 查詢（主鍵）。
- `/api/v1/reports/study/{exam_id}`：以對應的 `report_id`（即檢查 ID）取得最新報告。

`ReportDetailResponse` 欄位：

| 欄位 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `uid` | string | ✅ | 報告唯一識別。 |
| `report_id` | string | 否 | 與 study/exam 關聯。 |
| `title` | string | ✅ | 報告標題。 |
| `report_type` | string | ✅ | PDF/HTML/TXT… |
| `version_number` | integer | ✅ | 最新版號。 |
| `is_latest` | boolean | ✅ | 是否為最新。 |
| `created_at`, `verified_at` | datetime | ✅/否 | ISO 8601。 |
| `content_preview` | string | ✅ | 500 字預覽。 |
| `content_raw` | string | ✅ | 完整內容。 |
| `source_url` | string | ✅ | 原始來源 URL。 |

#### 例：成功

```json
{
  "uid": "rep-73de12",
  "report_id": "EXAM000001",
  "title": "Chest CT Report",
  "report_type": "PDF",
  "version_number": 3,
  "is_latest": true,
  "created_at": "2025-01-15T08:00:00",
  "verified_at": "2025-01-15T09:10:00",
  "content_preview": "CT of the chest demonstrates...",
  "content_raw": "Full report body...",
  "source_url": "https://pacs.example/report/rep-73de12"
}
```

失敗碼：404（報告不存在）、500（`ReportService` 例外）。

---

## 5. `GET /api/v1/ai/annotations/{report_id}`

| 項目 | 說明 |
| --- | --- |
| Path | `report_id`（整數，對應報告資料表主鍵）。 |
| Query | 可選 `annotation_type`（目前 Django 版本尚未開放，但已在 `docs/api/04_API_SPECIFICATION.md` 規劃）。 |

`AIAnnotation` 物件（依 `docs/database/03_DATABASE_DESIGN.md`）：

| 欄位 | 型別 | 說明 |
| --- | --- | --- |
| `id` | integer | 主鍵。 |
| `report_id` | integer | 關聯報告。 |
| `annotation_type` | string | `highlight` / `classification` / `extraction` / `scoring` / `custom`。 |
| `user_prompt` | string | 提示詞。 |
| `content` | object | JSON 結構依型別而異。 |
| `confidence` | number | 0~1，可為 null。 |
| `raw_response` | string | LLM 原始輸出。 |
| `model_name` | string | 預設 `qwen2.5:7b`。 |
| `is_edited` | boolean | 是否被人工修改。 |
| `created_at` | datetime | 建立時間。 |
| `edited_at` | datetime | 若 `is_edited=true` 才有值。 |

範例：

```json
[
  {
    "id": 9182,
    "report_id": 732,
    "annotation_type": "highlight",
    "user_prompt": "標記報告中的關鍵發現",
    "content": {
      "highlights": [
        {"text": "右上葉結節", "start": 125, "end": 129, "reason": "可能的病灶"}
      ]
    },
    "confidence": 0.91,
    "raw_response": "{\"highlights\":[...]}",
    "model_name": "qwen2.5:7b",
    "is_edited": false,
    "created_at": "2025-01-18T07:22:11",
    "edited_at": null
  }
]
```

錯誤碼：404（報告不存在或尚無標記）、500（資料庫錯誤）。

---

## 6. 引用方式

- 前端 FE-SR（`docs/requirements/02_FRONTEND_PRD_SR_SD.md`）在描述 `FE-SR-010/020/030` 時應引用此文件以確保欄位/錯誤一致。
- 後端 BE-SR（`docs/requirements/03_BACKEND_PRD_SR_SD.md`）亦應引用本文件，確保 schema 與 `backend_django/studies/schemas.py` 不再分歧。
- OpenAPI 片段：`openspec/changes/deliver-phase1-core-workflows/specs/phase1-core-workflows/openapi/studies-report.yaml` 提供 `paths` 與 `components`，可直接給 API Gateway 或自動化測試使用。

