/*===========================================================================
  04_migration_robustness.do

  Robustness check: Does Progresa intensity predict differential changes
  in the size of the elderly (65+) population at the municipality level
  RELATIVE TO the 50-64 population in the same municipality?

  The main regression dataset (aamr_regression_municipality_gender_tb.dta)
  contains annually interpolated population series by 5-year age group
  (geometric interpolation between census years 1990/1995/2000/2005):
      pop5054_  pop5559_  pop6064_   (control age groups: 50-64)
      pop6569_  pop7074_  popover70_ (treated age groups: 65+)
      popover65_, popover75_ = popover70_ - pop7074_

  Panel A — Total 65+ DiD (municipality × year panel)
    Outcome: popover65_ (levels, logs, Poisson)
    Identification: Intensity_1999 × Post within municipality and year FE

  Panel B — Triple-difference (DDD) on age x year x intensity
    Stacks 6 five-year age groups: 50-54, 55-59, 60-64, 65-69, 70-74, 75+
    Old65_a = 1 if age group is 65+, 0 if 50-64
    Specification:
        pop_{m,t,a} = beta · (Intensity_1999 × Post × Old65)
                    + Mun×Year FE + Mun×Age FE + Year×Age FE + e
    Mun×Year FE absorbs overall municipality-year population growth
      (the Intensity × Post variation in levels);
    Mun×Age FE absorbs municipality-specific age composition;
    Year×Age FE absorbs national age-cohort trends.
    The triple interaction identifies whether the 65+ population grew
    differentially relative to 50-64 in municipalities with higher
    Progresa intensity, post versus pre. A negative coefficient would
    indicate selective elderly out-migration.

  Both panels run:
    Short-run  (1992–2002): Intensity_1999 × Post (× Old65)
    Long-run   (1991–2006): Intensity_1999 × Post (× Old65)
                          + Intensity_2005 × Post (× Old65)

  Outputs:
    tables/appendix/AT_migration_robustness.tex        (Panel A: DiD)
    tables/appendix/AT_migration_robustness_ageFE.tex  (Panel B: DDD)
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
*  PANEL B — Triple-difference (DDD): age (50-64 vs 65+) × post × intensity
*  Stacks 6 five-year age groups using annually interpolated population
*  series. The Old65 indicator separates "treated" age cells (65+) from
*  the within-municipality control group (50-64). With Mun×Year, Mun×Age,
*  and Year×Age FE absorbed, identification rests on differential pop
*  growth across age groups within municipality-year.
*===========================================================================

use "$data/aamr_regression_municipality_gender_tb.dta", clear
keep if year >= 1991 & year <= 2006

*--- Construct 75+ and stack 6 five-year age groups -------------------------
keep cve_ent_mun_super year gm_mun_1990 inten1999 inten2005 post ///
     pop5054_ pop5559_ pop6064_ pop6569_ pop7074_ popover70_

gen popover75_ = popover70_ - pop7074_
drop popover70_

rename pop5054_   pop1      // age group 1: 50-54  (control)
rename pop5559_   pop2      // age group 2: 55-59  (control)
rename pop6064_   pop3      // age group 3: 60-64  (control)
rename pop6569_   pop4      // age group 4: 65-69  (treated)
rename pop7074_   pop5      // age group 5: 70-74  (treated)
rename popover75_ pop6      // age group 6: 75+    (treated)

reshape long pop, i(cve_ent_mun_super year) j(age_grp)

label define age_grp_lbl 1 "50-54" 2 "55-59" 3 "60-64" 4 "65-69" 5 "70-74" 6 "75+"
label values age_grp age_grp_lbl
lab var pop "Population count by 5-year age group"

gen old65 = (age_grp >= 4)
lab var old65 "Age group 65+ (1) vs 50-64 (0)"
lab def old65_lbl 0 "50-64 (control)" 1 "65+ (treated)"
lab val old65 old65_lbl

gen ln_pop = ln(pop)
lab var ln_pop "log population count by age group"

*--- Short-run DDD (1992–2002) ----------------------------------------------
preserve
keep if year >= 1992 & year <= 2002

* (B1) OLS — levels: triple interaction with saturated 2-way FEs
reghdfe pop c.inten1999#i.post#i.old65 if ($sample_marg), ///
	a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
	vce(cluster cve_ent_mun_super)
eststo pb_sr1

* (B2) OLS — logs
reghdfe ln_pop c.inten1999#i.post#i.old65 if ($sample_marg), ///
	a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
	vce(cluster cve_ent_mun_super)
eststo pb_sr2

* (B3) Poisson PML
ppmlhdfe pop c.inten1999#i.post#i.old65 if ($sample_marg), ///
	a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
	vce(cluster cve_ent_mun_super)
eststo pb_sr3
restore

*--- Long-run DDD (1991–2006) -----------------------------------------------
* (B4) OLS — levels
reghdfe pop c.inten1999#i.post#i.old65 c.inten2005#i.post#i.old65 if ($sample_marg), ///
	a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
	vce(cluster cve_ent_mun_super)
eststo pb_lr1

* (B5) OLS — logs
reghdfe ln_pop c.inten1999#i.post#i.old65 c.inten2005#i.post#i.old65 if ($sample_marg), ///
	a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
	vce(cluster cve_ent_mun_super)
eststo pb_lr2

* (B6) Poisson PML
ppmlhdfe pop c.inten1999#i.post#i.old65 c.inten2005#i.post#i.old65 if ($sample_marg), ///
	a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
	vce(cluster cve_ent_mun_super)
eststo pb_lr3


*===========================================================================
*  EXPORT — Panel A and Panel B as separate .tex files
*===========================================================================

local coef_labels_a  ///
	1.post#c.inten1999 "\$Intensity_{1999} \times Post\$" ///
	1.post#c.inten2005 "\$Intensity_{2005} \times Post\$"

local coef_labels_b  ///
	1.post#1.old65#c.inten1999 "\$Intensity_{1999} \times Post \times Old65\$" ///
	1.post#1.old65#c.inten2005 "\$Intensity_{2005} \times Post \times Old65\$"

local stat_labels  ///
	N       "Observations"  ///
	N_clust "Municipalities"

*--- Panel A (DiD) ----------------------------------------------------------
esttab pa_sr1 pa_sr2 pa_sr3 pa_lr1 pa_lr2 pa_lr3 ///
	using "$tables/appendix/AT_migration_robustness.tex", ///
	replace booktabs compress label nomtitles ///
	b(%12.3f) se(%12.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	keep(1.post#c.inten1999 1.post#c.inten2005) ///
	coeflabels(`coef_labels_a') ///
	mgroups("Short-run (1992--2002)" "Long-run (1991--2006)", ///
		pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	mtitles("OLS" "OLS (log)" "Poisson" "OLS" "OLS (log)" "Poisson") ///
	stats(N N_clust, fmt(%9.0f %9.0f) labels(`stat_labels')) ///
	prehead("\multicolumn{7}{l}{\textit{Panel A: Total 65+ population, DiD (Mun + Year FE)}} \\") ///
	postfoot("")

*--- Panel B (DDD) ----------------------------------------------------------
esttab pb_sr1 pb_sr2 pb_sr3 pb_lr1 pb_lr2 pb_lr3 ///
	using "$tables/appendix/AT_migration_robustness_ageFE.tex", ///
	replace booktabs compress label nomtitles ///
	b(%12.3f) se(%12.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	keep(1.post#1.old65#c.inten1999 1.post#1.old65#c.inten2005) ///
	coeflabels(`coef_labels_b') ///
	mgroups("Short-run (1992--2002)" "Long-run (1991--2006)", ///
		pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
	mtitles("OLS" "OLS (log)" "Poisson" "OLS" "OLS (log)" "Poisson") ///
	stats(N N_clust, fmt(%9.0f %9.0f) labels(`stat_labels')) ///
	prehead("\addlinespace \multicolumn{7}{l}{\textit{Panel B: Triple-difference (DDD), 65+ vs 50--64, with Mun$\times$Year, Mun$\times$Age, Year$\times$Age FE}} \\") ///
	postfoot("")
