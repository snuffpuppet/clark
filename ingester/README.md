# The ingester

Version 0.1, 10 September 2026. Owner: Adam Moyes. Implements `extraction-solution-design.md` 1.2 against `solution-register-model.md` 2.16. Built to `IMPLEMENTATION-PLAN.md` 0.1.

## Purpose

The ingester turns a discovery transcript (WebVTT from Teams or Webex) into rows in the six solution registers, claims in a current-state record, entries in a topic ledger and rows in a stakeholder register, with a human signing two review files before anything is written. All judgement is done by Claude Code running the `ingest-transcript` skill. Shell scripts do only deterministic work: flattening the VTT, checking citations, running integrity rules, writing approved items, bumping versions and scoring a run against a reference.

## Layout

| Path | Purpose |
|---|---|
| `../.claude/skills/ingest-transcript/SKILL.md` | The skill. Lives at the repository root so Claude Code finds it. Part of the ingester. |
| `README.md` | This file. |
| `VERSION` | Version of the mechanism as a whole. Bumped on any change to the skill, scripts, runbooks or templates. |
| `extraction-solution-design.md` | The design. |
| `solution-register-model.md` | The register model. |
| `extraction-rules.md` | Rules R1 to R19 and the grading conditions, with test passages. Carries its own version. |
| `IMPLEMENTATION-PLAN.md` | The build plan, with the formats the scripts agree on. |
| `bin/` | Shell scripts, listed under Scripts. |
| `runbooks/` | `S0.md` to `S3.md`, `staged-review.md`, `evaluate.md`. |
| `templates/` | Every engagement file in empty form. |

An engagement lives at `engagements/<name>/` with `engagement.md`, `stakeholders.md`, `transcripts.md`, `topics.md`, `current-state-<domain>.md`, `registers/` (six files), `transcripts/unprocessed/` and `transcripts/processed/`, `sessions/Tnnn/`, `evaluation/` and `logs/`. Design section 7.1 gives the full tree.

## Runtime

A Claude Code session started at the repository root. The skill takes the engagement name as an argument and resolves both parts by relative path. Nothing is installed on the host and Docker is not needed because Claude Code is already present.

## Command

First invocation for a transcript:

```
/ingest-transcript <path-to-vtt> <engagement> ["meeting subject"]
```

The file is copied unchanged into `engagements/<engagement>/transcripts/unprocessed/`, its name and SHA-256 recorded in `transcripts.md` against a new id, and S0 runs. Later invocations name the id:

```
/ingest-transcript T001 <engagement>
```

The skill finds the next unsigned gate and acts on it, or says which file is waiting and stops.

## Stages

| Stage | Done by | Input | Output | Gate to the next |
|---|---|---|---|---|
| S0 Prepare | `bin/s0-prepare`, then the skill proposes roles | VTT, stakeholder register | `Tnnn.utterances.tsv`, `Tnnn.session.md` | Session sheet signed, every verdict filled |
| S1 Read | The skill | Utterance table, signed sheet, rules, the engagement's records | `Tnnn.exchanges.md`, `Tnnn.episodes.md`, `Tnnn.dossier.md` | Dossier signed, every verdict filled |
| S2 Review | The human | Dossier | Dossier with verdicts | As above |
| S3 Write | `bin/s3-write` | Both signed files | Registers, record, ledger, stakeholders, session log; VTT moved to `processed/` | None |
| Evaluate | `bin/score`, then the human tags | Dossier and reference | `evaluation/Tnnn-run-nn.md` | None |

## Formats

These are the shapes every script and the skill agree on. `IMPLEMENTATION-PLAN.md` section "Formats fixed by this plan" is the authority; this is the short form.

- **F1 Utterance table.** TSV, header `utterance fragment start end speaker text`, one row per cue, whitespace collapsed, sorted by utterance then fragment numerically.
- **F2 Citation.** `<label> | Tnnn/<utt>:<frag>[-<frag>][, ...] | <speaker> | <hh:mm:ss> | "<quote>"`. Labels: asked, answered, proposed, restated, accepted, challenged, deferred, hedged. Timestamp is the start of the first cited fragment cut to seconds. Quote is verbatim; `...` skips words inside the range. In a table cell `|` is written `\|` and citations are separated by `; `.
- **F3 Tables.** Every register, the stakeholder register, the transcript register and the topic ledger is one markdown table under a title and a version line. First column is the id.
- **F4 Item block.** `### Item n | <kind> | <grade>` followed by `- Field: value` lines, a `- Citations:` list and a `- Gist:` line. Kinds: PRC, PRC.step, SYS, SYS.fact, REQ, DEC, LIM, RSK, OI, CR, Question, STK.edit, TOP. `- Target:` is `new` or an existing id. `- Verdict:` is blank, Accept, Edit or Reject.
- **F5 Gate.** A file is signed when `- Approver:` and `- Approved on:` are filled, no `- Verdict:` is blank, and no session sheet table row has an empty last cell.
- **F6 Current-state record.** One `## SYS-nnn <name>` or `## PRC-nnn <title>` section per element with a field list, a claims table, a questions list and the marker `<!-- end SYS-nnn -->`.
- **F7 Scope taxonomy.** Bullets under `## Scope taxonomy` in `engagement.md`.
- **F8 Session log.** `sessions/Tnnn/Tnnn.session-log.md`, one row per id created or changed.
- **F9 Run log.** `logs/<UTC timestamp>-<Tnnn>-<stage>.md`, append only.

Every document's second line is `Version X.Y, D Month YYYY.` and is bumped by the scripts or by hand on change.

## Scripts

All in `bin/`, POSIX sh with awk, sed, grep, shasum and date. `ENGAGEMENTS_ROOT` defaults to `engagements` and exists so that tests can point at a scratch folder.

| Script | Usage | What it does |
|---|---|---|
| `new-engagement` | `new-engagement <name>` | Creates an engagement folder from the templates. |
| `register-transcript` | `register-transcript <engagement> <vtt> ["subject"]` | Copies the file into `unprocessed/` unless already there, records name and SHA-256, assigns the next Tnnn, prints it. |
| `s0-prepare` | `s0-prepare <engagement> <Tnnn>` | Verifies the SHA, writes the utterance table and the session sheet with speakers matched against the stakeholder register. |
| `check-citations` | `check-citations <engagement> <Tnnn> <file>` | Checks every F2 citation in a file against the utterance table. Exit 1 on any failure. |
| `check-integrity` | `check-integrity <engagement> [--proposed <dossier>]` | Runs I1 to I19 over the engagement, optionally merged with the accepted items of a dossier. |
| `dossier2tsv` | `dossier2tsv <file>` | Flattens F4 item blocks to one TSV row per item. |
| `s3-write` | `s3-write <engagement> <Tnnn>` | Checks every gate, writes accepted items, bumps versions, writes the session log, moves the VTT to `processed/`. |
| `score` | `score <engagement> <Tnnn> <reference> [<dossier>]` | Writes `evaluation/Tnnn-run-nn.md` with the counts from design Q4. |
| `stage` | `stage <engagement> <Tnnn> <status\|S0\|S1\|S3\|check\|score>` | Driver. Reports the state, runs a stage, refuses a stage whose predecessor is unsigned, writes a run log. |

## Versioning

`VERSION` is the ingester. `extraction-rules.md` carries its own version because it changes with every evaluation loop. Every session log and run report records both, so a row in a register can always be traced to the mechanism that produced it. Rule changes are made by hand as a versioned change to the ingester; nothing under `ingester/` is written during ingestion.
