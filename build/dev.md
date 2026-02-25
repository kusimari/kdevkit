<!-- kdevkit:built:2026-02-25T03:51:34.163Z -->
## Step 0 — Self-update check

Before doing anything else, check whether kdevkit is up to date. This step is silent unless an update is found.

1.  **Find the build timestamp** — look for `<!-- kdevkit:built:{TIMESTAMP} -->` at the top of this file.
    If not found, skip this step entirely and continue to Step 1.

2.  **Find the install source** — look for `<!-- kdevkit:source:{SOURCE} -->` in this file.
    Supported values:
    - `github-pages` — fetch `https://kusimari.github.io/kdevkit/dev.md`
    - `raw` — fetch `https://raw.githubusercontent.com/kusimari/kdevkit/main/build/dev.md`
    - `local` — read `build/dev.md` relative to the project root (skip if the file is missing)

    If the source comment is not found, skip this step.

3.  **Fetch the remote version** from the URL or path determined above.
    If the fetch fails for any reason (network error, file missing), skip this step silently.

4.  **Compare timestamps** — extract `<!-- kdevkit:built:{REMOTE_TIMESTAMP} -->` from the remote content.
    If the timestamps are identical, skip this step. No message needed.

5.  **Prompt the user** if the remote timestamp is newer:
    *"kdevkit update available — remote: {REMOTE_TIMESTAMP}, installed: {LOCAL_TIMESTAMP}. Update now?"*

6.  **If yes — apply the update:**
    a. Take the remote content. Re-insert the original `<!-- kdevkit:source:{SOURCE} -->` comment on the
       line immediately after the new `<!-- kdevkit:built:... -->` line (the remote content will not have it).
    b. **IMPORTANT**: The following are default paths. Before writing, verify that the target file or directory exists. If it does not, ask the user for the correct path.
       Overwrite `dev.md` with the updated content:
       - Claude Code: `.claude/commands/dev.md` (or `~/.claude/commands/dev.md` if globally installed)
       - Kiro: `.kiro/steering/dev.md`
       - Gemini: replace only the `## kdevkit: dev` section in `GEMINI.md` (or `~/.gemini/GEMINI.md`)
    b2. Update companion files from the same source. **Verify paths before writing**:
        - `github-pages` → fetch `https://kusimari.github.io/kdevkit/feature-setup.md` and `.../git-practices.md`
        - `raw` → fetch `https://raw.githubusercontent.com/kusimari/kdevkit/main/build/feature-setup.md` and `.../git-practices.md`
        - `local` → read `build/feature-setup.md` and `build/git-practices.md`
        For Claude Code and Kiro: write each to the `kdevkit/` subdirectory alongside `dev.md`.
        For Gemini: replace the `## kdevkit: feature-setup` and `## kdevkit: git-practices` sections.
        If any companion fetch fails, note it but continue.
    c. Diff the old and new content to identify which steps changed.
    d. If Step 1 (project context guidance) changed: note *"Project context step updated — consider reviewing `.kdevkit/project.md`."*
    e. If Steps 2–4 (feature context or setup guidance) changed: note *"Feature guidance updated — consider reviewing the current feature file."*
    f. Confirm: *"kdevkit updated to {REMOTE_TIMESTAMP}."*

7.  **Continue to Step 1** regardless of whether an update was applied or skipped.

------

# /dev — Enter Dev Mode

Usage: `/dev [feature] [options]`

Options (`yolo` is **off** by default): `yolo` — chain phases and skip assumption plans; `yolo off` — revert.
Gemini/Kiro/fetch: include options in the message — e.g. _"enter dev mode for my-feature with yolo"_.

**Before Step 1**, parse `$ARGUMENTS` (or the invocation message): extract recognized option tokens and apply them; the rest is the feature name for Step 2.

Work through the steps below **in order**. Load companion files before starting:
- `kdevkit/feature-setup.md` — Feature Setup (Step 2, new features) · `https://kusimari.github.io/kdevkit/feature-setup.md`
- `kdevkit/git-practices.md` — Git conventions (Step 3) · `https://kusimari.github.io/kdevkit/git-practices.md`

---

## Step 1 — Project context

Read `.kdevkit/project.md` from the project root.

- **File has content** → load it silently; note what the project is in your internal context.
- **File is missing or empty** → ask exactly one question:
  *"Briefly describe this project — purpose, tech stack, and any hard constraints."*
  Wait for the answer, then create `.kdevkit/project.md` with a well-structured summary.
  Do not continue to Step 2 until the file exists with real content.

## Step 2 — Feature context

Determine the feature file to load:
- If an argument was passed (`$ARGUMENTS`), derive the path: `.kdevkit/feature/<argument>.md`
  (lowercase the argument and replace spaces with hyphens — e.g. `user auth` → `.kdevkit/feature/user-auth.md`).
- Otherwise, ask: *"Which feature are you working on? Provide a short name."*
  Use the answer the same way: `.kdevkit/feature/<name>.md`.

Then:
- **File has content** → load it silently; note what is currently being built.
- **File is missing or empty** → follow the Feature Setup process in `kdevkit/feature-setup.md` to create it.
  Do not continue to Step 3 until the file exists with real content.

---

## Step 3 — Git practices

Apply the git conventions from `kdevkit/git-practices.md` (loaded above) for the full duration of this session.

---

## Step 4 — Session behaviour (always active)

Apply these rules throughout the entire session without needing to be reminded:

**Keep the feature file current.** After each meaningful unit of work — a decision made, a subtask completed, an open question resolved — update the feature file to reflect the current state. Do not batch updates to the end of the session.

**Phase gating.** Never chain phases automatically. After completing any phase (requirements, design, implementation, tests, or any other), stop and wait for explicit instruction before starting the next. The order of phases is flexible — the gate applies between any two phases regardless of sequence.

**Assumptions within a phase.** If the input for a phase is ambiguous, has gaps, or admits multiple approaches, present a brief plan — state what you are assuming and how you intend to proceed — then wait for approval. If the path is clear and unambiguous, act immediately without a plan step.

**Efficient file loading.** Use the project context, feature context, and your own memory to understand the task. Avoid reading files if the context you have is sufficient. Load companion files only when they are needed for the current task.

**YOLO mode.** When the user says "yolo", enable YOLO mode for the rest of the session:
- Drop the phase gate: chain phases automatically without stopping between them
- Drop the plan step: act on assumptions without presenting them first

When the user says "yolo off", return to normal gated behaviour immediately.

**Feature completion.** When the user indicates that the feature is done, finished, or complete:
1. Prompt: *"Before we close out — shall I update `.kdevkit/project.md` with what changed? This keeps future sessions oriented."*
2. If yes: summarise what was built, key decisions made, and any new constraints or patterns introduced, then update `.kdevkit/project.md` accordingly.
3. If no: acknowledge and move on.

## Step 5 — Confirm

Reply with a compact summary:

```
Project:  <one sentence from .kdevkit/project.md>
Feature:  <one sentence from the feature file> [<path to feature file>]
Practices: git loaded
Mode:     normal  (or: YOLO if yolo is active)
```

Then stop and wait for the first instruction.

---

*Managed by [kdevkit](https://github.com/kusimari/kdevkit). Context in `.kdevkit/`.*
