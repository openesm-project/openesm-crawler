# Weekly ESM discovery report

Generated: 2026-10-03 08:09:08 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 72
- Successful classifications: 72
- Relevant ESM/EMA candidates: 53
  - with open-data evidence (listed below): 3
  - with an OSF view-only data link only (listed below): 0
  - without open-data evidence (not listed): 50
- Excluded as irrelevant: 19
- API or parse errors: 0

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 57 |
| openalex+osf_psyarxiv | 11 |
| osf_psyarxiv | 4 |

## Open-data candidates

- **[Adolescents’ Academic Motivation and Well-Being during the COVID-19 pandemic crisis in 2021: A daily diary study](https://openalex.org/W7166495923)**
  - Date: 2026-09-29 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states data are available at OSF (https://osf.io/dufgk/), which is a public repository, and study collects repeated daily measurements via diary method during a specific period.
- **[Daily loneliness and alcohol use in Alcohol Use Disorder: an 8-week EMA study of within-person associations](https://doi.org/10.31234/osf.io/46ty8_v1)**
  - Date: 2026-09-29 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.17605/OSF.IO/F76K3
  - Reason: Original EMA study with repeated daily measurements in real-life context; abstract describes data collection but does not state data availability or repository
- **[Differential Effects of Types of Momentary Social Support on Mood and Anxiety in Patients with Depression](https://doi.org/10.31234/osf.io/58gvq_v1)**
  - Date: 2026-09-27 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://researchbox.org/9429
  - Reason: Original human-subject research using daily-life EMA via smartphone; abstract describes repeated measurements over five days with six prompts per day, but no explicit mention of data availability or repository.

## Declared data, OSF view-only link

None.

## Excluded records

Excluded records: 19. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

None.

