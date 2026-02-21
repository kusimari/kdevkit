## Step 2 — Feature context

Determine the feature file to load:
- If an argument was passed (`$ARGUMENTS`), derive the path: `context/<argument>.md`
  (lowercase the argument and replace spaces with hyphens — e.g. `user auth` → `context/user-auth.md`).
- Otherwise, ask: *"Which feature are you working on? Provide a short name."*
  Use the answer the same way: `context/<name>.md`.

Then:
- **File has content** → load it silently; note what is currently being built.
- **File is missing or empty** → conduct the Feature Setup process below to create it.
  Do not continue to Step 3 until the file exists with real content.