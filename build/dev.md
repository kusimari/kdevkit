<!-- kdevkit:built:2026-02-23T23:56:55.857Z -->
## Step 0 — Self-update check

Before doing anything else, check whether kdevkit is up to date. This step is silent unless an update is found.

1. **Find the build timestamp** — look for `<!-- kdevkit:built:{TIMESTAMP} -->` at the top of this file.
   If not found, skip this step entirely and continue to Step 1.

2. **Find the install source** — look for `<!-- kdevkit:source:{SOURCE} -->` in this file.
   Supported values:
   - `github-pages` — fetch `https://kusimari.github.io/kdevkit/dev.md`
   - `raw` — fetch `https://raw.githubusercontent.com/kusimari/kdevkit/main/build/dev.md`
   - `local` — read `build/dev.md` relative to the project root (skip if the file is missing)

   If the source comment is not found, skip this step.

3. **Fetch the remote version** from the URL or path determined above.
   If the fetch fails for any reason (network error, file missing), skip this step silently.

4. **Compare timestamps** — extract `<!-- kdevkit:built:{REMOTE_TIMESTAMP} -->` from the remote content.
   If the timestamps are identical, skip this step. No message needed.

5. **Prompt the user** if the remote timestamp is newer:
   *"kdevkit update available — remote: {REMOTE_TIMESTAMP}, installed: {LOCAL_TIMESTAMP}. Update now?"*

6. **If yes — apply the update:**
   a. Take the remote content. Re-insert the original `<!-- kdevkit:source:{SOURCE} -->` comment on the
      line immediately after the new `<!-- kdevkit:built:... -->` line (the remote content will not have it).
   b. Overwrite the installed file with the updated content.
      - Claude Code: `.claude/commands/dev.md` (or `~/.claude/commands/dev.md` if globally installed)
      - Kiro: `.kiro/steering/dev.md`
      - Gemini: replace only the kdevkit dev section (bounded by its `##` heading) in `GEMINI.md` (or `~/.gemini/GEMINI.md`)
   c. Diff the old and new content to identify which steps changed.
   d. If Step 1 (project context guidance) changed: note *"Project context step updated — consider reviewing `.kdevkit/project.md`."*
   e. If Steps 2–4 (feature context or setup guidance) changed: note *"Feature guidance updated — consider reviewing the current feature file."*
   f. Confirm: *"kdevkit updated to {REMOTE_TIMESTAMP}."*

7. **Continue to Step 1** regardless of whether an update was applied or skipped.

------

# /dev — Enter Dev Mode

Usage: `/dev [path/to/feature.md]`

Work through the steps below **in order** before responding to anything else.

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
- **File is missing or empty** → conduct the Feature Setup process below to create it.
  Do not continue to Step 3 until the file exists with real content.

### Feature Setup

When a feature file needs to be created, conduct the structured interview process below before writing anything.
Ask each interview's questions **one at a time** and wait for the answer before continuing.
Do not ask all questions at once, and do not skip interviews.

#### File Location

Feature files live in `.kdevkit/feature/` and are named after the feature:
- Feature name `user-auth` → `.kdevkit/feature/user-auth.md`
- Feature name `export-to-csv` → `.kdevkit/feature/export-to-csv.md`
- Default (no name given) → `.kdevkit/feature/feature.md`

Lowercase, hyphenated, `.md` extension.

#### Git Setup

Before starting the interviews, ask the user about their git setup. Do this once, in order.

**Step 1 — Working style**

Ask: *"Do you want to work on a branch or a worktree?"*

- **Branch** — a feature branch checked out in the current repository.
- **Worktree** — a separate directory so you can work in parallel without switching branches.

**Step 2 — Base commit**

Ask: *"What should the branch start from?"* (e.g. `main`, `develop`, a commit hash, a tag).
If the user is unsure, suggest `main`.

**Step 3 — Show the command and confirm**

Derive the commands from the feature name and commit-ish, then **show the exact command** to the user before running anything:

- Branch:
  ```
  git checkout -b <feature-name> <commit-ish>
  ```
- Worktree (directory named after the feature, branch named the same):
  ```
  git worktree add <feature-name> -b <feature-name> <commit-ish>
  ```

Ask: *"Shall I run this now?"* Wait for explicit confirmation before executing.

If the branch already exists, tell the user and skip creation — just check it out (branch) or verify the worktree is already added (worktree).

**Step 4 — Record in the feature file**

After the git setup is confirmed or skipped, note the choice in the feature file under `## Git Setup` (see template below).

#### Interview Process

Run all four interviews in order. Each one produces a section of the feature file.

##### 1. Requirements Interview

**Purpose**: Understand what the feature should do, for whom, and how success is measured.

Questions to ask (one at a time):
1. *"What problem does this feature solve? Who experiences this problem?"*
2. *"Walk me through how users will interact with this feature."*
3. *"What specific actions or behaviours must the feature support?"*
4. *"Are there performance, security, usability, or compatibility requirements?"*
5. *"How will we know this feature is working correctly and providing value?"*
6. *"What technical, business, or timeline constraints must we work within?"*
7. *"What is essential vs nice-to-have? What can be deferred?"*

Push back on vague answers. "It works" is not an acceptance criterion — ask for a specific behaviour, output, or test that would pass.

**Output**: Functional requirements, non-functional requirements, user stories, success criteria, constraints.

##### 2. Design Interview

**Purpose**: Define the technical approach, architecture decisions, and design rationale.

Questions to ask (one at a time):
1. *"How should this feature fit into the existing system architecture?"*
2. *"What technologies, libraries, or frameworks should we use, and why?"*
3. *"What data structures, schemas, or storage does this feature need?"*
4. *"What APIs, UIs, or integration points need to be designed?"*
5. *"What existing systems, services, or components will this interact with?"*
6. *"What other approaches did you consider? Why is this one chosen?"*
7. *"What security considerations apply to this feature?"*

**Output**: Architecture overview, technical decisions, data model, API/interface design, security model, dependencies.

##### 3. Testing Interview

**Purpose**: Define how the feature will be validated and verified.

Questions to ask (one at a time):
1. *"What types of testing are needed — unit, integration, e2e, performance, security?"*
2. *"What specific scenarios should we test, based on the requirements?"*
3. *"What error conditions or boundary cases should we handle?"*
4. *"What should be automated vs tested manually?"*
5. *"Are there performance benchmarks or load requirements?"*
6. *"How will we validate that requirements are met?"*

**Output**: Test plan, specific test cases linked to requirements, edge cases, performance criteria, automation strategy.

##### 4. Implementation Interview

**Purpose**: Plan the development approach, identify risks, and sequence work.

Questions to ask (one at a time):
1. *"What's the overall development strategy — incremental, MVP-first, something else?"*
2. *"How should this feature be divided into development tasks?"*
3. *"What needs to be finished before other work can start?"*
4. *"What technical or project risks should we plan for? How do we mitigate them?"*
5. *"How will this be integrated and deployed with existing systems?"*
6. *"What logging, metrics, or monitoring should be implemented?"*
7. *"What documentation needs to be created or updated?"*

**Output**: Development approach, task breakdown with dependencies, risk assessment, integration and deployment plan.

#### Conducting the Interviews

- Be conversational — ask follow-up questions based on responses
- Probe for details — do not accept vague answers
- Challenge assumptions — help the user think through edge cases and alternatives
- Capture rationale — record not just what was decided, but why
- Summarise after each interview — repeat back what you heard and confirm before continuing

#### Output Format

After completing all four interviews, create the feature file at `.kdevkit/feature/<feature-name>.md`:

```markdown
# <Feature Name>

## How to use this file
This file contains specifications generated through structured interviews.
- **Decision record**: captures rationale for future reference
- **Agent instructions**: provides actionable guidance for implementation

Read the entire file before beginning work. Update the Session Log and Decision Log as the work progresses.

## Git Setup
<!-- Branch or worktree, base commit-ish, and the command that was run -->

## Feature Brief
<!-- 2–3 sentence executive summary -->

## Requirements Specification

### Functional Requirements
<!-- What the system must do -->

### Non-Functional Requirements
<!-- Performance, security, usability, compatibility -->

### User Stories
<!-- As a [user type], I want [goal] so that [benefit] -->

### Success Criteria
<!-- Measurable, testable outcomes that indicate success -->

### Constraints
<!-- Technical, business, or timeline limitations -->

## Technical Design Specification

### Architecture Overview
<!-- How this feature fits into the existing system -->

### Technical Decisions
<!-- Technologies chosen and why -->

### Data Model
<!-- Data structures, schemas, storage -->

### API / Interface Design
<!-- Endpoints, UIs, integration points -->

### Security Model
<!-- Security considerations and requirements -->

### Dependencies
<!-- Systems, services, components this interacts with -->

## Test Strategy Specification

### Test Plan Overview
<!-- Types of testing and overall strategy -->

### Test Cases
<!-- Specific scenarios linked to requirements -->

### Edge Cases & Error Handling
<!-- Boundary conditions and error scenarios -->

### Performance Criteria
<!-- Benchmarks and load requirements -->

### Automation Strategy
<!-- What will be automated vs manual -->

## Implementation Plan

### Development Approach
<!-- Overall strategy and methodology -->

### Task Breakdown
<!-- Development tasks and descriptions -->

### Dependencies & Sequencing
<!-- Task dependencies and recommended order -->

### Risk Assessment
<!-- Identified risks and mitigation strategies -->

### Integration & Deployment
<!-- How the feature will be released -->

**Status legend:** 📋 Not Started | ⏳ In Progress | ✅ Complete

## Session Log
<!-- Newest entry at top -->

### <date> — Session focus
- Achievement
- Current status

## Decision Log

### <date> — <Decision title>
**Context**: What led to this decision
**Decision**: What was decided
**Rationale**: Why
**Alternatives**: Other options considered
**Impact**: Expected effects
```

Tell the user where the file was created, then continue to Step 3.

#### Keeping the File Current

Throughout the session:
- Update **Implementation Plan** task statuses as work progresses
- Add entries to **Session Log** after each meaningful unit of work
- Record decisions in **Decision Log** — especially choices not covered in the specification
- Regularly validate implementation against the **Success Criteria**

When the feature is complete, prompt the project context update as described in Step 4 below.

---

## Step 3 — Git practices

Apply these git conventions for the full duration of this session:

### Branches

Pattern: `<type>/<short-description>`

Types: `feat` · `fix` · `chore` · `docs` · `refactor` · `test`

Examples:
- `feat/user-auth`
- `fix/null-pointer-on-login`
- `chore/update-deps`

### Commits

Format: Conventional Commits — `type(scope): subject`

Rules:
- Imperative mood, lowercase, no trailing period
- Subject line ≤ 72 characters
- Each commit must leave the repo in a working state — no broken builds mid-branch
- If a commit needs a body, the body explains *why*, not *what* (the diff shows what)

Examples:
- `feat(auth): add JWT refresh token rotation`
- `fix(api): handle empty response from upstream`
- `chore: bump Node to 22`

### Scope

- Commits and config changes stay **local to this project** — never modify global git config
- Do not write to `~/.gitconfig`, `~/.ssh/`, or any path outside the project root
- If a git hook or script tries to write outside the project, flag it before running

### Pull Requests

- PR title follows the same `type(scope): subject` format
- PR body: explain *why* the change is needed and what approach was chosen
- Keep PRs small; one concern per PR
- Squash merge; the squash commit message must match the PR title format

### Commit discipline

- **Commits are save points** — commit whenever a coherent unit of work is done; do not wait until the whole feature is complete
- Every commit must leave the repo in a working state (tests pass, build succeeds)
- Push to the feature branch freely; pushing is not the same as opening a PR

### PR gate

A PR is ready when, and only when, **`npm run build` passes locally** (or the project's equivalent build-and-test command). Do not open a PR if the build is broken or tests are red.

- Run the full build+test suite immediately before opening a PR
- If CI is configured, it runs only on protected branches (e.g. `main`) — feature branches are the developer's responsibility
- CI triggers only on changes to source and build files, not test-only changes

### Hygiene

- Do not commit commented-out code, debug prints, or temporary test files
- Do not commit secrets, credentials, or environment-specific values
- If `.gitignore` needs updating, include it in the same commit that adds the ignored file

---

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
Project:  <one sentence from .kdevkit/project.md>
Feature:  <one sentence from the feature file> [<path to feature file>]
Practices: git loaded
```

Then stop and wait for the first instruction.

---

*Managed by [kdevkit](https://github.com/kusimari/kdevkit). Context in `.kdevkit/`.*
