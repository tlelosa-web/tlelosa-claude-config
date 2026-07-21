#!/usr/bin/env bash
# PreToolUse hook — block Bash commands and file edits whose input contains
# secret material. Registered via settings-hooks-snippet.json with matcher
# "Bash|Edit|Write". Exit 2 blocks the tool call; stderr is fed back to
# Claude, which should switch to referencing the value from .env instead.
#
# Note: Supabase anon/publishable keys are JWTs too and will also match —
# intentional: every key belongs in env vars, not inline in commands or code.

INPUT=$(cat)

PATTERNS=(
  'sb_secret_[A-Za-z0-9_-]{10,}'
  'SUPABASE_SERVICE_ROLE_KEY[[:space:]]*[=:][[:space:]]*[A-Za-z0-9._-]{20,}'
  'eyJ[A-Za-z0-9_-]{20,}\.eyJ[A-Za-z0-9_-]{20,}'
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{36}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
)

for pattern in "${PATTERNS[@]}"; do
  if printf '%s' "$INPUT" | grep -qE -e "$pattern"; then
    echo "Blocked: tool input matches secret pattern ($pattern)." \
         "Load secrets from .env / environment variables — never inline them" \
         "in commands, code, or comments." >&2
    exit 2
  fi
done

exit 0
