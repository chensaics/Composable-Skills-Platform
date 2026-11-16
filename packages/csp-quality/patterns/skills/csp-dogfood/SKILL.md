---
name: csp-dogfood
description: >
  Use when doing exploratory testing, bug hunting, or dogfooding a web application.
  Systematically explores the app, finds bugs and UX issues, produces structured
  reports with step-by-step screenshots and repro steps. Asks user what to test
  and how deep to go, then independently explores.
  Keywords: dogfood, bug hunt, exploratory test, 找bug, QA, 狗粮测试, app testing.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: verify
domain: testing
role: specialist
scope: review
invocation: user
tools: [Read, Bash, WebFetch]
source: "Adapted from vercel-labs/agent-browser dogfood skill"
---

# csp-dogfood · 狗粮测试

Systematically explore a web app to find bugs and UX issues.

## Purpose

Not a test suite. Not a checklist. You USE the app like a real user would — explore every corner, click every button, try every flow. Find what breaks, what confuses, what's inconsistent. Produce a structured report the team can act on.

## Process

1. **Ask scope** — what to focus on? new feature? full app? specific flow?
2. **Explore systematically** — go through every page, interaction, and state
3. **Record evidence** — screenshot + step-by-step repro for every issue
4. **Rate severity** — blocker/critical/major/minor/cosmetic
5. **Structured report** — Findings table + Detail section with repro steps

## Explorers Mental Checklist

- [ ] Every button clickable (no dead buttons)
- [ ] Every form validates correctly
- [ ] Error states show useful messages (not raw errors)
- [ ] Empty states have guidance (not blank screens)
- [ ] Loading states exist (not frozen screens)
- [ ] Back button works everywhere
- [ ] Mobile/desktop both work
- [ ] Performance: anything feel slow?
- [ ] Inconsistencies: same action, different result?

## Output Format

```markdown
## Findings
| # | Severity | Page | Issue | Repro Steps |
|---|----------|------|-------|-------------|

## Detail
### Finding 1: {title}
[Screenshot]
Steps to reproduce:
1. Go to ...
2. Click ...
3. Observe: ...
Expected: ...
```