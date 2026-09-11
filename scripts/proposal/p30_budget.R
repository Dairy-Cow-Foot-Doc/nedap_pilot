# Preliminary budget for the three-arm study.
#
# Every input is a named constant at the top so the whole thing can be re-costed
# by changing one line. The script writes design/budget_nedap_3arm_draft.md.
#
# Structure follows Gerard's brief: one initial visit to each of six farms, then
# a half-day visit to each farm every month, data storage per cow-month, three
# weeks of analysis, and a day a month of project management throughout.

setwd("C:/Github/nedap_pilot")

# ---- study shape -----------------------------------------------------------
N_HERDS        <- 6
HERD_SIZE      <- 3000      # midpoint of the 2,000-5,000 eligibility range
MONTHS         <- 18        # 6 months enrolment + 12 months follow-up
N_INVESTIGATOR <- 3         # Gerard (West Coast), NY, Midwest - two farms each
FARMS_EACH     <- N_HERDS / N_INVESTIGATOR

# ---- rates -----------------------------------------------------------------
DAY_RATE       <- 2500      # per investigator per visit-day
HALF_DAY       <- DAY_RATE / 2
ANALYSIS_DAYS  <- 15        # three weeks
PM_DAYS_MONTH  <- 1
STORAGE_RATE   <- 0.06      # $/cow/month

# ---- travel, deliberately liberal ------------------------------------------
# Gerard flies from Vancouver to each distant region once, covering both of that
# region's farms in one trip.
trip <- function(air, car_days, car_rate, nights, night_rate, days, per_diem)
  air + car_days * car_rate + nights * night_rate + days * per_diem

g_buffalo <- trip(air = 800, car_days = 4, car_rate = 80, nights = 3, night_rate = 180,
                  days = 4, per_diem = 80)
g_denver  <- trip(air = 650, car_days = 4, car_rate = 80, nights = 3, night_rate = 180,
                  days = 4, per_diem = 80)
g_westcoast <- trip(air = 0, car_days = 3, car_rate = 0, nights = 2, night_rate = 180,
                    days = 3, per_diem = 80) + 400        # mileage instead of rental
collab_initial <- trip(air = 0, car_days = 0, car_rate = 0, nights = 1, night_rate = 180,
                       days = 2, per_diem = 80) + 350     # regional drive

# monthly: each investigator does both their farms in one day-trip
MONTHLY_TRIP_DRIVE <- 350
MONTHLY_OVERNIGHT_FRACTION <- 0.5
MONTHLY_NIGHT_RATE <- 180

# ---- personnel -------------------------------------------------------------
# Initial round: Gerard visits all six. The NY and Midwest collaborators join him
# at their own two. The West Coast farms are Gerard's own, so he is alone there.
pv_gerard_initial <- N_HERDS                       # 6 visit-days
pv_collab_initial <- 2 * FARMS_EACH                # NY 2 + Midwest 2 = 4
initial_personnel <- (pv_gerard_initial + pv_collab_initial) * DAY_RATE

monthly_halfdays  <- N_INVESTIGATOR * FARMS_EACH * MONTHS
monthly_personnel <- monthly_halfdays * HALF_DAY

analysis_personnel <- ANALYSIS_DAYS * DAY_RATE
pm_personnel       <- PM_DAYS_MONTH * MONTHS * DAY_RATE

personnel <- initial_personnel + monthly_personnel + analysis_personnel + pm_personnel

# ---- travel ----------------------------------------------------------------
initial_travel <- g_buffalo + g_denver + g_westcoast + 2 * collab_initial

monthly_trips  <- N_INVESTIGATOR * MONTHS
monthly_travel <- monthly_trips * MONTHLY_TRIP_DRIVE +
                  monthly_trips * MONTHLY_OVERNIGHT_FRACTION * MONTHLY_NIGHT_RATE

travel <- initial_travel + monthly_travel

# ---- data ------------------------------------------------------------------
cows_monitored <- N_HERDS * HERD_SIZE
storage_whole  <- cows_monitored * STORAGE_RATE * MONTHS
storage_enrol  <- 6000 * STORAGE_RATE * MONTHS      # if only study cows are charged
data_cost      <- storage_whole

subtotal   <- personnel + travel + data_cost
CONTINGENCY <- 0.10
contingency <- subtotal * CONTINGENCY
total       <- subtotal + contingency

m <- function(x) paste0("\\$", formatC(round(x), format = "d", big.mark = ","))

cat("\n=== PRELIMINARY BUDGET ===\n")
cat(sprintf("  personnel   %10s\n", m(personnel)))
cat(sprintf("  travel      %10s\n", m(travel)))
cat(sprintf("  data        %10s\n", m(data_cost)))
cat(sprintf("  contingency %10s\n", m(contingency)))
cat(sprintf("  TOTAL       %10s   (%s per enrolled cow at 6,000)\n",
            m(total), m(total / 6000)))

# ---------------------------------------------------------------------------
out <- c(
"# Preliminary budget — three-arm SmartSight study",
"",
sprintf("**Draft %s.** Every figure here comes from `scripts/proposal/p30_budget.R`; change an input at the top of that script and the whole budget re-costs. Travel is deliberately liberal.", format(Sys.Date())),
"",
"------------------------------------------------------------------------",
"",
"## What is being costed",
"",
sprintf("- **%d herds**, %s cows each on average, run by **%d investigators** with two farms each — Gerard on the West Coast, one collaborator in New York, one in the Midwest.", N_HERDS, format(HERD_SIZE, big.mark = ","), N_INVESTIGATOR),
sprintf("- **%d months**: six of enrolment, twelve of follow-up on the last cow enrolled.", MONTHS),
sprintf("- **One initial visit to every farm**, then a **half-day visit to each farm every month** for the life of the project."),
"",
"------------------------------------------------------------------------",
"",
"## Summary",
"",
"| Category | Cost | Share |",
"|---|---:|---:|",
sprintf("| Personnel | %s | %.0f%% |", m(personnel), 100 * personnel / total),
sprintf("| Travel | %s | %.0f%% |", m(travel), 100 * travel / total),
sprintf("| Data | %s | %.0f%% |", m(data_cost), 100 * data_cost / total),
sprintf("| Subtotal | **%s** | |", m(subtotal)),
sprintf("| Contingency at %.0f%% | %s | |", 100 * CONTINGENCY, m(contingency)),
sprintf("| **Total** | **%s** | |", m(total)),
"",
sprintf("**About %s per enrolled cow** at 6,000 enrolled, or %s per herd.", m(total / 6000), m(total / N_HERDS)),
"",
"------------------------------------------------------------------------",
"",
"## Personnel",
"",
sprintf("Costed at **%s per investigator per visit-day**, %s for a half-day.", m(DAY_RATE), m(HALF_DAY)),
"",
"| Item | Basis | Cost |",
"|---|---|---:|",
sprintf("| Initial farm visits | %d visit-days — Gerard at all six farms, each collaborator joining at their own two | %s |", pv_gerard_initial + pv_collab_initial, m(initial_personnel)),
sprintf("| Monthly farm visits | %d half-days — %d investigators x %d farms x %d months | %s |", monthly_halfdays, N_INVESTIGATOR, FARMS_EACH, MONTHS, m(monthly_personnel)),
sprintf("| Analysis and reporting | %d days (three weeks) | %s |", ANALYSIS_DAYS, m(analysis_personnel)),
sprintf("| Project management | %d day/month x %d months | %s |", PM_DAYS_MONTH, MONTHS, m(pm_personnel)),
sprintf("| **Total** | | **%s** |", m(personnel)),
"",
sprintf(paste0("**The monthly visits are the single largest line in the budget** — more than half of all ",
               "personnel cost. If a half-day visit to every farm every month turns out to be more than the ",
               "protocol needs, that is the first place to look for savings: holding monthly visits through ",
               "enrolment and dropping to every second month for the follow-up year would save about %s."),
        m((monthly_halfdays - N_INVESTIGATOR * FARMS_EACH * (6 + 12 / 2)) * HALF_DAY)),
"",
"------------------------------------------------------------------------",
"",
"## Travel",
"",
"### Initial round",
"",
"| Trip | Components | Cost |",
"|---|---|---:|",
sprintf("| Gerard, Vancouver to Buffalo | Airfare %s, car 4 days, 3 nights, per diem — covers both NY farms | %s |", m(800), m(g_buffalo)),
sprintf("| Gerard, Vancouver to Denver | Airfare %s, car 4 days, 3 nights, per diem — covers both Midwest farms | %s |", m(650), m(g_denver)),
sprintf("| Gerard, West Coast | Mileage, 2 nights, per diem | %s |", m(g_westcoast)),
sprintf("| NY collaborator | Regional drive, 1 night | %s |", m(collab_initial)),
sprintf("| Midwest collaborator | Regional drive, 1 night | %s |", m(collab_initial)),
sprintf("| **Total** | | **%s** |", m(initial_travel)),
"",
"### Monthly round",
"",
sprintf("Each investigator covers both of their farms in a single day-trip, so **%d trips** rather than %d.", monthly_trips, monthly_halfdays),
"",
"| Item | Basis | Cost |",
"|---|---|---:|",
sprintf("| Mileage and meals | %d trips at %s | %s |", monthly_trips, m(MONTHLY_TRIP_DRIVE), m(monthly_trips * MONTHLY_TRIP_DRIVE)),
sprintf("| Overnight stays | %.0f%% of trips at %s | %s |", 100 * MONTHLY_OVERNIGHT_FRACTION, m(MONTHLY_NIGHT_RATE), m(monthly_trips * MONTHLY_OVERNIGHT_FRACTION * MONTHLY_NIGHT_RATE)),
sprintf("| **Total** | | **%s** |", m(monthly_travel)),
"",
"------------------------------------------------------------------------",
"",
"## Data",
"",
sprintf("Storage at **\\$%.2f per cow per month**. The figure below charges the **whole monitored herd**, not just enrolled cows, because the camera watches every cow in the pen regardless of whether she is in the study.", STORAGE_RATE),
"",
"| Basis | Cows | Cost |",
"|---|---:|---:|",
sprintf("| **Whole herd monitored** *(used)* | %s | **%s** |", format(cows_monitored, big.mark = ","), m(storage_whole)),
sprintf("| Enrolled cows only | 6,000 | %s |", m(storage_enrol)),
"",
sprintf("If Nedap charges only for study cows the data line falls by %s. Worth asking them which it is.", m(storage_whole - storage_enrol)),
"",
"------------------------------------------------------------------------",
"",
"## What is not in here yet",
"",
"- **The camera subscription itself**, and whether Nedap supplies hardware for the study herds or the budget carries it. At \\$0.65-0.80/cow/month across 18,000 cows for 18 months this is \\$210,000-260,000 — larger than everything above combined, so it needs settling early.",
sprintf(paste0("- **Extra trimming.** The protocol trims cows in arms 1 and 2 who would not otherwise have ",
               "been trimmed. In the pilot the trimmed arm was trimmed 90.4%% of the time against the ",
               "control arm's 49.8%%, so **0.406 extra trims per enrolled cow**. Across the %s cows in the ",
               "two protocol arms at \\$18 a trim that is about **%s for the whole study** — not a ",
               "whole-herd cost, and not annual. **Who pays it is an open question**: it is a real cost the ",
               "arms do not share equally, and farms will ask."),
        format(round(6000 * 2 / 3), big.mark = ","), m(6000 * 2 / 3 * 0.406 * 18)),
"- Farm compensation or incentive payments.",
"- Publication and open-access charges.",
"- Statistical consulting beyond the analysis days above.",
"- Institutional overhead, which will depend on whose institution holds the award.",
"",
"------------------------------------------------------------------------",
"",
"## Sensitivity",
"",
"All three are savings against the \\$321,079 total, and all include the 10% contingency.",
"",
"| Change | Saving |",
"|---|---:|",
sprintf("| 15 months rather than 18 | %s |",
        m(total - (personnel - monthly_personnel - pm_personnel +
                   N_INVESTIGATOR * FARMS_EACH * 15 * HALF_DAY + 15 * DAY_RATE +
                   travel - monthly_travel +
                   N_INVESTIGATOR * 15 * MONTHLY_TRIP_DRIVE +
                   N_INVESTIGATOR * 15 * MONTHLY_OVERNIGHT_FRACTION * MONTHLY_NIGHT_RATE +
                   cows_monitored * STORAGE_RATE * 15) * (1 + CONTINGENCY))),
sprintf("| Four herds rather than six | roughly %s, as two farms' visits and travel fall away |",
        m(2 / 6 * (initial_personnel + monthly_personnel) * (1 + CONTINGENCY))),
sprintf("| Monthly visits halved for the follow-up year | about %s |",
        m((monthly_halfdays - N_INVESTIGATOR * FARMS_EACH * (6 + 12 / 2)) * HALF_DAY * (1 + CONTINGENCY))),
"",
"**Four herds is the one that changes the science as well as the cost** — see the heterogeneity table in the proposal. The other two are scheduling decisions.",
"")

writeLines(out, "design/budget_nedap_3arm_draft.md")
cat("\nwrote design/budget_nedap_3arm_draft.md\n")
