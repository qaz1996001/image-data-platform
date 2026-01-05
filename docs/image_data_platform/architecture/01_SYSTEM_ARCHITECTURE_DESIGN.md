# image_data_platform 系統架構設計（System Architecture Design）

> 本文件為 image_data_platform 專案在新文檔結構下的**系統架構與設計主文件**，  
> 後續將整合 `docs/old/architecture/`、`database/`、`api/` 中仍有效的內容。
>
> 範本結構來源：`templates/TEMPLATE_ARCHITECTURE_SYSTEM_DESIGN.md`。

---

**文件 ID**: IDP-ARCH-SYS-IMG-001  
**標題**: image_data_platform — 系統架構設計（Phase 1 完整版）  
**版本**: v1.1.0-Phase1  
**狀態**: Active  
**建立日期**: 2024-12-01  
**最後更新**: 2026-01-05
**作者**: AI 代理 + 需求整合團隊
**審核人**: [架構負責人 / 技術負責人]  
**來源**: 整合自 `docs/old/architecture/`, `database/`, `api/`  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v1.1.0 | 2026-01-05 | AI 代理 | 新增 imports 模組說明；更新後端技術架構（Django 4.2 + Django Ninja）；新增 §4.6 imports 表結構 |
| v1.0.0 | 2025-12-26 | AI 代理 | 整合 `docs/old/architecture/`, `database/`, `api/` 完整內容<br/>- 新增第 4.3 節：資料庫初始化腳本<br/>- 新增第 4.4 節：常用查詢範例<br/>- 新增第 5.4 節：API 客戶端範例 (Python/TS/curl)<br/>- 新增第 8 節：前端狀態管理與互動<br/>- 新增第 10 節：部署架構與環境配置 |
| v0.1 | 2024-12-01 | [姓名] | 從模板建立，準備整合 docs/old 架構 / DB / API 文檔 |

---

## 1. 架構概覽（Architecture Overview）

### 1.1 系統背景與目標

image_data_platform Phase 1 採用簡化但可擴充的三層結構：前端 Web、後端 API、資料庫與 AI 服務，  
聚焦於「報告資料 + AI 標註 + 專案管理」，為後續影像管理與整合（Phase 2）預留空間。

### 1.2 高階架構

- **Frontend (React + TypeScript)**
  - 使用 Ant Design 作為主要 UI 元件庫。
  - 透過 REST API 與後端互動，提供報告搜尋、AI 分析與專案管理介面。
- **Backend API（Django 4.2 + Django Ninja）**
  - 提供認證、報告管理、AI 分析、專案管理與匯出等 API。
  - 對接 PostgreSQL 資料庫與 Ollama 服務。
  - 模組化架構：`common`, `imports`, `project`, `report`, `study`。
- **Database（PostgreSQL 14+）**
  - 採用 6 張核心表：`users`、`reports`、`ai_annotations`、`projects`、`project_reports`、`import_tasks`。
  - 使用 JSONB 與全文索引支援靈活 AI 結構化資料與快速搜尋。
- **AI Engine（Ollama）**
  - 部署 qwen2.5:7b 等模型於院內環境。
  - 透過 HTTP API 提供單筆與批次報告分析能力。

### 1.3 架構風格與技術選型（Phase 1）

- Web API 採 RESTful 風格，未來可逐步補充事件通知 / WebSocket。
- 後端採分層設計（API / Service / Repository），利於將來遷移至 Django 或其他框架。
- 資料庫以關聯式模型為主，配合 JSONB 儲存彈性 AI 結果與標註。

---

## 2. 子系統與元件分解（Subsystem and Component Decomposition）

| 子系統           | 職責描述                               | 對應需求 (SYS-SR) | 備註 |
|------------------|----------------------------------------|--------------------|------|
| Ingestion        | 匯入 Excel/CSV 報告並執行欄位映射與驗證 | SYS-SR-匯入相關     | 對應 `imports` 模組 (backend_django/imports/) |
| Storage          | 以結構化方式儲存報告、AI 標註與專案關聯 | SYS-SR-儲存與查詢   | 對應 `reports` / `ai_annotations` / `projects` 等表 |
| Search & Filter  | 提供全文搜尋與多條件篩選              | SYS-SR-搜尋相關     | 使用 PostgreSQL GIN 全文索引 |
| AI Analysis      | 對接 Ollama 執行單筆 / 批次 AI 分析    | SYS-SR-AI 功能      | 對應 AI 模組與標註儲存 |
| Project Manager  | 管理專案與報告集合                    | SYS-SR-專案管理     | 支援報告加入 / 移除 / 匯出 |
| Export           | 將搜尋結果或專案報告匯出為 Excel/CSV/JSON | SYS-SR-匯出         | 配合後續 PACS 下載流程 |

---

## 3. 資料流與控制流（Data Flow & Control Flow）

### 3.1 典型業務流程

#### 流程 1: 報告匯入與搜尋
```
1. 研究人員上傳 Excel/CSV 檔案
   ↓
2. 前端呼叫 POST /api/v1/import/preview
   → 後端解析檔案，回傳欄位清單與預覽資料
   ↓
3. 研究人員確認欄位映射
   ↓
4. 前端呼叫 POST /api/v1/import/execute
   → 後端批次寫入 reports 表 (500-1000 筆/批)
   ↓
5. 匯入完成，研究人員進入搜尋頁面
   ↓
6. 前端呼叫 GET /api/v1/reports/search?q=關鍵字&exam_type=CT
   → 後端透過 PostgreSQL 全文索引查詢
   → 回傳分頁結果 (20 筆/頁)
   ↓
7. 前端渲染搜尋結果列表
```

#### 流程 2: AI 報告分析
```
1. 研究人員在報告詳情頁點擊「AI 分析」
   ↓
2. 前端呼叫 POST /api/v1/ai/analyze
   { report_id: 123, prompt: "找出肺部病灶", type: "extraction" }
   ↓
3. 後端提取報告內容，構建提示詞
   ↓
4. 後端呼叫 Ollama API (HTTP POST http://ollama:11434/api/generate)
   → Ollama 以 qwen2.5:7b 模型生成結構化結果 (5-10 秒)
   ↓
5. 後端解析 JSON 輸出，寫入 ai_annotations 表
   ↓
6. 後端回傳 AI 標註結果給前端
   ↓
7. 前端渲染 AI 標註 (高亮顯示、分類標籤、提取資訊等)
```

#### 流程 3: 專案管理與匯出
```
1. 研究人員建立專案「肺炎研究 2024」
   → POST /api/v1/projects { name, description, tags }
   ↓
2. 從搜尋結果批次選擇報告
   ↓
3. 前端呼叫 POST /api/v1/projects/{id}/reports
   { report_ids: [101, 102, 103, ...] }
   → 後端批次寫入 project_reports 關聯表
   ↓
4. 研究人員進入專案詳情頁，查看報告列表
   ↓
5. 點擊「匯出 Excel」
   → POST /api/v1/projects/{id}/export { format: "excel", include_ai: true }
   → 後端查詢專案報告 + AI 標註
   → 以 openpyxl 生成 Excel 檔案
   ↓
6. 前端下載 Excel 檔案 (供 PACS 下載清單使用)
```

### 3.2 系統互動序列圖

#### 認證流程
```
User → Frontend → Backend → Database
 │        │          │          │
 │ 輸入帳密 │          │          │
 ├────────>│          │          │
 │        │ POST /auth/login     │
 │        ├─────────>│          │
 │        │          │ 查詢 users│
 │        │          ├─────────>│
 │        │          │<─────────┤
 │        │          │ 驗證密碼 │
 │        │<─────────┤ 生成 JWT │
 │<────────┤ 儲存 token│          │
 │ 登入成功 │          │          │
```

#### AI 分析流程
```
Frontend → Backend → Database → Ollama
   │         │          │          │
   │ POST /ai/analyze   │          │
   ├────────>│          │          │
   │         │ SELECT reports      │
   │         ├─────────>│          │
   │         │<─────────┤          │
   │         │ 構建提示詞│          │
   │         │ POST /api/generate  │
   │         ├────────────────────>│
   │         │          │ 模型推理 │
   │         │<────────────────────┤
   │         │ 解析 JSON│          │
   │         │ INSERT ai_annotations│
   │         ├─────────>│          │
   │         │<─────────┤          │
   │<────────┤ 回傳結果 │          │
   │ 渲染標註 │          │          │
```

---

## 4. 資料模型設計（Data Model Design）

> 本節整合自 `docs/old/database/03_DATABASE_DESIGN.md`

Phase 1 採用 **6 張核心表**，聚焦於報告資料、AI 標註、專案管理與資料匯入：

### 4.1 ER 關係圖

```
┌─────────────┐
│   users     │
│  (使用者表)  │
│   簡化認證   │
└──────┬──────┘
       │ 1:N (created_by, imported_by)
       │
       ├──────────────────┐
       ↓                  ↓
┌─────────────┐    ┌─────────────┐
│   reports   │    │  projects   │
│  (報告表)    │    │  (專案表)    │
│ 檢查報告資料 │    │  資料組織    │
└──────┬──────┘    └──────┬──────┘
       │ 1:N               │ N:M
       │                   │
       ↓                   ↓
┌──────────────┐    ┌─────────────────┐
│ai_annotations│    │ project_reports │
│ (AI標記表)    │    │ (專案-報告關聯)  │
│ AI分析結果    │    │  多對多中間表   │
└──────────────┘    └─────────────────┘
```

### 4.2 表結構定義

#### 表 1: users (使用者表)

**用途**: 簡化的使用者認證與基本權限管理

| 欄位 | 類型 | 說明 | 約束 |
|------|------|------|------|
| id | SERIAL | 主鍵 | PRIMARY KEY |
| email | VARCHAR(100) | 電子郵件 | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | 密碼雜湊 (bcrypt) | NOT NULL |
| full_name | VARCHAR(100) | 全名 | |
| role | VARCHAR(20) | 角色 | CHECK IN ('admin', 'researcher'), DEFAULT 'researcher' |
| is_active | BOOLEAN | 帳號啟用 | DEFAULT true |
| last_login_at | TIMESTAMP | 最後登入時間 | |
| created_at | TIMESTAMP | 建立時間 | DEFAULT CURRENT_TIMESTAMP |
| updated_at | TIMESTAMP | 更新時間 | DEFAULT CURRENT_TIMESTAMP |

**索引**:
- `idx_users_email` ON email WHERE is_active = true
- `idx_users_role` ON role

**設計決策**:
- ✅ Phase 1 簡化為 2 種角色 (admin / researcher)
- ✅ 使用 bcrypt 加密密碼 (成本因子 12)
- ❌ 不支援多設備會話管理 (Phase 2)
- ❌ 不支援 SSO / LDAP 整合 (Phase 2)

---

#### 表 2: reports (報告表)

**用途**: 儲存檢查報告資料與患者基本資訊

| 欄位 | 類型 | 說明 | 約束 |
|------|------|------|------|
| id | SERIAL | 主鍵 | PRIMARY KEY |
| patient_id | VARCHAR(50) | 患者 ID | NOT NULL |
| patient_name | VARCHAR(100) | 患者姓名 | |
| patient_age | INTEGER | 患者年齡 | |
| patient_gender | VARCHAR(10) | 患者性別 | CHECK IN ('M', 'F', 'Other', 'Unknown') |
| exam_date | DATE | 檢查日期 | NOT NULL |
| exam_type | VARCHAR(50) | 檢查類型 (CT/MRI/X-ray) | NOT NULL |
| exam_description | TEXT | 檢查描述 | |
| department | VARCHAR(100) | 科別 | |
| report_content | TEXT | 完整報告內容 | NOT NULL |
| findings | TEXT | 發現 (Findings) | |
| diagnosis | TEXT | 診斷 (Diagnosis) | |
| impression | TEXT | 結論 (Impression) | |
| icd_codes | JSONB | ICD 編碼 | |
| source | VARCHAR(50) | 資料來源 | DEFAULT 'import' |
| source_reference | VARCHAR(200) | 原始來源參考 | |
| imported_by | INTEGER | 匯入者 | FK → users(id) |
| imported_at | TIMESTAMP | 匯入時間 | |
| created_at | TIMESTAMP | 建立時間 | DEFAULT CURRENT_TIMESTAMP |
| updated_at | TIMESTAMP | 更新時間 | DEFAULT CURRENT_TIMESTAMP |
| is_deleted | BOOLEAN | 軟刪除標記 | DEFAULT false |
| deleted_at | TIMESTAMP | 刪除時間 | |

**索引**:
- `idx_reports_patient_id` ON patient_id WHERE is_deleted = false
- `idx_reports_exam_date` ON exam_date DESC WHERE is_deleted = false
- `idx_reports_exam_type` ON exam_type WHERE is_deleted = false
- `idx_reports_content_fulltext` GIN (to_tsvector('simple', report_content))
- `idx_reports_patient_name_fulltext` GIN (to_tsvector('simple', patient_name))
- `idx_reports_exam_date_type` ON (exam_date DESC, exam_type)

**設計決策**:
- ✅ 患者資訊直接嵌入 (不需單獨 patients 表)
- ✅ 使用 PostgreSQL 全文索引 (GIN) 支援快速關鍵字搜尋
- ✅ 軟刪除機制 (is_deleted 欄位)
- ❌ 不儲存 DICOM 影像引用 (Phase 2)

---

#### 表 3: ai_annotations (AI 標記表)

**用途**: 儲存 Ollama AI 對報告的分析與標記結果

| 欄位 | 類型 | 說明 | 約束 |
|------|------|------|------|
| id | SERIAL | 主鍵 | PRIMARY KEY |
| report_id | INTEGER | 報告 ID | NOT NULL, FK → reports(id) ON DELETE CASCADE |
| user_prompt | TEXT | 使用者提示詞 | NOT NULL |
| annotation_type | VARCHAR(50) | 標記類型 | CHECK IN ('highlight', 'classification', 'extraction', 'scoring', 'custom') |
| content | JSONB | AI 分析結果 (JSON 格式) | NOT NULL |
| confidence | DECIMAL(3, 2) | 置信度 (0-1) | CHECK >= 0 AND <= 1 |
| raw_response | TEXT | 原始 LLM 響應 (調試用) | |
| model_name | VARCHAR(50) | 模型名稱 | DEFAULT 'qwen2.5:7b' |
| model_temperature | DECIMAL(3, 2) | 溫度參數 | DEFAULT 0.7 |
| is_edited | BOOLEAN | 是否被使用者編輯 | DEFAULT false |
| edited_at | TIMESTAMP | 編輯時間 | |
| created_by | INTEGER | 建立者 | FK → users(id) |
| created_at | TIMESTAMP | 建立時間 | DEFAULT CURRENT_TIMESTAMP |
| updated_at | TIMESTAMP | 更新時間 | DEFAULT CURRENT_TIMESTAMP |

**索引**:
- `idx_ai_annotations_report` ON report_id
- `idx_ai_annotations_type` ON annotation_type
- `idx_ai_annotations_created` ON created_at DESC
- `idx_ai_annotations_content_gin` GIN (content) — 支援 JSONB 查詢

**content 欄位 JSON Schema 範例**:

```json
// highlight 類型
{
  "highlights": [
    { "text": "雙肺紋理增多", "start": 15, "end": 22, "reason": "關鍵發現" }
  ]
}

// classification 類型
{
  "category": "normal",
  "confidence": 0.92,
  "reasoning": "未見明顯實質性病變"
}

// extraction 類型
{
  "findings": ["肺紋理增多", "心影不大"],
  "measurements": [{ "item": "心胸比", "value": "0.45" }]
}

// scoring 類型
{
  "score": 3,
  "scale": "1-5",
  "criteria": "嚴重程度評分"
}
```

---

#### 表 4: projects (專案表)

**用途**: 管理研究專案與報告集合

| 欄位 | 類型 | 說明 | 約束 |
|------|------|------|------|
| id | SERIAL | 主鍵 | PRIMARY KEY |
| name | VARCHAR(200) | 專案名稱 | NOT NULL |
| description | TEXT | 專案描述 | |
| tags | JSONB | 標籤 | DEFAULT '[]'::jsonb |
| status | VARCHAR(20) | 狀態 | CHECK IN ('active', 'archived', 'completed'), DEFAULT 'active' |
| created_by | INTEGER | 建立者 | NOT NULL, FK → users(id) |
| created_at | TIMESTAMP | 建立時間 | DEFAULT CURRENT_TIMESTAMP |
| updated_at | TIMESTAMP | 更新時間 | DEFAULT CURRENT_TIMESTAMP |

**索引**:
- `idx_projects_created_by` ON created_by
- `idx_projects_status` ON status WHERE status != 'archived'
- `idx_projects_name_fulltext` GIN (to_tsvector('simple', name))

---

#### 表 5: project_reports (專案-報告關聯表)

**用途**: 多對多關聯，記錄報告被加入到哪些專案

| 欄位 | 類型 | 說明 | 約束 |
|------|------|------|------|
| project_id | INTEGER | 專案 ID | NOT NULL, FK → projects(id) ON DELETE CASCADE |
| report_id | INTEGER | 報告 ID | NOT NULL, FK → reports(id) ON DELETE CASCADE |
| added_by | INTEGER | 加入者 | FK → users(id) |
| added_at | TIMESTAMP | 加入時間 | DEFAULT CURRENT_TIMESTAMP |
| notes | TEXT | 備註 | |

**約束**:
- PRIMARY KEY (project_id, report_id) — 唯一約束

**索引**:
- `idx_project_reports_report` ON report_id
- `idx_project_reports_added_at` ON added_at DESC
- `idx_project_reports_project_added` ON (project_id, added_at DESC)

---

#### 表 6: import_tasks (資料匯入任務表)

**用途**: 追蹤資料匯入任務狀態與進度

> 新增於 v1.1.0，對應 `backend_django/imports/` 模組

| 欄位 | 類型 | 說明 | 約束 |
|------|------|------|------|
| id | SERIAL | 主鍵 | PRIMARY KEY |
| file_name | VARCHAR(255) | 原始檔案名稱 | NOT NULL |
| file_size | INTEGER | 檔案大小 (bytes) | |
| status | VARCHAR(20) | 匯入狀態 | CHECK IN ('pending', 'processing', 'completed', 'failed'), DEFAULT 'pending' |
| total_rows | INTEGER | 總列數 | |
| processed_rows | INTEGER | 已處理列數 | DEFAULT 0 |
| success_rows | INTEGER | 成功匯入列數 | DEFAULT 0 |
| error_rows | INTEGER | 錯誤列數 | DEFAULT 0 |
| error_details | JSONB | 錯誤詳情 | DEFAULT '[]'::jsonb |
| field_mapping | JSONB | 欄位映射配置 | |
| created_by | INTEGER | 建立者 | FK → users(id) |
| created_at | TIMESTAMP | 建立時間 | DEFAULT CURRENT_TIMESTAMP |
| started_at | TIMESTAMP | 開始處理時間 | |
| completed_at | TIMESTAMP | 完成時間 | |

**索引**:
- `idx_import_tasks_status` ON status
- `idx_import_tasks_created_by` ON created_by
- `idx_import_tasks_created_at` ON created_at DESC

**對應模組**:
- `imports/models.py` - ImportTask model
- `imports/api.py` - 匯入預覽、執行 API
- `imports/services.py` - 匯入業務邏輯
- `imports/parsers.py` - Excel/CSV 解析器

---

### 4.3 資料庫初始化腳本

> 完整 DDL 來源：`docs/old/database/03_DATABASE_DESIGN.md`

```sql
-- =====================================================
-- Phase 1 資料庫初始化腳本
-- image_data_platform - AI 輔助報告篩選系統
-- =====================================================

-- 啟用 UUID 擴充功能（如需要）
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. 通用觸發器函數
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. 建立表
-- =====================================================

-- 2.1 使用者表
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'researcher' CHECK (role IN ('admin', 'researcher')),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email) WHERE is_active = true;
CREATE INDEX idx_users_role ON users(role);

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 2.2 報告表
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL,
    patient_name VARCHAR(100),
    patient_age INTEGER,
    patient_gender VARCHAR(10) CHECK (patient_gender IN ('M', 'F', 'Other', 'Unknown')),
    exam_date DATE NOT NULL,
    exam_type VARCHAR(50) NOT NULL,
    exam_description TEXT,
    department VARCHAR(100),
    report_content TEXT NOT NULL,
    findings TEXT,
    diagnosis TEXT,
    impression TEXT,
    icd_codes JSONB,
    source VARCHAR(50) DEFAULT 'import',
    source_reference VARCHAR(200),
    imported_by INTEGER REFERENCES users(id),
    imported_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_reports_patient_id ON reports(patient_id) WHERE is_deleted = false;
CREATE INDEX idx_reports_patient_name ON reports(patient_name) WHERE is_deleted = false;
CREATE INDEX idx_reports_exam_date ON reports(exam_date DESC) WHERE is_deleted = false;
CREATE INDEX idx_reports_exam_type ON reports(exam_type) WHERE is_deleted = false;
CREATE INDEX idx_reports_department ON reports(department) WHERE is_deleted = false;
CREATE INDEX idx_reports_content_fulltext ON reports USING gin(to_tsvector('simple', report_content)) WHERE is_deleted = false;
CREATE INDEX idx_reports_patient_name_fulltext ON reports USING gin(to_tsvector('simple', patient_name)) WHERE is_deleted = false;
CREATE INDEX idx_reports_exam_date_type ON reports(exam_date DESC, exam_type) WHERE is_deleted = false;

CREATE TRIGGER update_reports_updated_at
    BEFORE UPDATE ON reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 2.3 AI 標記表
CREATE TABLE ai_annotations (
    id SERIAL PRIMARY KEY,
    report_id INTEGER NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    user_prompt TEXT NOT NULL,
    annotation_type VARCHAR(50) NOT NULL CHECK (
        annotation_type IN ('highlight', 'classification', 'extraction', 'scoring', 'custom')
    ),
    content JSONB NOT NULL,
    confidence DECIMAL(3, 2) CHECK (confidence >= 0 AND confidence <= 1),
    raw_response TEXT,
    model_name VARCHAR(50) DEFAULT 'qwen2.5:7b',
    model_temperature DECIMAL(3, 2) DEFAULT 0.7,
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP WITH TIME ZONE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_annotations_report ON ai_annotations(report_id);
CREATE INDEX idx_ai_annotations_type ON ai_annotations(annotation_type);
CREATE INDEX idx_ai_annotations_created ON ai_annotations(created_at DESC);
CREATE INDEX idx_ai_annotations_content_gin ON ai_annotations USING gin(content);

CREATE TRIGGER update_ai_annotations_updated_at
    BEFORE UPDATE ON ai_annotations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 2.4 專案表
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    tags JSONB DEFAULT '[]'::jsonb,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived', 'completed')),
    created_by INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_project_name_length CHECK (LENGTH(name) >= 2)
);

CREATE INDEX idx_projects_created_by ON projects(created_by) WHERE is_deleted = false;
CREATE INDEX idx_projects_status ON projects(status) WHERE is_deleted = false;
CREATE INDEX idx_projects_created_at ON projects(created_at DESC) WHERE is_deleted = false;
CREATE INDEX idx_projects_name ON projects(name) WHERE is_deleted = false;
CREATE INDEX idx_projects_tags_gin ON projects USING gin(tags);

CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 2.5 專案-報告關聯表
CREATE TABLE project_reports (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    report_id INTEGER NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    added_by INTEGER REFERENCES users(id),
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT uq_project_report UNIQUE (project_id, report_id)
);

CREATE INDEX idx_project_reports_project ON project_reports(project_id);
CREATE INDEX idx_project_reports_report ON project_reports(report_id);
CREATE INDEX idx_project_reports_added_at ON project_reports(added_at DESC);
CREATE INDEX idx_project_reports_project_added ON project_reports(project_id, added_at DESC);

-- =====================================================
-- 3. 初始資料
-- =====================================================

-- 建立預設管理員帳號（密碼: Admin@123456, bcrypt hash）
INSERT INTO users (email, password_hash, full_name, role) VALUES
('admin@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIpVO7fUOu', '系統管理員', 'admin');

-- =====================================================
-- 4. 視圖（Views）
-- =====================================================

-- 報告統計視圖
CREATE OR REPLACE VIEW v_report_statistics AS
SELECT
    COUNT(*) as total_reports,
    COUNT(DISTINCT patient_id) as unique_patients,
    COUNT(DISTINCT exam_type) as exam_types,
    MIN(exam_date) as earliest_exam,
    MAX(exam_date) as latest_exam
FROM reports
WHERE is_deleted = false;

-- 專案統計視圖
CREATE OR REPLACE VIEW v_project_statistics AS
SELECT
    p.id as project_id,
    p.name as project_name,
    p.status,
    COUNT(pr.report_id) as report_count,
    COUNT(DISTINCT r.patient_id) as patient_count,
    MAX(pr.added_at) as last_updated
FROM projects p
LEFT JOIN project_reports pr ON p.id = pr.project_id
LEFT JOIN reports r ON pr.report_id = r.id
WHERE p.is_deleted = false AND (r.is_deleted = false OR r.id IS NULL)
GROUP BY p.id, p.name, p.status;

-- AI 標記統計視圖
CREATE OR REPLACE VIEW v_ai_annotation_statistics AS
SELECT
    annotation_type,
    COUNT(*) as annotation_count,
    COUNT(DISTINCT report_id) as annotated_reports,
    AVG(confidence) as avg_confidence
FROM ai_annotations
GROUP BY annotation_type;

-- =====================================================
-- 5. 完成訊息
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Phase 1 資料庫初始化完成';
    RAISE NOTICE '📊 建立了 5 張核心表: users, reports, ai_annotations, projects, project_reports';
    RAISE NOTICE '🔑 建立了預設管理員帳號: admin@example.com / Admin@123456';
    RAISE NOTICE '📈 建立了 3 個統計視圖: v_report_statistics, v_project_statistics, v_ai_annotation_statistics';
END $$;
```

### 4.4 常用查詢範例

> 來源：`docs/old/database/03_DATABASE_DESIGN.md`

#### 報告搜尋查詢
```sql
-- 全文搜尋報告內容 (使用 GIN 全文索引)
SELECT
    id,
    patient_id,
    patient_name,
    exam_date,
    exam_type,
    ts_rank(to_tsvector('simple', report_content), to_tsquery('simple', '肺部 & 異常')) as rank
FROM reports
WHERE
    to_tsvector('simple', report_content) @@ to_tsquery('simple', '肺部 & 異常')
    AND is_deleted = false
ORDER BY rank DESC, exam_date DESC
LIMIT 50;

-- 多條件組合查詢
SELECT *
FROM reports
WHERE
    is_deleted = false
    AND exam_date BETWEEN '2024-01-01' AND '2024-12-31'
    AND exam_type = 'CT'
    AND department = '放射科'
    AND (patient_name LIKE '%張%' OR patient_id LIKE '%123%')
ORDER BY exam_date DESC;
```

#### AI 標記相關查詢
```sql
-- 取得報告的所有 AI 標記
SELECT
    a.id,
    a.annotation_type,
    a.user_prompt,
    a.content,
    a.confidence,
    a.created_at,
    u.full_name as annotated_by
FROM ai_annotations a
LEFT JOIN users u ON a.created_by = u.id
WHERE a.report_id = 123
ORDER BY a.created_at DESC;

-- 查找被分類為「異常」的報告
SELECT DISTINCT r.*
FROM reports r
JOIN ai_annotations a ON r.id = a.report_id
WHERE
    a.annotation_type = 'classification'
    AND a.content->>'category' = 'abnormal'
    AND r.is_deleted = false;

-- AI 標記統計
SELECT
    annotation_type,
    COUNT(*) as count,
    AVG(confidence) as avg_confidence,
    MIN(created_at) as first_annotation,
    MAX(created_at) as last_annotation
FROM ai_annotations
GROUP BY annotation_type;
```

#### 專案管理查詢
```sql
-- 取得專案詳情與報告列表
SELECT
    p.id as project_id,
    p.name as project_name,
    r.id as report_id,
    r.patient_id,
    r.patient_name,
    r.exam_date,
    r.exam_type,
    pr.added_at
FROM projects p
JOIN project_reports pr ON p.id = pr.project_id
JOIN reports r ON pr.report_id = r.id
WHERE
    p.id = 1
    AND p.is_deleted = false
    AND r.is_deleted = false
ORDER BY pr.added_at DESC;

-- 專案報告數量統計
SELECT
    p.id,
    p.name,
    COUNT(pr.report_id) as report_count,
    COUNT(DISTINCT r.patient_id) as patient_count
FROM projects p
LEFT JOIN project_reports pr ON p.id = pr.project_id
LEFT JOIN reports r ON pr.report_id = r.id AND r.is_deleted = false
WHERE p.is_deleted = false
GROUP BY p.id, p.name;
```

#### 資料統計查詢
```sql
-- 總體資料統計
SELECT
    (SELECT COUNT(*) FROM reports WHERE is_deleted = false) as total_reports,
    (SELECT COUNT(DISTINCT patient_id) FROM reports WHERE is_deleted = false) as unique_patients,
    (SELECT COUNT(*) FROM ai_annotations) as total_annotations,
    (SELECT COUNT(*) FROM projects WHERE is_deleted = false) as total_projects;

-- 按檢查類型統計
SELECT
    exam_type,
    COUNT(*) as count,
    COUNT(DISTINCT patient_id) as unique_patients
FROM reports
WHERE is_deleted = false
GROUP BY exam_type
ORDER BY count DESC;

-- 按月份統計報告數量
SELECT
    DATE_TRUNC('month', exam_date) as month,
    COUNT(*) as report_count
FROM reports
WHERE is_deleted = false AND exam_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', exam_date)
ORDER BY month;
```

---

## 5. 介面設計（Interface Design）

> 本節整合自 `docs/old/api/04_API_SPECIFICATION.md` 與 `docs/old/architecture/FRONTEND_BACKEND_INTEGRATION.md`

### 5.1 API 設計原則

1. **RESTful 風格**: 資源導向，使用標準 HTTP 方法 (GET/POST/PUT/DELETE)
2. **版本控制**: 所有 API 統一前綴 `/api/v1/`
3. **統一響應格式**: 成功回傳資源物件，錯誤回傳 `{ "detail": "..." }`
4. **JWT 認證**: 使用 Bearer Token，會話時效 30 分鐘
5. **分頁標準**: 使用 `page` (從 1 開始) 與 `page_size` (預設 20, 最大 100)
6. **時間格式**: ISO 8601 (YYYY-MM-DDTHH:mm:ss.sssZ)

### 5.2 API 端點清單

#### 模組 1: 認證 (Authentication)

| 方法 | 路徑 | 說明 | 權限 | 請求 | 響應 |
|------|------|------|------|------|------|
| POST | `/api/v1/auth/login` | 使用者登入 | 公開 | `{ username, password }` (form) | `{ access_token, token_type, user }` |
| GET | `/api/v1/auth/me` | 取得當前使用者 | 需認證 | - | `UserDetail` |
| POST | `/api/v1/auth/logout` | 登出 (客戶端清除 token) | 需認證 | - | `{ message }` |

**範例: 登入請求**
```http
POST /api/v1/auth/login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=researcher@example.com&password=SecurePass123
```

**響應**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "researcher@example.com",
    "full_name": "張三",
    "role": "researcher"
  }
}
```

---

#### 模組 2: 資料匯入 (Import)

| 方法 | 路徑 | 說明 | 權限 | 請求 | 響應 |
|------|------|------|------|------|------|
| POST | `/api/v1/import/preview` | 預覽匯入資料 | researcher | Excel/CSV 檔案 (multipart/form-data) | `{ preview_data, column_mappings }` |
| POST | `/api/v1/import/execute` | 執行匯入 | researcher | `{ file, field_mapping }` | `{ success_count, skipped_count, errors }` |

**範例: 匯入預覽**
```http
POST /api/v1/import/preview HTTP/1.1
Authorization: Bearer {token}
Content-Type: multipart/form-data; boundary=---Boundary

-----Boundary
Content-Disposition: form-data; name="file"; filename="reports.xlsx"
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

[Binary Excel Data]
-----Boundary--
```

**響應**
```json
{
  "preview_data": [
    { "患者ID": "P001", "姓名": "王五", "檢查日期": "2024-11-30", ... },
    { "患者ID": "P002", "姓名": "李四", "檢查日期": "2024-11-29", ... }
  ],
  "column_mappings": {
    "suggested": {
      "患者ID": "patient_id",
      "姓名": "patient_name",
      "檢查日期": "exam_date"
    }
  },
  "row_count": 150
}
```

---

#### 模組 3: 報告管理 (Reports)

| 方法 | 路徑 | 說明 | 權限 | 查詢參數 / 請求體 | 響應 |
|------|------|------|------|-------------------|------|
| GET | `/api/v1/reports/search` | 搜尋報告 | researcher | `q, exam_type, start_date, end_date, page, page_size` | `PaginatedResponse<Report>` |
| GET | `/api/v1/reports/{id}` | 取得報告詳情 | researcher | - | `ReportDetail` |
| POST | `/api/v1/reports` | 新增報告 | researcher | `CreateReportRequest` | `Report` |
| PUT | `/api/v1/reports/{id}` | 更新報告 | researcher | `UpdateReportRequest` | `Report` |
| DELETE | `/api/v1/reports/{id}` | 刪除報告 (軟刪除) | admin | - | `{ message }` |

**範例: 搜尋報告**
```http
GET /api/v1/reports/search?q=肺炎&exam_type=CT&start_date=2024-01-01&page=1&page_size=20
Authorization: Bearer {token}
```

**響應**
```json
{
  "items": [
    {
      "id": 101,
      "patient_id": "P001",
      "patient_name": "王五",
      "exam_date": "2024-11-30",
      "exam_type": "CT",
      "report_content": "胸部CT顯示雙肺紋理增多...",
      "department": "放射科",
      "created_at": "2024-12-01T10:00:00Z"
    }
  ],
  "total": 45,
  "page": 1,
  "page_size": 20,
  "total_pages": 3
}
```

---

#### 模組 4: AI 分析 (AI Analysis)

| 方法 | 路徑 | 說明 | 權限 | 請求 | 響應 |
|------|------|------|------|------|------|
| POST | `/api/v1/ai/analyze` | 單筆 AI 分析 | researcher | `{ report_id, prompt, type }` | `AIAnnotation` |
| POST | `/api/v1/ai/batch-analyze` | 批次 AI 分析 | researcher | `{ report_ids[], prompt, type }` | `{ task_id, status }` |
| GET | `/api/v1/ai/annotations/{report_id}` | 取得報告的所有 AI 標註 | researcher | - | `AIAnnotation[]` |
| PUT | `/api/v1/ai/annotations/{id}` | 更新 AI 標註 | researcher | `UpdateAnnotationRequest` | `AIAnnotation` |
| DELETE | `/api/v1/ai/annotations/{id}` | 刪除 AI 標註 | researcher | - | `{ message }` |

**範例: 單筆 AI 分析**
```http
POST /api/v1/ai/analyze HTTP/1.1
Authorization: Bearer {token}
Content-Type: application/json

{
  "report_id": 101,
  "prompt": "找出肺部所有病灶，包含位置與大小",
  "annotation_type": "extraction"
}
```

**響應**
```json
{
  "id": 5001,
  "report_id": 101,
  "annotation_type": "extraction",
  "content": {
    "findings": [
      { "location": "右上肺", "description": "結節狀陰影", "size": "約1.2 cm" },
      { "location": "左下肺", "description": "斑片狀高密度影", "size": "約3 x 2 cm" }
    ]
  },
  "confidence": 0.87,
  "model_name": "qwen2.5:7b",
  "created_at": "2024-12-01T11:30:00Z"
}
```

---

#### 模組 5: 專案管理 (Projects)

| 方法 | 路徑 | 說明 | 權限 | 請求 / 查詢 | 響應 |
|------|------|------|------|-------------|------|
| GET | `/api/v1/projects` | 列出專案 | researcher | `status, page, page_size` | `PaginatedResponse<Project>` |
| GET | `/api/v1/projects/{id}` | 取得專案詳情 | researcher | - | `ProjectDetail` |
| POST | `/api/v1/projects` | 新增專案 | researcher | `{ name, description, tags }` | `Project` |
| PUT | `/api/v1/projects/{id}` | 更新專案 | researcher | `UpdateProjectRequest` | `Project` |
| DELETE | `/api/v1/projects/{id}` | 刪除專案 | admin | - | `{ message }` |
| GET | `/api/v1/projects/{id}/reports` | 取得專案的所有報告 | researcher | `page, page_size` | `PaginatedResponse<Report>` |
| POST | `/api/v1/projects/{id}/reports` | 批次加入報告到專案 | researcher | `{ report_ids[], notes }` | `{ added_count }` |
| DELETE | `/api/v1/projects/{id}/reports/{report_id}` | 從專案移除報告 | researcher | - | `{ message }` |

**範例: 建立專案**
```http
POST /api/v1/projects HTTP/1.1
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "肺炎研究專案 2024",
  "description": "針對 2024 年 CT 報告中肺炎案例的篩選與標註",
  "tags": ["pneumonia", "CT", "2024"]
}
```

**響應**
```json
{
  "id": 201,
  "name": "肺炎研究專案 2024",
  "description": "針對 2024 年 CT 報告中肺炎案例的篩選與標註",
  "tags": ["pneumonia", "CT", "2024"],
  "status": "active",
  "created_by": 1,
  "created_at": "2024-12-01T12:00:00Z"
}
```

---

#### 模組 6: 資料匯出 (Export)

| 方法 | 路徑 | 說明 | 權限 | 請求 | 響應 |
|------|------|------|------|------|------|
| POST | `/api/v1/export/project` | 匯出專案報告 | researcher | `{ project_id, format, include_ai }` | 檔案下載 (Excel/CSV/JSON) |
| POST | `/api/v1/export/search` | 匯出搜尋結果 | researcher | `{ search_criteria, format }` | 檔案下載 |

**範例: 匯出專案報告為 Excel**
```http
POST /api/v1/export/project HTTP/1.1
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 201,
  "format": "excel",
  "include_ai_annotations": true
}
```

**響應** (HTTP Header)
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="project_201_export_20241201.xlsx"
Content-Length: 524288
```

---

### 5.3 錯誤處理與狀態碼

| 狀態碼 | 說明 | 範例情境 |
|--------|------|----------|
| 200 | 成功 | GET/PUT 請求成功 |
| 201 | 已建立 | POST 新增資源成功 |
| 204 | 無內容 | DELETE 成功 |
| 400 | 錯誤請求 | 欄位驗證失敗 |
| 401 | 未授權 | JWT Token 無效或過期 |
| 403 | 禁止存取 | 權限不足 (非 admin 嘗試刪除) |
| 404 | 找不到資源 | 報告或專案不存在 |
| 422 | 無法處理的實體 | Pydantic 驗證錯誤 |
| 500 | 伺服器錯誤 | 資料庫連線失敗、Ollama 無回應 |

**錯誤響應範例**
```json
{
  "detail": "Report with id=999 not found"
}
```

**驗證錯誤範例**
```json
{
  "detail": [
    {
      "loc": ["body", "exam_date"],
      "msg": "invalid date format",
      "type": "value_error.date"
    }
  ]
}
```

---

### 5.4 API 客戶端範例

> 完整範例來源：`docs/old/api/04_API_SPECIFICATION.md`

#### Python 客戶端範例
```python
import requests
from typing import Optional, Dict, Any

BASE_URL = "http://localhost:8000/api/v1"

class ImageDataPlatformClient:
    def __init__(self, base_url: str = BASE_URL):
        self.base_url = base_url
        self.token: Optional[str] = None
        self.headers: Dict[str, str] = {}
    
    def login(self, email: str, password: str) -> Dict[str, Any]:
        """使用者登入"""
        response = requests.post(
            f"{self.base_url}/auth/login",
            data={"username": email, "password": password},
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        response.raise_for_status()
        data = response.json()
        
        self.token = data["access_token"]
        self.headers["Authorization"] = f"Bearer {self.token}"
        return data
    
    def search_reports(
        self,
        query: str,
        exam_type: Optional[str] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Dict[str, Any]:
        """搜尋報告"""
        params = {
            "q": query,
            "page": page,
            "page_size": page_size
        }
        if exam_type:
            params["exam_type"] = exam_type
        
        response = requests.get(
            f"{self.base_url}/reports/search",
            params=params,
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()
    
    def analyze_report(
        self,
        report_id: int,
        user_prompt: str,
        annotation_type: str = "extraction"
    ) -> Dict[str, Any]:
        """單筆 AI 分析"""
        response = requests.post(
            f"{self.base_url}/ai/analyze",
            json={
                "report_id": report_id,
                "user_prompt": user_prompt,
                "annotation_type": annotation_type
            },
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()
    
    def create_project(
        self,
        name: str,
        description: str,
        tags: list[str]
    ) -> Dict[str, Any]:
        """建立專案"""
        response = requests.post(
            f"{self.base_url}/projects",
            json={
                "name": name,
                "description": description,
                "tags": tags
            },
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()
    
    def add_reports_to_project(
        self,
        project_id: int,
        report_ids: list[int],
        notes: Optional[str] = None
    ) -> Dict[str, Any]:
        """批次加入報告到專案"""
        response = requests.post(
            f"{self.base_url}/projects/{project_id}/reports",
            json={"report_ids": report_ids, "notes": notes},
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()
    
    def export_project(
        self,
        project_id: int,
        format: str = "excel",
        include_ai: bool = True,
        output_file: str = "export.xlsx"
    ):
        """匯出專案報告"""
        response = requests.post(
            f"{self.base_url}/export/project",
            json={
                "project_id": project_id,
                "format": format,
                "include_ai_annotations": include_ai
            },
            headers=self.headers,
            stream=True
        )
        response.raise_for_status()
        
        with open(output_file, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        return output_file

# 使用範例
if __name__ == "__main__":
    client = ImageDataPlatformClient()
    
    # 1. 登入
    user = client.login("researcher@example.com", "SecurePass123")
    print(f"登入成功: {user['user']['full_name']}")
    
    # 2. 搜尋報告
    results = client.search_reports("肺炎", exam_type="CT", page=1)
    print(f"找到 {results['total']} 筆報告")
    
    # 3. AI 分析第一筆報告
    if results['items']:
        report = results['items'][0]
        annotation = client.analyze_report(
            report['id'],
            "請提取報告中的關鍵發現與位置",
            "extraction"
        )
        print(f"AI 分析結果: {annotation['content']}")
    
    # 4. 建立專案
    project = client.create_project(
        "肺炎研究 2024",
        "針對 2024 年 CT 報告中肺炎案例的篩選",
        ["pneumonia", "CT", "2024"]
    )
    print(f"專案已建立: {project['id']}")
    
    # 5. 加入報告到專案
    report_ids = [r['id'] for r in results['items'][:10]]
    client.add_reports_to_project(project['id'], report_ids)
    print(f"已加入 {len(report_ids)} 筆報告到專案")
    
    # 6. 匯出專案
    filename = client.export_project(project['id'], format="excel")
    print(f"專案已匯出至: {filename}")
```

#### TypeScript (React) 客戶端範例
```typescript
import axios, { AxiosInstance } from 'axios';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1';

// 建立 axios 實例
const api: AxiosInstance = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 請求攔截器：自動注入 Token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 響應攔截器：自動處理 401
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('access_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// API 方法
export const authAPI = {
  async login(email: string, password: string) {
    const formData = new URLSearchParams();
    formData.append('username', email);
    formData.append('password', password);

    const response = await axios.post(`${BASE_URL}/auth/login`, formData, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    });

    const { access_token } = response.data;
    localStorage.setItem('access_token', access_token);
    return response.data;
  },

  async getCurrentUser() {
    const response = await api.get('/auth/me');
    return response.data;
  },

  logout() {
    localStorage.removeItem('access_token');
    window.location.href = '/login';
  },
};

export const reportAPI = {
  async search(params: {
    q?: string;
    exam_type?: string;
    start_date?: string;
    end_date?: string;
    page?: number;
    page_size?: number;
  }) {
    const response = await api.get('/reports/search', { params });
    return response.data;
  },

  async getDetail(reportId: number) {
    const response = await api.get(`/reports/${reportId}`);
    return response.data;
  },
};

export const aiAPI = {
  async analyze(
    reportId: number,
    userPrompt: string,
    annotationType: 'highlight' | 'classification' | 'extraction' | 'scoring'
  ) {
    const response = await api.post('/ai/analyze', {
      report_id: reportId,
      user_prompt: userPrompt,
      annotation_type: annotationType,
    });
    return response.data;
  },

  async batchAnalyze(reportIds: number[], userPrompt: string, annotationType: string) {
    const response = await api.post('/ai/batch-analyze', {
      report_ids: reportIds,
      user_prompt: userPrompt,
      annotation_type: annotationType,
    });
    return response.data;
  },

  async getAnnotations(reportId: number) {
    const response = await api.get(`/ai/annotations/${reportId}`);
    return response.data;
  },
};

export const projectAPI = {
  async list(page: number = 1, page_size: number = 20) {
    const response = await api.get('/projects', {
      params: { page, page_size },
    });
    return response.data;
  },

  async create(name: string, description: string, tags: string[]) {
    const response = await api.post('/projects', {
      name,
      description,
      tags,
    });
    return response.data;
  },

  async getDetail(projectId: number) {
    const response = await api.get(`/projects/${projectId}`);
    return response.data;
  },

  async addReports(projectId: number, reportIds: number[], notes?: string) {
    const response = await api.post(`/projects/${projectId}/reports`, {
      report_ids: reportIds,
      notes,
    });
    return response.data;
  },

  async exportProject(
    projectId: number,
    format: 'excel' | 'csv' | 'json' = 'excel',
    includeAI: boolean = true
  ) {
    const response = await api.post(
      '/export/project',
      {
        project_id: projectId,
        format,
        include_ai_annotations: includeAI,
      },
      {
        responseType: 'blob',
      }
    );

    // 觸發下載
    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    const extension = format === 'excel' ? 'xlsx' : format;
    link.setAttribute('download', `project_${projectId}_export.${extension}`);
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(url);
  },
};

// React Hook 使用範例
import { useState, useEffect } from 'react';
import { reportAPI, aiAPI } from '@/api/client';

function ReportSearch() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleSearch = async () => {
    setLoading(true);
    try {
      const data = await reportAPI.search({ q: query, page: 1, page_size: 20 });
      setResults(data.items);
    } catch (error) {
      console.error('搜尋失敗:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAnalyze = async (reportId: number) => {
    try {
      const annotation = await aiAPI.analyze(
        reportId,
        '請提取報告中的關鍵發現',
        'extraction'
      );
      console.log('AI 分析結果:', annotation.content);
    } catch (error) {
      console.error('分析失敗:', error);
    }
  };

  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
      />
      <button onClick={handleSearch} disabled={loading}>
        {loading ? '搜尋中...' : '搜尋'}
      </button>
      
      <ul>
        {results.map((report: any) => (
          <li key={report.id}>
            {report.patient_name} - {report.exam_type}
            <button onClick={() => handleAnalyze(report.id)}>AI 分析</button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

#### curl 測試範例
```bash
# 1. 登入取得 Token
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=researcher@example.com&password=SecurePassword123"

# 儲存 Token 為環境變數
export TOKEN="your_access_token_here"

# 2. 搜尋報告
curl -X GET "http://localhost:8000/api/v1/reports/search?q=肺部&page=1&page_size=10" \
  -H "Authorization: Bearer $TOKEN"

# 3. AI 分析
curl -X POST "http://localhost:8000/api/v1/ai/analyze" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "report_id": 1,
    "user_prompt": "請提取關鍵發現",
    "annotation_type": "extraction"
  }'

# 4. 建立專案
curl -X POST "http://localhost:8000/api/v1/projects" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "測試專案",
    "description": "API 測試",
    "tags": ["test"]
  }'

# 5. 加入報告到專案
curl -X POST "http://localhost:8000/api/v1/projects/1/reports" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "report_ids": [1, 2, 3],
    "notes": "測試加入"
  }'

# 6. 匯出專案（下載檔案）
curl -X POST "http://localhost:8000/api/v1/export/project" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "format": "excel",
    "include_ai_annotations": true
  }' \
  -o "export.xlsx"

# 7. 取得當前使用者資訊
curl -X GET "http://localhost:8000/api/v1/auth/me" \
  -H "Authorization: Bearer $TOKEN"

# 8. 批次 AI 分析
curl -X POST "http://localhost:8000/api/v1/ai/batch-analyze" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "report_ids": [1, 2, 3, 4, 5],
    "user_prompt": "請分類為正常或異常",
    "annotation_type": "classification"
  }'
```

---

## 6. 非功能設計考量（Non-Functional Considerations）

### 6.1 效能設計

#### 資料庫查詢最佳化
- **全文索引**: reports 表的 report_content 與 patient_name 欄位建立 GIN 全文索引
- **複合索引**: exam_date + exam_type 複合索引支援常見篩選組合
- **分頁查詢**: 所有列表 API 預設分頁 (page_size=20, max=100)
- **懶載入**: AI 標註僅在需要時載入 (不自動 JOIN)

#### API 響應時間目標
- 認證 API: < 500 ms
- 報告搜尋 (全文): < 2 秒 (90th percentile)
- 報告詳情: < 500 ms
- AI 單筆分析: 5-10 秒 (依 Ollama 效能)
- 批次分析: 非同步背景任務 (不阻塞前端)

#### 並發處理
- AI 批次分析: 最多 3-5 筆並發 (避免 GPU 過載)
- 資料匯入: 批次插入 500-1000 筆/次
- 連線池: PostgreSQL 連線池設定 10-20 連線

### 6.2 安全性設計

#### 認證與授權
- **JWT Token**: HS256 演算法，30 分鐘有效期
- **密碼加密**: bcrypt (成本因子 12)
- **角色權限**: 
  - `researcher`: 可讀寫自己的報告與專案
  - `admin`: 可刪除任何報告、管理所有使用者

#### 資料保護
- **HTTPS**: 正式環境強制使用 TLS 1.2+
- **SQL Injection 防護**: 使用 SQLAlchemy ORM 參數化查詢
- **XSS 防護**: 前端渲染報告內容時進行 HTML 轉義
- **敏感資料處理**:
  - 密碼不記錄於日誌
  - 患者個資欄位不出現在錯誤訊息
  - AI 原始響應 (raw_response) 僅 admin 可見

### 6.3 可維護性設計

#### 程式碼結構
- **分層架構**: API Layer → Service Layer → Repository Layer
- **相依性注入**: FastAPI Depends / Django DI
- **型別提示**: 所有 Python 程式碼使用 Type Hints
- **API Schema**: Pydantic Models 定義請求/響應格式

#### 日誌與監控
- **結構化日誌**: JSON 格式，包含 request_id, user_id, timestamp
- **日誌等級**:
  - INFO: API 請求/響應
  - WARNING: 匯入資料格式問題
  - ERROR: 資料庫連線失敗、Ollama 超時
- **效能監控**: API 響應時間、資料庫查詢時間

#### 測試策略
- **單元測試**: Service Layer 與 Repository Layer (pytest)
- **整合測試**: API 端點測試 (TestClient)
- **E2E 測試**: 關鍵流程 (登入 → 搜尋 → AI 分析 → 匯出)

---

## 7. 風險與技術債（Risks and Technical Debt）

### 7.1 已知技術債

#### TD-001: 後端框架遷移規劃
- **描述**: Phase 1 使用 FastAPI，但規劃遷移至 Django + Django Ninja
- **影響**: API 路由、Service Layer 需重構
- **緩解**: 保持 Service Layer 與 API Layer 解耦，降低遷移成本
- **優先級**: 中 (Phase 2 前完成)

#### TD-002: 患者資訊嵌入 reports 表
- **描述**: 患者資訊直接儲存於 reports 表，未正規化
- **影響**: 同一患者多次檢查時，資訊重複儲存
- **緩解**: Phase 2 新增 patients 表，建立 1:N 關係
- **優先級**: 低 (Phase 1 資料量小，可接受)

#### TD-003: AI 批次分析無進度追蹤
- **描述**: 批次分析為背景任務，前端無法即時取得進度
- **影響**: 使用者體驗不佳 (不知道處理到第幾筆)
- **緩解**: 新增 task_status 表或使用 Celery + Redis
- **優先級**: 中 (Phase 1 批次數量小，可接受)

### 7.2 技術風險

#### R-001: Ollama 服務穩定性
- **描述**: Ollama 服務可能因 GPU OOM 或模型載入問題而中斷
- **機率**: 中
- **影響**: 高 (AI 分析功能完全不可用)
- **緩解措施**:
  - 實作重試機制 (最多 3 次)
  - 監控 Ollama 健康狀態 (定期 ping)
  - 錯誤時友善提示並記錄日誌

#### R-002: PostgreSQL 全文搜尋效能瓶頸
- **描述**: 當 reports 表超過 100 萬筆時，全文搜尋可能變慢
- **機率**: 低 (Phase 1 目標 < 10 萬筆)
- **影響**: 中 (搜尋響應時間 > 5 秒)
- **緩解措施**:
  - 定期 VACUUM ANALYZE 維護索引
  - 考慮引入 Elasticsearch (Phase 2)

#### R-003: Excel 匯出記憶體消耗
- **描述**: 匯出大型專案 (> 10,000 筆) 時，可能 OOM
- **機率**: 低
- **影響**: 中 (匯出失敗)
- **緩解措施**:
  - 限制單次匯出上限 (1,000 筆)
  - 使用串流寫入 (openpyxl write_only 模式)

---

## 8. 前端狀態管理與互動（Frontend State Management & Interaction）

> 本節整合自 `docs/old/architecture/FRONTEND_BACKEND_INTEGRATION.md`

### 8.1 Zustand 狀態管理

Phase 1 採用 Zustand 作為輕量級全域狀態管理方案：

```typescript
// src/store/studyStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface StudyState {
  // 搜尋狀態
  searchQuery: string;
  searchResults: Report[];
  totalResults: number;
  currentPage: number;
  filters: SearchFilters;
  loading: boolean;
  error?: string;
  
  // UI 狀態
  selectedReport?: Report;
  showDetailModal: boolean;
  showFilterPanel: boolean;
  
  // Actions
  setSearchQuery: (q: string) => void;
  search: () => Promise<void>;
  setFilters: (filters: SearchFilters) => void;
  clearFilters: () => void;
  setPage: (page: number) => void;
  selectReport: (report: Report) => void;
  clearSelection: () => void;
}

export const useStudyStore = create<StudyState>()(
  devtools(
    persist(
      (set, get) => ({
        // 初始狀態
        searchQuery: '',
        searchResults: [],
        totalResults: 0,
        currentPage: 1,
        filters: {},
        loading: false,
        showDetailModal: false,
        showFilterPanel: false,
        
        // Actions 實作
        setSearchQuery: (q) => set({ searchQuery: q }),
        
        search: async () => {
          set({ loading: true, error: undefined });
          try {
            const { searchQuery, filters, currentPage } = get();
            const response = await axios.get('/api/v1/reports/search', {
              params: {
                q: searchQuery,
                ...filters,
                page: currentPage,
                page_size: 20
              }
            });
            set({
              searchResults: response.data.items,
              totalResults: response.data.total,
              loading: false
            });
          } catch (error) {
            set({ error: error.message, loading: false });
          }
        },
        
        setFilters: (filters) => set({ filters, currentPage: 1 }),
        clearFilters: () => set({ filters: {}, currentPage: 1 }),
        setPage: (page) => set({ currentPage: page }),
        selectReport: (report) => set({ selectedReport: report, showDetailModal: true }),
        clearSelection: () => set({ selectedReport: undefined, showDetailModal: false })
      }),
      {
        name: 'study-storage',
        partialize: (state) => ({ filters: state.filters }) // 僅持久化 filters
      }
    )
  )
);
```

**使用方式**:
```typescript
// 在 React 元件中使用
import { useStudyStore } from '@/store/studyStore';

function StudySearch() {
  const { searchQuery, setSearchQuery, search, loading, searchResults } = useStudyStore();
  
  return (
    <div>
      <Input
        value={searchQuery}
        onChange={(e) => setSearchQuery(e.target.value)}
        onPressEnter={search}
        placeholder="搜尋報告..."
      />
      {loading ? <Spin /> : <Table dataSource={searchResults} />}
    </div>
  );
}
```

### 8.2 前端錯誤處理策略

#### HTTP 狀態碼處理
```typescript
// src/utils/http.ts
import axios from 'axios';
import { message, notification } from 'antd';

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1',
  timeout: 30000
});

// 請求攔截器：注入 JWT Token
http.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// 響應攔截器：統一錯誤處理
http.interceptors.response.use(
  (response) => response,
  (error) => {
    const { response } = error;
    
    if (!response) {
      // 網路錯誤
      notification.error({
        message: '網路錯誤',
        description: '無法連線至伺服器，請檢查網路連線'
      });
      return Promise.reject(error);
    }
    
    switch (response.status) {
      case 400:
        // 驗證錯誤
        if (Array.isArray(response.data.detail)) {
          const errors = response.data.detail.map(e => e.msg).join(', ');
          message.error(`請求格式錯誤: ${errors}`);
        } else {
          message.error(response.data.detail || '請求格式錯誤');
        }
        break;
        
      case 401:
        // Token 過期或無效
        message.warning('登入已過期，請重新登入');
        localStorage.removeItem('access_token');
        window.location.href = '/login';
        break;
        
      case 403:
        // 權限不足
        notification.warning({
          message: '權限不足',
          description: '您沒有權限執行此操作'
        });
        break;
        
      case 404:
        // 資源不存在
        message.error('找不到請求的資源');
        break;
        
      case 422:
        // Pydantic 驗證錯誤
        if (Array.isArray(response.data.detail)) {
          const errors = response.data.detail
            .map(e => `${e.loc.join('.')}: ${e.msg}`)
            .join('\n');
          notification.error({
            message: '資料驗證失敗',
            description: errors
          });
        }
        break;
        
      case 500:
        // 伺服器錯誤
        notification.error({
          message: '伺服器錯誤',
          description: response.data.detail || '伺服器發生錯誤，請稍後再試'
        });
        break;
        
      default:
        notification.error({
          message: `錯誤 ${response.status}`,
          description: response.data.detail || '發生未知錯誤'
        });
    }
    
    return Promise.reject(error);
  }
);

export default http;
```

### 8.3 Ollama AI Engine 整合細節

#### Ollama 服務配置
```yaml
# docker-compose.yml (Ollama 服務)
services:
  ollama:
    image: ollama/ollama:latest
    container_name: image-platform-ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_models:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

#### 後端 Ollama 客戶端實作
```python
# backend/services/ollama_client.py
import httpx
import json
from typing import Dict, Any, Optional
from pydantic import BaseModel

class OllamaConfig(BaseModel):
    base_url: str = "http://localhost:11434"
    model: str = "qwen2.5:7b"
    timeout: int = 60
    temperature: float = 0.7
    top_p: float = 0.9
    top_k: int = 40

class OllamaClient:
    def __init__(self, config: OllamaConfig):
        self.config = config
        self.client = httpx.Client(
            base_url=config.base_url,
            timeout=httpx.Timeout(config.timeout, read=config.timeout)
        )
    
    def generate(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        json_mode: bool = True
    ) -> Dict[str, Any]:
        """
        呼叫 Ollama generate API
        
        Args:
            prompt: 使用者提示詞
            system_prompt: 系統提示詞 (定義 AI 行為)
            json_mode: 是否要求 JSON 格式輸出
        
        Returns:
            生成的內容 (若 json_mode=True, 自動解析為 dict)
        """
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.config.model,
            "messages": messages,
            "stream": False,
            "options": {
                "temperature": self.config.temperature,
                "top_p": self.config.top_p,
                "top_k": self.config.top_k
            }
        }
        
        if json_mode:
            payload["format"] = "json"
        
        try:
            response = self.client.post("/api/chat", json=payload)
            response.raise_for_status()
            result = response.json()
            
            generated_text = result.get("message", {}).get("content", "")
            
            if json_mode:
                return json.loads(generated_text)
            return {"text": generated_text}
        
        except httpx.TimeoutException:
            raise Exception("Ollama 服務超時 (60秒)")
        except httpx.HTTPStatusError as e:
            raise Exception(f"Ollama 服務錯誤: {e.response.status_code}")
        except json.JSONDecodeError:
            raise Exception("Ollama 回應非有效 JSON 格式")
    
    def health_check(self) -> bool:
        """檢查 Ollama 服務健康狀態"""
        try:
            response = self.client.get("/api/tags", timeout=5)
            return response.status_code == 200
        except:
            return False
    
    def analyze_report(
        self,
        report_content: str,
        analysis_type: str,
        user_prompt: str
    ) -> Dict[str, Any]:
        """
        針對報告內容執行 AI 分析
        
        Args:
            report_content: 報告完整內容
            analysis_type: highlight|classification|extraction|scoring
            user_prompt: 使用者自訂提示詞
        
        Returns:
            結構化分析結果
        """
        system_prompts = {
            "highlight": "你是醫療報告分析助手。請標註出報告中的關鍵發現與重要資訊。",
            "classification": "你是醫療報告分類助手。請判斷報告的類別 (正常/異常)。",
            "extraction": "你是醫療資訊提取助手。請從報告中提取結構化資訊。",
            "scoring": "你是醫療報告評分助手。請對報告的嚴重程度進行評分 (1-5)。"
        }
        
        system_prompt = system_prompts.get(analysis_type, system_prompts["extraction"])
        
        full_prompt = f"""
{user_prompt}

報告內容：
{report_content}

請以 JSON 格式輸出分析結果。
"""
        
        return self.generate(
            prompt=full_prompt,
            system_prompt=system_prompt,
            json_mode=True
        )
```

### 8.4 前端效能最佳化

#### 請求最佳化
```typescript
// 1. 搜尋輸入防抖 (300ms)
import { debounce } from 'lodash-es';

const debouncedSearch = debounce((query: string) => {
  useStudyStore.getState().search();
}, 300);

<Input onChange={(e) => {
  setSearchQuery(e.target.value);
  debouncedSearch(e.target.value);
}} />

// 2. 分頁查詢 (每頁 20 筆)
const pagination = {
  current: currentPage,
  pageSize: 20,
  total: totalResults,
  showSizeChanger: false,
  onChange: (page) => {
    setPage(page);
    search();
  }
};

// 3. 懶載入報告詳情
const loadReportDetail = async (reportId: number) => {
  const detail = await http.get(`/reports/${reportId}`);
  return detail.data;
};

// 4. 快取篩選選項 (Session Storage)
const loadFilterOptions = async () => {
  const cached = sessionStorage.getItem('filter_options');
  if (cached && Date.now() - JSON.parse(cached).timestamp < 3600000) {
    return JSON.parse(cached).data;
  }
  
  const options = await http.get('/reports/filters/options');
  sessionStorage.setItem('filter_options', JSON.stringify({
    data: options.data,
    timestamp: Date.now()
  }));
  return options.data;
};
```

#### 後端查詢最佳化
```python
# backend/services/report_service.py
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import or_, and_, func

class ReportService:
    def search_reports(
        self,
        db: Session,
        q: str,
        filters: dict,
        page: int = 1,
        page_size: int = 20
    ):
        query = db.query(Report).filter(Report.is_deleted == False)
        
        # 全文搜尋 (使用 PostgreSQL GIN 索引)
        if q:
            search_vector = func.to_tsvector('simple', Report.report_content)
            search_query = func.to_tsquery('simple', q.replace(' ', ' & '))
            query = query.filter(search_vector.match(search_query))
            
            # 計算相關性排序
            query = query.order_by(
                func.ts_rank(search_vector, search_query).desc()
            )
        
        # 篩選條件 (使用索引)
        if filters.get('exam_type'):
            query = query.filter(Report.exam_type == filters['exam_type'])
        
        if filters.get('start_date'):
            query = query.filter(Report.exam_date >= filters['start_date'])
        
        if filters.get('end_date'):
            query = query.filter(Report.exam_date <= filters['end_date'])
        
        # 分頁 (LIMIT / OFFSET)
        total = query.count()
        reports = query.offset((page - 1) * page_size).limit(page_size).all()
        
        return {
            "items": reports,
            "total": total,
            "page": page,
            "page_size": page_size,
            "total_pages": (total + page_size - 1) // page_size
        }
```

---

## 10. 部署架構與環境配置（Deployment Architecture & Configuration）

> 本節整合自 `docs/old/architecture/FRONTEND_BACKEND_INTEGRATION.md` 部署考量部分

### 10.1 開發環境部署

#### 本地開發設定（Local Development）
```bash
# 終端機 1: 前端開發伺服器
cd frontend
npm install
npm run dev  # 啟動 Vite Dev Server (Port 3000)

# 終端機 2: 後端 API 伺服器
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# 終端機 3: Ollama AI 服務
ollama serve  # Port 11434
ollama pull qwen2.5:7b  # 首次執行需下載模型

# 終端機 4: PostgreSQL 資料庫
docker run -d \
  --name image-platform-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=imagedb \
  -p 5432:5432 \
  postgres:14
```

#### 環境變數設定
```bash
# frontend/.env.development
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_APP_TITLE=Image Data Platform (Dev)

# backend/.env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/imagedb
OLLAMA_BASE_URL=http://localhost:11434
SECRET_KEY=dev-secret-key-change-in-production
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=30
CORS_ORIGINS=["http://localhost:3000"]
```

### 10.2 正式環境部署（Production Deployment）

#### Docker Compose 部署架構
```yaml
# docker-compose.yml
version: '3.8'

services:
  # 前端 (Nginx + React SPA)
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: image-platform-frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/ssl:/etc/nginx/ssl:ro
    environment:
      - VITE_API_BASE_URL=https://api.example.com/api/v1
    depends_on:
      - backend
    restart: unless-stopped

  # 後端 API (FastAPI + Gunicorn)
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: image-platform-backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@db:5432/imagedb
      - OLLAMA_BASE_URL=http://ollama:11434
      - SECRET_KEY=${SECRET_KEY}
      - JWT_ALGORITHM=HS256
      - JWT_EXPIRE_MINUTES=30
      - CORS_ORIGINS=["https://example.com"]
    depends_on:
      - db
      - ollama
    restart: unless-stopped
    command: gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000

  # PostgreSQL 資料庫
  db:
    image: postgres:14
    container_name: image-platform-db
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=imagedb
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    restart: unless-stopped

  # Ollama AI 引擎
  ollama:
    image: ollama/ollama:latest
    container_name: image-platform-ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_models:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

volumes:
  postgres_data:
  ollama_models:
```

#### Nginx 設定（前端 SPA + 反向代理）
```nginx
# nginx/default.conf
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # 前端 SPA (React)
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 後端 API 反向代理
    location /api/ {
        proxy_pass http://backend:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
        proxy_connect_timeout 60s;
    }

    # 靜態檔案快取
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /usr/share/nginx/html;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Frontend Dockerfile
```dockerfile
# frontend/Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
```

#### Backend Dockerfile
```dockerfile
# backend/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 安裝系統相依性
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 安裝 Python 套件
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 複製應用程式
COPY . .

EXPOSE 8000

# 使用 Gunicorn 執行 (4 workers)
CMD ["gunicorn", "main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000", "--timeout", "60"]
```

### 10.3 環境變數管理

#### 開發環境（`.env.development`）
```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/imagedb

# AI Engine
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=qwen2.5:7b
OLLAMA_TIMEOUT=60

# Authentication
SECRET_KEY=dev-secret-key-change-in-production
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=30

# CORS
CORS_ORIGINS=["http://localhost:3000"]

# Debug
DEBUG=True
LOG_LEVEL=DEBUG
```

#### 正式環境（`.env.production`，**不可提交至版本控制**）
```bash
# Database (使用強密碼)
DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@db:5432/imagedb

# AI Engine
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_MODEL=qwen2.5:7b
OLLAMA_TIMEOUT=60

# Authentication (使用強隨機金鑰)
SECRET_KEY=${SECRET_KEY}  # 至少 64 字元隨機字串
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=30

# CORS (限制來源)
CORS_ORIGINS=["https://example.com"]

# Security
SECURE_COOKIES=True
HTTPS_ONLY=True

# Debug
DEBUG=False
LOG_LEVEL=INFO
```

**產生安全金鑰**:
```bash
# 產生 SECRET_KEY
python -c "import secrets; print(secrets.token_urlsafe(64))"

# 產生 DB_PASSWORD
openssl rand -base64 32
```

### 10.4 監控與日誌

#### 日誌設定
```python
# backend/config/logging.py
import logging
import sys
from pythonjsonlogger import jsonlogger

def setup_logging(log_level: str = "INFO"):
    logger = logging.getLogger()
    logger.setLevel(log_level)
    
    # JSON 格式日誌（適合 ELK Stack）
    handler = logging.StreamHandler(sys.stdout)
    formatter = jsonlogger.JsonFormatter(
        '%(timestamp)s %(level)s %(name)s %(message)s %(request_id)s %(user_id)s'
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
    return logger
```

#### 健康檢查端點
```python
# backend/api/health.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from services.ollama_client import OllamaClient

router = APIRouter()

@router.get("/health")
async def health_check(db: Session = Depends(get_db)):
    """系統健康檢查"""
    health = {
        "status": "healthy",
        "database": False,
        "ollama": False
    }
    
    # 檢查資料庫
    try:
        db.execute("SELECT 1")
        health["database"] = True
    except Exception as e:
        health["status"] = "unhealthy"
        health["database_error"] = str(e)
    
    # 檢查 Ollama
    try:
        ollama = OllamaClient()
        health["ollama"] = ollama.health_check()
    except Exception as e:
        health["status"] = "unhealthy"
        health["ollama_error"] = str(e)
    
    return health
```

### 10.5 備份與災難復原

#### 資料庫備份腳本
```bash
#!/bin/bash
# backup.sh - 每日自動備份

BACKUP_DIR=/backups/postgres
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="imagedb_backup_${DATE}.sql.gz"

# 備份資料庫
docker exec image-platform-db pg_dump -U postgres imagedb | gzip > "${BACKUP_DIR}/${BACKUP_FILE}"

# 保留最近 7 天的備份
find ${BACKUP_DIR} -name "imagedb_backup_*.sql.gz" -mtime +7 -delete

echo "✅ 備份完成: ${BACKUP_FILE}"
```

#### 資料還原
```bash
# 還原資料庫
gunzip -c imagedb_backup_20250126_120000.sql.gz | \
  docker exec -i image-platform-db psql -U postgres imagedb
```

---

## 11. 追溯性（Traceability）

（追溯至 `requirements/01_SYSTEM_PRD_SR_SD.md` 與相關測試文件）


