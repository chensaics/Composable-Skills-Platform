---
name: csp-handoff
description: >
  Use when approaching context limit (300K+ tokens), needing a clean session start,
  delegating work to another agent, or saving progress. Creates/loads a structured
  JSON handoff with goals, decisions, completed/pending steps, and file changes.
  Keywords: handoff, 交接, save state, resume, 继续, clean session, context rot.
version: "0.1.0"
layer: 4
category: runtime
type: technique
phase: verify
domain: other
role: specialist
scope: analysis
invocation: user
tools: [Read, Write]
source: "Adapted from psenger/ai-agent-skills handoff pattern"
related_skills:
  - csp-lifecycle-orchestrator
---

# csp-handoff · 会话交接

Save or load a structured session state so work survives context limits.

## When to Use

- ✅ Context approaching limit (300K+ tokens)
- ✅ Need a clean session start
- ✅ Delegating work to another agent
- ✅ After 5+ file edits or a major decision — suggest creating handoff
- ✅ Resuming: "load handoff", "continue where we left off"

## CREATE Mode

### Output Path
`.csp/handoffs/YYYY-MM-DD-HHMMSS-<slug>.json`

### Content
```json
{
  "task": {
    "goal": "one sentence",
    "acceptance_criteria": ["testable criterion"]
  },
  "current_state": "one paragraph summary",
  "completed_steps": ["past tense, done"],
  "pending_steps": ["imperative, ordered — first is next action"],
  "constraints": ["hard limits"],
  "discovered_issues": ["known unfixed problems"],
  "modified_files": [{"path": "...", "status": "created|modified|deleted", "note": "..."}],
  "decisions": [{"decision": "...", "rationale": "...", "alternatives_rejected": [...]}]
}
```

### Confirm
After writing, output:
```
Handoff → .csp/handoffs/<filename>
Task: <goal> | Done: N | Pending: N | Files: N
Next: Run /clear, start new session, load handoff to resume.
```

## RESUME Mode

1. Read `.csp/handoffs/`, pick most recent by timestamp
2. Report: "Loaded <file>. Task: <goal>. First pending: <step>."
3. Start work immediately with `pending_steps[0]`
4. Keep `constraints` and `decisions` visible — don't re-litigate