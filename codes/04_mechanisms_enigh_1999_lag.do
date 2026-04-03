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
LAGGED 1999 INTENSITY: Excludes 1998 wave (inten1999 is a lead in 1998)
*Sample: 1992,1994,1996 (pre) + 2000,2002,2004,2005,2006 (post), marginalized only
*inten1999 is always lagged >= 1 year relative to outcome year in the post period
*This sounds like our preferred.
*************************************/

*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $individuals {

	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & year != 1998 & female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
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

	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & year != 1998 & female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
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
		file open sm using "$tables/T1_ind_enigh_1999_lag.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh {

	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
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

	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
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
		file open sm using "$tables/T2_hh_enigh_1999_lag.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998, ///
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
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}


* --- Male ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_1999_lag.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998, ///
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
	*increment on i 
    local ++i
}		
	

* --- Female ---
local i = 1
foreach outcome in $hh_health{

	*weighted
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		


* --- Male ---
local i = 1
foreach outcome in $hh_health{

	*weighted
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		

	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_1999_lag.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2006} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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


/*************************************
2. Set of 4 Tables: using BR time period, short term effects
2.1 Using 1999 intensity interacted with post
2.2 1992-2002 (excluding 1998)
2.3 only marginalized 
*************************************/

{
*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $individuals {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
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
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
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
		file open sm using "$tables/T1_ind_enigh_1999_lag_2002.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh {
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
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
	
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
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
		file open sm using "$tables/T2_hh_enigh_1999_lag_2002.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998, ///
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
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}


* --- Male ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_1999_lag_2002.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998, ///
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
	*increment on i 
    local ++i
}		
	

* --- Female ---
local i = 1
foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & hhh_female == 1, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_f99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		


* --- Male ---
local i = 1
foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' c.inten1999#i.post [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & inrange(year, 1992, 2002) & year != 1998 & hhh_female == 0, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[1.post#c.inten1999]
	local SE_m99_`i' : di %12.3f  _se[1.post#c.inten1999]
	
	
	local t_`i' = abs(_b[1.post#c.inten1999]/_se[1.post#c.inten1999])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		

	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_1999_lag_2002.tex", write replace

		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity 1999 x 1997-2002} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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
}


/*************************************
3. Set of 4 Tables: This mimics BR, same treatment, period and sample but starting in 1999
*3.1 Using current intensity continous from Barham and Rowberry
*3.2 1992 to 2002
*3.3 All (not just marginalized)
*************************************/
global sample_br = "(inten_start_year==1998 |inten_start_year==1999) & inrange(year, 1992, 2002)"
{
*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_br & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $individuals {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_br & female == 1 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
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
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_br & female == 0 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
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
		file open sm using "$tables/T1_ind_enigh_br_1999.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
	
foreach outcome in $hh {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & hhh_female == 1 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
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
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & hhh_female == 0 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T2_hh_enigh_br_1999.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & year != 1998, ///
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
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & hhh_female == 1 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}


* --- Male ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & hhh_female == 0 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_br_1999.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & year != 1998, ///
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
	*increment on i 
    local ++i
}		
	

* --- Female ---
local i = 1
foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & hhh_female == 1 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		


* --- Male ---
local i = 1
foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_br & hhh_female == 0 & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		

	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_br_1999.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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

}


/*************************************
4. Set of 4 Tables: This uses continous in our sample
*4.1 Using current intensity continous
*4.2 1992 to 2006
*4.3 Only marginalized
*************************************/
{
*individual income and labor outcomes
local i = 1
global individuals = "employed hrs_worked hrs_worked_pos ind_earnings ind_income_tot progresa_ind benef_gob_ind "

foreach outcome in $individuals {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & $sample_marg & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $individuals {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & female == 1 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
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
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	`outcome'_out == 0 & female == 0 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
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
		file open sm using "$tables/T1_ind_enigh_c_1999.tex", write replace 
		file write sm "\begin{tabular}{lccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Employment} & \multicolumn{1}{c}{Hrs Worked} & \multicolumn{1}{c}{Hrs Worked +} & \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' \\ "_n
		file write sm "  & & &  & & & &  \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7')\\ "_n
		file write sm "  & & &  & & & &  \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7'  \\  "_n
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

*household outcomes
local i = 1
global hh= "hh_earnings hh_income_tot hh_expenditure progresa_hh benef_gob_hh savings debt n_hh"
	
	
foreach outcome in $hh {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0  & $sample_marg & year != 1998, ///
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
	
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh {
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 1 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
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
	
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 0 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
		
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	
	*increment on i 
    local ++i
	
}

{

			cap file close sm
		file open sm using "$tables/T2_hh_enigh_c_1999.tex", write replace 
		file write sm "\begin{tabular}{lcccccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Earnings} & \multicolumn{1}{c}{Income} & \multicolumn{1}{c}{Expenditure} & \multicolumn{1}{c}{Progresa} & \multicolumn{1}{c}{Transfers} & \multicolumn{1}{c}{Savings} & \multicolumn{1}{c}{Debt} & \multicolumn{1}{c}{Household Size}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5' & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5' & `mean_dep_w6'& `mean_dep_w7' & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5' & `N_w6' & `N_w7' & `N_w8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5' & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5' & `mean_dep_f6'& `mean_dep_f7' & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5' & `N_f6' & `N_f7' & `N_f8' \\ "_n
			file write sm "  & & &  & & & & & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5' & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
			file write sm "  & & &  & & & & & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5' & `mean_dep_m6'& `mean_dep_m7' & `mean_dep_m8'  \\  "_n
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
		
*food

global hh_food = "food_exp vegg_fruit cereals meat_dairy sugar_fat_drink alcohol tobacco vice"
local i=1
foreach outcome in $hh_food {
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998, ///
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
	*increment on i 
    local ++i
	
}


* --- Female ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 1 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}


* --- Male ---
local i = 1
foreach outcome in $hh_food {
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 0 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)

	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 
	*unweighted
	*increment on i 
    local ++i
	
}

{		
		
	cap file close sm
		file open sm using "$tables/T3_food_enigh_c_1999.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Food} & \multicolumn{1}{c}{Veggies} & \multicolumn{1}{c}{Cereals} & \multicolumn{1}{c}{Meat and D} & \multicolumn{1}{c}{Sugar} & \multicolumn{1}{c}{Alcohol} & \multicolumn{1}{c}{Tobacco} & \multicolumn{1}{c}{Vice}  \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9}"_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
		file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8')\\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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

*health
global hh_health = "health_exp medical medical_inpatient medical_outpatient drugs drugs_prescribed drugs_overcounter ortho"
local i=1

foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & $sample_marg & year != 1998, ///
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
	*increment on i 
    local ++i
}		
	

* --- Female ---
local i = 1
foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 1 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_f99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_f99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_f99_`i' = "`OLS_f99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_f`i' : di %12.2fc `r(mean)'
	
	local N_f`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		


* --- Male ---
local i = 1
foreach outcome in $hh_health{
	
	*weighted
	reghdfe `outcome' intensity_new [pweight=exp_factor] if ///
	hh_unique == 1 & `outcome'_out == 0 & hhh_female == 0 & $sample_marg & year != 1998, ///
	a(year cve_ent_mun_super) cluster(cve_ent_mun_super)
	
	local OLS_m99_`i'_aux: di %12.3f  _b[intensity_new]
	local SE_m99_`i' : di %12.3f  _se[intensity_new]
	
	
	local t_`i' = abs(_b[intensity_new]/_se[intensity_new])
	
	if (`t_`i'' >= 2.576) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'***"	
	} 

	if inrange(`t_`i'', 1.96, 2.575) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'**"	
	} 


	if inrange(`t_`i'', 1.645, 1.96) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'*"	
	} 

	if (`t_`i'' < 1.645) {
		local OLS_m99_`i' = "`OLS_m99_`i'_aux'"	
	} 
	
	
	
	sum `outcome' [fweight = exp_factor]  if e(sample) & post == 2
	local mean_dep_m`i' : di %12.2fc `r(mean)'
	
	local N_m`i' : di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local n_mun`i' : di %12.0fc `r(ndistinct)' 

	*unweighted
	*increment on i 
    local ++i
}		

	{
	cap file close sm
		file open sm using "$tables/T4_health_enigh_c_1999.tex", write replace 
		file write sm "\begin{tabular}{lcccccccc} \hline \hline"_n
		*file write sm "& \multicolumn{4}{c}{Schock 2003-2008} & \multicolumn{4}{c}{Shock 2003-2013} \\ "_n
		file write sm "& \multicolumn{1}{c}{Health} & \multicolumn{1}{c}{Medical Visits} & \multicolumn{1}{c}{Inpatient} & \multicolumn{1}{c}{Outpatient} & \multicolumn{1}{c}{Drugs} & \multicolumn{1}{c}{Drugs Prescribed} & \multicolumn{1}{c}{Drugs OC} & \multicolumn{1}{c}{Orthotics}   \\ "_n
		file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4} \cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8} \cmidrule(lr){9-9} "_n
		file write sm "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\  \toprule"_n
file write sm "\underline{\textit{Panel A: Pooled}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_w99_1'  & `OLS_w99_2' & `OLS_w99_3' & `OLS_w99_4' & `OLS_w99_5'  & `OLS_w99_6' & `OLS_w99_7' & `OLS_w99_8'\\  "_n
		file write sm "& (`SE_w99_1')  & (`SE_w99_2') & (`SE_w99_3') & (`SE_w99_4') & (`SE_w99_5')  & (`SE_w99_6') & (`SE_w99_7') & (`SE_w99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_w1'  & `mean_dep_w2' & `mean_dep_w3' & `mean_dep_w4' & `mean_dep_w5'  & `mean_dep_w6' & `mean_dep_w7'  & `mean_dep_w8'  \\  "_n
		file write sm "Obs & `N_w1'  & `N_w2' & `N_w3' & `N_w4' & `N_w5'  & `N_w6' & `N_w7'  & `N_w8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel B: Females}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_f99_1'  & `OLS_f99_2' & `OLS_f99_3' & `OLS_f99_4' & `OLS_f99_5'  & `OLS_f99_6' & `OLS_f99_7' & `OLS_f99_8'\\  "_n
		file write sm "& (`SE_f99_1')  & (`SE_f99_2') & (`SE_f99_3') & (`SE_f99_4') & (`SE_f99_5')  & (`SE_f99_6') & (`SE_f99_7') & (`SE_f99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_f1'  & `mean_dep_f2' & `mean_dep_f3' & `mean_dep_f4' & `mean_dep_f5'  & `mean_dep_f6' & `mean_dep_f7'  & `mean_dep_f8'  \\  "_n
		file write sm "Obs & `N_f1'  & `N_f2' & `N_f3' & `N_f4' & `N_f5'  & `N_f6' & `N_f7'  & `N_f8' \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
file write sm "\underline{\textit{Panel C: Males}}  \\  "_n
		file write sm "\textit{Intensity} & `OLS_m99_1'  & `OLS_m99_2' & `OLS_m99_3' & `OLS_m99_4' & `OLS_m99_5'  & `OLS_m99_6' & `OLS_m99_7' & `OLS_m99_8'\\  "_n
		file write sm "& (`SE_m99_1')  & (`SE_m99_2') & (`SE_m99_3') & (`SE_m99_4') & (`SE_m99_5')  & (`SE_m99_6') & (`SE_m99_7') & (`SE_m99_8') \\ "_n
		file write sm " &  & &  &  &  &  &  & \\ "_n
		file write sm "Mean (1992-1996) & `mean_dep_m1'  & `mean_dep_m2' & `mean_dep_m3' & `mean_dep_m4' & `mean_dep_m5'  & `mean_dep_m6' & `mean_dep_m7'  & `mean_dep_m8'  \\  "_n
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


}
