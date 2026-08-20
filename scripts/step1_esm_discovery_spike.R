#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(httr2)
  library(jsonlite)
  library(dplyr)
  library(stringr)
  library(purrr)
  library(cli)
})

# non-goals for this step-1 spike:
# - no llm triage
# - no email output/digests
# - no scheduler/github action
# - no state/ledger/files written by default
# - no pdf/full-text handling

# -----------------------------
# configuration
# -----------------------------
LOOKBACK_DAYS <- as.integer(Sys.getenv("LOOKBACK_DAYS", unset = "7"))
OPENALEX_PER_PAGE <- 200L
OSF_PAGE_SIZE <- 100L
MAX_RETRIES <- 6L
BACKOFF_BASE_SECONDS <- 1
BACKOFF_MAX_SECONDS <- 120
RETRY_STATUS_CODES <- c(429L, 500L, 502L, 503L, 504L)
OSF_RELATIONSHIP_PATHS <- c("relationships.node.links.related.href", "relationships.node.data.id")
OPENALEX_MIN_INTERVAL_SECONDS <- 1.25

# include a real address before running.
OPENALEX_MAILTO <- Sys.getenv("OPENALEX_MAILTO", unset = "")
USE_OPENALEX_POLITE_POOL <- OPENALEX_MAILTO != ""
CANDIDATE_CSV <- Sys.getenv("CANDIDATE_CSV", unset = "")

# optional: comma-separated known psyarxiv esm dois for abstract coverage probing.
KNOWN_PSYARXIV_ESM_DOIS_ENV <- Sys.getenv("KNOWN_PSYARXIV_ESM_DOIS", unset = "")
known_psyarxiv_esm_dois <- if (KNOWN_PSYARXIV_ESM_DOIS_ENV == "") {
  character()
} else {
  str_split(KNOWN_PSYARXIV_ESM_DOIS_ENV, pattern = ",", simplify = FALSE)[[1]] |>
    str_trim() |>
    (
      function(x) x[x != ""]
    )()
}

TERM_SET <- c(
  "experience sampling",
  "ecological momentary assessment",
  "ambulatory assessment",
  "daily diary",
  "intensive longitudinal",
  "ema"
)
EMA_TERM <- "ema"
CORE_TERMS <- TERM_SET[TERM_SET != EMA_TERM]

START_DATE <- Sys.Date() - LOOKBACK_DAYS
END_DATE <- Sys.Date()
RUN_TIMESTAMP <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")

# -----------------------------
# utility helpers
# -----------------------------
safe_chr <- function(x, default = NA_character_) {
  if (is.null(x) || length(x) == 0) {
    return(default)
  }
  value <- as.character(x[[1]])
  if (is.na(value) || value == "") {
    return(default)
  }
  value
}

safe_lgl <- function(x, default = FALSE) {
  if (is.null(x) || length(x) == 0) {
    return(default)
  }
  as.logical(x[[1]])
}

normalize_doi <- function(x) {
  ifelse(
    is.na(x) | str_trim(x) == "",
    NA_character_,
    x |>
      str_trim() |>
      str_to_lower() |>
      str_replace("^https?://(dx\\.)?doi\\.org/", "") |>
      str_replace("^doi:\\s*", "") |>
      str_trim()
  )
}

to_date_only <- function(x) {
  ifelse(
    is.na(x) | str_trim(x) == "",
    NA_character_,
    str_sub(as.character(x), 1, 10)
  )
}

collapse_or_na <- function(x, sep = ";") {
  values <- x[!is.na(x) & x != ""]
  if (length(values) == 0) {
    return(NA_character_)
  }
  paste(sort(unique(values)), collapse = sep)
}

print_table_chunks <- function(df, chunk_size = 25L) {
  if (!is.data.frame(df) || nrow(df) == 0) {
    return(invisible(NULL))
  }

  df <- as.data.frame(df, stringsAsFactors = FALSE)
  row_groups <- split(seq_len(nrow(df)), ceiling(seq_len(nrow(df)) / chunk_size))

  for (i in seq_along(row_groups)) {
    rows <- row_groups[[i]]
    chunk <- df[rows, , drop = FALSE]
    cli::cli_text("Chunk {i}/{length(row_groups)}")
    write.table(
      chunk,
      file = stdout(),
      sep = "\t",
      row.names = FALSE,
      col.names = (i == 1L),
      quote = FALSE,
      na = "NA"
    )
    if (i < length(row_groups)) {
      cat("\n")
    }
  }

  invisible(NULL)
}

unpack_openalex_abstract <- function(abstract_inverted_index) {
  if (is.null(abstract_inverted_index) || length(abstract_inverted_index) == 0) {
    return(NA_character_)
  }

  tokens <- names(abstract_inverted_index)
  if (is.null(tokens) || length(tokens) == 0) {
    return(NA_character_)
  }

  placement <- vector("list", length = 0)
  for (token in tokens) {
    positions <- abstract_inverted_index[[token]]
    if (is.null(positions) || length(positions) == 0) {
      next
    }
    for (pos in positions) {
      idx <- as.integer(pos) + 1L
      placement[[as.character(idx)]] <- token
    }
  }

  if (length(placement) == 0) {
    return(NA_character_)
  }

  ordered_idx <- as.integer(names(placement))
  ordered_tokens <- unlist(placement[order(ordered_idx)], use.names = FALSE)
  text <- paste(ordered_tokens, collapse = " ") |> str_squish()

  if (text == "") {
    NA_character_
  } else {
    text
  }
}

contains_term <- function(text, term) {
  if (is.na(text) || text == "") {
    return(FALSE)
  }
  if (term == EMA_TERM) {
    return(str_detect(text, regex("\\bema\\b", ignore_case = TRUE)))
  }
  str_detect(text, regex(str_escape(term), ignore_case = TRUE))
}

compute_match_flags <- function(title_text, abstract_text) {
  title_text <- ifelse(is.na(title_text), "", title_text)
  abstract_text <- ifelse(is.na(abstract_text), "", abstract_text)

  title_core <- any(vapply(CORE_TERMS, function(term) contains_term(title_text, term), logical(1)))
  abstract_core <- any(vapply(CORE_TERMS, function(term) contains_term(abstract_text, term), logical(1)))
  title_ema <- contains_term(title_text, EMA_TERM)
  abstract_ema <- contains_term(abstract_text, EMA_TERM)

  any_core <- title_core || abstract_core
  any_ema <- title_ema || abstract_ema
  any_match <- any_core || any_ema

  list(
    any_match = any_match,
    title_has_match = title_core || title_ema,
    abstract_has_match = abstract_core || abstract_ema,
    ema_exclusive = any_match && (!any_core) && any_ema
  )
}

request_with_retries <- function(req, source_name, max_retries = MAX_RETRIES) {
  get_retry_after_seconds <- function(resp) {
    headers <- tryCatch(resp_headers(resp), error = function(e) NULL)
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

  attempt <- 1L
  repeat {
    resp <- tryCatch(req_perform(req), error = function(e) e)

    if (inherits(resp, "error")) {
      if (attempt >= max_retries) {
        stop(sprintf("%s request failed after retries: %s", source_name, resp$message))
      }
      wait_seconds <- min(BACKOFF_MAX_SECONDS, BACKOFF_BASE_SECONDS * (2 ^ (attempt - 1))) + runif(1, 0, 0.75)
      cli::cli_warn(sprintf("%s request error on attempt %d; retrying in %.2fs", source_name, attempt, wait_seconds))
      Sys.sleep(wait_seconds)
      attempt <- attempt + 1L
      next
    }

    status <- resp_status(resp)
    if (status %in% RETRY_STATUS_CODES) {
      if (attempt >= max_retries) {
        stop(sprintf("%s returned status %d after retries", source_name, status))
      }
      retry_after_seconds <- get_retry_after_seconds(resp)
      exponential_wait <- min(BACKOFF_MAX_SECONDS, BACKOFF_BASE_SECONDS * (2 ^ (attempt - 1)))
      wait_seconds <- max(exponential_wait, retry_after_seconds, na.rm = TRUE) + runif(1, 0, 0.75)
      cli::cli_warn(sprintf("%s returned status %d on attempt %d; retrying in %.2fs", source_name, status, attempt, wait_seconds))
      Sys.sleep(wait_seconds)
      attempt <- attempt + 1L
      next
    }

    if (status >= 400L) {
      stop(sprintf("%s returned non-retryable status %d", source_name, status))
    }

    return(resp)
  }
}

# -----------------------------
# source fetchers
# -----------------------------
fetch_openalex_by_term <- function(term, start_date, end_date, mailto) {
  base_url <- "https://api.openalex.org/works"
  source_name <- sprintf("OpenAlex[%s]", term)

  all_rows <- list()
  cursor <- "*"
  page_counter <- 0L
  terminated_early <- FALSE
  termination_reason <- NA_character_

  repeat {
    page_counter <- page_counter + 1L
    user_agent <- if (mailto == "") {
      "openesm-crawler-step1/0.1"
    } else {
      sprintf("openesm-crawler-step1/0.1 (mailto:%s)", mailto)
    }

    req <- request(base_url) |>
      req_user_agent(user_agent) |>
      req_url_query(
        filter = paste0(
          "from_publication_date:", start_date,
          ",to_publication_date:", end_date
        ),
        search = term,
        cursor = cursor,
        `per-page` = OPENALEX_PER_PAGE
      )

    if (mailto != "") {
      req <- req_url_query(req, mailto = mailto)
    }

    resp <- tryCatch(
      request_with_retries(req, source_name = source_name),
      error = function(e) {
        terminated_early <<- TRUE
        termination_reason <<- e$message
        NULL
      }
    )

    if (is.null(resp)) {
      cli::cli_warn(sprintf("%s stopped early after %d page(s): %s", source_name, page_counter - 1L, termination_reason))
      break
    }

    payload <- resp_body_json(resp, simplifyVector = FALSE)

    # when no polite-pool mailto is configured, slow down between calls.
    if (mailto == "") {
      Sys.sleep(OPENALEX_MIN_INTERVAL_SECONDS + runif(1, 0, 0.35))
    }

    results <- purrr::pluck(payload, "results", .default = list())
    if (length(results) == 0) {
      break
    }

    rows <- lapply(results, function(item) {
      title <- safe_chr(purrr::pluck(item, "display_name", .default = NA_character_))
      abstract_text <- unpack_openalex_abstract(
        purrr::pluck(item, "abstract_inverted_index", .default = NULL)
      )

      data.frame(
        doi_raw = safe_chr(purrr::pluck(item, "doi", .default = NA_character_)),
        doi = normalize_doi(safe_chr(purrr::pluck(item, "doi", .default = NA_character_))),
        source = "openalex",
        date = to_date_only(safe_chr(purrr::pluck(item, "publication_date", .default = NA_character_))),
        title = title,
        abstract_text = abstract_text,
        abstract_available = !is.na(abstract_text) && abstract_text != "",
        linked_project_available = FALSE,
        raw_id = safe_chr(purrr::pluck(item, "id", .default = NA_character_)),
        matched_query_term = term,
        stringsAsFactors = FALSE
      )
    })

    all_rows <- c(all_rows, rows)

    next_cursor <- safe_chr(purrr::pluck(payload, "meta", "next_cursor", .default = NA_character_))
    if (is.na(next_cursor) || next_cursor == "" || identical(next_cursor, cursor)) {
      break
    }
    cursor <- next_cursor
  }

  if (length(all_rows) == 0) {
    out <- data.frame(
      doi_raw = character(), doi = character(), source = character(), date = character(),
      title = character(), abstract_text = character(), abstract_available = logical(),
      linked_project_available = logical(), raw_id = character(), matched_query_term = character(),
      stringsAsFactors = FALSE
    )
    attr(out, "term") <- term
    attr(out, "terminated_early") <- terminated_early
    attr(out, "termination_reason") <- termination_reason
    attr(out, "pages_fetched") <- max(page_counter - 1L, 0L)
    return(out)
  }

  out <- bind_rows(all_rows)
  attr(out, "term") <- term
  attr(out, "terminated_early") <- terminated_early
  attr(out, "termination_reason") <- termination_reason
  attr(out, "pages_fetched") <- page_counter
  out
}

fetch_osf_preprints <- function(start_date, end_date) {
  base_url <- "https://api.osf.io/v2/preprints/"
  source_name <- "OSF"

  all_rows <- list()
  page_number <- 1L

  fetch_with_filter_field <- function(date_filter_field) {
    local_rows <- list()
    local_page_number <- 1L

    repeat {
      req <- request(base_url) |>
        req_user_agent("openesm-crawler-step1/0.1") |>
        req_url_query(
          `filter[provider]` = "psyarxiv",
          `page[size]` = OSF_PAGE_SIZE,
          `page` = local_page_number
        )

      date_query <- stats::setNames(
        as.list(c(
          paste0(start_date, "T00:00:00Z"),
          paste0(end_date, "T23:59:59Z")
        )),
        c(
          paste0("filter[", date_filter_field, "][gte]"),
          paste0("filter[", date_filter_field, "][lte]")
        )
      )
      req <- do.call(req_url_query, c(list(req), date_query))

      resp <- request_with_retries(req, source_name = source_name)
      payload <- resp_body_json(resp, simplifyVector = FALSE)

      records <- purrr::pluck(payload, "data", .default = list())
      if (length(records) == 0) {
        break
      }

      rows <- lapply(records, function(item) {
        attrs <- purrr::pluck(item, "attributes", .default = list())
        rel <- purrr::pluck(item, "relationships", "node", .default = list())

        node_related_href <- safe_chr(purrr::pluck(rel, "links", "related", "href", .default = NA_character_))
        node_data_id <- safe_chr(purrr::pluck(rel, "data", "id", .default = NA_character_))

        linked_project_available <- (!is.na(node_related_href) && node_related_href != "") ||
          (!is.na(node_data_id) && node_data_id != "")

        title <- safe_chr(purrr::pluck(attrs, "title", .default = NA_character_))
        abstract_text <- safe_chr(purrr::pluck(attrs, "description", .default = NA_character_))

        date_published <- safe_chr(purrr::pluck(attrs, "date_published", .default = NA_character_))
        date_created <- safe_chr(purrr::pluck(attrs, "date_created", .default = NA_character_))
        chosen_date <- ifelse(!is.na(date_published), date_published, date_created)

        data.frame(
          doi_raw = safe_chr(purrr::pluck(attrs, "doi", .default = NA_character_)),
          doi = normalize_doi(safe_chr(purrr::pluck(attrs, "doi", .default = NA_character_))),
          source = "osf_psyarxiv",
          date = to_date_only(chosen_date),
          title = title,
          abstract_text = ifelse(is.na(abstract_text), NA_character_, abstract_text),
          abstract_available = !is.na(abstract_text) && abstract_text != "",
          linked_project_available = linked_project_available,
          raw_id = safe_chr(purrr::pluck(item, "id", .default = NA_character_)),
          matched_query_term = NA_character_,
          stringsAsFactors = FALSE
        )
      })

      local_rows <- c(local_rows, rows)

      has_next <- !is.na(safe_chr(purrr::pluck(payload, "links", "next", .default = NA_character_)))
      if (!has_next) {
        break
      }
      local_page_number <- local_page_number + 1L
    }

    if (length(local_rows) == 0) {
      return(data.frame(
        doi_raw = character(), doi = character(), source = character(), date = character(),
        title = character(), abstract_text = character(), abstract_available = logical(),
        linked_project_available = logical(), raw_id = character(), matched_query_term = character(),
        stringsAsFactors = FALSE
      ))
    }

    bind_rows(local_rows)
  }

  osf_date_filter_used <- "date_published"
  osf_date_filter_fallback <- FALSE
  osf_terminated_early <- FALSE
  osf_termination_reason <- NA_character_

  empty_osf_rows <- function() {
    data.frame(
      doi_raw = character(), doi = character(), source = character(), date = character(),
      title = character(), abstract_text = character(), abstract_available = logical(),
      linked_project_available = logical(), raw_id = character(), matched_query_term = character(),
      stringsAsFactors = FALSE
    )
  }

  all_rows <- tryCatch(
    fetch_with_filter_field("date_published"),
    error = function(e) {
      osf_date_filter_used <<- "date_created"
      osf_date_filter_fallback <<- TRUE
      cli::cli_warn("OSF date_published filtering failed; falling back to date_created window filtering.")
      tryCatch(
        fetch_with_filter_field("date_created"),
        error = function(e2) {
          # a persistent OSF outage should not discard results already fetched from other sources.
          osf_terminated_early <<- TRUE
          osf_termination_reason <<- e2$message
          cli::cli_warn(sprintf("OSF fetch failed after fallback; continuing without OSF records: %s", e2$message))
          empty_osf_rows()
        }
      )
    }
  )

  attr(all_rows, "osf_date_filter_used") <- osf_date_filter_used
  attr(all_rows, "osf_date_filter_fallback") <- osf_date_filter_fallback
  attr(all_rows, "osf_terminated_early") <- osf_terminated_early
  attr(all_rows, "osf_termination_reason") <- osf_termination_reason
  attr(all_rows, "osf_relationship_paths") <- paste(OSF_RELATIONSHIP_PATHS, collapse = " | ")

  all_rows
}

probe_known_psyarxiv_doi_coverage <- function(doi_values, mailto) {
  doi_values <- normalize_doi(doi_values)
  doi_values <- doi_values[!is.na(doi_values)]

  if (length(doi_values) == 0) {
    return(list(total = 0L, with_abstract = 0L, fraction = NA_real_))
  }

  probe_rows <- lapply(doi_values, function(doi_value) {
    user_agent <- if (mailto == "") {
      "openesm-crawler-step1/0.1"
    } else {
      sprintf("openesm-crawler-step1/0.1 (mailto:%s)", mailto)
    }

    req <- request("https://api.openalex.org/works") |>
      req_user_agent(user_agent) |>
      req_url_query(filter = paste0("doi:", doi_value), `per-page` = 1)

    if (mailto != "") {
      req <- req_url_query(req, mailto = mailto)
    }

    resp <- request_with_retries(req, source_name = "OpenAlex[doi_probe]")
    payload <- resp_body_json(resp, simplifyVector = FALSE)
    item <- purrr::pluck(payload, "results", 1, .default = NULL)

    abstract_text <- unpack_openalex_abstract(
      purrr::pluck(item, "abstract_inverted_index", .default = NULL)
    )

    data.frame(
      doi = doi_value,
      abstract_available = !is.na(abstract_text) && abstract_text != "",
      stringsAsFactors = FALSE
    )
  })

  probe_df <- bind_rows(probe_rows)
  total <- nrow(probe_df)
  with_abstract <- sum(probe_df$abstract_available, na.rm = TRUE)
  fraction <- ifelse(total > 0, with_abstract / total, NA_real_)

  list(total = total, with_abstract = with_abstract, fraction = fraction)
}

# -----------------------------
# workflow
# -----------------------------
cli::cli_h1("Step-1 ESM Discovery Spike")
cli::cli_text("Window: {START_DATE} to {END_DATE}")
cli::cli_text("Run timestamp: {RUN_TIMESTAMP}")
cli::cli_text("Sources: OpenAlex (works), OSF (preprints provider=psyarxiv)")
cli::cli_text("Term set: {paste(TERM_SET, collapse = '; ')}")
if (USE_OPENALEX_POLITE_POOL) {
  cli::cli_text("OpenAlex mode: polite pool enabled via OPENALEX_MAILTO")
} else {
  cli::cli_alert_info("OpenAlex mode: no OPENALEX_MAILTO set; proceeding without polite pool mailto parameter.")
}

cli::cli_h2("Fetching OpenAlex by term")
openalex_term_health <- lapply(TERM_SET, function(term) {
  result <- fetch_openalex_by_term(term, START_DATE, END_DATE, OPENALEX_MAILTO)
  list(
    term = term,
    rows = nrow(result),
    pages_fetched = attr(result, "pages_fetched"),
    terminated_early = isTRUE(attr(result, "terminated_early")),
    termination_reason = safe_chr(attr(result, "termination_reason"), default = NA_character_),
    data = result
  )
})

openalex_raw_list <- lapply(openalex_term_health, function(x) x$data)
openalex_raw <- bind_rows(openalex_raw_list)

openalex_health_df <- bind_rows(lapply(openalex_term_health, function(x) {
  data.frame(
    term = x$term,
    rows = x$rows,
    pages_fetched = x$pages_fetched,
    terminated_early = x$terminated_early,
    termination_reason = x$termination_reason,
    stringsAsFactors = FALSE
  )
}))

cli::cli_h2("OpenAlex Fetch Health")
for (i in seq_len(nrow(openalex_health_df))) {
  health_row <- openalex_health_df[i, ]
  if (isTRUE(health_row$terminated_early)) {
    cli::cli_warn(
      sprintf(
        "term='%s' rows=%d pages=%d status=partial reason=%s",
        health_row$term,
        health_row$rows,
        health_row$pages_fetched,
        health_row$termination_reason
      )
    )
  } else {
    cli::cli_text(
      sprintf(
        "term='%s' rows=%d pages=%d status=ok",
        health_row$term,
        health_row$rows,
        health_row$pages_fetched
      )
    )
  }
}

if (nrow(openalex_raw) > 0) {
  openalex_raw <- openalex_raw |>
    distinct(raw_id, .keep_all = TRUE)
}

cli::cli_h2("Fetching OSF PsyArXiv preprints")
osf_raw <- fetch_osf_preprints(START_DATE, END_DATE)
osf_date_filter_used <- attr(osf_raw, "osf_date_filter_used")
osf_date_filter_fallback <- isTRUE(attr(osf_raw, "osf_date_filter_fallback"))
osf_relationship_paths <- attr(osf_raw, "osf_relationship_paths")

if (isTRUE(attr(osf_raw, "osf_terminated_early"))) {
  cli::cli_alert_warning(sprintf(
    "OSF fetch failed; continuing with 0 OSF records: %s",
    attr(osf_raw, "osf_termination_reason")
  ))
}

combined_raw <- bind_rows(openalex_raw, osf_raw)

if (nrow(combined_raw) == 0) {
  cli::cli_alert_warning("No records fetched from either source in the selected window.")
}

with_doi <- combined_raw |>
  filter(!is.na(doi))

without_doi <- combined_raw |>
  filter(is.na(doi))

deduped_with_doi <- if (nrow(with_doi) > 0) {
  with_doi |>
    group_by(doi) |>
    summarise(
      doi_raw = first(doi_raw),
      source = paste(sort(unique(source)), collapse = "+"),
      date = suppressWarnings(max(date, na.rm = TRUE)),
      title = first(title[!is.na(title) & title != ""]),
      abstract_text = first(abstract_text[!is.na(abstract_text) & abstract_text != ""]),
      abstract_available = any(abstract_available, na.rm = TRUE),
      linked_project_available = any(linked_project_available, na.rm = TRUE),
      raw_id = first(raw_id),
      matched_query_term = collapse_or_na(matched_query_term),
      .groups = "drop"
    )
} else {
  with_doi
}

if (nrow(deduped_with_doi) > 0) {
  empty_title_idx <- which(is.na(deduped_with_doi$title) | deduped_with_doi$title == "")
  if (length(empty_title_idx) > 0) {
    deduped_with_doi$title[empty_title_idx] <- NA_character_
  }

  empty_abstract_idx <- which(is.na(deduped_with_doi$abstract_text) | deduped_with_doi$abstract_text == "")
  if (length(empty_abstract_idx) > 0) {
    deduped_with_doi$abstract_text[empty_abstract_idx] <- NA_character_
  }
}

combined_deduped <- bind_rows(deduped_with_doi, without_doi)

if (nrow(combined_deduped) > 0) {
  match_flags <- lapply(seq_len(nrow(combined_deduped)), function(i) {
    compute_match_flags(
      title_text = safe_chr(combined_deduped$title[i], default = ""),
      abstract_text = safe_chr(combined_deduped$abstract_text[i], default = "")
    )
  })

  combined_deduped$prefilter_pass <- vapply(match_flags, function(x) x$any_match, logical(1))
  combined_deduped$title_match <- vapply(match_flags, function(x) x$title_has_match, logical(1))
  combined_deduped$abstract_match <- vapply(match_flags, function(x) x$abstract_has_match, logical(1))
  combined_deduped$ema_exclusive <- vapply(match_flags, function(x) x$ema_exclusive, logical(1))
} else {
  combined_deduped$prefilter_pass <- logical()
  combined_deduped$title_match <- logical()
  combined_deduped$abstract_match <- logical()
  combined_deduped$ema_exclusive <- logical()
}

candidates <- combined_deduped |>
  filter(prefilter_pass) |>
  mutate(date = as.character(date)) |>
  arrange(desc(date))

if (CANDIDATE_CSV != "") {
  write.csv(candidates, file = CANDIDATE_CSV, row.names = FALSE, na = "")
  cli::cli_alert_success("Candidate object written to {CANDIDATE_CSV}")
}

# -----------------------------
# diagnostics
# -----------------------------
openalex_total <- nrow(openalex_raw)
openalex_abstract_count <- sum(openalex_raw$abstract_available, na.rm = TRUE)
openalex_abstract_pct <- ifelse(openalex_total > 0, 100 * openalex_abstract_count / openalex_total, NA_real_)

osf_total <- nrow(osf_raw)
osf_abstract_count <- sum(osf_raw$abstract_available, na.rm = TRUE)
osf_abstract_pct <- ifelse(osf_total > 0, 100 * osf_abstract_count / osf_total, NA_real_)
osf_linked_project_count <- sum(osf_raw$linked_project_available, na.rm = TRUE)
osf_linked_project_pct <- ifelse(osf_total > 0, 100 * osf_linked_project_count / osf_total, NA_real_)

prefilter_pass_total <- nrow(candidates)
title_only_count <- sum(candidates$title_match & !candidates$abstract_match, na.rm = TRUE)
abstract_supported_count <- sum(candidates$abstract_match, na.rm = TRUE)
ema_exclusive_count <- sum(candidates$ema_exclusive, na.rm = TRUE)

doi_probe <- probe_known_psyarxiv_doi_coverage(known_psyarxiv_esm_dois, OPENALEX_MAILTO)

# -----------------------------
# console output
# -----------------------------
cli::cli_h2("Source Coverage Breakdown")
cli::cli_text(
  "OpenAlex: Total fetched = {openalex_total} | Non-null abstract = {openalex_abstract_count} ({sprintf('%.1f', openalex_abstract_pct)}%)"
)
cli::cli_text(
  "OSF: Total fetched = {osf_total} | Non-null abstract = {osf_abstract_count} ({sprintf('%.1f', osf_abstract_pct)}%) | Linked OSF project = {osf_linked_project_count} ({sprintf('%.1f', osf_linked_project_pct)}%)"
)

if (doi_probe$total > 0) {
  cli::cli_text(
    "Known PsyArXiv DOI probe: {doi_probe$with_abstract}/{doi_probe$total} with OpenAlex abstract ({sprintf('%.1f', 100 * doi_probe$fraction)}%)"
  )
} else {
  cli::cli_alert_info("Known PsyArXiv DOI probe skipped: set KNOWN_PSYARXIV_ESM_DOIS with 20-30 comma-separated DOIs.")
}

cli::cli_h2("Filter Metrics")
cli::cli_text("Total candidates passing boolean prefilter: {prefilter_pass_total}")
cli::cli_text("Candidates passing title-only matching: {title_only_count}")
cli::cli_text("Candidates passing abstract-supported matching: {abstract_supported_count}")
cli::cli_text("EMA-exclusive matches: {ema_exclusive_count}")

cli::cli_h2("Candidate Table")
if (nrow(candidates) == 0) {
  cli::cli_alert_warning("No candidates passed the boolean prefilter in this run window.")
} else {
  cli::cli_text("Candidates returned: {nrow(candidates)}")
  print_table_chunks(
    candidates |>
      transmute(
        DOI = doi,
        source = source,
        date = date,
        title = title,
        abstract_available = abstract_available
      ),
    chunk_size = 25L
  )
}

cli::cli_h2("Design Impact Assessment")
if (!is.na(openalex_abstract_pct) && openalex_abstract_pct > 80) {
  cli::cli_alert_success(
    "Recommendation: OpenAlex abstract availability exceeds 80%; OpenAlex can be treated as primary for prefiltering, with OSF retained for supplement/project linkage coverage."
  )
} else {
  cli::cli_alert_warning(
    "Recommendation: OpenAlex abstract availability is not above 80%; keep OSF direct fetching as required and do not rely on OpenAlex abstract-based prefiltering alone."
  )
}

cli::cli_h2("API Behavior Notes")
cli::cli_text("OpenAlex pagination: cursor-based via meta.next_cursor.")
cli::cli_text("OSF pagination: page/page[size] with links.next termination.")
cli::cli_text("OSF relationship path(s) checked: {osf_relationship_paths}")
cli::cli_text("OSF date filter used: {osf_date_filter_used}{if (osf_date_filter_fallback) ' (fallback applied)' else ''}.")
cli::cli_text("Retries enabled for status codes: {paste(RETRY_STATUS_CODES, collapse = ', ')} using exponential backoff with jitter.")
