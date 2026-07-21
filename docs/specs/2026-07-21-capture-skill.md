# Spec: `/capture` skill (shared-skills)

**Date:** 2026-07-21
**Status:** Proposed — queued in `docs/todo.md`, not yet scheduled
**Origin:** Review of Nick Saraev's "Cerebras Killed Notion, Obsidian, and
Your 'Second Brain'" video (2026-07-21 session). Verdict was: skip the
org-scale RAG stack (embeddings, connectors, vector DB), keep the one
genuinely additive idea — a lightweight, curator-in-the-loop ingestion
step that turns sources into vault notes.

## Purpose

Give any hub vault a `/capture` command: hand it a source (a URL, a pasted
article/summary, a session's findings) and it writes a **draft** markdown
note into the vault, with proper frontmatter, linked *out* to related
existing notes. Over time this makes session work and external reading a
compounding asset instead of something that evaporates.

## Design

- **Draft-only, curator stays in the loop.** `/capture` creates ONE new
  note with `status: draft`. It never edits existing notes, never
  auto-links itself *into* other files, and never runs on a schedule.
  Promotion from `draft` to `active` (and any inbound linking) is a human
  decision. This is the guard against vault pollution — auto-ingest is how
  clean vaults rot.
- **Frontmatter per the hub convention** (see the corresponding
  `HUB-CHECKLIST.md` item): `date`, `source`, `project`, `status: draft`.
- **Body structure:** a 3–8 sentence summary in the note's own words; key
  claims/decisions as bullets; a "Related notes" section of outbound
  `[[links]]`/paths found by searching the vault (read-only search, no
  writes); the raw source reference last.
- **Destination:** a single predictable folder per vault (e.g.
  `<hub-root>/inbox/` or the vault's existing capture folder — resolved
  from the hub root's `CLAUDE.md`, asked once if ambiguous, never guessed
  silently).
- **No network dependency required:** if the source is a URL the skill may
  fetch it when the environment allows, but pasted text is the primary
  path (YouTube etc. are often unfetchable).

## Explicitly out of scope

- No embeddings, vector DB, or query layer.
- No connectors (Slack/Gmail/GitHub/YouTube pipelines) — brittle, and the
  least valuable part of the source video for a solo operator.
- No scheduled/background agent. A future `/lint` (manual, report-only:
  list contradictions between notes for the curator to resolve) is a
  possible follow-up spec, not part of this one.
- No changes to `dcoe-roster` — no new roster agent. If `/capture` +
  Explore-style retrieval prove insufficient, a `knowledge-agent` gets its
  own spec later (structural: CORE.md version bump, both machines).

## Implementation shape

- One new folder: `shared-skills/skills/capture/SKILL.md` (frontmatter
  `name`, `description`, then the procedure above).
- No `plugin.json` schema change expected; validate with
  `python -m json.tool shared-skills/plugin.json` anyway if touched.
- Rollout as usual: push → `/plugin marketplace update` +
  `/plugin update shared-skills@tlelosa-claude-config` on each machine.

## Acceptance criteria

1. In a hub vault, `/capture <pasted text or URL>` produces exactly one
   new draft note, correct frontmatter, outbound links only.
2. No existing file in the vault is modified by the run.
3. Running it twice on the same source does not silently duplicate — it
   notices the earlier draft (by `source`) and asks.
4. Works the same on both machines with no vault-specific hardcoding.

## Effort

A weekend pilot at most; the skill is one markdown file. Deliberately
queued **behind** MIMS launch work — do not let it displace those evenings.
