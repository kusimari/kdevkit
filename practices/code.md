# Code Practices

## Before Editing

- Read the file before changing it — understand what is already there
- Understand the surrounding context: callers, types, tests
- Check if a similar pattern already exists elsewhere in the codebase before introducing a new one

## Change Discipline

- Make small, focused changes — one concern per commit
- Only change what is needed for the current task; do not refactor or clean up adjacent code unless explicitly asked
- Do not add docstrings, comments, or type annotations to code you did not change

## Quality

- Prefer explicit and readable over clever and compact
- No commented-out code — delete it or keep it, not both
- Remove dead code rather than leaving it behind
- No debug prints or temporary scaffolding in commits

## Error Handling

- Only add validation and error handling at real system boundaries: user input, external APIs, file I/O
- Do not defend against internal invariants — trust the types and the calling code
- Do not add fallbacks or default values for scenarios that should not occur

## Tests

- Write tests for new behaviour
- Do not break existing tests without explaining why in the commit body
- Do not add tests that only confirm the language works (e.g., testing that `1 + 1 === 2`)

## Security

- Never introduce command injection, SQL injection, XSS, or other OWASP top-10 vulnerabilities
- If you write something insecure, fix it immediately in the same diff
- Do not log sensitive data (tokens, passwords, PII)
