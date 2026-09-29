# Runbook: backfill

Version 0.1, 29 September 2026.

## Purpose

Add the items of one register type to a transcript that was written before the type existed, without reopening what the reviewer has already signed. The first type backfilled this way is the pain point (PPT, ingester 0.12.0). Transcripts ingested from 0.12.0 onward produce pain points at S1 and S4 and need no backfill.

A backfill runs in two passes over an engagement.

1. **Promote.** `ingester/bin/promote-pain-points <engagement>` writes one PPT per process fact of Kind Pain point that no pain point links to yet. It uses no judgement and has no review file. It runs once for the engagement, before any transcript is backfilled.
2. **Backfill by transcript.** The skill reads each written transcript again for pain points only. It proposes the ones promotion could not see: a complaint about a system, recorded as a SYS.fact; one outside any process, dropped or recorded as a risk; a second voice agreeing with one already promoted. The reviewer signs a backfill file, and the write adds only pain points and links.

Rerunning S1 would give a different dossier, with the verdicts and hand edits of the signed one lost, so a backfill never does.

## Inputs

- `sessions/Tnnn/Tnnn.utterances.tsv`, the whole of it.
- `sessions/Tnnn/Tnnn.exchanges.md`, for speech acts and exchange outcomes.
- The signed session sheet, for roles, segments and standing.
- The signed dossier and processes file, for episode ids and titles and for what was already recorded from each exchange.
- `ingester/extraction-rules.md`, R3, R4, R7, R10, R13, R17, R22, R24 and R26 in particular.
- The engagement as it stands: every file under `pain-points/` (including those from pass 1 and from earlier transcripts), `systems/`, `processes/`, `requirements/`, `decisions/`, `risks/` and `stakeholders/`.

## Command

```
ingester/bin/promote-pain-points <engagement>          pass 1, once per engagement
ingester/bin/stage <engagement> Tnnn backfill PPT      pass 2, per transcript
ingester/bin/stage <engagement> Tnnn backfill PPT check
```

`stage ... backfill PPT` refuses unless the transcript's S4 is written and its PPT backfill is not. With no backfill file it says the reading is the skill's (`/ingest-transcript Tnnn --backfill PPT` from inside the engagement folder). With a signed file it runs `ingester/bin/s3-write <engagement> Tnnn --backfill PPT`. `check` runs `check-citations` and `check-integrity --proposed` on the file.

Backfill the transcripts in order (T001 before T002), so each one reads the pain points the earlier ones wrote and proposes Confirmed or a merge instead of a duplicate.

## Procedure

### 1. Read

In this order: R26 and R22 in `extraction-rules.md`; the signed session sheet; every file under `pain-points/`; the process and system files this transcript wrote or changed (from its session log); the signed dossier and processes file; then the exchanges file and the utterance table end to end.

### 2. Find the pain points

Apply R26 to every exchange. A pain point is a complaint about how things are today: work that is slow, manual, repeated, error-prone, or dreaded, said by someone who feels it. For each one decide:

- **Already a PPT.** Its citations overlap a promoted or earlier PPT. Propose nothing unless this transcript adds to it. When it does, propose a mutation of that PPT: new citations, a `felt in` link to a system or claim not yet named, Status Confirmed when a second person, or the person whose work it is (R24), agrees, and Impact when the passage says what the pain costs.
- **The same pain as an existing PPT, said again.** A mutation of that PPT as above, not a new one.
- **Two existing PPTs that are one pain.** A Question naming both, for the reviewer to merge by hand. Never merge them in the file.
- **New.** A PPT with Target `new`.

A pain point that threatens delivery is also a risk, as R22 says; if the dossier did not raise one, name it in the Gist and leave the risk to the reviewer. A backfill does not create risks.

### 3. Link

- `felt in` names what the pain is felt in: a process fact (`PRC-nnnn.nN`) when there is one, else a step (`PRC-nnnn.sN`), a process (`PRC-nnnn`), a system fact (`SYS-nnnn.fN`) or a system (`SYS-nnnn`).
- A REQ or DEC already in the register that plainly answers the pain gets a link-only mutation adding `addresses PPT-nnnn` (or `addresses item nn` for a new PPT). Its Gist names the passage that makes the link plain. Nothing else on the REQ or DEC changes.

### 4. Write the backfill file

Write `sessions/Tnnn/Tnnn.backfill-PPT.md` from `ingester/templates/dossier.md`: the same header with the title `# Backfill PPT: Tnnn`, `- Backfill: PPT`, and the dossier's episode headings for the episodes that yield something, in order. Items are F4 blocks numbered from 01. The kinds allowed are PPT, Question, and link-only mutations of REQ, DEC, LIM, RSK or OI (only `Links`, `Title` and `Gist` lines). The write refuses anything else.

A new PPT carries Title, Status (Raised, or Confirmed with Impact), Raised on (the session date), Raised by (the person who said it, from the stakeholder register), Severity when the passage gives it (L, M or H), Affects (the department or segment that feels it) and Links. Build every quote with `ingester/bin/quote`.

Grade every item under the grading conditions. A PPT whose speaker describes another team's pain is Needs a human: standing unclear.

### 5. Self-checks

1. `ingester/bin/stage <engagement> Tnnn backfill PPT check` passes. I25 and I26 are the pain point rules.
2. No new PPT has citations that overlap an existing PPT's Source. If one does, it is a mutation of that PPT instead.
3. Every Question under Closing names the two PPT ids it would merge.

### 6. Accept the Confident items and present

As runbook S1 steps 7 and 8. Copy the file to `sessions/Tnnn/Tnnn.backfill-PPT.draft.md` first. Present only the rulings, or that there are none, and the ask. On proceed, write Completed by and Completed on and run the write.

## Outputs

- `sessions/Tnnn/Tnnn.backfill-PPT.md`, the review file, and its draft copy.
- After the write:
  - new and changed files under `pain-points/`;
  - link-only changes to REQ, DEC, LIM, RSK or OI files, each with a History line;
  - session log rows under `- Backfill PPT completed by:` and `- Backfill PPT written on: <date>, ingester <v>, rules <v>`;
  - `index/pain-points.md` and section 7 of `index/outstanding.md`;
  - a run log with stage `backfill-PPT`.

## After the write

Rerun `ingester/bin/stage <engagement> Tnnn summary`. It measures the backfill on its own window and adds it to `evaluation/Tnnn-summary.md` under PPT backfill, with `ppt_` metrics (runbook summary). Present those figures in one short block.

## Automatic checks

At the write, in order, and the write refuses at the first failure:

1. The transcript's S4 is written and its PPT backfill is not.
2. The file carries Completed by and Completed on, and every verdict is filled under the bulk rule (F5).
3. Every accepted item is a PPT, a Question or a link-only mutation.
4. `check-citations` passes on every accepted item.
5. `check-integrity --proposed` passes on the accepted set merged with the engagement.

A failure after the checks restores every item folder and the session log.

## What the reviewer does

Read each new pain point as the person who feels it would, and ask whether that is their complaint, in their words, felt where the link says. Rule on the items presented. Merge duplicates the Questions name by hand afterwards, with a History line on each file.

## What approval means

Every pain point the transcript carries is in the register once, raised by the person who said it, and linked to where it is felt.

## On rejection

Write `Reject` on the Completed by line and notes under Closing. The skill writes `Tnnn.backfill-PPT.v2.md` and keeps the rejected file.
