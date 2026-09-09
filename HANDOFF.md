# Handoff

10 September 2026, updated after the approval session in `~/projects/solution-register`.

## Where things stand

The design `ingester/extraction-solution-design.md` is at version 1.0, approved by Adam on 10 September 2026. The register model is at 2.16 with the design's section 9 changes applied. Both are committed on `main` with `BRIEF.md` and T001 (commit 60c7ade). Implementation is paused while Adam's colleague reviews the design. No implementation plan has been written.

## What changed at approval

- The session-level approving forum flag is gone. Decision authority sits on the stakeholder register: a Decides field per person, a Forum role for approving bodies such as the SLT group, and rule R19. SMEs accept decisions within their area; architect acceptance leaves a decision Proposed with an OI to the forum.
- Skill discovery was tested with Claude Code 2.1.266. A root-level skill under `.claude/skills/` is found from an engagement subfolder with no symlink. Reads into `ingester/` from a subfolder are refused non-interactively, so the runtime is a session started at the repository root with the engagement name passed to the skill. Adam prefers the root `CLAUDE.md` to point at the ingester's README, with engagement folders carrying nothing about the ingester.
- T001 session date recorded as 8 September 2026, to be confirmed on the session sheet at S0.
- The domain name for T001 is still open and is set at S0.

## Untracked files

- `.claude/skills/ingest-transcript/SKILL.md` is a placeholder from the discovery test. It is replaced by the real skill under the implementation plan.
- `HANDOFF.md`, this file, is deliberately untracked.

## Next steps once the colleague's review is in

1. Fold any review changes into the design as 1.1.
2. Write the implementation plan: root `CLAUDE.md` and `ingester/README.md`; folder layout and templates; the S0 shell script and citation checker; the extraction rules file; the ingest skill; the S3 write script and integrity rules; the runbooks; the scoring script and the reference marking template.
3. Adam hand-marks T001 in the dossier format as the first reference.
4. First run on T001 and the first run report.

## Working conventions

Australian English. No em dashes. No rhyming patterns of three, and frame positively rather than as "not x but y". Every document carries a version and date and is bumped on change. The execution guardrail in Adam's global CLAUDE.md applies: nothing new installed on the host, shell and existing tools only.
