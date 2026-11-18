---
name: csp-product-spec
description: "Product Module Spec (PMS / 产品说明书). The living, versioned baseline that governs PRD generation quality for a product. Defines module decomposition, boundaries, and the acceptance standard every PRD must meet. Also bridges PMS to code: each module definition maps to the code entry points that need to exist (scaffolding checklist). Downstream skills read it before producing their own artifacts."
version: "1.0.0"
layer: 2
category: workflow
phase: define
domain: architecture
scope: design
role: architect
tools: [Read, Write, Edit, Glob, Grep, Bash]

dependencies:
  skills: []

related_skills:
  - csp-prd-generation
  - csp-prd-parser
  - csp-prd-traceability
  - csp-prd-change-impact
  - csp-requirement-decomposition
  - csp-code-spec
  - csp-test-spec
  - csp-lifecycle-orchestrator
  - csp-domain-driven-design
  - csp-user-story-decomposition
  - csp-requirement-prioritization
  - csp-competitive-analysis
  - csp-product-discovery-orchestrator
  - csp-roadmap-update
  - csp-product-pulse
  - csp-product-metrics-review
  - csp-user-feedback-analysis
  - csp-strategy
  - csp-effort-estimation
  - csp-tech-risk-assessment
  - csp-doc-lifecycle-manager
  - csp-project-doc-architect
  - csp-brainstorming
  - csp-interview-me

triggers:
  keywords: ["产品说明书", "产品基线", "需求基线", "PMS", "product module spec",
             "module spec", "模块边界", "产品模块规格", "需求质量基线", "product baseline",
             "产品规格书", "模块说明书"]
  intents:
    - "user wants a living product baseline that governs PRD quality"
    - "user needs module decomposition + boundaries before writing PRDs"
    - "user wants a versioned source of truth for product modules across iterations"
  context:
    - "new_product"
    - "module_decomposition_needed"
    - "prd_quality_gate"

anti_rationalizations:
  "每个 PRD 自己写就行，不需要产品基线": "没有基线，PRD 之间模块边界打架、验收标准漂移、迭代间无法对齐。PMS 是 PRD 质量的决定因素，不是可选文档。"
  "PMS 写一次就不用再动": "PMS 是 living baseline，每次模块变更以 delta 形式增量更新，迭代间折叠进 canonical。写完就忘 = 基线失效。"
  "模块边界可以边写 PRD 边定": "边界事后定 = 跨模块需求冲突、重复实现、职责重叠。必须先定边界再写 PRD。"
  "PMS 直接写技术实现": "PMS 描述 WHAT 与边界，不描述 HOW（不写 DB/语言/框架）。技术细节归 CMS 与 feature spec。"
---

# Product Module Spec (PMS) — 产品说明书

> **定位:** PMS 是产品级的 *living baseline*，定义模块分解、模块边界、验收标准形态。
> 它是所有 PRD 生成的基线，**决定需求文档的生成质量**。下游 `csp-prd-generation` /
> `csp-requirement-decomposition` / `csp-prd-traceability` / `csp-prd-change-impact`
> 在产出自身产物前先读 PMS，模块上线后以 delta 写回。
>
> **与单个 PRD 的区别:** PRD 描述一个功能的 WHAT；PMS 描述整个产品的模块地图与质量门，
> PRD 必须落在 PMS 声明的某个模块内、满足 PMS 的验收形态。

## When to Use

- 新产品 / 新模块族从零启动，需要先定模块地图再写 PRD
- 多个 PRD 并行，需要统一边界与验收标准防止漂移
- 迭代演进，需要一条 living baseline 让每次变更以 delta 增量而非推倒重来
- 需要给 PRD 生成、需求拆解、追溯矩阵、变更影响分析提供"模块层"基线

## When NOT to Use

- 单个功能的 PRD 生成（用 `csp-prd-generation`，但它会读 PMS）
- 技术方案 / 全栈 spec（用 `csp-tech-solution-design` / `csp-fullstack-spec-generator`；技术细节归 CMS）
- 一次性脚本，无迭代诉求

## Process

### Step 1: 装载上下文

读项目约定与既有产物，判定是新建还是增量：

| 检查 | 命中则 |
|------|--------|
| `.csp/product-spec/PRODUCT-MODULE-SPEC.md` 存在 | 增量模式 → Step 6（delta） |
| `docs/prd/PRD-*.md` 或 `.csp/prd-ir/PRD-IR.json` 存在 | 作为输入抽取既有模块 |
| 无任何既有产物 | 全新模式 → Step 2 |

读取顺序：`CLAUDE.md` → `README.md` → `docs/prd/` → `.csp/decomposition/`。

### Step 2: 模块分解

把产品拆成一组高内聚、低耦合的模块。三法并用：

1. **用户旅程法** — 映射用户从进入到达成目标的完整路径，关键节点聚类成模块。
2. **角色切分法** — 列出所有角色（终端用户 / 管理员 / 运营 / 平台方），每个角色的操作域是一个模块候选。
3. **领域驱动 (DDD)** — 识别限界上下文 (bounded context)，每个上下文一个模块。

每个模块必须给出：

| 字段 | 要求 |
|------|------|
| 模块 ID | `MOD-{domain}-{seq}`，如 `MOD-AUTH-1` |
| 模块名 | 名词短语，非动词 |
| 职责 | 一句话：做什么 + 不做什么（边界） |
| 对外能力 | 该模块对外暴露的能力清单（capability，非 API） |
| 依赖 | 依赖哪些其它模块（方向必须单向，无环） |
| 负责角色 | Owner / 角色 |
| 优先级 | P0 核心 / P1 重要 / P2 增强 |

### Step 3: 定义模块边界与交互契约

- 每个模块写明 **职责边界**：哪些能力属于本模块、哪些明确不属于。
- 模块间交互用 **能力契约** 描述（"模块 A 依赖模块 B 的 X 能力"），不写具体 API/协议。
- 边界冲突判定：同一能力被两个模块声称 → 必须裁决归属，记录决策。

### Step 4: 定义验收标准形态（PRD 质量门）

PMS 决定 PRD 质量，靠的是规定"验收标准长什么样"，而不是替 PRD 写验收：

```yaml
acceptance_standard:
  form: "Given [context], When [action], Then [verifiable result]"
  rules:
    - 必须可证伪：pass/fail 明确，禁止"体验良好""支持完善"
    - 每个功能模块 ≥3 条 AC
    - 异常场景 ≥2 条
    - 数据埋点：核心操作路径必须有 tracking event
    - 优先级显式：P0/P1/P2 标注
  forbidden_in_prd:
    - 技术实现（DB 类型、语言、框架）
    - UI 细节（颜色、字号、布局）
    - 模糊量词（"等""其它情况""必要时"）
  coverage_gate:
    prd_to_module: 100%        # 每个 PRD 必须落在某个 PMS 模块内
    module_to_owner: 100%      # 每个模块必须有 owner
```

### Step 4: PMS→代码脚手架翻译桥（PMS-to-Code）

PMS 定义"要做什么"（WHAT）——本步把每个模块翻译成开发者可直接行动的**代码脚手架清单**，
告诉开发者需要创建/修改哪些文件、哪些入口点、哪些接口。

#### 4a: 模块→入口点映射

对 PMS 的每个模块，推断它需要的代码入口点：

| PMS 模块能力 | → 代码入口点类型 | → 示例文件位置 |
|-------------|----------------|--------------|
| "用户可登录" | HTTP POST endpoint | `src/api/auth.py` → `POST /auth/login` |
| "管理员可查看用户列表" | HTTP GET endpoint + 权限守卫 | `src/api/admin.py` → `GET /admin/users` |
| "下单后扣库存" | Service 层方法 | `src/services/order.py` → `def create_order()` |
| "库存不足发通知" | 消息队列 consumer | `src/consumers/notification.py` |
| "每日数据报表" | 定时任务 | `src/cron/daily_report.py` |
| "前端用户注册页" | React 路由 + 组件 | `src/pages/Register.tsx` |
| "前端商品列表" | React 组件 + API client | `src/components/ProductList.tsx` |

**纪律**：
- 每个 PMS 模块能力 → **至少一个代码入口点**（入口点 = HTTP endpoint / RPC method / CLI command / React route / 定时任务）
- 不能直接映射的标 `[待技术设计确定]`
- 跨模块依赖 → 标注 `import dependency`（模块 A 的代码会 import 模块 B 的接口）

#### 4b: 输出代码脚手架清单

为每个 PMS 模块生成一份 **代码脚手架清单**，写入 `.csp/product-spec/scaffolds/{MOD-ID}.md`：

```markdown
# Code Scaffold — MOD-AUTH-1 用户与权限

**PMS 模块**: MOD-AUTH-1
**CMS 对应**: `code-spec/auth-svc/`
**状态**: 待开发 / 已有代码需对齐 / 代码已完成

## 需要创建/确认的代码

### 后端 (Python/FastAPI)

| 文件 | 内容 | PMS 能力映射 | 优先级 |
|------|------|------------|--------|
| `src/api/auth.py` | POST /auth/login — 用户登录接口 | "用户可登录" | P0 |
| `src/api/auth.py` | POST /auth/register — 用户注册接口 | "新用户注册" | P0 |
| `src/api/auth.py` | POST /auth/refresh — Token 刷新 | "会话续期" | P1 |
| `src/services/auth_service.py` | `class AuthService` — 认证逻辑 | "登录验证" | P0 |
| `src/models/user.py` | `class User(BaseModel)` — 用户模型 | "用户数据结构" | P0 |
| `src/middleware/auth.py` | `AuthMiddleware` — 权限中间件 | "访问控制" | P0 |

### 前端 (React/TypeScript)

| 文件 | 内容 | PMS 能力映射 | 优先级 |
|------|------|------------|--------|
| `src/pages/Login.tsx` | 登录页面组件 | "用户可登录" | P0 |
| `src/pages/Register.tsx` | 注册页面组件 | "新用户注册" | P0 |
| `src/hooks/useAuth.ts` | 认证状态管理 hook | "用户登录状态" | P0 |
| `src/api/auth.ts` | API client — auth endpoints | "前后端通信" | P0 |

### 模块间依赖

| 当前模块需要 | 依赖模块 | 接口 |
|------------|---------|------|
| 登录后跳转 | MOD-WORKSPACE-1 | workspace 入口路由 |
| 权限校验 | MOD-AUTH-1 (自身) | AuthMiddleware |

## 验收检查

- [ ] 每个 PMS 能力对应至少一个代码入口点文件
- [ ] 跨模块依赖已标注 import 方向
- [ ] CMS 代码抽取生成的模块文档能回链到此 scaffold
```

#### 4c: PMS 变更→代码影响分析

当 PMS 模块变更（新增能力、修改边界），触发代码影响评估：

```bash
# 比较 PMS delta 与当前 CMS 入口点清单
diff <(grep "PMS 能力映射" .csp/product-spec/scaffolds/*.md | sort) \
     <(grep "业务场景" .csp/code-spec/{app}/entry-points.jsonl | sort)
```

**影响类型**：
- PMS 新增能力 + 代码无对应入口 → 🟡 **需新建代码**
- PMS 删除能力 + 代码仍有入口 → 🔴 **需清理死代码**
- PMS 边界变更 + 代码入口归属不匹配 → 🟡 **需调整模块归属**

#### 4d: 从脚手架启动 CMS

PMS 脚手架完成后，CMS 使用入口点清单启动代码蒸馏：

```
PMS scaffold ──entry-points──▶ CMS Step 2 (入口点蒸馏)
                                       │
                                       ▼
                               CMS Step 2.5 (代码文档抽取)
```

**CMS 蒸馏时**，对 PMS scaffold 中列出的每个文件进行代码文档抽取，生成的模块文档回链到 PMS 模块 ID（`source-pms: MOD-AUTH-1`），形成双向可追溯。

输出到 `.csp/product-spec/`：

```markdown
# Product Module Spec — {Product Name}

**Version**: v1.0  **Date**: {date}  **Status**: Active
**Tech-agnostic**: 本文档只描述 WHAT 与边界，不含技术实现。

## 1. 产品定位
（为何做、不做的后果、做的收益 — 三问）

## 2. 模块地图（Mermaid）
graph LR
    MOD-AUTH --> MOD-DOC
    MOD-AUTH --> MOD-SEARCH

## 3. 模块清单
### MOD-AUTH-1 用户与权限
- 职责：...
- 对外能力：...
- 依赖：无
- Owner：...

## 4. 模块边界与交互契约
| 模块 A | 依赖 | 模块 B 的能力 | 契约形态 |

## 5. 验收标准形态（PRD 质量门）
（见 Step 4 的 acceptance_standard）

## 6. 覆盖门控
（prd_to_module / module_to_owner 目标值）

## 附录：模块变更历史
```

### Step 6: 增量更新（delta 模式）

模块变更以 delta 形式记录在 `.csp/product-spec/deltas/`，里程碑归档时折叠进 canonical：

```markdown
## ADDED Module
### MOD-PAY-1 支付
（完整模块定义）

## MODIFIED Module
### MOD-AUTH-1 用户与权限
（粘贴完整原文，再编辑 —— 禁止部分修改）

## REMOVED Module
### MOD-LEGACY-1 旧导出
**Reason:** 被 v2 替代
**Migration:** 使用新导出能力
```

### Step 7: 质量自检

运行 PMS 质量自检（见 `references/product-spec-standard.md` §质量自检），任何一项不过给出修复建议。

## 输出产物

```
.csp/product-spec/
├── PRODUCT-MODULE-SPEC.md      # canonical baseline
├── modules/{MODULE}.md          # 逐模块详情
├── scaffolds/                   # PMS→代码脚手架（Step 4）
│   └── {MOD-ID}.md              # 每个模块的代码入口点清单
└── deltas/                      # ADDED/MODIFIED/REMOVED
```

## 门控检查

- [ ] 每个模块有职责 + 边界 + 对外能力 + owner
- [ ] 模块依赖图无环
- [ ] 验收标准形态已定义（Given/When/Then + 禁止项）
- [ ] PRD 覆盖门：每个 PRD 可映射到某个 PMS 模块
- [ ] 每个 PMS 模块能力对应至少一个代码入口点（scaffold）
- [ ] 跨模块代码依赖已标注 import 方向
- [ ] delta 增量遵守 ADDED/MODIFIED/REMOVED 纪律
- [ ] 无技术实现细节（tech-agnostic）

## 完成信号

```yaml
completion_signal:
  output: .csp/product-spec/PRODUCT-MODULE-SPEC.md
  next_step:
    recommended: csp-prd-generation   # 在 PMS 基线内生成 PRD
    alternatives: [csp-requirement-decomposition, csp-test-spec]
  status:
    module_count: "{{count}}"
    phase: define
    ready_for: [prd-generation, requirement-decomposition, test-spec-seed]
```

## 与其他 Skill 的协作

| 下游 Skill | 读 PMS 的什么 | 写回 PMS 的什么 |
|-----------|---------------|-----------------|
| `csp-prd-generation` | 模块边界 + 验收形态 | 新模块 delta |
| `csp-requirement-decomposition` | 模块清单（不得越界） | 新模块 delta |
| `csp-prd-traceability` | 模块层追溯起点 | — |
| `csp-prd-change-impact` | 模块依赖图（影响传播） | delta |
| `csp-test-spec` | 模块边界 + 验收形态（TMS 是 PMS 的分支） | — |
| `csp-code-spec` | 模块边界（代码归属对齐）+ **消费 scaffolds/ 作为入口点清单** | — |

## Key Principles

- **PMS 只描述 WHAT 与边界**，不写 HOW（不写 DB/语言/框架）。技术细节归 `csp-code-spec` 与 feature spec。
- **PMS 是 living baseline**：增量 delta，迭代间折叠，不推倒重来。
- **不臆造**：用户未给的业务数据标 `[TBD]`，绝不编造。
- **平台中立**：无内部域名/平台名；远程协作走 git + 可配置 remote（`CSP_GIT_REMOTE`，默认 `github.com`）。

## References

| 文件 | 内容 |
|------|------|
| `references/product-spec-standard.md` | PMS 说明书标准、模块定义模板、验收形态、Spec 类型约束(layout/workflow/data/i18n/metrics)、virtual_page、质量自检表 |
| `references/pms-node-schema.md` | PMS 节点协议：五层架构、R1-R5 抽取、五 archetype、page→module→action JSON schema 形态、D 校验门 |
| `../references/code-to-spec-extraction.md` | 代码→产品规格萃取：6 类信号、sanitizer 黑名单、前后端融合（enrich 用） |
| `../references/module-spec-lifecycle-norms.md` | 全生命周期行为准则（PMS/CMS/TMS 共享，定义每个阶段 Agent 规范） |
| `../references/module-spec-operational-protocol.md` | 运行时纪律（断点续跑、文件边界、契约优先、双重门禁+判官、防臆造输入、原子单元） |
