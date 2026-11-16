---
name: csp-grilling
description: >
  Use when stress-testing a plan, design, or decision before implementation.
  Uses design-tree + frontier-based interviewing to map decisions and their
  dependencies, asking the whole frontier in each round until nothing is left
  unexamined. Inspired by mattpocock/skills grilling pattern.
  Keywords: grill, grilling, 盘问, 压力测试, design tree, 设计树, frontier, 决策审查.
version: "0.1.0"
layer: 1
category: meta
type: technique
phase: define
domain: architecture
role: specialist
scope: analysis
invocation: user
tools: [Read, Write, Edit, Glob, Grep]
related_skills:
  - csp-interview-me
  - csp-brainstorming
source: "Adapted from mattpocock/skills grilling pattern"
anti_rationalizations:
  "I already know what to build": "Knowing what ≠ having stress-tested every decision. Grilling finds the dependencies you didn't know were there."
  "Let me just ask one question at a time": "Frontier-based rounds are faster: ask every question whose prerequisites are settled. One-at-a-time wastes rounds on sequential dependencies."
---

# csp-grilling · 设计树盘问

Design-tree based relentless interviewing — map every decision as a node, find the frontier, ask it all at once.

## Purpose

Before implementing a plan or design, grill it until every decision is mapped and examined. This is NOT requirements gathering (use `csp-interview-me` for that). This is stress-testing an already-formed plan against edge cases, unspoken assumptions, and dependency gaps.

## When to Use

- ✅ User has a formed plan/design and wants to pressure-test it
- ✅ Before starting a large multi-session effort
- ✅ After brainstorming but before coding
- ❌ User has no plan yet → `csp-brainstorming`
- ❌ User has vague requirements → `csp-interview-me`
- ❌ Trivial changes with no design decisions

## When NOT to Use

- ❌ Single-file changes with no architectural impact
- ❌ User explicitly says "just do it, no questions"
- ❌ Already at >95% confidence on all decisions

## Process

### Step 1: Build the Design Tree（2 min）

Map the user's plan as a tree of decisions. Each decision is a node. A node's children are decisions that DEPEND on it being settled first.

```
Root: "Build user auth system"
├── Auth method? (Email/SSO/OAuth)
│   ├── [if OAuth] Which providers?
│   │   ├── Session storage?
│   │   └── Token refresh strategy?
│   └── [if Email] Password rules?
│       ├── MFA?
│       └── Account recovery flow?
├── User model changes?
│   └── Migration strategy?
└── Auth middleware placement?
```

**Rules**:
- A child decision cannot be asked until its parent is settled
- Decisions the user has ALREADY settled before the grilling session start as "confirmed" (green nodes)
- Unconfirmed decisions are the design tree to grill

### Step 2: Find the Frontier（1 min before each round）

The **frontier** = every unconfirmed node whose parent is confirmed.

```
Round 1 frontier: Auth method?, User model changes?, Auth middleware placement?
  → User answers Auth method = SSO

Round 2 frontier: Which providers?, Session storage?, (auth-method settled, unblocks children)
  → User picks Google + GitHub

Round 3 frontier: Token refresh strategy?, User model changes?, Auth middleware?
```

### Step 3: Ask the Frontier（per round）

Ask ALL frontier questions in one round. Format:

```
❓ **Q1 - Auth method**: Email/password (simpler, more control) or OAuth/SSO
   (lower friction, no password storage)?

➡️ OAuth — lower friction for B2B users.

---

❓ **Q2 - User model changes**: Will this require schema changes to the users table?

➡️ Yes — need to add `auth_provider` and `provider_id` columns.

---

❓ **Q3 - Auth middleware**: Where does the auth check sit in the request pipeline?

➡️ After rate-limiting, before route handlers.
```

**Rules**:
- Bundle ≤5 questions per round (more than 5 is overwhelming)
- Each question includes YOUR recommended answer
- Word it so "yes" accepts your recommendation
- Finding facts is YOUR job: dispatch sub-agent for codebase lookup, don't ask the user

### Step 4: Iterate Until Empty Frontier

Repeat steps 2-3 until the frontier is empty — every branch visited, nothing left silently assumed.

### Step 5: Produce the Decision Map

Output the completed decision tree as a record:

```markdown
## Decision Map — {topic}

### Confirmed Decisions
| # | Decision | Rationale | Dependents |
|---|---------|-----------|------------|
| D1 | OAuth for auth | Lower friction for B2B | D3, D4 |
| D2 | Add provider_id column | Required for OAuth mapping | — |
| D3 | JWT session storage | Stateless, works with OAuth | — |
| D4 | Refresh token rotation | Security best practice | — |

### Open Questions（if any）
- [ ] Multi-provider linking strategy (deferred to v2)
```

## Key Principles

- **Frontier-based, not sequential** — ask everything ready to be asked, don't waste rounds
- **Recommend, don't just question** — user reacts faster than generates
- **Facts are your job** — never ask "what does the codebase look like"
- **≤5 questions per round** — more is overwhelming
- **Empty frontier = done** — if nothing left to ask, the design is grilled

## Verification Checklist

- [ ] Design tree constructed with dependency edges
- [ ] Every frontier question has a recommended answer
- [ ] User confirmed each round before proceeding
- [ ] Frontier is empty (no unasked questions)
- [ ] Decision map written to record

## Related Skills

- [[csp-interview-me]] — For gathering initial requirements (before grilling)
- [[csp-brainstorming]] — For generating the plan (before grilling)
- [[csp-writing-plans]] — For implementing the grilled decisions