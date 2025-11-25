## Context
- Study Search 使用 `ListViewStore` selection，提供 `Selected List` Drawer，批次行為（加入專案、Available Actions）在 Drawer 內呈現；`ResultsCard.actions` 仍含「全選/取消、加入專案、已選清單」等多顆按鈕。
- Reports 以本地 state 管理 selection；`ResultsCard.actions` 直接堆疊欄位設定、全選/取消、查看清單、清除選擇以及所有批次按鈕。當總寬度不足時按鈕換行，破壞 spec 所要求的緊湊頭部列。
- Reports 的 Drawer 與 Study Search Drawer props 命名、操作順序不同，導致想共用無法直接抽象。

## Goals / Non-Goals
- Goals
  - 合併 Selection Drawer API：統一標題、批次動作 slot、清除/移除流程。
  - 將批次行為入口移出 `list-workbench-actions-area`，專注於欄位設定 + Drawer 入口。
  - 確保 Meta badge 與 selection badge 同步顯示方式。
- Non-Goals
  - 不改動 Projects 頁目前行為（另案）。
  - 不重新設計 Batch Action Registry，只重用現有 hook。

## Decisions
1. **受限 actions 區塊**  
   - `ResultsCard` 新增 guard：若 `actionsMode=\"drawer-only\"`，僅渲染欄位設定按鈕與 Drawer 觸發器 slot。其他批次按鈕一律以 Drawer 形式呈現。
2. **共用 Selection Drawer**  
   - 建立 `@components/ListWorkbench/SelectionDrawer`，以 props 提供 `items`, `renderItem`, `primaryActions`（如加入專案/匯出）、`secondaryActions`（清除/移除）。Study Search 與 Reports 傳入各自的 render 與 action config，但分享相同框架與標題樣式。
3. **Batch Action 入口**  
   - Reports 原本在上方顯示的匯出/列印/歸檔/刪除，改成 Drawer header 的 `ActionGroup`，並沿用 Study Search Batch Action Registry 觸發流程，以 `Space wrap` 呈現。
4. **CSS 與 Icon 統一**  
   - `list-workbench-actions-area` 只包含 icon button 與 Drawer trigger button，設定最小寬度與 gap；`SettingOutlined` 作為欄位設定 icon，`FolderOpenOutlined`（或現有）作為 Drawer 入口。

## Risks / Trade-offs
- Drawer 放入更多動作可能需要垂直滾動；以 `Space` + `Card` 分區，並在行動裝置時折疊批次按鈕為 `Dropdown` 作為後續優化。
- Reports 使用本地 selection map；重構時需確保 hook 仍支援跨頁 selection，避免 Drawer 列表與 Table 選取不同步。

## Validation Plan
- Storybook: 補 `ListWorkbench/ResultsCard` demo，示範 drawer-only 模式。
- 前端自動化：保留現有單元測試並新增 `SelectionDrawer` snapshot。
- 手動：在 1280px 與 360px 視窗驗證兩頁：欄位設定 icon 與 Drawer 入口位置一致、批次行為僅在 Drawer 內顯示。

