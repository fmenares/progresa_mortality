/*===========================================================================
  04_migration_robustness.do

  Robustness check: Does Progresa intensity predict changes in the size
  of the elderly population (65+) at the municipality level?

  If Progresa caused differential elderly out-migration from high-intensity
  municipalities, we should observe a negative effect on elderly population
  counts. A null result supports the parallel-trends assumption in the main
  mortality analysis.

  Specifications:
    Panel A — Short-run (HM sample, 1992–2002, inten1999 × Post)
    Panel B — Long-run  (HM sample, 1991–2006, inten1999 × Post + inten2005 × Post)

  Outcomes (3 columns each panel):
    (1) OLS — population counts (levels)
    (2) OLS — log population counts
    (3) Poisson PML — population counts

  Extended specification with age-group fixed effects uses a stacked
  municipality × year × age-group dataset built from census-year files.

  Outputs: tables/appendix/AT_migration_robustness.tex
===========================================================================*/

*--- 0. Paths ---------------------------------------------------------------
if "`c(username)'" == "FELIPEME" {
	global data    "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global tables  "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\tables"
}
else {
	global data    "/home/user/progresa_mortality/data/"
	global tables  "/home/user/progresa_mortality/tables"
}

global sample_marg "gm_mun_1990==4|gm_mun_1990==5"
global sample_br   "(inten_start_year==1998|inten_start_year==1999)"

*--- 1. Load main regression dataset ----------------------------------------
use "$data/aamr_regression_municipality_gender_tb.dta", clear

*--- Keep analysis window ---------------------------------------------------
keep if year >= 1991 & year <= 2006

*--- Generate log population ------------------------------------------------
gen ln_popover65 = ln(popover65_)
lab var popover65_   "Population 65+ (count)"
lab var ln_popover65 "log Population 65+"

*===========================================================================
*  PART A — WITHOUT AGE-GROUP FIXED EFFECTS
*  Uses total popover65_ from the main panel dataset
*===========================================================================

eststo clear

*--- Panel A: Short-run (1992–2002, HM sample) -----------------------------
foreach outcome in popover65_ ln_popover65 {
	qui {
		keep if year >= 1992 & year <= 2002

		* (1) OLS — counts or logs
		reghdfe `outcome' c.inten1999#i.post ///
			if ($sample_marg), ///
			a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		eststo sr_ols_`outcome'
	}
	use "$data/aamr_regression_municipality_gender_tb.dta", clear
	keep if year >= 1991 & year <= 2006
	gen ln_popover65 = ln(popover65_)
}

* (1)/(2) OLS — counts and logs, short-run
foreach outcome in popover65_ ln_popover65 {
	use "$data/aamr_regression_municipality_gender_tb.dta", clear
	keep if year >= 1992 & year <= 2002
	gen ln_popover65 = ln(popover65_)
	reghdfe `outcome' c.inten1999#i.post ///
		if ($sample_marg), ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	if "`outcome'" == "popover65_"   eststo sr_a1
	if "`outcome'" == "ln_popover65" eststo sr_a2
}

* (3) Poisson, short-run
use "$data/aamr_regression_municipality_gender_tb.dta", clear
keep if year >= 1992 & year <= 2002
ppmlhdfe popover65_ c.inten1999#i.post ///
	if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo sr_a3

*--- Panel B: Long-run (1991–2006, HM sample) -------------------------------
foreach outcome in popover65_ ln_popover65 {
	use "$data/aamr_regression_municipality_gender_tb.dta", clear
	keep if year >= 1991 & year <= 2006
	gen ln_popover65 = ln(popover65_)
	reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post ///
		if ($sample_marg), ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	if "`outcome'" == "popover65_"   eststo lr_a1
	if "`outcome'" == "ln_popover65" eststo lr_a2
}

* Poisson, long-run
use "$data/aamr_regression_municipality_gender_tb.dta", clear
keep if year >= 1991 & year <= 2006
ppmlhdfe popover65_ c.inten1999#i.post c.inten2005#i.post ///
	if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo lr_a3

*--- Export Panel A (no age-group FE) ----------------------------------------
esttab sr_a1 sr_a2 sr_a3 lr_a1 lr_a2 lr_a3 ///
	using "$tables/appendix/AT_migration_robustness.tex", ///
	replace booktabs compress label nomtitles ///
	b(%12.3f) se(%12.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	keep(1.post#c.inten1999 1.post#c.inten2005) ///
	coeflabels(1.post#c.inten1999 "\$Intensity_{1999} \times Post\$" ///
	           1.post#c.inten2005 "\$Intensity_{2005} \times Post\$") ///
	mgroups("Short-run (1992--2002)" "Long-run (1991--2006)", ///
		pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	mtitles("OLS (Count)" "OLS (Log)" "Poisson" ///
	        "OLS (Count)" "OLS (Log)" "Poisson") ///
	stats(N N_clust, fmt(%9.0f %9.0f) ///
	      labels("Observations" "Municipalities")) ///
	addnotes("Notes: see table note in paper")


*===========================================================================
*  PART B — WITH AGE-GROUP FIXED EFFECTS
*  Stacks census-year data (1990, 1995, 2000, 2005) by 5-year age group.
*  Age groups: 65-69, 70-74, 75-79, 80+
*  Identification: differential changes in age-group-specific population
*  counts across municipalities with different Progresa intensity.
*===========================================================================

/*
  NOTE: This section requires the intermediate age-group census files
  saved by aamr_011326.do:
      "$Data/Work_SR/Temp_data/pop_age_1990_mun.dta"
      "$Data/Work_SR/Temp_data/pop_age_1995_mun.dta"
      "$Data/Work_SR/Temp_data/pop_age_2000_mun.dta"
      "$Data/Work_SR/Temp_data/pop_age_2005_mun.dta"
  Each file has variables: cve_ent_mun_super, age_65_69_both,
  age_70_74_both, age_75_79_both, age_80_84_both, age_85m_both
  (and _male, _female variants).
*/

*--- Merge and reshape census-year age-group data ---------------------------
local censusyears "1990 1995 2000 2005"

use "$data/Work_SR/Temp_data/pop_age_1990_mun.dta", clear
gen year = 1990
foreach yr in 1995 2000 2005 {
	append using "$data/Work_SR/Temp_data/pop_age_`yr'_mun.dta"
	replace year = `yr' if year == .
}

*--- Rename to consistent stub for reshape ----------------------------------
foreach ag in 65_69 70_74 75_79 80_84 {
	cap rename age_`ag'_both pop`ag'_
}
*  85+ may be labelled differently across census years — harmonise:
foreach v of varlist age_85* {
	cap rename `v' pop85p_
}
* Post-2000 files use age_75_100_both — create a consistent 75-79 and 80+:
cap rename age_75_100_both pop75p_   // if present, treat as 75+
cap rename age_100m_both   pop100p_  // ignore — absorbed into pop75p_

*--- Reshape to long by age group -------------------------------------------
reshape long pop, i(cve_ent_mun_super year) j(age_grp) string
drop if pop == . | pop < 0

*--- Age-group identifier ---------------------------------------------------
encode age_grp, gen(age_grp_id)

*--- Merge program variables ------------------------------------------------
merge m:1 cve_ent_mun_super using "$data/Work_SR/Temp_data/inten1999.dta", ///
	keep(match) nogen
merge m:1 cve_ent_mun_super using "$data/Work_SR/Temp_data/inten2005.dta", ///
	keep(match) nogen
merge m:1 cve_ent_mun_super using "$data/inten_start_year.dta", ///
	keep(match) nogen   // contains inten_start_year and gm_mun_1990

*--- Post-1997 dummy (census years: pre=1990,1995; post=2000,2005) ----------
gen post = (year >= 2000)

*--- Generate log pop -------------------------------------------------------
gen ln_pop = ln(pop)

*--- Regressions with age-group FE ------------------------------------------
eststo clear

* Short-run census window: 1990, 1995, 2000 (closest to 1992–2002)
foreach outcome in pop ln_pop {
	reghdfe `outcome' c.inten1999#i.post ///
		if ($sample_marg) & year <= 2000, ///
		a(year cve_ent_mun_super age_grp_id) vce(cluster cve_ent_mun_super)
	if "`outcome'" == "pop"    eststo sr_b1
	if "`outcome'" == "ln_pop" eststo sr_b2
}
ppmlhdfe pop c.inten1999#i.post ///
	if ($sample_marg) & year <= 2000, ///
	a(year cve_ent_mun_super age_grp_id) vce(cluster cve_ent_mun_super)
eststo sr_b3

* Long-run: all four census years (1990, 1995, 2000, 2005)
foreach outcome in pop ln_pop {
	reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post ///
		if ($sample_marg), ///
		a(year cve_ent_mun_super age_grp_id) vce(cluster cve_ent_mun_super)
	if "`outcome'" == "pop"    eststo lr_b1
	if "`outcome'" == "ln_pop" eststo lr_b2
}
ppmlhdfe pop c.inten1999#i.post c.inten2005#i.post ///
	if ($sample_marg), ///
	a(year cve_ent_mun_super age_grp_id) vce(cluster cve_ent_mun_super)
eststo lr_b3

*--- Export Panel B (with age-group FE) --------------------------------------
esttab sr_b1 sr_b2 sr_b3 lr_b1 lr_b2 lr_b3 ///
	using "$tables/appendix/AT_migration_robustness_ageFE.tex", ///
	replace booktabs compress label nomtitles ///
	b(%12.3f) se(%12.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	keep(1.post#c.inten1999 1.post#c.inten2005) ///
	coeflabels(1.post#c.inten1999 "\$Intensity_{1999} \times Post\$" ///
	           1.post#c.inten2005 "\$Intensity_{2005} \times Post\$") ///
	mgroups("Short-run (census years 1990--2000)" ///
	        "Long-run (census years 1990--2005)", ///
		pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	mtitles("OLS (Count)" "OLS (Log)" "Poisson" ///
	        "OLS (Count)" "OLS (Log)" "Poisson") ///
	stats(N N_clust, fmt(%9.0f %9.0f) ///
	      labels("Observations" "Municipalities")) ///
	addnotes("Notes: see table note in paper")
