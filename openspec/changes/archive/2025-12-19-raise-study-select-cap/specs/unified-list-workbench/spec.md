# Spec: Study Search Selection Limit

## MODIFIED Requirements

### Requirement: 批次選擇與匯出入口
Study Search 的「全選全部」行為 MUST 允許透過設定值控制一次抓取與選取的最大筆數，預設 9,999。

#### Scenario: 使用者在 Study Search 點擊「全選全部」且總筆數 <= 上限
- 給定 `STUDY_SEARCH_FULL_SELECT_CAP = 9,999`
- 且當前查詢的總筆數 `total = 5,485`
- 當使用者點擊 ResultsCard summary 旁的「全選全部」按鈕
- 則前端 MUST 以 `page_size = min(total, cap)` 呼叫後端並成功選取所有 5,485 筆
- 並顯示成功提示「已選取全部 5,485 筆」

#### Scenario: 總筆數超過上限
- 給定 `cap = 9,999`
- 且 `total = 25,000`
- 當使用者點擊「全選全部」
- 則系統 MUST 只抓取並選取 cap 筆資料（9,999）
- 並顯示警示訊息「已選取 9,999 筆，上限已達；請縮小篩選」
- 按鈕文案 MUST 仍提供「取消全選」以清除這 9,999 筆

#### Scenario: 管理者需要調整上限
- 給定 build-time 或 runtime 可覆寫 `STUDY_SEARCH_FULL_SELECT_CAP`
- 當設定為 `cap = 2,000`
- 則 summary 按鈕文案 MUST 改為「全選全部 (最多 2,000 筆)」
- 所有上述成功與超出上限行為 MUST 以新 cap 值為準


