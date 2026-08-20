---
description: Close out a session — reconcile the queue, log it, prep it for archiving
---

# /session-end — Close Out & Prep For Archiving

Runs at the end of a session (or as a checkpoint mid-session): reconciles
this vault's task queue, logs what happened, and leaves the session in a
state a later `/continue` run can recognize and archive without needing to
reverse-engineer it from the transcript.

## Step 1 — Check Working Tree State

```bash
git status --short --branch
git log --oneline -5
```

Uncommitted changes or unpushed commits are part of "what this session is
leaving behind" — surface them plainly in the Step 4 report. **Never commit
or push on Tebello's behalf just because `/session-end` is running** — same
discipline as everywhere else: only act on explicit confirmation this turn.

## Step 1.5 — Can This Session's Work Be Found?

Committed and pushed is not the same as reachable. Work sitting on a feature
branch with no PR is invisible to every session that starts from the default
branch — and nothing about that state looks wrong: the tree is clean, the
commits are pushed, and this close-out reads like a success.

This session is the only one that knows what it just built, and this is the
last moment anyone will look at that branch on purpose.

**Run this in every repo this session touched, not just the one you're
sitting in.** A session that pushes two repos and opens a PR for one looks
finished — the PR it did open reads as success, and the repo it didn't touch
again is easy to forget checking. Two real cases landed this way: a PR
template and a `/retro` install each sat stranded in a second repo for a day
while the queue recorded both as done, because the session that built them
only ran this check where it happened to end up. If this session has more
than one repo checked out or referenced, list them explicitly before
running the check, then run it — and Step 4's report — once per repo:

```bash
git rev-parse --abbrev-ref HEAD
git log --oneline origin/<default-branch>..HEAD
```

If HEAD is not the default branch and the second command returns commits,
report it in Step 4, once per repo checked:

> **Branch state:** N commit(s) on `<branch>` not reachable from
> `<default>`. Invisible to any session starting from `<default>` until
> merged or a PR is opened.

**Report a pass in one line too** — "all commits reachable from `<default>`"
— because silence and never-ran look identical.

**Never open the PR, merge, or push** to resolve this. Same rule as Step 1:
`/session-end` reports what it is leaving behind; it does not act on the
owner's behalf. Naming the branch is the whole job — a branch that has been
named is one somebody can find again.

Why this belongs here rather than only in `/continue`: a resuming session
can find stranded work, but only after it has already been stranded, and it
has no idea which branch mattered. This step costs one command and catches
it at the source.

## Step 2 — Reconcile the Task Queue

Open this vault's `docs/todo.md`:

- Move anything actually finished this session from Open → Done, with a
  one-line summary (what changed, where the detail lives — spec file,
  commit, PR).
- Add any newly-discovered open item surfaced during the session that
  isn't tracked yet.
- Don't touch items untouched this session — this step reconciles, it
  doesn't re-audit the whole backlog.

> SHA-citation for Done entries is proposed but not yet live here — spec at
> `docs/specs/2026-08-12-done-sha-citation.md` (in `tlelosa-claude-config`)
> is BLOCKED by reviewer (defects: `git log` misses changed-file cases,
> needs a fresh-fetch guard per Hard Rule 10, needs a pending state for
> PR-merge lag). Don't add the requirement here until that spec is revised
> and approved.

If this vault keeps a `docs/session-log.md` (hub roots do; single-repo
vaults like a plugin/marketplace repo typically don't — check whether
`CLAUDE.md` references one before assuming), make sure it ends with a
dated entry covering this session, in the same format the existing entries
use, ending with the same
`**Last completed:** / **Next task:** / **Known risks:** / **Blockers:**`
block `/continue`'s Step 1 already expects to read.

**Reconcile — don't blindly append.** Check what's already there first:

- **Work not logged yet** → append a new entry. The common case.
- **Session already wrote its own entries** → don't restate them. Either
  add a short entry covering only what's new since (and say so explicitly,
  so it doesn't read as a duplicate), or verify the existing final entry's
  `Last completed:` / `Next task:` block is still accurate and leave it.
- **Second `/session-end` run in the same session** (mid-session checkpoint,
  then again at the end) → extend or replace the entry the first run wrote,
  rather than adding a near-empty second one.

Appending unconditionally produces duplicate or near-empty entries, which
is exactly the noise this log exists to avoid — an entry should be the
session's *output*, not a record that a close-out command ran.

If this vault keeps a topic-keyed knowledge cache (check `CLAUDE.md` for a
`knowledge/` convention) and this session surfaced a reusable fact — a
config quirk, a decision, an API behavior, something that would otherwise
get re-derived next time — append it to the matching `knowledge/<topic>.md`
and update its `knowledge/INDEX.md` row now, not as an afterthought later.
Ask explicitly, even if the answer is no: **did this session surface a
reusable fact not yet in `knowledge/`?** If yes, capture it now before
closing out.

Then ask a second, separate question: **is this fact relevant beyond this
vault** — a bug or gap in a shared plugin/core (`dcoe-roster`, `CORE.md`,
`hub-template/`), or a process/governance finding about how DCOE mechanics
behave in practice? If yes, it also belongs in the `Claude-Code` hub's
cross-project `knowledge/` cache — `git fetch` + pull `Claude-Code` first
(its own Hard Rule 6 names `knowledge/INDEX.md` as a contention file other
concurrent sessions write too), then write a dated entry to the matching
`knowledge/<topic>.md` and update `knowledge/INDEX.md` now, in this
session, if `Claude-Code` is checked out alongside this vault, rather than
deferring to a later sweep. **Committing and pushing that write follows the
same rule as everything else in this command: only on this session's
explicit confirmation this turn, never automatically because this step
ran.** If `Claude-Code` isn't checked out this session, file a queue item
in this vault naming the exact fact and the target `knowledge/<topic>.md`
file instead — per Hard Rule 11, a queue item naming the exact change still
discharges the obligation.

## Step 3 — Set This Session's Title

If a session-title tool (e.g. `set_session_title`) is available in this
environment, set this session's own title to `Cont-"<3-6 word
context-based title>"` describing what this session actually did — same
naming convention `/continue`'s Step 0 uses when renaming *other* stale
sessions, so a later `/continue` run doesn't have to reverse-engineer one
from `list_events`.

**Whether this is possible is surface-dependent — establish which case you
are in before deciding it can't be done.**

- **CCD desktop** (confirmed 2026-08-06, this command's first real run):
  `set_session_title` rejects the current session *and* `list_sessions`
  excludes it, so a session has no way to obtain its own ID. There is no
  call to make and therefore no error to report.
- **Claude Code Remote / web** (confirmed 2026-08-10): the opposite on both
  counts. The session ID appears verbatim in the session URL
  (`.../session_<id>`), and `list_sessions` **includes** the current session
  — it comes back as the first row, not excluded. `get_session` and
  `set_session_title` both accept that ID. Self-titling has demonstrably
  worked here: sessions titled `Cont-"…"` exist in the list. The call may
  still be gated on an ordinary tool-permission approval, which is a normal
  failure to report — not an impossibility.

So there are three outcomes, not two:

- **Title set** → report it.
- **Call attempted and refused** (permission denied, tool error) → report
  what happened. This is an ordinary failure; don't relabel it
  "not available in this environment", which claims something stronger.
- **No way to identify this session at all** (the CCD desktop case) → report
  `not available in this environment` in Step 4 and move on. This is
  expected, not a failure, and not something to work around — do not go
  hunting for the session ID in logs, config, or transcripts.

Before concluding you're in the third case, check the cheap sources: the
session URL, and one `list_sessions` call. The earlier version of this step
told sessions on *every* surface not to try, on evidence gathered from one.

Never call `archive_session` on this session either way. Setting a clear
title, *where possible*, is what "prepares this session for archiving" — a
later `/continue` run (or Tebello directly) does the actual archiving. Where
it isn't possible, the queue and log reconciliation from Step 2 is what
makes that later run's judgment easy, which is most of the value anyway.

## Step 4 — Report Close-Out

```
## Session End

**Committed:** [what's committed this session, or "nothing to commit"]
**Pushed:** [clean — nothing outstanding | N unpushed commit(s) on <branch>]
**Branch state:** [Step 1.5, per repo touched this session — <repo>: all commits reachable from <default> | <repo>: N commit(s) on <branch> not reachable from <default> — invisible until merged or PR'd]
**Logged:** [docs/todo.md updated | + session-log.md entry added | + knowledge/<topic>.md updated | + Claude-Code/knowledge/<topic>.md updated (cross-project) | cross-project: none this session]
**Title set:** [Cont-"<title>" | attempted, refused — <reason> | not available in this environment]
**Open follow-ups:** [none | listed, each already reflected in docs/todo.md]
```

Keep this short — it's a close-out, not a new resume report. If Step 1
surfaced uncommitted or unpushed work, or Step 1.5 found commits unreachable
from the default branch, lead with that rather than burying it at the end.
Those are the two ways a session's work disappears, and both are silent.
