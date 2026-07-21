---
description: Resume work on tlelosa-claude-config from where the last session ended
---

# /continue — Config Repo Session Resume

Minimal adaptation of `hub-template/continue.md` for this repo itself.
The hub template's session-hygiene steps (Step 0/0.5: `list_sessions`,
`set_session_title`, `archive_session`) are deliberately omitted — those
tools exist on the hub machines, not necessarily here — as is the
`session-log.md` read (this repo keeps no session log) and the CORE.md
upstream check (meaningless inside the source repo itself).

## Step 1 — Orient

Read:
- `docs/todo.md` → task list (Done + Open)
- `dcoe-roster/CORE.md` → if not already read this session per `CLAUDE.md`

Then check repo state:

```bash
git status --short --branch
git log --oneline -10
```

Uncommitted changes or unpushed commits are part of "where the last
session ended" — surface them, never silently discard or commit them.

## Step 2 — Identify Scope

Classify the next task per `CLAUDE.md`'s "How DCOE applies here":
- **Single-file markdown/JSON edit** → straight to Execute once confirmed.
- **Structural** (new plugin, schema change, > 2 files, anything altering
  what other machines install) → a spec in `docs/specs/` must exist or be
  written first.

## Step 3 — Report State

```
## Session Resume

**Last completed:** [from todo.md Done / recent commits]
**Next task:** [from todo.md Open]
**Type:** [single-file edit | structural]
**Spec:** [exists at docs/specs/<name>.md | MISSING — write before building | N/A]
**Working tree:** [clean | uncommitted changes / unpushed commits — listed]
**Blockers:** [none | description]

Ready to proceed? Confirm and I'll start.
```

**Always follow the prose block with a selectable list** via
`AskUserQuestion` (single question, single-select unless items are clearly
independent), built from every open item in `docs/todo.md` plus anything
surfaced above. Standing preference inherited from the hub template —
never leave Tebello to respond in free text only.

## Step 4 — Wait for Confirmation

Do not begin implementation. Do not open files beyond the reads above.
Wait for Tebello to confirm the task or redirect.

## Spec Gate Reminder

If the next task is structural and no spec exists in `docs/specs/` →
surface this immediately. Spec must be written and confirmed before
implementing.
