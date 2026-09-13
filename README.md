# clark

Clark turns discovery transcripts into a solution register: requirements, decisions, limitations, risks and open items, plus a current-state record of processes, systems, stakeholders and topics, with a human signing off before anything is written.

The name is a nod to Clark Kent. A clerk by day, taking down what was said and filing it under the right heading, with rather more going on underneath. The clerk part is the job. The Kent part is the judgement.

## What is in here

| Path | Purpose |
|---|---|
| `ingester/` | The mechanism. Design, register model, extraction rules, runbooks, templates and the shell scripts that do the deterministic work. Start with `ingester/README.md`, which lists every file and the formats the scripts parse. |
| `engagements/<name>/` | Everything produced for one client. Says nothing about how ingestion works. |
| `.claude/skills/ingest-transcript/` | The `/ingest-transcript` skill. Lives at the root so Claude Code finds it; it is part of the ingester. |
| `BRIEF.md` | The original brief. |
| `HANDOFF.md` | Where the work is up to and what to read first. |
| `CLAUDE.md` | Working instructions for Claude Code in this repository. |

## How it runs

Start a Claude Code session inside an engagement folder, `engagements/<name>/`, which is how the skill knows the engagement, then:

```
/ingest-transcript <path-to-vtt> ["meeting subject"]
```

The transcript moves through stages S0 to S3, stopping at each gate for a signed review. All judgement is done by Claude Code running the skill. The scripts use only awk, sed, grep, shasum and date, and nothing is installed on the host.
