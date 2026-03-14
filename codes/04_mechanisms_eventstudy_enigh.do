*=============================================================================
* 04_mechanisms_eventstudy_enigh.do
*
* Event-study figures that parallel Tables 1–4 in 03_mechanisms_enigh.do.
*
* DESIGN
* ------
* Replaces the binary post indicator with year-specific interactions:
*
*   outcome_imt = SUM_{t != 1996} beta_t * inten1999_m * 1(year == t)
*               + alpha_m + gamma_t + eps_imt
*
* Estimated via:
*   reghdfe outcome ib1996.year#c.inten1999 [pw=exp_factor], a(year mun) cl(mun)
*
* Only inten1999 is used (not inten2005); 1996 is the omitted reference year
* (last pre-PROGRESA ENIGH wave). beta_1992 and beta_1994 are pre-trend tests;
* beta_1998 through beta_2006 trace the post-program dynamic.
*
* OUTPUT
* ------
*   F_ES_T1.pdf  — individual outcomes  (mirrors Table 1)
*   F_ES_T2.pdf  — household outcomes   (mirrors Table 2)
*   F_ES_T3.pdf  — food expenditure     (mirrors Table 3)
*   F_ES_T4.pdf  — health expenditure   (mirrors Table 4)
*
* Each figure has one panel per outcome variable (7–8 panels per figure).
* Each panel shows 9 points: waves 1992, 1994, 1996(ref=0), 1998, 2000,
* 2002, 2004, 2005, 2006 at equally-spaced x-positions.
* Red dashed vertical line marks the PROGRESA rollout (between 1996 and 1998).
* 95% CI bars; SE clustered at municipality.
* Weighted by survey expansion factor.
* Sample: highly marginalized municipalities (gm_mun_1990 == 4 | 5).
*=============================================================================

clear
set more off
capture log close

*-----------------------------------------------------------------------------
* 0. PATHS  (mirror 03_mechanisms_enigh.do)
*-----------------------------------------------------------------------------

if c(username) == "felip" {
	global deaths "C:\Users\felip\Dropbox\R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data   "C:\Users\felip\Dropbox\2024\70ymas\data/"
	global output "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global iter   "C:\Users\felip\Dropbox\R01_MHAS\Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP     "C:\Users\felip\Dropbox\R01_MHAS\SocialProgramBeneficiaries"
}

if c(username) == "fmenares" {
	global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data   "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global output "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global iter   "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP     "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"
}

if c(username) == "FELIPEME" {
	global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data   "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global tables "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables"
	global output "$tables"
	global iter   "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP     "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"
}

*-----------------------------------------------------------------------------
* 1. DATA  (identical to 03_mechanisms_enigh.do)
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
* 2. AUXILIARY VARIABLES  (identical to 03_mechanisms_enigh.do)
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

* variables without own _out inherit from a related variable
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

* --- outcome globals (same as 03_mechanisms_enigh.do) ---
global T1 "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"
global T2 "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
global T3 "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
global T4 "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

* --- figure-level titles ---
local title_T1 "Individual Outcomes"
local title_T2 "Household Outcomes"
local title_T3 "Food Expenditure"
local title_T4 "Health Expenditure"

* --- panel titles (indexed: lbl_Tk_j = label for j-th outcome in group k) ---

* T1
local lbl_T1_1 "Employment"
local lbl_T1_2 "Hrs Worked"
local lbl_T1_3 "Hrs Worked (>0)"
local lbl_T1_4 "Earnings"
local lbl_T1_5 "Income"
local lbl_T1_6 "PROGRESA Transfers"
local lbl_T1_7 "Gov. Transfers"

* T2
local lbl_T2_1 "Earnings"
local lbl_T2_2 "Income"
local lbl_T2_3 "Expenditure"
local lbl_T2_4 "PROGRESA"
local lbl_T2_5 "Gov. Transfers"
local lbl_T2_6 "Savings"
local lbl_T2_7 "Debt"
local lbl_T2_8 "HH Size"

* T3
local lbl_T3_1 "Total Food"
local lbl_T3_2 "Veggies & Fruit"
local lbl_T3_3 "Cereals"
local lbl_T3_4 "Meat & Dairy"
local lbl_T3_5 "Sugar & Fat"
local lbl_T3_6 "Alcohol"
local lbl_T3_7 "Tobacco"
local lbl_T3_8 "Vice"

* T4
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
*-----------------------------------------------------------------------------
*
* x-axis positions map to ENIGH waves at equal spacing:
*   1=1992  2=1994  3=1996(ref)  4=1998  5=2000  6=2002  7=2004  8=2005  9=2006
*
* 1996 is set to b=0 / hi95=0 / lo95=0 (reference by construction).
* Red dashed xline(3.5) marks the PROGRESA rollout (after 1996, before 1998).
*
* Outer loop: produces one set of 4 figures per intensity measure.
*   inten1999 — enrollment intensity as of 1999 (early rollout)
*   inten2005 — enrollment intensity as of 2005 (mature program)
*

foreach inten in inten1997 inten1999 inten2005 {

	* human-readable intensity label for figure titles and file names
	if "`inten'" == "inten1997" local inten_lbl "Intensity 1997"
	if "`inten'" == "inten1999" local inten_lbl "Intensity 1999"
	if "`inten'" == "inten2005" local inten_lbl "Intensity 2005"

	local fig_note "Each panel: DiD event-study estimate of `inten_lbl' effect by ENIGH wave." ///
	    " 1996 = reference (omitted, 0 by construction). Red dashed line: PROGRESA rollout." ///
	    " Bars = 95% CI. SE clustered by municipality. Weighted by expansion factor." ///
	    " Sample: highly marginalized municipalities (GM 4-5)."

	foreach tbl in T1 T2 T3 T4 {

		* T1 is individual-level; T2–T4 restrict to unique HH observations
		local hh_cond = cond("`tbl'" == "T1", "", "hh_unique == 1 & ")

		local k = 0
		local gph_list ""

		foreach outcome in ${`tbl'} {

			local ++k
			local lb = "`lbl_`tbl'_`k''"

			*--------------------------------------------------------------
			* 4a. Event study regression
			*--------------------------------------------------------------
			cap noisily reghdfe `outcome' ib1996.year#c.`inten' ///
				[pweight = exp_factor] ///
				if `hh_cond'`outcome'_out == 0 & $sample_marg, ///
				a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

			if _rc != 0 {
				di as error "  *** reghdfe failed for `outcome' (`inten') in `tbl' — skipping"
				continue
			}

			*--------------------------------------------------------------
			* 4b. Extract estimates into a 9-row plotting dataset
			*     Rows: 1992 1994 1996(ref=0) 1998 2000 2002 2004 2005 2006
			*     _b[] / _se[] scalars survive the preserve/clear/restore
			*--------------------------------------------------------------
			preserve
			clear
			set obs 9

			gen yr_pos = _n    // 1–9
			gen yr_val = .     // calendar year (for reference)
			gen b      = .
			gen hi95   = .
			gen lo95   = .

			* pre-treatment years
			local pos = 1
			foreach yr in 1992 1994 {
				replace yr_val = `yr'                                                       if yr_pos == `pos'
				replace b      =  _b[`yr'.year#c.`inten']                                  if yr_pos == `pos'
				replace hi95   =  _b[`yr'.year#c.`inten'] + 1.96 * _se[`yr'.year#c.`inten'] if yr_pos == `pos'
				replace lo95   =  _b[`yr'.year#c.`inten'] - 1.96 * _se[`yr'.year#c.`inten'] if yr_pos == `pos'
				local ++pos
			}

			* reference year 1996 — zero by construction
			replace yr_val = 1996 if yr_pos == 3
			replace b      = 0    if yr_pos == 3
			replace hi95   = 0    if yr_pos == 3
			replace lo95   = 0    if yr_pos == 3

			* post-treatment years
			local pos = 4
			foreach yr in 1998 2000 2002 2004 2005 2006 {
				replace yr_val = `yr'                                                       if yr_pos == `pos'
				replace b      =  _b[`yr'.year#c.`inten']                                  if yr_pos == `pos'
				replace hi95   =  _b[`yr'.year#c.`inten'] + 1.96 * _se[`yr'.year#c.`inten'] if yr_pos == `pos'
				replace lo95   =  _b[`yr'.year#c.`inten'] - 1.96 * _se[`yr'.year#c.`inten'] if yr_pos == `pos'
				local ++pos
			}

			*--------------------------------------------------------------
			* 4c. Panel graph
			*--------------------------------------------------------------
			twoway ///
				(rcap hi95 lo95 yr_pos, lcolor(gs9) lwidth(thin)) ///
				(connected b yr_pos, ///
					mcolor(navy) lcolor(navy%60) ///
					msymbol(circle) msize(small) lwidth(thin)), ///
				yline(0, lcolor(black) lpattern(solid) lwidth(vthin)) ///
				xline(3.5, lcolor(red) lpattern(dash) lwidth(vthin)) ///
				xlabel(1 "1992" 2 "1994" 3 "1996" 4 "1998" 5 "2000" ///
				       6 "2002" 7 "2004" 8 "2005" 9 "2006", ///
				       labsize(tiny) angle(45) grid gmax) ///
				xscale(range(0.5 9.5)) ///
				xtitle("") ytitle("") ///
				title("`lb'", size(small) color(black) margin(b=1)) ///
				legend(off) ///
				graphregion(color(white)) plotregion(margin(l=0 r=0)) ///
				saving("$data/es_panel_`tbl'_`inten'_`k'.gph", replace)

			restore

			local gph_list `"`gph_list' "$data/es_panel_`tbl'_`inten'_`k'.gph""'

		} // end foreach outcome

		*------------------------------------------------------------------
		* 4d. Combine panels into one figure per table group × intensity
		*------------------------------------------------------------------
		local n_panels = `k'
		local n_cols   = min(`n_panels', 4)
		local n_rows   = ceil(`n_panels' / `n_cols')

		graph combine `gph_list', ///
			rows(`n_rows') cols(`n_cols') ///
			title("Event Study (`inten_lbl') — `title_`tbl''", ///
			      size(medsmall) color(black)) ///
			note(`fig_note', size(tiny)) ///
			graphregion(color(white)) ///
			saving("$output/F_ES_`tbl'_`inten'.gph", replace)

		graph export "$output/F_ES_`tbl'_`inten'.pdf", replace
		graph export "$output/F_ES_`tbl'_`inten'.png", replace width(2400)

		di as result "  => Saved F_ES_`tbl'_`inten'.pdf / .png"

		* clean up temporary panel gph files
		forval k_del = 1/`n_panels' {
			cap erase "$data/es_panel_`tbl'_`inten'_`k_del'.gph"
		}

	} // end foreach tbl

} // end foreach inten

di as result _n "Done. Twelve event-study figures (4 tables x 3 intensities) saved to: $output"
