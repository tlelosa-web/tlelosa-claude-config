# Spec — JSON-validation pre-commit hook

**Date:** 2026-08-05 | **Status:** Draft — awaiting owner approval, no implementation yet
**Basis:** Repo-specific hard rule #3 ("Validate JSON before committing catalog or plugin
manifest changes") is currently self-monitored only — a session has to remember to run
`python -m json.tool` by hand. Prompted by comparing this repo's governance model against
the `ECC` project's `hooks/` layer (deterministic, event-triggered, outside model context).

## Problem

`.claude-plugin/marketplace.json`, `dcoe-roster/plugin.json`, and `shared-skills/plugin.json`
are read directly by Claude Code on `/plugin marketplace add` / `/plugin update` on both
machines. A broken manifest breaks installs on **both** Operations and Pappa T at once — the
repo's own stated worst case (`CLAUDE.md` hard rule #3). Enforcement of "validate before
commit" today is a line in `CLAUDE.md` a session has to recall and run manually; nothing
actually stops a malformed-JSON commit from landing.

## What

A versioned git `pre-commit` hook that runs `python -m json.tool` against every staged
`*.json` file and blocks the commit (non-zero exit) if any fails to parse. Deterministic,
local, no network dependency — fits the "only deterministic local gates may block" hooks
philosophy already documented in `CLAUDE.md.template`'s HOOKS section.

## Decisions to lock in

1. **Mechanism: git hook via `core.hooksPath`, not a Claude Code hook.** This repo has no
   `.claude/settings.json` hooks infra today, and a git hook catches *every* commit —
   whether made from inside a Claude Code session or by hand — where a Claude Code
   `PreToolUse` hook would only fire on Bash-tool-issued `git commit` calls from within a
   session. Given the stated worst case is "breaks installs on both machines," the wider net
   is the right default.
2. **Versioned in-repo, not `.git/hooks/` directly.** `.git/hooks/` is untracked and
   per-clone; a hook living there cannot be shipped or reviewed. Store the script at
   `.githooks/pre-commit` (tracked, reviewable, diffable) and point git at it via
   `git config core.hooksPath .githooks` — a one-time, per-machine, per-clone setup step
   (see Rollout).
3. **Scope: staged `*.json` files only.** Only files in the commit's staged set are checked
   (`git diff --cached --name-only --diff-filter=ACM -- '*.json'`), not the whole repo tree —
   keeps the hook fast and avoids failing a commit over an unrelated pre-existing issue
   elsewhere.
4. **Failure mode: block with a clear message, no auto-fix.** On any staged `.json` file
   failing `python -m json.tool`, the hook prints the failing file path(s) and Python's own
   parse error, then exits non-zero (commit refused). It never rewrites, reformats, or
   auto-fixes the file.
5. **No Python found → warn, don't block.** If `python` (or `python3`) is not on `PATH`, the
   hook prints a one-line warning (`python not found — skipping JSON validation`) and exits
   0. This is the one deliberate exception to "deterministic gates may block": missing
   tooling is an environment problem, not a JSON problem, and must never be able to wedge a
   machine out of committing entirely.

## Hook behaviour (script contents, `.githooks/pre-commit`)

```bash
#!/usr/bin/env bash
set -euo pipefail

PY=python3
command -v "$PY" >/dev/null 2>&1 || PY=python
if ! command -v "$PY" >/dev/null 2>&1; then
  echo "pre-commit: python not found — skipping JSON validation" >&2
  exit 0
fi

files=$(git diff --cached --name-only --diff-filter=ACM -- '*.json')
[ -z "$files" ] && exit 0

fail=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  if ! "$PY" -m json.tool "$f" >/dev/null 2>&1; then
    echo "pre-commit: invalid JSON in $f" >&2
    "$PY" -m json.tool "$f" 2>&1 | sed 's/^/  /' >&2
    fail=1
  fi
done <<< "$files"

[ "$fail" -eq 0 ] || {
  echo "pre-commit: commit blocked — fix the JSON above and re-stage" >&2
  exit 1
}
```

(Exact quoting/robustness to be finalized at implementation time — the shape above is the
spec-level intent, not final shippable code.)

## Rollout

- **One-time per machine, per clone:** `git config core.hooksPath .githooks` — documented as
  a new step in `CLAUDE.md`'s "ESSENTIAL COMMANDS" section, and in whichever rollout
  checklist doc is current at implementation time (per `docs/todo.md`'s existing pattern of
  consolidating machine-side steps into one ordered checklist).
- `core.hooksPath` is a **local git config**, not something that ships or syncs via the
  marketplace — every clone (Operations, Pappa T, and any future clone) must run the command
  once. This is a real gap versus "deterministic enforcement" if forgotten; call it out
  explicitly rather than assume it self-propagates.
- Existing hard rule #3 in `CLAUDE.md` stays as prose (defense in depth / documents intent)
  but gets a note that a `pre-commit` hook now enforces it locally once `core.hooksPath` is
  set.

## Out of scope

- Validating anything other than JSON syntax (schema shape, required marketplace/plugin
  fields, cross-file consistency) — pure `json.tool` parse-validity only, matching what the
  hard rule already asks for today.
- A `pre-push` or CI-side check — this is commit-time only, matching the "block at commit
  time, not write time" philosophy already documented in `CLAUDE.md.template`.
- Auto-installing the hook via a Claude Code `SessionStart` hook or similar automation —
  manual one-time `git config` per machine, consistent with how other per-machine setup
  steps in this repo are handled (e.g. Codex CLI auth in the codex-gate spec).
- Non-JSON manifest formats (there are none in this repo today).

## Acceptance criteria

1. Staging a `.json` file with a syntax error and running `git commit` is refused, with the
   failing file path and parse error printed, and the commit does not land.
2. Staging only valid JSON (or no JSON at all) allows the commit to proceed normally.
3. An untracked/unstaged `.json` file with broken syntax elsewhere in the working tree does
   **not** block a commit that doesn't touch it.
4. On a machine without `python`/`python3` on `PATH`, the commit proceeds with a printed
   warning — never blocked by missing tooling.
5. `git config core.hooksPath .githooks` is a documented, single copy-pasteable step in
   `CLAUDE.md`.
6. The hook script itself is tracked in git (`.githooks/pre-commit`) and reviewable in the
   same diff/PR as any future change to it.

## Config file changes

- New file: `.githooks/pre-commit` (executable bit set).
- `CLAUDE.md` — ESSENTIAL COMMANDS: add the one-time `git config core.hooksPath .githooks`
  step, and a note that it supersedes manually running `python -m json.tool` before commit
  (rule #3 stays as the documented intent; the hook is the enforcement).
- No `CORE.md` change — this is repo-local tooling, not a universal DCOE rule.
- No `marketplace.json` / `plugin.json` change — the hook is not a plugin, it is not
  installed via `/plugin`.

## Open questions for the reviewer / Codex pass

- Is git-hook-via-`core.hooksPath` preferred over a Claude-Code-native `PreToolUse` hook on
  the `Bash` tool matching `git commit`? The latter would auto-apply inside every Claude Code
  session without a manual `git config` step, at the cost of not catching commits made
  outside a session. Worth weighing given this repo's commits are, in practice, almost always
  made through Claude Code sessions.
- Should the one-time `core.hooksPath` setup be added to the rollout checklist as a tracked,
  tickable item (like the codex-gate Pappa T install), given it's easy to forget and silently
  leaves a machine unprotected?
