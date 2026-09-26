# Builds reports/qmd_reports/pipeline_losses.xlsx - the cow-level detail behind
# the pipeline-loss section of report_nedlame_treatment_comparison_fx.qmd.
#
# This lived in a scratch directory for several rounds, which meant the workbook
# in the repo could not be rebuilt and quietly went stale against the report.
# It is a script rather than a report chunk because the workbook is for the Nedap
# conversation, not for readers of the report.
#
# The by-design verdicts come from fxn_build_pipeline_by_design() in
# functions/fxn_nedlame_analysis.R - the same function the report calls - so the
# workbook and the report cannot disagree. They previously did, by about ten
# cases, when each implemented the DSNLM rule separately.
#
# Run after step 0: Rscript scripts/step3_pipeline_losses.R

setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow); library(writexl)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
source("functions/fxn_read_milk_folder.R")

params <- list(milk_window_pre = 14, milk_window_post = 30, milk_baseline_days = 7,
               # Must track the report's params block. It was left at 21 when the
               # report moved to 28 (7264f67), which would have rebuilt the
               # workbook on a different window from the section it documents -
               # the same drift that made it stale once before.
               q4_lookback_days = 28, history_after_date = "2026-06-01",
               recent_trim_suppression_days = 28, post_trim_exclusion_days = 7,
               analysis_end_date = "2026-08-27", lmsv_valid_from = "2026-06-03")
CUT <- as.Date(params$analysis_end_date)

events_all <- read_parquet("data/intermediate_files/events_all_columns.parquet")
events_formatted <- read_parquet("data/intermediate_files/events_formatted.parquet")
animals <- read_parquet("data/intermediate_files/animals.parquet")
animal_lactations <- read_parquet("data/intermediate_files/animal_lactations.parquet")
date_max_pull <- max(events_all$date_event, na.rm = TRUE)
nedlame_start_date <- min(events_all$date_event[events_all$Event == "NEDLAME"], na.rm = TRUE)
cows_smartsight <- read_csv("data/cows_smartsight.csv", show_col_types = FALSE) |>
  transmute(id = as.character(Animal))

invisible(list2env(fxn_build_cohort(events_all, animal_lactations, animals, date_max_pull, params), environment()))
invisible(list2env(fxn_build_lame_history(events_formatted, cohort), environment()))
invisible(list2env(fxn_build_enrolled_ids(events_all, cows_smartsight), environment()))
invisible(list2env(fxn_build_q4(cohort, all_nedlame_cows, lame_data, events_formatted, events_all,
                                animal_lactations, enrolled_ids, nedlame_start_date, params), environment()))

att <- fxn_resolve_nedap_to_lactation(fxn_read_nedap_attentions(), animal_lactations)
cend <- max(att$attention_date, na.rm = TRUE)
qs <- q4 |> mutate(in_coverage = date_event <= cend)
sh <- qs |> filter(in_coverage) |> select(id_animal, lact_number, date_event, lookback_days_used) |>
  left_join(att |> select(id_animal, lact_number, attention_date), by = c("id_animal","lact_number"), relationship = "many-to-many") |>
  mutate(h = !is.na(attention_date) & attention_date < date_event & attention_date >= date_event - lookback_days_used) |>
  group_by(id_animal, lact_number, date_event) |> summarize(fired = any(h), .groups = "drop")
# Same rule as the report's lmsv-data / q4-sensor-build chunks: a day with
# LMSV > 0 inside the window means a flag was still running, so she counts as
# flagged even with no attention START in the window.
lmsv_resolved <- fxn_read_milk_folder(from = params$lmsv_valid_from, to = params$analysis_end_date) |>
  fxn_resolve_milk_to_lactation(animal_lactations, max_dim = 1000) |> filter(!is.na(lmsv))  # see report lmsv-data
sc <- qs |> filter(in_coverage) |> select(id_animal, lact_number, date_event, lookback_days_used) |>
  left_join(lmsv_resolved |> select(id_animal, lact_number, lmsv_date = milk_date, lmsv),
            by = c("id_animal","lact_number"), relationship = "many-to-many") |>
  mutate(h = !is.na(lmsv) & lmsv > 0 & lmsv_date < date_event & lmsv_date >= date_event - lookback_days_used) |>
  group_by(id_animal, lact_number, date_event) |> summarize(scored = any(h), .groups = "drop")
qs <- qs |> left_join(sh, by = c("id_animal","lact_number","date_event")) |>
  left_join(sc, by = c("id_animal","lact_number","date_event")) |>
  mutate(grp = case_when(!in_coverage ~ "outside", caught_by_nedap ~ "caught", warned_not_acted ~ "warned",
                         fired | coalesce(scored, FALSE) ~ "pipeline", TRUE ~ "truemiss"))
pl <- qs |> filter(grp == "pipeline")
cat("pipeline-loss candidates:", nrow(pl), "\n")

# ---- by-design verdicts come from the SHARED function ----
#
# The four rules (FTDAT, DSNLM, injury history, late arrival) are defined once
# in functions/fxn_nedlame_analysis.R. This script used to reimplement them,
# and the two had already drifted - DSNLM was applied here but not in the
# report, so they disagreed by about ten cases. Calling the shared function
# means the workbook and the report cannot give different answers.
q4_sensor <- qs |>
  # label must match what fxn_build_pipeline_by_design() filters on; when this
  # drifted the function silently matched nothing and returned zero for everything
  mutate(detection_group_3way = if_else(grp == "pipeline",
                                        "Flagged, No Alert Raised", "other"))
bd <- fxn_build_pipeline_by_design(q4_sensor, att, events_formatted, events_all, lame_data, lmsv_resolved)
plc <- bd$pipeline_loss_cases
cat("by design:", bd$n_pipeline_loss_by_design,
    " genuine:", bd$n_pipeline_loss_genuine, "\n")

# attention-level detail is presentation only - the verdict above is what must
# agree with the report
gate <- events_formatted |> filter(event %in% c("LAME","FOOTRIM","TRIM")) |>
  select(id_animal, lact_number, gt = date_event) |> distinct()
ned_all <- events_all |> filter(Event == "NEDLAME") |>
  transmute(id_animal, ned_date = date_event) |> distinct()

flags <- pl |> select(id_animal, lact_number, date_event, lookback_days_used) |>
  left_join(att |> select(id_animal, lact_number, attention_date, alert_type),
            by = c("id_animal","lact_number"), relationship = "many-to-many") |>
  filter(attention_date < date_event, attention_date >= date_event - lookback_days_used) |>
  left_join(gate, by = c("id_animal","lact_number"), relationship = "many-to-many") |>
  mutate(days_since_trim = if_else(!is.na(gt) & gt < attention_date, as.numeric(attention_date - gt), Inf)) |>
  group_by(id_animal, lact_number, date_event, attention_date, alert_type, lookback_days_used) |>
  summarize(days_since_last_trim = min(days_since_trim), .groups = "drop") |>
  left_join(ned_all, by = "id_animal", relationship = "many-to-many") |>
  mutate(dsnlm_win = if_else(alert_type == "LOW", 90, 7),
         prior = !is.na(ned_date) & ned_date < attention_date & ned_date >= attention_date - dsnlm_win) |>
  group_by(id_animal, lact_number, date_event, attention_date, alert_type, lookback_days_used, days_since_last_trim, dsnlm_win) |>
  summarize(dsnlm_blocked = any(prior),
            prior_alert_date = { d <- ned_date[prior]; if (length(d)) max(d) else as.Date(NA) }, .groups = "drop") |>
  mutate(ftdat_win = if_else(alert_type == "LOW", 90, 28),
         ftdat_blocked = days_since_last_trim <= ftdat_win,
         days_flag_to_lesion = as.numeric(date_event - attention_date),
         why_no_alert = case_when(
           ftdat_blocked & dsnlm_blocked ~ "by design: FTDAT and DSNLM both block",
           ftdat_blocked ~ "by design: trimmed too recently (FTDAT)",
           dsnlm_blocked ~ "by design: already alerted recently (DSNLM)",
           TRUE ~ "NOT EXPLAINED by FTDAT or DSNLM"))

# One row per case, built from the SHARED verdict rather than from the flag
# starts. Round 37 added cases flagged only through LMSV (a flag still running,
# none starting in the window); building from `flags` would silently drop them.
flag_summary <- flags |> group_by(id_animal, lact_number, date_event) |>
  summarize(n_flags = n(),
            flag_types = paste(sort(unique(alert_type)), collapse = "+"),
            first_flag = min(attention_date), last_flag = max(attention_date),
            .groups = "drop")
case <- plc |>
  select(id_animal, lact_number, date_event, reason, by_design, injury_explained,
         lmsv_days_scored, lmsv_low_days, all_dsnlm_blocked) |>
  left_join(flag_summary, by = c("id_animal","lact_number","date_event")) |>
  mutate(n_flags = coalesce(n_flags, 0L),
         flag_types = coalesce(flag_types, "none started - LOW still running (LMSV)"),
         injury_hist = coalesce(injury_explained, FALSE),
         status = reason,
         priority = if_else(by_design, 3L, 1L))

stopifnot(nrow(case) == nrow(plc), sum(!case$by_design) == bd$n_pipeline_loss_genuine)

LTC <- c("dd","footrot","wld","sole_ulcer","injury","cork","hemorrhage","sole_fracture","toe_ulcer","thin","other")
les <- lame_lesion_recent |> select(id_animal, lact_number, date_event, all_of(LTC)) |>
  pivot_longer(all_of(LTC), names_to = "lt", values_to = "h") |> filter(h == 1) |>
  group_by(id_animal, lact_number, date_event) |> summarize(lesions = paste(sort(lt), collapse = "+"), .groups = "drop")
legn <- c(LF="LeftFront", RF="RightFront", LR="LeftRear", RR="RightRear")
feet <- events_formatted |> filter(event %in% c("LAME","FOOTRIM","TRIM"), !is.na(locate_lesion), locate_lesion != "") |>
  select(id_animal, lact_number, date_event, locate_lesion) |>
  mutate(leg = str_extract_all(locate_lesion, ".{2}")) |> unnest(leg) |>
  distinct(id_animal, lact_number, date_event, leg) |> mutate(leg = unname(legn[leg])) |>
  group_by(id_animal, lact_number, date_event) |> summarize(feet = paste(sort(leg), collapse = "+"), .groups = "drop")
idmap <- events_all |> select(id_animal, id) |> distinct() |> mutate(id = as.character(id))
ever <- ned_all |> group_by(id_animal) |> summarize(n_nedlame_ever = n(), first_nedlame_ever = min(ned_date), .groups = "drop")

cases <- case |> left_join(idmap, by = "id_animal") |> left_join(les, by = c("id_animal","lact_number","date_event")) |>
  left_join(feet, by = c("id_animal","lact_number","date_event")) |>
  left_join(cohort |> select(id_animal, lact_number, tx_group), by = c("id_animal","lact_number")) |>
  left_join(ever, by = "id_animal") |>
  transmute(priority, status, cow = id, lact = lact_number, lesion_date = date_event, lesions, feet,
            n_flags, flag_types, first_flag, last_flag,
            days_last_flag_to_lesion = as.numeric(date_event - last_flag),
            lookback_days = lookback_days_used_placeholder <- NULL,
            arm = coalesce(tx_group, "not in pilot cohort"),
            n_nedlame_ever = coalesce(n_nedlame_ever, 0L), first_nedlame_ever,
            injury_history = injury_hist,
            lmsv_days_scored, lmsv_days_1_30 = lmsv_low_days) |>
  arrange(priority, desc(n_flags), desc(lesion_date))

flag_detail <- flags |> left_join(idmap, by = "id_animal") |>
  transmute(cow = id, lact = lact_number, lesion_date = date_event, flag_date = attention_date,
            flag_type = alert_type, days_flag_to_lesion,
            days_since_last_trim = if_else(is.infinite(days_since_last_trim), NA_real_, days_since_last_trim),
            ftdat_window = ftdat_win, ftdat_blocked,
            dsnlm_window = dsnlm_win, dsnlm_blocked, prior_alert_date,
            why_no_alert) |>
  arrange(cow, flag_date)

readme <- tibble::tribble(
  ~Field, ~Meaning,
  "Purpose", "Every case where the Nedap sensor flagged a cow but no NEDLAME event appeared in DairyComp, so the alert never reached the cowcard.",
  "Population", paste0(nrow(cases), " lesion cases, from the ", nrow(qs), " qualifying cases in the analysis window (to ", format(CUT), ")."),
  "priority 1 = Genuine pipeline loss", "A decline flag fired (no score gate), or the Low route was open - LMSV 1-30 with no other gate - and still no NEDLAME. The clean integration failures.",
  "priority 3 = Working as designed", "DairyComp was correctly declining to raise an alert: trimmed too recently (FTDAT), already alerted (DSNLM), upper-leg/injury history, or the score never 1-30 (LMSV gate, Low route only).",
  "An alert did arrive (priority 3)", "A NEDLAME reached DairyComp the day after the lesion. The ~5am batch stamps the load date, so a flag late on day D appears as D+1 - outside a lookback that only looks backward. The cow was still missed, but nothing was lost in transit. Added 2026-09-09 after cow 7207.",
  "LMSV", "DairyComp's copy of the Nedap score, from the daily VAS milk file. From 2026-06-03 it equals the prior day's score, and is sent only for cows under the LOW threshold (~70); otherwise 0. The go-live file (06-02) still held an older field and is not used. Round 37.",
  "flag_types = none started", "No attention started in the window, but DairyComp held a score for her in it - a LOW flag opened earlier and still running.",
  "DSNLM", "Exclusion criterion: a cow already alerted in the last N days is not re-flagged, so the cowcard does not fill with duplicate alarms. 90 days on the Low route, 7 on the decline routes. Confirmed by Gerard 2026-09-09; earlier versions of this analysis had it backwards.",
  "FTDAT", "Days since the most recent LAME diagnosis OR trim - not trims alone. 90 days on the Low route, 28 on the decline routes.",
  "Sheet: cases", "One row per lesion case, with the overall verdict.",
  "Sheet: flag_detail", "One row per individual sensor flag, showing exactly which rule blocked it - use this to see why a specific flag produced nothing.",
  "Caveat", "The Nedap export and the VAS file run at different times, so an alert or score can be overwritten between them. Only saving the files as sent would settle a disputed case."
)

f <- "reports/qmd_reports/pipeline_losses.xlsx"
write_xlsx(list(readme = readme, cases = cases, flag_detail = flag_detail), f)
cat("wrote", f, "\n\n")
cat("=== triage ===\n"); print(cases |> count(priority, status) |> as.data.frame())
cat("\n=== what changed now DSNLM is treated as an exclusion ===\n")
cat("cases where every flag was DSNLM-blocked:", sum(case$all_dsnlm_blocked), "\n")
cat("individual flags blocked by DSNLM:", sum(flags$dsnlm_blocked), "of", nrow(flags), "\n")
