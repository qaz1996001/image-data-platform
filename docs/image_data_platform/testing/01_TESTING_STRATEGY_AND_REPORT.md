# image_data_platform 測試策略與報告（Testing Strategy & Report）

> 本文件為 image_data_platform 專案在新文檔結構下的**測試策略與測試報告主文件**，  
> 後續將整合 `docs/old/workflow/` 中的測試章節與 `STUDY_SEARCH_COMPLETION_REPORT.md` 等內容。
>
> 範本結構來源：`templates/TEMPLATE_TESTING_STRATEGY_AND_REPORT.md`。

---

**文件 ID**: IDP-TEST-STRATEGY-IMG-001
**標題**: image_data_platform — 測試策略與報告（整合舊文檔）
**版本**: v1.1.0-Phase1
**狀態**: Active
**建立日期**: 2025-12-26
**最後更新**: 2026-01-05
**作者**: AI 代理
**審核人**: [測試負責人 / 品質負責人]  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v1.1.0 | 2026-01-05 | AI 代理 | 新增 §2.3 品質檢查工具；新增 §3.4 Imports 模組測試；更新測試環境為 Django 4.2 |
| v1.0.0 | 2025-12-26 | AI 代理 | 從模板建立，整合 docs/old 測試與完成報告內容 |

---

## 1. 測試範圍與目標（Scope & Objectives）

### 1.1 測試範圍

本文件涵蓋 Phase 1 之測試與驗證活動，聚焦於：

- 報告資料導入與搜尋流程是否符合需求與效能目標。
- AI 分析（單筆 / 批次）是否穩定、結果格式正確且可被前端正確顯示。
- 專案管理與匯出功能是否正確反映資料庫狀態。

### 1.2 測試目標

- 確認關鍵功能路徑（導入 → 搜尋 → AI 分析 → 專案管理 → 匯出）在正常與典型邊界條件下均可正確運作。
- 確認非功能性需求（如搜尋效能、AI 分析時間、基本穩定性）達到舊工作流中定義的 Phase 1 指標。

---

## 2. 測試對象與環境（Test Items & Environment）

### 2.1 測試對象

- Backend API（認證、導入、搜尋、AI 分析、專案管理、匯出）。
- Frontend UI（登入、報告列表與搜尋頁、AI 分析對話框、專案管理頁）。
- 資料庫結構與索引（5 張核心表與相關視圖）。

### 2.2 測試環境

- PostgreSQL 14+（與正式環境相同版本）。
- Django 4.2 + Django Ninja（RESTful API）。
- Ollama（本地部署，至少載入 qwen2.5:7b 模型）。
- 前端建置後以 Docker Compose 啟動的整合環境。

### 2.3 品質檢查工具（Quality Gates）

> 詳見 `guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md` §7.2

任何程式碼變更在提交 Review 前，**必須**通過以下品質檢查：

**Backend (Python) - 在 `backend_django/` 執行**

| 工具 | 指令 | 用途 |
|------|------|------|
| ty | `uvx ty check <module>` | 型別檢查 |
| ruff | `uvx ruff check <module> --fix` | Linting + 自動修復 |
| ruff | `uvx ruff format <module>` | 程式碼格式化 |

**Frontend (TypeScript/React) - 在 `frontend/` 執行**

| 工具 | 指令 | 用途 |
|------|------|------|
| ESLint | `pnpm lint` | JavaScript/TypeScript 檢查 |
| TypeScript | `npx tsc --noEmit` | 型別檢查 |

**測試模組對照**：

| 模組 | 說明 | 測試檔案 |
|------|------|----------|
| `common` | 共用工具、中介層 | `tests/test_common.py` |
| `imports` | 資料匯入功能 | `tests/test_imports.py` |
| `project` | 專案管理 | `project/tests/` |
| `report` | 報告搜尋與管理 | `report/tests/` |
| `study` | 檢查/影像操作 | `study/tests/` |

## 3. 測試類型與策略（Test Types & Strategy）

---

## 4. 測試計畫與案例設計（Test Plan & Test Cases）

---

## 5. 追溯性（Traceability）

（對應 `requirements/01_SYSTEM_PRD_SR_SD.md` 與 `traceability/01_TRACEABILITY_MATRIX.md`）

---

## 6. 測試執行結果（Test Execution Results）

（可整合 `STUDY_SEARCH_COMPLETION_REPORT.md` 等報告內容）

---

## 7. 結論與建議（Conclusion & Recommendations）

---

## 8. 附錄（Appendix）


