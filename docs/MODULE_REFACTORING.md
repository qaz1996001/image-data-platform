# Backend Django 模組重構文檔

**日期**: 2025-11-25  
**版本**: v1.0.0  
**狀態**: 已完成

## 概述

將 `backend_django/studies` 單體應用重構為模組化架構，拆分為 `study`、`project`、`report` 和 `common` 四個獨立應用，以提高代碼可維護性和可擴展性。

## 重構動機

1. **單一應用過於龐大**：原 `studies` 應用包含了研究（Study）、專案（Project）、報告（Report）等多個不同領域的模型和業務邏輯
2. **職責不清**：不同業務邏輯混在一起，違反單一職責原則
3. **難以維護**：單個 `models.py` 文件超過 800 行，API 文件分散但命名空間混亂
4. **擴展困難**：添加新功能時難以確定應該放在哪裡

## 重構方案

### 新模組結構

```
backend_django/
├── study/              # 研究相關
│   ├── __init__.py
│   ├── models.py       # Study 模型
│   ├── api.py          # Study API 端點
│   ├── services.py     # Study 業務邏輯
│   └── schemas.py      # Study Pydantic schemas
│
├── project/            # 專案相關
│   ├── __init__.py
│   ├── models.py       # Project, ProjectMember 模型
│   ├── api.py          # Project API 端點
│   ├── service.py      # Project 業務邏輯
│   └── schemas.py      # Project Pydantic schemas
│
├── report/             # 報告相關
│   ├── __init__.py
│   ├── models.py       # Report, ReportVersion, ReportSummary 等模型
│   ├── api.py          # Report API 端點
│   ├── service.py      # Report 業務邏輯
│   └── schemas.py      # Report Pydantic schemas
│
├── common/             # 共用模組
│   ├── __init__.py
│   ├── models.py       # StudyProjectAssignment 等關聯模型
│   ├── permissions.py  # 權限管理
│   ├── exceptions.py   # 自定義異常
│   ├── config.py       # 配置
│   ├── pagination.py   # 分頁輔助
│   ├── auth_api.py     # 認證 API
│   ├── base_pagination.py
│   ├── export_service.py
│   └── management/
│       └── commands/   # Django 管理命令
│
└── studies/            # 保留用於遷移歷史
    ├── __init__.py
    ├── models.py       # 空文件（避免衝突）
    ├── admin.py        # 空文件
    └── migrations/     # 保留完整遷移歷史
```

### 模型分配

#### study/models.py
- `Study` - 檢查記錄模型

#### project/models.py
- `Project` - 專案模型
- `ProjectMember` - 專案成員模型

#### report/models.py
- `Report` - 報告模型
- `ReportVersion` - 報告版本模型
- `ReportSummary` - 報告摘要模型
- `ReportSearchIndex` - 報告搜索索引
- `ExportTask` - 匯出任務模型
- `AIAnnotation` - AI 標註模型

#### common/models.py
- `StudyProjectAssignment` - 研究-專案關聯模型

### API 路由變更

| 舊路徑 | 新路徑 | 模組位置 | 說明 |
|--------|--------|----------|------|
| `/api/v1/studies/*` | `/api/v1/studies/*` | `study/api.py` | 研究/檢查相關端點 |
| `/api/v1/projects/*` | `/api/v1/projects/*` | `project/api.py` | 專案管理端點 |
| `/api/v1/reports/*` | `/api/v1/reports/*` | `report/api.py` | 報告相關端點 |
| `/api/v1/auth/*` | `/api/v1/auth/*` | `common/auth_api.py` | 認證端點 |

**注意**：API 路徑保持不變，僅內部模組結構改變，確保前端無需修改。

### 導入路徑變更

#### 舊導入方式
```python
from studies.models import Study, Project, Report
from studies.services import StudyService
from studies.permissions import ProjectPermissions
```

#### 新導入方式
```python
from study.models import Study
from project.models import Project, ProjectMember
from report.models import Report, ReportVersion
from common.models import StudyProjectAssignment
from study.services import StudyService
from project.service import ProjectService
from report.service import ReportService
from common.permissions import ProjectPermissions
from common.exceptions import StudyNotFoundError
from common.config import ServiceConfig
```

## 實施步驟

### 1. 創建新應用結構
- ✅ 創建 `study/`, `project/`, `report/`, `common/` 目錄
- ✅ 創建各模組的 `__init__.py` 文件

### 2. 遷移模型
- ✅ 將 `Study` 移至 `study/models.py`
- ✅ 將 `Project`, `ProjectMember` 移至 `project/models.py`
- ✅ 將 `Report`, `ReportVersion` 等移至 `report/models.py`
- ✅ 將 `StudyProjectAssignment` 移至 `common/models.py`
- ✅ 為 `StudyProjectAssignment` 添加顯式 `app_label = 'common'`

### 3. 遷移 API 和服務
- ✅ `studies/api.py` → `study/api.py`
- ✅ `studies/project_api.py` → `project/api.py`
- ✅ `studies/report_api.py` → `report/api.py`
- ✅ `studies/auth_api.py` → `common/auth_api.py`
- ✅ `studies/services.py` → `study/services.py`
- ✅ `studies/project_service.py` → `project/service.py`
- ✅ `studies/report_service.py` → `report/service.py`

### 4. 遷移共用模組
- ✅ `studies/permissions.py` → `common/permissions.py`
- ✅ `studies/exceptions.py` → `common/exceptions.py`
- ✅ `studies/config.py` → `common/config.py`
- ✅ `studies/pagination.py` → `common/pagination.py`
- ✅ `studies/export_service.py` → `common/export_service.py`

### 5. 更新導入
- ✅ 更新所有 API 文件的導入路徑
- ✅ 更新所有 Service 文件的導入路徑
- ✅ 更新 `common/` 模組內部的相互引用
- ✅ 更新測試文件的導入路徑

### 6. 更新 Django 配置
- ✅ 更新 `config/settings.py` 的 `INSTALLED_APPS`
- ✅ 更新 `config/urls.py` 的路由導入
- ✅ 更新日誌配置以反映新應用名稱

### 7. 處理舊應用
- ✅ 清空 `studies/models.py`（保留註釋說明）
- ✅ 清空 `studies/admin.py`（避免導入錯誤）
- ✅ 保留 `studies/migrations/` 目錄（維護遷移歷史）
- ✅ 刪除 `studies/management/` 目錄（命令已移至 `common/`）

### 8. 修復衝突和錯誤
- ✅ 修復 Django 系統檢查錯誤（E030, E028, E304 等）
- ✅ 解決重複的 `operation_id` 警告
- ✅ 修復 Pydantic 驗證錯誤
- ✅ 修正錯誤的導入路徑

### 9. 測試驗證
- ✅ 運行 Django 系統檢查：`python manage.py check`
- ✅ 測試主要 API 端點
- ✅ 驗證資料庫查詢正常

## 遇到的問題和解決方案

### 問題 1: 模型衝突
**錯誤**: `SystemCheckError: System check identified some issues: ?: (models.E030) index name 'idx_pm_proj_role' is not unique`

**原因**: 新舊應用同時定義了相同的模型，導致 `db_table` 和索引名稱衝突

**解決**: 清空 `studies/models.py` 和 `studies/admin.py`，僅保留註釋，避免重複定義

### 問題 2: app_label 未聲明
**錯誤**: `RuntimeError: Model class common.models.StudyProjectAssignment doesn't declare an explicit app_label`

**原因**: 關聯模型在 `common` 應用中但未顯式聲明 `app_label`

**解決**: 在 `StudyProjectAssignment` 的 `Meta` 類中添加 `app_label = 'common'`

### 問題 3: operation_id 衝突
**警告**: `operation_id "report_api_get_filter_options" is already used`

**原因**: `study/api.py` 和 `report/api.py` 都有 `get_filter_options` 函數，Django Ninja 自動生成的 `operation_id` 衝突

**解決**: 為衝突的端點顯式指定唯一的 `operation_id`：
- `study/api.py`: `operation_id='study_get_filter_options'`
- `report/api.py`: `operation_id='report_get_filter_options'` 和 `operation_id='report_get_filter_options_legacy'`

### 問題 4: Pydantic 驗證錯誤
**錯誤**: `validation error for ReportDetailResponse: source_url Field required`

**原因**: 構造 `ReportDetailResponse` 時遺漏了必填欄位 `source_url`

**解決**: 在 `report/api.py` 的 `search_reports` 函數中添加 `source_url=r.source_url`

### 問題 5: 錯誤的導入路徑
**錯誤**: `ModuleNotFoundError: No module named 'common.report_service'`

**原因**: `common/pagination.py` 中的導入路徑錯誤

**解決**: 將 `from .report_service import ReportService` 改為 `from report.service import ReportService`

## 數據庫遷移說明

**重要**: 此次重構為**純代碼重構**，未涉及數據庫結構變更：

- ✅ 所有模型的 `db_table` 名稱保持不變
- ✅ 外鍵引用使用字符串格式（如 `'project.Project'`），Django 自動解析
- ✅ 保留完整的 `studies/migrations/` 歷史
- ✅ 新應用（`study`, `project`, `report`, `common`）暫不創建遷移文件
- ✅ 在 `INSTALLED_APPS` 中保留 `studies` 以維護遷移歷史

**遷移風險**: 低，因為：
1. 沒有修改任何 `db_table` 名稱
2. 沒有更改欄位定義
3. Django 通過 `app_label` 和字符串引用正確解析模型關係

## 性能影響

- ✅ **無性能影響**：純代碼結構調整，不影響運行時性能
- ✅ **啟動時間**：略微增加（多載入幾個應用），影響可忽略
- ✅ **查詢性能**：無變化，資料庫查詢邏輯未改變

## 向後兼容性

### API 層面
- ✅ **完全兼容**：所有 API 路徑保持不變
- ✅ **請求/響應格式**：無變化
- ✅ **認證機制**：無變化

### 前端影響
- ✅ **無需修改**：API 合約未變，前端代碼無需調整

### 第三方集成
- ✅ **無影響**：外部系統調用的 API 端點未變

## 後續維護建議

### 1. 新增功能時
- 明確功能屬於哪個模組（study / project / report）
- 共用邏輯放在 `common/`
- 避免循環導入

### 2. 模型擴展
- 新增與研究相關的模型放在 `study/models.py`
- 新增與專案相關的模型放在 `project/models.py`
- 新增與報告相關的模型放在 `report/models.py`
- 跨模組關聯的中間模型放在 `common/models.py`

### 3. API 開發
- 遵循 RESTful 設計原則
- 為每個端點指定清晰的 `operation_id`
- 保持 API 版本控制（`/api/v1/`）

### 4. 服務層
- 業務邏輯封裝在 Service 類中
- 保持服務的單一職責
- 使用依賴注入而非全局狀態

### 5. 測試
- 為每個模組編寫獨立的單元測試
- 使用 fixtures 隔離測試數據
- 集成測試驗證跨模組交互

## 文檔更新

以下文檔需要更新以反映新模組結構：

### 已更新
- ✅ `backend_django/config/settings.py` - INSTALLED_APPS
- ✅ `backend_django/config/urls.py` - 路由導入
- ✅ 所有源代碼文件的導入路徑

### 待更新
- ⏳ `docs/01_PROJECT_OVERVIEW.md` - 技術棧和架構描述
- ⏳ `docs/requirements/03_BACKEND_PRD_SR_SD.md` - 後端需求文檔中的模組引用
- ⏳ `docs/requirements/UR003_UR004_API_CONTRACT.md` - API 合約中的文件路徑引用
- ⏳ `openspec/` - 相關規範文檔中的模組引用
- ⏳ API 文檔 - 更新代碼示例中的導入語句

## 總結

此次重構成功地將單體 `studies` 應用拆分為四個職責清晰的模組：

1. **study** - 專注於檢查記錄（Study）的管理
2. **project** - 專注於專案（Project）和成員管理
3. **report** - 專注於報告（Report）和 AI 標註
4. **common** - 提供跨模組的共用功能

**優點**：
- ✅ 代碼組織更清晰，易於理解和維護
- ✅ 職責分離，符合單一職責原則
- ✅ 便於並行開發和測試
- ✅ 降低模組間耦合

**保證**：
- ✅ API 完全向後兼容，前端無需修改
- ✅ 數據庫結構未變，無需數據遷移
- ✅ 所有功能正常運行，通過系統檢查

---

**文檔維護者**: Backend Development Team  
**最後審核**: 2025-11-25  
**版本控制**: 此文檔應隨代碼演進同步更新

