## 1. 更新系統需求文檔

- [x] 1.1 閱讀 `docs/image_data_platform/requirements/01_SYSTEM_PRD_SR_SD.md` 第 5 章系統設計部分
- [x] 1.2 為現有的系統設計內容（架構概述、ADR 決策等）分配 SYS-SD-xxx 編號
- [x] 1.3 更新 SYS-SR 的 Traced by 欄位，加入對應的 SYS-SD ID
- [x] 1.4 為每個 SYS-SD 添加完整的追溯關係（Traces to SYS-SR, Traced by 子系統設計）
- [x] 1.5 更新第 6 章追溯矩陣，加入 SYS-SD 欄位

## 2. 更新追溯性矩陣

- [x] 2.1 閱讀 `docs/image_data_platform/traceability/01_TRACEABILITY_MATRIX.md`
- [x] 2.2 更新 1.3 節「追溯性層次結構」，加入 SYS-SD 層級
- [x] 2.3 更新 2.1 節 UR → SYS-PRD → SYS-SR 表格，加入 SYS-SD 欄位
- [x] 2.4 更新 2.3 節 SYS-SR → FE-SR/BE-SR 表格，改為 SYS-SR → SYS-SD → FE-SR/BE-SR
- [x] 2.5 如有其他追溯表格，同步加入 SYS-SD 欄位

## 3. 更新需求索引（如果存在）

- [x] 3.1 檢查 `docs/image_data_platform/requirements/00_REQUIREMENTS_INDEX.md` 是否存在
- [x] 3.2 如果存在，更新 ID 命名規則表格，加入 SYS-SD-xxx 格式說明
- [x] 3.3 更新流水號分配建議，加入 SYS-SD 的編號範圍

## 4. 驗證與檢查

- [x] 4.1 執行 `openspec validate apply-sys-sd-traceability-to-image-data-platform --strict`
- [x] 4.2 檢查所有 SYS-SR 都有對應的 SYS-SD（直接或間接）
- [x] 4.3 檢查所有 SYS-SD 都有明確的 Traces to 和 Traced by
- [x] 4.4 確認追溯鏈完整無斷鏈
- [x] 4.5 檢查文檔格式與 Markdown 語法正確

## 5. 文檔一致性檢查

- [x] 5.1 確認變更後的文檔與 meta-framework 的標準一致
- [x] 5.2 檢查是否有其他文檔（如架構設計、指南等）需要同步更新
- [x] 5.3 更新相關索引文檔中的追溯性說明（如果有）

