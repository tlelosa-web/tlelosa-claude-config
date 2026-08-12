# Spec — Get the DCOE roster onto cloud sessions

**Date:** 2026-08-12
**Status:** Draft — awaiting owner approval before build
**Owner:** Tebello Lelosa
**Type:** Structural — touches `CORE.md` (core version bump), the
`dcoe-roster` plugin, and (depending on the chosen option) every opted-in
project repo's own tree. Full DCOE: this spec, then Reviewer Loop, then
Execute.
**Origin:** Open item "Get the roster onto cloud sessions" in
`docs/todo.md`, raised by the first `/retro` run (2026-08-10). Supersedes
and absorbs the second half of the "record the cloud-session ref-deletion
blocker" item, which named the same gap.

## Problem

CORE 1.5 made roster deployment automatic via a `SessionStart` hook shipped
inside the `dcoe-roster` **plugin** (`dcoe-roster/hooks/hooks.json`, running
`agent-bodies-reference/bootstrap.mjs`). That hook only fires on a machine
that has run `/plugin marketplace add` + `/plugin install
dcoe-roster@tlelosa-claude-config` — i.e. Operations and Pappa T.

A Claude Code cloud session (Claude Code on the web / Claude Code Remote)
clones the target repo fresh into an isolated container and never installs
the marketplace. Confirmed this session via the `session-start-hook` skill:
cloud sessions do support a **repo-level** `SessionStart` hook, declared in
a committed `.claude/settings.json` and referencing
`$CLAUDE_PROJECT_DIR`/`$CLAUDE_CODE_REMOTE` — no plugin install required —
but nothing in any opted-in repo currently ships one. So on a cloud session:

- `~/.claude/agents/` does not exist at all.
- Every delegation to a roster agent (`domain`, `planner`, `architect`,
  `executor`, `tester`, `reviewer`, `doc-writer`, `debugger`, `data-agent`,
  `Explore`) silently falls back to Claude Code's built-in agent of the same
  or a similar name.
- The `Explore` fallback in particular inherits the session's own model
  instead of running at the documented Haiku tier — every search delegation
  runs at Sonnet/Opus prices with no error or warning.

This is not a defect in CORE 1.5, which targets the two real machines by
design. The gap is that cloud sessions — confirmed this session to be doing
a large share of this repo's actual work — are a third surface CORE 1.5
never targeted, and nothing at session start says so. The 2026-08-10 session
that raised this item ran its entire retrospective un-delegated because of
exactly this gap.

## Constraints carried over from CORE 1.5's own design

- **Missing-only semantics must hold on this surface too.** A cloud session
  is fully ephemeral per-container, so "missing-only, don't revert local
  edits" is close to moot there (the container never survives to accumulate
  local edits) — but if a future persistent-workspace cloud mode ships, the
  same missing-only rule should still apply without a rewrite.
- **No duplicate agent listing.** `agent-bodies-reference/` was deliberately
  kept outside `dcoe-roster/agents/` so the plugin loader never lists each
  agent three times (2026-07-29 strip decision). Whatever this spec proposes
  must not reintroduce that.
- **`roster-manifest.json` stays the single source of truth** for which
  agents exist and which model each takes, in step with `CORE.md`'s routing
  table.
- **No company or project data** — repo-specific hard rule 1 applies to
  every file this spec adds, same as everything else in this repo.

## Options

### Option A — Commit `.claude/agents/` into each opted-in project repo

Vendor the 10 agent body files directly into every project that opts into
DCOE (this repo already has `agent-bodies-reference/` as its own
copy-source; `Claude-Code`, `ai-product-factory`, and any future opted-in
project would each carry their own `.claude/agents/*.md`, committed).

**Pros**
- Works immediately on any surface, cloud included — no hook, no network
  call, no plugin install. `.claude/agents/` is read directly by Claude
  Code regardless of how the session started.
- No dependency on the `session-start-hook` mechanism continuing to behave
  the way it does today.

**Cons**
- Reintroduces exactly what CORE 1.5 and the 2026-07-29 strip were built to
  avoid: N copies of the same 10 files, one per opted-in repo, each capable
  of drifting independently. A fix to `debugger.md` (like the
  systematic-debugging fold-in) now needs a coordinated multi-repo push
  instead of one commit to `tlelosa-claude-config` plus each machine
  picking it up on its own schedule.
- `agent-bodies-reference/roster-manifest.json`'s "missing-only, self-heal"
  bootstrap model has nothing to reconcile against once each repo carries
  its own independent copy — the propagation story CORE 1.5 documents
  (edit here, machines pick it up next session start) stops applying to
  this surface, with no replacement described.
- Every opted-in repo pays the file-count and diff-noise cost permanently,
  not just once during a transition.

### Option B — Move (or add) the `SessionStart` hook to repo level

Ship a `.claude/settings.json` in each opted-in repo with a `SessionStart`
hook (confirmed viable this session via the `session-start-hook` skill —
`$CLAUDE_PROJECT_DIR` and `$CLAUDE_CODE_REMOTE` are both available without
any plugin install) that runs a bootstrap step to populate
`~/.claude/agents/` before the session proceeds.

The open question Option B does not resolve on its own: **where does the
hook get the agent body content from**, since `bootstrap.mjs`,
`roster-manifest.json`, and the 10 `.md` bodies live only in
`tlelosa-claude-config`, not in the repo the cloud session actually cloned.
Two sub-approaches:

- **B1 — hook clones/fetches `tlelosa-claude-config` at session start**,
  then runs `bootstrap.mjs` from that fetched copy. Keeps a single source of
  truth and matches CORE 1.5's existing propagation model almost exactly,
  but depends on the cloud session's network policy allowing an outbound
  clone of a private repo, and adds a network round-trip (and its failure
  modes — auth, rate limits, an unreachable remote) to every session start
  on this surface.
- **B2 — hook fetches a lighter published artifact** (e.g. a release
  tarball or raw-content fetch of just the 10 `.md` files + manifest,
  rather than a full clone) — smaller and faster than B1, but is a new
  distribution mechanism this repo doesn't have today and would need its
  own maintenance (something has to publish that artifact on every roster
  change).

**Pros (both sub-approaches)**
- Single source of truth preserved — no per-repo drift, propagation story
  stays the one CORE.md already documents.
- Matches the existing CORE 1.5 mental model (bootstrap script + manifest +
  missing-only) rather than replacing it with a different one for this
  surface.

**Cons (both sub-approaches)**
- Still needs a `.claude/settings.json` + hook script committed to *every*
  opted-in repo — smaller than Option A's payload (a hook + a fetch step,
  not 10 files) but not zero-touch either.
- Introduces a network dependency into `SessionStart` that today's
  plugin-based hook doesn't have (the plugin-installed copy already has the
  files locally once installed; a cloud session never does).
- Needs one real validation this spec cannot complete from a description
  alone: run a cloud session against a repo carrying the new hook and
  confirm `~/.claude/agents/` is actually populated before the first
  delegation.

## Recommendation

**Option B1** (repo-level hook, fetching `tlelosa-claude-config` directly),
provisionally — it is the only option that keeps the single-source-of-truth
propagation model CORE 1.5 already committed to, and the
`session-start-hook` skill confirms the underlying mechanism (repo-level
`SessionStart`, no plugin needed) works on this surface. Option A is the
fallback if B1's clone-at-session-start step turns out to be blocked by
network policy on a meaningful share of cloud sessions — that is an
empirical question this spec cannot answer without a live test.

## Open questions (must be answered before Execute)

1. Does a Claude Code cloud/web session's default network policy permit an
   outbound `git clone`/fetch of a private GitHub repo (`tlelosa-web/tlelosa-claude-config`)
   during `SessionStart`? Needs a live test, not a guess.
2. If B1 is viable, does the hook clone the whole repo (simple, but pulls
   `Operations/`/`Pappa T/`-scale history/content into every cloud
   container) or a shallow/sparse checkout of just
   `agent-bodies-reference/`?
3. Which repos are actually "opted-in" for this purpose? At minimum this
   repo, `Claude-Code`, and `ai-product-factory` per the current GitHub
   scope — confirm the full list before writing per-repo hook files.
4. Async vs sync hook mode (per the `session-start-hook` skill): sync
   guarantees the roster is present before the first delegation but delays
   session start; async starts faster but risks a delegation racing ahead
   of the bootstrap. Given the cost of a silent built-in fallback (this
   whole problem), sync is the strong default — confirm.
5. Core version bump: this changes what `CORE.md` describes as the
   deployment mechanism (a third surface, a new "SESSION START" note per
   opted-in `CLAUDE.md`) — 1.5 → 1.6, documented same as prior bumps.

## Explicitly out of scope

- Recovering the stranded `claude/continuation-n6vvc6` branch (unrelated
  Open items) — tracked separately per this session's own decision.
- Any change to the Operations/Pappa T plugin-based bootstrap path — CORE
  1.5's existing mechanism for those two machines is not being replaced,
  only extended to a third surface.
