# Branch triage verdicts — `tlelosa-claude-config` (Phase 1.1)

**Date:** 2026-08-08
**Status:** Awaiting owner approval — no branch merged or deleted until approved
**Plan:** `docs/specs/2026-08-08-system-maintenance-plan.md`, Phase 1.1
**Method:** every verdict below is based on reading the branch's actual file
contents against current `main` (fetched 2026-08-08), not on commit messages.

## Summary

| Branch | Age | Verdict | Lands | Drops |
|---|---|---|---|---|
| `config-audit-gap-report-aew9g7` | 18d | **Cherry-pick by hand** | 7 items | 3 items |
| `continuation-utn4f5` | 3d | **Land nearly whole** | 5 items | 0 |
| `repo-status-update-n5z63h` | 20d | **Partial — mostly superseded** | 4 items | 4 items |
| `continuation-yon8p3` | 13d | **Delete** — content verified identical to `main` | — | — |
| 8 already-merged branches | — | **Delete** | — | — |

**Three version collisions must be resolved during the rebase** (detail
below). Two branches independently bumped to version numbers `main` has
since assigned to something else. A naive merge would silently produce two
different "v3.3"s of the master template.

-----

## Branch 1 — `config-audit-gap-report-aew9g7`

**Verdict: cherry-pick by hand. Do not rebase, do not merge.**

Five commits from 2026-07-21, based on `49ca4ea`, predating the 2026-07-29
agent-body strip. It re-adds `dcoe-roster/agents/` — a path that decision
deliberately removed — so merging it as-is would silently reverse a
governance decision. Its *content* is good; its *paths and version numbers*
are stale.

This is the highest-value branch in the repo. It fixes two live defects in
`CLAUDE.md.template`, the master file every other project copies.

### LAND — verified still missing from `main`

1. **`executor` worktree isolation.** `main`'s
   `agent-bodies-reference/executor.md` opens with *"running in your own git
   worktree with fresh context"* — but carries no `isolation: worktree` key,
   so nothing provides one. The agent's self-description is false in
   deployment. The branch adds the frontmatter key plus a body paragraph
   explaining the harness provides the worktree.
   **Replay into `agent-bodies-reference/executor.md`, not `dcoe-roster/agents/`.**

2. **`CLAUDE.md.template` worktree section.** `main` still carries the
   defect at lines 191–193: *"Executors run in a shared session by default —
   confirm the executor agent's first action `cd`s into its assigned
   worktree path."* Per the branch's finding, `cd` does not persist between a
   subagent's Bash calls, so that instruction produces executors that
   silently edit the main checkout. This is **actively wrong guidance in the
   master template.**

3. **`CLAUDE.md.template` HOOKS section.** `main`'s table (lines 287–293)
   lists trigger names that are not real Claude Code events — "git commit",
   "Agent stops", "New session" — and states *"Hook configs:
   `.claude/hooks/`"*, which is wrong: hooks register in
   `.claude/settings.json`. The branch maps every gate to its real event and
   matcher.

4. **`hub-template/hooks/`** — `secret-scan.sh` (PreToolUse, exit-2 block on
   Supabase/JWT/AWS/GitHub-PAT/private-key patterns), `auto-format.sh`
   (PostToolUse), `settings-hooks-snippet.json`, and a README. Self-contained,
   vault-agnostic, no dependency on the stripped path. Clean land.
   **Caveat:** these are bash scripts and both machines are Windows. They need
   git-bash, or PowerShell equivalents. Flag at rollout, not now.

5. **`docs/research/claude-code-config-audit.md`** (269 lines) and
   **`docs/specs/2026-07-21-config-audit-week1-fixes.md`** — land as-is, both
   marked historical (audited against Claude Code v2.1.212, 18 days old).

6. **`Explore` agent — land, but gated on re-verification.** The claim is
   that Claude Code's built-in Explore stopped defaulting to Haiku at
   v2.1.198 and now inherits the session model, so grep-tier work bills at
   Sonnet 5. If true it costs money daily. It is 18 days old and was never
   tested against a current install. **Re-verify before landing;** if the
   behaviour has reverted, land nothing here — an unnecessary override is its
   own maintenance burden. Destination is
   `agent-bodies-reference/explore.md`.

7. **The three `docs/todo.md` Done entries** for the above, reworded to match
   what actually lands.

### DROP

- **`dcoe-roster/agents/` as a path.** Reversed by the 2026-07-29 strip.
  Every agent change above is replayed into `agent-bodies-reference/`.
- **The branch's `marketplace.json` edit.** It updates the description but
  still lists the agents as shipped — correct in July, wrong now. Superseded
  by plan Phase 4.1, which rewrites that field properly.
- **The branch's `dcoe-roster/plugin.json` 3.4.0 bump.** Collides — see below.

### Version collisions (all three must be renumbered)

| Artifact | Branch assigns | `main` already used it for | Must become |
|---|---|---|---|
| `CLAUDE.md.template` | v3.3 | codex-gate (2026-07-21) | **v3.4** |
| `dcoe-roster/plugin.json` | 3.4.0 | the agent-body strip (2026-07-29) | **3.5.0** |
| `dcoe-roster/CORE.md` | 1.1 | `main` is at 1.2 | **1.3** |

The template collision is the dangerous one: two different documents both
labelled v3.3, distributed to both machines, with no way to tell which one a
project actually has.

-----

## Branch 2 — `continuation-utn4f5`

**Verdict: land nearly whole.** Highest-quality branch of the three, only
3 days old, small conflict surface. Recommended first execution target.

### LAND

1. **`agent-bodies-reference/bootstrap.sh`** — **this closes open todo item
   #2 outright.** Idempotent, `set -euo pipefail`, copies only the 9 named
   files, warns before overwriting a differing destination, rerun-safe error
   messages. Already carries a reviewer fix (commit `804e45f`).
   **Dependency:** if Branch 1's `Explore` lands, `bootstrap.sh` needs
   `explore.md` as a 10th entry, and its closing message ("9 roster agents")
   updates to 10. Land Branch 2 first, then patch it in Branch 1's commit —
   do not try to sequence around it.
   **Caveat:** bash on Windows machines, same as the hooks.

2. **`docs/specs/2026-08-05-json-validation-hook.md`** — land as **Draft, not
   implemented.** It is already codex-reviewed and carries a revision
   history; landing it preserves that work. It proposes a `.githooks/pre-commit`
   enforcing repo hard rule 3, which is currently self-monitored only.
   Implementation is a separate, later decision.

3. **`CLAUDE.md` SESSION START roster drift check** — warns when
   `~/.claude/agents/` is missing any of the 9 files, pointing at
   `bootstrap.sh`. Pairs directly with item 1.

4. **`hub-template/session-end.md` reusable-fact question** — three lines
   making the knowledge-cache prompt explicit rather than implied. Minor
   conflict expected against PR #11/#12's edits to the same file.

5. **The `docs/todo.md` ADR-010 correction — this is the plan's Phase 3.1
   fix, already written.** It corrects the false claim, dates ADR-010 to
   2026-08-05 (not 2026-08-04), and records *how* the error was caught (the
   Reviewer Loop on the command-center spec's Gap 3, verified against the
   filesystem). Use this wording rather than re-deriving it.
   **Note:** it only becomes true once the hub actually has ADR-010 — that is
   hub Phase 2.2, tracked in the hub triage. Land the correction and the hub
   file in the same pass, or the entry is still wrong, just differently.

### DROP

Nothing.

-----

## Branch 3 — `repo-status-update-n5z63h`

**Verdict: partial — extract four things, discard the rest.** 20 days old
and largely superseded: it is the branch that *originally created* this
repo's `/continue`, which `main` has since taken over and improved.

### LAND

1. **`hub-template/retro.md`** — genuinely new, no equivalent anywhere on
   `main`. The backward-looking counterpart to `/continue`: reviews a vault's
   todo/session-log for *framework* friction (a session redoing settled work,
   Tebello having to correct something already decided, a stale-external-state
   assertion) and proposes a confirmable batch of fixes. Vault-agnostic,
   copy-in-verbatim, same treatment as `continue.md`.
   Given this systems check found sixteen stranded branches and a false Done
   entry, a command that specifically hunts recurring framework failure is
   well aimed.

2. **`HUB-CHECKLIST.md` retro item** — installs `retro.md` into a vault.
   Lands only if item 1 lands.

3. **CORE.md "verify remote state before asserting it"** — before reporting
   repo/PR/branch status or proposing an action conditioned on it, fetch and
   check; never answer from a cached ref. Generalises beyond git to any
   external state a session doesn't solely control.
   **Lands as hard rule 10, not 9** — `main` gave 9 to codex-review. Fold
   into the single CORE 1.3 bump alongside Branch 1's routing changes rather
   than bumping twice.

4. **The mobile-surface gap note** — typing `/continue` returns *"isn't
   available in this environment"* on a Default-type session in the mobile
   app, though the same file works via the Skill tool in a web session.
   Workaround: ask in plain text. **Land in `hub-template/continue.md` only,
   refreshed** — the note is dated 2026-07-19 and still says desktop CLI is
   unconfirmed. Do not propagate an unverified note into four files.

### DROP

- **`.claude/commands/end-session.md`** — superseded by
  `.claude/commands/session-end.md` (PR #10, ADR-010). Two commands doing one
  job is exactly the drift this plan exists to remove.
- **`docs/session-log.md`** — this repo deliberately keeps no session log;
  both command instances say so explicitly. Rejected by later design.
- **`.claude/commands/continue.md`** — `main`'s version is strictly newer
  (PR #12's frontmatter fix plus the current preamble). The branch's
  frontmatter fix was independently made by PR #12.
- **`docs/todo.md`** — an entirely different structure ("Task Queue")
  that `main` replaced. Discard the file, salvage three still-live open items
  below.
- **The README "Maintaining this repo" section** — documents the
  `continue`/`end-session` pair. Only reusable if reworded to `session-end`;
  low value, recommend dropping.

### Salvage into `docs/todo.md` Open

- Confirm whether the desktop CLI has the same slash-command restriction as
  the mobile app. If yes, the gap note is a much bigger deal than currently
  written.
- Install `retro.md` at `Operations/.claude/commands/retro.md` via
  `HUB-CHECKLIST.md` (hub-side, machine-bound).
- Assign an ADR number for the verify-remote rule in the hub's
  `docs/decisions/`.

-----

## Deletions (no content at risk)

- **`continuation-yon8p3`** — shows unmerged by ancestry, but its files are
  byte-identical to `main`; content landed by another path. Verified with a
  full diff. Safe to delete.
- **The 8 already-merged branches** — `code-plugins-comparison-ofwn40`,
  `codex-gate-readiness-audit-7oym2i`, `continuation-l5o31x`,
  `new-session-jrgn3o`, `ops-pappa-t-mobile-platform-2kcvic`,
  `repo-status-update`'s merged predecessors, `session-toojf0`,
  `usage-n96pfg`.

-----

## Recommended execution order for Phase 2.1

1. **Branch 2** — mostly clean, closes an open todo item, and its ADR-010
   correction is needed by Phase 3.1.
2. **Branch 3's four keeps** — independent of everything else; the CORE rule
   waits for step 4.
3. **Branch 1's non-agent parts** — hooks, research doc, week-1 spec,
   template rewrites at **v3.4**.
4. **Branch 1's agent parts + one combined CORE 1.3 bump** — `executor`
   isolation, `Explore` (if re-verified), the Explore roster row, and Branch
   3's rule 10, in a single CORE edit. Patch `bootstrap.sh` to 10 agents in
   the same commit.
5. **Delete every branch** listed above.

Steps 3 and 4 change what both machines install, so they need a rollout pass
afterward — `/plugin marketplace update` + `/plugin update` + `/reload-plugins`
on Operations and Pappa T, plus re-running `bootstrap.sh`.

## Open questions for Tebello

1. **Explore/Haiku** — worth re-verifying against a live install before
   landing, or drop the override entirely?
2. **`retro.md`** — keep as a hub-template command, or is `/continue` +
   `/session-end` already enough surface?
3. **Bash-on-Windows** — `bootstrap.sh`, `secret-scan.sh`, `auto-format.sh`
   all assume bash. Ship as-is and rely on git-bash, or add PowerShell
   equivalents?
4. **`docs/research/`** — this repo has no such folder today. Create it for
   the config audit, or move that document under `docs/specs/`?
