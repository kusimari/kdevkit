# kdevkit

Dev practices as a slash command for Claude Code, Gemini CLI, and Amazon Kiro.

---

## Install

### 1. From GitHub

```sh
npx github:kusimari/kdevkit claude-code
npx github:kusimari/kdevkit gemini
npx github:kusimari/kdevkit kiro
```

Add `--global` to install at user scope instead of project scope (Claude Code and Gemini only):

```sh
npx github:kusimari/kdevkit claude-code --global
```

### 2. From a local clone

Build first, then install from the local build (equivalent to the GitHub version):

```sh
git clone https://github.com/kusimari/kdevkit.git
cd kdevkit
npm run build
node install.js claude-code --local
node install.js gemini --local
node install.js kiro --local
```

### 3. Cloud or no-install environments

If you can't run npm (e.g. Claude Code web, claude.ai), skip install — see **Using dev mode without install** below.

---

## Using dev mode

### If installed

**Claude Code**

```
/dev [feature-name]
```

**Gemini CLI**

Ask the model: _"Apply the kdevkit dev section from GEMINI.md and enter dev mode."_

**Amazon Kiro**

The steering file is always active. Ask Kiro to enter dev mode or reference the feature file directly.

### Without install (Claude Code web, claude.ai)

Paste this at the start of any session — Claude fetches the devkit on demand:

```
Fetch https://kusimari.github.io/kdevkit/dev.md and follow those instructions for feature: [feature-name]
```

Omit `for feature: ...` to be prompted interactively.

**claude.ai Projects** — add the devkit once, use it in every chat:

1. Open your Project → **Add content** → paste the contents of [`dev.md`](https://kusimari.github.io/kdevkit/dev.md)
2. Start sessions with: _"Enter dev mode for feature: [name]"_

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
