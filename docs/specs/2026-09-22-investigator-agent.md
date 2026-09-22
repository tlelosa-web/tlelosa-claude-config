# Spec: add an `investigator` agent to the shared DCOE roster

**Date:** 2026-09-22
**Status:** APPROVE WITH CHANGES (`reviewer`, 2026-09-22, pass 3) — the two
flagged text fixes (disambiguating `roster-manifest.json`'s "both manifest
fields" to `coreVersion` only, and collapsing the `investigator` row's
position to one consistent place — last, after `Explore`/`data-agent` — in
CORE.md, the manifest, `CLAUDE.md.template`, and `README.md`) are applied
below. Ready for Executor dispatch.
**Origin:** Owner request, scoped in the `ai-product-factory` session recorded at
`docs/session-logs/2026-09-22-investigator-agent-scoping-and-roster-mirror-removal.md`
(that hub's own history — cited here as the scope record, not as a file this
spec touches). Confirmed scope: retrospective root-cause analysis of project
delays/blockers, read-only/report-only, no standing model pin.

## Revision log

**2026-09-22, post-BLOCK-#1 revision.** The `reviewer` agent BLOCKed the first
draft on four defects and five warnings. All are addressed below; each
blocker/warning section cites the live file and line numbers verified
directly (per Hard Rule 12 — no paraphrase of the reviewer's report was
treated as fact without re-reading the source).

**2026-09-22, post-BLOCK-#2 revision (this one).** The `reviewer` BLOCKed the
revised draft on two further blockers plus warnings. All are fixed here, and
every line citation below was re-opened and re-read against the live files in
this revision — including the citations that BLOCK #1's revision had already
written, two of which turned out to be wrong (see "Corrected citations" below).
Summary of what changed:

- **New task 9 / AC9: `README.md`.** The prior two drafts omitted this file
  entirely. `README.md:115` currently reads `Verify with /agents — all ten show
  up unprefixed...` — true today at 10 agents, and made **false by this spec**.
  That is a spec-caused defect, not pre-existing drift, so it is squarely in
  scope. `README.md:15–17`'s "The 9 roster agent bodies (...)" list is
  pre-existing drift of the same class task 6 already fixes in
  `CLAUDE.md.template`, and is fixed in the same task for the same reason.
- **New AC8 for task 8.** Task 8's `EXPECTED_COUNT=10 → 11` edit previously had
  no acceptance criterion at all — nothing verified the fix to BLOCK #1's
  silent-cloud-session-gap defect actually landed.
- **Corrected citations.** `bootstrap.sh`'s count-bearing lines are **2, 7, 12,
  13**, not 2, 8, 12, 14 as the prior draft claimed (verified by reading the
  file in this revision: lines 8 and 14 are unrelated continuation/comment
  text). This repo's own `CLAUDE.md` carries the roster count in **two
  non-adjacent places**, `CLAUDE.md:24–27` and `CLAUDE.md:59`, not only the
  24–27 block the prior draft cited.
- **AC6's conditional branch collapsed.** AC6 previously stated a default
  behavior *and* a fallback behavior conditional on an owner judgment call. An
  acceptance criterion must describe one evaluable behavior. AC6 and task 6 now
  state only the chosen behavior (fix the template drift now); the rejected
  alternative moved to Out of Scope as a "Considered and rejected" note.
- **Two more follow-up findings filed** (not fixed): `marketplace.json:11` and
  `agent-bodies-reference/debugger.md:4`. See task 10.

## Prior learnings retrieved

This clone (`~/orca/tlelosa-claude-config`, canonical `tlelosa-claude-config`)
has no `shared-memory/learnings/INDEX.md` and no `knowledge/RETRIEVAL-INDEX.md`
— confirmed by directory listing, not assumed: this repo is a config/marketplace
repo with `docs/specs/` and `docs/research/` but no `shared-memory/` or
`knowledge/` tree at all. **No prior-learnings index exists here, so none
apply.** Checked and rejected as not relevant: the `ai-product-factory` hub's
own `knowledge/` and `shared-memory/learnings/` trees — those belong to a
different repo (the hub that *uses* this roster, not the roster's own source
repo) and are out of this spec's read scope; nothing about them would change
an agent-body edit made here. The prior debugger-agent spec
(`docs/specs/2026-07-21-debugger-systematic-debugging.md`) is not a "learning"
in the retrieval-index sense but is used directly below as the closest
precedent for shape and format, since it is the last time this roster added
methodology to an investigation-flavoured agent. Also directly consulted in
this revision (not a "learning" either, but load-bearing precedent):
`docs/specs/2026-08-12-done-sha-citation.md` (governs task 10's wording below)
and `docs/todo.md`'s 2026-08-20 Done entry (the three-way version-mismatch
precedent AC3 now explicitly extends to `plugin.json`).

## Goal

Add an eleventh agent, `investigator`, to the DCOE roster: a read-only,
report-only agent that performs retrospective root-cause analysis of
**project-level delays and blockers** (a spec cycling through review multiple
times, a `docs/todo.md` item open far longer than comparable items, a
recurring slippage pattern across sessions) — as distinct from `debugger`,
which does root-cause analysis of **code defects** and hands off a failing
test. `investigator` never proposes or implements a fix; it hands findings to
whichever agent owns the fix (`planner` for a process/spec change, `architect`
for a structural one, the owner directly for a judgment call).

## Why a new agent rather than extending `debugger`

`debugger`'s whole shape (Iron Law, four phases, failing-test handoff) is
built around code: reproduce, isolate in source, hand off a red test. A
project-delay question ("why did this spec take three review cycles", "why
has this todo item sat open six weeks") has no reproduction step and no test
to hand off — its evidence is dated documents (`docs/todo.md`, session logs,
specs, `docs/retro-log.md`, git history), not a stack trace. Folding this into
`debugger` would either dilute its code-focused Iron Law or force a
process-analysis question through a "reproduce the bug" frame that doesn't
fit. A dedicated agent keeps both roles legible: `debugger` stays code-only,
`investigator` is process/timeline-only, and the two hand off to each other
by name when a question turns out to be the other one's remit (see the agent
body text in the Appendix, "Boundary with `debugger`").

## Acceptance criteria

1. `agent-bodies-reference/investigator.md` exists, follows the existing
   agent-body frontmatter convention (`name`, `description`, `tools`, `model`,
   `memory`), and its tool grant is `Read, Grep, Glob, Bash, Write`. **On
   "read-only": do not claim the tool grant itself is technically read-only —
   `Bash` is a strictly stronger grant than read-only and is not mechanically
   constrained to git-inspection commands.** `debugger.md` (verified in this
   revision: `debugger.md:4` reads `tools: Read, Grep, Glob, Bash`) already
   carries `Bash` and never describes itself as "read-only" in prose anywhere —
   it states the behavioral constraint only ("never patch the symptom", "you
   implement nothing"). `investigator.md` follows the same pattern: it does not
   claim to be read-only; it states, as a Hard Rule in its own body, that its
   only write is the one report file (`docs/investigations/<slug>.md`, via the
   `Write` tool scoped to that one path in prose — same pattern `planner` uses
   for `docs/specs/`). This is a prose/instruction boundary, not a tool-level
   one, same as every other roster agent that carries `Bash`. The file also
   carries no standing model pin (meaning: `model: claude-sonnet-5` is set
   explicitly, the same default every non-pinned role gets — not omitted;
   omitting `model` would not match this repo's frontmatter convention and "no
   standing pin" refers to the absence of a `standingPin: true` manifest flag,
   not the absence of a `model` value), medium effort per CORE.md's escalation
   rules, and states explicitly that it implements nothing and proposes no code
   fix. The landed body must match this spec's Appendix text verbatim.
2. `agent-bodies-reference/roster-manifest.json` lists `investigator.md` with
   `model: claude-sonnet-5`, `effort: medium`, and a one-line role string
   consistent with the table added to `CORE.md`. (Verified precondition: the
   `agents[]` array currently holds exactly 10 entries, `roster-manifest.json:6–15`.)
3. **Three-way version agreement, matching this repo's own 2026-08-20
   precedent exactly.** `dcoe-roster/CORE.md`'s roster table includes an
   `investigator` row. `CORE.md`'s Core version number at the top (currently
   `1.12`, `CORE.md:3`), `agent-bodies-reference/roster-manifest.json`'s
   `coreVersion` field (verified `"1.12"`, `roster-manifest.json:4`), **and**
   `dcoe-roster/plugin.json`'s own `version` field and embedded
   version strings in its `description` (verified `"3.12.1"` at
   `plugin.json:3` and `"DCOE shared core (CORE.md, v1.12) ... matching
   CLAUDE.md v3.6"` at `plugin.json:4`) must all move together and agree
   exactly: `CORE.md` → `1.13`, `roster-manifest.json`'s `coreVersion` field
   (and only that field — `manifestVersion: 1` is the manifest schema
   version, unrelated to the Core version, and must not change) → `1.13`,
   `plugin.json.version` → `3.13.0` (per this repo's own
   bump convention: verified against `docs/todo.md`'s 2026-08-20 Done entry,
   which recorded `plugin.json`'s version moving `3.8.1 → 3.9.0` in the same
   commit that moved `CORE.md`/manifest `1.7 → 1.8` — i.e. a `coreVersion`
   bump always carries `plugin.json`'s minor version forward with patch
   reset to `0`), and `plugin.json`'s `description` embedded strings updated
   to `"CORE.md, v1.13"` and `"matching CLAUDE.md v3.7"` (the new
   `CLAUDE.md.template` version — see task 6). This exact three-way mismatch
   (`roster-manifest.json`/`plugin.json` stuck at `1.6` against `CORE.md`'s
   `1.7`, "open since `fe88c2b`, never caught") is the incident
   `docs/todo.md`'s 2026-08-20 Done entry records.
4. `agent-bodies-reference/bootstrap.sh` copies `investigator.md` (added to
   the `AGENTS` array) and **every** numeric agent-count mention in that
   file's header comments — verified in this revision as four separate lines,
   at **lines 2, 7, 12 and 13** — is updated to `11`:
   - line 2: `# bootstrap.sh — copy the 10 DCOE roster agent bodies into ~/.claude/agents/` → `11`
   - line 7: `# a manual "copy these 9 files" step. This script is that manual step turned` → `11`
     (already stale before this change, since the `AGENTS` array at
     `bootstrap.sh:27–38` already holds 10 entries; corrected to 11 as part of
     this same edit rather than left compounding)
   - line 12: `#   - Copies each of the 10 named files from this script's own directory into` → `11`
   - line 13: `#     ~/.claude/agents/, only touching those 9 filenames — nothing else in` → `11`
     (also already stale, same reason as line 7)

   **Correction to the prior draft:** it cited lines 2, 8, 12 and 14. Verified
   here by direct read: line 8 is `# into a real, idempotent, safe-to-rerun
   script.` and line 14 is `#     that directory is read, moved, or removed.` —
   neither carries a count. The correct lines are 2, 7, 12, 13.

   The script's own runtime count report (`bootstrap.sh:61`,
   `echo "bootstrap.sh: ${#AGENTS[@]} roster agents present in $DEST_DIR"`)
   is computed from the array length and needs no manual edit — confirmed by
   reading the line: it will read `11` automatically once the array holds 11
   entries.
5. This repo's own `CLAUDE.md` (which carries the roster count in **two
   non-adjacent places** — verified in this revision; the prior draft cited
   only the first) is updated in both:
   - **`CLAUDE.md:24–27`** (SESSION START check) — line 24 reads `Also check
     whether \`~/.claude/agents/\` (user-level only) contains all 10` and lines
     25–27 list the 10 expected roster filenames ending `\`tester.md\``. The
     count becomes 11 and `investigator.md` is added to the filename list (in
     the list's existing alphabetical order, i.e. between `executor.md`/
     `explore.md` and `planner.md`).
   - **`CLAUDE.md:59`** (PROJECT OVERVIEW) — reads
     `- \`agent-bodies-reference/\` — the 10 roster agent bodies, the copy-source`.
     The count becomes 11.

   This is one file with two separate, non-adjacent edits — both must land for
   task 5 to be done; editing 24–27 alone leaves `:59` newly false.
6. `CLAUDE.md.template` (the master template other projects copy from) gets
   an `investigator` row in its own roster table (verified table location:
   `CLAUDE.md.template:129–140`, a 10-row table whose last row is `Explore`),
   **and** the following pre-existing drift in the same file is fixed in the
   same task:
   - The version line at `CLAUDE.md.template:5` (`# Version: 3.6 | Owner:
     Tebello Lelosa | Stack: see PROJECT OVERVIEW`) moves to `3.7`, and a new
     changelog entry is added after the existing `*v3.5 change: ...*` block
     (verified at `CLAUDE.md.template:528–534`), immediately before the
     `*Last review: August 2026 — Tebello Lelosa*` line (verified at
     `CLAUDE.md.template:536`), reading
     `*v3.7 change: added the \`investigator\` row to the sub-agent roster
     table — retrospective root-cause analysis of project delays/blockers,
     report-only, no standing model pin. Spec:
     \`docs/specs/2026-09-22-investigator-agent.md\` in
     \`tlelosa-claude-config\`.*`

     **Known pre-existing drift, acknowledged not fixed:** the changelog has
     no `*v3.6 change:*` entry at all — it runs `v3.2, v3.3, v3.4, v3.5` and
     then stops, while the version line at `:5` already says `3.6`. So some
     v3.6 edit landed without a changelog entry, before and unrelated to this
     spec. This spec does not backfill that missing entry (it has no record of
     what the v3.6 change was, and inventing one would violate Hard Rule 12);
     it notes the gap in prose here so the new `v3.7` entry sitting directly
     after `v3.5` is understood as pre-existing drift rather than a mistake
     introduced by this task.
   - The directory-tree/roster-count block currently reads `Default 9-agent
     roster lives in` (verified `CLAUDE.md.template:424`, continuing across
     `:425–426`) and lists only 9 filenames in the tree (verified
     `CLAUDE.md.template:444–453`, `domain.md` through `data-agent.md`),
     already missing `explore.md` — a pre-existing gap independent of this
     spec. **This task fixes it:** `:424` becomes `Default 11-agent roster
     lives in`, and the filename list at `:444–453` gains both `explore.md`
     (the pre-existing gap) and `investigator.md` (this spec's own addition).

     **Ordering — corrected from the prior draft.** The prior draft said to
     insert these "in alphabetical order matching `bootstrap.sh`'s `AGENTS`
     array ordering". Verified false: the tree block at `:444–453` is **not**
     alphabetical — it is in CORE.md roster-table order (`domain.md`,
     `planner.md`, `architect.md`, `executor.md`, `tester.md`, `reviewer.md`,
     `doc-writer.md`, `debugger.md`, `data-agent.md`), the same order as the
     roster table at `:129–140` in this same file. The two new entries are
     therefore **appended in roster-table order**, after `data-agent.md`:
     `... ├── debugger.md`, `├── data-agent.md`, `├── explore.md`,
     `└── investigator.md` (tree-drawing characters adjusted so only the last
     line uses `└──`). This matches the roster table at `:129–140`, whose last
     row is already `Explore`, with `investigator` appended after it by task 6's
     table edit.
7. **`dcoe-roster/plugin.json`**: `version` moves `3.12.1 → 3.13.0` and the
   `description` field's two embedded version strings move to
   `"CORE.md, v1.13"` and `"matching CLAUDE.md v3.7"`, verified equal to the
   values landed in tasks 2 and 6 before this task is considered done (not
   merely copied from this spec's stated target — a divergent task-2 or task-6
   outcome must be re-checked against the live files, per Hard Rule 12).
8. **`hub-template/hooks/cloud-roster-bootstrap.sh`'s `EXPECTED_COUNT` reads
   `11`** (verified current value: `EXPECTED_COUNT=10` at
   `cloud-roster-bootstrap.sh:19`; it gates the roster-presence check at
   `:24`, `if [ "$ACTUAL_COUNT" -ge "$EXPECTED_COUNT" ]; then`). This closes
   BLOCK #1's silent-cloud-session-gap defect: left at 10, a cloud session
   with a stale 10-agent roster would report success while `investigator.md`
   was absent.

   **Three-way count agreement** — mirroring AC3's three-way *version*
   agreement, and checked the same way (read all three, compare, do not infer
   from this spec's stated target): after task 8 lands, all three of the
   following must be `11`, verified equal to each other:
   - `hub-template/hooks/cloud-roster-bootstrap.sh:19`'s `EXPECTED_COUNT`
     literal;
   - `agent-bodies-reference/roster-manifest.json`'s `agents[]` array length;
   - `agent-bodies-reference/bootstrap.sh`'s `AGENTS` array length
     (`bootstrap.sh:27–38`, currently 10 entries).

   If any two disagree, task 8 is not done, regardless of what this spec says
   the number should be.
9. **`README.md`** (new criterion — this file was missing from both prior
   drafts' file lists entirely). Both of the following, verified against the
   live file in this revision:
   - **`README.md:115`** currently reads `Verify with \`/agents\` — all ten
     show up unprefixed, with no \`dcoe-roster:*\`` (continuing at `:116`).
     This statement is **true today at 10 agents and made false by this spec**
     — a new, spec-caused defect, not pre-existing drift. It must read
     **"all eleven"**.
   - **`README.md:15–17`** currently reads `... See \`ADR-007\` in the
     \`Operations\` hub's \`docs/decisions/\` for the full design. The 9`
     (`:15`) / `roster agent bodies (domain, planner, architect, executor,
     tester,` (`:16`) / `reviewer, doc-writer, debugger, data-agent) are
     **not** shipped by this` (`:17`). This is already stale before this spec
     (missing `explore`) — the same defect class task 6 fixes in
     `CLAUDE.md.template`, fixed here for the same reason (the task already
     touches this file). It must read **"The 11 roster agent bodies"** and
     list all eleven, in the same roster-table order used everywhere else:
     `domain, planner, architect, executor, tester, reviewer, doc-writer,
     debugger, data-agent, explore, investigator`.

   Both edits must land for task 9 to be done; fixing `:115` alone leaves
   `:15–17` stale, and fixing `:15–17` alone leaves this spec's own
   self-inflicted `:115` defect in place.
10. `docs/todo.md` gets one atomic Done entry per task above once each lands and
    is pushed, each citing a verified commit SHA — per this repo's own
    `docs/specs/2026-08-12-done-sha-citation.md` convention: a Done entry is
    written at session-end, after the task's own commit has been pushed, and
    cites the SHA returned by `git log origin/main --oneline -- <path>` for
    the file(s) that task touched; if that command returns empty, the entry
    is not written and the session reports "not yet merged" instead. One
    entry per task, never a single batched entry once several tasks are in.
    The same task also files three named follow-up queue items under
    `docs/todo.md`'s `## Open` section (verified to exist at `docs/todo.md:449`)
    — see task 10 for their exact required text.
11. Every file in the manifest's `agents[]` array has a corresponding present
    file in `agent-bodies-reference/`, and every file physically present in
    `agent-bodies-reference/` has a corresponding manifest entry — checked as
    **two separate, explicit steps**, not one command, because no single
    existing command checks both directions:
    - (a) **Forward direction + activation, not just source-tree edits.**
      `node agent-bodies-reference/bootstrap.mjs --check` compares the
      manifest against the *installed* `~/.claude/agents/` directory (a
      deployment destination), not `agent-bodies-reference/` (the source
      tree this spec edits) — verified by reading `bootstrap.mjs:83–120` and
      `:181–191` directly. Immediately after this spec's source-file edits
      land, before any bootstrap actually runs, `--check` will correctly
      report `missing 1/11: investigator.md` and exit 1 against a stale
      `~/.claude/agents/` — that is not a spec defect, it is `--check`
      doing its job against a destination that hasn't been synced yet. The
      real acceptance check is sequenced: run
      `node agent-bodies-reference/bootstrap.mjs` (default, non-check mode)
      once — or start a fresh Claude Code session, which the `dcoe-roster`
      plugin's own `SessionStart` hook drives the same way — **then** run
      `--check` and confirm it reports all 11 present (`say(\`all
      ${manifest.agents.length} roster agents present\`)`, `bootstrap.mjs:186`)
      and exits 0.
    - (b) **Reverse direction, confirmed by direct inspection, not a
      command.** No existing script checks for a file present in
      `agent-bodies-reference/` with no manifest entry (a stray file, the
      inverse of `bootstrap.mjs`'s `stray` check at line 182–183, which only
      runs against the *destination* directory, not the source tree). This
      spec's own file list adds exactly one new source file
      (`investigator.md`) and one new manifest entry — confirmed by reading
      `agent-bodies-reference/*.md` file listing and comparing it by hand
      against `roster-manifest.json`'s `agents[]` array after task 3 lands,
      not inferred from the task list alone.

## Files to change (grouped into atomic tasks — none touches more than 1 file)

1. **`agent-bodies-reference/investigator.md`** (new file, 1 file) — write
   the agent body per the Appendix below, verbatim. No dependency; do this
   first since its role text is quoted (or closely paraphrased) into CORE.md's
   table in task 2. Satisfies AC1.
2. **`dcoe-roster/CORE.md`** (1 file) — add the `investigator` row to the
   roster table, placed last (after the `Explore` row — the same position
   used in every other roster listing this spec touches: the manifest,
   `CLAUDE.md.template`'s table/tree, and `README.md`'s filename list, so no
   surface's ordering diverges from the others). The cross-reference to
   `debugger` lives in `investigator.md`'s own body text ("Boundary with
   `debugger`"), not in physical table adjacency — visual placement doesn't
   need to match that relationship. Bump the Core version number at the top
   (`1.12` → `1.13`). No model-routing table change needed: `investigator`
   takes the universal default row, which already exists. Depends on task 1
   (for the role-description wording). Satisfies AC3's `CORE.md` leg.
3. **`agent-bodies-reference/roster-manifest.json`** (1 file) — add the
   `investigator` entry to `agents[]` (model `claude-sonnet-5`, effort
   `medium`, role string matching CORE.md's new table row), placed **last**
   (after the `explore.md` entry) to match CORE.md's now-updated table order
   and every other roster listing in this spec, and bump `coreVersion`
   to `1.13`. Depends on task 2 (needs the final version number and role
   wording). Satisfies AC2 and AC3's manifest leg.
4. **`agent-bodies-reference/bootstrap.sh`** (1 file) — add `investigator.md`
   to the `AGENTS` array (that array *is* alphabetical, verified at `:27–38`,
   so the new entry goes between `explore.md` and `planner.md`) and update all
   four numeric agent-count mentions — **lines 2, 7, 12 and 13** as
   re-verified in this revision — to `11`. Independent of tasks 2–3; only
   needs task 1's filename to exist. Satisfies AC4.
5. **This repo's own `CLAUDE.md`** (1 file, two non-adjacent edits) — update
   the SESSION START roster check at `CLAUDE.md:24–27` (count 10 → 11, add
   `investigator.md` to the filename list) **and** the PROJECT OVERVIEW line at
   `CLAUDE.md:59` ("the 10 roster agent bodies" → 11). Depends on task 1
   (filename) only. Satisfies AC5.
6. **`CLAUDE.md.template`** (1 file) — add an `investigator` row to its
   roster table at `:129–140`, after the `Explore` row, matching the "When to
   Use" phrasing style already used there (e.g. `Retrospective root-cause
   analysis of project delays/blockers (report-only)`); bump the file's own
   `# Version: 3.6` line at `:5` to `3.7` and add the `*v3.7 change:*`
   changelog entry described in AC6 after the `v3.5` block at `:528–534` and
   before `:536`; and fix the directory-tree/roster-count block — `:424`'s
   "9-agent roster" → "11-agent roster", and `:444–453`'s filename tree gains
   `explore.md` then `investigator.md`, **appended in roster-table order after
   `data-agent.md`** (that block is not alphabetical — verified). Depends on
   task 1 for the description wording; otherwise independent of tasks 2, 3, 5.
   Flag per repo-specific hard rule 2: this is template maintenance, not a
   change to this repo's own setup, but it still goes through the same DCOE
   spec-first gate as every other structural change here (cross-project by
   design, regardless of file count — Router rule 0 in CORE.md). Satisfies AC6.
7. **`dcoe-roster/plugin.json`** (1 file) — bump `version` `3.12.1 → 3.13.0`
   (`:3`) and update the two embedded version strings in `description` (`:4`)
   to `"CORE.md, v1.13"` and `"matching CLAUDE.md v3.7"`. Depends on task 2
   (needs `CORE.md`'s final version) **and** task 6 (needs
   `CLAUDE.md.template`'s final version) — must not land before both are
   final, since it copies both numbers verbatim into its own `description`
   string. Satisfies AC7.
8. **`hub-template/hooks/cloud-roster-bootstrap.sh`** (1 file) — bump
   `EXPECTED_COUNT=10` (verified at `:19`) to `EXPECTED_COUNT=11`. Independent
   of every other task except task 1 (needs `investigator.md` to exist so the
   count it gates against is correct) and task 3/task 4 for the AC8 three-way
   count check (which can only be *verified* once the manifest and
   `bootstrap.sh` arrays are at 11 — the edit itself has no such dependency).
   No version-number dependency, since this file carries no version field of
   its own. Satisfies AC8.

   **Follow-up not fixed here:** `EXPECTED_COUNT` is a second, independent copy
   of the roster's agent count, alongside `roster-manifest.json`'s `agents[]`
   array length and `bootstrap.sh`'s `AGENTS` array length — a third place this
   number lives and can drift again next time an agent is added. Filed as a
   `docs/todo.md` queue item in task 10.
9. **`README.md`** (1 file, two non-adjacent edits — new task, absent from
   both prior drafts) — `:115` "all ten" → "all eleven" (the defect this spec
   itself creates), and `:15–17` "The 9 roster agent bodies (domain, planner,
   architect, executor, tester, reviewer, doc-writer, debugger, data-agent)"
   → "The 11 roster agent bodies (domain, planner, architect, executor,
   tester, reviewer, doc-writer, debugger, data-agent, explore,
   investigator)". Depends on task 1 (filename) only; independent of every
   other task. Satisfies AC9.
10. **`docs/todo.md`** (1 file) — one atomic Done entry per task above (1
    through 9), each written after that task's own commit has landed on the
    default branch and been pushed, citing the SHA returned by
    `git log origin/main --oneline -- <path>` for the file(s) that task
    touched (per `docs/specs/2026-08-12-done-sha-citation.md` — entries are
    sequenced strictly after each task's own commit exists remotely, never
    inside that same commit, since a commit cannot cite its own not-yet-made
    SHA). A final Done entry, separate from the nine per-task entries, is
    written once all nine are in and cross-checked
    (`CORE.md`/`roster-manifest.json`/`plugin.json` version numbers verified
    equal per AC3, the three count surfaces verified equal per AC8,
    `agent-bodies-reference/` ↔ manifest correspondence verified per AC11).

    This same task also files **three** named follow-up queue items under
    `## Open` (`docs/todo.md:449`), each naming an exact file and line — these
    discharge Hard Rule 11 for findings this spec surfaced but does not fix:
    - **`hub-template/hooks/cloud-roster-bootstrap.sh:19`** — `EXPECTED_COUNT`
      duplicates the roster count that already lives in
      `roster-manifest.json`'s `agents[]` and `bootstrap.sh`'s `AGENTS`.
      Needs a derived-not-duplicated fix (e.g. read the count from
      `roster-manifest.json` after the shallow clone instead of a hardcoded
      literal).
    - **`.claude-plugin/marketplace.json:11`** — the `dcoe-roster` plugin
      description embeds a *fourth* stale version surface: it reads `Matches
      CLAUDE.md v3.4` (stale against the template's current `3.6`, and
      against this spec's `3.7`) and points at `agent-bodies-reference/
      bootstrap.sh` as the bootstrap path, superseded by `bootstrap.mjs` since
      CORE 1.5. Verified by direct read in this revision. Not fixed here (see
      Out of scope); needs its own small spec-or-single-edit task deciding
      whether marketplace-level descriptions should carry version strings at
      all, given they are a known drift surface.
    - **`agent-bodies-reference/debugger.md:4`** — `debugger.md`'s `tools:
      Read, Grep, Glob, Bash` omits `Write`, while `debugger.md:44` instructs
      it to `Write findings to docs/bugs/<slug>.md`. Verified by direct read.
      This is a live instance of exactly the defect this spec fixed in
      `investigator.md` (Codex finding 1). Not fixed here — a roster agent body
      change is its own structural change under repo hard rule 5 — but filed
      so it is not lost.

    Depends on tasks 1–9, and directly on task 1 as well (task 1's own
    commit is itself one of the ten entries this task writes, not only a
    transitive dependency through tasks 2–9).

## Dependency ordering

```
task 1 (investigator.md body)
   │
   ├──> task 2 (CORE.md: roster row + version bump)
   │        │
   │        └──> task 3 (roster-manifest.json: entry + coreVersion)
   │
   ├──> task 4 (bootstrap.sh)                    — independent of 2/3/5/6/7/8/9
   ├──> task 5 (this repo's CLAUDE.md)           — independent of 2/3/4/6/7/8/9
   ├──> task 6 (CLAUDE.md.template)              — independent of 2/3/4/5/8/9
   ├──> task 8 (cloud-roster-bootstrap.sh)       — edit independent of all but 1;
   │                                               AC8's three-way count check
   │                                               can only be verified once
   │                                               tasks 3 and 4 have landed
   ├──> task 9 (README.md)                       — independent of 2–8, only needs task 1
   │
   └──> task 10 (docs/todo.md)                   — direct edge: task 1's own
            ▲                                       commit is one of the entries
            │                                       task 10 writes, not merely
            │                                       reachable through 2–9
   task 2 ──┤
   task 6 ──┴──> task 7 (plugin.json: version + description, needs BOTH
                          task 2's and task 6's final version numbers)

tasks 2,3,4,5,6,7,8,9 (once each lands) ──> task 10 (docs/todo.md Done entries)
```

Tasks 4, 5, 6, 8 and 9 can run in parallel with each other and with task 2, but
task 3 must not land before task 2's version number is final (it copies that
number verbatim), and task 7 must not land before **both** task 2 and task 6
are final (it copies both their version numbers verbatim). Task 8's *edit* is
independent, but AC8's three-way count agreement cannot be *verified* until
tasks 3 and 4 have also landed — sequence the verification accordingly, not the
edit. Task 10 is last, after every other task's commit exists and is pushed —
and, per the direct edge above, is also a function of task 1's own commit, not
only of the tasks that build on task 1.

## Out of scope

- **Considered and rejected: deferring `CLAUDE.md.template`'s pre-existing
  `explore.md` / "9-agent roster" drift to a separate queue item.** The
  alternative considered was leaving `:424` and `:444–453` alone and filing a
  named `docs/todo.md` item citing those exact lines. Rejected because task 6
  already opens that exact file for the version/changelog edit, so the
  correction is a same-file, same-task text change costing less than filing an
  item and re-opening the file later; and because knowingly adding an eleventh
  agent while leaving a user-facing roster listing at nine widens visible drift
  (Codex finding 6 makes the same point). Hard Rule 11 requires *a* fix-or-file
  outcome, not a specific one; this spec chooses fix. AC6 and task 6 therefore
  state only that single behavior — this paragraph is the record of the
  rejected alternative, not a live branch an implementer may take. The same
  reasoning applies a fortiori to `README.md:115` (task 9), which is not
  pre-existing drift at all but a statement this spec actively falsifies.
- **No fix to `.claude-plugin/marketplace.json:11`'s stale `Matches CLAUDE.md
  v3.4` string and superseded `bootstrap.sh` reference.** This is a fifth
  version surface (alongside `CORE.md`, `roster-manifest.json`, `plugin.json`
  and `CLAUDE.md.template`) and unlike the template it is not a file any other
  task here opens, so the "already touching it" argument above does not apply.
  Filed as a named queue item in task 10 (`marketplace.json:11`), per Hard
  Rule 11.
- **No change to `agent-bodies-reference/debugger.md`.** Two distinct findings,
  both deliberately left: (a) its scope (code root-cause) is unaffected and a
  one-line cross-reference to `investigator` in its own body is optional
  polish; (b) its `tools` list at `:4` is missing `Write` despite `:44`
  requiring a report write — a real defect, the same one this spec fixes in
  `investigator.md`, but a roster agent body change is structural under repo
  hard rule 5 and belongs to its own task. Both are filed as a named queue item
  in task 10 (`debugger.md:4` vs `:44`), per Hard Rule 11 — not merely
  discussed in this prose.
- **No backfill of `CLAUDE.md.template`'s missing `*v3.6 change:*` changelog
  entry.** The gap is real and acknowledged in AC6, but this spec has no record
  of what the v3.6 change was, and writing one from inference would violate
  Hard Rule 12.
- **No new hook, command, or automation** — `investigator` is invoked like
  any other roster agent (by name or by Claude Code's task-routing), same as
  `debugger`/`Explore`. No `SessionStart` or `PostToolUse` wiring.
- **No `docs/investigations/` scaffolding in this repo** — that directory
  lives in each *consuming* project (same pattern as `docs/bugs/` for
  `debugger`), not in `tlelosa-claude-config` itself, which ships no runtime
  docs tree of its own.
- **No fix to `EXPECTED_COUNT`'s duplicated-count design** in
  `hub-template/hooks/cloud-roster-bootstrap.sh` — bumped to the correct
  literal value in task 8 and verified by AC8, but the underlying "count lives
  in three places" design is filed as a follow-up queue item in task 10, not
  fixed here.
- **No CORE.md model-routing table change.** `investigator` takes the
  existing universal-default row; per the standing-pin test in CORE.md, it
  does not qualify for a standing pin (not every task it receives is
  automatically a security/architecture escalation), matching the confirmed
  scope ("no standing model pin").
- **No schema or data-store change** — this is a Markdown/JSON-only change;
  no migration file applies (flagging per Architect-escalation rule on schema
  changes, in the negative: confirmed not triggered here).

## Effort

Small — nine small file edits plus one `docs/todo.md` task with ten Done
entries (nine per-task, one final cross-check) and three queue items. Larger
than the prior draft's eight-edit estimate because this revision adds
`README.md`, the file both prior drafts' file lists omitted. Still no new
plugin, and no version bump beyond the CORE/manifest/plugin/template version
fields this spec already changes.

## Appendix: `agent-bodies-reference/investigator.md` full text (task 1)

Executor should use this text verbatim unless review changes it — and per
AC1's body-content requirement, the landed file's body **must match this
Appendix's text verbatim**, not merely "state that it implements nothing" as a
paraphrase. Frontmatter fields chosen to match the existing convention
(compare `debugger.md` and `reviewer.md`): `tools` grants exactly what the
phases below use (no shell execution needed beyond `git log`/`git blame`, which
`Bash` covers; `Write` is included in the tools list below — corrected per
Codex's 2026-09-22 review, which caught it missing from an earlier draft
despite the agent body requiring a report write — and is scoped in prose to the
one report path, mirroring how `planner` is trusted with `Write` scoped in
prose to `docs/specs/`). Per AC1's framing, this frontmatter does not claim to
be technically read-only — `Bash` is a strictly stronger grant, trusted by
instruction, same as `debugger.md`'s own (unclaimed, but real) `Bash` grant at
`debugger.md:4`.

```markdown
---
name: investigator
description: Use for retrospective root-cause analysis of project-level delays and blockers — a spec that cycled through multiple review rounds, a todo item open far longer than comparable items, a recurring slippage pattern across sessions. Use PROACTIVELY when a process question has no clear cause yet and the evidence is dated documents/git history rather than a stack trace. Does not fix process or implement anything — hands findings to Planner/Architect/owner.
tools: Read, Grep, Glob, Bash, Write
model: claude-sonnet-5
memory: project
---

You are the Investigator agent. Your job is retrospective root-cause analysis
of project delays and blockers, not fixing them and not debugging code.

**Boundary with `debugger`:** `debugger` investigates code defects and hands
off a failing test. You investigate *process and timeline* questions — why a
spec, task, or decision took longer than expected, or why a pattern of delay
keeps recurring. If a question you're handed turns out to have a code root
cause (a bug caused the delay, not a process gap), say so explicitly and
hand it to `debugger` rather than forcing it through your own frame.

## Phase 1 — Build the timeline

1. Establish the evidence base: `docs/todo.md`, `docs/session-logs/` (or
   `docs/session-log.md`), the relevant spec(s) in `docs/specs/`,
   `docs/retro-log.md` if present, and git history (`git log`, `git blame`,
   commit dates) for the files/decisions in question.
2. Build a dated sequence of what actually happened — when the work was
   requested, when a spec was drafted, when review happened (and how many
   rounds), when it landed, or where it currently sits open. Cite every claim
   with a file, commit SHA, or dated log entry — never assert a date from
   memory or paraphrase.
3. Note what a *comparable* item looked like (a similar spec/task that moved
   normally) so the analysis has a baseline, not just the outlier.

## Phase 2 — Isolate the cause

1. Distinguish categories before naming one: unclear acceptance criteria,
   a genuinely hard technical/architectural question, a review-loop
   ping-pong (repeated BLOCKs on the same defect class), a dependency on
   something external (owner decision, another session's unmerged work), or
   a plain queue-management gap (item never picked up, not because it was
   hard but because nothing routed to it).
2. Check whether this is a **recurring** pattern (same cause behind multiple
   delayed items) or a one-off. A recurring pattern is more valuable to
   report — it points at a process gap worth fixing once, not re-litigating
   per instance.
3. If a `shared-memory/learnings/` or `knowledge/` index exists in this
   project, check it for a prior recorded instance of the same pattern
   before treating this one as new.

## Phase 3 — Handoff (you implement nothing, and you fix no process)

Write findings to `docs/investigations/<slug>.md`: the dated timeline, the
isolated root cause (with citations), whether it's recurring or one-off, the
comparable-item baseline, and a **specific recommended next step** naming
which agent or person should act on it (`planner` to revise a spec's
acceptance criteria, `architect` for a structural gap, the owner for a
judgment call this agent has no authority to make). You do not draft the fix
yourself, even a process one — that line stays with whoever owns the file
being changed, same boundary `debugger` holds for code.

## Red flags — restart Phase 1 if you catch yourself thinking

- "It was probably just X" without a citation to a dated document
- Proposing a process fix instead of naming who should propose it
- Treating a single instance as a pattern without checking for a second one
- Blaming a person rather than isolating a process or information gap

Output format: path to the investigation report, one-paragraph root-cause
summary, and which agent/person the recommended next step routes to.

Hard rule: you are read-only over the codebase and dated documents, and your
only write is the one report file above. Never edit `docs/todo.md`, a spec,
or any source file as part of an investigation — report what should change
and who should change it.

Update your memory with recurring delay patterns for this project (a review
gate that habitually needs two passes, a class of task that always stalls on
an external dependency) so future investigations start from that context
instead of relearning it.
```

## Codex second opinion (advisory) — 2026-09-22

**Findings**

1. **Tooling contradiction in `investigator.md` frontmatter**
   The acceptance criterion says the agent is “read-only plus a single report-write path (`docs/investigations/<slug>.md`)”, and the Appendix says “Write findings to `docs/investigations/<slug>.md`”. But the proposed frontmatter is:
   ```yaml
   tools: Read, Grep, Glob, Bash
   ```
   There is no `Write` tool listed. The paragraph above the Appendix also says “`tools` grants exactly what the phases below use” and mentions “`Write` is scoped in prose”, but the actual tool list omits it. This is a hard implementation blocker: either add `Write` to the tools list, or change the behavior so the agent outputs the report content without writing a file.

2. **Acceptance criterion 1 is internally ambiguous on model pinning**
   It says the file “carries no standing model pin” but also requires frontmatter convention including `model`, and the Appendix includes:
   ```yaml
   model: claude-sonnet-5
   ```
   Later, criterion 2 requires the manifest entry to say `model: claude-sonnet-5`. If “no standing model pin” means “use the default model value explicitly”, say that. As written, an implementer could reasonably interpret “no standing model pin” as omitting `model` from the agent body.

3. **Task ordering conflicts with Hard Rule 5 / commit-based todo requirement**
   Criterion 7 says `docs/todo.md` gets “one atomic entry per task below once each lands, naming the commit”. But the task list also says task 7 can be “one batched entry once all six file-edit tasks above are in”. Those are different process requirements. If the repo genuinely requires one todo entry per landed task and commit, the batched-entry option should be removed. If one batched Done entry is acceptable, criterion 7 should say that.

4. **Acceptance criterion 8 may be incomplete if `bootstrap.mjs --check` validates more than manifest/file presence**
   The spec says AC8 is “Every file in the manifest’s `agents[]` array has a corresponding present file” and makes that “checkable with `node agent-bodies-reference/bootstrap.mjs --check`”. That is only valid if the check command actually verifies exactly that, or at least includes it. The spec does not state whether `bootstrap.mjs --check` also validates copied output, order, counts, generated files, or destination state. This matters because the implementation might pass the stated manifest/file invariant but fail the actual command.

5. **“Read-only/report-only” is weaker than the proposed `Bash` grant**
   The Appendix allows `Bash` for `git log` / `git blame`, but the tool grant is unrestricted at the frontmatter level. The hard rule relies entirely on prose: “your only write is the one report file above.” If this roster treats tool lists as the enforceable boundary, then `Bash` undermines “read-only”. If prose boundaries are the established convention, that's acceptable, but the spec should explicitly acknowledge that `Bash` is trusted-by-instruction rather than technically constrained.

6. **Out-of-scope stale roster counts could become user-visible drift**
   The spec says not to fix `CLAUDE.md.template`'s directory-tree block because it already omits `explore.md`, and adding `investigator.md` there “would widen a pre-existing gap rather than create a new one.” That rationale is weak. If this change adds another roster file and knowingly leaves a visible roster listing stale, the drift becomes more misleading. I would either include that directory-tree update in task 6 or create an explicit follow-up todo in `docs/todo.md`.

7. **No acceptance criterion verifies the actual agent body content beyond broad intent**
   AC1 says the file “states explicitly that it implements nothing and proposes no code fix,” but the Appendix contains several more important behavioral requirements: dated citations, comparable baseline, recurring-vs-one-off classification, handoff target, boundary with `debugger`, memory update. If those are intentional requirements, they need acceptance criteria. Otherwise an implementation could satisfy AC1 with a much thinner body and still technically pass.

8. **“Update your memory” may be untestable or unavailable**
   The Appendix says:
   > “Update your memory with recurring delay patterns for this project…”

   But the spec earlier says this repo has no `shared-memory/` or `knowledge/` tree. If “memory: project” is an agent runtime feature, fine, but the acceptance criteria do not explain how to verify this. If it is not reliably testable, make it guidance rather than a hard behavioral expectation.

**Buried Assumptions**

The spec assumes `claude-sonnet-5` is the universal default and valid in this repo's manifest schema. That may be true, but the spec does not require checking the existing manifest schema or existing agent bodies before copying the value.

It assumes the roster has exactly 10 current agents and this becomes the eleventh. Several criteria depend on counts. Given the spec already cites prior drift, I would add a preflight acceptance check: count current manifest agents and current `agent-bodies-reference/*.md` before editing.

It assumes `CLAUDE.md.template` is the only downstream-facing documentation table that needs updating. The out-of-scope note about the directory-tree block suggests there may be more generated or copied references.

**Architectural Alternatives Worth Weighing**

1. **Extend `reviewer` or `planner` instead of adding an agent**
   If these investigations mostly produce process/spec recommendations, `planner` may already own the natural next step. A separate `investigator` is justified only if retrospective timeline reconstruction is common enough to deserve a reusable method and memory. The spec argues this well for not using `debugger`, but does not compare against `planner` or `reviewer`.

2. **Create a reusable investigation template instead of an agent**
   If the value is mainly the required report shape, a `docs/investigations/template.md` or spec checklist could be lighter than a new roster role. This is less useful if proactive routing and agent memory are important, but the spec should state that those are the reason an agent is preferable.

3. **Add a shared “root-cause analysis” protocol referenced by `debugger` and `investigator`**
   The spec draws a clean boundary between code defects and project delays. A small shared protocol could prevent divergence in concepts like timeline, evidence, cause, and handoff. I would only weigh this if the repo already has shared agent methodology files; otherwise it is probably overkill.

**Bottom Line**

The concept is sound and the `debugger` separation is well argued. The main blocker is the Appendix/tooling mismatch: the agent is required to write reports but lacks `Write`. The other high-value fixes are clarifying "no standing model pin," tightening the todo/commit acceptance criterion, and deciding whether knowingly stale template roster documentation should be fixed now or explicitly tracked.

_Advisory only — reviewer agent retains sole APPROVE/BLOCK authority._

## Reviewer BLOCK #1 (2026-09-22) — resolution log

Four blockers, five warnings. Resolution, each verified against live files:

1. **`dcoe-roster/plugin.json` missing from the file list** — fixed: task 7,
   AC7, three-way version agreement folded into AC3.
2. **`hub-template/hooks/cloud-roster-bootstrap.sh`'s hardcoded
   `EXPECTED_COUNT=10`** — fixed: task 8, bumped to 11; the
   duplicated-count design itself filed as a `docs/todo.md` follow-up in
   task 10, not fixed in this spec.
3. **`CLAUDE.md.template`'s own version line/changelog untouched by task
   6, plus the deeper "9-agent roster" + missing-`explore.md` drift** —
   fixed: task 6 widened to cover both.
4. **AC8 untestable** — replaced with AC11's two-part (a)/(b) split:
   sequenced bootstrap-then-check for the manifest↔installed-directory
   check, and direct inspection for the manifest↔source-tree reverse
   direction.
5. **Warnings** — task 4/AC4 now names all count-bearing lines in
   `bootstrap.sh`; task 10/AC10's wording now matches
   `docs/specs/2026-08-12-done-sha-citation.md`'s sequencing exactly
   (Done entry after push, never inside the commit it describes); AC1
   reworded to drop the "technically read-only" claim and match
   `debugger.md`'s actual (unclaimed but real) `Bash` framing; new AC1
   clause requires the landed body to match the Appendix verbatim; the
   dependency diagram now shows the direct task 1 → task 10 edge.

## Reviewer BLOCK #2 (2026-09-22) — resolution log

Two blockers, six warnings, plus one wording objection on AC6. Every file
named below was re-opened and read directly in this revision; the two
citation corrections were found by that re-reading, not accepted on report.

1. **BLOCKER — `README.md` absent from the file list in both prior drafts.**
   Fixed: new task 9, new AC9, covering `README.md:115` (`all ten` → `all
   eleven`; a statement this spec itself falsifies) and `README.md:15–17`
   (`The 9 roster agent bodies (...)`, already missing `explore`, → all 11 in
   roster-table order). Both line ranges re-verified against the live file.
2. **BLOCKER — task 8 had no acceptance criterion.** Fixed: new AC8, requiring
   `cloud-roster-bootstrap.sh:19`'s `EXPECTED_COUNT` to read `11` **and** to be
   verified equal to `roster-manifest.json`'s `agents[]` length and
   `bootstrap.sh`'s `AGENTS` length — a three-way count agreement mirroring
   AC3's three-way version agreement.
3. **Warning — wrong `bootstrap.sh` line citations.** Confirmed and fixed: the
   count-bearing lines are **2, 7, 12, 13**, not 2, 8, 12, 14. Lines 8 and 14
   carry no count (re-read in this revision).
4. **Warning — `CLAUDE.md` count lives in two places.** Confirmed and fixed:
   AC5/task 5 now cite `CLAUDE.md:24–27` (session-start filename list + count)
   and `CLAUDE.md:59` (PROJECT OVERVIEW "the 10 roster agent bodies")
   separately, as one file with two non-adjacent edits.
5. **Warning — template tree ordering is not alphabetical.** Confirmed and
   fixed: `CLAUDE.md.template:444–453` is in CORE.md roster-table order
   (domain → data-agent), matching the table at `:129–140` in the same file.
   AC6/task 6 now instruct appending `explore.md` then `investigator.md` in
   roster-table order, not alphabetically.
6. **Warning — missing `v3.6` changelog entry in the template.** Confirmed
   (`:5` says `Version: 3.6`; the changelog at `:509–534` runs v3.2 → v3.5 and
   stops; `:536` is the `Last review` line). Acknowledged explicitly in AC6 and
   in Out of Scope as pre-existing drift; not backfilled, since this spec has
   no record of what the v3.6 change was.
7. **Warning — `.claude-plugin/marketplace.json:11` is a fifth version
   surface.** Confirmed by direct read (`Matches CLAUDE.md v3.4` and a
   reference to the superseded `bootstrap.sh`). Out of scope here; now filed as
   a named `docs/todo.md` queue item in task 10, per Hard Rule 11.
8. **Warning — `debugger.md:4` vs `:44` `Write`-tool gap only discussed in
   prose.** Confirmed by direct read. Now filed as a real named queue item in
   task 10, in addition to the Out of Scope note.
9. **AC6's conditional branch collapsed.** The reviewer agreed the planner's
   default (fix the template drift now) was correct and should not return to
   the owner as an open question, but objected that AC6 stated two conditional
   behaviors. AC6 and task 6 now state the single chosen behavior as a plain
   requirement; the rejected alternative (file a queue item instead) moved to
   Out of Scope as a "Considered and rejected" note, where it is context rather
   than a live branch. The prior draft's "Open judgment call for the owner"
   section is removed accordingly — there is no open judgment call in this
   revision.
