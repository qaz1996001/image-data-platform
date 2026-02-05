# image_data_platform 文檔 ID 索引（Document ID Index）

> 本文件集中列出 `docs/image_data_platform/**` 下所有已定義 **文件 ID** 的文檔，  
> 由專用腳本自動產生與維護，協助審核追溯與一致性檢查。

---

## 1. 使用說明

- 本檔案 **SHALL** 由腳本自動更新，人工編輯僅限補充說明文字：
  - 列表內容（表格列）**MUST NOT** 人工修改，避免與實際文檔脫節。
  - 若需新增文件 ID，請在目標文檔中加入 `**文件 ID**:` 欄位，然後重新執行腳本。
- 腳本路徑與用法：
  - 腳本位置：`scripts/generate_doc_ids_index.py`
  - 執行方式（專案根目錄）：
    - `python scripts/generate_doc_ids_index.py`

---

## 2. 文檔 ID 一覽（自動生成區段）

> 下列表格由腳本掃描 `docs/image_data_platform/**` 中帶有 `**文件 ID**:` 欄位的 Markdown 檔案自動生成。  
> 不要直接修改此表格內容；請修改各自的原始文檔，然後重新執行腳本。

| 文檔 ID | 標題 | 檔案路徑 |
|--------|------|----------|
| DOC-IMAGE-DATA-PLATFORM-001 | image_data_platform 專案文件管理系統 | docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md |
| DOC-IMAGE-DATA-PLATFORM-REQ-001 | image_data_platform 專案需求文檔系統索引 | docs/image_data_platform/requirements/00_REQUIREMENTS_INDEX.md |
| DOC-IMAGE-DATA-PLATFORM-ARC-001 | image_data_platform 專案架構與設計文檔索引 | docs/image_data_platform/architecture/00_ARCHITECTURE_INDEX.md |
| DOC-IMAGE-DATA-PLATFORM-TEST-001 | image_data_platform 專案測試與驗證文檔索引 | docs/image_data_platform/testing/00_TESTING_INDEX.md |
| DOC-IMAGE-DATA-PLATFORM-TRC-001 | image_data_platform 專案追溯性文檔索引 | docs/image_data_platform/traceability/00_TRACEABILITY_INDEX.md |
| DOC-IMAGE-DATA-PLATFORM-GUI-001 | image_data_platform 專案開發指南與最佳實踐索引 | docs/image_data_platform/guides/00_GUIDES_INDEX.md |
| DOC-IMAGE-DATA-PLATFORM-OSI-001 | image_data_platform 專案 OpenSpec 整合管理索引 | docs/image_data_platform/openspec-integration/00_OPENSPEC_INTEGRATION_INDEX.md |
| IDP-REQ-SYS-PRD-SR-SD-IMG-001 | image_data_platform — 系統層 PRD / SR / SD（整合舊文檔） | docs/image_data_platform/requirements/01_SYSTEM_PRD_SR_SD.md |
| IDP-ARCH-SYS-IMG-001 | image_data_platform — 系統架構設計（整合舊文檔） | docs/image_data_platform/architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md |
| IDP-TEST-STRATEGY-IMG-001 | image_data_platform — 測試策略與報告（整合舊文檔） | docs/image_data_platform/testing/01_TESTING_STRATEGY_AND_REPORT.md |
| IDP-TRACE-IMG-001 | image_data_platform — 追溯性矩陣（整合舊文檔） | docs/image_data_platform/traceability/01_TRACEABILITY_MATRIX.md |
| IDP-GUIDE-IMG-OVERVIEW-001 | image_data_platform 專案概覽與開發工作流指南 | docs/image_data_platform/guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md |
| IDP-OPENSPEC-INTEG-IMG-001 | image_data_platform — OpenSpec 整合指南（整合舊文檔） | docs/image_data_platform/openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md |
| IDP-ARCH-001 | image_data_platform — 系統架構設計文件（Architecture System Design Template） | docs/image_data_platform/templates/TEMPLATE_ARCHITECTURE_SYSTEM_DESIGN.md |
| IDP-GUIDE-001 | image_data_platform 指南文件（Guide Document Template） | docs/image_data_platform/templates/TEMPLATE_GUIDE_DOCUMENT.md |
| IDP-TRACE-001 | image_data_platform 追溯性矩陣（Traceability Matrix Template） | docs/image_data_platform/templates/TEMPLATE_TRACEABILITY_MATRIX.md |
| IDP-OPENSPEC-INTEG-001 | image_data_platform OpenSpec 整合指南（Template） | docs/image_data_platform/templates/TEMPLATE_OPENSPEC_INTEGRATION_GUIDE.md |


