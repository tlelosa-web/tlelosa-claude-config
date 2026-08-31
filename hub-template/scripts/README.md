# hub-template/scripts — optional per-project scripts

- `qwen-review.sh` — local review fallback (tier 2) for `/codex-review`
  (`codex-gate` plugin). Only used when Codex itself fails (quota, network,
  not installed). Talks to a local Ollama instance (`localhost:11434`) —
  never leaves the machine, so it's outside `/codex-review`'s Hard Payload
  Rule entirely. Requires Ollama running locally with `qwen3:1.7b` pulled
  (`ollama pull qwen3:1.7b`). Missing-only in effect: if this file isn't
  installed in a project, `/codex-review` just skips straight to solo —
  installing it is optional, not required for `/codex-review` to work.
  Spec: `docs/specs/2026-08-31-multi-tier-review-fallback.md` (in
  `ai-product-factory`, not this repo — cross-project spec, mirror here if
  it needs updating).

  **Model is `qwen3:1.7b`, not a larger one.** Measured 2026-08-31:
  `qwen3:8b` took ~35s for a one-word reply on ordinary consumer hardware —
  not viable inside any sane review timeout. `1.7b` completed a full
  real-spec review in ~123s. Re-measure before changing this on a
  faster/slower machine; don't assume a bigger local model is free just
  because it's local — latency is a real cost.

  **Output is zero decision weight, not a peer opinion.** Measured the same
  day: this tier's review of a real spec contained multiple factually
  incorrect claims (flagged already-handled cases as unhandled). Treat its
  output as a source of stray secondary points only, never as evidence for
  or against a spec's soundness — `reviewer` retains sole APPROVE/BLOCK
  regardless of what this tier says.

## Install into a project

```bash
mkdir -p scripts
cp <this-repo>/hub-template/scripts/qwen-review.sh scripts/
chmod +x scripts/qwen-review.sh
```

Not registered in `.claude/settings.json` — this is invoked directly by
`/codex-review`'s own steps (`codex-gate/commands/codex-review.md` step 4a),
not a hook.

## Why this lives in `hub-template/scripts/`, not bundled inside `codex-gate/`

A plugin install from Claude Code's per-plugin cache only copies that
plugin's own folder, not repo-root siblings — the exact failure mode in
`docs/specs/2026-08-20-hook-crash-cache-relative-path.md`. Bundling this
script inside `codex-gate/` wouldn't hit that specific bug (it'd be inside
the plugin's own folder), but it would need to run from the *target
project's* working context regardless — same reasoning `secret-scan.sh` and
`auto-format.sh` already follow: per-project copy-install, not
plugin-bundled execution.
