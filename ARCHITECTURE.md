# Architecture

Version 0.1, 14 September 2026.

Decisions about the shape of this repository that are not derivable from the files themselves. Read before changing where something lives or which document says what.

## Two independent parts

`ingester/` is the mechanism. `engagements/<name>/` is what the mechanism produces for one client, and says nothing about how ingestion works. Nothing under `engagements/` is read to learn the method, and nothing under `ingester/` is written by a run.

## Which document owns what

Each fact about the mechanism has one home. Other documents point at it and do not restate it.

| Question | Owner |
|---|---|
| What the register looks like | `ingester/solution-register-model.md` |
| Why the mechanism is shaped as it is | `ingester/extraction-solution-design.md` |
| How an utterance becomes an item, and how it is graded (R1 to R19) | `ingester/extraction-rules.md` |
| The file formats the scripts parse (F1 to F10) | `ingester/IMPLEMENTATION-PLAN.md`, short form in `ingester/README.md` |
| What each stage reads, produces, checks and reports | `ingester/runbooks/` |
| How Claude Code operates the stages in a session | `.claude/skills/ingest-transcript/SKILL.md` |
| The empty form of every engagement file | `ingester/templates/` |

## Runbooks are the source of truth for the stages

Decided 14 September 2026, after the skill file had grown to restate every stage at greater length than the runbook, so that the two drifted and the drift ran towards the file that was not declared the truth.

The runbooks under `ingester/runbooks/` are the contract for each stage: purpose, inputs, command, procedure, outputs, automatic checks, what the reviewer does, what approval means, what rejection means. A person following a runbook by hand and the skill following it in a session produce the same files.

The skill file holds only what is specific to Claude Code running the mechanism: where the session runs, the rules it never breaks, how it shows progress, how it reads the current stage, and how it takes verdicts in the terminal. At each stage it names the runbook section to follow. It does not restate the procedure.

**How to apply.** A change to what a stage does is made in the runbook, and its version line is bumped. The skill file changes only when how Claude operates the stage changes. If the skill file ever contains a numbered procedure for a stage, that is the drift returning: move the procedure into the runbook and replace it with a reference. When the two disagree, the runbook wins and the skill file is corrected.

## Versioning

`ingester/VERSION` is the version of the mechanism as a whole and is bumped on any change to the skill, scripts, runbooks or templates. Each document carries its own `Version X.Y, D Month YYYY.` line near the top. Item files in an engagement carry `updated:` and a History section instead; git is the backup, not the record.
