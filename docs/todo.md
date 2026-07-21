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

- [x] Config-audit fix 1/3: executor worktree isolation — `isolation:
      worktree` frontmatter on the executor agent; template worktree section
      rewritten (no more shared-session/`cd` rule) — spec at
      `docs/specs/2026-07-21-config-audit-week1-fixes.md` (2026-07-21)

- [x] Config-audit fix 2/3: real hooks — `hub-template/hooks/` ships
      `secret-scan.sh` (PreToolUse) + `auto-format.sh` (PostToolUse) +
      settings snippet; template HOOKS section now maps gates to real
      events and the settings.json registration (2026-07-21)

- [x] Config-audit fix 3/3: `Explore` override agent (`model:
      claude-haiku-4-5`) restores the Haiku search tier — built-in Explore
      inherits the session model since Claude Code v2.1.198; CORE.md → 1.1,
      template → v3.3, dcoe-roster → 3.4.0 (2026-07-21)

## Open

- [ ] Validate the marketplace against a local clone on each machine —
      full steps in `docs/marketplace-validation.md`
- [ ] Run the `document-skills` install on both machines — exact commands
      in README's "External plugins" section; tick when both Operations
      and Pappa T show it in `/plugin list`
- [ ] Roll out dcoe-roster 3.4.0 (systematic-debugging debugger from 3.3.0
      + executor `isolation: worktree` + `Explore` Haiku override; CORE.md
      1.1, template v3.3) on both machines: `/plugin marketplace update` +
      `/plugin update dcoe-roster@tlelosa-claude-config` + `/reload-plugins`;
      also deploy `explore.md` to `~/.claude/agents/` alongside the roster
- [ ] Wire the new hooks into live projects: copy `hub-template/hooks/`
      scripts + settings snippet into MIMS App, IQ, TebelloReborn, Tenders
      (steps in `hub-template/hooks/README.md`)
- [ ] Run the Context7 install on both machines (IT clearance confirmed
      broad, 2026-07-21) — exact command in README's "External plugins"
      section; tick when both Operations and Pappa T show it in
      `/plugin list`
