# Evaluating the efficacy and cost-effectiveness of Nedap SmartSight

**Draft 1 — 2026-09-10.** Builds on the "NEDAP Proposal Idea" outline, a colleague's review comments, and the completed two-arm NEDLAME pilot. Every figure attributed to the pilot is computed from its data; nothing here is an estimate unless it says so.

**Open items are marked ▶ and are genuine decisions, not placeholders.**

---

## 1. Objective

Determine whether acting on Nedap SmartSight lameness alerts improves cow outcomes enough to pay for the system, and whether acting *early* matters more than acting at all.

Two questions, deliberately separated:

1. **Does the system help?** Alerted-and-treated against alerted-and-not-treated.
2. **Does speed matter?** Treated within a week against treated at four weeks.

The pilot could answer neither. It compared "trim off the alert" against "farm discretion", and farm discretion turned out to be mostly the routine trim schedule catching up — only 80 of 225 trimmed Control cows had a staff check first. So the pilot's contrast was the camera against a mixture, and roughly two thirds of that mixture was not an active decision at all.

---

## 2. Design

Randomised controlled trial, **three arms**, **one year**, **multiple herds**.

### Enrollment is rolling, not cross-sectional

▶ *This answers the reviewer's first question and it needs confirming, because the outline did not say.*

A cow enters the study **at her first SmartSight alert**, not at study start. Randomisation happens at that moment. Consequences:

- The study population is *alerted cows*, so every arm is comparable by construction — all three contain only cows the camera flagged.
- Accrual is continuous. In the pilot one farm produced **849 alerts in 86 days, about 69 per week**. A cow enrolled in month 11 has one month of follow-up, so the analysis must handle staggered entry (time-to-event models, and milk indexed to days-since-alert rather than calendar date).
- **Cross-sectional enrollment would not work here.** Randomising every cow at study start means most of the sample never gets alerted, and the arms would differ only among those who do — a much larger study for the same information.

### Arms

All three arms sit on a common floor: **if farm staff identify a cow as lame, she goes on the trim list and is treated, regardless of arm.** This is an ethical requirement and it is not negotiable.

| Arm | Intervention |
|---|---|
| **1. Early treatment** | Trim chute for evaluation and treatment within **1 week** of the alert. |
| **2. Delayed treatment** | Trim chute for evaluation and treatment at **4 weeks** after the alert. |
| **3. Alert only** | Alerted, recorded, **not** acted on. Treated only if staff find her. |

### Two things the reviewer's questions expose about this structure

**"Basically the treatment groups all rely on the system. No one at the farm will be picking lame cows, right?"**

Staff detection continues in all three arms and cannot be switched off. That makes it a **co-intervention**, and the design has to treat it as one:

- It is **recorded as an event** (`CHKLAME`) with its date, for every cow in every arm.
- In arm 3 it is the *only* treatment pathway, so arm 3 is not "untreated" — it is "treated only when a human notices". That is the honest comparator and it should be named that way in the protocol.
- Its magnitude is known from the pilot and it is modest: of cows whose lesion the camera had not flagged, staff caught **16.3% within 7 days**. So arm 3 will be largely, but not entirely, unmanaged.

**"In item 2b the false positives are the ones that would not develop lesions because you treated them early, correct?"**

Yes, and the outline was ambiguous about it. The precise statement:

> A cow trimmed in arm 1 with no lesion found is **unidentifiable** from the trim alone. She is either a camera false positive, or a true positive whose lesion was prevented by early intervention. **Arm 2 is what separates them.** If a meaningful share of arm-2 cows have a visible lesion at four weeks where arm-1 cows had none at one week, the arm-1 no-lesion trims were prevention, not error.

This is the single most valuable feature of the three-arm structure and it should be stated as a primary rationale, not a sub-bullet.

---

## 3. Eligibility

### Herds

- **Reliable** hoof trimming data (reviewer's wording, and better than "good" — the requirement is that records are complete and consistently coded, which is checkable).
- Trained hoof trimming staff, so treatment is competent.
- Daily milk weights.
- Able to install and run SmartSight.

### Cows

▶ **Recommendation: drop the "no lameness treatment in the current lactation" restriction. Enroll all cows and handle history in the analysis.**

The reviewer argued this on external-validity grounds — there are no farms without lameness, and the technology's value is in managing it going forward. The pilot data supports that, and quantifies the cost of the restriction:

| | Cows | With lameness history | Eligible under a "no history" rule |
|---|---|---|---|
| Lactation 1 | 177 | 15.8% | 84.2% |
| Lactation 2 | 272 | 29.8% | 70.2% |
| Lactation 3+ | 400 | **54.8%** | 45.2% |
| **All** | **849** | **38.7%** | **61.4%** |

The restriction costs 38.6% of the sample, but the real problem is that **it does not cost it evenly**. It removes over half of mature cows and only a sixth of first-lactation cows, so the study population would be systematically younger than the population the system is sold to manage. That is a bias in the direction that matters, not just a smaller n.

Handle history instead by:

- **Stratifying randomisation** on history (present / absent), so the arms are balanced on it rather than purged of it.
- **Adjusting** for it in every model, and testing the interaction (below).

### The chronicity × lactation interaction

▶ *The reviewer asked whether this was ever looked at. It was not, until now.*

Two observations from the pilot, both **hypothesis-generating and not conclusive**:

**Recurrence rises steeply with parity.** Among cows with an index lesion, the share with another lesion within 365 days:

| Lactation | Cows | Recurred |
|---|---|---|
| 1 | 661 | 34.0% |
| 2 | 1,099 | 47.7% |
| 3+ | 3,560 | 51.8% |

**Cows with lameness history appear to be missed by the camera more often.** Among alerted cows who were later found with a lesion, the share the camera gave no useful warning for was **17.3% with history against 3.0% without**. The cell counts are small (156 and 135 cases) and this is exactly the kind of pattern the pilot learned to distrust before checking base rates, so it is offered as a question for the full study rather than a finding.

Both argue for **powering the interaction rather than adjusting it away.** ▶ That materially raises sample size and is a decision to take deliberately.

---

## 4. Outcomes

### The measurement problem that shapes all of them

The pilot's most quotable result was that trimming off the alert found lesions in **58 more cows** than the control approach (170 of 397 against 127 of 452). **That number measures inspection, not disease.** TX cows were trimmed 90.4% of the time by protocol; Control cows 49.8%. Randomisation makes true lesion incidence equal by construction.

Confirmed rather than assumed: among cows actually trimmed, **Control found a lesion *more* often** (53.8% against 45.1%), which is what a suspicion-driven population looks like, not a healthier one.

**So any outcome that depends on being looked at is confounded across these three arms**, because arm 1 is inspected ~100%, arm 2 ~100% at four weeks, and arm 3 only when staff notice.

### The fix: measure at the routine dry-off trim

Every cow is trimmed around dry-off regardless of arm, which makes it an **arm-independent inspection point**. Verified in the pilot: dry-off trim coverage was **88.6% in Control against 92.7% in TX, p = 0.62**. No detectable difference.

Two things the protocol must get right, both found in the data:

- **It is a window, not a day.** Trims cluster **21 to 7 days *before*** dry-off. A ±7-day definition catches only 9.6% of them; a −45 to +7 day window catches about 90%.
- **Coverage is ~90%, not 100%**, so the ~10% who miss it need a pre-specified handling rule.

▶ **Recommendation: make lesion status at the dry-off trim a primary outcome.** It is the only lesion measure in this design that is not confounded by arm, and it directly answers "did acting on alerts leave cows with healthier feet at the end of lactation".

### Primary outcomes

1. **Daily milk production**, from **before** the alert through 2–3 months after.

   ▶ *The reviewer asked why the pre-detection period was not included. It should be, for two reasons.* Each cow's own pre-alert production is the baseline the post-alert curve is normalised against — the pilot used the mean of the 7 days before the alert, because cows at different lactation stages are not comparable in absolute terms. Beyond that, the pre-alert slope is informative in itself: it shows how much production was already being lost before the camera fired, which is part of the value case.

2. **Lesion status at the dry-off trim** (see above).

3. **Recurrence within 365 days** of a first lesion. This is the best-powered clinically meaningful outcome available — see §5.

4. **Culling hazard** to 6 months.

### Secondary outcomes

- **Whether staff also detected her, and when.** ▶ *The reviewer is right that this is entangled with treatment.* In arm 1 the cow is trimmed within a week, so staff rarely get the chance — time-to-staff-detection is censored by the intervention itself. It is interpretable in arms 2 and 3, and in arm 1 only as "did staff beat the protocol". State that rather than reporting one number across arms.

- **Share of trims finding a treatable lesion.** ▶ *The reviewer's point here is the sharpest in the review and it changes the interpretation.* If early treatment prevents lesions, arm 1 will show *fewer* lesions per trim. Read as diagnostic accuracy that looks like poor sensitivity; read as clinical effect it is the study succeeding. **The design cannot have it both ways, so it must declare which reading applies:** lesions-per-trim is reported as a *description of the trims*, and the efficacy question is answered by the dry-off prevalence and the recurrence outcomes instead.

- **Reproductive outcomes.** ▶ Not powered as primary without a stated effect size.

### Outcomes needing an external reference standard

▶ **Is the camera validated? What do locomotion scores add?**

Honest answer: the pilot had **no reference standard at all**. It could compare the camera against what the farm happened to find, which is not the same as truth. It established that the camera missed 54.1% of lesion cases and that digital dermatitis was over-represented among misses (42% of what it never flagged against 21% of what it caught), but it could not distinguish "the cow was not lame" from "the camera did not see it".

Human locomotion scoring, or a second independent camera, supplies that reference standard. Its value is specific:

- It makes **sensitivity and specificity estimable**, which no amount of trim data can do.
- It measures **duration of lameness**, an outcome the pilot could not touch and one that matters clinically and to welfare.
- It tests the DD blind spot directly. Locomotion scoring is known to detect DD poorly, so a camera scoring locomotion missing DD is expected — but only a reference standard can show whether the camera is worse than a human scorer or merely equally limited.

▶ Cost and feasibility of scoring at the required frequency is a decision, not a given.

---

## 5. Sample size

All figures below are computed from the pilot at 80% power, two-sided alpha = 0.05, using closed-form formulae. They ignore within-cow correlation across repeated measurements and the blocking the design will actually use, so treat them as order-of-magnitude guides. **The simulation reconciliation below supersedes them for milk.**

### Recurrence — the best-powered outcome

Baseline 365-day recurrence after an index lesion, counting only lesions 14+ days later so a same-episode recheck does not inflate it: **48.7%** (90 d: 19.5%; 180 d: 32.5%; 270 d: 43.3%).

| Relative reduction | Per arm | Three arms |
|---|---|---|
| 20% (48.7 → 39.0) | 406 | 1,218 |
| 30% (48.7 → 34.1) | 177 | 531 |
| 40% (48.7 → 29.2) | 98 | 294 |

These count **cows with an index lesion**. About 43% of alerted cows developed one in the pilot, so 406 index cases per arm needs roughly **950 enrolled per arm, ~2,850 total** — about 41 weeks at one farm's 69 alerts/week, comfortable inside a year across several herds.

### Milk

Percentage of each cow's own pre-alert baseline at days 25–30: TX 98.3% (SD 32.3), Control 95.4% (SD 28.5). Pooled SD ≈ 30.5.

| Difference to detect | Per arm | Three arms |
|---|---|---|
| 2.9 points (as observed) | 1,737 | 5,211 |
| 5 points | 585 | 1,755 |
| 7.5 points | 260 | 780 |

### Culling

6.2% over the pilot window, on only 53 events. 6.2% vs 4.0% needs 1,569 per arm; vs 3.0%, 672. Feasible across a year and several herds, but not at one farm.

### Reconciling with the existing simulation

A simulation already exists at `C:\Github\nedap_camera\sample size simulation.qmd`. Its structure is right and better than a closed-form calculation: it blocks on lactation and history, models five herds, uses `glmmTMB` with `treatment × history` and a spline on DIM, and — most importantly — **defines success as the lower 95% confidence bound exceeding a break-even, not as p < 0.05.** That is the correct criterion for a cost decision and it should be kept.

**Its input parameters are the problem.** They were assumed; the pilot can measure them. Fitting the same model shape to the pilot's real daily milk (weekly averages, `kg ~ arm × history + parity + ns(DIM) + (1|cow)`, 3,601 weekly records on 828 cows):

| Parameter | Simulation assumes | **Pilot measures** | Ratio |
|---|---|---|---|
| Between-cow SD | 1.8 kg | **9.39 kg** | 5.2× |
| Residual SD (week to week) | 1.1 kg | **4.79 kg** | 4.4× |
| True treatment effect | 3.2 kg | **~1.05 kg** | 0.33× |
| Break-even | 2.45 kg | — | — |

**A units check first.** The pilot's `dmlk1` is in **pounds** — mean 88.4 lb, which is 40.1 kg/day. Any parameter lifted from this herd's raw records has to be divided by 2.205 before it enters a kg-denominated simulation. The figures above are already converted.

**What this means — and it is not simply "the study is too big".** Sample size scales with variance and with the inverse square of the effect, so five-times-larger variance components and a three-times-smaller effect move the requirement a long way. But the two success criteria behave completely differently under those inputs, and conflating them is the mistake to avoid.

Working from the measured components (per-cow SD over nine weekly observations = 9.52 kg):

**Criterion A — show the effect differs from zero.** Feasible.

| True effect | Cows, two arms | Cows, three arms |
|---|---|---|
| 1.05 kg (pilot's observed) | 2,584 | 3,876 |
| 1.5 kg | 1,266 | 1,899 |
| 2.0 kg | 713 | 1,070 |
| 3.2 kg (simulation's assumption) | 279 | 419 |

At 69 alerts per week, 2,584 cows is 37 weeks at one farm — or about 7 weeks of accrual across five herds. **Even the pilot's small observed effect is comfortably detectable inside a one-year multi-herd study.**

**Criterion B — show the lower 95% bound clears the 2.45 kg break-even.** This is where it breaks down, and it has nothing to do with variance.

| True effect | Cows needed, two arms |
|---|---|
| 2.45 kg or below | **impossible at any n** |
| 2.50 kg | 1,139,299 |
| 3.00 kg | 9,416 |
| 3.20 kg | 5,064 |
| 3.50 kg | 2,584 |
| 4.00 kg | 1,186 |

The reason is structural, not statistical: a confidence bound can only clear a threshold if the estimate itself sits above it with room to spare. **If the true milk benefit is at or below break-even, no sample size can demonstrate that it clears break-even** — and the pilot's estimate of ~1.05 kg is less than half of it.

▶ **Neither criterion on its own is the right target** - see the economics section below, which reframes this as a precision question and resolves it.


▶ **Two caveats that cut the other way, and they are not small.**

1. **The pilot's contrast is diluted.** Its Control arm was trimmed 49.8% of the time by the routine round, so the pilot compared "trim now" against "trim eventually", not against "do not trim". Arm 3 here is a genuinely untreated comparator, so **the true arm 1 versus arm 3 effect should be larger than 1.05 kg.** How much larger is unknown, and it is the single most consequential unknown in this sample size.

2. **The pilot measured 30 days; this study measures 60–90.** If the benefit of early treatment accumulates, a longer window sees more of it.

▶ **Still worth doing:** re-run the simulation itself with the measured components to confirm the closed-form figures above, since the simulation carries the blocking and the herd structure that the formulae ignore. Both should agree; if they do not, the disagreement is the finding.

**On "can milk alone pay for it".** The reviewer's instinct looks right. The pilot's observed 1.05 kg/day sits **below** the 2.45 kg break-even used in the simulation. If that break-even is roughly correct, milk alone does not pay for the system on this evidence, and the case rests on culling and recurrence. That is a finding worth stating plainly to Nedap rather than discovering halfway through.

▶ Needed to firm this up: system cost per cow per day, milk price, cull value, cost per trim.

### The economic question is the real question — and it is answerable

The 3.2 kg figure comes from the break-even calculator at `dairycowfootdoc-camera-math.share.connect.posit.cloud`. It takes herd size, annual first-lesion incidence, camera cost per cow per month, and a milk-improvement window, and it normalises the cost **per lame cow** — not per cow in the herd, and not per alerted cow. That is the right denominator, because only cows that get a lesion can produce the benefit.

**Reported cost estimates are $0.65–0.80 per cow per month.**

#### The pilot can measure the parameter this is most sensitive to

Incidence sits in the denominator, so break-even moves inversely with it. It has been a guess; the pilot measures it.

**Annual first-lesion incidence in this herd: ~14%** (2,544 first-lesion cases in the year to 2026-09-07). ▶ *Sanity-check this against your known herd size — my denominator was 11,006 distinct animals present in the window, which may include stock that should not count. If the true milking denominator is smaller, incidence is higher and break-even falls.*

Break-even milk gain per lame cow, replicating the calculator's structure (`cost × 12 ÷ incidence ÷ IOFC ÷ days`):

| Cost/cow/month | Incidence | IOFC $0.20/kg | $0.25/kg | $0.30/kg |
|---|---|---|---|---|
| $0.65 | 14% (measured) | 4.64 | **3.71** | 3.10 |
| $0.65 | 25% | 2.60 | 2.08 | 1.73 |
| $0.65 | 45% | 1.44 | 1.16 | 0.96 |
| $0.80 | 14% (measured) | 5.71 | **4.57** | 3.81 |
| $0.80 | 25% | 3.20 | 2.56 | 2.13 |
| $0.80 | 45% | 1.78 | 1.42 | 1.19 |

*60-day window; a 90-day window is two thirds of each figure.* At the measured 14% incidence and $0.25/kg IOFC: **3.72 kg/day over 60 days, or 2.48 kg/day over 90.** The 2.45 kg break-even in the existing simulation corresponds closely to $0.65/cow/month over 90 days — so that figure is coherent and internally consistent, and my earlier scepticism about it was misplaced.

#### "If we power for A we can't answer B" — the objection is right, and the fix is neither A nor B

Powering to detect a difference from zero does not answer whether the system pays, and powering for "the lower bound clears break-even" assumes the answer. The way out is to recognise that the economic question has **three** possible study outcomes, not two:

1. Confidence interval entirely **above** break-even → it pays.
2. Confidence interval entirely **below** break-even → it does not pay.
3. Interval **straddles** break-even → inconclusive.

**Design for outcome 1 or 2, whichever is true.** That is a *precision* target, not a power-against-a-point target, and what it costs depends on the **gap between the true effect and break-even** — not on the effect size itself:

| Gap between truth and break-even | Cows, two arms | Cows, three arms |
|---|---|---|
| 0.5 kg | 11,393 | 17,090 |
| 1.0 kg | 2,849 | 4,274 |
| **1.4 kg** | **1,454** | **2,181** |
| 2.0 kg | 713 | 1,070 |

**Worked on the pilot's numbers.** True effect ~1.05 kg against a 2.45 kg break-even is a gap of 1.40 kg. That needs **1,454 cows across two arms, 2,181 across three** — to conclude, with 80% confidence, that the milk benefit does **not** reach break-even. Compare 2,584 cows merely to show the effect differs from zero.

**Answering the economic question is cheaper than detecting the effect.** That is not a paradox: 1.05 kg is far from 2.45 kg but close to zero, and a study only needs enough precision to clear whichever boundary matters.

If the break-even is higher — 3.7 kg at 60 days on the measured incidence — the gap widens to 2.7 kg and the requirement drops below 500 cows per pair.

#### The one thing this design cannot do

▶ **If the true effect lands within about 1 kg of break-even, no feasible study resolves it.** At a 0.5 kg gap the requirement is 11,393 cows in two arms. That has to be stated in the protocol as a declared limitation, not discovered afterwards: *this study will resolve the economic question unless the true milk benefit falls within roughly ±1 kg of break-even.*

#### What this implies for the design

On present evidence the likely answer is that **milk alone does not pay for the system** — 1.05 kg against a break-even of 2.5–4.6 kg. Two consequences:

- That is a publishable, decision-relevant finding, and the study should be built to establish it cleanly rather than to avoid it.
- It raises the weight on **culling and recurrence**, which is where the remaining value would have to come from. A cull avoided is worth far more than a few kilograms of milk, and recurrence is both well-powered here (§ above) and mechanistically upstream of both.

▶ **Recommendation.** Set the milk sample size from the precision target above (~2,200 cows across three arms for a 1.4 kg gap), and make the primary economic endpoint **net margin per cow-lactation** — milk, culling, treatment cost and system cost combined — with recurrence as the primary clinical endpoint. Milk then contributes to the economic answer without having to carry it alone.

▶ Still needed: IOFC per kg on these farms, cull value, cost per trim, and confirmation of the herd-size denominator behind the 14% incidence.

---

## 6. Analysis

**Milk.** Mixed linear model on daily records, fixed effects for arm, DIM, lactation number, lesion history, breed, and herd; random intercept per cow; random effect for herd if enough herds. Test arm × lesion history. Include the pre-alert period and index time to days-since-alert.

**Culling and recurrence.** Time-to-event with the same covariate set, stratified by herd. Test arm × lesion history.

**Lesion at dry-off.** Logistic mixed model, same covariates, herd random effect.

**Staggered entry.** Cows enrolled late have short follow-up. Censor explicitly; do not restrict to cows with complete follow-up, which would select the earliest-enrolled and is exactly the trap the pilot's day-30 milk figures fell into.

**Pre-specify before data collection starts** — all of these moved answers materially in the pilot:

- The alert-to-lesion window that counts as "caught in time", and how a cow alerted *outside* it is treated. In the pilot, 21 days versus unbounded moved the Control miss rate from 27.9% to 11.5%.
- That a `NEDLAME` dated the day of a trim came from the *previous* day's attention. The import runs about 05:00 and stamps the load date, so an attention after 05:00 on day D appears as D+1.
- That alerts landing 1–7 days after a trim are mostly the camera reacting to the trimmed cow. The pilot excluded 162 of them.
- That "trimmed" means `LAME` + `FOOTRIM` + `TRIM`, never a subset.

---

## 7. What we must have from Nedap

Both of these blocked the pilot and would block this study.

1. **Score at flag, in the export.** Its absence left 69 pipeline cases permanently unjudgeable, because a `Low` flag on a cow scoring outside the enrollment range who was correctly declined is indistinguishable from a lost flag.

2. **The daily file-in log, or independent instrumentation of the integration.** In the pilot, **119 of 313** apparent misses were cows the camera *did* flag whose alert never reached DairyComp. The export shows episode start, end and completion but not the daily payload, so the mechanism could not be identified. Logging every raw flag with a timestamp, independent of the DairyComp import, from day one, removes this entirely.

Without these the study measures the camera and the integration together and cannot separate them — which is what happened in the pilot.

---

## 8. Open decisions

| ▶ | Decision |
|---|---|
| 1 | Confirm rolling enrollment at first alert. |
| 2 | Drop the "no lameness history" restriction and stratify instead — recommended. |
| 3 | Power the chronicity × lactation interaction, or adjust only. |
| 4 | Adopt lesion-at-dry-off as a primary outcome — recommended. |
| 5 | Include locomotion scoring or a second camera as reference standard, and at what frequency. |
| 6 | IOFC per kg, cull value, cost per trim, and the herd-size denominator behind the 14% incidence. Cost is $0.65-0.80/cow/month. |
| 7 | Confirm the precision target (~2,200 cows over three arms) and net margin per cow-lactation as the economic endpoint, with recurrence as the primary clinical one. |
| 8 | Number of herds and expected alerts per herd per week. |
| 9 | Re-run the existing simulation with measured variance components, sweeping true effect 1.0-3.2 kg. |
