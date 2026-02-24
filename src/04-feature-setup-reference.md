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