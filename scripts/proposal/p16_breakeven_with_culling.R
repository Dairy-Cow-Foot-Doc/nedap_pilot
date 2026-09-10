# Extend the calculator's model with the two terms it does not have:
# extra trimming (a cost) and avoided culling (a benefit).
#
# The app's model, from app.R:
#   iofc      = milk_price - feed_cost/conv_factor      = 0.37 - 0.29/2.5 = 0.254
#   rev_req   = camera_cost_mo * herd * 12 / lame_cows
#   daily_vol = rev_req / iofc / days
suppressPackageStartupMessages(library(tidyverse))

IOFC   <- 0.37 - 0.29 / 2.5      # app defaults, metric
INCID  <- 0.271                  # measured new-case incidence
EXTRA_TRIMS_PER_LAME <- 0.97     # from the pilot
cat("IOFC from the app's defaults: $", round(IOFC, 3), "/kg\n\n", sep = "")

be <- function(cost_mo, days, trim_cost = 0, cull_saved_per_lame = 0,
               net_cull_cost = 1500, incid = INCID, iofc = IOFC) {
  cam_per_lame  <- cost_mo * 12 / incid
  trim_per_lame <- EXTRA_TRIMS_PER_LAME * trim_cost
  cull_credit   <- cull_saved_per_lame * net_cull_cost
  net_needed    <- cam_per_lame + trim_per_lame - cull_credit
  list(cost = cam_per_lame + trim_per_lame, net = net_needed,
       kg_day = net_needed / iofc / days)
}

cat("=== 1. COST SIDE with trimming at Gerard's $15-20 ===\n")
g <- expand_grid(cost_mo = c(0.65, 0.80), trim = c(0, 15, 20), days = c(60, 90)) |>
  rowwise() |>
  mutate(r = list(be(cost_mo, days, trim)),
         cost_per_lame = round(r$cost, 2), kg_day = round(r$kg_day, 2)) |>
  ungroup() |> select(-r)
for (d in c(60, 90)) {
  cat("  ", d, "days:\n")
  print(g |> filter(days == d) |> select(cost_mo, trim, cost_per_lame, kg_day) |> as.data.frame())
}

cat("\n=== 2. THE CULLING TERM ===\n")
cat("  net cost of a cull = replacement - cull value\n")
for (rep_ in c(2500, 3500)) for (cv in c(1200, 1500)) {
  cat(sprintf("    replacement $%d, cull value $%d -> net $%d\n", rep_, cv, rep_ - cv))
}
cat("\n  Culls avoided PER LAME COW needed to close the gap, at $20/trim:\n\n")
for (cost_mo in c(0.65, 0.80)) for (days in c(60, 90)) {
  need <- be(cost_mo, days, 20)$cost
  cat(sprintf("  $%.2f/cow/mo, %dd window: $%.2f per lame cow to recover\n",
              cost_mo, days, need))
  for (ncc in c(1000, 1500, 2300)) {
    culls <- need / ncc
    cat(sprintf("      at $%d net per cull: %.4f culls/lame cow = %.1f percentage points\n",
                ncc, culls, 100*culls))
  }
  cat("\n")
}

cat("=== 3. WHAT MILK AND CULLING TOGETHER LOOK LIKE ===\n")
cat("  Assuming the pilot's milk effect and a range of culling reductions.\n")
cat("  Positive net = the system pays.\n\n")
for (mk in c(1.05, 1.5)) {
  cat(sprintf("  milk %.2f kg/day:\n", mk))
  res <- expand_grid(cost_mo = c(0.65, 0.80), days = c(60, 90),
                     cull_pts = c(0, 1, 2, 3, 5)) |>
    rowwise() |>
    mutate(cost = be(cost_mo, days, 20)$cost,
           milk_val = mk * days * IOFC,
           cull_val = cull_pts/100 * 1500,
           net = round(milk_val + cull_val - cost, 2)) |>
    ungroup()
  print(res |> select(cost_mo, days, cull_pts, milk_val, cull_val, cost, net) |>
          mutate(across(c(milk_val, cost), ~round(.x, 2))) |> as.data.frame())
  cat("\n")
}
