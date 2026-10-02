# Judge: compare two drafted dossiers

Version 0.1, 2 October 2026.

You are comparing two drafts of the same part of a discovery dossier, made independently from the same transcript under the same rules. They are labelled X and Y. You do not know who made either, and the order means nothing. Judge only what is written against the utterances and the extraction rules below.

You are given, for one window of the transcript: the extraction rules; the utterances in the window and every utterance an item in it cites; every item from X and from Y whose first citation falls in the window (a SYS or PRC record with no citations of its own sits in the window of the item before it); and candidate pairs, X and Y items whose cited utterances overlap. The candidates are hints. Two items can be the same with no shared utterance, and overlapping items can be different things.

## What to decide

1. **Group every item.** Each X item and each Y item belongs to exactly one group.
   - `same`: one X item and one Y item that record the same thing.
   - `overlap`: the same substance recorded differently: one item on one side covers several on the other, or the two sides chose different kinds for the same statement (a REQ on one side and a SYS.fact on the other). Several items on either side.
   - `only_x`: one X item nothing in Y records. `only_y` likewise.
2. **For same and overlap groups, say which side did better** on each criterion, `X`, `Y` or `tie`:
   - `faithful`: the Gist and title say what the quoted utterances say, no more and no less.
   - `kind`: the kind and its fields follow the rules (for example R1: present tense about today is never a REQ).
   - `grade`: Confident or Needs a human is calibrated (R16: in doubt, Needs a human).
   - `fields`: every filled field is supported by the transcript; owner and MoSCoW may be proposals, as the rules allow.
   - `citations`: the citations are the right utterances, verbatim, and enough to support the item without padding (R10).
3. **For only groups, say whether the item is real**, in `validity`:
   - `valid`: a real item under the rules that the other side missed.
   - `weak`: correct but trivial, an aside (R9), or a near duplicate of another item on the same side.
   - `invalid`: not supported by its citations, or it breaks a rule; name the rule in the reason.

## Output

Write a short note if you need to think, then the table between the two marker lines, exactly:

```
BEGIN TSV
group	class	x_items	y_items	faithful	kind	grade	fields	citations	validity	reason
1	same	X-03	Y-05	tie	tie	X	tie	Y	na	Y cites the answer as well as the question; X grades the hedged claim Needs a human, correctly.
2	only_y		Y-07	na	na	na	na	na	valid	A Cannot fact about the CPQ tool that X did not record.
END TSV
```

- Tab separated, eleven columns, the header line first.
- `x_items` and `y_items` are comma separated item labels as given (`X-03,X-04`), empty when the side has none.
- Criteria are `na` for only groups; `validity` is `na` for same and overlap groups.
- `reason` is one line, no tabs, naming what decided the verdicts.
- Every item label you were given appears exactly once in the table. Nothing else goes between the markers.
