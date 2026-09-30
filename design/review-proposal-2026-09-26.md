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


### G. Non-sample-size pass, 2026-09-29 (session f9, parallel with f3 on sample size)

Split with the sample-size session: f3 owns §5, §6 Milk/Cure/Dry-off block and chronicity, the §2 herd/tau table, ×1.28, Appendix sizing rows (notes in F3). This pass owns the rest.

Gerard: *"fix everything but 5 we are going to ignore the extra trimming cost. ignore 8 as that was pilot specific."*

- **§2 study end:** "12 months from enrolment" was wrong - one end date, 12 months after the study starts, at least 6 after the last cow.
- **§2 arm 3:** dilution now referenced to the 28.6% routine-trimmed within 60 days (what §5 uses), not the 49.8% trimmed at all.
- **§2 eligibility:** "Control arm did not get washed out" removed - 28.6% were, 59.5% at DIM 61-120. Replaced with the 2x-lactation fact (F2) and the consequence.
- **§2 arm 2:** the one-third contamination is on first alerts; since a cow keeps her arm for later alerts, per-protocol is defined on the enrolling alert and later deviations recorded. *A design choice made here - Gerard to confirm.*
- **§3:** kept Gerard's rewrite. Primary cell "Does acting on alerts pay?" -> "How much does acting on alerts gain?" to match §5 (estimates, does not prove). His "only outcome powerable at a realistic size" was not true (culling detects 3.8 points at 4,000) - now "the outcome the study is sized on".
- **Spelling:** randomized, enrolment, analyze; DairComp, lactayion, "daily to for" fixed. §5 still has two "randomisation" (f3's section).
- **Not done, by Gerard's decision:** extra-trimming cost (§9 $19,500 left as is); the report's "August" v 2026-06-24 for first-lactation cows (pilot-specific).
- **Gerard's editor re-flowed the Appendix grid table and merged three rows** (TX-Control days 25-30 / new v chronic / 28.6%) into one cell. Flagged to f3.
- **§3 Economics subsection removed** (Gerard, same night), with its assumptions table and the §8 "Economics reported as total dollars" bullet. Left dangling in f3's §5: the break-even lines (0.25-0.6 points) were built on the removed \$18 trim / \$1,650 cull inputs, and now cite nothing.
- **Fixed what the removal left behind:** §5 break-even now states its inputs inline (\$0.65-0.80 subscription, \$18 trim, \$1,650 net cull); the composite-dollar-endpoint line cut (it argued for reporting dollars, which §3 no longer does). §3 "why three arms" reworded from "economic signs / economic verdict by the extra-trimming cost" to cost v benefit of the empty arm-1 trims.
- **Pointers after f3 moved the herd table to §5 "How many herds":** §2 four-herd bullet and §8 six-herds bullet now point to §5.

### F3. Cow-level trial simulation, 2026-09-30 (session f3, `p42`)

Gerard asked for one simulation that holds every sizing assumption together, checked by a review subagent. `scripts/proposal/p42_simulate_trial_cow_level.R`, log `output/p42_run.log`, 1,000 reps per scenario.

**Decisions (Gerard, 2026-09-30):** cows alerted late in lactation stay in and contribute milk until they dry off; the pre-specified test is **Hartung-Knapp** (HK).

**What the review found (all checked before use):**
- Statistics code correct: per-herd least squares, DerSimonian-Laird, HK and the time-to-trim draws all match independent implementations.
- **Attrition was about 36-41%, not the 21.9% in x1.28, and not random.** Of 116 pilot cows alerted 90+ days before the milk data ended, 41 of 54 alerted at DIM 200+ stopped milking before day 85 (dry-off). Re-checked by f3. p38's x1.28 has the same problem.
- Kenward-Roger on the protocol's own mixed model: about 55% power at 4,000 (false positives 0.7%), in line with t on 5 df. So "4,000 at 80%" held only for the z test.
- Arm-1 timing had two nearly cancelling errors; the later-alert trim rate was overstated about 2x (most were re-fires of a pending trim); calibration comparisons used unlike definitions. All fixed.

**The model now:** cows leave milk at dry-off (herd's completed lactation lengths, conditional on DIM at alert) or culling (pilot 90-day rate: 30% at DIM 0-60, 8.7% after). They contribute their weeks, weighted by cow^2 + residual^2/weeks. Farm trimming comes from the pilot Control arm by DIM band. Arm 1 uses the pilot TX Kaplan-Meier time to trim. Between-herd SD 0.47 kg on the true effect, which gives 0.25 kg observed. Checks: arm-3 farm trimming matches the pilot by DIM band (5.3 / 52.2 / 34.9 / 19.5 against 5.1 / 54.7 / 35.0 / 19.5); still milking at day 85 is 63% model against 59% pilot (slightly optimistic); HK false positives 4.8%.

**Results:**
- **The observed arm-1-v-3 contrast is about half the true effect** (0.49x). Arm 3 is trimmed 64.7% by day 90 under farm practice. The 1.0 kg observed target needs about a 2.0 kg true effect.
- **Power, HK, 6 herds:**

| Enrolled | True 1.5 kg (obs 0.73) | True 2.0 kg (obs 0.98) | 95% CI half-width |
|---|---|---|---|
| 4,000 | 50% | 72% | ±0.75 kg |
| 5,000 | 57% | **82%** | ±0.66 |
| 6,000 | 64% | 85% | ±0.62 |
| 8,000 | 76% | 93% | ±0.56 |
| 10,000 | 83% | 97% | ±0.50 |

- **Lowest confidence bound at 4,000** (Gerard's question): the lower end is the estimate minus 0.75 kg. At an observed 1.0 kg (true 2.0) the median lower bound is +0.24 kg, with a 10th-90th percentile range of -0.29 to +0.72.
- **New v chronic** (benefit only in new cows, same 2.0 kg average): at 4,000, effect in new cows 89%, the difference 57%; 73% at 6,000; 84% at 8,000.
- **Farm practice** (6,000, true 2.0): pilot 87%; twice the routine trimming 74%; half 95%.
- **Arm 1 v 2** on milk: observed about 0.53 kg, 32% power at 4,000. Not powerable, as §4 says.
- **Extra trims from later alerts**, per enrolled cow: 0.32 (arm 1) / 0.24 (arm 2) at 180 days; 0.41 / 0.32 at 270. That is 20 pilot events.

**Applied 2026-09-30.** Gerard chose **5,000 enrolled, enrolment up to 8 months, 6 months of follow-up after the last cow = 14 months**; the proposal states what a 12-month version loses.
- §5 rewritten: target, power table, "How the sample size was simulated", "Checked with a simple calculation", "What the result is sensitive to", months tables for 833 per herd, the 14-month timeline, the detects table at 1,667 per arm, the limitation (culling ±2.5 points; milk lower bound about 0.3 kg).
- §6: Kenward-Roger replaced by Hartung-Knapp; chronicity at 5,000 (powering the difference would take about 7,500 - not done).
- Appendix rebuilt, merged row split, simulation inputs added.
- Budget v4 (`design/budget_nedap_3arm (version 4).xlsx`): v3 with enrolment 6 -> 8 months and 4,000 -> 5,000 cows; $263,150 by hand, to confirm in Excel.

**Simple cross-check (`p43_simple_check.R`, Gerard's request).** Textbook formula plus the pilot's raw time-to-trim curves, none of p42's machinery. Dilution 0.50 (p42 0.49); CI ±0.70 kg (p42 ±0.66); HK power at 5,000 83% (p42 82%). **The one choice that moves it:** whether a dry-off trim counts as arm-3 treatment. The raw curve counts it (0.43, 71%); both calculations leave it out, because the cow leaves the milk outcome days later. Sensitivities at 5,000 (HK): true effect 1.5 kg 59%; arm-3 dilution +/-20% 65% / 93%; between-herd SD 0.5 kg 69%, 0.75 kg 52%; variance 42.4 / 60 kg^2 88% / 78%; 15% of cows with no milk 78%; 4 / 8 herds 66% / 89%.

**Herd table at 5,000** (HK power, true 2.0 kg): p42 herds mode. The first run's 0.75 kg row was wrong - tau was clamped at the edge of the calibration grid - and has been re-run with the tau mapping extrapolated.
- **Re-based to Gerard's choice (2026-09-30): 5,000 enrolled, up to 8 months of enrolment, 6 months after the last cow = 14 months.** Values from f3 (p42, F3). Applied in §2/§4/§8/§9: 14 months; 20-month option (was 18) makes dry-off an outcome (1,133/arm, 4.7 pts; 358/arm, 8.1 pts at 14 months); "about 5,000 rather than roughly 11,000" without baseline (scaled by variance, not simulated); budget v4 \$263,150 (\$217,500 / \$30,530 / \$15,120); eight herds about +\$55,000, about \$318,000; 20 months about +\$21,500 (scaled from v3's 6-month PM + data increment, not in the workbook), about \$285,000; subscription \$164,000-202,000, 62-77%; extra trimming scaled 4,000 -> 5,000 as about \$24,000 (first alerts only).
- **Hand-off complete (2026-09-30):** f3 finished §5 (herd table as HK power at 5,000) and §6; draft consistent at 5,000 / 14 months / $263,150. Skill and memory updated for both sessions. Uncommitted.
- **Gerard, 2026-09-30:** dry-off trims are NOT arm-3 treatment (p42 as modelled, 82%). The arm-2 per-protocol bullet's deletion was not deliberate - restored (defined on the enrolling alert). Still open: confirm v4 in Excel; keep or delete the §9 extra-trimming line.
