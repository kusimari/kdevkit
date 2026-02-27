## Purpose

kdevkit provides a structured dev workflow as a Claude agent (`kdevkit-dev`). When invoked, the agent loads project context, sets up or loads a feature file, applies git conventions, and confirms before starting work. Works in Claude Code CLI and Claude Code on the web.

## Tech Stack

- Node.js ≥18 — `build.js` (build script); zero npm dependencies, built-ins only (`fs`, `path`)
- Bash — test runner and test suite (`tests/build.sh`)
- Markdown — all content in `src/`; assembled into a single self-contained agent file
- GitHub Actions — CI: `npm run build && npm test` on push to `main` → commits `build/kdevkit-dev.md`

## Constraints

- `build.js` must have **zero npm dependencies** — Node.js built-ins only
- `build/` is gitignored locally; **only CI commits the build file** (`build/kdevkit-dev.md`) via `git add -f`
- The built agent file must be fully self-contained — no external URLs or file references inside it
- `src/*.md` files must concatenate cleanly into a single output

## Key Paths

| Path | Role |
|------|------|
| `src/` | Source markdown files; `build.js` MANIFEST controls assembly order |
| `build/kdevkit-dev.md` | Single built output — the agent file (gitignored locally, committed by CI) |
| `build.js` | Build script — concatenates src files into `build/kdevkit-dev.md` |
| `tests/build.sh` | Checks format (YAML frontmatter) and contents (all sections present, no external URLs) |
| `.kdevkit/project.md` | Project context loaded by the agent on every session |
| `.kdevkit/feature/` | Feature context files — one per feature, created/updated by the agent |

## Development Workflow

- **Build**: `npm run build` — generates `build/kdevkit-dev.md` from `src/` via MANIFEST
- **Test**: `npm test` — runs `tests/build.sh`
- **PR gate**: `npm run build && npm test` must pass locally before opening a PR
- **CI** commits `build/kdevkit-dev.md` to `main` after build + test pass
- Never push directly to `main`; always merge via PR
