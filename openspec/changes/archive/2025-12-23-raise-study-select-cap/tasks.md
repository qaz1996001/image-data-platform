# Tasks: Raise Study Select Cap

## Implementation
- [x] RSC-01 更新 `/api/v1/reports/export` 使 CSV/ZIP 匯出包含 `content_raw` 欄位
- [x] RSC-02 於 `report-search` 能力新增規格，定義 `content_raw` 欄位為必備輸出

## Validation
- [x] RSV-01 透過本機後端呼叫 `POST /api/v1/reports/export`，確認下載的 CSV 具有 `content_raw` 欄位並填入原始內容


