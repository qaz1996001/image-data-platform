# image_data_platform OpenSpec 整合指南（OpenSpec Integration Guide）

> 本文件為 image_data_platform 專案在新文檔結構下的**OpenSpec 整合主指南**，  
> 說明 OpenSpec 變更如何映射到 `docs/image_data_platform/**` 內的需求、架構、測試與追溯文檔，並取代舊遷移 / 規劃說明。
>
> 範本結構來源：`templates/TEMPLATE_OPENSPEC_INTEGRATION_GUIDE.md`。

---

**文件 ID**: IDP-OPENSPEC-INTEG-IMG-001
**標題**: image_data_platform — OpenSpec 整合指南（整合舊文檔）
**版本**: v1.3.0
**狀態**: Active
**建立日期**: 2025-12-24
**最後更新**: 2026-01-02  
**作者**: AI 代理 + 專案團隊  
**審核人**: [負責人]  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v1.3 | 2026-01-02 | AI 代理 | 新增 §5.2-5.5 歸檔變更案例摘要（統一專案資源、搜尋高亮、文檔遷移、進階搜尋） |
| v1.2 | 2026-01-02 | AI 代理 | 新增第 5 節實務範例:fix-advanced-search-bugs 變更記錄 |
| v1.1 | 2025-12-26 | AI 代理 | 新增第 3.3 節:舊文件處理流程;更新為 Active 狀態 |
| v0.1 | 2025-12-24 | AI 代理 | 從模板建立,準備取代舊遷移 / 規劃說明 |

---

## 1. 目的與範圍（Purpose & Scope）

- 定義 image_data_platform 專案中 **OpenSpec ↔ Docs** 的對應與同步機制。
- 說明如何在遷移舊文檔（`docs/old/**`）後，只使用 `docs/image_data_platform/**` 作為 canonical 文件樹。

---

## 2. OpenSpec 與 Docs 的對應關係（Mapping Between OpenSpec and Docs）

（沿用並細化模板中的對應表，指向本專案實際檔案）

---

## 3. 變更流程（Change Workflow）

### 3.1 標準變更流程

1. **創建提案**: 使用 `/openspec-proposal` 或 `openspec init` 創建變更提案
2. **編寫 specs/**: 在 `openspec/changes/<change-id>/specs/` 中定義 ADDED/MODIFIED/REMOVED 需求
3. **編寫 tasks.md**: 分解實施任務
4. **執行實作**: 使用 `/openspec-apply` 執行變更並更新文檔
5. **更新 docs/**: 同步更新 `docs/image_data_platform/` 對應文件
6. **驗證與審核**: 執行 `openspec validate --strict`
7. **歸檔變更**: 使用 `openspec archive <change-id>` 歸檔

### 3.2 文檔同步規則

當 OpenSpec 變更影響系統行為時,**MUST** 同步更新以下文檔:

| OpenSpec 變更類型 | 需更新的文檔 |
|------------------|------------|
| 新增/修改需求 | `requirements/01_SYSTEM_PRD_SR_SD.md` |
| 架構變更 | `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` |
| API 變更 | `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` (第 5 章) |
| 資料庫變更 | `architecture/01_SYSTEM_ARCHITECTURE_DESIGN.md` (第 4 章) |
| 測試策略變更 | `testing/01_TESTING_STRATEGY_AND_REPORT.md` |
| 追溯關係變更 | `traceability/01_TRACEABILITY_MATRIX.md` |

### 3.3 舊文件處理流程（Legacy Docs Handling）

> 基於 `migrate-legacy-docs-to-image-data-platform` 變更建立

#### 3.3.1 AI 代理操作指南

當 AI 代理在 `docs/old/**` 中發現需要參考的內容時,**SHALL** 遵循以下流程:

1. **識別舊文件狀態**
   - 檢查文件開頭是否有 `DEPRECATED` 標記
   - 查閱 `docs/old/README_DEPRECATED.md` 確認對應的新文件位置

2. **優先使用新文件**
   - 總是優先參考 `docs/image_data_platform/**` 中的文檔
   - 僅在新文件中缺少特定細節時,才參考舊文件作為歷史參考

3. **不要更新舊文件**
   - ❌ 不要對 `docs/old/**` 下的文檔進行任何更新
   - ✅ 所有更新應在 `docs/image_data_platform/**` 中進行

4. **報告缺失內容**
   - 如果新文件中缺少重要內容,創建 GitHub Issue 說明
   - 或創建 OpenSpec 變更提案補充缺失內容

#### 3.3.2 開發者操作指南

當開發者需要查閱文檔或進行文檔更新時:

1. **查閱文檔**
   ```bash
   # 正確:從新結構開始
   cat docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md
   
   # 避免:直接查閱舊文件(除非明確需要歷史參考)
   # cat docs/old/01_PROJECT_OVERVIEW.md
   ```

2. **更新文檔**
   - ✅ 更新 `docs/image_data_platform/**` 中的文檔
   - ✅ 使用 OpenSpec 變更流程追蹤重大文檔變更
   - ❌ 不要修改 `docs/old/**` 下的文檔

3. **遷移缺失內容**
   - 如發現舊文件中有價值但未遷移的內容:
     - 創建 OpenSpec 變更提案
     - 將內容整合至新結構
     - 更新追溯矩陣

#### 3.3.3 Canonical 文檔樹定義

**image_data_platform 專案的 canonical 文檔樹為 `docs/image_data_platform/**`**

- `docs/old/**` 為歷史參考,不再更新
- 所有新開發、變更、審核 **MUST** 基於 `docs/image_data_platform/**`
- CI/CD 流程 **SHOULD** 優先檢查 `docs/image_data_platform/**` 的一致性

---

## 4. 追溯性與審核（Traceability & Review）

---

## 5. 實務範例（Practical Examples）

### 5.1 變更案例：fix-advanced-search-bugs (2026-01-02)

#### 5.1.1 變更摘要

**Change ID**: `fix-advanced-search-bugs`
**狀態**: ✅ 已完成
**日期**: 2026-01-02

修復專案資源工作台進階搜尋的四個錯誤：
1. **Bug #1**: Highlight "性別：男" 會亮所有 'M' 字元
2. **Bug #2**: 患者性別搜尋 "屬於 男" 無法搜到資料
3. **Bug #3**: 患者年齡 <= 18 搜到的資料年齡不是小於18歲
4. **Bug #4**: 患者年齡 >= 0 應該搜到全部資料，但只搜到26筆

#### 5.1.2 根本原因

專案資源工作台端點 (`/projects/{id}/search/advanced`) 完全忽略了 `AdvancedQueryBuilder.build().filters` 的結構化查詢，僅做全文搜尋。

**報告搜尋** (`/reports/search/advanced`) 正確運作：
```python
result = builder.build()
if result.filters:
    queryset = queryset.filter(result.filters)  # 正確應用 DSL 過濾器
```

**專案資源搜尋** (錯誤)：
```python
result = builder.build()
# 只提取文字做全文搜尋，完全忽略 result.filters！
search_query = extract_text_from_tree(...)
```

#### 5.1.3 修正內容

| 類別 | 檔案 | 修改內容 |
|------|------|----------|
| Backend | `project/api.py` | 重寫 `advanced_search_project_resources` 以使用 `AdvancedQueryBuilder.build().filters` |
| Backend | `report/services/query_builder.py` | 新增 `_coerce_range_value()` 方法、更新 `_build_list_condition()` |
| Frontend | `pages/Projects/index.tsx` | 新增 TEXT_OPERATORS 過濾器 |
| Frontend | `pages/Projects/Detail/ProjectResourceWorkbench.tsx` | 新增 TEXT_OPERATORS 過濾器 |
| Frontend | `pages/ReportSearch/index.tsx` | 新增 TEXT_OPERATORS 過濾器 |

#### 5.1.4 OpenSpec Spec 更新

| Spec 檔案 | 新增需求 |
|-----------|----------|
| `report-search/spec.md` | RS-SEARCH-005 (Range Query Type Handling)、RS-SEARCH-006 (List Operator Value Format)、RS-HIGHLIGHT-002 (Keyword Filtering) |
| `project-resource-workbench/spec.md` | PRW-SEARCH-001 (Advanced Search DSL Filter Support)、PRW-HIGHLIGHT-001 (Keyword Filtering) |

#### 5.1.5 驗證狀態

- ✅ `python manage.py check` - 通過
- ✅ `npx tsc --noEmit --skipLibCheck` - 通過
- ✅ `openspec show fix-advanced-search-bugs` - 驗證通過
- ⏳ 手動瀏覽器測試 - 待執行

#### 5.1.6 相關文件

- **提案**: `openspec/changes/fix-advanced-search-bugs/proposal.md`
- **任務**: `openspec/changes/fix-advanced-search-bugs/tasks.md`
- **Session 記錄**: Serena memory `session_fix_advanced_search_bugs_2026-01-02`

---

### 5.2 歸檔變更案例：unify-project-resource-workbench (2025-12-17)

**Change ID**: `2025-12-17-unify-project-resource-workbench`
**狀態**: ✅ 已歸檔
**歸檔位置**: `openspec/changes/archive/2025-12-17-unify-project-resource-workbench/`

#### 5.2.1 變更摘要

統一專案資源工作台，解決以下問題：
1. **分離的 Studies/Reports 標籤頁**：用戶必須切換路由才能關聯資訊
2. **功能不一致**：專案層級的 Study/Report 列表缺少搜尋頁面的 ResultsCard 操作（欄位管理器、選取抽屜、批次操作）
3. **識別碼不統一**：`exam_id`、`study_id`、`report_id` 被視為不相關的識別碼

#### 5.2.2 解決方案

| 組件 | 變更內容 |
|------|----------|
| ResultsCard 對等性 | 專案 Study/Report 體驗繼承標準列表工作台操作 |
| 統一資源工作台 | 移除 Studies/Reports 標籤頁，改為單一 ListWorkbench 視圖 |
| 標準存取號碼鍵 | 定義 `exam_id` 為所有資源的標準關聯鍵 |

#### 5.2.3 相關 Specs

- `project-resource-workbench/spec.md`
- `project-unified-resource-list/spec.md`
- `project-resource-key-alignment/spec.md`

---

### 5.3 歸檔變更案例：add-search-highlight (2025-12-19)

**Change ID**: `2025-12-19-add-search-highlight`
**狀態**: ✅ 已歸檔
**歸檔位置**: `openspec/changes/archive/2025-12-19-add-search-highlight/`

#### 5.3.1 變更摘要

添加搜尋文字高亮顯示功能，提升搜尋結果的可讀性與用戶體驗。

#### 5.3.2 實作內容

| 功能區域 | 高亮實作 |
|----------|----------|
| Report 搜尋 | 列表與 ReportDetailDrawer 中高亮匹配文字 |
| ProjectResource 搜尋 | ProjectResourceWorkbench 列表與詳情抽屜高亮 |
| Study 搜尋 | StudySearch 列表、詳情抽屜、Verified Report 區塊高亮 |
| Projects 列表 | ProjectCard 名稱/描述/標籤高亮 |
| 共用組件 | `HighlightText` 組件支援多關鍵字、大小寫不敏感匹配 |

#### 5.3.3 視覺樣式

- 背景色: `#fff566` (黃色)
- 字體: 加粗
- 一致性: 所有搜尋區域使用相同樣式

---

### 5.4 歸檔變更案例：migrate-legacy-docs-to-image-data-platform (2025-12-26)

**Change ID**: `2025-12-26-migrate-legacy-docs-to-image-data-platform`
**狀態**: ✅ 已歸檔
**歸檔位置**: `openspec/changes/archive/2025-12-26-migrate-legacy-docs-to-image-data-platform/`

#### 5.4.1 變更摘要

建立正式遷移與廢止策略，將 `docs/old/**` 內容遷移至 `docs/image_data_platform/**` 並標記舊檔為 Deprecated。

#### 5.4.2 關鍵決策

1. **Canonical 文檔樹**: `docs/image_data_platform/**` 為唯一權威來源
2. **舊文檔處理**: `docs/old/**` 僅作為歷史參考，不再更新
3. **AI 代理操作流程**: 優先使用新結構，標記舊檔

#### 5.4.3 產出文件

- `docs/image_data_platform/00_IMAGE_DATA_PLATFORM_INDEX.md` - 新主索引
- `docs/image_data_platform/OLD_DOCS_MAPPING_CHECKLIST.md` - 遷移對應清單
- `docs/old/README_DEPRECATED.md` - 舊文檔說明與導引

---

### 5.5 歸檔變更案例：enable-study-fields-in-report-search (2025-12-19)

**Change ID**: `2025-12-19-enable-study-fields-in-report-search`
**狀態**: ✅ 已歸檔
**歸檔位置**: `openspec/changes/archive/2025-12-19-enable-study-fields-in-report-search/`

#### 5.5.1 變更摘要

在報告搜尋中啟用檢查記錄（Study）欄位的篩選能力，讓用戶可根據患者資訊、檢查來源等條件搜尋報告。

#### 5.5.2 技術方案

**選擇方案**: 子查詢過濾 (Subquery)

```python
# 範例：查詢「60歲以上患者的MRI報告」
Q(title__icontains='MRI') & Q(
    report_id__in=Study.objects.filter(
        patient_age__gte=60,
        exam_source='MRI'
    ).values_list('exam_id', flat=True)
)
```

#### 5.5.3 方案優勢

- ✅ 不修改資料模型（保持無 ForeignKey 設計）
- ✅ 利用資料庫索引（子查詢在 DB 端執行）
- ✅ 向後相容（不影響現有 Report 欄位查詢）
- ✅ 易擴展（未來可支援更多關聯模型）

---

### 5.6 歸檔變更索引

完整歸檔變更清單請參考 `openspec/changes/archive/` 目錄：

| 歸檔日期 | Change ID | 簡述 |
|----------|-----------|------|
| 2025-11-24 | align-study-report-workbench | Study/Report 工作台對齊 |
| 2025-11-24 | standardize-phase1-list-ux | Phase 1 列表 UX 標準化 |
| 2025-11-25 | enforce-projects-rbac-batch | 專案 RBAC 批次操作 |
| 2025-11-27 | implement-project-detail-page | 專案詳情頁實作 |
| 2025-12-17 | unify-project-resource-workbench | 統一專案資源工作台 |
| 2025-12-18 | add-text-selection-to-ai-chat | AI 聊天文字選取 |
| 2025-12-19 | add-search-highlight | 搜尋高亮功能 |
| 2025-12-19 | enable-project-fulltext-search | 專案全文搜尋 |
| 2025-12-19 | enable-study-fields-in-report-search | 報告搜尋啟用 Study 欄位 |
| 2025-12-19 | establish-documentation-alignment-workflow | 文檔對齊工作流 |
| 2025-12-19 | implement-advanced-report-search | 進階報告搜尋 |
| 2025-12-19 | list-ai-capabilities | AI 能力清單 |
| 2025-12-19 | raise-study-select-cap | 提升 Study 選取上限 |
| 2025-12-23 | supplement-fe-requirements | 補充前端需求 |
| 2025-12-23 | unify-projects-search-ux | 統一專案搜尋 UX |
| 2025-12-26 | apply-sys-sd-traceability-to-image-data-platform | 系統追溯性應用 |
| 2025-12-26 | migrate-legacy-docs-to-image-data-platform | 舊文檔遷移 |
| 2026-01-02 | verify-old-docs-mapping | 驗證舊文檔對應 |

---

## 6. 附錄（Appendix）

---

