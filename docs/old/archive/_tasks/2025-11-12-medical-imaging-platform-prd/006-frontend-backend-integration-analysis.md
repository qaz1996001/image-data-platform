# Frontend與Backend整合分析報告 - 醫療影像AI驗證工作流系統

## 文件資訊
- **建立日期**: 2025-11-12
- **版本**: 1.0
- **目的**: 分析現有frontend與backend_django的匹配程度，並規劃AI驗證工作流系統的整合路徑

---

## 1. 現況總覽

### 1.1 Frontend架構分析

#### 技術棧
```yaml
框架: React 18.3.1 + TypeScript
UI庫: Ant Design 5.28.0
狀態管理: Zustand 5.0.8
路由: React Router DOM 6.24.0
HTTP客戶端: Axios 1.13.2
建置工具: Vite 7.1.7
測試: Vitest 4.0.7
```

#### 目錄結構
```
frontend/src/
├── components/        # UI組件
│   ├── Common/       # 共用組件
│   ├── Dashboard/    # 儀表板組件
│   ├── Layout/       # 佈局組件
│   ├── Projects/     # 專案管理組件
│   └── StudySearch/  # 檢查搜尋組件
├── pages/            # 頁面
│   ├── Dashboard/    # 儀表板頁面
│   ├── StudySearch/  # 檢查搜尋頁面
│   ├── Projects/     # 專案管理頁面
│   ├── AIAnalysis/   # AI分析頁面
│   ├── DataImport/   # 資料匯入頁面
│   ├── ReportSearch/ # 報告搜尋頁面
│   ├── Settings/     # 設定頁面
│   └── Login/        # 登入頁面
├── services/         # API服務層
│   ├── api.ts        # Axios實例配置
│   ├── auth.ts       # 認證服務
│   ├── study.ts      # 檢查服務
│   ├── report.ts     # 報告服務
│   ├── project.ts    # 專案服務
│   └── analysis.ts   # 分析服務
├── store/            # Zustand狀態管理
│   ├── authStore.ts  # 認證狀態
│   └── reportStore.ts# 報告狀態
├── types/            # TypeScript類型定義
├── hooks/            # 自訂Hooks
└── utils/            # 工具函數
```

#### 現有功能模組
```yaml
✅ 已實現功能:
  - 使用者認證與授權 (authStore, auth.ts)
  - 檢查搜尋與過濾 (StudySearch, study.ts)
  - 報告搜尋與預覽 (ReportSearch, report.ts)
  - 專案管理 (Projects, project.ts)
  - 資料匯入 (DataImport, import.ts)
  - AI分析介面 (AIAnalysis, analysis.ts)
  - 儀表板統計 (Dashboard)

❌ 缺少功能 (針對AI驗證工作流):
  - 驗證工作流管理頁面
  - PACS搜尋介面
  - LLM分析結果顯示
  - 醫師審核介面
  - FP檢查流程
  - Guideline管理
  - 匿名化處理監控
  - 檔案傳輸狀態追蹤
```

### 1.2 Backend架構分析

#### 技術棧
```yaml
框架: Django 5.1 + Django Ninja
API文件: Swagger/OpenAPI
資料庫: PostgreSQL (透過Django ORM)
```

#### 現有API端點
```yaml
已實現API (studies app):
  GET  /api/v1/studies/search          # 檢查搜尋 ✅
  GET  /api/v1/studies/{id}            # 檢查詳情 ✅
  GET  /api/v1/studies/filters         # 過濾選項 ✅
  POST /api/v1/studies/export          # 匯出資料 ✅

  GET  /api/v1/reports/search          # 報告搜尋 ✅
  GET  /api/v1/reports/{uid}           # 報告詳情 ✅

  GET  /api/v1/health                  # 健康檢查 ✅

缺少API (針對AI驗證工作流):
  # 工作流管理
  POST   /api/v1/validation/workflows           # 建立驗證工作流 ❌
  GET    /api/v1/validation/workflows           # 取得工作流列表 ❌
  GET    /api/v1/validation/workflows/{id}      # 取得工作流詳情 ❌
  PATCH  /api/v1/validation/workflows/{id}      # 更新工作流 ❌
  DELETE /api/v1/validation/workflows/{id}      # 刪除工作流 ❌

  # 步驟執行
  POST   /api/v1/validation/workflows/{id}/steps/pacs-search      # 步驟1: PACS搜尋 ❌
  POST   /api/v1/validation/workflows/{id}/steps/llm-analysis     # 步驟2: LLM分析 ❌
  POST   /api/v1/validation/workflows/{id}/steps/statistics       # 步驟3: 統計分析 ❌
  POST   /api/v1/validation/workflows/{id}/steps/sampling         # 步驟4: 隨機抽樣 ❌
  POST   /api/v1/validation/workflows/{id}/steps/physician-review # 步驟5: 醫師審核 ❌
  POST   /api/v1/validation/workflows/{id}/steps/excel-export     # 步驟6: Excel匯出 ❌
  POST   /api/v1/validation/workflows/{id}/steps/dicom-download   # 步驟7: DICOM下載 ❌
  POST   /api/v1/validation/workflows/{id}/steps/anonymize        # 步驟8: 匿名化 ❌
  POST   /api/v1/validation/workflows/{id}/steps/transfer         # 步驟9: 檔案傳輸 ❌

  # 工作流狀態
  GET    /api/v1/validation/workflows/{id}/status        # 取得執行狀態 ❌
  GET    /api/v1/validation/workflows/{id}/statistics    # 取得統計資訊 ❌
  GET    /api/v1/validation/workflows/{id}/studies       # 取得關聯studies ❌

  # 醫師審核
  GET    /api/v1/validation/workflows/{id}/pending-reviews  # 取得待審核cases ❌
  POST   /api/v1/validation/reviews                         # 提交審核結果 ❌
  PATCH  /api/v1/validation/reviews/{id}                    # 更新審核結果 ❌

  # Guideline管理
  GET    /api/v1/validation/guidelines              # 取得guidelines ❌
  POST   /api/v1/validation/guidelines              # 建立guideline ❌
  PATCH  /api/v1/validation/guidelines/{id}         # 更新guideline ❌
  DELETE /api/v1/validation/guidelines/{id}         # 刪除guideline ❌
```

#### 已實現資料模型
```yaml
現有模型 (models.py):
  - Study: 檢查記錄主表 ✅
    * exam_id, medical_record_no, patient_name
    * exam_status, exam_source, exam_item
    * order_datetime, check_in_datetime

  - Report: 報告記錄 ✅
    * uid, exam_id (FK to Study)
    * report_text, modality
    * created_at, updated_at

已建立但未使用模型 (models_validation_simplified.py):
  - ValidationWorkflow: 驗證工作流 ⚠️
    * name, study_type, status
    * search_criteria, current_guideline

  - StudyRecord: 檢查記錄 (驗證用) ⚠️
    * study_uid, patient_id, report_text
    * llm_classification, physician_decision
    * anonymous_id

  - AnalysisResult: LLM分析結果 ⚠️
    * classification, confidence_score
    * key_findings

  - PhysicianReview: 醫師審核 ⚠️
    * is_false_positive, review_notes
    * reviewer_name, review_date

  - ExportBatch: 匯出批次 ⚠️
    * excel_path, dicom_path, nifti_path
    * transfer_status
```

#### 已實現工作流引擎
```yaml
工作流實作狀態 (workflows/):
  ✅ simple_workflow.py - 簡化版工作流引擎
    * SimpleValidationWorkflow類別
    * 9個步驟方法 (step1-step9)
    * execute_all(), execute_steps()
    * save_checkpoint(), load_checkpoint()

  ✅ pacs_integration.py - PACS整合模組
  ✅ llm_analyzer.py - LLM分析器
  ✅ dicom_processor.py - DICOM處理器
  ✅ excel_exporter.py - Excel匯出器
  ⚠️ validation_workflow.py - Prefect版本（已棄用）

狀態: 實作完成但無API暴露 ⚠️
```

---

## 2. 整合差異分析

### 2.1 架構層級差異

#### ✅ 相符部分
```yaml
共同特徵:
  - 都採用模組化架構設計
  - 都有清晰的職責分離
  - 都支援擴展性設計
  - 都有完整的錯誤處理機制
```

#### ❌ 不匹配部分
```yaml
主要差異:
  1. Frontend有完整的頁面結構，但缺少驗證工作流專用UI
     - 現有: Dashboard, StudySearch, Projects, AIAnalysis
     - 缺少: ValidationWorkflow, PhysicianReview, GuidelineManagement

  2. Backend有完整的工作流引擎，但沒有對應API端點
     - 現有: SimpleValidationWorkflow with 9 steps
     - 缺少: REST API endpoints for workflow operations

  3. 資料模型不一致
     - Study (現有) vs StudyRecord (驗證用) - 兩套獨立系統
     - 無法直接關聯現有Study資料到驗證工作流

  4. 狀態管理缺失
     - Frontend缺少validationStore (工作流狀態管理)
     - 無法追蹤工作流執行進度
```

### 2.2 功能層級差異

#### 步驟1-9實作狀態對比

| 步驟 | Backend實作 | API端點 | Frontend UI | 整合狀態 |
|-----|-----------|--------|-----------|---------|
| 步驟1: PACS搜尋 | ✅ simple_workflow.py:43 | ❌ 缺少 | ⚠️ 可用StudySearch | 🔴 未整合 |
| 步驟2: LLM分析 | ✅ simple_workflow.py:81 | ❌ 缺少 | ⚠️ 有AIAnalysis頁面 | 🔴 未整合 |
| 步驟3: 統計分析 | ✅ simple_workflow.py:126 | ❌ 缺少 | ❌ 缺少UI | 🔴 未整合 |
| 步驟4: 隨機抽樣 | ✅ simple_workflow.py:168 | ❌ 缺少 | ❌ 缺少UI | 🔴 未整合 |
| 步驟5: 醫師審核 | ✅ simple_workflow.py:204 | ❌ 缺少 | ❌ 缺少UI | 🔴 未整合 |
| 步驟6: Excel匯出 | ✅ simple_workflow.py:243 | ⚠️ 有通用export | ❌ 缺少專用UI | 🟡 部分整合 |
| 步驟7: DICOM下載 | ✅ simple_workflow.py:284 | ❌ 缺少 | ❌ 缺少UI | 🔴 未整合 |
| 步驟8: 匿名化轉換 | ✅ simple_workflow.py:320 | ❌ 缺少 | ❌ 缺少UI | 🔴 未整合 |
| 步驟9: 檔案傳輸 | ✅ simple_workflow.py:360 | ❌ 缺少 | ❌ 缺少UI | 🔴 未整合 |

### 2.3 資料流程差異

#### 現有資料流 (Study Management)
```
用戶 → Frontend (StudySearch) → API (/api/v1/studies/search)
  → Backend (StudyService) → Database (Study Model) → Response
```

#### 需要的資料流 (Validation Workflow)
```
用戶 → Frontend (ValidationWorkflow) → API (/api/v1/validation/workflows)
  → Backend (SimpleValidationWorkflow) → Database (ValidationWorkflow Model)
  → Services (PACS, LLM, DICOM, etc.) → Response
```

**問題**: 兩套資料流完全獨立，無法整合

---

## 3. 匹配度評估

### 3.1 整體匹配度評分

```yaml
整體匹配度: 30% 🔴

細部評分:
  架構設計匹配度: 70% 🟡
    ✅ 都採用模組化設計
    ✅ 都有服務層抽象
    ❌ 前後端模組無對應關係

  功能完整度: 25% 🔴
    ✅ Backend: 9個步驟完整實作 (100%)
    ❌ API: 0個端點實作 (0%)
    ❌ Frontend: 0個專用UI (0%)

  資料模型一致性: 20% 🔴
    ✅ ValidationWorkflow模型已建立
    ❌ 未註冊到Django admin
    ❌ 未與現有Study模型整合
    ❌ 未建立migration

  API整合度: 5% 🔴
    ❌ 驗證工作流API完全缺失
    ⚠️ 僅有通用Study/Report API

  UI完整度: 10% 🔴
    ⚠️ 可重用部分現有組件
    ❌ 缺少所有工作流專用介面
```

### 3.2 風險評估

```yaml
高風險項目:
  1. 🔴 雙系統並存風險
     - Study vs StudyRecord 資料重複
     - 可能造成資料不一致
     - 維護成本倍增

  2. 🔴 工作流引擎無法使用
     - Backend完整實作但無入口
     - 無法從Frontend觸發
     - 投資報酬率為0

  3. 🔴 使用者體驗斷層
     - 無法在UI上執行9步驟工作流
     - 需要手動執行Python腳本
     - 不符合臨床使用場景

中風險項目:
  1. 🟡 資料遷移複雜度
     - 需要建立Study到StudyRecord的映射
     - 可能需要歷史資料轉換

  2. 🟡 測試覆蓋率不足
     - 工作流引擎缺少E2E測試
     - Frontend-Backend整合測試缺失

低風險項目:
  1. 🟢 技術棧相容性良好
     - React + Django Ninja 成熟組合
     - TypeScript + Pydantic 類型安全
```

---

## 4. 後續規劃路徑

### 4.1 整合策略選擇

#### 選項A: 最小整合方案 (推薦) ⭐
```yaml
策略: 建立API層，復用現有UI組件

優點:
  - 快速整合 (1-2週)
  - 風險最低
  - 可漸進式遷移

步驟:
  Phase 1 (3天): API層開發
    - 建立validation router
    - 暴露9個步驟API
    - 實作工作流CRUD

  Phase 2 (3天): Frontend最小UI
    - 建立ValidationWorkflow頁面
    - 復用StudySearch組件
    - 建立步驟執行控制台

  Phase 3 (2天): 整合測試
    - E2E測試
    - 效能測試
    - 使用者驗收測試
```

#### 選項B: 完整重構方案
```yaml
策略: 統一資料模型，重建完整UI

優點:
  - 長期維護性好
  - 資料一致性強
  - UI體驗最佳

缺點:
  - 開發時間長 (4-6週)
  - 風險較高
  - 需要資料遷移

不推薦原因:
  - 違背PRD「快速、簡化」原則
  - 過度工程化
```

#### 選項C: 保持現狀
```yaml
策略: Backend CLI執行，無Web介面

優點:
  - 無需開發工作

缺點:
  - 無法給臨床醫師使用 ❌
  - 違背系統設計初衷 ❌
  - 投資報酬率為0 ❌

不推薦原因: 完全不符合需求
```

### 4.2 推薦實施計畫 (選項A)

#### Week 1: API層開發

**Day 1-2: Validation Router建立**
```python
# backend_django/studies/validation_api.py
from ninja import Router
from .workflows.simple_workflow import SimpleValidationWorkflow
from .models_validation_simplified import ValidationWorkflow, StudyRecord

validation_router = Router()

# 工作流CRUD
@validation_router.post('/workflows')
def create_workflow(request, name: str, study_type: str = 'Aorta CTA'):
    """建立新驗證工作流"""
    pass

@validation_router.get('/workflows')
def list_workflows(request):
    """取得工作流列表"""
    pass

@validation_router.get('/workflows/{id}')
def get_workflow(request, id: int):
    """取得工作流詳情"""
    pass

# 步驟執行API
@validation_router.post('/workflows/{id}/steps/pacs-search')
def execute_pacs_search(request, id: int, criteria: dict):
    """執行步驟1: PACS搜尋"""
    workflow = SimpleValidationWorkflow(workflow_id=id)
    return workflow.step1_pacs_search(criteria)

@validation_router.post('/workflows/{id}/steps/llm-analysis')
def execute_llm_analysis(request, id: int):
    """執行步驟2: LLM分析"""
    workflow = SimpleValidationWorkflow(workflow_id=id)
    return workflow.step2_llm_analysis()

# ... 其他7個步驟API
```

**Day 3: 註冊路由與測試**
```python
# backend_django/config/urls.py
from studies.validation_api import validation_router

api.add_router('/validation', validation_router, tags=['validation'])
```

#### Week 2: Frontend開發

**Day 1-2: 建立ValidationWorkflow頁面**
```typescript
// frontend/src/pages/ValidationWorkflow/index.tsx
import { useState } from 'react'
import { Card, Steps, Button, message } from 'antd'
import { useValidationWorkflow } from '@/hooks/useValidationWorkflow'

const ValidationWorkflowPage = () => {
  const { workflow, executeStep, isLoading } = useValidationWorkflow()

  const steps = [
    { title: 'PACS搜尋', key: 'pacs-search' },
    { title: 'LLM分析', key: 'llm-analysis' },
    { title: '統計分析', key: 'statistics' },
    { title: '隨機抽樣', key: 'sampling' },
    { title: '醫師審核', key: 'physician-review' },
    { title: 'Excel匯出', key: 'excel-export' },
    { title: 'DICOM下載', key: 'dicom-download' },
    { title: '匿名化', key: 'anonymize' },
    { title: '檔案傳輸', key: 'transfer' },
  ]

  const handleExecuteStep = async (stepKey: string) => {
    try {
      await executeStep(stepKey)
      message.success(`步驟 ${stepKey} 執行成功`)
    } catch (error) {
      message.error(`執行失敗: ${error.message}`)
    }
  }

  return (
    <Card title="驗證工作流">
      <Steps current={workflow?.currentStep} items={steps} />
      {/* 步驟執行控制台 */}
    </Card>
  )
}
```

**Day 3-4: API Service層**
```typescript
// frontend/src/services/validation.ts
import apiClient from './api'

export interface ValidationWorkflow {
  id: number
  name: string
  study_type: string
  status: string
  current_step?: number
}

export const validationService = {
  // 工作流CRUD
  async createWorkflow(name: string, studyType: string = 'Aorta CTA') {
    const { data } = await apiClient.post<ValidationWorkflow>(
      '/v1/validation/workflows',
      { name, study_type: studyType }
    )
    return data
  },

  async getWorkflows() {
    const { data } = await apiClient.get<ValidationWorkflow[]>(
      '/v1/validation/workflows'
    )
    return data
  },

  // 步驟執行
  async executeStep(workflowId: number, stepKey: string, params?: any) {
    const { data } = await apiClient.post(
      `/v1/validation/workflows/${workflowId}/steps/${stepKey}`,
      params
    )
    return data
  },

  async getWorkflowStatus(workflowId: number) {
    const { data } = await apiClient.get(
      `/v1/validation/workflows/${workflowId}/status`
    )
    return data
  }
}
```

**Day 5: 整合測試**
- E2E測試腳本
- API整合測試
- UI互動測試

### 4.3 Database Migration

```bash
# Step 1: 建立Migration
cd backend_django
python manage.py makemigrations studies

# Step 2: 檢視SQL
python manage.py sqlmigrate studies 0002_add_validation_workflow_tables

# Step 3: 執行Migration
python manage.py migrate

# Step 4: 建立測試資料
python manage.py shell
>>> from studies.models_validation_simplified import ValidationWorkflow
>>> ValidationWorkflow.objects.create(
...     name="Test Aorta CTA Validation",
...     study_type="Aorta CTA",
...     status="draft"
... )
```

---

## 5. 技術債務與優化建議

### 5.1 需要解決的技術債務

```yaml
立即處理 (P0):
  1. 註冊ValidationWorkflow到Django admin
     影響: 無法透過admin管理工作流
     方案: 在studies/admin.py中註冊

  2. 建立資料庫migration
     影響: ValidationWorkflow表不存在
     方案: makemigrations + migrate

  3. 實作Validation API端點
     影響: Frontend無法呼叫工作流
     方案: 建立validation_api.py

短期處理 (P1):
  1. 統一Study與StudyRecord
     影響: 資料重複，維護成本高
     方案: 建立FK關聯或合併模型

  2. 增加工作流監控
     影響: 無法追蹤執行狀態
     方案: WebSocket即時更新或輪詢

長期優化 (P2):
  1. 效能優化
     - 步驟執行非同步化
     - 大量資料批次處理
     - Redis快取機制

  2. 安全性加強
     - API認證授權
     - 敏感資料加密
     - 操作日誌審計
```

### 5.2 架構優化建議

```yaml
資料層優化:
  1. 建立Study → StudyRecord關聯
     current: 兩套獨立系統
     target: StudyRecord.study_fk = ForeignKey(Study)
     benefit: 資料一致性，避免重複

  2. 增加工作流快照機制
     purpose: 支援checkpoint恢復
     implementation: JSON欄位儲存中間結果

服務層優化:
  1. 引入Celery非同步任務
     purpose: 長時間步驟非阻塞執行
     benefit: 提升使用者體驗

  2. 增加重試機制
     purpose: 網路錯誤自動重試
     benefit: 提高可靠性

前端層優化:
  1. 建立validationStore
     purpose: 統一工作流狀態管理
     benefit: 跨組件狀態共享

  2. 實作即時進度追蹤
     purpose: 顯示步驟執行進度
     benefit: 改善使用者體驗
```

---

## 6. 結論與建議

### 6.1 現況總結

```yaml
✅ 正面發現:
  - Backend工作流引擎完整且設計優良
  - Frontend基礎架構完備，可快速擴展
  - 技術棧成熟穩定，相容性良好

❌ 主要問題:
  - Frontend與Backend完全未整合 (0%)
  - 缺少所有Validation API端點
  - ValidationWorkflow模型未啟用
  - 無專用UI介面

⚠️ 風險提示:
  - 投資的Backend實作無法使用
  - 臨床醫師無法執行驗證流程
  - 系統無法達成設計目標
```

### 6.2 行動建議

#### 立即行動 (本週)
1. ✅ **啟用ValidationWorkflow模型**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

2. ✅ **建立最小API端點**
   - 實作 `/api/v1/validation/workflows` CRUD
   - 實作至少3個步驟API (PACS搜尋、LLM分析、統計)

3. ✅ **建立基礎UI頁面**
   - ValidationWorkflow列表頁
   - 工作流執行控制台

#### 短期目標 (2週內)
1. **完成9個步驟API**
   - 全部步驟可透過API呼叫
   - 錯誤處理完善
   - API文件更新

2. **完整UI實作**
   - 所有步驟UI介面
   - 醫師審核介面
   - Guideline管理

3. **整合測試**
   - E2E測試覆蓋
   - 效能測試通過

#### 長期規劃 (1個月內)
1. **資料模型統一**
   - Study與StudyRecord整合
   - 歷史資料遷移

2. **效能與可靠性**
   - Celery非同步任務
   - Redis快取機制
   - 監控與告警

### 6.3 成功指標

```yaml
MVP成功標準 (2週):
  ✅ 能從Frontend建立ValidationWorkflow
  ✅ 能執行9個步驟
  ✅ 能查看執行狀態
  ✅ 能完成醫師審核
  ✅ 能匯出最終結果

完整系統標準 (1個月):
  ✅ 所有PRD需求實作完成
  ✅ E2E測試覆蓋率 >80%
  ✅ API效能符合要求
  ✅ UI/UX通過臨床測試
  ✅ 技術文件完整
```

---

## 7. 附錄

### 7.1 關鍵檔案清單

```yaml
Backend關鍵檔案:
  - backend_django/studies/models_validation_simplified.py
    作用: ValidationWorkflow資料模型
    狀態: 已建立，未啟用

  - backend_django/studies/workflows/simple_workflow.py
    作用: 9步驟工作流引擎
    狀態: 完整實作，無API暴露

  - backend_django/config/urls.py
    作用: API路由配置
    狀態: 需要增加validation router

Frontend關鍵檔案:
  - frontend/src/services/api.ts
    作用: Axios實例配置
    狀態: 完成，需增加validation service

  - frontend/src/store/
    作用: Zustand狀態管理
    狀態: 需增加validationStore

  - frontend/src/pages/
    作用: 頁面組件
    狀態: 需增加ValidationWorkflow頁面
```

### 7.2 相關文件

```yaml
已完成文件:
  - 003-validation-workflow-prd-simplified.md
    內容: 簡化版PRD

  - 004-loosely-coupled-architecture.md
    內容: 鬆散耦合架構設計

  - 005-implementation-guide.md
    內容: 實施指南

本文件:
  - 006-frontend-backend-integration-analysis.md
    內容: Frontend-Backend整合分析

需要建立文件:
  - 007-api-specification.md
    內容: Validation API規格

  - 008-ui-wireframes.md
    內容: UI線框圖與互動設計
```

---

**文件結束**

**下一步**: 執行「選項A: 最小整合方案」，預計2週完成MVP
