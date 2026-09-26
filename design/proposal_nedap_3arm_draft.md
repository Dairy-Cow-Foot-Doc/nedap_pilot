# Does it pay to use Nedap SmartSight?

## A proposal for a three-arm randomised trial

**Draft 4 — 2026-09-26.** All pilot figures are computed from its data. Derivations are held separately and available on request.

------------------------------------------------------------------------

## 1. The question

**Does acting on SmartSight alerts leave a commercial dairy better off, and by enough to pay for the system?**

The pilot study answered several important questions and provided insights into things we need to consider in a study that looks at if using SmartSight is worth it. What follows below is a proposal to study that question.

------------------------------------------------------------------------

## 2. Proposed design

Randomised controlled trial,

- **3 arms**

- **12 months in total.** Up to 6 months of enrolment, then every cow is followed to one study end date.

  - The last cow enrolled gets at least 6 months. That covers milk (90 days), cure (60-day recheck), and culling and recurrence at 180 days.

  - Cows enrolled early get up to a year, so 365-day culling is estimated from them.

- **6 herds of 2,000–5,000 cows** across three regions

  - Two each in New York, Midwest and the West Coast as I have DVM collaborators in those regions and I know you are active in these regions.

  - **Four herds is a workable minimum**

    - The precision cost is under Eligibility below; the calendar-time cost is in Section 5.

### Arms

The proposed arms are as follows.

+----------------------------------+-------------------------------------------------------------------------------------------------------------+
| Arm                              | Protocol                                                                                                    |
+==================================+=============================================================================================================+
| **1. Early**                     | Cow gets trimmed within **1 week** of the alert.                                                            |
+----------------------------------+-------------------------------------------------------------------------------------------------------------+
| **2. Delayed**                   | Cow gets trimmed **4 weeks** after her alert                                                                |
|                                  |                                                                                                             |
|                                  | - sooner if the routine schedule or staff put her on trim list.                                             |
+----------------------------------+-------------------------------------------------------------------------------------------------------------+
| **3. Farm practice**             | Alerted and recorded, not acted on. Treated only if staff or the routine schedule put her on the trim list. |
+----------------------------------+-------------------------------------------------------------------------------------------------------------+

For all 3 arms **if farm staff identify a cow as lame she is trimmed, regardless of arm.**

**How an alert reaches the trim list must differ by arm. This is the most important thing to set up correctly.**

- In the pilot a treated-arm alert **auto-added** the cow to the trim list. That is the system default.
  - It shows in the data: 23 treated-arm same-day trims had no prior staff check.
- In this design the alert adds her **within a week in arm 1, at four weeks in arm 2, and never in arm 3.**
- **If the auto-add fires for every arm, arm 3 is trimmed by the system.** The primary contrast is gone from day one, and nothing in the data will show it.

**Arm 3 is regular farm practice, not an untreated arm.**

- In the pilot the equivalent group was trimmed 49.8% of the time, mostly by routine trimming.
- Herds with **little mid-lactation trimming** sharpen this contrast. That is an eligibility criterion below.
  - It also moves arm 3 away from the pilot's 49.8%, which the contamination and dilution figures assume.

**Arm 2 is contaminated by design.**

- Based on the pilot Farm detection is heavily front-loaded — 66% of catches land inside four weeks, and week 1 alone is 31%

  - If this persists 1/3 of arm 2 will be treated before its protocol week.

  - This means we will pre-specify a per-protocol analysis alongside intention-to-treat to separate the impact of contamination.

  - Arm 2 is needed to determine whether the trims that find no lesion in Arm 1 would have developed into treatable lesions — that is, whether Arm 1 is actually preventing them.

### Enrolment

- A cow enters **at her first SmartSight alert** and is randomised then.
- Randomisation is **blocked by lameness history (new / chronic) and lactation group (1 / 2 / 3+).**
  - Blocking balances the arms on the two covariates most likely to change the effect. It costs nothing and improves precision.
- **The alert rules are frozen for the whole study** - see §7.
  - In the pilot, Nedap moved the LOW trigger seven weeks before go-live, and the farm's `Low` command no longer matched it.
  - Enrolment is "at the alert", so a change to what counts as an alert changes who is enrolled.
- **Each cow is enrolled once.** Her arm is a strategy for every alert she gets until the study ends, not just the first.

**Cows that calve during the study:**

- **She keeps her arm.** Alerts after calving are handled by the same protocol.
- **Milk (primary) stays in the enrolment lactation.** The 90-day window ends early if she dries off - that is attrition, already in the ×1.28.
  - Milk after calving is not used. A new lactation needs a new baseline.
- **Culling and recurrence follow the cow**, across the calving, to the study end.
- **Dry-off lesion is read at the enrolment lactation's dry-off.**
- A cow never enrolled who calves and is alerted in her new lactation can enrol then, at DIM 5 or later.
- Lactation group for the randomisation block is set by date at the alert, not from the event record (§6).

**Enrolling at freshening was considered and rejected.**

- It does not change the treatment contrast. Cows are still only treated when alerted.
- It costs ×1.6 the cows and about double the calendar time.
- It would only pay if detection accuracy were a study question. It is not - the pilot report covers detection.

### Eligibility

**Herds**

Herds are run by collaborating investigators, two in each region.

**The regional spread is a reason for more herds, not fewer regions.**

- Housing, flooring, climate and trimming practice differ by region.
- That raises the between-herd variation in the treatment effect, which is what herd count protects against.

Cows enrolled for 80% power on the primary milk contrast, analysed with an arm-by-herd random slope:

| Between-herd SD of the effect | 4 herds         | **6 herds** | 8 herds | 10 herds |
|-------------------------------|-----------------|-------------|---------|----------|
| 0.25 kg *(planning value)*    | 4,300           | **4,000**   | 3,800   | 3,700    |
| 0.50 kg                       | 7,100           | **5,200**   | 4,600   | 4,300    |
| 0.75 kg                       | *over 20,000*   | **13,300**  | 7,400   | 5,900    |

- **The sample size is planned at 0.25 kg with six herds: 4,000 enrolled.**
- The rest of the table is the sensitivity. If herds differ more than planned, more herds is the cheap fix, not more cows.
- **This matters more than it did.** Adjusting for baseline milk removes most of the cow-to-cow noise, so between-herd differences are a bigger share of what is left.
- **Herds are cheaper insurance than cows.** Eight herds would be the stronger design if collaborators allow.

**Each participating herd must have:**

- **Reliable** hoof trimming data — complete and consistently coded, checkable before enrolment.
- **Low routine-trimming frequency.**
  - Power on the primary contrast is 75% in a herd trimming routinely at 10%, against 33% at 60%, at the same enrolment.
  - This is a bigger lever than sample size, and it shows in existing records.
- Trained trimming staff; daily milk weights; able to run SmartSight.

**Cows**

**A minimum of 5 days in milk.** A cow alerted in her first days after calving is excluded. She re-enters if alerted later.

- Fresh cows walk abnormally for reasons that are not hoof lesions.
- **It costs almost nothing.** The median pilot cow was alerted at **DIM 150**. A DIM 5 floor would have excluded **11 of 849 cows (1.3%)**.
- It also removes the stale-lactation allocation error. All three pilot cases were at DIM 0–1.
- *Stated honestly:* the pilot cannot show fresh-cow alerts are more often wrong. Only 14 cows were alerted at DIM 0–5; a 20-point difference would need about 100 per group. The floor rests on physiology and its low cost.

**No lameness-history restriction.**

- Excluding cows treated this lactation would remove 38.7% of the herd.
- It falls unevenly: **54.8% of lactation 3+ against 15.8% of first lactation.** That skews the study young, away from the cows the system is sold to manage.
- Handle history by blocking on it and adjusting in every model.

------------------------------------------------------------------------

## 3. What the design answers

+-----------------------+-----------------------+----------------------------------------------------------------------------+
|                       | Comparison            | Answers                                                                    |
+=======================+=======================+============================================================================+
| **Primary**           | Arm 1 v arm 3         | Does acting on alerts pay?                                                 |
+-----------------------+-----------------------+----------------------------------------------------------------------------+
| **Secondary**         | Arm 1 v arm 2         | Does acting *quickly* pay — and is the responsive protocol worth its cost? |
+-----------------------+-----------------------+----------------------------------------------------------------------------+

- **Arm 1 v 3 carries the efficacy claim.** It is also the only milk contrast powerable at a realistic size, and the only one that holds whatever the measurement window (§4).
- **Arm 1 v 2 is the question a farm actually faces** - not whether to act, but how fast.
  - A one-week response costs more labour and scheduling than a four-week one. This comparison says whether that is worth buying.

### Why the trial needs three arms rather than two

- **An arm-1 trim that finds no lesion cannot be read on its own.**
  - Either the camera was wrong (a wasted trim), or early trimming prevented the lesion (the system working).
  - The two have opposite economic signs.
- **Arm 2 separates them.** If arm-2 cows show lesions at four weeks where arm-1 cows had none at one week, the empty arm-1 trims were prevention.
- 54.9% of arm-1 trims are expected to find nothing, at about \$17 per lame cow in extra trimming. **This one distinction moves the economic verdict by roughly the whole extra-trimming cost.**

### What the pilot already puts on the ledger

Acting on alerts means **trimming more cows.**

- The trimmed arm was trimmed 90.4% of the time against Control's 49.8% - about **one extra trim per lame cow.**
- 54.9% of those trims found no lesion.

Per lame cow, with the break-even calculator's own IOFC of \$0.254/kg:

|   | \$0.65/cow/month | \$0.80/cow/month |
|----|----|----|
| Camera | \$28.78 | \$35.42 |
| Extra trimming, 0.97 trims at \$18 | \$17.46 | \$17.46 |
| **Total to recover** | **\$46.24** | **\$52.88** |
| Milk supplies, at 1.05–1.5 kg over 90 days | \$24–34 | \$24–34 |
| **Shortfall** | **\$12–22** | **\$19–29** |

**Milk alone does not cover the cost.** The shortfall is what culling, recurrence and treatment labour must close. At \$1,650 net per cull avoided, roughly **0.7 to 1.8 percentage points of avoided culling** per lame cow would close it.

- Every figure here is one trim cost (\$18) and one cull cost (\$1,650), from the assumptions table below.

#### Economic assumptions

+------------------------+-----------------------+----------------+-------------------------------+
| Input                  | Value used            | Range          | Source                        |
+========================+=======================+================+===============================+
| Milk price             | \$0.37/kg             |                | Break-even calculator default |
+------------------------+-----------------------+----------------+-------------------------------+
| Feed cost              | \$0.29/kg DM          |                | Calculator default            |
+------------------------+-----------------------+----------------+-------------------------------+
| Feed conversion        | 2.5 kg milk per kg DM |                | Calculator default            |
+------------------------+-----------------------+----------------+-------------------------------+
| **IOFC**               | **\$0.254/kg**        |                | Derived from the three above  |
+------------------------+-----------------------+----------------+-------------------------------+
| Cost per hoof trim     | **\$18**              | \$15–20        | Current typical               |
+------------------------+-----------------------+----------------+-------------------------------+
| Replacement animal     | **\$3,000**           | \$2,500–3,500  | Current market                |
+------------------------+-----------------------+----------------+-------------------------------+
| Cull cow value         | **\$1,350**           | \$1,200–1,500  | Current market                |
+------------------------+-----------------------+----------------+-------------------------------+
| **Net cost of a cull** | **\$1,650**           | \$1,000–2,300  | Replacement less cull value   |
+------------------------+-----------------------+----------------+-------------------------------+
| Camera subscription    | \$0.65–0.80/cow/month |                | Reported estimates            |
+------------------------+-----------------------+----------------+-------------------------------+

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

**2. Lesion prevalence at the routine dry-off trim.**

Every cow is trimmed around dry-off whatever her arm, so this is the one lesion measure not driven by inspection rate. Coverage was **88.6% in Control against 92.7% in TX.**

- **It is a window, not a day.** Trims cluster 21 to 7 days *before* dry-off. ±7 days catches only 9.6% of them; −45 to +7 catches about 90%.
- **Baseline: a lesion is found at 22.4% of dry-off trims.**
- **Only cows with at least 90 days from alert to dry-off, and dry-off before the study ends.**
  - **This is the outcome the 12-month design costs most.** 21% of cows reach dry-off inside 6 months of their alert, 51% inside 9, 68% inside 12. Early-enrolled cows carry it.
  - It selects on DIM at alert, so report DIM for kept and dropped cows.

**3. Culling at 180 days, on every enrolled cow.**

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

**4. Recurrence within 180 days** of a first lesion, counting only lesions 14+ days later, and following the cow across a calving. Baseline **36.1%**.

- Measured on lame cows, so it is descriptive, not a randomised contrast - the same reason as culling.

### Not outcomes

- **Reproduction.** Nothing in the herd's records: median days to first service 77 v 78, services 1.93 v 1.94. No effect to power against.
- **Lesion severity.** Not standardisable across farms and trimmers.
- **Detection sensitivity.** Not estimable from an alert-triggered cohort at any size.

------------------------------------------------------------------------

## 5. Sample size

**Target: 4,000 cows enrolled across three arms, six herds.**

Powered on the primary milk contrast, arm 1 v 3, 1.0 kg/day, 80% power, two-sided α = 0.05.

| Step | Cows |
|---|---|
| Per arm, with each cow's baseline as a covariate | 815 |
| × 3 arms | 2,445 |
| × 1.28 attrition | 3,130 |
| **With the arm-by-herd random slope (between-herd SD 0.25 kg, six herds)** | **4,000** |

- **The variance is the pilot's own, over the full 90 days.** A cow's 90-day mean varies by 42 kg² after adjusting for her baseline, against 98 kg² without it.
  - It rests on the 114 pilot cows alerted early enough to have 90 days of milk. So the study is planned on the **90th percentile** of a bootstrap of that estimate (52 kg²), not the point.
  - Without the baseline covariate the same design needs 7,500.
- **1.0 kg/day is the realistic target.**
  - The three-arm simulation gives a 1.01 kg observed contrast for a 1.5 kg true effect.
  - The pilot's observed 1.05 kg implies a true effect near 1.5 kg, once its 49.8%-trimmed Control arm is allowed for.
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

| | |
|---|---|
| Enrolment | **up to 6 months**, in parallel across the six herds (2.6-5.1 months expected at 3,000 cows) |
| Follow-up | **every cow to one study end date**, at least 6 months after the last enrolment |
| **Total** | **12 months** |

- **Following each cow for 365 days would have set the duration at 18-21 months.** Following all cows to one end date does not lose that information: early cows still reach a year, and time-to-event analysis uses every cow for as long as she is watched.
- What the last cow's 6 months must cover: milk (90 days), cure (60-day recheck), and culling and recurrence at 180 days.
- Recurrence needs a lesion first, so the last cows enrolled may fall a few weeks short of 180 days. They are censored, not dropped.

### What this design detects

Smallest difference detectable at 80% power at 4,000 enrolled (1,333 per arm). Arm 1 v 3 unless noted:

| Outcome | Cows per arm | **Smallest detectable difference** |
|---|---|---|
| **Milk** (primary) | 1,333 | **1.00 kg/day** observed contrast |
| Culling at 180 days, all enrolled | 1,333 | **3.8 points** on 16.0% |
| Cure, white line and sole ulcer *(arm 1 v 2)* | 232 assessed | **12.8 points** on 49.3% |
| Recurrence at 180 days *(descriptive)* | 467 lame cows | **8.5 points** on 36.1% |
| Lesion at dry-off | 287 reach dry-off | **9.0 points** on 22.4% |

- **Cure is targeted at +15 points**, detected with 91% power.
- **Dry-off is the weakest outcome.** The count uses only the 21% who reach dry-off inside six months; early-enrolled cows add more.
- Binary outcomes are sized without a between-herd term. They are secondary, and the pilot gives no estimate of how much they vary by herd.

### The limitation, stated up front

- **Break-even needs 0.7-1.8 points less culling per lame cow.** On all enrolled cows that is 0.25-0.6 points.
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

**Cure and lesion at dry-off.** Mixed logistic, same covariates, herd intercept and arm-within-herd slope.

### The chronicity interaction: explored, not powered

- Chronic cows do worse. Recurrence rises 34% → 48% → 52% across parity; cure falls from 51.9% in new cows to 45.0% in chronic ones.
  - Those are **main effects**, and adjusting for them is free.
- Whether the *treatment benefit* differs by chronicity is untested. The pilot has no randomised contrast to test it with.
- **The study estimates it and reports it with its interval.**
  - At 4,000 enrolled the interaction's 95% interval is about ±1.0 kg/day, against ±0.7 kg for the main effect.
  - Only a large new-v-chronic difference would show. The estimate still tells a follow-up study whether to target one group.

**If Nedap wants it powered**, the cost is substantial:

|                       | Explored           | Powered            |
|-----------------------|--------------------|--------------------|
| Milk, 1.0 kg contrast | **4,000 enrolled** | **8,000 enrolled** |
| Enrolment, 3,000-cow herds at 0.010 | 5 months | 10 months |

- Powering the interaction is **2.0× the study**, because each stratum carries half the cows. Verified: 2.00× on the linear milk model, 1.59× on the logistic cure model.
- Ten months of enrolment would break the 12-month timeline.

**Culling and recurrence.** Time-to-event, same covariates, stratified by herd. Culling is a competing risk for recurrence, not attrition.

**Staggered entry.** Censor explicitly. Do not restrict to cows with complete follow-up - that selects the earliest enrolled, the trap the pilot's day-30 milk figures fell into.

**Record separately:** staff `CHKLAME` detections and routine-round trims. Median time to trim differs threefold (7 v 23 days), and routine coverage varies by herd.

**Pre-specify before enrolment opens.** Each of these moved answers in the pilot.

- **What counts as a miss for a cow alerted and never examined.** The single biggest lever, and it moves the *contrast*.
  - In the pilot it took Control from 27.9% to 11.5% and the trimmed arm from 12.4% to 10.1% - the **arm gap went from 15.4 points to 1.4.** The choice was made after seeing the data.
  - It lands unevenly by construction: twenty such cows in Control against four in the trimmed arm.
  - **Where one arm must act and another need not, an alerted-never-examined cow is an outcome in one arm and a protocol deviation in the other.** Settle it before unblinding.
- **The warning window.** The pilot used 28 days, to match DairyComp's `FTDAT<-28`.
  - The miss count did not move at 14-45 days. What moved was which category each miss fell in.
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
- **Randomisation blocked on chronicity and lactation group.** The chronicity interaction is explored, not powered. Powering it costs 8,000 enrolled (§6).
- **Six herds** across three regions, two each. Four is the stated minimum; eight would be stronger (§2, §5).
- **Economic inputs are stated assumptions** (§3). They do not affect the sample size.
- **Cure targeted at +15 points.** §5 states what the design detects on every outcome.
- **Cure compared primarily on arms 1 v 2**, where both are protocol-trimmed. Arm 3 is reported with its caveat and its detection route recorded.
- **Alert rules and DairyComp commands frozen for the study** (§2, §7).

------------------------------------------------------------------------

## Appendix: pilot figures used

| Quantity                                   | Value                  |
|--------------------------------------------|------------------------|
| Variance of a cow's 90-day milk mean, baseline-adjusted | 42 kg² (planned at 52, 90th percentile) |
| Same, without the baseline                 | 98 kg²                 |
| Baseline to 90-day milk correlation        | 0.89                   |
| Enrolled per week per cow in milk, pilot   | 0.024                  |
| Observed TX–Control milk contrast          | 1.05 kg/day            |
| Alerted cows with a lesion found           | 35.0%                  |
| Alerted cows with white line or sole ulcer | 18.3%                  |
| Cure at 60 days, WLD/SU                    | 49.3%                  |
| Recurrence within 180 days, cow-level      | 36.1%                  |
| Culling within 180 days of a camera flag, farm practice | 16.0%     |
| Lesion found at a dry-off trim             | 22.4%                  |
| New-case lesion incidence                  | 27.1 per 100 cow-years |
| Extra trims per lame cow                   | 0.97                   |
| Empty-trim rate, trimmed arm               | 54.9%                  |
| Culling gap at 180 / 365 days, from calving | 6.8 / 7.3 points      |
| Alerts per week, pilot farm                | 69                     |
| Cows alerted per lactation                 | 62%                    |
| Lesion cows flagged live, no alert         | 243                    |
| Of those, genuine integration losses       | 12                     |
| LOW flags after go-live / `Low` alerts     | 13,199 / 81            |
