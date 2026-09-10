# Enrol at FRESHENING instead of at the alert?
#
# Cleaner: randomisation precedes the alert, timing is anchored to a fixed point,
# dry-off becomes a fixed endpoint, and the pre-alert baseline is complete.
# Costly: most enrolled cows never get an alert, so the arms only differ among
# the alerted subset. This quantifies the multiplier.
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(lubridate)})
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")

ned <- ea |> filter(Event == "NEDLAME") |>
  transmute(id_animal, ned_date = date_event) |> distinct()
go_live <- min(ned$ned_date, na.rm = TRUE)
cover_end <- max(ea$date_event, na.rm = TRUE)
cat("NEDLAME live from", format(go_live), "to", format(cover_end),
    sprintf("(%d days)\n\n", as.numeric(cover_end - go_live)))

# lactations that were ENTIRELY inside the NEDLAME period, so a cow had the
# whole lactation exposed to the camera
lac <- al |>
  filter(!is.na(date_fresh), date_fresh >= go_live, date_fresh <= cover_end) |>
  mutate(lac_end = pmin(coalesce(date_dry, cover_end), cover_end),
         days_exposed = as.numeric(lac_end - date_fresh)) |>
  filter(days_exposed > 0)

hit <- lac |>
  left_join(ned, by = "id_animal", relationship = "many-to-many") |>
  mutate(in_lac = !is.na(ned_date) & ned_date >= date_fresh & ned_date <= lac_end) |>
  group_by(id_animal, lact_number, date_fresh, days_exposed) |>
  summarize(alerted = any(in_lac), .groups = "drop")

cat("=== ALERT RATE PER LACTATION (partial follow-up, so a FLOOR) ===\n")
cat("  lactations starting after go-live:", nrow(hit), "\n")
cat("  median days of exposure so far:", median(hit$days_exposed), "\n")
cat("  alerted at least once:", sum(hit$alerted),
    sprintf("(%.1f%%)\n", 100*mean(hit$alerted)))

cat("\n  by how much of the lactation we have observed:\n")
print(hit |> mutate(band = cut(days_exposed, c(0, 30, 60, 90, Inf),
                               labels = c("<=30d", "31-60", "61-90", ">90"))) |>
        group_by(band) |>
        summarize(lactations = n(), alerted = sum(alerted),
                  pct = round(100*mean(alerted), 1), .groups = "drop") |> as.data.frame())

# rate per exposed day, extrapolated to a full 305-day lactation
rate <- sum(hit$alerted) / sum(hit$days_exposed)
p305 <- 1 - exp(-rate * 305)
cat(sprintf("\n  alert hazard: %.5f per cow-day\n", rate))
cat(sprintf("  implied share alerted over a FULL 305-day lactation: %.0f%%\n", 100*p305))

cat("\n=== WHAT ENROLLING AT FRESHENING COSTS ===\n")
TARGET <- 4300   # alerted cows needed across three arms
for (p in c(round(p305, 2), 0.5, 0.6, 0.7)) {
  cat(sprintf("  if %.0f%% of freshenings get an alert: enrol %s cows to reach %s alerted\n",
              100*p, format(ceiling(TARGET/p), big.mark=","), format(TARGET, big.mark=",")))
}

cat("\n=== DURATION ===\n")
cat("  enrol at ALERT   : accrual only. 4,300 alerts at ~69/week = 62 farm-weeks.\n")
cat("                     3-4 herds x 1 year. Follow-up runs past the end for\n")
cat("                     late enrollees.\n")
cat(sprintf("  enrol at FRESHENING: %s freshenings needed. A 3,400-cow herd freshens\n",
            format(ceiling(TARGET/p305), big.mark=",")))
fresh_per_wk <- 3400 / 52 * 1.05   # ~1.05 lactations per cow-year
cat(sprintf("                     about %.0f cows/week, so %.0f farm-weeks of accrual,\n",
            fresh_per_wk, ceiling(TARGET/p305) / fresh_per_wk))
cat("                     PLUS a full lactation of follow-up on the last cow in.\n")
