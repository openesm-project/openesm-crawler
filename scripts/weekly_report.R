#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
})

TRIAGE_OUTPUT_CSV <- Sys.getenv("TRIAGE_OUTPUT_CSV", unset = "triage_v3.csv")
REPORT_OUTPUT_MD <- Sys.getenv("REPORT_OUTPUT_MD", unset = "weekly_report.md")

if (!file.exists(TRIAGE_OUTPUT_CSV)) {
  stop(sprintf("Triage CSV does not exist: %s", TRIAGE_OUTPUT_CSV))
}

triage <- read.csv(
  TRIAGE_OUTPUT_CSV,
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
# older discovery csvs predate the osf data-link columns.
for (column in c("osf_data_links", "triage_model", "triage_prompt_version")) {
  if (!column %in% names(triage)) triage[[column]] <- NA_character_
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

is_true <- function(x) x %in% c(TRUE, "TRUE", "true")

# split declared osf data links into public links and view-only (review) links.
split_links <- function(links, view_only) {
  vapply(links, function(value) {
    if (is.na(value)) return(NA_character_)
    parts <- str_split(value, ";")[[1]]
    parts <- parts[str_detect(parts, "view_only") == view_only]
    if (length(parts) == 0) NA_character_ else paste(parts, collapse = " ")
  }, character(1), USE.NAMES = FALSE)
}

successful <- triage |>
  filter(triage_status == "ok") |>
  mutate(
    confidence = suppressWarnings(as.numeric(confidence)),
    osf_public_links = split_links(osf_data_links, view_only = FALSE),
    osf_view_only_links = split_links(osf_data_links, view_only = TRUE),
    llm_open = data_access_status == "explicit_open" & is_true(dataset_candidate) & is_true(empirical_study)
  ) |>
  arrange(desc(confidence), desc(date))

relevant <- successful |>
  filter(is_true(relevant_esm))

# a record is listed in the first section it qualifies for, so it appears at most once.
open_candidates <- relevant |>
  filter(!is.na(osf_public_links) | llm_open)
view_only_candidates <- relevant |>
  filter(is.na(osf_public_links), !llm_open, !is.na(osf_view_only_links))
no_evidence <- relevant |>
  filter(is.na(osf_public_links), !llm_open, is.na(osf_view_only_links))
errors <- triage |>
  filter(triage_status != "ok")
excluded <- successful |>
  filter(!is_true(relevant_esm))
models_used <- paste(sort(unique(na.omit(paste(triage$triage_model, triage$triage_prompt_version)))), collapse = ", ")

source_counts <- triage |>
  count(source, name = "records") |>
  arrange(desc(records))

render_candidate <- function(row) {
  link <- record_link(row)
  title <- markdown_text(row[["title"]], "Untitled candidate")
  title_line <- if (link == "") title else paste0("[", title, "](", link, ")")
  evidence <- c(
    if (!is.na(row[["osf_public_links"]])) paste0("OSF data link: ", row[["osf_public_links"]]),
    if (!is.na(row[["osf_view_only_links"]])) paste0("OSF view-only link (review access, may not be public): ", row[["osf_view_only_links"]]),
    if (isTRUE(row[["llm_open"]])) "LLM: explicit open data in abstract"
  )
  paste0(
    "- **", title_line, "**\n",
    "  - Date: ", markdown_text(row[["date"]], "Unknown"), " | Source: ", markdown_text(row[["source"]], "Unknown"),
    " | Confidence: ", markdown_text(row[["confidence"]], "Unknown"), "\n",
    "  - Evidence: ", markdown_text(paste(evidence, collapse = "; "), "None"), "\n",
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
  paste0("Input: `", TRIAGE_OUTPUT_CSV, "`"),
  paste0("Model: ", if (models_used == "") "Unknown" else models_used),
  "",
  "## Summary",
  "",
  paste0("- Records fetched for triage: ", nrow(triage)),
  paste0("- Successful classifications: ", nrow(successful)),
  paste0("- Relevant ESM/EMA candidates: ", nrow(relevant)),
  paste0("  - with open-data evidence (listed below): ", nrow(open_candidates)),
  paste0("  - with an OSF view-only data link only (listed below): ", nrow(view_only_candidates)),
  paste0("  - without open-data evidence (not listed): ", nrow(no_evidence)),
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

lines <- render_section(lines, "Open-data candidates", open_candidates)
lines <- render_section(lines, "Declared data, OSF view-only link", view_only_candidates)

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
