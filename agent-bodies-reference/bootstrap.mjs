#!/usr/bin/env node
/**
 * bootstrap.mjs — make the DCOE roster and required plugins present on this machine.
 *
 * Spec: docs/specs/2026-08-09-universal-roster-and-codex-gate.md (Claude-Code hub).
 * Replaces bootstrap.sh on the hook path. bootstrap.sh is kept as a hand-run
 * fallback only — it is bash, and Node is what Claude Code already guarantees.
 *
 * Modes:
 *   (default)   missing-only. Copies roster files that are ABSENT. Never
 *               overwrites a present file — per-machine edits are legitimate
 *               under docs/specs/2026-07-29-strip-dcoe-roster-agent-bodies.md.
 *               Reports divergence instead of silently reverting it.
 *   --repair    restores every roster file from the reference copy, overwriting
 *               local edits. The deliberate "put it back" path.
 *   --check     reports only; writes nothing. Exit 1 if anything is missing.
 *
 * Design rules this file must keep:
 *   - Loud on failure. Silence means success; it must never mean "never ran".
 *     A bootstrap that fails quietly rebuilds the very defect it exists to fix.
 *   - Never corrupt settings.json. Parse, back up, temp-write, validate, rename.
 *   - Tolerate concurrent session starts. Two sessions may race here.
 *   - Never throw out of top level; a hook crash must not take the session down.
 */

import { readFileSync, writeFileSync, copyFileSync, mkdirSync, existsSync, renameSync, readdirSync, unlinkSync } from "node:fs";
import { homedir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const HOME = homedir();
const AGENTS_DIR = join(HOME, ".claude", "agents");
const SETTINGS = join(HOME, ".claude", "settings.json");
const MANIFEST = join(HERE, "roster-manifest.json");
const TAG = "dcoe-bootstrap";

const argv = new Set(process.argv.slice(2));
const MODE = argv.has("--repair") ? "repair" : argv.has("--check") ? "check" : "missing";
const QUIET = argv.has("--quiet");

/** Single-line reporter. Anything user-visible goes through here. */
const say = (msg) => console.log(`${TAG}: ${msg}`);
const fail = (msg) => { console.log(`${TAG}: ${msg}`); process.exitCode = 1; };

function loadManifest() {
  if (!existsSync(MANIFEST)) {
    fail(`reference manifest missing at ${MANIFEST} — roster not deployed`);
    return null;
  }
  try {
    const m = JSON.parse(readFileSync(MANIFEST, "utf8"));
    if (!Array.isArray(m.agents) || m.agents.length === 0) {
      fail(`manifest at ${MANIFEST} has no agents[] — roster not deployed`);
      return null;
    }
    return m;
  } catch (e) {
    fail(`manifest at ${MANIFEST} is not valid JSON (${e.message}) — roster not deployed`);
    return null;
  }
}

/** Atomic-ish copy: write a temp sibling, then rename over the destination. */
function safeCopy(src, dest) {
  const tmp = `${dest}.${process.pid}.tmp`;
  copyFileSync(src, tmp);
  renameSync(tmp, dest);
}

function syncRoster(manifest) {
  const result = { copied: [], diverged: [], missingRef: [] };

  try {
    mkdirSync(AGENTS_DIR, { recursive: true });
  } catch (e) {
    fail(`cannot create ${AGENTS_DIR} (${e.message}) — roster not deployed`);
    return null;
  }

  for (const agent of manifest.agents) {
    const src = join(HERE, agent.file);
    const dest = join(AGENTS_DIR, agent.file);

    if (!existsSync(src)) { result.missingRef.push(agent.file); continue; }

    const present = existsSync(dest);

    if (!present || MODE === "repair") {
      if (MODE === "check") { result.copied.push(agent.file); continue; }
      try {
        safeCopy(src, dest);
        result.copied.push(agent.file);
      } catch (e) {
        // A concurrent session may have created it between our check and write.
        if (!existsSync(dest)) fail(`failed writing ${agent.file} (${e.message})`);
      }
      continue;
    }

    // Present and we are not repairing: report drift, never revert it.
    try {
      if (readFileSync(src, "utf8") !== readFileSync(dest, "utf8")) result.diverged.push(agent.file);
    } catch { /* unreadable local file is not fatal — repair mode is the fix */ }
  }

  return result;
}

/**
 * Ensure every plugin in manifest.requiredPlugins is enabled in the user's
 * settings.json. Owner decision 2026-08-09: codex-gate goes on every machine
 * unconditionally, ahead of Fan Movement IT clearance for OpenAI egress.
 * See the spec's Amendment section, decision B.
 */
function ensurePlugins(manifest) {
  const required = manifest.requiredPlugins ?? [];
  if (required.length === 0 || MODE === "check") return [];

  let settings = {};
  let raw = null;

  if (existsSync(SETTINGS)) {
    try {
      raw = readFileSync(SETTINGS, "utf8");
      settings = JSON.parse(raw);
    } catch (e) {
      // Never overwrite a file we could not parse — that is how configs die.
      fail(`${SETTINGS} is not valid JSON (${e.message}) — left untouched, plugins not enabled`);
      return [];
    }
  }

  const enabled = settings.enabledPlugins ?? {};
  const added = required.filter((p) => enabled[p] !== true);
  if (added.length === 0) return [];

  for (const p of added) enabled[p] = true;
  settings.enabledPlugins = enabled;

  const tmp = `${SETTINGS}.${process.pid}.tmp`;
  try {
    const next = JSON.stringify(settings, null, 2) + "\n";
    JSON.parse(next); // validate what we are about to commit, before we commit it
    if (raw !== null) writeFileSync(`${SETTINGS}.bak`, raw, "utf8");
    writeFileSync(tmp, next, "utf8");
    renameSync(tmp, SETTINGS);
    return added;
  } catch (e) {
    try { if (existsSync(tmp)) unlinkSync(tmp); } catch { /* best effort */ }
    fail(`could not enable ${added.join(", ")} (${e.message}) — settings.json unchanged`);
    return [];
  }
}

function main() {
  const manifest = loadManifest();
  if (!manifest) return;

  const roster = syncRoster(manifest);
  if (!roster) return;

  if (roster.missingRef.length) {
    fail(`reference copy incomplete — missing ${roster.missingRef.join(", ")}`);
  }

  const plugins = ensurePlugins(manifest);

  if (MODE === "check") {
    const stray = existsSync(AGENTS_DIR)
      ? readdirSync(AGENTS_DIR).filter((f) => f.endsWith(".md") && !manifest.agents.some((a) => a.file === f))
      : [];
    if (roster.copied.length) fail(`missing ${roster.copied.length}/${manifest.agents.length}: ${roster.copied.join(", ")}`);
    else say(`all ${manifest.agents.length} roster agents present`);
    if (roster.diverged.length) say(`locally edited: ${roster.diverged.join(", ")}`);
    if (stray.length) say(`not in manifest: ${stray.join(", ")}`);
    return;
  }

  // Steady state is silent. Only actual changes and real problems speak.
  const notes = [];
  if (roster.copied.length) {
    notes.push(MODE === "repair"
      ? `restored ${roster.copied.length} roster agent(s)`
      : `installed ${roster.copied.length} missing roster agent(s): ${roster.copied.join(", ")}`);
  }
  if (plugins.length) notes.push(`enabled ${plugins.join(", ")} — restart Claude Code to load`);
  if (roster.diverged.length && !QUIET) {
    notes.push(`locally edited, left as-is: ${roster.diverged.join(", ")} (--repair to restore)`);
  }
  if (notes.length) say(notes.join(" | "));
}

try {
  main();
} catch (e) {
  // Last line of defence: a hook must never take the session down with it.
  fail(`unexpected failure (${e.message}) — roster may be incomplete`);
}
