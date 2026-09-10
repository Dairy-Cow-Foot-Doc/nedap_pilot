# Shared analysis functions for the NEDLAME pilot reports.
#
# Each report sources this file and calls only the pieces it needs, keeping its
# own prose, tone and choice of what to display. The point is that the RULES -
# the exclusions, the house conventions, the join order - live in one place, so
# a fix reaches every report instead of having to be applied to each by hand.
#
# Every function returns a NAMED LIST using the same object names the reports
# already use, so a report can splat it into its environment:
#
#   list2env(fxn_build_cohort(...), envir = environment())
#
# Bodies were lifted verbatim from the working report chunks and wrapped; the
# rendered output was verified identical afterwards.

library(tidyverse)
# fxn_build_q6() uses survfit2() (ggsurvfit) and Surv() (survival). Declared here
# so the file works when sourced on its own, not only inside a report that
# happens to have loaded them.
library(survival)
library(ggsurvfit)

# Build the pilot cohort from NEDLAME alerts.
# 
# Applies the analysis cut-off and the post-trim artifact exclusion: an alert
# dated 1-`params$post_trim_exclusion_days` days AFTER a trim is very likely the
# camera reading that cow's own post-trim gait, not an independent catch.
# 
# 'Trim' means LAME + FOOTRIM + TRIM. This farm codes a trim-with-a-lesion as
# LAME with no separate FOOTRIM, so a FOOTRIM/TRIM-only filter misses exactly
# the trims that matter. That mistake has been made three separate times in
# this project - do not reintroduce it.
fxn_build_cohort <- function(events_all, animal_lactations, animals, date_max_pull, params) {
  # One row per cow (id_animal) that ever got a NEDLAME alert - grouped by
  # id_animal alone since a cow only has one "first" NEDLAME ever. Treatment
  # group is read off the MNFRS value on the FIRST NEDLAME event for that cow
  # - MNFRS is stable across a cow's NEDLAME rows even though it drifts over
  # her broader event history (0 before enrollment, 1/2 once enrolled).
  # Hard analysis cut-off. The raw Nedap sensor export ends on
  # params$analysis_end_date, so alerts and lesion cases after it cannot be
  # checked against what the camera actually saw. Rather than carry a partly
  # checkable tail, entry into the analysis stops there for BOTH alerts (here)
  # and lesion cases (Q4). Follow-up events are deliberately NOT capped - a
  # cow who entered on/before the cut-off keeps every trim, cull and milk
  # record recorded after it, which is what time-to-event needs.
  analysis_end <- ymd(params$analysis_end_date)
  
  first_nedlame_raw <- events_all |>
    filter(Event == "NEDLAME", date_event <= analysis_end) |>
    group_by(id_animal) |>
    slice_min(date_event, n = 1, with_ties = FALSE) |>
    ungroup() |>
    transmute(
      id_animal, id,
      first_nedlame_date = date_event,
      alert_type = Remark,
      tx_group = case_when(
        MNFRS == "1" ~ "TX (Trim)",
        MNFRS == "2" ~ "Control",
        TRUE ~ NA_character_
      )
    ) |>
    filter(!is.na(tx_group))
  
  # lact_number is deliberately NOT taken from the raw NEDLAME event's own
  # field - right at a freshening transition (dry -> fresh, same day or one
  # day apart), DC's raw event can carry a stale lact_number from the
  # lactation that just ended rather than the one that just started (found
  # in 2 of 718 cows once the dataset grew past ~700 alerts: their alert
  # date fell after date_next_fresh/on date_fresh of the FOLLOWING
  # lactation, yet the raw event said the OLD lact_number). Resolving to
  # whichever lactation was actually active as of the alert date - the same
  # nearest-preceding-fresh-date pattern already used for the milk join -
  # fixes this without needing to trust the raw field.
  first_nedlame <- first_nedlame_raw |>
    inner_join(
      animal_lactations |>
        filter(!is.na(date_fresh)) |>
        select(id_animal, lact_number, date_fresh, date_dry, date_next_fresh),
      by = "id_animal",
      relationship = "many-to-many"
    ) |>
    filter(date_fresh <= first_nedlame_date) |>
    group_by(id_animal) |>
    slice_max(date_fresh, n = 1, with_ties = FALSE) |>
    ungroup()
  
  # Flag cows whose FIRST NEDLAME fired 1-`r params$post_trim_exclusion_days`
  # days AFTER a recorded trim, same cow-lactation - per the farm's
  # confirmed data-load schedule (NEDLAME's daily batch loads at ~5am and
  # stamps each alert with the day it was LOADED, not necessarily the day
  # the underlying sensor attention happened - an attention any time after
  # ~5am on day D gets logged with date D+1), an alert dated on or before
  # the trim date is a genuine independent catch, but one dated 1+ days
  # AFTER the trim is very likely the camera picking up that cow's own
  # post-trim gait change, not a new problem. It got through DC's own
  # FTDAT suppression gate only because the trim record itself is commonly
  # entered a day or two late (backdated to the actual trim date) - it
  # simply wasn't in the system yet when NEDLAME's batch ran. See the new
  # "Excluded" section below for the full writeup and examples.
  #
  # "Trim" here means LAME, FOOTRIM, *or* TRIM - same definition already
  # established for Q4's FTDAT suppression gate (Round 9): a LAME visit
  # IS the trim whenever the trimmer finds and codes a lesion at that
  # same encounter, it just doesn't also get a separate FOOTRIM code that
  # day. An earlier version of this exact chunk only checked
  # FOOTRIM/TRIM, which missed exactly this case - cow 7207's LAME (White
  # Line) visit on 06/11 was her actual trim, and NEDLAME fired the very
  # next day (confirmed directly against her real cowcard).
  trims_all <- events_all |>
    filter(Event %in% c("LAME", "FOOTRIM", "TRIM")) |>
    select(id_animal, lact_number, trim_date = date_event) |>
    distinct()
  
  post_trim_check <- first_nedlame |>
    select(id_animal, lact_number, first_nedlame_date) |>
    inner_join(trims_all, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(trim_date < first_nedlame_date, trim_date >= first_nedlame_date - params$post_trim_exclusion_days) |>
    group_by(id_animal, lact_number) |>
    summarize(days_since_nearest_trim = min(as.numeric(first_nedlame_date - trim_date)), .groups = "drop")
  
  first_nedlame <- first_nedlame |>
    left_join(post_trim_check, by = c("id_animal", "lact_number")) |>
    mutate(flagged_post_trim = !is.na(days_since_nearest_trim))
  
  # Attach lactation-stage context (date_fresh/date_dry) so every downstream
  # join can be scoped to id_animal + lact_number, never crossing into a
  # different lactation for the same cow.
  all_nedlame_cows <- first_nedlame |>
    left_join(animals |> select(id_animal, date_left), by = "id_animal") |>
    mutate(
      dim_at_nedlame = as.numeric(first_nedlame_date - date_fresh),
      date_lact_end = pmin(
        coalesce(date_dry, date_next_fresh, date_max_pull),
        date_max_pull,
        na.rm = TRUE
      ),
      # Observation actually ends when the cow leaves the herd, if that comes
      # first: a culled/dead cow can't have a subsequent trim, so counting her
      # as still at risk inflates the denominator and understates the event
      # rate. date_lact_end alone ignored this. pmax() floors it at her alert
      # date so a data error can't produce negative follow-up.
      date_obs_end = pmax(
        pmin(date_lact_end, coalesce(date_left, date_max_pull), na.rm = TRUE),
        first_nedlame_date
      )
    )
  
  # `cohort` (used throughout Q1-Q3, Q5, Q6) excludes the flagged cows;
  # `cohort_excluded_post_trim` keeps them, visibly, for the "Excluded"
  # section - nothing is silently dropped. Q4 is deliberately NOT scoped
  # to `cohort` (it pulls NEDLAME/lesion history from the whole herd
  # directly), so this exclusion does not affect Q4's miss-rate numbers.
  cohort <- all_nedlame_cows |> filter(!flagged_post_trim)
  cohort_excluded_post_trim <- all_nedlame_cows |> filter(flagged_post_trim)
  
  n_tx <- sum(cohort$tx_group == "TX (Trim)")
  n_control <- sum(cohort$tx_group == "Control")
  n_excluded_post_trim <- nrow(cohort_excluded_post_trim)

  list(analysis_end = analysis_end, first_nedlame_raw = first_nedlame_raw, first_nedlame = first_nedlame, trims_all = trims_all, post_trim_check = post_trim_check, all_nedlame_cows = all_nedlame_cows, cohort = cohort, cohort_excluded_post_trim = cohort_excluded_post_trim, n_tx = n_tx, n_control = n_control, n_excluded_post_trim = n_excluded_post_trim)
}

# Build the lesion dataset and attach each cow's lameness history at enrolment.
# 
# Returns an AUGMENTED cohort (adds history_group), so assign the result back.
# 
# History is scoped to id_animal only, NOT id_animal + lact_number - the one
# deliberate exception to lactation-scoping in this analysis, because chronicity
# is a lifetime concept. Do not 'fix' it to be lactation-scoped.
# 
# Candidate history rows are filtered BEFORE the join, not after. Filtering a
# left_join afterwards silently drops a cow from the cohort entirely instead of
# labelling her - that bug once removed ~11% of the cohort from every section.
fxn_build_lame_history <- function(events_formatted, cohort) {
  # These four come from elsewhere: fxn_trim_vars/fxn_dz_status are fetched live
  # from GitHub by fxn_load_os_fxns(), while fxn_code_lesions/fxn_collapse_lesions
  # MUST be the LOCAL overrides, sourced AFTER that fetch. If the upstream copies
  # win there is no error - this farm codes routine no-lesion trims as "NONE" in
  # the REMARK field, which the upstream fxn_code_lesions() does not check, so
  # every routine trim is silently reclassified as lesion-bearing. That flows
  # into lame_data and therefore Q2, Q5 and the whole Q4 miss analysis. Fail
  # loudly here instead.
  for (.f in c("fxn_code_lesions", "fxn_collapse_lesions", "fxn_trim_vars", "fxn_dz_status")) {
    if (!exists(.f, mode = "function")) {
      stop("fxn_build_lame_history(): ", .f, "() not found. Source functions/fxn_load_os_fxns.R ",
           "and THEN the local overrides functions/fxn_code_lesions.R and ",
           "functions/fxn_collapse_lesions.R before calling this.", call. = FALSE)
    }
  }
  # Same lesion-coding / chronicity pipeline as report_explore_lame_new.qmd,
  # just kept at the lactation grain (lact_number carried through) so the
  # "history at enrollment" lookup below never crosses lactations.
  all_lesions <- c("dd", "footrot", 'wld', "sole_ulcer", "injury",
                    "cork", "other", "hemorrhage",
                    "sole_fracture", "toe_ulcer", "thin",
                    "inf", "noninf", "toe", "axial", "lesion")
  diseases <- c("inf", "noninf", "lesion")
  
  lame_data <- events_formatted |>
    select(id_animal, lact_number, date_event, event,
           remark_letters1, protocols_letters1, location_event, protocols) |>
    filter(event %in% c("LAME", "TRIM", "FOOTRIM")) |>
    fxn_code_lesions(protocol_var = protocols_letters1, remark_var = remark_letters1) |>
    filter(!is.na(trimonly)) |>
    mutate(
      noninf = case_when(
        other == 1 & str_detect(protocols_letters1, "Ab") ~ 1,
        .default = noninf),
      other = case_when(
        other == 1 & str_detect(protocols_letters1, "Ab") ~ 0,
        .default = other)
    ) |>
    fxn_collapse_lesions(lesions = all_lesions) |>
    fxn_trim_vars(location_event, id_animal, date_var = date_event, trimonly_var = trimonly) |>
    fxn_dz_status(disease_cols = diseases, event_filter = trimonly == 0)
  
  # Each NEDLAME cow's lameness-history label as of (at/before) her first
  # NEDLAME date, using her FULL lifetime record (all lactations - lame_data
  # goes back to 2021), not scoped to her current lactation. Unlike every
  # other join in this report, this one is intentionally NOT lactation-scoped
  # per explicit user direction: chronicity is a lifetime concept, and the
  # ~5 years of history available should be used rather than artificially
  # resetting it at each freshening.
  #
  # IMPORTANT: candidate history rows are filtered to "at/before enrollment"
  # BEFORE joining to cohort, not after (same reasoning as fxn_time_to_next()
  # above) - filtering after a left_join would silently DROP a cow from
  # `cohort` entirely instead of correctly labeling her. An earlier version
  # of this exact chunk had that bug and was quietly dropping 49 of 434 cows
  # (~11%) from the ENTIRE cohort - not just from Q5, but from every section,
  # since `cohort` is the shared base table.
  history_lookup <- lame_data |>
    select(id_animal, date_event, status_lesion) |>
    filter(!is.na(status_lesion))
  
  valid_history <- history_lookup |>
    inner_join(
      cohort |> select(id_animal, lact_number, first_nedlame_date),
      by = "id_animal"
    ) |>
    filter(date_event <= first_nedlame_date) |>
    select(id_animal, lact_number, date_event, status_lesion)
  
  # A cow with no LESION ever diagnosed before her NEDLAME alert has no
  # status_lesion to inherit - fxn_dz_status() only assigns a status to
  # trimonly == 0 rows (an actual lesion found), so a cow's routine
  # trim-only visits (trimonly == 1) never produce a status_lesion, no
  # matter how many she's had. This is NOT the same as "no LAME/TRIM/
  # FOOTRIM event at all" - checked directly, most of these cows (206 of
  # 353 in the current cohort) DO have prior trim/LAME events, just never
  # one where a lesion was found; only a small remainder (~21 of 353)
  # truly have zero foot-care events before their alert. Rather than
  # invent a 4th bucket for either case, she's folded into "New" - the
  # same label her eventual first-ever diagnosis would get, and the
  # closest existing category to "no established chronic pattern."
  cohort <- cohort |>
    left_join(valid_history, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    group_by(id_animal, lact_number) |>
    slice_max(date_event, n = 1, with_ties = FALSE, na_rm = FALSE) |>
    ungroup() |>
    mutate(history_group = if_else(is.na(status_lesion), "New", status_lesion)) |>
    select(-date_event, -status_lesion)
  
  history_levels <- c("New", "Repeat", "Chronic")
  cohort <- cohort |>
    mutate(history_group = factor(history_group, levels = history_levels))

  list(all_lesions = all_lesions, diseases = diseases, lame_data = lame_data, history_lookup = history_lookup, valid_history = valid_history, cohort = cohort, history_levels = history_levels)
}

# Work out which animals are enrolled in SmartSight, allowing for renumbering.
# 
# Animal numbers get reassigned. DairyComp logs the change as an XID event whose
# Remark holds the OLD number, and old numbers stay in the extract as animals in
# their own right. A cow renumbered after enrolling looks ABSENT under her current
# number while being present under her old one, so enrollment is judged against
# current AND prior numbers.
# 
# EID cannot be used to bridge to the platform lists: it is the USDA ID
# (USA0032...), not the transponder SmartSight carries as Tag 1 (984000...).
fxn_build_enrolled_ids <- function(events_all, cows_smartsight) {
  # Nedap runs two separate platform instances at this farm - "Activity"
  # (used by farm staff daily) and "SmartSight" (mobility monitoring,
  # generates NEDLAME) - kept separate at the farm's request to avoid
  # confusion when checking the Nedap platform. A cow absent from
  # SmartSight's animal list was never being monitored for lameness at
  # all, regardless of what the raw attentions export's date coverage
  # shows - this check is animal-level enrollment, not date-bound, so it
  # can resolve cases the date-bound attentions export above can't (see
  # the Platform Enrollment Check subsection in Q4).
  # Uses the cows_smartsight passed in. This previously re-read both CSVs from
  # hard-coded paths right here, which silently discarded the argument - the
  # function looked parameterised but was not, and it broke outside the project
  # root. cows_activity was read but never used or returned, so it is gone.
  stopifnot(is.data.frame(cows_smartsight), "id" %in% names(cows_smartsight))
  
  # Animal numbers get reused and reassigned. DairyComp records an ID change as
  # an XID event whose Remark holds the OLD number, and 150 of those old numbers
  # are still present in this extract as animals in their own right. A cow
  # renumbered after she was enrolled therefore looks ABSENT from SmartSight
  # under her current number while being present under her old one - confirmed
  # on cow 23143, renumbered from 14347 on 2026-08-06 and enrolled all along as
  # 14347. Checking the current number alone would call her unmonitored.
  id_aliases <- events_all |>
    filter(Event == "XID") |>
    transmute(id = as.character(id), alias = trimws(as.character(Remark))) |>
    filter(!is.na(alias), grepl("^[0-9]+$", alias)) |>
    distinct()
  
  smartsight_ids <- unique(cows_smartsight$id)
  # a cow counts as enrolled if her current OR any prior number is on the list
  enrolled_ids <- union(
    smartsight_ids,
    id_aliases$id[id_aliases$alias %in% smartsight_ids]
  )
  n_rescued_by_alias <- length(setdiff(
    id_aliases$id[id_aliases$alias %in% smartsight_ids], smartsight_ids))

  list(id_aliases = id_aliases, smartsight_ids = smartsight_ids, enrolled_ids = enrolled_ids, n_rescued_by_alias = n_rescued_by_alias)
}

# Time from the first alert to the next trim/LAME event.
# 
# Candidate events are filtered to the valid post-alert window BEFORE joining to
# the cohort. Filtering after a left_join drops a cow who has events in her
# history but none in the window, instead of correctly censoring her.
# 
# Censoring uses cohort$date_obs_end, which already accounts for culling.
fxn_build_q2 <- function(cohort, events_formatted, lame_data) {
  next_events <- events_formatted |>
    filter(event %in% c("LAME", "FOOTRIM", "TRIM")) |>
    select(id_animal, lact_number, date_event, event) |>
    distinct()
  
  lesion_lookup <- lame_data |> select(id_animal, lact_number, date_event, event, lesion)
  
  # IMPORTANT: candidate events are filtered to the valid post-NEDLAME window
  # BEFORE joining to cohort, not after. Filtering after a left_join would
  # silently DROP a cow entirely (rather than correctly censoring her)
  # whenever she has trim/LAME events somewhere in her history but none
  # inside the valid window - an earlier version of this code had exactly
  # that bug and was quietly excluding ~45% of cows from the "any event"
  # curve (and a different ~25% from the "with lesion" curve), which is
  # also why the two curves looked identical - they weren't being computed
  # over the same denominator.
  fxn_time_to_next <- function(candidate_events) {
    valid_candidates <- candidate_events |>
      inner_join(
        cohort |> select(id_animal, lact_number, first_nedlame_date, date_obs_end),
        by = c("id_animal", "lact_number")
      ) |>
      filter(date_event > first_nedlame_date, date_event <= date_obs_end) |>
      select(id_animal, lact_number, date_event)
  
    cohort |>
      left_join(valid_candidates, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
      group_by(id_animal, lact_number) |>
      slice_min(date_event, n = 1, with_ties = FALSE, na_rm = FALSE) |>
      ungroup() |>
      mutate(
        event_occurred = as.integer(!is.na(date_event)),
        days_to_event = if_else(
          event_occurred == 1,
          as.numeric(date_event - first_nedlame_date),
          as.numeric(date_obs_end - first_nedlame_date)
        )
      )
  }
  
  q2_any <- fxn_time_to_next(next_events)
  
  next_events_lesion <- next_events |>
    left_join(lesion_lookup, by = c("id_animal", "lact_number", "date_event", "event")) |>
    filter(!is.na(lesion) & lesion == 1)
  
  q2_lesion <- fxn_time_to_next(next_events_lesion)

  list(next_events = next_events, lesion_lookup = lesion_lookup, q2_any = q2_any, next_events_lesion = next_events_lesion, q2_lesion = q2_lesion)
}

# Did farm staff identify the cow themselves, via a CHKLAME event?
# 
# A CHKLAME on the SAME day as the alert counts as staff-identified, folded into
# the pre-alert bucket with <= rather than falling between strict < and >.
fxn_build_q3 <- function(cohort, events_formatted) {
  chklame <- events_formatted |>
    filter(event == "CHKLAME") |>
    select(id_animal, lact_number, date_event) |>
    distinct()
  
  # "Trim" means LAME + FOOTRIM + TRIM, the house rule throughout this report:
  # when the trimmer finds a lesion at the visit, that visit is coded LAME and
  # gets no separate FOOTRIM code, so a FOOTRIM/TRIM-only filter silently misses
  # exactly the trims most likely to matter. (This chunk used FOOTRIM/TRIM alone
  # until an audit caught it - the third time that same mistake appeared in this
  # report. Impact here was one cow; the fix is for consistency, not magnitude.)
  trims <- events_formatted |>
    filter(event %in% c("LAME", "FOOTRIM", "TRIM")) |>
    select(id_animal, lact_number, date_event) |>
    distinct()
  
  # A CHKLAME on the SAME day as the NEDLAME alert counts as staff-identified
  # too (folded into the "pre-week" bucket via <= rather than <), rather than
  # falling through the gap between "before" (strict <) and "after" (strict >).
  pre_week <- cohort |>
    inner_join(chklame, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(date_event >= first_nedlame_date - 7, date_event <= first_nedlame_date) |>
    distinct(id_animal, lact_number)
  
  first_post_chklame <- cohort |>
    inner_join(chklame, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(date_event > first_nedlame_date) |>
    group_by(id_animal, lact_number) |>
    slice_min(date_event, n = 1, with_ties = FALSE) |>
    ungroup() |>
    rename(chklame_date = date_event)
  
  first_post_trim <- cohort |>
    inner_join(trims, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(date_event > first_nedlame_date) |>
    group_by(id_animal, lact_number) |>
    slice_min(date_event, n = 1, with_ties = FALSE) |>
    ungroup() |>
    select(id_animal, lact_number, trim_date = date_event)
  
  post_flag <- first_post_chklame |>
    left_join(first_post_trim, by = c("id_animal", "lact_number")) |>
    filter(is.na(trim_date) | chklame_date < trim_date) |>
    distinct(id_animal, lact_number)
  
  staff_id <- cohort |>
    mutate(
      staff_identified = as.integer(
        paste(id_animal, lact_number) %in% paste(pre_week$id_animal, pre_week$lact_number) |
        paste(id_animal, lact_number) %in% paste(post_flag$id_animal, post_flag$lact_number)
      )
    )

  list(chklame = chklame, trims = trims, pre_week = pre_week, first_post_chklame = first_post_chklame, first_post_trim = first_post_trim, post_flag = post_flag, staff_id = staff_id)
}

# Milk production around the first alert, normalised to each cow's own baseline.
# 
# The milk extract is pulled separately from the DairyComp events and lags behind
# them, so the number of cows contributing FALLS across the x-axis: a cow alerted
# less than milk_window_post days before the milk data ends has no day-30 record.
# n_milk_cows counts anyone with a usable baseline and at least one post-alert
# record, which is a much larger group than the one behind the right-hand end of
# the curve. Report n_milk_day30 alongside it or readers will assume otherwise.
fxn_build_q1 <- function(cohort, milk_resolved, params) {
  milk_cohort <- cohort |>
    inner_join(
      milk_resolved |> select(id_animal, lact_number, milk_date, dmlk1),
      by = c("id_animal", "lact_number"),
      relationship = "many-to-many"
    ) |>
    mutate(day_rel = as.numeric(milk_date - first_nedlame_date)) |>
    filter(day_rel >= -params$milk_window_pre, day_rel <= params$milk_window_post)
  
  baseline <- milk_cohort |>
    filter(day_rel >= -params$milk_baseline_days, day_rel <= -1) |>
    group_by(id_animal, lact_number) |>
    summarize(baseline_dmlk1 = mean(dmlk1, na.rm = TRUE), .groups = "drop")
  
  milk_norm <- milk_cohort |>
    inner_join(baseline, by = c("id_animal", "lact_number")) |>
    filter(baseline_dmlk1 >= 5) |> # drop the rare near-zero baseline (unreliable % denominator)
    mutate(pct_of_baseline = dmlk1 / baseline_dmlk1 * 100)
  
  n_milk_cows <- n_distinct(milk_norm$id_animal)
  
  # The milk extract is pulled separately from the DairyComp events and lags
  # behind them, so the number of cows contributing FALLS as day_rel grows: a
  # cow alerted less than 30 days before the milk data ends simply has no day-30
  # record. n_milk_cows counts anyone with a usable baseline and at least one
  # post-alert record, which is a much larger group than the one behind the
  # right-hand end of the curve - quote both or the reader assumes the whole
  # cohort is behind the day-30 figure. The n >= 5 filter on the plots below
  # shortens the line rather than making it noisy, so the drop-off is invisible
  # unless it is stated.
  milk_coverage_end <- max(milk_norm$milk_date, na.rm = TRUE)
  n_milk_day30 <- n_distinct(milk_norm$id_animal[milk_norm$day_rel == params$milk_window_post])
  n_no_milk_at_all <- sum(cohort$first_nedlame_date > milk_coverage_end)
  
  trend <- milk_norm |>
    group_by(tx_group, day_rel) |>
    summarize(
      mean_pct = mean(pct_of_baseline, na.rm = TRUE),
      se_pct = sd(pct_of_baseline, na.rm = TRUE) / sqrt(n()),
      n = n(),
      .groups = "drop"
    )

  list(milk_cohort = milk_cohort, baseline = baseline, milk_norm = milk_norm, n_milk_cows = n_milk_cows, milk_coverage_end = milk_coverage_end, n_milk_day30 = n_milk_day30, n_no_milk_at_all = n_no_milk_at_all, trend = trend)
}

# Time to culling after the first alert.
# 
# date_left is already on the cohort (it is needed to censor Q2 at culling), so
# do NOT re-join it here - that yields date_left.x / date_left.y and the bare
# name disappears.
fxn_build_q6 <- function(cohort, date_max_pull) {
  # `date_left` is already attached to `cohort` upstream (it's needed there to
  # censor Q2 at culling), so this chunk must NOT re-join it - doing so yields
  # date_left.x / date_left.y and the bare name disappears. date_sold/date_died
  # were only ever selected here, never used.
  q6 <- cohort |>
    mutate(
      culled_ever = as.integer(!is.na(date_left)),
      days_to_censor_cull = if_else(
        culled_ever == 1,
        as.numeric(date_left - first_nedlame_date),
        as.numeric(date_max_pull - first_nedlame_date)
      )
    ) |>
    filter(days_to_censor_cull >= 0)
  
  km_cull <- survfit2(Surv(days_to_censor_cull, culled_ever) ~ tx_group, data = q6)

  list(q6 = q6, km_cull = km_cull)
}

# Lesion cases and whether NEDAP alerted in time - the miss analysis.
# 
# Four eligibility exclusions, all for the same reason: the system could not have
# alerted, so a lesion found is not a camera miss.
#   - unfreshened heifers (lact_number 0, no date_fresh)
#   - cows already dried off
#   - cows trimmed within params$recent_trim_suppression_days (the FTDAT gate)
#   - cows never enrolled in SmartSight, so never monitored at all
# 
# The FTDAT gate tracks days since the most recent LAME diagnosis OR trim, not
# trims alone - confirmed with the farm.
# 
# The lookback window is capped at min(N, days since alerting went live), so a
# case found shortly after go-live is not judged against history that cannot exist.
fxn_build_q4 <- function(cohort, all_nedlame_cows, lame_data, events_formatted, events_all,
                         animal_lactations, enrolled_ids, nedlame_start_date, params) {
  # analysis_end is derived from params here rather than passed separately.
  # It used to be its own argument even though params was also passed, which
  # let the alert cut-off (set in fxn_build_cohort from the same param) and the
  # lesion cut-off drift apart - exactly the coupling the comment below says
  # must hold. Deriving it removes that possibility and one adjacent bare Date
  # from a long positional signature.
  analysis_end <- ymd(params$analysis_end_date)
  stopifnot(nedlame_start_date <= analysis_end)
  # Confirmed directly with the farm: the DairyComp FTDAT gate tracks days
  # since the most recent LAME diagnosis OR trim - not trims alone. A cow
  # with frequent LAME diagnoses but no formal trim in between is just as
  # ineligible for a new alert as a recently-trimmed one.
  trims_for_suppression <- events_formatted |>
    filter(event %in% c("LAME", "FOOTRIM", "TRIM")) |>
    select(id_animal, lact_number, trim_date = date_event) |>
    distinct()
  
  lame_lesion_recent_all <- lame_data |>
    filter(event == "LAME", lesion == 1,
           date_event >= ymd(params$history_after_date),
           date_event <= analysis_end) |>
    left_join(animal_lactations |> select(id_animal, lact_number, date_fresh, date_dry), by = c("id_animal", "lact_number"))
  
  # Days since this cow's most recent PRIOR trim, for each lesion case - computed
  # so that a case with no prior trim at all still gets exactly one row (Inf),
  # rather than a naive filter-then-min silently dropping it (see lessons-learned.md
  # in mcp_server/knowledge/ for why that pattern is dangerous).
  recent_trim_check <- lame_lesion_recent_all |>
    select(id_animal, lact_number, date_event) |>
    left_join(trims_for_suppression, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    mutate(days_since_trim = if_else(!is.na(trim_date) & trim_date < date_event, as.numeric(date_event - trim_date), Inf)) |>
    group_by(id_animal, lact_number, date_event) |>
    summarize(days_since_last_trim = min(days_since_trim), .groups = "drop")
  
  lame_lesion_recent_all <- lame_lesion_recent_all |>
    left_join(recent_trim_check, by = c("id_animal", "lact_number", "date_event"))
  
  # exclude lesions diagnosed on a heifer who never freshened (lact_number ==
  # 0, no date_fresh on record - confirmed this is exactly how this herd's
  # data represents "hasn't calved yet" - a real cowcard cross-check (cow
  # 31377) caught this: she's lact_number 0 and was being counted as a
  # "miss" despite never having been eligible for NEDAP monitoring at all),
  # after the cow was already dried off, or diagnosed while NEDAP would
  # have been structurally suppressed by a too-recent trim
  n_excluded_prefresh <- sum(is.na(lame_lesion_recent_all$date_fresh))
  n_excluded_dry <- sum(!is.na(lame_lesion_recent_all$date_fresh) & !is.na(lame_lesion_recent_all$date_dry) & lame_lesion_recent_all$date_event > lame_lesion_recent_all$date_dry)
  n_excluded_recent_trim <- sum(
    !is.na(lame_lesion_recent_all$date_fresh) &
      lame_lesion_recent_all$days_since_last_trim <= params$recent_trim_suppression_days &
      (is.na(lame_lesion_recent_all$date_dry) | lame_lesion_recent_all$date_event <= lame_lesion_recent_all$date_dry)
  )
  
  # A cow who was never enrolled in SmartSight was never monitored for
  # mobility at all, so a lesion found on her cannot be a camera miss - the
  # same reasoning that already excludes dry cows and unfreshened heifers.
  # Enrollment is judged renumber-aware via enrolled_ids (see the setup chunk).
  lame_lesion_recent_all <- lame_lesion_recent_all |>
    left_join(events_all |> select(id_animal, id) |> distinct(), by = "id_animal") |>
    mutate(enrolled_smartsight = as.character(id) %in% enrolled_ids)
  
  # Counted at the SAME grain as q4 (one row per cow-lactation, after the
  # first-qualifying-case slice), so that nrow(q4) + this reconciles against the
  # pre-exclusion total. Counting raw lesion rows instead double-counts a cow
  # with two qualifying events.
  excluded_not_enrolled_cases <- lame_lesion_recent_all |>
    filter(!is.na(date_fresh),
           is.na(date_dry) | date_event <= date_dry,
           days_since_last_trim > params$recent_trim_suppression_days,
           !enrolled_smartsight) |>
    group_by(id_animal, lact_number) |>
    slice_min(date_event, n = 1, with_ties = FALSE) |>
    ungroup()
  n_excluded_not_enrolled <- nrow(excluded_not_enrolled_cases)
  
  lame_lesion_recent <- lame_lesion_recent_all |>
    filter(!is.na(date_fresh)) |>
    filter(is.na(date_dry) | date_event <= date_dry) |>
    filter(days_since_last_trim > params$recent_trim_suppression_days) |>
    filter(enrolled_smartsight) |>
    select(-enrolled_smartsight, -id) |>
    select(-date_fresh, -date_dry, -days_since_last_trim) |>
    # first qualifying lesion case per cow-lactation only
    group_by(id_animal, lact_number) |>
    slice_min(date_event, n = 1, with_ties = FALSE) |>
    ungroup()
  
  nedlame_all <- events_all |>
    filter(Event == "NEDLAME") |>
    select(id_animal, lact_number, ned_date = date_event) |>
    distinct()
  
  q4 <- lame_lesion_recent |>
    mutate(
      lookback_days_available = pmax(as.numeric(date_event - nedlame_start_date), 0),
      lookback_days_used = pmin(params$q4_lookback_days, lookback_days_available)
    ) |>
    left_join(nedlame_all, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    mutate(lookback_hit = !is.na(ned_date) & ned_date <= date_event & ned_date >= date_event - lookback_days_used) |>
    group_by(id_animal, lact_number, date_event, lookback_days_used) |>
    summarize(caught_by_nedap = any(lookback_hit), .groups = "drop") |>
    left_join(cohort |> select(id_animal, lact_number, tx_group), by = c("id_animal", "lact_number")) |>
    mutate(tx_group = if_else(is.na(tx_group), "Never Alerted (Not in Pilot Cohort)", tx_group))
  
  # A cow can have been warned and simply not acted on. If a NEDLAME landed
  # before the lookback opened and NOTHING was done between that alert and the
  # lesion - no trim, no LAME, no FOOTRIM - then the camera did its job and the
  # farm did not. Counting her as a camera miss attributes a response failure to
  # the sensor.
  #
  # Gerard 2026-09-09, on cow 10581 (alerted 25 days out, Control): "a warning 25
  # days isn't a miss as she was in the control group". In the Control arm no
  # protocol obliged anyone to act, so an early warning is still a warning.
  #
  # The trim check is what keeps this honest. If she WAS trimmed after that alert
  # and then got a lesion anyway, the lesion is a new episode the camera did not
  # warn about, and she stays a miss. Only 2 of the 28 fall that way.
  #
  # Scale: 28 misses have an alert outside the window, 26 of them un-acted-on,
  # 21 in the Control arm. It moves the Control miss rate from 27.9% to ~11% and
  # barely touches TX, because the window was doing nearly all its work on the
  # arm where nobody was required to respond quickly.
  prior_alerts <- lame_lesion_recent |>
    select(id_animal, lact_number, date_event) |>
    distinct() |>
    left_join(nedlame_all, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(!is.na(ned_date), ned_date <= date_event) |>
    group_by(id_animal, lact_number, date_event) |>
    summarize(last_prior_ned = max(ned_date), .groups = "drop") |>
    mutate(days_alert_to_lesion = as.numeric(date_event - last_prior_ned))

  action_after_alert <- prior_alerts |>
    left_join(trims_for_suppression |> select(id_animal, lact_number, trim_date),
              by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    mutate(acted = !is.na(trim_date) & trim_date > last_prior_ned & trim_date < date_event) |>
    group_by(id_animal, lact_number, date_event) |>
    summarize(acted_on_alert = any(acted), .groups = "drop")

  q4 <- q4 |>
    left_join(prior_alerts, by = c("id_animal", "lact_number", "date_event")) |>
    left_join(action_after_alert, by = c("id_animal", "lact_number", "date_event")) |>
    mutate(
      acted_on_alert = coalesce(acted_on_alert, FALSE),
      warned_not_acted = !caught_by_nedap & !is.na(last_prior_ned) & !acted_on_alert,
      # the miss population every headline below is built from
      is_miss = !caught_by_nedap & !warned_not_acted
    )
  n_warned_not_acted <- sum(q4$warned_not_acted)
  n_misses <- sum(q4$is_miss)
  stopifnot(n_misses + n_warned_not_acted + sum(q4$caught_by_nedap) == nrow(q4))

  n_truncated_lookback <- sum(q4$lookback_days_used < params$q4_lookback_days)
  
  # The "Never Alerted" label is assigned by absence from `cohort`, and
  # `cohort` now excludes the post-trim-artifact cows - so that bucket is NOT
  # purely "never got an alert." Split it explicitly rather than describing it
  # loosely: an earlier draft called the non-pure share "a small number" when
  # it is actually ~18% of the bucket.
  # detection_group is defined HERE and nowhere else, and every count below is
  # derived from it. It used to be written twice - once here as a filter and
  # again in fxn_build_q4_groups as a case_when - which let the two drift and
  # produced a prose figure that disagreed with the chart beside it.
  #
  # Order matters: caught_by_nedap is tested FIRST. It asks whether ANY alert
  # landed in the window, while cohort membership additionally requires a valid
  # MNFRS and surviving the post-trim exclusion, so a cow can be flagged in time
  # yet sit outside the cohort. Testing membership first mislabels those cows
  # "Never Alerted" and stops the missed categories summing to the miss total.
  q4_group <- q4 |>
    mutate(detection_group = case_when(
      caught_by_nedap ~ "Alerted, Caught in Time",
      tx_group == "Never Alerted (Not in Pilot Cohort)" ~ "Never Alerted",
      TRUE ~ "Alerted, Missed"
    ))
  stopifnot(
    sum(q4_group$detection_group %in% c("Never Alerted", "Alerted, Missed")) ==
      sum(!q4_group$caught_by_nedap)
  )

  never_alerted_rows <- q4_group |> filter(detection_group == "Never Alerted")
  n_never_alerted_bucket <- nrow(never_alerted_rows)
  n_never_alerted_true <- never_alerted_rows |>
    anti_join(all_nedlame_cows |> select(id_animal, lact_number), by = c("id_animal", "lact_number")) |>
    nrow()
  n_never_alerted_excluded <- n_never_alerted_bucket - n_never_alerted_true

  list(trims_for_suppression = trims_for_suppression, lame_lesion_recent_all = lame_lesion_recent_all, recent_trim_check = recent_trim_check, n_excluded_prefresh = n_excluded_prefresh, n_excluded_dry = n_excluded_dry, n_excluded_recent_trim = n_excluded_recent_trim, excluded_not_enrolled_cases = excluded_not_enrolled_cases, n_excluded_not_enrolled = n_excluded_not_enrolled, lame_lesion_recent = lame_lesion_recent, nedlame_all = nedlame_all, q4 = q4, n_truncated_lookback = n_truncated_lookback, q4_group = q4_group, never_alerted_rows = never_alerted_rows, n_never_alerted_bucket = n_never_alerted_bucket, n_never_alerted_true = n_never_alerted_true, n_never_alerted_excluded = n_never_alerted_excluded, n_warned_not_acted = n_warned_not_acted, n_misses = n_misses)
}

# Detection categories and the lesion-type breakdown.
# 
# detection_group tests caught_by_nedap FIRST, then cohort membership. Those ask
# different questions - caught_by_nedap looks at ANY alert landing in the window,
# while cohort membership also requires a valid MNFRS and surviving the post-trim
# exclusion - so a cow can be flagged in time yet sit outside the cohort. Testing
# cohort membership first mislabels those cows 'Never Alerted' and stops the
# missed categories summing to the miss total.
# 
# Shares are within each lesion type, not counts: on a count axis a common lesion
# looks like a detection problem simply because it is common.
fxn_build_q4_groups <- function(q4_sensor, lame_lesion_recent) {
  # Computation half of what used to be the q4-lesion-types chunk. The plot
  # half stays in each report, so they can present it differently.
  #
  # Takes q4_group, which already carries detection_group from fxn_build_q4.
  # This function used to rebuild that rule itself and then assert agreement
  # against n_never_alerted_bucket read from the GLOBAL ENVIRONMENT - the only
  # unbound global in this file. Consuming q4_group removes the duplicated rule
  # and the global together, so the rule now lives in exactly one place.
  # Takes q4_sensor, which carries detection_group_3way - the sensor-side
  # taxonomy (caught / lost in pipeline / never flagged). The report used to
  # split these figures by a DairyComp-side label instead (caught / alerted
  # but missed / never alerted), which answered a different question - whether
  # she was ever in the pilot - and cut across the detection story. One
  # taxonomy now, and it is the one that says whether the camera saw her.
  stopifnot("detection_group_3way" %in% names(q4_sensor))

  lesion_type_cols <- c("dd", "footrot", "wld", "sole_ulcer", "injury", "cork",
                         "hemorrhage", "sole_fracture", "toe_ulcer", "thin", "other")
  
  q4_lesion_types <- lame_lesion_recent |>
    select(id_animal, lact_number, date_event, all_of(lesion_type_cols)) |>
    inner_join(q4_sensor |> select(id_animal, lact_number, date_event, detection_group_3way),
               by = c("id_animal", "lact_number", "date_event")) |>
    pivot_longer(cols = all_of(lesion_type_cols), names_to = "lesion_type", values_to = "has_lesion") |>
    filter(has_lesion == 1) |>
    count(detection_group_3way, lesion_type) |>
    # Shown as a share within each lesion type, not as counts. On a count axis a
    # common lesion looks like a detection problem simply because it is common -
    # the same base-rate trap the DD-by-foot table further down was built to
    # avoid. The case count is printed beside each bar so a lesion with only a
    # handful of cases can be discounted rather than read as a real rate.
    group_by(lesion_type) |>
    mutate(total_cases = sum(n), pct = 100 * n / total_cases) |>
    ungroup() |>
    mutate(lesion_type = fct_reorder(lesion_type, total_cases))
  
  lesion_totals <- q4_lesion_types |> distinct(lesion_type, total_cases)

  list(lesion_type_cols = lesion_type_cols, q4_lesion_types = q4_lesion_types, lesion_totals = lesion_totals)
}

# Of the cows the camera missed, how many did staff flag anyway?
fxn_build_staff_catch <- function(q4, chklame, staff_window_days = 7) {
  # The window was a hard-coded 7 in a project where every other window is a
  # params entry. Defaulted so behaviour is unchanged.
  missed_cases <- q4 |> filter(is_miss)
  
  staff_catch <- missed_cases |>
    left_join(chklame, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    mutate(staff_flagged = !is.na(date_event.y) & date_event.y <= date_event.x & date_event.y >= date_event.x - staff_window_days) |>
    group_by(id_animal, lact_number, date_event = date_event.x, tx_group) |>
    summarize(staff_flagged = any(staff_flagged), .groups = "drop")

  list(missed_cases = missed_cases, staff_catch = staff_catch)
}


# Why an apparent pipeline loss might not be one.
#
# A case reaches here because the camera flagged the cow inside the lookback
# window and no NEDLAME landed in that window. Four rules can explain that
# without any data being lost in transit:
#
#   FTDAT   she was trimmed too recently for the alert to be raised
#           (90 days on the Low route, 28 on the declines)
#   DSNLM   she had already been alerted recently, so a repeat is suppressed
#           (90 days on Low, 7 on the declines) - an EXCLUSION, confirmed by
#           the farm 2026-09-09; earlier versions of this analysis had it
#           backwards as an inclusion
#   injury  upper-leg/injury history blocks the Low route specifically, so it
#           only applies where nothing but a LOW flag fired
#   late    a NEDLAME did arrive, one day after the lesion. The ~5am batch
#           stamps the load date, so a flag after 5am on day D appears as D+1,
#           landing just outside a lookback that only looks backward. The cow
#           was still missed - an alert after the diagnosis helps nobody - but
#           nothing was lost. Found via cow 7207.
#
# Lives here rather than in a report chunk because the standalone pipeline-loss
# workbook needs the identical verdict. It previously did not: DSNLM was
# implemented in the workbook and not in the report, and they disagreed by
# about ten cases.
#
# What remains unexplained is a floor, not a count of confirmed bugs: score at
# flag is not in the data, so a LOW-only case could equally be a score of 31-69
# that was correctly declined. Only cases where a DECLINE route fired have no
# score gate left to hide behind.
fxn_build_pipeline_by_design <- function(q4_sensor, attentions_resolved, events_formatted, events_all, lame_data) {
  leg_abovefoot_injury_history <- lame_data |>
    filter(protocols == "Leg-AboveFoot" | injury == 1) |>
    select(id_animal, hist_date = date_event) |>
    distinct()
  
  pipeline_loss_cases <- q4_sensor |> filter(detection_group_3way == "Flagged, but no alert in time")
  
  # Which alert type(s) actually fired within the lookback window for each
  # pipeline-loss case - needed to restrict the injury/Leg-AboveFoot check
  # to cases where only a LOW attention fired, since that's the specific
  # enrollment gate this exclusion applies to (Strong/Low Decline aren't
  # gated the same way, per the farm).
  pipeline_loss_fired_types <- pipeline_loss_cases |>
    select(id_animal, lact_number, date_event, lookback_days_used) |>
    left_join(attentions_resolved |> select(id_animal, lact_number, attention_date, alert_type),
              by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
# A flag on the lesion DAY ITSELF is not advance warning. The trim happens
# during that day, so a same-day attention is as likely to be the camera
# reading her post-trim gait as anything that preceded the diagnosis - the
# same reasoning behind the post-trim exclusion in the cohort. Only a flag
# STRICTLY BEFORE the lesion date counts as the camera having seen a problem
# in time, so the window is [lesion - lookback, lesion).
#
# Confirmed in the data rather than assumed. No attention in the whole export
# occurs before 05:00 local - 84% fall between 18:00 and midnight - so an
# attention on day D is always picked up by the NEXT morning's batch. Matching
# attentions to the NEDLAME they produced, on the same alert type, 61% land at
# exactly +1 day. An attention ON the lesion day could therefore only ever have
# produced an alert the day AFTER the diagnosis - never in time.
#
# The mirror of this is why caught_by_nedap DOES count a NEDLAME dated on the
# lesion day: that alert came out of the 5am batch from the PREVIOUS day's
# attention, and the batch runs before trimming. It is genuine advance warning.
# The two rules look inconsistent and are not: one is about the attention, the
# other about the alert, and they sit a day apart by construction.
    filter(attention_date < date_event, attention_date >= date_event - lookback_days_used) |>
    group_by(id_animal, lact_number, date_event) |>
    summarize(low_only = all(alert_type == "LOW"), .groups = "drop")
  
  # Same pre-filter-before-join pattern used throughout this report.
  injury_history_check <- pipeline_loss_cases |>
    select(id_animal, lact_number, date_event) |>
    left_join(leg_abovefoot_injury_history, by = "id_animal", relationship = "many-to-many") |>
    mutate(has_prior_injury = !is.na(hist_date) & hist_date < date_event) |>
    group_by(id_animal, lact_number, date_event) |>
    summarize(has_injury_leg_history = any(has_prior_injury), .groups = "drop")
  
  # SECOND by-design mechanism: the FTDAT gate, evaluated AT THE ATTENTION
  # DATE. Q4 already applies an FTDAT-style test, but only at the *lesion*
  # date - which never asks whether the cow was eligible at the moment the
  # camera actually fired. A trim falling between the attention and the lesion
  # leaves the lesion-date test clean while making the attention itself
  # un-enrollable. Gate widths come straight from the farm's DairyComp
  # commands: FTDAT<-90 for the Low route, FTDAT<-28 for both decline routes.
  # FTDAT is a COW-LEVEL date item in DairyComp - it does not reset at
  # freshening. This lookup used to join on lact_number as well, which hid every
  # trim in a prior lactation: a recently freshened cow looked as though she had
  # never been trimmed and passed a gate DairyComp itself would have applied.
  #
  # Not cosmetic. It moves 18 of the 119 pipeline-loss cases from "cannot tell"
  # to "working as designed" (by design 39 -> 57, cannot tell 69 -> 51). The
  # genuine count is unchanged at 11 and no genuine loss is explained away, so
  # what goes to Nedap does not move - but a quarter of the unjudgeable pile was
  # unjudgeable only because of this bug. The 90-day Low gate is wide enough that
  # prior-lactation trims land inside it routinely.
  #
  # The temporal work is done by the gate_trim_date < attention_date filter
  # below, so dropping lact_number does not let a later trim block an earlier
  # attention.
  trims_gate <- events_formatted |>
    filter(event %in% c("LAME", "FOOTRIM", "TRIM")) |>
    select(id_animal, gate_trim_date = date_event) |>
    distinct()
  
  attention_gate_check <- pipeline_loss_cases |>
    select(id_animal, lact_number, date_event, lookback_days_used) |>
    left_join(attentions_resolved |> select(id_animal, lact_number, attention_date, alert_type),
              by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(attention_date < date_event, attention_date >= date_event - lookback_days_used) |>
    left_join(trims_gate, by = "id_animal", relationship = "many-to-many") |>
    mutate(days_since_trim = if_else(!is.na(gate_trim_date) & gate_trim_date < attention_date,
                                      as.numeric(attention_date - gate_trim_date), Inf)) |>
    group_by(id_animal, lact_number, date_event, attention_date, alert_type) |>
    summarize(days_since_trim = min(days_since_trim), .groups = "drop") |>
    mutate(gate_days = if_else(alert_type == "LOW", 90, 28),
           attention_blocked = days_since_trim <= gate_days) |>
    group_by(id_animal, lact_number, date_event) |>
    # only "by design" if EVERY attention in the window was gated out; if even
    # one was eligible, DairyComp should have enrolled her.
    summarize(all_attentions_blocked = all(attention_blocked), .groups = "drop")
  
  # THIRD by-design mechanism: the flag was not lost at all, it simply landed a
  # day late. The daily batch runs at ~5am and stamps an alert with the day it
  # was LOADED, so an attention after ~5am on day D is logged as D+1. The
  # lookback only looks BACKWARD from the lesion, so a NEDLAME dated the day
  # after the lesion falls outside it and the case is scored a pipeline loss -
  # even though the alert demonstrably reached DairyComp.
  #
  # Per the farm, these late arrivals are usually the camera reacting to the
  # trim itself rather than the pre-lesion flag arriving late. Either way the
  # cow was genuinely MISSED - an alert after the diagnosis helps nobody, so
  # caught_by_nedap is deliberately left alone. What is wrong is only the
  # "lost in pipeline" label: nothing was lost.
  #
  # Found via cow 7207: flagged 06-11, lesion 06-11, NEDLAME 06-12.
  nedlame_any <- events_all |>
    filter(Event == "NEDLAME") |>
    select(id_animal, lact_number, ned_date = date_event) |>
    distinct()
  
  late_arrival_check <- pipeline_loss_cases |>
    select(id_animal, lact_number, date_event) |>
    left_join(nedlame_any, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    mutate(days_late = as.numeric(ned_date - date_event)) |>
    group_by(id_animal, lact_number, date_event) |>
    summarize(alert_arrived_late = any(days_late == 1, na.rm = TRUE), .groups = "drop")
  
  # FOURTH by-design mechanism: DSNLM. Confirmed by the farm 2026-09-09 - it is
  # an EXCLUSION, not an inclusion: a cow already alerted in the last N days is
  # not re-flagged, so the cowcard does not fill with duplicate alarms.
  # DSNLM=90-1 on the Low route, DSNLM=7-1 on both decline routes.
  #
  # This was implemented in the standalone pipeline-loss workbook but never in
  # the report, so the two disagreed by ~10 cases. Living here, both get it.
  dsnlm_check <- pipeline_loss_cases |>
    select(id_animal, lact_number, date_event, lookback_days_used) |>
    left_join(attentions_resolved |> select(id_animal, lact_number, attention_date, alert_type),
              by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(attention_date < date_event, attention_date >= date_event - lookback_days_used) |>
    left_join(nedlame_any |> select(id_animal, lact_number, ned_date),
              by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    mutate(dsnlm_days = if_else(alert_type == "LOW", 90, 7),
           prior_alert = !is.na(ned_date) & ned_date < attention_date &
                         ned_date >= attention_date - dsnlm_days) |>
    group_by(id_animal, lact_number, date_event, attention_date) |>
    summarize(flag_dsnlm_blocked = any(prior_alert), .groups = "drop") |>
    group_by(id_animal, lact_number, date_event) |>
    # by design only if EVERY flag in the window was suppressed; one eligible
    # flag means DairyComp should have raised an alert
    summarize(all_dsnlm_blocked = all(flag_dsnlm_blocked), .groups = "drop")
  
  pipeline_loss_cases <- pipeline_loss_cases |>
    left_join(late_arrival_check, by = c("id_animal", "lact_number", "date_event")) |>
  left_join(dsnlm_check, by = c("id_animal", "lact_number", "date_event")) |>
    left_join(pipeline_loss_fired_types, by = c("id_animal", "lact_number", "date_event")) |>
    left_join(injury_history_check, by = c("id_animal", "lact_number", "date_event")) |>
    left_join(attention_gate_check, by = c("id_animal", "lact_number", "date_event")) |>
    mutate(
      all_attentions_blocked = coalesce(all_attentions_blocked, FALSE),
      alert_arrived_late = coalesce(alert_arrived_late, FALSE),
    all_dsnlm_blocked = coalesce(all_dsnlm_blocked, FALSE),
      injury_explained = low_only & has_injury_leg_history,
      by_design = all_attentions_blocked | injury_explained | alert_arrived_late | all_dsnlm_blocked
    )
  
  n_pipeline_loss_low_only <- sum(pipeline_loss_cases$low_only, na.rm = TRUE)
  n_pipeline_loss_injury_explained <- sum(pipeline_loss_cases$injury_explained, na.rm = TRUE)
  n_pipeline_loss_ftdat_blocked <- sum(pipeline_loss_cases$all_attentions_blocked, na.rm = TRUE)
  n_pipeline_loss_late <- sum(pipeline_loss_cases$alert_arrived_late, na.rm = TRUE)
n_pipeline_loss_dsnlm <- sum(pipeline_loss_cases$all_dsnlm_blocked, na.rm = TRUE)
  n_pipeline_loss_by_design <- sum(pipeline_loss_cases$by_design, na.rm = TRUE)
  n_pipeline_loss_unexplained <- nrow(pipeline_loss_cases) - n_pipeline_loss_by_design

  # Of what is left, most cannot be adjudicated at all. The Low route requires a
  # score of 1-30 and score-at-flag is not in the data, so a LOW-only case is
  # indistinguishable from a cow correctly declined for scoring 31-69. Only the
  # cases where a DECLINE route fired have no score gate left to hide behind -
  # those are the ones that are genuinely unexplained.
  pipeline_loss_cases <- pipeline_loss_cases |>
    mutate(verdict = case_when(
      by_design ~ "Working as designed",
      low_only  ~ "Cannot tell - LOW only, no score at flag",
      TRUE      ~ "Genuine pipeline loss"
    ))
  # ONE reason per case, in a fixed precedence, so the categories sum to the
  # total. The counts used to be independent - a case both FTDAT-blocked and
  # late was counted under each - so the prose bullets added to more than the
  # number of cases and disagreed with the figure beside them.
  pipeline_loss_cases <- pipeline_loss_cases |>
    mutate(reason = case_when(
      all_attentions_blocked ~ "Working as designed: flag inside its FTDAT window",
      all_dsnlm_blocked      ~ "Working as designed: already alerted (DSNLM)",
      injury_explained       ~ "Working as designed: upper-leg history blocks Low",
      alert_arrived_late     ~ "An alert did arrive, one day too late",
      low_only               ~ "Cannot tell: LOW only, no score at flag",
      TRUE                   ~ "Genuine pipeline loss: a decline flag vanished"
    ))
  n_only_ftdat  <- sum(pipeline_loss_cases$reason == "Working as designed: flag inside its FTDAT window")
  n_only_dsnlm  <- sum(pipeline_loss_cases$reason == "Working as designed: already alerted (DSNLM)")
  n_only_injury <- sum(pipeline_loss_cases$reason == "Working as designed: upper-leg history blocks Low")
  n_only_late   <- sum(pipeline_loss_cases$reason == "An alert did arrive, one day too late")
  stopifnot(n_only_ftdat + n_only_dsnlm + n_only_injury + n_only_late ==
              n_pipeline_loss_by_design)

  n_pipeline_loss_unknowable <- sum(pipeline_loss_cases$verdict == "Cannot tell - LOW only, no score at flag")
  n_pipeline_loss_genuine    <- sum(pipeline_loss_cases$verdict == "Genuine pipeline loss")
  stopifnot(n_pipeline_loss_by_design + n_pipeline_loss_unknowable + n_pipeline_loss_genuine ==
              nrow(pipeline_loss_cases))

  list(pipeline_loss_cases = pipeline_loss_cases, leg_abovefoot_injury_history = leg_abovefoot_injury_history, pipeline_loss_fired_types = pipeline_loss_fired_types, injury_history_check = injury_history_check, trims_gate = trims_gate, attention_gate_check = attention_gate_check, nedlame_any = nedlame_any, late_arrival_check = late_arrival_check, dsnlm_check = dsnlm_check, n_pipeline_loss_low_only = n_pipeline_loss_low_only, n_pipeline_loss_injury_explained = n_pipeline_loss_injury_explained, n_pipeline_loss_ftdat_blocked = n_pipeline_loss_ftdat_blocked, n_pipeline_loss_late = n_pipeline_loss_late, n_pipeline_loss_dsnlm = n_pipeline_loss_dsnlm, n_pipeline_loss_by_design = n_pipeline_loss_by_design, n_pipeline_loss_unexplained = n_pipeline_loss_unexplained, n_pipeline_loss_unknowable = n_pipeline_loss_unknowable, n_pipeline_loss_genuine = n_pipeline_loss_genuine, n_only_ftdat = n_only_ftdat, n_only_dsnlm = n_only_dsnlm, n_only_injury = n_only_injury, n_only_late = n_only_late)
}


# What actually drove a Control cow's trim: a staff CHKLAME between her alert and
# her trim, or the routine schedule coming round. The distinction matters because
# the Control arm is otherwise described as 'staff discretion', and most of it is
# not - it is the routine round catching up. Both reports need these numbers: the
# full one for the driver table, the farm one so its trim-only commentary does not
# call the whole Control arm staff-identified.
fxn_build_control_trim_drivers <- function(next_events, cohort, events_formatted, lame_data) {
  # Same pre-filter-before-join pattern used throughout: restrict the CHKLAME
  # candidates to the window FIRST, then join, so a cow with no qualifying
  # CHKLAME is correctly labelled "routine" rather than dropped from the table.
  chklame_events <- events_formatted |>
    filter(event == "CHKLAME") |>
    select(id_animal, lact_number, chk_date = date_event) |>
    distinct()
  
  first_post_alert_trim <- next_events |>
    inner_join(cohort |> select(id_animal, lact_number, first_nedlame_date, date_obs_end, tx_group),
               by = c("id_animal", "lact_number")) |>
    filter(date_event > first_nedlame_date, date_event <= date_obs_end) |>
    group_by(id_animal, lact_number) |>
    slice_min(date_event, n = 1, with_ties = FALSE) |>
    ungroup() |>
    rename(trim_date = date_event)
  
  chk_before_trim <- first_post_alert_trim |>
    select(id_animal, lact_number, first_nedlame_date, trim_date) |>
    inner_join(chklame_events, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    filter(chk_date >= first_nedlame_date, chk_date <= trim_date) |>
    distinct(id_animal, lact_number) |>
    mutate(staff_flagged = TRUE)
  
  trim_driver <- first_post_alert_trim |>
    left_join(chk_before_trim, by = c("id_animal", "lact_number")) |>
    left_join(lame_data |> select(id_animal, lact_number, date_event, trimonly) |> distinct(),
              by = c("id_animal", "lact_number", "trim_date" = "date_event")) |>
    mutate(staff_flagged = coalesce(staff_flagged, FALSE),
           Driver = if_else(staff_flagged, "Staff flagged her (CHKLAME)", "Routine trim, no CHKLAME"),
           days_to_trim = as.numeric(trim_date - first_nedlame_date),
           found_lesion = coalesce(trimonly, 1) == 0)
  
  control_trims <- trim_driver |> filter(tx_group == "Control")
  n_ctl_trimmed <- nrow(control_trims)
  n_ctl_staff   <- sum(control_trims$staff_flagged)
  n_ctl_routine <- n_ctl_trimmed - n_ctl_staff
  pct_ctl_staff <- round(100 * n_ctl_staff / n_ctl_trimmed, 1)
  pct_lesion_staff   <- round(100 * mean(control_trims$found_lesion[control_trims$staff_flagged]), 0)
  pct_lesion_routine <- round(100 * mean(control_trims$found_lesion[!control_trims$staff_flagged]), 0)
  med_days_staff   <- median(control_trims$days_to_trim[control_trims$staff_flagged])
  med_days_routine <- median(control_trims$days_to_trim[!control_trims$staff_flagged])

  list(chklame_events = chklame_events, first_post_alert_trim = first_post_alert_trim, chk_before_trim = chk_before_trim, trim_driver = trim_driver, control_trims = control_trims, n_ctl_trimmed = n_ctl_trimmed, n_ctl_staff = n_ctl_staff, n_ctl_routine = n_ctl_routine, pct_ctl_staff = pct_ctl_staff, pct_lesion_staff = pct_lesion_staff, pct_lesion_routine = pct_lesion_routine, med_days_staff = med_days_staff, med_days_routine = med_days_routine)
}


# How many MORE cows had a lesion found in TX than in Control.
#
# Derived from q2_lesion and q2_any, the SAME objects behind the survival curves
# above it in the report, rather than recomputed from lame_data. The first
# version did recompute - counting any LAME-with-lesion event in the window -
# and gave 184/133 where the report's own lesion curve gives 170/127 and the
# trim-only table gives 162/121. Three defensible definitions, three numbers,
# and a section that contradicted the table above it. Gerard caught it. Reading
# the report's existing objects is the only way this stays aligned.
#
# This is an ASCERTAINMENT difference, not a disease difference, and the report
# has to say so: the arms were randomised, so true lesion incidence is equal by
# construction. What differs is who got looked at. The supporting percentages
# are all returned rather than written into this comment, because a hand-typed
# figure in a comment is exactly the thing that goes stale silently.
#
# Rate-adjusted rather than a raw subtraction, because the arms are different
# sizes: it asks how many TX cows had a lesion found above what Control's rate
# would have produced in a group of that size.
fxn_build_lesion_yield <- function(q2_lesion, q2_any) {
  arm <- function(d) {
    d |> group_by(tx_group) |>
      summarize(cows = n(), n_event = sum(event_occurred),
                pct = round(100 * mean(event_occurred), 1), .groups = 'drop')
  }
  yield_by_arm <- arm(q2_lesion)
  trimmed_by_arm <- arm(q2_any)
  stopifnot(nrow(yield_by_arm) == 2, nrow(trimmed_by_arm) == 2)

  pick <- function(d, ctl) d[if (ctl) d$tx_group == 'Control' else d$tx_group != 'Control', ]
  tx <- pick(yield_by_arm, FALSE); ctl <- pick(yield_by_arm, TRUE)
  ttx <- pick(trimmed_by_arm, FALSE); tctl <- pick(trimmed_by_arm, TRUE)

  list(yield_by_arm = yield_by_arm, trimmed_by_arm = trimmed_by_arm,
       n_cows_tx = tx$cows, n_cows_ctl = ctl$cows,
       n_lesion_tx = tx$n_event, n_lesion_ctl = ctl$n_event,
       pct_lesion_arm_tx = tx$pct, pct_lesion_arm_ctl = ctl$pct,
       n_trimmed_tx = ttx$n_event, n_trimmed_ctl = tctl$n_event,
       pct_trimmed_tx = ttx$pct, pct_trimmed_ctl = tctl$pct,
       n_extra_lesion_cows = round(tx$n_event - tx$cows * ctl$n_event / ctl$cows))
}


