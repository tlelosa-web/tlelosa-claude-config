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

1. **Mechanism: git hook via `core.hooksPath`, not a Claude Code hook. Locked, not open.**
   This repo has no `.claude/settings.json` hooks infra today, and a git hook catches *every*
   commit — whether made from inside a Claude Code session or by hand — where a Claude Code
   `PreToolUse` hook would only fire on Bash-tool-issued `git commit` calls from within a
   session. Given the stated worst case is "breaks installs on both machines," the wider net
   is the right default.
   **Rejected alternative — Claude-Code-native `PreToolUse` hook on `Bash` matching
   `git commit`:** would auto-apply inside every session with no manual `git config` step,
   but silently misses any commit made outside a Claude Code session (manual terminal
   commits, other tools). Since the failure mode being guarded against is "a broken manifest
   breaks installs on both machines" regardless of how the bad commit was made, coverage
   breadth outweighs the convenience of zero-setup. Not reopened as a question below.
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
5. **No Python found → block, not warn. Reversed from the draft.** The draft proposed
   warning and letting the commit through if `python`/`python3` is missing, reasoning by
   analogy to codex-gate's warn-fail pattern. The reviewer agent correctly rejected that
   analogy: codex-gate's warn-fail exists because it is a *network-dependent advisory* gate,
   and this repo's own documented hooks philosophy (`CLAUDE.md.template`, HOOKS section) is
   explicit that "only deterministic local gates may block; network-dependent advisory gates
   warn and proceed." JSON syntax checking is a deterministic local gate — the philosophy
   says it *should* block, and a missing interpreter is exactly the failure mode most likely
   on a freshly-provisioned machine, i.e. exactly when the gate is most needed. Locked
   behavior: **the python check only runs after confirming the commit stages at least one
   `*.json` file** (script computes the staged-file set first, exits 0 immediately if empty,
   and only then checks for an interpreter) — a commit that touches no JSON must never be
   blocked by a missing interpreter, consistent with Decision #3's "staged JSON files only"
   scope and AC2. If neither `python3` nor `python` is found *and* JSON is staged, the hook
   prints `pre-commit: python3/python not found — install Python to commit JSON changes` and
   exits non-zero (commit refused).

## Hook behaviour (script contents, `.githooks/pre-commit`)

```bash
#!/usr/bin/env bash
set -euo pipefail

files=$(git diff --cached --name-only --diff-filter=ACM -- '*.json')
[ -z "$files" ] && exit 0

PY=python3
command -v "$PY" >/dev/null 2>&1 || PY=python
if ! command -v "$PY" >/dev/null 2>&1; then
  echo "pre-commit: python3/python not found — install Python to commit JSON changes" >&2
  exit 1
fi

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
  a new step in `CLAUDE.md`'s "ESSENTIAL COMMANDS" section, and added as a **tracked,
  tickable item** in the current rollout checklist doc (per `docs/todo.md`'s existing pattern
  of consolidating machine-side steps into one ordered checklist — same precedent as the
  codex-gate Pappa T install tracking). Not left as an untracked aside.
- `core.hooksPath` is a **local git config**, not something that ships or syncs via the
  marketplace — every clone (Operations, Pappa T, and any future clone) must run the command
  once. This is a real gap versus "deterministic enforcement" if forgotten, so it is backed by
  a compensating check rather than trusted to memory alone (see next bullet).
- **Compensating drift check, locked in:** add one line to this repo's `SESSION START`
  section in `CLAUDE.md` — `git config core.hooksPath` is checked at the start of any session
  that touches this repo (a single `git config --get core.hooksPath` call); if unset or not
  `.githooks`, the session prints a one-line warning surfaced to the owner
  (`core.hooksPath is not set on this machine — JSON pre-commit hook is inactive; run: git
  config core.hooksPath .githooks`) before proceeding. This does not block the session —
  it makes the drift visible instead of silent, which is the actual gap being closed.
- Existing hard rule #3 in `CLAUDE.md` stays as prose (defense in depth / documents intent)
  but gets a note that a `pre-commit` hook now enforces it locally once `core.hooksPath` is
  set, backed by the session-start drift check above.

## Non-issue check before rollout

Setting `core.hooksPath` repo-wide shadows any hook already sitting in a clone's
`.git/hooks/` (e.g. a personal commit-msg or signing hook), not just adds the JSON check
alongside it. Believed to be a non-issue today — no existing local hooks are known on either
machine — but each machine's `.git/hooks/` should be glanced at before running the
`core.hooksPath` config, so nothing already relied upon is silently disabled.

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
4. On a machine without `python`/`python3` on `PATH`: a commit that stages a `.json` file is
   refused with the `install Python to commit JSON changes` message (does not silently
   proceed); a commit that stages **no** `.json` file proceeds normally regardless of
   whether python is present — the missing interpreter never blocks a non-JSON commit.
5. `git config core.hooksPath .githooks` is a documented, single copy-pasteable step in
   `CLAUDE.md`, and appears as a tracked item in the current rollout checklist doc.
6. The hook script itself is tracked in git (`.githooks/pre-commit`) and reviewable in the
   same diff/PR as any future change to it, with its executable bit set in git
   (`git ls-files -s .githooks/pre-commit` shows mode `100755`).
7. A session that reads `CLAUDE.md`'s SESSION START on a machine where
   `core.hooksPath` is unset prints the drift warning before proceeding.

## Config file changes

- New file: `.githooks/pre-commit` (executable bit set).
- `CLAUDE.md` — ESSENTIAL COMMANDS: add the one-time `git config core.hooksPath .githooks`
  step, and a note that it supersedes manually running `python -m json.tool` before commit
  (rule #3 stays as the documented intent; the hook is the enforcement).
- `CLAUDE.md` — SESSION START: add the one-line `core.hooksPath` drift check described above.
- Current rollout checklist doc: add the `git config core.hooksPath .githooks` step as a
  tracked, tickable item per machine.
- No `CORE.md` change — this is repo-local tooling, not a universal DCOE rule.
- No `marketplace.json` / `plugin.json` change — the hook is not a plugin, it is not
  installed via `/plugin`.

## Codex second opinion (advisory) — 2026-08-05

`/codex-review` was run against this spec's first draft. Unavailable this session: the
Codex CLI is not installed on this machine (`command -v codex` failed). Per the codex-gate
spec's mandatory fail-warn behavior, this is logged as a warn, not treated as a blocker or
retried. No external cross-family opinion exists for this spec yet; it should be re-attempted
from a machine with Codex CLI installed and authed (Pappa T) before/alongside build if that
becomes available. `docs/session-log.md` does not exist in this repo, so no log line was
written there per the command's "create nothing if it doesn't exist" rule.

_Advisory only — reviewer agent retains sole APPROVE/BLOCK authority._

## Revision history

- **2026-08-05, rev 2:** Reviewer agent pass (general-purpose agent carrying the
  `reviewer.md` persona, standing in for the unbootstrapped native `reviewer` agent on this
  machine) returned **BLOCK** on rev 1, citing: (1) the mechanism decision was stated as
  locked then reopened as an open question — contradiction removed, PreToolUse recorded as a
  rejected alternative instead; (2) the rollout gap (manual per-clone `core.hooksPath` setup)
  was flagged as a risk but left unresolved — now backed by a tracked checklist item plus a
  session-start drift check (AC7); (3) missing Codex-attempt note per CORE.md rule 9 — added
  above. Also addressed as non-blocking nits: the python-missing fallback was reversed from
  warn to block, consistent with this repo's own "deterministic local gates may block" hooks
  philosophy (finding 4); an executable-bit acceptance criterion was added (AC6, finding 5);
  and a non-issue check for pre-existing `.git/hooks/` shadowing was added (finding 6).
- **2026-08-05, rev 3:** Reviewer re-review of rev 2 returned **BLOCK** again — the six
  procedural findings from rev 1 were confirmed fixed, but the rev-2 script itself introduced
  a correctness bug: the python-availability check ran *before* checking whether any JSON was
  staged, so a python-less machine would be blocked from committing *anything*, including
  non-JSON changes and a fix to the hook itself — directly contradicting Decision #3's scope
  and AC2. Fixed by reordering the script (staged-JSON check first, python check only if JSON
  is staged) and reconciling Decision #5 / AC4 wording to state that scope explicitly.
