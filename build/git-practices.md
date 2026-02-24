---

## Step 3 — Git practices

Apply these git conventions for the full duration of this session:

### Branches

Pattern: `<type>/<short-description>`

Types: `feat` · `fix` · `chore` · `docs` · `refactor` · `test`

Examples:
- `feat/user-auth`
- `fix/null-pointer-on-login`
- `chore/update-deps`

### Commits

Format: Conventional Commits — `type(scope): subject`

Rules:
- Imperative mood, lowercase, no trailing period
- Subject line ≤ 72 characters
- Each commit must leave the repo in a working state — no broken builds mid-branch
- If a commit needs a body, the body explains *why*, not *what* (the diff shows what)

Examples:
- `feat(auth): add JWT refresh token rotation`
- `fix(api): handle empty response from upstream`
- `chore: bump Node to 22`

### Scope

- Commits and config changes stay **local to this project** — never modify global git config
- Do not write to `~/.gitconfig`, `~/.ssh/`, or any path outside the project root
- If a git hook or script tries to write outside the project, flag it before running

### Pull Requests

- PR title follows the same `type(scope): subject` format
- PR body: explain *why* the change is needed and what approach was chosen
- Keep PRs small; one concern per PR
- Squash merge; the squash commit message must match the PR title format

### Commit discipline

- **Commits are save points** — commit whenever a coherent unit of work is done; do not wait until the whole feature is complete
- Every commit must leave the repo in a working state (tests pass, build succeeds)
- Push to the feature branch freely; pushing is not the same as opening a PR

### PR gate

A PR is ready when, and only when, **`npm run build` passes locally** (or the project's equivalent build-and-test command). Do not open a PR if the build is broken or tests are red.

- Run the full build+test suite immediately before opening a PR
- If CI is configured, it runs only on protected branches (e.g. `main`) — feature branches are the developer's responsibility
- CI triggers only on changes to source and build files, not test-only changes

### Hygiene

- Do not commit commented-out code, debug prints, or temporary test files
- Do not commit secrets, credentials, or environment-specific values
- If `.gitignore` needs updating, include it in the same commit that adds the ignored file
