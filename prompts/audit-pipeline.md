# 全链路审计编排器（Audit Pipeline Orchestrator）

> **定位**：独立于 00–07 链路（与 audit / feature-gap / critic 同级），将六份独立审查提示词按去重顺序串联为一次全链路审计——**编排器只做路由、聚合、去重裁决，不做具体审查**（审查方法论全在各提示词内部，编排器不重复嵌入）。存量仓库"深挖问题 → 修复 → 上线"的发现层一键入口。
>
> **这是编排器，不是审查方法论。** 六步各自的方法论、检查清单、设计判定卡（M1–M8）、Nielsen 10 速查等均在对应提示词文件中，编排器只声明"调哪份提示词、产什么、上下游谁消费、不重复跑什么"。如果你在找具体怎么审某个维度，去读对应的提示词文件，别在本文件里找。

---

## Pipeline 总览

```
 Step 1               Step 2               Step 3               Step 4              Step 5              Step 6
 audit.md        e2e-deep-audit.md   ui-review-to-           product-critic-     feature-gap-        product-audit-to-
 工程体检          实机验证             iteration.md           review.md           analysis.md         roadmap.md
                                      UI/UX 八镜头           产品总监七镜头        单模块缺口深潜       聚合交棒 roadmap
    │                   │                   │                    │                   │                   │
    ├─ 模块化           ├─ 全路由 sweep     ├─ 视觉层级/布局      ├─ 重复冗余(A)       ├─ F1-F12 通用面    ├─ 四角度审查
    ├─ Nielsen 10       ├─ 按钮点击审计     ├─ 交互模式/反馈      ├─ 信息架构(B)       ├─ U1-U7 UI维度     ├─ 主题候选提炼
    ├─ 四层联动测试     ├─ 孤儿路由确认     ├─ IA/导航(M7引用)    ├─ 视觉交互一致(C)    ├─ 领域增强目录      ├─ Phase 2.5审视
    └─ 裁决报告         └─ 结构健康核查     └─ 版本迭代路线图      └─ (D-G七镜头)       └─ 联动检查          └─ 交棒清单
```

**去重契约**：六步走同一批模块/页面，各审各的维度，互不重复——每步有明确的"主跑项"和"引用项"。谁主跑谁出 finding；引用方只读上游 finding ID 做交叉引用，不重复报同一问题。

---

## 一、红线

1. **编排器不改代码不发版**：六步均只产审查 + 建议；P0 findings 标 `快速修复=true` → 直发 04 拆 fix task → 05 → 06（quick-fix 跳过 roadmap/01，不跳 04/05/06）。
2. **去重即契约**：每步主跑归属不可越界重跑；引用上游结论时附 finding ID 指针（`AUDIT-F-NN` / `UI-F-NN` / `CRITIC-F-NN` / `GAP-F-NN`）。
3. **禁止降级审计**：工具/浏览器不可用 → 报 BLOCKED + 停手 + 重试，不产出降级报告。
4. **留尾纪律**：findings 只能 `open` / `BLOCKED`（附阻塞+谁解除）/ `deferred`（附解除条件）。
5. **产品 sense rationale 必填**（Step 3/4/5）：不止说"不一致/重复"，要论证对用户认知/效率/信任/产品定位的具体伤害。
6. **证据先于断言**：每条 finding 带 `file:line` / 截图 / 路由 / 命令输出；"应该/大概/看着"即停。

---

## 二、触发与路由

**触发词**：全链路审计 / audit pipeline / 六步审计 / 全面体检 / 深挖问题修复上线

- **全量（默认）**：从路由表 + `.csp/product-spec/` + `.csp/code-spec/entry-points.jsonl` + `docs/FEATURES.md` 自动枚举全部模块 → Step 1–6 全跑。
- **增量**：已跑过 → 读既有 findings（`AUDIT-F`/`UI-F`/`CRITIC-F`/`GAP-F`），只审 delta + 状态变化。
- **知识中枢前置**：`.csp/AGENTS.md` 不存在 → 提示先跑 00。

---

## 三、前置准备（Step 0.x，进入 Step 1 前必须完成）

### Step 0.0 — 运行时模式检测

```bash
# Agent 工具是否可用
AGENT_AVAILABLE=true
SUBAGENT_FILES=$(ls ~/.claude/agents/*.md 2>/dev/null | wc -l)
if [ "$SUBAGENT_FILES" -eq 0 ]; then AGENT_AVAILABLE=false; fi
```

| 模式 | 条件 | 执行方式 |
|------|------|---------|
| **标准模式** | Agent 工具可用 + subagent 定义存在 | 每步深度分析由 subagent 承载，主 agent 做路由聚合 |
| **Fallback 模式** | 上述任一不满足 | 主 agent 串行执行全部 Step，须遵守 Fallback 完整性门控（见 §十） |

**模式声明（强制输出）**：
```
🔍 运行时检测: Agent 工具={可用/不可用} | Subagent 定义={N 个/缺失} | 模式={标准/Fallback}
```

### Step 0.5 — 环境自检 + 会话重建

```bash
# 基础设施探活
pg_isready -h localhost -p 5432 2>/dev/null && echo "DB: OK" || echo "DB: DOWN"
redis-cli ping 2>/dev/null && echo "Redis: OK" || echo "Redis: DOWN"

# 后端健康检查（按健康检查路径+响应体确认，不凭端口号认）
BACKEND_URL=$(grep -r 'NEXT_PUBLIC_API_URL\|VITE_API_URL\|API_BASE' .env* 2>/dev/null | head -1 | cut -d= -f2)
curl -sf "${BACKEND_URL}/health" 2>/dev/null && echo "Backend: OK" || echo "Backend: DOWN"

# 前端 dev server
curl -sf "http://localhost:3000" 2>/dev/null && echo "Frontend: OK" || echo "Frontend: DOWN"
```

**一键起栈**（任一 DOWN 时）：
```bash
docker compose up -d 2>/dev/null || echo "No docker-compose.yml"
npx playwright test tests/e2e/auth.setup.ts --project=setup 2>/dev/null
```

**会话有效性检查**：
```bash
if [ -f "tests/e2e/.auth/auth.json" ]; then
  EXPIRY=$(node -e "const s=require('./tests/e2e/.auth/auth.json'); console.log(s.cookies?.[0]?.expires||'unknown')" 2>/dev/null)
  echo "Auth expiry: $EXPIRY"
else
  echo "No auth state found — run auth.setup.ts first"
fi
```

**强制输出**：
```
🔧 环境自检: DB={OK/DOWN} | Backend={OK/DOWN} | Frontend={OK/DOWN} | Auth={VALID/EXPIRED/MISSING}
   → 全绿 → 继续 Step 1
   → 有 DOWN → 尝试一键起栈
   → 起栈失败 → 登记 BLOCKED，不静默跳过 E2E 相关步骤
```

### Step 0.6 — 既有 findings 基线回读

```bash
echo "# PRIOR-FINDINGS-BASELINE $(date +%Y-%m-%d)" > .csp/audit/PRIOR-FINDINGS-BASELINE.md
for dir in .csp/audit .csp/ui-review .csp/critic .csp/gap-analysis .csp/review; do
  if [ -d "$dir" ]; then
    echo "## ${dir}" >> .csp/audit/PRIOR-FINDINGS-BASELINE.md
    for f in "$dir"/*FINDINGS*.json; do
      [ -f "$f" ] && echo "- $(basename $f): $(jq '.findings | length' "$f" 2>/dev/null || echo '?') findings" >> .csp/audit/PRIOR-FINDINGS-BASELINE.md
    done
  fi
done
```

**强制输出**：
```
📋 既有 findings 基线: AUDIT-F N 条 | UI-F N 条 | CRITIC-F N 条 | GAP-F N 条 | REV-F N 条
   → Step 1–5 审查时：已有登记的不重复报，只报状态变化
```

### Step 0.8 — 自动化门禁快照

```bash
python scripts/validate_gates.py --json > .csp/audit/GATE-SNAPSHOT-{date}.json 2>&1
python scripts/validate_gates.py   # 人类可读摘要
```

> 9 个门禁映射五类根因 Pattern A–E。`verdict == "BLOCKED"` → 成为 Step 1–5 优先审查目标。脚本不存在 → 标 SKIPPED，降级人工检查但声明"无机器证据"。

---

## 四、六步编排

### Step 1 — 工程结构体检

| 项 | 值 |
|----|-----|
| **调用** | `prompts/audit.md`（Phase 0–7 全量） |
| **角色** | 模块化审计 + Nielsen 10 可用性 + 四层联动测试 + 裁决报告 |
| **产出** | `.csp/audit/MODULE-LIST-{milestone-slug}.md` / `USABILITY-REPORT-{module}.md`（逐模块） / `AUDIT-VERDICT-{milestone-slug}.md` / `AUDIT-FINDINGS-{milestone-slug}.json` / `docs/analysis/AUDIT-SUMMARY-{milestone-slug}.md` |
| **前缀** | `AUDIT-F-NN` |

**主跑项**（后续步骤引用，不重跑）：
- Nielsen 10 可用性 Mode A/B + 状态覆盖
- 模块化拆解 + 联动四层测试
- 结构审计只标"疑似"孤儿路由/隐藏后端/死按钮 → 交 Step 2 实机确认

### Step 2 — 实机验证

| 项 | 值 |
|----|-----|
| **调用** | `prompts/e2e-deep-audit.md`（M4 深度审计） |
| **角色** | 全路由 sweep + 按钮级点击审计 + 孤儿路由确认 + 结构健康核查 |
| **产出** | `verify/ui-test-report.md` / `verify/evidence/`（截图等四类证据） / `gap-analysis/GAP-REPORT-*.md`（结构性 gap 登记） / `/tmp/button_audit*.jsonl`（按钮审计流式记录） |
| **前缀** | 无独立前缀（结构 findings 被下游引用） |

**主跑项**（后续步骤引用，不重跑）：
- 全路由 sweep + 按钮级点击审计
- 消费 Step 1 "疑似"线索 → 实机确认孤儿/隐藏/死按钮
- 结构健康核查（schema drift / tsc / mock 债务）

### Step 3 — UI/UX 设计总监审查

| 项 | 值 |
|----|-----|
| **调用** | `prompts/ui-review-to-iteration.md`（八镜头 + 版本迭代路线图） |
| **角色** | 视觉层级/交互模式/一致性/用户习惯/响应式/可访问性/状态覆盖 |
| **产出** | `.csp/ui-review/UI-REVIEW-REPORT-{date}.md` / `UI-FINDINGS-{date}.json` / `CROSS-MODULE-UI-{date}.md` / `docs/analysis/UI-VERSION-PLAN-{date}.md` / `docs/analysis/UI-TO-ROADMAP-{date}.md` |
| **前缀** | `UI-F-NN` |

**主跑项**：镜头 1 视觉层级（M1）、镜头 2 交互模式（M2）、镜头 4 一致性（M5 Token 漂移对照表）、镜头 5 用户习惯、镜头 6 响应式（M3）、镜头 7 可访问性（M6）

**引用项**（不重跑）：镜头 3 IA → 引用 Step 2 结构 findings；镜头 8 状态覆盖 → 引用 Step 1 AUDIT-F

### Step 4 — 产品总监批评性审查

| 项 | 值 |
|----|-----|
| **调用** | `prompts/product-critic-review.md`（七镜头 + 跨模块聚合） |
| **角色** | 重复冗余/信息架构/一致性/用户习惯/定位/完整性/状态覆盖 |
| **产出** | `.csp/critic/PRODUCT-CRITIC-REPORT-{date}.md` / `CRITIC-FINDINGS-{date}.json` / `CROSS-MODULE-{date}.md` / `.csp/critic/recon-{slug}.md`（逐模块现状重建） / `docs/analysis/CRITIC-SUMMARY-{date}.md` / `docs/analysis/CRITIC-TO-ROADMAP-{date}.md` |
| **前缀** | `CRITIC-F-NN` |

**主跑项**：镜头 A 重复与冗余（A1–A5）、镜头 B IA 散乱裁决、镜头 E 宏观定位、跨模块聚合

**引用项**（不重跑）：镜头 C/D 视觉交互一致性 → 引用 Step 3 UI-F；镜头 F/G 可用性违例 → 引用 Step 1 AUDIT-F

### Step 5 — 单模块缺口与增强深潜

| 项 | 值 |
|----|-----|
| **调用** | `prompts/feature-gap-analysis.md`（全界面自动巡检） |
| **角色** | 通用面 F1–F12 + UI 维度 U1–U7 + 领域增强目录 + 联动检查 |
| **产出** | `.csp/gap-analysis/SCAN-LIST-{date}.md` / `.csp/gap-analysis/GAP-REPORT-{slug}.md`（逐模块） / `GAP-FINDINGS-{slug}.json`（逐模块） / `.csp/gap-analysis/recon-{slug}.md`（逐模块现状重建） / `.csp/gap-analysis/CROSS-MODULE-UI-{date}.md` / `.csp/gap-analysis/GAP-FINDINGS-_aggregate.json`（统一 findings） / `docs/analysis/GAP-SUMMARY-{slug}.md` / `docs/analysis/GAP-TO-ROADMAP-{slug}-{date}.md` |
| **前缀** | `GAP-F-NN` |

**主跑项**：F1–F12 通用面（功能缺口部分）、领域增强目录、Phase 4 联动

**引用项**（不重跑）：U1–U7 UI 维度 → 引用 Step 3 UI-F；F2/F5 状态覆盖/a11y → 引用 Step 1 AUDIT-F + Step 3 UI-F

### Step 6 — 产品演进交棒

| 项 | 值 |
|----|-----|
| **调用** | `prompts/product-audit-to-roadmap.md`（四角度 + 主题提炼 + 集成必要性审视） |
| **角色** | 聚合 Step 1–5 全部 findings → 主题候选 → roadmap |
| **产出** | `docs/audit/PRODUCT-AUDIT-{date}.md` / `REVIEW-FINDINGS-{audit-slug}.json`（前缀 `AUDIT-F-NN` 同族） / `docs/analysis/AUDIT-TO-ROADMAP-{date}.md` |
| **前缀** | `AUDIT-F-NN`（同族） |

**输入**：聚合 AUDIT-F / UI-F / CRITIC-F / GAP-F 全部 findings，按前缀路由来源。

> ⚠️ Step 3 的 `docs/analysis/UI-VERSION-PLAN-{date}.md` 直接作为 UI 主题候选输入。

---

## 五、去重契约

| 审查维度 | 主跑方 | 引用方（不重跑） |
|---------|--------|-----------------|
| **Nielsen 10 可用性 + 状态覆盖** | Step 1 audit（Phase 4 Mode A/B） | Step 3 镜头 7/8、Step 4 镜头 F/G |
| **结构审计（孤儿/隐藏/死按钮）** | Step 2 e2e（L4 实机确认） | Step 1 只标疑似、Step 3 镜头 3、Step 4 镜头 B、Step 5 Phase 4 |
| **视觉层级与布局（M1）** | Step 3 ui-review 镜头 1 | Step 4 镜头 C、Step 5 U3/U5 |
| **交互模式与反馈（M2）** | Step 3 ui-review 镜头 2 | Step 4 镜头 C/D、Step 5 U4 |
| **Token 漂移对照（M5）** | Step 3 ui-review 镜头 4 | Step 4 镜头 C、Step 5 U3 |
| **可访问性 a11y（M6）** | Step 3 ui-review 镜头 7 | Step 5 F5 |
| **响应式（M3）** | Step 3 ui-review 镜头 6 | Step 5 U7 |
| **模块散乱判归属（M7）** | Step 4 critic 镜头 A/B 聚合 | Step 3 镜头 3、Step 5 U2 只记"疑似" |
| **功能缺口（F1–F12 + 领域目录）** | Step 5 gap | Step 4 镜头 F 引用可用性部分 |
| **产品定位对齐 + 北极星** | Step 4 critic 镜头 E | Step 5 U1 |

> 引用时附 finding ID 指针（如 `AUDIT-F-NN` 见 `.csp/audit/AUDIT-FINDINGS-{milestone-slug}.json`），不自行重跑同一维度。

---

## 六、Finding 前缀路由

| 来源 | 前缀 | 焦点 | 主要产物文件 |
|------|------|------|------------|
| Step 1 audit | `AUDIT-F-NN` | 工程结构 / 可用性 / Nielsen | `.csp/audit/AUDIT-FINDINGS-{milestone-slug}.json` |
| Step 2 e2e | — | 实机验证（被下游引用） | `verify/ui-test-report.md` |
| Step 3 ui-review | `UI-F-NN` | UI/UX 八镜头 | `.csp/ui-review/UI-FINDINGS-{date}.json` |
| Step 4 critic | `CRITIC-F-NN` | 产品批评（重复/散乱/定位） | `.csp/critic/CRITIC-FINDINGS-{date}.json` |
| Step 5 gap | `GAP-F-NN` | 功能缺口与增强 | `.csp/gap-analysis/GAP-FINDINGS-{slug}.json` + `GAP-FINDINGS-_aggregate.json` |
| Step 6 product-audit | `AUDIT-F-NN`（同族） | 聚合交棒 | `docs/audit/REVIEW-FINDINGS-{audit-slug}.json` |

> ⚠️ **已知不一致**：Step 6 的 `product-audit-to-roadmap.md` 自身产出文件名为 `REVIEW-FINDINGS-{audit-slug}.json`（含 `REVIEW` 字样），但其内部 finding 前缀声明为 `AUDIT-F-NN` 同族。这是上游提示词的历史遗留问题——编排器按前缀路由消费，不受文件名影响。

---

## 七、并行优化

| Wave | 步骤 | 依赖关系 |
|------|------|---------|
| **Wave 1** | Step 1 + Step 2 并行 | 互不阻塞（静态 vs 实机） |
| **Wave 2** | Step 3 | barrier：等 Step 1 + Step 2 完成 |
| **Wave 3** | Step 4 + Step 5 并行 | barrier：等 Step 3 完成；二者互不阻塞 |
| **Wave 4** | Step 6 | barrier：等 Step 4 + Step 5 完成 |

> ⚠️ Fallback 模式不适用并行——主 agent 串行按 Step 1→6 推进。

---

## 八、进度播报

**标准模式**（每步完成）：
```
📊 pipeline [Step i/6 {slug}] [就绪✓][主跑✓][去重引用✓][findings✓][交棒✓]
```

**六步全跑完**：输出总 findings 清单（按 AUDIT-F / UI-F / CRITIC-F / GAP-F + 跨模块重组批次分组，附产物路径）。

**Fallback 模式**（每步完成，含自检结论）：
```
📊 pipeline [Step i/6 {slug}] [模式:FALLBACK] [就绪✓][重建✓][深度分析✓][自检:PASS✓][交棒✓]
```

---

## 九、产物路径（逐步骤精确文件名）

```
# Step 1 — audit
.csp/audit/
├── MODULE-LIST-{milestone-slug}.md           # 模块清单（含 DB 模块）
├── USABILITY-REPORT-{module}.md              # 逐模块可用性报告
├── AUDIT-VERDICT-{milestone-slug}.md         # 裁决报告
├── AUDIT-FINDINGS-{milestone-slug}.json      # 结构化 findings（前缀 AUDIT-F-NN）
├── heuristic-scan-{milestone-slug}.txt       # 预扫描原始数据
└── PRIOR-FINDINGS-BASELINE.md                # Step 0.6 基线
docs/analysis/
└── AUDIT-SUMMARY-{milestone-slug}.md         # 人类可读摘要

# Step 2 — e2e-deep-audit
verify/
├── ui-test-report.md                         # 测试结论报告
└── evidence/                                 # 截图等四类证据
gap-analysis/
└── GAP-REPORT-*.md                           # 结构性 gap 登记（孤儿/隐藏/IA）
/tmp/
└── button_audit*.jsonl                       # 按钮审计流式记录

# Step 3 — ui-review
.csp/ui-review/
├── UI-REVIEW-REPORT-{date}.md                # 审查报告正文
├── UI-FINDINGS-{date}.json                   # 结构化 findings（前缀 UI-F-NN）
└── CROSS-MODULE-UI-{date}.md                 # 跨模块聚合裁决
docs/analysis/
├── UI-VERSION-PLAN-{date}.md                 # 版本迭代路线图
└── UI-TO-ROADMAP-{date}.md                   # 版本迭代交棒清单

# Step 4 — critic
.csp/critic/
├── PRODUCT-CRITIC-REPORT-{date}.md           # 批评审查报告
├── CRITIC-FINDINGS-{date}.json               # 结构化 findings（前缀 CRITIC-F-NN）
├── CROSS-MODULE-{date}.md                    # 跨模块聚合裁决
├── SCAN-LIST-{date}.md                       # 审查清单
└── recon-{slug}.md                           # 逐模块现状重建
docs/analysis/
├── CRITIC-SUMMARY-{date}.md                  # 人类可读摘要
└── CRITIC-TO-ROADMAP-{date}.md               # 主题候选交棒清单

# Step 5 — feature-gap
.csp/gap-analysis/
├── SCAN-LIST-{date}.md                       # 巡检清单
├── GAP-REPORT-{slug}.md                      # 逐模块增强深潜报告
├── GAP-FINDINGS-{slug}.json                  # 逐模块结构化发现（前缀 GAP-F-NN）
├── GAP-FINDINGS-_aggregate.json              # 统一 aggregated findings
├── recon-{slug}.md                           # 逐模块现状重建
└── CROSS-MODULE-UI-{date}.md                 # 跨模块 UI 聚合
docs/analysis/
├── GAP-SUMMARY-{slug}.md                     # 人类可读摘要
└── GAP-TO-ROADMAP-{slug}-{date}.md           # 主题候选交棒清单

# Step 6 — product-audit
docs/audit/
├── PRODUCT-AUDIT-{date}.md                   # 多角度审查报告
└── REVIEW-FINDINGS-{audit-slug}.json         # 结构化发现（前缀 AUDIT-F-NN 同族）
docs/analysis/
└── AUDIT-TO-ROADMAP-{date}.md                # 交棒清单
```

---

## 十、Fallback 模式

> 当 Agent 工具不可用时激活。最大风险不是"没跑"，而是"跑了一半、用批量文件读取替代了深度分析、产物结构不符合预期"。

### F-0 总纲

1. 每步必须产独立文件（不允许合并到"总报告"）
2. 每步必须产独立 findings JSON（不允许共用）
3. finding 前缀必须与标准模式一致
4. 批量文件读取只能用于现状重建，不能替代逐镜头/逐面深度分析
5. 每步完成后必须先自检（F-GATE），通过才进入下一步
6. 自检不通过 → BLOCKED（附缺失项清单），不强行进入下一步

### F-GATE 自检（每步完成后强制输出）

任一 `❌` 即 BLOCKED。每步检查项见下方速查表。完整自检表格式参见各提示词文件内的 F-GATE 模板。

**Step 1 自检**：`AUDIT-FINDINGS-{milestone-slug}.json` 存在 / finding_id 前缀为 `AUDIT-F-` / finding >0 / Nielsen 10 逐项有判定 / `MODULE-LIST-{milestone-slug}.md` 覆盖全模块 / 每条含 evidence / 无"应该/大概"断言

**Step 2 自检**：`verify/ui-test-report.md` 存在 / 全路由 sweep / 按钮审计 JSONL 非空 / 孤儿/隐藏确认 / 死按钮有 handler 核验 / schema drift/tsc 有执行记录 / 每条含执行证据

**Step 3 自检**：`UI-FINDINGS-{date}.json` 存在 / 前缀为 `UI-F-` / 8 镜头每镜头独立成节 / 镜头 4 含 Token 漂移对照表 / `CROSS-MODULE-UI-{date}.md` 含批次列表+IA 重组 / `UI-VERSION-PLAN-{date}.md` 含四级分组+版本批次 / 每条含 user_impact / UI 建议附原型对照 / 引用上游有明确指针

**Step 4 自检**：`CRITIC-FINDINGS-{date}.json` 存在 / 前缀为 `CRITIC-F-` / 七镜头 A–G 每镜头独立 / 镜头 A 分 A1–A5 五类 / 含产品 sense rationale / 引用上游有明确指针 / `CROSS-MODULE-{date}.md` 存在 / `recon-{slug}.md` 逐模块存在 / P0 标 快速修复=true

**Step 5 自检**：每模块有独立 `GAP-REPORT-{slug}.md` + `GAP-FINDINGS-{slug}.json` / F1–F12 每面有判定 / U1–U7 引用 UI-F / 功能原型按命中选目录 / `CROSS-MODULE-UI-{date}.md` 存在 / `GAP-FINDINGS-_aggregate.json` 存在 / 每条带依据

**Step 6 自检**：`PRODUCT-AUDIT-{date}.md` 存在 / 聚合全部四个前缀 / 四角度独立审查 / `AUDIT-TO-ROADMAP-{date}.md` 存在 / 主题含 SemVer 标注 / 跨步骤去重声明

### F-BLOCKED 处理

1. 停止继续下一步
2. 输出 BLOCKED 原因 + 缺失项清单
3. 不产出"合并总报告"替代
4. 同一步骤最多 BLOCKED 2 次；第 3 次 → PERMANENTLY_BLOCKED
5. PERMANENTLY_BLOCKED 列出"当前模式无法完成 vs 仍需完成"，用户决定

### F-ANTI 反模式

| 反模式 | 正确做法 |
|--------|---------|
| 批量 grep/glob 替代深度分析 | 每 lens 逐条对照检查项，每条 finding 带 product rationale |
| 6 步产出 1 个合并 report | 每步独立文件，路径+前缀与标准一致 |
| 不输出 F-GATE 自检表 | F-GATE 是强制输出 |
| finding 数=0 且无逐模块声明 | 必须逐模块/逐镜头声明"经审查无问题" |
| Token 漂移表为空壳 | 含 ≥1 条具体 file:line 对比，或声明"经逐页对比无漂移" |
| CROSS-MODULE 为泛泛之谈 | 含具体批次列表（模块+finding IDs+裁决） |
| 自检有 ❌ 但结论 PASS | 任一 ❌ 即 BLOCKED |

---

## 十一、与相邻提示词的边界

| 提示词 | 定位 | 粒度 | 前缀 |
|--------|------|------|------|
| `audit.md` | 工程结构体检（模块化+Nielsen+联动测试） | 全项目 | `AUDIT-F-NN` |
| `e2e-deep-audit.md` | 实机验证（路由 sweep+按钮审计+结构健康） | 全页面 | 无独立前缀 |
| `ui-review-to-iteration.md` | UI/UX 八镜头审查 + 版本迭代路线图 | 全界面 | `UI-F-NN` |
| `product-critic-review.md` | 产品总监七镜头批评（重复/散乱/定位） | 全模块 | `CRITIC-F-NN` |
| `feature-gap-analysis.md` | 单模块功能缺口与增强深潜 | 单模块 | `GAP-F-NN` |
| `product-audit-to-roadmap.md` | 多角度审查 → 主题候选交棒 roadmap | 聚合层 | `AUDIT-F-NN` |
| **本编排器** | 串联以上六份提示词，做去重路由、聚合、交棒 | 编排层 | —（不下发 finding） |

---

## 十二、自动发现与执行

未指定范围时：从路由表 + `.csp/product-spec/` 模块清单 + `.csp/code-spec/entry-points.jsonl` + `docs/FEATURES.md` 枚举全部页面/功能模块，按"核心路径优先 + P0 高危模块优先"排序，写入 SCAN-LIST 后即开始，不等确认。

**gate 即授权**：顺序、范围、去重归属、严重度校准、P0–P3 分级、deferred 取舍自己拍板；仅在审查清单真模糊且问询后仍不明 / 基线全缺且无法限定降级 / 真破坏操作（改代码删文档）/ 无法 auto-resolve 的报错时才打断用户。