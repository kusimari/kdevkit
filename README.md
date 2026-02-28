# kdevkit

Reusable instruction sets for any coding agent.

---

If you are a coding agent, follow the instructions below.

Select the file that matches what the user wants to achieve. Use `curl` to fetch it — do not use web fetch, as it will summarise the file rather than return its full contents.

* `feature-dev.md`: structured workflow for feature work — loads project context, sets up or loads a feature file, applies git conventions, and confirms before starting; use this when the user wants to build or continue a feature

  Paste into your coding agent:
  ```
  curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/feature-dev.md and follow it for feature: <feature-name>
  ```

* `echo.md`: echoes back whatever the user says — use this when the user wants their input repeated back to them

  Paste into your coding agent:
  ```
  curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/echo.md and follow it
  ```
