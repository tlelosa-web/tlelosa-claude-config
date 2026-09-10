---
name: core-version-bump-is-one-commit
description: In tlelosa-claude-config, a core version bump spans CORE.md + roster-manifest.json + plugin.json and must land as ONE commit, not split per-file
metadata:
  type: project
---

A core version bump in this repo touches exactly three live files, and they must be bumped in a single commit even though that exceeds the repo's "tasks touch at most 2 files" rule.

The three live citation sites (verified 2026-09-10 at core 1.10 / plugin 3.11.0):
- `dcoe-roster/CORE.md` header line 3 — `**Core version: X**`
- `agent-bodies-reference/roster-manifest.json` — `"coreVersion"`
- `dcoe-roster/plugin.json` — the `description` string embeds `v1.X`, and the plugin's own semver is a separate field

Everything else matching a version string is historical spec/todo prose and must NOT be rewritten.

**Why:** `docs/specs/2026-08-08-model-routing.md:140-147` set the precedent explicitly — "a core version bump is a single distribution event... splitting them would ship a template referencing a CORE version that does not exist yet." And `roster-manifest.json`'s `coreVersion` going stale is a *recorded, repeated* failure in this repo: found at 1.4 and at 1.6 in separate incidents (`docs/todo.md:387`, `docs/todo.md:412`, `docs/specs/2026-08-20-verify-fetch-succeeded-hard-rule-10.md:54`). Splitting the bump across commits manufactures exactly that stale intermediate state.

**How to apply:** When reviewing any spec that bumps the core version, check (a) all three files are named — grep to confirm no fourth site has appeared, don't trust the spec's list, and (b) they are one task/one commit with the ≤2-file exemption stated explicitly on the 2026-08-08 precedent. Flag per-file splitting as a warning, not a nit.

Related: [[bootstrap-quiet-flag-silences-checks]], [[retired-machine-names-still-in-live-strings]]
