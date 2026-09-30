---
name: nedap-proposal
description: Use when writing or revising the proposal to Nedap for the full three-arm lameness-camera study - covers the current design, where the sample-size inputs come from, the design constraints the pilot exposed, and how Gerard wants this written.
---

# Writing the Nedap three-arm study proposal

The NEDLAME pilot is finished. The proposal is `design/proposal_nedap_3arm_draft.qmd`. Every decision, derivation and correction behind it is in `design/review-proposal-2026-09-26.md`. **Read that review doc's last sections first (F, F2, F3, G, F4 - F4 is newest, at the end)** - they supersede anything older, including the working document `design/proposal_nedap_3arm.md` and `design/review-proposal-2026-09-10.md`.

## Current design (2026-09-30 night) - read before changing any number

**The design is 5,000 enrolled, 14 months (Gerard, 2026-09-30 night).** The proposal is written for 5,000; §5 ends with a "What 4,000 would lose" subsection and §9 lists 4,000 / 12 months / \$223,490 as a lower-cost option. The goal is to ESTIMATE - lead with the interval (±0.50 kg/day), power second. The case for 5,000 is the new-v-chronic difference (85% v 75%) and the secondaries, not milk precision. Review doc **F4-F6** has every figure.

| | 4,000 | 5,000 |
|---|---|---|
| Per arm / per herd | 1,333 / 667 | 1,667 / 833 |
| Enrolment / total | up to 6 / **12 months** | up to 8 / **14 months** |
| Power, 1.0 kg/day gain | **91%** | **95%** |
| Power, 0.75 kg/day gain | 72% | **81%** |
| 95% interval, milk | ±0.56 kg | ±0.50 kg |
| Culling 180 d, all enrolled | 3.8 pts (±2.8) | 3.4 pts (±2.5) |
| Cure WLD/SU, arm 1 v 2 | 12.8 pts (232 assessed) | 11.5 pts (290) |
| Recurrence 180 d, arm 1 v 2 | 8.5 pts (467) | 7.7 pts (583) |
| Dry-off (descriptive) | 9.0 pts (287); 5.2 at 18 months (912) | 8.1 pts (358); 4.7 at 20 months (1,140) |
| New-v-chronic difference (benefit only in new) | 75% - estimated | 85% - powered |
| Budget | **\$223,490** (v4 formulas with MO_ENROL 6, ENROLLED 4,000: \$182,500 / \$25,870 / \$15,120) | **\$267,110** (v4 as saved 2026-09-30: \$217,500 / \$31,970 / \$17,640) |
| Eight herds / 12 months after last cow | not recomputed / +\$22,560 | not recomputed (was ~+\$55,000) / +\$22,560 |
| Subscription (excluded) / extra trimming (excluded) | \$140,000-173,000 / ~\$19,500 | \$164,000-202,000 / ~\$24,000 |

Common to both: arms 1 trim within 1 week / 2 trim at 4 weeks / 3 farm practice (staff-spotted lame cows trimmed in every arm); enrolment at the first alert, DIM 5+, blocked on history and lactation group, enrolled once; six herds, two each NY / Midwest / West Coast, four minimum; every cow to one study end at least 6 months after the last cow; primary = milk arm 1 v 3 over 90 days with the 7-day pre-alert baseline as covariate.

**Primary analysis = the conventional multi-centre model** (Gerard, 2026-09-30 night): weekly milk, arm and herd FIXED, cow random intercept, **no arm-by-herd term**; the result is the effect in the enrolled herds. Arm-by-herd is checked and each herd's estimate reported, not part of the primary test. Hartung-Knapp / meta-analytic pooling was dropped as over-complicated for one trial under one protocol. p42's `fe13` column is this test.

The sizing comes from `scripts/proposal/p42_simulate_trial_cow_level.R` (cow-level simulation; review doc F3, F4). Old figures - 6,000, the HK powers (82% at 5,000, 72% at 4,000), ±0.66, "7,500 to power the chronicity difference", x1.09, "1.05 kg observed in the pilot" - are wrong now; do not reintroduce them.

## The proposal speaks ONLY of "the gain from acting on alerts" (Gerard, 2026-09-30 night)

- The primary number is the arm 1 v 3 milk difference, called **"the gain from acting on alerts"** in the proposal. Gerard: the true effect of being trimmed "is not what we are trying to show".
- **Never** put "true effect", "observed v true", "x0.49 / x0.50", "dilution factor", or benefit-from-the-day-she-is-trimmed language in the proposal. It is an unnecessary side trail. "Arm 3 is farm practice, not untreated: the farm trims 65% of arm-3 cows by day 90" is enough.
- **Internal mechanics, for the simulation only:** p42's `eff` is a per-enrolled-cow gain per day after trim; the arm 1 v 3 gain is about 0.49x it (p43: arm 1 spends 88% of the 90 days after a trim, arm 3 38%, difference 0.50). So a 1.0 / 0.75 kg gain = p42 `eff` 2.0 / 1.5. The CI rows 0.75-1.75 kg are p42 `eff` 1.5-3.5.
- **Open plausibility question (raised 2026-09-30, not in the proposal):** only 35-45% of alerted cows have a lesion, so a 1.0 kg/day gain across all enrolled cows needs about 4.4-5.7 kg/day per lesion cow (gain ≈ lesion share x 0.50 x per-lesion-cow gain). At 2-3 kg/day per lesion cow the gain is about 0.35-0.7 kg/day, where power is ~42-48% at a 0.5 kg gain. A lower bound of 1 kg needs a ~1.5 kg gain = 7-9 kg per lesion cow. Gerard has not decided whether to restate the target.
## What the study is sized on - do not blur this

- **Sized to DETECT a milk gain (1.0 kg/day at 4,000; 0.75 kg/day at 5,000). NOT sized to show the system pays.** Proving it pays is infeasible: break-even is 0.25-0.6 points of culling on all enrolled cows against a ±2.5-2.8 interval.
- **The effect sizes are design targets, not pilot estimates.** On the study's own outcome (kg, baseline-adjusted) the pilot shows +0.08 kg (SE 0.57). Do NOT put the old 1.05 kg (% of baseline) in the proposal, not even as a correction.
- **The study estimates whether the system pays; it does not prove it.** Say so wherever the question "does it pay" appears. §3's primary row is "How much does acting on alerts gain?" for this reason.
- The Economics section and its assumptions table were **removed** at Gerard's request (2026-09-29). The only economic inputs left are inline in the §5 limitation bullet (\$0.65-0.80 subscription, \$18 trim, \$1,650 net cull).

## Decided by Gerard - do not reopen

- No per-cow cost ledger; no Economics section.
- **5,000 is the design; 4,000 appears only as "what it would lose" (§5) and a budget option (§9).**
- **Conventional analysis (herd and arm fixed, no arm-by-herd term), not Hartung-Knapp.**
- **No history in the client document.** No old tests, superseded figures, "an earlier estimate was...", "a review found..." - that belongs in the review doc, memory and this skill. Pilot lessons that shape the design are fine.
- Six herds planned, eight a preference needing budget. Herd count barely moves power under the conventional test; the case for more herds is breadth and protection against losing one.
- Dry-off lesion descriptive; an outcome only with 12 months after the last cow.
- Late-lactation cows stay in and contribute milk until dry-off.
- Extra-trimming cost is ignored (§9 lists it as not included, nothing more).
- Herds must not routinely trim more than 2x per lactation. Herds that do are not enrolled. The pilot herd IS a 2x herd (mid-lactation + dry-off).
- The report's "August" v 2026-06-24 for first-lactation cows missing from SmartSight is pilot-specific; leave it.

### Sizing detail (p42, F3, F4)

- **False positives, conventional test, 4,000:** 5.4% with identical herds (its own null); 5.9% at the calibrated herd spread.
- **Power by N (gain 1.0 / 0.75 kg/day; p42 `eff` 2.0 / 1.5):** 3,000 84 / 60; 3,500 88 / 64; 4,000 91 / 72; 5,000 95 / 81; 6,000 97 / 88. The simple formula (`p43`) gives 94 / 98 at 4,000 / 5,000 - the sim is lower because the six herds' own average effect varies.
- **The one modelling choice that moves power:** whether dry-off trims count as arm-3 treatment. **Gerard: they do not.** If they did (simple formula): 85% at 4,000, 92% at 5,000.
- **Most sensitive inputs** (simple formula, 4,000 / 5,000): gain 0.75 kg 75 / 84; arm-3 farm trimming shrinks the gain 20% 80 / 88; variance 60 kg² 90 / 95. Simulated farm practice x2: 76 / 84.
- **Herd count at 5,000** (conventional): 4 / 6 / 8 / 10 herds at tau 0.25 = 95 / 96 / 94 / 97; 0.5 = 91 / 94 / 93 / 95; 0.75 = 87 / 90 / 90 / 92.
- **Chronicity:** intervals ±0.56 / ±0.50 overall, new ±0.71 / ±0.64, chronic ±0.90 / ±0.81, difference ±1.15 / ±1.03 (scaled by share of cows). Benefit only in new: difference 75 / 85%, new alone 99 / 100%.
- **Scripts:** `p42_simulate_trial_cow_level.R` (modes `[reps]`, `[reps] checks`, `[reps] ci` at 4,000 and 5,000, `[reps] herds [taus]`), `p43_simple_check.R`, `p40_detectable_differences_v2.R N`. Output `output/p42_run.log`, `p42_ci.log`, `p42_herds.log`, `.rds` alongside; the HK-era logs are `*_hk.log`. **`output/` is gitignored - local-only.** Regenerate with `Rscript scripts/proposal/p42_simulate_trial_cow_level.R 1000` (~1 h), `... 1000 ci`, `... 500 herds 0.25,0.5,0.75`. Use R 4.6.1 (`C:\Program Files\R\R-4.6.1\bin\Rscript.exe`); Rscript is not on PATH. The headline is the OBSERVED arm-1-v-3 difference - Gerard: only the observed difference shows whether it pays.
- **Do NOT redo:** the mechanistic routine-trim model (rejected, cannot reproduce the pilot); random x1.28 attrition (wrong - real loss is 36-41% and DIM-dependent); Kenward-Roger or HK as the primary test; p38/p41 figures.

## Still open for Gerard

Check the review doc's last section and the project memory before assuming this list is current.

- Budget: v4 re-saved by Gerard 2026-09-30 (herd 3,500 cows in milk, ON_FRAC 1) = \$267,110. The 4,000 figure (\$223,490) is computed from v4's formulas, NOT from v3 (deleted). Camera subscription: Gerard treats it as Nedap's cost of doing business; do not cost it. No contingency line: the buffer is the enrolment months budgeted beyond those expected (~\$21,800 per enrolment month).
- Keep or delete the §9 extra-trimming line (about \$19,500 / \$24,000, first alerts only).
- Header, §1 intro: Gerard is writing these himself.

**Answered 2026-09-30:** dry-off trims do NOT count as arm-3 treatment (p42 as modelled: 0.49 ratio, 82%). Arm-2 per-protocol is defined on the enrolling alert (the bullet's deletion was not deliberate; restored).

## Getting the numbers

**Never retype a figure from a report into the proposal.** Pilot figures come from `functions/fxn_nedlame_analysis.R`; write a script that sources it and calls the builders in order (`fxn_build_cohort` -> `fxn_build_lame_history` -> `fxn_build_enrolled_ids` -> `fxn_build_q4` -> ...), the way `scripts/step3_pipeline_losses.R` does. Proposal scripts live in `scripts/proposal/` (see its README).

For pilot results use the rendered `reports/qmd_reports/report_nedlame_treatment_comparison_fx.html`, not the `.qmd`: numbers are interpolated at render time. Key alignment with the final report: **a miss is a lesion with no NEDLAME at any time before it**; the 28-day window only sorts misses. Cohort 0/262, outside cohort 309/315. **Never quote 54.1%.**

## The budget workbook

Gerard's Excel edits make the WORKBOOK the source of truth. The only workbook is **`design/budget_nedap_3arm (version 4).xlsx`** (v1-v3 and the unnumbered one were deleted 2026-09-30). The 4,000 option is computed from v4's formulas with MO_ENROL 6 and ENROLLED 4,000. Edit it by XML surgery, or ask Gerard; **never re-run `p30_budget.R` or `p32_budget_xlsx.R`** (stale, would wipe his edits). The cached values in the workbook go stale; Excel recalculates on open. Neither session touches an xlsx without Gerard.

## Working with parallel sessions

Gerard runs more than one session on this proposal at once. Split the draft by section, and say the split out loud via SendMessage (the 2026-09-29 split: one session sample size - §5, top of §6 and chronicity, herd table, Appendix sizing rows; the other the rest). Rules that worked:

- Re-read just before every Edit; never Write the whole file; message the other session after each edit.
- Each session records its notes in its own review-doc section.
- One session owns memory and this skill at hand-off.
- **Gerard edits the draft in his editor at the same time.** His save overwrites anything written after his buffer loaded - it silently reverted a session's move once. After he says he saved, re-check your edits are still there. His editor also re-flows grid tables and has merged rows that had no separators.
- No commits until Gerard says so; then one joint commit.

## The design constraints the pilot exposed

These determine whether the study can answer its question.

- **Ascertainment is the central problem.** The pilot's "58 more lesions found" is explained by TX being trimmed 90.4% v Control 49.8%. Only outcomes that do not depend on being looked at (milk, culling on all enrolled) are randomized comparisons across arms 1 v 3. Cure and recurrence are compared on arms 1 v 2, where both are protocol-trimmed; arm 3 is descriptive.
- **Arm 3 dilution:** 28.6% of pilot Control cows were routine-trimmed within 60 days, strongly DIM-dependent (59.5% at DIM 61-120).
- **Conditions on Nedap (§7), stated as conditions, not wishes:** alert and score files as sent, with timestamps; alert rules and the LOW threshold frozen (threshold <30 v <70 still to choose with Nedap); every cow on the SmartSight instance, checked monthly. `EDAY=LMSFD` is unsafe - `LMSFD` frozen in the DC export since ~2026-02-02.
- **Pre-specify** the miss definition, timestamp semantics (05:00 load stamps the load day), lactation at alert, and save the trim list every trim day.
- **Do not frame DD detection as a defect.** Locomotion scoring detects DD poorly; that argues for a second modality.

## Verify what reviewers tell you

Agent findings have been wrong or inflated several times (and correct and consequential several times). Re-derive each before applying. Examples: the p42 review subagent's attrition finding (36-41%, not x1.28's 21.9%) was real; a pilot-side finding did not survive checking. This skill is not exempt.

## What Gerard will push back on

**A distinction the data cannot carry.** He removed the DD-on-a-hind-foot pattern, called the 21-day lookback "a bit arbitrary", and collapsed "caught in time" v "alerted too far ahead". Expect the same test on every arm, endpoint and cut-off: say what result would separate it from its neighbour. He also rejects overclaiming - e.g. "Control did not get washed out" when 28.6% was.

## How to write it

- **Short sentences, plain words, one idea each.** Bullets for parallel facts, prose for argument.
- **State the number, then what it means.**
- **Never state a null as a finding.** "Too few to tell" is not "no effect".
- **Never let a headline number travel without its caveat.**
- **No p-values at the discussion stage.**
- **Canadian spelling:** colour, centre, labour, enrolment; but randomize, analyze.

## Checks before it goes out

- Every number traceable to a computed object or the v4 workbook.
- Any figure appearing twice says the same thing in both places (grep for the old values: Hartung, random slope, 82%, 72%, 0.66, 7,500, 1,133). Both options must appear wherever a size, duration or cost does.
- The ascertainment problem is addressed by the design, not only in the limitations.
