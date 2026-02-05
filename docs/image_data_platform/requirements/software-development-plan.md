# 軟體開發規劃 (Software Development Plan)

**文件 ID**: IDP-REQ-SDP-001  
**標題**: image_data_platform 專案軟體開發規劃  
**版本**: v1.0.0-Phase1  
**狀態**: ✅ Active  
**建立日期**: 2025-12-26  
**最後更新**: 2025-12-26

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v1.0 | 2025-12-26 | AI | 建立軟體開發規劃文件，符合 IEC 62304:2006 第 5.1 條款要求 |

---

## 1. 文件概述

### 1.1 目的

本文件定義 `image_data_platform` 專案的軟體開發規劃，符合 IEC 62304:2006+AMD1:2015 醫療器材軟體生命週期標準第 5.1 條款（Software Development Planning）要求。

本文件提供：
- 開發模型說明
- 開發階段劃分與時程規劃
- 交付物清單
- 開發標準與規範
- 測試策略與驗收標準
- 風險管理計劃

### 1.2 範圍

本開發規劃適用於：
- **專案階段**: Phase 1（8 週開發計劃）
- **產品範圍**: image_data_platform（AI 輔助醫療影像報告篩選與管理系統）
- **開發活動**: 從需求分析到系統測試的完整軟體開發生命週期

### 1.3 適用標準

本開發規劃 **MUST** 符合以下標準要求：
- **IEC 62304:2006+AMD1:2015**: 醫療器材軟體生命週期流程
- **ISO 13485:2016**: 醫療器材品質管理系統
- **ISO 14971:2019**: 醫療器材風險管理
- **RFC 2119**: 需求關鍵字規範

### 1.4 相關文檔

- [`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md) - 系統層需求與設計
- [`guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md`](../guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md) - 專案概覽與工作流指南
- [`regulations/IEC-62304-Software-Lifecycle-Process.md`](../regulations/IEC-62304-Software-Lifecycle-Process.md) - IEC 62304 軟體生命週期流程
- [`regulations/quality-management-system.md`](../regulations/quality-management-system.md) - 品質管理系統

---

## 2. 開發模型（Development Model）

### 2.1 開發模型選擇

本專案採用 **迭代式開發模型（Iterative Development Model）**，結合 **V 模型（V-Model）** 的驗證與確認活動。

#### 2.1.1 迭代式開發

- **Phase 1**: 核心功能開發（8 週）
  - 資料匯入與管理
  - 報告檢索與篩選
  - AI 輔助分析
  - 專案管理
  - 資料匯出

- **Phase 2**: 功能擴展（未來規劃）
  - DICOM 影像支援
  - 影像檢視器整合
  - 高級分析功能

#### 2.1.2 V 模型驗證活動

每個開發階段對應相應的驗證活動：

```
需求分析 (5.2)  ←→  系統測試 (5.7)
架構設計 (5.3)  ←→  整合測試 (5.6)
詳細設計 (5.4)  ←→  單元測試 (5.5)
實作 (5.5)
```

### 2.2 開發流程

本專案遵循 IEC 62304 軟體生命週期流程：

1. **5.1 軟體開發規劃**（本文件）
2. **5.2 軟體需求分析** - 定義並文件化軟體需求
3. **5.3 軟體架構設計** - 將需求轉換為架構設計
4. **5.4 軟體詳細設計** - 細化架構設計為詳細設計
5. **5.5 軟體單元實作與驗證** - 實作軟體單元並執行單元測試
6. **5.6 軟體整合與整合測試** - 整合軟體單元並執行整合測試
7. **5.7 軟體系統測試** - 執行系統測試驗證需求滿足
8. **5.8 軟體發布** - 準備發布文檔與安裝說明

---

## 3. 開發階段總覽（Phase 1 - 8 週計劃）

### 3.1 階段劃分

| 週次 | 階段 | 主要活動 | 交付物 |
|------|------|---------|--------|
| **Week 1-2** | 基礎架構與資料匯入 | 環境搭建、資料庫設計、認證系統、資料匯入功能 | 基礎架構、認證系統、資料匯入 API |
| **Week 3-4** | 報告檢索與 AI 整合 | 全文搜尋、多維度篩選、Ollama AI 整合 | 搜尋功能、AI 分析 API |
| **Week 5-6** | AI 分析優化與專案管理 | AI 結果視覺化、專案管理功能 | AI 分析介面、專案管理系統 |
| **Week 7** | 測試與優化 | 單元測試、整合測試、性能優化 | 測試報告、優化成果 |
| **Week 8** | 部署與培訓 | 生產部署、用戶培訓、文檔交付 | 部署環境、培訓材料、用戶手冊 |

### 3.2 開發時程圖

```
Week 1-2: 基礎架構和資料匯入     ████████░░░░░░░░░░░░░░
Week 3-4: 報告檢索和AI整合        ░░░░░░░░████████░░░░░░
Week 5-6: AI分析和專案管理        ░░░░░░░░░░░░░░░░████░░
Week 7:   測試和優化              ░░░░░░░░░░░░░░░░░░░███
Week 8:   部署和培訓              ░░░░░░░░░░░░░░░░░░░░██
```

---

## 4. 每週詳細任務清單

### 4.1 Week 1-2: 基礎架構與資料匯入

#### Week 1: 專案初始化與開發環境

**目標**: 搭建完整的 Phase 1 開發環境，建立專案代碼結構

**任務清單**:

**Day 1-2: 環境準備**
- [x] Docker 環境配置（PostgreSQL 14、Ollama 服務）
- [x] 後端框架初始化（Django + Django Ninja）
- [x] 前端框架搭建（React + TypeScript + Ant Design）
- [x] 資料庫設計實施（5 張核心表）
- [x] Git 倉庫建立與規範配置

**Day 3-4: 資料庫與基礎服務**
- [x] 資料庫表結構建立（users, reports, ai_annotations, projects, project_reports）
- [x] 全文搜尋索引配置（GIN 索引）
- [x] JSONB 索引配置
- [x] Ollama 模型下載與配置（qwen2.5:7b）

**Day 5: 基礎 API 與健康檢查**
- [x] 健康檢查端點
- [x] 基礎 API 結構
- [x] 環境變數管理

**交付物**:
- Docker Compose 配置（4 服務：PostgreSQL, Ollama, Backend, Frontend）
- 資料庫遷移腳本
- 基礎專案結構

#### Week 2: 認證授權與資料匯入

**目標**: 實現 JWT 認證授權系統，開發報告資料匯入功能

**任務清單**:

**Day 1-2: JWT 認證系統**
- [x] 後端認證 API（登入/登出、JWT 令牌生成與驗證）
- [x] 前端認證（登入頁面、路由守衛、Token 自動刷新）
- [x] 基於角色的權限檢查（admin/researcher）

**Day 3-4: 報告匯入功能**
- [x] 後端匯入 API（Excel/CSV 檔案解析、欄位驗證、批次匯入）
- [x] 前端匯入頁面（檔案上傳、欄位映射、資料預覽、匯入進度）

**Day 5: 基礎前端頁面**
- [x] Dashboard 頁面（統計卡片、最近匯入記錄）
- [x] 報告列表頁面（基礎表格、簡單搜尋、分頁）

**交付物**:
- JWT 認證系統
- 資料匯入功能（支援 Excel/CSV）
- 基礎前端頁面

### 4.2 Week 3-4: 報告檢索與 AI 整合

#### Week 3: 報告搜尋與篩選

**目標**: 實現強大的報告搜尋功能，開發多維度篩選系統

**任務清單**:

**Day 1-2: 全文搜尋 API**
- [x] PostgreSQL 全文搜尋實現（to_tsvector、中文支援）
- [x] 多欄位搜尋（report_content + diagnosis）
- [x] 搜尋結果高亮
- [x] 搜尋性能優化（GIN 索引）

**Day 3-4: 前端搜尋介面**
- [x] 高級搜尋組件（搜尋輸入框、篩選器面板、搜尋歷史）
- [x] 搜尋結果展示（表格展示、關鍵詞高亮、快速操作）

**Day 5: 報告詳情頁面**
- [x] 報告詳情展示（患者資訊、報告內容、歷史 AI 分析記錄）

**交付物**:
- 全文搜尋功能（支援中文）
- 多維度篩選系統
- 報告詳情頁面

#### Week 4: Ollama AI 整合

**目標**: 集成 Ollama 本地 LLM，實現 4 種 AI 標註功能

**任務清單**:

**Day 1-2: OllamaClient 實現**
- [x] Ollama 客戶端封裝（httpx 異步客戶端）
- [x] 4 種標註類型的 system prompt（highlight/classification/extraction/scoring）
- [x] 並發控制（asyncio.Semaphore）
- [x] 錯誤處理與重試機制

**Day 3-4: AI 分析 API**
- [x] 單報告分析端點（POST /api/v1/ai/analyze）
- [x] 批次分析端點（POST /api/v1/ai/batch-analyze）
- [x] 獲取標註結果（GET /api/v1/ai/annotations/{report_id}）
- [x] 刪除標註（DELETE /api/v1/ai/annotations/{id}）

**Day 5: AI 分析前端**
- [x] AI 分析對話框（分析需求輸入、標註類型選擇、溫度參數調整）
- [x] 分析進度顯示
- [x] 結果視覺化展示

**交付物**:
- Ollama AI 整合（4 種標註類型）
- AI 分析 API
- AI 分析前端介面

### 4.3 Week 5-6: AI 分析優化與專案管理

#### Week 5: AI 分析結果視覺化

**目標**: 優化 AI 分析結果展示，實現標註結果的交互式查看

**任務清單**:

**Day 1-2: 標註結果視覺化**
- [x] Highlight 標註展示（文本高亮、不同類別顏色）
- [x] Classification 分類展示（分類標籤、置信度視覺化）
- [x] Extraction 提取結果（結構化資料表格、測量資料圖表化）
- [x] Scoring 評分展示（雷達圖/柱狀圖、各維度評分詳情）

**Day 3-4: AI 分析歷史管理**
- [x] 分析歷史列表（按報告查看歷史分析、時間軸展示）
- [x] 對比不同分析結果
- [x] 刪除/匯出分析結果

**Day 5: 批次分析監控**
- [x] 批次分析進度（即時進度顯示、成功/失敗統計、錯誤報告）

**交付物**:
- AI 分析結果視覺化組件
- AI 分析歷史管理功能
- 批次分析監控功能

#### Week 6: 專案管理功能

**目標**: 實現完整的專案 CRUD 功能，開發報告與專案的關聯管理

**任務清單**:

**Day 1-2: 專案管理 API**
- [x] 專案 CRUD 端點（建立、取得、更新、刪除專案）
- [x] 報告關聯管理（新增報告到專案、從專案移除報告、批次新增）

**Day 3-4: 專案前端頁面**
- [x] 專案列表頁面（專案卡片展示、建立專案對話框、搜尋和篩選）
- [x] 專案詳情頁面（專案基本資訊、包含報告列表、新增報告功能、專案統計資訊）

**Day 5: 資料匯出功能**
- [x] 匯出 API 實現（Excel/CSV/JSON 匯出，包含 AI 分析結果選項）

**交付物**:
- 專案管理系統（CRUD + 報告關聯）
- 專案前端頁面
- 資料匯出功能（Excel/CSV/JSON）

### 4.4 Week 7: 測試與優化

**目標**: 完成單元測試與整合測試，進行性能優化

**任務清單**:

**Day 1-2: 測試覆蓋**
- [x] 後端測試（單元測試、整合測試、API 端到端測試）
- [x] 前端測試（組件單元測試、E2E 測試）
- [x] 測試覆蓋率目標：≥ 80%

**Day 3-4: 性能優化**
- [x] 後端優化（資料庫查詢優化、API 響應時間優化、Ollama 並發控制優化）
- [x] 前端優化（代碼分割、虛擬滾動、圖片懶載入、打包優化）

**Day 5: Bug 修復與安全加固**
- [x] 修復測試中發現的 bug
- [x] 安全檢查（SQL 注入防護、XSS 防護、CORS 配置、密碼強度要求）

**交付物**:
- 測試報告（覆蓋率 ≥ 80%）
- 性能優化成果
- 安全檢查報告

### 4.5 Week 8: 部署與培訓

**目標**: 完成生產環境部署，配置監控和日誌，完成用戶培訓

**任務清單**:

**Day 1-2: 生產環境部署**
- [x] 伺服器配置（Docker、Docker Compose、防火牆規則）
- [x] Docker 生產部署（生產 Docker 鏡像、docker-compose.prod.yml、環境變數配置）
- [x] 資料庫遷移執行
- [x] 初始管理員帳號建立

**Day 3: 監控和日誌**
- [x] 監控配置（系統監控、Ollama 服務監控、資料庫監控、告警規則）
- [x] 日誌管理（日誌輪轉、日誌級別設置、關鍵操作日誌記錄）

**Day 4-5: 用戶培訓與文檔交付**
- [x] 用戶培訓（系統功能演示、資料匯入演示、AI 分析功能演示、專案管理演示）
- [x] 文檔交付（用戶操作手冊、管理員手冊、API 文檔、常見問題 FAQ）

**交付物**:
- 生產環境部署
- 監控與日誌系統
- 用戶培訓材料
- 完整文檔

---

## 5. 技術實施細節

### 5.1 技術堆疊

#### 5.1.1 後端技術

- **框架**: Django 4.2
- **API 框架**: Django Ninja
- **資料庫**: PostgreSQL 15
- **ORM**: Django ORM
- **認證**: JWT (djangorestframework-simplejwt)
- **AI 整合**: Ollama (本地 LLM)

#### 5.1.2 前端技術

- **框架**: React 18 + TypeScript
- **UI 庫**: Ant Design 5
- **狀態管理**: Zustand
- **路由**: React Router v6
- **HTTP 客戶端**: Axios
- **圖表庫**: @ant-design/charts

#### 5.1.3 開發工具

- **版本控制**: Git
- **容器化**: Docker + Docker Compose
- **變更管理**: OpenSpec
- **測試框架**: pytest (後端)、Vitest (前端)

### 5.2 資料庫設計

#### 5.2.1 核心資料表

1. **users**: 用戶表（email, hashed_password, full_name, role, is_active）
2. **reports**: 報告表（patient_id, patient_name, exam_date, exam_type, report_content, diagnosis）
3. **ai_annotations**: AI 標註表（report_id, annotation_type, content (JSONB), confidence）
4. **projects**: 專案表（name, description, created_by）
5. **project_reports**: 專案-報告關聯表（project_id, report_id）

#### 5.2.2 索引設計

- **全文搜尋索引**: GIN 索引（report_content + diagnosis）
- **JSONB 索引**: GIN 索引（ai_annotations.content）
- **外鍵索引**: 自動建立
- **查詢優化索引**: patient_id, exam_date, exam_type

### 5.3 API 設計

#### 5.3.1 API 端點結構

```
/api/v1/
├── auth/
│   ├── login (POST)
│   └── logout (POST)
├── reports/
│   ├── (GET) - 搜尋報告
│   ├── {id} (GET) - 取得報告詳情
│   └── import (POST) - 匯入報告
├── ai/
│   ├── analyze (POST) - 單報告分析
│   ├── batch-analyze (POST) - 批次分析
│   └── annotations/{report_id} (GET) - 取得標註結果
└── projects/
    ├── (GET) - 取得專案列表
    ├── (POST) - 建立專案
    ├── {id} (GET, PUT, DELETE) - 專案 CRUD
    └── {id}/reports (POST, DELETE) - 專案報告管理
```

### 5.4 代碼範例

#### 5.4.1 後端認證範例

```python
# backend/app/api/auth.py
from ninja import Router
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken

router = Router()

@router.post("/login")
def login(request, credentials: LoginSchema):
    user = authenticate(
        username=credentials.email,
        password=credentials.password
    )
    if user:
        refresh = RefreshToken.for_user(user)
        return {
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh)
        }
    raise HttpError(401, "Invalid credentials")
```

#### 5.4.2 前端 API 呼叫範例

```typescript
// frontend/src/services/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000',
});

// 請求攔截器 - 添加 token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
```

---

## 6. 測試策略與驗收標準

### 6.1 測試策略

#### 6.1.1 測試層級

1. **單元測試**: 測試單個函數或模組
   - 後端: pytest
   - 前端: Vitest + React Testing Library
   - 目標覆蓋率: ≥ 80%

2. **整合測試**: 測試模組間的整合
   - API 端到端測試
   - 資料庫整合測試
   - 前後端整合測試

3. **系統測試**: 測試完整系統功能
   - 功能測試
   - 性能測試
   - 安全測試

4. **驗收測試**: 用戶驗收測試
   - 用戶場景測試
   - 可用性測試

#### 6.1.2 測試計劃

| 測試類型 | 測試範圍 | 執行時機 | 責任人 |
|---------|---------|---------|--------|
| **單元測試** | 所有函數與模組 | 開發過程中 | 開發團隊 |
| **整合測試** | API 端點、資料庫操作 | 功能完成後 | 開發團隊 + QA |
| **系統測試** | 完整功能流程 | Phase 1 完成前 | QA 團隊 |
| **驗收測試** | 用戶場景 | 部署前 | 產品負責人 + 用戶 |

### 6.2 驗收標準

#### 6.2.1 功能驗收標準

- [x] 所有 Phase 1 功能需求已實現
- [x] 所有 API 端點正常運作
- [x] 前端頁面功能完整
- [x] 資料匯入功能正常（支援 Excel/CSV）
- [x] 全文搜尋功能正常（支援中文）
- [x] AI 分析功能正常（4 種標註類型）
- [x] 專案管理功能正常

#### 6.2.2 性能驗收標準

- [x] API 響應時間 < 500ms（報告列表查詢）
- [x] 全文搜尋響應時間 < 2s
- [x] AI 單報告分析時間 < 60s
- [x] 前端 FCP (First Contentful Paint) < 1.5s
- [x] 前端 TTI (Time to Interactive) < 3s

#### 6.2.3 品質驗收標準

- [x] 測試覆蓋率 ≥ 80%
- [x] 無嚴重缺陷（Critical/High）
- [x] 代碼審查通過率 100%
- [x] 文檔完整性 100%

---

## 7. 風險管理計劃

### 7.1 技術風險

| 風險項 | 概率 | 影響 | 應對措施 |
|--------|------|------|----------|
| **Ollama 性能不足** | 中 | 高 | 使用 GPU 加速；考慮雲 API fallback |
| **中文分詞問題** | 低 | 中 | 使用 PostgreSQL simple 詞典；測試覆蓋 |
| **資料匯入相容性** | 中 | 中 | 支援多種檔案格式；詳細錯誤提示 |
| **並發性能瓶頸** | 低 | 中 | 信號量限流；資料庫連接池優化 |

### 7.2 專案風險

| 風險項 | 概率 | 影響 | 應對措施 |
|--------|------|------|----------|
| **需求變更** | 中 | 中 | 敏捷開發；MVP 優先；定期溝通 |
| **時間延誤** | 低 | 中 | 8 週計劃有緩衝；核心功能優先 |
| **資源不足** | 低 | 高 | 簡化 Phase 1 範圍；Phase 2 擴展 |
| **AI 準確性不足** | 中 | 高 | Prompt 優化；用戶反饋迭代；溫度調整 |

### 7.3 風險監控

- **每週風險審查**: 識別新風險、評估現有風險狀態
- **風險日誌**: 記錄所有識別風險與應對措施
- **風險升級**: 高影響風險立即上報技術負責人

詳細風險管理參見：`ISO-14971-Risk-Management-Process.md`

---

## 8. Phase 2 未來擴展規劃

### 8.1 功能擴展

1. **DICOM 影像支援**
   - DICOM 檔案上傳與儲存（MinIO）
   - Cornerstone.js 影像檢視器
   - 影像與報告關聯

2. **Accssyn 自動同步**
   - Accssyn API 整合
   - 定時任務同步（Celery Beat）
   - WebSocket 即時進度

3. **高級分析功能**
   - AI 模型微調（基於反饋資料）
   - 多模態分析（影像+報告）
   - 統計分析與資料視覺化

4. **系統增強**
   - Redis 快取層
   - Elasticsearch 全文搜尋
   - 更多匯出格式（PDF 報告）
   - 行動端適配

### 8.2 時間估算

Phase 2 預計需要額外 8-12 週開發時間。

---

## 9. 開發標準

### 9.1 編碼標準

#### 9.1.1 Python (後端)

- **風格指南**: PEP 8
- **類型提示**: 使用類型提示（typing）
- **文檔字串**: 所有函數必須有 docstring
- **命名規範**: snake_case（變數、函數）、PascalCase（類別）

#### 9.1.2 TypeScript (前端)

- **風格指南**: ESLint + Prettier
- **類型定義**: 使用 interface 定義類型
- **組件規範**: 函數組件 + Hooks
- **命名規範**: camelCase（變數、函數）、PascalCase（組件、類別）

### 9.2 文檔標準

- **文檔格式**: Markdown
- **文檔編碼**: UTF-8
- **版本控制**: 語意化版本（Semantic Versioning）
- **變更管理**: OpenSpec 變更管理系統

### 9.3 Git 工作流

- **分支策略**: Git Flow
  - `main`: 生產環境代碼
  - `develop`: 開發主分支
  - `feature/*`: 功能分支
  - `bugfix/*`: Bug 修復分支

- **提交訊息規範**: Conventional Commits
  ```
  <type>(<scope>): <subject>
  
  <body>
  
  <footer>
  ```

### 9.4 代碼審查標準

- **審查要求**: 所有代碼 **MUST** 經過 Pull Request 審查
- **審查重點**: 功能正確性、代碼品質、測試覆蓋、文檔完整性
- **審查人**: 技術負責人或指定審查人

---

## 10. 交付物清單

### 10.1 代碼交付

- [x] 原始碼（Git 倉庫）
- [x] Docker 鏡像
- [x] Docker Compose 配置（開發與生產）
- [x] 資料庫遷移腳本
- [x] 配置檔案模板（.env.example）
- [x] 部署腳本

### 10.2 文檔交付

- [x] 專案概述文檔
- [x] 技術架構文檔
- [x] 資料庫設計文檔
- [x] API 介面文檔（Swagger UI）
- [x] 軟體開發規劃（本文件）
- [x] 用戶操作手冊
- [x] 管理員部署手冊
- [x] 常見問題 FAQ

### 10.3 測試交付

- [x] 單元測試代碼
- [x] 整合測試代碼
- [x] 測試報告（覆蓋率 ≥ 80%）
- [x] 性能測試報告

### 10.4 培訓交付

- [x] 培訓 PPT
- [x] 操作演示影片（可選）
- [x] 快速入門指南
- [x] 培訓簽到表

---

## 11. 參考文檔

### 11.1 相關標準

- IEC 62304:2006+AMD1:2015 - Medical device software — Software life cycle processes
- ISO 13485:2016 - Medical devices — Quality management systems
- ISO 14971:2019 - Medical devices — Application of risk management to medical devices
- RFC 2119 - Key words for use in RFCs to Indicate Requirement Levels

### 11.2 專案文檔

- [`01_SYSTEM_PRD_SR_SD.md`](01_SYSTEM_PRD_SR_SD.md) - 系統層需求與設計
- [`02_FRONTEND_PRD_SR_SD.md`](02_FRONTEND_PRD_SR_SD.md) - 前端層需求與設計
- [`03_BACKEND_PRD_SR_SD.md`](03_BACKEND_PRD_SR_SD.md) - 後端層需求與設計
- [`guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md`](../guides/01_PROJECT_OVERVIEW_AND_WORKFLOW_GUIDE.md) - 專案概覽與工作流指南
- [`regulations/IEC-62304-Software-Lifecycle-Process.md`](../regulations/IEC-62304-Software-Lifecycle-Process.md) - IEC 62304 軟體生命週期流程
- [`regulations/quality-management-system.md`](../regulations/quality-management-system.md) - 品質管理系統

---

**文檔版本**: v1.0.0-Phase1  
**最後更新**: 2025-12-26  
**維護者**: image_data_platform 開發團隊

