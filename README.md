# tlelosa-claude-config

Private Claude Code plugin marketplace. Holds tooling shared across the
Fan Movement work PC and the personal home PC — never project content or
company data. Deliberately generic so it's safe to clone on either machine.

## What's in here

- `.claude-plugin/marketplace.json` — the catalog Claude Code reads.
- `dcoe-roster/` — the DCOE sub-agent roster as an installable plugin
  (domain, planner, architect, executor, tester, reviewer, doc-writer,
  debugger, data-agent). Matches CLAUDE.md v3.2's model routing table.

**Not included:** CLAUDE.md itself. Claude Code's plugin system does not
recognize a CLAUDE.md inside a plugin folder — it's ignored by design.
CLAUDE.md stays a per-project file, copied in manually (or via a small
script) when a project is created or the master template updates. Keep
the master template (`CLAUDE.md.template`) alongside this repo for
reference, not as a plugin component.

## One-time setup — run on EACH machine (work PC and home PC)

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
