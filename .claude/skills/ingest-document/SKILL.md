---
name: ingest-document
description: Ingest a document (xlsx, pptx or pdf, such as a vendor's assessment workbook or deck) through stages D0, D1 and D3, one section at a time, linking what the register already holds and raising only what is new, stopping at each signed gate. Usage /ingest-document <file> ["title"] or /ingest-document Dnnn [<slug>], run from inside an engagement folder (engagements/<name>/), which is how the engagement is known.
---

# ingest-document

Version 0.16.0 (with the ingester; see `ingester/VERSION`). You are the judgement half of the document path described in `ingester/README.md` and `ingester/IMPLEMENTATION-PLAN.md` Addendum F. Shell scripts under `$ROOT/ingester/bin/` and the flattener under `$ROOT/ingester/docker/` do every deterministic step; you do the reading.

**The runbooks `ingester/runbooks/D0.md`, `D1.md` and `D3.md` are the source of truth for what each stage reads, produces, checks and reports.** This file says only how you operate them in a session. When this file and a runbook disagree, the runbook wins and this file is wrong.

**Shared with the transcript skill.** Read `.claude/skills/ingest-transcript/SKILL.md` and follow its sections **Where you run**, **Rules you never break**, **Progress** and **Review happens in the terminal** as written, reading transcript as document, `TID` as `DID`, session sheet as document sheet, and S3 as D3. Only what differs for documents is below.

## Arguments

`$ARGUMENTS` is `<first> ["title" | <slug>]`.

- `<first>` is a path to an `.xlsx`, `.pptx` or `.pdf` file (first invocation), or a document id `Dnnn` (every later invocation).
- After a path, an optional quoted title for the document.
- After an id, an optional section slug from the document sheet, to read that section instead of the next one in sheet order.

## Rules that differ for documents

- Item files are written only by `s3-write --document`, after the document sheet and the section dossier are signed. Stakeholder files are written by `s1-stakeholders` once the document sheet is signed, for accepted Author and Attributed rows only.
- Never edit, rename or delete a document under `documents/`. A SHA-256 mismatch blocks everything.
- Cite in the document citation form only (`documented | Dnnn/<unit>:<frag> | <Author> | <location> | "<quote>"`, F16), built with `$ROOT/ingester/bin/quote <engagement> DID <unit>:<frag>`, and run `check-citations` on every file you write that contains citations before presenting it.
- Read every section under the Treatment the signed sheet gives it, and nothing else (R28). Link before you raise (R30): a row that says what a held item or claim says is a Links row, never a new item, and a link never changes a field.
- The flattener runs in Docker. You run `make -C $ROOT/ingester flatten ENG=<engagement> DOC=DID`. If the image is not built, or Docker refuses, report the error verbatim, give the reviewer the command to run (`! make -C ../../ingester build`), and stop.

## Where you are

When `<first>` is a file path, run `$ROOT/ingester/bin/register-document <engagement> <path> ["title"]`. It prints the new `DID`. Then, and on every invocation, run `$ROOT/ingester/bin/stage <engagement> DID status` and act only on the word it prints.

| Status | What you do |
|---|---|
| `needs-flatten` | Run `make -C $ROOT/ingester flatten ENG=<engagement> DOC=DID`, then carry on with `needs-d0`. |
| `needs-d0` | Run `stage <engagement> DID D0`, then follow runbook D0, Procedure. Stop at the sheet. |
| `awaiting-document-sheet` | Re-present the review from runbook D0, Procedure step 8, and say that verdicts given here are enough and "accept all" signs it. Stop. |
| `needs-d1` | Run `stage <engagement> DID D1` (it writes the accepted stakeholder files and prints the next section), then carry on with `needs-d1:<slug>`. |
| `needs-d1:<slug>` | Follow runbook D1, Procedure, for that section, or for the slug given in the arguments if it is also unwritten. One task per numbered step. A section of several hundred rows is read in chunks of rows in unit order, and the Links and episodes are appended as you go; every row is read. Stop at the dossier. |
| `awaiting-dossier:<slug>` | Present what runbook D1 step 5 says: the Links summary and only the items that need a ruling, each with a recommended verdict. When every verdict is filled, write Completed by and Completed on and go straight to D3. Stop otherwise. |
| `needs-d3:<slug>` | Run `stage <engagement> DID D3 <slug>` **in the background** and wait for its exit line, as for S3. Report the ids created, updated and linked from the session log rows after `- Section <slug> written on:`, and the sections still to write. Then say the next section and stop, unless the reviewer asked to carry on through the sections. |
| `done` | Say every section is written and point at `ENG/index/documents.md` and `ENG/sessions/DID/DID.session-log.md`. Stop. |
| `blocked: <reason>` | Report the reason verbatim. Stop. |

Every `stage` call regenerates `ENG/sessions/DID/TASKS.md`; build the task list from `stage <engagement> DID tasks` as the transcript skill's Progress section says.
