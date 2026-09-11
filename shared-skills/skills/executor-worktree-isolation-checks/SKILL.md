---
name: executor-worktree-isolation-checks
description: Use at BOTH ends of a worktree-isolated subagent dispatch — when about to merge a finished Executor's worktree branch (the moment the leak is detectable), and when about to dispatch one. Trigger on "the Executor finished, merge its branch", on dispatching any agent with `isolation: worktree` or a self-isolating executor type, and whenever two background agents run concurrently. Two independent failures share this trigger: the harness can hand out a stale or double-booked worktree (base commit behind master), and the agent's own first `npm install`/build command can run against the shared main checkout instead of its worktree, leaking uncommitted changes into master. An agent's final report saying it self-corrected is not evidence nothing leaked. Skip only for read-only agents, which need no isolation.
---

## Why this exists

Two distinct failure modes, one trigger. Both are silent, and both are caught
by the same two checks.

**The harness hands out the wrong worktree.** Dispatching an `executor`-type
agent — with `isolation: worktree` or the type's own default sandboxing — is
supposed to create a fresh worktree branched from current `HEAD`. It does not
always. Observed twice in a row with different agent IDs landing on the *same*
stale commit, several merged tasks behind master, and separately as two live
agents double-booking one worktree slot. An agent that does not check its own
base will "succeed" while working from stale code — redoing fixed work, or
reintroducing a closed bug.

**The agent runs its first command in the wrong directory.** Here the harness
assigns the *correct* isolated worktree, but the agent's own first
environment-mutating command (`npm install`, then later `npm run build`) targets
the shared main checkout anyway — apparently because its default cwd at the
start of the turn is the shared checkout, and an early command runs before it
`cd`s. Both observed instances were self-caught by the agent and redone
correctly, **and both still left uncommitted changes sitting in master's
working tree.**

That last point is the one that matters most: in one case the agent reported
the mistake was *"caught by the harness's file-write guard before any file was
modified there."* It was not — a `next build` had already regenerated a
precache manifest in the shared checkout. **The agent's self-report undersold
what leaked, both times.** Since these repos are frequently worked by
concurrent dispatches, a stray write to the shared checkout is a real
corruption risk for a different agent or for your own git operations.

## Steps — at the merge moment

1. **Run `git status` on the main checkout before merging anything**, even when
   the agent's final report claims a clean self-correction. This is the only
   check that reliably catches the leak, and the report is not a substitute
   for it.

2. **If a stray change is there, do not discard it blindly.**
   `git stash push -u -m "<reason>"` first — reversible. Merge the agent's
   actual commit, then diff the stash against the merged result. Identical is
   the common case (the same dependency or build artifact the real commit also
   adds) and the stash can be dropped. Different means investigate before
   dropping.

3. **Weigh the category, but still verify.** A regenerated build artifact
   (`sw.js`, `dist/`) is lower-risk than an edited source file — but you often
   cannot tell which you have from the `git status` summary alone, so
   stash-and-verify rather than assume.

## Steps — at the dispatch moment

4. **Make the agent's very first action a self-check** of the worktree it was
   handed: confirm the branched-from commit matches the expected recent SHA
   (`git log --oneline -3`), confirm there are no pre-existing uncommitted
   changes, and **stop and report** if either is wrong rather than proceeding.
   This is what caught the stale-worktree bug in the first place.

5. **Instruct it to `cd` and confirm before any install or build**:
   *"before running any command that installs a dependency or builds the
   project, `cd` into your assigned worktree path and confirm with `pwd` /
   `git rev-parse --show-toplevel` that you are there — do not rely on your
   default working directory."* Note honestly: both leak incidents happened
   despite the dispatch prompt already naming the worktree path, so this is
   worth doing but is not proven sufficient.

6. **Do not retry an identical dispatch expecting a different result.** Two
   attempts produced the same stale commit. Either escalate, or fall back to
   direct implementation.

7. **If you fall back to implementing directly, keep the reviewer gate.** A
   read-only reviewer needs no isolation and works fine, so dispatch it against
   the diff exactly as if an Executor had produced it. Losing the Executor step
   is not a reason to lose the review step.

8. **The manual-worktree workaround does work** — an earlier "hard block"
   finding was corrected. Resume the agent with: *"ignore worktree
   auto-assignment entirely; use ONLY this exact path: `<path>`; confirm you
   are in that exact directory before editing; if it does not match, stop and
   report rather than falling back to auto-assignment."* Always pair it with
   that self-verification clause — a wrong path is silent otherwise.

## Evidence this pattern recurs

`Projects/tenders`, 2026-08-20: three consecutive failed dispatches — two stale
worktrees on the identical commit with different agent IDs, plus a
worktree-collision case later the same day. `ai-product-factory` dashboard
Phase 4, 2026-08-21: two stray-write leaks into the shared checkout, both
self-reported as cleanly corrected, both leaving real uncommitted diffs on
master. Five reproductions across two sessions and two distinct sub-failure
modes. No root cause confirmed for either; the checks, not an explanation, are
the control.
