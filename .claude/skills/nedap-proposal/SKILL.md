---
name: nedap-proposal
description: Use when writing or revising the proposal to Nedap for the full three-arm lameness-camera study - covers the design constraints the pilot exposed, where the sample-size inputs come from, and how Gerard wants this written.
---

# Writing the Nedap three-arm study proposal

The NEDLAME pilot is finished and **a full draft proposal exists**: `design/proposal_nedap_3arm_draft.md`. Read it first. The working document `design/proposal_nedap_3arm.md` holds every derivation, check and correction behind its figures.

**The design is settled.** Three arms - trim within a week, trim at four weeks, regular farm practice. Enrol at the alert. Six herds of 2,000-5,000 cows across three regions, four as a minimum. **6,000 cows enrolled**, powered on a 0.98 kg/day observed milk contrast between arms 1 and 3. Enrolment closes in 3-6 months; the 365-day culling follow-up sets the 15-18 month duration.

## Before writing anything

Read, in this order:

1. `reports/qmd_reports/report_nedlame_treatment_comparison_fx.html` — the full pilot report. The rendered page, not the `.qmd`: numbers are interpolated at render time.
2. `design/review-findings-2026-09-08.md` — 24 findings against the pilot, all closed. Sections G and H record what did *not* land as written and why. This is where the design mistakes are catalogued.
3. `qmd_reports/plan_nedlame_treatment_comparison.qmd` — the round-by-round record, including the design decisions and their justifications.

## Getting the numbers

**Never retype a figure from a report into the proposal.** Every number the pilot produced is computed by `functions/fxn_nedlame_analysis.R`. To get a fresh one, write a script that sources that file and calls the builders in order (`fxn_build_cohort` -> `fxn_build_lame_history` -> `fxn_build_enrolled_ids` -> `fxn_build_q4` -> ...), the way `scripts/step3_pipeline_losses.R` does. Copy its header for the setup.

Sample-size inputs already computed are in the `project-nedap-3arm-proposal` memory. Recompute rather than trusting them if the data has been refreshed since.
There is also groundwork already built for the follow-up, from Round 5:

- `mcp_server/knowledge/lessons-learned.md` — the four analysis bugs and their root causes, plus the design choices that look like bugs but are deliberate. Written explicitly to be read before building the 3-arm analysis.
- `mcp_server/knowledge/methodology-patterns.md` — ten patterns already generalised to N arms (group-code drift, lactation-safe vs lifetime joins, rolling lookback for a monitor with a go-live date, KM faceting, same-day diagnoses).
- `mcp_server/` — an MCP server exposing both as resources, plus `generate_treatment_group_r_code`, which takes an arm-label map of any size. Register with `claude mcp add`; see its README.

One design proposal is already on record, from Round 8: **instrument the Nedap-to-DairyComp integration from day one** — log every raw flag with a timestamp, independent of the DC import — rather than reconstructing pipeline losses afterwards from cowcard spot-checks. That is the same conclusion the pilot reached the hard way, and it should be a design feature of the next study rather than a data request.

**Answered since this skill was written:** the third arm is the 4-week-delayed trim. What remains open is the sample size section.


## The design constraints the pilot exposed

These are not caveats to mention — they determine whether the study can answer its question.

**Ascertainment is the central problem.** The pilot's headline benefit (58 more cows with a lesion found, 170/397 TX vs 127/452 Control) is entirely explained by TX cows being trimmed 90.4% of the time against Control's 49.8%. Because allocation was random, lesion incidence is equal by construction — the difference measures who got inspected, not who got sick. A three-arm design repeats this at greater cost unless it either imposes a common inspection schedule across arms or picks an outcome that does not depend on being looked at.

**Detection is the only outcome this farm can power.** Milk needs 585 cows/arm to detect 5 percentage points and 1,737 for the 2.9 points actually observed — 75 weeks of accrual at 69 alerts/week. Culling had 53 events total. The miss rate (54.1% of 579 lesion cases) has the largest effect and smallest variance of anything measured.

**Two things must come from Nedap as a condition of the study**, because the pilot could not close them:

- **Score at flag.** Its absence left 69 pipeline cases permanently unjudgeable — a `Low` flag on a cow scoring 31-69 who was correctly declined is indistinguishable from a lost flag.
- **The daily file-in log.** 119 of 313 misses were cows the camera flagged whose alert never reached DairyComp. The export shows episode start/end and completion but not the daily payload, so the mechanism could not be identified.

**Pre-specify the miss definition.** The lookback window is a judgement call that moved the answer: 21 days vs unbounded took the Control miss rate from 27.9% to 10.7% while barely touching TX. Also specify how a cow alerted *outside* the window is treated — the pilot settled on "alerted, not a miss, if nobody acted between the alert and the lesion", after starting somewhere else.

**Specify the timestamp semantics.** The ~5am batch stamps each alert with its load date, so an attention after 5am on day D is logged as D+1. The pilot needed a post-trim exclusion (162 alerts) and a strictly-before window because of this.

**Do not frame DD detection as a defect to be fixed.** Locomotion scoring detects digital dermatitis poorly and the camera scores locomotion; DD is 42% of what it never flagged against 21% of what it caught, while white line runs the other way. If DD matters to the study, that argues for a second modality, not for expecting more from this one.


## What is settled, and what it rests on

| Decision | Settled as | Because |
|---|---|---|
| Enrolment point | At the alert | Freshening costs x1.6 cows and double the time, and buys nothing unless detection accuracy is a question. It is not. |
| Primary outcome | Milk, arm 1 v arm 3, 90 days | The only milk contrast powerable at a realistic size and the one insensitive to window choice. |
| Cure comparison | Arms 1 v 2 primary, arm 3 descriptive | Both of 1 and 2 are protocol-trimmed so the contrast is clean; arm 3's cure is measured on farm-detected lesions that may be more severe. |
| Chronicity | Blocked in randomisation, interaction explored not powered | Powering it doubles the study to 11,500. The price is in the draft should Nedap want it. |
| Culling follow-up | 365 days | The gap is still widening at six months - 6.8 points against 7.3 at twelve. |
| Reproduction | Dropped | The herd's records show a one-day difference in days to first service. Nothing to power against. |
| Economics | Reported, not powered | The inputs do not affect the sample size, so a reader can substitute their own without changing precision. |

## The one thing to be honest about

**The study estimates whether the system pays; it does not prove it.** Break-even needs about 1 percentage point of avoided culling, and the design's interval on culling is +/-5.2 points. Detecting 1 point would take on the order of 200,000 cows. This is stated in the draft's §4 and should not be softened - a good estimate with honest uncertainty is what a purchasing decision needs, but it is not a hypothesis test.

## If the numbers need recomputing

Everything traces to `functions/fxn_nedlame_analysis.R`. The economic model is `C:/Github/camera_math/app.R`, which now carries trim cost and an optional avoided-culling credit. Sample-size and simulation scripts from this work were scratch files, not committed - the draft's appendix lists every pilot figure used, so they can be re-derived from the shared functions rather than recovered.

## What Gerard will push back on

He has now rejected the same thing three times, and it is predictive rather than incidental: **a distinction the data cannot carry.**

- The DD-on-a-hind-foot conjunction - a real pattern, but it answered a question he had not asked and rested on ~81 cases. Removed entirely.
- The 21-day lookback separating a miss from a catch - "a bit arbitrary", and it moved the Control miss rate from 27.9% to 10.7%.
- The farm report's split between "caught in time" and "alerted too far ahead" - "it could be a warning of that lesion and we don't know so lets say they are alerted".

Expect the same test applied to the proposal. Any arm, endpoint or cut-off that the study could not actually distinguish will be challenged, so state for each one what result would separate it from its neighbour.

**The question to answer before it is asked:** why is a three-arm study worth the cost if inspection is not common across the arms? On the pilot's own numbers the answer is uncomfortable - the benefit it appeared to show was ascertainment. Address this in the design section, not the limitations.

## How to write it

Gerard's style, learned across the pilot:

- **Short sentences, plain words, one idea each.** He rewrote the full report specifically because it was wordy. Cut throat-clearing: no "Due to the fact that", no "It should be noted that", no sentence explaining what the next sentence will do.
- **Bullets for parallel facts**, prose for argument.
- **State the number, then what it means.** Not the reasoning, then the number.
- **Never state a null as a finding.** "Too few events to tell" is not "no effect". This was a review finding against the pilot.
- **Never let a headline number travel without its caveat.** The 58-cow figure reads as a treatment effect to anyone who meets it alone; the ascertainment clause belongs in the same breath, every time.
- **No p-values at the discussion stage** — see `feedback-nedlame-pilot-workflow` memory.

## Checks before it goes out

- Every number traceable to a computed object, not typed from a report.
- Any figure appearing twice says the same thing in both places. The pilot repeatedly went stale this way.
- The ascertainment problem is addressed by the design, not just acknowledged in the limitations.
- The two data requests to Nedap (score at flag, file-in log) are stated as conditions, not wishes.
