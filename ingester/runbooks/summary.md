# Runbook: ingestion summary

Version 0.1, 23 September 2026.

## Purpose

Record, for every transcript once it is written, which model did the reading, how long the ingestion took, how many tokens it used and what they would cost at API list prices, what it produced and how the reviewer's verdicts fell, and set those figures beside the previous transcript's. It is the efficiency half of the evaluation (design Q4, The ingestion summary). The run report from runbook evaluate is the accuracy half against a reference; the summary needs no reference and is written every time.

## Inputs

- The written transcript: its S3 run log under `logs/`, its utterance table, signed session sheet and signed dossier under `sessions/Tnnn/`.
- The Claude Code session files for the sessions that ran it: JSON lines under `~/.claude/projects/<folder>/<session id>.jsonl`, where `<folder>` is the working directory with every character that is not a letter or a digit turned into `-`. Every folder for the repository root or anything below it is searched, and a session file is used only if it contains `<engagement> <Tnnn>`, which every stage command for the transcript does. `CLAUDE_PROJECTS_DIR` points the script elsewhere.
- The latest earlier `evaluation/Tnnn-summary.md` in the engagement, for the comparison.
- The latest `evaluation/Tnnn-run-nn.md`, when a reference has been scored.

## Command

```
ingester/bin/stage <engagement> Tnnn summary [<from> <to>]
```

The window runs from the first `/ingest-transcript` command that names the transcript's file or id to the time of its S3 run log, and continues past S3 until the next reviewer message, so the report of the write is counted. `<from>` and `<to>`, in UTC as `2026-09-22T21:05`, replace the window when the session was also used for other work.

Or, as the skill: straight after S3 reports it has written, in the same turn.

## Procedure

1. Run the command. It refuses when the transcript has no S3 run log or no session file mentions it.
2. Read `evaluation/Tnnn-summary.md`. Check that the window starts at the first ingest command and ends at S3, that the model is the one that ran the session, and that the reviewer message count matches the number of replies the reviewer gave.
3. When the session was also used for other work inside the window, rerun with `<from>` and `<to>` narrowed to the ingestion and say so.
4. Present, in the terminal: the model, the elapsed, active and waiting minutes, the model calls, output tokens and list-price cost, the items, the Needs a human share, the items the reviewer changed, the Confident items changed, and the comparison table's rows that moved by more than a tenth. Point at the file for the rest.

## Outputs

- `evaluation/Tnnn-summary.md` from `ingester/templates/ingestion-summary.md` (format F11). A rerun overwrites it and raises its version.
- A run log under `logs/` with stage `summary`.

## What the figures mean

- **Elapsed** runs from the first ingest command to the S3 run log. **Active** is every gap between two session events of under ten minutes, plus the whole of the S3 write, which runs in the background; it is reported on its own because a large dossier can take half an hour to write. **Waiting** is every gap that ends in a reviewer message. **Idle** is what is left.
- **Tokens** are summed once per model call, keyed by message id, from the assistant lines in the window. Cache read dominates because every call re-reads the conversation from the prompt cache; output is the work the model produced.
- **Cost** prices every model call by its own model from `ingester/pricing.tsv`: output, cache read, cache write by TTL (the session file records 5-minute and 1-hour writes separately) and uncached input, with fast-mode calls at the fast multiplier. It is the API list-price equivalent; on a subscription plan nothing is charged per token. A model with no row in the price file is named as not priced and left out of the total. When a price changes, edit the row, set its as_of date, and bump `ingester/VERSION`.
- **Accuracy** is read from the signed dossier. Changed means Edit or Reject. A blank verdict on a Confident item in a bulk-accepted episode is an Accept. A Confident item the reviewer changed is the design's Confident-but-wrong count.

## Automatic checks

- The transcript has an S3 run log.
- At least one session file mentions `<engagement> <Tnnn>` and at least one model call falls in the window.

## What the reviewer does

Nothing is required. Read the comparison, and tell the skill when the window has caught work that was not the ingestion.

## What approval means

Not applicable. The summary records what happened; it gates nothing.

## On rejection

Rerun with a corrected window. The figures are derived; the summary is never edited by hand.

## What it cannot say

The share of the plan's usage limit is not in the session files, so the summary does not report it. `/usage` in the Claude Code session gives the limit. Missed and Invented counts need a reference and come from the run report.
