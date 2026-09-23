# Extraction rules

Version 1.7, 23 September 2026.

These rules are the method. The skill reads them before S1 and applies them to every exchange. Each rule carries the failure modes that map to it (design Q4) and a table of test passages. When a run report tags a failure against a rule, the fix is made here: the statement is edited and the failing passage is added as a test passage under the rule, with the run that found it. A rule change that lowers any kind's Right count on an earlier reference is a regression and is reverted or explained in the change log. Every test passage citation passes `ingester/bin/check-citations` against its own engagement: passages added in 1.0 are from `puppy-gloves` T001, and passages added in 1.4 are from `techm-bss` T001 and T002, and passages added in 1.6 from `techm-bss` T003, and passages added in 1.7 from `techm-bss` T004.

## Roles and standing

Read from the signed session sheet, never from the transcript alone (design 5.1).

**Sources of requirements and decisions.** An engagement may say, in `engagement.md` under Who makes requirements and decisions, who may be the source of a requirement or decision in each kind of session (in techm-bss: only business stakeholders in business sessions; the Architecture team also for technical, integration and non-functional requirements in architecture sessions). That section overrides the table below, R2, R12 and R19. Anyone who is not a source in the session at hand yields no REQ or DEC. Their commitment language or design intent is an OI or a Question for the business, their acceptance settles nothing, and they are never Raised by, Owner or Approved by on a requirement or decision. Open items are fine for them. Their plain statements about systems they know are still Stated claims. The section may also allow programme-level and architecture decisions from people who are not a source of business ones (techm-bss: Program and Architecture). Read the kind of session from the signed session sheet, check the section before proposing any REQ or DEC, and never raise it as a ruling.

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

A statement in the present tense about what happens today, by any speaker, is a Process step or a System fact, never a requirement. Which it is, and which process it belongs to, is decided at S4 from the whole session (R20 to R25): at S1 a present-tense statement about how work is done is carried as a candidate for S4, and only a statement about what a system does, holds or cannot do is a System fact. A system doing its turn inside a flow ("an application will be created in CMS") is a step with the system as actor, and is recorded as a System fact as well only when it is also stated as a capability.

**Failure modes:** present-tense-as-requirement

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/867:0-1 \| Martin Vasquez \| 00:57:18 \| "We default to one port at the moment ... that's what we currently do." | SYS fact, Kind Does, Status Current. No REQ. | 1.0 | Design example 1 |

### R2 Commitment makes a requirement

A REQ candidate needs commitment language about the solution ("we need the solution to", "must", "has to", "there would be an expectation that") from an internal architect or SME who is a source of requirements (Roles and standing, Sources of requirements and decisions), or a vendor or consultant statement that an internal party accepts in the same exchange. A vendor's "we need to support" is design intent and becomes a DEC candidate in Proposed, raised by the vendor, or an OI if nothing was chosen. Every REQ drafted in Draft links, in the same dossier, an open item that tracks its agreement (`approval tracked by item nn`), with an Owner who runs the agreement: one open item may cover all the requirements a session drafts. Integrity rule I3 refuses a Draft requirement without one, and it only sees an item once it has a verdict, so the link is made at S1, never after review.

**Failure modes:** non-source-requirement, req-without-approval-oi

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | proposed \| T001/165:2-4, 166:0-3, 168:0 \| Elena Marchetti \| 00:09:25 \| "If we're going to bring the services onto the new platform, there would be an expectation that we'd be able to modify this. or if not, have some process bringing them into a state in which they can be modified ... We need a, we need a process, right?" | REQ in Draft from an Internal architect. Grade Needs a human: field needs a decision; kind uncertain. | 1.0 | Design example 5, range corrected |
| T003 (techm-bss) | proposed \| T003/6665:0-4 \| Abhishek Sinha \| 00:56:13 \| "At least the basic functionalities of AI that are supported and are part of the licensing should be included in the solution. However, there are customizations and more details, and there's a costing implication or development implications that can be taken out separately or maybe suggested separately." | No REQ: an Internal architect in a business session is not a source of requirements (engagement.md). At most an OI or a Question for the business. | 1.6 | T003 run 01, item 60 rejected |
| T003 (techm-bss) | proposed \| T003/5674:0-3 \| Shekhar Anil Tankhiwale \| 00:49:19 \| "Would it be right for me to say ABB knows every customer and contact once, understands who they represent, and consistently gives the right person the right access to right account, site, and service across every channel? Would that be the right future state, right statement to describe future state?" | No DEC: the vendor is not a source of decisions in a business session. An OI putting the statement to the business. | 1.6 | T003 run 01, item 52 rejected |
| T004 (techm-bss) | proposed \| T004/9832:2-5 \| Jason Bednar \| 01:24:21 \| "So what I would like to see is basically in the enterprise space in particular is something very similar to how it operates today with source, right? So I want to see something that comes from that point of sale that flows into a system that basically looks at it at that order." | REQ in Draft from a BE&G SME, with Links carrying `approval tracked by item nn` to an open item in the same dossier. Drafted with no such open item for any of the seven T004 requirements, so I3 failed once verdicts were given and the open item was added after review. | 1.7 | T004 run 01, reference item 144 missed |

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

"That requires business input", "I can't make that decision", "someone needs to check" yields an OI candidate. The named party or role goes in the gist, and is proposed as the Owner when it resolves to a person in the stakeholder register whose Role is not Mentioned. Where it does not, the Owner is proposed from whoever raised the deferral; it is never left blank.

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

The quote keeps transcription errors and filler. Interpretation goes in the gist. A quote never spans two speakers. A name the transcription has garbled so that nobody in the session can say what it refers to is quoted as spoken but never attached to a guessed system or element: the claim waits for a Question to identify it. A garbled form of a term the register already knows ("white sales" for Wide Sales, "MBN" for NBN, "Opticom" for Opticomm) is quoted as spoken, and the Gist names the term it stands for; a conflict with an existing claim is never raised on the garbled wording alone.

**Failure modes:** speaker-misattributed, unknown-term-kept, transcription-noise-unglossed

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T003 (techm-bss) | answered \| T003/5136:1-4, 5143:0-1 \| Nikki Kovacevic \| 00:44:51 \| "Digitally, no, we can't do that because everything does sit separate without like outside of CMS. So our digital channels are within a platform which we call Text Inc. and that sits outside of CMS. There is no way to track anything obviously of that. like the customer information, they have to input their full name, address and date of birth." | A Question on what "Text Inc" is. Drafted as a claim placed on SYS-0008 Live chat, which the reviewer dropped because nobody knows what Text Inc is. | 1.6 | T003 run 01, item 48 rejected |
| T004 (techm-bss) | answered \| T004/4632:0-1 \| Haylee Oates \| 00:42:53 \| "No, so technically white sales is CMS. It is a just looks prettier than what it was. It is still a module of CMS. However, the applications, once they're submitted," | SYS fact on Wide Sales, a module running in CMS as its sales interface, with the Gist saying "white sales" is Wide Sales. Drafted without the gloss and raised as a conflict with SYS-0001.f3. | 1.7 | T004 run 01, item 53 edited |
| T004 (techm-bss) | answered \| T004/7058:4-5 \| Haylee Oates \| 01:03:15 \| "Most of the ordering process is all done via APIs to the third party, so mobiles to Opticom to MBN." | SYS fact on CMS ordering by API, with the Gist saying "MBN" is NBN and "Opticom" is Opticomm. Drafted without the gloss. | 1.7 | T004 run 01, item 79 edited |

### R11 One item per assertion

An exchange that carries a fact and a deferral yields two items with overlapping citations. A single assertion is never split into two items. The exception is a narrated sequence: an assertion that tells several actions in turn yields one step per action under R20.

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

A follow-up session is read against the outstanding set as much as against the transcript. Before segmenting, build that set from the item files: open items not Closed, risks not Realised or Retired, decisions in Proposed, requirements in Draft, limitations in Identified or Under assessment, claims Hedged or Contested, and every Question under Questions for the SMEs in the earlier dossiers under `sessions/`. `index/outstanding.md` sections 1 to 6 hold the same set, regenerated at every S3.

This is what clears a hedged claim and an open Question, and it is the reason neither asks for a verdict at S2. A claim recorded as Hedged or Contested, and a Question, is complete work the moment it is written: the passage is kept and the uncertainty recorded, and nothing enters the current state as agreed. The reviewer cannot resolve the hedge from the transcript either. A later session or a reviewer's answer upgrades it (design section 4). Read the transcript with the set in hand. A member the session touches yields a mutation item; an on-subject member the session never reaches is listed under Closing, Outstanding not reached, so the reviewer can see what is still open.

A mutation is an item block whose `- Target:` is an existing id. The block carries only the fields that change, each as it should read afterwards, with the citations that justify the change. The Gist states every change as `Field: old to new` so the reviewer judges it without opening the file. The write stage sets the fields, adds the citations to Source (Raised by on an open item) or to the claim's evidence, and appends one History line (F10) recording each old and new value.

The moves the model allows, and what each needs in the block. A move that needs a companion record is two items in one dossier, the new one referred to as `item nn`.

| Type | Move | Block carries |
|---|---|---|
| OI | Open, In progress or Blocked to Closed | Status Closed, Resolution (the id or `item nn` of the record it produced, or `No record: <reason>`), Closed on, Next action if it changes. Never reopen a Closed item; raise a new one. |
| OI | to Blocked, or out of it | Status, Blocked by (set when entering, cleared to blank when leaving), Next action |
| OI | Owner, Next action or Due changes | The changed field only |
| DEC | Proposed to Accepted or Rejected | Status, Approved by (a person or forum on our side whose Decides covers it, R19), Decided on, Consulted if it grows |
| DEC | Accepted to Superseded | Status Superseded and `Links: superseded by item nn` on the old one; a new DEC in the same dossier. An Accepted decision changes in no other way. |
| REQ | Draft to Agreed, Designed, Delivered, Verified, Deferred or Withdrawn | Status, MoSCoW or Phase if they change, Owner if it changes |
| LIM | Identified to Under assessment | Status, Impact, `Links: assessed by <OI or item nn>` with an open item that carries the owner |
| LIM | Under assessment to Accepted | Status, Options (at least two), Chosen option, Disposition record (a DEC in Accepted, or `item nn`) |
| LIM | Under assessment to Resolved | Status, evidence in the citations |
| RSK | Identified to Mitigating | Status, Trigger, Mitigation, Due as the next review |
| RSK | to Realised | Status Realised, `Links: realised as item nn` with a new OI in the same dossier |
| RSK | to Retired | Status Retired, Mitigation carrying the one-line reason |
| RSK | Likelihood, Impact or Mitigation changes | The changed field only |
| Claim | Hedged or Contested to Stated | Confidence, with the confirming citation as new evidence |
| Claim | Current to Retired, or to Current, not needed | Status, with the citation (R5, R6) |

**Failure modes:** none yet

**Test passages:**

None yet.

### R18 Every voice is a known stakeholder

A speaker without a confirmed role in the stakeholder register blocks S1. A person named as an owner or decider who is not in the register is proposed as a Mentioned row with the citation, never silently used as an Owner. Standing is read from the register, and a session that reveals new standing proposes an edit with a citation rather than assuming it.

**Failure modes:** none yet

**Test passages:**

None yet.

### R19 Decisions follow authority

A DEC candidate is Accepted from the transcript only when an internal party whose Decides field covers the subject, and who is a source of decisions (Roles and standing), accepts it in the exchange. Then Approved by names that person, Decided on is the session date, and Consulted lists the other parties in the exchange. Where two or more SMEs with authority agree on a technical approach, that agreement is the acceptance. Acceptance by an architect, by an internal party without authority on the subject, or by the vendor leaves the DEC Proposed and raises an OI to take it to the Forum named in the stakeholder register. An accepted decision is always graded Needs a human with the reason "authority check", so the reviewer confirms the authority before it is written.

**Failure modes:** none yet

**Test passages:**

None yet.

### R20 A sequence is steps

Rules R20 to R25 are applied at S4 (runbook S4) over the whole session, never exchange by exchange. A passage that tells several actions in turn ("once we get a quote ... we'll then send that ... we'll then go back and ... sent for approval") yields one PRC.step per action, each with its own actor and system, and each `follows` the one before. The citation of a step keeps the continuation clause that carries the next action ("then the following morning ..."); trimming it loses the next step. A later retelling of an action already recorded is the same step: its citations join that step's evidence, and a retelling that adds detail between two steps adds a step between them.

**Failure modes:** step-collapsed, retelling-duplicated

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/6727:0-3, 6734:0, 6739:0 \| Ryan Morley \| 00:52:41 \| "Once we get a quote from our vendor, that'll then come back and typically we'll then send that to the commercial team to then give us a sell price. ... If we're using Quozal, we'll have said input the price, and... Sent for approval, sent to the customer." | Five steps in non-standard pricing: vendor returns quote; consultant sends it to commercial; commercial returns a sell price; consultant keys it into Quosal; consultant sends for approval, handing to the Quosal sale. Drafted by 0.9.1 as one step, with 6739 dropped. | 1.4 | Audit, PRC-0006 |
| T001 | answered \| T001/9045:0-3 \| Ryan Morley \| 01:11:17 \| "Then the following morning, when in the morning, the team leaders will then go run a Power BI report and that'll capture all the orders placed the day before, we then take that dump into Excel or whatever." | Two steps performed by team leaders (run the report; dump it into Excel) following the order submission. Drafted by 0.9.1 with the citation cut at 9045:0, so neither step was recorded. | 1.4 | Audit, PRC-0007 |

### R21 A process runs from its trigger to its outcome

A process is identified by who starts it, its trigger and its outcome (design 4.1). A statement belongs to a process only when it moves that trigger towards that outcome. A capability, a segment, a tool or a condition is not a process: commission capture, multi-site selling and agreement capture are steps or variants of the sale they happen in, and a segment or tool that does the same flow differently is a variant recorded with `when`. A statement that belongs to no process in the record starts a new one, or is raised as a Question; it is never placed in the nearest process. Before proposing a process, match it against the existing processes by trigger and outcome, not by the interviewer's heading.

A handoff to another function is a process boundary: where the work passes to a team in another part of the business (sales hands a signed quote to service delivery, which answers to operations) and that team works on to an outcome of its own, the two halves are two processes, linked by `hands-to`, Downstream and Upstream, even when one speaker tells both halves in one breath. Where the evidence does not show who owns the second half or what it ends in, keep one process and raise a Question on the boundary; a later session that shows it splits the process under S4 step 2 (a new process, the moved claims Withdrawn with `replaced-by`), so nothing is lost by waiting.

**Failure modes:** step-misfiled

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/7039:0-3 \| Tim Greening \| 00:55:05 \| "if we did a price rise would create 10 new plans and update our plan group and make white cells display that." | Steps in a mass-market price change process, not in non-standard pricing approval. Drafted by 0.9.1 as PRC-0006.s3. | 1.4 | Audit, PRC-0006 |
| T001 | answered \| T001/7992:3 \| Ryan Morley \| 01:02:54 \| "Then they send it to service delivery via e-mail." | The boundary between two processes: the business quote through Quosal ends by handing to service delivery, and business order delivery starts here. Drafted by 0.9.1 as one process, PRC-0002, with the delivery steps inside it. | 1.4 | Audit, PRC-0002; boundary set by Adam Moyes |

### R22 Statements about a process are facts

A statement about a process that is not an action is a PRC.fact with Kind Rule (a condition, a routing rule, an SLA), Volume, Timing (a duration or a wait) or Pain point, and names in `follows` the step it qualifies when there is one. It is never a step. A pain point that threatens delivery also yields a RSK candidate as today.

**Failure modes:** statement-as-step

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/4485:0-3 \| Ryan Morley \| 00:35:21 \| "For internal approval, we have an internal three-hour SLA for somebody in my team to approve that quote" | PRC.fact, Kind Rule, on the approval step of the Quosal sale. Drafted by 0.9.1 as PRC-0002.s7. | 1.4 | Audit, PRC-0002 |
| T001 | answered \| T001/6845:0-4 \| Antony Murphy \| 00:53:36 \| "So doing a mass market price change is probably the most annoying thing to do in this joint. So regularly have issues, regularly have processes that just break because it's getting so big." | PRC.fact, Kind Pain point, on the mass-market price change process. Drafted by 0.9.1 as a step in non-standard pricing, PRC-0006.s2. | 1.4 | Audit, PRC-0006 |

### R23 Every step has an actor

"We", "they", "someone in my team" and a passive verb are resolved to a role or team from the passage, the episode and the session sheet. When they cannot be resolved, performed-by is `unresolved` and a Question asks who does it. An actor is never supplied by inference beyond the transcript. A system that does its turn is the actor of that step.

**Failure modes:** actor-unresolved

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | hedged \| T001/5629:0-3, 5632:0 \| Chris Van Horn \| 00:44:12 \| "So that's, we then have to export the data out of CMS through BI to find that commission override information to. Validate the sale to live chat." | Step with performed-by unresolved ("we"), Hedged from 5629:0, plus a Question on who validates live chat sales. Drafted by 0.9.1 with an invented performer, "Residential sales operations". | 1.4 | Audit, PRC-0003 |

### R24 Standing follows whose work it is

A step is Stated when the speaker, or the team the speaker belongs to, performs it. When the speaker describes another team's work, however plainly, the step is Second-hand and graded Needs a human: standing unclear. The walkthrough agenda lists every Second-hand step under the role that performs it, so the next session can hear it from them.

**Failure modes:** standing-by-speaker

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/10740:3, 10750:0-1, 10762:0-1 \| Ryan Morley \| 01:25:33 \| "then they would typically call up or send through a cancellation form. Then the Customs Service person will then have to sort of calculate, typically calculate what the cancellation charge will be. generate an invoice, tell the customer to pay it, cancel the service." | Five steps of mid-contract cancellation, one by the customer and four by customer service, all Second-hand, because a Business Sales team leader describes what customers and customer service do. Drafted by 0.9.1 as one Stated step. | 1.4 | Audit, PRC-0009 |

### R25 Gaps and contradictions are questions

After a flow is assembled, walk it from trigger to outcome. Each of these is a Question aimed at the role that performs the step, and a line on the walkthrough agenda: two steps with no stated handoff between them; no step that reaches the outcome; an unresolved actor (R23); an item on an interviewer's checklist that nobody answered; a flow told only by an architect or consultant and never confirmed by someone who does it (R13). Two tellings in the same session that disagree are Contested on both sides with a Question (R4), even when they are far apart in the transcript.

**Failure modes:** flow-gap-unraised

**Test passages:**

| Transcript | Citation | Expected | Added in | Note |
|---|---|---|---|---|
| T001 | answered \| T001/12148:0-2 \| Farid Kakar \| 01:37:36 \| "We send the CIS before the customer signed up" | Contested, against the next passage, with a Question on when the CIS is sent. Drafted by 0.9.1 as a Stated fact (SYS-0013.f3) beside a Stated step saying the opposite (PRC-0010.s2). | 1.4 | Audit, PRC-0010 |
| T001 | answered \| T001/12268:0-2 \| Ryan Morley \| 01:38:35 \| "if it's through wide sales, they agree to the terms and conditions. We then send them a copy of the CIS, the critical information summary." | Contested, against the passage above. | 1.4 | Audit, PRC-0010 |
| T002 | answered \| T002/7412:0-3 \| John McCarthy \| 01:00:39 \| "So the leads captured by Aussie Broadband Wholesale will then drop into Symbio's HubSpot instance and enable those leads to be pushed through the funnel by the Symbio sales team." | Contested against T002/8821:0-3 ("farmed out by the head of sales operations to the various partner managers"), with a Question on which route ABB Wholesale leads take. Drafted by 0.9.1 as two Stated steps, PRC-0014.s3 and s4. | 1.4 | Audit, PRC-0014 |
| T002 | answered \| T002/5682:0-3 \| Jacque Greet \| 00:46:13 \| "well, actually the other thing that we do when a lead comes in, we check to see whether it's already in the system and has an owner. If it has an owner, then we forward that lead on to the same owner." | A correction that inserts a step before the wash spoken first: this step comes first in the flow, and the wash `follows` it. Drafted by 0.9.1 in spoken order. | 1.4 | Audit, PRC-0013 |

## Grading conditions

An item is **Confident** only when every condition holds (design Q3, R16):

- [ ] Its content citation (`answered` or `proposed`) is from a speaker whose standing on the session sheet covers the subject.
- [ ] Nobody challenged it in the exchange.
- [ ] It carries no hedge word or deferral.
- [ ] It does not conflict with an existing claim or item in the engagement.
- [ ] Every field the register model requires at its status is filled. Owner and MoSCoW are **proposed**, not left blank: an Owner from the person who raised the item or whose Decides covers the subject, a MoSCoW from the strength of the commitment language, with the Gist saying the value is a proposal. A blank Owner on a requirement or open item, or a blank MoSCoW on a requirement, is not Confident and is not cautious: `check-integrity` I3 and I2 fail the whole dossier at S3, and R17 makes correcting a wrong proposal a one-line mutation.

Anything else is **Needs a human** with exactly one reason from this list, so the evaluation can count them:

- hedged
- contested
- commitment not clearly accepted
- standing unclear
- authority check (always given to a DEC accepted from the transcript under R19)
- conflicts with an existing claim or item
- field needs a decision (a field that genuinely cannot be proposed from the transcript and the session sheet, not a field left blank)
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
| step-collapsed | R20 |
| retelling-duplicated | R20 |
| step-misfiled | R21 |
| statement-as-step | R22 |
| step-as-system-fact | R1 |
| flow-out-of-order | R20 |
| actor-unresolved | R23 |
| standing-by-speaker | R24 |
| flow-gap-unraised | R25 |
| non-source-requirement | R2 |
| unknown-term-kept | R10 |
| transcription-noise-unglossed | R10 |
| req-without-approval-oi | R2 |

## Change log

| Version | Date | Change |
|---|---|---|
| 1.7 | 23 September 2026 | From T004 run 01 (techm-bss): tags transcription-noise-unglossed (R10) and req-without-approval-oi (R2) added. R10 now requires a garbled form of a known term to be glossed in the Gist and never raised as a conflict on the garbled wording; R2 now requires every Draft requirement to link an open item in the same dossier that tracks its agreement, so integrity rule I3 passes before review. Test passages from T004 items 53 and 79, edited at review, and reference item 144, added after review. Tags given by Adam Moyes. |
| 1.6 | 23 September 2026 | From T003 run 01 (techm-bss): tags non-source-requirement (R2) and unknown-term-kept (R10) added; R10 now keeps an unidentifiable name out of any claim until a Question identifies it; test passages from T003 items 48, 52 and 60, all rejected at review. Tags given by Adam Moyes. |
| 1.5 | 23 September 2026 | Sources of requirements and decisions by kind of session: an engagement may say who is a source of requirements and decisions (techm-bss: only business stakeholders in business sessions, the Architecture team also for technical, integration and non-functional requirements in architecture sessions), overriding the role table, R2, R12 and R19; non-sources raise open items. Given by Adam Moyes at T003 S2, after the T003 dossier drafted a requirement from an architect and proposed Program owners for decisions. |
| 1.4 | 23 September 2026 | Processes built as flows at S4 from the whole session: R20 a sequence is steps, R21 a process runs from its trigger to its outcome, R22 statements about a process are facts, R23 every step has an actor, R24 standing follows whose work it is, R25 gaps and contradictions are questions. R1 narrowed so that S4 decides step or fact; R11 gains the narrated-sequence exception. Nine failure-mode tags added. R21 treats a handoff to another function as a process boundary, at Adam Moyes's direction on the first flow reference (the Quosal quote and business order delivery are two processes). Test passages from the audit of all 17 techm-bss processes (`process-audit-T001-T002.md`), which found flows told across up to nine episodes and recorded as compound steps, statements and system facts. |
| 1.3 | 18 September 2026 | Owner and MoSCoW are proposed at S1 rather than left blank for the reviewer, because the integrity gate fails a blank one at S3 while the grading conditions called it Confident (grading condition 5, R17). Hedged and Contested claims and Questions stated as complete work cleared by the outstanding set, not as items awaiting a verdict (R17). From the first end-to-end run, T001 techm-bss, 17 September 2026. |
| 1.1 | 10 September 2026 | Scope dropped from the grading conditions (register model 2.17). |
| 1.0 | 10 September 2026 | First version: R1 to R19 from design 1.2 section 5.6, grading conditions from Q3, test passages seeded from design section 6 with two ranges corrected (see design-review-notes.md). |
