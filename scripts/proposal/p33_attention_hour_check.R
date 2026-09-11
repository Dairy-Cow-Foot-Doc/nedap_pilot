# The other session says the "no attention occurs before 05:00, 84% are 18:00-24:00"
# justification does not hold. That claim is what the strictly-before window was
# argued from, so check it directly against the export.
setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages({library(tidyverse); library(lubridate)})

f <- "data/nedap_attentions_2026-08-27.csv"
if (!file.exists(f)) f <- "data/SkyView_Tioga_Attentions.csv"
cat("reading:", f, "\n")
a <- read_csv(f, show_col_types = FALSE)
cat("rows:", nrow(a), "\n")

stopifnot("start_time_utc" %in% names(a))
lt <- with_tz(ymd_hms(a$start_time_utc, tz = "UTC"), "America/Chicago")
lt <- lt[!is.na(lt)]
h  <- hour(lt)

cat("\n=== hour of day, local farm time ===\n")
cat(sprintf("  before 05:00 : %6d of %d = %.1f%%   (commit claims ZERO)\n",
            sum(h < 5), length(h), 100 * mean(h < 5)))
cat(sprintf("  18:00-24:00  : %6d        = %.1f%%   (commit claims 84%%)\n",
            sum(h >= 18), 100 * mean(h >= 18)))
cat("\n  deciles of hour:", paste(round(quantile(h, seq(0.1, 0.9, 0.1)), 1), collapse = " "), "\n")

cat("\n=== full hour histogram ===\n")
tb <- table(factor(h, levels = 0:23))
for (k in 0:23) cat(sprintf("  %02d:00 %5d %s\n", k, tb[[k + 1]],
                            strrep("#", round(40 * tb[[k + 1]] / max(tb)))))
