---
name: csp-prompt-builder
description: >
  Use when turning a vague idea into a copy-ready structured prompt for another
  LLM (Claude/GPT/Gemini/image models). Covers image generation, writing, code,
  business, research, agent tasks with model-aware adaptation and defaults.
  Keywords: prompt builder, 提示词生成, structured prompt, prompt engineering.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: patterns
role: specialist
scope: implementation
invocation: user
tools: [Read, Write]
source: "Adapted from flreey/myskills prompt-builder"
---

# csp-prompt-builder · 提示词构架

Turn vague ideas into structured, copy-ready prompts for other LLMs.

## Purpose

The user often says "I want to build X" or "Make an image of Y" or "Help me write about Z" — but doesn't know how to phrase it for another model. This skill turns those rough ideas into high-quality prompts through guided choices, sensible defaults, and model-aware adaptation.

## When to Use

- ✅ "I want a prompt for GPT that does X"
- ✅ "Write me a Midjourney prompt for Y"
- ✅ "I need an agent prompt that handles Z"
- ❌ Design/planning workflows (use csp-brainstorming)
- ❌ System diagnosis (use csp-systematic-debugging)

## Process

1. **Clarify the goal** — what output do they want?
2. **Choose the model** — adapt format to target (GPT/Gemini/Claude/image)
3. **Build structure** — role, context, task, constraints, output format
4. **Self-critique** — would this prompt produce the right output?
5. **Deliver copy-ready** — single block they can paste