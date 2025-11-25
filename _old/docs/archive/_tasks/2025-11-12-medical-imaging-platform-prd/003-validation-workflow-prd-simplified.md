# 醫療影像AI驗證工作流系統 PRD (簡化版)

## 1. 執行摘要

### 1.1 系統目標
建立一個醫療影像AI驗證工作流系統，用於驗證AI模型對Aorta CTA檢查的判讀準確性。系統設計強調**鬆散耦合**、**無強制前置條件**、**快速執行**的原則。

### 1.2 核心價值
- **完整性**：涵蓋從PACS搜尋到檔案傳輸的完整驗證流程
- **邏輯性**：清晰的9步驟工作流，每步驟獨立可執行
- **快速性**：批次處理、並行執行，無不必要的等待
- **鬆散耦合**：各模組獨立運作，可自由組合

### 1.3 使用者
- 醫療影像AI研發團隊
- 臨床驗證醫師
- 資料管理人員

## 2. 核心工作流（9步驟）

```
步驟1: PACS搜尋
  ↓
步驟2: LLM分析醫師報告
  ↓
步驟3: 統計分析
  ↓
步驟4: 隨機抽樣（5-20個cases）
  ↓
步驟5: 醫師FP檢查 → [若FP過高：調整guideline → 重新測試]
  ↓
步驟6: Excel匯出（核准cases）
  ↓
步驟7: DICOM下載
  ↓
步驟8: 匿名化 & 轉換nii.gz
  ↓
步驟9: 檔案傳輸至驗證中心
```

### 2.1 步驟詳細說明

#### 步驟1：PACS搜尋
- **輸入**：搜尋條件（日期範圍、檢查類型：Aorta CTA）
- **處理**：從PACS系統搜尋符合條件的檢查
- **輸出**：Study清單及報告文字
- **可選協議**：DICOM C-FIND或REST API

#### 步驟2：LLM分析
- **輸入**：醫師文字報告
- **處理**：使用Ollama (qwen2.5:7b)進行三分類
- **輸出**：
  - 無疾病（no_disease）
  - 不確定（uncertain）
  - 有疾病（has_disease）
- **未來擴展**：整合病理報告、門診報告、前次檢查

#### 步驟3：統計分析
- **輸入**：LLM分析結果
- **處理**：計算各分類數量及百分比
- **輸出**：統計報表

#### 步驟4：隨機抽樣
- **輸入**：有疾病cases
- **處理**：隨機選擇5-20個cases
- **輸出**：待審核清單

#### 步驟5：醫師審核
- **輸入**：抽樣cases
- **處理**：醫師判斷是否為False Positive
- **輸出**：
  - 核准/拒絕決定
  - 若FP率過高→更新guideline→重新執行步驟2-5

#### 步驟6：Excel匯出
- **輸入**：核准的有疾病cases
- **處理**：整理為結構化Excel報表
- **輸出**：驗證清單Excel檔

#### 步驟7：DICOM下載
- **輸入**：Excel清單中的Study UIDs
- **處理**：從PACS下載DICOM檔案
- **輸出**：DICOM檔案目錄

#### 步驟8：匿名化與轉換
- **輸入**：DICOM檔案
- **處理**：
  - HIPAA標準匿名化
  - 轉換為nii.gz格式
  - 建立匿名ID對應表
- **輸出**：匿名DICOM、nii.gz檔案、對應清單

#### 步驟9：檔案傳輸
- **輸入**：匿名化檔案及清單
- **處理**：複製至臨床AI驗證中心
- **輸出**：傳輸完成確認

## 3. 簡化資料模型

### 3.1 核心資料表（5張）

#### ValidationWorkflow（驗證工作流）
```python
- id
- name（工作流名稱）
- study_type（檢查類型：Aorta CTA）
- status（狀態：進行中/完成/失敗）
- search_criteria（PACS搜尋條件）
- current_guideline（目前使用的guideline）
- created_at
- completed_at
```

#### StudyRecord（檢查記錄）
```python
- id
- workflow_id（關聯工作流）
- study_uid（DICOM Study UID）
- patient_id
- study_date
- report_text（醫師報告文字）
- llm_classification（LLM分類結果）
- physician_decision（醫師決定：核准/拒絕/FP）
- anonymous_id（匿名ID）
```

#### AnalysisResult（分析結果）
```python
- id
- study_id（關聯檢查）
- classification（no_disease/uncertain/has_disease）
- confidence_score（信心分數）
- key_findings（關鍵發現）
```

#### PhysicianReview（醫師審核）
```python
- id
- study_id（關聯檢查）
- is_false_positive（是否為FP）
- review_notes（審核意見）
- reviewer_name
- review_date
```

#### ExportBatch（匯出批次）
```python
- id
- workflow_id
- excel_path（Excel檔案路徑）
- dicom_path（DICOM儲存路徑）
- nifti_path（NIfTI儲存路徑）
- transfer_status（傳輸狀態）
- created_at
```

## 4. 系統介面設計

### 4.1 服務模組（鬆散耦合）

每個模組獨立運作，透過簡單介面通訊：

```python
# PACS服務介面
class PACSService:
    def search_studies(criteria: dict) -> List[Study]
    def download_study(study_uid: str) -> str

# LLM服務介面
class LLMService:
    def analyze_report(text: str) -> Classification
    def update_guideline(guideline: str) -> bool

# DICOM服務介面
class DICOMService:
    def anonymize(dicom_path: str) -> str
    def convert_to_nifti(dicom_path: str) -> str

# Excel服務介面
class ExcelService:
    def export_studies(studies: List) -> str
    def create_mapping(anonymous_ids: dict) -> str

# 傳輸服務介面
class TransferService:
    def copy_to_validation_center(files: List) -> bool
```

### 4.2 無強制前置條件設計

- 任何步驟都可獨立啟動
- 步驟間透過資料傳遞，非狀態依賴
- 失敗可從任意點恢復
- 可跳過不需要的步驟

## 5. 非功能需求

### 5.1 效能需求
- PACS搜尋：< 30秒（1000筆）
- LLM分析：批次處理，3個並行
- DICOM下載：支援斷點續傳
- 檔案傳輸：支援大檔案（>10GB）

### 5.2 可靠性
- 每步驟獨立重試機制
- 進度儲存，可從中斷點恢復
- 錯誤不影響其他步驟執行

### 5.3 擴展性
- 模組化設計便於新增功能
- 支援多種PACS協議
- 可整合其他LLM模型
- 預留多報告來源介面

## 6. 未來擴展

### 6.1 多報告來源整合（步驟2擴展）
```
2.1 病理報告整合
2.2 門診報告整合
2.3 前次檢查報告整合
→ 綜合判讀
```

### 6.2 支援更多檢查類型
- Brain MRI
- Chest CT
- Cardiac MRI

### 6.3 自動化增強
- 定時執行工作流
- 自動檔案傳輸排程
- 異常自動通知

## 7. 實施優先順序

### Phase 1（MVP）- 2週
- 核心9步驟工作流
- 基本Web介面
- Aorta CTA支援

### Phase 2（增強）- 2週
- 多報告來源整合
- 批次處理優化
- 進度監控

### Phase 3（擴展）- 3週
- 更多檢查類型
- 自動化排程
- 進階統計分析

## 8. 成功指標

- 工作流完成率 > 95%
- 平均處理時間 < 2小時（100個cases）
- FP檢出率準確性 > 90%
- 系統可用性 > 99%

## 9. 風險與緩解

| 風險 | 影響 | 緩解策略 |
|------|------|----------|
| PACS連線中斷 | 無法取得資料 | 支援多PACS來源、離線模式 |
| LLM服務故障 | 無法分析 | 規則基礎備援分類 |
| 大量資料傳輸 | 網路壅塞 | 分批傳輸、壓縮 |
| 醫師審核延遲 | 流程停滯 | 非同步審核、批次處理 |

---

**文件版本**: 1.0
**更新日期**: 2024-11-12
**狀態**: 簡化版，移除不必要的複雜性