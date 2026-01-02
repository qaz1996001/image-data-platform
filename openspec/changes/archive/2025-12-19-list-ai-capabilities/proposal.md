# Change: 列出 AI 功能清單

## Why

目前專案中已實作或規劃了多項 AI 功能，但缺乏統一的規範文件來記錄這些功能。建立完整的 AI 功能清單規範有助於：
- 明確現有 AI 功能的範圍和能力
- 為後續開發提供參考基準
- 幫助新成員快速了解系統的 AI 能力
- 支援功能規劃和優先級排序

## What Changes

- **新增規範**: 建立 `ai-capabilities` 規範，列出所有 AI 相關功能
- **功能分類**: 將 AI 功能分為三大類：
  1. 報告 AI 分析（Report AI Analysis）
  2. 醫療影像 AI 驗證工作流（Medical Imaging AI Validation Workflow）
  3. 醫學影像推理模型（Medical Imaging Inference Models）
- **詳細說明**: 每個功能包含實作狀態、技術細節和使用場景

## Impact

- **受影響的規範**: 無（新增規範）
- **受影響的代碼**: 無（僅文檔化現有功能）
- **用戶影響**: 無（僅文檔化，不改變現有行為）

