# Does cure differ between NEW and CHRONIC cows? Gerard expects chronic to be
# worse. Testable for WLD/SU, which is what the cure outcome is sized on.
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

vis <- lame_data |> filter(event %in% c("LAME","FOOTRIM","TRIM")) |>
  select(id_animal, date_event, lesion, trimonly, wld, sole_ulcer, status_lesion) |>
  distinct() |>
  mutate(found = coalesce(lesion,0)==1 & coalesce(trimonly,0)!=1)

idx <- vis |> filter(found, coalesce(wld,0)==1 | coalesce(sole_ulcer,0)==1) |>
  group_by(id_animal) |> slice_min(date_event, n=1, with_ties=FALSE) |> ungroup() |>
  transmute(id_animal, idx_date = date_event, status = status_lesion) |>
  filter(idx_date <= cover_end - 60, !is.na(status))

fu <- idx |>
  left_join(vis |> transmute(id_animal, fu_date = date_event, found),
            by = "id_animal", relationship = "many-to-many") |>
  filter(fu_date > idx_date, fu_date <= idx_date + 60) |>
  group_by(id_animal, idx_date, status) |>
  slice_min(fu_date, n=1, with_ties=FALSE) |> ungroup() |>
  mutate(cured = !found)

cat("=== CURE AT 60 DAYS, WLD/SU, BY CHRONICITY AT THE INDEX LESION ===\n\n")
s <- fu |> group_by(status) |>
  summarize(assessed = n(), cured_n = sum(cured),
            cure_pct = round(100*mean(cured), 1), .groups = "drop") |>
  arrange(desc(assessed))
print(as.data.frame(s))

cat("\n  also: are chronic cows re-examined at a different rate?\n")
r <- idx |> count(status, name = "index") |>
  left_join(fu |> count(status, name = "assessed"), by = "status") |>
  mutate(pct_assessed = round(100*assessed/index, 1))
print(as.data.frame(r))

nw <- fu |> filter(status == "New") |> pull(cured)
ch <- fu |> filter(status == "Chronic") |> pull(cured)
if (length(nw) > 10 && length(ch) > 10) {
  cat("\n=== New vs Chronic ===\n")
  cat(sprintf("  New     %.1f%% cured (n=%d)\n", 100*mean(nw), length(nw)))
  cat(sprintf("  Chronic %.1f%% cured (n=%d)\n", 100*mean(ch), length(ch)))
  cat(sprintf("  difference: %+.1f points\n", 100*(mean(ch)-mean(nw))))
  print(prop.test(c(sum(ch), sum(nw)), c(length(ch), length(nw))))
}

cat("\n=== WHAT THIS IS, AND WHAT IT IS NOT ===\n")
cat("A difference in BASELINE cure between new and chronic cows is a MAIN\n")
cat("EFFECT. Adjusting for it costs nothing - it removes variance and if\n")
cat("anything helps precision.\n\n")
cat("An INTERACTION is different: it means the TREATMENT BENEFIT differs by\n")
cat("chronicity - early trimming helping new cows more than chronic ones, say.\n")
cat("That is what costs 2x, because the reported coefficient is then the effect\n")
cat("within one stratum, estimated from half the cows.\n\n")
cat("The pilot CANNOT test the interaction: it has no randomised treatment\n")
cat("contrast on cure, only observational cure rates. It can and does test the\n")
cat("main effect, above.\n")
