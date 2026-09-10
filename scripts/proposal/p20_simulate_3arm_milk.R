# THREE-ARM simulation, with the farm's own detection processes parameterised
# from the pilot rather than assumed.
#
# Arm 1  treated within 1 week of the alert
# Arm 2  treated at 4 weeks, OR EARLIER if staff spot her or the routine round
#        reaches her first - she is not held back
# Arm 3  regular farm practice: treated only if staff or the routine round
#        catch her
#
# TWO DETECTION PROCESSES, not one. The pilot's Control arm separates them and
# they behave very differently:
#
#            share of Control cows   week-of-trim distribution
#   staff          17.7%             front-loaded: 55% in week 1, 88% by day 28
#   routine        32.1%             spread: 54% by day 28, a tail out past 9 wks
#   never          50.2%
#
# This matters for arm 2 specifically. 66% of all catches land inside the first
# four weeks, so about a third of arm 2 would be treated before its protocol
# week - pulling arm 2 toward arm 1 and shrinking the 1-vs-2 contrast. An
# earlier version of this script drew the catch week uniformly over weeks 2-9,
# which put only 38% inside 28 days and excluded week 1 entirely, the single
# most common week. That understated the contamination.
#
# Gerard's design point: rechecks and dry-off trims can be standardised across
# farms, mid-lactation ROUTINE trimming cannot. So routine coverage is the
# herd-varying part; staff detection is treated as roughly constant.
suppressPackageStartupMessages({library(tidyverse); library(glmmTMB); library(splines)})

SD_COW <- 9.39; SD_RESID <- 4.79; N_WEEKS <- 9; N_HERDS <- 5

# empirical week-of-trim counts from the pilot's Control arm
W_STAFF   <- c(44, 16, 7, 3, 3, 0, 2, 3, 2)      # n = 80
W_ROUTINE <- c(26, 32, 11, 9, 19, 13, 10, 1, 24) # n = 145
P_STAFF_DEFAULT   <- 80 / 452
P_ROUTINE_DEFAULT <- 145 / 452

sim_once <- function(n_total, full_effect, routine_mean = P_ROUTINE_DEFAULT,
                     p_staff = P_STAFF_DEFAULT, routine_spread = 0.10) {
  # only the routine round varies by herd; staff detection is held constant
  herd_cov <- pmin(pmax(rnorm(N_HERDS, routine_mean, routine_spread), 0.02), 0.95)

  cows <- tibble(
    cow_id    = factor(seq_len(n_total)),
    herd      = sample(1:N_HERDS, n_total, replace = TRUE),
    lactation = factor(sample(c("1", "2", "3+"), n_total, replace = TRUE, prob = c(.35, .30, .35))),
    history   = factor(sample(c("Yes", "No"), n_total, replace = TRUE)),
    start_dim = sample(40:200, n_total, replace = TRUE)) |>
    group_by(lactation, history) |>
    mutate(arm = factor(sample(rep(c("A1_early", "A2_delayed", "A3_practice"), length.out = n())),
                        levels = c("A3_practice", "A1_early", "A2_delayed"))) |>
    ungroup() |>
    mutate(
      herd_id = factor(herd),
      cow_potential = 28 + case_when(lactation == "1" ~ 0, lactation == "2" ~ 3.6, TRUE ~ 6.8) +
        if_else(history == "Yes", 2.3, 0) + rnorm(n_total, 0, SD_COW),
      # each cow draws a would-be staff week and a would-be routine week; she is
      # caught by whichever process fires, at the earlier of the two
      staff_hit   = runif(n_total) < p_staff,
      routine_hit = runif(n_total) < herd_cov[herd],
      staff_wk    = sample(1:9, n_total, replace = TRUE, prob = W_STAFF / sum(W_STAFF)),
      routine_wk  = sample(1:9, n_total, replace = TRUE, prob = W_ROUTINE / sum(W_ROUTINE)),
      farm_wk     = pmin(if_else(staff_hit, staff_wk, 999L),
                         if_else(routine_hit, routine_wk, 999L)),
      treat_week  = case_when(
        arm == "A1_early"    ~ 1L,
        arm == "A2_delayed"  ~ pmin(5L, farm_wk),
        TRUE                 ~ farm_wk))

  wk <- cows |>
    uncount(N_WEEKS, .id = "week") |>
    mutate(avg_dim = start_dim + week * 7 - 3,
           lact_curve = 6.8 * log(avg_dim) - 0.032 * avg_dim,
           gain = if_else(week >= treat_week, full_effect, 0),
           weekly_avg_yield = lact_curve + cow_potential + gain + rnorm(n(), 0, SD_RESID))

  # arm as a main effect: the coefficients are average effects. The interaction
  # version costs exactly 2x - verified separately.
  m <- try(suppressWarnings(glmmTMB(
    weekly_avg_yield ~ arm + history + lactation + ns(avg_dim, df = 3) +
      (1 | herd_id) + (1 | cow_id), data = wk)), silent = TRUE)
  if (inherits(m, "try-error")) return(NULL)
  co <- summary(m)$coefficients$cond
  r1 <- "armA1_early"; r2 <- "armA2_delayed"
  if (!all(c(r1, r2) %in% rownames(co))) return(NULL)
  e1 <- co[r1, "Estimate"]; s1 <- co[r1, "Std. Error"]
  e2 <- co[r2, "Estimate"]; s2 <- co[r2, "Std. Error"]
  V <- vcov(m)$cond
  sd_ <- sqrt(V[r1, r1] + V[r2, r2] - 2 * V[r1, r2]); ed <- e1 - e2

  tibble(n_total, full_effect, routine_mean,
         est_1v3 = abs(e1), sig_1v3 = abs(e1) - 1.96 * s1 > 0,
         est_2v3 = abs(e2), sig_2v3 = abs(e2) - 1.96 * s2 > 0,
         est_1v2 = abs(ed), sig_1v2 = abs(ed) - 1.96 * sd_ > 0)
}

args <- commandArgs(trailingOnly = TRUE)
NREP <- if (length(args) >= 1) as.integer(args[1]) else 30
if (length(args) >= 2 && args[2] == "time") {
  t0 <- Sys.time(); print(sim_once(1500, 2.0))
  cat("one run at n=1500:", round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 2), "s\n"); quit()
}

set.seed(20260910)
main <- expand_grid(n_total = c(900, 1500, 2400, 3600, 6000),
                    full_effect = c(1.0, 1.5, 2.0, 3.0), routine_mean = P_ROUTINE_DEFAULT)
sens <- expand_grid(n_total = 2400, full_effect = 1.5, routine_mean = c(0.10, 0.20, 0.45, 0.60))
grid <- bind_rows(main, sens)
res <- pmap_dfr(grid, function(n_total, full_effect, routine_mean)
  map_dfr(seq_len(NREP), function(i) sim_once(n_total, full_effect, routine_mean)))
saveRDS(res, "output/sim3_res.rds")

s <- res |> group_by(routine_mean, full_effect, n_total) |>
  summarize(reps = n(),
            o13 = round(mean(est_1v3), 2), p13 = round(100 * mean(sig_1v3)),
            o23 = round(mean(est_2v3), 2), p23 = round(100 * mean(sig_2v3)),
            o12 = round(mean(est_1v2), 2), p12 = round(100 * mean(sig_1v2)),
            .groups = "drop")
base <- s |> filter(abs(routine_mean - P_ROUTINE_DEFAULT) < 1e-9)

cat("\n=== OBSERVED CONTRAST SIZES (kg), at the pilot's detection rates ===\n")
print(base |> select(full_effect, n_total, o13, o23, o12) |> filter(n_total == 2400) |> as.data.frame())
cat("\n=== ARM 1 vs ARM 3 - power % ===\n")
print(base |> select(full_effect, n_total, p13) |>
        pivot_wider(names_from = n_total, values_from = p13) |> as.data.frame())
cat("\n=== ARM 1 vs ARM 2 (does timing matter) - power % ===\n")
print(base |> select(full_effect, n_total, p12) |>
        pivot_wider(names_from = n_total, values_from = p12) |> as.data.frame())
cat("\n=== ARM 2 vs ARM 3 - power % ===\n")
print(base |> select(full_effect, n_total, p23) |>
        pivot_wider(names_from = n_total, values_from = p23) |> as.data.frame())
cat("\n=== SENSITIVITY to ROUTINE coverage (n=2400, effect 1.5 kg, staff held at 17.7%) ===\n")
print(s |> filter(n_total == 2400, full_effect == 1.5) |>
        select(routine_mean, o13, p13, o12, p12) |> as.data.frame())
cat("\nreps:", NREP, "; n_total across ALL THREE arms; staff detection", round(100*P_STAFF_DEFAULT,1), "%\n")
