---
name: csp-creator-orchestrator
description: >
  Use when starting a complete content creation project end-to-end — from strategy
  through production to publishing and复盘. This is the master orchestrator that routes
  to the right sub-skills in the right order. Use when the task spans multiple creator
  phases and needs coordinated execution. Triggers: 创作全流程, 端到端创作, content
  creation end-to-end, 内容项目, 完整创作. Keywords: 创作全流程, end-to-end, content
  project, 内容项目, orchestrator, 全链路创作, creative workflow.
version: "0.1.0"
layer: 2
category: workflow
type: workflow
phase: define
domain: patterns
role: specialist
scope: design
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch]
dependencies:
  skills:
    - csp-creator-vision
    - csp-creator-content-strategy
related_skills:
  - csp-creator-content-strategy
  - csp-creator-short-video
  - csp-creator-publish-pipeline
  - csp-creator-auto-publish
  - csp-creator-image-prompt
  - csp-creator-thumbnail
  - csp-creator-podcast
  - csp-creator-carousel
  - csp-beautiful-article
  - csp-content-engine
  - csp-poster
triggers:
  keywords: ["创作全流程", "端到端创作", "内容项目", "内容全链路", "end-to-end content",
             "完整创作流程", "creator workflow", "全链路创作"]
  intents:
    - "user wants to execute a complete content creation project"
    - "user asks for end-to-end content workflow"
    - "user references multiple creator stages in one request"
---

# Creator Orchestrator

End-to-end content creation project orchestrator — routes to the right skills at the right time.

## Purpose

When a content project spans multiple phases (strategy → production → publish → review), this orchestrator coordinates the flow, ensuring each phase completes with verification before moving to the next. It eliminates the "what skill do I use next?" confusion.

## When to Use

- ✅ "帮我做一个完整的AI工具推荐内容项目"
- ✅ "从选题到发布，帮我全流程做一期内容"
- ✅ Multi-phase content projects (strategy + production + publish)
- ✅ User doesn't know which creator skills to use in what order
- ❌ Single-phase task (just write an article → use `csp-article-writing`)
- ❌ Just need content strategy → use `csp-creator-content-strategy` directly

## When NOT to Use

Skip this orchestrator when:
- Only one phase is needed → go directly to the target skill
- User explicitly names a specific skill to use
- Task is purely one format (e.g., just a poster → `csp-poster`)

## Routing / Dispatch Logic

| Signal | Route to | Reason |
|--------|----------|--------|
| "先规划一下" / "做个选题" | ` [[csp-creator-content-strategy]] ` | Strategy phase |
| "做个视频" / "拍个短视频" | ` [[csp-creator-short-video]] ` | Production phase |
| "做个封面" / "封面图" | ` [[csp-creator-thumbnail]] ` | Asset phase |
| "配个图" / "生成图片" | ` [[csp-creator-image-prompt]] ` or ` [[csp-fal-ai-media]] ` | Asset phase |
| "做张海报" | ` [[csp-poster]] ` | Marketing asset |
| "写篇文章" / "写个推文" | ` [[csp-article-writing]] ` or ` [[csp-content-engine]] ` | Writing phase |
| "发布" / "上线" | ` [[csp-creator-publish-pipeline]] ` | Publish phase |
| "定时发布" / "排期" | ` [[csp-creator-auto-publish]] ` | Automated publish |
| "数据复盘" | ` [[csp-creator-auto-publish]] ` | Review phase |
| "怎么做播客" | ` [[csp-creator-podcast]] ` | Production phase |
| "做轮播图" / "信息图" | ` [[csp-creator-carousel]] ` | Production phase |

## Process

### Step 1: Project Intake & Phase Planning (2 min)

Assess the project scope and determine required phases:

```yaml
project_phases:
  define:     # Strategy, audience, topic selection
  plan:       # Script, storyboard, outline
  build:      # Production: shoot, write, record, design
  verify:     # Review, quality check, test
  ship:       # Publish, distribute, schedule
  review:     # Data collection,复盘, strategy iteration
```

**Checkpoint**: Phase plan confirmed with user before proceeding.

**红线**：
- Don't skip define phase for new projects — strategy matters
- Don't batch all phases into one step — verify between phases

### Step 2: Phase Execution (sequential, verify each)

Execute phases in order, verifying completion before moving on:

```
define → ✅ → plan → ✅ → build → ✅ → verify → ✅ → ship → ✅ → review
```

Each phase completion produces a marker so downstream skills can detect progress:

```yaml
# After strategy phase:
completion_signal:
  output: "content strategy + 30-day calendar"
  next_step: "plan phase: script/storyboard"
  status:
    phase: define
    ready_for: [plan]
```

### Step 3: Cross-Phase Handoff

When transitioning between phases, pass context explicitly:

```markdown
## Handoff: define → plan

**Carrying forward**:
- Content pillars: [Education 40%, Entertainment 30%, Inspiration 20%, Conversion 10%]
- Target platform: 抖音, B站
- This week's topics: ["3个免费AI工具", "AI翻车合集", "效率工具推荐"]
- Brand voice: sharp, practical, occasional humor

**Next**: Script and storyboard each topic for video production.
```

### Step 4: Project Close & Review

After ship phase, schedule review:

- [ ] 24h rapid review: first-impression metrics
- [ ] 7d full review: engagement depth, traffic sources, follower conversion
- [ ] Strategy update: feed findings back to `csp-creator-content-strategy`

## Key Principles

- **Phase-by-phase, not all-at-once** — Verify each phase; don't produce and publish in one go
- **Explicit handoffs** — Pass context between phases, don't assume downstream knows
- **Strategy anchors production** — Every piece of content has a strategic reason to exist
- **Review closes the loop** — Data feeds back to strategy for next cycle

## Anti-Patterns

| Anti-Pattern | Signal | Fix |
|-------------|--------|-----|
| Skipping strategy | Jumping straight to "make a video" | Backtrack: who is this for and why? |
| No verification between phases | Assets go to publish unchecked | Insert verification gate |
| Phases too large | "Do everything" in one step | Break into atomic phases |
| No review | Publishing without collecting data | Schedule 24h and 7d review |

## Completion Signal

```yaml
completion_signal:
  output: "Complete content project with all phases executed"
  next_step:
    recommended: "Schedule next content batch with [[csp-creator-auto-publish]]"
    alternatives:
      - "Start new project with [[csp-creator-content-strategy]]"
      - "Deep-dive single format with format-specific skill"
  status:
    phase: ship
    ready_for: [review]
```

## Examples

### Example: Full AI Tools Content Project

```
Input: "帮我做一个完整的AI工具推荐内容项目，覆盖抖音和B站"

Phase Flow:
  define → [[csp-creator-content-strategy]]
    Output: 4 pillars, 30-day calendar, audience defined

  plan → Scripting per topic
    Output: 5 video scripts with hooks, body, CTA

  build → [[csp-creator-short-video]]
    Output: 5 videos (9:16 for 抖音, 16:9 for B站)
    + [[csp-creator-thumbnail]] for custom covers
    + [[csp-creator-image-prompt]] for thumbnail art

  verify → Review each video
    Output: Quality-checked assets, subtitle verified

  ship → [[csp-creator-publish-pipeline]]
    Output: Multi-platform publish plan executed
    + [[csp-creator-auto-publish]] for batch scheduling

  review → Data collection (24h, 7d)
    Output: Performance report, strategy update
```

## Related Skills

- [[csp-creator-vision]] — Creator meta: goals, brand, audience definition
- [[csp-creator-content-strategy]] — Strategy and calendar planning
- [[csp-creator-short-video]] — Video production
- [[csp-creator-publish-pipeline]] — Publishing workflow
- [[csp-creator-auto-publish]] — Automated scheduling + review
- [[csp-simple-dev]] — Software development workflow (analogous orchestrator for code)
- [[csp-scope-guard]] — Scope management during projects