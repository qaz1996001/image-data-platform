# Project Context

## Purpose
醫療影像資料平台 (Image Data Platform) - 用於管理醫療影像檢查資料、報告與專案的全端應用系統。

## Tech Stack

### Frontend
- React 18 + TypeScript 5.x
- Vite (Build tool)
- Ant Design v5 (UI Framework)
- React Router v6 (Routing)
- Zustand (State Management)
- Playwright (E2E Testing)

### Backend
- Django 4.x + Python 3.11+
- Django REST Framework
- PostgreSQL (Database)
- Redis (Cache)

## Project Conventions

### Code Style

#### TypeScript/React (Frontend)

**基本原則 (Based on Linus-CLAUDE.md)**:

1. **Good Taste - 消除特殊情況**
   - 優先修正類型定義，而非到處添加型別斷言
   - 簡化程式碼結構，減少巢狀層級（≤3 層）
   - 消除不必要的條件判斷

2. **Never Break Userspace - 向後相容**
   - 任何修改不得破壞現有功能
   - UI 變更需經使用者同意
   - 保持 API 介面穩定

3. **Pragmatism - 實用主義**
   - 解決真實問題，非想像中的威脅
   - 對外部庫的類型問題，可使用型別斷言
   - 程式碼服務於現實，非學術論文

4. **Simplicity - 簡單性**
   - 函數短小，只做一件事
   - 命名簡潔明確
   - 複雜性是萬惡根源

**TypeScript 規範**:

```typescript
// ✅ 正確：明確的類型定義
interface User {
  id: string;
  name: string;
  role: 'admin' | 'user' | 'viewer';
}

// ❌ 錯誤：使用 any 或過度寬鬆的類型
const user: any = fetchUser();

// ✅ 正確：使用型別守衛
function isDateRange(value: unknown): value is { start: string; end: string } {
  return typeof value === 'object' && value !== null && 'start' in value;
}

// ❌ 錯誤：直接存取可能不存在的屬性
const start = value.start; // 當 value 可能是 string 時
```

**Import 規範**:
```typescript
// ✅ 正確：只導入使用的項目
import { Button, Form } from 'antd';

// ❌ 錯誤：導入未使用的項目
import { Button, Form, Modal, Input } from 'antd'; // Modal, Input 未使用

// ✅ 正確：類型導入使用 type 關鍵字
import type { ButtonProps } from 'antd';

// ❌ 錯誤：直接導入 .d.ts 檔案
import { SomeType } from '@types/someModule';
```

**組件規範**:
```typescript
// ✅ 正確：簡潔的 React 組件
export function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>;
}

// ❌ 錯誤：過度複雜的組件
export function UserCard({
  user,
  onEdit,
  onDelete,
  showActions,
  variant,
  // ... 20 more props
}: UserCardProps) {
  // 500 lines of code
}
```

#### Python/Django (Backend)

**基本原則 (Based on Linus-CLAUDE.md & code-quality-linus.mdc)**:

1. **Good Taste - 消除特殊情況**
   - 用資料結構取代 if/else 鏈
   - 縮排不超過 3 層
   - 優先修正資料結構設計

2. **Never Break Userspace - 向後相容**
   - 任何修改不得破壞現有 API
   - 保持例外訊息格式一致

3. **Pragmatism - 實用主義**
   - 解決真實問題，非想像中的威脅
   - 拒絕過度抽象與無用工廠

4. **Simplicity - 簡單性**
   - 函數短小（≤20 行）
   - 命名簡潔明確
   - 複雜性是萬惡根源

**Coding Standards**:

```python
# ✅ 正確：Early return，扁平邏輯
def validate_file(path: Path) -> ValidationResult:
    if not path.exists():
        return ValidationResult.error("檔案不存在")
    if not path.is_file():
        return ValidationResult.error("不是檔案")
    return ValidationResult.ok()

# ❌ 錯誤：深度巢狀
def validate_file(path: Path):
    if path.exists():
        if path.is_file():
            return True
```

**Exception Handling**:

```python
# ✅ 正確：使用 from 子句
try:
    result = parse_file(path)
except FileNotFoundError as e:
    raise HttpError(404, "File not found") from e

# ✅ 正確：明確隱藏不相關異常
try:
    task_id = UUID(payload.task_id)
except ValueError:
    raise HttpError(400, "Invalid format") from None

# ❌ 錯誤：遺失異常鏈
try:
    result = parse_file(path)
except FileNotFoundError:
    raise HttpError(404, "File not found")
```

**Type Safety**:

```python
# ✅ 正確：None 檢查
uid = data.get("uid")
if uid is None:
    raise ValueError("Missing uid")
process(uid)

# ❌ 錯誤：忽略 None 可能性
process(data.get("uid"))  # 可能是 None
```

**Tooling**:
- Formatter: `ruff format` (or Black)
- Linter: `ruff check`
- Type checker: `ty check` (or mypy)
- Style: PEP 8

**Reference Files**:
- `.cursor/rules/code-quality-linus.mdc` - Linus 風格程式碼審查標準
- `resource/Linus-CLAUDE.md` - Linus Torvalds 角色定義與審查流程

### Architecture Patterns

#### Frontend
- 功能模組化 (Feature-based structure)
- Custom Hooks 封裝業務邏輯
- 類型定義集中於 `src/types/`
- 服務層 (`src/services/`) 處理 API 呼叫

#### Backend
- Django REST Framework ViewSets
- Service Layer Pattern
- Repository Pattern for data access

### Testing Strategy

#### Frontend
- E2E: Playwright
- Unit: Vitest (建議)
- Component: React Testing Library

#### Backend
- Django TestCase
- pytest for advanced testing

### Git Workflow

**Branch Naming**:
- `feature/description`
- `fix/issue-description`
- `refactor/scope`

**Commit Convention**:
```
type(scope): brief description

- feat: 新功能
- fix: 錯誤修復
- refactor: 重構
- docs: 文件更新
- test: 測試相關
- chore: 維護性工作
```

## Domain Context

### Core Entities
- **Study**: 醫療影像檢查記錄
- **Report**: 檢查報告
- **Project**: 專案（用於組織 Studies 和 Reports）
- **Annotation**: 報告標註

### Business Rules
- Study 可以屬於多個 Project
- Report 必須關聯一個 Study
- 支援批次操作（匯入、匯出、指派）

## Important Constraints

### Technical
- TypeScript strict mode 必須通過（`npx tsc --noEmit` 無錯誤）
- 不使用 `any` 類型（除非絕對必要）
- 保持向後相容性

### Security
- API 需要驗證
- 敏感資料需加密
- 遵循 OWASP 安全指南

### Performance
- 分頁處理大量資料
- 使用虛擬列表顯示長清單
- 避免不必要的 re-render

## External Dependencies

### APIs
- Backend Django REST API
- AI Analysis Service (optional)

### Services
- PostgreSQL Database
- Redis Cache
- File Storage (local/cloud)

## Quality Gates

### Pre-commit
```bash
# Frontend
pnpm lint
npx tsc --noEmit

# Backend
uvx ruff format --check .
uvx ruff check .
uvx ty check .
```

### CI/CD
- 所有測試必須通過
- TypeScript 編譯無錯誤
- Lint 無警告
- Type check 無錯誤
