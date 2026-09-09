# Review findings — 2026-09-08

Two independent review agents checked (a) the new shared-functions refactor for code
and logic defects and (b) the written text of both reports for statistical
misinterpretation.

**Every finding below that is marked ✅ verified I re-checked myself against the code
or data rather than taking the agent's word for it.** Two findings the agents raised
turned out to be non-issues on checking; they are listed at the end so you can see they
were considered.

Nothing here has been fixed. Tick what you want done and I will apply it.

**Priority reading:** items **T1–T6** are the ones that matter most. They are all in
`report_farm_summary.qmd` — the report the farm will act on — and several of them state
things the full report explicitly contradicts.

---

## A. Code — the refactor

### ☐ C1. `cows_smartsight` argument is dead — silently overwritten by a disk read ✅ verified
**`functions/fxn_nedlame_analysis.R`, `fxn_build_enrolled_ids()`**

The signature takes `cows_smartsight`, then the body's third line overwrites it:

```r
fxn_build_enrolled_ids <- function(events_all, cows_smartsight) {
  cows_activity   <- read_csv("data/cows_activity.csv", ...)
  cows_smartsight <- read_csv("data/cows_smartsight.csv", ...)   # <- argument discarded
```

**My bug**, introduced by the extraction: the original chunk did the file reads, and I
lifted the body verbatim without noticing the argument was then shadowed.

Why it matters: the function *looks* parameterised and isn't. Pass it a filtered
enrollment list for a sensitivity run and it will silently return the unfiltered answer.
It is also the only function with a hard-coded relative path, so it breaks outside the
project root.

**Fix:** delete both `read_csv()` lines from the body and use the passed argument. Both
callers already build the objects, so no call-site change is needed. `cows_activity` is
built inside but never returned — drop it from the function entirely.

---

### ☐ C2. `n_never_alerted_bucket` is read from the global environment ✅ verified
**`functions/fxn_nedlame_analysis.R`, `fxn_build_q4_groups()`**

```r
stopifnot(sum(q4_group$detection_group == "Never Alerted") == n_never_alerted_bucket)
```

It is neither an argument nor created in the body. I ran `codetools::findGlobals()` over
all ten functions: this is **the only** real unbound global — everything else flagged was
a tidyverse column name.

It works today only because knitr evaluates chunks in `globalenv()` and `list2env()`
deposits it there. It breaks if anyone renders via `rmarkdown::render(envir = new.env())`,
wraps the pipeline in a driver function, or calls the function on a subset of `q4` — and
that last case is the nasty one: it would compare a subset count against a stale
full-cohort count and abort with a message that reads like the detection labels have
drifted.

**Fix (recommended):** hoist the `detection_group` mutate into `fxn_build_q4()`, which
already computes the counter, and have `fxn_build_q4_groups()` take `q4_group`. That also
resolves C3. **Fix (minimal):** add it as a third argument.

---

### ☐ C3. The "Never Alerted" rule is written twice, in two different functions ✅ verified
**`fxn_build_q4()` and `fxn_build_q4_groups()`**

The rule that decides whether a cow counts as "Never Alerted" appears in both. In the
original report these sat ~200 lines apart in one file; the refactor has put them in
separate functions with no shared argument. The only tripwire is the `stopifnot` from C2 —
which depends on the unbound global. This is the same silent-divergence class that caused
the 288-vs-284 mismatch earlier today.

**Fix:** the C2 recommended fix eliminates the duplication.

---

### ☐ C4. Uses `survival` and `ggsurvfit` without declaring them ✅ verified
**`fxn_build_q6()`** calls `survfit2()` and `Surv()`; the file declares only
`library(tidyverse)`. It works because both callers load them via `pacman::p_load()`.

Anyone sourcing the file and calling `fxn_build_q6()` — which the header comment
explicitly invites — gets `could not find function "survfit2"`, after every other
function has worked fine.

**Fix:** add `library(survival)` and `library(ggsurvfit)`, or namespace-qualify.

---

### ☐ C5. `fxn_build_q4()`'s signature is transposition-prone
**10 positional arguments, including two adjacent bare Dates** (`analysis_end`,
`nedlame_start_date`) and two adjacent same-shaped frames (`cohort`, `all_nedlame_cows`).

I verified **all ten call sites are currently correct**. This is a latent hazard, not a
present error. But swapping the two Dates would not error — it would collapse the lookback
window to zero for nearly every case and roughly **double the reported miss rate**, with
the report rendering clean.

Also: `analysis_end` is passed separately even though `params` is passed too and
`fxn_build_cohort()` derives it from `params$analysis_end_date`. Nothing ties them
together, so the alert cut-off and the lesion cut-off can drift apart — exactly the
coupling the code comment says must hold.

**Fix:** drop `analysis_end` from the signature and derive it inside from `params`; use
named arguments at both call sites.

---

### ☐ C6. Silent dependency on the *local* lesion-coding overrides
**`fxn_build_lame_history()`** calls `fxn_code_lesions()`, `fxn_collapse_lesions()`,
`fxn_trim_vars()`, `fxn_dz_status()`. Two come from a live GitHub fetch; two **must** be
the local overrides sourced *after* that fetch.

The ordering is correct in both callers today, but the functions file neither documents
nor enforces it while advertising itself as self-contained. If the upstream versions win,
there is no error — this farm's routine trims get misclassified as lesion-bearing, which
flows into `lame_data` and therefore into Q2, Q5 and the entire Q4 miss analysis. Every
number moves; nothing warns.

**Fix:** add a guard that fails loudly if the local overrides are not in force.

---

### ☐ C7. `fxn_build_staff_catch()` hard-codes a 7-day window
Every other window in the project is a `params` entry; this one is a literal `7`, and the
function does not take `params`. It also relies on `.x`/`.y` join suffixes, which shift if
either input gains a shared column name. Verbatim from the original, so not a regression.

**Fix:** add a `staff_window_days = 7` argument; rename before joining instead of relying
on suffixes.

---

### Code: what came back clean
Bodies are line-for-line identical to the originals. No chunk added or dropped. All ten
call sites correct in order and object. Return lists complete. Call ordering correct in
both reports. **All four domain rules intact** — "trim" is `LAME`+`FOOTRIM`+`TRIM` at all
five sites, filter-before-join is respected, lameness history is correctly *not*
lactation-scoped, and `detection_group` tests `caught_by_nedap` first. Rendered output
byte-identical for both reports.

---

## B. Text — genuine errors

### ☐ T1. Farm report claims the camera beats a competitor, with no supporting data ✅ verified
**`report_farm_summary.qmd:1164`** — *"NEDAP camera preforms better than CattleEye"*

Neither report contains a single CattleEye number. Nothing in the pipeline touches
CattleEye data. I grepped both sources: this is the only mention. It is the **first bullet
in the bottom line** of the report going to the farm.

**Fix:** delete it, or restate as explicitly-labelled opinion — *"Farm staff's impression
is that the Nedap camera flags more usable cases than CattleEye; this pilot did not
compare the two."* (Also "preforms" → "performs".)

---

### ☐ T2. All 339 are attributed to the camera, when only 195 were ✅ verified
**Both reports** — *"Of the 339 cows that were missed by the camera but had a lesion…"*

The full report's own analysis shows **144 of those 339 were flagged by the camera** — the
flag never reached DairyComp. The camera's actual miss count is 195, a rate of 195/579 =
**33.7%**, not 58.5%.

This is worse in the farm report, which omits the pipeline analysis entirely, so 58.5%
stands unqualified as the camera's miss rate. That is a near-doubling of the headline
failure number in the document the farm will act on.

**Fix:** both — *"Of the 339 cows whose lesion had no NEDLAME alert recorded in DairyComp
beforehand…"*. The farm report needs one added sentence: *"About 4 in 10 of these were
actually flagged by the camera — the flag just never arrived in DairyComp. The camera
itself genuinely missed 195."*

---

### ☐ T3. Farm report states the opposite of the full report's finding, and asserts a mechanism as fact ✅ verified
**`report_farm_summary.qmd`** — *"DD and other are the main categories being missed… The
missing of DD is not suprising as the camera was trained on locomotion scoring that also
misses cows with DD."*

Four problems:
1. Base-rate error — "main categories" with no comparison to what was *caught*.
2. The full report explicitly rejects the generic DD reading: *"So it is **not** DD as
   such"*. The gap is DD **on a rear foot** only; DD-on-front shows no gap (8.2% vs 7.6%).
3. **It says the opposite of the full report on "other"**: non-DD lesions on a rear foot
   are caught *better* than average (30.8% of misses vs 41.7% of flagged).
4. The mechanism is asserted as fact — and it is a *different* mechanism from the one the
   full report offers (bilateral DD → symmetric gait), which the full report correctly
   hedges. The plainer language removed the hedge and substituted an unevidenced
   explanation.

**Fix:** replace with the crossed comparison in plain language, keeping the hedge — see
the agent's suggested wording, which I think is good, quoted in full in §E below.

---

### ☐ T4. Farm report mis-frames the whole randomised contrast ✅ verified
**`report_farm_summary.qmd`** — *"Catching these extra cows does not impact short term
milk production and culling in the short term"*

Three compounding problems: (i) the TX/Control contrast is **not** caught-vs-missed —
every cow in both arms was flagged; it is *trim immediately* vs *staff discretion*.
"Catching these extra cows" describes the miss analysis, which has no milk or culling
outcome attached to it at all. (ii) It is a causal null claim from a descriptive
comparison. (iii) It contradicts this same report's milk text 200 lines earlier
(*"numerically there is an advantage to the trimmed group"*).

**Fix:** *"Trimming a flagged cow right away rather than waiting for staff or the routine
list did not produce a clear difference in milk or culling over the first 30 days. The
milk curves slightly favour the trimmed group but the spread is wide, and there were too
few culls to read anything into."*

---

### ☐ T5. Farm report labels the Control arm "staff identified" ✅ verified
**`report_farm_summary.qmd`** — *"Overall staff identified cows have fewer cows with no
lesion…"*

The Control arm is not staff-identified. Today's analysis showed **64.4% of Control trims
had no staff check at all** — they were the routine schedule. Labelling that mixture
"staff identified" produces a camera-vs-staff comparison the data does not support, and it
throws away the genuinely good news: when staff *did* flag a cow, 81% of those trims found
a lesion.

**Fix:** *"Just over half the trims done straight off a camera alert found no lesion
(54.9%), against 46.2% in the control group. But control trims are mostly the routine
schedule catching up, not staff picking cows out — when staff did flag a cow themselves,
81% of those trims found something."*

---

### ☐ T6. The two reports give contradictory logic for the same DairyComp rule ✅ verified
Same command `DSNLM=7-1` in both, glossed opposite ways:

- farm: *"Low Declining (… **no alarm in last 7 days** …)"*
- full: *"Low Declining (**alarm in last 7 days** …)"*

`DSNLM=7-1` is days-since-alarm between 1 and 7 — there **was** an alarm. **The full
report is correct; the farm report inverts it.** Conversely the farm report's *Low* gloss
is the more complete one — it accounts for `DSNLM=90-1`, which the full report's gloss
silently drops.

**Fix:** correct the farm report's Low Declining and Strong Decline glosses; add the
`DSNLM=90-1` condition to the full report's Low gloss. Also "and and" → "and".

---

### ☐ T7. Hard-coded table title disagrees with the table beneath it ✅ verified
**`report_farm_summary.qmd:668` and `report_nedlame_treatment_comparison_clean.qmd:924`** —
title reads *"43-55% of Trims do not have a lesion"*. I recomputed: the cells are **46.2 /
54.9 / 51.5**, so the range is **46-55%**. Stale from an earlier data cut, and it will
drift again on the next rebuild.

**Fix:** interpolate the title from the computed values so it cannot go stale.

---

### ☐ T8. Milk denominator sentence names the wrong event ✅ verified
**Both reports** — *"828 of the 849 cohort cows had at least one milk record **post
trimming**…"*. The curves are indexed to the **alert** date, and most Control cows were
never trimmed (only 225 of 452). "Post trimming" invites reading the milk curve as a
post-trim recovery curve in both arms.

**Fix:** *"…at least one milk record after their alert and a usable pre-alert baseline."*

---

### ☐ T9. Farm report describes the miss population as excluding the treatment groups
*"Cows with lesions not in the treatment groups that the camera missed"* — the 579 cases
are explicitly *regardless of* treatment group and include cohort cows from both arms.
This makes 58.5% look like an independent second dataset.

**Fix:** *"Cows found with a lesion — in either group or neither — where the camera had
not flagged her first."*

---

### ☐ T10. Time-to-trim presented as a measure of alert accuracy
**Both reports** — *"To determine the accuracy of the alert…"*. In the TX arm the trim is
*caused by the alert by protocol*, so time-to-trim measures protocol compliance. The full
report at least follows with a lesion-found table, which is a legitimate accuracy proxy;
**the farm report drops that table**, leaving its accuracy claim backed only by the
mechanical measure.

**Fix:** reword in both; restore the lesion-found table to the farm report.

---

### ☐ T11. Invalid inference about limb distribution
**Full report** — *"The never-alerted share is the largest block on every foot, so the
misses are not concentrated on one limb."* Which stacked segment is tallest does not
establish equal miss *rates* across feet. It also sits awkwardly against the section 40
lines later that isolates a +17pp DD-on-rear gap.

**Fix:** state that a miss rate cannot be read off that figure and point forward to the
flagged-vs-missed comparison.

---

## C. Overstatements

### ☐ T12. "Over time the control group reaches about 75% of cows trimmed" ✅ verified present
**`report_farm_summary.qmd:505`.** The table directly below says **37% at 30 days**, and
only 225 of 452 Control cows (49.8%) were *ever* trimmed in the observation window. 75%
can only come from the far tail of the KM curve where very few cows remain at risk. The
full report makes no such claim.

### ☐ T13. Day-30 milk caveat weakened in a way that changes its meaning
Farm: *"more variability at those time points"* — implies wider error bars on the same
estimate. The full report says something stronger: the day-30 point rests on a
**different, non-random subset** (553 of 828, the earlier-alerting cows) and the estimate
itself will move. Selection caveat, not a precision caveat.

### ☐ T14. The 58.5% loses both eligibility caveats in the farm report
The full report notes 111 of 579 (19%) had **less than the full 21-day window** to be
flagged. Some of those are counted as misses for a reason that has nothing to do with the
camera.

### ☐ T15. Causal framing on descriptive figures
Both reports: *"the impact of the treatment group on milk production"*, *"the impact on
milk production between the lesion history types"*. "Impact" asserts causation from
unadjusted curves with no test — and history groups are not randomised at all.

### ☐ T16. A null asserted from ~53 culling events
*"No real impact is seen."* Claims a demonstrated absence of effect where the data can
only say "too few culls to tell".

### ☐ T17. Headline DD claim slightly oversold
The crossed reasoning is **sound** — the agent independently re-expressed it as detection
rates and it holds (54% of rear-foot DD detected vs 73% of other rear-foot lesions). Three
tempering suggestions: "the whole effect" is too strong for a descriptive contrast resting
on ~81 cases; "the blind spot is" → "the clearest blind spot is"; and the table shows
three of four cells — adding non-DD-on-front would let the reader check the 2×2 closes.

### ☑ ~~T18a. SmartSight enrollment gap buried / absent from the farm report~~ — DECLINED 2026-09-09

> Gerard: *"that is a NEDAP issue and this would be solved in a real set up."* The enrollment
> stoppage is a pilot-setup artifact, not something the farm needs to act on, so it does not
> need promoting in either report.
>
> **Note this does NOT change the Q4 exclusion**, which stays. Those 26 cows genuinely were
> not being monitored during the pilot, so counting their lesions as camera misses would be
> wrong for this dataset. If anything, declining T18 on the grounds that enrollment failure
> is a setup artifact *strengthens* the case for excluding them — the camera should not be
> charged with cows it was never watching.

### ☐ T18b. The 108 unexplained pipeline losses are absent from the farm report

**Split out of the original T18, which bundled two separate things.** Declining the
enrollment item above does not resolve this one, and it is entangled with **T2**: the farm
report omits the pipeline analysis entirely while keeping the 58.5% headline, so that
number reads as the camera's miss rate when the camera's own rate is 33.7%. Either the
pipeline split goes into the farm report, or the 58.5% has to be relabelled. **Fixing T2
probably resolves this too.**

<details>
<summary>Original T18 text (for reference)</summary>
The **SmartSight enrollment stoppage** is the best-evidenced and most actionable result in
the pack — 0% of first-lactation cows freshening in July/August enrolled, against 97-99%
on Activity, both lists pulled the same day. It sits mid-section under a heading about
excluding 26 lesion cases, is never restated as a conclusion, and **appears nowhere in the
farm report**. The 108 unexplained pipeline losses are likewise absent — while an
unsupported competitor comparison made the bottom line.

**This is the item I would action first.** It is the one finding the farm can act on this
week.

</details>
---

## D. Nitpicks (listed only so you can skip them)

"Most cows enrolled were Lact 3+" — 46.7% is a plurality, not a majority · full report's
*"only 339 can currently be checked"* frames 100% coverage as a shortfall · farm table
title "Similar DIM between groups" vs full report's "Some skewness in DIM" on the same
table · stranded sub-bullet under the 144 line · typos: *preforms, and and, aroudn,
withing, suprising, recenlty, where trimmed, is show below*.

---

## E. Raised and checked — not issues

- **"Alerted, Missed" = 55 and staff-catch = 55.** Flagged as a possible crossing of two
  objects. ✅ I checked: only **11 of 55** cows overlap and the sets differ. Genuinely
  coincidence.
- **Whether the bilateral-DD mechanism is properly hedged in the full report.** It appears
  once and is correctly flagged as interpretation. The failure is only in the farm report
  (T3).

---

## Suggested order of work

1. ~~**T18**~~ — declined 2026-09-09 (Nedap setup artifact). T18b split out and folded into T2.
2. **T1, T2, T3, T4, T5, T6** — the farm report says things that are wrong or contradict
   the full report. **Start here.**
3. **C1, C2** — the two real code defects (both mine).
4. **T7, T8** — quick factual corrections in both reports.
5. Everything else.
