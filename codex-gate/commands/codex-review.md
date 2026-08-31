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
   90 s timeout — means Codex is unavailable this run. Do not stop yet —
   go to step 4a (local fallback) before falling back to solo.

4a. **Local fallback (tier 2), only on Codex failure.** Check for
   `${CLAUDE_PROJECT_DIR}/scripts/qwen-review.sh` with a file-existence
   guard — most projects won't have it installed, and that's a normal,
   silent skip, not an error (same missing-only philosophy as the roster
   bootstrap hooks). If present, run it against the same payload file used
   for Codex (unstripped-frontmatter spec content — the script does its own
   stripping):
   `bash "${CLAUDE_PROJECT_DIR}/scripts/qwen-review.sh" <spec-file>`
   with a 180 s cap (the script enforces its own internal timeout; wrap in
   `timeout 185` as an outer guard only). Canonical source:
   `hub-template/scripts/qwen-review.sh` — install into a project the same
   way as the hooks (`hub-template/hooks/README.md`'s pattern), not bundled
   inside this plugin (a plugin-cache install only copies the plugin's own
   folder, and this script needs to run from the *target* project's own
   context, not the plugin's — same reasoning as
   `docs/specs/2026-08-20-hook-crash-cache-relative-path.md`, applied in
   the opposite direction: don't reach for a path that won't exist where
   this actually runs).

   The script is local-only by design (talks to `localhost:11434`, never
   leaves the machine) — this does not touch the Hard Payload Rule above,
   which governs what leaves the machine to Codex.

   Any failure from the script itself (Ollama not running, model missing,
   timeout, empty output) — the script already fail-warns to stderr and
   exits 0; treat that identically to "not installed": fall through to
   solo, step 4b.

   If it succeeds: go to step 5 with the Qwen output, log state `warned
   (codex: <reason>) — qwen fallback ran`.

4b. **Solo, if both tiers failed or tier 2 isn't installed.** Print
   `Codex second opinion unavailable (<short reason>) — proceeding solo`.
   If `scripts/qwen-review.sh` wasn't present at all, also print: `No
   automated second opinion available. Consider asking the reviewer agent
   to read this spec with an adversarial brief before dispatch (per CORE.md
   Hard Rule 9's fallback chain).` This is a printed recommendation only —
   this command cannot spawn a `reviewer` agent itself. Do step 6 with
   `warned (<reason>) — no fallback available`, and stop **successfully**.
   Never retry, never block, never treat any of this as a task failure.

5. **Append the advisory note** to the spec file (Edit tool), at the end.

   If Codex ran (the normal case):
   ```markdown
   ## Codex second opinion (advisory) — <YYYY-MM-DD>

   <Codex output verbatim>

   _Advisory only — reviewer agent retains sole APPROVE/BLOCK authority._
   ```

   If the local fallback ran instead (step 4a succeeded):
   ```markdown
   ## Local review fallback (qwen3:1.7b, advisory, zero weight) — <YYYY-MM-DD>

   Codex was unavailable (<reason>). The following is a local-model second
   opinion, included for a partial check only. Measured 2026-08-31: this
   tier's output can contain factually incorrect claims about the spec it
   reviewed (flagged already-handled cases as "not considered"). Read for
   stray useful points only — never treat agreement or disagreement here as
   evidence for or against the spec's soundness.

   <qwen output verbatim>

   _Advisory only, zero decision weight — reviewer agent retains sole APPROVE/BLOCK authority._
   ```

   Touch nothing else in the file or repo.

6. **Log one line** to `docs/session-log.md` if that file exists (create
   nothing if it doesn't):
   `<YYYY-MM-DD> codex-review <file>: ran` or
   `<YYYY-MM-DD> codex-review <file>: warned (<reason>)` — using whichever
   state string step 4/4a/4b produced.

7. **Report** to the human: which tier actually produced the opinion (Codex,
   local fallback, or neither), and a one-paragraph summary of its
   strongest point if one ran. If the local fallback ran, say so explicitly
   and restate its zero-weight status — never present it with the same
   framing as a Codex result. The human decides what, if anything, changes
   in the spec — a logged note is sufficient; no disposition ceremony is
   required before approval.
