# Reusable Methodology Patterns

Generalizable analysis patterns from the 2-arm NEDLAME pilot report, written to carry over cleanly to an N-arm (e.g. 3-arm) version of the same RCT design: cows get a triggering health-monitor alert, get split into treatment arms by some group-code field, and the study asks how the arms differ on downstream outcomes (production, time-to-next-event, independent staff detection, miss-rate vs. the monitor, lameness history, culling).

## 1. Deriving treatment-group membership from a field that drifts over time

The group-code field (`MNFRS` in the 2-arm study) was not a stable per-cow attribute — it took a "not yet enrolled" placeholder value before a cow's first qualifying alert, then took on a real arm value once she was flagged. The fix generalizes directly to N arms:

1. Take the **first** qualifying alert event per cow (`group_by(id_animal) |> slice_min(alert_date, n = 1)`).
2. Read the group-code field off *that specific row*, not any other row for the cow.
3. Empirically verify the group-code field is stable across all of a cow's alert-type rows (even if it drifts elsewhere in her history) before trusting it.
4. Map raw codes to arm labels explicitly (`case_when(code == "1" ~ "Arm A", code == "2" ~ "Arm B", code == "3" ~ "Arm C", ...)`), and `filter(!is.na(arm))` to drop any cow whose code doesn't map to a known arm.

## 2. The cohort table is the shared foundation — protect it

Every downstream section joins against one central `cohort` table (one row per cow who ever got the triggering alert). Any bug that corrupts `cohort` corrupts *every* section, not just the one you're working on. When adding a new join that enriches `cohort` (e.g. attaching a history label, a lactation-stage covariate), always:
- Check `nrow(cohort)` before and after the join — it should be unchanged unless you're deliberately filtering the cohort itself.
- Use the filter-before-join pattern (see `lessons-learned.md`) for anything that could otherwise drop a non-matching cow.

## 3. Lactation-safe joins vs. lifetime joins — pick deliberately, per question

Two different scoping rules coexist in this analysis, and mixing them up produces wrong (but plausible-looking) numbers:
- **Lactation-scoped** (`id_animal + lact_number`): used for anything about *this specific lameness episode* — time to next event, staff detection around this alert, whether this specific case was caught by the monitor. Prevents a previous lactation's unrelated event from contaminating a "did X happen after this alert" question.
- **Lifetime** (`id_animal` only): used for anything that's conceptually a lifetime trait — chronicity/history classification. A cow's disease history doesn't reset when she freshens.

For each new analysis question in the N-arm study, explicitly decide which scoping rule applies *before* writing the join, rather than defaulting to whichever one was used in the nearest existing code.

## 4. Milk-record resolution when the raw ID is ambiguous

If milk records only carry a raw tag ID (not a composite animal+birthdate key), and that raw ID can be reused across different animals over time (retagging), resolve each milk row to a specific animal-lactation by finding the animal-lactation with the **nearest preceding freshening date** — not by trusting a `date_dry`/`date_next_fresh` window, which can be open-ended (still active) for a stale, never-closed-out record from a *different, earlier* animal that happened to reuse the same tag. See `functions/fxn_read_milk_folder.R`'s `fxn_resolve_milk_to_lactation()` for the working implementation; it also caps days-in-milk at a sanity threshold (450 days) as a backstop against any remaining resolution collisions.

## 5. Normalizing production trends across cows at different points in their own lactation

Don't compare raw production levels across cows flagged at very different days-in-milk. Normalize each cow's own time series to **% of her own pre-alert baseline** (mean over a short pre-alert window, e.g. 7 days) before averaging across cows within an arm. This isolates the *shape* of the trend/recovery from each cow's absolute production level. Guard against near-zero baselines (divide-by-near-zero blows up the ratio) by dropping cows below a small baseline floor.

## 6. Kaplan-Meier curves faceted by a covariate

`ggsurvfit`/`survival::survfit2()` only expose a single combined `strata` string when you fit `Surv(...) ~ groupA + groupB` — there's no way to `facet_wrap()` a ggsurvfit object by one of the grouping variables directly. Instead: loop over the facet variable's levels, fit `survfit2(Surv(...) ~ groupA, data = subset_for_this_level)` separately for each, extract `broom::tidy(fit)` (gives `time`, `estimate` = survival probability, `strata`), stack the results with the facet-level attached as a column, and build the plot manually with `ggplot() + geom_step() + facet_wrap(~facet_var)`. Skip any level that doesn't have both arms represented with enough events (`n_distinct(subset$arm_group) == n_arms && nrow(subset) >= some_floor`) rather than letting `survfit2()` error or produce a degenerate single-arm curve — and report which levels were skipped, don't silently drop them.

## 7. A monitor's "miss rate" needs a rolling lookback if the monitor has a go-live date

If checking "did the alert fire within N days before this outcome" and the alerting system itself only went live partway through the data, a fixed N-day lookback unfairly penalizes outcomes shortly after go-live (there wasn't N days of alert history yet for the system to have caught anything in). Cap the lookback per-case at `min(N, days_since_go_live_at_this_outcome_date)`, and report how many cases had a truncated window so the reader knows which results are least reliable.

## 8. Handling multiple diagnoses on the same day

When a single visit/date can produce multiple distinct diagnosis codes for the same animal (e.g. two different lesion types found at one exam), a naive collapse to "one row per date" can accidentally lose information if it picks a single representative row's flags rather than taking the union across all of that date's rows. When collapsing multi-row-per-date data: compute the union (`max()`) of type-flag columns from the **original, uncollapsed** data first, *then* reduce to one representative row for the remaining columns — not the other order (see `lessons-learned.md` bug #2 for what goes wrong if you get the order backwards).

## 9. "First occurrence only" as a standing rule, stated once

Decide up front whether repeated occurrences (repeated alerts, repeated diagnoses, repeated staff checks) should count once per cow or once per occurrence, and apply that rule consistently across every question in the report. This pilot used "first occurrence only" throughout (a cow flagged/diagnosed more than once doesn't get extra weight in any %), stated as a single methodology note near the top of the report rather than repeated ad hoc in each section.

## 10. Keep it descriptive, not confirmatory, at the discussion stage

At an early/discussion stage of a pilot (small early sample, short observation window), prefer descriptive summaries (%, counts, KM curves with CI ribbons) over formal significance tests (p-values). A p-value invites over-interpretation of what's meant to be a discussion starting point, and with thin subgroup cells it's easy for a "significant" result to be noise. Add hypothesis tests back in once the study has matured and a confirmatory analysis is actually the goal.
