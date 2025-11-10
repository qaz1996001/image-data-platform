# 影像数据平台 - Phase 1: AI辅助报告筛选系统

基于2020-2024年PAPA数据的AI驱动医学报告管理和智能分析平台

## 项目概述

本项目第一阶段（Phase 1）专注于构建一个**AI辅助的医学报告筛选和管理系统**，利用本地部署的大语言模型（Ollama）实现报告的智能分析、分类和信息提取，帮助研究人员快速筛选和管理大量医学影像报告。

### Phase 1 核心功能

- **📂 数据导入**：支持Excel/CSV批量导入医学报告
- **🔍 智能检索**：PostgreSQL全文搜索，支持复杂条件筛选
- **🤖 AI分析**：本地LLM（Ollama）进行报告标注、分类、提取和评分
- **📊 项目管理**：多项目管理，灵活组织和分类报告
- **📥 数据导出**：支持Excel/CSV导出带AI分析结果

### Phase 2 规划（后续扩展）

- DICOM影像存储和查看（MinIO + Cornerstone.js）
- 外部系统集成（Accssyn、Red Report）
- 高级影像处理功能
- 更多AI分析能力

## 技术栈

### 前端
- React 18+ with TypeScript
- Ant Design (UI组件库)
- Zustand (状态管理)
- Axios (HTTP客户端)
- Vite (构建工具)

### 后端
- Python 3.11 + FastAPI
- PostgreSQL 14+ (主数据库，全文搜索)
- SQLAlchemy + Alembic (ORM和数据库迁移)
- Pydantic (数据验证)

### AI引擎
- **Ollama** (本地LLM服务)
- **qwen2.5:7b** (推荐模型，7B参数，4.4GB)
- httpx (异步HTTP客户端)

### 部署
- Docker + Docker Compose
- 4个核心服务：PostgreSQL、Ollama、Backend、Frontend

## 快速开始

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- Git
- 至少16GB RAM（用于运行Ollama LLM）
- （可选）NVIDIA GPU + CUDA支持（用于GPU加速）

### 5步快速部署

**1. 克隆项目**
```bash
git clone https://github.com/your-org/image_data_platform.git
cd image_data_platform
```

**2. 配置环境变量**
```bash
cp .env.example .env
nano .env  # 根据需要修改配置
```

必需的环境变量：
```env
# 数据库配置
DATABASE_URL=postgresql://user:password@postgres:5432/imagedb
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=imagedb

# JWT认证
SECRET_KEY=your_very_secure_random_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Ollama配置
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_MODEL=qwen2.5:7b
OLLAMA_TIMEOUT=60
```

**3. 启动所有服务**
```bash
docker-compose up -d
```

等待所有服务启动（约2-3分钟）。

**4. 下载Ollama模型并初始化数据库**
```bash
# 下载qwen2.5:7b模型（约4.4GB，需要5-10分钟）
docker exec -it ollama ollama pull qwen2.5:7b

# 运行数据库迁移
docker exec -it backend alembic upgrade head

# 创建初始管理员账号
docker exec -it backend python scripts/create_admin.py
```

**5. 访问应用**
- **前端界面**：http://localhost:3000
- **后端API文档**：http://localhost:8000/docs
- **健康检查**：http://localhost:8000/api/v1/health

### 默认管理员账号

- **邮箱**：admin@hospital.com
- **密码**：Admin@123456

> ⚠️ **安全提示**：首次登录后请立即修改默认密码！

## 项目结构

```
image_data_platform/
├── backend/                       # FastAPI后端
│   ├── app/
│   │   ├── api/                  # API路由模块
│   │   │   ├── auth.py           # 认证端点
│   │   │   ├── import_data.py    # 数据导入
│   │   │   ├── reports.py        # 报告管理
│   │   │   ├── ai_analysis.py    # AI分析
│   │   │   ├── projects.py       # 项目管理
│   │   │   └── export.py         # 数据导出
│   │   ├── core/                 # 核心配置
│   │   │   ├── config.py         # 应用配置
│   │   │   └── security.py       # JWT认证
│   │   ├── models/               # SQLAlchemy模型
│   │   │   ├── user.py
│   │   │   ├── report.py
│   │   │   ├── ai_annotation.py
│   │   │   └── project.py
│   │   ├── schemas/              # Pydantic schemas
│   │   ├── services/             # 业务逻辑
│   │   │   ├── ollama_client.py  # Ollama客户端
│   │   │   ├── import_service.py # 导入服务
│   │   │   └── export_service.py # 导出服务
│   │   └── main.py               # FastAPI应用入口
│   ├── alembic/                  # 数据库迁移
│   ├── tests/                    # 测试代码
│   ├── requirements.txt          # Python依赖
│   └── Dockerfile
│
├── frontend/                      # React前端
│   ├── src/
│   │   ├── components/           # 可复用组件
│   │   ├── pages/                # 页面
│   │   │   ├── Login.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   ├── DataImport.tsx
│   │   │   ├── ReportSearch.tsx
│   │   │   ├── AIAnalysis.tsx
│   │   │   └── Projects.tsx
│   │   ├── services/             # API客户端
│   │   ├── store/                # Zustand状态
│   │   ├── types/                # TypeScript类型
│   │   └── App.tsx
│   ├── package.json
│   └── Dockerfile
│
├── docs/                          # 项目文档
│   ├── 00_DOCUMENTATION_INDEX.md # 文档索引
│   ├── 01_PROJECT_OVERVIEW.md    # 项目概述
│   ├── architecture/             # 架构设计
│   │   └── 02_TECHNICAL_ARCHITECTURE.md
│   ├── database/                 # 数据库设计
│   │   └── 03_DATABASE_DESIGN.md
│   ├── api/                      # API文档
│   │   └── 04_API_SPECIFICATION.md
│   ├── workflow/                 # 开发流程
│   │   └── 05_DEVELOPMENT_WORKFLOW.md
│   ├── requirements/             # 需求文档
│   │   ├── USER_REQUIREMENTS.md
│   │   └── FUNCTIONAL_SPECIFICATION.md
│   └── guides/                   # 开发指南
│       └── AI_INTEGRATION_GUIDE.md  # Ollama集成指南
│
├── docker-compose.yml             # Docker编排配置
├── .env.example                   # 环境变量模板
└── README.md                      # 本文件
```

## 核心文档

### 📖 必读文档（按阅读顺序）

1. **[项目概述](./docs/01_PROJECT_OVERVIEW.md)** - 了解项目背景、Phase 1目标和功能模块
2. **[技术架构设计](./docs/architecture/02_TECHNICAL_ARCHITECTURE.md)** - 系统架构、技术选型和代码示例
3. **[AI集成指南](./docs/guides/AI_INTEGRATION_GUIDE.md)** - Ollama部署、配置和使用详解
4. **[数据库设计](./docs/database/03_DATABASE_DESIGN.md)** - 5张核心表的完整设计
5. **[API接口规范](./docs/api/04_API_SPECIFICATION.md)** - 20个API端点详细文档
6. **[开发工作流](./docs/workflow/05_DEVELOPMENT_WORKFLOW.md)** - 8周Phase 1开发计划

### 📚 需求与规格文档

- [用户需求文档](./docs/requirements/USER_REQUIREMENTS.md) - 7个核心需求定义
- [功能规格说明书](./docs/requirements/FUNCTIONAL_SPECIFICATION.md) - 详细功能规格

### 🗂️ 完整文档索引

查看 [文档索引](./docs/00_DOCUMENTATION_INDEX.md) 获取完整文档列表和阅读指南。

## AI分析功能

系统提供4种AI分析类型，使用Ollama本地LLM实现：

### 1. 🔍 高亮标注 (Highlight)
自动识别和标注报告中的关键信息：
- 异常发现（abnormal）
- 测量数值（measurement）
- 解剖位置（location）
- 诊断结论（diagnosis）

### 2. 📋 分类标注 (Classification)
多维度报告分类：
- 异常程度（正常/轻度/中度/重度异常）
- 病变性质（良性/恶性/不确定）
- 检查质量评估
- 紧急程度分级

### 3. 📊 信息提取 (Extraction)
结构化提取报告信息：
- 主要发现列表
- 测量数值（含单位）
- 涉及解剖部位
- 印象和结论

### 4. ⭐ 质量评分 (Scoring)
多维度报告质量评估：
- 完整性（0-10分）
- 清晰度（0-10分）
- 详细程度（0-10分）
- 临床价值（0-10分）

> 💡 详细使用指南和示例请参考 [AI集成指南](./docs/guides/AI_INTEGRATION_GUIDE.md)

## Docker服务说明

Phase 1使用4个Docker服务（简化架构）：

| 服务 | 镜像 | 端口 | 说明 |
|-----|------|------|------|
| **postgres** | postgres:14-alpine | 5432 | PostgreSQL数据库 |
| **ollama** | ollama/ollama:latest | 11434 | Ollama LLM服务 |
| **backend** | 本地构建 | 8000 | FastAPI后端 |
| **frontend** | 本地构建 | 3000 | React前端 |

查看服务状态：
```bash
docker-compose ps
```

查看服务日志：
```bash
# 查看所有服务
docker-compose logs -f

# 查看特定服务
docker-compose logs -f backend
docker-compose logs -f ollama
```

## 开发规范

### Git工作流

```bash
# 1. 创建功能分支
git checkout -b feature/your-feature-name

# 2. 提交代码（使用规范的commit message）
git add .
git commit -m "feat(module): add new feature"

# 3. 推送分支
git push origin feature/your-feature-name

# 4. 创建Pull Request
```

### 提交信息规范

```
<type>(<scope>): <subject>

type: feat, fix, docs, style, refactor, test, chore
scope: auth, import, search, ai, project, export
subject: 简短描述（中文或英文）

示例:
feat(ai): add batch analysis API endpoint
fix(search): resolve full-text search timeout
docs(readme): update Ollama setup instructions
```

### 代码风格

**Python (Backend)**
- 遵循 PEP 8
- 使用类型提示（Type Hints）
- 添加docstring文档
- 使用 black 格式化代码

**TypeScript (Frontend)**
- 遵循 Airbnb 风格指南
- 使用接口定义类型
- 使用函数组件和 React Hooks
- 使用 Prettier 格式化代码

## 测试

### 运行测试

```bash
# 后端单元测试
docker exec -it backend pytest

# 后端测试覆盖率
docker exec -it backend pytest --cov=app --cov-report=html

# 前端测试
docker exec -it frontend npm test

# 前端测试覆盖率
docker exec -it frontend npm test -- --coverage
```

### 测试要求

- 后端单元测试覆盖率 > 80%
- 前端组件测试覆盖率 > 70%
- 核心功能集成测试覆盖率 100%

## 性能基准

Phase 1性能目标：

| 指标 | 目标值 | 说明 |
|-----|-------|------|
| 报告列表加载 | < 500ms | 20条/页 |
| 全文搜索 | < 2s | 10,000+报告 |
| AI单报告分析 | < 60s | qwen2.5:7b模型 |
| 批量AI分析 | 3并发 | asyncio.Semaphore |
| 报告详情加载 | < 300ms | 含AI标注 |
| 数据导入 | < 5s | 100条报告 |
| 数据导出 | < 10s | 1000条报告 |

## 常见问题

### Q1: Ollama模型下载失败？

**原因**：网络问题或磁盘空间不足

**解决方案**：
```bash
# 检查Ollama服务状态
docker exec -it ollama ollama list

# 手动下载模型
docker exec -it ollama ollama pull qwen2.5:7b

# 检查磁盘空间（需要至少10GB可用空间）
df -h
```

### Q2: AI分析超时或失败？

**原因**：模型未加载、资源不足或并发过高

**解决方案**：
```bash
# 检查Ollama健康状态
curl http://localhost:11434/api/tags

# 查看Ollama日志
docker-compose logs ollama

# 减少并发分析数（在backend环境变量中设置）
OLLAMA_MAX_CONCURRENT=2
```

### Q3: 全文搜索速度慢？

**原因**：缺少全文搜索索引

**解决方案**：
```bash
# 重新创建全文搜索索引
docker exec -it backend python scripts/rebuild_search_index.py
```

### Q4: 如何重置数据库？

```bash
# 1. 停止所有服务
docker-compose down

# 2. 删除PostgreSQL数据卷
docker volume rm image_data_platform_postgres_data

# 3. 重新启动并初始化
docker-compose up -d
docker exec -it backend alembic upgrade head
docker exec -it backend python scripts/create_admin.py
```

### Q5: 如何切换到GPU加速？

**前提条件**：
- NVIDIA GPU + CUDA支持
- 安装 nvidia-docker

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

重启Ollama服务：
```bash
docker-compose up -d ollama
```

## 监控与维护

### 健康检查

```bash
# 检查所有服务健康状态
curl http://localhost:8000/api/v1/health

# 检查数据库连接
curl http://localhost:8000/api/v1/health/db

# 检查Ollama连接
curl http://localhost:8000/api/v1/health/ollama
```

### 数据库备份

```bash
# 备份数据库
docker exec postgres pg_dump -U user imagedb > backup_$(date +%Y%m%d).sql

# 恢复数据库
docker exec -i postgres psql -U user imagedb < backup_20241201.sql
```

### 日志管理

```bash
# 实时查看所有日志
docker-compose logs -f

# 查看最近100行日志
docker-compose logs --tail=100 backend

# 导出日志到文件
docker-compose logs backend > backend.log
```

## Phase 1 vs Phase 2

### ✅ Phase 1（当前版本）- 8周开发

**核心功能**：
- ✅ 数据导入（Excel/CSV）
- ✅ 全文搜索和高级筛选
- ✅ AI报告分析（4种类型）
- ✅ 项目管理
- ✅ 数据导出

**技术栈**：
- 4个Docker服务
- PostgreSQL全文搜索
- Ollama本地LLM
- JWT认证

### 🔮 Phase 2（未来扩展）- 待规划

**扩展功能**：
- ⏳ DICOM影像上传和查看
- ⏳ MinIO对象存储
- ⏳ Cornerstone.js影像查看器
- ⏳ Accssyn/Red Report集成
- ⏳ 高级影像处理（MPR、MIP等）
- ⏳ Redis缓存和Celery任务队列
- ⏳ Elasticsearch高性能搜索

> 💡 Phase 1完成并稳定运行后，将根据实际需求启动Phase 2开发。

## 贡献指南

我们欢迎所有形式的贡献！

### 贡献流程

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 报告问题

- 使用GitHub Issues报告bug
- 提供详细的复现步骤
- 附上相关日志和截图

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

- **项目负责人**：[Your Name]
- **邮箱**：your.email@example.com
- **项目地址**：https://github.com/your-org/image_data_platform

## 致谢

感谢以下开源项目和工具：

- [FastAPI](https://fastapi.tiangolo.com/) - 现代化高性能Python Web框架
- [Ant Design](https://ant.design/) - 企业级UI设计语言和React组件库
- [Ollama](https://ollama.com/) - 本地大语言模型运行环境
- [PostgreSQL](https://www.postgresql.org/) - 世界上最先进的开源关系数据库
- [React](https://react.dev/) - 用于构建用户界面的JavaScript库

---

**最后更新**：2024-12-01
**文档版本**：v2.0.0 (Phase 1)
**维护团队**：影像数据平台开发团队
