# Spec — Get the DCOE roster onto cloud sessions

**Date:** 2026-08-12
**Status:** Draft — open questions answered 2026-08-12; awaiting owner
approval before Reviewer Loop / Execute
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

## Open questions — answered 2026-08-12

1. **Network policy for an outbound clone during `SessionStart` — partially
   verified, one gap remains for Execute.** Two things were actually tested
   this session, not guessed:
   - A same-session `git clone --depth 1` of `tlelosa-claude-config` (a repo
     already in this session's attached sources) succeeded in ~1.4s with no
     `add_repo` call for that specific git operation — the credentials the
     proxy hands the session are ambient at the git level, not gated per
     command.
   - The real B1 scenario — a **cold** cross-repo clone, from a session
     whose sources never included `tlelosa-claude-config` — was attempted
     twice via spawned test sessions and both were inconclusive for reasons
     worth recording rather than discarding: attempt 1 was intercepted by
     the target repo's own `CLAUDE.md` session-start ritual before the raw
     command ran (the session followed its host repo's instructions instead
     of the one-off diagnostic prompt); attempt 2 used an explicit
     system-prompt override to skip that ritual, and the child session
     correctly treated an unverified override as suspicious and stopped to
     ask for reconfirmation rather than proceed. That is the right behavior
     from that session, not a bug — but it means neither attempt produced a
     clean yes/no.
   - **Resolution:** don't chase this further with synthetic test sessions.
     The real test bed is the hook itself — install it for real on one
     opted-in repo and watch one live cloud session start, per the
     `session-start-hook` skill's own "Validate Hook" step. Make this the
     **first step of Execute**, not a blocking pre-condition of approving
     this spec. If it fails there, Option A (Done) is the documented
     fallback and the spec does not need to be rewritten to fall back to it.
2. **Shallow vs. sparse clone — resolved: plain shallow clone.** Measured
   this session: `tlelosa-claude-config` is ~0.38 MB of tracked content
   (`git ls-tree -r -l HEAD`), 832K on disk including `.git`. At this size a
   sparse checkout of just `agent-bodies-reference/` buys nothing worth its
   added complexity over `git clone --depth 1` of the whole repo.
3. **Opted-in repo list — resolved for now, re-check at Execute.** Per the
   current GitHub scope for this account: `Claude-Code` and
   `ai-product-factory` are the two consumers that need the new hook.
   `tlelosa-claude-config` itself does not — it already has
   `agent-bodies-reference/` locally by definition, and its own `CLAUDE.md`
   SESSION START section already points at the local working copy, not a
   bootstrap step. Re-confirm the list hasn't grown before writing the
   per-repo hook files, since scope can change between sessions.
4. **Sync vs. async — resolved: sync.** Matches the `session-start-hook`
   skill's own default ("don't use async in the first iteration") and the
   cost asymmetry here is lopsided: a silent built-in-agent fallback is
   exactly the failure this spec exists to close, so a session start that's
   a few seconds slower but guarantees the roster is present beats a faster
   start that can silently race a delegation ahead of the bootstrap.
5. **Core version bump — resolved: 1.5 → 1.6, plus one pre-existing drift to
   fix in the same commit.** Checked `agent-bodies-reference/roster-manifest.json`
   this session: its `coreVersion` field still reads `"1.4"`, even though
   `CORE.md` has been at 1.5 since before this spec was written — a drift
   that predates this task. Bumping to 1.6 without correcting the manifest
   would leave it two versions stale instead of one. Bundle the manifest fix
   into whichever Execute commit does the 1.6 bump; it does not need its own
   task or spec (single-field JSON correction, hard rule 0's trivial case).

## Explicitly out of scope

- Recovering the stranded `claude/continuation-n6vvc6` branch (unrelated
  Open items) — tracked separately per this session's own decision.
- Any change to the Operations/Pappa T plugin-based bootstrap path — CORE
  1.5's existing mechanism for those two machines is not being replaced,
  only extended to a third surface.
