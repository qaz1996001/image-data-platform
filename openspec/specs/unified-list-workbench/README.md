---
spec-id: unified-list-workbench
spec-name: unified-list-workbench
version: 1.0.0
status: approved
created-at: 2025-11-24
updated-at: 2025-11-24
---

# unified-list-workbench — 完整規格文件套件

## 📋 概述

本目錄包含 **unified-list-workbench** 規格的完整文件集合，詳細描述了如何在 Image Data Platform 前端建立統一的列表頁面佈局系統。

**關鍵目標**:
1. ✅ 統一 Reports、Study Search、Projects 三個列表頁面的視覺風格與互動模式
2. ✅ 建立可重用的 ListWorkbench 組件家族 (Header、FilterCard、ResultsCard 等)
3. ✅ 支援響應式設計、深色模式、無障礙性訪問
4. ✅ 提供完整的設計、實作、測試指引

---

## 📂 文件結構

### 1. **spec.md** — OpenSpec 規格主文件
- **描述**: 針對 unified-list-workbench 的核心規格文件
- **內容**:
  - Purpose: 產品目標與願景
  - Requirements: 四個主要需求
    - Requirement: List Workbench Header
    - Requirement: Filter Card
    - Requirement: Results Card
    - Requirement: 批次選擇與匯出入口
  - 三頁面適配方案 (Reports / Study Search / Projects)
- **版本**: v1.0.0 ✅
- **狀態**: Approved
- **讀者**: PM、Tech Lead、Architect

### 2. **prd.md** — 產品需求文件 (PRD)
- **描述**: 從產品視角詳細描述需求、功能與使用者故事
- **內容**:
  - 1. 產品概述：背景、動機、願景、目標
  - 2. 功能需求：組件家族詳解、三頁面適配
  - 3. 技術需求：技術棧、CSS 變數、響應式設計、a11y
  - 4. 使用者故事 (User Stories)
  - 5. 驗收標準 (Acceptance Criteria)
  - 6. 約束與假設
  - 7. 優先級 (P0/P1/P2)
  - 8. 風險與緩解
- **版本**: 1.0.0 ✅
- **狀態**: Approved
- **讀者**: PM、Design、Frontend Team

### 3. **sr.md** — 軟體需求規格 (SR)
- **描述**: 將 PRD 需求轉化為可實作與可驗證的軟體需求
- **內容**:
  - 1. 組件架構需求 (ULW-SR-001/002)
  - 2. Header 需求 (ULW-SR-010~012)
  - 3. FilterCard 需求 (ULW-SR-020~024)
  - 4. ResultsCard 需求 (ULW-SR-030~035)
  - 5. StatusBar 需求 (ULW-SR-040~044)
  - 6. SelectionDrawer 需求 (ULW-SR-050~055)
  - 7. ColumnSettingsDrawer 需求 (ULW-SR-060~062)
  - 8. CSS 與樣式需求 (ULW-SR-070~073)
  - 9. 三頁面適配需求 (ULW-SR-100/110/120)
  - 10. 測試需求 (ULW-SR-200~202)
  - 11. 效能需求 (ULW-SR-300~302)
  - 12. 無障礙性需求 (ULW-SR-400~402)
  - 13. 相容性需求 (ULW-SR-500~501)
- **版本**: 1.0.0 ✅
- **狀態**: Approved
- **讀者**: Frontend Engineers、QA、Tech Lead

### 4. **sd.md** — 軟體設計文件 (SD)
- **描述**: 詳細的軟體架構與實作設計指引
- **內容**:
  - 1. 架構概述：整體結構、組件關係圖、頁面使用模式
  - 2. 組件設計細節：每個組件的實作方式與代碼範例
    - ListWorkbench.Header 設計
    - FilterCard 設計
    - ResultsCard 設計
    - StatusBar 設計
    - SelectionDrawer 設計
    - ColumnSettingsDrawer 設計
  - 3. 資料流程與狀態管理：狀態流轉圖、ListViewStore 整合
  - 4. CSS 架構：變數體系、類別層次、響應式設計
  - 5. 與頁面層整合設計：Reports / Study Search / Projects 集成方案
  - 6. 測試策略：單元測試、E2E 測試、視覺回歸測試
  - 7. 效能優化：渲染優化、防抖、API 最適化
  - 8. 深色模式支援
  - 9. 無障礙性設計：鍵盤焦點、Aria 標籤、焦點順序
  - 10. 版本管理與向後相容性
- **版本**: 1.0.0 ✅
- **狀態**: Approved
- **讀者**: Frontend Engineers、Architects、Code Reviewers

### 5. **tasks.md** — 任務與驗收標準 (Tasks & Acceptance Criteria)
- **描述**: 所有實現 unified-list-workbench 所需的工作項目及驗收條件
- **內容**:
  - Task 總覽表 (17 個任務)
  - 已完成任務詳細說明：
    - ULW-T-001: 審核與批准所有規格文件 ✅
    - ULW-T-010: ListWorkbench 組件基礎實現 ✅
    - ULW-T-020: FilterCard 與進階篩選支援 ✅
    - ULW-T-030: ResultsCard 與 StatusBar 實現 ✅
    - ULW-T-040: SelectionDrawer 與 SelectionDrawerTrigger 實現 ✅
    - ULW-T-050: ColumnSettingsDrawer 實現 ✅
    - ULW-T-060: CSS 變數與樣式系統實現 ✅
    - ULW-T-070/080/090: 三頁面遷移 ✅
    - ULW-T-100: 組件單元測試編寫 ✅
    - ULW-T-110: Playwright E2E 測試編寫 ✅
    - ULW-T-120: 深色模式支援與驗證 ✅
    - ULW-T-130: 響應式設計驗證 ✅
    - ULW-T-140: 文件完成 ✅
    - ULW-T-150: 效能優化與指標驗證 ✅
    - ULW-T-160: 無障礙性 (a11y) 檢查 ✅
    - ULW-T-170: 程式碼審查與合併 ✅
  - 後續改進計畫 (v1.1 / v2.0)
  - 風險與緩解措施
  - 簽核與發布
- **版本**: 1.0.0 ✅
- **狀態**: Active
- **讀者**: Project Manager、Tech Lead、QA、Frontend Team

---

## 📊 文件對應關係

```
unified-list-workbench/
│
├── spec.md (OpenSpec 主規格)
│   └── 詳述四個主要需求 (Requirement: Header / Filter / Results / Batch)
│
├── prd.md (產品視角)
│   ├── 基於 spec.md 的需求
│   ├── 添加產品故事、用戶角色、驗收標準
│   └── 規定優先級與風險分析
│
├── sr.md (開發視角 - 軟體需求)
│   ├── 基於 prd.md 的功能
│   ├── 拆解為 ULW-SR-001 ~ 501 的可驗證需求
│   ├── 逐個組件詳述 Props、行為、限制
│   └── 包含測試、效能、a11y 需求
│
├── sd.md (架構與實作視角)
│   ├── 基於 sr.md 的需求
│   ├── 提供架構設計、代碼示例、資料流程
│   ├── 組件間互動設計
│   └── 整合、測試、優化策略
│
└── tasks.md (執行與驗收視角)
    ├── 基於所有文件的需求
    ├── 分解為 17 個具體任務 (ULW-T-001 ~ 170)
    ├── 每個任務配備驗收標準
    └── 包含完成狀態與後續計畫
```

---

## 🎯 快速導讀指南

**如果你是 PM**：
- 閱讀：[prd.md](./prd.md) 第 1-6 章
- 重點：功能需求、使用者故事、驗收標準、優先級

**如果你是 Tech Lead**：
- 閱讀：[spec.md](./spec.md) 全文 + [sd.md](./sd.md) 第 1-2 章
- 重點：架構、組件設計、技術棧、風險評估

**如果你是 Frontend Engineer**：
- 閱讀：[sr.md](./sr.md) 全文 + [sd.md](./sd.md) 第 2-7 章 + [tasks.md](./tasks.md) 相關章節
- 重點：需求詳述、設計方案、代碼示例、測試策略

**如果你是 QA/Tester**：
- 閱讀：[prd.md](./prd.md) 第 5 章 + [sr.md](./sr.md) 第 10 章 + [tasks.md](./tasks.md)
- 重點：驗收標準、測試需求、測試檢查清單

**如果你是 Designer**：
- 閱讀：[prd.md](./prd.md) 第 2-3 章 + [sd.md](./sd.md) 第 4 章
- 重點：功能需求、CSS 變數、響應式設計、深色模式

---

## ✅ 文件完整性檢查

### 審核清單

- [x] **spec.md**
  - [x] Purpose 已完善（從 TBD 更新為詳細說明）
  - [x] 四個 Requirements 清晰明確
  - [x] 包含三頁面適配方案
  - [x] 無遺漏的技術需求

- [x] **prd.md**
  - [x] 背景、動機、願景清楚
  - [x] 6 個功能需求詳述
  - [x] 3 個使用者故事完整
  - [x] 5 個驗收標準明確
  - [x] 7 個優先級分類
  - [x] 8 個風險與緩解

- [x] **sr.md**
  - [x] 組件架構需求清晰
  - [x] ULW-SR-001 ~ 501 範圍涵蓋完整
  - [x] 每個需求都有驗收條件
  - [x] Props 規範具體
  - [x] 三頁面適配需求詳細
  - [x] 測試、效能、a11y、相容性需求完備

- [x] **sd.md**
  - [x] 架構概述與組件關係圖
  - [x] 6 個主要組件設計方案
  - [x] 資料流程圖與狀態管理
  - [x] CSS 架構與響應式設計
  - [x] 三頁面集成方案
  - [x] 測試策略詳盡
  - [x] 深色模式、a11y、版本管理

- [x] **tasks.md**
  - [x] 17 個任務完整列表
  - [x] 所有任務標記狀態 (Completed)
  - [x] 每個任務有詳細驗收標準
  - [x] 後續改進計畫 (v1.1/v2.0)
  - [x] 風險與緩解措施
  - [x] 簽核與發布流程

---

## 📈 文件統計

| 文件 | 行數 | 內容量 | 完成度 |
|------|------|--------|--------|
| spec.md | 50 | 基礎規格 | ✅ 100% |
| prd.md | 420+ | 產品詳述 | ✅ 100% |
| sr.md | 650+ | 軟體需求 | ✅ 100% |
| sd.md | 550+ | 設計方案 | ✅ 100% |
| tasks.md | 700+ | 工作項目 | ✅ 100% |
| **合計** | **2,370+** | **完整規格套件** | **✅ 100%** |

---

## 🔗 相關文件與實現

### 實現檔案參考

**前端組件**：
```
frontend/src/components/ListWorkbench/
├── ListWorkbench.tsx        (主組件 + FilterCard + ResultsCard + StatusBar)
├── SelectionDrawer.tsx      (選取清單與觸發按鈕)
├── ColumnSettingsDrawer.tsx (欄位設定)
├── list-workbench.css       (樣式與 CSS 變數)
└── index.ts                 (統一匯出)
```

**頁面實現**：
```
frontend/src/pages/
├── Reports/index.tsx        (Reports 頁面適配)
├── StudySearch/index.tsx    (Study Search 頁面適配)
└── Projects/index.tsx       (Projects 頁面適配)
```

**測試**：
```
frontend/src/components/ListWorkbench/__tests__/  (單元測試)
frontend/e2e/                                      (E2E 測試)
```

**文件**：
```
frontend/docs/features/list-workbench-guide.md    (使用指南)
docs/requirements/02_FRONTEND_PRD_SR_SD.md        (整體前端規格)
```

---

## 🚀 使用指南

### 開始新的列表頁面

若要建立新的列表頁面（例如 `/export-logs`），請遵循以下步驟：

1. **參考三頁面中的任一個**（通常選擇最相似的）
2. **使用 ListWorkbench 架構**：
   ```typescript
   <ListWorkbench>
     <ListWorkbench.Header ... />
     <ListWorkbench.Body>
       <FilterCard ... />
       <ResultsCard ... />
     </ListWorkbench.Body>
   </ListWorkbench>
   ```
3. **套用 CSS 變數**：所有樣式使用 `--lw-*` 變數，無需自訂顏色
4. **實現 StatusBar**：按照 sr.md ULW-SR-042 的順序構建
5. **集成 SelectionDrawer**：如需批次操作
6. **編寫測試**：遵循 e2e 測試範本

---

## 📞 審核與批准

### 簽核流程

| 角色 | 文件 | 簽核日期 | 狀態 |
|------|------|----------|------|
| PM | prd.md | 2025-11-24 | ✅ Approved |
| Tech Lead | spec.md / sd.md / tasks.md | 2025-11-24 | ✅ Approved |
| Architecture | sr.md | 2025-11-24 | ✅ Approved |
| Frontend Team | 實現代碼 | 2025-11-24 | ✅ Completed |

### 發布資訊

- **版本**: 1.0.0
- **狀態**: Approved
- **發布日期**: 2025-11-24
- **下一版本**: v1.1 (計畫中，包含快捷鍵支援)

---

## 📝 更新記錄

| 日期 | 版本 | 變更 |
|------|------|------|
| 2025-11-24 | 1.0.0 | 初始版本，所有文件完成 |

---

## ❓ 常見問題

**Q: 三頁面都已遷移至 ListWorkbench，現在要建立新的列表頁面，要做什麼？**  
A: 遵循本目錄 sd.md 中的「頁面集成設計」章節，複製最接近的頁面結構。

**Q: 組件有更新需求怎麼辦？**  
A: 在 openspec/changes 中新增 change proposal，遵循版本管理規則 (v1.1 / v2.0)。

**Q: 如何報告 Bug 或提出改進建議？**  
A: 在 GitHub Issues 中建立，標籤為 `[list-workbench]`，並參考本規格文件的相關章節。

**Q: 文件什麼時候會更新？**  
A: 每個重大版本發布時（v1.1 / v2.0）會更新，修復型發布無需更新文件。

---

## 🎓 學習資源

- Ant Design 5 文件: https://ant.design/
- React 18 文件: https://react.dev/
- CSS 變數 (CSS Custom Properties): https://developer.mozilla.org/en-US/docs/Web/CSS/--*
- WCAG 2.1 無障礙標準: https://www.w3.org/WAI/WCAG21/quickref/

---

## 📄 許可與歸屬

本規格文件由 Image Data Platform 項目團隊編寫，遵循項目的標準規範與流程。

---

*最後更新時間：2025-11-24 | 下一版本：1.1 | 狀態：Approved ✅*

