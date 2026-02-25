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