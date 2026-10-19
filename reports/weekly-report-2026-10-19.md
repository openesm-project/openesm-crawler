# Weekly ESM discovery report

Generated: 2026-10-19 15:50:12 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 86
- Successful classifications: 83
- Relevant ESM/EMA candidates: 64
  - with open-data evidence (listed below): 10
  - with an OSF view-only data link only (listed below): 1
  - without open-data evidence (not listed): 53
- Excluded as irrelevant: 19
- API or parse errors: 3

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 72 |
| openalex+osf_psyarxiv | 13 |
| osf_psyarxiv | 1 |

## Open-data candidates

- **[Data from the ACHILLES (Assessing Daily Changes in Individual Prerequisites of Learning Success) Project](https://doi.org/10.5334/jopd.182)**
  - Date: 2026-10-15 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states dataset is publicly available with non-proprietary formats and extensive documentation, and includes repeated daily assessments and objective behavioral data from a human-subject study.
- **[An experience-sampling dataset of everyday moral experiences across 20 countries](https://doi.org/10.5281/zenodo.23378436)**
  - Date: 2026-10-14 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states the dataset is publicly available in a repository and describes original ESM/EMA data collection across 20 countries using preregistered, multi-site EMA.
- **[What Laboratory Alcohol Experiments Capture About Real-World Drinking](https://doi.org/10.31234/osf.io/xtuq4_v1)**
  - Date: 2026-10-15 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/rv39t/overview
  - Reason: Original human-subject research using EMA to collect repeated measurements in daily life; dataset is described as collected and analyzed, but no explicit data access information in abstract
- **[Preliminary Effects of PRECISE, a Personalized and Idiographically-Tailored Adjunctive Intervention for Treating Suicidal Ideation and Psychiatric Symptoms in Young Adults: Open Trial](https://doi.org/10.31234/osf.io/ut2bv_v1)**
  - Date: 2026-10-14 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://github.com/kskuehn/PRECISE_AFSP_outcomes
  - Reason: Original human-subject research using daily EMA (five times per day) to inform personalized treatment; no explicit data access statement in abstract
- **[Scroll and Snack: Daily Life Exposure to Healthy Food Content on Instagram Boosts Cravings for Healthy Snacks](https://doi.org/10.31234/osf.io/anpt3_v2)**
  - Date: 2026-10-14 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/rn4ma
  - Reason: Original human-subject ESM/EMA study with repeated daily measurements via smartphone; dataset is reusable and described in abstract, but no explicit data access information provided.
- **[1. Gunnell, K. E., Howard, A. L., Remedios, J. C., &amp; Wadlow, M. E. (2026). Quantity and Quality of Screen Time: The relationship between screen-related psychological needs and hedonic and eudaimonic well-being. Journal of Happiness Studies, 27, doi: https://doi.org/10.1007/s10902-026-01106-3](https://doi.org/10.31234/osf.io/g69hx_v1)**
  - Date: 2026-10-13 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/5pwhc
  - Reason: Study 2 uses a 1-week daily experience sampling method with self-report surveys, indicating original human-subject data collection with repeated measurements in daily life. However, the abstract does not state that the data are publicly available or deposited in a named repository, so dataset_candidate is false and data_access_status is not_stated.
- **[Beyond the Big Five: Disintegration as a Predictor of Daily Depression, Anxiety, and Rumination](https://doi.org/10.31234/osf.io/e5hma_v1)**
  - Date: 2026-10-13 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.5281/zenodo.23157249
  - Reason: Original daily diary study with repeated measurements; no explicit data access statement in abstract
- **[From Lab to Life: Stress Beliefs and the Stress Optimization Model in Everyday Stress](https://doi.org/10.31234/osf.io/d4ufx_v1)**
  - Date: 2026-10-13 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.17605/OSF.IO/FCWJG
  - Reason: Ecological momentary assessment study with repeated daily measurements; no explicit data access statement in abstract
- **[Unresolved snack desire and subsequent snacking in daily life](https://doi.org/10.31234/osf.io/etyms_v2)**
  - Date: 2026-10-13 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://github.com/gmarrazzo92/EMA-SnackDesire-Analysis.git https://osf.io/fsqpv/
  - Reason: Original EMA study with repeated daily measurements; abstract describes data collection but does not state data availability or repository
- **[Associations Between Global Emotion Beliefs and Three Stages of Emotion Regulation in Everyday Life](https://doi.org/10.31234/osf.io/zgxfr_v1)**
  - Date: 2026-10-12 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://emotedatabase.com/datasets/75
  - Reason: Original ESM study with repeated daily measurements; abstract describes data collection but does not state data availability or repository

## Declared data, OSF view-only link

- **[Comparing Time- and Event-Contingent Ecological Momentary Assessments of Daily Stressors](https://doi.org/10.31234/osf.io/cvby5_v1)**
  - Date: 2026-10-13 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/wdy4s/overview?view_only=d314d095cb634eb2bc18963955cb9cf1
  - Reason: Original human-subject ESM/EMA study with repeated daily measurements; no explicit data access statement in abstract

## Excluded records

Excluded records: 19. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

Errors: 3. These rows were not treated as irrelevant.
- Dynamic interplay between momentary self-rated activity/exertion and affective states: a temporal network analysis using intensive longitudinal data: API returned HTTP 500 after retries
- Dataset and Analysis Scripts: Predicting creativity in everyday life: An additional HRV reduction algorithm simulation and its Bayesian replication: API returned HTTP 500 after retries
- Framework for Generating Activity-Based Travel Demand Using Aggregated Mobility and Land-Use Big Data: API returned HTTP 500 after retries

