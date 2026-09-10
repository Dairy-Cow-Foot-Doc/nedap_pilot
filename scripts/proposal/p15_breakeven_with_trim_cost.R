# The Shiny app computes milk needed per LAME cow to break even, from herd size,
# annual first-lesion incidence, camera cost/cow/month and a benefit window.
# That is the right framework. The point below is not a different one - it is a
# missing term in its COST input.
#
# Acting on alerts means trimming more cows. The pilot measures how many more,
# and that cost lands on the same denominator the app already uses.
suppressPackageStartupMessages(library(tidyverse))

INCID   <- 0.271     # annual first-lesion incidence (new cases per cow-year)
P_ALERT <- 0.62      # share of cows alerted at least once per lactation
LACT_YR <- 1.05      # lactations per cow-year
EXTRA   <- 0.406     # extra trims per alerted cow (90.4% vs 49.8%)
IOFC    <- 0.25

cat("=== EXTRA TRIMS, expressed PER LAME COW (the app's denominator) ===\n")
alerts_per_cow_year <- P_ALERT * LACT_YR
extra_trims_per_cow_year <- EXTRA * alerts_per_cow_year
extra_per_lame <- extra_trims_per_cow_year / INCID
cat(sprintf("  alerts per cow-year            : %.3f\n", alerts_per_cow_year))
cat(sprintf("  extra trims per cow-year       : %.3f\n", extra_trims_per_cow_year))
cat(sprintf("  lame cows per cow-year         : %.3f\n", INCID))
cat(sprintf("  EXTRA TRIMS PER LAME COW       : %.2f\n\n", extra_per_lame))

cat("=== WHAT THAT DOES TO THE APP'S BREAK-EVEN ===\n")
cat("  app cost per lame cow  = cost/cow/month x 12 / incidence\n")
cat("  PLUS                   = extra trims per lame cow x cost per trim\n\n")
g <- expand_grid(cost_month = c(0.65, 0.80), trim = c(0, 8, 12, 18), days = c(60, 90)) |>
  mutate(cam_per_lame  = cost_month * 12 / INCID,
         trim_per_lame = extra_per_lame * trim,
         total_per_lame = cam_per_lame + trim_per_lame,
         breakeven_kg = round(total_per_lame / IOFC / days, 2))
for (d in c(60, 90)) {
  cat("  ", d, "day window:\n")
  print(g |> filter(days == d) |>
          transmute(`$/cow/month` = cost_month, `trim $` = trim,
                    `cost/lame cow` = round(total_per_lame, 2),
                    `break-even kg/day` = breakeven_kg) |> as.data.frame())
  cat("\n")
}
cat("  trim $0 is the app as it stands. The rows below it are what the same\n")
cat("  break-even becomes once the extra trimming is paid for.\n\n")
b0 <- g |> filter(cost_month == 0.65, trim == 0, days == 60) |> pull(breakeven_kg)
b12 <- g |> filter(cost_month == 0.65, trim == 12, days == 60) |> pull(breakeven_kg)
cat(sprintf("  at $0.65/cow/month over 60 days: %.2f -> %.2f kg/day, a %.0f%% increase\n",
            b0, b12, 100*(b12/b0 - 1)))
cat("\n=== and where the pilot's effect sits against it ===\n")
for (mk in c(1.05, 1.5)) {
  r <- g |> filter(trim == 12) |>
    mutate(covers = if_else(mk >= breakeven_kg, "COVERS", "short"))
  cat(sprintf("  milk %.2f kg/day:\n", mk))
  print(r |> transmute(`$/cow/mo` = cost_month, days,
                       `break-even` = breakeven_kg, verdict = covers) |> as.data.frame())
}
