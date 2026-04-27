* ============================================================
* 03c_mechanisms_unweighted.do
* Archive companion to 03_mechanisms_enigh.do
*
* Contains UNWEIGHTED regression results for all T1-T4 tables.
* The weighted panel (Panel A) has been removed from each table;
* only Panel B (Unweighted) is written to output.
* Table filenames carry an _uw suffix to distinguish them from
* the weighted tables produced by 03_mechanisms_enigh.do.
*
* This file runs as a standalone script and re-runs both the
* weighted and unweighted regressions (the weighted run is
* needed to populate n_mun locals used in table footers).
* ============================================================

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
	global data "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global tables  "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\progresa_mortality\tables" 
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
*i create the 
g prog_ben_ind = (progresa_ind>0)
g prog_ben_hh = (progresa_hh>0)

table year prog_ben_hh if _merge == 3 & $sample_marg, ///
stat(mean progresa_ind) stat(mean progresa_hh) stat(count id) stat(count cve_ent_mun_super)
table year prog_ben_ind if _merge == 3 & $sample_marg, ///
stat(mean progresa_ind) stat(mean progresa_hh) stat(count id) stat(count cve_ent_mun_super)


gen post=.
	replace post=2 if year <1997 & year >1990 & year!=.
	replace post=1 if year >=1997 & year <2007 & year!=.
		lab def post 1"1997-2006" 2"1991-1996" 
	lab val post post

	
table post prog_ben_hh if _merge == 3 & $sample_marg, ///
 stat(mean progresa_ind) stat(mean progresa_hh) stat(mean employed) stat(mean hrs_worked) stat(mean health_exp) stat(count id) 
table post prog_ben_ind if _merge == 3 & $sample_marg, ///
stat(mean progresa_ind) stat(mean progresa_hh) stat(mean employed) stat(mean hrs_worked) stat(mean health_exp) stat(count id)


table post inten10 if _merge == 3 & $sample_marg, ///
stat(mean progresa_ind) stat(mean progresa_hh) stat(count id) stat(count cve_ent_mun_super)
/*********************/
*DESCRIPTIVES
/********************/

*pre treated
*sum progresa_ind if inlist(year, 1992, 1998) & prog_ben_hh  = 1
*pre non treated
*sum progresa_ind if inlist(year, 1992, 1998) & prog_ben_hh  = 0

*destring(est_dis), g(stratvar)
*svyset [pweight = exp_factor], psu(upm) strata(stratvar)
*svyset [pweight = exp_factor], psu(upm)

*I have to check if we want a balanced sample
*unbalanced PANEL
global sample_marg = "(gm_mun_1990==4|gm_mun_1990==5)"

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

*====================================================
* INTENSIVE MARGIN: household-level 65+ earner flag
*====================================================
* Flag households that have at least one member aged 65+
* with positive individual earnings (intensive margin at HH level).
* NOTE: 'folio' is the ENIGH household identifier; adjust if variable name differs.
gen elder65_pos_earn_ind = (age >= 65 & ind_earnings > 0 & ind_earnings != . & age != .)
bysort folio year: egen hh_elder65_pos_earn = max(elder65_pos_earn_ind)
drop elder65_pos_earn_ind

  

 *individual
table year if $sample_marg, ///
stat(mean employed) stat(mean hrs_worked) stat(mean hrs_worked_pos) stat(mean ind_earnings) stat(mean ind_income_tot) stat(mean progresa_ind) stat(mean benef_gob_ind)
*hosuehold

*check SAVINGS and DEBT in 2000
table year if hh_unique == 1 & $sample_marg, ///
stat(mean hh_earnings) stat(mean hh_income_tot) stat(mean hh_expenditure) stat(mean progresa_hh) 
table year if hh_unique == 1 & $sample_marg, ///
stat(mean benef_gob_hh) stat(mean savings) stat(mean debt) stat(mean n_hh)

*food

table year if hh_unique == 1 & $sample_marg, ///
stat(mean food_exp) stat(mean vegg_fruit) stat(mean cereals) stat(mean meat_dairy)
table year if hh_unique == 1 & $sample_marg, ///
stat(mean sugar_fat_drink)  stat(mean alcohol) stat(mean tobacco) stat(mean vice)

*health

table year if hh_unique == 1 & $sample_marg, ///
stat(mean health_exp medical) stat(mean medical_inpatient) stat(mean medical_outpatient) stat(mean drugs)
table year if hh_unique == 1 & $sample_marg, ///
stat(mean drugs_prescribed) stat(mean drugs_overcounter) stat(mean ortho)
	

/*************************************
ONLY USING 1999 Intesity Interaction
*************************************/

*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "


foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' c.inten1999#i.post if `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T1_ind_enigh_1999_uw.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
		file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') \\ "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' c.inten1999#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T2_hh_enigh_1999_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
		
			file write sm "  & & &  & & & & & \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8'\\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		
		
		file write sm "&  & &  &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	*unweighted
	reghdfe `outcome' c.inten1999#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
		
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_1999_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5'  & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5')  & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	reghdfe `outcome' c.inten1999#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
}		
	
	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_1999_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5'  & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5')  & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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



/*************************************
ONLY USING 2 year Lagged (1999) Intesity from Barham and Rowberry
*************************************/

*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "
global sample_br = "(inten_start_year==1998 |inten_start_year==1999) & inrange(year, 1992, 2002)"

foreach outcome in $individuals {
	
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' lag2_intensity_new if `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T1_ind_enigh_br_uw.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
		file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') \\ "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
	
foreach outcome in $hh {
	
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' lag2_intensity_new if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T2_hh_enigh_br_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
		
			file write sm "  & & &  & & & & & \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8'\\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		
		
		file write sm "&  & &  &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	reghdfe `outcome' lag2_intensity_new if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
		
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_br_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5'  & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5')  & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	reghdfe `outcome' lag2_intensity_new if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
}		
	
	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_br_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5'  & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5')  & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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



/*************************************
ONLY USING 1997 Intesity Interaction up to 2006
*This sounds like our preferred.
*************************************/

*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' c.inten1997#i.post if `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T1_ind_enigh_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
		file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' \\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') \\ "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' c.inten1997#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T2_hh_enigh_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
		
			file write sm "  & & &  & & & & & \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8'\\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
		
		
		file write sm "&  & &  &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	reghdfe `outcome' c.inten1997#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
		local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	

	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
		
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5'  & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5')  & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	reghdfe `outcome' c.inten1997#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
}		
	
	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5'  & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5')  & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
		
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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


/*************************************
ONLY USING Current Intesity Continous from Barham and Rowberry 
*Intensitiy starting in 1997, and up to 2002
*************************************/

*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "
global sample_br = "(inten_start_year==1998 |inten_start_year==1999) & inrange(year, 1992, 2002)"
foreach outcome in $individuals {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' intensity_new if `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T1_ind_enigh_br_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
		file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') \\ "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
	
foreach outcome in $hh {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' intensity_new if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T2_hh_enigh_br_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
		
			file write sm "  & & &  & & & & & \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8'\\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		
		
		file write sm "&  & &  &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	reghdfe `outcome' intensity_new if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
		
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_br_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5'  & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5')  & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	reghdfe `outcome' intensity_new if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
}		
	
	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_br_1997_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_uw99_1'  & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5'  & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
		file write sm "& (`SE_uw99_1')  & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5')  & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
		
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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




/*************************************
ONLY USING 1997 Intesity Interaction up to 2002
*This sounds like our preferred.
*************************************/

*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' c.inten1997#i.post ///
	if `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T1_ind_enigh_1997_2002_uw.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
		file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' \\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') \\ "_n
		file write sm "&  &   &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	reghdfe `outcome' c.inten1997#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T2_hh_enigh_1997_2002_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
		
			file write sm "  & & &  & & & & & \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8'\\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
		
		
		file write sm "&  & &  &  & &  &   &  &   \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6'& `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
		*file write sm "&  &   &  & &  &   &  &  & \\ "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	reghdfe `outcome' c.inten1997#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
		local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	

	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
		
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_1997_2002_uw.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5'  & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5')  & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	reghdfe `outcome' c.inten1997#i.post if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	

	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	
	*increment on i 
    local ++i
}		
	
	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_1997_2002_uw.tex", write replace

		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
		file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1'  & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5'  & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
		file write sm "& (`SE_uw97_1')  & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5')  & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
		
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_uw1'  & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5'  & `mean_dep_uw6' & `mean_dep_uw7'  & `mean_dep_uw8'  \\  "_n
		file write sm "Obs & `N_uw1'  & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5'  & `N_uw6' & `N_uw7'  & `N_uw8' \\ "_n
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

/*=================================================================
* INTENSIVE MARGIN TABLES
* Individual outcomes: restricted to ind_earnings > 0
* Household outcomes: restricted to hh_elder65_pos_earn == 1
*=================================================================*/

/*************************************************************
INTENSIVE MARGIN: Only 1999 Intensity Interaction
*************************************************************/

*individual income and labor outcomes - INTENSIVE MARGIN (1999 only)
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & ind_earnings > 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1999#i.post if `outcome'_out == 0 & ind_earnings > 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T1_ind_enigh_1999_im_uw.tex", write replace 
	file write sm "\begin{tabular}{cccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*household outcomes - INTENSIVE MARGIN (1999 only)
local i = 1
global hh = "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"

foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1999#i.post if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T2_hh_enigh_1999_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*food outcomes - INTENSIVE MARGIN (1999 only)
local i = 1
global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"

foreach outcome in $hh_food {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1999#i.post if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T3_food_enigh_1999_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veg/Fruit} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat/Dairy} & \multicolumn{1}{c}{Sugar/Fat} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*health outcomes - INTENSIVE MARGIN (1999 only)
local i = 1
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

foreach outcome in $hh_health {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_w99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1999#i.post if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_uw99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T4_health_enigh_1999_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

/*************************************************************
INTENSIVE MARGIN: 2-Year Lagged Intensity (Barham & Rowberry)
*************************************************************/

global sample_br = "(inten_start_year==1998 |inten_start_year==1999) & inrange(year, 1992, 2002)"

*individual income and labor outcomes - INTENSIVE MARGIN (baseline 1999)
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"

foreach outcome in $individuals {
	
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & ind_earnings > 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' lag2_intensity_new if `outcome'_out == 0 & ind_earnings > 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T1_ind_enigh_br_im_uw.tex", write replace 
	file write sm "\begin{tabular}{cccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*household outcomes - INTENSIVE MARGIN (baseline 1999)
local i = 1
global hh = "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"

foreach outcome in $hh {
	
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' lag2_intensity_new if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T2_hh_enigh_br_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*food outcomes - INTENSIVE MARGIN (baseline 1999)
local i = 1
global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"

foreach outcome in $hh_food {
	
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' lag2_intensity_new if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T3_food_enigh_br_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veg/Fruit} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat/Dairy} & \multicolumn{1}{c}{Sugar/Fat} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*health outcomes - INTENSIVE MARGIN (baseline 1999)
local i = 1
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

foreach outcome in $hh_health {
	
	reghdfe `outcome' lag2_intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_w99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' lag2_intensity_new if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[lag2_intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[lag2_intensity_new]
	
	
	local t_`i' = abs(_b[lag2_intensity_new]/_se[lag2_intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T4_health_enigh_br_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Lagged Intensity (1999)} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

/*************************************************************
INTENSIVE MARGIN: 1997 Intensity Interaction (up to 2006)
*************************************************************/

*individual income and labor outcomes - INTENSIVE MARGIN (1997 only)
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & ind_earnings > 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if `outcome'_out == 0 & ind_earnings > 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T1_ind_enigh_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{cccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*household outcomes - INTENSIVE MARGIN (1997 only)
local i = 1
global hh = "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"

foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T2_hh_enigh_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*food outcomes - INTENSIVE MARGIN (1997 only)
local i = 1
global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"

foreach outcome in $hh_food {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T3_food_enigh_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veg/Fruit} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat/Dairy} & \multicolumn{1}{c}{Sugar/Fat} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*health outcomes - INTENSIVE MARGIN (1997 only)
local i = 1
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

foreach outcome in $hh_health {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T4_health_enigh_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2006} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

/*************************************************************
INTENSIVE MARGIN: Current Intensity (Barham & Rowberry, 1997-2002)
*************************************************************/

global sample_br = "(inten_start_year==1998 |inten_start_year==1999) & inrange(year, 1992, 2002)"

*individual income and labor outcomes - INTENSIVE MARGIN (baseline 1997)
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"

foreach outcome in $individuals {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & ind_earnings > 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' intensity_new if `outcome'_out == 0 & ind_earnings > 0 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T1_ind_enigh_br_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{cccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*household outcomes - INTENSIVE MARGIN (baseline 1997)
local i = 1
global hh = "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"

foreach outcome in $hh {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' intensity_new if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T2_hh_enigh_br_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*food outcomes - INTENSIVE MARGIN (baseline 1997)
local i = 1
global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"

foreach outcome in $hh_food {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' intensity_new if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T3_food_enigh_br_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veg/Fruit} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat/Dairy} & \multicolumn{1}{c}{Sugar/Fat} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*health outcomes - INTENSIVE MARGIN (baseline 1997)
local i = 1
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

foreach outcome in $hh_health {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_w99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w99_`i' = "`OLS_w99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' intensity_new if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_br, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_uw99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw99_`i' = "`OLS_uw99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T4_health_enigh_br_1997_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity} & `OLS_uw99_1' & `OLS_uw99_2' & `OLS_uw99_3' & `OLS_uw99_4' & `OLS_uw99_5' & `OLS_uw99_6' & `OLS_uw99_7' & `OLS_uw99_8' \\  "_n
	file write sm "& (`SE_uw99_1') & (`SE_uw99_2') & (`SE_uw99_3') & (`SE_uw99_4') & (`SE_uw99_5') & (`SE_uw99_6') & (`SE_uw99_7') & (`SE_uw99_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

/*************************************************************
INTENSIVE MARGIN: 1997 Intensity Interaction (up to 2002)
*************************************************************/

*individual income and labor outcomes - INTENSIVE MARGIN (1997, up to 2002)
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & ind_earnings > 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if `outcome'_out == 0 & ind_earnings > 0 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T1_ind_enigh_1997_2002_im_uw.tex", write replace 
	file write sm "\begin{tabular}{cccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N     \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*household outcomes - INTENSIVE MARGIN (1997, up to 2002)
local i = 1
global hh = "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"

foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T2_hh_enigh_1997_2002_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*food outcomes - INTENSIVE MARGIN (1997, up to 2002)
local i = 1
global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"

foreach outcome in $hh_food {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T3_food_enigh_1997_2002_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veg/Fruit} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat/Dairy} & \multicolumn{1}{c}{Sugar/Fat} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}

*health outcomes - INTENSIVE MARGIN (1997, up to 2002)
local i = 1
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

foreach outcome in $hh_health {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_w97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_w97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_w97_`i' = "`OLS_w97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_w`i' : di %12.2fc `r(mean)'
	
	local N_w`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	
	reghdfe `outcome' c.inten1997#i.post ///
	if hh_unique == 1 & `outcome'_out == 0 & hh_elder65_pos_earn == 1 & $sample_marg & inrange(year, 1992, 2002), ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_uw97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_uw97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_uw97_`i' = "`OLS_uw97_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_uw`i' : di %12.2fc `r(mean)'
	
	local N_uw`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	
	
	
	*increment on i 
    local ++i
	
}

{

		cap file close sm
	file open sm using "$tables/T4_health_enigh_1997_2002_im_uw.tex", write replace 
	file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
	file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9} "_n
	file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
	file write sm "  & & &  & & & &  \\ "_n
	
file write sm "\underline{\textit{Panel B: Unweighted}}  \\  "_n
	file write sm "\textit{Intensity 1997 x 1997-2002} & `OLS_uw97_1' & `OLS_uw97_2' & `OLS_uw97_3' & `OLS_uw97_4' & `OLS_uw97_5' & `OLS_uw97_6' & `OLS_uw97_7' & `OLS_uw97_8' \\  "_n
	file write sm "& (`SE_uw97_1') & (`SE_uw97_2') & (`SE_uw97_3') & (`SE_uw97_4') & (`SE_uw97_5') & (`SE_uw97_6') & (`SE_uw97_7') & (`SE_uw97_8') \\ "_n
	file write sm "&  &   &  & &  &   &  &   \\ "_n
	file write sm "Mean (1992-1996) & `mean_dep_uw1' & `mean_dep_uw2' & `mean_dep_uw3' & `mean_dep_uw4' & `mean_dep_uw5' & `mean_dep_uw6' & `mean_dep_uw7' & `mean_dep_uw8'  \\  "_n
	file write sm "Obs & `N_uw1' & `N_uw2' & `N_uw3' & `N_uw4' & `N_uw5' & `N_uw6' & `N_uw7' & `N_uw8' \\ "_n
	file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\  "_n
	file write sm "&  &  &  & &  &  &  & & 	  \\  "_n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y  \\ "_n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y\\ "_n
	file write sm "Mun Controls & N & N & N & N & N & N & N & N & N    \\  "_n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ "_n
	file write sm "\bottomrule"_n
	file write sm "\end{tabular}"
	file close sm
}


/*************************************
BY SEX: ONLY USING 1997 Intensity Interaction
*************************************/

* --- T1: Individual outcomes by sex ---
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind"

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & female == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_f97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'"	
	} 
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & female == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_m97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'"	
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
		file open sm using "$tables/T1_ind_enigh_1997_sex_uw.tex", write replace 
		file write sm "\\begin{tabular}{lccccccccc} \\hline \\hline"_n
		file write sm "& \\multicolumn{1}{c}{Employment} & \\multicolumn{1}{c}{Hrs Worked} & \\multicolumn{1}{c}{Hrs Worked +} & \\multicolumn{1}{c}{Earnings} & \\multicolumn{1}{c}{Income} & \\multicolumn{1}{c}{Progresa} & \\multicolumn{1}{c}{Transfers}   \\\\ "_n
		file write sm "\\cmidrule(lr){2-2}\\cmidrule(lr){3-3}\\cmidrule(lr){4-4} \\cmidrule(lr){5-5}\\cmidrule(lr){6-6}\\cmidrule(lr){7-7}\\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\\\  \\toprule"_n
file write sm "\\underline{\\textit{Panel A: Females}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_f97_1' & `OLS_f97_2' & `OLS_f97_3' & `OLS_f97_4' & `OLS_f97_5' & `OLS_f97_6' & `OLS_f97_7'\\\\  "_n
		file write sm "& (`SE_f97_1') & (`SE_f97_2') & (`SE_f97_3') & (`SE_f97_4') & (`SE_f97_5') & (`SE_f97_6') & (`SE_f97_7')\\\\ "_n
		file write sm "  & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1' & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6' & `mean_dep_f7' \\\\  "_n
		file write sm "Obs & `N_f1' & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\\\  "_n
			file write sm "  & & & & & & &  \\ "_n
	file write sm "\\underline{\\textit{Panel B: Males}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_m97_1' & `OLS_m97_2' & `OLS_m97_3' & `OLS_m97_4' & `OLS_m97_5' & `OLS_m97_6' & `OLS_m97_7' \\\\  "_n
		file write sm "& (`SE_m97_1') & (`SE_m97_2') & (`SE_m97_3') & (`SE_m97_4') & (`SE_m97_5') & (`SE_m97_6') & (`SE_m97_7') \\\\ "_n
		file write sm "  & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1' & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6' & `mean_dep_m7'  \\\\  "_n
		file write sm "Obs & `N_m1' & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' \\\\ "_n
		file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' \\\\  "_n
		file write sm "&  &  &  & &  &  &  & & \t  \\\\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y \\\\ "_n	
		file write sm "Mun Controls & N & N & N & N & N & N & N \\\\  "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "\\bottomrule"_n
		file write sm "\\end{tabular}"
		file close sm
}

* --- T2: Household outcomes by sex of household head ---
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_f97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'"	
	} 
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_m97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'"	
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
		file open sm using "$tables/T2_hh_enigh_1997_sex_uw.tex", write replace 
		file write sm "\\begin{tabular}{lcccccccccc} \\hline \\hline"_n
		file write sm "& \\multicolumn{1}{c}{Earnings} & \\multicolumn{1}{c}{Income} & \\multicolumn{1}{c}{Expenditure} & \\multicolumn{1}{c}{Progresa} & \\multicolumn{1}{c}{Transfers} & \\multicolumn{1}{c}{Savings} & \\multicolumn{1}{c}{Debt} & \\multicolumn{1}{c}{Household Size}   \\\\ "_n
		file write sm "\\cmidrule(lr){2-2}\\cmidrule(lr){3-3}\\cmidrule(lr){4-4} \\cmidrule(lr){5-5}\\cmidrule(lr){6-6}\\cmidrule(lr){7-7}\\cmidrule(lr){8-8}\\cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\\\  \\toprule"_n
file write sm "\\underline{\\textit{Panel A: Female-headed HH}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_f97_1' & `OLS_f97_2' & `OLS_f97_3' & `OLS_f97_4' & `OLS_f97_5' & `OLS_f97_6' & `OLS_f97_7' & `OLS_f97_8'\\\\  "_n
		file write sm "& (`SE_f97_1') & (`SE_f97_2') & (`SE_f97_3') & (`SE_f97_4') & (`SE_f97_5') & (`SE_f97_6') & (`SE_f97_7') & (`SE_f97_8')\\\\ "_n
		file write sm "  & & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1' & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6' & `mean_dep_f7' & `mean_dep_f8' \\\\  "_n
		file write sm "Obs & `N_f1' & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\\\  "_n
			file write sm "  & & & & & & & &  \\ "_n
	file write sm "\\underline{\\textit{Panel B: Male-headed HH}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_m97_1' & `OLS_m97_2' & `OLS_m97_3' & `OLS_m97_4' & `OLS_m97_5' & `OLS_m97_6' & `OLS_m97_7' & `OLS_m97_8' \\\\  "_n
		file write sm "& (`SE_m97_1') & (`SE_m97_2') & (`SE_m97_3') & (`SE_m97_4') & (`SE_m97_5') & (`SE_m97_6') & (`SE_m97_7') & (`SE_m97_8') \\\\ "_n
		file write sm "  & & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1' & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6' & `mean_dep_m7' & `mean_dep_m8'  \\\\  "_n
		file write sm "Obs & `N_m1' & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\\\ "_n
		file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\\\  "_n
		file write sm "&  &  &  & &  &  &  & & \t  \\\\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n	
		file write sm "Mun Controls & N & N & N & N & N & N & N & N \\\\  "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "\\bottomrule"_n
		file write sm "\\end{tabular}"
		file close sm
}

* --- T3: Food outcomes by sex of household head ---
local i = 1
global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"

foreach outcome in $hh_food {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_f97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'"	
	} 
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_m97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'"	
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
		file open sm using "$tables/T3_food_enigh_1997_sex_uw.tex", write replace 
		file write sm "\\begin{tabular}{lcccccccc} \\hline \\hline"_n
		file write sm "& \\multicolumn{1}{c}{Food} & \\multicolumn{1}{c}{Veggies} & \\multicolumn{1}{c}{Cereals} & \\multicolumn{1}{c}{Meat and D} & \\multicolumn{1}{c}{Sugar} & \\multicolumn{1}{c}{Alcohol} & \\multicolumn{1}{c}{Tobacco} & \\multicolumn{1}{c}{Vice}  \\\\ "_n
		file write sm "\\cmidrule(lr){2-2}\\cmidrule(lr){3-3}\\cmidrule(lr){4-4} \\cmidrule(lr){5-5}\\cmidrule(lr){6-6}\\cmidrule(lr){7-7}\\cmidrule(lr){8-8} \\cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\\\  \\toprule"_n
file write sm "\\underline{\\textit{Panel A: Female-headed HH}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_f97_1' & `OLS_f97_2' & `OLS_f97_3' & `OLS_f97_4' & `OLS_f97_5' & `OLS_f97_6' & `OLS_f97_7' & `OLS_f97_8'\\\\  "_n
		file write sm "& (`SE_f97_1') & (`SE_f97_2') & (`SE_f97_3') & (`SE_f97_4') & (`SE_f97_5') & (`SE_f97_6') & (`SE_f97_7') & (`SE_f97_8')\\\\ "_n
		file write sm "  & & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1' & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6' & `mean_dep_f7' & `mean_dep_f8' \\\\  "_n
		file write sm "Obs & `N_f1' & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\\\  "_n
			file write sm "  & & & & & & & &  \\ "_n
	file write sm "\\underline{\\textit{Panel B: Male-headed HH}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_m97_1' & `OLS_m97_2' & `OLS_m97_3' & `OLS_m97_4' & `OLS_m97_5' & `OLS_m97_6' & `OLS_m97_7' & `OLS_m97_8' \\\\  "_n
		file write sm "& (`SE_m97_1') & (`SE_m97_2') & (`SE_m97_3') & (`SE_m97_4') & (`SE_m97_5') & (`SE_m97_6') & (`SE_m97_7') & (`SE_m97_8') \\\\ "_n
		file write sm "  & & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1' & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6' & `mean_dep_m7' & `mean_dep_m8'  \\\\  "_n
		file write sm "Obs & `N_m1' & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\\\ "_n
		file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\\\  "_n
		file write sm "&  &  &  & &  &  &  & & \t  \\\\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n	
		file write sm "Mun Controls & N & N & N & N & N & N & N & N \\\\  "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "\\bottomrule"_n
		file write sm "\\end{tabular}"
		file close sm
}

* --- T4: Health outcomes by sex of household head ---
local i = 1
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"

foreach outcome in $hh_health {
	
	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 1 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_f97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f97_`i' = "`OLS_f97_`i'_aux'"	
	} 
	sum `outcome' [fweight = exp_factor] if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	reghdfe `outcome' c.inten1997#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 0 & $sample_marg, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m97_`i'_aux: di %12.3f  _b[1.post#c.inten1997]
	local SE_m97_`i' : di %12.3f  _se[1.post#c.inten1997]
	
	local t_`i' = abs(_b[1.post#c.inten1997]/_se[1.post#c.inten1997])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'**"	
	} 

	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m97_`i' = "`OLS_m97_`i'_aux'"	
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
		file open sm using "$tables/T4_health_enigh_1997_sex_uw.tex", write replace 
		file write sm "\\begin{tabular}{lcccccccc} \\hline \\hline"_n
		file write sm "& \\multicolumn{1}{c}{Health} & \\multicolumn{1}{c}{Medical Visits} & \\multicolumn{1}{c}{Inpatient} & \\multicolumn{1}{c}{Outpatient} & \\multicolumn{1}{c}{Drugs} & \\multicolumn{1}{c}{Drugs Prescribed} & \\multicolumn{1}{c}{Drugs OC} & \\multicolumn{1}{c}{Orthotics}   \\\\ "_n
		file write sm "\\cmidrule(lr){2-2}\\cmidrule(lr){3-3}\\cmidrule(lr){4-4} \\cmidrule(lr){5-5}\\cmidrule(lr){6-6}\\cmidrule(lr){7-7}\\cmidrule(lr){8-8} \\cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\\\  \\toprule"_n
file write sm "\\underline{\\textit{Panel A: Female-headed HH}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_f97_1' & `OLS_f97_2' & `OLS_f97_3' & `OLS_f97_4' & `OLS_f97_5' & `OLS_f97_6' & `OLS_f97_7' & `OLS_f97_8'\\\\  "_n
		file write sm "& (`SE_f97_1') & (`SE_f97_2') & (`SE_f97_3') & (`SE_f97_4') & (`SE_f97_5') & (`SE_f97_6') & (`SE_f97_7') & (`SE_f97_8')\\\\ "_n
		file write sm "  & & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1' & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6' & `mean_dep_f7' & `mean_dep_f8' \\\\  "_n
		file write sm "Obs & `N_f1' & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\\\  "_n
			file write sm "  & & & & & & & &  \\ "_n
	file write sm "\\underline{\\textit{Panel B: Male-headed HH}}  \\\\  "_n
		file write sm "\\textit{Intensity 1997 x 1997-2006} & `OLS_m97_1' & `OLS_m97_2' & `OLS_m97_3' & `OLS_m97_4' & `OLS_m97_5' & `OLS_m97_6' & `OLS_m97_7' & `OLS_m97_8' \\\\  "_n
		file write sm "& (`SE_m97_1') & (`SE_m97_2') & (`SE_m97_3') & (`SE_m97_4') & (`SE_m97_5') & (`SE_m97_6') & (`SE_m97_7') & (`SE_m97_8') \\\\ "_n
		file write sm "  & & & & & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1' & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6' & `mean_dep_m7' & `mean_dep_m8'  \\\\  "_n
		file write sm "Obs & `N_m1' & `N_m2' & `N_m3' & `N_m4' & `N_m5' & `N_m6' & `N_m7' & `N_m8' \\\\ "_n
		file write sm "No. Mun & `n_mun1' & `n_mun2' & `n_mun3' & `n_mun4' & `n_mun5' & `n_mun6' & `n_mun7' & `n_mun8' \\\\  "_n
		file write sm "&  &  &  & &  &  &  & & \t  \\\\  "_n		
		file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y \\\\ "_n	
		file write sm "Mun Controls & N & N & N & N & N & N & N & N \\\\  "_n
		file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y  \\\\ "_n
		file write sm "\\bottomrule"_n
		file write sm "\\end{tabular}"
		file close sm
}
