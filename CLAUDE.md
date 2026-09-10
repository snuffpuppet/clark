# paper-trail

This repository holds two independent parts. `ingester/` is the mechanism for turning discovery transcripts into register items and a current-state record. `engagements/<name>/` holds everything produced for one client and says nothing about how ingestion works.

Ingestion runs as the `/ingest-transcript` skill from this root. Read `ingester/README.md` before touching the ingester: it lists every file, the formats the scripts parse, and the versioning rule. Shell scripts use awk, sed, grep, shasum and date only, and nothing is installed on the host.

## Talking to the reviewer

Lead with the ask. When a reply needs the human to do something, that goes first, under its own heading or as a single short bullet, before any findings or reasoning: one or two sentences and the exact command. Everything else goes under a separate heading below, which they can skip or come back to.

An ask is never folded into a paragraph of context, and the reviewer never has to read the analysis to discover there was an ask. Findings, caveats, bugs found in the mechanism, assumptions and reasoning all belong in the section below, however interesting they are.
