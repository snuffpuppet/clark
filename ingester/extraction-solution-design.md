# Extracting solution records from discovery transcripts: solution design

Version 1.0, 10 September 2026. Approved by Adam Moyes, 10 September 2026. Owner: Adam Moyes. Responds to `BRIEF.md` version 1.0 and `solution-register-model.md` version 2.16.

This document answers the four questions in the brief, defines the current-state record and the session structures around it, and then proposes the extraction method. Section 6 shows worked examples taken from `T001-SANITISED-TechnicalSyncUp.vtt` so that each rule can be checked against real speech. Section 7 describes the split between the ingester, which holds the mechanism, and the engagements, which hold everything produced for a client. Section 10 lists the assumptions and questions that need an answer before implementation starts. Section 11 is the change log.

---

## 1. Goals and principles

**Primary goal.** Correct semantic extraction: register items that are true to what was said and useful in the project meeting, and a current-state record that reads as an accurate description of today. Judged against a hand-marked transcript by what was got right, got wrong, missed and invented.

**Secondary goal.** Reduce the human effort per transcript, and never at the expense of the primary goal. The human's attention is spent on the items that need judgement, and the share of items that need it shrinks as the method proves itself.

Four principles follow.

- **Inference first.** Claude, running as Claude Code at the repository root with the engagement named, does all the reading and all the meaning-making: episodes, exchanges, kinds, claims, rows, links, questions, topic matching, and checking each of those against what the engagement already holds. Shell scripts are confined to work where inference adds risk without adding meaning: flattening the VTT, verifying that a quote exists with that speaker, running the register model's integrity rules, bumping versions, counting results against a reference.
- **Whole reading before review.** The skill reads the transcript end to end, produces everything it can, checks its own output, and fixes its own failures before a human sees anything. The human reviews a finished reading, organised the way a person would read a session, rather than a sequence of partial drafts.
- **Confidence is graded and measured.** Every proposed item is marked confident or needs a human, with the reason. The human must judge the second group and may approve the first in bulk after reading it. The evaluation counts whether bulk-approved items were ever wrong, and if they were, the grading tightens. This is the only mechanism by which human effort is reduced.
- **Nothing is written without approval, and silence blocks.** Approval is a signed review file with no pending items. The write stage refuses anything else.

---

## 2. What the transcript tells us

The design has to work on transcripts like T001, so these observations shape it.

- **Each cue has a stable id.** A cue is identified as `<uuid>/<utterance>-<fragment>`, for example `.../867-3`. The utterance number groups the fragments of one speaker turn. Fragments of one utterance can be interleaved in the file with another speaker's utterance, and utterance numbers are not in time order (867-0 appears before 864-0). Timestamps overlap where people talk over each other. The utterance number is therefore the only reliable key. The timestamp helps a human find the spot.
- **Cues are short and broken mid-sentence.** A single assertion often spans three to six cues. The unit a reviewer needs to see is the utterance or a run of utterances, never one cue.
- **Meaning lives in the exchange.** Elena asks whether CONFIG-MGMT supports the templates natively, Martin answers "absolutely not", Elena replies "we already have this problem". The fact comes from the answerer, the topic from the question, and the weight from the reaction. Reading one speaker's utterance on its own loses two of the three.
- **The session falls into episodes.** T001 spends its first thirty-five minutes on SEGMENT-TAG modes for legacy templates, most of the rest on entity upgrade for multi-gig orders, and a few minutes on scheduling. People remember and revisit the session in those units.
- **Transcription is noisy.** "I enter" for "I'm here", "interview version" for a product name. Verbatim quotes must keep the noise; interpretation belongs beside the quote, never inside it.
- **Speaker role changes what a statement means.** A vendor saying "METCO will always reject that" is stating a fact about a third-party system. A vendor saying "the rule will be first check the capacity" is proposing a design. An internal SME saying "we default to one port at the moment" is describing current practice. An architect saying "we need a process" is committing. The same grammar yields different record types depending on who speaks and about what.
- **Hedging is everywhere.** "My guess", "probably in that spreadsheet", "you'd have to ask NETCO", "maybe it's just inferred". Much of T001's most interesting content is hedged. Recording a hedge as a fact is the most likely way to invent something.
- **T001 is a vendor technical sync-up.** It is rich in system facts, limitations and open items, and thin on business processes with a trigger, an actor and a frequency. The first hand-marked reference will reflect that, and the process side of the design will get its real test on a later SME session.

---

## 3. Answers to the four questions

### Q1. Where do current processes and current system facts live?

Three options were considered.

| Option | Shape | For | Against |
|---|---|---|---|
| A. Item types in the register model | Add PRC and SYS types with ids, states, columns and integrity rules, beside REQ, DEC and the rest | One id scheme, one set of link rules, one integrity run | Registers hold things that move through states and get worked. A current-state claim has no lifecycle beyond "still true" or "no longer true". Adding it re-inherits the shape the brief removed. The outstanding view and the maintenance routine would need exclusions for types that never have owners or next actions. Present-tense description sitting in the same tables as requirements is exactly the confusion the brief warns about. |
| B. A separate current-state record | A versioned document per domain with two element types, Process and System, each made of claims with their own ids. Registers link to claims with two new relationship words. | Keeps the register model's principle that registers hold items and narrative lives elsewhere. Claims can be read top to bottom as a description of today. Traceability, evidence and confidence are properties of claims and need not fit register columns. | Two structures to maintain. Cross-links need an integrity rule of their own. |
| C. Mix | Current-state record as in B, plus a REQ column "Current state" holding the claim ids | Same as B, with the link visible on the requirement row | Duplicates what Links already does. A new column changes the register layout for one relationship. |

**Recommendation: B.** The current-state record is a first-class document with the same rigour as the registers (ids never reused, evidence on every claim, versioned), and the register model gains only two relationship words, `replaces` and `preserves`, from a REQ to a claim id. That change is small enough to ship as register model version 2.16 without disturbing anything else. Section 4 defines the record.

### Q2. What is the unit of traceability?

**The evidence citation, read at the level of an exchange.** Every row in a register and every claim in the current-state record carries at least one citation. A citation names the transcript, the utterance and fragment range, the speaker, a timestamp and a verbatim quote:

```
T001/867:0-3 | Martin Vasquez | 00:57:18 | "We default to one port at the moment ... that's what we currently do."
```

- `T001` is the transcript id, assigned in the transcript register (4.5).
- `867:0-3` is the utterance number and the fragment range.
- The speaker is copied from the cue's `<v>` tag.
- The timestamp is the start of the first cited fragment, for a human finding the spot.
- The quote is verbatim, whitespace-normalised, at most about forty words, with `...` allowed to skip words inside the cited range. A quote never joins two speakers.

Where the meaning comes from an exchange, the item carries one citation per part, labelled by the part's role in the exchange:

```
asked     T001/630:1-2 | Elena Marchetti  | 00:35:34 | "Do you know if we support these templates natively out of CONFIG-MGMT then?"
answered  T001/631:0, 632:0 | Martin Vasquez | 00:35:40 | "but the PRIORITY-MARK and the tagged ones. Absolutely not."
accepted  T001/633:0 | Elena Marchetti  | 00:35:48 | "We already have this problem."
```

The labels are asked, answered, proposed, restated, accepted, challenged, deferred. The `answered` or `proposed` citation is the one that carries the content; the others establish standing and outcome. A claim or row with no `answered` or `proposed` citation is a defect.

A shell script (awk on the host, no new software) checks every citation: the utterance exists, the speaker matches the cue tag, the timestamp matches, and the quote is a subsequence of the concatenated fragment text. The skill runs this check on its own output and fixes failures before the dossier is presented. A citation that still fails at the write stage is a defect and blocks the write. That is what makes "a row I cannot check against the transcript is a defect" a mechanical test rather than a review habit.

In the registers the citations go in Source, which the model already reserves for "where the item came from". Open items carry them in Raised by since they have no Source column.

### Q3. What does the human review at each checkpoint, and what does approval mean?

There are two checkpoints per transcript. Each one is a file with a verdict per item. A blank verdict is "pending", and pending blocks the next stage. The approver writes their name and the date in the file header. Nothing moves on the strength of a conversation.

| Checkpoint | The human sees | Verdict per item | Approval means |
|---|---|---|---|
| Session sheet (after S0) | Transcript id, session date, domain and scope tags, and the attendee list drawn from the stakeholder register (4.6). Speakers already in the register appear with their recorded role, standing and decision authority, so the sheet shows who may accept a decision in this session and on which subjects. Speakers not in the register, and people named in the transcript as owners or deciders who are not present, appear as new stakeholder rows with a proposed role and the passage that suggested it. | Correct / Edit per attendee; Accept / Edit / Reject per new stakeholder row | The roles, standing and decision authority are right for everyone who spoke, and the stakeholder register is complete for this session. Every rule that depends on who spoke relies on this. |
| Dossier (after S1) | One document organised by episode. For each episode: title, span, outcome, topic, and everything it produced, with evidence inline: current-state claims, register rows, questions, links to existing claims and items, and conflicts with what the engagement already holds. Every item carries a grade: Confident, or Needs a human with the reason. A closing section lists the questions for the SMEs, the empty episodes, and the citation and integrity results. | Accept / Edit / Reject per item. Items graded Needs a human must each get a verdict. Items graded Confident may be approved in bulk per episode after reading, or individually. Questions get an answer or "raise an OI". Missed passages are added as new items. | Every item reads as true to the transcript, in the reviewer's judgement, every question has a disposition, and integrity failures I1 to I14 and I17 to I19 are zero or explicitly waived with a reason. |

The write stage (S3) runs only when both files carry an approver and date and no pending verdicts, the citation check passes on every approved item, and the integrity rules pass on the combined proposed set. It appends to the registers, the current-state record and the topic ledger, bumps the version of each document it touched, and writes a session log entry listing every id created or changed from that transcript.

**Grading.** An item is Confident when its content citation is from a speaker with standing on the subject, nobody challenged it in the exchange, it has no hedge, it does not conflict with an existing claim or item, and every field the register model requires at its status is either filled from the transcript or is one the reviewer always fills (Owner, MoSCoW, Scope). Anything else is Needs a human, and the reason is one of: hedged, contested, commitment not clearly accepted, standing unclear, authority check, conflicts with an existing claim or item, field needs a decision, kind uncertain between two types. The reasons are a controlled list so that the evaluation can count them.

**Fallback.** For an engagement or a transcript where the reviewer wants a slower path, the runbooks also describe a staged review, where the skill stops after episodes and candidates, again after current-state claims, and again after register rows. The files are the same; only the number of stops changes. The default is the dossier.

### Q4. How is extraction quality measured, and how does the measure improve the method?

**The reference.** A hand-marked transcript in the dossier format: episodes with outcomes, and per episode the claims, rows and questions with their citations. The first one is T001, marked by hand before the first automated run. After that, the approved dossier from every real session is the reference for that session, so the reference set grows with normal use and costs nothing extra.

**Matching.** A drafted episode matches a reference episode when their spans overlap by more than half. A drafted item matches a reference item when the kinds are the same and their cited utterance sets overlap. Matched items are then compared field by field.

**Four counts per kind, per run:**

| Count | Definition |
|---|---|
| Right | Matched, and the reviewer accepted kind, status, confidence and content without edit |
| Wrong | Matched, but kind, status, confidence or content needed an edit |
| Missed | In the reference, no match in the draft |
| Invented | In the draft, no match in the reference, or the citation check failed, or the reviewer judged the gist unsupported by the quote |

Two derived numbers matter most: invented per hundred drafted items, which must trend to zero, and missed per hundred reference items. Three further counts are reported on their own.

- Resurrections: reference items marked Retired or Current, not needed that the draft turned into a requirement or a current step.
- Empty episodes: episodes whose outcome demands an output and that produced none, which the scorer finds without a reference.
- Confident but wrong: items graded Confident that the reviewer edited or rejected. This is the number that governs the secondary goal. While it is above zero for a kind, that kind's grading rule is too loose and the review load stays where it is.

**The improvement loop.** Every Wrong, Missed, Invented or Confident-but-wrong item gets a failure-mode tag from a short controlled list (present-tense-as-requirement, hedge-as-fact, legacy-resurrected, vendor-intent-as-our-decision, consultant-restatement-as-fact, speaker-misattributed, exchange-split, episode-boundary, chatter-marked, overconfident-grade, and so on; the list grows as new modes appear). Each failure mode maps to one rule in the extraction rules file (5.3). Fixing a mode means editing that rule and attaching the failing passage as a test case under it. The rules file is versioned, every run records the rules version it used, and a run report compares the counts with the previous run on the same reference. A rule change that lowers any kind's Right count on an earlier reference is a regression and is reverted or explained. Where the disagreement turns out to be in the reference, the reference is corrected and that correction is logged too.

**Earning the reduction.** The human share of each dossier is the count of Needs-a-human items over all items. It falls in two ways: the grading rule for a kind is loosened when that kind's Confident-but-wrong count has been zero across a stated number of sessions, and it is tightened the first time it is not. Both moves are versioned changes to the rules file with the evidence attached. The reviewer always reads the whole dossier; what changes is how many items need an individual verdict.

This keeps the method's quality tied to evidence: the rules are the method, the references are the tests, and the run report is the score.

---

## 4. The current-state record

One file per domain, `current-state-<domain>.md`, versioned. It holds two element kinds. Every claim carries the same evidence and confidence fields.

### 4.1 Process (PRC-nnn)

| Field | Rule |
|---|---|
| ID | PRC plus zero-padded number. Never reused. |
| Title | What the process achieves, one line. |
| Trigger | The event that starts it, as stated. |
| Performed by | Role or team as stated. A named person only if the transcript names them as the performer. |
| Frequency | As stated ("every order", "monthly"). Blank if not stated; blank is not a defect, it is a question for the next session. |
| Systems | SYS ids touched. |
| Steps | Numbered claims PRC-nnn.s1, s2, and so on. Each step has: description, performed by, system, Status, Confidence, Evidence. |
| Status (per step, and for the whole process) | Current; Current, not needed (with the reason the SME gave); Retired (the SMEs no longer do it); Withdrawn (a later session or review showed the claim was wrong; keeps the id and says which claim replaced it). |
| Questions | Unresolved points, each with a citation and the OI id once raised. |

### 4.2 System (SYS-nnn)

| Field | Rule |
|---|---|
| ID | SYS plus zero-padded number. Never reused. |
| Name | The name the SMEs use. |
| Operated by | Us, Vendor, or a named third party. |
| Role today | One line. |
| Facts | Numbered claims SYS-nnn.f1, f2, and so on. Each fact has: Kind, description, Status, Confidence, Evidence. |
| Fact kind | Does (a capability in use); Holds (data it keeps); Cannot (a stated inability or constraint); Expected use (what the solution is expected to do with it). |
| Status | Current; Retired; Withdrawn. A Cannot fact about the vendor's platform that blocks a stated need also yields a LIM candidate. |

An Expected use fact with commitment language from our side also yields a REQ candidate linked `preserves` or `replaces`. Without commitment language it stays a fact and raises a question, since the brief says present-tense description is not a requirement.

### 4.3 Fields on every claim

| Field | Rule |
|---|---|
| Asserted by | Speaker and role from the session sheet. Where an architect or consultant restated and the SME confirmed, the SME is the asserter and the restatement is cited as `restated`. |
| Confidence | Stated (the speaker asserts it plainly about something they own or operate, and nobody challenged it in the exchange); Second-hand (asserted plainly about a system or practice the speaker does not own, for example the vendor describing NETCO's charging); Hedged (probably, I think, my guess, maybe, you'd have to ask); Contested (challenged in the exchange and not settled). Hedged and Contested claims are recorded so that the passage is not lost, but they raise a question and are excluded from the "current state as agreed" view until a later session or a reviewer answer upgrades them. |
| Evidence | One or more citations (Q2). |
| Episode | The episode id in which the claim was established or last changed. |
| Session | Transcript id and date of the session that established or last changed the claim. |

### 4.4 Links between registers and the record

Two relationship words are added to section 5 of the register model, proposed as version 2.16:

| From | Relationship | To |
|---|---|---|
| REQ | replaces | PRC-nnn.sN or SYS-nnn.fN (the requirement changes what happens today) |
| REQ | preserves | PRC-nnn.sN or SYS-nnn.fN (the requirement keeps something that works today) |

A link may target only a claim in Current or Current, not needed. Linking to a Retired or Withdrawn claim fails integrity rule I18 (below). Open items that exist to resolve a Hedged or Contested claim, or a question on a process, carry the claim id in Links as `clarifies PRC-nnn.sN`.

One integrity rule is added: **I18 Current-state links.** Every `replaces`, `preserves` and `clarifies` target exists in the current-state record, and no `replaces` or `preserves` target is Retired or Withdrawn. Failure.

### 4.5 Transcript register

`transcripts.md`, one row per transcript: id (T001), file name, session date, title, attendee STK ids, domain, session sheet approver and date, dossier approver and date, ingester and rules versions used.

### 4.6 Stakeholder register (STK-nnn)

`stakeholders.md`, one file per engagement, versioned. It is the single source of who people are, which side they are on, and what they have standing to speak about. The session sheet is derived from it, and the rules in 5.1 and R7 read standing from it rather than from the transcript alone.

| Field | Rule |
|---|---|
| ID | STK plus zero-padded number. Never reused. |
| Name | As the transcript renders it, with known variants (Martin, Marty) listed so that speaker tags and mentions resolve to one row. |
| Organisation | Us, Vendor, or a named third party. |
| Role | Internal SME, Internal architect, Internal other, Vendor, Consultant, Forum (a named approving body on our side, such as the SLT group), or Mentioned (named in a session but never present). |
| Standing | The systems, processes or domains this person owns or operates, as SYS or PRC ids where they exist, otherwise as text. R7 uses this to decide Stated against Second-hand. |
| Decides | The subjects on which this person may accept a decision in a session, as text or as scope values. For an Internal SME this is normally their area of expertise, so that a technical approach the SMEs agree on becomes a decision. For an Internal architect it is normally blank: their acceptance leaves a decision Proposed and sends it to a Forum row. A Forum row's Decides names what that body approves. R19 reads this field. |
| Status | Active; Left (no longer on the engagement, kept for attribution). |
| First seen | Transcript id where the person first spoke or was first named. |
| Sessions | Transcript ids where the person spoke. |
| Source | Citation for the passage that established the role or standing, or "engagement.md" if entered by hand. |
| Updated | Date of last change. |

**How it is maintained.** At S0 the shell script lists every speaker tag in the VTT and matches it against the register by name or variant. Matches are carried into the session sheet with their recorded role. Unmatched speakers become proposed rows with role blank. The skill then proposes a role and standing for each new speaker from what they say and how others address them, cites the passage, and also proposes Mentioned rows for people named as owners or deciders who did not speak ("someone from the business", "ask NETCO", a named colleague). All of that goes to the session sheet for the reviewer. A speaker with no confirmed role blocks S1, because every downstream rule depends on it. Standing can be extended in later sessions when a person reveals ownership of another system, and the skill proposes that as an edit with a citation in the dossier.

**Where names appear in the registers.** Owner, Raised by, Approved by and Consulted on register rows, and Performed by and Asserted by on claims, name a stakeholder by the name in the register, or use "Vendor: <name>", "Joint", or a forum name. One integrity rule is added, **I19 Known stakeholder**: every person named in those fields resolves to an STK row, and a row with Role Mentioned cannot be Owner. Failure.

---

## 5. Session structures and extraction method

### 5.1 Roles and standing

The stakeholder register (4.6) gives every speaker one role, a standing and a decision authority, and the session sheet carries them for the session. The rules use the role to decide what a statement can become, the standing to decide whether an assertion is Stated or Second-hand, and the Decides field to decide whether an acceptance makes a decision Accepted or leaves it Proposed. Authority belongs to people and subjects, never to the session as a whole.

| Role | Standing |
|---|---|
| Internal SME | Owns the current practice and the internal systems they operate. Their plain assertions about those are Stated. Their present-tense description never makes a requirement. Where their Decides field covers the subject, their acceptance of a technical approach in the session makes a DEC Accepted, with Approved by naming them and Decided on the session date (R19). |
| Internal architect | The design authority on our side (register model, section 1). Their commitment language makes a REQ or DEC candidate. Their restatement of an SME's words, confirmed by the SME, is the strongest form of a Stated claim. Their acceptance of a proposal in the session, whether from the vendor or from an SME, leaves the decision in Proposed with an OI to take it to the Forum named in the register, because their Decides field is normally blank. Usually Raised by on decisions and Owner on open items. Rarely Owner on a requirement, since the model gives that to whoever can say the need is met. |
| Internal other | Present, on our side, no specific standing. Treated as SME for systems they say they operate, otherwise as Second-hand. |
| Vendor | Owns the vendor platform. Their plain assertions about it are Stated; about NETCO or our systems, Second-hand. Their design intent ("the rule will be", "we need to support") is a DEC candidate in Proposed, raised by them, never Accepted from the transcript. Their Cannot facts that block a stated need yield a LIM candidate. |
| Consultant | Runs the session. Their restatements and summaries carry no standing until an SME, architect or vendor confirms them. A fluent consultant summary is the easiest thing to mistake for a fact. |

### 5.2 Speech acts and exchanges

Every utterance is read as one speech act: ask, assert, propose, restate, accept, challenge, defer, hedge, aside. An exchange is a run of utterances that opens with an ask or a propose and closes when the thread resolves or drifts. An exchange has an outcome:

| Outcome | Meaning |
|---|---|
| Answered and accepted | An assert or propose, then an accept from a party with standing. Yields a Stated claim, or a DEC if the accepted thing is a design: Accepted when the accepting party's Decides covers the subject, otherwise Proposed with an OI (R19). |
| Answered and challenged | An assert, then a challenge, no settlement. Yields Contested claims and a Question. |
| Deferred | Closes with a defer ("that needs business input", "you'd have to ask NETCO"). Yields an OI. |
| Hedged | The only answer is hedged. Yields a Hedged claim and a Question. |
| Unanswered | An ask with no assert before the thread drifts. Yields a Question. |

Speech acts and exchanges are the skill's working. They are kept in the session folder so that the reviewer can see how an item was reached and so that the scorer can tag failures, but they are not reviewed on their own. Items cite the parts of the exchange by role (Q2), and the rules in 5.6 read across those parts rather than across one speaker's words.

### 5.3 Episodes (Tnnn-Ennn)

An episode is a contiguous span of one session on one subject. The skill proposes the boundaries, title, span and outcome, and the dossier is organised by them. Every item carries its episode id.

| Field | Rule |
|---|---|
| ID | Transcript id plus E and a number: T001-E02. |
| Title | The subject, one line. |
| Span | First and last utterance, and timestamps. |
| Topic | The TOP id it belongs to (5.4), or "new". |
| Outcome | Settled (produced accepted claims or a proposed decision with internal acceptance); Parked (ended with an action for a named person or role); Unsettled (ended in disagreement or drifted); Informational (only described today); Aside (greetings, scheduling, jokes; produces nothing). |
| Outputs | Item ids in the dossier, and after the write stage the record and claim ids. |

Two completeness rules attach to outcomes. A Parked or Unsettled episode must yield at least one OI or Question. A Settled episode must yield at least one record row or claim. An episode that fails its rule is an empty episode and is listed in the dossier's closing section and in the run report.

### 5.4 Topic ledger (TOP-nnn)

`topics.md`, one file for the domain, versioned. A topic is a subject that recurs across sessions. Each topic row holds: id, title, scope value, the episodes that touched it in session order, the open items still outstanding on it, the decisions and requirements that closed parts of it, and a one-line current position. The skill proposes a match to an existing topic or a new topic for each episode, and the reviewer confirms in the dossier. The write stage appends the episode and the new ids to the topic.

The ledger is the cross-session view: which subjects have been discussed several times without settling, which questions to send to SMEs before the next session, and what each session added. It is a ledger rather than a pipeline stage, because it persists and is updated by every session rather than produced by one.

### 5.5 Stages

Within one transcript the method is a short pipeline: S0 to S3 in order, each stage rerunnable from its inputs. Across transcripts it is a ledger: the current-state record, the registers and the topic ledger persist and are updated by each session, Hedged claims get upgraded when a later session settles them, and open items raised in one session are closed by another. The pipeline feeds the ledger. Cross-session behaviour is designed on the ledger side and is never a batch job.

| Stage | Input | Output | Done by |
|---|---|---|---|
| S0 Prepare | VTT file, stakeholder register | `T001.utterances.tsv` (utterance, fragment, start, end, speaker, text) and `T001.session.md` with attendees matched to the register and unmatched speakers listed | Shell script from the ingester (awk). Deterministic. The skill then proposes role and standing for unmatched speakers and Mentioned rows for named absentees, with citations. Human confirms date, forum flag, scope and every attendee's role, and signs. |
| S1 Read | Utterance table, signed session sheet, stakeholder register, extraction rules, and the engagement's current-state record, registers and topic ledger | Working files: `T001.exchanges.md` (speech acts and exchanges), `T001.episodes.md`. The review file: `T001.dossier.md`, including any proposed standing extensions for known stakeholders. | The skill. It reads the whole transcript, produces the working files and the dossier, runs the citation checker and the integrity rules on its own output, fixes what it can, records what it cannot in the dossier's closing section, and stops for review. |
| S2 Review | The dossier | `T001.dossier.md` with verdicts, edits and a signed header | The human. |
| S3 Write | Signed session sheet and signed dossier | Updated registers, current-state record, topic ledger and stakeholder register, `T001.session-log.md`, version bumps | Shell script from the ingester. Refuses to run if any gate fails. |
| Evaluate | Dossier as drafted and the reference | `evaluation/T001-run-nn.md` with the counts in Q4 and the failure-mode tags | Shell scoring, human tagging |

In S1 the skill reads the engagement's existing records as context, not only as targets. It continues ids from the next free number, updates an existing claim rather than duplicating it, marks a conflict with an existing claim or item as Needs a human with the id, notes which open items the session closes, and says when an episode is the latest of several on a topic without a decision. It writes citations only in the Q2 form and writes "Question:" rather than fill a field it cannot support from the text.

### 5.6 Extraction rules (version 1, to be tested against the T001 reference)

These rules are the method. They live in `extraction-rules.md`, are versioned, and each one accumulates test passages from the evaluation loop.

| Rule | Statement |
|---|---|
| R1 Present tense is a claim | A statement in the present tense about what happens today, by any speaker, is a Process step or a System fact, never a requirement. |
| R2 Commitment makes a requirement | A REQ candidate needs commitment language about the solution ("we need the solution to", "must", "has to", "there would be an expectation that") from an internal architect or SME, or a vendor or consultant statement that an internal party accepts in the same exchange. A vendor's "we need to support" is design intent and becomes a DEC candidate in Proposed, raised by the vendor, or an OI if nothing was chosen. |
| R3 Hedges never become facts | Any assertion carrying "probably", "I think", "my guess", "maybe", "I'm not sure", or a deferral to someone else, is recorded with Confidence Hedged and yields a Question. It is never a Stated fact or a requirement. |
| R4 Disagreement is a question | Where an assertion is challenged in the exchange and the session does not settle it, both sides are recorded as Contested and a Question is raised. |
| R5 Legacy stays legacy | "Used to", "back in the day", "no longer", "not supported any more", "old way" mark a Retired claim. A Retired claim yields no requirement and no current step. |
| R6 Not needed is still current | "We do X but we don't need it" yields a claim with Status Current, not needed, and the reason quoted. It yields no requirement on its own. |
| R7 Standing sets confidence | A plain assertion about a system or practice the speaker owns or operates is Stated. A plain assertion about someone else's is Second-hand. A vendor's Cannot fact about their own platform that blocks a stated need also yields a LIM candidate with Identified on = session date. |
| R8 Explicit deferral is an open item | "That requires business input", "I can't make that decision", "someone needs to check" yields an OI candidate. The named party or role goes in the gist so the reviewer can set Owner. |
| R9 Asides are nothing | Greetings, scheduling, screen-share trouble and jokes are read as aside and grouped into Aside episodes. They produce no items, except that the reviewer can add any passage back. |
| R10 Quotes are verbatim | The quote keeps transcription errors and filler. Interpretation goes in the gist. A quote never spans two speakers. |
| R11 One item per assertion | An exchange that carries a fact and a deferral yields two items with overlapping citations. A single assertion is never split into two items. |
| R12 Vendor design rules are proposed decisions | A vendor describing how their build will behave ("the rule will always be") is a DEC candidate, Raised by the vendor. It is Accepted only under R19, by an internal party whose Decides covers the subject accepting it in the same exchange; otherwise it stays Proposed, Consulted blank, and needs an OI for our approval. Vendor acceptance of their own rule counts for nothing. |
| R13 Restatements borrow standing | An architect's or consultant's restatement ("so what you're saying is") carries no standing of its own. Confirmed by the SME or vendor it restates, it is cited as `restated` and the claim is asserted by the confirmer with Confidence Stated. Unconfirmed, it is a Question. |
| R14 Read the exchange, not the line | Kind, confidence and outcome are decided from the whole exchange (5.2). An assert that was challenged is Contested even if the assert itself is plain. An accept from a party without standing does not settle anything. |
| R15 Every episode pays its way | A Parked or Unsettled episode yields at least one OI or Question; a Settled episode yields at least one record or claim. An episode that yields nothing is flagged, never silently closed. |
| R16 Grade honestly | An item is Confident only when the conditions in Q3 all hold. When in doubt between Confident and Needs a human, choose Needs a human and give the reason. Overconfidence is a counted failure; caution is not. |
| R17 The ledger is context | Before proposing a claim or row, check the engagement's existing claims, items and topics. A match updates the existing id; a conflict is Needs a human with both ids; a closure names the open item it closes. |
| R18 Every voice is a known stakeholder | A speaker without a confirmed role in the stakeholder register blocks S1. A person named as an owner or decider who is not in the register is proposed as a Mentioned row with the citation, never silently used as an Owner. Standing is read from the register, and a session that reveals new standing proposes an edit with a citation rather than assuming it. |
| R19 Decisions follow authority | A DEC candidate is Accepted from the transcript only when an internal party whose Decides field covers the subject accepts it in the exchange. Then Approved by names that person, Decided on is the session date, and Consulted lists the other parties in the exchange. Where two or more SMEs with authority agree on a technical approach, that agreement is the acceptance. Acceptance by an architect, by an internal party without authority on the subject, or by the vendor leaves the DEC Proposed and raises an OI to take it to the Forum named in the stakeholder register. An accepted decision is always graded Needs a human with the reason "authority check", so the reviewer confirms the authority before it is written. |

---

## 6. Worked examples from T001

Each example shows the item as the dossier would present it, then what the write stage would produce from it on approval. Names are as they appear in the sanitised transcript. Episode ids assume T001-E01 "SEGMENT-TAG modes on legacy templates" and T001-E02 "Entity upgrade for multi-gig orders".

**Example 1: current practice plus deferral (R1, R8, R11). Episode T001-E02, exchange outcome Deferred.**

```
Item 14  System fact and Open item  Grade: Confident (fact); Needs a human: field needs a decision (OI owner)
proposed  T001/862:2-5 | Rafael Costa (Vendor) | 00:57:02 | "If it is cheaper to go as one port, then we keep it one port, but if it is the same ... I think 4 ports will will be ... more reasonable"
answered  T001/867:0-1 | Martin Vasquez | 00:57:18 | "We default to one port at the moment ... that's what we currently do."
deferred  T001/867:1-3 | Martin Vasquez | 00:57:22 | "We need someone from the business to, if they want to change that ... It doesn't require me making a decision."
```

On approval: `SYS-001.f1` on the internal orchestration, Kind Does, "Defaults a new premises-device request to one port", Status Current, Confidence Stated. And an OI, "Confirm whether the default premises-device port count should change from one to four", Raised by the deferred citation, with "business input" in the gist so the reviewer sets Owner. No requirement, because nobody committed the solution to anything. The vendor's preference for four ports is recorded on the OI as the option under discussion.

**Example 2: a fact with a hedged detail confirmed by the other party (R3, R7, R13, R14). Episode T001-E02.**

```
Item 21  System fact  Grade: Confident
asked     T001/919:0 | Rafael Costa (Vendor) | 01:00:47 | "We want support this scenario, like a..."
answered  T001/921:0-3, 922:0 | Martin Vasquez | 01:00:49 | "we definitely support service transfer to home hyper fast requesting the replacement of the legacy PREMISES-DEVICE ... I can see that in our code ... Yeah, so we currently do that."

Item 22  System fact, Second-hand  Grade: Needs a human: hedged
hedged    T001/921:4-5 | Martin Vasquez | 01:01:00 | "probably in that spreadsheet, it's probably like add ... add with notes or something like that"
answered  T001/920:0 | Rafael Costa (Vendor) | 01:01:06 | "As with, as with notes, yes."
Question: is the vendor's confirmation enough, or should the spreadsheet be checked?
```

Item 21 becomes a Stated fact asserted by Martin. In item 22 the exchange rule makes the vendor the answerer, since Martin hedged and Rafael confirmed against his own spreadsheet. The mapping name "add with notes" is proposed as Second-hand, asserted by the vendor, and the reviewer decides. Without the exchange reading, a draft would have recorded "add with notes" as a fact on Martin's authority.

**Example 3: a guess that must not become a fact (R3, R8). Episode T001-E02, exchange outcome Hedged.**

```
Item 23  Open item  Grade: Needs a human: field needs a decision (owner)
hedged    T001/926:0-2, 931:0-3 | Martin Vasquez | 01:01:15 | "my guess for ACCESS-TYPE-B, and again, guessing, you'd have to ask NETCO or SME ... my suspicion is like, well, they probably just go ..."
```

On approval: an OI, "Confirm with NETCO how connect-outstanding is handled for ACCESS-TYPE-B service transfers." Nothing enters the current-state record.

**Example 4: a vendor design rule and a third-party commercial fact (R12, R7). Episode T001-E02.**

```
Item 17  Decision (Proposed)  Grade: Needs a human: commitment not clearly accepted
proposed  T001/699:0-3, 709:0-3, 711:4 | Rafael Costa (Vendor) | 00:43:17 | "the rules will be basically first check the available capacity of the existing entity as is. If it is sufficient, we will use it. If not, then, and there is a free port, then are we eligible for upgrades ... If not ... we must go with a new entity."
No internal acceptance found in the exchange.

Item 18  System fact, Second-hand  Grade: Needs a human: standing unclear
answered  T001/711:0-3 | Rafael Costa (Vendor) | 00:44:58 | "this would be NETCO will not charge us anything extra, because actually there may be an special charge, that's fine, but we are not actually paying anything"
Question: verify the charging rule with NETCO before the decision is accepted?
```

Item 17 becomes a DEC in Proposed: "Entity selection on a capacity-driven order: reuse if sufficient, else free upgrade if eligible, else new entity", Raised by Rafael Costa (Vendor), Implemented by Vendor, with an OI in Links for our approval. Had Martin, as the SME whose Decides covers order orchestration, accepted the rule in the same exchange, R19 would have made it Accepted with Approved by Martin Vasquez and Decided on the session date, graded Needs a human for the authority check. Item 18 becomes a fact on SYS NETCO, Confidence Second-hand.

**Example 5: commitment language from an architect (R2). Episode T001-E01.**

```
Item 05  Requirement  Grade: Needs a human: field needs a decision (MoSCoW, Owner); kind uncertain (one requirement or two)
proposed  T001/165:3-4, 166:0-3, 168:0 | Elena Marchetti | 00:09:25 | "If we're going to bring the services onto the new platform, there would be an expectation that we'd be able to modify this. or if not, have some process bringing them into a state in which they can be modified ... We need a, we need a process, right?"
```

Elena is an Internal architect on the session sheet, so her commitment language stands on its own. On approval: a REQ in Draft, "Legacy PRIORITY-MARK and tagged services migrated to the new platform can be modified, or are brought to a modifiable state by a defined process", Raised on = session date, Owner suggested as Elena Marchetti, MoSCoW for the reviewer. The gist records the two alternatives Elena stated so the reviewer can split it into two requirements. Nothing enters the current-state record, because this passage describes an expectation, not today.

**Example 6: a full exchange yielding a Cannot fact and a self-raised action (R7, R8, R14). Episode T001-E01, outcome Answered and accepted, then Parked.**

```
Item 11  System fact, Cannot  Grade: Confident
asked     T001/630:1-2 | Elena Marchetti | 00:35:34 | "Do you know if we support these templates natively out of CONFIG-MGMT then?"
answered  T001/631:0, 632:0 | Martin Vasquez | 00:35:40 | "but the PRIORITY-MARK and the tagged ones. Absolutely not."
accepted  T001/633:0 | Elena Marchetti | 00:35:48 | "We already have this problem."

Item 12  Open item  Grade: Needs a human: field needs a decision (owner; Elena Marchetti suggested)
deferred  T001/635:0-1 | Elena Marchetti | 00:35:56 | "we should look into what our current state is, I suppose"
```

Item 11 becomes `SYS-002.f3` on CONFIG-MGMT: Kind Cannot, "Does not natively support PRIORITY-MARK or tagged templates", Stated, asserted by Martin. Item 12 becomes an OI to establish which imported services use those templates.

**Example 7: legacy product behaviour that is transparent today (R1, R6, R2). Episode T001-E01.**

```
Item 09  System fact and Question  Grade: Confident (fact); Needs a human: commitment not clearly accepted (question)
asked     T001/421:0-1 | Martin Vasquez | 00:25:29 | "so do we know if they're PRIORITY-MARK priority or just tagged?"
answered  T001/445:0-4, 450:0-3, 454:0-2 | Daniel Okonkwo | 00:26:02 | "It doesn't come in at all, right? It's transparent to us. It is tagged on the HANDOFF ... We need to know about it because it's important that we can support the customer ... but we don't really care a whole lot about it"
Question: is representing the tagged mode on the service model a requirement of ours?
```

On approval: a fact on the LEGACY-CARRIER handoff, tagging is applied on the handoff and translated before it reaches us, Stated by Daniel as the SME. "We need to know about it" is not commitment language about the solution, so no requirement is proposed. If the reviewer answers the question yes, the write stage creates the REQ with `preserves` pointing at the fact.

---

## 7. Project layout, runtime and runbooks

### 7.1 Two independent parts

The project is split into the ingester, which holds the mechanism, and the engagements, which hold everything produced for a client. The ingester contains nothing that belongs to one client. An engagement contains nothing that describes how ingestion works. Either can change without touching the other, and an engagement folder can be handed over, archived or deleted on its own.

```
solution-register/                 the git repository
  .claude/skills/ingest-transcript/SKILL.md
                                     the ingest skill, at the root so that
                                     Claude Code finds it; part of the ingester
  ingester/                          the how
    README.md                        what the ingester is and how to run it
    extraction-solution-design.md    this document
    solution-register-model.md       the register model
    extraction-rules.md              the rules in 5.6, with test passages
    bin/                             stage driver and shell scripts
    runbooks/                        S0.md to S3.md, staged-review.md, evaluate.md
    templates/                       session sheet, dossier, register headers,
                                     current-state record, topic ledger, engagement.md
    VERSION
  engagements/
    <engagement-name>/               the what, for one client
      engagement.md                  client, domain, scope taxonomy, glossary of
                                     system names, ingester version
      stakeholders.md                stakeholder register (4.6)
      transcripts/                   the VTT files as received
      transcripts.md                 transcript register (4.5)
      current-state-<domain>.md      current-state record (4)
      topics.md                      topic ledger (5.4)
      registers/                     the six registers
      sessions/T001/                 utterance table, session sheet, exchanges,
                                     episodes, dossier, session log
      evaluation/                    hand-marked references and run reports
      logs/                          one log per skill run
```

The ingester is versioned as a whole with a `VERSION` file, and the rules file carries its own version. Every session log in an engagement records both, so a row in a register can always be traced to the mechanism that produced it. The ingester never reads from an engagement except the one it was given.

### 7.2 Runtime

Ingestion is a Claude Code session started from the repository root. The user drops a VTT file into `engagements/<engagement-name>/transcripts/` and invokes the ingest skill with the engagement name, for example `/ingest-transcript puppy-gloves`. The skill assigns the next transcript id and runs S0 through the shell scripts, then stops for the session sheet. On the next invocation it finds the signed session sheet, performs S1 in full, and stops with the dossier. On the next invocation it finds the signed dossier and runs S3. If it finds an unsigned file it says so and stops. It never advances past an unsigned gate, and it never edits a signed file. If the reviewer rejects the dossier outright, the skill re-reads with the reviewer's notes as additional context and produces a new dossier version.

The skill file lives at `.claude/skills/ingest-transcript/SKILL.md` in the repository root, where Claude Code discovers project skills, and it is versioned with the ingester. It resolves the ingester and the engagement by relative path from the root, and the engagement's `engagement.md` records which ingester version it was last run with so that a mismatch is visible.

Two arrangements were tested on 10 September 2026 with Claude Code 2.1.266. A session started in `engagements/puppy-gloves/` did find a root-level skill, so no symlink or `CLAUDE.md` pointer is needed, but its reads into `ingester/` fell outside the working directory and were refused in non-interactive mode, with or without a project settings entry. A session started at the repository root read both the ingester and the engagement without any grant. The root is therefore the working directory, and the engagement name is an argument to the skill.

Everything the skill and the scripts write goes inside the engagement folder: the utterance table, session sheet, working files, dossier, session log, run reports, and a log file per skill run under `logs/` naming the stage, the ingester and rules versions, the files read and written, and the outcome. Nothing is written to the ingester during ingestion. Rule changes that come out of evaluation are made to the ingester deliberately, by hand, as a versioned change.

### 7.3 Runbooks

One markdown file per stage in `ingester/runbooks/`, with the same headings in the same order: purpose, inputs, command, outputs, automatic checks, what the reviewer does, what approval means, what to do on rejection. `staged-review.md` describes the fallback path in Q3, where S1 stops three times. The skill follows the runbooks, and a person can follow them without the skill. A driver script `ingester/bin/stage` takes the transcript id and the stage name, runs the stage's shell command, runs its checks, and refuses to start a stage whose predecessor is not signed. The runbooks are the operator's view and the scripts are their implementation, and both are versioned together.

### 7.4 What runs where

Shell scripts from the ingester handle S0, the citation check, integrity rules, S3, the topic ledger update and scoring, using awk, sed and grep only. Judgement at S1 is Claude Code running the skill, and the skill calls the shell checks on its own output. No software is installed on the host and, since Claude Code is already present, Docker is not needed for this design. Every stage reads and writes markdown or TSV, so a person can run any stage by hand following the runbooks and the rules file.

---

## 8. Evaluation plan for the first run

1. Adam hand-marks T001 in the dossier format. That is the reference, version 1.
2. S0 runs on T001. Adam approves the session sheet.
3. S1 runs with rules version 1. The dossier as drafted is scored against the reference before review, so the score reflects the method and not the reviewer's corrections.
4. Adam reviews the dossier. Each disagreement between draft and reference gets a failure-mode tag, and each Confident item that needed an edit is tagged overconfident-grade.
5. The run report is written to `evaluation/T001-run-01.md`. Rules are edited, version 2, with the failing passages attached as tests. Steps 3 and 4 repeat as run 02.
6. Nothing is written to the registers until the run Adam accepts. The accepted run's signed dossier is the input to S3.

The second transcript, when one exists, is not hand-marked in advance. Its approved dossier is its reference, so the marking effort per session becomes the review itself.

---

## 9. Changes proposed to the register model (version 2.16)

Applied to `solution-register-model.md` on approval of this design, 10 September 2026.

- Section 4.1 Source: add "a transcript citation in the form `Tnnn/utterance:fragments | speaker | timestamp | quote`, one per exchange part".
- Section 4.1 Approved by and section 4.2 Decision: Approved by may name a stakeholder register row with Role Forum.
- Section 5: add `REQ replaces claim`, `REQ preserves claim`, `OI clarifies claim`.
- Section 9: add I18 Current-state links and I19 Known stakeholder.
- No new item types.

---

## 10. Files, versions, assumptions and questions

### 10.1 Files

| File | Where | Purpose | Versioning |
|---|---|---|---|
| `BRIEF.md` | root | The brief | As is |
| `ingester/solution-register-model.md` | ingester | Register model | 2.15 now, 2.16 with section 9 changes |
| `ingester/extraction-solution-design.md` | ingester | This document | 1.0, approved |
| `ingester/extraction-rules.md` | ingester | The rules in 5.6 with test passages and the grading conditions | Bumped on every change; recorded in every run report and session log |
| `ingester/VERSION` | ingester | Version of the mechanism as a whole | Bumped on any change to skill, scripts, runbooks or templates |
| `.claude/skills/ingest-transcript/SKILL.md` | root | The ingest skill, part of the ingester | With the ingester |
| `ingester/runbooks/S0.md` to `S3.md`, `staged-review.md`, `evaluate.md` | ingester | Operator runbooks | With the ingester |
| `ingester/bin/` | ingester | Shell scripts for S0, citation check, integrity, S3, ledger update, scoring, the stage driver | With the ingester |
| `ingester/templates/` | ingester | Empty session sheet, dossier, registers, current-state record, topic ledger, engagement.md | With the ingester |
| `engagement.md` | engagement | Client, domain, scope taxonomy, glossary, ingester version last used | Bumped on every change |
| `stakeholders.md` | engagement | Stakeholder register: who people are, their side, role, standing and decision authority | Bumped by S3, or by hand with Source "engagement.md" |
| `transcripts/` | engagement | VTT files as received | Never edited |
| `transcripts.md` | engagement | Transcript register | Bumped on every row |
| `topics.md` | engagement | Topic ledger | Bumped by S3 |
| `current-state-<domain>.md` | engagement | Current-state record | Bumped by S3 |
| `registers/*.md` | engagement | Six registers | Bumped by S3 |
| `sessions/Tnnn/` | engagement | Utterance table, session sheet, exchanges, episodes, dossier versions, session log | Each file carries its own version |
| `evaluation/` | engagement | Reference marking and run reports | Reference versioned; runs numbered |
| `logs/` | engagement | One log per skill run | Append only |

The two existing files `solution-register-model.md` and `T001-SANITISED-TechnicalSyncUp.vtt` move into `ingester/` and `engagements/<first-engagement>/transcripts/` respectively when the layout is created. The project lives in the git repository `solution-register` (remote `github.com/snuffpuppet/solution-register`), with `ingester/` and `engagements/` as its two top-level folders. One repository holds both parts; the folder boundary keeps them independent.

### 10.2 Assumptions and decisions

All settled on approval, 10 September 2026, unless marked open.

1. **Recommendation B for Q1.** A separate current-state record with `replaces` and `preserves` links. Confirmed.
2. **Claims are the traceable grain**, sub-numbered under a process or system (PRC-003.s2, SYS-001.f4). Confirmed.
3. **Retired practice is recorded**, with status Retired, so that it can be checked and cannot be resurrected silently. Confirmed.
4. **One current-state record and one topic ledger per domain**, following the scope taxonomy. Open: the domain name for T001 is set on the session sheet at S0.
5. **The session date for T001** is 8 September 2026, the Tuesday before approval, as given by Adam. To be confirmed on the session sheet at S0.
6. **Speaker roles for T001 are settled during ingestion.** The stakeholder register starts empty for puppy-gloves, S0 lists the seven speakers, the skill proposes a role, standing and decision authority for each with citations, and the reviewer confirms on the session sheet. There is no session-level approving forum flag. Authority sits with people and subjects: SMEs can accept decisions within their area of expertise, architects normally cannot and their acceptance goes to the SLT group as an OI (4.6 Decides, R19).
7. **Claude Code is the runtime.** All judgement is the ingest skill inside a Claude Code session started at the repository root, with the engagement name as the skill's argument. No API key, no Docker, no other software. Confirmed.
8. **One git repository, `solution-register`, holds both parts.** Created 10 September 2026. Confirmed.
9. **The first hand-marked reference is made by Adam** before the first run, in the dossier format. Confirmed.
10. **One dossier review per transcript is the default**, with the staged three-stop path available as a fallback. Confirmed.
11. **Bulk approval of Confident items** is allowed per episode after the reviewer has read them. Confirmed. A kind's grading rule may be loosened after three sessions with zero Confident-but-wrong for that kind.
12. **Skill discovery.** Tested 10 September 2026 (7.2). The skill lives at the repository root under `.claude/skills/`, no symlink, and the session starts at the root.
13. **The first engagement folder is `engagements/puppy-gloves/`.** Confirmed. T001 lives in its `transcripts/` folder.

The next step is the implementation plan covering the folder layout, the skill, the shell scripts, the runbooks, the rules file, the templates and the reference marking template.

---

## 11. Change log

| Version | Date | Change |
|---|---|---|
| 0.1 | 10 September 2026 | First draft. |
| 0.2 | 10 September 2026 | Meaning is read at the level of the exchange: speech-act tags, exchange outcomes, citations labelled by exchange part. Roles gain standing, with Internal architect and Consultant distinct. Sessions are segmented into episodes with outcomes and completeness rules. Topic ledger added for cross-session subjects. Pipeline within a transcript and ledger across transcripts named separately. Runbooks per stage added. Worked examples rewritten in exchange form. |
| 0.3 | 10 September 2026 | Project split into `ingester/` (the mechanism) and `engagements/<name>/` (everything produced for one client), each independent of the other. Claude Code running an ingest skill from the engagement folder is the runtime. Docker model-call scripts and the API key removed. All outputs, logs and artefacts confined to the engagement folder. |
| 0.4 | 10 September 2026 | Goals and principles added (1): primary goal semantic correctness, secondary goal less human effort, inference first. Three judgement stops collapsed into one whole reading (S1) and one dossier review (S2), organised by episode with evidence inline; the staged path kept as a fallback. Every item graded Confident or Needs a human with a controlled reason (Q3, R16). Confident-but-wrong count added and made the governor of review reduction (Q4). The engagement's existing records read as context, with conflicts and closures surfaced (5.5, R17). Speech acts and exchanges kept as working files, not reviewed on their own. Stages renumbered S0 to S3. Worked examples show grades. Questions 10 and 11 added. |
| 0.5 | 10 September 2026 | Stakeholder register added as an engagement file (4.6): STK ids, organisation, role, standing, Mentioned rows for named absentees. S0 matches speakers against it and the skill proposes roles and standing for new ones with citations; a speaker without a confirmed role blocks S1 (R18). Integrity rule I19 Known stakeholder. Session sheet derived from the register. Repository named as `solution-register`; first engagement named `puppy-gloves`. Questions 6, 8 and 13 settled or reframed. |
| 1.0 | 10 September 2026 | Approved. The session-level approving forum flag is replaced by decision authority on the stakeholder register (4.6 Decides, Role Forum) and rule R19: SMEs accept decisions within their area, architect acceptance leaves a decision Proposed with an OI to the SLT group. R12 and the session sheet updated to match, and "authority check" added to the Needs-a-human reasons. Skill discovery tested: the skill lives at the repository root under `.claude/skills/` and the session starts at the root with the engagement name as argument (7.2). T001 session date recorded as 8 September 2026. Register model 2.16 changes applied. Section 10.2 questions closed. |
