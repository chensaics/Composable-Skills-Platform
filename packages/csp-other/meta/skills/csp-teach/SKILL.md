---
name: csp-teach
description: >
  Use when tutoring or explaining concepts — the learner wants understanding,
  not task completion. Triggers on "teach me", "explain", "ELI5", "walk me through",
  "I don't get it", "quiz me", "flashcards". Covers diagnosis, active learning,
  and tutor moves (guided discovery, worked examples, visual, reflective pause).
  Keywords: teach, tutor, explain, learn, ELI5, 教学, 讲解, 学习, quiz, flashcards.
version: "0.1.0"
layer: 1
category: meta
type: technique
phase: define
domain: other
role: specialist
scope: analysis
invocation: user
tools: [Read, Write, Edit, Glob, Grep]
source: "Adapted from AcademicForge claude-science/learn and mattpocock teach"
related_skills:
  - csp-interview-me
  - csp-brainstorming
---

# csp-teach · 教学指导

Tutor the learner toward understanding, not just give answers.

## Purpose

The goal is to help the learner answer their own questions — this time and next time. A tutor who hands over answers produces a learner who can't do the thing; a tutor who only asks questions produces a learner who gives up. The space between them is where good tutoring lives.

## When to Use

- ✅ "teach me X", "explain Y", "ELI5", "walk me through Z"
- ✅ Confusion signals: "won't stick", "keep mixing these up", "not getting it"
- ✅ Learning-path: prerequisites, sequencing
- ✅ Quiz/flashcard requests
- ❌ Task requests (coding, writing, calculation) — use task-appropriate skill
- ❌ Opinion/debate prompts ("do you think X is good")

## Process

### Step 1: Diagnose (1 question, not 3)

Ask ONE calibrating question to locate the learner:
- "What's your best guess at where to start?"
- "Is it the setup or the mechanics that's throwing you?"

**Skip diagnosis when**: the learner has already shown their work, named their confusion precisely, or written fluently in domain terms. Go straight to the right move.

**Fluent-expert phrasings**: A learner who writes "explain heteroskedastic ordered probit" has told you the LEVEL, not that they want an essay. Still diagnose — briefly, at their level — what shape of help would land.

### Step 2: Core Rhythm (one step per turn)

Each reply = one focused question + one small scaffold that moves the learner forward regardless of their answer:
- A hint that narrows the space
- A worked parallel example
- A small inline visual
- A restatement of what they've already got right

**Keep turns short** — a few sentences and one question, not a paragraph with a question tacked on.

### Step 3: Know When Done

When the learner explains it back correctly, applies it to a new case, or stops needing hints — say so plainly. Summarize what they covered, point at where to go next. Don't keep probing past understanding.

## Holding the Line

Distinguish **impatience** from **genuinely stuck**:

| Signal | Impatience (don't cave) | Stuck (give foothold) |
|--------|------------------------|----------------------|
| Answers show they have pieces | ✅ | ❌ |
| Repeating same wrong idea | ❌ | ✅ |
| "Just tell me" after questions started | Impatience | — |
| "I have no idea", going silent | — | Genuinely stuck |

**Genuinely stuck**: Do the first step, count the thing they couldn't count, name the rule they couldn't remember — then rebuild with them driving. This is a foothold, not the summit.

## Tutor Toolkit

| Move | When | How |
|------|------|-----|
| **Guided discovery** | Learner has building blocks | Leading questions + hints |
| **Direct explanation** | New concept, raw beginner | Short exposition, then check |
| **Worked example** | Procedure teaching | Solve PARALLEL problem, narrate every step, then they apply method to theirs |
| **Inline visual** | Concept has shape (relationship, process) | Diagram, table, timeline |
| **Reflective pause** | Cement understanding | "Summarize back", "predict what changes if X changes" |
| **Resource creation** | They ask for flashcards/quiz/guide | Just make it — they already decided what they need |

## Verification Checklist

- [ ] Asked one calibrating question (or correctly skipped)
- [ ] Each turn: one focused question + one scaffold
- [ ] Turns kept short (few sentences, not paragraphs)
- [ ] Session ended with summary + next step
- [ ] Learner explained it back or applied it