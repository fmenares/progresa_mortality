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

## ENIGH Variable Codebook — Income and Expenditure (`01_enigh_data.do`)

### Intended income aggregates

The script is designed to support two aggregates built from individual components:

```
earnings_work = wage_ind  + indep_w_ind        /* labor income only */
income        = wage_ind  + indep_w_ind
              + capital_ind + transfer_ind + other_inc_ind   /* total income, excl. financial_d */
```

Both variables exist at the individual (`_ind`) and household (`_hh`) level.
`financial_d` (loans received, pension fund withdrawals, asset sales) is **not** included in the income aggregate — it captures liquidity events, not current income.

---

### Income variables — P-code mapping by year

Each row describes which ENIGH `ingresos.dta` P-codes are assigned to each variable.

#### `wage_d` — Subordinate employment income
Sueldos, salarios, comisiones, aguinaldo, primas, cooperativa/sociedad/empresa wages, and **reparto de utilidades** (mandatory profit-sharing paid to employees under Mexican labor law).

| Year | P-codes | Contents |
|---|---|---|
| 1992 | P001–P006 | Sueldos, comisiones, horas extra, aguinaldo, primas, cooperativa wages bundled |
| 1994 | P001–P005, P014 | Sueldos–primas; P014 = cooperativa sueldos |
| 1996 | P001–P005, P014 | Same as 1994 |
| 1998/2000 | P001–P009, P018 | Expanded asalariado section; P018 = cooperativa sueldos |
| 2002 | P001–P009, P018, P020, P022 | Asalariado + cooperativa wages (P018) + sociedad wages (P020, P022) |
| 2004/2005 | P001–P009, P017, P019–P027, P029–P037 | Asalariado; P017 = cooperativa sueldos; P019–P026 = sociedad sueldos; P027 = sociedad reparto utilidades; P029–P036 = empresa sueldos; P037 = empresa reparto utilidades |
| 2006 | P001–P009, P017, P019–P027, P029–P037 | Same structure as 2004/2005 |

#### `indep_w_d` — Self-employment / own-business income
Net income from operating own businesses (sole proprietors, agricultural, livestock, industrial, commercial, services). Does **not** include ganancias netas from cooperativas, sociedades, or empresas — those are capital returns (see `capital_d`).

| Year | P-codes | Contents |
|---|---|---|
| 1992 | P007–P011, P013 | Negocios propios (agrícola, pecuario, industrial, comercio, servicios) + producción pecuaria. **P012 (venta agrícola) and P014 (venta pecuaria) are unclassified — farm sales revenue excluded from all categories.** |
| 1994 | P006–P013 | Negocios propios; P014 cooperativa sueldos excluded (in `wage_d`) to avoid double-count |
| 1996 | P006–P013 | Same as 1994 |
| 1998/2000 | P010–P017 | Negocios propios expanded section |
| 2002 | P010–P017, P023 | Negocios propios + P023 (likely sociedad ganancias — **verify: may belong in `capital_d`**) |
| 2004/2005 | P010–P016 | Negocios propios only; cooperativa/sociedad/empresa ganancias moved to `capital_d` |
| 2006 | P010–P016 | Same as 2004/2005 |

#### `capital_d` — Capital income
Returns to ownership: renta de la propiedad (alquiler, intereses, dividendos) plus ganancias netas from cooperativas, sociedades, and empresas (returns to capital membership, distinct from wages earned in those entities).

| Year | P-codes | Contents |
|---|---|---|
| 1992 | P015–P021 | Alquiler terrenos/inmuebles/maquinaria, intereses, dividendos, regalías, otros |
| 1994 | P015–P022 | P015–P021 same as 1992; P022 = cooperativa ganancias netas |
| 1996 | P015–P022 | Same as 1994 |
| 1998/2000 | P019–P027 | P019 = cooperativa ganancias; P020–P026 = renta propiedad; P027 = otros capital |
| 2002 | P019, P021, P024–P036 | P019 = cooperativa ganancias; P021 = sociedad ganancias; P024–P036 = renta propiedad |
| 2004/2005 | P018, P028, P038, P039–P047 | P018 = cooperativa ganancias; P028 = sociedad ganancias; P038 = empresa ganancias; P039–P047 = renta propiedad |
| 2006 | P018, P028, P038, P039–P047 | Same as 2004/2005 |

#### `transfer_d` — Transfers (all)
All public and private transfers. Includes sub-components listed separately below.

| Year | P-codes | Contents |
|---|---|---|
| 1992 | P022–P027 | Jubilaciones, seguros por accidente, indemnización laboral, becas/donativos instituciones, regalos/donativos país, remesas exterior |
| 1994 | P023–P028, P043 | Same categories + P043 = PROCAMPO |
| 1996 | P023–P029 | Jubilaciones through P029 = PROCAMPO |
| 1998/2000 | P028–P034 | Jubilaciones through P034 = PROCAMPO; **P031 (Becas instituciones) used to proxy PROGRESA receipt** (first explicit PROGRESA code available only in 2002+) |
| 2002 | P037–P047 | Jubilaciones (P037–P038), indemnización (P039–P041), becas ONG (P042), becas gobierno (P043), regalos otros hogares (P044), remesas (P045), **PROGRESA (P046)** — first year with own code, procampo (P047) |
| 2004/2005 | P048–P060 | Jubilaciones (P048–P049), indemnización (P050–P052), becas (P053–P054), donativo ONG (P055), donativo gobierno (P056), regalos hogares (P057), remesas (P058), **PROGRESA/Oportunidades (P059)**, PROCAMPO (P060) |
| 2006 | P048–P060 | Same as 2004/2005 |

**Key transfer sub-components** (stored as separate variables):

| Sub-variable | 1992 | 1994 | 1996 | 1998/2000 | 2002 | 2004/2005/2006 |
|---|---|---|---|---|---|---|
| `pensions_d` | P022 | P023 | P023 | P028 | P037–P038 | P048–P049 |
| `severance_d` | P023–P024 | P024–P025 | P024–P025 | P029–P030 | P039–P041 | P050–P052 |
| `progresa_d` | 0 (none) | 0 (none) | 0 (none) | P031 (proxy) | P046 (explicit) | P059 (explicit) |
| `procampo_d` | 0 (none) | P043 | P029 | P034 | P047 | P060 |
| `remit_d` | P027 | P028 | P028 | P033 | P045 | P058 |
| `benef_gob_d` | P025 | P026 | P026 | P031 | P043 | P056 |

> **PROGRESA identification note:** For 1998 and 2000, `progresa_d` is estimated as `(benef_don_gob_ind + benef_don_non_gob_ind) × share_2002`, where `share_2002` is PROGRESA's share of total institutional transfers observed in 2002. This imputation is applied after appending all waves.

#### `other_d` — Other current income
Miscellaneous current income not elsewhere classified (typically venta de bienes de segunda mano, otros ingresos corrientes). One or two P-codes per year; small category.

| Year | P-codes |
|---|---|
| 1992 | P028–P029 |
| 1994 | P029–P030 |
| 1996 | P030–P031 |
| 1998/2000 | P035–P036 |
| 2002 | P048 |
| 2004/2005/2006 | P061 |

#### `financial_d` — Financial / liquidity income *(not used in analysis)*
Receipts from loans taken, savings account withdrawals, sale of real estate, pension fund withdrawals. Captures balance-sheet events, not income flows. **Excluded from all income aggregates.**

---

### Savings / financial outflows — Q-code mapping by year

From `eroga.dta`. All stored as monthly amounts (`ero_tri / 3`).

| Variable | Description | 1992 | 1994–2002 | 2004–2006 |
|---|---|---|---|---|
| `savings` | Deposits into savings accounts | Q001 | Q001 | Q001 |
| `loans` | Loans made to others outside the household | Q002 | Q002 | Q002 |
| `debt` | Credit card payments, loan repayments, mortgage payments | Q003–Q004 | Q003–Q004, Q010 | Q003–Q005, Q011 |
| `currency` | Purchase of coins and precious metals | Q005 | Q005 | Q006 |

> Note: 1992 `savings/loans/debt/currency` are coded from `ingresos.dta` (Q-prefixed entries there), not from a separate `eroga.dta` file. All other years use `eroga.dta`.

---

### Expenditure variables — A-code mapping by year

Food spending is collapsed to monthly amounts (`gas_tri / 3`). The final aggregated variables used in analysis are listed below with the underlying food category indicators they sum.

#### Food aggregates (final variables in dataset)

| Variable | Components | Notes |
|---|---|---|
| `cereals` | `cereals_d` | Maíz, trigo, arroz, avena, and other grains |
| `meat_dairy` | `meat_fish_seafood_d` + `dairy_d` | All meats, poultry, fish, seafood, milk, cheese, dairy derivatives, eggs |
| `vegg_fruit` | `vegg_fruit_d` | Tubers, vegetables, legumes, seeds, fresh and processed fruit (incl. jams/jellies from 2004+) |
| `sugar_fat_drink` | `oils_fats_d` + `sugar_d` + `soft_drink_d` + `desserts_d` | Oils, fats, sugar, honey, soft drinks, bottled water, juices, desserts and sweets |
| `coffe_spices_other` | `coffe_d` + `specias_d` + `others_d` | Coffee, tea, chocolate, spices, condiments, food-preparation costs (nixtamal grinding, etc.) |
| `outside_food` | `takeout_d` + `outside_d` | Prepared food for home consumption (carnitas, rotisserie, barbacoa, etc.) + food eaten outside (breakfast, lunch, dinner, snacks) |
| `tobacco` | `tobacco_d` | Cigarettes, cigars, pipe tobacco |
| `alcohol` | `alcohol_d` | Beer, spirits, pulque, wine, prepared drinks |
| `packaged_food` | `packaged_food_d` | Pre-packaged food bundles and despensas from organizations — **2002+ only; set to 0 for 1992–2000** |
| `baby_food` | `baby_food_d` | Strained baby food, infant cereals, baby juices |
| `pet_food` | `pet_food_d` | Animal feed |

#### Food category A-code boundaries by year

The underlying indicator codes shift across waves. Key boundaries after applying all catalog corrections:

| Category | 1992 | 1994 | 1996/1998 | 2000 | 2002 | 2004/2005 | 2006 |
|---|---|---|---|---|---|---|---|
| Cereals | A001–A020 | A001–A021 | A001–A021 | A001–A021 | A001–A021 | A001–A022 | A001–A024 |
| Meat/fish/seafood | A021–A058 | A022–A059 | A022–A059 | A022–A059 | A022–A070 | A023–A071 | A025–A074 |
| Dairy + eggs | A059–A078 | A060–A079 | A060–A079 | A060–A079 | A071–A090 | A072–A091 | A075–A094 |
| Oils and fats | A079–A083 | A080–A084 | A080–A084 | A080–A084 | A091–A096 | A092–A097 | A095–A100 |
| Vegetables and fruit | A084–A143 | A085–A145 | A085–A146 | A085–A146 | A097–A168 | A098–**A169** | A101–A172 |
| Sugar and honey | A144–A146 | A146–A148 | A147–A149 | A147–A149 | A169–A171 | A170–A172 | A173–A175 |
| Outside food | A199–A202 | **A204**–A207 | A205–A208 | A206–A209 | A235–A239 | A235–A239 | A243–A247 |
| Tobacco | A203–A205 | A208–A210 | **A209**–A211 | A211–A213 | A240–A242 | A240–A242 | A239–A241 |

Bold entries indicate boundaries that were corrected from prior erroneous values.

---

### Health expenditure variables — J-code mapping by year

| Variable | Description | 1992/1994 | 1996/1998 | 2000 | 2002 | 2004/2005/2006 |
|---|---|---|---|---|---|---|
| `medical_outpatient` | Outpatient consultations, lab tests, x-rays | J001–J003, J005, J006, J009 | same | same | J001–J004 | J016–J019, J036 |
| `drugs_prescribed` | Prescription medications (outpatient + inpatient) | J004, J011 | same | same | J005–J023 | J020–J035, J037–J038 |
| `medical_inpatient` | Hospital fees, tests, procedures, overnight stays | J010, J012–J015 | same | same | J026–J030 | J039–J043 |
| `drugs_overcounter` | OTC medications and first-aid materials | **J029**–J036 | **J033**–J038 | J034–J038 | J048–J065 | J044–J059 |
| `ortho` | Eyeglasses, dentures, hearing aids, orthopedic devices, repairs | J037–J041 | J039–J043 | same | J070–J075 | J065–J069 |
| `insurance_cost` | Health insurance premiums, hospital membership fees | J042–J043 | J044–J045 | same | J076–J077 | J070–J072 |

Bold starting codes for `drugs_overcounter` indicate the corrected lower bound (previously off by 1, omitting material for first aid).

---

## Notes for Contributors

- All paths to external data are hardcoded in each `.do` file — update the `global` or `local` path macros at the top of each script before running.
- The sample is restricted to **highly marginalized municipalities** (`gm_mun_1990 == 4 | 5`) throughout.
- Scripts use **municipality and year fixed effects** — ensure panel IDs are correctly set (`xtset municipality year`).
- Regressions cluster standard errors at the **municipality level**.
- Figures are saved as `.png` or `.pdf` — output directories must exist before running.
