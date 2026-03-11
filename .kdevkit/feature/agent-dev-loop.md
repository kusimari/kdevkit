# Feature: agent-dev-loop

## Git Setup
- Branch: claude/plan-session-74PWP
- Base: main

## Feature Brief

Projects using kdevkit have no standard way to tell a coding agent how to run quality checks, tests,
and builds. The hudukaata project solved this by hand-writing `.kdevkit/agent-dev-instructions.md`.
This feature makes that pattern generic: a new `agent-dev-loop.md` agent auto-detects (or is told)
the project's toolchain and writes a project-specific `.kdevkit/agent-dev-instructions.md`. Once the
file exists, `feature-dev.md` loads it so every session enforces the same Quality → Test → Push gates.

## Requirements

- New `agent-dev-loop.md` at the kdevkit root, invocable the same way as `feature-dev.md`
- Agent detects the language ecosystem from marker files (`pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, `pom.xml`, `Makefile`)
- For each ecosystem, agent identifies the specific tools in use from config files and CI workflows
- Agent presents a confirmation table of detected commands before writing anything
- User can override any detected command or threshold before the file is written
- Output file is `.kdevkit/agent-dev-instructions.md` in the target project
- Output file structure: Repository Structure · Local Setup & Commands · Workflow (Quality Gate → Test Gate → Push Gate) · Testing Standards
- Configurable score threshold (default 70) and max test-retry cycles (default 2)
- If `.kdevkit/agent-dev-instructions.md` already exists, agent summarises it and offers to update
- `feature-dev.md` gains **Step 1.6**: silently load the file when present; offer to create it when absent
- `README.md` lists `agent-dev-loop.md` as a third agent option

## Design

### agent-dev-loop.md workflow (5 steps)

1. **Load project context** — read `.kdevkit/project.md`; ask one question if missing (same as feature-dev.md)
2. **Check existing instructions** — if `.kdevkit/agent-dev-instructions.md` exists, summarise and offer update/skip
3. **Probe the ecosystem** — inspect marker files then tool-config files; fall back to CI workflow commands as ground truth
4. **Confirm with user** — display a table (category → command); let user override; ask for threshold and retry count
5. **Write `.kdevkit/agent-dev-instructions.md`** — structured file with gates and testing standards

### Ecosystem detection priority

| Marker file | Ecosystem |
|---|---|
| `pyproject.toml` / `setup.py` / `requirements.txt` | Python |
| `package.json` | Node.js / JS / TS |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `pom.xml` / `build.gradle` | Java / Kotlin |
| `Makefile` | Any (inspect targets) |

### Tool identification (per ecosystem)

**Python:** `[tool.ruff]` in pyproject.toml or `ruff.toml` → ruff; `[tool.mypy]` or `.mypy.ini` → mypy; else pylint/black fallback
**Node:** `.eslintrc*` → eslint; `.prettierrc*` → prettier; `jest.config*` → jest; `vitest.config*` → vitest
**Rust:** always clippy + `cargo fmt` + `cargo test`
**Go:** `.golangci.yml` → golangci-lint; else `go vet` + `go fmt` + `go test ./...`

CI workflows (`.github/workflows/*.yml`, `.gitlab-ci.yml`) are checked last and take precedence — they are the source of truth for what the project actually runs.

### feature-dev.md Step 1.6

Inserted between Step 1 and Step 1.5. Non-blocking: missing file is not an error.

### Generated file template

Mirrors the hudukaata `agent-dev-instructions.md` structure, parameterised for any project.

## Test Strategy

Manual trace against two representative projects:
1. **Python (ruff + mypy + pytest)** — should produce commands equivalent to hudukaata's hand-written file
2. **Node.js (eslint + jest)** — should produce correct eslint + jest commands

Verify `feature-dev.md` Step 1.6:
- With file present: loads silently, Step 5 summary unchanged
- Without file: no error, hint appears after first implementation task

## Implementation Plan

1. ✅ Create `.kdevkit/feature/agent-dev-loop.md` (this file)
2. ⏳ Create `agent-dev-loop.md` at repo root
3. ⏳ Edit `feature-dev.md` — insert Step 1.6
4. ⏳ Edit `README.md` — add agent-dev-loop.md entry
5. ⏳ Commit and push on `claude/plan-session-74PWP`

## Session Log

<!-- 2026-03-11: Feature planned; feature file created; ready for implementation -->

## Decision Log

- **Standalone file vs. integrated into feature-dev.md**: chose standalone. Keeps concerns separate; users on projects that don't want quality gates aren't affected. `feature-dev.md` references it but doesn't require it.
- **Detection first, ask second**: agent probes files silently then presents findings for confirmation. Avoids interrogating the user for info already in the repo.
- **CI config as ground truth**: if `.github/workflows/*.yml` already defines the quality/test commands, use those — they're what the project actually runs in CI.
- **Non-blocking in feature-dev.md**: `agent-dev-instructions.md` is optional. Missing file triggers a hint, not an error. Existing projects aren't broken.
