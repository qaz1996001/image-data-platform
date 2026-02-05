# 00 — 需求文檔索引 (Requirements Index)

**文件 ID**: DOC-IMAGE-DATA-PLATFORM-REQ-001  
**標題**: image_data_platform 專案需求文檔系統索引  
**版本**: v1.3.0  
**最後更新**: 2025-12-24

---

## 1. 目的

本目錄包含 image_data_platform 專案的所有需求文檔。所有需求描述 **MUST** 遵循 **RFC 2119** 關鍵字規範。

需求層級包括：
- **使用者需求 (UR)**：描述利害關係人的期望。
- **系統需求 (SYS-SR)**：描述系統整體的技術要求。
- **軟體需求 (SW-SR)**：描述特定軟體組件的詳細要求。

## 2. 文檔清單

| 文檔 ID | 標題 | 版本 | 狀態 | 備註 |
|--------|------|------|------|------|
| IDP-REQ-SYS-PRD-SR-SD-IMG-001 | 01_SYSTEM_PRD_SR_SD.md — 系統層 PRD / SR / SD | v1.0.0-Phase1 | Active | 系統層需求與設計 |
| IDP-REQ-FE-PRD-SR-SD-001 | 02_FRONTEND_PRD_SR_SD.md — 前端層 PRD / SR / SD | v2.1.0-Phase1 | Active | 前端 React + TypeScript 需求與設計 |
| IDP-REQ-BE-PRD-SR-SD-001 | 03_BACKEND_PRD_SR_SD.md — 後端層 PRD / SR / SD | v2.1.0-Phase1 | Active | 後端 API / DB / AI Service 需求與設計 |
| IDP-REQ-SDP-001 | software-development-plan.md — 軟體開發規劃 | v1.0.0-Phase1 | Active | IEC 62304 軟體開發規劃 |

## 3. 需求追溯性

所有需求文檔 **MUST** 遵循以下追溯要求：
- **向上追溯**：**MUST** 追溯至利害關係人需求或更高等級的需求。
- **完整追溯鏈**：UR → SYS-PRD → SYS-SR → SYS-SD → FE-SR/BE-SR → 設計 → 程式碼 → 測試
- **設計追溯**：**SHALL** 被架構與設計文檔 (`architecture/`) 追溯。
- **驗證追溯**：**MUST** 被測試案例 (`testing/`) 驗證，並體現在追溯矩陣 (`traceability/`) 中。

## 4. 需求管理流程

1. **需求獲取與分析**：識別利害關係人需求。
2. **需求規格化**：使用 RFC 2119 關鍵字編寫需求。
3. **需求審查**：確保需求具備 SMART 屬性。
4. **需求變更管理**：**MUST** 通過 OpenSpec 流程進行。

---

**文檔版本**: v1.4.0  
**最後更新**: 2025-12-26

