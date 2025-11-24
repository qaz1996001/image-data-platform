---
change-id: deliver-phase1-core-workflows
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Architectural Scope

四條 UR 牽涉三個前端模組（Study Search、Report Detail、Projects/Export）與兩個 Django 應用（studies、projects）。本設計說明資料流、契約與權限整合方式，避免後續實作發散。

## 1. Study Search / Report Detail 資料流

```
[UI Search Form] → [studyService.searchStudies] → GET /api/v1/studies/search
                                            ↓
                                     cache filters (Redis)
```

- **分頁/排序**：一律使用 `page/page_size`、`sort` 字串，對應 `backend_django` 的統一分頁（`backend_django/docs/implementation/...` §2.2）。
- **資料模型**：以 `StudyListItem` / `StudyDetail` TypeScript 型別對應 Django Pydantic schema，並由 `shared/types/studies.ts` 匯出給 hooks/UI。
- **Report Detail**：
  - `GET /api/v1/studies/{exam_id}` 用於「外層」資訊（患者/檢查）。
  - `GET /api/v1/reports/{report_id}` + `/ai/annotations/{report_id}` 並行請求，結果以 `Promise.allSettled` 聚合，顯示 loading/error。
  - 任何 401/403 交由 `authInterceptor` 重導登入頁。

## 2. Projects / RBAC 整合

```
[Selection Cart Store] --(selectedStudies)--> [ProjectBatchService]
[ProjectBatchService] --POST--> /api/v1/projects/{id}/studies
```

- **角色映射**：後端 roles（owner/admin/editor/viewer）映射到前端 enum，以 `canAssign`, `canExport`, `canArchive` 等布林包裝，減少 UI 判斷。
- **批次流程**：
  1. Study Search 選取 → `selectionStore` 儲存 exam_id。
  2. 使用者點「加入專案」→ 彈出專案列表（呼叫 `/projects`）。
  3. 確認後呼叫 `/projects/{id}/studies` 批次新增；若權限不足，依 403 訊息顯示提示。
  4. 成功後，`selectionStore.clear()` 並觸發 `useProjects().refresh()`.

## 3. Export 任務生命週期

```
[Export Request] → POST /api/v1/export/(search|project)
      ↓
  ExportTask (pending) ── Celery worker ──┐
      ↓                                   │
  status=processing ── generate file ──> storage (S3/local)
      ↓                                   │
  status=completed + download_url <───────┘
```

- **Task Model**：`id`, `type`, `scope` (search filters or project_id), `status`, `progress`, `file_path`, `expires_at`.
- **API**：
  - POST 回傳 `{ task_id }`
  - GET `/api/v1/export/tasks/{task_id}` 回傳狀態 + 下載 URL
  - 允許 `DELETE` 以取消未完成任務。
- **前端 UX**：
  - Study Search / Projects 頁面透過新的 `useExportTasks` hook 管理狀態。
  - 顯示「最近匯出」列表，提供重新下載/失敗重試。
  - 匯出模式：`search`（依目前條件）或 `selection`（需提供 exam_id 陣列）。

## 4. 測試與驗證

- **API**：Django 端以 `pytest`/`manage.py test` 覆蓋搜尋/詳情/專案/匯出端點，並使用 `RequestFactory` 模擬 JWT。
- **Frontend**：Vitest + Testing Library 覆蓋表單互動、loading/error、RBAC gating；Playwright/Synced e2e 覆蓋「搜尋→詳情→加入專案→匯出」完整路徑。
- **性能**：Study Search 目標 P95 < 500ms；ExportTask 需在 30 秒內排入 queue、300 秒內完成 10k 筆。

