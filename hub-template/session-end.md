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

## Step 2 — Reconcile the Task Queue

Open this vault's `docs/todo.md`:

- Move anything actually finished this session from Open → Done, with a
  one-line summary (what changed, where the detail lives — spec file,
  commit, PR).
- Add any newly-discovered open item surfaced during the session that
  isn't tracked yet.
- Don't touch items untouched this session — this step reconciles, it
  doesn't re-audit the whole backlog.

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

## Step 3 — Set This Session's Title

If a session-title tool (e.g. `set_session_title`) is available in this
environment, set this session's own title to `Cont-"<3-6 word
context-based title>"` describing what this session actually did — same
naming convention `/continue`'s Step 0 uses when renaming *other* stale
sessions, so a later `/continue` run doesn't have to reverse-engineer one
from `list_events`.

**On some tool surfaces this step is not merely unreliable — it is
impossible, and cannot even be attempted.** Confirmed on the CCD desktop
surface (2026-08-06, this command's first real run): `set_session_title`
rejects the current session *and* `list_sessions` excludes it, so a session
has no way to obtain its own ID. There is no call to make and therefore no
error to report.

So don't frame this as "try it and handle the failure":

- **Self-titling reachable** → set the title.
- **No way to identify this session** (as above) → report
  `not available in this environment` in Step 4 and move on. This is
  expected, not a failure, and not something to work around — do not go
  hunting for the session ID in logs, config, or transcripts.

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
**Logged:** [docs/todo.md updated | + session-log.md entry added | + knowledge/<topic>.md updated]
**Title set:** [Cont-"<title>" | not available in this environment]
**Open follow-ups:** [none | listed, each already reflected in docs/todo.md]
```

Keep this short — it's a close-out, not a new resume report. If Step 1
surfaced uncommitted or unpushed work, lead with that rather than burying
it at the end.
