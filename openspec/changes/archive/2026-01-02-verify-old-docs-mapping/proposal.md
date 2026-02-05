# Change: 建立舊文檔對應檢查清單

## Why

雖然 `docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` 第 7.3 節已提供舊文檔對應表，但該對應表較為高層級（僅列出主要目錄）。為確保 `docs/old/` 中所有文件都已被正確對應至 `docs/image_data_platform/` 的相應文件與章節，需要建立一個詳細的檢查清單（checklist），逐項驗證對應關係，確保沒有遺漏或錯誤。

此檢查清單將作為：
1. **驗證工具**：確認所有舊文檔都有對應位置
2. **審核依據**：供文檔維護者審核遷移完整性
3. **參考文檔**：未來查閱舊文檔時的快速對照表

## What Changes

- 建立詳細的舊文檔對應檢查清單（`docs/image_data_platform/OLD_DOCS_MAPPING_CHECKLIST.md`）
- 清單包含：
  - `docs/old/` 中所有文件的完整路徑
  - 對應至 `docs/image_data_platform/` 的目標文件/章節
  - 對應狀態（✅ 已對應 / ⚠️ 部分對應 / ❌ 未對應 / 📦 已歸檔）
  - 對應類型（完整整合 / 章節整合 / 歷史參考 / 已過時）
  - 備註說明
- 檢查清單將根據文件類型分組（索引、需求、架構、指南、規劃、實作、遷移等）
- 更新 `docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` 第 7.3 節，加入檢查清單連結

## Impact

**受影響的能力 (Capabilities)**:
- `documentation-governance`（文檔治理規範，需確保對應完整性）

**受影響的文件**:
- 新建：`docs/image_data_platform/OLD_DOCS_MAPPING_CHECKLIST.md` — 詳細對應檢查清單
- 更新：`docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` — 加入檢查清單連結

**破壞性變更**:
- ❌ 無破壞性變更（僅新增檢查清單，不影響現有文檔結構）

**風險**:
- 低風險：僅新增文檔，不修改現有內容
- 可能發現部分舊文檔尚未完全對應，需要後續處理

**預估工作量**:
- 建立檢查清單：2-3 小時
- 驗證對應關係：1-2 小時
- 更新索引文件：0.5 小時
- **總計**：~4 小時

---
**提案建立日期**: 2025-12-26  
**提案狀態**: 📝 待審核 (Pending Review)

