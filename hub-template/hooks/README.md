# hub-template/hooks — ready-made Claude Code hooks

Three hooks every DCOE project inherits by copying (see the HOOKS
section of `CLAUDE.md.template`):

- `secret-scan.sh` — **PreToolUse** on `Bash|Edit|Write`. Blocks (exit 2) any
  tool input containing Supabase `sb_secret_`/service_role material, JWT
  pairs, AWS access keys, GitHub PATs, or private-key blocks.
- `auto-format.sh` — **PostToolUse** on `Edit|Write`. Formats the edited file
  with black + ruff (Python) or the project-local prettier (JS/TS). Never
  blocks. Requires `jq`.
- `cloud-roster-bootstrap.sh` — **SessionStart**, cloud sessions only (checks
  `$CLAUDE_CODE_REMOTE`, no-op on Operations/Pappa T). Populates
  `~/.claude/agents/` by cloning `tlelosa-claude-config` and running its
  `agent-bodies-reference/bootstrap.mjs`, since the `dcoe-roster` plugin's own
  `SessionStart` hook never fires on a cloud session (it clones the target
  repo without installing the marketplace). Missing-only, same semantics as
  `bootstrap.mjs`. Spec:
  `docs/specs/2026-08-12-roster-cloud-sessions.md`.

## Install into a project

```bash
mkdir -p .claude/hooks
cp <this-repo>/hub-template/hooks/secret-scan.sh .claude/hooks/
cp <this-repo>/hub-template/hooks/auto-format.sh .claude/hooks/
cp <this-repo>/hub-template/hooks/cloud-roster-bootstrap.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

Then merge `settings-hooks-snippet.json` **and**
`settings-snippet-roster-bootstrap.json` into the project's
`.claude/settings.json` under the `hooks` key (hooks are registered in
settings.json — `.claude/hooks/` only stores the scripts). Both snippets key
off `SessionStart`, so merge their `hooks.SessionStart` arrays together
rather than letting one overwrite the other. Verify with `/hooks` in a
session.

## Platform note (2026-08-08)

`secret-scan.sh` and `auto-format.sh` are bash. Operations and Pappa T are
Windows machines, so they need git-bash on PATH for Claude Code to execute
them. Whether to ship PowerShell equivalents instead is an open decision —
tracked in `docs/todo.md`. Verify with `/hooks` on the target machine before
relying on either gate.

`cloud-roster-bootstrap.sh` (added 2026-08-12) doesn't carry this risk — it
no-ops immediately unless `$CLAUDE_CODE_REMOTE` is set, and every Claude Code
cloud/web container is Linux, so it never runs anywhere git-bash would be a
concern.
