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

- [x] **Installed `/retro` in the `Claude-Code` hub and re-ran
      `HUB-CHECKLIST.md` against it** — closing the "adopt the Phase 6 branch
      checks in the hub" item, which was **half stale when its own addendum was
      written**. The hub adopted `/continue` Step 1.8 and `/session-end`
      Step 1.5 on 2026-08-09, recorded in both the hub's `docs/todo.md` and its
      `docs/session-log.md`; the addendum added here later that day said "one
      pass over three commands, not two" without re-reading the sentence above
      it. One command was outstanding, not three. Fifth instance this week of a
      queue entry asserting state it did not have — and the first signal
      `/retro`'s own Step 2 is written to detect, in the item that sent a
      session to redo finished work the day before `/retro` existed.
      Landed in the hub: `.claude/commands/retro.md`, tailored per ADR-008
      (its real paths, the "most recent last" log convention with the
      `grep -n "^## " | tail` idiom since that file is 3,000 lines, the
      hub-and-spoke boundary on whose friction counts, and the
      `hub-template/`-is-copy-source note); `docs/retro-log.md` wired in as
      the hub's **fourth** contention file across Hard Rule 6, `/continue`
      Step 1.75 and `/retro` Step 5; and `CLAUDE.md` now names `/retro` as
      periodic rather than part of the routine pair.
      **The checklist's diff-don't-assume rule found three drifts unrelated to
      the task**, which is the point of running it rather than trusting a copy
      made 12 days ago. Two folded into the hub: the mobile slash-command
      known-gap note (template-only since 2026-07-19, never copied to a hub
      whose owner uses the mobile app) and Step 1.75's
      conflicts-≠-misordering caveat. One folded the other way — the hub's
      `--include=*.md` grep gotcha was a local improvement the template
      lacked, now **promoted upstream** into `hub-template/continue.md`, the
      only change in this repo. ADR-008's file-copy distribution makes drift in
      both directions the expected state; only running the diff surfaces it.
      No version bump; `hub-template/` is copy-source, not a plugin
      (2026-08-09)

- [x] **Gave `HUB-CHECKLIST.md` an install item for `session-end.md`** — it
      had one for `continue.md` and one for `retro.md`, but named
      `session-end.md` exactly once in the whole file, in passing, inside the
      branch-checks item that assumes it is already installed. A vault worked
      through the list end to end therefore installed **half of ADR-008's
      resume/close-out pair and passed every check** — the same class of silent
      gap the checklist was written to catch for Pappa T, reproduced inside the
      checklist itself. New item placed second, next to `continue.md`, since
      the two are a pair and only `retro.md` is optional. It mirrors the
      `continue.md` item's copy-or-diff structure and adds the two failure
      modes specific to this file: a hub instance typically adds steps the
      template lacks, so every "report it in Step N" cross-reference has to be
      re-checked against the *report* step rather than trusted (the hub's own
      copy had exactly this off-by-one, pointing Step 1's findings at its title
      step until 2026-08-09), and the template is deliberately generic about
      whether a vault keeps a session log, a knowledge cache, or which
      contention files to pull before writing — all of which the copy must
      answer. Verified against the hub's instance, which passes the new item on
      both counts. No version bump; `hub-template/` is copy-source, not a
      plugin (2026-08-09)

- [x] **Landed the hub's `/retro` install — the half of the 2026-08-09 entry
      two above that never merged.** That entry states "Landed in the hub:
      `.claude/commands/retro.md`, tailored per ADR-008 … `docs/retro-log.md`
      wired in as the hub's fourth contention file … `CLAUDE.md` now names
      `/retro` as periodic." **None of it was on the hub's `main`** when this
      session started. Both repos had a branch named
      `claude/continuation-45sy98`; the config-repo half merged as PR #20, the
      hub half never got a PR, so all five files sat unmerged for a day while
      this queue recorded them done. Exactly the shape of the PR-template entry
      before it, and the **sixth** entry in three days asserting state it did
      not have — in the item installing the command written to detect that.
      Found by `/continue` Step 1.5's second measure (files present on a branch
      and absent from `main`): across 15 unmerged hub branches, `retro.md` was
      the only file `main` lacked; the ancestry check alone said "15 unmerged"
      and nothing more. **Landed by cherry-pick, not hand extraction** — unlike
      the PR-template branch, this one was **0 commits behind `main`**, so the
      commit applied verbatim; the triage's extract-don't-merge rule still holds
      for the other 14, which are genuinely stale. Content unchanged from what
      was reviewed on 2026-08-09, original commit date preserved. Recovery
      recorded in the hub's `docs/session-log.md`; its `docs/todo.md` needed no
      entry, since the cherry-pick carries the original. No version bump —
      `.claude/commands/` ships in no manifest (2026-08-10)

- [x] **Corrected the self-titling claim in all three `/session-end`
      instances** — `hub-template/session-end.md` Step 3, this repo's Step 3,
      and the hub's Step 5 all stated a session has **no way to obtain its own
      ID**, so "no call can be constructed and there is no error to report."
      True of the CCD desktop surface it was confirmed on (2026-08-06); false
      on Claude Code Remote. **Verified live before rewriting, per hard rule
      10, and the claim was wrong on both of its two counts** — not just the
      one the open item recorded. The session ID is in the session URL
      verbatim, `get_session` accepts it, and `list_sessions` does **not**
      exclude the current session: it comes back as the *first* row. Direct
      proof it has always worked on this surface: sessions titled
      `Cont-"Branch triage reconciled, retro landed"` and `Cont-"Systems check
      + maintenance Phases 1-6"` are in the account's own list. Each file now
      splits the two surfaces explicitly and reports **three** outcomes rather
      than two — set / attempted-and-refused / genuinely unidentifiable — since
      a permission denial is an ordinary failure and calling it "not available
      in this environment" claims something stronger than what happened. The
      Step 4/6 report line gained the third outcome to match. The hub's
      instance also dropped its "this hub's usual surface" framing, which named
      the desktop case as typical while most of the hub's sessions run remote.
      No version bump; `hub-template/` is copy-source and `.claude/commands/`
      ships in no manifest (2026-08-10)

- [x] **Closed the three remaining codex-gate rollout items** — install +
      network-off smoke-test on Pappa T, the ADR copy into the Operations
      hub's `docs/decisions/`, and the Fan Movement IT egress question. All
      three resolved in the `Claude-Code` hub, not here: smoke-test closed
      2026-08-03 (that hub's `docs/todo.md` Done section), ADR copy done
      2026-07-29 directly via git (recorded as
      `ADR-009-codex-second-opinion-gate.md`), IT egress confirmed covered
      2026-07-28 — the last of these recovered 2026-08-12 from a stranded
      branch (`claude/continuation-sqlkfd`), 15 days after it was originally
      answered. **Caveat on the IT answer's practical weight, not its
      settledness:** the Fan Movement contract was terminated 2026-08-03,
      five days after IT confirmed the egress question — the answer stands,
      what it was for changed. Reconciled here 2026-08-12.

- [x] **Recorded the CORE 1.5 roster-autodeploy work, and fixed the two
      knock-on drifts it left.** Commit `ab95eef` (`bootstrap.mjs`,
      `roster-manifest.json`, the `dcoe-roster` `SessionStart` hook, CORE
      1.4 → 1.5) landed 2026-08-09 with no Done entry here — closing that
      gap closes two Open items that described the pre-1.5 world:
      **"Run `bootstrap.sh` on the Downloads-cloned machine"** and
      **"Roll out dcoe-roster 3.6.0 + CORE 1.4 + template v3.5 on both
      machines"** both described a manual per-machine step 1.5 was built to
      obsolete — the roster now deploys itself on `SessionStart`,
      missing-only, wherever the `dcoe-roster` plugin loads. Also fixed
      `CLAUDE.md`'s three stale references (the session-start check, the
      project-overview bullet, the agent-edit-propagation note) that still
      named `bootstrap.sh` as *the* fix — it is now documented as the
      pre-1.5 manual fallback, not the live mechanism. Reconciled 2026-08-12.

- [x] **Delete the triaged branches — both halves, verified directly rather
      than by re-running the deletion sheet.** `git branch -r --no-merged
      origin/main` returns empty in both this repo and the `Claude-Code` hub
      as of 2026-08-12. Hub side: 0 remain — the last 9 (the 2026-08-10
      session-log-recovery triage's 8, plus `new-game-drivers-update-1hp4dq`
      found during that cleanup) were deleted 2026-08-12 after their unique
      `docs/session-log.md` entries were recovered into `main` first, on top
      of whatever this item's own last recorded count (15) had already
      brought toward zero. Config-repo side: 0 remain too — this item's own
      text recorded that half as **machine-bound** (`git push origin
      --delete` returning HTTP 403 from a cloud container), so it was
      cleared from a different session surface than this reconcile pass, not
      independently re-verified against the deletion sheet's per-branch file
      list — only against the empty ancestry check. Reconciled 2026-08-12.
      **Correction, same day:** the "0 remain" / "empty ancestry check" claim
      for the config-repo side was itself wrong when written — commit
      `791539f` (same day, "docs: correct overclaimed branch-deletion status
      in todo.md") had already re-verified that all 4 config-repo branches
      named in the 2026-08-08 triage sheet (`repo-status-update-n5z63h`,
      `config-audit-gap-report-aew9g7`, `continuation-yon8p3`,
      `continuation-utn4f5`) were never deleted — same tip SHAs, still HTTP
      403 on delete — but this entry was not updated to match, so the two
      entries contradicted each other in the same file. A live
      `git merge-base --is-ancestor` check run 2026-08-12 confirms: those 4
      are still unmerged, plus 2 more opened the same day
      (`continuation-ksd8pz`, `continuation-n6vvc6`, outside the original
      triage sheet) — **6 unmerged config-repo branches as of this check**,
      not 0. Hub-side "0 remain" is unaffected by this correction — that half
      was independently verified, per the text above.

- [x] **Ran `/retro` for the first time in the `Claude-Code` hub** — done
      2026-08-10, per that hub's own `docs/session-log.md`/`docs/todo.md`
      Done entries ("First `/retro` run: six patterns, six selected"). All
      six proposed patterns were selected; the four universal ones are the
      "From the first `/retro` run" section below. Reconciled 2026-08-12.

- [x] **Get the roster onto cloud sessions** — spec at
      `docs/specs/2026-08-12-roster-cloud-sessions.md`, approved and
      implemented same day, commit `3f31b17`. Chose Option B1 (repo-level
      hook, not vendoring agent bodies per-repo): new
      `hub-template/hooks/cloud-roster-bootstrap.sh`, copy-installed same as
      `secret-scan.sh`/`auto-format.sh`, no-ops unless `$CLAUDE_CODE_REMOTE`
      is set, otherwise clones `tlelosa-claude-config` shallow and runs the
      existing `bootstrap.mjs` — one implementation, two delivery paths
      (plugin hook for Operations/Pappa T, this hook for cloud sessions).
      **Live-tested in this session, not just described:** first run
      installed all 10 agents in ~1.3s, a repeat run no-op'd in 6ms, a
      non-remote run no-op'd immediately. CORE 1.5 → 1.6, template 3.5 →
      3.6, `dcoe-roster` plugin 3.7.0 → 3.8.0; also fixed
      `roster-manifest.json`'s `coreVersion`, found stale at `"1.4"` during
      this pass. Reviewer Loop: both `codex-gate` and the roster's own
      `reviewer` agent are unavailable on this cloud session — the exact gap
      the task closes — so the review was self-conducted and logged as
      retrospective, same handling as the 2026-08-08 specs. **All three PRs
      merged and independently verified against each repo's fetched default
      branch (not just the merge API response):** `tlelosa-claude-config`
      PR #25 (`3f31b17`, merged as `7e16c86`), `Claude-Code` PR #20
      (`f343869`, merged as `9f9020b`), `ai-product-factory` PR #1
      (`a691620`, merged as `0dcdd6e` — note this repo's default branch is
      `master`, not `main`). All confirmed with
      `git merge-base --is-ancestor <sha> origin/<default-branch>` after a
      fresh fetch.

## Open

> Machine-side items below are consolidated into one ordered run per
> machine in `docs/rollout-checklist-2026-07-21.md` — work from that,
> tick here as each block passes.

### From the 2026-08-08 systems check

- [x] **Decide: bash vs PowerShell for `hub-template/hooks/secret-scan.sh`
      and `auto-format.sh`** (deferred 2026-08-08; resolved 2026-08-12).
      Decision: keep both as bash. Operations and Pappa T Windows machines
      need git-bash on PATH — verified as already present for other scripts.
      Single bash implementation avoids duplication, cloud sessions (Linux)
      require bash anyway. No `.ps1` equivalents needed. Next step: verify
      git-bash is on PATH on both machines during rollout.
- [ ] **Confirm whether the desktop CLI has the mobile app's slash-command
      restriction** — `/continue` returns "isn't available in this
      environment" on a Default-type mobile session (2026-07-19). If the CLI
      is affected too, the note now in `hub-template/continue.md` needs
      upgrading from a surface quirk to a much bigger problem.
- [x] **Decide whether to implement the JSON-validation pre-commit hook** —
      spec at `docs/specs/2026-08-05-json-validation-hook.md` (Codex-reviewed).
      **Implemented 2026-08-12:** `.githooks/pre-commit` created, CLAUDE.md
      updated with session-start check, ESSENTIAL COMMANDS, and hard rule #3
      note. Commit: `3887017`. Next step: per-machine `git config core.hooksPath .githooks`
      during rollout.
- [ ] **Run `/codex-review` on both 2026-08-08 specs from Pappa T, or record
      a waiver** — `2026-08-08-model-routing.md` and
      `2026-08-08-unmerged-branch-checks.md`. Universal hard rule 9 wants the
      pass on every spec before an Executor runs; both were approved and
      implemented the same day without it, because codex-gate is a
      per-machine install and this session ran in a cloud container. Both
      changes are already committed, so these are **retrospective** reviews:
      anything Codex raises becomes a follow-up fix, not a revert. Recorded
      here rather than left to lapse quietly — the model-routing one changes
      what both machines install. **Status 2026-08-12:** Cloud container has no
      codex-gate; this session cannot run the review. Deferred to Pappa T session.
- [x] **Verify or drop the "introductory pricing ends 31 August 2026" claim**
      in `CLAUDE.md.template` (~line 175). **Dropped 2026-08-12:** Claim was
      unverifiable (knowledge cutoff Feb 2025; claim references Aug 2026).
      Specific date predictions become stale quickly. Replaced with general
      cost-awareness guidance + link to live pricing. Commit: `0acf65d`.

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
- [x] **Record the cloud-session ref-deletion blocker in the hub's knowledge
      cache** — `git push origin --delete` returns HTTP 403 from a Claude Code
      cloud container for every branch, while ordinary pushes to the same
      remote succeed. Root cause: session credentials can create/update refs
      but not delete them. Workaround: delete from Operations/Pappa T or
      GitHub web UI. **Recorded in `Claude-Code/knowledge/cloud-sessions.md`
      on 2026-08-12**, commit `add8b55`. Includes scope note that this was
      measured on restricted-access cloud container, not full-filesystem-access
      CCR sessions.

### From the first `/retro` run (2026-08-10)

> First run in the `Claude-Code` hub, unbounded per its Step 1 — all 47
> `session-log.md` entries (2026-07-28 → 2026-08-10) plus the full hub queue.
> Six patterns proposed, all six selected. The four below are **universal**
> and land here per ADR-008; two hub-scoped ones (count hygiene, known-risks
> deferral) are queued in the hub's own `docs/todo.md`. Run recorded in
> `Claude-Code/docs/retro-log.md`.

- [ ] **New `CORE.md` hard rule: a record is not a control** — **structural,
      spec required, core version bump (1.6→1.7).** Spec drafted at
      `docs/specs/2026-08-12-record-is-not-control.md` on 2026-08-12. Commit:
      `34d85fa`. **Status: Draft, awaiting reviewer agent approval.** The rule:
      a session recording a lesson must install it in an executable location
      (command file, hook, manifest, deployment script) in the same session,
      or file a queue item naming the exact file. Recording alone never
      discharges the obligation. Enforcement: self-monitored by process +
      reviewer check. Basis: highest-evidence pattern from first `/retro` run —
      six false/stale Done entries in three days, all care failures from gap
      between "wrote it down" and "verified it's true".

- [x] **Made `/session-end` Step 1.5 per-repo, not per-session** — both
      half-landed pairs of the last two days came from sessions that pushed
      **two** repos and opened a PR for **one**. The PR template (2026-08-09)
      and `/retro` itself (2026-08-10) each sat stranded for a day while the
      queue recorded them done; the 2026-08-09 roster entry independently calls
      "a branch with no PR" the documented stranding failure. Step 1.5 existed
      precisely to stop this and did not fire, because a session that opened
      *a* PR looks finished. Fixed in all three instances —
      `hub-template/session-end.md`, this repo's `.claude/commands/session-end.md`,
      and the `Claude-Code` hub's `.claude/commands/session-end.md` — Step 1.5
      now explicitly says to list every repo the session touched and run the
      reachability check (and Step 4/6's report) once per repo, not once for
      wherever the session happens to be sitting. No version bump;
      `hub-template/` is copy-source and `.claude/commands/` ships in no
      manifest (2026-08-12)

- [ ] **Require a Done entry to cite a SHA on `main`** — Spec drafted at
      `docs/specs/2026-08-12-done-sha-citation.md` on 2026-08-12. Commit:
      `34d85fa`. **Status: Draft, awaiting reviewer agent approval.** The
      requirement: Done entries claiming file delivery must verify with
      `git log origin/<branch> --oneline -- <path>` before writing. Entry is
      not written if verification fails. Implementation: add Step 3.5 to all
      three `/session-end` instances (hub-template + two project copies).
      Basis: six false landing claims from 2026-08-09 through 2026-08-12, all
      care failures from gap between "wrote it down" and "verified it's on main".


- [ ] **Phase 7 of the maintenance plan remains**: hub hygiene and
      governance. Spec drafted at `docs/specs/2026-08-12-hub-phase-7-hygiene.md`
      on 2026-08-12. Commit: `49dfe3a`. **Status: Awaiting owner decision** on
      two governance-level issues: (1) Root `.gitignore` for large files (31 MB
      installers, logs, generated images currently tracked); patterns needed +
      owner input on exclusions. (2) Company-data contradiction: hub hard rule
      #4 says "no company data" but `Operations/` snapshot contains it (Fan
      Movement closure, deliberate staging). Needs clarification: rule applies
      to git history not filesystem, or move/delete the copy. No technical
      blocker; owner call required.
