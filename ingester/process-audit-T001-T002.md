# Process audit: T001 and T002, techm-bss

Version 1.0, 23 September 2026.

The evidence behind extraction rules R20 to R25, runbook S4 and design 4.1 version 1.4. All 17 process files written by ingester 0.9.1 were read against the full T001 (sales and commissions) and T002 (marketing and demand) transcripts, and both transcripts were swept end to end for process narratives that produced no process. Citations are `Tnnn/utterance:fragment`. A row marked GAP is a step the flow needs that nobody stated. The flow tables are the draft of the first flow reference (runbook evaluate) and are not signed by anyone.

## Findings

About seven of T002's 30 steps are clean single actions, and T001 is similar. The rest are compound actions, volumes, timings, rules, pain points or system behaviour, or they belong to another process. Most of the ordered flow the stakeholders described sits in system facts (SYS-0001 holds 36 T002 citations of flow material, SYS-0006 holds 20, SYS-0003 holds 10) or is cited nowhere.

| Root cause | Evidence |
|---|---|
| A process was created per episode and capability heading, so one flow is split and orphan claims go to the nearest process | PRC-0007, PRC-0010 and PRC-0011 are steps and variants of the two sales flows. T002 item 151: "Placed in the wholesale lead process as the nearest wholesale process in the register". PRC-0006.s2 and s3 (price rises) sit in non-standard pricing |
| Flows exist only across the session; extraction reads one exchange at a time | The Quosal sale is told five times across nine episodes, T001/3235 to 12737. Exchanges X56 and X57 split one answer at T001/10762. Steps sit in spoken order (PRC-0002.s10 signing after s7 SLA; PRC-0013.s1; PRC-0016.s1; PRC-0017.s4). T002 material about T001 processes attached to none of them |
| No definition of a step; no order, condition, handoff or outcome in the format | Volumes (PRC-0003.s2, PRC-0012.s1), timings (PRC-0002.s5, s7), rules (PRC-0002.s1, s8, PRC-0007.s2, s4), pain points (PRC-0002.s11, PRC-0006.s2) filed as steps. Steps with a system as subject filed as SYS facts (SYS-0001.f17, f19, f22, f26, f28; SYS-0002.f9; SYS-0006.f7 to f10; SYS-0012.f1) |
| R11 forbids splitting an assertion, and citations are trimmed to the headline clause | PRC-0001.s1, PRC-0002.s2, s10, PRC-0004.s1, PRC-0007.s3 each collapse three to six actions. Continuations dropped: T001/6739, 9045:1-3, 9309:1-3, 10740:3, 11018, 11952. PRC-0001.s1 skips 3134 behind "..."; PRC-0002.s10 skips 7918 |
| Retellings are not matched to earlier steps | PRC-0002.s1 and s8, s3 and s4, s12 and s14; PRC-0003.s1 and s3; PRC-0001.s4 and PRC-0010.s1 |
| Actors and standing are read from the speaker, not from whose work is described | "We" and "they" never resolved; invented performer "Residential sales operations" (PRC-0003.s4); system actions credited to "The customer" (PRC-0004). Service delivery and customer service steps told by a Business Sales team leader graded Stated (PRC-0002.s3, PRC-0009.s1, PRC-0011.s1) |
| Contradictions inside a session not caught | CIS before sign-up (T001/12148, SYS-0013.f3) against after (T001/12268, PRC-0010.s2). ABB Wholesale leads re-keyed to HubSpot (T002/7412, PRC-0014.s3) against farmed out in Salesforce (T002/8821, s4). Remove or select template items (T001/8467 against 11299) |
| The process has a trigger and no outcome, so membership has no test | Every PRC file |
| Review and evaluation look only at items | Every step was bulk-accepted as individually true; no reference exists for techm-bss; the scorer counts items by kind |
| Upstream: the sessions were run as capability checklists, and the teams that perform many steps were absent | "On a process level, we just want to map this at a more on a capability level right now" (T001/3034). Capability lists at T001/7635, 8900, 10590 and T002 throughout produced tool lists and pain points; walkthrough prompts produced flow (T001/2876, 7747, 5533, 6051; T002/7808) |

### How stakeholders narrate

- One overview at the first open question, then fragments in answer to capability questions. The only end-to-end telling in T001 is the Quosal quote at 7784 to 7992, cued by a narrow "are the emails automated" question.
- People who do the work narrate in order (Jacque Greet, T002/5447 to 5948, 7808, 11766 to 11909). Marketing leads describe tracking and pain. Architects paraphrase ("it sounds like what happens is", T001/5895) and SMEs correct them.
- Corrections and insertions arrive out of order ("well, actually the other thing that we do", T002/5682, inserts a step that comes first).
- Variants come as contrasts in one breath ("treated once again differently for wide sales and quozal", T001/8975; "residential follows the same", T002/3446). In sales the real variant axis is the tool, Wide Sales against Quosal; in marketing it is the segment.
- Sequence words ("then", "once they do that", "the following morning") are plentiful and are the fragments most often dropped from citations.

## T001 processes

### PRC-0001 Small business and business sale through Wide Sales

Described by Ryan Morley, with Chris Van Horn. Trigger "a lead is captured either online or someone calls in" (3104:2). Outcome: delivered and billed (6461:0-1), not stated as done. Residential is the same journey with different plans (5156, 8632).

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1 | Customer or website | Calls in, or a lead arrives online | Wide Sales | Online leads: PRC-0005 | 3104:2 |
| 2 | Consultant | Creates the lead | Wide Sales | | 3104:2-3 |
| 3 | Consultant | Selects product and plan, configures options | Wide Sales | NBN TC4, mobile, basic hardware and VoIP only | 3134:2; 5156:4 |
| 4 | Consultant | Applies a valid promo | Wide Sales | Customer has a promo | 6420:3-4 |
| 5 | Consultant | Creates the account | Wide Sales to CMS | No account | 3183:0-1 |
| 6 | Consultant | Clicks to show the voice print | Wide Sales | | 11952:1; 10997:1-2 |
| 7 | Consultant, customer | Reads the terms verbatim; customer agrees | Call recording | | 11610:2; 11018:1 |
| 8 | Consultant | Submits the order | Wide Sales | | 11018:2; 8975:2-3 |
| 9 | System | Creates the CMS application with commission override and agreement timestamp | CMS | | 9012:1-3; 11705:2-3 |
| 10 | System | Emails the critical information summary | GAP: platform | | 11705:4; 11739:0-1 |
| 11 | Consultant | Creates a linked lead for the next site | Wide Sales | Multi-site | 12800:1-3 |
| 12 | System | Provisions through the automated queue | CMS | | 3372:4-5; 10102:1-3 |
| 13 | System | Delivers and bills with the promo | CMS | | 6461:0-1 |

Existing claims: s1 compound; s2 not a step (Rule); s3 wrong process (residential emailed quote, 8652); s4 good step, duplicate of PRC-0010.s1. Missed: 6420, 9012, 11705, 12800, 3372, 10102, 9970.

### PRC-0002 Small business and business sale through Quosal

Told by Ryan Morley in E08 (3235 to 3267), E10 (3810 to 3903), E30 (7711 to 7992), E34 (9270 to 9338), E44 (11824), E47 (12697 to 12737). Trigger: the product is not in Wide Sales (3414), or several products or sites, or a paper contract (6610). Outcome "the customer gets a bill" (3626:1).

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 0 | Consultant | Decides to use Quosal | | Trigger conditions | 3414:0-1; 6610:0-2; 6644:0 |
| 1 | Consultant | Gathers the information | GAP: source | 10 to 15 minutes multi-site | 3842:0 |
| 2 | Consultant | Selects template items and quantities | Quosal | | 8467:0-1; 4057:0-2 |
| 3 | Consultant | Adds free-text configuration and location notes | Quosal | Tab per address multi-site | 3235:2-4; 12697:1-2 |
| 4 | Consultant | Selects product terms and a contract term line, deletes the rest | Quosal | | 4057:3-4; 10688:2-3; 11299:0 |
| 5 | Consultant | Checks or enters the price from the price book | Quosal | Non-standard: PRC-0006 | 6644:2-3; 6678:0 |
| 6 | Consultant | Requests approval, which emails the approver | Quosal, email, Slack | | 7784:1-3; 7711:2-4 |
| 7 | Approver (business sales team) | Checks the proposal and approves | Quosal | Three-hour internal SLA; one level | 7825:0-2; 4485:1-3 |
| 8 | System | Emails the consultant that it is approved | Quosal | | 7825:3-4 |
| 9 | Consultant | Submits; the customer receives a portal link | Quosal, Order Porter | | 7875:1-4 |
| 10 | Customer | Reviews, signs, ticks acceptance, submits | Order Porter | | 7918:0-5; 7953:0 |
| 11 | System | Emails the signed PDF and stores it on the quote | Quosal | | 7953:1-4; 11780:2-3 |
| 12 | Consultant | Sets closed-won | Quosal | Optional | 7992:1-2 |
| 13 | Consultant | Emails the signed PDF to service delivery | Email | | 7992:3; 8559:1-4 |
| 14 | Consultant | Attaches the document to the CMS account as a note | CMS | Convention only | 11824:1-3; 11868:2-3 |
| 15 | Consultant | Creates and converts a Wide Sales lead with quote number, items and value, to claim commission | Wide Sales | | 9270:1-3; 9309:0-1 |
| 16 | Service delivery | Picks up the order after a couple of days | | | 3903:0 |
| 17 | Service delivery | Creates applications and services by hand, keys contract dates, repeats per site | CMS | | 3267:1-2; 10740:0-1; 11299:2-4; 12737:0 |
| 18 | Service delivery | Provisions, pushes go, customer is billed | CMS | Not automated for enterprise | 3593:1-3 (hedged); 3626:0-1 |

Existing claims: s1 and s8 not steps (Rule, trigger), duplicates; s2 compound; s3 compound over two actors; s4 duplicate of s3; s5 not a step (Timing); s6 wrong process (PRC-0006, E&G); s7 not a step (SLA on step 7); s9 compound plus system behaviour; s10 compound, skips 7825 and 7918; s11 not a step (template design); s12 compound, duplicate of s14; s13 not a step (hedged system behaviour); s14 duplicate, and contradicts s11 (8467 against 11299). Missed: 7825, 7918, 7992:1-2, 6644 to 6678, 4057 to 4101, 3626. PRC-0010.s3, PRC-0007.s3 and s4 and PRC-0011 are steps or conditions of this flow. E&G quoting was never described (Andre absent, 2792).

### PRC-0003 Residential assisted sale through a shared cart in live chat

Chris Van Horn, E17 to E22, prompted by George Beatty (5533, 5895). Trigger stated only by George. Outcome implied.

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1 | Customer | Opens live chat from the website | Live chat | | 5578:0; 5895:1-2 |
| 2 | Consultant | Builds a cart on the public website | Website | Business can too | 5039:1-2; 5018:3 |
| 3 | Consultant | Probably also creates a Wide Sales lead | Wide Sales | Hedged | 5921:0-1 |
| 4 | Consultant | Posts the cart link in the chat | Live chat | | 5285:0-1 |
| 5 | Customer | Opens the cart carrying the consultant's reference | Website | | 5578:3; 5590:0 |
| 6 | Customer | Presses go; continues as self-serve (PRC-0004) | Website to CMS | George's paraphrase | 5958:3-4 |
| 7 | System | Records a commission override for the consultant | GAP: system | Hedged | 5629:0-1 |
| 8 | GAP: actor | Exports CMS data through BI to credit live chat | CMS, BI | Commission | 5629:2-3; 5632:0 |

Existing claims: s1 good, mildly compound; s2 not a step (Volume); s3 compound, duplicate of s1; s4 compound, reporting half belongs to commission, performer invented. Recommendation: an assisted-entry variant of PRC-0004.

### PRC-0004 Residential online self-serve sign up

George Beatty (architect, second-hand), E22 5686 to 5867. Trigger 5372:2. Outcome a working service (5867:2).

| # | Actor | Action | System | Evidence |
|---|---|---|---|---|
| 1 | Customer | Goes to Residential, then Plans | Website | 5733:1-2 |
| 2 | Customer | Enters address, chooses speed, router, voice | Website | 5733:2-4; 5771:0 |
| 3 | System | Creates a lead when the cart starts (branch to PRC-0005) | Wide Sales or CMS | 6089:0-2; T002/4161; T002/4206:2-4 |
| 4 | Customer | Applies a promo code (optional) | Website | 6496:2 |
| 5 | Customer | Clicks go | Website | 5771:0 |
| 6 | System | Calls CMS with the hard-coded plan ID | Website to CMS | 5826:1-3 |
| 7 | System | CMS creates the customer | CMS | 5771:1; 5867:0 |
| 8 | System | CMS starts provisioning; live in about five minutes | CMS | 5867:1-2 |

Existing claim s1 is compound and entirely system behaviour; none of the customer's steps were extracted.

### PRC-0005 Residential outbound call on an abandoned website lead

Tiffany Webb and Chris Van Horn in T001; Jay Stacey and Anthony Lopez in T002. Outcome: the sale completes in Wide Sales (6065, prompted by George at 6051).

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1 | Customer | Starts an online order and enters details | Website | Visible from cart step 2 | 5992:1; T002/4063:2; T002/4161 |
| 2 | System | Creates a lead | Wide Sales or CMS | | 6089:0; T002/4206 |
| 3 | Customer | Leaves without finishing | | | 5992:1 |
| 4 | System | After two hours unprovisioned, sets source to cart abandonment and queues it outbound | CMS or Wide Sales | | T002/4063:3-4; T002/4266:0-3 |
| 5 | System | Serves the lead to an outbound consultant | Wide Sales | Priority 1 to 90 | 6003:0-1; T002/4313 |
| 6 | Outbound consultant | Closes duplicate leads | Wide Sales | Several addresses looked up | T002/4009:2-4 |
| 7 | Outbound consultant | Calls the customer | Phone | | 5992:2 |
| 8 | Outbound consultant | Completes the sale in Wide Sales (PRC-0001 from step 3) | Wide Sales | Customer agrees | 6065:0-2 |

Existing claims: s1 and s3 compound; s2 good (a handoff); s4 not a step (rule); s5 wrong trigger (contact form path, overlaps PRC-0012). Recommendation: merge with PRC-0012 as web lead follow-up with lead-source variants.

### PRC-0006 Non-standard pricing approval

Ryan Morley, E25 (6727 to 6739) and E31 (8298 to 8309, second-hand for E&G); Stuart Cronin in E13 (4324, 4332). Trigger 6727:0. Outcome: a priced quote enters normal approval (6739).

| # | Actor | Action | System | Variant | Evidence |
|---|---|---|---|---|---|
| 1 | Consultant | Identifies a non-standard product | | | 6727:0 |
| 2 | Consultant | Requests a vendor quote | GAP | | implied by 6727:1 |
| 3 | Vendor | Returns the quote | | | 6727:1 |
| 4 | Consultant | Sends it to the commercial team | GAP for SMB; Excel for E&G | | 6727:2; 8298:2 |
| 5 | Commercial | Adds margin, approves, returns a sell price | Excel | Bespoke or large deals signed off by commercial | 6727:2; 8298:3-4; 4324:1-2 |
| 6 | Consultant | Keys the price into the quote | Quosal; Salesforce for E&G | | 6734:0; 8309:0 |
| 7 | Consultant | Sends for approval, then to the customer (PRC-0002 step 6) | Quosal | | 6739:0 |

Existing claims: s1 compound (steps 3 to 6); s2 wrong process and a pain point; s3 wrong process, system behaviour; s4 E&G variant of s1, second-hand. Missed: 4324, 4332, 8213, 7415, 7426, 6301, 6461:3-4. Recommendation: split out a mass-market price change process (6301, 6461:3-4, 6845, 7039), never told as a flow.

### PRC-0007 Sales commission capture and payment

Ryan Morley, E34 and E36; Chris Van Horn for residential hardware. Trigger per variant: submission (9012:1), signature (9338:1), activation (9103:0). Outcome never stated.

| # | Actor | Action | System | Variant | Evidence |
|---|---|---|---|---|---|
| A1 | Consultant | Builds the order, reads terms, submits | Wide Sales | Wide Sales | 8975:2-3 |
| A2 | System | Creates the CMS application with commission override | CMS | | 9012:1-3; 9045:0 |
| A3 | Team leaders | Next morning, run a Power BI report of yesterday's orders | Power BI | | 9045:0-2 |
| A4 | Team leaders | Dump it into Excel | Excel | | 9045:3 |
| A5 | System (rate card) | Assigns commission per product by team | Power BI | Residential | 9103:2-3; 9138:0-2 |
| A6 | Chris Van Horn | Extracts hardware commission by hand and adds it | BI, Excel | Residential hardware | 9676:1-2 |
| B1 | Seller | Gets the signature | Quosal | Quosal | 9231:3-4 |
| B2 | Seller | Sends the order to service delivery | Email | | 9270:0 |
| B3 | Seller | Creates and converts a new Wide Sales lead | Wide Sales | | 9270:1-2 |
| B4 | Seller | Types quote number, name, items, value; submits | Wide Sales | | 9309:0-1 |
| B5 | Team leaders | Next day, run the converted Quosal orders report | Power BI | | 9309:1-3; 9338:0 |
| B6 | Team leaders | Export both and enter Quosal orders into their Excel | Excel | Small business | 9576:0-1; 9621:0-3; 9190:0-1 |
| C | Live chat | Override on the shared cart; BI export to credit live chat | Website, CMS, BI | Live chat | 5629 |
| D | Partner channels | Separate rate card, manual | | Partners | 9456:1; 9507:0 |
| GAP | | Who calculates, approves and pays, and when | | All | not stated |

Existing claims: s1 compound, citation cut at 9045:0; s2 not a step (Rule); s3 compound (B1 to B4); s4 not a step, and its citation starts step B5, which went unrecorded, wrong system; s5 duplicate of A3, A4, B5, B6; s6 good, residential variant. Recorded elsewhere: SYS-0012.f1, f2; PRC-0003.s3, s4; SYS-0011.f2.

### PRC-0008 Contract renewal call-down

Ryan Morley, one answer 10688 to 10839 to the checklist at 10590 to 10632. Trigger a calendar cadence: "there's no notification" (10811:0). Outcome only a goal.

| # | Actor | Action | System | Evidence |
|---|---|---|---|---|
| 0 | Service delivery | Keys contract start and end dates on the CMS service (precondition) | CMS | 10740:0-1; 11299:2-4 |
| 1 | A team leader | Every month or two, pulls a report of contracts expiring within one or three months | GAP: source | 10811:1-3 |
| 2 | Team leader | Uses it as a call-down list | | 10811:3-4 |
| 3 | GAP: actor | Calls each customer for a re-contract | Phone | 10839:0-1 |
| GAP | | What happens when the customer agrees | | not stated |

E&G variant second-hand (10900:0-1). Contract variation asked (10632:1-2) and never answered.

### PRC-0009 Mid-contract cancellation

Ryan Morley describing customer service, all second-hand.

| # | Actor | Action | Evidence |
|---|---|---|---|
| 1 | Customer | Calls or sends a cancellation form | 10740:3 |
| 2 | Customer service | Calculates the charge | 10750:0-1 |
| 3 | Customer service | Generates an invoice | 10762:0 |
| 4 | Customer service | Asks the customer to pay | 10762:0 |
| 5 | Customer service | Cancels the service | 10762:1 |
| GAP | | Where the charge inputs come from; whether cancelling waits for payment | not stated |

Existing claim s1 is compound, its quote runs into the next topic, and it is graded Stated.

### PRC-0010 Agreement document handling

Both variants had been told earlier in the session. Neither trigger nor outcome stated.

| # | Actor | Action | System | Variant | Evidence |
|---|---|---|---|---|---|
| W1 | Consultant | Builds the order; the terms list is generated | Wide Sales | Wide Sales | 10997:1-3 |
| W2 | Consultant | Clicks to show the voice print | Wide Sales | | 11952:1-2 |
| W3 | Consultant | Reads it verbatim | | | 11610:2-3; 11631:0 |
| W4 | Customer | Agrees verbally | Call recording | | 11018:1 |
| W5 | Consultant | Submits | Wide Sales | | 11018:2 |
| W6 | System | Logs time of agreement | CMS | | 11705:2-3 |
| W7 | System | Emails the CIS | KFS or CIS platform | | 11705:4-5; 12055:2-3 |
| Q1 | Seller | Generates and sends the document | Quosal | Quosal | 11739:2-3 |
| Q2 | Customer | Logs into the portal and e-signs | Order Porter | | 11780:0-1; 7875; 7918 |
| Q3 | System | Returns the signed document and emails the seller | Quosal | | 11780:1-4; 7953 |
| Q4 | Seller | Emails it to service delivery | Email | | 11824:1 |
| Q5 | Seller | Attaches it to the CMS account by convention | CMS | | 11824:1-2 |
| Q6 | Anyone, later | Retrieves it from CMS or Quosal | | | 11868:3-4; 11871 |

Contradiction not flagged: CIS sent before sign-up (12148:1-2, Farid Kakar) or after agreement (12268:1-2, Ryan Morley).

### PRC-0011 Multi-site quoting

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1 | Seller | One lead per site, terms read per site | Wide Sales | "no one ever does" | 12669:0-3; 12697:0 |
| 1a | Seller | Uses "create new lead" for the next site | Wide Sales | | 12800:1-3 |
| 2 | Seller | Moves to Quosal | Quosal | Usual | 12697:0 |
| 3 | Seller | Adds a tab per address | Quosal | | 12697:1-2; 12722:0 |
| 4 | Seller | Sends it off as PRC-0002 | Quosal | | 12722:1 |
| 5 | Service delivery | Creates each site by hand | CMS | | 12722:1-3; 12737:0 |

Recommendation: a condition on PRC-0002 steps 3 and 17, and on PRC-0001 step 11.

### T001 narratives with no process

| Narrative | Citations | Recorded as |
|---|---|---|
| Quote correction by the business sales team | 6678:0-2 | SYS-0002.f8 |
| Quosal catalogue and template upkeep | 3192, 4213, 6644 to 6678, 6913:1-3, 13133 | SYS-0002.f2, f13 |
| Mass-market price change | 6461:2-4, 6845, 7039:1-3 | PRC-0006.s2, s3; SYS-0003.f4, f6 |
| Promo application in the Wide Sales sale | 6420, 6461:0-1, 6496:2 | SYS-0001.f9; SYS-0003.f5, f7 |
| CMS percentage discount with approval | 7415, 7426 | SYS-0003.f8; deferred at 7451 |
| Wide Sales delivery and provisioning | 3372:4-5, 10102 | SYS-0003.f9 |
| Residential emailed quote | 8652 | PRC-0001.s3 |
| Order abandonment during delivery | 13280:1-3, 13330:0-1 | RSK-0003 |

## T002 processes

### PRC-0012 Small business lead capture and follow-up in Wide Sales

Spread over E03 to E08 and E18. Trigger the channel list (1275, 1534, 1577). End states 11a to 11c; no single outcome stated.

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1a | Customer | Calls in | WebEx (hedged) | Phone | 1299; 1354 |
| 1b | Customer | Completes a form or drops out of the purchase journey | Website | Web | 1534 |
| 1c | System | Creates a lead from cart step 2 | Website, Wide Sales | Purchase journey | 4063; 4161 |
| 1d | System | After two hours, sets cart abandonment | CMS, Wide Sales | Not provisioned | 4063; 4266 |
| 1e | System | Sends a form or wizard lead straight to outbound | Website | Form or wizard | 4101 |
| 1f | Live chat | Creates email and chat tickets out of hours | Live chat | GAP: who picks up | 1577 |
| 1g | Customer | A contact us form creates an OTRS ticket | OTRS | Uncommon | 1677 |
| 2 | System | Sets lead priority by product, state, tech | Wide Sales | SMB two priorities (contested) | 3934; 4313; 4372 |
| 3a | Inbound consultant | Takes a routed call | WebEx, Wide Sales | Inbound | 2127; 2157 |
| 3b | Outbound consultant | Presses new lead | Wide Sales | Outbound | 2157 |
| 4 | Outbound consultant | Closes duplicate leads | Wide Sales | | 3352; 4009 |
| 5 | Consultant | Calls and does discovery | Phone, Wide Sales | | 3275 |
| 6 | Consultant | Records stage, company, address, revenue, close date | Wide Sales | Stage by hand | 3210; 3155 |
| 7 | Consultant | Sets a callback | Wide Sales | | 3956; 3842 |
| 8 | Consultant | Reattempts a second and third time | Wide Sales | No answer | 3824; 4416; 4429 |
| 9 | Consultant | Tags, wrap code, "how did you hear about us" | Wide Sales | Often skipped | 2553; 10720 |
| 10 | Consultant | Moves an opportunity to a separate queue | Wide Sales | | 3741 |
| 11a | Consultant | Converts in Wide Sales, or Quosal for a signed document | Wide Sales, Quosal | | 1699; 1736 |
| 11b | Consultant | Closes as not interested, priority 70, callback in three months | Wide Sales | | 4757; 4774 |
| 11c | SMB sales | Emails a lead over 100 FTE to E&G | Email | Over 100 FTE | 5628 |

Existing claims: s1 not a step (Volume); s2 compound; s3 wrong process (relocation, 1854); s4 pain point hiding step 9, second-hand; s5 compound; s6 good. Missed: 1c to 1g, 2 to 9, 11a, 11c (in SYS-0001.f19, f21, f22, f27, f28, f31, SYS-0008.f3, SYS-0015.f1, LIM-0014, PRC-0005.s3 to s5). 3915, 3934, 1736 cited nowhere.

### PRC-0013 Enterprise and government lead qualification and allocation

Jacque Greet, E11 5447 to 6366, the most complete ordered narrative in T002.

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1a | Prospect | Submits a web form; auto-added to a campaign | Pardot, Salesforce | Web | 5577; 5779; 5816 |
| 1b | Campaign team | Receives an event list | Spreadsheet | Event | 5927 |
| 1c | SMB team | Emails leads over 100 FTE | Email | Forwarded | 5628 |
| 1d | Campaign team | Uploads a bought list as opted out | Salesforce, Pardot | Bought list | 6046 to 6075 |
| 2 | Campaign team | Checks for an existing owner; forwards if found | Salesforce | Existing | 5682; 5927 |
| 3 | Campaign team | Washes FTE and head office state, not trusting the form | DCA, ZoomInfo, LinkedIn, AI | New lead | 5489; 5530; 5577; 5779 |
| 4a | Campaign team | Emails small or wholesale-looking leads to those teams | Email | Under 100 FTE or wholesale | 5715 |
| 4b | Campaign team | Allocates to the salesperson for the band and area | Salesforce | Otherwise | 5715; 5948 |
| 5 | Campaign team | Sets campaign status for the team allocated | Salesforce | | 5873 |
| 6 | Campaign team | Sends a Salesforce task and a Slack message | Salesforce, Slack | | 5873 |
| 7 | Salesperson | Follows up within 24 hours; GAP: what follow-up means | | | 5877 |

Existing claims: s1 compound and out of order (step 2 comes first, 5682); s2, s3, s4 compound; s5 good with a Timing rule; s6 variant duplicating s1 and s3.

### PRC-0014 Wholesale lead capture and handover

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1 | Prospect | Submits a brand contact form | Salesforce (ABB Wholesale) or HubSpot (Symbio, Telco in a Box) | By brand | 7001 |
| 1b | Prospect | Engages a LinkedIn campaign | LinkedIn | Symbio, TIAB | 7288 |
| 1c | E&G campaign team | Emails a wholesale-looking lead | Email | GAP: to whom | 5715 |
| 2 | Wholesale marketing | Types LinkedIn leads into the HubSpot form | LinkedIn to HubSpot | | 7326 |
| 3 | Wholesale marketing | Re-keys ABB Wholesale leads into the HubSpot form | Salesforce to HubSpot | Contested with 3' | 7366; 7412 |
| 3' | Head of sales operations | Farms ABB Wholesale leads out to partner managers and BDMs | Salesforce | Contested with 3 | 8821 |
| 4 | Owner or Symbio sales | Nurtures through four to six stages | Salesforce, HubSpot | Hedged, second-hand | 8851; 8912 |
| 5 | Symbio sales | Hands to account management after a couple of months | HubSpot | | 8936 |

Existing claims: s1 system routing, acceptable as a branch; s2, s3 good; s4, s5 wrong process (wholesale opportunity management), compound, second-hand; s6 wrong process (wholesale offers, item 151). Recommendation: three processes.

### PRC-0015 Enterprise and government opportunity management

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1 | GAP: salesperson implied | Converts the lead to account and contact | Salesforce | Looks like an opportunity | 7808; 7859 |
| 2 | Salesperson | Creates the opportunity, broken down by product | Salesforce | | 7859; 7900 |
| 3 | Salesperson | Progresses stages with probability and close date | Salesforce | | 7859; 8132; 8308 |
| 4 | Manager | Flags stuck or past-due opportunities; salesperson re-forecasts | Salesforce | Hygiene | 8252; 8325; 8341 |
| 5 | Salesperson | Closes won or lost | Salesforce | | 7900 |
| 6 | Salesforce | Produces the commission report | Salesforce | | 8011 |
| 7 | Jacque Greet | Checks each opportunity against its contract documents quarterly | Salesforce | Quarterly | 8050; 8405 |
| 8 | Acquisition manager | Runs a report and asks which accounts to hand over | Salesforce | Minimum MRC or six to twelve months | 8597; 8637; 8673 |

Existing claims: s1 compound; s2 compound, commission belongs to PRC-0007, quarterly check is a separate control; s3 a separate account handover process. Steps 2 to 4 recorded only as SYS-0006.f7 to f10.

### PRC-0016 Enterprise and government campaign management

Order: choose the target (11766, GAP: who decides); build the list from Salesforce reports (11766); create the campaign (11810); tag records into it (11810); export and upload to Pardot (11909); Pardot sends the EDM (11867, 11958); Pardot tracks bounces (11909); update member status (11810, 11824, GAP: who); report (11824). Existing s1 compound and out of order; s2 compound plus a pain point. Missed: the Aussie Fibre six-system variant (12878), the target mix (12814), opt-out (6075).

### PRC-0017 Residential and small business promotion lifecycle

| # | Actor | Action | System | Condition | Evidence |
|---|---|---|---|---|---|
| 1 | Marketing with commercial | Decides the promotion | | Ownership contested | 13061; 13115; 12498; 12678; 13017 |
| 2 | Marketing | Enters code, discount, plan, conditions, dates | CMS promo tool | | 12498; 12604; 12610; 12543 |
| 3 | System | Publishes to the website and feeds Wide Sales | Website, Wide Sales | | 12519 |
| 4 | Customer | Sees the deal and calls | | | 12289 |
| 5 | Consultant | Applies the promo in the cart, or a similar one | Wide Sales | | 12289; 12321 |
| 6 | System | Refuses a new-customer promo to a recent location | Promo tool | Location check | 13183 |
| 7 | Consultant, then Level 2 | Leeway on an expired promo, else Level 2 applies it at the back end | CMS | Past end date | 12439; 12446 |

E&G variant (12678 to 12933): product refuses a code; finance applies the discount by hand and monitors it; recorded only as LIM-0027. Existing claims: s1 to s3 good; s4 out of order (it is step 1) and compound.

### T002 narratives with no process

| Narrative | Citations | Recorded as |
|---|---|---|
| SMB and residential opportunity work in Wide Sales | 3101 to 3363, 3446 | SYS-0001.f20 to f24 |
| Cart journey inside CMS (extends PRC-0004) | 4206 | SYS-0003.f13 |
| Shared cart account creation (extends PRC-0003) | 3614 | SYS-0001.f26 |
| NBN underperforming lines | 9930, 9938 | SYS-0011.f4; SYS-0001.f30 |
| Marketing attribution | 10211, 10397, 10633, 10681 | SYS-0005.f2; SYS-0021.f1; LIM-0021 |
| Reseller leads | 11653 | SYS-0005.f3 |
| E&G commission (extends PRC-0007) | 8011, 8050 | PRC-0015.s2 |
| SMB reactive retention | 14295 | REQ-0009 only |
| Opportunity renamed by trading entity | 6485 to 6570 | LIM (item 69) |
