# Weekly ESM discovery report

Generated: 2026-11-09 18:55:39 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 76
- Successful classifications: 76
- Relevant ESM/EMA candidates: 58
  - with open-data evidence (listed below): 6
  - with an OSF view-only data link only (listed below): 2
  - without open-data evidence (not listed): 50
- Excluded as irrelevant: 18
- API or parse errors: 0

Source counts:

| Source | Records |
| --- | ---: |
| openalex | 66 |
| openalex+osf_psyarxiv | 9 |
| osf_psyarxiv | 1 |

## Open-data candidates

- **[Analytic datasets for lag-specific physical activity–affect associations in young adults](https://doi.org/10.5281/zenodo.23670851)**
  - Date: 2026-11-06 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states data are available in a repository with complete-case analytic datasets, codebook, and README; includes EMA and wearable data from repeated daily measurements; data access is directly stated as public.
- **[When do learned representations improve longitudinal health prediction? A persistence-anchored, information-matched benchmark of wearable data and personalized models](https://doi.org/10.5281/zenodo.23955095)**
  - Date: 2026-11-04 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract explicitly states the LifeSnaps dataset is publicly available via DOI (10.5281/zenodo.7229547) and includes derived data, code, and reproducibility materials; study uses repeated daily measurements via wearable and EMA; dataset is reusable and open.
- **[Behind the Number: Using Open-Ended Responses to Uncover Response Processes in Emotion Ratings in ESM Studies.](https://doi.org/10.83089/tiuacc01-2e3wdz)**
  - Date: 2026-11-02 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states that the data were collected in a diary study using ESM, participants provided open-ended responses about emotion ratings, and the raw data are available via OSF with a direct link, indicating explicit public access to participant data.
- **[Cross-Symptoms Interactions Fail to Predict Future Symptom States Across Four Ecological Momentary Assessment Datasets](https://doi.org/10.31234/osf.io/ct9nw_v1)**
  - Date: 2026-11-02 | Source: openalex+osf_psyarxiv | Confidence: 0.95
  - Evidence: OSF data link: https://openesmdata.org/
  - Reason: Abstract states four public EMA datasets are used and names them as publicly available, with participant data accessible from a named repository or link.
- **[The National Couples’ Health and Time Stress Biology Study (NCHAT-BIO): Wave 1 Methodology Report and Wave 3 Preview](https://doi.org/10.1097/psy.0000000000001514)**
  - Date: 2026-11-02 | Source: openalex | Confidence: 0.95
  - Evidence: LLM: explicit open data in abstract
  - Reason: Abstract states that Wave 1 NCHAT-BIO data have been deposited at ICPSR for public release, with explicit mention of public availability and linkage to survey data, indicating open access to participant-level data.
- **[Sleep and the Daytime Course of Anhedonia in Adolescent Depression: An Ecological Momentary Assessment Study](https://doi.org/10.31234/osf.io/2q3tp_v1)**
  - Date: 2026-11-06 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF data link: https://github.com/HannahEveMarshall/ctads_sleep_anhedonia/tree/d3f42648c5231bbe00f43b726e3fe25a72e94a70/data
  - Reason: Original EMA study with repeated daily measurements; abstract describes data collection but does not state data availability or repository
  - Also: https://doi.org/10.31234/osf.io/2q3tp

## Declared data, OSF view-only link

- **[Dreading Tomorrow, Dreading Today: Additive Effects of Evening Stress Anticipation and Sleep Quality on Morning Stress Anticipation](https://doi.org/10.31234/osf.io/8kw3z)**
  - Date: 2026-11-06 | Source: openalex+osf_psyarxiv | Confidence: 0.9
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/2x348/overview?view_only=316fbeec042c40b4b108d1bdd797c74e
  - Reason: Original ambulatory assessment study with repeated daily measurements; collects evening and morning stress anticipation, self-reported sleep, and smartwatch sleep data; describes a reusable dataset but no explicit data access statement in abstract.
  - Also: https://doi.org/10.31234/osf.io/8kw3z_v1
- **[Development Insights and User Experience of a Preventive Digital Parenting Intervention for Adolescent Mental Health](https://doi.org/10.31234/osf.io/sy3nk)**
  - Date: 2026-11-06 | Source: openalex+osf_psyarxiv | Confidence: 0.85
  - Evidence: OSF view-only link (review access, may not be public): https://osf.io/tbp36/overview?view_only=1318656d07bb4fedb61da2c819a5c7bd
  - Reason: Original human-subject research with daily diary data on user experience; dataset is reusable but no explicit data access statement in abstract
  - Also: https://doi.org/10.31234/osf.io/sy3nk_v1

## Excluded records

Excluded records: 18. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

None.

