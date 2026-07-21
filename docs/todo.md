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

## Open

- [ ] Validate the marketplace against a local clone on each machine —
      full steps in `docs/marketplace-validation.md`
- [ ] Install Anthropic's official `document-skills` (xlsx/docx/pdf) on both
      machines (`/plugin marketplace add anthropics/skills`) — complements
      `safe-office-file-read` and strengthens `data-agent`'s report prep
- [ ] Fold the `systematic-debugging` methodology (obra/superpowers, MIT,
      with attribution) into the `debugger` agent — structural change:
      spec in `docs/specs/` first, bump dcoe-roster version
- [ ] Install the Context7 plugin for hub dev projects (live version-correct
      library docs for executor/debugger) on both machines — IT-policy
      check cleared 2026-07-21
