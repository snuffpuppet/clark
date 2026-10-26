# clark

This repository holds three independent parts. `ingester/` is the mechanism for turning discovery transcripts into register items and a current-state record. `engagements/<name>/` holds everything produced for one client and says nothing about how ingestion works. `bench/` compares two models running the mechanism on the same transcript, in a throwaway copy; read `bench/README.md` before touching it.

Ingestion runs as the `/ingest-transcript` skill from this root, and documents (xlsx, pptx, pdf) as the `/ingest-document` skill; flattening a document is the one step that runs in Docker, through `ingester/Makefile`. Read `ingester/README.md` before touching the ingester: it lists every file, the formats the scripts parse, and the versioning rule. Read `ARCHITECTURE.md` before changing which document says what: the runbooks under `ingester/runbooks/` are the source of truth for the stages and the skill file only operates them. Shell scripts use awk, sed, grep, shasum and date only, and nothing is installed on the host.

## Hand entries from chat

When the reviewer states a register item in chat (for example "there is an integration from Source to the Usage Data API via REST"), enter it by hand on their word; no session sheet or dossier is needed. INT-0153 in `engagements/techm-bss/` is the worked example.

- Check the register first. If an item already covers it, say which and add to it with a History line instead of raising a new one. Both systems of an integration must already be in the record (I27); if one is missing, ask before creating it.
- Write the next free id in the type's folder, in the same frontmatter and body headings as its neighbours. `raised-on` and `updated` are today, `raised-by` is the reviewer, `created` is `<name>, <D Month YYYY>`.
- Map their words onto the field lists the integrity rules allow (REST is Mechanism `API`) and leave a field blank rather than guess it. Say in Notes that it was entered by hand and what is not yet stated.
- Source is one line: `- stated | <name> | <D Month YYYY> | Claude session, hand entry | "<their words>"`. History is one line: `- <D Month YYYY> | <name> | Created by hand entry: <fields set> |`.
- Append `- <D Month YYYY>: <id> <title> entered by hand on <name>'s word.` to the engagement's `LOG.md`.
- Run `ingester/bin/check-integrity <engagement>`, then `ingester/bin/render-index <engagement>`; both take seconds. Report the id, the fields set and the fields left blank.

## Talking to the reviewer

Lead with the ask. When a reply needs the human to do something, that goes first, under its own heading or as a single short bullet, before any findings or reasoning: one or two sentences and the exact command. Everything else goes under a separate heading below, which they can skip or come back to.

An ask is never folded into a paragraph of context, and the reviewer never has to read the analysis to discover there was an ask. Findings, caveats, bugs found in the mechanism, assumptions and reasoning all belong in the section below, however interesting they are.
