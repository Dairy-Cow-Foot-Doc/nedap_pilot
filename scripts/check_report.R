#!/usr/bin/env Rscript
# ---------------------------------------------------------------------------
# check_report.R - pre-commit checks for the Quarto reports in this project.
#
#   Rscript scripts/check_report.R qmd_reports/report_nedlame_treatment_comparison_fx.qmd
#   Rscript scripts/check_report.R <file.qmd> <render.log>     # also scan a render log
#   Rscript scripts/check_report.R                             # all qmd_reports/*_fx.qmd
#
# Exits 1 if any ERROR is found, 0 otherwise. WARNs never fail the run.
#
# WHY THIS EXISTS
# Four separate breaks reached the rendered page in one editing session on
# 2026-09-10, and not one was a code defect a reviewer would flag:
#
#   1. `::: panel-tabset` opened one line BELOW its first heading, so the table
#      under that heading sat inside the tabset before any tab and Quarto
#      silently dropped it. No error, no warning - the table was simply absent
#      from the page, and had been for weeks.               -> check E
#   2. An inline `r n_ctl_staff` placed five lines ABOVE the chunk computing it.
#      The render halted, and quarto still exited 0.        -> checks G, H
#   3. A dropped `|>` mid-pipeline. The chunk still PARSED (as two statements),
#      so this is not a syntax error; it failed at runtime. -> check D
#   4. `@fig-q2-any-lesion`, a crossref to a label that never existed. Rendered
#      into the page as a literal "?@fig-q2-any-lesion", and reported only as a
#      WARNING, not an error.                               -> checks B, H
#
# The common thread is that a clean exit code is not evidence of a good render.
# Check H therefore treats WARNING lines as findings, and the caller should
# capture the FULL log - piping quarto through `tail` is how #4 got missed.
# See the plan doc's Round 29/30 for the layered-checks argument.
# ---------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
qmd_files <- args[grepl("\\.qmd$", args)]
log_file  <- args[!grepl("\\.qmd$", args)][1]
if (!length(qmd_files)) {
  qmd_files <- Sys.glob("qmd_reports/report_*_fx.qmd")
  if (!length(qmd_files))
    stop("usage: Rscript scripts/check_report.R <file.qmd> [render.log]")
}

n_err <- 0L; n_warn <- 0L
say <- function(kind, check, msg) {
  if (kind == "ERROR") n_err <<- n_err + 1L else n_warn <<- n_warn + 1L
  cat(sprintf("  [%-5s] %s: %s\n", kind, check, msg))
}

# --- chunk extraction; keeps the true file line number of every code line ---
get_chunks <- function(q) {
  fence  <- startsWith(q, "```")
  opens  <- which(fence & startsWith(q, "```{r"))
  closes <- which(fence & !startsWith(q, "```{"))
  out <- list()
  for (s in opens) {
    e <- closes[closes > s][1]; if (is.na(e)) next
    idx  <- if (e - s > 1) (s + 1):(e - 1) else integer(0)
    body <- q[idx]
    is_opt <- startsWith(trimws(body), "#|")
    lab <- grep("label:", body[is_opt], value = TRUE, fixed = TRUE)[1]
    out[[length(out) + 1]] <- list(
      open = s, close = e,
      label = if (is.na(lab)) NA_character_ else trimws(sub(".*label:", "", lab)),
      code  = body[!is_opt],
      code_lines = idx[!is_opt]        # <- true file lines, so G can't be off by one
    )
  }
  out
}

# --- strip string literals, so symbol extraction never reads prose inside "" -
strip_strings <- function(x) {
  x <- gsub('"(\\\\.|[^"\\\\])*"', '""', x)
  gsub("'(\\\\.|[^'\\\\])*'", "''", x)
}

# --- D: a pipeline fragment left with no data argument ----------------------
# `a |> f() |> g()` parses as g(f(a)), so walk the first POSITIONAL argument
# down to the head of the chain. If the head is itself a verb call with no
# positional argument, the pipe that should have fed it was lost.
VERBS <- c("mutate", "filter", "select", "summarize", "summarise", "group_by",
           "ungroup", "arrange", "count", "rename", "distinct", "slice",
           "slice_min", "slice_max", "pivot_wider", "pivot_longer", "ggplot",
           "left_join", "inner_join", "full_join", "anti_join", "semi_join")
chain_head <- function(e) {
  while (is.call(e)) {
    a <- as.list(e)[-1]
    if (!length(a)) return(e)
    nm <- names(a); if (is.null(nm)) nm <- rep("", length(a))
    pos <- which(!nzchar(nm))
    if (!length(pos)) return(e)
    e <- a[[pos[1]]]
  }
  e
}

# --- G: inline `r sym` used above the chunk that assigns sym ---------------
RESERVED <- c("if", "else", "for", "while", "function", "return", "TRUE", "FALSE",
              "NA", "NULL", "Inf", "in", "repeat", "break", "next")
inline_syms <- function(q) {
  out <- list()
  hits <- gregexpr("`r [^`]+`", q)
  for (i in seq_along(q)) {
    if (hits[[i]][1] == -1) next
    for (txt in regmatches(q[i], hits[i])[[1]]) {
      body <- strip_strings(sub("`$", "", sub("^`r\\s*", "", txt)))
      # drop anything immediately followed by "(" - those are function calls
      body <- gsub("[A-Za-z._][A-Za-z0-9._]*\\s*\\(", "(", body)
      # drop named arguments (collapse = , na.rm = ) - they are not objects
      body <- gsub("[A-Za-z._][A-Za-z0-9._]*\\s*=(?!=)", "", body, perl = TRUE)
      # drop $column references - those are columns, not free symbols
      body <- gsub("\\$[A-Za-z0-9._]+", "", body)
      syms <- unique(regmatches(body, gregexpr("[A-Za-z._][A-Za-z0-9._]*", body))[[1]])
      for (s in setdiff(syms, RESERVED))
        out[[length(out) + 1]] <- list(line = i, sym = s)
    }
  }
  out
}

# --- I: names each fxn_build_*() hands back via its closing list(...) -------
# Report objects mostly arrive through list2env(fxn_build_*()), so they are
# never assigned in the .qmd. Without this, an inline `r obj` naming something
# that exists NOWHERE is indistinguishable from a normal function-supplied
# object. Reading the returns closes that gap - it is what would have caught
# `n_truly_never` and `n_pipeline`, both pasted in from the farm report, which
# computes the same quantities under different names.
provided_names <- function(path = "functions/fxn_nedlame_analysis.R") {
  if (!file.exists(path)) return(character(0))
  p <- try(parse(path), silent = TRUE)
  if (inherits(p, "try-error")) return(character(0))
  out <- character(0)
  for (e in p) {
    if (!is.call(e) || !identical(as.character(e[[1]]), "<-")) next
    b <- e[[3]]
    if (!is.call(b) || !identical(as.character(b[[1]]), "function")) next
    fb <- b[[3]]
    st <- if (is.call(fb) && identical(as.character(fb[[1]]), "{")) as.list(fb)[-1] else list(fb)
    last <- st[[length(st)]]
    if (is.call(last) && identical(as.character(last[[1]]), "list"))
      out <- c(out, names(as.list(last)[-1]))
  }
  unique(out[nzchar(out)])
}
FXN_PROVIDED <- provided_names()

for (f in qmd_files) {
  cat("\n==== ", f, " ====\n", sep = "")
  if (!file.exists(f)) { say("ERROR", "file", "does not exist"); next }
  q  <- readLines(f, warn = FALSE)
  ch <- get_chunks(q)
  labs <- vapply(ch, function(x) x$label, character(1))
  known <- labs[!is.na(labs)]

  ## A. duplicate chunk labels
  for (d in unique(known[duplicated(known)]))
    say("ERROR", "A dup-label", sprintf("label '%s' declared more than once", d))

  ## B. dangling crossrefs. Quarto labels are letters/digits/-/_ only, so a
  ##    trailing "." is sentence punctuation and must not be captured.
  used <- unique(sub("^@", "",
    unlist(regmatches(q, gregexpr("@(fig|tbl)-[A-Za-z0-9_-]+", q)))))
  for (u in setdiff(used, known)) {
    ln <- grep(paste0("@", u), q, fixed = TRUE)[1]
    sugg <- if (length(known)) known[which.min(utils::adist(u, known)[1, ])] else "none"
    say("ERROR", "B crossref",
        sprintf("line %d: @%s has no matching label (closest existing: %s)", ln, u, sugg))
  }

  ## C. figure/table chunks whose label prefix disagrees with their output
  for (x in ch) {
    if (is.na(x$label)) next
    code   <- paste(x$code, collapse = " ")
    is_fig <- grepl("ggplot\\(|ggsurvfit\\(", code)
    is_tbl <- grepl("\\bgt\\(|as_gt\\(|kable\\(|tbl_summary\\(", code)
    if (is_fig && !startsWith(x$label, "fig-"))
      say("WARN", "C label", sprintf("'%s' draws a figure but is not fig-*", x$label))
    if (is_tbl && !startsWith(x$label, "tbl-"))
      say("WARN", "C label", sprintf("'%s' draws a table but is not tbl-*", x$label))
    if (startsWith(x$label, "fig-") && !is_fig)
      say("WARN", "C label", sprintf("'%s' is fig-* but draws no figure", x$label))
    if (startsWith(x$label, "tbl-") && !is_tbl)
      say("WARN", "C label", sprintf("'%s' is tbl-* but draws no table", x$label))
  }

  ## D. unparseable chunks, and dangling pipeline fragments
  for (x in ch) {
    if (!length(x$code)) next
    p <- try(parse(text = paste(x$code, collapse = "\n")), silent = TRUE)
    if (inherits(p, "try-error")) {
      say("ERROR", "D parse", sprintf("chunk '%s' does not parse: %s", x$label,
          conditionMessage(attr(p, "condition"))))
      next
    }
    for (e in as.list(p)) {
      h <- chain_head(e)
      if (is.call(h) && as.character(h[[1]])[1] %in% VERBS)
        say("ERROR", "D pipe",
            sprintf("chunk '%s': `%s(...)` has no data argument - a `|>` was probably dropped",
                    x$label, as.character(h[[1]])[1]))
    }
  }

  ## E. a panel-tabset must open immediately before its first tab heading
  for (i in which(trimws(q) == "::: panel-tabset")) {
    j <- i + 1
    while (j <= length(q) && !nzchar(trimws(q[j]))) j <- j + 1
    if (j <= length(q) && !grepl("^#{1,6} ", q[j]))
      say("ERROR", "E tabset",
          sprintf("line %d: content sits before the first tab heading (%s...) - Quarto drops it",
                  i, substr(trimws(q[j]), 1, 32)))
  }

  ## F. div fence balance
  op <- sum(grepl("^::: *[a-zA-Z]", q)); cl <- sum(trimws(q) == ":::")
  if (op != cl) say("ERROR", "F fences", sprintf("%d opening ::: vs %d closing :::", op, cl))

  ## G. an inline value used above the chunk that assigns it.
  ##    Only `<-` counts: `=` would also match named arguments in multi-line calls.
  assign_line <- list()
  for (x in ch) for (k in seq_along(x$code)) {
    if (grepl("^\\s*[A-Za-z._][A-Za-z0-9._]*\\s*<-", x$code[k])) {
      s  <- trimws(sub("\\s*<-.*$", "", x$code[k]))
      ln <- x$code_lines[k]
      if (is.null(assign_line[[s]]) || ln < assign_line[[s]]) assign_line[[s]] <- ln
    }
  }
  in_chunk <- rep(FALSE, length(q))
  for (x in ch) in_chunk[x$open:x$close] <- TRUE
  for (h in inline_syms(q)) {
    if (in_chunk[h$line]) next
    a <- assign_line[[h$sym]]
    if (!is.null(a) && a > h$line)
      say("ERROR", "G forward-ref",
          sprintf("line %d uses `%s`, first assigned at line %d (below it)", h$line, h$sym, a))
  }

  ## I. an inline `r obj` naming something defined nowhere at all
  known_objs <- unique(c(names(assign_line), FXN_PROVIDED, "params"))
  if (length(FXN_PROVIDED)) {
    seen <- character(0)
    for (h in inline_syms(q)) {
      if (in_chunk[h$line] || h$sym %in% known_objs || h$sym %in% seen) next
      seen <- c(seen, h$sym)
      say("ERROR", "I undefined",
          sprintf("line %d: `%s` is assigned nowhere and returned by no fxn_build_*()",
                  h$line, h$sym))
    }
  } else {
    say("WARN", "I undefined",
        "functions/fxn_nedlame_analysis.R not readable - skipped the undefined-object check")
  }

  cat(sprintf("  (%d chunks, %d labelled, %d crossrefs)\n", length(ch), length(known), length(used)))
}

## H. render log. Objects supplied by list2env(fxn_build_*()) are invisible to
##    check G, so the log is the only place those forward references surface.
if (!is.na(log_file) && file.exists(log_file)) {
  cat("\n==== render log:", log_file, "====\n")
  lg <- readLines(log_file, warn = FALSE)
  hard <- grep("Execution halted|^Error|Quitting from|not found", lg, value = TRUE)
  soft <- grep("WARNING|Unable to resolve|Warning message", lg, value = TRUE)
  for (l in unique(hard)) say("ERROR", "H log", trimws(l))
  for (l in unique(soft)) say("WARN",  "H log", trimws(l))
  if (!length(hard) && !length(soft)) cat("  clean\n")
} else if (!is.na(log_file)) {
  say("WARN", "H log", paste("log file not found:", log_file))
}

cat(sprintf("\n%d ERROR, %d WARN\n", n_err, n_warn))
if (n_err > 0) quit(status = 1)
