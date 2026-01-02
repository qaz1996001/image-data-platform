# Change: Apply SYS-SD Traceability to image_data_platform

## Why

根據 meta-framework 的最新修正，完整的追溯鏈應該包含系統設計（SYS-SD）層級，確保 UR → SYS-SR → SYS-SD → 子系統需求 → 子系統設計的完整追溯性。

目前 image_data_platform 的需求文檔中：
- 有系統設計章節，但沒有明確的 SYS-SD-xxx 編號格式
- 追溯性矩陣中缺少 SYS-SD 欄位
- 追溯鏈圖中缺少 SYS-SD 層級

這個變更將：
- 完善追溯性鏈，符合 ISO/IEC/IEEE 29148 標準要求
- 使系統設計有明確的 ID 和追溯關係
- 與 meta-framework 的標準保持一致

## What Changes

- 在 `requirements/01_SYSTEM_PRD_SR_SD.md` 中：
  - 為系統設計章節添加 SYS-SD-xxx 編號格式
  - 為現有設計內容（如 ADR）分配 SYS-SD ID
  - 更新追溯關係，加入 SYS-SD 的 Traces to 和 Traced by

- 在 `traceability/01_TRACEABILITY_MATRIX.md` 中：
  - 更新追溯鏈圖，加入 SYS-SD 層級
  - 更新追溯表格，加入 SYS-SD 欄位
  - 更新追溯性層次結構說明

- 在 `requirements/00_REQUIREMENTS_INDEX.md` 中（如果存在）：
  - 更新 ID 命名規則，加入 SYS-SD-xxx 格式說明

- 更新相關指南文檔，確保追溯性說明包含 SYS-SD 層級

## Impact

- **Affected specs**: `documentation-governance`
- **Affected docs**:
  - `docs/image_data_platform/requirements/01_SYSTEM_PRD_SR_SD.md`
  - `docs/image_data_platform/traceability/01_TRACEABILITY_MATRIX.md`
  - `docs/image_data_platform/requirements/00_REQUIREMENTS_INDEX.md` (if exists)
- **Breaking changes**: None (additive change only)
- **Compliance**: 改善 IEC 62304 §5.4.2 Design Traceability 合規性

