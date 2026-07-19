# tlelosa-claude-config — Task Queue

Maintained by `/continue` (read) and `/end-session` (write). This repo is
the plugin marketplace itself, not a governed vault — this queue tracks its
own maintenance work only (new plugin components, framework fixes), not
project work on any downstream repo.

## Open

- [ ] **Decide on opening a PR** for today's three commits (`cac7ecf`,
      `3ebeee0`, `65c8836`) — currently pushed straight to
      `claude/repo-status-update-n5z63h`, no PR opened yet, awaiting a call.
- [ ] **Operations hub reconciliation** — out of this repo's scope to do
      directly (different repo, not added to this session). Two follow-ups
      live there once someone opens a session with that repo in scope:
      - Run `HUB-CHECKLIST.md` against `Operations/CLAUDE.md` to install
        `hub-template/retro.md` at `.claude/commands/retro.md` (checklist
        item added this session).
      - File the ADR for CORE.md hard rule 9 (verify-remote-before-
        asserting) in `Operations/docs/decisions/` — referenced from
        `CORE.md` by number elsewhere in this repo's convention, but no
        ADR number has been assigned since that repo wasn't in scope here.
- [ ] **Verify `/continue`'s actual resume-report output** (not just that it
      registers) on a fresh session — today's dogfooding only confirmed
      command discovery + description text, not a full Step 1-4 run.

## Done (this session, not yet reflected upstream)

- [x] `dcoe-roster/CORE.md` v1.0 → v1.1: added hard rule 9 (verify remote
      state before asserting it).
- [x] `hub-template/retro.md` — batched-improvement counterpart to
      `/continue`, wired into `HUB-CHECKLIST.md`.
- [x] `.claude/commands/continue.md` + `.claude/commands/end-session.md` —
      this repo's own resume/archive pair.
- [x] Dogfooded both commands same-session; found and fixed a frontmatter
      bug (comment banner instead of a real `description:` field) in all
      four command files, confirmed fixed via the command picker.
