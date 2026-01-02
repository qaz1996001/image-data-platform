# AI Capabilities Specification

本規範列出影像數據平台中所有 AI 相關功能的詳細說明。

## ADDED Requirements

### Requirement: 報告 AI 分析功能
系統 SHALL 提供基於本地 LLM（Ollama）的報告智能分析功能，支援單報告和批量分析，並將結果儲存為 AI 註解。

#### Scenario: 單報告 AI 分析
- **WHEN** 用戶選擇單個報告並提供自定義提示詞
- **AND** 選擇標註類型（高亮、分類、提取、評分）
- **THEN** 系統調用 Ollama LLM（qwen2.5:7b）進行分析
- **AND** 分析結果儲存為 AIAnnotation 記錄
- **AND** 返回包含標註內容、置信度和元資料的分析結果

#### Scenario: 批量報告 AI 分析
- **WHEN** 用戶選擇多個報告（最多 50-100 個）
- **AND** 提供統一的提示詞和標註類型
- **THEN** 系統使用後台任務隊列進行批量處理
- **AND** 支援並發處理（3-5 個同時）
- **AND** 提供進度追蹤和錯誤處理
- **AND** 每個報告的分析結果獨立儲存為 AIAnnotation

#### Scenario: AI 標註類型 - 高亮
- **WHEN** 用戶選擇「高亮」標註類型
- **THEN** 系統提取報告中的關鍵短語或句子
- **AND** 返回包含文字位置（start, end）和原因的高亮標記
- **AND** 結果格式為 JSON，包含 highlights 陣列

#### Scenario: AI 標註類型 - 分類
- **WHEN** 用戶選擇「分類」標註類型
- **THEN** 系統對報告進行分類（如嚴重程度：正常/輕度/中度/重度）
- **AND** 返回分類結果、置信度和推理過程
- **AND** 結果格式為 JSON，包含 category、confidence 和 reasoning

#### Scenario: AI 標註類型 - 提取
- **WHEN** 用戶選擇「提取」標註類型
- **THEN** 系統從報告中提取結構化資訊（如測量值、病灶位置）
- **AND** 返回提取的項目、數值、單位和位置
- **AND** 結果格式為 JSON，包含 measurements 陣列

#### Scenario: AI 標註類型 - 評分
- **WHEN** 用戶選擇「評分」標註類型
- **THEN** 系統對報告進行數值評分
- **AND** 返回評分值和評分依據
- **AND** 結果格式為 JSON，包含 score 和 rationale

#### Scenario: 提示詞模板管理
- **WHEN** 用戶使用預置提示詞模板
- **THEN** 系統提供 6 個預置模板（關鍵發現、嚴重程度、病灶資訊、測量值提取等）
- **AND** 用戶可以保存自定義提示詞為模板
- **AND** 支援提示詞的復用和管理

#### Scenario: AI 註解查詢
- **WHEN** 用戶查詢報告的 AI 註解
- **THEN** 系統返回該報告的所有 AIAnnotation 記錄
- **AND** 包含註解類型、內容、置信度、建立時間和建立者資訊
- **AND** 支援按註解類型過濾

### Requirement: 醫療影像 AI 驗證工作流
系統 SHALL 提供 9 步臨床工作流，用於驗證 AI 模型對主動脈 CTA 檢查的準確性，其中包含 LLM 分析步驟。

#### Scenario: LLM 分析分類
- **WHEN** 工作流執行 LLM 分析步驟
- **THEN** 系統使用 Ollama LLM（qwen2.5:7b）分析檢查報告
- **AND** 對每個檢查進行分類：no_disease / uncertain / has_disease
- **AND** 儲存分類結果、置信度分數和關鍵發現到 AnalysisResult
- **AND** 支援批量處理多個檢查

#### Scenario: 統計分析
- **WHEN** 工作流執行統計步驟
- **THEN** 系統計算分類結果的分佈百分比
- **AND** 顯示各類別（no_disease / uncertain / has_disease）的統計資訊
- **AND** 提供視覺化統計圖表

#### Scenario: 隨機採樣
- **WHEN** 工作流執行隨機採樣步驟
- **THEN** 系統從 has_disease 類別中隨機選擇 5-20 個案例
- **AND** 儲存採樣結果供後續醫師審查

#### Scenario: 醫師審查
- **WHEN** 醫師審查採樣案例
- **THEN** 系統記錄醫師的判斷（是否為假陽性）
- **AND** 儲存審查備註和審查者姓名
- **AND** 更新 StudyRecord 的 physician_decision 欄位

### Requirement: 醫學影像推理模型整合
系統 SHALL 整合醫學影像推理模型，用於影像分割、分類和處理任務。

#### Scenario: SynthSeg 腦部分割
- **WHEN** 系統需要進行腦部影像分割
- **THEN** 系統使用 SynthSeg 模型進行分割
- **AND** 模型路徑配置為字典格式：{'unet_model': path, 'unet_l2l_model': path}
- **AND** 支援 MetaTensor 格式的影像輸入，元資料封裝在 tensor 中

#### Scenario: Series Classification
- **WHEN** 系統需要對影像序列進行分類
- **THEN** 系統使用 Series Classification 模型
- **AND** 返回序列的分類結果和置信度

#### Scenario: nnUNet 影像分割
- **WHEN** 系統需要進行醫學影像分割
- **THEN** 系統使用 nnUNet 模型
- **AND** 支援多種解剖結構的分割任務
- **AND** 使用 MONAI transforms 進行影像正規化
- **AND** CT 影像使用 ScaleIntensityRange(-250, 550) 處理 HU 值

#### Scenario: 統一模型介面
- **WHEN** 系統載入任何推理模型
- **THEN** 所有模型路徑統一為字典格式（Dict[str, str]）
- **AND** 所有模組使用 image_tensor 介面（Union[torch.Tensor, MetaTensor]）
- **AND** 元資料封裝在 tensor 中，無需額外參數傳遞

### Requirement: AI 功能狀態追蹤
系統 SHALL 記錄每個 AI 功能的實作狀態和可用性。

#### Scenario: 報告 AI 分析狀態
- **WHEN** 查詢報告 AI 分析功能狀態
- **THEN** 系統顯示：
  - 前端界面：已完成
  - 後端 API：開發中（預計 3 週）
  - Ollama 整合：規劃中
  - AIAnnotation 模型：已實作並啟用

#### Scenario: 驗證工作流狀態
- **WHEN** 查詢驗證工作流功能狀態
- **THEN** 系統顯示：
  - 工作流引擎：100% 實作完成
  - 支援服務（PACS、LLM、DICOM）：100% 實作完成
  - API 端點：0% 實作（完全阻塞）
  - 前端界面：10% 實作（可重用現有組件）
  - 資料模型：已建立但未啟用（需執行 migrations）

#### Scenario: 推理模型狀態
- **WHEN** 查詢推理模型功能狀態
- **THEN** 系統顯示：
  - IntegratedModelManager：已整合真實推理流程
  - SynthSeg：已整合
  - Series Classification：已整合
  - nnUNet：已整合
  - 測試環境：WSL + conda nnUNet，模型可正常載入

