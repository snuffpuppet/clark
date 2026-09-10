# Handoff

10 September 2026, end of the build session. The ingester is built and the first real run of the skill is the next thing that happens.

## Where things stand

The ingester is at 0.5.1, the register model at 2.19, the design at 1.6, the extraction rules at 1.1. Everything in the build plan (`ingester/IMPLEMENTATION-PLAN.md`, version 0.5, including addendum A) is built, tested against T001 on scratch copies, and committed locally. Main is ahead of origin by the commits listed by `git log origin/main..main`; Adam pushes.

The engagement `engagements/puppy-gloves/` exists in its final shape and is reset to the unregistered state: the VTT sits in `transcripts/unprocessed/`, no transcript is registered, every item folder is empty. This is deliberate. An S0 run made during the build was cleared so that the skill's first run is a complete test from the start.

Adam's colleague reviewed the design; the comments and Adam's own review were folded in during the session (see the change logs in the model and the design, and `ingester/design-review-notes.md`).

## Files in this repository

| File | What it is |
|---|---|
| `BRIEF.md` | The brief, version 1.0. |
| `CLAUDE.md` | Root pointer to the ingester. |
| `.claude/skills/ingest-transcript/SKILL.md` | The ingest skill, versioned with the ingester. The method, as a prompt. |
| `ingester/README.md` | What the ingester is, every script, every format. Read first. |
| `ingester/extraction-solution-design.md` | The design, 1.6. Sections 4, 5.6, 7 and 10.1 matter most. |
| `ingester/solution-register-model.md` | The register model, 2.19. Section 7 is one file per item; section 9 the integrity rules. |
| `ingester/extraction-rules.md` | Rules R1 to R19 and the grading conditions, 1.1, with seeded test passages. |
| `ingester/IMPLEMENTATION-PLAN.md` | The build plan and addendum A. Historical now, but it fixes the formats. |
| `ingester/design-review-notes.md` | Decisions made on review and things the design should say in its next version. |
| `ingester/bin/` | Twelve shell scripts (awk, sed, grep, shasum, date only). |
| `ingester/runbooks/` | S0 to S3, staged review, evaluate. |
| `ingester/templates/` | Session sheet, dossier, reference, run report, session log, engagement.md, CLAUDE.md, LOG.md, and `items/` with one template per item type. |
| `engagements/puppy-gloves/` | The first engagement. Its `CLAUDE.md` says how to start a session there; its `LOG.md` is the running history. |

## Decisions that shape the build

- **Runtime.** A Claude Code session started inside the engagement folder, `engagements/<name>/`, which is how the engagement is known. Start with `claude --add-dir ../../ingester` so reads into the ingester need no prompt. The skill lives at the repository root under `.claude/skills/` and is found from the subfolder.
- **Command.** `/ingest-transcript <vtt-file> ["meeting subject"]` the first time, `/ingest-transcript Tnnn` after that. The subject is a prior for episode and topic reading, never a filter.
- **One file per item.** Every requirement, decision, limitation, risk, open item, process, system, stakeholder, topic and transcript is one markdown file with YAML frontmatter, named by a four-digit id (`REQ-0004`). Claims are sections in their process or system file (`SYS-0002.f1`). Generated tables under `index/` are the meeting view and are never edited. Transcript and episode ids stay three digits.
- **No change requests, no Scope.** Both removed from the model on review. Phases are named in `engagement.md` under Phases, in order, current marked; a requirement's phase must be one of them (I5).
- **Stakeholders** carry Segment (Residential, BE&G, Wholesale, or blank meaning the whole business) and Department. Both are stakeholder fields only for now; no rule reads them yet.
- **Stakeholder files are written the moment the session sheet is signed**, as the first act of S1, so the register is current for S1 and for any second transcript. Item files are written only by S3 after both signatures.
- **Two human stops per transcript**: the session sheet after S0 and the dossier after S1. Nothing is written without a signed file; a blank verdict is pending and blocks. A signed file is never edited and a sheet is never regenerated once signed.
- **The write stage is transactional.** Every gate runs again before writing; a failure part-way restores every folder, the transcript file, `engagement.md` and the session log.
- **Progress** is shown two ways: the skill maintains the Claude Code task list from `stage <eng> Tnnn tasks`, and every stage call writes `sessions/Tnnn/TASKS.md`.
- **Shell does only deterministic work.** No Docker, no API key, nothing installed on the host.
- **T001 session date** is 8 September 2026, to be confirmed on the session sheet. Domain and phases are set at S0; the phases list in `engagement.md` carries placeholders (Day one, Later phase) that Adam renames.

## Git

Adam pushes. Claude commits locally and never pushes.

## What happens next

1. Adam starts a session in `engagements/puppy-gloves/` and runs `/ingest-transcript transcripts/unprocessed/T001-SANITISED-TechnicalSyncUp.vtt "entity upgrade for multi-gig orders"` (the subject is optional). This is the first time the skill runs as a prompt; every stage has been tested by running the scripts and by Claude standing in for the skill on S0, so the things to watch are whether it reads the ingester without fuss, whether its proposals are sound and every citation passes the checker, and whether it stops at the gate.
2. Adam signs the session sheet (every verdict, date, domain, name and date in the header), renames the phases in `engagement.md`, and optionally hand-marks `evaluation/T001-reference.md` from `ingester/templates/reference.md`.
3. `/ingest-transcript T001` runs S1 and stops with the dossier. Adam reviews and signs. The same command runs S3.
4. Score the drafted dossier against the reference (`../../ingester/bin/stage puppy-gloves T001 score evaluation/T001-reference.md sessions/T001/T001.dossier.draft.md`, after copying the dossier aside before review), tag the failure modes in the run report, and fold them into `extraction-rules.md` as 1.2.

## Open questions

- Whether the register model should carry a summary of the process and system elements so a reader of the model alone can see them (they are defined in design section 4).
- Whether Segment and Department should start feeding a rule (for example, a BE&G SME's "our process" is the BE&G process). Wait for evidence from a session where it matters.
- Design 1.6 has been kept in step with every change by section edits and change-log rows. A read-through for coherence, especially sections 5.5, 7 and 10, would be worth an hour before the next design revision.

## Working conventions

Australian English. No em dashes. No rhyming patterns of three, and frame positively rather than as "not x but y". Every document carries a version and date and is bumped on change; item files carry `updated:` and rely on git for history. The execution guardrail in Adam's global CLAUDE.md applies.

## Prompt for the next session

Paste this to start, from `engagements/puppy-gloves/` with `claude --add-dir ../../ingester`:

> /ingest-transcript transcripts/unprocessed/T001-SANITISED-TechnicalSyncUp.vtt "entity upgrade for multi-gig orders"
