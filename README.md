# kdevkit

Dev practices as a slash command for Claude Code, Gemini CLI, and Amazon Kiro.

The installer fetches the latest `dev.md` from GitHub Pages and writes it into your agent's config. The GitHub repo holds source only; the published app lives on Pages.

---

## Install from GitHub (no clone needed)

```sh
npx github:kusimari/kdevkit claude-code
npx github:kusimari/kdevkit gemini
npx github:kusimari/kdevkit kiro
```

Add `--global` to install at user scope instead of project scope (Claude Code and Gemini only):

```sh
npx github:kusimari/kdevkit claude-code --global
```

---

## Install from a local clone

```sh
git clone https://github.com/kusimari/kdevkit.git
cd kdevkit
npm run build            # builds build/dev.md and runs tests
node install.js claude-code --local   # installs from local build
node install.js gemini --local
node install.js kiro --local
```

---

## Manual install (no command needed)

After `npm run build`, copy `build/dev.md` directly into your agent's config:

| Agent | Destination |
|-------|-------------|
| Claude Code | `.claude/commands/dev.md` (project) or `~/.claude/commands/dev.md` (global) |
| Gemini CLI | Append under `## kdevkit: dev` heading in `GEMINI.md` |
| Amazon Kiro | `.kiro/steering/dev.md` |

---

## Usage

### Claude Code

```
/dev [path/to/feature.md]
```

### Gemini CLI

Ask the model: _"Apply the kdevkit dev section from GEMINI.md and enter dev mode."_

### Amazon Kiro

The steering file is always active. Ask Kiro to enter dev mode or reference the feature file directly.

---

## Development

```sh
# Edit source files in src/, then build:
npm run build          # generates build/dev.md

# Run all tests (requires build/dev.md):
npm test

# Run test subsets:
npm run test:install
npm run test:dev
npm run test:agent

# Install into the current project from local build:
npm run install:claude
npm run install:gemini
npm run install:kiro
```

**Source** lives in `src/` (numbered for sort order). `build.js` concatenates them into `build/dev.md`. On push to `main`, CI runs `npm run build` then `npm test`, and on success publishes `build/dev.md` + `install.js` to GitHub Pages. The `build/` directory is gitignored.
