---
name: csp-writing-plans
description: "Use when you have a spec or requirements for a multi-step task, before touching code. Transforms specs into fully detailed, step-by-step implementation plans with file-level changes and verification steps. Use for planning non-trivial implementation work."
layer: 1
category: meta
phase: plan
domain: architecture
scope: design
tools: [Read, Write, Edit, Glob, Grep]
version: "1.0.0"
role: specialist
---

# Writing Plans

Transform a spec or requirements document into a fully detailed, step-by-step implementation plan. Every task includes exact file paths, complete code blocks, and precise commands — no placeholders, no ambiguity. Plans are written test-first (TDD) and structured so an engineer (or subagent) can execute each task independently.

```

## Task Structure

### Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate. When drawing task boundaries: fold setup, configuration, scaffolding, and documentation steps into the task whose deliverable needs them; split only where a reviewer could meaningfully reject one task while approving its neighbor. Each task ends with an independently testable deliverable.

### Interfaces Block (per task)

Every task declares what it consumes from earlier tasks and what it produces for later ones — exact function names, parameter types, and return types. This is how tasks communicate without a shared implementation:

```
**Interfaces:**
- Consumes: [what earlier tasks provide — exact signatures]
- Produces: [what later tasks rely on — exact names + types]
```

Slack in the interfaces is where bugs breed: if `clearLayers()` in Task 3 becomes `clearFullLayers()` in Task 7, the plan is broken. The self-review catches this.

### Step Granularity

**Each step is one action with a checkable result:**
- "Write the failing test" — step
- "Run it to make sure it fails" — step
- "Implement the minimal code" — step
- "Run tests and verify they pass" — step
- "Commit" — step

A step is done when the implementer can write exactly one reasonable thing from it. More than that is multiple steps; less than that is ambiguous.

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/code-skills-package/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use csp-executing-plans
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use csp:executing-plans
- Batch execution with checkpoints for review
