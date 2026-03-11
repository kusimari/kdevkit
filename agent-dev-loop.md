Work through the steps below **in order**. Do not skip steps.

---

## Step 1 — Project context

Read `.kdevkit/project.md` from the project root.

- **File has content** → load it silently; note the project name, tech stack, and constraints.
- **File is missing or empty** → ask exactly one question:
  *"Briefly describe this project — purpose, tech stack, and any hard constraints."*
  Wait for the answer, then create `.kdevkit/project.md` with a well-structured summary.
  Do not continue to Step 2 until the file exists with real content.

---

## Step 2 — Check for existing instructions

Check whether `.kdevkit/agent-dev-instructions.md` already exists.

- **File exists** → read it and display a compact summary (project name, quality commands, test command, thresholds). Ask:
  *"Dev-loop instructions already exist. Update them, or keep as-is?"*
  - **Keep** → skip to the end and confirm. You are done.
  - **Update** → continue to Step 3, treating this as a re-detection pass.
- **File missing** → continue to Step 3.

---

## Step 3 — Probe the project ecosystem

Silently inspect the project root for the marker files below. A project may have more than one
ecosystem (e.g. a Python backend with a Node.js frontend) — detect all that apply.

### Ecosystem markers

| Marker file(s) | Ecosystem |
|---|---|
| `pyproject.toml` · `setup.py` · `requirements.txt` | Python |
| `package.json` | Node.js / JavaScript / TypeScript |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `pom.xml` · `build.gradle` · `build.gradle.kts` | Java / Kotlin |
| `Makefile` | Any (inspect targets) |

### Tool identification

For each detected ecosystem, look for tool config files to pin down the exact commands:

**Python**
- Format: `[tool.ruff]` in `pyproject.toml` or `ruff.toml` present → `ruff format .`; else `black .`
- Lint: `[tool.ruff]` present → `ruff check .`; else `pylint <src-dir>`
- Type: `[tool.mypy]` in `pyproject.toml` or `.mypy.ini` present → `mypy .`; else skip
- Test: `pytest.ini` · `[tool.pytest]` · `conftest.py` present → `pytest`; else `python -m unittest discover`
- Setup: `pyproject.toml` with `[build-system]` → `pip install -e .`; `requirements.txt` → `pip install -r requirements.txt`

**Node.js / JavaScript / TypeScript**
- Format: `.prettierrc*` or `prettier` in `package.json#devDependencies` → `npx prettier --write .`
- Lint: `.eslintrc*` or `eslint` key in `package.json` → `npx eslint .`
- Type: `tsconfig.json` present → `npx tsc --noEmit`
- Test: `jest.config*` or `jest` in `package.json#scripts` → `npm test`; `vitest.config*` → `npx vitest run`
- Setup: `package-lock.json` → `npm ci`; `yarn.lock` → `yarn install`; `pnpm-lock.yaml` → `pnpm install`

**Rust**
- Format: `cargo fmt --all -- --check`
- Lint: `cargo clippy -- -D warnings`
- Test: `cargo test`
- Setup: `cargo build`

**Go**
- Format: `gofmt -l .` (fail if output non-empty); or `goimports -l .` if present
- Lint: `.golangci.yml` present → `golangci-lint run`; else `go vet ./...`
- Test: `go test ./...`
- Setup: `go mod download`

**Java / Kotlin**
- Use `mvn` or `gradle` commands detected from the build file
- Format/Lint: check for `checkstyle` plugin in `pom.xml` / `build.gradle`
- Test: `mvn test` or `./gradlew test`

**Makefile**
- Read the Makefile and identify targets named `lint`, `test`, `build`, `fmt`, `format`, `check`, `typecheck`
- Use `make <target>` for each identified target

### CI as ground truth

After the above detection, check `.github/workflows/*.yml` and `.gitlab-ci.yml` for any job steps
that run quality or test commands. If found, **prefer those commands** — they reflect what the project
actually runs. Extract the commands exactly as written in the CI config.

---

## Step 4 — Confirm with user

Present the detected commands as a table:

```
Detected toolchain for <project-name>:

| Category  | Command                        |
|-----------|--------------------------------|
| Setup     | <detected setup command>       |
| Format    | <detected format command>      |
| Lint      | <detected lint command>        |
| Type      | <detected typecheck command>   |
| Test      | <detected test command>        |
```

Omit rows for categories where nothing was detected.

Then ask:
1. *"Are these commands correct? Reply with any overrides in the form `<category>: <new command>`, or say 'ok' to confirm."*
2. *"Code review score threshold? (Default: 70 — enter a number 0–100, or press Enter for default.)"*
3. *"Max test-retry cycles? (Default: 2 — enter a number, or press Enter for default.)"*

Wait for all three answers before proceeding.

---

## Step 5 — Write `.kdevkit/agent-dev-instructions.md`

Using the confirmed commands and thresholds, write the file below to `.kdevkit/agent-dev-instructions.md`.
Create the `.kdevkit/` directory if it does not exist.

---

*Template — replace all `<…>` placeholders with the actual values:*

```markdown
# Agent Development Instructions — <project-name>

## Repository Structure
<one short paragraph from .kdevkit/project.md describing what the project is>

## Local Setup & Commands

**Setup:**
```bash
<setup command>
```

**Code Quality:**
- `<format command>` — auto-format source files
- `<lint command>` — enforce lint rules (must exit 0)
<if typecheck>- `<typecheck command>` — static type checking (must exit 0)</if>

**Testing:**
- `<test command>` — run the full test suite

## Workflow: Code → Quality → Test → Push

Always follow this sequence after completing any unit of work.

### Quality Gate (Step 1)

1. Run the format command and apply all automatic fixes.
2. Run the lint command. Fix all violations. Re-run until it exits 0.
<if typecheck>3. Run the type-check command. Fix all errors. Re-run until it exits 0.</if>
4. Generate a diff of all changes against the base branch:
   ```bash
   git diff <base-branch>...HEAD
   ```
5. Spawn a sub-agent to review the diff. Use this prompt:
   > "Review the following diff for code quality, correctness, security issues, and adherence to
   > the project's conventions. Score it 0–100 and list specific issues to fix, ordered by severity."
6. Threshold is **<threshold>/100**.
   - Score ≥ threshold → proceed to the Test Gate.
   - Score < threshold → fix the highest-severity issues from the review, then re-review **once only**.
     If still below threshold after one re-review, proceed anyway and note the residual issues.

### Test Gate (Step 2)

1. Run the full test suite: `<test command>`
2. All tests must pass (zero failures, zero errors).
3. If tests fail, diagnose, fix, and re-run. Up to **<max-retries> fix-and-retry cycles** are allowed.
4. If tests still fail after <max-retries> attempts, stop and report the failures — do not push.
5. If the fixes in this step involved substantial code changes, re-run the Quality Gate before pushing.

### Push Gate

Only push after both gates pass:

```bash
git push -u origin <feature-branch>
```

Do not open a PR — that is the human reviewer's step.

## Testing Standards

- Tests must not make real network calls; use mocks or stubs for external services.
- Each test should verify one behaviour; avoid testing implementation details.
- New code requires corresponding tests; do not ship untested code.
- If the test suite has existing patterns (fixtures, factories, helpers), follow them.
```

---

After writing the file, display a one-line confirmation:

```
✓ Wrote .kdevkit/agent-dev-instructions.md  (threshold: <N>, retries: <N>)
```

Then stop and wait for the user's next instruction.
