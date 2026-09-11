# Gerard wants the farm's trim list captured on trim day.
#
# The argument for it is that a trim list records INTENT, while a trim event
# records EXECUTION - and the pilot can only see the second. A cow put on the
# list and not trimmed looks identical to a cow nobody ever noticed, which are
# completely different failures.
#
# CHKLAME is the closest thing the pilot has to a listing event: staff recording
# that they think a cow is lame. How often does a CHKLAME NOT lead to a trim?
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})

ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")

TRIMS <- c("LAME", "FOOTRIM", "TRIM")     # exact, never grepl - see lessons-learned

chk <- ea |>
  filter(Event == "CHKLAME", !is.na(date_event)) |>
  distinct(id_animal, chk_date = date_event)
trims <- ea |>
  filter(Event %in% TRIMS, !is.na(date_event)) |>
  distinct(id_animal, trim_date = date_event)

cat("distinct CHKLAME cow-days:", nrow(chk), " cows:", n_distinct(chk$id_animal), "\n")
cat("distinct trim cow-days   :", nrow(trims), "\n\n")

# how long after a staff check does a trim follow, if ever?
j <- chk |>
  left_join(trims, by = "id_animal", relationship = "many-to-many") |>
  mutate(gap = as.numeric(trim_date - chk_date)) |>
  filter(is.na(gap) | gap >= 0) |>
  group_by(id_animal, chk_date) |>
  summarize(first_gap = suppressWarnings(min(gap, na.rm = TRUE)), .groups = "drop") |>
  mutate(first_gap = ifelse(is.finite(first_gap), first_gap, NA_real_))

cat("=== does a staff lameness check lead to a trim? ===\n")
for (w in c(1, 3, 7, 14, 30, 60)) {
  n <- sum(!is.na(j$first_gap) & j$first_gap <= w)
  cat(sprintf("  trimmed within %2d days : %5d of %d  (%.1f%%)\n",
              w, n, nrow(j), 100 * n / nrow(j)))
}
never <- sum(is.na(j$first_gap))
cat(sprintf("  NEVER trimmed after    : %5d of %d  (%.1f%%)\n",
            never, nrow(j), 100 * never / nrow(j)))
cat(sprintf("\n  median days to trim when it happens: %s\n",
            median(j$first_gap, na.rm = TRUE)))

cat("\n=== what this actually shows, which is NOT what I expected ===\n")
same_day <- sum(!is.na(j$first_gap) & j$first_gap <= 1)
cat(sprintf("  %.1f%% of staff checks are followed by a trim within a day, median gap 1 day.\n",
            100 * same_day / nrow(j)))
cat("\n  So CHKLAME at this farm is NOT a trim list. It is recorded essentially AT\n")
cat("  the trim - it documents a trim that happened, not a cow who was scheduled.\n")
cat("  The pilot therefore has NO prospective record of intent at all.\n")
cat("\n  That is the argument for capturing the list, not against it: the quantity\n")
cat("  we cannot measure here - how often a cow meant to be trimmed was not - is\n")
cat("  exactly what a trim list would record. The 3.4% that did not convert\n")
cat("  within two weeks is a floor on a number the pilot cannot see, not an\n")
cat("  estimate of it.\n")
cat("\n  In a trial it matters because compliance is an outcome: 'not trimmed within\n")
cat("  a week' means one thing if the farm never listed her and something else if\n")
cat("  she was listed and missed in the chute.\n")
