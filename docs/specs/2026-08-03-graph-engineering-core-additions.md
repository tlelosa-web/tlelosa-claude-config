# Spec — Name the reviewer Loop and promote the scale Router into CORE.md

**Date:** 2026-08-03 | **Status:** Approved by owner (no dedicated `reviewer`
agent available on this machine — see the roster-bootstrap gap logged in
`docs/todo.md` — so approval followed the ADR-009 human-approval path
directly) and implemented same session.
**Basis:** Comparison of a "Graph Engineering" reference architecture (Graph
Orchestrator over Agent/Tool/Data/Goal components, named topology patterns,
Router/Reducer/Verifier primitives) against DCOE as currently documented in
`dcoe-roster/CORE.md` and this repo's own `CLAUDE.md`. Full comparison
reported in-session 2026-08-03; not itself copied here — see that session's
transcript if the reasoning needs revisiting.

## Why

DCOE already implements most of what the reference architecture describes,
under different names (Orchestrator = Graph Orchestrator, sub-agent roster =
Agents, `reviewer` = Verifier, parallel Executors = fan-out). Two ideas are
genuinely missing or only exist as an unpromoted local pattern:

1. **The reviewer gate is already an iterate-until-pass loop in practice**
   (Hard Rule 9: `codex-review` → `reviewer` approve/reject), but CORE.md
   never draws the "if rejected, back to Context Agent" edge — it's implicit
   in how Hard Rule 9 is used, not written down.
2. **This repo's own CLAUDE.md already has a scale-based Router** ("How DCOE
   Applies Here": trivial single-file edit → skip straight to Execute;
   structural change → full DCOE) — but it's local to this one project. Other
   spoke projects (e.g. the Claude-Code hub) have independently reinvented
   the same distinction rather than inheriting it from CORE.md.

Both are **naming/promotion changes to existing behavior**, not new
capability — low risk, in keeping with this repo having no runtime to break.

## What changes

### 1. `dcoe-roster/CORE.md` — name the reviewer Loop

**Edit target (per 2026-08-03 Amendment below):** the actual source checkout,
`C:\Users\tlelo\Downloads\tlelosa-claude-config\dcoe-roster\CORE.md` — not
the installed plugin path (`~/.claude/plugins/marketplaces/tlelosa-claude-config/...`),
which is a synced copy other projects read but this repo never edits.

Under "DCOE Rules" (or immediately after Hard Rule 9 in "Universal hard
rules" — whichever the architect implementing this judges reads better in
context), add a short paragraph documenting the existing cycle explicitly:

> **Reviewer Loop.** The spec-review-build sequence is a loop, not a single
> gate: `Context Agent writes spec → codex-review (advisory) → reviewer
> approve/reject`. **Final pre-build authority rests with the `reviewer`
> agent** (per Hard Rule 9 — Codex is advisory only, never a decider). On
> reject, control returns to the **Context Agent**, not to Execute — the
> spec is revised and the loop repeats. Only the `reviewer` agent's APPROVE
> exits the loop into Execute. The loop is manual and owner/reviewer-
> directed — there is no automatic retry count or escalation; a spec can
> cycle as many times as the reviewer requires. This is the same cycle Hard
> Rule 9 already requires; this paragraph names it so it can be pointed to
> instead of re-derived per project.

No behavior changes — Hard Rule 9 already requires this sequence. This just
gives it a name, draws the loop-back edge that was previously implicit, and
settles the human-vs-agent approval ambiguity the 2026-08-03 Codex review
flagged between this wording and ADR-009's "human approves" phrasing: the
`reviewer` agent is the actual decision-maker; a human can still redirect it
at any point, same as any other agent action.

### 2. `dcoe-roster/CORE.md` — promote the scale Router

Add a new step to "DCOE Rules" (numbered before rule 1, or as rule 0 — the
implementer's call) formalizing the classification this repo's own CLAUDE.md
already performs locally:

> **0. Router (scale check).** Before Domain Agent, classify the task by
> **impact first, file count second** (2026-08-03 Amendment — file count
> alone under-classifies governance changes; this very spec touches only
> 2 files but changes universal behavior):
>    - **Structural regardless of file count:** anything touching contracts,
>      data, security, production behavior, governance/shared-core docs
>      (`CORE.md`, an agent definition), or cross-project dependencies —
>      full DCOE: Domain confirms scope, Context writes a spec, then Execute.
>    - **Trivial** (only if none of the above apply): single-file edit, typo
>      fix, version bump, no schema/contract change, no cross-project
>      effect — skip Domain/Context, go straight to Execute. One task = one
>      commit still holds.
>    A project's own `CLAUDE.md` may restate this in project-specific terms
>    (as this repo's "How DCOE Applies Here" already does) but should not
>    need to re-derive the underlying rule.

This repo's own "How DCOE Applies Here" section becomes a worked example of
rule 0 applied to a markdown/JSON-only repo, not a standalone local
invention — leave that section's wording as-is (it already matches), just
note in this repo's `docs/todo.md` that it's now an instance of the promoted
rule.

### 3. Version bump

Bump `dcoe-roster/CORE.md`'s "Core version" line (currently 1.1) to **1.2**,
per this repo's Repo-Specific Hard Rule 5 (changes to CORE.md affect every
opted-in project and must bump the version so machines can tell a real
update happened at next `/plugin marketplace update`).

## Out of scope

- No change to the actual `reviewer`/`codex-gate` mechanics — this only
  documents the existing cycle, doesn't add retries, auto-iteration, or
  tooling.
- No change to any spoke project's own `CLAUDE.md` — promoting the Router
  to CORE.md doesn't require every project to delete its local restatement;
  that's optional cleanup left to each project's own next touch.
- No quantified/metrics-based observability (durations, token counts) — the
  in-session comparison flagged this as a real gap versus the reference
  architecture, but out of scope for a no-runtime markdown/JSON repo.
- No new Reducer role — flagged in the comparison as a real gap (Orchestrator
  merge/conflict-resolution discipline is undocumented), but deliberately
  left out of this spec to keep the change to the two highest-value,
  lowest-risk items. Worth its own spec later if merge conflicts recur.

## Acceptance criteria

1. `dcoe-roster/CORE.md` contains a named "Reviewer Loop" paragraph
   describing the reject → Context Agent loop-back.
2. `dcoe-roster/CORE.md` contains a Router rule (trivial vs. structural)
   ahead of or alongside the existing DCOE Rules list.
3. Core version bumped to 1.2 with a changelog-style note (matching how the
   1.0 → 1.1 bump was recorded, if precedent exists — otherwise a one-line
   note at the top is sufficient).
4. `python -m json.tool` still passes on all plugin manifests (this change
   touches only `CORE.md`, a markdown file, so no manifest should need
   touching — confirm nothing else regresses).
5. This repo's own `docs/todo.md` updated marking the change done, per this
   repo's Hard Rule 5.
6. Run `/codex-review` against this spec before dispatching an Executor, per
   Universal Hard Rule 9 — fold any real findings back as a dated Amendment
   before implementation starts. **Satisfied by this spec's own 2026-08-03
   "Codex second opinion" + "Amendment" sections below** — any future spec
   reusing this one as a template should point to its own dated sections,
   not this one's.

## Amendment — 2026-08-03 (post-Codex-review)

Three of the six Codex findings were folded directly into "What changes"
above (edit-path precision, reviewer-authority disambiguation, impact-based
Router classification). One finding (no "How DCOE Applies Here" section in
the current root `CLAUDE.md`) was **not acted on** — it's a false positive:
that section does exist in `tlelosa-claude-config/CLAUDE.md` today, confirmed
by direct read in the 2026-08-03 session that wrote this spec. Codex's
`codex exec` sandbox was scoped to a different repo's working directory
(the session's cwd at the time, a separate hub repo) and couldn't see this
repo's actual `CLAUDE.md` — a real limitation of running `/codex-review`
from a session whose cwd differs from the spec's own project, worth keeping
in mind for future cross-repo spec work, not a defect in this spec.

Two findings were noted but deliberately left for the implementing Executor
rather than the spec itself:
- **Manifest-validation criterion (#6):** acceptance criterion 4 already
  says "if any plugin manifests exist in the edited source tree" in spirit;
  left as-is since this change only touches `CORE.md`, a markdown file, and
  the Executor can confirm at build time whether any manifest is even
  reachable from that edit.
- **Marketplace metadata/release-marker gap:** flagged as a real question
  (does anything besides `/plugin marketplace update` need to change for
  machines to pick up 1.2?) but out of scope for this spec — CORE.md's own
  header already documents the pull-based update mechanism; no evidence a
  separate release marker exists to update.

**Second Opinion**

The spec is directionally sound, but I would not approve it as-is. The two conceptual changes are reasonable; the weak points are stale file assumptions and ambiguous governance around the Router/reviewer gate.

**Findings**

1. **File location assumption is wrong or at least unstated.**
   The spec repeatedly says `dcoe-roster/CORE.md`, but this repo does not contain that path. Root `CLAUDE.md` points to `~/.claude/plugins/marketplaces/tlelosa-claude-config/dcoe-roster/CORE.md`, and the live CORE file itself says "edit here, commit, push" in the marketplace source. The spec needs to name the actual source checkout to edit, not the installed/cache path, or an Executor may patch the wrong copy.

2. **The "this repo's own CLAUDE.md already has a scale-based Router" claim looks stale.**
   I found no "How DCOE Applies Here" section or trivial/structural Router wording in the current root `CLAUDE.md`. The spec says "leave that section's wording as-is" and "note in `docs/todo.md` that it's now an instance of the promoted rule," but the referenced section appears absent. Acceptance criteria should either require adding that note somewhere real, or remove the claim.

3. **Reviewer authority is muddled.**
   The proposed paragraph says: `Context Agent writes spec → codex-review (advisory) → reviewer approve/reject`. Existing CORE Hard Rule 9 says `/codex-review` is advisory and "the `reviewer` agent still holds sole APPROVE/BLOCK authority." ADR-009 says "Planner writes spec → `/codex-review` → human approves or asks planner." Those are not identical. The spec should explicitly settle whether final pre-build approval is by human owner, reviewer agent, or both.

4. **Router criteria leave common cases ambiguous.**
   "Trivial" is "single-file edit…" and "Structural" includes "> 2 files," leaving exactly two-file changes unclear. This spec itself touches two files (`CORE.md`, `docs/todo.md`) but changes universal behavior, so it is structural by impact, not file count. Add a rule like: "any CORE.md / governance / cross-project behavior change is Structural regardless of file count."

5. **Acceptance criterion 6 is process-only and hard to verify.**
   "Run `/codex-review` against this spec before dispatching an Executor" is fine as a rule, but the acceptance criteria do not say where the review output must be recorded. Require a dated "Codex advisory" or "Amendment" section in the spec file, or it is not testable after the fact.

6. **Manifest validation criterion is under-specified.**
   "`python -m json.tool` still passes on all plugin manifests" assumes there are discoverable plugin manifests in this repo. My search found no `plugin.json` under the current workspace. The acceptance criterion should name the manifest root in the marketplace/source repo, or say "if any plugin manifests exist in the edited source tree."

**Failure Modes Not Covered**

- Editing the installed marketplace copy instead of the source repo, then losing the change on the next plugin update.
- Bumping CORE to 1.2 without updating any marketplace metadata or release marker that machines actually use to detect/consume the update.
- Router rule causing agents to skip Domain/Context for "small" edits that are operationally risky, such as secrets, production data paths, migrations, permissions, or governance docs.
- Reviewer Loop becoming infinite or vague: no limit, owner escalation, or handling for repeated reject cycles is documented. That may be acceptable, but the spec should say the loop is manual and owner-directed, not automated retry behavior.

**Acceptance Criteria Gaps**

Add criteria for:

- The actual source path edited for `CORE.md`, not just `dcoe-roster/CORE.md`.
- A concrete dated changelog note in CORE mentioning both "Reviewer Loop" and "Router."
- A check that `CLAUDE.md` no longer contradicts the promoted Router, or remove the stale "How DCOE Applies Here" claim.
- A post-change grep confirming `Core version: 1.2`, `Reviewer Loop`, and `Router (scale check)` exist in the intended source file.
- A recorded `/codex-review` advisory/amendment location.

**Alternatives I'd Weigh**

1. **Minimal CORE-only governance patch.**
   Add Router and Reviewer Loop only to CORE, with no `docs/todo.md` note beyond normal task closure. This is cleaner if the root `CLAUDE.md` does not actually contain the claimed worked example.

2. **Promote as "Triage" instead of "Router."**
   "Router" may imply a runtime dispatcher. If this is documentation-only human/agent procedure, "Scale Triage" may be clearer and less likely to be interpreted as tooling.

3. **Make Router impact-based first, file-count second.**
   I would define Structural as "changes contracts, data, security, production behavior, governance, or cross-project dependencies," then use file count as a secondary heuristic. That better matches the real risk profile.

Net: sound intent, but the spec needs a small amendment before implementation. The biggest blocker is the stale/ambiguous path and the unsupported claim about the current root `CLAUDE.md` already containing the Router example.

_Advisory only — reviewer agent retains sole APPROVE/BLOCK authority._
