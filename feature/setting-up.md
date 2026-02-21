# Setting Up k-mcp-devkit

## What This Project Is

`k-mcp-devkit` is a toolkit for injecting your preferred dev conventions into any
coding agent that supports slash commands or persistent context files.

The core idea: define your dev mode once, install it into whichever agent you're
using that day. One source of truth, many targets.

---

## Problem

Every coding agent has its own convention for global and project-level context:

| Agent | Project context | Global context |
|---|---|---|
| Claude Code | `.claude/commands/*.md` | `~/.claude/commands/*.md` |
| Gemini CLI | `GEMINI.md` | `~/.gemini/GEMINI.md` |
| Amazon Kiro | `.kiro/steering/*.md` | _(not supported)_ |

Without a shared source, you end up maintaining the same conventions in multiple
places and they drift.

---

## Solution

A single `commands/` directory holds all command prompts. An `install.sh` script
copies them to the right place for a given agent:

```
./install.sh --agent claude-code          # project scope
./install.sh --agent claude-code --global # user scope
./install.sh --agent gemini
./install.sh --agent kiro
```

---

## Project Structure

```
k-mcp-devkit/
├── commands/                  # Source of truth for all command prompts
│   └── dev.md                 # /dev — enter dev mode
├── agents/                    # Per-agent install scripts
│   ├── claude-code.sh         # → .claude/commands/
│   ├── gemini.sh              # → GEMINI.md
│   └── kiro.sh                # → .kiro/steering/
├── install.sh                 # Main entry point
└── feature/                   # Planning docs (this folder)
```

---

## Agent Support Matrix

| Agent | Mechanism | Slash command? | Scope |
|---|---|---|---|
| Claude Code | `.claude/commands/*.md` | Yes — `/dev` | project + global |
| Gemini CLI | `GEMINI.md` appended | No — always-on section | project + global |
| Amazon Kiro | `.kiro/steering/*.md` | No — always-on steering | project only |

Agents with native slash command support (Claude Code) get a true `/dev` invocation.
Agents without it (Gemini, Kiro) get the content injected as persistent context —
the closest equivalent.

---

## Adding a New Command

1. Create `commands/<name>.md` with the prompt content
2. Re-run `./install.sh --agent <agent>` — all `commands/*.md` files are installed

## Adding a New Agent

1. Create `agents/<agent-name>.sh`
2. The script receives `--global` as `$1` when the flag is passed
3. It should read from `$SCRIPT_DIR/../commands/*.md` and write to the agent's target location

---

## Setup Checklist

- [x] `commands/dev.md` — dev mode prompt
- [x] `agents/claude-code.sh`
- [x] `agents/gemini.sh`
- [x] `agents/kiro.sh`
- [x] `install.sh` — unified entry point
- [ ] Test install on a real project for each agent
- [ ] Add more commands (e.g. `review.md`, `debug.md`)
- [ ] README with full usage docs
