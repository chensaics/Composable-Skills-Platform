---
name: csp-knowledge-hub
description: "Local-first Knowledge Hub — a git-managed markdown workspace that unifies spec (PMS/CMS/TMS), wiki, and memory into one indexed, queryable hub. Includes alignment guard that proactively checks PMS↔CMS↔TMS consistency: when any one changes, detect drift in the others. Platform-decoupled: local markdown + git + AGENTS.md routing + a sole manifest index."
version: "1.1.0"
layer: 2
category: workflow
phase: define
domain: architecture
scope: design
role: architect
tools: [Read, Write, Edit, Glob, Grep, Bash]

dependencies:
  skills: [csp-product-spec, csp-code-spec, csp-test-spec]

related_skills:
  - csp-product-spec
  - csp-code-spec
  - csp-test-spec
  - csp-wiki
  - csp-code-wiki
  - csp-remember
  - csp-writer-memory
  - csp-session-knowledge-extractor
  - csp-doc-lifecycle-manager
  - csp-project-doc-architect
  - csp-lifecycle-orchestrator
  - csp-prd-traceability

triggers:
  keywords: ["知识中枢", "knowledge hub", "知识库初始化", "local wiki workspace", "spec 索引",
             "locate spec", "知识 workspace", "本地知识库", "align docs to code", "knowledge workspace",
             "manifest index", "AGENTS.md 路由", "spec 定位", "知识闭环", "docs-to-code",
             "对齐检查", "alignment check", "PMS对齐", "CMS对齐", "TMS对齐", "spec drift",
             "文档一致性", "需求代码测试对齐"]
  intents:
    - "user wants a single local hub indexing specs + wiki + memory"
    - "user wants fast spec location/read/generation across the codebase"
    - "user wants to align docs to code locally (git-managed, no platform)"
    - "user wants the 需求→code→test knowledge loop closed in one workspace"
    - "user wants to check if PMS/CMS/TMS are consistent with each other"
    - "user detects that specs and code are out of sync"
  context:
    - "project_onboarding"
    - "before_spec_generation"
    - "knowledge_compaction"
    - "closed_loop_needed"

anti_rationalizations:
  "知识直接散在 docs/ 就行": "散落文档无索引、无 manifest、无路由 → Agent 找不到、对不齐。hub 用 manifest + AGENTS.md 让 spec 可定位、可追溯、可增量。"
  "用平台知识库存就行": "平台耦合（鉴权/域名/专有 API）不可本地复现、不可离线、不可 git 治理。本 hub 全本地 markdown+git，可离线、可审计、可 PR。"
  "manifest 用 mtime 判变化": "禁止。mtime/文件大小不可靠；用稳定 source_id + content_hash(git blob) 判 added/changed/removed。"
  "wiki/spec 各存各的 .meta.json": "废弃侧车。元数据内联进 .md 顶部 YAML frontmatter，每页自包含。"
  "生成 Python 代码操作知识": "禁止。用 hub_manifest.sh 脚本（纯 git+grep，零依赖），比生成代码快 10x 且可复现。"
  "写知识前不查冲突": "禁止。add 前必先 search 现有页；命中冲突自动 update，不问'删旧的?'。"
---

# Knowledge Hub (Local-First)

> **定位:** 一个 git 治理的本地 markdown 工作区，把 **spec (PMS/CMS/TMS) + wiki + memory**
> 统一到一个可索引、可查询、可增量同步的 hub，**加速 Agent 对 codebase 的理解、
> 快速 spec 定位/读取/生成**，闭环 **需求对齐(文档 spec 记录) → code 开发 → 测试**。
>
> **平台解耦:** 替换平台托管的研发知识交互
> （鉴权/域名/专有 API）为 **本地 markdown + git + AGENTS.md 路由 + 唯一 manifest 索引**。
> 可离线、可审计、可 PR、可 git 版本治理。

## When to Use

- 项目启动/接手，要一个本地知识中枢索引 spec + wiki + memory
- 要快速定位/读取既有 spec（"这个模块的 PMS 在哪？""auth 的 CMS 入口点？"）
- 要把文档对齐到代码（本地 git 治理，非平台）
- 要闭环 需求→code→test 的知识流（spec 记录 → code 开发 → test 用例，全在 hub 索引）
- 要替代平台知识库做离线/可审计的本地等价物
- **棕地项目**：已有代码但文档不全 → 从代码反推文档并对齐

## When NOT to Use

- 单页 wiki（用 `csp-wiki`）
- 代码 source-grounded Q&A wiki（用 `csp-code-wiki`）
- 个人事实记忆（用 `csp-remember`）
- 只读既有 spec 不需 hub 路由（直接 Read）

## 棕地项目快速启动（Brownfield Quick Start）

已有代码和部分文档，需要快速建立 PMS/CMS/TMS 体系并对齐。按**信息丰富程度**分三条路径：

### 路径 1: 代码完备，文档缺失（最常见）

**指令**: "从代码生成 CMS + 反推 PMS + 梳理 TMS + 对齐检查"

Agent 执行：
1. **代码→CMS** (`csp-code-spec` Step 2.5)：全量扫描源码，生成按文件/模块的结构化文档到 `.csp/code-spec/{app}/modules/`
2. **代码→PMS 反推**：从目录/包结构推导模块边界，从业务规则代码（枚举、校验、状态机）反推业务逻辑。输出 PMS 模块定义，标注 `[从代码反推，需人工确认]`
3. **测试→TMS 梳理**：扫描现有测试文件，建立入口点→覆盖矩阵，标注 `⚠️ NO COVERAGE` 的入口点
4. **对齐检查** (`hub align-check`)：报告 PMS↔CMS↔TMS 的所有不一致

**Agent 自动完成的**：文档生成、gap 检测、对齐报告
**需要你确认的**：从代码反推的 PMS 模块名和边界是否准确、孤立的测试是否该保留

### 路径 2: PRD + 代码都有，但可能不一致

**指令**: "从 PRD 生成 PMS，从代码生成 CMS，找出 PRD 和代码的差异"

Agent 执行：
1. PRD → PMS（`csp-product-spec` Step 2）
2. 代码 → CMS（`csp-code-spec`）
3. PMS ↔ CMS 对齐对比：
   - PMS 声明的模块 CMS 没找到 → 🔴 **PRD 写了但代码没实现**
   - CMS 有入口点 PMS 没声明 → 🟡 **代码有功能但 PRD 没记录**
   - 两者都有但不一致 → 🟡 **实现偏离设计，需确认以哪个为准**

**Agent 自动完成的**：双向生成、差异检测、标注严重度
**需要你确认的**：PRD vs 代码哪个是 ground truth，不一致时改哪个

### 路径 3: 三者都有，只验证

**指令**: "检查 PMS/CMS/TMS 对齐"

Agent 执行 `hub align-check`：
- 检查 A (PMS↔CMS)：模块边界是否对齐
- 检查 B (PMS↔TMS)：验收标准是否覆盖
- 检查 C (CMS↔TMS)：代码入口点是否有测试
- 输出对齐报告 + 修复建议

**Agent 自动完成的**：全量一致性检查、报告生成
**需要你确认的**：歧义项的裁决（两个模块声称同一入口等）

## Project Entry Contract

**REQUIRED REFERENCE:** `references/project-entry-contract.md` — L0 身份 → L1 当前状态 → L2 意图路由 → L3 任务详情；区分最近观测与发布门禁、findings 来源与存量违规基线。入场时按意图读，不把整个 manifest 或历史日志注入上下文。项目原有可运行路径优先于下面的示例布局。

## Workspace Layout

详见 `references/workspace-layout.md`。核心结构（统一在 `.csp/` 下，不移动既有产物）：

```
.csp/                              # hub 根
├── AGENTS.md                      # 路由契约（6 节）—— 见 references/agents-md-route-contract.md
├── manifest.json                  # 唯一 source index（跨 spec/wiki/memory）—— 见 references/manifest-frontmatter-spec.md
├── product-spec/                  # PMS（既有，不移动）
├── code-spec/{app}/               # CMS（既有）
├── test-spec/{module}/            # TMS（既有）
├── wiki/                          # 通用项目 wiki（csp-wiki 产物）
├── code-wiki/{system}/            # 代码 Q&A wiki（csp-code-wiki 产物）
├── specs/                         # 全栈 feature spec（既有）
├── decomposition/ tech-decisions/ tech-design/ tasks/ plan/ traceability/ prd-ir/  # 既有
├── intel/                         # 会话知识（既有）
└── milestones/v{N}/               # 里程碑归档（既有）
```

**权威与依赖方向:** raw/docs → spec/wiki → 派生产物，单向；`raw`（原始资料快照）下载后只读。

## 核心：唯一 manifest 索引

`.csp/manifest.json` 是跨 spec/wiki/memory 的**唯一 source index**与同步基线：

```json
{
  "manifest_id": "<project>-hub",
  "version": 1,
  "generated_at": "...",
  "adapter": "csp-knowledge-hub",
  "repo_url": "<configured git remote>",
  "items": [
    {
      "source_id": "pms:MOD-AUTH-1",
      "source_type": "pms|cms|tms|wiki|codewiki|memory|doc",
      "kind": "module|feature|page|fact",
      "title": "用户与权限",
      "raw_path": "docs/prd/auth.md",
      "output_path": ".csp/product-spec/modules/MOD-AUTH-1.md",
      "original_ref": "docs/prd/auth.md @ a1b2c3d",
      "content_hash": "<git blob hash>",
      "source_updated_at": "...",
      "build_status": "pending|built|failed",
      "wiki_pages": ["MOD-AUTH-1"],
      "status": "ready|degraded|blocked"
    }
  ]
}
```

- **增量判据：** 写入者用稳定 `source_id` + `content_hash`(git blob) 判 added/changed/removed；**禁止 mtime/文件大小**。现有 `hub_manifest.sh diff` 只比较 manifest 已列 `output_path` 的哈希/缺失，不自动发现新来源或回写索引。
- raw 下载成功 → 更新 hash/path/`status=ready`；失败 → 保留 item 标 `blocked`/`degraded`。
- 删除来源 → 二次确认后从 `items` 移除。

## 核心：内联 YAML Frontmatter

每篇**实质页** `.md` 顶部内联 frontmatter（**废弃侧车 `.meta.json`**），每页自包含：

```md
---
type: concept|entity|faq|howto|reference|comparison|source-summary|archive|skill|module-spec|feature-spec|test-spec
confidence: high|medium|low
sources:
  - "[[raw/auth.md@a1b2c3d]]"
seeAlso:
  - "[[code-spec/auth-service/CODE-MODULE-SPEC]]"
created: "2026-08-28"
updated: "2026-08-28"
---
# {Title}
```

字段规范见 `references/manifest-frontmatter-spec.md`。

## 核心：AGENTS.md 路由契约

`.csp/AGENTS.md` 是 hub 轻量入口（不承载编译细节），6 节固定结构 + 操作路由表，详见 `references/agents-md-route-contract.md`。进入 workspace 先读它；写入前读 schema/manifest；查询前读 `wiki/index.md`。

## 核心：闭环（需求→code→test）

详见 `references/closed-loop.md`。hub 让三说明书 + wiki + memory 在一个索引内闭环：

```
需求对齐 (PMS 文档spec记录) ──manifest index──▶ code 开发 (CMS ground design/codegen)
        ▲                                                  │
        │                                                  ▼
   test (TMS 存量+增量) ◀──manifest index── 审查 (CR 读 CMS+TMS) ◀─ ship (PMS 闭环)
```

- **需求对齐:** PMS 模块边界 + 验收形态记录为 spec 页（frontmatter `type: module-spec`），入 manifest。
- **code 开发:** CMS 蒸馏入口点/调用链（`type: feature-spec` 衍生），生码读 CMS 约定匹配既有模式；CMS 变更 auto-align 写回 manifest。
- **test:** TMS 需求→方法矩阵 + 存量用例（`type: test-spec`），增量只对 delta 新组合。
- **审查/ship:** CR 读 CMS 追溯调用链 + TMS 存量产增量；ship 后 PMS 闭环（每条验收可追溯到需求）+ 三说明书 delta 折叠进 canonical。

## 对齐守卫 (Alignment Guard) — PMS/CMS/TMS 一致性检查

PMS、CMS、TMS 是**有机整体**，不是三个孤岛。对齐守卫**主动检测**三者之间的一致性，
在任何变更后回答："PMS 改了，CMS 和 TMS 跟着更新了吗？"

### align-check 命令

```bash
# 全面对齐检查（PMS↔CMS, PMS↔TMS, CMS↔TMS）
bash scripts/hub_manifest.sh align-check

# 只检查某个维度
bash scripts/hub_manifest.sh align-check --pms   # PMS→CMS 对齐
bash scripts/hub_manifest.sh align-check --tms   # PMS→TMS 对齐
bash scripts/hub_manifest.sh align-check --all   # 全维度
```

### 三大对齐检查

#### 检查 A: PMS ↔ CMS 模块边界对齐

```bash
# 1. PMS 声明了哪些模块
grep "^### MOD-" .csp/product-spec/PRODUCT-MODULE-SPEC.md

# 2. CMS 入口点归属了哪些模块
grep "业务场景" .csp/code-spec/{app}/entry-points.jsonl

# 3. 差异检测
diff <(grep "^### MOD-" .csp/product-spec/PRODUCT-MODULE-SPEC.md | sort) \
     <(grep "pms:" .csp/code-spec/{app}/CODE-MODULE-SPEC.md | sort)
```

| 检测信号 | 问题 | 严重度 | 建议操作 |
|---------|------|--------|---------|
| PMS 有模块、CMS 无代码归属 | 模块无实现 | 🔴 | 创建代码入口点（见 PMS scaffold） |
| CMS 有入口、PMS 未声明模块 | 自由代码 | 🟡 | 确认是 PMS 遗漏还是应删除 |
| PMS 模块更名、CMS 仍用旧名 | 命名不一致 | 🟡 | 同步 CMS 引用 |
| 两个模块声称同一入口点 | 职责冲突 | 🔴 | 裁决归属 |

#### 检查 B: PMS ↔ TMS 验收覆盖对齐

```bash
# 1. PMS 有多少条 AC
grep -c "Given.*When.*Then" .csp/product-spec/PRODUCT-MODULE-SPEC.md

# 2. TMS 映射了多少条
grep -c "^| AC-" .csp/test-spec/{module}/TEST-MODULE-SPEC.md

# 3. 找出未映射的 AC
diff <(grep "Given.*When.*Then" .csp/product-spec/PRODUCT-MODULE-SPEC.md | sort) \
     <(grep "PMS 验收标准" .csp/test-spec/{module}/TEST-MODULE-SPEC.md | sort)
```

| 检测信号 | 问题 | 严重度 | 建议操作 |
|---------|------|--------|---------|
| PMS AC 无 TMS 映射 | 未测需求 | 🔴 | 生成 AC→Test 映射 |
| TMS 用例无 PMS AC 对应 | 孤儿测试 | 🟡 | 标注来源或清理 |
| AC 语义已变但 TMS 用例未更新 | 过时测试 | 🟡 | 标记 ⚠️ AC CHANGED |

#### 检查 C: CMS ↔ TMS 入口覆盖对齐

```bash
# 1. CMS 有多少 HTTP 入口点
grep "HTTP" .csp/code-spec/{app}/entry-points.jsonl | wc -l

# 2. TMS 覆盖了多少入口
grep "入口" .csp/test-spec/{module}/case-inventory.md | wc -l

# 3. 找出无测试覆盖的入口点
comm -23 \
  <(grep "HTTP" .csp/code-spec/{app}/entry-points.jsonl | cut -d',' -f2 | sort) \
  <(grep "入口:" .csp/test-spec/{module}/case-inventory.md | cut -d':' -f2 | sort)
```

| 检测信号 | 问题 | 严重度 |
|---------|------|--------|
| HTTP 入口无 TMS 覆盖 | 漏测风险 | 🔴 |
| RPC 入口无 TMS 覆盖 | 漏测风险 | 🔴 |
| CMS 新增/删除入口 TMS 未更新 | 测试不再匹配代码 | 🔴 |

### 对齐报告格式

```markdown
## PMS/CMS/TMS 对齐报告 — {timestamp}

### 概览
| 维度 | 状态 | 问题数 |
|------|------|--------|
| PMS ↔ CMS | ✅ aligned | 0 |
| PMS ↔ TMS | ⚠️ 3 issues | 3 |
| CMS ↔ TMS | ❌ 5 issues | 5 |

### 议题清单
| ID | 维度 | 严重度 | 来源 | 问题 | 建议 |
|----|------|--------|------|------|------|
| ALN-1 | PMS↔TMS | 🔴 | .csp/product-spec/ | AC-AUTH-7 无测试映射 | 生成 AC→Test |
| ALN-2 | CMS↔TMS | 🔴 | .csp/code-spec/auth/ | POST /auth/refresh 无测试覆盖 | 补 E2E case |
```

### 对齐触发时机

| 触发事件 | 应执行的检查 |
|---------|-----------|
| PMS 模块变更 (delta) | A (PMS↔CMS) + B (PMS↔TMS) |
| CMS 代码变更 (ship 后 realign) | A (PMS↔CMS) + C (CMS↔TMS) |
| TMS 用例变更 | B (PMS↔TMS) + C (CMS↔TMS) |
| 里程碑归档 (fold deltas) | A + B + C 全量 |
| CR review 前 | C (CMS↔TMS) — 确认有测试覆盖 |
| 用户显式请求 "alignment check" | A + B + C 全量 |

### 自动修复 vs 人工裁决

| 问题类型 | 处理方式 |
|---------|---------|
| 命名不一致（同义不同名） | 自动建议统一命名，人工确认 |
| 缺失映射（新 AC 无测试） | 自动生成骨架，人工填充 |
| 孤儿条目（死代码/死测试） | 标记 `[DEPRECATED]`，人工确认删除 |
| 职责冲突（两个模块声称同一入口） | 上报人工裁决，不解冲突 |

## 快速 Spec 定位/读取/生成

从已安装的 `csp-knowledge-hub` 技能目录定位兄弟脚本 `scripts/hub_manifest.sh`；在 CSP 源码仓库中其路径为 `csp-workflow/skills/csp-knowledge-hub/scripts/hub_manifest.sh`。设置 `CSP_PROJECT_ROOT=<目标项目根>` 后运行：

```bash
CSP_PROJECT_ROOT=<目标项目根> bash <技能目录>/scripts/hub_manifest.sh status
CSP_PROJECT_ROOT=<目标项目根> bash <技能目录>/scripts/hub_manifest.sh locate <query>
CSP_PROJECT_ROOT=<目标项目根> bash <技能目录>/scripts/hub_manifest.sh list --type cms
CSP_PROJECT_ROOT=<目标项目根> bash <技能目录>/scripts/hub_manifest.sh diff
```

`diff` 仅报告已索引输出的内容哈希变化/缺失，不查新来源、不写 manifest。`doctor` 仅做六节数、选定目录首行 frontmatter 和 sidecar 的基础检查；完整 schema/路由/阶段一致性仍需单独验证。

- **定位:** `locate` grep manifest `title`/`source_id`/`output_path` → 返回页面路径 + frontmatter 摘要。
- **读取:** 拿到 `output_path` 后 Read 该 `.md`（自包含 frontmatter，无需侧车）。
- **生成:** 缺失项（`build_status: pending`）→ 路由到对应 spec skill 生成（PMS/CMS/TMS/csp-wiki/csp-code-wiki），生成后回写 manifest `built`。

## Confirmation Gates（用户卡点）

| 卡点 | 触发 | 决策 |
|------|------|------|
| 初始化输入确认 | 收集完资料源/项目名/workspace | 确认/修改 |
| schema 模式 | 首次或重建 | `auto`(AI 生成 schema) / `user`(用户提供) |
| 更新范围 | diff 计算后 | 确认/暂停 |
| source 删除 | removed source | 二次确认删除/保留 |
| raw 质量 | 正文下载后 | 继续/暂停 |
| 编译结果 | 生成后 | 确认/修改/暂停 |
| Git 发布 | 编译确认后 | 确认发布/保留本地 |

## 操作纪律（源自生产记忆/研发知识实践，本地化）

1. **写前查冲突:** add 前必 `locate`/`search` 现有页；命中同主题 → 自动 update，**不问"删旧的?"**。
2. **CLI 脚本优先:** 用 `hub_manifest.sh`（纯 git+grep），**禁生成 Python 操作代码**（慢 10x 且不可复现）。
3. **raw 只读:** 下载后任何 skill 不得改 raw。
4. **查询只读:** query 不写入；未覆盖明确说缺口，不编造。
5. **不写凭证/token:** 凭据不入 workspace；Git 发布必须用户确认。
6. **manifest 唯一:** `wiki/` 内不存 manifest 或符号链接；`.csp/manifest.json` 是唯一索引。
7. **definition-of-done:** 操作未完成直到 (a) 冲突检测已走 (b) 用户已明确被告知 added/updated/skipped。

## 输出产物

```
.csp/
├── AGENTS.md                      # 路由契约
├── manifest.json                  # 唯一索引
├── (既有 spec/wiki/memory 子目录，不移动)
└── .hub-run/<run-id>/             # 运行工作区（不提交）：source-lock/coverage/audit
```

## 门控

- [ ] `AGENTS.md` 6 节齐全 + 操作路由表
- [ ] `manifest.json` 唯一索引，item 字段完整（source_id/content_hash/build_status）
- [ ] 实质页 frontmatter 内联（无 `.meta.json` 侧车）
- [ ] 增量用 content_hash（非 mtime）
- [ ] raw 只读；查询只读
- [ ] 闭环：每条 spec 可 manifest 定位；ship 后 PMS 闭环
- [ ] 对齐守卫已就绪：PMS↔CMS 模块边界、PMS↔TMS 验收覆盖、CMS↔TMS 入口覆盖全部检查
- [ ] 无内部平台名/域名/鉴权耦合（git + CSP_GIT_REMOTE）

## 完成信号

```yaml
completion_signal:
  output: .csp/AGENTS.md + .csp/manifest.json
  next_step:
    recommended: csp-product-spec   # 在 hub 内生成首条 PMS
    alternatives: [csp-code-spec, csp-wiki, csp-remember]
  status:
    hub: "{{project}}"
    items_indexed: "{{count}}"
    alignment: "{{aligned_count}}/{{total}} aligned"
    phase: define
    ready_for: [spec-generation, code-understanding, closed-loop, query, alignment-check]
```

## References

| 文件 | 内容 |
|------|------|
| `references/project-entry-contract.md` | 四层入场、文件责任、新鲜度、体积与保留规则（入场/治理必读） |
| `references/workspace-layout.md` | 目录结构、权威文件、依赖方向、命名规范 |
| `references/manifest-frontmatter-spec.md` | manifest.json 字段 + 内联 frontmatter 规范 + type 枚举 |
| `references/agents-md-route-contract.md` | AGENTS.md 6 节结构 + 操作路由表 + 模板 |
| `references/closed-loop.md` | 需求→code→test 闭环、knowledge-signal-rules（6信号+7知识类型+目录模板）、冲突检测、definition-of-done |
| `references/wiki-schema-contract.md` | schema.md 契约：字段、auto/user 模式、三类抽取、build 顺序、blocker/error/warning 门 |
| `../references/destructive-operation-safety.md` | 破坏性/可逆操作分类（捕获为 development_pitfall 信号） |
| `scripts/hub_manifest.sh` | CLI 辅助：status / locate / diff / list（纯 git+grep，零依赖） |
| `../references/module-spec-operational-protocol.md` | 运行时纪律共享（断点续跑/文件边界/双重门禁） |

## 人类可读的使用文档

详细操作手册：`docs/guides/PMS-CMS-TMS-GUIDE.md` — 绿地/棕地完整流程，常用指令速查，产物目录速查。
