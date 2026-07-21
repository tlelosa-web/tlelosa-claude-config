# Spec — Config-audit week-1 fixes (3 changes)

**Date:** 2026-07-21 · **Source:** `docs/research/claude-code-config-audit.md` (rows 1–3 of
the priority table / "3 changes this week") · **Type:** structural — touches the template,
CORE.md, and the dcoe-roster plugin that both machines install.

## Scope

Three changes, one commit each, in this order:

### 1. Executor worktree isolation (audit row 1)

Problem: `CLAUDE.md.template` GIT WORKTREE WORKFLOW tells executors to `cd` into an assigned
worktree from a "shared session". Subagents have their own contexts, and `cd` does not persist
between a subagent's Bash calls — so the rule as written produces executors that silently edit
the main checkout.

- `dcoe-roster/agents/executor.md`: add `isolation: worktree` frontmatter; adjust body to say
  the worktree is provided by the harness (branched from the default branch) and commands are
  confined to it — no `cd`-based setup.
- `CLAUDE.md.template` worktree section: replace the shared-session/`cd` bullet with the
  `isolation: worktree` mechanism; document the two caveats (auto-worktrees branch from the
  **default branch**, not session HEAD; auto-removed if unchanged); keep the manual
  `git worktree add` flow for stacked-branch work; note executors run in the background by
  default (v2.1.198+) and the Orchestrator waits for completion notifications before review.
- Review-before-merge gate is unchanged.

### 2. Real hooks: secret-scan + auto-format (audit rows 2 & 5)

Problem: the template's four hooks (`pre-commit`, `pre-push`, `post-task`, `session-start`)
name no real Claude Code events and ship no `settings.json` wiring — nothing fires.

- New `hub-template/hooks/`: `secret-scan.sh` (PreToolUse on `Bash|Edit|Write`, exit 2 on
  secret patterns — Supabase service_role/`sb_secret_`, JWT pairs, AWS, GitHub PAT, private
  keys), `auto-format.sh` (PostToolUse on `Edit|Write`, black/ruff for Python,
  project-local prettier for JS/TS, always exit 0), `settings-hooks-snippet.json` (the
  `hooks` block to merge into a project's `.claude/settings.json`), short `README.md`.
- `CLAUDE.md.template` HOOKS section: correct the registration location (settings.json, not
  `.claude/hooks/` — that's script storage), map all legacy gate names to real events
  (`PreToolUse` git-commit/push gates, `SubagentStop`, `SessionStart`), point at
  `hub-template/hooks/` for the shipped scripts. Keep the block-at-commit-time philosophy.

### 3. Explore override → restore the Haiku search tier (audit row 3)

Problem: since Claude Code v2.1.198 the built-in Explore agent inherits the session model
(Sonnet 5 here) instead of defaulting to Haiku; no roster agent implements the routing
tables' Haiku search tier, so it doesn't exist.

- New `dcoe-roster/agents/explore.md`: `name: Explore` (overrides the built-in when deployed
  to `~/.claude/agents/`), `model: claude-haiku-4-5`, read-only tools, search-and-cite-only
  body.
- `dcoe-roster/CORE.md`: add explore to the roster table, annotate the Haiku routing row with
  the v2.1.198 behavior change, bump core version 1.0 → 1.1.
- `CLAUDE.md.template`: mirror the roster row and routing annotation.

## Cross-cutting

- `CLAUDE.md.template` version 3.2 → **3.3**, trailer changelog line (done in commit 3, which
  finishes the template edits).
- `dcoe-roster/plugin.json` 3.3.0 → **3.4.0** (executor + explore changes), description
  updated to v3.3; `marketplace.json` dcoe-roster description likewise (validate both with
  `python -m json.tool` before committing).
- `docs/todo.md`: Done entry per change; Open entry for the 3.4.0 rollout on both machines.

## Acceptance criteria

- `executor.md` frontmatter contains `isolation: worktree`; no `cd`-into-worktree instruction
  survives anywhere in the template.
- Both hook scripts are executable, self-contained bash, and match the snippet's paths; the
  snippet parses as JSON.
- `explore.md` frontmatter: `name: Explore`, `model: claude-haiku-4-5`, read-only tools.
- Core version, plugin version, and template version all bumped; JSON files validate.
