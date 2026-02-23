# Rename kdevkit

## How to use this file
This file contains specifications generated through structured interviews.
- **Decision record**: captures rationale for future reference
- **Agent instructions**: provides actionable guidance for implementation

Read the entire file before beginning work. Update the Session Log and Decision Log as the work progresses.

## Git Setup

- **Style**: Branch
- **Branch**: `claude/rename-kdevkit-repo-jjEzC`
- **Base**: `master`
- **Command run**: `git checkout -b claude/rename-kdevkit-repo-jjEzC`

## Feature Brief

Rename the GitHub repository from `k-mcp-devkit` to `kdevkit` and propagate the change everywhere: package name, URLs, installer output, tests, and documentation. As part of the rename, restructure context storage from the `context/` directory to `.kdevkit/` (project file at root, feature files under `feature/`), add a GitHub Pages landing page (`index.html`), and document the no-install fetch-based invocation for Claude Code Web and claude.ai.

## Requirements Specification

### Functional Requirements

- All occurrences of `k-mcp-devkit` in source, tests, and config replaced with `kdevkit`
- GitHub Pages URL updated from `kusimari.github.io/k-mcp-devkit` to `kusimari.github.io/kdevkit`
- `package.json` name and bin key updated; repository URL updated
- Gemini section heading changed from `## k-mcp-devkit: dev` to `## kdevkit: dev`
- Context files relocated: `context/project.md` → `.kdevkit/project.md`, `context/feature.md` → `.kdevkit/feature/feature.md`, `feature/setting-up.md` → `.kdevkit/feature/setting-up.md`
- `src/02`, `src/03`, `src/04`, `src/07` updated to reference `.kdevkit/` paths
- `index.html` landing page created, built into `build/`, published to GitHub Pages
- GitHub Actions workflow updated: `index.html` added to publish step and path triggers
- README documents fetch-based invocation for Claude Code Web and claude.ai Projects

### Non-Functional Requirements

- All existing tests must pass after renaming
- Zero new npm dependencies introduced
- `build/` remains gitignored

### Success Criteria

- `npm run build && npm test` passes with 0 failures across all 6 suites
- `build/index.html` produced by `npm run build`
- No remaining `k-mcp-devkit` references in source, tests, or docs (excluding git history)
- `.kdevkit/project.md` and `.kdevkit/feature/` exist and are committed

### Constraints

- Work on branch `claude/rename-kdevkit-repo-jjEzC`
- Cannot break existing agent install flows (claude-code, gemini, kiro)
- install.js and build.js must remain zero-dependency

## Technical Design Specification

### Architecture Overview

Pure rename and file-move operation on an existing single-package Node.js/Bash project. No new modules or runtime changes. Build pipeline extended with one `fs.copyFileSync` call. GitHub Actions workflow extended with one `cp` line.

### Technical Decisions

- `.kdevkit/` chosen as the context directory name (mirrors the package name, hidden directory keeps it tidy)
- `project.md` at `.kdevkit/` root (no subdirectory) — it is singular and global to the project
- Feature files under `.kdevkit/feature/` — namespaced to allow multiple features without collision
- `index.html` created at repo root, copied to `build/` by `build.js` (consistent with how `dev.md` is built), then deployed from `build/` in CI — single source of truth

### Data Model

No data model changes. File layout change only:

| Old path | New path |
|----------|----------|
| `context/project.md` | `.kdevkit/project.md` |
| `context/feature.md` | `.kdevkit/feature/feature.md` |
| `feature/setting-up.md` | `.kdevkit/feature/setting-up.md` |
| *(new)* | `index.html` |
| *(new)* | `build/index.html` (generated) |

### API / Interface Design

No API changes. New public surface: `https://kusimari.github.io/kdevkit/index.html` (landing page).

No-install invocation pattern documented in README:
```
Fetch https://kusimari.github.io/kdevkit/dev.md and follow those instructions for feature: [name]
```

### Security Model

No changes. Static files only, no server-side logic.

### Dependencies

- GitHub Actions `actions/checkout@v4`, `actions/setup-node@v4`, `actions/configure-pages@v4`, `actions/upload-pages-artifact@v3`, `actions/deploy-pages@v4` — unchanged

## Test Strategy Specification

### Test Plan Overview

Existing bash test suites cover all install and dev-mode behaviours. Update assertions to match new paths and section headings. No new test infrastructure needed.

### Test Cases

| Test file | What changed |
|-----------|-------------|
| `tests/dev-mode/prompt.sh` | Assertions updated: `context/project.md` → `.kdevkit/project.md`, `context/<argument>.md` → `.kdevkit/feature/<argument>.md` |
| `tests/dev-mode/references.sh` | File existence checks updated; GitHub Pages URL updated; build output path assertions updated |
| `tests/install/gemini.sh` | Section heading assertion: `k-mcp-devkit: dev` → `kdevkit: dev` |
| `tests/agent/dev-command.sh` | Directory setup and path assertions updated to `.kdevkit/` |

### Edge Cases & Error Handling

- `context/` and `feature/` directories left empty after `git mv` — removed with `rmdir` to keep tree clean
- Gemini idempotency: heading change means old installs will get a second section on re-install (acceptable; users upgrading should re-install)

### Automation Strategy

All assertions automated in existing bash test suites. CI runs full suite on push to `main`.

## Implementation Plan

### Development Approach

Incremental rename: core files first, then source markdown, then file moves, then tests, then build pipeline additions. Build and test after each group.

### Task Breakdown

| Task | Status |
|------|--------|
| Rename `k-mcp-devkit` → `kdevkit` in `package.json`, `install.js`, `README.md` | ✅ Complete |
| Update `src/02`, `src/03`, `src/07` to use `.kdevkit/` paths | ✅ Complete |
| Fix `src/04` `context/` → `.kdevkit/feature/` paths (missed in initial pass) | ✅ Complete |
| `git mv context/ feature/` files to `.kdevkit/` structure | ✅ Complete |
| Update test files for new paths and renamed section heading | ✅ Complete |
| Create `index.html` landing page | ✅ Complete |
| Update `build.js` to copy `index.html` to `build/` | ✅ Complete |
| Update `pages.yml` to publish `index.html` and add path trigger | ✅ Complete |
| Add Claude Code Web / claude.ai no-install usage to README | ✅ Complete |
| Create `.kdevkit/feature/rename-kdevkit.md` (this file) | ✅ Complete |

### Dependencies & Sequencing

All tasks were independent except: `src/04` fix must precede build verification; file moves must precede test updates.

### Risk Assessment

| Risk | Mitigation |
|------|-----------|
| Missed `k-mcp-devkit` reference | Full test suite catches stale URL and heading assertions |
| Broken file paths in tests after move | Run `npm test` immediately after each change group |
| `index.html` not deploying | `pages.yml` publish step explicitly copies from `build/` |

### Integration & Deployment

Push to `claude/rename-kdevkit-repo-jjEzC`. When merged to `main`, CI deploys updated Pages with `index.html`, new URL (`kusimari.github.io/kdevkit`), and updated `dev.md`.

**Status legend:** 📋 Not Started | ⏳ In Progress | ✅ Complete

## Session Log

### 2026-02-23 — Full rename and restructure

- Renamed all `k-mcp-devkit` references to `kdevkit` across `package.json`, `install.js`, `README.md`, `src/`, and tests
- Moved context files: `context/` → `.kdevkit/`, `feature/` → `.kdevkit/feature/`
- Updated all `src/` instructions to reference `.kdevkit/` paths (02, 03, 04, 07)
- Added `index.html` landing page; updated `build.js` and `pages.yml` to include it in the build and Pages publish
- Added Claude Code Web / claude.ai no-install fetch-based usage to README
- All 6 test suites pass (0 failures)

## Decision Log

### 2026-02-23 — Use .kdevkit/ as context directory
**Context**: Needed a new home for project and feature context files to align with the new package name and avoid `context/` being too generic
**Decision**: `.kdevkit/` at project root; project file directly inside, feature files under `feature/` subdirectory
**Rationale**: Mirrors the package name; hidden directory keeps the project tree clean; subdirectory separation prevents future naming collisions between project.md and feature files
**Alternatives**: `context/` (old, too generic); `.dev/` (too ambiguous)
**Impact**: All agents instructed to read/write `.kdevkit/project.md` and `.kdevkit/feature/<name>.md`; existing users must re-install or manually move files

### 2026-02-23 — No-install fetch invocation for Claude Code Web
**Context**: Users on claude.ai or Claude Code without a local install need a way to use the devkit without running the installer
**Decision**: Document `Fetch https://kusimari.github.io/kdevkit/dev.md and follow those instructions for feature: [name]` as the one-off invocation pattern
**Rationale**: Claude Code has WebFetch tool access; the devkit instructions are self-contained and work when fetched dynamically just as well as when installed; no additional infrastructure needed
**Alternatives**: Session-start hook (complex, non-standard); requiring install (poor UX for web users)
**Impact**: Any Claude Code session (web or CLI) can use the devkit without prior setup
