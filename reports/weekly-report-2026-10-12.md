# Weekly ESM discovery report

Generated: 2026-10-12 18:05:53 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 87
- Successful classifications: 87
- Relevant ESM/EMA candidates: 67
  - with open-data evidence (listed below): 7
  - with an OSF view-only data link only (listed below): 0
  - without open-data evidence (not listed): 60
- Excluded as irrelevant: 20
- API or parse errors: 0

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 74 |
| openalex+osf_psyarxiv | 10 |
| osf_psyarxiv | 3 |

## Open-data candidates

- **[Triangulating Careless Responding: Quantitative Models Meet Qualitative Insights on Response Processes](https://doi.org/10.83089/tiu01-ak41ui)**
  - Date: 2026-10-08 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states data are available via OSF project page (https://osf.io/md9xa/), explicitly open and reusable; original ESM data collected with repeated daily measurements and qualitative response process insights.
- **[Data osf.io/bweza (Contemporary, Temporal and Between-Person Correlates of Stress, Affect, Activity, Social Context across subtypes of Suicidal Ideation: Multilevel Network Analysis of Ecological Momentary Assessment data)](https://doi.org/10.17605/osf.io/gecjv)**
  - Date: 2026-10-05 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states data are available at osf.io/bweza, a public repository, and the study involves EMA data collection on suicidal ideation with repeated daily measurements.
- **[Associations Between Global Emotion Beliefs and Three Stages of Emotion Regulation in Everyday Life](https://doi.org/10.31234/osf.io/zgxfr_v1)**
  - Date: 2026-10-12 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://emotedatabase.com/datasets/75
  - Reason: Original ESM/EMA study using seven-day experience sampling with a community sample; abstract describes repeated daily measurements but does not state data availability or repository.
- **[An Idiographic Examination of Body-Focused Repetitive Behaviors Using Ecological Momentary Assessment and Network Analysis](https://doi.org/10.31234/osf.io/2yz6v_v1)**
  - Date: 2026-10-10 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/gepkv/files/osfstorage
  - Reason: Original ESM/EMA data collected via five daily assessments over two weeks; study reports individual-level network analyses from repeated momentary data; dataset is plausibly reusable but no explicit data access statement in abstract.
- **[Real-time Associations Between Psychological States and Context in University Students with Suicidal Ideation: An Ecological Momentary Assessment Study](https://doi.org/10.31234/osf.io/x9s6e_v2)**
  - Date: 2026-10-09 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.17605/OSF.IO/GECJV
  - Reason: Original EMA study with repeated daily measurements; abstract describes data collection but does not state data availability or repository.
- **[Loneliness and Interpersonal Emotion Regulation in Everyday Life](https://doi.org/10.31234/osf.io/rfzyv_v1)**
  - Date: 2026-10-07 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/6d7rt/ https://osf.io/s87f6
  - Reason: Original daily diary and experience sampling studies with repeated momentary assessments; dataset described as collected and analyzed, but no explicit data access statement in abstract
- **[Felt but Not Detected: Salience Versus Detectability of Affective Change in Ambulatory Assessment](https://doi.org/10.31234/osf.io/36zwq_v1)**
  - Date: 2026-10-05 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/57spj/overview
  - Reason: Original human-subject ESM/EMA study with repeated daily measurements; dataset is reusable and described in detail (N=250, 14-day protocol, 5,982 observations), but no explicit data access information in abstract

## Declared data, OSF view-only link

None.

## Excluded records

Excluded records: 20. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

None.

