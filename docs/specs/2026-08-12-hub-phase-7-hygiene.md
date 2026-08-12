# Spec — Phase 7: Hub Hygiene & Governance (DCOE Maintenance Plan)

**Date:** 2026-08-12 | **Status:** Open — requires owner decision on company-data policy
**Basis:** Seven-phase maintenance plan at `docs/specs/2026-08-08-system-maintenance-plan.md`.
Phases 1–6 completed through 2026-08-12 (branch triage, model routing, PR templates, roster
cloud-sessions, etc.). Phase 7 remains.

## Overview

Two structural gaps in the `Claude-Code` hub's governance need resolution. Neither is a technical
defect; both are policy/governance choices awaiting owner confirmation.

## Issue 1: Root `.gitignore` for large files

**Problem:** The hub tracks generated files (logs, images) and installers (31 MB+) that should be
gitignored:

- `Projects/dashboard/` builds (node_modules, build output, dist/)
- Screenshots and exported images from design work
- Large tool installers (old Downloads clones, etc.)
- Session logs and transcripts

**Current state:** Not tracked today; if they end up in the working tree and `git add -A` is
run, they would land. No prevention.

**What's needed:** A `.gitignore` at the hub root with patterns for:
- `**/node_modules/`, `**/dist/`, `**/build/`
- `**/*.png`, `**/*.jpg`, `**/*.gif` (generated images only; keep source diagrams)
- `**/*.log`
- Installers: `**/Downloads/`, `**/*.exe`, `**/*.msi`, `**/*.dmg`
- Session transcripts if ever exported: `**/*.transcript`

**Acceptance:** Any session that runs `git add -A` at the hub root will not stage unintended
large files.

**No blocker:** This is straightforward once the patterns are chosen. The hard part is deciding
which file types to exclude — that should be owner's call per the hub's actual use.

## Issue 2: Company data contradiction & Fan Movement closure

**Problem:** The hub's hard rule #4 states "No company or project data beyond what's already
public." However, the `Operations/` snapshot folder contains real company data from Fan Movement
(a now-terminated contract, ended 2026-08-03):

- Staged company IP (917 files) in `Desktop/Fan Movement - Company IP/`
- Production databases (SOPS, Delivery Note System) in the staged snapshot
- Some gitignored runtime state files

**Historical context:**
- This was intentional: the Fan Movement contract's IP was staged to a folder when the contract
  ended (2026-08-03).
- The folder is deliberately a copy, not a git-tracked-and-committed piece — so it doesn't end up
  in public GitHub pushes.
- Hard rule #4 was written *before* this happened, and hasn't been reconciled with the new state.

**What needs resolution:**
1. **Update hard rule #4** to clarify: "No company or project data in this repo's git history" (
   the important part — what gets pushed to GitHub). The staged copy is a filesystem artifact,
   not a git artifact.
2. **Or:** Move the staged copy out of this repo entirely (to an encrypted, non-git location).
   The current location is a side effect of having this repo as the hub.
3. **Or:** Document that the copy is temporary and scheduled for deletion (if that's the plan).

**Acceptance criteria:** The repo's governance is clear: an reader of `CLAUDE.md` should know
what's in this repo and why, and should understand what ends up in public GitHub history versus
what's local-only.

**Owner decision required:** This is not technical — it's a governance choice about whether
company data lives in a copy inside the hub, in a separate encrypted location, or gets deleted.
Recommend: move it out or delete it, then update hard rule #4 to clarify the rule applies to
git history, not the filesystem.

## Execution path

1. **Owner input:** Decide .gitignore patterns and company-data policy.
2. **Context Agent writes detailed spec** with exact patterns and timeline.
3. **Execute:** Create `.gitignore`, update hard rule #4 (or move/delete staged folder).
4. **Verify:** Clean run of `git clean -nd` shows no surprises, and rule #4 clearly documents
   the remaining scoping.

## Out of scope for this spec

- Detailed migration of company-data files (if deleted/moved) — that's a separate task once the
  policy is decided.
- Audit of what data is actually in `Operations/` — that was done during systems check (Phase 3);
  the summary is available in `knowledge/operations-hub.md`.

## Why Phase 7

The first six phases of the maintenance plan addressed technical/process gaps (branch triage,
model updates, template consistency, cloud-session issues). Phase 7 is governance-level: what
belongs in this repo, and what should be protected by policy from the start. It's lower urgency
than Phase 1–6 (no sessions are blocked; no installs are broken) but higher importance long-term
(governance gaps silently widen over time).

Marked as remaining work so it doesn't fall off the queue and become the "known issue" that
nobody revisits.
