# Runbook: backfill

Version 0.4, 2 October 2026.

## Purpose

Add the items of one register type to a transcript that was written before the type existed, without reopening what the reviewer has already signed. Two kinds can be backfilled:

- **PPT**, the pain point (ingester 0.12.0). Transcripts ingested from 0.12.0 onward produce pain points at S1 and S4 and need no PPT backfill.
- **INT**, the integration (ingester 0.14.0). Transcripts ingested from 0.14.0 onward produce integrations at S1 and need no INT backfill.

Each kind is backfilled separately, with its own file, `sessions/Tnnn/Tnnn.backfill-<KIND>.md`, and its own lines in the session log. The two do not depend on each other.

A PPT backfill runs in two passes over an engagement.

1. **Promote.** `ingester/bin/promote-pain-points <engagement>` writes one PPT per process fact of Kind Pain point that no pain point links to yet. It uses no judgement and has no review file. It runs once for the engagement, before any transcript is backfilled.
2. **Backfill by transcript.** The skill reads each written transcript again for pain points only. It proposes the ones promotion could not see: a complaint about a system, recorded as a SYS.fact; one outside any process, dropped or recorded as a risk; a second voice agreeing with one already promoted. The reviewer signs a backfill file, and the write adds only pain points and links.

An INT backfill has only the second pass: system facts carry no integration kind, so nothing can be promoted without reading.

Rerunning S1 would give a different dossier, with the verdicts and hand edits of the signed one lost, so a backfill never does.

## Inputs

- `sessions/Tnnn/Tnnn.utterances.tsv`, the whole of it.
- `sessions/Tnnn/Tnnn.exchanges.md`, for speech acts and exchange outcomes.
- The signed session sheet, for roles, segments and standing.
- The signed dossier and processes file, for episode ids and titles and for what was already recorded from each exchange.
- `ingester/extraction-rules.md`: for PPT, R3, R4, R7, R10, R13, R17, R22, R24 and R26 in particular; for INT, R2, R3, R10, R11, R12, R17 and R27.
- The engagement as it stands: every file under `pain-points/` (for PPT, including those from pass 1) or `integrations/` (for INT), from earlier transcripts too, and `systems/`, `processes/`, `requirements/`, `decisions/`, `limitations/`, `risks/` and `stakeholders/`.

## Command

```
ingester/bin/promote-pain-points <engagement>          pass 1, once per engagement
ingester/bin/stage <engagement> Tnnn backfill PPT      pass 2, per transcript
ingester/bin/stage <engagement> Tnnn backfill PPT check
ingester/bin/stage <engagement> Tnnn backfill INT      per transcript
ingester/bin/stage <engagement> Tnnn backfill INT check
```

`stage ... backfill <KIND>` refuses unless the transcript's S4 is written and its backfill of that kind is not. With no backfill file it says the reading is the skill's (`/ingest-transcript Tnnn --backfill <KIND>` from inside the engagement folder). With a signed file it runs `ingester/bin/s3-write <engagement> Tnnn --backfill <KIND>`. `check` runs `check-citations` and `check-integrity --proposed` on the file.

Backfill the transcripts in order (T001 before T002), so each one reads the items the earlier ones wrote and proposes a mutation or a merge instead of a duplicate.

## Procedure: PPT

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

## Procedure: INT

### 1. Read

In this order: R27, R2 and R11 in `extraction-rules.md`; the signed session sheet; every file under `integrations/`; every file under `systems/`, and first the system facts this transcript wrote or changed (from its session log), because most integrations were recorded there; the signed dossier and processes file; then the exchanges file and the utterance table end to end.

### 2. Find the integrations

Apply R27 to every exchange. An integration is a connection in which one system sends to, calls, reads from or writes to another, with no person in between. For each one decide:

- **Already an INT.** Its citations overlap an earlier INT. Propose nothing unless this transcript adds to it. When it does, propose a mutation of that INT: new citations, a `described in` or `used in` link not yet named, or a field the passage settles (Mechanism, Direction, Data, Frequency).
- **The same integration as an existing INT, said again.** A mutation of that INT as above, not a new one.
- **Two existing INTs that are one integration.** A Question naming both, for the reviewer to merge by hand. Never merge them in the file.
- **New.** An INT with Target `new`: Current when it exists today, Proposed when the speakers commit to it for the design.

A manual transfer between systems, and a statement that two systems do not integrate, are not integrations (R27). The system fact that records them is enough, and a complaint about one belongs to a PPT backfill. An INT backfill does not create system facts, limitations or pain points.

### 3. Link

- `described in` names the system fact that states the integration today (`SYS-nnnn.fN`), else the system (`SYS-nnnn`). Every Current INT has one when the record holds such a fact.
- `used in` names a process step in which one system hands work to the other (`PRC-nnnn.sN`), when the processes file recorded one.
- A REQ or DEC already in the register that plainly calls for the integration gets a link-only mutation adding `specifies INT-nnnn` (or `specifies item nn` for a new INT); one that plainly switches it off gets `retires`. Its Gist names the passage that makes the link plain. Nothing else on the REQ or DEC changes.
- A PPT or LIM already in the register that is felt in, or constrains, the integration may get a link-only mutation adding `felt in` or `constrains` it.

### 4. Write the backfill file

Write `sessions/Tnnn/Tnnn.backfill-INT.md` from `ingester/templates/dossier.md`: the same header with the title `# Backfill INT: Tnnn`, `- Backfill: INT`, and the dossier's episode headings for the episodes that yield something, in order. Items are F4 blocks numbered from 01. The kinds allowed are INT, Question, and link-only mutations of REQ, DEC, LIM, RSK, PPT or OI (only `Links`, `Title` and `Gist` lines). The write refuses anything else.

A new INT carries Title, Status (Current or Proposed), From and To (SYS ids), Direction (One-way or Two-way), Data, Mechanism (API, HTTP, File, Queue, Event, ETL or Database) and Frequency when the passage gives them (blank otherwise, never guessed), Raised on (the session date), Raised by (the person who described it, from the stakeholder register) and Links. Build every quote with `ingester/bin/quote`.

Grade every item under the grading conditions. An INT whose route is hedged, or whose speaker describes another team's system from outside it, is Needs a human.

### 5. Self-checks

1. `ingester/bin/stage <engagement> Tnnn backfill INT check` passes. I27 and I28 are the integration rules.
2. No new INT has citations that overlap an existing INT's Source. If one does, it is a mutation of that INT instead.
3. No INT rests on a passage that describes a person moving data by hand, or says there is no integration.
4. Every Question under Closing names the two INT ids it would merge.

### 6. Accept the Confident items and present

As for PPT, step 6, with `Tnnn.backfill-INT.draft.md` as the draft copy.

## Outputs

- `sessions/Tnnn/Tnnn.backfill-<KIND>.md`, the review file, and its draft copy.
- After the write:
  - new and changed files under `pain-points/` (PPT) or `integrations/` (INT, the folder made if the engagement has none yet);
  - link-only changes to other register items, each with a History line;
  - session log rows under `- Backfill <KIND> completed by:` and `- Backfill <KIND> written on: <date>, ingester <v>, rules <v>`;
  - `index/pain-points.md` and section 7 of `index/outstanding.md` (PPT), or `index/integrations.md` and section 8 (INT);
  - a run log with stage `backfill-<KIND>`.

## After the write

Rerun `ingester/bin/stage <engagement> Tnnn summary`. It measures the backfill on its own window and adds it to `evaluation/Tnnn-summary.md` under PPT backfill with `ppt_` metrics, or INT backfill with `int_` metrics (runbook summary). Present those figures in one short block.

## Automatic checks

At the write, in order, and the write refuses at the first failure:

1. The transcript's S4 is written and its backfill of this kind is not.
2. The file carries Completed by and Completed on, and every verdict is filled under the bulk rule (F5).
3. Every accepted item is of the kind backfilled, a Question or a link-only mutation.
4. `check-citations` passes on every accepted item.
5. `check-integrity --proposed` passes on the accepted set merged with the engagement.

A failure after the checks restores every item folder and the session log.

## What the reviewer does

For PPT, read each new pain point as the person who feels it would, and ask whether that is their complaint, in their words, felt where the link says. For INT, ask whether the two systems really connect that way, with no person in between, and whether the link to the system fact is to the right one. Rule on the items presented. Merge duplicates the Questions name by hand afterwards, with a History line on each file.

## What approval means

For PPT, every pain point the transcript carries is in the register once, raised by the person who said it, and linked to where it is felt. For INT, every integration the transcript describes is in the register once, raised by the person who described it, and linked to the system fact that states it or the REQ or DEC that specifies it.

## On rejection

Write `Reject` on the Completed by line and notes under Closing. The skill writes `Tnnn.backfill-<KIND>.v2.md` and keeps the rejected file.
