# Two questions:
#  1. Is there reproduction data, and how much is at stake?
#  2. Gerard's point: culling separates over the LONG term, and the pilot's
#     3-month window is too short. Test it on the herd's multi-year records
#     rather than the pilot cohort.
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(lubridate)})
source("functions/fxn_load_os_fxns.R"); suppressMessages(fxn_load_os_fxns())
source("functions/fxn_code_lesions.R"); source("functions/fxn_collapse_lesions.R")
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
ef <- read_parquet("data/intermediate_files/events_formatted.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")
cover_end <- max(ef$date_event, na.rm = TRUE)

cat("=== REPRODUCTION EVENTS AVAILABLE ===\n")
print(ea |> filter(Event %in% c("BRED","PREG","HEAT","OPEN","ABORT","DNB","PROST","OVSYNC")) |>
        count(Event, sort = TRUE) |> as.data.frame())

# lesions, from the collapsed lame table
lame <- ef |> filter(event == "LAME")
ld <- suppressWarnings(try(fxn_collapse_lesions(fxn_code_lesions(lame)), silent = TRUE))
les <- if (inherits(ld, "try-error")) {
  ef |> filter(event == "LAME") |> transmute(id_animal, lact_number, les_date = date_event)
} else {
  ld |> filter(lesion == 1) |> transmute(id_animal, lact_number, les_date = date_event)
} |> distinct()

lac <- al |> filter(!is.na(date_fresh), date_fresh >= as.Date("2023-01-01"),
                    date_fresh <= cover_end - 400) |>
  select(id_animal, lact_number, date_fresh, date_dry)

## ---- lesion in the first 120 DIM, then look at repro and culling ----------
early <- les |>
  inner_join(lac, by = c("id_animal","lact_number")) |>
  mutate(dim = as.numeric(les_date - date_fresh)) |>
  filter(dim >= 0, dim <= 120) |>
  distinct(id_animal, lact_number) |> mutate(early_lesion = TRUE)

base <- lac |> left_join(early, by = c("id_animal","lact_number")) |>
  mutate(early_lesion = coalesce(early_lesion, FALSE))
cat("\nlactations analysed:", nrow(base),
    " with a lesion by 120 DIM:", sum(base$early_lesion),
    sprintf("(%.1f%%)\n", 100*mean(base$early_lesion)))

## ---- 1. REPRODUCTION -------------------------------------------------------
bred <- ea |> filter(Event == "BRED") |>
  transmute(id_animal, bred_date = date_event) |> distinct()
preg <- ea |> filter(Event == "PREG") |>
  transmute(id_animal, preg_date = date_event) |> distinct()

r <- base |>
  left_join(bred, by = "id_animal", relationship = "many-to-many") |>
  filter(is.na(bred_date) | (bred_date > date_fresh & bred_date < date_fresh + 400)) |>
  group_by(id_animal, lact_number, date_fresh, early_lesion) |>
  summarize(first_bred = suppressWarnings(min(bred_date, na.rm = TRUE)),
            n_bred = sum(!is.na(bred_date)), .groups = "drop") |>
  mutate(dfs = as.numeric(first_bred - date_fresh)) |>
  left_join(preg, by = "id_animal", relationship = "many-to-many") |>
  filter(is.na(preg_date) | (preg_date > date_fresh & preg_date < date_fresh + 400)) |>
  group_by(id_animal, lact_number, early_lesion, dfs, n_bred) |>
  summarize(got_preg = any(!is.na(preg_date)), .groups = "drop")

cat("\n=== REPRODUCTION BY EARLY-LACTATION LESION ===\n")
print(r |> group_by(early_lesion) |>
        summarize(lactations = n(),
                  median_days_to_1st_service = median(dfs, na.rm = TRUE),
                  mean_services = round(mean(n_bred, na.rm = TRUE), 2),
                  pct_pregnant = round(100*mean(got_preg), 1), .groups = "drop") |>
        as.data.frame())

## ---- 2. CULLING OVER A LONGER WINDOW --------------------------------------
left <- ea |> filter(Event %in% c("SOLD","DIED","OFF")) |>
  transmute(id_animal, left_date = date_event) |> distinct() |>
  group_by(id_animal) |> summarize(left_date = min(left_date), .groups = "drop")

cull <- base |> left_join(left, by = "id_animal") |>
  mutate(days_to_leave = as.numeric(left_date - date_fresh))
cat("\n=== CULLING BY EARLY-LACTATION LESION, over increasing windows ===\n")
cat("(Gerard: the effect accumulates, so a 3-month window understates it)\n\n")
out <- map_dfr(c(90, 180, 270, 365), function(w) {
  cull |> mutate(gone = !is.na(days_to_leave) & days_to_leave <= w) |>
    group_by(early_lesion) |>
    summarize(window = w, n = n(), left_n = sum(gone),
              pct = round(100*mean(gone), 1), .groups = "drop")
})
print(out |> select(window, early_lesion, n, pct) |>
        pivot_wider(names_from = early_lesion, values_from = pct,
                    names_prefix = "lesion_") |> as.data.frame())
cat("\n  difference in percentage points by window:\n")
d <- out |> select(window, early_lesion, pct) |>
  pivot_wider(names_from = early_lesion, values_from = pct)
print(d |> mutate(diff = round(`TRUE` - `FALSE`, 1)) |> as.data.frame())
