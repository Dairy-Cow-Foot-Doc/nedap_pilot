# Baselines for the shorter design (2026-09-26 review, section A and fix B1).
#
#  1. Recurrence within 180 and 365 days of a first lesion (14+ days later).
#     The draft quotes 48.7% at 365 with no committed script behind it; this
#     rebuilds it and adds 180.
#  2. Culling after the camera flag, for ALL flagged cows - not only those found
#     lame. Culling in the draft was sized on lesion cows, but whether a lesion
#     is FOUND depends on the arm (ascertainment), so that subset is not a
#     randomised comparison. All enrolled cows is.
#     Source: cows flagged before go-live (2025-08-25 to 2026-06-01). No alert
#     could reach DairyComp then, so these cows were left to farm practice -
#     the arm-3 condition - and many now have a year of follow-up.
#
# Run from the project root: Rscript scripts/proposal/p39_outcome_baselines_180d.R
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
params <- list(history_after_date = "2026-06-01", recent_trim_suppression_days = 28,
               post_trim_exclusion_days = 7, analysis_end_date = "2026-08-27")
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
ef <- read_parquet("data/intermediate_files/events_formatted.parquet")
an <- read_parquet("data/intermediate_files/animals.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")
ev_end <- max(ea$date_event, na.rm = TRUE)
GOLIVE <- min(ea$date_event[ea$Event == "NEDLAME"], na.rm = TRUE)
cat("events end", format(ev_end), " go-live", format(GOLIVE), "\n")

# ---- 1. recurrence --------------------------------------------------------
# Lesion coding from the shared builder, so it matches the report exactly
# (this farm codes routine trims "NONE" in the remark field).
invisible(list2env(fxn_build_cohort(ea, al, an, ev_end, params), environment()))
invisible(list2env(fxn_build_lame_history(ef, cohort), environment()))
les <- lame_data |> filter(trimonly == 0) |> distinct(id_animal, lact_number, les_date = date_event)
first <- les |> group_by(id_animal, lact_number) |> summarize(first_les = min(les_date), .groups = "drop")
rec <- first |> left_join(les, by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
  mutate(gap = as.numeric(les_date - first_les)) |>
  group_by(id_animal, lact_number, first_les) |>
  summarize(next_gap = suppressWarnings(min(gap[gap >= 14])), .groups = "drop")
cat("\n== RECURRENCE of a first lesion (next lesion 14+ days later, same lactation) ==\n")
for (w in c(180, 365)) {
  r <- rec |> filter(first_les <= ev_end - w)
  cat(sprintf("  within %3d days: %.1f%%  (n = %s first lesions with %d days of follow-up)\n",
              w, 100 * mean(is.finite(r$next_gap) & r$next_gap <= w), format(nrow(r), big.mark = ","), w))
}

# ---- 2. culling after the camera flag, all flagged cows ----------------------
att <- fxn_resolve_nedap_to_lactation(fxn_read_nedap_attentions(), al)
left <- ea |> filter(Event %in% c("SOLD", "DIED")) |>
  group_by(id_animal) |> summarize(left_date = min(date_event), .groups = "drop")
# First DECLINE flag per lactation before go-live, at DIM 5+ - the routes that
# produced 97% of pilot alerts, and the study's enrolment floor.
flag1 <- att |> filter(attention_date < GOLIVE, alert_type != "LOW", dim >= 5) |>
  group_by(id_animal, lact_number) |> summarize(flag = min(attention_date), .groups = "drop") |>
  left_join(left, by = "id_animal") |>
  left_join(les |> rename(fl = les_date), by = c("id_animal", "lact_number"), relationship = "many-to-many") |>
  group_by(id_animal, lact_number, flag, left_date) |>
  summarize(lesion_after = any(!is.na(fl) & fl >= flag & fl <= flag + 60), .groups = "drop")
cat("\n== CULLING after the first pre-go-live DECLINE flag (farm practice, no alert) ==\n")
for (w in c(180, 365)) {
  f <- flag1 |> filter(flag <= ev_end - w) |>
    mutate(culled = !is.na(left_date) & left_date >= flag & left_date <= flag + w)
  cat(sprintf("  within %3d days: all flagged %.1f%% (n = %s) | lesion found within 60 d %.1f%% (n = %s) | %.0f%% had a lesion found\n",
              w, 100 * mean(f$culled), format(nrow(f), big.mark = ","),
              100 * mean(f$culled[f$lesion_after]), format(sum(f$lesion_after), big.mark = ","),
              100 * mean(f$lesion_after)))
}

# ---- 1b. recurrence counted across a calving (cow-level) ----------------------
# The draft's 48.7% has no committed script. Test whether it is this definition:
# the first lesion of a lactation, then any lesion 14+ days later, in any lactation.
recc <- first |> left_join(les |> select(id_animal, les_date), by = "id_animal", relationship = "many-to-many") |>
  mutate(gap = as.numeric(les_date - first_les)) |>
  group_by(id_animal, lact_number, first_les) |>
  summarize(next_gap = suppressWarnings(min(gap[gap >= 14])), .groups = "drop")
cat("\n== RECURRENCE, cow-level (any lactation) ==\n")
for (w in c(180, 365)) {
  r <- recc |> filter(first_les <= ev_end - w)
  cat(sprintf("  within %3d days: %.1f%%  (n = %s)\n", w,
              100 * mean(is.finite(r$next_gap) & r$next_gap <= w), format(nrow(r), big.mark = ",")))
}
