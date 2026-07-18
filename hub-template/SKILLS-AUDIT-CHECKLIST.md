# Skills Audit Checklist

**Source:** `tlelosa-claude-config` (`hub-template`) | **Companion to:**
`hub-template/continue.md` and `hub-template/HUB-CHECKLIST.md` | **Not a
template to install** — this is a checklist a session runs from a hub root
(or any project root) to find Claude Code Skills worth sharing across
machines, never a file that overwrites anything on its own.

## Why this exists

The DCOE agent roster got promoted to a shared core once it proved out in
one project (`dcoe-roster/CORE.md`, ADR-007). The hub-and-spoke `/continue`
resume flow got the same treatment (`hub-template/`, ADR-008). This
checklist applies the same "promote what's proven, don't duplicate it"
principle a third time — this time for Skills (`.claude/skills/*/SKILL.md`)
built inside individual projects, which may be generic enough to be useful
on a different machine's projects too (e.g. something built inside an
Operations project turning out to be useful for a Pappa T project, or vice
versa).

## How to use this

Run this from a **local** session — it needs real filesystem access to
project folders, which a remote/cloud session bound to `tlelosa-claude-config`
does not have.

### Step 1 — Enumerate projects

Read the hub root's own project index (e.g. Operations' `CLAUDE.md` §
Project Index table, or the equivalent list for whatever vault root this
is run from) to get the list of project folders that have their own git
repo.

### Step 2 — Per project, check for skills

For each project folder, look for `.claude/skills/*/SKILL.md`. For each one
found, note:

- **Name** and **one-line purpose** (read the skill's own description).
- **Portability judgment** — is it tied to business/domain specifics (e.g.
  a SOPS works-order print format, a Fan Movement-specific report layout)
  or genuinely generic (e.g. a CSV-cleaning technique, a PDF-diffing
  approach, a retry/backoff pattern)? Same discipline as
  `HUB-CHECKLIST.md`: classify what's there, don't rewrite it.

### Step 3 — Shortlist candidates

Only skills judged genuinely generic are candidates for sharing. Anything
tied to a specific business process or dataset stays exactly where it is —
this is not a "copy everything" exercise, only what's actually portable.

### Step 4 — Report back

Produce a short table:

| Skill name | Source project | One-line purpose | Why it's portable |
|------------|----------------|-------------------|--------------------|

Hand this table to a `tlelosa-claude-config` session (this checklist's own
repo). That session scaffolds a new `shared-skills/` plugin (kept separate
from `dcoe-roster`'s agent roster) and migrates the shortlisted skills in —
`shared-skills/` does not exist yet and should only be created once there's
at least one real skill to put in it, so `.claude-plugin/marketplace.json`
never carries an empty, non-validating plugin entry.

Report the outcome back so the originating decision can be closed out —
same closing discipline as `HUB-CHECKLIST.md`.
