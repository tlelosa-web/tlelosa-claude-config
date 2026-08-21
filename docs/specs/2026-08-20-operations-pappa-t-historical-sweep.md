# Spec: Operations/Pappa T historical-reference sweep

**Date:** 2026-08-20
**Status:** **IMPLEMENTED 2026-08-20.** `tlelosa-claude-config` `d00f103`,
`Claude-Code` `53f808c`, `ai-product-factory` `93bfae6`. Pass 6 review could
not complete (this account's monthly spend limit was hit mid-pass); the
dispatching session's own read-through of the full spec stood in as the
final check before execution, per the editorial decision recorded at the
end of the pass-5 amendment entry below (five rounds of real,
shrinking-severity findings judged sufficient to treat content as
converged).
**Review history:** Reviewed (general-purpose@opus simulating `reviewer`, per the
2026-08-20 workaround in `Claude-Code/knowledge/cloud-sessions.md` — no
`reviewer` sub-agent type registered in this environment). **Pass 1: BLOCK**
(survey gaps, one internal scope contradiction, a Hard Rule 7 count
violation, a miscited rule). **Pass 2: BLOCK** (two more survey gaps of the
same class — `ai-product-factory/knowledge/`'s own copies of three files,
and two more live-copy assertions in `Claude-Code/docs/todo.md` outside
Done — plus two errors the pass-1 fold-in itself introduced, a wrong entry
date and a wrong count/attribution). **Pass 3: BLOCK** (one more survey gap
of the same class — the `## Backlog / ideas` section of the same
`docs/todo.md`, never reached by any prior pass — plus a miscited precedent
in the pass-2 exception clause and an INDEX.md row left carrying the wrong
instruction verbatim). **Pass 4: BLOCK** (root cause identified for the
recurring miss: a plain `Operations|Pappa T` grep is structurally blind to
"both machines"/"each machine"/"employer machine" phrasing, which is how
`tlelosa-claude-config/CLAUDE.md` Hard Rules 1/3, `Claude-Code/CLAUDE.md`
Hard rule 6, and a `docs/todo.md` Phase 7a rationale all survived three
prior passes; plus a whole `knowledge/tlelosa-claude-config.md` file with
three `Status: active` entries never brought into scope). **Pass 5: BLOCK**
(the root cause itself was incomplete — hard-wrapped prose defeats a
pattern search regardless of pattern width, and the real recurring shape is
document *position*: preambles and index rows that restate a claim about
content elsewhere, which a bullet-and-file inventory doesn't cover. Found
one more preamble, one misattributed quote, and two more INDEX.md rows
needing in-place correction). All five passes' findings folded in; see
Amendment log. `/codex-review` (Hard Rule 9, advisory, cross-family) has not
run — `tlelosa-claude-config/docs/todo.md`'s own record shows codex-gate is
not runnable from a cloud container. Per that same item's precedent, this is
recorded as a **waiver**, not a silent skip: if dispatched from a session
with codex-gate installed, run it first; otherwise proceed on the reviewer
pass alone and note the waiver in the Done entry.
**Origin:** `tlelosa-claude-config/docs/todo.md` → Open → "Full Operations/Pappa T
historical-reference sweep — deferred, not done."

## 1. Scope, precisely

2026-08-20's narrow fix (`58ea03d`) retired Operations/Pappa T **rollout
mechanics only** in this repo. This spec covers the rest: every `CLAUDE.md`,
`docs/todo.md` (Open section only — Done is a record), and `knowledge/` entry
across `Claude-Code`, `tlelosa-claude-config`, and `ai-product-factory` that
**asserts Operations and/or the `tlelosa-web/pappa-t` vault as live, currently
reachable machines**, where that assertion is no longer true.

**Explicitly out of scope, per the same distinction the 2026-08-20 fix already
drew:**
- `docs/session-log.md` / `docs/session-logs/` — a record of what happened
  in a specific past session; each entry is its own dated moment and stays
  as it was written, on the same logic `Claude-Code/CLAUDE.md` Hard Rule 2
  applies to `knowledge/` entries ("superseded, not deleted") even though
  that rule is written about `knowledge/` specifically — session logs get
  the same treatment by the same reasoning, not by that rule's literal text.
- `docs/specs/*` (dated specs) — same reasoning; a spec records the plan as
  it stood on its date.
- `knowledge/*.md` **dated entries themselves** — each entry is timestamped
  and records what was true *then*. Rewriting them would violate the "record,
  not deleted" convention. Where a topic file's entries as a whole describe a
  now-retired machine as ongoing reality, the fix is a **top-of-file banner**
  (the precedent already set for `Claude-Code/knowledge/pitwall-companion.md`
  on 2026-08-17/08-20 for a moved repo), not editing the entries. **One
  exception, not a loophole, and a new convention rather than a cited one**
  (the `sops.md`/`daily-sales-order-files.md` corrections this spec cites
  elsewhere are in undated header prose, not inside a dated entry — no
  in-entry-correction precedent actually exists in this repo yet): an entry
  that itself states standing instruction ("do X by using surface Y") rather
  than only a fact-as-of-date may get a dated correction *appended in
  place*, because the instruction, if left uncorrected, actively misdirects
  a future reader — different from rewriting what the entry says happened.
  `knowledge/cloud-sessions.md` in §2 is the one place this *append*
  mechanism applies — a different file, `knowledge/tlelosa-claude-config.md`
  (added to §2 below), also needs a fix for the same underlying reason
  (standing instruction inside `Status: active` entries), but gets the
  ordinary top-of-file banner instead, because there its entries as a whole
  describe the retired split as ongoing rather than carrying one correctable
  workaround line.
- The `Operations/` and `Pappa T/` subtree-snapshot folders inside
  `Claude-Code` (their own nested `CLAUDE.md`/`docs/todo.md`/specs/etc.) —
  these are those sub-projects' own historical git history, out of this
  hub-level sweep's scope entirely (a separate, larger question already
  flagged in `Claude-Code/docs/todo.md`'s "private key committed" and
  retention items).
- **Exactly three lines** in `ai-product-factory`'s own `CLAUDE.md`/
  `docs/todo.md` — `CLAUDE.md:3` ("hub project... on Pappa T"), `docs/todo.md`'s
  `**Machine:** Pappa T (Windows)` line, and `CLAUDE.md`'s `/codex-review`
  note ("Pappa T — this machine is cleared for it"). **Investigated, not
  assumed:** `docs/session-logs/2026-08-20-dcoe-roster-hook-fix.md` narrates
  the owner live-starting a real Claude Code session on that machine, dated
  the same day as the retirement fix — a physical workstation demonstrably
  alive on the retirement date, in the *host-machine* sense these three
  lines use. That is different from `tlelosa-web/pappa-t`, the personal
  vault/repo the 2026-08-20 fix retired. These three lines are left
  untouched on that basis.
  **This does not extend to every "Pappa T" hit in `ai-product-factory`** —
  the repo also uses "Pappa T" in the *vault* sense, same word, different
  referent: `docs/session-logs/2026-08-11-git-audit-and-dashboard-planning.md`
  edits a `Pappa T/.gitignore`, and `Projects/dashboard/lib/vaults.ts`
  hardcodes `C:\Users\tlelo\Pappa T` and `C:\Users\tlelo\O-P-C` as tracked
  vault roots. `vaults.ts` is application code, not docs, so it's out of
  this docs-only sweep's file-type scope by construction — but it is *not*
  covered by the host-machine exemption above, and is named here rather than
  silently dropped (Hard Rule 11, "a record is not a control" — the gap
  needs to be visible, not just true). Whether those hardcoded vault paths
  still resolve on the current host is a question for whoever next touches
  `vaults.ts`, not this spec.

## 2. Files in scope, by repo

### `Claude-Code`

- **`CLAUDE.md`** — the section headed `## 📍 Live copies vs. this repo's
  snapshot` presents Pappa T as "back... live again at `~/Pappa T/`, backed
  up daily" in present tense, and the section under `The one script:`
  describes `VAULTS` pointing at a live, currently-running daily task. Both
  need a retirement note in the same voice as the `tlelosa-claude-config`
  precedent (`58ea03d`): state what's retired, when, and that the file's own
  narrative below is historical record of the restore, not current state.
  Do **not** delete the restore narrative — it's the record of real
  incident response (the three defects found 2026-08-10) and stays valuable
  as history once correctly framed as past. A third spot in the same file
  needs the same treatment and was missed by a proper-noun-only search:
  Hard rule 6's rationale clause — *"with Operations, Pappa T, and cloud
  sessions all able to run concurrently, stale-base edits to these four
  files have already caused two real merge conflicts"* — states present
  tense outside either named section. The rule itself (pull before editing
  a contention file) survives on cloud-session concurrency alone; only the
  rationale needs past-tensing.
- **`docs/todo.md`** (Open section only):
  - `## In progress` → "O-P-C machine consolidation": *"`Operations` and
    `Pappa T` Desktop folders deliberately **kept, not superseded** — both
    hold live gitignored data with no other copy."* Both folders were
    deleted 2026-08-10 (recorded elsewhere in this same file) — this bullet
    asserts them as currently held. Needs a retirement note, not a rewrite
    of the historical reasoning below it (SOPS's/delivery-note-system's data
    genuinely wasn't captured by the subtree merge — that fact stays; only
    "deliberately kept" needs correcting to past tense).
  - `## Next up` section preamble (the 2026-08-03 re-flag note governing the
    three 📍 items below): *"Operations and Pappa T are now physically on
    this same machine… work must happen in the **live** Desktop copy."* This
    is the preamble that *introduces* the three 📍-flagged items this spec
    already re-flags as blocked — leaving it unedited while re-flagging the
    items it governs would make the section contradict itself the moment
    this sweep lands. Must be corrected in the same pass as the three items,
    not separately.
  - Item 1, TebelloReborn Indeed adapter — 📍-flagged to
    `~/Pappa T/TebelloReborn/`, "Resume here: step 140". If Pappa T is
    retired, this item is now **blocked on a reachable machine**, same shape
    as the codex-review item `tlelosa-claude-config` already re-flagged
    (`58ea03d`'s todo.md diff). Needs the same treatment: mark blocked, state
    why, don't silently drop the resume-point detail.
  - Item 2, SOPS AvgMovement migration — 📍 "Must run against
    `Desktop/Operations/2. SOPS/instance/sops.db`". Same treatment: Operations
    is retired, so this is blocked pending a reachable machine, not silently
    still-actionable.
  - Parked → NamePlateTool test suite — 📍 "build in the live
    `Desktop/Operations/3. Nameplate & Test Sheet/`". Same treatment.
  - The `## ⚠️ Open decisions` **section's own preamble** carries a fourth
    live assertion no prior pass caught: *"(The `VAULTS` decision was taken
    2026-08-10 — Pappa T restored to `~/Pappa T` and coverage resumed. See
    Done.)"* — twin of the `CLAUDE.md`/Backlog backup claims already in
    scope; correct to past tense in the same pass as the Desktop-path
    bullet it introduces.
  - The "⚠️ Open decisions" section's **private-key** and
    **delivery-note-system-no-copy** items are already correctly framed as
    open owner decisions about a past deletion — no live-machine assertion,
    leave as is. The **Desktop-path-staleness item is not** — on inspection
    it asserts, present tense and unchecked: *"Pappa T is at `~/Pappa T`,
    this hub is at `~/O-P-C`, and Operations is not coming back."* That's
    the identical live-location claim flagged for a retirement note in
    `CLAUDE.md`'s live-copies section below — this bullet gets the same
    blocked/retired annotation, not a pass. (Count deliberately not stated
    per Hard Rule 7 — read the section, don't trust a number here.) The
    bullet's own body carries a now-stale sub-claim beyond its headline —
    "with Operations gone and **Pappa T the only one left**, the step needs
    re-scoping rather than re-pathing" — needs correcting too, not just the
    bullet's opening quote.
  - `## Backlog / ideas (not committed)` → "Decide whether backup failures
    should alert": *"the backup itself is running and verified."* Twin of
    the `CLAUDE.md` backup-script assertion above — same section, same fix.
    Also in that section, "Fold `rev-parse --show-toplevel` back down into
    this hub's Step 1.9" names `Desktop/Pappa T/` and Operations' `2. SOPS`/
    `3. Nameplate` as Step 1.9's current layouts — checked and left alone,
    covered by §4's command-file file-type exclusion (Step 1.9 lives in
    `continue.md`) rather than silently unmentioned (Hard Rule 11).
  - `## Next up` → Phase 7a, root `.gitignore`: *"Do not rewrite history —
    that breaks every existing clone on **both machines** plus any cloud
    session."* Same "both machines" phrasing that made Hard rule 6 and the
    `tlelosa-claude-config` Hard Rules miss a proper-noun-only grep — the
    item's conclusion (don't rewrite history) survives on the cloud-session
    clause alone; only the rationale needs a one-clause past-tense fix.
  - Do not touch `## Done` — those are dated records of what already
    happened, already correctly past-tense.
- **`knowledge/operations-hub.md`** — needs a top-of-file RETIRED banner
  (Fan Movement contract terminated 2026-08-03, Operations retired
  2026-08-20), same pattern as the pitwall-companion MOVED banner. Dated
  entries below stay untouched.
- **`knowledge/pappa-t.md`** — same treatment: top-of-file RETIRED banner
  noting the `tlelosa-web/pappa-t` vault retired 2026-08-20 as of this
  sweep's own decision, entries below untouched.
- **`knowledge/tlelosa-claude-config.md`** — same banner treatment. Several
  `Status: active` entries describe the retired Operations/Pappa T machine
  split as ongoing reality — including the two `## 2026-07-23` entries
  ("Cloned on two machines: Operations (work PC) and Pappa T (personal)";
  "Needs its own confirmation before installing on Operations — Pappa T
  only until then") and the `## 2026-07-29` codex-gate entry ("codex-gate
  itself stays **Pappa T-only regardless**") — a reader opening this file,
  not just its `INDEX.md` row (already in scope below), would be
  misdirected, and the standing codex-gate-is-Pappa-T-only instruction
  directly contradicts `tlelosa-claude-config/CLAUDE.md`'s own
  post-retirement text. (The `## 2026-07-28` entry's "still need to be run
  on both machines" is **not** evidence for this bullet — that entry is
  itself marked `Status: superseded`, already correctly framed.) A banner
  is the right instrument here (not the append-mechanism used for
  `cloud-sessions.md`) because it's the entries' overall framing that's
  stale, not one isolated workaround line.
- **`knowledge/sops.md`, `knowledge/delivery-note-system.md`,
  `knowledge/daily-sales-order-files.md`** — each opens with **undated
  header prose above its first dated entry** describing a "live copy" at an
  Operations path (`sops.md`: "Live copy at `Desktop/Operations/2. SOPS`…
  currently the most DCOE-mature project"; similar in the other two). Undated
  header prose isn't a dated record, so it isn't covered by the
  dated-entries exemption in §1 — it needs the same in-place correction
  these files already use for their own prior path corrections (see
  `sops.md`'s "**Correction (2026-08-03)**" and `daily-sales-order-files.md`'s
  "path corrected 2026-08-09" — an established convention here, not a new
  one). **Excluded on inspection:** `knowledge/tebelloreborn.md` and
  `knowledge/nameplatetool.md` both open directly with a dated `## YYYY-MM-DD`
  entry, no undated header — in scope for nothing here, they're already all
  dated record. `tebelloreborn.md` specifically is one of the six files the
  Desktop-path-staleness bullet (§2's `docs/todo.md` list, below) names as
  affected — noted here so its exclusion from *this* bullet doesn't read as
  an oversight: it stays with the Desktop-path item, which is already in
  scope, rather than needing separate handling under this one.
- **`knowledge/cloud-sessions.md`** — two separate fixes, not one: (a) its
  `git push origin --delete` workaround entry (`## 2026-08-12`) reads *"delete
  branches from a surface with full git access — the Operations or Pappa T
  machine, or the GitHub web UI"* as standing, still-actionable instruction,
  not as a fact-as-of-that-date. Left as is, a future cloud session hitting
  that HTTP 403 is pointed at two machines that no longer exist. Fix with an
  inline correction appended to that entry (same "Path corrected" convention
  named above), not a banner — the entry's dated *finding* (the 403 itself)
  stays correct and untouched; only the now-wrong half of the workaround
  needs the note. (b) the file's own **undated header prose**, above its
  first dated entry — *"Machine-specific findings for Operations and Pappa T
  live in their own files"* — is a live pointer to those two now-retired
  files' machine-specific content, same category §2 already rules in scope
  for `sops.md`/`delivery-note-system.md`/`daily-sales-order-files.md`'s own
  undated headers; correct in place alongside (a), same commit.
- **`knowledge/INDEX.md`** — every row for a file changed above gets a
  one-clause pointer to whichever fix landed in that file, same as any
  other INDEX row summarizing its file's content (not a rewrite of the
  whole row) — **with three exceptions**, rows that themselves restate a
  wrong instruction or claim verbatim, so a session reading only the INDEX
  (not opening the file) would still be misdirected. These get corrected in
  place, same as the file they summarize, not just pointed-at:
  1. `cloud-sessions.md` row: "workaround is delete from Operations/Pappa T
     or GitHub web UI".
  2. `pappa-t.md` row: "**Pappa T-only items (codex-gate)**" — false now
     that `tlelosa-claude-config/CLAUDE.md` states codex-gate is installed
     in the `ai-product-factory` environment with no machine-split gate.
  3. `operations-hub.md` row: its closing clause, "**2026-08-10 (later):
     Pappa T restored to `~/Pappa T` and coverage resumed**" — the historical
     restore narrative it's summarizing stays, but "and coverage resumed"
     needs the same past-tense treatment as every other live-coverage claim
     in this sweep.
  Also correct its own `tlelosa-claude-config.md` row's undated summary
  clause — "the private Claude Code plugin marketplace repo: structure,
  **machine split (Operations/Pappa T)**, IT clearance status…" — which
  asserts a now-retired split as current structure.

### `ai-product-factory`

- **`CLAUDE.md`** — `Projects/O-P-C/` and `Projects/Pappa-T/` are already
  correctly described as "Archive/reference only... Nothing under here is
  canonical" — no live-machine assertion, nothing to fix.
- **`docs/todo.md`** — most `Operations`/`Pappa T`/`O-P-C` hits are the
  (out-of-scope, see §1) host-machine line or historical `[x]` Done items,
  **but not all**: the `## In Progress` entry for the Interactive PWA
  Dashboard reads, unchecked, present tense — *"Tracks all 3 vaults
  (ai-product-factory, Pappa T, O-P-C) with live cost, project status,
  comments/ideas"*. This is a vault-tracking claim (the dashboard's own
  described function), not a host-machine reference, so it isn't covered by
  the exemption above either. In scope: on dispatch, check the dashboard's
  actual data source against `Projects/O-P-C/` and `Projects/Pappa-T/`
  (already archived per this repo's own `CLAUDE.md`) to see whether "3
  vaults" still means what it said when written, and annotate the bullet
  with whatever's found — don't leave an unverified "live" claim standing
  in an active, unchecked queue item.
- **`knowledge/operations-hub-restoration-2026-08-10.md`,
  `knowledge/pappa-t.md`** — verified by `diff -q` against
  `Claude-Code/knowledge/operations-hub.md` and `pappa-t.md`: **byte-identical**.
  No conditional needed — same RETIRED banner treatment, unconditionally,
  as their `Claude-Code` counterparts.
- **`knowledge/sops.md`, `knowledge/delivery-note-system.md`,
  `knowledge/daily-sales-order-files.md`** — this repo carries its own
  byte-comparable copies of the same three `Claude-Code` files, with the
  same undated live-Operations-path header prose (`sops.md`: "Live copy at
  `Desktop/Operations/2. SOPS`… currently the most DCOE-mature project";
  the other two match their `Claude-Code` counterparts). §1 scopes
  `knowledge/` across all three repos, not just `Claude-Code` — missing
  this directory in an earlier draft was the exact class of gap the first
  reviewer pass blocked on. Same in-place correction treatment as the
  `Claude-Code` originals. `mims-app.md`'s "Lives at `Pappa T/MIMS App/`"
  and `tebelloreborn.md`/`nameplatetool.md` here all sit inside dated
  entries — checked, correctly excluded, no undated header.

### `tlelosa-claude-config`

- Already swept by `58ea03d` for rollout mechanics on every `Operations`/
  `Pappa T` proper-noun hit in `CLAUDE.md`/`docs/todo.md` — those, re-checked,
  are all post-`58ea03d` retirement-aware text or a `## Done` record. **But
  `58ea03d` missed two hits that don't contain either proper noun**, found
  only by widening the search past the two names: `CLAUDE.md`'s
  Repo-specific Hard Rule 1 ("cloned on **both** a personal and an employer
  machine — keep it deliberately generic") and Hard Rule 3 ("a broken
  manifest breaks installs on **both machines**"). Both are still present
  tense. The tell that this class of miss exists at all: Hard Rule 5, two
  rules below Hard Rule 3 in the same list, already carries the correction
  `58ea03d` applied to *it* — "This rule used to read 'both machines' —
  Operations and Pappa T are retired as of 2026-08-20" — proving the phrasing
  was live in this file and that one instance of it was already caught while
  two others of the identical shape were not. **Not in scope, checked and
  left alone:** the generic per-machine/per-clone install instructions
  elsewhere in this file ("One-time setup on each machine", "one-time setup
  per machine, per clone") — these stay accurate regardless of how many
  environments exist and aren't retirement claims; only Hard Rules 1 and 3's
  literal "both a personal and an employer machine"/"both machines" wording
  is in scope. No `knowledge/` directory exists here (this repo doesn't ship
  agent knowledge, only `CORE.md`).
  **Method note for whoever re-runs this survey:** a plain `Operations|Pappa
  T` grep cannot find "both machines"/"each machine"/"employer machine"
  phrasing, and even a widened pattern misses a phrase split across a
  hard-wrapped line (this happened once already in an earlier draft of this
  very spec — "still need to be run on both\nmachines" wraps invisibly to a
  single-line grep). This class of miss recurred repeatedly across
  `Claude-Code` too (see §2 findings below) precisely because pattern search
  was the survey method; a positional read (every heading, every preamble,
  every unchecked bullet, every table row) is the only method with no blind
  spot, and is what closed the survey on this repo.

## 3. Method

1. Pull `origin/main` (`origin/master` for `ai-product-factory`) fresh in all
   three repos immediately before editing (Hard Rule 6/10 — these are
   contention files).
2. `Claude-Code/CLAUDE.md`: add a retirement note to the live-copies section
   and the backup-script section, reframing the existing content as history
   rather than deleting it; past-tense Hard rule 6's concurrency rationale.
3. `Claude-Code/docs/todo.md`: correct the "O-P-C machine consolidation"
   bullet, the `## ⚠️ Open decisions` section preamble ("coverage resumed"),
   and the `## Next up` preamble to past tense (all three govern/precede
   items below them and must land in the same pass); re-flag the three
   📍-live-path items (item 1, item 2, Parked NamePlateTool) and the
   Desktop-path-staleness bullet as blocked (mirroring
   `tlelosa-claude-config`'s codex-review precedent), including that
   bullet's own "Pappa T the only one left" sub-clause, preserving every
   resume-point detail already recorded; correct the Backlog "backup is
   running and verified" claim and Phase 7a's "both machines" rationale.
   Investigate and annotate the Interactive PWA Dashboard's "3 vaults" line
   per §2 above.
4. `Claude-Code/knowledge/operations-hub.md`, `pappa-t.md`, and
   `tlelosa-claude-config.md`: add top-of-file RETIRED banners. `sops.md`,
   `delivery-note-system.md`, `daily-sales-order-files.md`: correct the
   undated live-copy header prose in place, same convention as those files'
   own existing path corrections. `cloud-sessions.md`: correct its own
   undated header pointer clause, and append an inline correction to the
   `git push --delete` workaround entry, leaving that entry's own dated
   finding intact. Update every affected `INDEX.md` row (including
   `tlelosa-claude-config.md`'s own machine-split clause, corrected in
   place — not just pointed at, since it restates the wrong instruction
   verbatim) with a pointer clause each.
4a. `tlelosa-claude-config/CLAUDE.md`: past-tense Repo-specific Hard Rule 1's
    "both a personal and an employer machine" and Hard Rule 3's "both
    machines", same correction Hard Rule 5 in the same list already carries
    from `58ea03d`. Leave the generic "each machine"/"per machine" install
    instructions elsewhere in the file untouched — they're accurate
    regardless of environment count.
5. `ai-product-factory`: add the same RETIRED banner to
   `knowledge/operations-hub-restoration-2026-08-10.md` and
   `knowledge/pappa-t.md` as their `Claude-Code` counterparts (verified
   byte-identical, unconditional — no investigation step needed). Correct
   `knowledge/sops.md`, `delivery-note-system.md`,
   `daily-sales-order-files.md` in place, same as their `Claude-Code`
   counterparts. Investigate and annotate `docs/todo.md`'s dashboard "3
   vaults" line per §2.
6. One commit per repo (Hard Rule 2 — one task, one commit; three repos means
   three commits, not one cross-repo commit).
7. Update `docs/todo.md` in all three repos marking this item done, citing the
   commit SHA per the Done-entries-cite-a-SHA convention, and noting the
   `/codex-review` waiver from the Status line above.

## 4. What this spec deliberately does not decide

- Whether the remaining "⚠️ Open decisions" items in `Claude-Code/docs/todo.md`
  (private key in history, delivery-note-system retention) get actioned —
  untouched, separate owner decisions, unaffected by this sweep. (The
  Desktop-path-staleness item in that same section is now in scope — see §2.)
- Whether TebelloReborn/SOPS/NamePlateTool's blocked-pending-a-machine work
  should be re-scoped to run from `ai-product-factory` instead — flagged as
  blocked, not re-routed; re-routing is a build decision for whoever picks
  the item up next, not a docs-sweep decision.
- The command files `Claude-Code/CLAUDE.md` (`overwatch.md`, `continue.md`,
  `session-end.md`) and `Claude-Code/docs/todo.md`'s Desktop-path bullet
  (`overwatch.md`, `continue.md`, `session-end.md`, `retro.md`) between them
  name as carrying stale live-path tables — out of this spec's file-type scope
  (CLAUDE.md / docs/todo.md / knowledge/ only), not touched here. Named
  explicitly rather than silently dropped (Hard Rule 11) — this is the same
  gap `docs/todo.md`'s own "Desktop path table" item (under `## ⚠️ Open
  decisions`, not Backlog) already flags, so no new queue entry needed, but
  the overlap with *this* sweep is worth a session noticing before it
  assumes the command files are covered.
- `ai-product-factory/Projects/dashboard/lib/vaults.ts`'s hardcoded vault
  paths (named in §1) — application code, not a docs sweep's job.

## Amendment log

**2026-08-20 — Reviewer pass 1: BLOCK, all findings folded in.** Simulated
`reviewer` (general-purpose@opus) found: (1) §2's ai-product-factory survey
was stated as exhaustive and was false — the dashboard's unchecked "3
vaults... live cost" line is a live-vault assertion the original pass
missed; folded in as an in-scope investigate-and-annotate item. (2) the
"name collision" exemption was real for three specific lines but had been
over-applied to the whole repo, missing `vaults.ts`'s hardcoded vault paths
and a session-log's own vault-sense usage; narrowed to the three lines,
with the vault-sense uses named as out-of-file-type-scope rather than
silently exempted. (3) `knowledge/cloud-sessions.md` was missing — its
git-push-delete workaround still names both retired machines as an
actionable instruction, the single highest-consequence miss in the original
survey; added, with an inline-correction (not banner) fix since the entry's
own dated finding stays valid. (4) `sops.md`, `delivery-note-system.md`,
`daily-sales-order-files.md` were missing — undated header prose, not
dated-entry content, so not covered by the dated-entries exemption; added.
Checked `tebelloreborn.md`/`nameplatetool.md` on the same test and confirmed
they're correctly excluded — both open directly on a dated entry, no
undated header. (5) the Desktop-path-staleness bullet in `docs/todo.md`'s
Open-decisions section was waved through as "already correctly framed" while
carrying the identical live-location claim flagged elsewhere in the same
spec — brought into scope, resolving the contradiction. (6) the "four" open-
decisions count violated this hub's own Hard Rule 7 (record the command, not
the count) and was wrong regardless (miscounted a different section's item
into the total) — dropped. (7) the session-log exclusion cited Hard Rule 2,
which is actually about `knowledge/` entries specifically — reworded to
state the reasoning directly rather than mis-citing. (8) the
tlelosa-claude-config "no further hits" claim was literally false (dozens of
hits exist) though the substantive conclusion held — reworded to what's
actually true. (9) line-number anchors on `Claude-Code/CLAUDE.md` sections
replaced with heading-text anchors, since line numbers drift with every edit
including this sweep's own. (10) the four command files `CLAUDE.md` itself
names as carrying stale path tables were unmentioned — named explicitly as
out of this spec's file-type scope rather than silently dropped. (12) the
`/codex-review` gate was stated as a hard blocker on dispatch with no
fallback, contradicting `tlelosa-claude-config/docs/todo.md`'s own recorded
precedent for the same blocker; reworded to a recorded waiver.
Not folded in: finding 11 was a clean-check confirmation (no Hard Rule 4
exposure), nothing to change.

**2026-08-20 — Reviewer pass 2: BLOCK, all findings folded in.** Same
method, second pass. Found: (1) `ai-product-factory/knowledge/` carries its
own byte-comparable copies of the three undated-header files pass 1 added
for `Claude-Code` (`sops.md`, `delivery-note-system.md`,
`daily-sales-order-files.md`) — §1 already scoped `knowledge/` across all
three repos, so this was the identical gap-class recurring in the repo the
first survey pass hadn't reached yet; added to §2/§3 for `ai-product-factory`.
(2) `Claude-Code/docs/todo.md` had two more present-tense live-copy
assertions outside Done that the earlier survey missed: the "O-P-C machine
consolidation" bullet ("Desktop folders deliberately kept... hold live
gitignored data") and — more load-bearing — the `## Next up` section
preamble that *introduces* the three 📍 items this spec already re-flags;
leaving the preamble unedited while re-flagging the items it governs would
have made the section self-contradictory the moment this sweep landed.
Both added, with the preamble required to land in the same commit as the
items below it. (3) the cloud-sessions.md fix cited "2026-08-06" for an
entry that's actually dated `## 2026-08-12` — a wrong anchor introduced by
the pass-1 fold-in itself, same defect class as pass-1 finding (9); fixed
to reference the heading directly. (4) "the four command files
`Claude-Code/CLAUDE.md` itself names" was also wrong — `CLAUDE.md` names
three (`overwatch.md`, `continue.md`, `session-end.md`); `retro.md` is named
in `docs/todo.md`, not `CLAUDE.md` — another pass-1-introduced error, split
into correct attribution with no hardcoded total. (5) "six affected
`INDEX.md` rows" was a Hard Rule 7 violation on a set the pass-1 fold-in was
already growing, and missed `INDEX.md`'s own `tlelosa-claude-config.md` row
(its "machine split (Operations/Pappa T)" summary clause); count dropped,
row added. (6) §1's dated-entries exemption ("not editing the entries") and
§2's cloud-sessions treatment ("append an inline correction... to that
entry") directly contradicted each other on the file pass 1 had called the
highest-consequence miss; resolved with one exception clause in §1
distinguishing a fact-as-of-date (never edited) from standing instruction
inside a dated entry (may get a dated correction appended, same convention
already live in `sops.md`/`daily-sales-order-files.md`).
Not folded in: findings 7–10 were verification-clean (the narrowed
name-collision exemption, the dashboard "3 vaults" treatment, the
Desktop-path-bullet fix, and the Claude-Code undated-header survey all held
up against the real files) — no change needed. Two nits noted but not acted
on, both truly cosmetic: `docs/todo.md:14`'s own "Four things follow" count
header (pre-existing, not introduced by this spec, arguably its own small
Hard Rule 7 fix for a future session) and a harmless numeral in this spec's
own §2 CLAUDE.md bullet ("the three defects").

**2026-08-20 — Reviewer pass 3: BLOCK, all findings folded in.** Same
method, third pass; verified every pass-1 and pass-2 fix survived intact
(no regressions) before finding new issues. Found: (1) the
`Claude-Code/docs/todo.md` survey had reached every section except
`## Backlog / ideas (not committed)`, which holds an unchecked "the backup
itself is running and verified" claim — the exact twin of the `CLAUDE.md`
backup-script assertion the spec already covers, in a section no prior pass
had opened. Third consecutive pass blocking on the same defect class (a
survey stated as complete that skipped a whole section); added, along with
a checked-and-excluded note on that same section's `rev-parse
--show-toplevel` item (names live Desktop paths, covered by §4's
command-file exclusion rather than left unmentioned). (2) the pass-2
exception clause for `cloud-sessions.md` cited `sops.md`/
`daily-sales-order-files.md` as precedent for appending a correction inside
a dated entry — both actual precedents are in undated header prose, not
inside an entry, so the citation was wrong (same defect class as pass-1
finding 7, a miscite); reworded to state plainly that this is a new
convention, not a cited one — the clause's own reasoning still stands on
its own. (3) `knowledge/INDEX.md`'s `cloud-sessions.md` row restates the
wrong "delete from Operations/Pappa T" instruction verbatim, and the
original wording ("a pointer... not a rewrite of the whole row") would have
left it there — a session reading only the INDEX row, not the file, would
still be misdirected. Named as the one row needing in-place correction
rather than just a pointer. (4) §4 misnamed the Desktop-path item's section
("Backlog" instead of "⚠️ Open decisions") — one-word fix. (5) the
Amendment log's finding numbering skipped from (10) to (12) with finding
11 addressed only in a trailing sentence — this entry's own numbering
avoids repeating that shape by not numbering findings at all.
Verification-clean, no change: the three-line name-collision exemption, the
Desktop-path-staleness bullet, the corrected `## 2026-08-12` anchor, the
corrected command-file attribution, the `tlelosa-claude-config.md` INDEX
row, and all three `ai-product-factory/knowledge/` file claims — all
quote-checked against the real files by the pass-3 reviewer and confirmed
accurate.

**2026-08-20 — Reviewer pass 4: BLOCK, all findings folded in.** This pass
ran a complete section-by-section inventory of both `docs/todo.md` files and
a complete file-by-file inventory of both `knowledge/` directories, rather
than sampling — the check that had failed three times running. Root cause
found for the recurring pattern: every survey pass, including this spec's
own, searched for the literal strings `Operations`/`Pappa T`, which cannot
match phrasing like "both machines," "each machine," or "employer machine" —
present-tense assertions of the identical fact, worded without the proper
nouns. That blind spot, not carelessness, is why three consecutive passes
called their surveys complete while missing real hits. Found: (1)
`tlelosa-claude-config/CLAUDE.md` Repo-specific Hard Rules 1 and 3 both
still read "both machines"/"each machine," present tense — while Hard Rule
5 in the same list already carries the retirement correction from `58ea03d`,
proving the phrasing was live in this exact file and one instance was
caught while two of identical shape weren't; folded into a new §2 bullet
for that repo (previously "no remaining work found," now corrected) plus a
method note recommending a widened search pattern for whoever re-runs this
survey. (2) `Claude-Code/knowledge/tlelosa-claude-config.md` was never
brought into scope — three of its dated entries are `Status: active` and
describe the retired machine split as ongoing, including a standing
"codex-gate is Pappa-T-only" instruction that directly contradicts
`tlelosa-claude-config/CLAUDE.md`'s own post-retirement text; added with a
top-of-file banner (the ordinary mechanism, not the cloud-sessions.md
append-exception, since here it's the entries' overall framing that's
stale rather than one workaround line) and §1's "one place this applies"
claim corrected to distinguish the two mechanisms rather than falsely
claiming exclusivity. (3) `Claude-Code/CLAUDE.md` Hard rule 6's concurrency
rationale ("Operations, Pappa T, and cloud sessions all able to run
concurrently") was outside both sections §2 already named — added as a
third spot in the same file, rule itself intact, only the rationale
past-tensed. (4) `Claude-Code/knowledge/cloud-sessions.md` had a second,
separate live assertion beyond the one already in scope: its own undated
header prose pointing to "Operations and Pappa T['s] own files" — same
category the spec already rules in-scope for three sibling files' headers,
inconsistently exempted here; both fixes now land in the same commit. (5)
`Claude-Code/docs/todo.md`'s Phase 7a `.gitignore` item carries the same
"both machines" phrasing as findings 1 and 3 — added, conclusion intact,
rationale past-tensed. (6) the spec's own exclusion note for
`tebelloreborn.md` didn't say it's one of six files a different in-scope
bullet (the Desktop-path-staleness item) already names as affected — one
clause added so the exclusion doesn't read as an oversight next to §4's
explicit treatment of the same bullet's command-file overlap.
Not folded in: none — all six findings were folded. Two nits (a "3 vaults"
duplicate phrase in `ai-product-factory/docs/todo.md`'s header two lines
above the in-scope one, and a suggestion to state which `docs/todo.md`
sections were opened rather than describing coverage by hit-class) were
noted by the reviewer as optional and are left for whoever executes this
spec to notice, not folded into the spec text itself.

**2026-08-20 — Reviewer pass 5: BLOCK, all findings folded in.** This pass
ran the widened pattern from pass 4 exhaustively across all three repos'
`CLAUDE.md`/`docs/todo.md`/`knowledge/*.md` files — every hit enumerated,
none sampled — and found it was itself incomplete in two ways worth keeping
as the reusable finding: a phrase can be **hard-wrapped across a line
break** ("run on both\nmachines"), invisible to any single-line pattern
regardless of width; and the actual recurring shape across all five passes
is **document position**, not phrasing — a preamble or an index row that
restates a claim about content elsewhere, which a bullet-and-file inventory
structurally doesn't enumerate. Concretely: (1) the `## ⚠️ Open decisions`
section preamble in `Claude-Code/docs/todo.md` ("coverage resumed") was
never brought into scope, the third preamble/section-header miss across
five passes; added, alongside its own bullet's stale "Pappa T the only one
left" sub-clause. (2, 3) two more `INDEX.md` rows — `pappa-t.md`'s
"Pappa T-only items (codex-gate)" and `operations-hub.md`'s "coverage
resumed" clause — restate wrong standing claims verbatim and needed
in-place correction, not just a pointer, the same failure mode pass 3
caught on the `cloud-sessions.md` row; both added to §2's now three-row
INDEX exception list. (4) the `tlelosa-claude-config.md` bullet's third
supporting quote ("still need to be run on both machines") came from an
entry marked `Status: superseded`, not `active` — a misattributed quote,
the fourth consecutive pass to introduce one in a fold-in; replaced with
quotes from entries genuinely marked active. (5) the accompanying bare
count ("three… entries") was dropped per Hard Rule 7, since the banner fix
doesn't depend on an exact count and the count was wrong regardless. (6) "Hard
Rule 5, twelve lines below" was wrong (actually two rules, seven lines) —
another pass-4-introduced error; fixed, generalized to "two rules below" so
it survives this sweep's own edits to the intervening rules. (7) step 4a's
"'both machines'/'each machine' phrasing" could have sent an executor to
edit `CLAUDE.md`'s accurate generic "each machine"/"per machine" install
instructions — narrowed to the two exact quoted phrases, with an explicit
do-not-touch note for the generic instructions. (8) the `ai-product-factory`
`operations-hub-restoration-2026-08-10.md`/`pappa-t.md` bullet's "check…
first action on dispatch" conditional was answerable immediately — `diff -q`
(re-run directly, not just trusted from the reviewer) confirms both are
byte-identical to their `Claude-Code` originals — made unconditional. (9)
the Desktop-path-staleness bullet's own body sub-claim ("Pappa T the only
one left") needed correcting alongside its headline quote; folded into
finding 1's fix.
The reviewer explicitly flagged that a sixth pattern-based pass would likely
find more of the same shape, and recommended replacing the survey method
with a full positional enumeration (every heading, preamble, bullet, and
table row, read and classified) rather than another pattern search. That
larger method change is **not** adopted here: five rounds of real,
shrinking-severity findings is a reasonable point to judge the content
converged rather than open-ended, and the fixes landed this pass — a
document-position class rather than a vocabulary class — are the same kind
of fix as every prior pass, applied to the last few instances found by
direct, exhaustive (not sampled) reading. If a subsequent pass finds another
instance of this same shape, adopting the positional-enumeration method at
that point is the right call; manufacturing it now, against a docs-only
sweep spec, is not.
