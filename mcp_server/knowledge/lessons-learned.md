# Lessons Learned: NEDLAME 2-Arm Pilot Report

Four real bugs were found while building `qmd_reports/report_nedlame_treatment_comparison.qmd`, three of them the *same* root-cause pattern. Read this before building the 3-arm follow-up analysis so it doesn't repeat them.

## The recurring bug pattern: filter-after-join instead of filter-before-join

**The pattern that bit us three separate times:**

```r
# WRONG - looks correct, silently drops rows
cohort |>
  left_join(candidate_events, by = c("id_animal", "lact_number")) |>
  filter(date_event > some_cutoff)   # <-- filters the JOINED result
```

If a cow has candidate events somewhere in her history but *none* satisfy the filter, `left_join` still produces real (non-NA) rows for her — one per candidate event. The `filter()` afterward removes *all* of them, and she vanishes from the output entirely instead of being correctly treated as "no match" (e.g. censored, or labeled with a default/NA category). This is silent — no error, no warning — you only notice because a total count doesn't reconcile somewhere downstream.

**The fix — always filter the candidate table before joining it to the base table:**

```r
# CORRECT
valid_candidates <- candidate_events |>
  inner_join(cohort |> select(id_animal, lact_number, some_cutoff_col), by = c("id_animal", "lact_number")) |>
  filter(date_event > some_cutoff_col) |>
  select(id_animal, lact_number, date_event)

cohort |>
  left_join(valid_candidates, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
  group_by(id_animal, lact_number) |>
  slice_min(date_event, n = 1, with_ties = FALSE, na_rm = FALSE) |>
  ungroup()
```

This way, a cow with zero valid candidates gets exactly one row from the `left_join` (all-NA on the candidate columns) instead of zero rows.

**Where this bit us:**
1. `fxn_time_to_next()` (Q2, time-to-next-event) — silently excluded ~45% of cows from one curve.
2. The lameness-history join (Q5) — silently dropped 49 of 434 cows from the *entire shared cohort table*, corrupting every section, not just Q5.
3. (A near-miss caught before shipping) the milk-to-lactation resolution join had an analogous issue with open-ended `date_dry` windows letting a stale prior lactation "swallow" a later cow's milk rows — see `fxn_read_milk_folder.R`'s `fxn_resolve_milk_to_lactation()` for the nearest-preceding-fresh-date fix.

**When building the 3-arm analysis: audit every `left_join` followed by a `filter()` for this exact shape.** If in doubt, ask "if this cow has zero valid matches, does she still get exactly one output row?"

## Bug #2: externally-fetched functions can silently override your local, correct ones

This pipeline sources several R functions live from a GitHub repo (`github.com/Dairy-Cow-Foot-Doc/os_functions`, via `functions/fxn_load_os_fxns.R`). That repo's `fxn_code_lesions()` only checks the `protocols` field for `"NONE"` when deciding if a trim found no lesion — but this farm codes routine no-lesion trims via the *remark* field instead. Because the local, correctly-calibrated copy of `fxn_code_lesions.R` was sourced *before* the GitHub fetch, the GitHub version silently won (last-sourced-wins in R), and **every single LAME/FOOTRIM/TRIM row got misclassified as having a lesion** for an entire draft of the report.

The GitHub repo's `fxn_collapse_lesions()` has a second, independent bug: it reassigns its own `data` variable to an already-one-row-per-date subset (via `slice_min(trimonly)`) *before* computing a `max()` union across that date's lesion-type columns — so a cow with two *different* lesions coded on the same day silently loses all but one of them.

**Lesson:** if you depend on live-fetched external code, (a) know exactly what it does before trusting its output against your farm's specific data conventions, and (b) if you need to override a specific function, source your corrected local copy *after* the external fetch, not before — R's `source()` uses last-loaded-wins.

**Status:** both bugs were fixed and a PR was prepared for the upstream repo (branch `fix/lesion-classification-bugs`, pushed to `github.com/Dairy-Cow-Foot-Doc/os_functions`). Check whether that PR has been merged before starting the 3-arm analysis — if it has, the local override files in `functions/fxn_code_lesions.R` and `functions/fxn_collapse_lesions.R` may no longer be necessary (but re-verify before removing them).

## Bug #3: "was this cow trimmed recently" must mean LAME + FOOTRIM + TRIM, never FOOTRIM/TRIM alone

This farm records a hoof-trimmer's visit as a `LAME` event (with lesion codes) whenever a lesion is found at that visit — it does **not** also get a separate `FOOTRIM` code that same day. So any check for "was this cow trimmed within the last N days" that only looks at `Event %in% c("FOOTRIM", "TRIM")` will systematically miss every visit where a lesion was actually found, which is exactly the subset of trims most likely to matter for a downstream analysis.

This bit the 2-arm report **twice**, independently, in two different chunks:
1. Q4's `FTDAT` recent-trim-suppression gate (Round 9) — confirmed directly with the farm and fixed to `c("LAME", "FOOTRIM", "TRIM")`.
2. A later "exclude alerts that fired shortly after a trim" check (Round 12/13, added to detect alerts that are really post-trim gait artifacts rather than independent catches) — built independently, made the *exact same mistake* (`FOOTRIM`/`TRIM` only), and was only caught because the user cross-checked a specific cow's real cowcard and found her actual trim visit had been coded as `LAME`.

**Lesson: treat "trim" as `LAME + FOOTRIM + TRIM` everywhere in this farm's data, as a house rule — never write a new "was she trimmed" check without all three, even if an earlier chunk in the same file already got it right.** The bug can and did recur within the same document once the underlying assumption wasn't written down as an explicit rule.

## Bug #4: `lact_number == 0` (pre-fresh heifers) need their own eligibility exclusion, same as dry cows

`NEDLAME`'s mobility/activity monitoring is tied to a cow being in milk. The report already excludes lesions found after a cow was dried off (`date_event > date_dry`) for exactly this reason — but it initially missed the mirror-image case at the *other* end of a lactation: a heifer who has never freshened yet (`lact_number == 0`, `date_fresh` is NA) was never eligible for monitoring in the first place either, and yet her `LAME` diagnoses were being counted as full misses (100% miss rate for that subgroup, since a cow with no `date_fresh` can never join into the alerted cohort). Caught via a real cowcard cross-check (cow 31377) — 31 of 418 qualifying Q4 cases (7.4%) turned out to be pre-fresh heifers.

**Lesson: any "was this cow eligible to be monitored" check needs BOTH ends of the lactation checked — not just "already dried off," but also "hasn't freshened yet."** In this herd's data, `lact_number == 0` with a null `date_fresh` is the reliable signal for the latter; confirmed consistent across all 31 example cases before trusting it as an exclusion rule.

## Design choices that look like bugs but aren't (documented so you don't "fix" them by accident)

- **`history_group` (lameness chronicity) deliberately does NOT use the lactation-scoping pattern used everywhere else.** Every other join in the report scopes by `id_animal + lact_number` to avoid crossing lactations. Lameness history is the sole exception — it searches a cow's *entire lifetime* record (`id_animal` only), because chronicity is a lifetime concept, per explicit instruction. Don't "fix" this to be lactation-scoped without checking whether the same reasoning applies to the 3-arm study.
- **The external chronicity classifier's `Repeat` vs. `Chronic` cutoff is a 1-day gap.** In practice this means almost any cow with 2+ lifetime lesion diagnoses ends up `Chronic`, regardless of whether those diagnoses were weeks or years apart (in the final 2-arm data: 236 `Chronic` vs. only 3 `Repeat`, out of a 592-cow cohort). Don't be surprised if `Repeat` is nearly empty again in the 3-arm data — that's the classifier's definition, not a bug. **Corollary worth knowing:** all 3 `Repeat` cows in the 2-arm data got that label purely because their most recent pre-enrollment diagnosis happened to land exactly 1 day after an earlier one. One of them had 11 lifetime lesion diagnoses and was arguably the most chronic cow in the whole cohort. `Repeat` was ultimately excluded from the trend plots for this reason — treat it as a timing artifact, not a clinical category.
- **A cow with no *lesion ever diagnosed* is folded into `New`, not given a separate 4th category.** This was an explicit modeling choice (not wanting an artificial 4th bucket alongside the classifier's real New/Repeat/Chronic). **Be precise about what this bucket actually is** — this was mis-described in the report's own prose for several rounds before being caught: `fxn_dz_status()` only assigns a `status_lesion` to rows where `trimonly == 0` (a lesion was actually found), so a cow's routine trim-only visits *never* produce a history row no matter how many she's had. "Folded into `New`" therefore means "no lesion ever diagnosed," **not** "no `LAME`/`FOOTRIM`/`TRIM` event at all" — very different populations. In the final 2-arm data, of 353 cows labeled `New`: 206 (58%) *do* have prior trim/LAME visits, just never one with a lesion; 126 (36%) got `New` from the classifier directly (a real first-ever diagnosis); only 21 (6%) truly had zero foot-care events before their alert.
- **A rolling (not fixed) lookback window is used wherever a "did the alert catch it in time" question reaches back before the alerting system existed.** A fixed N-day lookback isn't fair to cases found shortly after the alert system went live — there simply wasn't N days of alert history yet. Cap the lookback at `min(N, days since alert-system go-live)` for any similar "did the alert fire in time" analysis in the 3-arm study.
- **Every "first occurrence" rule is deliberate, not an oversight.** Wherever this report looks for "the" trim, diagnosis, staff check, or alert for a cow, it uses her first qualifying occurrence in the relevant window, not every occurrence, so a cow flagged/diagnosed repeatedly doesn't get double-counted or over-weighted.
- **Multiple *different* lesion types coded on the same day count as separate entries in the lesion-type breakdown chart; the same type coded twice on one day counts once.** This depends on the `fxn_collapse_lesions()` fix above actually being applied — verify it before reusing that chart pattern.

---

# Rounds 14-30 (added 2026-09-10)

Everything above was written at Round 13. The pilot ran to Round 30 and the
findings below matter more to a follow-up study than most of what precedes them,
because several are **design** lessons rather than coding ones.

## The biggest one: ascertainment, not disease

The pilot's most quotable result — **58 more cows with a lesion found in the
trimmed arm** (170/397 vs 127/452) — measures **who got inspected**, not who got
sick. TX cows were trimmed 90.4% of the time by protocol; Control cows 49.8%.
Allocation was random, so true lesion incidence is equal by construction.

Checked rather than assumed: among cows actually trimmed, **Control found a
lesion more often** (53.8% vs 45.1%), which is the signature of a
suspicion-driven population, not a healthier one.

**For an N-arm design: any "lesions found" outcome is confounded by inspection
rate unless the arms share a common inspection schedule.** Either impose one, or
choose outcomes that do not depend on being looked at (milk, culling,
time-to-event). This is a design constraint, not a limitation to note.

## `DSNLM` is an EXCLUSION, and I had it backwards twice

`DSNLM=90-1` on the `Low` route and `DSNLM=7-1` on the declines **excludes** cows
already alerted in that window, so the cowcard does not fill with duplicate
alarms. It is not "there was an alarm, therefore enroll."

Two separate rounds got this wrong in opposite directions by reasoning from the
syntax. **Ask the farm what a DairyComp command means. Do not infer it.**

## The daily batch stamps the LOAD date, not the observation date

The Nedap-to-DairyComp import runs about 05:00. An attention after ~05:00 on day
D is written with date D+1. Established empirically: no attention in the whole
export occurs before 05:00, 84% fall 18:00-24:00, and 61% of matched
attention/NEDLAME pairs are exactly +1 day apart.

Consequences that any similar study inherits:

- A `NEDLAME` dated ON the lesion day came from the **previous** day's attention
  and IS advance warning. `NEDLAME` is written before trimming on trim day.
- An **attention** on the lesion day cannot have produced an alert in time, so
  the sensor window must be strictly before the lesion date, `[d - N, d)`.
- Alerts landing 1-7 days after a trim are mostly the camera reacting to the
  trimmed cow. The pilot excluded 162 of them.

**Specify the timestamp semantics in the protocol.** They changed several
headline numbers here.

## An alert outside the window is still an alert

A cow flagged before the lookback opened, and never trimmed between that alert
and her lesion, is **not** a camera miss — the warning arrived and nobody used
it. That is a response failure.

This was not a corner case: 28 of 339 apparent misses, 26 of them never trimmed
in between, **21 of the 28 in the Control arm**. Recategorising them moved the
Control miss rate from 27.9% to 11.5% while barely touching TX.

The guard that keeps it honest: if she **was** trimmed after that alert, the
later lesion is a new episode the camera did not warn about, and she stays a
miss.

**The lookback window is a judgement call that moves the answer. Pre-specify it,
and pre-specify how out-of-window alerts are treated.**

## Comparing a level NAME is the most reliable way to lose data silently

Four instances in this project, every one silent — no error, no warning, a page
that renders with wrong numbers:

1. `detection_group` tested `"Never Alerted"` against a column holding
   `"Never Alerted (Not in Pilot Cohort)"`.
2. A standalone script filtered `"Flagged, Lost in Pipeline"` after the shared
   function moved to `"Flagged, but no alert in time"` — every verdict zeroed.
3. A `case_when()` and its `factor(levels=)` are two lists that must agree; one
   was edited.
4. A site still tested `'Never Flagged (True Miss)'` after the rename, putting
   every cow in one group and rendering blanks where percentages belonged.

**Two rules.** First, when renaming, search the **bare label text**, not the
quoted literal — a find-and-replace over `"Label"` will not match `'Label'`,
though R treats them identically.

Second, and this is the part we got half-right for several rounds:

> **Asserting the partition is necessary and NOT sufficient.** A partition
> assertion proves the parts sum to the whole and says nothing about whether the
> whole is the right size — and it is at its weakest exactly when the whole has
> collapsed to nothing. `0 + 0 + 0 == 0` passes.

**Guard the population as well as the partition.** Assert the expected category
is present in the input's vocabulary, so the error names the cause instead of
the symptom.

## Compute the base rate before believing a pattern in a hand-picked set

Two convincing leads died to this in one round. Five of thirteen problem cows
had a staff check on the matching foot within 4 days of a camera flag — which
looked like proof the flag reached the farm, until the herd-wide rate turned out
to be 30.4% against 38.5% here. Likewise "June startup teething" evaporated once
weekly volumes were plotted.

Related: **do not measure a change on the group that is defined by the outcome.**
A gate change that can only ever move cases one way was sized on the set defined
by "nothing blocked them", which is close to guaranteed to return zero. Measured
on the population that could actually cross the boundary, it moved 18 cases.

## Things the data could not answer, and what to demand up front

- **Score at flag is not in the export.** 69 pipeline cases were permanently
  unjudgeable because a `Low` flag on a cow scoring 31-69 who was correctly
  declined is indistinguishable from a lost flag. **Ask for score at flag.**
- **The daily file-in payload is not in the export.** 119 of 313 misses were
  cows the camera flagged whose alert never reached DairyComp, and the mechanism
  could not be identified from episode start/end/completion alone. **Ask for the
  file-in log**, or instrument the integration independently from day one.
- **`FTDAT` is a cow-level lifetime date**, not lactation-scoped. Scoping the
  lookup to the current lactation hid prior-lactation trims and left 18 cases
  wrongly unexplained.
- **`MNFRS` cannot be used to check cohort membership** — it is pre-assigned
  herd-wide, and 6,141 cows carry a value having never received a `NEDLAME`.
  Enrollment requires an actual alert event.

## Reporting rules that came out of review

- **Never state a null as a finding.** "No real impact is seen" over 53 culling
  events became "too few events to answer either way".
- **Never let a headline number travel without its caveat.** The 58-cow figure
  reads as a treatment effect to anyone meeting it alone.
- **Interpolate every number**; a figure typed into prose or a table title goes
  stale on the next rebuild, and did.
- **Read the rendered page, not just the code.** Two defects this project shipped
  were valid code producing prose that was false about the data — invisible to
  static checks and to a successful render.
- **A number appearing in two documents will go stale in one of them.** Compute
  it once, in a shared function, and have both read it.

---

# Designing the follow-up: lessons from the proposal work (2026-09-10)

These come from sizing the three-arm study, not from the pilot analysis. Several
are the kind of error that produces a confident wrong number rather than a crash.

## Denominator discipline: convert every sample size to ONE unit before comparing

Sample sizes were quoted in three different units and read as though comparable:
enrolled cows, cows with a lesion, and cows re-examined. Converted properly, the
cure outcome went from an apparent 3,330 enrolled to 9,321 — the same figure,
three times further from the truth each time the denominator was skipped.

**Rule: publish every sample size in the unit the study actually enrols, and show
the conversion factors.** Here they were 35.0% of alerted cows having a lesion
found and 60.2% of white-line/sole-ulcer index cases being re-examined.

## Within-herd randomisation is NOT cluster randomisation

The instinct is to apply a design effect of `1 + (m-1)·ICC` for herds. **That is
wrong when cows are randomised to arms within each herd.** Herd is then a
*blocking* factor, and blocking *removes* between-herd variance from the contrast
rather than adding to it. Applying a cluster design effect would have inflated
this study several-fold for no reason.

What *does* inflate is **treatment-effect heterogeneity**: `Var = σ²/n + τ²/k`,
with `k` the number of herds. At a plausible τ of 0.5 kg, four herds cost ×1.96
and six cost ×1.49. **More herds buy protection against heterogeneity far more
efficiently than more cows do** — and at τ = 0.75, four herds cannot reach the
target at *any* sample size while six still can.

## An interaction term doubles the sample size, and the multiplier is not universal

`treatment * covariate` makes the reported treatment coefficient the effect
*within one stratum*, estimated from half the cows. Verified by fitting both
models to identical data:

| Model | SE | Estimate |
|---|---|---|
| `treatment * history` | 0.844 | 1.945 (one stratum) |
| `treatment + history` | 0.597 | 2.27 (average) |

SE ratio **1.414 — exactly √2 — so exactly ×2** on a linear model. But the
logistic cure model gave **1.59×**, not 2×. **Simulate the penalty for the model
you are actually fitting; do not carry it across from another.**

This also explains apparent disagreements between a closed-form calculation and
a simulation: the formula gives the *average* effect, the interaction model's
coefficient gives a *stratum* effect. They answer different questions and neither
is wrong.

## The measurement window changes which contrast is cheapest, and can flip the ordering

For a design with immediate, delayed and control arms, contrast sizes as a
fraction of the full effect:

| Window | 1 v 3 | 2 v 3 | 1 v 2 |
|---|---|---|---|
| 28 days | 0.81 | **−0.19** | **1.00** |
| 60 days | 0.78 | 0.33 | 0.44 |
| 90 days | 0.77 | 0.46 | 0.31 |
| 180 days | 0.76 | 0.61 | 0.15 |

**Different questions want different windows in the same study.** The delayed-arm
contrast is ten times cheaper at 28 days than at 90, because the delayed arm
spends the rest of the window catching up. Choosing one window for everything is
the natural mistake.

Note the negative at 28 days: the delayed arm looks *worse than doing nothing*
early on, because it is protocol-bound to wait while the control arm can be
picked up at any time. **An early interim analysis will show that, and it needs
saying before someone reads it as harm.**

## A window shorter than the process can give the WRONG SIGN

The pilot's three-month culling figure showed lame cows culled *less* than
non-lame (5.0% vs 7.0%). On the herd's multi-year records the association is the
other way and grows with the window:

| Window | No early lesion | Early lesion | Gap |
|---|---|---|---|
| 90 days | 28.1% | 33.0% | +4.9 |
| 365 days | 45.0% | 52.3% | **+7.3** |

**Before reporting a null from a short window, check whether the process being
measured is slower than the window.** A cow diagnosed and treated in week one is
not culled in week eight.

## A composite endpoint is not automatically cheaper

Pooling outcomes into one dollar figure looks like it should help. It does not
when one component is a rare-but-expensive binary: a $1,500 event at 46%
prevalence has an SD of $748 per cow, which swamps a milk signal worth $76.
Sizing on the composite needed 43,000 cows against 5,800 on milk alone.

**A composite is the right thing to report and often the wrong thing to power on.**

## Do not size a change on the group defined by its outcome

To size a gate change that can only ever move cases one way, measure on the
population that **could cross the boundary** — never on the group already sitting
on one side. Sizing on "cases nothing blocked" returns approximately zero by
construction.

## dplyr `summarize()` evaluates sequentially — do not reuse the input column name

```r
summarize(n_trim = sum(trimmed), pct = 100 * mean(trimmed))   # correct
summarize(trimmed = sum(trimmed), pct = 100 * mean(trimmed))  # WRONG
```

The second makes `mean()` see the sum, not the logical vector. It produced
"35,900% trimmed" once — obvious — and a plausible-looking wrong percentage twice
more. **Hit three times in one project.** Never name a summarised column after the
column being summarised.

## Read the model's source before reproducing its assumptions

The break-even calculator's IOFC turned out to be `milk_price − feed_cost /
conversion` = $0.254/kg, which matched the assumption in use — but the *cost*
side had no trimming term at all, which changed the break-even by 41%. Fetching
the rendered page showed the inputs; only the source showed what was missing.
