# Feasibility audit — Linear adoption for project management

**Date:** 2026-08-12 | **Status:** Findings only — nothing implemented  
**Scope:** Linear as a replacement or supplement to `docs/todo.md` + `docs/session-log.md` pair across tlelosa-claude-config, Claude-Code hub, and ai-product-factory vaults

-----

## Blockers (read first)

1. **Architectural mismatch on contention files.** The current system designates `docs/todo.md` and `docs/session-log.md` as **contention files** requiring `git fetch + git pull` before editing (CLAUDE.md hard rule 6 in the hub). This is because three machines (Operations, Pappa T, cloud sessions) write to the same files concurrently. Linear centralizes state on its server and removes the git-based conflict model entirely — which *solves* one problem while introducing a different one: **network dependency**. All state writes now require reaching Linear's API. A cloud session with network restrictions, or a desktop session on a network outage, cannot write state at all. Current system degrades gracefully (local write succeeds; merge conflict happens later and is resolved with both sides' changes preserved). Linear's model either requires network or silently loses state.

2. **The known-risks deferrals pattern has no Linear equivalent.** In the current system, when a session surfaces a risk too large to fix in that session, it records a queue item with exact deferral criteria — e.g. "Phase 7 hub hygiene: awaiting owner decision on two governance issues". The risk is visible on every `/continue`, which means it doesn't get silently deferred forever. Linear's model relies on issue filters and dashboards; a single unclosed issue in a 2,000-item backlog becomes invisible. If Linear adoption happens, this visibility model must be re-implemented — e.g. a standing "blockers" view, or a dashboard that surfaces deferred work by age-of-deferral. **No blocker to adoption, but it needs a design call and likely custom tooling.**

3. **Concurrent session discovery is a manual step today.** When a `/continue` session starts, it calls `list_sessions` to discover what other sessions are open in the same vault. That reveals "I'm working on X, you might need to know about that" without requiring human coordination. Linear has no analog for session-level state (sessions are a Claude Code construct, not visible to Linear). Adoption would need to replace this with either (a) a convention ("prefix your Linear issue title with the branch name"), (b) new tooling (a bot that auto-creates issues from sessions), or (c) manual discipline (always update Linear before starting work). None is as frictionless as the current system.

4. **Fan Movement contract termination changes the calculus completely.** As of 2026-08-03, the Fan Movement contract is terminated and the Operations machine is no longer a deployment target. This means:
   - The "two machines" constraint (Operations + Pappa T) still stands, but the *number* of machines just changed from 3 (+ cloud) to 2 (+ cloud)
   - Any off-the-shelf Linear integration assumes **one canonical authority** for issue state — typically the main branch. With two independent machines, each reading/writing Linear, there must be a decision about whether the "source of truth" is the Linear API or git history. Current system makes both true simultaneously via `docs/todo.md` checked in. Linear breaks that symmetry.
   - The **Operations hub's snapshots in this repo** (now deliberately marked as archives) no longer carry runtime state that needs tracking. This simplifies the multi-project state problem slightly, but doesn't eliminate the two-machine concurrency problem.

5. **No vendor lock-in is a non-negotiable constraint in this setup.** This repo is explicitly generic ("Shared tooling only — NEVER project content or company data") and is cloned on both a personal and an employer machine. Any adoption of Linear would amount to a vendor lock-in decision that affects both machines. The current `docs/todo.md` + `docs/session-log.md` system is self-hosted, zero vendor, zero operational dependencies. This is a **decision the owner must make**, not something analysis can resolve — but it's a real constraint.

-----

## 1. Functional fit — what Linear would replace vs. what it cannot

### What Linear can replace

- **`docs/todo.md` as the queue.** Linear issues map directly to tasks. Backlogs, filtering, priority fields, status tracking — all native. `docs/todo.md` becomes a read-only export (a markdown table or a linked dashboard) rather than the source of truth.
- **`docs/session-log.md` as the record.** Linear's issue history and linked comments can record per-session decision trails and lessons-learned. Combined with a convention (e.g., "Close issue on `/session-end`"), this replaces the linear log.
- **Stranded-branch detection.** A Linear field ("unmerged branch?") can track branches not yet in main. Combined with a bot, this semi-automates Step 1.5 of `/continue`.

### What Linear cannot replace

- **`docs/retro-log.md` (the friction analysis record).** Retro is run once every few sessions and generates a timestamped entry. Linear's model is "one issue per task" — retro would need a custom "meta-issue" type or a separate doc. Not a blocker, but needs design.
- **`knowledge/` cache (the per-topic fact store).** Linear is task/workflow tracking; it is not a fact database. The knowledge cache survives retro runs and sessions, carrying forward reusable findings. Linear would need a separate integration (e.g., Linear + a Notion/Obsidian/markdown sync for the cache). Alternatively, the cache stays git-hosted and Linear stays purely for the queue.
- **`CLAUDE.md` instructions and ADRs.** These are configuration and architecture docs, not tasks. Linear is not a documentation system. They stay in git.
- **The `.claude/commands/` protocols.** `/continue`, `/session-end`, and `/retro` are git-based scripts that run locally. Moving to Linear would require rewriting these as API clients. Possible, not trivial, and tightly couples the commands to Linear's API stability.

### The core question: does it replace or duplicate?

**It does both, and that's the problem.**

If you use Linear as the canonical queue (`docs/todo.md` becomes a read-only export), then `/continue` and `/session-end` must read from Linear's API instead of git. Sessions running in the cloud with restricted network access cannot read state. Storing the queue in git remains a backup, but then you have two sources of truth and the cost of keeping them in sync.

If you keep `docs/todo.md` as the canonical queue and add Linear as a "visibility layer" (synced read-only dashboard), then:
- You've added operational complexity (sync tooling) without removing the git-based contention problem
- Sessions write to git as before; Linear stays always-behind
- The system is strictly harder to use (read from two places) without removing the hard problem (concurrent writes from three machines)

-----

## 2. Multi-machine behavior — the hard case

Current system (git-based):
- Session writes to `docs/todo.md` locally
- Session does `git fetch + git pull` before editing (hard rule 6)
- If both machines edited since last sync, git reports a merge conflict
- Session resolves the conflict *as a union* (both sides' changes preserved)
- Result: no lost data, visible merge ceremony forces human attention

Linear-based system (API-based):
- Session A calls Linear API: "add task X"
- Session B calls Linear API: "add task Y"
- Linear server receives both, stores both
- Both sessions now see both tasks
- **This works perfectly for independent tasks**

But Linear's behavior with **the same field modified concurrently** is the problem:
- Session A calls Linear API: "move task X from Open to In Progress, update description"
- Session B simultaneously calls Linear API: "move task X from Open to Review, update description"
- One request wins; the other's metadata (`Updated-at`, `Updated-by`) is overwritten
- No merge conflict, no warning, no manual resolution
- **One session's edits are silently lost**

This is the **atomic write isolation** problem. Linear handles it by "last write wins". Git handles it with merge conflicts. The current system surfaces the problem; Linear hides it.

-----

## 3. Session discovery and coordination

Current system:
- `/continue` session A calls `list_sessions` and sees sessions B, C, D also open
- It reads their transcripts (via `list_events`) to understand what they're working on
- If there's overlap (both sessions editing the same file or the same task), the human sees it and coordinates
- The mechanism is **automatic and free** (session tooling, no additional burden)

Linear-based system:
- `/continue` session A queries Linear API for issues created/updated in the last 24 hours
- Session B's work might be captured if B remembered to create an issue for it
- If B opened the issue but hasn't updated it yet, A sees incomplete/stale info
- The mechanism requires **discipline** (every session must maintain an issue) and **staleness tolerance** (issues update asynchronously)

This is a **soft regression** — the system still works, but visibility is degraded and coordination requires more human attention.

-----

## 4. Fan Movement contract termination — what actually changed

Terminated 2026-08-03. Consequences:

1. **No more Operations deployment target.** Previously: Operations (work PC) and Pappa T (personal) were both canonical machines. Now: Pappa T is the only living personal machine; Operations data is archives only.

2. **The "two machines + cloud sessions" problem didn't go away.** It became "one machine + cloud sessions" — still concurrent, still needs sync. Cloud sessions can't reach Pappa T's local filesystem; Pappa T can't reach a cloud session's filesystem. State must live in a reachable place: git (both can reach GitHub) or a centralized service (both can reach the API).

3. **Snapshot copies in this repo are now explicitly marked "archive/reference only."** The `Operations/` folder snapshot was deliberately kept (per CLAUDE.md) as history, not as live state. Its presence doesn't change the architecture — it's documentation, not runtime. This slightly *reduces* the burden (no need to sync archive state), but doesn't alter the core multi-machine problem.

4. **Operating cost of the current system actually went *down*.** Two independent machines synchronizing git is cheaper (bandwidth, dependencies) than two machines + cloud sessions all reaching a centralized API. The problem was already hard; it didn't get harder when one machine's *new* work stopped. (Archive queries still happen, but less frequently.)

**Implication for Linear:** The contract termination doesn't make a business case *for* Linear adoption — the multi-machine problem is still present, and cost trade-offs still favor git. It *does* clarify scope — one live machine simplifies the "version skew" problem (no need to sync Linear client versions across two desktop installs), but introduces a different one (Pappa T becomes the gateway for all state writes, which is a single point of failure if Pappa T is offline).

-----

## 5. Recommendation

**Status quo is maintained until blockers 1 and 4 are resolved by owner decision.**

The case *against* Linear:
- Blocker 1 (network dependency) is a real architectural downgrade for a setup that runs offline-first
- Blocker 4 (vendor lock-in and multi-machine state) is a non-negotiable design principle
- Blocker 2 (deferred risk visibility) needs solved differently (new tooling/dashboard) whether or not Linear is adopted
- Blocker 3 (concurrent session discovery) has no frictionless solution in Linear; the cost is real
- Functional overlap (duplication vs. replacement) creates operational burden either way

The case *for* Linear:
- Visibility and reporting — a dedicated tool surface is better than markdown tables
- Automated workflow — issues can drive state changes (e.g., "Close issue when merged" GitHub Action)
- Integration with GitHub and Linear's other ecosystem features (teams, cycles, sprints, etc.) if those ever become relevant
- Single source of truth for the backlog — removes the "keep two files in sync" burden (trades it for "keep git and Linear in sync")

**Open questions (require owner input):**
1. Is offline-first (no network dependency on the critical path) non-negotiable?
2. Is self-hosting (zero vendor lock-in) required, or is Linear acceptable as a dependency?
3. If Linear is adopted, what becomes the canonical source of truth — git or Linear's API?
4. How should Pappa T (the single remaining personal machine) become an external queue writer if all state centralizes on Linear?

**If owner decides to adopt:**
- Issue a new structural spec (ADR + detailed implementation plan)
- Design the offline-first and multi-machine state-sync model *before* writing code
- Plan the migration (how long does `docs/todo.md` stay as a shadow; when does it become read-only)
- Build/integrate the missing tooling (deferred-risk dashboard, session discovery bot, retro-log handling)

-----

## Revision history

- **2026-08-12** — first draft. Findings structured as five blockers + five recommendation sections, following the 2026-07-21 codex-gate readiness audit format. No implementation; decision gate set at blocker 1 (network dependency) and blocker 4 (vendor lock-in + multi-machine state).
