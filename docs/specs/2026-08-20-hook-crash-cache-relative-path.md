# Spec — Fix dcoe-roster SessionStart hook crash (cache-relative path)

**Date:** 2026-08-20 | **Decided by:** Tebello Lelosa (via chat, ai-product-factory hub)

## Problem

Every session start on Pappa T printed:

```
SessionStart:startup hook error
Failed with non-blocking status code: node:internal/modules/cjs/loader:1459
```

Reproduced directly: `node "${CLAUDE_PLUGIN_ROOT}/../agent-bodies-reference/bootstrap.mjs"`
throws `Error: Cannot find module '...\dcoe-roster\agent-bodies-reference\bootstrap.mjs'`
when `CLAUDE_PLUGIN_ROOT` is a plugin cache directory
(`~/.claude/plugins/cache/tlelosa-claude-config/dcoe-roster/<sha>/`).

## Root cause

`agent-bodies-reference/` was deliberately kept at the repo root, sibling to
`dcoe-roster/`, per [[2026-07-29-strip-dcoe-roster-agent-bodies]] — to avoid
the plugin loader double-listing agent bodies. That layout only resolves
correctly when Claude Code runs the plugin from a full git checkout (e.g.
`plugins/marketplaces/tlelosa-claude-config/`). In normal operation Claude
Code instead runs installed plugins from its **per-plugin cache**, which
copies only the plugin's own folder — not repo-root siblings. So
`${CLAUDE_PLUGIN_ROOT}/../agent-bodies-reference/` never exists there, and
`node` throws an uncaught `MODULE_NOT_FOUND` before `bootstrap.mjs`'s own
top-level error handling ever runs.

Confirmed low-impact: `~/.claude/agents/` already had all 10 roster files on
this machine, so the hook (missing-only mode) had nothing to add — the
crash was pure noise, not a functional loss.

## Fix

Guard the hook command with a file-existence check so a cache-run session
no-ops silently instead of crashing:

```
if [ -f "${CLAUDE_PLUGIN_ROOT}/../agent-bodies-reference/bootstrap.mjs" ]; then node "..."; fi
```

Changed in `dcoe-roster/hooks/hooks.json`.

## Out of scope (follow-up, not done here)

Moving `agent-bodies-reference/` inside `dcoe-roster/` (as a non-`agents/`-named
subfolder, e.g. `dcoe-roster/agent-bodies-reference/`) would let the hook
actually run from cache instead of silently skipping. Not done now — it
touches ~14 files (hooks.json, plugin.json, CORE.md, README.md, multiple
spec docs, hub-template/cloud-roster-bootstrap.sh) and the roster is already
fully deployed on the only machine this was observed on. Revisit if a new
machine's bootstrap ever needs this hook to actually fire from a cached
plugin install.
