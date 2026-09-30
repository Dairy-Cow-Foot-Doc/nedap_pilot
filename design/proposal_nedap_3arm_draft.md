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

  - **5,000 cows enrolled**, about 1,667 in each treatment group. §5 sets out what a 4,000-cow version would lose.

- **14 months in total.** Up to 8 months of enrolment, then every cow is followed to one study end date, 6 months after enrolment closes.

  - The last cow enrolled gets at least 6 months. That covers milk (90 days), cure (28-day recheck), and culling and recurrence at 180 days.

  - A longer study (12 months after the last cow: 20 months) would allow answering more questions but increases cost.

- **6 herds of 2,000–5,000 cows** across three regions

  - Two each in New York, Midwest and the West Coast as I have DVM collaborators in those regions and I know you are active in these regions.

### Arms

The proposed arms are as follows.

+----------------------+---------------------------------------------------------------------------+
| Arm                  | Protocol                                                                  |
+======================+===========================================================================+
| **1. Early**         | Cow gets trimmed within **1 week** of the alert.                          |
+----------------------+---------------------------------------------------------------------------+
| **2. Delayed**       | Cow gets trimmed **4 weeks** after her alert                              |
|                      |                                                                           |
|                      | - Sooner if the routine schedule or staff put her on trim list.           |
+----------------------+---------------------------------------------------------------------------+
| **3. Farm practice** | Alerted and recorded, not acted on.                                       |
|                      |                                                                           |
|                      | - Treated only if staff or the routine schedule put her on the trim list. |
+----------------------+---------------------------------------------------------------------------+

For all 3 arms **if farm staff identify a cow as lame she is trimmed, regardless of arm allocation.**

Similar to the pilot we would have alerts go into DairyComp and add cows to the trim list based on a priori randomization.

Arm 2 is needed to determine whether the trims that find no lesion in Arm 1 would have developed into treatable lesions.

- This answers the question does trimming the cows with no lesions in Arm 1 help them.

**Arm 3 is regular farm practice, not an untreated arm.**

- In the pilot the equivalent group mostly by routine trimming.
- Herds with **less mid-lactation trimming** would add to the difference between the arms and reduce sample size.

**Arm 2 will be contaminated by staff detection**

- Based on the pilot farm detection is heavily front-loaded

  - in the pilot 66% of farm caught cows in the TX group were inside four weeks, and week 1 alone is 31%

    - If this persists 1/3 of arm 2 will be treated before its allocated treatment week.

    - This means we will pre-specify a per-protocol analysis (restrict analysis to cows in arm 2 that follow the 4 week delay protocol) alongside intention-to-treat to separate the impact of contamination.

### Enrolment

- A cow enters **at her first SmartSight alert** and is randomized then.
  - This means randomization allocation will be run daily for cows not yet enrolled.
- Randomization is **blocked by lameness history (new / chronic) and lactation group (1 / 2 / 3+).**
  - Blocking balances the arms on the two covariates most likely to change the effect.
- **Each cow is enrolled once.** Her arm is a strategy for every alert she gets until the study ends, not just the first.
  - After her first alert cows will undergo a standard recheck protocol for hoof horn lesions and become eligible to be checked again based on alerts 28 days after her last recheck.
  - Cows with infectious lesions become eligible for re-alerting 28 days after her last trim unless she has strong decline.
  - Cows waiting for a trim in arm 1 and 2 will have a delay on alerts until trimming occurs.

**Cows that calve during the study who are already enrolled:**

- **She keeps her arm.** Alerts after calving are handled by the same protocol.
- **Milk (primary outcome) stays in the enrollment lactation.**
  - The time between enrollment and dry-off is less than the 90-day window ends will still contribute only those days to the milk outcome.
    - Milk after calving is not used.
- **Culling and recurrence follow the cow**, across the calving, to the study end.
- **Dry-off lesion is read at the enrolment lactation's dry-off.**
- A cow never enrolled who calves and is alerted in her new lactation can enrol then, at DIM 5 or later.
- Lactation group for the randomization block is set by lactation at the alert.

### Eligibility

**Each participating herd must have:**

- **Reliable** historical and current hoof trimming data entered into DairyComp
  - Need to allow proper randomization
  - Before the start of the study we will work with trim staff to ensure the data is complete and consistently coded.
  - Monthly checks will be done to ensure this remains consistent throughout.
- **Routine dry cow trimming.**
- Must not preventatively trim cows routinely more than 2x/lactation.
  - Herds that trim more often than this dilute the arm 1 v 3 contrast further.
- Trained trimming staff
- Daily milk weights
- Ability to have SmartSight installed.
- Ability and willingness to do a standardized recheck at around 28 days after a block has been placed on a cow.

**Cows**

**A minimum of 5 days in milk.** A cow alerted in her first 5 days after calving is excluded. She re-enters if alerted later.

- Fresh cows can walk abnormally for reasons that are not hoof lesions.
  - The median pilot cow was alerted at **DIM 150**. A DIM 5 floor would have excluded **11 of 849 cows (1.3%)**.
- This also allows her to get a baseline for milk production.

------------------------------------------------------------------------

## 3. What the design answers

+---------------+---------------+--------------------------------------+
|               | Comparison    | Answers                              |
+===============+===============+======================================+
| **Primary**   | Arm 1 v arm 3 | How much does acting on alerts gain? |
+---------------+---------------+--------------------------------------+
| **Secondary** | Arm 1 v arm 2 | Does acting *early* matter           |
|               |               |                                      |
|               |               | - prevention, cure and recurrence?   |
+---------------+---------------+--------------------------------------+

- **Arm 1 v 3 is how we will estimate the milk impact of the technology.**
  - Milk is the outcome the study is sized on.
  - Culling, cure and recurrence are estimated with the precision that milk production sample size gives.
  - It estimates whether acting on alerts pays. Proving it pays depends trimming costs and price of the technology and this study can provide estimates to inform this prize
- **Arm 1 v 2 is how we will tell whether acting early matters.**
  - Whether the no lesion arm-1 trims were prevention or not necessary.
  - Whether a lesion left four weeks (arm 2) cures and recurs the same as one treated within a week (arm 1).

### Why the trial needs three arms rather than two

- **An arm-1 trim that finds no lesion leave a question unanswered**
  - Either the camera was wrong (a unnecessary trim), or earlier trimming prevented the lesion (the system working).
  - One is a cost of the system, the other a benefit.
  - If more arm-2 cows show lesions compared to arm-1, the non lesion arm-1 trims were prevention.
    - From the pilot 54.9% of arm-1 trims are expected to find nothing, so this distinction decides whether most arm-1 trims count for or against the system.

------------------------------------------------------------------------

## 4. Outcomes

### Primary

**Daily milk, arm 1 versus arm 3**, from 14 days before the alert to 90 days after.

- Indexed to days since alert.
- 90 days to realistically get as many cows as possible.

### Secondary

**1. Cure at a standardized recheck for white line and sole ulcer lesions.**

- **Primary comparison: arm 1 versus arm 2.**

- It is the clinical question: **does a lesion left not treated for four weeks still heal as well?**

- Arm 3 cure rates will be reported too but should be **considered descriptive**

**2. Culling at 180 days, on every enrolled cow.**

- Measures on **all enrolled cows,** not only those found lame at trimming**.**

**3. Recurrence within 180 days** for cows in **arm 1 versus arm 2.**

- Recurrence is only measured in cows with a lesion and finding one depends on the arm.
  - Arms 1 and 2 are both trimmed by protocol and randomized accordingly
- **Arm 3 is reported, as descriptive**
  - Cows with lesion in this group are not randomly selected

### Descriptive

1.  **Lesion prevalence at the routine dry-off trim.**

    - Every cow is trimmed around dry-off whatever her arm, so this is the one lesion measure not driven by inspection rate.

    - **Descriptive, not an outcome, in a 14-month study.** Only 21% of cows reach dry-off inside 6 months of their alert, so the last cows enrolled mostly never get there.

      - That is about 358 cows per arm, enough to detect only an **8.1-point** difference using the pilot's baseline lesion occurrence.

    - **Extending the study to 12 months** after the last cow (20 months) would make it an outcome.

      - Twelve months of follow-up after the last enrollment brings \~ 68% of cows to dry-off - about 1,140 per arm - and detects a **4.7-point** difference. It adds about \$21,500.

2.  **Reproduction.**

    - In the pilot no evidence of difference was found so it was hard to determine an effect for sample size.

### Not considered as outcomes

- **Lesion severity.** Not standardizable across farms and trimmers.

------------------------------------------------------------------------

## 5. Sample size

**5,000 cows enrolled across six herds: 1,667 per arm, 833 per herd.**

**The study is built to estimate.** It measures the gain from acting on alerts - arm 1 against arm 3, the choice a farm makes - to within about **±0.50 kg/day**. What it would typically report:

| Gain from acting on alerts | Typical 95% interval | Chance the lower bound is at least 1.0 kg |
|---|---|---|
| 0.75 kg/day | 0.23 to 1.24 | 0% |
| **1.0 kg/day** | **0.47 to 1.48** | 3% |
| 1.25 kg/day | 0.72 to 1.73 | 16% |
| 1.5 kg/day | 0.93 to 1.94 | 42% |
| 1.75 kg/day | 1.21 to 2.22 | 76% |

- The interval is about ±0.50 kg/day whatever the gain; that is the precision 5,000 buys.
- **A 0.75 kg/day gain is detected with 81% power, 1.0 kg/day with 95%** (two-sided α = 0.05, analyzed as §6 specifies).
- A lower bound of 1.0 kg/day is only likely if the gain is about 1.75 kg/day or more. At a 1.0 kg gain, the lower bound is typically about 0.5 kg/day.
- **5,000 also powers the new-v-chronic difference** if the benefit sits in new cows (§6), and narrows every secondary interval.

It was sized by simulating the whole trial, and checked with a simple calculation (both below).

- **The variance is the pilot's own, over the full 90 days.** A cow's 90-day mean varies by 42 kg² after adjusting for her baseline, against 98 kg² without it.

  - It rests on the 114 pilot cows alerted early enough to have 90 days of milk. So the study is planned on the **90th percentile** of a bootstrap of that estimate (52 kg²), not the point.
  - Without the baseline covariate the variance is 2.3 times larger, and the study would need about 2.3 times as many cows.

- **The gains are design targets, not pilot estimates.**

  - **Arm 3 is farm practice, not untreated.** The farm trims 65% of arm-3 cows by day 90, so the study measures what acting on alerts adds to what the farm already does.
  - **1.0 kg is the smallest gain worth detecting, not break-even.** At current pricing milk alone does not pay at 1.0 kg; the study estimates the total return with its interval.
  - **The pilot does not measure it.** On the outcome this study uses (kg, adjusted for each cow's baseline), the pilot's TX–Control difference at days 25–30 was **+0.08 kg** (95% CI −1.0 to +1.2). That neither supports 1.0 kg nor rules it out.
  - The pilot's effect sits in new cows, not chronic ones (see §6). A study that averages over both is sized on the average.

- **The targets assume farm practice in arm 3 trims like the pilot's.** Routine trimming reaching arm-3 cows depends on DIM at the alert: in the pilot, 5% of cows alerted at DIM 0–60 were routine-trimmed within 60 days, 55% at DIM 61–120, just before the herd's routine window.

  - Herds whose routine trimming reaches more arm-3 cows shrink the gain. At twice the pilot's rate, power for a 1.0 kg gain is 84%; at half the rate, 99%.

- **Late-lactation cows stay in.** 38% of alerted cows are past DIM 200, and three in four of them dry off inside 90 days. They contribute milk until they do, so 97% of enrolled cows add some milk and two in three add the full 13 weeks. Dropping them instead would lose over a third of the study.

- **The result is the milk difference in the enrolled herds.** Randomization is *within* herd, so herd is a block, not a cluster. Whether the gain differs between herds is checked and each herd's estimate reported (§6).

### How the sample size was simulated

A simulation of the whole trial, cow by cow, run 1,000 times at each size. Each simulated trial:

- **Draws cows from the pilot**: their baseline milk, DIM at the alert, lactation and history.
- **Lets each cow leave milk** when she dries off (from this herd's own lactation lengths) or is culled (the pilot's rate by DIM). She contributes the weeks she milks, up to 90 days.
- **Trims arm 3 as the pilot's Control arm was trimmed**, by staff or routine round, at the pilot's rates for her DIM. Arm 1 is trimmed as the pilot's TX arm was; arm 2 four weeks later unless the farm gets there first.
- **Gives each cow a milk gain that depends on when she is trimmed.**
- **Spreads the cows over six herds** that differ in routine trimming and in the size of the gain.
- **Analyzes each trial as §6 specifies** and counts how often it finds the gain.

It reproduces the pilot where it can be checked:

- Farm trimming by DIM at the alert: 5.3 / 52.2 / 34.9 / 19.5% of arm-3 cows routine-trimmed within 60 days, against the pilot's 5.1 / 54.7 / 35.0 / 19.5%.
- Cows still milking at day 85: 63%, against 59%. Slightly optimistic.
- With no effect, it calls one 5.4% of the time, as a 5% test should.

### Checked with a simple calculation

The same answer from a textbook formula, with none of the simulation's machinery:

- **95% interval**: ±0.50 kg/day. The simulation gives the same.
- **Power for a 1.0 kg gain: 98%.** The simulation gives 95%. It is lower because the herds' own gains vary.

**One choice moves it:** whether a dry-off trim counts as treatment in arm 3. Both calculations leave it out, because the cow leaves the milk outcome days later. Counting it would lower power to 92%.

### What the result is sensitive to

Power for a 1.0 kg/day gain at 5,000, moving one input at a time (simple formula):

| Input | Planned | Changed to | Power |
|---|---|---|---|
| *As planned* | | | **98%** |
| Gain from acting on alerts | 1.0 kg | 0.75 kg | 84% |
| Farm trimming in arm 3 | pilot's | gain 20% smaller | 88% |
| | | gain 20% larger | 100% |
| Variance of a cow's 90-day mean | 51.9 kg² | 42.4 (the pilot point estimate) | 99% |
| | | 60 kg² | 95% |
| Cows giving no milk | 3% | 15% | 96% |

- **The size of the gain and the farm's own trimming in arm 3 matter most.**
- **Farm trimming in arm 3 is the one the design can still influence**, through which herds are chosen and their routine-trimming rule (§2). Herds whose routine round reaches fewer alerted cows raise power.
- **The variance and the loss of cows matter less.** The baseline covariate has already done most of what can be done there.

### How many herds

Power at 5,000 enrolled for a 1.0 kg/day gain, by the number of herds and how much the gain differs between them (simulation):

| Between-herd SD of the gain | 4 herds | **6 herds** | 8 herds | 10 herds |
|---|---|---|---|---|
| 0.25 kg | 95% | **96%** | 94% | 97% |
| 0.50 kg | 91% | **94%** | 93% | 95% |
| 0.75 kg | 87% | **90%** | 90% | 92% |

- **The number of herds barely changes power.** Power is set by the number of cows.
- **Herds decide how widely the result applies.** Six herds in three regions cover more housing, flooring and trimming practice than four.
- **Four herds is the minimum.** Losing one herd from four removes a quarter of the study and one region's second herd.
- **Eight herds is insurance** against losing a herd and broadens the result further. It costs about \$55,000 more (§9).

### What each herd supplies

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

| | |
|---|---|
| Enrolment | **up to 8 months**, in parallel across the six herds (3.2-6.4 months expected at 3,000 cows) |
| Follow-up | **every cow to one study end date**, at least 6 months after the last enrolment |
| **Total** | **14 months** |

- **Following each cow for 365 days would set the duration at 20 months or more.** Following all cows to one end date does not lose that information: early cows still reach a year, and time-to-event analysis uses every cow for as long as she is watched.
- What the last cow's 6 months must cover: milk (90 days), cure (60-day recheck), and culling and recurrence at 180 days.
- Recurrence needs a lesion first, so the last cows enrolled may fall a few weeks short of 180 days. They are censored, not dropped.

### What this design detects

Smallest difference detectable at 80% power at 5,000 enrolled. Arm 1 v 3 unless noted:

| Outcome | Cows per arm | Smallest detectable difference |
|---|---|---|
| **Milk** (primary) | 1,667 | **0.75 kg/day** gain (81% power); 1.0 kg/day at 95% |
| Culling at 180 days, all enrolled | 1,667 | **3.4 points** on 16.0% (±2.5) |
| Cure, white line and sole ulcer *(arm 1 v 2)* | 290 assessed | **11.5 points** on 49.3% |
| Recurrence at 180 days *(arm 1 v 2)* | 583 with a first lesion | **7.7 points** on 36.1% |
| Lesion at dry-off *(descriptive)* | 358 reach dry-off | **8.1 points** on 22.4% |

- **Cure is targeted at +15 points**, detected with 96% power.
- **Dry-off is descriptive.** The count uses only the 21% who reach dry-off inside six months; early-enrolled cows add more. With 12 months after the last cow (a 20-month study) 68% reach it and it becomes an outcome: 1,140 per arm, 4.7 points (§4).

### What 4,000 would lose

A 4,000-cow version (1,333 per arm, 667 per herd) runs **12 months** (up to 6 months of enrolment) and costs **\$220,250, about \$43,000 less** (§9).

| | 5,000 | 4,000 |
|---|---|---|
| Milk: 95% interval | ±0.50 kg/day | ±0.56 kg/day |
| Milk: power for a 0.75 kg/day gain | 81% | 72% |
| **New v chronic difference**, benefit only in new cows | **85% power** (±1.03 kg) | **75%** (±1.15 kg) |
| Culling at 180 days | 3.4 points (±2.5) | 3.8 points (±2.8) |
| Cure *(arm 1 v 2)* | 11.5 points (290 assessed) | 12.8 points (232) |
| Recurrence *(arm 1 v 2)* | 7.7 points (583) | 8.5 points (467) |
| Lesion at dry-off | 8.1 points (358) | 9.0 points (287) |

- **The main loss is the new-v-chronic question.** At 5,000 the study can show whether the benefit sits in new cows; at 4,000 it can only estimate it.
- **Milk precision changes little.** The interval widens by about 0.06 kg/day.
- **Every secondary outcome loses about a tenth of its precision.**
- Enrolment is easier: 667 cows take a 3,000-cow herd 2.6-5.1 months at 0.010-0.020 alerts per cow per week.

### The limitation, stated up front

- **Break-even needs 0.25-0.6 points less culling across all enrolled cows.** That assumes a \$0.65–0.80/cow/month subscription, \$18 a trim and \$1,650 net cost of a cull (replacement less cull value).
- **The study's interval on culling is ±2.5 points.** It cannot tell break-even from zero.
  - No feasible study can: detecting it would take 170,000 to a million cows.
- **The same holds for milk.** If the gain is 1.0 kg/day, the lowest value the study can vouch for is typically about 0.5 kg/day.
- **So this study will *estimate* whether the system pays. It will not *prove* it.** An honest estimate is what a purchasing decision needs. It is not a hypothesis test, and this proposal does not claim one.

------------------------------------------------------------------------

## 6. Analysis

**Milk.** Mixed linear model on weekly averages, arm 1 v 3.

- **Fixed effects:** arm, **the cow's 7-day pre-alert milk**, DIM spline, lactation group, lesion history, breed, herd.
  - Herd is fixed because randomization is within herd and herds differ in milk level.
- **Random effect:** cow intercept. Each cow contributes up to 13 weekly averages, and her weeks are correlated.
- Cows that dry off or leave contribute the weeks they milk.
- **The result is the milk difference in the enrolled herds.**
- **Whether the effect differs by herd** is checked with an `arm × herd` term and each herd's estimate is reported. It is not part of the primary test.
- The `arm × history` interaction is estimated and reported - see below.

**Cure.** Logistic, same covariates, herd fixed.

**Lesion at dry-off.** Reported by arm with its interval, from the same model. Not tested (§4).

### The chronicity interaction

- Chronic cows do worse. Recurrence rises 34% → 48% → 52% across parity; cure falls from 51.9% in new cows to 45.0% in chronic ones.
  - Those are **main effects**, and adjusting for them is free.
- **We expect the treatment benefit to be larger in new cows, and the pilot points that way.** Pilot TX–Control milk, days 1–30, baseline-adjusted:

|                            | TX effect   | 95% CI           |
|----------------------------|-------------|------------------|
| New cows (61% of enrolled) | +0.39 kg    | −0.64 to +1.42   |
| Chronic cows               | −1.45 kg    | −2.75 to −0.15   |
| **Difference**             | **1.84 kg** | **0.18 to 3.50** |

- History was recorded before randomization, so each row is a randomized comparison. But it is one herd, a subgroup looked at after the fact, and a wide interval. Planning on the point estimate would be optimistic.

**What 5,000 enrolled gives** (simulation, 6 herds, pilot's 61% new):

| Estimate               | 95% interval   |
|------------------------|----------------|
| Overall gain           | ±0.50 kg       |
| Gain in new cows       | about ±0.64 kg |
| Gain in chronic cows   | about ±0.81 kg |
| New minus chronic      | about ±1.03 kg |

*The subgroup intervals are scaled from the overall one by each group's share of cows.*

- **If the benefit sits in new cows** (none in chronic, the same 1.0 kg/day gain overall), the study finds it in new cows alone with near-100% power, and **the new-v-chronic difference with 85%.**
  - That is the best case: no benefit at all in chronic cows. A smaller difference has less power.
- **If the gain is equal in both**, power in new cows alone is 85%.
- At 4,000 the difference would have 75% power: estimated, not shown (§5).

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

- **5,000 enrolled, six herds, 14 months** (up to 8 months of enrolment, 6 of follow-up after the last cow). Milk adjusted for each cow's baseline, herd and arm as fixed effects (§5, §6). A 4,000-cow, 12-month version and what it loses are in §5.
- **Every cow followed to one study end**, at least 6 months after the last enrolment. Culling and recurrence at 180 days; 365 days reported where cows reach it (§2, §4).
- **Culling compared on all enrolled cows**, not lame cows only (§4).
- **Randomization blocked on chronicity and lactation group.** At 5,000 the new-v-chronic difference has 85% power if the benefit sits in new cows (§6).
- **Six herds** across three regions, two each. Four is the stated minimum. Eight is preferred but needs about \$55,000 more (§5, §9).
- **Lesion at dry-off is descriptive.** It becomes an outcome with 12 months of follow-up after the last cow (§4).
- **Cure targeted at +15 points.** §5 states what the design detects on every outcome.
- **Cure and recurrence compared primarily on arms 1 v 2**, where both are protocol-trimmed. Arm 3 is reported with its caveat and its detection route recorded.
- **Alert rules and DairyComp commands frozen for the study** (§2, §7).

------------------------------------------------------------------------

## 9. Budget

**Total: \$263,150 over 14 months** - six herds, 5,000 enrolled.

| | |
|---|---|
| Personnel - farm visits, project management, analysis | \$217,500 |
| Travel | \$30,530 |
| Data storage | \$15,120 |
| **Total** | **\$263,150** |

- Farm visits run through enrolment only (up to 8 months). Follow-up is passive data collection.

**Options:**

| | Changes the budget by | Total |
|---|---|---|
| **Eight herds** instead of six - mostly monthly farm visits, plus travel to the extra herds | about +\$55,000 | about \$318,000 |
| **20 months** instead of 14 (makes dry-off lesion an outcome, §4) - project management and data storage | about +\$21,500 | about \$285,000 |
| **4,000 enrolled, 12 months** instead (what it loses: §5) | about −\$43,000 | \$220,250 |

**Not included - to settle with Nedap:**

- **Camera subscription:** \$164,000-202,000 for 18,000 cows over 14 months at \$0.65-0.80 per cow per month. That is 62-77% of the study budget again, so it has to be settled before the total means anything.
- **Extra trimming in arms 1 and 2:** about \$24,000 over the study, at \$18 per trim (first alerts only; later alerts add more).

------------------------------------------------------------------------

## Appendix: pilot figures used

+----------------------------------------------------------------------------------------+------------------------------------------+
| Quantity                                                                               | Value                                    |
+========================================================================================+==========================================+
| Variance of a cow's 90-day milk mean, baseline-adjusted                                | 42 kg² (planned at 52, 90th percentile)  |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Same, without the baseline                                                             | 98 kg²                                   |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Baseline to 90-day milk correlation                                                    | 0.89                                     |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Enrolled per week per cow in milk, pilot                                               | 0.024                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| TX–Control milk, days 25–30, baseline-adjusted                                         | +0.08 kg/day (SE 0.57)                   |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Same, TX effect in new v chronic cows, days 1–30                                       | +0.39 v −1.45 kg/day                     |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Control cows routine-trimmed within 60 days of the alert (followed 60+ days)           | 28.6%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Alerted cows past DIM 200                                                              | 38%                                      |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Still milking 85 days after the alert (n = 116)                                        | 59%; 24% of those past DIM 200           |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Culled within 90 days of the alert, DIM 0–60 / 61+                                     | 30% / 8.7%                               |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Completed lactation length, median                                                     | 317–320 days                             |
+----------------------------------------------------------------------------------------+------------------------------------------+
| TX cows trimmed by day 7 / by day 90 (Kaplan-Meier)                                    | 63% / 98%                                |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Arm-3 cows routine-trimmed first within 60 days, by DIM 0–60 / 61–120 / 121–200 / 200+ | 5 / 55 / 35 / 20%                        |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Alerted cows with a lesion found                                                       | 35.0%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Alerted cows with white line or sole ulcer                                             | 18.3%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Cure at 60 days, WLD/SU                                                                | 49.3%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Recurrence within 180 days, cow-level                                                  | 36.1%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Culling within 180 days of a camera flag, farm practice                                | 16.0%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Lesion found at a dry-off trim                                                         | 22.4%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| New-case lesion incidence                                                              | 27.1 per 100 cow-years                   |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Empty-trim rate, trimmed arm                                                           | 54.9%                                    |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Culling gap at 180 / 365 days, from calving                                            | 6.8 / 7.3 points                         |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Alerts per week, pilot farm                                                            | 69                                       |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Cows alerted per lactation                                                             | 62%                                      |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Lesion cows flagged live, no alert                                                     | 243                                      |
+----------------------------------------------------------------------------------------+------------------------------------------+
| Of those, genuine integration losses                                                   | 12                                       |
+----------------------------------------------------------------------------------------+------------------------------------------+
| LOW flags after go-live / `Low` alerts                                                 | 13,199 / 81                              |
+----------------------------------------------------------------------------------------+------------------------------------------+
| First-lactation cows absent from SmartSight, after 2026-06-24                          | 160                                      |
+----------------------------------------------------------------------------------------+------------------------------------------+
