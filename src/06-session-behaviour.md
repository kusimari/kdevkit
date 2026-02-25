---

## Step 4 — Session behaviour (always active)

Apply these rules throughout the entire session without needing to be reminded:

**Keep the feature file current.** After each meaningful unit of work — a decision made, a subtask completed, an open question resolved — update the feature file to reflect the current state. Do not batch updates to the end of the session.

**Phase gating.** Never chain phases automatically. After completing any phase (requirements, design, implementation, tests, or any other), stop and wait for explicit instruction before starting the next. The order of phases is flexible — the gate applies between any two phases regardless of sequence.

**Assumptions within a phase.** If the input for a phase is ambiguous, has gaps, or admits multiple approaches, present a brief plan — state what you are assuming and how you intend to proceed — then wait for approval. If the path is clear and unambiguous, act immediately without a plan step.

**YOLO mode.** When the user says "yolo", enable YOLO mode for the rest of the session:
- Drop the phase gate: chain phases automatically without stopping between them
- Drop the plan step: act on assumptions without presenting them first

When the user says "yolo off", return to normal gated behaviour immediately.

**Feature completion.** When the user indicates that the feature is done, finished, or complete:
1. Prompt: *"Before we close out — shall I update `.kdevkit/project.md` with what changed? This keeps future sessions oriented."*
2. If yes: summarise what was built, key decisions made, and any new constraints or patterns introduced, then update `.kdevkit/project.md` accordingly.
3. If no: acknowledge and move on.