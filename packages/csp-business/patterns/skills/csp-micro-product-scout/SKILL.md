---
name: csp-micro-product-scout
description: >
  Use when discovering small overseas product opportunities for a solo indie
  developer — tools, browser extensions, platform plugins, converters, micro-SaaS.
  Hard filter: overseas users, real-case-accessible, competitor-adjacent (not clone),
  7-10 day MVP. Core principle: competitors validate demand, the opportunity is the
  small neglected action beside them.
  Keywords: micro product, indie, 小产品, overseas, scout, opportunity, 机会扫描.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: define
domain: patterns
role: specialist
scope: analysis
invocation: user
tools: [Read, WebFetch, WebSearch]
source: "Adapted from flreey/myskills overseas-micro-product-scout"
---

# csp-micro-product-scout · 微型产品机会扫描

Discover small overseas product opportunities a solo developer can build and sell.

## Purpose

Core principle: **Competitors validate demand. The opportunity is the small neglected action beside them.**

This is NOT broad startup idea research, NOT "free clone of paid tool", NOT local-regulatory domains. It finds gaps beside existing products — the small ignored use case, the export button, the plugin that 100 people on Reddit keep asking for.

## Hard Filters

- Overseas users (non-China market)
- Real-case-accessible input data (you can inspect it)
- Competitor-adjacent wedge (not a free clone)
- 7-10 day MVP for solo dev
- No local-regulatory domains (tax, legal, medical certification)

## Process

1. **Scan competitor ecosystem** — find products with existing paying users
2. **Map their edges** — what do they NOT do? what do users ask for in reviews/forums?
3. **Score by solo feasibility** — can one person build and sell this?
4. **Rank by build/sell ratio** — highest revenue per build hour wins