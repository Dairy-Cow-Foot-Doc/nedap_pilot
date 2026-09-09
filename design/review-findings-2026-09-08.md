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

### ☑ ~~C1. `cows_smartsight` argument is dead — silently overwritten by a disk read ✅ verified~~ — FIXED 2026-09-09 (`624e2cf`)
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

### ☑ ~~C2. `n_never_alerted_bucket` is read from the global environment ✅ verified~~ — FIXED 2026-09-09 (`624e2cf`)
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

### ☑ ~~C3. The "Never Alerted" rule is written twice, in two different functions ✅ verified~~ — FIXED 2026-09-09 (`624e2cf`)
**`fxn_build_q4()` and `fxn_build_q4_groups()`**

The rule that decides whether a cow counts as "Never Alerted" appears in both. In the
original report these sat ~200 lines apart in one file; the refactor has put them in
separate functions with no shared argument. The only tripwire is the `stopifnot` from C2 —
which depends on the unbound global. This is the same silent-divergence class that caused
the 288-vs-284 mismatch earlier today.

**Fix:** the C2 recommended fix eliminates the duplication.

---

### ☑ ~~C4. Uses `survival` and `ggsurvfit` without declaring them ✅ verified~~ — FIXED 2026-09-09 (`624e2cf`)
**`fxn_build_q6()`** calls `survfit2()` and `Surv()`; the file declares only
`library(tidyverse)`. It works because both callers load them via `pacman::p_load()`.

Anyone sourcing the file and calling `fxn_build_q6()` — which the header comment
explicitly invites — gets `could not find function "survfit2"`, after every other
function has worked fine.

**Fix:** add `library(survival)` and `library(ggsurvfit)`, or namespace-qualify.

---

### ☑ ~~C5. `fxn_build_q4()`'s signature is transposition-prone~~ — FIXED 2026-09-09 (`624e2cf`)
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

### ☑ ~~C6. Silent dependency on the *local* lesion-coding overrides~~ — FIXED 2026-09-09 (`624e2cf`)
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

### ☑ ~~C7. `fxn_build_staff_catch()` hard-codes a 7-day window~~ — FIXED 2026-09-09 (`624e2cf`)
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

### ☑ ~~T1. Farm report claims the camera beats a competitor, with no supporting data ✅ verified~~ — DONE 2026-09-09
**`report_farm_summary.qmd:1164`** — *"NEDAP camera preforms better than CattleEye"*

Neither report contains a single CattleEye number. Nothing in the pipeline touches
CattleEye data. I grepped both sources: this is the only mention. It is the **first bullet
in the bottom line** of the report going to the farm.

**Fix:** delete it, or restate as explicitly-labelled opinion — *"Farm staff's impression
is that the Nedap camera flags more usable cases than CattleEye; this pilot did not
compare the two."* (Also "preforms" → "performs".)

---

### ☑ ~~T2. All 339 are attributed to the camera~~ — FIXED 2026-09-09
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

### ◐ T3 — PARTLY DECLINED 2026-09-09: the "states the opposite" claim was wrong

> **Gerard 2026-09-09, and he is right:** *"I disagree with it stating the opposite. The leg
> differentiation is extra stuff for main report but for farm the conclusion compared main
> lesions (WLD, DD, SU) DD is missed more than the others."*
>
> Checked, and the farm report's claim holds at the level it makes it: **DD is 43% of the cases
> the camera never flagged against 27% of the ones it did; white line is 17% vs 39%.** DD is
> missed more than the others, decisively.
>
> The reviewer conflated two levels. *"It is not DD as such"* in the full report is about the
> CROSSED analysis — the gap concentrates in DD **on a rear foot** — which refines the simple
> lesion-level finding rather than contradicting it. Both are true at their own level, and the
> foot breakdown is main-report detail the farm does not need.
>
> Sub-points 1 and 3 fall with it: at lesion level "other" is over-represented among misses too,
> so that was not backwards either.
>
> **Still open from T3:** the farm report asserts its mechanism as fact ("the camera was trained
> on locomotion scoring that also misses cows with DD"), and it differs from the full report's
> hedged one (bilateral DD → symmetric gait). One should be hedged, or they should agree.
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

### ☑ ~~T4. Farm report mis-frames the whole randomised contrast ✅ verified~~ — FIXED 2026-09-09
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

### ☑ ~~T5. Farm report labels the Control arm "staff identified" ✅ verified~~ — DONE 2026-09-09 (`57fd3f5`)
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

### ☑ ~~T6. The two reports give contradictory logic for the same DairyComp rule~~ — FIXED 2026-09-09 (direction corrected by Gerard)
Same command `DSNLM=7-1` in both, glossed opposite ways:

- farm: *"Low Declining (… **no alarm in last 7 days** …)"*
- full: *"Low Declining (**alarm in last 7 days** …)"*

> **Gerard 2026-09-09: `DSNLM` is an EXCLUSION** — it excludes cows already alerted in the last N days so the cowcard is not filled with duplicate alarms. **So the FARM report was right and the FULL report was wrong** — the opposite of what this finding originally said. Both copies of the full report have been corrected, including the `Low` route, which also silently omitted the `DSNLM=90-1` condition.

~~`DSNLM=7-1` is days-since-alarm between 1 and 7 — there **was** an alarm. **The full
report is correct; the farm report inverts it.** Conversely the farm report's *Low* gloss
is the more complete one — it accounts for `DSNLM=90-1`, which the full report's gloss
silently drops.

**Fix:** correct the farm report's Low Declining and Strong Decline glosses; add the
`DSNLM=90-1` condition to the full report's Low gloss. Also "and and" → "and".

---

### ☑ ~~T7. Hard-coded table title disagrees with the table beneath it ✅ verified~~ — DONE 2026-09-09 (`57fd3f5`)
**`report_farm_summary.qmd:668` and `report_nedlame_treatment_comparison_clean.qmd:924`** —
title reads *"43-55% of Trims do not have a lesion"*. I recomputed: the cells are **46.2 /
54.9 / 51.5**, so the range is **46-55%**. Stale from an earlier data cut, and it will
drift again on the next rebuild.

**Fix:** interpolate the title from the computed values so it cannot go stale.

---

### ☑ ~~T8. Milk denominator sentence names the wrong event ✅ verified~~ — DONE 2026-09-09 (`57fd3f5`)
**Both reports** — *"828 of the 849 cohort cows had at least one milk record **post
trimming**…"*. The curves are indexed to the **alert** date, and most Control cows were
never trimmed (only 225 of 452). "Post trimming" invites reading the milk curve as a
post-trim recovery curve in both arms.

**Fix:** *"…at least one milk record after their alert and a usable pre-alert baseline."*

---

### ☑ ~~T9. Farm report describes the miss population as excluding the treatment groups~~ — DONE 2026-09-09 (`57fd3f5`)
*"Cows with lesions not in the treatment groups that the camera missed"* — the 579 cases
are explicitly *regardless of* treatment group and include cohort cows from both arms.
This makes 58.5% look like an independent second dataset.

**Fix:** *"Cows found with a lesion — in either group or neither — where the camera had
not flagged her first."*

---

### ☑ ~~T10. Time-to-trim presented as a measure of alert accuracy~~ — DONE 2026-09-09 (`57fd3f5`) — with a deviation Gerard directed, see note
**Both reports** — *"To determine the accuracy of the alert…"*. In the TX arm the trim is
*caused by the alert by protocol*, so time-to-trim measures protocol compliance. The full
report at least follows with a lesion-found table, which is a legitimate accuracy proxy;
**the farm report drops that table**, leaving its accuracy claim backed only by the
mechanical measure.

**Fix:** reword in both; restore the lesion-found table to the farm report.

---

### ☑ ~~T11. Invalid inference about limb distribution~~ — DONE 2026-09-09 (`57fd3f5`) — applied far more broadly than the finding asked, see note
**Full report** — *"The never-alerted share is the largest block on every foot, so the
misses are not concentrated on one limb."* Which stacked segment is tallest does not
establish equal miss *rates* across feet. It also sits awkwardly against the section 40
lines later that isolates a +17pp DD-on-rear gap.

**Fix:** state that a miss rate cannot be read off that figure and point forward to the
flagged-vs-missed comparison.

---

## C. Overstatements

### ☑ ~~T12. "Over time the control group reaches about 75% of cows trimmed" ✅ verified present~~ — DONE 2026-09-09 (`57fd3f5`) — replaced rather than deleted, see note
**`report_farm_summary.qmd:505`.** The table directly below says **37% at 30 days**, and
only 225 of 452 Control cows (49.8%) were *ever* trimmed in the observation window. 75%
can only come from the far tail of the KM curve where very few cows remain at risk. The
full report makes no such claim.

### ☑ ~~T13. Day-30 milk caveat weakened in a way that changes its meaning~~ — PARTLY ADDRESSED 2026-09-09 — Gerard wrote his own wording; the selection half is still open, see note
Farm: *"more variability at those time points"* — implies wider error bars on the same
estimate. The full report says something stronger: the day-30 point rests on a
**different, non-random subset** (553 of 828, the earlier-alerting cows) and the estimate
itself will move. Selection caveat, not a precision caveat.

### ☑ ~~T14. The 58.5% loses both eligibility caveats in the farm report~~ — DONE 2026-09-09 (`57fd3f5`)
The full report notes 111 of 579 (19%) had **less than the full 21-day window** to be
flagged. Some of those are counted as misses for a reason that has nothing to do with the
camera.

### ☑ ~~T15. Causal framing on descriptive figures~~ — DONE 2026-09-09 (`57fd3f5`)
Both reports: *"the impact of the treatment group on milk production"*, *"the impact on
milk production between the lesion history types"*. "Impact" asserts causation from
unadjusted curves with no test — and history groups are not randomised at all.

### ☑ ~~T16. A null asserted from ~53 culling events~~ — DONE 2026-09-09 (`57fd3f5`)
*"No real impact is seen."* Claims a demonstrated absence of effect where the data can
only say "too few culls to tell".

### ☑ ~~T17. Headline DD claim slightly oversold~~ — SUPERSEDED 2026-09-09 — moot once T11 removed the passage it tempered
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

### ☑ ~~T18b. The 108 unexplained pipeline losses are absent from the farm report~~ — DECLINED (farm report) 2026-09-09

> Gerard: *"The other pipeline issues are not really of interest to the farm as those are
> of interest to me and NEDAP as we need to make sure for future studies we avoid them."*
> Pipeline detail stays OUT of the farm report.

**T2 still needs fixing, but only as a relabel — no pipeline content need enter the farm
report.** Changing *"missed by the camera"* to *"had no NEDLAME alert recorded in
DairyComp beforehand"* makes the sentence accurate without explaining why. That keeps the
farm report simple and stops 58.5% being read as the camera's own miss rate.

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
### ☑ ~~T19. NEW — report the one pipeline split that is actually actionable (full report only)~~ — DONE 2026-09-09 (`57fd3f5`)

**Proposed 2026-09-09 in response to:** *"we don't know why they happened as we don't have
the scores at time of flag."* True for most of them — but not all, and the report does not
currently separate the two.

The report already computes `low_only` but uses it solely for the injury check. Splitting
the 108 unexplained pipeline losses by which route fired gives:

| | Cases | Score-gated? | Resolvable without scores? |
|---|---|---|---|
| `LOW` flag only | **84** | Yes (`LMSV=1-30`) | **No** — a score of 31-69 is indistinguishable from a lost flag |
| A decline flag fired | **24** | **No** | **Yes** — no by-design explanation remains |

So the honest position for the Nedap conversation is not "108 unexplained" but **"24 clean
integration failures, plus 84 we cannot adjudicate without scores at flag."** The decline
routes carry no score gate, so for those 24 a flag fired and no `NEDLAME` appeared, full
stop.

Two of the 24 involve a `STRONG DECLINE` — the most severe trigger — and several fired
five or six times over a fortnight with nothing reaching DairyComp. Cow IDs are already
saved at `reports/qmd_reports/pipeline_loss_decline_only.csv`.

**Fix:** add the split plus one sentence to the by-design section of the FULL report only.
It also sharpens the existing floor caveat, which currently says the score gate cannot be
checked without noting that for 24 cases it does not apply.

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

---

## F. Found by Gerard's cowcard checks, 2026-09-09 — both real, both unfixed

### ☑ ~~T20. The batch-load lag is applied in one place but not the other ✅ verified~~ — DONE 2026-09-09

**Found via cow 7207.** Her sensor flagged on 2026-06-11 (`LOW DECLINE` + `STRONG DECLINE`), her white-line lesion was diagnosed 2026-06-11, and her `NEDLAME` landed in DairyComp on **2026-06-12** — one day later.

The lookback window is `[lesion − 21, lesion]`, so a `NEDLAME` stamped the day *after* the lesion falls outside it. She is therefore scored `caught_by_nedap = FALSE`, counted as a miss, and — because the sensor fired inside the window — classified a **pipeline loss**. Her flag plainly did reach DairyComp.

**The report already knows about this lag.** It is the entire basis of the post-trim exclusion: *"the daily batch loads at ~5am and stamps each alert with the day it was LOADED... an attention any time after ~5am on day D gets logged with date D+1."* That reasoning is applied to exclusions but never to the lookback, which only looks backward.

**Scale:**

| | Count |
|---|---|
| Misses with a `NEDLAME` dated exactly +1 day | **15 of 339** |
| Pipeline losses with one | **14 of 144** |
| …of which **priority 1** (the "clean integration failures") | **10 of 23** |
| Within +2 days / +3 days (misses) | 34 / 50 |

**Nearly half the priority-1 list is contaminated.** Those cows are not integration failures — the alert arrived, a day late. That directly undercuts the list I generated for the Nedap conversation.

Treating +1 day as caught moves the miss rate from **58.5% to 56.0%** (339 → 324).

**One caution against fixing it naively.** A `NEDLAME` at lesion+1 has two possible causes: the pre-lesion flag arriving late (7207's case), or a *genuine new* post-trim reaction — which is the artifact the post-trim exclusion exists to remove. The two are distinguishable: if a sensor attention exists on or before the lesion date and the `NEDLAME` is dated +1, it is the late arrival. All 14 pipeline-loss cases satisfy that by construction, since a pipeline loss requires an in-window attention. The 15 misses need the check applied case by case.

**Suggested fix:** when testing whether an in-window sensor flag became a `NEDLAME`, allow the documented one-day batch lag. Regenerate `pipeline_losses.xlsx` afterwards — the priority-1 list is the part that matters.

---

### ☑ ~~T21. `locate_lesion` invents a phantom left-front on `XNLF*` remarks ✅ verified~~ — DONE 2026-09-09

**Found via cow 10214.** Gerard: *"the xnlfrf is not 2 legs. it means xnl for the treatment F for foot rot and then RF for leg — lf is not another leg."*

`XNLFRF` = `XNL` (treatment) + `F` (foot rot) + `RF` (leg). A two-character scan finds a phantom `LF` spanning the treatment's trailing **L** and the lesion's **F**. This is upstream in how `locate_lesion` is built, not in the report's own parsing.

Confirmed it is specific to this family. Other codes are 4-letter treatments followed by genuine feet — `BLKWLFRF` really is two feet, `LATDLRRR` really is two. `XNLF` is the one case where treatment and lesion letters accidentally form a valid foot pair. Note also that the farm writes `LH`/`RH` for hind and `locate_lesion` correctly normalises those to `LR`/`RR`; that mapping is fine.

| | All history | In the analysis window |
|---|---|---|
| `XNLF*` rows carrying a phantom `LF` | 559 of 605 | 56 |
| Foot-level entries removed by correcting it | — | 42 |
| Left Front | — | 255 → **213** |
| Left/Right Rear | — | unchanged (375 / 380) |

**The headline is safe, and slightly strengthened.** The phantom is *always* a left front, so it can only inflate front-foot counts. DD-on-rear and non-DD-on-rear are untouched; the DD-on-**front** share (8.2% vs 7.6%, already no gap) shrinks further, which reinforces *"it is not DD as such."* Front/rear in the window goes 529/755 → 487/755.

**Suggested fix:** for remarks starting `XNLF`, parse the feet from what follows `XNLF` rather than scanning the whole `locate_lesion` string. Verified against the awkward cases: `XNLFRHRF` → RR+RF, `XNLFLHRH` → LR+RR, `XNLFLF` → LF. The proper fix is upstream in step 0, since `locate_lesion` is built there and every downstream analysis inherits it.

---

### ☑ ~~T22. The report and the workbook disagree about `DSNLM`~~ — FIXED 2026-09-09

**Introduced by me, found while applying T20/T21.** `DSNLM` is implemented as a by-design suppression in `pipeline_losses.xlsx` but **not** in the report, where it appears only as text inside the DairyComp command listing. The report's `by_design` is `all_attentions_blocked | injury_explained | alert_arrived_late` — no `DSNLM` term.

Since Gerard confirmed on 2026-09-09 that `DSNLM` genuinely is an exclusion (a cow already alerted in the last N days is not re-flagged), the report is **understating** by-design suppression by roughly 10 cases and overstating real pipeline losses by the same.

The two artefacts therefore give different answers for the same question, which is exactly the drift the shared-functions refactor was meant to prevent — except this rule lives in neither place, it is duplicated between a report chunk and a standalone script.

**Fix:** add the `DSNLM` term to the report's `by_design`, and ideally move the whole by-design block into `functions/fxn_nedlame_analysis.R` so the report and the workbook compute it once.

---

### ☑ ~~ACTION REQUIRED: step 0 must be re-run~~ — DONE 2026-09-09, phantoms 559 → 0

T21 was fixed at source in `functions/fxn_location.R`, and the report-level workaround has been removed. **The intermediate parquet files still contain the old `locate_lesion` with the phantom left front.** Until step 0 is re-run, the foot figures revert to the inflated numbers (front 309 rather than 299).

Nothing else is affected — the phantom is always a left front, so rear counts and the DD-on-rear headline are unchanged either way.

---

## G. Found checking the 13 genuine pipeline losses against Gerard's cowcards, 2026-09-09

Gerard supplied cowcards for all 13 `CHECK FIRST` cases plus their `MNFRS` and `UPLAM` values from DairyComp. Full write-up in the plan doc, Round 25. Most of what the cowcards tested came back **clean** — the `low_only` restriction on the injury exclusion is correct (`UPLAM<>1` is only on the `Low` route, and all 13 had a decline flag fire), `MNFRS` is pre-assigned herd-wide so it cannot contradict "not in pilot cohort", and `leg_abovefoot_injury_history` reproduces the `UPLAM` field exactly. Two things did not.

---

### ☐ T23. A cow alerted *before* the lookback opens is scored as a genuine pipeline loss ✅ verified

**`functions/fxn_nedlame_analysis.R`, `fxn_build_pipeline_by_design()`**

`by_design` has four terms — `all_attentions_blocked | injury_explained | alert_arrived_late | all_dsnlm_blocked`. The `alert_arrived_late` term catches an alert that reached DairyComp the day *after* the lesion. There is no mirror term for an alert that reached DairyComp *before the lookback window opened*, so such a cow is scored as though the camera flagged her and the flag vanished — when in fact the alert arrived, was recorded, and enrolled her.

**Cow 10581 is the case.** `NEDLAME` on 2026-07-10, lesion on 2026-08-04 — 25 days, four days outside the 21-day lookback. She was enrolled and in the **Control** arm. Her 08-02 `LOW DECLINE` flag genuinely produced no second alert, so at *flag* level something was lost; but the claim the bucket makes is a **cow-level** one — "the camera flagged her and the alert never reached DairyComp, so she was missed" — and that is false for her.

**Re-derived 2026-09-09 against `f3a6031`.** The concurrent session made the attention window strictly before the lesion date (`d40cca3`, `c86825b`), on the finding that no attention in the export occurs before 05:00 local and 61% of matched alerts land at exactly +1 day — so a flag on the lesion day can never have arrived in time. That moved the whole section: baseline is now **50 by design / 69 cannot tell / 12 genuine = 131**, not 58 / 73 / 13, and **10379** dropped out of the genuine set on the window change rather than on this finding. Re-running the check against the current 131: 12 cases have a `NEDLAME` before the lookback opened — 10 already `DSNLM`-blocked, 1 `FTDAT`-blocked, and **exactly one genuine: 10581**. The blast radius is still exactly one case.

Why it matters: these 13 are the cases being taken to Nedap. One of them is a cow who was alerted, enrolled and monitored. That is the single weakest item in the set, and it is the kind of thing that costs credibility in the room.

**Fix:** add a fifth term, `alert_arrived_before_window` — any `NEDLAME` for that cow-lactation strictly before `date_event - lookback_days_used`. **Genuine drops 12 → 11** and the split becomes **51 / 69 / 11**. The `stopifnot` on the three-way sum already guards the arithmetic, and the exclusive `reason` `case_when` added in `6422356` needs the new term slotted into its precedence — alongside `alert_arrived_late`, since it is the same family (*an alert did arrive*), not a *working as designed* suppression. Note this is a **labelling** fix, not a `caught_by_nedap` change: an alert 25 days out did not prevent the lesion, so her detection status should not move and she stays in the 339. Both the report and `pipeline_losses.xlsx` call `fxn_build_pipeline_by_design()` now, so the workbook picks this up for free.

---

### ☐ T24. The `FTDAT` trim gate is lactation-scoped; DairyComp's `FTDAT` is cow-level ✅ verified — impact quantified as zero here

**`functions/fxn_nedlame_analysis.R`, `fxn_build_pipeline_by_design()`, the `trims_gate` join**

```r
left_join(trims_gate, by = c("id_animal", "lact_number"), ...)
```

`FTDAT` in DairyComp is a **cow-level date item** — it does not reset at freshening. Scoping the lookup to the current lactation makes any trim in a prior lactation invisible, so a cow who freshened recently shows `days_since_last_trim = NA` and passes a gate that DairyComp itself would have applied. This was already noted as a floor in Round 18 (*"the trim lookup is lactation-scoped while real `FTDAT` likely looks back further"*), never quantified, and never fixed.

**Quantified now: it changes 0 of 43 flags for the 13 cases.** Recomputing cow-level, seven cows go from `NA` to a real interval (10204: 147 d, 10214: 189, 10379: 164, 10581: 124, 23069: 175, 7784: 205, 9254: 108) and **none** falls inside its gate — every one of the 13 had a *decline* flag, whose window is only 28 days. The 43 flags were enumerated under the pre-`d40cca3` window; the narrower window can only *remove* flags, never make one fall inside its gate, so the zero holds a fortiori (10379 has since left the set entirely).

So this is a correctness fix, not a numbers fix. It is worth doing anyway because the gate width varies by route (90 days for `Low`, 28 for the declines) and the 90-day `Low` window is wide enough that a prior-lactation trim *will* land inside it for some cow eventually — at which point the bug starts silently moving counts with nothing to warn you.

**Fix:** join `trims_gate` on `id_animal` alone and keep the existing `gate_trim_date < attention_date` filter, which already does the temporal work. Same change applies to the `trims_gate` build itself, which currently carries `lact_number` only to support this join.

---

## H. Disposition of T5–T19, 2026-09-09

Applied by the concurrent session in `57fd3f5` and `773bcd7`, Gerard cueing them one at a time. Recorded here because four did not land as written and the reasons matter more than the ticks.

### T11 — applied far beyond the finding, and it removes the report's headline

The finding asked only that an invalid limb-distribution inference be dropped. Gerard went much further: **"the whole DD and rear vs front is a who cares"**, and the DD-on-a-hind-foot crossing was **an agent's invention, not a question he had asked**. So the crossed table, its three bullets and the entire `conj_*` computation are gone, and the bilateral-DD mechanism went with them. Front versus hind is now stated plainly — hind-foot lesions dominate missed and flagged cases in much the same proportion, so there is no front-foot blind spot — and the mechanism paragraph leads on locomotion scoring detecting DD poorly.

**This retires what Rounds 19–21 treated as the report's headline finding.** Anyone returning to this project should not go looking for the DD-on-hind-foot conjunction; it was removed deliberately, not lost. Verified in the working tree: no `conj_` and no "bilateral" remain in either `_fx` report.

### T13 — only half addressed, and the open half is the one the finding was about

Gerard rewrote the day-30 milk caveat himself. His text is a **precision** caveat ("more variability... the true impact is not certain yet"). The finding was about **selection** — that the cows behind the day-30 point are the earlier-alerting ones, so the figure describes a non-random subset rather than a noisy estimate of the whole. His wording, his call, and the concurrent session correctly did not overwrite it. Logged so the distinction is not quietly lost: **the selection point is still unmade.**

### T10 and T12 — deviations Gerard directed

- **T10:** reworded to protocol compliance in both reports, but the lesion-found table was **not** restored to the farm report — he said it is not useful to him.
- **T12:** the 75% claim was **replaced** with the staff-vs-routine trim-driver table rather than simply deleted, which answers the underlying question instead of removing it.

### Single-sourcing extended

Both reports now also go through `fxn_build_control_trim_drivers()`, so the staff-vs-routine numbers are computed once, the same way the by-design verdicts already were. That is the T22 drift class closed off in a second place.

### `pipeline_losses.xlsx` is reproducible now — and moving it found two live drifts

The generator lived only in a scratchpad; it is now `scripts/step3_pipeline_losses.R`. Promoting it surfaced two real disagreements with the report that had been invisible:

1. It still used the **inclusive same-day window**, so it built 144 candidates where the report had moved to 131.
2. It emitted **"Flagged, Lost in Pipeline"** where the shared function had moved to **"Flagged, but no alert in time"** — a filter that silently matched nothing and zeroed every verdict.

Both fixed; it now reproduces 131 → 50 by design / 81 not. **The second is the sharpest example yet of this project's recurring failure mode:** sharing logic through a *string label* rather than a value, so a rename fails silently instead of erroring. Same class as the `detection_group` label mismatches in Round 18 and the `DSNLM` split in T22. Note the `.xlsx` itself sits under the gitignored `reports/` tree and was never a committed artifact — the script is what makes it reproducible.

### Still open

**T13** (selection half, above) and **T23** (awaiting Gerard). **T24** is unfixed but quantified at zero impact.
