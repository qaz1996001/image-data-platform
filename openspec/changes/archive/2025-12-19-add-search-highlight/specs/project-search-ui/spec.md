## ADDED Requirements

### Requirement: Projects 搜尋結果高亮顯示
系統 SHALL 在 `/projects` 的搜尋結果列表中，以黃色背景 (#fff566) 和加粗字體高亮顯示符合搜尋條件的文字，幫助使用者快速定位相關專案。

#### Scenario: Projects 列表高亮
- **GIVEN** 使用者在 Projects 搜尋輸入關鍵字「AI」
- **WHEN** 系統顯示 Projects 列表（grid/list）
- **THEN** 系統在專案卡片/列表的可見文字（例如專案名稱、描述、標籤）中將符合文字以黃色背景 (#fff566) 和加粗字體顯示


