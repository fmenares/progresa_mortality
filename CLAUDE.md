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

## Analysis Window Switch (`00_config.do`)

`codes/00_config.do` defines a global `$window` that controls the **balanced-panel
completeness screen** in `01_mortality_data.do` — i.e., how many municipalities
survive. Set `$window` before running; default is `full`.

| `$window` | Span | Use |
|---|---|---|
| `full` | 1990–2017 | **Original baseline — byte-identical to pre-switch behavior** |
| `prog` | 1990–2006 | Program decade (preferred analytic window) |
| `br`   | 1992–2002 | Barham & Rowberry (2013) replication window |

**Design:** the BR replication regression in AT3/AT5 is **always run over 1992–2002**
(BR's own window). `$window` changes *only* the panel-completeness screen, hence the
municipality sample. A **shorter** window requires completeness over fewer years, so
**more municipalities** are retained — this is why `br` recovers the count toward BR's
reported 1,961, while the full 1990–2017 balance drops it to ~1,422. This isolates the
pure sample-composition effect (same regression window, different municipality set).

- `full` preserves the **original** panel screens exactly (require all 29 pop-years
  1990–2018, then balanced 1990–2017); `prog`/`br` require completeness only within
  the chosen window.
- `01_` saves `aamr_regression_municipality_gender_tb_<window>.dta` plus the canonical
  name under `full`; `02_` loads the matching windowed file (falling back to the
  canonical file if it hasn't been rebuilt). To compare, set `$window` and re-run
  `01_` then `02_` for each of `full`/`prog`/`br`.

> **Caveat:** running `02_` under `prog`/`br` also truncates the *non-BR* tables
> (e.g. T2, mechanisms) to that span, since the whole master file is restricted. For
> the municipality-count comparison the relevant outputs are AT3/AT5. The AT4
> robustness matrices and BR event-study figures are pinned to 1992–2002.

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

## Conference Discussant Comments — Status Tracker

Paper: *Do CCT Programs (Really) Reduce Mortality? Ten-Year Evidence from Mexico*

### Major Comments

| # | Issue | Status | Output / Notes |
|---|-------|--------|----------------|
| 1 | Weighting: BR unweighted result driven by small municipalities (SHW 2015, JHR) | **Done** | `AT5_BR_trimming.tex` — 5 cols: BR original, UW replication, W replication (AT3 Panel C), ex. bottom 10%, ex. bottom 25% (50% excluded removed) |
| 2 | Health channel: ENCEL health visit data not exploited (healthcare utilization, 1999 ENCEL) | **In Progress** | `T3_experimental.tex` — total_visits col 5 (65+) and col 6 (51+, Gertler 2000 comparison). SPSS import simplified; col 5 `if _rc==0` bug fixed; non-visitors zero-filled. Appendix `AT_elderly_only_hours.tex` — weekly hours for elderly-only households (no children), 3 panels as columns |
| 3 | Intensity variation reflects locality composition | **Pending (text only)** | Footnote at **line 171** needs expansion: municipality intensity is a function of locality poverty-score composition; cite P&V (2023) Figures 2–3 |
| 4 | Correlation between Intensity_1999 and Intensity_2005 + trend×SES robustness | **Partially Done** | **Robustness (done):** `AT_ses_trend.tex` + `AF_ses_trend.pdf` — 3 specs: (1) baseline W+SP, (2) +trend×im_mun_1990 continuous, (3) +trend×1990 marg.-index quintile bins (P&V 2023 style; fixed from 8 raw SES components). **Correlation text (pending):** add sentence near line 171 in main .tex citing P&V fn. 18 (65% variance) + in-sample R² from `reg inten2005 inten1999 if $sample_marg` on municipality cross-section. Proposed text saved in Detailed Approaches below. |
| 5 | β₁ (Intensity_2005) / θk event study not shown | **Done** | `AF_beta1_sex.pdf` — θk pooled/female/male; `AF_beta1_wuw.pdf` — pooled weighted vs. unweighted |
| 6 | Minimum detectable effect / null result analysis | **Assessment Done** | Awaiting user confirmation to implement CI bounds in Stata |
| 7 | Direct vs. indirect transfer framing | **In Progress** | Reframe mortality effect: direct transfer (apoyo alimentario — fixed base grant, NOT conditional on kids, paid to household *titular*/head) vs. indirect (apoyo educativo — child-school-conditional grants). PROGRESA receipt is a single line in all data (ENIGH `P046`/`P059`; admin records) — NOT decomposable into the two components. **Identification trick:** elderly-headed households with **no children** receive *only* the apoyo alimentario → total transfer = direct transfer by construction; elderly head (`renglon==1`) receives it directly. `AT_elderly_only_hours.tex` isolates this subsample's labor-supply response. **Direct-transfer elasticity: FEASIBLE (not blocked). No transfer-amount microdata exists, so IMPUTE the apoyo alimentario from the published program schedule.** Early-phase apoyo alimentario (the direct, non-kid-conditional grant paid to the *titular*/head): **≈90 pesos/month per household in 2nd-half-1997/1998 (≈US$7), flat per household, conditional on health-clinic compliance, NOT a function of # children; inflation-adjusted semiannually → ~115–125 pesos/month nominal by 1999** (real value held ~constant at 1997 level). Indirect part = apoyo educativo/becas (60–135 primary, ~190–305 secondary, kid- and grade-conditional); household *tope*/cap ≈695–750 pesos/mo (1998–99). Imputed direct transfer for elderly-headed/no-children eligible HHs = apoyo alimentario schedule amount, deflated to project's real-2025-USD base. **VERIFY exact per-semester pesos against Skoufias (2005, IFPRI RR139) Table 2.1 and Schultz (2004, JDE) before hard-coding.** |

### Minor Comments

> Comments 2–6 were duplicates of Major Comments 2–6 and have been merged there. Minor comments begin at 7.

| # | Comment | Type | Status | Notes |
|---|---------|------|--------|-------|
| 7 | Age sub-groups (50–64, 65+, 65–69, 70+) | Implementation | **Done** | Table: `AT_age_subgroups.tex` |
| 8 | Cancer/ICD coding tension (text) | Text | **Not Started** | 1–2 sentences after Romano-Wolf paragraph |
| 9 | Life expectancy motivation (intro) | Text | **Not Started** | 1–2 sentences; cite Einav & Finkelstein (NBER 2026) |
| 10 | Table 1 consistency: 1990 SES, add po2sm | Implementation | **Done** | Match archive file; use 1990 census for SES variables; add po2sm column |
| 11 | Progresa enrollment/take-up rates | Text | **Not Started** | Brief footnote |

> **Instructions for Claude:** Update both tables whenever a comment is resolved. Mark status as **Done** and record the output filename or text change. Always update CLAUDE.md and commit before ending a session.

### Detailed approaches (so they survive context compression)

**Comment 6 — MDE / null-result analysis (full assessment).** Based on T2 col 4 SE ≈ **1.464**. Four options:

| Option | What | Result | Code |
|--------|------|--------|------|
| 1. MDE | Min. effect detectable at 80% power | **≈4.1 deaths/1,000** — larger than BR's *weighted* −3.74, smaller than BR's *original* −6.37 → "powered to detect BR's original magnitude, not their weighted estimate" | Stata (shares regression call w/ opt 2) |
| 2. CI as credibility interval | Use estimate's CI as the argument | CI lower bound ≈ **−3.6**: rules out BR original −6.37, does *not* fully rule out weighted −3.74 | No code — text |
| 3. *70 y Más* structural bound | Benchmark vs. direct-elderly-transfer program | Progresa's *indirect* elderly channel ⊂ household transfer ⇒ smaller than *70 y Más* direct ≈**2.5 deaths/1,000**. MDE > structurally-expected effect ⇒ non-detection is **expected, a positive framing**. Cites Menares (JHR) | No code — text |
| 4. TOST equivalence | Formal equivalence test | With δ=2 **likely fails** (CI LB −3.6 outside [−2,+2]); needs δ≈3.6 to pass — hard to motivate | Stata, fragile |

**Recommendation:** implement **1+2** in Stata (one regression call), add **3** as a text paragraph, **skip 4** unless discussant demanded formal equivalence. *Awaiting user go-ahead to implement.*

**Intensity_1999 vs. Intensity_2005 correlation (identification of the two-phase design; relevant to comments 4 & 5).** Discussant concern: the two intensity measures are collinear, so can β₀ (1999) and β₁ (2005) be separately identified? **P&V (2023), footnote 18:** *"In sample municipalities, enrol2005 accounts for 65% of the variance of enrol1999."* Answer the discussant wanted: **report the shared-variance number (high but not fatal), then show the coefficient is stable after adding the trend controls** (the comment-4 `AT_ses_trend.tex` table is that stability evidence). TODO: also compute the in-sample analog (`correlate inten1999 inten2005` / R² of `reg inten1999 inten2005`) to compare against P&V's 65%. Proposed text (near line 171 in main .tex): *"The two phases are related: Intensity_2005 explains approximately 65% of the variance in Intensity_1999 \citep[fn.~18]{parker2023conditional}, reflecting the cumulative nature of program rollout. We include β₁ to partial out later-phase effects that would otherwise contaminate β₀; its inclusion is motivated by Parker & Vogl (2023) who show that omitting it biases the early-phase estimate upward."*

---

## Notes for Contributors

- All paths to external data are hardcoded in each `.do` file — update the `global` or `local` path macros at the top of each script before running.
- The sample is restricted to **highly marginalized municipalities** (`gm_mun_1990 == 4 | 5`) throughout.
- Scripts use **municipality and year fixed effects** — ensure panel IDs are correctly set (`xtset municipality year`).
- Regressions cluster standard errors at the **municipality level**.
- Figures are saved as `.png` or `.pdf` — output directories must exist before running.
