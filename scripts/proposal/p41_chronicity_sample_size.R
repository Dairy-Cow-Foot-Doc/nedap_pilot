# New v chronic: how big is the treatment effect in each, and what does the
# design need to estimate it (2026-09-29).
#
# Gerard expects the benefit to be larger in NEW cows than in chronic ones, and
# the pilot's milk curves pointed that way. Draft 4's section 6 sized the
# chronicity question on a 50/50 split and quoted a within-subgroup interval as
# if it were the interaction's. This script:
#   1. estimates the pilot's TX-v-Control milk contrast separately in new and
#      chronic cows, on the same baseline-adjusted model p38 sizes on;
#   2. sizes, with the same arm-by-herd random-slope simulation as p38, (a) the
#      overall contrast, (b) the effect in new cows alone, (c) the effect in
#      chronic cows alone, (d) the new-v-chronic difference (the interaction),
#      at the pilot's real split and under effect scenarios anchored on the
#      planning 1.0 kg overall contrast.
#
# Run from the project root: Rscript scripts/proposal/p41_chronicity_sample_size.R
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

# Same outcome construction as p38. hist: "No" = New, "Yes" = chronic or repeat.
LB_PER_KG <- 2.20462
d <- milk_norm |>
  filter(!is.na(dmlk1), day_rel >= 1) |>
  mutate(kg = dmlk1 / LB_PER_KG, base_kg = baseline_dmlk1 / LB_PER_KG,
         dim = dim_at_nedlame + day_rel,
         lact_grp = factor(case_when(lact_number == 1 ~ "1", lact_number == 2 ~ "2", TRUE ~ "3+")),
         hist = factor(if_else(history_group == "New", "New", "Chronic"), levels = c("New", "Chronic")),
         tx = factor(tx_group, levels = c("Control", "TX (Trim)")),
         week = ceiling(day_rel / 7)) |>
  filter(dim > 0, dim < 500)
full90 <- cohort |> filter(first_nedlame_date <= milk_end - 90) |> pull(id_animal)
weekly <- function(dat, max_week) dat |>
  filter(week <= max_week) |>
  group_by(id_animal, tx, lact_grp, hist, week) |>
  summarize(kg = mean(kg), dim = mean(dim), base_kg = first(base_kg), .groups = "drop") |>
  filter(!is.na(kg), !is.na(base_kg))

# ---- 1. the pilot's contrast in each group ------------------------------------
# Parameterised as tx nested in hist, so each coefficient IS the TX-v-Control
# contrast in that group, with its own SE; the interaction is their difference.
by_group <- function(wk, lab) {
  m <- lmer(kg ~ hist + hist:tx + lact_grp + ns(dim, df = 3) + base_kg + (1 | id_animal), data = wk)
  b <- fixef(m); V <- as.matrix(vcov(m))
  kn <- "histNew:txTX (Trim)"; kc <- "histChronic:txTX (Trim)"
  diff_se <- sqrt(V[kn, kn] + V[kc, kc] - 2 * V[kn, kc])
  cows <- wk |> distinct(id_animal, hist, tx) |> count(hist, tx)
  cat(sprintf("\n== %s: %d cows\n", lab, n_distinct(wk$id_animal)))
  print(cows |> pivot_wider(names_from = tx, values_from = n))
  out <- tibble(
    estimate = c("TX effect, new", "TX effect, chronic", "new minus chronic"),
    kg = c(b[kn], b[kc], b[kn] - b[kc]),
    se = c(sqrt(V[kn, kn]), sqrt(V[kc, kc]), diff_se)) |>
    mutate(lo = kg - 1.96 * se, hi = kg + 1.96 * se)
  print(out |> mutate(across(where(is.numeric), \(x) round(x, 2))))
  invisible(out)
}
e30 <- by_group(weekly(d, 4), "days 1-30, all cows")
e90 <- by_group(weekly(d |> filter(id_animal %in% full90), 13), "days 1-90, full-90 cows")

p_new <- mean(cohort$history_group == "New")
cat(sprintf("\nshare of enrolled cows that are new: %.3f\n", p_new))

# ---- 2. sizing ------------------------------------------------------------------
# p38's planning variance (90th bootstrap percentile of Var(cow 90-day mean),
# baseline model) and its random-slope power simulation, generalised so the
# herd-level estimate can be a subgroup effect or a difference of two.
VAR_MEAN <- 51.9; ATTR <- 1.28; za <- qnorm(0.975); K <- 6
# se2_fn(N): variance of the pooled estimate at N enrolled, ignoring tau.
power_rs <- function(N, delta, se2_fn, tau = 0.25, k = K, R = 40000) {
  s2 <- k * se2_fn(N)
  b <- matrix(rnorm(R * k, delta, sqrt(s2 + tau^2)), R); m <- rowMeans(b)
  Q <- rowSums((b - m)^2) / s2; t2 <- pmax(0, (Q - (k - 1)) * s2 / (k - 1))
  mean(abs(m / sqrt((s2 + t2) / k)) > za)
}
size_rs <- function(delta, se2_fn, tau = 0.25) {
  for (N in seq(1000, 60000, 100)) if (power_rs(N, delta, se2_fn, tau) >= 0.80) return(N)
  NA
}
n_arm <- function(N) N / 3 / ATTR
se2_all     <- function(p) function(N) 2 * VAR_MEAN / n_arm(N)
se2_new     <- function(p) function(N) 2 * VAR_MEAN / (n_arm(N) * p)
se2_chronic <- function(p) function(N) 2 * VAR_MEAN / (n_arm(N) * (1 - p))
se2_diff    <- function(p) function(N) 2 * VAR_MEAN / n_arm(N) * (1 / p + 1 / (1 - p))

# Scenarios hold the OVERALL observed contrast at the planning 1.0 kg - the
# number the 4,000 is built on - and split it between the groups. "Pilot ratio"
# takes the chronic effect as a share of the new effect from the 30-day fit
# (more cows than the 90-day one), floored at 0.
ratio_pilot <- max(0, e30$kg[2] / e30$kg[1])
scen <- tibble(scenario = c("equal effect", "chronic half of new", "pilot ratio", "none in chronic"),
               ratio = c(1, 0.5, ratio_pilot, 0))
set.seed(41)
res <- expand_grid(scen, p = c(p_new, 0.5)) |>
  mutate(new_kg = 1.0 / (p + (1 - p) * ratio), chronic_kg = ratio * new_kg,
         diff_kg = new_kg - chronic_kg) |>
  mutate(N_overall = map_dbl(p, \(p) size_rs(1.0, se2_all(p))),
         N_new     = map2_dbl(new_kg, p, \(dl, p) size_rs(dl, se2_new(p))),
         N_chronic = map2_dbl(chronic_kg, p, \(dl, p) if (dl < 0.05) NA else size_rs(dl, se2_chronic(p))),
         N_diff    = map2_dbl(diff_kg, p, \(dl, p) if (dl < 0.05) NA else size_rs(dl, se2_diff(p))))
cat(sprintf("\n== Enrolled for 80%% power, 6 herds, tau 0.25, overall contrast 1.0 kg (pilot ratio = %.2f) ==\n", ratio_pilot))
print(res |> mutate(across(c(ratio, new_kg, chronic_kg, diff_kg), \(x) round(x, 2))), width = 200)

# ---- 3. what 4,000 gives ----------------------------------------------------------
# Intervals at the design size. The tau share is approximated by the ratio the
# simulation needs: 1.96 x sqrt(se2 + tau^2 / k) - the between-herd term enters
# every herd-level estimate once.
at <- function(se2_fn, N = 4000) 1.96 * sqrt(se2_fn(N) + 0.25^2 / K)
pw <- function(delta, se2_fn, N = 4000) power_rs(N, delta, se2_fn)
cat("\n== At 4,000 enrolled, pilot split ==\n")
iv <- tibble(estimate = c("overall", "new cows", "chronic cows", "new minus chronic"),
             ci_halfwidth_kg = c(at(se2_all(p_new)), at(se2_new(p_new)),
                                 at(se2_chronic(p_new)), at(se2_diff(p_new))))
print(iv |> mutate(ci_halfwidth_kg = round(ci_halfwidth_kg, 2)))
for (i in seq_len(nrow(scen))) {
  r <- scen$ratio[i]; nk <- 1.0 / (p_new + (1 - p_new) * r)
  cat(sprintf("  %-20s new %.2f kg, chronic %.2f kg: power in new cows %.0f%%, power on the difference %s\n",
              scen$scenario[i], nk, r * nk, 100 * pw(nk, se2_new(p_new)),
              if (nk * (1 - r) < 0.05) "n/a" else sprintf("%.0f%%", 100 * pw(nk * (1 - r), se2_diff(p_new)))))
}

# ---- 4. two checks on the anchoring ----------------------------------------------
# (a) The overall contrast on this same model. The planning 1.0 kg comes from the
#     pilot's days 25-30 figure; a days 1-30 average includes the early post-trim
#     dip, so it need not match - but if it is far off, say so.
overall <- function(wk, lab) {
  m <- lmer(kg ~ tx + hist + lact_grp + ns(dim, df = 3) + base_kg + (1 | id_animal), data = wk)
  k <- "txTX (Trim)"
  cat(sprintf("  %-26s overall TX effect %.2f kg (SE %.2f)\n", lab, fixef(m)[k], sqrt(vcov(m)[k, k])))
}
cat("\n== Overall contrast, same model, no interaction ==\n")
overall(weekly(d, 4), "days 1-30, all cows")
overall(weekly(d |> filter(week >= 4), 5), "days 22-35, all cows")
overall(weekly(d |> filter(id_animal %in% full90), 13), "days 1-90, full-90 cows")
# (b) Size the difference directly on what the pilot saw, not on a split of 1.0.
cat("\n== Enrolled for 80% power on the new-minus-chronic difference, 6 herds, tau 0.25 ==\n")
for (dl in c(1.0, 1.5, round(e30$kg[3], 2))) for (p in c(p_new, 0.5))
  cat(sprintf("  difference %.2f kg, %.0f%% new: %s enrolled\n", dl, 100 * p,
              format(size_rs(dl, se2_diff(p)), big.mark = ",")))
