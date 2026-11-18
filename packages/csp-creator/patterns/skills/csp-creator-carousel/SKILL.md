---
name: csp-creator-carousel
description: >
  Use when creating visual storytelling content — Instagram/LinkedIn/小红书 carousels,
  infographics, multi-slide educational content, data storytelling, or swipeable
  content series. Covers narrative structure, visual hierarchy, slide-to-slide flow,
  and platform-specific optimization. Use when a single image isn't enough to tell
  the story. Keywords: 轮播图, carousel, 信息图, infographic, 图文, 多图, slide,
  小红书轮播, LinkedIn carousel, Instagram carousel, 数据可视化, visual storytelling,
  知识卡片.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: patterns
role: specialist
scope: implementation
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-creator-image-prompt
  - csp-creator-thumbnail
  - csp-frontend-slides
  - csp-chart
triggers:
  keywords: ["轮播图", "carousel", "信息图", "infographic", "知识卡片", "图文",
             "多图", "slide", "小红书轮播", "LinkedIn carousel", "Instagram carousel",
             "数据可视化", "visual storytelling", "滑动", "翻页"]
  intents:
    - "user wants to create a carousel post"
    - "user wants to visualize data or concepts in slides"
    - "user wants to create educational swipeable content"
---

# Carousel & Visual Storytelling

Turn ideas into swipeable visual narratives — carousels, infographics, knowledge cards.

## Purpose

Some ideas need more than one image. Carousels let you build a visual narrative across multiple slides — each one advancing the story, revealing the next insight, and keeping the audience swiping. This skill covers the full workflow: narrative structure, slide design, visual hierarchy, and platform optimization.

## When to Use

- ✅ Creating a 小红书/LinkedIn/Instagram carousel post
- ✅ Building educational "knowledge cards" (知识卡片)
- ✅ Designing an infographic that tells a story
- ✅ Data storytelling: visualizing numbers with narrative
- ✅ Step-by-step guides in visual format
- ❌ Single-image posts → use `csp-creator-thumbnail`
- ❌ Live presentation slides → use `csp-frontend-slides`

## Carousel Narrative Structures

Choose the structure that fits your content:

### Structure 1: Hook → Build → Reveal (Best: LinkedIn, 小红书)

```
Slide 1: HOOK — Provocative question, surprising stat, or bold claim
Slide 2: CONTEXT — Why this matters, the problem
Slide 3: INSIGHT 1 — First key point with visual
Slide 4: INSIGHT 2 — Second key point with visual
Slide 5: INSIGHT 3 — Third key point with visual
Slide 6: TAKEAWAY — Summary, what to do next
Slide 7: CTA + Brand — Follow for more, your logo/handle
```

### Structure 2: Problem → Solution → Proof (Best: Case studies, tutorials)

```
Slide 1: PROBLEM — Pain point the audience relates to
Slide 2: COMMON MISTAKE — What people usually do wrong
Slide 3: SOLUTION OVERVIEW — Your approach at a glance
Slide 4: STEP 1 — First action step with example
Slide 5: STEP 2 — Second action step with example
Slide 6: STEP 3 — Third action step with example
Slide 7: RESULT — Before/after or proof it works
Slide 8: RECAP + CTA — Summary checklist, follow for more
```

### Structure 3: List/Collection (Best: Recommendations, roundups)

```
Slide 1: TITLE — "5个免费的AI工具" (with number, creates curiosity)
Slides 2-6: ONE TOOL PER SLIDE — Name + screenshot + best use case
Slide 7: COMPARISON TABLE — All tools side by side at a glance
Slide 8: VERDICT — Which tool for which situation
```

### Structure 4: Data Story (Best: Reports, research findings)

```
Slide 1: HEADLINE STAT — The single most surprising number
Slide 2: WHY IT MATTERS — Context for the data
Slide 3: CHART 1 — First data visualization
Slide 4: CHART 2 — Second data visualization
Slide 5: INSIGHT — What the data means
Slide 6: PREDICTION/ACTION — Based on the data, here's what to do
```

## Slide Design Principles

### Visual Hierarchy Per Slide

```
┌─────────────────────────────┐
│  [Number/Icon]   (15% area) │  ← Anchor: slide number or category icon
│                             │
│  HEADLINE          (25%)    │  ← Big, bold, 1 line ideally
│                             │
│  ┌─────────────────────┐    │
│  │   VISUAL / CHART    │    │  ← Main visual: screenshot, chart,
│  │                     │    │    illustration, diagram
│  │   (45% of area)     │    │
│  └─────────────────────┘    │
│                             │
│  Supporting text (15%)      │  ← Optional: 1-2 lines max
│  →  swipe indicator         │  ← Small: "1/7" or arrow
└─────────────────────────────┘
```

### Color Consistency Across Slide Deck

Use a single color palette across ALL slides:

```yaml
carousel_palette:
  background: "#0F172A"      # Dark navy — every slide same bg
  headline: "#FFFFFF"        # White — consistent text color
  accent: "#38BDF8"          # Sky blue — highlights, numbers, icons
  secondary: "#94A3B8"       # Slate — supporting text
  chart_colors:              # If data visualization is included
    - "#38BDF8"              # Blue
    - "#A78BFA"              # Purple
    - "#FB923C"              # Orange
```

### Text Rules for Carousel Slides

| Element | Max Length | Font Size (1080px wide) | Weight |
|---------|-----------|------------------------|--------|
| Headline | 12 chars (CN) / 8 words (EN) | 64-80px | Bold/Black |
| Subtitle | 20 chars / 12 words | 36-48px | Regular/Medium |
| Body text | 30 chars / 20 words | 28-36px | Regular |
| Slide number | "01" format | 24px | Medium |
| Source/citation | 40 chars | 20px | Light |

**Iron Rule**: If text doesn't fit at these sizes, cut words — don't shrink the font.

## Platform-Specific Optimization

| Platform | Slide Count | Ratio | First Slide | File Format |
|----------|------------|-------|-------------|-------------|
| 小红书 | 1-10 slides | 3:4 (1080×1440) | 封面决定点击率 | JPG/PNG < 20MB |
| LinkedIn | 1-20 slides | 1:1 (1080×1080) | PDF or multi-image | PDF recommended |
| Instagram | 2-10 slides | 1:1 or 4:5 | First slide = hook | JPG/PNG |
| 公众号 | N/A (long image) | Variable | Top 1/3 visible in feed | JPG/PNG < 10MB |
| X/Twitter | 2-4 images | 16:9 or 1:1 | First image visible | JPG/PNG < 5MB |

## Creation Workflow

### Step 1: Outline (Paper First)

Before touching any design tool, outline every slide:

```
Slide 1: "你知道90%的人都在用错AI工具吗？" [Hook question]
Slide 2: "常见误区：把AI当成搜索引擎用" [Problem setup]
Slide 3: "正确的用法：把AI当成实习生" [Key insight]
Slide 4: "让AI先做80分，你再改到100分" [Actionable tip]
Slide 5: "一个真实案例：3小时工作→15分钟" [Social proof]
Slide 6: "记住这个公式：指令+上下文+格式=好结果" [Framework]
Slide 7: "收藏这张图，下次用AI前看一眼" [CTA + brand]
```

### Step 2: Design (AI-Assisted)

For each slide, generate with AI or use templates:

1. **AI Image Generation**: Use `csp-creator-image-prompt` per slide
2. **Template工具**: Canva, Figma, 稿定设计
3. **Consistency check**: All slides share background color, font, accent color

### Step 3: Export & Sequence Check

- [ ] All slides exported at correct resolution
- [ ] Named sequentially: `slide-01.png`, `slide-02.png`, ...
- [ ] Preview the swipe: does the narrative flow from 1→N?
- [ ] First slide works as standalone hook (it shows in feed)
- [ ] Last slide has CTA and brand/handle

### Step 4: Caption Writing

The caption complements the carousel, not duplicates it:

```
小红书 caption formula:
[Emoji hook] + [1-line tease of what's inside] + [encourage swipe] +
[value promise] + [hashtags]

Example:
"🤯 90%的人用AI的方式都错了
左滑看正确用法→
这6张图可能帮你每天节省2小时
#AI工具 #效率提升 #职场技能 #AI使用技巧"
```

## Key Principles

- **First slide is a billboard** — It must make people stop scrolling
- **One idea per slide** — Don't crowd; each slide advances one thought
- **Visual consistency is trust** — Same colors, fonts, spacing across all slides
- **Narrative arc matters** — Beginning → middle → end, not just a random collection
- **Caption complements, doesn't repeat** — Give people a reason to swipe, not just read

## Anti-Patterns

| Anti-Pattern | Signal | Fix |
|-------------|--------|-----|
| Text wall slides | More than 30 chars per slide | Cut to headlines, use visuals |
| No narrative arc | Slides could be in any order | Apply a structure from above |
| First slide is boring | Generic title, no hook | Lead with question/stat/emotion |
| Inconsistent design | Different fonts/colors per slide | Lock palette + font choices |
| Duplicate caption | Caption repeats slide content | Caption teases, slides deliver |

## Verification Checklist

- [ ] Narrative structure chosen (1 of 4 patterns)
- [ ] Every slide outlined before design starts
- [ ] Slide count within platform limits (小红书 ≤10, LinkedIn ≤20)
- [ ] Consistent color palette across all slides
- [ ] First slide has a scroll-stopping hook
- [ ] Text follows size rules (headline ≤12 CN chars, body ≤30)
- [ ] All slides exported at correct resolution
- [ ] Caption written (teases, doesn't duplicate)

## Examples

### Example: 小红书知识卡片系列

```
Input: "帮我做一个AI工具入门的7页知识卡片，发小红书"

Structure: Hook → Build → Reveal

Slide 1 (封面): "AI工具入门指南 🚀 从0到上手"
  Big title + gradient bg + "左滑查看→"

Slide 2: "为什么要学AI工具？"
  Bullet: 效率提升300% | 竞争力 | 未来必备

Slide 3: "3个必知概念"
  图标+文字: Prompt / Model / Token

Slide 4: "第一步：选对工具"
  表格: ChatGPT vs Claude vs 文心一言

Slide 5: "第二步：学会提问"
  Bad example vs Good example (对比色块)

Slide 6: "第三步：建立工作流"
  流程图: 需求→提示词→生成→修改→交付

Slide 7 (尾页): "收藏这张图，下次忘记时翻出来看"
  + 关注我，每周分享AI实用技巧
  + 你的logo/handle

Output: 7 slides, 3:4 ratio, consistent deep blue palette.
```

## Related Skills

- [[csp-creator-image-prompt]] — AI 生成每张幻灯片配图
- [[csp-creator-thumbnail]] — 第一张封面设计尤为重要
- [[csp-creator-publish-pipeline]] — 多平台发布
- [[csp-frontend-slides]] — 演示文稿（更适合演讲场景）
- [[csp-chart]] — 数据可视化图表生成
- [[csp-poster]] — 单张海报设计