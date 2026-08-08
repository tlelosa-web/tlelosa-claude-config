# Spec — System maintenance plan (config repo + hub, 2026-08-08)

**Date:** 2026-08-08
**Status:** Draft — awaiting approval
**Owner:** Tebello Lelosa
**Scope:** System maintenance only. No project work (no SOPS, NamePlateTool,
TebelloReborn, Delivery Note, or any other sub-project task appears here).

## Problem

A full systems check on 2026-08-08 (both repos, all manifests, all command
and agent files, git and PR state verified against a fresh `git fetch`)
found the tooling itself healthy but the **bookkeeping around it broken in
four distinct ways**:

1. **16 branches across the two repos are unmerged with no open PR**, several
   carrying finished, reviewed work — including a bootstrap script that
   closes an open todo item outright, and an ADR that a Done entry already
   claims exists.
2. **A Done entry asserts something untrue** — `docs/todo.md` says ADR-010
   was recorded in the hub; it is not on the hub's `main`.
3. **Manifest and doc drift** — the marketplace catalog still advertises a
   plugin layout abandoned on 2026-07-29, and two manifests cite a template
   version superseded on 2026-07-21.
4. **Documented model routing contradicts the deployed agent files**, and the
   Haiku search tier that `CORE.md` advertises is very likely not in effect.

None of these are bugs in the tooling. They are all *drift between what the
system says about itself and what it is* — which is precisely the failure
mode DCOE's bookkeeping rules exist to prevent, so fixing them is
maintenance of the governance layer, not feature work.

This plan touches `CORE.md`, both plugin manifests, and multiple command
files across two repos. That is structural under this repo's own rules, so
it gets a spec first.

## Root cause of the branch problem

The stranding is not an accident of any one session — it is systemic. Cloud
sessions each push a `claude/<slug>` branch and end. Nothing in `/continue`
or `/session-end` asks "is there unmerged work on another branch?", and the
work is invisible from a local machine that never fetches. So each session
ends *believing* it delivered, and the next one starts from `main` without
it. Sixteen branches is what four weeks of that looks like.

**Any fix that only merges the current backlog will be back here in a
month.** Phase 6 is therefore not optional polish — it is the actual fix,
and the merges in Phase 2 are the cleanup it enables.

-----

## Phases

Ordered by dependency, not by size. Phases 1–2 come first because **the
stranded branches contain edits to the same files every later phase
touches** (`docs/todo.md`, `CORE.md`, `continue.md`, `marketplace.json`).
Fixing those files before triaging the branches guarantees conflicts, and
guarantees resolving them against a base that is itself mid-repair.

### Phase 1 — Establish ground truth (read-only, no commits)

No file changes. Output is a verdict per branch, written down.

**1.1 — `tlelosa-claude-config` branch triage (3 branches).**
For each, determine what it contains that `main` lacks, and issue one
verdict: **rebase-and-land**, **cherry-pick specific commits**, or
**discard with reason**.

| Branch | Age | Carries | Known conflict surface |
|---|---|---|---|
| `config-audit-gap-report-aew9g7` | 18d | config audit vs Claude Code v2.1.212, week-1 fixes spec, `Explore` agent override, `executor` `isolation:worktree` fix, 3 hub-template hooks | `marketplace.json`, `CLAUDE.md.template`, `CORE.md`, `plugin.json`, `docs/todo.md`, and `dcoe-roster/agents/executor.md` — a path deleted by the 2026-07-29 strip |
| `continuation-utn4f5` | 3d | `agent-bodies-reference/bootstrap.sh`, JSON-validation pre-commit hook spec, `/session-end` gap fix | `docs/todo.md`, `hub-template/session-end.md` |
| `repo-status-update-n5z63h` | 20d | `hub-template/retro.md`, CORE.md hard rule "verify remote state before asserting it" | `continue.md`, `README.md`, `CORE.md`, `docs/todo.md`, `HUB-CHECKLIST.md`, `hub-template/continue.md` |

Two known complications to resolve *during* triage, not after:

- **`config-audit-gap-report` predates the agent-body strip.** It re-adds
  `dcoe-roster/agents/`, which ADR-level decision 2026-07-29 deliberately
  removed. Its `executor` and `Explore` changes must be replayed into
  `agent-bodies-reference/`, never merged as-is. This branch is a
  cherry-pick-by-hand job, not a rebase.
- **Both older branches are based on CORE 1.1; `main` is 1.2.** The
  `repo-status-update` branch writes "verify remote state" as hard rule 9,
  but 1.2 gave rule 9 to codex-review. If kept, it becomes **rule 10**.

`continuation-yon8p3` needs no verdict — verified byte-identical to `main`;
its content already landed. Delete the branch in Phase 2.3.

**1.2 — `Claude-Code` hub branch triage (13 branches).**
Same verdict format. All 13 are diverged (none fast-forwardable).

Do **not** assume all 13 carry lost work: `main`'s tip is a 68-commit
"Re-merge Pappa T vault", which may already have absorbed much of it. The
reliable test is per-file — what does this branch contain that `main`
lacks — run branch by branch.

What is *confirmed* stranded (files present on a branch, absent from
`main`):

| File | Stranded on |
|---|---|
| `docs/decisions/ADR-010-session-end-command.md` | `continuation-utn4f5`, `session-end-archive-afo043` |
| `.claude/commands/overwatch.md` | `continuation-utn4f5` |
| `docs/specs/2026-08-05-command-center.md` | `continuation-utn4f5` |
| `knowledge/claude-code-sessions.md` | `reddit-article-claude-sessions-yefxfd` |
| `knowledge/cloud-sessions.md` | `total-race-count-indicator-keqb18` |
| `knowledge/pitcrew-sync.md` | `pwa-component-driver-app-ysxe8a` |

The three `knowledge/` files are the priority: the cache exists so facts
are not re-derived, and three sessions' findings are currently where no
session will read them.

**Deliverable:** `docs/specs/2026-08-08-branch-triage-verdicts.md` (config
repo) covering both repos, one row per branch: verdict, rationale, what
lands, what is dropped and why.

**Gate:** Tebello approves the verdicts before any branch is merged or
deleted. Discarding a branch is irreversible in practice; it is not a call
to make unilaterally.

### Phase 2 — Recover the keeps

Execute Phase 1's approved verdicts. One task = one commit throughout.

- **2.1** Land config-repo keeps. Expect the `Explore`/`executor` changes to
  be re-authored into `agent-bodies-reference/` rather than merged.
- **2.2** Land hub keeps. ADR-010 first (Phase 3.1 depends on it), then the
  three `knowledge/` files, then `overwatch.md` + the command-center spec if
  the verdict keeps them.
- **2.3** Delete every branch that is merged, superseded, or discarded —
  including the 8 config-repo branches already fully merged and
  `continuation-yon8p3`. A branch list that only shows live work is what
  makes the Phase 6 check cheap to run.

### Phase 3 — Correct the record

- **3.1** Fix the false ADR-010 claim in `docs/todo.md:61-62`. Once Phase 2.2
  lands ADR-010, the claim becomes true and the entry needs only a date
  correction; if the verdict was to drop it, the claim must be retracted
  instead. Note that hub commit `7e2ce22` ("Write ADR-010 for real; correct
  stale session-end claims") is a prior session's attempt at this exact fix,
  itself stranded — prefer its wording over re-deriving.
- **3.2** Record PR #14 (`hub-template/continue.md` reconcile) in Done. This
  is the only merged PR missing from the list.
- **3.3** Refresh `knowledge/INDEX.md`: PR #14 is described as "open" (it
  merged 2026-08-07), and any `knowledge/` file landed in Phase 2.2 needs
  its index row.

### Phase 4 — Manifest and doc drift (trivial, one commit each)

All single-file edits — straight to Execute, no spec needed beyond this one.
Validate JSON before each manifest commit.

- **4.1** `marketplace.json` — rewrite the `dcoe-roster` description. It
  still advertises "sub-agent roster: domain, planner, architect, executor,
  tester, reviewer, doc-writer, debugger, data-agent" as if shipped. It has
  not shipped them since 3.4.0. `plugin.json` and `README.md` were both
  updated on 2026-07-29; the catalog entry — the text actually rendered by
  `/plugin marketplace list` — was missed.
- **4.2** `marketplace.json` + `dcoe-roster/plugin.json` — "CLAUDE.md v3.2"
  → v3.3, matching the template since 2026-07-21.
- **4.3** `CLAUDE.md` ESSENTIAL COMMANDS — add `codex-gate/plugin.json` to
  the validate-before-commit block. It lists 3 of 4 manifests, leaving a
  hole in repo hard rule 3 exactly where a broken manifest breaks installs.
- **4.4** `CLAUDE.md` PROJECT OVERVIEW — add `codex-gate/` and
  `agent-bodies-reference/`, both absent; stop calling `dcoe-roster` "the
  sub-agent roster plugin"; and reword hard rule 5, which gates changes to
  "CORE.md or the agents" but points at agents no longer in that plugin.

### Phase 5 — Model routing (structural, needs its own spec + CORE bump)

Three linked inconsistencies. One spec, one decision, one CORE version bump
(1.2 → 1.3) — not three separate edits to the same table.

- **5.1** `architect` is pinned to `claude-opus-4-8` in its frontmatter, but
  `CORE.md` names only `reviewer` as a standing Opus exception and hard rule
  7 says "Opus is earned, not assigned." Either the pin is wrong or
  `architect` is a second documented exception. **Decision needed.**
- **5.2** The routing table mixes generations: default `claude-sonnet-5`,
  escalation target `claude-opus-4-8`. Escalating from a 5-family model to a
  4.8-family one is backwards; the current Opus is `claude-opus-5`.
- **5.3** The Haiku search tier is very likely not in effect. The
  `config-audit-gap-report` branch documents that Claude Code's built-in
  Explore stopped defaulting to Haiku as of v2.1.198 and now inherits the
  session model — so every search delegation runs at Sonnet 5 prices while
  `CORE.md` advertises a Haiku tier. **Re-verify against the current Claude
  Code version before acting**; that finding is 18 days old and the
  behaviour may have changed again.

Because this changes `CORE.md`, it reaches every opted-in project on both
machines. Per hard rule 9 it also wants a `/codex-review` pass — see the
machine-bound note below.

### Phase 6 — Stop the recurrence (the actual fix)

Without this, Phase 2 is a treadmill.

- **6.1** Add an unmerged-branch check to `hub-template/continue.md` and
  `hub-template/session-end.md`: list branches not merged into the default
  branch, with age, and surface them. `/session-end` is the natural place to
  catch a session that is about to strand its own work; `/continue` catches
  what previous sessions already stranded. Both, not one.
- **6.2** Backport the Step 1.75 sync check to this repo's own
  `.claude/commands/continue.md`. It never fetches before reporting git
  state — Step 1 runs `git status` against possibly-stale refs. The hub
  template gained this in PR #14; the local instance did not. (I fetched
  manually during the systems check and state *was* current, but the command
  cannot guarantee that.)
- **6.3** If Phase 1.1 keeps it, land the "verify remote state before
  asserting it" hard rule as **rule 10**. It is the general form of 6.2 and
  belongs in `CORE.md`. Fold into Phase 5's CORE bump rather than bumping
  twice.

### Phase 7 — Repo hygiene and governance

- **7.1** Hub `.gitignore` — there is none at root, and build artifacts are
  tracked: a **31 MB `node-v24.10.0-x64.msi`**, a 2 MB `backend.log.1`, and
  ~6 MB of generated PNGs, in a 67 MB repo. Add a `.gitignore` and untrack
  going forward. **Do not rewrite history** to purge them — that breaks
  every existing clone on both machines plus any cloud session, for a
  cosmetic size win. Untracking is enough.
- **7.2** **Governance decision needed (Tebello only).** The hub's hard rule
  4 says "no company or project data beyond what's already public in the
  source project's own repo," but `Operations/` holds
  `CustomerInvoicesReport.csv`, `CustomerSalesOrdersByCustomer.csv`,
  `Contract register 2025.xlsx`, and the 07.2026 sales order report. The
  hub-and-spoke design intends sub-projects to live there, so the rule and
  the layout contradict each other. Resolve which one is meant, and reword
  the loser. All five repos are confirmed private, so this is a
  clarity-of-rules issue, not an exposure — with one caveat worth deciding
  on explicitly: **cloud sessions clone the entire vault, company data
  included, into an Anthropic cloud container.** The IT clearance on record
  covers a personal Anthropic account on the work PC; whether it covers that
  is a separate question, and it is the same class of question as the open
  codex-gate/OpenAI-egress item.
- **7.3** Fold the three already-open machine-bound items into this plan's
  tracking rather than leaving them stranded in the Open list: the
  `~/.claude/agents/` bootstrap (**note: Phase 2.1 may land `bootstrap.sh`,
  which closes this outright**), the codex-gate smoke test on Pappa T, and
  the IT question on OpenAI egress.

-----

## Machine-bound dependencies

This plan is being written from a cloud container. Three things cannot be
done here and must be flagged rather than silently skipped:

1. **`/codex-review` is unavailable.** codex-gate is Pappa T-only and needs
   the Codex CLI at `~/.codex/`. Hard rule 9 requires a codex-review pass on
   every spec before dispatching an Executor — including this one and Phase
   5's. Either run it from Pappa T before building, or record an explicit
   waiver. Do not let it lapse silently.
2. **Phase 5.3 needs a real machine** to confirm the current Explore
   behaviour and the installed Claude Code version.
3. **Phase 7.3's items are inherently per-machine.**

## Acceptance criteria

- Every branch in both repos is either merged, deleted, or listed in the
  triage doc with a written reason for keeping it open.
- `docs/todo.md` contains no claim contradicted by the repo state — the
  ADR-010 assertion specifically is true or retracted.
- All four manifests validate, and no manifest or catalog description
  describes a layout the repo no longer has.
- `CORE.md`'s routing table matches every agent file's frontmatter, and any
  standing exception is documented in both places.
- `/continue` and `/session-end` surface unmerged branches, in both the
  template and this repo's instance.
- A follow-up systems check finds no new stranded branch older than one
  session cycle.

## Explicitly out of scope

Project work of any kind. NamePlateTool's Excel-import bug, the SOPS
migration items, TebelloReborn Phases E–H, and every other sub-project task
in the hub queue stay untouched — they are tracked in their own repos'
`docs/todo.md` and are not what this plan is for.

## Recommended entry point

Phase 1.1 (three branches, one repo, read-only). It is the smallest unit
that produces a decision, it needs no machine access, and its output gates
the largest irreversible step in the plan.
