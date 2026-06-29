*** ============================================================================================================
*** DATA: Municiaplity data, Death data(vital statistics), Total population(Census), Population by age group (Census)
*** TOPIC: Regression AAMR (Municipality level) back to 1990
*** BY: Soomin 
*** ============================================================================================================
cls
clear
set more off


 *	MAC

	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global codes "C:\Users\FELIPEME\Documents\projects\progresa_mortality\codes\"

	
 if c(username)=="root" {
	global data  "/home/user/progresa_mortality/data/"
	global codes "/home/user/progresa_mortality/codes/"
 }

*** BR phase-in sample: which start-year municipalities count as BR?
***   "1998_1999" : strict — only 1998 and 1999 entrants (current default, ~1,422 mun)
***   "1997_1999" : inclusive — adds 1997 entrants (~1,961 mun, matches BR reported N)
	global br_phase "1998_1999"



*** ====================================================================================
*** 0. Margination Index & POP data (1990, 2000, 2005, 2010)- used Felipe/Jorge's data
*** ====================================================================================
	use "$data/MI_mun_ipolate_recoded_1990.dta", clear
	
*** Create geographic code 
	sort cve_ent_mun_super year   
	rename pob_tot pop_tot
	* inconsistent: vhac sprim po2sm*
	save "$data/Temp_data/Index_mun_recoded.dta", replace
	
	keep if year==1990
	keep cve_ent_mun_super pop_tot im_mun_1990 gm_mun_1990
	rename pop_tot pop_tot_1990
	save "$data/Temp_data/im_recoded1990.dta", replace
	
	
***	Mean of total population in 1990-2015
	use "$data/Temp_data/Index_mun_recoded.dta", clear
	
	keep if year <2017
	collapse (mean) pop_tot, by(cve_ent_mun_super)
	
	save "$data/Temp_data/mean_pop.dta", replace
	
	
	
*** ======================================================================================
*** 1. NEW Beneficiary data (1997-2018)- collapsed by municipality - used Felipe/Jorge's data
*** ======================================================================================
	use "$data/beneficiaries_mun_recoded_1990.dta", clear
	
*** Create 1997 new benef = 1997 old benef	
	forvalues j=1997(1)2018 {
	rename pg_mun`j'  pg_new`j'
	rename cc_pg_mun`j' c_pg_new`j'
	}
	keep cve_ent_mun_super pg_new* c_pg_new* 
	foreach j in pg_new c_pg_new {
	gen `j'1990=0
	gen `j'1991=0
	gen `j'1992=0
	gen `j'1993=0
	gen `j'1994=0
	gen `j'1995=0
	gen `j'1996=0
	}
	reshape long pg_new c_pg_new, i(cve_ent_mun_super) j(year)
	sort cve_ent_mun_super year
	lab var pg_new "cumulative benef"
	save "$data/Temp_data/Progresa_benef_mun_recoded.dta", replace

	
	
*** =============================================================
*** 2. Number of HH (changed in 05/24/2023) - used Felipe/Jorge's data
*** =============================================================
	use "$data/households_mun_ipolate_recoded_1990.dta", clear

*** Create code
	collapse (sum) HH, by(year cve_ent_mun_super)
	rename HH hh_tot
	sort cve_ent_mun_super year
	save "$data/Temp_data/hhnum_recoded.dta", replace
	
	keep if year==1990
	rename hh_tot hh_tot1990
	drop year
	save "$data/Temp_data/hhnum_1990.dta", replace
	
	
	
*** =============================================================
*** Merge margination/pop + benef + HH
*** =============================================================	
*** Margination index (linearized ones) -> changed to the final data (05/23/2023)
	use "$data/Temp_data/Index_mun_recoded.dta", clear
	
*** Combine all datasets (beneficiary and HH in all years, 1990)
	merge 1:1 year cve_ent_mun_super using "$data/Temp_data/Progresa_benef_mun_recoded.dta"
	drop _merge
	merge 1:1 year cve_ent_mun_super using "$data/Temp_data/hhnum_recoded.dta"
	drop _merge
	merge m:1 cve_ent_mun_super using "$data/Temp_data/hhnum_1990.dta"
	drop _merge
	sort cve_ent_mun_super year

*** Exclude 2019, 2020 
	drop if year==2019|year==2020

*** Only old beneficiary data is not cumulative
	*bysort cve_ent_mun_super: gen pgbenef_old = sum(pg_old_y)
	rename pg_new pgbenef_new
	
	lab var hh_tot "total HH"
	lab var pop_tot "total population"
	lab var pgbenef_new "cumulative new benef"
	
*** Create Progresa intensity (cumulative benef) 
	bysort cve_ent_mun_super: gen intensity_new= pgbenef_new/hh_tot
	replace intensity_new=0 if intensity_new==.
	replace intensity_new=1 if intensity_new>=1 & intensity_new!=.
	replace c_pg_new=1 if c_pg_new>=1 & c_pg_new!=. /* replaced intensity=1 if over 1*/
		
	sort cve_ent_mun_super year
	bysort cve_ent_mun_super : gen lag_intensity_new = intensity_new[_n-1]
	replace lag_intensity_new=0 if lag_intensity_new==.
	bysort cve_ent_mun_super : gen lag2_intensity_new = lag_intensity_new[_n-1]
	replace lag2_intensity_new=0 if lag2_intensity_new==.
	bysort cve_ent_mun_super : gen lag3_intensity_new = lag2_intensity_new[_n-1]
	replace lag3_intensity_new=0 if lag3_intensity_new==.
	bysort cve_ent_mun_super : gen lag4_intensity_new = lag3_intensity_new[_n-1]
	replace lag4_intensity_new=0 if lag4_intensity_new==.
	bysort cve_ent_mun_super : gen lag5_intensity_new = lag4_intensity_new[_n-1]
	replace lag5_intensity_new=0 if lag5_intensity_new==.
	bysort cve_ent_mun_super : gen lag6_intensity_new = lag5_intensity_new[_n-1]
	replace lag6_intensity_new=0 if lag6_intensity_new==.
	bysort cve_ent_mun_super : gen lag7_intensity_new = lag6_intensity_new[_n-1]
	replace lag7_intensity_new=0 if lag7_intensity_new==.
	bysort cve_ent_mun_super : gen lag8_intensity_new = lag7_intensity_new[_n-1]
	replace lag8_intensity_new=0 if lag8_intensity_new==.
	bysort cve_ent_mun_super : gen lag9_intensity_new = lag8_intensity_new[_n-1]
	replace lag9_intensity_new=0 if lag9_intensity_new==.
	bysort cve_ent_mun_super : gen lag10_intensity_new = lag9_intensity_new[_n-1]
	replace lag10_intensity_new=0 if lag10_intensity_new==.
	
	bysort cve_ent_mun_super : gen lead_intensity_new = intensity_new[_n+1]
	replace lead_intensity_new=0 if lead_intensity_new==.
	replace lead_intensity_new=. if year==2018
	
*** Create Binary Progresa intensity 10%, 15% 
*	15%
	gen inten15=.
	replace inten15=1 if intensity_new>=0.15 &intensity_new!=.
	replace inten15=0 if intensity_new<0.15 &intensity_new!=.
	
	bysort cve_ent_mun_super: gen lag_inten15 = inten15[_n-1]
	replace lag_inten15=0 if lag_inten15==.
	bysort cve_ent_mun_super: gen lag2_inten15 = lag_inten15[_n-1]
	replace lag2_inten15=0 if lag2_inten15==.
	bysort cve_ent_mun_super: gen lag3_inten15 = lag2_inten15[_n-1]
	replace lag3_inten15=0 if lag3_inten15==.
	bysort cve_ent_mun_super: gen lag4_inten15 = lag3_inten15[_n-1]
	replace lag4_inten15=0 if lag4_inten15==.
	bysort cve_ent_mun_super: gen lag5_inten15 = lag4_inten15[_n-1]
	replace lag5_inten15=0 if lag5_inten15==.
	bysort cve_ent_mun_super: gen lag6_inten15 = lag5_inten15[_n-1]
	replace lag6_inten15=0 if lag6_inten15==.
	bysort cve_ent_mun_super: gen lag7_inten15 = lag6_inten15[_n-1]
	replace lag7_inten15=0 if lag7_inten15==.
	bysort cve_ent_mun_super: gen lag8_inten15 = lag7_inten15[_n-1]
	replace lag8_inten15=0 if lag8_inten15==.
	bysort cve_ent_mun_super: gen lag9_inten15 = lag8_inten15[_n-1]
	replace lag9_inten15=0 if lag9_inten15==.
	bysort cve_ent_mun_super: gen lag10_inten15 = lag9_inten15[_n-1]
	replace lag10_inten15=0 if lag10_inten15==.
	
	bysort cve_ent_mun_super: gen lead_inten15 = inten15[_n+1]
	replace lead_inten15=0 if lead_inten15==.
	replace lead_inten15=. if year==2018

*	10%
	gen inten10=.
	replace inten10=1 if intensity_new>=0.10 &intensity_new!=.
	replace inten10=0 if intensity_new<0.10 &intensity_new!=.
	
	bysort cve_ent_mun_super: gen lag_inten10 = inten10[_n-1]
	replace lag_inten10=0 if lag_inten10==.
	bysort cve_ent_mun_super: gen lag2_inten10 = lag_inten10[_n-1]
	replace lag2_inten10=0 if lag2_inten10==.
	bysort cve_ent_mun_super: gen lag3_inten10 = lag2_inten10[_n-1]
	replace lag3_inten10=0 if lag3_inten10==.
	bysort cve_ent_mun_super: gen lag4_inten10 = lag3_inten10[_n-1]
	replace lag4_inten10=0 if lag4_inten10==.
	bysort cve_ent_mun_super: gen lag5_inten10 = lag4_inten10[_n-1]
	replace lag5_inten10=0 if lag5_inten10==.
	bysort cve_ent_mun_super: gen lag6_inten10 = lag5_inten10[_n-1]
	replace lag6_inten10=0 if lag6_inten10==.
	bysort cve_ent_mun_super: gen lag7_inten10 = lag6_inten10[_n-1]
	replace lag7_inten10=0 if lag7_inten10==.
	bysort cve_ent_mun_super: gen lag8_inten10 = lag7_inten10[_n-1]
	replace lag8_inten10=0 if lag8_inten10==.
	bysort cve_ent_mun_super: gen lag9_inten10 = lag8_inten10[_n-1]
	replace lag9_inten10=0 if lag9_inten10==.
	bysort cve_ent_mun_super: gen lag10_inten10 = lag9_inten10[_n-1]
	replace lag10_inten10=0 if lag10_inten10==.
	
	bysort cve_ent_mun_super: gen lead_inten10 = inten10[_n+1]
	replace lead_inten10=0 if lead_inten10==.
	replace lead_inten10=. if year==2018
	
*	5%
	gen inten5=.
	replace inten5=1 if intensity_new>=0.05 &intensity_new!=.
	replace inten5=0 if intensity_new<0.05 &intensity_new!=.
	
	bysort cve_ent_mun_super: gen lag_inten5 = inten5[_n-1]
	replace lag_inten5=0 if lag_inten5==.
	bysort cve_ent_mun_super: gen lag2_inten5 = lag_inten5[_n-1]
	replace lag2_inten5=0 if lag2_inten5==.
	bysort cve_ent_mun_super: gen lag3_inten5 = lag2_inten5[_n-1]
	replace lag3_inten5=0 if lag3_inten5==.
	bysort cve_ent_mun_super: gen lag4_inten5 = lag3_inten5[_n-1]
	replace lag4_inten5=0 if lag4_inten5==.
	bysort cve_ent_mun_super: gen lag5_inten5 = lag4_inten5[_n-1]
	replace lag5_inten5=0 if lag5_inten5==.
	bysort cve_ent_mun_super: gen lag6_inten5 = lag5_inten5[_n-1]
	replace lag6_inten5=0 if lag6_inten5==.
	bysort cve_ent_mun_super: gen lag7_inten5 = lag6_inten5[_n-1]
	replace lag7_inten5=0 if lag7_inten5==.
	bysort cve_ent_mun_super: gen lag8_inten5 = lag7_inten5[_n-1]
	replace lag8_inten5=0 if lag8_inten5==.
	bysort cve_ent_mun_super: gen lag9_inten5 = lag8_inten5[_n-1]
	replace lag9_inten5=0 if lag9_inten5==.
	bysort cve_ent_mun_super: gen lag10_inten5 = lag9_inten5[_n-1]
	replace lag10_inten5=0 if lag10_inten5==.
	
	bysort cve_ent_mun_super: gen lead_inten5 = inten5[_n+1]
	replace lead_inten5=0 if lead_inten5==.
	replace lead_inten5=. if year==2018


*** Create groups based on Progresa intensity >=15%
*	ONLY FOR PRE-TRENDS: Replace as 1 if municipalities had 15% intensity in previous years	(e.g., ID: 01006)
	gen inten15_re= inten15
	bysort cve_ent_mun_super: replace inten15_re=1 if inten15_re[_n-1]==1
	bysort cve_ent_mun_super: gen inten15_cum=sum(inten15_re)
	bysort cve_ent_mun_super: gen inten15_total= inten15_cum[_N]
	
	bysort cve_ent_mun_super: gen lag_inten15_re = inten15_re[_n-1]
	replace lag_inten15_re=0 if lag_inten15_re==.
	bysort cve_ent_mun_super: gen lag2_inten15_re = lag_inten15_re[_n-1]
	replace lag2_inten15_re=0 if lag2_inten15_re==.
	bysort cve_ent_mun_super: gen lag3_inten15_re = lag2_inten15_re[_n-1]
	replace lag3_inten15_re=0 if lag3_inten15_re==.
	bysort cve_ent_mun_super: gen lag4_inten15_re = lag3_inten15_re[_n-1]
	replace lag4_inten15_re=0 if lag4_inten15_re==.
	bysort cve_ent_mun_super: gen lag5_inten15_re = lag4_inten15_re[_n-1]
	replace lag5_inten15_re=0 if lag5_inten15_re==.
	bysort cve_ent_mun_super: gen lag6_inten15_re = lag5_inten15_re[_n-1]
	replace lag6_inten15_re=0 if lag6_inten15_re==.
	bysort cve_ent_mun_super: gen lag7_inten15_re = lag6_inten15_re[_n-1]
	replace lag7_inten15_re=0 if lag7_inten15_re==.
	bysort cve_ent_mun_super: gen lag8_inten15_re = lag7_inten15_re[_n-1]
	replace lag8_inten15_re=0 if lag8_inten15_re==.
	bysort cve_ent_mun_super: gen lag9_inten15_re = lag8_inten15_re[_n-1]
	replace lag9_inten15_re=0 if lag9_inten15_re==.
	bysort cve_ent_mun_super: gen lag10_inten15_re = lag9_inten15_re[_n-1]
	replace lag10_inten15_re=0 if lag10_inten15_re==.
	
	bysort cve_ent_mun_super: gen lead_inten15_re = inten15_re[_n+1]
	replace lead_inten15_re=0 if lead_inten15_re==.
	replace lead_inten15_re=. if year==2018
	
*** Create groups based on Progresa intensity >=10%
	gen inten10_re= inten10
	bysort cve_ent_mun_super: replace inten10_re=1 if inten10_re[_n-1]==1
	bysort cve_ent_mun_super: gen inten10_cum=sum(inten10_re)
	bysort cve_ent_mun_super: gen inten10_total= inten10_cum[_N]
	
	bysort cve_ent_mun_super: gen lag_inten10_re = inten10_re[_n-1]
	replace lag_inten10_re=0 if lag_inten10_re==.
	bysort cve_ent_mun_super: gen lag2_inten10_re = lag_inten10_re[_n-1]
	replace lag2_inten10_re=0 if lag2_inten10_re==.
	bysort cve_ent_mun_super: gen lag3_inten10_re = lag2_inten10_re[_n-1]
	replace lag3_inten10_re=0 if lag3_inten10_re==.
	bysort cve_ent_mun_super: gen lag4_inten10_re = lag3_inten10_re[_n-1]
	replace lag4_inten10_re=0 if lag4_inten10_re==.
	bysort cve_ent_mun_super: gen lag5_inten10_re = lag4_inten10_re[_n-1]
	replace lag5_inten10_re=0 if lag5_inten10_re==.
	bysort cve_ent_mun_super: gen lag6_inten10_re = lag5_inten10_re[_n-1]
	replace lag6_inten10_re=0 if lag6_inten10_re==.
	bysort cve_ent_mun_super: gen lag7_inten10_re = lag6_inten10_re[_n-1]
	replace lag7_inten10_re=0 if lag7_inten10_re==.
	bysort cve_ent_mun_super: gen lag8_inten10_re = lag7_inten10_re[_n-1]
	replace lag8_inten10_re=0 if lag8_inten10_re==.
	bysort cve_ent_mun_super: gen lag9_inten10_re = lag8_inten10_re[_n-1]
	replace lag9_inten10_re=0 if lag9_inten10_re==.
	bysort cve_ent_mun_super: gen lag10_inten10_re = lag9_inten10_re[_n-1]
	replace lag10_inten10_re=0 if lag10_inten10_re==.
	
	bysort cve_ent_mun_super: gen lead_inten10_re = inten10_re[_n+1]
	replace lead_inten10_re=0 if lead_inten10_re==.
	replace lead_inten10_re=. if year==2018
	
*** Create groups based on Progresa intensity >= 5%
	gen inten5_re= inten5
	bysort cve_ent_mun_super: replace inten5_re=1 if inten5_re[_n-1]==1
	bysort cve_ent_mun_super: gen inten5_cum=sum(inten5_re)
	bysort cve_ent_mun_super: gen inten5_total= inten5_cum[_N]
	
	bysort cve_ent_mun_super: gen lag_inten5_re = inten5_re[_n-1]
	replace lag_inten5_re=0 if lag_inten5_re==.
	bysort cve_ent_mun_super: gen lag2_inten5_re = lag_inten5_re[_n-1]
	replace lag2_inten5_re=0 if lag2_inten5_re==.
	bysort cve_ent_mun_super: gen lag3_inten5_re = lag2_inten5_re[_n-1]
	replace lag3_inten5_re=0 if lag3_inten5_re==.
	bysort cve_ent_mun_super: gen lag4_inten5_re = lag3_inten5_re[_n-1]
	replace lag4_inten5_re=0 if lag4_inten5_re==.
	bysort cve_ent_mun_super: gen lag5_inten5_re = lag4_inten5_re[_n-1]
	replace lag5_inten5_re=0 if lag5_inten5_re==.
	bysort cve_ent_mun_super: gen lag6_inten5_re = lag5_inten5_re[_n-1]
	replace lag6_inten5_re=0 if lag6_inten5_re==.
	bysort cve_ent_mun_super: gen lag7_inten5_re = lag6_inten5_re[_n-1]
	replace lag7_inten5_re=0 if lag7_inten5_re==.
	bysort cve_ent_mun_super: gen lag8_inten5_re = lag7_inten5_re[_n-1]
	replace lag8_inten5_re=0 if lag8_inten5_re==.
	bysort cve_ent_mun_super: gen lag9_inten5_re = lag8_inten5_re[_n-1]
	replace lag9_inten5_re=0 if lag9_inten5_re==.
	bysort cve_ent_mun_super: gen lag10_inten5_re = lag9_inten5_re[_n-1]
	replace lag10_inten5_re=0 if lag10_inten5_re==.
	
	bysort cve_ent_mun_super: gen lead_inten5_re = inten5_re[_n+1]
	replace lead_inten5_re=0 if lead_inten5_re==.
	replace lead_inten5_re=. if year==2018
	
*** Starting year 5, 10, 15%
	gen inten5_year= 2019-inten5_total
	replace inten5_year=. if intensity_new==.
	
	gen inten10_year= 2019-inten10_total
	replace inten10_year=. if intensity_new==.
	
	gen inten15_year= 2019-inten15_total
	replace inten15_year=. if intensity_new==.

*** Group
	tab inten15_year
	gen inten15_year_group=.
	replace inten15_year_group=1 if inten15_year==1997 |inten15_year==1998
	replace inten15_year_group=2 if inten15_year==1999
	replace inten15_year_group=3 if inten15_year==2000
	replace inten15_year_group=4 if inten15_year==2001
	replace inten15_year_group=5 if inten15_year==2002|inten15_year==2003
	replace inten15_year_group=6 if inten15_year>2003 & inten15_year <2020
	tab inten15_year_group
	lab var inten15_year_group "Groups based on Progresa 15% started"
	
*** Labeling
	lab var cve_ent_mun_super "Mun code"
	lab var pgbenef_new "Progresa Beneficiaries, new"
	lab var intensity_new "Program intensity, new (% cumulative benef in total HH)"
	lab var analf "% illiterate population"
	lab var sprim "% without completed primary school"
	lab var ovsee "% without electricity"
	lab var ovsae "% without piped water"
	lab var vhac "% of overcrowding"
	lab var ovpt "% with dirt floors"
	lab var im_mun "continuous margination index"
	lab var inten15 "Binary-Progresa intensity (15%)"
	lab def inten15 0"<15%" 1">=15%"
	lab val inten15 inten15
	lab var inten15_year_group "Groups based on Progresa intensity (15%)"
	lab def inten15_year_group 1"A-1997-1998" 2"B-1999" 3"C-2000" 4"D-2001" 5"E-2002,2003" 6"F-2004-2018 or never" 
	lab val inten15_year_group inten15_year_group
	lab var lead_inten15 "1-year lead Binary-Progresa intensity (15%)"
	lab var lag_inten15 "1-year lag Binary-Progresa intensity (15%)"
	forvalues k=2(1)10 {
		lab var lag`k'_inten15 "`k'-year lag Binary-Progresa intensity (15%)"
	}
	lab var lead_intensity_new "1-year lead lag continuous Progresa intensity"
	lab var lag_intensity_new "1-year lag continuous Progresa intensity"
	forvalues k=2(1)10 {
	lab var lag`k'_intensity_new "`k'-year lag continuous Progresa intensity"
	}
	drop inten5_cum inten5_total inten10_cum inten10_total inten15_cum inten15_total
	save "$data/Temp_data/Index_bene_mun_recoded_temp.dta", replace
	
	
*** Year for program started
	use "$data/Temp_data/Index_bene_mun_recoded_temp.dta", clear
	keep intensity_new year cve_ent_mun_super 
	reshape wide intensity_new, i(cve_ent_mun_super) j(year)  
	tab cve_ent_mun_super if intensity_new1997>0 & (intensity_new1998==0 |intensity_new1999==0|intensity_new2000==0|intensity_new2001==0) 
	
	gen inten_start_year= .
	replace inten_start_year=1997 if intensity_new1997>0 
	order cve_ent_mun_super inten_start_year

	forvalues j=1998(1)2018 {
		replace inten_start_year=`j' if intensity_new`j'>0 &inten_start_year==.
	}
	
	gen inten_start_group=.
	replace inten_start_group=1 if inten_start_year>=1997 &inten_start_year<=1999
	replace inten_start_group=2 if inten_start_year>=2000 &inten_start_year<=2003
	replace inten_start_group=3 if inten_start_year==2004
	replace inten_start_group=4 if inten_start_year>=2005 &inten_start_year<=2015
	
	keep cve_ent_mun_super inten_*
	save "$data/Temp_data/Bene_start_mun_recoded.dta", replace


***	Merge two files
	use "$data/Temp_data/Index_bene_mun_recoded_temp.dta", clear
	merge m:1 cve_ent_mun_super using "$data/Temp_data/Bene_start_mun_recoded.dta"
	drop _merge
	order year cve_ent_mun_super intensity_new inten_start*
	save "$data/Temp_data/Index_bene_mun_recoded.dta", replace

	
*** =========================================================
*** 3. Population by 5-year age group (1990, 1995, 2000, 2005)
*** =========================================================
*** Data cleaning
	foreach k in 90 95 {
	use "$data/pop/Population_municipality_level_19`k'.dta", clear
		rename sta_code cve_ent
		rename mun_code cve_mun
		merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta"
		destring cve_ent cve_mun, replace
		format cve_ent %02.0f
		format cve_mun %03.0f
		gen cve_mun2=string(cve_ent,"%02.0f") + string(cve_mun,"%03.0f")
		replace cve_mun2=cve_ent_mun_super if cve_ent_mun_super!=""
	
		drop _merge cve_ent_mun_super
		rename cve_mun2 cve_ent_mun_super
		sort cve_ent_mun_super 
		collapse (sum) age_*, by(cve_ent_mun_super)
		
		foreach j in 50 55 60  {
		local a = `j' + 1
		local b = `j' + 2
		local c = `j' + 3
		local d = `j' + 4
		gen pop`j'`d'_19`k'=age_`j'_both + age_`a'_both +age_`b'_both +age_`c'_both +age_`d'_both
		gen pop`j'`d'_m19`k'=age_`j'_male + age_`a'_male +age_`b'_male +age_`c'_male +age_`d'_male
		gen pop`j'`d'_f19`k'=age_`j'_female + age_`a'_female +age_`b'_female +age_`c'_female +age_`d'_female
		}
		
* 	Missing of pop +65 are considered as 0
		egen popover65_19`k'=rowtotal(age_65_69_both age_70_74_both age_75_79_both age_80_84_both ///
			age_85_89_both age_90_94_both age_95_99_both age_100m_both)
		egen popover65_m19`k'=rowtotal(age_65_69_male age_70_74_male age_75_79_male age_80_84_male ///
			age_85_89_male age_90_94_male age_95_99_male age_100m_male)
		egen popover65_f19`k'=rowtotal(age_65_69_female age_70_74_female age_75_79_female age_80_84_female ///
			age_85_89_female age_90_94_female age_95_99_female age_100m_female)

*	Sub-groups within 65+ for AAMR65 construction
		gen pop6569_19`k'   = age_65_69_both
		gen pop6569_m19`k'  = age_65_69_male
		gen pop6569_f19`k'  = age_65_69_female
		gen pop7074_19`k'   = age_70_74_both
		gen pop7074_m19`k'  = age_70_74_male
		gen pop7074_f19`k'  = age_70_74_female
		egen popover70_19`k'  = rowtotal(age_70_74_both   age_75_79_both   age_80_84_both   ///
			age_85_89_both   age_90_94_both   age_95_99_both   age_100m_both)
		egen popover70_m19`k' = rowtotal(age_70_74_male   age_75_79_male   age_80_84_male   ///
			age_85_89_male   age_90_94_male   age_95_99_male   age_100m_male)
		egen popover70_f19`k' = rowtotal(age_70_74_female age_75_79_female age_80_84_female ///
			age_85_89_female age_90_94_female age_95_99_female age_100m_female)

		keep cve_ent_mun_super pop*
	save "$data/Temp_data/pop_age_19`k'_mun.dta", replace
	}

*** Compute 1995 national standard weights for AAMR65 (scalars persist across clear)
	use "$data/Temp_data/pop_age_1995_mun.dta", clear
	collapse (sum) pop6569_1995 popover70_1995 popover65_1995 ///
	               pop6569_m1995 popover70_m1995 popover65_m1995 ///
	               pop6569_f1995 popover70_f1995 popover65_f1995
	scalar w6569_1995    = pop6569_1995[1]    / popover65_1995[1]
	scalar wover70_1995  = popover70_1995[1]  / popover65_1995[1]
	scalar w6569_m1995   = pop6569_m1995[1]   / popover65_m1995[1]
	scalar wover70_m1995 = popover70_m1995[1] / popover65_m1995[1]
	scalar w6569_f1995   = pop6569_f1995[1]   / popover65_f1995[1]
	scalar wover70_f1995 = popover70_f1995[1] / popover65_f1995[1]
	
	foreach k in 00 05 {
	use "$data/pop/Population_municipality_level_20`k'.dta", clear
		rename sta_code cve_ent
		rename mun_code cve_mun
		merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta"
		destring cve_ent cve_mun, replace
		format cve_ent %02.0f
		format cve_mun %03.0f
		gen cve_mun2=string(cve_ent,"%02.0f") + string(cve_mun,"%03.0f")
		replace cve_mun2=cve_ent_mun_super if cve_ent_mun_super!=""
		 
		drop _merge cve_ent_mun_super
		rename cve_mun2 cve_ent_mun_super
		sort cve_ent_mun_super 
		collapse (sum) age_*, by(cve_ent_mun_super)
		
		foreach j in 50 55 60 {
		local a = `j' + 1
		local b = `j' + 2
		local c = `j' + 3
		local d = `j' + 4
		gen pop`j'`d'_20`k'=age_`j'_both + age_`a'_both +age_`b'_both +age_`c'_both +age_`d'_both
		gen pop`j'`d'_m20`k'=age_`j'_male + age_`a'_male +age_`b'_male +age_`c'_male +age_`d'_male
		gen pop`j'`d'_f20`k'=age_`j'_female + age_`a'_female +age_`b'_female +age_`c'_female +age_`d'_female
		}
		
* 	Missing of pop +65 are considered as 0
		egen popover65_20`k'=rowtotal(age_65_69_both age_70_74_both age_75_100_both age_100m_both)
		egen popover65_m20`k'=rowtotal(age_65_69_male age_70_74_male age_75_100_male age_100m_male)
		egen popover65_f20`k'=rowtotal(age_65_69_female age_70_74_female age_75_100_female age_100m_female)

*	Sub-groups within 65+ for AAMR65 construction
		gen pop6569_20`k'   = age_65_69_both
		gen pop6569_m20`k'  = age_65_69_male
		gen pop6569_f20`k'  = age_65_69_female
		gen pop7074_20`k'   = age_70_74_both
		gen pop7074_m20`k'  = age_70_74_male
		gen pop7074_f20`k'  = age_70_74_female
		gen popover70_20`k'   = age_70_74_both   + age_75_100_both  + age_100m_both
		gen popover70_m20`k'  = age_70_74_male   + age_75_100_male  + age_100m_male
		gen popover70_f20`k'  = age_70_74_female + age_75_100_female + age_100m_female

		keep cve_ent_mun_super pop*
	save "$data/Temp_data/pop_age_20`k'_mun.dta", replace
	}

*** Linearization (1990-2015)
	use "$data/Temp_data/pop_age_1990_mun.dta", clear
	merge 1:1 cve_ent_mun_super using "$data/Temp_data/pop_age_1995_mun.dta"
	drop _merge
	merge 1:1 cve_ent_mun_super using "$data/Temp_data/pop_age_2000_mun.dta"
	drop _merge
	merge 1:1 cve_ent_mun_super using "$data/Temp_data/pop_age_2005_mun.dta"
	drop _merge
	
	
*** Generate multiplyer and linearize population
	foreach k in 5054 5559 6064 over65 6569 7074 over70 {
	gen m1pop`k'=(pop`k'_1995/pop`k'_1990)^(1/5)
	gen m1pop`k'm=(pop`k'_m1995/pop`k'_m1990)^(1/5)
	gen m1pop`k'f=(pop`k'_f1995/pop`k'_f1990)^(1/5)
	
	gen m2pop`k'=(pop`k'_2000/pop`k'_1995)^(1/5)
	gen m2pop`k'm=(pop`k'_m2000/pop`k'_m1995)^(1/5)
	gen m2pop`k'f=(pop`k'_f2000/pop`k'_f1995)^(1/5)
	
	gen m3pop`k'=(pop`k'_2005/pop`k'_2000)^(1/5)
	gen m3pop`k'm=(pop`k'_m2005/pop`k'_m2000)^(1/5)
	gen m3pop`k'f=(pop`k'_f2005/pop`k'_f2000)^(1/5)
	drop pop`k'_2005 pop`k'_m2005 pop`k'_f2005
	}
	forvalues k=1991(1)1994 {
		foreach i in 5054 5559 6064 over65 6569 over70 {
		gen pop`i'_`k'=pop`i'_1990*(m1pop`i')^(`k'-1990)
		gen pop`i'_m`k'=pop`i'_m1990*(m1pop`i'm)^(`k'-1990)
		gen pop`i'_f`k'=pop`i'_f1990*(m1pop`i'f)^(`k'-1990)
		}
	}
	forvalues k=1996(1)1999 {
		foreach i in 5054 5559 6064 over65 6569 over70 {
		gen pop`i'_`k'=pop`i'_1995*(m2pop`i')^(`k'-1995)
		gen pop`i'_m`k'=pop`i'_m1995*(m2pop`i'm)^(`k'-1995)
		gen pop`i'_f`k'=pop`i'_f1995*(m2pop`i'f)^(`k'-1995)
		}
	}
	forvalues k=2001(1)2018 {
		foreach i in 5054 5559 6064 over65 6569 over70 {
		gen pop`i'_`k'=pop`i'_2000*(m3pop`i')^(`k'-2000)
		gen pop`i'_m`k'=pop`i'_m2000*(m3pop`i'm)^(`k'-2000)
		gen pop`i'_f`k'=pop`i'_f2000*(m3pop`i'f)^(`k'-2000)
		}
	}

	drop m1* m2* m3* 
	
*** Reshape wide to long
	reshape long pop5054_ pop5559_ pop6064_ popover65_ pop6569_ pop7074_ popover70_  ///
	pop5054_m pop5559_m pop6064_m popover65_m pop6569_m pop7074_m popover70_m ///
	pop5054_f pop5559_f pop6064_f popover65_f pop6569_f pop7074_f popover70_f  , i(cve_ent_mun_super) j(year)
	sort cve_ent_mun_super year 

	drop if pop5054_f ==.| pop5054_m==.|pop5559_m==.
	egen pop_over50_ = rowtotal (pop5054_ pop5559_ pop6064_ popover65_ )
	egen pop_over50_f = rowtotal (pop5054_f pop5559_f pop6064_f popover65_f)
	egen pop_over50_m = rowtotal (pop5054_m pop5559_m pop6064_m popover65_m)
	
*** Labeling
	foreach i in 5054 5559 6064 over65 6569 7074 over70 _over50 {
	lab var pop`i'_ "Population age group `i'"
	lab var pop`i'_m "Population age group `i', male"
	lab var pop`i'_f "Population age group `i', female"
	}
	
	* Population completeness screen.
	*   full : original behavior — require all 29 years (1990-2018) present.
	*   prog/br : require complete coverage only WITHIN the analytic window,
	*             which retains more municipalities (recovers the BR sample).
	if "$window" == "full" {
		bysort cve_ent_mun_super: gen num=1
		bysort cve_ent_mun_super: gen num_cum=sum(num)
		bysort cve_ent_mun_super: gen num_total= num_cum[_N]
		tab num_total
		keep if num_total==29
		drop num*
	}
	else {
		bysort cve_ent_mun_super: egen _nyr_w = total(inrange(year, $yr_start, $yr_end))
		tab _nyr_w
		keep if _nyr_w == $nyears
		drop _nyr_w
	}
	save "$data/Temp_data/Pop_agegrp_mun_recoded.dta", replace


	
***	Keep only pop over 50 in 1990
	use "$data/Temp_data/Pop_agegrp_mun_recoded.dta", clear
	keep if year ==1990 
	keep cve_ent_mun_super pop_over50_*
	rename pop_over50_  pop_over50_1990
	rename pop_over50_f pop_over50_f_1990
	rename pop_over50_m pop_over50_m_1990
	save "$data/Temp_data/Pop1990_mun_recoded.dta", replace
	
	

*** ================================================
*** 4. Death data from vital statistics (1990~)
*** ================================================

*	Will use dataset: "$Data/Work_SR/Temp_data/deathdata/Death_mun_final_gender_tb.dta"  

*** ==============================================================================
*** 5. Merge 4 datasets: municipality, death, HH, pop by age group
*** ==============================================================================
	use "$data/deaths/Death_mun_final_gender_tb.dta", clear   
	merge 1:1 year cve_ent_mun_super using "$data/Temp_data/Index_bene_mun_recoded.dta"
	keep if _merge==3
	drop _merge
	merge 1:1 year cve_ent_mun_super using "$data/Temp_data/Pop_agegrp_mun_recoded.dta"
	keep if _merge==3
	drop _merge
	merge m:1 cve_ent_mun_super using "$data/Temp_data/im_recoded1990.dta"
	keep if _merge==3
	drop _merge
	
	
*** Program in 1990-1996 =0
	foreach v of varlist intensity* lag_intensity* lag2_intensity* lag3_intensity* lag4_intensity* lag5_intensity* {
	replace `v'=0 if year>=1990 &year<=1996
	}
	order cve_ent_mun_super year intensity* lag*
	
*** Additional deaths
	gen death50_0=1 if death50==0
	replace death50_0=0 if death50>0 & death50!=.
	tab death50_0

	gen popover50_ = pop_over50_
	foreach k in m f {
	gen popover50_`k' = pop_over50_`k'
	}
	egen pob50_c=cut(popover50_), at (0, 50, 100, 200, 300, 400, 500, 1000, 9999999)
	
*** Labeling
	lab var death50_0 "Existence of Deaths +50"
	lab def death50_0 0"At least one death +50" 1"No Deaths +50"
	lab val death50_0 death50_0
	lab var popover50_ "Population aged +50"
	lab var popover65_ "Population aged +65"
	lab var pob50_c "Category of population aged over 50"
	lab def pob50_c 0"0-49" 50"50-99" 100"100-199" 200"200-299" 300"300-399" 400"400-499" 500"500-999" 1000">=1000"
	lab val pob50_c pob50_c

	lab var death50 "Deaths aged +50"
	lab var death65 "Deaths aged +65"
	cap lab var death50_2 "Deaths aged +50 (which have info on age)"
	cap lab var death_assist "Deaths +50 that had medical assistance"
	cap lab var death_hospital "Deaths +50 occurred at health facilities"
	cap lab var hospital_p "% deaths +50 in health facilities in total deaths +50"
	cap lab var assist_p "% received medical assistance +50 in total deaths +50"
	foreach i in 5054 5559 6064 6569 over70 {
		cap lab var death`i'  "Deaths age `i'"
		cap lab var death`i'm "Deaths age `i' (male)"
		cap lab var death`i'f "Deaths age `i' (female)"
	}
	foreach i in 5054f 5559f 6064f 6569f over70f 5054m 5559m 6064m 6569m over70m {
		cap lab var tb_card`i'   "Cardiovascular and circulatory diseases"
		cap lab var tb_infect`i' "Infections"
		cap lab var tb_diab`i'   "Diabetes"
		cap lab var tb_resp`i'   "Respiratory illnesses"
		cap lab var tb_nutri`i'  "Nutrition and anemia"
		cap lab var tb_cancer`i' "Cancers"
		cap lab var tb_accid`i'  "Accidents (Transportation accidents)"
		cap lab var tb_illdef`i' "Ill-defined"
		cap lab var tb_other`i'  "Others"
	}


*** ==============================================================
*** 6. Construct AAMR (2002-2013): deaths per 100,000 population
*** ==============================================================
*** 1) Crude mortality and by cause of death
	gen crude_mor=.
	replace crude_mor= death50*1000/pop_tot
	lab var crude_mor "Crude mortality (aged over 50) per 100,000"
	
***	Age-specific death rate
	gen emr50=.
	replace emr50 = death50*1000/popover50_
	lab var emr50 "Age-specific death rate (deaths over 50 per 100,000 of pop over 50)"
	
	gen emr50f=.
	replace emr50f = death50f*1000/popover50_f
	lab var emr50f "Mortality rate for female +50 older per 1000"
	
	gen emr50m=.
	replace emr50m = death50m*1000/popover50_m
	lab var emr50m "Mortality rate for male +50 older per 1000"
	
	gen emr65=.
	replace emr65 = death65*1000/popover65_
	lab var emr65 "Mortality rate +65 older per 1000"
	
	gen emr65f=.
	replace emr65f = death65f*1000/popover65_f
	lab var emr65f "Mortality rate for female +65 older per 1000"
	
	gen emr65m=.
	replace emr65m = death65m*1000/popover65_m
	lab var emr65m "Mortality rate for male +65 older per 1000"
			

***	 By cause of death
	foreach k in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {
		egen `k'over65= rowtotal (`k'6569f `k'over70f `k'6569m `k'over70m)
		egen `k'over65f= rowtotal (`k'6569f `k'over70f)
		egen `k'over65m= rowtotal (`k'6569m `k'over70m)
		gen emr65`k' = `k'over65*1000/popover65_
		gen emr65`k'f = `k'over65f*1000/popover65_f
		gen emr65`k'm = `k'over65m*1000/popover65_m
		lab var emr65`k' "Mortality rate +65 for `k'"
		lab var emr65`k'm "Mortality rate +65 for `k', male"
		lab var emr65`k'f "Mortality rate +65 for `k', female" 
		}		
			
			
*** 2) AAMR65: Age-adjusted Mortality Rate 65+ (1995 standard population)
*   Two age groups: 65-69 and 70+; standard weights from 1995 national census.
*   Assumes death6569, death6569m, death6569f, deathover70, deathover70m, deathover70f
*   exist in the death data file (consistent with cause-specific age sub-groups already present).
	gen asr6569   = death6569  * 1000 / pop6569_   if pop6569_   > 0
	gen asr6569m  = death6569m * 1000 / pop6569_m  if pop6569_m  > 0
	gen asr6569f  = death6569f * 1000 / pop6569_f  if pop6569_f  > 0
	gen asrover70  = deathover70  * 1000 / popover70_   if popover70_   > 0
	gen asrover70m = deathover70m * 1000 / popover70_m  if popover70_m  > 0
	gen asrover70f = deathover70f * 1000 / popover70_f  if popover70_f  > 0

	gen aamr65  = asr6569  * w6569_1995  + asrover70  * wover70_1995
	gen aamr65m = asr6569m * w6569_m1995 + asrover70m * wover70_m1995
	gen aamr65f = asr6569f * w6569_f1995 + asrover70f * wover70_f1995

	lab var asr6569    "Age-specific death rate 65-69 per 1,000"
	lab var asr6569m   "Age-specific death rate 65-69 per 1,000, male"
	lab var asr6569f   "Age-specific death rate 65-69 per 1,000, female"
	lab var asrover70  "Age-specific death rate 70+ per 1,000"
	lab var asrover70m "Age-specific death rate 70+ per 1,000, male"
	lab var asrover70f "Age-specific death rate 70+ per 1,000, female"
	lab var aamr65  "AAMR 65+ per 1,000 (1995 standard)"
	lab var aamr65m "AAMR 65+ per 1,000, male (1995 standard)"
	lab var aamr65f "AAMR 65+ per 1,000, female (1995 standard)"


***	Restrict to the analytic window.
***	full : original behavior — drop only 2018 (lead intensity missing there).
***	prog/br : keep only the chosen window.
	if "$window" == "full" {
		drop if year==2018
	}
	else {
		keep if inrange(year, $yr_start, $yr_end)
	}

	
*** Marginalized areas
	gen margin_1990=.
	replace margin_1990=1 if gm_mun_1990==3|gm_mun_1990==4|gm_mun_1990==5
	replace margin_1990=0 if gm_mun_1990==1|gm_mun_1990==2
	lab def margin_1990 1"Marginalized" 0"Non-marginalized"
	lab val margin_1990 margin_1990
	
	sort cve_ent_mun_super year
	order year cve_ent_mun_super gm_mun_1990 intensity_new  
	global control "hospital_p assist_p im_mun"
	global control2 "ovsae ovsee ovpt sprim po2sm ovsde pl5000 vhac"
	
*** Make balanced panel
***	full : original behavior — require all 28 years (1990-2017).
***	prog/br : require a complete panel within the chosen window.
	capture drop num*
	if "$window" == "full" {
		bysort cve_ent_mun_super: gen num=1
		bysort cve_ent_mun_super: gen num_cum=sum(num)
		bysort cve_ent_mun_super: gen num_total= num_cum[_N]
		tab num_total
		keep if num_total==28
		drop num*
	}
	else {
		bysort cve_ent_mun_super year: gen byte _yr1 = (_n==1)
		bysort cve_ent_mun_super: egen num_total = total(_yr1)
		tab num_total
		keep if num_total == $nyears
		drop _yr1 num_total
	}
	
	* Baseline older-adult population at the window's first year (1990 under
	* full/prog; 1992 under the BR window, where 1990-91 are out of sample).
	gen pop_over50_1990=.
	replace pop_over50_1990=pop_over50_ if year==$yr_start
	bysort cve_ent_mun_super (pop_over50_1990): replace pop_over50_1990 =pop_over50_1990[1]
	order year cve_ent_mun_super intensity_new lag_intensity_new lag2_intensity_new lag3_intensity_new lag4_intensity_new lag5_intensity_new
	
	gen margin_1990_grp=.
	replace margin_1990_grp=1 if gm_mun_1990==4|gm_mun_1990==5
	replace margin_1990_grp=0 if gm_mun_1990==1|gm_mun_1990==2|gm_mun_1990==3
	lab def margin_1990_grp 1"Marginalized areas" 0"Non-marginalized areas"
	lab val margin_1990_grp margin_1990_grp
	
	* Save a window-specific master; also keep the canonical name under the
	* default "full" window so other scripts are unaffected unless a window is chosen.
	save "$data/aamr_regression_municipality_gender_tb${master_suffix}.dta", replace
	if "$window" == "full" {
		save "$data/aamr_regression_municipality_gender_tb.dta", replace
	}