# Change: 新增文字選取到 AI 聊天室功能

## Why

用戶在瀏覽報告、檢查或其他內容時，經常需要將選取的文字內容發送到 AI 助手進行分析或詢問。目前用戶需要手動複製貼上，流程繁瑣。提供拖曳和右鍵選單功能可以：
- **提升效率**：快速將選取內容添加到 AI 對話
- **改善體驗**：減少複製貼上的步驟
- **增強互動**：讓 AI 助手更自然地融入工作流程
- **保持上下文**：選取的內容自動包含在對話中

## What Changes

- **拖曳功能**：用戶可以拖曳選取的文字到 AI 懸浮按鈕或對話框
- **右鍵選單**：在選取文字時顯示右鍵選單，提供「發送到 AI 助手」選項
- **自動填充**：選取的內容自動填充到輸入框或作為新訊息發送
- **視覺反饋**：拖曳時顯示視覺提示，指示可以放置的位置

## Impact

- **受影響的規範**: 修改 `floating-ai-assistant` 規範
- **受影響的代碼**: 
  - `frontend/src/components/AIAssistant/FloatingButton.tsx` - 添加拖曳接收功能
  - `frontend/src/components/AIAssistant/ChatDialog.tsx` - 添加拖曳接收和右鍵選單處理
  - `frontend/src/hooks/useTextSelection.ts` - 新建文字選取處理 hook（可選）
  - `frontend/src/utils/textSelection.ts` - 新建文字選取工具函數
- **用戶影響**: 所有用戶都可以使用拖曳和右鍵選單功能將選取內容發送到 AI 助手

