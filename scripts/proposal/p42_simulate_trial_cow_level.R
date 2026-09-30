# Cow-level simulation of the whole three-arm trial (2026-09-29, revised 09-30).
#
# Every sizing figure in the draft so far was checked one assumption at a time:
# p38 sized milk on an analytic cow variance plus a herd-level simulation, p41
# did the same for new v chronic, and the routine-trim dilution was scaled from
# the old working-doc sweep (p20). This script puts them together, cow by cow.
#
# DECISIONS IT ENCODES (Gerard, 2026-09-30)
#   - Cows alerted late in lactation stay in and contribute milk until they dry
#     off or leave. Nobody is dropped whole for drying off.
#   - Primary test (revised 2026-09-30 night): the conventional multi-centre
#     model - arm and herd fixed, no arm-by-herd term, one fit on all cows
#     (fe_est). Inference is on the enrolled herds. Hartung-Knapp (HK) pooling of
#     the per-herd contrasts is kept alongside for comparison only.
#
# THE MODEL
#   cows       resampled from the pilot cohort (DIM 5 floor): baseline milk, DIM
#              at alert, lactation group, new/chronic
#   leaving    each cow leaves milk at the earlier of dry-off and culling.
#              Dry-off: her remaining lactation, drawn from this herd's completed
#              lactation lengths for her lactation group, conditional on being
#              longer than her DIM at alert. Culling: constant hazard fitted to
#              the pilot's 90-day cull rate. Checked against the pilot cows that
#              could have had 90 days (check a). This replaces the old random
#              x1.28, which the review showed was about half the real loss and
#              ignored that the loss is concentrated in DIM 200+ cows.
#   outcome    her mean kg over the days she milks, up to 90. Its variance is
#              cow^2 + resid^2 / weeks - p38's baseline-adjusted variance
#              components, scaled so a full 13 weeks gives the planning 51.9 kg^2.
#              Mean structure from the pilot's own regression.
#   benefit    from the day she is trimmed to the day she leaves or day 90:
#              effect x (days milked after trim) / (days milked). Same accrual
#              rule as p20.
#   farm       in EVERY arm, staff (CHKLAME) and non-staff trims drawn from the
#              pilot Control arm by DIM band at alert - cause-specific
#              Kaplan-Meier, each censoring the other, follow-up ending 45 days
#              before dry-off (the dry-off trim is not dilution). A mechanistic
#              version from the herd's recorded trim schedule could not reproduce
#              the pilot's DIM pattern and was rejected (first two runs).
#   arm 1      trimmed at a draw from the pilot TX arm's Kaplan-Meier time to
#              first trim. That time already includes farm-caught trims, so no
#              second min() with the farm (review, issue 3).
#   arm 2      28 days + the same draw, or earlier if the farm trims her first
#   arm 3      farm only
#   herds      6; each herd's non-staff trim hazard scaled by a mean-one
#              lognormal (SD 0.3); each herd's true effect shifted by
#              N(0, TAU_TRUE), calibrated so the observed contrast varies by
#              0.25 kg between herds - the tau p38 sized on
#   analysis   per herd, weighted least squares of the cow means on the
#              protocol's covariates, weights 1 / (cow^2 + resid^2 / weeks) - the
#              GLS estimate a weekly random-intercept model gives for cow-level
#              terms. Per-herd contrasts pooled by DL; tested by HK.
#
# Not modelled: an early post-trim milk dip; later alerts' effect on milk; herds
# differing in staff detection; a dry-off trim's few days of benefit.
#
# Run from the project root:
#   Rscript scripts/proposal/p42_simulate_trial_cow_level.R [reps] [checks]
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(splines); library(lme4)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
source("functions/fxn_read_milk_folder.R")
args <- commandArgs(trailingOnly = TRUE)
REPS <- if (length(args) >= 1) as.integer(args[1]) else 1000
CHECKS_ONLY <- length(args) >= 2 && args[2] == "checks"
HERDS_ONLY  <- length(args) >= 2 && args[2] == "herds"   # the 5,000-cow design tables
CI_ONLY     <- length(args) >= 2 && args[2] == "ci"      # estimate and 95% CI at 5,000

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
invisible(list2env(fxn_build_q2(cohort, ef, lame_data), environment()))
invisible(list2env(fxn_build_control_trim_drivers(next_events, cohort, ef, lame_data), environment()))
milk_long <- fxn_read_milk_folder(
  from = min(cohort$first_nedlame_date, na.rm = TRUE) - params$milk_window_pre,
  to   = max(cohort$first_nedlame_date, na.rm = TRUE) + params$milk_window_post)
mr <- fxn_resolve_milk_to_lactation(milk_long, al)
invisible(list2env(fxn_build_q1(cohort, mr, params), environment()))
milk_end <- max(mr$milk_date)
lg <- function(l) factor(case_when(l == 1 ~ "1", l == 2 ~ "2", TRUE ~ "3+"), levels = c("1", "2", "3+"))
band <- function(x) cut(x, c(-1, 60, 120, 200, 1000), labels = c("0-60", "61-120", "121-200", "200+"))
LB_PER_KG <- 2.20462
K <- 6

# ============================================================================
# 1. INPUTS FROM THE PILOT
# ============================================================================

# ---- cows to resample -------------------------------------------------------
d <- milk_norm |>
  filter(!is.na(dmlk1), day_rel >= 1, day_rel <= 90) |>
  mutate(kg = dmlk1 / LB_PER_KG, base_kg = baseline_dmlk1 / LB_PER_KG,
         dim = dim_at_nedlame + day_rel, week = ceiling(day_rel / 7),
         lact_grp = lg(lact_number), hist = factor(if_else(history_group == "New", "No", "Yes")))
pool <- d |> distinct(id_animal, base_kg, dim0 = dim_at_nedlame, lact_number, history_group) |>
  filter(!is.na(base_kg), dim0 >= 5, dim0 < 500) |>
  distinct(id_animal, .keep_all = TRUE) |>
  mutate(lact = lg(lact_number), chronic = as.integer(history_group != "New"))
cat("resampling pool:", nrow(pool), "cows; new", round(100 * mean(pool$chronic == 0), 1), "%;",
    "DIM 200+", round(100 * mean(pool$dim0 > 200), 1), "%\n")

# ---- variance components: p38's baseline model, scaled to the planning value ---
full90 <- cohort |> filter(first_nedlame_date <= milk_end - 90) |> pull(id_animal)
wk <- d |> filter(id_animal %in% full90) |>
  group_by(id_animal, tx_group, lact_grp, hist, week) |>
  summarize(kg = mean(kg), dim = mean(dim), base_kg = first(base_kg), .groups = "drop") |>
  filter(!is.na(kg), !is.na(base_kg))
mB <- lmer(kg ~ tx_group * hist + lact_grp + ns(dim, df = 3) + base_kg + (1 | id_animal), data = wk)
vc <- as.data.frame(VarCorr(mB))
V_COW <- vc$vcov[vc$grp == "id_animal"]; V_RES <- vc$vcov[vc$grp == "Residual"]
VAR_PLAN <- 51.9                                  # p38 planning Var(13-week mean)
SCALE <- VAR_PLAN / (V_COW + V_RES / 13)
V_COW <- V_COW * SCALE; V_RES <- V_RES * SCALE
cat(sprintf("variance components (scaled x%.2f to the planning value): cow %.1f, weekly residual %.1f kg^2\n",
            SCALE, V_COW, V_RES))

# ---- mean structure: the pilot's regression of the cow mean -------------------
cl90 <- d |> filter(id_animal %in% full90) |> group_by(id_animal) |>
  summarize(post = mean(kg), .groups = "drop") |> inner_join(pool, by = "id_animal")
NSB <- ns(pool$dim0, df = 3)
Xf <- function(base, dim0, lact, chronic)
  cbind(1, base, predict(NSB, dim0), lact == "2", lact == "3+", chronic)
BETA <- lm.fit(Xf(cl90$base_kg, cl90$dim0, cl90$lact, cl90$chronic), cl90$post)$coefficients

# ---- leaving milk: dry-off from the herd's lactation lengths, plus culling ----
lens <- al |> filter(!is.na(date_fresh), !is.na(date_dry), date_dry >= as.Date("2024-09-01")) |>
  mutate(len = as.numeric(date_dry - date_fresh), lact = lg(lact_number)) |>
  filter(len >= 150, len <= 700)
LENS <- map(split(lens$len, lens$lact), sort)
cat("completed lactation length, median (lact 1 / 2 / 3+):",
    paste(sapply(LENS, median), collapse = " / "), "days\n")
# 90-day cull rate by DIM band, among cohort cows that could be followed 90
# days. By band because early-lactation cows leave more (one flat rate put 87%
# of DIM 0-60 cows at day 85, against 74% in the pilot).
# Two groups, not four: the 61-120 and 121-200 bands have 27 and 12 cows and
# one has no culls, too few to estimate apart.
cgrp <- function(dim0) if_else(dim0 <= 60, "0-60", "61+")
cull90 <- cohort |> filter(first_nedlame_date <= dmp - 90, dim_at_nedlame >= 5) |>
  mutate(g = cgrp(dim_at_nedlame)) |> group_by(g) |>
  summarize(n = n(), p = mean(!is.na(date_left) & date_left <= first_nedlame_date + 90), .groups = "drop")
H_CULL <- setNames(-log(1 - cull90$p) / 90, cull90$g)
cat("culled within 90 days of the alert, by DIM at alert:",
    paste0(cull90$g, " ", round(100 * cull90$p, 1), "% (n=", cull90$n, ")", collapse = "; "), "\n")
draw_exit <- function(dim0, lact) {
  n <- length(dim0); dry <- numeric(n)
  for (L in levels(lact)) {
    i <- which(lact == L); if (!length(i)) next
    Ls <- LENS[[L]]; nL <- length(Ls)
    # uniform draw among the lengths longer than her DIM + 1 (Ls is sorted)
    first <- findInterval(dim0[i] + 1, Ls) + 1
    ok <- first <= nL
    pick <- first + floor(runif(length(i)) * (nL - first + 1))
    dry[i] <- ifelse(ok, Ls[pmin(pick, nL)] - dim0[i], runif(length(i), 1, 30))
  }
  pmin(dry, rexp(n, H_CULL[cgrp(dim0)]))
}

# ---- arm-1 timing: the pilot TX arm's Kaplan-Meier time to first trim ----------
km <- function(time, ev) {                        # S(t) at the end of days 0..90
  s <- numeric(91); S <- 1
  for (dd in 0:90) {
    at_risk <- sum(time >= dd); e <- sum(ev & floor(time) == dd)
    if (at_risk > 0) S <- S * (1 - e / at_risk)
    s[dd + 1] <- S
  }
  s
}
draw_km <- function(S, n, m = 1) {                # first day with S(t)^m <= 1 - u
  thr <- (1 - runif(n))^(1 / m)
  i <- findInterval(-thr, -S, left.open = TRUE) + 1
  ifelse(i > length(S), Inf, i - 1 + runif(n))
}
tx <- q2_any |> filter(tx_group == "TX (Trim)")
KM_TX <- km(tx$days_to_event, tx$event_occurred == 1)
cat(sprintf("pilot TX (Kaplan-Meier): %.1f%% trimmed by day 7, %.1f%% by day 90\n",
            100 * (1 - KM_TX[8]), 100 * (1 - KM_TX[91])))

# ---- the farm process, from the pilot Control arm -------------------------------
ctl_all <- cohort |> filter(tx_group == "Control") |>
  mutate(fu = as.numeric(date_obs_end - first_nedlame_date), b = band(dim_at_nedlame),
         to_dryoff = as.numeric(date_dry - first_nedlame_date) - 45,
         fu_km = pmin(fu, coalesce(to_dryoff, Inf))) |>
  left_join(trim_driver |> select(id_animal, lact_number, days_to_trim, staff_flagged),
            by = c("id_animal", "lact_number")) |>
  mutate(time = if_else(is.na(days_to_trim), fu_km, pmin(days_to_trim, fu_km)),
         time = if_else(fu_km < 0, -1, time),
         ev_staff = !is.na(days_to_trim) & staff_flagged & days_to_trim <= fu_km,
         ev_rout  = !is.na(days_to_trim) & !staff_flagged & days_to_trim <= fu_km)
KM_STAFF <- map(split(ctl_all, ctl_all$b), \(x) km(x$time, x$ev_staff))
KM_ROUT  <- map(split(ctl_all, ctl_all$b), \(x) km(x$time, x$ev_rout))
# Aalen-Johansen cumulative incidence of a non-staff FIRST trim by day 60 - the
# quantity the model's arm 3 reproduces (review, issue 5)
aj60 <- function(x) {
  S <- 1; cif <- 0
  for (dd in 0:60) {
    n <- sum(x$time >= dd); if (!n) break
    es <- sum(x$ev_staff & floor(x$time) == dd); er <- sum(x$ev_rout & floor(x$time) == dd)
    cif <- cif + S * er / n; S <- S * (1 - (es + er) / n)
  }
  100 * cif
}
target <- ctl_all |> group_by(b) |> group_modify(\(x, k) tibble(n = nrow(x), pilot_AJ = aj60(x))) |> ungroup()

# ---- later alerts, for the trimming count (review, issue 4) ---------------------
# Only alerts AFTER the cow's first post-alert trim (earlier ones are re-fires of
# the same pending trim), not blocked by a trim in the prior 28 days, one per 7
# days; exposure is the unblocked days after that first trim.
trims <- ef |> filter(event %in% c("LAME", "FOOTRIM", "TRIM")) |> distinct(id_animal, trim = date_event)
tx_c <- cohort |> filter(tx_group == "TX (Trim)") |>
  inner_join(trim_driver |> filter(tx_group == "TX (Trim)") |> select(id_animal, lact_number, first_trim = trim_date),
             by = c("id_animal", "lact_number"))
alerts_after <- tx_c |> select(id_animal, first_trim, date_obs_end) |>
  inner_join(ea |> filter(Event == "NEDLAME", str_detect(Remark, "DECLINE")) |> distinct(id_animal, a = date_event),
             by = "id_animal") |>
  filter(a > first_trim, a <= date_obs_end) |>
  left_join(trims, by = "id_animal", relationship = "many-to-many") |>
  group_by(id_animal, a) |> summarize(blocked = any(!is.na(trim) & trim < a & trim >= a - 28), .groups = "drop") |>
  filter(!blocked) |> arrange(id_animal, a) |> group_by(id_animal) |>
  filter(is.na(lag(a)) | as.numeric(a - lag(a)) > 7) |> ungroup()
exposure <- tx_c |> select(id_animal, first_trim, date_obs_end) |> filter(date_obs_end > first_trim) |>
  mutate(day = map2(first_trim + 1, date_obs_end, \(a, b) seq(a, b, by = "day"))) |> unnest(day) |>
  left_join(trims, by = "id_animal", relationship = "many-to-many") |>
  group_by(id_animal, day) |> summarize(blocked = any(!is.na(trim) & trim < day & trim >= day - 28), .groups = "drop") |>
  summarize(unblocked = sum(!blocked)) |> pull(unblocked)
LAMBDA <- nrow(alerts_after) / exposure
cat(sprintf("later decline alerts after the first trim: %d over %d unblocked cow-days = %.4f per day\n",
            nrow(alerts_after), exposure, LAMBDA))

# ============================================================================
# 2. THE SIMULATION
# ============================================================================
HERD_ROUT_SD <- 0.3
ROUT_MULT <- c("pilot" = 1, "more routine (x2)" = 2, "less routine (x0.5)" = 0.5)

sim_trial <- function(N, eff_new, eff_chronic, tau_true, scenario = "pilot", herd_sd = HERD_ROUT_SD) {
  cows <- pool[sample(nrow(pool), N, replace = TRUE), ]
  herd <- sample(rep(seq_len(K), length.out = N))
  blk <- interaction(herd, cows$lact, cows$chronic, drop = TRUE)
  arm <- integer(N)
  for (g in split(seq_len(N), blk)) arm[g] <- sample(rep(1:3, length.out = length(g)))
  m_h <- exp(rnorm(K, -herd_sd^2 / 2, herd_sd)) * ROUT_MULT[[scenario]]   # mean one
  b <- band(cows$dim0)
  staff_t <- routine_t <- rep(Inf, N)
  for (lv in levels(b)) {
    i <- which(b == lv); if (!length(i)) next
    staff_t[i] <- draw_km(KM_STAFF[[lv]], length(i))
    routine_t[i] <- draw_km(KM_ROUT[[lv]], length(i), m_h[herd[i]])
  }
  farm_t <- pmin(staff_t, routine_t)
  proto <- draw_km(KM_TX, N)
  t <- case_when(arm == 1 ~ proto, arm == 2 ~ pmin(28 + proto, farm_t), TRUE ~ farm_t)
  exit <- draw_exit(cows$dim0, cows$lact)
  days <- pmin(90, exit); weeks <- pmin(13, ceiling(days / 7))   # 90 days = 13 weeks
  eff <- ifelse(cows$chronic == 1, eff_chronic, eff_new) + rnorm(K, 0, tau_true)[herd]
  gain <- eff * pmax(0, days - t) / days
  vi <- V_COW + V_RES / pmax(weeks, 1)
  X <- Xf(cows$base_kg, cows$dim0, cows$lact, cows$chronic)
  y <- drop(X %*% BETA) + gain + rnorm(N, 0, sqrt(vi))
  keep <- days >= 7                                 # a cow needs one week of milk
  list(y = y[keep], X = X[keep, ], w = 1 / vi[keep], arm = arm[keep], herd = herd[keep],
       chronic = cows$chronic[keep], dim0 = cows$dim0[keep], t = t[keep], weeks = weeks[keep],
       routine_t = routine_t[keep], staff_t = staff_t[keep], n_enrolled = N)
}

wls <- function(X, y, w) {
  f <- lm.wfit(X, y, w); stopifnot(f$rank == ncol(X))
  s2 <- sum(w * f$residuals^2) / (nrow(X) - f$rank)
  list(b = f$coefficients, V = s2 * chol2inv(qr.R(f$qr)))
}
herd_est <- function(s) {
  map_dfr(seq_len(K), function(h) {
    i <- s$herd == h; X <- s$X[i, ]; a1 <- s$arm[i] == 1; a2 <- s$arm[i] == 2; ch <- s$chronic[i]
    p <- ncol(X)
    m <- wls(cbind(X, a1, a2), s$y[i], s$w[i])
    mi <- wls(cbind(X, a1, a2, a1 * ch, a2 * ch), s$y[i], s$w[i])
    tibble(herd = h, c1 = m$b[p + 1], v1 = m$V[p + 1, p + 1],
           c12 = m$b[p + 1] - m$b[p + 2], v12 = m$V[p + 1, p + 1] + m$V[p + 2, p + 2] - 2 * m$V[p + 1, p + 2],
           cnew = mi$b[p + 1], vnew = mi$V[p + 1, p + 1],
           cint = mi$b[p + 3], vint = mi$V[p + 3, p + 3])
  })
}
pool_dl <- function(b, v) {
  w <- 1 / v; k <- length(b); m0 <- sum(w * b) / sum(w); Q <- sum(w * (b - m0)^2)
  t2 <- max(0, (Q - (k - 1)) / (sum(w) - sum(w^2) / sum(w)))
  ws <- 1 / (v + t2); est <- sum(ws * b) / sum(ws); se <- sqrt(1 / sum(ws))
  se_hk <- sqrt(sum(ws * (b - est)^2) / ((k - 1) * sum(ws)))
  tq <- qt(.975, k - 1)
  c(est = est, z = abs(est / se) > qnorm(.975), hk = abs(est / se_hk) > tq,
    lo_hk = est - tq * se_hk, hw_hk = tq * se_hk)
}
# The conventional multi-centre analysis (Gerard, 2026-09-30, replaces HK as the
# primary test): one model on all cows, arm and herd as fixed main effects, no
# arm-by-herd term, covariates common to all herds. Inference is on the effect
# in the enrolled herds. t on the residual df.
fe_est <- function(s) {
  a1 <- s$arm == 1; a2 <- s$arm == 2; ch <- s$chronic
  H <- outer(s$herd, 2:K, `==`) * 1
  X <- cbind(s$X, H); p <- ncol(X)
  m <- wls(cbind(X, a1, a2), s$y, s$w)
  mi <- wls(cbind(X, a1, a2, a1 * ch, a2 * ch), s$y, s$w)
  tq <- qt(.975, length(s$y) - p - 2)
  se1 <- sqrt(m$V[p + 1, p + 1])
  se12 <- sqrt(m$V[p + 1, p + 1] + m$V[p + 2, p + 2] - 2 * m$V[p + 1, p + 2])
  c(fe13 = abs(m$b[[p + 1]] / se1) > tq, festd13 = m$b[[p + 1]], lofe13 = m$b[[p + 1]] - tq * se1, hwfe13 = tq * se1,
    fe12 = abs((m$b[[p + 1]] - m$b[[p + 2]]) / se12) > tq,
    fenew = abs(mi$b[[p + 1]] / sqrt(mi$V[p + 1, p + 1])) > tq,
    feint = abs(mi$b[[p + 3]] / sqrt(mi$V[p + 3, p + 3])) > tq)
}
one_rep <- function(N, eff_new, eff_chronic, tau_true, scenario) {
  s <- sim_trial(N, eff_new, eff_chronic, tau_true, scenario)
  e <- herd_est(s)
  r1 <- pool_dl(e$c1, e$v1); r12 <- pool_dl(e$c12, e$v12)
  rn <- pool_dl(e$cnew, e$vnew); ri <- pool_dl(e$cint, e$vint)
  f <- fe_est(s)
  a3 <- s$arm == 3
  c(f, est13 = r1[["est"]], z13 = r1[["z"]], hk13 = r1[["hk"]], lo13 = r1[["lo_hk"]], hw13 = r1[["hw_hk"]],
    est12 = r12[["est"]], hk12 = r12[["hk"]],
    estnew = rn[["est"]], hknew = rn[["hk"]], estint = ri[["est"]], hkint = ri[["hk"]],
    kept = length(s$y) / s$n_enrolled, full13 = mean(s$weeks == 13),
    a1_wk1 = mean(s$t[s$arm == 1] <= 7), a2_early = mean(s$t[s$arm == 2] < 28),
    a3_any90 = mean(s$t[a3] < 90))
}
run <- function(N, eff_new, eff_chronic, tau_true = TAU_TRUE, scenario = "pilot", reps = REPS) {
  r <- t(replicate(reps, one_rep(N, eff_new, eff_chronic, tau_true, scenario)))
  lo <- r[, "lo13"]; lf <- r[, "lofe13"]
  tibble(N = N, eff_new = eff_new, eff_chronic = eff_chronic, scenario = scenario, reps = reps,
         !!!as.list(colMeans(r)),
         lo13_med = median(lo), lo13_p10 = unname(quantile(lo, .10)), lo13_p90 = unname(quantile(lo, .90)),
         lofe_med = median(lf), lofe_p10 = unname(quantile(lf, .10)), lofe_p90 = unname(quantile(lf, .90)))
}

# ============================================================================
# 3. CHECKS BEFORE SIZING ANYTHING
# ============================================================================
set.seed(42)

# (a) leaving milk: model v the pilot cows that could have had 90 days
obs90 <- cohort |> filter(first_nedlame_date <= milk_end - 90, dim_at_nedlame >= 5) |>
  left_join(d |> group_by(id_animal) |> summarize(last = max(day_rel), .groups = "drop"), by = "id_animal") |>
  mutate(b = band(dim_at_nedlame), complete = coalesce(last, 0) >= 85)
ex <- tibble(dim0 = pool$dim0, lact = pool$lact) |> slice_sample(n = 100000, replace = TRUE)
ex$exit <- draw_exit(ex$dim0, ex$lact)
cat("\n== CHECK (a): share of cows still milking at day 85, pilot v model ==\n")
print(obs90 |> group_by(b) |> summarize(n = n(), pilot = round(100 * mean(complete)), .groups = "drop") |>
        left_join(ex |> mutate(b = band(dim0)) |> group_by(b) |>
                    summarize(model = round(100 * mean(exit >= 85)), .groups = "drop"), by = "b"))
cat(sprintf("  all bands: pilot %.0f%% (n = %d); model on the pool's DIM mix %.0f%%\n",
            100 * mean(obs90$complete), nrow(obs90), 100 * mean(ex$exit >= 85)))

# (b) farm process: arm 3 against the pilot Control (Aalen-Johansen), herd
#     variation off so one draw of six multipliers cannot move it
v <- sim_trial(300000, 0, 0, 0, herd_sd = 0)
a3 <- v$arm == 3
cat("\n== CHECK (b): arm 3, first trim non-staff within 60 days - pilot (Aalen-Johansen) v model ==\n")
print(target |> left_join(tibble(b = band(v$dim0[a3]),
                                 r = v$routine_t[a3] <= 60 & v$routine_t[a3] < v$staff_t[a3]) |>
                            group_by(b) |> summarize(model = 100 * mean(r), .groups = "drop"), by = "b") |>
        mutate(across(c(pilot_AJ, model), \(x) round(x, 1))))
cat(sprintf("  arm 1 trimmed by day 7 %.1f%%; arm 2 before day 28 %.1f%%; arm 3 by day 90 %.1f%%\n",
            100 * mean(v$t[v$arm == 1] <= 7), 100 * mean(v$t[v$arm == 2] < 28), 100 * mean(v$t[a3] < 90)))
cat(sprintf("  cows with at least a week of milk %.1f%%; with the full 13 weeks %.1f%%\n",
            100 * length(v$y) / v$n_enrolled, 100 * mean(v$weeks == 13)))

# (c) calibrate TAU_TRUE: between-herd SD of the observed arm-1-v-3 contrast,
#     per-herd sampling variance subtracted (review, issue 6). Target 0.25 kg.
tau_obs <- function(tau_true, R = 60) {
  x <- replicate(R, { e <- herd_est(sim_trial(6 * 20000, 2.0, 2.0, tau_true)); c(var(e$c1), mean(e$v1)) })
  sqrt(max(0, mean(x[1, ]) - mean(x[2, ])))
}
tt <- c(0, 0.25, 0.5, 0.75, 1.0)
to <- map_dbl(tt, tau_obs)
cat("\n== CHECK (c): between-herd SD of the observed contrast (true effect 2.0 kg) ==\n")
for (i in seq_along(tt)) cat(sprintf("  tau on the true effect %.2f -> observed %.2f kg\n", tt[i], to[i]))
TAU_TRUE <- approx(to, tt, xout = 0.25)$y
cat(sprintf("  -> TAU_TRUE = %.2f\n", TAU_TRUE))

# (d) false-positive rate with no effect anywhere
cat("\n== CHECK (d): false-positive rate at no effect, 4,000 enrolled ==\n")
# The conventional test's null is "no effect in these herds", so its own false-
# positive rate is checked with herds identical (tau 0). At tau > 0 it answers a
# different question (the six herds' average moves with the herd draw), so the
# rate there is shown only to record what it would be for the wider population.
print(bind_rows(run(4000, 0, 0, reps = max(REPS, 2000)) |> mutate(tau = "calibrated"),
                run(4000, 0, 0, tau_true = 0, reps = max(REPS, 2000)) |> mutate(tau = "0")) |>
        select(tau, N, reps, fe13, feint, est13, z13, hk13, hkint) |>
        mutate(across(where(is.double) & !c(N, reps), \(x) round(x, 3))))
if (CHECKS_ONLY) quit(save = "no")

# ---- what the study would report at 5,000 (Gerard, 2026-09-30) -----------------
# The goal is to ESTIMATE the milk effect, so show the estimate and its 95% CI
# (Hartung-Knapp) across true effects, and how much they move between studies.
if (CI_ONLY) {
  # Also: how often the lower bound clears 0.5 and 1.0 kg. The study reports the
  # OBSERVED difference, about half the true effect, so a 0.5 kg lower bound is
  # roughly a 1 kg lower bound on the effect of trimming a cow.
  # 2026-09-30 night: conventional analysis (fe_est), at 4,000 and 5,000 - the
  # two sizes offered to Nedap.
  ci <- expand_grid(N = c(4000, 5000), eff = c(0, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0)) |> pmap_dfr(function(N, eff) {
    r <- t(replicate(REPS, one_rep(N, eff, eff, TAU_TRUE, "pilot")))
    est <- r[, "festd13"]; lo <- r[, "lofe13"]; hi <- est + r[, "hwfe13"]
    tibble(N = N, true = eff, power = mean(r[, "fe13"]), est_med = median(est), est_p10 = quantile(est, .1), est_p90 = quantile(est, .9),
           lo_med = median(lo), lo_p10 = quantile(lo, .1), lo_p90 = quantile(lo, .9),
           hi_med = median(hi), hw_med = median(r[, "hwfe13"]),
           p_lo_gt0 = mean(lo > 0), p_lo_ge05 = mean(lo >= 0.5), p_lo_ge1 = mean(lo >= 1))
  })
  cat("\n== 4,000 and 5,000 enrolled: arm 1 v 3 estimate and 95% CI, conventional analysis, kg/day ==\n")
  print(ci |> mutate(across(everything(), \(v) round(v, 2))), width = 200)
  saveRDS(ci, "output/p42_ci.rds")
  quit(save = "no")
}

# ---- the design Gerard chose (2026-09-30): 5,000 enrolled ----------------------
# Herd count by between-herd SD of the OBSERVED effect (0.25 / 0.5 / 0.75 kg,
# mapped to the true-effect scale by the calibration in check c), and new v
# chronic, all at 5,000 enrolled and a 2.0 kg true effect (1.0 kg observed).
if (HERDS_ONLY) {
  run_k <- function(k, ...) { K <<- k; on.exit(K <<- 6); run(...) }
  # Observed tau only reaches ~0.50 inside the calibrated grid, so 0.75 must be
  # extrapolated: linear on the last two grid points (observed is ~half the
  # true-scale tau throughout). The first herds run clamped it (rule = 2) and
  # gave the 0.75 row the 0.5 row's numbers.
  tau_true_for <- function(o) {
    if (o <= max(to)) return(approx(to, tt, xout = o)$y)
    n <- length(to); tt[n] + (o - to[n]) * (tt[n] - tt[n - 1]) / (to[n] - to[n - 1])
  }
  TAU_OBS <- if (length(args) >= 3) as.numeric(strsplit(args[3], ",")[[1]]) else c(0.25, 0.5, 0.75)
  tau_map <- setNames(map_dbl(TAU_OBS, tau_true_for), TAU_OBS)
  cat("\n== tau, observed -> true scale:", paste(names(tau_map), round(tau_map, 2), sep = " -> ", collapse = "; "), "\n")
  herds <- expand_grid(k = c(4, 6, 8, 10), tau_obs = TAU_OBS) |>
    pmap_dfr(\(k, tau_obs) run_k(k, 5000, 2.0, 2.0, tau_true = tau_map[[as.character(tau_obs)]]) |>
               mutate(herds = k, tau_obs = tau_obs))
  cat("\n== HERDS: power at 5,000 enrolled, true 2.0 kg (observed ~1.0), conventional (fe13) and HK ==\n")
  print(herds |> select(herds, tau_obs, fe13, hk13) |> mutate(across(c(fe13, hk13), \(v) round(100 * v))) |>
          pivot_wider(names_from = herds, values_from = c(fe13, hk13)))
  p_new <- mean(pool$chronic == 0)
  ch5 <- run(5000, 2.0 / p_new, 0)
  eq5 <- run(5000, 2.0, 2.0)
  cat("\n== 5,000 enrolled, true 2.0 kg: equal effect v benefit only in new cows ==\n")
  print(bind_rows(eq5 |> mutate(case = "equal"), ch5 |> mutate(case = "new cows only")) |>
          select(case, eff_new, eff_chronic, festd13, fe13, hwfe13, fenew, feint, hk13, hknew, hkint) |>
          mutate(across(where(is.double), \(v) round(v, 2))))
  saveRDS(list(herds = herds, ch5 = ch5, eq5 = eq5, tau_map = tau_map), "output/p42_herds.rds")
  quit(save = "no")
}

# ============================================================================
# 4. SIZING
# ============================================================================
fmt <- \(x) mutate(x, across(where(is.double) & !c(N, reps), \(v) round(v, 2)))

cat("\n== MAIN: equal effect in new and chronic cows, pilot farm practice; conventional test (fe13), HK for comparison ==\n")
main <- expand_grid(N = c(3000, 3500, 4000, 5000, 6000), eff = c(1.5, 2.0)) |>
  pmap_dfr(\(N, eff) run(N, eff, eff))
print(fmt(main) |> select(N, eff_new, festd13, fe13, hwfe13, lofe_med, hk13, z13, fe12, kept, full13), n = 50)

cat("\n== CHRONICITY: benefit only in new cows, same overall average as a 2.0 kg effect ==\n")
p_new <- mean(pool$chronic == 0)
chron <- expand_grid(N = c(4000, 5000, 7500), eff = 2.0) |> pmap_dfr(\(N, eff) run(N, eff / p_new, 0))
print(fmt(chron) |> select(N, eff_new, eff_chronic, festd13, fe13, fenew, feint, hk13, hknew, hkint))

cat("\n== FARM PRACTICE: how much routine trimming reaches arm 3 (4,000 and 5,000 enrolled, true 2.0) ==\n")
sched <- expand_grid(N = c(4000, 5000), sc = names(ROUT_MULT)) |> pmap_dfr(\(N, sc) run(N, 2.0, 2.0, scenario = sc))
print(fmt(sched) |> select(N, scenario, festd13, fe13, hk13, a3_any90))

# ---- trims from later alerts: renewal model with leaving milk --------------------
# First protocol trim at the arm's time; each trim blocks 28 days; after that,
# decline alerts arrive at LAMBDA per day and are trimmed at once; nothing after
# the cow leaves milk.
renew <- function(n, horizon, arm) {
  cows <- pool[sample(nrow(pool), n, replace = TRUE), ]
  exit <- draw_exit(cows$dim0, cows$lact); p <- draw_km(KM_TX, n)
  t1 <- if (arm == 1) p else 28 + p
  map_dbl(seq_len(n), function(i) {
    end <- min(horizon, exit[i]); tt <- t1[i]; k <- 0
    if (!is.finite(tt) || tt > end) return(0)
    repeat { tt <- tt + 28 + rexp(1, LAMBDA); if (tt > end) break; k <- k + 1 }
    k
  }) |> mean()
}
cat("\n== EXTRA TRIMS FROM LATER ALERTS (Gerard's rule), per enrolled cow ==\n")
for (h in c(180, 270)) cat(sprintf("  %d days: arm 1 %.2f, arm 2 %.2f\n", h, renew(20000, h, 1), renew(20000, h, 2)))

saveRDS(list(main = main, chron = chron, sched = sched, tau_true = TAU_TRUE), "output/p42_sim.rds")
