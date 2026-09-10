# Six herds across three regions, or four as a minimum. What does herd count buy,
# and what does each herd have to supply?
suppressPackageStartupMessages(library(tidyverse))
za <- qnorm(0.975); zb <- qnorm(0.80)
var_cow <- 9.39^2 + 4.79^2 / 9

# Var(pooled effect) = sigma^2/n + tau^2/k
n_het <- function(d, tau, k) {
  rhs <- d^2 / (za + zb)^2 - tau^2 / k
  if (rhs <= 0) return(NA_real_)
  ceiling(2 * var_cow / rhs)      # per arm
}
base <- n_het(1.0, 0, 1)

cat("=== HETEROGENEITY INFLATION BY HERD COUNT, 1.0 kg contrast ===\n")
cat("   (tau = between-herd SD of the treatment effect)\n\n")
tab <- expand_grid(k = c(3, 4, 6, 10), tau = c(0.25, 0.50, 0.75, 1.00)) |>
  rowwise() |>
  mutate(n = n_het(1.0, tau, k),
         mult = if (is.na(n)) NA_real_ else round(n / base, 2)) |>
  ungroup()
print(tab |> select(k, tau, mult) |>
        pivot_wider(names_from = k, values_from = mult, names_prefix = "herds_") |>
        as.data.frame())
cat("\n  NA = tau alone exceeds the target precision; no sample size suffices.\n")

cat("\n=== WHY GEOGRAPHIC SPREAD CUTS BOTH WAYS ===\n")
cat("  Herds in NY, SD/KS and the West Coast differ in housing, flooring,\n")
cat("  climate and trimming practice - which RAISES tau, the thing herd count\n")
cat("  protects against. Six herds is the right response to that, not an\n")
cat("  argument against the spread:\n\n")
for (tau in c(0.5, 0.75, 1.0)) {
  m4 <- n_het(1.0, tau, 4) / base; m6 <- n_het(1.0, tau, 6) / base
  cat(sprintf("    tau %.2f: 4 herds x%.2f, 6 herds x%.2f  (6 herds saves %.0f%%)\n",
              tau, m4, m6, 100*(1 - m6/m4)))
}

cat("\n=== WHAT EACH HERD SUPPLIES ===\n")
for (k in c(4, 6)) {
  for (N in c(5800, 6000)) {
    per <- ceiling(N / k)
    cat(sprintf("  %d herds, %s enrolled: %s alerted cows per herd\n",
                k, format(N, big.mark=","), format(per, big.mark=",")))
  }
}
cat("\n  At the pilot farm's rate - 69 alerts/week from ~3,400 cows, so about\n")
cat("  0.020 alerts per cow per week - the accrual time per herd is:\n\n")
rate_per_cow_wk <- 69 / 3400
for (hs in c(1000, 2000, 3400)) {
  for (k in c(4, 6)) {
    per <- 6000 / k
    wks <- per / (hs * rate_per_cow_wk)
    cat(sprintf("    %s-cow herd, %d herds: %.0f cows each -> %.0f weeks of accrual\n",
                format(hs, big.mark=","), k, per, wks))
  }
}
cat("\n  So with 6 herds even a 1,000-cow farm accrues its share in about a year;\n")
cat("  larger herds finish much sooner and the binding constraint becomes the\n")
cat("  365-day follow-up rather than enrolment.\n")
