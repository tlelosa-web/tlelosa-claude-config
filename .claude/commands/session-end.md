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

A session cannot rename or archive itself in every tool surface (see
`hub-template/continue.md` Step 0 point 5). If the tool isn't available or
the call fails for that reason, say so plainly and move on — don't attempt
`archive_session` on this session directly. This is what "prepares the
session for archiving": a later `/continue` run (or Tebello directly) does
the actual archiving.

## Step 4 — Report Close-Out

```
## Session End

**Committed:** [what's committed this session, or "nothing to commit"]
**Pushed:** [clean — nothing outstanding | N unpushed commit(s) on <branch>]
**Logged:** [docs/todo.md updated]
**Title set:** [Cont-"<title>" | not available in this environment]
**Open follow-ups:** [none | listed, each already reflected in docs/todo.md]
```

Keep it short. If Step 1 surfaced uncommitted or unpushed work, lead with
that.
