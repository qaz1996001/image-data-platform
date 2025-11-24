---
change-id: deliver-phase1-core-workflows
status: draft
owners:
  - TBD
created-at: 2025-11-24
updated-at: 2025-11-24
extensions: {}
---

## Summary

推動 Phase 1 關鍵工作流（UR‑003 報告/檢查搜尋、UR‑004 報告詳情、UR‑007 專案管理、UR‑008 匯出）的「端到端交付」，將目前 **前端已完成的 UI/UX**（如 `frontend/docs/STUDY_SEARCH_COMPLETION_REPORT.md`、`frontend/docs/features/project-list-view-guide.md`）與 **後端已具備的 Django API 能力**（見 `backend_django/docs/implementation/實作狀態_當前進度_2025-01-13.md`）正式銜接，同時補足匯出與詳情視圖仍缺的契約、權限與進度回報機制。

## Motivation

- Study Search 前端已完成、並具備 mock fallback（`frontend/docs/STUDY_SEARCH_COMPLETION_REPORT.md`），但仍缺少對 `backend_django/docs/010_BACKEND_INTEGRATION_CHECKLIST.md` 所列四個 `/studies/*` 端點的正式整合與測試。
- 報告詳情（UR‑004）雖在 `docs/requirements/USER_REQUIREMENTS.md` 中定義需要 AI 標記與專案摘要，但現有 UI 尚未強制使用 `/reports/{id}` + `/ai/annotations/{report_id}` 的資料；同時 Django 端已於 `backend_django/docs/implementation/...` 宣告 95% 完成，需要收斂契約。
- 專案管理（UR‑007）在前端以 ListView Provider 完成（`frontend/docs/features/project-list-view-guide.md`），後端亦已提供完整 CRUD + RBAC（`backend_django/docs/implementation/...` §2.4），但尚未描述如何落實使用者角色、批次指派與選取匯入等整合情境。
- 匯出功能（UR‑008）前端仍列為 Phase 4（`frontend/README.md`）且僅支援「全搜尋匯出」 (`frontend/docs/features/study-table-management-guide.md` FAQ)，後端則已有 90% 功能但缺乏非同步與進度推播（`backend_django/docs/implementation/...` §2.5）。需要共同定義匯出任務生命週期與 UI 回饋。

## Scope

### In scope

1. **UR‑003 / UR‑004**：定義並鎖定 `/api/v1/studies/search`、`/api/v1/studies/{exam_id}`、`/api/v1/reports/{report_id}` 與 `/api/v1/ai/annotations/{report_id}` 的最終契約、分頁、快取與錯誤回應；描述前端如何移除 mock、導入實際 API 並新增整合測試。
2. **UR‑007**：釐清專案 CRUD、成員管理、Study 指派與批次操作的資料流程（從 shopping cart selection → Projects API），並確保 RBAC 角色在 UI 層曝光。
3. **UR‑008**：完善「搜尋結果匯出」與「專案匯出」的後端任務模型（含 async 任務、進度、通知、檔案保存）與前端 UX（含進度提示、錯誤回饋、下載記錄）。

### Out of scope

- AI 分析（UR‑005/006）、資料匯入（UR‑002）與 JWT 問題等其他 backlog。
- 任一新 UI 功能的實作細節；本 proposal 只定義需求與協作方式。

## Current gaps (per UR)

| UR | 目前狀態 | 缺口 |
|----|----------|------|
| UR‑003 搜尋 | 前端完成、支援 mock（`frontend/docs/STUDY_SEARCH_COMPLETION_REPORT.md`），後端 checklist 已列 4 端點 (`backend_django/docs/010_BACKEND_INTEGRATION_CHECKLIST.md`) | 尚未建立 **統一契約 + 型別**，也缺少端到端測試與性能驗證 |
| UR‑004 詳情 | User Requirements 要求顯示 AI 標記/專案資訊；後端 reports/annotations API 幾乎完成 (`backend_django/docs/implementation/...` §2.3) | 前端尚未強制以實際 API 取代假資料，AI 標記與專案摘要無一致格式 |
| UR‑007 專案管理 | ListView Provider + hooks 完成 (`frontend/docs/features/project-list-view-guide.md`)；後端 CRUD/RBAC/批次 API 已備 (`backend_django/docs/implementation/...` §2.4) | 缺少「角色/權限」映射、批次指派與 selection cart 流程說明，亦無整合測試 |
| UR‑008 匯出 | 前端仍規劃中（`frontend/README.md` Phase 4；`study-table-management-guide.md` FAQ 說明僅能匯出整個搜尋）；後端 ExportTask 90% (同步, 無 progress) | 尚未定義 **非同步/進度/通知** 的最終行為，也未規範「僅匯出選取資料」與權限限制 |

## Proposed changes

1. **契約統一**：產生一份供前後端共用的 DTO + OpenAPI 片段，描述 `/studies/search`、`/studies/{id}`、`/reports/{id}`、`/projects/*`、`/export/*` 的欄位、錯誤碼與分頁行為。
2. **Mock 切換計畫**：在前端服務層新增「環境開關 + fallback 移除指南」，確保 Study Search、Report Detail、Projects、Export 全部預設呼叫真實 API，mock 僅做測試。
3. **RBAC 與 selection 整合**：定義使用者角色（owner/admin/editor/viewer）如何反映在前端 store 與批次操作（加入專案、匯出、封存）。
4. **匯出任務生命週期**：規範 ExportTask 以非同步方式執行、允許最多 10k 筆、提供進度輪詢/通知，並描述前端如何顯示狀態、歷史與下載按鈕。

## Success criteria

- 新增的 OpenSpec delta 覆蓋 UR‑003/004/007/008，描述上述契約與流程。
- `tasks.md` 內的行動項目（契約審核、前端整合、後端 async export、整合測試）可以直接啟動實作。
- 需求通過 `openspec validate deliver-phase1-core-workflows --strict`。
- 後續實作完成後，Study Search/Report Detail/Project Management/Export 頁面可以完全移除 mock，並具備可追蹤的匯出進度。

## Risks / Open questions

- JWT 驗證尚未修復（`backend_django/docs/implementation/...` CRITICAL issue）；若阻礙 API 測試，需在 apply 階段納入依賴。
- 匯出任務若走同步流程，可能造成 request timeout；需評估 Celery/自製 async 任務與部署成本。
- 前端目前 selection cart 僅維持在搜尋結果；若要支援「僅匯出選取」需調整資料結構與 UX。
- 需要確認既有 Project API 角色模型是否與 UX 權限一致，避免雙方語意不同步。

