---
name: csp-contract-review
description: >
  Use when reviewing contracts, NDAs, employment agreements, SaaS terms, or
  any legal document. Pre-review checklist (blank fields, missing exhibits,
  signature status), CUAD risk categories, key term extraction, and redline
  suggestions. Triggers on "review contract", "analyze agreement", "check NDA".
  Keywords: contract review, NDA, legal, 合同审查, 法律, agreement, redline.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: review
domain: other
role: specialist
scope: review
invocation: user
tools: [Read, Write]
source: "Adapted from evolsb/claude-legal-skill contract-review"
---

# csp-contract-review · 合同审查

Review legal contracts for risks, extract key terms, suggest improvements.

## When to Use

- ✅ "review this contract", "analyze this NDA", "check this agreement"
- ✅ Contract risk assessment for solo founders/indie hackers
- ❌ Providing legal advice (this is analysis, not advice)
- ❌ Replacing a lawyer for high-stakes deals

## Pre-Review Checklist

Before analyzing content, verify document completeness:

- [ ] **Blank fields**: Flag any `$X`, `TBD`, `[amount]`, `____` placeholders
- [ ] **Missing exhibits**: List all referenced schedules/exhibits, note which are missing
- [ ] **Signature status**: Draft or already executed?
- [ ] **All pages present**: Check for truncation

## Review Categories

| Category | Key Questions |
|----------|--------------|
| Payment terms | When, how much, what triggers payment? |
| Termination | When can either party walk away? Notice period? |
| Liability | What's capped? What's excluded? |
| IP ownership | Who owns what's created? |
| Confidentiality | What's covered, how long, what's excluded? |
| Non-compete | Geography, duration, scope? Enforceable? |
| Dispute resolution | Arbitration vs court? Which jurisdiction? |

## Output Format

```
Risk Level: Low / Medium / High
Key Issues: Top 3-5 concerns with suggested fixes
Favorable Terms: What's working in client's favor
Missing Clauses: What should be added
```