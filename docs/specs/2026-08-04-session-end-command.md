# Spec — `/session-end` command (close out a session, prep it for archiving)

**Date:** 2026-08-04
**Status:** Implemented
**Owner:** Tebello Lelosa

## Problem

`/continue` orients a *new* session against whatever state the *last* one
left behind — but nothing on the other end of that handoff does the
leaving-behind deliberately. Right now a session just stops: `docs/todo.md`
may or may not be updated, `docs/session-log.md` (hub only) may or may not
get an entry, and the session's own title stays whatever generic default it
started with. `/continue`'s Step 0 (ADR-005/Step 0.5) then has to
reverse-engineer all of that from raw transcripts on the *next* run — read
`list_events`, guess a title, judge whether the task actually finished —
which is exactly the kind of re-derivation this hub's own knowledge-cache
discipline (`Claude-Code/CLAUDE.md` Hard Rule 1) says to avoid.

This is a structural change under both repos' own rules — it adds a new
shared command file plus two vault instances (>2 files, alters what other
machines get when they update the marketplace) — so it gets a spec first,
per `tlelosa-claude-config/CLAUDE.md`'s "How DCOE applies here."

## Decision

Add a `/session-end` command, following the exact promotion pattern ADR-008
already established for `/continue`:

1. **`tlelosa-claude-config/hub-template/session-end.md`** — a
   vault-agnostic skeleton: verify the working tree is clean (or surface
   what isn't), reconcile `docs/todo.md` (Done/Open), append a
   `docs/session-log.md` entry *if the vault keeps one*, set this session's
   own title via `set_session_title` if that tool exists, and report a
   short close-out. No vault-specific content, so it can be copied
   verbatim into any hub root's `.claude/commands/session-end.md`, same as
   `hub-template/continue.md`.
2. **`tlelosa-claude-config/.claude/commands/session-end.md`** — minimal
   instance for this repo itself: no `session-log.md` (this repo keeps
   none, same reason `continue.md`'s local copy omits it), no
   `knowledge/` step (that cache lives in the `Claude-Code` hub, not here).
   Just `docs/todo.md` reconciliation + git-state check + title-set.
3. **`Claude-Code/.claude/commands/session-end.md`** — full hub instance:
   adds the `knowledge/<topic>.md` + `knowledge/INDEX.md` update step (Hard
   Rule 5 in this hub's own `CLAUDE.md`) and writes the
   `docs/session-log.md` entry in the existing dated-entry format (matches
   what `/continue`'s Step 1 already reads).

**Why a title-set, not a direct `archive_session` call:** `/continue`'s own
Step 0 documents that a session cannot rename or archive *itself* —
`set_session_title`/`archive_session` only ever target *other* sessions
from within a given session's tool surface. So `/session-end` cannot
literally archive the session it's running in. What it *can* do is leave
the session in a state where a **later** `/continue` run's Step 0/0.5 can
recognize and archive it immediately — by setting the descriptive
`Cont-"<title>"` title itself (removing the need to reverse-engineer one
from the transcript) and by making sure `docs/todo.md`/`session-log.md`
already reflect the work, so Step 0.5's "is this superseded/stale" judgment
call is trivial instead of a transcript read. That is what "prepare the
session for archiving" means here — the actual archive action stays a
different session's / Tebello's call, same as it already is today.

**Distribution mechanism:** file copy, same as `/continue` (ADR-008) — not
a plugin/`@import`, since this needs to run as each vault's own local slash
command.

## Alternatives considered

- **Have `/session-end` call `archive_session` on itself** — not possible;
  ruled out by the tool-surface constraint documented in `/continue` Step
  0 point 5, not a design preference.
- **Fold this into `/continue` itself (a "wrap up" step at the end of the
  same command)** — rejected: `/continue` runs at session *start*, before
  any new work happens; a close-out step belongs at the point work actually
  stops, which isn't a fixed offset from when it started. Keeping them
  separate commands also means `/session-end` can run mid-session if
  Tebello wants a checkpoint without ending the conversation.
- **No shared template, author each vault's `session-end.md`
  independently** — rejected for the same reason ADR-008 rejected it for
  `/continue`: every fix (e.g. a future stale-tree edge case) would need
  independent rediscovery per vault instead of one shared skeleton.

## Consequences

- `/continue`'s Step 0 gets cheaper over time as more sessions actually run
  `/session-end` before stopping — titles arrive pre-set instead of
  needing a transcript read, and `docs/todo.md`/`session-log.md` arrive
  already reconciled instead of stale.
- Like `/continue`, this is file-copy distribution — an improvement made to
  one vault's `session-end.md` doesn't propagate automatically to the
  others; backporting into `hub-template/session-end.md` and re-copying is
  a manual, deliberate step, same tradeoff ADR-008 already accepted.
- `session-end.md`'s git-state check reuses the same "surface, never
  silently discard" discipline as `/continue`'s own Step 1 — it reports
  uncommitted/unpushed work, it does not commit or push on Tebello's
  behalf without being asked.

## Post-implementation corrections (2026-08-06)

Item 3 (`Claude-Code/.claude/commands/session-end.md`) was **not** actually
created when this spec was first marked `Status: Implemented` — only items 1
and 2 shipped in `a56ea84`. The hub instance was written 2026-08-06; the
status line is accurate as of then. Worth noting as a process point: a
cross-repo item in a spec can lag its status line, since the status is set
in the repo the spec lives in.

Two defects surfaced on the command's first real run and are fixed in the
same change that closed item 3:

1. **The session-log step over-appended.** It said "append a new dated
   entry" unconditionally, which produces a duplicate or near-empty entry
   when the session already wrote its own entries, or when `/session-end`
   runs twice (mid-session checkpoint, then again at the end). Reworded to
   reconcile-not-duplicate, with the three cases spelled out.
2. **The title step was framed as attempt-then-handle-failure, but on some
   surfaces it cannot be attempted at all.** On the CCD desktop surface
   `set_session_title` rejects the current session *and* `list_sessions`
   excludes it, so a session cannot obtain its own ID — there is no call to
   make and no error to catch. Reworded to report `not available in this
   environment` outright, and to not go hunting for the ID elsewhere.

## References

- `hub-template/session-end.md`, `.claude/commands/session-end.md` (this
  repo), `Claude-Code/.claude/commands/session-end.md`
- ADR-008 (`Claude-Code/docs/decisions/ADR-008-hub-template-promotion.md`)
  — the `/continue` promotion this spec mirrors
- `hub-template/continue.md` Step 0 / Step 0.5 (ADR-005) — the
  archive-detection flow this command feeds into
