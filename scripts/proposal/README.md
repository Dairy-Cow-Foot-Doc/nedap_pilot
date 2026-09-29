# Scripts behind the three-arm proposal

Every figure in `design/proposal_nedap_3arm_draft.md` is produced by one of these.
Run from the project root: `Rscript scripts/proposal/pNN_name.R`.

They are independent — each sources the shared functions and rebuilds what it
needs, so any one can be run alone to re-derive a single number. That costs a few
seconds of duplicated setup and buys the ability to check one figure without
running the rest.

Simulations write their raw draws to `output/`, which is gitignored. The printed
summaries are what the proposal quotes.

## Parameters derived from the pilot

| Script | Produces |
|---|---|
| `p01_milk_variance_components.R` | Between-cow SD 9.39 kg and weekly residual SD 4.79 kg, after the lactation curve, parity and history. **Also establishes that `dmlk1` is in POUNDS** — mean 88.4 lb = 40.1 kg/day. |
| `p02_new_case_incidence.R` | New-case lesion incidence, 27.1 per 100 cow-years, using the validated denominator file. Also per lesion category. |
| `p03_cure_by_lesion_type.R` | Re-examination rate and cure by index lesion. White line 60.4% re-examined and 51.6% cured; DD only 13.4% re-examined. |
| `p04_cure_gap_by_lesion_type.R` | Time from index lesion to the follow-up that found one. Shows foot rot's short-gap clustering (60% within 7 days) is a duplicate-entry artifact, and that white line and sole ulcer show nothing of the kind. |
| `p05_cure_by_chronicity.R` | Cure 51.9% in new cows against 45.0% in chronic, p = 0.007. |
| `p06_culling_window_and_reproduction.R` | The culling gap by window — 4.9 points at 90 days rising to 7.3 at 365 — and the reproduction null. |
| `p07_farm_detection_timing.R` | How and when the farm catches an alerted cow with no protocol acting: staff 17.7% at median 7 days, routine 32.1% at median 23 days, 66% of catches inside four weeks. |
| `p08_enrol_at_freshening_cost.R` | Alert hazard 0.0032/cow-day, so 62% of cows alerted per lactation — the ×1.6 cost of enrolling at freshening. |

## Sample size

| Script | Produces |
|---|---|
| `p10_milk_sample_size.R` | The primary sizing, three ways, **and the reconciliation with the original `camera_math` simulation** — its per-cow variance was 27.8× too small but its success criterion was far stricter, which roughly cancelled. |
| `p11_culling_sample_size_and_composite.R` | Culling sizing across recoverable fractions of the 7.3-point gap, and why a composite dollar endpoint costs 43,000 cows rather than the 5,800 first estimated. |
| `p12_detectable_differences.R` | What 6,000 enrolled detects on every outcome at 80% power. |
| `p13_herd_count_and_accrual.R` | Heterogeneity inflation by herd count, and accrual weeks by herd size. |
| `p14_interaction_cost.R` | What powering the chronicity interaction costs: 11,500 against 5,800. |

## Economics

| Script | Produces |
|---|---|
| `p15_breakeven_with_trim_cost.R` | Extra trims per lame cow (0.97) and the 41% rise in break-even it causes. |
| `p16_breakeven_with_culling.R` | Break-even with both trim cost and avoided culling, matching `C:/Github/camera_math/app.R`. |
| `p17_net_ledger_per_alerted_cow.R` | The full ledger per alerted cow, benefit against cost. |

## Simulation

| Script | Produces |
|---|---|
| `p20_simulate_3arm_milk.R` | Three arms with farm detection parameterised from the pilot. Shows the dilution — a 1.5 kg true effect gives a 1.01 kg observed arm-1-v-3 contrast — and that herd routine-trimming frequency moves power from 75% to 33%. Takes about an hour at 100 reps. |
| `p21_simulate_cure.R` | The cure outcome, with and without the chronicity interaction. Establishes the logistic interaction penalty of 1.59×, which is **not** the 2× that applies to the linear milk model. |

## A caution carried from this work

Several of these numbers changed more than once while the proposal was drafted,
each time because an input was wrong rather than because the method was. The ones
worth re-checking before quoting are the **denominator** (enrolled cows, cows with
a lesion, and cows assessed are all different) and the **window** (a measurement
window shorter than the process can reverse the sign, as the three-month culling
figure did).

## Budget and post-review checks

| Script | Produces |
|---|---|
| `p30_budget.R` | The preliminary budget. Every input is a named constant at the top; the script writes `design/budget_nedap_3arm_draft.md`, so re-costing means changing one line and re-running, never editing the markdown. |
| `p31_baseline_variance_check.R` | **Open decision D2.** Refits the milk variance components with and without the cow's own pre-alert baseline. Baseline as a covariate takes the requirement from 6,200 to 2,300 enrolled; change-from-baseline gives 3,000. r = 0.845. Measured over days 1-30 only, which is the whole caveat. |

See `design/review-proposal-2026-09-10.md` for what the independent review found,
what was verified, and the two decisions left open.

`p32_budget_xlsx.R` writes `design/budget_nedap_3arm.xlsx` — the same budget as a
live workbook. Every figure is an Excel formula referring to named cells on the
Inputs sheet, so changing a yellow cell recalculates everything. The workbook is
an output: re-running the script overwrites it, so change defaults in the script,
not in Excel, if they need to persist.

`p33_attention_hour_check.R` checks the hour-of-day distribution of raw
attentions. It exists because a commit justified the strictly-before alert window
with "no attention occurs before 05:00 and 84% are 18:00-24:00" — both false
(15.4% and 25.5%; the histogram is nearly flat). The window change was still
right, but for the modal-lag reason, not that one.

`p34_stale_lactation_check.R` compares each NEDLAME's own `lact_number` against
the lactation resolved by date. Three disagree, all at DIM 0-1 — but that is
3 of the 8 alerts in that window, which is the rate a trial is exposed to, since
lactation group is a randomisation block.

`p36_trim_list_gap.R` asks whether `CHKLAME` can stand in for a trim list. It
cannot: 82.5% of staff checks are followed by a trim within one day, median gap
1 day, so it records a trim that happened rather than a cow who was booked. The
pilot has no prospective record of intent, which is the argument for capturing
the farm's trim list in the trial.

## Draft 4 resize (2026-09-26) - supersedes p10, p12 and p13 for the current draft

| Script | Produces |
|---|---|
| `p38_milk_sample_size_90d_baseline.R` | D2 over the full 90 days: baseline correlation r = 0.889, Var(cow 90-day mean) 42.4 kg² with baseline vs 98.3 without; bootstrap 90th percentile 51.9; **4,000 enrolled at 6 herds** with an arm-by-herd random slope (tau 0.25); the section 2 herd-count table. Takes a few minutes (bootstrap). |
| `p39_outcome_baselines_180d.R` | Recurrence at 180 days 36.1% cow-level (29.5% same-lactation; the old 48.7% matches neither); culling within 180 days of a pre-go-live camera flag, all flagged cows, 16.0%. |
| `p40_detectable_differences_v2.R` | What 4,000 detects, culling on all enrolled cows; dry-off baseline 22.4% and the share reaching dry-off inside follow-up (21% / 51% / 68% at 6 / 9 / 12 months); break-even on all enrolled (0.25-0.6 points). |

`p16_breakeven_with_culling.R` now takes one trim cost ($18) and one cull cost ($1,650) from the top of the file; section 4 prints the ledger the proposal quotes.

## New v chronic (2026-09-29)

| Script | Produces |
|---|---|
| `p41_chronicity_sample_size.R` | Pilot TX effect by history on the p38 baseline-adjusted model (new +0.39, chronic -1.45, difference 1.84 kg, days 1-30); the overall contrast on the same model (+/-0 - the old 1.05 kg was % of baseline, unadjusted); enrolment to power the new-v-chronic difference with p38's random-slope simulation (4,700 / 7,100 / 16,700 at 1.84 / 1.5 / 1.0 kg) and the intervals at 4,000. Supersedes p14 for the current draft. |
