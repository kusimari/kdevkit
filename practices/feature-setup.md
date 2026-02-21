# Feature Setup Interview

When a feature file needs to be created, conduct the following interview with the user.
Ask each question **one at a time** and wait for the answer before continuing.
Do not ask all questions at once.

---

## Interview Steps

**1. Name**
Ask: *"What is a short name or identifier for this feature?"*
Use the answer as the heading of the feature file.

**2. Goal**
Ask: *"What does this feature do, and why is it being built?"*
A sentence or two is enough. Capture the user's words closely.

**3. Acceptance criteria**
Ask: *"What does done look like? List the things that must be true for this feature to be considered complete."*
Prompt the user to be specific. Vague answers like "it works" should be gently pushed back on:
*"Can you make that more concrete — e.g. a specific behaviour, output, or test that would pass?"*

**4. Constraints**
Ask: *"Are there hard limits or things that must not change? For example: APIs that cannot break, performance budgets, libraries that cannot be added."*
If the user says none, record that explicitly.

**5. Dependencies**
Ask: *"Does this feature depend on other features, services, or systems that are in flight or not yet built?"*
If yes, note them so the agent knows what to watch out for.

**6. Open questions**
Ask: *"What do you not yet know that could block or change this feature?"*
These become action items, not blockers — record them so they can be resolved during the session.

---

## Output Format

After the interview, create the feature file with this structure:

```markdown
# <Feature Name>

## Goal
<what it does and why>

## Acceptance Criteria
- <specific, testable criterion>
- <specific, testable criterion>

## Constraints
- <hard limit or "none">

## Dependencies
- <other feature/service or "none">

## Open Questions
- [ ] <unresolved question>

## Progress
<!-- Updated by the agent throughout the session -->
- [ ] <first subtask or milestone>
```

Tell the user where the file was created, then continue to Step 3 of `/dev`.

---

## Keeping the File Current

Throughout the session, update the **Progress** section as work advances:
- Mark completed items with `[x]`
- Add new subtasks as they emerge
- Move resolved open questions out of Open Questions and into Notes if useful context should be preserved

When the user says the feature is complete, mark all done items and prompt the project context update as described in `commands/dev.md`.
