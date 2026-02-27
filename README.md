# kdevkit

A Claude agent that brings structured workflow to coding sessions — loads project context, manages feature files, and applies git conventions.

---

## What is this for?

kdevkit installs a Claude agent (`kdevkit-dev`) that, when invoked, walks through a structured process before any coding begins:

1. Loads project context from `.kdevkit/project.md`
2. Loads or creates a feature file under `.kdevkit/feature/`
3. Applies git conventions (branch naming, commit format, PR rules)
4. Confirms the plan before starting work

---

## In CLI (Claude Code)

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/build/kdevkit-dev.md \
  -o .claude/agents/kdevkit-dev.md
```

Or tell Claude to do it:

```
Download https://raw.githubusercontent.com/kusimari/kdevkit/main/build/kdevkit-dev.md to .claude/agents/kdevkit-dev.md
```

### Invoke

```
use the kdevkit-dev agent for feature: <feature-name>
```

---

## In web or ephemeral systems

Tell Claude at the start of a session:

```
Fetch https://raw.githubusercontent.com/kusimari/kdevkit/main/build/kdevkit-dev.md and run the kdevkit-dev agent for feature: <feature-name>
```
