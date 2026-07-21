# Marketplace validation — run on EACH machine

Step-by-step validation of this marketplace against a local clone first,
then the remote swap both machines run on permanently. Completes the
"validate against a local clone" item in `docs/todo.md` and the README's
"Before relying on this for real" section. Same procedure on both
machines, with one gating difference for Operations.

## Before you start — Operations only

Resolve the IT policy question first (see `docs/todo.md` and the README's
final section): confirm Fan Movement allows cloning a personal private
GitHub repo on a company machine. Don't run the steps below on Operations
until that's cleared. Pappa T can proceed immediately.

## Phase 1 — Prerequisites

```powershell
# Confirm git auth works (SSH key loaded, or gh auth login, or a PAT)
gh auth status

# Clone (or refresh) the repo somewhere convenient, e.g. your home folder
git clone https://github.com/tlelosa-web/tlelosa-claude-config.git
# — or if a clone already exists:
git -C tlelosa-claude-config pull
```

Confirm the clone is at current `main` (`git log --oneline -1`) so you're
validating what's actually deployed.

## Phase 2 — Local-clone validation

Start a Claude Code session **in the directory containing the clone** (so
the relative path resolves), then:

```
/plugin marketplace add ./tlelosa-claude-config
```

This is the moment of truth for `marketplace.json`. If it reports a
validation error, the schema here was a best-effort starting point —
cross-check against code.claude.com/docs/en/plugins and note what needed
fixing (that fix is then a commit to this repo).

If it validates, install both plugins from the local marketplace:

```
/plugin install dcoe-roster@tlelosa-claude-config
/plugin install shared-skills@tlelosa-claude-config
```

Verify:

```
/plugin marketplace list   → tlelosa-claude-config listed, local path source
/plugin list               → both plugins installed, user scope
/agents                    → domain, planner, architect, executor, tester,
                             reviewer, doc-writer, debugger, data-agent
```

For the Skills, confirm the five from `shared-skills` appear as available:
`dev-server-staleness-check`, `safe-office-file-read`,
`reuse-existing-ui-primitive`, `sweep-shared-ui-convention-fix`,
`verify-ui-cardinality-against-output`.

## Phase 3 — Swap to the remote

Once the local install is proven clean, replace it with the remote-backed
marketplace:

```
/plugin marketplace remove tlelosa-claude-config
/plugin marketplace add https://github.com/tlelosa-web/tlelosa-claude-config.git
/plugin install dcoe-roster@tlelosa-claude-config
/plugin install shared-skills@tlelosa-claude-config
```

Re-run the same verification commands as Phase 2. Then confirm the path
that opted-in projects' `CLAUDE.md` files reference (ADR-007) exists:

```powershell
Test-Path ~\.claude\plugins\marketplaces\tlelosa-claude-config\dcoe-roster\CORE.md
```

`True` is what makes the CORE.md read instruction work in every project on
that machine.

## Phase 4 — Prove the update loop (optional, ~2 minutes)

```
/plugin marketplace update tlelosa-claude-config
/plugin update dcoe-roster@tlelosa-claude-config
/reload-plugins
```

Should complete cleanly even with no upstream changes. For hands-off
refresh instead, set a repo-scoped `GITHUB_TOKEN` in the shell profile —
Claude Code then background-refreshes private marketplaces on startup
(which is also what makes the hub `/continue`'s Step 1.5 upstream check
meaningful).

## Done when

Both machines pass Phase 3. Then tick the item off in `docs/todo.md` —
that update is itself a one-task commit per this repo's rules.
