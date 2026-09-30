# Does it pay to use NEDAP SmartSight?

## A proposal for a three-arm randomized trial

------------------------------------------------------------------------

## 1. The question and objective

**Determine if acting on SmartSight alerts leave a dairy better off, and by enough to pay for the system?**

- The pilot study answered several important questions and provided insights into things we need to consider in a study that looks at if using SmartSight is worth it.

------------------------------------------------------------------------

## 2. Proposed design

Randomized controlled trial,

- **3 arms**

- **14 months in total.** Up to 8 months of enrolment, then every cow is followed to one study end date, 14 months after the study starts.

  - The last cow enrolled gets at least 6 months. That covers milk (90 days), cure (60-day recheck), and culling and recurrence at 180 days.

  - A 20 month study (12 months after the last cow) would allow answering more questions but increases cost.

- **6 herds of 2,000–5,000 cows** across three regions

  - Two each in New York, Midwest and the West Coast as I have DVM collaborators in those regions and I know you are active in these regions.

  - **Four herds is a workable minimum**

    - Its precision cost and calendar-time cost are both in §5.

  - **Eight herds is our preference, but increases cost** about \$55,000 more (§9).

### Arms

The proposed arms are as follows.

+----------------------+-------------------------------------------------------------------------------------------------------------+
| Arm                  | Protocol                                                                                                    |
+======================+=============================================================================================================+
| **1. Early**         | Cow gets trimmed within **1 week** of the alert.                                                            |
+----------------------+-------------------------------------------------------------------------------------------------------------+
| **2. Delayed**       | Cow gets trimmed **4 weeks** after her alert                                                                |
|                      |                                                                                                             |
|                      | - sooner if the routine schedule or staff put her on trim list.                                             |
+----------------------+-------------------------------------------------------------------------------------------------------------+
| **3. Farm practice** | Alerted and recorded, not acted on. Treated only if staff or the routine schedule put her on the trim list. |
+----------------------+-------------------------------------------------------------------------------------------------------------+

For all 3 arms **if farm staff identify a cow as lame she is trimmed, regardless of arm.**

Similar to the pilot we would have alerts go into DairyComp and add cows to the trim list based on a priori randomization.

Arm 2 is needed to determine whether the trims that find no lesion in Arm 1 would have developed into treatable lesions — that is, whether Arm 1 is actually preventing them.

**Arm 3 is regular farm practice, not an untreated arm.**

- In the pilot the equivalent group was trimmed 49.8% of the time, mostly by routine trimming.
- Herds with **little mid-lactation trimming** would add to the difference between the arms.

**Arm 2 is contaminated by design.**

- Based on the pilot farm detection is heavily front-loaded

  - in the pilot 66% of farm caught cows in the TX group were inside four weeks, and week 1 alone is 31%

    - If this persists 1/3 of arm 2 will be treated before its protocol week.

    - This means we will pre-specify a per-protocol analysis (restrict analysis to cows in ARM 2 that follow the 4 week delay protocol) alongside intention-to-treat to separate the impact of contamination.

    - The one-third is measured on first alerts. A cow keeps her arm for later alerts too, so later alerts can be contaminated the same way. Per-protocol is defined on the enrolling alert; protocol deviations on later alerts are recorded and reported.

### Enrolment

- A cow enters **at her first SmartSight alert** and is randomized then.
  - This means randomization allocation will be run daily for unenrolled cows.
- Randomization is **blocked by lameness history (new / chronic) and lactation group (1 / 2 / 3+).**
  - Blocking balances the arms on the two covariates most likely to change the effect.
- **Each cow is enrolled once.** Her arm is a strategy for every alert she gets until the study ends, not just the first.
  - After her first alert cows will undergo a standard recheck protocol for hoof horn lesions and become eligible to be checked again based on alerts 28 days after her recheck.
  - Cows with infectious lesions become eligible for re-alerting 28 days after her last trim unless she has strong decline.
  - Cows waiting for a trim in ARM 1 and 2 will have a delay on alerts until trimming occurs

**Cows that calve during the study:**

- **She keeps her arm.** Alerts after calving are handled by the same protocol.
- **Milk (primary outcome) stays in the enrolment lactation.** The 90-day window ends early if she dries off; she contributes the weeks she milked, and the sample size allows for it (§5).
  - Milk after calving is not used.
- **Culling and recurrence follow the cow**, across the calving, to the study end.
- **Dry-off lesion is read at the enrolment lactation's dry-off.**
- A cow never enrolled who calves and is alerted in her new lactation can enrol then, at DIM 5 or later.
- Lactation group for the randomization block is set by lactation at the alert.

### Eligibility

**Herds**

Herds are monitored by collaborating investigators and myself, two in each of our regions minimize travel costs.

**The regional spread.**

- Housing, flooring, climate and trimming practice differ by region.
- We choose 6 herds to balance cost and increase generalizability. Details on the reasons for 6 is in the sample size section.

**Each participating herd must have:**

- **Reliable** hoof trimming data
  - Before the start of the study we will work with trim staff to ensure the data is complete and consistently coded.
  - Monthly checks will be done to ensure this remains consistent throughout.
- **Routine dry cow trimming.**
- Routine mid lactation hoof trimming is ok but herds should not trim cows routinely more than 2x/lactation.
  - Herds that trim more often than this dilute the arm 1 v 3 contrast further and should not be enrolled.
- Trained trimming staff; daily milk weights; ability to have SmartSight installed.
- Ability and willingness to do a standardized recheck at around 28 days after a block has been placed on a cow.

**Cows**

**A minimum of 5 days in milk.** A cow alerted in her first days after calving is excluded. She re-enters if alerted later.

- Fresh cows can walk abnormally for reasons that are not hoof lesions.
  - The median pilot cow was alerted at **DIM 150**. A DIM 5 floor would have excluded **11 of 849 cows (1.3%)**.

------------------------------------------------------------------------

## 3. What the design answers

+---------------+---------------+---------------------------------------------------------------+
|               | Comparison    | Answers                                                       |
+===============+===============+===============================================================+
| **Primary**   | Arm 1 v arm 3 | How much does acting on alerts gain?                          |
+---------------+---------------+---------------------------------------------------------------+
| **Secondary** | Arm 1 v arm 2 | Does acting *early* matter - prevention, cure and recurrence? |
+---------------+---------------+---------------------------------------------------------------+

- **Arm 1 v 3 is how we will estimate the milk impact of the technology.**
  - Milk is the outcome the study is sized on.
  - Culling, cure and recurrence are estimated with the precision that milk production sample size gives.
  - It estimates whether acting on alerts pays. Proving it pays depends trimming costs and prize of the technology and this study can provide estimates to inform this prize
- **Arm 1 v 2 is how we will tell whether acting early matters.**
  - Whether the empty arm-1 trims were prevention or wasted trims (below).
  - Whether a lesion left four weeks cures and recurs the same as one treated within a week (§4).

### Why the trial needs three arms rather than two

- **An arm-1 trim that finds no lesion cannot be read on its own.**
  - Either the camera was wrong (a wasted trim), or early trimming prevented the lesion (the system working).
  - One is a cost of the system, the other a benefit.
- **Arm 2 separates them.** If arm-2 cows show lesions at four weeks where arm-1 cows had none at one week, the empty arm-1 trims were prevention.
  - From the pilot 54.9% of arm-1 trims are expected to find nothing, so this distinction decides whether most arm-1 trims count for or against the system.

------------------------------------------------------------------------

## 4. Outcomes

### Primary

**Daily milk, arm 1 versus arm 3**, from 14 days before the alert to 90 days after.

- Indexed to days since alert.
- **Each cow's own 7-day pre-alert average enters as a co-variate.** This is what makes the study affordable.
  - In the pilot, a cow's baseline predicts her next 90 days closely (r = 0.89).
  - Adjusting for it cuts the variance of a cow's 90-day mean from 98 to 42 kg², so the study needs about 5,000 cows rather than roughly 11,000.

### Secondary

**1. Cure at a standardized recheck for white line and sole ulcer lesions. Primary comparison: arm 1 versus arm 2.**

**Why arms 1 and 2 carry cure.**

- Both are trimmed by protocol, so cure is measured on the same kind of cow in each.
- It is the clinical question: **does a lesion left not treated for four weeks still heal as well?**

**Arm 3 cure rates will be reported too but should be considered descriptive**

**2. Culling at 180 days, on every enrolled cow.**

- Measures on **all enrolled cows,** not only those found lame**.**

**3. Recurrence within 180 days** for cows in **arm 1 versus arm 2.**

- **Why arms 1 and 2, the same reason as cure.** Recurrence is only measured in cows with a lesion found first, and finding one depends on the arm.
  - Arms 1 and 2 are both trimmed by protocol, so the first lesion is found in the same kind of cow in each.
- **Arm 3 is reported, as descriptive.**

### Descriptive

**Lesion prevalence at the routine dry-off trim.**

Every cow is trimmed around dry-off whatever her arm, so this is the one lesion measure not driven by inspection rate. Coverage was **88.6% in Control against 92.7% in TX.**

- **Descriptive, not an outcome, in a 14-month study.** Only 21% of cows reach dry-off inside 6 months of their alert, so the last cows enrolled mostly never get there.
  - At 5,000 enrolled that is about 358 cows per arm, enough to detect only an **8.1-point** difference on a 22.4% baseline.
- **Extending the study to 20 months would make it an outcome.** Twelve months of follow-up after the last enrolment brings 68% of cows to dry-off - about 1,133 per arm - and detects **4.7 points**. It adds about \$21,500 (§9).
- **Demoting it does not reopen the ascertainment problem.** The primary outcome (milk) and culling do not depend on a cow being looked at.
- **It is a window, not a day.** Trims cluster 21 to 7 days *before* dry-off. ±7 days catches only 9.6% of them; −45 to +7 catches about 90%.
- **Baseline: a lesion is found at 22.4% of dry-off trims.**
- **Only cows with at least 90 days from alert to dry-off, and dry-off before the study ends.** This selects on DIM at alert, so report DIM for kept and dropped cows.

### Not outcomes

- **Reproduction.** Nothing in the herd's records: median days to first service 77 v 78, services 1.93 v 1.94. No effect to power against.
- **Lesion severity.** Not standardizable across farms and trimmers.
- **Detection sensitivity.** Not estimable from an alert-triggered cohort at any size.

------------------------------------------------------------------------

## 5. Sample size

**Target: 5,000 cows enrolled across three arms, six herds.**

Powered on the primary milk contrast, arm 1 v 3: **82% power for a 1.0 kg/day observed difference**, two-sided α = 0.05, Hartung-Knapp test (§6).

It was sized by simulating the whole trial, and checked with a simple calculation (both below).

| Enrolled | Power | 95% interval on the difference |
|---|---|---|
| 4,000 | 72% | ±0.75 kg |
| **5,000** | **82%** | **±0.66 kg** |
| 6,000 | 85% | ±0.62 kg |
| 8,000 | 93% | ±0.56 kg |

*For a 1.0 kg observed difference (a 2.0 kg true effect), six herds.*

- **The variance is the pilot's own, over the full 90 days.** A cow's 90-day mean varies by 42 kg² after adjusting for her baseline, against 98 kg² without it.
  - It rests on the 114 pilot cows alerted early enough to have 90 days of milk. So the study is planned on the **90th percentile** of a bootstrap of that estimate (52 kg²), not the point.
  - Without the baseline covariate the variance is 2.3 times larger, and the study would need roughly 11,000 cows (scaled by the variance, not simulated).
- **1.0 kg/day is the design target, not a pilot estimate.**
  - **The observed difference is about half the true effect.** Farm practice trims 65% of arm-3 cows by day 90, so they get much of the benefit too. A 1.0 kg observed difference needs about a 2.0 kg true effect.
  - If the true effect is nearer 1.5 kg, the observed difference is about 0.75 kg and 5,000 gives 57% power. It would take about 9,000 cows.
  - **1.0 kg is the smallest effect worth detecting, not break-even.** At current pricing milk alone does not pay at 1.0 kg; the study estimates the total return with its interval.
  - **The pilot does not measure it.** On the outcome this study uses (kg, adjusted for each cow's baseline), the pilot's TX–Control difference at days 25–30 was **+0.08 kg** (95% CI −1.0 to +1.2). That neither supports 1.0 kg nor rules it out.
  - An earlier figure of 1.05 kg came from milk as a percentage of baseline (97.9% v 95.4%). TX cows started from a lower baseline (42.1 v 42.5 kg overall, 39.5 v 41.8 kg in new cows), and a percentage of a lower baseline flatters the same milk. That is why the study adjusts for baseline instead.
  - The pilot's effect sits in new cows, not chronic ones (see §6). A study that averages over both is sized on the average.
- **The target assumes farm practice in arm 3 dilutes like the pilot's.** Routine trimming reaching arm-3 cows depends on DIM at the alert: in the pilot, 5% of cows alerted at DIM 0–60 were routine-trimmed within 60 days, 55% at DIM 61–120, just before the herd's routine window.
  - Herds whose routine trimming reaches more arm-3 cows dilute the contrast more. At twice the pilot's rate, 6,000 cows gives 74% power instead of 87%; at half the rate, 95%.
- **Late-lactation cows stay in.** 38% of alerted cows are past DIM 200, and three in four of them dry off inside 90 days. They contribute milk until they do, so 97% of enrolled cows add some milk and two in three add the full 13 weeks. Dropping them instead would lose over a third of the study.
- **The random slope costs cows, and it is not optional.** Without it the analysis cannot see herds differing in the effect.
  - It is not a cluster design effect. Randomization is *within* herd, so herd is a block.
- **The test matters as much as the size.** With six herds, how the analysis allows for between-herd variation changes the power at the same size:
  - **Hartung-Knapp** (pre-specified): false-positive rate 4.8% in the simulation, 72% power at 4,000.
  - A normal-theory (z) test: 4.4%, 85% at 4,000 - but it assumes the between-herd variation is known, which six herds cannot show.
  - Kenward-Roger in a mixed model: 0.7%, about 55% at 4,000. Far too cautious with six herds.

### How the sample size was simulated

A simulation of the whole trial, cow by cow, run 1,000 times at each size. Each simulated trial:

- **Draws cows from the pilot**: their baseline milk, DIM at the alert, lactation and history.
- **Lets each cow leave milk** when she dries off (from this herd's own lactation lengths) or is culled (the pilot's rate by DIM). She contributes the weeks she milks, up to 90 days.
- **Trims arm 3 as the pilot's Control arm was trimmed**, by staff or routine round, at the pilot's rates for her DIM. Arm 1 is trimmed as the pilot's TX arm was; arm 2 four weeks later unless the farm gets there first.
- **Gives each cow the benefit from the day she is trimmed** to the end of her milk window.
- **Spreads the cows over six herds** that differ in routine trimming and in the size of the effect (0.25 kg between herds).
- **Analyses each trial as §6 specifies** and counts how often it finds the effect.

It reproduces the pilot where it can be checked:

- Farm trimming by DIM at the alert: 5.3 / 52.2 / 34.9 / 19.5% of arm-3 cows routine-trimmed within 60 days, against the pilot's 5.1 / 54.7 / 35.0 / 19.5%.
- Cows still milking at day 85: 63%, against 59%. Slightly optimistic.
- With no effect, it calls one 4.8% of the time, as a 5% test should.

An independent review of the code found no errors in the statistics; the problems it did find were fixed before these figures were run.

### Checked with a simple calculation

The same answer from a textbook formula, with none of the simulation's machinery:

- **Dilution**, from the pilot's raw time-to-trim curves: arm 1 keeps 88% of the benefit, arm 3 gets 38% of it, so the observed difference is **0.50** of the true effect. The simulation gives 0.49.
- **Standard error**, from the variance, cows per arm and between-herd spread: ±0.70 kg at 5,000. The simulation gives ±0.66.
- **Power at 5,000: 83%.** The simulation gives 82%.

**One choice moves it:** whether a dry-off trim counts as arm-3 treatment. A cow trimmed just before drying off leaves the milk outcome days later, so she gains almost nothing, and both calculations leave those trims out. Counting them as full treatment would lower the observed difference to 0.43 of the true effect and power to 71%.

### What the result is sensitive to

Power at 5,000 enrolled, moving one input at a time (simple formula, Hartung-Knapp):

| Input | Planned | Changed to | Power |
|---|---|---|---|
| *As planned* | | | **83%** |
| True effect | 2.0 kg | 1.5 kg | 59% |
| | | 2.5 kg | 95% |
| Arm-3 dilution from farm practice | pilot's | 20% more | 65% |
| | | 20% less | 93% |
| Between-herd SD of the effect | 0.25 kg | 0.5 kg | 69% |
| | | 0.75 kg | 52% |
| Variance of a cow's 90-day mean | 51.9 kg² | 42.4 (the pilot point estimate) | 88% |
| | | 60 kg² | 78% |
| Cows giving no milk | 3% | 15% | 78% |
| Number of herds | 6 | 4 | 66% |
| | | 8 | 89% |

- **The true effect, the farm's own trimming in arm 3, and how much herds differ matter most.** Each can take power below 70%.
- **Arm-3 dilution is the one the design can still influence**, through which herds are chosen and their routine-trimming rule (§2). Herds whose routine round reaches fewer alerted cows raise power.
- **The variance and the loss of cows matter less.** The baseline covariate has already done most of what can be done there.

### How many herds

Power at 5,000 enrolled for a 1.0 kg observed difference, by the number of herds and how much the effect differs between them (simulation, Hartung-Knapp):

| Between-herd SD of the effect | 4 herds | **6 herds** | 8 herds | 10 herds |
|---|---|---|---|---|
| 0.25 kg *(planning value)* | 68% | **81%** | 87% | 89% |
| 0.50 kg | 47% | **65%** | 76% | 84% |
| 0.75 kg | 33% | **50%** | 61% | 75% |

- **The study is planned at 0.25 kg with six herds: 5,000 enrolled.**
- The rest of the table is the sensitivity. If herds differ more than planned, more herds protects the study better than more cows.
- **Four herds is a real loss:** 68% even at the planning value. With four, the between-herd spread is estimated from four numbers, and the test has only three degrees of freedom.
- **Eight herds is insurance.** At the planning value it adds 6 points of power. Its value is in the lower rows: if herds differ by 0.5 kg, eight herds hold 76% where six fall to 65%.
  - It costs about \$55,000 more (§9), which is why six is the plan and eight the preference.

### What each herd supplies

At 5,000 enrolled: **833 alerted cows per herd** across six.

**Plan for fewer alerts than the pilot.** The pilot farm enrolled 0.024 alerted cows per week for every cow in milk (68 a week from about 2,800). It is likely a high-alert herd, so other herds are planned at 0.010-0.020.

Months to enrol 833 cows:

| Herd size  | 0.020 per cow per week | 0.015 | **0.010** |
|------------|------------------------|-------|-----------|
| 2,000 cows | 4.8                    | 6.4   | 9.6       |
| 3,000 cows | 3.2                    | 4.3   | **6.4**   |
| 5,000 cows | 1.9                    | 2.6   | 3.8       |

- **Eight months of enrolment covers a 3,000-cow herd at under half the pilot's rate, with time to spare.** 6.4 months is expected at the low rate.
- A 2,000-cow herd at a low rate does not finish in eight months. Take more cows from the bigger herds instead - randomization is within herd, so herds need not enrol equal numbers.

### Timeline

+------------+----------------------------------------------------------------------------------------------+
|            |                                                                                              |
+============+==============================================================================================+
| Enrolment  | **up to 8 months**, in parallel across the six herds (3.2-6.4 months expected at 3,000 cows) |
+------------+----------------------------------------------------------------------------------------------+
| Follow-up  | **every cow to one study end date**, at least 6 months after the last enrolment              |
+------------+----------------------------------------------------------------------------------------------+
| **Total**  | **14 months**                                                                                |
+------------+----------------------------------------------------------------------------------------------+

- **Following each cow for 365 days would have set the duration at 20 months or more.** Following all cows to one end date does not lose that information: early cows still reach a year, and time-to-event analysis uses every cow for as long as she is watched.
- What the last cow's 6 months must cover: milk (90 days), cure (60-day recheck), and culling and recurrence at 180 days.
- Recurrence needs a lesion first, so the last cows enrolled may fall a few weeks short of 180 days. They are censored, not dropped.

**What a 12-month study would lose** (8 months of enrolment, 4 of follow-up):

- Milk (90 days) and cure (60-day recheck) stay complete for every cow.
- If enrolment runs the full 8 months, cows enrolled in the last 2 months have under 6 months. **Culling and recurrence at 180 days are censored for them**, about a quarter of the study.
- If enrolment finishes as expected (3.2-6.4 months), every cow still gets 5.6 months or more, and 12 months loses almost nothing.
- So 14 months is the safe plan; 12 is possible if enrolment is on time.

### What this design detects

Smallest difference detectable at 80% power at 5,000 enrolled (1,667 per arm). Arm 1 v 3 unless noted:

+-----------------------------------------------+-------------------------+----------------------------------------------------------------+
| Outcome                                       | Cows per arm            | **Smallest detectable difference**                             |
+===============================================+=========================+================================================================+
| **Milk** (primary)                            | 1,667                   | **1.0 kg/day** observed contrast (82% power)                   |
+-----------------------------------------------+-------------------------+----------------------------------------------------------------+
| Culling at 180 days, all enrolled             | 1,667                   | **3.4 points** on 16.0%                                        |
+-----------------------------------------------+-------------------------+----------------------------------------------------------------+
| Cure, white line and sole ulcer *(arm 1 v 2)* | 290 assessed            | **11.5 points** on 49.3%                                       |
+-----------------------------------------------+-------------------------+----------------------------------------------------------------+
| Recurrence at 180 days *(arm 1 v 2)*          | 583 with a first lesion | **7.7 points** on 36.1%                                        |
+-----------------------------------------------+-------------------------+----------------------------------------------------------------+
| Lesion at dry-off *(descriptive)*             | 358 reach dry-off       | **8.1 points** on 22.4% (4.7 with 12 months after the last cow) |
+-----------------------------------------------+-------------------------+----------------------------------------------------------------+

- **Cure is targeted at +15 points**, detected with 96% power.
- **Dry-off is descriptive at 14 months.** The count uses only the 21% who reach dry-off inside six months; early-enrolled cows add more. With 12 months after the last cow (a 20-month study) 68% reach it and it becomes an outcome (§4).
- Binary outcomes are sized without a between-herd term. They are secondary, and the pilot gives no estimate of how much they vary by herd.

### The limitation, stated up front

- **Break-even needs 0.25-0.6 points less culling across all enrolled cows.** That assumes a \$0.65–0.80/cow/month subscription, \$18 a trim and \$1,650 net cost of a cull (replacement less cull value).
- **The study's interval on culling is ±2.5 points.** It cannot tell break-even from zero.
- **The same holds for milk.** At 5,000 the interval on the milk difference is ±0.66 kg. If the observed difference is 1.0 kg, the lowest value the study can vouch for is typically about 0.3 kg/day.
  - No feasible study can: detecting it would take 170,000 to a million cows.
- **So this study will *estimate* whether the system pays. It will not *prove* it.** An honest estimate is what a purchasing decision needs. It is not a hypothesis test, and this proposal does not claim one.

------------------------------------------------------------------------

## 6. Analysis

**Milk.** Mixed linear model on weekly averages.

- Fixed: arm, **the cow's 7-day pre-alert milk**, DIM spline, lactation group, lesion history, breed, herd. Random: cow intercept, and **arm within herd** - `(1 + arm | herd)`.
- **The random slope is what lets the analysis see herds differing in the effect.** The sample size already pays for it (§5).
- **The test is Hartung-Knapp**, fitted as six per-herd estimates pooled with a between-herd variance, with the standard error rescaled by how much the herds actually disagree, and a t reference on five degrees of freedom.
  - With six herds the between-herd variance is estimated from six numbers. A normal-theory test treats it as known; Kenward-Roger allows for it twice and is far too cautious (a 0.7% false-positive rate in the simulation, against 5% intended). Hartung-Knapp holds 4.8%.
  - Cows that dry off or leave contribute the weeks they milk, weighted accordingly.
- **Arm is a main effect.** The `arm × history` interaction is estimated and reported, but not powered - see below.

**Cure.** Logistic, same covariates, per-herd estimates pooled and tested the same way (Hartung-Knapp).

**Lesion at dry-off.** Reported by arm with its interval, from the same model. Not tested (§4).

### The chronicity interaction: explored, not powered

- Chronic cows do worse. Recurrence rises 34% → 48% → 52% across parity; cure falls from 51.9% in new cows to 45.0% in chronic ones.
  - Those are **main effects**, and adjusting for them is free.
- **We expect the treatment benefit to be larger in new cows, and the pilot points that way.** Pilot TX–Control milk, days 1–30, baseline-adjusted:

|                            | TX effect   | 95% CI           |
|----------------------------|-------------|------------------|
| New cows (61% of enrolled) | +0.39 kg    | −0.64 to +1.42   |
| Chronic cows               | −1.45 kg    | −2.75 to −0.15   |
| **Difference**             | **1.84 kg** | **0.18 to 3.50** |

- History was recorded before randomization, so each row is a randomized comparison. But it is one herd, a subgroup looked at after the fact, and a wide interval. Planning on the point estimate would be optimistic.
- Like the overall effect, each group's observed effect is about half its true effect, because farm practice treats arm 3 too.

**What 5,000 enrolled gives** (simulation, 6 herds, Hartung-Knapp, pilot's 61% new):

| Estimate               | 95% interval   |
|------------------------|----------------|
| Overall effect         | ±0.67 kg       |
| Effect in new cows     | about ±0.85 kg |
| Effect in chronic cows | about ±1.1 kg  |
| New minus chronic      | about ±1.4 kg  |

*The subgroup intervals are scaled from the overall one by each group's share of cows.*

- **If the benefit sits in new cows** (none in chronic, the same 1.0 kg observed overall), the study finds it in new cows alone with **96% power**, and the new-v-chronic difference with 66%.
- **If the effect is equal in both**, power in new cows alone is 61%.

**If Nedap wants the difference powered:** power on the new-v-chronic difference, if the whole benefit is in new cows:

| Enrolled | Power on the difference |
|---|---|
| 4,000 | 57% |
| **5,000** | **66%** |
| 6,000 | 73% |
| 8,000 | 84% |

- **80% takes about 7,500 cows** - 1,250 per herd, about 9.6 months of enrolment for a 3,000-cow herd at the low alert rate. That breaks the 8-month enrolment window.
- That is the best case: no benefit at all in chronic cows. A smaller difference would take more.
- So the difference is **estimated and reported with its interval, not powered.** The estimate still tells a follow-up study whether to target new cows.

**Culling and recurrence.** Time-to-event, same covariates, stratified by herd. Culling is a competing risk for recurrence, not attrition. Recurrence is compared on arms 1 v 2 (§4).

**Staggered entry.** Censor explicitly. Do not restrict to cows with complete follow-up - that selects the earliest enrolled, the trap the pilot's day-30 milk figures fell into.

**Record separately:** staff `CHKLAME` detections and routine-round trims. Median time to trim differs threefold (7 v 23 days), and routine coverage varies by herd.

**Pre-specify before enrolment opens.** Each of these moved answers in the pilot.

- **What counts as a miss.** The pilot settled on: a lesion is missed only if **no alert reached DairyComp at any time before it**. A cow alerted and never examined counts as alerted, not missed.
  - The pilot reached that rule after seeing the data, and earlier versions moved the answer. The trial should start with it.
  - Every enrolled cow has been alerted, so by this rule no lesion in an enrolled cow is a miss. In the pilot, 0 of 262 cohort cases; 309 of 315 cases outside the cohort.
  - **Where one arm must act and another need not, an alerted-never-examined cow is an outcome in one arm and a protocol deviation in the other.** Settle how each arm records it before unblinding.
- **The warning window.** The pilot used 28 days, to match DairyComp's `FTDAT<-28`.
  - The window does not decide who was missed. It only sorts each miss into a category: flagged with no alert raised, or no flag in the window.
  - The camera's blind spot depends on it: 29 cows were never flagged, but 58 had no flag in the 28 days.
- **How an alert's date relates to the detection behind it.**
  - The import runs about 05:00 and stamps the *load* day. **68% of pilot alerts are dated at least a day after the attention behind them.**
  - Measured: across 96 DairyComp command logs every `NEDLAME` is written 05:31-05:35, and trimming never starts before 05:35. On a same-day cow the alert always comes first.
  - **Fix it at source, and check the fix first.** `EDAY=LMSFD` in the `ENTER` command would stamp the camera's date. **But `LMSFD` has been frozen in DairyComp's export since about 2026-02-02.** As it stands it would date every alert in early February. Confirm `LMSFD` updates daily before relying on it.
- **Which lactation a cow is in when she is alerted.**
  - A cow calving overnight may not have `FRESH` entered before the morning command, so her alert is written against the **previous** lactation.
  - It hit 3 of 1,608 pilot alerts - but **3 of the 8 at DIM 0–1**, the only window where it can happen.
  - **In a trial, lactation group is a randomization block. A cow allocated on a stale lactation is enrolled wrongly, and no later analysis repairs it.**
  - The DIM 5 floor removes this. Also run the alert command after fresh events are entered, and resolve lactation by date.
- **The farm's trim list, saved on every trim day.**
  - A trim event records what was *done*. The list records what was *intended*.
  - Without it, a cow booked but not trimmed - moved pen, refused the chute, dried off, sold - looks the same as a cow nobody noticed.
  - `CHKLAME` does not fill the gap: 82.5% are entered within a day of the trim.
  - **In a trial, compliance is an outcome.** It also records *why* an arm-3 cow was trimmed, which §4 asks for.
  - Cost of not having it: showing that 24 of 52 pilot same-day trims were already booked took a read of 96 command logs. With the list, it is a lookup.
- That alerts landing 1–7 days after a trim are mostly the camera reacting to the trimmed cow.
- That "trimmed" means `LAME` + `FOOTRIM` + `TRIM`, never a subset.
- **The denominator for every rate.** A rate averaged over cases that could never fail looks small.
  - The pilot's stale-lactation rate is 0.19% of all alerts but **37% of alerts in the calving window** - the only window where it can happen. Fix each denominator before the analysis.

------------------------------------------------------------------------

## 7. What we need from Nedap

These are conditions of the study, not wishes.

1.  **The alert and score files as sent, with timestamps.**

    - DairyComp does receive the score (`LMSV`), once a day in the farm export. That settled what the pilot first thought was unjudgeable.
      - Every one of the pilot's "cannot tell" cases turned out to be the `Low` route's score gate working as designed.
    - What DairyComp's copy cannot show is what Nedap sent, and when.
      - The Nedap export and the DairyComp file run at different times. An alert or score can be overwritten, or lost, without a trace.
      - In the pilot, 17 cows had a LOW flag but DairyComp held no score for them. These files cannot say whether it was never sent or overwritten.
    - **Log every raw flag and score with a timestamp, independent of the DairyComp import.**

2.  **The alert rules, frozen for the study.**

    - In mid-April, before the pilot went live, Nedap moved the LOW trigger from a score of about 50 to about 70, to send more scores into DairyComp.
    - The farm's `Low` command still required a score of 1-30. So nearly every LOW flag was blocked by design: 13,199 LOW flags after go-live, 81 `Low` alerts out of 2,422.
    - **Agree the thresholds and the DairyComp commands before enrolment, and change neither during it.**
    - **The threshold itself is still an open question.** The pilot could not say whether a LOW score should start at below 30 or below 70. It has to be chosen, with Nedap, before it is frozen.

3.  **Every cow in each herd on the SmartSight instance, checked monthly.**

    - A cow missing from SmartSight is not being watched at all. She cannot be alerted, so she cannot be enrolled.
    - In the pilot, first-lactation cows stopped being added to the SmartSight instance: after 2026-06-24, **160 fresh first-lactation cows were absent.** Nothing in DairyComp showed it.
    - Enrolment is at the alert, so a gap like this silently removes a whole lactation group from the study.

**Why this matters for enrolment.** In the pilot, 243 cows with a lesion were flagged by the camera while alerting was live, but no alert reached DairyComp.

- 231 were the enrolment rules working as designed.
- **12 were genuine losses:** a decline flag fired, no rule explains the silence, and no `NEDLAME` appeared.
- **Every one was a cow who was never enrolled.** A lost alert is exactly what prevents enrolment, so the failure and its consequence are one event.
  - It is invisible from inside DairyComp. It showed here only because the raw camera export could be checked against the import.
- **A limitation to name before Nedap does:** the pilot cannot see alerts lost for cows *already* enrolled. Neither will the trial, without the raw log.

Without these, the study measures the camera and the integration together and cannot separate them. That is what happened in the pilot.

------------------------------------------------------------------------

## 8. Decisions taken

- **5,000 enrolled, six herds, 14 months** (up to 8 months of enrolment, 6 of follow-up after the last cow). Milk adjusted for each cow's baseline, with an arm-by-herd random slope (§5, §6).
- **Every cow followed to one study end**, at least 6 months after the last enrolment. Culling and recurrence at 180 days; 365 days reported where cows reach it (§2, §4).
- **Culling compared on all enrolled cows**, not lame cows only (§4).
- **Randomization blocked on chronicity and lactation group.** The new-v-chronic difference is estimated, not powered, at 5,000. Powering it would take about 7,500 enrolled and 9.6 months of enrolment, beyond the 8-month window (§6).
- **Six herds** across three regions, two each. Four is the stated minimum. Eight is preferred but needs about \$55,000 more (§5, §9).
- **Lesion at dry-off is descriptive.** It becomes an outcome if the study runs 20 months (§4).
- **Cure targeted at +15 points.** §5 states what the design detects on every outcome.
- **Cure and recurrence compared primarily on arms 1 v 2**, where both are protocol-trimmed. Arm 3 is reported with its caveat and its detection route recorded.
- **Alert rules and DairyComp commands frozen for the study** (§2, §7).

------------------------------------------------------------------------

## 9. Budget

**Total: \$263,150 over 14 months** - six herds, 5,000 enrolled.

+-------------------------------------------------------+---------------+
|                                                       |               |
+=======================================================+===============+
| Personnel - farm visits, project management, analysis | \$217,500     |
+-------------------------------------------------------+---------------+
| Travel                                                | \$30,530      |
+-------------------------------------------------------+---------------+
| Data storage                                          | \$15,120      |
+-------------------------------------------------------+---------------+
| **Total**                                             | **\$263,150** |
+-------------------------------------------------------+---------------+

- Farm visits run through enrolment only (up to 8 months). Follow-up is passive data collection.

**Options that add cost:**

+-------------------------------------------------------------------+----------------------------------------------------------------------------+-----------------+
|                                                                   | Adds                                                                       | Total           |
+===================================================================+============================================================================+=================+
| **Eight herds** instead of six                                    | about \$55,000, mostly monthly farm visits, plus travel to the extra herds | about \$318,000 |
+-------------------------------------------------------------------+----------------------------------------------------------------------------+-----------------+
| **20 months** instead of 14 (makes dry-off lesion an outcome, §4) | about \$21,500, project management and data storage                        | about \$285,000 |
+-------------------------------------------------------------------+----------------------------------------------------------------------------+-----------------+

**Not included - to settle with Nedap:**

- **Camera subscription:** \$164,000-202,000 for 18,000 cows over 14 months at \$0.65-0.80 per cow per month. That is 62-77% of the study budget again, so it has to be settled before the total means anything.
- **Extra trimming in arms 1 and 2:** about \$24,000 over the study, at \$18 per trim (first alerts only; later alerts add more).

------------------------------------------------------------------------

## Appendix: pilot figures used

| Quantity | Value |
|---|---|
| Variance of a cow's 90-day milk mean, baseline-adjusted | 42 kg² (planned at 52, 90th percentile) |
| Same, without the baseline | 98 kg² |
| Baseline to 90-day milk correlation | 0.89 |
| Enrolled per week per cow in milk, pilot | 0.024 |
| TX–Control milk, days 25–30, baseline-adjusted | +0.08 kg/day (SE 0.57) |
| Same, TX effect in new v chronic cows, days 1–30 | +0.39 v −1.45 kg/day |
| Control cows routine-trimmed within 60 days of the alert (followed 60+ days) | 28.6% |
| Alerted cows past DIM 200 | 38% |
| Still milking 85 days after the alert (n = 116) | 59%; 24% of those past DIM 200 |
| Culled within 90 days of the alert, DIM 0–60 / 61+ | 30% / 8.7% |
| Completed lactation length, median | 317–320 days |
| TX cows trimmed by day 7 / by day 90 (Kaplan-Meier) | 63% / 98% |
| Arm-3 cows routine-trimmed first within 60 days, by DIM 0–60 / 61–120 / 121–200 / 200+ | 5 / 55 / 35 / 20% |
| Observed arm 1 v 3 difference as a share of the true effect | 0.49 (simulation); 0.50 (simple formula) |
| Alerted cows with a lesion found | 35.0% |
| Alerted cows with white line or sole ulcer | 18.3% |
| Cure at 60 days, WLD/SU | 49.3% |
| Recurrence within 180 days, cow-level | 36.1% |
| Culling within 180 days of a camera flag, farm practice | 16.0% |
| Lesion found at a dry-off trim | 22.4% |
| New-case lesion incidence | 27.1 per 100 cow-years |
| Empty-trim rate, trimmed arm | 54.9% |
| Culling gap at 180 / 365 days, from calving | 6.8 / 7.3 points |
| Alerts per week, pilot farm | 69 |
| Cows alerted per lactation | 62% |
| Lesion cows flagged live, no alert | 243 |
| Of those, genuine integration losses | 12 |
| LOW flags after go-live / `Low` alerts | 13,199 / 81 |
| First-lactation cows absent from SmartSight, after 2026-06-24 | 160 |
