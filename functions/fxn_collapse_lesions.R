library(tidyverse)

# Collapses multiple event rows on the same (farm, animal, date) down to one
# row, keeping the UNION of all lesion-type flags across those rows (so two
# different lesions coded on the same day - e.g. white line AND digital
# dermatitis - both survive), while still counting a repeated code for the
# same lesion type only once (it's the same 0/1 flag either way).
#
# This is a corrected local override of the same-named function normally
# fetched live from github.com/Dairy-Cow-Foot-Doc/os_functions. That version
# reassigns its own `data` variable to an already-one-row-per-date subset
# (via slice_min on trimonly) BEFORE computing the max() aggregation across
# lesion columns - so the "max across all of that day's rows" step ends up
# operating on a single row, silently dropping any lesion type that wasn't
# on the one row slice_min happened to keep. Confirmed against real data:
# a cow with 4 separate LAME rows on one date (white line + digital
# dermatitis x2 + a leg injury) was losing the digital dermatitis and
# injury flags entirely under the GitHub version. Sourced after
# fxn_load_os_fxns() so this corrected copy wins.
fxn_collapse_lesions <- function(data, farm_col = location_event,
                                  id_col = id_animal, date_col = date_event,
                                  lesions) {
  # union of lesion flags across ALL of that day's rows, computed from the
  # original (uncollapsed) data
  data_sum <- data |>
    group_by({{ farm_col }}, {{ id_col }}, {{ date_col }}) |>
    summarise(across(all_of(lesions), \(x) max(x, na.rm = TRUE)), .groups = "drop")

  # one representative row per day for all the OTHER columns (prefer the
  # row with the lowest trimonly, i.e. a lesion-positive row over a
  # trim-only one, matching the original function's intent)
  data_rep <- data |>
    group_by({{ farm_col }}, {{ id_col }}, {{ date_col }}) |>
    slice_min(trimonly, n = 1, with_ties = FALSE) |>
    ungroup() |>
    select(-all_of(lesions)) |>
    distinct({{ farm_col }}, {{ id_col }}, {{ date_col }}, .keep_all = TRUE)

  left_join(data_rep, data_sum, by = join_by({{ farm_col }}, {{ id_col }}, {{ date_col }}))
}
