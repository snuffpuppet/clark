# The ingester

Version 0.11, 18 September 2026.

## Purpose

The ingester turns a discovery transcript (WebVTT from Teams or Webex) into rows in the six solution registers, claims in a current-state record, entries in a topic ledger and rows in a stakeholder register, with a human signing two review files before anything is written. All judgement is done by Claude Code running the `ingest-transcript` skill. Shell scripts do only deterministic work: flattening the VTT, checking citations, running integrity rules, writing approved items, bumping versions and scoring a run against a reference.

## Layout

| Path | Purpose |
|---|---|
| `../.claude/skills/ingest-transcript/SKILL.md` | The skill. Lives at the repository root so Claude Code finds it. Part of the ingester. Holds only how Claude operates the stages; the procedure itself is in `runbooks/`. |
| `README.md` | This file. |
| `VERSION` | Version of the mechanism as a whole. Bumped on any change to the skill, scripts, runbooks or templates. |
| `extraction-solution-design.md` | The design. |
| `solution-register-model.md` | The register model. |
| `extraction-rules.md` | Rules R1 to R19 and the grading conditions, with test passages. Carries its own version. |
| `IMPLEMENTATION-PLAN.md` | The build plan, with the formats the scripts agree on. |
| `mutation-design.md` | Design note for mutating existing items from a follow-up transcript (ingester 0.6.0, F10). |
| `bin/` | Shell scripts, listed under Scripts. |
| `runbooks/` | `S0.md` to `S3.md`, `staged-review.md`, `evaluate.md`. The source of truth for what each stage reads, produces, checks and reports; the skill file operates them and does not restate them. |
| `templates/` | Every engagement file in empty form. |

An engagement lives at `engagements/<name>/` with `engagement.md`, one file per item under `requirements/`, `decisions/`, `limitations/`, `risks/` and `open-items/`, one file per element under `processes/` and `systems/` (claims as sections), one file per person under `stakeholders/`, one file per topic under `topics/`, one file per transcript under `transcripts/` beside `transcripts/unprocessed/` and `transcripts/processed/`, generated tables under `index/`, and `sessions/Tnnn/`, `evaluation/` and `logs/`. Design section 7.1 gives the full tree.

## Runtime

A Claude Code session started inside the engagement folder, `engagements/<name>/`, which is how the skill knows the engagement. The skill finds the repository root with `git rev-parse --show-toplevel` and calls the scripts from there. Reads into `ingester/` fall outside the working directory, so start the session with `claude --add-dir ../../ingester` or approve the read prompt once. The skill file lives at the root under `.claude/skills/` and is found from the subfolder. Nothing is installed on the host and Docker is not needed because Claude Code is already present.

## Command

First invocation for a transcript:

```
/ingest-transcript <path-to-vtt> ["meeting subject"]
```

The file is copied unchanged into `engagements/<engagement>/transcripts/unprocessed/`, its name and SHA-256 recorded in `transcripts.md` against a new id, and S0 runs. Later invocations name the id:

```
/ingest-transcript T001
```

Run from inside `engagements/<name>/`. The scripts take the engagement name as their first argument and can be run from anywhere.

The skill finds the next unsigned gate and acts on it, or says which file is waiting and stops.

## Stages

| Stage | Done by | Input | Output | Gate to the next |
|---|---|---|---|---|
| S0 Prepare | `bin/s0-prepare`, then the skill proposes roles | VTT, stakeholder register | `Tnnn.utterances.tsv`, `Tnnn.session.md` | Session sheet signed, every verdict filled |
| S1 Read | `bin/s1-stakeholders` writes the accepted stakeholder rows, then the skill reads | Utterance table, signed sheet, rules, the engagement's records | `Tnnn.exchanges.md`, `Tnnn.episodes.md`, `Tnnn.dossier.md` | Dossier signed, every verdict filled |
| S2 Review | The human | Dossier | Dossier with verdicts | As above |
| S3 Write | `bin/s3-write` | Both signed files | Registers, record, ledger, stakeholder edits, History lines on changed items, session log; VTT moved to `processed/` | None |
| Evaluate | `bin/score`, then the human tags | Dossier and reference | `evaluation/Tnnn-run-nn.md` | None |

## Formats

These are the shapes every script and the skill agree on. `IMPLEMENTATION-PLAN.md` section "Formats fixed by this plan" is the authority; this is the short form.

- **F1 Utterance table.** TSV, header `utterance fragment start end speaker text`, one row per cue, whitespace collapsed, sorted by utterance then fragment numerically.
- **F2 Citation.** `<label> | Tnnn/<utt>:<frag>[-<frag>][, ...] | <speaker> | <hh:mm:ss> | "<quote>"`. Labels: asked, answered, proposed, restated, accepted, challenged, deferred, hedged, aside. Timestamp is the start of the first cited fragment cut to seconds. Quote is verbatim; `...` skips words inside the range. In a table cell `|` is written `\|` and citations are separated by `; `.

  The label is not the speech act name the exchanges file uses. `ask`/`asked`, `assert`/**`answered`**, `propose`/`proposed`, `restate`/`restated`, `accept`/`accepted`, `challenge`/`challenged`, `defer`/`deferred`, `hedge`/`hedged`, `aside`/`aside`. `assert` becoming `answered` is the one that catches people. Build the quote with `bin/quote` rather than retyping it: it parses the range the way `check-citations` does, so the quote cannot run past the range it cites.
- **F3 Item files.** One markdown file per item, named by its id (`REQ-0004.md`), with YAML frontmatter for short fields (kebab-case keys, lists as `  - ` items) and fixed body headings for long ones (Source, Rationale, Impact, Options, Trigger, Mitigation, Raised by, Next action, Notes). Ids are four digits; transcripts are `T001`.
- **F4 Item block.** `### Item n | <kind> | <grade>` followed by `- Field: value` lines, a `- Citations:` list and a `- Gist:` line. Kinds: PRC, PRC.step, SYS, SYS.fact, REQ, DEC, LIM, RSK, OI, CR, Question, STK.edit, TOP. `- Target:` is `new` or an existing id. With an existing id the block is a mutation: it carries only the fields that change, as they should read afterwards, and its Gist says `Field: old to new` for each. An `STK.edit` is always a mutation: its Target is the existing `STK-nnnn` of the person whose standing changed, never `new`, because a standing extension extends a stakeholder the register already holds (R18). `check-integrity` rule I20 refuses anything else. `- Verdict:` is blank, Accept, Edit or Reject, and nothing else; a verdict outside that list is refused by the gate, because the write stage merges only Accept and Edit and free text would be dropped in silence.
- **F5 Gate.** A file is signed when `- Approver:` and `- Approved on:` are filled, no `- Verdict:` is blank, and no session sheet table row has an empty last cell.
- **F6 Claims.** A system or process file holds its claims as sections `## f1 <description>` or `## s1 <description>`, each with `- key: value` lines (kind, status, confidence, asserted-by, episode, session, evidence list). Claim ids are `SYS-0002.f1`. Sections are never renumbered or removed.
- **F7 Index tables.** `index/*.md` are rendered from the item files by `bin/render-index` after every S3 and on request; never edited. `index/changes.md` lists every History line and claim history entry across the register.
- **F8 Session log.** `sessions/Tnnn/Tnnn.session-log.md`, one row per id created or changed.
- **F9 Run log.** `logs/<UTC timestamp>-<Tnnn>-<stage>.md`, append only.
- **F10 History line.** The last section of every register item file is `## History`, one line per change: `- <D Month YYYY> | <Tnnn item nn, or a person's name for a hand edit> | <Field>: <old> to <new>; ... | <F2 citations, or blank>`. A blank old value is written `blank`. A claim carries the same as `- history:` list entries under its section, and its new evidence joins `- evidence:`. The session log row for the id repeats the change summary.

Documents (README, rules, runbooks, engagement.md, session sheet, dossier) carry `Version X.Y, D Month YYYY.` near the top and are bumped on change. Item files carry `updated:` and a History section (F10) instead; git is the backup, not the record.

## Scripts

All in `bin/`, POSIX sh with awk, sed, grep, shasum and date. `ENGAGEMENTS_ROOT` defaults to `engagements` and exists so that tests can point at a scratch folder.

| Script | Usage | What it does |
|---|---|---|
| `new-engagement` | `new-engagement <name>` | Creates an engagement folder from the templates. |
| `register-transcript` | `register-transcript <engagement> <vtt> ["subject"]` | Copies the file into `unprocessed/` unless already there, writes `transcripts/Tnnn.md` with name and SHA-256, prints the id. |
| `s0-prepare` | `s0-prepare <engagement> <Tnnn>` | Verifies the SHA, writes the utterance table and the session sheet with speakers matched against the stakeholder register. |
| `s1-stakeholders` | `s1-stakeholders <engagement> <Tnnn>` | Runs when the signed session sheet opens the S1 gate. Writes one `stakeholders/STK-nnnn.md` per accepted row, extends `sessions` on attendees, starts the session log. Once per transcript. |
| `check-citations` | `check-citations <engagement> <Tnnn> <file>` | Checks every F2 citation in a file against the utterance table. Exit 1 on any failure. |
| `check-integrity` | `check-integrity <engagement> [--proposed <dossier>]` | Runs the model's integrity rules over the item files, optionally merged with the accepted items of a dossier: new items as new rows, mutations overlaid on the rows they target. Refuses a mutation of a missing id, a reopened open item or a changed Accepted decision. |
| `dossier2tsv` | `dossier2tsv [-e] <file>` | Flattens F4 item blocks to one TSV row per item, or with `-e` one row per episode. |
| `dossier2episodes` | `dossier2episodes <dossier> [<out>]` | Writes `Tnnn.episodes.md` from the dossier's episode headings and item numbers, so the two cannot disagree. Preserves a `- Confirmed by:` line. |
| `quote` | `quote <engagement> <Tnnn> <utt>:<lo>[-<hi>][, ...]` | Prints `speaker \| timestamp \| text` for a citation range, to copy the quote from rather than retype it. Refuses a range spanning two speakers (R10). |
| `s3-write` | `s3-write <engagement> <Tnnn>` | Checks every gate, writes one file per accepted new item, applies each mutation to its existing file with a History line, appends claims, extends topics, completes the transcript file, writes the session log, renders the index, moves the VTT to `processed/`. Restores everything on failure. |
| `render-index` | `render-index <engagement>` | Regenerates the tables under `index/`, including `outstanding.md` and `changes.md`. |
| `score` | `score <engagement> <Tnnn> <reference> [<dossier>]` | Writes `evaluation/Tnnn-run-nn.md` with the counts from design Q4. |
| `stage` | `stage <engagement> <Tnnn> <status\|tasks\|S0\|S1\|S3\|check\|score>` | Driver. Reports the state, runs a stage, refuses a stage whose predecessor is unsigned, writes a run log. |
| `tasks` | `tasks <engagement> <Tnnn>` | Prints the ingestion checklist for one transcript with each step marked from the files on disk, and writes `sessions/Tnnn/TASKS.md`. Also `stage <engagement> <Tnnn> tasks`. |

## Versioning

`VERSION` is the ingester. `extraction-rules.md` carries its own version because it changes with every evaluation loop. Every session log and run report records both, so a row in a register can always be traced to the mechanism that produced it. Rule changes are made by hand as a versioned change to the ingester; nothing under `ingester/` is written during ingestion.
