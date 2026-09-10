# Notes for design 1.3

Version 0.1, 10 September 2026. Findings made during the build that belong in the next design revision. Folded into `extraction-solution-design.md` as 1.3 by hand.

| Found | Section | Note |
|---|---|---|
| 10 September 2026, step 3 | 6, Example 1 | The citation `T001/862:2-5` starts one fragment late. The quote begins at 862:1 ("If it is cheaper to go as one port"). Correct range `862:1-5`, timestamp 00:56:58. |
| 10 September 2026, step 3 | 6, Example 5 | The citation `T001/165:3-4, 166:0-3, 168:0` starts one fragment late. The quote begins at 165:2 ("If we're going to bring the services onto"). Correct range `165:2-4, 166:0-3, 168:0`, timestamp 00:09:25. |
| 10 September 2026, step 2 | 4.6 | The stakeholder register template carries name variants in a separate Variants column rather than inside Name, so that S0 matching is a plain string comparison. Same meaning. |
| 10 September 2026, step 2 | 4 | Each current-state section closes with an end marker `<!-- end SYS-nnn -->` so the write stage can insert claims mechanically. |
