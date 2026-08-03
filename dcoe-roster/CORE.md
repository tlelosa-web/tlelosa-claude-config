# CORE.md — DCOE Shared Core

**Core version: 1.1** | Source: `tlelosa-claude-config` (`dcoe-roster` plugin) | Owner: Tebello Lelosa

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

1. **Domain Agent** confirms scope, stack/project, and ambiguities before
   anything else.
2. **Context Agent** writes the plan — never the code. Spec lives in
   `docs/specs/`.
3. **Orchestrator** reads `docs/todo.md`, coordinates work, merges.
4. **Executors** each get a fresh context. One task. One atomic commit. Done.
5. If acceptance criteria are unclear at any stage → **STOP and ask**.
6. Orchestrator never does heavy lifting. Executors never plan.

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
|`architect` |`~/.claude/agents/architect.md` |System design, ADRs, DB schema         |
|`executor`  |`~/.claude/agents/executor.md`  |Implement a single well-defined task   |
|`tester`    |`~/.claude/agents/tester.md`    |Write tests, TDD loops                 |
|`reviewer`  |`~/.claude/agents/reviewer.md`  |Code review, security, quality gate    |
|`doc-writer`|`~/.claude/agents/doc-writer.md`|Update docs, README, changelogs        |
|`debugger`  |`~/.claude/agents/debugger.md`  |Systematic bug investigation           |
|`data-agent`|`~/.claude/agents/data-agent.md`|Excel/CSV transforms, report processing|

### Model routing

`claude-sonnet-5` at **medium effort** is the universal default for all
agents. `claude-opus-4-8` is reserved for **evidence-based escalation
only** — not assigned up front by task type.

**Escalate to Opus when:**
- Two prior Sonnet attempts on the same task have failed
- The task requires deep architectural reasoning (system-wide redesign,
  non-trivial ADRs)
- A security review is warranted (auth, data-export, file-write code)

**Standing exception:** the `reviewer` agent runs permanently on
`claude-opus-4-8` — code review is treated as a fixed high-stakes gate, not a
per-task escalation.

|Role                              |Model              |Effort |
|-----------------------------------|-------------------|-------|
|All agents (default)               |`claude-sonnet-5`  |Medium |
|`reviewer` (permanent)             |`claude-opus-4-8`  |High   |
|Escalation (2 failed attempts / deep architecture / security review)|`claude-opus-4-8`|High|
|Search / grep only                 |`claude-haiku-4-5` |Low    |

Set per-agent in frontmatter: `model: claude-haiku-4-5`

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

-----

*Update this file when a pattern proven in one project's own `CLAUDE.md`
turns out to be genuinely universal — promote it here rather than leaving it
duplicated project-by-project. Keep project-specific content (stack, folder
layout, project hard rules) out of this file; it belongs in that project's
own `CLAUDE.md`.*
