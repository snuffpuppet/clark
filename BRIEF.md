# Brief: extracting solution records from discovery transcripts

Version 1.0, 10 September 2026. Owner: Adam Moyes.

## What I want

Consultants run discovery sessions with our subject matter experts. Each session produces a WebVTT transcript from Teams or Webex. From each transcript I want to produce, with a human approving before anything is written:

1. Requirements, decisions, open items, change requests, limitations and risks, as rows in the registers defined by `solution-register-model.md`.
2. A record of the current business processes the SMEs describe: what triggers each one, the steps performed today, who performs them, how often, and which systems are involved.
3. A record of the facts stated about the systems in use today: what each system does, what it holds, what it cannot do, and what the solution is expected to do with it.

Items 2 and 3 are first-class outputs. They are not background. I want to be able to read them as a description of the current state, and I want a requirement to be able to say which current step or system fact it replaces or preserves.

## What matters most

Correct extraction of the register items and the current-state record from the transcript. Judge any design on that, with a hand-marked transcript as the reference: what it got right, what it got wrong, what it missed and what it invented.

## Constraints

- Every output traces to where it was said: the transcript, the speaker and the passage. A row I cannot check against the transcript is a defect.
- Never invent. Where the transcript is ambiguous, ask a question rather than guess.
- Legacy practice the SMEs no longer perform must not become a requirement or a current process step. Current steps the SMEs say they do not need are still current, and are recorded as such with the reason, and raise no requirement on their own.
- Present-tense description of what happens today is not a requirement. A requirement needs commitment language about the solution.
- A human approves each stage before anything is written. Silence is not approval.
- No new software on the host. Shell tools run directly; anything else runs in Docker.
- Australian English. No em dashes. Versioned documents.

## Questions the design must answer before proposing a pipeline

1. Where do current processes and current system facts live? As item types in the register model, as a separate current-state record, or a mix. Say what the trade-off is and recommend one.
2. What is the unit of traceability, so that every row can be checked against the transcript?
3. What does the human review at each checkpoint, and what does approval mean?
4. How is extraction quality measured, and how does the measure improve the method over time?

## What is deliberately not in this brief

The register model attached is version 2.15. It has no process or system type. Earlier work added both, with a particular shape, and I have removed them so that question 1 is answered fresh rather than inherited. Do not assume any intermediate representation, staging or pipeline shape. Propose the structure for the current-state record first, then the extraction method.
