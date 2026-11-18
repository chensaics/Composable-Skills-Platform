# Archive Template

```markdown
---
tags: [keyword1, keyword2, keyword3]
category: infrastructure | release | debugging | feature | design
related: []
---

# {标题} - {YYYY-MM-DD}

## Summary
一句话概括完成了什么。

## Context
- **Branch**: {分支名}
- **Version**: {版本号（如适用）}
- **Related Issue**: {相关 issue/PR 链接（如适用）}

## Issues & Solutions

### 1. {问题标题}
- **Problem**: {问题描述——症状、影响范围}
- **Root Cause**: {根本原因}
- **Fix**: {解决方案——保留精确命令}

## Key Commands
```bash
# 精确的可复现命令
```

## Lessons Learned
- {关键洞察}
- {下次可以避免的做法}
```

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `tags` | Yes | 2-5 个具体关键词，用于 `grep -ri "tags:.*keyword" .archive/` |
| `category` | Yes | `infrastructure` / `release` / `debugging` / `feature` / `design` |
| `related` | No | 关联归档文件名（不含 `.md`），用于交叉引用 |

## Category Guidelines

| Category | Use When |
|----------|----------|
| `infrastructure` | AWS, 容器, IAM, 网络, 密钥, CI/CD, 云服务 |
| `release` | 发布, TestFlight, 版本管理, Git Flow, CHANGELOG |
| `debugging` | Bug 修复, 错误排查, 性能问题, flaky test |
| `feature` | 功能设计, 实现笔记, 架构决策 |
| `design` | UI/UX, 图标, 视觉设计 |