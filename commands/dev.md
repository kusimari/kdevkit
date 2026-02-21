# /dev — Enter Dev Mode

Usage: `/dev [path/to/feature.md]`

Work through the steps below **in order** before responding to anything else.

---

## Step 1 — Project context

Read `context/project.md` from the project root.

- **File has content** → load it silently; note what the project is in your internal context.
- **File is missing or empty** → ask exactly one question:
  *"Briefly describe this project — purpose, tech stack, and any hard constraints."*
  Wait for the answer, then create `context/project.md` with a well-structured summary.
  Do not continue to Step 2 until the file exists with real content.

## Step 2 — Feature context

Determine the feature file to load:
- If an argument was passed (`$ARGUMENTS`), use that path as the feature file.
- Otherwise, use `context/feature.md`.

Then:
- **File has content** → load it silently; note what is currently being built.
- **File is missing or empty** → run the feature setup interview defined in `practices/feature-setup.md` to create it.
  Do not continue to Step 3 until the file exists with real content.

## Step 3 — Git practices

Read and apply `practices/git.md` for the full duration of this session.

If the file is missing, note it in your confirmation and continue.

## Step 4 — Session behaviour (always active)

Apply these rules throughout the entire session without needing to be reminded:

**Keep the feature file current.** After each meaningful unit of work — a decision made, a subtask completed, an open question resolved — update the feature file to reflect the current state. Do not batch updates to the end of the session.

**Feature completion.** When the user indicates that the feature is done, finished, or complete:
1. Prompt: *"Before we close out — shall I update `context/project.md` with what changed? This keeps future sessions oriented."*
2. If yes: summarise what was built, key decisions made, and any new constraints or patterns introduced, then update `context/project.md` accordingly.
3. If no: acknowledge and move on.

## Step 5 — Confirm

Reply with a compact summary:

```
Project:  <one sentence from context/project.md>
Feature:  <one sentence from the feature file> [<path to feature file>]
Practices: git loaded
```

Then stop and wait for the first instruction.

---

*Managed by [k-mcp-devkit](https://github.com/kusimari/k-mcp-devkit). Context in `context/`. Practices in `practices/`.*
