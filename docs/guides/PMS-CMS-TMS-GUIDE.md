# PMS/CMS/TMS 使用指南

> 产品说明书 (PMS) → 代码说明书 (CMS) → 测试说明书 (TMS) 三位一体的使用手册。
> 覆盖绿地和棕地两种场景下的完整操作流程。

---

## 一、快速理解：三者是什么？

| 缩写 | 全称 | 一句话 | 存哪里 | 谁写 |
|------|------|--------|--------|------|
| **PMS** | Product Module Spec | 描述产品**要做什么**——模块、边界、验收标准 | `.csp/product-spec/` | 产品/Agent 从 PRD 生成 |
| **CMS** | Code Module Spec | 描述代码**怎么做的**——入口点、调用链、每个文件的功能 | `.csp/code-spec/{app}/` | Agent 从源码自动抽取 |
| **TMS** | Test Module Spec | 描述**怎么验证**——验收标准对应的测试用例 | `.csp/test-spec/{module}/` | Agent 从 PMS AC 映射 |

三者关系：
```
PMS（要做什么）──驱动──▶ CMS（怎么做的）──驱动──▶ TMS（怎么验证）
    ▲                                                │
    └────────── 对齐守卫：改了哪个，其他跟着更新了吗？ ◀──┘
```

---

## 二、场景 A：绿地项目（从零开始）

### Step 1: 初始化知识中枢

```bash
# 在你的项目根目录
cd your-project

# 告诉 Agent：
"初始化这个项目的知识中枢，按 CSP 的 PMS/CMS/TMS 结构来"
```

Agent 会：
1. 扫描项目结构（语言、框架、目录布局）
2. 创建 `.csp/` 目录骨架（AGENTS.md + manifest.json）
3. 询问项目名和应用名

### Step 2: 从 PRD 生成 PMS

```bash
"从 docs/prd/ 下的 PRD 文档生成 PMS（产品模块说明书）"
```

Agent 会：
1. 读取 PRD 文档
2. 拆解模块（用户旅程法 + 角色切分法）
3. 定义每个模块的验收标准（Given/When/Then 格式）
4. 生成代码脚手架清单（每个模块能力 → 对应哪些代码文件要创建）
5. 输出到 `.csp/product-spec/PRODUCT-MODULE-SPEC.md`

### Step 3: 开发代码

在 PMS 脚手架清单的指导下开发代码。PMS 已经告诉了你：
- 每个模块需要哪些文件
- 每个文件对应哪些功能
- 模块间依赖关系

### Step 4: 代码写完后 → 生成 CMS

```bash
"从代码生成 CMS 文档，包括每个文件的模块说明"
```

Agent 会从源码自动抽取（详见 `csp-code-spec` Step 2.5）：
- Python: 每个 class 的 docstring → class 文档，每个 method → method 文档
- TypeScript: 每个组件的 JSDoc → 组件文档，Props interface → 参数表
- Go: 每个包的文档注释 → 包文档

输出到 `.csp/code-spec/{app}/modules/`

### Step 5: 从 PMS 验收标准生成 TMS

```bash
"从 PMS 的验收标准生成测试用例映射表"
```

Agent 会：
1. 提取所有 Given/When/Then 验收标准
2. 自动分配测试方法（happy path → unit, reject → negative, display → E2E...）
3. 生成测试函数骨架代码
4. 建立 AC→Test 可追溯矩阵

### Step 6: 运行对齐检查

```bash
"检查 PMS/CMS/TMS 是否对齐"
```

Agent 会输出对齐报告，告诉你哪些地方不一致、如何修复。

---

## 三、场景 B：棕地项目（已有代码和文档）⭐

这是最常见的场景——你手上已经有一个正在运行的项目，有代码、可能有一些 PRD 文档、可能有一些测试，但三者在不同时期写的，彼此不一致。

### 棕地项目的三种起点

#### B1: 有代码，但没有结构化文档（最常见）

**你的指令**：

```bash
"这个项目已经有完整代码，但没有结构化文档。
请帮我：
1. 从现有代码生成 CMS（代码说明书）——扫描所有模块，生成每个文件的文档
2. 从代码中反推 PMS（产品说明书）——识别模块边界和业务规则
3. 从现有测试中梳理 TMS（测试说明书）——建立测试覆盖图
4. 三者生成完后运行对齐检查，告诉我哪里不一致"
```

**Agent 会做的**：

1. **代码 → CMS**（`csp-code-spec` Step 2.5）
   - 扫描所有 `.py`/`.tsx`/`.go` 文件
   - 提取 docstring、接口定义、组件 Props
   - 生成 `.csp/code-spec/{app}/modules/` 下的按文件文档
   - 标注哪些公开 API 缺少文档 `⚠️ MISSING DOCSTRING`

2. **代码 → PMS 反推**（`csp-code-spec` Step 4 → `csp-product-spec` Step 2）
   - 从代码的模块边界（目录/包结构）反推产品模块
   - 从业务规则代码（枚举、校验、状态机）提取业务规则
   - 生成 PMS 模块定义，标注 `[从代码反推，需确认]`
   - 识别 gap：代码有但 PMS 没声明的模块

3. **测试 → TMS 梳理**（`csp-test-spec`）
   - 扫描现有测试文件
   - 建立入口点→测试覆盖矩阵
   - 标注哪些入口点无测试覆盖 `⚠️ NO TEST COVERAGE`

4. **对齐检查**（`csp-knowledge-hub` Alignment Guard）
   - PMS↔CMS：模块边界是否一致
   - PMS↔TMS：验收标准是否覆盖
   - CMS↔TMS：代码入口点是否有测试
   - 输出对齐报告，列出所有不一致项

#### B2: 有 PRD + 代码，但 PRD 和代码可能不一致

**你的指令**：

```bash
"我有一批 PRD 文档在 docs/prd/ 下，代码在 src/ 下，但两者可能不一致。
请帮我：
1. 从 PRD 生成 PMS
2. 从代码生成 CMS
3. 对比 PMS 和 CMS，找出哪些 PRD 描述的功能在代码中缺失、哪些代码功能在 PRD 中没有记录
4. 生成对齐报告"
```

**Agent 会做的**：

1. PRD → PMS：按文档提取模块定义和验收标准
2. 代码 → CMS：按源码生成代码文档
3. 对齐对比：

```
PMS 有但 CMS 无 ──→ 🔴 PRD 写了但代码没实现（需求遗漏）
CMS 有但 PMS 无 ──→ 🟡 代码有但 PRD 没记录（文档缺失）
PMS 和 CMS 都有但不一致 ──→ 🟡 实现偏离了设计（需确认哪个是对的）
```

4. 输出差异报告，每条标注严重度和修复建议

#### B3: 三者都有，但需要验证一致性

**你的指令**：

```bash
"检查 PMS/CMS/TMS 的一致性，告诉我哪些不一致"
```

Agent 运行 `hub align-check`，输出对齐报告。

### 棕地对齐：Agent 的能力边界

| Agent 能自动做的 | Agent 需要你确认的 |
|-----------------|------------------|
| ✅ 从代码扫描生成 CMS | ⚠️ 从代码反推的 PMS 模块名需要你确认 |
| ✅ 从 PRD 提取 PMS | ⚠️ PRD 与代码不一致时，需要你决断以哪个为准 |
| ✅ 从测试文件梳理 TMS | ⚠️ 孤立的测试用例是否该删除 |
| ✅ 检测 PMS↔CMS↔TMS 不一致 | ⚠️ 两个模块声称同一功能时的归属裁决 |
| ✅ 生成对齐报告 | ⚠️ 修改 PRD 还是修改代码的决策 |
| ✅ 自动生成测试骨架 | ⚠️ 测试逻辑的填充 |

**关键原则**：Agent **检测问题、报告问题、建议修复**，但在有歧义的地方（PRD vs 代码到底哪个是对的），**必须由你做决策**。

---

## 四、日常使用流程

### 每次代码变更后

```bash
# 1. 更新 CMS（只处理变更文件）
"代码改完了，增量更新 CMS 文档"

# 2. 更新 TMS（如果新增了功能）
"新增的功能需要测试用例，更新 TMS"

# 3. 运行对齐检查
"检查 PMS/CMS/TMS 对齐"
```

### 每次 PRD 变更后

```bash
# 1. 更新 PMS
"PRD 改动了，更新 PMS delta"

# 2. 对齐检查
"PRD 改动影响了哪些代码和测试？检查对齐"
```

### 发版前

```bash
"发版前检查：PMS/CMS/TMS 全量对齐 + 测试覆盖 + 验收标准完备"
```

---

## 五、常用指令速查

| 你想要 | 对 Agent 说 |
|--------|------------|
| 初始化知识中枢 | "初始化 PMS/CMS/TMS 知识中枢" |
| 从 PRD 生成产品说明书 | "从 PRD 生成 PMS" |
| 从代码生成文档 | "从代码生成 CMS 模块文档" |
| 只生成变更文件的文档 | "增量更新 CMS，只处理 git diff 的文件" |
| 从验收标准生成测试 | "从 PMS 的 AC 生成 TMS 测试映射" |
| 检查三者是否对齐 | "检查 PMS/CMS/TMS 对齐" 或 "运行 align-check" |
| 只检查某个维度 | "检查 PMS 和 CMS 的模块边界是否对齐" |
| 看对齐报告 | "显示上次的对齐报告" |
| 修复对齐问题 | "修复对齐报告中标记的问题" |
| 棕地项目全量生成 | "从代码生成 CMS + 反推 PMS + 梳理 TMS + 对齐检查" |

---

## 六、输出产物速查

```
.csp/
├── AGENTS.md                          # Agent 路由契约
├── manifest.json                      # 唯一产物索引
│
├── product-spec/                      # ← PMS
│   ├── PRODUCT-MODULE-SPEC.md         #    产品模块说明书
│   ├── modules/MOD-{ID}.md            #    逐模块详情
│   ├── scaffolds/MOD-{ID}.md          #    每个模块的代码脚手架
│   └── deltas/                        #    变更历史
│
├── code-spec/{app}/                   # ← CMS  
│   ├── CODE-MODULE-SPEC.md            #    代码说明书
│   ├── entry-points.jsonl             #    入口点清单
│   ├── knowledge-graph.json           #    调用链图谱
│   ├── modules/                       #    按文件/模块的代码文档
│   │   ├── INDEX.md                   #    文档总索引
│   │   ├── auth_service_py.md         #    Python 模块文档
│   │   └── UserProfile_tsx.md         #    TS 组件文档
│   └── deltas/
│
├── test-spec/{module}/                # ← TMS
│   ├── TEST-MODULE-SPEC.md            #    测试说明书
│   ├── case-inventory.md              #    存量用例矩阵
│   ├── ac-test-mapping.md             #    AC→Test 映射表
│   ├── requirement-matrix.md          #    需求→方法追溯
│   └── deltas/
│
└── alignment-reports/                 # ← 对齐报告
    └── align-{timestamp}.md
```