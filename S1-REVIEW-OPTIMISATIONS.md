# Reducing the review load at S2

Notes from the first end-to-end run of the ingester, T001 in `engagements/techm-bss/`, 17 September 2026. Written to be folded into `ingester/runbooks/`, `ingester/extraction-rules.md` and the skill as a versioned change. Deliberately outside `ingester/`, because nothing under `ingester/` is written during a run.

## The measurement

T001 was a two hour discovery session: 1938 cues, 843 utterances, 19 speakers. S1 produced 230 items across 50 episodes.

| Group | Items | Did the reviewer need to think? |
|---|---|---|
| Graded Confident, bulk accepted | 178 | No |
| Hedged claims and Questions | 28 | No. Accepted as drafted so R17 clears them later |
| Blank Owner, MoSCoW or Due | 16 | No. Administrative, and the values were derivable |
| Genuine judgement | 8 | Yes |

**8 of 230.** The reviewer's real load is the eight. Everything below is about making the other 222 invisible, and about four defects that cost round trips.

## 1. Fill Owner and MoSCoW at S1 instead of leaving them blank

**Observation.** 16 items were graded `Needs a human: field needs a decision` only because Owner, MoSCoW or Due was blank. The runbook currently tells the reader to leave those for the reviewer and list them under Integrity check.

**Cost.** `s3-write` line 26 runs `check-integrity --proposed` as a hard gate and dies on failure. The gate is whole-dossier, not per item. Rule I3 fails any REQ or OI with no Owner; I2 fails any REQ with no MoSCoW. A dossier left in the state the runbook describes cannot be written at all, and the reviewer discovers this only when S3 refuses.

**Fix.** S1 proposes a value for every required field and says in the Gist that it is a proposal.

- Owner on an open item: the person who raised it, or whose Decides covers the subject. It must be a name in the stakeholder register; I19 rejects anything else and also rejects any person whose Role is Mentioned.
- MoSCoW on a requirement: proposed from the language. "Needs to be one of the key features we get built" is Must.
- Due stays blank. I4 warns rather than fails, so it costs nothing.

R17 already documents the mutation path for changing an Owner or a MoSCoW later, so a wrong proposal is cheap and a blank is expensive. Grade these `Confident` with the proposal named, not `Needs a human`.

## 2. Accept hedged and contested claims as drafted

**Observation.** 28 of the 52 were hedged claims and Questions. None of them needed a decision now.

**Cost.** Presenting them as items awaiting a verdict implies the reviewer should resolve the hedge, which they cannot do from the transcript either.

**Fix.** The design already says it, in `extraction-solution-design.md` section 4: "Hedged and Contested claims are recorded so that the passage is not lost, but they raise a question and are excluded from the current state as agreed until a later session or a reviewer answer upgrades them." R17 builds the next session's outstanding set from claims that are Hedged or Contested, and from every line under Questions for the SMEs in earlier dossiers.

Make this explicit in the runbook so the reviewer sees it once rather than 28 times: a hedged claim is complete work, not pending work. Present them as one line in the terminal, not as 28 items to vote on.

Two things worth knowing that are not written down anywhere:

- **Questions write nothing.** `s3-write` has `Question) ;;`, a deliberate no-op. A Question survives only as a line under Questions for the SMEs in the dossier under `sessions/`, which is where R17 reads it from. Accepting one carries it forward; it does not create a record.
- **Hedged claims are not in `index/outstanding.md`.** That view covers open items, limitations, risks, proposed decisions and draft requirements. Hedged claims appear in `index/systems.md` and `index/processes.md` and are found by reading the item files, which is what R17 tells the reader to do. Consider adding a section 6 to the outstanding view for claims that are Hedged or Contested.

## 3. Use the bulk accept line the dossier already has

**Observation.** The dossier template carries a `- Bulk accept:` line per episode and `lib.sh` honours it: `dossier_signed` treats a blank verdict as filled when the item is Confident and the episode has a bulk name, and `accepted_items` merges it. It went unused for all 50 episodes.

**Fix.** At step 7, instead of writing `- Verdict: Accept` on 178 items, write the reviewer's name on the `- Bulk accept:` line of every episode whose items are all Confident, and accept individually only in mixed episodes. The dossier gets shorter and the terminal summary becomes one line per episode.

## 4. Check grade against confidence before presenting

**Observation.** Two claims carried `Confidence: Hedged` with `Grade: Confident`, and four more were graded Confident with a hedge word in the content citation. All six were caught by the step 6 self-checks and regraded, but only because the checks were run carefully.

**Fix.** Add to runbook S1 step 6 as a mechanical check: no item may have `Confidence: Hedged` or `Contested` with `Grade: Confident`. It is a two line awk and it catches the failure mode R16 exists to prevent.

## 5. Defects that cost round trips

Defects in the mechanism and in how it is operated, not in the method. Each one cost a correction cycle on T001.

**5.1 A free-text verdict is accepted by the gate and then silently dropped.** `dossier_signed` requires only that the verdict is not empty. `accepted_items` merges only `Accept` and `Edit`. A reviewer who writes "approve but it must happen with Andre Dunn, not Andrew Mann" passes the gate and gets nothing written, with no warning anywhere. This happened on T001 item 14 and was caught by hand.

*Fix:* make `dossier_signed` fail on any verdict that is not `Accept`, `Edit` or `Reject`, and name the item. A reviewer's words should never vanish.

**5.2 `s1-stakeholders` silently drops rows it does not recognise.** Line 17 matches `^| new |` only. The S0 runbook tells the reader to add Mentioned rows to the same table but never says what goes in the Proposed column. T001 used `| mentioned |` and five accepted rows were dropped; the script reported "19 stakeholder file(s) created" against 24 accepted rows and exited clean.

*Fix:* document that the Proposed column takes `new` for every row and that `Mentioned` belongs in Role, and make the script compare rows accepted against files written and fail on a mismatch. Separately, record the decision taken on T001: a stakeholder file is written only for people who spoke, because only they express a viewpoint the register can cite. Mentioned rows stay on the session sheet so the reviewer can see who was named and who is missing.

**5.3 `Consulted` splits on commas, not semicolons.** I19 splits that one field on `, *` while every other list in the dossier uses `; `. T001 item 75 used semicolons and all four names read as a single unknown stakeholder. Either accept both separators or say which in the format note.

**5.4 The F2 citation labels are not the speech act names.** The exchanges file tags acts as `ask`, `assert`, `propose`, `restate`, `accept`, `challenge`, `defer`, `hedge`, `aside`. F2 citations use `asked`, `answered`, `proposed`, `restated`, `accepted`, `challenged`, `deferred`, `hedged`, `aside`. `assert` becomes `answered`, which is not obvious. The first dossier batch failed all 19 citations on this alone.

*Fix:* put the mapping in the F2 note in `README.md` and in runbook S1 step 4.

**5.5 Nothing validates an `STK.edit` target before S3.** `s3-write` reads the Target of an `STK.edit` as the id of the stakeholder file to edit and dies if that file is missing. Neither `check-citations` nor `check-integrity` looks at it: the integrity check merges only the register item types and never inspects an `STK.edit` block. T001 proposed two standing extensions with `Target: new`, both passed every gate, and S3 died on the first of them after writing 143 items, which the rollback then undid. R18 tells the reader to propose a standing edit with a citation, but the F4 note never says that the Target is the stakeholder's existing id.

*Fix:* say in the F4 note that an `STK.edit` Target is an existing `STK-nnnn` and never `new`, and add a check that every `STK.edit` target names a stakeholder file that exists. It belongs in `check-integrity` so the reader catches it at S1 rather than after a write that takes minutes to fail.

**5.6 A large write exceeds the foreground command timeout.** T001's dossier held 230 accepted items and `s3-write` needs several minutes of shell work to write them. Run in the foreground it is moved to the background part way through, which makes the run hard to follow and invites a wrong conclusion about whether it is still going.

*Fix:* runbook S3 should say to start the write in the background and wait for it to report, and to read its exit line rather than inferring progress from the item folders. Nothing may touch those folders while a write is in flight: `s3-write` snapshots them and rolls back on failure, and a concurrent change to them breaks that guarantee.

## 6. Two mechanical aids worth building

**6.1 A quote extractor.** Six citations failed because a quoted sentence ran one fragment further than the cited range. Each cost a check, a look and a fix. A short script that takes `Tnnn/utt:lo-hi` and prints the speaker, the start second and the exact concatenated text removes the whole class of error:

```sh
quote techm-bss T001 3414:0-3
# Ryan Morley | 00:26:42 | Now, any product that isn't in wide sales, which is a lot of them, ...
```

Write the quote by copying from its output rather than from the transcript. Add it as `ingester/bin/quote`.

**6.2 Generate the episodes file from the dossier.** `Tnnn.episodes.md` repeats the span, topic, subject and outcome already in the dossier's episode headings, plus the item numbers. Generating it with awk after the dossier is written removes a copy and guarantees the two agree.

## 7. What to present in the terminal

The reviewer should not scroll 230 items. Present, in this order:

1. The items that genuinely need judgement, in full, with their evidence. On T001 that was 8.
2. One line saying how many hedged claims and Questions were accepted as drafted and that R17 will raise them next session.
3. One line per proposed Owner and MoSCoW, so they can be corrected in a word.
4. The counts and the file path.

Everything else goes in the dossier for the record and is never read aloud.

## Suggested change list

| Change | Where |
|---|---|
| Propose Owner and MoSCoW at S1; grade Confident with the proposal named | `runbooks/S1.md` step 4, grading conditions in `extraction-rules.md` |
| Say that hedged and contested claims are complete work, and how R17 clears them | `runbooks/S1.md` step 5 and `runbooks/S2.md` |
| Use the per-episode bulk accept line | `runbooks/S1.md` step 7 |
| Add the confidence against grade self-check | `runbooks/S1.md` step 6 |
| Add the speech act to F2 label mapping | `README.md` F2, `runbooks/S1.md` step 4 |
| Say what the Proposed column takes, and that only speakers get a file | `runbooks/S0.md` procedure step 3 |
| Reject a verdict that is not Accept, Edit or Reject | `bin/lib.sh` `dossier_signed` |
| Fail when accepted rows and written files disagree | `bin/s1-stakeholders` |
| Accept `; ` as a separator on Consulted | `bin/check-integrity` I19 |
| Add claims that are Hedged or Contested to the outstanding view | `bin/render-index` |
| Say that an STK.edit Target is an existing STK id, and check it | `README.md` F4, `bin/check-integrity` |
| Start the write in the background and wait for it; touch nothing while it runs | `runbooks/S3.md`, the skill |
| Add the quote extractor | `bin/quote` |
| Generate the episodes file from the dossier | `runbooks/S1.md` step 3 |

Every change above is a change to the mechanism, so it is made by hand as a versioned change with `ingester/VERSION` bumped, and `extraction-rules.md` carries its own version.
