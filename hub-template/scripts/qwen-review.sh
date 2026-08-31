#!/bin/bash
set -euo pipefail

# Local review fallback (tier 2) for /codex-review's fail-warn path.
# Spec: docs/specs/2026-08-31-multi-tier-review-fallback.md (T1).
# Fail-warn only: never blocks, never retries, exit 0 on any failure.
# Local-machine only — fails fast (not a hang) when Ollama isn't running,
# which is the expected state on any cloud/remote Claude Code session.
#
# Model is qwen3:1.7b, not qwen3:8b: measured on this machine 2026-08-31,
# qwen3:8b took ~35s for a one-word reply (cold or warm) — not viable
# inside any sane review timeout. qwen3:1.7b completed a ~1200-word spec
# review in ~123s, but a follow-up run against a ~1850-word spec timed out
# at 180s — `curl localhost:11434/api/ps` shows size_vram:0, i.e. this is
# CPU-only inference on this machine, so latency scales with input size,
# not just a fixed per-call cost. There is no single timeout that's safe
# for an arbitrarily large spec on this hardware — this is a known,
# accepted limitation of this tier, not a bug to keep chasing with a
# bigger number. A timeout here is expected, normal fail-warn behavior for
# a long spec, exactly like any other failure mode this script handles.

SPEC_FILE="${1:-}"
MODEL="qwen3:1.7b"
OLLAMA_HOST="http://localhost:11434"
CALL_TIMEOUT=240

if [ -z "$SPEC_FILE" ] || [ ! -f "$SPEC_FILE" ]; then
  echo "qwen-review: refused — argument must be an existing file" >&2
  exit 0
fi

# Availability probe, short timeout — fails fast when Ollama isn't running
# (e.g. every cloud/remote session) rather than hanging.
if ! curl -s --max-time 2 "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
  echo "qwen-review: unavailable (Ollama not reachable at $OLLAMA_HOST) — skipping" >&2
  exit 0
fi

# Build the payload and call the API in Python (available on this machine;
# jq is not — confirmed before writing this, not assumed). Avoids fragile
# manual JSON string-escaping of arbitrary spec content in bash.
python - "$SPEC_FILE" "$MODEL" "$OLLAMA_HOST" "$CALL_TIMEOUT" <<'PYEOF'
import sys, json, urllib.request

spec_path, model, host, call_timeout = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

with open(spec_path, "r", encoding="utf-8") as f:
    content = f.read()

# Strip a leading YAML frontmatter block, same rule as /codex-review step 2.
if content.startswith("---\n"):
    end = content.find("\n---\n", 4)
    if end != -1:
        content = content[end + 5:]

instruction = (
    "You are an independent reviewer from a different model family giving a "
    "second opinion on an implementation spec. Do not rubber-stamp. Report: "
    "(1) buried or unstated assumptions; (2) missing or untestable "
    "acceptance criteria; (3) failure modes the spec does not consider; "
    "(4) architectural alternatives you would seriously weigh instead, and "
    "why. Be concrete and reference the spec's own wording. If the spec is "
    "sound, say so briefly rather than inventing objections."
)
prompt = instruction + "\n---\n" + content

payload = json.dumps({
    "model": model,
    "prompt": prompt,
    "stream": False,
    "think": False,
}).encode("utf-8")

req = urllib.request.Request(
    f"{host}/api/generate",
    data=payload,
    headers={"Content-Type": "application/json"},
    method="POST",
)

try:
    with urllib.request.urlopen(req, timeout=call_timeout) as resp:
        body = json.loads(resp.read().decode("utf-8"))
except Exception as e:
    print(f"qwen-review: call failed ({e}) — skipping", file=sys.stderr)
    sys.exit(0)

text = body.get("response", "").strip()
if not text:
    print("qwen-review: empty response — skipping", file=sys.stderr)
    sys.exit(0)

print(text)
PYEOF
