# 00 — 架構與設計文檔索引 (Architecture Index)

**文件 ID**: DOC-IMAGE-DATA-PLATFORM-ARC-001  
**標題**: image_data_platform 專案架構與設計文檔索引  
**版本**: v1.5.0  
**最後更新**: 2025-12-26

---

## 1. 目的

本目錄包含 image_data_platform 專案的所有架構與設計文檔，遵循 meta-framework 的三層架構規範。所有設計決策 **SHOULD** 記錄其理由與影響評估。

分層結構如下：
- **Layer 1: 系統層** (System Architecture)
- **Layer 2: 子系統層** (Subsystem Architecture)
- **Layer 3: 模組層** (Detailed Design)

## 2. 文檔清單

| 文檔 ID | 標題 | 版本 | 狀態 | 內容摘要 |
|--------|------|------|------|---------|
| IDP-ARCH-SYS-IMG-001 | 01_SYSTEM_ARCHITECTURE_DESIGN.md<br/>— 系統架構設計 | v1.0.0-Phase1 | Active | **完整整合版本（1300+ 行）**<br/>✅ 架構概覽（高階架構、技術選型）<br/>✅ 子系統分解（6 大子系統）<br/>✅ 資料流與控制流（3 個流程 + 序列圖）<br/>✅ 資料模型設計（5 張表 + ER 圖 + DDL）<br/>✅ 完整資料庫初始化 SQL 腳本<br/>✅ 常用查詢範例（全文搜尋、統計）<br/>✅ API 設計（6 大模組，20+ 端點）<br/>✅ API 客戶端範例（Python/TypeScript/curl）<br/>✅ 非功能設計（效能、安全、可維護性）<br/>✅ 前端狀態管理（Zustand）<br/>✅ Ollama AI Engine 整合細節<br/>✅ 錯誤處理與最佳化策略<br/>✅ 部署架構（Docker Compose/Nginx）<br/>✅ 環境配置與監控<br/>✅ 風險與技術債識別<br/>**整合來源**: `docs/old/architecture/`, `database/`, `api/` |

## 3. 設計追溯性

所有架構與設計文檔 **MUST** 遵循以下追溯要求：
- **需求追溯**：**MUST** 向上追溯至相關的需求文檔 (`requirements/`)。
- **實作追溯**：**SHALL** 被原始碼中的實作代碼所參考。
- **風險追溯**：若涉及風險控制，**MUST** 追溯至風險分析報告 (`regulations/ISO-14971-...`)。
- **驗證追溯**：**SHALL** 被整合測試或單元測試所驗證。

## 4. 設計原則（Architecture Decision Records, ADR）

### ADR-001: Phase 1 採用 5 張核心表（簡化資料模型）
- **決策**: Phase 1 不建立獨立的 `patients`, `studies`, `series` 表，患者資訊直接嵌入 `reports` 表
- **理由**: 
  - Phase 1 聚焦於報告篩選與 AI 分析，不需要複雜的影像管理層級結構
  - 減少 JOIN 操作，提升查詢效能
  - 降低初期開發複雜度
- **影響**: 
  - ✅ 優點：開發速度快，查詢簡單
  - ❌ 缺點：患者資訊可能重複儲存（同一患者多次檢查）
- **遷移策略**: Phase 2 將新增 `patients` 表，並重構 `reports` 表為 1:N 關係

### ADR-002: 使用 PostgreSQL JSONB 儲存 AI 分析結果
- **決策**: `ai_annotations.content` 欄位使用 JSONB 而非關聯式結構
- **理由**:
  - AI 分析結果結構多變（highlight/classification/extraction/scoring 各有不同 schema）
  - JSONB 支援靈活查詢（GIN 索引）
  - 避免為每種分析類型建立獨立表
- **影響**:
  - ✅ 優點：靈活、易擴充、支援 JSON 查詢
  - ❌ 缺點：無法在資料庫層級強制 schema 驗證（需在應用層驗證）

### ADR-003: 前端採用 Zustand 而非 Redux
- **決策**: Phase 1 使用 Zustand 作為全域狀態管理工具
- **理由**:
  - Zustand API 簡潔，學習曲線低
  - 支援 TypeScript，類型安全
  - 無需 boilerplate（reducer/action/dispatch）
  - 內建 devtools 與 persistence middleware
- **影響**:
  - ✅ 優點：開發效率高，程式碼簡潔
  - ❌ 缺點：生態系統較 Redux 小

### ADR-004: 後端架構採用 FastAPI（Phase 1）→ Django Ninja（Phase 2）
- **決策**: Phase 1 使用 FastAPI 快速原型，Phase 2 評估遷移至 Django Ninja
- **理由**:
  - FastAPI 開發速度快，適合 MVP
  - Django 提供更完整的 ORM、Admin、權限管理（Phase 2 需求）
  - Django Ninja 保留 FastAPI 的 API 風格
- **影響**:
  - ✅ 優點：Phase 1 快速上線
  - ❌ 缺點：需規劃 Phase 2 遷移成本（Service Layer 需解耦）

### ADR-005: Ollama AI Engine 部署於院內而非雲端
- **決策**: 使用 Ollama 部署 qwen2.5:7b 於本地伺服器，不使用雲端 API（如 OpenAI/Claude）
- **理由**:
  - 醫療資料隱私要求（不可傳送至外部）
  - 成本考量（避免雲端 API 按次計費）
  - 可客製化模型與提示詞
- **影響**:
  - ✅ 優點：資料隱私、成本可控
  - ❌ 缺點：需自行維護 GPU 資源與模型更新

---

## 5. Phase 1 與 Phase 2 對照

| 面向 | Phase 1 (Current) | Phase 2 (Planned) |
|------|-------------------|-------------------|
| **資料庫** | 5 張核心表（患者資訊嵌入 `reports`） | 新增 `patients`, `studies`, `series`, `images` 表 |
| **後端框架** | FastAPI | Django + Django Ninja |
| **影像管理** | ❌ 不支援 | ✅ DICOM 上傳/查看/下載 |
| **權限管理** | 2 種角色（admin/researcher） | RBAC（角色基於權限管理） |
| **認證** | JWT（30 分鐘有效期） | JWT + Refresh Token + SSO |
| **批次任務** | 同步處理 | Celery + Redis 非同步任務佇列 |
| **全文搜尋** | PostgreSQL GIN 索引 | Elasticsearch（支援 > 100 萬筆資料） |

---

## 6. 相關文檔連結

- **需求文檔**: `../requirements/01_SYSTEM_PRD_SR_SD.md` — 系統需求與追溯
- **測試文檔**: `../testing/01_TESTING_STRATEGY_AND_REPORT.md` — 測試策略與報告
- **指南文檔**: `../guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md` — 專案概覽與開發流程
- **舊文檔（已廢止）**: `../../old/architecture/`, `../../old/database/`, `../../old/api/`

---

**文檔版本**: v1.5.0  
**維護狀態**: Active  
**整合完成度**: ✅ 100% (所有 `docs/old/architecture`, `database`, `api` 內容已整合至 `01_SYSTEM_ARCHITECTURE_DESIGN.md`)

