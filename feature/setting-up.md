# Setting Up k-mcp-devkit

## What This Project Is

`k-mcp-devkit` is a toolkit for entering a consistent dev mode in any coding agent
that supports slash commands or persistent context files.

One invocation — `/dev` — loads the current project and feature context, applies
dev practices, and gets the agent oriented. All context lives in the project repo
itself, not in agent-specific home directories.

---

## Problem

Every coding agent has its own convention for context injection. Without a shared
source you end up repeating and drifting your conventions across tools.

Additionally, agents often encourage writing context to global files (`~/.claude/`,
`~/.gemini/GEMINI.md`, etc.), which makes it hard to keep context scoped to a
project and tracked in version control.

---

## Solution

A single command prompt (`commands/dev.md`) acts as an orchestrator. When invoked,
it instructs the agent to:

1. Load (or interactively create) `context/project.md`
2. Load (or interactively create) `context/feature.md`
3. Read and apply all files in `practices/`

Everything stays inside the project root — no writes to global paths.

An `install.sh` script copies `commands/dev.md` to wherever the target agent
expects to find slash commands.

---

## Project Structure

```
k-mcp-devkit/
├── commands/
│   └── dev.md                 # /dev — orchestrator slash command
├── context/
│   ├── project.md             # what is this project (created/loaded by /dev)
│   └── feature.md             # what are we building now (created/loaded by /dev)
├── practices/
│   ├── git.md                 # branch naming, commit format, PR rules
│   ├── code.md                # code quality expectations
│   └── communication.md       # interaction style for this session
├── agents/
│   ├── claude-code.sh         # installs to .claude/commands/
│   ├── gemini.sh              # appends to GEMINI.md
│   └── kiro.sh                # installs to .kiro/steering/
├── install.sh                 # unified entry point
└── feature/                   # planning docs (this folder)
```

---

## Usage

Install the slash command for your agent:

```bash
./install.sh --agent claude-code          # project scope
./install.sh --agent claude-code --global # user scope
./install.sh --agent gemini
./install.sh --agent kiro
```

Then in your agent, invoke `/dev`.

The agent will:
- Load `context/project.md` and `context/feature.md` if they have content
- Ask you to fill them in if they are empty
- Apply `practices/git.md`, `practices/code.md`, `practices/communication.md`
- Confirm context and practices are loaded, then wait for your first instruction

---

## Agent Support Matrix

| Agent | Mechanism | Native slash cmd | Context scope |
|---|---|---|---|
| Claude Code | `.claude/commands/dev.md` | Yes — `/dev` | project + global |
| Gemini CLI | `GEMINI.md` section | No — always-on | project + global |
| Amazon Kiro | `.kiro/steering/dev.md` | No — always-on steering | project only |

---

## Extending

**New command** → add `commands/<name>.md`, re-run `./install.sh`

**New agent** → add `agents/<name>.sh`; it receives `--global` as `$1` when that flag is passed and should read from `$SCRIPT_DIR/../commands/*.md`

**New practice** → add `practices/<topic>.md` and reference it in `commands/dev.md`

---

## Checklist

- [x] `commands/dev.md` — orchestrator slash command
- [x] `context/project.md` — project context stub
- [x] `context/feature.md` — feature context stub
- [x] `practices/git.md`
- [x] `practices/code.md`
- [x] `practices/communication.md`
- [x] `agents/claude-code.sh`
- [x] `agents/gemini.sh`
- [x] `agents/kiro.sh`
- [x] `install.sh`
- [ ] Test install + `/dev` invocation for each agent
- [ ] README with full usage docs
