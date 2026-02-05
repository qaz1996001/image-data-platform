# image_data_platform 文件模板索引（Templates Index）

> 本目錄提供 image_data_platform 專案各類文件的標準模板與欄位規範。  
> 所有新文件 **MUST** 優先從對應模板複製後再填寫內容，避免結構與欄位遺漏。

---

## 1. 目的

- **一致性**：確保 requirements / architecture / regulations / testing / traceability / guides / openspec-integration 等文件結構一致。
- **合規性**：模板內容 **SHALL** 對齊 `docs/meta-framework` 中對應範本與規範（特別是 `TEMPLATE_SYSTEM_PRD_SR_SD.md` 與各合規 mapping 模板）。
- **追溯性**：所有文件 **SHALL** 保留文件 ID、版本、變更歷史與追溯性欄位。

---

## 2. 模板一覽

- **需求文件模板**
  - `TEMPLATE_REQUIREMENTS_SYSTEM_PRD_SR_SD.md`  
    - 用途：系統層 PRD / SR / SD（專案版），對齊 `docs/meta-framework/requirements/TEMPLATE_SYSTEM_PRD_SR_SD.md`。

- **架構文件模板**
  - `TEMPLATE_ARCHITECTURE_SYSTEM_DESIGN.md`  
    - 用途：系統與子系統架構設計文件（對應 `architecture/` 目錄）。

- **測試文件模板**
  - `TEMPLATE_TESTING_STRATEGY_AND_REPORT.md`  
    - 用途：測試策略與測試報告（對應 `testing/` 目錄）。

- **追溯性文件模板**
  - `TEMPLATE_TRACEABILITY_MATRIX.md`  
    - 用途：需求–設計–程式碼–測試之追溯性矩陣（對應 `traceability/` 目錄）。

- **指南文件模板**
  - `TEMPLATE_GUIDE_DOCUMENT.md`  
    - 用途：一般操作指南、協作模式、開發流程等說明文件（對應 `guides/` 目錄）。

- **OpenSpec 整合文件模板**
  - `TEMPLATE_OPENSPEC_INTEGRATION_GUIDE.md`  
    - 用途：記錄 OpenSpec 變更如何映射到本專案需求、架構與測試（對應 `openspec-integration/` 目錄）。

> **Note**：規範與合規類文件（`regulations/`）優先使用 `docs/meta-framework/regulations` 下既有模板  
>（例如 `*-compliance-mapping-template.md`、`risk-analysis-template.md`），本目錄不重複建立同類模板。

---

## 3. 使用規則（General Rules）

所有從本目錄產生的新文件 **MUST** 滿足：

1. **文件頭資訊**
   - **文件 ID**：專案唯一 ID（例如：`IDP-REQ-001`、`IDP-ARCH-001`）。
   - **標題**：清楚描述文件用途與範圍。
   - **版本 / 狀態**：遵循語意化版本（如 `v1.0.0-Phase1`），狀態包含 `Draft / Review / Approved / Archived`。
   - **建立日期 / 最後更新**。
   - **作者 / 審核人**。

2. **變更歷史**
   - 必須包含「版本、日期、修改者、變更摘要」表格。

3. **追溯性欄位**
   - 需求、設計與測試文件 **MUST** 明確記錄：
     - `Traces to`（上游需求 / 法規）
     - `Traced by`（下游設計 / 實作 / 測試）

4. **RFC 2119 關鍵字**
   - 需求與規範文字中 **SHALL / MUST / SHOULD / MAY** 等關鍵字必須符合 `RFC-2119` 說明。

---

## 4. 類型與對應關係

| 類型           | 目錄                    | 建議模板檔案                              |
|----------------|-------------------------|-------------------------------------------|
| 系統層需求/設計 | `requirements/`         | `TEMPLATE_REQUIREMENTS_SYSTEM_PRD_SR_SD.md` |
| 架構設計       | `architecture/`         | `TEMPLATE_ARCHITECTURE_SYSTEM_DESIGN.md`  |
| 測試策略與報告 | `testing/`              | `TEMPLATE_TESTING_STRATEGY_AND_REPORT.md` |
| 追溯性矩陣     | `traceability/`         | `TEMPLATE_TRACEABILITY_MATRIX.md`         |
| 專案指南       | `guides/`               | `TEMPLATE_GUIDE_DOCUMENT.md`              |
| OpenSpec 整合  | `openspec-integration/` | `TEMPLATE_OPENSPEC_INTEGRATION_GUIDE.md`  |
| 規範/合規      | `regulations/`          | 使用 `docs/meta-framework/regulations` 內模板 |

---

## 5. AI 代理與開發者使用建議

- 在建立新文件前，**SHALL**：
  1. 檢查該類型是否已有對應模板檔。
  2. 直接複製對應模板並重新命名（例如：`TEMPLATE_REQUIREMENTS_SYSTEM_PRD_SR_SD.md` → `01_SYSTEM_PRD_SR_SD.md`）。
  3. 依實際需求調整章節與內容，但不得刪除關鍵欄位（文件頭、變更歷史、追溯欄位）。
- AI 代理在處理文檔相關任務時 **MUST**：
  - 先閱讀本索引與對應模板，再產生或修改文件內容。


