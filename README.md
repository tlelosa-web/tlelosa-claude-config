# tlelosa-claude-config

Private Claude Code plugin marketplace. Holds tooling shared across the
Operations (work PC) and the personal Pappa T — never project content or
company data. Deliberately generic so it's safe to clone on either machine.

## What's in here

- `.claude-plugin/marketplace.json` — the catalog Claude Code reads.
- `dcoe-roster/` — the DCOE sub-agent roster as an installable plugin
  (domain, planner, architect, executor, tester, reviewer, doc-writer,
  debugger, data-agent). Matches CLAUDE.md v3.3's model routing table.
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
  `SKILLS-AUDIT-CHECKLIST.md` — run from a local session to find Skills
  built in one machine's projects that are generic enough to share with
  the other's; this is what produced the `shared-skills/` plugin below.
- `shared-skills/` — cross-project Claude Code Skills as an installable
  plugin (`shared-skills/skills/<name>/SKILL.md` each): `dev-server-
  staleness-check`, `safe-office-file-read`, `reuse-existing-ui-primitive`,
  `sweep-shared-ui-convention-fix`, `verify-ui-cardinality-against-output`.
  Each was drafted business-agnostic in the `Operations` hub's
  `docs/research/skill-drafts/` before migrating here — see that hub's
  `docs/patterns.md` for the promotion discipline.
- `codex-gate/` — advisory cross-family second-opinion gate as an
  installable plugin: `/codex-review docs/specs/<feature>.md` sends exactly
  one spec file to the OpenAI Codex CLI and appends the response to the
  spec as an advisory note. Warn-only, never blocks (offline-first hard
  rule); the `reviewer` agent keeps sole APPROVE/BLOCK authority.
  **Install per machine, Pappa T only for now** — see IT-policy status
  below. Spec: `docs/specs/2026-07-21-codex-gate-spec.md`; readiness audit:
  `docs/specs/2026-07-21-codex-gate-readiness-audit.md`. Requires the Codex
  CLI authenticated at user scope (`~/.codex/`) — no API key ever lives in
  this repo or any project `.env`.

  ```
  # Pappa T ONLY (until Operations OpenAI clearance):
  /plugin install codex-gate@tlelosa-claude-config
  ```

**Not included:** CLAUDE.md itself. Claude Code's plugin system does not
recognize a CLAUDE.md inside a plugin folder — it's ignored by design.
CLAUDE.md stays a per-project file, copied in manually (or via a small
script) when a project is created or the master template updates. Keep
the master template (`CLAUDE.md.template`) alongside this repo for
reference, not as a plugin component.

## One-time setup — run on EACH machine (Operations and Pappa T)

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

## External plugins — run on EACH machine (Operations and Pappa T)

Approved external tooling installed alongside this marketplace (not
distributed through it — install from the official directory so upstream
updates flow directly):

```
# Context7 — live, version-correct library docs for executor/debugger work
/plugin install context7@claude-plugins-official

# Anthropic document skills (xlsx/docx/pdf) — strengthens data-agent's
# report prep; complements shared-skills' safe-office-file-read
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

Install at **user** scope (the default) so it's available across projects.
Works without an API key at lower rate limits; add a key later via
context7.com if throttling bites. Covered by the IT clearance below.

## IT-policy status (Operations machine)

Cleared by Fan Movement IT (2026-07-21): personal Anthropic account approved
for use on the work PC, covering this repo's use there. Confirmed broad
enough to cover approved external AI tooling, including Context7's external
MCP service. This repo still
contains no company data by design — that remains a hard rule regardless of
the clearance. If the policy changes, or a new tool goes beyond what was
cleared (e.g. a plugin talking to a new external service), re-confirm before
installing it on Operations.

**Not covered by the clearance:** `codex-gate` (OpenAI egress). The
existing clearance is Anthropic-specific plus named tools; sending spec
content to OpenAI from the work PC needs its own confirmation. Until then,
do **not** install `codex-gate` on Operations — Pappa T only.
