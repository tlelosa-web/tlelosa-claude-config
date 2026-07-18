# Hub Root CLAUDE.md Checklist

**Source:** `tlelosa-claude-config` (`hub-template`) | **Companion to:**
`hub-template/continue.md` | **Not a file to install as-is** — this is a
checklist a session reconciles its own hub root's `CLAUDE.md` against, never
a template that overwrites one. A hub root's real content (its project
index, life-domain sections, whatever is genuinely local to that vault)
stays exactly as it is. Same "shared core only" principle as
`dcoe-roster/CORE.md` (ADR-007), one level up: hub-to-hub instead of
project-to-project.

## How to use this

1. Open the hub root's own `CLAUDE.md`.
2. Go through each item below. For each one: **already present and
   correct** → leave it alone, don't rewrite working text to match this
   checklist's exact wording. **Missing** → add it, in a style consistent
   with the rest of that file. **Present but stale/contradictory** (e.g.
   describes a command or hook as active when it doesn't exist on disk) →
   flag it to whoever's running this session rather than silently
   rewriting — the same discipline `folder-structure.md`-style audits
   already use.
3. Don't restructure sections that aren't on this list. This checklist adds
   the minimum needed to run the hub-and-spoke `/continue` pattern — it is
   not a full CLAUDE.md rewrite.

## Checklist

- [ ] **`CORE.md` read instruction.** Near the top of the file, an
      instruction telling Claude to read
      `~/.claude/plugins/marketplaces/tlelosa-claude-config/dcoe-roster/
      CORE.md` at session start and treat its contents (DCOE architecture,
      sub-agent roster, model routing, universal hard rules) as part of
      this hub's operating instructions. See `Operations/CLAUDE.md` for the
      exact wording this was first piloted with — copy the spirit, not
      necessarily character-for-character, since a hub root's file has its
      own voice.
- [ ] **`.claude/commands/continue.md` exists and is referenced.** If it's
      missing, copy `hub-template/continue.md` (this repo, verbatim — it's
      vault-agnostic, no Operations-specific content) into place at
      `<hub-root>/.claude/commands/continue.md`. If the hub root's
      `CLAUDE.md` already *describes* a resume flow or session hygiene
      commands as active, check they actually exist on disk — don't trust
      the prose over the filesystem (this exact gap — commands described
      as active but the folder empty — is what triggered this checklist's
      existence for Pappa T).
- [ ] **Hard rules don't relax `CORE.md`'s universal ones.** The hub root's
      own Hard Rules section may add local rules (e.g. this vault's own
      data-safety or project-onboarding rules) but must not contradict or
      soften anything in `CORE.md`'s Universal Hard Rules section (no code
      without a plan for >2 files, one task = one commit, ask before
      deleting production data, stop and ask when acceptance criteria are
      unclear, Opus is earned not assigned, etc.).
- [ ] **Hub-and-spoke framing is explicit.** The file should say, in its
      own words, that project-level `CLAUDE.md`/`AGENTS.md` files (any
      sub-project with its own brain) take precedence over this hub root
      for work done inside that project's folder — the hub root governs
      cross-project decisions and new work started at root, not everything
      everywhere.
- [ ] **`docs/todo.md` + `docs/session-log.md` exist** (or vault-equivalent
      paths) and are what `continue.md`'s Step 1 actually reads. If this
      vault uses different filenames for its task queue / session log,
      note the actual paths near the top of `CLAUDE.md` (or update
      `continue.md`'s Step 1 to point at them) rather than leaving a
      silent mismatch.

## After reconciling

Open a **fresh** session at the hub root and run `/continue`. A working
result looks like a real resume report grounded in that vault's own
`docs/todo.md`/session-log content — not silence, not "command not found,"
and not Operations' own project data (a fresh session pulling in the wrong
project's content means the file landed in the wrong place, not that the
mechanism is broken). Report the outcome back so the originating ADR/spec
can be closed out.
