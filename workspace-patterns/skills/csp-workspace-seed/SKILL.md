---
name: csp-workspace-seed
description: >
  Use when connecting to Notion, Linear, Feishu, WeChat, or managing knowledge
  bases, project tasks, IM integrations, or productivity workflows.
  Keywords: Notion, Linear, 飞书, 企业微信, knowledge base, 知识库, 项目管理, IM.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: other
role: specialist
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep, WebFetch]
---

# Workspace Seed

工作套件的入口 — 链接 Notion/Linear/飞书/微信，不是构建它们。

## Principle

Skills 教 Agent 使用这些产品的 API/SDK/CLI，不构建替代品。
- ✅ "用 Notion API 把本次会议的 action items 同步到数据库"
- ❌ "构建一个 Notion"

## Routing

| 用户意图 | 链接外部产品 | route to |
|---------|-------------|----------|
| 知识库同步 | Notion / Obsidian | `notion-api` → `csp-knowledge-hub` |
| 项目管理 | Linear / Jira | `linear-api` / `jira-api` |
| IM 消息推送 | 飞书 / WeCom / 钉钉 / Slack | webhook → `csp-automation` |
| 效率工具 | Todoist / Things / 日历 | API integration |

## Quick Check

```bash
# Notion token 是否可用
curl -s -H "Authorization: Bearer $NOTION_TOKEN" \
  "https://api.notion.com/v1/users/me" | jq .type

# Linear API 是否可用
curl -s -H "Authorization: $LINEAR_API_KEY" \
  "https://api.linear.app/graphql" -d '{"query":"{ viewer { id } }"}'

# 飞书 webhook 是否可达
curl -s "$FEISHU_WEBHOOK_URL" -d '{"msg_type":"text","content":{"text":"test"}}'
```