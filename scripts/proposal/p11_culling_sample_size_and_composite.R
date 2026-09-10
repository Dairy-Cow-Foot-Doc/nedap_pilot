# Size the culling outcome across a RANGE of recoverable fractions, and recheck
# the composite margin using the 365-day culling baseline rather than the
# 6-month one I used earlier.
suppressPackageStartupMessages(library(tidyverse))

GAP        <- 7.3 / 100    # association between early lesion and leaving, 365 d
BASE_LAME  <- 0.523        # leaving rate among cows with an early lesion, 365 d
BASE_ALL   <- 0.46         # herd-wide 365-day leaving rate
P_LESION   <- 0.35         # alerted cows with a lesion found
NET_CULL   <- 1500
IOFC       <- 0.37 - 0.29/2.5
za <- qnorm(0.975); zb <- qnorm(0.80)

np <- function(p1, p2) { pb <- (p1+p2)/2
  ceiling((za*sqrt(2*pb*(1-pb)) + zb*sqrt(p1*(1-p1)+p2*(1-p2)))^2 / (p1-p2)^2) }

cat("=== CULLING OUTCOME, across recoverable fractions of the 7.3-point gap ===\n")
cat("    measured among cows WITH a lesion, baseline 52.3% at 365 days\n\n")
r <- tibble(frac = c(0.10, 0.25, 0.40, 0.50, 0.75, 1.00)) |>
  mutate(pts = round(100*frac*GAP, 2),
         p2 = BASE_LAME - frac*GAP,
         n_lame = map2_dbl(BASE_LAME, p2, np),
         enrolled_3arm = ceiling(n_lame / P_LESION) * 3,
         # value per lame cow of that reduction
         value = round(frac*GAP*NET_CULL, 2))
print(r |> transmute(`% of gap recovered` = 100*frac, `points` = pts,
                     `$ per lame cow` = value,
                     `lame cows/arm` = format(n_lame, big.mark=","),
                     `enrolled 3 arms` = format(enrolled_3arm, big.mark=",")) |>
        as.data.frame())
cat("\n  break-even needs about $48 per lame cow from all sources; milk at\n")
cat("  1.05-1.5 kg over 90 days supplies $24-34, so culling must find $14-24.\n")
need <- 20 / NET_CULL
cat(sprintf("  that is %.1f points, or %.0f%% of the 7.3-point association.\n",
            100*need, 100*need/GAP))

cat("\n=== COMPOSITE MARGIN, rechecked on the 365-day culling baseline ===\n")
cat("Earlier I sized this with a 10% six-month culling rate. Over a year the\n")
cat("rate is ~46%, and a Bernoulli near 0.5 has close to maximal variance.\n\n")
for (base in c(0.10, 0.46)) {
  sd_cull <- sqrt(base*(1-base)) * NET_CULL
  sd_milk <- 9.52 * 90 * IOFC * P_LESION
  sd_tot  <- sqrt(sd_cull^2 + sd_milk^2)
  delta   <- 17.5   # margin gain needed per alerted cow
  n2 <- ceiling(2 * sd_tot^2 * (za+zb)^2 / delta^2)
  cat(sprintf("  culling baseline %.0f%%: cull SD $%.0f, milk SD $%.0f, total $%.0f\n",
              100*base, sd_cull, sd_milk, sd_tot))
  cat(sprintf("     -> %s per arm, %s over 3 arms\n\n",
              format(n2, big.mark=","), format(ceiling(n2*1.5), big.mark=",")))
}
cat("  So the composite is MUCH more expensive than I said. Including a\n")
cat("  high-variance binary worth $1,500 swamps the milk signal.\n")

cat("\n=== A CONSERVATIVE, DEFENSIBLE TARGET ===\n")
cat("Powering on MILK alone, and treating culling as an estimated side-benefit\n")
cat("reported with its interval rather than something the study must prove:\n\n")
sd_m <- 9.52
n_milk <- function(d) ceiling(4*(sd_m^2 + 4.79^2/9)*(za+zb)^2/d^2)
for (obs in c(0.8, 1.0, 1.2)) {
  n2 <- n_milk(obs)
  cat(sprintf("  detect an observed %.1f kg/day contrast: %s per arm, %s over 3 arms\n",
              obs, format(n2, big.mark=","), format(ceiling(n2*1.5), big.mark=",")))
}
cat("\n  and what culling precision comes free at those sizes:\n")
for (n3 in c(4300, 6000, 8000)) {
  n_lame_arm <- (n3/3) * P_LESION
  se <- sqrt(2*BASE_LAME*(1-BASE_LAME)/n_lame_arm)
  cat(sprintf("    %s enrolled -> %.0f lame cows/arm, culling CI half-width +/-%.1f points\n",
              format(n3, big.mark=","), n_lame_arm, 100*1.96*se))
}
