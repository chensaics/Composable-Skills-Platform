---
name: csp-constraints
description: >
  Use when setting up a project's machine-checkable quality bar (CONSTRAINTS.md),
  when an agent keeps silencing checks or skipping tests to get to green, when
  coverage/performance/security numbers get argued about per-PR, or when starting
  autonomous loops without a written bar. Produces a CONSTRAINTS.md with Floor,
  Enforced, and Measured tiers, plus installs the tools each dimension needs.
  Keywords: constraints, CONSTRAINTS.md, quality bar, 质量门, ratchet, 约束, standards.
version: "0.1.0"
layer: 1
category: meta
type: guardian
phase: define
domain: quality
role: guardian
scope: design
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
source: "Adapted from addyosmani/agent-skills constraint-driven-development"
related_skills:
  - csp-tdd
  - csp-coding-standards
  - csp-security-review
anti_rationalizations:
  "We'll add constraints once the code settles": "Code settles around whatever was allowed while it was moving."
  "The tests are the constraints": "Tests prove you agree with yourself, not coverage/security/perf."
  "This will slow the agent down": "Only if slow checks land in fast loop. Cost decides placement."
---

# csp-constraints · 项目质量约束

Define a machine-checkable quality bar as CONSTRAINTS.md, then enforce it.

## Purpose

CSP has plenty of "how to do X" skills. This skill defines "what does good enough to ship mean for THIS project" — with numbers and commands, not prose. Spec says what. TDD proves it works. Constraints define the bar.

## When to Use

- ✅ Starting a project and no quality bar is written down
- ✅ Agent keeps silencing checks to get green
- ✅ Coverage/performance numbers argued per-PR
- ✅ Starting autonomous loops without a written bar
- ❌ Project already has CONSTRAINTS.md → read and follow it
- ❌ One-off scripts or throwaway prototypes

## Process

### Step 1: Detect Before You Ask

Read the codebase, don't ask cold:
- Language/stack from package.json/pyproject.toml/go.mod
- Test runner from devDeps
- Existing linters (eslint/biome/ruff)
- Current coverage (run it once)
- CI (.github/workflows/)

### Step 2: Four Questions with Defaults

```
Q1: Beyond the floor, which dimensions? (a) Coverage (b) Security (c) Perf (d) A11y
    DEFAULT: (a) and (b)

Q2: Block or warn when check fails mid-task?
    DEFAULT: Block on floor, warn on rest for first 2 weeks

Q3: Target numbers or measure-and-hold?
    DEFAULT: Measure and hold (ratchet)

Q4: Max check time before agent hands back?
    DEFAULT: 90s at task end, unlimited in CI
```

### Step 3: Write CONSTRAINTS.md

Produce one file at repo root with three tiers:

```markdown
# Constraints · Last reviewed: {date}

## Floor (always enforced)
- No new suppression comments (@ts-ignore/eslint-disable/#noqa)
- No unimplemented stubs (throw Error("Not implemented")/empty catch{})
- No skipped/deleted tests without reason
- No secrets in source
- This file does not get weakened

## Enforced with numbers
| Dimension | Rule | Checked by | Runs at |
|-----------|------|-----------|---------|
| Types | Zero errors | tsc --noEmit | every edit |
| Lint | Zero errors | biome check | every edit |
| Coverage | Changed lines ≥80% | vitest --coverage | task end, CI |

## Measured (ratchets)
| Metric | Today | Direction |
|--------|-------|-----------|
| Project coverage | 62% | must not fall |
```

Add `Read CONSTRAINTS.md before writing code.` to AGENTS.md/CLAUDE.md.

### Step 4: Install Tooling

Each picked dimension gets a real tool, a real command, and verification:
- Types → tsc/mypy, already there
- Coverage → your test runner's coverage mode
- Security → semgrep/gitleaks/osv-scanner
- Perf → Lighthouse/size-limit
- A11y → axe-core

**Before declaring a row enforced:** run the command against a known violation (should fail) and a clean control (should pass). Scanner errors must also fail.

### Step 5: Wire Check by Phase

| Phase | What runs | Budget |
|-------|-----------|--------|
| Edit | Types + lint + secrets + floor | <5s, changed files only |
| Task end | Related tests + coverage on changed | <90s |
| Review | Everything + guard checks | minutes |
| CI/Ship | Direction checks, no regressions | CI |

### Step 6: Guard the Bar

Watch the diff for five moves at review:
1. Threshold moved downward
2. Test got easier (.skip, deleted)
3. Checker silenced (new @ts-ignore)
4. Work unfinished (stub, empty catch)
5. New exception appeared without discussion

## Key Principles

- **Numbers > prose** — every enforced dimension has a number and a command
- **Ratchets, not targets** — record today + refuse to regress
- **External check needed** — at least one constraint from outside the test suite (axe, Lighthouse, osv-scanner)
- **Cost decides placement** — slow checks in CI, fast checks in edit loop
- **Floor is free** — day one enforcement with no tool installs

## Related Skills

- [[csp-tdd]] — the suite that constraints measure
- [[csp-coding-standards]] — the lint rules that constraints enforce
- [[csp-security-review]] — what the security dimension checks
- [[csp-interview-me]] — the question discipline this skill borrows