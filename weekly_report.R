#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
})

TRIAGE_INPUT_CSV <- Sys.getenv("TRIAGE_INPUT_CSV", unset = "triage_v3.csv")
REPORT_OUTPUT_MD <- Sys.getenv("REPORT_OUTPUT_MD", unset = "weekly_report.md")

if (!file.exists(TRIAGE_INPUT_CSV)) {
  stop(sprintf("Triage CSV does not exist: %s", TRIAGE_INPUT_CSV))
}

triage <- read.csv(
  TRIAGE_INPUT_CSV,
  stringsAsFactors = FALSE,
  check.names = FALSE,
  na.strings = c("", "NA")
)

required_columns <- c(
  "title", "abstract_text", "source", "date", "doi", "raw_id",
  "triage_status", "relevant_esm", "empirical_study", "dataset_candidate",
  "data_access_status", "priority", "confidence", "reason"
)
missing_columns <- setdiff(required_columns, names(triage))
if (length(missing_columns) > 0) {
  stop(sprintf("Triage CSV is missing columns: %s", paste(missing_columns, collapse = ", ")))
}

safe_text <- function(value, fallback = "") {
  if (length(value) == 0 || is.na(value[[1]])) {
    return(fallback)
  }
  str_squish(as.character(value[[1]]))
}

markdown_text <- function(value, fallback = "Not stated.") {
  text <- safe_text(value, fallback)
  str_replace_all(text, "\\|", "\\\\|")
}

record_link <- function(row) {
  doi <- safe_text(row[["doi"]])
  raw_id <- safe_text(row[["raw_id"]])

  if (doi != "") {
    return(paste0("https://doi.org/", str_remove(doi, "^https?://(dx\\.)?doi\\.org/")))
  }
  if (str_detect(raw_id, "^https?://")) {
    return(raw_id)
  }
  if (safe_text(row[["source"]]) == "osf_psyarxiv" && raw_id != "") {
    return(paste0("https://osf.io/", str_remove(raw_id, "_v[0-9]+$"), "/"))
  }
  ""
}

priority_order <- c(high = 1L, medium = 2L, low = 3L)
successful <- triage |>
  filter(triage_status == "ok") |>
  mutate(
    priority_rank = unname(priority_order[as.character(priority)]),
    confidence = suppressWarnings(as.numeric(confidence))
  ) |>
  arrange(priority_rank, desc(confidence), desc(date))

relevant <- successful |>
  filter(relevant_esm %in% c(TRUE, "TRUE", "true"))

high_priority <- relevant |>
  filter(priority == "high")
medium_priority <- relevant |>
  filter(priority == "medium")
explicit_open <- relevant |>
  filter(data_access_status == "explicit_open")
not_stated <- relevant |>
  filter(data_access_status == "not_stated")
restricted_or_unclear <- relevant |>
  filter(data_access_status %in% c("explicit_restricted", "unclear"))
errors <- triage |>
  filter(triage_status != "ok")
excluded <- successful |>
  filter(!(relevant_esm %in% c(TRUE, "TRUE", "true")))

source_counts <- triage |>
  count(source, name = "records") |>
  arrange(desc(records))

render_candidate <- function(row) {
  link <- record_link(row)
  title <- markdown_text(row[["title"]], "Untitled candidate")
  title_line <- if (link == "") title else paste0("[", title, "](", link, ")")
  paste0(
    "- **", title_line, "**\n",
    "  - Date: ", markdown_text(row[["date"]], "Unknown"), "\n",
    "  - Source: ", markdown_text(row[["source"]], "Unknown"), "\n",
    "  - Confidence: ", markdown_text(row[["confidence"]], "Unknown"), "\n",
    "  - Dataset candidate: ", markdown_text(row[["dataset_candidate"]], "Unknown"), "\n",
    "  - Data status: ", markdown_text(row[["data_access_status"]], "Unknown"), "\n",
    "  - Reason: ", markdown_text(row[["reason"]])
  )
}

render_section <- function(lines, heading, records) {
  lines <- c(lines, paste0("## ", heading), "")
  if (nrow(records) == 0) {
    return(c(lines, "None.", ""))
  }
  c(lines, unlist(lapply(seq_len(nrow(records)), function(i) render_candidate(records[i, , drop = FALSE]))), "")
}

lines <- c(
  "# Weekly ESM discovery report",
  "",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  paste0("Input: `", TRIAGE_INPUT_CSV, "`"),
  "",
  "## Summary",
  "",
  paste0("- Records fetched for triage: ", nrow(triage)),
  paste0("- Successful classifications: ", nrow(successful)),
  paste0("- Relevant ESM/EMA candidates: ", nrow(relevant)),
  paste0("- Excluded as irrelevant: ", nrow(excluded)),
  paste0("- API or parse errors: ", nrow(errors)),
  "",
  "Source counts:",
  "",
  "| Source | Records |",
  "| --- | ---: |",
  paste0("| ", source_counts$source, " | ", source_counts$records, " |"),
  ""
)

lines <- render_section(lines, "High-priority candidates", high_priority)
lines <- render_section(lines, "Medium-priority candidates", medium_priority)
lines <- render_section(lines, "Explicit open-data evidence", explicit_open)
lines <- render_section(lines, "Relevant, access not stated", not_stated)
lines <- render_section(lines, "Relevant, restricted or unclear access", restricted_or_unclear)

lines <- c(lines, "## Excluded records", "")
if (nrow(excluded) == 0) {
  lines <- c(lines, "None.", "")
} else {
  lines <- c(lines, paste0("Excluded records: ", nrow(excluded), ". They remain in the triage CSV for audit and prompt review.", ""))
}

lines <- c(lines, "## API and parsing errors", "")
if (nrow(errors) == 0) {
  lines <- c(lines, "None.", "")
} else {
  lines <- c(lines, paste0("Errors: ", nrow(errors), ". These rows were not treated as irrelevant.", ""))
  for (i in seq_len(nrow(errors))) {
    row <- errors[i, , drop = FALSE]
    lines <- c(
      lines,
      paste0("- ", markdown_text(row[["title"]], "Untitled candidate"), ": ", markdown_text(row[["error_message"]], "Unknown error"))
    )
  }
  lines <- c(lines, "")
}

writeLines(lines, con = REPORT_OUTPUT_MD, useBytes = TRUE)
message(sprintf("Wrote weekly report to %s", REPORT_OUTPUT_MD))
