# Dont Assume For Me

## How to use this file
This file contains specifications generated through structured interviews.
- **Decision record**: captures rationale for future reference
- **Agent instructions**: provides actionable guidance for implementation

Read the entire file before beginning work. Update the Session Log and Decision Log as the work progresses.

## Git Setup

- **Style**: Branch
- **Branch**: `claude/dont-assume-for-me-feature-KOELh`
- **Base**: `main`
- **Command run**: `git checkout -b claude/dont-assume-for-me-feature-KOELh main`

## Feature Brief

Agents using kdevkit sometimes skip the interview process and pre-fill feature templates with assumed content rather than asking the user. This feature adds an explicit, prominent "no assumptions" rule to `feature-setup.md` so that every agent — regardless of how confident it feels — must ask every question and wait for every answer before writing anything.

## Requirements Specification

### Functional Requirements

- `src/04-feature-setup-reference.md` must contain a clear, prominent prohibition against agents assuming answers to interview questions
- The prohibition must appear before the first interview begins (i.e., before the Git Setup block)
- The prohibition must cover: pre-filling template sections, inferring requirements from context, skipping questions the agent believes it already knows the answer to
- The prohibition must include an explicit instruction: when uncertain, ask rather than assume

### Non-Functional Requirements

- No new npm dependencies
- No new source files — the change is a text addition within an existing src file
- `build/` files remain gitignored; only CI commits them

### User Stories

- As a developer, I want the AI agent to ask me what my feature should do rather than guessing, so that the feature file reflects my actual intent rather than the agent's assumptions
- As a developer, I want the agent to ask every interview question even when it thinks it knows the answer, so that I remain in control of all decisions

### Success Criteria

- `src/04-feature-setup-reference.md` contains language explicitly prohibiting assumption (e.g. the word "assume" or "assumption")
- `tests/dev-mode/references.sh` asserts the prohibition is present in the feature-setup source
- `npm run build && npm test` passes with 0 failures

### Constraints

- Work on branch `claude/dont-assume-for-me-feature-KOELh`
- Zero new npm dependencies
- `build/` stays gitignored; CI publishes build files

## Technical Design Specification

### Architecture Overview

Pure text addition to `src/04-feature-setup-reference.md`. The build pipeline concatenates this file into `build/feature-setup.md` unchanged; no pipeline changes required.

### Technical Decisions

- Placement: a new "**No assumptions**" paragraph immediately after the `### Feature Setup` heading and before `#### File Location`, so it is the first thing an agent reads when the feature-setup companion is loaded
- Phrasing: imperative, unambiguous — "Never assume", "Ask every question", "Wait for every answer"
- No new source files or manifest entries needed

### Data Model

No data model changes.

### API / Interface Design

No interface changes. The published companion file `build/feature-setup.md` gains a new paragraph.

### Security Model

No changes.

### Dependencies

- `src/04-feature-setup-reference.md` (modified)
- `tests/dev-mode/references.sh` (test assertion added)
- Build pipeline (`build.js`) — unchanged

## Test Strategy Specification

### Test Plan Overview

Extend the existing `tests/dev-mode/references.sh` bash test suite with one new assertion that verifies the anti-assumption language is present in `src/04-feature-setup-reference.md`.

### Test Cases

| Test | Assertion |
|------|-----------|
| Anti-assumption language present | `assert_file_contains "$FS" "assume"` or equivalent phrase |

### Edge Cases & Error Handling

- If the word "assume" appears only in an unrelated context, the test would be a false positive — phrase the assertion to target the specific prohibition text

### Performance Criteria

No performance requirements.

### Automation Strategy

All automated in the existing bash test suite. No manual testing needed.

## Implementation Plan

### Development Approach

Single-file text addition followed by a test update. Run build+test after to confirm.

### Task Breakdown

| Task | Status |
|------|--------|
| Add "No assumptions" paragraph to `src/04-feature-setup-reference.md` | ✅ Complete |
| Add assertion to `tests/dev-mode/references.sh` | ✅ Complete |
| Run `npm run build && npm test` | ✅ Complete |
| Create `.kdevkit/feature/dont-assume-for-me.md` (this file) | ✅ Complete |
| Commit and push | ⏳ In Progress |

### Dependencies & Sequencing

1. Create feature file (this file) — first, to record intent
2. Edit `src/04-feature-setup-reference.md` — core change
3. Edit `tests/dev-mode/references.sh` — test coverage
4. Build and test — verify
5. Commit and push

### Risk Assessment

| Risk | Mitigation |
|------|-----------|
| New language breaks existing test assertions | Run full test suite; existing assertions are additive |
| Phrasing is too weak and agents ignore it | Use imperative "Never", "must", "do not" — same register as the existing rules |

### Integration & Deployment

Push to `claude/dont-assume-for-me-feature-KOELh`. When merged to `main`, CI rebuilds and deploys updated `build/feature-setup.md` to GitHub Pages.

**Status legend:** 📋 Not Started | ⏳ In Progress | ✅ Complete

## Session Log
<!-- Newest entry at top -->

### 2026-02-24 — Implementation complete
- Added "No assumptions" paragraph to `src/04-feature-setup-reference.md` as the first text under `### Feature Setup`
- Added assertion to `tests/dev-mode/references.sh` verifying the word "assume" is present in the feature-setup source
- `npm run build && npm test` passes: 6 suites, 0 failures (110 assertions total)
- All changes on branch `claude/dont-assume-for-me-feature-KOELh`

### 2026-02-24 — Feature file created, implementation starting
- Created `.kdevkit/feature/dont-assume-for-me.md` with full specification
- On branch `claude/dont-assume-for-me-feature-KOELh`

## Decision Log

### 2026-02-24 — Placement of no-assumptions rule
**Context**: Needed to decide where in `src/04-feature-setup-reference.md` to insert the prohibition so it is most effective
**Decision**: Place it immediately after the `### Feature Setup` heading, before `#### File Location` — the very first thing an agent reads
**Rationale**: Agents load `feature-setup.md` specifically for this section; placing the prohibition first means it is seen before any procedural steps, maximising the chance it is followed
**Alternatives**: Inside "Conducting the Interviews" bullet list (less prominent, buried after procedural detail); inline warning before each interview (repetitive, noisy)
**Impact**: All agents using kdevkit's feature-setup companion file will encounter the prohibition before reading any procedural instructions

### 2026-02-24 — No new source files
**Context**: Could add a new `src/` file dedicated to the no-assumptions rule, or embed it in the existing `04-feature-setup-reference.md`
**Decision**: Embed in existing file — no new src file or manifest entry
**Rationale**: The rule is part of the feature-setup process, not a standalone concept; embedding it keeps the companion file self-contained and avoids manifest churn
**Alternatives**: New `src/04a-no-assumptions.md` inserted before `04-feature-setup-reference.md` in the manifest (unnecessary complexity for a single paragraph)
**Impact**: `build.js` MANIFEST unchanged; one fewer moving part
