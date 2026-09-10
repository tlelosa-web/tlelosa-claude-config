# Spec — Opt-in `--fail-on-drift` flag for bootstrap.mjs

**Date:** 2026-09-10
**Status:** Reviewed 2026-09-10 — **BLOCK cleared by revision.** All three Hard Rule 9 tiers logged below. Ready for Execute.
**Owner:** Tebello Lelosa
**Type:** Structural — touches `agent-bodies-reference/bootstrap.mjs`, bumps the
core version in `dcoe-roster/CORE.md`, and touches files that cite that
version. Full DCOE per repo-specific hard rule 5.

## Prior learnings retrieved

This repo has no `shared-memory/learnings/INDEX.md` and no
`knowledge/RETRIEVAL-INDEX.md` (confirmed by directory listing this session)
— there is no index in this project to retrieve prior learnings from, so
none were retrieved or applied. Explicitly noted rather than omitted, per
this spec's own writing instructions.

## Problem — stated precisely

`bootstrap.mjs`'s missing-only default already detects divergence
(`syncRoster()` populates `result.diverged`) and already reports it via
`say()` in both default and `--check` mode. This is correct and must not
change: per `CORE.md` (~L108-116) and
`docs/specs/2026-07-29-strip-dcoe-roster-agent-bodies.md`, a locally edited
agent body is a **legitimate, intentional per-machine tweak**, never
silently reverted.

The gap is that divergence and "intentional per-machine tweak" and
"someone edited the deployed copy and forgot to push it upstream" are
currently indistinguishable by anything scriptable — only by a human
reading the `say()` line. That happened for real on 2026-09-10:
`~/.claude/agents/domain.md` and `planner.md` had diverged from
`agent-bodies-reference/`, caught only because a human noticed, then
reconciled via PR #32 (merged). There is currently no way to ask "has
anything drifted?" and get a non-zero exit for a script, pre-push check, or
audit to act on.

**This spec adds only the capability to ask that question on demand.** It
does not add a gate, hook, or CI step that calls the new flag — that is a
separate, future decision. It is also **not a fix to `--check`**: `--check`'s
documented contract ("exit 1 if anything is missing") already matches its
behaviour and stays exactly as it is for anyone who does not pass the new
flag.

## Design

Add a new argv flag, `--fail-on-drift`, parsed alongside the existing
`--repair` / `--check` / `--quiet` flags. Chosen name over alternatives:
`--strict` (too vague — strict about what?) and `--check-drift` (implies a
new mode, when this is a modifier of existing modes, not a fourth mode).
`--fail-on-drift` states exactly and only what it changes: the exit code
when `result.diverged` is non-empty.

Behaviour:

- **Opt-in only.** Absent the flag, output and exit code are byte-for-byte
  unchanged in every mode — this is the hard constraint the rest of the
  design serves.
- **Orthogonal to `MODE`, not a new mode.** It composes with default
  (missing-only) and `--check`. In both, if `roster.diverged.length > 0`
  after `syncRoster()` runs, call the existing `fail()` helper (which both
  prints via the existing `TAG:` line and sets `process.exitCode = 1`) in
  addition to the existing `say()` reporting — reporting text is unchanged,
  only the exit code gains a new input.
- **Vacuous with `--repair`.** `--repair` mode never leaves a diverged file
  by construction (every present file is overwritten in that branch of
  `syncRoster()`, so `result.diverged` stays empty for the duration of that
  run). `--fail-on-drift --repair` together will therefore always exit 0 —
  this is documented as intentional, not silently inconsistent: repair's job
  is to eliminate drift, so asking "did anything stay drift after a repair"
  correctly reports nothing.
- **Does not change what counts as "missing."** `--check`'s existing
  "exit 1 if anything is missing" behaviour (via `roster.copied.length`) is
  untouched and independent — a run can exit 1 for missing files, for
  drifted files, for both, or neither.
- **No new write path.** The flag only ever influences `process.exitCode`;
  it never causes a copy, revert, or settings.json touch that wasn't already
  going to happen for that `MODE`. This keeps "never corrupt settings.json"
  and "loud on failure, silent on success" intact — steady state (no drift,
  no missing files) is still silent and exits 0.
- **`--quiet` suppresses text, never exit status.** This is load-bearing and
  must be implemented deliberately, not inherited. Today `QUIET` gates
  exactly one thing — the default-mode drift report at
  `if (roster.diverged.length && !QUIET)`. New exit-code logic placed inside
  that guard (the obvious spot, since it is where divergence is already
  handled in default mode) would become **switchable off by a verbosity
  flag**: `--fail-on-drift --quiet` would exit 0 with drift present. That
  directly violates the file's own design rule, "Loud on failure. Silence
  means success; it must never mean 'never ran'." The exit-code decision
  must therefore be evaluated **outside** the `!QUIET` guard, reading
  `roster.diverged.length` directly. `--quiet` may suppress the `locally
  edited…` line; it must never change the exit code. (Blast radius if this
  is got wrong is hand-run and scripted use only — neither
  `dcoe-roster/hooks/hooks.json` nor
  `hub-template/hooks/cloud-roster-bootstrap.sh` passes `--quiet`; both
  invoke `bootstrap.mjs` with no flags. Verified 2026-09-10.)

## Acceptance criteria

Run from `agent-bodies-reference/` (or with the path adjusted). All exit
codes are `process.exitCode` as observed via `echo $?` / `$LASTEXITCODE`
immediately after the command.

1. **No drift, no flag:** `node bootstrap.mjs --check` → exit `0`.
2. **No drift, with flag:** `node bootstrap.mjs --check --fail-on-drift` →
   exit `0`.
3. **Drift present (a file in `~/.claude/agents/` edited to differ from its
   `agent-bodies-reference/` source, still present), no flag:**
   `node bootstrap.mjs --check` → exit `0` (unchanged from today —
   `--check`'s contract is "exit 1 if missing," not "if diverged").
4. **Drift present, with flag, `--check`:**
   `node bootstrap.mjs --check --fail-on-drift` → exit `1`, and the printed
   `locally edited: <file>` line is unchanged text, still present.
5. **Drift present, with flag, default mode (no `--check`):**
   `node bootstrap.mjs --fail-on-drift` → exit `1`. The diverged file is
   still left untouched on disk (missing-only semantics unaffected).
6. **Drift present, with flag, `--repair`:**
   `node bootstrap.mjs --repair --fail-on-drift` → exit `0` (repair
   overwrote the diverged file before the drift check would have anything to
   report — see "Vacuous with `--repair`" above).
7. **Missing file present, flag on, no drift:**
   `node bootstrap.mjs --check --fail-on-drift` → exit `1`, from the
   pre-existing missing-file path. *Narrow claim only:* this shows the flag
   does not suppress an existing failure. It does **not** demonstrate the
   two failure paths are independent — same command and same expected exit
   code as criterion 4, and exit status is one bit, so it cannot distinguish
   the two causes. Criterion 7b is what actually tests that.
7b. **Both conditions simultaneously — the real non-masking test.** Fixture
   requires **two different files**: one roster agent absent from
   `~/.claude/agents/`, and a *different* one present but edited to differ
   from its reference. (One file cannot be both: in `syncRoster()` an absent
   destination hits the copy branch and `continue`s before the divergence
   comparison is ever reached.) Then
   `node bootstrap.mjs --check --fail-on-drift` → exit `1`, **and both output
   lines must be present** — the `missing N/M: <file>` line and the
   `locally edited: <other-file>` line, each naming its own file. Asserting
   on the two distinct lines, not the exit code, is what proves neither path
   masks the other.
8. **`--quiet` does not silence the failure.** With drift present:
   `node bootstrap.mjs --fail-on-drift --quiet` → exit `1`. The
   `locally edited…` line may legitimately be absent (that is what `--quiet`
   is for); the exit code must not be. A run that exits 0 here means the
   exit-code logic was placed inside the `!QUIET` guard and the
   implementation is wrong regardless of what every other criterion says.
9. Running any command above twice in a row with no state change between
   runs produces the same exit code both times (idempotence — no
   flag-related side effect accumulates).

## Tasks

Each task below touches at most 2 files, per this repo's "HOW DCOE APPLIES
HERE."

1. **Implement `--fail-on-drift` in `bootstrap.mjs`.**
   File: `agent-bodies-reference/bootstrap.mjs`. Parse the new flag, apply it
   in the `MODE === "check"` block and in the default-mode notes block per
   the Design section above. Update the file's own docstring "Modes:" block
   to document the flag without altering the existing `--check` line's
   wording (it stays accurate as-is).
2. **Core version bump — all three files, ONE commit.** Files:
   `dcoe-roster/CORE.md`, `agent-bodies-reference/roster-manifest.json`,
   `dcoe-roster/plugin.json`.
   - `CORE.md`: header `**Core version: 1.10**` → `1.11`; in the
     roster-deployment paragraph (~L108-116) that already names `--repair`
     and `--check`, add one clause naming `--fail-on-drift` as opt-in,
     non-default. No behavioural claim beyond what task 1 implements.
   - `roster-manifest.json`: `"coreVersion": "1.10"` → `"1.11"`.
   - `plugin.json`: description's `v1.10` → `v1.11`; plugin semver
     `3.11.0` → `3.12.0` (minor — new opt-in capability, nothing breaking).

   **This task deliberately exceeds the repo's "at most 2 files per task"
   rule, and the exemption is the point.** Precedent is explicit in
   `docs/specs/2026-08-08-model-routing.md` ("Commit boundaries"): *"a core
   version bump is a single distribution event… The three files describe one
   decision and splitting them would ship a template referencing a CORE
   version that does not exist yet."* Splitting this manufactures a stale
   intermediate state — and `roster-manifest.json`'s `coreVersion` going
   stale is a **recorded, repeated** failure here, caught at 1.4 and again
   at 1.6 in separate incidents. Before committing, grep for any *fourth*
   live citation site rather than trusting this list; historical prose in
   `docs/specs/` and `docs/todo.md` must **not** be rewritten.
3. **Document the flag in `README.md`.** File: `README.md` (repo root).
   Add a fourth line to the existing hand-run usage block (~L129-132)
   alongside the documented `--check` / `--repair` lines:
   `node agent-bodies-reference/bootstrap.mjs --fail-on-drift   # combine with --check; non-zero exit if anything has diverged`.

## Dependency ordering

**1 → 2 → 3.** Task 1 (implementation) lands first; tasks 2 and 3 describe a
flag and must not be committed while it does not yet exist in `main()`.
Task 3 (README) last — the usage line is where a reader checks the feature
actually landed, so it should reflect the final flag name and version.

Three tasks, three commits. Task 2 is one commit across three files by
deliberate exemption (see its note). `docs/todo.md` updated after each
lands, per hard rule 5.

## Review tiers used (Hard Rule 9)

First spec in this ecosystem to exercise all three tiers in one pass.

- **Tier 1 — `/codex-review`: unavailable, root-caused, not merely absent.**
  Four live attempts 2026-09-10 (08:27, 09:28, 09:57 SAST, and again after
  updating the CLI 0.145.0 → 0.154.0). The ChatGPT account is on the **Free
  plan** with no `gpt-5.5` entitlement; a dozen alternate model ids all
  returned "not supported when using Codex with a ChatGPT account". This is
  a **plan limitation, not a quota window** — it will not clear by waiting,
  and the previously recorded "Codex available after 2026-09-10" date was
  wrong at origin. Not re-attempted a fifth time here, deliberately.
- **Tier 2 — `scripts/qwen-review.sh`: ran to completion, output discarded.**
  First time this tier has ever been reachable: it is measured to time out
  past ~1,850 words, and the spec was ~1,300 **at the time it was reviewed**.
  Note for anyone re-running it: the post-review revision below took the file
  to ~2,300 words, back over the threshold, so this tier is **no longer
  reachable for this spec** — the reachability was a property of the draft,
  not of the document you are now reading. Its output nonetheless
  reproduced the exact failure mode recorded 2026-08-31 — **three of its four
  findings asserted the spec omits things it explicitly contains** (claimed
  no acceptance criteria test the flag, when eight numbered ones with exact
  commands and exit codes were present; claimed the spec never states the
  flag leaves `--check` unchanged, when it says "byte-for-byte unchanged in
  every mode"). Its proposed alternative — make `--check` itself fail on
  divergence — is precisely what this design rules out, and it contradicted
  itself by proposing that while claiming to preserve the contract. **Zero
  decision weight, correctly rated;** logged as run, not as input. (Script
  invoked from the sibling `ai-product-factory` hub — this repo has not
  opted in to a local copy.)
- **Tier 3 — `reviewer` agent: BLOCK, now cleared by revision.** Verdict was
  BLOCK on one finding, with two more to fix in the same pass. The design
  itself was upheld — the reviewer independently verified the `--repair`
  vacuity claim against `syncRoster()`'s control flow and confirmed the
  three-file version-citation set was complete.

### What the BLOCK was, and what changed

1. **BLOCKER — `--quiet` interaction unspecified.** The spec directed the
   Executor at the default-mode notes block without noting that `QUIET`
   already guards it, so a conformant implementation could have shipped a
   drift detector silenceable by a verbosity flag. Fixed: *Design* now
   requires the exit-code decision live outside the `!QUIET` guard, and
   **criterion 8** tests `--quiet` explicitly.
2. **Version bump was split across three tasks.** Fixed: merged into a single
   task/commit on the explicit `docs/specs/2026-08-08-model-routing.md`
   precedent, with the ≤2-file exemption stated rather than silently taken.
3. **Criterion 7 restated a property it could not test** — same command and
   expected exit code as criterion 4, differing only in fixture, while
   claiming to prove non-masking. Fixed: 7 narrowed to its honest claim, new
   **7b** uses a genuine two-file fixture and asserts on both output lines.
4. Stale machine-name strings named in *Explicitly out of scope* rather than
   left unmentioned.

## Explicitly out of scope

- Any hook, CI step, or pre-push check that actually *calls*
  `--fail-on-drift`. This spec adds the capability only.
- Any change to `--check`'s existing "exit 1 if missing" contract — it is
  correct today and is not being touched.
- Any change to missing-only semantics, `--repair`'s overwrite behaviour, or
  `ensurePlugins()` — none of the "Design rules this file must keep" are
  being revisited.
- Retroactive tooling for the 2026-09-10 `domain.md`/`planner.md` incident
  itself — already reconciled via PR #32; this spec only prevents silent
  recurrence going forward, scriptably.
- **The retired machine names still living in live, present-tense strings —
  deferred deliberately, not missed.** Task 2 edits `plugin.json`'s
  description line, which currently claims the hook deploys bootstrap "on
  Operations/Pappa T"; both machines were retired 2026-08-20 (hub is the
  folder, not a machine). Two further live sites exist in
  `dcoe-roster/CORE.md` — "only fires on a machine that has actually
  installed the marketplace — Operations and Pappa T" and "no-ops on
  Operations/Pappa T" (verify line numbers before editing; they drift).
  **The Executor doing task 2 must leave these strings alone** and change
  only the version substring, even though the false clause sits on the same
  line. Three sites across two files with their own verification surface is
  its own task, and bundling it here would mix a capability change with a
  records correction. Queued separately in `docs/todo.md`. Note the
  distinction: historical narrative naming those machines (`CORE.md`'s
  ADR-007 reference, the 2026-08-09 incident entry, and all `docs/specs/`
  prose) is **correct as history and must not be rewritten** — only
  present-tense claims about current deployment surfaces are wrong.
