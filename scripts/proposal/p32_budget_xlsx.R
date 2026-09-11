# Builds the budget as a LIVE Excel workbook: every figure is an Excel formula
# referring to named input cells, so changing an input on the Inputs sheet
# recalculates the whole budget. Nothing is hard-coded downstream.
#
# Writes design/budget_nedap_3arm.xlsx. Re-run to regenerate; the workbook is an
# output, so edits made in Excel are lost on the next run. Change defaults here.

setwd("C:/Github/nedap_pilot")
suppressPackageStartupMessages(library(openxlsx))

OUT <- "design/budget_nedap_3arm.xlsx"

# ---- styles ----------------------------------------------------------------
st_title   <- createStyle(fontSize = 14, textDecoration = "bold")
st_head    <- createStyle(textDecoration = "bold", fgFill = "#D9E2F3", border = "TopBottom")
st_section <- createStyle(textDecoration = "bold", fontSize = 11)
st_input   <- createStyle(fgFill = "#FFF2CC", border = "TopBottomLeftRight",
                          borderColour = "#BF9000", numFmt = "#,##0")
st_input_d <- createStyle(fgFill = "#FFF2CC", border = "TopBottomLeftRight",
                          borderColour = "#BF9000", numFmt = "0.00")
st_input_p <- createStyle(fgFill = "#FFF2CC", border = "TopBottomLeftRight",
                          borderColour = "#BF9000", numFmt = "0%")
st_money   <- createStyle(numFmt = "$#,##0")
st_money_b <- createStyle(numFmt = "$#,##0", textDecoration = "bold")
st_total   <- createStyle(numFmt = "$#,##0", textDecoration = "bold", border = "Top")
st_grand   <- createStyle(numFmt = "$#,##0", textDecoration = "bold", fontSize = 12,
                          border = "TopBottom", fgFill = "#E2EFDA")
st_note    <- createStyle(fontColour = "#7F7F7F", wrapText = TRUE, valign = "top")
st_wrap    <- createStyle(wrapText = TRUE, valign = "top")

wb <- createWorkbook()

# ===========================================================================
# INPUTS
# ===========================================================================
addWorksheet(wb, "Inputs")
writeData(wb, "Inputs", "Budget inputs — change anything in a yellow cell", startCol = 1, startRow = 1)
addStyle(wb, "Inputs", st_title, rows = 1, cols = 1)
writeData(wb, "Inputs",
          "Every other sheet is formulas referring to these cells. Nothing downstream is typed in.",
          startCol = 1, startRow = 2)
addStyle(wb, "Inputs", st_note, rows = 2, cols = 1)

# name, value, unit, note, format
inp <- list(
  c("STUDY SHAPE", "", "", ""),
  c("N_HERDS",            6,     "herds",        "Four is the stated minimum; six is the design"),
  c("HERD_SIZE",          3000,  "cows",         "Midpoint of the 2,000-5,000 eligibility range"),
  c("MONTHS",             18,    "months",       "6 enrolment + 12 follow-up on the last cow"),
  c("N_INVESTIGATORS",    3,     "people",       "Gerard (West Coast), New York, Midwest"),
  c("ENROLLED",           6000,  "cows",         "Used for cost-per-cow and the storage alternative"),
  c("RATES", "", "", ""),
  c("DAY_RATE",           2500,  "$ / day",      "Per investigator per visit-day"),
  c("ANALYSIS_DAYS",      15,    "days",         "Three weeks of analysis and reporting"),
  c("PM_DAYS_PER_MONTH",  1,     "days / month", "Project management, whole life of the project"),
  c("STORAGE_RATE",       0.06,  "$ / cow / mo", "Data storage"),
  c("STORAGE_BASIS",      1,     "1 or 2",       "1 = whole monitored herd, 2 = enrolled cows only"),
  c("CONTINGENCY",        0.10,  "fraction",     "Applied to the subtotal"),
  c("TRAVEL UNIT COSTS", "", "", ""),
  c("CAR_DAY_RATE",       80,    "$ / day",      "Rental car"),
  c("NIGHT_RATE",         180,   "$ / night",    "Airbnb or hotel"),
  c("PER_DIEM",           80,    "$ / day",      "Meals and incidentals"),
  c("MONTHLY_TRIP_DRIVE", 350,   "$ / trip",     "Mileage and meals, one monthly trip covering both farms"),
  c("MONTHLY_ON_FRAC",    0.5,   "fraction",     "Share of monthly trips needing an overnight"),
  c("OPTIONAL LINES", "", "", ""),
  c("INC_SUBSCRIPTION",   0,     "1 or 0",       "Include the camera subscription in the total?"),
  c("SUB_RATE",           0.65,  "$ / cow / mo", "Camera subscription, reported range 0.65-0.80"),
  c("INC_TRIMMING",       0,     "1 or 0",       "Include the extra trimming the protocol causes?"),
  c("EXTRA_TRIMS_ALERT",  0.406, "per enrolled", "Pilot: trimmed arm 90.4% vs control 49.8%"),
  c("PROTOCOL_ARMS_FRAC", 0.667, "fraction",     "Arms 1 and 2 of three are trimmed by protocol"),
  c("TRIM_COST",          18,    "$ / trim",     "Stated assumption; range 15-20")
)

hdr <- 4
writeData(wb, "Inputs", data.frame(Input = "Input", Value = "Value", Unit = "Unit", Note = "Note"),
          startCol = 1, startRow = hdr, colNames = FALSE)
addStyle(wb, "Inputs", st_head, rows = hdr, cols = 1:4, gridExpand = TRUE)

r <- hdr
named <- list()
for (row in inp) {
  r <- r + 1
  if (row[[2]] == "") {                     # section divider
    writeData(wb, "Inputs", row[[1]], startCol = 1, startRow = r)
    addStyle(wb, "Inputs", st_section, rows = r, cols = 1)
    next
  }
  writeData(wb, "Inputs", row[[1]], startCol = 1, startRow = r)
  writeData(wb, "Inputs", as.numeric(row[[2]]), startCol = 2, startRow = r)
  writeData(wb, "Inputs", row[[3]], startCol = 3, startRow = r)
  writeData(wb, "Inputs", row[[4]], startCol = 4, startRow = r)
  v <- as.numeric(row[[2]])
  sty <- if (row[[1]] %in% c("CONTINGENCY", "MONTHLY_ON_FRAC")) st_input_p
         else if (v < 10 && v != round(v)) st_input_d else st_input
  addStyle(wb, "Inputs", sty, rows = r, cols = 2)
  addStyle(wb, "Inputs", st_note, rows = r, cols = 4)
  createNamedRegion(wb, "Inputs", cols = 2, rows = r, name = row[[1]])
  named[[row[[1]]]] <- r
}

# derived, also named so the sheets can use them
r <- r + 2
writeData(wb, "Inputs", "DERIVED — do not edit", startCol = 1, startRow = r)
addStyle(wb, "Inputs", st_section, rows = r, cols = 1)
derived <- list(
  c("FARMS_EACH",     "N_HERDS/N_INVESTIGATORS",  "farms per investigator"),
  c("HALF_DAY",       "DAY_RATE/2",               "$ per half-day visit"),
  c("COWS_MONITORED", "N_HERDS*HERD_SIZE",        "cows the camera watches")
)
for (d in derived) {
  r <- r + 1
  writeData(wb, "Inputs", d[[1]], startCol = 1, startRow = r)
  writeFormula(wb, "Inputs", paste0("=", d[[2]]), startCol = 2, startRow = r)
  writeData(wb, "Inputs", d[[3]], startCol = 4, startRow = r)
  addStyle(wb, "Inputs", st_note, rows = r, cols = 4)
  createNamedRegion(wb, "Inputs", cols = 2, rows = r, name = d[[1]])
}
setColWidths(wb, "Inputs", cols = 1:4, widths = c(22, 12, 14, 62))
freezePane(wb, "Inputs", firstActiveRow = hdr + 1)

# ===========================================================================
# helper: write a line-item sheet
# ===========================================================================
line_sheet <- function(sheet, title, intro, rows, total_label = "Total") {
  addWorksheet(wb, sheet)
  writeData(wb, sheet, title, startCol = 1, startRow = 1)
  addStyle(wb, sheet, st_title, rows = 1, cols = 1)
  writeData(wb, sheet, intro, startCol = 1, startRow = 2)
  addStyle(wb, sheet, st_note, rows = 2, cols = 1)
  writeData(wb, sheet, data.frame(a = "Item", b = "Basis", c = "Cost"),
            startCol = 1, startRow = 4, colNames = FALSE)
  addStyle(wb, sheet, st_head, rows = 4, cols = 1:3, gridExpand = TRUE)
  rr <- 4
  first <- NA
  for (x in rows) {
    rr <- rr + 1
    writeData(wb, sheet, x[[1]], startCol = 1, startRow = rr)
    writeData(wb, sheet, x[[2]], startCol = 2, startRow = rr)
    writeFormula(wb, sheet, paste0("=", x[[3]]), startCol = 3, startRow = rr)
    addStyle(wb, sheet, st_money, rows = rr, cols = 3)
    addStyle(wb, sheet, st_wrap, rows = rr, cols = 2)
    if (is.na(first)) first <- rr
  }
  rr <- rr + 1
  writeData(wb, sheet, total_label, startCol = 1, startRow = rr)
  addStyle(wb, sheet, st_section, rows = rr, cols = 1)
  writeFormula(wb, sheet, sprintf("=SUM(C%d:C%d)", first, rr - 1), startCol = 3, startRow = rr)
  addStyle(wb, sheet, st_total, rows = rr, cols = 3)
  setColWidths(wb, sheet, cols = 1:3, widths = c(34, 56, 14))
  createNamedRegion(wb, sheet, cols = 3, rows = rr, name = paste0(toupper(sheet), "_TOTAL"))
  rr
}

# ===========================================================================
# PERSONNEL
# ===========================================================================
line_sheet("Personnel", "Personnel",
  "Costed at DAY_RATE per investigator per visit-day, half that for a half-day visit.",
  list(
    list("Initial farm visits",
         "Gerard at all six farms, each collaborator joining at their own two: N_HERDS + 2*FARMS_EACH visit-days",
         "(N_HERDS + 2*FARMS_EACH) * DAY_RATE"),
    list("Monthly farm visits",
         "N_INVESTIGATORS x FARMS_EACH x MONTHS half-days",
         "N_INVESTIGATORS * FARMS_EACH * MONTHS * HALF_DAY"),
    list("Analysis and reporting",
         "ANALYSIS_DAYS at the day rate",
         "ANALYSIS_DAYS * DAY_RATE"),
    list("Project management",
         "PM_DAYS_PER_MONTH x MONTHS at the day rate",
         "PM_DAYS_PER_MONTH * MONTHS * DAY_RATE")
  ))

# ===========================================================================
# TRAVEL - initial trips get their own editable component table
# ===========================================================================
addWorksheet(wb, "Travel")
writeData(wb, "Travel", "Travel", startCol = 1, startRow = 1)
addStyle(wb, "Travel", st_title, rows = 1, cols = 1)
writeData(wb, "Travel",
  "Yellow cells are per-trip counts - edit them directly. Rates live on the Inputs sheet. Deliberately liberal.",
  startCol = 1, startRow = 2)
addStyle(wb, "Travel", st_note, rows = 2, cols = 1)

writeData(wb, "Travel", "Initial round — one visit to every farm", startCol = 1, startRow = 4)
addStyle(wb, "Travel", st_section, rows = 4, cols = 1)
writeData(wb, "Travel",
          data.frame(a = "Trip", b = "Airfare", c = "Car days", d = "Nights",
                     e = "Per-diem days", f = "Mileage/other", g = "Cost"),
          startCol = 1, startRow = 5, colNames = FALSE)
addStyle(wb, "Travel", st_head, rows = 5, cols = 1:7, gridExpand = TRUE)

trips <- list(
  c("Gerard, Vancouver to Buffalo — both NY farms",   800, 4, 3, 4, 0),
  c("Gerard, Vancouver to Denver — both Midwest farms", 650, 4, 3, 4, 0),
  c("Gerard, West Coast — his own two farms",           0, 0, 2, 3, 400),
  c("New York collaborator — regional",                 0, 0, 1, 2, 350),
  c("Midwest collaborator — regional",                  0, 0, 1, 2, 350)
)
r <- 5
for (t in trips) {
  r <- r + 1
  writeData(wb, "Travel", t[[1]], startCol = 1, startRow = r)
  for (k in 2:6) writeData(wb, "Travel", as.numeric(t[[k]]), startCol = k, startRow = r)
  addStyle(wb, "Travel", st_input, rows = r, cols = 2:6, gridExpand = TRUE)
  writeFormula(wb, "Travel",
    sprintf("=B%d + C%d*CAR_DAY_RATE + D%d*NIGHT_RATE + E%d*PER_DIEM + F%d", r, r, r, r, r),
    startCol = 7, startRow = r)
  addStyle(wb, "Travel", st_money, rows = r, cols = 7)
}
r_init_first <- 6; r_init_last <- r
r <- r + 1
writeData(wb, "Travel", "Initial round total", startCol = 1, startRow = r)
addStyle(wb, "Travel", st_section, rows = r, cols = 1)
writeFormula(wb, "Travel", sprintf("=SUM(G%d:G%d)", r_init_first, r_init_last), startCol = 7, startRow = r)
addStyle(wb, "Travel", st_total, rows = r, cols = 7)
r_init_total <- r

r <- r + 2
writeData(wb, "Travel", "Monthly round — each investigator covers both their farms in one day-trip",
          startCol = 1, startRow = r)
addStyle(wb, "Travel", st_section, rows = r, cols = 1)
r <- r + 1
writeData(wb, "Travel", data.frame(a = "Item", b = "Basis", c = "Cost"),
          startCol = 1, startRow = r, colNames = FALSE)
addStyle(wb, "Travel", st_head, rows = r, cols = 1:3, gridExpand = TRUE)
mth <- list(
  list("Mileage and meals", "N_INVESTIGATORS x MONTHS trips at MONTHLY_TRIP_DRIVE",
       "N_INVESTIGATORS * MONTHS * MONTHLY_TRIP_DRIVE"),
  list("Overnight stays", "MONTHLY_ON_FRAC of those trips at NIGHT_RATE",
       "N_INVESTIGATORS * MONTHS * MONTHLY_ON_FRAC * NIGHT_RATE")
)
r_m_first <- r + 1
for (m in mth) {
  r <- r + 1
  writeData(wb, "Travel", m[[1]], startCol = 1, startRow = r)
  writeData(wb, "Travel", m[[2]], startCol = 2, startRow = r)
  writeFormula(wb, "Travel", paste0("=", m[[3]]), startCol = 3, startRow = r)
  addStyle(wb, "Travel", st_money, rows = r, cols = 3)
  addStyle(wb, "Travel", st_wrap, rows = r, cols = 2)
}
r <- r + 1
writeData(wb, "Travel", "Monthly round total", startCol = 1, startRow = r)
addStyle(wb, "Travel", st_section, rows = r, cols = 1)
writeFormula(wb, "Travel", sprintf("=SUM(C%d:C%d)", r_m_first, r - 1), startCol = 3, startRow = r)
addStyle(wb, "Travel", st_total, rows = r, cols = 3)
r_mth_total <- r

r <- r + 2
writeData(wb, "Travel", "TRAVEL TOTAL", startCol = 1, startRow = r)
addStyle(wb, "Travel", st_section, rows = r, cols = 1)
writeFormula(wb, "Travel", sprintf("=G%d + C%d", r_init_total, r_mth_total), startCol = 3, startRow = r)
addStyle(wb, "Travel", st_grand, rows = r, cols = 3)
createNamedRegion(wb, "Travel", cols = 3, rows = r, name = "TRAVEL_TOTAL")
setColWidths(wb, "Travel", cols = 1:7, widths = c(44, 11, 11, 10, 14, 15, 14))

# ===========================================================================
# DATA
# ===========================================================================
line_sheet("Data", "Data storage",
  paste("STORAGE_BASIS on the Inputs sheet switches between charging the whole monitored herd (1)",
        "and enrolled cows only (2). The camera watches every cow in the pen, so 1 is the planning basis."),
  list(
    list("Storage",
         "IF whole herd: COWS_MONITORED x STORAGE_RATE x MONTHS. IF enrolled only: ENROLLED x STORAGE_RATE x MONTHS",
         "IF(STORAGE_BASIS=1, COWS_MONITORED, ENROLLED) * STORAGE_RATE * MONTHS")
  ))
writeData(wb, "Data", "For reference — the basis not chosen", startCol = 1, startRow = 8)
addStyle(wb, "Data", st_section, rows = 8, cols = 1)
writeData(wb, "Data", "Whole monitored herd", startCol = 1, startRow = 9)
writeFormula(wb, "Data", "=COWS_MONITORED*STORAGE_RATE*MONTHS", startCol = 3, startRow = 9)
writeData(wb, "Data", "Enrolled cows only", startCol = 1, startRow = 10)
writeFormula(wb, "Data", "=ENROLLED*STORAGE_RATE*MONTHS", startCol = 3, startRow = 10)
writeData(wb, "Data", "Difference — worth asking Nedap which it is", startCol = 1, startRow = 11)
writeFormula(wb, "Data", "=C9-C10", startCol = 3, startRow = 11)
addStyle(wb, "Data", st_money, rows = 9:11, cols = 3, gridExpand = TRUE)

# ===========================================================================
# SUMMARY
# ===========================================================================
addWorksheet(wb, "Summary")
writeData(wb, "Summary", "Preliminary budget — three-arm SmartSight study", startCol = 1, startRow = 1)
addStyle(wb, "Summary", st_title, rows = 1, cols = 1)
writeData(wb, "Summary",
  "All formulas. Change an input on the Inputs sheet and every figure here updates.",
  startCol = 1, startRow = 2)
addStyle(wb, "Summary", st_note, rows = 2, cols = 1)

writeData(wb, "Summary", data.frame(a = "Category", b = "Cost", c = "Share"),
          startCol = 1, startRow = 4, colNames = FALSE)
addStyle(wb, "Summary", st_head, rows = 4, cols = 1:3, gridExpand = TRUE)
cats <- list(c("Personnel", "PERSONNEL_TOTAL"), c("Travel", "TRAVEL_TOTAL"), c("Data", "DATA_TOTAL"))
r <- 4
for (c_ in cats) {
  r <- r + 1
  writeData(wb, "Summary", c_[[1]], startCol = 1, startRow = r)
  writeFormula(wb, "Summary", paste0("=", c_[[2]]), startCol = 2, startRow = r)
  writeFormula(wb, "Summary", sprintf("=B%d/$B$8", r), startCol = 3, startRow = r)
  addStyle(wb, "Summary", st_money, rows = r, cols = 2)
  addStyle(wb, "Summary", createStyle(numFmt = "0%"), rows = r, cols = 3)
}
r <- r + 1
writeData(wb, "Summary", "Subtotal", startCol = 1, startRow = r)
writeFormula(wb, "Summary", "=SUM(B5:B7)", startCol = 2, startRow = r)
addStyle(wb, "Summary", st_total, rows = r, cols = 2)
r <- r + 1
writeData(wb, "Summary", "Contingency", startCol = 1, startRow = r)
writeFormula(wb, "Summary", "=B8*CONTINGENCY", startCol = 2, startRow = r)
addStyle(wb, "Summary", st_money, rows = r, cols = 2)
r <- r + 1
writeData(wb, "Summary", "Optional lines (see below)", startCol = 1, startRow = r)
writeFormula(wb, "Summary", "=B16+B17", startCol = 2, startRow = r)
addStyle(wb, "Summary", st_money, rows = r, cols = 2)
r <- r + 1
writeData(wb, "Summary", "TOTAL", startCol = 1, startRow = r)
writeFormula(wb, "Summary", "=B8+B9+B10", startCol = 2, startRow = r)
addStyle(wb, "Summary", st_grand, rows = r, cols = 2)

writeData(wb, "Summary", "Per enrolled cow", startCol = 1, startRow = 13)
writeFormula(wb, "Summary", "=B11/ENROLLED", startCol = 2, startRow = 13)
writeData(wb, "Summary", "Per herd", startCol = 1, startRow = 14)
writeFormula(wb, "Summary", "=B11/N_HERDS", startCol = 2, startRow = 14)
addStyle(wb, "Summary", createStyle(numFmt = "$#,##0.00"), rows = 13, cols = 2)
addStyle(wb, "Summary", st_money, rows = 14, cols = 2)

writeData(wb, "Summary", "Optional — set the include flag to 1 on the Inputs sheet",
          startCol = 1, startRow = 15)
addStyle(wb, "Summary", st_section, rows = 15, cols = 1)
writeData(wb, "Summary", "Camera subscription", startCol = 1, startRow = 16)
writeFormula(wb, "Summary", "=INC_SUBSCRIPTION*COWS_MONITORED*SUB_RATE*MONTHS",
             startCol = 2, startRow = 16)
writeData(wb, "Summary",
  "At the full monitored herd. Larger than everything above combined, so settle with Nedap first.",
  startCol = 3, startRow = 16)
writeData(wb, "Summary", "Extra trimming the protocol causes", startCol = 1, startRow = 17)
writeFormula(wb, "Summary",
  "=INC_TRIMMING*ENROLLED*PROTOCOL_ARMS_FRAC*EXTRA_TRIMS_ALERT*TRIM_COST",
  startCol = 2, startRow = 17)
writeData(wb, "Summary",
  paste("Total over the study, not per year. Only enrolled cows in arms 1 and 2 are trimmed by protocol,",
        "so this is not a whole-herd cost. A real farm cost the arms do not share equally, and who pays is open."),
  startCol = 3, startRow = 17)
addStyle(wb, "Summary", st_money, rows = 16:17, cols = 2, gridExpand = TRUE)
addStyle(wb, "Summary", st_note, rows = 16:17, cols = 3, gridExpand = TRUE)

writeData(wb, "Summary", "Still not costed anywhere", startCol = 1, startRow = 19)
addStyle(wb, "Summary", st_section, rows = 19, cols = 1)
for (k in seq_along(nc <- c(
  "Farm compensation or incentive payments",
  "Publication and open-access charges",
  "Statistical consulting beyond the analysis days above",
  "Institutional overhead — depends on whose institution holds the award")))
  writeData(wb, "Summary", nc[k], startCol = 1, startRow = 19 + k)

setColWidths(wb, "Summary", cols = 1:3, widths = c(36, 16, 70))

invisible(worksheetOrder(wb) <- c(5, 1, 2, 3, 4))
invisible(activeSheet(wb) <- 5)
saveWorkbook(wb, OUT, overwrite = TRUE)
cat("wrote", OUT, "\n")
