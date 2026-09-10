# Runbook: staged review

Version 0.1, 10 September 2026.

## Purpose

The slower path from design Q3. The skill stops three times inside S1 instead of once at the end, for an engagement or a transcript where the reviewer wants to steer the reading. The files are the same; only the number of stops changes.

## Inputs

As S1, plus `- Review path: staged` on the signed session sheet.

## Command

`/ingest-transcript Tnnn <engagement>`, three times. Each invocation finds the last stop and continues from it.

## Outputs

- Stop 1: `Tnnn.exchanges.md` and `Tnnn.episodes.md`. The reviewer confirms episode boundaries, titles, outcomes and topic matches by editing `Tnnn.episodes.md` and adding `- Confirmed by: <name>, <date>` at the top.
- Stop 2: `Tnnn.dossier.md` containing only current-state claims (SYS, SYS.fact, PRC, PRC.step) and Questions. The reviewer gives verdicts on those and writes `- Stage 2 confirmed by: <name>, <date>` in the header.
- Stop 3: the dossier completed with register rows, links, TOP and STK.edit items. Review continues as S2.

## Automatic checks

As S1 at each stop, on what exists so far.

## What the reviewer does

At each stop, edit and confirm as above. Items confirmed at stop 2 are not re-graded at stop 3.

## What approval means

The dossier's final header signature, as S2. The intermediate confirmations gate the next stop only.

## On rejection

Edit the working file and remove the confirmation line; the skill reworks from that stop.
