#!/usr/bin/env bash
# PostToolUse hook — format the file Claude just edited. Registered via
# settings-hooks-snippet.json with matcher "Edit|Write". Non-blocking by
# design: the edit already happened, so this always exits 0 (a PostToolUse
# hook cannot block anyway). Formatters run only if present, so the same
# script works in Python and Node projects unchanged.

command -v jq >/dev/null 2>&1 || exit 0
FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

case "$FILE" in
  *.py)
    command -v black >/dev/null 2>&1 && black --quiet "$FILE" 2>/dev/null
    command -v ruff >/dev/null 2>&1 && ruff check --fix --quiet "$FILE" 2>/dev/null
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.css)
    if [ -x node_modules/.bin/prettier ]; then
      node_modules/.bin/prettier --log-level silent --write "$FILE" 2>/dev/null
    fi
    ;;
esac

exit 0
