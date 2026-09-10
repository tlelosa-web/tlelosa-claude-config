---
name: retired-machine-names-still-in-live-strings
description: "Operations"/"Pappa T" were retired 2026-08-20 but survive as present-tense claims in CORE.md and plugin.json — distinguish those from correct historical prose
metadata:
  type: project
---

Machine names as identity were retired 2026-08-20 (hub is the folder, not a machine). Stale *present-tense* survivors as of 2026-09-10:
- `dcoe-roster/plugin.json:4` — description says the hook deploys bootstrap "on Operations/Pappa T"
- `dcoe-roster/CORE.md:128` — "only fires on a machine that has actually installed the marketplace — Operations and Pappa T"
- `dcoe-roster/CORE.md:135` — "no-ops on Operations/Pappa T"

Correct as historical narrative, do NOT touch: `CORE.md:13` (ADR-007 reference), `CORE.md:120` (the 2026-08-09 Pappa T incident), and all `docs/specs/` prose.

**Why:** These are live descriptive claims about current deployment surfaces, now false. They sit in the same lines specs routinely edit for version bumps, so an Executor bumping `v1.10`→`v1.11` in `plugin.json:4` will read the false clause and have no instruction.

**How to apply:** If a spec edits a line containing one of these, require the spec to state explicitly whether the correction is in scope or deferred to a named `docs/todo.md` item — "unmentioned" is the bad outcome, because a later reader can't tell reviewed-and-kept from missed. My standing call: it's a separate item (three sites, two files, its own verification surface), but it must be named in "Explicitly out of scope." Verify these line numbers before citing — they drift.

Related: [[core-version-bump-is-one-commit]]
