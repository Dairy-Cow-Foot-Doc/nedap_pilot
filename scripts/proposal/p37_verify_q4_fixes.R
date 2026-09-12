# Re-derive the effect of the three fixes rather than take the predicted 3 -> 0.
# Mirrors the report's own setup so the numbers are comparable to a render.
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")

params <- list(milk_window_pre = 14, milk_window_post = 30, milk_baseline_days = 7,
               q4_lookback_days = 21, history_after_date = "2026-06-01",
               recent_trim_suppression_days = 28, post_trim_exclusion_days = 7,
               analysis_end_date = "2026-08-27")
events_all <- read_parquet("data/intermediate_files/events_all_columns.parquet")
events_formatted <- read_parquet("data/intermediate_files/events_formatted.parquet")
animals <- read_parquet("data/intermediate_files/animals.parquet")
animal_lactations <- read_parquet("data/intermediate_files/animal_lactations.parquet")
dmp <- max(events_all$date_event, na.rm = TRUE)
nedlame_start_date <- min(events_all$date_event[events_all$Event == "NEDLAME"], na.rm = TRUE)

invisible(list2env(fxn_build_cohort(events_all, animal_lactations, animals, dmp, params), environment()))
invisible(list2env(fxn_build_lame_history(events_formatted, cohort), environment()))
cows_smartsight <- read_csv("data/cows_smartsight.csv", show_col_types = FALSE) |>
  transmute(id = as.character(Animal))
invisible(list2env(fxn_build_enrolled_ids(events_all, cows_smartsight), environment()))

invisible(list2env(fxn_build_q4(
  cohort = cohort, all_nedlame_cows = all_nedlame_cows, lame_data = lame_data,
  events_formatted = events_formatted, events_all = events_all,
  animal_lactations = animal_lactations, enrolled_ids = enrolled_ids,
  nedlame_start_date = nedlame_start_date, params = params), environment()))

cat("=== q4 after the fixes ===\n")
cat("  rows (lesion cases)     :", nrow(q4), "\n")
cat("  caught_by_nedap         :", sum(q4$caught_by_nedap), "\n")
cat("  warned_not_acted        :", sum(q4$warned_not_acted), "\n")
cat("  is_miss                 :", sum(q4$is_miss), "\n")
if (exists("n_new_episode")) cat("  excluded as new episode :", n_new_episode, "\n")

in_pilot <- q4$tx_group != "Never Alerted (Not in Pilot Cohort)"
cat("\n=== the split that matters ===\n")
cat(sprintf("  IN COHORT   : %3d cases, %3d misses (%.1f%%)\n",
            sum(in_pilot), sum(q4$is_miss & in_pilot),
            100 * sum(q4$is_miss & in_pilot) / max(sum(in_pilot), 1)))
cat(sprintf("  NEVER ENROLLED: %3d cases, %3d misses (%.1f%%)\n",
            sum(!in_pilot), sum(q4$is_miss & !in_pilot),
            100 * sum(q4$is_miss & !in_pilot) / max(sum(!in_pilot), 1)))
cat(sprintf("  POOLED      : %3d cases, %3d misses (%.1f%%)\n",
            nrow(q4), sum(q4$is_miss), 100 * mean(q4$is_miss)))

cat("\n=== the four cows in question ===\n")
for (tag in c("_22408_", "_9616_", "_21648_", "_20444_")) {
  r <- q4 |> filter(grepl(tag, id_animal, fixed = TRUE))
  if (!nrow(r)) { cat(sprintf("  %-9s absent from q4 (excluded)\n", tag)); next }
  for (k in seq_len(nrow(r)))
    cat(sprintf("  %-9s %s  caught=%-5s warned=%-5s miss=%-5s  arm=%s\n", tag,
                r$date_event[k], r$caught_by_nedap[k], r$warned_not_acted[k],
                r$is_miss[k], r$tx_group[k]))
}
