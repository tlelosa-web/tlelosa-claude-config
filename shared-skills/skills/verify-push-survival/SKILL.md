---
name: verify-push-survival
description: Use before treating any `git push` as durably delivered — when confirming a push landed, closing out a session, ending a container, or answering "is my work safe on the remote?" Trigger whenever `git status`, `git branch -vv`, or a remembered push-success message is about to be used as evidence that a branch is still on the remote: all three read a local cache that never self-invalidates, so a branch deleted upstream still reads "up to date" with zero local symptoms. Also trigger for the general shape — a client-side success message being treated as proof a write is still true later (a cloud save, a deploy, a database commit). Skip only when the remote has already been queried directly in this session with `git fetch --prune` + `git ls-remote`.
---

## Why this exists

`git push -u origin <branch>` reported success — `[new branch]`, tracking set
up. Later in the same session, `git status` and `git branch -vv` both still read
"up to date with 'origin/<branch>'". The branch was **gone from GitHub**,
confirmed independently through the GitHub API. No PR had been opened against
it, no merge touched it, and nothing in that session force-pushed.

The mechanism is ordinary git behaviour, not a bug: `git fetch` **without
`--prune`** does not delete local remote-tracking refs for branches removed
upstream, and `git status` / `git branch -vv` read that same local cache rather
than the remote. So the sequence *push succeeds → branch disappears upstream →
every later local git command still says clean and up to date* produces **zero
local symptoms**. Nothing on the machine will tell you. The only thing that
catches it is asking the remote directly.

A successful push message is a **point-in-time claim, not a durability
guarantee**. "Push succeeded" and "the work is safe" are different statements,
and the gap between them is invisible from inside the pushing session.

## Steps

1. **After any `git push`, before treating the work as delivered** — at a
   session close-out, before ending a session or container, or whenever asked
   to confirm a push landed — query the remote itself:

   ```bash
   git fetch origin --prune --quiet
   git ls-remote --heads origin refs/heads/<branch>
   ```

   Compare the SHA it prints against `git rev-parse HEAD`. Matching SHAs are
   the evidence; a "clean" working tree is not.

2. **`--prune` is not optional.** Without it, a deleted remote branch's local
   tracking ref survives and keeps answering "up to date" from stale cache —
   which is precisely the trap. A plain `git fetch` does not close this.

3. **If the branch is missing despite a successful push**, confirm the commits
   are still intact locally (`git log --oneline`, `git branch -vv`), re-push,
   and re-verify with the **same** ground-truth check. Do not trust the second
   push's success message either.

4. **Do not silently fix and move on.** A branch vanishing with no visible
   cause is worth naming explicitly even once it is re-pushed — a future
   session, or a person, needs to know it happened, not just that things look
   fine now.

5. **Report the check, not just the outcome.** "Verified with `ls-remote`:
   remote and local both at `<sha>`" is checkable. "Pushed successfully" is the
   claim this skill exists to distrust.

## Generalising past git

Any "did my write land, and is it *still* landed?" question has this shape
whenever the client-side view of success is itself a cache: a cloud save, a
deployed config, a database commit behind a connection pool. If the thing
telling you it worked is the thing that would also be stale, it is not
evidence. Go ask the system of record.

## Evidence this pattern recurs

`ai-product-factory`, 2026-08-20: branch `claude/continuation-2gbew7` pushed
successfully and was gone from the remote by the next check, caught only by
`git fetch --prune` + `git ls-remote`, never by `git status`'s cached view. The
cause of the upstream deletion was never explained — which is exactly why the
check, rather than an explanation, is the control. The check is now a standing
step in `/session-end` across every hub that copies from this config.
