# Spec — Cross-project knowledge-cache check in close-out commands

**Date:** 2026-08-20 | **Status:** Approved with nits (reviewer pass, 2026-08-20, third pass — two
prior BLOCKs resolved) — ready for implementation. Five nits from the third pass (a
branch-vs-`main` timing clause, a missing negative report-line option, a pull-before-write guard
on the cross-repo `knowledge/INDEX.md` write in all three proposed texts, and two wording nits)
folded into this revision; no further re-review required.
**Basis:** `Claude-Code`'s second `/retro` run (2026-08-20), item 3 of 3 selected. Evidence:
session-log entry "2026-08-20 — Cross-repo learnings sweep: two gaps closed in
`knowledge/tlelosa-claude-config.md`" (`Claude-Code/docs/session-log.md`).

**Revision note:** the first draft of this spec was BLOCKED — it proposed no actual text for any
of the three files it changes, misstated the current state of `hub-template/session-end.md`
(which already has knowledge-cache guidance; the gap is narrower than the draft claimed), cited a
knowledge-cache file at the wrong path, and its own two-instance evidence was internally
inconsistent on timing. This revision quotes exact current/proposed text per file, corrects the
`hub-template/session-end.md` claim, and fixes the citation.

**Second revision note (after a second BLOCK, same day):** the re-review found the rewritten
timing claim ("~8 days, 2026-08-12 → 2026-08-20") was itself wrong — verified against
`tlelosa-claude-config`'s own commit history below, the correct figure is 4 days
(2026-08-16 → 2026-08-20) — and that the proposed text told `/session-end` to commit and push,
contradicting an explicit prohibition already stated in all three files it edits. Both fixed in
this revision: the Problem section's timing now cites the exact commits, and every proposed
sentence that mentions writing to `Claude-Code/knowledge/` now separates "write the entry now"
from "commit/push only on this turn's explicit confirmation," matching Step 1's existing rule in
every file this spec touches.

## Problem

`Claude-Code` is meant to be the cross-project fact cache — its own `CLAUDE.md` says: "Before
ending a task that surfaced a reusable fact ... append it to the matching `knowledge/<topic>.md`."
That instruction only fires for sessions that are *in* `Claude-Code` when they close out. A
session working in `tlelosa-claude-config` or `ai-product-factory` — both opted into the same DCOE
pattern, both routinely surfacing facts relevant beyond their own repo — has no equivalent step
pointing back at `Claude-Code`.

**Primary instance, and the one this spec is built on:** PR #22's mechanical bypass of the
spec-review gate (`tlelosa-claude-config`) — a `/session-end` instance shipped live text into all
three `/session-end` copies before its own counterpart spec (the SHA-citation requirement) had
been reviewed; the reviewer had BLOCKED that spec on 2026-08-12. The bypass was found and reverted
the same day it was noticed, **2026-08-16** — `tlelosa-claude-config/docs/todo.md` was updated
that day (commit `94c9351`, on PR #22's branch; it reached `main` with the PR's own merge,
`55f1cfb`, 2026-08-17) and `Claude-Code`'s copy of the flawed text was reverted the same day
(`02462dd`, 82 seconds after `94c9351`). **This repo's own `docs/todo.md` entry for this item is
itself stale on this exact point** — it reads "Reverted on merge (**2026-08-12**)", but
`2026-08-12` is when `cfb4767` first authored the flawed SHA-citation text (the spec that later got
BLOCKED), not when it was reverted; the revert commits are both dated `2026-08-16`, four days
later. Left uncorrected here deliberately — fixing that line is outside this spec's own scope,
but it's the same "record asserting something git doesn't back up" pattern this spec exists to
close, one level up. This is a process-integrity finding about spec review and shipped commands
drifting
apart — squarely the kind of fact `Claude-Code/knowledge/hub-process.md` or
`knowledge/tlelosa-claude-config.md` exists to hold. It sat recorded only in
`tlelosa-claude-config/docs/todo.md` and in `Claude-Code`'s own revert-commit message — not yet in
`Claude-Code/knowledge/`, where this hub's own `CLAUDE.md` says a reusable fact belongs — until
**2026-08-20** (`Claude-Code` commit `4659aeb`), when a session working in `Claude-Code` was asked
to sweep for cross-repo gaps and wrote it up. **Four days** (2026-08-16 → 2026-08-20), not the
eight this spec's first revision claimed — corrected here after a second reviewer pass verified
the dates directly against `git log` rather than against this spec's own earlier prose, which is
exactly the discipline Hard Rule 10 (and the fetch-verification spec alongside this one) exists to
enforce.

**Second instance, weaker evidence, kept for context rather than as independent support:** the
`dcoe-roster` `SessionStart` hook's `MODULE_NOT_FOUND` crash (fixed in `tlelosa-claude-config`,
commit `4691578`, 2026-08-20T15:44 UTC) landed in `Claude-Code/knowledge/tlelosa-claude-config.md`
the same day, in the same `4659aeb` commit (2026-08-20T16:27 UTC) — well under a day, not a gap by
the letter of "landed late." What it does demonstrate: it only landed that promptly *because* the
same cross-repo sweep session happened to be running that afternoon, not because the fixing
session (in `tlelosa-claude-config`) itself had any step prompting the cross-repo write. Had the
sweep not been requested, this is the same multi-day gap as the PR #22 instance, just not yet
manifested. Both instances point at the same missing step; only PR #22 proves it as elapsed time.

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

Four files are in scope. Three get a specific text addition, quoted in full below; one
(`Claude-Code`'s own instance, §4) needs no change.

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
> `Claude-Code` hub's cross-project `knowledge/` cache — `git fetch` + pull `Claude-Code` first
> (its own Hard Rule 6 names `knowledge/INDEX.md` as a contention file other concurrent sessions
> write too), then write a dated entry to the matching `knowledge/<topic>.md` and update
> `knowledge/INDEX.md` now, in this session, if `Claude-Code` is
> checked out alongside this vault, rather than deferring to a later sweep. **Committing and
> pushing that write follows the same rule as everything else in this command: only on this
> session's explicit confirmation this turn, never automatically because this step ran.** If
> `Claude-Code` isn't checked out this session, file a queue item in this vault naming the exact
> fact and the target `knowledge/<topic>.md` file instead — per Hard Rule 11, a queue item naming
> the exact change still discharges the obligation.

Wording stays vault-agnostic (references "the `Claude-Code` hub" by name, since that hub — not a
generic placeholder — is the actual, singular cross-project cache every vault in this ecosystem
shares; `hub-template/`'s own precedent already names concrete tools like `set_session_title` by
name where genuinely universal, so naming a real shared resource here is consistent).

### 2. `tlelosa-claude-config/.claude/commands/session-end.md` — add the check where it currently disclaims it

Current text (file header, lines 7–10):

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
> process/governance finding (a spec-review-gate miss, a session-mechanics bug)? If yes, `git
> fetch` + pull `Claude-Code` first (its Hard Rule 6 names `knowledge/INDEX.md` as a contention
> file), then write a dated entry to `Claude-Code/knowledge/<topic>.md` (+ `INDEX.md`) in this same
> session — a session working here commonly has `Claude-Code` checked out alongside this repo (see
> Step 1.5 above), so this is a normal cross-repo write, not a hand-off. **Committing and pushing
> that write follows Step 1's existing rule: only on explicit confirmation this turn, never
> automatically because this step ran.** If `Claude-Code` isn't checked out this session, file a
> `docs/todo.md` item
> naming the exact fact and pointing at the target `knowledge/<topic>.md` file instead — per Hard
> Rule 11, a queue item naming the exact change still discharges the obligation.

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
> this repo (a bug in a shared plugin/core, a process finding about DCOE mechanics) — if so, `git
> fetch` + pull `Claude-Code` first (its Hard Rule 6 names `knowledge/INDEX.md` as a contention
> file other concurrent sessions also write), then write a dated entry to the `Claude-Code` hub's
> `knowledge/<topic>.md` (+ `INDEX.md`) now, in this session, if `Claude-Code` is checked out
> alongside this repo, or as a `docs/todo.md` item naming the exact target file if it isn't.
> **Commit/push that write only on this session's explicit
> confirmation** — same rule as this repo's own `/session-end` convention (per
> `ai-product-factory/CLAUDE.md`'s session-commands line: "Never commit/push without explicit
> confirmation"), never automatically because this step ran.

### 4. `Claude-Code/.claude/commands/session-end.md` — no change

Step 4 ("Update the Knowledge Cache (Hard Rule 5)") already covers this repo writing to its own
`knowledge/`, which *is* the cross-project cache from this repo's own side. Confirmed unchanged.

**Copy-drift note:** `Claude-Code`'s instance is itself a derivative of `hub-template/session-end.md`
(same promotion path as the other two). The new §1 sentence, once copied into a vault, tells the
reader to write to "the `Claude-Code` hub's cross-project `knowledge/` cache" — self-referential if
copied verbatim into `Claude-Code` itself. **When `hub-template/session-end.md` is next re-copied
into `Claude-Code`'s own instance, the new §1 sentence is deliberately dropped**, since that repo's
own Step 4 already covers the same write from the inside. This is a one-line note for whoever does
that future re-copy, not a change to either file today.

### Report-line additions (all three edited files)

Each file's close-out report template needs a line for this new check's outcome, or the check's
result is unreported and "silence and never-ran look identical" — the same failure both
`hub-template/session-end.md` and this repo's own instance already warn about for other steps.

- **`hub-template/session-end.md`** Step 4 report block — extend the existing `**Logged:**` line
  from `[docs/todo.md updated | + session-log.md entry added | + knowledge/<topic>.md updated]` to
  `[docs/todo.md updated | + session-log.md entry added | + knowledge/<topic>.md updated | +
  Claude-Code/knowledge/<topic>.md updated (cross-project) | cross-project: none this session]` —
  the negative option matters here as much as in §2's proposal below: this file's own Step 1.5
  already says "report a pass in one line too — silence and never-ran look identical," and
  omitting the negative case here would contradict that in the file that gets copied everywhere.
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
for cross-project/knowledge-cache language returns one hit — Hard Rule 11's applicability list at
`CORE.md:237`, which names "knowledge-cache entries" as one of the things a record-without-a-control
can be, but doesn't itself establish a cross-project convention — so no CORE change or version bump
is needed). Distribution follows the
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
- `Claude-Code/knowledge/tlelosa-claude-config.md` — where both findings that motivated this spec
  actually landed, both on 2026-08-20 (not `knowledge/claude-code-plugin-hooks.md`, which doesn't exist in
  `Claude-Code`'s own `knowledge/`; that filename belongs to `ai-product-factory/knowledge/`, a
  different repo's local cache holding its own copy of the same finding).
- **Follow-up, out of scope here:** `ai-product-factory/.claude/commands/session-end.md` Step 4
  doesn't mention that repo's own `knowledge/` folder at all, only `shared-memory/`/`docs/research/`
  — a pre-existing gap this spec's revision found but doesn't fix, since it's a same-repo
  omission, not a cross-project one.
- **Follow-up, out of scope here:** `/retro`'s Step 2 (`Claude-Code/.claude/commands/retro.md`)
  could specifically check for cross-repo-relevant facts sitting un-mirrored in another repo's
  queue, once this spec gives it something to check against.
- **Follow-up, out of scope here:** `docs/todo.md`'s own "Require a Done entry to cite a SHA on
  `main`" item (the PR #22 entry) says "Reverted on merge (2026-08-12)" — that date is the flawed
  text's original authorship (`cfb4767`), not the revert, which happened `2026-08-16`
  (`94c9351`/`02462dd`). Found while dating this spec's own evidence; not corrected here since it's
  a one-line todo.md fix unrelated to the close-out commands this spec changes.
