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

Also check whether `~/.claude/agents/` (user-level only) contains all 10
expected roster filenames (`architect.md`, `data-agent.md`, `debugger.md`,
`doc-writer.md`, `domain.md`, `executor.md`, `explore.md`, `planner.md`,
`reviewer.md`, `tester.md` — e.g. via `ls ~/.claude/agents/`). As of CORE 1.5
this deploys itself: the `dcoe-roster` plugin's `SessionStart` hook runs
`agent-bodies-reference/bootstrap.mjs` on every session, missing-only so
local agent edits survive. If any are still missing after that ran, the
plugin itself is likely not installed/loaded on this machine — print a
one-line warning naming which files are missing and pointing at
`/plugin marketplace update` + `/plugin install dcoe-roster@tlelosa-claude-config`.
`agent-bodies-reference/bootstrap.sh` is the pre-1.5 manual fallback, kept
for a machine where the plugin genuinely can't load (e.g. a cloud session
that cloned this repo without installing the marketplace).

**Verify the JSON pre-commit hook is active:** run `git config core.hooksPath`
and confirm it returns `.githooks`. If not set or different, print a one-line
warning: `core.hooksPath is not set on this machine — JSON pre-commit hook is
inactive; run: git config core.hooksPath .githooks`

-----

## PROJECT OVERVIEW

```
Project:     tlelosa-claude-config
Type:        Private Claude Code plugin marketplace (Markdown + JSON only)
Deployment:  GitHub → /plugin marketplace add in each environment
Environment: ai-product-factory (sole vault as of 2026-08-20 — Operations and
             Pappa T are retired; see docs/todo.md for what that closed out)
Content:     Shared tooling only — NEVER project content or company data
```

- `.claude-plugin/marketplace.json` — the catalog Claude Code reads.
- `dcoe-roster/` — ships `CORE.md` only (shared core, ADR-007). Does **not**
  ship agent bodies; those were stripped 2026-07-29.
- `agent-bodies-reference/` — the 10 roster agent bodies, the copy-source
  for a new machine's `~/.claude/agents/`. Deployed automatically by
  `dcoe-roster`'s `SessionStart` hook (`bootstrap.mjs`, CORE 1.5+);
  `bootstrap.sh` is the pre-1.5 manual fallback.
- `codex-gate/` — `/codex-review`, advisory cross-family second opinion on a
  spec. Installed in the ai-product-factory environment (the machine-split
  gating this used to need — Pappa T cleared, Operations pending IT
  clearance — no longer applies now that Operations is retired).
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
# One-time setup on each machine (activates JSON pre-commit hook)
git config core.hooksPath .githooks

# Validate JSON before every commit that touches it (automated via hook once above is set)
python -m json.tool .claude-plugin/marketplace.json
python -m json.tool dcoe-roster/plugin.json
python -m json.tool shared-skills/plugin.json
python -m json.tool codex-gate/plugin.json

# Test a change against a LOCAL clone before pushing (inside Claude Code):
#   /plugin marketplace add ./tlelosa-claude-config
#   /plugin install dcoe-roster@tlelosa-claude-config

# Roll out after push — run in the ai-product-factory environment
# (the sole vault; no second machine to repeat this on since 2026-08-20):
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
3. **Validate JSON** before committing catalog or plugin manifest changes;
   a broken manifest breaks installs on both machines. A `pre-commit` hook at
   `.githooks/pre-commit` enforces this automatically once `core.hooksPath`
   is set (one-time setup per machine, per clone). The session-start check
   above monitors drift; hard rule stands as documentation of intent.
4. **No `CLAUDE.md` inside plugin folders** — Claude Code ignores it there
   by design; per-project config stays a per-project file.
5. **Changes to `dcoe-roster/CORE.md` or to `agent-bodies-reference/` affect
   every opted-in project** — treat edits to them as structural (spec
   first), and bump the core version noted at the top of `CORE.md`. As of
   CORE 1.5 the agent bodies reach an environment via `dcoe-roster`'s
   `SessionStart` hook (missing-only — a local edit isn't silently
   reverted, but it also isn't silently updated), so an agent edit here
   reaches other sessions on their next session start, not on this push.
   A cloud session used to be the one surface this didn't reach (it clones
   the source repo without installing the marketplace, so the plugin hook
   never fires) — closed 2026-08-12 by a repo-level hook,
   `hub-template/hooks/cloud-roster-bootstrap.sh`, copy-installed into each
   opted-in project same as the other `hub-template/hooks/` scripts. See
   `docs/specs/2026-08-12-roster-cloud-sessions.md`. (This rule used to read
   "both machines" — Operations and Pappa T are retired as of 2026-08-20;
   ai-product-factory is the sole environment now, but the propagation
   mechanism itself is unchanged.)
