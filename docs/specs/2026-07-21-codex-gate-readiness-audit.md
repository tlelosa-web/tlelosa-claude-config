# Readiness audit — cross-family Codex second-opinion gate

**Date:** 2026-07-21 | **Status:** Findings only — nothing implemented
**Scope reviewed:** `CLAUDE.md.template` (v3.2), `dcoe-roster/CORE.md` (core
1.0), `dcoe-roster/agents/reviewer.md`, `hub-template/`, this repo's own
`CLAUDE.md`.

-----

## Blockers (read first)

1. **The audit target is only half in this repo.** The vault-level
   `CLAUDE.md`/`AGENTS.md` and the named sub-projects (MIMS App, IQ,
   TebelloReborn, Tenders) live on the machines, not here — correctly so,
   per this repo's hard rule #1 ("no company or project data, ever").
   Exclusion paths below are therefore recommendations by name; verifying
   them requires a session at the vault root, not in this repo.
2. **`codex-plugin-cc` provenance is unverified.** Nothing in this repo (or
   its marketplace) references it. Before any install decision, vet the
   plugin source the same way Context7 and document-skills were vetted, and
   record it in the README "External plugins" section.
3. **IT clearance gap.** Prior clearances on the Operations (work) machine
   were specific: personal *Anthropic* account, Context7. Shipping
   plan/code context to *OpenAI* from the work PC is a new, uncleared
   egress path. Until cleared, any Codex gate must be Pappa T–only —
   which alone rules out putting it in `CORE.md` as universal.
4. **`ExitPlanMode` largely misses the DCOE flow.** Pattern 1 does not run
   through Claude Code's plan mode: the *planner sub-agent* writes the spec
   to `docs/specs/`, and approval happens at Pattern 1 step 2 ("Review
   spec → approve or iterate") — a human checkpoint, not a tool event. An
   `ExitPlanMode` hook fires only in plan-mode sessions, so as the primary
   gate it would silently not fire for most DCOE feature work.
5. **Fail-warn is not a preference — it is forced by an existing hard
   rule.** Hard rule #11 ("Offline-first always — no feature may depend on
   internet connectivity") makes any fail-stop Codex gate a direct hard-rule
   violation. See §3.

-----

## 1. Placement — recommendation

**Recommended: an explicit spec-review step at Pattern 1 step 2**, i.e. the
gate sits between "Planner writes spec" and "human approves spec", invoked
as a visible command (`/codex:review docs/specs/<feature>.md` or
equivalent), with its verdict attached to the spec before approval.
Optionally add an `ExitPlanMode` hook as a *secondary* catch for the
sessions that do use plan mode — never as the primary mechanism (blocker
#4).

Why here and not the alternatives:

- **Not `pre-push`.** The HOOKS table reserves `pre-push` for the
  deterministic test suite. A Codex call there (a) arrives after the code
  is written — the expensive place to discover a plan-level disagreement,
  (b) adds a network dependency to a gate whose philosophy is "block if
  fails", colliding with blocker #5, and (c) reviews the same diff the
  reviewer just reviewed (double-gating, §2).
- **Not an addition to the reviewer stage.** Pattern 1 step 5 already has a
  permanent Opus 4.8 blocking gate on the diff. Stacking a second reviewer
  on the same artifact doubles latency for the artifact where cross-family
  disagreement is *least* actionable. Cross-family value concentrates at
  the plan, where changing course is cheap.
- **Not a new roster agent.** Roster agents are Claude sub-agents routed by
  `model:` frontmatter — Codex is not addressable that way; a "codex" agent
  would be a shell-out shim wearing an agent's clothes, breaking the
  roster's semantics. Worse, the roster deploys user-level to *both*
  machines via this marketplace, which force-installs an OpenAI egress path
  onto the employer machine (blocker #3).

DCOE fit: the gate lands exactly at the existing human checkpoint, so it
adds no new stage and respects "Context Agent writes the plan — never the
code". Per this repo's own rules this is a **structural change** (alters
what other machines install, touches CORE-adjacent flow): spec + ADR first.

## 2. Reviewer overlap — division of labour

**Codex checks (plan stage only):**

- Buried assumptions in the spec — unstated acceptance criteria, implicit
  environment/stack assumptions, missing failure modes. This directly
  services hard rule "if acceptance criteria are unclear → STOP and ask".
- Cross-model architectural disagreement — "would a non-Claude model design
  this differently, and why". Planner and reviewer are both Claude-family;
  their failure modes are correlated, so a shared wrong assumption can pass
  the Opus gate untouched. That correlated-blind-spot risk is the entire
  justification for the integration.
- Codex's lack of project memory and CLAUDE.md context is a *feature* here
  (genuinely fresh eyes on the plan) and a *liability* at code level.

**Reviewer keeps, exclusively:** diff-level correctness against acceptance
criteria, security review (auth, file-write, data-export, injection),
secrets-in-code scan, migration-file checks, test-coverage gaps, hard-rule
compliance, and — critically — **sole verdict authority**
(APPROVE / BLOCK). Codex output is advisory annotation on the spec; only
the reviewer blocks.

**Redundant (do not send to Codex):** anything the reviewer already covers
above. A Codex pass over the final diff duplicates the Opus gate with a
model that has less context.

**Double-gating guardrails:**

- One Codex call per feature, at spec approval. Never per-commit,
  never per-push.
- Slim-profile work ("single-file markdown/JSON edits: go straight to
  Execute") and Pattern 2 bug fixes are **exempt** — no Codex call.
- If Codex and the human/reviewer disagree, the disagreement is logged in
  the spec and the human decides; there is no "both must agree" rule, which
  is where second-opinion gates quietly become veto gates.

## 3. Fail mode — fail-warn, confirmed mandatory

Fail-warn is not a design choice to weigh; fail-stop would violate hard
rule #11 (offline-first) and the HOOKS philosophy simultaneously. Concretely:

- On Codex outage, rate limit, timeout, or missing credentials: emit a
  visible warning ("Codex second opinion unavailable — proceeding solo"),
  and continue. Exit success. Never block spec approval, commit, or push.
- **Where it belongs in the HOOKS philosophy:** extend the existing
  paragraph — "Block at commit time, not write time" — with one sentence:
  *only deterministic local gates (lint, format, tests) may block;
  network-dependent advisory gates warn and proceed.* The Codex row in the
  HOOKS table must carry "Warn only — never block" in its Action column,
  making it the table's first explicitly non-blocking row.
- Give the call a hard timeout (proposed 60–90 s — open question) so a
  hung API can't stall the flow, and log the outcome
  (`ran / warned / skipped-offline`) to `docs/session-log.md` via the
  existing `post-task` hook, so silent degradation is visible rather than
  discovered months later.

## 4. Security conflict — scoping and redaction

The vault holds real CVs, financial strategy, and personal records under
"no secrets in code" and data-preservation rules. A Codex call is an
egress of context to OpenAI. Proposed rule: **default-deny, explicit
allow-list** — scoping is the primary control, redaction is secondary.

**Must be excluded from any Codex payload (deny by default):**

| Path / area | Reason |
|---|---|
| Vault notes/docs (hub root markdown, inbox, life-domain folders) | CVs, financial strategy, personal records |
| `TebelloReborn` | Personal identity/records project |
| `Tenders` | Bid + financial data; company-adjacent |
| `MIMS App` | Company-adjacent; also gated on blocker #3 (work-machine clearance) |
| `IQ` | Unverified contents — stays denied until audited at the vault |
| Any `.env`, `docs/session-log.md`, `docs/todo.md`, CLAUDE.md/`@import` chains | Secrets, personal task queue, operating context |

**Allow:** only sub-projects explicitly marked payload-safe in the vault's
own config, and even then only the artifact under review — the single spec
file or diff. Never the surrounding CLAUDE.md context, never `@imports`,
never other `docs/` content. Strip YAML frontmatter (`source`, `project`
provenance fields per the hub note convention) before sending.

**Where the list lives:** the allow-list names real sub-projects, so it
**must not be committed to this repo** (hard rule #1). It belongs in the
vault's own `CLAUDE.md`/settings on each machine. This repo may carry only
the generic mechanism ("default-deny; allow-list is vault-local").

## 5. Config surface (what would change — not changed now)

- **Vault `CLAUDE.md` (v3.2 → v3.3):**
  - Pattern 1 step 2 amended: "Review spec → *Codex second opinion
    (advisory, warn-only)* → approve or iterate".
  - HOOKS table: one new row — trigger "spec approval (+ optional
    `ExitPlanMode`)", action "Codex cross-family review — warn only, never
    block"; philosophy paragraph extended per §3.
  - SECURITY & PERMISSIONS: default-deny egress rule + pointer to the
    vault-local allow-list.
  - Versioned changelog line at the bottom, matching the v3.2 precedent.
- **`CORE.md`:** at most a one-line model-routing note that a cross-family
  second opinion is an *optional, hub-local, advisory* gate outside the
  Opus escalation ladder. Do **not** make it a universal hard rule or
  roster entry — it cannot be universal while blocker #3 stands.
- **Roster:** no new agent line (per §1). If the plugin route is chosen it
  arrives as commands (`/codex:review`), not agents.
- **ADR:** required. External data egress + both-machines impact makes this
  structural under this repo's own rules: spec in `docs/specs/`, ADR in the
  vault's `docs/decisions/`, and `docs/todo.md` updated.
- **API key:** **user scope, per machine** — Codex CLI's own auth store
  (`~/.codex/`) or user-level environment, mirroring how the agent roster
  itself is user-scoped. Not per-sub-project `.env`: that scatters an
  OpenAI credential into projects that are themselves on the deny list,
  and multiplies "never commit `.env`" failure surfaces. Pappa T machine
  only until blocker #3 clears. Never in this repo in any form.

-----

## Open questions (acceptance criteria not yet defined — do not build)

1. What does the human *do* with a Codex disagreement — is a logged note in
   the spec sufficient, or is a disposition ("accepted / rejected because…")
   required before approval?
2. Is the gate wanted for plan-mode sessions, spec approvals, or both?
   (Determines whether the `ExitPlanMode` hook is built at all.)
3. Timeout budget and retry policy for the Codex call (proposed 60–90 s,
   no retry — unconfirmed).
4. Plugin vs. hook implementation: is `codex-plugin-cc` acceptable after
   vetting, or is a thin self-owned hook preferred for payload control?
5. Which sub-projects, if any, does the owner actually want allow-listed —
   or is phase 1 "specs written at the config-repo/hub level only, no
   sub-project payloads at all"?
6. Does Fan Movement IT clearance extend to OpenAI egress from the
   Operations machine? (Blocker #3 — determines single- vs. dual-machine
   rollout.)
