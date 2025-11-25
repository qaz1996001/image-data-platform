---
change-id: enforce-projects-rbac-batch
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Summary

為 UR‑007（專案管理）補齊 **RBAC 權限暴露** 與 **批次指派流程** 的詳規：Django Projects API 需回傳角色資訊並強制批次操作上限/錯誤回饋；前端需依角色限制顯示操作、將 selection cart 透過共用服務批次指派/移除，並以 E2E 覆蓋成功與 403 案例。

## Why

- Phase 1 的 Projects 功能雖然已有基本 CRUD 與 RBAC，但 API 回傳缺乏明確的角色與可用操作欄位，前端無法可靠地依權限關閉或隱藏危險操作。
- Study Search 與 Projects 目前各自實作批次指派流程，對「500 筆上限」「部分失敗」「權限不足」等情境缺少統一約定，容易在 UI 與 API 之間產生不一致行為。
- 若沒有標準化的批次回應格式與自動化測試覆蓋，交付核心工作流時需要大量人工驗證 RBAC 與批次錯誤處理，風險過高。

## What Changes

- 新增 `projects-rbac-batch` spec，定義 Projects API 必須回傳的 `user_role` 與布林權限欄位（如 `can_assign_studies`、`can_manage_members`、`can_archive`），以及批次指派/移除端點的輸入與回應合約（含 `max_batch_size=500`、`failed_items[]`、`requested_count` 等欄位）。
- 後端 Django Projects 應用需依此 spec 擴充 serializer / service：從 `ProjectMember` 關係推導角色與權限、在 `POST /projects/{id}/studies` 中實作 500 筆上限與 `failed_items` 回傳、並針對 RBAC 權限不足回傳 403 與對應錯誤碼。
- 前端需在 Projects / Study Search 中導入統一的 `ProjectRole` 型別與 `ProjectBatchService`，依 API 權限欄位 gating UI 按鈕行為，並使用批次回應中的 `added_count` / `skipped_count` / `failed_items[]` 呈現成功與錯誤細節，同時以 Vitest + Playwright e2e 覆蓋成功與 403 案例。

## Motivation

- 後端 `projects` app 雖已提供 CRUD/RBAC，但現行 API 回應未帶 `role`，前端無法根據權限決定是否可刪除/封存/批次指派。
- Study Search 選取清單與 Projects 動作各自實作批次呼叫，缺少統一的 service 來處理 500 筆上限與 `failed_items`，容易導致 UI 與 API 行為不一致。
- 缺乏自動化測試驗證「權限不足」與「批次超量」情境，導致交付 Phase 1 核心工作流時仍需人工驗證。

## Scope

### In scope
- 後端：`backend_django/projects` serializer/view 回傳 `role`、批次 `POST /projects/{id}/studies` 驗證 500 筆並回傳 `failed_items`，以及對應單元測試。
- 前端：更新 `types/projects.ts`、`hooks/projects/useProjects.ts`、`pages/Projects/index.tsx` 顯示角色徽章並依布林權限控制操作。
- 建立 `frontend/src/services/projectBatch.ts` 串接 selection cart，供 Study Search / Projects 共享批次 assign/remove 流程。
- 新增 Playwright e2e (`frontend/e2e/projects-rbac.spec.ts`) 覆蓋成功與 403 案例。

### Out of scope
- 重新設計 Projects UI（仍延用既有 List Workbench 版面）。
- 匯出、報告詳情等其他 change 的需求（已有獨立 proposal）。

## Success Criteria

- `openspec validate enforce-projects-rbac-batch --strict` 通過。
- 後端/前端實作完成後，可在 Projects 列表上顯示角色並正確 gating 操作；批次加入/移除超過 500 筆或無權限時會收到 `failed_items`、UI 呈現錯誤明細。
- Playwright e2e 針對成功與 403 案例皆綠燈。

## Risks / Open Questions

- selection cart 當前僅存在 Study Search；是否需要在其他頁也共享？若未來需要，ProjectBatchService 需保持可重複使用。
- RBAC 角色來源若與 Django model 不一致，需同步調整 API schema；本提案假設 `owner/admin/editor/viewer` 為最終定義。

