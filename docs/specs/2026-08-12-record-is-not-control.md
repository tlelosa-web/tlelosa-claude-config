# Spec — CORE.md Hard Rule: "A record is not a control"

**Date:** 2026-08-12 | **Status:** Draft — awaiting reviewer approval before implementation
**Basis:** First `/retro` run on 2026-08-10 in the `Claude-Code` hub. Highest-evidence pattern
in the full session log (47 entries, 2026-07-28 → 2026-08-10), and the only one the log had
already diagnosed itself four separate times — yet recurred anyway after each diagnosis.

## Problem

Sessions write findings, decisions, and lessons into `knowledge/` files or commit messages.
Nothing executable changes. The next session cannot act on the recorded fact because it lives only
in text. Two concrete cases from the log:

1. **Commit `ef247bc`** stated the cross-repo staleness check "moved to `/continue`" — it moved
   into `knowledge/hub-process.md`, and the command file went untouched. Three more sessions later,
   `/continue` still lacked the check.

2. **2026-08-08 note** correctly recorded that agent bodies "need a `bootstrap.sh` re-run to
   actually land" — true and never acted on, leaving Pappa T with no `~/.claude/agents/` for
   six weeks until CORE 1.5's `SessionStart` hook + `bootstrap.mjs` automated the step.

The pattern holds even when the note is *correct* — correctness is not the issue. The issue is
that a note is passive; an agent cannot execute a sentence. Only edits to files that Claude Code
or a machine actually runs (a command, a hook, a manifest, a script) change behavior. The
obligation to close the loop cannot be discharged by writing a note.

## What

A new universal hard rule (CORE.md, High impact): **a session that records a lesson must either
install it in an executable location (command file, hook, manifest, deployment script) in the
same session, or file a queue item naming the exact file that needs to change.** Recording alone
never discharges the obligation.

This closes a structural gap in the DCOE's "Decision → Action" loop: decisions written down are
not decisions implemented. A governance system that confuses recording with execution will slowly
fill with forgotten insights.

## Mechanics

The rule applies everywhere **a session records a lesson learned during the task**, not just
knowledge-cache entries:

- **Commit messages** that say "fixed the X problem by changing Y" imply a note about Y belongs
  somewhere (where was it? how do we remember?). If it doesn't yet exist, the commit should add
  it. A message that describes only past work, not future behavior, never needs a follow-up.
- **Knowledge entries** describing a quirk ("the mobile app can't run `/continue`") don't
  discharge the obligation until the entry's own finding is acted on somewhere (the
  CLAUDE.md.template note, the command's Step 2.5 reworded, the FAQ expanded). The finding
  alone is not implementation.
- **Code comments** are a lower bar — a comment inside a function is an artifact of the code
  it annotates, not a separate note. But a "TODO: X is still broken" comment at file scope
  is a forward claim and wants a queue item.

### What counts as "install"

**Install** means the finding is now part of something executable or reusable:
- A command file (`/continue`, `/session-end`, `/retro`, `/codex-review`)
- A hook (a `.claude/hooks/` script or a git hook)
- A manifest (`CLAUDE.md`, `CLAUDE.md.template`, `CORE.md`, a plugin `plugin.json`)
- A deployment/rollout checklist
- A test (if the "lesson" is a bug that mustn't re-occur)
- An automation script or scheduled task

**A queue item** counts as discharge when it names the exact file to change and the exact change
(more specific than "document this finding somewhere").

### What doesn't count

- A `knowledge/` entry alone — the entry *is* the finding, but recording it doesn't enact it
- A prose note in a commit message or `/session-end` write-up
- A journal-style session log entry that describes what happened
- A future-tense note like "Pappa T should X" (should implies it doesn't happen today; only a
  queue item + owner agreement makes that an obligation)

## Enforcement

No automated gate — like the DCOE's other governance rules, this is self-monitored by:

1. **At write time:** before typing a finding into `knowledge/`, ask "where does this get used?"
   If the answer is "only here," consider whether it's worth recording (most of the time it
   is; the rule doesn't prevent recording, just requires follow-through).
2. **At review time:** a `reviewer` agent auditing a session's changes sees commit messages that
   describe lessons. A message that names a finding should cite where it's now installed, or
   reference the queue item that's tracking the install.
3. **At re-occur time:** if the same lesson appears twice in a session log, the gap is visible.
   That's already part of `/retro`'s scan.

## Impact

**CORE version bump:** this is a universal hard rule; changes to `CORE.md` always bump. Will
be CORE 1.6 → 1.7.

**New entry in this repo's `docs/specs/` checklist:** rules newly added to CORE.md get an entry
in the config repo's `docs/specs/` (this file becomes that entry once approved).

**No code changes needed.** This rule is enforcement via process and session discipline, the same
as CORE rule 1 ("Domain Agent confirms scope"). It's not a hook, not a guard, not an automation.
It is a **governance rule** about how sessions conduct themselves.

## Related

- This rule is not new behavior — `/retro`'s Step 2 is written to detect it as a pattern
  (sessions that record decisions but don't install them).
- The `/session-end` command's Step 1.5 (check that all touched repos have outbound PRs or
  merged commits) is a different gate — it catches work that's not *shipped*, whereas this rule
  catches work that's not *executable*.
- Hard rule 10 in this repo's CLAUDE.md ("Verify remote state before asserting it") is a
  related discipline — don't assume a change is live just because you wrote about it; verify it.
