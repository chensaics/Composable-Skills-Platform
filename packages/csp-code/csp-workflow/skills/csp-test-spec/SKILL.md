---
name: csp-test-spec
description: "Test Module Spec (TMS / 测试说明书). The per-module living test baseline, branching from PMS. Generates stock + incremental test cases from PMS acceptance criteria with full traceability (AC→test method→test case matrix). Auto-generates test stubs from PRD acceptance criteria. When a change lands, TMS emits only the incremental cases the delta requires, not a from-scratch rewrite."
version: "1.0.0"
layer: 2
category: workflow
phase: verify
domain: testing
scope: testing
role: architect
tools: [Read, Write, Edit, Glob, Grep, Bash]

dependencies:
  skills: [csp-product-spec]

related_skills:
  - csp-product-spec
  - csp-code-spec
  - csp-test-methodology
  - csp-qa-test-engineering
  - csp-qa-cr-review
  - csp-prd-traceability
  - csp-prd-change-impact
  - csp-tdd
  - csp-verification
  - csp-e2e-testing
  - csp-api-tester
  - csp-cross-layer-testing
  - csp-visual-regression
  - csp-db-state-assertion
  - csp-linked-test-runner
  - csp-defect-mining
  - csp-security-review
  - csp-ultraqa

triggers:
  keywords: ["测试说明书", "测试基线", "存量用例", "增量用例", "测试模块规格", "TMS",
             "test module spec", "test baseline", "需求用例矩阵", "regression inventory",
             "测试用例基线", "用例存量", "用例增量"]
  intents:
    - "user wants a living test baseline (stock inventory) per module"
    - "user needs stock + incremental test cases from requirement/design docs"
    - "user wants a requirement→method trace matrix to find untested functionality"
  context:
    - "after_prd_or_design"
    - "before_test_generation"
    - "incremental_change"

anti_rationalizations:
  "每次变更重新生成全套用例就行": "全量重写 = 浪费 + 不可追溯。TMS 维护存量基线，只对 delta 产出增量，回归有边界。"
  "绿测试 = 覆盖了需求": "绿测试可能没映射需求。需求可追溯缺口分析才是覆盖真相；未映射需求 = 潜在功能缺失。"
  "TMS 和 PMS 无关": "TMS 是 PMS 的分支：测试面继承 PMS 模块边界与验收形态，不得发明 PMS 未声明的模块。"
  "用例随便列就行": "用例矩阵式组织（入口×状态），命名完整叙事句；割裂测试（只测功能点不测联动）是漏 bug 主因。"
---

# Test Module Spec (TMS) — 测试说明书

> **定位:** TMS 是模块级 *living test baseline*，**作为 PMS 的分支**。它维护
> **存量用例清单 (stock)** + **需求→方法追溯矩阵**，并基于需求/设计文档生成
> **存量与增量用例**。变更落地时只产出 delta 新触及的增量用例（入口×状态矩阵），
> 而非推倒重来。它像 PMS 治理 PRD 质量一样**治理测试用例质量**。
>
> **与 csp-qa-cr-review 的关系:** CR 的"生成用例"步骤读 TMS 存量基线，只输出增量。
> TMS 是其背后的 living 来源；`csp-qa-cr-review` 是 CR 场景的执行入口。

## When to Use

- 需求/设计文档完成后，需要建立模块级测试基线（存量用例 + 需求矩阵）
- 变更落地，需要只针对 delta 产出增量用例，而非全量重写
- 需要需求→方法追溯矩阵找出"未测功能"（绿测试掩盖的缺口）
- 迭代演进，需要一条 living 测试基线跨迭代复用

## When NOT to Use

- 单功能的测试用例生成（用 `csp-qa-test-engineering`；它会读 TMS）
- 选测试方法/组合拳（用 `csp-test-methodology`；TMS 引用其方法谱系）
- 一次性 E2E 脚本（用 `csp-e2e-testing`）

## Process

### Step 1: 装载上下文（PMS 分支校验）

TMS 是 PMS 的分支，先校验：

| 检查 | 要求 |
|------|------|
| `.csp/product-spec/PRODUCT-MODULE-SPEC.md` 存在 | TMS 模块必须在 PMS 声明的模块内 |
| `.csp/specs/SPEC-F-*.md` 或设计文档 | 作为用例来源（验收标准 + 异常场景） |
| `.csp/code-spec/{app}/entry-points.jsonl` | 增量用例的入口维度（与 CMS 协同） |
| `.csp/test-spec/{module}/TEST-MODULE-SPEC.md` 存在 | 增量模式 → Step 6 |

**分支纪律:** TMS 不得发明 PMS 未声明的模块；验收形态继承 PMS §5。

### Step 1.5: PMS 验收标准→TMS 测试用例映射（AC→Test）

TMS 的核心价值是把 PMS 的验收标准（AC）**自动翻译为可执行的测试用例骨架**。
这建立了从 PRD 到测试的完整追溯链。

#### 1.5a: AC 到测试方法的自动路由

对 PMS 中每条验收标准，按**原型**自动分配测试方法：

| AC 原型 | → 测试方法 | 示例 |
|--------|----------|------|
| "用户执行 X，系统返回 Y" | unit test (happy path) | `test_login_returns_token()` |
| "当 X 条件不满足，系统拒绝" | unit test (negative) | `test_login_rejects_invalid_password()` |
| "X 操作后，Y 状态变更" | cross-layer (集成) | `test_order_changes_stock_in_db()` |
| "用户可看到 Z 列表" | E2E / component test | `test_user_list_renders_20_items()` |
| "系统在 N 秒内响应" | performance test | `test_search_under_200ms()` |
| "X 变更不影响 Y 功能" | regression test | `test_email_still_works_after_auth_change()` |
| "N 个用户同时 X" | concurrency / property | `test_concurrent_order_no_oversell()` |

**执行**：
```bash
# 从 PMS 提取所有 AC，自动分配测试方法
python3 -c "
import re, sys
ac_pattern = r'Given (.+), When (.+), Then (.+)'
for line in sys.stdin:
    m = re.match(ac_pattern, line.strip())
    if m:
        given, when, then = m.groups()
        # 规则分配
        if 'reject' in then.lower() or 'denied' in then.lower():
            method = 'unit (negative)'
        elif 'display' in then.lower() or 'render' in then.lower():
            method = 'E2E / component'
        elif 'status' in then.lower() or 'change' in then.lower():
            method = 'cross-layer'
        elif 'second' in then.lower() or 'second' in then.lower():
            method = 'performance'
        else:
            method = 'unit (happy path)'
        print(f'AC: {given} | {when} | {then}')
        print(f'  → test method: {method}')
        print()
" < .csp/product-spec/PRODUCT-MODULE-SPEC.md
```

#### 1.5b: AC→测试用例映射表

为每条 PMS 验收标准生成测试用例骨架：

```markdown
## AC→Test 映射表 — MOD-AUTH-1 用户与权限

**PMS 来源**: `.csp/product-spec/PRODUCT-MODULE-SPEC.md`
**生成时间**: {date}
**覆盖率目标**: 每个 AC ≥ 1 测试方法

| AC ID | PMS 验收标准 | 测试方法 | 测试用例 | 优先级 | 状态 |
|-------|-----------|---------|---------|--------|------|
| AC-AUTH-1 | Given 有效凭证, When 用户登录, Then 返回 JWT token | unit (happy) | `test_login_valid_credentials` | P0 | ⬜ |
| AC-AUTH-2 | Given 无效密码, When 用户登录, Then 返回 401 + "密码错误" | unit (negative) | `test_login_invalid_password` | P0 | ⬜ |
| AC-AUTH-3 | Given 已登录, When 访问需认证页面, Then 正常显示 | cross-layer | `test_auth_middleware_allows_authenticated` | P0 | ⬜ |
| AC-AUTH-4 | Given 未登录, When 访问需认证页面, Then 跳转到登录页 | cross-layer | `test_auth_middleware_redirects_anonymous` | P0 | ⬜ |
| AC-AUTH-5 | Given 过期 token, When 访问 API, Then 返回 401 + "token 过期" | unit (negative) | `test_expired_token_rejected` | P1 | ⬜ |
| AC-AUTH-6 | Given 有效 token, When 用户登出, Then token 被撤销 | cross-layer | `test_logout_revokes_token` | P1 | ⬜ |

### 覆盖统计
- 总 AC 数：6
- 已映射测试方法：6 (100%)
- 已实现测试用例：0 (0%)  ← 开发者逐步实现
- 未覆盖 AC：无
```

**自动生成测试骨架代码**：

```python
# 从 AC→Test 映射表自动生成测试函数骨架
def generate_test_stub(ac_id, ac_given, ac_when, ac_then, test_method):
    """生成 pytest 测试函数骨架"""
    test_name = ac_id.lower().replace('-', '_')
    return f'''
def test_{test_name}():
    """AC: Given {ac_given}, When {ac_when}, Then {ac_then}"""
    # TODO: 实现测试逻辑
    # Arrange: {ac_given}
    # Act: {ac_when}
    # Assert: {ac_then}
    pass  # ← 开发者替换为实际测试代码
'''

# 示例输出:
# def test_auth_1():
#     """AC: Given 有效凭证, When 用户登录, Then 返回 JWT token"""
#     # Arrange: 准备有效的用户名和密码
#     # Act: 调用 POST /auth/login
#     # Assert: 响应 status=200, body.token 非空, token 可解码
#     pass
```

#### 1.5c: PMS 变更→TMS 影响追踪

当 PMS 新增/修改/删除 AC 时，自动更新 TMS：

```bash
# 比较当前 PMS AC 与上次 TMS 基线的差异
diff \
  <(grep -E "Given.+When.+Then" .csp/product-spec/PRODUCT-MODULE-SPEC.md | sort) \
  <(grep "^| AC-" .csp/test-spec/{module}/TEST-MODULE-SPEC.md | sort)
```

**变更影响**：
- PMS 新增 AC → TMS 新增一行映射 + 未实现测试用例
- PMS 修改 AC（语义变化）→ TMS 标记 `⚠️ AC CHANGED — 测试用例需更新`
- PMS 删除 AC → TMS 标记 `🗑️ AC REMOVED — 对应测试用例可清理或归档`

#### 1.5d: TMS→PMS 覆盖回写

测试用例实现后，回写 TMS 映射表状态：

```markdown
| AC-AUTH-1 | Given 有效凭证... | unit (happy) | `test_login_valid_credentials` | P0 | ✅ 已实现 |
```

**输出产物**：
```
.csp/test-spec/{module}/
├── TEST-MODULE-SPEC.md       # canonical baseline (含 AC→Test 映射表)
├── case-inventory.md          # 存量用例（入口×状态矩阵）
├── requirement-matrix.md      # 需求→方法 + 缺口清单
├── ac-test-mapping.md         # PMS AC→TMS 测试用例映射表（本步产出）
└── deltas/                    # 增量用例
```

把每条需求/验收标准映射到至少一种测试方法（参考 `csp-test-methodology` 谱系）：

```
requirement ──maps──▶ [test method(s)]
   R1 下单扣库存       → unit(扣减逻辑) + cross-layer(下单→DB stock delta)
   R2 余额不足拦截      → unit(校验) + negative(负数余额)
   R3 并发下单不超卖    → property(并发不变量) + integration(锁)
   R4 支付失败回滚订单  → cross-layer(回滚→DB 一致)  ← 若缺这条联动测试，R4 是"未测功能"
```

**缺口即风险清单**：未映射需求 = 没被任何测试覆盖 = 潜在功能缺失。

### Step 3: 生成存量用例（stock）

存量 = 当前模块已有的测试用例基线。按**矩阵式**组织（入口 × 状态），非单枚举值枚举：

| 规则 | 要求 |
|------|------|
| 矩阵组织 | 入口×状态组合，单枚举仅用于特殊分支 |
| 命名 | 「前提：[场景]-[行为]，[预期]」完整叙事句 |
| 入口追溯 | 以 CMS 入口点为入口维度（与 CR 蒸馏一致） |
| 状态组合 | 组合场景优先；每功能模块 ≥3 AC + 异常 ≥2 |
| 形态 | Given/When/Then，可证伪 |

输出 `case-inventory.md`（存量）与 `requirement-matrix.md`（追溯 + 缺口）。

### Step 4: 反割裂铁律（与 csp-test-methodology 一致）

1. 测了功能点 ≠ 测了联动效果 —— 写路径必有跨层联动一例。
2. 绿测试 ≠ 覆盖了需求 —— 用追溯矩阵找缺口。
3. 每种方法有盲点 —— 按盲点互补选组合，而非堆砌。
4. 广而快在前，慢而深在后 —— smoke/property/contract 先行，E2E/exploratory 收尾。

### Step 5: 生成 canonical TMS

输出到 `.csp/test-spec/{module}/`：

```markdown
# Test Module Spec — {Module}

**Version**: v1.0  **Date**: {date}  **Status**: Active
**Branch of**: PMS `{MOD-ID}` (inherits boundary + acceptance form)

## 1. 测试范围（继承 PMS 模块边界）
## 2. 需求→方法追溯矩阵（含缺口清单）
## 3. 存量用例清单（入口×状态矩阵）
## 4. 测试组合拳（按功能原型最小互补集）
## 5. 质量门（requirement coverage gate）
## 附录：用例变更历史
```

### Step 6: 增量用例（incremental delta）

变更落地时，只产出 delta 新触及的增量用例：

1. 读 `csp-prd-change-impact` 影响链 → 受影响的需求/入口。
2. diff 当前需求矩阵 vs 旧矩阵 → 新触及的入口×状态组合。
3. 只为新组合生成用例；存量未触及的不动。
4. delta 写入 `.csp/test-spec/{module}/deltas/`，里程碑折叠进 canonical。

**增量命名**：`{module}_增量_{变更ID}_用例`。

### Step 7: 质量自检

运行 TMS 质量自检（见 `references/test-spec-standard.md` §质量自检）。

## 输出产物

```
.csp/test-spec/{module}/
├── TEST-MODULE-SPEC.md      # canonical baseline
├── case-inventory.md         # 存量用例（入口×状态矩阵）
├── requirement-matrix.md     # 需求→方法 + 缺口清单
└── deltas/                    # 增量用例
```

## 门控检查

- [ ] 模块在 PMS 声明范围内（分支纪律）
- [ ] 每条 PMS 验收标准映射到 ≥1 TMS 测试用例（AC→Test 映射表 100% 覆盖）
- [ ] 每条需求映射到 ≥1 测试方法
- [ ] 缺口清单已列（未映射需求 = 风险）
- [ ] 存量用例矩阵式组织 + 叙事句命名
- [ ] 增量只覆盖 delta 新触及组合，未触及的不动
- [ ] 写路径有跨层联动一例（反割裂）
- [ ] 需求覆盖率门：未映射需求 = 0（或已登记风险）
- [ ] AC→Test 映射表含所有 PMS AC，状态标注（⬜ 待实现 / ✅ 已实现 / ⚠️ 需更新）

## 完成信号

```yaml
completion_signal:
  output: .csp/test-spec/{module}/TEST-MODULE-SPEC.md
  next_step:
    recommended: csp-qa-test-engineering   # 落地为可执行用例
    alternatives: [csp-qa-cr-review, csp-tdd, csp-verification]
  status:
    module: "{{module}}"
    stock_cases: "{{count}}"
    requirement_gaps: "{{count}}"
    phase: verify
    ready_for: [test-execution, cr-incremental-cases, regression]
```

## 与其他 Skill 的协作

| 下游 Skill | 读 TMS 的什么 | 写回 TMS 的什么 |
|-----------|---------------|-----------------|
| `csp-qa-test-engineering` | 存量 + 矩阵（落地为可执行用例） | 新增用例 delta |
| `csp-qa-cr-review` | 存量基线（CR 只输出增量） | 增量用例 |
| `csp-tdd` | 需求矩阵（先写可执行规约） | — |
| `csp-verification` | 需求覆盖率门 | — |
| `csp-prd-change-impact` | — | 变更触发增量生成 |
| `csp-test-methodology` | 方法谱系（TMS 引用其选方法） | — |

## Key Principles

- **TMS 是 PMS 的分支**：继承模块边界与验收形态，不发明模块。
- **living baseline**：存量 + 增量 delta，里程碑折叠，不推倒重来。
- **增量不重写**：只对 delta 新触及组合产出用例。
- **需求可追溯**：绿测试 ≠ 覆盖；缺口分析找未测功能。
- **反割裂**：矩阵式 + 联动一例，不只测功能点。
- **平台中立**：无内部域名/平台名；git + `CSP_GIT_REMOTE`。

## References

| 文件 | 内容 |
|------|------|
| `references/test-spec-standard.md` | TMS 说明书标准、存量/增量规则、矩阵组织、存量直通vs生成、来源互斥、结构化失败、质量自检 |
| `../references/module-spec-lifecycle-norms.md` | 全生命周期行为准则（PMS/CMS/TMS 共享） |
| `../references/module-spec-operational-protocol.md` | 运行时纪律（断点续跑、文件边界、契约优先、双重门禁、原子单元+退出码） |
| `../references/polling-watch-protocol.md` | 异步状态纪律：先查状态后查结果、watch 退出码、machine-readable contract、结构化错误、四易混维度 |
