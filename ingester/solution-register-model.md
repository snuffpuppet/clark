# Solution register model

Version 2.18, 10 September 2026. Owner: Adam Moyes. Version 2.17 removed the Scope field, the scope taxonomy and integrity rule I5. Version 2.18 removes the change request type (to return in a later version when needed), makes ids four digits, adds Segment and Department to the stakeholder register, and replaces the register tables with one file per item plus generated index tables (section 7). Both at Adam's direction on review, 10 September 2026.

This file describes how we track the artifacts of solution architecture on a project where we are the design authority and a vendor builds the platform. It is tool-agnostic. It says what the item types are, how they relate, how each one moves, and what a healthy register looks like. It does not say how to build or populate the registers in any particular tool; that belongs in a separate runner document.

Diagrams in `diagrams/` show the same model: `day-in-the-life` (six things that happen on the project and how each runs through the registers), `management-flow` (one requirement followed through the registers) and `artifact-workflow` (the open item queue and the limitation disposition). The day-in-the-life diagram is generated from `diagrams/src/day_in_the_life_gen.py`.

---

## 1. Purpose and context

We specify a solution. The solution is ours and is wider than the vendor's platform: some of it is designed and built internally. The vendor architects, designs and builds their platform in collaboration with us and is consulted on our decisions; our own stakeholder groups and SMEs are consulted too. Approval always sits with us.

Our architects produce solution design documents and need to track, from our perspective:

- requirements
- decisions
- limitations
- risks
- open items

The vendor keeps their own registers with their own ids, costs and timelines. We do not mirror those. We hold our view and reference theirs.

The goal is a set of registers that a person can open during a meeting and see what is outstanding, and that can be maintained by hand with a few minutes of effort per item.

## 2. Principles

**Open items are the working queue. Everything else is a record.**
An open item closes only by creating or changing a record: a decision gets accepted, a limitation gets dispositioned, a requirement gets clarified, a risk gets retired. In a meeting we review one filtered list of open items. The registers behind them stay stable.

**A limitation must be dispositioned, and each disposition links to a record.**
A limitation leaves "Under assessment" by exactly one path, and each path names the record that carries the outcome. The choice between living with it, working around it, and asking the vendor for a change is made on the limitation, in its Options. Asking for a change is recorded as a decision with Implemented by Vendor and the vendor's own reference in Vendor ref; we do not carry a change request register of our own in this version.

**Registers and narrative are separate.**
Registers hold items. Solution design documents hold narrative and reference items by id. A design document never holds the master copy of an item. This is what lets design documents be split per service, per customer service, or combined, without changing how tracking works.

**Every item traces to a source.**
Not every item begins with a requirement. Each item records where it came from, and that is enough.

## 3. Entry points

Four kinds of thing come in, and the question beside each one picks the type.

| Entry | Question | Usually becomes |
|---|---|---|
| Requirement | We need the solution to do X. | REQ |
| Discovery | The platform does, or does not, do X. | LIM if a need is now unmet; DEC if we must now design a certain way; OI first if uncertain |
| Ask | A stakeholder wants X changed. | OI, then REQ or DEC |
| Event | A risk lands, an assumption fails, a review finds a gap. | OI, then whatever record the work produces |

Asks and events are work first and record later. Requirements and discoveries can go straight to a record.

## 4. Item types

### 4.1 Header fields (every item)

| Field | Rule |
|---|---|
| ID | Type prefix plus a four-digit zero-padded number, e.g. REQ-0014, DEC-0003, LIM-0021, RSK-0007, OI-0045. Never reused. Transcript ids are three digits (T001) and episode ids are the transcript id plus E and a number (T001-E02). |
| Title | One line, specific. |
| Status | One of the values for the type (4.2). |
| Owner | A named person on our side, or "Vendor" plus a named vendor contact, or "Joint". Required on every requirement and open item that is not in a terminal state. Not used on decisions, limitations or risks, which carry Raised by instead. While a decision is Proposed or a limitation is Under assessment, the open item driving it carries the owner. Risks have no standing owner; they are reviewed on their review date by the routine in section 10, and a realised risk raises an open item. |
| Implemented by | Vendor, Internal or Both. Whose build the item lands in. Required on requirements, decisions and limitations. Optional on risks and open items. |
| Vendor ref | The vendor's id for the corresponding item, if one exists. Otherwise blank. Not used on decisions; a vendor document reference goes in Source. |
| Links | Ids of related items, with the relationship word (5). |
| Next action | Required on open items that are not Closed. Not used on any other type; the open item driving a record carries it. |
| Due | Date for the next action, on open items. On a risk, Due is the date the risk is next reviewed, and is required while the risk is not in a terminal state. Not used on other types. |
| Source | Where the item came from: a design document and section, a knowledge base claim id, a meeting date, a vendor document reference, or a transcript citation in the form `Tnnn/utterance:fragments | speaker | timestamp | quote`, one per exchange part. Not used on open items, where Raised on and Raised by carry it. |
| Updated | Date of last change. |

### 4.2 Types, states and type-specific fields

Terminal states are marked *.

| Type | Prefix | States | Type-specific fields |
|---|---|---|---|
| Requirement | REQ | Draft, Agreed, Designed, Delivered, Verified*, Deferred*, Withdrawn* | MoSCoW (Must / Should / Could / Won't), Phase (this phase / next phase), Raised on (date the need was stated) |
| Decision | DEC | Proposed, Accepted, Superseded*, Rejected* | Rationale (short, naming the rejected option where there was one), Raised by (who proposed it), Consulted (vendor, SMEs, stakeholder groups who had input), Approved by (the person or forum on our side who made it stick; a forum is a stakeholder register row with Role Forum), Decided on (date of acceptance or rejection) |
| Limitation | LIM | Identified, Under assessment, Accepted*, Resolved* | Identified on (date), Impact (one line: what it means for the customer or the operation), Options (numbered list, each `n. <option>; impact: <cost and time, or effort and who>; phase: <phase>`; accept it, work around it manually and ask the vendor for a change are the usual options), Chosen option (the option number), Disposition record (id of the DEC that carries the outcome) |
| Risk | RSK | Identified, Mitigating, Realised*, Retired* | Identified on (date), Raised by (person, or the review it came from), Likelihood (L/M/H), Impact (L/M/H), Trigger (the observable event that says the risk has become real), Mitigation (what is being done, as text) |
| Open item | OI | Open, In progress, Blocked, Closed* | Raised on (date), Raised by (person, or the meeting or review it came from), Blocked by (an id or a short reason, while Blocked), Resolution (id of the record it produced or changed), Closed on (date) |

### 4.3 Use it when

| Type | Use when |
|---|---|
| Requirement | We need the solution to do something. Owned by whoever stated the need, usually the SME or stakeholder who raised it, because they can say whether it has been met. |
| Decision | We chose how, or accepted a constraint. See 4.5. |
| Limitation | The solution will not do, or does differently, something we need. A fact about the solution, not a piece of work. Title says what the solution does; Impact says why we care; Options says what we could do about it and Chosen option says what we decided. |
| Risk | Something might go wrong, or an assumption is unverified and would hurt if wrong. A record, not a piece of work: it carries who raised it and a review date, and the weekly routine reviews it. Mitigation actions are open items with their own owners. Anyone who sees the trigger happen raises an open item and the risk moves to Realised. |
| Open item | Someone must do something before a record can change. The only thing you work. |

### 4.4 Transition rules

- Requirement: the Owner is the person who stated the need, and Raised on is when they stated it. MoSCoW is required from Draft onwards. Won't means agreed as out of this project and is recorded rather than deleted; a need wanted later is Must, Should or Could with Phase = next phase. A requirement row carries no next action: work to get it agreed, designed or verified is an open item in Links, and a requirement in Draft must have one. Designed means a section of a design document, ours or the vendor's, covers it, and Source or Links points at that section. A decision link is needed only where a real choice was made. Most requirements never have a decision.
- Decision: while Proposed, an open item in Links carries the owner, next action and due date; the decision row itself has none. Accepted or Rejected needs Approved by, Decided on and at least one Consulted entry, and Approved by is ours. Accepted is immutable. To change an accepted decision, create a new one, mark the old one Superseded, and write "superseded by DEC-nnn" in the old one's Links.
- Limitation: Identified on is set when the row is created. Under assessment needs an open item in Links carrying the owner and next action. Impact, at least two Options, each with an impact and a phase, and a Chosen option must be filled before the limitation leaves assessment by Accepted; a vendor estimate is an input to Options, not a state. From Under assessment, exactly one of Accepted (the chosen option is to live with it, to work around it, or to ask the vendor for a change; needs a DEC id, and where the choice is a vendor change the DEC has Implemented by Vendor and carries the vendor's reference in Vendor ref once they assign one) or Resolved (needs evidence in Source or Links; no options needed). The disposition is written in Disposition record; Links holds the other relationships (constrains, introduced by, the assessing open item). If the vendor later declines a requested change, the accepting DEC is Superseded by a new one and the limitation is dispositioned again.
- Risk: Identified on and Raised by are set when the row is created. Mitigating needs Trigger and Mitigation filled and a Due date for the next review; the review happens in the weekly routine, and whoever runs it updates Likelihood, Impact, Mitigation and the next Due. Realised is set when the Trigger is observed, and must create an OI. Retired needs a one-line reason in Mitigation. Mitigation is text on the row; there is no "mitigated by" link. Where the mitigation is a decision, Links carries "raised by DEC-nnn" or the DEC carries "raises", and that is enough.
- Open item: Blocked needs Blocked by, either the id of the item it is waiting on or a short reason, and it is cleared when the item leaves Blocked. Closed needs a Resolution id and Closed on. If nothing was produced, the Resolution says "No record: <reason>" and that is acceptable but should be rare.

### 4.5 When to write a decision

A requirement says what the solution must do. A decision records a choice or an accepted trade-off. Write a decision only when at least one of these is true:

- There was a real choice between viable options, and you picked one.
- It constrains later design, such as a principle or standard other decisions must follow.
- It accepts something: a limitation you live with or work around, a risk you carry knowingly, a vendor constraint you design around. The decision's Rationale names the limitation's chosen option and the options it beat.
- Someone will later ask "why did we do it this way?" and the answer is more than "the requirement said so".

Do not write a decision to restate a requirement, to put a requirement in or out of a phase (that is the requirement's Phase and Agreed status), or for the vendor's routine implementation detail (that lives in their design document; add a Vendor ref on our requirement if it matters).

**Discovery: decision or limitation?** Ask one question: after this, is something we need now not going to happen? If yes, it is a limitation, and a decision appears only if the limitation is later accepted. If no, but we must now design a certain way, it is a decision that accepts a constraint. If the discovery is not yet certain, raise an open item to confirm it with the vendor first.

Examples:

- The platform requires an access service to exist before a delivery service is provisioned. Nothing is lost, the ordering is now fixed. Decision: "Provision access before delivery, because the platform enforces it." Consulted: vendor. Implemented by: Both.
- The platform can represent a customer service as a bundle object or as two linked services. Both work. We choose linked services because the bundle hides the access service from support tooling. Decision, recording the rejected option.
- The platform holds one notification channel per customer and a Must requirement needs email and SMS on day one. Limitation constraining that requirement, assessed through an open item. A decision appears only if we accept the shortfall.

## 5. Relationships

Links are written as `<relationship> <ID>`, several per item separated by semicolons. A link only needs to be written on one side; a dashboard derives the reverse.

| From | Relationship | To |
|---|---|---|
| DEC | addresses | REQ (only when a real choice was made) |
| DEC | introduces | LIM |
| DEC | raises | RSK |
| DEC | supersedes | DEC (the old decision also carries "superseded by") |
| LIM | constrains | REQ |
| LIM | dispositioned by | DEC (a later disposition keeps the earlier one as "previously dispositioned by") |
| RSK | realised as | OI |
| OI | resolves into | any |
| REQ | replaces | A current-state claim, PRC-nnn.sN or SYS-nnn.fN (the requirement changes what happens today) |
| REQ | preserves | A current-state claim (the requirement keeps something that works today) |
| OI | clarifies | A current-state claim that is Hedged or Contested, or a question on a process |

Current-state claims live in the engagement's current-state record, defined in `extraction-solution-design.md` section 4. A `replaces` or `preserves` link may target only a claim in Current or Current, not needed.

## 6. Scope taxonomy

Removed in 2.17. Items carry no Scope. A way of filtering the registers by service or domain can be added when an engagement has several services to name.

## 7. Register layout

One file per item, named by its id, in a folder per type: `requirements/REQ-0004.md`, `decisions/DEC-0001.md`, `limitations/`, `risks/`, `open-items/`. The file opens with a YAML frontmatter block holding the header fields in 4.1 that apply to the type and the short type-specific fields, in kebab-case (`raised-on`, `implemented-by`, `vendor-ref`, `links` as a list). Long fields sit in the body under fixed headings: Source (one citation per line), Rationale, Impact, Options, Trigger, Mitigation, Next action, Resolution, Notes. A change to one item is therefore a change to one file, and the item's history is the file's history in version control. Only requirements and open items carry an Owner. Requirements, because it names who can say the need is met; open items, because they are the work. Every other type carries Raised by instead, and the work that moves it lives on an open item. Risks carry Due as a review date but no Next action. Decisions carry no Vendor ref. Open items carry no Source; Raised on and Raised by do that job.

The meeting view is a set of generated index tables, one per type, rendered from the frontmatter and never edited by hand. Their columns are:

| Index | Columns |
|---|---|
| Requirements | ID, Title, Status, MoSCoW, Phase, Raised on, Owner, Implemented by, Vendor ref, Links, Updated |
| Decisions | ID, Title, Status, Raised by, Consulted, Approved by, Decided on, Implemented by, Links, Updated |
| Limitations | ID, Title, Status, Identified on, Chosen option, Disposition record, Implemented by, Vendor ref, Links, Updated |
| Risks | ID, Title, Status, Identified on, Raised by, Likelihood, Impact, Links, Due, Updated |
| Open items | ID, Title, Status, Owner, Raised on, Raised by, Blocked by, Links, Resolution, Next action, Due, Closed on, Updated |

One supporting page sits beside the indexes: a conventions page that condenses sections 2 to 5 and 8 for people adding items by hand. Field values are plain text. Ids in Links are plain text ids. Status values are exactly the strings in 4.2.

## 8. What "outstanding" means

The meeting view is:

1. Open items not Closed, sorted by Due, grouped by Owner, with Blocked by shown for any that are Blocked.
2. Limitations in Identified or Under assessment, oldest Identified on first.
3. Risks in Identified or Mitigating with Impact H, and any risk whose review date has passed.
4. Decisions in Proposed older than 14 days.
5. Requirements in Draft older than 14 days, measured from Raised on.

Requirements with Phase = next phase are excluded from this view and appear on a separate next-phase view, reviewed at phase planning rather than in the weekly meeting.

Anything on the outstanding view without an owner, a next action and a due date on it or on its open item is a defect in the register, not a discussion point.

## 9. Integrity rules

Run against a proposed set of registers before writing them, and on request during maintenance. Each rule reports the ids that fail.

| Rule | Check |
|---|---|
| I1 Unique ids | No id appears twice across all registers. |
| I2 Valid status | Every status is an exact 4.2 value for its type. Every requirement has a MoSCoW value and a Raised on date. Every limitation has an Identified on date; Impact once it is past Identified; and at least two Options and a Chosen option once it is Accepted. Every risk has an Identified on date, and Trigger and Mitigation once it is Mitigating. |
| I3 Owner present | Every non-terminal requirement and open item has an Owner that is a person, "Vendor: <name>" or "Joint". Every decision, limitation and risk has Raised by. Decisions and limitations are exempt from Owner, but a decision in Proposed, a requirement in Draft and a limitation in Under assessment must each have an open item in Links whose Owner is set. |
| I4 Next action present | Every open item not Closed has Next action and Due. Every non-terminal risk has Due as its review date. |
| I5 | Removed in 2.17 (was Scope valid). |
| I6 Link targets exist | Every id in Links exists in some register. |
| I7 Limitation disposition | Every LIM in Accepted has a Disposition record naming a DEC in Accepted, and no LIM in Identified or Under assessment has one. A LIM whose Links carry "previously dispositioned by" must name a DEC in Superseded there. |
| I8 Decision supersession | Every DEC in Superseded has a "superseded by" link pointing at a DEC in Accepted or Proposed. |
| I9 Open item resolution | Every OI in Closed has a Resolution and a Closed on date. Every OI in Blocked has Blocked by, and no OI in another state does. |
| I10 | Removed in 2.18 (was Change request approval). |
| I11 Decision approval | Every DEC in Accepted or Rejected has Approved by, Decided on and at least one Consulted entry. Every DEC has Raised by. |
| I12 Implemented by | Every REQ, DEC and LIM has Implemented by set to Vendor, Internal or Both. |
| I13 Realised risk | Every RSK in Realised has a "realised as OI-nnn" link. |
| I14 Source present | Every item other than an open item has a Source. Every open item has Raised on and Raised by. |
| I15 Stale proposals | DEC in Proposed and REQ in Draft older than 14 days are listed as warnings. |
| I16 Decision without requirement | A DEC with no "addresses REQ" link and no "accepts" wording in its Rationale is listed as a warning: it usually means an unstated requirement or an unrecorded constraint. |
| I17 | Removed in 2.18 (was Deferred change request). |
| I18 Current-state links | Every `replaces`, `preserves` and `clarifies` target exists in the current-state record, and no `replaces` or `preserves` target is Retired or Withdrawn. |
| I19 Known stakeholder | Every person named in Owner, Raised by, Approved by and Consulted resolves to a row in the engagement's stakeholder register, or is "Vendor: <name>", "Joint" or a Forum row. A row with Role Mentioned cannot be Owner. |

I1 to I4, I6 to I9, I11 to I14, I18 and I19 are failures. I15 and I16 are warnings.

## 10. Maintenance routine

Before each project meeting:
1. Regenerate the outstanding view (8) from the six registers.
2. Run the integrity rules. Fix I3 and I4 failures before the meeting, since those are the ones that make the meeting unproductive.

During the meeting:
3. Walk the outstanding view top to bottom. Every open item gets a new Next action and Due, or gets Closed with a Resolution.
4. New items raised in the meeting get an id from the next free number, Source = meeting date, and an owner before the meeting ends.

Weekly:
5. Check Limitations in Under assessment for more than 14 days. Each one either gets dispositioned, by choosing one of its Options, or the open item that is assessing it gets a new Due.
5a. Review every risk whose Due has passed. Update Likelihood, Impact and Mitigation, set the next Due, or Retire it with a reason. If the Trigger has been seen, move it to Realised and raise an open item.
6. Check vendor refs. Where the vendor has closed or changed an item we reference, update our item and add a note in Source.

When a design document changes:
7. Any new tracking table in a design document is a defect. Move its rows to the register and mark the table as superseded with a link to the register.

---

## Appendix. Source references

- MADR template primer: ozimmer.ch/practices/2022/11/22/MADRTemplatePrimer.html
- arc42 section 11, risks and technical debt: docs.arc42.org/section-11/
- Google Cloud architecture decision records overview: cloud.google.com/architecture/architecture-decision-records
- RAID log guide: smartsheet.com/content/raid-project-management
