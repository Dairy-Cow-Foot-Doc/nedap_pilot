# Proposal review, 2026-09-26 - duration, sample size, and a critical read of draft 3

For `design/proposal_nedap_3arm_draft.md` (draft 3, `259bdf7`) and `design/budget_nedap_3arm (version 2).xlsx`.
**Nothing in the proposal has been changed yet.** Each item below is a proposed change, for Gerard to accept or reject.

Settled by Gerard today:

- **Plan for lower alert rates than the pilot.** The pilot is a high-alert herd (0.024 per cow per week). The April LOW-trigger change was to get scores into DairyComp, not because cows at that score are lame.
- **Aim for about 7,200 enrolled.** That is the random-slope fix (below).
- **21 months is too long. 18 was already a stretch.**

------------------------------------------------------------------------

## A. Duration: 21 months is avoidable

Duration = enrolment + follow-up of the **last** cow. Budget v2 has 9 + 12 = 21. Both terms can come down.

### A1. Follow to a fixed study end, not 365 days per cow (recommended)

- **Every cow is followed to one calendar end date**, not for 365 days each. Early cows get more than a year; the last cow gets the minimum.
- **Time-to-event outcomes handle this already.** §6 already specifies censoring for staggered entry. The 365-day culling estimate comes from the cows who reached 365 days.
- **Minimum follow-up after the last enrolment, by outcome:**

| Outcome | Needs | Minimum after last cow |
|---|---|---|
| Milk (primary) | 90 days after alert | **3 months** |
| Cure, WLD/SU | 60-day recheck | 2-3 months |
| Culling | see A2 | **6 months** |
| Recurrence | see A2 | 6 months |
| Lesion at dry-off | cow must reach dry-off | varies - see A3 |

- **So the floor is about 6 months after the last cow.** That gives enrolment + 6.

### A2. Culling at 180 days carries nearly all of the signal

From the draft's own table (§4):

| Window | Gap |
|---|---|
| 180 days | +6.8 |
| 365 days | +7.3 |

- **93% of the 365-day gap is there by 180 days.** The draft's "still widening" argument rests on the last 0.5 points.
- The study cannot *prove* the culling effect anyway (§5 limitation: break-even needs about 1.2 points, the interval is ±5.2). So culling is an estimate either way, and 180 days loses very little.
- **Proposed:** culling and recurrence at **180 days as the stated horizon**; 365 days reported for cows enrolled early enough, with its interval.
- **Still to compute:** recurrence baseline at 180 days. The draft only has 48.7% at 365. Needs the shared functions, not a guess.

### A3. Lesion at dry-off gets shorter follow-up too

- A cow alerted at DIM 150 dries off about 5 months later. A cow alerted at DIM 30 dries off 9 months later.
- With 6 months after the last cow, early-lactation cows alerted late in enrolment will not reach dry-off. That is a DIM selection, already flagged in the draft for the 90-day rule.
- **Proposed:** keep the outcome; restrict to cows whose dry-off falls before the study end, and report DIM at alert for kept and dropped cows. Or demote it to descriptive.

### A4. Enrolment: more herds, or bigger herds - not more months

Months to enrol at **0.010 per cow per week** (under half the pilot rate), herds of 3,000 cows:

| Design | Per herd | Enrolled | Power (tau 0.25, random slope) | Months to enrol |
|---|---|---|---|---|
| 6 herds (budget v2) | 1,200 | 7,200 | 81% | **9.2** |
| **8 herds** | 850 | 6,800 | 80% | **6.5** |
| 10 herds | 660 | 6,600 | 80% | 5.1 |
| 6 herds of 4,000+ | 1,167 | 7,000 | 80% | 6.7 |

- **More herds cut two ways:** fewer cows per herd, and a smaller between-herd penalty (7,000 needed at 6 herds, 6,800 at 8, 6,600 at 10).
- Simulation: per-herd estimates, 40,000 runs, same variance inputs as §5. `scratchpad` only - rebuild if needed (see memory `project-nedap-3arm-proposal`).
- **The cost of 8 herds is practical, not statistical:** 8 farms to visit, and 3 regions means 2-3 farms each. Visits run fewer months, so the budget may not move much. Re-run the budget before deciding.

### A5. Putting it together

| Option | Enrolment | After last cow | **Total** |
|---|---|---|---|
| Budget v2 | 9 | 12 | **21** |
| 6 herds, fixed end | 9 | 6 | **15** |
| **8 herds, fixed end** | 6.5 | 6 | **12.5, budget 15** |
| 8 herds, fixed end, pilot-like rate (0.020) | 3.3 | 6 | 9.3 |

**Recommendation: 8 herds of about 3,000, 6,800 enrolled, fixed study end, culling at 180 days.** Budget 15 months total (enrolment up to 9, study end at month 15). That keeps the 9-month safety valve and lands under 18.

------------------------------------------------------------------------

## B. Critical read of draft 3 - things that are wrong or inconsistent

Ordered by how much they matter.

1. **Culling and recurrence are sized on lesion cows only (700 per arm).** Whether a lesion is *found* depends on the arm - that is the ascertainment problem the whole design is built around. Restricting to cows with a lesion breaks randomisation. **Culling should be on all enrolled cows** (about 2,400 per arm at 7,200). That is randomisation-protected and narrows the interval. The 2026-09-10 review raised this ("conditioning on cows with a lesion is a collider"); it was never applied. Recurrence can stay on lesion cows but must be labelled as not a randomised contrast.
2. **§5 and §6 still say 6,000 and have no random slope.** Needs: §6 `(1 + arm | herd)` with Kenward-Roger df, on the logistic models too; §5 target and inflation (×1.09 -> about ×1.2), herd table, timeline. Wait for section A to settle the herd count first.
3. **The trim cost is stated three ways.** Ledger: \$20 per trim (\$19.40 per lame cow). Assumptions table: \$18. Budget: \$18. §3 text: "about \$19". Pick one.
4. **Break-even is 1.3 points in §5, 0.9-1.5 in §3.** The 1.3 comes from a superseded \$1,500 cull value; at \$1,650 it is 1.21. Flagged on 2026-09-10, never fixed.
5. **§5's herd-supply table and §6's chronicity table use the pilot alert rate** (0.020, 69 per week). Both need the lower-rate range. "29 weeks rather than 15" in §6 is from an older sizing.
6. **§4's "2,982 to 3,228 cows from 28 to 180 days"** is from an earlier sizing basis (working doc line 583), not the 1,425-per-arm table in §5. The point it makes - arm 1 v 3 barely cares about the window - still holds. Drop the numbers or state the basis.
7. **§4's "arm 1 v 2 reaches 43% power at 6,000"** needs re-stating at the new size.
8. **D1 and D2 (2026-09-10 review) are still open.** D2 is now the biggest lever on duration: a baseline-adjusted milk outcome took 6,200 to 2,300 over days 1-30. **The pilot's milk now reaches 90 days for the first alerts** (alerts from 2026-06-02, milk to 2026-09-08), so D2 can be re-measured over the full window instead of argued. If it holds even partly, the sample size - and the duration - drop a lot. Do this before re-sizing anything.

## C. Not changed, deliberately

- The arms, the enrolment point, the DIM 5 floor, the §7 asks and the pre-specification list are sound.
- The "Milk alone does not cover the cost" line stays until D1 is decided.

## D. Suggested order for the next session

1. **Re-measure D2 over 90 days** (`scripts/proposal/p31_baseline_variance_check.R`). It may make section A moot.
2. Decide herds (6 v 8) and follow-up (fixed end, 180-day culling).
3. Fix B1 (culling denominator) - it changes the detectable-difference table.
4. Re-size §5, update §6, timeline and the budget together.
5. Fix B3-B7 in the same pass.
