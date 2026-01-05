# TEMPLATE: image_data_platform OpenSpec 整合指南（OpenSpec Integration Guide）

> **使用說明**  
> 本模板適用於 `docs/image_data_platform/openspec-integration/` 下的文件，  
> 用來說明 OpenSpec 變更如何映射到本專案之需求、架構、測試與文檔。

---

**文件 ID**: IDP-OPENSPEC-INTEG-001  
**標題**: image_data_platform — OpenSpec 整合指南  
**版本**: v1.0.0  
**狀態**: Draft  
**建立日期**: YYYY-MM-DD  
**最後更新**: YYYY-MM-DD  
**作者**: [待填]  
**審核人**: [負責人]  

---

## 變更歷史（Change History）

| 版本 | 日期       | 修改者 | 變更摘要 |
|------|------------|--------|---------|
| v0.1 | YYYY-MM-DD | [姓名] | 初始草稿 |

---

## 1. 目的與範圍（Purpose & Scope）

- 說明本文件如何協助團隊將 OpenSpec 的變更與 image_data_platform 文件管理系統對齊。

---

## 2. OpenSpec 與 Docs 的對應關係（Mapping Between OpenSpec and Docs）

### 2.1 主要對應表

| OpenSpec 元素                    | 對應 Docs 位置                                         |
|----------------------------------|--------------------------------------------------------|
| `openspec/specs/*/spec.md`      | `docs/image_data_platform/requirements/`              |
| `openspec/changes/*/proposal.md`| `docs/image_data_platform/guides/` 或變更說明文件     |
| `openspec/changes/*/tasks.md`   | 開發 / 測試工作項目，可鏈結至 `testing/` 文件         |

---

## 3. 變更流程（Change Workflow）

### 3.1 從 Proposal 到文件更新

1. **建立變更提案**：`openspec/changes/<id>/proposal.md`。  
2. **撰寫 / 更新 specs**：對應 capability 規格更新。  
3. **更新 Docs**：根據 proposal / spec，更新：
   - `requirements/`（需求與設計）
   - `architecture/`（架構）
   - `testing/`（測試策略與報告）
   - `traceability/`（追溯性矩陣）
4. **記錄在 documentation update summary（若有）**。

---

## 4. 追溯性與審核（Traceability & Review）

- 說明如何從 OpenSpec 變更追溯到：
  - 對應需求文件版本
  - 對應架構設計與程式碼
  - 對應測試證據

---

## 5. 實務範例（Practical Examples）

- 範例 1：新增某個功能的 OpenSpec 變更與文件更新流程。  
- 範例 2：修改既有需求時，如何同步更新 traceability 與 testing 文件。

---

## 6. 附錄（Appendix）

- 相關工具命令（例如 `openspec list`、`openspec validate` 等）。  
- 與其他指南（`guides/`）或規範（`regulations/`）之連結。


