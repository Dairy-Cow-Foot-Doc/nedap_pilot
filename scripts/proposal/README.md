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
