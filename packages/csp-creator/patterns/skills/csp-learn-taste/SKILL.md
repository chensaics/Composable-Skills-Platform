---
name: csp-learn-taste
description: >
  Use after a design review session to codify corrections into reusable rules.
  Turns design feedback ("don't use blue buttons", "cards need 12px radius") into
  DESIGN.md entries or project skills, with the WHY behind each rule so future
  sessions follow them without repeating the same corrections.
  Keywords: learn taste, 设计规则, design rules, codify, DESIGN.md, 审美规则.
version: "0.1.0"
layer: 4
category: runtime
type: technique
phase: verify
domain: patterns
role: specialist
scope: design
invocation: user
tools: [Read, Write, Edit]
source: "Adapted from emilkowalski/skill learn-taste"
---

# csp-learn-taste · 设计规则固化

Codify design corrections into reusable rules so you don't repeat the same feedback.

## Purpose

After every design review, capture what was corrected and WHY. Write it into DESIGN.md or a project skill. Next session, the agent reads it and follows it — no repeat corrections.

## When to Use

- ✅ After any design review where corrections were made
- ✅ "Remember I don't like X" — turns preference into rule
- ✅ Team design standards evolving
- ❌ One-off experimental decisions that shouldn't be rules

## Process

1. **Collect corrections** from the session: what was changed and why
2. **Write each as a rule** with rationale:
   ```
   ## Color palette
   - [ ] No blue buttons (reason: brand uses green. Corrected 2026-11-16)
   - [ ] Cards use 12px border-radius (reason: matches design system)
   ```
3. **Save to DESIGN.md** or project skill
4. **Reference in AGENTS.md**: `Read DESIGN.md before designing UI.`

## Rule Format

```markdown
## {Category}
- [ ] {Rule} (reason: {why}. Source: {session/date})
```

Rules are checkboxes — check them when followed during implementation.