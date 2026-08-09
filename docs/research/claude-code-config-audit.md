# Config audit — CLAUDE.md v3.2 (+ AGENTS.md) vs Claude Code v2.1.212


> **Status (2026-08-08):** historical. Audited against Claude Code v2.1.212
> on 2026-07-21 and recovered from an unmerged branch on 2026-08-08 — the
> version-specific claims below have not been re-verified against a current
> install. Re-check before acting on any of them.
**Date:** 2026-07-21 · **Role:** read-only config-audit review · **Auditor:** Claude (DCOE reviewer role)
**Scope:** `CLAUDE.md.template` (v3.2, the master template for MIMS App, IQ, TebelloReborn, Tenders),
`dcoe-roster/CORE.md` (v1.0), roster agent frontmatter, `.claude/commands/continue.md`, and the
(nonexistent) `AGENTS.md`.
**Verified against:** code.claude.com/docs — `skills`, `hooks`, `sub-agents`, `memory` pages
(fetched 2026-07-21), plus live harness behavior in this session. Version markers cited
(v2.1.186–v2.1.212) come from the docs' own min-version annotations.

**Headline:** nothing in the config is broken today — `.claude/commands/` files still work, model
names are still current. But three sections now describe a Claude Code that no longer exists:
the executor "shared session + cd into worktree" rule (subagents can't do that anymore), the
Haiku search tier (Explore stopped defaulting to Haiku in v2.1.198 and nothing in the roster
implements the tier), and the HOOKS section (all four hooks are aspirational — no
`settings.json` wiring exists, yet HARD RULE 3 claims "Hooks enforce this").

---

## 0. AGENTS.md — does not exist, and that's (mostly) correct

There is **no `AGENTS.md`** in this repo or in the template's directory layout. Current fact:
**Claude Code reads `CLAUDE.md`, not `AGENTS.md`** — no native support. The documented pattern
for repos that need both is to keep `AGENTS.md` as the cross-tool source and have `CLAUDE.md`
start with an `@AGENTS.md` import (or a symlink). `/init` only ingests `AGENTS.md` when
`CLAUDE_CODE_NEW_INIT=1` is set.

**Verdict: KEEP (no file).** Your projects are single-agent (Claude Code only); adding
AGENTS.md would just create a second file to keep in sync. Revisit only if a project adopts a
second coding agent — then split: facts into `AGENTS.md`, Claude-specific workflow (DCOE,
hooks, model routing) stays below the import in `CLAUDE.md`.

---

## 1. Commands → skills migration

**Verified current behavior:** "Custom commands have been merged into skills. A file at
`.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create
`/deploy` and work the same way. Your existing `.claude/commands/` files keep working."

**What breaks if you don't migrate: nothing.** Proof: this repo's own
`.claude/commands/continue.md` surfaced as an invocable `/continue` skill in this very session.
Migration is about gaining features, not avoiding breakage:

| Skill-only feature | Why it matters for your setup |
|---|---|
| `disable-model-invocation: true` | Stops Claude auto-triggering workflow commands. `/plan` and `/build` are exactly the "you decide when" type (like the docs' `/deploy` example). |
| `context: fork` + `agent:` | Runs the skill in a subagent — `/build` could fork straight into the orchestrator flow. |
| Directory for supporting files | Checklists/templates load only when invoked (cheaper than CLAUDE.md). |
| Auto-load when relevant | Claude can pull a skill in without you typing `/name`. |
| `$ARGUMENTS[0]` / `$0` positional args | Cleaner than prose argument conventions. |

**Command → skill map:**

| Today | Migrate to | Frontmatter |
|---|---|---|
| `/plan` (referenced at `CLAUDE.md.template:202`, no file in template tree) | `.claude/skills/plan/SKILL.md` | `disable-model-invocation: true` |
| `/build` (referenced at `CLAUDE.md.template:204`) | `.claude/skills/build/SKILL.md` | `disable-model-invocation: true` |
| `.claude/commands/continue.md` (this repo) | `.claude/skills/continue/SKILL.md` | `disable-model-invocation: true` (it's a session-control workflow) |
| `hub-template/continue.md` (skeleton other vaults copy) | ship as a skill folder skeleton | same |

Also: `CLAUDE.md.template:389` documents `commands/ ← Custom slash commands` in the directory
tree with no mention of `skills/`. **Verdict: UPDATE** (template text, S effort); **migrate
files opportunistically** — per-machine Claude Code versions all post-date the merge, so
there's no compatibility reason to rush.

---

## 2. Background subagents (v2.1.198+) vs the worktree/executor rules

**Verified current behavior:**

- As of **v2.1.198 subagents run in the background by default**; Claude runs one in the
  foreground only when it needs the result before continuing. Permission prompts from
  background subagents surface in the main session (v2.1.186+).
- Inside a subagent, **`cd` does not persist between Bash tool calls** and doesn't affect the
  main conversation's working directory.
- The supported isolation mechanism is **`isolation: worktree`** frontmatter: the subagent gets
  a temporary git worktree, **branched from the default branch (not the parent session's
  HEAD)**, auto-cleaned if it makes no changes. Since v2.1.203 its shell commands are *forced*
  to run inside the worktree (commands resolving to the main checkout fail).
- Since v2.1.211, the parent waits for the completion notification before reporting a
  background subagent's results (no more premature "done" reports).
- Committing/pushing/opening draft PRs: an executor with Bash can commit in its worktree
  (permissions willing). The "opens draft PRs on its own" behavior belongs to **background
  agents** (separate parallel sessions, agent-view/cloud) — a different feature from in-session
  subagents. Your Orchestrator flow uses in-session subagents, so PRs are not spontaneous.

**Reconciliation with your rules:**

| Rule | Status |
|---|---|
| "Executors run in a shared session by default — confirm the executor agent's first action `cd`s into its assigned worktree path" (`CLAUDE.md.template:191-193`) | **CONTRADICTED, twice.** Executors are subagents → own context, not a shared session; and the `cd`-first instruction is now a no-op because `cd` doesn't persist across a subagent's Bash calls. This rule, followed literally, produces executors that silently edit the main checkout. Replace with `isolation: worktree` on the executor agent. |
| Manual `git worktree add` block (`CLAUDE.md.template:173-183`) | **UPDATE.** Still valid for human-driven parallel branches, but for agent executors `isolation: worktree` supersedes it. Caveat to document: the auto-worktree branches from the **default branch**, so an executor building on an unmerged feature branch needs the manual flow or a pushed base. |
| "Orchestrator reviews and integrates; never commits unreviewed code" (`CLAUDE.md.template:189`) | **KEEP — not contradicted.** Background-by-default changes *when* results arrive, not *who merges*. The v2.1.211 wait-for-notification fix actually strengthens this gate. |
| "One agent per worktree" / atomic commit rules (`:186-188`) | **KEEP.** `isolation: worktree` enforces the first one mechanically. |
| Orchestrator "Context stays < 40%" (`:91`) | **KEEP.** Background default helps: results return as summaries. |
| HARD RULES 7/8 (`:438-439`, specialists / orchestrator routes) | **KEEP.** No conflict. |
| `dcoe-roster/agents/executor.md:3` says "in an isolated git worktree" but has no `isolation: worktree` frontmatter | **UPDATE** — the description promises isolation the config doesn't deliver. One frontmatter line fixes it. |

**Why it matters for your projects:** MIMS App is the one running parallel executors against a
live Next.js/Supabase checkout — an executor that thinks it's in a worktree but is actually in
the main checkout can clobber the working tree mid-review. This is the highest-severity gap in
the audit.

---

## 3. Hooks coverage

**Verified event list (July 2026):** `SessionStart`, `Setup`, `SessionEnd`, `UserPromptSubmit`,
`UserPromptExpansion`, `Stop`, `StopFailure`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`,
`PostToolBatch`, `PermissionRequest`, `PermissionDenied`, `SubagentStart`, `SubagentStop`,
`PreCompact`, `PostCompact`, `Notification` (matchers incl. `agent_completed`,
`agent_needs_input`, `permission_prompt`), `InstructionsLoaded`, `ConfigChange`, `FileChanged`,
`WorktreeCreate`/`WorktreeRemove`, MCP `Elicitation` events, `MessageDisplay`, plus team/task
events. Hooks are **registered in `settings.json`** (`hooks` key) — `.claude/hooks/` is only
where scripts live, so `CLAUDE.md.template:292` ("Hook configs: `.claude/hooks/`") is
misleading as written.

**Your 4 hooks vs reality** (`CLAUDE.md.template:285-291`): none of the four names
(`pre-commit`, `pre-push`, `post-task`, `session-start`) is a Claude Code event, and no
`settings.json` wiring ships with the template — so **HARD RULE 3 (`:434`) "Tests must pass
before any commit. Hooks enforce this." is currently enforced by nothing.** Mapping:

| Your hook | Real mechanism |
|---|---|
| `pre-commit` (lint+format gate) | `PreToolUse`, matcher `Bash`, `if: "Bash(git commit*)"` → exit 2 blocks the commit with stderr fed back to Claude. (Plain git `pre-commit` hooks also still work and cover human commits too — worth keeping both.) |
| `pre-push` (full test suite) | `PreToolUse` on `Bash(git push*)`, or a git `pre-push` hook. |
| `post-task` (log to session-log.md) | `SubagentStop` (fires per executor; matcher = agent name) and/or `Stop` for main-session turns. |
| `session-start` (load todo.md) | `SessionStart` → emit `hookSpecificOutput.additionalContext` with the todo contents — stronger than the current CLAUDE.md "please read it" instruction. |

**High-value additions for a Supabase + Python vault (ADD, in priority order):**

1. **Secret scan on shell — `PreToolUse` matcher `Bash`** (and `Edit|Write` for file content).
   Deny via `permissionDecision: "deny"` when the command/content matches Supabase
   `service_role` keys, `SUPABASE_*` env values, or generic key patterns (gitleaks/trufflehog
   in single-string mode). MIMS App is the driver: a leaked service_role key bypasses RLS
   entirely. Impact H, effort S.
2. **Auto-format on edit — `PostToolUse` matcher `Edit|Write`**: `black`+`ruff --fix` for
   IQ/TebelloReborn/Tenders, `prettier`/`eslint --fix` for MIMS. Non-blocking (tool already
   ran); matches your stated philosophy at `CLAUDE.md.template:294-296` — hints during work,
   walls at commit. Impact M, effort S.
3. **Test-on-Stop — `Stop` event** with `decision: "block"` + reason on failure, which forces
   Claude to keep going and fix red tests before ending its turn. Keep it to the *fast* tier
   (ruff + changed-file pytest / `tsc --noEmit`) — full suites stay at pre-push, or Stop hooks
   will make every turn crawl. Impact H, effort M.
4. **`Notification` matcher `agent_completed|agent_needs_input`** → OS toast/`terminalSequence`
   bell. This is the direct companion to §2: with executors backgrounded by default, this is
   how you notice one finished or stalled on a permission prompt. (Note the real matcher is
   `agent_needs_input`, not `needs_input`.) Impact M, effort S.

Also worth knowing (no action): `PostToolUseFailure`, `PreCompact` (snapshot todo.md before
compaction), and `WorktreeCreate` (custom worktree paths) exist and fit DCOE well later.

---

## 4. Model routing

**Verified naming (July 2026):** `claude-sonnet-5`, `claude-opus-4-8`, `claude-haiku-4-5` are
all current — full IDs in agent frontmatter (`dcoe-roster/agents/*.md:5`) are valid, and the
short aliases `sonnet` / `opus` / `haiku` / `fable` now also work. **KEEP** the Sonnet 5
default / Opus 4.8 evidence-based escalation (`CORE.md:97-121`, `CLAUDE.md.template:141-164`)
— it matches current tiering exactly. Two flags:

- **Haiku search tier is silently unimplemented.** `CORE.md:118` / `CLAUDE.md.template:158`
  assign "Search / grep only → `claude-haiku-4-5`", but (a) no roster agent sets a Haiku model,
  and (b) as of **v2.1.198 the built-in Explore agent no longer defaults to Haiku** — it
  inherits the main conversation's model (capped at Opus). So every "search-only" task your
  template routes through Explore (`CLAUDE.md.template:240,312`) now burns Sonnet 5. The
  documented fix: a user/project agent named `Explore` overrides the built-in and keeps its own
  `model: haiku`. **UPDATE:** add an `Explore` override (or a `searcher` roster agent) with
  `model: claude-haiku-4-5`, and note the v2.1.198 behavior change in both routing tables.
- **Minor:** a `fable` tier now exists above Opus. No action — Opus 4.8 remains the right
  escalation ceiling for your cost profile — but the "Opus is earned" rule could gain a
  parenthetical so a future session doesn't self-escalate to Fable.
- **Housekeeping:** `CLAUDE.md.template:164` (bulk jobs "before 31 August 2026 — introductory
  pricing ends") is a pricing claim I could not verify in current docs; date-stamped claims
  like this rot fast — verify or delete. The Thinking-Levels table (`:449-457`) still works,
  but effort is now a first-class per-agent setting (`effort: low|medium|high|xhigh|max`
  frontmatter) — the table should point at that instead of prompt magic words.

---

## 5. Skill budget (`SLASH_COMMAND_TOOL_CHAR_BUDGET`)

**Verified mechanics:** the skill listing gets **1% of the model's context window** by default;
each entry's description is capped at 1,536 chars; when over budget, Claude Code trims
least-used skills' descriptions first and warns in `--debug` / `/doctor`. Two knobs exist:
`skillListingBudgetFraction` (modern, e.g. `0.02`) and `SLASH_COMMAND_TOOL_CHAR_BUDGET` (legacy
env var, fixed char count).

**Your numbers:** 6 shared skills with descriptions of 502–641 chars ≈ **3.6 KB total**, plus
`/continue` and the planned document-skills + Context7 installs — comfortably inside a 1%
budget on any current model. **Verdict: KEEP — do not raise it.** Setting the env var now would
be cargo-culting. Instead: (a) run `/doctor` on each machine after the document-skills/Context7
installs land (todo items) and only act if it warns; (b) if it ever does warn, prefer
`skillListingBudgetFraction: 0.02` in settings over the env var, or mark low-traffic skills
`"name-only"` via `skillOverrides`. Your per-skill descriptions are well under the 1,536 cap —
no trimming needed.

---

## 6. MCP gaps (candidates only — no installs)

Context7 is already cleared and queued (`docs/todo.md:35-38`) — good, it covers the
"current-docs lookup" gap for both stacks. Remaining candidates, ranked for YOUR stack:

| Candidate | Project fit | Notes / cautions |
|---|---|---|
| **Supabase MCP** (official) | MIMS App — schema inspection, SQL, migrations, logs, RLS-policy review without leaving the session | Run **read-only mode + project-scoped**; pairs with the §3 secret-scan hook (server config holds an access token). Biggest single win for MIMS. |
| **GitHub MCP** (official) | All projects — PRs, issues, CI status inside the DCOE review loop | Fits the Reviewer→merge gate; you already use the marketplace-over-GitHub distribution model. |
| **Playwright MCP** | Tenders — real-browser scraping of JS-heavy tender portals; second use: MIMS UI verification (your `verify-ui-cardinality` / `dev-server-staleness` skills hint you need this) | Chromium-driven; heavier than fetch but handles auth walls and dynamic pages. |
| **Firecrawl MCP** (or a simple fetch MCP) | Tenders — bulk crawl/markdown extraction of static tender listings | Cheaper per page than Playwright; hosted-service key required → keep off the work machine unless IT-cleared like Context7 was. Check target sites' ToS before scheduled scraping. |
| **Postgres MCP** (direct) | IQ / TebelloReborn if they outgrow SQLite; alternative to Supabase MCP when you want DB-only surface | Skip while Supabase MCP covers MIMS; redundant otherwise. |

Not recommended now: Sentry/observability MCPs (no evidence of Sentry in the vault), generic
filesystem/memory MCPs (native tools already cover them).

---

## Prioritized gap table (highest impact-to-effort first)

| # | Area | Current | Recommended | File:Line | Effort | Impact |
|---|------|---------|-------------|-----------|--------|--------|
| 1 | Executor isolation | "Executors run in a shared session… first action `cd`s into worktree" — impossible since subagent `cd` doesn't persist; executors may edit main checkout | Rewrite rule: executors are background subagents with `isolation: worktree`; note worktree branches from default branch; keep review-before-merge gate | `CLAUDE.md.template:191-193` (+ `:173-183` caveat); `dcoe-roster/agents/executor.md:5` add `isolation: worktree` | S | H |
| 2 | Secret-scan hook | No hook; HARD RULE 4 is instruction-only | `PreToolUse` matcher `Bash` (+`Edit\|Write`) deny on Supabase service_role/env-key patterns | `CLAUDE.md.template:285-291` (hooks table) + project `settings.json` | S | H |
| 3 | Haiku search tier | Routing table assigns Haiku to search, but Explore inherits Sonnet 5 since v2.1.198 and no agent implements the tier | Add `Explore` override agent with `model: claude-haiku-4-5`; annotate both routing tables | `CORE.md:118`, `CLAUDE.md.template:158`, new `~/.claude/agents/Explore.md` | S | M |
| 4 | Hooks are aspirational | 4 named hooks, zero `settings.json` wiring; ":434 Hooks enforce this" is false; `:292` points at wrong config location | Map to real events (`PreToolUse` git-commit/push gates, `SubagentStop` log, `SessionStart` todo inject) and ship a `hooks` block in template settings | `CLAUDE.md.template:285-297,434` | M | H |
| 5 | Auto-format hook | Manual `black/ruff/prettier` before commit | `PostToolUse` on `Edit\|Write`, per-stack formatter, non-blocking | template `settings.json` + `:285-291` | S | M |
| 6 | Notification hook | Nothing; background-default executors finish silently | `Notification` matcher `agent_completed\|agent_needs_input` → OS notify | template `settings.json` | S | M |
| 7 | External `@import` (ADR-007) | CORE.md says absolute-path imports don't resolve, hence "read this file" prose instruction | Docs now support absolute/`~/` imports with a one-time approval dialog — re-test; if it works, `@~/.claude/plugins/...CORE.md` is a harder guarantee than prose | `CORE.md:11-18` | S | M |
| 8 | Commands→skills | `/plan`,`/build`,`/continue` as commands/prose; no `skills/` in dir tree | Migrate to `.claude/skills/<name>/SKILL.md` + `disable-model-invocation: true`; document skills/ dir | `CLAUDE.md.template:202,204,389`; `.claude/commands/continue.md`; `hub-template/continue.md` | S | M |
| 9 | Test-on-Stop | Tests only at (aspirational) pre-push | `Stop` hook, fast tier only, `decision: block` on red | template `settings.json` | M | M |
| 10 | AGENTS.md | Absent | Keep absent (Claude Code doesn't read it); document the `@AGENTS.md` import pattern for any future multi-agent repo | n/a (note in `CLAUDE.md.template` §context mgmt) | S | L |
| 11 | Size guidance | "Keep under 500 lines" | Docs now say target <200 lines/file; adopt `.claude/rules/` (path-scoped) to split stack rules per project | `CLAUDE.md.template:9` | M | M |
| 12 | Effort/thinking table | Prompt magic words only | Note per-agent `effort:` frontmatter (`low…max`) as the structured equivalent | `CLAUDE.md.template:162,449-457` | S | L |
| 13 | Pricing deadline claim | "before 31 August 2026" unverifiable | Verify or delete — date-stamped pricing claims rot | `CLAUDE.md.template:164` | S | L |
| 14 | Skill budget | Unset (default 1% of context) | **KEEP unset.** ~3.6 KB of descriptions is nowhere near budget; check `/doctor` after plugin installs; prefer `skillListingBudgetFraction` if ever needed | n/a | S | L |
| 15 | MCP roster | Context7 queued only | Candidates: Supabase (read-only) → MIMS; GitHub → all; Playwright/Firecrawl → Tenders | new todo entries | M | M |

---

## The 3 changes to make this week

1. **Fix the executor isolation rule (rows 1).** Rewrite `CLAUDE.md.template:191-193` and add
   `isolation: worktree` to `dcoe-roster/agents/executor.md`. This is the only gap that can
   corrupt work *today*: the current instruction relies on subagent `cd` persistence that no
   longer exists, so a literal-minded executor edits MIMS's main checkout while the
   Orchestrator believes it's sandboxed. One template paragraph + one frontmatter line, and per
   HARD RULE 5 of this repo it's a structural change — spec first, bump CORE version if the
   CORE.md worktree wording changes too.

2. **Ship two real hooks: secret-scan (PreToolUse) and auto-format (PostToolUse) (rows 2, 5).**
   Right now the entire HOOKS section is documentation of gates that don't fire, while
   template HARD RULE 3 claims hooks enforce testing. Start with the two S-effort/H-M-impact
   ones: the secret scan directly protects the MIMS Supabase `service_role` key (an RLS-bypass
   credential) on a repo pattern you deliberately run on two machines, and auto-format removes
   the most common Python/Next.js review noise for free. Add the `hooks` block to the
   template's `settings.json` guidance so all four projects inherit it.

3. **Restore the Haiku search tier via an `Explore` override (row 3).** Since v2.1.198 every
   Explore/search delegation in your Pattern-5 research flow has been running on Sonnet 5, not
   Haiku — the routing table's cheapest tier quietly stopped existing. A 5-line
   `~/.claude/agents/Explore.md` with `model: claude-haiku-4-5` reinstates it on both machines
   and is pure cost recovery with zero workflow change. Annotate `CORE.md:118` (and bump the
   core version) so the table matches reality.

*Report only — no config files were modified. Sources: code.claude.com/docs (`skills`, `hooks`,
`sub-agents`, `memory`), retrieved 2026-07-21.*
