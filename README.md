# NEDLAME Alert Pilot — Dairy Health Data Analysis

This repo answers one question: **is the Nedap `NEDLAME` mobility-alert pilot worth adopting?** Cows flagged by the alert are split into two arms — automatically trimmed (**TX**) vs. left to staff judgement (**Control**) — and this analysis compares them on milk production, time to follow-up, independent staff detection, and how many lameness cases the alert actually catches.

It started as a fork of [DairyHealthDataProcessing](https://github.com/LivestockVeterinaryResources/DairyHealthDataProcessing) (a general DairyComp-to-parquet processing pipeline, originally built for teaching) and has since grown into a specific, self-contained analysis project. The pipeline mechanics are still used under the hood — see [Underlying data pipeline](#underlying-data-pipeline) — but the reason this repo exists now is the pilot analysis, not the teaching framework.

## Start here

- **[qmd_reports/report_nedlame_treatment_comparison.qmd](qmd_reports/report_nedlame_treatment_comparison.qmd)** — the full analysis: milk trend, time-to-next-lameness-event, independent staff detection, alert miss-rate, lameness history, time-to-culling. Renders to `reports/qmd_reports/report_nedlame_treatment_comparison.html`.
- **[qmd_reports/executive_summary_nedlame_pilot.qmd](qmd_reports/executive_summary_nedlame_pilot.qmd)** — a short, code-free summary of the headline findings, for discussion.
- **[qmd_reports/plan_nedlame_treatment_comparison.qmd](qmd_reports/plan_nedlame_treatment_comparison.qmd)** — the design record: every methodology decision, every bug found (and how), and why the report is built the way it is. Read this before changing the analysis — several things that look like bugs are deliberate, and it explains why.
- **[mcp_server/](mcp_server/)** — an MCP server packaging the validated patterns and R functions from this analysis for reuse on the 3-arm follow-up study. See its README for what MCP is and how to register it.

## What's specific to this pilot (not part of the general pipeline)

- **`MNFRS`** (in `data/intermediate_files/events_all_columns.parquet` only — it's dropped from `events_formatted.parquet`) identifies the treatment arm: `1` = TX (auto-trimmed), `2` = Control. Confirmed against the farm's DairyComp `NEDLAME`/`MNFRS` setup documentation.
- **`data/milk/`** (`UMN_milk_SV_MM-DD-YYYY.csv` files) is a milk-production data source not wired into the general pipeline's `step1a_read_in_production_data.R`. `functions/fxn_read_milk_folder.R` reads it and resolves each row's raw animal ID to a specific animal-lactation (raw IDs get reused across animals over time, so this isn't a trivial join — see the function's comments).
- **`functions/fxn_code_lesions.R`** and **`functions/fxn_collapse_lesions.R`** are corrected local overrides of same-named functions normally fetched live from `github.com/Dairy-Cow-Foot-Doc/os_functions` (via `functions/fxn_load_os_fxns.R`). Both had real bugs that silently misclassified lesions on this farm's data — see the plan doc for details. A fix was prepared and pushed upstream (branch `fix/lesion-classification-bugs`); check whether it's been merged before assuming these local overrides are still necessary.

## Underlying data pipeline

The general mechanics (unchanged from the upstream framework): one entry point, `step0_master_processing.R`, runs a pipeline that turns raw DairyComp exports into parquet artifacts in `data/intermediate_files/`:

- `animals.parquet` — one row per unique animal
- `animal_lactations.parquet` — one row per unique animal-lactation
- `events_formatted.parquet` — one row per event, standardized columns (drops `MNFRS` — this pilot's code reads `events_all_columns.parquet` instead when it needs that field, see above)
- `events_all_columns.parquet` — the untrimmed version of the above, keeps every raw column
- `denominator_by_calendar_time_period.parquet` — animal counts per farm/lactation-group/time-period

To regenerate these from a fresh DairyComp pull:

1. Pull events from DairyComp (`EVENTS\2S2000CHN #1 #2 #4 #5 #6 #11 #12 #13 #15 #28 #29 #30 #31 #32 #38 #40 #43`, or the "days back" variant) into `data/event_files/`.
2. Optionally pull heifer data (same command + `FOR LACT=0`) into the same folder.
3. Optionally pull production data into `data/milk_files/` — **note**: this pilot's actual milk data lives in `data/milk/` instead, in a different format; see above.
4. Check the options at the top of `step0_master_processing.R`, then run it.
5. Use the files in `data/intermediate_files/` (or the reports in `qmd_reports/` that already read them) from there.

`data/` subfolders aren't shared to git except `data/shared_files/` (size/privacy) — see `.gitignore`.

### Project paths

Plain project-root-relative paths (e.g. `read_parquet("data/intermediate_files/animals.parquet")`); multi-part paths use base R `file.path()`. Run scripts and render reports from the project root — `_quarto.yml` sets `execute-dir: project` so Quarto documents execute from the root automatically.

## Leftover from the upstream teaching framework

`milestones_dairy/`, `in_development/`, and `junk/` are course/teaching material and work-in-progress scripts inherited from the upstream `DairyHealthDataProcessing` framework — not part of this pilot's analysis. `qmd_reports/report_data_dictionary.qmd`, `report_how_to_use_denominators.qmd`, and `report_explore_lame_new.qmd` (the general lameness-report template this pilot's report is modeled on) are also from the upstream framework and still useful as general-purpose references.
