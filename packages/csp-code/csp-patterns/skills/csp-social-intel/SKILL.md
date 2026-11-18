---
name: csp-social-intel
description: >
  Read-only social media data retrieval for research, competitive analysis,
  and user feedback collection. Two channels: Reddit (public JSON API, no auth
  required) and Twitter/X (twitterapi.io, requires API key). Search posts,
  get user profiles, retrieve discussions. Complements csp-crosspost which
  handles writing/publishing. Use when researching market sentiment, finding
  user pain points, tracking competitor mentions, or gathering social proof.
  Keywords: social media, Reddit, Twitter, X, search posts, 社交搜索,
  user feedback, 用户反馈, market research, competitive analysis.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: define
domain: patterns
role: specialist
scope: analysis
invocation: user
tools: [Read, Bash, WebFetch, WebSearch]
related_skills:
  - csp-crosspost
  - csp-deep-research
  - csp-micro-product-scout
triggers:
  keywords: ["Reddit", "Twitter", "X", "社交搜索", "social media", "搜索帖子",
    "user feedback", "用户反馈", "market research", "reddit search"]
  intents:
    - "user wants to search social media for research"
    - "user wants to find user pain points on Reddit"
    - "user wants to track competitor mentions on Twitter/X"
---

# Social Intel

社交平台数据采集（只读）——为调研和竞品分析收集公开社交数据。

## Purpose

提供两个社交平台的数据获取能力：
- **Reddit**：公开 JSON API，无需认证，零门槛获取帖子和讨论
- **Twitter/X**：twitterapi.io SDK，需要 API key，适合深度用户分析

**这只做数据读取**——内容分发/发布请用 [[csp-crosspost]]。

## When to Use

- ✅ 做市场调研——搜索用户对某产品的评价
- ✅ 找用户痛点——搜索 "I hate" / "frustrated with" / "wish X could"
- ✅ 竞品分析——追踪竞品在各平台的讨论量
- ✅ 验证需求假设——搜索 "any tool that" / "looking for"
- ✅ 收集社会证明——提取用户的积极评价和用例
- ❌ 发布/分发内容——用 csp-crosspost
- ❌ 需要中国社交平台（微信/微博/小红书）——不在本 skill 范围
- ❌ 需要实时大数据分析——本 skill 适合 ad-hoc 查询

## Channels

### Channel 1: Reddit（推荐首选）

**优势**：无需 API key，公开 JSON API，论坛式讨论质量高

**快速验证**：
```bash
curl -s "https://www.reddit.com/r/python/hot.json?limit=3" -H "User-Agent: Research/1.0"
```

**搜索帖子**：
```bash
# 全站搜索
curl -s "https://www.reddit.com/search.json?q={query}&sort=relevance&limit=20&raw_json=1" \
  -H "User-Agent: Research/1.0"

# 指定子版块搜索
curl -s "https://www.reddit.com/r/{subreddit}/search.json?q={query}&restrict_sr=1&sort=top&t=year&limit=20&raw_json=1" \
  -H "User-Agent: Research/1.0"
```

**获取热门帖子**：
```bash
# hot / new / top / rising
curl -s "https://www.reddit.com/r/{subreddit}/{sort}.json?limit=20&raw_json=1" \
  -H "User-Agent: Research/1.0"
```

**获取帖子和评论**：
```bash
curl -s "https://www.reddit.com/comments/{post_id}.json?limit=50&raw_json=1" \
  -H "User-Agent: Research/1.0"
```

**获取子版块信息**：
```bash
curl -s "https://www.reddit.com/r/{subreddit}/about.json?raw_json=1" \
  -H "User-Agent: Research/1.0"
```

**Reddit 搜索策略**：
- 用 `site:reddit.com {query}` 在 WebSearch 中也能搜索
- 子版块搜索优先于全站搜索（信号更聚焦）
- `sort=top&t=year` 找高质量讨论
- `sort=new` 找最新反馈

### Channel 2: Twitter/X（需要 API key）

**前置条件**：设置 `TWITTERAPI_API_KEY` 环境变量
```bash
export TWITTERAPI_API_KEY="your_api_key"
```

**搜索推文**：
```bash
curl -s "https://api.twitterapi.io/twitter/tweet/advanced_search?query={query}&queryType=Latest" \
  -H "X-API-Key: $TWITTERAPI_API_KEY"
```

**获取用户信息**：
```bash
curl -s "https://api.twitterapi.io/twitter/user/info?userName={username}" \
  -H "X-API-Key: $TWITTERAPI_API_KEY"
```

**获取用户推文**：
```bash
curl -s "https://api.twitterapi.io/twitter/user/last_tweets?userName={username}" \
  -H "X-API-Key: $TWITTERAPI_API_KEY"
```

**X 搜索语法**（高级搜索）：
```
from:{username}              # 来自特定用户
from:{username} since:2026-01-01 until:2026-06-01  # 日期范围
-filter:retweets             # 排除转推
filter:media                 # 仅含媒体
min_faves:1000               # 至少 1000 赞
```

## Research Workflow

### Step 1: 定义研究范围（1 min）

明确三个问题：
1. **研究目标**：想了解什么？（用户痛点/竞品评价/功能需求）
2. **目标平台**：选择 Reddit（论坛深度讨论）/ X（实时趋势和情绪）/ 两者都用
3. **关键词**：列出 2-3 个搜索短语变体

### Step 2: 采集数据（3 min per platform）

**Reddit 策略**：
```bash
# Round 1: 宽泛搜索
"{product}" → 找出主要讨论所在的子版块
# Round 2: 在目标子版块深度搜索
"{product} review" / "{product} alternative" / "wish {product} had"
# Round 3: 痛点搜索
"hate {product}" / "{product} broken" / "{product} missing"
```

**X 策略**：
```bash
# 品牌监控
from:{competitor_handle} → 看竞品自己发什么
"{product} -filter:retweets" → 看用户在说什么
# 趋势搜索
"{keyword} min_faves:100" → 找被广泛讨论的内容
```

### Step 3: 分析信号强度

| 信号 | Reddit | X | 说明 |
|------|--------|---|------|
| 高质量讨论 | ⭐⭐⭐ | ⭐ | Reddit 论坛格式天然适合深度讨论 |
| 实时情绪 | ⭐ | ⭐⭐⭐ | X 适合捕捉最新趋势 |
| 用户痛点 | ⭐⭐⭐ | ⭐⭐ | Reddit 用户写得更详细 |
| 竞品公关 | ⭐ | ⭐⭐⭐ | 竞品在 X 上的官方动态 |
| 社会证明 | ⭐⭐⭐ | ⭐⭐ | 用户在 Reddit 写的推荐更可信 |
| 开发者反馈 | ⭐⭐⭐ | ⭐⭐ | r/programming, r/webdev 等质量极高 |

### Step 4: 输出调研摘要

```markdown
## {Topic} Social Intel Report

### Overview
- Platforms: Reddit (N posts), X (N tweets)
- Time Range: {period}
- Search Terms: {queries used}

### Key Findings
1. **Top Pain Points**: {用户最抱怨的 3 个问题}
2. **Feature Requests**: {用户最想要的 3 个功能}
3. **Competitive Mentions**: {竞品被讨论的上下文}
4. **Sentiment Summary**: {正面/负面/中性比例}

### Representative Quotes
> "{exact user quote}" — u/{username}, r/{subreddit}, {score} upvotes
> "{exact user quote}" — @{username}, {likes} likes

### Actionable Insights
- {基于调研的具体行动建议}
```

## Key Principles

- **Reddit 优先**：无需 API key、信号质量高、讨论深度好
- **直接 curl 而非脚本**：CSP 环境下直接 API 调用比 Python 脚本更高效
- **搜索 → 聚焦 → 深挖**：先宽泛搜索找目标子版块，再在子版块内聚焦搜索
- **原话引用**：报告中引用真实用户原话，注明来源和投票数
- **时效性标注**：标注帖子/推文的时间，区分历史和最新反馈

## Anti-Patterns

| Anti-Pattern | 信号 | 正确做法 |
|-------------|------|---------|
| 只看首页热帖 | 遗漏新发布的长尾反馈 | 同时搜 hot + new，周期性检查 |
| 只看英文 | 遗漏非英语用户群 | 如产品有国际用户，搜当地语言的子版块 |
| 不加过滤的搜索 | 海量无关结果 | 用子版块限制 + 精确短语搜索 |
| 忽略投票/赞数 | 把 1 upvote 的帖子当主流意见 | 标注投票数，区分少数意见和主流意见 |
| 不验证来源 | 把推广内容当真反馈 | 检查账号历史，排除明显的营销号 |

## Related Skills

- [[csp-crosspost]] — 社交平台内容分发/发布（写操作）
- [[csp-deep-research]] — 多源深度调研，包含完整研究报告格式
- [[csp-micro-product-scout]] — 微型产品机会扫描，也用到社交平台数据
- [[csp-competitive-analysis]] — 竞品分析框架