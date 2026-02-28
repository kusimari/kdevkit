# kdevkit

Reusable instruction sets for coding agents. Tell your agent to fetch an instruction file and follow it — no installation needed.

---

## Available instructions

### Project & feature work

**`kdevkit-feature-dev.md`** gives your coding agent a structured workflow for any feature:

- Loads project context from `.kdevkit/project.md` (creates it if missing)
- Loads or creates a feature file under `.kdevkit/feature/` (runs a structured interview if new)
- Applies git conventions for the session (branches, commits, PR rules)
- Confirms the plan before starting work

---

## How to use

**Starting a new feature** — tell your coding agent:

```
Fetch https://raw.githubusercontent.com/kusimari/kdevkit/main/kdevkit-feature-dev.md and follow it for feature: <feature-name>
```

**Continuing an existing feature** — if you have already worked on a feature and a file exists at `.kdevkit/feature/<feature-name>.md`, tell your agent the same thing:

```
Fetch https://raw.githubusercontent.com/kusimari/kdevkit/main/kdevkit-feature-dev.md and follow it for feature: <feature-name>
```

The agent will detect the existing feature file and pick up where you left off, rather than running the setup interview again.

---

## How feature files work

Feature files live in `.kdevkit/feature/` in your project. Each file captures:

- What is being built and why
- Requirements, design decisions, and test strategy
- An implementation plan and task breakdown
- A running log of decisions and progress

The agent updates the file as work progresses so future sessions have full context.
