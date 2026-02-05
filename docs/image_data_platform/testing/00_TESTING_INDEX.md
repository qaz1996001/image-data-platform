# 00 — 測試與驗證文檔索引 (Testing Index)

**文件 ID**: DOC-IMAGE-DATA-PLATFORM-TEST-001  
**標題**: image_data_platform 專案測試與驗證文檔索引  
**版本**: v1.3.0  
**最後更新**: 2025-12-24

---

## 1. 目的

本目錄包含 image_data_platform 專案的所有測試與驗證文檔。所有軟體發佈 **MUST** 附帶對應的測試報告以證明其安全性與效能。

## 2. 測試層級

根據 IEC 62304 要求，本專案 **MUST** 執行以下層級的測試活動：
- **單元測試 (Unit Testing)**：針對各個模組進行獨立驗證。
- **整合測試 (Integration Testing)**：驗證模組間的介面與互動。
- **系統測試 (System Testing)**：驗證整個系統是否符合系統需求規格。
- **驗收測試 (Acceptance Testing)**：驗證系統是否符合使用者需求（UR）。

## 3. 文檔清單

| 文檔 ID | 標題 | 版本 | 狀態 | 備註 |
|--------|------|------|------|------|
| IDP-TEST-STRATEGY-IMG-001 | 01_TESTING_STRATEGY_AND_REPORT.md — 測試策略與報告 | v1.0.0-Phase1 | Draft | 從 `docs/old/workflow/`、完成報告整合中 |

## 4. 測試追溯性

所有測試案例 **MUST** 遵循以下追溯要求：
- **需求覆蓋**：所有標註為 **MUST** 的需求 **MUST** 至少有一個關聯的測試案例。
- **設計覆蓋**：關鍵架構組件 **SHOULD** 有對應的整合測試。
- **風險覆蓋**：所有風險控制措施 **MUST** 通過測試驗證其有效性。

---

**文檔版本**: v1.3.0

