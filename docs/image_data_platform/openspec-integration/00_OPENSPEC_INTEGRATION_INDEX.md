# 00 — OpenSpec 整合索引 (OpenSpec Integration Index)

**文件 ID**: DOC-IMAGE-DATA-PLATFORM-OSI-001  
**標題**: image_data_platform 專案 OpenSpec 整合管理索引  
**版本**: v1.3.0  
**最後更新**: 2026-01-02

---

## 1. 目的

本目錄記錄 image_data_platform 專案如何利用 OpenSpec 進行組態管理與變更控制。OpenSpec 是確保專案符合 IEC 62304 變更管理要求的核心工具。

## 2. 核心流程

所有對專案受控文件或原始碼的修改 **MUST** 遵循以下 OpenSpec 流程：
1. **提案階段**：建立 `proposal.md`，**MUST** 包含影響評估 (Impact Analysis)。
2. **實作階段**：依據 `tasks.md` 執行。所有 spec deltas **MUST** 遵循 RFC 2119 關鍵字規範。
3. **驗證階段**：任務完成後，**SHALL** 更新對應的測試結果。
4. **歸檔階段**：變更歸檔後，**MUST** 確保 `specs/` 與 `docs/` 已同步更新。

## 3. 專案特定規範

- **Change ID 命名**：**MUST** 採用 `[verb]-[subject]` 格式（如：`add-user-auth`）。
- **審核要求**：所有提案 **MUST** 經過至少一名開發者審核，且涉及法規影響時 **MUST** 經過合規官審核。

## 4. 文檔清單

| 文檔 ID | 標題 | 版本 | 狀態 | 備註 |
|--------|------|------|------|------|
| IDP-OPENSPEC-INTEG-IMG-001 | 01_OPENSPEC_INTEGRATION_GUIDE.md — OpenSpec 整合指南 | v1.2.0 | Active | 說明 OpenSpec 變更與 `docs/image_data_platform/**` 的映射與同步流程；含實務範例 |

---

**文檔版本**: v1.3.0

