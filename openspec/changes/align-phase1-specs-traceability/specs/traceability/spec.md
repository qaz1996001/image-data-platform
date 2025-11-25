## ADDED Requirements

### Requirement: Phase 1 Traceability Matrix

The system documentation SHALL maintain a canonical traceability matrix that maps each User Requirement (UR) to its corresponding System (SYS), Frontend (FE), and Backend (BE) requirements, ensuring full coverage and traceability for IEC 62304 compliance.

#### Scenario: Matrix Content and Mappings
- **WHEN** referencing the Phase 1 requirements set
- **THEN** the following traceability mappings SHALL apply:

| UR ID | UR 摘要（簡述） | SYS‑PRD | SYS‑SR | FE‑PRD / FE‑SR（主要） | BE‑PRD / BE‑SR（主要） |
|-------|-----------------|---------|--------|------------------------|------------------------|
| UR‑001 | 使用者登入（JWT，30 分鐘有效會話） | SYS‑PRD‑004 | SYS‑SR‑001 | FE‑PRD‑001 / FE‑SR‑001, FE‑SR‑002 | BE‑PRD‑001 / BE‑SR‑001, BE‑SR‑002 |
| UR‑002 | 檢查 / 報告資料匯入（Excel/CSV + 欄位映射） | SYS‑PRD‑002 | SYS‑SR‑002 | （前端匯入精靈 UI，整體掛在 FE‑PRD‑002 / FE‑SR‑010，尚未完全展開） | BE‑PRD‑002 / BE‑SR‑010, BE‑SR‑011 |
| UR‑003 | 檢查記錄搜尋（全文＋多條件） | SYS‑PRD‑002 | SYS‑SR‑003 | FE‑PRD‑002 / FE‑SR‑010, FE‑SR‑011 | BE‑PRD‑002, BE‑PRD‑003 / BE‑SR‑020 |
| UR‑004 | 報告詳情檢視（含 AI 標記歷史） | SYS‑PRD‑001 | SYS‑SR‑004 | FE‑PRD‑003 / FE‑SR‑020, FE‑SR‑030 | BE‑PRD‑003, BE‑PRD‑004 / BE‑SR‑021, BE‑SR‑030, BE‑SR‑031 |
| UR‑005 | 單筆 AI 報告分析（Ollama、本地 LLM） | SYS‑PRD‑001 | SYS‑SR‑005, SYS‑SR‑006 | FE‑PRD‑004 / FE‑SR‑040 | BE‑PRD‑004 / BE‑SR‑040, BE‑SR‑041 |
| UR‑006 | AI 標記管理與基於標記的篩選 | SYS‑PRD‑001 | SYS‑SR‑007（部分 SYS‑SR‑006 亦相關） | FE‑PRD‑003, FE‑PRD‑004 / FE‑SR‑030, FE‑SR‑040, FE‑SR‑041 | BE‑PRD‑004 / BE‑SR‑030, BE‑SR‑031, BE‑SR‑040, BE‑SR‑041 |
| UR‑007 | 專案建立與管理（報告集合） | SYS‑PRD‑003 | SYS‑SR‑008 | FE‑PRD‑005 / FE‑SR‑050, FE‑SR‑051 | BE‑PRD‑005 / BE‑SR‑050, BE‑SR‑051 |
| UR‑008 | 專案 / 搜尋結果匯出（Excel / CSV / JSON） | SYS‑PRD‑003 | SYS‑SR‑009 | FE‑PRD‑005 / FE‑SR‑060 | BE‑PRD‑005 / BE‑SR‑060, BE‑SR‑061 |
| UR‑009 | 高效 UI / 鍵盤快捷鍵 / 大列表效能 | SYS‑PRD‑004 | SYS‑SR‑010 + SYS‑SR‑NFR‑001, 004, 005 | FE‑PRD‑006, FE‑PRD‑007 / FE‑SR‑080, FE‑SR‑090~092 | BE‑PRD‑001, BE‑PRD‑002, BE‑PRD‑003 / BE‑SR‑NFR‑001 – 005（後端僅以效能／穩定性支撐） |

> **Notes**:
> - Source of truth for mappings: `USER_REQUIREMENTS.md` (UR), `01_SYSTEM_PRD_SR_SD.md` (SYS), `02_FRONTEND_PRD_SR_SD.md` (FE), `03_BACKEND_PRD_SR_SD.md` (BE).
> - FE/BE lists include primary requirements; see respective docs for full details.

