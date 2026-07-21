---
name: capture
description: Turn a source (pasted text, an article, a video summary, a URL, or this session's findings) into ONE draft markdown note in the current vault/hub, with YAML frontmatter and outbound links to related existing notes. Trigger on /capture, or when the user says to capture/save/file something "to the vault", "to my notes", or "to the hub". Draft-only by design — it never edits existing notes, never links itself into other files, and never runs on a schedule; promotion from draft is the user's decision. Skip when the user wants a project file, code, or a document deliverable (report/spec/README) — this is only for knowledge-base notes.
---

## Why this exists

Session findings and external reading evaporate unless they land in the
vault, but automated ingestion pipelines are how clean vaults rot: notes
that write themselves into other notes, scheduled agents that "reconcile"
things, connectors that dump unreviewed content. This skill takes the
useful half only — a fast, consistent way to turn a source into one
well-formed **draft** note — and leaves every promotion and inbound-linking
decision to the human curator.

## Hard limits (non-negotiable)

- **Exactly one new file per run.** Never modify any existing file — no
  "helpful" backlink edits, no index updates, no todo entries.
- **`status: draft` always.** Never write `active`. The user promotes.
- **Outbound links only.** The new note may link to existing notes; nothing
  links back to it until the user does that themselves.
- **Never scheduled, never in the background.** Run only when explicitly
  invoked in the current turn.

## Steps

1. **Get the source content.** Pasted text is the primary path. If given
   only a URL, attempt one fetch; if fetching fails (common for YouTube and
   paywalled pages), say so and ask for pasted text or a summary — do not
   guess at content you couldn't read.

2. **Resolve the destination folder.** Look in the hub root's `CLAUDE.md`
   (or `AGENTS.md`) for a stated capture/inbox folder. If none is stated,
   look for an existing conventional folder (`inbox/`, `capture/`,
   `notes/inbox/`). If still ambiguous, ask once — never invent a new
   folder silently, and never hardcode a vault-specific path.

3. **Check for a duplicate.** Search the vault (read-only: grep frontmatter
   `source:` fields) for a note with the same source. If one exists, stop
   and ask whether to skip, or capture anyway as a second note — never
   silently duplicate and never overwrite the earlier note.

4. **Search for related notes (read-only).** Grep the vault for the
   source's key topics/terms. Collect up to ~5 genuinely related notes for
   the "Related notes" section. Zero matches is fine — leave the section
   with "none found" rather than forcing weak links.

5. **Write the note.** Filename: `YYYY-MM-DD-short-slug.md` in the resolved
   folder. Structure:

   ```markdown
   ---
   date: <ISO date of capture>
   source: <URL, "session", or a short provenance string>
   project: <project/life-domain it belongs to, or "hub">
   status: draft
   ---

   # <Title in plain words>

   <3–8 sentence summary in this note's own words — not a transcript
   dump, not the source's marketing framing.>

   ## Key points

   - <claims, decisions, numbers worth keeping — one per bullet>

   ## Related notes

   - [<note title>](<relative path>) — <one line on the connection>

   ## Source

   <raw URL / where the text came from / which session>
   ```

   Match the vault's own linking style if it visibly uses `[[wikilinks]]`
   instead of markdown links.

6. **Report.** Tell the user the note's path and remind them it's a draft:
   they promote it (`status: active`) and add any inbound links when
   they've reviewed it.

## What this skill is not

No embeddings, no vector DB, no connectors (Slack/Gmail/YouTube pipelines),
no scheduled lint/reconcile agent. If retrieval over captured notes ever
needs more than ordinary file search, that's a separate decision — not
something this skill quietly grows into.
