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

------------------------------------------------------------------------

## E. Done (same day, second pass) - read this first next session

Gerard: *"if we go 12 months total ... Fix the 3 problems ... redo the sample size by including base line milk, how would we handle cows that calve during the study ... Do suggested or as you recommended."*

**D2 settled, and it rescued the timeline** (`p38`). Baseline-adjusted milk holds over 90 days (r = 0.889). Planned at the 90th bootstrap percentile of the variance, with the random slope: **4,000 enrolled at six herds** (3,800 at eight). Without the baseline: 7,500. So section A4 (8 herds) is no longer needed; six herds stays, eight noted as stronger.

**Applied to the draft (draft 4, `9664f79`):**

- 12 months: enrolment up to 6 (2.6-5.1 expected at 3,000-cow herds, 0.010-0.020), every cow followed to one study end, at least 6 months after the last cow. Culling and recurrence at 180 days; 365 where cows reach it.
- **B1** culling on all enrolled cows, 16.0% at 180 days, detects 3.8 points; ±2.8 interval.
- **B3/B4** one trim cost ($18) and one cull cost ($1,650); break-even 0.7-1.8 points per lame cow (0.25-0.6 on all enrolled).
- **B5** alert-rate tables at 0.010-0.020; **B6/B7** stale figures removed; §6 random slope + Kenward-Roger + baseline covariate; chronicity re-based (8,000 to power it).
- **Cows that calve during the study** (§2): enrolled once, keep their arm as a strategy for every alert; milk read in the enrolment lactation only (drying off = attrition); culling and recurrence follow the cow across calving; dry-off lesion at the enrolment lactation's dry-off.

**12 months, answered:** cure (60-day recheck) and milk are complete for every cow. Culling at 180 days is complete for every cow with enrolment at 6 months or less. Recurrence at 180 needs a lesion first, so the last few weeks of enrolees fall short and are censored. **Nobody reaches 365 days in all cows** - that is the price, and 93% of the culling gap is in by 180.

**New problems found on the way:**

- **Recurrence 48.7% could not be reproduced.** Same-lactation 36.7%, cow-level 52.4% at 365. Now 36.1% at 180, cow-level, scripted.
- **Dry-off lesion is the outcome the 12-month design hurts most** - only 21% of cows reach dry-off within 6 months of their alert. Kept as secondary, stated as weakest. Candidate to demote to descriptive.
- **Binary outcomes have no between-herd term in their sizing** - the pilot cannot estimate it. Stated in §5.
- **The milk variance rests on 114 cows.** Hence the 90th-percentile planning value. Refit when more pilot milk arrives.

**Budget v3** (`design/budget_nedap_3arm (version 3).xlsx`): 6 + 6 months, 4,000 enrolled. **$220,250** by hand-check ($182,500 personnel, $24,790 travel, $12,960 data), $55 per enrolled cow. Excel recalculates on open. The buffer is the enrolment slack (6 months budgeted, 2.6-5.1 expected). Gerard prefers to over-budget and be negotiated down - options if he wants more: keep 9 enrolment months (visits), or add analysis days.

**Still open:** D1 (ledger denominators - "milk alone does not cover it" kept verbatim); herd count final (6 v 8); whether dry-off stays secondary.

------------------------------------------------------------------------

## F. Third pass, 2026-09-29 - open decisions closed, aligned with the final report

Gerard: *"we don't need a cost ledger/cow etc as we just want to show total $. Go with 6 herds and leave 8 as preference but requires more budget. Make dry off lesion descriptive but add if we extend study to 18 months we could make it an outcome. Then align proposal with report."*

- **D1 closed by removing it.** The per-lame-cow ledger and "Milk alone does not cover the cost" are gone from §3. §3 now says the study reports total dollars by arm. §5 break-even is stated on all enrolled cows only (0.25-0.6 points).
- **New §9 Budget**, from `budget_nedap_3arm (version 3).xlsx` by hand-check: \$220,250 (\$182,500 / \$24,790 / \$12,960). The workbook's cached values are stale (e.g. D46 = 18 months); Excel recalculates on open.
  - Eight herds: +\$44,320 (2 herds x 6 visit-days x \$2,500 + 4 initial visit-days + data), plus travel -> "about \$45,000, about \$265,000".
  - 18 months: +\$15,000 project management + \$6,480 data = \$21,480 -> "about \$242,000". Visits unchanged (follow-up is passive).
  - Not included: subscription \$140,400-172,800 (64-79% of the budget - the workbook label "larger than everything above combined" is no longer true); extra trimming 4,000 x 2/3 x 0.406 x \$18 = \$19,488.
- **Six herds**; eight stated as preference needing budget. "Herds are cheaper insurance than cows" was wrong at the planning value (8 herds saves 200 cows for ~\$45k) - reworded as insurance against tau 0.5-0.75.
- **Dry-off lesion descriptive.** At 18 months (12 months after the last enrolment, 68% reach dry-off, 906/arm) it detects 5.2 points vs 9.0 - same power.prop.test basis that gives 9.0 at 287.
- **Aligned with the final report:**
  - §6 miss definition: "no NEDLAME at any time before the lesion"; the 27.9/11.5, 15.4 -> 1.4 and "twenty v four" figures (pre-Round-35 lookback framing) removed. 0/262 and 309/315 quoted.
  - §6 "miss count did not move at 14-45 days" removed (true by definition, Round 39). Window now described as sorting misses, not deciding them.
  - §7 item 2: the LOW threshold (<30 v <70) is an open question to settle with Nedap before freezing.
  - §7 new item 3: every cow on the SmartSight instance, checked monthly - 160 first-lactation cows absent after 2026-06-24 (report, "Was a Miss a NEDAP Now problem?").
- **Not done (Gerard handling):** header still "Draft 4", §1 intro, other small items.
- **Recurrence moved from descriptive to secondary, arm 1 v 2** (Gerard asked why randomisation would not protect it). The first lesion is found by protocol in both arms 1 and 2, so the at-risk cows are comparable - the same argument as cure. Arm 1 v 3 is not: arm 3's first lesions are farm-caught only. 467 per arm with a first lesion (35% of 1,333) detects 8.5 points on 36.1% (re-checked). ITT and per-protocol; time-to-recurrence because arm 2 trims later alerts at four weeks.

### F2. Sample-size pass after Gerard's edits (2026-09-29, `p41`)

- **The 1.05 kg is not what the pilot shows on the study's own outcome.** It was milk as % of baseline, unadjusted (97.9 v 95.4 at days 25-30). Baseline-adjusted kg, same cows and days: **+0.08 kg (SE 0.57)**; raw kg -0.24; days 1-30 adjusted -0.32. The % figure is flattered by TX new cows' lower baseline (39.5 v 41.8 kg). §5 now calls 1.0 kg a design target, not a pilot estimate; "implies a true effect near 1.5 kg" removed. The 4,000 is unchanged - it was always sized to detect 1.0 kg.
- **New v chronic, pilot (days 1-30, adjusted):** new +0.39 kg (-0.64 to 1.42), chronic -1.45 (-2.75 to -0.15), difference 1.84 (0.18 to 3.50). Gerard expected this direction.
- **§6's chronicity numbers were wrong.** "±1.0 kg interaction interval" was a within-subgroup interval at a 50/50 split; "8,000 to power it" (2x) was also the 50/50 subgroup figure. At 61% new, 6 herds, tau 0.25, the random-slope simulation gives at 4,000: overall ±0.65, new ±0.81, chronic ±1.02, difference ±1.29. To power the difference: 4,700 (1.84 kg), 7,100 (1.5 kg), 16,700 (1.0 kg). Still "estimated, not powered" - Gerard has not chosen to power it.
- **Routine trimming depends on DIM at alert** (pilot Control, >= 60 d follow-up, n = 147): routine-trimmed within 60 days 2.5% at DIM 0-60, 59.5% at 61-120, 34.5% at 121-200, 16.7% at 200+; 28.6% overall. Herd routine trims sit at DIM 90-150 (lact 1-2) and 120-200 (3+). The 1.0 kg target assumes about this dilution. The 4,500 / 6,400 at 45% / 60% coverage are scaled from the old working-doc sweep, not re-simulated.
- **Corrected (same day):** I first said Gerard's <=2x-per-lactation criterion was looser than the pilot. Wrong - the pilot herd IS a 2x herd: completed lactations dried off 2025-09 to 2026-09 (n = 2,819) average 1.9 / 2.0 / 2.4 non-staff trims (lact 1 / 2 / 3+), 50% exactly two; mid-lactation 1.1-1.6 plus dry-off ~80%. So the criterion matches the herd the 28.6% came from. What drives dilution is where the mid-lactation trim falls relative to alerts, not the count. Later-alert rule (his §2 text) will raise extra trimming above the §9 figure, which came from first alerts over a 3-month window.
