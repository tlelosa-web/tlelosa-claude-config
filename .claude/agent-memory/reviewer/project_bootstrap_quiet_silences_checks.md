---
name: bootstrap-quiet-flag-silences-checks
description: bootstrap.mjs's --quiet guard wraps the drift report; any new exit-code logic placed near it gets silently disabled — check every bootstrap.mjs spec for this
metadata:
  type: project
---

In `agent-bodies-reference/bootstrap.mjs`, `QUIET` currently gates exactly one thing: the default-mode drift report (`if (roster.diverged.length && !QUIET)`). Any new failure/exit-code logic that a spec describes as going "in the default-mode notes block" lands inside that guard and becomes switchable-off by a verbosity flag.

Caught this on the 2026-09-10 `--fail-on-drift` spec, which never mentioned `--quiet` at all while directing the Executor at that exact block.

**Why:** The file's own docstring design rule is "Loud on failure. Silence means success; it must never mean 'never ran'." A detector a verbosity flag can silence rebuilds the defect it exists to fix. Note the SessionStart hooks (`dcoe-roster/hooks/hooks.json`, `hub-template/hooks/cloud-roster-bootstrap.sh`) do NOT pass `--quiet`, so the blast radius is hand-run and scripted use, not the hook path.

**How to apply:** For any spec touching `bootstrap.mjs` exit codes or reporting, require that (a) Design states whether `--quiet` affects the exit code — correct answer is that it suppresses text only, never exit status, and (b) at least one acceptance criterion actually passes `--quiet`. Treat omission as a blocker, not a nit: it ships as a spec-conformant implementation.

Related: [[core-version-bump-is-one-commit]], [[spec-acceptance-criteria-restate-not-test]]
