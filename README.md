# openESM crawler

A small R workflow for finding recent ESM-related papers and PsyArXiv preprints through OpenAlex and OSF, then optionally ranking them with an OpenAI-compatible language-model API. It does not send email or create GitHub issues.

## Requirements

R with these packages:

```r
install.packages(c("httr2", "jsonlite", "dplyr", "stringr", "purrr", "cli"))
```

## Run

From PowerShell in the repository directory:

```powershell
$env:OPENALEX_MAILTO="you@example.org"
$env:CANDIDATE_CSV="candidates.csv"
Rscript step1_esm_discovery_spike.R
```

The default lookback window is seven days. Change `LOOKBACK_DAYS` in the script for a different window. Set `CANDIDATE_CSV` to keep the filtered candidates for the next step.

## Options

Set these environment variables before running:

- `OPENALEX_MAILTO`: email address for OpenAlex's polite pool. Recommended for better throughput; it does not guarantee unlimited requests.
- `CANDIDATE_CSV`: path for an optional CSV export of the candidate object. No file is written when unset.
- `KNOWN_PSYARXIV_ESM_DOIS`: comma-separated known PsyArXiv ESM DOIs for the OpenAlex abstract-coverage check.
- `LLM_API_KEY`: API key for the triage service; required only by `triage_candidates.R`.
- `LLM_BASE_URL`: OpenAI-compatible API base URL; defaults to AcademicCloud.
- `LLM_MODEL`: model name; defaults to `meta-llama-3.1-8b-instruct`.
- `TRIAGE_INPUT_CSV`: discovery CSV for the triage script; defaults to `candidates.csv`.
- `TRIAGE_OUTPUT_CSV`: triage result CSV; defaults to `triage_<date>.csv` and is never overwritten.
- `LLM_MAX_TOKENS`, `LLM_TEMPERATURE`, `LLM_DELAY_SECONDS`: optional triage controls.

Example:

```powershell
$env:OPENALEX_MAILTO="you@example.org"
$env:KNOWN_PSYARXIV_ESM_DOIS="10.31234/osf.io/example1,10.31234/osf.io/example2"
$env:CANDIDATE_CSV="candidates.csv"
Rscript step1_esm_discovery_spike.R
```

The discovery script prints diagnostics and writes the full filtered candidate object, including title, abstract, DOI/source identifiers, and matching fields.

## Triage

Run the second step locally after reviewing the discovery CSV:

```powershell
$env:LLM_API_KEY="your-key"
$env:LLM_BASE_URL="https://chat-ai.academiccloud.de/v1"
$env:LLM_MODEL="meta-llama-3.1-8b-instruct"
$env:TRIAGE_INPUT_CSV="candidates.csv"
$env:TRIAGE_OUTPUT_CSV="triage.csv"
Rscript triage_candidates.R
```

The script sends only titles and abstracts, requests JSON classifications, preserves every input row, and writes model results plus errors to `triage.csv`. Review high-priority and low-confidence rows manually. API keys are read from the environment and are not written to the output.

To use another OpenAI-compatible provider or a local service, change `LLM_BASE_URL`, `LLM_MODEL`, and `LLM_API_KEY`.
