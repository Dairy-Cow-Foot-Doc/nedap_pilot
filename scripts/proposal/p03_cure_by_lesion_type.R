setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})
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
cover_end <- max(ef$date_event, na.rm = TRUE)

lcols <- intersect(c("dd", "footrot", "wld", "sole_ulcer", "cork", "other",
                     "hemorrhage", "sole_fracture", "toe_ulcer", "thin", "injury"),
                   names(lame_data))

exams <- lame_data |>
  filter(event %in% c("LAME", "FOOTRIM", "TRIM")) |>
  transmute(id_animal, date_event,
            found_lesion = coalesce(lesion, 0) == 1 & coalesce(trimonly, 0) != 1) |>
  distinct()

# index case, tagged with its lesion type(s)
idx <- lame_data |>
  filter(event == "LAME", lesion == 1) |>
  group_by(id_animal) |> slice_min(date_event, n = 1, with_ties = FALSE) |> ungroup() |>
  select(id_animal, idx_date = date_event, all_of(lcols)) |>
  pivot_longer(all_of(lcols), names_to = "lesion_type", values_to = "has") |>
  filter(has == 1) |> select(-has)

W <- 60
elig <- idx |> filter(idx_date <= cover_end - W)
fu <- elig |>
  left_join(exams |> rename(fu_date = date_event), by = "id_animal",
            relationship = "many-to-many") |>
  filter(fu_date > idx_date, fu_date <= idx_date + W) |>
  group_by(id_animal, idx_date, lesion_type) |>
  slice_min(fu_date, n = 1, with_ties = FALSE) |>
  ungroup()

out <- elig |>
  count(lesion_type, name = "index_cases") |>
  left_join(fu |> group_by(lesion_type) |>
              summarize(re_examined = n(), cured = sum(!found_lesion), .groups = "drop"),
            by = "lesion_type") |>
  mutate(across(c(re_examined, cured), ~ coalesce(.x, 0L)),
         pct_reexamined = round(100 * re_examined / index_cases, 1),
         cure_rate = round(100 * cured / pmax(re_examined, 1), 1)) |>
  arrange(desc(index_cases))

cat("=== RE-EXAMINATION AND CURE WITHIN", W, "DAYS, BY INDEX LESION TYPE ===\n")
cat("    (Gerard: rechecks typically happen for specific lesions, not DD or foot rot)\n\n")
print(as.data.frame(out))

cat("\n=== the selection, stated plainly ===\n")
hi <- out |> filter(pct_reexamined >= median(out$pct_reexamined))
lo <- out |> filter(pct_reexamined <  median(out$pct_reexamined))
cat("  re-examined MORE often:", paste(hi$lesion_type, collapse = ", "), "\n")
cat("  re-examined LESS often:", paste(lo$lesion_type, collapse = ", "), "\n")
dd <- out |> filter(lesion_type %in% c("dd", "footrot"))
if (nrow(dd)) {
  cat("\n  DD and foot rot specifically:\n")
  print(as.data.frame(dd))
}
cat("\n  overall re-examination rate:",
    round(100 * sum(out$re_examined) / sum(out$index_cases), 1), "%\n")
cat("  pooled cure rate:", round(100 * sum(out$cured) / sum(out$re_examined), 1), "%\n")
