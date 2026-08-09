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

- [x] **PR templates for both repos** — spec at
      `docs/specs/2026-08-09-pr-templates.md`, approved and implemented the
      same day. Neither repo had one; PR bodies were freehand, so the two
      facts a reviewer needs before merging (which spec authorised the change,
      whether the `reviewer` agent approved it) lived only in a session
      transcript that dies with the container. Adds
      `.github/pull_request_template.md` to this repo and to `Claude-Code`:
      shared `What changed` / `Why` / `Scope` / `DCOE gates` block, a two-box
      self-attested checklist, tailored `Verification` prose per repo. Nothing
      blocks — no CI, no required check. No version bump; `.github/` ships in
      no manifest, so neither machine needs to do anything (2026-08-09)

- [x] **Reconciled the branch-triage count** — the queue recorded 3 held-open
      config-repo branches against a 2026-08-09 check finding 4. Re-measured
      both repos against freshly fetched refs, by ancestry and by *files
      present on the branch and absent from `main`*: **4 config-repo branches
      and 14 hub branches**, so both of the spec's headline counts were wrong,
      for four independent reasons. Amendment appended to
      `docs/specs/2026-08-08-branch-triage-verdicts.md` (2026-08-09); it
      supersedes that file's own summary tables. Three findings beyond the
      count: (1) `hub-template/retro.md` is the **only** file across all four
      config branches that `main` lacks — everything else is the
      deliberately-stripped `dcoe-roster/agents/` path or a file this repo
      decided against — so the `retro.md` decision alone now gates all four
      deletions; (2) `continuation-yon8p3`'s "byte-identical to `main`" reason
      was wrong when written, though its delete verdict stands; (3) the hub's
      PR template never landed — logged as its own open item below. Also
      **closed the `/overwatch` open item**: it was being held on the hub's
      `claude/continuation-utn4f5`, but that branch's content reached the hub's
      `main` on 2026-08-09 (`b7ceebb` for `/overwatch` + the command-center
      spec, `1517c7f` for ADR-010) and the branch was deleted. All three
      command-center gaps are now live across both repos and that spec is
      marked complete (2026-08-09)

- [x] **Landed the hub's PR template** — the half of the 2026-08-09
      PR-template task that never merged. `Claude-Code` had no `.github/` at
      all; `.github/pull_request_template.md` sat alone on
      `claude/pr-template-linear-planning-40hnrd` while the Done entry above
      recorded the task complete for both repos, so that entry was half-true
      for a day. Taken verbatim from the stranded branch onto a branch cut from
      the hub's current `main` — **not merged**: that branch is thousands of
      lines behind `main`, per the triage's extract-don't-merge rule. Content
      unchanged from the spec's §2 (shared block + hub-tailored `Verification`).
      Logged in the hub's `docs/session-log.md`; its `docs/todo.md` needs no
      entry, since this initiative is tracked here under hub-and-spoke. No
      version bump — `.github/` ships in no manifest and GitHub reads the
      template server-side, so neither machine does anything (2026-08-09)

- [x] **Landed `hub-template/retro.md`** — the 2026-08-08 call to drop it is
      reversed. `/retro` is the backward-looking counterpart to `/continue`:
      where `/continue` orients on what's next, `/retro` reads the session log
      and queue for *framework* friction — a session redoing settled work,
      Tebello having to point out something already decided, a stale
      external-state assertion, the same gap recurring across entries, an item
      deferred three times — then proposes a confirmable batch and records the
      run in `docs/retro-log.md` so it never repeats its own complaint.
      Authorised by `docs/specs/2026-08-08-branch-triage-verdicts.md` (Branch 3,
      LAND items 1–2), so no new spec. Recovered from
      `claude/repo-status-update-n5z63h`, the last unlanded file across either
      repo's branches. **The evidence was this session:** every one of its five
      detection signals fired here — a Done entry false twice over, a second
      half-true for a day, a spec calling a branch "already merged" when it was
      not, a "byte-identical" claim wrong when written, an open item held on a
      branch that no longer existed. All of it surfaced from an audit that
      happened to be run. Two costs taken deliberately rather than waved past:
      `docs/retro-log.md` becomes a fourth contention file, so the command
      carries a pull-before-appending note in Step 5, and `HUB-CHECKLIST.md`'s
      new item marks `/retro` **optional** and periodic — it does nothing
      useful in a vault with no session history. No version bump;
      `hub-template/` is copy-source, not a plugin (2026-08-09)

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

- [ ] **Run `agent-bodies-reference/bootstrap.sh` on the machine this repo
      was cloned to under `C:\Users\tlelo\Downloads\`** — and check whether
      Operations and Pappa T ever had it run either. Logged 2026-08-03 as a
      manual "copy these files" step after
      `docs/specs/2026-07-29-strip-dcoe-roster-agent-bodies.md` stopped the
      plugin shipping agent bodies; discovered when dispatching the
      `reviewer` agent found no agent files anywhere on that machine.
      **As of 2026-08-08 there is a script for it** — recovered from a
      stranded branch, idempotent and rerun-safe — so this is one command
      now, not a copy-by-hand. Two things changed with it: the roster is
      **10 files, not 9** (`explore.md` was added the same day, and a
      machine missing it silently falls back to Sonnet-priced search), and
      `CLAUDE.md`'s session-start check now warns when any are missing.
      Note this is the same command the pending rollout item needs, so doing
      the rollout covers this for Operations and Pappa T.

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
- [ ] **Confirm whether the desktop CLI has the mobile app's slash-command
      restriction** — `/continue` returns "isn't available in this
      environment" on a Default-type mobile session (2026-07-19). If the CLI
      is affected too, the note now in `hub-template/continue.md` needs
      upgrading from a surface quirk to a much bigger problem.
- [ ] **Decide whether to implement the JSON-validation pre-commit hook** —
      spec recovered as Draft at `docs/specs/2026-08-05-json-validation-hook.md`,
      already Codex-reviewed. Hard rule 3 is self-monitored until then.
- [ ] **Delete the triaged branches** — **now fully unblocked**, both halves.
      `retro.md` landed 2026-08-09, which was the last held decision.
      **4 config-repo branches and 14 hub branches** (corrected
      2026-08-09; the spec's original 3 and 13 were both wrong). Verdicts and
      live per-branch figures in
      `docs/specs/2026-08-08-branch-triage-verdicts.md`, whose 2026-08-09
      amendment supersedes its own summary tables. The hub's
      `claude/pr-template-linear-planning-40hnrd` was the one exclusion — it
      held the only file either repo's branches still had that `main` lacked —
      and that file landed on the hub's `main` (`8a3fd14`), so **all 14 hub
      branches are cleared**, re-measured at 0 unique files each after the
      merge. The other held decision this used to wait on (`/overwatch`) is
      resolved. The four config-repo branches are cleared too, but **by
      verdict, not by measuring zero** — three still carry `dcoe-roster/agents/*`
      (deliberately stripped 2026-07-29) and one also carries `end-session.md`
      and `session-log.md` (both superseded). The spec's config deletion sheet
      tabulates exactly which files are expected on each; confirm the remaining
      files match it and nothing new has appeared, since the hub's "0 unique"
      check does **not** apply on this side.
      **Machine-bound — a cloud session cannot do this half.** `git push origin
      --delete` returns HTTP 403 for all 14: not the egress policy (the proxy
      logged no failure and ordinary pushes succeed), but the session's git
      credentials, which create and update refs but cannot delete them, with no
      delete-ref tool on the GitHub MCP server either. Run it from Operations
      or Pappa T, or from the GitHub web UI. **Ready-to-paste command and every
      branch's tip SHA are in the spec's "Deletion sheet" section** — the SHAs
      are what make the deletion reversible, so use that block rather than
      re-deriving the list.
- [ ] **Run `/codex-review` on both 2026-08-08 specs from Pappa T, or record
      a waiver** — `2026-08-08-model-routing.md` and
      `2026-08-08-unmerged-branch-checks.md`. Universal hard rule 9 wants the
      pass on every spec before an Executor runs; both were approved and
      implemented the same day without it, because codex-gate is a
      per-machine install and this session ran in a cloud container. Both
      changes are already committed, so these are **retrospective** reviews:
      anything Codex raises becomes a follow-up fix, not a revert. Recorded
      here rather than left to lapse quietly — the model-routing one changes
      what both machines install.
- [ ] **Verify or drop the "introductory pricing ends 31 August 2026" claim**
      in `CLAUDE.md.template` (~line 164), which advises scheduling bulk
      batch jobs before that date. 22 days out as of 2026-08-08 and
      unverified — deliberately left out of the model-routing spec as a
      separate factual question.
- [ ] **Adopt the Phase 6 branch checks in the `Claude-Code` hub's own
      `.claude/commands/` copies** — the templates here have them as of
      2026-08-08; the hub's instances are separate files in a separate repo
      and do not yet. Run `HUB-CHECKLIST.md` against that vault.
### From 2026-08-09

- [ ] **Evaluate feasibility of adopting Linear** for project management —
      raised alongside the PR-template task and deliberately left unstarted;
      explicitly out of scope in
      `docs/specs/2026-08-09-pr-templates.md`. Wants a findings doc
      (recommendation, blockers, open questions) in the shape of the
      2026-07-21 codex-gate readiness audit, covering whether it replaces or
      merely duplicates the `docs/todo.md` + `docs/session-log.md` pair, how
      it behaves with two machines plus concurrent cloud sessions, and what
      changed for it now the Fan Movement contract has terminated.
- [ ] **Confirm the PR templates behave on the next real PR in each repo** —
      two acceptance criteria from `docs/specs/2026-08-09-pr-templates.md`
      cannot be checked from a cloud container: that GitHub pre-fills the body
      with no `?template=` parameter, and that nothing blocks a merge. The
      pre-fill is the one that matters — it is the entire reason a single
      default template was chosen over a chooser directory.
- [ ] **Record the CORE 1.5 roster-autodeploy work in this list** — commit
      `ab95eef` (`bootstrap.mjs`, `roster-manifest.json`, the `dcoe-roster`
      `SessionStart` hook, CORE 1.4 → 1.5) is on `main` in both repos with no
      Done entry here, in breach of hard rule 5. Two knock-on drifts to fix in
      the same pass: `CLAUDE.md`'s session-start block still names
      `bootstrap.sh` as the fix for a missing roster, and the Open item above
      about re-running `bootstrap.sh` by hand describes the manual step 1.5
      was built to obsolete.

- [ ] **Phase 7 of the maintenance plan remains**: hub hygiene and
      governance — a root `.gitignore` (31 MB installer, logs and generated
      images are tracked today), and the contradiction between the hub's
      hard rule 4 and the company data actually living in `Operations/`.
