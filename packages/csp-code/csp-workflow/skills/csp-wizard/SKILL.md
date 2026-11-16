---
name: csp-wizard
description: >
  Use when a manual procedure needs to be walked through step-by-step by a human
  (provisioning infrastructure, setting up credentials/CI secrets, navigating
  third-party dashboards, running one-off migrations). Generates an interactive
  bash wizard script from `scripts/template.sh`.
  Keywords: wizard, 向导, setup, provisioning, 配置, credentials, CI secrets, migration.
version: "0.1.0"
layer: 2
category: workflow
type: technique
phase: build
domain: devops
role: specialist
scope: implementation
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
source: "Adapted from mattpocock/skills wizard pattern"
related_skills:
  - csp-devops
  - csp-deployment
---

# csp-wizard · 交互式操作向导

Generate an interactive bash wizard that walks a human through steps only they can perform.

## Purpose

For manual procedures that are tedious to do by hand and tedious to re-explain: provisioning infrastructure, setting up credentials or CI secrets, navigating an unfamiliar third-party dashboard, running a one-off migration or cutover.

The wizard opens each URL, says exactly what to click and copy, captures values, writes them where they belong (.env, GitHub secrets), confirms at every stage, and shows how many stages are left.

## When to Use

- ✅ Setting up third-party service credentials (API keys, OAuth apps)
- ✅ Configuring CI secrets (GitHub Actions, Vercel env vars)
- ✅ Walking through an unfamiliar dashboard (AWS console, Stripe)
- ✅ Running a one-off migration or cutover
- ❌ Steps the Agent can perform itself (use Bash tool directly)
- ❌ Fully automated deployments (use csp-devops)

## Process

### Step 1: Scope the Procedure

Read the repo first, don't ask cold:
- `.env`, `.env.example`, `.env.*` — every variable is a value to capture
- `README`, `docker-compose*`, framework config
- `.github/workflows/*` — every `secrets.*` / `vars.*` is a value to produce

Show the user:
- Ordered list of stages
- What each stage captures
- Where each value is written

**Done when**: every stage named, every value has a source and destination.

### Step 2: Map Each Stage's Journey

For each stage, write the precise path:
- URL to open
- What to do there
- Where the value is shown
- Which variable it fills

```
✅ "Dashboard → Developers → API keys → Reveal test key → copy"
❌ "Get the API key from the dashboard"
```

### Step 3: Author the Wizard Script

Copy `scripts/template.sh` to the target path. Write one `stage` per step.

Library helpers available:
- `banner "Title"` — opening frame
- `stage "Name"` — announces stage with progress (N/M)
- `say "..."` — plain instruction
- `step "..."` — numbered instruction
- `open_url "https://..."` — opens URL in browser
- `ask "Prompt"` / `ask_secret "Prompt"` — captures value
- `write_env KEY "value"` — writes to .env
- `set_secret NAME "value"` — writes GitHub secret
- `confirm "Proceed?"` — gate before irreversible action
- `pause "Ready?"` — wait for Enter

**Rules**:
- Don't edit the library section (above STAGES marker)
- Set `TOTAL_STAGES` to stage count
- `open_url` before `ask` for its value
- `ask_secret` for anything secret
- `write_env` every persisted value
- `confirm` before irreversible actions

### Step 4: Verify and Hand Off

- Run `bash wizard.sh` to verify it starts
- The wizard is ephemeral by default — delete after use
- Commit only for repeatable setup paths

## Examples

```bash
# Generated wizard for Stripe setup
./wizard-stripe-setup.sh
  Stage 1/5 · Create Stripe account
  Stage 2/5 · Get API keys
  Stage 3/5 · Set webhook endpoint
  Stage 4/5 · Configure CI secrets
  Stage 5/5 · Verify connection
```

## Related Skills

- [[csp-devops]] — For fully automated deployment procedures
- [[csp-deployment]] — For deployment strategies