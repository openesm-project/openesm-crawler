# Weekly ESM discovery report

Generated: 2026-11-16 18:41:49 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 69
- Successful classifications: 69
- Relevant ESM/EMA candidates: 52
  - with open-data evidence (listed below): 7
  - with an OSF view-only data link only (listed below): 0
  - without open-data evidence (not listed): 45
- Excluded as irrelevant: 17
- API or parse errors: 0

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 61 |
| openalex+osf_psyarxiv | 5 |
| osf_psyarxiv | 3 |

## Open-data candidates

- **[A multi-session simultaneous EEG-fMRI dataset with repeated experience sampling](https://doi.org/10.1038/s41597-026-08722-x)**
  - Date: 2026-11-14 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states dataset is available in BIDS format and explicitly describes repeated experience sampling (36 repetitions per participant) with mental experience ratings, indicating open data access.
- **[When do missed prompts matter? A simulation and empirical sensitivity study of structured nonresponse in intensive longitudinal assessment.](https://doi.org/10.1037/pas0001513)**
  - Date: 2026-11-09 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states the study applied a delta-shift sensitivity analysis to an 'open ecological momentary assessment data set', confirming open data access and reuse of a real ESM/EMA dataset collected in daily life.
- **[Hunger and Concentration in Daily Life: Inter-Individual Differences and Eating-Related Variation but No Robust Average Association](https://doi.org/10.31234/osf.io/486ny_v4)**
  - Date: 2026-11-16 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.17605/OSF.IO/7P6C9
  - Reason: Original ESM study with repeated daily measurements; dataset is reusable but no explicit data access statement in abstract
- **[Daily life evidence against the general relieving function of conspiracy beliefs](https://doi.org/10.31234/osf.io/svx6u)**
  - Date: 2026-11-14 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/2h5pc/
  - Reason: Original ESM/EMA data collected via experience sampling in daily life; dataset is described as reusable (N = 77, Nobs = 2,905 in Hungary; N = 200, Nobs = 10,609 in U.S.); no explicit data access statement in abstract
  - Also: https://doi.org/10.31234/osf.io/svx6u_v1
- **[Rethinking Smartphones and Sleep: A Fine-Grained Within-Person Analysis of Evening Smartphone Use and Sleep](https://doi.org/10.31234/osf.io/rpk86)**
  - Date: 2026-11-14 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.5281/zenodo.24109913
  - Reason: Original human-subject research collecting repeated measurements via experience sampling and device-based smartphone use over 10 days; dataset is described as collected and analyzed, but no explicit data access statement in abstract
  - Also: https://doi.org/10.31234/osf.io/rpk86_v1
- **[Connected or drained? An experience sampling study on informal communication and well-being in hybrid work settings](https://doi.org/10.31234/osf.io/d6vmp_v2)**
  - Date: 2026-11-10 | Source: osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://osf.io/amguk/overview
  - Reason: Original ESM study with repeated daily measurements via experience sampling; abstract describes data collection from 26 participants over one week with 549 surveys, but no mention of data availability or repository.
- **[From use perception to use behavior: Digitally traced smartphone use purposes and psychological well-being in daily life](https://doi.org/10.31234/osf.io/v834q)**
  - Date: 2026-11-10 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://doi.org/10.5281/zenodo.24083591
  - Reason: Original ESM/EMA study with repeated daily measurements using device-logged app use data; dataset is described as collected from a 10-day ecological momentary assessment study of romantic couples; no explicit data access statement in abstract
  - Also: https://doi.org/10.31234/osf.io/v834q_v1

## Declared data, OSF view-only link

None.

## Excluded records

Excluded records: 17. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

None.

