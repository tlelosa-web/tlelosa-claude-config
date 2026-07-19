---
# /end-session — Archive this session's outcome on tlelosa-claude-config
# The "archiving" half of the /continue pair: makes sure the next session
# (here or on the other machine) starts from a true record instead of
# re-deriving or re-litigating what already happened.
---

## Step 1 — Verify nothing is left dangling

```
git status
```

Flag uncommitted changes rather than silently archiving around them. Ask
whether to commit/push before closing out, or leave them for next session
(and note that explicitly in the log entry if so).

## Step 2 — Summarize the session

Pull together, from the actual conversation (not assumptions):
- What shipped (files touched, commits, PR if any)
- Any decision made that future sessions shouldn't re-litigate
- Anything Tebello had to manually correct or point out that the session
  should have caught itself — this is exactly what `/retro`'s pattern
  detection reads for later, so be honest and specific here, not vague
- What's still open / deferred, and why

## Step 3 — Append to `docs/session-log.md`

```
## [date] — [3-6 word summary]
**Shipped:** [files/commits/PR]
**Decisions:** [none | short list]
**Manual corrections needed:** [none | what, and why the session missed it]
**Still open:** [none | short list, should also be reflected in todo.md]
```

Keep entries append-only — never rewrite a past entry, even to "clean it up."

## Step 4 — Update `docs/todo.md`

- Remove/check off anything this session actually finished
- Add anything new that surfaced but wasn't done
- Don't leave a completed item sitting in todo.md — that's exactly the
  staleness `/retro` and `/continue`'s Step 1 are trying to avoid

## Step 5 — Report the close-out

Short confirmation to Tebello: what got logged, what's still open, whether
anything needs attention before the next session (e.g. "PR still needs a
review" or "uncommitted changes left on purpose, see log").
