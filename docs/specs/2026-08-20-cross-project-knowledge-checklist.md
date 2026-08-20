# Spec — Cross-project knowledge-cache check in close-out commands

**Date:** 2026-08-20 | **Status:** Draft (revised after reviewer BLOCK, 2026-08-20) — awaiting
re-review before implementation
**Basis:** `Claude-Code`'s second `/retro` run (2026-08-20), item 3 of 3 selected. Evidence:
session-log entry "2026-08-20 — Cross-repo learnings sweep: two gaps closed in
`knowledge/tlelosa-claude-config.md`" (`Claude-Code/docs/session-log.md`).

**Revision note:** the first draft of this spec was BLOCKED — it proposed no actual text for any
of the three files it changes, misstated the current state of `hub-template/session-end.md`
(which already has knowledge-cache guidance; the gap is narrower than the draft claimed), cited a
knowledge-cache file at the wrong path, and its own two-instance evidence was internally
inconsistent on timing. This revision quotes exact current/proposed text per file, corrects the
`hub-template/session-end.md` claim, fixes the citation, and leads with the single load-bearing
instance rather than two unevenly-supported ones.

## Problem

`Claude-Code` is meant to be the cross-project fact cache — its own `CLAUDE.md` says: "Before
ending a task that surfaced a reusable fact ... append it to the matching `knowledge/<topic>.md`."
That instruction only fires for sessions that are *in* `Claude-Code` when they close out. A
session working in `tlelosa-claude-config` or `ai-product-factory` — both opted into the same DCOE
pattern, both routinely surfacing facts relevant beyond their own repo — has no equivalent step
pointing back at `Claude-Code`.

**Primary instance, and the one this spec is built on:** PR #22's mechanical bypass of the
spec-review gate (`tlelosa-claude-config`, recorded in that repo's own `docs/todo.md` around
2026-08-12) — a `/session-end` instance shipped live text into all three `/session-end` copies
before its own counterpart spec (the SHA-citation requirement) had been reviewed; the reviewer
subsequently BLOCKED that spec. This is a process-integrity finding about spec review and shipped
commands drifting apart — squarely the kind of fact `Claude-Code/knowledge/hub-process.md` or
`knowledge/tlelosa-claude-config.md` exists to hold. It sat only in
`tlelosa-claude-config/docs/todo.md`, unrecorded in `Claude-Code/knowledge/`, for roughly eight
days (2026-08-12 → 2026-08-20) — until a session working in `Claude-Code` was directly asked to
sweep for cross-repo gaps and found it.

**Second instance, weaker evidence, kept for context rather than as independent support:** the
`dcoe-roster` `SessionStart` hook's `MODULE_NOT_FOUND` crash (fixed in `tlelosa-claude-config`,
commit `4691578`, 2026-08-20) landed in `Claude-Code/knowledge/tlelosa-claude-config.md` the same
day it was fixed — zero days, not a gap by the letter of "landed late." What it does demonstrate:
it only landed there *because* the same cross-repo sweep session happened to be running that day,
not because the fixing session (in `tlelosa-claude-config`) itself had any step prompting the
cross-repo write. Had the sweep not been requested that day, this is the same eight-day-plus gap
as PR #22, just not yet manifested. Both instances point at the same missing step; only PR #22
proves it as elapsed time.

Both instances share the same shape: the finding was real, it was recorded *somewhere*, and the
place it was recorded is not the place a future session would think to look first. This is the
same failure class Hard Rule 11 ("a record is not a control") already names — a lesson was written
down and not installed anywhere it could act on a *different* repo's session — but it is
specifically about **which repo** a record lands in, which Hard Rule 11 doesn't address.

## What

Add a **cross-project relevance check** to the close-out flow of every repo that shares the DCOE
pattern and is not itself `Claude-Code`: at the point a session already decides whether a finding
is "reusable" (each repo's own knowledge/reuse-checklist step, see Mechanics below), also ask
**"is this relevant beyond this repo?"** — and if yes, land it in `Claude-Code/knowledge/` (with
an `INDEX.md` update) in the same session, not deferred to a later sweep.

"Relevant beyond this repo" means: a plugin/tooling bug that would affect any project installing
the same shared core or plugin, a process/governance finding about how DCOE mechanics behave in
practice (spec review, session-end conventions, staleness checks), or a decision that changes
something universal (a `CORE.md` rule, a `hub-template/` file). A project-local fact (a bug in
that project's own application code, a decision scoped to that project's own roadmap) stays local
— this check is a filter, not a mandate to duplicate everything everywhere.

## Mechanics

Four files are in scope. Two need no change; two get a specific text addition, quoted in full
below.

### 1. `hub-template/session-end.md` — **narrower change than the first draft claimed**

This file is **not** missing knowledge-cache guidance — Step 2 (lines 111–118) already has it:

> If this vault keeps a topic-keyed knowledge cache (check `CLAUDE.md` for a `knowledge/`
> convention) and this session surfaced a reusable fact — a config quirk, a decision, an API
> behavior, something that would otherwise get re-derived next time — append it to the matching
> `knowledge/<topic>.md` and update its `knowledge/INDEX.md` row now, not as an afterthought
> later. Ask explicitly, even if the answer is no: **did this session surface a reusable fact not
> yet in `knowledge/`?** If yes, capture it now before closing out.

What's missing is the cross-project half. **Extend this same paragraph** (do not add a new step —
this is one decision, not two) with one more sentence immediately after the existing "capture it
now before closing out":

> Then ask a second, separate question: **is this fact relevant beyond this vault** — a bug or
> gap in a shared plugin/core (`dcoe-roster`, `CORE.md`, `hub-template/`), or a process/governance
> finding about how DCOE mechanics behave in practice? If yes, it also belongs in the
> `Claude-Code` hub's cross-project `knowledge/` cache (append a dated entry to the matching
> `knowledge/<topic>.md`, update `knowledge/INDEX.md`), committed and pushed from this session if
> `Claude-Code` is checked out alongside this vault — not deferred to a later sweep.

Wording stays vault-agnostic (references "the `Claude-Code` hub" by name, since that hub — not a
generic placeholder — is the actual, singular cross-project cache every vault in this ecosystem
shares; `hub-template/`'s own precedent already names concrete tools like `set_session_title` by
name where genuinely universal, so naming a real shared resource here is consistent).

### 2. `tlelosa-claude-config/.claude/commands/session-end.md` — add the check where it currently disclaims it

Current text (file header, lines 8–10):

> Minimal adaptation of `hub-template/session-end.md` for this repo itself. The `session-log.md`
> step is omitted (this repo keeps no session log, same as `.claude/commands/continue.md`'s local
> copy), as is the `knowledge/` cache step (that lives in the `Claude-Code` hub, not here).

Proposed replacement:

> Minimal adaptation of `hub-template/session-end.md` for this repo itself. The `session-log.md`
> step is omitted (this repo keeps no session log, same as `.claude/commands/continue.md`'s local
> copy). The local `knowledge/` cache step is also omitted (that cache lives in the `Claude-Code`
> hub, not here) — but Step 2 below still checks whether this session's finding belongs there.

And in **Step 2** (currently ends at "Leave untouched items alone — this reconciles, it doesn't
re-audit the whole backlog." before the SHA-citation note), add a new paragraph:

> Before finishing, ask: **did this session find something relevant beyond this repo** — a bug or
> gap in a plugin/core this repo ships (`dcoe-roster`, `CORE.md`, `agent-bodies-reference/`), or a
> process/governance finding (a spec-review-gate miss, a session-mechanics bug)? If yes, land it
> in `Claude-Code/knowledge/<topic>.md` (+ `INDEX.md`) in this same session — a session working
> here commonly has `Claude-Code` checked out alongside this repo (see Step 1.5 above), so this is
> a normal cross-repo commit, not a hand-off. If `Claude-Code` isn't checked out this session, file
> a `docs/todo.md` item naming the exact fact and pointing at the target `knowledge/<topic>.md`
> file instead — per Hard Rule 11, a queue item naming the exact change still discharges the
> obligation.

### 3. `ai-product-factory/.claude/commands/session-end.md` — clarify Step 4's existing checklist

Current text (Step 4, in full):

> Check whether the session surfaced a reusable fact worth capturing:
>
> **Reusable fact checklist:**
> - [ ] A new pattern or workflow that other projects could use?
> - [ ] A decision made (should go in `docs/decisions/` as an ADR)?
> - [ ] A cross-cutting bug or limitation discovered?
> - [ ] Architecture or design insight not yet documented?
> - [ ] A vendor/dependency observation or version note?
>
> If **yes** to any above, update or create a file in `shared-memory/` or `docs/research/`:
> - One topic per file, most recent entry first
> - Link related entries with `[[file-name]]`
> - Date all entries
>
> If **no**, that's fine — most sessions don't surface new learnings.

**Note, separate from this spec's own scope:** this repo's own `CLAUDE.md` directory map also
declares a `knowledge/` folder ("one topic = one file, dated entries"), and it is in active use
(`knowledge/claude-code-plugin-hooks.md` is where the hook-crash finding actually landed) — but
Step 4 above never mentions it, only `shared-memory/`/`docs/research/`. That's a pre-existing gap
in this file, not something this spec introduces, and not fixed here (out of scope — flagged in
Related below as a follow-up).

Proposed addition, appended after the existing "If **yes** to any above..." bullet list, before
"If **no**...":

> A "yes" to **"A new pattern or workflow that other projects could use?"** or **"A cross-cutting
> bug or limitation discovered?"** specifically also means checking whether it's relevant beyond
> this repo (a bug in a shared plugin/core, a process finding about DCOE mechanics) — if so, also
> land it in the `Claude-Code` hub's `knowledge/<topic>.md` (+ `INDEX.md`), committed from this
> session if `Claude-Code` is checked out alongside this repo, or as a `docs/todo.md` item naming
> the exact target file if it isn't.

### 4. `Claude-Code/.claude/commands/session-end.md` — no change

Step 4 ("Update the Knowledge Cache (Hard Rule 5)") already covers this repo writing to its own
`knowledge/`, which *is* the cross-project cache from this repo's own side. Confirmed unchanged.

### Report-line additions (all three edited files)

Each file's close-out report template needs a line for this new check's outcome, or the check's
result is unreported and "silence and never-ran look identical" — the same failure both
`hub-template/session-end.md` and this repo's own instance already warn about for other steps.

- **`hub-template/session-end.md`** Step 4 report block — extend the existing `**Logged:**` line
  from `[docs/todo.md updated | + session-log.md entry added | + knowledge/<topic>.md updated]` to
  `[docs/todo.md updated | + session-log.md entry added | + knowledge/<topic>.md updated | +
  Claude-Code/knowledge/<topic>.md updated (cross-project)]`.
- **`tlelosa-claude-config/.claude/commands/session-end.md`** Step 4 report block — extend
  `**Logged:** [docs/todo.md updated]` to `[docs/todo.md updated | + Claude-Code/knowledge/<topic>.md
  updated (cross-project) | cross-project: none this session]`.
- **`ai-product-factory/.claude/commands/session-end.md`** Step 6 report block — extend
  `**Knowledge cache:** [Updated | No updates needed]` to `[Updated (local) | Updated (local +
  Claude-Code cross-project) | No updates needed]`.

## Enforcement

Same posture as the rest of this repo's process rules — no automated gate, self-monitored:

1. **At close-out time**, the amended step asks the relevance question explicitly rather than
   leaving it implicit — the gap this spec fixes is exactly that the question was never asked in
   `tlelosa-claude-config`'s or `ai-product-factory`'s own close-out flow.
2. **At review time**, a `reviewer` agent auditing a session that fixed a plugin/tooling bug or
   found a process gap can ask whether the cross-project check was run and reported, the same way
   it already checks other close-out steps.
3. **`/retro`'s Step 2** (in `Claude-Code`) scans for stale or wrong external-state assertions; it
   does not yet specifically check for a cross-repo-relevant fact sitting in another repo's
   `docs/todo.md`/`docs/session-log.md` with no corresponding `Claude-Code/knowledge/` entry. That
   remains a gap after this spec — flagged as a follow-up in Related, not solved here, since it
   would change `retro.md` itself and this spec is scoped to the three `session-end.md` files.

## Impact

**Structural, but no CORE version bump** — this changes `hub-template/session-end.md` and two
repos' own command-file instances, not `CORE.md` itself (confirmed: grepping `dcoe-roster/CORE.md`
for cross-project/knowledge-cache language returns no relevant hits). Distribution follows the
existing file-copy path (ADR-008): fix in `hub-template/` first, then re-copy into each opted-in
vault's own `.claude/commands/session-end.md` — copying doesn't propagate automatically, per this
repo's own documented tradeoff.

**Touches:** `hub-template/session-end.md` (Step 2 paragraph + Step 4 report line),
`tlelosa-claude-config/.claude/commands/session-end.md` (header note + Step 2 addition + Step 4
report line), `ai-product-factory/.claude/commands/session-end.md` (Step 4 addition + Step 6
report line). No change to `Claude-Code/.claude/commands/session-end.md` or to `dcoe-roster/CORE.md`.

**No code changes needed** beyond the command-file text itself — same as Hard Rule 11, this is a
discipline addition, not a hook or automation.

## Related

- Hard Rule 11 ("a record is not a control," CORE 1.6 → 1.7) — the general form of this problem
  (a finding recorded but not installed anywhere executable); this spec is the *which-repo* special
  case of it.
- `session-end.md` Step 1.5 ("Can This Session's Work Be Found?", both `Claude-Code`'s and
  `tlelosa-claude-config`'s instances) — the existing precedent for "check every repo this session
  touched, not just the one you're sitting in," which this spec applies to knowledge-cache writes
  specifically rather than PR/branch reachability.
- `Claude-Code/knowledge/tlelosa-claude-config.md` — where both 2026-08-20 findings that motivated
  this spec actually landed (not `knowledge/claude-code-plugin-hooks.md`, which doesn't exist in
  `Claude-Code`'s own `knowledge/`; that filename belongs to `ai-product-factory/knowledge/`, a
  different repo's local cache holding its own copy of the same finding).
- **Follow-up, out of scope here:** `ai-product-factory/.claude/commands/session-end.md` Step 4
  doesn't mention that repo's own `knowledge/` folder at all, only `shared-memory/`/`docs/research/`
  — a pre-existing gap this spec's revision found but doesn't fix, since it's a same-repo
  omission, not a cross-project one.
- **Follow-up, out of scope here:** `/retro`'s Step 2 (`Claude-Code/.claude/commands/retro.md`)
  could specifically check for cross-repo-relevant facts sitting un-mirrored in another repo's
  queue, once this spec gives it something to check against.
