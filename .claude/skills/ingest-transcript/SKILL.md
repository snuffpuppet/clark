---
name: ingest-transcript
description: Ingest a discovery transcript (WebVTT) through stages S0 to S4, stopping at each signed gate. Usage /ingest-transcript <vtt-file|Tnnn> ["meeting subject"], run from inside an engagement folder (engagements/<name>/), which is how the engagement is known.
---

# ingest-transcript

Version 0.10.1 (with the ingester; see `ingester/VERSION`). You are the judgement half of the ingester described in `ingester/README.md` and `ingester/extraction-solution-design.md`. Shell scripts under `$ROOT/ingester/bin/` do every deterministic step; you do the reading.

**The runbooks under `ingester/runbooks/` are the source of truth for what each stage reads, produces, checks and reports.** This file says only how you, in a Claude Code session, operate them: where you run, what you never do, how you show progress, how you find the current stage, and how you take verdicts in the terminal. When this file and a runbook disagree, the runbook wins and this file is wrong.

## Where you run

The session is started inside an engagement folder, `engagements/<name>/`, and that folder is the engagement. Before anything else:

```
ENG=$(pwd)
ROOT=$(cd "$ENG/../.." && pwd)
```

The root is two levels above the engagement folder, never `git rev-parse --show-toplevel`: `engagements/` is its own git repository, so from inside an engagement folder git names `engagements/` as the top level and every `$ROOT/ingester/...` path misses. `ENG` must be `$ROOT/engagements/<name>`, must contain `engagement.md`, and `$ROOT/ingester/VERSION` must exist. If it is not (the session was started at the root or somewhere else), say so in one line, name the folder to start from, and stop. Never pick an engagement by guessing. Every script is called as `$ROOT/ingester/bin/<script> <name> ...`, where `<name>` is the folder's basename; the scripts resolve every path from the root themselves. The runbooks write paths relative to the engagement folder (`sessions/Tnnn/...`), which is `ENG`. Reads into `$ROOT/ingester/` are outside the working directory; the session grants them with `claude --add-dir ../../ingester` (or by approving the prompt once).

## Arguments

`$ARGUMENTS` is `<first> ["meeting subject"]`.

- `<first>` is either a path to a `.vtt` file (first invocation for a transcript) or a transcript id `Tnnn` (every later invocation).
- The optional meeting subject is a quoted phrase, for example "entity upgrade for multi-gig orders" or the title of the calendar invitation. It is recorded on the transcript file and the session sheet and read as a prior at S1 (runbook S1). It is never a filter (design 5.3).

## Rules you never break

- Nothing is written to an item file (requirements/, decisions/, limitations/, risks/, open-items/, processes/, systems/, topics/) except by `$ROOT/ingester/bin/s3-write`, only after both review files are signed with no pending verdicts, and by `$ROOT/ingester/bin/s4-write`, only after the processes file is signed. Stakeholder files are written by `$ROOT/ingester/bin/s1-stakeholders` once the session sheet is signed. Silence is not approval.
- Never edit a signed file. Never advance past an unsigned gate: say which file is waiting and stop.
- Never edit, rename or delete a transcript file. A SHA-256 mismatch reported by any script blocks everything; report it and stop.
- Write nothing under `ingester/`. Every output goes under `ENG/`.
- Quotes are verbatim, including transcription noise and filler. Interpretation goes in the Gist. A quote never spans two speakers (R10).
- When in doubt between Confident and Needs a human, choose Needs a human and give the reason (R16).
- Never fill a register field you cannot support from the transcript. Write a Question instead. Owner and MoSCoW are the exception and are always proposed, never left blank, with the Gist saying the value is a proposal: the integrity gate fails a blank one at S3, and R17 makes a wrong one a one-line correction (runbook S1 step 4).
- Cite in the F2 form only, and run `$ROOT/ingester/bin/check-citations` on every file you write that contains citations before presenting it.

## Progress

Show the reviewer where the transcript is at every step, using the Claude Code task list (the TodoWrite tool). Do this on every invocation, before any other work:

1. Run `$ROOT/ingester/bin/stage <engagement> TID tasks`. It prints the pipeline checklist with each step marked from the files on disk.
2. Create one task per line of its Pipeline and After the run sections, in that order, with the same wording. A `[x]` line is `completed`; the line marked `(current step)` is `in_progress`; every other line is `pending`.
3. As you work, update the list: mark a step `in_progress` when you start it and `completed` the moment its file exists or its check passes. The steps you own are the S0 proposals, S1 Read (split it into its own sub-tasks, one per numbered step of the S1 runbook's Procedure), S4 Processes (the same, one per numbered step of the S4 runbook's Procedure) and, after S3, the ingestion summary and the score.
4. When you stop at a gate, the human step is left `in_progress` and the task list stays visible with the next command in the final message.

The file `ENG/sessions/TID/TASKS.md` carries the same list for anyone reading the repository; the task list is for the person watching this session.

## Where you are

First, when `<first>` is a file path, run:

```
$ROOT/ingester/bin/register-transcript <engagement> <path> ["meeting subject"]
```

It prints the new `TID`. Then, and on every invocation, run:

```
$ROOT/ingester/bin/stage <engagement> TID status
```

It prints one word and act only on that word.

| Status | What you do |
|---|---|
| `needs-s0` | Run `stage <engagement> TID S0`, then follow runbook S0, Procedure. |
| `awaiting-session-sheet` | Re-present the review table from runbook S0, Procedure step 8, and say that verdicts given here are enough because you will write them into the sheet, and that "accept all" signs it. Stop. |
| `needs-s1` | Run `stage <engagement> TID S1` (it writes the accepted stakeholder files and prints `gate open`), then follow runbook S1, Procedure, steps 1 to 8. If the signed sheet says `- Review path: staged`, follow runbook staged-review instead: the files are the same, only the number of stops changes. |
| `awaiting-dossier` | Follow runbook S2, Completing the dossier: if every Verdict is filled, complete it and go straight to S3; otherwise present only the rulings, as runbook S1 step 8 says, or say that none are needed and offer proceed, and stop. |
| `needs-s3` | Run `stage <engagement> TID S3` **in the background** and wait for its exit line; a large dossier takes longer than a foreground command is given. Touch nothing under the item folders while it runs. Report as runbook S3 says, then in the same turn run `stage <engagement> TID summary` and present it as runbook summary says. The status is then `needs-s4`; carry straight on with S4 in the same turn, without waiting for another invocation. If S3 refuses, report its reason verbatim and stop. |
| `needs-s4` | S3 has written the transcript and its processes are next. Follow runbook S4, Procedure, steps 1 to 11: it reads the whole transcript again for processes only. For a transcript written before ingester 0.10.0 this is the rebuild of its processes (runbook S4, Rebuilding). |
| `awaiting-processes` | Present what runbook S4 step 11 says: only the flows and items that need a ruling, each with a recommendation, or that none do, and offer proceed. A Flow verdict given in the terminal ("flow 2 accept", "accept all") is written into the file as for the dossier; an instruction to move, split or reorder steps is an Edit you make in the file before the verdict. When every Flow verdict and item verdict is filled, write Completed by and Completed on and go straight to the write. |
| `needs-s4-write` | Run `stage <engagement> TID S4` **in the background** and wait for its exit line, exactly as for S3. Report the processes written and changed from the session log rows after `- S4 written on:`, and point at `ENG/index/processes.md` and `ENG/sessions/TID/TID.walkthrough-agenda.md`. Then, in the same turn, rerun `stage <engagement> TID summary` (runbook S4, After the write) and carry on with `done`. If it refuses, report its reason verbatim and stop. |
| `done` | Say the transcript has been written and point at `ENG/sessions/TID/TID.session-log.md`. If `ENG/evaluation/TID-summary.md` does not exist, or has no S4 figures, run `stage <engagement> TID summary` and present it as runbook summary says. If there is no `ENG/evaluation/TID-run-*.md`, score the draft (runbook evaluate): `stage <engagement> TID score sessions/TID/TID.dossier.md sessions/TID/TID.dossier.draft.md`, using `ENG/evaluation/TID-reference.md` as the reference instead when one exists. Present the counts, and a recommended Tag and Rule for each row of the failure-mode table as a ruling; "proceed" writes them into the run report and folds them into `ingester/extraction-rules.md` as runbook evaluate says. Stop. |
| `blocked: <reason>` | Report the reason verbatim. Stop. |

## Review happens in the terminal

The reviewer never has to open a review file. At every gate you present what needs a verdict in the reply, compactly and in the form the runbook gives, and take the verdicts from what they type. You present only the items that need a ruling, each with a recommended verdict, and never a list of proposals or counts for them to check (runbook S1 step 8). A reply such as "accept all", "proceed", "go", "approve" or "yes" takes your recommended verdict on every item you presented and Accept on the rest, and their instruction to proceed is their signature: write their name as Approver or Completed by and today's date, then carry on to the next stage in the same turn. Corrections given in the same reply ("item 12 reject", "owner of 33 is Martin", "the vendor is X") are written into the file before the verdicts. Never treat silence, or a reply about something else, as approval; ask again in one line. Record in the file's Notes or Closing that the verdicts came from the terminal and on whose word.
