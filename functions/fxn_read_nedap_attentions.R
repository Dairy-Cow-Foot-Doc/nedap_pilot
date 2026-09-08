library(tidyverse)

# Reads the raw Nedap "Attentions" export (one row per discrete mobility
# alert episode - issue_uuid is unique per row, confirmed against a real
# extract, so this is NOT a repeated status ping that needs collapsing).
# start_time_utc is converted to local farm time before extracting a date,
# since DC's events are recorded in local time and a UTC timestamp near
# midnight could otherwise shift the date by a day. The file's own
# time_zone column confirms US/Central for effectively all rows (a
# handful are labeled UTC, a negligible data quirk not worth branching
# on for a date-level, not time-level, analysis).
fxn_read_nedap_attentions <- function(file = "data/nedap_attentions_2026-08-27.csv",
                                       local_tz = "America/Chicago") {
  read_csv(
    file,
    col_select = c(animal_number, start_time_utc, issue_type, is_completed),
    col_types = cols(
      animal_number = col_character(),
      start_time_utc = col_character(),
      issue_type = col_double(),
      is_completed = col_logical()
    ),
    show_col_types = FALSE
  ) |>
    mutate(
      attention_date = as_date(with_tz(as_datetime(start_time_utc, tz = "UTC"), tzone = local_tz)),
      # matches this report's alert_type labels elsewhere (from DC's own
      # NEDLAME Remark field: LOW / LOW DECLINE / STRONG DECLINE)
      alert_type = case_when(
        issue_type == 0 ~ "LOW",
        issue_type == 1 ~ "STRONG DECLINE",
        issue_type == 2 ~ "LOW DECLINE",
        TRUE ~ NA_character_
      )
    ) |>
    rename(id = animal_number) |>
    filter(!is.na(id), !is.na(attention_date))
}

# Resolves raw attentions (id, attention_date) to a specific id_animal/
# lactation, same nearest-preceding-fresh-date pattern already used for
# the milk data (fxn_resolve_milk_to_lactation) - raw animal_number gets
# reused across animals over time just like the milk files' raw id (23 of
# 3,436 animal_numbers map to >1 Nedap-side animal_uuid, confirming this
# isn't hypothetical), and the CSV never carries DC's composite id_animal
# or a birth date to disambiguate directly.
fxn_resolve_nedap_to_lactation <- function(attentions, animal_lactations,
                                            max_dim = 450) {
  lact_lookup <- animal_lactations |>
    filter(!is.na(date_fresh)) |>
    select(id_animal, id, lact_number, date_fresh)

  attentions |>
    inner_join(lact_lookup, by = "id", relationship = "many-to-many") |>
    filter(date_fresh <= attention_date) |>
    mutate(dim = as.numeric(attention_date - date_fresh)) |>
    group_by(id, attention_date, issue_type) |>
    slice_min(dim, n = 1, with_ties = FALSE) |>
    ungroup() |>
    filter(dim <= max_dim) |>
    select(id_animal, id, lact_number, attention_date, issue_type, alert_type, is_completed, dim)
}
