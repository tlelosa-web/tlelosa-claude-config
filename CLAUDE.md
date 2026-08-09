# CLAUDE.md — tlelosa-claude-config

# Architecture: DCOE (Domain → Context → Orchestrate → Execute) — slim profile

# Owner: Tebello Lelosa

> Loaded at the start of every Claude Code session in this repo.
> This is a **config/marketplace repo**, not an app: no runtime, no tests,
> no dev server. It runs a slimmed-down DCOE — see "How DCOE applies here".

-----

## SESSION START

Read `./dcoe-roster/CORE.md` and treat its contents as part of this
session's operating instructions (DCOE architecture, roster, model routing,
universal hard rules).

Use the **local working-copy path above**, not the installed-plugin path
(`~/.claude/plugins/marketplaces/tlelosa-claude-config/...`) that other
projects use — this repo IS the source of that file, and the installed copy
may lag behind the branch being edited.

Also check whether `~/.claude/agents/` (user-level only) contains all 9
expected roster filenames (`architect.md`, `data-agent.md`, `debugger.md`,
`doc-writer.md`, `domain.md`, `executor.md`, `planner.md`, `reviewer.md`,
`tester.md` — e.g. via `ls ~/.claude/agents/`). If any are missing, print a
one-line warning naming which ones, pointing at
`agent-bodies-reference/bootstrap.sh` as the fix.

-----

## PROJECT OVERVIEW

```
Project:     tlelosa-claude-config
Type:        Private Claude Code plugin marketplace (Markdown + JSON only)
Deployment:  GitHub → /plugin marketplace add on each machine
Machines:    Operations (work PC) · Pappa T (personal)
Content:     Shared tooling only — NEVER project content or company data
```

- `.claude-plugin/marketplace.json` — the catalog Claude Code reads.
- `dcoe-roster/` — ships `CORE.md` only (shared core, ADR-007). Does **not**
  ship agent bodies; those were stripped 2026-07-29.
- `agent-bodies-reference/` — the 10 roster agent bodies + `bootstrap.sh`,
  the copy-source for a new machine's `~/.claude/agents/`.
- `codex-gate/` — `/codex-review`, advisory cross-family second opinion on a
  spec. Per-machine install; Pappa T only until Operations OpenAI clearance.
- `shared-skills/` — cross-project Skills plugin.
- `hub-template/` — vault-agnostic `/continue` + `/session-end` skeletons,
  checklists, and ready-made `hooks/` (ADR-008).
- `CLAUDE.md.template` — **master template for OTHER projects.** Reference
  only; never fill it in or edit it as this repo's own config.
- `docs/todo.md` — task list. `docs/specs/` — specs for larger changes.
- `.claude/commands/continue.md` / `session-end.md` — this repo's own
  resume/close-out pair (minimal adaptations of the `hub-template/`
  versions: orient via `docs/todo.md` + git state, report, wait for
  confirmation — no hub session hygiene, no session log).

-----

## ESSENTIAL COMMANDS

```bash
# Validate JSON before every commit that touches it
python -m json.tool .claude-plugin/marketplace.json
python -m json.tool dcoe-roster/plugin.json
python -m json.tool shared-skills/plugin.json
python -m json.tool codex-gate/plugin.json

# Test a change against a LOCAL clone before pushing (inside Claude Code):
#   /plugin marketplace add ./tlelosa-claude-config
#   /plugin install dcoe-roster@tlelosa-claude-config

# Roll out after push — run on EACH machine:
#   /plugin marketplace update tlelosa-claude-config
#   /plugin update dcoe-roster@tlelosa-claude-config
#   /reload-plugins
```

-----

## HOW DCOE APPLIES HERE

The universal hard rules in `CORE.md` apply in full. The staged pipeline is
scaled to the work:

- **Single-file markdown/JSON edits** (refine an agent, fix a typo, bump a
  version): go straight to Execute. One task = one commit still holds.
- **Structural changes** (new plugin, schema change, > 2 files, anything
  altering what other machines install): full DCOE — confirm scope, write a
  spec to `docs/specs/`, then implement. Update `docs/todo.md` after.
- No worktree parallelism needed at this repo's scale.

-----

## REPO-SPECIFIC HARD RULES

1. **No company or project data, ever.** This repo is cloned on both a
   personal and an employer machine — keep it deliberately generic.
2. **`CLAUDE.md.template` is the master for other projects** — edits to it
   are template maintenance, never this repo's own setup.
3. **Validate JSON** (`python -m json.tool`) before committing catalog or
   plugin manifest changes; a broken manifest breaks installs on both machines.
4. **No `CLAUDE.md` inside plugin folders** — Claude Code ignores it there
   by design; per-project config stays a per-project file.
5. **Changes to `dcoe-roster/CORE.md` or to `agent-bodies-reference/` affect
   every opted-in project on both machines** — treat edits to them as
   structural (spec first), and bump the core version noted at the top of
   `CORE.md`. Note the agent bodies reach a machine by `bootstrap.sh`, not by
   the plugin, so an agent edit needs a re-run there as well as a push here.
