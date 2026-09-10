# Runbook: evaluate

Version 0.1, 10 September 2026.

## Purpose

Measure a drafted dossier against a reference, tag every disagreement with a failure mode, and turn the tags into a versioned change to the rules (design Q4 and section 8).

## Inputs

- The reference: `evaluation/Tnnn-reference.md` in the dossier shape (hand-marked for the first transcript, from `ingester/templates/reference.md`), or the approved dossier of a later session.
- The dossier as drafted, before the reviewer's edits. Copy it aside as `sessions/Tnnn/Tnnn.dossier.draft.md` before S2 so the score reflects the method and not the corrections.

## Command

```
ingester/bin/stage <engagement> Tnnn score evaluation/Tnnn-reference.md sessions/Tnnn/Tnnn.dossier.draft.md
```

## Outputs

`evaluation/Tnnn-run-nn.md` with, per kind, Right, Wrong, Missed and Invented; the derived rates; Resurrections, Empty episodes and Confident-but-wrong; a failure-mode table with one blank row per disagreement; and the previous run's counts for comparison.

## Automatic checks

Episodes match when their spans overlap by more than half. Items match when kinds agree and cited utterance sets overlap. Every citation in both files is checked with `check-citations`.

## What the reviewer does

1. Fill Tag and Rule on every row of the failure-mode table from the list in `ingester/extraction-rules.md`. Add a new tag to that list when none fits, mapped to one rule.
2. For each tagged rule, edit the rule statement in `extraction-rules.md` and add the failing passage to its Test passages table with the run number. Bump the rules version and write the change log entry.
3. Where the disagreement is in the reference, correct the reference, bump its version, and log the correction in the run report.
4. Rerun S1 with the new rules version and score again as the next run.
5. A change that lowers any kind's Right count on an earlier reference is a regression: revert it or explain it under Regression check.

## What approval means

Adam accepts a run when its dossier is good enough to review. That dossier goes through S2 and S3. Nothing is written to the registers from an unaccepted run (design section 8, item 6).

## On rejection

Repeat from step 1 with the next run number.
