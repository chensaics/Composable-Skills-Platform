---
name: csp-drawio
description: >
  Use when generating draw.io architecture diagrams, flowcharts, decision trees,
  comparisons, or converting Markdown documents into draw.io XML. Structured
  pipeline: MD analysis → diagram type selection → XML generation → self-check.
  Triggers on "drawio", "画图", "架构图", "流程图", "对比图", "决策树".
  Keywords: drawio, draw.io, architecture diagram, 架构图, flowchart, 流程图, XML.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: architecture
role: specialist
scope: implementation
invocation: user
tools: [Read, Write, Edit, Glob, Grep]
source: "Adapted from drawio-best-practice skill"
related_skills:
  - csp-tech-diagram
  - csp-code-graph
---

# csp-drawio · 结构化图表生成

Generate readable draw.io diagrams with minimum effort.

## Purpose

A good diagram = 3 seconds to grasp structure + 30 seconds to understand details. This skill provides a structured pipeline for generating draw.io XML from documents, plus standardized conventions for colors, layout, and element selection.

## MD→Drawio Pipeline

### Step 1: Analyze Document Structure

| MD structure | Maps to drawio type |
|-------------|---------------------|
| `# Title` + `## Sections` | Part chapters (colored title bars) |
| Tables `|...|` | HTML `<table>` with color rows |
| Ordered lists `1. 2. 3.` | SOP step boxes (rectangles + arrows) |
| Conditions "if...then..." | Decision tree (diamonds + rectangles) |
| Priority P0/P1/P2 | Color coding (红/黄/绿) |
| Links `[text](url)` | UserObject clickable links |

### Step 2: Choose Layout

| Info type | Use | Avoid |
|-----------|-----|-------|
| Yes/no chain | Decision tree (diamond→rectangle) | Table |
| Multi-step ops | Side-by-side rectangles + arrows | Plain text list |
| Multi-dimension comparison | HTML `<table>` | Markdown table |
| Metric matrix | HTML `<table>` + color rows | Many small boxes |
| Topology/panorama | Layered layout + attribution colors | Everything in one layer |
| Escalation path | Horizontal nodes + arrows | Plain text |

### Step 3: Generate XML

Follow drawio XML conventions. Key rules:
- HTML tables: `rounded=0;whiteSpace=wrap;html=1;overflow=fill` (NEVER `shape=table`)
- Decision nodes: rhombus, yellow fill `#fff2cc`
- Color = one dimension only (attribution OR priority, not both)
- Links use `<UserObject link="URL">` not plain mxCell value
- XML entity escaping: `<`→`&lt;`, `>`→`&gt;`

### Step 4: Self-Check

Run the 10-point checklist in `references/checklist.md`

## Standard Colors

| Semantic | fillColor | strokeColor | Use |
|----------|-----------|-------------|-----|
| Safe/green | `#d5e8d4` | `#82b366` | Normal, pass |
| Warning/amber | `#fff2cc` | `#d6b656` | Attention, conditional |
| Danger/red | `#f8cecc` | `#b85450` | Fail, P0, block |
| Info/blue | `#dae8fc` | `#6c8ebf` | Steps, operations |
| Neutral/grey | `#f5f5f5` | `#cccccc` | Mixed, deprecated |

## Key Principles

- **Table vs graphic rule**: classification lists → table (lowest reading cost); flows/cause-effect → graphic (arrows express relationships); both → hybrid
- **Color does one thing**: one diagram = one color dimension. Priority uses emoji prefixes (🔴🟡⚪) when color is used for attribution
- **Layout rhythm**: title→part-bars→content→next-part, 50-60px gaps between parts
- **No markdown tables** in drawio — they don't render. Use HTML `<table>` instead