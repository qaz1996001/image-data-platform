## Context

image_data_platform 目前存在兩套並行的文件樹：

- 舊結構：`docs/old/**`（含 `00_DOCUMENTATION_INDEX.md`、`01_PROJECT_OVERVIEW.md`、架構 / DB / API / workflow / requirements 等）
- 新結構：`docs/image_data_platform/**`（索引 + templates + requirements / architecture / regulations / traceability / testing / guides / openspec-integration）

為了符合 `documentation-governance` 能力中「單一真實來源」的精神，需要明確定義哪一棵文件樹是 canonical，並為舊內容提供可追溯的遷移與廢止策略。

## Goals / Non-Goals

- Goals
  - 將舊文件中仍有效的內容系統化遷移到 `docs/image_data_platform/**`。
  - 明確規定 `docs/image_data_platform/**` 為 image_data_platform 專案的唯一權威文件樹。
  - 在 OpenSpec 中新增治理規範，讓 AI 代理與開發者有清楚的操作流程。
- Non-Goals
  - 不重新設計 meta-framework 的全域文檔結構。
  - 不在此變更中改動後端 / 前端程式碼。

## Decisions

- Decision: Canonical Docs Tree
  - 對於 image_data_platform 專案，**canonical docs tree SHALL be `docs/image_data_platform/**`**。
  - `docs/old/**` 僅保留為歷史記錄或封存用途，之後不再作為現行文件依據。

- Decision: Migration Style
  - 內容遷移採「整理後重寫」優先，而非機械一對一複製。
  - 所有新文件 SHALL 從 `docs/image_data_platform/templates/` 中對應的模板複製產生，確保欄位與結構一致。

## Risks / Trade-offs

- Risk: 遷移過程中可能出現重複或矛盾敘述。
  - Mitigation: 在遷移前先建立完整 mapping 清單，並由文件負責人審核整併版本。
- Risk: 費時，短期內舊新結構可能同時存在。
  - Mitigation: 在 `documentation-governance` 中加入明確情境，規定優先使用新結構，並要求在一定階段後完成舊檔標記與封存。

## Migration Plan

1. 盤點 `docs/old/**` 文件與狀態。
2. 規劃每個類型的對應新位置與模板。
3. 建立 / 補齊新文件並遷移或重寫內容。
4. 在舊文件中加入 Deprecated 標記與新位置連結，必要時移入 `docs/old/archive/`。
5. 更新 governance spec 與指南，要求後續只在新結構下新增 / 修改文檔。

## Legacy Docs Inventory & Mapping（Tasks 1–2）

### 1.1 `docs/old/` 頂層清單與狀態

| 路徑 / 頂層項目                      | 類型         | 狀態 (Active / Obsolete / To-merge) | 說明 |
|--------------------------------------|--------------|-------------------------------------|------|
| `docs/old/00_DOCUMENTATION_INDEX.md` | 單一索引文件 | To-merge                            | 舊版總索引，導覽資訊將在 Phase 3 整合進 `docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` 與子索引。 |
| `docs/old/01_PROJECT_OVERVIEW.md`    | 專案概述     | To-merge                            | 高階專案背景與功能說明，將遷移到新結構的專案概覽 / 指南文件。 |
| `docs/old/api/`                      | 目錄         | To-merge                            | API 規格與說明，將對應到新架構或指南文件（API 規格章節）。 |
| `docs/old/architecture/`             | 目錄         | To-merge                            | 技術架構設計，將整併進新的系統架構設計文件。 |
| `docs/old/archive/`                  | 目錄         | Active (Archive)                    | 歷史文件封存區，保留為歷史參考，不遷移內容。 |
| `docs/old/ARCHIVE_INDEX.md`          | 索引         | Obsolete                            | 僅用於描述 `docs/old/archive/`，視為歷史索引，不遷移。 |
| `docs/old/BACKEND_INTEGRATION_CHECKLIST.md` | 檢查清單 | To-merge                            | 後端整合檢查項目，將併入新 guides / testing 文件。 |
| `docs/old/database/`                 | 目錄         | To-merge                            | 資料庫設計，將整併到新的架構設計文件（資料模型章節）。 |
| `docs/old/DOCUMENTATION_COMPLETE.md` | 文件匯總     | To-merge                            | 文檔完成度總結，重要摘要將整合到新索引或指南中。 |
| `docs/old/DOCUMENTATION_INDEX.md`    | 索引         | To-merge                            | 舊索引變體，與 `00_DOCUMENTATION_INDEX.md` 重疊，遷移時會一併整理。 |
| `docs/old/guides/`                   | 目錄         | To-merge                            | 各種開發 / 部署指南，將對應到 `docs/image_data_platform/guides/`。 |
| `docs/old/image_data_platform/`      | 目錄         | To-merge                            | 舊版專案專屬文檔，內容將遷移或重寫到新樹對應位置。 |
| `docs/old/implementation/`           | 目錄         | To-merge                            | 實作相關說明，將依內容分流到架構 / guides / testing。 |
| `docs/old/migration/`                | 目錄         | To-merge                            | 舊遷移說明，未來可合併到 OpenSpec 整合指南或專案遷移指南。 |
| `docs/old/planning/`                 | 目錄         | To-merge                            | 專案規劃與排程，可併入專案概覽 / workflow guide。 |
| `docs/old/requirements/`             | 目錄         | To-merge                            | 舊需求 / 功能規格，將整併到新 `requirements/01_SYSTEM_PRD_SR_SD.md` 等文件。 |
| `docs/old/setup/`                    | 目錄         | To-merge                            | 環境與安裝說明，將對應到新的 setup / operations 類指南。 |
| `docs/old/STUDY_SEARCH_COMPLETION_REPORT.md` | 報告 | To-merge                            | 功能完成報告，可作為案例附錄整合到 guides 或 testing 報告中。 |
| `docs/old/workflow/`                 | 目錄         | To-merge                            | 開發工作流與流程說明，將整併進新的 workflow / collaboration 類指南。 |

### 1.2 舊文件類型 → 新結構與模板對應

| 舊類型 / 目錄          | 代表性檔案                          | 新位置 (`docs/image_data_platform/**`)                  | 對應模板 (`templates/`)                          |
|------------------------|-------------------------------------|---------------------------------------------------------|--------------------------------------------------|
| 專案概覽 / 開發流程    | `01_PROJECT_OVERVIEW.md`, `workflow/` | `guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md`     | `TEMPLATE_GUIDE_DOCUMENT.md`                     |
| 系統層需求 / 規格      | `requirements/USER_REQUIREMENTS.md`, `FUNCTIONAL_SPECIFICATION.md` | `requirements/01_SYSTEM_PRD_SR_SD.md`                 | `TEMPLATE_REQUIREMENTS_SYSTEM_PRD_SR_SD.md`      |
| 技術架構 / DB / API    | `architecture/`, `database/`, `api/` | `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`        | `TEMPLATE_ARCHITECTURE_SYSTEM_DESIGN.md`         |
| 測試與驗證 / 完成報告  | `STUDY_SEARCH_COMPLETION_REPORT.md`, workflow 中的測試章節 | `testing/01_TESTING_STRATEGY_AND_REPORT.md`           | `TEMPLATE_TESTING_STRATEGY_AND_REPORT.md`        |
| 追溯性 / 匯總          | `DOCUMENTATION_COMPLETE.md` 等       | `traceability/01_TRACEABILITY_MATRIX.md`               | `TEMPLATE_TRACEABILITY_MATRIX.md`                |
| 一般指南 / 開發指南    | `guides/**`, `BACKEND_INTEGRATION_CHECKLIST.md`, `setup/**`, `migration/**`, `implementation/**` | `guides/**`（多個具體指南文件）                     | `TEMPLATE_GUIDE_DOCUMENT.md`                     |
| OpenSpec 與文檔整合    | 舊遷移 / 規劃說明                    | `openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md` | `TEMPLATE_OPENSPEC_INTEGRATION_GUIDE.md`         |

### 1.3 可直接棄用（Obsolete）內容

- 目前分析結果：**尚無** 明確判定為「完全可棄用且不需任何資訊遷移」的內容。  
- 像 `ARCHIVE_INDEX.md` 這類文件雖標記為 Obsolete，但其角色主要為歷史 `archive/` 目錄索引，本身不作為現行規格或需求依據；  
  未來若確認其資訊完全可由新結構與 Git 歷史取代，將在 Phase 4（Deprecation & Archival 任務）中正式標記為廢止。

> 結論：在 Tasks 1.x 階段，預設所有與 image_data_platform 現行行為相關的舊文件皆視為 **To-merge**，  
> 真正完全無需遷移的內容將在後續遷移與審核過程中再標記為 Obsolete，以避免過早丟失潛在重要資訊。

## Open Questions

- 是否需要對部分舊文件保留完整「只讀」副本，或僅保留 Git 歷史即可？
- 舊索引（例如 `DOCUMENTATION_COMPLETE.md`、`DOCUMENTATION_INDEX.md`）中哪些統計資訊需要在新結構中重現？哪些可以由工具或追溯矩陣補足？


