# Spec — Amend CORE.md Hard Rule 10: verify the fetch itself succeeded

**Date:** 2026-08-20 | **Status:** Approved with nits (reviewer pass, 2026-08-20) — ready for
implementation. Reviewer findings (wrong hard-rule citation, an outdated "already fixed" claim,
and an incomplete Touches list) corrected in this revision; no re-review required.
**Basis:** `Claude-Code`'s second `/retro` run (2026-08-20), item 2 of 3 selected. Evidence:
session-log entry "2026-08-12 — Architecture export, and a checkout that was 13 commits behind
while looking current" (`Claude-Code/docs/session-log.md`), full incident detail in
`Claude-Code/knowledge/cloud-sessions.md`.

## Problem

A cloud session's checkout of both `Claude-Code` and `tlelosa-claude-config` sat **13 commits
behind** `origin/main` while every check the session ran said otherwise: a clean working tree, a
cached `origin/main` ref identical to `HEAD`, and an empty `git log origin/main..HEAD`. All three
read as "up to date." None of them were — the session had followed Hard Rule 10 (fetch, then
check) and still landed on a confidently wrong answer.

Root cause, in two parts:

1. **The fetch itself failed, silently.** The session ran `git fetch origin main <a stray
   branch-name ref>` as one command. The stray ref didn't exist on the remote, and `git fetch`
   aborts **atomically** on a bad ref in the same invocation — `main` was never updated, and the
   command's own failure (`fatal: couldn't find remote ref ...`) was easy to read as "that one
   ref failed" rather than "nothing in this command updated the local cache." Every comparison
   run immediately afterward (`git log origin/main..HEAD`, diffing `origin/main` against `HEAD`)
   answered from the stale pre-fetch cache, confidently.

2. **A phantom tracking ref manufactured false confidence in the other direction.** Both repos
   showed `remotes/origin/claude/system-architecture-download-injjbi` in `git branch -a` — a
   plausible-looking sign that a branch had been pushed. `git ls-remote --heads origin` showed it
   on **neither** remote. The local tracking ref proved nothing about what actually exists on
   GitHub; only asking the remote directly did.

Hard Rule 10 as currently worded ("fetch the relevant ref and check it") is satisfied by both
of the actions that produced the wrong answer here — a fetch was run, and a check was made. The
rule doesn't yet say what to do when the fetch's own result is itself untrustworthy, which is
exactly the gap this incident fell through. This is the same *shape* of failure already named
twice elsewhere in this hub's own hard rules — Hard Rule 8 (`Claude-Code/CLAUDE.md`) calls out
`rmtree` calls that report success while failing, and the PowerShell `..` range-operator trap:
**a command that produces a plausible wrong answer instead of a visible error.** Hard Rule 10 is
the git-specific instance of the same class, and it isn't yet armored against it.

One further detail worth keeping in the fix: this same stale checkout also **manufactured a false
finding**, not just missed real ones — at the time (2026-08-12), it reported a
`roster-manifest.json`/`CORE.md` version drift (manifest `1.4` against `CORE.md` `1.5`) that was
real in the stale copy and had already been fixed on `main` (both `1.6`) by the time it was
checked. A stale-fetch bug doesn't only hide work; it invents defects that don't exist, and a
fabricated finding is easier to act on by mistake because it still looks like diligence.

**Re-verified while writing this spec (2026-08-20, fresh `git fetch`): a version drift of the
same shape exists again, right now, and is not stale-checkout artifact — it's real and open.**
`fe88c2b` (CORE 1.6 → 1.7, the Hard-Rule-11 spec) bumped `CORE.md`'s header but not
`agent-bodies-reference/roster-manifest.json`'s `coreVersion` field, which still reads `1.6` on
current `origin/main`; `dcoe-roster/plugin.json`'s `description` text also still says
`CORE.md, v1.6`. This is not evidence for the "manufactured a false finding" case above — it's
the opposite case, a genuine drift that's gone unnoticed for over a week — but it's worth citing
here since it's the same *class* of stale-record problem this spec exists to close, caught by the
review pass on this very spec. Filed separately below in Impact rather than folded into this
rule change, since it's a one-time cleanup, not a process fix.

## What

Amend CORE.md Hard Rule 10 to add two concrete checks, both narrow and mechanical — this is not a
new rule, it closes the gap in the existing one:

**Current text:**

> 10. **Verify remote state before asserting it.** Before reporting repo/PR/branch status or
>    proposing an action conditioned on it (open a PR, merge, rebase), `git fetch` the relevant
>    ref and check it — never answer from a locally cached branch ref that may be stale. This
>    applies to any external state a session doesn't control alone (remote branches, deployed
>    versions, other sessions' in-progress work), not git specifically.

**Proposed text (additions only, existing sentences unchanged):**

> 10. **Verify remote state before asserting it.** Before reporting repo/PR/branch status or
>    proposing an action conditioned on it (open a PR, merge, rebase), `git fetch` the relevant
>    ref and check it — never answer from a locally cached branch ref that may be stale. This
>    applies to any external state a session doesn't control alone (remote branches, deployed
>    versions, other sessions' in-progress work), not git specifically. **A fetch that runs is not
>    evidence it succeeded** — check its own exit status before trusting any comparison derived
>    from it; a single `git fetch` invocation naming multiple refs can abort atomically on one bad
>    ref, leaving every ref's local cache exactly as stale as before the command ran, with no
>    separate error on the refs that would otherwise have updated. And when the fact being
>    verified is a tracking ref's own existence on the remote (e.g. "did this branch actually get
>    pushed"), a local `git branch -a` entry is not evidence of that — cross-verify with
>    `git ls-remote --heads origin`, since that is the only one of the two commands that actually
>    asks the remote rather than reading a local cache.

## Mechanics

The two additions map directly onto the two root causes:

1. **Check the fetch's own result.** In practice: run `git fetch` as its own step, confirm it
   returned success (no `fatal:`/non-zero exit) before treating the local `origin/*` refs it was
   supposed to update as current. If a fetch names multiple refs and any one is invalid, re-run
   with only the refs known to be valid rather than assuming the valid ones still updated.
2. **Use `git ls-remote --heads origin` as ground truth for "does this ref exist on the remote,"**
   not `git branch -a` — the latter lists local tracking refs, which can exist, be stale, or be
   entirely fabricated by container/environment setup without ever reflecting a real push.

Both are single commands, not new tooling — this is a discipline addition to an existing rule,
not new infrastructure.

## Enforcement

Same posture as the rest of CORE.md's hard rules — self-monitored, not gated by automation:

1. **At the point of use:** any session about to assert "X is pushed," "the branch is up to
   date," or "nothing changed on `origin/main`" runs the fetch, checks its exit status, and — if
   a tracking ref's existence is part of the claim — cross-verifies with `git ls-remote`.
2. **At review time:** a `reviewer` agent checking a session's claims about remote/branch state
   can ask "was the fetch's exit status checked, and was `ls-remote` used where a tracking ref's
   existence mattered" the same way it already checks other hard-rule compliance.
3. **`/retro`'s Step 2** already scans for "asserted a fact about external state that turned out
   to be stale or wrong" — this amendment doesn't change that scan, it gives the rule sharper
   teeth for the next time the scan finds an instance.

## Impact

**CORE version bump:** amending a hard rule bumps CORE.md's version. Current: **1.7**. This
change → **1.8**.

**No code changes needed.** Like Hard Rule 11 ("a record is not a control"), this is a process/
discipline amendment, not a hook or automation. It changes what a session is expected to check,
not what runs automatically.

**Touches:** `dcoe-roster/CORE.md` (the rule text, 1.7 → 1.8) plus two records that restate CORE's
version and go stale on every bump if not updated in the same commit —
`agent-bodies-reference/roster-manifest.json`'s `coreVersion` field and
`dcoe-roster/plugin.json`'s `description` text (which also names the CORE version). Both are
currently stale at `1.6` against `CORE.md`'s `1.7` (open since `fe88c2b`, found during this
spec's review pass — see the note above) and should be corrected to `1.8` in the same commit that
lands this amendment, closing both the old drift and pre-empting a new one. `dcoe-roster/plugin.json`'s
own `version` field (currently `3.8.1`, the value `/plugin update` on each machine keys off) should
also bump so the fix actually reaches Operations/Pappa T on their next update, not just this repo.
No `hub-template/` or command-file changes — Hard Rule 10 already applies universally via the
CORE.md read instruction every opted-in project's `CLAUDE.md` carries. One local restatement is
worth a follow-up, not part of this commit: `ai-product-factory/CLAUDE.md`'s own abbreviated Hard
Rule 10 ("git fetch + check; never trust stale local refs") will under-specify the strengthened
rule once this lands — file as a separate one-line queue item in that repo rather than bundling an
edit to a different repo into this spec.

## Mechanics addendum

Step 1's remediation (re-run with only the refs known to be valid) is the fallback, not the
default habit: prefer fetching one ref per `git fetch` invocation, or a plain `git fetch origin`
with no explicit refspec, since the atomic-abort-on-one-bad-ref failure this incident hit only
exists for a single invocation naming multiple refs at once.

## Related

- Hard Rule 8 (`Claude-Code/CLAUDE.md`) — the same "plausible wrong answer instead of a visible
  error" shape, for Windows shell/`rmtree` traps rather than git.
- Hard Rule 11 ("a record is not a control," CORE 1.6 → 1.7) — this spec is itself compliance
  with that rule: the incident was recorded in `knowledge/cloud-sessions.md` on 2026-08-12, and
  this spec is the executable follow-through the rule requires, filed after `/retro` surfaced
  that no such follow-through existed yet.
- `Claude-Code/knowledge/cloud-sessions.md` (2026-08-12 entry) — full incident detail, including
  the (correctly) withdrawn `roster-manifest.json` `1.4`-vs-`1.5` version-drift finding, distinct
  from the currently-open `1.6`-vs-`1.7` drift this spec's review pass found.
