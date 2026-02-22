# k-mcp-devkit

Dev practices as a slash command for Claude Code, Gemini CLI, and Amazon Kiro.

The full dev instructions are embedded in the installer and written directly into your agent's config — works offline, no network fetch required at runtime.

---

## Install from GitHub (no clone needed)

```sh
npx github:kusimari/k-mcp-devkit claude-code
npx github:kusimari/k-mcp-devkit gemini
npx github:kusimari/k-mcp-devkit kiro
```

Add `--global` to install at user scope instead of project scope (Claude Code and Gemini only):

```sh
npx github:kusimari/k-mcp-devkit claude-code --global
```

---

## Install from a local clone

```sh
git clone https://github.com/kusimari/k-mcp-devkit.git
cd k-mcp-devkit
node build/install.js claude-code
node build/install.js gemini
node build/install.js kiro
```

---

## Manual install (no command needed)

Copy `build/dev.md` from a local clone directly into your agent's config:

| Agent | Destination |
|-------|-------------|
| Claude Code | `.claude/commands/dev.md` (project) or `~/.claude/commands/dev.md` (global) |
| Gemini CLI | Append under `## k-mcp-devkit: dev` heading in `GEMINI.md` |
| Amazon Kiro | `.kiro/steering/dev.md` |

---

## Usage

### Claude Code

```
/dev [path/to/feature.md]
```

### Gemini CLI

Ask the model: _"Apply the k-mcp-devkit dev section from GEMINI.md and enter dev mode."_

### Amazon Kiro

The steering file is always active. Ask Kiro to enter dev mode or reference the feature file directly.

---

## Development

```sh
# Edit source files in src/
# Build build/dev.md and build/install.js:
npm run build    # or: node build.js

# Run all tests:
make test

# Run only install tests:
make test-install

# Run agent integration test:
make test-agent

# Install into the current project after building:
make install-claude
make install-gemini
make install-kiro
```

Source files are in `src/` (numbered for sort order). `build.js` concatenates them into `build/dev.md` and generates a self-contained `build/install.js` with the content embedded. Both artifacts are committed so `npx github:kusimari/k-mcp-devkit` works without a separate build step.
