library(tidyverse)

# Reads all UMN_milk_SV_*.csv files in a folder and stacks them into one
# long tibble. The record date lives only in the filename (MM-DD-YYYY),
# not reliably in any in-file column, so it's parsed from the file name.
fxn_read_milk_folder <- function(folder = "data/milk",
                                  pattern = "UMN_milk_SV_.*\\.csv$") {
  files <- list.files(folder, pattern = pattern, full.names = TRUE)

  if (length(files) == 0) {
    cli::cli_abort("No milk files found matching {pattern} in {folder}")
  }

  file_dates <- files |>
    basename() |>
    str_extract("\\d{2}-\\d{2}-\\d{4}") |>
    mdy()

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
