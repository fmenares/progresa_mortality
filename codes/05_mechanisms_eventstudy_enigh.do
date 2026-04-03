*=============================================================================
* 05_mechanisms_eventstudy_enigh.do
*
* Event-study figures mirroring Set 1 of 04_mechanisms_enigh_1999_lag.do.
*
* SPECIFICATION
* -------------
*   reghdfe outcome ib1996.year#c.inten1999 [pw=exp_factor]
*          if [sample] & year != 1998, a(year mun) cl(mun)
*
*   - inten1999 only (enrollment intensity as of 1999)
*   - 1998 ENIGH wave excluded throughout (pre-period ends 1996,
*     post-period starts 2000)
*   - 1996 = omitted reference year (beta = 0 by construction)
*   - Sample: highly marginalized municipalities (gm_mun_1990 == 4 | 5)
*
* OUTPUT
* ------
*   One combined figure per outcome group (T1–T4).
*   Each sub-panel = one outcome variable with three overlaid series:
*
*     Pooled  — navy,         solid line,          circle marker
*     Female  — cranberry,    dashed line,          square marker
*     Male    — forest_green, shortdash_dot line,   triangle marker
*
*   Series are cascaded on the x-axis (±0.18 offset) so that CI bars
*   do not overlap.  Bars = 95% CI.  Red dashed xline at 3.5 marks
*   PROGRESA rollout (after 1996 wave, before 2000 wave).
*
*   x-axis positions (8 waves):
*     1=1992  2=1994  3=1996(ref)  4=2000  5=2002  6=2004  7=2005  8=2006
*
* FILES SAVED
*   F_ES_T1_1999_lag.pdf/png  — individual outcomes  (mirrors Table 1)
*   F_ES_T2_1999_lag.pdf/png  — household outcomes   (mirrors Table 2)
*   F_ES_T3_1999_lag.pdf/png  — food expenditure     (mirrors Table 3)
*   F_ES_T4_1999_lag.pdf/png  — health expenditure   (mirrors Table 4)
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
	global data   "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global tables "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables"
	global output "$tables"
}

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
* 4. EVENT STUDY FIGURES
*     - inten1999 × year dummies, 1996 reference, 1998 excluded
*     - Three series per panel: Pooled / Female / Male
*     - Cascade: ±0.18 x-offset to separate CI bars
*
* x-axis positions (8 waves, 1998 omitted):
*   1=1992  2=1994  3=1996(ref)  4=2000  5=2002  6=2004  7=2005  8=2006
*-----------------------------------------------------------------------------

local yr_order  "1992 1994 1996 2000 2002 2004 2005 2006"
local yr_labels `"1 "1992" 2 "1994" 3 "1996" 4 "2000" 5 "2002" 6 "2004" 7 "2005" 8 "2006""'

foreach tbl in T1 T2 T3 T4 {

	* Level of observation: individual (T1) vs household (T2–T4)
	local hh_cond = cond("`tbl'" == "T1", "", "hh_unique == 1 & ")

	* Gender condition variable
	local fem_var = cond("`tbl'" == "T1", "female", "hhh_female")

	local k = 0
	local gph_list ""

	foreach outcome in ${`tbl'} {

		local ++k
		local lb "`lbl_`tbl'_`k''"

		*----------------------------------------------------------------------
		* 4a. Run three regressions; store b and se as locals
		*----------------------------------------------------------------------

		foreach grp in w f m {

			if "`grp'" == "w" local grp_cond ""
			if "`grp'" == "f" local grp_cond "& `fem_var' == 1"
			if "`grp'" == "m" local grp_cond "& `fem_var' == 0"

			cap noisily reghdfe `outcome' ib1996.year#c.inten1999 ///
				[pweight = exp_factor] ///
				if `hh_cond'`outcome'_out == 0 & $sample_marg ///
				& year != 1998 `grp_cond', ///
				a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

			local ok_`grp' = (_rc == 0)

			if `ok_`grp'' {
				foreach yr in 1992 1994 2000 2002 2004 2005 2006 {
					local b_`grp'_`yr'  = _b[`yr'.year#c.inten1999]
					local se_`grp'_`yr' = _se[`yr'.year#c.inten1999]
				}
			}
		}

		if !`ok_w' & !`ok_f' & !`ok_m' {
			di as error "  *** All regressions failed for `outcome' in `tbl' — skipping panel"
			continue
		}

		*----------------------------------------------------------------------
		* 4b. Build wide plotting dataset (8 time points, 3 groups)
		*     xpos_w = yr_pos      (pooled, centred)
		*     xpos_f = yr_pos-0.18 (female, left)
		*     xpos_m = yr_pos+0.18 (male, right)
		*----------------------------------------------------------------------

		preserve
		clear
		set obs 8

		gen yr_pos = _n                  // 1–8
		gen xpos_w = yr_pos
		gen xpos_f = yr_pos - 0.18
		gen xpos_m = yr_pos + 0.18

		foreach grp in w f m {
			gen b_`grp'  = .
			gen hi_`grp' = .
			gen lo_`grp' = .
		}

		local pos = 1
		foreach yr in `yr_order' {

			if `yr' == 1996 {
				* reference year: zero by construction for all groups
				foreach grp in w f m {
					replace b_`grp'  = 0 if yr_pos == `pos'
					replace hi_`grp' = 0 if yr_pos == `pos'
					replace lo_`grp' = 0 if yr_pos == `pos'
				}
			}
			else {
				foreach grp in w f m {
					if `ok_`grp'' {
						replace b_`grp'  = `b_`grp'_`yr''                           ///
							if yr_pos == `pos'
						replace hi_`grp' = `b_`grp'_`yr'' + 1.96 * `se_`grp'_`yr'' ///
							if yr_pos == `pos'
						replace lo_`grp' = `b_`grp'_`yr'' - 1.96 * `se_`grp'_`yr'' ///
							if yr_pos == `pos'
					}
				}
			}

			local ++pos
		}

		*----------------------------------------------------------------------
		* 4c. Panel graph: cascade of three event-study series
		*----------------------------------------------------------------------

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
			xlabel(`yr_labels', ///
				labsize(tiny) angle(45) grid gmax) ///
			xscale(range(0.5 8.5)) ///
			xtitle("") ytitle("Coeff.", size(tiny)) ///
			title("`lb'", size(small) color(black) margin(b=1)) ///
			legend(order(6 "Pooled" 2 "Female" 4 "Male") ///
				cols(3) size(tiny) ///
				region(lcolor(none)) ///
				symxsize(5) keygap(1) rowgap(0)) ///
			graphregion(color(white)) ///
			plotregion(margin(l=1 r=1)) ///
			saving("$data/es_`tbl'_1999_`k'.gph", replace)

		restore

		local gph_list `"`gph_list' "$data/es_`tbl'_1999_`k'.gph""'

	} // end foreach outcome

	*--------------------------------------------------------------------------
	* 4d. Combine sub-panels into one figure per outcome group
	*--------------------------------------------------------------------------

	local n_panels = `k'
	local n_cols   = min(`n_panels', 4)
	local n_rows   = ceil(`n_panels' / `n_cols')

	graph combine `gph_list', ///
		rows(`n_rows') cols(`n_cols') ///
		title("Event Study — `title_`tbl'' (Intensity 1999)", ///
			size(medsmall) color(black)) ///
		note("Spec: ib1996.year#c.inten1999 | Sample: highly marginalized (GM 4–5) | 1998 excluded." ///
			" 1996 = reference (0). Red line: PROGRESA rollout. Bars = 95% CI (SE clustered by mun.)." ///
			" Colors: navy=Pooled  cranberry=Female  forest_green=Male.", ///
			size(tiny)) ///
		graphregion(color(white)) ///
		saving("$output/F_ES_`tbl'_1999_lag.gph", replace)

	graph export "$output/F_ES_`tbl'_1999_lag.pdf", replace
	graph export "$output/F_ES_`tbl'_1999_lag.png", replace width(2400)

	di as result "  => Saved F_ES_`tbl'_1999_lag.pdf / .png"

	forval j = 1/`n_panels' {
		cap erase "$data/es_`tbl'_1999_`j'.gph"
	}

} // end foreach tbl

di as result _n "Done. Four event-study figures (T1–T4, inten1999, 1998 excluded) saved to: $output"
