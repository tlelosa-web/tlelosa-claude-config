# tlelosa-claude-config — Task Queue

Maintained by `/continue` (read) and `/end-session` (write). This repo is
the plugin marketplace itself, not a governed vault — this queue tracks its
own maintenance work only (new plugin components, framework fixes), not
project work on any downstream repo.

## Open

- [ ] **Decide on opening a PR** for commit `cac7ecf` (CORE.md v1.1 hard
      rule 9 + `hub-template/retro.md`) — currently pushed straight to
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
- [ ] **Dogfood `/continue` + `/end-session`** on the next session that
      touches this repo — confirm the resume report is grounded in this
      file and `session-log.md` rather than silence or stale state.

## Done (this session, not yet reflected upstream)

- [x] `dcoe-roster/CORE.md` v1.0 → v1.1: added hard rule 9 (verify remote
      state before asserting it).
- [x] `hub-template/retro.md` — batched-improvement counterpart to
      `/continue`, wired into `HUB-CHECKLIST.md`.
- [x] `.claude/commands/continue.md` + `.claude/commands/end-session.md` —
      this repo's own resume/archive pair (this task).
