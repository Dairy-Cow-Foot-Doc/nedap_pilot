setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(arrow)})
source("functions/fxn_read_nedap_attentions.R"); source("functions/fxn_load_os_fxns.R")
suppressMessages(fxn_load_os_fxns()); source("functions/fxn_code_lesions.R")
source("functions/fxn_collapse_lesions.R"); source("functions/fxn_nedlame_analysis.R")
pp <- list(milk_window_pre = 14, milk_window_post = 30, milk_baseline_days = 7,
           q4_lookback_days = 21, history_after_date = "2026-06-01",
           recent_trim_suppression_days = 28, post_trim_exclusion_days = 7,
           analysis_end_date = "2026-08-27")
ea <- read_parquet("data/intermediate_files/events_all_columns.parquet")
ef <- read_parquet("data/intermediate_files/events_formatted.parquet")
an <- read_parquet("data/intermediate_files/animals.parquet")
al <- read_parquet("data/intermediate_files/animal_lactations.parquet")
invisible(list2env(fxn_build_cohort(ea, al, an, max(ea$date_event, na.rm = TRUE), pp), environment()))
invisible(list2env(fxn_build_lame_history(ef, cohort), environment()))
cover_end <- max(ef$date_event, na.rm = TRUE)

lc <- intersect(c("dd","footrot","wld","sole_ulcer","other","hemorrhage","thin",
                  "toe_ulcer","injury"), names(lame_data))
vis <- lame_data |> filter(event %in% c("LAME","FOOTRIM","TRIM")) |>
  select(id_animal, date_event, lesion, trimonly, all_of(lc)) |> distinct() |>
  mutate(found = coalesce(lesion,0)==1 & coalesce(trimonly,0)!=1)

# for each lesion type: index = first visit with that lesion; follow-up = next
# visit within 60 d; among the follow-ups that FOUND a lesion, how long a gap?
gaps <- map_dfr(lc, function(lt) {
  idx <- vis |> filter(found, .data[[lt]] == 1) |>
    group_by(id_animal) |> slice_min(date_event, n=1, with_ties=FALSE) |> ungroup() |>
    transmute(id_animal, idx_date = date_event)
  if (!nrow(idx)) return(NULL)
  idx |>
    left_join(vis |> transmute(id_animal, fu_date = date_event, found,
                               same_type = coalesce(.data[[lt]], 0) == 1),
              by = "id_animal", relationship = "many-to-many") |>
    filter(fu_date > idx_date, fu_date <= idx_date + 60) |>
    group_by(id_animal, idx_date) |> slice_min(fu_date, n=1, with_ties=FALSE) |> ungroup() |>
    filter(found) |>
    transmute(lesion_type = lt, gap = as.numeric(fu_date - idx_date), same_type)
})

cat("=== 'NOT CURED' FOLLOW-UPS: how soon, and is it the SAME lesion type? ===\n")
cat("Gerard: for lesions other than foot rot the trimmer diagnoses and treats at\n")
cat("the same visit, so an early return is a real treatment failure.\n")
cat("If so, the short-gap clustering should be specific to foot rot.\n\n")
s <- gaps |> group_by(lesion_type) |>
  summarize(n = n(),
            pct_within_7d  = round(100*mean(gap <= 7)),
            pct_within_14d = round(100*mean(gap <= 14)),
            median_gap = median(gap),
            pct_same_type_le7 = round(100*mean(gap <= 7 & same_type)),
            .groups = "drop") |>
  arrange(desc(pct_within_7d))
print(as.data.frame(s))

cat("\n=== what excluding follow-ups within 14 days would do to each cure rate ===\n")
eff <- map_dfr(lc, function(lt) {
  idx <- vis |> filter(found, .data[[lt]] == 1) |>
    group_by(id_animal) |> slice_min(date_event, n=1, with_ties=FALSE) |> ungroup() |>
    transmute(id_animal, idx_date = date_event) |>
    filter(idx_date <= cover_end - 60)
  if (!nrow(idx)) return(NULL)
  fu <- idx |>
    left_join(vis |> transmute(id_animal, fu_date = date_event, found),
              by = "id_animal", relationship = "many-to-many") |>
    filter(fu_date > idx_date, fu_date <= idx_date + 60) |>
    group_by(id_animal, idx_date) |> slice_min(fu_date, n=1, with_ties=FALSE) |> ungroup() |>
    mutate(gap = as.numeric(fu_date - idx_date))
  if (!nrow(fu)) return(NULL)
  keep <- fu |> filter(gap > 14)
  tibble(lesion_type = lt, n_all = nrow(fu),
         cure_all = round(100*mean(!fu$found), 1),
         n_gap14 = nrow(keep),
         cure_gap14 = if (nrow(keep)) round(100*mean(!keep$found), 1) else NA_real_)
})
print(as.data.frame(eff |> arrange(desc(n_all))))
cat("\n  A big jump from cure_all to cure_gap14 means early returns dominate,\n")
cat("  which is the duplicate-entry signature. Little change means early\n")
cat("  returns are genuine failures and should be kept.\n")
