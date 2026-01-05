# TEMPLATE: image_data_platform 追溯性矩陣（Traceability Matrix）

> **使用說明**  
> 本模板適用於 `docs/image_data_platform/traceability/` 下的追溯性矩陣文件。  
> 用於連結需求（UR / SR）、設計、程式碼與測試案例，確保符合醫療器材軟體追溯性要求。

---

**文件 ID**: IDP-TRACE-001  
**標題**: image_data_platform — 追溯性矩陣  
**版本**: v1.0.0-Phase1  
**狀態**: Draft  
**建立日期**: YYYY-MM-DD  
**最後更新**: YYYY-MM-DD  
**作者**: [待填]  
**審核人**: [品質負責人 / 系統工程師]  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v0.1 | YYYY-MM-DD | [姓名] | 初始草稿 |

---

## 1. 目的與範圍（Purpose & Scope）

- 說明本追溯矩陣涵蓋的需求範圍（例如：Phase 1 核心功能）。
- 指出與哪些需求 / 規範文件相連結（例如 `requirements/`、`regulations/`）。

---

## 2. 需求追溯矩陣（Requirements Traceability）

> 將使用者需求（UR）、系統需求（SYS-SR）、設計與實作、測試案例關聯起來。

| UR ID | SYS-PRD ID | SYS-SR ID | Design ID | Code Location                  | Test Case ID      | Verification Method | Status |
|-------|-----------|-----------|-----------|-------------------------------|-------------------|---------------------|--------|
| UR-001 | SYS-PRD-001 | SYS-SR-010 | ARCH-IMG-INGEST | `backend/ingest/service.py:45` | TC-IDP-ING-001    | Test                | Verified |
| UR-002 | SYS-PRD-002 | SYS-SR-020 | ARCH-IMG-STORE  | `backend/storage/models.py:10` | TC-IDP-STORE-001  | Test                | In Progress |

---

## 3. 法規對應追溯（Regulations Traceability）

> 可與 `docs/image_data_platform/regulations/` 內的合規 mapping 文件搭配使用。

| Regulation ID | 條款 / 章節 | 關聯需求 (UR / SR) | 關聯設計 / 實作 | 測試證據 (Test Evidence) |
|---------------|------------|---------------------|-----------------|---------------------------|
| ISO-14971     | 7.4        | UR-001, SYS-SR-010  | ARCH-IMG-INGEST | Test Report: TEST-RESP-001 |

---

## 4. 設計與實作追溯（Design & Implementation Traceability）

| Design ID | 類型 | 說明 | Traces to SYS-SR | Implemented in Code | Test Case ID |
|-----------|------|------|------------------|---------------------|--------------|
| ARCH-IMG-INGEST | Component | 影像匯入服務 | SYS-SR-010 | `backend/ingest/service.py` | TC-IDP-ING-001 |

---

## 5. 追溯性維護原則（Maintenance Rules）

- 每當新增或修改需求 / 設計 / 測試時，**MUST** 同步更新本矩陣。
- 若有多個版本（Phase 1 / Phase 2），可使用額外欄位標示版本與狀態。


