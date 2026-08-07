---
description: Resume hub work from where the last root-level session ended
---

# /continue — Hub Session Resume

Resumes work from where the last root-level session ended. Project-aware:
identifies which project folder is in play before acting.

> **Vault-agnostic by design (ADR-008).** Nothing below names a specific
> machine, project, or vault. When you copy this into a hub root's
> `.claude/commands/continue.md`, it is expected to work as-is; add that
> vault's own specifics (its machine names, its live-vs-mirror convention,
> its knowledge-cache paths) to the copy, not back into this template.

## Step 0 — Rename Stale Sessions

Before orienting, clean up titles left over from prior `/continue` runs:

1. Call `list_sessions` (this always excludes the current session, so it's
   safe to run — it can only surface *other* sessions).
2. For every other session still titled exactly `Continuation`, read its
   transcript with `list_events` (most recent 30 first; page backward with
   `before_uuid` if the actual task isn't visible yet) to find the concrete
   task it worked on — the first real user request after the `/continue`
   resume boilerplate, and what got built/fixed/decided.
3. Rename each one with `set_session_title` to `Cont-"<3-6 word
   context-based title>"` — describe what the session actually did, e.g.
   `Cont-"Dashboard & BOM UI fixes batch"`, not the generic bootstrap
   exchange.
4. Skip a session if it has no real task yet (just the `/continue`
   resume-report exchange, no follow-up from the owner) — leave it as
   `Continuation` until there's something to summarize.
5. **This session's own title is out of reach from inside itself** —
   `set_session_title` can only target other sessions. This session stays
   labeled `Continuation` until a *later* `/continue` run (in a different
   session) renames it per the steps above, or it's renamed manually.

If `list_sessions` (or `list_events`/`set_session_title`/`archive_session`
below) isn't available as a tool in this environment, say so plainly and
skip straight to Step 1 — don't treat a missing tool as an error to work
around. Session-management tools are absent in some cloud environments and
present on desktop/CLI installs; check rather than assume either way.

Then proceed to Step 0.5.

## Step 0.5 — Detect Superseded or Stale Sessions (ADR-005)

Originally this step only caught sessions clearly superseded by later work
in the *same* project — a narrow bar that let plain-old-idle sessions pile
up unarchived even when nothing about them was ambiguous. It now checks
two independent categories each run; a session only needs to match one:

**A. Superseded** — task completed or made obsolete by later work on the
same project:

1. Group the `list_sessions` results (already fetched in Step 0) by `cwd`
   (project folder).
2. For any project folder with more than one open session, read enough of
   each *older* session's transcript with `list_events` (and that project's
   own `docs/todo.md` if it has one) to judge — don't assume — whether its
   task is actually done, merged, or superseded by a later session's work.
   Sessions on genuinely separate, still-relevant tasks (e.g. different
   batches or features in the same project) are **not** candidates just
   because a newer session exists — an actively developed project routinely
   has several legitimately parallel sessions open at once.
3. For each session judged superseded, propose it to the owner by
   name/title with a one-line reason (e.g. "`Cont-\"Batch 25 resume: Edit
   Item modals\"` — that PR merged in a later session, this one's task is
   done").

**B. Stale/idle** — nothing to do with whether the task is superseded,
just whether the session is plainly dead weight:

1. Using `list_sessions`' last-activity timestamp for each other session,
   flag any session with **no activity in 7+ days**.
2. For each flagged session, read enough of its transcript with
   `list_events` to sanity-check it's actually dead, not just quiet
   because it's mid-wait on something external (blocked on the owner's
   go-ahead, waiting on a third party, watching a PR). A session with a
   real open thread stays off the list even if it's old — staleness is
   about abandonment, not age alone.
3. Also flag single-exchange sessions with no follow-up task (the same
   condition Step 0 point 4 uses to skip renaming) once they're past the
   7-day mark — a `Continuation` session nobody ever gave a real task to
   is the clearest case of dead weight there is.
4. For each session flagged stale, propose it to the owner by name/title
   with a one-line reason (e.g. "`Cont-\"Draft outreach copy edits\"` —
   last activity 2026-07-14, no open thread, nothing pending").

**Both categories:**

- **Never call `archive_session` speculatively.** Only archive a session
  the owner has explicitly confirmed in this turn, one at a time.
- Present superseded and stale candidates together as one combined list so
  the owner isn't asked twice in the same run.
- If nothing looks superseded or stale, say so briefly and move on — this
  step should not turn into an interrogation when the session list is
  clean.

Category B exists because "superseded" is the wrong test for most dead
sessions: a finished task is usually not *superseded* by anything, it
simply finished, and the superseded-only version left those open
indefinitely.

Then proceed to Step 1.

## Step 1 — Orient

Read:
- `docs/todo.md` → current hub task queue and priorities
- `docs/session-log.md` → last session summary (final entry only)

Read both as a **claim with a timestamp**, not as state. Neither is
verified until Step 1.9 has compared them against the live sub-project
repos they name — do not carry anything from them into the Step 3 report
before that check has run.

## Step 1.5 — Shared Core Update Check (ADR-007)

Check whether the shared `CORE.md` (DCOE architecture, sub-agent roster,
model routing, universal hard rules — see the read instruction near the top
of this hub's `CLAUDE.md`) has upstream changes not yet pulled on this
machine:

```
git -C ~/.claude/plugins/marketplaces/tlelosa-claude-config fetch --quiet
git -C ~/.claude/plugins/marketplaces/tlelosa-claude-config rev-list HEAD..origin/main --count
```

If the count is > 0, mention it in the Step 3 resume report: "Shared core
template has N new commit(s) upstream — run `/plugin marketplace update
tlelosa-claude-config` to pull them in." This is a signal only — never run
the update automatically, and don't let it block orienting or reporting.
If the marketplace clone doesn't exist on this machine at all, note that
plainly too rather than silently skipping the check.

## Step 1.75 — Sync Check (prevents contention-file conflicts)

`docs/todo.md` and `docs/session-log.md` — plus any other file nearly every
session writes, such as a knowledge-cache index if this vault keeps one —
are **contention files**. A hub can have several sessions running at once
across machines, and editing a contention file from a stale local `main`
produces a real merge conflict rather than a clean append.

```
git fetch origin main --quiet
git -C . rev-list HEAD..origin/main --count
```

If the count is > 0, `git pull origin main` before doing anything else in
this session (Step 0-1's reads above are safe either way; this just makes
sure any *edit* later in the session starts from a current base). If the
pull produces conflicts on a contention file, resolve as a real **union**
of both sides' changes — never pick one branch and discard the other's
work.

Note this prevents *conflicts*, not *misordering*: a clean auto-merge can
still insert a session-log entry above an older one. Step 3's log discipline
covers that separately.

## Step 1.9 — Cross-Repo Staleness Check (verifies Step 1 before you believe it)

Run this **after** Step 1.75, not before — comparing against a stale local
`main` compares the wrong clock.

`docs/session-log.md`'s final entry was written by a session that has since
ended, and the work it describes usually continued afterwards in a
*different* repo that pushes on its own schedule. **Nothing about a stale
entry looks stale:** `git status` is clean, `rev-list HEAD..origin/main` is
`0`, and the entry reads as a confident, complete close-out. Whenever hub
docs and the work they summarise live in separate repos, this is the normal
condition rather than an edge case.

1. **List the live repos to check.** Take every sub-project named by the
   final `session-log.md` entry and by the `todo.md` "Next task."
   **The repo root is usually not the project folder** — a vault may be one
   repo covering many sub-projects, or each sub-project may be its own repo,
   and both shapes commonly coexist in the same hub. Resolve it rather than
   assume:

   ```
   git -C "<project path>" rev-parse --show-toplevel
   ```

   If this hub keeps both a live working copy and a consolidated or mirrored
   copy of a project, check the **live** one — a mirror's clock answers a
   different question. If a named machine isn't reachable from this session,
   say so in the report and skip that repo; never guess at its state.

2. **Compare newest-commit clocks**, one call per resolved repo root:

   ```
   git -C . log -4 --format="%h %ci %s"
   git -C "<live project repo>" log -6 --format="%h %ci %s"
   git -C "<live project repo>" status --porcelain=v1 -b
   ```

3. **If the project's newest commit is later than the hub's newest commit
   touching that item, the hub entry is stale** — however complete it
   reads. Don't repeat it. Read that project's own `docs/todo.md` header
   and `docs/session-log.md` final entry and report *those* as current
   state instead.

4. **The `status` line is part of the answer.** The hub can be accurate
   about what was committed and still wrong about what exists — unpushed
   commits, or uncommitted work in the live repo, change the real state.
   Report them; a clean `rev-list` alone is not the whole picture.

5. **Report the outcome either way in Step 3, including a pass.** One line
   is enough ("hub `<sha>` `<time>` ahead of `<repo>` `<sha>` `<time>` —
   hub state accurate"). Silence is indistinguishable from not having run
   the check.

6. **Finding drift does not make reconciling it this session's task.**
   Surface it in the Step 3 report and let the owner pick. If both files
   are wrong, the reconciliation direction is: bring the *authoritative*
   (project) file current first, then trim the hub entry to a pointer at
   it. Hub-and-spoke says which copy is **owned** by whom; it does not say
   which copy is **correct**.

**Why this step is placed here and not inside `/session-end`:** a close-out
command runs the check at the one moment the hub is guaranteed to be
correct, so it always answers "fine." The *reading* session is the one that
can be wrong, so it is the one that must check.

## Step 2 — Identify Scope

Is the next task:
- **Hub-level** (cross-project, or new work at root) → this `CLAUDE.md`
  governs.
- **Inside a specific project folder** → check whether that folder has its
  own `CLAUDE.md`/`AGENTS.md`. If it does, read it — it takes precedence
  over this file for anything inside that folder. If it doesn't, this hub
  brain's Hard Rules still apply, but stack-specific conventions must be
  confirmed with the owner (Domain agent territory) rather than assumed.

## Step 2.5 — Flag Machine-Bound Tasks

Before reporting, check whether the candidate next task(s) (the `todo.md`
"Next task" plus any other open items you're about to surface) actually
need local filesystem/machine access this session doesn't have — e.g. a
folder survey on a named machine from a cloud session, or any task whose
description names a specific machine when the current session isn't running
on it.

- Compare the task's stated machine against this session's actual
  environment. If this hub keeps per-machine notes, read them rather than
  guessing which machine a task means.
- If a candidate task is machine-bound and this session can't reach that
  machine, don't drop it from the list — still surface it, but mark it
  clearly (e.g. "⚠️ requires local access on `<machine>` — can't run from
  this session") in both the Step 3 report and its `AskUserQuestion` option
  description, so the owner isn't offered it as if it were runnable here.
- If a candidate task **is** machine-bound but this session **is** that
  machine, check `docs/todo.md` for a linked spec under `docs/specs/`. If
  one exists, say so plainly in the Step 3 report ("Spec ready:
  docs/specs/<name>.md — no further research needed, can start
  immediately") — machine-bound queue items are often given specs ahead of
  time from a session that couldn't run them. Don't re-derive a plan from
  scratch if a ready spec already exists.
- If a task must run against a **live** working copy rather than a mirrored
  or consolidated one, say which, and say what goes wrong otherwise —
  a mirror that lacks the live data will either fail outright or silently
  operate on an empty stand-in.
- This is a labeling check only — don't skip the task, don't silently
  reorder the queue, and don't try to work around the access gap (e.g. by
  guessing at the other machine's folder structure) without the owner
  asking for that explicitly.

Then proceed to Step 3.

## Step 3 — Report State

Tell the owner:
1. **Last completed task** — from `session-log.md`, **as verified by Step
   1.9**, not as the entry states it
2. **Next pending task** — from `todo.md`, with which project (if any) it
   touches
3. **Spec status** — does a spec exist in `docs/specs/` (or the project's
   own `docs/specs/`) for the next task, if it's a build task?
4. **Hub state** — Step 1.9's result, stated explicitly whether it passed
   or found drift
5. **Known risks** — surface any standing risk this hub's own `CLAUDE.md`
   or `docs/todo.md` flags as still unresolved
6. **Blockers** — anything unresolved, pending decisions, or missing
   context

Format:

```
## Session Resume

**Scope:** [Hub-level | <project folder name>]
**Last completed:** [task name]
**Next task:** [task name from todo.md — if machine-bound and unreachable from this session, say so here: "⚠️ requires local access on <machine> — not runnable from this session"]
**Spec:** [exists at docs/specs/<name>.md | MISSING — must write spec before building | N/A]
**Hub state:** [Step 1.9 — verified: hub <sha> <time> ahead of <repo> <sha> <time>, entry accurate | STALE: <repo> is <N> ahead of the hub's last write, state above taken from that project's own docs | not checkable: <machine> unreachable from this session]
**Known risks:** [none new | <standing item from CLAUDE.md/todo.md>]
**Blockers:** [none | description — include any machine-access gap from Step 2.5 here too]

Ready to proceed? Confirm and I'll start.
```

**Then always follow the prose block with a selectable list** via
`AskUserQuestion` (single question, single-select unless the items are
clearly independent) — do not leave the owner to respond in free text only.
Build the option list from every open item surfaced in this step: the
`todo.md` "Next task," plus any other still-open items mentioned in the
report (cross-project backlog items, a session flagged as possibly
duplicating work, etc.). Each option is one concrete item with a short
description of what picking it means — for any item flagged machine-bound
in Step 2.5, lead the description with the same ⚠️ access-gap note so it's
clear before the owner picks it, not after. This was requested twice
independently (2026-07-17, two separate sessions) — treat it as a standing
preference, not a one-off.

## Step 4 — Wait for Confirmation

Do not begin implementation. Do not open files outside of the reads above.
Wait for the owner to confirm the task or redirect.

## Spec Gate Reminder

If the next task is a build task and no spec exists → surface this
immediately. Spec must be written and confirmed before any executor is
dispatched.
