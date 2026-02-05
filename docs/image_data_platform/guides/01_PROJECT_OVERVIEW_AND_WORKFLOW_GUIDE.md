# image_data_platform 專案概覽與開發工作流指南（Project Overview & Workflow Guide）

> 本文件為 image_data_platform 專案在新文檔結構下的**專案概覽與開發工作流主指南**，  
> 整合自 `docs/old/01_PROJECT_OVERVIEW.md` 與 `docs/old/workflow/05_DEVELOPMENT_WORKFLOW.md`。

---

**文件 ID**: IDP-GUIDE-IMG-OVERVIEW-001  
**標題**: image_data_platform 專案概覽與開發工作流指南  
**版本**: v2.1.0-Phase1  
**狀態**: Active  
**建立日期**: 2025-12-26  
**最後更新**: 2026-01-05  
**作者**: [AI Agent]  
**審核人**: [產品負責人 / 技術負責人]  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v2.1 | 2026-01-05 | AI | 新增 §7.2 程式碼品質檢查門檻 (Quality Gates)；更新 imports 模組狀態 |
| v2.0 | 2025-12-26 | AI | 從 docs/old 整合專案概覽與開發工作流內容 |

---

## 1. 目的（Purpose）

本指南提供：
1. **專案背景與目標**：說明 image_data_platform 的業務背景、核心價值與 Phase 1 目標
2. **功能模組總覽**：5 大核心功能模組（資料匯入、AI 分析、報告檢索、專案管理、資料匯出）
3. **技術堆疊**：Phase 1 採用的前後端技術、資料庫與 AI 引擎
4. **開發工作流**：8 週 Phase 1 開發時程、各階段任務與交付物
5. **角色與責任**：團隊角色分工與協作模式

**目標對象**：
- 新加入的開發者（了解專案全貌）
- AI 代理（理解專案上下文與開發流程）
- 專案經理與產品負責人（追蹤進度與里程碑）

---

## 2. 專案背景與目標（Background & Objectives）

### 2.1 專案背景

基於 2020-2024 年 PAPA 數據和多源醫療檢查報告，構建 **AI 驅動的報告篩選和管理平台**，用於 PACS 影像下載前的資料預處理和智能分析。本系統採用**本地 LLM（Ollama）**實現報告內容的智能理解和標註，幫助研究人員高效篩選和組織臨床研究數據。

#### 核心價值

- **智能篩選**：AI 輔助快速識別符合研究標準的報告
- **本地部署**：資料不出院內，保障患者隱私安全
- **高效管理**：專案化組織篩選結果，支援批次匯出
- **研究友好**：為後續 PACS 影像下載提供精準的檢查清單

#### 業務問題

| 現狀問題 | 解決方案 |
|---------|---------|
| 手動篩選效率低 | AI 自動標註關鍵資訊 |
| 篩選標準不一致 | 標準化提示詞模板與分類 |
| 缺乏結構化標記 | JSONB 儲存 AI 分析結果 |
| 資料組織混亂 | 專案管理與報告關聯 |
| 重複勞動 | 批次分析與提示詞複用 |

### 2.2 Phase 1 目標（8 週）

1. **資料整合**：統一匯入和管理多源檢查報告資料（PAPA 表、Red Report 等）
2. **智能分析**：本地 LLM 驅動的報告內容理解和自動標註
3. **高效檢索**：全文搜尋和多維度篩選功能
4. **專案管理**：建立專案組織篩選結果，支援協作
5. **資料匯出**：匯出篩選清單用於 PACS 影像下載準備

### 2.3 Phase 2 規劃（未來擴展）

- ⏸️ DICOM 影像預覽和檢視器整合（Cornerstone.js）
- ⏸️ 影像儲存和管理（MinIO 物件儲存）
- ⏸️ Accssyn 自動同步
- ⏸️ 高級統計分析和視覺化（Elasticsearch + Kibana）

**遷移路徑**：Phase 1 的 5 張表設計已預留擴展能力，提供 SQL 遷移腳本。

---

## 3. 核心功能模組（Core Features）

### 3.1 資料匯入模組（Data Import）

#### 目標
靈活匯入多源檢查報告資料

#### 功能清單

**Excel/CSV 匯入**
- 智能欄位映射（拖拽配置）
- 資料預覽和驗證（前 100 行）
- 重複偵測（基於 patient_id + exam_date）
- 批次匯入（支援 10,000+ 筆記錄）

**資料來源支援**
- PAPA 表資料（2020-2024）
- Red Report 手動匯入
- 自訂 Excel 格式

**資料品質**
- 必填欄位驗證（patient_id, exam_date, report_content）
- 日期格式自動識別
- 資料清洗和標準化

#### 技術實作
- Pandas 處理 Excel/CSV 檔案
- 前端欄位映射介面（Ant Design Upload + DragDrop）
- 批次插入最佳化（100 筆/batch）

---

### 3.2 AI 分析模組（AI Analysis）— 核心功能

#### 目標
本地 LLM 驅動的報告智能理解和標註

#### AI 能力

**單報告分析**
- 使用者自訂提示詞
- 4 種標註類型：高亮（highlight）、分類（classification）、提取（extraction）、評分（scoring）
- 即時回饋（5-10 秒）

**批次分析**
- 並發處理（3-5 個同時）
- 背景任務佇列
- 進度追蹤和錯誤處理
- 支援 50-100 個報告/批次

**提示詞庫**
- 6 個預置模板（關鍵發現、嚴重程度、病灶資訊、測量值提取等）
- 使用者自訂提示詞儲存
- 提示詞管理和複用

#### 技術實作
- Ollama 本地部署（推薦模型：qwen2.5:7b）
- FastAPI 非同步任務處理
- JSONB 儲存 AI 分析結果
- 置信度評分系統

#### AI 標註範例

```json
// 高亮關鍵發現
{
  "highlights": [
    {"text": "雙肺紋理增多", "start": 15, "end": 22, "reason": "關鍵發現"}
  ]
}

// 嚴重程度分類
{
  "category": "moderate",
  "confidence": 0.85,
  "reasoning": "存在中度異常，需進一步檢查"
}

// 提取測量值
{
  "measurements": [
    {"item": "結節直徑", "value": "8", "unit": "mm", "location": "右肺上葉"}
  ]
}
```

---

### 3.3 報告檢索與篩選模組（Report Search & Filter）

#### 目標
快速定位目標報告

#### 搜尋功能

**全文搜尋**（PostgreSQL GIN 索引）
- 報告內容全文檢索
- 患者姓名/ID 搜尋
- 中文分詞支援

**多條件篩選**
- 時間範圍（日期區間選擇）
- 檢查類型（CT、MRI、X-Ray 等）
- 部門（病區、OPD）
- ICD 疾病編碼

**AI 標註篩選**
- 按 AI 分類結果過濾
- 按嚴重程度篩選
- 按置信度範圍篩選

#### 使用者體驗
- 即時搜尋（輸入即搜，300ms 防抖）
- 分頁載入（20 筆/頁）
- 虛擬捲動（大資料集最佳化）
- 快捷鍵支援（Ctrl+K 喚起搜尋）

---

### 3.4 專案管理模組（Project Management）

#### 目標
組織和管理篩選結果

#### 功能清單

**專案 CRUD**
- 建立專案（名稱、描述、標籤）
- 專案列表和詳情
- 專案封存和刪除

**報告關聯**
- 從搜尋結果新增報告到專案
- 批次新增（多選）
- 新增備註說明

**協作支援**
- 專案建立者記錄
- 新增人追蹤
- 專案狀態（active/archived/completed）

**專案統計**
- 報告數量統計
- AI 標註分布
- 檢查類型分布

---

### 3.5 資料匯出模組（Data Export）

#### 目標
匯出篩選清單用於 PACS 下載準備

#### 匯出格式

**Excel 格式**（推薦）
- 完整欄位資訊
- AI 標註結果
- 格式化和樣式

**CSV 格式**
- 相容性最佳
- 大資料匯出

**JSON 格式**
- API 整合友善
- 完整資料結構

#### 匯出選項
- 匯出當前篩選結果
- 匯出完整專案報告
- 自訂欄位選擇
- AI 標註結果包含/排除

---

## 4. 技術堆疊（Technology Stack）

### 4.1 前端技術

```yaml
框架: React 18+ with TypeScript
UI 元件庫: Ant Design 5.x
狀態管理: Zustand (輕量級)
HTTP 客戶端: Axios
建置工具: Vite 5.x
程式碼規範: ESLint + Prettier
```

**關鍵套件版本**：
- React 18.2+
- TypeScript 5.2+
- Ant Design 5.11+
- React Router DOM 6.20+

### 4.2 後端技術

```yaml
Web 框架: FastAPI 0.104+ (Python 3.10+)
ORM: SQLAlchemy 2.0+
資料驗證: Pydantic 2.5+
遷移工具: Alembic
非同步 HTTP: httpx (呼叫 Ollama)
密碼加密: bcrypt
身份認證: JWT (python-jose)
```

**關鍵決策**：
- FastAPI 提供高效能非同步 API
- Pydantic 確保型別安全與資料驗證
- SQLAlchemy 2.0 新語法更簡潔

### 4.3 資料庫

```yaml
主資料庫: PostgreSQL 14+
  - JSONB 支援（AI 標註儲存）
  - 全文搜尋（GIN 索引）
  - 觸發器和視圖
```

**表結構**（5 張核心表）：
1. `users` - 使用者帳號與角色
2. `reports` - 檢查報告資料
3. `ai_annotations` - AI 標註結果（JSONB）
4. `projects` - 研究專案
5. `project_reports` - 專案與報告多對多關聯

### 4.4 AI 引擎

```yaml
LLM 部署: Ollama (本地部署)
推薦模型: qwen2.5:7b (Alibaba 開源)
備選模型:
  - llama3.1:8b
  - mistral:7b
  - gemma2:9b
```

**Ollama 優勢**：
- 本地部署保障資料隱私
- RESTful API 易於整合
- 支援 JSON 格式輸出（JSON mode）
- 模型可替換與更新

### 4.5 基礎設施

```yaml
容器化: Docker + Docker Compose
版本控制: Git
程式碼託管: GitHub / GitLab
```

**Phase 1 移除的元件**（Phase 2 再加入）：
- ❌ MinIO（物件儲存）
- ❌ Redis（快取）
- ❌ Celery（任務佇列）- 使用 FastAPI BackgroundTasks
- ❌ Cornerstone.js（DICOM 檢視器）
- ❌ Elasticsearch（搜尋引擎）- PostgreSQL 全文搜尋足夠

---

## 5. 開發工作流（Development Workflow）

### 5.1 Phase 1 時程總覽（8 週）

```
Week 1-2: 基礎架構和資料匯入 ████████░░░░░░░░░░░░░░
Week 3-4: 報告檢索和 AI 整合   ░░░░░░░░████████░░░░░░
Week 5-6: AI 分析和專案管理    ░░░░░░░░░░░░░░██████░░
Week 7:   測試和最佳化         ░░░░░░░░░░░░░░░░░░████
Week 8:   部署和培訓           ░░░░░░░░░░░░░░░░░░░░██
```

### 5.2 Week 1-2: 基礎架構和資料匯入

#### Week 1: 專案初始化與開發環境

**目標**：搭建完整的 Phase 1 開發環境

**任務清單**：

**Day 1-2: 環境準備**
- [x] Docker 環境配置
  - 安裝 Docker 和 Docker Compose
  - 配置 PostgreSQL 14
  - 安裝 Ollama 服務
- [x] 建立專案 Git 倉庫
  - 配置 .gitignore 和專案規範

**Day 3-4: 前端框架和資料庫**
- [x] 前端專案搭建
  - 使用 Vite 建立 React 專案
  - 配置 TypeScript 和 ESLint
  - 安裝 Ant Design 和基礎依賴
  - 設定路由結構（react-router-dom v6）

- [x] 資料庫設計實施
  - 建立 5 張核心表
  - 設定外鍵關係和索引
  - 配置全文搜尋索引（GIN）
  - 配置 JSONB 索引

**Day 5: Ollama 模型配置**
- [x] Ollama 部署
  - Docker Compose 配置 Ollama 服務
  - 下載 qwen2.5:7b 模型（4.4GB）
  - 測試 Ollama API 連線
  - 驗證 JSON 格式輸出

**交付物**：
- 完整的 Docker Compose 環境
- 資料庫 Schema 與遷移腳本
- 前後端專案骨架

#### Week 2: 使用者認證與資料匯入

**目標**：完成基礎認證與匯入功能

**任務清單**：
- [x] JWT 認證 API（登入、登出、取得當前使用者）
- [x] Excel/CSV 匯入預覽與執行 API
- [x] 前端登入頁面與狀態管理
- [x] 前端匯入精靈 UI

**交付物**：
- 認證系統（JWT + bcrypt）
- 資料匯入完整流程

### 5.3 Week 3-4: 報告檢索和 AI 整合

#### Week 3: 報告搜尋與檢視

**目標**：報告檢索與詳情展示

**任務清單**：
- [x] 報告搜尋 API（全文搜尋 + 多條件篩選）
- [x] 報告詳情 API
- [x] 前端搜尋頁面（搜尋列、篩選器、分頁列表）
- [x] 前端報告詳情頁

**交付物**：
- 完整報告搜尋功能
- 報告詳情展示

#### Week 4: AI 整合與測試

**目標**：Ollama 客戶端與單筆分析

**任務清單**：
- [x] Ollama HTTP 客戶端（httpx）
- [x] 單筆 AI 分析 API
- [x] AI 標註儲存與查詢
- [x] 前端 AI 分析觸發 UI
- [x] AI 結果展示元件

**交付物**：
- Ollama 整合完成
- 單筆 AI 分析流程

### 5.4 Week 5-6: AI 分析和專案管理

#### Week 5: 批次分析與提示詞管理

**目標**：批次 AI 分析與提示詞庫

**任務清單**：
- [x] 批次 AI 分析 API（背景任務）
- [x] 6 個預置提示詞模板
- [x] AI 標註管理 API（CRUD）
- [x] 前端批次分析 UI
- [x] 前端提示詞選擇器

**交付物**：
- 批次分析功能
- 提示詞模板庫

#### Week 6: 專案管理

**目標**：專案 CRUD 與報告關聯

**任務清單**：
- [x] 專案 CRUD API
- [x] 報告加入/移除專案 API
- [x] 專案統計 API
- [x] 前端專案列表與詳情頁
- [x] 前端批次加入報告 UI

**交付物**：
- 完整專案管理功能

### 5.5 Week 7: 資料匯出與測試

**目標**：資料匯出與測試最佳化

**任務清單**：
- [x] Excel/CSV/JSON 匯出 API
- [x] 前端匯出對話框 UI
- [ ] 單元測試編寫（覆蓋率 > 70%）
- [ ] 整合測試（核心流程）
- [ ] 效能最佳化（查詢、匯出）

**交付物**：
- 多格式資料匯出
- 測試報告

### 5.6 Week 8: 部署與培訓

**目標**：正式部署與使用者培訓

**任務清單**：
- [ ] 部署腳本與文件
- [ ] 使用者手冊編寫
- [ ] 使用者培訓（2 小時）
- [ ] 錯誤監控與日誌配置
- [ ] 備份與還原機制

**交付物**：
- 部署文件
- 使用者手冊
- 培訓材料

---

## 6. 角色與責任（Roles & Responsibilities）

### 6.1 建議團隊配置（Phase 1 最小團隊）

| 角色 | 人數 | 責任 | 搭配文件 / 工具 |
|------|------|------|----------------|
| **全端開發** | 1-2 人 | 前後端功能實作、API 設計、資料庫設計 | `requirements/`, `architecture/`, Code Repo |
| **AI 工程師** | 1 人（兼職） | Ollama 調優、提示詞工程、模型評估 | Ollama Docs, AI Analysis Module |
| **產品/測試** | 1 人（兼職） | 需求確認、驗收測試、使用者回饋 | `requirements/`, `testing/`, User Manual |

### 6.2 開發流程與協作

**標準開發流程**：
1. **需求定義** → 建立/更新 `requirements/` 文件
2. **技術設計** → 更新 `architecture/` 文件
3. **實作開發** → 功能開發 + 單元測試
4. **整合測試** → 驗證端到端流程
5. **部署上線** → 更新部署文件與使用者手冊

**OpenSpec 整合**：
- 重大變更需建立 OpenSpec proposal（`openspec/changes/`）
- 需求變更需更新追溯矩陣（`traceability/01_TRACEABILITY_MATRIX.md`）
- 定期同步文件與實作狀態

### 6.3 技能要求

**全端開發**：
- React + TypeScript（中級）
- Python + FastAPI（中級）
- PostgreSQL（基礎）
- Docker（基礎）

**AI 工程師**：
- LLM 基礎知識（了解）
- 提示詞工程（Prompt Engineering）
- JSON Schema 設計

---

## 7. 最佳實務（Best Practices）

### 7.1 開發最佳實務

**程式碼品質**：
- Python: 遵守 PEP 8, 使用 ruff/mypy/black
- TypeScript: 遵守 ESLint 規則, 使用 Prettier
- 單元測試覆蓋率 ≥ 70%（核心模組）

**文件維護**：
- 變更程式碼前先更新對應文件（requirements/architecture）
- 重大變更需建立 OpenSpec proposal
- API 變更需同步更新 API 規範（`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` §5）

**追溯性維護**：
- 新增需求時更新追溯矩陣
- 修改需求時識別下游影響（透過追溯矩陣）
- 刪除需求時處理孤立項目

### 7.2 程式碼品質檢查門檻（Quality Gates）

**🚨 重要**: 任何程式碼變更在提交 Review 前，**必須**通過以下品質檢查。

#### Backend (Python) - 在 `backend_django/` 執行

```bash
# 1. 型別檢查 (ty)
uvx ty check <module>

# 2. Linting + 自動修復 (ruff)
uvx ruff check <module> --fix

# 3. 程式碼格式化 (ruff)
uvx ruff format <module>

# 範例：編輯 report 模組後
uvx ty check report
uvx ruff check report --fix
uvx ruff format report
```

#### Frontend (TypeScript/React) - 在 `frontend/` 執行

```bash
# 1. ESLint 檢查
pnpm lint

# 2. TypeScript 型別檢查
npx tsc --noEmit
```

#### 品質檢查工作流

```
編輯程式碼 → 執行品質檢查 → 修復錯誤 → 重新檢查 → 全部通過 ✅ → 提交 Review
                  ↓                              ↑
                錯誤 ❌ ─────────────────────────┘
```

#### 模組對照表

| 模組 | 說明 |
|------|------|
| `common` | 共用工具、中介層、基礎類別 |
| `imports` | 資料匯入功能 |
| `project` | 專案管理 |
| `report` | 報告搜尋與管理 |
| `study` | 檢查/影像操作 |
| `tests` | 測試檔案 |

#### 快速檢查全部 Backend

```bash
for module in common imports project report study; do
  echo "=== Checking $module ==="
  uvx ty check $module
  uvx ruff check $module --fix
  uvx ruff format $module
done
```

#### 快速檢查 Frontend

```bash
cd frontend && pnpm lint && npx tsc --noEmit
```

### 7.3 常見錯誤與避免方式

| 常見錯誤 | 避免方式 |
|---------|---------|
| 只改 code 沒更新 docs/spec | 在 PR 前檢查文件更新，使用 checklist |
| API 回應格式不一致 | 定義 Pydantic Schema，嚴格驗證 |
| 追溯關係未維護 | 每次需求變更時同步更新追溯矩陣 |
| 測試覆蓋不足 | 每個 PR 需包含測試，CI 檢查覆蓋率 |
| 敏感資訊洩漏於日誌 | 日誌中不記錄患者個資與報告全文 |
| 未通過 Quality Gates | 每次程式碼變更前執行 §7.2 品質檢查 |

### 7.4 AI 協作模式

**使用 AI 代理時**：
- 提供完整的專案背景（本文件）
- 明確指定需求文件位置（`requirements/01_SYSTEM_PRD_SR_SD.md`）
- 要求 AI 更新追溯矩陣（`traceability/01_TRACEABILITY_MATRIX.md`）
- 驗證 AI 生成的程式碼符合專案規範

---

## 8. 相關文件與連結（Related Documents & Links）

### 8.1 核心文件

| 文件 | 用途 | 位置 |
|------|------|------|
| **專案索引** | 文件導覽 | [`00_IMAGE_DATA_PLATFORM_INDEX.md`](../00_IMAGE_DATA_PLATFORM_INDEX.md) |
| **系統需求** | UR/SYS-PRD/SYS-SR/NFR | [`requirements/01_SYSTEM_PRD_SR_SD.md`](../requirements/01_SYSTEM_PRD_SR_SD.md) |
| **系統架構** | 架構/DB/API 設計 | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) |
| **追溯矩陣** | 需求追溯 | [`traceability/01_TRACEABILITY_MATRIX.md`](../traceability/01_TRACEABILITY_MATRIX.md) |
| **OpenSpec 整合** | 規格管理流程 | [`openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md`](../openspec-integration/01_OPENSPEC_INTEGRATION_GUIDE.md) |

### 8.2 舊文件參考（已廢止）

| 舊文件 | 新位置 | 狀態 |
|--------|--------|------|
| `docs/old/01_PROJECT_OVERVIEW.md` | 本文件 §2-3 | ⚠️ Deprecated |
| `docs/old/workflow/05_DEVELOPMENT_WORKFLOW.md` | 本文件 §5 | ⚠️ Deprecated |
| `docs/old/requirements/USER_REQUIREMENTS.md` | [`requirements/01_SYSTEM_PRD_SR_SD.md`](../requirements/01_SYSTEM_PRD_SR_SD.md) §3 | ⚠️ Deprecated |
| `docs/old/architecture/FRONTEND_BACKEND_INTEGRATION.md` | [`architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md`](../architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md) | ⚠️ Deprecated |

---

## 9. 附錄（Appendix）

### 9.1 Phase 1 里程碑（Milestones）

| 里程碑 | 日期 | 關鍵交付物 | 狀態 |
|--------|------|-----------|------|
| M1: 環境搭建完成 | Week 1 | Docker 環境、資料庫 Schema | ✅ |
| M2: 認證與匯入 | Week 2 | JWT 認證、Excel 匯入 | ✅ |
| M3: 搜尋與檢視 | Week 3 | 報告搜尋、詳情展示 | ✅ |
| M4: AI 整合 | Week 4 | Ollama 整合、單筆分析 | ✅ |
| M5: 批次分析 | Week 5 | 批次分析、提示詞庫 | 🔄 |
| M6: 專案管理 | Week 6 | 專案 CRUD、報告關聯 | ⏸️ |
| M7: 匯出與測試 | Week 7 | 資料匯出、測試報告 | ⏸️ |
| M8: 部署上線 | Week 8 | 部署文件、使用者培訓 | ⏸️ |

### 9.2 成功標準（Success Criteria）

**功能完整性**：
- ✅ 匯入 10,000+ 筆歷史報告資料
- ✅ 全文搜尋和多維篩選可用
- 🔄 AI 分析準確率 > 80%（人工抽查 100 份）
- ⏸️ 建立和管理至少 3 個研究專案
- ⏸️ 匯出篩選清單用於 PACS 下載

**使用者滿意度**：
- 資料匯入流程 ≤ 5 步
- 報告搜尋到標註 ≤ 3 次點擊
- AI 分析結果可理解和可信任
- 使用者培訓時間 ≤ 2 小時

**技術指標**：
- 單元測試覆蓋率 > 70%
- 核心 API 響應時間 < 2 秒
- 系統穩定執行 > 7 天無重啟
- Docker 部署成功率 100%

### 9.3 相關連結

- [PostgreSQL 官方文件](https://www.postgresql.org/docs/14/)
- [FastAPI 官方文件](https://fastapi.tiangolo.com/)
- [Ollama 官方文件](https://github.com/ollama/ollama)
- [Ant Design 5 文件](https://ant.design/components/overview-cn/)
- [React Router v6 文件](https://reactrouter.com/en/main)

---

**維護說明**：本指南應隨專案進展持續更新。每個 Phase 或重大里程碑完成後，應更新對應章節與附錄狀態。
