## Purpose

kdevkit provides dev practices as a slash command for coding agents (Claude Code, Gemini CLI, Amazon Kiro). When a user runs `/dev [feature]`, the agent follows structured steps: load project context, set up or load a feature file, apply git conventions, and confirm before starting work.

## Tech Stack

- Node.js ≥18 — `build.js` (build script) and `install.js` (installer); zero npm dependencies, built-ins only (`fs`, `path`, `os`, `https`)
- Bash — test runner and test suites (`tests/`)
- Markdown — all content in `src/`
- GitHub Pages — hosts `build/dev.md`, `build/feature-setup.md`, `build/git-practices.md`, `install.js`, and `index.html` at `kusimari.github.io/kdevkit`
- GitHub Actions — CI: `npm run build` on push to `main` → commit build files → publish to Pages

## Constraints

- `install.js` and `build.js` must have **zero npm dependencies** — Node.js built-ins only
- `build/` is gitignored locally; **only CI commits build files** (`build/dev.md`, `build/feature-setup.md`, `build/git-practices.md`) via `git add -f`. Do not commit build files manually.
- `src/*.md` files must concatenate cleanly: no YAML frontmatter, no special syntax
- Published content is static files only (Pages); no server-side logic

## Key Paths

| Path | Role |
|------|------|
| `src/` | Source markdown files; `build.js` MANIFEST controls which files go into which output |
| `build/` | Generated output (gitignored locally, committed by CI); `build/dev.md`, `build/feature-setup.md`, `build/git-practices.md`, and `build/index.html` are published to Pages |
| `install.js` | Installer — fetches `dev.md` + companion files from GitHub Pages (default) or reads from `build/` (`--local`); writes companion files to `kdevkit/` subdirectory alongside `dev.md` |
| `build.js` | Build script — MANIFEST maps src files → `build/dev.md` (compact entry), `build/feature-setup.md`, `build/git-practices.md` |
| `tests/` | Test suites — run via `npm test` |
| `.kdevkit/project.md` | Project context loaded by `/dev` on every session |
| `.kdevkit/feature/` | Feature context files — one per feature, created/updated by `/dev` |
| `index.html` | Landing page (source); built to `build/index.html`, deployed to Pages |

## Development Workflow

- **Build**: `npm run build` — generates `build/dev.md`, `build/feature-setup.md`, `build/git-practices.md` from `src/` via MANIFEST
- **Test**: `npm test` — all suites; subsets via `npm run test:install`, `test:dev`, `test:agent`
- **Install locally**: `npm run install:claude` / `install:gemini` / `install:kiro` (uses `--local`)
- **PR gate**: `npm run build && npm test` must pass locally before opening a PR
- **Commits** are save points — commit often on the feature branch; don't wait for the full feature
- **CI** runs only on push to `main`, triggered only by changes to `src/`, `install.js`, or `build.js`
- Never push directly to `main`; always merge via PR
