---
name: csp-deliberate
description: >
  Use when making consequential decisions — "帮我分析利弊", "两面论证",
  "先别下结论", steelman both sides. Structured deliberation in 2 turns:
  Turn 1 improves the question and asks the ONE most decision-critical question;
  Turn 2 makes the judgment. Not for factual Q&A, summaries, or urgent safety.
  Keywords: deliberate, steelman, 两面论证, 决策, 分析利弊, 钢人, decision review.
version: "0.1.0"
layer: 1
category: meta
type: technique
phase: define
domain: other
role: specialist
scope: analysis
invocation: user
tools: [Read, Glob, Grep]
source: "Adapted from flreey/myskills steelman-deliberation"
---

# csp-deliberate · 结构化决策

Two-turn structured deliberation for consequential decisions.

## Purpose

Structure judgment when the decision matters — not for factual Q&A, summaries, or urgent safety response. The protocol runs in two turns, never merged.

## When to Use

- ✅ "帮我分析利弊", "两面论证", "先别下结论"
- ✅ Major product/architecture/career/business decisions
- ❌ Factual Q&A, summaries, urgent safety response
- ❌ Trivial choices with no real trade-off

## Turn 1 — Deliberate, Ask, Stop

Five sections in order:

**1. 真正要解决的问题** — Restate the decision in its strongest form. Separate proposed solution from underlying outcome, constraints, stakes.

**2. 支持方的最强论证** — Present the strongest charitable case FOR the idea. Don't weaken it.

**3. 反对方的最强论证** — Present the strongest charitable case AGAINST at same rigor. Don't manufacture symmetry if evidence is lopsided.

**4. 真正的分歧与关键变量** — Rank variables by `decision sensitivity × uncertainty × answerability`. Lead with the ones most capable of reversing the judgment.

**5. 唯一问题** — Ask exactly ONE question about the highest-ranked unresolved variable. It must distinguish between competing conclusions. This sentence IS the end of the response. No verdict, no recommendation, no explanation after it.

## Turn 2 — Judge and Act

After user answers, give the best available judgment. Not a restart — incorporate the answer directly.

## Red Lines

- NEVER merge two turns into one
- NEVER give verdict in Turn 1
- NEVER ask more than one question at the end of Turn 1
- The question distinguishes between conclusions, doesn't just request more background