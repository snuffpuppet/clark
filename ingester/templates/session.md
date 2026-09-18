# Session sheet: {{TID}}

Version 0.2, {{DATE}}.

- Transcript: {{TID}}
- File: {{FILE}}
- SHA-256: {{SHA256}}
- Session date: {{SESSION_DATE}}
- Meeting subject: {{SUBJECT}}
- Domain:
- Review path: dossier
- Ingester version: {{INGESTER_VERSION}}
- Approver:
- Approved on:

## How to review

Confirm the session date and domain. For each attendee, Verdict is Correct or Edit, confirming the speaker is who the STK column says; a change to an existing stakeholder's role or standing is raised as an STK.edit item in the dossier, not here. For each proposed stakeholder, check Role, Segment, Department, Standing and Decides, edit the cells in place, and write Accept, Edit or Reject. Segment is Residential, BE&G, Wholesale, or blank when the person speaks for the whole business. Department is where they sit, such as Product or Operations. Every Verdict cell must be filled, then write your name in Approver and the date in Approved on. A blank verdict is pending and blocks S1. Review path is dossier or staged. You can give all of this to the skill in the terminal instead and let it write the verdicts and the signature here.

## Attendees

| Speaker tag | STK | Utterances | Verdict |
|---|---|---|---|

## New stakeholders

Speakers not in the register, and people named as owners or deciders who were not present. Role and standing are proposed from the transcript with the passage that suggested them. The Proposed column takes `new` on every row, including a person who did not speak; what the person is goes in Role (Mentioned for someone named but absent, Forum for an approving body). A stakeholder file is written only for the people who spoke; a Mentioned or Forum row stays here, where the reviewer sees who was named and the integrity check reads it.

| Proposed | Name | Organisation | Role | Segment | Department | Standing | Decides | Passage | Verdict |
|---|---|---|---|---|---|---|---|---|---|

## Notes for the reviewer

