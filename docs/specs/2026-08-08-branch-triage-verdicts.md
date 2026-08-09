# Branch triage verdicts — Phase 1 (both repos)

**Date:** 2026-08-08
**Status:** Awaiting owner approval — no branch merged or deleted until approved
**Plan:** `docs/specs/2026-08-08-system-maintenance-plan.md`, Phases 1.1 + 1.2
**Method:** every verdict below is based on reading the branch's actual file
contents against current `main` (fetched 2026-08-08), not on commit messages.

Part 1 covers `tlelosa-claude-config` (3 branches). Part 2 covers the
`Claude-Code` hub (13 branches).

> **Both counts are wrong — see the 2026-08-09 amendment at the foot of this
> file.** The live figures are **4** config-repo branches and **14** hub
> branches. Work from the amendment's tables, not from these two numbers or
> from the Part 2 summary table, when acting on the deletion item.

-----

# Part 1 — `tlelosa-claude-config` (Phase 1.1)

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

-----

# Part 2 — `Claude-Code` hub (Phase 1.2)

## Method correction

The plan warned not to assume all 13 branches carry lost work. That warning
was right, and the first measurement was misleading: diffing each branch
against its **merge-base** showed 43,000-line deltas across ~290 files,
which looks catastrophic. It isn't. `main`'s tip is a 68-commit vault
re-merge, so those diffs mostly show content that has *since* landed by
another path.

The reliable test is diffing **`main` against the branch** and counting only
what the branch adds. Every branch turns out to be far *behind* `main`
(2,800–5,600 lines), each carrying a small unique residue:

| Branch | Lines `main` lacks | Lines behind `main` | Verdict |
|---|---|---|---|
| `continuation-utn4f5` | 649 | 2,854 | **Extract 3 files** |
| `total-race-count-indicator-keqb18` | 277 | 2,871 | **Extract 3 items** |
| `session-end-archive-afo043` | 253 | 2,853 | **Superseded** by utn4f5 |
| `pwa-component-driver-app-ysxe8a` | 245 | 2,869 | **Extract 1 file** |
| `reddit-article-claude-sessions-yefxfd` | 232 | 3,988 | **Extract 1 file** |
| `repo-update-check-mn1wv2` | 155 | 1,546 | **Extract 1 item** |
| `continuation-sqlkfd` | 134 | 4,747 | **Delete** |
| `continuation-cl1tel` | 102 | 5,410 | **Delete** |
| `repo-knowledge-insights-62s4xj` | 94 | 4,367 | **Delete** |
| `continuation-tmc4e6` | 85 | 5,077 | **Delete** |
| `environment-update-process-c1zn1a` | 83 | 3,990 | **Delete** |
| `continuation-bpj3tw` | 67 | 5,256 | **Delete** |
| `continuation-s2a36h` | 21 | 5,634 | **Delete** |

**Seven of thirteen carry nothing worth keeping.** Their residue is entirely
*older* `knowledge/INDEX.md` rows and stale `docs/todo.md` / `docs/session-log.md`
state that `main` has since superseded with richer versions — e.g. a branch's
`tlelosa-claude-config.md` index row dated 2026-07-28 against `main`'s much
fuller row dated 2026-08-08. Landing them would move the cache backwards.

Spot-checked to be safe: the seven `docs/specs/2026-07-29-*.md` files that
appear across three of these branches are all already on `main`, as is the
Ollama `READ_TIMEOUT` finding in `knowledge/ai-outreach-agency.md`.

## Confirmed lost work — six extractions

### 1. `docs/decisions/ADR-010-session-end-command.md` — **the highest priority**

Exists on two branches in two versions. **Take `continuation-utn4f5`'s
(111 lines), not `session-end-archive-afo043`'s (86 lines)** — the former is
the deliberate 2026-08-05 rewrite whose commit is titled "Write ADR-010 for
real," made after a prior session discovered the first version's claims were
premature.

This is the file `tlelosa-claude-config/docs/todo.md` already asserts exists.
Landing it is what makes that Done entry true, and it gates config-repo
Branch 2's todo correction.

### 2. The command-center initiative — fully built, entirely stranded

`docs/specs/2026-08-05-command-center.md` (286 lines) and
`.claude/commands/overwatch.md` (175 lines), both on `continuation-utn4f5`.

This one deserves attention beyond its line count. The spec is an
owner-scoped, `AskUserQuestion`-confirmed initiative from 2026-08-05
addressing three named gaps, with a locked build order. **All three gaps were
built, across two repos, and not one landed:**

| Gap | Deliverable | Stranded on |
|---|---|---|
| 1 — no single status view | `/overwatch` command | hub `continuation-utn4f5` |
| 2 — roster bootstrap gap | `bootstrap.sh` | config `continuation-utn4f5` |
| 3 — knowledge cache goes stale | session-end reusable-fact prompt | config `continuation-utn4f5` |

A complete, approved, three-part piece of work finished and lost. Recovering
it is the single largest value item in this triage, and it is the sharpest
evidence for why the plan's Phase 6 matters.

`/overwatch` is read-only by contract (never writes, edits, or commits) and
aggregates open items across the hub, every sub-project, and the config repo.
Land it with the spec, marked Gap 1 complete and Gaps 2–3 landing alongside
the config-repo branch.

### 3. `knowledge/claude-code-sessions.md` (79 lines)

From `reddit-article-claude-sessions-yefxfd`. Claude Code internals: the
`~/.claude/projects/` path/encoding scheme. Not on `main`; no `INDEX.md` row.

### 4. `knowledge/cloud-sessions.md` (71 lines)

From `total-race-count-indicator-keqb18`. Agent-proxy host blocking, and
specifically that **HTTP 000 is not an empty page** — exactly the kind of
gotcha that costs an hour when re-derived. Directly relevant to sessions like
this one.

### 5. `knowledge/pitcrew-sync.md` (95 lines)

From `pwa-component-driver-app-ysxe8a`. PitCrew Sync, the third F1 Clash
sibling PWA, including that it lives in the `RMLRACE` org and not
`tlelosa-web` — a fact that will otherwise be re-derived by anyone looking
for the repo.

### 6. Two entries appended to existing knowledge files

- **`knowledge/cratetracker.md`** (from `keqb18`) — "Cache-busting isn't
  enough: the SW update prompt." Bumping `CACHE_VERSION` was necessary but
  never sufficient; with the old cache-first worker a deploy needed *two* app
  opens to appear. The entry records that the gap cost a full debugging round.
- **`knowledge/pitwall-companion.md`** (from `mn1wv2` and `keqb18`) — the
  cache-busting rule was documented and then **missed three times in a row**
  across consecutive PRs, plus the `tlelosa-web` → `RMLRACE` repo move.

Both are append-only additions to files `main` already has — low-risk, and
they are the highest-signal kind of knowledge entry: a documented rule that
was written down and then not followed.

## Explicit deletions

- **7 branches** with no unique content: `continuation-sqlkfd`,
  `continuation-cl1tel`, `repo-knowledge-insights-62s4xj`,
  `continuation-tmc4e6`, `environment-update-process-c1zn1a`,
  `continuation-bpj3tw`, `continuation-s2a36h`.
- **`session-end-archive-afo043`** once ADR-010 is taken from `utn4f5`.
- **`cloud-env-overview-setup-ymv1vd`** — already merged.
- The 5 source branches above, after their extractions land.

**Do not merge any of these branches.** Every one is thousands of lines
behind `main`; a merge risks reverting current content. Extract the named
files and entries onto a fresh branch cut from `main`, then delete.

## Recommended execution order for hub Phase 2.2

1. **ADR-010** from `utn4f5` — unblocks config Phase 3.1.
2. **The three missing `knowledge/` files** + the two appended entries, with
   their `INDEX.md` rows in the same commit (hub hard rule: index and file
   move together).
3. **Command-center spec + `/overwatch`**, coordinated with the config repo's
   `bootstrap.sh` so all three gaps land together and the spec can be marked
   complete rather than partially done.
4. **Delete all 13 branches.**

Note the hub's own contention-file rule: `docs/todo.md`, `docs/session-log.md`,
and `knowledge/INDEX.md` are touched by nearly every session and have already
caused two real conflicts. Fetch and pull immediately before each commit
above, not once at the start.

## Open questions for Tebello

5. **`/overwatch`** — still wanted? It was scoped and built on 2026-08-05 and
   has sat unmerged since. If the command-center goal has moved on, say so and
   the spec lands as historical rather than as live work.
   **Answered 2026-08-09 — see the amendment: it landed.**
6. **Two ADR-010s** — confirm taking `utn4f5`'s 111-line version. It contradicts
   the 86-line one on dates and on what existed when.
   **Answered 2026-08-09 — see the amendment: `utn4f5`'s version landed.**

-----

# Amendment — 2026-08-09: count reconciliation

`docs/todo.md` carried an open item noting that this spec records 3 held-open
config-repo branches while a 2026-08-09 check found 4. Both repos were
re-measured today against freshly fetched refs. **4 and 14 are correct;** this
spec's 3 and 13 are not, for four separate reasons set out below.

**Method.** Two measurements per branch, both against `origin/main` fetched
2026-08-09 (never against a merge-base — that is this file's own rule 1):
ancestry via `git merge-base --is-ancestor`, and *files present on the branch
and absent from `main`*. The second number is the one that matters: it is what
would actually be lost on deletion. It does **not** count edits to files `main`
already has, so a zero there means no new file is at risk, not that the branch
is byte-identical.

## Part 1 — config repo: 4, not 3

All four branches from the original summary table still exist. The headline
"3 branches" excluded `continuation-yon8p3` because its verdict was Delete —
but a branch with a delete verdict that was never deleted is still a live
branch, and the deletion item has to name it.

| Branch | Age | Ahead | Files `main` lacks | What they are |
|---|---|---|---|---|
| `repo-status-update-n5z63h` | 21d | 5 | 12 | 9 stripped agents + `end-session.md` + `session-log.md` + **`hub-template/retro.md`** |
| `config-audit-gap-report-aew9g7` | 19d | 5 | 10 | all `dcoe-roster/agents/*` |
| `continuation-yon8p3` | 14d | 5 | 9 | all `dcoe-roster/agents/*` |
| `continuation-utn4f5` | 4d | 6 | **0** | — fully recovered by Phase 2 |

**`hub-template/retro.md` is the only unlanded file across all four.** Every
other unique file is either `dcoe-roster/agents/*` — the path the 2026-07-29
strip deliberately removed, so re-adding it would reverse a governance
decision — or a file this repo decided against (`end-session.md`, superseded by
`session-end.md`; `session-log.md`, which this repo deliberately keeps none of).
That leaves exactly one open question gating all four deletions, and it is
already in the queue: **is `retro.md` wanted?** Answer it and all four go.

**Correction to `continuation-yon8p3`'s verdict.** The stated reason — "its
files are byte-identical to `main` … verified with a full diff" — was wrong
when written, not merely stale: the branch carries 9 `dcoe-roster/agents/`
files that `main` had already dropped on 2026-07-29, a week before the triage.
The verdict itself (safe to delete) stands; only the reason changes, to the
same one as `config-audit-gap-report-aew9g7` — its unique content is a
deliberately-removed path.

## Part 2 — hub: 14, not 13

Three separate movements since 2026-08-08, netting +1:

1. **`continuation-utn4f5` is gone** (−1). Its content landed on `main` and the
   branch was deleted: ADR-010 via `1517c7f`, `/overwatch` plus the
   command-center spec via `b7ceebb` (2026-08-09). This closes open questions
   5 and 6 above and completes the three-part command-center initiative this
   file called "the single largest value item in this triage" — all three gaps
   are now on `main` in their respective repos.
2. **`cloud-env-overview-setup-ymv1vd` was mislabelled** (+1). The Deletions
   section lists it as "already merged"; it is **not** an ancestor of `main`.
   It carries 0 files `main` lacks, so the Delete verdict stands unchanged —
   but it belongs in the held count, and a reader working from "already merged"
   would leave it behind.
3. **`pr-template-linear-planning-40hnrd` is new** (+1), created 2026-08-09,
   after this triage. See below.

12 of the original 13 remain, all carrying **0 files `main` lacks**. So do
`cloud-env-overview-setup-ymv1vd` and every other hub branch — with one
exception.

### The exception: the hub's PR template never landed

`claude/pr-template-linear-planning-40hnrd` is 1 commit ahead and holds
`.github/pull_request_template.md` — **the only file across all 14 hub branches
that `main` does not have.** The hub has no `.github/` directory at all.

`docs/specs/2026-08-09-pr-templates.md` specifies a template for *both* repos
and `docs/todo.md` records it Done for both. The config-repo half merged as
PR #16; the hub half did not. The Done entry is currently half-true — the same
failure mode, on the same day, that Phase 6's branch checks were built to
catch. Recorded as its own open item rather than fixed here, since this
amendment is a record correction and landing a file in another repo is not.

## Net effect on the deletion item

The queue's deletion item reads "3 config-repo branches and 13 hub branches."
It should read **4 and 14**, and the hub's 14 must not include the PR-template
branch until that file lands — deleting it would strand the only unique file
either repo has left, plus `retro.md` here.

-----

# Deletion sheet — hub's 14, cleared 2026-08-09

The PR template landed (hub `main` `8a3fd14`), so the one exclusion above is
released. All 14 hub branches were re-measured against `main` **after** that
merge and every one carries **0 files `main` lacks**. They are cleared to
delete.

**A cloud session cannot do it.** `git push origin --delete` returns HTTP 403
from GitHub for all 14. This is not the egress policy — the proxy's
`recentRelayFailures` is empty and ordinary pushes to the same remote succeed —
it is the session's git credentials, which can create and update refs but not
delete them. The GitHub MCP server available here exposes `create_branch` and
`list_branches` but no delete-ref tool. So this step needs a machine with full
credentials, or the GitHub web UI.

Tips recorded below because **a deleted branch is recoverable only if its SHA
was written down** — `git push origin <sha>:refs/heads/<name>` restores any of
them until GitHub garbage-collects. Verified against hub `main` `8a3fd14`.

| Branch (`claude/…`) | Tip | Last commit |
|---|---|---|
| `continuation-s2a36h` | `9c7f010b` | 2026-07-26 |
| `continuation-tmc4e6` | `1789efb2` | 2026-07-28 |
| `continuation-cl1tel` | `2c1d2967` | 2026-07-28 |
| `continuation-sqlkfd` | `e2f4dac6` | 2026-07-28 |
| `continuation-bpj3tw` | `edcb9c04` | 2026-07-28 |
| `environment-update-process-c1zn1a` | `0553aa0c` | 2026-07-29 |
| `repo-knowledge-insights-62s4xj` | `7c4ddb00` | 2026-07-29 |
| `reddit-article-claude-sessions-yefxfd` | `e3f3c43c` | 2026-07-30 |
| `cloud-env-overview-setup-ymv1vd` | `87f9506f` | 2026-08-01 |
| `session-end-archive-afo043` | `a328d22e` | 2026-08-04 |
| `pwa-component-driver-app-ysxe8a` | `1b931991` | 2026-08-05 |
| `repo-update-check-mn1wv2` | `5aebd259` | 2026-08-06 |
| `total-race-count-indicator-keqb18` | `630039e4` | 2026-08-07 |
| `pr-template-linear-planning-40hnrd` | `580f3d32` | 2026-08-09 |

Run from a `Claude-Code` clone on Operations or Pappa T:

```bash
git fetch origin --prune
git push origin --delete \
  claude/continuation-s2a36h claude/continuation-tmc4e6 \
  claude/continuation-cl1tel claude/continuation-sqlkfd \
  claude/continuation-bpj3tw claude/environment-update-process-c1zn1a \
  claude/repo-knowledge-insights-62s4xj \
  claude/reddit-article-claude-sessions-yefxfd \
  claude/cloud-env-overview-setup-ymv1vd claude/session-end-archive-afo043 \
  claude/pwa-component-driver-app-ysxe8a claude/repo-update-check-mn1wv2 \
  claude/total-race-count-indicator-keqb18 \
  claude/pr-template-linear-planning-40hnrd
```

Do **not** add `claude/continuation-wn1egp` to that list — it is the current
working branch and points at `main`.

Re-run the measurement first if any time has passed, since `main` moves:

```bash
comm -13 <(git ls-tree -r --name-only origin/main | sort) \
        <(git ls-tree -r --name-only origin/<branch> | sort)
```

A non-empty result means that branch gained something `main` lacks — stop and
re-triage it rather than deleting.

The config repo's own 4 are **not** cleared: `hub-template/retro.md` on
`repo-status-update-n5z63h` is still the one unlanded file, and that decision
gates all four.
