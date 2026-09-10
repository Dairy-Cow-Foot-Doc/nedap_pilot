# What the 6,000-cow design detects on each outcome, at 80% power - the
# "with this sample size we can find X" statement.
suppressPackageStartupMessages(library(tidyverse))
za <- qnorm(0.975); zb <- qnorm(0.80)
N <- 6000; per_arm <- N/3
P_LESION <- 0.35; P_WLDSU <- 0.183; P_RE <- 0.95

# continuous: smallest detectable difference at given n per arm
mdd_cont <- function(n, var) sqrt(2*var*(za+zb)^2/n)
var_cow <- 9.39^2 + 4.79^2/9
# binary: smallest detectable difference, solved numerically
mdd_prop <- function(n, p1) {
  f <- function(d) {
    p2 <- p1 - d; pb <- (p1+p2)/2
    n - (za*sqrt(2*pb*(1-pb)) + zb*sqrt(p1*(1-p1)+p2*(1-p2)))^2/d^2
  }
  uniroot(f, c(0.001, p1*0.95))$root
}
cat("=== WHAT 6,000 ENROLLED DETECTS AT 80% POWER ===\n")
cat("   (arm 1 v arm 3;", format(per_arm, big.mark=","), "cows per arm)\n\n")
eff <- per_arm / 1.28 / 1.05     # after attrition and heterogeneity
cat(sprintf("  MILK          %.2f kg/day observed contrast\n", mdd_cont(eff, var_cow)))
n_les <- per_arm * P_LESION
cat(sprintf("  RECURRENCE    %.1f points on a 48.7%% baseline (%.0f lame cows/arm)\n",
            100*mdd_prop(n_les, 0.487), n_les))
n_cure <- per_arm * P_WLDSU * P_RE
cat(sprintf("  CURE WLD/SU   %.1f points on a 49.3%% baseline (%.0f assessed/arm)\n",
            100*mdd_prop(n_cure, 0.493), n_cure))
n_do <- per_arm * 0.66
cat(sprintf("  DRY-OFF PREV  %.1f points (%.0f cows/arm after the 90-day rule)\n",
            100*mdd_prop(n_do, 0.30), n_do))
cat(sprintf("  CULLING       %.1f points on a 52.3%% baseline (%.0f lame cows/arm)\n",
            100*mdd_prop(n_les, 0.523), n_les))
cat("\n  Culling is the one the study cannot resolve at the level the economics\n")
cat("  needs (about 1 point); everything else is comfortably within reach.\n")
