# Weekly ESM discovery report

Generated: 2026-10-03 07:59:31 UTC
Input: `output/triage_v3.csv`
Model: qwen3-30b-a3b-instruct-2507 v4

## Summary

- Records fetched for triage: 72
- Successful classifications: 43
- Relevant ESM/EMA candidates: 30
  - with open-data evidence (listed below): 2
  - with an OSF view-only data link only (listed below): 0
  - without open-data evidence (not listed): 28
- Excluded as irrelevant: 13
- API or parse errors: 29

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

## Declared data, OSF view-only link

None.

## Excluded records

Excluded records: 13. They remain in the triage CSV for audit and prompt review.
## API and parsing errors

Errors: 29. These rows were not treated as irrelevant.
- Quality of Life in Adults With Metastatic Breast Cancer: The Impact of Between‐ and Within‐Person Changes in Symptoms and Positive Affect: HTTP 429 Too Many Requests.
- Required components of a sleep-wake online daily diary for accurate and efficient human research: HTTP 429 Too Many Requests.
- Risk perception, but not response efficacy, linked risk communication to protective action during an atmospheric river in California: HTTP 429 Too Many Requests.
- Temporal Quotas, Interrupted Task Resumption and Sleep Displacement in Generative AI Use: HTTP 429 Too Many Requests.
- The Impact of Microinteractions on User Engagement in Mobile Applications: A Cognitive and Affective Analysis: HTTP 429 Too Many Requests.
- Addiction as a Claimed Context Network: Coverage, the Isthmus, Rhythm Match, and Why Abstinence Is Held Rather Than Reached: HTTP 429 Too Many Requests.
- A tutorial on Bayesian multilevel latent time series models using stan with the mlts R package.: HTTP 429 Too Many Requests.
- Capturing the rhythm of time: introducing Dynamic Time Warping in behavioral research: HTTP 429 Too Many Requests.
- Helping or controlling? A multi-method case study of a mother-daughter dyad and their interactions during trauma-focused therapy: HTTP 429 Too Many Requests.
- Incremental advantage of extraversion and neuroticism facets in predicting state work engagement: HTTP 429 Too Many Requests.
- Incremental Value of Smartphone Sensing for Monitoring Momentary Affect Intensity in Adults Using Transformer-Based Models: Observational Study: HTTP 429 Too Many Requests.
- Physical activity in older adults: an event-based ecological momentary assessment study: HTTP 429 Too Many Requests.
- Supplementary material from "A climate action intervention increases four psychological motivators, as well as climate advocacy, activism and civic participation": HTTP 429 Too Many Requests.
- The relationship between intolerance of uncertainty and fear of missing out: Evidence from network analysis and a daily diary study: HTTP 429 Too Many Requests.
- Unique and shared effects of single-session intervention proximal outcomes on 3-month depression symptoms in adolescents: A commonality analysis: HTTP 429 Too Many Requests.
- Validating a Linguistic Index of Cognitive Constriction Using Daily Diary Data: Reliability, Convergent and Predictive Validity: HTTP 429 Too Many Requests.
- Differential Effects of Types of Momentary Social Support on Mood and Anxiety in Patients with Depression: HTTP 429 Too Many Requests.
- Does Smartphone Application Use Impact Adolescents’ Affect? Or Vice Versa? An Experience Sampling Study: HTTP 429 Too Many Requests.
- A Longitudinal and Ecological Momentary Assessment Study of Parent-Peer Relationships, Mentalizing, and Non-Suicidal Self-Injury in Chinese Adolescents: HTTP 429 Too Many Requests.
- Assessing Person-Specific Symptom Networks From Brief Narratives: Development and Initial Evaluation of the Narrative-to-Network (N2N) Approach: HTTP 429 Too Many Requests.
- Associations between adverse childhood experiences, parent-child and peer attachment relationships, and daily-life self-harm in adolescents: HTTP 429 Too Many Requests.
- Emotion regulation in early adolescence: using dyadic experience sampling to examine the regulatory strategies used by youths and their trauma-exposed mothers: HTTP 429 Too Many Requests.
- Family-Specific Dynamics Between Parenting and Preschoolers’ Self-Regulation: Evidence from 100-Day Daily Diary Data: HTTP 429 Too Many Requests.
- Goals in Focus: A single-blind multi-method randomized‑controlled pilot feasibility trial of a targeted CBT approach for motivational negative symptoms of schizophrenia: HTTP 429 Too Many Requests.
- How could redistribution be possible? Effects of national identity and communion among Chinese youth: HTTP 429 Too Many Requests.
- Intensity and instability of affective and cognitive states in borderline personality disorder compared to remitted mood disorders and population-based controls: an Ecological Momentary Assessment study: HTTP 429 Too Many Requests.
- Mapping Cannabis Use and Environmental Availability in a Sample of Black Young Adults: A Descriptive Geolocation Analysis: HTTP 429 Too Many Requests.
- Use of telehealth and at-home video for remote administration of the North Star Ambulatory Assessment (NSAA): a comparative methods study: HTTP 429 Too Many Requests.
- With Others, More Myself: Personal Expressiveness as Identity Enactment in Adult Daily Life: HTTP 429 Too Many Requests.

