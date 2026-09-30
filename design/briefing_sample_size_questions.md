# INTERNAL - sample size: expected questions and answers

For Gerard only. Not part of the proposal. Written 2026-09-30, against the 5,000-cow, 14-month design (commit `634e793`).

> **SUPERSEDED (2026-09-30 night).** Every power and interval figure below is for the Hartung-Knapp test, which is no longer the primary analysis. The proposal now uses the conventional multi-centre model (arm and herd fixed, no arm-by-herd term) and offers 4,000 or 5,000 cows: 91% / 95% power at 1.0 kg observed, ±0.56 / ±0.50 kg. See review doc F4. Re-write this briefing before relying on it.

Everything here comes from `scripts/proposal/p42_simulate_trial_cow_level.R` (the cow-level simulation) and `p43_simple_check.R` (the textbook cross-check). Review-doc section F3 has the detail.

------------------------------------------------------------------------

## The one-paragraph answer

5,000 cows gives 82% power for a 1.0 kg/day observed milk difference between arm 1 and arm 3, and a 95% interval of about ±0.66 kg/day. The observed difference is about half the true effect of trimming, because farm practice trims 65% of arm-3 cows within 90 days. A simple textbook calculation gives the same answer (83%). The study is designed to **estimate** the milk effect to that precision, not to prove the system pays.

------------------------------------------------------------------------

## Precision: the goal

**The number that answers "does it pay" is the observed difference** - arm 1 against arm 3, as randomized. A farm buys the strategy (camera plus acting on alerts) against what it already does, and farm practice already trims many alerted cows. The effect of trimming a single cow (about twice the observed difference) explains why, but it does not say whether the system pays. Keep it out of the headline.

**What the study would report at 5,000 enrolled** (simulation, 1,000 trials per row, Hartung-Knapp 95% interval, kg/day):

| True effect of trimming | Typical estimate | Typical 95% interval | Lower bound > 0 | Lower bound ≥ 0.5 | **Lower bound ≥ 1.0** |
|---|---|---|---|---|---|
| 0 | 0.00 | −0.65 to 0.65 | 3% | 0% | 0% |
| 1.0 | 0.47 | −0.19 to 1.15 | 28% | 2% | 0% |
| 1.5 | 0.72 | 0.06 to 1.39 | 57% | 11% | 0% |
| **2.0 (planned)** | **0.98** | **0.32 to 1.64** | **81%** | **28%** | **3%** |
| 2.5 | 1.22 | 0.54 to 1.86 | 94% | 54% | 8% |
| 3.0 | 1.45 | 0.80 to 2.12 | 98% | 80% | 26% |
| 3.5 | 1.71 | 1.04 to 2.40 | 100% | 92% | 55% |
| 4.0 | 1.96 | 1.27 to 2.65 | 100% | 98% | 78% |

*"Typical" is the median trial. The estimate itself moves by about ±0.37 kg between trials (10th to 90th percentile), and the interval moves with it.*

**Reading it:**

- **The interval is about ±0.66 kg/day at every effect size.** That is the precision 5,000 buys.
- **A lower bound of 1.0 kg on the observed difference needs a true effect of 3.5 kg/day or more to be likely** (55% at 3.5, 78% at 4.0). At the planned 2.0 kg it happens 3% of the time.
- **At the planned effect, the study most likely reports about 1.0 kg/day with an interval of 0.3 to 1.6.** Over 90 days that is about 90 kg per cow, with a lower bound near 30 kg.
- **So if 1.0 kg/day is what the system needs to pay, the study will most likely show a smaller difference with confidence,** and say how much smaller. That is still a useful answer for a purchase decision, but it is not a demonstration of payback.
- **More cows would not change this much.** At 8,000 the interval is about ±0.56; the lower bound at the planned effect rises only from about 0.3 to 0.4 kg.

------------------------------------------------------------------------

## Questions to expect, most likely first

### 1. "Your effect size is assumed, not measured."

- **The point:** sized for a 1.0 kg observed difference (about 2.0 kg true). On the same adjusted outcome the pilot showed +0.08 kg/day (95% CI −1.0 to +1.2). At a 1.5 kg true effect, power is 59%.
- **Answer:** the pilot was one herd, 30 days, and never sized for milk. Its interval does not rule 1.0 kg out. 1.0 kg is the smallest difference worth detecting. The study's aim is to estimate the effect to ±0.66 kg, which holds whatever the true effect is.
- **Prepare:** a published estimate of milk loss around lameness treatment, to support the 2.0 kg true effect. Not yet found - needs a source.

### 2. "You're powered for an effect that doesn't pay."

- **The point:** 1.0 kg/day is below break-even on milk alone.
- **Answer:** proving payback on milk is impossible at any feasible size. The study estimates the total return - milk, culling, cure, trimming - with its interval. It does not claim a test that the system pays. The proposal says so in §5.

### 3. "Your control arm is heavily treated."

- **The point:** 65% of arm-3 cows are trimmed by farm practice within 90 days, so the observed difference is half the true effect. Why not a cleaner control?
- **Answer:** farm practice is the right comparator. It is what a farm without the camera does, and the question a buyer faces.
- **Prepare:** a pre-specified secondary analysis estimating the effect among cows whose treatment actually differed by arm, from the recorded trim dates. It costs no cows.

### 4. "The between-herd variation is a guess, and six herds is thin."

- **The point:** τ = 0.25 kg is a planning assumption; a single herd cannot measure it. At 0.5 kg, power falls to 65%.
- **Answer:** the §5 herd table shows the sensitivity. Hartung-Knapp keeps the false-positive rate at 5% with six herds (4.8% in the simulation). Eight herds (+$55,000) holds 76% at 0.5 kg - cheaper protection than more cows.

### 5. "The variance comes from 114 cows in one herd."

- **Answer:** it is planned at the 90th percentile of a bootstrap of that estimate (51.9 kg²), not the point (42.4). At the point estimate, power would be 88%; at 60 kg², 78%.
- **Best defence:** the blinded interim check below.

### Less likely

- **"The simulation is a black box."** A textbook formula gives the same answer (83% v 82%, dilution 0.50 v 0.49). An independent code review found no errors in the statistics.
- **"Three arms and many outcomes - multiple testing?"** One primary comparison (milk, arm 1 v 3), then secondaries in a stated order. *The proposal implies this order but does not state it - worth one line in §6.*
- **"The secondary outcomes are underpowered."** Yes; §5 says what each detects. Arm 1 v 2 on milk and new v chronic are estimated, not powered.
- **"Cows trimmed on the same day by the same trimmer are not independent."** Not modelled; probably small. Worth one sentence in the analysis plan.
- **"The benefit may not start at the trim."** The pilot hinted at an early post-trim dip (−0.32 kg over days 1–30). If there is one, the observed difference is smaller. State it as a limitation.
- **"The alert rate will be lower than you think."** Planned at 0.010–0.020 alerted cows per cow per week, under half the pilot's 0.024. 3.2–6.4 months expected at a 3,000-cow herd; 8 months allowed.

------------------------------------------------------------------------

## Ways to strengthen it without more cows

1. **Choose herds on how much routine trimming reaches alerted cows.** The biggest lever the design controls: 20% less arm-3 dilution takes power from 83% to 93%; 20% more drops it to 65%.
2. **A blinded interim check at about 1,500 cows.** Re-estimate the variance and the alert rate without looking at the arms, with a pre-set cap on any increase. No cost to the false-positive rate. It answers question 5 directly.
3. **Eight herds if the budget allows** (+$55,000). It answers question 4.
4. **State the primary goal as precision** (±0.66 kg on the milk difference), with power second. It takes the heat out of question 1.
