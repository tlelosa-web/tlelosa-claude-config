---
# /retro — Todo & Session-Log Retrospective (batched improvement proposals)
# Reviews this hub's own operating history for recurring friction and
# proposes concrete utilities to close the gaps. Never builds anything
# without confirmation. Companion to hub-template/continue.md and
# HUB-CHECKLIST.md — same vault-agnostic, copy-in-verbatim treatment.
---

## Purpose

`/continue` orients on *what's next*. `/retro` looks backward instead: did
this hub's own framework (todo.md discipline, session-log hygiene, the
`/continue` dedup check in Step 0.5, hard rules) actually hold up across
recent sessions — or did Tebello have to catch something the framework
should have caught? Run this periodically (weekly, or whenever a session
felt like a repeat of one already done) — not on every session.

## Step 1 — Gather evidence

Read, bounded to entries since the last `/retro` run (see Step 5):
- `docs/session-log.md` — every entry since the last retro marker
- `docs/todo.md` — current state, plus how long each item has sat unresolved
- `docs/decisions/` — ADR titles only, to check whether a friction point
  already has a fix proposed there but not yet executed

If `docs/retro-log.md` doesn't exist yet, this is the first run — review the
full `session-log.md` history instead of a bounded window, and say so in the
report.

## Step 2 — Detect friction patterns

Look specifically for signals of the *framework* failing to hold state, not
just "things that went wrong" in a single session:
- A session re-did or re-proposed something a prior session already
  finished (redundant work)
- Tebello had to manually point out something already decided or
  completed, rather than the session catching it itself
- A session asserted a fact about external state (git remote, a deployed
  version, another session's status) that turned out to be stale or wrong
- The same category of bug or gap recurs across 2+ session-log entries
- A `docs/todo.md` item has been deferred 3+ times without being dropped or
  actually scheduled

Don't flag one-off mistakes or genuinely new problems — this is specifically
about the framework failing to prevent repeat work, not a general quality
audit.

## Step 3 — Propose a batch

For each pattern found, write one proposal in this shape:

```
**Problem:** [one line, cite the session-log entry / todo item as evidence]
**Utility:** [new CORE.md hard rule | new skill | new hook | new
              CLAUDE.md/checklist item | new agent instruction]
**Scope:** [this hub only | universal — promote to tlelosa-claude-config so
            it reaches every machine/project]
**Effort:** [S | M | L]
```

Cap the batch at ~8 items. If more than 8 patterns surface, keep the
highest-evidence ones (cited by multiple entries) and note the rest were
held back rather than silently dropping them.

## Step 4 — Confirm before building anything

Present the batch, then **always follow it with a selectable list** via
`AskUserQuestion` (multiSelect — these are independent proposals; Tebello
may want some now and some later, or none). Never build a proposal that
wasn't picked.

Selected items become normal DCOE work from here: hub-only fixes go straight
to `docs/todo.md` as tasks (or `docs/specs/` first if non-trivial); anything
scoped **universal** follows the existing promotion path — fixed/proven
locally first, then migrated into `tlelosa-claude-config`
(`dcoe-roster/CORE.md` for a hard rule, `shared-skills/` for a skill,
`hub-template/` for a session-mechanics change) so both Pappa T and the work
PC pick it up via `/plugin marketplace update tlelosa-claude-config`.

## Step 5 — Record the run

Append to `docs/retro-log.md` (create it if missing):

```
## [date] — /retro run
Reviewed: session-log entries [range] | todo.md as of [date]
Proposed: N items — [M] selected, [N-M] deferred
Selected: [short list]
```

This is what bounds Step 1's next run to *new* entries only. Without it,
`/retro` would eventually repeat its own complaint — re-surfacing a pattern
it already raised and Tebello already declined to act on.
