# Run report: {{TID}} run {{RUN}}

Version 0.1, {{DATE}}.

- Transcript: {{TID}}
- Reference: {{REFERENCE}} (version {{REFERENCE_VERSION}})
- Dossier scored: {{DOSSIER}}
- Ingester version: {{INGESTER_VERSION}}
- Rules version: {{RULES_VERSION}}
- Previous run: {{PREVIOUS}}

## Counts per kind

Right: matched and accepted without edit. Wrong: matched but edited or rejected. Missed: in the reference, not in the draft. Invented: in the draft, not in the reference, or the citation failed.

| Kind | Right | Wrong | Missed | Invented | Previous right | Previous wrong | Previous missed | Previous invented |
|---|---|---|---|---|---|---|---|---|
{{COUNTS}}

## Derived

- Invented per hundred drafted items: {{INVENTED_RATE}}
- Missed per hundred reference items: {{MISSED_RATE}}
- Human share (Needs a human over all drafted items): {{HUMAN_SHARE}}

## Further counts

- Resurrections: {{RESURRECTIONS}}
- Empty episodes: {{EMPTY_EPISODES}}
- Confident but wrong: {{CONFIDENT_WRONG}}

## Failure-mode tags

One row per Wrong, Missed, Invented or Confident-but-wrong item. The human fills Tag from the list in extraction-rules.md and Rule with the rule to change.

| Item | Kind | Count | Tag | Rule | Note |
|---|---|---|---|---|---|
{{TAG_ROWS}}

## Regression check

A rule change that lowers any kind's Right count on an earlier reference is a regression and is reverted or explained here.

