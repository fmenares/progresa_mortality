/*==============================================================================
 05_diet_financial_enigh.do

 Tables for diet quality and financial stress outcomes using 1997 PROGRESA
 intensity.  Follows the same DiD structure as T1–T4 in 03_mechanisms_enigh.do
 (Panel A weighted / Panel B unweighted; year + mun FE; cluster SE: mun).

 Outcomes — new variables created at the end of 01_enigh_data.do:

   Diet quality (T5_diet_enigh_1997.tex)
     protein_share    share of food spending on meat & dairy
     staples_share    share on cereals
     vegg_fruit_share share on vegetables & fruit
     unhealthy_share  share on sugar/fat/drinks + alcohol + tobacco
     diversity_index  count of non-zero food categories (0–7)

   Financial stress (T6_financial_enigh_1997.tex)
     net_fin_position savings minus debt service (real 2025 USD)
     debt_to_income   debt / HH labor earnings (positive earnings only)
     health_share     health spending / total HH expenditure
     rx_to_visit_ratio Rx drug spending / outpatient spending
     otc_to_rx_ratio  OTC / Rx drug spending

 Sample: highly marginalized municipalities (gm_mun_1990 == 4 | 5)
 Unit:   household (hh_unique == 1)
 Period: 1992–2006
==============================================================================*/

clear
set more off
capture log close
set seed 1234

if c(username) == "felip" {
	global data    "C:\Users\felip\Dropbox\2024\70ymas\data/"
	global tables  "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global figures "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/figures/"
}

if c(username) == "fmenares" {
	global data    "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global tables  "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global figures "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/figures/"
}

if c(username) == "FELIPEME" {
	global data    "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global tables  "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables"
	global figures "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\figures"
}

/*----------------------------------------------------------------------------
 Load and prepare
----------------------------------------------------------------------------*/
use "$data/enigh_panel", clear

merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", ///
	keep(1 3) nogen

destring cve_ent cve_mun, replace
format cve_ent %02.0f
format cve_mun %03.0f
gen cve_mun2 = string(cve_ent, "%02.0f") + string(cve_mun, "%03.0f")
replace cve_mun2 = cve_ent_mun_super if cve_ent_mun_super != ""
drop cve_ent_mun_super
rename cve_mun2 cve_ent_mun_super
sort cve_ent_mun_super

merge m:1 cve_ent_mun_super year using "$data/mortality_muni.dta", keep(3)

gen post = .
	replace post = 2 if year < 1997 & year > 1990 & year != .
	replace post = 1 if year >= 1997 & year < 2007 & year != .
	lab def post 1 "1997-2006" 2 "1991-1996"
	lab val post post

global sample_marg = "(gm_mun_1990 == 4 | gm_mun_1990 == 5)"
global years = "1992 1994 1996 1998 2000 2002 2004 2005 2006"

/*----------------------------------------------------------------------------
 Outlier flags

 Share / bounded variables (0–1) and diversity_index (0–7) have no meaningful
 upper-tail outliers → _out = 0.
 Right-skewed ratios and the net financial position are trimmed at p99 by year.
----------------------------------------------------------------------------*/

* bounded [0,1] or small integers: no trimming needed
foreach v in protein_share staples_share vegg_fruit_share unhealthy_share ///
             diversity_index health_share {
	gen `v'_out = 0
}

* right-skewed or unbounded: p99 trimming by year
foreach v in net_fin_position debt_to_income rx_to_visit_ratio otc_to_rx_ratio {
	gen `v'_out = .
	foreach y in $years {
		sum `v' if year == `y' & $sample_marg, d
		replace `v'_out = (`v' > `r(p99)') if year == `y'
	}
}

/*============================================================================
 TABLE 5 — Diet Quality
 Outcomes: protein_share staples_share vegg_fruit_share unhealthy_share
           diversity_index
============================================================================*/
global hh_diet = ///
	"protein_share staples_share vegg_fruit_share unhealthy_share diversity_index"

local i = 1

foreach outcome in $hh_diet {

	* weighted
	reghdfe `outcome' c.inten1997#i.post [pweight = exp_factor] if ///
		hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
		a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_w97_`i'_aux : di %12.3f _b[1.post#c.inten1997]
	local SE_w97_`i'       : di %12.3f _se[1.post#c.inten1997]
	local t_`i' = abs(_b[1.post#c.inten1997] / _se[1.post#c.inten1997])

	if (`t_`i'' >= 2.576)                  local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575)  local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.959) local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"
	else                                   local OLS_w97_`i' = "`OLS_w97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.3fc `r(mean)'
	local N_w`i'        : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i'      : di %12.0fc `r(ndistinct)'

	* unweighted
	reghdfe `outcome' c.inten1997#i.post if ///
		hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
		a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_uw97_`i'_aux : di %12.3f _b[1.post#c.inten1997]
	local SE_uw97_`i'       : di %12.3f _se[1.post#c.inten1997]
	local t_`i' = abs(_b[1.post#c.inten1997] / _se[1.post#c.inten1997])

	if (`t_`i'' >= 2.576)                  local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575)  local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.959) local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"
	else                                   local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.3fc `r(mean)'
	local N_uw`i'        : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)

	local ++i
}

{
	cap file close sm
	file open sm using "$tables/T5_diet_enigh_1997.tex", write replace
	file write sm "\begin{tabular}{lccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Protein Share} & \multicolumn{1}{c}{Staples Share} & \multicolumn{1}{c}{Vegg \& Fruit Share} & \multicolumn{1}{c}{Unhealthy Share} & \multicolumn{1}{c}{Diet Diversity}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Weighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_w97_1' & `OLS_w97_2' & `OLS_w97_3' & `OLS_w97_4' & `OLS_w97_5' \\  "_n
	file write sm "& (`SE_w97_1') & (`SE_w97_2') & (`SE_w97_3') & (`SE_w97_4') & (`SE_w97_5') \\ "_n
	file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') \\ "_n
	file write sm " & & & & & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' \\  "_n
	file write sm " & & & & & \\ "_n
	file write sm "Year FE & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun Controls & N & N & N & N & N  \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

/*============================================================================
 TABLE 6 — Financial Stress
 Outcomes: net_fin_position debt_to_income health_share
           rx_to_visit_ratio otc_to_rx_ratio
============================================================================*/
global hh_financial = ///
	"net_fin_position debt_to_income health_share rx_to_visit_ratio otc_to_rx_ratio"

local i = 1

foreach outcome in $hh_financial {

	* weighted
	reghdfe `outcome' c.inten1997#i.post [pweight = exp_factor] if ///
		hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
		a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_w97_`i'_aux : di %12.3f _b[1.post#c.inten1997]
	local SE_w97_`i'       : di %12.3f _se[1.post#c.inten1997]
	local t_`i' = abs(_b[1.post#c.inten1997] / _se[1.post#c.inten1997])

	if (`t_`i'' >= 2.576)                  local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575)  local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.959) local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"
	else                                   local OLS_w97_`i' = "`OLS_w97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.3fc `r(mean)'
	local N_w`i'        : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i'      : di %12.0fc `r(ndistinct)'

	* unweighted
	reghdfe `outcome' c.inten1997#i.post if ///
		hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
		a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_uw97_`i'_aux : di %12.3f _b[1.post#c.inten1997]
	local SE_uw97_`i'       : di %12.3f _se[1.post#c.inten1997]
	local t_`i' = abs(_b[1.post#c.inten1997] / _se[1.post#c.inten1997])

	if (`t_`i'' >= 2.576)                  local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575)  local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.959) local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"
	else                                   local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.3fc `r(mean)'
	local N_uw`i'        : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)

	local ++i
}

{
	cap file close sm
	file open sm using "$tables/T6_financial_enigh_1997.tex", write replace
	file write sm "\begin{tabular}{lccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Net Financial Position} & \multicolumn{1}{c}{Debt-to-Income} & \multicolumn{1}{c}{Health Share} & \multicolumn{1}{c}{Rx per Visit \$} & \multicolumn{1}{c}{OTC-to-Rx Ratio}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Weighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_w97_1' & `OLS_w97_2' & `OLS_w97_3' & `OLS_w97_4' & `OLS_w97_5' \\  "_n
	file write sm "& (`SE_w97_1') & (`SE_w97_2') & (`SE_w97_3') & (`SE_w97_4') & (`SE_w97_5') \\ "_n
	file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') \\ "_n
	file write sm " & & & & & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' \\  "_n
	file write sm " & & & & & \\ "_n
	file write sm "Year FE & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun Controls & N & N & N & N & N  \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

/*============================================================================
 EVENT STUDIES — Figures ES5 (diet quality) and ES6 (financial stress)

 Specification:
   areg outcome c.inten1997##ib1996.year [pweight=exp_factor] if ...,
        absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels

 ENIGH survey years: 1992 1994 1996 1998 2000 2002 2004 2005 2006
 Base year (ib1996): last pre-program ENIGH wave → position 3 in coefplot.
 xline(3) marks the omitted reference year; vertical line = treatment onset.
============================================================================*/

foreach outcome in $hh_diet $hh_financial {

	local lbl : variable label `outcome'

	areg `outcome' c.inten1997##ib1996.year [pweight = exp_factor] if ///
		hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
		absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels

	coefplot, drop(*.year _cons inten1997) omitted base vertical             ///
		coeflabels(, interaction("") wrap(6))                                ///
		yline(0, lpattern(dash))                                             ///
		xline(3, lpattern(dash) lcolor(gray))                                ///
		graphregion(fcolor(white))                                           ///
		xtitle("Year × PROGRESA Intensity 1997")                             ///
		ytitle("`lbl'")                                                      ///
		ciopts(lwidth(1.15) lcolor(*.5))                                     ///
		xlabel(, labsize(small)) ylabel(, labsize(small))

	graph export "$figures/ES_`outcome'_1997.pdf", as(pdf) replace
}

di as result _n "Done. Saved:"
di as result "  $tables/T5_diet_enigh_1997.tex"
di as result "  $tables/T6_financial_enigh_1997.tex"
di as result "  $figures/ES_<outcome>_1997.pdf  (10 figures)"
