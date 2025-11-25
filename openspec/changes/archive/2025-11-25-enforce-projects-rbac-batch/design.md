---
change-id: enforce-projects-rbac-batch
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Architectural Scope

此變更跨越 Django `projects` 應用與前端 Projects/Study Search 模組：需要在 API 層新增 role metadata、批次操作限制與錯誤回傳格式；在前端建立共用批次服務、驅動 selection cart → Projects API 的流程，並將權限狀態反映於 UI / 測試。

## 1. 後端 RBAC 擴充

```
client ──┬─ GET /api/v1/projects ──> ProjectSerializer(role=…)
         ├─ POST /projects/{id}/studies  (≤500, returns failed_items[])
         └─ DELETE /projects/{id}/studies (mirror API, optional)
```

- **ProjectSerializer**：加入 `role`（Enum: owner/admin/editor/viewer），由 `ProjectMembership` 或 request.user 和 project 的關係推導。
- **Batch endpoints**：統一接受 `{"exam_ids": []}`，若超過上限回傳 400 (`code=too_many_items`)；若單筆失敗，收集在 `failed_items` 陣列（含 `exam_id`, `reason`），其餘成功寫入。
- **Validation hooks**：服務層判斷角色對應權限（owner/admin: full, editor: add/remove only, viewer: read-only），並在 serializer errors 中附帶 `permission="assign_denied"`。

## 2. 前端角色與批次服務

```
selectionStore (examIds)
    │
    ▼
ProjectBatchService.assign({ projectId, examIds })
    │  ├─ calls POST /projects/{id}/studies
    │  └─ handles failed_items → toast + detail modal
```

- **Types/hooks**：`ProjectRole` enum + derived booleans (`canManageMembers`, `canAssignStudies`, `canArchive`). `useProjects()` 暴露角色資訊與 helper。
- **UI**：Projects 列表/卡片顯示角色徽章；批次操作按鈕依 `canAssignStudies` 決定 enable/tooltip。
- **Selection integration**：Study Search selection drawer與 Projects 頁行為透過 ProjectBatchService，確保相同上限與錯誤處理。成功後自動 `selectionStore.clear()` 並觸發 `useProjects().refresh()`。

## 3. 測試策略

- **Backend**：針對 role 解析、批次上限、failed_items/permission denied 各加一組單元測試。
- **Frontend**：
  - Vitest：`ProjectBatchService` 行為（成功/403/部分失敗）。
  - Playwright (`projects-rbac.spec.ts`)：以 mock API 驗證 owner 可以批次指派、viewer 嘗試指派時顯示權限錯誤。

## 4. Telemetry 與可觀測性

- 在前端批次操作錯誤處理時使用 `console.warn` + (若已有) telemetry hook 記錄 `project_batch_failed` (包含 `projectId`, `failureCount`, `reason`)，以供後續分析。

