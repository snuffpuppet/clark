# solution-register

This repository holds two independent parts. `ingester/` is the mechanism for turning discovery transcripts into register items and a current-state record. `engagements/<name>/` holds everything produced for one client and says nothing about how ingestion works.

Ingestion runs as the `/ingest-transcript` skill from this root. Read `ingester/README.md` before touching the ingester: it lists every file, the formats the scripts parse, and the versioning rule. Shell scripts use awk, sed, grep, shasum and date only, and nothing is installed on the host.
