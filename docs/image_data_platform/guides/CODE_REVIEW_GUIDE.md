# Code Review 指南

**文件 ID**: GUIDE-CODE-REVIEW-001  
**標題**: 程式碼審查指南 (Code Review Guide)  
**版本**: v1.3.0  
**狀態**: Active  
**建立日期**: 2025-12-22  
**最後更新**: 2025-12-24  

---

## 變更歷史（Change History）

| 版本 | 日期 | 修改者 | 變更摘要 |
|------|------|--------|---------|
| v1.0 | 2025-12-22 | MetaFramework Team | 初始版本，基於 Linus Torvalds 哲學建立 |
| v1.3 | 2025-12-24 | AI Assistant | 整合醫療器材標準 (IEC 62304, ISO 14971) 與資訊安全 (ISO 27001) 要求 |

---

## 1. 概述（Overview）

### 1.1 目的

本文檔提供元框架下的程式碼審查指南，結合 Linus Torvalds 的務實哲學與醫療器材軟體 (SaMD) 的合規性要求。本指南旨在：

- 建立統一的程式碼審查標準，提升程式碼品質與安全性
- 確保程式碼符合 IEC 62304 軟體開發生命週期要求
- 確保風險控制措施 (ISO 14971) 正確落實於代碼中
- 整合資訊安全 (ISO 27001) 的最佳實踐
- 確保程式碼與架構、需求保持 100% 追溯性

### 1.2 適用對象

- **Code Reviewer**：需要審查 Pull Request 的開發人員
- **開發人員**：需要了解審查標準，撰寫符合規範的程式碼
- **專案管理人員**：需要了解程式碼品質標準

### 1.3 核心原則

> "Talk is cheap. Show me the code."

本指南基於 Linus Torvalds 的程式設計哲學，強調：

1. **程式碼勝於空談**：實際的程式碼比討論更重要
2. **資料結構優先**：好的程式設計師關心資料結構和它們的關係
3. **好品味（Good Taste）**：消除特殊情況，讓程式碼簡潔優雅
4. **務實簡潔**：函數要短，程式碼要清晰
5. **直接了當**：程式碼應該自解釋，註解解釋「為什麼」而非「是什麼」

---

## 2. Linus Torvalds 哲學核心原則

### 2.1 第一原則：程式碼勝於空談

**核心價值**：
> "Talk is cheap. Show me the code."

**Code Review 檢查要點**：
- [ ] 審查者應聚焦於實際程式碼，而非設計討論
- [ ] 如果設計有問題，要求提交修正後的程式碼
- [ ] 理論很好，但實際運作更重要

**範例**：

❌ **不好的審查評論**：
```
「這個設計看起來不錯，但我覺得可能有更好的方法...」
```

✅ **好的審查評論**：
```
「這個設計有問題，因為 [具體原因]。建議改為 [具體方案]，請提交修正後的程式碼。」
```

### 2.2 第二原則：資料結構優先

**核心價值**：
> "Bad programmers worry about the code. Good programmers worry about data structures and their relationships."

**Code Review 檢查要點**：
- [ ] 資料結構設計是否合理？
- [ ] 程式碼是否圍繞資料結構組織？
- [ ] 如果程式碼很複雜，是否因為資料結構設計不當？

**範例**：

❌ **不好的設計**：
```python
# 使用多個獨立變數儲存相關資料
user_name = "John"
user_email = "john@example.com"
user_age = 30
user_status = "active"
```

✅ **好的設計**：
```python
# 使用資料結構組織相關資料
from dataclasses import dataclass

@dataclass
class User:
    name: str
    email: str
    age: int
    status: str
```

### 2.3 第三原則：Good Taste（好品味）

**核心價值**：消除特殊情況，讓邊緣案例消失

**Code Review 檢查要點**：
- [ ] 是否有可以消除的特殊情況？
- [ ] 程式碼是否使用 if/else 處理「特殊情況」？
- [ ] 是否可以用不同的角度重構，讓特殊情況變成正常情況？

**範例**：

❌ **不好的程式碼**（有特殊情況）：
```python
def remove_item(items: list, item: str) -> list:
    if len(items) == 0:
        return items
    if items[0] == item:
        return items[1:]
    result = []
    for i, x in enumerate(items):
        if x == item:
            result.extend(items[:i])
            result.extend(items[i+1:])
            break
    return result if result else items
```

✅ **好的程式碼**（消除特殊情況）：
```python
def remove_item(items: list, item: str) -> list:
    return [x for x in items if x != item]
```

### 2.4 第四原則：Spartan（斯巴達式）程式設計

**核心價值**：函數要短，程式碼要簡潔

**Code Review 檢查要點**：
- [ ] 函數是否超過 24 行？（超過應拆分）
- [ ] 程式碼是否超過 3 層縮排？（超過應重構）
- [ ] 變數命名是否適當？（區域變數短，全域變數描述性）

**範例**：

❌ **不好的程式碼**（函數太長）：
```python
def process_gateway_data(gateway_data: dict) -> dict:
    # 50+ 行的函數，包含多個職責
    result = {}
    # ... 大量處理邏輯 ...
    return result
```

✅ **好的程式碼**（函數簡潔）：
```python
def process_gateway_data(gateway_data: dict) -> dict:
    validated = validate_gateway_data(gateway_data)
    normalized = normalize_gateway_data(validated)
    enriched = enrich_gateway_data(normalized)
    return enriched
```

### 2.5 第五原則：直接了當

**核心價值**：程式碼應該自解釋，註解解釋「為什麼」而非「是什麼」

**Code Review 檢查要點**：
- [ ] 程式碼是否需要很多註解才能理解？（如果是，應重寫）
- [ ] 註解是否解釋「為什麼」而非「是什麼」？
- [ ] 是否有使用令人困惑的「聰明」技巧？

**範例**：

❌ **不好的程式碼**（需要註解解釋「是什麼」）：
```python
# 計算總和
total = 0
for i in range(len(items)):
    total = total + items[i]
```

✅ **好的程式碼**（自解釋）：
```python
total = sum(items)
```

❌ **不好的註解**（解釋「是什麼」）：
```python
# 設定 status 為 'active'
status = 'active'
```

✅ **好的註解**（解釋「為什麼」）：
```python
# 設定為 'active' 以觸發自動同步機制
status = 'active'
```

---

## 3. 實戰檢查清單

### 3.1 設計階段檢查

在審查程式碼前，先檢查設計：

- [ ] **資料結構設計**
  - 資料結構是否合理？
  - 是否圍繞資料結構組織程式碼？
  - 如果程式碼很複雜，是否因為資料結構設計不當？

- [ ] **程式碼組織**
  - 這是解決問題的最簡單方式嗎？
  - 是否在解決實際問題還是假想問題？
  - 是否有過度設計？

- [ ] **需求追蹤**
  - 程式碼是否包含需求追蹤註解（`Implements: [REQ-ID]`）？
  - 需求追蹤註解是否正確？
  - 是否與 RTM（需求追溯矩陣）一致？

- [ ] **醫療器材合規性 (Medical Compliance)**
  - 是否實作了對應的風險控制措施 (Risk Control)？
  - Class B/C 模組是否有對應的單元測試？
  - 是否引入了新的 SOUP (Software of Unknown Pedigree)？如果是，是否有相關記錄？

- [ ] **資訊安全 (Information Security)**
  - 是否符合 ISO 27001 的存取控制要求？
  - 是否有敏感資訊硬編碼 (Hard-coded secrets)？
  - 是否對使用者輸入進行了充分的驗證與清理 (Injection prevention)？

### 3.2 品味檢查（Good Taste）

檢查程式碼是否優雅簡潔：

- [ ] **消除特殊情況**
  - 是否有可以消除的特殊情況？
  - 是否可以用不同的角度重構？

- [ ] **縮排深度**
  - 程式碼是否超過 3 層縮排？
  - 超過 3 層應考慮拆分函數

- [ ] **函數長度**
  - 函數是否超過 24 行？
  - 超過 24 行應考慮拆分

- [ ] **函數職責**
  - 函數是否只做一件事？
  - 是否遵循單一職責原則？

### 3.3 可讀性檢查

檢查程式碼是否易於理解：

- [ ] **變數命名**
  - 區域變數是否簡短但清楚（`i`, `j`, `tmp`）？
  - 全域變數和函數是否有描述性名稱？
  - 是否遵循 Python 命名規範（snake_case、PascalCase、UPPER_CASE）？

- [ ] **註解使用**
  - 程式碼是否需要很多註解才能理解？
  - 註解是否解釋「為什麼」而非「是什麼」？
  - 是否有不必要的註解？

- [ ] **程式碼清晰度**
  - 隨機的程式設計師能立即看懂這段程式碼嗎？
  - 是否有使用令人困惑的「聰明」技巧？
  - 是否清楚比簡短更重要？

---

## 4. Python PEP8 程式碼風格與註解規範

### 4.1 命名規範

**檢查要點**：
- [ ] 函數、變數、模組名稱使用 `snake_case`
- [ ] 類別名稱使用 `PascalCase`
- [ ] 常數使用 `UPPER_CASE`
- [ ] 私有變數使用單底線前綴（`_private_var`）
- [ ] 避免使用雙底線前綴（除非特殊情況如 `__init__`）

**範例**：

✅ **正確**：
```python
# 函數和變數
def get_gateway_info(gateway_id: int) -> dict:
    gateway_data = fetch_gateway_data(gateway_id)
    return gateway_data

# 類別
class GatewayService:
    pass

# 常數
MAX_RETRY_COUNT = 3
DEFAULT_TIMEOUT = 30

# 私有變數
class GatewayService:
    def __init__(self):
        self._cache = {}
```

❌ **錯誤**：
```python
# 函數使用 PascalCase（錯誤）
def GetGatewayInfo(gateway_id: int):
    pass

# 變數使用 camelCase（錯誤）
gatewayData = fetch_gateway_data(gateway_id)

# 常數使用小寫（錯誤）
max_retry_count = 3
```

### 4.2 縮排與空白

**檢查要點**：
- [ ] 使用 4 個空格縮排（不使用 Tab）
- [ ] 行長度限制 79 字元（註解與文檔字串 72 字元）
- [ ] 運算符周圍使用空白
- [ ] 逗號後使用空白
- [ ] 函數定義與類別定義之間空兩行
- [ ] 類別方法之間空一行

**範例**：

✅ **正確**：
```python
def calculate_total(items: list[int]) -> int:
    total = 0
    for item in items:
        total += item
    return total


class GatewayService:
    def __init__(self):
        self._cache = {}
    
    def get_gateway(self, gateway_id: int) -> dict:
        return self._cache.get(gateway_id)
```

❌ **錯誤**：
```python
# 使用 Tab 縮排（錯誤）
def calculate_total(items:list[int])->int:  # 運算符周圍缺少空白
    total=0  # 運算符周圍缺少空白
    for item in items:
        total+=item
    return total
```

### 4.3 匯入順序

**檢查要點**：
- [ ] 標準庫匯入
- [ ] 第三方庫匯入
- [ ] 本地應用/庫匯入
- [ ] 每組之間空一行
- [ ] 每個匯入語句一行
- [ ] 使用 `from` 匯入時，按字母順序排列

**範例**：

✅ **正確**：
```python
# 標準庫
import json
from typing import Dict, List, Optional

# 第三方庫
from fastapi import APIRouter, Request
from pydantic import BaseModel

# 本地應用
from dap.gateway.service import GatewayService
from dap.gateway.api_schema import GatewayRequest
```

❌ **錯誤**：
```python
# 匯入順序混亂（錯誤）
from dap.gateway.service import GatewayService
import json
from fastapi import APIRouter
from typing import Dict
```

### 4.4 註解與 Docstring 格式

**檢查要點**：
- [ ] 使用 docstring（三引號字串）描述模組、類別、函數
- [ ] 遵循 PEP 257 docstring 慣例
- [ ] **統一使用 Google 風格的 docstring**（專案標準）
- [ ] 註解解釋「為什麼」而非「是什麼」
- [ ] 不在行尾加註解（除非簡短且必要）
- [ ] **包含需求追溯、設計參考、合規性參考**（如適用）

**Google 風格 Docstring 格式**：

```python
def function_name(param1: type, param2: type) -> return_type:
    """函數簡短描述（一行）
    
    函數詳細描述（可多行，說明函數的目的、行為、使用場景等）
    
    Requirement Traceability:
        - REQ-ID: 需求描述
        - Related: 相關需求 ID
    
    Design Reference:
        - docs/dap/design/XX_DESIGN.md: 設計決策說明
    
    Compliance Reference:
        - docs/meta-framework/regulations/00_REGULATIONS_INDEX.md: 合規性索引參考
    
    Args:
        param1: 參數1的描述
        param2: 參數2的描述
        
    Returns:
        返回值的描述
        
    Raises:
        ValueError: 當參數無效時
        ConnectionError: 當連線失敗時
        
    Example:
        >>> result = function_name(1, "test")
        >>> print(result)
        {'status': 'success'}
    """
    pass
```

**範例**：

✅ **正確**（Google 風格 docstring，包含需求追溯）：
```python
def get_gateway_info(gateway_id: int) -> dict:
    """取得閘道器資訊
    
    從資料庫或快取中取得指定閘道器的完整資訊，包含狀態、版本、關聯工廠等。
    優先從快取取得資料，避免重複查詢資料庫。
    
    Requirement Traceability:
        - GWMGMT-FR-003: 閘道器資訊查詢
        - Related: GWMGMT-FR-001, GWMGMT-FR-002
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.2: 資料快取策略
    
    Args:
        gateway_id: 閘道器 ID（必須 > 0）
        
    Returns:
        包含閘道器資訊的字典，格式：
        {
            'id': int,
            'name': str,
            'status': str,
            'factory_id': int,
            ...
        }
        
    Raises:
        ValueError: 當 gateway_id <= 0 時
        NotFoundError: 當閘道器不存在時
        
    Example:
        >>> gateway = get_gateway_info(1)
        >>> print(gateway['name'])
        'Gateway-001'
    """
    if gateway_id <= 0:
        raise ValueError("Invalid gateway_id")
    # 從快取取得資料，避免重複查詢資料庫
    return fetch_from_cache(gateway_id)
```

✅ **正確**（類別 docstring，包含需求追溯與設計參考）：
```python
class GatewayService:
    """閘道器服務類別
    
    提供閘道器管理的業務邏輯實作，包含註冊、狀態管理、與工廠關聯等功能。
    遵循分層架構原則，僅處理業務邏輯，不直接操作資料庫。
    
    Requirement Traceability:
        - GWMGMT-FR-001: 閘道器註冊
        - GWMGMT-FR-002: 閘道器狀態管理
        - GWMGMT-FR-007: 閘道器與工廠關聯
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 2.1: Service 層設計
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.1: 資料庫設計
    
    Compliance Reference:
        - docs/meta-framework/regulations/00_REGULATIONS_INDEX.md § 2.3: 需求追溯性管理
    """
    
    def __init__(self, crud: AnalysisCRUD):
        """初始化分析服務
        
        Args:
            crud: 分析 CRUD 層實例（依賴注入）
        """
        self._crud = crud
    
    def register_analysis(self, serial_number: str) -> Analysis:
        """註冊新分析任務
        
        當分析任務啟動時自動註冊，建立新的分析記錄並設定初始狀態。
        
        Requirement Traceability:
            - ANLYS-FR-001: 分析任務註冊
        
        Design Reference:
            - docs/brain-cmb/architecture/00_ARCHITECTURE_INDEX.md: 自動註冊流程
        
        Args:
            serial_number: 分析任務序號（唯一識別碼）
            
        Returns:
            Analysis: 已註冊的分析物件
            
        Raises:
            DuplicateError: 當序號已存在時
        """
        pass
```

✅ **正確**（模組 docstring，包含需求追溯）：
```python
"""分析管理模組

提供分析任務管理的完整功能，包含註冊、狀態追蹤等。

Requirement Traceability:
    - ANLYS-SR-001: 即時掌握分析狀態
    - ANLYS-FR-001 ~ ANLYS-FR-009: 功能需求

Design Reference:
    - docs/brain-cmb/architecture/00_ARCHITECTURE_INDEX.md: 分析管理設計
    
Compliance Reference:
    - docs/meta-framework/regulations/00_REGULATIONS_INDEX.md: 合規性要求
"""

from typing import Optional
from fastapi import APIRouter
```

❌ **錯誤**（缺少 docstring）：
```python
# 缺少 docstring（錯誤）
def get_gateway_info(gateway_id: int) -> dict:
    if gateway_id <= 0:
        raise ValueError("Invalid gateway_id")
    return fetch_from_cache(gateway_id)
```

❌ **錯誤**（註解解釋「是什麼」而非「為什麼」）：
```python
def get_gateway_info(gateway_id: int) -> dict:
    # 取得閘道器資訊（錯誤：解釋「是什麼」）
    if gateway_id <= 0:
        raise ValueError("Invalid gateway_id")
    return fetch_from_cache(gateway_id)
```

❌ **錯誤**（缺少需求追溯）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Args:
        serial_number: 閘道器序號
        
    Returns:
        Gateway: 已註冊的閘道器物件
    """
    # 錯誤：缺少 Requirement Traceability
    pass
```

**需求追溯格式說明**：

- **Requirement Traceability**：列出實作的需求 ID
  - 主要需求使用 `- REQ-ID: 需求描述`
  - 相關需求使用 `- Related: REQ-ID1, REQ-ID2`
- **Design Reference**：引用相關設計文檔
  - 格式：`- docs/[project]/architecture/XX_INDEX.md: 設計決策說明`
- **Compliance Reference**：引用合規性文檔（如適用）
  - 格式：`- docs/meta-framework/regulations/XX-compliance-mapping-template.md: 合規性要求`

### 4.5 程式碼組織

**檢查要點**：
- [ ] 模組層級常數定義在檔案頂部
- [ ] 類別定義在函數之前
- [ ] 主程式碼放在 `if __name__ == "__main__":` 區塊

**範例**：

✅ **正確**：
```python
"""Gateway service module."""

# 模組層級常數
DEFAULT_TIMEOUT = 30
MAX_RETRY_COUNT = 3

# 類別定義
class GatewayService:
    def __init__(self):
        self._cache = {}
    
    def get_gateway(self, gateway_id: int) -> dict:
        return self._cache.get(gateway_id)

# 函數定義
def create_gateway_service() -> GatewayService:
    return GatewayService()

# 主程式碼
if __name__ == "__main__":
    service = create_gateway_service()
    print(service.get_gateway(1))
```

---

## 5. Python 最佳實踐

### 5.1 Pythonic 慣用法

**檢查要點**：
- [ ] 使用列表推導式（list comprehension）而非迴圈
- [ ] 使用生成器（generator）處理大量資料
- [ ] 使用 `enumerate()` 而非手動計數
- [ ] 使用 `zip()` 同時迭代多個序列
- [ ] 使用 `with` 語句管理資源（檔案、資料庫連線）

**範例**：

✅ **正確**（Pythonic）：
```python
# 列表推導式
squares = [x**2 for x in range(10)]

# 生成器
def read_large_file(file_path: str):
    with open(file_path) as f:
        for line in f:
            yield line.strip()

# enumerate
for index, item in enumerate(items):
    print(f"{index}: {item}")

# zip
for name, age in zip(names, ages):
    print(f"{name} is {age} years old")

# with 語句
with open('data.txt') as f:
    data = f.read()
```

❌ **錯誤**（非 Pythonic）：
```python
# 使用迴圈而非列表推導式
squares = []
for x in range(10):
    squares.append(x**2)

# 手動計數而非 enumerate
index = 0
for item in items:
    print(f"{index}: {item}")
    index += 1

# 不使用 with 語句
f = open('data.txt')
data = f.read()
f.close()  # 可能忘記關閉檔案
```

### 5.2 型別標註（Type Hints）

**檢查要點**：
- [ ] 函數參數與返回值必須使用 Type Hints
- [ ] 使用 `typing` 模組的型別（`List`, `Dict`, `Optional`, `Union`）
- [ ] 複雜型別使用 `TypedDict` 或 `dataclass`
- [ ] 避免使用 `Any`（除非必要）

**範例**：

✅ **正確**：
```python
from typing import List, Dict, Optional, Union
from dataclasses import dataclass

@dataclass
class Gateway:
    id: int
    name: str
    status: str

def get_gateways(
    status: Optional[str] = None,
    limit: int = 10
) -> List[Gateway]:
    """取得閘道器列表"""
    pass

def process_data(
    data: Union[str, int]
) -> Dict[str, int]:
    """處理資料"""
    pass
```

❌ **錯誤**：
```python
# 缺少 Type Hints（錯誤）
def get_gateways(status=None, limit=10):
    pass

# 使用 Any（應避免）
from typing import Any

def process_data(data: Any) -> Any:
    pass
```

### 5.3 錯誤處理

**檢查要點**：
- [ ] 使用具體的例外類別而非 `Exception`
- [ ] 遵循「請求寬恕而非許可」（EAFP）原則
- [ ] 適當使用 `try-except-else-finally`
- [ ] 記錄例外資訊（使用 `logging` 而非 `print`）

**範例**：

✅ **正確**：
```python
import logging

logger = logging.getLogger(__name__)

def get_gateway(gateway_id: int) -> dict:
    """取得閘道器資訊"""
    try:
        gateway = fetch_from_database(gateway_id)
    except ValueError as e:
        logger.error(f"Invalid gateway_id: {gateway_id}", exc_info=True)
        raise
    except ConnectionError as e:
        logger.error("Database connection failed", exc_info=True)
        raise
    else:
        logger.info(f"Successfully fetched gateway {gateway_id}")
        return gateway
    finally:
        cleanup_resources()
```

❌ **錯誤**：
```python
# 使用 Exception（太寬泛）
def get_gateway(gateway_id: int) -> dict:
    try:
        gateway = fetch_from_database(gateway_id)
    except Exception:  # 錯誤：太寬泛
        pass

# 使用 print 而非 logging
def get_gateway(gateway_id: int) -> dict:
    try:
        gateway = fetch_from_database(gateway_id)
    except ValueError as e:
        print(f"Error: {e}")  # 錯誤：應使用 logging
        raise

# 違反 EAFP 原則
def get_gateway(gateway_id: int) -> dict:
    if gateway_id not in valid_ids:  # 錯誤：先檢查許可
        raise ValueError("Invalid gateway_id")
    return fetch_from_database(gateway_id)
```

### 5.4 效能考量

**檢查要點**：
- [ ] 避免不必要的資料複製
- [ ] 使用 `collections` 模組的資料結構（`defaultdict`, `Counter`）
- [ ] 避免全域變數，使用依賴注入
- [ ] 適當使用快取（`functools.lru_cache`）

**範例**：

✅ **正確**：
```python
from collections import defaultdict, Counter
from functools import lru_cache

# 使用 defaultdict
gateway_counts = defaultdict(int)
for gateway in gateways:
    gateway_counts[gateway.status] += 1

# 使用 Counter
status_counts = Counter(gateway.status for gateway in gateways)

# 使用 lru_cache
@lru_cache(maxsize=128)
def expensive_calculation(n: int) -> int:
    # 複雜計算
    pass

# 依賴注入而非全域變數
class GatewayService:
    def __init__(self, db_connection):
        self._db = db_connection
```

❌ **錯誤**：
```python
# 不必要的資料複製
def process_items(items: list) -> list:
    result = []
    for item in items:
        result.append(item.copy())  # 錯誤：不必要的複製
    return result

# 使用全域變數
db_connection = None  # 錯誤：應使用依賴注入

def get_gateway(gateway_id: int) -> dict:
    global db_connection
    return db_connection.query(gateway_id)
```

---

## 6. 反模式警告

以下行為違反 Linus 哲學與 Python 最佳實踐：

### 6.1 🚫 光說不練

**反模式**：
- 討論設計幾週而不寫任何程式碼
- 批評別人的程式碼但不提交修正
- 理論完美但從未實作

**Code Review 建議**：
- 如果設計有問題，要求提交修正後的程式碼
- 不要接受「我會改」的承諾，要求實際的程式碼

### 6.2 🚫 過度設計

**反模式**：
- 為假想的未來需求添加抽象層
- 試圖一次設計出完美系統
- 讓架構比問題更複雜

**Code Review 建議**：
- 檢查是否在解決實際問題還是假想問題
- 要求簡化設計，移除不必要的抽象層

### 6.3 🚫 犧牲可讀性

**反模式**：
- 使用「聰明」的技巧來炫技
- 寫超長的函數
- 深層巢狀結構

**Code Review 建議**：
- 要求拆分長函數
- 要求重構深層巢狀結構
- 要求使用更清晰的寫法

### 6.4 🚫 忽視資料結構

**反模式**：
- 先寫程式碼再考慮資料
- 用複雜的程式碼彌補錯誤的資料設計
- 關心演算法多於關心資料

**Code Review 建議**：
- 如果程式碼很複雜，檢查資料結構設計
- 要求重新設計資料結構

### 6.5 🚫 違反 PEP8 規範

**反模式**：
- 使用 Tab 而非空格
- 行長度超過 79 字元
- 匯入順序混亂
- 缺少 docstring

**Code Review 建議**：
- 要求修正所有 PEP8 違規
- 使用自動化工具（如 `black`, `flake8`）檢查

### 6.6 🚫 非 Pythonic 寫法

**反模式**：
- 使用迴圈而非列表推導式
- 不使用 `with` 語句管理資源
- 缺少 Type Hints
- 使用 `print` 而非 `logging`

**Code Review 建議**：
- 要求使用 Pythonic 寫法
- 要求添加 Type Hints
- 要求使用 `logging` 而非 `print`

---

## 7. 專案特定要點

### 7.1 Web 框架與路由設計 (以 FastAPI 為例)

**檢查要點**：
- [ ] 路由函數應簡潔，業務邏輯放在 Service 層
- [ ] 使用 Pydantic 模型進行請求/響應驗證
- [ ] 適當使用依賴注入（`Depends`）
- [ ] 錯誤處理使用 HTTPException

**範例**：

✅ **正確**：
```python
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from brain_cmb.core.service import AnalysisService
from brain_cmb.core.schema import AnalysisRequest

analysis_router = APIRouter(tags=['analysis'], prefix='/analysis')

@analysis_router.get("/{analysis_id}")
async def get_analysis(
    analysis_id: int,
    service: AnalysisService = Depends(get_analysis_service)
) -> dict:
    """取得分析資訊"""
    analysis = await service.get_analysis(analysis_id)
    if not analysis:
        raise HTTPException(
            status_code=404,
            detail=f"Analysis {analysis_id} not found"
        )
    return analysis
```

❌ **錯誤**：
```python
# 業務邏輯放在 Controller（錯誤）
@gateway_bp.get("/{gateway_id}")
async def get_gateway(gateway_id: int) -> dict:
    # 錯誤：業務邏輯應該在 Service 層
    db = get_database_connection()
    gateway = db.query("SELECT * FROM gateways WHERE id = ?", gateway_id)
    if not gateway:
        return {"error": "Not found"}
    return gateway
```

### 7.2 分層架構檢查

**檢查要點**：
- [ ] Controller 層：僅處理 HTTP 請求/響應
- [ ] Service 層：業務邏輯實作
- [ ] CRUD 層：資料庫操作
- [ ] Models 層：資料模型定義
- [ ] 避免跨層直接呼叫（如 Controller 直接呼叫 CRUD）

**架構圖**：
```
Controller (HTTP 請求/響應)
    ↓
Service (業務邏輯)
    ↓
CRUD (資料庫操作)
    ↓
Models (資料模型)
```

**範例**：

✅ **正確**（分層清晰）：
```python
# Controller
@gateway_bp.get("/{gateway_id}")
async def get_gateway(
    gateway_id: int,
    service: GatewayService = Depends(get_gateway_service)
) -> dict:
    return await service.get_gateway(gateway_id)

# Service
class GatewayService:
    def __init__(self, crud: GatewayCRUD):
        self._crud = crud
    
    async def get_gateway(self, gateway_id: int) -> dict:
        return await self._crud.get_by_id(gateway_id)

# CRUD
class GatewayCRUD:
    async def get_by_id(self, gateway_id: int) -> dict:
        # 資料庫操作
        pass
```

❌ **錯誤**（跨層呼叫）：
```python
# Controller 直接呼叫 CRUD（錯誤）
@gateway_bp.get("/{gateway_id}")
async def get_gateway(gateway_id: int) -> dict:
    crud = GatewayCRUD()  # 錯誤：應透過 Service 層
    return await crud.get_by_id(gateway_id)
```

### 7.3 非同步處理

**檢查要點**：
- [ ] 適當使用 `async/await`（I/O 操作）
- [ ] Celery 任務應為純函數或易於測試
- [ ] 避免阻塞事件迴圈

**範例**：

✅ **正確**：
```python
# FastAPI 路由使用 async
@gateway_bp.get("/{gateway_id}")
async def get_gateway(gateway_id: int) -> dict:
    # I/O 操作使用 await
    gateway = await service.get_gateway(gateway_id)
    return gateway

# Celery 任務為純函數
@celery_app.task
def process_gateway_data(gateway_id: int) -> dict:
    """處理閘道器資料（純函數，易於測試）"""
    data = fetch_gateway_data(gateway_id)
    return process_data(data)
```

❌ **錯誤**：
```python
# 阻塞事件迴圈（錯誤）
@gateway_bp.get("/{gateway_id}")
async def get_gateway(gateway_id: int) -> dict:
    import time
    time.sleep(5)  # 錯誤：阻塞事件迴圈
    return {"id": gateway_id}

# Celery 任務包含複雜狀態（錯誤）
@celery_app.task
def process_gateway_data(gateway_id: int) -> dict:
    global cache  # 錯誤：使用全域變數
    cache[gateway_id] = fetch_gateway_data(gateway_id)
    return process_data(cache[gateway_id])
```

### 7.4 需求追蹤檢查

**檢查要點**：
- [ ] 程式碼是否包含需求追蹤註解（在 docstring 中使用 `Requirement Traceability`）？
- [ ] 需求追蹤註解是否正確？
- [ ] 是否包含設計參考（`Design Reference`）？
- [ ] 是否包含合規性參考（`Compliance Reference`，如適用）？
- [ ] 是否與 RTM（需求追溯矩陣）一致？
- [ ] 是否與需求文檔（`docs/dap/requirements/`）一致？
- [ ] 是否與設計文檔（`docs/dap/design/`）一致？

**範例**：

✅ **正確**（完整的 Google 風格 docstring，包含需求追溯、設計參考、合規性參考）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    當閘道器發送第一次心跳時自動註冊，建立新的閘道器記錄並設定初始狀態為 'online'。
    
    Requirement Traceability:
        - GWMGMT-FR-001: 閘道器註冊
        - Related: GWMGMT-FR-002, GWMGMT-NFR-001
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.3: 自動註冊流程
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.1: 資料庫設計（gateways 表）
    
    Compliance Reference:
        - docs/dap/regulations/ISO-29148-compliance.md § 2.3: 需求追溯性管理
    
    Args:
        serial_number: 閘道器序號（唯一識別碼，格式：GW-XXXXXX）
        
    Returns:
        Gateway: 已註冊的閘道器物件，包含 id、name、status 等屬性
        
    Raises:
        DuplicateError: 當序號已存在時
        ValueError: 當序號格式無效時
        
    Example:
        >>> gateway = register_gateway("GW-001234")
        >>> print(gateway.status)
        'online'
    """
    # 實作...
    pass
```

✅ **正確**（使用行內註解 + docstring，符合現有程式碼風格）：
```python
# Implements: GWMGMT-FR-007
# Related: GWMGMT-FR-001, GWMGMT-FR-002
async def process_bind_gateway(request: GatewayBindRequest):
    """將閘道器綁定至工廠
    
    將指定的閘道器與工廠建立關聯關係，更新資料庫中的 factory_id 欄位。
    綁定前會檢查閘道器是否存在且狀態正常。
    
    Requirement Traceability:
        - GWMGMT-FR-007: 閘道器與工廠關聯
        - GWMGMT-FR-001: 閘道器註冊（檢查閘道器是否存在）
        - GWMGMT-FR-002: 閘道器狀態管理（檢查狀態是否正常）
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.4: 閘道器與工廠關聯設計
    
    Args:
        request: GatewayBindRequest 包含 factory_id 與 gateway_id
        
    Returns:
        HTTPResponse: 綁定結果，包含成功訊息或錯誤訊息
    """
    # 實作...
    pass
```

❌ **錯誤**（缺少需求追蹤）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Args:
        serial_number: 閘道器序號
        
    Returns:
        Gateway: 已註冊的閘道器物件
    """
    # 錯誤：缺少 Requirement Traceability
    pass
```

❌ **錯誤**（缺少設計參考）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Requirement Traceability:
        - GWMGMT-FR-001: 閘道器註冊
    
    Args:
        serial_number: 閘道器序號
        
    Returns:
        Gateway: 已註冊的閘道器物件
    """
    # 錯誤：缺少 Design Reference
    pass
```

**檢查清單**：

在 Code Review 時，檢查 docstring 是否包含：

1. **Requirement Traceability**（必須）
   - 列出實作的主要需求 ID
   - 列出相關需求 ID（如適用）

2. **Design Reference**（建議）
   - 引用相關設計文檔
   - 說明設計決策的位置

3. **Compliance Reference**（如適用）
   - 引用合規性文檔
   - 說明合規性要求的位置

4. **文檔一致性**
   - 需求 ID 是否與 `docs/dap/requirements/RTM.md` 一致？
   - 設計參考是否與 `docs/dap/design/` 文檔一致？
   - 合規性參考是否與 `docs/dap/regulations/` 文檔一致？

---

## 8. 審查流程與最佳實踐

### 8.1 Code Review 流程

1. **收到 Pull Request**
   - 檢查 PR 描述是否清楚說明變更內容
   - 檢查是否關聯相關需求 ID

2. **初步檢查**
   - 檢查程式碼是否符合 PEP8 規範
   - 檢查是否有明顯的錯誤或安全問題

3. **深入審查**
   - 使用本指南的檢查清單逐項檢查
   - 檢查設計是否符合 Linus 哲學
   - 檢查是否符合 XX 專案規範

4. **提供反饋**
   - 明確指出問題與建議
   - 提供具體的修正建議
   - 要求提交修正後的程式碼

5. **驗證修正**
   - 檢查修正後的程式碼是否解決問題
   - 確認所有檢查項目都通過

### 8.2 審查評論最佳實踐

**好的審查評論**：
- ✅ 明確指出問題與原因
- ✅ 提供具體的修正建議
- ✅ 引用相關規範或最佳實踐
- ✅ 要求提交修正後的程式碼

**不好的審查評論**：
- ❌ 僅說「這個不好」而不說明原因
- ❌ 僅提供理論建議而不要求實際程式碼
- ❌ 過於嚴苛或個人化

**範例**：

✅ **好的審查評論**：
```
這個函數超過 50 行，違反 Linus 哲學的「函數要短」原則。
建議拆分為以下函數：
1. validate_gateway_data() - 驗證資料
2. normalize_gateway_data() - 正規化資料
3. save_gateway_data() - 儲存資料

請提交修正後的程式碼。
```

❌ **不好的審查評論**：
```
這個函數太長了。
```

### 8.3 審查優先順序

1. **Critical（關鍵）**：安全問題、資料遺失風險、嚴重錯誤
2. **High（高）**：違反核心原則、影響效能、破壞架構
3. **Medium（中）**：違反 PEP8、非 Pythonic、可讀性問題
4. **Low（低）**：風格問題、註解建議、優化建議

### 8.4 審查檢查清單摘要

**快速檢查清單**（每次 Code Review 必檢）：

- [ ] 資料結構設計是否合理？
- [ ] 是否有可以消除的特殊情況？
- [ ] 函數是否超過 24 行？
- [ ] 程式碼是否超過 3 層縮排？
- [ ] 是否符合 PEP8 規範？
- [ ] 是否使用 Type Hints？
- [ ] **Docstring 是否使用 Google 風格？**
- [ ] **Docstring 是否包含 Requirement Traceability？**
- [ ] **Docstring 是否包含 Design Reference？**
- [ ] **Docstring 是否包含 Compliance Reference（如適用）？**
- [ ] 是否符合 XX 分層架構？
- [ ] 錯誤處理是否適當？
- [ ] 是否使用 `logging` 而非 `print`？

**文檔一致性檢查**（實作核心功能時必檢）：

- [ ] **需求追蹤檢查**
  - [ ] 程式碼中的 `Requirement Traceability` 註解是否包含需求 ID？
  - [ ] 需求 ID 是否在對應的需求文檔（`docs/dap/requirements/`）中存在？
  - [ ] 需求 ID 是否在 RTM（`docs/dap/requirements/RTM.md`）中存在？
  - [ ] RTM 中的實作檔案路徑是否與實際程式碼位置一致？
  - [ ] 需求狀態是否為 "Implemented" 或 "In Progress"？

- [ ] **設計一致性檢查**
  - [ ] 程式碼中的 `Design Reference` 註解是否指向有效的設計文檔？
  - [ ] 設計文檔路徑是否存在（如 `docs/dap/design/02_GATEWAY_DESIGN.md`）？
  - [ ] 設計文檔中的章節是否存在（如 `§ 3.3: 自動註冊流程`）？
  - [ ] 程式碼實作是否符合設計決策？
  - [ ] 分層架構是否正確（Controller → Service → CRUD → Models）？

- [ ] **合規性檢查**（如適用）
  - [ ] 程式碼中的 `Compliance Reference` 註解是否指向有效的法規文檔？
  - [ ] 法規文檔路徑是否存在（如 `docs/dap/regulations/ISO-29148-compliance.md`）？
  - [ ] 法規文檔中的章節是否存在（如 `§ 2.3: 需求追溯性管理`）？
  - [ ] 程式碼是否符合合規性要求？

**SR、SD、程式碼三層審查**（新增需求或重大設計變更時必檢）：

- [ ] **SR 文檔審查**
  - [ ] **完整性檢查**
    - [ ] 所有需求都有明確的描述（需求標題、需求描述、業務價值）
    - [ ] 每個需求都有至少一個 Scenario（使用 Given-When-Then 格式）
    - [ ] 每個需求都標註驗證方法（Test/Inspection/Analysis/Demo）
    - [ ] 需求描述使用 RFC 2119 關鍵字（SHALL/MUST/SHOULD/MAY）
  - [ ] **可驗證性檢查**
    - [ ] Scenario 使用正確的格式（`#### Scenario:` 標題，GIVEN/WHEN/THEN/AND 關鍵字）
    - [ ] Scenario 描述清晰，可被測試驗證
  - [ ] **可追溯性檢查**
    - [ ] 每個需求都標註 Traces to（追溯到上層需求）
    - [ ] 每個需求都標註 Traced by（被下層設計/實作追溯）
    - [ ] 追溯關係中的需求 ID 是否存在（在對應文檔中查找）
    - [ ] 追溯關係是否完整（無斷鏈）
  - [ ] **ISO 29148 合規性檢查**
    - [ ] 需求格式是否符合 ISO/IEC/IEEE 29148 標準（需求標題、需求描述、驗證方法）
    - [ ] 需求關鍵字是否正確使用（SHALL/MUST/SHOULD/MAY，保持英文大寫）
    - [ ] 文檔結構是否完整（Stakeholder Requirements、Requirements、Scenarios 三個主要區段）
    - [ ] 需求 ID 格式是否正確（`[CAPABILITY]-[TYPE]-[NUMBER]`）

- [ ] **SD 文檔審查**
  - [ ] **設計決策檢查**
    - [ ] 設計決策是否明確（設計決策的內容、理由、影響）
    - [ ] 設計決策是否有理由說明（為什麼選擇這個設計）
    - [ ] 設計決策是否考慮了替代方案（是否有說明其他選項）
    - [ ] 設計決策是否標註了追溯關係（Traces to 對應的需求 ID）
  - [ ] **架構一致性檢查**
    - [ ] SD 文檔是否符合系統架構設計（是否符合 `01_SYSTEM_ARCHITECTURE.md` 中的架構原則）
    - [ ] 分層架構是否正確（Controller → Service → CRUD → Models）
    - [ ] 介面定義是否一致（API 端點、資料格式、錯誤處理）
    - [ ] 技術選型是否合理（是否符合系統架構設計中的技術選型）
  - [ ] **實作可行性檢查**
    - [ ] 設計決策是否可實作（技術選型是否合理、是否有技術限制）
    - [ ] 設計決策是否考慮了實作複雜度（是否過於複雜或過於簡單）
    - [ ] 設計決策是否考慮了效能與擴展性（是否滿足非功能需求）
    - [ ] 設計決策是否標註了實作檔案路徑（Traced by 對應的程式碼檔案）

- [ ] **三層一致性檢查**
  - [ ] **SR → SD 一致性檢查**
    - [ ] SD 文檔中的 Traces to 是否指向有效的 SR 需求 ID
    - [ ] SD 文檔的設計決策是否滿足 SR 需求（設計是否實現了需求目標）
    - [ ] 追溯關係是否完整（SR 需求是否都有對應的 SD 設計）
  - [ ] **SD → 程式碼一致性檢查**
    - [ ] 程式碼中的 Design Reference 是否指向有效的 SD 文檔
    - [ ] 程式碼是否符合 SD 文檔中的架構設計（分層架構、介面定義、資料結構）
    - [ ] 程式碼中的實作是否與 SD 文檔中的設計決策一致
  - [ ] **完整追溯鏈檢查**
    - [ ] 追溯鏈的完整性（SR 需求 → SD 設計 → 程式碼實作是否都有對應關係）
    - [ ] 追溯鏈的一致性（三層之間的描述是否一致、是否有矛盾）
    - [ ] RTM 是否正確記錄三層追溯關係

---

## 11. 參考文檔進行 Code Review

### 11.1 概述

Code Review 不僅要檢查程式碼品質，還需要驗證程式碼與文檔的一致性。本節說明如何參考 requirements、regulations、design 文檔進行審查，確保程式碼實作符合需求、法規與設計決策。

**Requirement Traceability**:
- REQMGMT-FR-012: Code Review 與文檔整合

**Design Reference**:
- docs/dap/design/01_SYSTEM_ARCHITECTURE.md: 系統架構設計

**Compliance Reference**:
- docs/dap/regulations/ISO-29148-compliance.md § 2.3: 需求追溯性管理

### 11.2 參考需求文檔進行審查

#### 11.2.1 查閱需求文檔

需求文檔位於 `docs/dap/requirements/`，包含：
- **系統層需求**：`01_SYSTEM_PRD_SR_SD.md`（產品需求、利害關係人需求、系統需求）
- **子系統需求**：`02_GATEWAY_MANAGEMENT.md`、`03_FACTORY_MANAGEMENT.md` 等
- **需求追溯矩陣**：`RTM.md`（記錄需求與實作、測試的對應關係）

**如何查閱**：
1. 根據程式碼中的 `Requirement Traceability` 註解，找到對應的需求 ID（如 `GWMGMT-FR-001`）
2. 在對應的子系統需求文檔中查找該需求（如 `02_GATEWAY_MANAGEMENT.md`）
3. 在 RTM 中驗證需求狀態與實作檔案路徑

#### 11.2.2 驗證需求追蹤註解

**檢查要點**：
- [ ] 程式碼中的 `Requirement Traceability` 註解是否包含需求 ID？
- [ ] 需求 ID 是否在對應的需求文檔中存在？
- [ ] 需求 ID 是否在 RTM（`docs/dap/requirements/RTM.md`）中存在？
- [ ] RTM 中的實作檔案路徑是否與實際程式碼位置一致？
- [ ] 需求狀態是否為 "Implemented" 或 "In Progress"？

**範例**：

✅ **正確**（需求追蹤註解與文檔一致）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Requirement Traceability:
        - GWMGMT-FR-001: 閘道器註冊
        - Related: GWMGMT-FR-002, GWMGMT-NFR-001
    
    Args:
        serial_number: 閘道器序號
        
    Returns:
        Gateway: 已註冊的閘道器物件
    """
    # 實作...
    pass
```

**驗證步驟**：
1. 檢查 `docs/dap/requirements/02_GATEWAY_MANAGEMENT.md` 中是否存在 `GWMGMT-FR-001`
2. 檢查 `docs/dap/requirements/RTM.md` 中 `GWMGMT-FR-001` 的實作檔案是否為當前檔案
3. 檢查需求狀態是否正確

❌ **錯誤**（需求 ID 不存在於文檔中）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Requirement Traceability:
        - GWMGMT-FR-999: 閘道器註冊  # 錯誤：需求 ID 不存在
    """
    # 實作...
    pass
```

#### 11.2.3 驗證需求狀態

需求狀態應符合以下規則：
- **Draft/Proposed**：需求尚未實作，程式碼不應包含此需求的實作
- **Approved**：需求已批准，程式碼可以開始實作
- **In Progress**：需求實作中，程式碼應包含此需求的實作
- **Implemented**：需求已實作完成，程式碼應包含完整的實作
- **Verified**：需求已測試驗證，程式碼應包含測試案例

### 11.3 參考法規文檔進行審查

#### 11.3.1 查閱法規文檔

法規文檔位於 `docs/dap/regulations/`，包含：
- **ISO 29148 合規性**：`ISO-29148-compliance.md`（需求工程標準合規性對照）
- **法規索引**：`00_REGULATIONS_INDEX.md`

**如何查閱**：
1. 根據程式碼中的 `Compliance Reference` 註解，找到對應的法規文檔路徑
2. 在法規文檔中查找對應的章節（如 `§ 2.3: 需求追溯性管理`）
3. 驗證程式碼是否符合合規性要求

#### 11.3.2 驗證合規性參考

**檢查要點**：
- [ ] 程式碼中的 `Compliance Reference` 註解是否指向有效的法規文檔？
- [ ] 法規文檔路徑是否存在（如 `docs/dap/regulations/ISO-29148-compliance.md`）？
- [ ] 法規文檔中的章節是否存在（如 `§ 2.3: 需求追溯性管理`）？
- [ ] 程式碼是否符合合規性要求？

**範例**：

✅ **正確**（合規性參考與文檔一致）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Compliance Reference:
        - docs/dap/regulations/ISO-29148-compliance.md § 2.3: 需求追溯性管理
    
    Args:
        serial_number: 閘道器序號
        
    Returns:
        Gateway: 已註冊的閘道器物件
    """
    # 實作...
    pass
```

**驗證步驟**：
1. 檢查 `docs/dap/regulations/ISO-29148-compliance.md` 是否存在
2. 檢查文件中是否存在 `§ 2.3: 需求追溯性管理` 章節
3. 檢查程式碼是否符合該章節的合規性要求

❌ **錯誤**（法規文檔路徑不存在）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Compliance Reference:
        - docs/dap/regulations/NONEXISTENT.md § 1.1: 某合規性要求  # 錯誤：文檔不存在
    """
    # 實作...
    pass
```

### 11.4 參考設計文檔進行審查

#### 11.4.1 查閱設計文檔

設計文檔位於 `docs/dap/design/`，包含：
- **系統架構**：`01_SYSTEM_ARCHITECTURE.md`（整體架構設計）
- **子系統設計**：`02_GATEWAY_DESIGN.md`、`03_FACTORY_DESIGN.md` 等
- **設計索引**：`00_DESIGN_INDEX.md`

**如何查閱**：
1. 根據程式碼中的 `Design Reference` 註解，找到對應的設計文檔路徑
2. 在設計文檔中查找對應的章節（如 `§ 3.3: 自動註冊流程`）
3. 驗證程式碼實作是否符合設計決策

#### 11.4.2 驗證設計參考

**檢查要點**：
- [ ] 程式碼中的 `Design Reference` 註解是否指向有效的設計文檔？
- [ ] 設計文檔路徑是否存在（如 `docs/dap/design/02_GATEWAY_DESIGN.md`）？
- [ ] 設計文檔中的章節是否存在（如 `§ 3.3: 自動註冊流程`）？
- [ ] 程式碼實作是否符合設計決策？
- [ ] 分層架構是否正確（Controller → Service → CRUD → Models）？

**範例**：

✅ **正確**（設計參考與文檔一致）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.3: 自動註冊流程
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.1: 資料庫設計（gateways 表）
    
    Args:
        serial_number: 閘道器序號
        
    Returns:
        Gateway: 已註冊的閘道器物件
    """
    # 實作...
    pass
```

**驗證步驟**：
1. 檢查 `docs/dap/design/02_GATEWAY_DESIGN.md` 是否存在
2. 檢查文件中是否存在 `§ 3.3: 自動註冊流程` 章節
3. 檢查程式碼實作是否符合該章節的設計決策
4. 檢查程式碼是否遵循分層架構（如 Service 層不應直接操作資料庫）

❌ **錯誤**（設計文檔章節不存在）：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 99.99: 不存在的章節  # 錯誤：章節不存在
    """
    # 實作...
    pass
```

### 11.5 驗證需求追蹤註解與 RTM 的一致性

#### 11.5.1 RTM 概述

需求追溯矩陣（RTM）位於 `docs/dap/requirements/RTM.md`，記錄：
- 需求 ID 與需求描述
- 對應的實作檔案路徑與行號
- 對應的測試案例
- 需求狀態（Draft/Proposed/Approved/In Progress/Implemented/Verified）

#### 11.5.2 驗證步驟

**檢查要點**：
- [ ] 程式碼中的需求 ID 是否在 RTM 中存在？
- [ ] RTM 中的實作檔案路徑是否與實際程式碼位置一致？
- [ ] RTM 中的需求狀態是否正確（"Implemented" 或 "In Progress"）？
- [ ] 如果需求已實作，RTM 中是否包含對應的測試案例？

**範例**：

假設程式碼中包含：
```python
# Implements: GWMGMT-FR-001
def register_gateway(serial_number: str) -> Gateway:
    # 實作...
    pass
```

**驗證步驟**：
1. 在 `docs/dap/requirements/RTM.md` 中查找 `GWMGMT-FR-001`
2. 檢查 RTM 中的實作檔案是否為 `dap/gateway/service.py`（或實際檔案路徑）
3. 檢查需求狀態是否為 "Implemented" 或 "In Progress"
4. 如果需求已實作，檢查是否有對應的測試案例

### 11.6 實戰範例：完整的 Code Review 流程

以下範例展示如何審查一個 Pull Request，包含需求、法規、設計三個層面：

#### 範例：審查閘道器註冊功能

**Pull Request 內容**：
- 新增 `dap/gateway/service.py` 中的 `register_gateway()` 函數
- 實作閘道器自動註冊功能

**Code Review 步驟**：

**1. 檢查需求追蹤**：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Requirement Traceability:
        - GWMGMT-FR-001: 閘道器註冊
    """
    # 實作...
    pass
```

**檢查**：
- [x] 查閱 `docs/dap/requirements/02_GATEWAY_MANAGEMENT.md`，確認 `GWMGMT-FR-001` 存在
- [x] 查閱 `docs/dap/requirements/RTM.md`，確認 `GWMGMT-FR-001` 的實作檔案為 `dap/gateway/service.py`
- [x] 確認需求狀態為 "In Progress" 或 "Implemented"

**2. 檢查設計一致性**：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 3.3: 自動註冊流程
    """
    # 實作...
    pass
```

**檢查**：
- [x] 查閱 `docs/dap/design/02_GATEWAY_DESIGN.md`，確認 `§ 3.3: 自動註冊流程` 存在
- [x] 確認程式碼實作符合設計決策（如：自動註冊時設定初始狀態為 "online"）
- [x] 確認程式碼遵循分層架構（Service 層不直接操作資料庫）

**3. 檢查合規性**：
```python
def register_gateway(serial_number: str) -> Gateway:
    """註冊新閘道器
    
    Compliance Reference:
        - docs/dap/regulations/ISO-29148-compliance.md § 2.3: 需求追溯性管理
    """
    # 實作...
    pass
```

**檢查**：
- [x] 查閱 `docs/dap/regulations/ISO-29148-compliance.md`，確認 `§ 2.3: 需求追溯性管理` 存在
- [x] 確認程式碼符合合規性要求（如：需求追蹤註解完整）

**4. 綜合檢查**：
- [x] 所有文檔參考都存在且正確
- [x] 程式碼實作符合需求、設計、合規性要求
- [x] RTM 已更新，反映實作狀態

---

## 12. SR、SD、程式碼三層審查

### 12.1 概述

Code Review 不僅要檢查程式碼品質，還需要審查 SR（Stakeholder Requirements）文檔和 SD（System Design）文檔的品質，並驗證三層之間的一致性。本節說明如何進行 SR、SD、程式碼三層審查，確保需求文檔、設計文檔與程式碼的品質與一致性。

**Requirement Traceability**:
- REQMGMT-FR-013: SR、SD、程式碼三層審查

**Design Reference**:
- docs/dap/design/01_SYSTEM_ARCHITECTURE.md: 系統架構設計

**Compliance Reference**:
- docs/dap/regulations/ISO-29148-compliance.md § 2.2: 需求文件結構
- docs/dap/regulations/ISO-29148-compliance.md § 2.3: 需求品質屬性

### 12.2 SR 文檔審查

#### 12.2.1 SR 文檔概述

SR 文檔（Stakeholder Requirements）位於 `docs/dap/requirements/`，包含：
- **系統層需求**：`01_SYSTEM_PRD_SR_SD.md`（產品需求、利害關係人需求 UR-xxx、系統需求 SYS-SR-xxx）
- **子系統需求**：`02_GATEWAY_MANAGEMENT.md`、`03_FACTORY_MANAGEMENT.md` 等（利害關係人需求 SR-xxx、功能需求 FR-xxx）

#### 12.2.2 SR 文檔完整性檢查

**檢查要點**：
- [ ] 所有需求都有明確的描述（需求標題、需求描述、業務價值）
- [ ] 每個需求都有至少一個 Scenario（使用 Given-When-Then 格式）
- [ ] 每個需求都標註驗證方法（Test/Inspection/Analysis/Demo）
- [ ] 需求描述使用 RFC 2119 關鍵字（SHALL/MUST/SHOULD/MAY）

**範例**：

✅ **正確**（完整的 SR 需求）：
```markdown
### Requirement: 即時掌握設備狀態 {#GWMGMT-SR-001}

**利益相關者**：工廠管理員、設備維護人員、系統管理員

**業務需求**：系統 SHALL 提供即時追蹤所有閘道器線上/離線狀態的能力，讓管理人員能夠快速識別異常設備並採取相應措施。

**業務價值**：
- 減少設備故障造成的生產損失
- 提升設備維護效率
- 支援預測性維護策略

**追溯關係**：
- **Traces to**: SYS-SR-001（系統層需求：閘道器狀態追蹤）
- **Traced by**: GWMGMT-FR-002（功能需求：閘道器狀態管理）

**驗證方法**: Test, Demo
```

**檢查**：
- [x] 需求描述明確（說明系統 SHALL 提供什麼能力）
- [x] 業務價值清楚（列出三個業務價值）
- [x] 追溯關係完整（Traces to 和 Traced by 都有標註）
- [x] 驗證方法明確（Test, Demo）

❌ **錯誤**（不完整的 SR 需求）：
```markdown
### Requirement: 即時掌握設備狀態 {#GWMGMT-SR-001}

系統應該提供設備狀態追蹤功能。  # 錯誤：缺少業務價值、追溯關係、驗證方法
```

#### 12.2.3 SR 文檔可驗證性檢查

**檢查要點**：
- [ ] 每個需求都有至少一個 Scenario（驗收場景）
- [ ] Scenario 使用正確的格式（`#### Scenario:` 標題，GIVEN/WHEN/THEN/AND 關鍵字）
- [ ] Scenario 描述清晰，可被測試驗證
- [ ] 每個需求都標註驗證方法

**範例**：

✅ **正確**（可驗證的 Scenario）：
```markdown
#### Scenario: 閘道器上線狀態追蹤
- **GIVEN** 閘道器 "GW001" 處於離線狀態
- **WHEN** 閘道器發送心跳訊息
- **THEN** 系統 SHALL 更新閘道器狀態為 "online"
- **AND** 系統 SHALL 記錄狀態變更時間
```

**檢查**：
- [x] Scenario 格式正確（使用 `#### Scenario:` 標題）
- [x] GIVEN/WHEN/THEN/AND 關鍵字正確使用
- [x] Scenario 描述清晰，可被測試驗證

❌ **錯誤**（不可驗證的 Scenario）：
```markdown
#### Scenario: 閘道器狀態追蹤
系統應該能夠追蹤閘道器狀態。  # 錯誤：沒有使用 GIVEN/WHEN/THEN 格式，無法驗證
```

#### 12.2.4 SR 文檔可追溯性檢查

**檢查要點**：
- [ ] 每個需求都標註 Traces to（追溯到上層需求）
- [ ] 每個需求都標註 Traced by（被下層設計/實作追溯）
- [ ] 追溯關係中的需求 ID 是否存在（在對應文檔中查找）
- [ ] 追溯關係是否完整（無斷鏈）

**範例**：

✅ **正確**（完整的追溯關係）：
```markdown
**追溯關係**：
- **Traces to**: SYS-SR-001（系統層需求：閘道器狀態追蹤）
- **Traced by**: GWMGMT-FR-002（功能需求：閘道器狀態管理）
```

**檢查**：
- [x] 在 `docs/dap/requirements/01_SYSTEM_PRD_SR_SD.md` 中查找 `SYS-SR-001`，確認存在
- [x] 在 `docs/dap/requirements/02_GATEWAY_MANAGEMENT.md` 中查找 `GWMGMT-FR-002`，確認存在
- [x] 追溯關係完整，無斷鏈

❌ **錯誤**（追溯關係不完整）：
```markdown
**追溯關係**：
- **Traces to**: SYS-SR-999  # 錯誤：需求 ID 不存在
- **Traced by**: （空白）  # 錯誤：缺少 Traced by
```

#### 12.2.5 SR 文檔 ISO 29148 合規性檢查

**檢查要點**：
- [ ] 需求格式是否符合 ISO/IEC/IEEE 29148 標準（需求標題、需求描述、驗證方法）
- [ ] 需求關鍵字是否正確使用（SHALL/MUST/SHOULD/MAY，保持英文大寫）
- [ ] 文檔結構是否完整（Stakeholder Requirements、Requirements、Scenarios 三個主要區段）
- [ ] 需求 ID 格式是否正確（`[CAPABILITY]-[TYPE]-[NUMBER]`）

**範例**：

✅ **正確**（符合 ISO 29148 標準）：
```markdown
### Requirement: 即時掌握設備狀態 {#GWMGMT-SR-001}

**利益相關者**：工廠管理員、設備維護人員、系統管理員

**業務需求**：系統 SHALL 提供即時追蹤所有閘道器線上/離線狀態的能力。

**驗證方法**: Test, Demo
```

**檢查**：
- [x] 需求格式符合標準（有需求標題、需求描述、驗證方法）
- [x] 關鍵字正確使用（SHALL 保持英文大寫）
- [x] 需求 ID 格式正確（GWMGMT-SR-001）

❌ **錯誤**（不符合 ISO 29148 標準）：
```markdown
### Requirement: 即時掌握設備狀態 {#GWMGMT-SR-001}

系統應該提供設備狀態追蹤功能。  # 錯誤：使用「應該」而非「SHALL」，缺少利益相關者、驗證方法
```

### 12.3 SD 文檔審查

#### 12.3.1 SD 文檔概述

SD 文檔（System Design）位於 `docs/dap/design/`，包含：
- **系統架構設計**：`01_SYSTEM_ARCHITECTURE.md`（整體架構、子系統分界、介面定義）
- **子系統設計**：`02_GATEWAY_DESIGN.md`、`03_FACTORY_DESIGN.md` 等（架構設計、API 設計、資料庫設計）

#### 12.3.2 SD 文檔設計決策檢查

**檢查要點**：
- [ ] 設計決策是否明確（設計決策的內容、理由、影響）
- [ ] 設計決策是否有理由說明（為什麼選擇這個設計）
- [ ] 設計決策是否考慮了替代方案（是否有說明其他選項）
- [ ] 設計決策是否標註了追溯關係（Traces to 對應的需求 ID）

**範例**：

✅ **正確**（明確的設計決策）：
```markdown
### 2.1 子系統架構

閘道器管理子系統採用三層架構設計：
- **Controller Layer**：處理 HTTP 請求與響應
- **Service Layer**：實作業務邏輯
- **Data Access Layer**：處理資料庫操作

**設計理由**：
- 分層架構確保職責分離，提升可維護性
- 符合 XX 系統架構設計原則

**Traces to**: GWMGMT-SR-001（即時掌握設備狀態）、GWMGMT-FR-002（閘道器狀態管理）
```

**檢查**：
- [x] 設計決策明確（三層架構設計）
- [x] 設計理由清楚（職責分離、可維護性）
- [x] 追溯關係完整（Traces to 對應的需求 ID）

❌ **錯誤**（不明確的設計決策）：
```markdown
### 2.1 子系統架構

使用三層架構。  # 錯誤：沒有說明設計理由、追溯關係
```

#### 12.3.3 SD 文檔架構一致性檢查

**檢查要點**：
- [ ] SD 文檔是否符合系統架構設計（是否符合 `01_SYSTEM_ARCHITECTURE.md` 中的架構原則）
- [ ] 分層架構是否正確（Controller → Service → CRUD → Models）
- [ ] 介面定義是否一致（API 端點、資料格式、錯誤處理）
- [ ] 技術選型是否合理（是否符合系統架構設計中的技術選型）

**範例**：

✅ **正確**（符合系統架構）：
```markdown
### 2.1 子系統架構

```
┌─────────────────────────────────────────┐
│         API Controller Layer            │
│    dap/gateway/controller.py            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Service Layer                   │
│    dap/gateway/service.py               │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Data Access Layer               │
│    dap/views/device_overview/util/      │
│    Gateway.py                           │
└─────────────────────────────────────────┘
```

**符合系統架構設計**：符合 `docs/dap/design/01_SYSTEM_ARCHITECTURE.md` § 2.1 中的多層架構原則。
```

**檢查**：
- [x] 分層架構正確（Controller → Service → Data Access）
- [x] 符合系統架構設計（引用 `01_SYSTEM_ARCHITECTURE.md`）
- [x] 檔案路徑正確（對應實際程式碼結構）

❌ **錯誤**（不符合系統架構）：
```markdown
### 2.1 子系統架構

使用單層架構，所有邏輯都在 controller 中。  # 錯誤：不符合系統架構設計中的多層架構原則
```

#### 12.3.4 SD 文檔實作可行性檢查

**檢查要點**：
- [ ] 設計決策是否可實作（技術選型是否合理、是否有技術限制）
- [ ] 設計決策是否考慮了實作複雜度（是否過於複雜或過於簡單）
- [ ] 設計決策是否考慮了效能與擴展性（是否滿足非功能需求）
- [ ] 設計決策是否標註了實作檔案路徑（Traced by 對應的程式碼檔案）

**範例**：

✅ **正確**（可實作的設計）：
```markdown
### 3.1 資料庫設計

**gateways 表結構**：
- `id`: INTEGER PRIMARY KEY
- `serial_number`: VARCHAR(50) UNIQUE NOT NULL
- `status`: VARCHAR(20) NOT NULL
- `factory_id`: INTEGER REFERENCES factories(id)
- `created_at`: TIMESTAMP
- `updated_at`: TIMESTAMP
- `deleted_at`: TIMESTAMP（軟刪除）

**Traced by**: `dap/views/device_overview/util/Gateway.py`（資料存取層實作）
```

**檢查**：
- [x] 資料庫設計可實作（使用標準 SQL 類型）
- [x] 設計考慮了軟刪除（deleted_at 欄位）
- [x] 追溯關係完整（Traced by 對應的程式碼檔案）

❌ **錯誤**（不可實作的設計）：
```markdown
### 3.1 資料庫設計

使用不存在的資料庫類型 `SUPER_INTEGER`。  # 錯誤：技術選型不合理，無法實作
```

### 12.4 三層審查整合流程

#### 12.4.1 SR → SD 一致性驗證

**檢查要點**：
- [ ] SD 文檔中的 Traces to 是否指向有效的 SR 需求 ID
- [ ] SD 文檔的設計決策是否滿足 SR 需求（設計是否實現了需求目標）
- [ ] 追溯關係是否完整（SR 需求是否都有對應的 SD 設計）

**驗證步驟**：

1. **檢查 SD 文檔中的 Traces to**：
   - 在 SD 文檔中查找所有 `Traces to` 標記
   - 在對應的 SR 文檔中驗證需求 ID 是否存在
   - 確認需求 ID 格式正確

2. **檢查設計決策是否滿足需求**：
   - 閱讀 SR 需求描述，理解需求目標
   - 閱讀 SD 設計決策，確認設計是否實現了需求目標
   - 確認設計決策與需求描述一致，無矛盾

3. **檢查追溯關係完整性**：
   - 在 RTM（`docs/dap/requirements/RTM.md`）中查找 SR 需求
   - 確認 SR 需求都有對應的 SD 設計
   - 確認追溯關係無斷鏈

**範例**：

假設 SR 文檔中有：
```markdown
### Requirement: 即時掌握設備狀態 {#GWMGMT-SR-001}

**業務需求**：系統 SHALL 提供即時追蹤所有閘道器線上/離線狀態的能力。
```

SD 文檔中應該有：
```markdown
### 2.2 狀態管理設計

**設計決策**：使用心跳機制追蹤閘道器狀態，每 30 秒檢查一次心跳逾時。

**Traces to**: GWMGMT-SR-001（即時掌握設備狀態）
```

**檢查**：
- [x] SD 文檔中的 `Traces to: GWMGMT-SR-001` 指向有效的 SR 需求
- [x] 設計決策（心跳機制）實現了需求目標（即時追蹤狀態）
- [x] 追溯關係完整

#### 12.4.2 SD → 程式碼一致性驗證

**檢查要點**：
- [ ] 程式碼中的 Design Reference 是否指向有效的 SD 文檔
- [ ] 程式碼是否符合 SD 文檔中的架構設計（分層架構、介面定義、資料結構）
- [ ] 程式碼中的實作是否與 SD 文檔中的設計決策一致

**驗證步驟**：

1. **檢查 Design Reference**：
   - 在程式碼中查找所有 `Design Reference` 註解
   - 驗證 SD 文檔路徑是否存在（如 `docs/dap/design/02_GATEWAY_DESIGN.md`）
   - 驗證 SD 文檔中的章節是否存在（如 `§ 2.2: 狀態管理設計`）

2. **檢查架構一致性**：
   - 閱讀 SD 文檔中的架構設計
   - 檢查程式碼是否符合分層架構（Controller → Service → CRUD → Models）
   - 確認程式碼沒有跨層呼叫（如 Controller 直接呼叫 CRUD）

3. **檢查設計決策一致性**：
   - 閱讀 SD 文檔中的設計決策
   - 檢查程式碼實作是否符合設計決策
   - 確認程式碼與設計決策無矛盾

**範例**：

假設 SD 文檔中有：
```markdown
### 2.2 狀態管理設計

**設計決策**：使用心跳機制追蹤閘道器狀態，每 30 秒檢查一次心跳逾時。
```

程式碼中應該有：
```python
def handle_heartbeat(gateway_id: int) -> dict:
    """處理閘道器心跳
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 2.2: 狀態管理設計
    
    Args:
        gateway_id: 閘道器 ID
        
    Returns:
        dict: 心跳處理結果
    """
    # 實作心跳處理邏輯，符合設計決策（30 秒逾時檢查）
    pass
```

**檢查**：
- [x] Design Reference 指向有效的 SD 文檔（`02_GATEWAY_DESIGN.md`）
- [x] Design Reference 指向有效的章節（`§ 2.2: 狀態管理設計`）
- [x] 程式碼實作符合設計決策（心跳機制、30 秒逾時）

#### 12.4.3 SR → SD → 程式碼完整追溯鏈驗證

**檢查要點**：
- [ ] 追溯鏈的完整性（SR 需求 → SD 設計 → 程式碼實作是否都有對應關係）
- [ ] 追溯鏈的一致性（三層之間的描述是否一致、是否有矛盾）
- [ ] RTM 是否正確記錄三層追溯關係

**驗證步驟**：

1. **檢查追溯鏈完整性**：
   - 從 SR 需求開始，查找對應的 SD 設計（透過 SD 文檔中的 Traces to）
   - 從 SD 設計開始，查找對應的程式碼實作（透過程式碼中的 Design Reference）
   - 確認 SR → SD → 程式碼的完整追溯鏈

2. **檢查追溯鏈一致性**：
   - 閱讀 SR 需求描述
   - 閱讀 SD 設計決策，確認是否實現了 SR 需求
   - 閱讀程式碼實作，確認是否符合 SD 設計
   - 確認三層之間的描述一致，無矛盾

3. **檢查 RTM 記錄**：
   - 在 RTM（`docs/dap/requirements/RTM.md`）中查找 SR 需求
   - 確認 RTM 中記錄了 SR → SD → 程式碼的完整追溯關係
   - 確認 RTM 中的實作檔案路徑與實際程式碼位置一致

**範例**：

**SR 文檔**（`docs/dap/requirements/02_GATEWAY_MANAGEMENT.md`）：
```markdown
### Requirement: 即時掌握設備狀態 {#GWMGMT-SR-001}

**業務需求**：系統 SHALL 提供即時追蹤所有閘道器線上/離線狀態的能力。

**Traced by**: GWMGMT-FR-002（功能需求：閘道器狀態管理）
```

**SD 文檔**（`docs/dap/design/02_GATEWAY_DESIGN.md`）：
```markdown
### 2.2 狀態管理設計

**設計決策**：使用心跳機制追蹤閘道器狀態。

**Traces to**: GWMGMT-SR-001（即時掌握設備狀態）、GWMGMT-FR-002（閘道器狀態管理）

**Traced by**: `dap/gateway/service.py`（業務邏輯實作）
```

**程式碼**（`dap/gateway/service.py`）：
```python
def handle_heartbeat(gateway_id: int) -> dict:
    """處理閘道器心跳
    
    Requirement Traceability:
        - GWMGMT-FR-002: 閘道器狀態管理
    
    Design Reference:
        - docs/dap/design/02_GATEWAY_DESIGN.md § 2.2: 狀態管理設計
    
    Args:
        gateway_id: 閘道器 ID
        
    Returns:
        dict: 心跳處理結果
    """
    # 實作心跳處理邏輯
    pass
```

**檢查**：
- [x] 追溯鏈完整：SR（GWMGMT-SR-001）→ SD（§ 2.2）→ 程式碼（`dap/gateway/service.py`）
- [x] 追溯鏈一致：三層描述一致（即時追蹤狀態 → 心跳機制 → 心跳處理實作）
- [x] RTM 記錄正確：RTM 中記錄了完整的追溯關係

### 12.5 實戰範例：完整的三層審查流程

以下範例展示如何審查一個完整的變更，從 SR 到 SD 到程式碼：

#### 範例：審查閘道器狀態管理功能

**Pull Request 內容**：
- 新增 SR 需求：`docs/dap/requirements/02_GATEWAY_MANAGEMENT.md` 中的 `GWMGMT-SR-001`
- 新增 SD 設計：`docs/dap/design/02_GATEWAY_DESIGN.md` 中的 `§ 2.2: 狀態管理設計`
- 新增程式碼：`dap/gateway/service.py` 中的 `handle_heartbeat()` 函數

**Code Review 步驟**：

**1. 審查 SR 文檔**：

**檢查完整性**：
- [x] 需求描述明確：系統 SHALL 提供即時追蹤所有閘道器線上/離線狀態的能力
- [x] 業務價值清楚：減少設備故障造成的生產損失、提升設備維護效率
- [x] 追溯關係完整：Traces to SYS-SR-001，Traced by GWMGMT-FR-002
- [x] 驗證方法明確：Test, Demo

**檢查可驗證性**：
- [x] 有至少一個 Scenario：檢查 `#### Scenario:` 是否存在
- [x] Scenario 格式正確：使用 GIVEN/WHEN/THEN/AND 格式
- [x] Scenario 可被測試驗證：描述清晰，可寫成測試案例

**檢查 ISO 29148 合規性**：
- [x] 需求格式符合標準：有需求標題、需求描述、驗證方法
- [x] 關鍵字正確使用：SHALL 保持英文大寫
- [x] 需求 ID 格式正確：GWMGMT-SR-001

**2. 審查 SD 文檔**：

**檢查設計決策**：
- [x] 設計決策明確：使用心跳機制追蹤閘道器狀態
- [x] 設計理由清楚：即時性、可靠性、可擴展性
- [x] 追溯關係完整：Traces to GWMGMT-SR-001

**檢查架構一致性**：
- [x] 符合系統架構：符合 `01_SYSTEM_ARCHITECTURE.md` 中的多層架構原則
- [x] 分層架構正確：Controller → Service → Data Access
- [x] 技術選型合理：使用心跳機制，符合系統架構設計

**檢查實作可行性**：
- [x] 設計可實作：心跳機制是成熟的技術方案
- [x] 實作檔案路徑正確：Traced by `dap/gateway/service.py`

**3. 審查程式碼**：

**檢查 Design Reference**：
- [x] Design Reference 指向有效的 SD 文檔：`docs/dap/design/02_GATEWAY_DESIGN.md`
- [x] Design Reference 指向有效的章節：`§ 2.2: 狀態管理設計`

**檢查架構一致性**：
- [x] 程式碼符合分層架構：`handle_heartbeat()` 在 Service 層
- [x] 沒有跨層呼叫：Service 層不直接操作資料庫

**檢查設計決策一致性**：
- [x] 程式碼實作符合設計決策：實作了心跳處理邏輯
- [x] 程式碼與設計決策一致：無矛盾

**4. 驗證三層一致性**：

**檢查 SR → SD 一致性**：
- [x] SD 文檔中的 Traces to 指向有效的 SR 需求：GWMGMT-SR-001
- [x] SD 設計決策滿足 SR 需求：心跳機制實現了即時追蹤狀態的需求
- [x] 追溯關係完整：SR 需求有對應的 SD 設計

**檢查 SD → 程式碼一致性**：
- [x] 程式碼中的 Design Reference 指向有效的 SD 文檔
- [x] 程式碼符合 SD 架構設計：分層架構正確
- [x] 程式碼實作符合設計決策：心跳處理邏輯正確

**檢查完整追溯鏈**：
- [x] 追溯鏈完整：SR（GWMGMT-SR-001）→ SD（§ 2.2）→ 程式碼（`dap/gateway/service.py`）
- [x] 追溯鏈一致：三層描述一致，無矛盾
- [x] RTM 記錄正確：RTM 中記錄了完整的追溯關係

**5. 綜合檢查**：
- [x] 所有文檔品質符合標準
- [x] 三層之間的一致性驗證通過
- [x] 追溯鏈完整且正確
- [x] RTM 已更新，反映三層追溯關係

---

## 9. 相關文檔

- **開發指南**: [`DEVELOPMENT_GUIDE.md`](DEVELOPMENT_GUIDE.md)
- **培訓指南**: [`TRAINING_GUIDE.md`](TRAINING_GUIDE.md)
- **Linus 哲學指引**: `.cursor/code_guide/linus_torvalds_philosophy_guide.md`
- **專案規範**: `openspec/project.md`
- **需求追溯矩陣**: `docs/dap/requirements/RTM.md`

---

## 10. 版本歷史

| 版本 | 日期 | 修改者 | 變更摘要 |
|------|------|--------|---------|
| v1.0 | 2025-12-22 | XX Team | 初始版本，基於 Linus Torvalds 哲學建立 Code Review 指南 |
| v1.1 | 2025-12-22 | XX Team | 新增 § 11. 參考文檔進行 Code Review，整合 requirements、regulations、design 文檔審查流程 |
| v1.2 | 2025-12-22 | XX Team | 新增 § 12. SR、SD、程式碼三層審查，擴展 Code Review 至需求文檔、設計文檔與程式碼的完整審查流程 |

---

**文檔版本**: v1.2.0  
**維護團隊**: XX Development Team  
**最後審核**: 2025-12-22  
**文檔語言**: 繁體中文（Traditional Chinese）

