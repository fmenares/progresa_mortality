clear
set more off
capture log close
set seed 1234

if c(username)=="felip" {
    
	global deaths "C:\Users\felip\Dropbox\R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "C:\Users\felip\Dropbox\2024\70ymas\data/"
	
	global output "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global iter "C:\Users\felip\Dropbox\R01_MHAS\Progresa_Locality_Mortality_Project\CensusData_ITER\" 
	global SP "C:\Users\felip\Dropbox\R01_MHAS\SocialProgramBeneficiaries"
}

if c(username)=="fmenares" {
    global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global output  "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}

if c(username)=="FELIPEME" {
    global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global tables "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\tables"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}


use "$data/enigh_panel", clear

merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", keep(1 3) nogen
*keeping only those that change municipalities between 1990 and 2018, and those who did not.
destring cve_ent cve_mun, replace
format cve_ent %02.0f
format cve_mun %03.0f
gen cve_mun2=string(cve_ent,"%02.0f") + string(cve_mun,"%03.0f")
replace cve_mun2=cve_ent_mun_super if cve_ent_mun_super!=""
drop cve_ent_mun_super
rename cve_mun2 cve_ent_mun_super
sort cve_ent_mun_super 

merge m:1 cve_ent_mun_super year using "$data/mortality_muni.dta", keep(3)
*keeping only highly marginalized municipalities that are present in the ENIGH

global sample_marg = "gm_mun_1990==4|gm_mun_1990==5"

*table year, stat(mean benef_don_non_gob_ind) stat(mean benef_don_gob_ind) stat(mean progresa_ind) stat(mean progresa_hh)
table year if _merge == 3 & $sample_marg, ///
stat(mean benef_don_non_gob_ind) stat(mean benef_don_gob_ind) stat(mean progresa_ind) stat(mean progresa_hh)
*the self report variable does not identify any older adult given that the transfer ask for the school benefits
*table year progresa_benef_hh if _merge == 3, stat(mean benef_don_non_gob_ind) stat(mean benef_don_gob_ind) stat(mean progresa_ind) stat(mean progresa_hh)


gen post=.
	replace post=2 if year <1998 & year >1990 & year!=.
	replace post=1 if year >=1998 & year <2007 & year!=.
		lab def post 1"1998-2006" 2"1992-1997"
	lab val post post

	
g hrs_worked_pos = hrs_worked if hrs_worked !=. & hrs_worked!=0
egen vice = rsum(alcohol tobacco)
egen medical = rsum(medical_inpatient medical_outpatient)


global years = "1992 1994 1996 1998 2000 2002 2004 2005 2006"
global raw_outcomes = "ind_earnings ind_income_tot hh_income_tot hh_earnings benef_gob_ind benef_gob_hh hh_expenditure food_exp cereals meat_dairy sugar_fat_drink vegg_fruit health_exp health_med medical drugs savings debt currency loans"

*maybe I have to restrict outlier to my sample of interest
foreach outcome in $raw_outcomes {
	g `outcome'_out = .
	foreach year in $years {			
		 sum `outcome' if year == `year' & $sample_marg, d    
		replace `outcome'_out = (`outcome' >`r(p99)') if year == `year'    
		
	}
}

*some variables does not have an outlier
replace benef_gob_ind_out = ind_earnings_out
g progresa_ind_out = ind_earnings_out
*replace ind_income_tot_out = ind_earnings_out
g hrs_worked_out = 0
g hrs_worked_pos_out = 0
g employed_out = ind_earnings_out


*hh income outliers variable
replace benef_gob_hh_out = hh_earnings_out 
g progresa_hh_out = hh_earnings_out 
g n_hh_out = hh_earnings_out 
*replace hh_income_tot_out = hh_earnings_out 


g alcohol_out = 0
g tobacco_out = 0
g vice_out = 0

g medical_inpatient_out = medical_out
g medical_outpatient_out = medical_out
g drugs_prescribed_out = drugs_out
g drugs_overcounter_out = drugs_out
g ortho_out = 0



g ln_hh_income_tot = log(hh_income_tot)
g ln_hh_expenditure = log(hh_expenditure)


/*************************************
PREPROCESSING FOR STANDARDIZATION
Calculate intensity statistics and create z-scored versions
*************************************/
* Calculate mean and SD of intensity variables (pre-period 1992-1996)
sum inten1998 if inrange(year, 1992, 1996)
local inten1998_mean = r(mean)
local inten1998_sd = r(sd)

sum inten2000 if inrange(year, 1992, 1996)
local inten2000_mean = r(mean)
local inten2000_sd = r(sd)

* Create z-scored intensity variables
gen inten1998_z = (inten1998 - `inten1998_mean') / `inten1998_sd'
gen inten2000_z = (inten2000 - `inten2000_mean') / `inten2000_sd'

* Store intensity stats as string macros for use in coefficient transformations
local inten1998_mean_str : di %12.4f `inten1998_mean'
local inten2000_mean_str : di %12.4f `inten2000_mean'


/*************************************
1. Set of 4 Tables: short-run effects (1998) - All Municipalities
2.1 Using 1998 intensity interacted with post
2.2 1992-1998
2.3 All municipalities (not restricted to highly marginalized)
*************************************/
{
*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {

	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & inrange(year, 1992, 1998), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate different standardization versions
	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	* Format raw coefficient with significance
	local OLS_w98_`i'_aux: di %12.3f  `coef_raw'
	local SE_w98_`i' : di %12.3f  `se_raw'

	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'**"
	}


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'"
	}

	* Format standardized versions
	local OLS_w98_z_`i'_aux: di %12.3f  `coef_zscore'
	local OLS_w98_pct_`i'_aux: di %12.3f  `coef_pct'
	local OLS_w98_marg_`i'_aux: di %12.3f  `coef_marg'

	* Apply significance stars to standardized versions (using same t-stat)
	if (`t_`i'' >= 2.576) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'***"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'***"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'**"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'**"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'*"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'*"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'

	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}


* --- Female ---
local i = 1
foreach outcome in $individuals {

	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & inrange(year, 1992, 1998) & female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardization versions
	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	* Format raw coefficient with significance
	local OLS_f98_`i'_aux: di %12.3f  `coef_raw'
	local SE_f98_`i' : di %12.3f  `se_raw'

	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'**"
	}


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'"
	}

	* Format standardized versions
	local OLS_f98_z_`i'_aux: di %12.3f  `coef_zscore'
	local OLS_f98_pct_`i'_aux: di %12.3f  `coef_pct'
	local OLS_f98_marg_`i'_aux: di %12.3f  `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'***"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'***"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'**"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'**"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'*"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'*"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'

	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}


* --- Male ---
local i = 1
foreach outcome in $individuals {

	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & inrange(year, 1992, 1998) & female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardization versions
	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	* Format raw coefficient with significance
	local OLS_m98_`i'_aux: di %12.3f  `coef_raw'
	local SE_m98_`i' : di %12.3f  `se_raw'

	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'**"
	}


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'"
	}

	* Format standardized versions
	local OLS_m98_z_`i'_aux: di %12.3f  `coef_zscore'
	local OLS_m98_pct_`i'_aux: di %12.3f  `coef_pct'
	local OLS_m98_marg_`i'_aux: di %12.3f  `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'***"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'***"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'**"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'**"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'*"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'*"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'

	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}

{

			cap file close sm
		file open sm using "$tables/1998/T1_ind_enigh_1992_1998_all.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_1'  & `OLS_w98_2' & `OLS_w98_3' & `OLS_w98_4' & `OLS_w98_5' & `OLS_w98_6' & `OLS_w98_7'\\  "_n
		file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_1'  & `OLS_f98_2' & `OLS_f98_3' & `OLS_f98_4' & `OLS_f98_5' & `OLS_f98_6' & `OLS_f98_7'\\  "_n
		file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_1'  & `OLS_m98_2' & `OLS_m98_3' & `OLS_m98_4' & `OLS_m98_5' & `OLS_m98_6' & `OLS_m98_7'\\  "_n
		file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
		file write sm "&  &  &  & &  &  &  & & 	  \\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n	
		file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\  "_n
		*file write sm "Weight & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		*file write sm "Year x Age Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Locality Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Age x Locality Eligible FE & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}


{
	cap file close sm
	file open sm using "$tables/1998/T1_ind_enigh_1992_1998_all_z.tex", write replace
	file write sm "\begin{tabular}{lccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_z_1'  & `OLS_w98_z_2' & `OLS_w98_z_3' & `OLS_w98_z_4' & `OLS_w98_z_5' & `OLS_w98_z_6' & `OLS_w98_z_7'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_z_1'  & `OLS_f98_z_2' & `OLS_f98_z_3' & `OLS_f98_z_4' & `OLS_f98_z_5' & `OLS_f98_z_6' & `OLS_f98_z_7'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_z_1'  & `OLS_m98_z_2' & `OLS_m98_z_3' & `OLS_m98_z_4' & `OLS_m98_z_5' & `OLS_m98_z_6' & `OLS_m98_z_7'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T1_ind_enigh_1992_1998_all_pct.tex", write replace
	file write sm "\begin{tabular}{lccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_pct_1'  & `OLS_w98_pct_2' & `OLS_w98_pct_3' & `OLS_w98_pct_4' & `OLS_w98_pct_5' & `OLS_w98_pct_6' & `OLS_w98_pct_7'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_pct_1'  & `OLS_f98_pct_2' & `OLS_f98_pct_3' & `OLS_f98_pct_4' & `OLS_f98_pct_5' & `OLS_f98_pct_6' & `OLS_f98_pct_7'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_pct_1'  & `OLS_m98_pct_2' & `OLS_m98_pct_3' & `OLS_m98_pct_4' & `OLS_m98_pct_5' & `OLS_m98_pct_6' & `OLS_m98_pct_7'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T1_ind_enigh_1992_1998_all_marg.tex", write replace
	file write sm "\begin{tabular}{lccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_marg_1'  & `OLS_w98_marg_2' & `OLS_w98_marg_3' & `OLS_w98_marg_4' & `OLS_w98_marg_5' & `OLS_w98_marg_6' & `OLS_w98_marg_7'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_marg_1'  & `OLS_f98_marg_2' & `OLS_f98_marg_3' & `OLS_f98_marg_4' & `OLS_f98_marg_5' & `OLS_f98_marg_6' & `OLS_f98_marg_7'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_marg_1'  & `OLS_m98_marg_2' & `OLS_m98_marg_3' & `OLS_m98_marg_4' & `OLS_m98_marg_5' & `OLS_m98_marg_6' & `OLS_m98_marg_7'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7')\\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\ "_n
	file write sm " &  & &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
foreach outcome in $hh {

	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardization versions
	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	* Format raw coefficient with significance
	local OLS_w98_`i'_aux: di %12.3f  `coef_raw'
	local SE_w98_`i' : di %12.3f  `se_raw'

	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'**"
	}


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w98_`i' = "`OLS_w98_`i'_aux'"
	}

	* Format standardized versions
	local OLS_w98_z_`i'_aux: di %12.3f  `coef_zscore'
	local OLS_w98_pct_`i'_aux: di %12.3f  `coef_pct'
	local OLS_w98_marg_`i'_aux: di %12.3f  `coef_marg'

	* Apply significance stars to standardized versions (using same t-stat)
	if (`t_`i'' >= 2.576) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'***"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'***"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'**"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'**"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'*"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'*"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'

	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}


* --- Female ---
local i = 1
foreach outcome in $hh {

	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998) & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardization versions
	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	* Format raw coefficient with significance
	local OLS_f98_`i'_aux: di %12.3f  `coef_raw'
	local SE_f98_`i' : di %12.3f  `se_raw'

	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'**"
	}


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f98_`i' = "`OLS_f98_`i'_aux'"
	}

	* Format standardized versions
	local OLS_f98_z_`i'_aux: di %12.3f  `coef_zscore'
	local OLS_f98_pct_`i'_aux: di %12.3f  `coef_pct'
	local OLS_f98_marg_`i'_aux: di %12.3f  `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'***"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'***"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'**"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'**"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'*"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'*"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'"
	}


	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	*increment on i 
    local ++i
	
}


* --- Male ---
local i = 1
foreach outcome in $hh {

	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998) & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardization versions
	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	* Format raw coefficient with significance
	local OLS_m98_`i'_aux: di %12.3f  `coef_raw'
	local SE_m98_`i' : di %12.3f  `se_raw'

	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'**"
	}


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m98_`i' = "`OLS_m98_`i'_aux'"
	}

	* Format standardized versions
	local OLS_m98_z_`i'_aux: di %12.3f  `coef_zscore'
	local OLS_m98_pct_`i'_aux: di %12.3f  `coef_pct'
	local OLS_m98_marg_`i'_aux: di %12.3f  `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'***"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'***"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'**"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'**"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'*"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'*"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'

	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}

{

			cap file close sm
		file open sm using "$tables/1998/T2_hh_enigh_1992_1998_all.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_1'  & `OLS_w98_2' & `OLS_w98_3' & `OLS_w98_4' & `OLS_w98_5' & `OLS_w98_6' & `OLS_w98_7' & `OLS_w98_8'\\  "_n
		file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_1'  & `OLS_f98_2' & `OLS_f98_3' & `OLS_f98_4' & `OLS_f98_5' & `OLS_f98_6' & `OLS_f98_7' & `OLS_f98_8'\\  "_n
		file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_1'  & `OLS_m98_2' & `OLS_m98_3' & `OLS_m98_4' & `OLS_m98_5' & `OLS_m98_6' & `OLS_m98_7' & `OLS_m98_8'\\  "_n
		file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
		file write sm "&  &  &  & &  &  &  & & &	  \\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n	
		file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
		*file write sm "Weight & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Age Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Locality Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Age x Locality Eligible FE & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}
		
{
	cap file close sm
	file open sm using "$tables/1998/T2_hh_enigh_1992_1998_all_z", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_z_1'  & `OLS_w98_z_2' & `OLS_w98_z_3' & `OLS_w98_z_4' & `OLS_w98_z_5' & `OLS_w98_z_6' & `OLS_w98_z_7' & `OLS_w98_z_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_z_1'  & `OLS_f98_z_2' & `OLS_f98_z_3' & `OLS_f98_z_4' & `OLS_f98_z_5' & `OLS_f98_z_6' & `OLS_f98_z_7' & `OLS_f98_z_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_z_1'  & `OLS_m98_z_2' & `OLS_m98_z_3' & `OLS_m98_z_4' & `OLS_m98_z_5' & `OLS_m98_z_6' & `OLS_m98_z_7' & `OLS_m98_z_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T2_hh_enigh_1992_1998_all_pct.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_pct_1'  & `OLS_w98_pct_2' & `OLS_w98_pct_3' & `OLS_w98_pct_4' & `OLS_w98_pct_5' & `OLS_w98_pct_6' & `OLS_w98_pct_7' & `OLS_w98_pct_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_pct_1'  & `OLS_f98_pct_2' & `OLS_f98_pct_3' & `OLS_f98_pct_4' & `OLS_f98_pct_5' & `OLS_f98_pct_6' & `OLS_f98_pct_7' & `OLS_f98_pct_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_pct_1'  & `OLS_m98_pct_2' & `OLS_m98_pct_3' & `OLS_m98_pct_4' & `OLS_m98_pct_5' & `OLS_m98_pct_6' & `OLS_m98_pct_7' & `OLS_m98_pct_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T2_hh_enigh_1992_1998_all_marg.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_marg_1'  & `OLS_w98_marg_2' & `OLS_w98_marg_3' & `OLS_w98_marg_4' & `OLS_w98_marg_5' & `OLS_w98_marg_6' & `OLS_w98_marg_7' & `OLS_w98_marg_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_marg_1'  & `OLS_f98_marg_2' & `OLS_f98_marg_3' & `OLS_f98_marg_4' & `OLS_f98_marg_5' & `OLS_f98_marg_6' & `OLS_f98_marg_7' & `OLS_f98_marg_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_marg_1'  & `OLS_m98_marg_2' & `OLS_m98_marg_3' & `OLS_m98_marg_4' & `OLS_m98_marg_5' & `OLS_m98_marg_6' & `OLS_m98_marg_7' & `OLS_m98_marg_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	local OLS_w98_`i'_aux: di %12.3f  `coef_raw'
	local SE_w98_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)           local OLS_w98_`i' = "`OLS_w98_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_w98_`i' = "`OLS_w98_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_w98_`i' = "`OLS_w98_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_w98_`i' = "`OLS_w98_`i'_aux'"

	local OLS_w98_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_w98_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_w98_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'***"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'***"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'**"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'**"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'*"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'*"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}


* --- Female ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998) & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	local OLS_f98_`i'_aux: di %12.3f  `coef_raw'
	local SE_f98_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_f98_`i' = "`OLS_f98_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_f98_`i' = "`OLS_f98_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_f98_`i' = "`OLS_f98_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_f98_`i' = "`OLS_f98_`i'_aux'"

	local OLS_f98_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_f98_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_f98_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'***"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'***"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'**"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'**"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'*"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'*"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}


* --- Male ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998) & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	local OLS_m98_`i'_aux: di %12.3f  `coef_raw'
	local SE_m98_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_m98_`i' = "`OLS_m98_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_m98_`i' = "`OLS_m98_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_m98_`i' = "`OLS_m98_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_m98_`i' = "`OLS_m98_`i'_aux'"

	local OLS_m98_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_m98_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_m98_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'***"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'***"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'**"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'**"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'*"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'*"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}

{		
		
	cap file close sm
		file open sm using "$tables/1998/T3_food_enigh_1992_1998_all.tex", write replace
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_1'  & `OLS_w98_2' & `OLS_w98_3' & `OLS_w98_4' & `OLS_w98_5'  & `OLS_w98_6' & `OLS_w98_7' & `OLS_w98_8'\\  "_n
		file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_1'  & `OLS_f98_2' & `OLS_f98_3' & `OLS_f98_4' & `OLS_f98_5'  & `OLS_f98_6' & `OLS_f98_7' & `OLS_f98_8'\\  "_n
		file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_1'  & `OLS_m98_2' & `OLS_m98_3' & `OLS_m98_4' & `OLS_m98_5'  & `OLS_m98_6' & `OLS_m98_7' & `OLS_m98_8'\\  "_n
		file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T3_food_enigh_1992_1998_all_z", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_z_1'  & `OLS_w98_z_2' & `OLS_w98_z_3' & `OLS_w98_z_4' & `OLS_w98_z_5'  & `OLS_w98_z_6' & `OLS_w98_z_7' & `OLS_w98_z_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_z_1'  & `OLS_f98_z_2' & `OLS_f98_z_3' & `OLS_f98_z_4' & `OLS_f98_z_5'  & `OLS_f98_z_6' & `OLS_f98_z_7' & `OLS_f98_z_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_z_1'  & `OLS_m98_z_2' & `OLS_m98_z_3' & `OLS_m98_z_4' & `OLS_m98_z_5'  & `OLS_m98_z_6' & `OLS_m98_z_7' & `OLS_m98_z_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T3_food_enigh_1992_1998_all_pct.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_pct_1'  & `OLS_w98_pct_2' & `OLS_w98_pct_3' & `OLS_w98_pct_4' & `OLS_w98_pct_5'  & `OLS_w98_pct_6' & `OLS_w98_pct_7' & `OLS_w98_pct_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_pct_1'  & `OLS_f98_pct_2' & `OLS_f98_pct_3' & `OLS_f98_pct_4' & `OLS_f98_pct_5'  & `OLS_f98_pct_6' & `OLS_f98_pct_7' & `OLS_f98_pct_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_pct_1'  & `OLS_m98_pct_2' & `OLS_m98_pct_3' & `OLS_m98_pct_4' & `OLS_m98_pct_5'  & `OLS_m98_pct_6' & `OLS_m98_pct_7' & `OLS_m98_pct_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T3_food_enigh_1992_1998_all_marg.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_marg_1'  & `OLS_w98_marg_2' & `OLS_w98_marg_3' & `OLS_w98_marg_4' & `OLS_w98_marg_5'  & `OLS_w98_marg_6' & `OLS_w98_marg_7' & `OLS_w98_marg_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_marg_1'  & `OLS_f98_marg_2' & `OLS_f98_marg_3' & `OLS_f98_marg_4' & `OLS_f98_marg_5'  & `OLS_f98_marg_6' & `OLS_f98_marg_7' & `OLS_f98_marg_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_marg_1'  & `OLS_m98_marg_2' & `OLS_m98_marg_3' & `OLS_m98_marg_4' & `OLS_m98_marg_5'  & `OLS_m98_marg_6' & `OLS_m98_marg_7' & `OLS_m98_marg_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	local OLS_w98_`i'_aux: di %12.3f  `coef_raw'
	local SE_w98_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_w98_`i' = "`OLS_w98_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_w98_`i' = "`OLS_w98_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_w98_`i' = "`OLS_w98_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_w98_`i' = "`OLS_w98_`i'_aux'"

	local OLS_w98_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_w98_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_w98_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'***"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'***"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'**"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'**"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'*"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'*"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_w98_z_`i' = "`OLS_w98_z_`i'_aux'"
		local OLS_w98_pct_`i' = "`OLS_w98_pct_`i'_aux'"
		local OLS_w98_marg_`i' = "`OLS_w98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}


* --- Female ---
local i = 1
foreach outcome in $hh_health{

	*weighted
	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998) & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	local OLS_f98_`i'_aux: di %12.3f  `coef_raw'
	local SE_f98_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_f98_`i' = "`OLS_f98_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_f98_`i' = "`OLS_f98_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_f98_`i' = "`OLS_f98_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_f98_`i' = "`OLS_f98_`i'_aux'"

	local OLS_f98_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_f98_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_f98_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'***"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'***"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'**"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'**"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'*"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'*"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_f98_z_`i' = "`OLS_f98_z_`i'_aux'"
		local OLS_f98_pct_`i' = "`OLS_f98_pct_`i'_aux'"
		local OLS_f98_marg_`i' = "`OLS_f98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}


* --- Male ---
local i = 1
foreach outcome in $hh_health{

	*weighted
	reghdfe `outcome' c.inten1998#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 1998) & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten1998]
	local se_raw = _se[1.post#c.inten1998]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten1998_sd'
	local coef_pct = (`coef_raw' * `inten1998_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten1998_mean'

	local OLS_m98_`i'_aux: di %12.3f  `coef_raw'
	local SE_m98_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_m98_`i' = "`OLS_m98_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_m98_`i' = "`OLS_m98_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_m98_`i' = "`OLS_m98_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_m98_`i' = "`OLS_m98_`i'_aux'"

	local OLS_m98_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_m98_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_m98_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'***"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'***"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'**"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'**"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'*"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'*"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_m98_z_`i' = "`OLS_m98_z_`i'_aux'"
		local OLS_m98_pct_`i' = "`OLS_m98_pct_`i'_aux'"
		local OLS_m98_marg_`i' = "`OLS_m98_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}

	{
	cap file close sm
		file open sm using "$tables/1998/T4_health_enigh_1992_1998_all.tex", write replace

		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_1'  & `OLS_w98_2' & `OLS_w98_3' & `OLS_w98_4' & `OLS_w98_5'  & `OLS_w98_6' & `OLS_w98_7' & `OLS_w98_8'\\  "_n
		file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_1'  & `OLS_f98_2' & `OLS_f98_3' & `OLS_f98_4' & `OLS_f98_5'  & `OLS_f98_6' & `OLS_f98_7' & `OLS_f98_8'\\  "_n
		file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_1'  & `OLS_m98_2' & `OLS_m98_3' & `OLS_m98_4' & `OLS_m98_5'  & `OLS_m98_6' & `OLS_m98_7' & `OLS_m98_8'\\  "_n
		file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
		file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "Mun Controls & N  & N & N & N & N  & N & N & N     \\  "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T4_health_enigh_1992_1998_all_z", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_z_1'  & `OLS_w98_z_2' & `OLS_w98_z_3' & `OLS_w98_z_4' & `OLS_w98_z_5'  & `OLS_w98_z_6' & `OLS_w98_z_7' & `OLS_w98_z_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_z_1'  & `OLS_f98_z_2' & `OLS_f98_z_3' & `OLS_f98_z_4' & `OLS_f98_z_5'  & `OLS_f98_z_6' & `OLS_f98_z_7' & `OLS_f98_z_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_z_1'  & `OLS_m98_z_2' & `OLS_m98_z_3' & `OLS_m98_z_4' & `OLS_m98_z_5'  & `OLS_m98_z_6' & `OLS_m98_z_7' & `OLS_m98_z_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T4_health_enigh_1992_1998_all_pct.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_pct_1'  & `OLS_w98_pct_2' & `OLS_w98_pct_3' & `OLS_w98_pct_4' & `OLS_w98_pct_5'  & `OLS_w98_pct_6' & `OLS_w98_pct_7' & `OLS_w98_pct_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_pct_1'  & `OLS_f98_pct_2' & `OLS_f98_pct_3' & `OLS_f98_pct_4' & `OLS_f98_pct_5'  & `OLS_f98_pct_6' & `OLS_f98_pct_7' & `OLS_f98_pct_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_pct_1'  & `OLS_m98_pct_2' & `OLS_m98_pct_3' & `OLS_m98_pct_4' & `OLS_m98_pct_5'  & `OLS_m98_pct_6' & `OLS_m98_pct_7' & `OLS_m98_pct_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

{
	cap file close sm
	file open sm using "$tables/1998/T4_health_enigh_1992_1998_all_marg.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_w98_marg_1'  & `OLS_w98_marg_2' & `OLS_w98_marg_3' & `OLS_w98_marg_4' & `OLS_w98_marg_5'  & `OLS_w98_marg_6' & `OLS_w98_marg_7' & `OLS_w98_marg_8'\\  "_n
	file write sm "& (`SE_w98_1')  & (`SE_w98_2') & (`SE_w98_3') & (`SE_w98_4') & (`SE_w98_5')  & (`SE_w98_6') & (`SE_w98_7') & (`SE_w98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_f98_marg_1'  & `OLS_f98_marg_2' & `OLS_f98_marg_3' & `OLS_f98_marg_4' & `OLS_f98_marg_5'  & `OLS_f98_marg_6' & `OLS_f98_marg_7' & `OLS_f98_marg_8'\\  "_n
	file write sm "& (`SE_f98_1')  & (`SE_f98_2') & (`SE_f98_3') & (`SE_f98_4') & (`SE_f98_5')  & (`SE_f98_6') & (`SE_f98_7') & (`SE_f98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
	file write sm "\textit{Intensity 1998 x post (1998)} & `OLS_m98_marg_1'  & `OLS_m98_marg_2' & `OLS_m98_marg_3' & `OLS_m98_marg_4' & `OLS_m98_marg_5'  & `OLS_m98_marg_6' & `OLS_m98_marg_7' & `OLS_m98_marg_8'\\  "_n
	file write sm "& (`SE_m98_1')  & (`SE_m98_2') & (`SE_m98_3') & (`SE_m98_4') & (`SE_m98_5')  & (`SE_m98_6') & (`SE_m98_7') & (`SE_m98_8')\\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
	file write sm "Avg Intensity & `inten1998_mean_str'  & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str' & `inten1998_mean_str'& `inten1998_mean_str' & `inten1998_mean_str'  \\  "_n
	file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
	file write sm " &  & &  &  &  &  &  & \\ "_n
	file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}
}



/*************************************
1. Set of 4 Tables: short-run effects (2000) - All Municipalities
2.1 Using 2000 intensity interacted with post
2.2 1992-2000
2.3 All municipalities (not restricted to highly marginalized)
*************************************/
{
*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {

	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	local OLS_w00_`i'_aux: di %12.3f  `coef_raw'
	local SE_w00_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_w00_`i' = "`OLS_w00_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_w00_`i' = "`OLS_w00_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_w00_`i' = "`OLS_w00_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_w00_`i' = "`OLS_w00_`i'_aux'"

	local OLS_w00_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_w00_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_w00_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'***"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'***"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'**"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'**"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'*"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'*"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}


* --- Female ---
local i = 1
foreach outcome in $individuals {

	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	local OLS_f00_`i'_aux: di %12.3f  `coef_raw'
	local SE_f00_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_f00_`i' = "`OLS_f00_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_f00_`i' = "`OLS_f00_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_f00_`i' = "`OLS_f00_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_f00_`i' = "`OLS_f00_`i'_aux'"

	local OLS_f00_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_f00_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_f00_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'***"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'***"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'**"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'**"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'*"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'*"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}


* --- Male ---
local i = 1
foreach outcome in $individuals {

	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	local mean_outcome = .
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	local OLS_m00_`i'_aux: di %12.3f  `coef_raw'
	local SE_m00_`i' : di %12.3f  `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576)            local OLS_m00_`i' = "`OLS_m00_`i'_aux'***"
	if inrange(`t_`i'', 1.96, 2.575) local OLS_m00_`i' = "`OLS_m00_`i'_aux'**"
	if inrange(`t_`i'', 1.645, 1.96) local OLS_m00_`i' = "`OLS_m00_`i'_aux'*"
	if (`t_`i'' < 1.645)             local OLS_m00_`i' = "`OLS_m00_`i'_aux'"

	local OLS_m00_z_`i'_aux:    di %12.3f `coef_zscore'
	local OLS_m00_pct_`i'_aux:  di %12.3f `coef_pct'
	local OLS_m00_marg_`i'_aux: di %12.3f `coef_marg'

	if (`t_`i'' >= 2.576) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'***"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'***"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'***"
	}
	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'**"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'**"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'**"
	}
	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'*"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'*"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'*"
	}
	if (`t_`i'' < 1.645) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'"
	}

	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'
    local ++i
}

{

			cap file close sm
		file open sm using "$tables/2000/T1_ind_enigh_1992_2000_all.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_1'  & `OLS_w00_2' & `OLS_w00_3' & `OLS_w00_4' & `OLS_w00_5' & `OLS_w00_6' & `OLS_w00_7'\\  "_n
		file write sm "& (`SE_w00_1')  & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5')  & (`SE_w00_6') & (`SE_w00_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_1'  & `OLS_f00_2' & `OLS_f00_3' & `OLS_f00_4' & `OLS_f00_5' & `OLS_f00_6' & `OLS_f00_7'\\  "_n
		file write sm "& (`SE_f00_1')  & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5')  & (`SE_f00_6') & (`SE_f00_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_1'  & `OLS_m00_2' & `OLS_m00_3' & `OLS_m00_4' & `OLS_m00_5' & `OLS_m00_6' & `OLS_m00_7'\\  "_n
		file write sm "& (`SE_m00_1')  & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5')  & (`SE_m00_6') & (`SE_m00_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
		file write sm "&  &  &  & &  &  &  & & 	  \\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n	
		file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\  "_n
		*file write sm "Weight & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		*file write sm "Year x Age Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Locality Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Age x Locality Eligible FE & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}

{
	cap file close sm
	file open sm using "$tables/2000/T1_ind_enigh_1992_2000_all_z.tex", write replace
	file write sm "\begin{tabular}{lccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_z_1' & `OLS_w00_z_2' & `OLS_w00_z_3' & `OLS_w00_z_4' & `OLS_w00_z_5' & `OLS_w00_z_6' & `OLS_w00_z_7'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1' & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6' & `mean_dep_w7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1' & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_z_1' & `OLS_f00_z_2' & `OLS_f00_z_3' & `OLS_f00_z_4' & `OLS_f00_z_5' & `OLS_f00_z_6' & `OLS_f00_z_7'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1' & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6' & `mean_dep_f7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1' & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_z_1' & `OLS_m00_z_2' & `OLS_m00_z_3' & `OLS_m00_z_4' & `OLS_m00_z_5' & `OLS_m00_z_6' & `OLS_m00_z_7'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1' & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6' & `mean_dep_m7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1' & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Note: Coefficients show effect per 1 SD increase in intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T1_ind_enigh_1992_2000_all_pct.tex", write replace
	file write sm "\begin{tabular}{lccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_pct_1' & `OLS_w00_pct_2' & `OLS_w00_pct_3' & `OLS_w00_pct_4' & `OLS_w00_pct_5' & `OLS_w00_pct_6' & `OLS_w00_pct_7'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1' & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6' & `mean_dep_w7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1' & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_pct_1' & `OLS_f00_pct_2' & `OLS_f00_pct_3' & `OLS_f00_pct_4' & `OLS_f00_pct_5' & `OLS_f00_pct_6' & `OLS_f00_pct_7'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1' & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6' & `mean_dep_f7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1' & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_pct_1' & `OLS_m00_pct_2' & `OLS_m00_pct_3' & `OLS_m00_pct_4' & `OLS_m00_pct_5' & `OLS_m00_pct_6' & `OLS_m00_pct_7'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1' & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6' & `mean_dep_m7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1' & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Note: Coefficients show percentage effect at mean intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T1_ind_enigh_1992_2000_all_marg.tex", write replace
	file write sm "\begin{tabular}{lccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_marg_1' & `OLS_w00_marg_2' & `OLS_w00_marg_3' & `OLS_w00_marg_4' & `OLS_w00_marg_5' & `OLS_w00_marg_6' & `OLS_w00_marg_7'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1' & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6' & `mean_dep_w7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1' & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_marg_1' & `OLS_f00_marg_2' & `OLS_f00_marg_3' & `OLS_f00_marg_4' & `OLS_f00_marg_5' & `OLS_f00_marg_6' & `OLS_f00_marg_7'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1' & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6' & `mean_dep_f7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1' & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_marg_1' & `OLS_m00_marg_2' & `OLS_m00_marg_3' & `OLS_m00_marg_4' & `OLS_m00_marg_5' & `OLS_m00_marg_6' & `OLS_m00_marg_7'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7')\\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1' & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6' & `mean_dep_m7'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1' & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\\\ "_n
	file write sm " &  & &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N     \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Note: Coefficients show effect at mean intensity (0 to mean) \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"

foreach outcome in $hh {

	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_w00_`i'_aux: di %12.3f `coef_raw'
	local SE_w00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_w00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_w00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_w00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'***"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'***"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'**"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'**"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'*"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'*"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'"
	}

	local mean_dep_w`i' : di %12.2fc `mean_outcome'
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}


* --- Female ---
local i = 1
foreach outcome in $hh {

	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_f00_`i'_aux: di %12.3f `coef_raw'
	local SE_f00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_f00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_f00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_f00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'***"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'***"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'**"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'**"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'*"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'*"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'"
	}

	local mean_dep_f`i' : di %12.2fc `mean_outcome'
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}


* --- Male ---
local i = 1
foreach outcome in $hh {

	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_m00_`i'_aux: di %12.3f `coef_raw'
	local SE_m00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_m00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_m00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_m00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'***"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'***"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'**"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'**"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'*"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'*"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'"
	}

	local mean_dep_m`i' : di %12.2fc `mean_outcome'
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}

{

			cap file close sm
		file open sm using "$tables/2000/T2_hh_enigh_1992_2000_all.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_1'  & `OLS_w00_2' & `OLS_w00_3' & `OLS_w00_4' & `OLS_w00_5' & `OLS_w00_6' & `OLS_w00_7' & `OLS_w00_8'\\  "_n
		file write sm "& (`SE_w00_1')  & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5')  & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_1'  & `OLS_f00_2' & `OLS_f00_3' & `OLS_f00_4' & `OLS_f00_5' & `OLS_f00_6' & `OLS_f00_7' & `OLS_f00_8'\\  "_n
		file write sm "& (`SE_f00_1')  & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5')  & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_1'  & `OLS_m00_2' & `OLS_m00_3' & `OLS_m00_4' & `OLS_m00_5' & `OLS_m00_6' & `OLS_m00_7' & `OLS_m00_8'\\  "_n
		file write sm "& (`SE_m00_1')  & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5')  & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
		file write sm "&  &  &  & &  &  &  & & &	  \\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n	
		file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
		*file write sm "Weight & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Age Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Locality Eligible FE & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Age x Locality Eligible FE & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}
		
{
	cap file close sm
	file open sm using "$tables/2000/T2_hh_enigh_1992_2000_all_z.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_z_1'   & `OLS_w00_z_2' & `OLS_w00_z_3' & `OLS_w00_z_4' & `OLS_w00_z_5' & `OLS_w00_z_6' & `OLS_w00_z_7' & `OLS_w00_z_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_z_1'   & `OLS_f00_z_2' & `OLS_f00_z_3' & `OLS_f00_z_4' & `OLS_f00_z_5' & `OLS_f00_z_6' & `OLS_f00_z_7' & `OLS_f00_z_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_z_1'   & `OLS_m00_z_2' & `OLS_m00_z_3' & `OLS_m00_z_4' & `OLS_m00_z_5' & `OLS_m00_z_6' & `OLS_m00_z_7' & `OLS_m00_z_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show effect per 1 SD increase in intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T2_hh_enigh_1992_2000_all_pct.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_pct_1'   & `OLS_w00_pct_2' & `OLS_w00_pct_3' & `OLS_w00_pct_4' & `OLS_w00_pct_5' & `OLS_w00_pct_6' & `OLS_w00_pct_7' & `OLS_w00_pct_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_pct_1'   & `OLS_f00_pct_2' & `OLS_f00_pct_3' & `OLS_f00_pct_4' & `OLS_f00_pct_5' & `OLS_f00_pct_6' & `OLS_f00_pct_7' & `OLS_f00_pct_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_pct_1'   & `OLS_m00_pct_2' & `OLS_m00_pct_3' & `OLS_m00_pct_4' & `OLS_m00_pct_5' & `OLS_m00_pct_6' & `OLS_m00_pct_7' & `OLS_m00_pct_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show percentage effect at mean intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T2_hh_enigh_1992_2000_all_marg.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_marg_1'   & `OLS_w00_marg_2' & `OLS_w00_marg_3' & `OLS_w00_marg_4' & `OLS_w00_marg_5' & `OLS_w00_marg_6' & `OLS_w00_marg_7' & `OLS_w00_marg_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_marg_1'   & `OLS_f00_marg_2' & `OLS_f00_marg_3' & `OLS_f00_marg_4' & `OLS_f00_marg_5' & `OLS_f00_marg_6' & `OLS_f00_marg_7' & `OLS_f00_marg_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_marg_1'   & `OLS_m00_marg_2' & `OLS_m00_marg_3' & `OLS_m00_marg_4' & `OLS_m00_marg_5' & `OLS_m00_marg_6' & `OLS_m00_marg_7' & `OLS_m00_marg_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show effect at mean intensity (0 to mean) \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_w00_`i'_aux: di %12.3f `coef_raw'
	local SE_w00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_w00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_w00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_w00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'***"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'***"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'**"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'**"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'*"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'*"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'"
	}

	local mean_dep_w`i' : di %12.2fc `mean_outcome'
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}


* --- Female ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_f00_`i'_aux: di %12.3f `coef_raw'
	local SE_f00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_f00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_f00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_f00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'***"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'***"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'**"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'**"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'*"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'*"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'"
	}

	local mean_dep_f`i' : di %12.2fc `mean_outcome'
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}


* --- Male ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_m00_`i'_aux: di %12.3f `coef_raw'
	local SE_m00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_m00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_m00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_m00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'***"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'***"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'**"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'**"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'*"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'*"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'"
	}

	local mean_dep_m`i' : di %12.2fc `mean_outcome'
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i

}

{		
		
	cap file close sm
		file open sm using "$tables/2000/T3_food_enigh_1992_2000_all.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_1'  & `OLS_w00_2' & `OLS_w00_3' & `OLS_w00_4' & `OLS_w00_5'  & `OLS_w00_6' & `OLS_w00_7' & `OLS_w00_8'\\  "_n
		file write sm "& (`SE_w00_1')  & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5')  & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_1'  & `OLS_f00_2' & `OLS_f00_3' & `OLS_f00_4' & `OLS_f00_5'  & `OLS_f00_6' & `OLS_f00_7' & `OLS_f00_8'\\  "_n
		file write sm "& (`SE_f00_1')  & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5')  & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_1'  & `OLS_m00_2' & `OLS_m00_3' & `OLS_m00_4' & `OLS_m00_5'  & `OLS_m00_6' & `OLS_m00_7' & `OLS_m00_8'\\  "_n
		file write sm "& (`SE_m00_1')  & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5')  & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n	
		file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\  "_n
		*file write sm "Weight & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Age Eligible FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Year x Locality Eligible FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
		*file write sm "Age x Locality Eligible FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}

{
	cap file close sm
	file open sm using "$tables/2000/T3_food_enigh_1992_2000_all_z.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_z_1'   & `OLS_w00_z_2' & `OLS_w00_z_3' & `OLS_w00_z_4' & `OLS_w00_z_5' & `OLS_w00_z_6' & `OLS_w00_z_7' & `OLS_w00_z_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_z_1'   & `OLS_f00_z_2' & `OLS_f00_z_3' & `OLS_f00_z_4' & `OLS_f00_z_5' & `OLS_f00_z_6' & `OLS_f00_z_7' & `OLS_f00_z_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_z_1'   & `OLS_m00_z_2' & `OLS_m00_z_3' & `OLS_m00_z_4' & `OLS_m00_z_5' & `OLS_m00_z_6' & `OLS_m00_z_7' & `OLS_m00_z_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show effect per 1 SD increase in intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T3_food_enigh_1992_2000_all_pct.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_pct_1'   & `OLS_w00_pct_2' & `OLS_w00_pct_3' & `OLS_w00_pct_4' & `OLS_w00_pct_5' & `OLS_w00_pct_6' & `OLS_w00_pct_7' & `OLS_w00_pct_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_pct_1'   & `OLS_f00_pct_2' & `OLS_f00_pct_3' & `OLS_f00_pct_4' & `OLS_f00_pct_5' & `OLS_f00_pct_6' & `OLS_f00_pct_7' & `OLS_f00_pct_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_pct_1'   & `OLS_m00_pct_2' & `OLS_m00_pct_3' & `OLS_m00_pct_4' & `OLS_m00_pct_5' & `OLS_m00_pct_6' & `OLS_m00_pct_7' & `OLS_m00_pct_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show percentage effect at mean intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T3_food_enigh_1992_2000_all_marg.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_marg_1'   & `OLS_w00_marg_2' & `OLS_w00_marg_3' & `OLS_w00_marg_4' & `OLS_w00_marg_5' & `OLS_w00_marg_6' & `OLS_w00_marg_7' & `OLS_w00_marg_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_marg_1'   & `OLS_f00_marg_2' & `OLS_f00_marg_3' & `OLS_f00_marg_4' & `OLS_f00_marg_5' & `OLS_f00_marg_6' & `OLS_f00_marg_7' & `OLS_f00_marg_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_marg_1'   & `OLS_m00_marg_2' & `OLS_m00_marg_3' & `OLS_m00_marg_4' & `OLS_m00_marg_5' & `OLS_m00_marg_6' & `OLS_m00_marg_7' & `OLS_m00_marg_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show effect at mean intensity (0 to mean) \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{

	*weighted
	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_w00_`i'_aux: di %12.3f `coef_raw'
	local SE_w00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w00_`i' = "`OLS_w00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_w00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_w00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_w00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'***"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'***"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'**"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'**"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'*"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'*"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_w00_z_`i' = "`OLS_w00_z_`i'_aux'"
		local OLS_w00_pct_`i' = "`OLS_w00_pct_`i'_aux'"
		local OLS_w00_marg_`i' = "`OLS_w00_marg_`i'_aux'"
	}

	local mean_dep_w`i' : di %12.2fc `mean_outcome'
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i
}


* --- Female ---
local i = 1
foreach outcome in $hh_health{

	*weighted
	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_f00_`i'_aux: di %12.3f `coef_raw'
	local SE_f00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f00_`i' = "`OLS_f00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_f00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_f00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_f00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'***"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'***"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'**"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'**"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'*"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'*"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_f00_z_`i' = "`OLS_f00_z_`i'_aux'"
		local OLS_f00_pct_`i' = "`OLS_f00_pct_`i'_aux'"
		local OLS_f00_marg_`i' = "`OLS_f00_marg_`i'_aux'"
	}

	local mean_dep_f`i' : di %12.2fc `mean_outcome'
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i
}


* --- Male ---
local i = 1
foreach outcome in $hh_health{

	*weighted
	reghdfe `outcome' c.inten2000#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & inrange(year, 1992, 2000) & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	* Store raw coefficient and SE
	local coef_raw = _b[1.post#c.inten2000]
	local se_raw = _se[1.post#c.inten2000]
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_outcome = r(mean)

	* Calculate standardized versions
	local coef_zscore = `coef_raw' * `inten2000_sd'
	local coef_pct = (`coef_raw' * `inten2000_mean' / `mean_outcome') * 100
	local coef_marg = `coef_raw' * `inten2000_mean'

	* Format raw coefficient with significance
	local OLS_m00_`i'_aux: di %12.3f `coef_raw'
	local SE_m00_`i' : di %12.3f `se_raw'
	local t_`i' = abs(`coef_raw'/`se_raw')

	if (`t_`i'' >= 2.576) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m00_`i' = "`OLS_m00_`i'_aux'"
	}

	* Format standardized versions
	local OLS_m00_z_`i'_aux: di %12.3f `coef_zscore'
	local OLS_m00_pct_`i'_aux: di %12.3f `coef_pct'
	local OLS_m00_marg_`i'_aux: di %12.3f `coef_marg'

	* Apply significance stars
	if (`t_`i'' >= 2.576) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'***"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'***"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'***"
	}

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'**"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'**"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'**"
	}

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'*"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'*"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'*"
	}

	if (`t_`i'' < 1.645) {
		local OLS_m00_z_`i' = "`OLS_m00_z_`i'_aux'"
		local OLS_m00_pct_`i' = "`OLS_m00_pct_`i'_aux'"
		local OLS_m00_marg_`i' = "`OLS_m00_marg_`i'_aux'"
	}

	local mean_dep_m`i' : di %12.2fc `mean_outcome'
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)'

	*increment on i
    local ++i
}

	{
	cap file close sm
		file open sm using "$tables/2000/T4_health_enigh_1992_2000_all.tex", write replace

		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_1'  & `OLS_w00_2' & `OLS_w00_3' & `OLS_w00_4' & `OLS_w00_5'  & `OLS_w00_6' & `OLS_w00_7' & `OLS_w00_8'\\  "_n
		file write sm "& (`SE_w00_1')  & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5')  & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_1'  & `OLS_f00_2' & `OLS_f00_3' & `OLS_f00_4' & `OLS_f00_5'  & `OLS_f00_6' & `OLS_f00_7' & `OLS_f00_8'\\  "_n
		file write sm "& (`SE_f00_1')  & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5')  & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_1'  & `OLS_m00_2' & `OLS_m00_3' & `OLS_m00_4' & `OLS_m00_5'  & `OLS_m00_6' & `OLS_m00_7' & `OLS_m00_8'\\  "_n
		file write sm "& (`SE_m00_1')  & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5')  & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
		file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str' & `inten2000_mean_str'& `inten2000_mean_str' & `inten2000_mean_str'  \\  "_n
		file write sm "Obs & `N_m1'  & `N_m2' & `N_m3' & `N_m4' & `N_m5'  & `N_m6' & `N_m7'  & `N_m8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "No. Mun & `n_mun1'  & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'  & `n_mun6' & `n_mun7'  & `n_mun8' \\  "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n	
		file write sm "Mun Controls & N  & N & N & N & N  & N & N & N     \\  "_n
		*file write sm "Weight & Y & Y & Y & Y & Y & Y & Y \\ "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
		*file write sm "Year x Age Eligible FE & Y & Y & Y & Y & Y & Y  \\ "_n
		*file write sm "Year x Locality Eligible FE & Y & Y & Y & Y & Y & Y  \\ "_n
		*file write sm "Age x Locality Eligible FE & Y & Y & Y & Y & Y & Y  \\ "_n
		file write sm "\bottomrule"_n
		file write sm "\end{tabular}"
		file close sm
}
{
	cap file close sm
	file open sm using "$tables/2000/T4_health_enigh_1992_2000_all_z.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_z_1'   & `OLS_w00_z_2' & `OLS_w00_z_3' & `OLS_w00_z_4' & `OLS_w00_z_5' & `OLS_w00_z_6' & `OLS_w00_z_7' & `OLS_w00_z_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_z_1'   & `OLS_f00_z_2' & `OLS_f00_z_3' & `OLS_f00_z_4' & `OLS_f00_z_5' & `OLS_f00_z_6' & `OLS_f00_z_7' & `OLS_f00_z_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_z_1'   & `OLS_m00_z_2' & `OLS_m00_z_3' & `OLS_m00_z_4' & `OLS_m00_z_5' & `OLS_m00_z_6' & `OLS_m00_z_7' & `OLS_m00_z_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show effect per 1 SD increase in intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T4_health_enigh_1992_2000_all_pct.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_pct_1'   & `OLS_w00_pct_2' & `OLS_w00_pct_3' & `OLS_w00_pct_4' & `OLS_w00_pct_5' & `OLS_w00_pct_6' & `OLS_w00_pct_7' & `OLS_w00_pct_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_pct_1'   & `OLS_f00_pct_2' & `OLS_f00_pct_3' & `OLS_f00_pct_4' & `OLS_f00_pct_5' & `OLS_f00_pct_6' & `OLS_f00_pct_7' & `OLS_f00_pct_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_pct_1'   & `OLS_m00_pct_2' & `OLS_m00_pct_3' & `OLS_m00_pct_4' & `OLS_m00_pct_5' & `OLS_m00_pct_6' & `OLS_m00_pct_7' & `OLS_m00_pct_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show percentage effect at mean intensity \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


{
	cap file close sm
	file open sm using "$tables/2000/T4_health_enigh_1992_2000_all_marg.tex", write replace
	file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}  \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\  \\toprule"_n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_w00_marg_1'   & `OLS_w00_marg_2' & `OLS_w00_marg_3' & `OLS_w00_marg_4' & `OLS_w00_marg_5' & `OLS_w00_marg_6' & `OLS_w00_marg_7' & `OLS_w00_marg_8'\\\\  "_n
	file write sm "& (`SE_w00_1') & (`SE_w00_2') & (`SE_w00_3') & (`SE_w00_4') & (`SE_w00_5') & (`SE_w00_6') & (`SE_w00_7') & (`SE_w00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_w1'   & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'   & `mean_dep_w6' & `mean_dep_w7'   & `mean_dep_w8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_w1'   & `N_w2' & `N_w3' & `N_w4' & `N_w5'   & `N_w6' & `N_w7'   & `N_w8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel B: Females}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_f00_marg_1'   & `OLS_f00_marg_2' & `OLS_f00_marg_3' & `OLS_f00_marg_4' & `OLS_f00_marg_5' & `OLS_f00_marg_6' & `OLS_f00_marg_7' & `OLS_f00_marg_8'\\\\  "_n
	file write sm "& (`SE_f00_1') & (`SE_f00_2') & (`SE_f00_3') & (`SE_f00_4') & (`SE_f00_5') & (`SE_f00_6') & (`SE_f00_7') & (`SE_f00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_f1'   & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'   & `mean_dep_f6' & `mean_dep_f7'   & `mean_dep_f8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_f1'   & `N_f2' & `N_f3' & `N_f4' & `N_f5'   & `N_f6' & `N_f7'   & `N_f8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "\underline{\textit{Panel C: Males}}  \\\\  "_n
	file write sm "\textit{Intensity 2000 x post (2000)} & `OLS_m00_marg_1'   & `OLS_m00_marg_2' & `OLS_m00_marg_3' & `OLS_m00_marg_4' & `OLS_m00_marg_5' & `OLS_m00_marg_6' & `OLS_m00_marg_7' & `OLS_m00_marg_8'\\\\  "_n
	file write sm "& (`SE_m00_1') & (`SE_m00_2') & (`SE_m00_3') & (`SE_m00_4') & (`SE_m00_5') & (`SE_m00_6') & (`SE_m00_7') & (`SE_m00_8')\\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_m1'   & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'   & `mean_dep_m6' & `mean_dep_m7'   & `mean_dep_m8'  \\\\  "_n
	file write sm "Avg Intensity & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  & `inten2000_mean_str'  \\\\  "_n
	file write sm "Obs & `N_m1'   & `N_m2' & `N_m3' & `N_m4' & `N_m5'   & `N_m6' & `N_m7'   & `N_m8' \\\\ "_n
	file write sm " &  & &  &  &  &  &  & \\\\ "_n
	file write sm "No. Mun & `n_mun1'   & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5'   & `n_mun6' & `n_mun7'   & `n_mun8' \\\\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Mun Controls & N  & N & N & N & N  & N & N & N    \\\\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n
	file write sm "Note: Coefficients show effect at mean intensity (0 to mean) \\\\ "_n
	file write sm "\\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

}


