---
name: csp-quality
description: >
  Quality entry hub — routes testing/security/code-review requests to the correct 
  sub-skill. Use when running tests (pytest/vitest/playwright), security audits 
  (SonarQube/Snyk), or code reviews (CR checklists/lint). 
  Keywords: test, testing, pytest, vitest, security, audit, code review, QA, quality.
version: "0.1.0"
layer: 3
category: patterns
type: workflow
phase: build
domain: testing
role: orchestrator
scope: review
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-test-methodology
  - csp-security-review
  - csp-code-review
  - csp-coding-standards
---

# csp-quality · 质量入口

测试/安全/CR 的质量路由 hub — 根据用户意图分发到正确的 quality 子技能。

## When to Use

- ✅ 跑测试 (`pytest` / `vitest` / `playwright`)
- ✅ 做安全审计 (依赖扫描 / 渗透测试 / 合规审查)
- ✅ 做代码评审 (CR checklist / 编码规范 / lint)
- ❌ 纯 CI/CD 任务 → `csp-devops`
- ❌ 纯编码 → `csp-code`

## Routing

| 用户意图 | route to |
|---------|----------|
| 跑测试 / 写测试用例 | `csp-test-methodology` → `csp-python-testing` / `csp-typescript-testing` |
| 安全审计 | `csp-security-review` |
| 代码评审 | `csp-code-review` |
| lint / 编码规范 | `csp-coding-standards` |

## Quick Check

```bash
# 测试框架是否可加载（05 首个 task 前必跑）
pytest --collect-only 2>&1 | tail -1    # exit 0
vitest run --reporter=json 2>&1 | jq .success  # true

# 安全依赖扫描
pip-audit 2>&1 | grep "vulnerabilities found" || npm audit --json | jq '.metadata.vulnerabilities'
```