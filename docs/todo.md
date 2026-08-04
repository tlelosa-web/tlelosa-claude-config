# todo.md — tlelosa-claude-config

Task list for this repo. Per the DCOE hard rules: update after every
completed task; one task = one commit.

## Done

- [x] Set up the repo itself with the DCOE framework (slim profile):
      root `CLAUDE.md`, `docs/todo.md`, `docs/specs/` (2026-07-21)
- [x] Adapt a minimal `/continue` for this repo:
      `.claude/commands/continue.md` (2026-07-21)
- [x] Add note-frontmatter convention item to `hub-template/HUB-CHECKLIST.md`
      (from second-brain video review) (2026-07-21)
- [x] Build `/capture` skill in `shared-skills` — spec at
      `docs/specs/2026-07-21-capture-skill.md`; bumped shared-skills to
      1.1.0 (2026-07-21)
- [x] Confirm Fan Movement IT policy allows the personal private repo on
      the Operations machine — cleared by IT (personal Anthropic account
      approved for use on the work PC) (2026-07-21)
- [x] Fold the `systematic-debugging` methodology (obra/superpowers, MIT,
      with attribution) into the `debugger` agent — spec at
      `docs/specs/2026-07-21-debugger-systematic-debugging.md`; bumped
      dcoe-roster to 3.3.0 (2026-07-21)
- [x] Audit readiness for a cross-family Codex second-opinion gate —
      findings (recommendation, blockers, open questions) at
      `docs/specs/2026-07-21-codex-gate-readiness-audit.md`; nothing
      implemented pending answers to its open questions (2026-07-21)

- [x] Scope the Codex second-opinion gate via owner questionnaire (specs-only
      payload, self-owned command, logged-note dissent, no plan-mode hook) —
      spec at `docs/specs/2026-07-21-codex-gate-spec.md`, awaiting approval
      (2026-07-21)
- [x] Implement codex-gate per approved spec: new `codex-gate/` plugin
      (`/codex-review` command), marketplace entry, CLAUDE.md.template
      bumped to v3.3, README install + IT-scope notes (2026-07-21)

- [x] Validate the marketplace against a local clone on each machine —
      full steps in `docs/marketplace-validation.md`; both Operations and
      Pappa T passed local + remote install and the ADR-007 CORE.md path
      check (2026-07-22)
- [x] Roll out dcoe-roster 3.3.0 (systematic-debugging debugger) on both
      machines — both Operations and Pappa T updated; `debugger` agent
      shows the four-phase systematic-debugging methodology (2026-07-22)
- [x] Run the `document-skills` install on both machines — both
      Operations and Pappa T show it in `/plugin list` (2026-07-22)
- [x] Run the Context7 install on both machines — both Operations and
      Pappa T show it in `/plugin list` (2026-07-22)
- [x] Name the reviewer Loop and promote the impact-based scale Router into
      `dcoe-roster/CORE.md`, per a Graph Engineering reference-architecture
      comparison — spec at
      `docs/specs/2026-08-03-graph-engineering-core-additions.md` (Codex
      second opinion + Amendment folded in before build). Bumped Core
      version 1.1 → 1.2. Documentation-only, no plugin/manifest changes
      (2026-08-03)
- [x] Add a `/session-end` command (close out a session, prep it for
      archiving) — spec at
      `docs/specs/2026-08-04-session-end-command.md`. Promoted the same way
      as `/continue` (ADR-008): `hub-template/session-end.md`
      (vault-agnostic) plus a minimal instance here at
      `.claude/commands/session-end.md` and a full instance in the
      `Claude-Code` hub. Recorded as `Claude-Code/docs/decisions/
      ADR-010-session-end-command.md` (2026-08-04)

## Open

> Machine-side items below are consolidated into one ordered run per
> machine in `docs/rollout-checklist-2026-07-21.md` — work from that,
> tick here as each block passes.

- [ ] Install + smoke-test codex-gate on Pappa T (Codex CLI authed at
      `~/.codex/`, then `/plugin install codex-gate@tlelosa-claude-config`;
      run `/codex-review` on a real spec and confirm the fail-warn path by
      running it once with the network off) — acceptance criteria in
      `docs/specs/2026-07-21-codex-gate-spec.md`
- [ ] Record the codex-gate ADR in the Operations hub's `docs/decisions/`
      (vault-side) — draft ready to copy over at
      `docs/specs/2026-07-21-codex-gate-adr-draft.md`
- [ ] Ask Fan Movement IT whether OpenAI egress from the Operations machine
      is covered — until then codex-gate stays off the work PC

- [ ] **Bootstrap `~/.claude/agents/` on the machine this repo was cloned to
      under `C:\Users\tlelo\Downloads\`** — per
      `docs/specs/2026-07-29-strip-dcoe-roster-agent-bodies.md`, the roster
      is no longer plugin-installed; each machine needs the 9 files in
      `agent-bodies-reference/` copied into `~/.claude/agents/` manually.
      Discovered 2026-08-03 while trying to dispatch the `reviewer` agent
      against `docs/specs/2026-08-03-graph-engineering-core-additions.md`
      and finding no agent files anywhere on that machine (not a repo bug —
      this machine's local git clone was also 3 commits behind `origin/main`
      at the time, predating the strip-agent-bodies merge; corrected via
      merge this session). Worth checking whether Operations/Pappa T
      themselves ever got the manual bootstrap step run too, since the
      rollout checklist's old verify step for it is now informational-only
      per that spec's item 4.
