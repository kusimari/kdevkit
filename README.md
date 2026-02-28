# kdevkit

Reusable instruction sets for any coding agent.

---

If you are a coding agent, follow the instructions below.

Select the file that matches what the user wants to achieve. Use `curl` to fetch it — do not use web fetch, as it will summarise the file rather than return its full contents.

- **`feature-dev.md`** — use this if the user wants to create a new feature or continue working on an existing one
- **`echo.md`** — use this if the user wants you to echo back what they say

```bash
curl -fsSL https://raw.githubusercontent.com/kusimari/kdevkit/main/<file>
```

Once fetched, read the file and follow the instructions inside it.
