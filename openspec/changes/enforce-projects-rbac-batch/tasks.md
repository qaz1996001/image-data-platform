---
change-id: enforce-projects-rbac-batch
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

1. - [x] **Projects API 回傳角色與批次驗證**  
     - 在 `backend_django/projects/serializers.py`、`views.py` 加入 `role` 欄位與 500 筆上限/`failed_items` 回傳邏輯。  
     - 更新/新增 `backend_django/tests/projects/test_rbac.py`、`test_batch_assign.py` 覆蓋 owner/admin/editor/viewer 權限與錯誤碼。  
     - **驗證**：`pytest backend_django/projects` 綠燈，並記錄一份 `failed_items` JSON 範例。

2. - [x] **ProjectRole 型別與 UI 權限 gating**  
     - 在 `frontend/src/types/projects.ts` 增加 `ProjectRole` enum + derived 權限；更新 `hooks/projects/useProjects.ts` 及 `pages/Projects/index.tsx` 顯示角色徽章並禁用不符權限的按鈕。  
     - 於 `frontend/src/components/Projects/ProjectCard.tsx` / action slots 加入 tooltip 說明權限不足。  
     - **驗證**：`pnpm lint` + `pnpm test`，並附上桌面截圖顯示不同角色的 UI。

3. - [x] **ProjectBatchService 與 selection cart 整合**  
     - 新增 `frontend/src/services/projectBatch.ts`，封裝 assign/remove API、500 筆判斷與 `failed_items` 處理。  
     - Study Search selection drawer、Projects 批次操作改用該 service；成功後清空選取並 refresh 相關列表。  
     - **驗證**：新增 `frontend/src/services/__tests__/projectBatch.test.ts` 覆蓋成功/部分失敗/403。

4. - [x] **Playwright e2e：Projects RBAC**  
     - 建立 `frontend/e2e/projects-rbac.spec.ts`：  
       1) owner 可以批次加入專案並看到成功提示。  
       2) viewer 嘗試批次加入時顯示權限錯誤。  
     - 提供錄影或截圖，並在 README/e2e 說明如何重播。  
     - **驗證**：`pnpm test:e2e --filter projects-rbac` 綠燈。

