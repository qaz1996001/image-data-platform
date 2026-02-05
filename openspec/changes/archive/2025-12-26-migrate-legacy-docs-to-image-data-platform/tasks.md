## 1. 分析與對應設計（Analysis & Mapping）
- [x] 1.1 盤點 `docs/old/` 下所有頂層文件與子目錄（architecture / database / api / requirements / workflow / guides 等），建立清單與狀態（Active / Obsolete / To-merge）。
- [x] 1.2 為每一類舊文件決定對應的新位置與類型（對應 `docs/image_data_platform/requirements/`、`architecture/`、`testing/`、`traceability/`、`guides/` 等）。
- [x] 1.3 確認哪些舊內容可直接棄用（例如已被新規格完全取代），標記為「廢止，不遷移」。

## 2. 新結構文件規劃與建立（New Docs Planning & Creation）
- [x] 2.1 依照 `docs/image_data_platform/templates/00_TEMPLATES_INDEX.md`，為需要承接舊內容的類型建立或補齊新文件（從 `TEMPLATE_*.md` 複製）。
- [x] 2.2 確保所有新建文件具備文件 ID、版本、變更歷史與追溯欄位，符合 RFC 2119 關鍵字使用規範。

## 3. 內容遷移與合併（Content Migration & Consolidation）
- [x] 3.1 將 `docs/old/00_DOCUMENTATION_INDEX.md` / `DOCUMENTATION_INDEX.md` 中仍有效的導覽結構，整合進 `docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` 與各子索引中。
- [x] 3.2 將 `docs/old/01_PROJECT_OVERVIEW.md` 與相關高階說明，遷移或重寫進新結構中的對應文件（例如 requirements / guides）。
- [x] 3.3 將舊的架構 / 資料庫 / API / workflow / guides 文件內容，根據 1.2 的對應設計分批遷移，避免一對一機械複製，優先以「整理後的新版」為目標。
- [x] 3.4 **需求文件遷移完成確認**：
  - [x] 使用者需求（UR-001~UR-009）→ `requirements/01_SYSTEM_PRD_SR_SD.md` 第 3 章 ✅
  - [x] 系統設計（SYS-SD）→ `requirements/01_SYSTEM_PRD_SR_SD.md` 第 5 章（概要）+ `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`（詳細，788 行）✅
  - [x] 非功能性需求（NFR-001~NFR-009）→ `requirements/01_SYSTEM_PRD_SR_SD.md` 第 7 章 ✅
  - [x] 架構設計（前後端整合、資料流、模組劃分）→ `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` 第 1-3 章 ✅
  - [x] 資料庫設計（5 張核心表 + ER 圖 + 索引策略）→ `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` 第 4 章 ✅
  - [x] API 規範（6 大模組 + 請求/響應格式 + 錯誤處理）→ `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` 第 5 章 ✅
  - [x] 非功能設計考量（效能、安全、可維護性實作）→ `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` 第 6 章 ✅
  - [x] 風險與技術債識別 → `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` 第 7 章 ✅

## 4. 舊文件廢止與封存（Deprecation & Archival）
- [ ] 4.1 在 `docs/old/**` 相關主文件中明確標示「Deprecated / 已遷移」，並指向新結構的對應文件。
- [ ] 4.2 視需要將部分舊文件移動至 `docs/old/archive/` 或標記為歷史記錄，避免與現行文件混用。

## 5. 治理規範與流程更新（Governance & Workflow Updates）
- [ ] 5.1 依據本變更的 spec delta，更新 `documentation-governance` 能力，明確規定 image_data_platform 專案的 canonical docs tree 為 `docs/image_data_platform/**`。
- [ ] 5.2 在適當的指南 / OpenSpec 整合文件中，補充「發現舊文件時應如何處理」的 AI 代理與開發者操作流程。

## 6. 驗證與審核（Validation & Review）
- [ ] 6.1 確認所有舊文件清單都有對應處理結果（遷移 / 廢止 / 封存），避免遺漏。
- [ ] 6.2 由文件負責人 / 品質負責人審核新結構與內容，確保符合 `documentation-governance` 及相關標準。
- [ ] 6.3 執行 `openspec validate migrate-legacy-docs-to-image-data-platform --strict`，確保本變更 proposal 與 spec deltas 通過檢查。


