setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(splines)})
ok <- suppressWarnings(suppressPackageStartupMessages(require(lme4)))
cat("lme4 available:", ok, "\n\n")
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
source("functions/fxn_read_milk_folder.R")
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
invisible(list2env(fxn_build_lame_history(ef, cohort), environment()))
milk_long <- fxn_read_milk_folder(
  from = min(cohort$first_nedlame_date, na.rm = TRUE) - params$milk_window_pre,
  to   = max(cohort$first_nedlame_date, na.rm = TRUE) + params$milk_window_post)
mr <- fxn_resolve_milk_to_lactation(milk_long, al)
invisible(list2env(fxn_build_q1(cohort, mr, params), environment()))

LB_PER_KG <- 2.20462
d <- milk_norm |>
  filter(!is.na(dmlk1), day_rel >= -params$milk_window_pre, day_rel <= params$milk_window_post) |>
  mutate(kg = dmlk1 / LB_PER_KG,
         dim = dim_at_nedlame + day_rel,
         lact_grp = factor(case_when(lact_number == 1 ~ "1", lact_number == 2 ~ "2", TRUE ~ "3+")),
         hist = factor(if_else(history_group == "New", "No", "Yes")),
         week = ceiling(pmax(day_rel, 1) / 7)) |>
  filter(dim > 0, dim < 500)

cat("=== UNITS ===\n")
cat("  raw dmlk1 mean:", round(mean(d$dmlk1), 1), "(pounds)\n")
cat("  in kg         :", round(mean(d$kg), 1), "kg/day  <- plausible for a high-producing herd\n\n")

wk <- d |>
  group_by(id_animal, tx_group, lact_grp, hist, week) |>
  summarize(kg = mean(kg), dim = mean(dim), .groups = "drop") |>
  filter(!is.na(kg))
cat("weekly records:", nrow(wk), " cows:", n_distinct(wk$id_animal), "\n\n")

if (ok) {
  m <- lmer(kg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + (1 | id_animal), data = wk)
  vc <- as.data.frame(VarCorr(m))
  sd_cow <- vc$sdcor[vc$grp == "id_animal"]
  sd_res <- vc$sdcor[vc$grp == "Residual"]
  cat("=== VARIANCE COMPONENTS, weekly kg, AFTER lactation curve + parity + history ===\n")
  cat("  between-cow SD (random intercept):", round(sd_cow, 2), "kg\n")
  cat("  residual SD (week to week)       :", round(sd_res, 2), "kg\n\n")
  cat("  your simulation assumes           : cow_potential SD 1.8, residual 1.1\n")
  cat("  ratio measured/assumed            :", round(sd_cow / 1.8, 1), "x and",
      round(sd_res / 1.1, 1), "x\n\n")
  fe <- summary(m)$coefficients
  rn <- grep("^tx_group", rownames(fe), value = TRUE)
  cat("=== treatment terms (kg/day, weekly scale) ===\n")
  print(round(fe[rn, , drop = FALSE], 3))
} else {
  cat("lme4 not installed - install.packages('lme4') to get the variance components\n")
}

cat("\n=== observed effect on the baseline-normalised scale, converted to kg ===\n")
b <- milk_norm |> filter(day_rel >= 25, day_rel <= 30, !is.na(pct_of_baseline)) |>
  group_by(id_animal, tx_group) |> summarize(p = mean(pct_of_baseline), bl = first(baseline_dmlk1), .groups = "drop")
dpp <- mean(b$p[b$tx_group != "Control"]) - mean(b$p[b$tx_group == "Control"])
bl_kg <- mean(b$bl, na.rm = TRUE) / LB_PER_KG
cat("  ", round(dpp, 1), "pp of a", round(bl_kg, 1), "kg baseline =",
    round(dpp / 100 * bl_kg, 2), "kg/day\n")
cat("   your simulation assumes a true effect of 3.2 kg and break-even 2.45 kg\n")
