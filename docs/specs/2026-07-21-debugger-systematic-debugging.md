# Spec: fold systematic-debugging methodology into the `debugger` agent

**Date:** 2026-07-21
**Status:** Proposed
**Origin:** 2026-07-21 plugin/skills ecosystem review. Verdict was: do not
install the Superpowers plugin (its full lifecycle duplicates DCOE), but
its `systematic-debugging` skill is the most independently validated skill
in the ecosystem and maps directly onto our `debugger` agent, which is
currently the thinnest file in the roster. Upstream:
`obra/superpowers` → `skills/systematic-debugging/SKILL.md` (MIT).

## Purpose

Upgrade `dcoe-roster/agents/debugger.md` from a 4-step outline to the
proven four-phase root-cause methodology, so every opted-in project on
both machines gets a debugger that investigates before it theorizes and
refuses symptom patches by structure, not just by exhortation.

## Design

Adapt, don't transplant. The upstream skill assumes the same agent also
implements the fix; in DCOE the debugger **never fixes** — that boundary
stays. The adapted shape:

- **Iron Law (verbatim, it's the point):** "No fixes without root-cause
  investigation first." Symptom fixes are failure.
- **Phase 1 — Root-cause investigation:** read error messages completely;
  reproduce with exact steps before theorizing (already our step 1); check
  recent diffs/config/dependency changes; in multi-component paths, log at
  each boundary and trace bad values backward to their origin.
- **Phase 2 — Pattern analysis:** find similar *working* code in the same
  codebase, read it completely (not skimmed), and list every difference
  between working and broken paths, including dependency/assumption gaps.
- **Phase 3 — Hypothesis and testing:** state it as "I think X causes this
  because Y"; test with the smallest possible change, one variable at a
  time; failed hypothesis → new hypothesis, not a bigger change.
- **Phase 4 — Handoff (adapted from upstream's "Implementation"):** write
  the findings report to `docs/bugs/<slug>.md` as today, but now it must
  include a **failing test case** (or exact reproduction script) that the
  fix must turn green — that test is the contract handed to
  Tester/Executor. The debugger still implements nothing.
- **Red flags (self-check list, kept):** "quick fix for now", "just try X
  and see", proposing solutions before tracing data flow, "one more fix"
  after 2+ attempts. Any of these → restart Phase 1.
- **Escalation alignment:** upstream's "3+ failed fixes → question the
  architecture" becomes: after **two** failed hypothesis cycles, stop and
  escalate per CORE.md model routing (evidence-based Opus escalation),
  flagging that the architecture itself may be the root cause. This keeps
  one escalation rule across the roster instead of introducing a second
  threshold.
- **Unchanged:** tools (`Read, Grep, Glob, Bash`), `model:
  claude-sonnet-5`, `memory: project`, the output format (bug-report path,
  one-paragraph root cause, next tasks for Planner/Executor), and the
  memory instruction about recurring root causes.
- **Attribution:** one line at the bottom of `debugger.md`:
  "Methodology adapted from obra/superpowers `systematic-debugging`
  (MIT, © Jesse Vincent)."

## Explicitly out of scope

- No new skill in `shared-skills` — this lives in the agent definition,
  where it's always active for debugging work; a skill would need separate
  triggering and could drift from the agent.
- Upstream's supporting-technique files (`root-cause-tracing.md`,
  `defense-in-depth.md`, `condition-based-waiting.md`) are **not**
  vendored — the phase summaries above carry the useful content; revisit
  only if the condensed version proves too thin in practice.
- No changes to other roster agents, and no CORE.md content change — the
  roster table's one-line description for `debugger` ("Systematic bug
  investigation") already matches. Per repo hard rule 5 the spec-first
  discipline applies; the core version at the top of CORE.md stays 1.0
  because CORE.md's text is untouched. The rollout signal is the plugin
  version bump below.

## Implementation shape

- Rewrite `dcoe-roster/agents/debugger.md` per the Design section
  (single file).
- Bump `dcoe-roster/plugin.json` version `3.2.0` → `3.3.0`; validate with
  `python -m json.tool dcoe-roster/plugin.json`.
- One task = one commit. Update `docs/todo.md` after.
- Rollout as usual on each machine: `/plugin marketplace update
  tlelosa-claude-config`, `/plugin update dcoe-roster@tlelosa-claude-config`,
  `/reload-plugins`.

## Acceptance criteria

1. `debugger.md` contains the Iron Law, all four phases, the red-flag
   list, and the two-failed-cycles escalation tied to CORE.md routing.
2. The agent still implements no fixes: Phase 4 produces a report plus a
   failing test/reproduction, nothing else.
3. Frontmatter (tools, model, memory) is unchanged from v3.2.0.
4. MIT attribution line is present.
5. `plugin.json` says `3.3.0` and passes `python -m json.tool`.
6. After rollout, `/agents` on either machine shows the updated debugger
   description with no install errors.

## Effort

Small — one agent file rewrite plus a manifest bump. An evening at most;
implement together with the next dcoe-roster touch if one is already
queued, to save a rollout round-trip on both machines.
