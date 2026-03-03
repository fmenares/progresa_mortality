# Intensive Margin Tables

All output files are written to `$tables/`. Each file mirrors its extensive-margin counterpart with an `_im` suffix.

## Restriction Logic

| Table series | Sample restriction added |
|---|---|
| T1 (individual outcomes) | `ind_earnings > 0` |
| T2 / T3 / T4 (household outcomes) | `hh_elder65_pos_earn == 1` |

`hh_elder65_pos_earn` flags households with at least one member aged 65+ with positive individual earnings.

---

## File Patterns by Specification Group

### 1. 1999 + 2005 Intensity (Pooled)

| File | Contents |
|---|---|
| `T1_ind_enigh_im.tex` | Employment, hours, earnings, income, transfers — positive earners only |
| `T2_hh_enigh_im.tex` | HH earnings, income, expenditure, transfers, savings, debt, size |
| `T3_food_enigh_im.tex` | Food, veg/fruit, cereals, meat, sugar/fat, alcohol, tobacco, vice |
| `T4_health_enigh_im.tex` | Health exp, medical visits, inpatient, outpatient, drugs, orthotics |

### 2. By Sex — 1999 + 2005 Intensity

| File | Contents |
|---|---|
| `T1_ind_enigh_sex_im.tex` | Individual outcomes — Panel A: Females, Panel B: Males |
| `T2_hh_enigh_sex_im.tex` | HH outcomes — female-headed vs. male-headed HH |
| `T3_food_enigh_sex_im.tex` | Food outcomes — female-headed vs. male-headed HH |
| `T4_health_enigh_sex_im.tex` | Health outcomes — female-headed vs. male-headed HH |

### 3. 1999 Intensity Only

| File | Contents |
|---|---|
| `T1_ind_enigh_1999_im.tex` | Individual outcomes |
| `T2_hh_enigh_1999_im.tex` | HH income/expenditure outcomes |
| `T3_food_enigh_1999_im.tex` | Food outcomes |
| `T4_health_enigh_1999_im.tex` | Health outcomes |

### 4. Baseline 1999 — Barham & Rowberry (`lag2_intensity_new`, 1992–2002)

| File | Contents |
|---|---|
| `T1_ind_enigh_br_im.tex` | Individual outcomes |
| `T2_hh_enigh_br_im.tex` | HH income/expenditure outcomes |
| `T3_food_enigh_br_im.tex` | Food outcomes |
| `T4_health_enigh_br_im.tex` | Health outcomes |

### 5. 1997 Intensity Only (up to 2006)

| File | Contents |
|---|---|
| `T1_ind_enigh_1997_im.tex` | Individual outcomes |
| `T2_hh_enigh_1997_im.tex` | HH income/expenditure outcomes |
| `T3_food_enigh_1997_im.tex` | Food outcomes |
| `T4_health_enigh_1997_im.tex` | Health outcomes |

### 6. Baseline 1997 — Barham & Rowberry (`intensity_new`, 1992–2002)

| File | Contents |
|---|---|
| `T1_ind_enigh_br_1997_im.tex` | Individual outcomes |
| `T2_hh_enigh_br_1997_im.tex` | HH income/expenditure outcomes |
| `T3_food_enigh_br_1997_im.tex` | Food outcomes |
| `T4_health_enigh_br_1997_im.tex` | Health outcomes |

### 7. 1997 Intensity up to 2002

| File | Contents |
|---|---|
| `T1_ind_enigh_1997_2002_im.tex` | Individual outcomes |
| `T2_hh_enigh_1997_2002_im.tex` | HH income/expenditure outcomes |
| `T3_food_enigh_1997_2002_im.tex` | Food outcomes |
| `T4_health_enigh_1997_2002_im.tex` | Health outcomes |

---

## Column Variables

### T1 — Individual Outcomes (7 columns)

| Col | Variable | Label |
|---|---|---|
| 1 | `employed` | Employment |
| 2 | `hrs_worked` | Hrs Worked |
| 3 | `hrs_worked_pos` | Hrs Worked + |
| 4 | `ind_earnings` | Earnings |
| 5 | `ind_income_tot` | Income |
| 6 | `progresa_ind` | Progresa |
| 7 | `benef_gob_ind` | Transfers |

### T2 — Household Outcomes (8 columns)

| Col | Variable | Label |
|---|---|---|
| 1 | `hh_earnings` | Earnings |
| 2 | `hh_income_tot` | Income |
| 3 | `hh_expenditure` | Expenditure |
| 4 | `progresa_hh` | Progresa |
| 5 | `benef_gob_hh` | Transfers |
| 6 | `savings` | Savings |
| 7 | `debt` | Debt |
| 8 | `n_hh` | Household Size |

### T3 — Food Outcomes (8 columns)

| Col | Variable | Label |
|---|---|---|
| 1 | `food_exp` | Food |
| 2 | `vegg_fruit` | Veg/Fruit |
| 3 | `cereals` | Cereals |
| 4 | `meat_dairy` | Meat/Dairy |
| 5 | `sugar_fat_drink` | Sugar/Fat |
| 6 | `alcohol` | Alcohol |
| 7 | `tobacco` | Tobacco |
| 8 | `vice` | Vice |

### T4 — Health Outcomes (8 columns)

| Col | Variable | Label |
|---|---|---|
| 1 | `health_exp` | Health |
| 2 | `medical` | Medical Visits |
| 3 | `medical_inpatient` | Inpatient |
| 4 | `medical_outpatient` | Outpatient |
| 5 | `drugs` | Drugs |
| 6 | `drugs_prescribed` | Drugs Prescribed |
| 7 | `drugs_overcounter` | Drugs OC |
| 8 | `ortho` | Orthotics |
