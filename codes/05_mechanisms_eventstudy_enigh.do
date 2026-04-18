*=============================================================================
* 05_mechanisms_eventstudy_enigh.do
*
* Pre-trend tests for ENIGH mechanisms analysis.
*
* SPECIFICATIONS
* -------------
*   Approach 1 (inten1998):
*     reghdfe outcome ib1996.year ib1996.year#c.inten1998 [pw=exp_factor]
*            if [sample], a(mun) cl(mun)
*     -> All years included; extracts pre-period coefficients only.
*
*   Approach 2 (inten2000):
*     reghdfe outcome ib1996.year ib1996.year#c.inten2000 [pw=exp_factor]
*            if [sample] & year != 1998, a(mun) cl(mun)
*     -> 1998 excluded (mirrors DiD spec for 2000 treatment).
*     -> Extracts pre-period coefficients only.
*
*   Both approaches:
*     - Sample: highly marginalized municipalities (gm_mun_1990 == 4 | 5)
*     - Reference year: 1996 (beta = 0 by construction)
*     - Three series per figure: Pooled / Female / Male
*
* OUTPUT
* ------
*   One figure per outcome variable per approach.
*   x-axis: 1992, 1994, 1996 (pre-period only; 1996 = reference = 0)
*   Red dashed xline at 3.5 marks end of pre-period.
*   Bars = 95% CI.
*
*   Approach 1:  F_PT_1998_`outcome'.pdf/png  (saved to $output/pretrend/)
*   Approach 2:  F_PT_2000_`outcome'.pdf/png  (saved to $output/pretrend/)
*
*   Both approaches share the same pre-period (1992, 1994, 1996),
*   so pre-trend patterns should be virtually identical across specs.
*=============================================================================

clear
set more off
capture log close

*-----------------------------------------------------------------------------
* 0. PATHS
*-----------------------------------------------------------------------------

if c(username) == "felip" {
	global data   "C:\Users\felip\Dropbox\2024\70ymas\data/"
	global output "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
}

if c(username) == "fmenares" {
	global data   "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global output "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
}

if c(username) == "FELIPEME" {
	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global tables "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables"
	global figures  "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_mortality\figures" 
	global output "$tables"
	global output "$figures"
}

cap mkdir "$output/pretrend"

*-----------------------------------------------------------------------------
* 1. DATA
*-----------------------------------------------------------------------------

use "$data/enigh_panel", clear

merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", keep(1 3) nogen
destring cve_ent cve_mun, replace
format cve_ent %02.0f
format cve_mun %03.0f
gen cve_mun2 = string(cve_ent, "%02.0f") + string(cve_mun, "%03.0f")
replace cve_mun2 = cve_ent_mun_super if cve_ent_mun_super != ""
drop cve_ent_mun_super
rename cve_mun2 cve_ent_mun_super
sort cve_ent_mun_super

merge m:1 cve_ent_mun_super year using "$data/mortality_muni.dta", keep(3)

global sample_marg = "(gm_mun_1990==4|gm_mun_1990==5)"

*-----------------------------------------------------------------------------
* 2. AUXILIARY VARIABLES
*-----------------------------------------------------------------------------

g hrs_worked_pos = hrs_worked if hrs_worked != . & hrs_worked != 0
egen vice    = rsum(alcohol tobacco)
egen medical = rsum(medical_inpatient medical_outpatient)

global years = "1992 1994 1996 1998 2000 2002 2004 2005 2006"

global raw_outcomes = "ind_earnings ind_income_tot hh_income_tot hh_earnings benef_gob_ind benef_gob_hh hh_expenditure food_exp cereals meat_dairy sugar_fat_drink vegg_fruit health_exp health_med medical drugs savings debt currency loans"

foreach outcome in $raw_outcomes {
	g `outcome'_out = .
	foreach yr in $years {
		sum `outcome' if year == `yr' & $sample_marg, d
		replace `outcome'_out = (`outcome' > `r(p99)') if year == `yr'
	}
}

replace benef_gob_ind_out = ind_earnings_out
g progresa_ind_out    = ind_earnings_out
g hrs_worked_out      = 0
g hrs_worked_pos_out  = 0
g employed_out        = ind_earnings_out

replace benef_gob_hh_out = hh_earnings_out
g progresa_hh_out = hh_earnings_out
g n_hh_out        = hh_earnings_out

g alcohol_out = 0
g tobacco_out = 0
g vice_out    = 0

g medical_inpatient_out  = medical_out
g medical_outpatient_out = medical_out
g drugs_prescribed_out   = drugs_out
g drugs_overcounter_out  = drugs_out
g ortho_out              = 0

*-----------------------------------------------------------------------------
* 3. OUTCOME GROUPS AND LABELS
*-----------------------------------------------------------------------------

global T1 "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"
global T2 "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
global T3 "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
global T4 "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

local title_T1 "Individual Outcomes"
local title_T2 "Household Outcomes"
local title_T3 "Food Expenditure"
local title_T4 "Health Expenditure"

* T1 panel labels
local lbl_T1_1 "Employment"
local lbl_T1_2 "Hrs Worked"
local lbl_T1_3 "Hrs Worked (>0)"
local lbl_T1_4 "Earnings"
local lbl_T1_5 "Income"
local lbl_T1_6 "PROGRESA Transfers"
local lbl_T1_7 "Gov. Transfers"

* T2 panel labels
local lbl_T2_1 "Earnings"
local lbl_T2_2 "Income"
local lbl_T2_3 "Expenditure"
local lbl_T2_4 "PROGRESA"
local lbl_T2_5 "Gov. Transfers"
local lbl_T2_6 "Savings"
local lbl_T2_7 "Debt"
local lbl_T2_8 "HH Size"

* T3 panel labels
local lbl_T3_1 "Total Food"
local lbl_T3_2 "Veggies & Fruit"
local lbl_T3_3 "Cereals"
local lbl_T3_4 "Meat & Dairy"
local lbl_T3_5 "Sugar & Fat"
local lbl_T3_6 "Alcohol"
local lbl_T3_7 "Tobacco"
local lbl_T3_8 "Vice"

* T4 panel labels
local lbl_T4_1 "Total Health"
local lbl_T4_2 "Medical Visits"
local lbl_T4_3 "Inpatient"
local lbl_T4_4 "Outpatient"
local lbl_T4_5 "Drugs"
local lbl_T4_6 "Drugs (Rx)"
local lbl_T4_7 "OTC Drugs"
local lbl_T4_8 "Orthotics"

*-----------------------------------------------------------------------------
* 4. PRE-TREND FIGURES
*
*   Loop over two intensity approaches (1998 and 2000).
*   For each outcome: run full event-study regression (all relevant years),
*   extract only pre-period interactions (1992, 1994; 1996 = reference = 0),
*   and export one figure per outcome.
*
*   x-axis positions: 1=1992  2=1994  3=1996(ref)
*   Series: Pooled (navy, solid, circle) / Female (cranberry, dashed, square)
*           / Male (forest_green, shortdash_dot, triangle)
*   Cascade ±0.18 on x-axis so CI bars do not overlap.
*   Red dashed xline at 3.5 marks end of pre-period.
*-----------------------------------------------------------------------------

local yr_labels_pre `"1 "1992" 2 "1994" 3 "1996""'

foreach sample in marg all {

	if "`sample'" == "marg" {
		local sample_cond  "& (gm_mun_1990==4|gm_mun_1990==5)"
		local sample_label "Highly marginalized (GM 4-5)"
	}
	if "`sample'" == "all" {
		local sample_cond  ""
		local sample_label "All municipalities"
	}

	cap mkdir "$output/pretrend/`sample'"

foreach approach in 1998 2000 {

	* Intensity variable and year exclusion for each approach
	if `approach' == 1998 {
		local inten_var "inten1998"
		local yr_excl   ""
		local spec_note "Intensity 1998 x post | `sample_label'"
	}
	if `approach' == 2000 {
		local inten_var "inten2000"
		local yr_excl   "& year != 1998"
		local spec_note "Intensity 2000 x post | `sample_label' | 1998 excl."
	}

	foreach tbl in T1 T2 T3 T4 {

		* Unit of observation: individual (T1) vs household (T2-T4)
		local hh_cond = cond("`tbl'" == "T1", "", "hh_unique == 1 & ")

		* Gender variable
		local fem_var = cond("`tbl'" == "T1", "female", "hhh_female")

		local k = 0

		foreach outcome in ${`tbl'} {

			local ++k
			local lb "`lbl_`tbl'_`k''"

			*------------------------------------------------------------------
			* 4a. Run three regressions (pooled, female, male)
			*     Full-sample regression; extract pre-period coefficients only
			*------------------------------------------------------------------

			foreach grp in w f m {

				if "`grp'" == "w" local grp_cond ""
				if "`grp'" == "f" local grp_cond "& `fem_var' == 1"
				if "`grp'" == "m" local grp_cond "& `fem_var' == 0"

				cap noisily reghdfe `outcome' ib1996.year ib1996.year#c.`inten_var' ///
					[pweight = exp_factor] ///
					if `hh_cond'`outcome'_out == 0 `sample_cond' ///
					`yr_excl' `grp_cond', ///
					a(cve_ent_mun_super) cluster(cve_ent_mun_super)

				local ok_`grp' = (_rc == 0)

				if `ok_`grp'' {
					foreach yr in 1992 1994 {
						local b_`grp'_`yr'  = _b[`yr'.year#c.`inten_var']
						local se_`grp'_`yr' = _se[`yr'.year#c.`inten_var']
					}
				}
				else {
					foreach yr in 1992 1994 {
						local b_`grp'_`yr'  = .
						local se_`grp'_`yr' = .
					}
				}
			}

			if !`ok_w' & !`ok_f' & !`ok_m' {
				di as error "  *** All regressions failed for `outcome' (approach `approach') — skipping"
				continue
			}

			*------------------------------------------------------------------
			* 4b. Build plotting dataset (3 time points: 1992, 1994, 1996)
			*------------------------------------------------------------------

			preserve
			clear
			set obs 3

			* yr_pos: 1=1992, 2=1994, 3=1996(ref)
			gen yr_pos = _n
			gen xpos_w = yr_pos
			gen xpos_f = yr_pos - 0.18
			gen xpos_m = yr_pos + 0.18

			foreach grp in w f m {
				gen b_`grp'  = .
				gen hi_`grp' = .
				gen lo_`grp' = .
			}

			* 1992 (position 1)
			foreach grp in w f m {
				if `ok_`grp'' {
					replace b_`grp'  = `b_`grp'_1992'                           if yr_pos == 1
					replace hi_`grp' = `b_`grp'_1992' + 1.96 * `se_`grp'_1992' if yr_pos == 1
					replace lo_`grp' = `b_`grp'_1992' - 1.96 * `se_`grp'_1992' if yr_pos == 1
				}
			}

			* 1994 (position 2)
			foreach grp in w f m {
				if `ok_`grp'' {
					replace b_`grp'  = `b_`grp'_1994'                           if yr_pos == 2
					replace hi_`grp' = `b_`grp'_1994' + 1.96 * `se_`grp'_1994' if yr_pos == 2
					replace lo_`grp' = `b_`grp'_1994' - 1.96 * `se_`grp'_1994' if yr_pos == 2
				}
			}

			* 1996 (position 3) — reference year, all zeros
			foreach grp in w f m {
				replace b_`grp'  = 0 if yr_pos == 3
				replace hi_`grp' = 0 if yr_pos == 3
				replace lo_`grp' = 0 if yr_pos == 3
			}

			*------------------------------------------------------------------
			* 4c. Export figure: one per outcome
			*------------------------------------------------------------------

			twoway ///
				(rcap hi_f lo_f xpos_f, ///
					lcolor(cranberry%60) lwidth(vthin)) ///
				(connected b_f xpos_f, ///
					mcolor(cranberry) lcolor(cranberry) ///
					msymbol(square) msize(vsmall) ///
					lpattern(dash) lwidth(thin)) ///
				(rcap hi_m lo_m xpos_m, ///
					lcolor(forest_green%60) lwidth(vthin)) ///
				(connected b_m xpos_m, ///
					mcolor(forest_green) lcolor(forest_green) ///
					msymbol(triangle) msize(vsmall) ///
					lpattern(shortdash_dot) lwidth(thin)) ///
				(rcap hi_w lo_w xpos_w, ///
					lcolor(navy%60) lwidth(vthin)) ///
				(connected b_w xpos_w, ///
					mcolor(navy) lcolor(navy) ///
					msymbol(circle) msize(vsmall) ///
					lpattern(solid) lwidth(thin)), ///
				yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
				xline(3.5, lcolor(red) lpattern(dash) lwidth(vthin)) ///
				xlabel(`yr_labels_pre', ///
					labsize(tiny) angle(45) grid gmax) ///
				xscale(range(0.5 4)) ///
				xtitle("") ytitle("Coeff.", size(tiny)) ///
				title("`lb'", size(small) color(black) margin(b=1)) ///
				subtitle("`title_`tbl''", size(tiny) color(gs6) margin(b=1)) ///
				note("`spec_note'." ///
					" 1996 = reference (0). Red line: end of pre-period." ///
					" Bars = 95% CI (SE clustered by mun.).", ///
					size(tiny)) ///
				legend(order(6 "Pooled" 2 "Female" 4 "Male") ///
					cols(3) size(tiny) ///
					region(lcolor(none)) ///
					symxsize(5) keygap(1) rowgap(0)) ///
				graphregion(color(white)) ///
				plotregion(margin(l=1 r=1))

			graph export "$output/pretrend/`sample'/F_PT_`approach'_`outcome'.pdf", replace
			graph export "$output/pretrend/`sample'/F_PT_`approach'_`outcome'.png", replace width(2400)

			di as result "  => Saved `sample'/F_PT_`approach'_`outcome'.pdf / .png"

			restore

		} // end foreach outcome

	} // end foreach tbl

} // end foreach approach

} // end foreach sample

di as result _n "Done."
di as result "Pre-trend figures (one per outcome) saved to: $output/pretrend/"
di as result "  marg/: F_PT_1998_*.pdf/png  F_PT_2000_*.pdf/png"
di as result "  all/:  F_PT_1998_*.pdf/png  F_PT_2000_*.pdf/png"
