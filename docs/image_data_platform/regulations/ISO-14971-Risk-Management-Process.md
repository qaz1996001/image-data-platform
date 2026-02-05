# ISO 14971 風險管理過程指南 (image_data_platform)

**文件 ID**: DOC-IMAGE-DATA-PLATFORM-REG-011  
**標題**: image_data_platform 專案醫療器材風險管理流程指南  
**版本**: v1.0.0  
**狀態**: Active  
**建立日期**: 2025-12-24

---

## 1. 目的

本文件定義 `image_data_platform` 專案如何實作 ISO 14971:2019 標準要求，系統性地管理 AI 軟體在預期用途下的所有風險。

## 2. 風險管理流程

### 2.1 風險管理計劃 (Risk Management Plan)
- 定義風險可接受程度準則 (Acceptability Criteria)。
- 建立風險矩陣 (Severity vs. Probability)。

### 2.2 風險分析 (Risk Analysis)
- 識別產品特性。
- 識別已知與可預見的危害 (Hazards)，例如：
  - AI 演算法偏差。
  - MRI 資料品質不良 (Artifacts)。
  - 使用者誤解 AI 標註結果。

### 2.3 風險評估 (Risk Evaluation)
- 根據矩陣評估各個危害情境的風險。

### 2.4 風險控制 (Risk Control)
- 實施控制措施，順序為：
  1. 固有的安全性設計 (Inherent safety by design)。
  2. 軟體保護措施。
  3. 安全資訊 (Warnings/Manuals)。

### 2.5 剩餘風險評估 (Residual Risk Evaluation)
- 評估實施控制措施後的剩餘風險是否可接受。

## 3. 風險管理報告
- 定期產出風險管理總結報告，存放於 `docs/image_data_platform/compliance/`。

---

**文檔版本**: v1.0.0  
**最後更新**: 2025-12-24

