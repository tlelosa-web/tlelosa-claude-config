# hub-template/hooks — ready-made Claude Code hooks

Two quality gates every DCOE project inherits by copying (see the HOOKS
section of `CLAUDE.md.template`):

- `secret-scan.sh` — **PreToolUse** on `Bash|Edit|Write`. Blocks (exit 2) any
  tool input containing Supabase `sb_secret_`/service_role material, JWT
  pairs, AWS access keys, GitHub PATs, or private-key blocks.
- `auto-format.sh` — **PostToolUse** on `Edit|Write`. Formats the edited file
  with black + ruff (Python) or the project-local prettier (JS/TS). Never
  blocks. Requires `jq`.

## Install into a project

```bash
mkdir -p .claude/hooks
cp <this-repo>/hub-template/hooks/secret-scan.sh .claude/hooks/
cp <this-repo>/hub-template/hooks/auto-format.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

Then merge `settings-hooks-snippet.json` into the project's
`.claude/settings.json` under the `hooks` key (hooks are registered in
settings.json — `.claude/hooks/` only stores the scripts). Verify with
`/hooks` in a session.

## Platform note (2026-08-08)

Both scripts are bash. Operations and Pappa T are Windows machines, so they
need git-bash on PATH for Claude Code to execute them. Whether to ship
PowerShell equivalents instead is an open decision — tracked in
`docs/todo.md`. Verify with `/hooks` on the target machine before relying on
either gate.
