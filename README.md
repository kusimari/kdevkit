# k-mcp-devkit

Dev practices as a slash command for Claude Code, Gemini CLI, and Amazon Kiro.

The installer drops a tiny stub into your agent's config directory. When you run `/dev`, the agent fetches the latest instructions from GitHub Pages — so your practices stay up to date without reinstalling.

---

## Install from GitHub (no clone needed)

```sh
npx github:kusimari/k-mcp-devkit --agent claude-code
```

Replace `claude-code` with `gemini` or `kiro` for other agents.

### Options

| Flag | Effect |
|------|--------|
| _(none)_ | Install stub — fetches latest instructions from GitHub Pages at runtime |
| `--local` | Install full built file (offline, pins to the version you have checked out) |
| `--global` | Install at user scope instead of project scope (Claude Code and Gemini only) |

---

## Install from a local clone

```sh
git clone https://github.com/kusimari/k-mcp-devkit.git
cd k-mcp-devkit
node install.js --agent claude-code
```

To install for all three agents at once:

```sh
node install.js --agent claude-code
node install.js --agent gemini
node install.js --agent kiro
```

---

## Install the local build (offline / pin version)

First build `commands/dev.md` from the source files in `src/`:

```sh
npm run build
# or
node build.js
```

Then install using the local build:

```sh
node install.js --agent claude-code --local
node install.js --agent gemini --local
node install.js --agent kiro --local
```

---

## Manual install (no command needed)

Copy the appropriate file directly into your agent's config:

| Agent | File to copy | Destination |
|-------|-------------|-------------|
| Claude Code | `stub/dev.md` | `.claude/commands/dev.md` (project) or `~/.claude/commands/dev.md` (global) |
| Gemini CLI | `stub/dev.md` | Append under `## k-mcp-devkit: dev` heading in `GEMINI.md` |
| Amazon Kiro | `stub/dev.md` | `.kiro/steering/dev.md` |

Use `commands/dev.md` instead of `stub/dev.md` if you want the full offline version.

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
# Build combined commands/dev.md:
npm run build

# Run all tests:
make test

# Run only install tests:
make test-install

# Run agent integration test:
make test-agent
```

Source files are in `src/` (numbered for sort order). `build.js` concatenates them into `commands/dev.md`, which is published to [GitHub Pages](https://kusimari.github.io/k-mcp-devkit/dev.md) on every push to `main`.
