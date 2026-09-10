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
| **2. Delayed treatment** | Trim chute for evaluation and treatment at **4 weeks** after the alert - or sooner if the routine round or farm staff pick her up first. She is not held back. |
| **3. Alert only** | Alerted, recorded, **not** acted on. Treated only if staff find her. |

### Two things the reviewer's questions expose about this structure

**"Basically the treatment groups all rely on the system. No one at the farm will be picking lame cows, right?"**

Staff detection continues in all three arms and cannot be switched off. That makes it a **co-intervention**, and the design has to treat it as one:

- It is **recorded as an event** (`CHKLAME`) with its date, for every cow in every arm.
- In arm 3, staff detection and **the routine trim round** are the only treatment pathways. Arm 3 is **regular farm practice**, not an untreated arm, and it must be named that way in the protocol. In the pilot the equivalent group was trimmed 49.8% of the time, mostly by the routine round rather than by staff picking cows out.

- **Routine trimming differs between farms and only part of it can be standardised.** Rechecks and dry-off 
trims can be fixed by protocol; getting buy-in to standardise *mid-lactation* routine trims is unrealistic. 
So routine coverage is a herd-level quantity that varies, it dilutes the arm-1-versus-arm-3 contrast, and it 
dilutes it by a different amount in each herd. It has to be **recorded per herd and carried in the model**, 
not assumed away.
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

Both argue for **powering the interaction rather than adjusting it away.** ▶ That doubles the sample size - verified, not estimated; see the simulation section in §5. A deliberate purchase, not a side effect.

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

A simulation already exists at `C:\Github\nedap_camera\sample size simulation.qmd`. Its structure is right and better than a closed-form calculation: it blocks on lactation and history, models five herds, uses `glmmTMB` with `treatment × history` and a spline on DIM, and — most importantly — **defines success as the lower 95% confidence bound exceeding a break-even, not as p < 0.05.** That instinct is right — a cost decision needs more than statistical significance — though the economics section argues for reporting the value with an interval rather than testing it against a fixed threshold.

**Its input parameters are the problem.** They were assumed; the pilot can measure them. Fitting the same model shape to the pilot's real daily milk (weekly averages, `kg ~ arm × history + parity + ns(DIM) + (1|cow)`, 3,601 weekly records on 828 cows):

| Parameter | Simulation assumes | **Pilot measures** | Ratio |
|---|---|---|---|
| Between-cow SD | 1.8 kg | **9.39 kg** | 5.2× |
| Residual SD (week to week) | 1.1 kg | **4.79 kg** | 4.4× |
| True treatment effect | 3.2 kg | **~1.05 kg** | 0.33× |
| Break-even used | 2.45 kg | corresponds to a lower incidence than this herd's; see economics | — |

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

**Criterion B — show the benefit covers the system's cost.** This is the question that matters, and it cannot be answered by powering against a fixed threshold: a confidence bound only clears a threshold if the estimate sits above it with room to spare, so making that the design target assumes the answer.

▶ **The economics section below replaces this with a better framing** — fix the sample size, then report what the system is worth with an interval. It also shows why the *demonstrable* lower bound on milk value stays small at any feasible n, which is the same point Criterion B was groping at, expressed in dollars instead of kilograms.


▶ **Two caveats that cut the other way, and they are not small.**

1. **The pilot's contrast is probably the right one, not a diluted one.** Its Control arm was trimmed 49.8% of the time by the routine round - which is what arm 3 *is*. An earlier draft of this document argued arm 3 would be a genuinely untreated comparator and so reveal a larger effect; that was wrong. **1.05 kg is a reasonable estimate of the arm-1-versus-arm-3 contrast**, and the study should be sized for an effect of about that magnitude rather than hoping for more.

2. **The pilot measured 30 days; this study measures 60–90.** If the benefit of early treatment accumulates, a longer window sees more of it.

The simulation has now been re-run with those components. Results below.

**On "can milk alone pay for it".** Not on its own - see the economics section below, which answers this with the herd's measured new-case incidence rather than an assumed break-even. Milk is worth about $0.36-0.53 per cow per month at the pilot's effect size, against a price of $0.65-0.80.

▶ Needed to firm this up: system cost per cow per day, milk price, cull value, cost per trim.


#### The simulation, re-run with measured inputs

100 replicates per cell, `glmmTMB`, the original engine's structure with the pilot's variance components. `n` is the two arms being compared; a third arm adds 50%.

**Power to detect a difference from zero (95% CI excludes 0), %:**

| True effect | 200 | 500 | 1,000 | 2,000 | 4,000 |
|---|---|---|---|---|---|
| 1.0 kg | 9 | 13 | 22 | 43 | 70 |
| 1.5 | 14 | 13 | 41 | 68 | 94 |
| 2.0 | 19 | 40 | 72 | 94 | 100 |
| 2.5 | 35 | 55 | 86 | 100 | 100 |
| 3.0 | 38 | 69 | 97 | 99 | 100 |
| 3.5 | 39 | 83 | 97 | 100 | 100 |

**Power for the economic criterion (lower 95% bound ≥ 2.45 kg), %:**

| True effect | 200 | 500 | 1,000 | 2,000 | 4,000 |
|---|---|---|---|---|---|
| 1.0–2.5 kg | ~0 | ~0–5 | ~0–2 | ~0–2 | ~0–3 |
| 3.0 | 4 | 6 | 19 | 12 | 26 |
| 3.5 | 5 | 14 | 15 | 46 | 75 |

The second table confirms the structural point: a threshold criterion is near-unattainable unless the true effect comfortably exceeds the threshold. At 2.5 kg against a 2.45 kg break-even, power never leaves single digits at any sample size.

#### Why the simulation needs twice the cows the formulae say — and it is a design decision, not an error

The simulation consistently requires about **2× the closed-form sample size**. That disagreement is worth resolving rather than averaging, and the cause is the model, not the variance:

**`treatment * history` makes the reported `treatmentControl` coefficient the treatment effect within `history = "No"` only** — estimated from half the cows. Tested directly on identical data, 40 replicates at n = 1,000:

| Model | Mean SE | Mean estimate |
|---|---|---|
| `treatment * history` | 0.844 | 1.945 (effect in one stratum) |
| `treatment + history` | 0.597 | 2.27 (average across strata) |
| Closed-form prediction | 0.602 | — |

The SE ratio is **1.414 — exactly √2 — so the sample-size penalty is exactly 2×.** The closed-form figure matches the main-effects model to three decimals; it was never wrong, it just answers a different question.

▶ **So the choice of primary estimand sets the sample size, and it doubles it.**

- **If the primary question is the average treatment effect across the herd**, fit treatment as a main effect (or take the marginal effect from the interaction model) and the closed-form figures in §5 apply.
- **If the interaction is itself of interest** — and §3 gives real reason to think chronicity matters, with recurrence rising 34% → 52% across parity — then the study needs roughly double, and that must be a deliberate purchase rather than a side effect of how the model was written.

This is the quantitative answer to the open question of whether to power the chronicity interaction or merely adjust for it. **It costs 2×.**


### What does waiting four weeks cost? — and the window decides the answer

▶ *Gerard's proposal: treat the benefit/cost of waiting as an outcome in its own right, with the expectation that milk differences run 1v3 > 2v3 > 1v2.*

**That ordering is correct, but only for windows of 90 days or more.** It reverses at shorter windows, and the reversal is a design lever rather than a curiosity.

Each contrast as a fraction of the full treatment effect (50% routine coverage in arm 3):

| Window | Arm 1 v 3 | Arm 2 v 3 | Arm 1 v 2 |
|---|---|---|---|
| 28 days | 0.81 | **−0.19** | **1.00** |
| 60 days | 0.78 | 0.33 | 0.44 |
| 90 days | 0.77 | 0.46 | 0.31 |
| 120 days | 0.77 | 0.53 | 0.24 |
| 180 days | 0.76 | 0.61 | 0.15 |

Cows needed across all three arms, 80% power, full effect 1.5 kg/day:

| Window | Arm 1 v 3 | Arm 2 v 3 | Arm 1 v 2 |
|---|---|---|---|
| **28 days** | 2,982 | 55,613 | **1,967** |
| 60 days | 3,138 | 17,124 | 9,633 |
| 90 days | 3,185 | 8,820 | 19,844 |
| 180 days | 3,228 | 5,076 | 78,596 |

Three things fall out of this.

**1. The cost of waiting must be measured over the delay window, not the study window.** Arm 2's entire disadvantage is realised in the first four weeks, and every week of measurement after that is arm 2 catching up and washing the signal out. Over 28 days the contrast is the *full* effect and costs about **2,000 cows**; over 90 days it is a third of the effect and costs **20,000**. Measuring the value of early treatment on a 90-day window is a tenfold mistake, and it is the natural mistake to make if one window is chosen for the whole study.

▶ **Recommendation: define the arm-1-versus-arm-2 comparison on cumulative milk over days 0–28**, and the arm-1-versus-arm-3 comparison on 60–90 days. Different questions, different windows, both pre-specified.

**2. Arm 1 versus arm 3 barely cares about the window** — 2,982 to 3,228 cows from 28 to 180 days. That contrast is robust, and it should carry the primary efficacy claim.

**3. Arm 2 versus arm 3 is the expensive one and should not be a primary comparison.** It needs a long window and 5,000+ cows even at 180 days. At 28 days it is *negative*:

> ⚠ **An early interim analysis would show arm 2 performing worse than doing nothing.** Inside the first four weeks arm-2 cows are protocol-bound to wait, while arm-3 cows can be picked up by the routine round at any time. This is an artifact of the protocol, not a harm, but it will look alarming to anyone reading a 30-day interim without warning. **Say so in the protocol before it happens.**

#### Better outcomes than milk for the cost of waiting

Milk over 28 days answers the question but is not the sharpest measure. The follow-up trim gives two better ones, and both use inspection points the study is standardising anyway.

#### Cure at the recheck — and it can be estimated after all

▶ *Gerard expected there would be too little data to size this. There is enough, once the outcome is built the way he described: **look at the LAME event after the initial trim, and read cure off whether the follow-up trim came back trim-only.***

Note first that **there is no hoof recheck event in this data.** `RECK` exists with 4,524 records but it is reproductive — its remarks are `LUT2CLEAN`, `CYSTIC`, `TWINS`, `NOCL`. Cure has to be read from the next foot exam.

- Index: a `LAME` with a lesion.
- Follow-up: the next `LAME` / `FOOTRIM` / `TRIM`.
- **Cured**: that exam is trim-only. **Not cured**: it finds a lesion.

| Window | Index cases re-examined | Cure rate among those re-examined |
|---|---|---|
| 30 days | 19% | 28.8% |
| **60 days** | **35%** | **40.4%** |
| 90 days | 40% | 40.3% |
| 180 days | 61% | 44.3% |

Sample size on the 60-day cure rate, baseline 40.4%:

| Improvement | Re-examined cows per arm |
|---|---|
| +5 points (to 45%) | 1,537 |
| **+10 points (to 50%)** | **388** |
| +15 points (to 55%) | 173 |

**Standardising the recheck is worth about three times the sample size on this outcome.** In current practice only 35% of index cases are re-examined within 60 days, so 388 *re-examined* cows per arm means enrolling roughly 1,100 per arm. If every treated cow gets a protocol recheck — which is what is already planned — re-examined equals enrolled and the requirement stays at 388.

▶ **Two caveats on the 40.4% baseline.** It is measured on cows who happened to be re-examined, which is a selected group: a cow looked at again within 60 days was probably looked at *because* something was wrong, so the true cure rate under a standardised recheck should be **higher** than 40.4%, and the sample sizes above correspondingly conservative. And "trim-only at the next exam" is a proxy for cure, not a clinical cure assessment — the study can do better by recording lesion resolution directly at a scheduled recheck.

#### Not lesion severity

▶ *Dropped on Gerard's objection: severity is not standardisable across farms.* A depth or severity score depends on the trimmer, and with several herds and multiple trimmers per herd the between-observer variation would swamp the treatment effect. **Cure at a standardised recheck is the better instrument** — it is closer to binary, and it survives being measured by different people.

▶ **Recommendation: make cure at a standardised recheck the primary measure of what waiting costs**, with recurrence within 365 days as the longer-run clinical outcome and 28-day milk as the economic translation. Cure is measured at a point both arms pass through, needs no window chosen for it, is not diluted by catch-up, and unlike severity it survives being scored by different trimmers on different farms.

### Economics: what is the system worth?

▶ **Recommended framing, and it replaces break-even.** Rather than fixing a break-even and powering to clear it, **fix a feasible sample size and report what the system is worth, with an interval.** There is no threshold to assume, so the study cannot be unfalsifiable, and the output is the number a farm or Nedap actually needs.

$$\text{affordable \$/cow/month} = \frac{\text{milk gain (kg/day)} \times \text{days} \times \text{IOFC (\$/kg)} \times \text{new-case incidence}}{12}$$

#### The incidence input, measured

"% of cows with a first lesion annually" means cows with **no prior lesion history** — `New` in the lameness code, not first-of-lactation. Using the project's validated denominator (`deno_type = lact_basic`, `LACT > 0`):

| Year | New cases | Cow-years | Per 100 cow-years |
|---|---|---|---|
| 2023 | 1,022 | 3,506 | 29.2 |
| 2024 | 801 | 3,490 | 23.0 |
| 2025 | 1,011 | 3,471 | 29.1 |
| **Mean** | | | **27.1** |

**This herd is at the high end**, so it is used as the top of a range rather than as the expected value. New cases by category, per 100 cow-years (mean, and year-to-year range):

| Lesion | Mean | Range |
|---|---|---|
| Other (mostly corkscrew claw) | 13.7 | 9.5–17.1 |
| White line | 13.6 | 10.9–16.5 |
| Digital dermatitis | 12.8 | 10.8–14.2 |
| Injury | 5.7 | 2.8–10.3 |
| Haemorrhage | 3.5 | 2.6–4.9 |
| Thin sole | 3.3 | 2.2–5.2 |
| Sole ulcer | 2.4 | 1.5–3.1 |
| Foot rot | 1.9 | 1.2–2.6 |
| Toe ulcer | 0.7 | 0.2–1.3 |
| Corkscrew | 0.2 | 0.1–0.3 |

*A cow can be a new case for one lesion while already chronic overall, so the categories sum to more than the 27.1 overall figure.*

#### What the system is worth on milk alone

| True effect | 60 d / 15% | 60 d / 20% | 60 d / 27.1% | 90 d / 15% | 90 d / 20% | 90 d / 27.1% |
|---|---|---|---|---|---|---|
| 0.5 kg | 0.09 | 0.12 | 0.17 | 0.14 | 0.19 | 0.25 |
| **1.05 kg (pilot)** | 0.20 | 0.26 | **0.36** | 0.30 | 0.39 | **0.53** |
| 1.5 kg | 0.28 | 0.38 | 0.51 | 0.42 | 0.56 | **0.76** |
| 2.0 kg | 0.38 | 0.50 | 0.68 | 0.56 | 0.75 | 1.02 |
| 3.0 kg | 0.56 | 0.75 | 1.02 | 0.84 | 1.12 | 1.52 |

*$/cow/month, IOFC $0.25/kg. **The cost to beat is $0.65–0.80.***

At the pilot's observed effect and this herd's incidence, **milk alone is worth $0.36–0.53 per cow per month — roughly 45–80% of the price.** Short, but not by a wide margin, and the shortfall closes entirely if the true effect is nearer 1.5 kg over a 90-day window.

Whether the true effect is nearer 1.5 kg is genuinely open, but **not** for the reason an earlier draft gave. Arm 3 is regular farm practice including routine trimming, which is what the pilot's Control arm was, so the pilot's 1.05 kg is a fair estimate of this contrast and not an understatement. The upside case rests instead on the longer measurement window (60-90 days against the pilot's 30) and on herds with lower routine-trim coverage, where the contrast is less diluted.

#### The uncomfortable part, and why it decides the design

Reporting an *estimate* is feasible. **Proving a lower bound is not.** Assuming the true effect is 1.05 kg:

| Cows (3 arms) | SE | Lower 95% bound | "Worth at least" |
|---|---|---|---|
| 1,500 | 0.60 | −0.13 kg | $0 |
| 3,000 | 0.43 | 0.22 kg | $0.07 |
| 4,500 | 0.35 | 0.37 kg | $0.13 |
| 10,000 | 0.23 | 0.59 kg | $0.20 |

To *demonstrate* even $0.20/cow/month takes about 9,900 cows across three arms. $0.40 and above is unreachable at any n, because it would require proving more milk than the point estimate itself.

**So milk alone cannot justify this system's price at any realistic sample size** — not because the benefit is absent, but because the confidence interval on a per-cow milk effect is wide relative to the money involved. This holds whichever incidence definition is used, because it is driven by the effect size and the variance, not by the threshold.

#### Consequences

1. **Do not set the sample size from the economics.** Set it from the clinical endpoint — recurrence — and report the economics as an estimate with an interval. Roughly 2,850 enrolled cows gives 406 index lesion cases per arm, enough for a 20% relative reduction in 365-day recurrence.
2. **The economic endpoint must be the combined margin**, not milk. Milk reaches about half the price on its own; culls avoided, repeat lesions prevented and treatment labour saved have to carry the rest, and a cull is worth far more than 60 days of a kilogram.
3. **Report affordability as a curve, not a verdict** — "$X per cow per month at this effect size, this incidence, this milk price", with the sensitivity table above. A farm with 15% new-case incidence and one with 27% face genuinely different propositions, and averaging them serves neither.

▶ Still needed: IOFC per kg on these farms, cull value, and cost per trim. The incidence input is now measured; the definition to use is `status_lesion == "New"`.

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
| 3 | Power the chronicity x lactation interaction, or adjust only. **Now quantified: the interaction costs exactly 2x the sample size.** |
| 4 | Adopt lesion-at-dry-off as a primary outcome — recommended. |
| 5 | Include locomotion scoring or a second camera as reference standard, and at what frequency. |
| 6 | IOFC per kg, cull value, cost per trim. Incidence is measured (27.1 new cases/100 cow-years, this herd at the high end). |
| 7 | Confirm: sample size from recurrence (~2,850 enrolled), economics reported as an affordability estimate with an interval rather than a break-even verdict. |
| 8 | Number of herds and expected alerts per herd per week. |
| 9 | Re-run the existing simulation with measured variance components, sweeping true effect 1.0-3.2 kg. |
| 10 | Confirm different measurement windows per contrast: 0-28 d for arm 1 v 2, 60-90 d for arm 1 v 3. |
| 11 | Confirm cure at a standardised recheck as the primary measure of what waiting costs (severity dropped - not standardisable across farms). |
