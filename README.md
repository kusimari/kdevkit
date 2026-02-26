# kdevkit

A Claude agent that brings structured workflow to coding sessions — loads project context, manages feature files, and applies git conventions.

---

## What is this for?

kdevkit installs a Claude agent (`kdevkit-dev`) that, when invoked, walks through a structured process before any coding begins:

1. Loads project context from `.kdevkit/project.md`
2. Loads or creates a feature file under `.kdevkit/feature/`
3. Applies git conventions (branch naming, commit format, PR rules)
4. Confirms the plan before starting work

This keeps sessions consistent and context-rich, regardless of whether you're in Claude Code CLI or Claude Code on the web.

---

## In CLI (Claude Code)

### Install

Tell Claude to install the agent:

```
Install agent from https://raw.githubusercontent.com/kusimari/kdevkit/main/build/kdevkit-dev.md
```

Claude will fetch the file and write it to `.claude/agents/kdevkit-dev.md`.

### Invoke

```
use the kdevkit-dev agent for feature: <feature-name>
```

Add `yolo` to chain phases automatically without confirmation stops:

```
use the kdevkit-dev agent for feature: <feature-name> with yolo
```

---

## In web or ephemeral systems

### Install and invoke

Tell Claude at the start of a session:

```
Fetch https://raw.githubusercontent.com/kusimari/kdevkit/main/build/kdevkit-dev.md and run the kdevkit-dev agent for feature: <feature-name>
```

Claude will load the agent content directly and begin the structured workflow.
