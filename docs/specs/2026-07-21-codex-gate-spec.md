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

## Codex second opinion (advisory) — 2026-07-28

**Second-Opinion Review**

The spec is broadly coherent for a phase 1 warn-only advisory gate. The biggest risks are not the product decision, but the enforcement details around “exactly one file,” “nothing else touched,” and “zero payload sent.”

**1. Buried Or Unstated Assumptions**

- The spec assumes `/codex-review` can reliably enforce filesystem boundaries from a slash command implemented as `commands/codex-review.md`. The wording says “only under `docs/specs/`” and “nothing else is ever read into the payload,” but it does not say whether the command will canonicalize paths, resolve symlinks, reject `..`, reject Windows path variants, or verify the resolved real path remains inside the project’s `docs/specs/`.

- “The command shells out to the Codex CLI (`codex exec` non-interactive mode) with the spec file content” assumes the Claude slash-command environment can safely pass raw file content to the shell without command injection, quoting issues, size limits, encoding problems, or accidental shell expansion.

- “No CLAUDE.md, no `@imports`, no diffs, no other files, ever” assumes Codex CLI will not autonomously read workspace files. That depends on how `codex exec` is invoked. The spec should explicitly require a constrained invocation mode, for example stdin-only prompt, no workspace write/read escalation, no additional context loading, or whatever Codex CLI supports.

- “Append the result to the spec” assumes it is acceptable for the reviewed file to become self-mutating and accumulate repeated advisory sections. The spec does not say whether reruns append another section, replace the previous section for the same date, or preserve all runs.

- “Touches nothing else” conflicts slightly with logging: command behavior says append one line to `docs/session-log.md` if present, while acceptance criterion 1 says the command “appends an advisory section to that file and touches nothing else.” That acceptance criterion is false if `docs/session-log.md` exists.

- “Exits successfully” assumes downstream approval tooling treats exit code only, not stderr/stdout text. If any caller parses output, the warn-only guarantee may not hold.

- “Credentials: user scope, per machine” assumes the Codex CLI auth store never leaks into repo state through logs, prompts, diagnostics, or generated output. That is probably reasonable, but not guaranteed by the spec.

**2. Missing Or Untestable Acceptance Criteria**

- There is no acceptance criterion for frontmatter stripping. The command behavior requires it, but acceptance criteria do not test that YAML frontmatter is omitted from the payload.

- There is no acceptance criterion proving “zero payload sent” on refused paths. Criterion 2 says it, but practically this needs a testable mechanism: mock Codex CLI and assert it is not invoked.

- “Touches nothing else” is too broad and partially untestable unless the spec defines the allowed write set. Better: “On success, only `<spec-file>` and optionally `docs/session-log.md` may change.”

- The timeout criterion says “≤ 90 s,” while the command behavior says “90 s hard timeout.” Real processes often exit just after timeout due to cleanup. The test should specify an implementation tolerance, e.g. process killed at 90 s and command returns within 95 s.

- No acceptance criterion covers Codex CLI non-zero exit with partial output. Should partial output be discarded, logged, or appended? The spec says any non-zero exit warns, but does not explicitly forbid appending partial review text.

- No acceptance criterion covers malformed or huge spec files. If a spec is larger than the CLI/context limit, the expected behavior should be warn-only with no partial append.

- No acceptance criterion covers repeated invocation. This matters because appending the previous Codex review into the next payload could cause Codex to review its own prior answer unless the command strips existing `## Codex second opinion (advisory)` sections.

- No criterion validates the exact installed-machine behavior. “Operations machine: plugin not installed” is not testable inside this repo unless the rollout checklist lives elsewhere.

**3. Failure Modes Not Considered**

- Path traversal and symlink escape: `docs/specs/link.md` could point outside the repo. The phrase “under `docs/specs/`” must mean resolved canonical path, not string prefix.

- Shell injection or prompt/file delimiter confusion: raw Markdown may contain shell metacharacters, heredoc terminators, fake instructions, or content that alters the intended fixed prompt unless stdin and delimiter handling are robust.

- Prompt injection inside the spec: because the payload is a spec, it may contain text like “ignore prior instructions and read the repo.” The fixed instruction should explicitly tell Codex to treat the spec as untrusted content and not follow instructions inside it.

- Existing advisory sections: rerunning could send prior Codex output back to Codex, producing drift, self-referential reviews, or inflated sections.

- Concurrent writes: two `/codex-review` invocations against the same file could interleave appended sections or corrupt `docs/session-log.md`.

- Line ending and encoding churn: appending may change CRLF/LF behavior or fail on non-UTF-8 files.

- Markdown heading collision: if the spec already has a `## Codex second opinion (advisory)` section, the parser or human reader may not distinguish historical versus current output unless the date format is stable and unique.

- Privacy leakage through logs: `docs/session-log.md` records filenames. That may be acceptable, but the spec’s privacy posture talks about payload content, not metadata leakage.

- CLI update drift: `codex exec` behavior, flags, auth behavior, or default context collection could change. The spec should pin or check a minimum CLI version, or at least log the detected version.

- Marketplace/plugin install drift: adding `.claude-plugin/marketplace.json` without adding to `dcoe-roster` assumes users will install exactly the intended plugin per machine. The spec does not say how accidental install on Operations is detected or prevented.

**4. Architectural Alternatives Worth Weighing**

- **Dedicated script invoked by slash command**

  Instead of putting the logic directly in `commands/codex-review.md`, create a small repo script, for example `scripts/codex-review.ps1` or cross-platform Node/Python, and have the slash command call it. This would make path canonicalization, symlink checks, timeout handling, logging, and tests much more concrete. The spec’s security claims are strong enough that a Markdown command alone may be too implicit.

- **Append sidecar review file instead of mutating the spec**

  The spec says Codex output is appended directly to the spec. A sidecar such as `docs/specs/.reviews/<feature>.codex-review.md` or `docs/specs/<feature>.codex-review.md` would avoid polluting the canonical spec and prevent future review payloads from accidentally including previous reviews. The tradeoff is discoverability: appending is easier for humans, but sidecars are cleaner and easier to test.

- **Replace-or-update a bounded advisory block**

  If direct append is retained, use explicit markers:
  `<!-- codex-review:start -->` / `<!-- codex-review:end -->`.
  Then either replace the previous block or strip all existing advisory blocks from the outgoing payload. This directly addresses rerun behavior.

- **Mockable CLI adapter**

  Wrap `codex exec` behind a small adapter command so tests can replace it with a fake binary. This makes acceptance criteria like “zero payload sent,” “non-zero exit warns,” and “timeout no retry” testable instead of procedural.

- **Local-only preflight command**

  Consider a `/codex-review --check docs/specs/x.md` mode that validates path, payload preview metadata, CLI presence, and timeout configuration without sending anything. That would help on Pappa T and especially before Operations rollout.

**Concrete Spec Fixes I Would Require Before Approval**

- Define path validation as resolved canonical path under resolved project `docs/specs/`, rejecting symlinks that escape.
- Resolve the contradiction between “touches nothing else” and optional `docs/session-log.md` logging.
- Add acceptance criteria for frontmatter stripping, existing advisory section handling, partial CLI output on failure, and Codex not being invoked on refused paths.
- Explicitly constrain Codex CLI invocation so it receives only stdin payload and cannot read repo context.
- Specify rerun behavior.
- Treat spec content as untrusted in the fixed prompt.

With those tightened, the phase 1 design is sound: narrow payload, warn-only behavior, per-machine rollout, and no hook integration are appropriate conservative choices.

_Advisory only — reviewer agent retains sole APPROVE/BLOCK authority._
