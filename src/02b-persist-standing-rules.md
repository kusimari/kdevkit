## Step 1.5 — Persist standing rules

Write the kdevkit standing rules into the agent's native configuration file so they survive across sessions without needing to be reloaded manually.

**Identify the running agent** and target the corresponding file:

| Agent | Target file |
|---|---|
| Claude Code | `CLAUDE.md` |
| Gemini CLI | `GEMINI.md` |
| OpenAI Codex | `AGENTS.md` |
| Kiro | `.kiro/steering/workflow.md` |

**Idempotency check:** Read the target file (if it exists). If it already contains `<!-- kdevkit:standing-rules -->`, skip this step — the rules are already persisted.

**If absent:** Append the block below to the target file. Do not modify any existing content — only append. For Kiro, create the `.kiro/steering/` directory if it does not exist.

```markdown
<!-- kdevkit:standing-rules -->
## kdevkit Standing Rules

### Git Practices

**Branches:** `<type>/<short-description>` — types: `feat` · `fix` · `chore` · `docs` · `refactor` · `test`

**Commits:** Conventional Commits — `type(scope): subject`; imperative mood, lowercase, no trailing period; subject ≤ 72 chars; body explains *why* not *what*; every commit must leave the repo in a working state.

**Scope:** Changes stay local to this project — never modify global git config or write outside the project root.

**Pull Requests:** Title follows `type(scope): subject`; body explains *why* and what approach was chosen; keep PRs small (one concern per PR); squash merge.

**Hygiene:** No commented-out code, debug prints, temporary test files, secrets, or credentials in commits.

### Session Behaviour

**Feature file:** Update `.kdevkit/feature/<name>.md` after each meaningful unit of work — do not batch updates.

**Phase gating:** Never chain phases automatically — stop and wait for explicit instruction between phases.

**Assumptions:** If a phase input is ambiguous, present a brief plan and wait for approval before proceeding.

**YOLO mode:** "yolo" drops phase gates and assumption plans; "yolo off" restores normal behaviour.

**Feature completion:** When the feature is done, offer to update `.kdevkit/project.md` with what changed.
<!-- /kdevkit:standing-rules -->
```
