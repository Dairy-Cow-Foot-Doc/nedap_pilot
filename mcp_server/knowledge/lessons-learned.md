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
