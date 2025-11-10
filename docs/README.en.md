# Image Data Platform - Phase 1: AI-Assisted Report Screening System

An AI-driven medical report management and intelligent analysis platform based on 2020-2024 PAPA data.

## Project Overview

Phase 1 of this project focuses on building an **AI-assisted medical report screening and management system** that leverages locally deployed large language models (Ollama) to enable intelligent analysis, classification, and information extraction from medical reports, helping researchers quickly filter and manage large volumes of medical imaging reports.

### Phase 1 Core Features

- **📂 Data Import**: Support batch import of medical reports from Excel/CSV
- **🔍 Intelligent Retrieval**: PostgreSQL full-text search with advanced filtering support
- **🤖 AI Analysis**: Local LLM (Ollama) for report annotation, classification, extraction, and scoring
- **📊 Project Management**: Multi-project management with flexible organization and categorization
- **📥 Data Export**: Support Excel/CSV export with AI analysis results

### Phase 2 Planning (Future Expansion)

- DICOM image storage and viewing (MinIO + Cornerstone.js)
- External system integration (Accssyn, Red Report)
- Advanced image processing capabilities
- Enhanced AI analysis capabilities

## Technology Stack

### Frontend
- React 18+ with TypeScript
- Ant Design (UI Component Library)
- Zustand (State Management)
- Axios (HTTP Client)
- Vite (Build Tool)

### Backend
- Python 3.11 + FastAPI
- PostgreSQL 14+ (Main Database with Full-Text Search)
- SQLAlchemy + Alembic (ORM and Database Migration)
- Pydantic (Data Validation)

### AI Engine
- **Ollama** (Local LLM Service)
- **qwen2.5:7b** (Recommended Model: 7B Parameters, 4.4GB)
- httpx (Async HTTP Client)

### Deployment
- Docker + Docker Compose
- 4 Core Services: PostgreSQL, Ollama, Backend, Frontend

## Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Git
- At least 16GB RAM (for running Ollama LLM)
- (Optional) NVIDIA GPU + CUDA support (for GPU acceleration)

### 5-Step Quick Deployment

**1. Clone the Project**
```bash
git clone https://github.com/your-org/image_data_platform.git
cd image_data_platform
```

**2. Configure Environment Variables**
```bash
cp .env.example .env
nano .env  # Modify configuration as needed
```

Required environment variables:
```env
# Database Configuration
DATABASE_URL=postgresql://user:password@postgres:5432/imagedb
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=imagedb

# JWT Authentication
SECRET_KEY=your_very_secure_random_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Ollama Configuration
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_MODEL=qwen2.5:7b
OLLAMA_TIMEOUT=60
```

**3. Start All Services**
```bash
docker-compose up -d
```

Wait for all services to start (approximately 2-3 minutes).

**4. Download Ollama Model and Initialize Database**
```bash
# Download qwen2.5:7b model (approximately 4.4GB, requires 5-10 minutes)
docker exec -it ollama ollama pull qwen2.5:7b

# Run database migration
docker exec -it backend alembic upgrade head

# Create initial admin account
docker exec -it backend python scripts/create_admin.py
```

**5. Access the Application**
- **Frontend**: http://localhost:3000
- **Backend API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/api/v1/health

### Default Admin Account

- **Email**: admin@hospital.com
- **Password**: Admin@123456

> ⚠️ **Security Notice**: Please change the default password immediately after first login!

## Project Structure

```
image_data_platform/
├── backend/                       # FastAPI Backend
│   ├── app/
│   │   ├── api/                  # API Route Modules
│   │   │   ├── auth.py           # Authentication Endpoints
│   │   │   ├── import_data.py    # Data Import
│   │   │   ├── reports.py        # Report Management
│   │   │   ├── ai_analysis.py    # AI Analysis
│   │   │   ├── projects.py       # Project Management
│   │   │   └── export.py         # Data Export
│   │   ├── core/                 # Core Configuration
│   │   │   ├── config.py         # App Configuration
│   │   │   └── security.py       # JWT Authentication
│   │   ├── models/               # SQLAlchemy Models
│   │   │   ├── user.py
│   │   │   ├── report.py
│   │   │   ├── ai_annotation.py
│   │   │   └── project.py
│   │   ├── schemas/              # Pydantic Schemas
│   │   ├── services/             # Business Logic
│   │   │   ├── ollama_client.py  # Ollama Client
│   │   │   ├── import_service.py # Import Service
│   │   │   └── export_service.py # Export Service
│   │   └── main.py               # FastAPI App Entry Point
│   ├── alembic/                  # Database Migration
│   ├── tests/                    # Test Code
│   ├── requirements.txt          # Python Dependencies
│   └── Dockerfile
│
├── frontend/                      # React Frontend
│   ├── src/
│   │   ├── components/           # Reusable Components
│   │   ├── pages/                # Pages
│   │   │   ├── Login.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   ├── DataImport.tsx
│   │   │   ├── ReportSearch.tsx
│   │   │   ├── AIAnalysis.tsx
│   │   │   └── Projects.tsx
│   │   ├── services/             # API Clients
│   │   ├── store/                # Zustand State
│   │   ├── types/                # TypeScript Types
│   │   └── App.tsx
│   ├── package.json
│   └── Dockerfile
│
├── docs/                          # Project Documentation
│   ├── 00_DOCUMENTATION_INDEX.md # Documentation Index
│   ├── 01_PROJECT_OVERVIEW.md    # Project Overview
│   ├── architecture/             # Architecture Design
│   │   └── 02_TECHNICAL_ARCHITECTURE.md
│   ├── database/                 # Database Design
│   │   └── 03_DATABASE_DESIGN.md
│   ├── api/                      # API Documentation
│   │   └── 04_API_SPECIFICATION.md
│   ├── workflow/                 # Development Workflow
│   │   └── 05_DEVELOPMENT_WORKFLOW.md
│   ├── requirements/             # Requirements Documents
│   │   ├── USER_REQUIREMENTS.md
│   │   └── FUNCTIONAL_SPECIFICATION.md
│   └── guides/                   # Development Guides
│       └── AI_INTEGRATION_GUIDE.md
│
├── docker-compose.yml             # Docker Orchestration Configuration
├── .env.example                   # Environment Variables Template
└── README.md                      # This File
```

## Core Documentation

### 📖 Essential Documentation (Reading Order)

1. **[Project Overview](./docs/01_PROJECT_OVERVIEW.md)** - Understand project background, Phase 1 goals, and feature modules
2. **[Technical Architecture Design](./docs/architecture/02_TECHNICAL_ARCHITECTURE.md)** - System architecture, technology selection, and code examples
3. **[AI Integration Guide](./docs/guides/AI_INTEGRATION_GUIDE.md)** - Ollama deployment, configuration, and usage details
4. **[Database Design](./docs/database/03_DATABASE_DESIGN.md)** - Complete design of 5 core tables
5. **[API Specification](./docs/api/04_API_SPECIFICATION.md)** - Detailed documentation of 20 API endpoints
6. **[Development Workflow](./docs/workflow/05_DEVELOPMENT_WORKFLOW.md)** - 8-week Phase 1 development plan

### 📚 Requirements and Specification Documents

- [User Requirements](./docs/requirements/USER_REQUIREMENTS.md) - 7 core requirement definitions
- [Functional Specification](./docs/requirements/FUNCTIONAL_SPECIFICATION.md) - Detailed functional specifications

### 🗂️ Complete Documentation Index

See [Documentation Index](./docs/00_DOCUMENTATION_INDEX.md) for complete documentation list and reading guide.

## AI Analysis Features

The system provides 4 types of AI analysis using Ollama local LLM:

### 1. 🔍 Highlight Annotation
Automatically identifies and annotates key information in reports:
- Abnormal findings (abnormal)
- Measurement values (measurement)
- Anatomical locations (location)
- Diagnostic conclusions (diagnosis)

### 2. 📋 Classification Annotation
Multi-dimensional report classification:
- Abnormality level (Normal/Mild/Moderate/Severe)
- Lesion type (Benign/Malignant/Uncertain)
- Image quality assessment
- Urgency grading

### 3. 📊 Information Extraction
Structured extraction of report information:
- Main findings list
- Measurement values (with units)
- Involved anatomical structures
- Impressions and conclusions

### 4. ⭐ Quality Scoring
Multi-dimensional report quality assessment:
- Completeness (0-10 points)
- Clarity (0-10 points)
- Detail level (0-10 points)
- Clinical value (0-10 points)

> 💡 For detailed usage guides and examples, see [AI Integration Guide](./docs/guides/AI_INTEGRATION_GUIDE.md)

## Docker Services Overview

Phase 1 uses 4 Docker services (simplified architecture):

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| **postgres** | postgres:14-alpine | 5432 | PostgreSQL Database |
| **ollama** | ollama/ollama:latest | 11434 | Ollama LLM Service |
| **backend** | Custom Build | 8000 | FastAPI Backend |
| **frontend** | Custom Build | 3000 | React Frontend |

Check service status:
```bash
docker-compose ps
```

View service logs:
```bash
# View all services
docker-compose logs -f

# View specific service
docker-compose logs -f backend
docker-compose logs -f ollama
```

## Development Standards

### Git Workflow

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Commit code (using standardized commit messages)
git add .
git commit -m "feat(module): add new feature"

# 3. Push branch
git push origin feature/your-feature-name

# 4. Create Pull Request
```

### Commit Message Standards

```
<type>(<scope>): <subject>

type: feat, fix, docs, style, refactor, test, chore
scope: auth, import, search, ai, project, export
subject: Brief description (English or Chinese)

Examples:
feat(ai): add batch analysis API endpoint
fix(search): resolve full-text search timeout
docs(readme): update Ollama setup instructions
```

### Code Style

**Python (Backend)**
- Follow PEP 8
- Use type hints
- Add docstring documentation
- Use black for code formatting

**TypeScript (Frontend)**
- Follow Airbnb style guide
- Use interfaces for type definitions
- Use functional components and React Hooks
- Use Prettier for code formatting

## Testing

### Running Tests

```bash
# Backend unit tests
docker exec -it backend pytest

# Backend test coverage
docker exec -it backend pytest --cov=app --cov-report=html

# Frontend tests
docker exec -it frontend npm test

# Frontend test coverage
docker exec -it frontend npm test -- --coverage
```

### Test Requirements

- Backend unit test coverage > 80%
- Frontend component test coverage > 70%
- Core functionality integration test coverage 100%

## Performance Benchmarks

Phase 1 performance targets:

| Metric | Target | Description |
|--------|--------|-------------|
| Report List Loading | < 500ms | 20 items/page |
| Full-Text Search | < 2s | 10,000+ reports |
| AI Single Report Analysis | < 60s | qwen2.5:7b model |
| Batch AI Analysis | 3 concurrent | asyncio.Semaphore |
| Report Detail Loading | < 300ms | With AI annotations |
| Data Import | < 5s | 100 reports |
| Data Export | < 10s | 1000 reports |

## FAQs

### Q1: Ollama Model Download Failed?

**Reason**: Network issues or insufficient disk space

**Solution**:
```bash
# Check Ollama service status
docker exec -it ollama ollama list

# Manually download model
docker exec -it ollama ollama pull qwen2.5:7b

# Check disk space (need at least 10GB free)
df -h
```

### Q2: AI Analysis Timeout or Failed?

**Reason**: Model not loaded, insufficient resources, or high concurrency

**Solution**:
```bash
# Check Ollama health
curl http://localhost:11434/api/tags

# View Ollama logs
docker-compose logs ollama

# Reduce concurrent analysis (set in backend environment variables)
OLLAMA_MAX_CONCURRENT=2
```

### Q3: Full-Text Search Slow?

**Reason**: Missing full-text search index

**Solution**:
```bash
# Rebuild full-text search index
docker exec -it backend python scripts/rebuild_search_index.py
```

### Q4: How to Reset Database?

```bash
# 1. Stop all services
docker-compose down

# 2. Delete PostgreSQL data volume
docker volume rm image_data_platform_postgres_data

# 3. Restart and initialize
docker-compose up -d
docker exec -it backend alembic upgrade head
docker exec -it backend python scripts/create_admin.py
```

### Q5: How to Enable GPU Acceleration?

**Prerequisites**:
- NVIDIA GPU + CUDA support
- nvidia-docker installed

**Modify docker-compose.yml**:
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

Restart Ollama:
```bash
docker-compose up -d ollama
```

## Monitoring and Maintenance

### Health Check

```bash
# Check all services health
curl http://localhost:8000/api/v1/health

# Check database connection
curl http://localhost:8000/api/v1/health/db

# Check Ollama connection
curl http://localhost:8000/api/v1/health/ollama
```

### Database Backup

```bash
# Backup database
docker exec postgres pg_dump -U user imagedb > backup_$(date +%Y%m%d).sql

# Restore database
docker exec -i postgres psql -U user imagedb < backup_20241201.sql
```

### Log Management

```bash
# View all logs in real-time
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100 backend

# Export logs to file
docker-compose logs backend > backend.log
```

## Phase 1 vs Phase 2

### ✅ Phase 1 (Current Version) - 8 Weeks Development

**Core Features**:
- ✅ Data Import (Excel/CSV)
- ✅ Full-Text Search and Advanced Filtering
- ✅ AI Report Analysis (4 types)
- ✅ Project Management
- ✅ Data Export

**Technology Stack**:
- 4 Docker services
- PostgreSQL full-text search
- Ollama local LLM
- JWT authentication

### 🔮 Phase 2 (Future Expansion) - TBD

**Extended Features**:
- ⏳ DICOM image upload and viewing
- ⏳ MinIO object storage
- ⏳ Cornerstone.js image viewer
- ⏳ Accssyn/Red Report integration
- ⏳ Advanced image processing (MPR, MIP, etc.)
- ⏳ Redis caching and Celery task queue
- ⏳ Elasticsearch high-performance search

> 💡 Phase 2 development will start after Phase 1 is stable and production-ready.

## Contribution Guide

We welcome all forms of contributions!

### Contribution Process

1. Fork this project
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Create Pull Request

### Report Issues

- Use GitHub Issues to report bugs
- Provide detailed reproduction steps
- Attach relevant logs and screenshots

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details

## Contact

- **Project Lead**: [Your Name]
- **Email**: your.email@example.com
- **Project URL**: https://github.com/your-org/image_data_platform

## Acknowledgments

We thank the following open-source projects and tools:

- [FastAPI](https://fastapi.tiangolo.com/) - Modern, fast Python web framework
- [Ant Design](https://ant.design/) - Enterprise-grade UI design language and React component library
- [Ollama](https://ollama.com/) - Local large language model runtime environment
- [PostgreSQL](https://www.postgresql.org/) - The World's Most Advanced Open Source Relational Database
- [React](https://react.dev/) - A JavaScript library for building user interfaces

---

**Last Updated**: 2024-12-01
**Documentation Version**: v2.0.0 (Phase 1)
**Maintenance Team**: Image Data Platform Development Team
