# Proposal review, 2026-09-10

An independent reviewer went through `proposal_nedap_3arm_draft.md` against the
scripts in `scripts/proposal/`. **Its findings were not taken on trust** — the
consequential ones were re-derived here, and this document records which
survived. Two did not get applied because they change the study's conclusion or
its size, and those are Gerard's calls.

------------------------------------------------------------------------

## TWO OPEN DECISIONS

### D1. The ledger mixes denominators, and fixing it reverses its headline

**Verified.** The §3 ledger is labelled *per lame cow*. Two rows honour that:

- Camera `$28.78` = `$0.65 x 12 / 0.271` — cost per cow-year over **new lesion
  cases** per cow-year. Correct.
- Extra trimming `$19.40` = `0.97 x $20`, and `p15` derives the 0.97 by scaling
  alerted cows to lame cows (`x2.40`). Correct.

The milk row does not. `1.05 kg x 90 d x $0.254 = $24.00` is the benefit **per
alerted cow**, because `fxn_build_q1()` (functions/fxn_nedlame_analysis.R:451)
applies **no lesion filter** — the 1.05 kg contrast is measured over the whole
alerted cohort. Confirmed by reading the function.

Applying the same `x2.40` the trim row uses:

| Per lame cow | Draft | Corrected |
|---|---:|---:|
| Milk at 1.05 kg over 90 d | $24.00 | **$57.66** |
| Milk at 1.50 kg over 90 d | $34.29 | **$82.37** |

Per 1,000 cows per year: 651 alerts x $24.00 = **$15,624** of milk against
$7,800 camera + $5,258 extra trims = **$13,058**. Net **+$2,566**, not the
shortfall the draft reports.

**So "Milk alone does not cover the cost" is not supported by the ledger as
computed**, and "0.9 to 1.5 percentage points of avoided culling would close it"
has nothing to close. That sentence is load-bearing: it justifies the 365-day
culling follow-up and the "estimates but cannot prove" framing in §5.

**But the correction is not simply good news.** The 1.05 kg was measured at
**days 25-30** of a 30-day window and is extrapolated flat across 90 days. Over
30 days the milk benefit is $5,208 per 1,000 cows and the system loses. So the
ledger is wrong in one direction on the denominator and optimistic in the other
on the window.

**The honest position is that the sign is unresolved**, which is a different and
more defensible thing to say than either "it does not pay" or "it does". It also
changes what the study is for: from *finding the culling benefit that rescues a
losing case* to *resolving a genuinely open question*. That is a better proposal
and a more fundable one, but it is a change of argument, not a number.

**Decision needed:** how to present it. Recommend stating both the corrected
denominator and the window caveat, and letting the conclusion be "unresolved".

### D2. The study may be sized on the wrong variance, by a factor of about two

**Verified by refitting on the pilot data** (`scripts/proposal/v01` equivalent,
826 cows, 3,599 post-alert weekly records):

| Model | Between-cow SD | Var of a 9-week mean | n/arm at 1.0 kg | Enrolled |
|---|---:|---:|---:|---:|
| **A. As `p01` fits it — no baseline term** | 9.58 | 94.2 | 1,479 | **6,200** |
| **B. Plus the cow's own pre-alert baseline** | 5.57 | 33.5 | 526 | **2,300** |
| **C. Outcome as change from baseline** | 6.54 | 45.2 | 710 | **3,000** |

Cow-level correlation between pre-alert baseline and post-alert mean is
**r = 0.845**. Model A reproduces the planning figure the draft uses.

The problem: **§4 defines the outcome as "normalised to each cow's own pre-alert
baseline"** and the pilot itself measured it that way (`pct_of_baseline`), but
the planning variance comes from a model with no baseline term, and §6's model
omits one too. All three disagree with each other.

If the trial adjusts for pre-alert baseline — which it should, and which §4
already says it will — **a 1.0 kg contrast needs roughly 2,300-3,000 enrolled,
not 6,000.**

**The caveat that stops this being a free win.** This was measured over days
1-30, the only window the pilot has. The trial's primary window is 90 days, and
the correlation between a 7-day baseline and milk at day 90 will be weaker than
at day 30. The true gain sits somewhere between model A and model B, and **the
pilot cannot say where**, because it has no 90-day follow-up.

**A second consequence:** if milk falls to ~3,000, milk stops being the binding
outcome. Cure (~3,000) and recurrence (~3,700) become binding, and the design
total lands nearer 4,000 than 6,000. The whole sizing section needs re-deriving,
not patching.

**Decision needed:** whether to re-size. Options are (a) keep 6,000 and justify
it as conservative against baseline-correlation decay, (b) re-size on a
conservative interpolation, (c) re-size on model C and make recurrence the
binding outcome. **(a) is defensible and cheapest to write; (b) is the most
honest; (c) is the most efficient study.**

------------------------------------------------------------------------

## APPLIED

- **§6 accrual arithmetic.** "Roughly two years of accrual across four herds
  rather than one" was wrong — 174 farm-weeks across four herds in parallel is
  43.5 weeks, not two years. Now "about 29 weeks across six herds rather than
  15", which also stops it reverting to four herds after §2 and §8 settled six.
  Fixed in the draft and in `p14`.

------------------------------------------------------------------------

## VERIFIED, NOT YET APPLIED

Held because D1 and D2 move the same tables.

1. **`p12` mixes inflated and uninflated bases.** The milk row divides by
   `1.28 x 1.09`; every other row uses the raw 2,000 per arm. A design cannot
   have both 1,433 and 2,000 analysable cows per arm. On a consistent 1,433:
   cure becomes 12.4 points (not 10.5), dry-off 5.7 (not 4.9). On a consistent
   2,000, milk becomes 0.84 kg. **Confirmed by reading `p12`.**
2. **`p14`'s intervals use 2,000/arm uninflated** while §5's detectable
   differences use 1,433. A reader checking §5's 1.00 kg against §6's +/-0.59 kg
   finds they cannot both hold. Same defect, different section.
3. **Trim price is $18 in the assumptions table and $20 in the ledger.** At $18
   the ledger rows become $17.46 / $46.24 / $52.88. Entangled with D1.
4. **§5's "1.3 points" descends from a superseded $1,500 net cull value.** At
   the settled $1,650 it is 1.21 points. §3 already quotes the correct range.
5. **The dry-off row ignores the ~90% coverage the same section verifies**
   (88.6%/92.7%), and its 4.9 points assumes a 30% baseline that appears nowhere
   else, unlike every other row which states its baseline.

------------------------------------------------------------------------

## THE BEST STRUCTURAL POINT THE REVIEWER MADE

**§6's model cannot express the heterogeneity §5 inflates for.** The stated
model is "arm, DIM spline, lactation group, lesion history, breed, **herd as
fixed effects**; cow random intercept" — there is no `arm | herd` random slope.
A model with herd fixed and no arm-by-herd term produces a standard error that
ignores tau entirely. The study would inflate by `x1.09` to protect against
heterogeneity and then analyse it with a model that cannot see it.

**Either §6 needs `(1 + arm | herd)` — or a two-stage per-herd estimate pooled
by random effects — or the `x1.09` in §5 is decorative.** This is correct and is
a one-line fix to §6. Recommend applying it.

------------------------------------------------------------------------

## JUDGEMENT CALLS WORTH READING

- **Conditioning on "cows with a lesion" is a collider.** §5 sizes recurrence and
  culling on 2,000 x 0.35 = 700 per arm. But 0.35 is a property of the *trimmed*
  arm: arm 1 trims 90.4% of cows and finds lesions in 35%; arm 3 trims 49.8% so
  finds them in ~19%. Restricting to cows with a found lesion conditions on a
  post-randomisation variable the treatment causes. §4 is careful about exactly
  this for cure and demotes arm 3 to descriptive; §5 then does it anyway for
  recurrence and culling. **Culling should be ITT on all enrolled** — 4.4 points
  detectable at 2,000/arm against 7.5 on the conditioned subset, and unbiased.
- **§5's corroboration of the 1.0 kg target is circular.** The simulation maps a
  1.5 kg true effect to a 1.01 kg observed contrast; the draft then maps the
  pilot's 1.05 kg back to 1.5 kg by inverting the same model and presents the two
  as independent confirmations. The working document (lines 422, 983) already
  retracted this: **arm 3 is what the pilot's control arm was, so the pilot's
  1.05 kg *is* the arm-1-v-3 quantity.** Simpler and not circular.
- **The accrual rate is a start-up rate.** 69 alerts/week is the first-alert rate
  over the camera's first 97 days, which drains the herd's prevalent pool of lame
  cows. `p08`'s own hazard estimate implies a steady-state rate 1.6x lower.
  Enrolment closing in "three to six months" becomes four to nine.
- **Low-routine-trimming eligibility trades away external validity.** If arm 3 is
  trimmed 10% rather than 50%, the trial measures acting-versus-nearly-nothing,
  which is a bigger effect and **not the decision a commercial farm faces** —
  which is the decision the title asks about.
- **The culling ledger treats an association as recoverable.** The 7.3 points is
  observational: lame cows leave more partly because they are older and lower
  producing, which a trim does not change. The pilot work is scrupulous about
  exactly this failure mode ("58 extra lesions is ascertainment"), so the
  omission stands out.
- **Arm 1 v 2 on milk over 0-28 days needs only ~1,967 cows** per the working
  document, comfortably inside the design. §3 says arm 1 v 2 is the operational
  question a farm faces; §4 then declines to measure it on the primary outcome.

------------------------------------------------------------------------

## CHECKED AND CORRECT

Stated so nobody re-spends effort: the within-herd blocking argument; all nine
cells of the §2 heterogeneity table, and the 8,200 / 10,800 figures; the 2.00x
linear and 1.59x logistic interaction multipliers; attrition `x1.28`; the §5
sizing table; the culling-window table and the reproduction null; the +/-5.2
culling interval and the ~200,000-cow figure; week 1 at 31.1%, weeks 1-4 at
65.8%, and a third of arm 2 caught early; cure at 15 points reaching 98% power.

------------------------------------------------------------------------

## FROM THE PILOT SIDE, AND RESOLVED

The other session split the headline miss rate: cohort 31/291 = **10.7%**, never-enrolled 282/288 = **97.9%**, pooled 313/579 = 54.1%. **54.1% is the wrong figure to carry into the proposal.** The draft never quoted it as a headline, but two figures descended from the pooled definition and both were chased down.

### The 119, resolved - and the answer reframes the ask

The pipeline losses split by population, and the two populations fail differently:

| | Flagged, no alert | Never flagged | Genuine losses |
|---|---:|---:|---:|
| Never enrolled | 107 | 175 | **9** |
| Pilot cohort | 12 | 19 | **2** |
| Pooled | 119 | 194 | 11 |

By design, never enrolled: 35 FTDAT + 12 upper-leg + 5 late + 46 cannot-tell + 9 genuine. Cohort: 4 + 1 + 0 + 5 + 2. Both sum; the population totals reconcile to 282 and 31.

**Quoting "119 apparent misses" overstates the cohort integration problem roughly tenfold** - but narrowing it to "2 confirmed losses" would understate the real one, because the serious failure is in the other population. In the cohort, a dropped re-alert hits a cow already being watched. Among the never enrolled, **9 cows met the enrolment criteria and never entered the study**, which is invisible from inside DairyComp - she simply never appears. It was only detectable because the raw attention export could be checked against the imported record.

**APPLIED.** §7 now carries the split and the reframing. The ask to Nedap is no longer "you lost 119 alerts" but "nine cows met your own enrolment criteria and your pipeline never enrolled them" - a design risk to a trial that depends on enrolment working, not a pilot curiosity. Both genuine-loss counts are stated as **floors**, because the cannot-tell cases are `Low`-only where score at flag is missing, which is exactly what ask 1 requests. The two asks are now linked rather than listed.

**Also resolved, and it produced a better number than either of the originals.** The 27.9% / 11.5% figures were rechecked against current data and are exactly right — control n=122 splits 88 caught / 20 alerted-earlier-no-action / 14 missed, so 34/122 against 14/122, and the whole 16-point gap is those 20 cows. **But the figure that matters is the contrast, not the levels:** the same choice moved control minus trimmed from **15.4 points to 1.4**, a 14-point swing, because the control arm had twenty such cows and the trimmed arm four. The same cows over the same window support either “control misses fifteen points more” or “the arms are within a point and a half”, and the choice was made after seeing the data. That swing is comparable to the 15-point cure effect this study is powered for. §6 now states it as a structural property of the design rather than a pilot anecdote: **wherever one arm is obliged to act and another is not, a cow alerted and never examined is an outcome in the first and a protocol deviation in the second**, so the three-arm design inherits the exposure directly through arm 3.


------------------------------------------------------------------------

## A JUSTIFICATION THAT DID NOT HOLD (2026-09-11)

Commit `d40cca3` justified the strictly-before alert window with "no attention in the whole export occurs before 05:00 local and 84% are 18:00-24:00". **Both halves are wrong**, verified here directly against `data/nedap_attentions_2026-08-27.csv` (40,193 rows, UTC converted to America/Chicago as the loader does):

| Claim | Actual |
|---|---|
| No attention before 05:00 | **15.4%** are (6,177 of 40,193) |
| 84% fall in 18:00-24:00 | **25.5%** do |

The hour histogram is close to flat — hourly counts run 836 to 2,302 across all 24 hours. Attentions are not an evening phenomenon.

**The change itself stands; only its stated basis was wrong.** The other session bounded the exposure at **2 cases out of 194**: 74 lesion cases have an attention on the lesion day, 13 of those have no earlier attention in the window, and 2 of those had the same-day attention before 05:00.

**The defensible argument is the modal lag**, which does not depend on time of day: matching each alert to the attention that produced it gives lag 0 for 425 and lag 1 for 896, so **68% are stamped at least a day after detection**. §6 now says that instead.

**And it carries a protocol requirement into the proposal.** Adding `EDAY=LMSFD` to the `ENTER` command stamps the camera's detection date rather than the command's run date, which removes this whole line of reasoning. §6 now states it as a precondition rather than a nice-to-have — the 68% is the argument for it, and it cannot be reconstructed after the fact.


## A SECOND PROTOCOL REQUIREMENT: STALE LACTATION AT DIM 0 (2026-09-11)

From a DairyComp log: cow 22408's `NEDLAME` was written at 05:32 and her `FRESH` was not keyed in until 07:26, so the alert carries the previous lactation. Not a DairyComp fault — the command used what existed when it ran.

**Verified independently** (`scripts/proposal/p34_stale_lactation_check.R`), comparing each `NEDLAME`'s own `lact_number` against the lactation resolved by date:

| | |
|---|---|
| NEDLAME events resolvable to a lactation | 1,608 |
| Events whose lactation number is stale | **3**, in 3 distinct cows |
| DIM at those events | 0, 0, 1 — all inside the calving window |
| **Alerts at DIM 0-1 overall** | **8** |
| **So the rate where it can happen at all** | **3 of 8** |

Cows 21648, 22408 and 9616; the last two are the pair from the log. **The 3-in-1,608 framing understates it.** The exposure is not 0.19% of alerts, it is more than a third of alerts in the calving window — and a three-arm trial enrolling at the alert will put cows through that window continuously.

**Why it is worse in a trial than it was here.** The pilot resolves lactation by date and is unaffected. But lactation group is a **randomisation block**, so a cow allocated on a stale lactation is enrolled into the wrong stratum, and an allocation error cannot be repaired by analysis. §6 now carries it alongside `EDAY=LMSFD`, with both remedies and Gerard's inference that **an attention is itself evidence the cow has calved**, because the camera only sees her once she is in the milking string.


## SUPERSEDED: THE 12/107 SPLIT (2026-09-11)

The other session rebuilt the miss section so cohort membership is judged AT THE LESION rather than across the whole study, which removed a look-ahead bias: cohort 291 - cases. Under that definition **all 119 pipeline losses fall among the never-enrolled and none in the cohort**, so the 12/107 and 9/2 splits written into section 7 earlier today are superseded.

**The correction strengthens the ask rather than weakening it.** There are not two failure modes; there is one. A lost alert is precisely what prevents enrolment, so the failure and its consequence are the same event - which is why the cohort figure is zero. Section 7 now says that, and states the confirmed-genuine count as a floor without a number pending re-confirmation under the new definition.

**A standing habit worth keeping, since the denominator was the finding twice in one day:** when a rate looks reassuringly small, check whether its denominator includes cases where the failure was structurally impossible. Added to the pre-specification list in section 6, using the stale-lactation example - 0.19% of all alerts against 37% of alerts in the calving window.

## A THIRD PROTOCOL REQUIREMENT: SAVE THE TRIM LIST (2026-09-11)

Gerard: print or save the farm's trim list on every trim day. The reasoning is that a trim event is a record of execution and the list is a record of intent, and the pilot only has the first.

**I tried to size the gap with `CHKLAME` and the result argued against my framing, which turned out to be the useful part** (`scripts/proposal/p36_trim_list_gap.R`). Staff checks convert to trims almost automatically: 82.5% within one day, 92.0% within a week, 96.6% within two, median gap **1 day**, only 5 of 3,634 never trimmed.

So `CHKLAME` is **not a trim list**. At this farm it is recorded at the trim, documenting something that happened rather than a cow who was booked. **The pilot has no prospective record of intent at all** — which is the argument for capturing one, not against it. The quantity we want (how often a cow meant to be trimmed was not) is precisely the quantity this data cannot see, and the 3.4% that did not convert inside two weeks is a floor on it rather than an estimate.

Added to §6 with the trial-specific reason: **compliance is an outcome**. “Not trimmed within a week” is the protocol failing if she was never listed, and an execution miss if she was listed and not caught — only the first is about the system under test. It also gives §4's arm-3 route recording directly, as a row rather than an inference from event codes.

