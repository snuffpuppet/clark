# Dossier: {{TID}}

Version 0.1, {{DATE}}.

- Transcript: {{TID}}
- Session date: {{SESSION_DATE}}
- Meeting subject: {{SUBJECT}}
- Inferred purpose:
- Ingester version: {{INGESTER_VERSION}}
- Rules version: {{RULES_VERSION}}
- Dossier version: 1
- Completed by:
- Completed on:

## How to review

Read every episode. Each item carries a grade. Items graded Needs a human must each get a Verdict of Accept, Edit or Reject. Items graded Confident may be accepted individually, or in bulk for an episode by writing `Bulk accept: <your name>` on the line under the episode heading after reading them; the write stage treats a blank Verdict on a Confident item in a bulk-accepted episode as Accept. To edit an item, change its field lines in place and write Edit. Questions get an answer in the Gist line or the verdict `raise an OI`. Missed passages are added as new items with citations. When every verdict is filled the dossier is complete: the skill writes Completed by and Completed on and goes straight to S3. There is no separate approval step. A blank verdict outside a bulk-accepted episode is pending and blocks S3.

## {{TID}}-E01 Example episode title

- Span: 630-0 to 635-1 (00:35:34 to 00:35:56)
- Topic: new
- Subject: On subject
- Outcome: Settled
- Bulk accept:

### Item 01 | SYS.fact | Confident
- Episode: {{TID}}-E01
- Target: new
- Grade: Confident
- Verdict:
- Title: Does not natively support PRIORITY-MARK or tagged templates
- System: SYS-0002
- Kind: Cannot
- Status: Current
- Confidence: Stated
- Asserted by: Martin Vasquez
- Citations:
  - asked | T001/630:1-2 | Elena Marchetti | 00:35:34 | "Do you know if we support these templates natively out of CONFIG-MGMT then?"
  - answered | T001/631:0, 632:0 | Martin Vasquez | 00:35:40 | "but the PRIORITY-MARK and the tagged ones. Absolutely not."
  - accepted | T001/633:0 | Elena Marchetti | 00:35:48 | "We already have this problem."
- Gist: Example item in the shape every item takes. Delete when writing a real dossier.

## Closing

### Questions for the SMEs

### Empty episodes

### Citation check

### Integrity check

### Standing extensions proposed

### Subject not reached

