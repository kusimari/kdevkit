# kdevkit

Reusable instruction sets for any coding agent.

---

Paste into your coding agent to get started:
```
curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/README.md and follow the instructions
```

---

If you are a coding agent, follow the instructions below.

Select the file that matches what the user wants to achieve. Use `curl` to fetch it — do not use web fetch, as it will summarise the file rather than return its full contents.

* `feature-dev.md`: structured workflow for feature work — loads project context, sets up or loads a feature file, applies git conventions, and confirms before starting; use this when the user wants to build or continue a feature

  Paste into your coding agent:
  ```
  curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/feature-dev.md and follow it for feature: <feature-name>
  ```

* `agent-dev-loop.md`: detects your project's code-quality, test, and build toolchain and creates `.kdevkit/agent-dev-instructions.md` so coding agents follow a consistent quality → test → push gate on every session; use this once per project to set up the dev loop, or when you want to update it

  Paste into your coding agent:
  ```
  curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/agent-dev-loop.md and follow it
  ```

* `echo.md`: echoes back whatever the user says — use this when the user wants their input repeated back to them

  Paste into your coding agent:
  ```
  curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/echo.md and follow it
  ```
