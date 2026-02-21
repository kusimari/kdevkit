# Setting Up k-mcp-devkit

## What This Project Is

`k-mcp-devkit` is an MCP (Model Context Protocol) server that surfaces dev-practice
tooling to AI assistants. The goal is to codify good development habits — git
workflow, code hygiene, project conventions — as MCP tools that an agent can invoke
during a coding session rather than relying on ad-hoc prompting.

The name reflects the scope: a **dev-kit** for everyday dev practices and whatever
else proves useful ("sundry").

---

## Vision

### Problem

AI coding assistants are great at writing code but often skip the surrounding
practices: committing with clean messages, following branch conventions, linting
before pushing, keeping a changelog, etc. These tasks live outside the editor and
are easy to forget.

### Solution

A single MCP server that an agent can call to:
- enforce and automate git workflows (branch naming, commit messages, tags)
- run or report code quality checks (linting, formatting, dead code)
- generate and maintain project boilerplate (configs, READMEs, changelogs)
- surface project-level conventions as callable tools

The server is language-agnostic: it wraps external tools and conventions rather
than reimplementing them.

---

## Core Feature Areas

### 1. Git Workflow Tools
- `git_branch_name` — suggest a valid branch name from a description
- `git_commit_message` — generate a conventional commit message from a diff/summary
- `git_changelog` — produce a changelog entry from recent commits
- `git_pr_description` — draft a PR title + body from branch commits

### 2. Code Quality
- `lint_check` — run the project's configured linter and return results
- `format_check` — check formatting without applying (report-only)
- `dead_code_check` — surface unused exports/functions (language-specific)

### 3. Project Scaffolding
- `init_config` — generate standard config files (`.editorconfig`, `.gitignore`, etc.)
- `init_readme` — scaffold a README template from project metadata
- `init_ci` — generate a basic CI workflow file

### 4. Conventions & Metadata
- `project_info` — return key metadata about the current project
- `convention_check` — compare the project against a set of defined conventions

---

## Non-Goals (for now)

- No UI or web interface — pure MCP server
- No cloud/remote execution — runs locally against the working directory
- No per-language deep analysis (leave that to language servers)

---

## Tech Stack

| Concern | Choice | Reason |
|---|---|---|
| Language | TypeScript | Official MCP SDK is TS-first; strong tooling |
| Runtime | Node.js ≥ 20 | LTS, good `child_process` support for shelling out |
| MCP SDK | `@modelcontextprotocol/sdk` | Official SDK |
| Transport | stdio | Standard for local MCP servers |
| Packaging | npm | Simple distribution |

---

## Project Structure (target)

```
k-mcp-devkit/
├── src/
│   ├── index.ts          # MCP server entry point
│   ├── tools/            # One file per tool group
│   │   ├── git.ts
│   │   ├── quality.ts
│   │   ├── scaffold.ts
│   │   └── conventions.ts
│   └── utils/            # Shared helpers (exec, fs, etc.)
│       └── exec.ts
├── feature/              # Feature planning docs (this folder)
├── package.json
├── tsconfig.json
├── .gitignore
└── README.md
```

---

## Setup Checklist

- [x] Repo created with AGPLv3 license
- [ ] `package.json` with MCP SDK dependency
- [ ] `tsconfig.json` configured
- [ ] Basic MCP server skeleton in `src/index.ts`
- [ ] First working tool (e.g. `git_branch_name`)
- [ ] Local test via MCP inspector
- [ ] README updated with install + usage instructions

---

## Running Locally

```bash
npm install
npm run build
node dist/index.js
```

To connect to Claude Desktop or another MCP host, add an entry like:

```json
{
  "mcpServers": {
    "k-mcp-devkit": {
      "command": "node",
      "args": ["/path/to/k-mcp-devkit/dist/index.js"]
    }
  }
}
```

---

## Development Conventions

- Conventional Commits (`feat:`, `fix:`, `chore:`, etc.)
- Branch pattern: `<type>/<short-description>` (e.g. `feat/git-branch-tool`)
- PRs require a description; squash merge to main
- Keep tool functions pure where possible — side effects only in `utils/exec.ts`
