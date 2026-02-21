# /dev — Enter Dev Mode

Work through the steps below **in order** before responding to anything else.

---

## Step 1 — Project context

Read `context/project.md` from the project root.

- **File has content** → load it silently; note what the project is in your internal context.
- **File is missing or empty** → ask exactly one question:
  *"Briefly describe this project — purpose, tech stack, and any hard constraints."*
  Wait for the answer, then create `context/project.md` using the template in that file.
  Do not continue to Step 2 until the file exists with real content.

## Step 2 — Feature context

Read `context/feature.md` from the project root.

- **File has content** → load it silently; note what is currently being built.
- **File is missing or empty** → ask exactly one question:
  *"What feature or task are we working on right now?"*
  Wait for the answer, then create or update `context/feature.md` using the template in that file.
  Do not continue to Step 3 until the file exists with real content.

## Step 3 — Dev practices

Read and apply each of the following files for the full duration of this session:

- `practices/git.md`
- `practices/code.md`
- `practices/communication.md`

These files live in the project root alongside this command. If any are missing, skip that section and note it in your confirmation.

## Step 4 — Confirm

Reply with a compact summary:

```
Project:   <one sentence from context/project.md>
Feature:   <one sentence from context/feature.md>
Practices: git, code, communication loaded
```

Then stop and wait for the first instruction.

---

*Managed by [k-mcp-devkit](https://github.com/kusimari/k-mcp-devkit). Context lives in `context/`. Practices live in `practices/`.*
