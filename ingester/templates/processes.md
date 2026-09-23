# Processes: {{TID}}

Version 0.1, {{DATE}}.

- Transcript: {{TID}}
- Session date: {{SESSION_DATE}}
- Ingester version: {{INGESTER_VERSION}}
- Rules version: {{RULES_VERSION}}
- Processes file version: 1
- New items:
- Mutations:
- Completed by:
- Completed on:

## How to review

Each section is one process, read from the whole session. Its Flow table is the process as assembled: a trigger, steps in order with the actor on each, and an outcome. Read the table first and ask whether that is what happens, in that order, as the people who do the work would say it. Write `Accept`, `Edit` or `Reject` on the section's `- Flow verdict:` line. To correct the flow, edit the items (reorder by changing `- Follows:`, split or merge steps, change a step's `- Process:`) and write `Edit`. A Reject writes nothing from that section. Then give a Verdict to every item graded Needs a human; Confident items in a section with `Bulk accept:` count as accepted once the Flow verdict is Accept or Edit. A mutation's Gist says what each changed field was before. Second-hand steps are graded Needs a human: standing unclear, because the speaker described another team's work; accepting one records it as Second-hand and it stays on the walkthrough agenda. Questions need no answer to be accepted. When every Flow verdict and item verdict is filled the file is complete and S4 writes it.

## {{TID}}-P01 Example process title

- Process: new
- Flow verdict:
- Bulk accept:

### Flow

| Step | Actor | Action | System | Follows | When | Hands to | Item |
|---|---|---|---|---|---|---|---|
| 1 | Vendor | Returns a quote for a non-standard product | | | | | 02 |
| 2 | Consultant | Sends the vendor quote to the commercial team | | 1 | | | 03 |

Trigger: a product with no standard sell price. Outcome: a quote carrying an approved sell price enters quote approval.

### Item 01 | PRC | Confident
- Episode: {{TID}}-E25
- Target: new
- Grade: Confident
- Verdict:
- Title: Non-standard pricing
- Trigger: A product or solution has no standard sell price
- Outcome: A quote carrying a commercially approved sell price goes into quote approval
- Performed by: Sales consultants; commercial team
- Frequency:
- Systems: SYS-0002; SYS-0011
- Upstream: PRC-0002
- Downstream: PRC-0002
- Status: Current
- Gist: Example. Delete when writing a real file.

### Item 02 | PRC.step | Needs a human: standing unclear
- Episode: {{TID}}-E25
- Target: new
- Grade: Needs a human: standing unclear
- Verdict:
- Process: item 01
- Title: Vendor returns a quote for the non-standard product
- Performed by: Vendor
- System:
- Follows:
- When:
- Status: Current
- Confidence: Second-hand
- Asserted by: Ryan Morley
- Citations:
  - answered | T001/6727:0-3 | Ryan Morley | 00:52:41 | "Once we get a quote from our vendor, that'll then come back"
- Gist: Example step: one actor, one action. Second-hand because a sales team leader describes what the vendor does (R24). Delete when writing a real file.

### Item 03 | PRC.step | Confident
- Episode: {{TID}}-E25
- Target: new
- Grade: Confident
- Verdict:
- Process: item 01
- Title: Consultant sends the vendor quote to the commercial team for a sell price
- Performed by: Sales consultant
- System:
- Follows: item 02
- When:
- Status: Current
- Confidence: Stated
- Asserted by: Ryan Morley
- Citations:
  - answered | T001/6727:0-3 | Ryan Morley | 00:52:41 | "typically we'll then send that to the commercial team to then give us a sell price."
- Gist: Example. Delete when writing a real file.

### Item 04 | PRC.fact | Confident
- Episode: {{TID}}-E14
- Target: new
- Grade: Confident
- Verdict:
- Process: PRC-0002
- Title: Quote approval runs to a three-hour internal SLA
- Kind: Rule
- Follows: s7
- Status: Current
- Confidence: Stated
- Asserted by: Ryan Morley
- Citations:
  - answered | T001/4485:0-3 | Ryan Morley | 00:35:21 | "For internal approval, we have an internal three-hour SLA for somebody in my team to approve that quote"
- Gist: Example fact qualifying a step. Delete when writing a real file.

### Item 05 | PRC.step | Confident
- Episode: {{TID}}-E25
- Target: PRC-0006.s1
- Grade: Confident
- Verdict:
- Status: Withdrawn
- Replaced by: item 02; item 03
- Citations:
  - answered | T001/6727:0-3 | Ryan Morley | 00:52:41 | "Once we get a quote from our vendor, that'll then come back"
- Gist: Example mutation. Status: Current to Withdrawn; Replaced by: blank to item 02; item 03, because s1 collapsed several actions into one step (R20). Delete when writing a real file.

## Closing

### Catalogue changes

### Citation check

### Integrity check
