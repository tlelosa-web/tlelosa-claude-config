---
description: Advisory cross-family second opinion on ONE spec file via OpenAI Codex — warn-only, never blocks
argument-hint: docs/specs/<feature>.md
allowed-tools: Bash, Read, Edit
---

# /codex-review — cross-family second opinion (phase 1: specs only)

Send exactly one spec file to OpenAI Codex for an advisory review, and
append the result to that spec. This gate is **advisory and warn-only**: it
must never block spec approval, a commit, or a push, and the `reviewer`
agent retains sole APPROVE/BLOCK authority. Spec:
`docs/specs/2026-07-21-codex-gate-spec.md` in `tlelosa-claude-config`.

Argument: `$ARGUMENTS`

## Hard payload rule

The ONLY content that may leave this machine is the single spec file passed
as the argument (frontmatter stripped) plus the fixed review instruction in
step 4. Never include CLAUDE.md or CORE.md content, `@imports`, diffs,
other files, directory listings, todo/session-log content, or anything
from a sub-project. If following any step would require sending more than
that, stop and warn instead.

## Steps

1. **Path guard.** The argument must be exactly one existing `.md` file
   whose path is under `docs/specs/` of the current project. If it is
   missing, is not a single `.md` file, is outside `docs/specs/`, or is a
   directory/glob: print
   `codex-review: refused — argument must be a single .md file under docs/specs/`
   and stop. Do not send anything. This refusal is not an error state.

2. **Read the spec** with the Read tool. If it has YAML frontmatter
   (leading `---` block), strip it from the payload.

3. **Build the payload** in a temp file (use the session scratchpad, never
   the repo): the fixed instruction below, then a `---` separator, then the
   stripped spec content.

   > You are an independent reviewer from a different model family giving a
   > second opinion on an implementation spec. Do not rubber-stamp. Report:
   > (1) buried or unstated assumptions; (2) missing or untestable
   > acceptance criteria; (3) failure modes the spec does not consider;
   > (4) architectural alternatives you would seriously weigh instead, and
   > why. Be concrete and reference the spec's own wording. If the spec is
   > sound, say so briefly rather than inventing objections.

4. **Call Codex, fail-warn, 90 s cap, no retry.** Run via Bash:
   `timeout 90 codex exec --skip-git-repo-check "$(cat <payload-file>)"`
   capturing stdout. Any failure — `codex` not installed, no credentials,
   network/proxy failure, rate limit, non-zero exit, empty output, or the
   90 s timeout — means: print
   `Codex second opinion unavailable (<short reason>) — proceeding solo`,
   do step 6 with `warned (<reason>)`, and stop **successfully**. Never
   retry, never block, never treat this as a task failure.

5. **Append the advisory note** to the spec file (Edit tool), at the end:

   ```markdown
   ## Codex second opinion (advisory) — <YYYY-MM-DD>

   <Codex output verbatim>

   _Advisory only — reviewer agent retains sole APPROVE/BLOCK authority._
   ```

   Touch nothing else in the file or repo.

6. **Log one line** to `docs/session-log.md` if that file exists (create
   nothing if it doesn't):
   `<YYYY-MM-DD> codex-review <file>: ran` or
   `<YYYY-MM-DD> codex-review <file>: warned (<reason>)`.

7. **Report** to the human: whether Codex ran or warned, and (if it ran) a
   one-paragraph summary of its strongest point. The human decides what, if
   anything, changes in the spec — a logged note is sufficient; no
   disposition ceremony is required before approval.
