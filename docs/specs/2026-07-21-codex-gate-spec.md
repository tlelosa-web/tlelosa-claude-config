# Spec — Codex cross-family second-opinion gate (phase 1)

**Date:** 2026-07-21 | **Status:** Awaiting owner approval — no implementation yet
**Basis:** `docs/specs/2026-07-21-codex-gate-readiness-audit.md` + owner
decisions (2026-07-21): specs-only payload · self-owned command · logged-note
disagreement handling · no ExitPlanMode hook.

## What

A single self-owned slash command, `/codex-review <spec-file>`, that sends
exactly one spec file to OpenAI Codex for an advisory cross-family second
opinion, and appends the result to the spec as a logged note. It slots into
Pattern 1 step 2: Planner writes spec → `/codex-review` → human approves or
iterates. Warn-only, never blocking.

## Decisions locked in

1. **Payload scope: specs only.** The command accepts exactly one path, and
   only under `docs/specs/` of the project it is run in. All sub-projects
   (MIMS App, IQ, TebelloReborn, Tenders), all vault notes/docs, and all
   other repo content are outside the payload — not by redaction but by
   construction: nothing else is ever read into the payload.
2. **Mechanism: self-owned.** No third-party plugin. The command shells out
   to the Codex CLI (`codex exec` non-interactive mode) with the spec file
   content and a fixed review prompt. `codex-plugin-cc` is not adopted.
3. **Disagreement handling: logged note.** Codex output is appended to the
   spec under a `## Codex second opinion (advisory)` heading, date-stamped.
   No disposition ceremony; the human approves or iterates as usual. Codex
   has no veto.
4. **No ExitPlanMode hook.** The spec gate is the only mechanism. Plan-mode
   sessions outside the DCOE spec flow get no Codex opinion.

## Command behaviour

`/codex-review docs/specs/<feature>.md`

1. **Path guard.** Refuse (with a clear message, exit success) if the
   argument is not a single existing `.md` file under `docs/specs/`.
   Never accept directories, globs, or additional files.
2. **Payload.** The spec file's raw content plus a fixed instruction:
   review for buried assumptions, missing/unstated acceptance criteria,
   unconsidered failure modes, and architectural alternatives a different
   model family would raise. No CLAUDE.md, no `@imports`, no diffs, no
   other files, ever.
3. **Frontmatter strip.** If the spec carries YAML frontmatter, strip it
   before sending (provenance fields per the hub note convention).
4. **Fail-warn (mandatory, hard rule #11).** Any failure — CLI missing, no
   credentials, network down, rate limit, non-zero exit, or the **90 s hard
   timeout (no retry)** — prints `Codex second opinion unavailable
   (<reason>) — proceeding solo` and exits successfully. The gate can never
   block spec approval, commit, or push.
5. **Output.** On success, append to the spec file:
   `## Codex second opinion (advisory) — <date>` followed by the response,
   and a closing line `_Advisory only — reviewer agent retains sole
   APPROVE/BLOCK authority._`
6. **Logging.** Append one line to `docs/session-log.md` (if present):
   `<date> codex-review <file>: ran | warned (<reason>)`.

## Packaging & rollout

- New marketplace plugin **`codex-gate`** (own folder, own `plugin.json`),
  carrying only `commands/codex-review.md`. It is **not** added to
  `dcoe-roster` — the roster auto-deploys user-scope to both machines,
  and this plugin must be installable per machine.
- **Install on Pappa T only** until Fan Movement IT confirms OpenAI egress
  from the Operations machine (open blocker; Anthropic-specific clearance
  does not cover it).
- **Credentials: user scope, per machine.** Codex CLI's own auth store
  (`~/.codex/`). No API key in any `.env`, any repo file, or any plugin
  content.

## Config file changes

- **`CLAUDE.md.template` v3.2 → v3.3:**
  - Pattern 1 step 2: `Review spec → /codex-review (advisory, warn-only,
    if installed) → approve or iterate`.
  - HOOKS philosophy paragraph, one added sentence: *Only deterministic
    local gates (lint, format, tests) may block; network-dependent advisory
    gates warn and proceed.*
  - HOOKS table row: trigger "spec approval", action "Codex cross-family
    second opinion — warn only, never block (optional, per machine)".
  - SECURITY & PERMISSIONS: one bullet — external-model payloads are
    default-deny; only single spec files under `docs/specs/` may be sent,
    and only where the codex-gate plugin is deliberately installed.
  - Version bump + changelog line at the bottom, matching v3.2 precedent.
- **`CORE.md`:** no change (stays universal; the gate is per-machine
  opt-in). At most a future one-line routing note once both machines are
  cleared — out of scope here.
- **`.claude-plugin/marketplace.json`:** add the `codex-gate` entry.
  Validate with `python -m json.tool` before commit.
- **ADR:** record the decision in the Operations hub's `docs/decisions/`
  (vault-side task, done at the vault, not in this repo).

## Acceptance criteria

1. `/codex-review docs/specs/x.md` on Pappa T appends an advisory section
   to that file and touches nothing else.
2. Any path outside `docs/specs/`, or more than one file, is refused with
   a clear message and zero payload sent.
3. With the network down (or CLI/credentials absent), the command warns and
   exits successfully in ≤ 90 s — nothing blocks.
4. No file in this repo contains an OpenAI credential in any form.
5. JSON validation passes on `marketplace.json` and the new `plugin.json`.
6. Operations machine: plugin not installed; nothing else in the rollout
   depends on it.

## Out of scope (phase 1)

- Sub-project payloads / allow-lists of any kind.
- Diff or code review by Codex (reviewer agent keeps that exclusively).
- ExitPlanMode or any hook-based invocation.
- Operations-machine install (blocked on IT clearance).
