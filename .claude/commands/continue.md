---
# /continue — Resume work on tlelosa-claude-config itself
# This repo is a plugin marketplace, not a hub-and-spoke vault — this
# command is a simplified, repo-specific sibling of hub-template/continue.md
# (that one is a template for OTHER vaults; this one governs this repo).
---

## Step 1 — Verify remote state (CORE.md hard rule 9)

```
git fetch origin main
git log origin/main..HEAD --oneline   # anything local not yet pushed?
git log HEAD..origin/main --oneline   # anything upstream not yet pulled?
```

Do not trust a cached local branch ref for this — the whole reason this
command exists is a session having asserted stale git state earlier. If
`origin/main` has moved since the last session-log entry, say so before
reading further — the plan below may already be partly done or superseded.

## Step 2 — Orient

Read:
- `docs/todo.md` → current task queue
- `docs/session-log.md` → last 1-2 entries (what shipped, what's still open)

## Step 3 — Report state

```
## Session Resume — tlelosa-claude-config

**Remote check:** [origin/main matches last session-log entry | N commits
ahead/behind — describe]
**Last completed:** [from session-log.md]
**Next pending:** [from todo.md]
**Blockers:** [none | description]
```

Then **always follow with a selectable list** via `AskUserQuestion`
(single-select unless items are clearly independent) built from every open
`docs/todo.md` item — don't leave Tebello to respond in free text only.

## Step 4 — Wait for confirmation

Do not begin implementation until Tebello confirms or redirects.

---

When the work is done, close out with `/end-session` — don't leave
`docs/todo.md`/`docs/session-log.md` stale for the next session to untangle.
