---
name: ingest-transcript
description: Ingest a discovery transcript (WebVTT) through stages S0 to S3, stopping at each signed gate. Usage /ingest-transcript <vtt-file|Tnnn> ["meeting subject"], run from inside an engagement folder (engagements/<name>/), which is how the engagement is known.
---

# ingest-transcript

Version 0.6.0 (with the ingester; see `ingester/VERSION`). You are the judgement half of the ingester described in `ingester/README.md` and `ingester/extraction-solution-design.md`. Shell scripts under `$ROOT/ingester/bin/` do every deterministic step; you do the reading. Follow `ingester/runbooks/` for each stage.

## Where you run

The session is started inside an engagement folder, `engagements/<name>/`, and that folder is the engagement. Before anything else:

```
ROOT=$(git rev-parse --show-toplevel)
ENG=$(pwd)
```

`ENG` must be `$ROOT/engagements/<name>` and must contain `engagement.md`. If it is not (the session was started at the root or somewhere else), say so in one line, name the folder to start from, and stop. Never pick an engagement by guessing. Every script below is called as `$ROOT/ingester/bin/<script> <name> ...`, where `<name>` is the folder's basename; the scripts resolve every path from the root themselves. Reads into `$ROOT/ingester/` are outside the working directory; the session grants them with `claude --add-dir ../../ingester` (or by approving the prompt once).

## Arguments

`$ARGUMENTS` is `<first> ["meeting subject"]`.

- `<first>` is either a path to a `.vtt` file (first invocation for a transcript) or a transcript id `Tnnn` (every later invocation).
- The optional meeting subject is a quoted phrase, for example "entity upgrade for multi-gig orders" or the title of the calendar invitation. It is recorded on the transcript file and the session sheet and read as a prior at S1 (below). It is never a filter (design 5.3).

Everything below uses `ENG` for the engagement folder, `<engagement>` for its basename and `TID` for the transcript id.

## Rules you never break

- Nothing is written to an item file (requirements/, decisions/, limitations/, risks/, open-items/, processes/, systems/, topics/) except by `$ROOT/ingester/bin/s3-write`, and only after both review files are signed with no pending verdicts. Stakeholder files are written by `$ROOT/ingester/bin/s1-stakeholders` once the session sheet is signed. Silence is not approval.
- Never edit a signed file. Never advance past an unsigned gate: say which file is waiting and stop.
- Never edit, rename or delete a transcript file. A SHA-256 mismatch reported by any script blocks everything; report it and stop.
- Write nothing under `ingester/`. Every output goes under `ENG/`.
- Quotes are verbatim, including transcription noise and filler. Interpretation goes in the Gist. A quote never spans two speakers (R10).
- When in doubt between Confident and Needs a human, choose Needs a human and give the reason (R16).
- Never fill a register field you cannot support from the transcript. Write a Question instead.
- Cite in the F2 form only, and run `$ROOT/ingester/bin/check-citations` on every file you write that contains citations before presenting it.

## Progress

Show the reviewer where the transcript is at every step, using the Claude Code task list (the TodoWrite tool). Do this on every invocation, before any other work:

1. Run `$ROOT/ingester/bin/stage <engagement> TID tasks`. It prints the pipeline checklist with each step marked from the files on disk.
2. Create one task per line of its Pipeline and After the run sections, in that order, with the same wording. A `[x]` line is `completed`; the line marked `(current step)` is `in_progress`; every other line is `pending`.
3. As you work, update the list: mark a step `in_progress` when you start it and `completed` the moment its file exists or its check passes. The steps you own are the S0 proposals, S1 Read (split it into its own sub-tasks: read the rules and the engagement, read the transcript, write exchanges, write episodes, write the dossier, run the self-checks) and, after S3, the score.
4. When you stop at a gate, the human step is left `in_progress` and the task list stays visible with the next command in the final message.

The file `ENG/sessions/TID/TASKS.md` carries the same list for anyone reading the repository; the task list is for the person watching this session.

## Where you are

First, when `<first>` is a file path, run:

```
ingester/bin/register-transcript <engagement> <path> ["meeting subject"]
```

It prints the new `TID`. Then, and on every invocation, run:

```
ingester/bin/stage <engagement> TID status
```

It prints one word and act only on that word.

| Status | What you do |
|---|---|
| `needs-s0` | Run S0 below. |
| `awaiting-session-sheet` | Re-present the review table from S0 step 8 and say that verdicts given here are enough because you will write them into the sheet, and that "accept all" signs it. Stop. |
| `needs-s1` | Run S1 below. |
| `awaiting-dossier` | The dossier is written but not yet complete. Follow **Completing the dossier** below: if every Verdict is filled, mark it complete and go straight to S3; otherwise present the items still without a verdict and stop. |
| `needs-s3` | Run S3 below. |
| `done` | Say the transcript has been written and point at `ENG/sessions/TID/TID.session-log.md`. Stop. |
| `blocked: <reason>` | Report the reason verbatim. Stop. |

## S0 Prepare

1. Run `$ROOT/ingester/bin/stage <engagement> TID S0`. It writes `ENG/sessions/TID/TID.utterances.tsv` and `ENG/sessions/TID/TID.session.md` with every speaker matched against `ENG/stakeholders/*.md` by name or variant. Speakers it could not match appear in Attendees with STK `new` and again in New stakeholders with empty cells.
2. Read the whole utterance table.
3. For every `new` speaker, fill the New stakeholders row: Organisation (the real company name, never a positional label: the client's own name for internal people, the vendor's name for the vendor, and every other party by name), Role (Internal SME, Internal architect, Internal other, Vendor, Consultant), Segment (Residential, BE&G or Wholesale when the person speaks for one customer segment; blank when they speak for the whole business, as a Finance SME does; blank for vendors and consultants), Department (where they sit, such as Product, Operations, Finance, Architecture; blank when the transcript gives no clue), Standing (the systems, processes or domains they show they own or operate, as text), Decides (the subjects on which they may accept a decision; blank for architects and vendors), and Passage: one F2 citation for the utterance that best shows the role. Read the role from what they say and how others address them, never from the name alone. A `(Vendor)` suffix on the speaker tag is evidence, not proof.
4. Propose Mentioned rows for people, roles or bodies named as owners or deciders who did not speak: "someone from the business", "ask NETCO", a named colleague, an approving group. Role Mentioned, or Forum for an approving body on our side, with Decides naming what that body approves. One citation each.
5. Propose the Session date from the invitation, the reviewer's instruction, or the transcript, in `D Month YYYY` form, and the Domain. Fill the Meeting subject if one was given. Write anything the reviewer should know, including the purpose you infer for the session, under Notes for the reviewer.
6. Leave every Verdict cell blank. Leave Approver and Approved on blank.
7. Run `$ROOT/ingester/bin/check-citations <engagement> TID ENG/sessions/TID/TID.session.md`. Fix any FAIL and rerun until OK.
8. Append a line to `ENG/LOG.md`: `- <today>: TID S0 proposals written for <n> speakers; awaiting the session sheet.` Then present the proposals for review **in the terminal**, so the reviewer never has to open the sheet to check them. Write a markdown table in the reply, one row per proposed stakeholder, with the columns Name, Org, Role, Segment, Department, Utterances (blank for people who did not speak) and Verdict (left blank for them to fill). Follow it with a Decision authority list giving the full Decides text for every row that has one, because that is the field R19 reads at S1 and it is too long for the table; then one line naming any row whose evidence is thin. Give the sheet path, the count matched and the count new. Say that verdicts can be given here in the terminal and that you will write them, the Approver and the Approved on date into the sheet on their word, and that they may edit the sheet by hand instead if they prefer. Then stop.

## S1 Read

Precondition: `stage` said `needs-s1`, which means the session sheet is signed and every verdict is filled. Do not start otherwise. Run `$ROOT/ingester/bin/stage <engagement> TID S1` first: it writes one `ENG/stakeholders/STK-nnnn.md` per accepted row and prints `gate open`.

Mark each of the S1 sub-tasks in the task list as you reach it. Read, in this order: `ingester/extraction-rules.md` in full; the signed session sheet; every file under `ENG/stakeholders/`; `ENG/engagement.md` (glossary); every file under `ENG/systems/` and `ENG/processes/`; every file under `ENG/requirements/`, `ENG/decisions/`, `ENG/limitations/`, `ENG/risks/` and `ENG/open-items/`; every file under `ENG/topics/`; then the whole utterance table end to end. The tables under `ENG/index/` are a quick overview and are regenerated by S3; the item files are the truth.

**The outstanding set.** A follow-up session changes the register as much as it adds to it. Before segmenting, list from the item files everything still open (R17): open items not Closed, risks not Realised or Retired, decisions in Proposed, requirements in Draft, limitations in Identified or Under assessment, claims Hedged or Contested, and every line under Questions for the SMEs in the earlier dossiers in `ENG/sessions/*/`. Keep that list beside you while reading. Each member the session touches becomes a mutation item (below); each on-subject member the session never reaches goes under Closing, Outstanding not reached.

Then produce three files in `ENG/sessions/TID/`.

**`TID.exchanges.md`** (versioned). Part 1: one line per utterance, `utterance | speaker | speech act`, with the act one of ask, assert, propose, restate, accept, challenge, defer, hedge, aside. Part 2: one block per exchange with opening and closing utterances, participants, outcome (Answered and accepted, Answered and challenged, Deferred, Hedged, Unanswered) and the item numbers it yields. This is working, not reviewed, and it is what the scorer uses to tag failures.

**The meeting subject as a prior.** Read `- Meeting subject:` from the session sheet before segmenting. When one is given: expect at least one episode on that subject and look for where the session reaches it; use its vocabulary to name and bound those episodes and to read noisily transcribed terms (a product name garbled by the transcriber is most likely a term from the subject); match those episodes first against existing topics whose title shares that vocabulary; set each episode's Subject to On subject, Related or Off subject. Episodes on other subjects are read, segmented, matched and graded exactly as if no subject had been given. If the session never reaches the subject, say so under Closing, Subject not reached. When no subject is given, infer the session's purpose from the opening minutes and the title, write it in `- Inferred purpose:`, and leave Subject blank on every episode.

**`TID.episodes.md`** (versioned). One block per episode with the design 5.3 fields: ID `TID-Enn`, Title, Span (first and last utterance and timestamps), Topic (a TOP id or `new`), Subject (On subject, Related, Off subject, or blank when no subject was given), Outcome (Settled, Parked, Unsettled, Informational, Aside), Outputs (item numbers). Greetings, scheduling, screen-share trouble and jokes are Aside episodes with no items (R9).

**`TID.dossier.md`** from `ingester/templates/dossier.md`, organised by episode, every item in the F4 block form shown in the template. For each exchange apply the rules:

- Present tense about today is a SYS.fact or PRC.step, never a REQ (R1). Confidence from standing: Stated, Second-hand, Hedged or Contested (R3, R4, R7). Legacy language is a Retired claim and nothing else (R5). "We do X but we don't need it" is Current, not needed with the reason quoted (R6).
- Commitment language about the solution from an Internal architect or SME is a REQ in Draft (R2). Its Phase is a name from the Phases list in `ENG/engagement.md`: the current phase unless the speakers place it later ("day two", "next release"), in which case the later phase named there. A vendor's "we need to support" is a DEC in Proposed raised by the vendor, or an OI (R2, R12).
- A vendor describing how their build will behave is a DEC in Proposed. It is Accepted only when an internal party whose Decides covers the subject accepted it in the exchange, and then it is graded Needs a human: authority check (R12, R19).
- A vendor Cannot fact about their own platform that blocks a stated need also yields a LIM with Identified on = session date (R7).
- An explicit deferral is an OI, with the named party in the Gist so the reviewer sets Owner (R8). A hedge is a Hedged claim plus a Question (R3). An unsettled challenge is Contested claims on both sides plus a Question (R4).
- A restatement by an architect or consultant is cited `restated` and the claim is asserted by the confirmer; unconfirmed it is a Question (R13).
- One item per assertion; an exchange carrying a fact and a deferral yields two items with overlapping citations (R11). Read kind, confidence and outcome from the whole exchange (R14).
- Before proposing any item, check the engagement's existing claims, items and topics. A match sets `Target` to the existing id and proposes the update. A conflict is Needs a human: conflicts with an existing claim or item, naming both ids. A closure of an existing open item is an item of kind `OI` with `Target` the existing id and Status Closed (R17).
- **A mutation item** carries only the fields that change, each as it should read afterwards, plus the citations that justify the change. Its Gist states every change as `Field: old to new` so the reviewer judges it without opening the file. Use the moves table under R17 in `extraction-rules.md` for what each move needs; a move that needs a companion record (supersede a decision, realise a risk, disposition a limitation) is two items in the same dossier, the new one referred to as `item nn` in Links, Resolution or Disposition record. Never reopen a Closed open item and never change an Accepted decision except to Superseded; the integrity check refuses both.
- A speaker who reveals new standing yields an `STK.edit` item with a citation (R18). Each episode yields a `TOP` item naming the matched topic or proposing a new one.
- Grade every item with the conditions in `extraction-rules.md`, Grading conditions. Use exactly one reason from the controlled list.
- For a REQ, add `- Links: preserves SYS-nnn.fN` or `replaces ...` when it keeps or changes a claim in the record or in this dossier (refer to a claim proposed in this dossier by its item number, `item 07`, and S3 resolves it).

Number items from 01 in dossier order. Set `- Session date:` and `- Meeting subject:` from the session sheet and `- Inferred purpose:` to the purpose you read from the opening minutes when no subject was given, or to how the session related to the subject when one was.

Fill Closing: Questions for the SMEs (every Question item, one line each); Empty episodes (every Settled, Parked or Unsettled episode that yielded nothing, R15); Outstanding not reached (every on-subject member of the outstanding set the session did not touch, one line each with its id and title); Standing extensions proposed; Subject not reached (when a subject was given and no episode is On subject).

**Self-checks before presenting.** Run each, fix what you can, rerun, and record what remains under Closing.

1. `$ROOT/ingester/bin/check-citations <engagement> TID ENG/sessions/TID/TID.dossier.md` must print OK. Record the line under Citation check.
2. `$ROOT/ingester/bin/check-integrity <engagement> --proposed ENG/sessions/TID/TID.dossier.md`. Failures you can fix (a missing Raised by, an Implemented by, a Status not in the model) you fix. Failures that need the reviewer (an Owner, a MoSCoW) stay, and you list them under Integrity check with the item number.
3. Every item has an `answered` or `proposed` citation, or is a Question.
4. No Confident item carries a hedge word in its content citation (probably, I think, my guess, maybe, I'm not sure, you'd have to ask).
5. Every episode that is Settled, Parked or Unsettled owns at least one item.

**Accept the Confident items.** Before the run log, write `- Verdict: Accept` on every item graded Confident. Leave every item graded Needs a human blank: those are the reviewer's. Add a short section at the end of Closing, `### How the Confident items were accepted`, recording that the verdicts were written by the skill under this rule rather than marked one by one, and giving the count. This does not sign the dossier; Approver, Approved on and the Needs a human verdicts still gate S3.

Write a run log with `$ROOT/ingester/bin/stage <engagement> TID log S1 "<outcome>"`. Append to `ENG/LOG.md`: `- <today>: TID S1 read; dossier v<n> with <items> items (<new> new, <mutations> changing existing ids), <needs> needing a human; awaiting review.` Tell the reviewer the dossier path, the item count split into new items and mutations, the count graded Needs a human, that you have accepted the Confident items and how many, and how many outstanding items were not reached, and stop.

**Rejected dossier.** When the reviewer has written `Reject` on the dossier header's Completed by line or asked for a re-read, read their notes, produce `TID.dossier.v2.md` with `- Dossier version: 2`, and leave the rejected file untouched.


## Review happens in the terminal

The reviewer never has to open a review file. At every gate you present what needs a verdict in the reply, compactly, and take the verdicts from what they type. A reply such as "accept all", "proceed", "go", "approve" or "yes" is a verdict of Accept on every item you presented, and their instruction to proceed is their signature: write their name as Approver or Completed by and today's date, then carry on to the next stage in the same turn. Corrections given in the same reply ("item 12 reject", "owner of 33 is Martin", "the vendor is X") are written into the file before the verdicts. Never treat silence, or a reply about something else, as approval; ask again in one line. Record in the file's Notes or Closing that the verdicts came from the terminal and on whose word.

## Completing the dossier

A dossier is complete when every Verdict is filled and both self-checks pass. There is no separate approval step and you never stop to ask for one.

When `stage` says `awaiting-dossier`, read the dossier and check every Verdict.

- **Any Verdict blank.** Present the outstanding items in the terminal, grouped by the reason each was graded Needs a human, one line each saying what you need in order to fill it. Say which fields are still missing on the items that need one, such as an Owner or a MoSCoW. Say that "accept all" plus any corrections completes the dossier and starts S3. Stop.
- **Every Verdict filled.** Run `$ROOT/ingester/bin/check-citations` and `$ROOT/ingester/bin/check-integrity <engagement> --proposed` on the dossier and fix what you can. Then write `- Completed by:` with the reviewer's name and `- Completed on:` with today's date into the header, add a short `### How this dossier was completed` section at the end of Closing recording the rule and where the verdicts came from, and go straight to S3. Report what was written.

Never mark a dossier complete while a Verdict is blank, and never invent a verdict to get there. A Confident item in an episode carrying `Bulk accept:` counts as filled.

## S3 Write

Precondition: `stage` said `needs-s3`. Run:

```
ingester/bin/stage <engagement> TID S3
```

It checks every gate again, writes the accepted items, applies every mutation to its existing file with a History line (F10), writes the session log, regenerates the index including `index/changes.md`, and moves the transcript to `processed/`. Report the session log path, the ids it created and the ids it changed with the change each row records. If it refuses, report its reason verbatim and stop.

## Staged review

When the signed session sheet says `- Review path: staged`, follow `ingester/runbooks/staged-review.md`: stop after `TID.episodes.md` for confirmation, again after the current-state claims, and again after the register rows. The files are the same; only the number of stops changes.
