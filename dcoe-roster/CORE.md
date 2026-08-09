# CORE.md — DCOE Shared Core

**Core version: 1.4** | Source: `tlelosa-claude-config` (`dcoe-roster` plugin) | Owner: Tebello Lelosa

> Shared, reusable core for every Fan Movement / Tebello Lelosa project running
> the DCOE pattern: the DCOE architecture, the sub-agent roster, model
> routing, and hard rules that are genuinely universal (not project-specific).
> Everything else — stack, folder layout, project-specific hard rules — stays
> local to that project's own `CLAUDE.md`.
>
> **How this file reaches a project:** Claude Code's `@path` import does not
> resolve absolute paths outside the project tree (confirmed 2026-07-18, see
> ADR-007 in the `Operations` hub's `docs/decisions/`) — so this is **not**
> wired in via `@import`. Instead, an opted-in project's own `CLAUDE.md` carries a plain
> instruction telling Claude to read this file (at
> `~/.claude/plugins/marketplaces/tlelosa-claude-config/dcoe-roster/CORE.md`)
> at session start and treat its contents as part of that session's operating
> instructions. Same self-monitored trust model as any other `CLAUDE.md` rule.
>
> **Updating this file:** edit here, commit, push. Each machine picks up the
> change on its own schedule via `/plugin marketplace update
> tlelosa-claude-config` (or the marketplace's background refresh). A project
> only actually sees the update the next time a session reads this file —
> there is no silent auto-apply to any project's files.

-----

## DCOE Agent Architecture

**Domain → Context → Orchestrate → Execute**

An evolution of the DOE pattern that adds an explicit Domain layer. Each
complex task is routed through four stages. Never collapse them.

```
┌──────────────────────────────────────────────────────┐
│                    YOU (Human)                        │
│          Describe goal  →  Review output              │
└───────────────────────┬──────────────────────────────┘
                        │
             ┌──────────▼──────────┐
             │     DOMAIN AGENT    │  Clarifies scope, confirms
             │                     │  stack/project, flags ambiguity.
             └──────────┬──────────┘  Stops if unclear. ASK before acting.
                        │
             ┌──────────▼──────────┐
             │   CONTEXT AGENT     │  Writes spec to docs/specs/.
             │  (Planner/Architect)│  Never implements. Routes only.
             └──────────┬──────────┘
                        │
             ┌──────────▼──────────┐
             │  ORCHESTRATOR       │  Reads docs/todo.md, coordinates
             │                     │  Executors, merges results.
             └──────────┬──────────┘
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐
    │EXECUTOR 1│  │EXECUTOR 2│  │EXECUTOR N│  One task. One commit. Done.
    └──────────┘  └──────────┘  └──────────┘
```

### DCOE Rules

0. **Router (scale check).** Before Domain Agent, classify the task by
   **impact first, file count second** — file count alone under-classifies
   governance changes (a 2-file edit to `CORE.md` is still Structural):
   - **Structural regardless of file count:** anything touching contracts,
     data, security, production behavior, governance/shared-core docs
     (`CORE.md`, an agent definition), or cross-project dependencies — full
     DCOE: Domain confirms scope, Context writes a spec, then Execute.
   - **Trivial** (only if none of the above apply): single-file edit, typo
     fix, version bump, no schema/contract change, no cross-project effect —
     skip Domain/Context, go straight to Execute. One task = one commit
     still holds.
   A project's own `CLAUDE.md` may restate this in project-specific terms
   but should not need to re-derive the underlying rule.
1. **Domain Agent** confirms scope, stack/project, and ambiguities before
   anything else.
2. **Context Agent** writes the plan — never the code. Spec lives in
   `docs/specs/`.
3. **Orchestrator** reads `docs/todo.md`, coordinates work, merges.
4. **Executors** each get a fresh context. One task. One atomic commit. Done.
5. If acceptance criteria are unclear at any stage → **STOP and ask**.
6. Orchestrator never does heavy lifting. Executors never plan.
7. **Reviewer Loop.** The spec-review-build sequence is a loop, not a single
   gate: `Context Agent writes spec → codex-review (advisory) → reviewer
   approve/reject`. Final pre-build authority rests with the `reviewer`
   agent (Codex is advisory only, never a decider). On reject, control
   returns to the **Context Agent**, not to Execute — the spec is revised
   and the loop repeats. Only the `reviewer` agent's APPROVE exits the loop
   into Execute. The loop is manual and owner/reviewer-directed — no
   automatic retry count or escalation; a spec can cycle as many times as
   the reviewer requires.

-----

## Sub-agent roster

**Default location: `~/.claude/agents/` (user-level).** The full roster is
deployed once at the user level and is available automatically in every
project. No per-project copying required. Project-level `.claude/agents/` is
reserved for **overrides only** — e.g. a `data-agent` variant tuned to a
specific project's export format. A same-named file in a project's own
`.claude/agents/` wins over the user-level default for that project.

|Agent       |Default file                  |When to Use                            |
|------------|-------------------------------|----------------------------------------|
|`domain`    |`~/.claude/agents/domain.md`    |Session start, scope confirmation      |
|`planner`   |`~/.claude/agents/planner.md`   |Break features into spec + tasks       |
|`architect` |`~/.claude/agents/architect.md` |System design, ADRs, DB schema (Opus, standing)|
|`executor`  |`~/.claude/agents/executor.md`  |Implement a single well-defined task   |
|`tester`    |`~/.claude/agents/tester.md`    |Write tests, TDD loops                 |
|`reviewer`  |`~/.claude/agents/reviewer.md`  |Code review, security, quality gate (Opus, standing)|
|`doc-writer`|`~/.claude/agents/doc-writer.md`|Update docs, README, changelogs        |
|`debugger`  |`~/.claude/agents/debugger.md`  |Systematic bug investigation           |
|`data-agent`|`~/.claude/agents/data-agent.md`|Excel/CSV transforms, report processing|
|`Explore`   |`~/.claude/agents/explore.md`   |Read-only search/grep (Haiku tier)     |

### Model routing

`claude-sonnet-5` at **medium effort** is the universal default for all
agents. `claude-opus-5` is reserved for **evidence-based escalation
only** — not assigned up front by task type.

**Escalate to Opus when:**
- Two prior Sonnet attempts on the same task have failed
- The task requires deep architectural reasoning (system-wide redesign,
  non-trivial ADRs)
- A security review is warranted (auth, data-export, file-write code)

**When a standing pin is legitimate.** A role earns a **standing** model pin
only when **every** task it can receive already meets an escalation trigger
above. If some of its tasks would meet one and some would not, the role takes
the default and escalates per-task on evidence. Two roles pass this test, and
only two:

- **`reviewer`** — every review is a quality/security gate, which is already
  an escalation trigger. Code review is a fixed high-stakes gate, not a
  per-task judgment call.
- **`architect`** — "deep architectural reasoning (system-wide redesign,
  non-trivial ADRs)" is an escalation trigger and is also a description of
  this role's entire job. Making it re-establish escalation per task is
  ceremony.

This test keeps hard rule 7 intact rather than carving out favourites: a
proposal to pin any other role is answered by asking whether *any* task that
role receives would fail to meet a trigger.

|Role                              |Model              |Effort |
|-----------------------------------|-------------------|-------|
|All agents (default)               |`claude-sonnet-5`  |Medium |
|`reviewer` (standing)              |`claude-opus-5`    |High   |
|`architect` (standing)             |`claude-opus-5`    |High   |
|Escalation (2 failed attempts / deep architecture / security review)|`claude-opus-5`|High|
|`Explore` / search-grep only       |`claude-haiku-4-5` |Low    |

Set per-agent in frontmatter: `model: claude-haiku-4-5`

The Haiku search tier is implemented by the roster's `Explore` agent — an
override of Claude Code's built-in Explore, which inherits the session model
instead of defaulting to Haiku. Without the override deployed, search
delegations silently run at Sonnet 5 prices.

-----

## Universal hard rules

These apply to every project regardless of stack — project `CLAUDE.md`s add
their own stack-specific and project-specific hard rules on top, they never
relax these.

1. **No code without a plan** for any task touching > 2 files.
2. **One task = one commit** — atomic, traceable, revertable. No bundling.
3. **Sub-agents are specialists** — never make one agent do everything.
   Orchestrator routes. Executors build. Never reverse this.
4. **Ask before deleting** anything in production data paths.
5. **Update `docs/todo.md`** after every completed task.
6. **If acceptance criteria are unclear → STOP and ask** before implementing.
7. **Opus is earned, not assigned** — default to Sonnet 5 at medium effort;
   escalate only on evidence (failed attempts, architecture, security).
8. **Agent roster lives at user level** (`~/.claude/agents/`) — do not fork a
   full copy into a project's `.claude/agents/`; add project files there only
   as single-agent overrides.
9. **Run `/codex-review` on every spec in `docs/specs/` before dispatching an
   Executor** — advisory cross-family second opinion, appended to the spec,
   never blocking. Fold the strongest points (buried assumptions, missing
   acceptance criteria, real failure modes) back into the spec as a dated
   Amendment section before build starts. Standard procedure for every spec,
   not optional. The `reviewer` agent still holds sole APPROVE/BLOCK
   authority — Codex is advisory only.
10. **Verify remote state before asserting it.** Before reporting repo/PR/
   branch status or proposing an action conditioned on it (open a PR, merge,
   rebase), `git fetch` the relevant ref and check it — never answer from a
   locally cached branch ref that may be stale. This applies to any external
   state a session doesn't control alone (remote branches, deployed
   versions, other sessions' in-progress work), not git specifically.

-----

*Update this file when a pattern proven in one project's own `CLAUDE.md`
turns out to be genuinely universal — promote it here rather than leaving it
duplicated project-by-project. Keep project-specific content (stack, folder
layout, project hard rules) out of this file; it belongs in that project's
own `CLAUDE.md`.*
