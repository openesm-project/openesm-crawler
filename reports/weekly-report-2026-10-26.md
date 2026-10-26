# Weekly ESM discovery report

Generated: 2026-10-26 15:21:29 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 63
- Successful classifications: 63
- Relevant ESM/EMA candidates: 46
  - with open-data evidence (listed below): 3
  - with an OSF view-only data link only (listed below): 2
  - without open-data evidence (not listed): 41
- Excluded as irrelevant: 17
- API or parse errors: 0

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 56 |
| openalex+osf_psyarxiv | 4 |
| osf_psyarxiv | 3 |

## Open-data candidates

- **[Bidirectional Dynamics of Cannabis Use and Schizophrenia: A Compound-Causality Research Protocol and Analysis Plan](https://doi.org/10.5281/zenodo.23607654)**
  - Date: 2026-10-24 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states that the dataset is collected via repeated within-person measurement with ecological momentary assessment bursts, biochemical verification, and mandatory registry linkage, and that the full protocol, simulation code, parameter register, and outputs are publicly available under a MIT licence, indicating explicit open access to participant data.
- **[Dataset: Keep on Scrolling? – Using Intensive Longitudinal Smartphone Sensing Data to Assess How Everyday Smartphone Usage Behaviors are Related to Well-Being](https://openalex.org/W7113551950)**
  - Date: 2026-10-22 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states dataset is available on OSF, a public repository, and describes original intensive longitudinal smartphone sensing data collection.
- **[Fabla: An Open-Source Voice-First EMA Platform for Clinical Research](https://doi.org/10.5281/zenodo.22923409)**
  - Date: 2026-10-19 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states that Fabla collects voice diary audio from participants in daily life, supports 15 active studies, and explicitly mentions that the platform is open-source with data stored in Emory's IRB-approved infrastructure; the paper describes a reusable ESM/EMA dataset with public access via the open-source platform and associated infrastructure, and the data are available for reuse.

## Declared data, OSF view-only link

- **[Stress Generation Across Hours, Days, and 1 Month](https://doi.org/10.31234/osf.io/ydwqc_v2)**
  - Date: 2026-10-23 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/pcjnb/overview?view_only=52f63069dc1849f1b53c37b813a92e03
  - Reason: Original human-subject research using experience sampling and daily diary methods; no explicit data access statement in abstract
- **[Solitude as Short-Term Regulation: An Allostatic View of Withdrawal in Times of Distress](https://doi.org/10.31234/osf.io/8sbpu_v2)**
  - Date: 2026-10-20 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/aemg8/?view_only=4aa7e26aa200451d972f9b10b5456717
  - Reason: Original EMA studies with repeated daily measurements in naturalistic settings; dataset is reusable but no explicit data access statement in abstract

## Excluded records

Excluded records: 17. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

None.

