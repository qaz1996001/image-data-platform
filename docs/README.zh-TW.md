# 影像數據平台 - Phase 1: AI輔助報告篩選系統

基於2020-2024年PAPA數據的AI驅動醫學報告管理和智慧分析平台

## 項目概述

本項目第一階段（Phase 1）專注於構建一個**AI輔助的醫學報告篩選和管理系統**，利用本地部署的大語言模型（Ollama）實現報告的智慧分析、分類和資訊提取，幫助研究人員快速篩選和管理大量醫學影像報告。

### Phase 1 核心功能

- **📂 數據導入**：支援Excel/CSV批量導入醫學報告
- **🔍 智慧檢索**：PostgreSQL全文搜尋，支援複雜條件篩選
- **🤖 AI分析**：本地LLM（Ollama）進行報告標註、分類、提取和評分
- **📊 項目管理**：多項目管理，靈活組織和分類報告
- **📥 數據導出**：支援Excel/CSV導出帶AI分析結果

### Phase 2 規劃（後續擴展）

- DICOM影像存儲和查看（MinIO + Cornerstone.js）
- 外部系統集成（Accssyn、Red Report）
- 高級影像處理功能
- 更多AI分析能力

## 技術棧

### 前端
- React 18+ with TypeScript
- Ant Design (UI元件庫)
- Zustand (狀態管理)
- Axios (HTTP客戶端)
- Vite (構建工具)

### 後端
- Python 3.11 + FastAPI
- PostgreSQL 14+ (主數據庫，全文搜尋)
- SQLAlchemy + Alembic (ORM和數據庫遷移)
- Pydantic (數據驗證)

### AI引擎
- **Ollama** (本地LLM服務)
- **qwen2.5:7b** (推薦模型，7B參數，4.4GB)
- httpx (非同步HTTP客戶端)

### 部署
- Docker + Docker Compose
- 4個核心服務：PostgreSQL、Ollama、Backend、Frontend

## 快速開始

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- Git
- 至少16GB RAM（用於運行Ollama LLM）
- （可選）NVIDIA GPU + CUDA支援（用於GPU加速）

### 5步快速部署

**1. 克隆項目**
```bash
git clone https://github.com/your-org/image_data_platform.git
cd image_data_platform
```

**2. 配置環境變數**
```bash
cp .env.example .env
nano .env  # 根據需要修改配置
```

必需的環境變數：
```env
# 數據庫配置
DATABASE_URL=postgresql://user:password@postgres:5432/imagedb
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=imagedb

# JWT認證
SECRET_KEY=your_very_secure_random_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Ollama配置
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_MODEL=qwen2.5:7b
OLLAMA_TIMEOUT=60
```

**3. 啟動所有服務**
```bash
docker-compose up -d
```

等待所有服務啟動（約2-3分鐘）。

**4. 下載Ollama模型並初始化數據庫**
```bash
# 下載qwen2.5:7b模型（約4.4GB，需要5-10分鐘）
docker exec -it ollama ollama pull qwen2.5:7b

# 運行數據庫遷移
docker exec -it backend alembic upgrade head

# 創建初始管理員賬號
docker exec -it backend python scripts/create_admin.py
```

**5. 訪問應用**
- **前端界面**：http://localhost:3000
- **後端API文檔**：http://localhost:8000/docs
- **健康檢查**：http://localhost:8000/api/v1/health

### 默認管理員賬號

- **郵箱**：admin@hospital.com
- **密碼**：Admin@123456

> ⚠️ **安全提示**：首次登錄後請立即修改默認密碼！

## 項目結構

```
image_data_platform/
├── backend/                       # FastAPI後端
│   ├── app/
│   │   ├── api/                  # API路由模塊
│   │   │   ├── auth.py           # 認證端點
│   │   │   ├── import_data.py    # 數據導入
│   │   │   ├── reports.py        # 報告管理
│   │   │   ├── ai_analysis.py    # AI分析
│   │   │   ├── projects.py       # 項目管理
│   │   │   └── export.py         # 數據導出
│   │   ├── core/                 # 核心配置
│   │   │   ├── config.py         # 應用配置
│   │   │   └── security.py       # JWT認證
│   │   ├── models/               # SQLAlchemy模型
│   │   │   ├── user.py
│   │   │   ├── report.py
│   │   │   ├── ai_annotation.py
│   │   │   └── project.py
│   │   ├── schemas/              # Pydantic schemas
│   │   ├── services/             # 業務邏輯
│   │   │   ├── ollama_client.py  # Ollama客戶端
│   │   │   ├── import_service.py # 導入服務
│   │   │   └── export_service.py # 導出服務
│   │   └── main.py               # FastAPI應用入口
│   ├── alembic/                  # 數據庫遷移
│   ├── tests/                    # 測試代碼
│   ├── requirements.txt          # Python依賴
│   └── Dockerfile
│
├── frontend/                      # React前端
│   ├── src/
│   │   ├── components/           # 可複用元件
│   │   ├── pages/                # 頁面
│   │   │   ├── Login.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   ├── DataImport.tsx
│   │   │   ├── ReportSearch.tsx
│   │   │   ├── AIAnalysis.tsx
│   │   │   └── Projects.tsx
│   │   ├── services/             # API客戶端
│   │   ├── store/                # Zustand狀態
│   │   ├── types/                # TypeScript類型
│   │   └── App.tsx
│   ├── package.json
│   └── Dockerfile
│
├── docs/                          # 項目文檔
│   ├── 00_DOCUMENTATION_INDEX.md # 文檔索引
│   ├── 01_PROJECT_OVERVIEW.md    # 項目概述
│   ├── architecture/             # 架構設計
│   │   └── 02_TECHNICAL_ARCHITECTURE.md
│   ├── database/                 # 數據庫設計
│   │   └── 03_DATABASE_DESIGN.md
│   ├── api/                      # API文檔
│   │   └── 04_API_SPECIFICATION.md
│   ├── workflow/                 # 開發流程
│   │   └── 05_DEVELOPMENT_WORKFLOW.md
│   ├── requirements/             # 需求文檔
│   │   ├── USER_REQUIREMENTS.md
│   │   └── FUNCTIONAL_SPECIFICATION.md
│   └── guides/                   # 開發指南
│       └── AI_INTEGRATION_GUIDE.md
│
├── docker-compose.yml             # Docker編排配置
├── .env.example                   # 環境變數模板
└── README.md                      # 本文件
```

## 核心文檔

### 📖 必讀文檔（按閱讀順序）

1. **[項目概述](./docs/01_PROJECT_OVERVIEW.md)** - 了解項目背景、Phase 1目標和功能模塊
2. **[技術架構設計](./docs/architecture/02_TECHNICAL_ARCHITECTURE.md)** - 系統架構、技術選型和代碼示例
3. **[AI集成指南](./docs/guides/AI_INTEGRATION_GUIDE.md)** - Ollama部署、配置和使用詳解
4. **[數據庫設計](./docs/database/03_DATABASE_DESIGN.md)** - 5張核心表的完整設計
5. **[API接口規範](./docs/api/04_API_SPECIFICATION.md)** - 20個API端點詳細文檔
6. **[開發工作流](./docs/workflow/05_DEVELOPMENT_WORKFLOW.md)** - 8週Phase 1開發計劃

### 📚 需求與規格文檔

- [用戶需求文檔](./docs/requirements/USER_REQUIREMENTS.md) - 7個核心需求定義
- [功能規格說明書](./docs/requirements/FUNCTIONAL_SPECIFICATION.md) - 詳細功能規格

### 🗂️ 完整文檔索引

查看 [文檔索引](./docs/00_DOCUMENTATION_INDEX.md) 獲取完整文檔列表和閱讀指南。

## AI分析功能

系統提供4種AI分析類型，使用Ollama本地LLM實現：

### 1. 🔍 高亮標註 (Highlight)
自動識別和標註報告中的關鍵信息：
- 異常發現（abnormal）
- 測量數值（measurement）
- 解剖位置（location）
- 診斷結論（diagnosis）

### 2. 📋 分類標註 (Classification)
多維度報告分類：
- 異常程度（正常/輕度/中度/重度異常）
- 病變性質（良性/惡性/不確定）
- 檢查質量評估
- 緊急程度分級

### 3. 📊 信息提取 (Extraction)
結構化提取報告信息：
- 主要發現列表
- 測量數值（含單位）
- 涉及解剖部位
- 印象和結論

### 4. ⭐ 質量評分 (Scoring)
多維度報告質量評估：
- 完整性（0-10分）
- 清晰度（0-10分）
- 詳細程度（0-10分）
- 臨床價值（0-10分）

> 💡 詳細使用指南和示例請參考 [AI集成指南](./docs/guides/AI_INTEGRATION_GUIDE.md)

## Docker服務說明

Phase 1使用4個Docker服務（簡化架構）：

| 服務 | 鏡像 | 端口 | 說明 |
|-----|------|------|------|
| **postgres** | postgres:14-alpine | 5432 | PostgreSQL數據庫 |
| **ollama** | ollama/ollama:latest | 11434 | Ollama LLM服務 |
| **backend** | 本地構建 | 8000 | FastAPI後端 |
| **frontend** | 本地構建 | 3000 | React前端 |

查看服務狀態：
```bash
docker-compose ps
```

查看服務日誌：
```bash
# 查看所有服務
docker-compose logs -f

# 查看特定服務
docker-compose logs -f backend
docker-compose logs -f ollama
```

## 開發規範

### Git工作流

```bash
# 1. 創建功能分支
git checkout -b feature/your-feature-name

# 2. 提交代碼（使用規範的commit message）
git add .
git commit -m "feat(module): add new feature"

# 3. 推送分支
git push origin feature/your-feature-name

# 4. 創建Pull Request
```

### 提交信息規範

```
<type>(<scope>): <subject>

type: feat, fix, docs, style, refactor, test, chore
scope: auth, import, search, ai, project, export
subject: 簡短描述（中文或英文）

示例:
feat(ai): add batch analysis API endpoint
fix(search): resolve full-text search timeout
docs(readme): update Ollama setup instructions
```

### 代碼風格

**Python (後端)**
- 遵循 PEP 8
- 使用類型提示（Type Hints）
- 添加docstring文檔
- 使用 black 格式化代碼

**TypeScript (前端)**
- 遵循 Airbnb 風格指南
- 使用接口定義類型
- 使用函數元件和 React Hooks
- 使用 Prettier 格式化代碼

## 測試

### 運行測試

```bash
# 後端單元測試
docker exec -it backend pytest

# 後端測試覆蓋率
docker exec -it backend pytest --cov=app --cov-report=html

# 前端測試
docker exec -it frontend npm test

# 前端測試覆蓋率
docker exec -it frontend npm test -- --coverage
```

### 測試要求

- 後端單元測試覆蓋率 > 80%
- 前端元件測試覆蓋率 > 70%
- 核心功能集成測試覆蓋率 100%

## 性能基準

Phase 1性能目標：

| 指標 | 目標值 | 說明 |
|-----|-------|------|
| 報告列表加載 | < 500ms | 20條/頁 |
| 全文搜尋 | < 2s | 10,000+報告 |
| AI單報告分析 | < 60s | qwen2.5:7b模型 |
| 批量AI分析 | 3並發 | asyncio.Semaphore |
| 報告詳情加載 | < 300ms | 含AI標註 |
| 數據導入 | < 5s | 100條報告 |
| 數據導出 | < 10s | 1000條報告 |

## 常見問題

### Q1: Ollama模型下載失敗？

**原因**：網絡問題或磁盤空間不足

**解決方案**：
```bash
# 檢查Ollama服務狀態
docker exec -it ollama ollama list

# 手動下載模型
docker exec -it ollama ollama pull qwen2.5:7b

# 檢查磁盤空間（需要至少10GB可用空間）
df -h
```

### Q2: AI分析超時或失敗？

**原因**：模型未加載、資源不足或並發過高

**解決方案**：
```bash
# 檢查Ollama健康狀態
curl http://localhost:11434/api/tags

# 查看Ollama日誌
docker-compose logs ollama

# 減少並發分析數（在backend環境變數中設置）
OLLAMA_MAX_CONCURRENT=2
```

### Q3: 全文搜尋速度慢？

**原因**：缺少全文搜尋索引

**解決方案**：
```bash
# 重新創建全文搜尋索引
docker exec -it backend python scripts/rebuild_search_index.py
```

### Q4: 如何重置數據庫？

```bash
# 1. 停止所有服務
docker-compose down

# 2. 刪除PostgreSQL數據卷
docker volume rm image_data_platform_postgres_data

# 3. 重新啟動並初始化
docker-compose up -d
docker exec -it backend alembic upgrade head
docker exec -it backend python scripts/create_admin.py
```

### Q5: 如何切換到GPU加速？

**前提條件**：
- NVIDIA GPU + CUDA支援
- 安裝 nvidia-docker

**修改docker-compose.yml**：
```yaml
ollama:
  image: ollama/ollama:latest
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu]
```

重啟Ollama服務：
```bash
docker-compose up -d ollama
```

## 監控與維護

### 健康檢查

```bash
# 檢查所有服務健康狀態
curl http://localhost:8000/api/v1/health

# 檢查數據庫連接
curl http://localhost:8000/api/v1/health/db

# 檢查Ollama連接
curl http://localhost:8000/api/v1/health/ollama
```

### 數據庫備份

```bash
# 備份數據庫
docker exec postgres pg_dump -U user imagedb > backup_$(date +%Y%m%d).sql

# 恢復數據庫
docker exec -i postgres psql -U user imagedb < backup_20241201.sql
```

### 日誌管理

```bash
# 實時查看所有日誌
docker-compose logs -f

# 查看最近100行日誌
docker-compose logs --tail=100 backend

# 導出日誌到文件
docker-compose logs backend > backend.log
```

## Phase 1 vs Phase 2

### ✅ Phase 1（當前版本）- 8週開發

**核心功能**：
- ✅ 數據導入（Excel/CSV）
- ✅ 全文搜尋和高級篩選
- ✅ AI報告分析（4種類型）
- ✅ 項目管理
- ✅ 數據導出

**技術棧**：
- 4個Docker服務
- PostgreSQL全文搜尋
- Ollama本地LLM
- JWT認證

### 🔮 Phase 2（未來擴展）- 待規劃

**擴展功能**：
- ⏳ DICOM影像上傳和查看
- ⏳ MinIO對象存儲
- ⏳ Cornerstone.js影像查看器
- ⏳ Accssyn/Red Report集成
- ⏳ 高級影像處理（MPR、MIP等）
- ⏳ Redis緩存和Celery任務隊列
- ⏳ Elasticsearch高性能搜尋

> 💡 Phase 1完成並穩定運行後，將根據實際需求啟動Phase 2開發。

## 貢獻指南

我們歡迎所有形式的貢獻！

### 貢獻流程

1. Fork 本項目
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 創建 Pull Request

### 報告問題

- 使用GitHub Issues報告bug
- 提供詳細的複現步驟
- 附上相關日誌和截圖

## 許可證

本項目採用 MIT 許可證 - 詳見 [LICENSE](LICENSE) 文件

## 聯繫方式

- **項目負責人**：[Your Name]
- **郵箱**：your.email@example.com
- **項目地址**：https://github.com/your-org/image_data_platform

## 致謝

感謝以下開源項目和工具：

- [FastAPI](https://fastapi.tiangolo.com/) - 現代化高性能Python Web框架
- [Ant Design](https://ant.design/) - 企業級UI設計語言和React元件庫
- [Ollama](https://ollama.com/) - 本地大語言模型運行環境
- [PostgreSQL](https://www.postgresql.org/) - 世界上最先進的開源關係數據庫
- [React](https://react.dev/) - 用於構建用戶界面的JavaScript庫

---

**最後更新**：2024-12-01
**文檔版本**：v2.0.0 (Phase 1)
**維護團隊**：影像數據平台開發團隊
