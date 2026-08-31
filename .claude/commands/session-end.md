---
description: Close out a session on tlelosa-claude-config and prep it for archiving
---

# /session-end — Config Repo Session Close-Out

Minimal adaptation of `hub-template/session-end.md` for this repo itself.
The `session-log.md` step is omitted (this repo keeps no session log, same
as `.claude/commands/continue.md`'s local copy). The local `knowledge/`
cache step is also omitted (that cache lives in the `Claude-Code` hub, not
here) — but Step 2 below still checks whether this session's finding
belongs there.

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
git fetch origin --prune --quiet
git rev-parse --abbrev-ref HEAD
git log --oneline origin/main..HEAD
git ls-remote --heads origin refs/heads/$(git rev-parse --abbrev-ref HEAD)
```

If HEAD is not `main` and commits come back, say so in Step 4, naming the
repo, branch, and count. Report a pass in one line too, per repo — silence
and never-ran look identical.

**The `ls-remote` line is a separate check from the reachability question
above it, and both matter.** A branch can pass "commits ahead of `main`,
pushed" trivially and still have vanished from the remote by the time a
later session checks — the local cached tracking ref never invalidates
itself just because the remote side changed. Confirmed for real in
`ai-product-factory` (2026-08-20): a branch this session pushed was gone
from the remote with no PR, merge, or force-push visible from the pushing
session, while `git status`/`git branch -vv` kept reading "up to date"
throughout. If `ls-remote` returns nothing for a branch this session just
pushed, re-push it now (`git push -u origin <branch>`) and re-verify with
the same command — don't trust the push's own "success" message either,
that's exactly what read as success the first time. Report the
discrepancy in Step 4 even after re-pushing fixes it.

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

Before finishing, ask: **did this session find something relevant beyond
this repo** — a bug or gap in a plugin/core this repo ships (`dcoe-roster`,
`CORE.md`, `agent-bodies-reference/`), or a process/governance finding (a
spec-review-gate miss, a session-mechanics bug)? If yes, it also belongs in
`Claude-Code`'s cross-project `knowledge/` cache — but only if two
preconditions both hold, checked in this order:

1. `Claude-Code` is checked out this session (Step 1.5 above already has
   this session list every repo it touched — use that).
2. Its checkout is on `main` (`git -C "<Claude-Code path>" rev-parse
   --abbrev-ref HEAD`).

If either doesn't hold, skip straight to filing a `docs/todo.md` item
naming the exact fact and the target `knowledge/<topic>.md` file — say
which precondition failed if it was the second one — per Hard Rule 11, a
queue item naming the exact change still discharges the obligation.

If both hold, confirm it's current before writing: `git -C "<Claude-Code
path>" fetch origin main --quiet`, checking the fetch's own exit status
before trusting anything derived from it; only if it succeeded, compare
`git -C "<Claude-Code path>" rev-list --count HEAD..origin/main` — pull
(`git -C "<Claude-Code path>" pull origin main`) if nonzero and re-run both
checks before writing. Then write a dated entry to
`Claude-Code/knowledge/<topic>.md` (+ `INDEX.md`) in this same session —
preferring a surgical edit to `INDEX.md`'s one row over rewriting the file,
since it's a named `Claude-Code` Hard Rule 6 contention file other
concurrent sessions also write.

**Committing that write follows Step 1's existing rule — only on explicit
confirmation this turn, never automatically because this step ran — but
state plainly in Step 4's report that the write is pending, and give the
exact command that commits it when confirmation comes.** Write a one-line
commit message to a scratch file first (`<msg-file>`; e.g. `knowledge:
<short summary> (cross-project write from this repo)` is enough), then use:

```
if [ "$(git -C "<Claude-Code path>" rev-parse --abbrev-ref HEAD)" != "main" ]; then
  echo "Claude-Code is no longer on main — stop, do not commit. Re-check the two preconditions above; if it's still not on main, use the queue-item path instead."
else
  git -C "<Claude-Code path>" fetch origin main --quiet
  if [ $? -ne 0 ]; then
    echo "Fetch failed — Claude-Code's remote is unreachable or misconfigured; diagnose that before doing anything else. Do not commit."
  else
    count="$(git -C "<Claude-Code path>" rev-list --count HEAD..origin/main)"
    if [ -z "$count" ]; then
      echo "rev-list produced no output after a successful fetch — investigate directly rather than trusting this command further."
    elif [ "$count" != "0" ]; then
      echo "Claude-Code is $count commit(s) behind origin/main — see the pull note below, then retry this command."
    else
      git -C "<Claude-Code path>" add knowledge/<topic>.md knowledge/INDEX.md && \
      git -C "<Claude-Code path>" commit -F "<msg-file>" && \
      git -C "<Claude-Code path>" push origin main || \
      echo "Commit or push failed after a fetch that showed Claude-Code current on main — most likely not staleness; read the error above directly (a push rejected as non-fast-forward does mean the remote moved — see the pull note below)."
    fi
  fi
fi
```

**If the count is nonzero** the knowledge write is still uncommitted at
this point, so a plain `pull` can fail with "local changes would be
overwritten." Stash it first (`git -C "<Claude-Code path>" stash`), pull
(`git -C "<Claude-Code path>" pull origin main`), then pop (`git -C
"<Claude-Code path>" stash pop`) — if the pop itself conflicts, resolve by
hand and `git -C "<Claude-Code path>" stash drop` once resolved, since a
conflicting pop leaves the stash entry in place — before retrying the
command above.

**If instead the final branch's push is rejected as non-fast-forward**, the
write is already committed (that branch only runs after `add && commit`
succeeded), so there is nothing to stash — a plain `git -C "<Claude-Code
path>" pull origin main` is enough, then retry the command above to push.

Written for a POSIX shell; translate to PowerShell (same three-outcome
structure: fetch, check its own exit status, then compare the count) on a
machine without git-bash on `PATH`, rather than assuming this block runs
as-is. Deferring the commit here widens the race window `hub-process.md`
separately warns about shrinking by committing immediately — accepted
openly as the cost of the confirmation-gate rule already in force in this
file.

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
**Branch state:** [Step 1.5, per repo touched this session — <repo>: all commits reachable from main, branch verified via ls-remote | <repo>: N commit(s) on <branch> not reachable from main — invisible until merged or PR'd | <repo>: branch had vanished from the remote and was re-pushed — see notes]
**Logged:** [docs/todo.md updated | + Claude-Code/knowledge/<topic>.md updated (cross-project) | + Claude-Code write pending commit (command given in Step 2) | cross-project: none this session]
**Title set:** [Cont-"<title>" | attempted, refused — <reason> | not available in this environment]
**Open follow-ups:** [none | listed, each already reflected in docs/todo.md]
```

Keep it short. If Step 1 surfaced uncommitted or unpushed work, lead with
that.
