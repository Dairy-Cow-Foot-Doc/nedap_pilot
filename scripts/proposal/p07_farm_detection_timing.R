# What the pilot actually says about how, and WHEN, the farm catches an alerted
# cow with no protocol acting on her. The simulation currently uses one 50%
# probability with a uniform week 2-9, which is too crude: staff detection and
# the routine round have very different timing, and both have medians BEFORE
# the four-week mark that defines arm 2.
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
invisible(list2env(fxn_build_q2(cohort, ef, lame_data), environment()))
invisible(list2env(fxn_build_control_trim_drivers(next_events, cohort, ef, lame_data), environment()))

n_ctl <- sum(cohort$tx_group == "Control")
cat("=== CONTROL ARM: what happens after the alert ===\n")
cat("  Control cows:", n_ctl, "\n")
cat("  trimmed at all:", n_ctl_trimmed, sprintf("(%.1f%%)\n", 100 * n_ctl_trimmed / n_ctl))
cat("    of those, staff CHKLAME first:", n_ctl_staff, sprintf("(%.1f%%)\n", 100 * pct_ctl_staff / 100 * 100))
cat("    routine round:", n_ctl_routine, "\n\n")

cat("=== as a share of ALL Control cows - what the simulation needs ===\n")
p_staff   <- n_ctl_staff / n_ctl
p_routine <- n_ctl_routine / n_ctl
cat(sprintf("  caught by STAFF   : %.1f%%   median %d days to trim\n",
            100 * p_staff, med_days_staff))
cat(sprintf("  caught by ROUTINE : %.1f%%   median %d days to trim\n",
            100 * p_routine, med_days_routine))
cat(sprintf("  never trimmed     : %.1f%%\n\n", 100 * (1 - p_staff - p_routine)))

cat("=== full timing distribution, days from alert to trim ===\n")
d <- control_trims |> mutate(wk = pmin(ceiling(pmax(days_to_trim, 1) / 7), 9))
print(d |> count(Driver, wk) |>
        pivot_wider(names_from = wk, values_from = n, values_fill = 0) |> as.data.frame())

cat("\n=== the number that matters for ARM 2 ===\n")
cat("Arm 2 waits 4 weeks. Any Control-like cow caught BEFORE day 28 would, in\n")
cat("arm 2, be treated then instead - so she is pulled toward arm 1.\n\n")
for (grp in c("Staff flagged her (CHKLAME)", "Routine trim, no CHKLAME")) {
  g <- control_trims |> filter(Driver == grp)
  if (!nrow(g)) next
  cat(sprintf("  %-28s %.0f%% of its trims happen within 28 days\n",
              grp, 100 * mean(g$days_to_trim <= 28)))
}
early <- control_trims |> filter(days_to_trim <= 28)
cat(sprintf("\n  OVERALL: %.1f%% of all Control cows are caught within 28 days\n",
            100 * nrow(early) / n_ctl))
cat(sprintf("  so roughly that share of ARM 2 would be treated before its protocol week.\n"))
cat(sprintf("\n  the simulation currently assumes: 50%% caught, week uniform 2-9,\n"))
cat(sprintf("  which puts %.0f%% of catches inside 28 days (weeks 2-4 of 2-9) - close by\n", 100*3/8))
cat("  luck on the fraction, but with the wrong shape and no staff/routine split.\n")

cat("\n=== empirical week-of-catch distribution, all Control trims ===\n")
tab <- d |> count(wk) |> mutate(pct = round(100 * n / sum(n), 1))
print(as.data.frame(tab))
cat("\nas probabilities of catch-week given caught (for the simulation):\n")
cat(paste(sprintf("w%d=%.3f", tab$wk, tab$n / sum(tab$n)), collapse = ", "), "\n")
