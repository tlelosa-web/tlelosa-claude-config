# Spec — Cross-project knowledge-cache check in close-out commands

**Date:** 2026-08-20 | **Status:** Eighth revision — addresses the seventh pass's reviewer BLOCK.
Not self-certified: needs an eighth reviewer pass before dispatch.
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

**Fourth revision note (cross-checked against `Claude-Code/knowledge/` before dispatch, no
reviewer BLOCK involved):** the third pass approved the mechanics as sound but was reviewed on
their own terms, not against this hub's own recorded incidents about editing this exact class of
file. Two of those incidents apply directly and were folded into §1–§3's proposed text at the
time: `Claude-Code/knowledge/hub-process.md`'s 2026-08-07 entry ("Contention-file discipline needs
a re-check immediately before writing") and `Claude-Code/knowledge/cloud-sessions.md`'s 2026-08-12
entry (a cloud container whose `HEAD` and cached `origin/main` both matched a stale SHA while the
real remote was 13 commits ahead — so `HEAD..origin/main` read `0` and looked current when it
wasn't). A third addition came from `Claude-Code/knowledge/tlelosa-claude-config.md`'s 2026-08-16
entry (PR #22 shipping a still-BLOCKED spec's text into these same three files).

**Fifth revision note (addressed the fourth pass's reviewer BLOCK):** re-baselined §1–§3 against
the live files after confirming the third-pass text (including all report-line additions) was
already shipped in all three; added `-C <Claude-Code path>` to every git command; replaced the
undefined "abort and fall back" with pull-recheck-proceed; bound the freshness re-check to the
commit rather than only the write; chained fetch-and-count with `&&`; reworded §3 to a numbered
list matching its host file's checklist style. That pass was itself BLOCKed on five further
points, detailed and fixed below.

**Sixth revision note (this pass — addresses the fifth pass's reviewer BLOCK):** the reviewer
independently re-verified the fifth revision's "Currently live" quotes against the files on disk
(confirming §1's quote and all three report-line citations were accurate) before finding four
further problems, all confirmed directly against the live files before this revision:

1. **§3's replacement text opened with a dangling reference.** "A 'yes' to either of those two
   checklist items" had no antecedent once the live trigger's explicit naming of both items was
   dropped — the host file's checklist has five items, not two, and nothing nearby says which two.
   Fixed by restating both checklist items by name, as the live text already does, rather than
   compressing them into an unresolvable "those two."
2. **§2 and §3 asserted "no change proposed" to the exact paragraphs their own replacement text
   replaces, and neither carried a verbatim "Currently live" quote** — the most drift-prone
   possible anchor (bare line numbers) in the two sections most likely to see those numbers shift.
   This was the B1 failure mode re-armed. Fixed: both now open with a verbatim "Currently live"
   quote block, matching §1's structure, and the surrounding prose no longer claims the replaced
   paragraph is out of scope.
3. **The commit-time re-check had no carrier — it was prose inside a step that finishes before the
   deferred commit ever happens, with no report line and no state naming it.** This is a genuine
   design gap, not a wording one: the previous revision said the check "re-runs immediately before
   the commit," but nothing in the file makes that true if the commit lands turns later, and its
   failure branch (fall back to "file a queue item... instead of writing") made no sense once the
   write had already happened. **Redesigned rather than reworded:** the freshness check is no
   longer a separate step to remember — it is folded directly into the literal git command this
   revision now gives verbatim for the deferred commit itself, so running that command *is* running
   the check ("the same command as the commit," per `hub-process.md`'s own prescription, applied
   literally rather than described). The write step's report is required to state the write is
   pending and to carry that exact command forward; a new report-line option (below) gives it a
   place to land instead of dissolving into unstated prose. The failure branch is now a single
   `||` clause on the same command — pull, re-apply the entry if the pull conflicts with it, retry
   — never a detour through the pre-write queue-item path, which is reserved for the case where
   `Claude-Code` was never checked out at all.
4. **Two citation errors, found while re-verifying everything else:** the Impact section cited
   `CORE.md:237` and "one hit" for cross-project/knowledge-cache language; re-grepped directly
   (`grep -n "cross-project\|knowledge-cache" dcoe-roster/CORE.md`) returns three hits (`:70`,
   `:73`, `:248`), and the knowledge-cache-entries phrase this section actually means is at `:248`
   (inside Hard Rule 11), not `:237` (Hard Rule 10 territory). And the Fifth revision note's own
   `hub-template/session-end.md` line range for the cross-project paragraph was `111–134`; the
   actual paragraph is `120–135` (`111–118` is the separate, adjacent local-knowledge-cache
   paragraph). Both corrected below and in the citations that reference them.

Also folded in, not separately blocking: the `Claude-Code`'s-Hard-Rule-6 qualifier (dropped to bare
"Hard Rule 6" in the fifth revision, which resolves wrongly against `ai-product-factory`'s own
Hard Rule 6 and ambiguously in vault-agnostic `hub-template`) is restored at every site; §3 is
aligned with §1/§2's wording (it had silently dropped the "re-run the check before writing" clause
after the pull); Enforcement item 4's three verification commands no longer assume three different
implicit working directories — each now names its own repo root explicitly rather than a bare
relative folder name; and a one-sentence `main`-branch confirmation is added to all three sections,
since the freshness check and pull both silently assumed `Claude-Code`'s checkout was on `main`.

**Seventh revision note (this pass — addresses the sixth pass's reviewer BLOCK):** the reviewer
confirmed everything the sixth revision fixed genuinely holds (all three "Currently live" quotes,
the CORE.md citation, the carrier mechanism's soundness in principle) before finding four further
blockers, all in the command's content rather than its design:

1. **A non-`main` checkout was only "noted," not handled — a silent-success path.** `push origin
   main` pushes the local `main` branch regardless of what's checked out, so on a non-`main`
   `Claude-Code` HEAD the chain reports success while nothing reaches the remote, and the auto-pull
   merges `main` into an unrelated branch nobody asked to touch. **Fixed by making `HEAD == main`
   a hard precondition, checked alongside "is `Claude-Code` checked out at all"** — either one
   failing routes to the exact same, already-defined queue-item fallback, rather than "note it and
   proceed." This removes the ambiguous case entirely instead of handling it.
2. **The single `||` catch-all misdiagnosed most of its own failure modes.** A failed fetch, an
   auth failure, a rejected hook, and a genuine staleness case all printed the same "Claude-Code
   moved since the write" message — which is only true for one of them, and is the exact message
   the `&&`-chaining two paragraphs earlier was written to prevent. **Redesigned as three explicit,
   mutually exclusive branches**, each naming its own cause: fetch failure (diagnose the remote,
   don't commit), genuine staleness (pull and retry, with the actual commit count), or a
   commit/push failure *after* a verified-fresh fetch (told explicitly this is not a staleness
   issue, read the real error). This is the same pattern the fifth revision hit on the pre-write
   fallback and the sixth relocated rather than removed — fixed this time by eliminating the
   catch-all rather than moving it again.
3. **`<msg-file>` was an unexplained placeholder an Executor would have to guess at.** One sentence
   added at each use: write a one-line commit message to a scratch file first, with a concrete
   example message.
4. **§1 and §2 pointed the "state this in the report" instruction at "this step's report," but the
   paragraph being replaced is in Step 2, which has no report block in either file** — only Step 4
   does. §3 already named "Step 6" correctly; §1/§2 now say "Step 4's report" explicitly, matching
   it.

Also fixed, from the sixth pass's warnings: the Problem section's claim that `docs/todo.md`'s
revert-date line was "left uncorrected here deliberately" was itself stale — that line has since
been corrected in `docs/todo.md` (verified live) — reworded to say so, and the now-redundant
Related follow-up bullet describing it as still-open was corrected rather than repeated. The
`cloud-sessions.md` citations describing the 2026-08-12 incident had the direction backwards ("13
commits behind" implied the fetch ran and found nothing current; the actual incident is that the
fetch never ran and the cached ref was stale) — reworded in both places it appeared. The shell
block now states its POSIX assumption and names PowerShell as the translation target on a machine
without git-bash on `PATH`. And the report-line additions' "(command given above)" — ambiguous
once a block spans multiple steps — now names the step explicitly in all three files.

**Eighth revision note (this pass — addresses the seventh pass's reviewer BLOCK):** the reviewer
confirmed every fix from the seventh revision held and, for the first time across eight passes,
found **no new citation error** in the revision itself — the entire remaining finding was one
design gap, plus warnings on its edges:

1. **The `main`-branch precondition was enforced at the write step but never carried into the
   deferred commit command — the seventh revision's own fix for the *staleness* check (bind it to
   the commit, not a separate step to remember) was not applied to the *branch* check.** Concretely:
   a session writes the entry while `Claude-Code` is on `main`; before confirmation arrives,
   `Claude-Code`'s checkout moves to a feature branch (a live scenario this ecosystem's own Hard
   Rule 6 exists because of); the deferred command's `rev-list --count HEAD..origin/main` reads `0`
   on that branch too, so it commits onto the feature branch and `push origin main` pushes the
   untouched local `main`, reporting "Everything up-to-date" — exit `0`, no error, a cross-project
   write reported as pushed that never reached the remote. **Fixed by making the branch check the
   first clause of the deferred command itself**, not just a write-time precondition: the whole
   fetch/commit sequence in all three sections now sits inside `if [ "$(git -C "<Claude-Code
   path>" rev-parse --abbrev-ref HEAD)" != "main" ]; then echo "no longer on main, stop" … else …
   fi`. This is the third time this spec's failure path has had to be *relocated to its actual
   point of execution* rather than merely reworded (the fifth revision's pre-write fallback, the
   sixth's `||` catch-all, now this) — the fix each time has been the same shape: stop describing
   a check in prose and put it inside the literal command that runs.
2. **(warning) The staleness branch's own prescribed remedy — `pull` — can fail in exactly the
   situation it exists for**, since the knowledge write is still uncommitted when a nonzero count
   is found; if the incoming commits touch `INDEX.md` (the likely reason the count is nonzero at
   all, since it's the named contention file), a plain pull refuses to run. **Fixed** by adding a
   stash → pull → pop sequence, given as prose immediately after each command block rather than
   crammed into the `echo` text.
3. **(warning) The "not a staleness issue" message asserted a cause it couldn't fully rule out** —
   a push rejected as non-fast-forward *is* a staleness case, just one the fetch didn't catch
   because the remote moved in the few seconds after it. **Reworded** to say "most likely not
   staleness" and point at the same stash/pull/pop note for the one case where it actually is.
4. **(warning) Unquoted `<Claude-Code path>` placeholders** would break on a checkout path
   containing a space — this ecosystem has one (`~/Pappa T/`, per `Claude-Code/CLAUDE.md`).
   **Fixed**: every `-C <Claude-Code path>` in all three command blocks and their surrounding
   prose is now `-C "<Claude-Code path>"`, and `<msg-file>` is likewise quoted at both `commit -F`
   uses (it isn't referenced anywhere in the stash/pull/pop note, which only touches the
   `INDEX.md`/topic-file working-tree state, not the not-yet-written commit message).
5. **(warning) An empty `rev-list` result would fall into the staleness branch with a blank
   count**, reading "Claude-Code is  commit(s) behind" — narrow, but named as unhandled last pass.
   **Fixed**: added an explicit `[ -z "$count" ]` branch with its own message, ahead of the
   staleness comparison, in all three sections.

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
(`02462dd`, 82 seconds after `94c9351`). **This repo's own `docs/todo.md` entry for this item was
itself stale on this exact point** — it read "Reverted on merge (**2026-08-12**)", when
`2026-08-12` is when `cfb4767` first authored the flawed SHA-citation text (the spec that later got
BLOCKED), not when it was reverted; the revert commits are both dated `2026-08-16`, four days
later. **Corrected as of this spec's own dating work** — `docs/todo.md` now reads "Reverted
2026-08-16 (`94c9351`/`02462dd`) — not 2026-08-12..." (verified live, not re-cited here since it
is no longer this spec's own open item). Left as a worked example rather than deleted: it's the
same "record asserting something git doesn't back up" pattern this spec exists to close, one
level up, caught and fixed the same way this spec asks every session to catch it. This is a
process-integrity finding about spec review and shipped commands drifting apart — squarely the
kind of fact `Claude-Code/knowledge/hub-process.md` or
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

**Third instance, this spec's own history:** the fourth revision's approved mechanics shipped into
all three target files (per the fifth revision note) independently of this spec's own ongoing
review — the identical shape as PR #22, one level up, on the spec written to fix it.

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

## Mechanics — as of this revision

**All three files already carry the base cross-project-relevance mechanic** (third pass, confirmed
shipped independently by the fourth- and fifth-pass reviewers). What follows is the genuinely
outstanding delta: one paragraph replacement per file, plus one report-line extension per file.
`Claude-Code`'s own instance (§4) needs no change, as before.

### 1. `hub-template/session-end.md`

**Currently live** (Step 2, lines 120–135, the paragraph beginning "Then ask a second, separate
question"):

> Then ask a second, separate question: **is this fact relevant beyond this vault** — a bug or
> gap in a shared plugin/core (`dcoe-roster`, `CORE.md`, `hub-template/`), or a process/governance
> finding about how DCOE mechanics behave in practice? If yes, it also belongs in the
> `Claude-Code` hub's cross-project `knowledge/` cache — `git fetch` + pull `Claude-Code` first
> (its own Hard Rule 6 names `knowledge/INDEX.md` as a contention file other concurrent sessions
> write too), then write a dated entry to the matching `knowledge/<topic>.md` and update
> `knowledge/INDEX.md` now, in this session, if `Claude-Code` is checked out alongside this vault,
> rather than deferring to a later sweep. **Committing and pushing that write follows the same
> rule as everything else in this command: only on this session's explicit confirmation this
> turn, never automatically because this step ran.** If `Claude-Code` isn't checked out this
> session, file a queue item in this vault naming the exact fact and the target
> `knowledge/<topic>.md` file instead — per Hard Rule 11, a queue item naming the exact change
> still discharges the obligation.

**Full replacement text:**

> Then ask a second, separate question: **is this fact relevant beyond this vault** — a bug or
> gap in a shared plugin/core (`dcoe-roster`, `CORE.md`, `hub-template/`), or a process/governance
> finding about how DCOE mechanics behave in practice? If yes, it also belongs in the
> `Claude-Code` hub's cross-project `knowledge/` cache — but only if two preconditions both hold,
> checked in this order:
>
> 1. `Claude-Code` is checked out this session — commonly a sibling directory of this vault's own
>    working directory in a cloud session; check where this session's other repos are checked out
>    if unsure.
> 2. Its checkout is on `main` (`git -C "<Claude-Code path>" rev-parse --abbrev-ref HEAD`).
>
> If either doesn't hold, skip straight to filing a queue item in this vault naming the exact fact
> and the target `knowledge/<topic>.md` file — say which precondition failed if it was the second
> one — per Hard Rule 11, a queue item naming the exact change still discharges the obligation.
>
> If both hold, confirm `Claude-Code` is current before writing: `git -C "<Claude-Code path>" fetch
> origin main --quiet`, checking the fetch's own exit status rather than assuming success (an
> unreachable remote leaves the cached ref stale and gives no other sign of it); only if the fetch
> succeeded, compare `git -C "<Claude-Code path>" rev-list --count HEAD..origin/main` — pull
> (`git -C "<Claude-Code path>" pull origin main`) if nonzero and re-run both checks before
> writing. Then
> write a dated entry to the matching `knowledge/<topic>.md` and update `knowledge/INDEX.md` now,
> in this session, rather than deferring to a later sweep — preferring a surgical edit to
> `INDEX.md`'s one row over rewriting the file, since it is a named `Claude-Code` Hard Rule 6
> contention file other concurrent sessions write too.
>
> **Committing that write is deferred to this session's explicit confirmation, same as everything
> else in this command — but state plainly in Step 4's report that the write is pending, and
> give the exact command that commits it when confirmation comes.** Write a one-line commit
> message to a scratch file first (`<msg-file>` — this session's own scratch/temp location; e.g.
> `knowledge: <short summary> (cross-project write from this vault)` is enough), then use:
>
> ```
> if [ "$(git -C "<Claude-Code path>" rev-parse --abbrev-ref HEAD)" != "main" ]; then
>   echo "Claude-Code is no longer on main — stop, do not commit. Re-check the two preconditions above; if it's still not on main, use the queue-item path instead."
> else
>   git -C "<Claude-Code path>" fetch origin main --quiet
>   if [ $? -ne 0 ]; then
>     echo "Fetch failed — Claude-Code's remote is unreachable or misconfigured; diagnose that before doing anything else. Do not commit."
>   else
>     count="$(git -C "<Claude-Code path>" rev-list --count HEAD..origin/main)"
>     if [ -z "$count" ]; then
>       echo "rev-list produced no output after a successful fetch — investigate directly rather than trusting this command further."
>     elif [ "$count" != "0" ]; then
>       echo "Claude-Code is $count commit(s) behind origin/main — see the pull note below, then retry this command."
>     else
>       git -C "<Claude-Code path>" add knowledge/<topic>.md knowledge/INDEX.md && \
>       git -C "<Claude-Code path>" commit -F "<msg-file>" && \
>       git -C "<Claude-Code path>" push origin main || \
>       echo "Commit or push failed after a fetch that showed Claude-Code current on main — most likely not staleness; read the error above directly (a push rejected as non-fast-forward does mean the remote moved — see the pull note below)."
>     fi
>   fi
> fi
> ```
>
> **If the count is nonzero** the knowledge write is still uncommitted at this point, so a plain
> `pull` can fail with "local changes would be overwritten." Stash it first (`git -C
> "<Claude-Code path>" stash`), pull (`git -C "<Claude-Code path>" pull origin main`), then pop
> (`git -C "<Claude-Code path>" stash pop`) — if the pop itself conflicts, resolve by hand and
> `git -C "<Claude-Code path>" stash drop` once resolved, since a conflicting pop leaves the
> stash entry in place — before retrying the command above.
>
> **If instead the final branch's push is rejected as non-fast-forward**, the write is already
> committed (that branch only runs after `add && commit` succeeded), so there is nothing to stash
> — a plain `git -C "<Claude-Code path>" pull origin main` is enough, then retry the command
> above to push.
>
> Written for a POSIX shell (bash/sh); on a machine without git-bash on `PATH`, translate the same
> three-outcome structure — fetch, check its own exit status, then compare the count — into
> PowerShell rather than assuming this block runs as-is. Each of the three branches names a
> distinct cause instead of one catch-all guess, since an earlier revision of this spec's single
> undifferentiated fallback message was found to misdiagnose most of its own failure modes.
> Deferring the commit like this necessarily widens the race window
> `Claude-Code/knowledge/hub-process.md`'s own source entry warns about (it separately recommends
> committing immediately to shrink that window) — accepted here openly as the cost of this file's
> existing confirmation-gate rule, not silently traded away.

Wording stays vault-agnostic (references "the `Claude-Code` hub" by name, since that hub — not a
generic placeholder — is the actual, singular cross-project cache every vault in this ecosystem
shares; `hub-template/`'s own precedent already names concrete tools like `set_session_title` by
name where genuinely universal, so naming a real shared resource here is consistent).

### 2. `tlelosa-claude-config/.claude/commands/session-end.md`

The header note (lines 7–12) is already live and unchanged by this revision. **Currently live**
(Step 2, lines 64–78, the paragraph this revision replaces):

> Before finishing, ask: **did this session find something relevant beyond this repo** — a bug or
> gap in a plugin/core this repo ships (`dcoe-roster`, `CORE.md`, `agent-bodies-reference/`), or a
> process/governance finding (a spec-review-gate miss, a session-mechanics bug)? If yes, `git
> fetch` + pull `Claude-Code` first (its Hard Rule 6 names `knowledge/INDEX.md` as a contention
> file), then write a dated entry to `Claude-Code/knowledge/<topic>.md` (+ `INDEX.md`) in this
> same session — a session working here commonly has `Claude-Code` checked out alongside this
> repo (see Step 1.5 above), so this is a normal cross-repo write, not a hand-off. **Committing
> and pushing that write follows Step 1's existing rule: only on explicit confirmation this turn,
> never automatically because this step ran.** If `Claude-Code` isn't checked out this session,
> file a `docs/todo.md` item naming the exact fact and pointing at the target
> `knowledge/<topic>.md` file instead — per Hard Rule 11, a queue item naming the exact change
> still discharges the obligation.

**Full replacement text:**

> Before finishing, ask: **did this session find something relevant beyond this repo** — a bug or
> gap in a plugin/core this repo ships (`dcoe-roster`, `CORE.md`, `agent-bodies-reference/`), or a
> process/governance finding (a spec-review-gate miss, a session-mechanics bug)? If yes, it also
> belongs in `Claude-Code`'s cross-project `knowledge/` cache — but only if two preconditions both
> hold, checked in this order:
>
> 1. `Claude-Code` is checked out this session (Step 1.5 above already has this session list
>    every repo it touched — use that).
> 2. Its checkout is on `main` (`git -C "<Claude-Code path>" rev-parse --abbrev-ref HEAD`).
>
> If either doesn't hold, skip straight to filing a `docs/todo.md` item naming the exact fact and
> the target `knowledge/<topic>.md` file — say which precondition failed if it was the second one
> — per Hard Rule 11, a queue item naming the exact change still discharges the obligation.
>
> If both hold, confirm it's current before writing: `git -C "<Claude-Code path>" fetch origin main
> --quiet`, checking the fetch's own exit status before trusting anything derived from it; only if
> it succeeded, compare `git -C "<Claude-Code path>" rev-list --count HEAD..origin/main` — pull
> (`git -C "<Claude-Code path>" pull origin main`) if nonzero and re-run both checks before writing.
> Then write a dated entry to `Claude-Code/knowledge/<topic>.md` (+ `INDEX.md`) in this same
> session — preferring a surgical edit to `INDEX.md`'s one row over rewriting the file, since it's
> a named `Claude-Code` Hard Rule 6 contention file other concurrent sessions also write.
>
> **Committing that write follows Step 1's existing rule — only on explicit confirmation this
> turn, never automatically because this step ran — but state plainly in Step 4's report that
> the write is pending, and give the exact command that commits it when confirmation comes.**
> Write a one-line commit message to a scratch file first (`<msg-file>`; e.g. `knowledge: <short
> summary> (cross-project write from this repo)` is enough), then use:
>
> ```
> if [ "$(git -C "<Claude-Code path>" rev-parse --abbrev-ref HEAD)" != "main" ]; then
>   echo "Claude-Code is no longer on main — stop, do not commit. Re-check the two preconditions above; if it's still not on main, use the queue-item path instead."
> else
>   git -C "<Claude-Code path>" fetch origin main --quiet
>   if [ $? -ne 0 ]; then
>     echo "Fetch failed — Claude-Code's remote is unreachable or misconfigured; diagnose that before doing anything else. Do not commit."
>   else
>     count="$(git -C "<Claude-Code path>" rev-list --count HEAD..origin/main)"
>     if [ -z "$count" ]; then
>       echo "rev-list produced no output after a successful fetch — investigate directly rather than trusting this command further."
>     elif [ "$count" != "0" ]; then
>       echo "Claude-Code is $count commit(s) behind origin/main — see the pull note below, then retry this command."
>     else
>       git -C "<Claude-Code path>" add knowledge/<topic>.md knowledge/INDEX.md && \
>       git -C "<Claude-Code path>" commit -F "<msg-file>" && \
>       git -C "<Claude-Code path>" push origin main || \
>       echo "Commit or push failed after a fetch that showed Claude-Code current on main — most likely not staleness; read the error above directly (a push rejected as non-fast-forward does mean the remote moved — see the pull note below)."
>     fi
>   fi
> fi
> ```
>
> **If the count is nonzero** the knowledge write is still uncommitted at this point, so a plain
> `pull` can fail with "local changes would be overwritten." Stash it first (`git -C
> "<Claude-Code path>" stash`), pull (`git -C "<Claude-Code path>" pull origin main`), then pop
> (`git -C "<Claude-Code path>" stash pop`) — if the pop itself conflicts, resolve by hand and
> `git -C "<Claude-Code path>" stash drop` once resolved, since a conflicting pop leaves the
> stash entry in place — before retrying the command above.
>
> **If instead the final branch's push is rejected as non-fast-forward**, the write is already
> committed (that branch only runs after `add && commit` succeeded), so there is nothing to stash
> — a plain `git -C "<Claude-Code path>" pull origin main` is enough, then retry the command
> above to push.
>
> Written for a POSIX shell; translate to PowerShell (same three-outcome structure: fetch, check
> its own exit status, then compare the count) on a machine without git-bash on `PATH`, rather than
> assuming this block runs as-is. Deferring the commit here widens the race window
> `hub-process.md` separately warns about shrinking by committing immediately — accepted openly as
> the cost of the confirmation-gate rule already in force in this file.

### 3. `ai-product-factory/.claude/commands/session-end.md`

The base checklist (Step 4, lines 52–57 and 59–63) is already live and unchanged by this revision.
**Currently live** (the trigger paragraph, lines 64–73, this revision replaces):

> A "yes" to **"A new pattern or workflow that other projects could use?"** or **"A cross-cutting
> bug or limitation discovered?"** specifically also means checking whether it's relevant beyond
> this repo (a bug in a shared plugin/core, a process finding about DCOE mechanics) — if so, `git
> fetch` + pull `Claude-Code` first (its Hard Rule 6 names `knowledge/INDEX.md` as a contention
> file other concurrent sessions also write), then write a dated entry to the `Claude-Code` hub's
> `knowledge/<topic>.md` (+ `INDEX.md`) now, in this session, if `Claude-Code` is checked out
> alongside this repo, or as a `docs/todo.md` item naming the exact target file if it isn't.
> **Commit/push that write only on this session's explicit confirmation** — same rule as this
> repo's own `/session-end` convention (per `ai-product-factory/CLAUDE.md`'s session-commands
> line: "Never commit/push without explicit confirmation"), never automatically because this step
> ran.

**Full replacement text**, restructured as a numbered list to match the rest of this file's plain,
checklist-driven style rather than a dense paragraph, and — unlike the fifth revision — naming
both checklist items explicitly rather than referring back to "those two":

> A "yes" to **"A new pattern or workflow that other projects could use?"** or **"A cross-cutting
> bug or limitation discovered?"** specifically also means one more check — is it relevant beyond
> this repo (a bug in a shared plugin/core, a process finding about DCOE mechanics)? If so:
>
> 1. Locate `Claude-Code`'s checkout for this session (commonly a sibling repo already open
>    alongside this one) **and** confirm it's on `main` (`git -C "<Claude-Code path>" rev-parse
>    --abbrev-ref HEAD`). If `Claude-Code` isn't checked out, or is checked out but not on `main`,
>    stop here and add a `docs/todo.md` item naming the exact fact and the target
>    `knowledge/<topic>.md` file instead (say which condition failed) — per Hard Rule 11, a queue
>    item naming the exact change still discharges the obligation.
> 2. Confirm it's current: `git -C "<Claude-Code path>" fetch origin main --quiet`, checking the
>    fetch's own exit status before trusting anything derived from it; only if it succeeded,
>    compare `git -C "<Claude-Code path>" rev-list --count HEAD..origin/main` (pull with `git -C
>    "<Claude-Code path>" pull origin main` if nonzero, and re-run both checks before writing).
> 3. Write a dated entry to `Claude-Code/knowledge/<topic>.md` and update its `INDEX.md` row, in
>    this same session — prefer a surgical edit to `INDEX.md`'s one row over rewriting the file,
>    since it's a named `Claude-Code` Hard Rule 6 contention file other sessions also write.
> 4. Commit/push only on this session's explicit confirmation (per `ai-product-factory/CLAUDE.md`'s
>    session-commands line) — never automatically because this step ran. This widens the race
>    window `hub-process.md` separately warns shrinking by committing immediately; accepted here as
>    the cost of this repo's own confirmation-gate rule. State in Step 6's report that the write is
>    pending, and use this exact command when confirmation comes — write a one-line commit message
>    to a scratch file first (`<msg-file>`; e.g. `knowledge: <short summary> (cross-project write
>    from this repo)`), then:
>
>    ```
>    if [ "$(git -C "<Claude-Code path>" rev-parse --abbrev-ref HEAD)" != "main" ]; then
>      echo "Claude-Code is no longer on main — stop, do not commit. Re-check step 1's preconditions; if it's still not on main, use the queue-item path instead."
>    else
>      git -C "<Claude-Code path>" fetch origin main --quiet
>      if [ $? -ne 0 ]; then
>        echo "Fetch failed — Claude-Code's remote is unreachable or misconfigured; diagnose that before doing anything else. Do not commit."
>      else
>        count="$(git -C "<Claude-Code path>" rev-list --count HEAD..origin/main)"
>        if [ -z "$count" ]; then
>          echo "rev-list produced no output after a successful fetch — investigate directly rather than trusting this command further."
>        elif [ "$count" != "0" ]; then
>          echo "Claude-Code is $count commit(s) behind origin/main — see the pull note below, then retry this command."
>        else
>          git -C "<Claude-Code path>" add knowledge/<topic>.md knowledge/INDEX.md && \
>          git -C "<Claude-Code path>" commit -F "<msg-file>" && \
>          git -C "<Claude-Code path>" push origin main || \
>          echo "Commit or push failed after a fetch that showed Claude-Code current on main — most likely not staleness; read the error above directly (a push rejected as non-fast-forward does mean the remote moved — see the pull note below)."
>        fi
>      fi
>    fi
>    ```
>
>    **If the count is nonzero** the knowledge write is still uncommitted at this point, so a
>    plain `pull` can fail with "local changes would be overwritten." Stash it first (`git -C
>    "<Claude-Code path>" stash`), pull (`git -C "<Claude-Code path>" pull origin main`), then pop
>    (`git -C "<Claude-Code path>" stash pop`) — if the pop itself conflicts, resolve by hand and
>    `git -C "<Claude-Code path>" stash drop` once resolved, since a conflicting pop leaves the
>    stash entry in place — before retrying the command above.
>
>    **If instead the final branch's push is rejected as non-fast-forward**, the write is already
>    committed (that branch only runs after `add && commit` succeeded), so there is nothing to
>    stash — a plain `git -C "<Claude-Code path>" pull origin main` is enough, then retry the
>    command above to push.
>
>    Written for a POSIX shell; translate to PowerShell (same structure) on a machine without
>    git-bash on `PATH`.

### 4. `Claude-Code/.claude/commands/session-end.md` — no change

Step 4 ("Update the Knowledge Cache (Hard Rule 5)") already covers this repo writing to its own
`knowledge/`, which *is* the cross-project cache from this repo's own side. Confirmed unchanged.

**Copy-drift note:** `Claude-Code`'s instance is itself a derivative of `hub-template/session-end.md`
(same promotion path as the other two). The §1 sentence, once copied into a vault, tells the
reader to write to "the `Claude-Code` hub's cross-project `knowledge/` cache" — self-referential if
copied verbatim into `Claude-Code` itself. **When `hub-template/session-end.md` is next re-copied
into `Claude-Code`'s own instance, that sentence is deliberately dropped**, since that repo's own
Step 4 already covers the same write from the inside. This is a one-line note for whoever does
that future re-copy, not a change to either file today.

### Report-line additions

**Already shipped, no change** (confirmed live, kept as a historical record):
`hub-template/session-end.md:191`, `tlelosa-claude-config/.claude/commands/session-end.md:121`,
`ai-product-factory/.claude/commands/session-end.md:94` each already carry a cross-project outcome
option in their report block.

**New this revision** — each needs one further option so a pending, uncommitted cross-project
write has somewhere to be reported rather than dissolving into unstated prose once its step
finishes (this is what gives the redesigned commit-time check in §1–§3 an actual carrier):

- **`hub-template/session-end.md`** Step 4 report block — extend the `**Logged:**` line to add
  `| + Claude-Code write pending commit (command given in Step 2)` as a further option.
- **`tlelosa-claude-config/.claude/commands/session-end.md`** Step 4 report block — same
  extension to its `**Logged:**` line, also naming Step 2.
- **`ai-product-factory/.claude/commands/session-end.md`** Step 6 report block — extend
  `**Knowledge cache:**` to add `Updated (local) + Claude-Code write pending commit (command given
  in Step 4)` as a further option.

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
4. **This has already happened to this very spec — not a hypothetical to guard against, a
   confirmed occurrence, twice now (the fourth revision's text, then the fifth's).** Before
   dispatching any future revision of this spec, verify what's actually live rather than trusting
   this spec's own "Currently live" quotes — run, from wherever this session has each repo checked
   out this session (do not assume a shared working directory across the three commands):
   `git -C "<tlelosa-claude-config root>/hub-template" log --oneline -3 -- session-end.md`,
   `git -C "<tlelosa-claude-config root>" log --oneline -3 -- .claude/commands/session-end.md`, and
   `git -C "<ai-product-factory root>" log --oneline -3 -- .claude/commands/session-end.md` — then
   diff the live file against this spec's proposed text before treating any of it as outstanding.

## Impact

**Structural, but no CORE version bump** — this changes `hub-template/session-end.md` and two
repos' own command-file instances, not `CORE.md` itself (confirmed: `grep -n "cross-project\|
knowledge-cache" dcoe-roster/CORE.md` returns three hits — `:70` and `:73` are the Router's
"cross-project dependencies"/"no cross-project effect" scale-check language, unrelated to
knowledge-cache convention; `:248` is Hard Rule 11's applicability list, which names
"knowledge-cache entries" as one of the things a record-without-a-control can be but doesn't
itself establish a cross-project convention — so no CORE change or version bump is needed).
Distribution follows the existing file-copy path (ADR-008): fix in `hub-template/` first, then
re-copy into each opted-in vault's own `.claude/commands/session-end.md` — copying doesn't
propagate automatically, per this repo's own documented tradeoff.

**Touches (as of this revision — the base mechanic already shipped, see revision notes above):**
`hub-template/session-end.md` (one paragraph replaced — freshness check, `main`-branch
confirmation, and a literal deferred-commit command that folds the recheck into itself — plus one
report-line extension), `tlelosa-claude-config/.claude/commands/session-end.md` (same amendment,
within Step 2), `ai-product-factory/.claude/commands/session-end.md` (same amendment, as a
numbered list matching Step 4's existing checklist style, plus its Step 6 report-line extension).
No change to `Claude-Code/.claude/commands/session-end.md` or to `dcoe-roster/CORE.md`.

**No code changes needed** beyond the command-file text itself — same as Hard Rule 11, this is a
discipline addition, not a hook or automation.

## Related

- Hard Rule 11 ("a record is not a control," CORE 1.6 → 1.7) — the general form of this problem
  (a finding recorded but not installed anywhere executable); this spec is the *which-repo* special
  case of it. The fallback path in §1–§3 (file a `docs/todo.md` item when `Claude-Code` isn't
  checked out) is itself just such a record — nothing in this spec makes a future session pick it
  up automatically, which is exactly the follow-up named below. The redesigned commit-time check in
  this revision is a direct application of the same rule to this spec's own mechanism: a re-check
  described only in prose, with no report line or executable carrier, was found to be exactly the
  kind of record-without-a-control Hard Rule 11 forbids.
- `session-end.md` Step 1.5 ("Can This Session's Work Be Found?", both `Claude-Code`'s and
  `tlelosa-claude-config`'s instances) — the existing precedent for "check every repo this session
  touched, not just the one you're sitting in," which this spec applies to knowledge-cache writes
  specifically rather than PR/branch reachability. It's also the only place in this ecosystem that
  already asks "what repos does this session have checked out" — §2's proposed text points at it
  explicitly rather than re-deriving the same question.
- `Claude-Code/knowledge/hub-process.md`, 2026-08-07 entry ("Contention-file discipline needs a
  re-check immediately before writing") — source for the re-fetch-immediately-before-the-commit
  addition in §1–§3, now implemented literally (the check is a clause inside the actual commit
  command) rather than described as a separate step to remember.
- `Claude-Code/knowledge/cloud-sessions.md`, 2026-08-12 entry (a cloud container whose `HEAD` and
  cached `origin/main` both read a stale SHA while the real remote was 13 commits ahead — a fetch
  that never ran, not one that ran and found nothing — plus the atomic-fetch-failure trap) —
  source for the "checked out is not the same as current" freshness check and, after the sixth
  pass found the earlier `&&`-chained form conflated a failed fetch with a genuinely fresh `0`,
  for separating the fetch's own exit status from the count comparison throughout §1–§3.
- `Claude-Code/knowledge/tlelosa-claude-config.md`, 2026-08-16 entry (PR #22 independently shipped
  a still-BLOCKED spec's text into these same three `session-end.md` files) — source for
  Enforcement item 4 above and this spec's own Problem-section evidence; item 4 now names this
  spec's own repeat occurrence (fourth revision, then fifth) as confirmed history, not just
  precedent from elsewhere.
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
- `docs/todo.md`'s own "Require a Done entry to cite a SHA on `main`" item (the PR #22 entry) said
  "Reverted on merge (2026-08-12)" — that date is the flawed text's original authorship
  (`cfb4767`), not the revert, which happened `2026-08-16` (`94c9351`/`02462dd`). Found while
  dating this spec's own evidence, and corrected in `docs/todo.md` the same day — no longer an
  open follow-up (a prior revision of this spec listed it as one; that was stale by the time it
  was written and is not repeated here).
