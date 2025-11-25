# projects-rbac-batch Specification

## Purpose
為 UR‑007「專案管理」補齊 **RBAC 權限** 與 **批次指派/移除流程** 的穩定合約，確保 Django Projects API 一致回傳角色與權限 metadata，並對批次操作提供明確的上限與錯誤回饋格式，同時讓前端能依此正確 gating UI 行為與處理 `failed_items`。
## Requirements
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

### Requirement: Projects RBAC Role Metadata
Projects API MUST 回傳與呼叫者相關的專案角色與布林權限欄位，以便前端依權限顯示或禁用操作。

#### Scenario: 使用者在 Projects 列表中檢視自己可存取的專案
- `GET /api/v1/projects` 回應中的 `items[]` MUST 針對每個專案包含：
  - `user_role: "owner" | "admin" | "editor" | "viewer"`
  - `can_assign_studies: boolean`
  - `can_manage_members: boolean`
  - `can_archive: boolean`
- 專案建立者預設為 `owner`，其 `can_assign_studies`、`can_manage_members`、`can_archive` MUST 為 `true`。
- `owner` 與 `admin` 角色 MUST 擁有指派/移除檢查、管理成員與封存/啟用專案的權限；`editor` 角色 MUST 允許指派/移除檢查但不能管理成員或封存專案；`viewer` 角色 MUST 為唯讀（所有批次指派、成員管理與封存/刪除相關操作 SHALL 在 API 層被拒絕）。
- 權限判斷 MUST 由 Projects 服務層根據 `ProjectMember` 關係推導，而非由前端自行假設；任何 API 回應中權限欄位與實際行為 MUST 一致。

### Requirement: Project Study Batch Assignment Contract
Projects 批次指派/移除檢查的 API MUST 以統一的 JSON 合約處理上限、重複與不存在的檢查，並回傳 `failed_items` 陣列供前端呈現細節。

#### Scenario: 使用者批次將檢查加入某個專案
- `POST /api/v1/projects/{project_id}/studies` MUST 接受 payload：`{"exam_ids": string[]}`，忽略空字串並去除重複後再處理。
- 當去重後的 `exam_ids` 數量為 `0` 時，API MUST 回傳：
  - `success: true`
  - `added_count: 0`
  - `skipped_count: 0`
  - `failed_items: []`
  - `requested_count: 0`
  - `max_batch_size: 500`
- 若去重後的 `exam_ids` 數量 **> 500**，API MUST 回傳 HTTP 400，JSON 內含至少：
  - `code: "too_many_items"`
  - `max_batch_size: 500`
  - `requested_count: number`
- 當批次大小在允許範圍內時，API MUST：
  - 針對未存在於資料庫的檢查產生 `failed_items[]` 條目 `{ "exam_id": string, "reason": "not_found" }`。
  - 針對已在同一專案中的檢查產生 `failed_items[]` 條目 `{ "exam_id": string, "reason": "already_assigned" }`。
  - 僅對首次指派成功的檢查建立 `StudyProjectAssignment`，並回傳：
    - `success: true`
    - `added_count: number`（新增成功的筆數）
    - `skipped_count: number`（因已存在而未新增的筆數）
    - `failed_items: { exam_id, reason }[]`
    - `requested_count: number`
    - `max_batch_size: 500`
- 回應 MUST 同步更新 `Project.study_count`，確保 Projects 統計 API 能反映正確的檢查數量。

### Requirement: Project Study Batch Removal Contract
Projects 批次移除檢查的 API MUST 提供對稱的批次移除行為並維護專案的 `study_count` 正確性。

#### Scenario: 使用者從專案中批次移除檢查
- `DELETE /api/v1/projects/{project_id}/studies`（或等效端點） MUST 接受 payload：`{"exam_ids": string[]}`，忽略空字串與重複後執行刪除。
- 若去重後 `exam_ids` 為空，API MUST 回傳 `{"success": true, "removed_count": 0}`。
- 成功刪除後，API MUST 回傳：
  - `success: true`
  - `removed_count: number`（實際刪除的筆數）
- 每次刪除操作 MUST 同步遞減對應專案的 `study_count`，以維持 Projects 統計 API 一致性。

### Requirement: RBAC Enforcement for Batch Operations
Projects 批次指派/移除 API MUST 依 caller 與專案間的角色關係強制 RBAC 權限，禁止未授權的批次操作。

#### Scenario: 權限不足的使用者嘗試批次操作專案
- 當 `viewer` 角色或其他無權限角色呼叫 `POST /api/v1/projects/{project_id}/studies` 或對應的批次移除端點時，API MUST 回傳 403（或等效權限錯誤），JSON 內 SHOULD 包含：
  - `code: "assign_denied" | "permission_denied"`
  - `detail` 或 `message` 字串，說明目前角色不允許進行該操作。
- `owner` 與 `admin` 角色 MUST 被允許對自己擁有成員資格的專案執行批次指派與移除；`editor` 角色 MUST 僅允許指派與移除檢查，禁止管理成員與封存專案；`viewer` 角色 MUST 禁止所有批次指派/移除與成員管理操作。
- 若 payload 同時包含多個 `project_ids` 的批次指派（例如 `/api/v1/projects/batch-assign/`），服務層 MUST 逐一檢查每個目標專案的角色權限，對無權限的專案跳過實際指派並在回應中回報 0 筆成功與相符的權限錯誤資訊。

### Requirement: Frontend Role & Batch Handling Contract
前端 Projects 與 Study Search 模組 MUST 依據 API 回傳的角色與批次回應欄位，提供一致的 UI gating 與錯誤呈現行為。

#### Scenario: 使用者在前端批次指派檢查到專案
- 前端型別層 MUST 定義 `ProjectRole`（`"owner" | "admin" | "editor" | "viewer"`）與對應布林權限（如 `canAssignStudies`, `canManageMembers`, `canArchive`），並與 API 欄位保持同步。
- Projects 列表/卡片 MUST 顯示角色徽章（Owner/Admin/Editor/Viewer），並依布林權限決定批次操作按鈕與成員管理按鈕是否啟用；被禁用的按鈕 SHALL 顯示 tooltip 說明權限不足。
- 批次指派流程 MUST 透過共用的 `ProjectBatchService`（或等效服務）呼叫 `POST /api/v1/projects/{project_id}/studies`，並根據回應中的：
  - `added_count` / `skipped_count` 更新成功提示訊息，
  - `failed_items[]` 在 UI 中提供失敗清單（例如以 toast + 詳細列表或對話框呈現）。
- 當回應代碼為 400（`too_many_items`）或 403（權限錯誤）時，前端 MUST 以統一的錯誤訊息呈現（含伺服器回傳的 `message/detail`），並不得悄悄吞掉錯誤。
- 成功完成批次指派或移除後，前端 selection cart MUST 自動清空並重新整理相關列表頁，使 `study_count` 與選取狀態保持一致。

