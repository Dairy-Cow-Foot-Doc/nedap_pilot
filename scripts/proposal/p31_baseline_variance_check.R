# The reviewer claims the planning variance (between-cow SD 9.39) comes from a
# model with NO pre-alert baseline term, while section 4 specifies a
# baseline-normalised outcome - so the study may be sized on the wrong variance.
# Fit both models on the same data and compare.
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(splines); library(lme4)})
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
         base_kg = baseline_dmlk1 / LB_PER_KG,
         dim = dim_at_nedlame + day_rel,
         lact_grp = factor(case_when(lact_number == 1 ~ "1", lact_number == 2 ~ "2", TRUE ~ "3+")),
         hist = factor(if_else(history_group == "New", "No", "Yes")),
         week = ceiling(pmax(day_rel, 1) / 7)) |>
  filter(dim > 0, dim < 500)

# POST-alert weekly records only - the baseline period must not be in the outcome
wk <- d |>
  filter(day_rel >= 1) |>
  group_by(id_animal, tx_group, lact_grp, hist, week) |>
  summarize(kg = mean(kg), dim = mean(dim), base_kg = first(base_kg), .groups = "drop") |>
  filter(!is.na(kg), !is.na(base_kg))

cat("weekly post-alert records:", nrow(wk), " cows:", n_distinct(wk$id_animal), "\n\n")

vc_of <- function(m) {
  v <- as.data.frame(VarCorr(m))
  c(cow = v$sdcor[v$grp == "id_animal"], res = v$sdcor[v$grp == "Residual"])
}
za <- qnorm(0.975); zb <- qnorm(0.80)
report <- function(lab, s) {
  var_mean <- s[["cow"]]^2 + s[["res"]]^2 / 9     # variance of a cow's 9-week mean
  n_arm <- ceiling(2 * var_mean * (za + zb)^2 / 1.0^2)
  tot <- ceiling(3 * n_arm * 1.28 * 1.09 / 100) * 100
  cat(sprintf("%-34s cowSD %5.2f  resSD %5.2f  -> Var(mean) %6.2f  SD %5.2f  n/arm %5d  enrolled %s\n",
              lab, s[["cow"]], s[["res"]], var_mean, sqrt(var_mean), n_arm,
              format(tot, big.mark = ",")))
  invisible(var_mean)
}

cat("=== MODEL A: as p01 fits it (no baseline term) ===\n")
mA <- lmer(kg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + (1 | id_animal), data = wk)
sA <- vc_of(mA); report("A: no baseline covariate", sA)

cat("\n=== MODEL B: same, plus the cow's own pre-alert baseline ===\n")
mB <- lmer(kg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + base_kg + (1 | id_animal), data = wk)
sB <- vc_of(mB); report("B: baseline as covariate", sB)

cat("\n=== MODEL C: outcome expressed as change from baseline ===\n")
wk$chg <- wk$kg - wk$base_kg
mC <- lmer(chg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + (1 | id_animal), data = wk)
sC <- vc_of(mC); report("C: kg change from baseline", sC)

cat("\n=== cow-level correlation between baseline and post-alert mean ===\n")
cl <- wk |> group_by(id_animal) |>
  summarize(post = mean(kg), base = first(base_kg), .groups = "drop")
cat(sprintf("  n = %d cows, r = %.3f\n", nrow(cl), cor(cl$post, cl$base)))
cat(sprintf("  SD of raw post-alert cow mean      : %.2f kg\n", sd(cl$post)))
cat(sprintf("  SD of post-alert residual on base  : %.2f kg\n", sd(resid(lm(post ~ base, cl)))))
