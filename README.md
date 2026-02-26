# kdevkit

Structured dev mode for Claude Code — loads project context, manages feature files, applies git conventions.

---

## What is this?

kdevkit is a Claude agent that brings structured workflow to coding sessions. When you invoke it, it:

1. Loads project context from `.kdevkit/project.md`
2. Loads or creates a feature file under `.kdevkit/feature/`
3. Applies git conventions (branch naming, commit format, PR rules)
4. Confirms the plan before starting work

The agent file is `.claude/agents/kdevkit-dev.md` — it works in both Claude Code CLI and Claude Code on the web (claude.ai projects).

---

## In CLI (Claude Code)

### Install

```sh
npx github:kusimari/kdevkit
```

For user-scope install (available across all projects):

```sh
npx github:kusimari/kdevkit --global
```

This writes `kdevkit-dev.md` (and companion files) to `.claude/agents/`.

### Invoke

Tell Claude:

```
use the kdevkit-dev agent for feature: <feature-name>
use the kdevkit-dev agent for feature: <feature-name> with yolo
```

Or via the Task tool in another agent:

```
use the kdevkit-dev agent
```

---

## In web or ephemeral systems

For Claude Code on the web (claude.ai projects) or any environment where you can't run npm:

### Install

1. Fetch the raw agent file:
   ```
   https://raw.githubusercontent.com/kusimari/kdevkit/main/build/kdevkit-dev.md
   ```
2. In your claude.ai Project → **Add content** → paste the file contents.

Or tell Claude directly at the start of a session:

```
Fetch https://raw.githubusercontent.com/kusimari/kdevkit/main/build/kdevkit-dev.md and follow those instructions for feature: <feature-name>
```

### Invoke

Once the agent content is in your project context:

```
Enter dev mode for feature: <feature-name>
Enter dev mode for feature: <feature-name> with yolo
```

`yolo` chains phases automatically and skips assumption plans. Say `yolo off` at any point to return to gated mode.
