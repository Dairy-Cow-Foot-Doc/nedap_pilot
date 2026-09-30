---
name: nedap-proposal
description: Use when writing or revising the proposal to Nedap for the full three-arm lameness-camera study - covers the current design, where the sample-size inputs come from, the design constraints the pilot exposed, and how Gerard wants this written.
---

# Writing the Nedap three-arm study proposal

The NEDLAME pilot is finished. The proposal is `design/proposal_nedap_3arm_draft.md`. Every decision, derivation and correction behind it is in `design/review-proposal-2026-09-26.md`. **Read that review doc's last sections first (F, F2, F3, G)** - they supersede anything older, including the working document `design/proposal_nedap_3arm.md` and `design/review-proposal-2026-09-10.md`.

## Current design (2026-09-30) - read before changing any number

| | Settled as |
|---|---|
| Arms | 1 trim within 1 week / 2 trim at 4 weeks / 3 farm practice. Staff-spotted lame cows are trimmed in every arm. |
| Enrolment | At the first SmartSight alert, DIM 5+, randomized daily, blocked on history (new/chronic) and lactation group. Enrolled once; the arm is a strategy for every later alert. |
| Size | **5,000 enrolled, 1,667 per arm, 833 per herd, six herds** (two each NY / Midwest / West Coast). Four is the minimum; eight is the preference (+ about \$55,000). |
| Duration | **14 months: up to 8 months of enrolment, every cow followed to one study end at least 6 months after the last cow.** 3.2-6.4 months of enrolment expected at 3,000-cow herds; 8 is the margin. |
| Primary | Milk, arm 1 v 3, 90 days, each cow's 7-day pre-alert milk as a covariate. Sized to detect **1.0 kg/day observed** (about 2.0 kg true - the observed contrast is ~0.49x the true effect because arm 3 is trimmed by farm practice). **Hartung-Knapp** test, arm-by-herd random slope. 82% power at 5,000 (72% at 4,000). |
| Secondary | Culling at 180 d on ALL enrolled (3.4 points on 16.0%, ±2.5); cure WLD/SU arm 1 v 2 (290 assessed, 11.5 points on 49.3%); recurrence 180 d arm 1 v 2 (583 with a first lesion, 7.7 points on 36.1%). |
| Descriptive | Lesion at dry-off (358/arm, 8.1 points). Becomes an outcome at **20 months** (12 after the last cow: 1,133/arm, 4.7 points, + about \$21,500). |
| Budget | **\$263,150** (\$217,500 personnel / \$30,530 travel / \$15,120 data), `design/budget_nedap_3arm (version 4).xlsx`. Excluded: subscription \$164,000-202,000; extra trimming. |

The sizing comes from `scripts/proposal/p42_simulate_trial_cow_level.R` (cow-level simulation; review doc F3). **It supersedes p38/p41.** The old figures - 6,000, 4,000, 365-day follow-up, 12 or 18 months, x1.09, "1.05 kg observed in the pilot" - are all wrong now; do not reintroduce them.

## What the study is sized on - do not blur this

- **Sized to DETECT a 1.0 kg/day milk contrast. NOT sized to show the system pays.** Proving it pays is infeasible: break-even is 0.25-0.6 points of culling on all enrolled cows against a ±2.5 interval.
- **1.0 kg is a design target, not a pilot estimate.** On the study's own outcome (kg, baseline-adjusted) the pilot shows +0.08 kg (SE 0.57). The old 1.05 kg was % of baseline, flattered by TX new cows' lower baseline.
- **The study estimates whether the system pays; it does not prove it.** Say so wherever the question "does it pay" appears. §3's primary row is "How much does acting on alerts gain?" for this reason.
- The Economics section and its assumptions table were **removed** at Gerard's request (2026-09-29). The only economic inputs left are inline in the §5 limitation bullet (\$0.65-0.80 subscription, \$18 trim, \$1,650 net cull).

## Decided by Gerard - do not reopen

- No per-cow cost ledger; no Economics section.
- Six herds planned, eight a preference needing budget.
- Dry-off lesion descriptive at 14 months.
- Hartung-Knapp as the milk test. Late-lactation cows stay in and contribute milk until dry-off.
- Extra-trimming cost is ignored (§9 lists it as not included, nothing more).
- Herds must not routinely trim more than 2x per lactation. Herds that do are not enrolled. The pilot herd IS a 2x herd (mid-lactation + dry-off).
- The report's "August" v 2026-06-24 for first-lactation cows missing from SmartSight is pilot-specific; leave it.

### Sizing detail (p42, F3)

- **The one modelling choice that moves power:** whether dry-off trims count as arm-3 treatment. **Gerard: they do not** (2026-09-30). As modelled, the observed/true ratio is 0.49 and power 82%. If they count: 0.43 and 71%. The simple formula `p43_simple_check.R` agrees with p42 (0.50, 83%).
- **Most sensitive inputs:** the true effect (1.5 kg -> 59%), arm-3 dilution (±20% -> 65 / 93%), between-herd SD (0.5 -> 69%).
- **Herd count at 5,000** (HK power): tau 0.25 -> 4 / 6 / 8 / 10 herds = 68 / 81 / 87 / 89%; tau 0.5 -> 47 / 65 / 76 / 84%. tau 0.75 -> 33 / 50 / 61 / 75% (from `output/p42_herds_075.log`; the 0.75 row in `output/p42_herds.log` is WRONG, tau was clamped).
- **Chronicity at 5,000:** ±0.67 overall, about ±0.85 new, ±1.1 chronic, ±1.4 difference. If the benefit is only in new cows: 96% power in new cows, 66% on the difference. Powering the difference needs about 7,500 (9.6 months of enrolment), so it stays estimated, not powered.
- **Scripts:** `scripts/proposal/p42_simulate_trial_cow_level.R` (modes `[reps]`, `[reps] checks`, `[reps] herds [taus]`), `p43_simple_check.R`. Output: `output/p42_run.log`, `output/p42_sim.rds` (main grid, 1,000 reps), `output/p42_herds*.log`. **`output/` is gitignored - these are local-only.** Regenerate with `Rscript scripts/proposal/p42_simulate_trial_cow_level.R 1000` (main grid, ~1 h), `... 500 herds` and `... 500 herds 0.75` (herd table).
- **Do NOT redo:** the mechanistic routine-trim model (rejected, cannot reproduce the pilot); random x1.28 attrition (wrong - real loss is 36-41% and DIM-dependent); z or Kenward-Roger as the test (Kenward-Roger gives ~55% at 4,000; HK decided); p38/p41 figures.

## Still open for Gerard

Check the review doc's last section and the project memory before assuming this list is current.

- Confirm the v4 budget total of \$263,150 by opening the workbook in Excel.
- Keep or delete the §9 extra-trimming line (about \$24,000, first alerts only).
- Header, §1 intro: Gerard is writing these himself.

**Answered 2026-09-30:** dry-off trims do NOT count as arm-3 treatment (p42 as modelled: 0.49 ratio, 82%). Arm-2 per-protocol is defined on the enrolling alert (the bullet's deletion was not deliberate; restored).

## Getting the numbers

**Never retype a figure from a report into the proposal.** Pilot figures come from `functions/fxn_nedlame_analysis.R`; write a script that sources it and calls the builders in order (`fxn_build_cohort` -> `fxn_build_lame_history` -> `fxn_build_enrolled_ids` -> `fxn_build_q4` -> ...), the way `scripts/step3_pipeline_losses.R` does. Proposal scripts live in `scripts/proposal/` (see its README).

For pilot results use the rendered `reports/qmd_reports/report_nedlame_treatment_comparison_fx.html`, not the `.qmd`: numbers are interpolated at render time. Key alignment with the final report: **a miss is a lesion with no NEDLAME at any time before it**; the 28-day window only sorts misses. Cohort 0/262, outside cohort 309/315. **Never quote 54.1%.**

## The budget workbook

Gerard's Excel edits make the WORKBOOK the source of truth. The current one is **version 4**. Edit it by XML surgery, or ask Gerard; **never re-run `p30_budget.R` or `p32_budget_xlsx.R`** (stale, would wipe his edits). The cached values in the workbook go stale; Excel recalculates on open. Neither session touches an xlsx without Gerard.

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
- Any figure appearing twice says the same thing in both places (grep for the old values: 4,000, 12 months, 18 months, \$220,250, \$45,000).
- The ascertainment problem is addressed by the design, not only in the limitations.
