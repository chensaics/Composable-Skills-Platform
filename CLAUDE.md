# CSP — Composable Skills Platform v0.12.0

面向一人公司与超级个体的 AI 技能操作系统。可组合的多领域 AI 技能平台，联邦路由 + 五层架构 + 技能蒸馏。

## Architecture

```
L0  csp-router    — task classification + skill selection (always loaded, ~800 tokens)
L1  packages/csp-code/csp-meta      — methodology: brainstorming, TDD, debugging, spec-driven (32 entries)
L2  packages/csp-code/csp-workflow  — project lifecycle: plan → execute → verify → ship (212 entries)
L3  packages/csp-code/csp-patterns  — language/framework patterns, reviewers, build-resolvers (406 entries)
L4  packages/csp-code/csp-runtime   — autopilot, ralph, wiki, remember, self-improve (58 entries)
Total: 709 entries across 5 layers (397 skills + 116 agents + 153 commands + 36 workflows + 7 tools; 2 deprecated, carry redirect targets)
```

## Skill 内容规范（强制，所有新增/移植技能必须遵守）

- **无作者信息**：禁止 `author:` 字段、个人姓名、署名/来源脚注；技能只保留内容本身。
- **无 LICENSE 文件**：技能目录内不得包含 LICENSE/NOTICE/COPYING；包级许可仅根目录 `LICENSE`（MIT）。
- **无谱系字段**：frontmatter 禁止 `origin:`（含 `metadata:` 内嵌）；`source:` 仅允许指向公开项目（如 GitHub 开源仓库）。
- **无内部 URL**：禁止 `*.alibaba-inc.com`、`*.antfin.com` 等内部域名；功能性 URL 用占位符（如 `{CR_API_BASE}`）+ 环境变量参数化。公开链接（github.com、官方文档等）保留。
- **无个人环境硬编码**：本机路径/端口等用环境变量或相对路径参数化。
- **无构建产物**：`__pycache__/`、`*.pyc`、`*.bak`、`.DS_Store` 不入库。
- **移植外部技能**：先确认许可证兼容（MIT 包禁止引入 NC/SA 等限制性条款内容）；内容改写通用化，不带来源归属。

## Engineering

Build / validate / test pipeline (all zero-runtime-dependency Node ≥ 18 ESM):

```bash
npm run build:all      # registry → metadata → triggers → graph → page (one-shot rebuild)
npm run validate:all   # skill-v2 + triggers + registry schema validation
npm test               # validate:all + build:graph + node --test test/ (20 invariants)
```

- **Single source of truth**: `SKILL.md` frontmatter (v2: `phase`/`domain`/`scope`/`tools`/`deprecated`/`redirect`) → derived `registry.json` / `triggers.yaml` / `skill-metadata.yaml` / `skpg/graph.json` / `index.json` / `docs/csp-page`. Never hand-edit derived data.
- **Shared YAML parser**: `shared/scripts/lib/yaml.mjs` (handles `>-`/`|-` multiline, inline + block arrays, nested objects, type coercion).
- **`csp-sdk` CLI**: `query <sub>` · `doctor` · `version` · `init-skill <name> --layer <1-4>` (scaffolds a validate-passing SKILL.md). Unknown subcommands exit non-zero (no silent stub-pass).
- **`install.sh`**: split into `install.sh` (930 lines) + `lib/platforms.sh` + `lib/bootstrap.sh`. CSP_BRANCH whitelisted (`^[A-Za-z0-9._-]+$`); remote bootstrap supports `CSP_SHA256` integrity pinning.
- **Tests**: `test/csp-invariants.test.mjs` (registry shape, graph consistency, triggers integrity, version sync across 5 files, csp-sdk contract, npm-pack hygiene).
- **Git push fallback (SSH 22 to github.com down)**: if `git push` / `git ls-remote` over `git@github.com` hang (port 22 blocked), switch to the HTTPS + `gh` token channel — do **not** keep retrying SSH:
  ```bash
  gh auth setup-git                                    # wire gh as the git credential helper for github.com
  git remote set-url origin https://github.com/maythyai/code-skills-package.git
  git push origin master                                # now HTTPS, authed by the gh token (no PAT entry)
  ```
  Verify with `gh auth status` (expects `Git operations protocol: https` + a token with `repo` scope). `gh Release` creation over HTTPS follows the same channel. Revert to SSH later: `git remote set-url origin git@github.com:maythyai/code-skills-package.git`. The commit is always safe locally first; only the push is channel-dependent.

## Docs

- [ARCHITECTURE.md](./docs/architecture/ARCHITECTURE.md) — full architecture design
- [SKILL-INDEX.md](./docs/reference/SKILL-INDEX.md) — complete skill index
- [USER-GUIDE.md](./docs/guides/USER-GUIDE.md) — user guide
- [INSTALL.md](./docs/guides/INSTALL.md) — installation guide
- [UPDATE.md](./docs/guides/UPDATE.md) — update guide
- [ENGINEERING.md](./docs/guides/ENGINEERING.md) — build pipeline & supply-chain safety
- [VERSIONING.md](./docs/reference/VERSIONING.md) — version management (X=arch/system-refactor, Y=module/feature, Z=fix)
- [CONTRIBUTING.md](./CONTRIBUTING.md) — how to contribute a skill or fix (quality tiers, AI usage policy, skill review process)
- [SKILL-TEMPLATE-v3.md](./shared/templates/SKILL-TEMPLATE-v3.md) — v3 增强版模板（quality tiers, type classification, CSO, token budgets）
- [SKILL-SPEC.md](./docs/reference/SKILL-SPEC.md) — v3 规范（frontmatter + body structure requirements）
- [scripts/README.md](./scripts/README.md) — build/validate/maintenance tooling reference
- [docs/reports/](./docs/reports/project-review-2026-08.md) — audit reports + upgrade plans (project-review-2026-08, REVIEW-PROGRAMMING-SKILLS, cross-layer-testing-case-study)

## CSP 知识中枢 & Agent 团队

本项目用 `.csp/` 作为**编程管理统一文档库**（PMS/CMS/TMS + 流水线产物），`.claude/agents/` 为多智能体团队。约定详见 `.claude/agents/README.md`。

### 知识中枢（进入 workspace 先读）
- `.csp/AGENTS.md`：路由契约。
- `.csp/manifest.json`：唯一产物索引（`source_id`+`content_hash`+`build_status`）。
- `.csp/lifecycle-state.json`：流水线阶段状态（现在第几步、下一步谁）。
- **若 `.csp/AGENTS.md` 不存在** → 先运行 `knowledge-hub` agent 初始化：建 `AGENTS.md`/`manifest.json`/`lifecycle-state.json` + 棕地 CMS 蒸馏（`.csp/code-spec/`）+ 既有文档整改（Phase 1.5）。这是整条链路（00→07）的第一步，未初始化不进 01。

### Agent 团队（`.claude/agents/`）
- 外环 `roadmap-planner`（方向调研+战略锚点+版本号规则+版本序列+集成必要性审视+规划级 PRD SPEC，跑一次）
- 内环：`knowledge-hub`(00) → `prd-writer`(01) → `decomposer`(02) → `tech-designer`(03) → `task-breaker`(04) → `dev-lead`(05) → `release-manager`(06) → `reviewer`(07)
- 主调度：`lifecycle-orchestrator`（读 lifecycle-state 自动派 agent；gate 即授权，仅破坏性/无解才问人）
- 05 角色：`backend-engineer`/`frontend-engineer`/`db-engineer`/`qa-engineer`（由 dev-lead spawn + worktree 并行）

### 文档边界
- **三层定位**（权威见 `docs/README.md`）：`README.md`（根，门面+路标，不堆细节）→ `docs/`（对外人类文档：安装/使用/架构/技能编写/分析/PRD 原文/战略）→ `.csp/`（对内 agent 产物库，人不直接读）。
- `.csp/` = 编程管理产物（PMS/CMS/TMS + specs/tasks/tech-design/traceability/artifacts/ship/ops/milestones + planning/spark/writer-memory/intel），git 跟踪。
- `docs/` = 对外人类文档（给人读，非流水线驱动）；门面 `README.md` 与发布元数据 `CHANGELOG.md`/`LICENSE` 在根目录，不属 `docs/`。
- 测试运行证据（截图/DOM/联动契约/进度文件）统一落 `.csp/artifacts/verify/evidence/` 与 `.csp/artifacts/verify/`，禁止散落根目录裸 `evidence/` 或 `.csp-*-test/`。L2 csp-workflow 生命周期产物落 `.csp/planning/`（原 `.planning/`），Spark 设计链产物落 `.csp/spark/`（原 `spark-output/`），写作记忆落 `.csp/writer-memory/`（原 `.csp-writer-memory/`）——所有 skill 产物一律进 `.csp/` 或 `docs/`，不散落根目录。
- 版本号默认 SemVer（X.Y.Z），不自动用日期形式 tag；攒批发布——一个版本可含多个功能/修复，不逐功能 bump（按整批最高级别一次 bump）。

### 用法
- 端到端：说"跑流程/从 00 开始/推进" → `lifecycle-orchestrator` 自动推进到 06 发布。
- 单阶段：说"写 PRD/拆 task/发版/复盘" → 对应 agent。
- 产物遵循 `.csp/` 格式（front-matter 互链 + manifest 回写 + lifecycle-state 推进）。

<!-- csp-begin (do not edit between these markers) -->
# CSP (Code Skills Package)

本项目已安装 CSP 技能包（397 个 skills，五层架构）。

## 使用方式

在 CLAUDE.md 中添加路由指令即可自动使用：

```
使用 CSP (Code Skills Package) 技能包。当用户给出任务时,先通过 csp-router 路由到合适的 skill 组合。
```

## 核心规则

1. **收到任务时，先通过 csp-router 路由** — 识别任务类型并加载对应 skill 组合
2. **设计先于编码** — 功能需求先做 brainstorming 和 plan
3. **测试先于实现** — 写代码前先写测试（TDD）
4. **验证先于完成** — 声称完成前必须运行验证命令

## 技能质量

新增/编辑 skill 请使用 v3 模板 (`shared/templates/SKILL-TEMPLATE-v3.md`)，按技能类型（technique/pattern/reference/workflow/guardian）选择 Required Sections，目标 Tier B 以上。
编写前加载 `csp-writing-skills` 获取结构化质量指南。
验证：`node scripts/validate-skill-v3.mjs <skill-path> --strict`

<!-- csp-end -->
