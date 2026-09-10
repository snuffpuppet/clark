# Ingester implementation plan

Version 0.1, 10 September 2026. Owner: Adam Moyes. Implements `extraction-solution-design.md` version 1.2 against `solution-register-model.md` version 2.16, in the build order given in `HANDOFF.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: use superpowers:executing-plans to implement this plan step by step. Steps use checkbox (`- [ ]`) syntax for tracking. Commit after every numbered step. Nothing is pushed.

**Goal:** Build the ingester so that S0 runs on T001, produces the utterance table and session sheet, and stops for Adam's signature, with every later stage (S1 skill behaviour, S3 write, integrity, scoring) built and tested against T001 fixtures.

**Architecture:** Two independent parts. `ingester/` holds the mechanism: shell scripts (awk, sed, grep, shasum only), templates, runbooks, the rules file and the skill. `engagements/puppy-gloves/` holds everything produced for the client and is created from the templates in step 9. Judgement runs as the `ingest-transcript` skill inside Claude Code at the repository root; the scripts do only deterministic work and refuse to pass an unsigned gate.

**Tech stack:** POSIX sh, BSD awk 20200816, sed, grep, shasum, date. All already on the host. No Docker is needed because Claude Code is the runtime (design 7.4).

**Spec:** `ingester/extraction-solution-design.md` (sections 4, 5, 7, 10.1) and `ingester/solution-register-model.md` (sections 7 and 9).

## Global constraints

- Australian English. No em dashes. Every document carries `Version X.Y, D Month YYYY` on its second line and is bumped on change.
- Shell scripts use awk, sed, grep, shasum and date only. Nothing is installed on the host. No Docker.
- Nothing is written to a register, record or ledger without a signed session sheet and a signed dossier with no pending verdicts (design Q3).
- Transcript files are never edited, renamed or deleted. A SHA-256 mismatch blocks every stage.
- The ingester never writes into itself during ingestion. Everything a run produces lands under `engagements/<name>/`.
- Ids are never reused. Every id is a prefix plus a three-digit zero-padded number.
- Commit locally after each numbered step. Never push.

## Formats fixed by this plan

The design leaves the machine-readable shapes to the implementation. These are fixed here so that the skill, the scripts and the templates agree. They are repeated in `ingester/README.md`.

**F1 Utterance table** `sessions/Tnnn/Tnnn.utterances.tsv`. Tab-separated, header row `utterance	fragment	start	end	speaker	text`. One row per cue. Text has CR, internal newlines and runs of whitespace collapsed to one space, tabs removed. Rows sorted by utterance then fragment, both numeric, because utterance numbers are the key and are not in time order (design 2).

**F2 Citation line.** `<label> | Tnnn/<range>[, <range>] | <speaker> | <hh:mm:ss> | "<quote>"` where `<range>` is `<utt>:<frag>` or `<utt>:<frag>-<frag>`, `<label>` is one of `asked answered proposed restated accepted challenged deferred hedged`, the timestamp is the start of the first cited fragment cut to whole seconds, and the quote is verbatim with `...` allowed between kept runs. Inside a markdown table cell each `|` is written `\|` and citations are separated by `; `. Parsers unescape `\|` before reading.

**F3 Markdown tables.** Every register, the stakeholder register, the transcript register and the topic ledger is one markdown table under a title and a version line. Cells hold plain text with `|` escaped as `\|`. The first column is the id.

**F4 Item block** in a dossier or a reference marking. Items live inside an episode section and are parsed line by line:

```
### Item 14 | SYS.fact | Confident
- Episode: T001-E02
- Target: new
- Grade: Confident
- Verdict:
- Title: Defaults a new premises-device request to one port
- System: SYS-001
- Kind: Does
- Status: Current
- Confidence: Stated
- Asserted by: Martin Vasquez
- Citations:
  - answered | T001/867:0-1 | Martin Vasquez | 00:57:18 | "We default to one port at the moment ... that's what we currently do."
  - deferred | T001/867:1-3 | Martin Vasquez | 00:57:22 | "We need someone from the business to, if they want to change that"
- Gist: The vendor prefers four ports; Martin defers the change to the business.
```

The heading gives the item number, its kind and its grade. Kinds: `PRC`, `PRC.step`, `SYS`, `SYS.fact`, `REQ`, `DEC`, `LIM`, `RSK`, `OI`, `CR`, `Question`, `STK.edit`, `TOP`. `Target` is `new` or an existing id to update. `Grade` is `Confident` or `Needs a human: <reason>` with the reason from the Q3 list. `Verdict` is blank (pending), `Accept`, `Edit` or `Reject`; an edited item has its field lines edited in place and the verdict `Edit`. Field lines after `Verdict` are the register columns (model section 7) or the claim fields (design 4.1 to 4.3), one per line, `- <Field>: <value>`. `Citations` is a list. `Gist` is free text and is never written to a register.

**F5 Gate header.** Session sheet and dossier open with a field list containing `- Approver:` and `- Approved on:`. A gate is open when both are non-empty, and no `- Verdict:` line in the file is blank, and no table row in the session sheet has an empty last cell.

**F6 Current-state record.** One `## SYS-nnn <name>` or `## PRC-nnn <title>` section per element, holding a field list, then a claims table (`| ID | Kind | Description | Status | Confidence | Asserted by | Evidence | Episode | Session |` for systems; `| ID | Description | Performed by | System | Status | Confidence | Evidence | Episode | Session |` for process steps), then a questions list, then the marker line `<!-- end SYS-nnn -->`. S3 inserts new claim rows before the marker.

**F7 Scope taxonomy.** In `engagement.md` under the heading `## Scope taxonomy`, one value per `- ` bullet until the next heading. I5 reads this list.

**F8 Session log** `sessions/Tnnn/Tnnn.session-log.md`. Versioned. One table `| Id | Action | File | Item | Written on |` with one row per id created or changed by S3, plus ingester and rules versions in the header.

**F9 Run log** `logs/<UTC timestamp>-<Tnnn>-<stage>.md`. Written by `bin/stage` and by the skill: stage, ingester and rules versions, files read, files written, outcome. Append only.

---

## Step 1: Root `CLAUDE.md`, `ingester/README.md`, `ingester/VERSION`

**Files:**
- Create: `CLAUDE.md` (root)
- Create: `ingester/README.md`
- Create: `ingester/VERSION` containing `0.1.0`

**Produces:** the ingester's self-description that every later step points at, and the version string every log and session log records.

- [ ] **1.1** Write `CLAUDE.md` at the root. Contents: one paragraph saying this repository holds the ingester under `ingester/` and client engagements under `engagements/`, that the ingest skill is `/ingest-transcript`, and that `ingester/README.md` describes the mechanism. Nothing about any engagement.
- [ ] **1.2** Write `ingester/README.md`, version 0.1: what the ingester is, the file list from design 10.1 with one line each, the runtime (design 7.2), the command forms, the formats F1 to F9 above, how to run each script by hand, and the versioning rule. Sections: Purpose, Layout, Runtime, Command, Stages, Formats, Scripts, Versioning.
- [ ] **1.3** Write `ingester/VERSION` with the single line `0.1.0`. The build makes 0.1.0; the version stays there until the first change after step 10.
- [ ] **1.4 Verify.** Run:

```sh
cat ingester/VERSION                       # 0.1.0
grep -c 'ingester/README.md' CLAUDE.md      # 1 or more
sed -n 2p ingester/README.md                # Version 0.1, 10 September 2026
grep -c $'\xe2\x80\x94' CLAUDE.md ingester/README.md   # 0 for both (the byte sequence is the em dash)
```

- [ ] **1.5 Commit.** `git add CLAUDE.md ingester/README.md ingester/VERSION && git commit -m "Ingester 0.1.0: root CLAUDE.md, README and VERSION"`

---

## Step 2: Templates in `ingester/templates/`

**Files (create):**
- `ingester/templates/engagement.md`
- `ingester/templates/stakeholders.md`
- `ingester/templates/transcripts.md`
- `ingester/templates/session.md`
- `ingester/templates/dossier.md`
- `ingester/templates/registers/requirements.md`, `decisions.md`, `limitations.md`, `risks.md`, `open-items.md`, `change-requests.md`
- `ingester/templates/current-state.md`
- `ingester/templates/topics.md`
- `ingester/templates/session-log.md`
- `ingester/templates/run-report.md`
- `ingester/templates/reference.md`

**Produces:** the exact headers that `s0-prepare`, `s3-write`, `check-integrity` and `score` parse. Placeholders are `{{ENGAGEMENT}}`, `{{TID}}`, `{{DATE}}`, `{{DOMAIN}}`, `{{INGESTER_VERSION}}`, `{{RULES_VERSION}}`, `{{FILE}}`, `{{SHA256}}`, `{{SUBJECT}}`; scripts fill them with sed.

- [ ] **2.1** `engagement.md`: title `# Engagement: {{ENGAGEMENT}}`, version line, fields Client, Domain, Ingester version last used, Rules version last used; `## Scope taxonomy` (F7) with one example bullet to replace; `## Glossary of system names` table `| Name | Also called | Operated by | SYS id |`.
- [ ] **2.2** `stakeholders.md`: title, version line, table with columns `ID, Name, Variants, Organisation, Role, Standing, Decides, Status, First seen, Sessions, Source, Updated`. Variants is a comma-separated list of other renderings of the name; design 4.6 lists variants within Name, and a separate column keeps S0 matching mechanical while the meaning is unchanged.
- [ ] **2.3** `transcripts.md`: columns `ID, File, SHA-256, Session date, Title, Meeting subject, Attendees, Domain, Session sheet approver, Session sheet approved on, Dossier approver, Dossier approved on, Ingester version, Rules version` (design 4.5).
- [ ] **2.4** `session.md`: header field list (`- Transcript:`, `- File:`, `- SHA-256:`, `- Session date:` prefilled `{{SESSION_DATE}}` for the reviewer to confirm, `- Meeting subject:`, `- Domain:`, `- Scope:`, `- Ingester version:`, `- Approver:`, `- Approved on:`); `## Attendees` table `| Speaker tag | STK | Role | Standing | Decides | Utterances | Verdict |`; `## New stakeholders` table `| Proposed | Name | Organisation | Role | Standing | Decides | Passage | Verdict |`; `## Notes for the reviewer`. Verdict values as in design Q3.
- [ ] **2.5** `dossier.md`: header (`- Transcript:`, `- Session date:`, `- Meeting subject:`, `- Inferred purpose:`, `- Ingester version:`, `- Rules version:`, `- Dossier version:`, `- Approver:`, `- Approved on:`), a `## How to review` block quoting the Q3 verdict rules, an episode section skeleton `## Tnnn-E01 <title>` with `- Span:`, `- Topic:`, `- Subject:`, `- Outcome:` and one F4 item block as example, and `## Closing` with subsections Questions for the SMEs, Empty episodes, Citation check, Integrity check, Standing extensions proposed, Subject not reached.
- [ ] **2.6** Six registers with the 2.16 columns from model section 7, in that order, one header row and one alignment row each, version line `Version 0.1, {{DATE}}`.
- [ ] **2.7** `current-state.md`: title `# Current state: {{DOMAIN}}`, version line, an explanatory paragraph, one example SYS section and one PRC section in F6 shape with end markers, and a `## Withdrawn and retired` note that claims keep their ids.
- [ ] **2.8** `topics.md`: columns `ID, Title, Scope, Episodes, Open items, Closed by, Position, Updated`.
- [ ] **2.9** `session-log.md` (F8), `run-report.md` (the Q4 counts table per kind, the three extra counts, failure-mode tag table, comparison with the previous run, rules version), `reference.md` (the dossier skeleton with a `- Reference version:` header and the note that the marker fills Verdict as `Accept` for every item and marks Retired and Current, not needed claims explicitly so the scorer can count resurrections).
- [ ] **2.10 Verify.** Run:

```sh
ls ingester/templates ingester/templates/registers | wc -l        # 17 entries plus the registers dir line
for f in ingester/templates/registers/*.md; do sed -n 4p "$f"; done  # six header rows
grep -c '^| ID | Title | Status | MoSCoW | Phase | Raised on | Owner | Scope | Implemented by | Vendor ref | Links | Source | Updated |$' ingester/templates/registers/requirements.md  # 1
grep -rc $'\xe2\x80\x94' ingester/templates | grep -vc ':0$'   # 0
```

Then compare each register header word for word against model section 7 by eye.

- [ ] **2.11 Commit.** `git add ingester/templates && git commit -m "Ingester templates: engagement, stakeholders, transcripts, session sheet, dossier, six registers, current state, topics, logs, run report, reference"`

---

## Step 3: `bin/lib.sh`, `bin/register-transcript`, `bin/s0-prepare`, `bin/check-citations`

**Files (create, mode 755 except lib.sh):**
- `ingester/bin/lib.sh` shared functions
- `ingester/bin/register-transcript`
- `ingester/bin/s0-prepare`
- `ingester/bin/check-citations`

**Interfaces produced:**
- `lib.sh`: `die msg`, `today` (prints `10 September 2026` form via `date '+%e %B %Y' | sed 's/^ //'`), `bump_version file` (rewrites line 2 `Version X.Y, <today>` with Y+1), `doc_version file`, `next_id prefix files...` (scans first-column ids and prints `PREFIX-nnn`), `table_rows file` (prints data rows of the first markdown table, skipping header and alignment), `unescape_pipes`, `sha256 file`, `log_run engagement tid stage outcome read... written...` (writes F9).
- `register-transcript <engagement> <vtt-path> ["subject"]`: copies the file unchanged into `transcripts/unprocessed/` unless it is already there, refuses if a file of that name exists with a different SHA, assigns the next `Tnnn` from `transcripts.md`, appends the row with File, SHA-256, Meeting subject, Ingester and Rules versions, bumps `transcripts.md`, prints the id. Exit 0.
- `s0-prepare <engagement> <Tnnn>`: finds the file by the register, verifies SHA, writes F1 and the session sheet, prints a speaker summary. Exit 1 on any mismatch.
- `check-citations <engagement> <Tnnn> <file>`: reads every F2 citation in the file (item blocks and table cells), checks each against the utterance table, prints `OK` or one `FAIL <reason>` line per bad citation, exit 1 if any fail.

- [ ] **3.1** Write `lib.sh`. Key fragments:

```sh
today() { date '+%e %B %Y' | sed 's/^ *//'; }
doc_version() { sed -n '2s/^Version \([0-9][0-9.]*\),.*/\1/p' "$1"; }
bump_version() {
  v=$(doc_version "$1"); maj=${v%%.*}; min=${v#*.}
  new="$maj.$((min + 1))"
  sed -i '' "2s/^Version .*/Version $new, $(today)./" "$1"
}
next_id() { p=$1; shift
  n=$(grep -ho "^| $p-[0-9][0-9][0-9]" "$@" 2>/dev/null | sed "s/^| $p-//" | sort -n | tail -1)
  printf '%s-%03d\n' "$p" $(( ${n:-0} + 1 )); }
table_rows() { awk '/^\|/{ if (++n > 2) print }' "$1"; }
sha256() { shasum -a 256 "$1" | cut -d' ' -f1; }
```

Version lines in every document end with a full stop after the date: `Version 0.1, 10 September 2026.` so `doc_version` and `bump_version` agree.

- [ ] **3.2** Write `s0-prepare`. The VTT parser, line by line with CR stripped:

```awk
BEGIN { OFS = "\t"; print "utterance", "fragment", "start", "end", "speaker", "text" }
{ sub(/\r$/, "") }
/^[0-9a-f-]+\/[0-9]+-[0-9]+$/ { split($0, a, "/"); split(a[2], b, "-"); utt = b[1]; frag = b[2]; next }
/^[0-9:.]+ --> [0-9:.]+/ { start = $1; end = $3; next }
/^<v / { s = $0; sub(/^<v /, "", s); spk = s; sub(/>.*/, "", spk); sub(/^[^>]*>/, "", s); text = s; intext = 1
         if (s ~ /<\/v>$/) { emit(); intext = 0 } ; next }
intext { text = text " " $0; if ($0 ~ /<\/v>$/) { emit(); intext = 0 } }
function emit() { sub(/<\/v>$/, "", text); gsub(/\t/, " ", text); gsub(/  +/, " ", text)
                  print utt, frag, start, end, spk, text }
```

Pipe the output through `(sed -n 1p; sed 1d | sort -t "$(printf '\t')" -k1,1n -k2,2n)` so the header stays first. Then the speaker list: `cut -f5 | sed 1d | sort | uniq -c`. Match each speaker tag against `stakeholders.md` by Name or Variants (case-insensitive, exact string), writing matched rows into the Attendees table with STK, Role, Standing and Decides copied and Verdict blank, and unmatched tags into Attendees with STK `new` and also into New stakeholders with Role blank and Passage blank for the skill to fill. Fill the header from `transcripts.md` (File, SHA-256, Meeting subject) and `VERSION`. Session date is left blank; the skill proposes it and the reviewer confirms.

- [ ] **3.3** Write `check-citations`. Extract citation lines with `grep -o` on the pattern `[a-z]* | T[0-9][0-9][0-9]/[0-9:, -]* | [^|]* | [0-9:]* | "[^"]*"` after unescaping `\|`. For each: parse ranges; for each range fetch rows from the TSV where `$1 == utt && $2 >= lo && $2 <= hi`; fail `no such utterance` if none; fail `speaker mismatch` if any row's speaker differs from the cited speaker; fail `timestamp mismatch` if the first row's start cut at the dot does not equal the cited time; concatenate texts in fragment order; split the quote on `...`; walk the pieces with `index()` from the last match position, fail `quote not found` if a piece is missing or out of order. Print `OK n citations` at the end.
- [ ] **3.4 Verify on T001.** Create a scratch engagement so nothing touches `engagements/` before step 9:

```sh
S=/private/tmp/claude-501/-Users-adam-projects-solution-register/a8ff432d-a8af-4d9d-9358-303092d6df55/scratchpad/eng
mkdir -p "$S/scratch/transcripts/unprocessed" "$S/scratch/transcripts/processed"
sed "s/{{ENGAGEMENT}}/scratch/; s/{{DATE}}/$(date '+%e %B %Y' | sed 's/^ *//')/" ingester/templates/transcripts.md > "$S/scratch/transcripts.md"
cp ingester/templates/stakeholders.md "$S/scratch/stakeholders.md"
ENGAGEMENTS_ROOT="$S" ingester/bin/register-transcript scratch engagements/puppy-gloves/transcripts/unprocessed/T001-SANITISED-TechnicalSyncUp.vtt   # prints T001
ENGAGEMENTS_ROOT="$S" ingester/bin/s0-prepare scratch T001
wc -l "$S/scratch/sessions/T001/T001.utterances.tsv"        # 1105
cut -f5 "$S/scratch/sessions/T001/T001.utterances.tsv" | sed 1d | sort -u | wc -l   # 7
awk -F'\t' '$1==867' "$S/scratch/sessions/T001/T001.utterances.tsv"   # four fragments 0..3, Martin Vasquez, 00:57:1x
grep -c '| new |' "$S/scratch/sessions/T001/T001.session.md"        # 7
```

`ENGAGEMENTS_ROOT` defaults to `engagements` and exists only so tests can point at the scratchpad. Then write the seven worked-example citations from design section 6 into `$S/cites.md` and run `check-citations scratch T001 $S/cites.md`. Expect `OK`; any FAIL is examined and, where the design's example quote is the thing that is wrong, noted for the 1.3 design change rather than patched in the checker. Then corrupt one speaker and one word in a copy and confirm two `FAIL` lines and exit 1.

- [ ] **3.5 Commit.** `git add ingester/bin && git commit -m "Ingester bin: lib.sh, register-transcript, s0-prepare, check-citations, tested on T001"`

---

## Step 4: `ingester/extraction-rules.md` version 1

**Files:** Create `ingester/extraction-rules.md`.

- [ ] **4.1** Header `# Extraction rules`, `Version 1.0, 10 September 2026.`, a paragraph on how the file is used (design Q4: each failure mode maps to one rule, each fix attaches the failing passage as a test).
- [ ] **4.2** `## Roles and standing`: the table from design 5.1 verbatim.
- [ ] **4.3** `## Speech acts and exchange outcomes`: the table from design 5.2.
- [ ] **4.4** `## Rules R1 to R19`: one `### Rn <title>` per rule, the statement from design 5.6 verbatim, then `**Failure modes:**` (the tag list mapped: R1 present-tense-as-requirement, R3 hedge-as-fact, R5 legacy-resurrected, R12 vendor-intent-as-our-decision, R13 consultant-restatement-as-fact, R10 speaker-misattributed, R14 exchange-split, R15 episode-boundary, R9 chatter-marked, R16 overconfident-grade; others `none yet`), then `**Test passages:**` with a table `| Transcript | Citation | Expected | Added in | Note |` seeded from the design section 6 example that exercises the rule, and `none yet` where none does.
- [ ] **4.5** `## Grading conditions`: the Confident conditions from Q3 as a checklist, the controlled Needs-a-human reasons as a list (`hedged, contested, commitment not clearly accepted, standing unclear, authority check, conflicts with an existing claim or item, field needs a decision, kind uncertain between two types`), the loosening rule (three sessions at zero Confident-but-wrong, design 10.2 item 11) and the tightening rule.
- [ ] **4.6** `## Change log` table.
- [ ] **4.7 Verify.** `grep -c '^### R[0-9]' ingester/extraction-rules.md` prints 19. `sed -n 2p` prints `Version 1.0, 10 September 2026.` Every citation in the seeded test passages passes `check-citations` against the scratch T001 table from step 3.
- [ ] **4.8 Commit.** `git add ingester/extraction-rules.md && git commit -m "Extraction rules 1.0: R1 to R19, grading conditions, seeded test passages"`

---

## Step 5: The skill `.claude/skills/ingest-transcript/SKILL.md`

**Files:** Replace `.claude/skills/ingest-transcript/SKILL.md`.

**Consumes:** `bin/register-transcript`, `bin/s0-prepare`, `bin/check-citations`, and from step 6 `bin/stage`, `bin/check-integrity`, `bin/s3-write`. The skill names them by relative path from the root.

- [ ] **5.1** Frontmatter: `name: ingest-transcript`, `description: Ingest a discovery transcript through S0 to S3 for a named engagement, stopping at each signed gate. Usage: /ingest-transcript <vtt-file|Tnnn> <engagement> ["meeting subject"]`.
- [ ] **5.2** `## Arguments`: first argument a file path (first invocation) or a `Tnnn` id; second the engagement folder name under `engagements/`; optional third the meeting subject. Refuse and explain when the engagement folder or `engagement.md` is missing.
- [ ] **5.3** `## Where you are`: run `ingester/bin/stage <engagement> <Tnnn> status`, which prints one of `needs-register`, `needs-s0`, `awaiting-session-sheet`, `needs-s1`, `awaiting-dossier`, `needs-s3`, `done`, `blocked: <reason>`. Act only on that state. Never edit a signed file. Never advance past an unsigned gate; say which file is waiting and stop.
- [ ] **5.4** `## S0`: run `register-transcript` when given a file, then `stage <eng> <Tnnn> S0`. Then read the utterance table and, for each `new` speaker, propose Organisation, Role, Standing and Decides with one F2 citation each in the New stakeholders table; propose Mentioned rows for named absentees; propose the Session date (from the invitation or the reviewer's instruction; for T001, 8 September 2026 per the handoff) and the Domain; write the meeting subject; run `check-citations` on the session sheet; write the run log; tell the reviewer the sheet path and stop.
- [ ] **5.5** `## S1`: the runbook order. Read `extraction-rules.md`, the signed session sheet, `stakeholders.md`, `engagement.md`, the current-state record, the six registers and `topics.md`. Read the whole utterance table. Write `Tnnn.exchanges.md` (one line per utterance: utterance, speaker, speech act; then exchanges with open and close utterances and outcome), `Tnnn.episodes.md` (design 5.3 fields), then `Tnnn.dossier.md` from the template with F4 item blocks, ids for new items as `new`, existing ids for updates, every citation in F2, every grade with its reason, standing extensions as `STK.edit` items, topic matches as `TOP` items. Self-checks before presenting: `check-citations` on the dossier, `check-integrity --proposed` on the dossier plus the engagement, R15 empty episode check, every item has a content citation (`answered` or `proposed`), no `Confident` item carries a hedge word. Fix, re-run, record what remains in Closing. Write the run log. Stop.
- [ ] **5.6** `## S3`: run `stage <eng> <Tnnn> S3` and report the session log. On a dossier rejected outright, re-read with the reviewer's notes and write `Tnnn.dossier.v2.md`, bumping the Dossier version.
- [ ] **5.7** `## Staged review`: when the session sheet says `- Review path: staged`, stop after episodes, after claims, after rows, per `runbooks/staged-review.md`.
- [ ] **5.8** `## Rules you never break`: the eight bullets from Global constraints, plus R10 and R16 quoted.
- [ ] **5.9 Verify.** `head -4 .claude/skills/ingest-transcript/SKILL.md` shows the frontmatter; `grep -c INGEST-SKILL-FOUND` prints 0; every `ingester/bin/<name>` the skill mentions exists after step 6 (`grep -o 'ingester/bin/[a-z0-9-]*' SKILL.md | sort -u | while read p; do test -x "$p" || echo "missing $p"; done`, rerun at the end of step 6).
- [ ] **5.10 Commit.** `git add .claude/skills/ingest-transcript/SKILL.md && git commit -m "Ingest skill: arguments, gate detection, S0 and S1 behaviour, self-checks"`

---

## Step 6: `bin/check-integrity`, `bin/s3-write`, `bin/stage`

**Files (create, 755):** `ingester/bin/check-integrity`, `ingester/bin/s3-write`, `ingester/bin/stage`, and `ingester/bin/dossier2tsv` (helper that flattens F4 item blocks to one TSV row per item: `item, kind, grade, verdict, target, episode, fields as key=value joined by \x1f, citations joined by \x1e`; used by s3-write, check-integrity --proposed and score).

**Interfaces:**
- `check-integrity <engagement> [--proposed <dossier>]`: runs I1 to I19 over the engagement's registers, current-state record and stakeholders, plus the accepted items of the dossier when given. Prints `In <ids>` per failing rule, `WARN I15 ...` and `WARN I16 ...` for warnings, `OK` when no failures. Exit 1 on any failure.
- `s3-write <engagement> <Tnnn>`: gates (both files signed, no pending verdicts, SHA match, citations pass on accepted items, integrity passes on the proposed set), then appends, bumps, logs, moves.
- `stage <engagement> <Tnnn> <status|S0|S1|S3|check|score [ref]>`.

- [ ] **6.1** Write `dossier2tsv`. awk state machine: `^### Item` opens an item, `^- Key: value` collects fields, `^  - ` under `Citations` collects citations, `^## ` closes. Unit test: run it on the example block in `templates/dossier.md` and expect one row with kind `SYS.fact`.
- [ ] **6.2** Write `check-integrity`. Flatten each register with `table_rows` to TSV keyed by column name from the header row, so rules address columns by name. Implement each rule as one awk block that prints `In <rule> <id>` per failure. Rules by data source:
  - I1 unique ids across the six registers, current-state elements and STK rows.
  - I2 status per type from a here-doc list of valid values; required fields per status as tabulated in model I2.
  - I3, I4, I9, I10, I11, I12, I13, I14 direct column checks.
  - I5 against F7 in `engagement.md`.
  - I6 link targets: every `PREFIX-nnn` token in Links exists somewhere (registers, current-state claim ids, STK).
  - I7, I8, I17 cross-register checks by id lookup.
  - I15, I16 warnings, with the 14-day check done by converting `D Month YYYY` to a day count in awk (month table) against today.
  - I18 targets exist in the current-state record and are not Retired or Withdrawn.
  - I19 names in Owner, Raised by, Approved by, Consulted resolve to an STK Name or Variant, or start with `Vendor: `, or equal `Joint`, or match a Forum row; Mentioned rows are never Owner.
  With `--proposed`, accepted dossier items are turned into virtual rows (ids assigned as `new` placeholders `REQ-new1` and so on) and merged before the checks so that links to items created in the same session resolve.
- [ ] **6.3** Write `s3-write`. Order: check gates (exit 1 with the reason), `check-citations` on accepted items only (extract them with dossier2tsv), `check-integrity --proposed`, then for each accepted item in dossier order: assign the id with `next_id` (or use the target id), map the kind to its file, build the row from the template header (blank where the dossier has no value; citations into Source or, for OI, Raised by; `Updated` = today), append with awk before the first blank line after the table, or insert before the F6 marker for claims, or append a `## SYS-nnn` section when the target element is new, or append `, Tnnn-Enn` to a topic's Episodes cell; write the id into the session log; replace the `new` in the dossier's `Target` line with the assigned id so the dossier becomes the record of what was written. Then: apply `STK.edit` items to `stakeholders.md`, add `Tnnn` to each attendee's Sessions, fill the transcript register row (approvers, dates, attendees), set `Ingester version last used` in `engagement.md`, bump every touched document, write the run log, and last move the VTT to `processed/` and verify its SHA once more.
- [ ] **6.4** Write `stage`. `status` inspects the files (register row present, utterance table present, session sheet gate, dossier present, dossier gate, VTT location, SHA) and prints the state word. `S0` runs `s0-prepare`. `S1` checks the session sheet gate, prints `S1 is performed by the skill; gate open` and exits 0, or the reason and exits 1. `S3` runs `s3-write`. `check` runs `check-citations` on the dossier and `check-integrity`. `score` runs `bin/score` (step 8). Every branch writes an F9 run log.
- [ ] **6.5 Verify on T001 fixtures.** In the scratch engagement from step 3, build a full engagement from the templates (the same commands step 9 will use) and write a fixture dossier `fixture.dossier.md` containing the seven design section 6 items in F4 with Verdict `Accept`, and a fixture session sheet with all verdicts filled and an approver. Then:

```sh
ENGAGEMENTS_ROOT=$S ingester/bin/stage scratch T001 status                    # awaiting-session-sheet before the fixture sheet is copied in, then needs-s1, then needs-s3
ENGAGEMENTS_ROOT=$S ingester/bin/check-integrity scratch --proposed $S/scratch/sessions/T001/T001.dossier.md   # OK
ENGAGEMENTS_ROOT=$S ingester/bin/s3-write scratch T001
grep -c '^| SYS-' $S/scratch/current-state-*.md            # 3 (NETCO, CONFIG-MGMT, internal orchestration)
grep -c '^| REQ-001' $S/scratch/registers/requirements.md   # 1
grep -c '^| OI-' $S/scratch/registers/open-items.md         # 3
ls $S/scratch/transcripts/processed                          # T001-SANITISED-TechnicalSyncUp.vtt
sed -n 2p $S/scratch/registers/open-items.md                 # Version 0.2, 10 September 2026.
ENGAGEMENTS_ROOT=$S ingester/bin/check-integrity scratch     # OK, plus WARN I15 for the Draft REQ only if older than 14 days (it is not)
ENGAGEMENTS_ROOT=$S ingester/bin/stage scratch T001 status   # done
```

Negative tests: blank one Verdict and confirm `s3-write` exits 1 naming the pending item; change one cited word and confirm it exits 1 at the citation gate; set an OI Owner to a Mentioned person and confirm `I19` fails; run `s3-write` twice and confirm the second run refuses because the VTT is already processed.

- [ ] **6.6 Commit.** `git add ingester/bin && git commit -m "Ingester bin: check-integrity I1 to I19, s3-write with gates and version bumps, stage driver, dossier2tsv"`

---

## Step 7: Runbooks

**Files (create):** `ingester/runbooks/S0.md`, `S1.md`, `S2.md`, `S3.md`, `staged-review.md`, `evaluate.md`.

- [ ] **7.1** Every runbook has the same headings in this order (design 7.3): Purpose, Inputs, Command, Outputs, Automatic checks, What the reviewer does, What approval means, On rejection. Version line on line 2.
- [ ] **7.2** S0: command `ingester/bin/stage <eng> <Tnnn> S0` after `register-transcript`; the reviewer confirms date, domain, scope and every role, standing and Decides; approval per design Q3 row 1; rejection means editing the sheet, since the sheet is the register's proposal.
- [ ] **7.3** S1: command is the skill; the runbook lists the reading order from step 5.5 so a person can do it by hand; automatic checks are the self-checks; the reviewer does nothing at S1.
- [ ] **7.4** S2: what the reviewer does, quoted from Q3 row 2, with the F4 verdict mechanics and the bulk approval rule per episode.
- [ ] **7.5** S3: command `stage <eng> <Tnnn> S3`, the gate list, what it writes, and that rejection is impossible after the write (a wrong row is corrected by a later session, never by editing history).
- [ ] **7.6** staged-review: the three stops, the `- Review path: staged` switch on the session sheet, the same files.
- [ ] **7.7** evaluate: the design 8 sequence, the `score` command, tagging failure modes, editing the rules file, the regression rule.
- [ ] **7.8 Verify.** `for f in ingester/runbooks/*.md; do grep -c '^## ' "$f"; done` prints 8 for S0 to S3; every `ingester/bin/` path named in a runbook exists and is executable (same loop as 5.9).
- [ ] **7.9 Commit.** `git add ingester/runbooks && git commit -m "Runbooks S0 to S3, staged review and evaluate"`

---

## Step 8: `bin/score` and the reference marking template

**Files:** Create `ingester/bin/score` (755); refine `ingester/templates/reference.md` and `run-report.md` if the scorer needs a field they lack.

**Interface:** `score <engagement> <Tnnn> <reference-file> [<dossier-file>]` writes `evaluation/Tnnn-run-nn.md` (nn = next free number) and prints the counts table.

- [ ] **8.1** Flatten both files with `dossier2tsv`. Episode matching: spans overlap by more than half of the shorter span, using utterance numbers from `- Span:`. Item matching: same kind (with `SYS.fact` and `PRC.step` matched by kind, and `Question` matched to `Question` or `OI`) and cited utterance sets intersect. Right = matched and draft Verdict `Accept`; Wrong = matched and Verdict `Edit` or `Reject`; Missed = reference item with no match; Invented = draft item with no match, or whose citation fails `check-citations`. Confident-but-wrong = draft Grade `Confident` and Verdict not `Accept`. Resurrections = reference items with Status `Retired` or `Current, not needed` matched by a draft `REQ` or a draft claim with Status `Current`. Empty episodes = draft episodes whose Outcome is Settled, Parked or Unsettled and which own no item (R15). Derived: invented per hundred drafted, missed per hundred reference.
- [ ] **8.2** Write the report from `templates/run-report.md`, filling the per-kind table, the extra counts, a blank failure-mode tag table (one row per Wrong, Missed, Invented and Confident-but-wrong item for the human to tag), the rules and ingester versions, and the previous run's counts when `Tnnn-run-(nn-1).md` exists.
- [ ] **8.3 Verify on T001.** Score the step 6 fixture dossier against itself: all seven items Right, zero Missed, zero Invented. Copy it, delete one item and change another's verdict to Edit, score again: Missed 1, Wrong 1, and the second run report names the first in its comparison. Set a Confident item's Verdict to Reject: Confident-but-wrong 1.
- [ ] **8.4 Commit.** `git add ingester/bin/score ingester/templates && git commit -m "Scorer: Q4 counts, resurrections, empty episodes, confident but wrong, run report"`

---

## Step 9: Create `engagements/puppy-gloves/`

**Files (create from templates):** `engagements/puppy-gloves/engagement.md`, `stakeholders.md` (empty table), `transcripts.md` (empty), `topics.md` (empty), `registers/` (six empty), `current-state-<domain>.md` is deferred to S0 because the domain is set on the session sheet (design 10.2 item 4); `sessions/`, `evaluation/`, `logs/` folders with `.gitkeep`.

- [ ] **9.1** Add `ingester/bin/new-engagement <name>` (755): copies and fills the templates, creates the folders, refuses if the folder already holds any of the files. This is the deterministic form of the step 6.5 fixture setup and is what a person runs for the next client.
- [ ] **9.2** Run `ingester/bin/new-engagement puppy-gloves`. The existing `transcripts/unprocessed/T001-SANITISED-TechnicalSyncUp.vtt` is untouched.
- [ ] **9.3** Fill `engagement.md` by hand: Client puppy-gloves (sanitised), Domain left as `to be set at S0`, scope taxonomy with the domain placeholder, glossary seeded with the system names that appear in T001 (CONFIG-MGMT, NETCO, METCO, SEGMENT-TAG, PRIORITY-MARK, HANDOFF, PREMISES-DEVICE, ACCESS-TYPE-B, LEGACY-CARRIER), SYS ids blank until S3.
- [ ] **9.4 Verify.** `ingester/bin/stage puppy-gloves T001 status` prints `needs-register`. `ingester/bin/check-integrity puppy-gloves` prints `OK` on the empty registers. `shasum -a 256` of the VTT matches the value recorded later by step 10. `git status` shows only new files under `engagements/puppy-gloves/`.
- [ ] **9.5 Commit.** `git add engagements/puppy-gloves ingester/bin/new-engagement && git commit -m "Create engagements/puppy-gloves from the templates"`

---

## Step 10: Run S0 on T001 and stop

- [ ] **10.1** Run `ingester/bin/register-transcript puppy-gloves engagements/puppy-gloves/transcripts/unprocessed/T001-SANITISED-TechnicalSyncUp.vtt`. Expect `T001`. The file is already in place, so it is registered without a copy; its SHA-256 is recorded.
- [ ] **10.2** Run `ingester/bin/stage puppy-gloves T001 S0`. Expect `sessions/T001/T001.utterances.tsv` with 1105 lines and `T001.session.md` with seven `new` attendees.
- [ ] **10.3** Act as the skill for the judgement part of S0 (step 5.4): read the utterance table, propose for each of the seven speakers Organisation, Role, Standing and Decides with one citation each, propose Mentioned rows for named absentees (NETCO contact, "someone from the business", the SLT group as a Forum row), propose Session date 8 September 2026 and a Domain, and write them into the session sheet with Verdict blank. Run `ingester/bin/check-citations puppy-gloves T001 engagements/puppy-gloves/sessions/T001/T001.session.md` and expect `OK`.
- [ ] **10.4** Run `ingester/bin/stage puppy-gloves T001 status`. Expect `awaiting-session-sheet`. Confirm a run log exists under `engagements/puppy-gloves/logs/`.
- [ ] **10.5 Commit.** `git add engagements/puppy-gloves && git commit -m "T001 registered; S0 run; session sheet awaiting approval"`
- [ ] **10.6 Stop.** Report the session sheet path to Adam. Adam signs the sheet and hand-marks T001 as the first reference in `evaluation/T001-reference.md` using `templates/reference.md`. The first S1 run and run report follow in the next session.

---

## Self-review against the design

- Q1 (current-state record): F6, step 2.7, step 6.3 claim insertion, I18 in step 6.2.
- Q2 (citation unit): F2, step 3.3 checker, run by the skill (5.5) and by S3 (6.3).
- Q3 (two checkpoints, signed files, grading): F4, F5, templates 2.4 and 2.5, gates in 6.3 and 6.4, grading conditions in 4.5.
- Q4 (measurement and improvement): step 8 scorer, run report template, rules file test passages in 4.4, evaluate runbook 7.7.
- 4.5 transcript register and 4.6 stakeholder register: 2.2, 2.3, 3.2 matching, I19.
- 5.3 episodes with Subject field and 5.4 topic ledger: dossier template, TOP items, 6.3 ledger update.
- 5.5 stage table: S0 in 3.2, S1 in 5.5, S3 in 6.3, Evaluate in 8.
- 7.2 runtime: file copy and SHA in 3.1 register-transcript, move to processed in 6.3, id-based later invocations in 5.3.
- 7.3 runbooks and driver: 7 and 6.4.
- 10.1 file list: every file has a step; `current-state-<domain>.md` is created by the first S3 or by hand once the domain is set at S0.
- Not in this plan: the first S1 run, the run report and any 1.3 design changes from the colleague's review. Those follow Adam's signature on the session sheet.
