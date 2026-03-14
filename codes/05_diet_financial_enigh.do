/*==============================================================================
 05_diet_financial_enigh.do

 Diet quality and financial stress tables using 1997 PROGRESA intensity.
 Produces:
   T5_diet_enigh_1997.tex    — 8 food-quality outcomes (hh-level)
   T6_financial_enigh_1997.tex — 4 financial-stress outcomes (hh-level)

 Specification (preferred): c.inten1997 # i.post
   Panel A: survey-weighted (pweight=exp_factor)
   Panel B: unweighted
   Absorb: year + cve_ent_mun_super FE
   Cluster SE: municipality
   Sample: highly marginalized municipalities (gm_mun_1990 == 4 | 5)
   Unit: household (hh_unique == 1)
==============================================================================*/

clear
set more off
capture log close
set seed 1234

if c(username) == "felip" {
	global data    "C:\Users\felip\Dropbox\2024\70ymas\data/"
	global tables  "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
}

if c(username) == "fmenares" {
	global data    "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global tables  "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
}

if c(username) == "FELIPEME" {
	global data    "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global tables  "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables"
}

/*----------------------------------------------------------------------------
 Load and prepare data
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

/*----------------------------------------------------------------------------
 Outlier flags

 The following already have _out flags built from the global raw_outcomes loop
 in 03_mechanisms_enigh.do (p99 winsorisation by year):
   vegg_fruit, cereals, meat_dairy, sugar_fat_drink
   savings, debt, loans, currency

 These are set to 0 in 03_mechanisms_enigh.do:
   alcohol_out = 0, tobacco_out = 0

 New flags needed for this file:
   coffe_spices_other, outside_food
----------------------------------------------------------------------------*/
global years = "1992 1994 1996 1998 2000 2002 2004 2005 2006"

foreach outcome in coffe_spices_other outside_food {
	gen `outcome'_out = .
	foreach year in $years {
		sum `outcome' if year == `year' & $sample_marg, d
		replace `outcome'_out = (`outcome' > `r(p99)') if year == `year'
	}
}

* outlier flags for variables already covered in 03 (recreate if file is run
* standalone, harmless if they already exist)
foreach outcome in vegg_fruit cereals meat_dairy sugar_fat_drink ///
                   food_exp savings debt loans currency {
	capture gen `outcome'_out = .
	foreach year in $years {
		sum `outcome' if year == `year' & $sample_marg, d
		replace `outcome'_out = (`outcome' > `r(p99)') if year == `year'
	}
}

capture gen alcohol_out  = 0
capture gen tobacco_out  = 0
capture gen vice_out     = 0

/*============================================================================
 TABLE 5 — Diet Quality
 Outcomes: vegg_fruit cereals meat_dairy sugar_fat_drink
           coffe_spices_other outside_food alcohol tobacco
============================================================================*/
global hh_diet = ///
	"vegg_fruit cereals meat_dairy sugar_fat_drink coffe_spices_other outside_food alcohol tobacco"

local i = 1

foreach outcome in $hh_diet {

	* weighted
	reghdfe `outcome' c.inten1997#i.post [pweight = exp_factor] if ///
		hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
		a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_w97_`i'_aux : di %12.3f _b[1.post#c.inten1997]
	local SE_w97_`i'       : di %12.3f _se[1.post#c.inten1997]
	local t_`i' = abs(_b[1.post#c.inten1997] / _se[1.post#c.inten1997])

	if (`t_`i'' >= 2.576)              local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575) local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.96) local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"
	else                               local OLS_w97_`i' = "`OLS_w97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
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

	if (`t_`i'' >= 2.576)              local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575) local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.96) local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"
	else                               local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	local N_uw`i'        : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)

	local ++i
}

{
	cap file close sm
	file open sm using "$tables/T5_diet_enigh_1997.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Vegg \& Fruit} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat \& Dairy} & \multicolumn{1}{c}{Sugar \& Fat} & \multicolumn{1}{c}{Coffee \& Spices} & \multicolumn{1}{c}{Outside Food} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Weighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_w97_1' & `OLS_w97_2' & `OLS_w97_3' & `OLS_w97_4' & `OLS_w97_5' & `OLS_w97_6' & `OLS_w97_7' & `OLS_w97_8'\\  "_n
	file write sm "& (`SE_w97_1') & (`SE_w97_2') & (`SE_w97_3') & (`SE_w97_4') & (`SE_w97_5') & (`SE_w97_6') & (`SE_w97_7') & (`SE_w97_8') \\ "_n
	file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
	file write sm " & & & & & & & & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8' \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm " & & & & & & & & \\ "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N  \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

/*============================================================================
 TABLE 6 — Financial Stress
 Outcomes: savings debt loans currency
============================================================================*/
global hh_financial = "savings debt loans currency"

local i = 1

foreach outcome in $hh_financial {

	* weighted
	reghdfe `outcome' c.inten1997#i.post [pweight = exp_factor] if ///
		hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
		a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_w97_`i'_aux : di %12.3f _b[1.post#c.inten1997]
	local SE_w97_`i'       : di %12.3f _se[1.post#c.inten1997]
	local t_`i' = abs(_b[1.post#c.inten1997] / _se[1.post#c.inten1997])

	if (`t_`i'' >= 2.576)              local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575) local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.96) local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"
	else                               local OLS_w97_`i' = "`OLS_w97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
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

	if (`t_`i'' >= 2.576)              local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"
	else if inrange(`t_`i'', 1.96, 2.575) local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"
	else if inrange(`t_`i'', 1.645, 1.96) local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"
	else                               local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	local N_uw`i'        : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)

	local ++i
}

{
	cap file close sm
	file open sm using "$tables/T6_financial_enigh_1997.tex", write replace
	file write sm "\begin{tabular}{lcccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Loans to Others} & \multicolumn{1}{c}{Currency}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}"_n
	file write sm "& (1) & (2) & (3) & (4) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Weighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_w97_1' & `OLS_w97_2' & `OLS_w97_3' & `OLS_w97_4'\\  "_n
	file write sm "& (`SE_w97_1') & (`SE_w97_2') & (`SE_w97_3') & (`SE_w97_4') \\ "_n
	file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') \\ "_n
	file write sm " & & & & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' \\  "_n
	file write sm " & & & & \\ "_n
	file write sm "Year FE & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y  \\ "_n
	file write sm "Mun Controls & N & N & N & N  \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

di as result _n "Done. Saved:"
di as result "  $tables/T5_diet_enigh_1997.tex"
di as result "  $tables/T6_financial_enigh_1997.tex"
