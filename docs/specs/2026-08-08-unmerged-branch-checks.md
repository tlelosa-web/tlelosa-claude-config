# Spec — Unmerged-branch checks in `/continue` and `/session-end`

**Date:** 2026-08-08
**Status:** Draft — awaiting owner approval
**Owner:** Tebello Lelosa
**Type:** Structural — changes both `hub-template/` commands and both of this
repo's own instances, so it alters what every vault copies in.
**Plan:** `docs/specs/2026-08-08-system-maintenance-plan.md`, Phase 6

## Problem

The 2026-08-08 systems check found **16 branches across two repos, unmerged,
with no open PR**, holding finished and reviewed work: a bootstrap script
that closed a todo item outright, an ADR another file already claimed
existed, three `knowledge/` files, and a complete three-gap initiative built
across both repos.

None of that was a mistake by any one session. It is systemic, and the
mechanism is specific:

1. A cloud session does its work and pushes a `claude/<slug>` branch.
2. It ends. Nothing asks whether that work is reachable from `main`.
3. The next session starts from `main`, cannot see the branch, and has no
   step that would look.
4. Repeat for four weeks.

Every session in that loop ends *believing it delivered*. The work is
committed, pushed, and green — it is simply invisible from the only branch
anyone reads. The failure has no symptom: `git status` is clean,
`rev-list HEAD..origin/main` is `0`, and the session log reads like a
successful close-out. It is the same shape as the Step 1.9 staleness problem
the template already solves, one level up: **nothing about stranded work
looks stranded.**

Phase 2 of the maintenance plan recovered the current backlog. Without this
phase, the backlog refills, and the next systems check finds sixteen more.

## Decision

Two checks, deliberately not one, because they answer different questions at
different moments.

### `/session-end` — outbound: *don't strand your own work*

The closing session is the only one that knows what it just built. It is
also the last moment anyone will look at that branch on purpose. A new
**Step 1.5** runs after the working-tree check and asks whether this
session's commits are reachable from the default branch — and if not, says
so in the close-out report, naming the branch.

### `/continue` — inbound: *find what earlier sessions stranded*

The closing check cannot help with work already stranded, and a session that
ends badly (context exhausted, interrupted, container reclaimed) never runs
`/session-end` at all. So the resuming session also looks — a new **Step
1.8**, placed after Step 1.75's fetch (checking against a stale remote ref
answers the wrong question) and before Step 1.9.

### Both checks report; neither acts

Consistent with Step 1.9's existing discipline: surfacing drift does not make
resolving it this session's task. Neither check pushes, merges, opens a PR,
or deletes anything. `/session-end` in particular already carries "never
commit or push on Tebello's behalf just because `/session-end` is running" —
this must not become the exception.

### Design calls made here

| Decision | Choice | Why |
|---|---|---|
| Staleness threshold | **7 days** | Reuses the template's existing Step 0.5 stale/idle rule rather than inventing a second number. One convention, not two. |
| Output cap | Report all counts; list at most the **5 oldest** in detail | Sixteen branches would otherwise bury the resume report it lives inside. |
| Branch scope | Remote branches only (`refs/remotes/origin`) | Local-only branches are that machine's business; the failure mode is work pushed and then lost. |
| Merged-branch cleanup | **Out of scope** | Deleting branches is irreversible and belongs to a triage decision, not an automatic step. The check reports; a human deletes. |
| Blocking | **Never** | A warn-only signal, like every other check in these files. A close-out that refuses to close is a close-out people stop running. |

## Exact changes

### 1. `hub-template/session-end.md` — new Step 1.5

After Step 1 (working tree), before Step 2 (task queue):

```bash
git rev-parse --abbrev-ref HEAD
git log --oneline origin/<default-branch>..HEAD
```

If HEAD is not the default branch and the second command returns commits,
report in Step 4:

> **Branch state:** N commit(s) on `<branch>` not reachable from
> `<default>`. This work is invisible to any session that starts from
> `<default>` until it is merged or a PR is opened.

Never open the PR. Report a pass in one line too — silence and never-ran
look identical.

### 2. `hub-template/continue.md` — new Step 1.8

Placed after Step 1.75, before Step 1.9, with a note on why the ordering
matters.

```bash
git fetch origin --quiet
git for-each-ref --format='%(refname:short)|%(committerdate:short)' refs/remotes/origin
# for each ref that is not the default branch:
git merge-base --is-ancestor <ref> origin/<default-branch>
```

Refs failing the ancestor test are unmerged. Report count, and detail the 5
oldest: name, age in days, commits ahead. Flag anything older than 7 days.

Two warnings written into the step, both learned the expensive way during
the systems check:

- **Diff against `origin/<default>`, not the merge-base.** A merge-base diff
  on a repo whose default branch absorbed a large merge shows tens of
  thousands of misleading lines. Branch-vs-default answers "what does this
  branch have that the default lacks"; merge-base does not.
- **A branch being unmerged by ancestry does not mean it holds lost work.**
  Content can land by another path. Verify per-file before concluding
  anything, and never delete on ancestry alone.

### 3. `.claude/commands/continue.md` (this repo's instance)

Its Step 1 currently runs `git status` and `git log` with **no fetch**, so
its report is built on possibly-stale refs. Add a fetch plus a scoped-down
unmerged-branch check. No cross-repo staleness check (single repo), no
session-log (this repo keeps none).

### 4. `.claude/commands/session-end.md` (this repo's instance)

Same Step 1.5 as the template, minus the vault-specific wording.

### 5. `hub-template/HUB-CHECKLIST.md`

A reconciliation item so a vault that copied these commands before today
learns it needs to re-copy — the checklist previously only handled a
*missing* command file, which is exactly the gap PR #14 found.

## Commit boundaries

1. `hub-template/continue.md` — Step 1.8
2. `hub-template/session-end.md` — Step 1.5
3. Both `.claude/commands/` instances (one task: this repo adopts its own
   template change)
4. `HUB-CHECKLIST.md` reconciliation item
5. `docs/todo.md`

## No version bump

`hub-template/` is copy-source, not a plugin — it ships in no manifest and
`CORE.md` is untouched. This does **not** join the pending
3.6.0 / CORE 1.4 / v3.5 rollout. Adoption is per-vault re-copying, tracked
as its own todo item.

## Acceptance criteria

- `/session-end` reports, in every close-out, whether the session's commits
  are reachable from the default branch — including when they are.
- `/continue` reports unmerged remote branches with ages, flags any over 7
  days, and caps its detail at 5.
- Neither command pushes, merges, opens a PR, or deletes a branch.
- This repo's own two instances carry the checks, not just the templates.
- `/continue` in this repo fetches before reporting git state.
- Running `/continue` against this repo today would surface the 3 config-repo
  branches still held open — the check is testable against a known answer.

## Out of scope

- Automatic branch deletion or PR creation.
- Adopting the change into the `Claude-Code` hub's own copies — a separate
  repo, tracked as a todo item.
- The 13 hub branches and 3 config branches still open; their verdicts live
  in `docs/specs/2026-08-08-branch-triage-verdicts.md` and two are held
  pending owner decisions.

## Codex second opinion

**Not run** — codex-gate is Pappa T-only and this was written from a cloud
container. Same standing gap as the model-routing spec; tracked in
`docs/todo.md` rather than left to lapse.

## Revision history

- **2026-08-08** — first draft, from Phase 6 of the maintenance plan.
