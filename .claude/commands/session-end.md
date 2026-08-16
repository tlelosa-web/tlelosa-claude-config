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

**Run this in every repo this session touched, not just this one.** A cloud
session commonly has this repo plus `Claude-Code` and/or `ai-product-factory`
checked out together — a session that pushes two of them and opens a PR for
one looks finished, and the repo it didn't return to is easy to forget. Two
real cases landed this way: a PR template and a `/retro` install each sat
stranded in a second repo for a day while the queue recorded both as done.
List every repo this session touched, then run this — and report it in
Step 4 — once per repo:

```bash
git rev-parse --abbrev-ref HEAD
git log --oneline origin/main..HEAD
```

If HEAD is not `main` and commits come back, say so in Step 4, naming the
repo, branch, and count. Report a pass in one line too, per repo — silence
and never-ran look identical.

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

> SHA-citation for Done entries is proposed but not yet live here — spec at
> `docs/specs/2026-08-12-done-sha-citation.md` is BLOCKED by reviewer
> (defects: `git log` misses changed-file cases, needs a fresh-fetch guard
> per Hard Rule 10, needs a pending state for PR-merge lag). Don't add the
> requirement here until that spec is revised and approved.

## Step 3 — Set This Session's Title

If `set_session_title` is available in this environment, set this
session's title to `Cont-"<3-6 word context-based title>"` describing what
this session did — so a later `/continue` run doesn't have to
reverse-engineer one from the transcript.

Whether this is possible is surface-dependent (see `hub-template/continue.md`
Step 0 point 5). On the **CCD desktop** surface it is impossible rather than
merely unreliable, and cannot even be attempted — confirmed 2026-08-06:
`set_session_title` rejects the current session *and* `list_sessions`
excludes it, so a session has no way to obtain its own ID; no call to make,
no error to report. On **Claude Code Remote / web** the opposite holds on
both counts (confirmed 2026-08-10): the session ID is in the session URL
verbatim, `list_sessions` returns the current session as its first row rather
than excluding it, and `get_session`/`set_session_title` accept that ID. The
call may still hit an ordinary tool-permission approval — that's a normal
failure to report, not an impossibility.

So report one of three, not two: title set; attempted and refused (say what
happened); or genuinely unidentifiable, which is the only case that warrants
`not available in this environment`. Check the session URL and one
`list_sessions` call before concluding the last. Never call
`archive_session` on this session in any case. Setting a title *where
possible* is what "prepares the session for archiving": a later `/continue`
run (or Tebello directly) does the actual archiving.

## Step 4 — Report Close-Out

```
## Session End

**Committed:** [what's committed this session, or "nothing to commit"]
**Pushed:** [clean — nothing outstanding | N unpushed commit(s) on <branch>]
**Branch state:** [Step 1.5, per repo touched this session — <repo>: all commits reachable from main | <repo>: N commit(s) on <branch> not reachable from main — invisible until merged or PR'd]
**Logged:** [docs/todo.md updated]
**Title set:** [Cont-"<title>" | attempted, refused — <reason> | not available in this environment]
**Open follow-ups:** [none | listed, each already reflected in docs/todo.md]
```

Keep it short. If Step 1 surfaced uncommitted or unpushed work, lead with
that.
