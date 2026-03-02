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
	global data   "C:\Users\felip\Dropbox\2024\70ymas\data/"
	global output "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
}
if c(username)=="fmenares" {
	global data   "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global output "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
}
if c(username)=="FELIPEME" {
	global data   "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global output "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables"
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
