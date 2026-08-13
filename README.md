# openESM crawler

A small R script for finding recent ESM-related papers and PsyArXiv preprints through OpenAlex and OSF. It prints coverage, filter counts, and candidate records for manual review. It does not send email or create GitHub issues.

## Requirements

R with these packages:

```r
install.packages(c("httr2", "jsonlite", "dplyr", "stringr", "purrr", "cli"))
```

## Run

From PowerShell in the repository directory:

```powershell
Rscript step1_esm_discovery_spike.R
```

The default lookback window is seven days. Change `LOOKBACK_DAYS` in the script for a different window.

## Options

Set these environment variables before running:

- `OPENALEX_MAILTO`: email address for OpenAlex's polite pool. Optional, but recommended.
- `CANDIDATE_CSV`: path for an optional CSV export of the candidate object. No file is written when unset.
- `KNOWN_PSYARXIV_ESM_DOIS`: comma-separated known PsyArXiv ESM DOIs for the OpenAlex abstract-coverage check.

Example:

```powershell
$env:OPENALEX_MAILTO="you@example.org"
$env:KNOWN_PSYARXIV_ESM_DOIS="10.31234/osf.io/example1,10.31234/osf.io/example2"
$env:CANDIDATE_CSV="candidates.csv"
Rscript step1_esm_discovery_spike.R
```

The script prints the candidate table and diagnostic summaries to the console. The CSV export contains the full filtered candidate object, including matching and linked-project fields.
