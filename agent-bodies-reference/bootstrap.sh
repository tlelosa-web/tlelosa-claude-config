#!/usr/bin/env bash
# bootstrap.sh — copy the 10 DCOE roster agent bodies into ~/.claude/agents/
#
# Context: dcoe-roster/agents/ used to be plugin-installed and auto-bootstrapped
# a new machine's ~/.claude/agents/. That stopped (see
# docs/specs/2026-07-29-strip-dcoe-roster-agent-bodies.md) and bootstrap became
# a manual "copy these 9 files" step. This script is that manual step turned
# into a real, idempotent, safe-to-rerun script.
#
# Behavior:
#   - Creates ~/.claude/agents/ if it doesn't exist.
#   - Copies each of the 10 named files from this script's own directory into
#     ~/.claude/agents/, only touching those 9 filenames — nothing else in
#     that directory is read, moved, or removed.
#   - Idempotent: running it twice in a row leaves the same end state both
#     times.
#   - Before overwriting a destination file that already differs in content
#     from the reference copy, prints a one-line notice naming the file, then
#     overwrites anyway — the reference copy in this repo is the source of
#     truth (per the strip-agent-bodies spec's decision).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${HOME}/.claude/agents"

AGENTS=(
  architect.md
  data-agent.md
  debugger.md
  doc-writer.md
  domain.md
  executor.md
  explore.md
  planner.md
  reviewer.md
  tester.md
)

mkdir -p "$DEST_DIR"

for agent in "${AGENTS[@]}"; do
  src="${SCRIPT_DIR}/${agent}"
  dest="${DEST_DIR}/${agent}"

  if [[ ! -f "$src" ]]; then
    echo "bootstrap.sh: missing expected source file: $src" >&2
    exit 1
  fi

  if [[ -f "$dest" ]] && ! cmp -s "$src" "$dest"; then
    echo "bootstrap.sh: overwriting $dest (content differed from reference)"
  fi

  if ! cp "$src" "$dest"; then
    echo "bootstrap.sh: failed copying $agent — rerun to retry (script is idempotent)" >&2
    exit 1
  fi
done

echo "bootstrap.sh: ${#AGENTS[@]} roster agents present in $DEST_DIR"
