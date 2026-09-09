library(tidyverse)

# Reads UMN_milk_SV_*.csv files in a folder and stacks them into one long
# tibble. The record date lives only in the filename (MM-DD-YYYY), not
# reliably in any in-file column, so it's parsed from the file name.
#
# `from`/`to` restrict which files are READ, not just which rows are kept.
# The folder holds every milk day back to 2023 while an analysis normally
# needs only a window around the events it studies - reading the lot cost
# ~26 s, and then handed ~3.5M rows to fxn_resolve_milk_to_lactation(),
# whose many-to-many join took a further ~138 s. Passing a window cuts both:
# on the NEDLAME pilot it took the pair from ~164 s to ~15 s per render.
#
# Because the date is parsed from the filename BEFORE anything is opened,
# filtering is essentially free. Both default to NULL, which reads
# everything - existing callers are unaffected.
#
# Only restrict to a window the downstream work actually needs.
# fxn_resolve_milk_to_lactation() matches on nearest-preceding date_fresh
# from animal_lactations, not from older milk rows, so a window that covers
# the analysis period is safe - verified by comparing the resolved output
# against a full read.
fxn_read_milk_folder <- function(folder = "data/milk",
                                  pattern = "UMN_milk_SV_.*\\.csv$",
                                  from = NULL, to = NULL) {
  files <- list.files(folder, pattern = pattern, full.names = TRUE)

  if (length(files) == 0) {
    cli::cli_abort("No milk files found matching {pattern} in {folder}")
  }

  file_dates <- files |>
    basename() |>
    str_extract("\\d{2}-\\d{2}-\\d{4}") |>
    mdy()

  n_all <- length(files)
  keep <- rep(TRUE, n_all)
  if (!is.null(from)) keep <- keep & file_dates >= as.Date(from)
  if (!is.null(to))   keep <- keep & file_dates <= as.Date(to)
  files <- files[keep]
  file_dates <- file_dates[keep]

  if (length(files) == 0) {
    cli::cli_abort(c(
      "No milk files fall between {from} and {to}.",
      i = "The folder holds {n_all} file{?s} spanning a different range - check the window."
    ))
  }

  map2(files, file_dates, \(.file, .date) {
    read_csv(
      .file,
      col_select = any_of(c("ID", "LACT", "DMLK1")),
      col_types = cols(
        ID = col_character(),
        LACT = col_double(),
        DMLK1 = col_double()
      ),
      show_col_types = FALSE
    ) |>
      mutate(milk_date = .date)
  }) |>
    list_rbind() |>
    rename(id = ID, reported_lact_number = LACT, dmlk1 = DMLK1) |>
    filter(!is.na(id))
}

# Resolves raw milk (id, milk_date) rows to a specific id_animal/lactation
# by picking the animal_lactations row for that `id` with the nearest
# date_fresh at or before milk_date. This is necessary because raw `id`
# values get reused across different animals over time (retagging), and
# milk files never carry the composite id_animal or a birth date to
# disambiguate directly. Matching on nearest-preceding-fresh (rather than
# trusting an open-ended date_dry/date_next_fresh window) avoids picking a
# stale, never-closed-out lactation from a previous animal that happened
# to reuse the same tag number. Any row still implausibly far past
# freshening (default > 450 DIM) is dropped as an unresolved collision.
fxn_resolve_milk_to_lactation <- function(milk_long, animal_lactations,
                                           max_dim = 450) {
  lact_lookup <- animal_lactations |>
    filter(!is.na(date_fresh)) |>
    select(id_animal, id, lact_number, date_fresh)

  milk_long |>
    inner_join(lact_lookup, by = "id", relationship = "many-to-many") |>
    filter(date_fresh <= milk_date) |>
    mutate(dim = as.numeric(milk_date - date_fresh)) |>
    group_by(id, milk_date) |>
    slice_min(dim, n = 1, with_ties = FALSE) |>
    ungroup() |>
    filter(dim <= max_dim) |>
    select(id_animal, id, lact_number, reported_lact_number, milk_date, dim, dmlk1)
}
