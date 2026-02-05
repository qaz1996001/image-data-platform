# Raise Study Select Cap

## Problem
- Study Search 的「全選全部」功能目前受到未公開的 API 預設頁大小（100 筆）限制，導致只能選取前 100 筆資料，無法符合使用者「一次選取 5,485 筆檢查」的需求。
- 缺乏可調整的上限設定；若後端或 API 允許更大值，前端仍無法快速調整或降級 fallback。

## Goal
1. 允許 Study Search 頁面透過單一設定值決定「全選全部」動作的最大抓取筆數，預設 9,999，並允許系統管理員後續視需要調整。
2. 明確 UI 行為：當總筆數 <= 限制時應完整選取並提示成功；若超出限制，須選取上限筆數並提示「僅選取上限」。

## Non-goals
- 不調整後端 API 的最大 page_size；若 API 不支援，前端需自行分頁抓取或中止。
- 不變動 Reports / Projects 頁面的 Selection Drawer 行為，除非後續驗證需要一致設定。

## Approach
- 新增 `studySearchSelectionCap` 設定（臨時可放在前端常數或環境設定），預設值 9,999，可由 build-time 設定覆寫。
- Study Search 的 `handleSelectAllAcrossPages` 在呼叫 API 前先以 `Math.min(total, selectionCap)` 作為 `pageSize`，並在 API 無法提供足夠筆數時給予提示。
- `ResultsCard` 的 Summary 按鈕文案更新，當前已選取筆數 >= min(total, cap) 時顯示「取消全選」，其餘狀態顯示「全選全部 (最多 cap 筆)」。

## Validation
- Unit：`StudySearchContent` 中的 `handleSelectAllAcrossPages` 需以 jest/vitest 模擬不同 `total` 與 API 回傳筆數，確保訊息顯示正確。
- Manual：在瀏覽器透過假的 120 筆資料，確認會顯示「已選取上限 9999」與「取消全選」行為。
- Openspec：`openspec validate raise-study-select-cap --strict`


