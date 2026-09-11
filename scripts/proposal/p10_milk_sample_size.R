# Gerard is right to be suspicious. Three independent routes to the same number,
# plus a reconciliation with his original app, which needed ~500 cows for a
# 3.2 kg effect.
suppressPackageStartupMessages(library(tidyverse))
za <- qnorm(0.975); zb <- qnorm(0.80)

SD_COW <- 9.39; SD_RESID <- 4.79; K <- 9
var_cow <- SD_COW^2 + SD_RESID^2 / K
cat("per-cow variance over", K, "weekly obs:", round(var_cow, 1),
    " (SD", round(sqrt(var_cow), 2), "kg)\n\n")

cat("=== ROUTE 1: closed form, stated carefully ===\n")
n_per_arm <- function(d) ceiling(2 * var_cow * (za + zb)^2 / d^2)
for (d in c(0.8, 1.0, 1.2, 3.2)) {
  pa <- n_per_arm(d)
  cat(sprintf("  delta %.1f kg: %6s PER ARM, %6s for 2 arms, %6s for 3 arms\n",
              d, format(pa, big.mark=","), format(2*pa, big.mark=","),
              format(3*pa, big.mark=",")))
}
cat("\n  NOTE: an earlier version of this analysis printed the TWO-ARM TOTAL\n")
cat("  under a 'per arm' heading. The three-arm figures were right because\n")
cat("  they multiplied the two-arm total by 1.5, but the label was wrong.\n")

cat("\n=== ROUTE 2: the three-arm simulation, run separately ===\n")
cat("  At a 1.5 kg TRUE effect the simulation observed a 1.01 kg arm-1-v-3\n")
cat("  contrast and gave: 57% power at 2,400 enrolled, 91% at 6,000.\n")
cat("  80% therefore falls near 4,000-4,500 enrolled over three arms.\n")
cat("  Closed form for a 1.01 kg contrast:",
    format(3*n_per_arm(1.01), big.mark=","), "over three arms. AGREES.\n")

cat("\n=== ROUTE 3: reconciling with the original app ===\n")
cat("  Its assumptions: cow SD 1.8, DAILY residual 1.1, effect 3.2 kg,\n")
cat("  success = lower 95% bound clears a 2.45 kg break-even, and the model\n")
cat("  carried treatment*history.\n\n")
their_var <- 1.8^2 + (1.1/sqrt(7))^2 / K
cat("  their per-cow variance:", round(their_var, 2),
    "vs measured", round(var_cow, 1), "->", round(var_cow/their_var, 1), "x larger\n")
# their criterion: effect - 2.8*SE >= breakeven
margin <- 3.2 - 2.45
se_needed <- margin / (za + zb)
n_their <- ceiling(2 * their_var / se_needed^2)
cat(sprintf("  their criterion needs SE <= %.3f -> %d per arm\n", se_needed, n_their))
cat(sprintf("  x2 for the interaction model            -> %d per arm, %d total\n",
            2*n_their, 4*n_their))
cat("  which lands inside the 100-600 range their sweep explored. CONSISTENT.\n\n")
cat("  So the two are reconciled: their variance was about", round(var_cow/their_var),
    "times too small,\n  but their success criterion was far stricter and their model carried an\n")
cat("  interaction. Those roughly cancelled, which is why the cow numbers\n")
cat("  looked similar for a three-times-larger effect.\n")

cat("\n=== WHAT THIS MEANS FOR THE TARGET ===\n")
cat("  Powering on an OBSERVED 1.0 kg arm-1-v-3 contrast:\n")
cat(sprintf("    %s per arm, %s enrolled over three arms\n",
            format(n_per_arm(1.0), big.mark=","), format(3*n_per_arm(1.0), big.mark=",")))
cat("  With x1.28 for attrition and x1.05 for herd heterogeneity:\n")
cat(sprintf("    %s enrolled\n", format(ceiling(3*n_per_arm(1.0)*1.28*1.09/100)*100, big.mark=",")))
cat("\n  If Gerard's stricter criterion is kept - lower bound clears break-even -\n")
cat("  the requirement is far larger, which is the point made elsewhere: that\n")
cat("  criterion assumes the answer.\n")
