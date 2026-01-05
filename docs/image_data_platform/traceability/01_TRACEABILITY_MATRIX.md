# image_data_platform 追溯性矩陣（Traceability Matrix）

> 本文件為 image_data_platform 專案在新文檔結構下的**追溯性主文件**，  
> 連結需求（UR / SYS-PRD / SYS-SR）、設計（架構/資料庫/API）、程式碼與測試案例，  
> 取代舊索引 / 匯總中的部分追溯資訊，整合自 `docs/old/image_data_platform/regulations/IEC-62304/traceability-matrix.md`。

---

**文件 ID**: IDP-TRACE-IMG-001  
**標題**: image_data_platform — 追溯性矩陣（Phase 1）  
**版本**: v1.0.0-Phase1  
**狀態**: Active  
**建立日期**: 2025-12-26  
**最後更新**: 2025-12-26  
**作者**: [AI Agent]  
**審核人**: [品質負責人 / 系統工程師]  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v1.0 | 2025-12-26 | AI | 從 docs/old 遷移追溯性內容，建立 Phase 1 追溯矩陣 |

---

## 1. 目的與範圍（Purpose & Scope）

### 1.1 目的

本追溯性矩陣旨在：
1. **確保需求覆蓋完整性**：所有 UR 都有對應的 SYS-SR 與實作
2. **支援變更影響分析**：快速識別需求變更影響的下游項目
3. **符合法規要求**：滿足 IEC 62304:2006 §5.2.6 與 §8.1.3 追溯性要求
4. **支援審計與驗證**：提供完整的證據鏈（Evidence Trail）

### 1.2 範圍

- **涵蓋層級**：UR → SYS-PRD → SYS-SR → SYS-SD → FE-SR/BE-SR → FE-SD/BE-SD → 設計規格 → 程式碼 → 測試
- **追溯方向**：雙向追溯（Forward & Backward Traceability）
- **Phase 1 範圍**：UR-001 ~ UR-009, NFR-001 ~ NFR-009，及其衍生需求
- **維護方式**：配合需求變更與 OpenSpec 流程持續更新

### 1.3 追溯性層次結構

```
UR (User Requirements) - 9 個
  ↕
SYS-PRD (System Product Requirements) - 4 個
  ↕
SYS-SR (System Software Requirements) - 10 個功能 + 5 個非功能
  ↕
SYS-SD (System Design) - 7 個設計項目
  ↕                   ↕
FE-SR               BE-SR
(Frontend SR)        (Backend SR)
  ↕                   ↕
FE-Design           BE-Design
(Frontend Design)    (Backend Design)
  ↕                   ↕
FE-Code             BE-Code
  ↕                   ↕
FE-Tests            BE-Tests
```

---

## 2. 需求追溯矩陣（Requirements Traceability）

### 2.1 UR → SYS-PRD → SYS-SR → SYS-SD 完整追溯表

| UR ID | UR 標題 | 優先級 | SYS-PRD | SYS-SR | SYS-SD | 驗收標準 | 實作狀態 |
|-------|---------|--------|---------|--------|---------|---------|---------|
| **UR-001** | 使用者登入與基本認證 | 高 | SYS-PRD-004 | SYS-SR-010 | SYS-SD-001, SYS-SD-002, SYS-SD-007 | ✅ 正確憑證可登入<br>✅ 錯誤憑證顯示錯誤<br>✅ 會話 30 分鐘有效<br>✅ 密碼 bcrypt 加密 | Phase 1 |
| **UR-002** | 檢查資料與報告導入 | 高 | SYS-PRD-002, SYS-PRD-001 | SYS-SR-020 | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-007 | ✅ Excel/CSV 解析正確<br>✅ 欄位映射可配置<br>✅ 重複偵測生效<br>✅ 匯入速度 ≥ 500 筆/分 | Phase 1 |
| **UR-003** | 報告搜尋與篩選 | 高 | SYS-PRD-002 | SYS-SR-030 | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | ✅ 關鍵字搜尋準確<br>✅ 多條件篩選生效<br>✅ 分頁載入正確<br>✅ 搜尋響應 < 2 秒 | Phase 1 |
| **UR-004** | 報告詳細檢視 | 高 | SYS-PRD-001, SYS-PRD-002 | SYS-SR-030 | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | ✅ 完整報告內容顯示<br>✅ AI 標記歷史可查<br>✅ 患者資訊正確<br>✅ 載入時間 < 2 秒 | Phase 1 |
| **UR-005** | AI 報告分析 | 高 | SYS-PRD-002 | SYS-SR-040 | SYS-SD-001, SYS-SD-003, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | 單筆分析完成 < 10 秒<br>結果 JSON 格式正確<br>錯誤處理友善<br>提示詞可自訂 | Phase 1 |
| **UR-006** | AI 標記管理 | 高 | SYS-PRD-002 | SYS-SR-040 | SYS-SD-001, SYS-SD-003, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | 標記 CRUD 功能正常<br>標記篩選生效<br>編輯歷史可追蹤<br>批次操作支援 | Phase 1 |
| **UR-007** | 專案建立與管理 | 高 | SYS-PRD-003 | SYS-SR-050 | SYS-SD-001, SYS-SD-005, SYS-SD-006, SYS-SD-007 | 專案 CRUD 正常<br>報告加入/移除生效<br>統計資訊準確<br>列表載入 < 2 秒 | Phase 1 |
| **UR-008** | 專案資料匯出 | 高 | SYS-PRD-003 | SYS-SR-060 | SYS-SD-001, SYS-SD-005, SYS-SD-007 | ✅ Excel/CSV/JSON 匯出<br>✅ AI 標記可選擇性包含<br>✅ 欄位完整<br>✅ 匯出速度 ≥ 1000 筆/分 | Phase 1 |
| **UR-009** | 簡潔高效的 UI/UX | 高 | SYS-PRD-004 | SYS-SR-010, SYS-SR-NFR-001, NFR-004, NFR-005 | SYS-SD-001, SYS-SD-002 | ✅ 頁面載入 < 2 秒<br>✅ 鍵盤快捷鍵生效<br>✅ 錯誤提示清楚<br>✅ 1000+ 筆列表流暢 | Phase 1 |

### 2.2 NFR → SYS-SR-NFR 追溯表

| NFR ID | NFR 類別 | 指標 | SYS-SR-NFR | 驗證方式 | 實作狀態 |
|--------|---------|------|------------|---------|---------|
| **NFR-001** | 效能：響應時間 | API < 1s, 搜尋 < 2s, AI < 5s | SYS-SR-NFR-001 | 效能測試（P90） | Phase 1 |
| **NFR-002** | 效能：吞吐量 | 10+ 並發，500 筆/分匯入 | SYS-SR-NFR-001 | 壓力測試 | Phase 1 |
| **NFR-003** | 效能：資料容量 | 100k 報告，500k AI 標記 | SYS-SR-NFR-002 | 容量測試 | Phase 1 |
| **NFR-004** | 可用性：系統 | 95% 可用性，< 1 分啟動 | SYS-SR-NFR-003 | 監控與可用性測試 | Phase 1 |
| **NFR-005** | 可用性：UI | 核心操作 ≤ 3 步 | SYS-SR-NFR-004, NFR-005 | 使用性測試 | Phase 1 |
| **NFR-006** | 安全：認證 | JWT 30 分，密碼複雜度 | SYS-SR-NFR-004 | 安全測試 | Phase 1 |
| **NFR-007** | 安全：資料 | HTTPS, bcrypt, 日誌脫敏 | SYS-SR-NFR-004 | 安全審計 | Phase 1 |
| **NFR-008** | 可維護：品質 | 70% 測試覆蓋，PEP 8/ESLint | SYS-SR-NFR-005 | 程式碼審查 | Phase 1 |
| **NFR-009** | 可維護：部署 | Docker Compose, 環境變數 | SYS-SR-NFR-005 | 部署測試 | Phase 1 |

### 2.3 SYS-SR → SYS-SD → FE-SR/BE-SR 追溯表

| SYS-SR ID | SYS-SR 標題 | SYS-SD | FE-SR | BE-SR | 說明 |
|-----------|------------|-------|-------|------|------|
| **SYS-SR-010** | 認證 API 與會話管理 | SYS-SD-001, SYS-SD-002, SYS-SD-007 | FE-SR-001, FE-SR-002 | BE-SR-001, BE-SR-002 | JWT 登入、Token 管理 |
| **SYS-SR-020** | 檢查資料與報告匯入服務 | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-007 | FE-SR-010 | BE-SR-010, BE-SR-011 | Excel/CSV 預覽與執行 |
| **SYS-SR-030** | 報告搜尋與詳情 API | SYS-SD-001, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-010, FE-SR-011, FE-SR-020, FE-SR-030 | BE-SR-020, BE-SR-021, BE-SR-030, BE-SR-031 | 搜尋、詳情、標記顯示 |
| **SYS-SR-040** | AI 報告分析與標記管理 API | SYS-SD-001, SYS-SD-003, SYS-SD-004, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-030, FE-SR-040, FE-SR-041 | BE-SR-040, BE-SR-041 | AI 分析觸發、標記 CRUD |
| **SYS-SR-050** | 專案管理與報告關聯 API | SYS-SD-001, SYS-SD-005, SYS-SD-006, SYS-SD-007 | FE-SR-050, FE-SR-051 | BE-SR-050, BE-SR-051 | 專案 CRUD、報告關聯 |
| **SYS-SR-060** | 專案資料匯出 API | SYS-SD-001, SYS-SD-005, SYS-SD-007 | FE-SR-060 | BE-SR-060, BE-SR-061 | Excel/CSV/JSON 匯出 |
| **SYS-SR-NFR-001** | 效能需求（響應時間、吞吐量） | FE-SR-090~092 | BE-SR-NFR-001~003 | 前後端效能最佳化 |
| **SYS-SR-NFR-002** | 容量需求 | - | BE-SR-NFR-002 | 資料庫索引與查詢設計 |
| **SYS-SR-NFR-003** | 可用性需求 | - | BE-SR-NFR-003 | Docker 啟動、健康檢查 |
| **SYS-SR-NFR-004** | 安全性需求 | FE-SR-002, FE-SR-080 | BE-SR-NFR-004 | 認證、授權、加密 |
| **SYS-SR-NFR-005** | 可維護性需求 | FE-SR-090~092 | BE-SR-NFR-005 | 程式碼品質、測試、文件 |

**註**：FE-SR / BE-SR 詳細內容請參閱：
- 前端需求：[`requirements/02_FRONTEND_PRD_SR_SD.md`](../requirements/02_FRONTEND_PRD_SR_SD.md)
- 後端需求：[`requirements/03_BACKEND_PRD_SR_SD.md`](../requirements/03_BACKEND_PRD_SR_SD.md)

---

## 3. 設計與實作追溯（Design & Implementation Traceability）

### 3.1 SYS-SR → 架構設計追溯

| SYS-SR | 對應架構元件 | 文件位置 | 說明 |
|--------|------------|---------|------|
| SYS-SR-010 | 認證模組 (Authentication) | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §2 (子系統分解) | JWT 驗證、會話管理 |
| SYS-SR-020 | 資料導入模組 (Data Ingestion) | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §2, §3.1 (流程 1) | Excel/CSV 解析、欄位映射 |
| SYS-SR-030 | 報告管理模組 (Report Management) | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §2, §3.1 (流程 1) | 全文搜尋、報告 CRUD |
| SYS-SR-040 | AI 分析模組 (AI Analysis) | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §2, §3.1 (流程 2) | Ollama 整合、標註管理 |
| SYS-SR-050 | 專案管理模組 (Project Management) | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §2, §3.1 (流程 3) | 專案 CRUD、報告關聯 |
| SYS-SR-060 | 資料匯出模組 (Data Export) | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §2, §3.1 (流程 3) | Excel/CSV/JSON 生成 |

### 3.2 SYS-SR → 資料庫設計追溯

| SYS-SR | 對應資料表 | 文件位置 | 說明 |
|--------|-----------|---------|------|
| SYS-SR-010 | `users` 表 | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §4.2 (表 1) | 使用者帳號、角色、密碼 hash |
| SYS-SR-020, SYS-SR-030 | `reports` 表 | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §4.2 (表 2) | 報告內容、全文索引 |
| SYS-SR-040 | `ai_annotations` 表 | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §4.2 (表 3) | AI 標註結果 (JSONB) |
| SYS-SR-050 | `projects` 表 | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §4.2 (表 4) | 專案資訊 |
| SYS-SR-050 | `project_reports` 表 | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §4.2 (表 5) | 專案與報告多對多關聯 |

### 3.3 SYS-SR → API 設計追溯

| SYS-SR | 對應 API 端點 | 文件位置 | 說明 |
|--------|--------------|---------|------|
| SYS-SR-010 | `POST /api/v1/auth/login`<br>`GET /api/v1/auth/me` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §5.2 (認證 API) | JWT 登入與使用者查詢 |
| SYS-SR-020 | `POST /api/v1/import/preview`<br>`POST /api/v1/import/execute` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §5.2 (匯入 API) | 匯入預覽與執行 |
| SYS-SR-030 | `GET /api/v1/reports/search`<br>`GET /api/v1/reports/{id}` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §5.2 (報告 API) | 報告搜尋與詳情 |
| SYS-SR-040 | `POST /api/v1/ai/analyze`<br>`POST /api/v1/ai/batch-analyze`<br>`GET /api/v1/ai/annotations/{report_id}` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §5.2 (AI API) | AI 分析與標註管理 |
| SYS-SR-050 | `GET/POST/PUT/DELETE /api/v1/projects/*`<br>`POST /api/v1/projects/{id}/reports` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §5.2 (專案 API) | 專案 CRUD 與報告關聯 |
| SYS-SR-060 | `POST /api/v1/export/project`<br>`POST /api/v1/export/search` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) §5.2 (匯出 API) | 資料匯出 |

### 3.4 SYS-SR → 程式碼追溯（待補充）

> **Phase 1 狀態**：程式碼實作與追溯關係待補充。  
> 建議在程式碼中使用註解標註對應 SR ID，例如：

```python
# Implements: SYS-SR-010 (JWT Authentication)
# Traceability: UR-001 → SYS-PRD-004 → SYS-SR-010 → BE-SR-001
def login(request: LoginRequest) -> LoginResponse:
    ...
```

### 3.5 SYS-SR → 測試案例追溯（待補充）

> **Phase 1 狀態**：測試文件與追溯關係待補充。  
> 建議在測試檔案中標註對應 SR ID，例如：

```python
# Tests: SYS-SR-010, BE-SR-001
# Traceability: UR-001 → SYS-SR-010 → BE-SR-001 → test_login
def test_login_success():
    ...
```

---

## 4. 法規對應追溯（Regulations Traceability）

### 4.1 IEC 62304:2006 合規性追溯

| IEC 62304 條款 | 要求 | 對應文件 | 追溯至 SR | 狀態 |
|---------------|------|---------|----------|------|
| §5.2.6 Requirements Traceability | 需求可追溯性 | 本文件 + [`requirements/01_SYSTEM_PRD_SR_SD.md`](../requirements/01_SYSTEM_PRD_SR_SD.md) §6 | 全部 UR/SR | ✅ |
| §5.3.5 Architecture Verification | 架構驗證 | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) | SYS-SR-010~060 | ✅ |
| §5.4.2 Design Traceability | 設計追溯性 | 本文件 §3.2, §3.3 | SYS-SR → DB/API | ✅ |
| §5.5.5 Software Unit Verification | 單元驗證 | 待補充測試文件 | 待補充 | 🔄 |
| §8.1.3 Traceability to Risk Controls | 風險控制追溯 | 待補充風險文件 | 待補充 | ⏸️ |

### 4.2 ISO/IEC/IEEE 29148:2018 合規性追溯

| 29148 要求 | 品質特性 | 對應文件 | 狀態 |
|-----------|---------|---------|------|
| Verifiable | 可驗證性 | [`requirements/01_SYSTEM_PRD_SR_SD.md`](../requirements/01_SYSTEM_PRD_SR_SD.md) §4.2 (GIVEN/WHEN/THEN 場景) | ✅ |
| Traceable | 可追溯性 | 本文件（雙向追溯矩陣） | ✅ |
| Consistent | 一致性 | 全文件 ID 系統與追溯檢查 | ✅ |
| Modifiable | 可修改性 | 唯一 ID 與版本控制 | ✅ |

---

## 5. 追溯性維護原則（Maintenance Rules）

### 5.1 新增需求時

1. **分配唯一 ID**（例如 UR-010, SYS-SR-070）
2. **建立向上追溯連結**（標註來源需求）
3. **更新上游需求的向下追溯連結**
4. **同步更新本追溯矩陣**
5. **驗證雙向追溯完整性**

### 5.2 修改需求時

1. **識別所有受影響的下游項目**（透過本矩陣）
2. **同步更新下游需求/設計/程式碼/測試**
3. **更新追溯矩陣中的追溯關係**
4. **驗證追溯鏈完整性**

### 5.3 刪除需求時

1. **檢查是否有下游依賴**（透過本矩陣）
2. **處理孤立的下游項目**（重新映射或刪除）
3. **從追溯矩陣中移除該需求**
4. **驗證無孤立需求**

### 5.4 追溯性驗證檢查表

- [ ] **向下追溯完整性**：所有 UR 都有對應 SYS-PRD/SYS-SR
- [ ] **向上追溯完整性**：所有 SYS-SR 都追溯到 UR
- [ ] **橫向追溯一致性**：FE-SR 與 BE-SR 協同實作同一 SYS-SR
- [ ] **孤立需求偵測**：無無來源或無下游的需求
- [ ] **ID 唯一性**：所有需求 ID 唯一且符合命名規則

---

## 6. 參考文件（References）

1. [`requirements/01_SYSTEM_PRD_SR_SD.md`](../requirements/01_SYSTEM_PRD_SR_SD.md) - 系統層 PRD/SR/SD 與簡化追溯表
2. [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) - 系統架構與設計詳細文件
3. [`regulations/IEC-62304/traceability-matrix.md`](../regulations/IEC-62304/traceability-matrix.md) - IEC 62304 追溯性管理指南（舊參考）
4. [`requirements/02_FRONTEND_PRD_SR_SD.md`](../requirements/02_FRONTEND_PRD_SR_SD.md) - 前端需求文件
5. [`requirements/03_BACKEND_PRD_SR_SD.md`](../requirements/03_BACKEND_PRD_SR_SD.md) - 後端需求文件

---

**維護說明**：本追溯性矩陣應隨需求變更與實作進展持續更新。每次需求審查會議前應驗證追溯性完整性。
