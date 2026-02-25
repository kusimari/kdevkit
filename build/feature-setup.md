### Feature Setup

When a feature file needs to be created, conduct a structured interview process to establish a clear understanding of the feature's requirements, design, testing strategy, and implementation plan.

#### File Location

Feature files reside in `.kdevkit/feature/` and are named after the feature (e.g., `user-auth` → `.kdevkit/feature/user-auth.md`). Names should be lowercase and hyphenated.

#### Git Setup

Before interviews, determine the user's preferred git setup (branch or worktree) and the base commit. If the current branch already matches the feature name, skip branch/worktree creation. Propose the `git checkout -b <feature-name> <commit-ish>` or `git worktree add <feature-name> -b <feature-name> <commit-ish>` command for user confirmation.

#### Interview Process

Use existing project context to inform the interview process and avoid starting from scratch. Run four interviews to define the feature:
1.  **Requirements:** Understand the problem, user interaction, and success criteria.
2.  **Design:** Define the technical approach, architecture, and component interactions.
3.  **Testing:** Define the validation strategy, including test types and key scenarios.
4.  **Implementation:** Plan the development approach, task breakdown, and risk mitigation.

#### Output Format

After completing interviews, create the feature file at `.kdevkit/feature/<feature-name>.md` following a specified template (which includes sections for Git Setup, Feature Brief, Requirements, Design, Test Strategy, Implementation Plan, Session Log, and Decision Log). This template serves as a decision record and agent instructions.
