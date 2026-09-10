# SIMULATION for the cure outcome.
#
# Worth doing rather than using the two-proportion formula, because the closed
# form ignores three things this design actually has:
#   1. multi-stage selection - enrolled -> gets a WLD/SU -> is assessed
#   2. herd-level variation in both the cure rate and the assessment rate
#   3. arm-2 contamination: a third of arm 2 is treated before its protocol
#      week, so its cure rate sits between arm 1's and arm 3's rather than at
#      the delayed-treatment value
#
# Pilot inputs:
#   18.3% of alerted cows get a white line or sole ulcer
#   49.3% cure at 60 days among those re-examined (WLD/SU)
#   60.2% currently re-examined; ~95% under a scheduled recheck
#   74.8% reach a dry-off trim, no standardisation needed
suppressPackageStartupMessages({library(tidyverse); library(lme4)})

P_LESION   <- 0.183
P_CURE_A3  <- 0.493     # cure under regular practice (WLD/SU, 60 d)
P_CHRONIC  <- 0.363    # share chronic among WLD/SU index cases (1040/2852)
# measured main effect: chronic cure 45.0% vs new 51.9%, a -6.9 point gap
LOR_CHRONIC <- qlogis(0.450) - qlogis(0.519)
N_HERDS    <- 5

sim_cure <- function(n_total, cure_gain, p_assess,
                     herd_sd_cure = 0.35,   # logit-scale between-herd SD
                     frac_a2_early = 0.33) {# arm 2 treated before protocol week
  herd_off <- rnorm(N_HERDS, 0, herd_sd_cure)
  d <- tibble(
    herd = sample(1:N_HERDS, n_total, replace = TRUE),
    # A3 (regular practice) must be the REFERENCE level; left as a
    # character it sorted A1 first and the armA1 coefficient did not exist
    arm  = factor(sample(rep(c("A1", "A2", "A3"), length.out = n_total)),
                  levels = c("A3", "A1", "A2"))) |>
    mutate(
      history = factor(if_else(runif(n_total) < P_CHRONIC, "Chronic", "New"),
                       levels = c("New", "Chronic")),
      got_lesion = runif(n_total) < P_LESION,
      assessed   = got_lesion & runif(n_total) < p_assess,
      # arm 2: the contaminated fraction gets arm 1's benefit, the rest a
      # delayed benefit, here taken as half the full gain
      gain = case_when(
        arm == "A1" ~ cure_gain,
        arm == "A2" ~ if_else(runif(n_total) < frac_a2_early, cure_gain, cure_gain / 2),
        TRUE        ~ 0),
      p = plogis(qlogis(P_CURE_A3) + herd_off[herd] + gain +
                   if_else(history == "Chronic", LOR_CHRONIC, 0)),
      cured = runif(n_total) < p)
  a <- d |> filter(assessed)
  if (n_distinct(a$arm) < 3 || nrow(a) < 30) return(NULL)
  grab <- function(fm) {
    m <- try(suppressMessages(suppressWarnings(
      glmer(fm, data = a, family = binomial,
            control = glmerControl(optimizer = "bobyqa")))), silent = TRUE)
    if (inherits(m, "try-error")) return(c(NA, NA))
    co <- summary(m)$coefficients
    if (!"armA1" %in% rownames(co)) return(c(NA, NA))
    c(co["armA1", "Estimate"], co["armA1", "Std. Error"])
  }
  # MAIN-EFFECTS model: chronicity adjusted for, arm coefficient is the average
  mm <- grab(cured ~ arm + history + (1 | herd))
  # INTERACTION model: arm coefficient is the effect in New cows only
  mi <- grab(cured ~ arm * history + (1 | herd))
  if (is.na(mm[1]) || is.na(mi[1])) return(NULL)
  tibble(n_total, cure_gain, p_assess, n_assessed = nrow(a),
         se_main = mm[2], sig_main = abs(mm[1]) - 1.96 * mm[2] > 0,
         se_int  = mi[2], sig_int  = abs(mi[1]) - 1.96 * mi[2] > 0)
}

args <- commandArgs(trailingOnly = TRUE)
NREP <- if (length(args) >= 1) as.integer(args[1]) else 30
if (length(args) >= 2 && args[2] == "time") {
  t0 <- Sys.time(); print(sim_cure(3000, log(1.8), 0.95))
  cat("one run:", round(as.numeric(difftime(Sys.time(), t0, units="secs")), 2), "s\n"); quit()
}

# cure_gain is a log odds ratio; convert target percentage-point gains
pt_to_lor <- function(pts) qlogis(P_CURE_A3 + pts) - qlogis(P_CURE_A3)
set.seed(20260910)
grid <- expand_grid(n_total = c(2000, 3000, 4300, 6000, 9000),
                    pts = c(0.10, 0.15, 0.20),
                    p_assess = c(0.602, 0.748, 0.95))
res <- pmap_dfr(grid, function(n_total, pts, p_assess)
  map_dfr(seq_len(NREP), function(i)
    sim_cure(n_total, pt_to_lor(pts), p_assess) |>
      mutate(pts = pts)))
saveRDS(res, "output/cure_res.rds")

cat("
=== SE ratio interaction/main (2x cost shows as sqrt(2) = 1.414) ===
")
cat("  mean ratio:", round(mean(res$se_int / res$se_main, na.rm = TRUE), 3), "
")
cat("  implied sample-size multiplier:",
    round(mean(res$se_int / res$se_main, na.rm = TRUE)^2, 2), "x
")
s <- res |> group_by(pts, p_assess, n_total) |>
  summarize(reps = n(), assessed = round(mean(n_assessed)),
            power = round(100 * mean(sig_main)), power_int = round(100 * mean(sig_int)), .groups = "drop")
for (pa in c(0.602, 0.748, 0.95)) {
  lab <- c("0.602" = "current practice 60%", "0.748" = "dry-off trim 75%",
           "0.95" = "scheduled recheck 95%")[as.character(pa)]
  cat("\n=== assessment route:", lab, "- power % for arm 1 v arm 3 ===\n")
  print(s |> filter(p_assess == pa) |>
          mutate(pts = paste0("+", 100*pts, " pts")) |>
          select(pts, n_total, power) |>
          pivot_wider(names_from = n_total, values_from = power) |> as.data.frame())
}
cat("\nreps:", NREP, "; n_total is enrolled across ALL THREE arms\n")
cat("herd SD on the logit of cure: 0.35; arm-2 early-treatment fraction: 0.33\n")
