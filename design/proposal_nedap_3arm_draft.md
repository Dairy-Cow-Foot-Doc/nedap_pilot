# Does it pay to use NEDAP SmartSight?

## A proposal for a three-arm randomised trial

------------------------------------------------------------------------

## 1. The question and objective

**Determine if acting on SmartSight alerts leave a dairy better off, and by enough to pay for the system?**

- The pilot study answered several important questions and provided insights into things we need to consider in a study that looks at if using SmartSight is worth it.

------------------------------------------------------------------------

## 2. Proposed design

Randomised controlled trial,

- **3 arms**

- **12 months in total.** Up to 6 months of enrollment, then every cow is followed to one study end date 12 months from enrollement

  - The last cow enrolled gets at least 6 months. That covers milk (90 days), cure (60-day recheck), and culling and recurrence at 180 days.

  - An 18 month study would allow answering more questions but increases cost.

- **6 herds of 2,000–5,000 cows** across three regions

  - Two each in New York, Midwest and the West Coast as I have DVM collaborators in those regions and I know you are active in these regions.

  - **Four herds is a workable minimum**

    - The precision cost is under Eligibility below; the calendar-time cost is in Section 5.

  - **Eight herds is our preference, but needs more budget** - about \$45,000 more (§9).

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

Similar to the pilot we would have alerts go into DairComp and add cows to the trim list based on a priori randomization.

Arm 2 is needed to determine whether the trims that find no lesion in Arm 1 would have developed into treatable lesions — that is, whether Arm 1 is actually preventing them.

**Arm 3 is regular farm practice, not an untreated arm.**

- In the pilot the equivalent group was trimmed 49.8% of the time, mostly by routine trimming.
- Herds with **little mid-lactation trimming** would add to the contrast between the arms.
  - We can determine if we want this to be an eligibility criterion below.
  - It also moves arm 3 away from the pilot's 49.8%, which the contamination and dilution figures assume.

**Arm 2 is contaminated by design.**

- Based on the pilot Farm detection is heavily front-loaded

  - in the pilot 66% of farm caught cows in the TX group were inside four weeks, and week 1 alone is 31%

    - If this persists 1/3 of arm 2 will be treated before its protocol week.

    - This means we will pre-specify a per-protocol analysis (restrict analysis to cows in ARM 2 that follow the 4 week delay protocol) alongside intention-to-treat to separate the impact of contamination.

### Enrolment

- A cow enters **at her first SmartSight alert** and is randomized then.
  - This means randomization allocation will be run daily to for unenrolled cows
- Randomization is **blocked by lameness history (new / chronic) and lactation group (1 / 2 / 3+).**
  - Blocking balances the arms on the two covariates most likely to change the effect.
- **Each cow is enrolled once.** Her arm is a strategy for every alert she gets until the study ends, not just the first.
  - After her first alert cows will undergo a standard recheck protocol for hoof horn lesions and become eligible to be checked again based on alerts 28 days after her recheck.
  - Cows with infectious lesions become eligible for re-alerting 28 days after her last trim unless she has strong decline.
  - Cows waiting for a trim in ARM 1 and 2 will have a delay on alerts until trimming occurs

**Cows that calve during the study:**

- **She keeps her arm.** Alerts after calving are handled by the same protocol.
- **Milk (primary outcome) stays in the enrollment lactation.** The 90-day window ends early if she dries off - that is attrition, already in the ×1.28.
  - Milk after calving is not used.
- **Culling and recurrence follow the cow**, across the calving, to the study end.
- **Dry-off lesion is read at the enrollment lactation's dry-off.**
- A cow never enrolled who calves and is alerted in her new lactation can enroll then, at DIM 5 or later.
- Lactation group for the randomization block is set by lactayion at the alert.

### Eligibility

**Herds**

Herds are monitored by collaborating investigators, two in each region.

**The regional spread is a reason for more herds, not fewer regions.**

- Housing, flooring, climate and trimming practice differ by region.
- We choose 6 herds to balance cost and increase generalizability.

Cows enrolled for 80% power on the primary milk outcome, analyzed with an arm-by-herd random slope:

+-------------------------------+---------------+-------------+-----------+-----------+
| Between-herd SD of the effect | 4 herds       | **6 herds** | 8 herds   | 10 herds  |
+===============================+===============+=============+===========+===========+
| 0.25 kg *(planning value)*    | 4,300         | **4,000**   | 3,800     | 3,700     |
+-------------------------------+---------------+-------------+-----------+-----------+
| 0.50 kg                       | 7,100         | **5,200**   | 4,600     | 4,300     |
+-------------------------------+---------------+-------------+-----------+-----------+
| 0.75 kg                       | *over 20,000* | **13,300**  | 7,400     | 5,900     |
+-------------------------------+---------------+-------------+-----------+-----------+

- **The sample size is planned at 0.25 kg with six herds: 4,000 enrolled.**
- The rest of the table is the sensitivity. If herds differ more than planned, more herds is the cheap fix, not more cows.
- **Eight herds is insurance, not a saving.** At the planning value it saves only 200 cows. Its value is in the lower rows: if herds differ by 0.5-0.75 kg, eight herds holds the study near 4,600-7,400 where six would need 5,200-13,300.
  - It costs about \$45,000 more (§9), which is why six is the plan and eight the preference.

**Each participating herd must have:**

- **Reliable** hoof trimming data
  - Before the start of the study we will work with trim staff to ensure the data is complete and consistently coded.
  - Monthly checks will be done to ensure this remains consistent throughout.
- **Routine dry cow trimming.**
- Routine mid lactation hoof trimming is ok but herds should not trim cows routinely more than 2x/lactation.
  - The pilot study herd trimmed cows in strategically in mid lactation and Control arm did not get washed out with those hoof trimmings.
- Trained trimming staff; daily milk weights; ability to have SmartSight installed.

**Cows**

**A minimum of 5 days in milk.** A cow alerted in her first days after calving is excluded. She re-enters if alerted later.

- Fresh cows can walk abnormally for reasons that are not hoof lesions.
  - The median pilot cow was alerted at **DIM 150**. A DIM 5 floor would have excluded **11 of 849 cows (1.3%)**.

------------------------------------------------------------------------

## 3. What the design answers

+---------------+---------------+----------------------------------------------------------------------------+
|               | Comparison    | Answers                                                                    |
+===============+===============+============================================================================+
| **Primary**   | Arm 1 v arm 3 | Does acting on alerts pay?                                                 |
+---------------+---------------+----------------------------------------------------------------------------+
| **Secondary** | Arm 1 v arm 2 | Does acting *quickly* pay — and is the responsive protocol worth its cost? |
+---------------+---------------+----------------------------------------------------------------------------+

- **Arm 1 v 3 carries the efficacy claim.** It is also the only milk contrast powerable at a realistic size, and the only one that holds whatever the measurement window (§4).
- **Arm 1 v 2 is the question a farm actually faces** - not whether to act, but how fast.
  - A one-week response costs more labour and scheduling than a four-week one. This comparison says whether that is worth buying.

### Why the trial needs three arms rather than two

- **An arm-1 trim that finds no lesion cannot be read on its own.**
  - Either the camera was wrong (a wasted trim), or early trimming prevented the lesion (the system working).
  - The two have opposite economic signs.
- **Arm 2 separates them.** If arm-2 cows show lesions at four weeks where arm-1 cows had none at one week, the empty arm-1 trims were prevention.
- 54.9% of arm-1 trims are expected to find nothing. **This one distinction moves the economic verdict by roughly the whole extra-trimming cost.**

### Economics

Acting on alerts means **trimming more cows.** In the pilot the trimmed arm was trimmed 90.4% of the time against Control's 49.8%, and 54.9% of those trims found no lesion.

The study measures what the system costs and what it returns - milk, culling, cure and extra trimming - and reports the **total dollars** for each arm. The pilot does not settle the answer in advance, and this proposal does not try to.

#### Economic assumptions

+------------------------+-----------------------+---------------+-------------------------------+
| Input                  | Value used            | Range         | Source                        |
+========================+=======================+===============+===============================+
| Milk price             | \$0.37/kg             |               | Break-even calculator default |
+------------------------+-----------------------+---------------+-------------------------------+
| Feed cost              | \$0.29/kg DM          |               | Calculator default            |
+------------------------+-----------------------+---------------+-------------------------------+
| Feed conversion        | 2.5 kg milk per kg DM |               | Calculator default            |
+------------------------+-----------------------+---------------+-------------------------------+
| **IOFC**               | **\$0.254/kg**        |               | Derived from the three above  |
+------------------------+-----------------------+---------------+-------------------------------+
| Cost per hoof trim     | **\$18**              | \$15–20       | Current typical               |
+------------------------+-----------------------+---------------+-------------------------------+
| Replacement animal     | **\$3,000**           | \$2,500–3,500 | Current market                |
+------------------------+-----------------------+---------------+-------------------------------+
| Cull cow value         | **\$1,350**           | \$1,200–1,500 | Current market                |
+------------------------+-----------------------+---------------+-------------------------------+
| **Net cost of a cull** | **\$1,650**           | \$1,000–2,300 | Replacement less cull value   |
+------------------------+-----------------------+---------------+-------------------------------+
| Camera subscription    | \$0.65–0.80/cow/month |               | Reported estimates            |
+------------------------+-----------------------+---------------+-------------------------------+

**None of these affect the sample size.** The study is powered on milk (§5). The economic inputs only convert measured effects into dollars, so a reader can substitute their own without changing the study's precision.

------------------------------------------------------------------------

## 4. Outcomes

### Primary

**Daily milk, arm 1 versus arm 3**, from 14 days before the alert to 90 days after.

- Indexed to days since alert.
- **Each cow's own 7-day pre-alert average enters as a covariate.** This is what makes the study affordable.
  - In the pilot, a cow's baseline predicts her next 90 days closely (r = 0.89).
  - Adjusting for it cuts the variance of a cow's 90-day mean from 98 to 42 kg², so the study needs about 4,000 cows rather than 7,500.
  - As a covariate, not as change-from-baseline or % of baseline. A covariate uses only as much of the baseline as actually predicts.
- The pre-alert slope also shows how much milk was already lost before the camera fired.
- *Why arm 1 v 3 only:* its contrast is the largest, and it barely moves with the length of the window. Arm 1 v 2 on milk is not powerable at this size - arm-2 contamination and catch-up shrink it to a fraction of arm 1 v 3.

### Secondary

**1. Cure at a standardised recheck — white line and sole ulcer. Primary comparison: arm 1 versus arm 2.**

Cure is read from the follow-up trim coming back trim-only. This herd has no hoof recheck event (`RECK` is reproductive), so the study must create one at a fixed interval after treatment.

- **Sized on white line and sole ulcer.** The baseline is well estimated (49.3% cure at 60 days) and rechecks are already standard at 60.2% coverage.
- **Foot rot excluded.** Its 15.5% cure rate is a recording artifact: 60% of its "non-cures" fall within 7 days and 46% are re-coded foot rot.
- **A 14-day minimum gap applies to foot rot only.** White line and sole ulcer show no early clustering (10–11% within a week, medians 29–35 days), so their early returns are real failures.
- **DD collected opportunistically.** A standardised DD recheck is not feasible on farm.

**Why arms 1 and 2 carry cure.**

- Both are trimmed by protocol, so cure is measured on the same kind of cow in each.
- It is the clinical question: **does a lesion left four weeks still heal as well?**

**Arm 3 is reported too, with its caveat.**

- In arm 3 only cows the farm catches are trimmed, so its cure is on **farm-detected lesions**, which may be more severe.
- The pilot cannot say whether that matters: Control cure was 14.7% (n = 34) staff-detected against 18.2% (n = 11) routine-detected. Too few to tell.
- **Record how every arm-3 cow came to be trimmed** - staff `CHKLAME` or routine round - and report cure by route.
- Present arm 3's cure as **descriptive, not an unbiased treatment contrast.**

**Dilution on the 1 v 2 comparison.** About a third of arm 2 is treated early.

- The design detects a **12.8-point** observed difference.
- Among cows who actually waited four weeks, that is about a **19-point** true difference.
- Report both, alongside the per-protocol analysis.

**2. Culling at 180 days, on every enrolled cow.**

- **All enrolled cows, not only those found lame.** Whether a lesion is *found* depends on the arm - the ascertainment problem. Only the whole enrolled group is a randomised comparison.
- **Baseline: 16.0% culled within 180 days** of a camera flag, for cows left to farm practice (flagged before the pilot went live, n = 1,505).
- **Why 180 days, not 365.** The lameness–culling gap has built nearly all the way by six months:

| Window       | No early lesion | Early lesion | Gap      |
|--------------|-----------------|--------------|----------|
| 90 days      | 28.1%           | 33.0%        | +4.9     |
| **180 days** | **34.0%**       | **40.8%**    | **+6.8** |
| 365 days     | 45.0%           | 52.3%        | +7.3     |

- 93% of the 365-day gap is there at 180 days. (These rates run from calving over a whole lactation, which is why they are higher than 16%.)
- 365-day culling is reported for cows enrolled early enough to reach it.
- The pilot's own three-month figure had the *wrong sign* - lame cows culled less. That is what a window shorter than the process produces.

**3. Recurrence within 180 days** of a first lesion, counting only lesions 14+ days later, and following the cow across a calving. Baseline **36.1%**. **Primary comparison: arm 1 versus arm 2.**

- **Why arms 1 and 2, the same reason as cure.** Recurrence is only measured in cows with a lesion found first, and finding one depends on the arm.
  - Arms 1 and 2 are both trimmed by protocol, so the first lesion is found in the same kind of cow in each.
  - Arm 3's first lesions are only those the farm caught, likely later and more severe. Comparing arm 1 with arm 3 would compare different cows, not different treatments.
- **Arm 3 is reported, as descriptive.**
- **Dilution, as for cure.** About a third of arm 2 is treated early. Report intention-to-treat and per-protocol.
- **Timing differs slightly by arm.** A later alert is trimmed within a week in arm 1 and at four weeks in arm 2, so an arm-2 recurrence can be found later. Analyse time to recurrence, not a 180-day yes/no alone.

### Descriptive

**Lesion prevalence at the routine dry-off trim.**

Every cow is trimmed around dry-off whatever her arm, so this is the one lesion measure not driven by inspection rate. Coverage was **88.6% in Control against 92.7% in TX.**

- **Descriptive, not an outcome, in a 12-month study.** Only 21% of cows reach dry-off inside 6 months of their alert, so the last cows enrolled mostly never get there.
  - At 4,000 enrolled that is about 287 cows per arm, enough to detect only a **9.0-point** difference on a 22.4% baseline.
- **Extending the study to 18 months would make it an outcome.** Twelve months of follow-up after the last enrolment brings 68% of cows to dry-off - about 906 per arm - and detects **5.2 points**. It adds about \$21,500 (§9).
- **Demoting it does not reopen the ascertainment problem.** The primary outcome (milk) and culling do not depend on a cow being looked at.
- **It is a window, not a day.** Trims cluster 21 to 7 days *before* dry-off. ±7 days catches only 9.6% of them; −45 to +7 catches about 90%.
- **Baseline: a lesion is found at 22.4% of dry-off trims.**
- **Only cows with at least 90 days from alert to dry-off, and dry-off before the study ends.** This selects on DIM at alert, so report DIM for kept and dropped cows.

### Not outcomes

- **Reproduction.** Nothing in the herd's records: median days to first service 77 v 78, services 1.93 v 1.94. No effect to power against.
- **Lesion severity.** Not standardisable across farms and trimmers.
- **Detection sensitivity.** Not estimable from an alert-triggered cohort at any size.

------------------------------------------------------------------------

## 5. Sample size

**Target: 4,000 cows enrolled across three arms, six herds.**

Powered on the primary milk contrast, arm 1 v 3, 1.0 kg/day, 80% power, two-sided α = 0.05.

+----------------------------------------------------------------------------+---------------------+
| Step                                                                       | Cows                |
+============================================================================+=====================+
| Per arm, with each cow's baseline as a covariate                           | 815                 |
+----------------------------------------------------------------------------+---------------------+
| × 3 arms                                                                   | 2,445               |
+----------------------------------------------------------------------------+---------------------+
| × 1.28 attrition                                                           | 3,130               |
+----------------------------------------------------------------------------+---------------------+
| **With the arm-by-herd random slope (between-herd SD 0.25 kg, six herds)** | **4,000**           |
+----------------------------------------------------------------------------+---------------------+

- **The variance is the pilot's own, over the full 90 days.** A cow's 90-day mean varies by 42 kg² after adjusting for her baseline, against 98 kg² without it.
  - It rests on the 114 pilot cows alerted early enough to have 90 days of milk. So the study is planned on the **90th percentile** of a bootstrap of that estimate (52 kg²), not the point.
  - Without the baseline covariate the same design needs 7,500.
- **1.0 kg/day is the design target, not a pilot estimate.**
  - The three-arm simulation gives a 1.01 kg observed contrast for a 1.5 kg true effect, with arm 3 trimmed by farm practice at the pilot's rate.
  - **The pilot does not measure it.** On the outcome this study uses (kg, adjusted for each cow's baseline), the pilot's TX–Control difference at days 25–30 was **+0.08 kg** (95% CI −1.0 to +1.2). That neither supports 1.0 kg nor rules it out.
  - An earlier figure of 1.05 kg came from milk as a percentage of baseline (97.9% v 95.4%). TX cows started from a lower baseline (42.1 v 42.5 kg overall, 39.5 v 41.8 kg in new cows), and a percentage of a lower baseline flatters the same milk. That is why the study adjusts for baseline instead.
  - The pilot's effect sits in new cows, not chronic ones (see §6). A study that averages over both is sized on the average.
- **The target assumes farm practice in arm 3 dilutes like the pilot's.** In the pilot, 28.6% of Control cows were routine-trimmed within 60 days of the alert. It depends on DIM at the alert: 2.5% for cows alerted at DIM 0–60, 59.5% at DIM 61–120, just before the herd's routine window.
  - Herds whose routine schedule reaches more cows than this dilute the contrast more, and need more cows: roughly 4,500 at 45%, 6,400 at 60%.
- **Attrition is ×1.28**, mostly drying off (15.8% by day 90) rather than culling (6.2%).
- **The random slope costs cows, and it is not optional.** Without it the analysis cannot see herds differing in the effect, and calls a real effect when there is none 6-9% of the time instead of 5%.
  - It is not a cluster design effect. Randomisation is *within* herd, so herd is a block.

### What each herd supplies

At 4,000 enrolled: **667 alerted cows per herd** across six, or 1,000 across four.

**Plan for fewer alerts than the pilot.** The pilot farm enrolled 0.024 alerted cows per week for every cow in milk (68 a week from about 2,800). It is likely a high-alert herd, so other herds are planned at 0.010-0.020.

Months to enrol 667 cows:

| Herd size  | 0.020 per cow per week | 0.015 | **0.010** |
|------------|------------------------|-------|-----------|
| 2,000 cows | 3.8                    | 5.1   | 7.7       |
| 3,000 cows | 2.6                    | 3.4   | **5.1**   |
| 5,000 cows | 1.5                    | 2.1   | 3.1       |

- **Six months of enrolment covers a 3,000-cow herd at under half the pilot's rate.**
- A 2,000-cow herd at a low rate does not finish in six months. Take more cows from the bigger herds instead - randomisation is within herd, so herds need not enrol equal numbers.
- Four herds would need 1,000 each: 7.7 months for a 3,000-cow herd at 0.010.

### Timeline

+------------------+----------------------------------------------------------------------------------------------+
|                  |                                                                                              |
+==================+==============================================================================================+
| Enrolment        | **up to 6 months**, in parallel across the six herds (2.6-5.1 months expected at 3,000 cows) |
+------------------+----------------------------------------------------------------------------------------------+
| Follow-up        | **every cow to one study end date**, at least 6 months after the last enrolment              |
+------------------+----------------------------------------------------------------------------------------------+
| **Total**        | **12 months**                                                                                |
+------------------+----------------------------------------------------------------------------------------------+

- **Following each cow for 365 days would have set the duration at 18-21 months.** Following all cows to one end date does not lose that information: early cows still reach a year, and time-to-event analysis uses every cow for as long as she is watched.
- What the last cow's 6 months must cover: milk (90 days), cure (60-day recheck), and culling and recurrence at 180 days.
- Recurrence needs a lesion first, so the last cows enrolled may fall a few weeks short of 180 days. They are censored, not dropped.

### What this design detects

Smallest difference detectable at 80% power at 4,000 enrolled (1,333 per arm). Arm 1 v 3 unless noted:

+-----------------------------------------------+-------------------------+--------------------------------------------+
| Outcome                                       | Cows per arm            | **Smallest detectable difference**         |
+===============================================+=========================+============================================+
| **Milk** (primary)                            | 1,333                   | **1.00 kg/day** observed contrast          |
+-----------------------------------------------+-------------------------+--------------------------------------------+
| Culling at 180 days, all enrolled             | 1,333                   | **3.8 points** on 16.0%                    |
+-----------------------------------------------+-------------------------+--------------------------------------------+
| Cure, white line and sole ulcer *(arm 1 v 2)* | 232 assessed            | **12.8 points** on 49.3%                   |
+-----------------------------------------------+-------------------------+--------------------------------------------+
| Recurrence at 180 days *(arm 1 v 2)*          | 467 with a first lesion | **8.5 points** on 36.1%                    |
+-----------------------------------------------+-------------------------+--------------------------------------------+
| Lesion at dry-off *(descriptive)*             | 287 reach dry-off       | **9.0 points** on 22.4% (5.2 at 18 months) |
+-----------------------------------------------+-------------------------+--------------------------------------------+

- **Cure is targeted at +15 points**, detected with 91% power.
- **Dry-off is descriptive at 12 months.** The count uses only the 21% who reach dry-off inside six months; early-enrolled cows add more. At 18 months it becomes an outcome (§4).
- Binary outcomes are sized without a between-herd term. They are secondary, and the pilot gives no estimate of how much they vary by herd.

### The limitation, stated up front

- **Break-even needs 0.25-0.6 points less culling across all enrolled cows.**
- **The study's interval on culling is ±2.8 points.** It cannot tell break-even from zero.
  - No feasible study can: detecting it would take 170,000 to a million cows.
- **So this study will *estimate* whether the system pays. It will not *prove* it.** An honest estimate is what a purchasing decision needs. It is not a hypothesis test, and this proposal does not claim one.
- *A composite dollar endpoint was considered and rejected.* A cull-sized dollar event adds far more variance than milk carries. The composite is the right thing to report and the wrong thing to power on.

------------------------------------------------------------------------

## 6. Analysis

**Milk.** Mixed linear model on weekly averages.

- Fixed: arm, **the cow's 7-day pre-alert milk**, DIM spline, lactation group, lesion history, breed, herd. Random: cow intercept, and **arm within herd** - `(1 + arm | herd)`.
- **The random slope is what lets the analysis see herds differing in the effect.** The sample size already pays for it (§5). Without it, the standard error ignores that variation and the false-positive rate climbs to 6-9%.
- Kenward-Roger degrees of freedom. With six herds the between-herd term is estimated from few groups, and a normal approximation overstates certainty.
- **Arm is a main effect.** The `arm × history` interaction is estimated and reported, but not powered - see below.

**Cure.** Mixed logistic, same covariates, herd intercept and arm-within-herd slope.

**Lesion at dry-off.** Reported by arm with its interval, from the same model. Not tested (§4).

### The chronicity interaction: explored, not powered

- Chronic cows do worse. Recurrence rises 34% → 48% → 52% across parity; cure falls from 51.9% in new cows to 45.0% in chronic ones.
  - Those are **main effects**, and adjusting for them is free.
- **We expect the treatment benefit to be larger in new cows, and the pilot points that way.** Pilot TX–Control milk, days 1–30, baseline-adjusted:

| | TX effect | 95% CI |
|---|---|---|
| New cows (61% of enrolled) | +0.39 kg | −0.64 to +1.42 |
| Chronic cows | −1.45 kg | −2.75 to −0.15 |
| **Difference** | **1.84 kg** | **0.18 to 3.50** |

- History was recorded before randomization, so each row is a randomized comparison. But it is one herd, a subgroup looked at after the fact, and a wide interval. Planning on the point estimate would be optimistic.

**What 4,000 enrolled gives** (6 herds, arm-by-herd random slope, pilot's 61% new):

| Estimate | 95% interval |
|---|---|
| Overall effect | ±0.65 kg |
| Effect in new cows | ±0.81 kg |
| Effect in chronic cows | ±1.02 kg |
| New minus chronic | ±1.29 kg |

- If the benefit sits in new cows (1.6 kg in new, none in chronic, 1.0 kg overall), the study has **95% power to detect it in new cows alone** and 63% on the difference.
- If the effect is equal in both, power in new cows alone is 61%.

**If Nedap wants the difference powered:**

| New-minus-chronic difference to detect | Enrolled | Months to enrol, 3,000-cow herds at 0.010 |
|---|---|---|
| 1.84 kg (pilot's estimate) | **4,700** | 6.0 |
| 1.5 kg (a cautious planning value) | **7,100** | 9.1 |
| 1.0 kg | 16,700 | 21 |

- **4,700 is within reach** of the 12-month design, but only if the pilot's difference is real. It uses the full 6 months of enrolment at the low alert rate.
- 7,100 would need about 9 months of enrolment, and an 18-month study.

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
  - **In a trial, lactation group is a randomisation block. A cow allocated on a stale lactation is enrolled wrongly, and no later analysis repairs it.**
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

- **4,000 enrolled, six herds, 12 months.** Milk adjusted for each cow's baseline, with an arm-by-herd random slope (§5, §6).
- **Every cow followed to one study end**, at least 6 months after the last enrolment. Culling and recurrence at 180 days; 365 days reported where cows reach it (§2, §4).
- **Culling compared on all enrolled cows**, not lame cows only (§4).
- **Randomization blocked on chronicity and lactation group.** The new-v-chronic difference is estimated, not powered, at 4,000. Powering it costs 4,700 enrolled on the pilot's estimate, 7,100 on a cautious one (§6).
- **Six herds** across three regions, two each. Four is the stated minimum. Eight is preferred but needs about \$45,000 more (§2, §9).
- **Economics reported as total dollars by arm** (§3), on stated assumptions. They do not affect the sample size.
- **Lesion at dry-off is descriptive.** It becomes an outcome if the study runs 18 months (§4).
- **Cure targeted at +15 points.** §5 states what the design detects on every outcome.
- **Cure and recurrence compared primarily on arms 1 v 2**, where both are protocol-trimmed. Arm 3 is reported with its caveat and its detection route recorded.
- **Alert rules and DairyComp commands frozen for the study** (§2, §7).

------------------------------------------------------------------------

## 9. Budget

**Total: \$220,250 over 12 months** - six herds, 4,000 enrolled.

+-------------------------------------------------------+---------------+
|                                                       |               |
+=======================================================+===============+
| Personnel - farm visits, project management, analysis | \$182,500     |
+-------------------------------------------------------+---------------+
| Travel                                                | \$24,790      |
+-------------------------------------------------------+---------------+
| Data storage                                          | \$12,960      |
+-------------------------------------------------------+---------------+
| **Total**                                             | **\$220,250** |
+-------------------------------------------------------+---------------+

- Farm visits run through enrolment only (6 months). Follow-up is passive data collection.

**Options that add cost:**

+-------------------------------------------------------------------+----------------------------------------------------------------------------+-----------------+
|                                                                   | Adds                                                                       | Total           |
+===================================================================+============================================================================+=================+
| **Eight herds** instead of six                                    | about \$45,000, mostly monthly farm visits, plus travel to the extra herds | about \$265,000 |
+-------------------------------------------------------------------+----------------------------------------------------------------------------+-----------------+
| **18 months** instead of 12 (makes dry-off lesion an outcome, §4) | about \$21,500, project management and data storage                        | about \$242,000 |
+-------------------------------------------------------------------+----------------------------------------------------------------------------+-----------------+

**Not included - to settle with Nedap:**

- **Camera subscription:** \$140,000-173,000 for 18,000 cows over 12 months at \$0.65-0.80 per cow per month. That is 64-79% of the study budget again, so it has to be settled before the total means anything.
- **Extra trimming in arms 1 and 2:** about \$19,500 over the study, at \$18 per trim.

------------------------------------------------------------------------

## Appendix: pilot figures used

+---------------------------------------------------------------+-----------------------------------------+
| Quantity                                                      | Value                                   |
+===============================================================+=========================================+
| Variance of a cow's 90-day milk mean, baseline-adjusted       | 42 kg² (planned at 52, 90th percentile) |
+---------------------------------------------------------------+-----------------------------------------+
| Same, without the baseline                                    | 98 kg²                                  |
+---------------------------------------------------------------+-----------------------------------------+
| Baseline to 90-day milk correlation                           | 0.89                                    |
+---------------------------------------------------------------+-----------------------------------------+
| Enrolled per week per cow in milk, pilot                      | 0.024                                   |
+---------------------------------------------------------------+-----------------------------------------+
| TX–Control milk, days 25–30, baseline-adjusted                | +0.08 kg/day (SE 0.57)                  |
| Same, TX effect in new v chronic cows, days 1–30              | +0.39 v −1.45 kg/day                    |
| Control cows routine-trimmed within 60 days of the alert      | 28.6%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| Alerted cows with a lesion found                              | 35.0%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| Alerted cows with white line or sole ulcer                    | 18.3%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| Cure at 60 days, WLD/SU                                       | 49.3%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| Recurrence within 180 days, cow-level                         | 36.1%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| Culling within 180 days of a camera flag, farm practice       | 16.0%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| Lesion found at a dry-off trim                                | 22.4%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| New-case lesion incidence                                     | 27.1 per 100 cow-years                  |
+---------------------------------------------------------------+-----------------------------------------+
| Empty-trim rate, trimmed arm                                  | 54.9%                                   |
+---------------------------------------------------------------+-----------------------------------------+
| Culling gap at 180 / 365 days, from calving                   | 6.8 / 7.3 points                        |
+---------------------------------------------------------------+-----------------------------------------+
| Alerts per week, pilot farm                                   | 69                                      |
+---------------------------------------------------------------+-----------------------------------------+
| Cows alerted per lactation                                    | 62%                                     |
+---------------------------------------------------------------+-----------------------------------------+
| Lesion cows flagged live, no alert                            | 243                                     |
+---------------------------------------------------------------+-----------------------------------------+
| Of those, genuine integration losses                          | 12                                      |
+---------------------------------------------------------------+-----------------------------------------+
| LOW flags after go-live / `Low` alerts                        | 13,199 / 81                             |
+---------------------------------------------------------------+-----------------------------------------+
| First-lactation cows absent from SmartSight, after 2026-06-24 | 160                                     |
+---------------------------------------------------------------+-----------------------------------------+