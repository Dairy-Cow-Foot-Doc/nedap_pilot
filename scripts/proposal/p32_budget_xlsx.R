# Builds the budget workbook in GERARD'S staircase layout.
#
# The rule, taken from his "GC personnel" sheet: a number sits in a column, its
# LABEL sits one column to its right, and its COMPONENTS sit one column further
# right on the rows below. You read left-to-right to drill into any figure, and
# the arithmetic is visible on the sheet rather than described in a text column.
#
#   A  TOTAL
#      B  category
#         C  line item
#            D  the numbers that multiply together
#
# Everything is a live Excel formula against named input cells, so changing an
# input recalculates the whole staircase.
#
# Gerard's own "GC personnel" sheet is PRESERVED untouched - this script deletes
# and rebuilds only the sheets it owns.

setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages(library(openxlsx))
OUT <- "design/budget_nedap_3arm.xlsx"

# ---- styles ----------------------------------------------------------------
st_title <- createStyle(fontSize = 14, textDecoration = "bold")
st_note  <- createStyle(fontColour = "#7F7F7F", wrapText = TRUE, valign = "top")
st_hdr   <- createStyle(textDecoration = "bold", fgFill = "#D9E2F3", border = "TopBottom")
st_in    <- createStyle(fgFill = "#FFF2CC", border = "TopBottomLeftRight",
                        borderColour = "#BF9000", numFmt = "#,##0.00")
st_lab   <- createStyle(fontColour = "#404040")
st_grand <- createStyle(numFmt = "$#,##0", textDecoration = "bold", fontSize = 13,
                        fgFill = "#E2EFDA", border = "TopBottom")
st_cat   <- createStyle(numFmt = "$#,##0", textDecoration = "bold")
st_item  <- createStyle(numFmt = "$#,##0")
st_part  <- createStyle(numFmt = "#,##0.##", fontColour = "#595959")
st_sect  <- createStyle(textDecoration = "bold", fontSize = 11)

wb <- loadWorkbook(OUT)
# Gerard's own sheets are preserved by not being on this list. He renamed
# "GC personnel" to "GC example"; delete by name only, never by position.
for (s in c("Summary", "Inputs", "Personnel", "Travel", "Data", "Budget")) {
  if (s %in% names(wb)) removeWorksheet(wb, s)
}
addWorksheet(wb, "Budget")
SH <- "Budget"

r <- 1
put <- function(col, row, value, style = NULL, formula = FALSE) {
  if (formula) writeFormula(wb, SH, paste0("=", value), startCol = col, startRow = row)
  else         writeData(wb, SH, value, startCol = col, startRow = row)
  if (!is.null(style)) addStyle(wb, SH, style, rows = row, cols = col)
}
label <- function(col, row, text) {
  writeData(wb, SH, text, startCol = col, startRow = row)
  addStyle(wb, SH, st_lab, rows = row, cols = col)
}

put(1, 1, "Budget \u2014 three-arm SmartSight study", st_title)
put(1, 2, paste("Yellow cells are inputs. Every figure to the LEFT of a number is built from it:",
                "read right to drill into a total, left to roll it up."), st_note)

# ===========================================================================
# INPUTS  (value in A, label in B) - the same idiom as the GC sheet
# ===========================================================================
r <- 4
put(1, r, "INPUTS", st_sect); r <- r + 1

inputs <- list(
  c("DAY_RATE",        2500,  "Daily fee, $ per investigator per day"),
  c("N_HERDS",         6,     "# of farms"),
  c("N_INVESTIGATORS", 3,     "# of investigators (Gerard, New York, Midwest)"),
  c("INIT_DAYS",       1,     "Initial visit days per farm"),
  c("MONTHLY_DAYS",    0.5,   "Monthly visit days per farm"),
  c("MO_ENROL",        6,     "Months of ENROLMENT — farm visits and their travel run only here"),
  c("MO_FOLLOWUP",     12,    "Months of FOLLOW-UP — passive data collection, no farm visits"),
  c("ANALYSIS_DAYS",   15,    "Analysis and reporting days"),
  c("PM_DAYS_MO",      1,     "Project management days per month"),
  c("HERD_SIZE",       3000,  "Cows per farm"),
  c("STORAGE_RATE",    0.06,  "Data storage, $ per cow per month"),
  c("CONTINGENCY",     0.10,  "Contingency, fraction of subtotal"),
  c("ENROLLED",        6000,  "Cows enrolled (for cost per cow)"),
  c("AIR_NY",          800,   "Airfare Vancouver-Buffalo, return"),
  c("AIR_MW",          650,   "Airfare Vancouver-Denver, return"),
  c("CAR_DAY",         80,    "Rental car, $ per day"),
  c("NIGHT",           180,   "Accommodation, $ per night"),
  c("PER_DIEM",        80,    "Meals and incidentals, $ per day"),
  c("TRIP_DRIVE",      350,   "Monthly trip mileage and meals, $ per trip"),
  c("ON_FRAC",         0.5,   "Share of monthly trips needing an overnight")
)
for (x in inputs) {
  put(1, r, as.numeric(x[[2]]), st_in)
  label(2, r, x[[3]])
  createNamedRegion(wb, SH, cols = 1, rows = r, name = x[[1]], overwrite = TRUE)
  r <- r + 1
}
r <- r + 1
put(1, r, "DERIVED", st_sect); r <- r + 1
for (d in list(c("FARMS_EACH", "N_HERDS/N_INVESTIGATORS", "Farms per investigator"),
               c("HALF_DAY", "DAY_RATE*MONTHLY_DAYS", "$ per monthly half-day visit"),
               c("COWS", "N_HERDS*HERD_SIZE", "Cows monitored in total"))) {
  put(1, r, d[[2]], st_part, formula = TRUE)
  label(2, r, d[[3]])
  createNamedRegion(wb, SH, cols = 1, rows = r, name = d[[1]], overwrite = TRUE)
  r <- r + 1
}

# ===========================================================================
# THE STAIRCASE
# ===========================================================================
r <- r + 2
put(1, r, "THE BUDGET", st_sect)
put(2, r, "read right to drill in", st_note)
r <- r + 2

TOTAL_ROW <- r
r <- r + 1

# --- B: PERSONNEL ----------------------------------------------------------
PERS_ROW <- r; r <- r + 1

# C: initial visits
INIT_ROW <- r; r <- r + 1
put(4, r, "DAY_RATE", st_part, formula = TRUE); label(5, r, "Daily fee"); r <- r + 1
put(4, r, "N_HERDS*INIT_DAYS + 2*FARMS_EACH*INIT_DAYS", st_part, formula = TRUE)
label(5, r, "Visit-days: Gerard at all farms, each collaborator at their own two"); IDAYS <- r; r <- r + 1
put(3, INIT_ROW, sprintf("D%d*D%d", INIT_ROW + 1, IDAYS), st_item, formula = TRUE)
label(4, INIT_ROW, "Initial farm visits")

# C: monthly visits
MON_ROW <- r; r <- r + 1
put(4, r, "N_HERDS", st_part, formula = TRUE); label(5, r, "# of farms to visit"); M1 <- r; r <- r + 1
put(4, r, "MO_ENROL*MONTHLY_DAYS", st_part, formula = TRUE)
label(5, r, "Visit-days per farm — enrolment months only, follow-up is passive"); M2 <- r; r <- r + 1
put(4, r, "DAY_RATE", st_part, formula = TRUE); label(5, r, "Daily fee"); M3 <- r; r <- r + 1
put(3, MON_ROW, sprintf("D%d*D%d*D%d", M1, M2, M3), st_item, formula = TRUE)
label(4, MON_ROW, "Monthly farm visits")

# C: project management
PM_ROW <- r; r <- r + 1
put(4, r, "PM_DAYS_MO", st_part, formula = TRUE); label(5, r, "# of days per month"); P1 <- r; r <- r + 1
put(4, r, "MO_ENROL+MO_FOLLOWUP", st_part, formula = TRUE); label(5, r, "Total months"); P2 <- r; r <- r + 1
put(4, r, "DAY_RATE", st_part, formula = TRUE); label(5, r, "Daily fee"); P3 <- r; r <- r + 1
put(3, PM_ROW, sprintf("D%d*D%d*D%d", P1, P2, P3), st_item, formula = TRUE)
label(4, PM_ROW, "Project management")

# C: analysis
AN_ROW <- r; r <- r + 1
put(4, r, "ANALYSIS_DAYS", st_part, formula = TRUE); label(5, r, "# of days (three weeks)"); A1 <- r; r <- r + 1
put(4, r, "DAY_RATE", st_part, formula = TRUE); label(5, r, "Daily fee"); A2 <- r; r <- r + 1
put(3, AN_ROW, sprintf("D%d*D%d", A1, A2), st_item, formula = TRUE)
label(4, AN_ROW, "Analysis and reporting")

put(2, PERS_ROW, sprintf("C%d+C%d+C%d+C%d", INIT_ROW, MON_ROW, PM_ROW, AN_ROW), st_cat, formula = TRUE)
label(3, PERS_ROW, "PERSONNEL")

# --- B: TRAVEL -------------------------------------------------------------
TRAV_ROW <- r; r <- r + 1

INITTR_ROW <- r; r <- r + 1
trips <- list(
  c("AIR_NY + 4*CAR_DAY + 3*NIGHT + 4*PER_DIEM", "Gerard to Buffalo \u2014 both New York farms"),
  c("AIR_MW + 4*CAR_DAY + 3*NIGHT + 4*PER_DIEM", "Gerard to Denver \u2014 both Midwest farms"),
  c("400 + 2*NIGHT + 3*PER_DIEM",                "Gerard, West Coast \u2014 his own two farms, driving"),
  c("350 + 1*NIGHT + 2*PER_DIEM",                "New York collaborator \u2014 regional"),
  c("350 + 1*NIGHT + 2*PER_DIEM",                "Midwest collaborator \u2014 regional"))
t_first <- r
for (t in trips) { put(4, r, t[[1]], st_part, formula = TRUE); label(5, r, t[[2]]); r <- r + 1 }
put(3, INITTR_ROW, sprintf("SUM(D%d:D%d)", t_first, r - 1), st_item, formula = TRUE)
label(4, INITTR_ROW, "Initial round \u2014 one trip to every farm")

MONTR_ROW <- r; r <- r + 1
put(4, r, "N_INVESTIGATORS*MO_ENROL", st_part, formula = TRUE)
label(5, r, "Trips \u2014 one per investigator per enrolment month, both farms in a day"); T1 <- r; r <- r + 1
put(4, r, "TRIP_DRIVE + ON_FRAC*NIGHT", st_part, formula = TRUE)
label(5, r, "Cost per trip, mileage and meals plus a part-share of a night"); T2 <- r; r <- r + 1
put(3, MONTR_ROW, sprintf("D%d*D%d", T1, T2), st_item, formula = TRUE)
label(4, MONTR_ROW, "Monthly rounds")

put(2, TRAV_ROW, sprintf("C%d+C%d", INITTR_ROW, MONTR_ROW), st_cat, formula = TRUE)
label(3, TRAV_ROW, "TRAVEL")

# --- B: DATA ---------------------------------------------------------------
DATA_ROW <- r; r <- r + 1
put(4, r, "COWS", st_part, formula = TRUE)
label(5, r, "Cows monitored \u2014 the camera watches the whole pen, not only study cows"); G1 <- r; r <- r + 1
put(4, r, "STORAGE_RATE", st_part, formula = TRUE); label(5, r, "$ per cow per month"); G2 <- r; r <- r + 1
put(4, r, "MO_ENROL+MO_FOLLOWUP", st_part, formula = TRUE); label(5, r, "Months"); G3 <- r; r <- r + 1
put(2, DATA_ROW, sprintf("D%d*D%d*D%d", G1, G2, G3), st_cat, formula = TRUE)
label(3, DATA_ROW, "DATA")

# --- B: CONTINGENCY --------------------------------------------------------
CONT_ROW <- r; r <- r + 1
put(3, r, sprintf("B%d+B%d+B%d", PERS_ROW, TRAV_ROW, DATA_ROW), st_item, formula = TRUE)
label(4, r, "Subtotal"); S1 <- r; r <- r + 1
put(3, r, "CONTINGENCY", st_part, formula = TRUE); label(4, r, "Rate"); S2 <- r; r <- r + 1
put(2, CONT_ROW, sprintf("C%d*C%d", S1, S2), st_cat, formula = TRUE)
label(3, CONT_ROW, "CONTINGENCY")

put(1, TOTAL_ROW, sprintf("B%d+B%d+B%d+B%d", PERS_ROW, TRAV_ROW, DATA_ROW, CONT_ROW),
    st_grand, formula = TRUE)
put(2, TOTAL_ROW, "TOTAL BUDGET", createStyle(textDecoration = "bold", fontSize = 13))

# ---- per-cow, per-herd ----------------------------------------------------
r <- r + 1
put(1, r, sprintf("A%d/ENROLLED", TOTAL_ROW), createStyle(numFmt = "$#,##0.00"), formula = TRUE)
label(2, r, "Per enrolled cow"); r <- r + 1
put(1, r, sprintf("A%d/N_HERDS", TOTAL_ROW), createStyle(numFmt = "$#,##0"), formula = TRUE)
label(2, r, "Per farm"); r <- r + 2

# ---- optional lines, same staircase ---------------------------------------
put(1, r, "NOT INCLUDED ABOVE \u2014 set the flag to 1 to fold either into the total",
    st_sect); r <- r + 1
put(1, r, 0, st_in); label(2, r, "Include camera subscription?"); INC_SUB <- r
createNamedRegion(wb, SH, cols = 1, rows = r, name = "INC_SUB", overwrite = TRUE); r <- r + 1
put(1, r, 0.65, st_in); label(2, r, "Subscription $ per cow per month, range 0.65-0.80")
createNamedRegion(wb, SH, cols = 1, rows = r, name = "SUB_RATE", overwrite = TRUE); r <- r + 1
put(2, r, "INC_SUB*COWS*SUB_RATE*(MO_ENROL+MO_FOLLOWUP)", st_cat, formula = TRUE)
label(3, r, "Camera subscription \u2014 larger than everything above combined; settle with Nedap first")
r <- r + 1
put(1, r, 0, st_in); label(2, r, "Include extra trimming?")
createNamedRegion(wb, SH, cols = 1, rows = r, name = "INC_TRIM", overwrite = TRUE); r <- r + 1
put(1, r, 0.406, st_in); label(2, r, "Extra trims per enrolled cow (pilot: 90.4% trimmed vs 49.8%)")
createNamedRegion(wb, SH, cols = 1, rows = r, name = "XTRIM", overwrite = TRUE); r <- r + 1
put(1, r, 18, st_in); label(2, r, "Cost per trim, $")
createNamedRegion(wb, SH, cols = 1, rows = r, name = "TRIM_COST", overwrite = TRUE); r <- r + 1
put(2, r, "INC_TRIM*ENROLLED*(2/3)*XTRIM*TRIM_COST", st_cat, formula = TRUE)
label(3, r, "Extra trimming \u2014 arms 1 and 2 only, total over the study, not annual")
r <- r + 2

put(1, r, "WHAT RUNS WHEN", st_sect); r <- r + 1
put(1, r, paste("Enrolment and follow-up are costed separately because they are different",
                "kinds of work. Farm visits and their travel run through ENROLMENT only \u2014",
                "once a farm has stopped enrolling, follow-up is passive data collection and",
                "needs nobody on site. Project management, data storage and the camera",
                "subscription run across both, so they use MO_ENROL + MO_FOLLOWUP."), st_note)

setColWidths(wb, SH, cols = 1:6, widths = c(14, 15, 15, 15, 58, 12))
freezePane(wb, SH, firstActiveRow = 4)
# activeSheet can still point at an index that removeWorksheet() deleted, and
# worksheetOrder() restores it afterwards - so reset it before reordering.
bud <- which(names(wb) == "Budget")
invisible(activeSheet(wb) <- bud)
invisible(worksheetOrder(wb) <- c(bud, setdiff(seq_along(names(wb)), bud)))
invisible(activeSheet(wb) <- 1)
saveWorkbook(wb, OUT, overwrite = TRUE)
cat("wrote", OUT, "- sheets:", paste(names(wb), collapse = ", "), "\n")
