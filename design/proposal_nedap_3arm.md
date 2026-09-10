# Evaluating the efficacy and cost-effectiveness of Nedap SmartSight

**Draft 1 — 2026-09-10.** Builds on the "NEDAP Proposal Idea" outline, a colleague's review comments, and the completed two-arm NEDLAME pilot. Every figure attributed to the pilot is computed from its data; nothing here is an estimate unless it says so.

**Open decisions are marked ▶ and collected in §8. Everything else has been settled — §8 lists those too, with the basis for each.**

---

## 1. Objective

**Does it pay a commercial dairy to use SmartSight?**

Detection accuracy is not the question. The pilot already establishes that the camera works after a fashion — it flagged 240 of 579 lesion cases in time, missed 194 outright, and has a known blind spot in digital dermatitis. Measuring that more precisely needs a different study with a reference standard, and is not what a farm buying the system wants to know.

What a farm wants to know is whether acting on the alerts leaves it better off, and by how much. Two questions serve that:

1. **Does acting on alerts pay?** Arm 1 against arm 3 — trim off the alert, or carry on as now.
2. **Does acting *quickly* pay?** Arm 1 against arm 2 — within a week, or at four weeks. This decides how much of the answer to (1) depends on responsiveness, which is the expensive part for a farm to deliver.

### The ledger, and what the pilot already puts on it

"Does it pay" is a **net** question, and the cost side is not only the subscription. **Acting on alerts means trimming more cows**: in the pilot the trimmed arm was trimmed 90.4% of the time against Control's 49.8%, and 54.9% of those trims found no lesion.

That cost is quantified in §5 in the units the break-even calculator already uses — about **one extra trim per lame cow**, which raises the milk gain needed to break even by 41%. **On milk alone, net of the extra trimming, the system does not pay at either cost point or either window.**

### What that means for the design

- **The primary analysis is economic**: net margin per alerted cow, arm 1 against arm 3, combining milk, culling, recurrence, treatment cost and subscription.
- **The clinical outcomes are there to explain the economics**, not to stand alone. Cure and recurrence matter because they drive future treatment cost and culling risk, which is where the gap has to close.
- **Extra trim cost must be measured, not assumed.** It is a first-order term — comparable in size to the entire milk benefit — and it is the one cost a farm controls. Record every trim, its duration if possible, and whether a lesion was found.
- **Arm 2 earns its place economically, not just clinically.** If arm 1's empty trims are prevented lesions, they are value; if they are false positives, they are the largest avoidable cost in the design. Arm 2 is what distinguishes those, and the answer moves the ledger by up to $4.87 per alerted cow.

---

## 2. Design

Randomised controlled trial, **three arms**, **one year**, **multiple herds**.

### Enrollment is rolling, not cross-sectional

*This answers the reviewer's first question; the outline did not say.*

A cow enters the study **at her first SmartSight alert**, not at study start. Randomisation happens at that moment. Consequences:

- The study population is *alerted cows*, so every arm is comparable by construction — all three contain only cows the camera flagged.
- Accrual is continuous. In the pilot one farm produced **849 alerts in 86 days, about 69 per week**. A cow enrolled in month 11 has one month of follow-up, so the analysis must handle staggered entry (time-to-event models, and milk indexed to days-since-alert rather than calendar date).
- **Cross-sectional enrollment would not work here.** Randomising every cow at study start means most of the sample never gets alerted, and the arms would differ only among those who do — a much larger study for the same information.


##### Enrolling at freshening instead of at the alert

▶ *Raised as the alternative that makes timing clean, at the cost of a longer study.* Worth quantifying rather than assuming.

**What it costs.** Most cows enrolled at freshening never get an alert, so the arms only differ among the alerted subset. Measured from the pilot: the alert hazard is 0.0032 per cow-day, which over a full 305-day lactation implies **about 62% of cows are alerted at least once**. (Checked against the observed rate by exposure band — 4% by 30 days, 15% by 60, 24% by 90 — which is consistent with a roughly constant hazard.)

| | Enrol at alert | Enrol at freshening |
|---|---|---|
| Cows to enrol for 4,300 alerted | 4,300 | **~6,900** (×1.6) |
| Accrual | 62 farm-weeks | **101 farm-weeks** |
| Follow-up after the last enrollee | 60–90 days | **a full lactation** |
| Across 3 herds | ~5 months accrual | ~8 months accrual + ~10 months follow-up |

Roughly **1.6× the cows and about double the calendar time.**

**What it buys**, and some of it is more than tidiness:

- **Randomisation precedes the alert.** Assignment cannot interact with anything about how or when the cow was flagged.
- **A fixed time anchor.** DIM at enrolment is known and balanced across arms, and dry-off becomes a fixed endpoint rather than a variable one.
- **A complete pre-alert baseline**, rather than whatever milk history happens to exist before an alert that arrives at an arbitrary DIM.
- **A denominator for detection performance.** This is the substantial one. With every cow enrolled and every cow reaching a dry-off trim, the study has an unselected population and a common examination point — which is what makes the camera's sensitivity estimable at all. Enrolling at the alert cannot do this, because the population is defined by the camera having fired. It partly answers the open question about whether a reference standard is needed, though the dry-off trim only sees lesions still present at dry-off, so it is an imperfect one.

▶ **The decision.** Enrol at the alert if the study is about *what to do with an alert*. Enrol at freshening if it is also about *how well the camera detects* — that question cannot be answered from an alert-triggered cohort at any sample size, and 1.6× the cows plus a year of calendar time is what it costs to add it.

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
- **Low routine-trimming frequency.** Checkable from existing hoof records before enrolment. Power on the primary contrast more than doubles between a herd that trims routinely at 10% and one at 60%, at identical enrolment - a bigger lever than sample size. See §5.
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

*The reviewer asked whether this was ever looked at. It was not, until now.*

Two observations from the pilot, both **hypothesis-generating and not conclusive**:

**Recurrence rises steeply with parity.** Among cows with an index lesion, the share with another lesion within 365 days:

| Lactation | Cows | Recurred |
|---|---|---|
| 1 | 661 | 34.0% |
| 2 | 1,099 | 47.7% |
| 3+ | 3,560 | 51.8% |

**Cows with lameness history appear to be missed by the camera more often.** Among alerted cows who were later found with a lesion, the share the camera gave no useful warning for was **17.3% with history against 3.0% without**. The cell counts are small (156 and 135 cases) and this is exactly the kind of pattern the pilot learned to distrust before checking base rates, so it is offered as a question for the full study rather than a finding.

Both argue for **powering the interaction rather than adjusting it away.** That doubles the sample size - verified, not estimated; see the simulation section in §5. A deliberate purchase, not a side effect.

---

## 4. Outcomes

### The proposed outcome structure

▶ *Proposed: milk between arms 1 and 3 only; cure across all three arms; lesion prevalence at dry-off as a secondary outcome restricted to cows with a minimum alert-to-dry-off gap. The alternative is to enrol at freshening instead.*

**Milk on arm 1 versus arm 3 only — yes, and the simulation supports it.** That contrast is insensitive to the measurement window (2,982 to 3,228 cows from 28 to 180 days) and it is the only milk comparison that is powerable at a realistic size. Arm 1 versus arm 2 on milk reaches 43% power at 6,000 cows over 60 days and should not be attempted there; if the timing question is to be answered on milk it needs the 0–28 day window, where the contrast is the full effect rather than a third of it.

**Cure across all three arms — yes, but with one caveat that the pilot cannot resolve.**

In arms 1 and 2 every cow is trimmed by protocol, so cure is measured on all lesions those arms have. In arm 3 a cow is only trimmed if the farm catches her, so cure there is measured on **farm-detected lesions**. If those are systematically worse — noticed because they were bad — the arm-1-versus-arm-3 cure comparison is confounded by severity rather than by treatment timing.

I tested this in the pilot and **the test is uninformative rather than reassuring**: among Control cows, cure was 14.7% (n = 34) in staff-detected cows against 18.2% (n = 11) in routine-detected, p = 1.0. With 45 cows the confidence interval spans everything of interest. **The concern stands unresolved.**

Two ways to handle it, and one is nearly free:

- **Record how each arm-3 cow came to be trimmed** — staff `CHKLAME` or routine round — and report cure separately for each. Routine-round cows are the closer analogue to a protocol trim, since the routine round is not triggered by anyone noticing the cow.
- **Restrict the primary cure comparison to arms 1 and 2**, where both arms are trimmed by protocol and the populations are comparable by construction, and treat arm 3's cure as descriptive.

▶ The second is cleaner, and it costs less than it appears: arm 1 versus arm 2 is *also* the timing question, which is the one the three-arm design exists to answer.

**Lesion prevalence at dry-off with a minimum gap — yes, and the restriction works.** Using DIM at alert to project the gap (the pilot's own three-month span makes the observed gaps useless for this):

| Minimum alert-to-dry-off gap | Alerted cows retained (305-day lactation) |
|---|---|
| 30 days | 82% |
| 60 days | 74% |
| **90 days** | **66%** |
| 120 days | 60% |

A 90-day minimum keeps about two thirds of alerted cows. ▶ **But the third it drops are the cows alerted late in lactation, which is a selection on DIM rather than a random subset** — they differ in yield and in lesion risk. That is acceptable for a secondary outcome provided it is stated, and DIM at alert should be reported for the retained and excluded groups so a reader can see what was lost.

### Enrol at freshening instead?

**On these outcomes specifically, freshening enrolment buys very little for its cost.** It does not change the treatment contrast at all — cows are still only treated when alerted — so milk, cure and dry-off prevalence are all measured on the same alerted cows either way. What it adds is a denominator of unalerted cows, and none of the three proposed outcomes uses one.

It earns its cost only if the study also wants to measure **how well the camera detects**, which an alert-triggered cohort cannot do at any sample size, since the population is defined by the camera having fired.

▶ **So the question is not "which enrolment is better" but "is detection performance one of the questions?"**

- **If no**: enrol at the alert. ~4,300 cows, about five months of accrual across three herds, and the minimum-gap restriction handles the dry-off timing problem well enough for a secondary outcome.
- **If yes**: enrol at freshening. ~6,900 cows and roughly double the calendar time, with cows monitored and untouched for much of it — and it also fixes the dry-off timing by construction, since every cow has a full lactation.

**Recommendation: enrol at the alert.** The pilot already establishes that the camera misses a great deal (54.1% of lesion cases got no useful warning) and that the misses are concentrated in digital dermatitis. A second study to measure that more precisely is a different study with a different design — a detection-accuracy study wants locomotion scoring or a second camera as its reference standard, not a treatment protocol. **Trying to answer both questions in one trial pays full price for each and gets a compromised version of both.**

---


### The measurement problem that shapes all of them

The pilot's most quotable result was that trimming off the alert found lesions in **58 more cows** than the control approach (170 of 397 against 127 of 452). **That number measures inspection, not disease.** TX cows were trimmed 90.4% of the time by protocol; Control cows 49.8%. Randomisation makes true lesion incidence equal by construction.

Confirmed rather than assumed: among cows actually trimmed, **Control found a lesion *more* often** (53.8% against 45.1%), which is what a suspicion-driven population looks like, not a healthier one.

**So any outcome that depends on being looked at is confounded across these three arms**, because arm 1 is inspected ~100%, arm 2 ~100% at four weeks, and arm 3 only when staff notice.

### The fix: measure at the routine dry-off trim

Every cow is trimmed around dry-off regardless of arm, which makes it an **arm-independent inspection point**. Verified in the pilot: dry-off trim coverage was **88.6% in Control against 92.7% in TX, p = 0.62**. No detectable difference.

Two things the protocol must get right, both found in the data:

- **It is a window, not a day.** Trims cluster **21 to 7 days *before*** dry-off. A ±7-day definition catches only 9.6% of them; a −45 to +7 day window catches about 90%.
- **Coverage is ~90%, not 100%**, so the ~10% who miss it need a pre-specified handling rule.

**Lesion status at the dry-off trim is a primary outcome.** It is the only lesion measure in this design that is not confounded by arm, and it directly answers "did acting on alerts leave cows with healthier feet at the end of lactation".

### Primary outcomes

1. **Daily milk production**, from **before** the alert through 2–3 months after.

   *The reviewer asked why the pre-detection period was not included. It should be, for two reasons.* Each cow's own pre-alert production is the baseline the post-alert curve is normalised against — the pilot used the mean of the 7 days before the alert, because cows at different lactation stages are not comparable in absolute terms. Beyond that, the pre-alert slope is informative in itself: it shows how much production was already being lost before the camera fired, which is part of the value case.

2. **Lesion status at the dry-off trim** (see above).

3. **Recurrence within 365 days** of a first lesion. This is the best-powered clinically meaningful outcome available — see §5.

4. **Culling hazard** to 6 months.

### Secondary outcomes

- **Whether staff also detected her, and when.** *The reviewer is right that this is entangled with treatment.* In arm 1 the cow is trimmed within a week, so staff rarely get the chance — time-to-staff-detection is censored by the intervention itself. It is interpretable in arms 2 and 3, and in arm 1 only as "did staff beat the protocol". State that rather than reporting one number across arms.

- **Share of trims finding a treatable lesion.** *The reviewer's point here is the sharpest in the review and it changes the interpretation.* If early treatment prevents lesions, arm 1 will show *fewer* lesions per trim. Read as diagnostic accuracy that looks like poor sensitivity; read as clinical effect it is the study succeeding. **The design cannot have it both ways, so it must declare which reading applies:** lesions-per-trim is reported as a *description of the trims*, and the efficacy question is answered by the dry-off prevalence and the recurrence outcomes instead.

- **Reproductive outcomes.** Not powered as primary without a stated effect size.

### Outcomes needing an external reference standard

**Is the camera validated? What do locomotion scores add?**

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

These count **cows with an index lesion**. 35.0% of alerted cows had a lesion found in the pilot - 42.8% in the trimmed arm, 28.1% in Control - so 406 index cases per arm needs roughly **1,161 enrolled per arm, ~3,483 total** — about 41 weeks at one farm's 69 alerts/week, comfortable inside a year across several herds.

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

**The economics section below replaces this with a better framing** — fix the sample size, then report what the system is worth with an interval. It also shows why the *demonstrable* lower bound on milk value stays small at any feasible n, which is the same point Criterion B was groping at, expressed in dollars instead of kilograms.


**Two caveats that cut the other way, and they are not small.**

1. **The pilot's contrast is probably the right one, not a diluted one.** Its Control arm was trimmed 49.8% of the time by the routine round - which is what arm 3 *is*. So **1.05 kg is a reasonable estimate of the arm-1-versus-arm-3 contrast**, and the study should be sized for an effect of about that magnitude rather than a larger one.

2. **The pilot measured 30 days; this study measures 60–90.** If the benefit of early treatment accumulates, a longer window sees more of it.

The simulation has now been re-run with those components. Results below.

**On "can milk alone pay for it".** Not on its own - see the economics section below, which answers this with the herd's measured new-case incidence rather than an assumed break-even. Milk is worth about $0.36-0.53 per cow per month at the pilot's effect size, against a price of $0.65-0.80.

▶ Needed to firm this up: IOFC per kg, cull value, cost per trim. System cost is known at $0.65-0.80 per cow per month.



##### Farm detection after an alert: two processes, not one

The pilot's Control arm is the best available picture of what happens to an alerted cow when no protocol acts on her, and it separates two processes that behave very differently.

| | Share of Control cows | Median days to trim | Within 28 days |
|---|---|---|---|
| Staff spot her (`CHKLAME`) | **17.7%** | 7 | **88%** of them |
| Routine round reaches her | **32.1%** | 23 | **54%** of them |
| Never trimmed | 50.2% | — | — |

Week of trim, as a share of all Control trims:

| Week | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|
| Share | **31%** | 21% | 8% | 5% | 10% | 6% | 5% | 2% | 12% |

**Detection is heavily front-loaded: 66% of all catches land inside the first four weeks, and week 1 alone accounts for 31%.**

**This is the number that governs arm 2.** A cow assigned to wait four weeks who is spotted by staff in week 1 is treated in week 1. About **a third of all alerted cows are caught within 28 days**, so roughly a third of arm 2 never actually waits — it is pulled toward arm 1, and the arm-1-versus-arm-2 contrast shrinks accordingly.

**Two consequences for the design.**

1. **Arm 2 is not "treated at four weeks", it is "treated at four weeks or sooner, whichever the farm gets to first".** The analysis has to record the actual treatment date per cow, and an intention-to-treat comparison of arm 1 against arm 2 will understate the true value of early treatment by roughly the contamination fraction. A per-protocol or time-varying analysis should be pre-specified alongside it.

2. **Staff detection and routine trimming should be modelled and reported separately**, because only one of them is standardisable. Gerard's point is that rechecks and dry-off trims can be fixed by protocol but mid-lactation routine trims cannot — so routine coverage is the herd-varying nuisance, while staff detection can be treated as roughly constant across farms. Recording `CHKLAME` separately from routine trims is what makes that separation possible in the analysis, and the pilot shows it is worth doing: the two differ by a factor of three in median time-to-trim.

▶ **This also sets a floor on how untreated arm 3 can be.** Half of alerted Control cows were never trimmed in the pilot, so arm 3 is roughly half-untreated — not fully. Any expectation of the arm-1-versus-arm-3 effect has to be discounted for that, and it is the main reason the pilot's 1.05 kg is the right planning figure rather than a floor.

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


#### The three-arm simulation

100 replicates per cell. Farm detection parameterised from the pilot: staff catch 17.7% of cows (median 7 days), the routine round 32.1% (median 23 days), each cow treated by whichever fires first. Arm as a main effect. 60-day window.

**Dilution is the dominant fact.** The contrast a study can see is much smaller than the treatment effect that generates it:

| True treatment effect | Arm 1 v 3 | Arm 2 v 3 | Arm 1 v 2 |
|---|---|---|---|
| 1.0 kg | 0.69 | 0.45 | 0.49 |
| **1.5 kg** | **1.01** | 0.50 | 0.61 |
| 2.0 kg | 1.42 | 0.78 | 0.71 |
| 3.0 kg | 2.02 | 0.99 | 1.06 |

*Observed contrast in kg/day, at the pilot's detection rates.*

**Power, enrolled across all three arms:**

| True effect | 900 | 1,500 | 2,400 | 3,600 | 6,000 |
|---|---|---|---|---|---|
| **Arm 1 v 3** | | | | | |
| 1.0 kg | 14 | 20 | 26 | 45 | 52 |
| 1.5 kg | 24 | 45 | 57 | — | 91 |
| 2.0 kg | 46 | 51 | 82 | 94 | 100 |
| **Arm 1 v 2** | | | | | |
| 1.5 kg | 8 | 11 | 23 | — | 43 |
| 3.0 kg | 24 | 45 | 58 | 70 | 91 |

**Three findings.**

**1. The simulation and the closed form agree once dilution is accounted for.** A 1.5 kg treatment effect produces a 1.01 kg observed contrast; the closed form needs about 4,200 cows over three arms to detect 1.01 kg, and the simulation puts 80% power between 3,600 and 6,000. They were never in conflict — the closed-form figures were quoted against *observed* contrasts and the simulation against *true* effects.

**2. This revises the pilot's effect size upward, and it matters for the economics.** The pilot's 1.05 kg was itself an observed, diluted contrast — its Control arm was trimmed 49.8% of the time. On this dilution model, an observed 1.05 kg implies a **true treatment effect near 1.5 kg**. That moves the affordability figures: at 1.5 kg the system is worth **$0.51 per cow per month over 60 days, or $0.76 over 90** — against a price of $0.65–0.80. The 90-day figure covers the cost.

▶ This is a model-dependent inference, not a measurement. It rests on how benefit is assumed to accrue after treatment, and it should be presented as a range rather than a point.

**3. Arm 1 versus arm 2 cannot be answered on a 60-day window at any realistic size.** At a 1.5 kg true effect, 6,000 cows gives 43% power. Arm-2 contamination plus catch-up shrinks the contrast to 0.61 kg. **This is the quantitative confirmation that the timing question needs the 0–28 day window** — over 28 days arm 2 has had no treatment at all and the contrast is the full effect.

#### Herd selection is a bigger lever than sample size

Routine-trim coverage varies between farms and cannot be standardised. Holding staff detection at 17.7% and n at 2,400:

| Routine coverage in arm 3 | Observed arm 1 v 3 | Power |
|---|---|---|
| 10% | 1.23 kg | **75%** |
| 20% | 1.09 | 63% |
| 32% (pilot) | 1.01 | 57% |
| 45% | 0.94 | 55% |
| 60% | 0.79 | **33%** |

**Power more than doubles between a high-routine-trimming herd and a low one, at identical enrolment.** Recruiting three herds that trim routinely at 10–20% is worth more than adding 2,000 cows to a study run in 60%-coverage herds.

▶ **This should be a herd eligibility criterion, and it is checkable before enrolment** — routine trimming frequency is visible in any farm's existing hoof records. It belongs alongside "reliable hoof trimming data" in §3.

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

*Gerard's proposal: treat the benefit/cost of waiting as an outcome in its own right, with the expectation that milk differences run 1v3 > 2v3 > 1v2.*

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

**The arm-1-versus-arm-2 comparison is defined on cumulative milk over days 0–28**, and the arm-1-versus-arm-3 comparison on 60–90 days. Different questions, different windows, both pre-specified.

**2. Arm 1 versus arm 3 barely cares about the window** — 2,982 to 3,228 cows from 28 to 180 days. That contrast is robust, and it should carry the primary efficacy claim.

**3. Arm 2 versus arm 3 is the expensive one and should not be a primary comparison.** It needs a long window and 5,000+ cows even at 180 days. At 28 days it is *negative*:

> ⚠ **An early interim analysis would show arm 2 performing worse than doing nothing.** Inside the first four weeks arm-2 cows are protocol-bound to wait, while arm-3 cows can be picked up by the routine round at any time. This is an artifact of the protocol, not a harm, but it will look alarming to anyone reading a 30-day interim without warning. **Say so in the protocol before it happens.**

#### Better outcomes than milk for the cost of waiting

Milk over 28 days answers the question but is not the sharpest measure. The follow-up trim gives two better ones, and both use inspection points the study is standardising anyway.

#### Cure at the recheck — and it can be estimated after all

*Gerard expected there would be too little data to size this. There is enough, once the outcome is built the way he described: **look at the LAME event after the initial trim, and read cure off whether the follow-up trim came back trim-only.***

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

**Two caveats on the 40.4% baseline**, before the lesion-type breakdown below sharpens them further. It is measured on cows who happened to be re-examined, and a cow looked at again within 60 days was probably looked at because something was wrong - so the true rate under a standardised recheck should be **higher**, and these sample sizes are conservative. And "trim-only at the next exam" is a proxy for cure, not a clinical assessment.


##### Rechecks are lesion-selected, and that changes how the baseline can be used

*Gerard: rechecks typically happen for specific lesions, not DD or foot rot.* Correct for DD, and strikingly so. Within 60 days of the index case:

| Index lesion | Index cases | Re-examined | Cure rate among those re-examined |
|---|---|---|---|
| Digital dermatitis | 2,521 | **13.4%** | 37.3% |
| White line | 1,653 | **60.4%** | 51.6% |
| Other (mostly corkscrew) | 1,555 | 44.9% | 23.8% |
| Injury | 352 | 19.6% | 24.6% |
| Sole ulcer | 183 | 57.4% | 50.5% |
| Haemorrhage | 148 | 45.3% | 52.2% |
| Foot rot | 136 | **52.2%** | 15.5% |
| Thin sole | 136 | 32.4% | 56.8% |
| Toe ulcer | 93 | 34.4% | 18.8% |

**Three things follow, and they change how the 40.4% pooled figure can be used.**

**1. The pooled cure rate is essentially a white-line cure rate.** White line supplies 999 of the 2,100 re-examinations. The block-and-recheck lesions — white line 60.4%, sole ulcer 57.4% — dominate the denominator, exactly as Gerard said. Quoting 40.4% as a general cure rate would be wrong.

**2. Cure rates differ enormously by lesion**, from 15.5% for foot rot to 56.8% for thin sole. **The outcome has to be defined per lesion type, or restricted to the lesions where a recheck is clinically meaningful.** Pooling across a mix that differs between arms would be a confound in its own right.

**3. Foot rot is a partial exception to the expectation** - re-examined 52.2% of the time, not rarely. Its 15.5% cure rate turns out to be a recording artifact rather than a clinical finding; see below.

**The consequence for the study, and it is a real one.** DD is simultaneously the lesion the camera misses most (42% of what it never flagged, against 21% of what it caught) and the lesion with the least recheck data (13.4%). **Standardising rechecks across all lesion types would generate genuinely new information exactly where the pilot is blindest** — but it also means the DD cure baseline is the least certain input in this design, resting on a 13.4% selected sample.

**Recommendation.** Make cure the primary measure of what waiting costs **for white line and sole ulcer**, where the baseline is well estimated and rechecks are standard practice. Exclude foot rot (artifact, below). Collect DD opportunistically rather than by standardised recheck, which is not feasible.


##### Foot rot's low cure rate is a recording artifact

*Gerard: the trimmer enters a foot rot, then farm staff enter another foot rot treatment when the drug is actually given.* The data agrees. Of the 171 foot rot index cases whose follow-up "found a lesion":

| Gap to follow-up | 0–1 d | 2–3 d | 4–7 d | 8–14 d | 15–30 d | 31–60 d |
|---|---|---|---|---|---|---|
| Cases | 27 | 10 | 65 | 33 | 22 | 14 |

**60% fall within 7 days**, the median gap is 7 days, and **46% of those follow-ups are themselves coded foot rot.** That is one episode entered twice, not a treatment failure. The 15.5% cure rate is an artifact and foot rot must be excluded from the cure outcome.

**The gap rule applies to foot rot, not generally.** *Gerard: for other lesions the hoof trimmer diagnoses and treats at the same visit, so a return the next week means the treatment did not work.* The data separates the two cases cleanly. Among follow-ups that found a lesion:

| Index lesion | Within 7 days | Median gap | Cure, all follow-ups | Cure, excluding <14 days |
|---|---|---|---|---|
| Foot rot | **60%** | 7 d | 12.4% | 29.4% |
| Other | **47%** | 8 d | 25.8% | 39.9% |
| Injury | 35% | 14 d | 20.5% | 30.7% |
| DD | 19% | 28 d | 39.2% | 35.9% |
| Sole ulcer | 11% | 29 d | 47.0% | 52.9% |
| **White line** | **10%** | **35 d** | 48.6% | 53.6% |

Foot rot's non-cures pile up in the first week — the duplicate-entry signature. **White line and sole ulcer show nothing of the kind**: a tenth within a week, medians of a month, and imposing a 14-day gap moves their cure rates by only about 5 points. Those early returns are treatment failures and must be counted.

So: **exclude foot rot from the cure outcome, and impose no minimum gap on white line or sole ulcer.**

▶ **One thing that was not raised and looks like the same artifact.** "Other" — mostly corkscrew claw — has 47% of its non-cures inside 7 days and 22% re-coded as the same type. That is closer to foot rot's pattern than to white line's, and a 14-day gap moves its cure rate 14 points. Worth a view on whether corkscrew is being double-entered too, or whether something else explains it. It is not on the critical path, since "other" is not part of the value case.

##### Digital dermatitis: no evidence it sets cows up for white line or sole ulcer

*Gerard's hypothesis: the camera's value probably runs through white line and sole ulcer, with DD contributing little — unless an ignored DD lesion predisposes to WLD/SU.*

Tested on the pilot. Index = a cow's first foot exam, excluding cows already found with WLD or SU; outcome = WLD or sole ulcer within 365 days:

| At the index exam | Cows | Later WLD/SU | Rate |
|---|---|---|---|
| DD found | 1,401 | 176 | 12.6% |
| No DD found | 6,788 | 850 | 12.5% |

Risk ratio **1.00**, risk difference **0.0 points**, 95% CI −1.9 to +2.0, p = 1.0. **A precise null, not an underpowered one** — the interval excludes anything larger than a two-point difference in either direction.

**But it does not test the hypothesis as stated, and the distinction matters.** Every DD case in these records was *diagnosed*, and diagnosis at this farm means treatment. So this shows that **DD found and treated** does not raise later WLD/SU risk. Gerard's hypothesis is about DD that is **ignored** — and undiagnosed DD, by construction, cannot appear in diagnosis records. It is unobservable here.

**That gives arm 3 a specific scientific purpose beyond being a control.** By leaving alerted cows to regular practice, the study creates the untreated-DD condition that no observational dataset can supply, and the DD → WLD/SU pathway becomes testable for the first time. It is worth stating as a secondary objective rather than leaving it implicit.

**Design consequences, taking these together with the recheck selection above.**

- **Standardising DD rechecks is not feasible** (Gerard) and should not be proposed. DD is scored at whatever exam the cow next has.
- **The camera's value case rests on white line and sole ulcer.** They are the lesions the camera detects well — white line is 16% of what it missed against 48% of what it caught — they are the block-and-recheck lesions with well-estimated cure rates, and they carry the milk and culling consequences.
- **DD stays in as a secondary question**, not as a driver of the value case: whether prolonged untreated DD leads to WLD/SU, answerable only because arm 3 exists.

#### Not lesion severity

*Dropped on Gerard's objection: severity is not standardisable across farms.* A depth or severity score depends on the trimmer, and with several herds and multiple trimmers per herd the between-observer variation would swamp the treatment effect. **Cure at a standardised recheck is the better instrument** — it is closer to binary, and it survives being measured by different people.

**Cure at a standardised recheck is the primary measure of what waiting costs**, with recurrence within 365 days as the longer-run clinical outcome and 28-day milk as the economic translation. Cure is measured at a point both arms pass through, needs no window chosen for it, is not diluted by catch-up, and unlike severity it survives being scored by different trimmers on different farms.


### What the numbers count, and what to inflate them by

Every sample size quoted above counts a different thing, which makes them not directly comparable. Converted to the only operational quantity — **cows enrolled, i.e. alerts** — using the pilot's own conversion rates:

- **35.0%** of alerted cows have a lesion found (42.8% in the trimmed arm, 28.1% in Control).
- **35.7%** of index lesions are re-examined within 60 days under current practice.

| Outcome | The published *n* counts | Per arm | **Enrolled per arm** | **Enrolled, 3 arms** |
|---|---|---|---|---|
| Milk, arm 1 v 3, 60–90 d | enrolled cows | 1,046 | 1,046 | **3,138** |
| Milk, arm 1 v 2, 0–28 d | enrolled cows | 656 | 656 | **1,968** |
| Recurrence 365 d, −20% relative | cows *with a lesion* | 406 | 1,161 | **3,483** |
| Cure at 60 d, +10 points — current practice | cows *re-examined* | 388 | 3,107 | **9,321** |
| Cure at 60 d, +10 points — **recheck standardised** | cows *with a lesion* | 388 | 1,110 | **3,330** |

**Standardising the recheck helps, but by less than a first pass suggested, and the cure outcome is dearer than these rows imply** - both corrected immediately below, where the figures are re-derived on white line and sole ulcer rather than on all lesions pooled.


##### What "standardising the recheck" means, and what it is worth

The term needs pinning down, because the arithmetic depends on which of two things it means.

**It does not mean giving every treated cow a follow-up exam.** A recheck in practice is the trimmer re-examining a cow he blocked — pulling the block, checking healing. That happens naturally for white line and sole ulcer and not for digital dermatitis, which has no block and is why standardising DD rechecks is not feasible.

**It means fixing the timing and the recording of rechecks that already happen**: a scheduled re-examination at a set interval after treatment for the lesions that warrant one, recorded as a distinct event with the lesion status found. Not new rechecks for cows who would never have had one.

On that reading, here is what it is worth. For white line and sole ulcer — the lesions the cure outcome is sized on:

| | Current practice | Standardised |
|---|---|---|
| Re-examined within 60 days | **60.2%** | ~95% |
| Saving on enrolment | — | **×1.58** |

▶ **This corrects a figure given earlier in this document.** An earlier version claimed ×2.8, computed from the 35.7% re-examination rate pooled across *all* lesions. That pooled rate is dragged down by DD at 13.4%, and DD will not be rechecked under any version of this protocol. On the lesions the outcome is actually sized for, current practice is already around 60%, so the gain from standardising is real but smaller.

##### The cure outcome is the expensive one, not the cheap one

Correcting the same error changes the sample size materially. **Only 18.3% of alerted cows go on to have a white line or sole ulcer**, and the correct baseline cure rate for those lesions is **49.3%**, not the 40.4% pooled figure.

| Improvement to detect | Re-examined per arm | Enrolled, 3 arms (standardised recheck) |
|---|---|---|
| +5 points (49→54%) | 1,567 | 27,042 |
| +10 points (49→59%) | 389 | **6,714** |
| +15 points (49→64%) | 171 | **2,952** |
| +20 points (49→69%) | 94 | 1,623 |

**Revised enrolment picture**, with ×1.28 attrition on the milk outcomes and ×1.05 for herd heterogeneity throughout:

| Outcome | Target enrolled, 3 arms |
|---|---|
| Milk, arm 1 v 2 (0–28 d) | 2,600 |
| Cure WLD/SU, **+15 points** | 3,100 |
| Recurrence 365 d, −20% relative | 3,700 |
| **Milk, arm 1 v 3 (60–90 d)** | **4,300** |
| Cure WLD/SU, +10 points | 7,100 |

▶ **The decision this forces.** At about **4,300 enrolled cows** the study covers the milk contrasts, recurrence, and a **15-point** cure difference. Detecting a **10-point** cure difference instead requires 7,100 — a 65% larger study for one outcome. **Is a 10-point improvement in cure the thing worth nearly doubling the study for, or is 15 points the honest target?** That is a clinical judgement, not a statistical one.

For scale: 4,300 cows is about 62 farm-weeks at the pilot farm's ~69 alerts a week, so three to four herds over a year. 7,100 is about 103 farm-weeks, which needs five or more.



##### Chronic cows cure worse — and the distinction between a main effect and an interaction is worth £

▶ *Expected: chronic cure rates worse than new. Confirmed, for white line and sole ulcer at 60 days:*

| Chronicity at the index lesion | Assessed | Cured | Re-examination rate |
|---|---|---|---|
| New | 1,089 | **51.9%** | 60.1% |
| Chronic | 631 | **45.0%** | 60.7% |
| Repeat | 26 | — | 54.2% |

**A 6.9-point gap, p = 0.007, 95% CI −11.9 to −1.9.** Re-examination rates are the same in both groups, so this is not a selection artifact — chronic cows really do cure less often.

**But this is a main effect, and a main effect is free.** Adjusting for chronicity costs nothing; if anything it removes variance and improves precision. What costs 2× is an **interaction** — the treatment *benefit* differing by chronicity, so that early trimming helps new cows more (or less) than chronic ones. Those are different claims:

| | Claim | Cost |
|---|---|---|
| Main effect | Chronic cows cure less often **regardless of arm** | free — adjust for it |
| Interaction | **Early trimming helps chronic cows less** than new ones | ×2 sample size |

**The pilot can establish the first and cannot test the second**, because it has no randomised treatment contrast on cure — only observational cure rates. Whether the *benefit* differs by chronicity is a genuine open hypothesis.

▶ **It is a plausible hypothesis, and arguably the most clinically interesting question in the study.** If chronic cows cure worse whatever you do, early intervention may buy less in them — which would mean targeting the camera's alerts at new cases. If instead early intervention is what *prevents* a new case becoming chronic, the benefit runs the other way and the value is concentrated exactly where the pilot says the camera performs (white line, sole ulcer).

**What it costs to answer.** The interaction penalty was verified exactly (×2) for the linear milk model. For the logistic cure model it is being simulated rather than assumed, since the two need not agree. On the closed-form expectation, powering the cure interaction at +15 points would take the enrolment target from ~4,300 to somewhere near 8,600.

▶ **So the chronicity question forces the same decision twice** — once on milk, once on cure — and it is the same decision: buy the interaction at roughly double, or adjust for chronicity and report the interaction as exploratory. Given that the pilot shows recurrence rising 34% → 52% across parity *and* cure falling 7 points in chronic cows, the case for buying it is stronger than it looked before these numbers existed.

##### The cure outcome, simulated

▶ *Worth simulating rather than trusting the two-proportion formula, because the closed form ignores three things this design has: the multi-stage selection from enrolled to lesion to assessed, herd-level variation in the cure rate, and arm-2 contamination.* 300 replicates per cell, mixed-effects logistic with a herd random effect, arm-2 modelled with a third of cows treated before its protocol week.

**Power for arm 1 versus arm 3, by how cows are assessed:**

| Improvement | Assessment route | 2,000 | 3,000 | **4,300** | 6,000 | 9,000 |
|---|---|---|---|---|---|---|
| **+10 points** | current practice (60%) | 24 | 31 | 39 | 51 | 73 |
| | scheduled recheck (95%) | 31 | 45 | **62** | 75 | 87 |
| **+15 points** | current practice (60%) | 42 | 64 | 76 | 87 | 97 |
| | scheduled recheck (95%) | 55 | 79 | **93** | 98 | 100 |
| **+20 points** | scheduled recheck (95%) | 87 | 97 | 100 | 100 | 100 |

*Enrolled cows across all three arms.*

**The simulation agrees with the closed-form figures**, which is worth stating because the milk simulation did not. For a scheduled recheck it puts 80% power at about 7,000 enrolled for +10 points and about 3,100 for +15, against closed-form values of 6,714 and 2,952 — within 5%. The agreement holds because the cure model has arm as a main effect with no interaction, so the formula applies directly; the milk discrepancy came entirely from the `treatment × history` term, and the same 2× penalty would apply here if the cure model carried an interaction.

**Three things the table settles.**

1. **At 4,300 enrolled the study has 93% power for a 15-point cure difference and 62% for a 10-point one.** That confirms the enrolment target from the other direction, and it confirms that 10 points is the ambition that does not fit.

2. **Standardising the recheck is worth having but is not transformative.** At +15 points it moves power from 76% to 93% — the difference between inadequate and comfortable, but the study is not impossible without it.


#### Attrition: inflate the milk outcome by about 1.28

Measured on the pilot cohort, from the alert:

| | By day 60 | By day 90 |
|---|---|---|
| Culled | 5.8% | 6.2% |
| Dried off | 14.4% | 15.8% |
| **Either — milk outcome lost** | **19.9%** | **21.7%** |

Drying off is the larger loss, not culling, and it is easy to overlook. **Inflate the milk sample sizes by ×1.25 at 60 days or ×1.28 at 90.** Culling alone would only be ×1.07.

Recurrence and cure are less exposed: a culled cow cannot recur, so she is a competing risk to be handled in the analysis rather than a sample-size inflation, and dry-off does not end follow-up for either.

#### Herd clustering: much smaller than it looks, because randomisation is within herd

▶ **A cluster-randomised design effect does not apply here and would badly over-inflate the study.** Cows are randomised to arms *within* each herd, so herd is a **blocking factor**. Blocking removes between-herd variance from the contrast rather than adding to it — the usual `1 + (m−1)·ICC` inflation is for studies that randomise whole herds, which this does not.

What does inflate is **treatment-effect heterogeneity**: the effect genuinely differing between farms. Then `Var(effect) = σ²/n + τ²/k`, with `k` the number of herds:

| τ (between-herd SD of the effect) | 5 herds | 10 herds |
|---|---|---|
| 0 | ×1.00 | ×1.00 |
| 0.25 kg | ×1.05 | ×1.02 |
| 0.50 kg | ×1.21 | ×1.10 |
| 0.75 kg | ×1.65 | ×1.24 |
| 1.00 kg | ×3.31 | ×1.54 |

Routine-trim coverage varying between roughly 10% and 60% across farms implies the diluted effect varies by about 0.3–0.5 kg, so **τ ≈ 0.15–0.25 and the inflation is ×1.02–1.05.** Negligible.

▶ **But the table shows where it stops being negligible.** At τ = 1.0 kg with 5 herds the requirement more than triples, and doubling to 10 herds cuts that to ×1.54. **More herds buy protection against heterogeneity far more efficiently than more cows do** — and since routine-trim practice is the main thing that differs between farms and cannot be standardised, heterogeneity is a live risk rather than a theoretical one.

#### Putting it together

| Outcome | Enrolled, 3 arms | × attrition | × heterogeneity | **Target** |
|---|---|---|---|---|
| Milk, arm 1 v 3 | 3,138 | 1.28 | 1.05 | **~4,200** |
| Milk, arm 1 v 2 (28 d) | 1,968 | 1.25 | 1.05 | **~2,600** |
| Recurrence | 3,483 | 1.00 | 1.05 | **~3,700** |
| Cure, recheck standardised | 3,330 | 1.00 | 1.05 | **~3,500** |

**About 4,300 enrolled cows covers the milk contrasts, recurrence, and a 15-point cure difference** - see the corrected figures above. A 10-point cure difference would need 7,100, which is the one decision where the enrolment target is genuinely in play.

---

### Sizing the study on the question it is actually asking

The calculator's model, from `app.R`: `IOFC = milk_price − feed_cost / conversion`, which on its metric defaults is **$0.254/kg**; cost per lame cow is the yearly camera cost divided by yearly lame cows; required milk is that over IOFC over the window. It has **no trim-cost and no culling term** — confirmed in the source, not inferred.

#### Two terms to add, with Gerard's figures

**Extra trimming, a cost.** 0.97 extra trims per lame cow (§ above). At **$15–20** a trim that is $14.55–19.40 per lame cow.

**Avoided culling, a benefit.** The right unit is not the cull's market value but **replacement cost minus cull value**: $2,500–3,500 less $1,200–1,500, so **$1,000–2,300 net per cull avoided**, with $1,500 a reasonable middle.

With both, at $20 a trim:

| Camera | Cost per lame cow | Milk at 1.05 kg/90 d | Milk at 1.5 kg/90 d |
|---|---|---|---|
| $0.65/cow/month | $48.18 | −$24.18 | −$13.89 |
| $0.80/cow/month | $54.82 | −$30.82 | −$20.53 |

**Milk does not cover it in any scenario.** But the gap is small against the value of a cull: at $1,500 net, **a 2-percentage-point reduction in culling among lame cows closes it entirely.**

#### The problem, and it is the central one

**A 2-point culling reduction is not detectable at any feasible size.** Culling among lame cows in the pilot was 5.0% over three months, so roughly 10% over the six months the study would follow. Testing that as its own outcome:

| Reduction to detect | Lame cows/arm | **Enrolled, 3 arms** |
|---|---|---|
| 2 points | 3,213 | **27,540** |
| 3 points | 1,356 | 11,625 |
| 5 points | 435 | 3,729 |

**So the study cannot show that culling falls by the amount that would make the system pay** — not at 4,300 cows, not at 10,000.

#### The way through: measure the margin, not its components

The question is not "does culling fall". It is "does the whole thing pay". A **composite margin per alerted cow** — milk value, minus trim cost, plus avoided-cull value — is a continuous outcome and does not require any component to be individually significant.

| | Per alerted cow |
|---|---|
| SD of the composite margin | **$280–286** |
| — of which culling | $276 |
| — of which milk | $51–76 |
| Margin gain needed to break even | **$16.86** ($0.65/mo) to **$19.19** ($0.80/mo) |

| | Enrolled, 3 arms |
|---|---|
| Detect the break-even margin, $0.80/cow/month | **5,000–5,200** |
| Detect the break-even margin, $0.65/cow/month | **6,500–6,800** |
| *(Testing culling alone, for comparison)* | *27,540* |

**The composite costs a fifth of what testing culling separately would.**

▶ **What 4,300 buys, and why it is not quite enough.** At 4,300 enrolled the 95% CI on the margin is **±$20.52 per alerted cow**, against a break-even of $16.86–19.19. The interval would straddle break-even and the study would end inconclusive on its own question.

▶ **Recommendation: size the study at about 6,000 enrolled cows across three arms, with the composite margin per alerted cow as the primary endpoint.** That is 87 farm-weeks at the pilot farm's rate — four to five herds over a year, which is also where the herd-heterogeneity argument pointed. It answers "does it pay" directly, and the milk, cure and recurrence outcomes then explain *why* rather than having to carry the verdict.

▶ **One caveat that cuts both ways.** The culling SD dominates the composite, so the answer is sensitive to the net cull cost. At $1,000 the required sample rises; at $2,300 it falls. That figure should be set from the participating farms' actual replacement economics before the protocol is fixed, not from a national average.

### Economics: what is the system worth?

**The framing, replacing break-even.** Rather than fixing a break-even and powering to clear it, **fix a feasible sample size and report what the system is worth, with an interval.** There is no threshold to assume, so the study cannot be unfalsifiable, and the output is the number a farm or Nedap actually needs.

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

## 8. Decisions

### Settled

| | Decision | Basis |
|---|---|---|
| Arms | Three: trim within 1 week, trim at 4 weeks, regular farm practice. | Gerard's outline. |
| Arm 2 | Treated at 4 weeks **or sooner** if the routine round or staff pick her up. About **a third never actually waits** - 66% of farm catches land inside four weeks. Record the actual treatment date; pre-specify a per-protocol analysis alongside intention-to-treat. | Gerard + pilot timing. |
| Arm 3 | **Regular farm practice**, including routine trimming — not an untreated arm. Its coverage varies by farm, is only partly standardisable, and must be recorded per herd and carried in the model. | Gerard, 2026-09-10. |
| Common inspection point | Routine **dry-off trim** — coverage does not differ by arm in the pilot (88.6% vs 92.7%, p = 0.62). Defined as a window of −45 to +7 days, not a day. | Measured; see §4. |
| Cure outcome | Read from the follow-up trim coming back trim-only. **Sized on white line and sole ulcer**; foot rot excluded as a recording artifact; DD collected opportunistically. | Gerard + pilot data. |
| DD rechecks | **Not standardised** — not feasible on farm. | Gerard, 2026-09-10. |
| Minimum gap for cure | Applies to **foot rot only**. White line and sole ulcer keep their early returns, which are genuine failures. | Gap distributions differ sharply by lesion; see §4. |
| Lesion severity | **Dropped** as an outcome — not standardisable across farms and trimmers. | Gerard, 2026-09-10. |
| Value case | Rests on **white line and sole ulcer**, the lesions the camera detects well. DD is a secondary question. | Gerard; supported by the pilot's detection split. |
| Measurement windows | **Different windows per contrast**: 0–28 days for arm 1 v 2, 60–90 days for arm 1 v 3. | The 1v2 contrast is 10× cheaper at 28 days; see §5. |
| Economic framing | Report **what the system is worth**, with an interval — not a pass/fail against a break-even. | Gerard's inversion; avoids assuming the answer. |
| Incidence input | Measured: **27.1 new cases per 100 cow-years**, this herd at the **high end** of a range. Definition is `status_lesion == "New"`. | Gerard's definition + validated denominator. |
| System cost | $0.65–0.80 per cow per month. | Gerard's quotes. |
| Enrolment point | **At the alert.** Detection accuracy is not a study question, so a freshening cohort buys nothing for these outcomes at x1.6 cows and double the duration. | Gerard, 2026-09-10. |
| Primary question | **Does it pay?** Net margin per alerted cow, arm 1 v arm 3. Clinical outcomes explain the economics rather than standing alone. | Gerard, 2026-09-10. |
| Enrolment target | **~6,000 across three arms**, set by the composite margin endpoint. 4,300 leaves the margin CI straddling break-even. 4-5 herds over a year. | Pilot economics; see §5. |
| Chronicity interaction | Costs **exactly 2×** the sample size — verified, not estimated. | Simulation + direct test; see §5. |
| `RECK` events | Dead end — reproductive, not hoof. | Confirmed in the data. |

### Open

| | Decision | What it turns on |
|---|---|---|
| 1 | Drop the "no lameness history" eligibility restriction and stratify instead. **Recommended.** | It removes 54.8% of lactation 3+ cows against 15.8% of first-lactation, skewing the sample young. The reviewer argues the same on external validity. |
| 2 | Buy the chronicity × lactation interaction at 2× the sample size, or adjust only. | Recurrence rises 34% → 52% across parity, so there is real reason to think it matters. Purely a budget decision now that the price is known. |
| 3 | Include locomotion scoring or a second camera as a reference standard, and at what frequency. | Without one, sensitivity and specificity are not estimable and lameness duration cannot be measured. The pilot had no reference standard at all. |
| 4 | Number of herds, and expected alerts per herd per week. | Drives whether the recurrence target (~2,850 enrolled) fits inside a year. This farm alone produces ~69 alerts/week. |
| 5 | IOFC per kg, cull value, cost per trim. | The affordability figures scale directly with all three. |
| 6 | Whether "other"/corkscrew is being double-entered like foot rot. | 47% of its non-cures fall inside 7 days. Not on the critical path — "other" is outside the value case. |
