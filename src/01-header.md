# /dev — Enter Dev Mode

Usage: `/dev [feature] [options]`

**Options** (set at invocation or at any point during the session):

| Option | Effect |
|--------|--------|
| `yolo` | YOLO mode: chain phases automatically and skip assumption plans |
| `yolo off` | Return to normal gated mode |

For Gemini, Kiro, and fetch-based invocations, include options naturally in the message — e.g. _"enter dev mode for my-feature with yolo"_.

**Before Step 1**, scan `$ARGUMENTS` (or the invocation message) for recognized option tokens and apply them. Everything remaining is treated as the feature name for Step 2.

Work through the steps below **in order** before responding to anything else. Load companion files before starting:
- `kdevkit/feature-setup.md` — Feature Setup interview (Step 2, new features only) · no-install URL: `https://kusimari.github.io/kdevkit/feature-setup.md`
- `kdevkit/git-practices.md` — Git conventions (Step 3) · no-install URL: `https://kusimari.github.io/kdevkit/git-practices.md`

---