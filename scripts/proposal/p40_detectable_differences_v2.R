# What the resized design detects (2026-09-26), replacing p12's 6,000-cow table.
#
# Changes from p12, each from the 2026-09-26 review:
#  - N = 4,000 enrolled: milk sized with each cow's baseline as a covariate over
#    90 days, planned at the 90th bootstrap percentile of the variance, with an
#    arm-by-herd random slope at tau 0.25 kg across 6 herds (p38).
#  - Culling on ALL enrolled cows, at 180 days (fix B1). Lesion cows are not a
#    randomised subset, because finding a lesion depends on the arm.
#  - Recurrence at 180 days, cow-level (follows her across a calving) - p39.
#  - Dry-off baseline and the share of cows who reach dry-off inside follow-up,
#    computed here rather than assumed (the draft's 30% and 66% had no script).
#
# Run from the project root: Rscript scripts/proposal/p40_detectable_differences_v2.R
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})
source("functions/fxn_load_os_fxns.R"); suppressMessages(fxn_load_os_fxns())
source("functions/fxn_code_lesions.R"); source("functions/fxn_collapse_lesions.R")
source("functions/fxn_nedlame_analysis.R")
params <- list(history_after_date = "2026-06-01", recent_trim_suppression_days = 28,
               post_trim_exclusion_days = 7, analysis_end_date = "2026-08-27")
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
ef <- read_parquet("data/intermediate_files/events_formatted.parquet")
an <- read_parquet("data/intermediate_files/animals.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")
ev_end <- max(ea$date_event, na.rm = TRUE)
invisible(list2env(fxn_build_cohort(ea, al, an, ev_end, params), environment()))
invisible(list2env(fxn_build_lame_history(ef, cohort), environment()))

# N from the command line (2026-09-30: 4,000 and 5,000 are both offered).
args <- commandArgs(trailingOnly = TRUE)
N <- if (length(args) >= 1) as.numeric(args[1]) else 4000; per_arm <- N / 3
za <- qnorm(0.975); zb <- qnorm(0.80)
P_LESION <- 0.35; P_WLDSU <- 0.183; P_RE <- 0.95        # pilot, as in p12
CURE <- 0.493; RECUR180 <- 0.361; CULL180 <- 0.160       # p03; p39; p39

mdd_prop <- function(n, p1) {
  f <- function(d) { p2 <- p1 - d; pb <- (p1 + p2) / 2
    n - (za * sqrt(2 * pb * (1 - pb)) + zb * sqrt(p1 * (1 - p1) + p2 * (1 - p2)))^2 / d^2 }
  uniroot(f, c(0.001, p1 * 0.95))$root
}
power_prop <- function(n, p1, d) { p2 <- p1 - d
  pnorm((abs(d) * sqrt(n) - za * sqrt(2 * ((p1 + p2) / 2) * (1 - (p1 + p2) / 2))) / sqrt(p1 * (1 - p1) + p2 * (1 - p2))) }

# ---- dry-off: baseline prevalence and who reaches it -------------------------
# Lactation length from completed lactations since 2023; alert DIM from the
# pilot cohort (DIM 5+). A cow counts if dry-off comes 90+ days after her alert
# and before her follow-up ends.
lac <- al |> filter(!is.na(date_fresh), !is.na(date_dry), date_fresh >= as.Date("2023-01-01")) |>
  mutate(len = as.numeric(date_dry - date_fresh)) |> filter(len > 150, len < 600)
dim_alert <- cohort$dim_at_nedlame[cohort$dim_at_nedlame >= 5]
set.seed(40); L <- sample(lac$len, 1e5, TRUE); D <- sample(dim_alert, 1e5, TRUE); gap <- L - D
reach <- function(fu) mean(gap >= 90 & gap <= fu)
cat(sprintf("dry-off 90+ days after alert and inside follow-up: %.0f%% at 6 months | %.0f%% at 9 | %.0f%% at 12\n",
            100 * reach(183), 100 * reach(274), 100 * reach(365)))
les <- lame_data |> filter(trimonly == 0) |> distinct(id_animal, lact_number, les_date = date_event)
tr  <- lame_data |> distinct(id_animal, lact_number, tr_date = date_event)
do <- lac |> select(id_animal, lact_number, date_dry) |>
  left_join(tr, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
  mutate(in_win = !is.na(tr_date) & tr_date >= date_dry - 45 & tr_date <= date_dry + 7) |>
  group_by(id_animal, lact_number, date_dry) |> summarize(trimmed = any(in_win), .groups = "drop") |>
  left_join(les, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
  mutate(l = !is.na(les_date) & les_date >= date_dry - 45 & les_date <= date_dry + 7) |>
  group_by(id_animal, lact_number, trimmed) |> summarize(lesion = any(l), .groups = "drop")
DRY_PREV <- mean(do$lesion[do$trimmed])
cat(sprintf("dry-off trim window (-45 to +7): %.0f%% of lactations trimmed; lesion found in %.1f%% of those (n = %s)\n\n",
            100 * mean(do$trimmed), 100 * DRY_PREV, format(sum(do$trimmed), big.mark = ",")))
P_DRY <- reach(183)   # conservative: the last cow's minimum follow-up

# ---- the table ----------------------------------------------------------------
cat(sprintf("=== WHAT %s ENROLLED DETECTS AT 80%% POWER (%s per arm) ===\n", format(N, big.mark = ","), format(round(per_arm), big.mark = ",")))
cat("  MILK          1.00 kg/day observed arm-1-v-3 contrast (sized for it, p38)\n")
n_cure <- per_arm * P_WLDSU * P_RE
cat(sprintf("  CURE WLD/SU   %.1f points on %.1f%% (arm 1 v 2, %.0f assessed/arm); +15 points has %.0f%% power\n",
            100 * mdd_prop(n_cure, CURE), 100 * CURE, n_cure, 100 * power_prop(n_cure, CURE, 0.15)))
n_do <- per_arm * P_DRY
cat(sprintf("  DRY-OFF PREV  %.1f points on %.1f%% (%.0f cows/arm reach dry-off)\n",
            100 * mdd_prop(n_do, DRY_PREV), 100 * DRY_PREV, n_do))
n_do12 <- per_arm * reach(365)
cat(sprintf("  DRY-OFF PREV, 12 months after the last cow: %.1f points (%.0f cows/arm)\n",
            100 * mdd_prop(n_do12, DRY_PREV), n_do12))
n_les <- per_arm * P_LESION
cat(sprintf("  RECURRENCE    %.1f points on %.1f%% at 180 d (%.0f lame cows/arm - descriptive, not randomised)\n",
            100 * mdd_prop(n_les, RECUR180), 100 * RECUR180, n_les))
cat(sprintf("  CULLING       %.1f points on %.1f%% at 180 d (ALL %s enrolled/arm - randomised)\n",
            100 * mdd_prop(per_arm, CULL180), 100 * CULL180, format(round(per_arm), big.mark = ",")))
hw <- 100 * za * sqrt(2 * CULL180 * (1 - CULL180) / per_arm)
cat(sprintf("  culling 95%% interval half-width on all enrolled: +/-%.1f points\n", hw))
# Break-even (p16: 0.72-1.75 points per LAME cow) expressed on all enrolled cows,
# assuming the culling benefit sits in the cows who had a lesion found.
be_all <- P_LESION * c(0.72, 1.75)
n_be <- sapply(be_all / 100, \(d) 2 * (za + zb)^2 * CULL180 * (1 - CULL180) / d^2 * 3)
cat(sprintf("  break-even on all enrolled: %.2f-%.2f points; detecting it needs %s-%s enrolled\n",
            be_all[1], be_all[2], format(round(n_be[2], -3), big.mark = ","), format(round(n_be[1], -3), big.mark = ",")))
