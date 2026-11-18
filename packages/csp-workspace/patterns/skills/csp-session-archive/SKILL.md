---
name: csp-session-archive
description: >
  Archive session learnings, debugging solutions, and deployment logs to
  .archive/YYYY-MM-DD/ as indexed markdown with searchable tags. Auto-indexes
  entries in .archive/MEMORY.md for cross-session knowledge reuse. Use when
  completing a significant task, resolving a tricky bug, deploying, or when
  the user says "archive this". Also use when encountering an error that
  may have been solved before — search archives first.
  Keywords: archive, 归档, save, 保存, session, debug, 排查, learn, 笔记,
  knowledge base, 知识沉淀, memory, history.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: review
domain: other
role: specialist
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-workspace
  - csp-compound-learning
triggers:
  keywords: ["archive", "归档", "save session", "保存会话", "remember this",
    "记录", "knowledge base", "debug log"]
  intents:
    - "user wants to save session learnings"
    - "user completed a significant task and wants to preserve knowledge"
    - "user resolved a tricky bug and wants to document the fix"
    - "user wants to search past solutions"
anti_rationalizations:
  "I'll remember this, no need to archive": "Cross-session memory is unreliable. A 2-minute archive saves hours of re-debugging."
  "This is too small to archive": "Small fixes cause big headaches when forgotten. Archive size doesn't matter — reproducibility does."
---

# Session Archive

会话知识归档——让每次排查和部署的经验在下一次复现时可检索。

## Purpose

跨会话知识保留系统。每次完成重要任务、排查棘手 Bug、或完成部署后，将关键信息写入 `.archive/YYYY-MM-DD/` 目录，并在 `.archive/MEMORY.md` 中建立索引。下次遇到类似问题时先检索归档。

## When to Use

- ✅ 完成重大任务后（部署、迁移、重构、重要功能）
- ✅ 解决了一个棘手的 Bug/排查问题
- ✅ 用户明确说 "archive this" / "记录一下" / "保存"
- ✅ 多步骤操作中有值得复用的经验
- ✅ 遇到错误时 → 先搜索归档看是否有人遇到过
- ✅ 重复执行某流程前 → 先查归档中的历史记录
- ❌ 琐碎的日常对话（没有可复现的知识）
- ❌ 代码本身已经记录的常规逻辑

## Directory Structure

```
.archive/                        ← gitignore（本地知识，不上库）
  MEMORY.md                      ← 索引文件（自动维护）
  2026-01-15/
    cloudwatch-logging-fix.md    ← YAML frontmatter + Markdown 内容
  2026-01-20/
    ecs-deploy-timeout.md
  2026-02-01/
    test-flaky-fix.md
```

## Process

### Step 1: 归档前先查重（1 min）

```bash
# 读取索引检查是否有相关归档
cat .archive/MEMORY.md

# 全文搜索
grep -ri "关键词" .archive/
```

**检查点**：确认是否有相关历史归档。如有，更新已有条目而非新建。

**红线**：不要重复归档相同内容——在已有条目上补充。

### Step 2: 创建归档文件（2 min）

```bash
mkdir -p .archive/YYYY-MM-DD
```

使用模板（`references/TEMPLATE.md`）创建归档文件：

```markdown
---
tags: [tag1, tag2, tag3]
category: infrastructure | release | debugging | feature | design
related: []
---

# {标题} - {YYYY-MM-DD}

## Summary
一句话概括完成了什么。

## Context
- **Branch**: {分支名}
- **Version**: {版本号（如适用）}

## Issues & Solutions

### 1. {问题标题}
- {问题描述}
- **Fix**: {解决方案（含精确命令/代码）}

## Key Commands
{关键的命令行或代码片段}

## Lessons Learned
{可选：对未来有参考价值的洞察}
```

**检查点**：
- `tags` 字段有助于 `grep -ri "tags:.*关键词" .archive/`
- `category` 只取五个值之一：`infrastructure` / `release` / `debugging` / `feature` / `design`
- `related` 是关联归档的文件名（不含 `.md`）

### Step 3: 更新索引（1 min）

在 `.archive/MEMORY.md` 中添加一行（按分类）：

```markdown
## MEMORY.md

# Session Archive Index

## infrastructure
- [2026-01-20 ECS Deploy Timeout Fix](2026-01-20/ecs-deploy-timeout.md) — IAM role missing ecs:UpdateService
- [2026-01-15 CloudWatch Logging Fix](2026-01-15/cloudwatch-logging-fix.md) — log group retention policy

## release
- [2026-02-01 v1.2.0 Release](2026-02-01/v1.2.0-release.md) — TestFlight review passed after 3rd attempt

## debugging
- [2026-01-18 Flaky Test Fix](2026-01-18/test-flaky-fix.md) — Race condition in async test setup

## feature

## design
```

**检查点**：索引文件中每个条目都有一行描述，通过链接可达。

### Step 4: 检索归档（遇到问题时）

```bash
# 全文搜索
grep -ri "error message" .archive/

# 按标签搜索
grep -ri "tags:.*aws.*ecs" .archive/

# 按分类浏览
cat .archive/MEMORY.md | grep "## debugging" -A 20
```

## Key Principles

- **可复现性优先**：归档的价值在于下次能复现——保留精确命令，不保留泛泛描述
- **小即是美**：一个聚焦的归档文件 > 一个大而全的日志
- **标签驱动检索**：tags 是主要检索入口，认真写
- **索引必须更新**：写归档文件 = 必须更新 MEMORY.md，否则等于没写
- **本地知识不提交**：`.archive/` 在 `.gitignore` 中

## Anti-Patterns

| Anti-Pattern | 信号 | 正确做法 |
|-------------|------|---------|
| 归档像日记 | "今天做了很多事..." | 聚焦问题和解决方案，不记录日常 |
| 不做索引 | MEMORY.md 缺条目 | 写归档时立刻更新索引 |
| 命令不完整 | "运行修复脚本" | 保留精确的 `curl`/`aws`/`kubectl` 命令 |
| 标签太宽泛 | `tags: [bug]` | 用具体标签：`[aws, ecs, iam, deploy]` |
| 归档提交到 Git | .archive 出现在 PR 中 | 确保 `.gitignore` 含 `.archive/` |

## Verification Checklist

- [ ] `.archive/MEMORY.md` 索引文件存在且最新
- [ ] 归档文件含 YAML frontmatter（tags, category, related）
- [ ] tags 至少 2 个具体关键词
- [ ] 解决方案含可复现的精确命令/代码
- [ ] `.gitignore` 含 `.archive/`
- [ ] 无重复归档——先在 MEMORY.md 查过

## Examples

### Example 1: Bug 修复归档

```
输入: "Deploy 报了 IAM 权限错误，搞了 2 小时才修好，记录一下"
处理:
  1. grep -ri "iam" .archive/ → 无现有归档
  2. 创建 .archive/2026-01-20/iam-ecs-deploy-fix.md
  3. 写入: tags: [aws, iam, ecs, deploy], category: infrastructure
  4. 核心命令: aws iam attach-role-policy --role-name ecsTaskRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
  5. 更新 MEMORY.md infrastructure 部分
输出: "已归档到 .archive/2026-01-20/iam-ecs-deploy-fix.md"
```

### Example 2: 检索历史解决方案

```
输入: "这个 test 又 flaky 了，之前修过一次"
处理:
  1. grep -ri "flaky" .archive/ → 找到 .archive/2026-01-18/test-flaky-fix.md
  2. 读取归档 → 发现是 async test setup 的 race condition
  3. 复用上次的修复方案
输出: "找到历史归档，问题原因是 test setup 中 await 缺失导致的竞态条件"
```

## Related Skills

- [[csp-workspace]] — 工作套件入口，含 Notion/Linear/IM 集成
- [[csp-compound-learning]] — 结构化知识沉淀（更正式的学习文档）