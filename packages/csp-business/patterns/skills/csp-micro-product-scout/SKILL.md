---
name: csp-micro-product-scout
description: >
  Use when discovering small overseas product opportunities for a solo indie
  developer — tools, browser extensions, platform plugins, converters, micro-SaaS.
  Hard filter: overseas users, real-case-accessible, competitor-adjacent (not clone),
  7-10 day MVP. Core principle: competitors validate demand, the opportunity is the
  small neglected action beside them. Now includes platform-based user demand
  research methodology (Reddit, GitHub, YouTube, Amazon, LinkedIn, X).
  Keywords: micro product, indie, 小产品, overseas, scout, opportunity, 机会扫描,
  user demand, 用户需求, product research.
version: "0.2.0"
layer: 3
category: patterns
type: technique
phase: define
domain: patterns
role: specialist
scope: analysis
invocation: user
tools: [Read, WebFetch, WebSearch]
related_skills:
  - csp-social-intel
  - csp-deep-research
  - csp-competitive-analysis
triggers:
  keywords: ["micro product", "indie", "小产品", "overseas", "scout",
    "opportunity", "机会扫描", "product idea", "find product"]
  intents:
    - "user wants to discover small product opportunities"
    - "user wants to validate if a product idea has demand"
---

# csp-micro-product-scout · 微型产品机会扫描

Discover small overseas product opportunities a solo developer can build and sell.

## Purpose

Core principle: **Competitors validate demand. The opportunity is the small neglected action beside them.**

This is NOT broad startup idea research, NOT "free clone of paid tool", NOT local-regulatory domains. It finds gaps beside existing products — the small ignored use case, the export button, the plugin that 100 people on Reddit keep asking for.

## Hard Filters

- Overseas users (non-China market)
- Real-case-accessible input data (you can inspect it)
- Competitor-adjacent wedge (not a free clone)
- 7-10 day MVP for solo dev
- No local-regulatory domains (tax, legal, medical certification)

## Process

### Step 1: 竞品生态扫描（5 min）

围绕目标领域，用 WebSearch 找到 5-10 个已有付费用户的竞品。

```bash
# 搜索已有产品
WebSearch: "best {category} tools 2026"
WebSearch: "{category} software alternatives"
WebSearch: "site:producthunt.com {category}"
```

**检查点**：列出竞品名、付费用户量（估算）、核心功能矩阵

### Step 2: 用户需求挖掘——按品类选平台（10 min）

不同品类用户反馈聚集在不同平台。按品类选择 2-3 个最优平台：

| 品类 | 首选平台 | 次选平台 | 信号类型 |
|------|---------|---------|---------|
| 开发者工具 | Reddit, GitHub Issues | X | Bug 报告、功能请求 |
| AI/SaaS 产品 | Reddit | LinkedIn, X | 用户抱怨、功能对比 |
| 消费电子产品 | Amazon 评论 | YouTube, Reddit | 产品评价、痛点 |
| 内容创作工具 | Reddit | YouTube 评论 | 工作流需求 |
| B2B/企业工具 | LinkedIn | X | 行业讨论 |
| 教育/学习 | YouTube 评论 | Reddit | 教程中的缺陷吐槽 |
| 设计/创意 | Reddit | YouTube | 工具链需求 |
| 电商/实体 | Amazon 评论 | Reddit | 评价中的 Wish List |

**需求挖掘策略**：

**Reddit**（详见 [[csp-social-intel]]）：
```
# 痛点搜索
"hate {product}" OR "frustrated with {product}"
"{product} alternative" OR "{product} replacement"
"wish {product} could" OR "{product} should have"
"any tool that {use case}" OR "looking for {use case}"
```

**GitHub Issues**：
```
WebSearch: "site:github.com/{repo}/issues feature request"
WebSearch: "site:github.com/{repo}/issues {pain_point}"
```

**Amazon Reviews**（仅消费电子/实体产品）：
```
WebSearch: "site:amazon.com {product} review"
# 重点读 3 星和 4 星评论（含建设性批评）
# 提取 "I wish it had..." / "If only it could..." 句式
```

**YouTube 评论**：
```
WebSearch: "{product} review" site:youtube.com
# 评论中的常见模式：
# - "Does it support X?"
# - "Compared to {alternative}, this lacks Y"
# - "The only thing missing is Z"
```

### Step 3: 需求量化评分（3 min）

对找到的需求信号打分：

| 评分维度 | 评分标准 | 权重 |
|---------|---------|------|
| 信号数量 | <5=1分, 5-15=2分, >15=3分 | 30% |
| 信号强度 | Comment=1, Post=2, Top Post=3, Multiple subreddits=4 | 25% |
| 竞品忽略度 | 竞品已做=1, 竞品不做=2, 竞品做但差=3 | 25% |
| 单人可实现 | 大工程=1, 中=2, 7天内=3 | 20% |

### Step 4: 排名与推荐

按 `(信号数量 × 信号强度 × 竞品忽略度) / 实现难度` 排序。

输出格式：
```
## {领域} 微型产品机会

| Rank | 机会 | 需求信号 | 竞品 | 实现难度 | 得分 |
|------|------|---------|------|---------|------|
| 1 | {简短描述} | {来源+数量} | {竞品为何忽略} | {预估天数} | {得分} |
```

## Key Principles

- **竞品验证需求**：有竞品意味着需求存在，机会在竞品忽略的缝隙
- **信号优先于直觉**：Reddit 上 100 个人在问的功能 > 你觉得好的功能
- **最小可行判断**：7-10 天能验证的需求才值得做
- **不造轮子重构版**：不做"更好的 Notion"，做"Notion 用户都想要的导出插件"
- **平台匹配品类**：不同品类有不同信息源，开发者工具看 GitHub，消费品看 Amazon

## Anti-Patterns

| Anti-Pattern | 信号 | 正确做法 |
|-------------|------|---------|
| 做免费的竞品 | "XXX but free" | 用户在竞品付费说明需求存在，做差异化而非免费克隆 |
| 只看一个平台 | 只在 Reddit 搜 | 按品类匹配 2-3 个平台交叉验证 |
| 忽略信号强度 | 把 1 upvote 的帖子当需求 | 标注投票数/评论数/出现频率 |
| 主观臆断 | "我觉得用户需要这个" | 每个机会必须附至少一个真实用户原话链接 |

## Examples

### Example 1: 日历工具需求扫描

```
输入: "帮我看看日历/日程管理领域有什么微产品机会"
处理:
  1. 竞品扫描 → Notion Calendar, Cron, Fantastical, Vimcal
  2. 平台选择 → 开发者工具 → Reddit + GitHub Issues 首选
  3. Reddit 搜索 → "Notion Calendar alternative" → 发现 r/Notion 热议
  4. 需求信号提取:
     - "wish Notion Calendar could sync with Google Tasks" (47 upvotes, r/Notion)
     - "any tool that converts meeting notes to calendar blocks?" (156 upvotes, r/productivity)
     - "fantastical is great but expensive, $57/yr is steep"  (多次出现)
  5. 评分 → "Meeting Notes → Calendar Blocks" 得分最高
输出: Top 3 机会 + 每个机会的 3 条用户原话验证
```

### Example 2: 浏览器扩展机会

```
输入: "Chrome 扩展有什么值得做的"
处理:
  1. WebSearch → "most popular chrome extensions" → 列出前 20
  2. 对每个热门扩展搜索 "{extension} alternative" → 找用户抱怨
  3. 发现 "OneTab alternative that syncs across devices" (多次出现)
  4. GitHub Issues → 相关开源扩展的 feature request
输出: 需求信号充足的机会列表
```

## Related Skills

- [[csp-social-intel]] — Reddit/Twitter 数据采集（需求挖掘第一步）
- [[csp-deep-research]] — 深度多源调研
- [[csp-competitive-analysis]] — 竞品分析框架