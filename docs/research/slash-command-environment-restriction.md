# Research: Slash-Command Environment Restrictions

**Status:** Open — awaiting test on desktop CLI  
**Raised:** 2026-07-19 (mobile app confirmed)  
**Tracked in:** `tlelosa-claude-config/docs/todo.md`, `hub-template/continue.md`

## Background

The Claude Code mobile app (Default session type) has a known restriction on slash-command invocation. When a user types `/continue`, the app returns "isn't available in this environment" even though:
- The command file exists and is correctly formed
- The same file works when invoked via the `Skill` tool in Claude Code Remote/web sessions
- This appears to be a client-side restriction, not a file issue

**Confirmed:** 2026-07-19 on mobile app  
**Workaround:** Ask in plain text ("continue" / "run continue") instead of slash form

## Open Question

**Does the desktop Claude Code CLI have the same restriction?**

- If **YES** → slash-commands are a platform-wide issue; note in `hub-template/continue.md` must be escalated from "surface quirk" to "architectural problem"
- If **NO** → restriction is mobile-only; current note documenting mobile workaround is sufficient

## Test Procedure

**Environment:** Desktop Claude Code CLI (Windows or macOS)

**Preconditions:**
- This repo cloned locally: `tlelosa-claude-config`
- `.claude/commands/continue.md` exists in the repo
- Currently in a project directory where `/continue` would be invoked

**Test Steps:**

1. Open a new Claude Code session in the CLI
2. Type: `/continue`
3. Observe and record the response:
   - **Success case:** Command runs normally (shows session resume report)
   - **Failure case:** Returns "isn't available in this environment" or similar error
   - **Alternative case:** Command not recognized at all (different error)

4. If failure, test the workaround:
   - Type: `continue` (plain text, no slash)
   - Observe whether the `Skill` tool can invoke it
   - Record whether this works

**Acceptance Criteria:**

Result must clearly answer: **Can the desktop CLI invoke `/continue`, yes or no?**

## Recording the Result

Once tested, update `tlelosa-claude-config/docs/todo.md`:
- Move this item from Open to Done
- Record the test result (CLI: YES / NO / DIFFERENT_ERROR)
- If NO, escalate the note in `hub-template/continue.md` (lines 13–19)
- If YES, document that the restriction is mobile-only

Also update the note in `hub-template/continue.md` (line 18–19) to replace "still unconfirmed" with the test result.

## Context

This verification matters because:
1. **Slash-command support** is a core Claude Code feature — if it's broken on the CLI too, every vault's commands are degraded
2. **Platform consistency** — understanding which surfaces have the restriction helps set correct expectations for users across mobile, web, and CLI
3. **Workaround scope** — knowing whether to recommend the plain-text workaround to all users or just mobile ones
