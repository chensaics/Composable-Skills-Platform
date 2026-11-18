---
name: csp-creator-content-strategy
description: >
  Use when building a content strategy, editorial calendar, topic library,
  or content pillar framework. Covers audience analysis, competitor content
  audit, topic clustering, format mix planning, and posting cadence design.
  Use BEFORE content production to avoid random posting. Keywords: 内容策略,
  content strategy, 选题库, editorial calendar, 内容日历, topic cluster, 内容规划,
  发稿计划, 内容矩阵.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: define
domain: patterns
role: specialist
scope: design
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch]
related_skills:
  - csp-creator-short-video
  - csp-creator-publish-pipeline
  - csp-content-engine
triggers:
  keywords: ["内容策略", "选题库", "内容日历", "content strategy", "editorial calendar",
             "发稿计划", "内容矩阵", "content pillar", "话题聚类", "topic cluster"]
  intents:
    - "user wants to plan a content strategy"
    - "user needs a posting schedule"
    - "user wants to build a topic library"
---

# Content Strategy & Editorial Calendar

Systematic content strategy — from audience definition to publishable calendar.

## Purpose

Stop guessing what to post. Build a data-informed content strategy with target audiences, content pillars, topic clusters, format mix, and posting cadence — so every piece of content serves a strategic goal, not just fills a calendar slot.

## When to Use

- ✅ Starting a new creator account / brand channel
- ✅ Content feels random — need a strategy refresh
- ✅ Need a 30/60/90-day editorial calendar
- ✅ Want to build a reusable topic library
- ❌ One-off single post (use `content-engine`)
- ❌ Already have a working strategy that just needs execution

## Process

### Step 1: Audience & Competitive Audit (5 min)

1. **Define target audience**: demographics, pain points, content consumption habits
2. **Competitor content audit**: scan 3-5 competitor accounts, extract:
   - Top performing content patterns
   - Content gaps they're not covering
   - Format/tonal patterns

**Output**: Audience persona card + competitive gap map

### Step 2: Content Pillars Design (3 min)

Define 3-5 content pillars — thematic buckets all content falls into:

| Pillar Type | Example | Ratio |
|------------|---------|-------|
| Education | How-to, tutorials, tips | 40% |
| Entertainment | Behind-scenes, humor, trends | 30% |
| Inspiration | Case studies, transformations | 20% |
| Conversion | Product demo, testimonials | 10% |

**Rule**: Each pillar must answer "What does my audience get from this?"

### Step 3: Topic Clustering (3 min)

Per pillar, generate 10-20 topics using keyword research:

```
For each pillar:
  - Brainstorm seed keywords × 5
  - Expand via related searches
  - Cluster into content series (3-5 topics per series)
  - Assign format fit: short video / long article / carousel / thread
```

### Step 4: Format Mix & Cadence

Design posting rhythm per platform:

| Platform | Frequency | Best Formats | Best Times |
|----------|-----------|-------------|------------|
| 抖音/TikTok | 1-2/day | Short video, trending audio | 7-9am, 7-9pm |
| 小红书 | 1/day | Carousel + caption | 12-2pm, 8-10pm |
| B站 | 2-3/week | Long-form, tutorial | 12-2pm, 6-8pm |
| YouTube | 1-2/week | Long-form, series | 12-4pm |
| 公众号 | 2-3/week | Long article | 8-10am |
| X/Twitter | 3-5/day | Thread, hot take | varies |

### Step 5: Calendar Generation

Output a 30-day content calendar as Markdown table:

```markdown
| Date | Platform | Pillar | Topic | Format | Status |
|------|----------|--------|-------|--------|--------|
| Mon 1 | 抖音 | Education | AI tool tutorial | Short video | 📝 |
| Mon 1 | 小红书 | Inspiration | Before/after case | Carousel | 📝 |
```

## Key Principles

- **Strategy before production** — Don't post just to post; every piece has a job
- **Cluster > scatter** — Content series (3-5 related pieces) outperform isolated posts
- **Repurpose, don't recreate** — One research → multiple formats across platforms
- **Audit before planning** — Know what competitors are doing and what gaps exist

## Anti-Patterns

| Anti-Pattern | Signal | Fix |
|-------------|--------|-----|
| Random posting | No pillar structure | Return to Step 2 |
| All education, no personality | Zero entertainment/inspiration | Add 30% personality content |
| Copying competitor exactly | Same topics, same format | Find their gap and fill it |
| Over-planning, no production | 90-day calendar, zero posts | Ship the first week, iterate |

## Verification Checklist

- [ ] 3-5 content pillars defined with ratio allocation
- [ ] 10+ topics per pillar in topic library
- [ ] 30-day calendar populated (at minimum first 7 days detailed)
- [ ] Format mix balanced across platforms
- [ ] Competitive audit completed with gap analysis
- [ ] Audience persona card written

## Examples

### Example: New AI Tools Creator Account

```
Input: "我想做一个分享AI工具的抖音号，帮我规划内容策略"

Output:
  Pillars:
    1. Education (40%): 每周推荐2-3个AI工具 + 使用教程
    2. Entertainment (30%): AI翻车现场、搞笑AI生成内容
    3. Inspiration (20%): 用AI工具做成的作品展示
    4. Conversion (10%): 付费工具深度评测

  First Week Calendar:
    Mon: "3个免费AI工具，效率提升10倍" (Education, 短视频)
    Tue: "我用AI做了一首歌，结果..." (Entertainment, 短视频)
    Wed: "打工人必装的AI浏览器插件" (Education, 图文)
    Thu: "AI生成的奇葩图片合集" (Entertainment, 短视频)
    Fri: "用AI做PPT，同事以为我加班了" (Education, 短视频)
    Sat: "一个业余画手用AI后的作品对比" (Inspiration, 图文)
```

## Related Skills

- [[csp-creator-short-video]] — 短视频创作全流程
- [[csp-creator-publish-pipeline]] — 多平台发布流水线
- [[csp-content-engine]] — 内容生产引擎（单条内容撰写）
- [[csp-business-seo]] — SEO and keyword research
- [[csp-market-research]] — 市场调研与竞品分析