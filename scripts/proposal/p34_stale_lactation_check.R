# Claim: a NEDLAME written before the morning's FRESH events are keyed in carries
# the PREVIOUS lactation number, because that is what DairyComp held when the
# command ran. Check how many NEDLAME events disagree with the lactation that was
# actually active on that date.
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})

ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")

nl <- ea |> filter(event == "NEDLAME")
cat("NEDLAME events:", nrow(nl), " distinct cows:", n_distinct(nl$id_animal), "\n\n")

# lactation active on the event date: the most recent freshening on or before it
lact <- al |>
  filter(!is.na(date_fresh)) |>
  select(id_animal, lact_number, date_fresh) |>
  arrange(id_animal, date_fresh)

resolved <- nl |>
  select(id_animal, date_event, lact_raw = lact_number) |>
  inner_join(lact, by = "id_animal", relationship = "many-to-many") |>
  filter(date_fresh <= date_event) |>
  group_by(id_animal, date_event, lact_raw) |>
  slice_max(date_fresh, n = 1, with_ties = FALSE) |>
  ungroup() |>
  mutate(dim = as.numeric(date_event - date_fresh),
         mismatch = lact_raw != lact_number)

cat("events resolvable to a lactation:", nrow(resolved), "\n")
cat("MISMATCHES (event's own lact_number disagrees with the date-resolved one):",
    sum(resolved$mismatch), "\n")
cat("distinct cows affected:", n_distinct(resolved$id_animal[resolved$mismatch]), "\n\n")

if (any(resolved$mismatch)) {
  cat("=== the mismatches ===\n")
  print(resolved |> filter(mismatch) |>
          select(id_animal, date_event, lact_raw, lact_resolved = lact_number, dim) |>
          arrange(id_animal) |> as.data.frame())
  cat("\nDIM at the mismatching event:",
      paste(sort(resolved$dim[resolved$mismatch]), collapse = ", "), "\n")
  cat("all at DIM 0 or 1?  ", all(resolved$dim[resolved$mismatch] <= 1), "\n")
}

cat("\n=== for scale: NEDLAME events at DIM 0-1 overall ===\n")
cat("  ", sum(resolved$dim <= 1), "events, of which",
    sum(resolved$dim <= 1 & resolved$mismatch), "carry a stale lactation number\n")
