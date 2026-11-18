---
name: csp-creator-vision
description: >
  Use when defining or refining the creator's brand identity, mission, target
  audience, and content philosophy. This is the "why" behind all content — the
  meta-level foundation that all other creator skills reference. Use BEFORE any
  content production to establish clear creative direction. Use when the creator
  asks "who am I as a creator?" or "what should my brand be?" Keywords: 创作者定位,
  brand identity, creator vision, 创作理念, 品牌定位, content philosophy, 受众定位,
  creator mission, 人设.
version: "0.1.0"
layer: 1
category: meta
type: reference
phase: define
domain: patterns
role: specialist
scope: design
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-creator-content-strategy
  - csp-creator-orchestrator
  - csp-brand-voice
triggers:
  keywords: ["创作者定位", "品牌定位", "创作理念", "content philosophy", "creator vision",
             "brand identity", "受众定位", "人设", "内容方向", "我是谁", "定位"]
  intents:
    - "user wants to define their creator identity"
    - "user asks 'what should my brand be?'"
    - "user wants to refine their content direction"
---

# Creator Vision & Identity

Define the creator's core identity — the "why" that anchors all content decisions.

## Purpose

Before any content exists, define who you are as a creator. Your identity determines what you make, how you make it, and who cares. This skill produces a Creator Identity Card that all downstream skills reference — so content strategy, production, and publishing stay aligned.

## When to Use

- ✅ Starting a new creator account/channel
- ✅ Refining or pivoting existing creator brand
- ✅ Content feels unfocused, need clarity on "who am I?"
- ✅ Building a team — need a shared creative brief
- ❌ Content strategy already clear and producing well
- ❌ Just need a one-off post (use strategy directly)

## Process

### Step 1: Core Identity Discovery (5 min)

Answer these foundational questions:

```markdown
## Creator Identity Card

### 1. WHO are you?
- **Creator Archetype**: [Educator / Entertainer / Storyteller / Analyst / Curator / Maker]
- **Your Unfair Advantage**: What do you know/do better than 90% of people?
- **Your Voice**: [professional / casual / humorous / sharp / warm / authoritative]

### 2. WHAT do you make?
- **Content Genre**: [Tech tutorials / Lifestyle vlogs / Product reviews / Opinion essays / ...]
- **Primary Format**: [Short video / Long article / Podcast / Carousel / Live stream]
- **Value Proposition**: "I help [audience] achieve [outcome] through [method]"

### 3. WHO is it for?
- **Primary Audience**: [demographics + psychographics + pain points]
- **What they want**: [information / entertainment / inspiration / tools / community]
- **Why they'd follow YOU specifically**: [your unique angle or personality]

### 4. WHY do you do it?
- **Mission**: One sentence. What change do you want to create?
- **Content Philosophy**: 3 principles that guide every content decision
```

### Step 2: Competitive Positioning (3 min)

Map yourself against the competitive landscape:

```
Positioning Matrix:

     Formal ────────────────── Casual
       │                          │
Expert │  Your Space?             │  Personality-driven
       │                          │  experts
       │                          │
  ─────┼──────────────────────────┼──────
       │                          │
  News │  News aggregators        │  Entertainment
       │                          │  creators
       │                          │
     Formal ────────────────── Casual
```

Identify your unique position: What combination of traits does NO ONE else occupy?

### Step 3: Content Philosophy

Write 3-5 principles that every piece of content must follow:

```markdown
## Content Philosophy

1. **Show, don't just tell** — Every claim backed by demo/screenshot/result
2. **Respect the audience's time** — If a 3-min video can be 1 min, make it 1 min
3. **One piece, one insight** — Each content piece delivers exactly one actionable takeaway
4. **Personality over polish** — Authentic rough edges > sterile perfection
5. **No hype, just help** — Never oversell; let results speak
```

### Step 4: Output — Creator Identity Card

Produce a shareable identity card:

```markdown
---
creator_id: "tech-ai-educator"
name: "[Creator Name]"
archetype: Educator × Maker
advantage: "10 years in AI/ML engineering + teaching experience"
voice: "Sharp, practical, occasional deadpan humor"
audience: "Chinese tech professionals (25-35) wanting to leverage AI tools"
mission: "Make AI tools accessible and immediately useful for everyday work"
philosophy:
  - Show real workflows, not demoware
  - Every tutorial ends with something the viewer can do today
  - Tools over theory; practice over papers
positioning: "The engineer who actually builds things with AI, not just talks about it"
---
```

**Checkpoint**: User signs off on identity card before production begins.

## Key Principles

- **Identity anchors content** — Every content decision traces back to the identity card
- **Narrow beats broad** — A sharp identity for 10K people > a vague identity for 1M
- **Authenticity is strategy** — Don't invent a persona; amplify your real strengths
- **Write it down** — An undocumented identity drifts; a card keeps you honest

## Anti-Patterns

| Anti-Pattern | Signal | Fix |
|-------------|--------|-----|
| "For everyone" | No target audience defined | Narrow to one persona |
| Copying a big creator | Identity sounds like a clone | Find your unique angle |
| Mission too vague | "Make the world better" | Specific: who, what, how |
| No philosophy | Content feels random | Write 3 principles |

## Completion Signal

```yaml
completion_signal:
  output: "Creator Identity Card (markdown, shareable)"
  next_step:
    recommended: "Feed into [[csp-creator-content-strategy]] for calendar planning"
    alternatives:
      - "Use [[csp-brand-voice]] to define writing voice in detail"
      - "Go to [[csp-creator-orchestrator]] for full project execution"
  status:
    phase: define
    ready_for: [plan]
```

## Examples

### Example: AI Tool Reviewer

```
Input: "我想做一个AI工具评测的号，帮我定位一下"

Output — Identity Card:
  archetype: Analyst × Educator
  advantage: "试用了200+ AI工具，知道什么好用什么不行"
  voice: "直接、实用、偶尔毒舌"
  audience: "不想被AI割韭菜的普通职场人"
  mission: "帮普通人分辨真正有用的AI工具，少交智商税"
  philosophy:
    1. 每个工具必须亲手用满一周才出评测
    2. 好的说好，差的说差，不收钱说假话
    3. 工具评测必须有实际工作流场景，不是参数堆砌
  positioning: "全网最real的AI工具评测，不恰烂饭"
```

## Related Skills

- [[csp-creator-content-strategy]] — 基于定位的内容策略和日历
- [[csp-brand-voice]] — 品牌语调的细化定义
- [[csp-creator-orchestrator]] — 端到端创作编排
- [[csp-agentic-identity-trust]] — Agent 身份与信任体系