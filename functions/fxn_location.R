library(tidyverse)


# use herd id -------------------
fxn_add_location_event <- function(df) {
  df %>%
    mutate(
      location_event = HERDID
    )
}


# use pen number -----------------------------
fxn_assign_location_event_pen_template <- function(df) {
  df %>%
    mutate(pen_num = parse_number(PEN)) %>%
    mutate(
      location_event = case_when(
        (pen_num == 0) ~ "Pen Zero"
        (pen_num < 100) ~ "Location1",
        (pen_num < 200) ~ "Location2",
        (pen_num < 300) ~ "Location3",
        TRUE ~ "Unknown Location"
      )
    )
}


# location from parenell source file ------------------------------
fxn_assign_location_event_parnell_ANON <- function(df) {
  df %>%
    mutate(
      location_event = paste0("Herd ", str_sub(source_file_path, 18, 22))
    )
}

# location lesion------------------
# Foot codes are searched for in `detect_src`, not in Remark directly.
#
# The search is a substring match, so any foot pair appearing anywhere in the
# remark is picked up - including one that is not a foot at all. XNLFRF is
# XNL (treatment) + F (foot rot) + RF (leg), a SINGLE foot, but "LF" spans the
# treatment's trailing L and the lesion's F, so a naive search invents a left
# front. 559 of 605 XNLF* rows carried that phantom, and every downstream
# analysis inherited it.
#
# Stripping the XNLF prefix before searching fixes it without touching
# anything else: XNLFRF -> RF, XNLFRH -> RH, XNLFLF -> LF (still a real left
# front), XNLFRHRF -> RHRF (genuinely two feet).
#
# Deliberately narrow. Other prefixes are 4-letter treatments followed by real
# feet, so BLKWLFRF really is two feet and LATDLRRR really is two - stripping
# more would delete genuine records.
fxn_strip_lesion_prefix <- function(x) stringr::str_remove(x, "^XNLF")

fxn_detect_location_lesion <- function(df) {
  df %>%
    mutate(detect_src = fxn_strip_lesion_prefix(Remark)) %>%
    mutate(
      detectRR = case_when(
        str_detect(detect_src, "RR|.RR|RR.|.RR.|RH|.RH|RH.|.RH.|ALL|.ALL|ALL.|.ALL.") ~ "RR",
        TRUE ~ ""
      ),
      detectLR = case_when(
        str_detect(detect_src, "LR|.LR|LR.|.LR.|LH|.LH|LH.|.LH.|ALL|.ALL|ALL.|.ALL.") ~ "LR",
        TRUE ~ ""
      ),
      detectRF = case_when(
        str_detect(detect_src, "RF|.RF|RF.|.RF.|BF|.BF|BF.|.BF.|ALL|.ALL|ALL.|.ALL.") ~ "RF",
        TRUE ~ ""
      ),
      detectLF = case_when(
        str_detect(detect_src, "LF|.LF|LF.|.LF.|BF|.BF|BF.|.BF.|ALL|.ALL|ALL.|.ALL.") ~ "LF",
        TRUE ~ ""
      )
    ) %>%
    mutate(locate_lesion = paste0(detectRR, detectLR, detectRF, detectLF))
}


# location lesion------------------
fxn_detect_location_lesion_default <- function(df) {
  df %>%
    mutate(detect_src = fxn_strip_lesion_prefix(Remark)) %>%
    mutate(
      detectRR = case_when(
        str_detect(detect_src, "RR|.RR|RR.|.RR.|RH|.RH|RH.|.RH.|ALL|.ALL|ALL.|.ALL.") ~ "RR",
        TRUE ~ ""
      ),
      detectLR = case_when(
        str_detect(detect_src, "LR|.LR|LR.|.LR.|LH|.LH|LH.|.LH.|ALL|.ALL|ALL.|.ALL.") ~ "LR",
        TRUE ~ ""
      ),
      detectRF = case_when(
        str_detect(detect_src, "RF|.RF|RF.|.RF.|BF|.BF|BF.|.BF.|ALL|.ALL|ALL.|.ALL.") ~ "RF",
        TRUE ~ ""
      ),
      detectLF = case_when(
        str_detect(detect_src, "LF|.LF|LF.|.LF.|BF|.BF|BF.|.BF.|ALL|.ALL|ALL.|.ALL.") ~ "LF",
        TRUE ~ ""
      )
    ) %>%
    mutate(locate_lesion = paste0(detectRR, detectLR, detectRF, detectLF))
}
