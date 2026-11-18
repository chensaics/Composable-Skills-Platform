# Code-to-CMS Documentation Extraction

> 从源码自动抽取结构化文档，生成 CMS 中每个代码模块/文件的说明。
> 目标：一键运行生成文档，代码变更时自动检测并增量更新。
>
> 这是 csp-code-spec 的 Step 2.5（代码→文档抽取）的详细规范。

## 1. 整体流程

```
源代码 ──scan──▶ 结构化元数据 ──templating──▶ 模块文档 .md
                          │
                    git diff 检测变更
                          │
                    ────▶ delta 增量更新
```

三个阶段：
1. **Scan**：扫描源码提取结构化元数据（docstring、类型、签名）
2. **Generate**：用模板渲染为 markdown 文档
3. **Align**：git diff 检测变更，只更新变更文件

## 2. Python 抽取模式

### 2.1 模块级注释

```python
"""
Module: auth_service.py
Purpose: 用户认证与授权服务
Dependencies: database.py, jwt_utils.py
"""
```

抽取为：
```markdown
## 模块: auth_service.py
- **职责**: 用户认证与授权服务
- **依赖**: database.py, jwt_utils.py
```

### 2.2 Class 文档

从 docstring + type hints + 装饰器 抽取：

```python
@dataclass
class UserSession:
    """用户会话对象，管理单次登录状态。

    会话在登录时创建，登出时销毁。支持自动续期。
    """
    user_id: str          # 用户唯一标识
    token: str            # JWT access token
    created_at: datetime  # 会话创建时间
    expires_at: datetime  # 会话过期时间

    def is_expired(self) -> bool:
        """检查会话是否过期。"""
        return datetime.now() > self.expires_at

    def refresh(self, duration: timedelta = timedelta(hours=1)) -> None:
        """续期会话，延长过期时间。

        Args:
            duration: 续期时长，默认 1 小时
        """
        self.expires_at = datetime.now() + duration
```

抽取为结构化文档：
```markdown
### Class: UserSession

用户会话对象，管理单次登录状态。会话在登录时创建，登出时销毁。支持自动续期。

**Type**: dataclass
**File**: `auth_service.py:15`

#### Fields
| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | str | 用户唯一标识 |
| token | str | JWT access token |
| created_at | datetime | 会话创建时间 |
| expires_at | datetime | 会话过期时间 |

#### Methods

##### is_expired()
- **签名**: `is_expired() -> bool`
- **功能**: 检查会话是否过期

##### refresh(duration)
- **签名**: `refresh(duration: timedelta = timedelta(hours=1)) -> None`
- **功能**: 续期会话，延长过期时间
- **参数**:
  - `duration (timedelta)`: 续期时长，默认 1 小时
```

### 2.3 抽取命令（Python）

```bash
# 单文件抽取
python3 -c "
import ast, sys
with open(sys.argv[1]) as f:
    tree = ast.parse(f.read())
for node in ast.walk(tree):
    if isinstance(node, ast.ClassDef):
        doc = ast.get_docstring(node) or '(no docstring)'
        methods = [m.name for m in node.body if isinstance(m, ast.FunctionDef)]
        print(f'CLASS|{node.name}|{node.lineno}|{doc}|{methods}')
    elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and node.name != '__init__':
        doc = ast.get_docstring(node) or '(no docstring)'
        args = [a.arg for a in node.args.args]
        print(f'FUNC|{node.name}|{node.lineno}|{doc}|{args}')
" {file}
```

```bash
# 批量抽取全项目
find . -name "*.py" -not -path "*/__pycache__/*" -not -path "*/venv/*" | while read f; do
    echo "## FILE: $f"
    python3 scripts/extract_python_docs.py "$f"
done
```

### 2.4 抽取规则

| 信号 | Python 来源 | 文档用途 |
|------|-----------|---------|
| 模块说明 | 文件顶部的 `"""module docstring"""` | 模块职责 + 依赖 |
| Class 说明 | `class X: """docstring"""` | 类功能 + 字段 + 方法列表 |
| Method 说明 | `def x(): """docstring"""` | 方法功能 + 参数 + 返回值 |
| 类型信息 | type hints (`str`, `int`, `Optional[X]`) | 参数类型 + 返回值类型 |
| 装饰器 | `@route`, `@dataclass`, `@staticmethod` | 类/方法元信息 |
| 继承关系 | `class X(Y)` | 类层级 |
| 常量 | `MAX_RETRY = 3` / `DEFAULT_*` | 配置说明 |

## 3. TypeScript/React 抽取模式

### 3.1 Component JSDoc

```typescript
/**
 * UserProfileCard — 用户信息卡片组件。
 *
 * @component
 * @example
 * <UserProfileCard userId="123" onEdit={(id) => navigate(`/edit/${id}`)} />
 */
interface UserProfileCardProps {
  /** 用户 ID */
  userId: string;
  /** 是否显示编辑按钮 @default true */
  showEdit?: boolean;
  /** 编辑回调 */
  onEdit?: (userId: string) => void;
}

export const UserProfileCard: React.FC<UserProfileCardProps> = ({
  userId, showEdit = true, onEdit
}) => { /* ... */ };
```

抽取为：
```markdown
### Component: UserProfileCard

用户信息卡片组件。

**File**: `components/UserProfileCard.tsx`

#### Props
| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| userId | string | ✅ | — | 用户 ID |
| showEdit | boolean | ❌ | true | 是否显示编辑按钮 |
| onEdit | (userId: string) => void | ❌ | — | 编辑回调 |

**Example**:
```tsx
<UserProfileCard userId="123" onEdit={(id) => navigate(`/edit/${id}`)} />
```
```

### 3.2 TypeScript 抽取命令

```bash
# 从 .tsx/.ts 文件抽取组件和接口
find src -name "*.tsx" -o -name "*.ts" | while read f; do
    echo "## FILE: $f"
    # 抽取 interface/type
    grep -n "export interface\|export type\|interface.*Props" "$f" | while read line; do
        echo "TYPE|$line"
    done
    # 抽取 JSDoc 注释块
    grep -B1 -A5 "\*\*" "$f" | grep -v "^--$"
    # 抽取 export 的组件/函数
    grep -n "export.*function\|export const.*=" "$f"
done
```

### 3.3 抽取规则

| 信号 | TypeScript 来源 | 文档用途 |
|------|---------------|---------|
| 组件说明 | JSDoc `@component` | 组件功能 |
| Props 类型 | `interface XProps` + JSDoc `@param` | 参数列表 |
| 自定义 Hooks | `export function useXxx` | Hook 用途 |
| 工具函数 | `export function xxx` | 函数文档 |
| 事件处理 | Props 中的 `onXxx` 回调 | 交互说明 |
| 示例用法 | JSDoc `@example` | 代码示例 |
| 类型导出 | `export type X` | 领域类型说明 |

## 4. Go 抽取模式

### 4.1 抽取规则

| 信号 | Go 来源 | 文档用途 |
|------|--------|---------|
| 包说明 | `// Package xxx provides...` | 包职责 |
| 结构体 | `type Xxx struct` + 上方注释 | 数据结构 |
| 公开方法 | `func (x *Xxx) Method()` + 注释 | 方法文档 |
| 接口 | `type XxxInterface interface` | 接口契约 |
| 常量 | `const MaxRetry = 3` | 配置 |

### 4.2 抽取命令

```bash
# 抽取 Go 包的公开 API
go doc -all ./pkg/auth/ 2>/dev/null
```

## 5. 一键生成脚本

创建 `scripts/code_doc_gen.sh`：

```bash
#!/bin/bash
# code_doc_gen.sh — 从源码自动生成 CMS 模块文档
# Usage:
#   bash scripts/code_doc_gen.sh [--lang python|typescript|go] [--changed-since HEAD~1]

set -euo pipefail

OUT_DIR=".csp/code-spec/{app}/modules"
LANG="${1:-auto}"  # auto = 从项目文件自动检测
CHANGED="${2:-}"    # git diff 范围，空 = 全量

mkdir -p "$OUT_DIR"

detect_language() {
    if ls *.py >/dev/null 2>&1; then echo "python"
    elif ls tsconfig.json >/dev/null 2>&1; then echo "typescript"
    elif ls go.mod >/dev/null 2>&1; then echo "go"
    else echo "unknown"; fi
}

if [ "$LANG" = "auto" ]; then
    LANG=$(detect_language)
fi

if [ -n "$CHANGED" ]; then
    # 增量模式：只处理变更文件
    FILES=$(git diff --name-only "$CHANGED" | grep -E "\.(py|tsx?|go)$" || true)
else
    # 全量模式
    case "$LANG" in
        python) FILES=$(find . -name "*.py" -not -path "*/__pycache__/*" -not -path "*/venv/*" -not -path "*/test/*") ;;
        typescript) FILES=$(find src -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".test.") ;;
        go) FILES=$(find . -name "*.go" -not -path "*/vendor/*" -not -path "*/_test.go") ;;
    esac
fi

for f in $FILES; do
    module_name=$(echo "$f" | sed 's|/|_|g' | sed 's|\.||g')
    out="$OUT_DIR/${module_name}.md"
    echo "Generating $out from $f..."

    case "$LANG" in
        python)
            python3 scripts/extract_python_docs.py "$f" > "$out"
            ;;
        typescript)
            bash scripts/extract_ts_docs.sh "$f" > "$out"
            ;;
        go)
            go doc "$f" > "$out" 2>/dev/null || echo "# $(basename $f)" > "$out"
            ;;
    esac
done

echo "Done. Generated $(find $OUT_DIR -name '*.md' | wc -l) module docs."
```

## 6. 增量更新机制

代码变更后，不重扫全量，只处理变更文件：

```bash
# 检测自从上次 CMS 基线以来的变更
PREV_BASELINE=$(git log --oneline -1 -- .csp/code-spec/{app}/CODE-MODULE-SPEC.md | cut -d' ' -f1)
if [ -n "$PREV_BASELINE" ]; then
    bash scripts/code_doc_gen.sh --changed-since "$PREV_BASELINE"
fi
```

**Delta 策略**：
- 新增文件 → 生成新的 `{module_name}.md`
- 修改文件 → 覆盖对应 `{module_name}.md`（幂等）
- 删除文件 → `{module_name}.md` 移入 `deltas/REMOVED/`
- CMS canonical `CODE-MODULE-SPEC.md` 记录每次生成的 git baseline

## 7. 质量门

- [ ] 每个 Class/Component 至少有 docstring 检查：无 docstring 标记 `⚠️ MISSING DOCSTRING`
- [ ] 公开方法/函数必须标注参数类型（Python 用 type hints，TS 用 interface）
- [ ] 模块文档至少含：模块职责 + 主要 Class/Component 列表
- [ ] 文档中的 `source` 引用指回原始代码 `file:line`
- [ ] 增量生成不产生重复内容（幂等性）