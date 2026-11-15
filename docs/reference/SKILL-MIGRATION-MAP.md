# CSP 联邦拆包 — 技能迁移映射

本文件记录从 csp-code（原 csp-core）到各新包的技能迁移方案。

## csp-code → csp-quality (测试/安全/CR)

这些技能目前位于 csp-code 的 workflow/patterns 层，应迁移到 csp-quality：

| 当前路径 | 技能名 | 类型 | 迁移后路径 |
|---------|--------|------|-----------|
| `csp-meta/skills/csp-tdd/` | csp-tdd | guardian | quality-meta/skills/ |
| `csp-meta/skills/csp-verification/` | csp-verification | specialist | quality-workflow/skills/ |
| `csp-workflow/skills/csp-verify-phase/` | csp-verify-phase | workflow | quality-workflow/skills/ |
| `csp-workflow/skills/csp-code-review/` | csp-code-review | reviewer | quality-workflow/skills/ |
| `csp-patterns/skills/csp-security-review/` | csp-security-review | guardian | quality-patterns/skills/ |
| `csp-patterns/skills/csp-defect-mining/` | csp-defect-mining | specialist | quality-patterns/skills/ |
| `csp-patterns/skills/csp-codebase-audit/` | csp-codebase-audit | specialist | quality-patterns/skills/ |
| `csp-patterns/agents/csp-security-reviewer/` | csp-security-reviewer | agent | quality-patterns/agents/ |
| `csp-workflow/skills/csp-qa-cr-review/` | csp-qa-cr-review | specialist | quality-workflow/skills/ |

## csp-code → csp-devops (CI/CD/云/运维)

| 当前路径 | 技能名 | 类型 | 迁移后路径 |
|---------|--------|------|-----------|
| `csp-patterns/skills/csp-cicd-pipelines/` | csp-cicd-pipelines | specialist | devops-patterns/skills/ |
| `csp-patterns/skills/csp-deployment/` | csp-deployment | specialist | devops-patterns/skills/ |
| `csp-patterns/skills/csp-docker-patterns/` | csp-docker-patterns | specialist | devops-patterns/skills/ |
| `csp-patterns/skills/csp-kubernetes-patterns/` | csp-kubernetes-patterns | specialist | devops-patterns/skills/ |
| `csp-patterns/skills/csp-monitoring-alerting/` | csp-monitoring-alerting | specialist | devops-patterns/skills/ |
| `csp-patterns/skills/csp-infrastructure-as-code/` | csp-infrastructure-as-code | specialist | devops-patterns/skills/ |
| `csp-patterns/skills/csp-platform-deploy/` | csp-platform-deploy | specialist | devops-patterns/skills/ |
| `csp-patterns/skills/csp-vps-deploy/` | csp-vps-deploy | specialist | devops-patterns/skills/ |

## csp-code → csp-product (产品管理)

| 当前路径 | 技能名 | 类型 | 迁移后路径 |
|---------|--------|------|-----------|
| `csp-workflow/skills/csp-prd-generation/` | csp-prd-generation | workflow | product-workflow/skills/ |
| `csp-workflow/skills/csp-roadmap-planner/` | csp-roadmap-planner | workflow | product-workflow/skills/ |
| `csp-workflow/skills/csp-product-spec/` | csp-product-spec | specialist | product-workflow/skills/ |
| `csp-meta/skills/csp-spec-contract/` | csp-spec-contract | specialist | product-meta/skills/ |
| `csp-workflow/skills/csp-requirement-decomposition/` | csp-requirement-decomposition | workflow | product-workflow/skills/ |
| `csp-workflow/skills/csp-requirement-prioritization/` | csp-requirement-prioritization | specialist | product-workflow/skills/ |
| `csp-workflow/skills/csp-prd-traceability/` | csp-prd-traceability | specialist | product-workflow/skills/ |
| `csp-workflow/skills/csp-prd-change-impact/` | csp-prd-change-impact | specialist | product-workflow/skills/ |

## 共享保留（留在 csp-code / 所有包共用）

以下技能作为跨包共享基础能力，保留在 csp-code（通过 csp-meta 路由访问）：

| 技能名 | 原因 |
|--------|------|
| csp-coding-standards | 通用编码规范，所有语言都需要 |
| csp-python-coding-standards / java / cpp / ... | 语言专精规范 |
| csp-python-testing / typescript-testing / ... | 语言测试实现，非测试方法论 |
| csp-postgres-patterns / sql-reviewer | DB 层面，属于 code 基础设施 |
| csp-frontend-patterns / backend-patterns | 前端/后端实现，属于 code |
| csp-git-conventions | 通用 Git 规范 |

## 迁移策略

1. **不物理移动文件**（第一步）— 在 federation.yaml 的 routing 中标记归属包
2. **第二步** — 在新包目录中创建符号链接指向原 skills
3. **第三步**（独立仓库时）— 物理移动并更新 import/引用路径