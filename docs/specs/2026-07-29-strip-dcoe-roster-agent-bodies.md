# Spec — Strip agent bodies from the dcoe-roster plugin

**Date:** 2026-07-29 | **Decided by:** Tebello Lelosa (via `/continue`, Operations hub)

## Problem

`dcoe-roster/agents/*.md` ships full copies of the 9 roster agent bodies
inside the plugin, duplicating the authoritative user-level roster
(`~/.claude/agents/`). Because Claude Code namespaces marketplace plugins by
install-cache commit-SHA, every session lists each agent three times
(unprefixed user-level, `dcoe-roster:*`, `<sha>:*`). Confirmed cosmetic only
(Operations `docs/todo.md`, 2026-07-23 investigation) — nothing is broken,
the unprefixed name always resolves correctly.

## Decision

Strip `dcoe-roster/agents/` from the plugin. Accept the tradeoff: the
plugin no longer doubles as a new-machine roster-bootstrap vehicle. Bootstrap
becomes a manual step — copy `dcoe-roster/agents/*.md` (still available in
this repo's working tree, just not plugin-installed) into
`~/.claude/agents/` on a new machine, or clone this repo and copy from there.

## Changes

1. Move `dcoe-roster/agents/` (9 files) out of the plugin folder to
   `agent-bodies-reference/` at repo root — preserves the content as a
   copy-paste source for new-machine bootstrap, but out of any path Claude
   Code's plugin loader scans for agent definitions (deletion would lose
   the reference copy for no extra benefit; moving keeps it usable without
   double-loading).
2. Bump `dcoe-roster/plugin.json` version (3.3.0 → 3.4.0) and note the
   change in its description/CHANGELOG if one exists.
3. Update `README.md` § "Updating the roster" — editing now happens
   directly in `~/.claude/agents/` on each machine; `agent-bodies-reference/`
   is the reference copy to bootstrap a new machine from (copy its files into
   `~/.claude/agents/`), no longer plugin-installed.
4. Update `docs/rollout-checklist-2026-07-21.md` verify step ("`/agents`
   shows all nine roster agents" after installing `dcoe-roster`) — that
   step no longer applies to a fresh plugin install; note the new manual
   bootstrap step instead. (Historical checklist — informational fix only,
   not re-run.)
5. No change needed to `dcoe-roster/CORE.md` — it already documents
   `~/.claude/agents/` as the default/authoritative location (lines 78-95).

## Out of scope

Does not touch `shared-skills`, `codex-gate`, or any other plugin. Does not
change CORE.md content or version.
