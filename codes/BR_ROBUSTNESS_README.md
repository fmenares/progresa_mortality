# BR 2013 Robustness Verification

## Purpose
Verify whether the Barham & Rowberry (2013) PROGRESA mortality results hold when:
1. Using a fixed-effects approach that allows testing for pre-trends
2. Restricting to highly marginalized municipalities (all poor communities)
3. Weighting by 65+ population (eliminating population bias)
4. Controlling for Seguro Popular intensity (health insurance expansion post-2001)

## Script: `03_br_robustness_verification.do`

### Specification
- **Treatment variable**: PROGRESA enrollment intensity in 1999 (`inten1999`)
- **Time window**: 1992–2002 (sample up to 2002 for BR comparability)
- **Model**: Difference-in-differences with municipal and year fixed effects
  ```stata
  emr65/aamr65 = α_i + γ_t + δ*(post × inten1999) + controls + ε
  ```
  - `post = 1` for years 1997–2006, `post = 2` for 1991–1996
  - Cluster standard errors by municipality

### Outcomes
Two tables with 9 DD specifications each:

**Table 1: Excess Mortality Rate (EMR65)** — mortality excess for ages 65+ relative to national average
**Table 2: Age-Adjusted Mortality Rate (AAMR65)** — PROGRESA-weighted standardization

### Specifications (3 samples × 3 models = 9 columns)

#### Sample 1: BR Sample (Barham & Rowberry eligible municipalities)
- Col 1: Unweighted, no SP control
- Col 2: Unweighted + SP intensity control
- Col 3: Weighted (65+ population) + SP intensity control

#### Sample 2: Highly Marginalized Only (all poor, all counties)
- Col 4: Unweighted, no SP control
- Col 5: Unweighted + SP intensity control
- Col 6: Weighted (65+ population) + SP intensity control

#### Sample 3: BR Sample × Highly Marginalized (BR methods on all-poor sample)
- Col 7: Unweighted, no SP control
- Col 8: Unweighted + SP intensity control
- Col 9: Weighted (65+ population) + SP intensity control

### Output Tables
- `T_BR_robustness_emr65.tex` — EMR65 results
- `T_BR_robustness_aamr65.tex` — AAMR65 results

Each table rows:
1. **Coefficient** on `inten1999 × post` (with *, **, *** for 10%, 5%, 1% significance)
2. **Std. Error** (in parentheses)
3. **Sample Size** (municipality-years)
4. **Municipalities** (distinct)
5. **Mean (Pre-period)** — baseline mortality rate 1991–1996

### Interpretation

**Column comparison logic:**
- **BR sample progression** (cols 1→2→3): Tests BR robustness to SP controls and 65+ weighting
- **Marg vs BR** (cols 1 vs 4): Tests whether results hold on all-poor sample vs BR-eligible subset
- **BR & Marg** (cols 7–9): Replicates BR approach on restricted all-poor sample

**Key comparisons for BR validation:**
- **Col 1 vs. literature**: Should align with BR (2013) main DD estimate (they find ~-6 to -7)
- **Col 1 vs. Col 4**: Robustness to sample composition (BR-eligible vs all poor)
- **Col 2 vs. Col 3**: SP intensity control sufficient without 65+ weighting?
- **Col 3 (weighted) vs. Col 2 (unweighted)**: Population bias adjustment

### Data Requirements
Requires same inputs as `02_mortality.do`:
- `aamr_regression_municipality_gender_tb.dta` — outcome & population data
- `inten1999.dta` — PROGRESA intensity 1999
- `inten2005.dta` — PROGRESA intensity 2005
- `SP_2001_2018.dta` — Seguro Popular enrollment

### Run Instructions
```stata
do "$codes/03_br_robustness_verification.do"
```

Outputs tables to `$tables/` as specified in `02_mortality.do`'s global paths.
