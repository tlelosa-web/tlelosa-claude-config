# Spec — `docs/todo.md` Done entries must cite a verified SHA

**Date:** 2026-08-12 | **Status:** Revised after BLOCK — re-entering review
**Basis:** Six Done entries in three days asserted a landing that didn't actually exist when
written. Each was a care failure, and the fix should be mechanical.

## Revision note (responds to BLOCK)

The first draft's verification command (`git log origin/main --oneline -- <path>`) does not
detect the failure it exists to catch: it returns history for any file ever touched on
`origin/main`, so a session's *unlanded* edit to an *already-tracked* file still produces
non-empty output and passes. That covers only new-file incidents (2 of the 6 motivating
cases), not changed-file incidents (the other 4 — including the ADR-010 and PR-template
entries, both edits to existing files). This revision replaces the command, fixes a Hard
Rule 10 violation in the original's network-dependency claim, replaces a fabricated worked
example with a verified one, adds a pending state, and narrows the file list to what this
repo actually contains. See "Revision history" at the end for the full list against the
reviewer's BLOCK.

## Problem

Care failures from 2026-08-09 through 2026-08-12:

1. **ADR-010 false claim** (two counts): stated it was landed and merged, but it sat unmerged
   for a day while the queue recorded it done.
2. **PR template landing** (2026-08-09): recorded as complete for both repos; half landed one
   day late.
3. **`/retro` landing** (2026-08-10): recorded as complete on 2026-08-09; actually landed
   2026-08-10 by cherry-pick.
4. **"Byte-identical to `main`" claim** (2026-08-08): asserted as a reason to delete a branch;
   claim was wrong when written.
5. **Branch-check addendum** (2026-08-09): written the same day as the entry it amended; the
   amendment was stale when typed (the "3 commands" claim was wrong; only 1 was outstanding).
6. **`/overwatch` item held on a deleted branch** (2026-08-09): recorded as present; the branch
   no longer existed by the time it was read.

Each succeeded with wrong state instead of failing, because the gap between "wrote it down" and
"verified it's true" is where the bugs hide. Commit-time verification isn't enough — when a
session writes an entry during its own work, that entry is describing a thing that exists only
in the session's local copy: a merged branch, a pushed commit, a merged PR. The entry is fact
only if the reader can independently verify it, against the *actual* remote — not a cached
guess at it.

## What

Modify `/session-end` to require a verified SHA citation when recording a Done entry that
claims a file was delivered. **This repo has two instances of that command** (see "Scope" —
the third named instance in the original draft is in a different repository):

- `hub-template/session-end.md`
- `.claude/commands/session-end.md`

Specifically:

A Done entry claiming a file landed on the default branch (whether a feature, a fix, a
documentation update, or a command copy) must, after a fresh `git fetch`, verify with:

```bash
git fetch origin
git diff --quiet origin/main -- <path> && git log origin/main --oneline -1 -- <path>
```

If the `diff --quiet` exits 0 (no difference between the local file and what's on
`origin/main` — the content is landed), the `git log` half runs and prints the citation SHA.
If `diff --quiet` exits non-zero (local content differs from `origin/main`, or the file isn't
there at all), nothing prints and the entry is not written as Done — see "Pending state"
below for what to do instead.

## Verification command: choice and rationale

Two options were on the table; `git diff` was chosen.

**`git diff origin/main -- <path>`** (chosen) — empty output means the file's current local
content is byte-identical to what's on `origin/main`. This directly answers the question a
Done entry is making a claim about ("is this file, as I have it, actually on the branch
anyone else reads") and cannot be fooled by unrelated history on the same path — the exact
bug in the original draft. It needs no SHA in hand before running, so it works uniformly for
new files and changed files alike, and for a Done entry written before the session has looked
up which specific commit is responsible.

**`git merge-base --is-ancestor <sha> origin/main`** (not chosen, but not wrong) — this repo
already uses it successfully elsewhere: `/session-end` Step 1.5 and `/continue` Step 1.8
(`docs/specs/2026-08-08-unmerged-branch-checks.md`), and a live example sits in this repo's
own `docs/todo.md` right now (2026-08-12 entry citing `git merge-base --is-ancestor <sha>
origin/<default-branch>` for three cross-repo PRs). It answers a related but different
question — "is this specific commit reachable from the default branch" — which requires
already knowing the commit SHA to test. That's the right tool for *branch*-level reachability
checks (is this session's work stranded), which is what Step 1.5/1.8 use it for. For a
*file*-content claim in a Done entry, `git diff` is more direct: it doesn't presuppose which
commit the session thinks is responsible, so it can't be defeated by citing the wrong SHA and
having it happen to also be an ancestor of `origin/main` via an unrelated path.

Either command detects the actual failure (unlike the original's `git log`); `git diff` was
picked for directness. A repo that already leans on `merge-base --is-ancestor` for branch
checks may reasonably standardize on it instead for consistency — that's a style call, not a
correctness one.

## Hard Rule 10 compliance (fixes the original's violation)

The original draft argued reading a locally cached `origin/main` was a *feature*
("no network dependency and no new blocker" for cloud sessions). That is a direct violation
of CORE Hard Rule 10: *"Verify remote state before asserting it. ... `git fetch` the relevant
ref and check it — never answer from a locally cached branch ref that may be stale."* A Done
entry is exactly the kind of remote-state assertion the rule targets, and this spec's whole
premise is that stale/cached answers are what caused the six incidents in the first place —
reusing a cached ref inside its own fix would reproduce the class of bug it exists to close.

**Fix:** the verification command block above opens with `git fetch origin`, unconditionally,
every time, immediately before the `diff`/`log` check. This is cheap (a no-op if nothing
changed) and was demonstrated live in this session: `git fetch origin` run while drafting this
revision moved `origin/main` forward two commits (`b94af54..89ff3c3`) that the previously
cached ref did not have — concrete evidence that skipping the fetch would have checked the
Done claim against stale state.

No exception is claimed for this check. Hard Rule 10 applies in full.

## Pending state (new — addresses PR-merge lag)

PR merge lag is routine in this repo: sessions frequently end with a PR opened but not yet
merged (the ADR-010 and PR-template incidents are exactly this). The original draft only
defined Done and "blocked, don't write the entry," which left no way to record "PR opened,
awaiting merge" — a true and useful statement that isn't Done and shouldn't be silently
dropped.

This follows the escape-hatch pattern CORE Hard Rule 11 already established for the adjacent
problem ("A record is not a control" — a session that can't yet install a lesson executably
"file[s] a queue item in `docs/todo.md` naming the exact file that needs to change";
`docs/specs/2026-08-12-record-is-not-control.md`): when verification doesn't pass yet, don't
block silently and don't claim Done — queue it.

**New entry state, distinct from `[x]` Done:**

```
- [ ] Delivered `<path>` — PR #<NN> opened, awaiting merge. Verification
      pending: `git diff origin/main -- <path>` was non-empty as of
      <date>. Promote to [x] with a SHA citation once merged and re-verified.
```

This goes in `docs/todo.md`'s `## Open` section (the existing queue, same place Hard Rule 11
items go), not in `## Done`. A session finding an item in this state on a later pass re-runs
the verification command; if it now passes, the entry is promoted to Done with the citation
per the "What" section above. If it still fails, the pending entry stays, unchanged except for
an updated "as of" date if meaningfully stale.

This gives three states, not two:

| State | Marker | Meaning |
|---|---|---|
| Done | `[x]` in `## Done` | Verified landed; SHA cited. |
| Pending | `[ ]` in `## Open`, "awaiting merge" wording | Work exists (commit/PR), not yet landed; re-check next session. |
| (not recorded) | — | Nothing to record yet — work not pushed at all. |

## Examples

**Before (unverifiable claim):**
```
- [x] Landed `hub-template/retro.md` — now installed on Pappa T. PR review tracked
      in the hub's session-log.
```

**After (verified, real example from this repo's history):**
```
- [x] Landed `hub-template/retro.md` (commit 9914e0b) — now installed on Pappa T.
      Verified: git fetch origin; git diff origin/main -- hub-template/retro.md
      returned empty; git log origin/main --oneline -- hub-template/retro.md
      shows 9914e0b as the commit ("Land retro.md, the last unlanded file on
      either repo's branches", 2026-08-09).
```

This is independently checkable by anyone with the repo cloned:

```bash
git fetch origin
git diff origin/main -- hub-template/retro.md     # → empty
git log origin/main --oneline -- hub-template/retro.md | head -1
# → 9914e0b Land retro.md, the last unlanded file on either repo's branches
```

**Pending example (PR open, not yet merged):**
```
- [ ] Delivered `docs/specs/2026-08-12-example.md` — PR #31 opened, awaiting
      merge. Verification pending: `git diff origin/main -- docs/specs/
      2026-08-12-example.md` was non-empty as of 2026-08-12. Promote to [x]
      with a SHA citation once merged and re-verified.
```

## Mechanics

Add a new sub-step to `/session-end`'s verification phase (both instances in this repo):

**Step 3.5 — For each file the session says it delivered (added or changed), verify it landed
on the repo's default branch:**

```bash
git fetch origin

# For a changed or new file in the target repo:
git diff --quiet origin/main -- <file> && git log origin/main --oneline -1 -- <file>
# e.g. hub-template/retro.md

# Exit 0 + a printed line: content is landed. Record the Done entry with the
# printed short SHA — see Examples above.
#
# Exit non-zero (nothing printed after &&): the file's current content is not
# on origin/main. Do not write a Done entry. If a PR is open, write a Pending
# entry instead (see "Pending state" above) in docs/todo.md's Open section.
```

This replaces the current step's prose check "was it merged/pushed?" with a command that
produces a verifiable answer and, when it passes, the citation as a side effect.

## Scope

**This repo contains two instances of `/session-end`**, both in scope for this
implementation:

- `hub-template/session-end.md`
- `.claude/commands/session-end.md`

The original draft named a third instance, `Claude-Code/.claude/commands/session-end.md`.
That path does not exist in this repo — `Claude-Code` is a separate repository not checked
out here. The "three instances" framing is accurate for a comprehensive rollout across every
vault that copied `hub-template/session-end.md`, but this spec's Implementation phase touches
only the two paths above. Adopting the change into the `Claude-Code` hub's own copy is a
separate cross-repo task, tracked as its own `docs/todo.md` item (same handling the
unmerged-branch-checks spec used for the identical gap — see its "Out of scope" section).

## Impact

**Command files (two instances in this repo):** adds a new verification sub-step plus the
pending-state escape hatch, roughly 15 lines of inline prose + two code blocks (verification
command, pending-entry template). No logic change to the rest of the command; more explicit
verification with a defined non-Done outcome.

**No version bump needed:** neither instance is versioned —
`hub-template/session-end.md` is copy-source, not a plugin; `.claude/commands/session-end.md`
is a per-project command file.

**No CORE.md change:** this is an instance of Hard Rule 10 ("Verify remote state before
asserting it") applied narrowly to Done entries, and reuses Hard Rule 11's existing queue-item
escape hatch for the pending case. Neither rule's text needs to change.

## Acceptance criteria

1. A session that writes a Done entry naming a delivered file first runs `git fetch origin`,
   then the verification command, and records the resulting SHA only if `git diff` was empty.
2. If the verification command's `diff` is non-empty (file not landed with matching content on
   `origin/main`), the entry is not written as Done. If a PR is open for it, a Pending entry is
   written in `docs/todo.md`'s Open section instead (per "Pending state"); if no PR exists yet,
   nothing is recorded.
3. On a future re-read of `docs/todo.md`, a Done entry with a SHA can be spot-checked by
   anyone with access to the repo: `git fetch origin && git diff origin/main -- <file>` returns
   empty, and `git log origin/main --oneline -- <file> | head -1` shows the cited SHA.
4. The worked example (`hub-template/retro.md`, commit `9914e0b`) is independently verifiable
   against this repo's actual git history using the commands shown in "Examples."
5. A Pending entry is visually and structurally distinct from a Done entry (different section,
   different checkbox state, explicit "awaiting merge" / "verification pending" wording) and
   carries enough information (path, PR number, date, what was checked) for a later session to
   re-verify and promote it without re-deriving context.
6. Hard Rule 10 is satisfied: the verification command block always fetches before checking,
   with no cached-ref exception claimed anywhere in this spec.

## Non-issue check

**Cloud sessions:** `git fetch origin` works in a cloud container the same as anywhere else —
it is a normal network operation, not an obstacle. The original draft's claim that skipping
the fetch was safe because it had "no network dependency" is the Hard Rule 10 violation this
revision fixes (see above); the corrected step has a network dependency by design, and that is
correct, not a cost to route around.

**Multi-file deliverables:** if one session's work touches multiple files and claims to have
delivered all of them, each file needs its own verification (and, if mixed, may produce a mix
of Done and Pending entries for the same session). That's expected to be the exception — most
Done entries name one file or one coherent change.

## Revision history

- **2026-08-12** — first draft, from the six-incident review.
- **2026-08-12** — **BLOCKED** by reviewer. Structural defects: (1) verification command
  (`git log origin/main --oneline -- <path>`) doesn't detect the motivating failure — passes
  for any previously-touched file regardless of whether the session's edit landed, catching
  only 2 of 6 incidents; (2) Hard Rule 10 violation — defended cached-`origin/main` reads as a
  feature; (3) worked example cited a nonexistent SHA (`b7ceebb`); (4) no way to record
  routine PR-merge lag other than blocking the entry outright; (5) named a third
  `/session-end` instance (`Claude-Code/...`) that isn't in this repo.
- **2026-08-12** — revised to address all five: swapped verification command to
  `git diff origin/main -- <path>` (with rationale against the `merge-base --is-ancestor`
  alternative and citation to this repo's existing use of it), added a mandatory `git fetch
  origin` ahead of every check, replaced the worked example with a verified one
  (`hub-template/retro.md`, commit `9914e0b`, confirmed against this repo's actual history),
  added an explicit Pending state modeled on Hard Rule 11's queue-item escape hatch, and
  narrowed "Impact"/"What" to the two `/session-end` instances that actually exist in this
  repo, with the third tracked separately.
