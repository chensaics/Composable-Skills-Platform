---
name: csp-break-ui
description: >
  Use when stress-testing UI components with worst-case data — long names,
  zero items, empty states, non-Latin text, emoji, extreme numbers, missing
  fields. Feeds demo data + worst-case toggle to find everything that breaks.
  Triggers on "stress test", "break this", "worst case", "边缘情况", "极限测试".
  Keywords: stress test, break UI, edge cases, 边缘, 极限, worst-case, robustness.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: verify
domain: testing
role: specialist
scope: review
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
source: "Adapted from emilkowalski/skill break-ui"
---

# csp-break-ui · 组件压力测试

Feed a UI worst-case data and report everything that breaks.

## Purpose

Components look fine with normal data. The real test is what happens with long names, zero items, one-letter inputs, huge counts, missing fields, non-Latin text, emoji, extreme numbers. This skill feeds those edge cases and reports every break, with the fix for each.

## Stress Data Generator

Feed these worst cases:

| Type | Worst case |
|------|-----------|
| Text | 100-char name, 1-char name, empty string, RTL text, emoji |
| Numbers | 0, -1, MAX_INT, NaN, very large |
| Lists | empty, 1 item, 10K items |
| Dates | 1970-01-01, 2099-12-31, invalid |
| Nulls | missing field, `null`, `undefined` |
| Special | accented chars, URL in text, `<script>alert(1)</script>` |

## Process

1. **Render component** with each worst-case input
2. **Toggle** between "Demo data" and "Worst case" views
3. **Report** every break: overflow, misalignment, crash, missing label
4. **Suggest fix** for each break found

## Red Flags

- Layout overflow on long text
- Empty state renders nothing (user thinks it's broken)
- Number overflow/underflow
- XSS from unescaped input
- Crash on null/missing field