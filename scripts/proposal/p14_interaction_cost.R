# If Nedap wants the chronicity interaction POWERED rather than explored, what
# does it cost? Verified multipliers: 2.00x on the linear milk model (SE ratio
# exactly sqrt(2)), 1.59x on the logistic cure model (SE ratio 1.26).
suppressPackageStartupMessages(library(tidyverse))
za <- qnorm(0.975); zb <- qnorm(0.80)
var_cow <- 9.39^2 + 4.79^2 / 9
n_per_arm <- function(d, mult = 1) ceiling(mult * 2 * var_cow * (za + zb)^2 / d^2)
infl <- 1.28 * 1.09     # attrition x heterogeneity (tau = 0.25 kg, 6 herds)

cat("=== MILK, arm 1 v arm 3 ===\n")
for (d in c(0.8, 1.0, 1.2)) {
  base <- n_per_arm(d); with_i <- n_per_arm(d, 2)
  cat(sprintf("  %.1f kg contrast:\n", d))
  cat(sprintf("    main effect only : %5s/arm, %6s over 3 arms, %6s with inflation\n",
              format(base, big.mark=","), format(3*base, big.mark=","),
              format(ceiling(3*base*infl/100)*100, big.mark=",")))
  cat(sprintf("    interaction powered: %5s/arm, %6s over 3 arms, %6s with inflation\n",
              format(with_i, big.mark=","), format(3*with_i, big.mark=","),
              format(ceiling(3*with_i*infl/100)*100, big.mark=",")))
}

cat("\n=== CURE, white line and sole ulcer, +15 points ===\n")
cat("  main effect only  : about 3,000 enrolled\n")
cat(sprintf("  interaction (1.59x): about %s enrolled\n",
            format(ceiling(2952*1.59/100)*100, big.mark=",")))

cat("\n=== WHAT BINDS ===\n")
b <- ceiling(3*n_per_arm(1.0)*infl/100)*100
i <- ceiling(3*n_per_arm(1.0, 2)*infl/100)*100
cat(sprintf("  exploring the interaction : %s enrolled (milk binds)\n", format(b, big.mark=",")))
cat(sprintf("  powering the interaction  : %s enrolled (milk binds)\n", format(i, big.mark=",")))
cat(sprintf("  difference                : %s more cows, %.1fx\n",
            format(i - b, big.mark=","), i/b))
cat(sprintf("\n  at 69 alerts/week that is %.0f farm-weeks against %.0f - so about\n",
            i/69, b/69))
cat("  two years of accrual across four herds rather than one.\n")

cat("\n=== AND WHAT THE EXPLORATORY VERSION CAN STILL SAY ===\n")
cat("  At the 6,000-cow design, the interaction term is estimated with an SE\n")
cat("  sqrt(2) times the main effect's:\n")
n_arm <- 6000/3
se_main <- sqrt(2 * var_cow / n_arm)
cat(sprintf("    main effect SE      %.3f kg -> 95%% CI +/-%.2f kg\n", se_main, 1.96*se_main))
cat(sprintf("    interaction term SE %.3f kg -> 95%% CI +/-%.2f kg\n",
            se_main*sqrt(2), 1.96*se_main*sqrt(2)))
cat("\n  So a difference in treatment effect between new and chronic cows would\n")
cat("  need to exceed about", round(1.96*se_main*sqrt(2), 1),
    "kg/day to reach significance -\n  large, but the estimate and its interval are still reportable and would\n")
cat("  inform whether a future study should target one group.\n")
