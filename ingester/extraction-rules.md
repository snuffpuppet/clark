# Extraction rules

Version 1.0, 10 September 2026. Owner: Adam Moyes. Implements `extraction-solution-design.md` 1.2 sections 5.1, 5.2, 5.6 and Q3. Recorded in every run report and session log.

These rules are the method. The skill reads them before S1 and applies them to every exchange. Each rule carries the failure modes that map to it (design Q4) and a table of test passages. When a run report tags a failure against a rule, the fix is made here: the statement is edited and the failing passage is added as a test passage under the rule, with the run that found it. A rule change that lowers any kind's Right count on an earlier reference is a regression and is reverted or explained in the change log. Every test passage citation passes `ingester/bin/check-citations`.

## Roles and standing

Read from the signed session sheet, never from the transcript alone (design 5.1).

| Role | Standing |
|---|---|
| Internal SME | Owns the current practice and the internal systems they operate. Their plain assertions about those are Stated. Their present-tense description never makes a requirement. Where their Decides field covers the subject, their acceptance of a technical approach in the session makes a DEC Accepted, with Approved by naming them and Decided on the session date (R19). |
| Internal architect | The design authority on our side (register model, section 1). Their commitment language makes a REQ or DEC candidate. Their restatement of an SME's words, confirmed by the SME, is the strongest form of a Stated claim. Their acceptance of a proposal in the session, whether from the vendor or from an SME, leaves the decision in Proposed with an OI to take it to the Forum named in the register, because their Decides field is normally blank. Usually Raised by on decisions and Owner on open items. Rarely Owner on a requirement, since the model gives that to whoever can say the need is met. |
| Internal other | Present, on our side, no specific standing. Treated as SME for systems they say they operate, otherwise as Second-hand. |
| Vendor | Owns the vendor platform. Their plain assertions about it are Stated; about NETCO or our systems, Second-hand. Their design intent ("the rule will be", "we need to support") is a DEC candidate in Proposed, raised by them, never Accepted from the transcript. Their Cannot facts that block a stated need yield a LIM candidate. |
| Consultant | Runs the session. Their restatements and summaries carry no standing until an SME, architect or vendor confirms them. A fluent consultant summary is the easiest thing to mistake for a fact. |

## Speech acts and exchange outcomes

Every utterance is one speech act: ask, assert, propose, restate, accept, challenge, defer, hedge, aside. An exchange opens with an ask or a propose and closes when the thread resolves or drifts (design 5.2).

| Outcome | Meaning |
|---|---|
| Answered and accepted | An assert or propose, then an accept from a party with standing. Yields a Stated claim, or a DEC if the accepted thing is a design: Accepted when the accepting party's Decides covers the subject, otherwise Proposed with an OI (R19). |
| Answered and challenged | An assert, then a challenge, no settlement. Yields Contested claims and a Question. |
| Deferred | Closes with a defer ("that needs business input", "you'd have to ask NETCO"). Yields an OI. |
| Hedged | The only answer is hedged. Yields a Hedged claim and a Question. |
| Unanswered | An ask with no assert before the thread drifts. Yields a Question. |

## Rules

Statements are verbatim from design 5.6. Failure-mode tags are the controlled list the run report uses; the list grows as new modes appear and every new tag is mapped to one rule here.

### R1 Present tense is a claim

A statement in the present tense about what happens today, by any speaker, is a Process step or a System fact, never a requirement.

**Failure modes:** present-tense-as-requirement

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/867:0-1 \| Martin Vasquez \| 00:57:18 \| "We default to one port at the moment ... that's what we currently do." | SYS fact, Kind Does, Status Current. No REQ. | 1.0 | Design example 1 |

### R2 Commitment makes a requirement

A REQ candidate needs commitment language about the solution ("we need the solution to", "must", "has to", "there would be an expectation that") from an internal architect or SME, or a vendor or consultant statement that an internal party accepts in the same exchange. A vendor's "we need to support" is design intent and becomes a DEC candidate in Proposed, raised by the vendor, or an OI if nothing was chosen.

**Failure modes:** none yet

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | proposed \| T001/165:2-4, 166:0-3, 168:0 \| Elena Marchetti \| 00:09:25 \| "If we're going to bring the services onto the new platform, there would be an expectation that we'd be able to modify this. or if not, have some process bringing them into a state in which they can be modified ... We need a, we need a process, right?" | REQ in Draft from an Internal architect. Grade Needs a human: field needs a decision; kind uncertain. | 1.0 | Design example 5, range corrected |

### R3 Hedges never become facts

Any assertion carrying "probably", "I think", "my guess", "maybe", "I'm not sure", or a deferral to someone else, is recorded with Confidence Hedged and yields a Question. It is never a Stated fact or a requirement.

**Failure modes:** hedge-as-fact

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | hedged \| T001/926:0-2, 931:0-3 \| Martin Vasquez \| 01:01:15 \| "my guess for ACCESS-TYPE-B, and again, guessing, you'd have to ask NETCO or SME ... my suspicion is like, well, they probably just go ..." | OI only. Nothing enters the current-state record. | 1.0 | Design example 3 |

### R4 Disagreement is a question

Where an assertion is challenged in the exchange and the session does not settle it, both sides are recorded as Contested and a Question is raised.

**Failure modes:** none yet

**Test passages:**

None yet.

### R5 Legacy stays legacy

"Used to", "back in the day", "no longer", "not supported any more", "old way" mark a Retired claim. A Retired claim yields no requirement and no current step.

**Failure modes:** legacy-resurrected

**Test passages:**

None yet.

### R6 Not needed is still current

"We do X but we don't need it" yields a claim with Status Current, not needed, and the reason quoted. It yields no requirement on its own.

**Failure modes:** none yet

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/445:0-4, 450:0-3, 454:0-2 \| Daniel Okonkwo \| 00:26:02 \| "It doesn't come in at all, right? It's transparent to us. It is tagged on the HANDOFF ... We need to know about it because it's important that we can support the customer ... but we don't really care a whole lot about it" | Stated fact on the LEGACY-CARRIER handoff. "We need to know about it" is not commitment about the solution: Question, no REQ. | 1.0 | Design example 7 |

### R7 Standing sets confidence

A plain assertion about a system or practice the speaker owns or operates is Stated. A plain assertion about someone else's is Second-hand. A vendor's Cannot fact about their own platform that blocks a stated need also yields a LIM candidate with Identified on = session date.

**Failure modes:** none yet

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/711:0-3 \| Rafael Costa (Vendor) \| 00:44:58 \| "this would be NETCO will not charge us anything extra, because actually there may be an special charge, that's fine, but we are not actually paying anything" | Fact on SYS NETCO, Confidence Second-hand, grade Needs a human: standing unclear. | 1.0 | Design example 4 |

### R8 Explicit deferral is an open item

"That requires business input", "I can't make that decision", "someone needs to check" yields an OI candidate. The named party or role goes in the gist so the reviewer can set Owner.

**Failure modes:** none yet

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | deferred \| T001/867:1-3 \| Martin Vasquez \| 00:57:22 \| "We need someone from the business to, if they want to change that ... It doesn't require me making a decision." | OI, gist names "business input" so the reviewer sets Owner. | 1.0 | Design example 1 |

### R9 Asides are nothing

Greetings, scheduling, screen-share trouble and jokes are read as aside and grouped into Aside episodes. They produce no items, except that the reviewer can add any passage back.

**Failure modes:** chatter-marked

**Test passages:**

None yet.

### R10 Quotes are verbatim

The quote keeps transcription errors and filler. Interpretation goes in the gist. A quote never spans two speakers.

**Failure modes:** speaker-misattributed

**Test passages:**

None yet.

### R11 One item per assertion

An exchange that carries a fact and a deferral yields two items with overlapping citations. A single assertion is never split into two items.

**Failure modes:** none yet

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/867:0-1 \| Martin Vasquez \| 00:57:18 \| "We default to one port at the moment ... that's what we currently do." | Two items from one exchange: the fact (this citation) and the OI (R8 citation), overlapping at 867:1. | 1.0 | Design example 1 |

### R12 Vendor design rules are proposed decisions

A vendor describing how their build will behave ("the rule will always be") is a DEC candidate, Raised by the vendor. It is Accepted only under R19, by an internal party whose Decides covers the subject accepting it in the same exchange; otherwise it stays Proposed, Consulted blank, and needs an OI for our approval. Vendor acceptance of their own rule counts for nothing.

**Failure modes:** vendor-intent-as-our-decision

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | proposed \| T001/699:0-3, 709:0-3, 711:4 \| Rafael Costa (Vendor) \| 00:43:17 \| "the rules will be basically first check the available capacity of the existing entity as is. If it is sufficient, we will use it. If not, then, and there is a free port, then are we eligible for upgrades ... If not ... we must go with a new entity." | DEC in Proposed, Raised by the vendor, Implemented by Vendor, OI for our approval. Grade Needs a human: commitment not clearly accepted. | 1.0 | Design example 4 |

### R13 Restatements borrow standing

An architect's or consultant's restatement ("so what you're saying is") carries no standing of its own. Confirmed by the SME or vendor it restates, it is cited as `restated` and the claim is asserted by the confirmer with Confidence Stated. Unconfirmed, it is a Question.

**Failure modes:** consultant-restatement-as-fact

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | hedged \| T001/921:4-5 \| Martin Vasquez \| 01:01:00 \| "probably in that spreadsheet, it's probably like add ... add with notes or something like that" | With the vendor's confirmation at 920:0, the vendor is the answerer and the claim is Second-hand. | 1.0 | Design example 2 |

### R14 Read the exchange, not the line

Kind, confidence and outcome are decided from the whole exchange (5.2). An assert that was challenged is Contested even if the assert itself is plain. An accept from a party without standing does not settle anything.

**Failure modes:** exchange-split

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/631:0, 632:0 \| Martin Vasquez \| 00:35:40 \| "but the PRIORITY-MARK and the tagged ones. Absolutely not." | Cannot fact on CONFIG-MGMT, Stated, Confident, read with the ask at 630:1-2 and the accept at 633:0. | 1.0 | Design example 6 |

### R15 Every episode pays its way

A Parked or Unsettled episode yields at least one OI or Question; a Settled episode yields at least one record or claim. An episode that yields nothing is flagged, never silently closed.

**Failure modes:** episode-boundary

**Test passages:**

None yet.

### R16 Grade honestly

An item is Confident only when the conditions in Q3 all hold. When in doubt between Confident and Needs a human, choose Needs a human and give the reason. Overconfidence is a counted failure; caution is not.

**Failure modes:** overconfident-grade

**Test passages:**

None yet.

### R17 The ledger is context

Before proposing a claim or row, check the engagement's existing claims, items and topics. A match updates the existing id; a conflict is Needs a human with both ids; a closure names the open item it closes.

**Failure modes:** none yet

**Test passages:**

None yet.

### R18 Every voice is a known stakeholder

A speaker without a confirmed role in the stakeholder register blocks S1. A person named as an owner or decider who is not in the register is proposed as a Mentioned row with the citation, never silently used as an Owner. Standing is read from the register, and a session that reveals new standing proposes an edit with a citation rather than assuming it.

**Failure modes:** none yet

**Test passages:**

None yet.

### R19 Decisions follow authority

A DEC candidate is Accepted from the transcript only when an internal party whose Decides field covers the subject accepts it in the exchange. Then Approved by names that person, Decided on is the session date, and Consulted lists the other parties in the exchange. Where two or more SMEs with authority agree on a technical approach, that agreement is the acceptance. Acceptance by an architect, by an internal party without authority on the subject, or by the vendor leaves the DEC Proposed and raises an OI to take it to the Forum named in the stakeholder register. An accepted decision is always graded Needs a human with the reason "authority check", so the reviewer confirms the authority before it is written.

**Failure modes:** none yet

**Test passages:**

None yet.

## Grading conditions

An item is **Confident** only when every condition holds (design Q3, R16):

- [ ] Its content citation (`answered` or `proposed`) is from a speaker whose standing on the session sheet covers the subject.
- [ ] Nobody challenged it in the exchange.
- [ ] It carries no hedge word or deferral.
- [ ] It does not conflict with an existing claim or item in the engagement.
- [ ] Every field the register model requires at its status is filled from the transcript, or is one the reviewer always fills (Owner, MoSCoW, Scope).

Anything else is **Needs a human** with exactly one reason from this list, so the evaluation can count them:

- hedged
- contested
- commitment not clearly accepted
- standing unclear
- authority check (always given to a DEC accepted from the transcript under R19)
- conflicts with an existing claim or item
- field needs a decision
- kind uncertain between two types

When in doubt between Confident and Needs a human, choose Needs a human. Overconfidence is a counted failure; caution is not.

**Loosening.** A kind's grading rule may be loosened only after three consecutive sessions in which that kind's Confident-but-wrong count was zero (design 10.2 item 11). The change is made here with the run reports cited.

**Tightening.** The first session in which a kind's Confident-but-wrong count is above zero tightens that kind's rule here, with the failing items attached as test passages under the rule they broke.

## Failure-mode tags

The controlled list for run reports. Each maps to one rule.

| Tag | Rule |
|---|---|
| present-tense-as-requirement | R1 |
| hedge-as-fact | R3 |
| legacy-resurrected | R5 |
| chatter-marked | R9 |
| speaker-misattributed | R10 |
| vendor-intent-as-our-decision | R12 |
| consultant-restatement-as-fact | R13 |
| exchange-split | R14 |
| episode-boundary | R15 |
| overconfident-grade | R16 |

## Change log

| Version | Date | Change |
|---|---|---|
| 1.0 | 10 September 2026 | First version: R1 to R19 from design 1.2 section 5.6, grading conditions from Q3, test passages seeded from design section 6 with two ranges corrected (see design-review-notes.md). |
