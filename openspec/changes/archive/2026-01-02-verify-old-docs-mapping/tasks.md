# Tasks: 建立舊文檔對應檢查清單

## 1. 準備工作
- [x] 1.1 檢視現有對應表（`docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` 第 7.3 節）
- [x] 1.2 清點 `docs/old/` 中所有 markdown 文件（排除 archive 目錄）
- [x] 1.3 檢視 `docs/image_data_platform/` 的目錄結構，確認所有目標文件位置

## 2. 建立檢查清單文檔
- [x] 2.1 建立 `docs/image_data_platform/OLD_DOCS_MAPPING_CHECKLIST.md`
- [x] 2.2 按照文件類型分組（索引、需求、架構、指南、規劃、實作、遷移等）
- [x] 2.3 為每個文件建立對應條目，包含：
  - 舊文檔路徑
  - 新文檔路徑/章節
  - 對應狀態（✅ 已對應 / ⚠️ 部分對應 / ❌ 未對應 / 📦 已歸檔）
  - 對應類型（完整整合 / 章節整合 / 歷史參考 / 已過時）
  - 備註說明

## 3. 驗證對應關係
- [x] 3.1 逐項檢查每個文件的對應狀態
- [x] 3.2 確認對應路徑/章節是否正確
- [x] 3.3 標記需要進一步處理的文件
- [x] 3.4 驗證所有文件的完整性（無遺漏）

## 4. 更新索引文件
- [x] 4.1 更新 `docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` 第 7.4 節
- [x] 4.2 加入檢查清單的連結
- [x] 4.3 更新相關說明文字

## 5. 建立 OpenSpec 規範變更
- [x] 5.1 建立 spec delta 文件 (`openspec/changes/verify-old-docs-mapping/specs/documentation-governance/spec.md`)
- [x] 5.2 更新 `documentation-governance` 規範，加入檢查清單要求
- [x] 5.3 驗證 OpenSpec 變更通過驗證 (`openspec validate verify-old-docs-mapping --strict`)

## 6. 審核與驗證
- [x] 6.1 檢查清單格式正確性
- [x] 6.2 確認所有連結可正常訪問
- [x] 6.3 驗證對應關係準確性

