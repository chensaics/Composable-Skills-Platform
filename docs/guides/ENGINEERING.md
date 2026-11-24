# 工程管线与供应链安全

> 本文承接 README「工程与供应链安全」章节的细节。面向贡献者与关注安全的安装者。
> 权威约定见根目录 [CLAUDE.md](../../CLAUDE.md)；多维审查报告见 [project-review-2026-08.md](../reports/project-review-2026-08.md)。

## 单一真相源与派生数据

`SKILL.md` frontmatter（v2/v3 字段：`phase`/`domain`/`scope`/`tools`/`deprecated`/`redirect` 等）是唯一真相源。以下文件全部由脚本派生，**禁止手编**：

| 派生产物 | 生成脚本 |
|----------|----------|
| `csp-router/registry.json` | `shared/scripts/build-registry.mjs` |
| `csp-router/skill-metadata.yaml` | `scripts/build-skill-metadata.mjs` |
| `csp-router/triggers.yaml` | `scripts/generate-triggers.mjs` + `scripts/fix-triggers.mjs` |
| `csp-router/skpg/graph.json` + `index.json` | `scripts/build-skpg.mjs` + `scripts/build-skpg-edges.mjs` |
| `docs/csp-page/`（在线仪表盘） | `shared/scripts/build-page.mjs` |
| `assets/dashboard-overview.svg` | `shared/scripts/build-overview-svg.mjs` |

一键重建：

```bash
npm run build:all     # registry → metadata → triggers → graph → page → overview → version:sync
npm run validate:all  # skill-v2/v3 + triggers + registry schema 校验
npm test              # validate:all + graph 重建 + node --test 不变量断言
```

全部脚本为零运行时依赖的 Node ≥18 ESM。共享 YAML 解析器位于 `shared/scripts/lib/yaml.mjs`。

## 脚手架与 SDK

```bash
# 脚手架一个通过校验的新 skill
node bin/csp-sdk.mjs init-skill csp-my-skill --layer 3 --phase build

# 其他子命令
node bin/csp-sdk.mjs query <sub>
node bin/csp-sdk.mjs doctor
node bin/csp-sdk.mjs version
```

未知子命令以非零码退出（不静默假通过）。新增/编辑 skill 使用 v3 模板 `shared/templates/SKILL-TEMPLATE-v3.md`，编写前加载 `csp-writing-skills`，验证：`node scripts/validate-skill-v3.mjs <skill-path> --strict`。

## 安装器结构与远程完整性

- `install.sh` 拆分为 `install.sh` + `lib/platforms.sh` + `lib/bootstrap.sh`，便于维护。
- **远程 bootstrap 完整性**：设置 `CSP_SHA256=<hash>` 可校验下载的压缩包（每次安装都会打印实际 hash，可固定）。
- **命令注入防护**：`CSP_BRANCH` 经 `^[A-Za-z0-9._-]+$` 白名单校验。
- 选择性安装：`--stacks python,typescript`（按技术栈）、`--layers router,meta`（按层级）、`--minimal`（仅 router + meta）、`--dry-run`（预览）。

## Skill 内容规范（强制）

所有新增/移植技能必须遵守（详见 CLAUDE.md）：

- 无作者信息、无谱系字段（`origin:` 禁止）、技能目录内无 LICENSE 文件（包级许可仅根目录 MIT）。
- 无内部 URL（功能性 URL 用占位符 + 环境变量参数化）、无个人环境硬编码。
- 无构建产物入库（`__pycache__/`、`*.pyc`、`*.bak`、`.DS_Store`）。
- 移植外部技能先确认许可证兼容（MIT 包禁止引入 NC/SA 等限制性条款内容）。

## 计数一致性守卫

`scripts/count-skills.mjs` 以 `registry.json` 为基准，检查 README / CLAUDE.md / docs 中硬编码的条目数是否一致，不一致时退出码 1。建议接入 CI，让陈旧数字在构建期失败而非随发布流出。

```bash
npm run count:skills
```

## 版本管理

SemVer（X=架构/系统重构，Y=模块/功能，Z=修复），攒批发布——一个版本可含多个功能/修复，按整批最高级别一次 bump。详见 [VERSIONING.md](../reference/VERSIONING.md)。