使用 CSP 技能自我优化 CSP 技能体系。从执行观察 → 缺口识别 → 技能编写 → 验证发布的全闭环。

## 触发场景

- 用户说"优化 CSP""改进技能""这个 skill 有缺口"
- 用户提供执行后的问题反馈（如 v6.65 复盘报告）
- 用户说"蒸馏一下最近的执行""从执行中学习"
- 定期维护（每轮迭代后）

## 执行流程

### Phase 1: 收集信号

调用 `[[workflow:csp-skill-distiller]]` 收集执行观察：

```
来源:
  - git log --oneline -20 (修复类 commit)
  - .csp/skill-improvements/ 中已有的蒸馏报告
  - 用户反馈（对话中提到的缺口）
  - 最近的 gate 失败记录
  - 最近的复盘 findings (.csp/review/)
```

**输出**: 观察清单（每条含证据/阶段/影响）

### Phase 2: 缺口分析

对照 CSP 技能体系分析每条观察：

| 缺口类型 | 判定 | 示例 |
|---------|------|------|
| 规则缺失 | 现有 skill 有覆盖意图但缺具体规则 | coding-standards 缺 G-10 |
| 门禁缺失 | 规则存在但无 gate 强制 | TQ.1 有 Build 但缺 HARD BLOCK |
| 技能空白 | 无 skill 覆盖 | Agent 写后 import 验证 |
| 执行腐化 | 规则和 gate 都有但被跳过 | 06 gate 没跑 build |

**输出**: 每条缺口 → 目标 skill 文件 + 改进方向

### Phase 3: 编写/修改技能

对每个缺口，使用 `[[workflow:csp-writing-skills]]` 编写或修改技能：

```
新技能:   cp shared/templates/SKILL-TEMPLATE-v3.md → 目标路径
          → 填写 frontmatter (name/description/type/layer/phase...)
          → 填写 body (Purpose/When to Use/Process/Verification/Examples)
          → 运行 validate-skill-v3.mjs 验证

修改技能: → 读取现有 SKILL.md
          → delta 修改（ADDED/MODIFIED 标记）
          → 运行 validate-skill-v3.mjs 验证
```

**CSO 规则（Claude Search Optimization）**:
- description 以 "Use when..." 开头
- 包含中英文关键词
- 关联 skill 用 `[[wiki-link]]` 格式

**Token 预算**: L1~300 / L2~500 / L3~200-600 / L4~300

### Phase 4: 注册与构建

```
1. 更新 registry.json（或运行 npm run build:all 自动生成）
2. 添加 trigger words 到 triggers.yaml（中英文）
3. 更新 docs/reference/SKILL-INDEX.md
4. 运行 npm run build:all（重建 registry + triggers + graph + page）
5. 运行 npm run validate:all（验证全部通过）
```

### Phase 5: 发布

```
git add -A
git commit -m "feat(skill): <描述>"
git push origin master
```

## 编写的技能质量标准

按 `[[workflow:csp-writing-skills]]` 的三级质量：

| Tier | 要求 | 适用 |
|------|------|------|
| **A** | 全部 Required Sections + 表格 + 代码示例 + 验证清单 | 核心/高频 skill |
| **B** | Purpose/When to Use/Process/Verification/Examples | 默认目标 |
| **C** | 最小结构（Purpose/When to Use/Process） | 轻量 reference |

新编写技能目标 **Tier B 或以上**。

## 技能类型对照表

| 类型 | Required Sections | 示例 |
|------|------------------|------|
| technique | Purpose/When/Process/Verification/Examples | csp-tdd |
| pattern | + Key Principles | csp-scope-guard |
| guardian | + Anti-Patterns/Rationalization Defense | csp-writing-skills |
| workflow | + When NOT/Routing/Completion Signal/Related | csp-simple-dev |
| reference | Purpose/When/Examples | csp-code-wiki |

确定 skill 类型后，按上表检查所有 Required Sections 齐全。

## 完成信号

```yaml
completion_signal:
  output: |
    新创建技能: N 个
    修改技能: N 个
    新增规则: N 条
    补全 gate: N 条
  next_step:
    recommended: "回到 Phase 1 — 这次修改后下次执行会有新的观察"
  status:
    phase: ship
```

---

## 示例：从 v6.65 复盘蒸馏一个改进

```markdown
### 观察: 模块删除后测试 import 断裂
**证据**: test_v337_smoke.py import 已删除的 audit_v337.py
**缺口类型**: 规则缺失
**目标 skill**: csp-patterns/skills/csp-coding-standards/SKILL.md

### 改进提案: G-10 模块生命周期变更必须级联测试

**建议文本**:

### Module Lifecycle — Rename/Delete Must Cascade Test References (CRITICAL)

| 操作 | 检查 | 门禁 |
|------|------|------|
| git mv / rename | grep -r <old_name> tests/ | pytest --collect-only exit 0 |
| git rm | 同上 | 同上 |
| __tablename__ 变更 | grep -r <old_tablename> tests/ | 同上 |

**红线**: 禁止留下 import 断裂的测试文件, CI 中 pytest --collect-only exit ≠0 → BLOCKED
```

## CSP Skill 路径速查

| 任务 | Skill |
|------|-------|
| 收集执行观察 | `[[workflow:csp-skill-distiller]]` |
| 编写/修改技能 | `[[workflow:csp-writing-skills]]` |
| 创建新技能 | SKILL-TEMPLATE-v3.md |
| 验证技能 | `[[meta:csp-skill-optimizer]]` |
| 编译注册表 | `npm run build:all` |
| 全面验证 | `npm run validate:all` |