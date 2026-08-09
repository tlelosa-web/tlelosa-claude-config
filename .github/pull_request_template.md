## What changed

<!-- One or two sentences. What a reader needs to know before the diff. -->

## Why

<!-- The problem this solves. Link the todo item or the session that found it. -->

## Scope

<!-- Router classification, per CORE.md rule 0. Delete the one that doesn't apply. -->

- **Trivial** — single-file edit, typo, version bump. No contract, schema,
  governance, or cross-project effect.
- **Structural** — touches contracts, data, security, governance/shared-core
  docs (`CORE.md`, an agent body), or what the machines install.

## DCOE gates

- [ ] **Spec:** `docs/specs/<name>.md` — or **N/A, Trivial** per the Router.
- [ ] **Reviewer:** the `reviewer` agent APPROVEd — or **not run**, with the
      reason below.

<!-- If either box is unchecked, say why here. Unchecked does not block merge;
     unexplained is what makes the record useless later. -->

## Verification

<!-- What you actually ran, and what it printed. For any commit touching a
     catalog or plugin manifest, hard rule 3 wants:
       python -m json.tool .claude-plugin/marketplace.json
       python -m json.tool dcoe-roster/plugin.json
       python -m json.tool shared-skills/plugin.json
       python -m json.tool codex-gate/plugin.json
     "Not applicable, markdown only" is a fine answer. -->
