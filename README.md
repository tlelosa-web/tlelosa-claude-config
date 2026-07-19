# tlelosa-claude-config

Private Claude Code plugin marketplace. Holds tooling shared across the
Fan Movement work PC and the personal Pappa T — never project content or
company data. Deliberately generic so it's safe to clone on either machine.

## What's in here

- `.claude-plugin/marketplace.json` — the catalog Claude Code reads.
- `dcoe-roster/` — the DCOE sub-agent roster as an installable plugin
  (domain, planner, architect, executor, tester, reviewer, doc-writer,
  debugger, data-agent). Matches CLAUDE.md v3.2's model routing table.
  Also holds `dcoe-roster/CORE.md` — the shared DCOE core (architecture,
  roster table, model routing, universal hard rules), distributed to any
  project via a plain read instruction in that project's own `CLAUDE.md`
  (not a Claude Code `@import` — those don't resolve absolute paths
  outside the project tree). See `ADR-007` in the `Operations` hub's
  `docs/decisions/` for the full design.
- `hub-template/` — the mechanical skeleton for running the hub-and-spoke
  `/continue` pattern at *any* Tebello-governed vault root (not just
  `Operations`): a vault-agnostic `continue.md` to copy in verbatim, and
  `HUB-CHECKLIST.md`, a checklist a session reconciles that vault's own
  root `CLAUDE.md` against (never a file that overwrites one). See
  `ADR-008` in the `Operations` hub's `docs/decisions/`. Also holds
  `retro.md` — the batched-improvement counterpart to `/continue`: reviews
  a vault's `docs/todo.md`/`docs/session-log.md` for recurring friction
  (redundant work, a session needing to be manually corrected on something
  already settled) and proposes a confirmable batch of fixes, logging each
  run to that vault's own `docs/retro-log.md` so it doesn't re-raise what
  was already declined.
- `shared-skills/` — cross-project Claude Code Skills as an installable
  plugin (`shared-skills/skills/<name>/SKILL.md` each): `dev-server-
  staleness-check`, `safe-office-file-read`, `reuse-existing-ui-primitive`,
  `sweep-shared-ui-convention-fix`, `verify-ui-cardinality-against-output`.
  Each was drafted business-agnostic in the `Operations` hub's
  `docs/research/skill-drafts/` before migrating here — see that hub's
  `docs/patterns.md` for the promotion discipline.

## Maintaining this repo

This repo's own maintenance work (new plugin components, framework fixes)
is tracked the same way it tells other vaults to track theirs — just not
published as a plugin component, same as `CLAUDE.md` below:
- `docs/todo.md` / `docs/session-log.md` — this repo's own task queue and
  append-only session archive.
- `.claude/commands/continue.md` / `.claude/commands/end-session.md` — a
  resume/archive pair scoped to this repo specifically (simpler than the
  hub-and-spoke `continue.md`/`retro.md` in `hub-template/`, which are
  templates *for other vaults*, not for this repo itself).

**Not included:** CLAUDE.md itself. Claude Code's plugin system does not
recognize a CLAUDE.md inside a plugin folder — it's ignored by design.
CLAUDE.md stays a per-project file, copied in manually (or via a small
script) when a project is created or the master template updates. Keep
the master template (`CLAUDE.md.template`) alongside this repo for
reference, not as a plugin component.

## One-time setup — run on EACH machine (work PC and Pappa T)

```powershell
# Confirm git auth works first (SSH key loaded, or gh auth login, or a PAT)
gh auth status

# Inside a Claude Code session:
```
```
/plugin marketplace add https://github.com/tlelosa-web/tlelosa-claude-config.git
/plugin install [email protected]
```

Default install scope is **user** — the roster becomes available in every
project on that machine automatically, no per-project copying.

Verify with:
```
/plugin marketplace list
/plugin list
```

## Updating the roster (e.g. after refining reviewer.md)

1. Edit the relevant file under `dcoe-roster/agents/` in your local clone.
2. `git add . && git commit -m "..." && git push`
3. On **each** machine:
   ```
   /plugin marketplace update tlelosa-claude-config
   /plugin update [email protected]
   /reload-plugins
   ```

For hands-off updates instead of step 3, set a `GITHUB_TOKEN` in your shell
profile on each machine (repo scope) — Claude Code will background-refresh
private marketplaces on startup.

## Before relying on this for real

Run `/plugin marketplace add ./tlelosa-claude-config` against a **local**
clone first to confirm the JSON validates and the roster installs cleanly,
before pushing and pointing both machines at the remote. The exact
marketplace.json / plugin.json schema here is a best-effort starting
point — cross-check against `code.claude.com/docs/en/plugins` if
`/plugin marketplace add` reports a validation error.

## One thing worth checking before using this on the work PC

Confirm whether Fan Movement's IT policy allows cloning a personal private
GitHub repo (or using a personal GitHub/git account) on a company-issued
machine. This repo contains no company data by design, but the account and
hosting choice is a policy question for your employer, not something this
repo can resolve on its own.
