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
      archiving) — spec at `docs/specs/2026-08-04-session-end-command.md`
      (design decided 2026-08-04). **Correction (2026-08-05):** this entry
      previously claimed the `Claude-Code` hub instance and its ADR already
      existed as of 2026-08-04 — they didn't; caught by the Reviewer Loop
      on `docs/specs/2026-08-05-command-center.md`'s Gap 3, verified against
      the filesystem. Promoted the same way as `/continue` (ADR-008):
      `hub-template/session-end.md` (vault-agnostic, gained a
      reusable-fact knowledge-cache checklist question 2026-08-05 per Gap 3)
      plus a minimal instance here at `.claude/commands/session-end.md`
      (2026-08-04, unaffected by the correction) and a full instance in the
      `Claude-Code` hub — actually built 2026-08-05. Recorded as
      `Claude-Code/docs/decisions/ADR-010-session-end-command.md`
      (written 2026-08-05; **merged to the hub's `main` only on 2026-08-08**
      — it sat unmerged on a branch until the systems-check recovery, so
      this entry was still false in a second way until then)
- [x] Fix two `/session-end` defects found on its first real run against the
      `Claude-Code` hub: the session-log step over-appended (reworded to
      reconcile-not-duplicate, three cases spelled out) and the title step
      assumed `set_session_title` could always be attempted (reworded to
      report "not available in this environment" on surfaces where a session
      can't obtain its own ID). Fix 1 is hub-template-only; fix 2 applies to
      both `hub-template/session-end.md` and this repo's own instance. PR #11
      (2026-08-06)
- [x] Fix inert YAML frontmatter in both `hub-template/` commands —
      `continue.md` and `session-end.md` opened with a `---` block of only
      `#` comments, which parses to nothing, so every vault copying them into
      `.claude/commands/` got an undescribed command. Converted both to a
      real `description:` key with the explanatory text moved below as prose.
      Rest of the repo checked; no other command file affected. PR #12
      (2026-08-06)
- [x] Record PR #14 (`hub-template/continue.md` reconciled with four hub
      improvements: Step 0.5 stale/idle category, Step 1.75 sync check,
      Step 1.9 cross-repo staleness, Step 2.5 machine-bound flagging, plus
      Step 3 fields; three vault-specific leaks generalised) — merged
      2026-08-07, recorded here 2026-08-08 during the systems check that
      found it missing from this list
- [x] **Systems check of both repos** — findings and a seven-phase
      maintenance plan at `docs/specs/2026-08-08-system-maintenance-plan.md`;
      per-branch verdicts at `docs/specs/2026-08-08-branch-triage-verdicts.md`
      (2026-08-08)
- [x] **Phase 1 — branch triage, both repos.** 16 unmerged branches with no
      open PR assessed by reading contents against current `main`. Config
      repo: 3 branches, partial keeps. Hub: 13 branches, 7 carrying nothing
      but stale state. Found three version collisions that a naive merge
      would have shipped (two different v3.3 templates, two 3.4.0 rosters)
      (2026-08-08)
- [x] **Phase 2 — recovered the keeps.** Config repo: `bootstrap.sh` + its
      session-start check, the JSON-validation hook spec (Draft), the
      session-end reusable-fact question, the mobile slash-command gap note,
      the config audit + week-1 spec (new `docs/research/`), the
      `hub-template/hooks/` pair, `CLAUDE.md.template` v3.4 (executor
      isolation + real HOOKS events), the `Explore` Haiku override, and
      CORE 1.3 (Explore row + hard rule 10, verify-remote-before-asserting).
      Hub: ADR-010, three stranded `knowledge/` files, and four PWA
      service-worker entries (2026-08-08)
- [x] **Phase 3/4 — corrected the record.** The false ADR-010 claim (wrong
      twice over — see the entry above), the marketplace catalog still
      advertising agent bodies stripped on 2026-07-29, and four CLAUDE.md
      drifts including a validation block missing `codex-gate/plugin.json`
      (2026-08-08)

- [x] **Phase 5 — model routing.** Spec at
      `docs/specs/2026-08-08-model-routing.md`, approved and implemented the
      same day. Added the standing-pin test (a role earns a permanent model
      pin only when *every* task it receives already meets an escalation
      trigger), which documents `architect`'s pin instead of leaving it
      contradicting hard rule 7, and replaced 11 stale `claude-opus-4-8`
      references with `claude-opus-5` across `CORE.md`, `CLAUDE.md.template`
      and two agent bodies. CORE 1.4 / template v3.5 / dcoe-roster 3.6.0
      (2026-08-08)

- [x] **Phase 6 — unmerged-branch checks.** Spec at
      `docs/specs/2026-08-08-unmerged-branch-checks.md`, approved and
      implemented the same day. `/continue` gains Step 1.8 (find work earlier
      sessions stranded) and `/session-end` gains Step 1.5 (don't strand your
      own), in both `hub-template/` and this repo's own instances; this
      repo's `/continue` also now fetches before reporting git state, which
      it never did. `HUB-CHECKLIST.md` names both steps so a vault that
      copied the commands earlier learns to re-copy. Verified against a known
      answer — the check found 5 unmerged branches here including this
      session's own 22 commits. No version bump: `hub-template/` is
      copy-source, not a plugin (2026-08-08)


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

### From the 2026-08-08 systems check

- [ ] **Roll out dcoe-roster 3.6.0 + CORE 1.4 + template v3.5 on both
      machines** (was 3.5.0/1.3/v3.4 before the model-routing change landed
      on top — nothing has shipped yet, so it all goes in one pass) — `/plugin marketplace update` + `/plugin update
      dcoe-roster@tlelosa-claude-config` + `/reload-plugins`, then **re-run
      `agent-bodies-reference/bootstrap.sh`** so `explore.md` and the
      executor's `isolation: worktree` actually reach `~/.claude/agents/`.
      The plugin update alone does not deliver agent bodies.
- [ ] **Decide: bash vs PowerShell for the shipped scripts** (deferred
      2026-08-08). `bootstrap.sh`, `hub-template/hooks/secret-scan.sh` and
      `auto-format.sh` are all bash; Operations and Pappa T are Windows and
      need git-bash on PATH. Either confirm git-bash is present on both, or
      add `.ps1` equivalents.
- [ ] **Review `/overwatch` and the command-center spec** (deferred
      2026-08-08). Built 2026-08-05, still unmerged on the hub's
      `claude/continuation-utn4f5`. Gaps 2 and 3 of that spec landed today;
      Gap 1 (`/overwatch`) is the only piece left. Decide whether it is still
      wanted or lands as historical — the branch is held undeleted until then.
- [ ] **Confirm `retro.md` is genuinely not wanted** — dropped 2026-08-08 on
      the reading that `/continue` + `/session-end` already cover workflow
      management. It still exists on `claude/repo-status-update-n5z63h`,
      which is being held undeleted in case that call is reversed.
- [ ] **Confirm whether the desktop CLI has the mobile app's slash-command
      restriction** — `/continue` returns "isn't available in this
      environment" on a Default-type mobile session (2026-07-19). If the CLI
      is affected too, the note now in `hub-template/continue.md` needs
      upgrading from a surface quirk to a much bigger problem.
- [ ] **Decide whether to implement the JSON-validation pre-commit hook** —
      spec recovered as Draft at `docs/specs/2026-08-05-json-validation-hook.md`,
      already Codex-reviewed. Hard rule 3 is self-monitored until then.
- [ ] **Delete the triaged branches** once the two held-open decisions above
      are made — 3 config-repo branches and 13 hub branches, verdicts in
      `docs/specs/2026-08-08-branch-triage-verdicts.md`.
- [ ] **Run `/codex-review` on `docs/specs/2026-08-08-model-routing.md` from
      Pappa T, or record a waiver.** The spec was approved and implemented
      2026-08-08 without it — codex-gate is a per-machine install and this
      was written from a cloud container. Universal hard rule 9 wants the
      pass on every spec; noted here rather than left to lapse quietly. The
      change is already committed, so this is a retrospective review: if
      Codex raises something real, it becomes a follow-up fix, not a revert.
- [ ] **Verify or drop the "introductory pricing ends 31 August 2026" claim**
      in `CLAUDE.md.template` (~line 164), which advises scheduling bulk
      batch jobs before that date. 22 days out as of 2026-08-08 and
      unverified — deliberately left out of the model-routing spec as a
      separate factual question.
- [ ] **Adopt the Phase 6 branch checks in the `Claude-Code` hub's own
      `.claude/commands/` copies** — the templates here have them as of
      2026-08-08; the hub's instances are separate files in a separate repo
      and do not yet. Run `HUB-CHECKLIST.md` against that vault.
- [ ] **Run `/codex-review` on
      `docs/specs/2026-08-08-unmerged-branch-checks.md` from Pappa T, or
      record a waiver** — same standing gap as the model-routing spec.
- [ ] **Phase 7 of the maintenance plan remains**: hub hygiene and
      governance — a root `.gitignore` (31 MB installer, logs and generated
      images are tracked today), and the contradiction between the hub's
      hard rule 4 and the company data actually living in `Operations/`.
