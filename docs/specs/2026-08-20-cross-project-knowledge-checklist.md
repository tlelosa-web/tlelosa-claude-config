# Spec — Cross-project knowledge-cache check in close-out commands

**Date:** 2026-08-20 | **Status:** Draft — awaiting reviewer approval before implementation
**Basis:** `Claude-Code`'s second `/retro` run (2026-08-20), item 3 of 3 selected. Evidence:
session-log entry "2026-08-20 — Cross-repo learnings sweep: two gaps closed in
`knowledge/tlelosa-claude-config.md`" (`Claude-Code/docs/session-log.md`).

## Problem

`Claude-Code` is meant to be the cross-project fact cache — its own `CLAUDE.md` says: "Before
ending a task that surfaced a reusable fact ... append it to the matching `knowledge/<topic>.md`."
That instruction only fires for sessions that are *in* `Claude-Code` when they close out. A
session working in `tlelosa-claude-config` or `ai-product-factory` — both of which are opted into
the same DCOE pattern, and both of which routinely surface facts relevant beyond their own repo —
has no equivalent step pointing back at `Claude-Code`.

Two concrete instances surfaced in one sweep on 2026-08-20, both real, both cross-project-relevant,
neither caught until a session was directly asked to go looking:

1. **The `dcoe-roster` `SessionStart` hook's `MODULE_NOT_FOUND` crash** (fixed in
   `tlelosa-claude-config`, commit `4691578`, 2026-08-20) — a plugin-cache-vs-checkout-path bug
   that affects every machine and every project that installs `dcoe-roster`. This is about as
   cross-project as a finding gets, and it sat unrecorded in `Claude-Code/knowledge/` for the same
   day it was fixed, only landing there once a session was asked to sweep for gaps.
2. **PR #22's mechanical bypass of the spec-review gate** (`tlelosa-claude-config`, recorded in
   that repo's own `docs/todo.md` around 2026-08-12) — a `/session-end` instance shipped live
   text that its own counterpart spec was later BLOCKED on by the reviewer agent. This is a
   process-integrity finding about how spec review and shipped commands can drift apart — squarely
   the kind of fact `Claude-Code/knowledge/hub-process.md` exists to hold — and it had been sitting
   only in `tlelosa-claude-config/docs/todo.md` for over a week.

Both instances share the same shape: the finding was real, it was recorded *somewhere*, and the
place it was recorded is not the place a future session would think to look first. This is the
same failure class Hard Rule 11 ("a record is not a control") already names — a lesson was
written down and not installed anywhere it could act on a *different* repo's session — but it is
specifically about **which repo** a record lands in, which Hard Rule 11 doesn't address.

## What

Add a **cross-project relevance check** to the close-out flow of every repo that shares the DCOE
pattern and is not itself `Claude-Code`: at the point a session would normally decide whether a
finding is "reusable" (per that repo's own knowledge/reuse-checklist step), also ask **"is this
relevant beyond this repo?"** — and if yes, land it in `Claude-Code/knowledge/` (with an
`INDEX.md` update) in the same session, not deferred to a later sweep.

"Relevant beyond this repo" means: a plugin/tooling bug that would affect any project installing
the same shared core or plugin, a process/governance finding about how DCOE mechanics behave in
practice (spec review, session-end conventions, staleness checks), or a decision that changes
something universal (a CORE.md rule, a `hub-template/` file). A project-local fact (a bug in that
project's own application code, a decision scoped to that project's own roadmap) stays local —
this check is a filter, not a mandate to duplicate everything everywhere.

## Mechanics

**Where this lands, per repo:**

- **`hub-template/session-end.md`** (vault-agnostic skeleton, ADR-008 promotion path) — add a new
  step, positioned next to wherever the template's own knowledge-cache guidance already lives, or
  as a new step if it doesn't have one yet. Wording should be generic ("this vault's cross-project
  cache," not a hardcoded path), since `hub-template/` must stay vault-agnostic.
- **`Claude-Code/.claude/commands/session-end.md`** — no change needed; Step 4 ("Update the
  Knowledge Cache") already covers this repo writing to its own `knowledge/`, which *is* the
  cross-project cache from this repo's own perspective.
- **`tlelosa-claude-config/.claude/commands/session-end.md`** — currently states outright that
  "the `knowledge/` cache step... lives in the `Claude-Code` hub, not here." Add the cross-project
  check as a small addition: before finishing, ask whether anything found this session (a plugin
  bug, a process finding, a spec-review-gate issue) is cross-project-relevant, and if so, write it
  into `Claude-Code/knowledge/<topic>.md` + `INDEX.md` directly — a session working here commonly
  has `Claude-Code` checked out in the same working set (per this file's own Step 1.5 guidance
  about repos a session touches together), so the write is a normal cross-repo commit, not a
  hand-off to another session.
- **`ai-product-factory/.claude/commands/session-end.md`** — Step 4's existing "reusable fact"
  checklist already asks "a new pattern or workflow that other projects could use?" and "a
  cross-cutting bug or limitation discovered?" — both would already catch these cases in principle,
  but the step only writes to `shared-memory/`/`docs/research/` **inside this repo**. Add one line
  clarifying that a "yes" to either of those two checklist items also means checking whether
  `Claude-Code/knowledge/` is the more discoverable home for it (or an additional one), for the
  same reason as above.

**What "land it" means concretely**, matching `Claude-Code/CLAUDE.md`'s own entry-format
convention: append a dated entry to the matching `knowledge/<topic>.md` (create one if nothing
fits), update that file's row in `knowledge/INDEX.md`, commit and push to `Claude-Code` from
within the same session.

## Enforcement

Same posture as the rest of this repo's process rules — no automated gate, self-monitored:

1. **At close-out time**, the new/amended step asks the relevance question explicitly rather than
   leaving it implicit — the gap this spec fixes is exactly that the question was never asked in
   `tlelosa-claude-config`'s or `ai-product-factory`'s own close-out flow.
2. **At review time**, a `reviewer` agent auditing a session that fixed a plugin/tooling bug or
   found a process gap can ask whether the cross-project check was run, the same way it already
   checks other close-out steps.
3. **`/retro`'s Step 2** (in `Claude-Code`) already scans session-log entries for cross-repo
   staleness; a future run can specifically check whether a cross-project-relevant fact recorded
   in another repo's `docs/todo.md`/`docs/session-log.md` has a corresponding `Claude-Code/
   knowledge/` entry, and flag the gap if not — this spec's fix is what gives that future check
   something to point at other than "still missing."

## Impact

**Structural, but no CORE version bump** — this changes `hub-template/session-end.md` and two
repos' own command-file instances, not `CORE.md` itself. Distribution follows the existing
file-copy path (ADR-008): fix in `hub-template/` first, then re-copy into each opted-in vault's
own `.claude/commands/session-end.md` — copying doesn't propagate automatically, per this repo's
own documented tradeoff.

**Touches:** `hub-template/session-end.md`, `tlelosa-claude-config/.claude/commands/
session-end.md`, `ai-product-factory/.claude/commands/session-end.md`. No change needed to
`Claude-Code/.claude/commands/session-end.md` (already correct from its own side) or to
`dcoe-roster/CORE.md`.

**No code changes needed** beyond the command-file text itself — same as Hard Rule 11, this is a
discipline addition, not a hook or automation.

## Related

- Hard Rule 11 ("a record is not a control," CORE 1.6 → 1.7) — the general form of this problem
  (a finding recorded but not installed anywhere executable); this spec is the *which-repo*
  special case of it.
- `session-end.md` Step 1.5 ("Can This Session's Work Be Found?", both `Claude-Code`'s and
  `tlelosa-claude-config`'s instances) — the existing precedent for "check every repo this session
  touched, not just the one you're sitting in," which this spec applies to knowledge-cache writes
  specifically rather than PR/branch reachability.
- `Claude-Code/knowledge/claude-code-plugin-hooks.md` and `knowledge/tlelosa-claude-config.md` —
  where the two 2026-08-20 findings that motivated this spec eventually landed, four to eight
  days after they were found.
