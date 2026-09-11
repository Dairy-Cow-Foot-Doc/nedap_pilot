# Does it pay to use Nedap SmartSight?

## A proposal for a three-arm randomised trial

**Draft 2 — 2026-09-10.** All figures attributed to the pilot are computed from its data; derivations and validation are held separately and available on request.

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

**Arm 3 is regular farm practice, not an untreated arm.** In the pilot the equivalent group was trimmed 49.8% of the time, mostly by routine trimming.

- Selecting herds that do **little mid-lactation trimming** sharpens this contrast and is an eligibility criterion below — though it also moves arm 3 away from the pilot's 49.8%, which the contamination and dilution figures assume.

**Arm 2 is contaminated by design.**

- Based on the pilot Farm detection is heavily front-loaded — 66% of catches land inside four weeks, and week 1 alone is 31%

  - If this persists 1/3 of arm 2 will be treated before its protocol week.

  - This means we will pre-specify a per-protocol analysis alongside intention-to-treat to separate the impact of contamination.

  - Arm 2 is needed to determine whether the trims that find no lesion in Arm 1 would have developed into treatable lesions — that is, whether Arm 1 is actually preventing them.

### Enrolment

A cow enters **at her first SmartSight alert** and is randomised at that moment, in **blocks by lameness history (new / chronic) and lactation group (1 / 2 / 3+)**. Blocking balances the arms on the two covariates most likely to modify the effect, costs nothing, and improves precision on the main comparison.

Enrolling at freshening instead was considered and rejected. It does not change the treatment contrast — cows are still only treated when alerted — so it buys nothing for these outcomes, at ×1.6 the cows and roughly double the calendar time. It would only earn that if detection accuracy were a study question. It is not — the pilot report accompanying this proposal covers detection, and what remains open is whether acting on the alerts pays.

### Eligibility

**Herds**

Herds are run by collaborating investigators, two in each region.

**The geographic spread cuts both ways and the herd count is the answer to it.** Herds in different regions differ in housing, flooring, climate and trimming practice, which raises the between-herd variation in the treatment effect — the thing herd count protects against. Six herds is the right response to that spread, not a reason to narrow it:

| Between-herd SD of the effect | 4 herds         | **6 herds** | 10 herds |
|-------------------------------|-----------------|-------------|----------|
| 0.25 kg *(planning value)*    | ×1.14           | **×1.09**   | ×1.05    |
| 0.50 kg                       | ×1.96           | **×1.49**   | ×1.24    |
| 0.75 kg                       | *no n suffices* | **×3.78**   | ×1.79    |

**The sample size is planned at a 0.25 kg between-herd SD**, costing ×1.09 at six herds against ×1.14 at four. The rest of the table is the sensitivity, and it is why the herd count matters: at 0.5 kg six herds would need 8,200 enrolled where four would need 10,800, and at 0.75 kg four herds cannot deliver the target at any sample size while six still can. **Herds are cheaper insurance than cows.**

**Each participating herd must have:**

- **Reliable** hoof trimming data — complete and consistently coded, checkable before enrolment.
- **Low routine-trimming frequency.** Power on the primary contrast more than doubles between a herd that trims routinely at 10% and one at 60% (75% versus 33% at identical enrolment). This is a bigger lever than sample size and is visible in existing records.
- Trained trimming staff; daily milk weights; able to run SmartSight.

**Cows**

**No lameness-history restriction.** Excluding cows treated in the current lactation would remove 38.7% of the herd — but unevenly: **54.8% of lactation 3+ against 15.8% of first lactation**, skewing the study young, away from the cows the system is sold to manage. Handle history by stratifying randomisation on it and adjusting in every model.

------------------------------------------------------------------------

## 3. What the design answers

Now that the arms are defined, the comparisons they support:

+-----------------------+-----------------------+----------------------------------------------------------------------------+
|                       | Comparison            | Answers                                                                    |
+=======================+=======================+============================================================================+
| **Primary**           | Arm 1 v arm 3         | Does acting on alerts pay?                                                 |
+-----------------------+-----------------------+----------------------------------------------------------------------------+
| **Secondary**         | Arm 1 v arm 2         | Does acting *quickly* pay — and is the responsive protocol worth its cost? |
+-----------------------+-----------------------+----------------------------------------------------------------------------+

**Arm 1 versus arm 3 is the primary comparison** and carries the efficacy claim. It is also the only milk contrast powerable at a realistic size, and the only one insensitive to how long production is measured for — see §4.

**Arm 1 versus arm 2 answers the operational question a farm faces**, which is not usually whether to act but how fast. A one-week response costs more in labour and scheduling than a four-week one, and this comparison is what says whether that is worth buying.

### Why the trial needs three arms rather than two

A cow trimmed in arm 1 with no lesion found is **unidentifiable from that trim alone**. She is either a camera false positive, or a true positive whose lesion was prevented by early intervention. The two have opposite economic signs: the first is a wasted trim, the second is the system working.

**Arm 2 separates them.** If a meaningful share of arm-2 cows show a visible lesion at four weeks where arm-1 cows had none at one week, the arm-1 empty trims were prevention rather than error. Since 54.9% of arm-1 trims are expected to find nothing, and extra trimming costs about \$19 per lame cow, **this distinction moves the economic verdict by roughly the entire extra-trimming cost.**

### What the pilot already puts on the ledger

Acting on alerts means **trimming more cows**. In the pilot the trimmed arm was trimmed 90.4% of the time against the control arm's 49.8% — about **one extra trim per lame cow** — and 54.9% of those trims found no lesion.

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

Stated explicitly, since the ledger depends on them:

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

**None of these affect the sample size.** The study is powered on the milk contrast alone (§5); the economic inputs enter only the interpretation, where they convert measured effects into dollars. A reader who disagrees with any of them can substitute their own and the study's precision is unchanged — which is the main practical argument for not powering on the economics.

------------------------------------------------------------------------

## 4. Outcomes

### Primary

**Daily milk production, arm 1 versus arm 3**, from 14 days before the alert to 90 days after, indexed to days since alert and normalised to each cow's own pre-alert baseline.

The pre-alert period is included both as the normalising baseline and because the pre-alert slope shows how much production was already lost before the camera fired.

*Why arm 1 v 3 only:* this contrast is insensitive to the measurement window (2,982 to 3,228 cows from 28 to 180 days) and is the only milk comparison powerable at a realistic size. Arm 1 v 2 on milk reaches 43% power at 6,000 cows over 60 days.

### Secondary

**1. Cure at a standardised recheck — white line and sole ulcer. Primary comparison: arm 1 versus arm 2.**

Cure is read from the follow-up trim coming back trim-only. There is no hoof recheck event in this herd's data (`RECK` is reproductive), so the study must create one: a scheduled re-examination at a fixed interval after treatment.

- **Sized on white line and sole ulcer**, where the baseline is well estimated (49.3% cure at 60 days) and rechecks are already standard practice at 60.2% coverage.
- **Foot rot excluded** — its apparent 15.5% cure rate is a recording artifact. 60% of its "non-cures" fall within 7 days and 46% are re-coded foot rot, consistent with the trimmer recording the lesion and staff recording the treatment separately.
- **A minimum 14-day gap applies to foot rot only.** White line and sole ulcer show no early clustering (10–11% within a week, medians of 29–35 days), so their early returns are genuine failures and must be counted.
- **DD collected opportunistically**, not by standardised recheck, which is not feasible on farm.

**Why arms 1 and 2 carry this outcome.** Both are trimmed by protocol, so cure is measured on the same population in each and the comparison is clean by construction. It is also the clinically important question: **does a lesion left for four weeks still heal as well?** That is what a farm is really deciding when it weighs a responsive protocol against a scheduled one.

**Arm 3 is reported too, with its caveat stated.** In arm 3 only cows the farm catches are trimmed, so cure there is measured on **farm-detected lesions**, which may be more severe because they were noticed. The pilot cannot settle whether that matters — among control cows, cure was 14.7% (n = 34) in staff-detected against 18.2% (n = 11) in routine-detected, p = 1.0, an interval that spans everything of interest. So:

- **Record how every arm-3 cow came to be trimmed** — staff `CHKLAME` or routine round — and report cure separately by route. Routine-round cows are the closer analogue to a protocol trim, since the routine round is not triggered by anyone noticing her.
- Present arm 3's cure as **descriptive, not as an unbiased treatment contrast.**

**One dilution to note on the 1-versus-2 comparison.** About a third of arm 2 is treated before its protocol week, by staff or the routine round. The design detects a **10.5-point** observed difference; among cows who actually waited the four weeks that corresponds to roughly a **16-point** true difference. Both figures should be reported, alongside the per-protocol analysis.

**2. Lesion prevalence at the routine dry-off trim.**

Every cow is trimmed around dry-off regardless of arm, which makes this the one lesion measure not confounded by inspection rate. Verified: dry-off trim coverage was **88.6% in Control against 92.7% in TX, p = 0.62**.

- **It is a window, not a day.** Trims cluster 21 to 7 days *before* dry-off; a ±7-day definition catches only 9.6% of them, −45 to +7 catches about 90%.
- **Restricted to cows with at least 90 days between alert and dry-off**, which retains 66% of alerted cows. The third excluded are those alerted late in lactation — a selection on DIM, so report DIM at alert for retained and excluded groups.

**3. Culling, followed for 365 days.**

Not six months. The lameness–culling gap widens with the window and has not flattened at six:

| Window       | No early lesion | Early lesion | Gap      |
|--------------|-----------------|--------------|----------|
| 90 days      | 28.1%           | 33.0%        | +4.9     |
| 180 days     | 34.0%           | 40.8%        | +6.8     |
| **365 days** | **45.0%**       | **52.3%**    | **+7.3** |

The pilot's own three-month figure had the *wrong sign* — lame cows culled less — which is what a window shorter than the process produces.

**4. Recurrence within 365 days** of a first lesion, counting only lesions 14+ days later. Baseline 48.7%.

### Not outcomes

- **Reproduction.** The herd's records show nothing: median days to first service 77 versus 78, services 1.93 versus 1.94, and lesion cows marginally *more* likely to conceive. No effect size to power against.
- **Lesion severity.** Not standardisable across farms and trimmers; between-observer variation would swamp the treatment effect.
- **Detection sensitivity.** Not estimable from an alert-triggered cohort at any sample size.

------------------------------------------------------------------------

## 5. Sample size

**Target: 6,000 cows enrolled across three arms.**

Powered on the primary milk contrast, at 80% power and two-sided α = 0.05, using variance components measured from the pilot (between-cow SD 9.39 kg, weekly residual SD 4.79 kg on weekly averages after adjusting for the lactation curve, parity and history):

+-----------------------------+----------------+----------------+-------------------------------------------+
| Observed arm-1-v-3 contrast | Per arm        | Three arms     | With ×1.28 attrition, ×1.09 heterogeneity |
+=============================+================+================+===========================================+
| 0.8 kg/day                  | 2,226          | 6,678          | 9,400                                     |
+-----------------------------+----------------+----------------+-------------------------------------------+
| **1.0 kg/day**              | **1,425**      | **4,275**      | **6,000**                                 |
+-----------------------------+----------------+----------------+-------------------------------------------+
| 1.2 kg/day                  | 989            | 2,967          | 4,200                                     |
+-----------------------------+----------------+----------------+-------------------------------------------+

**1.0 kg/day is the realistic target.** The three-arm simulation, with farm detection parameterised from the pilot, gives an observed arm-1-v-3 contrast of 1.01 kg for a 1.5 kg true treatment effect — and the pilot's own observed 1.05 kg implies a true effect near 1.5 kg once its 49.8%-trimmed control arm is accounted for.

**Attrition is ×1.28**, driven more by drying off (15.8% by day 90) than by culling (6.2%).

### What each herd supplies

At 6,000 enrolled that is **1,000 alerted cows per herd** across six, or 1,500 across four.

Participating herds are expected to run **2,000 to 5,000 cows**. At the pilot farm's alert rate of about 0.020 per cow per week:

+----------------+-----------------+--------------------------+----------------------+
| Herd size      | Alerts per week | **6 herds** (1,000 each) | 4 herds (1,500 each) |
+================+=================+==========================+======================+
| 2,000 cows     | 40              | **25 weeks**             | 37 weeks             |
+----------------+-----------------+--------------------------+----------------------+
| 3,000 cows     | 60              | **17 weeks**             | 25 weeks             |
+----------------+-----------------+--------------------------+----------------------+
| 5,000 cows     | 100             | **10 weeks**             | 15 weeks             |
+----------------+-----------------+--------------------------+----------------------+

**So enrolment closes in roughly three to six months, not a year.**

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

**The 365-day culling follow-up is what sets the duration, not recruitment.** That is worth stating plainly, because the instinct is to assume a six-herd study takes longer than a smaller one. It does not: more herds shorten the enrolment phase, and the follow-up window is fixed regardless. Six herds of 2,000–5,000 cows finish enrolment sooner than four would, and both are dominated by the year of follow-up.

Shortening the follow-up to six months would cut the study to 9–12 months, but at the cost of the culling outcome: the lameness–culling gap is still widening at six months (6.8 points against 7.3 at twelve), so a six-month endpoint understates the effect the economics depends on.

**Herd heterogeneity is ×1.09** at the 0.25 kg planning value, not a cluster design effect. Randomisation is *within* herd, so herd is a blocking factor and blocking *removes* between-herd variance. The `1 + (m−1)·ICC` inflation applies to studies that randomise whole herds; this does not.

### What this design detects

Smallest difference detectable at 80% power at 6,000 enrolled (2,000 per arm), after allowing for attrition and herd heterogeneity. Contrasts are arm 1 versus arm 3 except where noted:

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

**Cure is targeted at a 15-point improvement**, which the design detects with 98% power; the 10.5-point figure above is the floor at 80%. Detecting a 10-point difference as the stated target would need about 10,000 enrolled, which is not worth a 65% larger study when milk is the primary endpoint.

**Recurrence and dry-off prevalence come free** at the enrolment the milk contrast requires, and both are detectable at clinically meaningful sizes.

### The limitation, stated up front

**A ±5.2-point interval on culling cannot distinguish the 1.3 points that break-even needs from zero.** No feasible study can: detecting 1.3 points would take on the order of 200,000 cows.

**So this study will *estimate* whether the system pays. It will not *prove* it.** A good estimate with honest uncertainty is what a purchasing decision needs, but it is not a hypothesis test and this proposal does not claim one.

*A composite dollar endpoint was considered as a way around this and rejected: adding a \$1,500 event occurring at 46% imports enough variance to require 43,000 cows. The composite is the right thing to report and the wrong thing to power on.*

------------------------------------------------------------------------

## 6. Analysis

**Milk.** Mixed linear model on weekly averages: arm, DIM spline, lactation group, lesion history, breed, herd as fixed effects; cow random intercept. **Arm enters as a main effect.** The `arm × history` interaction is **estimated and reported, but the study is not powered for it** — see below.

**Cure and lesion at dry-off.** Mixed logistic, same covariates, herd random effect.

### The chronicity interaction: explored, not powered

Chronic cows do worse on both outcomes the pilot can measure: recurrence rises 34% → 48% → 52% across parity, and cure falls from 51.9% in new cows to 45.0% in chronic ones (p = 0.007). Those are **main effects**, and adjusting for them is free. Whether the *treatment benefit* also differs by chronicity is untested — the pilot has no randomised treatment contrast to test it with.

**The study will estimate that interaction and report it with its interval, without being sized for it.** At 6,000 enrolled the interaction term carries a 95% interval of about ±0.83 kg/day against ±0.59 kg for the main effect, so only a large difference between new and chronic cows would reach significance. The estimate is still worth having: it is what would tell a follow-up study whether to target one group.

**If Nedap wants it powered**, the cost is available and it is substantial:

|                           | Explored           | Powered             |
|---------------------------|--------------------|---------------------|
| Milk, 1.0 kg contrast     | **6,000 enrolled** | **12,000 enrolled** |
| Cure, WLD/SU +15 points   | \~3,000            | \~4,700             |
| Accrual at 69 alerts/week | 87 farm-weeks      | 174 farm-weeks      |

Milk binds in both cases. Powering the interaction is **2.0× the study** — roughly two years of accrual across four herds rather than one — because the reported coefficient becomes a within-stratum effect estimated from half the cows. Verified rather than assumed: the penalty is exactly 2.00× on the linear milk model and 1.59× on the logistic cure model.

**Culling and recurrence.** Time-to-event, same covariates, stratified by herd. Culled cows are a competing risk for recurrence, not an attrition adjustment.

**Staggered entry.** Censor explicitly. Do not restrict to cows with complete follow-up — that selects the earliest-enrolled and is the trap the pilot's day-30 milk figures fell into.

**Record separately, because only one is standardisable:** staff `CHKLAME` detections and routine-round trims. They differ threefold in median time-to-trim (7 versus 23 days) and routine coverage is the herd-varying nuisance.

**Pre-specify before enrolment opens** — each of these moved answers materially in the pilot:

- The alert-to-lesion window that counts as caught in time, and how a cow alerted *outside* it is treated. In the pilot, 21 days versus unbounded moved the control miss rate from 27.9% to 11.5%.
- That the import runs about 05:00 and stamps the load date, so an attention after 05:00 on day D appears as D+1.
- That alerts landing 1–7 days after a trim are mostly the camera reacting to the trimmed cow.
- That "trimmed" means `LAME` + `FOOTRIM` + `TRIM`, never a subset.

------------------------------------------------------------------------

## 7. What we need from Nedap

1.  **Score at flag, in the export.** Its absence left 69 pilot cases permanently unjudgeable, because a `Low` flag on a cow outside the enrollment score range who was correctly declined is indistinguishable from a lost flag.

2.  **The daily file-in log, or independent instrumentation of the integration.** In the pilot, **119 of 313** apparent misses were cows the camera *did* flag whose alert never reached DairyComp. Logging every raw flag with a timestamp, independent of the import, removes this entirely.

Without these the study measures the camera and the integration together and cannot separate them, which is what happened in the pilot.

------------------------------------------------------------------------

## 8. Decisions taken

**Settled:** randomisation is **blocked on chronicity and lactation group**, and the chronicity interaction is **explored, not powered**. The cost of powering it is given in §6 should Nedap want it: 12,000 enrolled rather than 6,000.

**Settled:** **six herds** across three regions, two each, with four as a stated minimum. Six is the right count for a geographically spread study, not merely a convenient one — see §2 and §5.

**Settled:** the **economic inputs are stated assumptions**, listed in §3. They do not affect the sample size, since the study is powered on milk, so a reader who prefers different figures can substitute them without changing the study's precision.

**Settled:** cure is targeted at **+15 points**. §5 states what the design detects on every outcome rather than only the powered one.

**Settled:** the **cure comparison is primarily arms 1 versus 2**, where both arms are protocol-trimmed and the contrast is clean. Arm 3 is reported with its selection caveat stated and its detection route recorded. This is the clinically important question — does a lesion left four weeks still heal as well — and it is also the timing question the three-arm design exists to answer.

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
