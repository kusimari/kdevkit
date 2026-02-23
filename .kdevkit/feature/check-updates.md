# Check Updates

## How to use this file
This file contains specifications generated through structured interviews.
- **Decision record**: captures rationale for future reference
- **Agent instructions**: provides actionable guidance for implementation

Read the entire file before beginning work. Update the Session Log and Decision Log as the work progresses.

## Git Setup
Branch: `claude/add-self-update-check-rQ6Kz` from current HEAD on `claude/add-self-update-check-rQ6Kz`

## Feature Brief
Add a self-update mechanism to kdevkit so that agents can detect when a newer version of the `/dev` command is available and offer to update the installed file. The check compares a build timestamp embedded in the installed file against the remote source, then prompts the user if a newer version exists.

## Requirements Specification

### Functional Requirements
- `build.js` embeds an ISO 8601 timestamp comment (`<!-- kdevkit:built:{TS} -->`) at the top of `build/dev.md` at build time
- `install.js` injects a source comment (`<!-- kdevkit:source:{SOURCE} -->`) into the installed file so the agent knows where to fetch updates
- The installed `dev.md` contains a Step 0 that the agent executes on every `/dev` invocation:
  - Reads the embedded timestamp and source from the current file
  - Fetches the remote version from the appropriate source (github-pages, local, or raw)
  - Compares timestamps; if remote is newer, prompts the user
  - On confirmation, overwrites the installed file with the remote content (preserving source metadata)
  - Notes if project context or feature guidance changed, and offers to review `.kdevkit/` files
- GitHub Actions workflow publishes for every push to `main` except test-only changes (use `paths-ignore` instead of `paths`)

### Non-Functional Requirements
- Zero new npm dependencies — Node.js built-ins only
- Timestamp is injected at build time, not at install time, so it reflects the actual content version
- The self-update check is a best-effort step: if the remote is unreachable or source is `local`, the check is silently skipped
- The agent must not auto-update without explicit user confirmation

### User Stories
- As a developer, I want the `/dev` command to tell me when kdevkit has a newer version, so I don't work with stale agent instructions
- As a developer, I want to choose whether to update, so I remain in control of my tooling
- As a developer, I want the workflow to publish whenever anything meaningful changes (not just tracked source files), so the published artifact is always current

### Success Criteria
- Running `npm run build` produces `build/dev.md` with `<!-- kdevkit:built:{ISO_TIMESTAMP} -->` as the first line
- Installing via `node install.js claude-code` results in a file containing `<!-- kdevkit:source:github-pages -->`
- Installing via `node install.js claude-code --local` results in a file containing `<!-- kdevkit:source:local -->`
- The installed file's Step 0 instructions correctly describe the three-source fetch strategy
- The GitHub Actions workflow triggers on any push to `main` that doesn't touch only `tests/**`
- `npm run build && npm test` passes

### Constraints
- No new files added to the npm package (`files` in package.json stays as-is)
- `build/` remains gitignored
- Must not break Gemini or Kiro install paths

## Technical Design Specification

### Architecture Overview
Three-layer change:
1. **Build time** (`build.js`): stamp the artifact with a timestamp
2. **Install time** (`install.js`): stamp the installed file with the fetch source and inject the Step 0 metadata
3. **Runtime** (`src/00-selfupdate.md`): agent instructions that interpret the metadata and perform the check

### Technical Decisions
- HTML comments (`<!-- kdevkit:... -->`) chosen for metadata: invisible in rendered markdown, easy to parse with regex, don't break agent instruction parsing
- ISO 8601 string for timestamp: human-readable, lexicographically sortable, unambiguous
- `paths-ignore` over `paths` in GitHub Actions: simpler, future-proof — new source files automatically trigger publish without needing to update the workflow

### Data Model
Metadata comments injected into installed `dev.md`:
```
<!-- kdevkit:built:2026-02-23T12:00:00.000Z -->   (from build.js)
<!-- kdevkit:source:github-pages -->               (from install.js)
```

### API / Interface Design
No external APIs. The agent reads the comments with simple pattern matching and calls:
- `fetch` / HTTP GET for `github-pages` and `raw` sources
- File read for `local` source

### Security Model
- No credentials involved; all fetches are public HTTP GET
- The agent writes only to the specific installed path — no escalated permissions

### Dependencies
- `build.js` → `fs`, `path` (already used)
- `install.js` → `fs`, `path`, `os`, `https` (already used)
- New `src/00-selfupdate.md` → concatenated into `build/dev.md` by `build.js` (no new dependency)

## Test Strategy Specification

### Test Plan Overview
- Existing build and install tests should continue to pass
- Manual verification: run `npm run build`, inspect first line of `build/dev.md`
- Manual verification: run `node install.js claude-code --local`, inspect installed file for metadata comments

### Test Cases
- `npm run build` → `build/dev.md` line 1 matches `<!-- kdevkit:built:\d{4}-\d{2}-\d{2}T`
- `node install.js claude-code --local` → installed file contains `<!-- kdevkit:source:local -->`
- `node install.js claude-code` (pages) → installed file contains `<!-- kdevkit:source:github-pages -->`
- Workflow file: no `paths:` allowlist key present; `paths-ignore: [tests/**]` present

### Edge Cases & Error Handling
- Remote fetch fails during Step 0: silently skip update check, continue to Step 1
- `local` source with missing `build/dev.md`: silently skip update check
- Timestamps identical: silently skip, no prompt
- User declines update: continue normally to Step 1

### Automation Strategy
Existing test suite covers install and build correctness. No new automated tests required for the agent-instruction content (tested by reading/verifying the built output).

## Implementation Plan

### Development Approach
Incremental — each layer (build, install, src, workflow) is independently committable.

### Task Breakdown
1. `build.js` — prepend timestamp comment ⏳
2. `install.js` — inject source metadata after the timestamp line ⏳
3. `src/00-selfupdate.md` — Step 0 agent instructions ⏳
4. `.github/workflows/pages.yml` — switch to `paths-ignore: [tests/**]` ⏳

### Dependencies & Sequencing
- Tasks 1, 3, 4 are independent
- Task 2 depends on Task 1 (install.js must place source comment after the timestamp line)

### Risk Assessment
- **Timestamp line assumption**: if `build.js` is run in an environment with a wrong clock, timestamp will be stale. Mitigation: use `new Date().toISOString()` which reads system clock — acceptable risk.
- **Agent parsing**: agent uses pattern matching on comments; malformed comments will cause the check to be silently skipped. Mitigation: instructions say "if not found, skip this step".

### Integration & Deployment
PR → merge to `main` → CI runs build+test → publishes updated `dev.md` to GitHub Pages → future installs pick up new content with timestamp.

**Status legend:** 📋 Not Started | ⏳ In Progress | ✅ Complete

## Session Log
<!-- Newest entry at top -->

### 2026-02-23 — Initial implementation
- Created feature file
- All four implementation tasks in progress

## Decision Log

### 2026-02-23 — HTML comments for metadata embedding
**Context**: Need to embed machine-readable metadata (timestamp, source) into a Markdown file without breaking rendering or agent parsing.
**Decision**: Use HTML comments `<!-- kdevkit:key:value -->` format.
**Rationale**: HTML comments are valid in Markdown, invisible when rendered, easy to extract with a simple regex, and don't interfere with the agent reading the instruction text.
**Alternatives**: YAML frontmatter (breaks some agents), a dedicated metadata section (visible to agent, adds noise), filename-based encoding (not flexible enough).
**Impact**: Slightly unconventional but self-contained. Any future tooling can parse these comments with a one-liner regex.

### 2026-02-23 — paths-ignore over paths in GitHub Actions
**Context**: Workflow currently uses an explicit `paths` allowlist that misses the `pages.yml` file itself and any future source additions.
**Decision**: Replace `paths` allowlist with `paths-ignore: [tests/**]`.
**Rationale**: The principle of least surprise — anything committed to `main` that isn't a test should trigger a publish. Maintaining an allowlist is toil.
**Alternatives**: Keep allowlist and add workflow file itself (fragile, grows over time).
**Impact**: Workflow now also triggers on `README.md`, `.kdevkit/`, and other files — acceptable since those changes are infrequent and publish is cheap.
