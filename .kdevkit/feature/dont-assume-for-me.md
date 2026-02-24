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

## Feature Brief

Agents should not automatically chain development phases (requirements → design → implementation → tests) without being asked. Within a phase, inferring from context is fine; crossing a phase boundary requires explicit user instruction. When assumptions are needed within a phase, the agent shows a brief plan and waits. If the path is clear, it acts immediately. Users can enable YOLO mode to remove both the phase gate and the plan step.

## Requirements Specification

### Functional Requirements

- After completing any phase, the agent must stop and wait for explicit instruction before starting the next phase — regardless of phase order
- Within a phase, if the input is ambiguous or gaps exist, the agent presents a brief plan (what it is assuming, how it will proceed) and waits for approval before acting
- Within a phase, if the path is clear and unambiguous, the agent acts immediately without a plan step
- Users can enable YOLO mode by saying "yolo" — this removes both the phase gate and the plan step for the rest of the session
- Users can disable YOLO mode by saying "yolo off" — this restores normal gated behaviour
- The current mode (normal / YOLO) is shown in the Step 5 confirmation summary at the start of each session (defaults to normal)
- The usage instruction (Step 0 / header) briefly explains how to activate YOLO mode

### Non-Functional Requirements

- No new npm dependencies
- No new source files if the change fits naturally in existing ones
- Changes must not break any existing test assertions

### User Stories

- As a developer, I want the agent to stop after finishing design and wait for me to say "implement it" — so I stay in control of when work advances
- As a developer running in YOLO mode, I want the agent to chain phases automatically so I can move fast without repeated prompts
- As a developer, I want to see the agent's assumptions stated as a plan before it acts on them — so I can correct them early

### Success Criteria

- `src/06-session-behaviour.md` contains phase gating rule and YOLO mode toggle language
- `src/01-header.md` contains a usage note about YOLO mode
- `src/07-confirm.md` confirmation block includes a `Mode:` line
- `npm run build && npm test` passes with 0 failures
- Test assertions cover the new phase gating and YOLO language

### Constraints

- Work on branch `claude/dont-assume-for-me-feature-KOELh`
- `src/04-feature-setup-reference.md` is not changed — the gating rule lives at session level, not inside the interview reference
- `build/` stays gitignored; CI publishes build files

## Technical Design Specification

### Architecture Overview

Three existing source files are updated; no new files or manifest entries. The build pipeline concatenates them unchanged.

### Technical Decisions

- **Phase gating in `src/06-session-behaviour.md`**: this file governs agent behaviour for the whole session — it is the right place for a session-level constraint
- **YOLO mode usage note in `src/01-header.md`**: the header is what a user reads first; a one-liner there makes discoverability immediate
- **Mode line in `src/07-confirm.md`**: showing the current mode at session start sets expectations and reminds users the toggle exists
- **No changes to `src/04-feature-setup-reference.md`**: the interview reference defines *what* to do in a phase; the gating rule defines *when* to advance — keeping them separate avoids duplication

### Data Model

No data model changes.

### API / Interface Design

User-facing toggles:
- `yolo` — enables YOLO mode for the session
- `yolo off` — returns to normal gated mode

### Security Model

No changes.

### Dependencies

- `src/06-session-behaviour.md` (modified)
- `src/01-header.md` (modified)
- `src/07-confirm.md` (modified)
- `tests/dev-mode/prompt.sh` (assertions added)

## Test Strategy Specification

### Test Plan Overview

Extend `tests/dev-mode/prompt.sh` with assertions that verify the new phase gating, assumption plan, and YOLO mode language is present in `build/dev.md`.

### Test Cases

| Test | File | Assertion text |
|------|------|---------------|
| Phase gating language | build/dev.md | "phase" or "Phase" |
| YOLO mode toggle | build/dev.md | "yolo" or "YOLO" |
| Mode line in confirmation | build/dev.md | "Mode:" |

### Edge Cases & Error Handling

- YOLO mode applies for the rest of the session — if the user says "yolo" mid-session, all subsequent phases chain automatically
- "yolo off" restores the gate; any phase already in progress is not rewound

### Automation Strategy

All assertions automated in existing bash test suites.

## Implementation Plan

### Development Approach

Edit three source files, add test assertions, build and test.

### Task Breakdown

| Task | Status |
|------|--------|
| Create `.kdevkit/feature/dont-assume-for-me.md` (this file) | ✅ Complete |
| Add phase gating + YOLO mode to `src/06-session-behaviour.md` | ✅ Complete |
| Add YOLO mode usage note to `src/01-header.md` | ✅ Complete |
| Add `Mode:` line to `src/07-confirm.md` | ✅ Complete |
| Add test assertions to `tests/dev-mode/prompt.sh` | ✅ Complete |
| Run `npm run build && npm test` | ✅ Complete |
| Commit and push | ⏳ In Progress |

### Dependencies & Sequencing

All source edits are independent; do them before build+test.

### Risk Assessment

| Risk | Mitigation |
|------|-----------|
| Existing `Mode:` assertion absent, test suite already checks for it | Check existing assertions before adding duplicates |
| YOLO phrasing too vague for agents to follow reliably | Use clear imperative language; define exactly what changes in YOLO mode |

### Integration & Deployment

Push to `claude/dont-assume-for-me-feature-KOELh`. CI rebuilds on merge to `main`.

**Status legend:** 📋 Not Started | ⏳ In Progress | ✅ Complete

## Session Log
<!-- Newest entry at top -->

### 2026-02-24 — Implementation complete
- Added Phase gating + YOLO mode rules to `src/06-session-behaviour.md`
- Added YOLO mode usage note to `src/01-header.md`
- Added `Mode:` line to confirmation block in `src/07-confirm.md`
- Added `phase`, `yolo`, `Mode:` assertions to `tests/dev-mode/prompt.sh`
- `npm run build && npm test`: 6 suites, 0 failures

### 2026-02-24 — Feature file created, implementation starting
- Clarified requirements with user: phase gating (flexible order), YOLO mode toggle, session-behaviour is the right home
- Created `.kdevkit/feature/dont-assume-for-me.md`

## Decision Log

### 2026-02-24 — Phase gating lives in session-behaviour, not feature-setup
**Context**: Could put the gating rule inside the interview reference or at session level
**Decision**: Session behaviour (`src/06-session-behaviour.md`) — applies to the whole session regardless of which phase or tool is in use
**Rationale**: Feature-setup reference defines *what* to do in a phase; session behaviour defines *how* the session advances. Separation keeps each file focused.
**Alternatives**: Inline in `src/04-feature-setup-reference.md` (wrong scope — only covers feature setup, not implementation or testing work)
**Impact**: Any session using kdevkit will respect the gate; the interview reference stays clean

### 2026-02-24 — YOLO mode is a session-level toggle, not a per-phase flag
**Context**: Could allow per-phase YOLO (e.g. "yolo this phase only")
**Decision**: Session-level toggle for simplicity — "yolo" applies for the rest of the session; "yolo off" restores gating
**Rationale**: Per-phase flags add complexity with little benefit; users who want to go fast just say "yolo" once
**Alternatives**: Per-phase flag; command-line argument to `/dev` (harder to discover mid-session)
**Impact**: Simple, memorable; one toggle covers the common "go fast" scenario
