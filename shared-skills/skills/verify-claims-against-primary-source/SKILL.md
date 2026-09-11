---
name: verify-claims-against-primary-source
description: Use the moment a subagent's report, a task brief's Context section, a returned diff, or any second-hand summary states something about a schema, API contract, config shape, file, or repo state — and you are about to implement against it OR record it in a durable artifact (a todo, a spec, a commit message, a PR body, a published page). Trigger on "the subagent reported X, add it to the todo", on any claim attributed to a source you did not open yourself in this session, and on any count you derived from a command's output. Open the actual file or run the actual command first: a paraphrase is a new, unverified claim even when it reads first-hand and even when it faithfully summarises a source you trust. Writing a verification command is not running it. Skip only when you have already read the primary source yourself this session.
---

## Why this exists

The damage is the **assertion**, not the implementation. Once a wrong claim
lands in a todo, a spec, a commit message or a PR comment, it is read as fact by
everyone downstream, including future sessions that will not re-derive it.

Five confirmed instances across three projects, and they split into two kinds.

**Reading failures — a source existed and was not opened.** A task brief
paraphrased a spec's own correct architecture-decision text and described a
`contacts` table as having a plain `tender_ocid UNIQUE` when the live DDL was
the composite `UNIQUE(tender_ocid, name, email)`. Another brief described
`fetch_log` with `started_at, ended_at, status` columns when the real shape was
`id, fetched_at, date_from, date_to, tender_count, new_count, error`. **Both
times the original spec was correct** — the drift entered in a second-hand
summary written minutes later, in the same planning pass, by the same process.
Nothing marked the paraphrase as unverified; it read exactly as authoritative
as the source it condensed.

The most expensive instance was not a task brief at all. A subagent reported
that `bootstrap.mjs --check` *"computes divergence but never fails on it,"*
framed as a bug. That was written into a todo and posted onto a live GitHub PR
**without anyone opening `bootstrap.mjs`**. Reading it afterwards showed it was
wrong three ways at once.

**Writing failures — a command was composed and not run.** A review pass
replaced a bad grep with a corrected one, published the corrected command beside
a denominator of 1, and never ran it. It returns 2. The corrected command was
published *as the fix* and was itself unverified — a second unverified claim
wearing the costume of a verification.

## Steps

1. **Open the primary source before the claim lands anywhere others read it.**
   Run `.schema` against the real database, hit the real endpoint, read the real
   config, open the actual file at the actual line. Do this even when the claim
   is attributed to a spec you already trust — the drift is in the paraphrase
   step, not the source.

2. **Two texts that trace back to one paraphrase are one claim, not two
   confirmations.** "The spec says X" and "the brief says X" only tell you the
   transcription did not lose fidelity. Neither tells you X was ever
   independently verified.

3. **Treat a subagent's report as a brief, not as evidence.** It reads
   first-hand ("I checked X") and is produced by a process you trust, which is
   exactly what makes it dangerous. The report is a pointer to a source; follow
   the pointer.

4. **A count you derived from a command's own output counts too.** Confirm the
   command's match condition is the predicate the count is *about* — `heading`
   versus `verdict`, `dated` versus `created`, anchored versus unanchored. A
   grep answers what you typed, not what you meant. Check whether an unanchored
   alternation matches the metric's own definition prose, and whether one branch
   is a dead subset of another.

5. **Compute first, then write.** Run the command, capture the output, and write
   the sentence from what came back. Composing the command and writing the
   sentence in the same breath, intending to run it after, is the failure mode —
   it is how a corrected grep got published beside a figure that disproves it.

6. **Fix drift at its transcription point**, and add a runtime assertion where
   practical, so the next paraphrase is caught mechanically rather than by
   another manual read.

7. **A `file:line` reference is a claim too**, and it decays the moment its
   target is edited. Re-resolve it after the edit, or anchor on a unique quoted
   string rather than a line number.

## Evidence this pattern recurs

Five instances, three projects: two `Projects/tenders` schema drifts
(2026-08-19), a blueprint-migration Context section (2026-08-20), the
`bootstrap.mjs --check` claim published to a live PR (2026-09-10), and the
unrun corrected grep (2026-09-10) — **three of them on published surfaces in a
single day, and the fifth inside the written record of the fourth.** The
pattern survives careful process: every one happened under a written spec, a
review gate, and an explicit verification rule already in force.
