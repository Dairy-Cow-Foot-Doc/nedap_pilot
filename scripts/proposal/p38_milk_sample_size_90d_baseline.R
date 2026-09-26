# D2, re-measured over the full 90-day outcome window (2026-09-26).
#
# p31 found that adding each cow's pre-alert baseline cut the sample size from
# ~6,200 to ~2,300 - but over days 1-30 only, and the review left it open because
# the baseline correlation should weaken further from the alert. Pilot milk now
# runs far enough past the first alerts to measure 90 days directly, so this
# fits the same models on cows with a full 13 weeks and sizes the study on the
# result, with the arm-by-herd random slope (tau) the analysis will actually use.
#
# Run from the project root: Rscript scripts/proposal/p38_milk_sample_size_90d_baseline.R
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(splines); library(lme4)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
source("functions/fxn_read_milk_folder.R")
params <- list(milk_window_pre = 14, milk_window_post = 90, milk_baseline_days = 7,
               q4_lookback_days = 28, history_after_date = "2026-06-01",
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

milk_end <- max(mr$milk_date)
cat("milk data ends", format(milk_end), "\n")

LB_PER_KG <- 2.20462
d <- milk_norm |>
  filter(!is.na(dmlk1), day_rel >= 1) |>
  mutate(kg = dmlk1 / LB_PER_KG, base_kg = baseline_dmlk1 / LB_PER_KG,
         dim = dim_at_nedlame + day_rel,
         lact_grp = factor(case_when(lact_number == 1 ~ "1", lact_number == 2 ~ "2", TRUE ~ "3+")),
         hist = factor(if_else(history_group == "New", "No", "Yes")),
         week = ceiling(day_rel / 7)) |>
  filter(dim > 0, dim < 500)

# Cows whose alert is at least 90 days before the milk data ends - the only
# ones who COULD have a full window. Drying off or culling inside it is real
# attrition and stays in (handled by the x1.28), not a data gap.
full90 <- cohort |> filter(first_nedlame_date <= milk_end - 90) |> pull(id_animal)
cat("cows alerted >= 90 days before milk ends:", length(full90), "\n")

weekly <- function(dat, max_week) dat |>
  filter(week <= max_week) |>
  group_by(id_animal, tx_group, lact_grp, hist, week) |>
  summarize(kg = mean(kg), dim = mean(dim), base_kg = first(base_kg), .groups = "drop") |>
  filter(!is.na(kg), !is.na(base_kg))

za <- qnorm(0.975); zb <- qnorm(0.80); DELTA <- 1.0; ATTR <- 1.28
fit <- function(wk, weeks, lab) {
  mA <- lmer(kg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + (1 | id_animal), data = wk)
  mB <- lmer(kg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + base_kg + (1 | id_animal), data = wk)
  out <- map_dfr(list(A_no_baseline = mA, B_baseline = mB), function(m) {
    v <- as.data.frame(VarCorr(m))
    cow <- v$sdcor[v$grp == "id_animal"]; res <- v$sdcor[v$grp == "Residual"]
    var_mean <- cow^2 + res^2 / weeks                 # variance of a cow's window mean
    n_arm <- ceiling(2 * var_mean * (za + zb)^2 / DELTA^2)
    tibble(cow_sd = cow, res_sd = res, var_mean = var_mean, n_arm = n_arm,
           enrolled_no_tau = 3 * n_arm * ATTR)
  }, .id = "model")
  cl <- wk |> group_by(id_animal) |> summarize(post = mean(kg), base = first(base_kg), .groups = "drop")
  cat(sprintf("\n== %s: %d cows, %d weekly records, r(baseline, post mean) = %.3f\n",
              lab, n_distinct(wk$id_animal), nrow(wk), cor(cl$post, cl$base)))
  print(out |> mutate(across(where(is.numeric), \(x) round(x, 2))))
  out
}

r30_all  <- fit(weekly(d, 4), 4, "days 1-30, all cows (p31's basis)")
r30_same <- fit(weekly(d |> filter(id_animal %in% full90), 4), 4, "days 1-30, full-90 cows only")
r90      <- fit(weekly(d |> filter(id_animal %in% full90), 13), 13, "days 1-90, full-90 cows")

# ---- size it with the random slope --------------------------------------------
# Per-herd arm-1-v-3 estimates b_h ~ N(delta + u_h, s2), u_h ~ N(0, tau^2); tau
# estimated from the herds (DL, truncated at 0) exactly as a random-slope REML
# fit would, and tested on z. Same simulation as the 2026-09-26 review.
power_rs <- function(N, k, var_mean, tau = 0.25, R = 40000) {
  n_arm <- N / 3 / ATTR
  var_contrast <- 2 * var_mean / n_arm            # pooled, ignoring tau
  s2 <- k * var_contrast
  b <- matrix(rnorm(R * k, DELTA, sqrt(s2 + tau^2)), R); m <- rowMeans(b)
  Q <- rowSums((b - m)^2) / s2; t2 <- pmax(0, (Q - (k - 1)) * s2 / (k - 1))
  mean(abs(m / sqrt((s2 + t2) / k)) > za)
}
size_rs <- function(var_mean, k, tau = 0.25) {
  Ns <- seq(600, 12000, 100)
  for (N in Ns) if (power_rs(N, k, var_mean, tau) >= 0.80) return(N)
  NA
}
set.seed(38)
cat("\n== Enrolled for 80% power on a 1.0 kg arm-1-v-3 contrast, random slope, x1.28 attrition ==\n")
grid <- expand_grid(basis = c("A_no_baseline", "B_baseline"), k = c(6, 8, 10), tau = c(0.25, 0.5))
grid$var_mean <- r90$var_mean[match(grid$basis, r90$model)]
grid$enrolled <- pmap_dbl(grid, \(basis, k, tau, var_mean) size_rs(var_mean, k, tau))
grid$per_herd <- round(grid$enrolled / grid$k)
print(grid |> select(-var_mean), n = 20)

# ---- how sure is the 90-day baseline variance? --------------------------------
# It rests on only the cows alerted early enough for 90 days of milk. Bootstrap
# cows, refit model B, and plan on an upper percentile rather than the point.
wk90 <- weekly(d |> filter(id_animal %in% full90), 13)
ids <- unique(wk90$id_animal)
boot <- map_dbl(1:300, function(i) {
  pick <- tibble(id_animal = sample(ids, replace = TRUE)) |> mutate(bid = row_number())
  bd <- pick |> left_join(wk90, by = "id_animal", relationship = "many-to-many") |> mutate(id_animal = paste(id_animal, bid))
  m <- suppressMessages(lmer(kg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + base_kg + (1 | id_animal), data = bd))
  v <- as.data.frame(VarCorr(m)); v$sdcor[v$grp == "id_animal"]^2 + v$sdcor[v$grp == "Residual"]^2 / 13
})
q <- quantile(boot, c(.5, .8, .9))
cat(sprintf("\n== bootstrap Var(90-day mean), baseline model: median %.1f | 80th %.1f | 90th %.1f  (no baseline: %.1f)\n",
            q[1], q[2], q[3], r90$var_mean[1]))
for (p in names(q)[2:3]) for (k in c(6, 8)) {
  cat(sprintf("  planning at the %s percentile, %d herds: %s enrolled (tau 0.25)\n", p, k,
              format(size_rs(q[[p]], k), big.mark = ",")))
}
