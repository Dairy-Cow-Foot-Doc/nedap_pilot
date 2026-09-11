# What would a minimum-DIM criterion for enrolment cost, and is there evidence
# that fresh-cow alerts are worth excluding?
#
# Gerard's argument: cows just fresh walk abnormally anyway, so an alert at DIM 2
# is as likely to be transition-period gait as lameness. A DIM floor would also
# remove the stale-lactation allocation error outright, since all three of those
# sat at DIM 0-1.
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")

params <- list(milk_window_pre = 14, milk_window_post = 30, milk_baseline_days = 7,
               q4_lookback_days = 21, history_after_date = "2026-06-01",
               recent_trim_suppression_days = 28, post_trim_exclusion_days = 7,
               analysis_end_date = "2026-08-27")
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
ef <- read_parquet("data/intermediate_files/events_formatted.parquet")
an <- read_parquet("data/intermediate_files/animals.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")
dmp <- max(ea$date_event, na.rm = TRUE)
invisible(list2env(fxn_build_cohort(ea, al, an, dmp, params), environment()))

d <- cohort |> filter(!is.na(dim_at_nedlame))
cat("cohort cows with a DIM at first alert:", nrow(d), "\n")
cat("median DIM at first alert:", median(d$dim_at_nedlame), "\n\n")

cat("=== alerts in the first two weeks of lactation ===\n")
cat("  DIM   n   cumulative   % of cohort lost if the floor is DIM >= this\n")
for (k in 0:14) {
  n_k <- sum(d$dim_at_nedlame == k)
  cum <- sum(d$dim_at_nedlame < k + 1)
  cat(sprintf("  %3d %4d %8d        %5.2f%%\n", k, n_k, cum, 100 * cum / nrow(d)))
}

cat("\n=== what a floor costs, and what it buys ===\n")
for (f in c(2, 3, 5, 7, 10, 14)) {
  lost <- sum(d$dim_at_nedlame < f)
  cat(sprintf("  floor DIM >= %2d : excludes %3d cows (%.2f%% of enrolment)\n",
              f, lost, 100 * lost / nrow(d)))
}

# CAN the pilot test whether fresh-cow alerts are more often spurious? No - and
# saying why is more useful than a number.
#
# (An earlier version of this script tried, and got 100% lesion yield in every
#  DIM band. The bug: grepl("LAME|...") matches NEDLAME itself, so every cow
#  matched her own alert at gap 0. Left here as a warning - "LAME" is a substring
#  of "NEDLAME", so never pattern-match lesion events that way.)
cat("\n=== can the pilot test the fresh-cow rationale? ===\n")
n_early <- sum(d$dim_at_nedlame <= 5)
cat(sprintf("  cows alerted at DIM 0-5 : %d of %d (%.1f%%)\n",
            n_early, nrow(d), 100 * n_early / nrow(d)))
cat("  At that count no comparison of lesion yield between fresh and non-fresh\n")
cat("  alerts has any power - a 20-point difference would need roughly 100 per\n")
cat("  group. So the floor is justified physiologically, not empirically:\n")
cat("  fresh cows walk abnormally for reasons that are not hoof lesions.\n")
cat("\n  The argument that does not need evidence is the cost: a floor removes\n")
cat("  about 1% of enrolment, so it is cheap enough to adopt without proof, and\n")
cat("  it eliminates the stale-lactation allocation error outright.\n")
