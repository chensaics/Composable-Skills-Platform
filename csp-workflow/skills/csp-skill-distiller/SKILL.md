---
name: csp-skill-distiller
description: >
  Use after completing any lifecycle phase (01-07) or the full cycle, when executing
  design/planning/development/testing with CSP skills and observing gaps or failures.
  Distills execution observations into structured CSP skill improvement proposals:
  需要什么新规则、哪个 skill 缺什么 section、什么反模式应该被文档化。
  Keywords: 技能蒸馏, skill distill, 自我优化, 复盘改进, 技能缺口, self-improve skills,
  post-phase analysis, skill improvement, 改进建议.
version: "1.0.0"
layer: 2
category: workflow
type: workflow
phase: verify
domain: quality
role: specialist
scope: analysis
tools: [Read, Write, Edit, Glob, Grep, Bash]

dependencies:
  skills: []

related_skills:
  - csp-lifecycle-orchestrator
  - csp-writing-skills
  - csp-retro
  - csp-skill-optimizer

triggers:
  keywords: ["技能蒸馏", "skill distill", "自我优化", "复盘改进", "技能缺口",
             "improve skills", "distill findings", "优化skill", "改进技能"]
  intents:
    - "user wants to improve CSP skills based on execution experience"
    - "user wants to distill observations into skill improvements"
    - "user noticed gaps in CSP coverage during development"
  context:
    - "post_phase"
    - "post_cycle"
    - "post_retro"

anti_rationalizations:
  "这个 gap 太小了，不值得记录": "小 gap 积累 = 大缺口。每个 gap 都是一个具体可修复的改进点。记录成本低，遗忘成本高。"
  "复盘已经做了，不需要再蒸一脚": "复盘分析「项目层面」的问题。蒸馏分析「技能层面」的问题——两者不同：复盘告诉你 v6.64 有哪些 bug；蒸馏告诉你 CSP 的 coding-standards 缺了 G-10。"
  "先攒着，等积累多了再一起改": "攒着就是遗忘。每次执行后立即蒸馏——上下文还在、证据还在、记忆还热。"
---

# Skill Distiller

执行驱动的 CSP 自我蒸馏 — 在每阶段完成后，反思执行过程中发现的技能缺口，产出具象的改进提案。

## Purpose

本技能观察 CSP 技能体系在实际执行中的表现，识别三类缺口并产出具象的改进提案：

1. **规则缺失** — 执行中出现的错误，CSP 现有技能有覆盖意图但缺具体规则
2. **技能空白** — 执行中出现的错误，CSP 没有任何技能覆盖这个场景
3. **执行腐化** — 技能规则存在但未被遵守，因为规则太弱/缺乏门禁

## When to Use

- ✅ 每个生命周期阶段完成后（01→02→03→04→05→06→07）
- ✅ 发现 CSP 技能未能预防的 bug/错误时
- ✅ 复盘（07）完成后，作为复盘产物的下游消费
- ✅ 用户说"这个 skill 好像没覆盖 X""为什么 Y 没有 gate""下次怎么避免 Z"
- ❌ 用户显式要求修改某个 skill（用 `csp-writing-skills` 直接编辑）
- ❌ 对话中的一次性反馈（用 `csp-skill-optimizer`）

## Process

### Step 1: 收集执行观察（2 min）

从当前阶段的执行产物中提取信号：

| 信号源 | 读取什么 | 提取什么 |
|--------|---------|---------|
| Git log | `git log --oneline -10` | commit message 中的 fix/revert/修复类提交 |
| 失败的检查 | `.csp/artifacts/verify/evidence/` 中的红色证据 | 哪个 gate 失败了、失败原因 |
| DEV-LOG | 当前版本的开发决策摘要 | 遇到了什么意外问题、做了什么临时决策 |
| 复盘 findings | `.csp/review/REVIEW-FINDINGS-*.json` | 每条 finding 的 root cause、触发场景 |
| 测试失败 | `pytest` / `vitest` 的失败输出 | 失败类型分类：import 断裂/断言过期/类型错误 |
| 用户纠正 | 对话中用户的否定/纠正性消息 | 用户说了"不应该""为什么""怎么又""还是没"的上下文 |

**输出格式**（对话级，不落盘）：
```
观察 {N}: {问题简述}
  证据: {commit hash / file:line / 用户原话}
  阶段: {哪个 lifecycle 阶段}
  影响: {导致了什么后果}
```

### Step 2: 分类缺口（1 min）

对照 CSP 现有技能体系（`csp-router/registry.json` 或 `docs/reference/SKILL-INDEX.md`），判定每个观察属于哪种缺口：

| 缺口类型 | 判定条件 | 示例 |
|---------|---------|------|
| **规则缺失** | 相关 skill 存在，但缺少覆盖这条观察的具体规则 | `csp-coding-standards` 有 G-09（禁版本号命名），但没有"rename 后测试同步" → 缺口 G-10 |
| **门禁缺失** | 规则存在但没有对应的 gate 强制它被执行 | `000-test_pipeline_csp.md` 写了 `Build exit 0` 但在 TQ.1 里没有 HARD BLOCK 标注 |
| **技能空白** | 没有任何 CSP skill 覆盖这个场景 | "Agent 新建 .tsx 文件的 import 路径验证"——没有任何 skill 显式检查这个 |
| **执行腐化** | 规则和 gate 都存在，但 Agent 跳过了 gate | 06 gate 写了 `Check 3: Build` 但发布时没有实际跑 |
| **文档漂移** | 规则描述与实际情况不一致 | lifecycle-state 说 `05-implement` 但 tag 已存在 |

**输出格式**：
```
观察 {N} → 缺口类型: {规则缺失/门禁缺失/技能空白/执行腐化/文档漂移}
  目标 skill: {应该覆盖这个场景的 skill 名称} 或 "无现有 skill 覆盖"
```

### Step 3: 生成改进提案（3 min）

对每条缺口，产出具象的改进提案。提案必须包含以下六要素：

```markdown
### 提案 {P-序号}: {一句话标题}

**缺口类型**: {类型}
**目标 skill**: {skill 文件路径}
**证据**: {来自 Step 1 的具体证据}
**改进内容**:
{要修改哪个 section、新增什么规则、加入什么检查项}

**建议文本**（可直接写入 SKILL.md 或 prompt 文件）：

```markdown
### {新 section 名或规则编号}

{具体规则文本，含门禁/反模式/示例}
```

**影响评估**: {这个改进会防止哪类问题的再次发生}
```

**提案质量要求**：
- 必须指名道姓：具体到哪个文件的哪个 section（不是"应该加强验证"这种废话）
- 必须有证据链：每个提案必须有 Step 1 收集的具体证据
- 必须有可执行文本：建议文本可直接贴进 skill 文件（不是"建议加个 gate"这种废话）
- 一条提案只解决一个问题：不做复合提案

**反模式**：

| 反模式 | 正确做法 |
|--------|---------|
| "建议加强测试覆盖" | 具体到：`000-test_pipeline_csp.md` Phase TA.3 结构健康维度新增"AI 生成文件的 import 路径解析"检查项 |
| "应该有个 gate" | 具体到：`csp-lifecycle-orchestrator` routing_rules 中新增 `V-01 双真相源对账` 的完整 YAML |
| "文档需要更新" | 具体到：`csp-coding-standards/SKILL.md` 的"File Naming — Anti-Pattern"段新增 G-10 规则 |
| 提案 ≥3 个改动点 | 拆成多条提案，一条一个点 |

### Step 4: 优先级排序

按以下矩阵排序提案：

| 优先级 | 判定条件 |
|--------|---------|
| **P0 立刻改** | 已经导致过生产/发布问题 + 修复成本低（< 10 行修改） |
| **P1 下版本** | 已经导致过发布阻塞 + 修复成本中等 |
| **P2 下一迭代** | 预防性改进 + 尚未导致实际问题 |
| **P3 长期跟踪** | 大范围重构 + 需要跨 skill 协调 |

### Step 5: 落盘归档

输出到 `.csp/skill-improvements/SKILL-DISTILL-{phase}-{date}.md`：

```markdown
# Skill Distillation Report — {phase} / {date}

## 执行摘要
- 阶段: {01-07 或 full-cycle}
- 版本: {version tag}
- 收集观察: {N} 条
- 缺口: {N} 条（规则缺失 {n} / 门禁缺失 {n} / 技能空白 {n} / 执行腐化 {n} / 文档漂移 {n}）
- 改进提案: {N} 条（P0 {n} / P1 {n} / P2 {n} / P3 {n}）

## 观察清单
{Step 1 的输出}

## 缺口分类
{Step 2 的输出}

## 改进提案
{Step 3 的输出，按 Priority 排序}

## P0 立即行动项
{列表，每条含目标 skill + 预计行数}
```

**累计索引**：每次蒸馏后更新 `.csp/skill-improvements/INDEX.md`（如不存在则创建），按 Phase 列出所有报告链接。

## Key Principles

- **证据优先于直觉**：每条提案必须基于具体证据（commit/error log/finding），不基于"我觉得应该加个规则"
- **具象优先于抽象**：提案必须命名到文件+段落，"应该加强"不算提案
- **一条提案一个点**：复合提案拆成多条
- **立刻改优先于攒着**：P0 提案在蒸馏完成后立即执行修改，不推迟
- **蒸馏 ≠ 修改**：蒸馏产出提案；修改是 `csp-writing-skills` 的事。但 P0 提案建议立即执行。

## Completion Checklist

- [ ] Step 1: 收集了 3+ 条执行观察（如果 < 3 条，说明阶段太顺利或信号未收集）
- [ ] Step 2: 每条观察分类到了具体缺口类型
- [ ] Step 3: 每条缺口有对应的具象改进提案（六要素齐全）
- [ ] Step 4: 提案按优先级排序
- [ ] Step 5: 报告落盘到 `.csp/skill-improvements/`
- [ ] Step 5: INDEX.md 已更新
- [ ] P0 提案已立即执行修改（如有）

## Completion Signal

```yaml
completion_signal:
  output: .csp/skill-improvements/SKILL-DISTILL-{phase}-{date}.md
  next_step:
    recommended: csp-lifecycle-orchestrator  # 继续下一阶段
    alternatives:
      - csp-writing-skills                    # 执行 P0 提案中的具体修改
      - csp-retro                             # 如果本报告是 07 复盘输入
  status:
    observations_collected: "{{count}}"
    proposals_generated: "{{count}}"
    p0_actions: "{{count}}"
    phase: verify
    ready_for: [next_phase, skill_improvement]
```

## 与 csp-retro 和 csp-skill-optimizer 的边界

| Skill | 关注层面 | 输入 | 输出 |
|-------|---------|------|------|
| **csp-retro** | 项目层面：这个版本有什么问题 | 代码质量/dev 流程/团队协作 | lessons for next iteration |
| **csp-skill-optimizer** | 对话层面：用户在对话中说了什么 | 用户反馈/对话纠正 | 触发词优化/参数调整 |
| **csp-skill-distiller**（本 Skill） | **技能层面**：CSP 技能体系有什么缺口 | 执行证据（commit/finding/gate log） | 具象改进提案 |

三者互补：复盘告诉你 v6.64 有哪些 bug；优化器告诉你用户说了什么；蒸馏告诉你 CSP 的 coding-standards 缺了 G-10。

## Example

从 v6.64/v6.65 执行的蒸馏示例：

```markdown
### 提案 P-1: 模块生命周期变更必须级联测试

**缺口类型**: 规则缺失
**目标 skill**: csp-patterns/skills/csp-coding-standards/SKILL.md
**证据**:
  - `test_v337_smoke.py` import 已删除的 `audit_v337.py` (C1)
  - `test_v5695_extension.py` import 已删除的 `extension_v5695` (C2)
  - `test_v5573_evidence_ledger.py` 断言过期 `__tablename__` (C3)
  - sidebar-config.test.ts 期望 6 sections 实际 5 (C4)
  - deprecated-paths.test.ts 期望 44 实际 55 (C5)

**改进内容**:
在 coding-standards "File Naming" 段之后新增 "Module Lifecycle — rename/delete must cascade test references" 段（G-10），含四项门禁：git mv/rm 后 grep tests/、ORM tablename 变更后 grep tests/、sidebar/route 计数变更后同步断言。

**建议文本**: {具体 markdown, 略}

**影响评估**: 防止代码结构变更后测试腐败，所有 C1-C6 类问题被覆盖。
```