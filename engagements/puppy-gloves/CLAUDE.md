# Engagement: puppy-gloves

This folder holds everything produced for one client. Start Claude Code here to ingest a transcript:

```
claude --add-dir ../../ingester
/ingest-transcript <path-to-vtt> ["meeting subject"]      first time for a transcript
/ingest-transcript Tnnn                                    every later time
```

The skill is `.claude/skills/ingest-transcript/SKILL.md` at the repository root and carries the whole method. The mechanism it uses lives in `../../ingester/` (`README.md` there lists every script and format; `runbooks/` describe each stage for a person; `extraction-rules.md` is the method). Nothing under `../../ingester/` is written during ingestion.

## What is here

- `engagement.md`: client, domain, phases, glossary, ingester version last used. Edit by hand.
- `LOG.md`: running log of what happened to this engagement, one line per event, appended by the scripts and by hand.
- One file per item: `requirements/`, `decisions/`, `limitations/`, `risks/`, `open-items/`, `processes/`, `systems/`, `stakeholders/`, `topics/`, `transcripts/Tnnn.md`. Written by the write stage after a signed dossier; edit by hand only with a dated note.
- `index/`: generated tables. Never edit; run `../../ingester/bin/render-index puppy-gloves` to refresh.
- `transcripts/unprocessed/` and `transcripts/processed/`: VTT files as received. Never edit, rename or delete.
- `sessions/Tnnn/`: utterance table, session sheet, exchanges, episodes, dossier, session log, `TASKS.md`.
- `evaluation/`: hand-marked references and run reports. `logs/`: one file per skill run.

## Rules

- Nothing is written to an item file without a signed session sheet and a signed dossier. Silence is not approval.
- Never edit a signed session sheet or dossier.
- Where a transcript is: `../../ingester/bin/stage puppy-gloves Tnnn tasks`.
