## ADDED Requirements

### Requirement: 檢查搜尋結果高亮顯示
系統 SHALL 在 `/study-search` 搜尋結果列表與檢查詳情頁面中高亮顯示符合搜尋條件的文字，以黃色背景和加粗字體標記，幫助使用者快速定位相關資訊。

#### Scenario: 搜尋文字高亮
- **GIVEN** 使用者在檢查搜尋頁面輸入搜尋關鍵字「腹部」
- **WHEN** 使用者點擊某個檢查查看詳情
- **THEN** 系統在檢查詳情頁面中將所有包含「腹部」的文字以黃色背景 (#fff566) 和加粗字體顯示

#### Scenario: 搜尋結果列表欄位高亮
- **GIVEN** 使用者在檢查搜尋頁面輸入搜尋關鍵字「31410270375」
- **WHEN** 系統顯示搜尋結果列表
- **THEN** 系統在列表可見欄位（例如 Accession Number、Patient ID、Patient Name、Description）中將符合文字以黃色背景 (#fff566) 和加粗字體顯示

#### Scenario: 多關鍵字高亮
- **GIVEN** 使用者搜尋包含多個關鍵字的條件（如病患姓名和檢查部位）
- **WHEN** 使用者點擊某個檢查查看詳情
- **THEN** 系統同時高亮顯示所有匹配的關鍵字
- **AND** 不同關鍵字使用相同的視覺樣式

#### Scenario: 大小寫不敏感匹配
- **GIVEN** 使用者搜尋關鍵字「Xray」
- **WHEN** 檢查內容包含「xray」、「XRAY」或「XRay」
- **THEN** 系統高亮顯示所有大小寫變體的匹配文字

#### Scenario: 無搜尋條件時不高亮
- **GIVEN** 使用者直接從其他頁面進入檢查詳情（無搜尋條件）
- **WHEN** 查看檢查詳情
- **THEN** 系統不進行任何文字高亮，正常顯示內容

#### Scenario: 詳情頁 Verified Report 區塊高亮
- **GIVEN** 使用者以搜尋關鍵字「Abdomen」查詢並進入某筆檢查詳情
- **WHEN** 詳情頁顯示 Verified Report 區塊（報告標題/內容）
- **THEN** 系統在 Verified Report 區塊中同樣以黃色背景 (#fff566) 和加粗字體高亮顯示符合搜尋條件的文字


