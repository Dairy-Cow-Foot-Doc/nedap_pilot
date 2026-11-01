library(tidyverse)
library(rio)

enrolled <- cohort |>
  select(id, first_nedlame_date)

rio::export(enrolled, "enrolled.csv")
