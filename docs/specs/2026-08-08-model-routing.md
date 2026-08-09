# Spec — Model routing: a test for standing exceptions, and a generation fix

**Date:** 2026-08-08
**Status:** Implemented 2026-08-08 (approved by owner same day)
**Owner:** Tebello Lelosa
**Type:** Structural — changes `CORE.md` and `CLAUDE.md.template`, so it reaches
every opted-in project on both machines. Core version bump required.
**Plan:** `docs/specs/2026-08-08-system-maintenance-plan.md`, Phase 5

## Problem

Three findings from the 2026-08-08 systems check, all in the same routing
table, all better fixed together than as three edits to one table.

### 1. Hard rule 7 has no test for a legitimate standing exception

Universal hard rule 7 says **"Opus is earned, not assigned — default to
Sonnet 5 at medium effort; escalate only on evidence."** The routing section
then grants `reviewer` a permanent Opus pin by declaration, and
`agent-bodies-reference/architect.md` carries `model: claude-opus-4-8` that
nothing in `CORE.md` mentions at all.

So the rule currently reads as *"no exceptions, except the ones we felt like
making."* One exception is documented and unjustified; the other is
undocumented entirely. A future session reading rule 7 and then finding the
architect pin has no way to tell whether it is intentional or a mistake —
which is exactly the question this systems check had to stop and ask.

The problem is not that either pin is wrong. It is that there is no stated
principle to test a pin against.

### 2. The escalation target is a generation behind

The default is `claude-sonnet-5` (5-family) and the escalation target is
`claude-opus-4-8` (4.8-family). Escalating from a 5-family model to a
4.8-family one is backwards — the "escalation" path currently moves to an
older model. `claude-opus-5` is the current Opus.

The stale identifier appears **11 times across 4 files** (enumerated below),
so it is not a one-line fix and is worth doing in a single pass.

### 3. `architect`'s pin is invisible from `CORE.md`

`CORE.md`'s roster table lists `architect` with no model annotation, and its
routing table names only `reviewer` as a standing exception. The pin lives
solely in the agent body — a file that reaches machines via `bootstrap.sh`
rather than the plugin, so the two can drift without anything noticing.

## Decision

### The exception test

Add to `CORE.md`'s routing section, as the governing principle:

> A role earns a **standing** model pin only when **every** task it can
> receive already meets an escalation trigger. If some of its tasks would
> meet one and some would not, the role takes the default and escalates
> per-task on evidence.

This resolves both cases without weakening rule 7:

- **`reviewer`** — every review is a quality/security gate, which the
  escalation list already names. Pin earned. Unchanged in substance, now
  justified rather than declared.
- **`architect`** — the escalation list already names *"deep architectural
  reasoning (system-wide redesign, non-trivial ADRs)"*, which is a
  description of the architect's whole job. Requiring it to re-establish
  escalation per task is ceremony. Pin earned, and now documented in
  `CORE.md` instead of hiding in the agent body.
- **Every other role** — mixed workloads, so per-task escalation stands
  exactly as today.

The test is deliberately closed and checkable: a future proposal to pin a
role can be answered by asking whether *any* task that role receives would
fail to meet an escalation trigger.

### The routing table

|Role                              |Model              |Effort |
|-----------------------------------|-------------------|-------|
|All agents (default)               |`claude-sonnet-5`  |Medium |
|`reviewer` (standing)              |`claude-opus-5`    |High   |
|`architect` (standing)             |`claude-opus-5`    |High   |
|`Explore` / search-grep only       |`claude-haiku-4-5` |Low    |
|Escalation (2 failed attempts / deep architecture / security review)|`claude-opus-5`|High|

### Deliberately unchanged

- **`doc-writer` stays on `claude-sonnet-5`.** It is the obvious downgrade
  candidate and is rejected on purpose: this repo's product *is* prose. The
  agent that writes `CORE.md`, READMEs and changelogs is the wrong place to
  economise.
- **Effort tiers stay as they are** — medium default, high for pinned roles,
  low for search.
- **`claude-fable-5` is not assigned a role.** It exists in the Claude 5
  family, but no cost/capability profile was verified during this spec, and
  inventing a role for an unverified model is how the `claude-opus-4-8`
  staleness happened in the first place. Adding it later is a separate,
  evidence-backed change.

## Exact changes

### `dcoe-roster/CORE.md` (version 1.3 → 1.4)

1. Line ~123 — `claude-opus-4-8` → `claude-opus-5` in the escalation sentence.
2. Line ~133 — rewrite the "Standing exception" paragraph to state the
   exception test and name **both** `reviewer` and `architect`.
3. Line ~139 — routing table: `reviewer` row → `claude-opus-5`.
4. Line ~140 — routing table: escalation row → `claude-opus-5`.
5. Add an `architect` (standing) row to the routing table.
6. Roster table: annotate `architect` so its pin is visible where the roster
   is listed, not only in the routing table.
7. Bump the header to **Core version: 1.4**.

### `CLAUDE.md.template` (v3.4 → v3.5)

8. Line ~21 — the `Inference:` line in PROJECT OVERVIEW.
9. Line ~145 — escalation sentence.
10. Line ~152 — standing-exception paragraph (same rewrite as CORE).
11. Line ~157 — `reviewer` routing row.
12. Line ~158 — escalation routing row.
13. Add the `architect` standing row.
14. Version header → **3.5**, plus a `v3.5 change` changelog line at the
    bottom matching the v3.2/v3.3/v3.4 precedent.

### Agent bodies

15. `agent-bodies-reference/architect.md` — `model: claude-opus-5`.
16. `agent-bodies-reference/reviewer.md` — `model: claude-opus-5`.

### Manifest

17. `dcoe-roster/plugin.json` — version **3.5.0 → 3.6.0**, description
    `matching CLAUDE.md v3.4` → `v3.5`. Validate with
    `python -m json.tool` before committing (repo hard rule 3).

**Total: 11 `claude-opus-4-8` occurrences replaced** — 4 in `CORE.md`, 5 in
`CLAUDE.md.template`, 2 in agent bodies.

## Commit boundaries

Per one-task-one-commit, but respecting that a core version bump is a single
distribution event:

1. **CORE 1.4 + template v3.5 + plugin 3.6.0** — the routing change proper,
   as one commit. The three files describe one decision and splitting them
   would ship a template referencing a CORE version that does not exist yet.
2. **Agent bodies** — `architect.md` and `reviewer.md`, one commit.
3. **`docs/todo.md`** — record Done, per hard rule 5.

## Rollout

Folds into the **existing open rollout item** rather than creating a second
pass — dcoe-roster 3.5.0 + CORE 1.3 + template v3.4 have not shipped to
either machine yet, so this ships as 3.6.0 / CORE 1.4 / v3.5 in the same run:

```
/plugin marketplace update tlelosa-claude-config
/plugin update dcoe-roster@tlelosa-claude-config
/reload-plugins
bash agent-bodies-reference/bootstrap.sh
```

**The `bootstrap.sh` re-run is not optional.** Changes 15–16 are agent
bodies, which reach a machine only via that script — a plugin update
delivers `CORE.md` and nothing else. Skipping it leaves `architect` and
`reviewer` on `claude-opus-4-8` while every document says otherwise, which is
the exact drift class this spec exists to close.

## Acceptance criteria

- No `claude-opus-4-8` reference remains outside `docs/specs/` and
  `docs/research/`, where historical documents legitimately cite it.
- `CORE.md`'s routing table, `CLAUDE.md.template`'s routing table, and every
  agent body's `model:` frontmatter agree — no role's model can be read
  differently from two places.
- Every standing pin in the roster passes the exception test, and the test is
  stated in `CORE.md` rather than implied.
- `python -m json.tool` passes on all four manifests.
- After rollout, `~/.claude/agents/architect.md` and `reviewer.md` on both
  machines read `claude-opus-5`.

## Out of scope

- Adding `claude-fable-5` to the roster — needs verified profile data first.
- Any change to effort tiers or the Thinking Levels mapping.
- Downgrading `doc-writer` — explicitly rejected above.
- The `31 August 2026` introductory-pricing claim in `CLAUDE.md.template`
  (line ~164). It is 22 days out at time of writing and was not verified
  during this spec. Tracked as its own todo item: confirm it, or remove it
  from the template if stale. It is routing-adjacent but is a separate factual
  question, and folding an unverified claim into an approved spec is how such
  claims survive unchallenged.

## Codex second opinion

Universal hard rule 9 requires `/codex-review` on every spec before
dispatching an Executor. **Not run** — this spec was written from a cloud
container, and codex-gate is a per-machine install available on Pappa T only.
Either run it from Pappa T before building, or record an explicit waiver in
`docs/todo.md`. Do not let it lapse silently: this spec changes what both
machines install.

## Revision history

- **2026-08-08** — first draft, from the Phase 5 findings of the systems
  check (`docs/specs/2026-08-08-system-maintenance-plan.md`).
- **2026-08-08** — approved and implemented in three commits (CORE 1.4 +
  template v3.5 + plugin 3.6.0; the two agent bodies; this status update).
  One deviation from the letter of the spec: a single `claude-opus-4-8`
  mention remains in `CLAUDE.md.template`, inside the v3.5 changelog line
  describing this very change. That is a historical citation of the kind the
  acceptance criteria already permit in `docs/specs/` and `docs/research/`,
  not an unreplaced reference. Additions beyond the listed changes: the
  `architect`/`reviewer` roster rows in **both** files are annotated
  "(Opus, standing)", so a reader of the roster table sees the pin without
  having to reach the routing table. Rollout remains outstanding — nothing
  has reached either machine yet.
