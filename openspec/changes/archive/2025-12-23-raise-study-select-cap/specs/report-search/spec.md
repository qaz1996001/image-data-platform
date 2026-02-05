# Spec Delta: Report Search Export Enhancements

## ADDED Requirements

### Requirement: RS-EXPORT-001 報告匯出必須包含原始內容
Report Search 的批次匯出功能 SHALL 在 CSV/ZIP 檔案中加入 `content_raw` 欄位，以便分析或轉存完整報告內容。

#### Scenario: 匯出檔案含 content_raw 欄位
- **GIVEN** 使用者在報告檢索頁面選取多筆報告後點擊「匯出」
- **WHEN** 下載後開啟 CSV
- **THEN** 檔案欄位 MUST 包含 `content_raw` 並放入每筆報告的完整原始文字
- **AND** 若報告內容為空，該欄位 SHOULD 為空字串以維持欄位一致性


