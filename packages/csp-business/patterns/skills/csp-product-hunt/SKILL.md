---
name: csp-product-hunt
description: >
  Product Hunt data access via GraphQL API — discover trending products,
  search posts by topic, track competitor launches, find makers, and monitor
  collections. Use for product discovery, competitive intelligence, market
  validation, and trend spotting. Complements csp-micro-product-scout (find
  opportunities) and csp-competitive-analysis (track competitors).
  Keywords: Product Hunt, PH, product launch, 产品发布, trending, discovery,
  competitive intel, maker, indie, 趋势发现, market validation.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: define
domain: patterns
role: specialist
scope: analysis
invocation: user
tools: [Read, Bash, WebFetch]
related_skills:
  - csp-micro-product-scout
  - csp-competitive-analysis
  - csp-deep-research
  - csp-social-intel
triggers:
  keywords: ["Product Hunt", "PH", "product launch", "产品发布",
    "trending products", "trending", "maker", "indie hacker",
    "product discovery", "producthunt"]
  intents:
    - "user wants to discover trending products on Product Hunt"
    - "user wants to research product launches in a specific category"
    - "user wants to track competitor product launches"
    - "user wants to validate market interest in a product category"
---

# Product Hunt Intel

Product Hunt 产品情报——发现趋势产品、追踪竞品发布、验证市场需求。

## Purpose

通过 Product Hunt GraphQL API 获取产品发布数据，为 CSP 的三大场景提供数据支持：
- **产品发现**：什么品类在起来？什么产品在获得 traction？
- **竞品情报**：竞品什么时候发布的？获得多少投票？用户评论说什么？
- **市场验证**：目标品类有多少产品在发布？用户反响如何？

## When to Use

- ✅ 发现特定品类的趋势产品（按 topic 过滤）
- ✅ 追踪竞品在 PH 上的发布和表现
- ✅ 研究某个 maker/团队的发布历史
- ✅ 验证产品品类的市场热度（发布频率、投票量）
- ✅ 收集用户对同类产品的评论反馈
- ✅ 寻找产品灵感和功能参考
- ❌ 中国市场的产品发现（PH 主要是海外用户）
- ❌ 深度竞品分析（仅投票数不够，需结合 csp-competitive-analysis）

## Prerequisites

**必需**：设置 `PRODUCTHUNT_ACCESS_TOKEN` 环境变量。

从 https://www.producthunt.com/v2/oauth/applications 获取 Developer Token。

```bash
export PRODUCTHUNT_ACCESS_TOKEN="your_developer_token"

# 快速验证
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ posts(first:3) { edges { node { name tagline votesCount } } } }"}'
```

**API 规格**：
- Endpoint: `https://api.producthunt.com/v2/api/graphql`
- 类型: GraphQL (POST)
- Rate Limit: 6250 complexity points / 15 min
- 文档: https://api.producthunt.com/v2/docs

## Process

### Step 1: 明确查询意图（1 min）

选择查询模式：

| 意图 | 查询对象 | 典型问题 |
|------|---------|---------|
| 趋势发现 | Posts（按 topic/featured/日期） | "AI 领域这周最火的 10 个产品是什么？" |
| 竞品追踪 | Posts（特定 maker/关键词搜索）+ Comments | "某竞品发布时获得多少 votes？用户说什么？" |
| 品类研究 | Topics → Posts | "developer-tools 品类有多少产品？热度如何？" |
| Maker 调研 | User → submittedPosts | "这个 maker 之前做过哪些产品？" |
| 集合挖掘 | Collections | "有哪些 AI 工具的精选集合？" |

### Step 2: 执行查询（2 min）

**A. 搜索趋势产品**

```bash
# 今日精选
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ posts(first:20, featured:true) { edges { node { id name tagline votesCount commentsCount url website topics(first:3) { edges { node { name } } } } } } }"}'
```

```bash
# 按品类搜索
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ posts(first:15, topic:\"developer-tools\") { edges { node { id name tagline votesCount commentsCount url website createdAt } } } }"}'
```

```bash
# 按日期范围搜索
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ posts(first:10, postedAfter:\"2026-10-01T00:00:00Z\") { edges { node { id name tagline votesCount url } } } }"}'
```

**B. 获取产品详情与评论**

```bash
# 按 slug 获取
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ post(slug:\"chatgpt\") { id name tagline description votesCount commentsCount url website makers { name username } topics(first:5) { edges { node { name slug } } } comments(first:10) { edges { node { body votesCount user { name username } } } } } }"}'
```

**C. 搜索品类/主题**

```bash
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ topics(query:\"AI\", first:15) { edges { node { id name slug description postsCount followersCount } } } }"}'
```

**D. Maker/用户调研**

```bash
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ user(username:\"rrhoover\") { id name username headline isMaker submittedPosts(first:10) { edges { node { id name tagline votesCount url } } } } }"}'
```

**E. 精选集合**

```bash
curl -s -X POST https://api.producthunt.com/v2/api/graphql \
  -H "Authorization: Bearer $PRODUCTHUNT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ collections(first:10, featured:true, order:FOLLOWERS_COUNT) { edges { node { id name tagline url followersCount posts(first:5) { edges { node { name tagline votesCount } } } } } } }"}'
```

### Step 3: 解读信号（3 min）

PH 数据的解读框架：

| 指标 | 信号含义 | 阈值参考 |
|------|---------|---------|
| **votesCount** | 产品吸引力/市场热度 | 500+ = 不错的发布, 1000+ = 热门, 2000+ = 爆款 |
| **commentsCount** | 用户参与度/争议度 | 投票:评论 = 10:1 正常, 5:1 以下表示争议或深度讨论 |
| **featured** | 编辑认可度 | Featured 产品获得更多曝光 |
| **topics** | 产品定位/赛道 | 品类越细分，竞争越少 |
| **makers 发布历史** | 创业者经验/成功率 | 连续 maker 的后续产品通常质量更高 |

### Step 4: 输出分析（2 min）

根据不同意图输出不同格式：

**趋势发现报告**：
```markdown
## {品类} PH 趋势速览 | {日期}

### Top 5 本周热门
| Rank | 产品 | Tagline | Votes | 亮点 |
|------|------|---------|-------|------|
| 1 | ... | ... | ... | ... |

### 趋势信号
- 新兴方向：{从产品 tagline 和 topic 中发现的模式}
- 功能热点：{多个产品共有的功能特征}
- Maker 动向：{值得关注的 maker/团队}
```

**竞品情报报告**：
```markdown
## {竞品名} PH 发布分析

- 发布时间：{date}
- 投票数：{votes}（处于 {percentile} 分位）
- 评论情感：正面/负面/功能请求 比例
- 话题标签：{topics}
- 竞品 maker 的其他产品：{list}
```

## Key Principles

- **投票数是相对信号，不是绝对验证**：1000 votes 不保证商业成功，但 10 votes 确实说明没 traction
- **PH 用户群体偏早期 adopters**：不代表主流市场，但对开发者工具、SaaS、AI 产品有较强参考性
- **评论比投票更有价值**：阅读真实用户评论，特别是"wish it had X"、"vs Y" 类评论
- **Maker 追踪是隐形资产**：追踪优质 maker 的后续发布，比泛泛搜索更高效
- **与 CSP skills 联动**：PH 数据 + csp-social-intel（Reddit 验证）+ csp-micro-product-scout（机会评分）

## Anti-Patterns

| Anti-Pattern | 信号 | 正确做法 |
|-------------|------|---------|
| 只看 votes 不看评论 | 忽略用户真实反馈 | 评论中的痛点才是机会 |
| 把 PH 热度当市场规模 | "500 votes = 大市场" | PH 是早期 adopter 样本，需用其他数据源交叉验证 |
| 只搜 featured | 遗漏早期/小众产品 | 同时搜索非 featured、按 topic 深入 |
| 忽略品类语境 | 把不同品类的 votes 绝对比较 | 开发者工具 300 votes > 消费品 800 votes |

## CSP 场景联动

| CSP 场景 | PH 数据用法 |
|----------|-----------|
| **csp-micro-product-scout** | PH 上的新品发布 = 需求验证信号；评论中的"wish it had" = 机会 |
| **csp-competitive-analysis** | 竞品 PH 发布历史、投票趋势、用户评论情感 |
| **csp-deep-research** | PH 品类数据作为市场调研的一个维度的数据源 |
| **csp-social-intel** | PH 发现的 maker → 在 Reddit/Twitter 追踪其用户讨论 |
| **csp-business-seo** | PH 上高票产品 = 内容营销素材（"Top X tools" 类文章） |

## Verification Checklist

- [ ] `PRODUCTHUNT_ACCESS_TOKEN` 已设置且有效
- [ ] 查询意图明确（趋势/竞品/品类/maker）
- [ ] 结果含 votes + comments 两个维度
- [ ] 对高票产品阅读了至少 3 条评论
- [ ] 关键结论附带了 PH 原始数据支持

## Examples

### Example 1: 发现 AI 开发工具趋势

```
输入: "看看 AI 开发工具最近有什么新产品"
处理:
  1. 搜索 posts(topic:"developer-tools", postedAfter:"2026-10-01")
  2. 交叉过滤 topic 含 "AI"/"Artificial Intelligence" 的产品
  3. 分析 tagline 中的共同模式
  4. 对 Top 5 产品阅读评论
输出: 趋势报告 — "AI 开发工具领域 3 个新方向：1) AI-powered code review...
        2) prompt management platforms... 3) AI agent testing frameworks..."
```

### Example 2: 竞品 PH 发布回溯

```
输入: "分析一下 CompetitorX 在 PH 的发布情况"
处理:
  1. 搜索 posts → 找到 slug
  2. 获取 post 详情 + comments
  3. 获取 maker 的其他 submittedPosts
  4. 按时间线整理
输出: 竞品报告 — 发布时间、投票趋势、评论关键反馈、maker 产品矩阵
```

## Related Skills

- [[csp-micro-product-scout]] — 发现微产品机会（PH 数据作为验证信号之一）
- [[csp-competitive-analysis]] — 系统化竞品分析（PH 发布数据作为一个分析维度）
- [[csp-deep-research]] — 多源深度调研（PH 作为数据源之一）
- [[csp-social-intel]] — Reddit/Twitter 数据采集（交叉验证 PH 信号）
- [[csp-business-seo]] — SEO/GEO 优化（PH 趋势产品可用于内容选题）