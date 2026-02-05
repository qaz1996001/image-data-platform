# Change: Migrate legacy docs/old to structured docs/image_data_platform and deprecate old documents

## Why
image_data_platform 專案目前同時存在兩套文檔結構：舊版 `docs/old/**`（含 `00_DOCUMENTATION_INDEX.md` 等）與新版 `docs/image_data_platform/**`（含索引、templates 與子目錄）。若持續並存，將導致真實文件位置不明、審核與合規困難，且與 `documentation-governance` 規範要求的一致性衝突。

## What Changes
- 建立一套**正式遷移與廢止策略**：將 `docs/old/**` 中仍有效的內容遷移到 `docs/image_data_platform/**` 對應位置，並明確標記舊檔為 Deprecated / Archived。
- 定義**新舊索引與文件的對應關係**：例如將舊 `docs/old/00_DOCUMENTATION_INDEX.md` / `01_PROJECT_OVERVIEW.md` 等內容，整合或重寫進 `docs/image_data_platform` 結構與 templates 產生的新文件中。
- 在 `documentation-governance` 能力中新增需求：規定 image_data_platform 的**唯一權威文檔樹（canonical docs tree）** 為 `docs/image_data_platform/**`，`docs/old/**` 僅可作為封存或歷史參考，不得再作為現行依據。
- 為 AI 代理與開發者定義**操作流程**：新增情境，說明當在 `docs/old/**` 中發現內容但 `docs/image_data_platform/**` 已有對應文件時，應如何處理（優先更新新結構、標記舊檔等）。

## Impact
- **Affected specs**
  - `specs/documentation-governance/spec.md`
- **Affected docs**
  - `docs/old/**`：舊版索引與主文檔（`00_DOCUMENTATION_INDEX.md`、`01_PROJECT_OVERVIEW.md`、`DOCUMENTATION_INDEX.md` 等）
  - `docs/image_data_platform/**`：索引、templates 與各子目錄中新建或補齊的文件
- **Out of scope (本次不處理)**
  - 不修改 meta-framework 通用規範（`docs/meta-framework/**`）
  - 不改動後端 / 前端程式碼實作


