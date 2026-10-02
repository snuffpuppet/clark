# The model benchmark

Version 0.1, 2 October 2026.

## Purpose

Runs `/ingest-transcript` on the same transcript with two models and compares what each drafted against the other. There is no reference: a signed dossier ages as the ingester changes, so each run is judged only against its pair. The judge is a model, because deciding that two items record the same thing, which did it better, and whether an item only one model found is real, all need reading.

The scope is S0 to the drafted S1 dossier. Everything runs in a throwaway fixture under `$TMPDIR/clark-bench/<run>/`, the report is printed in the terminal, and teardown removes the fixture and the Claude Code session files the arms left. Nothing is written under `ingester/`, `engagements/` or anywhere else in the repository.

## Running it

From `bench/`, in a normal shell (not inside a sandboxed Claude Code session, which cannot start `claude -p` or write the session files it needs):

```
make selftest   # no model calls; proves fixtures, pairing, judging and teardown
make bench      # the real run; see the cost note below
```

Cost, at API list price: the first run cut off part way through S1 had already cost US$8.76 for Opus and US$5.88 for Sonnet, and used up a five-hour plan limit with both arms in parallel. A full run costs more than that, plus the judge.

`KEEP=1 make bench` keeps the run folder and session files for debugging. `make clean` removes kept run folders and every session folder a bench run left under `~/.claude/projects`; do not run it while a bench is running. `EFFORT=<level>` passes `--effort` to both arms.

An arm can be cut off before the dossier gate, by a plan usage limit for example; the report then says `ended with api_error` and the limit message. Keep the run (`KEEP=1`), wait for the limit to reset, and continue it:

```
KEEP=1 make resume RUN=<run folder printed by the first run>
```

Each unfinished arm gets one more message on its saved session (`continue`, `RESUME_REPLY` in `bin/lib.sh`) as its next call, its figures are added to the earlier calls', and the judge runs once both arms are at the gate. Each arm was cut off at a different point, which the report shows as calls and calls cut off.

## What a run does

1. **Fixture per arm**: copies of `ingester/` and `.claude/skills/ingest-transcript/`, a fresh `techm-bss` engagement from `new-engagement` with today's `engagement.md` (its glossary SYS ids blanked, since those files do not exist in a fresh register), and the T001 vtt in `transcripts/unprocessed/`.
2. **Arms in parallel**, `claude-opus-5-5` and `claude-sonnet-5-5`, headless (`bin/run-arm`, see below). Call 1 runs `/ingest-transcript` and stops at the session sheet; call 2 resumes the session with `accept all. The session date is 14 September 2026.` (`GATE_REPLY` in `bin/lib.sh`; the date is not in the transcript, so it is read from the repo's `transcripts/T001.md`) and runs S1 to the dossier gate. An arm is finished when `T001.dossier.draft.md` exists and `stage status` is `awaiting-dossier`.
3. **Same input**: the two utterance tables must be identical, or citations cannot be compared.
4. **Items and pairs**: `bin/items` splits each draft into item blocks with their cited utterances and window; `bin/pair` lists X and Y items whose citations overlap, as hints.
5. **Judge, two passes** (`bin/judge-windows`): the transcript is cut into windows of 100 utterances, and every SYS record goes to window 0 so both arms' records of a system are judged together. Each window goes to `claude-opus-5-5` with no tools and no saved session, with `prompts/judge.md`, `ingester/extraction-rules.md`, the window's utterances and every utterance its items cite, both sides' items and the candidate pairs. X and Y are assigned at random per window in pass 1 and swapped in pass 2. A reply is validated (every item exactly once, eleven columns, known values) and asked again once if it fails.
6. **Report** (`bin/aggregate`): only groups both passes formed the same way count, and only verdicts both passes gave the same arm; the rest is reported as flipped.

## Reading the report

- **Status and efficiency**: whether each arm reached the gate, the models that actually answered, the calls each arm took and how many were cut off and resumed, wall minutes, turns, tokens, cost from the CLI's own result events, compactions, citation failures in the draft, and every permission denial.
- **Volume**: items per kind, the Needs a human share, episodes.
- **Alignment**: each arm's items by group: `same` (one item each side, the same thing), `overlap` (the same substance at a different granularity or kind) and `only`.
- **Quality**: over same and overlap groups, which arm did better on faithful, kind, grade, fields and citations (the criteria are defined in `prompts/judge.md`).
- **Unique finds**: each arm's only items as valid, weak or invalid, with the valid and invalid ones listed.
- **Caveats**: one run per arm, and the judge is one of the two models under test.

## The arm runner

`bin/run-arm` drives one arm through the two `claude -p` calls with `--model`, `--session-id`, `--permission-mode manual`, `--allowedTools` from `prompts/allowed-tools` (which includes `rm`), `--add-dir ../../ingester`, `--strict-mcp-config` and `--output-format stream-json --verbose`, and writes `<arm>/metrics.tsv` from the result events. Each call also gets `--settings` turning the OS sandbox on (`enabled`, `autoAllowBashIfSandboxed`, `allowUnsandboxedCommands: false`, `failIfUnavailable`). A Bash command that runs inside the sandbox is approved without a prompt, nothing may run outside it, and the call fails if the sandbox cannot start. The skill's commands are compound lines with command substitution (`ENG=$(pwd); ROOT=...`), which no allowlist pattern matches, so the sandbox is what lets them run; it also keeps bash writes inside the fixture and the temp folders. The mode is `manual`, because `dontAsk` denies anything without an allow rule, sandbox approval included. Any other tool call not on the allowlist would prompt; in `-p` nobody can answer, so it is denied, the model is told and carries on, and the denial is listed in the report. Tune `prompts/allowed-tools` from that list.

Write `prompts/allowed-tools` one entry per line; `#` lines are comments. `run-arm` joins the entries with commas into one `--allowedTools` argument.

## Files

| Path | Purpose |
|---|---|
| `Makefile` | `bench`, `selftest`, `check`, `clean`. |
| `bin/lib.sh` | Paths, the delete guard (`rm_run` refuses anything but a run folder directly under `$TMPDIR/clark-bench`), UUIDs, result-event fields, the arms. |
| `bin/bench` | The orchestrator, with teardown on exit. |
| `bin/prepare` | One arm's fixture. |
| `bin/run-arm` | One arm's two headless calls and metrics (see above). |
| `bin/items` | Item blocks from a draft, with window and cited utterances. |
| `bin/pair` | Candidate pairs by shared utterances. |
| `bin/judge-windows` | Blinded judge inputs, judge calls, validation. `JUDGE_CMD` replaces the judge. |
| `bin/aggregate` | Unblinding, the agreement between passes, the report. |
| `bin/selftest` | The run without models, with a fake judge (`selftest fake-judge`). |
| `prompts/judge.md` | The judge's instructions and output table. |
| `prompts/allowed-tools` | The allowlist for the arms. |

## Versioning

This README's version line is the benchmark's version. Bump it on any change to a script or prompt, and the judge prompt's own line when its rubric changes, so two reports can be told apart. The benchmark reads the ingester and never changes it, so a benchmark change never bumps `ingester/VERSION`.
