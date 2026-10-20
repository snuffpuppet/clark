# Document sheet: {{DID}}

Version 0.1, {{DATE}}.

- Document: {{DID}}
- File: {{FILE}}
- SHA-256: {{SHA256}}
- Title: {{TITLE}}
- Author: {{AUTHOR}}
- Organisation:
- Document date: {{DOC_DATE}}
- Document version:
- Kind:
- Domain:
- Ingester version: {{INGESTER_VERSION}}
- Approver:
- Approved on:

## How to review

This sheet fixes the standing of a document, as the session sheet fixes the standing of the people in a meeting. Confirm the header. Author is the person or organisation the document speaks as, and every citation of this document names it, so set it before any citation is written. Kind is one of Vendor deliverable, ABB internal, Design document or Other. Domain is what the document covers.

For each section, check its Treatment and write Accept, Edit or Reject in Verdict:

- **Origin**: what the section says is the author's own assertion, with the author's standing under `engagement.md`, Who makes requirements and decisions (a vendor's assertion about our systems is Second-hand; its design intent is a proposal, never a decision).
- **Attributed**: each row names the person it came from, in the column named under Attribution column. A row is read as that person's statement reported by the author: Second-hand, asserted by the named person, with an open item to confirm with them.
- **Corroborate only**: the section renders ground the register already holds (a vendor's write-up of sessions already ingested is read as a playback). It raises nothing; a row that matches a held item or claim adds a citation to it, and a row that contradicts one is raised as a question.
- **Skip**: not read. A section whose Verdict is Reject is treated as Skip.

D1 reads one section at a time, and each section has its own dossier. The document moves to `documents/processed/` once every section that is not Skip has been written.

People named in the document who are not in the register appear under New stakeholders. Proposed is `new` on every row. Role is Author for the people who wrote the document, Attributed for people a row attributes a statement to, and Mentioned for anyone else named. Only an accepted Author or Attributed row becomes a stakeholder file, because only those people have statements the register can cite. A Mentioned row stays here. Every Verdict cell must be filled, then write your name in Approver and the date in Approved on. You can give all of this to the skill in the terminal instead and let it write the verdicts and the signature here.

## Sections

| Section | Slug | What it holds | Treatment | Attribution column | Verdict |
|---|---|---|---|---|---|
{{SECTIONS}}

## New stakeholders

| Proposed | Name | Organisation | Role | Segment | Department | Standing | Decides | Passage | Verdict |
|---|---|---|---|---|---|---|---|---|---|

## Notes for the reviewer

