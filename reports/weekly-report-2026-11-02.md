# Weekly ESM discovery report

Generated: 2026-11-02 18:34:17 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 80
- Successful classifications: 80
- Relevant ESM/EMA candidates: 57
  - with open-data evidence (listed below): 5
  - with an OSF view-only data link only (listed below): 2
  - without open-data evidence (not listed): 50
- Excluded as irrelevant: 23
- API or parse errors: 0

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 68 |
| openalex+osf_psyarxiv | 11 |
| osf_psyarxiv | 1 |

## Open-data candidates

- **[The dynamical signature of anhedonia in Major Depressive Disorder: Positive emotion dynamics, reactivity, and recovery](https://openalex.org/W7160473144)**
  - Date: 2026-10-30 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states that data are available at osf.io/8gxrw, which is a public repository, and the study collects repeated daily measurements via EMA in human participants with MDD and controls.
- **[Post-psychedelic and meditation-related challenges: a protocol for a mixed-methods longitudinal-observational study](https://doi.org/10.64898/2026.10.26.26366468)**
  - Date: 2026-10-29 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states the study will produce a publicly available de-identified dataset, supporting reuse; includes repeated daily/weekly ambulatory assessments and longitudinal design with multiple measurement waves, meeting ESM/EMA criteria.
- **[LIVING-1: Does living a life help predict a person? Frozen protocols, sealed predictions and the feasibility gate](https://doi.org/10.5281/zenodo.23658126)**
  - Date: 2026-10-26 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states that the ESM arm uses two open experience sampling datasets and that results are being released with the study; data access is confirmed as open via named datasets.
- **[The Reciprocal Effects of Trauma-Focused Rumination and Emotional Clarity in Daily Life: A Mechanistic Evaluation Using Dynamic Structural Equation Modeling](https://doi.org/10.31234/osf.io/sduv8_v1)**
  - Date: 2026-10-28 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/36fj7/files/osfstorage
  - Reason: Original human-subject ESM data collected via experience sampling (5x/day for 14 days) from trauma-exposed students; dataset is described as reusable, but no explicit data access information is provided in the abstract.
- **[Exposure to Sexualised Appearance and Beauty Content on Social Media and Body Satisfaction in Female Adolescents: A Computational Real-World Approach](https://doi.org/10.31234/osf.io/9d6kp_v1)**
  - Date: 2026-10-26 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://github.com/ChristinaHaag/tiktok-appearance-exposure-ema
  - Reason: Original ESM/EMA study with repeated daily measurements; dataset includes raw TikTok video data and EMA responses; no explicit data access statement in abstract

## Declared data, OSF view-only link

- **[From Data to Dialogue: Using Person-Specific Networks to Personalize Cognitive-Behavioral Treatment for Chronic Pain](https://doi.org/10.31234/osf.io/edscr_v4)**
  - Date: 2026-10-29 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/tsdc8/overview?view_only=4e564f92f03e40b2ad5e37c678fe70b0
  - Reason: Original EMA data collected via six daily prompts over three weeks; no mention of data availability in abstract
- **[Growing Well with Grow It!: Acceptability of a Gamified mHealth App for Adolescents With a Chronic Somatic Illness – A Mixed Methods Study](https://doi.org/10.31234/osf.io/g8vtw_v1)**
  - Date: 2026-10-29 | Source: openalex+osf_psyarxiv | Confidence: 0.85
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/p4kmz/?view_only=9d62b206a30d4241b84c25f00e799f18
  - Reason: The study uses experience sampling via a mobile app to collect repeated momentary assessments in daily life, but the abstract does not state that the raw participant data are publicly available or deposited in a named repository.

## Excluded records

Excluded records: 23. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

None.

