## Git Setup

Branch: `claude/install-agents-feature-pdfH6` (already active — matches session requirement).

---

## Feature Brief

Replace kdevkit's Claude Code slash-command installer with a Claude **agent** installer. Provide a companion install-agent capability so users can tell the coding agent to install any agent from a URL or local path. The agent file format is identical for Claude Code CLI and Claude Code on the web (same `.claude/agents/` directory), so a single generated output covers both.

---

## Requirements

### Problem

kdevkit currently installs as a slash command (`.claude/commands/dev.md`). Slash commands are user-invoked one-shots. Claude **agents** (`.claude/agents/*.md`) are better because:
- They have YAML frontmatter declaring name, description, and tool restrictions.
- They can be invoked by Claude itself (e.g. via Task tool) or by the user.
- They integrate cleanly with Claude Code's agent orchestration model.

### User-facing behaviour

1. **Install kdevkit as an agent**: `npx github:kusimari/kdevkit claude-code-agent` writes `dev.md` to `.claude/agents/dev.md` (project) or `~/.claude/agents/dev.md` (global). A companion `install-agent.md` agent is also installed.
2. **Install any agent via the coding agent**: User says "install agent from <URL or path>". The `install-agent` agent fetches/reads the file, parses the YAML frontmatter for the agent name, and writes it to `.claude/agents/<name>.md`.
3. **Same format for CLI and web**: The generated `agent.md` (YAML frontmatter + content) works identically in Claude Code CLI and Claude Code on the web. Both read `.claude/agents/` in the project root.
4. **Self-update awareness**: The dev agent's self-update step knows both the commands path (`.claude/commands/dev.md`) and the agents path (`.claude/agents/dev.md`); it detects which one applies.

### Success criteria

- `install.js claude-code-agent` creates `.claude/agents/dev.md` with valid YAML frontmatter.
- `build/agent.md` starts with `---` YAML frontmatter, followed by `<!-- kdevkit:built:... -->` comment.
- `build/install-agent.md` is a well-formed agent file with instructions Claude can follow to install any agent from a URL/path.
- All existing tests still pass.
- New `tests/install/claude-code-agent.sh` tests pass.

---

## Design

### New build outputs

| Output | Source files | Purpose |
|--------|-------------|---------|
| `build/agent.md` | `src/agent-header.md` + existing dev.md src files | Dev command as a Claude agent (frontmatter + content) |
| `build/install-agent.md` | `src/install-agent.md` | Agent for installing other agents |

### `build/agent.md` structure

```
---
name: dev
description: Structured dev mode — loads project context, manages feature files, applies git conventions.
---
<!-- kdevkit:built:TIMESTAMP -->
<!-- kdevkit:source:SOURCE -->
## Step 0 — Self-update check
...
```

`build.js` must insert the timestamp comment *after* the closing `---` of the frontmatter (not before it), so YAML parsing isn't broken.

### `install.js` new target: `claude-code-agent`

- Project scope: `.claude/agents/dev.md` + `.claude/agents/install-agent.md` + `.claude/agents/kdevkit/feature-setup.md` + `.claude/agents/kdevkit/git-practices.md`
- Global scope: same paths under `~/.claude/agents/`
- Source file: `agent.md` (not `dev.md`)
- `install-agent.md` fetched as a companion (new entry in `COMPANION_FILES` logic for this agent type)

### `src/install-agent.md` — the install-agent agent

YAML frontmatter: `name: install-agent`, `description: Install a Claude agent from a URL or local path`.

Body: step-by-step instructions Claude follows to:
1. Obtain source URL or path from user.
2. Fetch (via `Bash: curl`) or read (via `Read` tool) the file.
3. Parse YAML frontmatter to extract `name`.
4. Determine install path: `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (global — CLI only; web is project-only).
5. Confirm with user, write the file.
6. Report completion.

### Self-update step change (`src/00-selfupdate.md`)

Add agent paths to the list of default paths in Step 6b:
- Claude Code (agent): `.claude/agents/dev.md` (or `~/.claude/agents/dev.md` if globally installed)

Update the companion directory note for agent installs: `kdevkit/` subdirectory alongside `dev.md` in `.claude/agents/`.

Update Step 1 to say: look for the timestamp in the **first 10 lines** (to handle the case where frontmatter precedes the comment).

---

## Test Strategy

New file: `tests/install/claude-code-agent.sh`

Tests:
- Project-scope install creates `.claude/agents/dev.md` and `.claude/agents/install-agent.md`.
- Installed `dev.md` starts with `---` (YAML frontmatter).
- Installed `dev.md` contains `kdevkit:built:` timestamp.
- Installed `dev.md` contains `kdevkit:source:local`.
- Companion files created at `.claude/agents/kdevkit/`.
- Global-scope install creates files under `~/.claude/agents/`.
- Idempotent re-install overwrites cleanly.

Existing tests (`tests/install/claude-code.sh`) remain unchanged — the `claude-code` slash-command target is kept for backward compatibility.

---

## Implementation Plan

1. `src/agent-header.md` — YAML frontmatter for the dev agent.
2. `src/install-agent.md` — install-agent agent instructions.
3. `build.js` — add `agent.md` and `install-agent.md` to MANIFEST; special timestamp insertion for agent.md.
4. `install.js` — add `claude-code-agent` case.
5. `src/00-selfupdate.md` — add agent path, widen timestamp search.
6. `tests/install/claude-code-agent.sh` — new test suite.
7. Run `npm run build && npm test`; fix failures.

---

## Session Log

- 2026-02-26: Feature file created. Branch `claude/install-agents-feature-pdfH6` already active.

## Decision Log

- Keep `claude-code` (slash-command) target in `install.js` for backward compatibility.
- Use `agent.md` as the build output for the agent version to avoid overloading `dev.md`.
- Timestamp comment goes *after* the YAML frontmatter closing `---` so YAML parsing is unaffected.
- `install-agent.md` is an always-present companion alongside `dev.md` in the agent install.
- Agent format is identical for CLI and web; no separate web-specific output needed.
