#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(httr2)
  library(jsonlite)
  library(dplyr)
  library(stringr)
  library(purrr)
  library(cli)
})

# This script sends titles and abstracts to an OpenAI-compatible API.
# It does not send full text, create GitHub issues, or send email.

LLM_API_KEY <- Sys.getenv("LLM_API_KEY", unset = "")
LLM_BASE_URL <- Sys.getenv("LLM_BASE_URL", unset = "https://chat-ai.academiccloud.de/v1")
LLM_MODEL <- Sys.getenv("LLM_MODEL", unset = "meta-llama-3.1-8b-instruct")
TRIAGE_INPUT_CSV <- Sys.getenv("TRIAGE_INPUT_CSV", unset = "candidates.csv")
TRIAGE_OUTPUT_CSV <- Sys.getenv("TRIAGE_OUTPUT_CSV", unset = paste0("triage_", Sys.Date(), ".csv"))
LLM_MAX_TOKENS <- as.integer(Sys.getenv("LLM_MAX_TOKENS", unset = "400"))
LLM_TEMPERATURE <- as.numeric(Sys.getenv("LLM_TEMPERATURE", unset = "0"))
LLM_DELAY_SECONDS <- as.numeric(Sys.getenv("LLM_DELAY_SECONDS", unset = "1"))
LLM_MAX_ABSTRACT_CHARS <- as.integer(Sys.getenv("LLM_MAX_ABSTRACT_CHARS", unset = "12000"))
MAX_RETRIES <- 5L
BACKOFF_BASE_SECONDS <- 1
BACKOFF_MAX_SECONDS <- 60
RETRY_STATUS_CODES <- c(408L, 429L, 500L, 502L, 503L, 504L)
TRIAGE_PROMPT_VERSION <- "v1"

if (LLM_API_KEY == "") {
  stop("Set LLM_API_KEY before running the triage script.")
}
if (!file.exists(TRIAGE_INPUT_CSV)) {
  stop(sprintf("Input CSV does not exist: %s", TRIAGE_INPUT_CSV))
}
if (file.exists(TRIAGE_OUTPUT_CSV)) {
  stop(sprintf("Output CSV already exists; refusing to overwrite: %s", TRIAGE_OUTPUT_CSV))
}
if (!is.finite(LLM_MAX_TOKENS) || LLM_MAX_TOKENS < 200L) {
  stop("LLM_MAX_TOKENS must be at least 200.")
}
if (!is.finite(LLM_TEMPERATURE) || LLM_TEMPERATURE < 0 || LLM_TEMPERATURE > 2) {
  stop("LLM_TEMPERATURE must be between 0 and 2.")
}
if (!is.finite(LLM_DELAY_SECONDS) || LLM_DELAY_SECONDS < 0) {
  stop("LLM_DELAY_SECONDS must be zero or greater.")
}
if (!is.finite(LLM_MAX_ABSTRACT_CHARS) || LLM_MAX_ABSTRACT_CHARS < 100L) {
  stop("LLM_MAX_ABSTRACT_CHARS must be at least 100.")
}

candidates <- read.csv(
  TRIAGE_INPUT_CSV,
  stringsAsFactors = FALSE,
  check.names = FALSE,
  na.strings = c("", "NA")
)

required_columns <- c("title", "abstract_text")
missing_columns <- setdiff(required_columns, names(candidates))
if (length(missing_columns) > 0) {
  stop(sprintf("Input CSV is missing required columns: %s", paste(missing_columns, collapse = ", ")))
}

safe_text <- function(value) {
  if (length(value) == 0 || is.na(value[[1]])) {
    return("")
  }
  str_squish(as.character(value[[1]]))
}

json_value <- function(payload, field) {
  if (!field %in% names(payload)) {
    stop(sprintf("Missing JSON field: %s", field))
  }
  payload[[field]]
}

parse_boolean <- function(value, field) {
  if (is.logical(value) && length(value) == 1L && !is.na(value)) {
    return(value)
  }
  if (is.character(value) && length(value) == 1L && value %in% c("true", "false")) {
    return(identical(value, "true"))
  }
  stop(sprintf("Invalid boolean field: %s", field))
}

parse_choice <- function(value, field, choices) {
  if (!is.character(value) || length(value) != 1L || is.na(value) || !value %in% choices) {
    stop(sprintf("Invalid %s; expected one of: %s", field, paste(choices, collapse = ", ")))
  }
  value
}

parse_confidence <- function(value) {
  confidence <- suppressWarnings(as.numeric(value))
  if (length(confidence) != 1L || is.na(confidence) || confidence < 0 || confidence > 1) {
    stop("Invalid confidence; expected a number from 0 to 1.")
  }
  confidence
}

get_retry_after_seconds <- function(response) {
  headers <- tryCatch(resp_headers(response), error = function(e) NULL)
  if (is.null(headers)) {
    return(NA_real_)
  }
  retry_after <- headers[["retry-after"]]
  if (is.null(retry_after)) {
    retry_after <- headers[["Retry-After"]]
  }
  if (is.null(retry_after) || length(retry_after) == 0) {
    return(NA_real_)
  }
  suppressWarnings(as.numeric(retry_after[[1]]))
}

request_with_retries <- function(request_object) {
  for (attempt in seq_len(MAX_RETRIES)) {
    response <- tryCatch(req_perform(request_object), error = function(error) error)

    if (inherits(response, "error")) {
      if (attempt == MAX_RETRIES) {
        stop(response$message)
      }
      wait_seconds <- min(BACKOFF_MAX_SECONDS, BACKOFF_BASE_SECONDS * 2 ^ (attempt - 1L)) + runif(1, 0, 0.5)
      cli::cli_warn("Request error on attempt {attempt}; retrying in {sprintf('%.2f', wait_seconds)}s")
      Sys.sleep(wait_seconds)
      next
    }

    status <- resp_status(response)
    if (status %in% RETRY_STATUS_CODES) {
      if (attempt == MAX_RETRIES) {
        stop(sprintf("API returned HTTP %d after retries", status))
      }
      retry_after <- get_retry_after_seconds(response)
      exponential_wait <- min(BACKOFF_MAX_SECONDS, BACKOFF_BASE_SECONDS * 2 ^ (attempt - 1L))
      wait_seconds <- max(exponential_wait, retry_after, na.rm = TRUE) + runif(1, 0, 0.5)
      cli::cli_warn("API returned HTTP {status} on attempt {attempt}; retrying in {sprintf('%.2f', wait_seconds)}s")
      Sys.sleep(wait_seconds)
      next
    }

    if (status >= 400L) {
      stop(sprintf("API returned non-retryable HTTP %d", status))
    }
    return(response)
  }
}

build_prompt <- function(title, abstract, source, date, identifier) {
  abstract_text <- if (abstract == "") "[No abstract available; use title only and mark uncertain judgments accordingly.]" else abstract
  if (nchar(abstract_text) > LLM_MAX_ABSTRACT_CHARS) {
    abstract_text <- paste0(str_sub(abstract_text, 1, LLM_MAX_ABSTRACT_CHARS), " [abstract truncated]")
  }

  paste0(
    "Classify one literature-discovery candidate for an ESM/EMA dataset search. ",
    "Use only the supplied metadata. Do not infer open data from the existence of a DOI. ",
    "If the abstract is missing or evidence is insufficient, use conservative values and explain the uncertainty. ",
    "Return exactly one JSON object and no surrounding prose.\n\n",
    "Required JSON schema:\n",
    '{"relevant_esm":true,"empirical_study":true,"data_openly_available":false,',
    '"data_access_route":"unclear","priority":"medium","confidence":0.5,',
    '"reason":"short evidence-based explanation"}\n\n',
    "Allowed values: data_access_route = open, request, none, unclear; ",
    "priority = high, medium, low; confidence is a number from 0 to 1.\n\n",
    "Candidate metadata:\n",
    "source: ", source, "\n",
    "date: ", date, "\n",
    "identifier: ", identifier, "\n",
    "title: ", title, "\n",
    "abstract: ", abstract_text
  )
}

triage_one <- function(candidate) {
  title <- safe_text(candidate[["title"]])
  abstract <- safe_text(candidate[["abstract_text"]])
  source <- if ("source" %in% names(candidate)) safe_text(candidate[["source"]]) else ""
  date <- if ("date" %in% names(candidate)) safe_text(candidate[["date"]]) else ""
  doi <- if ("doi" %in% names(candidate)) safe_text(candidate[["doi"]]) else ""
  raw_id <- if ("raw_id" %in% names(candidate)) safe_text(candidate[["raw_id"]]) else ""
  identifier <- if (doi != "") doi else raw_id

  prompt <- build_prompt(title, abstract, source, date, identifier)
  request_object <- request(paste0(str_remove(LLM_BASE_URL, "/+$"), "/chat/completions")) |>
    req_headers(
      Authorization = paste("Bearer", LLM_API_KEY),
      Accept = "application/json"
    ) |>
    req_body_json(list(
      model = LLM_MODEL,
      messages = list(
        list(role = "system", content = "You are a careful metadata classifier."),
        list(role = "user", content = prompt)
      ),
      temperature = LLM_TEMPERATURE,
      max_tokens = LLM_MAX_TOKENS,
      response_format = list(type = "json_object")
    )) |>
    req_timeout(120)

  response <- request_with_retries(request_object)
  response_body <- resp_body_json(response, simplifyVector = FALSE)
  model_content <- purrr::pluck(response_body, "choices", 1, "message", "content", .default = NULL)
  if (is.null(model_content) || length(model_content) == 0 || safe_text(model_content) == "") {
    stop("API response did not contain choices[1].message.content")
  }

  parsed <- jsonlite::fromJSON(safe_text(model_content), simplifyVector = FALSE)
  validated <- list(
    relevant_esm = parse_boolean(json_value(parsed, "relevant_esm"), "relevant_esm"),
    empirical_study = parse_boolean(json_value(parsed, "empirical_study"), "empirical_study"),
    data_openly_available = parse_boolean(json_value(parsed, "data_openly_available"), "data_openly_available"),
    data_access_route = parse_choice(json_value(parsed, "data_access_route"), "data_access_route", c("open", "request", "none", "unclear")),
    priority = parse_choice(json_value(parsed, "priority"), "priority", c("high", "medium", "low")),
    confidence = parse_confidence(json_value(parsed, "confidence")),
    reason = safe_text(json_value(parsed, "reason"))
  )

  c(
    list(
      triage_status = "ok",
      triage_model = LLM_MODEL,
      triage_prompt_version = TRIAGE_PROMPT_VERSION,
      triage_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
      relevant_esm = validated$relevant_esm,
      empirical_study = validated$empirical_study,
      data_openly_available = validated$data_openly_available,
      data_access_route = validated$data_access_route,
      priority = validated$priority,
      confidence = validated$confidence,
      reason = validated$reason,
      raw_model_response = safe_text(model_content),
      error_message = NA_character_
    )
  )
}

empty_result <- function(status, error_message) {
  list(
    triage_status = status,
    triage_model = LLM_MODEL,
    triage_prompt_version = TRIAGE_PROMPT_VERSION,
    triage_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    relevant_esm = NA,
    empirical_study = NA,
    data_openly_available = NA,
    data_access_route = NA_character_,
    priority = NA_character_,
    confidence = NA_real_,
    reason = NA_character_,
    raw_model_response = NA_character_,
    error_message = error_message
  )
}

cli::cli_h1("LLM candidate triage")
cli::cli_text("Input: {TRIAGE_INPUT_CSV}")
cli::cli_text("Output: {TRIAGE_OUTPUT_CSV}")
cli::cli_text("Model: {LLM_MODEL}")
cli::cli_text("Candidates: {nrow(candidates)}")

results <- vector("list", nrow(candidates))
for (row_number in seq_len(nrow(candidates))) {
  cli::cli_text("Processing {row_number}/{nrow(candidates)}")
  result <- tryCatch(
    triage_one(candidates[row_number, , drop = FALSE]),
    error = function(error) {
      cli::cli_warn("Candidate {row_number} failed: {error$message}")
      error_status <- if (str_detect(
        error$message,
        regex("JSON|syntax error|parse error|Missing JSON field|Invalid (boolean|data_access_route|priority|confidence)", ignore_case = TRUE)
      )) "parse_error" else "api_error"
      empty_result(error_status, error$message)
    }
  )
  results[[row_number]] <- result
  if (row_number < nrow(candidates) && LLM_DELAY_SECONDS > 0) {
    Sys.sleep(LLM_DELAY_SECONDS)
  }
}

triage_columns <- bind_rows(results)
output <- bind_cols(candidates, triage_columns)
write.csv(output, file = TRIAGE_OUTPUT_CSV, row.names = FALSE, na = "")

cli::cli_alert_success("Wrote {nrow(output)} rows to {TRIAGE_OUTPUT_CSV}")
cli::cli_text("Successful classifications: {sum(output$triage_status == 'ok', na.rm = TRUE)}")
cli::cli_text("Failed classifications: {sum(output$triage_status != 'ok', na.rm = TRUE)}")
