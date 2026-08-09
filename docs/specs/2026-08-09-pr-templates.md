# Spec — PR templates for `tlelosa-claude-config` and `Claude-Code`

**Date:** 2026-08-09
**Status:** Draft — awaiting owner approval
**Owner:** Tebello Lelosa
**Type:** Structural — adds a new `.github/` surface to two repos and changes
the shape of every future PR in both.

## Problem

Neither repo has a PR template. Confirmed 2026-08-09: no
`pull_request_template.md`, no `.github/PULL_REQUEST_TEMPLATE/`, in either
`tlelosa-claude-config` or `Claude-Code`.

PR bodies are therefore written freehand, by whichever session opened the PR,
with no fixed place to record the two things a reviewer most needs to know
before merging:

1. **Which spec authorised this**, or that the change was Trivial under the
   Router and needed none.
2. **Whether the `reviewer` agent approved it** — the sole APPROVE/BLOCK
   authority under CORE hard rule 7 and DCOE rule 7's Reviewer Loop.

Both facts exist today only in a session's transcript, which is gone once the
container is reclaimed. The PR is the durable record; it currently doesn't
carry them.

This matters more here than in a typical repo because most PRs are opened by
cloud sessions that end immediately afterwards. There is frequently nobody
left to ask.

## Decision

Four calls, made by the owner 2026-08-09:

| Question | Decision |
|---|---|
| Which repos | **Both, tailored per repo** |
| Gates enforced | **Spec link + reviewer status only** |
| Strictness | **Checklist, self-attested** — never blocking |
| Structure | **Single default template** per repo |

### Both repos, tailored

The two repos fail differently. `tlelosa-claude-config` breaks installs on two
machines when a manifest or version is wrong; `Claude-Code` breaks the fact
cache and the task queue when a session forgets to reconcile them. A single
shared body would carry sections that are dead weight in one repo or the
other, and dead sections train people to skim the live ones.

**The checklist is identical in both** — the two gates apply everywhere. Only
the free-text prose sections differ.

### Spec link + reviewer status only

The checklist is deliberately two items. A two-box checklist gets read; a
ten-box checklist gets ticked without reading, which is worse than no
checklist at all because it manufactures false assurance.

### Self-attested, never blocking

Unchecked boxes do not prevent merge. No CI, no Action, no required check.
This is the same trust model as every other rule in this setup: `CLAUDE.md`,
`CORE.md`, and hard rule 3's JSON validation are all self-monitored. A PR
template that blocks would be the only enforced rule in the system, and
enforcing the *least* consequential rule first would be an odd place to start.

### Single default template

`.github/pull_request_template.md` auto-applies to **every** PR, including
ones opened by tooling or by a Claude session via the API. A
`PULL_REQUEST_TEMPLATE/` chooser directory only applies when a human visits a
`?template=` URL — which, in a workflow where most PRs are opened
programmatically from a cloud container, means it would apply almost never.
Trivial changes mark the irrelevant sections `N/A`.

## Deliberately excluded

Recorded so the reasoning survives and the call is easy to reverse.

Two further gates were proposed and **not** selected:

- **Rollout impact** (which version bumped — CORE / template / plugin; does
  this change what the machines install; does it need a `bootstrap` re-run).
- **`docs/todo.md` updated** (CORE hard rule 5).

Both were proposed because both correspond to failures that have actually
happened in this repo, not hypotheticals:

- The 2026-08-08 branch triage found **three version collisions** — two
  different v3.3 templates and two different 3.4.0 rosters — that a naive
  merge would have shipped to both machines.
- The CORE 1.5 roster-autodeploy change (`ab95eef`) merged to `main` with **no
  corresponding entry** in this repo's `docs/todo.md`, in breach of hard rule
  5. That gap is still open as of this spec.

The template as specified will not catch either class. That is an accepted
trade-off in favour of a checklist short enough to actually be read, and the
owner's call. If a third instance of either failure occurs, the cheapest fix
is adding one line to the checklist — this section is the argument, pre-made.

**Codex-review status** (hard rule 9) was also proposed and not selected.
Noted separately because it has a standing structural gap of its own:
codex-gate is a Pappa T-only install, so a cloud session cannot run it and
would tick "waived" every time. A gate that one whole class of author must
always waive is not a gate.

## Exact changes

### 1. `tlelosa-claude-config/.github/pull_request_template.md` (new)

```markdown
## What changed

<!-- One or two sentences. What a reader needs to know before the diff. -->

## Why

<!-- The problem this solves. Link the todo item or the session that found it. -->

## Scope

<!-- Router classification, per CORE.md rule 0. Delete the one that doesn't apply. -->

- **Trivial** — single-file edit, typo, version bump. No contract, schema,
  governance, or cross-project effect.
- **Structural** — touches contracts, data, security, governance/shared-core
  docs (`CORE.md`, an agent body), or what the machines install.

## DCOE gates

- [ ] **Spec:** `docs/specs/<name>.md` — or **N/A, Trivial** per the Router.
- [ ] **Reviewer:** the `reviewer` agent APPROVEd — or **not run**, with the
      reason below.

<!-- If either box is unchecked, say why here. Unchecked does not block merge;
     unexplained is what makes the record useless later. -->

## Verification

<!-- What you actually ran, and what it printed. For any commit touching a
     catalog or plugin manifest, hard rule 3 wants:
       python -m json.tool .claude-plugin/marketplace.json
       python -m json.tool dcoe-roster/plugin.json
       python -m json.tool shared-skills/plugin.json
       python -m json.tool codex-gate/plugin.json
     "Not applicable, markdown only" is a fine answer. -->
```

### 2. `Claude-Code/.github/pull_request_template.md` (new)

Identical `What changed`, `Why`, `Scope`, and `DCOE gates` sections. The
`Verification` section is replaced by:

```markdown
## Verification

<!-- What you checked. This is a hub, not an app — there is nothing to build,
     so verification here usually means: did the record stay true?
     - `knowledge/INDEX.md` still matches the files it indexes
     - superseded entries marked `Status: superseded`, not deleted (hard rule 2)
     - `docs/todo.md` and `docs/session-log.md` were pulled before editing
       (hard rule 6 — these three files have caused two real merge conflicts)
     "Not applicable" is a fine answer. -->
```

### 3. No changes to `hub-template/`

Not promoted to the vault-agnostic template in this pass. Two repos is not yet
evidence of a reusable pattern, and `hub-template/` already carries a
re-copying burden on every vault that adopted it (see the `HUB-CHECKLIST.md`
reconciliation item from Phase 6). Promote later if a third repo wants it.

## Commit boundaries

One task = one commit, per hard rule 2:

1. `tlelosa-claude-config/.github/pull_request_template.md`
2. `Claude-Code/.github/pull_request_template.md`
3. `docs/todo.md` in this repo — mark this task done

Commits 1 and 3 land on this repo's `claude/pr-template-linear-planning-40hnrd`;
commit 2 lands on the same-named branch in `Claude-Code`.

## No version bump

`.github/` ships in no plugin manifest. `CORE.md` and `CLAUDE.md.template` are
untouched. This does **not** join the pending 3.6.0 / CORE 1.4 / v3.5 rollout,
and neither machine needs to do anything to pick it up — GitHub reads the
template server-side.

## Acceptance criteria

- Opening a PR in either repo pre-fills the body with that repo's template,
  with no `?template=` parameter and no human action.
- The checklist is exactly two boxes in both repos.
- Neither template blocks a merge: no CI check, no Action, no required status.
- The two templates share their `What changed` / `Why` / `Scope` / `DCOE gates`
  sections verbatim, and differ only in `Verification`.
- A Trivial change can complete the template honestly without inventing a spec
  — the `N/A` path is explicit, not implied.

## Out of scope

- CI enforcement of any box.
- Promotion to `hub-template/`.
- An issue template, a `CODEOWNERS`, or any other `.github/` surface.
- Retrofitting the template onto open PRs.
- The Linear feasibility evaluation — a separate task from the same session
  invocation, and a separate document.

## Codex second opinion

**Not run** — codex-gate is a Pappa T-only install and this spec was written
from a cloud container. Same standing gap as the 2026-08-08 model-routing and
unmerged-branch specs; tracked in `docs/todo.md` alongside those two rather
than left to lapse quietly.

## Revision history

- **2026-08-09** — first draft. Scope set by owner questionnaire the same day
  (both repos tailored / two gates / self-attested / single default template).
