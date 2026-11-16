---
name: csp-beautiful-article
description: >
  Use when converting any source (URL/PDF/DOCX/Markdown/text/screenshots) into
  a beautiful single-file HTML web article that can be opened offline and shared.
  Follows source→plan→checkpoint→first-spread→full→review harness workflow.
  Triggers: "做成网页文章", "生成可分享HTML", "beautiful web article", "reacticle".
  Keywords: 网页文章, beautiful article, HTML article, 长文, 可分享, single-file.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: patterns
role: specialist
scope: implementation
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
source: "Adapted from ConardLi/garden-skills beautiful-article"
---

# csp-beautiful-article · 网页文章

Convert source material into a beautiful single-file HTML web article.

## Purpose

Turn dry, linear text into visually rich, well-paced, shareable single-file HTML articles. HTML adds information density, visual clarity, and interactivity — tables, SVG, CSS, code snippets, copy/export buttons. The reader doesn't just read; they compare, navigate, review, and reuse.

## Boundaries

- ✅ Final output = single HTML article, not a web app
- ✅ Can use interactive elements serving reading/argument/pacing/aesthetics
- ❌ NOT: dashboards, forms, drag-drop workspaces, full products, generic web apps

## Workflow

```
Phase 0: Intake → judge if article-appropriate
Phase 1: Source → Markdown (URL/PDF/DOCX/MD/text → source.md)
Phase 2: Editorial Plan → Brief/Outline/Theme/Assets
Phase 3: ★ Checkpoint 1 — confirm article type, theme, layout, image mode, cover
Phase 4: First Spread → hero + first section + one representative visual block
         ★ Checkpoint 2 — confirm direction, switch to full production
Phase 5: Full Article → complete all sections
Phase 6: Final Review → polish, fixes
```

## Key Principles

- **Default 100% information retention** — don't cut content unless user confirms
- **Each element serves reading** — layout, motion, interaction all serve understanding
- **Single file** — offline-openable, shareable, self-contained
- **Two checkpoints** — user confirms direction before full production, not after