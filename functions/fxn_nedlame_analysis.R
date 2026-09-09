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
  cows_activity <- read_csv("data/cows_activity.csv", show_col_types = FALSE) |>
    transmute(id = as.character(Animal))
  
  cows_smartsight <- read_csv("data/cows_smartsight.csv", show_col_types = FALSE) |>
    transmute(id = as.character(Animal))
  
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
fxn_build_q4 <- function(cohort, all_nedlame_cows, lame_data, events_formatted, events_all, animal_lactations, enrolled_ids, analysis_end, nedlame_start_date, params) {
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
  
  n_truncated_lookback <- sum(q4$lookback_days_used < params$q4_lookback_days)
  
  # The "Never Alerted" label is assigned by absence from `cohort`, and
  # `cohort` now excludes the post-trim-artifact cows - so that bucket is NOT
  # purely "never got an alert." Split it explicitly rather than describing it
  # loosely: an earlier draft called the non-pure share "a small number" when
  # it is actually ~18% of the bucket.
  # Must match the figure's "Never Alerted" band exactly, which means carrying
  # the !caught_by_nedap test too - a handful of cows are outside the cohort yet
  # were still flagged in time, and they belong in "Caught in Time", not here.
  # (detection_group itself is built later, so the rule is repeated rather than
  # referenced; if one changes, change both.)
  never_alerted_rows <- q4 |>
    filter(!caught_by_nedap, tx_group == "Never Alerted (Not in Pilot Cohort)")
  n_never_alerted_bucket <- nrow(never_alerted_rows)
  n_never_alerted_true <- never_alerted_rows |>
    anti_join(all_nedlame_cows |> select(id_animal, lact_number), by = c("id_animal", "lact_number")) |>
    nrow()
  n_never_alerted_excluded <- n_never_alerted_bucket - n_never_alerted_true

  list(trims_for_suppression = trims_for_suppression, lame_lesion_recent_all = lame_lesion_recent_all, recent_trim_check = recent_trim_check, n_excluded_prefresh = n_excluded_prefresh, n_excluded_dry = n_excluded_dry, n_excluded_recent_trim = n_excluded_recent_trim, excluded_not_enrolled_cases = excluded_not_enrolled_cases, n_excluded_not_enrolled = n_excluded_not_enrolled, lame_lesion_recent = lame_lesion_recent, nedlame_all = nedlame_all, q4 = q4, n_truncated_lookback = n_truncated_lookback, never_alerted_rows = never_alerted_rows, n_never_alerted_bucket = n_never_alerted_bucket, n_never_alerted_true = n_never_alerted_true, n_never_alerted_excluded = n_never_alerted_excluded)
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
fxn_build_q4_groups <- function(q4, lame_lesion_recent) {
  # Computation half of what used to be the q4-lesion-types chunk. The plot
  # half stays in each report, so they can present it differently.
  lesion_type_cols <- c("dd", "footrot", "wld", "sole_ulcer", "injury", "cork",
                         "hemorrhage", "sole_fracture", "toe_ulcer", "thin", "other")
  
  q4_group <- q4 |>
    # Order matters: test caught_by_nedap FIRST, then cohort membership.
    #
    # caught_by_nedap looks at ANY NEDLAME event, while cohort membership also
    # requires a valid MNFRS and survival of the post-trim exclusion. So a cow
    # can be flagged in time yet sit outside the cohort. Testing cohort
    # membership first labelled those cows "Never Alerted" even though an alert
    # did reach DairyComp inside the window - 4 cases, and it stopped the two
    # missed categories summing to the miss total (55 + 288 = 343, not 339).
    #
    # NB when editing: compare tx_group against the value it actually holds (set
    # in q4-build), not the short display label - the short label matches nothing
    # and silently dumps every never-alerted cow into "Alerted, Missed".
    mutate(detection_group = case_when(
      caught_by_nedap ~ "Alerted, Caught in Time",
      tx_group == "Never Alerted (Not in Pilot Cohort)" ~ "Never Alerted",
      TRUE ~ "Alerted, Missed"
    ))
  
  # The two missed categories must account for every miss. If this ever fails,
  # the labels have drifted away from caught_by_nedap again.
  stopifnot(
    sum(q4_group$detection_group %in% c("Never Alerted", "Alerted, Missed")) ==
      sum(!q4_group$caught_by_nedap)
  )
  
  # and the prose counters above must describe the same band as the figure
  stopifnot(sum(q4_group$detection_group == "Never Alerted") == n_never_alerted_bucket)
  
  q4_lesion_types <- lame_lesion_recent |>
    select(id_animal, lact_number, date_event, all_of(lesion_type_cols)) |>
    inner_join(q4_group |> select(id_animal, lact_number, date_event, detection_group),
               by = c("id_animal", "lact_number", "date_event")) |>
    pivot_longer(cols = all_of(lesion_type_cols), names_to = "lesion_type", values_to = "has_lesion") |>
    filter(has_lesion == 1) |>
    count(detection_group, lesion_type) |>
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

  list(lesion_type_cols = lesion_type_cols, q4_group = q4_group, q4_lesion_types = q4_lesion_types, lesion_totals = lesion_totals)
}

# Of the cows the camera missed, how many did staff flag anyway?
fxn_build_staff_catch <- function(q4, chklame) {
  missed_cases <- q4 |> filter(!caught_by_nedap)
  
  staff_catch <- missed_cases |>
    left_join(chklame, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
    mutate(staff_flagged = !is.na(date_event.y) & date_event.y <= date_event.x & date_event.y >= date_event.x - 7) |>
    group_by(id_animal, lact_number, date_event = date_event.x, tx_group) |>
    summarize(staff_flagged = any(staff_flagged), .groups = "drop")

  list(missed_cases = missed_cases, staff_catch = staff_catch)
}

