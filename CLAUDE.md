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
| 2 | Health channel: ENCEL health visit data not exploited (healthcare utilization, 1999 ENCEL) | **In Progress — blocked on ENCEL98M health module** | `T3_experimental.tex` — total_visits col 5 (65+) and col 6 (51+, Gertler 2000 comparison). SPSS import simplified; col 5 `if _rc==0` bug fixed; non-visitors zero-filled. Appendix `AT_elderly_only_hours.tex` — weekly hours for elderly-only households (no children), 3 panels as columns. **Two-round pooled spec (to match Gertler 2000 Table 6, which pools waves 3+4 and gets N=15,399 for 51+ vs. our current col 6 N≈5k) is blocked**: see "ENCEL98M data search" note below. |
| 3 | Intensity variation reflects locality composition | **Pending — converges with IADB thread** | Footnote at **line 171** needs expansion: municipality intensity is a function of locality poverty-score composition; cite P&V (2023) Figures 2–3. **Shared deliverable D0/W-fig (see IADB synthesis):** replicate P&V Fig 3 (municipality enrollment vs marginality percentile, by phase) — feasible; Fig 2 (locality) not replicable (data gap). |
| 4 | Correlation between Intensity_1999 and Intensity_2005 + trend×SES robustness | **Partially Done** | **Robustness (done):** `AT_ses_trend.tex` + `AF_ses_trend.pdf` — 3 specs: (1) baseline W+SP, (2) +trend×im_mun_1990 continuous, (3) +trend×1990 marg.-index quintile bins (P&V 2023 style; fixed from 8 raw SES components). This is the analogue of P&V's eq. (3) only — see IADB-3 deep dive for P&V's eq. (4), a more granular locality-composition-share control we don't yet have. **Correlation text (pending):** add sentence near line 171 in main .tex citing P&V fn. 18 (65% variance) + in-sample R² from `reg inten2005 inten1999 if $sample_marg` on municipality cross-section. **This is IADB synthesis item W5 / Phase-0 0a + fn-18 rows 1–2 (replicable); row 3 (locality shares) not.** Proposed text saved in Detailed Approaches below. |
| 5 | β₁ (Intensity_2005) / θk event study not shown | **Done** | `AF_beta1_sex.pdf` — θk pooled/female/male; `AF_beta1_wuw.pdf` — pooled weighted vs. unweighted |
| 6 | Minimum detectable effect / null result analysis | **Assessment Done — extended to AT3/AT4/AT5** | MDE cross-checked across T2, AT3/AT5 (BR design+sample), AT4 (adapted design) using real SEs from generated tables. Every column clears BR's original (−6.37); most also clear BR's weighted (−3.74) except T2 col 4 and AT4 col 3. See Detailed Approaches. Awaiting user confirmation to implement as in-Stata calculation. |
| 7 | Direct vs. indirect transfer framing | **In Progress** | Reframe mortality effect: direct transfer (apoyo alimentario — fixed base grant, NOT conditional on kids, paid to household *titular*/head) vs. indirect (apoyo educativo — child-school-conditional grants). PROGRESA receipt is a single line in all data (ENIGH `P046`/`P059`; admin records) — NOT decomposable into the two components. **Identification trick:** elderly-headed households with **no children** receive *only* the apoyo alimentario → total transfer = direct transfer by construction; elderly head (`renglon==1`) receives it directly. This subsample's labor-supply response is shown **only as columns in T3** (no standalone appendix table — the `AT_elderly_only_hours*.tex` write blocks were deleted per user; the `_eoh`/`_eob` computation loop is kept to feed the T3 columns). **T3 now operationalizes the contrast in the main table:** new **column 2 = weekly hours in elderly-only households** (`only_elderly==1 & age97>=65`, same DiD/muni-FE/eligible spec as col 1), placed next to col 1 (all eligible elderly, whose household transfer is dominated by the indirect becas). Col 1 vs col 2 = whole/indirect transfer vs direct-food-transfer-only. `03_experimental.do`: `_eoh` locals now computed *before* the T3 write block (shared with the appendix table); `tables.tex` floatfoot updated for the inserted column and renumbered (1)=hours, (2)=hours elderly-only, (3)–(5)=living arr., (6)–(7)=visits. **CAVEAT (addressed):** `only_elderly` is measured *contemporaneously* each round and is itself a treatment outcome (T3 col 5) → conditioning on it risks endogenous-sample/bad-control bias. **Now handled by a baseline-fixed version** `only_elderly_base` (`= max(cond(ronda==1, only_elderly, .))` by folio; composition frozen at 1997/pre-treatment). Both definitions shown side by side: Contemporaneous (`_eoh`) and baseline-fixed (`_eob`) were shown side by side to compare; they came out near-identical, so **user kept only the baseline-fixed one** as T3 col 2 (`_eob`, superscript §); contemporaneous dropped. No standalone appendix tables (both `AT_elderly_only_hours*.tex` write blocks deleted per user). `T3_experimental_slide.tex` carries the same single elderly-only column (pooled). Composition restriction = tight `only_elderly` (excludes anyone 18–60), *confirmed by user*: they want households where the elderly is surely the recipient — any 15–64 member could be the titular instead, so working-age adults must be excluded (not just kids <15). `tables.tex` floatfoot renumbered: (1)=hours, (2)=hours eld.-only contemp., (3)=hours eld.-only baseline, (4)–(6)=living arr., (7)–(8)=visits. **Same endogenous-composition concern applies to `AT6_expenditures_elderly`:** its `elderly97` heterogeneity split uses baseline *age* (`age97`) but *contemporaneous presence* (collapsed `(sum) by hhid year`), so a household flips elderly/non-elderly if an elderly member moves in/out. Was shown as two panels (A = contemporaneous `elderly97`, B = baseline-fixed `has_elderly_base`) to compare; they came out the same, so **user kept only Panel A** (contemporaneous) — AT6 reverted to single panel, `has_elderly_base` code removed. Magnitude of the concern is bounded by T3 living-arrangement effects, which are small/mostly insignificant. **T3 restructured (direct-transfer framing):** cols (1)-(5) = full eligible age-65+ sample (weekly hours, live alone, with children, only elderly, total visits); cols (6)-(7) = older-adults-only households (`only_elderly_base==1`) reporting weekly hours (`_eob`) and **total visits (`_tveo`)** — the two sample groups separated by a spanning header ("All Eligible Older Adults" vs "Older-Adults-Only Households"). The former age-51+ Gertler visits column was dropped. Slide table mirrors this. **New appendix table `AT_elderly_transfer.tex`** (label `at:elderly_transfer`, next to AT6): **exact same layout/outcomes as AT6** (HH food/health expenditure — Food Log, Food Share, Health Log, Health Share) but restricted to **older-adults-only households** (`only_elderly_base==1`) and split by **eligibility** (`elig_bin = eligible==1`) instead of elderly presence. DiD `i.year##i.contba##i.elig_bin`, base 1998, muni FE, locality-clustered. Rows: Treatment×1999 (ineligible), Differential (eligible), Control Mean (1998), Obs. The eligible differential isolates the direct food transfer (only eligible HH receive it). `only_elderly_base` added to the AT6 collapse so it survives to household level. AT6 itself unchanged. `tables.tex` T3 floatfoot rewritten for the new column layout. **Direct-transfer elasticity: FEASIBLE (not blocked). No transfer-amount microdata exists, so IMPUTE the apoyo alimentario from the published program schedule.** Early-phase apoyo alimentario (the direct, non-kid-conditional grant paid to the *titular*/head): **≈90 pesos/month per household in 2nd-half-1997/1998 (≈US$7), flat per household, conditional on health-clinic compliance, NOT a function of # children; inflation-adjusted semiannually → ~115–125 pesos/month nominal by 1999** (real value held ~constant at 1997 level). Indirect part = apoyo educativo/becas (60–135 primary, ~190–305 secondary, kid- and grade-conditional); household *tope*/cap ≈695–750 pesos/mo (1998–99). Imputed direct transfer for elderly-headed/no-children eligible HHs = apoyo alimentario schedule amount, deflated to project's real-2025-USD base. **VERIFY exact per-semester pesos against Skoufias (2005, IFPRI RR139) Table 2.1 and Schultz (2004, JDE) before hard-coding.** |

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

**MDE cross-check across BR-comparison tables (for a presentation slide: "our design has power to detect BR-original-sized effects, so the null is not a power artifact").** User asked whether AT4_BR_robustness and AT5_BR_trimming (cols 2–3) — the tables closest in sample/design to BR (2013) — are more appropriate MDE benchmarks than the headline T2 col 4. Pulled actual SEs from the generated `.tex` files (not hand-derived) and computed MDE = 2.8 × SE (95% two-sided sig., 80% power) for each:

| Table / column | Design | Sample | SE | MDE | Clears BR original (−6.37)? | Clears BR weighted (−3.74)? |
|---|---|---|---|---|---|---|
| T2 col 4 (main, Pooled) | Weighted + SP, Post interaction | Full panel, HM, through 2006 | 1.464 | **4.10** | ✓ | ✗ |
| AT3 Panel B / AT5 col 2 (Pooled) | BR's own design: continuous 2-yr lag, no post | BR sample (1998/99 incorp.), 1992–2002 | 1.256 | 3.52 | ✓ | ✓ |
| AT3 Panel C / AT5 col 3 (Pooled) | Same, weighted | Same | 0.786 | **2.20** | ✓ | ✓ |
| AT4 col 1 (Pooled) | Adapted design: Intensity×Post | BR sample, unweighted, 1992–2002 | 1.214 | 3.40 | ✓ | ✓ |
| AT4 col 2 (Pooled) | Adapted design, weighted | BR sample | 0.807 | 2.26 | ✓ | ✓ |
| AT4 col 3 (Pooled) | Adapted design, unweighted | HM sample (not BR sample), 1992–2002 | 2.107 | 5.90 | ✓ (thin margin: 5.90 vs 6.37) | ✗ |
| AT4 col 4 (Pooled) | Adapted design, weighted | HM sample | 1.261 | 3.53 | ✓ | ✓ |

**Key finding: every single column above clears BR's *original* unweighted magnitude (−6.37)** — including AT4 col 3, which the user initially wanted to exclude as "not comparable" (HM sample ≠ BR sample) but which actually already clears the bar on its own, just with the thinnest margin (5.90 vs. 6.37). The sample-non-comparability argument is only *needed* for the stronger claim of also clearing BR's *weighted* estimate (−3.74), which AT4 col 3 fails (5.90 > 3.74) while every other column passes.

**AT3/AT5 Panel B–C (BR's own sample + BR's own continuous-lag design, no post-interaction) is the single most direct/reassuring comparison** — same design AND same sample as BR (2013), not just an adapted design on their sample. MDE there (2.20–3.52) clears both BR benchmarks with the most room to spare.

**Recommended slide line (short, for end of presentation):**
> *"Our design is powered to detect BR's original effect (MDE ≈ 4.1 vs. −6.37 deaths/1,000 in the main long-run table; MDE as low as 2.2–3.5 in BR's own sample/design, Appendix Tables AT3–AT5) — the null is not a power artifact."*

**Framing guidance:** anchor the claim to BR's **original** unweighted estimate specifically (not "BR's findings" generically) — every column clears that bar, so no caveats are needed. Only stretch to "also powered for BR's weighted estimate" if citing AT3/AT5 Panel B–C or AT4 cols 1/2/4 specifically; AT4 col 3 does not clear that stricter bar. *Status: numbers verified from generated `.tex` output (not yet computed as an in-Stata MDE calculation — recommend adding `di 2.8*_se[...]` right after each cited regression so the number is code-derived rather than hand-copied before it goes on a slide).*

**Intensity_1999 vs. Intensity_2005 correlation (identification of the two-phase design; relevant to comments 4 & 5).** Discussant concern: the two intensity measures are collinear, so can β₀ (1999) and β₁ (2005) be separately identified? **P&V (2023), footnote 18:** *"In sample municipalities, enrol2005 accounts for 65% of the variance of enrol1999."* Answer the discussant wanted: **report the shared-variance number (high but not fatal), then show the coefficient is stable after adding the trend controls** (the comment-4 `AT_ses_trend.tex` table is that stability evidence). TODO: also compute the in-sample analog (`correlate inten1999 inten2005` / R² of `reg inten1999 inten2005`) to compare against P&V's 65%. Proposed text (near line 171 in main .tex): *"The two phases are related: Intensity_2005 explains approximately 65% of the variance in Intensity_1999 \citep[fn.~18]{parker2023conditional}, reflecting the cumulative nature of program rollout. We include β₁ to partial out later-phase effects that would otherwise contaminate β₀; its inclusion is motivated by Parker & Vogl (2023) who show that omitting it biases the early-phase estimate upward."*

**Comment 2 — ENCEL98M health module: data gap blocking the two-round pooled spec.** Gertler (2000) Table 6 pools person-level utilization data from ENCEL's **third and fourth waves** (per his own text) to get N=15,399 for age 51+; our current `T3_experimental.tex` col 6 uses only the **November 1999** wave (`socioec_encel_99n.sav`, the file whose `n1390X`/`n1410X` variables feed `total_visits` in `03_experimental.do` lines 380–449) and gets N≈5k. Wave-naming resolution (via web search of Skoufias/IFPRI "Impact of Progresa on Consumption" final report, since PROGRESA's official codes use *program*-year labels, not survey-year labels): **ENCEL98M = fieldwork in June 1999** (the wave immediately before ENCEL99N/November-1999). This is the file we need but don't have.

- **Checked the file the user has for ENCEL98M** (`.sav`, 134,604 obs × 393 vars, `folio`/`renglon` keyed). It is the **household socioeconomic questionnaire** — education attitudes, food-consumption diary (p034–p039), household expenditure (p044–p051), a *household-level* health-access module (p082–p097: clinic hours, wait time, cost, satisfaction — not a per-person visit tally), women's reproductive health, gender-attitudes, and a children-only health roster (p001–p076). **It does not contain the person-level utilization-count variable** (the `n1390X`/`n1410X`-style "which household member used which service type, how many times in the last 4 weeks" roster) that Gertler's outcome and our `total_visits` variable require. That roster likely lives in a **separate health/"salud" module file** for the same round, distributed alongside — not bundled into — the socioeconomic file.
- **Searched for a download source.** The original evaluation portal (`evaluacion.oportunidades.gob.mx:8010`) is dead (user confirmed link doesn't work). Best remaining lead: IFPRI's "Mexico, Evaluation of PROGRESA" dataset on Harvard Dataverse (`hdl:1902.1/18235`) — file manifest not confirmed (Dataverse blocked automated fetch with 403; needs manual browser check). Fallback: contact `evaluacion@oportunidades.gob.mx` or INSP (co-ran the health-specific surveys) directly.
- **Status: blocked, awaiting user to locate the ENCEL98M health/salud file** (via Dataverse manual check or direct contact with evaluation team/INSP). Once obtained, implement the two-round pool (add `ronda==4` back at `03_experimental.do` line 130, stack `total_visits` from both 1999 waves, and switch the 51+ cutoff in col 6 to contemporaneous age rather than `age97` baseline age — see prior assessment on why col 6 N is smaller than Gertler's).

**UPDATE — user located the correct file: `bd_rur_1999_m_socioeconomico_2005-07-06/socioec_encel_99m.sav`**, containing the `m149{01-07}{,a,b,c}` variable block (7 service-type questions × up to 3 person-slots). This is very likely **ENCEL98M/June-1999 = `ronda==4`** in the panel (inferred from the existing `ronda==1/3/5` → 1997/1998/1999-Nov mapping leaving `ronda==4` as the only unassigned slot before Nov-1999; not yet confirmed against a date variable in the panel).

**Structure confirmed via `codebook m14901 m14901a m14901b m14901c, compact`:**
- `m1490X` (X=1..7): household-level Yes/No/NR gate question ("did any member use service type X in the last 4 weeks?"), obs≈22,334 (≈full household count), values {1,2,9}.
- `m1490Xa/b/c`: **renglón (line number) of the 1st/2nd/3rd household member** who used that service — inferred from (i) monotonically shrinking obs counts across slots (337→39→9, consistent with sequential person-slots filled in order) and (ii) value ranges (1–12, 1–10, 2–9) matching household-member line numbers, not plausible visit-frequency values.

**Critical gap: no companion "how many times" stem found** (unlike the November file's `n1390X` [renglon] + `n1410X` [count] *pair*). The `m149` block appears to capture only the **extensive margin** — *which* members used *which* of 7 service types — not a visit **count**. If confirmed, June-wave data cannot feed a literal "total visits" sum comparable to the November wave's `n1410`-based counts; pooling them as-is would silently mix two different outcome definitions (a true count vs. a capped 0–7 "how many distinct service types" measure) in one regression.

**RESOLVED — user located the count companion: `m151{XX}{k}`.** Confirmed via `codebook m15106a` (label "...cuantas veces (NOMBRE) acudio...", small-integer values = genuine visit counts). This IS the same renglon/count pair structure as `n1390X`/`n1410X` in the November file, just with 7 service types (01–07, zero-padded) instead of 4, and different stem names (`m149`=renglon, `m151`=count vs. November's `n1390`=renglon, `n1410`=count).

**IMPLEMENTED** in `03_experimental.do`:
- New block (inserted right after the November `total_visits` finalization, before `gen post=...`) parses `socioec_encel_99m.sav` identically to the November block's pattern: loops `sn` in `01..07` × `k` in `a,b,c`, using `m149{sn}{k}` as renglon and `m151{sn}{k}` as visit count, collapses to one row per `folio renglon`, produces `total_visits_june`, zero-fills non-visitors present in the SPSS file. Merged onto the working panel by `folio renglon` only (no year condition), so the same June value is replicated across a person's kept-round rows — this is intentional (see below), not a bug.
- **Assumptions carried over from the November block's conventions, NOT independently confirmed for this file** — flag for the user to sanity-check once run: (i) `renglon==9` treated as an NS/NR sentinel and dropped (matches the household gate question's `9`=NR code, but not verified for the person-slot fields specifically); (ii) `n_visits>=90` treated as a top-coded/missing sentinel — no confirmed exact cutoff was found in the codebook output shared so far (only values 1–4 were observed in the `m15106a` sample), so this is a conservative guess.
- New block after the existing per-wave "Total visits" regressions stacks `total_visits_june` and the November `total_visits` (extracted as a person-level constant via `bys pid: egen ... = max(cond(year==99, total_visits, .))`, since it's otherwise only populated on `year==99` rows) into one long person-wave file, tagged `wave99` = "n"/"m", and reruns the treat-vs-control comparison (`contba` on `total_visits_pooled`, municipality FE, eligible sample) at **both** age65+ and age51+ cutoffs (age measured at baseline, `age97`, consistent with the existing single-wave columns).
- New appendix table `AT_gertler_pooled.tex` (label `at:gertler_pooled`, `tables_app.tex`): 6 columns — Pooled/Female/Male × {Ages 65+, Ages 51+ (Gertler comparison)}. Note explicitly tells the reader to compare col (4)'s N to Gertler's reported 15,399.
- **Status: code written, NOT YET RUN against real data** (no ENCASEH/ENCEL data present in this sandbox). User needs to run `03_experimental.do` and report back: (a) the diagnostic `di` counts printed at each step (person-slot record counts per `sn`/`k`, pre/post zero-fill counts), (b) whether the resulting age51+ pooled N approaches Gertler's 15,399, and (c) whether the `renglon==9`/`n_visits>=90` sentinel assumptions look correct given the actual data (e.g., via `tab` on the raw `m149`/`m151` values before the drop/missing recodes, if the pooled N looks off). If the pooled N still falls well short of 15,399, the next lever (per the original assessment) is switching from baseline `age97` to contemporaneous age at each wave for the 51+ cutoff.

---

## IADB Presentation Comments (HBL Series) — Status Tracker

> **Separate from the "Conference Discussant Comments" tracker above.** These are from the **IADB HBL-Series seminar** ("Do CCT Programs Really (Reduce) Mortality? Ten-Year Evidence from Mexico"), summarized from a Spanish transcript (source: `literature/Resumen_Comentarios_HBL_Progresa.docx`, itself a Copilot-Opus summary — treat wording as paraphrase, not verbatim quotes). Translated/condensed to English and contextualized against the current codebase. Prefix **IADB-#** and tag by commentator to keep them distinct. Several overlap with issues already worked in the conference tracker (cross-refs noted).

| # | Commentator | Issue (short) | Status | Cross-ref |
|---|---|---|---|---|
| IADB-1 | Óscar | Why does the *identity* of the recipient matter (vs. just a budget-constraint shock)? Reduced form can't see intra-HH allocation. | **Partially addressed (framing)** | Conf. Comment 7 |
| IADB-2 | Eduardo | Endogeneity of treatment intensity (higher intensity ↔ deeper poverty ↔ worse mortality). | **Addressed in framing, UNDER-LEVERAGED** | Conf. Comments 3, 4 |
| IADB-3 | Óscar | "Forbidden comparisons" / staggered adoption; two-period intensity fix may not solve it. Continuous-DiD (dCDH) is the modern rebuttal. | **NEW — and paper's fn.\ is vulnerable** | — |
| IADB-4 | Óscar | Population weights are a *parametric* way to absorb size heterogeneity; add non-parametric subsample-by-size. | **Partially addressed** | AT5 trimming |
| IADB-5 | Luis | Heterogeneity by *beneficiary vulnerability*, not municipality size. | **NEW — not started** | — |
| IADB-6 | León + Eduardo | Null may reflect poor health-*supply* quality, not program failure; use hospital openings. | **Partially addressed** | Conf. Comment 2 |
| IADB-7 | Leonel | Migration as confounder (short-run ↓ intl. migration; long-run possibly ↑) → compositional bias. | **Addressed (text + MHAS)** | AT_migration_robustness |

### Detail & assessment (condensed)

**IADB-1 (Óscar) — recipient identity vs. budget-constraint shock.** *Comment:* Without an explicit intra-household bargaining model, hard to justify theoretically why *who* receives the transfer (the mother/titular) matters — economically the household budget constraint shifts and resources get reallocated internally across generations. Second, methodological: a reduced-form null can't distinguish (i) resources never reached the elderly vs. (ii) they did but were insufficient. *Our response:* acknowledged; mechanisms section (nutrition spend, doctor visits) speaks to it, but no *individual*-level consumption data (only income), and ENIGH is underpowered for the window. *Assessment:* This is exactly the tension our recent direct-vs-indirect-transfer work targets — the **older-adults-only-household** cut (T3 cols 6–7, `AT_elderly_transfer`) is the closest thing to isolating "resources that reach the elderly directly," since those HHs receive only the apoyo alimentario. Worth explicitly framing that exercise as the response to Óscar's (i)-vs-(ii) point. Fully resolving the bargaining critique is out of scope (data-limited), but we can state the limitation cleanly and lean on the elderly-only subsample as partial identification.

**IADB-2 (Eduardo) — intensity endogeneity.** *Comment:* higher-intensity municipalities are likely poorer, and poverty predicts worse mortality → bias. *Our response (verbal, at the seminar):* (i) restrict to highly-marginalized municipalities (baseline comparability); (ii) use Intensity_2005 to absorb within-group wealth heterogeneity. *Assessment (revised after reading main.tex — earlier "Addressed" was based on the verbal answer + design elements, not a verified read of the paper):* The **core defense IS in the active text** — line 175 (HM restriction mitigates differential-trends confounding) and lines 200–201 (full parallel-trends paragraph naming the threat — "timing of early enrollment systematically related to pre-existing health infrastructure, local state capacity…" — and the defenses: HM restriction, muni FE, event-study pre-trends, ITT framing). Municipality FE absorb the time-invariant poverty *level*; HM restriction + event study handle differential *trends*. So the concern is answered at the parallel-trends level. **Two concrete gaps (user's intuition was right):** (a) `AT_ses_trend` (trend × baseline marginalization, continuous + quintile) — the single most direct empirical rebuttal to "intensity ∝ poverty ∝ differential mortality trends" — is **NOT `\ref`'d anywhere in main.tex**; it exists as a table but is never invoked. Highest-value fix = one sentence in §Empirical Strategy/§Robustness citing it. (b) The verbal "Intensity_2005 absorbs wealth heterogeneity" argument is **not** how the paper frames Intensity_2005 (paper: partials out *later-phase timing* via the negative early/late correlation, lines 197, 200) — do NOT graft the wealth-absorption framing onto the paper; the timing framing is cleaner and AT_ses_trend is the right vehicle for the wealth worry. Net: not new estimation, but a real writing gap (cite the SES-trend table).

**IADB-3 (Óscar) — staggered adoption / forbidden comparisons (the most-debated point).** *Comment:* fixing intensity at just 1999 and 2005 to handle staggered rollout does **not** clearly solve the Callaway–Sant'Anna forbidden-comparison problem — real intensity also varied in 2000–2004, and those intermediate cohorts still contaminate already-treated vs. newly-treated comparisons. Óscar was tentative ("I need to think more, but ignoring that intensity keeps changing doesn't remove the staggered-adoption problem") and offered two concrete robustness paths: **(A)** Callaway–Sant'Anna with **continuous** treatment at the municipality level (noted the continuous-DiD literature is moving fast; municipal intensity is computable even though original assignment was at the unobserved *locality* level); **(B)** **binarize** treatment (e.g. ≥15% intensity = treated, ~0 = control) and run a standard year-by-year event study — called this "super clean" and "low-hanging fruit." *Our response:* accepted both as reasonable robustness; argued current spec loads intermediate heterogeneity onto the 2005 coefficient and the paper's relevant variation is the 1999 phase. *Assessment (revised — my earlier "continuous CS is awkward/needs a clean cohort" was WRONG; the continuous-dose estimators are built for exactly a ramping treatment):*

- **The paper's own footnote is the vulnerability.** `main.tex` line 173 fn: *"Staggered adoption estimators \citep{callaway2021difference, sun2021estimating, de2020two} require a clearly defined binary treatment date… Our setting does not satisfy this…"* This is outdated, and **`de2020two` IS de Chaisemartin & D'Haultfœuille** — the very authors whose continuous-treatment DiD (`did_multiplegt` / `did_multiplegt_dyn`, and the "DiD for continuous treatments" paper) explicitly relax the binary-date requirement and handle time-varying continuous doses. Citing dCDH to justify *not* using dCDH-style estimators is backwards; a referee/Óscar catches it immediately. **Fix the footnote regardless of what estimation we add.**
- **Reconciling continuous-DiD with the data (user's specific question — locality treatment, municipal outcome):** (1) *Feasibility ≠ aggregation.* dCDH-continuous runs at the municipality-year level (where mortality lives) with municipal intensity as the continuous dose — feasible with current data; no locality-level mortality needed. The ramping dose is what these estimators are *for*. (2) *The locality-vs-municipality mismatch is about the estimand, not feasibility.* The estimand is a **municipal dose-response** — identical object to the current β₀ in eq. (1); dCDH just estimates it robustly to heterogeneous/dynamic effects. State plainly: "estimand is a municipal dose-response; the original locality-level randomization cannot be exploited for mortality (vital stats are municipal only) — that experimental variation is instead used for the Table 3 mechanism outcomes, observed at the household level." (3) *What is genuinely forgone:* experimental ID for mortality — but that was never available (mortality is inherently observational-municipal); dCDH upgrades the observational design's robustness, it does not recover RCT-grade ID.
- **The one real practical check before committing to dCDH-continuous:** it identifies off municipalities whose dose *changes* t−1→t, using "stayers" (stable dose) as controls. A broadly monotonic universal rollout leaves few stayers → thin identifying variation. **Check the distribution of year-on-year Δintensity (how many municipality-years ≈ 0 change).** This determines whether dCDH-continuous is well-powered.
- **Why Option B (binarize) is still "low-hanging fruit":** `treated = inten1999 crosses ~15%` gives a clean first-crossing *entry date*, making Callaway–Sant'Anna / Sun–Abraham directly usable and sidestepping stayer-scarcity entirely. B = clean staggered-timing design; dCDH-continuous = more faithful (keeps the dose) but more demanding. **Recommend: (0) fix the line-173 footnote; (1) Option B event study [fast, uses existing `AF_beta1_*`/`AF_ses_trend` machinery, threshold sensitivity grid]; (2) dCDH-continuous (`did_multiplegt_dyn`) as the heavier, modern-standard robustness, after checking stayer availability.** Needs a new bib entry for the continuous-treatment dCDH paper.

**DEEP DIVE — read `literature/Parker and Vogl 2023.pdf` directly (pp. 10–13) to check whether P&V's own paper addresses (a) why `enrol2005`/`Intensity_2005` doesn't fully net out locality-level wealth heterogeneity, and (b) why "loading intermediate variation onto the 2005 coefficient" doesn't solve forbidden comparisons. It does address both, explicitly — and finding (b) has a sharp, previously-missed implication for our paper's line-173 footnote.**

- **(a) Confirmed: P&V themselves flag that `enrol2005ₘ` is an incomplete control.** P&V p.11: *"Figure 3 shows that the relationship between the marginality index and enrolment ratios flattens slightly between the two roll-out phases, suggesting that enrol2005ₘ may not fully capture the unobserved heterogeneity that may be correlated with trends."* Mechanism: Progresa targeting was locality-level (their Fig. 2); municipality aggregates (their Fig. 3) smooth away the within-municipality *distribution* of locality poverty — two municipalities can share identical `enrol1999`/`enrol2005` while differing in whether that intensity comes from a few very-poor localities or many moderately-poor ones, and that compositional difference isn't captured by either scalar. **Footnote 18 quantifies this precisely:** `enrol2005ₘ` alone explains only **65%** of the variance in `enrol1999ₘ`; adding municipality-marginality-percentile indicators → 67%; adding *locality*-marginality-population-shares → 75%. Never 100%, even with three controls stacked.
  - **P&V's fix has two tiers, and we only have the first.** Eq. (3): municipality-marginality-percentile × cohort/year FE — this is our `AT_ses_trend` (trend × baseline `im_mun_1990`, continuous/quintile). Eq. (4), the more granular fix that actually targets *locality*-level composition: shares of the municipality's population living in localities at each percentile of the *locality* marginality distribution, interacted with cohort/year FE (their Fig. 4 heat map visualizes this). **We do not have an analogue of eq. (4).** This is the precise, citable, actionable answer to Eduardo's concern beyond just "we control for Intensity_2005" — building it requires locality-level CONAPO marginality data aggregated to municipality population-shares, merged to the panel. Real data lift, but well-defined and directly modeled on a published, citable precedent.

- **(b) Confirmed, with a sharp twist: P&V explicitly disclaim CS/dCDH for THEIR design — and the reason they can is structurally absent from ours.** P&V p.13, fn. 21 (their own words, note the citations): *"Other recent developments in the interpretation of two-way fixed effects estimators deal with variable treatment timing (De Chaisemartin and d'Haultfoeuille, 2020; Callaway and Sant'Anna, 2021) so do not apply to our design."* **These are the same two citations (`de2020two`, alongside `callaway2021difference`) that appear in our `main.tex` line-173 footnote** — strongly suggesting our footnote was adapted from theirs without re-checking whether the underlying justification transfers.
  - **It doesn't transfer, and here's the precise mechanical reason.** P&V's `t` index is a **birth cohort**, not calendar time: `y_imt` is one cross-sectional observation per individual, `post_t` is fixed by age in 1997, and the same "clock" applies to every municipality at once. There is **no repeated-calendar-time panel per municipality** in their design — no unit is observed evolving across many years with changing treatment status, so the forbidden-comparisons mechanism (which requires exactly that: comparing a long-since-treated unit's own evolving post-treatment trajectory against a newly-treated unit's, across shared calendar time) has no channel to operate through. Their identifying variation is purely cross-sectional (high- vs. low-`enrol1999`, holding `enrol2005` fixed).
  - **Our equation (1) is a genuine calendar-time panel**: `MR_{m,t}` is observed repeatedly for the *same* municipality across 16 calendar years (1991–2006), year FE `γ_t` are estimated off within-year cross-municipality variation in *every year*, and `Post_t` spans a full decade uniformly while `Intensity_1999`/`Intensity_2005` are frozen at two snapshots. This means the model implicitly asserts that `β₀·Intensity_1999 + β₁·Intensity_2005` applies identically to mortality in 1998 and in 2006 alike — years in which municipalities' *actual* realized intensity differed enormously along genuinely different paths (front-loaded vs. back-loaded ramps) even conditional on sharing the same two endpoints. ⚠️ **CORRECTED in FOLLOW-UP 5 below:** the sentence originally here ("this is exactly the repeated-panel structure the forbidden-comparisons critique requires") was **overstated**. A repeated-time panel is *necessary but not sufficient* for forbidden comparisons — you also need staggered *timing*, which our single-1997-break design does NOT have. So this calendar-panel structure creates a **functional-form** concern (constant summary of an evolving dose), NOT a forbidden-comparison one; and P&V are immune for the *same* reason we are (common timing schedule × cross-sectional intensity), not for a structurally different reason. See FOLLOW-UP 5.
  - **Directly answers "can loading it all onto Intensity_2005 fix this":** mechanically, no — `Intensity_2005` is a single time-invariant number interacted with one broad `Post` dummy; it contributes the *identical* amount to the prediction for every post-year. It cannot differentially "absorb" what happened specifically in 2001 vs. 2004 for a given municipality — that within-window path information isn't a regressor at all; it sits in `ε_{m,t}`, correlated with `Intensity_2005` only to the extent the footnote-18-style R² shows (65–75%, never 100%).

**FOLLOW-UP (user pushed on defending the assumption + the 65% correlation) — concrete, low-cost test now available.** User asked how to defend "2000–2005 heterogeneity loads into Intensity_2005," and whether lower Intensity_1999/2005 correlation is "better." Assessment:
- **The defensible version of the assumption is P&V's institutional-timing argument** (p.13: roll-out timing within a phase "reflects idiosyncratic bureaucratic and programmatic considerations"), which argues *composition* (who got added in phase 2) isn't confounded with poverty dynamics. **This does NOT address the calendar-panel problem above** — it defends a different threat. Don't let it stand in for the CS/dCDH point.
- **"Lower correlation = better" is not generally true.** `intensity_new` is cumulative (`pgbenef_new` = "cumulative new benef"), so two cumulative snapshots of the same non-decreasing process would mechanically default to *high* positive correlation; a lower-than-mechanical correlation likely reflects a catch-up/ceiling dynamic (near-universal HM coverage by ~2000, per P&V). Whether that's reassuring or concerning depends on *why* the residual variation exists: if it's exogenous bureaucratic timing (good — real independent information for β₁), vs. if slow-1999 municipalities systematically catch up faster/slower for reasons tied to local state capacity (bad — same confounder in different clothes). **The correlation coefficient alone can't distinguish these two stories.**
- **"Only varies by intensity of a few localities" is a good instinct — quantify it.** Compute `(Intensity_2005 − Intensity_1999) / Intensity_2005` per municipality: if the share of eventual cumulative enrollment achieved *after* 1999 is small for most HM municipalities, that bounds how much the omitted intermediate-window heterogeneity can matter. One `sum` command turns intuition into evidence.
- **The concrete, actionable test (new finding): `inten1997`, `inten1998`, `inten2000`, `inten2002` already exist** in `02_mortality.do` (lines 197–213, built inline from `intensity_new` the same way `inten1999`/`inten2005` are). This means the "loads into 2005" assumption is **directly testable, not just arguable**: (1) swap `Intensity_2005` for `Intensity_2002` and check if β₀ moves; (2) add `Post×Intensity_2000` (or `_2002`) one at a time alongside the existing two regressors and check β₀ stability (expect wider SEs from collinearity among these serially-correlated cumulative snapshots — test point-estimate stability, not precision, and add snapshots one at a time rather than all at once). Stable β₀ = real evidence for the assumption; unstable β₀ = signal to move to the binarized event study or dCDH-continuous approaches instead of continuing to defend the two-snapshot spec. **Not yet run — recommend as the next concrete step before further defending the assumption in text.**

**FEASIBILITY OF THE dCDH/binarized ALTERNATIVES — user's saturation concern (astute; user asked to hold off on any code and just log this).** User worries there may be **no stable ~0% penetration municipalities within the HM sample**, which would block a continuous-treatment estimator and complicate binarization + pre-trend testing; and fears that going time-varying-continuous collapses back to BR. Assessment:
- **The saturation worry is real and well-founded** — P&V p.10: *"The programme was operating in all high and very high marginality municipalities by the year 2000, so we measure the intensity of programme penetration rather than an indicator for any penetration."* This is exactly why P&V (and this paper) use continuous intensity, not a binary treated/never indicator. **All three modern options hinge on the same scarce resource:** binarize-vs-never needs never-treated (≈empty within HM under saturation); binarize + Callaway–Sant'Anna needs spread in the *first-crossing year* (weak if all cross in 1997–98); dCDH-continuous needs *"stayers"* (municipalities with flat year-on-year dose) as controls (scarce under universal ramping). One diagnostic settles all three: distribution of (a) year-on-year Δintensity, (b) first-year-crossing-X%, (c) any HM municipality near 0% throughout.
- **Misconception to correct: continuous ≠ losing the pre-trend test.** `did_multiplegt_dyn` has a `placebo()` option (pre-period placebo estimates = the pre-trend test); `csdid` produces pre-period group-time ATTs. So the real tradeoff is **feasibility under saturation**, NOT "pre-trends vs. continuous." The pre-trend test survives in all these designs; you just don't hand-build the year×intensity interactions — the estimator does.
- **"Back to BR" only if done *naively*.** What made BR unable to test pre-trends was a time-varying lagged dose with **no pre/post anchor** + naive TWFE — not the continuous dose per se. dCDH keeps the continuous time-varying dose AND gives pre-period placebos AND is robust to heterogeneity → it *dominates* BR, it is not BR. A naive continuous-TWFE (contemporaneous/lagged intensity in `reghdfe`) *is* BR and inherits the TWFE-heterogeneity bias.
- **Hidden strength of the current design (the key upside):** the current fixed-1999-snapshot spec is the **most saturation-robust** of the options, because it identifies β₀ off the *cross-sectional spread in the 1999 intensity level* (30% vs. 80% by 1999) — which survives saturation — rather than treated-vs-never or timing variation, which saturation erodes. Binarizing would *discard* exactly the variation that keeps the design feasible. Fixing at 1999 is therefore well-motivated by the saturation dynamics (capturing early-phase spread before universal enrollment compressed it), not just a convenience.
- **Two clean outcomes, both good (the synthesis):** (1) if the intermediate-snapshot stability test above shows β₀ stable → the two-snapshot design is empirically sufficient; no need for dCDH. (2) if the saturation diagnostic confirms few stayers/no never-treated → that is the **correct replacement for the broken line-173 footnote**: not "these estimators require a binary date" (wrong), but *"continuous-treatment/staggered-timing estimators require untreated stayer/not-yet-treated comparison units; within our HM sample, penetration was near-universal by 2000, leaving too few such units; we instead exploit cross-sectional early-phase intensity variation, fixed before saturation, and test robustness to intermediate-year snapshots."* Honest, specific, cites the real data feature, and converts the limitation into a principled design justification. **So the decision is "current design defended by the stability test" vs. "dCDH if the data can feed it" — and the saturation diagnostic decides which, while writing the footnote either way.**
  - **Implication for the footnote fix:** don't just soften the wording — the corrected footnote should explain *why* our setting differs from P&V's (repeated calendar-time panel vs. cohort cross-section), not merely restate a disclaimer inherited from a paper whose immunity claim rests on a structural feature (no calendar-time panel) that our design doesn't share. This is a stronger, more specific version of the "footnote is vulnerable" finding above — worth leading with when drafting the replacement text.

**FOLLOW-UP 2 (user asked: how do csdid/dCDH test pre-trends under continuous treatment; how does BR's forbidden-comparison problem arise; and can a β₀-stability figure + SES-vs-2005 comparison help).** Clarifications:
- **csdid ≠ dCDH; only dCDH takes a continuous dose.** `csdid` (Callaway–Sant'Anna) is *binary, staggered/absorbing* — needs a first-treated-period `gvar`; it's the tool for the *binarized* option, and its pre-trend test is the pre-period group-time ATTs, ATT(g,t) for t<g (negative event-time coefficients). `did_multiplegt_dyn` (dCDH) is the *continuous, non-absorbing, time-varying-dose* tool — identifies off switchers (dose changes t−1→t) vs. stayers (flat dose); pre-trend test = `placebo()`, the *same switcher-vs-stayer comparison run backward in time*. Both need stayer/not-yet-treated units → under saturation the placebo/pre-trend test can be underpowered or infeasible, not just imprecise.
- **BR's forbidden-comparison problem arises *because of*, not despite, the time-varying dose (user's intuition was inverted).** TWFE on a time-varying dose = weighted avg of many dose-change comparisons; some use *already-changed* municipalities (whose effect is still evolving) as *controls* for *later*-changing ones → their ongoing dynamics get subtracted as a fake counterfactual trend → contamination + possible negative weights (dCDH 2020, holds for continuous treatment). You only get "already-treated-as-control" when treatment changes at *different times across units* — i.e., the time variation is the *source*. **Corollary (a genuine 2nd advantage of the adapted design over BR, beyond pre-trends):** our fixed-1999 × single-1997-break spec has *one simultaneous break*, no staggered entry, so *no* already-treated-as-control comparison → it mechanically escapes the classic negative-weights problem. **Óscar's critique, precisely stated, is therefore NOT the classic forbidden-comparison** (our single-break spec doesn't have it) but a *functional-form/aggregation* worry: is a two-snapshot summary adequate for a continuously-evolving dose? That is exactly what the intermediate-snapshot stability test checks — so we're on firmer ground than his "forbidden comparisons" phrasing implies.
- **Proposed figures (feasible, low-cost, reuse existing machinery) — NOT yet built, awaiting user go-ahead:** (1) **β₀-stability coefplot** across second-phase controls: {none} · {+Intensity_2000} · {+Intensity_2002} · {+Intensity_2005} · {+all}. NOTE only `inten1997/1998/2000/2002/2005` exist — *no* 2001/2003/2004 — so the sequence is 2000→2002→2005; state this in the figure. Flat β₀ = two-snapshot design insensitive to which later snapshot is conditioned on (read the {+all} point estimate, not its collinearity-widened CI). (2) **β₀ across {Intensity_2005 only} · {SES trend only} · {both}** to answer "is 2005 captured by the SES interactions."
- **(b) is partly answerable NOW from the existing `AT_ses_trend`:** col 1 (baseline, has Intensity_2005, no trend) vs. col 5 (continuous trend, *drops* Intensity_2005) vs. col 4 (quintile trend, drops Intensity_2005). If β₀ agrees across these, Intensity_2005 and the baseline-SES trend absorb overlapping variation (sensible: later enrollment ∝ baseline marginality, P&V Fig. 3). Caveat: related but not identical controls (2005 = later-*timing* partial; SES = differential-*poverty*-trend), so "mostly captured" is an empirical claim contingent on cols 1/4/5 agreeing, not an identity.
- **(c) The power payoff (the useful part for the user's ES-precision problem):** the event study carries *two* 15-parameter year-interaction blocks (`year×inten1999` + `year×inten2005`). If (b) holds, replace the 15-param `year×inten2005` block with a **1-param** continuous `c.im_mun_1990#c.year` trend → ~14 fewer parameters → materially tighter β_k CIs. So (b) is not just robustness; it's a lever to *recover event-study power*. Honest caveat: this changes the identification narrative (timing-partial → poverty-trend control), so justify the swap by *showing* near-equivalence (cols 1/4/5 + figure 1), not by assertion.

**FOLLOW-UP 3 (user's own three-point synthesis — all correct, one attribution fix).** User: (1) "fixing 1999 + 2005 intensity together bypasses forbidden comparison under a strong flat-2000–2005 assumption"; (2) still unsure csdid fits without super-strong cohort assumptions; (3) recalls binarizing on one threshold + clean TWFE mimics current design "assuming flat after threshold." Assessment:
- **(1) Attribution fix — the single break, not flatness, escapes the forbidden comparison.** `Post_t` is one 0/1 turning on in 1997 for *every* municipality → zero variation in treatment *timing* → no already-treated-as-control → no negative weights, **by construction, flat or not.** The flat assumption defends a *different* threat: whether two fixed snapshots × one `Post` dummy is an adequate *functional form* for the continuously-evolving dose (the model contributes a constant `β₀·Int1999+β₁·Int2005` to every post-year). Tension: *perfectly* flat ⇒ `Int1999=Int2005` ⇒ collinear ⇒ can't identify β₁; the fact both are estimable (65% shared var) means NOT perfectly flat. So the honest claim is "**mostly** flat" — quantifiable via `(Int2005−Int1999)/Int2005`, testable via the stability figure. Reframe: "single break rules out forbidden comparisons; mostly-flat makes the two-snapshot summary a good approximation, and I can show it." Don't overload the flat assumption with the forbidden-comparison job the single break already does.
- **(2) csdid genuinely doesn't fit — user's skepticism is right.** It needs `gvar` = first-treated *period* (binary, absorbing cohort). Using it forces (a) binarize (discard the dose = the signal) AND (b) real spread in crossing-year (multiple cohorts). Saturation ⇒ everyone crosses early ⇒ 1–2 cohorts ⇒ nothing to identify. Don't force it; its inapplicability is part of the honest footnote.
- **(3) Binarize on the FIXED 1999 snapshot + single-break TWFE = mimics current design, and is the RIGHT binarization for this data (unlike Óscar's).** `treated_m=1[Int1999_m≥c]`, single 1997 break, event study — current spec with binary-not-continuous treatment, same implicit flat-after. Buys: transparency (high vs low) + robustness to *dose-response functional form* (drops linearity-in-intensity). Does NOT buy: any improvement on the staggered/forbidden-comparison concern (both single-break, both already escape it) — it's a presentation/robustness figure, not an answer to Óscar's staggered point. Cautions under saturation: threshold must preserve a control group (no never-treated; "control" = below-c 1999 intensity ⇒ estimand is **high-vs-low**, not treated-vs-never); discards dose ⇒ complements, not replaces, the continuous result. **Key distinction: user's fixed-1999 binarization (single clean break) ≠ Óscar's time-varying-crossing binarization (staggered csdid cohorts); the former sidesteps the crossing-year-spread requirement saturation destroys, so it's the version that survives this data.**
- **Two natural low-cost deliverables when user says go:** (i) β₀-stability coefplot across second-phase snapshots; (ii) binary high-vs-low single-break event study on `Int1999` (the Point-3 figure the user has built before). Both complementary, reuse existing machinery. **Not built yet — user still reasoning through design.**

**FOLLOW-UP 4 (user: "even with enough stayers, would dCDH-continuous be right? (1) am I doing forbidden comparison — I think not by construction; (2) what am I missing by not using the later time-varying intensity?").** Assessment:
- **(1) No forbidden comparison, by construction — confirmed.** Forbidden comparison (Goodman-Bacon 2021, dCDH 2020) needs variation in treatment *timing*; the design has a single `Post` dummy flipping in 1997 for all municipalities → no timing variation → estimator never uses an already-in-post unit as a control for a just-entering one → this is exactly the *clean benchmark* case those papers hold up, not the problematic one. Identification is purely cross-sectional (high vs. low intensity vs. a common pre-period). Honest aside: a *separate, milder* continuous-treatment weighting issue exists for ANY continuous-dose DiD (TWFE slope = weighted avg of dose-response slopes, weights misbehave only under a very skewed dose) — NOT the forbidden comparison; P&V p.13 address it and argue it's benign for this dose distribution (roughly normal), which is the same dose, so same conclusion.
- **(2) What's forgone by not using the time-varying dose (assume stayers exist):** (a) **within-municipality time-series identifying variation = power** — β₀ uses only the cross-sectional early-intensity spread; a continuous design would additionally use every within-municipality dose *change* 1997–2006 as identifying variation. This is the loss that actually bites (ties to the ES-precision complaint). (b) **dose-response dynamics / lag structure** — dCDH's DID_ℓ traces the effect ℓ years after a dose increment; the two-snapshot DiD collapses the post window into one average and *assumes* cumulative exposure. BUT the event study already recovers most of this under the mostly-flat assumption (high-1999 ≈ high-throughout, so β_k profile ≈ dose-response dynamics); what's unrecoverable is attributing dynamics to a *specific later increment*.
- **The crux — why dCDH is still probably NOT right even with stayers:** its *headline* benefit is heterogeneity-robustness under staggered adoption = fixing the forbidden comparison — a bias the design **doesn't have**. So dCDH would solve a non-problem while (i) importing the 2000–2005 catch-up variation, the *least* plausibly-exogenous variation (saturation-era; deliberately excluded by fixing at 1999), and (ii) answering a *different question* (year-by-year dynamic dose-response) than the paper's (average effect of early cumulative exposure). Net: a power-vs-cleanliness tradeoff where dCDH sits on the side the design deliberately avoids; dCDH's robustness payoff is moot without staggered timing while its cost (noisier variation + needing stayers) is real. dCDH would genuinely add value ONLY if the research question were the dynamic lag structure of the dose-response; it isn't.

**FOLLOW-UP 5 (user pushed back on the P&V-vs-us distinction, and asked what Intensity_2005 does) — includes a CORRECTION to the earlier IADB-3 deep-dive overstatement.**
- **CORRECTION: on forbidden comparisons, P&V and this paper are in the SAME position (both immune), for the same reason — my earlier "you have a genuine calendar-time panel so you're more exposed than P&V's cohort cross-section" was overstated.** P&V's `post_t` = "younger than 14 in 1997" is a *cohort-exposure* boundary set by the common 1997 program start; it is the **same function of cohort for every municipality**. Municipalities vary in *intensity* (`enrol1999_m` scalar), not in *timing*. So P&V = "common exposure schedule × cross-sectional intensity," and our design = "common 1997 break × cross-sectional intensity" — structurally the *same kind of object*. Neither has variation in treatment *timing* across units → neither has the forbidden comparison. Having a repeated-time panel is *necessary but not sufficient* for forbidden comparisons; you also need staggered timing, which neither design has. (The user was right to push; the clean "no forbidden comparison by construction" from FOLLOW-UP 4 applies equally to P&V.)
- **The REAL, narrower difference (functional form, not bias):** P&V observe the outcome **once** (2010 census), *after* exposure fully accumulated → no within-window dose evolution to misrepresent. We observe mortality **repeatedly** (1991–2006) *while* the dose ramps → we carry the "mostly-flat" two-snapshot functional-form assumption P&V don't need. BUT the repeated outcome is *double-edged*: it also lets our event study **trace the accumulation** (effect building with calendar time ≈ cumulative exposure), which P&V's single endpoint cannot. So the repeated panel is a functional-form *burden* AND a dynamics *advantage* — not a forbidden-comparison vulnerability.
- **What Intensity_2005 does (user Q):** it is a **nuisance control** (β₁ not interpreted causally) whose job is to **partial out later-phase enrollment so β₀ isolates the *early*-phase effect** — converting the design from "more-vs-less total enrollment" into "**early-vs-late** enrollment, holding overall trajectory fixed." Rationale: early/late intensity are negatively correlated by construction, so omitting Intensity_2005 conflates "enrolled early" with "enrolled a lot"; including it makes β₀ an early-vs-late timing contrast, which is more credible for parallel trends (same-total-enrollment early-vs-late municipalities are more comparable than high-vs-low-total ones). P&V p.11: differential trends tied to overall eligibility "load onto γ [enrol2005], while β [enrol1999] captures … the first rather than second phase." This is the *timing-partialling* role (paper's framing, main.tex line 197), NOT the "wealth absorption" seminar framing (keep that out).
  - **Crystallizing example (worked for user):** decompose Total(2005) = Early(1999) + Late(2000–05). Muni A = 80% early / 100% total; Muni B = 20% early / 100% total — *same total, different speed* (A front-loaded, B back-loaded). Controlling for Intensity_2005 makes β₀ identified off exactly such same-total pairs → pure timing effect (if mortality is cumulative, A has more person-years of exposure by 2006). WITHOUT the control, β₀ regresses on early alone, so B (low-early/high-total) gets averaged with low-early/low-total munis (e.g. C = 20% early / 40% total) → β₀ conflates "enrolled early" with "enrolled a lot." **Two things both true, and the user got this right:** (i) the HM restriction already mutes the poverty channel (poverty range compressed), so this is *not* an "early localities poorer than late localities" story; (ii) the Intensity_2005 control does the *mechanical* timing-vs-total-dose separation *regardless of poverty* — it would matter even with zero poverty differences, purely to stop conflating "early" with "a lot." Poverty is the *residual* reason timing is the cleaner variation (total enrollment ∝ poverty/capacity ∝ differential trends); the decomposition is the *mechanical* reason the control exists. β₀ is interpretable as a clean early effect *only because* Intensity_2005 is in the regression — the two coefficients aren't rivals; β₁ purifies β₀.

**CLARIFICATION FROM USER (supersedes the transcript's initial framing): Óscar did NOT ultimately propose csdid.** He raised it *initially*, then converged on **binarize on the fixed 1999 intensity + plain single-break TWFE** as the reconciling suggestion. So his final recommendation == the user's own Point-3 binarization (FOLLOW-UP 3 item 3), NOT the staggered-crossing/csdid version. This collapses the earlier "user's fixed-1999 binarization ≠ Óscar's time-varying-crossing version" distinction: there is no divergence — both landed on the clean binary-1999 single-break TWFE. Consequences: (a) csdid is off the table entirely (nobody is proposing it; the earlier csdid discussion is moot except as documentation of *why* it doesn't fit); (b) the only actually-requested robustness is the **binary high-vs-low single-break event study on `Int1999`** (deliverable ii above), which the user has built before and which does not touch the forbidden-comparison question (single break already handles it) — it's a functional-form/transparency robustness (high-vs-low, drops linearity-in-dose). The dCDH-continuous thread stays as documented reasoning for the footnote/limitations discussion, not as something to implement.

**IADB-4 (Óscar) — population weights may be masking heterogeneity.** *Comment:* inverse population weights are a very *parametric* way to capture size-heterogeneous effects; complement with non-parametric subsamples (large/medium/small municipalities). Also would help explain the divergence from Barham & Rowberry, who were unweighted and found effects. *Our response:* weights reflect proportional contribution to total mortality; the progressive trimming (`AT5_BR_trimming`) already shows the unweighted coefficient converging to the weighted one as small municipalities are dropped, implying size is a real heterogeneity source; accepted adding subsample analysis. *Assessment:* Partly answered by `AT5` trimming, but the explicit **size-tercile subsample** table Óscar asked for doesn't exist yet — cheap to add (split by municipal population terciles, run the main spec in each). Would pair naturally with IADB-5.

**IADB-5 (Luis) — heterogeneity by beneficiary vulnerability (not size).** *Comment:* rather than municipality size, split by characteristics of the *beneficiary population* — theory says some subgroups are more susceptible to mortality gains, and averaging across municipalities could dilute a real effect in one subgroup with a zero elsewhere. Even with municipality-only mortality, exploit the *share* of the municipal population that is especially vulnerable (e.g. elderly in extreme poverty, specific HH composition) as the heterogeneity dimension; check prior literature for the theoretically most-susceptible subgroup. *Our response:* acknowledged the structural limit (mortality only at municipality level); binarizing (IADB-3B) could partly enable this by crossing binary treatment with municipal vulnerability shares. *Assessment:* **New.** Actionable via municipality-level moderators already in the data (marginalization components, elderly-poverty share if constructible). Needs a literature check to pick the a-priori susceptible subgroup before implementing, so it doesn't look like specification search. Medium effort.

**IADB-6 (León + Eduardo) — health-supply quality as the binding constraint.** *Comment:* León — a null could reflect poor *supply* (clinics without resolutive capacity in marginalized rural areas), not program failure; policy-relevant distinction. Eduardo — use **hospital openings** as quasi-exogenous variation (his work with Julio Ramos & Sebastián Bauhoff on infant mortality): (i) as an added control, (ii) as heterogeneity (Progresa's effect should concentrate where hospital infrastructure is better). Eduardo self-caveated that hospitals may matter less for *elderly* mortality. *Our response:* we control for Seguro Popular rollout as a supply proxy (results unchanged) and municipality FE absorb structural supply differences; but detailed locality health-infrastructure/personnel data start only in 2001, so no pre-trends in the relevant window; agreed to contact Julio Ramos for pre-2001 hospital-infrastructure data. *Assessment:* Overlaps the health-channel work (Conf. Comment 2). The Seguro-Popular-control + muni-FE response is legitimate and already in the paper. The hospital-opening extension is **data-blocked pre-2001** (same vintage problem as the ENCEL health module) — action item is the Julio Ramos data contact, not code. Keep as "contingent on data."

**IADB-7 (Leonel) — migration as a confounder.** *Comment:* Progresa's documented migration effects could bias mortality via composition. Short-run: reduced *international* migration (not internal); intl. migrants are positively health-selected, so changing who stays alters municipal mortality composition. Long-run: newer evidence that larger-transfer households (adolescents/specific composition) migrated *more* to the US — so over our 10-year window the migration effect could flip sign. How is this handled in sampling/identification? *Our response:* (i) prior lit (Stampini, *Demography* 2005) finds no Progresa migration effect *in old age*, our group of interest; (ii) MHAS (Mexican Health & Aging Study, HRS-analog) checked directly — no significant elderly migration attributable to the program; (iii) contrast: our *70 y Más* paper (transfer targeted *at* the elderly) *does* find internal migration — reinforcing that when the program isn't elderly-targeted (Progresa), the elderly don't move. *Assessment:* Well-handled already, and we have `AT_migration_robustness` / `AT_migration_robustness_ageFE` tables (currently commented out in `tables_app.tex`) plus the migration paragraph in `main.tex` §Robustness citing Stecklov/Stampini. Action: mostly ensure the write-up covers the **long-run sign-flip** possibility Leonel raised (the newer larger-transfer→more-migration evidence), which the current text may not explicitly address; consider un-commenting the migration tables if we want the direct test in-paper.

### ═══ IDENTIFICATION-DEFENSE SYNTHESIS & CONSOLIDATED ACTION LIST ═══

Distills the FOLLOW-UP 1–5 methodology thread (all above) into user's 6 improvement targets → verdicts → deliverables. Detail lives in the FOLLOW-UPs; this is the index.

**User's 6 points, assessed:**
1. **Improve stability defense** → the load-bearing empirical task. Deliverable **D1** (β₀-stability figure) + the `(Int2005−Int1999)/Int2005` descriptive that quantifies "mostly flat." This is what makes the two-snapshot design defensible against Óscar's functional-form worry. *Highest priority.*
2. **Question of interest = early phase, and why** → writing (§Empirical Strategy). β₀ = effect of EARLY cumulative exposure; early is the cleaner variation (pre-saturation, driven by initial poverty-targeting algorithm; the later phase is saturation-era catch-up, least exogenous). Motivates both fixing at 1999 *and* the Intensity_2005 control. Merge with Point 6 (one narrative).
3. **What we lose with continuous time-varying (maybe not needed)** → writing/limitations. Lose within-unit time-series variation (power) + dose-dynamics (mostly recoverable from the event study). dCDH's headline benefit (forbidden-comparison fix) is MOOT here (single break). Not needed because the question is the average early effect, not the dynamic lag structure. Feeds the footnote fix (**W1**).
4. **Does binarizing add something meaningful?** → yes, modestly. Deliverable **D2** (binary high-vs-low single-break event study on Int1999 = Óscar's actual ask). Adds transparency + robustness to dose-response functional form (drops linearity-in-intensity). Does NOT fix any bias (single break already handles forbidden comparison). A robustness *figure*, not an identification change.
5. **Highlight the forbidden-comparison advantage over BR** → writing (§Robustness, near line 234). BR's time-varying-dose TWFE HAS the forbidden comparison (already-treated-as-control, negative weights); our single-break design escapes it by construction. This is a genuine *second* advantage over BR (the first is the pre-trend test). High-value, cheap framing win (**W3**).
6. **Improve the Intensity_2005 story; not about poverty** → writing (§Empirical Strategy, near line 197). It's a nuisance control that partials out later enrollment so β₀ is an early-vs-late *timing* contrast (same-total-different-speed), holding total fixed. Mechanical (timing-vs-total decomposition), NOT "early localities poorer"; HM restriction mutes poverty. Merge with Point 2 (**W4**).

**Combined action list (merges the 6 points with the prior methodological to-do):**
- **Empirical deliverables (low-cost, reuse existing machinery; NOT yet built):**
  - **D1** — β₀-stability coefplot across second-phase snapshots {none/+2000/+2002/+2005} (+`(Int2005−Int1999)/Int2005` descriptive). [Points 1] — *do first.*
  - **D2** — binary high-vs-low single-break event study on `Int1999`, threshold sensitivity grid. [Points 4]
  - **D3 (optional/diagnostic)** — saturation check: distribution of year-on-year Δintensity + first-crossing-year spread, to confirm the "few stayers" story for the footnote. Also the intermediate-snapshot regression stability (swap 2005→2002; add 2000/2002 one at a time).
- **Writing / framing fixes (no estimation):**
  - **W1** — fix `main.tex` line-173 footnote: drop the (wrong) "estimators require a binary date"; instead (i) single break ⇒ no forbidden comparison, and (ii) continuous/staggered estimators need stayer/not-yet-treated units that near-universal HM saturation denies. Explain why our setting differs from P&V's (both immune, common-timing×cross-sectional-intensity). [Points 3, 5]
  - **W2** — cite `AT_ses_trend` in the identification/robustness text (currently uncited; IADB-2 gap).
  - **W3** — add the forbidden-comparison advantage over BR explicitly near line 234 (BR's "two advantages" → three). [Point 5]
  - **W4** — sharpen Intensity_2005 = early-vs-late timing story, explicitly not-about-poverty, near line 197. [Points 2, 6]
  - **W5** — Comment-4 correlation text: cite P&V fn. 18 (65% shared variance) + in-sample R² near line 171.
- **Note:** W1+W3 fold into one "BR / modern-DiD" paragraph; W4+W5 fold into one "early-vs-late / Intensity_2005" paragraph; W2 is a one-line cite. So the writing collapses to ~2 paragraphs + 2 cites.

**OVERLAP WITH CONFERENCE COMMENTS 3 & 4 (user flagged; they converge — one deliverable closes several).** The identification thread = the same substance as Conf. Comment 3 (locality-composition, "cite P&V Figs 2–3") and Conf. Comment 4 (Intensity_1999/2005 correlation, "cite P&V fn. 18, 65%"). Replicating what our data allows closes both + IADB-2 correlation + W5 simultaneously:
- **REPLICABLE → new deliverable D0/W-fig:** a **P&V Fig-3 analogue** — municipality enrollment ratio (`inten1999`, `inten2005`) vs municipality marginality-index percentile, split by phase (1997–99 vs 2000–05). Feasible (all municipality-level); NOT currently in the paper (existing appendix figures are `spmap` maps, not this scatter/local-linear plot). Directly answers Conf. Comment 3 and visually motivates the early-vs-late design. Pair with **fn-18 R² rows 1–2** (R² of `inten1999~inten2005`; then + municipality-marginality-percentile) = Phase-0 item 0a extended → Conf. Comment 4.
- **UPDATE — previously "not replicable," now IS: user has locality-level marginality index data.** This unblocks **both** of the items below, which is a materially bigger win than originally scoped:
  - **P&V Fig 2 analogue** — locality-level enrollment ratio vs. locality marginality percentile, by phase. Requires locality-level enrollment (new beneficiaries by locality by phase), which needs checking/construction alongside the municipal series, but the marginality side is now available.
  - **P&V eq. (4)-style locality-composition-share control** — the more granular fix for Eduardo's endogeneity concern that `AT_ses_trend` (eq.-3 analogue: municipality-marginality-percentile × trend) does NOT fully address. Construct, for each municipality-year, the share of municipal population living in localities at each percentile of the *locality* marginality distribution (`L^p_m` in P&V), interact with year FE, and re-check β₀ stability + report the R² progression (their fn. 18: 65% → 67% with municipality percentile → 75% with locality shares). This is the single most direct, citable answer to "have you fully netted out locality-level wealth heterogeneity" — previously logged as a real data gap; now buildable. New deliverable: **D0b** (locality-share control, pairs with D0's municipality-level Fig 3/R²).

**β₁ / Intensity_2005 COEFFICIENT & EVENT STUDY (AF_beta1) — is it interpretable? (user unsure; reconciled).** β₁ = partial association of *later-phase* (2000–05) enrollment with mortality, net of early. It is **NOT a clean causal late-enrollment effect** — the late variation is the least-exogenous (saturation-era) dimension by the design's own logic; interpreting θ_k/β₁ causally is the mistake the design avoids. It is a **nuisance-control coefficient, not a result.** Drop the "poorer vs richer" talk framing (the muted-in-HM wealth-absorption story we keep out); the correct framing is timing/total-decomposition (β₁ soaks up the later/total enrollment so β₀ isolates early). **Useful diagnostic role of the θ_k event study:** it locates *where confounding lives* — if θ_k (late) shows pre-1997 trends while β_k (early) does not, that is direct evidence the differential-trend confound sits in the late/total dimension the control absorbs, and the early dimension is clean → an argument *for* the design (checkable on the existing `AF_beta1` plot vs the main event study). **Handle head-on:** β₁ is significantly negative in the *unweighted* T2 specs (pooled −5.5*, female −9.1**), attenuating when weighted (same small-municipality fragility as the BR story). Do NOT read this as "late enrollment reduced mortality"; read it as the control catching a real differential trend correlated with total/late enrollment (= why the control is needed), driven by the small volatile municipalities already distrusted. Action = a small caption/text reframe of `AF_beta1_*`: label it a *confounding-location diagnostic + complement* to the main ES, explicitly not a causal late-phase estimate.

**One-paragraph discussion summary (for quick recall):** We stress-tested the identification against the IADB comments (esp. Óscar's staggered-adoption critique). Conclusions: (a) the design (fixed 1999 intensity × single 1997 break + Intensity_2005 control) is NOT subject to the classic forbidden comparison, *by construction* — no staggered timing; same immunity as P&V (2023), whose cohort-exposure boundary is likewise common across municipalities. (b) BR *does* have the forbidden comparison (time-varying dose + TWFE), so our design has TWO advantages over BR: the pre-trend test AND no forbidden comparison. (c) Intensity_2005 is a nuisance control that isolates the early-vs-late *timing* effect (holds total enrollment fixed); mechanical, not a poverty story (HM restriction handles poverty). (d) Óscar's residual worry (after he dropped csdid and converged on binarize-1999+TWFE) is a *functional-form* question — is two snapshots an adequate summary of the evolving dose? — which is TESTABLE via D1; "mostly flat," not "perfectly flat" (perfectly flat kills β₁ ID). (e) Continuous-treatment dCDH is not needed (headline benefit moot; imports the noisiest saturation-era variation; answers a different question) and likely infeasible (few stayers under saturation); csdid doesn't fit (binary + needs cohort-spread saturation destroys). (f) MDE work shows the design is powered to detect BR's original effect, so the null isn't a power artifact.

### ═══ POST-IADB-PRESENTATION IMPLEMENTATION ROADMAP ═══

Consolidates everything above (Conf. Comments 3/4, IADB-1 through IADB-7, all FOLLOW-UPs) into one executable plan, split code vs. text, in dependency order. **Updated per user: intensity is computable for every year (not just the 1997/1998/1999/2000/2002/2005 snapshots), and locality-level marginality index data is available** — both materially upgrade what's feasible below.

**Legend:** CODE = Stata (Claude writes, user runs) · TEXT = LaTeX draft (Claude writes now) · DATA = blocked on external data · ✅ = already built this session.

**Bucket 1 — Identification defense (IADB-2, IADB-3; Conf. Comments 3, 4) — the core:**

| Item | Type | What | Updated by new data? |
|---|---|---|---|
| **D0** | CODE ✅ | P&V Fig-3 analogue (municipality enrollment vs. marginality percentile, by phase) + fn-18 R² rows 1–2. **Implemented** in `02_mortality.do` (appended after AT_age_subgroups). Outputs: `$figures/appendix/AF_pv_fig3_replication.pdf` + `di` R² lines (0.65/0.67 benchmarks). Awaiting user run. | — |
| **D0b** | CODE | **NEW, unlocked by locality marginality data:** P&V Fig-2 analogue (locality-level) + eq.-(4) locality-composition-share control (`L^p_m` × year FE) + fn-18 R² row 3 (→0.75). The deeper fix for Eduardo's endogeneity concern beyond `AT_ses_trend`. **DEFERRED — user is sourcing the locality-level marginality data separately; do not build until that's ready.** |
| **D1** | CODE ✅ | β₀-stability figure. **Implemented, upgraded to full year-by-year:** loops the second-phase control over `{none, 2000, 2001, ..., 2006}` (all now constructed from `intensity_new`, no new data needed) and coefplots β₀ with 95% CIs, plus the `(Int2005−Int1999)/Int2005` "mostly flat" descriptive. Output: `$figures/appendix/AF_beta0_stability.pdf`. Awaiting user run. |
| **D2** | CODE | Binary high-vs-low single-break event study on `Int1999`, threshold sensitivity grid (Óscar's actual ask). **Not yet built.** |
| **D3** | CODE ✅ | Saturation diagnostics. **Implemented, upgraded from approximate to exact:** true year-on-year `Δintensity` for every HM municipality-year 1997–2006 (`|Δintensity|<1pp` = "stayer" count), first-year-crossing-15% distribution, near-zero-penetration check. **Resolves the open dCDH-feasibility question below — this is the diagnostic that decides it, not an approximation.** `did_multiplegt_dyn` becomes genuinely implementable if stayers are plentiful; otherwise this is the exact evidence for the corrected footnote (W1). Awaiting user run + reported numbers. |
| **W1** | TEXT | Fix line-173 footnote (single break ⇒ no forbidden comparison; explain why P&V's disclaimer doesn't mechanically transfer). |
| **W2** | TEXT | Cite `AT_ses_trend` in the robustness text (currently unreferenced). |
| **W3** | TEXT | Add the forbidden-comparison advantage over BR, near line 234. |
| **W4** | TEXT | Sharpen Intensity_2005 = early-vs-late timing story, not-about-poverty, near line 197. |
| **W5** | TEXT | Correlation sentence near line 171 (P&V fn. 18 + in-sample R² from D0/D0b). |
| **W6** | TEXT | Reframe `AF_beta1_*` caption as a confounding-location diagnostic, not a causal late-phase estimate. |

**Bucket 2 — Heterogeneity (IADB-4, IADB-5):**

| Item | Type | What |
|---|---|---|
| **H1** | CODE | Size-tercile subsample table (Óscar's non-parametric ask). |
| **H2** | CODE + lit check | Vulnerability-share heterogeneity (Luis) — needs a literature check first to pre-register the subgroup, so it isn't spec search. |

**Bucket 3 — Mechanisms / health supply (IADB-1, IADB-6; Conf. Comment 2):**

| Item | Type | What |
|---|---|---|
| **M1** | TEXT | Frame T3 cols 6–7 + `AT_elderly_transfer` ✅ as the partial answer to IADB-1 (Óscar's recipient-identity/intra-HH-allocation critique); state the limitation honestly. |
| **M2** | CODE ✅ (awaiting run) | ENCEL two-wave pooling (`AT_gertler_pooled`) — built; user needs to run + validate sentinel assumptions and check N vs. Gertler's 15,399. |
| **M3** | TEXT / DATA | Health-supply response (IADB-6) — Seguro-Popular + muni-FE response already in paper; hospital-openings extension is data-blocked pre-2001 (Julio Ramos contact). |

**Bucket 4 — Migration (IADB-7):**

| Item | Type | What |
|---|---|---|
| **G1** | TEXT | Add the long-run migration sign-flip possibility to the robustness paragraph. |
| **G2** | TEXT/CODE | Optional: un-comment `AT_migration_robustness*` tables if a direct in-paper test is wanted. |

**Recommended sequence:**
1. **Bucket 1's code first, as one combined block: D0 + D0b + D1 + D3.** They share estimation setup and the locality-share construction (D0b) is now the single highest-value new addition — it's both a Conf. 3/4 closer and the deepest available answer to Eduardo's endogeneity concern. D3's re-run with exact (not approximated) year-on-year data should happen before finalizing any dCDH-feasibility conclusion in the text.
2. **Then the text (W1–W6, M1, G1)** — drafted with the real numbers from step 1 plugged in; collapses to ~2–3 paragraphs + several cites + 2 caption tweaks.
3. **D2** (binary event study) as its own block.
4. **Bucket 2** (H1, then H2 after the lit check) — cheap, do together.
5. **Bucket 3/4 remainder** — mostly text (M3, G2 optional) + user's pending M2 run; hospital data stays parked on the Julio Ramos contact.

**STATUS UPDATE — D0, D1, D3 implemented in `02_mortality.do`** (appended after the `AT_age_subgroups` block, ~line 3218 on). D0b deliberately **held off** per user instruction — the locality-level marginality index is data the user is sourcing/constructing separately; do not build D0b until that arrives. What's now in the code:
- **Prerequisite step:** extends the cumulative-intensity snapshots to every year (`inten2001`, `inten2003`, `inten2004`, `inten2006`, added to the pre-existing `inten1997/1998/1999/2000/2002/2005`) — built the same way as the existing snapshots, directly from `intensity_new` (confirmed to be a genuine year-by-year panel variable via its `lag_intensity_new`/`lag2_.../lead_intensity_new` companions in `01_mortality_data.do`). **No new data needed for this** — confirms the user's instinct that the different intensity years are producible from data already on hand.
- **D0**: uses the FULL (unrestricted) municipality cross-section — confirmed safe to build, since every `keep if $sample_marg` earlier in the file is wrapped in its own `preserve`/`restore` block, so the working dataset still contains all municipalities nationwide by the time this new block runs. Plots phase-specific (incremental) enrollment ratios — `phase1_new = inten1999`, `phase2_new = inten2005 − inten1999` (matching P&V's own construction: their Figs. 2–3 plot new enrollment *during* each phase, not cumulative totals) — against percentile bins of `im_mun_1990`. Includes a `phase2_new < 0` diagnostic that checks the assumption that `inten1999`/`inten2005` are cumulative-through-year snapshots (same convention as the existing `inten1997/1998/2000/2002`); flags for investigation if that count is large. The fn.18-style R² check runs on the HM sample specifically (`$sample_marg`), matching P&V's own "in sample municipalities" wording.
- **D1**: full year-by-year β₀-stability loop (`none, 2000, 2001, ..., 2006`), coefplotted with 95% CIs; plus the `(Int2005−Int1999)/Int2005` "share of eventual enrollment added after 1999" descriptive.
- **D3**: exact year-on-year `Δintensity` (no longer interpolated) restricted to the HM sample 1997–2006; stayer count (`|Δintensity|<1pp`); first-year-crossing-15% distribution; near-zero-penetration check.
- **Status: code written, NOT run against real data** (no Progresa/mortality data in this sandbox). User needs to run `02_mortality.do` and report back: (a) the `phase2_new<0` count (validates the cumulative-snapshot assumption); (b) whether `im_mun_1990` is broadly populated outside the HM sample (the "dropped for missing" diagnostic in D0) or mostly missing outside HM, which would mean the Fig-3 replication needs a different marginality-index source for non-HM municipalities; (c) the β₀-stability coefplot itself — is it flat?; (d) the D3 stayer share and first-crossing-year spread — this is the number that finally settles the dCDH-feasibility question, replacing the earlier five-snapshot approximation.

> **Not yet started — awaiting user's go-ahead on which bucket/item to open first.**

### Overall assessment / priorities

- **Immediate, near-zero-cost text fixes:** (a) **fix the `main.tex` line-173 footnote** — it cites de Chaisemartin & D'Haultfœuille (`de2020two`) to argue modern estimators "require a binary treatment date," which is backwards since their continuous-treatment DiD is exactly the counterexample. Confirmed this footnote is very likely adapted from P&V (2023)'s own fn. 21 disclaiming the same estimators — but P&V's disclaimer is valid *for their cohort-cross-section design* (no repeated calendar-time panel per unit) and does NOT transfer to our genuine municipality-year panel (see IADB-3 deep dive). The fix needs to explain *why* our setting differs, not just soften the wording. (b) **Cite `AT_ses_trend` in the identification/robustness text** (IADB-2) — the most direct rebuttal to intensity-endogeneity-via-differential-trends currently isn't `\ref`'d in main.tex at all. Note this is only P&V's eq.-(3)-level control; their eq.-(4)-level locality-composition-share control is a further, unimplemented step (IADB-3 deep dive).
- **Highest-value new estimation: IADB-3 (staggered adoption).** Binarized event study (Option B) is low-cost, uses existing event-study code, gives a clean entry date, and directly answers the most-debated critique. dCDH **continuous**-treatment DiD (`did_multiplegt_dyn`, Option A) is the modern-standard, more-faithful follow-up — feasible at the municipality-year level (estimand = municipal dose-response, same as current β₀), but first check "stayer" availability (year-on-year Δintensity distribution). My earlier claim that continuous-DiD was infeasible/awkward here was wrong. **UPDATE: user can now compute intensity for every year (not just sparse snapshots) — re-run the stayer/Δintensity diagnostic (D3, exact this time) before concluding on dCDH feasibility; the earlier "likely infeasible under saturation" verdict was based on interpolating between five snapshots and may understate true within-year flatness.**
- **Cheap, complementary: IADB-4 + IADB-5** — size-tercile and vulnerability-share subsample tables; do together.
- **Mostly "point to existing robustness": IADB-7** (and IADB-6's Seguro-Popular part) — largely a writing task, with IADB-7 needing a sentence on the long-run migration sign-flip. IADB-2 is *also* mostly writing but has the specific uncited-table gap above.
- **Data-blocked / external: IADB-6 hospital data (Julio Ramos contact, pre-2001).**
- **Framing / partial-by-design: IADB-1** — lean on the elderly-only-household exercises as the partial answer; state the bargaining/individual-allocation limitation honestly.

> **Instructions for Claude:** when any IADB-# item is implemented, mark its status here and record the output filename, mirroring the conference-comment tracker convention. Keep IADB-# numbering separate from Major/Minor conference comments.

---

## Notes for Contributors

- All paths to external data are hardcoded in each `.do` file — update the `global` or `local` path macros at the top of each script before running.
- The sample is restricted to **highly marginalized municipalities** (`gm_mun_1990 == 4 | 5`) throughout.
- Scripts use **municipality and year fixed effects** — ensure panel IDs are correctly set (`xtset municipality year`).
- Regressions cluster standard errors at the **municipality level**.
- Figures are saved as `.png` or `.pdf` — output directories must exist before running.
