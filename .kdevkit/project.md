## Purpose

kdevkit provides dev practices as a slash command for coding agents (Claude Code, Gemini CLI, Amazon Kiro). When a user runs `/dev [feature]`, the agent follows structured steps: load project context, set up or load a feature file, apply git conventions, and confirm before starting work.

## Tech Stack

- Node.js ≥18 — `build.js` (build script) and `install.js` (installer); zero npm dependencies, built-ins only (`fs`, `path`, `os`, `https`)
- Bash — test runner and test suites (`tests/`)
- Markdown — all content in `src/`
- GitHub Pages — hosts `build/dev.md` and `install.js` at `kusimari.github.io/kdevkit`
- GitHub Actions — CI: `npm run build` on push to `main` (src/install/build changes only) → publish to Pages

## Constraints

- `install.js` and `build.js` must have **zero npm dependencies** — Node.js built-ins only
- `build/` is gitignored; never commit generated artifacts
- `src/*.md` files must concatenate cleanly: no YAML frontmatter, no special syntax
- Published content is static files only (Pages); no server-side logic

## Key Paths

| Path | Role |
|------|------|
| `src/` | Source markdown files (`01-header.md` … `07-confirm.md`), sorted and concatenated by `build.js` |
| `build/` | Generated output (gitignored); `build/dev.md` is what gets published and installed |
| `install.js` | Installer — fetches `dev.md` from GitHub Pages (default) or reads `build/dev.md` (`--local`) |
| `build.js` | Build script — `src/*.md` → `build/dev.md` |
| `tests/` | Test suites — run via `npm test` |
| `.kdevkit/` | Project and feature context files maintained by `/dev` mode |

## Development Workflow

- **Build**: `npm run build` — generates `build/dev.md` from `src/`
- **Test**: `npm test` — all suites; subsets via `npm run test:install`, `test:dev`, `test:agent`
- **Install locally**: `npm run install:claude` / `install:gemini` / `install:kiro` (uses `--local`)
- **PR gate**: `npm run build && npm test` must pass locally before opening a PR
- **Commits** are save points — commit often on the feature branch; don't wait for the full feature
- **CI** runs only on push to `main`, triggered only by changes to `src/`, `install.js`, or `build.js`
- Never push directly to `main`; always merge via PR
