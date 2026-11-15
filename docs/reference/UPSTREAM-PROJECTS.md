# 上游参考项目（Upstream Projects）

> CSP 技能优化参考库清单与可借鉴能力索引
> 最后更新：2026-11-15

## 概述

`开源项目参考/` 目录收录了 15 个在 CSP 设计过程中参考过的外部开源项目，用于技能体系优化、方法论补充和能力对齐。本文档记录每个项目的来源、CSP 集成状态，及后续技能优化方向。

项目分为三类：

- **核心已整合（Core Integrated）**：已深度借鉴并融入 CSP 五层架构，在 README 鸣谢中列出
- **候选参考（Candidate Reference）**：持续观察，部分能力待评估吸收
- **本地材料（Local Only）**：指向 CSP 自身仓库，不是独立上游项目

## 快速同步

```bash
# 在新机器上一键 clone 全部参考项目
./scripts/sync-reference-projects.sh --target "$HOME/csp-reference-projects" --clone-only

# 更新已 clone 的项目
./scripts/sync-reference-projects.sh

# 查看本地状态
./scripts/sync-reference-projects.sh --status
```

---

## 目录

1. [核心已整合](#核心已整合-core-integrated)
2. [候选参考](#候选参考-candidate-reference)
3. [本地材料](#本地材料-local-only)
4. [README 鸣谢链接校正](#readme-鸣谢链接校正)
5. [后续优化路线](#后续优化路线)

---

## 核心已整合（Core Integrated）

### 1. ECC

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/affaan-m/ECC.git` |
| 本地目录 | `开源项目参考/ECC` |
| 定位 | 视频编辑 AI 驱动的多 Agent 技能库 |
| CSP 借鉴 | 技能库组织方式、skill-creator 模板、code-simplifier / refactor-cleaner |
| 优化方向 | 技能规范化模板可同步更新，可引入更多 Agent 编排模式 |

> **README 链接注**：README 中记载的 `burningion/video-editing-ai` 已不可访问，当前实际仓库为 `affaan-m/ECC`。若未来上游恢复原链接，应更新。

### 2. get-shit-done（GSD）

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/gsd-build/get-shit-done.git` |
| 本地目录 | `开源项目参考/get-shit-done` |
| 定位 | 项目管理与开发生命周期工作流（plan → execute → verify → ship） |
| CSP 借鉴 | `csp-plan` / `csp-execute-phase` / `csp-ship` 全流程，worktree 隔离执行 |
| 优化方向 | 可增强 CI/CD pipeline 集成、多环境部署策略 |

> **README 链接注**：`benjiwoss/get-shit-done` 已重定向至 `gsd-build/get-shit-done`。

### 3. oh-my-claudecode（OMC）

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/Yeachan-Heo/oh-my-claudecode.git` |
| 本地目录 | `开源项目参考/oh-my-claudecode` |
| 定位 | Claude Code 运行时增强：autopilot、wiki、remember、文件整理 |
| CSP 借鉴 | `csp-autopilot`（动态 DAG 编排）、`csp-wiki`（持续学习引擎）、知识管理 |
| 优化方向 | autopilot 可引入更复杂的并行分支策略和回退恢复机制 |

> **README 链接注**：`ruvcode/oh-my-claudecode` 已重定向至 `Yeachan-Heo/oh-my-claudecode`。

### 4. Superpowers

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/obra/superpowers.git` |
| 本地目录 | `开源项目参考/superpowers` |
| 定位 | 元技能与方法论（brainstorming, TDD, debugging, code review, plans 等） |
| CSP 借鉴 | Layer 1 (csp-meta) 方法论层核心来源：brainstorming、TDD、调试、code review、plan |
| 优化方向 | 关注 Superpowers 的 writing-skills 和 verification-before-completion 更新 |

> **README 链接注**：`SimpleVibe/Superpowers` 已重定向至 `obra/superpowers`。

### 5. spec-kit

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/github/spec-kit.git` |
| 本地目录 | `开源项目参考/spec-kit` |
| 定位 | 规范驱动开发（Spec-Driven Development），GitHub 官方 |
| CSP 借鉴 | PMS/CMS/TMS 三说明书治理层、产物接力机制、规范驱动方法论 |
| 优化方向 | 跟进 GitHub spec-kit 的更新，完善 PMS 产品说明书模板 |

> **README 链接注**：`microsoft/spec-kit` 已重定向至 `github/spec-kit`。

### 6. Agency-Agents

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/msitarzewski/agency-agents.git` |
| 本地目录 | `开源项目参考/agency-agents` |
| 定位 | 专业化 AI Agent 定义集合 |
| CSP 借鉴 | Layer 3 (csp-patterns) 中 116 agents 的参考模板和交互模式 |
| 优化方向 | 可引入更多垂直领域 Agent（如数据分析、文档编写） |

### 7. awesome-copilot

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/github/awesome-copilot.git` |
| 本地目录 | `开源项目参考/awesome-copilot` |
| 定位 | GitHub Copilot Skills & Agents 精选合集（~40 个精选融入 CSP） |
| CSP 借鉴 | 命令集（154 commands）和 Cursor 规则（39 rules）的参考来源 |
| 优化方向 | 周期同步 GitHub Copilot 生态新增的能力和范式 |

---

## 候选参考（Candidate Reference）

以下项目尚未深度整合到 CSP 核心架构中，但存在明确的借鉴价值，按优先级排列。

### 8. agent-skills

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/addyosmani/agent-skills.git` |
| 本地目录 | `开源项目参考/agent-skills` |
| 定位 | Addy Osmani 的 Agent Skills 集合（24 skills + 4 agents + 8 commands） |
| 整合状态 | 已完成 Gap Analysis，见 `开源项目参考/AGENT-SKILLS-GAP-ANALYSIS.md` |
| 优化方向 | **P0**: interview-me（需求澄清）、doubt-driven-development（开发中质疑）、context-engineering（上下文工程）**P1**: observability-and-instrumentation、deprecation-and-migration、source-driven-development、browser-testing-with-devtools **P2**: idea-refine、shipping checklist、orchestration patterns |

### 9. BMAD-METHOD

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/bmad-code-org/BMAD-METHOD.git` |
| 本地目录 | `开源项目参考/BMAD-METHOD` |
| 定位 | Breakthrough Method for Agile AI-Driven Development |
| 优化方向 | 敏捷 AI 开发方法论、角色分工体系可参考 |

### 10. claude-skills

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/alirezarezvani/claude-skills.git` |
| 本地目录 | `开源项目参考/claude-skills` |
| 定位 | Claude Code 技能集合 |
| 优化方向 | 对比分析技能覆盖度、发现 CSP 缺失的场景 |

### 11. claude-standard-dev-team

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/xuanbingbingo/claude-standard-dev-team.git` |
| 本地目录 | `开源项目参考/claude-standard-dev-team` |
| 定位 | Claude Code 标准开发团队配置 |
| 优化方向 | 团队协作模式、多 Agent 角色分工参考 |

### 12. coding-skill-orchestrator

| 属性 | 值 |
|------|-----|
| 仓库 | `git@github.com:chensaics/coding-skill-orchestrator.git`（私有） |
| 本地目录 | `开源项目参考/coding-skill-orchestrator` |
| 定位 | 编码技能编排器 |
| 同步注意 | 使用 SSH URL，新机器需先配置 GitHub SSH Key |

### 13. comet

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/rpamis/comet.git` |
| 本地目录 | `开源项目参考/comet` |
| 定位 | Java 项目快速开发框架 |
| 优化方向 | 后端项目模板、快速脚手架模式可参考 |

### 14. compound-engineering-plugin

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/EveryInc/compound-engineering-plugin.git` |
| 本地目录 | `开源项目参考/compound-engineering-plugin` |
| 定位 | 复合工程插件 |
| 优化方向 | 多技能组合模式、插件架构可参考 |

### 15. impeccable

| 属性 | 值 |
|------|-----|
| 仓库 | `https://github.com/pbakaus/impeccable.git` |
| 本地目录 | `开源项目参考/impeccable` |
| 定位 | Paul Bakaus 的前端 UI 精修技能（audit/polish/harden/animate） |
| 优化方向 | 前端 UI 审查、视觉打磨、动画规范可整合到 CSP 前端 skill |

---

## 本地材料（Local Only）

以下目录位于 `开源项目参考/` 但并非独立上游项目，仅作为 CSP 本地构建材料：

| 目录 | 说明 |
|------|------|
| `batch-module-dev` | 指向 CSP 自身仓库的本地别名（`git@github.com:maythyai/code-skills-package.git`） |
| `skills-zip` | CSP 自身仓库的另一份签出（包含 `playwright-cli-*.zip` 等打包产物） |

`scripts/sync-reference-projects.sh` 的注册表中的项目清单**不包含**这两个目录。

---

## README 鸣谢链接校正

根目录 `README.md` 和 `README_zh.md` 的「鸣谢/Acknowledgments」章节中，部分项目链接已失效或发生迁移：

| README 记载 | 当前实际 | 状态 |
|-------------|---------|------|
| `burningion/video-editing-ai` | `affaan-m/ECC` | 404 |
| `benjiwoss/get-shit-done` | `gsd-build/get-shit-done` | 重定向 |
| `ruvcode/oh-my-claudecode` | `Yeachan-Heo/oh-my-claudecode` | 重定向 |
| `SimpleVibe/Superpowers` | `obra/superpowers` | 重定向 |
| `microsoft/spec-kit` | `github/spec-kit` | 重定向 |
| `msitarzewski/agency-agents` | ✓ 正确 | — |
| `github/awesome-copilot` | ✓ 正确 | — |

> 建议后续更新 README 中的鸣谢链接，指向当前实际可访问的仓库地址。

---

## 后续优化路线

### 短期（Phase 1）

- [ ] 更新 README 鸣谢链接至当前正确地址
- [ ] 从 `agent-skills` 引入 P0 级别技能（interview-me、doubt-driven-development、context-engineering）

### 中期（Phase 2）

- [ ] 从 `agent-skills` 引入 P1 级别技能（observability、deprecation、source-driven、browser-testing）
- [ ] 对 `BMAD-METHOD`、`claude-skills`、`impeccable` 进行 Gap Analysis
- [ ] 建立季度同步机制：运行 `scripts/sync-reference-projects.sh` 并审查变更

### 长期（Phase 3）

- [ ] 建立参考项目的自动化变更监控（通过 CI 检测上游更新）
- [ ] 为每个核心参考项目维护独立的 Gap Analysis 文档
- [ ] 将聚类分析结果反馈到 CSP 技能覆盖度地图