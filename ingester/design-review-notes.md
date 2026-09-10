# Notes for design 1.3

Version 0.3, 10 September 2026.

| Found | Section | Note |
|---|---|---|
| 10 September 2026, step 3 | 6, Example 1 | The citation `T001/862:2-5` starts one fragment late. The quote begins at 862:1 ("If it is cheaper to go as one port"). Correct range `862:1-5`, timestamp 00:56:58. |
| 10 September 2026, step 3 | 6, Example 5 | The citation `T001/165:3-4, 166:0-3, 168:0` starts one fragment late. The quote begins at 165:2 ("If we're going to bring the services onto"). Correct range `165:2-4, 166:0-3, 168:0`, timestamp 00:09:25. |
| 10 September 2026, step 2 | 4.6 | The stakeholder register template carries name variants in a separate Variants column rather than inside Name, so that S0 matching is a plain string comparison. Same meaning. |
| 10 September 2026, step 2 | 4 | Each current-state section closes with an end marker `<!-- end SYS-nnn -->` so the write stage can insert claims mechanically. |
| 10 September 2026, step 10 | Q2 | The citation label list (asked, answered, proposed, restated, accepted, challenged, deferred, hedged) has no label for a passage cited only to show that someone was present, such as a greeting on the session sheet. `aside` is a speech act in 5.2 and the checker now accepts it as a label. Add it to the Q2 list or say the sheet cites differently. |
| 10 September 2026, step 6 | 7.2, S3 | A write that fails part-way (for example a claim naming an element that does not exist) restores every touched file and removes the session log, so a failed S3 leaves the engagement as it was. Worth stating in the design. |
| 10 September 2026, step 6 | 4.6 | S0 leaves the Session date blank for the skill to propose; the VTT carries no date. The handoff date is written as a proposal marked for confirmation. |
| 10 September 2026, after step 10 | 4.6, 5.5, 10.1 | Accepted stakeholder rows are written into `stakeholders.md` as soon as the session sheet is signed (the first act of S1, `bin/s1-stakeholders`), not at S3. The human gate is unchanged; the register is current for S1 and for any second transcript started before S3. The file table line "Bumped by S3" becomes "Bumped when a session sheet is signed, and by S3 for standing extensions". Agreed with Adam. |
| 10 September 2026, addendum A | 7.1, 10.1 | Built: one file per item with generated index tables, four-digit ids (transcripts and episodes stay three), Segment and Department on stakeholders, change requests removed. Model 2.18, design 1.4, ingester 0.3.0. |
| 10 September 2026, phases | model 4.2, 8, 9 | Phases are named in `engagement.md` under `## Phases`, in order, current marked. REQ Phase takes one of those names; I5 is Phase valid. Model 2.19. |
