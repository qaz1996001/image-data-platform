# ISO 14971 風險分析報告 (image_data_platform)

**文件 ID**: DOC-IMAGE-DATA-PLATFORM-REG-012  
**標題**: image_data_platform 專案初步風險分析報告  
**版本**: v1.0.0  
**狀態**: Active  
**建立日期**: 2025-12-24

---

## 1. 危害識別與風險評估表

| 危害 ID | 危害描述 | 危害情境 | 傷害嚴重程度 | 發生機率 | 風險等級 | 控制措施 | 剩餘風險 |
|--------|---------|---------|------------|---------|---------|---------|---------|
| H-001 | AI 演算法偽陰性 | 漏診微出血點，導致醫療決策偏差 | Moderate | Occasional | Medium | 模型效能驗證、使用者介面提示醫師須手動確認 | Low |
| H-002 | AI 演算法偽陽性 | 誤診微出血點，導致不必要的進階檢查 | Minor | Frequent | Medium | 信心值過濾、提供 AI 推論依據 (Heatmap) | Low |
| H-003 | 資料隱私洩漏 | 患者 MRI 影像包含敏感個資洩漏 | Serious | Improbable | Medium | 資料去識別化 (De-identification)、存取控制 | Low |
| H-004 | 軟體系統崩潰 | 醫師無法讀取影像或標註結果 | Minor | Remote | Low | 系統穩定性測試、日誌備份 | Low |

## 2. 嚴重程度與機率定義

### 2.1 嚴重程度 (Severity)
- **Serious**: 導致長期或不可逆傷害。
- **Moderate**: 導致短期傷害或需醫療處置。
- **Minor**: 導致不適或不便。

### 2.2 發生機率 (Probability)
- **Frequent**: 經常發生。
- **Occasional**: 偶爾發生。
- **Remote**: 極少發生。
- **Improbable**: 幾乎不發生。

## 3. 風險控制驗證
- 所有控制措施必須通過軟體系統測試或文件稽核驗證。

---

**文檔版本**: v1.0.0  
**最後更新**: 2025-12-24

