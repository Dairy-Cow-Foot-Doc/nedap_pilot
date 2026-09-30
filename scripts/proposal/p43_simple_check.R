# A plain cross-check on p42 (2026-09-30).
#
# Gerard: "check your work with a simpler calculation to make sure our
# complexity isn't confusing things." This does the sizing with textbook
# formulas and the pilot's raw time-to-trim curves, none of p42's machinery
# (no DIM bands, no herd multipliers, no dry-off model, no per-herd fits):
#
#   1. dilution    how much of a true effect survives as the observed arm 1 v 3
#                  difference: E[share of 90 days after the trim] in arm 1
#                  (pilot TX time to first trim) minus arm 3 (pilot Control
#                  time to first trim), both Kaplan-Meier
#   2. SE          2 x variance / cows per arm, plus between-herd tau^2 / herds
#   3. power       z: normal; Hartung-Knapp: noncentral t on herds - 1 df
#
# Then the same formula moved one input at a time - the sensitivities the
# proposal lists. Run from the project root: Rscript scripts/proposal/p43_simple_check.R
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
params <- list(milk_window_pre = 14, milk_window_post = 90, milk_baseline_days = 7,
               q4_lookback_days = 28, history_after_date = "2026-06-01",
               recent_trim_suppression_days = 28, post_trim_exclusion_days = 7,
               analysis_end_date = "2026-08-27")
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
ef <- read_parquet("data/intermediate_files/events_formatted.parquet")
an <- read_parquet("data/intermediate_files/animals.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")
invisible(list2env(fxn_build_cohort(ea, al, an, max(ea$date_event, na.rm = TRUE), params), environment()))
invisible(list2env(fxn_build_lame_history(ef, cohort), environment()))
invisible(list2env(fxn_build_q2(cohort, ef, lame_data), environment()))

# ---- 1. dilution from the raw pilot curves -------------------------------------
km_share <- function(time, ev) {                  # E[(90 - t)+ / 90] from a KM curve
  S <- 1; out <- 0
  for (d in 1:90) {
    n <- sum(time >= d); e <- sum(ev & time == d)
    h <- if (n > 0) e / n else 0
    out <- out + S * h * (90 - d) / 90; S <- S * (1 - h)
  }
  c(share = out, trimmed90 = 1 - S)
}
a1 <- with(filter(q2_any, tx_group == "TX (Trim)"), km_share(days_to_event, event_occurred == 1))
a3 <- with(filter(q2_any, tx_group == "Control"),   km_share(days_to_event, event_occurred == 1))
DIL <- a1[["share"]] - a3[["share"]]
cat(sprintf("arm 1: trimmed by day 90 %.0f%%, benefit share %.2f | arm 3: %.0f%%, %.2f\n",
            100 * a1[["trimmed90"]], a1[["share"]], 100 * a3[["trimmed90"]], a3[["share"]]))
cat(sprintf("observed / true = %.2f (p42: 0.49)\n", DIL))
# The raw curve counts a Control cow's dry-off trim as if she then milked out
# the 90 days. She does not - she dries off days later. Censor the Control
# curve 45 days before dry-off, as p42 does, to see whether that is the gap.
ctl <- q2_any |> filter(tx_group == "Control") |>
  mutate(cut = as.numeric(date_dry - first_nedlame_date) - 45,
         t2 = if_else(!is.na(cut) & cut < days_to_event, pmax(cut, 0), days_to_event),
         e2 = event_occurred == 1 & (is.na(cut) | days_to_event <= cut))
a3b <- with(ctl, km_share(t2, e2))
cat(sprintf("arm 3 with dry-off trims left out: %.0f%% trimmed by day 90, share %.2f -> observed / true %.2f\n",
            100 * a3b[["trimmed90"]], a3b[["share"]], a1[["share"]] - a3b[["share"]]))
DIL_DRYOFF <- a1[["share"]] - a3b[["share"]]

# ---- 2 and 3. SE and power ---------------------------------------------------------
power_simple <- function(N = 5000, true = 2.0, var_cow = 51.9, tau = 0.25, k = 6,
                         kept = 0.97, dil = DIL_DRYOFF) {
  n_arm <- N / 3 * kept
  delta <- true * dil
  se <- sqrt(2 * var_cow / n_arm + tau^2 / k)
  z  <- pnorm(delta / se - qnorm(.975))
  hk <- pt(qt(.975, k - 1), k - 1, ncp = delta / se, lower.tail = FALSE)
  # conventional analysis (2026-09-30 night, now primary): herd and arm fixed,
  # no arm-by-herd term, so no tau in the SE; inference on the enrolled herds
  se_fe <- sqrt(2 * var_cow / n_arm)
  fe <- pnorm(delta / se_fe - qnorm(.975))
  tibble(N, true, observed = delta, var_cow, tau, k, se, ci = qt(.975, k - 1) * se,
         ci_fe = qnorm(.975) * se_fe, fe, z, hk)
}
fmt <- \(x) mutate(x, across(c(observed, se, ci, ci_fe), \(v) round(v, 2)),
                   across(c(fe, z, hk), \(v) round(100 * v)))
cat("\n== The design, simple formula v p42 ==\n")
print(fmt(bind_rows(power_simple(4000), power_simple(5000), power_simple(6000))))
cat("  ...and with dry-off trims left out of arm 3's dilution:\n")
print(fmt(bind_rows(power_simple(4000, dil = DIL_DRYOFF), power_simple(5000, dil = DIL_DRYOFF),
                    power_simple(6000, dil = DIL_DRYOFF))))
cat("  p42 (HK / z): 4,000 72 / 85; 5,000 82 / 91; 6,000 85 / 94.  p42 CI half-width at 5,000: 0.66\n")
cat("  Note: the simple SE is the known-variance SE; HK's own SE is noisier with six herds,\n")
cat("  so the noncentral-t HK figure is an approximation.\n")

cat("\n== SENSITIVITY: one input at a time, 5,000 enrolled ==\n")
sens <- bind_rows(
  power_simple() |> mutate(input = "planned (all as designed)"),
  power_simple(true = 1.5) |> mutate(input = "true effect 1.5 kg, not 2.0"),
  power_simple(true = 2.5) |> mutate(input = "true effect 2.5 kg"),
  power_simple(var_cow = 42.4) |> mutate(input = "variance at the pilot point estimate (42.4), not the 90th pct"),
  power_simple(var_cow = 60) |> mutate(input = "variance 60 kg^2 (worse than planned)"),
  power_simple(tau = 0.5) |> mutate(input = "herds differ by 0.5 kg"),
  power_simple(tau = 0.75) |> mutate(input = "herds differ by 0.75 kg"),
  power_simple(dil = DIL) |> mutate(input = "dry-off trims counted as dilution"),
  power_simple(dil = DIL_DRYOFF * 0.8) |> mutate(input = "farm practice dilutes 20% more"),
  power_simple(dil = DIL_DRYOFF * 1.2) |> mutate(input = "farm practice dilutes 20% less"),
  power_simple(kept = 0.85) |> mutate(input = "15% of cows give no milk (not 3%)"),
  power_simple(k = 4) |> mutate(input = "four herds"),
  power_simple(k = 8) |> mutate(input = "eight herds"))
print(fmt(sens) |> select(input, observed, ci_fe, fe, ci, hk, z), n = 20)
cat("\n== SENSITIVITY, 4,000 enrolled ==\n")
sens4 <- bind_rows(
  power_simple(4000) |> mutate(input = "planned"),
  power_simple(4000, true = 1.5) |> mutate(input = "true effect 1.5 kg"),
  power_simple(4000, true = 2.5) |> mutate(input = "true effect 2.5 kg"),
  power_simple(4000, var_cow = 42.4) |> mutate(input = "variance 42.4"),
  power_simple(4000, var_cow = 60) |> mutate(input = "variance 60"),
  power_simple(4000, dil = DIL) |> mutate(input = "dry-off trims counted as dilution"),
  power_simple(4000, dil = DIL_DRYOFF * 0.8) |> mutate(input = "dilutes 20% more"),
  power_simple(4000, dil = DIL_DRYOFF * 1.2) |> mutate(input = "dilutes 20% less"),
  power_simple(4000, kept = 0.85) |> mutate(input = "15% give no milk"))
print(fmt(sens4) |> select(input, observed, ci_fe, fe, ci, hk, z), n = 20)
cat("\n== Conventional power by N ==\n")
print(fmt(map_dfr(c(3000, 3500, 4000, 4500, 5000), \(n) power_simple(n))) |> select(N, observed, ci_fe, fe))
