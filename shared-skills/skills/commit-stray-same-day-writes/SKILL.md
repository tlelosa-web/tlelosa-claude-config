---
name: commit-stray-same-day-writes
description: Use before any commit or session close-out in a repo where several sessions run in the same day — especially when asked to wrap up, commit a session log, or commit notes written earlier. Trigger whenever a `git add` is about to be scoped to "the files this session touched": a file written by an earlier session that never got committed is exactly what a scoped add misses, and it then sits untracked indefinitely with no error from any session. Review every line of a plain `git status`, not just your own work, and surface stray writes by name before committing. Skip only if the repo genuinely has one session at a time and `git status` has already been read in full this session.
---

## Why this exists

A close-out report says *"Session log: docs/session-logs/<date>.md"* the moment
the file is **written**. But where the convention is "never commit without
explicit confirmation," writing and committing are two separate moments, and
nothing forces the second one to happen.

In the confirmed instance, an unrelated same-day session — a different topic
entirely — ran its own close-out in between, read the current `docs/todo.md`,
updated it, and committed. Its `git add` covered only the files **it** touched,
not the still-uncommitted session log from the earlier session. Both close-out
reports read as complete, and **neither was lying**: each accurately described
its own session's state at the moment it ran. The gap existed only *between*
them, invisible to both.

This is the same shape as a push that doesn't survive, one layer earlier: a
successful `Write` is not proof the file stays tracked through whatever commits
happen next in the same working tree. Multi-session same-day work on one repo
is normal, not an edge case — the confirmed repo had five-plus distinct
same-day sessions on the day this was found.

`git status` would have caught it instantly. It simply was never run, because
the second session had no reason to imagine a first session's write was still
sitting there.

## Steps

1. **Run a plain `git status` first — and read every line.** Not
   `git status -- <the files I touched>`, and not a mental list of your own
   edits. The whole thing.

   ```bash
   git status --porcelain=v1 -b
   ```

2. **Treat anything you did not write as a finding, not noise.** Check whether
   it is a legitimate write from another session — a session log, a knowledge
   entry, a spec — that simply never got committed.

3. **Surface it by name before committing**, and let the owner decide.
   Do not silently fold it into your commit, and do not silently leave it.
   Name the file, say which session it looks like it came from, and say what
   you propose.

4. **Prefer separate, honestly-scoped commits** when the stray work is a
   different concern from yours. One commit per concern keeps each revertable
   and keeps the stray work's own message truthful about where it came from.

5. **Check the unpushed side too.** `## branch...origin/branch [ahead N]` in
   that same output means committed-but-not-delivered work, which a scoped
   `git add` also would not have told you about.

## Generalising

Any "write now, commit or publish later on confirmation" pattern has this gap
whenever something else can commit in between. The window is not exotic — it
opens every time two agents, two sessions, or a person and an agent share one
working tree. The fix is always the same: before the commit, look at the whole
tree, not at your own diff.

## Evidence this pattern recurs

`ai-product-factory`, 2026-09-03: a session log written during one
`/continue` + close-out pair was found untracked by a later same-day close-out,
after an unrelated intervening session had already committed `docs/todo.md`.
**It then recurred the same day** — the very session that fixed the first
instance wrote its own todo edit and session log and never committed those
either, found by the next session's cross-repo check. Two strikes in one day.
Found a third time on 2026-09-11: nine files from two prior sessions, one of
which had no shell tool at all and therefore *could not* commit, sitting in the
tree for a later session to notice.
