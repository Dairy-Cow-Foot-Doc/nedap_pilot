setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(lubridate)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
pp <- list(milk_window_pre = 14, milk_window_post = 30, milk_baseline_days = 7,
           q4_lookback_days = 21, history_after_date = "2026-06-01",
           recent_trim_suppression_days = 28, post_trim_exclusion_days = 7,
           analysis_end_date = "2026-08-27")
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
ef <- read_parquet("data/intermediate_files/events_formatted.parquet")
an <- read_parquet("data/intermediate_files/animals.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")
invisible(list2env(fxn_build_cohort(ea, al, an, max(ea$date_event, na.rm = TRUE), pp), environment()))
invisible(list2env(fxn_build_lame_history(ef, cohort), environment()))

cat("=== what the lameness code puts in the status fields ===\n")
for (v in c("status_lesion", "status_inf", "status_noninf")) {
  if (v %in% names(lame_data)) {
    cat("\n", v, ":\n", sep = "")
    print(lame_data |> filter(event == "LAME") |> count(.data[[v]]) |> as.data.frame())
  }
}

deno <- read_parquet("data/intermediate_files/denominator_by_calendar_time_period.parquet") |>
  filter(deno_type == "lact_basic", calendar_time_period_type == "year",
         `Lactation Group` == "LACT > 0") |>
  transmute(year = year(date_time_period_start),
            cow_years = ct_animal_time_periods, days = days_in_time_period) |>
  filter(days > 350)

lesion_cols <- c("dd", "footrot", "wld", "sole_ulcer", "cork", "other",
                 "hemorrhage", "sole_fracture", "toe_ulcer", "thin", "injury")
lesion_cols <- intersect(lesion_cols, names(lame_data))

cat("\n\n=== NEW-CASE INCIDENCE per 100 cow-years, overall ===\n")
if ("status_lesion" %in% names(lame_data)) {
  newc <- lame_data |>
    filter(event == "LAME", lesion == 1, status_lesion == "New") |>
    distinct(id_animal, lact_number, date_event) |>
    mutate(year = year(date_event)) |>
    count(year, name = "new_cases") |>
    inner_join(deno, by = "year") |>
    mutate(per_100_cow_years = round(100 * new_cases / cow_years, 1))
  print(as.data.frame(newc))
  cat("\n  mean:", round(mean(newc$per_100_cow_years), 1), "new cases per 100 cow-years\n")
}

cat("\n\n=== NEW-CASE INCIDENCE BY LESION CATEGORY, per 100 cow-years ===\n")
cat("(the calculator works per category, so this is the per-category input)\n\n")
bycat <- lame_data |>
  filter(event == "LAME", lesion == 1) |>
  select(id_animal, lact_number, date_event, status_lesion, all_of(lesion_cols)) |>
  pivot_longer(all_of(lesion_cols), names_to = "lesion_type", values_to = "has") |>
  filter(has == 1) |>
  mutate(year = year(date_event))

# "new" per lesion type = a cow's FIRST ever occurrence of THAT lesion type
first_by_type <- bycat |>
  group_by(id_animal, lesion_type) |>
  slice_min(date_event, n = 1, with_ties = FALSE) |>
  ungroup() |>
  count(year, lesion_type, name = "new_cases") |>
  inner_join(deno, by = "year") |>
  mutate(per_100 = 100 * new_cases / cow_years)

print(first_by_type |>
        group_by(lesion_type) |>
        summarize(mean_per_100_cow_years = round(mean(per_100), 1),
                  min = round(min(per_100), 1), max = round(max(per_100), 1),
                  .groups = "drop") |>
        arrange(desc(mean_per_100_cow_years)) |> as.data.frame())

cat("\ntotal across categories (a cow can appear in more than one):",
    round(sum(first_by_type$per_100) / n_distinct(first_by_type$year), 1),
    "per 100 cow-years\n")
