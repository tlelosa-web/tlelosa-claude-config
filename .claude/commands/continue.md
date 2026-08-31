---
description: Resume work on tlelosa-claude-config from where the last session ended
---

# /continue — Config Repo Session Resume

Minimal adaptation of `hub-template/continue.md` for this repo itself.
The hub template's session-hygiene steps (Step 0/0.5: `list_sessions`,
`set_session_title`, `archive_session`) are deliberately omitted — those
tools exist on the hub machines, not necessarily here — as is the
`session-log.md` read (this repo keeps no session log) and the CORE.md
upstream check (meaningless inside the source repo itself).

## Step 1 — Orient

Read:
- `docs/todo.md` → task list (Done + Open)
- `dcoe-roster/CORE.md` → if not already read this session per `CLAUDE.md`

Then check repo state. **Fetch first** — this repo is cloned on Operations,
Pappa T, and any number of cloud sessions, so a status report built on stale
remote refs can claim "up to date" against a `main` that moved days ago:

```bash
git fetch origin --quiet
git status --short --branch
git log --oneline -10
```

Uncommitted changes or unpushed commits are part of "where the last
session ended" — surface them, never silently discard or commit them.

## Step 1.5 — Unmerged-Branch Check

Cloud sessions each push a `claude/<slug>` branch and end. Nothing used to
ask whether that work became reachable from `main`, and **nothing about
stranded work looks stranded** — clean tree, zero commits behind, a close-out
that reads like success. A 2026-08-08 audit found 16 such branches across
this repo and the hub, holding an ADR another file already claimed existed
and a finished three-part initiative nobody could see.

**First, prune stale refs — this loop is only as good as the cache it reads.**
Step 1's `git fetch origin --quiet` does not delete local tracking refs for
branches removed upstream, so a branch deleted from the remote after being
pushed still appears here as if it exists, and `git status` still reads "up
to date" from that same stale cache — confirmed for real in
`ai-product-factory` (2026-08-20): a branch pushed successfully in one turn
was gone from the remote by the next session's close-out check, with no PR,
merge, or force-push visible from the session that pushed it, and nothing
locally ever re-verified it. Re-fetch with `--prune` before this loop, and
separately verify the branch this session is actually resuming:

```bash
git fetch origin --prune --quiet
git ls-remote --heads origin refs/heads/$(git rev-parse --abbrev-ref HEAD)
```

If that second command returns nothing, this session's own current branch
doesn't exist on the remote despite what `git status` claimed — report it
in Step 3 as a blocker, not folded silently into "clean." Then run the
unmerged-branch scan against the now-pruned cache:

```bash
git for-each-ref --format='%(refname:short)|%(committerdate:short)' refs/remotes/origin
```

For each ref that is not `origin/main` and not `origin/HEAD`:

```bash
git merge-base --is-ancestor <ref> origin/main
```

Non-zero exit = not contained in `main`. Report the count in Step 3, detail
at most the 5 oldest (name, age, commits ahead), and flag anything over 7
days.

Three rules, each learned the expensive way:

1. **Compare against `origin/main`, not the merge-base** — a merge-base diff
   reports already-landed content and leads straight to the wrong conclusion.
2. **Unmerged ≠ lost.** Content often lands by another path; verify per-file
   before concluding a branch holds anything.
3. **Report only.** Never merge, PR, or delete from this step. Verdicts for
   the currently-open branches are in
   `docs/specs/2026-08-08-branch-triage-verdicts.md`; two are deliberately
   held pending owner decisions, so their appearance here is expected.

## Step 2 — Identify Scope

Classify the next task per `CLAUDE.md`'s "How DCOE applies here":
- **Single-file markdown/JSON edit** → straight to Execute once confirmed.
- **Structural** (new plugin, schema change, > 2 files, anything altering
  what other machines install) → a spec in `docs/specs/` must exist or be
  written first.

## Step 3 — Report State

```
## Session Resume

**Last completed:** [from todo.md Done / recent commits]
**Next task:** [from todo.md Open]
**Type:** [single-file edit | structural]
**Spec:** [exists at docs/specs/<name>.md | MISSING — write before building | N/A]
**Working tree:** [clean | uncommitted changes / unpushed commits — listed]
**Branch state:** [Step 1.5 — all remote branches merged | <N> unmerged, oldest <branch> (<days>d, <M> ahead) — ⚠️ <K> over 7 days]
**Blockers:** [none | description]

Ready to proceed? Confirm and I'll start.
```

**Always follow the prose block with a selectable list** via
`AskUserQuestion` (single question, single-select unless items are clearly
independent), built from every open item in `docs/todo.md` plus anything
surfaced above. Standing preference inherited from the hub template —
never leave Tebello to respond in free text only.

## Step 4 — Wait for Confirmation

Do not begin implementation. Do not open files beyond the reads above.
Wait for Tebello to confirm the task or redirect.

## Spec Gate Reminder

If the next task is structural and no spec exists in `docs/specs/` →
surface this immediately. Spec must be written and confirmed before
implementing.
