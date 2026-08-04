---
# /session-end — Close Out & Prep For Archiving
# Runs at the end of a session (or as a checkpoint mid-session): reconciles
# this vault's task queue, logs what happened, and leaves the session in a
# state a later /continue run can recognize and archive without needing to
# reverse-engineer it from the transcript.
---

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
`CLAUDE.md` references one before assuming), append a new dated entry in
the same format the existing entries use, ending with the same
`**Last completed:** / **Next task:** / **Known risks:** / **Blockers:**`
block `/continue`'s Step 1 already expects to read.

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

**A session cannot rename or archive itself in every environment** —
confirmed in `/continue` Step 0 that some tool surfaces only expose
`set_session_title`/`archive_session` for *other* sessions, never the
current one. If the tool call fails or isn't available for that reason,
say so plainly and move on — don't treat it as an error to work around,
and don't attempt `archive_session` on this session directly. Setting a
clear title (when possible) is what "prepares this session for archiving"
— a later `/continue` run (or Tebello directly) does the actual archiving,
same as today.

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
