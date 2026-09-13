# Ingester: mutate existing items from a follow-up transcript

## Context

The `/ingest-transcript` skill only produces new items in practice. A follow-up meeting closes open items, retires risks, accepts proposed decisions, confirms hedged claims and changes mitigations, and the skill needs to write those changes into the existing register files.

The mechanism has a mutation path on paper (`Target: <existing id>` on an F4 item block), but it is unusable: `check-integrity --proposed` re-declares the id and fails rule I1 ("id appears more than once"), and S3 runs that check as a gate. Verified with a scratch engagement holding one open item and a dossier that closes it. Behind that blocker, `s3-write` drops the citations on an update, skips every body field (Mitigation, Trigger, Next action, Impact, Options, Rationale), does not resolve `item nn` references in field values, updates claims with Status and Confidence only, and never extends a topic's `closed-by` for a closure.

Change tracking decision (Adam, 11 September 2026): a `## History` section on every item file is the single record of changes, mirrored in the session log and rendered into `index/changes.md`. Git is backup only.

## Design

### Dossier form (F4, meaning clarified, shape unchanged)

`- Target: <id>` marks a mutation. The block carries only the fields that change, each as it should read afterwards. The Gist states every change as `Field: old to new` so the reviewer never opens the file to judge it. A lifecycle move that the model says needs a companion record (supersede a DEC, realise a RSK, disposition a LIM) is two items in the same dossier, the new one referenced as `item nn` from the update's Links, Resolution, Disposition record or Blocked by. Kind for a closure is `OI` with Target the existing id and Status Closed.

### New format F10: History line

In every register item file (REQ, DEC, LIM, RSK, OI) a fixed `## History` heading, last section of the body, one line per change:

```
- <D Month YYYY> | <Tnnn item nn | person's name> | <Field>: <old> to <new>; <Field>: <old> to <new> | <F2 citation or blank>
```

Claims get `- history:` as the last key of the claim section, each entry `  - <date> | <Tnnn item nn> | status: <old> to <new>; confidence: <old> to <new>`, and the new evidence lines appended to `- evidence:`. Hand edits use the same line form with a name in place of the transcript reference (the engagement CLAUDE.md already asks for a dated note; this is its form).

### Reading discipline for a follow-up (rules R17 expanded)

Before segmenting, build the outstanding set from the item files: OI not Closed, RSK not Realised or Retired, DEC Proposed, REQ Draft, LIM Identified or Under assessment, claims Hedged or Contested, and the Questions for the SMEs in every earlier dossier under `sessions/`. Read the transcript against that set. Each member the session touches yields a mutation item; each on-subject member not reached is listed under a new Closing heading, `Outstanding not reached`. A lifecycle table in the rules names the allowed moves per type and what each needs (from `solution-register-model.md` section 4 and rules I7, I8, I9, I11, I13).

## Files to change

- `ingester/extraction-rules.md`: expand R17 with the outstanding set, the lifecycle table, the Gist convention for mutations; bump version.
- `.claude/skills/ingest-transcript/SKILL.md`: S1 gains a "Follow-up reading" step after the read order (build the outstanding set, prior dossiers' Questions), the mutation block form and Gist rule, the `Outstanding not reached` Closing heading, and a count of mutations beside new items in the S1 summary and LOG line. Bump version.
- `ingester/runbooks/S1.md`, `S3.md`: mention the outstanding set, the History line and the `changes.md` output. Bump versions.
- `ingester/templates/dossier.md`: add `### Outstanding not reached` under Closing and a `- Mutations:` header count. Add a second example item with `Target: OI-0001` in the F4 mutation form.
- `ingester/templates/items/{REQ,DEC,LIM,RSK,OI}.md`: add `## History` as the last section (empty on creation).
- `ingester/templates/items/claim.md`: nothing (history list appended only when a change happens; `render` leaves no blank key).
- `ingester/bin/check-integrity`: in the `--proposed` awk, when `target != "new"` emit only the changed fields plus `Proposed yes`, no second `ID` fact, so the merged view overlays the file. Add guards: DEC in Accepted may change only to Superseded (fail I11); OI in Closed may not change (fail I9); a mutation targeting an id not on disk fails I6. Update header comment.
- `ingester/bin/s3-write`:
  - `resolve_items` applied to every field value on create and update, not only Links.
  - Update branch for REQ/DEC/LIM/RSK/OI: read old value of each field (`fm` for frontmatter, a new `body_section` helper for headings) before writing; set frontmatter; replace body sections named in the block (new `body_set` helper in `lib.sh`, keeps heading order); append citations under Source or Raised by; append the F10 History line built from old/new pairs; set `updated`. Drop the bare dated Gist note.
  - Update branch for SYS.fact/PRC.step: record old status and confidence, set new ones, append evidence lines, append `- history:` entry, add session line.
  - Topics: for a closure (OI existing, Status Closed) extend the topic of the episode with `closed-by` = Resolution id when it is an id.
  - Session log `logrow` Item column carries the `Field: old to new` summary for updated rows.
- `ingester/bin/lib.sh`: `body_section file heading`, `body_set file heading text`, `history_add file line`.
- `ingester/bin/render-index`: new `index/changes.md`, one row per History line across all item files, columns Id, Date, Source, Change, Evidence, newest last; and a row per claim history entry.
- `ingester/README.md`: F10 in Formats, changes.md in F7, `render-index` row, Stages table S3 output; bump to 0.6.
- `ingester/VERSION`: 0.6.0. `ingester/IMPLEMENTATION-PLAN.md` row 364 note that History supersedes git-only tracking.
- `ingester/templates/CLAUDE.md`: hand edits append a History line in the F10 form.

## Verification

Scratch engagement under the scratchpad with `ENGAGEMENTS_ROOT` set (the probe from today is the seed): one STK, one OI Open, one RSK Identified, one DEC Proposed, one LIM Identified, one SYS with a Hedged claim, one TOP. A hand-written signed T002 dossier with: close the OI (Resolution `item 02`), a new DEC accepted by the SME, supersede the DEC, retire the RSK with a Mitigation reason, move the LIM to Under assessment with a new OI, confirm the claim Stated with new evidence, and one illegal move (reopen a Closed OI) in a second dossier.

1. `check-integrity --proposed` prints OK on the first dossier and FAIL I9 on the second.
2. `s3-write` succeeds; diff every item file: frontmatter set, body section replaced, citations appended, History line with correct old/new, claim evidence and history appended, topic `closed-by` extended, session log rows carry the summary, `index/changes.md` lists every line.
3. Rollback: break the second dossier so S3 fails after the gates; confirm the engagement is restored.
4. Existing behaviour: re-run a new-items-only dossier and confirm nothing changed except the empty History heading in new files.
5. `check-citations` still OK on dossiers containing mutation items.
