/*===========================================================================
  04_migration_robustness.do

  Robustness check: Does Progresa intensity predict changes in the size
  of the elderly population (65+) at the municipality level?

  If Progresa caused differential elderly out-migration, we expect a
  negative effect on elderly population counts in high-intensity
  municipalities. A null result supports the parallel-trends assumption.

  The main regression dataset (aamr_regression_municipality_gender_tb.dta)
  already contains annually interpolated population series by 5-year age
  group (geometric interpolation between census years 1990/1995/2000/2005):
      pop6569_     pop7074_     popover70_   (both sexes)
      popover65_   (total 65+, both sexes)

  Panel A — Total 65+, no age-group FE (municipality × year panel)
    Outcome: popover65_ (levels, logs, Poisson)

  Panel B — Stacked by age group (65-69, 70-74, 75+), with age-group FE
    Reshape to municipality × year × age-group (65-69, 70-74, 75+)
    popover75_ = popover70_ - pop7074_
    Outcome: age-group count (levels, logs, Poisson)
    FEs: municipality + year + age-group

  Both panels run:
    Short-run  (1992–2002): Intensity_1999 × Post
    Long-run   (1991–2006): Intensity_1999 × Post + Intensity_2005 × Post

  Outputs:
    tables/appendix/AT_migration_robustness.tex        (Panel A)
    tables/appendix/AT_migration_robustness_ageFE.tex  (Panel B)
===========================================================================*/

*--- 0. Paths ---------------------------------------------------------------
if "`c(username)'" == "FELIPEME" {
	global data   "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global tables "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\tables"
}
else {
	global data   "/home/user/progresa_mortality/data/"
	global tables "/home/user/progresa_mortality/tables"
}

global sample_marg "gm_mun_1990==4|gm_mun_1990==5"

*===========================================================================
*  PANEL A — Total 65+ (no age-group FE)
*===========================================================================

use "$data/aamr_regression_municipality_gender_tb.dta", clear
keep if year >= 1991 & year <= 2006

gen ln_popover65 = ln(popover65_)
lab var popover65_   "Population 65+ (count)"
lab var ln_popover65 "log Population 65+"

eststo clear

*--- Short-run (1992–2002) --------------------------------------------------
preserve
keep if year >= 1992 & year <= 2002

* (A1) OLS — levels
reghdfe popover65_ c.inten1999#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo pa_sr1

* (A2) OLS — logs
reghdfe ln_popover65 c.inten1999#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo pa_sr2

* (A3) Poisson PML
ppmlhdfe popover65_ c.inten1999#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo pa_sr3
restore

*--- Long-run (1991–2006) ---------------------------------------------------
* (A4) OLS — levels
reghdfe popover65_ c.inten1999#i.post c.inten2005#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo pa_lr1

* (A5) OLS — logs
reghdfe ln_popover65 c.inten1999#i.post c.inten2005#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo pa_lr2

* (A6) Poisson PML
ppmlhdfe popover65_ c.inten1999#i.post c.inten2005#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
eststo pa_lr3


*===========================================================================
*  PANEL B — Stacked by age group (65-69, 70-74, 75+), with age-group FE
*  Uses annually interpolated pop6569_, pop7074_, popover70_ from the same
*  dataset. popover75_ = popover70_ - pop7074_
*===========================================================================

use "$data/aamr_regression_municipality_gender_tb.dta", clear
keep if year >= 1991 & year <= 2006

*--- Construct 75+ and reshape to long by age group -------------------------
keep cve_ent_mun_super year gm_mun_1990 inten1999 inten2005 post ///
     pop6569_ pop7074_ popover70_ inten_start_year

gen popover75_ = popover70_ - pop7074_

rename pop6569_   pop1      // age group 1: 65-69
rename pop7074_   pop2      // age group 2: 70-74
rename popover75_ pop3      // age group 3: 75+

drop popover70_

reshape long pop, i(cve_ent_mun_super year) j(age_grp)

label define age_grp_lbl 1 "65-69" 2 "70-74" 3 "75+"
label values age_grp age_grp_lbl
lab var pop "Population count by age group"

gen ln_pop = ln(pop)
lab var ln_pop "log population count by age group"

*--- Short-run (1992–2002) --------------------------------------------------
preserve
keep if year >= 1992 & year <= 2002

* (B1) OLS — levels
reghdfe pop c.inten1999#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super age_grp) vce(cluster cve_ent_mun_super)
eststo pb_sr1

* (B2) OLS — logs
reghdfe ln_pop c.inten1999#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super age_grp) vce(cluster cve_ent_mun_super)
eststo pb_sr2

* (B3) Poisson PML
ppmlhdfe pop c.inten1999#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super age_grp) vce(cluster cve_ent_mun_super)
eststo pb_sr3
restore

*--- Long-run (1991–2006) ---------------------------------------------------
* (B4) OLS — levels
reghdfe pop c.inten1999#i.post c.inten2005#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super age_grp) vce(cluster cve_ent_mun_super)
eststo pb_lr1

* (B5) OLS — logs
reghdfe ln_pop c.inten1999#i.post c.inten2005#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super age_grp) vce(cluster cve_ent_mun_super)
eststo pb_lr2

* (B6) Poisson PML
ppmlhdfe pop c.inten1999#i.post c.inten2005#i.post if ($sample_marg), ///
	a(year cve_ent_mun_super age_grp) vce(cluster cve_ent_mun_super)
eststo pb_lr3


*===========================================================================
*  EXPORT — Panel A and Panel B as separate .tex files
*===========================================================================

local coef_labels  ///
	1.post#c.inten1999 "\$Intensity_{1999} \times Post\$" ///
	1.post#c.inten2005 "\$Intensity_{2005} \times Post\$"

local stat_labels  ///
	N       "Observations"  ///
	N_clust "Municipalities"

*--- Panel A ----------------------------------------------------------------
esttab pa_sr1 pa_sr2 pa_sr3 pa_lr1 pa_lr2 pa_lr3 ///
	using "$tables/appendix/AT_migration_robustness.tex", ///
	replace booktabs compress label nomtitles ///
	b(%12.3f) se(%12.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	keep(1.post#c.inten1999 1.post#c.inten2005) ///
	coeflabels(`coef_labels') ///
	mgroups("Short-run (1992--2002)" "Long-run (1991--2006)", ///
		pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	mtitles("OLS" "OLS (log)" "Poisson" "OLS" "OLS (log)" "Poisson") ///
	stats(N N_clust, fmt(%9.0f %9.0f) labels(`stat_labels')) ///
	prehead("\multicolumn{7}{l}{\textit{Panel A: Total 65+ population (no age-group FE)}} \\") ///
	postfoot("")

*--- Panel B ----------------------------------------------------------------
esttab pb_sr1 pb_sr2 pb_sr3 pb_lr1 pb_lr2 pb_lr3 ///
	using "$tables/appendix/AT_migration_robustness_ageFE.tex", ///
	replace booktabs compress label nomtitles ///
	b(%12.3f) se(%12.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	keep(1.post#c.inten1999 1.post#c.inten2005) ///
	coeflabels(`coef_labels') ///
	nomtitles ///
	stats(N N_clust, fmt(%9.0f %9.0f) labels(`stat_labels')) ///
	prehead("\addlinespace \multicolumn{7}{l}{\textit{Panel B: Stacked by age group (65--69, 70--74, 75+) with age-group FE}} \\") ///
	postfoot("")
