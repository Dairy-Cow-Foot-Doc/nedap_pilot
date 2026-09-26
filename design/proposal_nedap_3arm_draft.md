# Does it pay to use Nedap SmartSight?

## A proposal for a three-arm randomised trial

**Draft 3 — 2026-09-26.** All pilot figures are computed from its data. Derivations are held separately and available on request.

------------------------------------------------------------------------

## 1. The question

**Does acting on SmartSight alerts leave a commercial dairy better off, and by enough to pay for the system?**

The pilot study answered several important questions and provided insights into things we need to consider in a study that looks at if using SmartSight is worth it. What follows below is a proposal to study that question.

------------------------------------------------------------------------

## 2. Proposed design

Randomised controlled trial,

- **3 arms**

- **365-day follow-up** after enrollment to allow impacts on culling and recurrence to be determined — cure is read earlier, at the 60-day recheck

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

| Between-herd SD of the effect | 4 herds         | **6 herds** | 10 herds |
|-------------------------------|-----------------|-------------|----------|
| 0.25 kg *(planning value)*    | ×1.14           | **×1.09**   | ×1.05    |
| 0.50 kg                       | ×1.96           | **×1.49**   | ×1.24    |
| 0.75 kg                       | *no n suffices* | **×3.78**   | ×1.79    |

- **The sample size is planned at 0.25 kg**: ×1.09 at six herds, ×1.14 at four.
- The rest of the table is the sensitivity.
  - At 0.5 kg, six herds need 8,200 enrolled; four need 10,800.
  - At 0.75 kg, four herds cannot reach the target at any size. Six still can.
- **Herds are cheaper insurance than cows.**

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
- 54.9% of arm-1 trims are expected to find nothing, at about \$19 per lame cow in extra trimming. **This one distinction moves the economic verdict by roughly the whole extra-trimming cost.**

### What the pilot already puts on the ledger

Acting on alerts means **trimming more cows.**

- The trimmed arm was trimmed 90.4% of the time against Control's 49.8% - about **one extra trim per lame cow.**
- 54.9% of those trims found no lesion.

Per lame cow, with the break-even calculator's own IOFC of \$0.254/kg:

|   | \$0.65/cow/month | \$0.80/cow/month |
|----|----|----|
| Camera | \$28.78 | \$35.42 |
| Extra trimming at \$20 | \$19.40 | \$19.40 |
| **Total to recover** | **\$48.18** | **\$54.82** |
| Milk supplies, at 1.05–1.5 kg over 90 days | \$24–34 | \$24–34 |
| **Shortfall** | **\$14–24** | **\$21–31** |

**Milk alone does not cover the cost.** The shortfall is what culling, recurrence and treatment labour must close. At \$1,650 net per cull avoided, roughly **0.9 to 1.5 percentage points of avoided culling** would close it.

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

- Indexed to days since alert, and normalised to each cow's own pre-alert baseline.
- The pre-alert slope also shows how much milk was already lost before the camera fired.
- *Why arm 1 v 3 only:* it holds across windows (2,982 to 3,228 cows from 28 to 180 days). Arm 1 v 2 on milk reaches only 43% power at 6,000 cows over 60 days.

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

- The design detects a **10.5-point** observed difference.
- Among cows who actually waited four weeks, that is about a **16-point** true difference.
- Report both, alongside the per-protocol analysis.

**2. Lesion prevalence at the routine dry-off trim.**

Every cow is trimmed around dry-off whatever her arm, so this is the one lesion measure not driven by inspection rate. Coverage was **88.6% in Control against 92.7% in TX.**

- **It is a window, not a day.** Trims cluster 21 to 7 days *before* dry-off. ±7 days catches only 9.6% of them; −45 to +7 catches about 90%.
- **Only cows with at least 90 days from alert to dry-off.** That keeps 66% of alerted cows. The rest were alerted late in lactation, so report DIM at alert for both groups.

**3. Culling, followed for 365 days.**

Not six months. The lameness–culling gap is still widening at six:

| Window       | No early lesion | Early lesion | Gap      |
|--------------|-----------------|--------------|----------|
| 90 days      | 28.1%           | 33.0%        | +4.9     |
| 180 days     | 34.0%           | 40.8%        | +6.8     |
| **365 days** | **45.0%**       | **52.3%**    | **+7.3** |

The pilot's own three-month figure had the *wrong sign* - lame cows culled less. That is what a window shorter than the process produces.

**4. Recurrence within 365 days** of a first lesion, counting only lesions 14+ days later. Baseline 48.7%.

### Not outcomes

- **Reproduction.** Nothing in the herd's records: median days to first service 77 v 78, services 1.93 v 1.94. No effect to power against.
- **Lesion severity.** Not standardisable across farms and trimmers.
- **Detection sensitivity.** Not estimable from an alert-triggered cohort at any size.

------------------------------------------------------------------------

## 5. Sample size

**Target: 6,000 cows enrolled across three arms.**

Powered on the primary milk contrast, 80% power, two-sided α = 0.05. Variance components from the pilot: between-cow SD 9.39 kg, weekly residual SD 4.79 kg, after adjusting for lactation curve, parity and history.

+-----------------------------+----------------+----------------+-------------------------------------------+
| Observed arm-1-v-3 contrast | Per arm        | Three arms     | With ×1.28 attrition, ×1.09 heterogeneity |
+=============================+================+================+===========================================+
| 0.8 kg/day                  | 2,226          | 6,678          | 9,400                                     |
+-----------------------------+----------------+----------------+-------------------------------------------+
| **1.0 kg/day**              | **1,425**      | **4,275**      | **6,000**                                 |
+-----------------------------+----------------+----------------+-------------------------------------------+
| 1.2 kg/day                  | 989            | 2,967          | 4,200                                     |
+-----------------------------+----------------+----------------+-------------------------------------------+

- **1.0 kg/day is the realistic target.**
  - The three-arm simulation gives a 1.01 kg observed contrast for a 1.5 kg true effect.
  - The pilot's observed 1.05 kg implies a true effect near 1.5 kg, once its 49.8%-trimmed Control arm is allowed for.
- **Attrition is ×1.28**, mostly drying off (15.8% by day 90) rather than culling (6.2%).
- **Herd heterogeneity is ×1.09** at the 0.25 kg planning value. It is not a cluster design effect: randomisation is *within* herd, so herd is a block and removes between-herd variance.

### What each herd supplies

At 6,000 enrolled: **1,000 alerted cows per herd** across six, or 1,500 across four. At the pilot farm's alert rate of about 0.020 per cow per week:

+----------------+-----------------+--------------------------+----------------------+
| Herd size      | Alerts per week | **6 herds** (1,000 each) | 4 herds (1,500 each) |
+================+=================+==========================+======================+
| 2,000 cows     | 40              | **25 weeks**             | 37 weeks             |
+----------------+-----------------+--------------------------+----------------------+
| 3,000 cows     | 60              | **17 weeks**             | 25 weeks             |
+----------------+-----------------+--------------------------+----------------------+
| 5,000 cows     | 100             | **10 weeks**             | 15 weeks             |
+----------------+-----------------+--------------------------+----------------------+

**Enrolment closes in three to six months, not a year.**

### Timeline

+----------------------------------------------------+----------------------------------------------------------+
|                                                    |                                                          |
+====================================================+==========================================================+
| Enrolment                                          | **3–6 months**, running in parallel across the six herds |
+----------------------------------------------------+----------------------------------------------------------+
| Follow-up on the last cow enrolled                 | **12 months**                                            |
+----------------------------------------------------+----------------------------------------------------------+
| **Total from first enrolment to last observation** | **15–18 months**                                         |
+----------------------------------------------------+----------------------------------------------------------+

- **The 365-day culling follow-up sets the duration, not recruitment.**
  - More herds shorten enrolment. The year of follow-up is fixed either way.
- A six-month follow-up would cut the study to 9–12 months, but lose the culling outcome. The gap is still widening at six months (6.8 against 7.3 points at twelve).

### What this design detects

Smallest difference detectable at 80% power at 6,000 enrolled (2,000 per arm), after attrition and herd heterogeneity. Arm 1 v 3 unless noted:

+-----------------------------------------------+---------------------------+---------------------------------------------------+
| Outcome                                       | Cows contributing per arm | **Smallest detectable difference**                |
+===============================================+===========================+===================================================+
| **Milk** (primary)                            | 2,000                     | **1.00 kg/day** observed contrast                 |
+-----------------------------------------------+---------------------------+---------------------------------------------------+
| Lesion prevalence at dry-off                  | 1,320                     | **4.9 points**                                    |
+-----------------------------------------------+---------------------------+---------------------------------------------------+
| Recurrence within 365 days                    | 700                       | **7.4 points** on a 48.7% baseline (15% relative) |
+-----------------------------------------------+---------------------------+---------------------------------------------------+
| Culling at 365 days                           | 700                       | **7.5 points** on a 52.3% baseline                |
+-----------------------------------------------+---------------------------+---------------------------------------------------+
| Cure, white line and sole ulcer *(arm 1 v 2)* | 348                       | **10.5 points** on a 49.3% baseline               |
+-----------------------------------------------+---------------------------+---------------------------------------------------+

- **Cure is targeted at +15 points**, detected with 98% power. 10.5 points is the floor at 80%.
  - A 10-point target would need about 10,000 enrolled - not worth a 65% larger study when milk is primary.
- **Recurrence and dry-off prevalence come free** at the size milk requires.

### The limitation, stated up front

- **A ±5.2-point interval on culling cannot tell the 1.3 points break-even needs from zero.**
  - No feasible study can. Detecting 1.3 points would take on the order of 200,000 cows.
- **So this study will *estimate* whether the system pays. It will not *prove* it.** An honest estimate is what a purchasing decision needs. It is not a hypothesis test, and this proposal does not claim one.
- *A composite dollar endpoint was considered and rejected.* A \$1,500 event at 46% adds enough variance to need 43,000 cows. The composite is the right thing to report and the wrong thing to power on.

------------------------------------------------------------------------

## 6. Analysis

**Milk.** Mixed linear model on weekly averages.

- Fixed: arm, DIM spline, lactation group, lesion history, breed, herd. Random: cow intercept.
- **Arm is a main effect.** The `arm × history` interaction is estimated and reported, but not powered - see below.

**Cure and lesion at dry-off.** Mixed logistic, same covariates, herd random effect.

### The chronicity interaction: explored, not powered

- Chronic cows do worse. Recurrence rises 34% → 48% → 52% across parity; cure falls from 51.9% in new cows to 45.0% in chronic ones.
  - Those are **main effects**, and adjusting for them is free.
- Whether the *treatment benefit* differs by chronicity is untested. The pilot has no randomised contrast to test it with.
- **The study estimates it and reports it with its interval.**
  - At 6,000 enrolled the interaction's 95% interval is about ±0.83 kg/day, against ±0.59 kg for the main effect.
  - Only a large new-v-chronic difference would show. The estimate still tells a follow-up study whether to target one group.

**If Nedap wants it powered**, the cost is substantial:

|                           | Explored           | Powered             |
|---------------------------|--------------------|---------------------|
| Milk, 1.0 kg contrast     | **6,000 enrolled** | **12,000 enrolled** |
| Cure, WLD/SU +15 points   | \~3,000            | \~4,700             |
| Accrual at 69 alerts/week | 87 farm-weeks      | 174 farm-weeks      |

- Milk binds in both. Powering the interaction is **2.0× the study** - about 29 weeks of accrual across six herds rather than 15.
- Verified: the penalty is 2.00× on the linear milk model and 1.59× on the logistic cure model.

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

- **Randomisation blocked on chronicity and lactation group.** The chronicity interaction is explored, not powered. Powering it costs 12,000 enrolled (§6).
- **Six herds** across three regions, two each. Four is the stated minimum (§2, §5).
- **Economic inputs are stated assumptions** (§3). They do not affect the sample size.
- **Cure targeted at +15 points.** §5 states what the design detects on every outcome.
- **Cure compared primarily on arms 1 v 2**, where both are protocol-trimmed. Arm 3 is reported with its caveat and its detection route recorded.
- **Alert rules and DairyComp commands frozen for the study** (§2, §7).

------------------------------------------------------------------------

## Appendix: pilot figures used

| Quantity                                   | Value                  |
|--------------------------------------------|------------------------|
| Between-cow SD, weekly milk                | 9.39 kg                |
| Residual SD, weekly milk                   | 4.79 kg                |
| Observed TX–Control milk contrast          | 1.05 kg/day            |
| Alerted cows with a lesion found           | 35.0%                  |
| Alerted cows with white line or sole ulcer | 18.3%                  |
| Cure at 60 days, WLD/SU                    | 49.3%                  |
| Recurrence within 365 days                 | 48.7%                  |
| New-case lesion incidence                  | 27.1 per 100 cow-years |
| Extra trims per lame cow                   | 0.97                   |
| Empty-trim rate, trimmed arm               | 54.9%                  |
| Culling gap at 365 days                    | 7.3 points             |
| Alerts per week, pilot farm                | 69                     |
| Cows alerted per lactation                 | 62%                    |
| Lesion cows flagged live, no alert         | 243                    |
| Of those, genuine integration losses       | 12                     |
| LOW flags after go-live / `Low` alerts     | 13,199 / 81            |
