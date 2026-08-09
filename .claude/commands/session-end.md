---
description: Close out a session on tlelosa-claude-config and prep it for archiving
---

# /session-end — Config Repo Session Close-Out

Minimal adaptation of `hub-template/session-end.md` for this repo itself.
The `session-log.md` step is omitted (this repo keeps no session log, same
as `.claude/commands/continue.md`'s local copy), as is the `knowledge/`
cache step (that lives in the `Claude-Code` hub, not here).

## Step 1 — Check Working Tree State

```bash
git status --short --branch
git log --oneline -5
```

Uncommitted changes or unpushed commits are part of what this session is
leaving behind — surface them, never commit or push without explicit
confirmation this turn.

## Step 1.5 — Can This Session's Work Be Found?

Committed and pushed is not the same as reachable. Work on a feature branch
with no PR is invisible to every session that starts from `main`, and nothing
about that state looks wrong — clean tree, commits pushed, close-out reading
like a success.

```bash
git rev-parse --abbrev-ref HEAD
git log --oneline origin/main..HEAD
```

If HEAD is not `main` and commits come back, say so in Step 4, naming the
branch and the count. Report a pass in one line too — silence and never-ran
look identical.

**Never open the PR, merge, or push** to resolve it: same rule as Step 1.
Naming the branch is the whole job — a branch that has been named is one
somebody can find again.

## Step 2 — Reconcile `docs/todo.md`

- Move anything actually finished this session from Open → Done, with a
  one-line summary and, for structural changes, a link to its spec in
  `docs/specs/`.
- Add any newly-discovered open item surfaced this session that isn't
  tracked yet.
- Leave untouched items alone — this reconciles, it doesn't re-audit the
  whole backlog.

## Step 3 — Set This Session's Title

If `set_session_title` is available in this environment, set this
session's title to `Cont-"<3-6 word context-based title>"` describing what
this session did — so a later `/continue` run doesn't have to
reverse-engineer one from the transcript.

On some tool surfaces this is impossible rather than merely unreliable, and
cannot even be attempted (see `hub-template/continue.md` Step 0 point 5).
Confirmed on the CCD desktop surface 2026-08-06: `set_session_title`
rejects the current session *and* `list_sessions` excludes it, so a session
has no way to obtain its own ID — no call to make, no error to report. In
that case report `not available in this environment` in Step 4 and move on;
don't go hunting for the ID elsewhere. Never call `archive_session` on this
session either way. Setting a title *where possible* is what "prepares the
session for archiving": a later `/continue` run (or Tebello directly) does
the actual archiving.

## Step 4 — Report Close-Out

```
## Session End

**Committed:** [what's committed this session, or "nothing to commit"]
**Pushed:** [clean — nothing outstanding | N unpushed commit(s) on <branch>]
**Branch state:** [all commits reachable from main | N commit(s) on <branch> not reachable from main — invisible until merged or PR'd]
**Logged:** [docs/todo.md updated]
**Title set:** [Cont-"<title>" | not available in this environment]
**Open follow-ups:** [none | listed, each already reflected in docs/todo.md]
```

Keep it short. If Step 1 surfaced uncommitted or unpushed work, lead with
that.
