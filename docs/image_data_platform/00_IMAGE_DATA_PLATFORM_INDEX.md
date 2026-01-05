# image_data_platform 文件管理系統

**文件 ID**: DOC-IMAGE-DATA-PLATFORM-001
**標題**: image_data_platform 專案文件管理系統
**版本**: v1.6.0
**狀態**: ✅ Active
**建立日期**: 2025-12-24
**最後更新**: 2026-01-05

---

## 1. 目的與範圍

本文件管理系統為 image_data_platform 專案提供符合醫療器材軟體開發標準的文檔結構與管理流程。所有專案參與者與 AI 代理 **MUST** 遵循本系統定義的規範。

## 2. 文檔結構

```
docs/image_data_platform/
├── 00_IMAGE_DATA_PLATFORM_INDEX.md   # ⭐ 專案文檔系統索引 (本文件)
├── README.md                         # 🚀 快速開始指南
├── templates/                        # 🧩 文件模板（00_TEMPLATES_INDEX.md）
├── requirements/                     # 📋 需求文檔 (00_REQUIREMENTS_INDEX.md, 01_SYSTEM_PRD_SR_SD.md, 02_FRONTEND_PRD_SR_SD.md, 03_BACKEND_PRD_SR_SD.md)
├── architecture/                     # 🏗️ 架構與設計 (00_ARCHITECTURE_INDEX.md, 01_SYSTEM_ARCHITECTURE_DESIGN.md)
├── regulations/                      # ⚖️ 規範與合規性 (00_REGULATIONS_INDEX.md)
├── traceability/                     # 🔗 追溯性管理 (00_TRACEABILITY_INDEX.md, 01_TRACEABILITY_MATRIX.md)
├── testing/                          # ✅ 測試與驗證 (00_TESTING_INDEX.md, 01_TESTING_STRATEGY_AND_REPORT.md)
├── openspec-integration/             # 🔄 OpenSpec 整合 (00_OPENSPEC_INTEGRATION_INDEX.md, 01_OPENSPEC_INTEGRATION_GUIDE.md)
└── guides/                           # 📚 專案指南 (00_GUIDES_INDEX.md, 01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md)
```

## 3. 適用標準

本文件管理系統 **MUST** 支援並遵循以下標準：

- **RFC 2119**: 需求關鍵字規範 (基礎規範)
- **ISO 13485**: 醫療器材品質管理系統
- **IEC 62304**: 醫療器材軟體生命週期
- **ISO 14971**: 醫療器材風險管理
- **IEC 62366**: 醫療器材可用性工程
- **ISO 27001**: 資訊安全管理系統
- **ISO/IEC 23894**: AI 風險管理

## 4. 文檔管理原則

### 4.1 版本控制

- 所有文檔 **MUST** 使用 Git 進行版本控制。
- 重大變更 **MUST** 使用 OpenSpec 變更管理流程。
- 文檔版本號 **SHALL** 遵循語意化版本規範。

### 4.2 文檔追溯性

- 需求文檔 **MUST** 追溯至利害關係人需求。
- 架構與設計文檔 **MUST** 追溯至需求文檔。
- 測試文檔 **MUST** 追溯至需求與架構文檔。
- 規範與合規性文檔 **MUST** 追溯至相關標準要求。

### 4.3 文檔審核

- 所有文檔 **MUST** 經過審核與批准。
- 審核記錄 **SHALL** 保存在 OpenSpec 變更記錄中。

## 5. 與 OpenSpec 整合

本文件管理系統與 OpenSpec 變更管理系統深度整合：

- **變更提案**: **MUST** 使用 OpenSpec 創建變更提案。
- **變更實作**: **SHALL** 依據 tasks.md 完成開發與文檔更新。
- **變更歸檔**: 歸檔變更時 **MUST** 同步更新相關文檔。

## 6. 快速開始

1. 在建立任何新文件前，先閱讀 [`templates/00_TEMPLATES_INDEX.md`](templates/00_TEMPLATES_INDEX.md)，選擇對應模板並複製使用。
2. 閱讀 [`guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md`](guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md) 了解專案背景、Phase 1 目標與開發工作流。
3. 閱讀 [`requirements/01_SYSTEM_PRD_SR_SD.md`](requirements/01_SYSTEM_PRD_SR_SD.md) 了解系統層 PRD / SR / SD。
4. 閱讀 [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) 了解系統與資料庫 / API 架構。
5. 閱讀 [`testing/01_TESTING_STRATEGY_AND_REPORT.md`](testing/01_TESTING_STRATEGY_AND_REPORT.md) 與 [`traceability/01_TRACEABILITY_MATRIX.md`](traceability/01_TRACEABILITY_MATRIX.md)，確認測試與追溯策略。
6. 若進行 OpenSpec 變更，搭配 [`openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md`](openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md) 使用。

## 7. 舊文檔對應（docs/old → docs/image_data_platform）

### 7.1 Canonical 文檔樹定義（Documentation Governance）

**image_data_platform 專案的 canonical 文檔樹 SHALL be `docs/image_data_platform/**`**。

此規範基於以下原則:
- **單一權威來源 (Single Source of Truth)**: 避免文檔重複與不一致
- **標準化管理**: 符合 IEC 62304 醫療器材軟體生命週期標準
- **追溯性要求**: 確保所有文檔可追溯至需求與變更
- **版本控制**: 所有文檔變更必須通過 OpenSpec 變更管理流程

### 7.2 舊文檔狀態

`docs/old/**` 中的文檔已於 **2025-12-26** 標記為 **DEPRECATED**,並移動部分已完全整合的文件至 `docs/old/archive/`。

舊文檔僅保留作為**歷史參考**,不再更新。所有開發者、AI 代理與專案參與者 **MUST**:
- ✅ 優先使用 `docs/image_data_platform/**` 中的文檔
- ✅ 所有文檔更新在 `docs/image_data_platform/**` 中進行
- ❌ 不要更新或引用 `docs/old/**` 作為當前文檔
- ❌ 不要在 `docs/old/**` 中創建新文件

詳細處理流程請參考: [`openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md`](openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md) 第 3.3 節。

### 7.3 舊文檔內容對應表

為避免文件重複與混淆,舊文檔中仍有效的內容已整合到下列新文件:

| 舊文檔路徑 | 新文檔路徑 | 遷移狀態 |
|-----------|-----------|---------|
| `docs/old/00_DOCUMENTATION_INDEX.md` | [`00_IMAGE_DATA_PLATFORM_INDEX.md`](00_IMAGE_DATA_PLATFORM_INDEX.md) | ✅ 已整合並標記 Deprecated |
| `docs/old/01_PROJECT_OVERVIEW.md` | [`guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md`](guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md) | ✅ 已整合並標記 Deprecated |
| `docs/old/DOCUMENTATION_INDEX.md` | [`00_IMAGE_DATA_PLATFORM_INDEX.md`](00_IMAGE_DATA_PLATFORM_INDEX.md) | ✅ 已整合並標記 Deprecated |
| `docs/old/requirements/**` | [`requirements/01_SYSTEM_PRD_SR_SD.md`](requirements/01_SYSTEM_PRD_SR_SD.md) | ✅ 已整合 |
| `docs/old/architecture/**` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) | ✅ 已整合 (788 行) |
| `docs/old/database/**` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) (第 4 章) | ✅ 已整合 |
| `docs/old/api/**` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) (第 5 章) | ✅ 已整合 |
| `docs/old/workflow/**` | [`guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md`](guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md) | ✅ 已整合 |
| `docs/old/DOCUMENTATION_COMPLETE.md` | [`testing/01_TESTING_STRATEGY_AND_REPORT.md`](testing/01_TESTING_STRATEGY_AND_REPORT.md) | ✅ 已整合並移至 archive |
| `docs/old/STUDY_SEARCH_COMPLETION_REPORT.md` | [`testing/01_TESTING_STRATEGY_AND_REPORT.md`](testing/01_TESTING_STRATEGY_AND_REPORT.md) | ✅ 已整合並移至 archive |
| `docs/old/BACKEND_INTEGRATION_CHECKLIST.md` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) | ✅ 已整合並移至 archive |
| `docs/old/ARCHIVE_INDEX.md` | [`00_IMAGE_DATA_PLATFORM_INDEX.md`](00_IMAGE_DATA_PLATFORM_INDEX.md) | ✅ 已整合並標記 Deprecated |

### 7.4 查閱舊文檔導引

如需查閱舊文檔作為歷史參考,請先閱讀:
- [`docs/old/README_DEPRECATED.md`](../old/README_DEPRECATED.md) - 舊文檔目錄說明與對應表
- [`OLD_DOCS_MAPPING_CHECKLIST.md`](OLD_DOCS_MAPPING_CHECKLIST.md) - 詳細對應檢查清單（逐項驗證所有文件的對應狀態）

相關 OpenSpec 變更:
- **變更 ID**: `migrate-legacy-docs-to-image-data-platform`
- **提案**: [`openspec/changes/migrate-legacy-docs-to-image-data-platform/proposal.md`](../../openspec/changes/migrate-legacy-docs-to-image-data-platform/proposal.md)
- **任務**: [`openspec/changes/migrate-legacy-docs-to-image-data-platform/tasks.md`](../../openspec/changes/migrate-legacy-docs-to-image-data-platform/tasks.md)
- **檢查清單變更 ID**: `verify-old-docs-mapping`
- **檢查清單提案**: [`openspec/changes/verify-old-docs-mapping/proposal.md`](../../openspec/changes/verify-old-docs-mapping/proposal.md)

`docs/old/**` 已於 2025-12-26 完成標記與部分歸檔,未來將僅保留作為歷史記錄。

## 8. 文件格式、編碼與索引規則（Format, Encoding & Index Rules）

- **檔案格式與編碼**
  - `docs/image_data_platform/**` 下所有文檔 **MUST** 使用 **Markdown (`.md`)** 作為檔案格式。
  - 所有文檔 **MUST** 使用 **UTF-8** 文字編碼（支援繁體中文與英文混合內容）。  
  - 若需進行多語系或編碼相關操作，**SHOULD** 參考舊結構中的 I18N 指南：`docs/old/guides/I18N_GUIDE.md`，其中包含：
    - 檔案編碼檢查方式（例如 `file -i`）。
    - 將檔案轉換為 UTF-8 的建議流程（例如使用 `iconv`）。

- **索引文件命名與欄位規則**
  - 每一個子目錄（如 `requirements/`、`architecture/`、`testing/` 等）**MUST** 擁有一個 `00_*.md` 索引檔，例如：
    - `requirements/00_REQUIREMENTS_INDEX.md`
    - `architecture/00_ARCHITECTURE_INDEX.md`
    - `testing/00_TESTING_INDEX.md`
    - `traceability/00_TRACEABILITY_INDEX.md`
    - `guides/00_GUIDES_INDEX.md`
    - `openspec-integration/00_OPENSPEC_INTEGRATION_INDEX.md`
  - 每一個索引檔 **MUST** 至少包含一個「文檔清單」表格，欄位結構如下：
    - `文檔 ID`：唯一識別碼（例如 `IDP-REQ-SYS-PRD-SR-SD-IMG-001`）。
    - `標題`：檔名與簡短說明（建議附上實際檔名，例如 `01_SYSTEM_PRD_SR_SD.md — 系統層 PRD / SR / SD`）。
    - `版本`：語意化版本（例如 `v1.0.0-Phase1`）。
    - `狀態`：Draft / Active / Deprecated / Archived 等。
    - `備註`：可說明是否為「舊文檔整合中」、「僅歷史參考」等。
  - 新增任何受控文檔時，**SHALL** 同步更新對應子目錄的 `00_*_INDEX.md`，確保索引與實際檔案一致。
  - 所有已定義 **文件 ID** 的文檔 **SHALL** 由 `DOC_IDS_INDEX.md` 彙總管理，並透過 `scripts/generate_doc_ids_index.py` 腳本定期同步。

## 9. 目錄導覽（Clickable Directory）

以下為 `docs/image_data_platform/` 主要索引與關鍵文件的快速導覽，點選即可跳至對應檔案：

- **總索引與快速開始**
  - [`00_IMAGE_DATA_PLATFORM_INDEX.md`](00_IMAGE_DATA_PLATFORM_INDEX.md) — 本文件
  - [`README.md`](README.md) — 專案文檔 Quick Start

- **模板與共用規則**
  - [`templates/00_TEMPLATES_INDEX.md`](templates/00_TEMPLATES_INDEX.md)

- **需求與架構**
  - 需求索引：[`requirements/00_REQUIREMENTS_INDEX.md`](requirements/00_REQUIREMENTS_INDEX.md)
  - 系統層 PRD/SR/SD：[`requirements/01_SYSTEM_PRD_SR_SD.md`](requirements/01_SYSTEM_PRD_SR_SD.md)
  - 架構索引：[`architecture/00_ARCHITECTURE_INDEX.md`](architecture/00_ARCHITECTURE_INDEX.md)
  - 系統架構設計：[`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md)

- **測試與追溯**
  - 測試索引：[`testing/00_TESTING_INDEX.md`](testing/00_TESTING_INDEX.md)
  - 測試策略與報告：[`testing/01_TESTING_STRATEGY_AND_REPORT.md`](testing/01_TESTING_STRATEGY_AND_REPORT.md)
  - 追溯索引：[`traceability/00_TRACEABILITY_INDEX.md`](traceability/00_TRACEABILITY_INDEX.md)
  - 追溯性矩陣：[`traceability/01_TRACEABILITY_MATRIX.md`](traceability/01_TRACEABILITY_MATRIX.md)

- **規範與 OpenSpec 整合**
  - 規範索引：[`regulations/00_REGULATIONS_INDEX.md`](regulations/00_REGULATIONS_INDEX.md)
  - OpenSpec 整合索引：[`openspec-integration/00_OPENSPEC_INTEGRATION_INDEX.md`](openspec-integration/00_OPENSPEC_INTEGRATION_INDEX.md)
  - OpenSpec 整合指南：[`openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md`](openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md)

- **指南與最佳實務**
  - 指南索引：[`guides/00_GUIDES_INDEX.md`](guides/00_GUIDES_INDEX.md)
  - 專案概覽與開發工作流：[`guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md`](guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md)
---

**文檔版本**: v1.6.0
**最後更新**: 2026-01-05

