## MODIFIED Requirements

### Requirement: UR-007 Projects RBAC 與批次指派
UR-007 **SHALL** 擴充專案 API 以傳遞角色與批次結果，並要求前端依角色控制操作、透過共用服務整合 selection cart 流程。

#### Scenario: Projects API exposes角色資訊
- `GET /api/v1/projects` **MUST** 在每筆專案資料中回傳 `role`（`owner`/`admin`/`editor`/`viewer`），並同時附帶 `can_manage_members`, `can_assign_studies`, `can_archive` 等布林欄位或可由角色推導。
- 前端 Projects List **SHALL** 以 badge/label 顯示目前使用者的角色，並在 telemetry 事件中包含 `role` 以便追蹤權限使用情形。

#### Scenario: Batch assign/remove validates limits and failed_items
- `POST /api/v1/projects/{project_id}/studies` **MUST** 接受 `exam_ids` 陣列，若超過 500 筆 **SHALL** 回傳 `400 code=too_many_items`，UI 需顯示縮小範圍的提示。
- 當部分項目失敗時（已存在、權限不足、已封存等），後端 **SHALL** 在回傳 body 中提供 `failed_items[]`（含 `exam_id`, `reason`），其餘成功的項目仍需寫入；前端 **MUST** 以列表或對話框呈現失敗明細。
- 任何缺乏 `can_assign_studies` 權限的角色呼叫該 API **MUST** 收到 `403 code=assign_denied`；UI **SHALL** 顯示「權限不足」訊息並保留 selection cart。

#### Scenario: Role-aware UI gating and tooltips
- Projects 列表與專案行動列 **SHALL** 依 `role`/布林權限決定哪些按鈕可用（例如 viewer 隱藏批次按鈕，editor 禁止刪除專案）；當按鈕被禁用時 **MUST** 提供 tooltip 說明原因。
- FE 測試（Vitest + Playwright）**MUST** 覆蓋 owner/admin/editor/viewer 至少各一種互動，確保角色切換時 UI 立即更新。

#### Scenario: Selection cart 批次流程與共用服務
- Study Search selection drawer 與 Projects 頁面 **SHALL** 共用 `ProjectBatchService` 以呼叫 assign/remove API，並在成功後自動 `selectionStore.clear()` + `useProjects().refresh()`。
- 該服務 **MUST** 處理 `failed_items`（顯示細節、計算成功/失敗數量）與重試；若 API 回傳 500 或網路錯誤，服務 **SHALL** 提供可重試承諾與 telemetry 事件 `project_batch_failed`。

#### Scenario: End-to-end RBAC regression coverage
- Playwright 腳本 `frontend/e2e/projects-rbac.spec.ts` **SHALL** 模擬至少兩種角色：  
  1) owner 成功批次新增，顯示成功 toast；  
  2) viewer 嘗試新增，看到權限錯誤且 selection cart 保留原狀。  
- 腳本 **MUST** 被納入 `pnpm test:e2e` 預設流程，並在 CI 報告中標示角色情境。

