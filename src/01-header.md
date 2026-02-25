# /dev — Enter Dev Mode

Usage: `/dev [feature] [options]`

Options (`yolo` is **off** by default): `yolo` — chain phases and skip assumption plans; `yolo off` — revert.
Gemini/Kiro/fetch: include options in the message — e.g. _"enter dev mode for my-feature with yolo"_.

**Before Step 1**, parse `$ARGUMENTS` (or the invocation message): extract recognized option tokens and apply them; the rest is the feature name for Step 2.

Work through the steps below **in order**. Load companion files before starting:
- `kdevkit/feature-setup.md` — Feature Setup (Step 2, new features) · `https://kusimari.github.io/kdevkit/feature-setup.md`
- `kdevkit/git-practices.md` — Git conventions (Step 3) · `https://kusimari.github.io/kdevkit/git-practices.md`

---
