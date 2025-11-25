# 影像數據平台 - Phase 1: AI輔助報告篩選系統

基於2020-2024年PAPA數據的AI驅動醫學報告管理和智慧分析平台

## 📚 Language / 語言

- **[繁体中文 (Traditional Chinese)](./docs/README.zh-TW.md)** ← Default / 預設版本
- **[English](./docs/README.en.md)**
- **[简体中文 (Simplified Chinese)](./docs/README.md.bak)** (原始版本)

---

> **Note**: This is a brief overview. For complete documentation, please refer to the language-specific versions above.
>
> **說明**：這是簡要概述。如需完整文檔，請參考上方語言版本。

## 項目概述

本項目第一階段（Phase 1）專注於構建一個**AI輔助的醫學報告篩選和管理系統**，利用本地部署的大語言模型（Ollama）實現報告的智慧分析、分類和資訊提取，幫助研究人員快速篩選和管理大量醫學影像報告。

### Phase 1 核心功能

**✅ 已實現**：
- **🔍 智慧檢索**：PostgreSQL全文搜尋，12個篩選條件（超越規格）
- **📊 項目管理**：多項目管理，4角色權限系統（超越規格）
- **📥 數據導出**：支援Excel/CSV導出完整報告資料
- **🔐 認證系統**：JWT 登入/登出/驗證

**⚠️ 開發中**：
- **📂 數據導入**：Management commands 已實現，API 端點開發中
- **🤖 AI分析**：前端界面已完成，後端 Ollama 整合開發中（預計3週）

## 技術棧

### 前端
- React 18+ with TypeScript
- Ant Design (UI元件庫)
- Zustand (狀態管理)
- Axios (HTTP客戶端)
- Vite (構建工具)

### 後端
- **Python 3.11 + Django 4.2 + Django Ninja** (FastAPI-style framework for Django)
- PostgreSQL 14+ (主數據庫，全文搜尋)
- Django ORM + Migrations (數據庫管理)
- Pydantic 2.5+ (數據驗證，schema定義)

### AI引擎 ⚠️ 規劃中
- **Ollama** (本地LLM服務) - 規劃中，未實現
- **qwen2.5:7b** (推薦模型，7B參數，4.4GB) - 規劃中
- httpx (非同步HTTP客戶端) - 規劃中
- **註**：AI 分析功能前端已完成，後端開發中

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

**3. 啟動所有服務**
```bash
docker-compose up -d
```

**4. 下載Ollama模型並初始化數據庫**
```bash
docker exec -it ollama ollama pull qwen2.5:7b
docker exec -it backend alembic upgrade head
docker exec -it backend python scripts/create_admin.py
```

**5. 訪問應用**
- **前端界面**：http://localhost:3000
- **後端API文檔**：http://localhost:8000/docs
- **健康檢查**：http://localhost:8000/api/v1/health

## 核心文檔

完整文檔請參考：
- **[繁体中文文檔](./docs/README.zh-TW.md)** - 完整的繁體中文版本
- **[English Documentation](./docs/README.en.md)** - Complete English version

## 許可證

本項目採用 MIT 許可證 - 詳見 [LICENSE](LICENSE) 文件

---

**最後更新**：2024-12-01
**維護團隊**：影像數據平台開發團隊
