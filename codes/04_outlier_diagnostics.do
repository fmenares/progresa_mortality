clear
set more off
capture log close

* ============================================================
* 04_outlier_diagnostics.do
* Diagnoses the year-specific p99 outlier removal used in
* 03_mechanisms_enigh.do. Checks:
*   1. Flagging rate  — is ~1% flagged each year per variable?
*   2. Threshold stability — do p99 cutoffs jump across years?
*   3. Extremity      — how far above p99 are the trimmed values?
*   4. Mean impact    — how much does trimming shift the mean?
*   5. Borrowed flags — are proxy _out flags appropriate?
* ============================================================

* --- Paths (mirror 03_mechanisms_enigh.do) ---
if c(username)=="felip" {
	global data    "C:\Users\felip\Dropbox\2024\70ymas\data/"
	global output  "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global figures "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/figures/"
}
if c(username)=="fmenares" {
	global data    "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global output  "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global figures "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/figures/"
}
if c(username)=="FELIPEME" {
	global data    "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global output  "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables"
	global figures "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\figures"
}

* --- Load data (identical to 03) ---
use "$data/enigh_panel", clear
merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", keep(1 3) nogen
destring cve_ent cve_mun, replace
format cve_ent %02.0f
format cve_mun %03.0f
gen cve_mun2 = string(cve_ent,"%02.0f") + string(cve_mun,"%03.0f")
replace cve_mun2 = cve_ent_mun_super if cve_ent_mun_super != ""
drop cve_ent_mun_super
rename cve_mun2 cve_ent_mun_super
sort cve_ent_mun_super
merge m:1 cve_ent_mun_super year using "$data/mortality_muni.dta", keep(3)

* --- Reconstruct derived variables ---
g hrs_worked_pos = hrs_worked if hrs_worked != . & hrs_worked != 0
egen vice    = rsum(alcohol tobacco)
egen medical = rsum(medical_inpatient medical_outpatient)

global sample_marg = "(gm_mun_1990==4|gm_mun_1990==5)"
global years       = "1992 1994 1996 1998 2000 2002 2004 2005 2006"
global raw_outcomes = "ind_earnings ind_income_tot hh_income_tot hh_earnings benef_gob_ind benef_gob_hh hh_expenditure food_exp cereals meat_dairy sugar_fat_drink vegg_fruit health_exp health_med medical drugs savings debt currency loans"

* --- Recreate _out flags (identical to 03) ---
foreach outcome in $raw_outcomes {
	g `outcome'_out = .
	foreach year in $years {
		sum `outcome' if year == `year' & $sample_marg, d
		replace `outcome'_out = (`outcome' > `r(p99)') if year == `year'
	}
}


* ============================================================
* DIAGNOSTIC 1: Flagging rate — % flagged per variable x year
* Expected: ~1% per cell. Values well below 1% suggest ties
* at p99 are absorbing many observations above the threshold.
* ============================================================

di _newline(2) "========================================================"
di "DIAGNOSTIC 1: FLAGGING RATE BY VARIABLE AND YEAR"
di "Expected: ~1% per cell. Deviations indicate ties at p99."
di "========================================================"

* Save results to a matrix for tabulation
tempname flagrate
local nvars : word count $raw_outcomes
local nyears : word count $years
matrix `flagrate' = J(`nvars', `nyears', .)

local r = 0
foreach outcome in $raw_outcomes {
	local ++r
	local c = 0
	foreach year in $years {
		local ++c
		qui count if year == `year' & $sample_marg & `outcome' != .
		local N_total = r(N)
		qui count if year == `year' & $sample_marg & `outcome'_out == 1
		local N_flag  = r(N)
		if `N_total' > 0 {
			matrix `flagrate'[`r', `c'] = round(100 * `N_flag' / `N_total', 0.01)
		}
	}
}

matrix rownames `flagrate' = $raw_outcomes
matrix colnames `flagrate' = $years
matrix list `flagrate', format(%5.2f)


* ============================================================
* DIAGNOSTIC 2: P99 threshold stability across years
* Large jumps may indicate structural breaks in the data
* (e.g. survey redesign between waves) rather than true
* changes in the distribution.
* ============================================================

di _newline(2) "========================================================"
di "DIAGNOSTIC 2: P99 THRESHOLDS BY VARIABLE AND YEAR"
di "Check for implausible jumps across survey waves."
di "========================================================"

tempname thresholds
matrix `thresholds' = J(`nvars', `nyears', .)

local r = 0
foreach outcome in $raw_outcomes {
	local ++r
	local c = 0
	foreach year in $years {
		local ++c
		qui sum `outcome' if year == `year' & $sample_marg, d
		matrix `thresholds'[`r', `c'] = r(p99)
	}
}

matrix rownames `thresholds' = $raw_outcomes
matrix colnames `thresholds' = $years
matrix list `thresholds', format(%12.1f)


* ============================================================
* DIAGNOSTIC 3: Extremity — ratio of max to p99
* Ratio near 1 → trimmed values are barely above threshold
*   (trimming is conservative, may not matter much).
* Very high ratio → genuine extreme outliers being removed.
* ============================================================

di _newline(2) "========================================================"
di "DIAGNOSTIC 3: MAX / P99 RATIO BY VARIABLE AND YEAR"
di "Ratio >> 1 means trimmed values are truly extreme."
di "Ratio near 1 means trimming has little effect."
di "========================================================"

tempname extratio
matrix `extratio' = J(`nvars', `nyears', .)

local r = 0
foreach outcome in $raw_outcomes {
	local ++r
	local c = 0
	foreach year in $years {
		local ++c
		qui sum `outcome' if year == `year' & $sample_marg, d
		local p99    = r(p99)
		local maxval = r(max)
		if `p99' > 0 {
			matrix `extratio'[`r', `c'] = round(`maxval' / `p99', 0.01)
		}
		else {
			matrix `extratio'[`r', `c'] = .
		}
	}
}

matrix rownames `extratio' = $raw_outcomes
matrix colnames `extratio' = $years
matrix list `extratio', format(%8.2f)


* ============================================================
* DIAGNOSTIC 4: Impact on mean — % change in mean after trimming
* Large % changes (>5%) mean the outliers were materially
* distorting the mean used in regressions.
* Near-zero changes → trimming has little effect on results.
* ============================================================

di _newline(2) "========================================================"
di "DIAGNOSTIC 4: % CHANGE IN MEAN AFTER OUTLIER REMOVAL"
di "Pooled across years within $sample_marg."
di "========================================================"

foreach outcome in $raw_outcomes {
	qui sum `outcome' if $sample_marg
	local mean_with = r(mean)
	local sd_with   = r(sd)
	qui sum `outcome' if $sample_marg & `outcome'_out == 0
	local mean_wo = r(mean)
	local sd_wo   = r(sd)
	if `mean_with' != 0 & `mean_with' != . {
		local pct_chg = 100 * (`mean_with' - `mean_wo') / abs(`mean_with')
		di %-28s "`outcome'" "  mean_full=" %10.2f `mean_with' ///
		   "  mean_trimmed=" %10.2f `mean_wo' ///
		   "  pct_chg=" %6.2f `pct_chg' "%"
	}
	else {
		di %-28s "`outcome'" "  mean is zero or missing — skipping"
	}
}


* ============================================================
* DIAGNOSTIC 5: Borrowed-flag audit
* For each variable that uses another variable's _out flag,
* compare how many observations that flag removes vs. what
* the variable's own p99 would have removed.
* ============================================================

di _newline(2) "========================================================"
di "DIAGNOSTIC 5: BORROWED FLAG AUDIT"
di "Compares N flagged by borrowed _out vs. own p99."
di "A mismatch means the borrowed flag is not the same as"
di "what the variable's own distribution would produce."
di "========================================================"

* Pairs: borrowed_var donor_var
local borrow_pairs "benef_gob_ind ind_earnings progresa_ind ind_earnings employed ind_earnings benef_gob_hh hh_earnings progresa_hh hh_earnings n_hh hh_earnings medical_inpatient medical medical_outpatient medical drugs_prescribed drugs drugs_overcounter drugs"

local np : word count `borrow_pairs'
local k = 1
while `k' <= `np' {
	local own   : word `k'       of `borrow_pairs'
	local donor : word `=`k'+1' of `borrow_pairs'
	local k = `k' + 2

	di _newline "  `own'_out borrows from `donor'_out"
	di "  Year    N_borrowed   N_own_p99   Difference"
	foreach year in $years {
		* Count flagged by borrowed donor flag
		qui count if year == `year' & $sample_marg & `donor'_out == 1
		local n_borrowed = r(N)

		* Count what own p99 would flag
		qui sum `own' if year == `year' & $sample_marg, d
		local p99_own = r(p99)
		qui count if year == `year' & $sample_marg ///
			& `own' > `p99_own' & `own' != .
		local n_own = r(N)

		local diff = `n_borrowed' - `n_own'
		di "  `year'    " %6.0f `n_borrowed' "       " %6.0f `n_own' ///
		   "       " %6.0f `diff'
	}
}


* ============================================================
* DIAGNOSTIC 6: Variables with zero trimming (never flagged)
* These are kept as-is — confirm this is intentional.
* ============================================================

di _newline(2) "========================================================"
di "DIAGNOSTIC 6: VARIABLES WITH NO TRIMMING (_out hardcoded = 0)"
di "========================================================"
di "  hrs_worked_out     = 0  (all observations kept)"
di "  hrs_worked_pos_out = 0  (all observations kept)"
di "  alcohol_out        = 0  (all observations kept)"
di "  tobacco_out        = 0  (all observations kept)"
di "  vice_out           = 0  (all observations kept)"
di "  ortho_out          = 0  (all observations kept)"
di ""
di "Checking whether these variables have outliers that are being kept:"

foreach outcome in hrs_worked hrs_worked_pos alcohol tobacco vice ortho {
	capture confirm variable `outcome'
	if _rc == 0 {
		qui sum `outcome' if $sample_marg, d
		local ratio_check = r(max) / max(r(p99), 0.001)
		di "  `outcome':  p99=" %10.2f r(p99) "  max=" %10.2f r(max) ///
		   "  max/p99=" %6.2f `ratio_check'
	}
}

di _newline(2) "========================================================"
di "END OF OUTLIER DIAGNOSTICS"
di "========================================================"


* ============================================================
* SECTION 7: TREATMENT INTENSITY VARIATION IN THE ENIGH SAMPLE
*
* inten1997 is a municipality-level constant (fraction of
* households enrolled in 1997).  For the event study to
* identify causal effects, the ENIGH municipalities must
* have sufficient CROSS-SECTIONAL variation in inten1997
* and comparable intensity distributions across survey waves.
*
* Figures produced:
*   FA1a — distribution of inten1997 across unique ENIGH
*            municipalities (highly marginalized only)
*   FA1b — box plot of inten1997 by survey wave (to check
*            whether municipal composition shifts over time)
*   FA1c — table: N municipalities, mean, SD, p25/p50/p75
*            of inten1997 by survey wave
* ============================================================

* Auxiliary: post dummy and treatment intensity flag
gen post = (year >= 1997) if year != .

* --- Collapse to municipality × year (one obs per mun-wave) ---
preserve

	keep if $sample_marg & inten1997 != .
	bysort cve_ent_mun_super year: keep if _n == 1

	* --- FA1a: kernel density of inten1997 (unique municipalities pooled) ---
	bysort cve_ent_mun_super: keep if _n == 1        // unique municipalities

	twoway kdensity inten1997,                                               ///
		lcolor(navy) lwidth(medthick)                                        ///
		graphregion(fcolor(white))                                           ///
		xtitle("PROGRESA Beneficiary Share (1997)")                          ///
		ytitle("Density")                                                    ///
		title("Treatment Intensity Distribution: ENIGH Municipalities")      ///
		subtitle("Highly marginalized only (gm{subscript:1990} = 4 or 5)") ///
		note("One observation per municipality." ///
		     "Dashed line = sample mean.", size(small))                      ///
		xline(`=r(mean)', lpattern(dash) lcolor(gray))
	graph export "$figures/FA1a_inten1997_kdensity.pdf", as(pdf) replace

restore

* --- FA1b: box plot of inten1997 by survey wave ---
preserve

	keep if $sample_marg & inten1997 != .
	bysort cve_ent_mun_super year: keep if _n == 1

	graph box inten1997, over(year, label(angle(45) labsize(small)))         ///
		graphregion(fcolor(white))                                           ///
		ytitle("PROGRESA Beneficiary Share (1997)")                          ///
		title("Intensity Distribution by Survey Wave")                       ///
		subtitle("Highly marginalized municipalities")                       ///
		note("Each box = distribution across ENIGH municipalities in that wave.", ///
		     size(small))
	graph export "$figures/FA1b_inten1997_bywave.pdf", as(pdf) replace

restore

* --- FA1c: LaTeX table of intensity distribution by wave ---
preserve

	keep if $sample_marg & inten1997 != .
	bysort cve_ent_mun_super year: keep if _n == 1

	cap file close sm
	file open sm using "$output/TA0_intensity_variation.tex", write replace
	file write sm "\begin{tabular}{lrrrrrrr} \hline \hline"_n
	file write sm "Survey Wave & N Mun & Mean & SD & Min & p25 & p50 & p75-Max \\ \toprule"_n

	foreach y in $years {
		qui count if year == `y'
		local n_mun = r(N)
		if `n_mun' > 0 {
			qui sum inten1997 if year == `y', d
			local mn  : di %6.3f r(mean)
			local sd  : di %6.3f r(sd)
			local mn_ : di %6.3f r(min)
			local p25 : di %6.3f r(p25)
			local p50 : di %6.3f r(p50)
			local p75 : di %6.3f r(p75)
			local mx  : di %6.3f r(max)
			file write sm "`y' & `n_mun' & `mn' & `sd' & `mn_' & `p25' & `p50' & `p75'--`mx' \\"_n
		}
	}

	* Coefficient of variation row
	qui sum inten1997, d
	local cv_all : di %6.3f (r(sd) / r(mean))
	file write sm " & & & & & & & \\ "_n
	file write sm "\multicolumn{8}{l}{\textit{Pooled (all waves):} Mean = " ///
		`"`: di %6.3f r(mean)'" SD = "`: di %6.3f r(sd)'"'               ///
		" CV = `cv_all'} \\"_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm

restore


* ============================================================
* SECTION 8: DESCRIPTIVE STATISTICS — PRE / POST
*
* Three tables, one per outcome group:
*   TA1 — Individual-level outcomes  (T1)
*   TA2 — Household-level outcomes   (T2–T4)
*   TA3 — Diet quality & financial stress (T5–T6)
*
* Columns: Pre N | Pre Mean | Pre SD | Post N | Post Mean | Post SD | Δ
* Pre  = year < 1997 (1992, 1994, 1996)
* Post = year ≥ 1997 (1998, 2000, 2002, 2004, 2005, 2006)
* Sample: gm_mun_1990 == 4 | 5, trimmed observations excluded.
* ============================================================

* ---- helper macro: write one row ----
* Requires locals: vname, vlabel, pre_n, pre_mn, pre_sd, pos_n, pos_mn, pos_sd, delta
* and open file handle sm.

* -- TABLE A1: Individual-level outcomes (T1) --
global desc_ind  = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"
global label_employed        = "Employed (0/1)"
global label_hrs_worked      = "Hours worked (weekly)"
global label_hrs_worked_pos  = "Hours worked | employed"
global label_ind_earnings    = "Individual labor earnings"
global label_ind_income_tot  = "Individual total income"
global label_progresa_ind    = "PROGRESA transfer (indiv.)"
global label_benef_gob_ind   = "Gov. benefits (indiv.)"

cap file close sm
file open sm using "$output/TA1_desc_individual.tex", write replace
file write sm "\begin{tabular}{lrrrrrrrr} \hline \hline"_n
file write sm "& \multicolumn{3}{c}{\textit{Pre (1992--1996)}} & \multicolumn{3}{c}{\textit{Post (1997--2006)}} & \multicolumn{1}{c}{$\Delta$} \\ "_n
file write sm "\cmidrule(lr){2-4}\cmidrule(lr){5-7}"_n
file write sm "Variable & N & Mean & SD & N & Mean & SD & Post$-$Pre \\ \toprule"_n

foreach v in $desc_ind {
	qui sum `v' if $sample_marg & post == 0
	local pre_n  : di %9.0fc r(N)
	local pre_mn : di %9.3f  r(mean)
	local pre_sd : di %9.3f  r(sd)
	qui sum `v' if $sample_marg & post == 1
	local pos_n  : di %9.0fc r(N)
	local pos_mn : di %9.3f  r(mean)
	local pos_sd : di %9.3f  r(sd)
	local delta  : di %9.3f  (r(mean) - `pre_mn')
	file write sm "${label_`v'} & `pre_n' & `pre_mn' & `pre_sd' & `pos_n' & `pos_mn' & `pos_sd' & `delta' \\"_n
}

file write sm "\bottomrule"_n
file write sm "\multicolumn{8}{l}{\footnotesize Sample: highly marginalized municipalities (gm\textsubscript{1990} = 4 or 5). Unweighted.} \\"_n
file write sm "\end{tabular}"
file close sm

* -- TABLE A2: Household-level outcomes (T2-T4) --
global desc_hh = "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco health_exp medical drugs"
global label_hh_earnings     = "HH labor earnings"
global label_hh_income_tot   = "HH total income"
global label_hh_expenditure  = "HH total expenditure"
global label_progresa_hh     = "PROGRESA transfer (HH)"
global label_benef_gob_hh    = "Gov. benefits (HH)"
global label_savings         = "Monthly savings"
global label_debt            = "Monthly debt service"
global label_food_exp        = "Total food expenditure"
global label_vegg_fruit      = "Vegetables \& fruit"
global label_cereals         = "Cereals"
global label_meat_dairy      = "Meat, fish \& dairy"
global label_sugar_fat_drink = "Sugar, fat \& drinks"
global label_alcohol         = "Alcohol"
global label_tobacco         = "Tobacco"
global label_health_exp      = "Total health expenditure"
global label_medical         = "Medical visits (total)"
global label_drugs           = "Drug spending (total)"

cap file close sm
file open sm using "$output/TA2_desc_household.tex", write replace
file write sm "\begin{tabular}{lrrrrrrrr} \hline \hline"_n
file write sm "& \multicolumn{3}{c}{\textit{Pre (1992--1996)}} & \multicolumn{3}{c}{\textit{Post (1997--2006)}} & \multicolumn{1}{c}{$\Delta$} \\ "_n
file write sm "\cmidrule(lr){2-4}\cmidrule(lr){5-7}"_n
file write sm "Variable & N & Mean & SD & N & Mean & SD & Post$-$Pre \\ \toprule"_n

foreach v in $desc_hh {
	qui sum `v' if $sample_marg & hh_unique == 1 & post == 0
	local pre_n  : di %9.0fc r(N)
	local pre_mn : di %9.3f  r(mean)
	local pre_sd : di %9.3f  r(sd)
	qui sum `v' if $sample_marg & hh_unique == 1 & post == 1
	local pos_n  : di %9.0fc r(N)
	local pos_mn : di %9.3f  r(mean)
	local pos_sd : di %9.3f  r(sd)
	local delta  : di %9.3f  (r(mean) - `pre_mn')
	file write sm "${label_`v'} & `pre_n' & `pre_mn' & `pre_sd' & `pos_n' & `pos_mn' & `pos_sd' & `delta' \\"_n
}

file write sm "\bottomrule"_n
file write sm "\multicolumn{8}{l}{\footnotesize Sample: highly marginalized municipalities, one household per HH ID (hh\_unique=1). Unweighted.} \\"_n
file write sm "\end{tabular}"
file close sm

* -- TABLE A3: Diet quality and financial stress (T5-T6) --
global desc_ratios = "protein_share staples_share vegg_fruit_share unhealthy_share diversity_index net_fin_position debt_to_income health_share rx_to_visit_ratio otc_to_rx_ratio"
global label_protein_share     = "Protein share (meat \& dairy / food)"
global label_staples_share     = "Staples share (cereals / food)"
global label_vegg_fruit_share  = "Vegg \& fruit share"
global label_unhealthy_share   = "Unhealthy share (sugar/fat/alc/tob)"
global label_diversity_index   = "Diet diversity index (0--7)"
global label_net_fin_position  = "Net financial position (savings$-$debt)"
global label_debt_to_income    = "Debt-to-income ratio"
global label_health_share      = "Health share (health / total expend.)"
global label_rx_to_visit_ratio = "Rx per outpatient dollar"
global label_otc_to_rx_ratio   = "OTC-to-Rx ratio"

cap file close sm
file open sm using "$output/TA3_desc_ratios.tex", write replace
file write sm "\begin{tabular}{lrrrrrrrr} \hline \hline"_n
file write sm "& \multicolumn{3}{c}{\textit{Pre (1992--1996)}} & \multicolumn{3}{c}{\textit{Post (1997--2006)}} & \multicolumn{1}{c}{$\Delta$} \\ "_n
file write sm "\cmidrule(lr){2-4}\cmidrule(lr){5-7}"_n
file write sm "Variable & N & Mean & SD & N & Mean & SD & Post$-$Pre \\ \toprule"_n
file write sm "\multicolumn{8}{l}{\textit{Panel A: Diet quality}} \\"_n

foreach v in protein_share staples_share vegg_fruit_share unhealthy_share diversity_index {
	qui sum `v' if $sample_marg & hh_unique == 1 & post == 0
	local pre_n  : di %9.0fc r(N)
	local pre_mn : di %9.3f  r(mean)
	local pre_sd : di %9.3f  r(sd)
	qui sum `v' if $sample_marg & hh_unique == 1 & post == 1
	local pos_n  : di %9.0fc r(N)
	local pos_mn : di %9.3f  r(mean)
	local pos_sd : di %9.3f  r(sd)
	local delta  : di %9.3f  (r(mean) - `pre_mn')
	file write sm "${label_`v'} & `pre_n' & `pre_mn' & `pre_sd' & `pos_n' & `pos_mn' & `pos_sd' & `delta' \\"_n
}

file write sm "\multicolumn{8}{l}{\textit{Panel B: Financial stress \& healthcare use}} \\"_n

foreach v in net_fin_position debt_to_income health_share rx_to_visit_ratio otc_to_rx_ratio {
	qui sum `v' if $sample_marg & hh_unique == 1 & post == 0
	local pre_n  : di %9.0fc r(N)
	local pre_mn : di %9.3f  r(mean)
	local pre_sd : di %9.3f  r(sd)
	qui sum `v' if $sample_marg & hh_unique == 1 & post == 1
	local pos_n  : di %9.0fc r(N)
	local pos_mn : di %9.3f  r(mean)
	local pos_sd : di %9.3f  r(sd)
	local delta  : di %9.3f  (r(mean) - `pre_mn')
	file write sm "${label_`v'} & `pre_n' & `pre_mn' & `pre_sd' & `pos_n' & `pos_mn' & `pos_sd' & `delta' \\"_n
}

file write sm "\bottomrule"_n
file write sm "\multicolumn{8}{l}{\footnotesize Sample: highly marginalized municipalities, one household per HH ID (hh\_unique=1). Unweighted.} \\"_n
file write sm "\end{tabular}"
file close sm


* ============================================================
* SECTION 9: BY-YEAR MEANS
*
* Shows the evolution of each outcome across all survey waves.
* Useful to detect pre-trends and assess plausibility of the
* parallel-trends assumption.
*   TA1b — Individual-level outcomes
*   TA2b — Household-level outcomes (T2–T4)
*   TA3b — Diet quality & financial stress (T5–T6)
* ============================================================

* -- TABLE A1b: Individual by year --
cap file close sm
file open sm using "$output/TA1b_byyear_individual.tex", write replace
file write sm "\begin{tabular}{l" + "r" * 9 + "} \hline \hline"_n
file write sm "Variable & 1992 & 1994 & 1996 & 1998 & 2000 & 2002 & 2004 & 2005 & 2006 \\ \toprule"_n

foreach v in $desc_ind {
	file write sm "${label_`v'}"
	foreach y in $years {
		qui sum `v' if year == `y' & $sample_marg
		if r(N) > 0 {
			local mn : di %9.3f r(mean)
			file write sm " & `mn'"
		}
		else {
			file write sm " & --"
		}
	}
	file write sm " \\"_n
}

file write sm "\bottomrule"_n
file write sm "\multicolumn{10}{l}{\footnotesize Cell entries are unweighted means. Sample: gm\textsubscript{1990} = 4 or 5.} \\"_n
file write sm "\end{tabular}"
file close sm

* -- TABLE A2b: Household by year --
cap file close sm
file open sm using "$output/TA2b_byyear_household.tex", write replace
file write sm "\begin{tabular}{l" + "r" * 9 + "} \hline \hline"_n
file write sm "Variable & 1992 & 1994 & 1996 & 1998 & 2000 & 2002 & 2004 & 2005 & 2006 \\ \toprule"_n

foreach v in $desc_hh {
	file write sm "${label_`v'}"
	foreach y in $years {
		qui sum `v' if year == `y' & $sample_marg & hh_unique == 1
		if r(N) > 0 {
			local mn : di %9.3f r(mean)
			file write sm " & `mn'"
		}
		else {
			file write sm " & --"
		}
	}
	file write sm " \\"_n
}

file write sm "\bottomrule"_n
file write sm "\multicolumn{10}{l}{\footnotesize Cell entries are unweighted means. Sample: gm\textsubscript{1990} = 4 or 5, one obs per HH.} \\"_n
file write sm "\end{tabular}"
file close sm

* -- TABLE A3b: Ratios by year --
cap file close sm
file open sm using "$output/TA3b_byyear_ratios.tex", write replace
file write sm "\begin{tabular}{l" + "r" * 9 + "} \hline \hline"_n
file write sm "Variable & 1992 & 1994 & 1996 & 1998 & 2000 & 2002 & 2004 & 2005 & 2006 \\ \toprule"_n
file write sm "\multicolumn{10}{l}{\textit{Panel A: Diet quality}} \\"_n

foreach v in protein_share staples_share vegg_fruit_share unhealthy_share diversity_index {
	file write sm "${label_`v'}"
	foreach y in $years {
		qui sum `v' if year == `y' & $sample_marg & hh_unique == 1
		if r(N) > 0 {
			local mn : di %9.3f r(mean)
			file write sm " & `mn'"
		}
		else {
			file write sm " & --"
		}
	}
	file write sm " \\"_n
}

file write sm "\multicolumn{10}{l}{\textit{Panel B: Financial stress \& healthcare use}} \\"_n

foreach v in net_fin_position debt_to_income health_share rx_to_visit_ratio otc_to_rx_ratio {
	file write sm "${label_`v'}"
	foreach y in $years {
		qui sum `v' if year == `y' & $sample_marg & hh_unique == 1
		if r(N) > 0 {
			local mn : di %9.3f r(mean)
			file write sm " & `mn'"
		}
		else {
			file write sm " & --"
		}
	}
	file write sm " \\"_n
}

file write sm "\bottomrule"_n
file write sm "\multicolumn{10}{l}{\footnotesize Cell entries are unweighted means. Sample: gm\textsubscript{1990} = 4 or 5, one obs per HH.} \\"_n
file write sm "\end{tabular}"
file close sm


* ============================================================
* SECTION 10: WITHIN-BETWEEN VARIATION TABLE
*
* Addresses whether there is sufficient variation in outcomes
* and treatment intensity to identify effects.
*   Columns per outcome: Overall SD | Between-mun SD | Within-mun SD
*   Between-mun SD: SD of municipality means (collapsed across years)
*   Within-mun SD:  SD of demeaned (mun-mean removed) observations
* ============================================================

* We compute for household-level outcomes only; individual outcomes
* follow a similar pattern but the table would be very wide.

global desc_all = ///
	"hh_earnings hh_income_tot hh_expenditure food_exp vegg_fruit cereals " ///
	"meat_dairy health_exp medical drugs " ///
	"protein_share staples_share vegg_fruit_share unhealthy_share " ///
	"diversity_index net_fin_position debt_to_income health_share"

cap file close sm
file open sm using "$output/TA4_within_between.tex", write replace
file write sm "\begin{tabular}{lrrrr} \hline \hline"_n
file write sm "Variable & Overall SD & Between-mun SD & Within-mun SD & CV (Overall) \\ \toprule"_n
file write sm "\multicolumn{5}{l}{\textit{Household-level outcomes}} \\"_n

* -- generate municipality means for each variable, then compute SDs --
foreach v in $desc_all {
	capture confirm variable `v'
	if _rc != 0 {
		di "  skipping `v' — not in dataset"
		continue
	}

	* Overall SD
	qui sum `v' if $sample_marg & hh_unique == 1
	if r(N) == 0 | r(mean) == 0 | r(mean) == . {
		continue
	}
	local sd_overall = r(sd)
	local mean_all   = r(mean)
	local cv         : di %6.3f (`sd_overall' / abs(`mean_all'))

	* Between-municipality SD: collapse to mun means, then compute SD
	preserve
		qui keep if $sample_marg & hh_unique == 1 & `v' != .
		qui collapse (mean) mun_mean_`v' = `v', by(cve_ent_mun_super)
		qui sum mun_mean_`v'
		local sd_between = r(sd)
	restore

	* Within-municipality SD: demean by municipality
	qui bysort cve_ent_mun_super: ///
		egen mun_mean_v = mean(`v') if $sample_marg & hh_unique == 1
	qui gen  within_v = `v' - mun_mean_v if $sample_marg & hh_unique == 1
	qui sum  within_v
	local sd_within = r(sd)
	drop mun_mean_v within_v

	local sd_o : di %9.3f `sd_overall'
	local sd_b : di %9.3f `sd_between'
	local sd_w : di %9.3f `sd_within'
	file write sm "${label_`v'} & `sd_o' & `sd_b' & `sd_w' & `cv' \\"_n
}

file write sm "\bottomrule"_n
file write sm "\multicolumn{5}{l}{\footnotesize Between-mun SD computed from municipality-level means. Within-mun SD from demeaned values.} \\"_n
file write sm "\multicolumn{5}{l}{\footnotesize Sample: gm\textsubscript{1990} = 4 or 5, one obs per HH (hh\_unique=1). Unweighted.} \\"_n
file write sm "\end{tabular}"
file close sm

di _newline(2) "========================================================"
di "SECTIONS 7–10 COMPLETE. Files written:"
di "  $figures/FA1a_inten1997_kdensity.pdf"
di "  $figures/FA1b_inten1997_bywave.pdf"
di "  $output/TA0_intensity_variation.tex"
di "  $output/TA1_desc_individual.tex   (pre/post, T1 vars)"
di "  $output/TA2_desc_household.tex    (pre/post, T2-T4 vars)"
di "  $output/TA3_desc_ratios.tex       (pre/post, T5-T6 vars)"
di "  $output/TA1b_byyear_individual.tex"
di "  $output/TA2b_byyear_household.tex"
di "  $output/TA3b_byyear_ratios.tex"
di "  $output/TA4_within_between.tex    (between vs. within-mun SD)"
di "========================================================"
