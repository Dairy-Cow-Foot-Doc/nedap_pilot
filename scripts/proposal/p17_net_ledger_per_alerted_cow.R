# "Does it pay to use the camera?" is a NET question, and so far this document
# has only costed the system subscription against the milk benefit. Acting on
# alerts also means TRIMMING MORE COWS, which costs money and labour. That has
# to be on the ledger.
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
dmp <- max(ea$date_event, na.rm = TRUE)
invisible(list2env(fxn_build_cohort(ea, al, an, dmp, pp), environment()))
invisible(list2env(fxn_build_lame_history(ef, cohort), environment()))
invisible(list2env(fxn_build_q2(cohort, ef, lame_data), environment()))

cat("=== THE COST SIDE: how many EXTRA trims does acting on alerts cause? ===\n")
tr <- cohort |>
  left_join(q2_any |> select(id_animal, lact_number, event_occurred),
            by = c("id_animal","lact_number")) |>
  mutate(trimmed = coalesce(event_occurred, 0) == 1)
s <- tr |> group_by(tx_group) |>
  # NB: do not reuse the column name being summarised - dplyr evaluates
  # sequentially, so mean(trimmed) would see the sum, not the logical vector
  summarize(cows = n(), n_trim = sum(trimmed), pct = round(100*mean(trimmed), 1), .groups="drop")
print(as.data.frame(s))
p_tx  <- s$pct[s$tx_group != "Control"]/100
p_ctl <- s$pct[s$tx_group == "Control"]/100
extra <- p_tx - p_ctl
cat(sprintf("\n  extra trims per alerted cow: %.3f  (%.1f%% vs %.1f%%)\n",
            extra, 100*p_tx, 100*p_ctl))

# of those extra trims, how many find nothing?
q2d <- q2_any |> filter(event_occurred == 1) |>
  left_join(lame_data |> select(id_animal, lact_number, date_event, trimonly),
            by = c("id_animal","lact_number","date_event"))
to <- q2d |> group_by(tx_group) |>
  summarize(trims = n(), no_lesion = sum(coalesce(trimonly,0)==1),
            pct_empty = round(100*mean(coalesce(trimonly,0)==1),1), .groups="drop")
cat("\n  of the trims that happen, share finding NO lesion:\n")
print(as.data.frame(to))

cat("\n=== NET LEDGER PER ALERTED COW ===\n")
cat("  Benefit and cost both expressed per ALERTED cow, so they can be netted.\n\n")
INCID <- 0.271        # new-case incidence, share of cows per year
P_LESION <- 0.35      # share of alerted cows with a lesion found
IOFC <- 0.25
ledger <- function(milk_kg, days, trim_cost, sys_cost_month, months = 12) {
  # milk benefit accrues to alerted cows who actually have a lesion to treat
  benefit_milk <- milk_kg * days * IOFC * P_LESION
  cost_trims   <- extra * trim_cost
  cost_system  <- sys_cost_month * months / (INCID / P_LESION * 1)  # per alerted cow
  tibble(benefit_milk, cost_trims, net_before_system = benefit_milk - cost_trims)
}
cat("  benefit: milk gain x days x IOFC x P(lesion among alerted)\n")
cat("  cost   : extra trims per alerted cow x cost per trim\n\n")
for (mk in c(1.05, 1.5)) for (tc in c(8, 12, 18)) {
  b <- mk * 60 * IOFC * P_LESION
  c_ <- extra * tc
  cat(sprintf("  milk %.2f kg over 60 d, trim $%2d: benefit $%.2f, extra-trim cost $%.2f, net $%+.2f per alerted cow\n",
              mk, tc, b, c_, b - c_))
}
cat("\n  over 90 days:\n")
for (mk in c(1.05, 1.5)) for (tc in c(8, 12, 18)) {
  b <- mk * 90 * IOFC * P_LESION
  c_ <- extra * tc
  cat(sprintf("  milk %.2f kg over 90 d, trim $%2d: benefit $%.2f, extra-trim cost $%.2f, net $%+.2f per alerted cow\n",
              mk, tc, b, c_, b - c_))
}
cat("\n=== what the system costs on the same per-alerted-cow basis ===\n")
cat("  A cow generates ~", round(1/(1 - exp(-0.00319*305)), 2),
    "lactations per alert, i.e. about 62% of cows are alerted per lactation.\n")
for (cm in c(0.65, 0.80)) {
  per_cow_year <- cm * 12
  per_alerted <- per_cow_year / 0.62
  cat(sprintf("  $%.2f/cow/month = $%.2f/cow/year = $%.2f per ALERTED cow\n",
              cm, per_cow_year, per_alerted))
}
