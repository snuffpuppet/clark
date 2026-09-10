# Handoff

10 September 2026. Written at the end of the approval session. The next session builds the ingester.

## Where things stand

The design `ingester/extraction-solution-design.md` is at version 1.2 and approved for implementation. The register model `ingester/solution-register-model.md` is at 2.16 with the design's section 9 changes applied. Adam's colleague has the design for review through a shared page; any comments from that review are folded in as 1.3 before or during the build, without stopping it. Nothing has been implemented.

## Files in this repository

| File | What it is |
|---|---|
| `BRIEF.md` | The brief, version 1.0. |
| `ingester/extraction-solution-design.md` | The design, version 1.2. Read this first, in full. Section 7 gives the layout and runtime, 5.6 the rules, 10.1 every file to be created. |
| `ingester/solution-register-model.md` | Register model, version 2.16. Section 7 gives the register columns, section 9 the integrity rules I1 to I19. |
| `engagements/puppy-gloves/transcripts/unprocessed/T001-SANITISED-TechnicalSyncUp.vtt` | The first transcript, a vendor technical sync-up, seven speakers, about 67 minutes. |
| `.claude/skills/ingest-transcript/SKILL.md` | A placeholder from the skill discovery test. Replace it with the real skill. |

## Decisions that shape the build

- Runtime is a Claude Code session started inside the engagement folder, `engagements/<name>/`, which names the engagement. The command is `/ingest-transcript <vtt-file> ["meeting subject"]` on first invocation and `/ingest-transcript <Tnnn>` after that. The skill lives at the root under `.claude/skills/` with no symlink and is found from the subfolder (tested 10 September 2026). Reads into `ingester/` need a grant from a subfolder: start with `claude --add-dir ../../ingester` or approve the prompt once.
- The root `CLAUDE.md` points at `ingester/README.md`. The ingester knows its own files. Engagement folders carry nothing about the ingester.
- The transcript file is copied unchanged into `transcripts/unprocessed/`, its name and SHA-256 recorded in the transcript register, and moved to `transcripts/processed/` by S3 as its last step. Nothing edits, renames or deletes a transcript.
- The meeting subject is a guide to episodes and topics, never a filter.
- Decision authority sits with people and subjects on the stakeholder register (Decides field, Forum role, rule R19). There is no session-level forum flag.
- Shell does only deterministic work: awk, sed, grep, shasum. No Docker, no API key, nothing installed on the host.
- Two human stops per transcript: the session sheet after S0 and the dossier after S1. Nothing is written without a signed file.
- T001 session date is 8 September 2026, to be confirmed on the session sheet. The domain for T001 is set at S0.

## Git

Adam pushes. Claude commits locally and never pushes. At the end of this session main is ahead of origin by the commits listed by `git log origin/main..main`.

## Build order

1. Root `CLAUDE.md`, `ingester/README.md`, `ingester/VERSION` at 0.1.0.
2. Templates in `ingester/templates/`: engagement.md, stakeholders.md, transcripts.md, session sheet, dossier, the six registers with the 2.16 columns, current-state record, topic ledger, session log, run report, reference marking.
3. `ingester/bin/s0-prepare`: VTT to `Tnnn.utterances.tsv`, speaker list matched against the stakeholder register, session sheet from the template. `ingester/bin/check-citations`: the citation checker from design Q2. Test both on T001.
4. `ingester/extraction-rules.md` version 1: rules R1 to R19 and the grading conditions from Q3, each with a slot for test passages.
5. The skill `SKILL.md`: argument handling, the copy into unprocessed, gate detection, S0 and S1 behaviour following the runbooks, self-checks before the dossier is presented.
6. `ingester/bin/check-integrity` for I1 to I19 and `ingester/bin/s3-write`: gates, appends, version bumps, session log, move to processed. `ingester/bin/stage` as the driver.
7. Runbooks S0 to S3, staged-review and evaluate.
8. `ingester/bin/score` and the reference marking template.
9. Create `engagements/puppy-gloves/` from the templates: engagement.md, an empty stakeholders.md, empty registers, empty topic ledger.
10. Run S0 on T001 and stop for Adam's session sheet. Adam hand-marks T001 as the first reference. Then the first S1 run and run report.

## Working conventions

Australian English. No em dashes. No rhyming patterns of three, and frame positively rather than as "not x but y". Every document carries a version and date and is bumped on change. The execution guardrail in Adam's global CLAUDE.md applies.

## Prompt for the next session

Paste this to start:

> Read HANDOFF.md, then read ingester/extraction-solution-design.md and ingester/solution-register-model.md in full. Write the implementation plan for the ingester as `ingester/IMPLEMENTATION-PLAN.md`, following the build order in the handoff and the file list in design section 10.1, with a verification step for each item that can be run on T001. Show me the plan before building. Once I approve it, build it in order, committing after each numbered step, testing every shell script against T001, and stop when S0 has run on T001 and the session sheet is waiting for me. Commit locally only; I push.
