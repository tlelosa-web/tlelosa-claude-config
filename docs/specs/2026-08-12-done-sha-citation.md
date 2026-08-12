# Spec — `docs/todo.md` Done entries must cite a verified SHA

**Date:** 2026-08-12 | **Status:** Draft — awaiting reviewer approval before implementation
**Basis:** Six Done entries in three days asserted a landing that didn't actually exist when
written. Each was a care failure, and the fix should be mechanical.

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
only if the reader can independently verify it.

## What

Modify every instance of `/session-end` command (three files: `hub-template/session-end.md`,
`tlelosa-claude-config/.claude/commands/session-end.md`, `Claude-Code/.claude/commands/session-end.md`)
to require a verified SHA citation when recording a Done entry that claims a file was delivered.

Specifically:

A Done entry claiming a file landed on `main` (whether a feature, a fix, a documentation update,
or a command copy) must cite the commit that added or changed that file, verified with:

```
git log origin/<default-branch> --oneline -- <path>
```

before the entry is written. The citation goes inline in the entry as a short commit reference
(`<7-char-SHA>` or `SHA: <full-hash>`).

## Examples

**Before:**
```
- [x] Landed `hub-template/retro.md` — now installed on Pappa T. PR review tracked
      in the hub's session-log.
```

**After:**
```
- [x] Landed `hub-template/retro.md` (commit b7ceebb) — now installed on Pappa T.
      Verified: git log origin/main --oneline -- hub-template/retro.md returned
      b7ceebb as most recent.
```

The verification step is quick (single `git log` call) and can be done as part of
`/session-end`'s **Step 3.5** (Verify outbound state). A failure to find the commit blocks
the entry from being written — the Done list only records deliverables that are actually
delivered.

## Mechanics

Add a new sub-step to `/session-end`'s verification phase (all three instances):

**Step 3.5 — For each file the session says it delivered (added or changed), verify it landed
on the repo's default branch:**

```bash
# For a changed file in the target repo:
git log origin/main --oneline -- <file>  # e.g. hub-template/retro.md

# If the output is empty, the file is not on origin/main yet —
# done entry is blocked until the push is confirmed.

# If the output shows the commit, record the short SHA:
# [x] Delivered <file> (SHA: b7ceebb) ...
```

This replaces the current step's prose check "was it merged/pushed?" with a command that
produces a verifiable answer. The command is portable (works on any repo), deterministic
(git's output is stable), and produces the citation as a side effect.

## Impact

**Command files (all three instances):** adds a new verification sub-step, roughly 6 lines
of inline prose + one code block showing the command. No logic change; just more explicit
verification.

**No version bump needed:** the three `/session-end` instances live in:
- `hub-template/session-end.md` — not a plugin, not versioned
- Two project copies — not versioned per-project

**No CORE.md change:** this is an instance of Hard Rule 10 ("Verify remote state before
asserting it"), applied narrowly to Done entries.

## Acceptance criteria

1. A session that writes a Done entry naming a delivered file also runs the verification
   command and records the resulting SHA.
2. If the verification command returns empty (file not on origin/main), the entry is not
   written — the session reports "not yet merged" and stops.
3. On a future re-read of `docs/todo.md`, a Done entry with a SHA can be spot-checked by
   anyone with access to the repo: `git log origin/main --oneline -- <file> | head` and
   verify the SHA is present.

## Non-issue check

**Cloud sessions:** `git log origin/main` works fine in a cloud container (it's a local query
against the fetched remote-tracking branches). The verification step has no network dependency
and no new blocker.

**Multi-file deliverables:** if one session's work touches multiple files and claims to have
delivered all of them, each file needs its own verification. That's expected to be the
exception — most Done entries name one file or one coherent change.
