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

## Open

- [ ] Implement the codex-gate plugin per
      `docs/specs/2026-07-21-codex-gate-spec.md` — **blocked on owner
      approval of that spec**; install Pappa T only
- [ ] Ask Fan Movement IT whether OpenAI egress from the Operations machine
      is covered — until then codex-gate stays off the work PC

- [ ] Validate the marketplace against a local clone on each machine —
      full steps in `docs/marketplace-validation.md`
- [ ] Run the `document-skills` install on both machines — exact commands
      in README's "External plugins" section; tick when both Operations
      and Pappa T show it in `/plugin list`
- [ ] Roll out dcoe-roster 3.3.0 (systematic-debugging debugger) on both
      machines: `/plugin marketplace update` + `/plugin update
      dcoe-roster@tlelosa-claude-config` + `/reload-plugins`
- [ ] Run the Context7 install on both machines (IT clearance confirmed
      broad, 2026-07-21) — exact command in README's "External plugins"
      section; tick when both Operations and Pappa T show it in
      `/plugin list`
