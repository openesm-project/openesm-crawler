# Weekly ESM discovery report

Generated: 2026-11-23 20:21:42 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 85
- Successful classifications: 85
- Relevant ESM/EMA candidates: 73
  - with open-data evidence (listed below): 4
  - with an OSF view-only data link only (listed below): 2
  - without open-data evidence (not listed): 67
- Excluded as irrelevant: 12
- API or parse errors: 0

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 74 |
| openalex+osf_psyarxiv | 7 |
| osf_psyarxiv | 4 |

## Open-data candidates

- **[Self-esteem and Perceived Empathic Self-Efficacy: Daily Dynamics in Italian Young Adults](https://doi.org/10.5281/zenodo.24364754)**
  - Date: 2026-11-19 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states that the daily diary data file is included and available, indicating open access to the raw participant data.
- **[Psychopathic Traits and Reactions to Interpersonal Stress in Daily Life: An Examination of the DSM-5 Alternative Model of Psychopathy](https://doi.org/10.31234/osf.io/dqjkh)**
  - Date: 2026-11-17 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/9r6fd/overview
  - Reason: Abstract describes original ESM/EMA data collection via 14- to 21-day ecological momentary assessment, with repeated daily measurements of affect and psychopathy-related traits in response to interpersonal events. No explicit mention of data availability or repository.
  - Also: https://doi.org/10.31234/osf.io/dqjkh_v1
- **[Who I Am vs. How Do I Feel? Testing the Empirical Distinctiveness of Self-Concept Clarity and Trait Negative Affectivity](https://doi.org/10.31234/osf.io/jb7ha_v1)**
  - Date: 2026-11-17 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/xzjc9/overview
  - Reason: Original ESM/EMA study with repeated daily measurements over 15 days; abstract describes data collection from 493 adults using ecological momentary assessment, indicating a reusable dataset. No explicit mention of data availability in the abstract.
  - Also: https://doi.org/10.31234/osf.io/jb7ha
- **[Hunger and Concentration in Daily Life: Inter-Individual Differences and Eating-Related Variation but No Robust Average Association](https://doi.org/10.31234/osf.io/486ny_v4)**
  - Date: 2026-11-16 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.17605/OSF.IO/7P6C9
  - Reason: Original ESM study with repeated daily measurements; abstract describes data collection from 64 participants using experience sampling; dataset is likely reusable but no explicit data access statement in abstract

## Declared data, OSF view-only link

- **[Positive Affect is Associated with Interactive Social Media Use: An Ecological Momentary Assessment Study](https://doi.org/10.31234/osf.io/wmqhu_v2)**
  - Date: 2026-11-22 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/kdmz3/overview?view_only=4b41179c635a4c67aeb46d8cbb4cbc42
  - Reason: Original EMA study with repeated daily measurements; no explicit data access statement in abstract
- **[Momentary Emotion Differentiation: A Theory-Consistent Index that is Disambiguated from Momentary Affect](https://doi.org/10.31234/osf.io/kcygm_v1)**
  - Date: 2026-11-23 | Source: osf_psyarxiv | Confidence: 0.85
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/jvf58/overview?view_only=88f4e531addb4ba3ac9aab146c938841
  - Reason: Original EMA study with repeated daily measurements; dataset described as reusable; R code provided, but no explicit data access statement in abstract

## Excluded records

Excluded records: 12. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

None.

