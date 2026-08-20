# Machine rollout checklist — 2026-07-21

> **Retired 2026-08-20.** Operations and Pappa T are no longer in use —
> `ai-product-factory` is the sole environment now. Every numbered block
> below already passed on both machines (see the ticks in `docs/todo.md`)
> except the two items noted inline as permanently blocked rather than
> pending. Kept for history, not as a live checklist — there is no second
> machine left to run this on.

Consolidates every machine-side open item in `docs/todo.md` into one
ordered run per machine: marketplace validation, dcoe-roster 3.3.0,
external plugins (Context7, document-skills), and — Pappa T only — the
codex-gate install + smoke test. Full detail lives in the referenced
docs; this is the run order with the exact commands inline.

As each numbered block passes, tick the matching item in `docs/todo.md`
(each tick is its own one-task commit, per repo rules).

-----

## Pappa T (personal) — run first, nothing gated

### 1. Marketplace validation

Full procedure with verification steps: `docs/marketplace-validation.md`.
Condensed:

```powershell
# Prereqs
gh auth status
git clone https://github.com/tlelosa-web/tlelosa-claude-config.git   # or: git -C tlelosa-claude-config pull
git -C tlelosa-claude-config log --oneline -1                        # confirm current main
```

In a Claude Code session started in the directory containing the clone:

```
/plugin marketplace add ./tlelosa-claude-config
/plugin install dcoe-roster@tlelosa-claude-config
/plugin install shared-skills@tlelosa-claude-config
```

Verify: `/plugin list` shows both at user scope; the five shared skills
appear. (Historical note, 2026-07-29: `dcoe-roster` no longer ships agent
bodies, so `/agents` showing all nine now depends on copying
`agent-bodies-reference/*.md` into `~/.claude/agents/` separately — see
`docs/specs/2026-07-29-strip-dcoe-roster-agent-bodies.md`. This checklist is
historical and not re-run; noted for anyone reading it later.) Then swap to
remote:

```
/plugin marketplace remove tlelosa-claude-config
/plugin marketplace add https://github.com/tlelosa-web/tlelosa-claude-config.git
/plugin install dcoe-roster@tlelosa-claude-config
/plugin install shared-skills@tlelosa-claude-config
```

Re-verify, then confirm the ADR-007 path exists:

```powershell
Test-Path ~\.claude\plugins\marketplaces\tlelosa-claude-config\dcoe-roster\CORE.md
```

### 2. dcoe-roster 3.3.0 (systematic-debugging debugger)

A fresh install from current `main` in step 1 already delivers 3.3.0 —
confirm with `/plugin list`. If the marketplace was already installed
before this rollout, update instead:

```
/plugin marketplace update tlelosa-claude-config
/plugin update dcoe-roster@tlelosa-claude-config
/reload-plugins
```

Verify: the `debugger` agent description mentions the four-phase
systematic-debugging methodology.

### 3. External plugins

```
/plugin install context7@claude-plugins-official
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

User scope (the default). Verify both appear in `/plugin list`. This
machine's half of the two "run on both machines" todo items.

### 4. codex-gate install + smoke test (Pappa T ONLY)

Acceptance criteria: `docs/specs/2026-07-21-codex-gate-spec.md`.

Prereq — Codex CLI installed and authed at user scope:

```powershell
codex login          # or confirm ~/.codex/ already holds credentials
```

Install:

```
/plugin install codex-gate@tlelosa-claude-config
```

Smoke test, in a project with a real spec under `docs/specs/`:

- [ ] `/codex-review docs/specs/<real-spec>.md` → appends a dated
      `## Codex second opinion (advisory)` section to that file and
      touches nothing else.
- [ ] `/codex-review README.md` (any path outside `docs/specs/`) →
      refused with a clear message, nothing sent.
- [ ] Fail-warn path: disable the network (or rename `~/.codex/`
      temporarily), run again → prints "Codex second opinion unavailable
      (<reason>) — proceeding solo" and exits successfully within 90 s.
- [ ] If the project has `docs/session-log.md`: one `codex-review` line
      per run, `ran` or `warned (<reason>)`.

-----

## Operations (work PC) — same order, two gates

Standing gate: **do NOT install codex-gate here** until Fan Movement IT
confirms OpenAI egress (question drafted; outcome pending — see
`docs/todo.md`). Everything else below is covered by the 2026-07-21
clearance (personal Anthropic account + approved external tooling incl.
Context7).

### 1. Marketplace validation

Same as Pappa T step 1. The "Before you start — Operations only" gate in
`docs/marketplace-validation.md` (personal repo on company machine) was
cleared by IT on 2026-07-21.

### 2. dcoe-roster 3.3.0

Same as Pappa T step 2.

### 3. External plugins

Same as Pappa T step 3 (Context7 explicitly named in the IT clearance;
document-skills is Anthropic tooling under the same clearance).

### 4. codex-gate

**Skip.** Revisit only when the IT egress answer lands: if cleared, run
Pappa T step 4 here too and update the README's IT-policy section; if
declined, note it in `docs/todo.md` and the README so the Pappa T-only
status is recorded as permanent rather than pending.

-----

## Done when

- Pappa T: steps 1–4 all pass.
- Operations: steps 1–3 all pass; step 4 resolved either way.
- All five machine-side items in `docs/todo.md` ticked (marketplace
  validation, document-skills ×2 machines, dcoe-roster 3.3.0 ×2,
  Context7 ×2, codex-gate smoke test), each as its own commit.
- This checklist file can then be deleted (or moved to an archive note)
  in the same commit as the final tick.
