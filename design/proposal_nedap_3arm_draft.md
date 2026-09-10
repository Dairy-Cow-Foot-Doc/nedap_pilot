# Does it pay to use Nedap SmartSight?

## A proposal for a three-arm randomised trial

**Draft 2 — 2026-09-10.** Consolidated from the working document (`proposal_nedap_3arm.md`), which retains the derivations, the checks and the corrections behind every figure here. Every number attributed to the pilot is computed from its data.

---

## 1. The question

**Does acting on SmartSight alerts leave a commercial dairy better off, and by enough to pay for the system?**

Detection accuracy is not the question. The pilot establishes that the camera works after a fashion — of 579 lesion cases it flagged 240 in time and missed 194 outright, with a known blind spot in digital dermatitis. Measuring that more precisely needs a reference standard and a different design, and it is not what a farm deciding whether to buy is asking.

Two comparisons serve the question:

| | Comparison | Answers |
|---|---|---|
| **Primary** | Arm 1 v arm 3 | Does acting on alerts pay? |
| **Secondary** | Arm 1 v arm 2 | Does acting *quickly* pay — and is the responsive protocol worth its cost? |

### What the pilot already puts on the ledger

Acting on alerts means **trimming more cows**. In the pilot the trimmed arm was trimmed 90.4% of the time against the control arm's 49.8% — about **one extra trim per lame cow** — and 54.9% of those trims found no lesion.

Per lame cow, with the break-even calculator's own IOFC of $0.254/kg:

| | $0.65/cow/month | $0.80/cow/month |
|---|---|---|
| Camera | $28.78 | $35.42 |
| Extra trimming at $20 | $19.40 | $19.40 |
| **Total to recover** | **$48.18** | **$54.82** |
| Milk supplies, at 1.05–1.5 kg over 90 days | $24–34 | $24–34 |
| **Shortfall** | **$14–24** | **$21–31** |

**Milk alone does not cover the cost.** The shortfall is what culling, recurrence and treatment labour must close — and at $1,500 net per cull avoided, roughly **1.3 percentage points of avoided culling** would close it.

---

## 2. Design

Randomised controlled trial, **three arms**, **365-day follow-up**, **six herds** across three regions - two each in New York, South Dakota/Kansas and the West Coast. **Four herds is the minimum**; §5 gives what that costs.

### Enrolment

A cow enters **at her first SmartSight alert** and is randomised at that moment, in **blocks by lameness history (new / chronic) and lactation group (1 / 2 / 3+)**. Blocking balances the arms on the two covariates most likely to modify the effect, costs nothing, and improves precision on the main comparison.

Enrolling at freshening instead was considered and rejected. It does not change the treatment contrast — cows are still only treated when alerted — so it buys nothing for these outcomes, at ×1.6 the cows and roughly double the calendar time. It would only earn that if detection accuracy were a study question, and it is not.

### Arms

All three sit on a common floor: **if farm staff identify a cow as lame she is trimmed, regardless of arm.** This is not negotiable.

| Arm | Protocol |
|---|---|
| **1. Early** | Trim chute within **1 week** of the alert. |
| **2. Delayed** | Trim chute at **4 weeks** — or sooner if the routine round or staff reach her first. She is not held back. |
| **3. Farm practice** | Alerted and recorded, not acted on. Treated only if staff or the routine round catch her. |

**Arm 3 is regular farm practice, not an untreated arm.** In the pilot the equivalent group was trimmed 49.8% of the time, mostly by the routine round.

**Arm 2 is contaminated by design and that must be handled.** Farm detection is heavily front-loaded — 66% of catches land inside four weeks, and week 1 alone is 31% — so about a third of arm 2 will be treated before its protocol week. Record each cow's **actual** treatment date; pre-specify a per-protocol analysis alongside intention-to-treat.

**Why arm 2 exists.** A cow trimmed in arm 1 with no lesion found is unidentifiable from the trim alone: she is either a camera false positive or a true positive whose lesion was prevented. **Arm 2 separates them**, and the answer moves the ledger by up to $19 per lame cow — the entire extra-trimming cost.

### Eligibility

**Herds**

**Six herds, three regions.** Two each in NY, SD/KS and the West Coast, run by collaborating investigators. Four is a workable minimum.

**The geographic spread cuts both ways and the herd count is the answer to it.** Herds in different regions differ in housing, flooring, climate and trimming practice, which raises the between-herd variation in the treatment effect - the thing herd count protects against. Six herds is the right response to that spread, not a reason to narrow it:

| Between-herd SD of the effect | 4 herds | **6 herds** | 10 herds |
|---|---|---|---|
| 0.25 kg | ×1.24 | **×1.16** | ×1.09 |
| 0.50 kg | ×1.96 | **×1.49** | ×1.24 |
| 0.75 kg | *no n suffices* | **×3.78** | ×1.79 |

At a plausible 0.5 kg between-herd SD, six herds costs ×1.49 against four herds' ×1.96 - **a quarter less**. At 0.75 kg, four herds cannot deliver the target at any sample size and six still can. **Herds are cheaper insurance than cows.**


- **Reliable** hoof trimming data — complete and consistently coded, checkable before enrolment.
- **Low routine-trimming frequency.** Power on the primary contrast more than doubles between a herd that trims routinely at 10% and one at 60% (75% versus 33% at identical enrolment). This is a bigger lever than sample size and is visible in existing records.
- Trained trimming staff; daily milk weights; able to run SmartSight.

**Cows**

**No lameness-history restriction.** Excluding cows treated in the current lactation would remove 38.7% of the herd — but unevenly: **54.8% of lactation 3+ against 15.8% of first lactation**, skewing the study young, away from the cows the system is sold to manage. Handle history by stratifying randomisation on it and adjusting in every model.

---

## 3. Outcomes

### Primary

**Daily milk production, arm 1 versus arm 3**, from 14 days before the alert to 90 days after, indexed to days since alert and normalised to each cow's own pre-alert baseline.

The pre-alert period is included both as the normalising baseline and because the pre-alert slope shows how much production was already lost before the camera fired.

*Why arm 1 v 3 only:* this contrast is insensitive to the measurement window (2,982 to 3,228 cows from 28 to 180 days) and is the only milk comparison powerable at a realistic size. Arm 1 v 2 on milk reaches 43% power at 6,000 cows over 60 days.

### Secondary

**1. Cure at a standardised recheck — white line and sole ulcer.**

Cure is read from the follow-up trim coming back trim-only. There is no hoof recheck event in this herd's data (`RECK` is reproductive), so the study must create one: a scheduled re-examination at a fixed interval after treatment.

- **Sized on white line and sole ulcer**, where the baseline is well estimated (49.3% cure at 60 days) and rechecks are already standard practice at 60.2% coverage.
- **Foot rot excluded** — its apparent 15.5% cure rate is a recording artifact. 60% of its "non-cures" fall within 7 days and 46% are re-coded foot rot, consistent with the trimmer recording the lesion and staff recording the treatment separately.
- **A minimum 14-day gap applies to foot rot only.** White line and sole ulcer show no early clustering (10–11% within a week, medians of 29–35 days), so their early returns are genuine failures and must be counted.
- **DD collected opportunistically**, not by standardised recheck, which is not feasible on farm.

**2. Lesion prevalence at the routine dry-off trim.**

Every cow is trimmed around dry-off regardless of arm, which makes this the one lesion measure not confounded by inspection rate. Verified: dry-off trim coverage was **88.6% in Control against 92.7% in TX, p = 0.62**.

- **It is a window, not a day.** Trims cluster 21 to 7 days *before* dry-off; a ±7-day definition catches only 9.6% of them, −45 to +7 catches about 90%.
- **Restricted to cows with at least 90 days between alert and dry-off**, which retains 66% of alerted cows. The third excluded are those alerted late in lactation — a selection on DIM, so report DIM at alert for retained and excluded groups.

**3. Culling, followed for 365 days.**

Not six months. The lameness–culling gap widens with the window and has not flattened at six:

| Window | No early lesion | Early lesion | Gap |
|---|---|---|---|
| 90 days | 28.1% | 33.0% | +4.9 |
| 180 days | 34.0% | 40.8% | +6.8 |
| **365 days** | **45.0%** | **52.3%** | **+7.3** |

The pilot's own three-month figure had the *wrong sign* — lame cows culled less — which is what a window shorter than the process produces.

**4. Recurrence within 365 days** of a first lesion, counting only lesions 14+ days later. Baseline 48.7%.

### Not outcomes

- **Reproduction.** The herd's records show nothing: median days to first service 77 versus 78, services 1.93 versus 1.94, and lesion cows marginally *more* likely to conceive. No effect size to power against.
- **Lesion severity.** Not standardisable across farms and trimmers; between-observer variation would swamp the treatment effect.
- **Detection sensitivity.** Not estimable from an alert-triggered cohort at any sample size.

---

## 4. Sample size

**Target: 6,000 cows enrolled across three arms.**

Powered on the primary milk contrast, at 80% power and two-sided α = 0.05, using variance components measured from the pilot (between-cow SD 9.39 kg, weekly residual SD 4.79 kg on weekly averages after adjusting for the lactation curve, parity and history):

| Observed arm-1-v-3 contrast | Per arm | Three arms | With ×1.28 attrition, ×1.05 heterogeneity |
|---|---|---|---|
| 0.8 kg/day | 2,286 | 6,858 | 9,200 |
| **1.0 kg/day** | **1,425** | **4,275** | **5,800** |
| 1.2 kg/day | 990 | 2,970 | 4,000 |

**1.0 kg/day is the realistic target.** The three-arm simulation, with farm detection parameterised from the pilot, gives an observed arm-1-v-3 contrast of 1.01 kg for a 1.5 kg true treatment effect — and the pilot's own observed 1.05 kg implies a true effect near 1.5 kg once its 49.8%-trimmed control arm is accounted for.

**Attrition is ×1.28**, driven more by drying off (15.8% by day 90) than by culling (6.2%).

### What each herd supplies

At 6,000 enrolled: **1,000 alerted cows per herd** across six, or 1,500 across four. Accrual time depends on herd size, at the pilot farm's rate of about 0.020 alerts per cow per week:

| Herd size | 6 herds (1,000 each) | 4 herds (1,500 each) |
|---|---|---|
| 1,000 cows | 49 weeks | 74 weeks |
| 2,000 cows | 25 weeks | 37 weeks |
| 3,400 cows | 14 weeks | 22 weeks |

**With six herds even a 1,000-cow farm accrues its share inside a year**, and larger herds finish much sooner - at which point the binding constraint becomes the 365-day follow-up rather than enrolment. That matters for the timeline: with reasonably sized herds the study is roughly six months of accrual plus a year of follow-up, not two years of accrual.


**Herd heterogeneity is ×1.05**, not a cluster design effect. Randomisation is *within* herd, so herd is a blocking factor and blocking *removes* between-herd variance. The `1 + (m−1)·ICC` inflation applies to studies that randomise whole herds; this does not.

### What 6,000 buys on the secondary outcomes

| Outcome | Detectable at 6,000 | 
|---|---|
| **Cure, WLD/SU** | +15 points on a 49.3% baseline at 98% power; +10 points at 75% |
| **Recurrence** | 20% relative reduction on a 48.7% baseline |
| **Lesion prevalence at dry-off** | Two thirds of enrolled cows retained under the 90-day rule |
| **Culling, 365 days** | Estimated with a 95% interval of about ±5.2 points |

### The limitation, stated up front

**A ±5.2-point interval on culling cannot distinguish the 1.3 points that break-even needs from zero.** No feasible study can: detecting 1.3 points would take on the order of 200,000 cows.

**So this study will *estimate* whether the system pays. It will not *prove* it.** A good estimate with honest uncertainty is what a purchasing decision needs, but it is not a hypothesis test and this proposal does not claim one.

*A composite dollar endpoint was considered as a way around this and rejected: adding a $1,500 event occurring at 46% imports enough variance to require 43,000 cows. The composite is the right thing to report and the wrong thing to power on.*

---

## 5. Analysis

**Milk.** Mixed linear model on weekly averages: arm, DIM spline, lactation group, lesion history, breed, herd as fixed effects; cow random intercept. **Arm enters as a main effect.** The `arm x history` interaction is **estimated and reported, but the study is not powered for it** - see below.

**Cure and lesion at dry-off.** Mixed logistic, same covariates, herd random effect.

### The chronicity interaction: explored, not powered

Chronic cows do worse on both outcomes the pilot can measure: recurrence rises 34% -> 48% -> 52% across parity, and cure falls from 51.9% in new cows to 45.0% in chronic ones (p = 0.007). Those are **main effects**, and adjusting for them is free. Whether the *treatment benefit* also differs by chronicity is untested - the pilot has no randomised treatment contrast to test it with.

**The study will estimate that interaction and report it with its interval, without being sized for it.** At 6,000 enrolled the interaction term carries a 95% interval of about +/-0.83 kg/day against +/-0.59 kg for the main effect, so only a large difference between new and chronic cows would reach significance. The estimate is still worth having: it is what would tell a follow-up study whether to target one group.

**If Nedap wants it powered**, the cost is available and it is substantial:

| | Explored | Powered |
|---|---|---|
| Milk, 1.0 kg contrast | **5,800 enrolled** | **11,500 enrolled** |
| Cure, WLD/SU +15 points | ~3,000 | ~4,700 |
| Accrual at 69 alerts/week | 84 farm-weeks | 167 farm-weeks |

Milk binds in both cases. Powering the interaction is **2.0x the study** - roughly two years of accrual across four herds rather than one - because the reported coefficient becomes a within-stratum effect estimated from half the cows. Verified rather than assumed: the penalty is exactly 2.00x on the linear milk model and 1.59x on the logistic cure model.


**Culling and recurrence.** Time-to-event, same covariates, stratified by herd. Culled cows are a competing risk for recurrence, not an attrition adjustment.

**Staggered entry.** Censor explicitly. Do not restrict to cows with complete follow-up — that selects the earliest-enrolled and is the trap the pilot's day-30 milk figures fell into.

**Record separately, because only one is standardisable:** staff `CHKLAME` detections and routine-round trims. They differ threefold in median time-to-trim (7 versus 23 days) and routine coverage is the herd-varying nuisance.

**Pre-specify before enrolment opens** — each of these moved answers materially in the pilot:

- The alert-to-lesion window that counts as caught in time, and how a cow alerted *outside* it is treated. In the pilot, 21 days versus unbounded moved the control miss rate from 27.9% to 11.5%.
- That the import runs about 05:00 and stamps the load date, so an attention after 05:00 on day D appears as D+1.
- That alerts landing 1–7 days after a trim are mostly the camera reacting to the trimmed cow.
- That "trimmed" means `LAME` + `FOOTRIM` + `TRIM`, never a subset.

---

## 6. What we need from Nedap

1. **Score at flag, in the export.** Its absence left 69 pilot cases permanently unjudgeable, because a `Low` flag on a cow outside the enrollment score range who was correctly declined is indistinguishable from a lost flag.

2. **The daily file-in log, or independent instrumentation of the integration.** In the pilot, **119 of 313** apparent misses were cows the camera *did* flag whose alert never reached DairyComp. Logging every raw flag with a timestamp, independent of the import, removes this entirely.

Without these the study measures the camera and the integration together and cannot separate them, which is what happened in the pilot.

---

## 7. Open decisions

**Settled:** randomisation is **blocked on chronicity and lactation group**, and the chronicity interaction is **explored, not powered**. The cost of powering it is given in §5 should Nedap want it: 11,500 enrolled rather than 5,800.

**Settled:** **six herds** across three regions, two each, with four as a stated minimum. Six is the right count for a geographically spread study, not merely a convenient one - see §2 and §5.


| | Decision | Turns on |
|---|---|---|
| 3 | IOFC, cost per trim, replacement cost and cull value **from the participating farms**, not national averages. | The culling term dominates the economics and the answer is sensitive to it. |
| 4 | Cure at +15 points, or +10 for a larger study? | +15 fits inside 6,000; +10 needs about 10,000. |

---

## Appendix: pilot figures used

| Quantity | Value |
|---|---|
| Between-cow SD, weekly milk | 9.39 kg |
| Residual SD, weekly milk | 4.79 kg |
| Observed TX–Control milk contrast | 1.05 kg/day |
| Alerted cows with a lesion found | 35.0% |
| Alerted cows with white line or sole ulcer | 18.3% |
| Cure at 60 days, WLD/SU | 49.3% |
| Recurrence within 365 days | 48.7% |
| New-case lesion incidence | 27.1 per 100 cow-years |
| Extra trims per lame cow | 0.97 |
| Empty-trim rate, trimmed arm | 54.9% |
| Culling gap at 365 days | 7.3 points |
| Alerts per week, pilot farm | 69 |
| Cows alerted per lactation | 62% |
