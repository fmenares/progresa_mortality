# CLAUDE.md

## Project Overview

This repository contains research code evaluating the causal impact of **PROGRESA** (Programa de Educación, Salud y Alimentación) — Mexico's major conditional cash transfer program — on **adult mortality rates**. The analysis focuses on municipalities with high marginalization levels and examines mechanisms through household income, consumption, health expenditure, and employment.

**Research question:** Does greater PROGRESA enrollment intensity at the municipality level reduce mortality, particularly for adults aged 65+?

**Identification strategy:** Difference-in-differences exploiting variation in program rollout timing and intensity across municipalities (pre/post 1997).

---

## Repository Structure

```
progresa_mortality/
├── CLAUDE.md                     # This file
├── codes/
│   ├── aamr_011326.do            # Data assembly: merges all sources, constructs mortality rates
│   ├── 01_enigh_data.do          # ENIGH household survey data processing
│   ├── 02_mortality.do           # Main mortality regressions and event study figures
│   ├── 03_mechanisms_enigh.do    # Mechanisms analysis (income, consumption, health spending)
│   └── enigh_string_recoding.do  # Utility: decodes ENIGH string variables
└── c_enigh1992.pdf               # ENIGH 1992 survey documentation (reference)
```

---

## Analysis Scripts (run in order)

### 1. `aamr_011326.do` — Data Construction
Merges five data sources to build the main analysis dataset:
- Marginalization index (1990, 2000)
- PROGRESA beneficiary records (1997–2018)
- Household counts by municipality
- Death records (vital statistics)
- Population data by age/sex (census ITER)

Constructs:
- **Program intensity** measures at 5%, 10%, 15% beneficiary thresholds
- **Crude and age-adjusted mortality rates (AAMR)** by municipality-year
- **Excess mortality rate (EMR)** for ages 65+, overall, male, and female
- `post` dummy = 1 for years ≥ 1997

Sample: Highly marginalized municipalities (`gm_mun_1990 == 4 | gm_mun_1990 == 5`)

### 2. `01_enigh_data.do` — ENIGH Household Survey Processing
Processes ENIGH waves (1992, 1994, 1996, 1998, 2000) to construct individual- and household-level outcome variables:
- Household income and total expenditures
- Food consumption by category (cereals, meat, vegetables, sugar)
- Health spending and medical visits
- Employment, hours worked, and earnings
- PROGRESA transfer receipt
- Financial outcomes: savings, debt, currency

Uses survey expansion weights (`exp_factor`) and municipality-level merges.

### 3. `02_mortality.do` — Main Mortality Analysis
Runs difference-in-differences regressions:
```
emr65 ~ inten1999*post + inten2005*post + year FE + municipality FE + Seguro Popular controls
```
Produces Tables and **Figures 2–3** (event study plots by program intensity group).

### 4. `03_mechanisms_enigh.do` — Mechanisms Analysis
Tests whether PROGRESA affects mortality through employment, income, food consumption, health spending, or savings/debt. Uses weighted regression with municipality-level clustering.

### 5. `enigh_string_recoding.do` — Utility
Standalone helper that decodes ENIGH identifiers (FOLIO, CLAVE, UPM, EST_DIS) from string to numeric for the years 1992–2000.

---

## Key Variables

| Variable | Description |
|---|---|
| `emr65` | Excess mortality rate, ages 65+ |
| `inten1999` | PROGRESA intensity in 1999 (fraction of households enrolled) |
| `inten2005` | PROGRESA intensity in 2005 |
| `post` | = 1 for years ≥ 1997 |
| `gm_mun_1990` | Municipal marginalization grade (4 = high, 5 = very high) |
| `aamr` | Age-adjusted mortality rate |
| `sp_*` | Seguro Popular controls |

---

## Data Sources

Data files are stored externally (Dropbox/OneDrive/shared server) and are not included in this repository. The scripts reference these paths — update them to match your local environment before running.

| Source | Description |
|---|---|
| ENIGH | Encuesta Nacional de Ingresos y Gastos de los Hogares (1992–2000) |
| Vital Statistics | Death records by municipality and year |
| ITER / Census | Population counts by age, sex, municipality |
| PROGRESA admin data | Beneficiary enrollment records (1997–2018) |
| Seguro Popular | Health insurance enrollment (2001–2018) |
| CONAPO marginalization index | Socioeconomic deprivation by municipality (1990, 2000) |

---

## Software and Dependencies

- **Stata** (all scripts are `.do` files)
- Required user-written Stata packages:
  - `reghdfe` — high-dimensional fixed effects regression
  - `coefplot` — coefficient plots for event studies

Install packages via:
```stata
ssc install reghdfe
ssc install coefplot
```

---

## Notes for Contributors

- All paths to external data are hardcoded in each `.do` file — update the `global` or `local` path macros at the top of each script before running.
- The sample is restricted to **highly marginalized municipalities** (`gm_mun_1990 == 4 | 5`) throughout.
- Scripts use **municipality and year fixed effects** — ensure panel IDs are correctly set (`xtset municipality year`).
- Regressions cluster standard errors at the **municipality level**.
- Figures are saved as `.png` or `.pdf` — output directories must exist before running.
