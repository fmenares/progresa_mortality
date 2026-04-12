*** ============================================================================================================
*** DATA: Municiaplity data, Death data(vital statistics), Total population(Census), Population by age group (Census)
*** TOPIC: Regression AAMR (Municipality level) back to 1990
*** BY: Soomin 
*** ============================================================================================================
cls
clear
set more off


 if c(username)=="Soomin" {
 
 global Project "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS"
 global Data "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS/Progresa_Locality_Mortality_Project"
 global Benefdata "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS/SocialProgramBeneficiaries"
 global Vitaldata "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS/Mortality_VitalStatistics_Project" 
 cd "/Users/soominryu/Desktop"
}

 if c(username)=="FELIPEME" {
    global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global tables  "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_mortality\tables"
	global figures "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_mortality\figures"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}

 
 *	Interact with one post-dummy=1 - intensity99*post and one for intensity05*post. [MAY 2025]  
	use "$data/aamr_regression_municipality_gender_tb.dta", clear
	merge m:1 cve_ent_mun_super using "$data/inten1999.dta"
	drop _merge
	merge m:1 cve_ent_mun_super using "$data/inten2005.dta"
	drop _merge

	gen post=.
	replace post=2 if year <1997 & year >1990 & year!=.
	replace post=1 if year >=1997 & year <2007 & year!=.
	
	lab def post 1"1997-2006" 2"1991-1996" 
	lab val post post
	
*	Merge with Seguro Popular data
	merge 1:1 cve_ent_mun_super year using "$data/SP_2001_2018.dta"
	drop _merge
	order year cve_ent_mun_super inten1999 post sp_intensity
	
*	Restriction (year)
	keep if year >1990 & year <2007
	
	tab post 
	global sample_marg = "gm_mun_1990==4|gm_mun_1990==5"
	
	
	
lab var year "year"
	lab var inten1999 " "
	
	gen year_1995=.
	replace year_1995=1 if year==1991
	replace year_1995=2 if year==1992
	replace year_1995=3 if year==1993
	replace year_1995=4 if year==1994
	replace year_1995=5 if year==1995
	replace year_1995=6 if year==1996
	replace year_1995=7 if year==1997
	replace year_1995=8 if year==1998
	replace year_1995=9 if year==1999
	replace year_1995=10 if year==2000
	replace year_1995=11 if year==2001
	replace year_1995=12 if year==2002
	replace year_1995=13 if year==2003
	replace year_1995=14 if year==2004
	replace year_1995=15 if year==2005
	replace year_1995=16 if year==2006
	 
	lab var year_1995 "y"
	lab def year_1995 1"1991" 2"1992" 3"1993" 4"1994" 5"1995" 6"1996" 7"1997" 8"1998" 9"1999" ///
		10"2000" 11"2001" 12"2002" 13"2003" 14 "2004" 15"2005" 16"2006" 
	lab val year_1995 year_1995
	
	g aux = intensity_new if year == 2002
	bys cve_ent_mun_super: egen inten2002 = min(aux)
	drop aux
	g aux = intensity_new if year == 1997
	bys cve_ent_mun_super: egen inten1997 = min(aux)
	drop aux
	preserve
	*Restriction (marginalized areas)
	*keep if gm_mun_1990==4|gm_mun_1990==5
	keep year cve_ent_mun_super im_mun inten15 inten10 inten5 inten1999 ///
	inten2005 lag2_intensity_new intensity_new inten1997 inten_start_year gm_mun_1990
	
	save "$data/mortality_muni", replace
	restore
	
*Table 2

*UW
*pool results: using clustering
reghdfe emr65 c.inten1999#i.post c.inten2005#i.post if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
*by sex
reghdfe emr65m c.inten1999#i.post c.inten2005#i.post if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65f c.inten1999#i.post c.inten2005#i.post if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
*UW + SP
reghdfe emr65 c.inten1999#i.post c.inten2005#i.post c.sp_intensity  if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

*Weighted results
reghdfe emr65 c.inten1999#i.post c.inten2005#i.post [aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65m c.inten1999#i.post c.inten2005#i.post [aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65f c.inten1999#i.post c.inten2005#i.post [aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

reghdfe emr65 c.inten1999#i.post c.inten2005#i.post c.sp_intensity [aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity [aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity [aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

*Appendix TAble
*Barham and Rowberry (2013)
*1992 - 2002
global sample_br = "(inten_start_year==1998 |inten_start_year==1999)"
areg  emr65 lag2_intensity_new i.year if inrange(year, 1992, 2002) & $sample_br, ///
a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)

*AT1b: BR
reghdfe emr65 lag2_intensity_new if inrange(year, 1992, 2002) & $sample_br, ///
a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)
*AT1c: BR + weights
reghdfe emr65 lag2_intensity_new [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, ///
a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

*AT1d: not quite sure why the time period changes, is just for sensitivity?
reghdfe emr65 lag_intensity_new [aw=popover65_] if inrange(year, 1991, 2001) & $sample_br, ///
a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65 lag_intensity_new [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, ///
a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
*AT1e: not quite sure why the time period changes, is just for sensitivity?
reghdfe emr65 lag3_intensity_new [aw=popover65_] if inrange(year, 1993, 2003) & $sample_br, ///
a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65 lag3_intensity_new [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, ///
a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

*Table needs to be created here by having a similar structure as the Table 2.
*However, here every columns should refer a specification:
*(1) BR result, copy by hand; 2: BR Replication 3: Replication + W; 4: 
*1 yr lag + w; 5: 3 year lag + w
*In the rows there must be 3 different names that captures the coefficient of interest*
*1. 2-year lagged Progresa Intensity
*2. 1- year lagged progresa intensity
*3. 3-year lagged progresa intensity


/*** appendix tABLE
bASED ON THE FOLLOWING regressions create a similar Tables as the others for mortality
having the same structure on panels, pool, female and males, but having a first 
column with the previous results having mortality in levels as the dependant variable
second column having it as count of deaths and using a poisson regression with
an offset, and a last one having it as a logs of mortality rate. 
*felipe's poisson and log specifications*/

	g lemr65 = log(emr65)
	g lemr65m = log(emr65m)
	g lemr65f = log(emr65f)
	g lpopover65 = log(popover65_)

areg lemr65 c.inten1999#i.post c.inten2005#i.post i.year if $sample_marg, absorb(cve_ent_mun_super) 


reghdfe emr65m c.inten1999#i.post c.inten2005#i.post if $sample_marg, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)
reghdfe lemr65m c.inten1999#i.post c.inten2005#i.post if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
reghdfe emr65m c.inten1999#i.post c.inten2005#i.post if e(sample), a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

ppmlhdfe death65 c.inten1999#i.post c.inten2005#i.post if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
ppmlhdfe death65 c.inten1999#i.post c.inten2005#i.post if $sample_marg, a(year cve_ent_mun_super) offset(lpopover65) vce(cluster cve_ent_mun_super)		
		

/********************
FIGURES
***********************/


*Figure 1: Can you create a 2 figures plotting the elderly 65+ mortality raw mortality trends,
*that on the y axis has the mortality rate plotted and on the y2 axis has the
*penetration for each year between 1990 and 2006, 1 figure should for all municipalities
*and the other should be only for the highly marginalized. Each figure should include
*separate mortality trends by pool (all), males and females

*Fig 2 consistent with Panel B in T2 but PLUS CLUSTER SE (UNWEIGHTED)
*a
areg emr65 c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 c.sp_intensity ///
if $sample_marg, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2005 inten2005 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Mortality Rate") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
		graph export "$figures/Figure_2a_all.pdf", as(pdf) replace	
*b
		areg emr65m c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 c.sp_intensity ///
		if $sample_marg, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2005 inten2005 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Mortality Rate") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
		graph export "$figures/Figure_2b_male.pdf", as(pdf) replace	
*c
		areg emr65f c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 c.sp_intensity ///
		 if $sample_marg, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2005 inten2005 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Mortality Rate") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
		graph export "$figures/Figure_2c_female.pdf", as(pdf) replace	

*Fig 3 consistent with Panel C in T2 (WEIGHTED)
*a
areg emr65 c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 c.sp_intensity [aw=popover65_] if $sample_marg, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2005 inten2005 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Mortality Rate") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
		graph export "$figures/Figure_3a_all.pdf", as(pdf) replace	
*b
		areg emr65m c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 c.sp_intensity [aw=popover65_] if $sample_marg, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2005 inten2005 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Mortality Rate") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
		graph export "$figures/Figure_3b_male.pdf", as(pdf) replace	
*c
		areg emr65f c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 c.sp_intensity [aw=popover65_] if $sample_marg, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2005 inten2005 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Mortality Rate") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
		graph export "$figures/Figure_3c_female.pdf", as(pdf) replace	


		
*what about the pre-trends of Barham and Roweberry?

*There is no direct testing because the intesnity/treatment changes over time. 
*Therefore, an adapated method would be considering early cumulative effects 
*and thus adapt their intensity time varying lagged 2 periods for the intensity 
*in 1999 interacted with time dummies.

*First we get the PostxIntensity 1999, getting a negative and significant of 3.9
 
**Event Study (This would be similar to F2) *Unweighted
*a
 reghdfe emr65 c.inten1999##ib6.year_1995 if inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
 		coefplot, drop (*.year_1995 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	

**b)  Event Study weighted 
 reghdfe emr65 c.inten1999##ib6.year_1995 [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
  		coefplot, drop (*.year_1995 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 
		
**c) Event Study weighted + cp_intensity
 reghdfe emr65 c.inten1999##ib6.year_1995 c.sp_intensity [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
  		coefplot, drop (*.year_1995 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		  yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 
 
 *IT NEEDS TO GO FOR 99 TO 2002 INTENSISTY
 *However, this strategy requires that in the absence of roll-out, cross- cohort 
 *trends would be parallel in municipalities more and less intensively treated at 
 *the start of the programme. Because initial po v erty predicts enrolment intensity, 
 *this assumption would be violated if, for example, initially poor municipalities 
 *tended to converge toward less poor municipalities across successive cohorts.

 *Adapting BR 2013 to P&V 2023
* As such, we modify the standard specification to ask whether, among municipalities
* with the same cumulative enrolment intensity at the end of the Fox administration 
* (2005), those that saw more intensity during the Zedillo administration (1997–9)
* experienced larger gains in early beneficiary cohorts. Thus, the spatial 
*component of our design focuses on an early-versus-late comparison, rather than everer versus-never.

*Adapting BR to PV does not make much sense because the post period is already 2002. 
*and it looks for short term effects only. if we care about pre-trends, previous
*exercise should be enough

*Including weights

reghdfe emr65 c.inten1999#i.post c.inten2002#i.post if ///
 inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
*now including weights
reghdfe emr65 c.inten1999#i.post c.inten2002#i.post [aw=popover65_] if ///
inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
 
 **Event Study
 areg emr65 c.inten1999##ib6.year_1995 c.inten2002##ib6.year_1995 ///
 if inrange(year, 1992, 2002) & $sample_br, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2002 inten2002 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
 **Event Study weighted
 areg emr65 c.inten1999##ib6.year_1995 c.inten2002##ib6.year_1995 [aw=popover65_] ///
 if inrange(year, 1992, 2002) & $sample_br, absorb(cve_ent_mun_super) vce(cluster cve_ent_mun_super) baselevels
		coefplot, drop (*.year_1995 *.year_1995#c.inten2002 inten2002 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	
 
*********************************************
 *what if we instead we do BR in our sample
 *********************************************
 *Maybe I can create a Table here: Ask claude for it. based on columns
 *maybe a plot of the different coefficients. 
 
*BR but now only for highly marginalized (significant)
reghdfe emr65 lag2_intensity_new if ///
 inrange(year, 1992, 2002) & $sample_br & $sample_marg, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)

reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
 inrange(year, 1992, 2002) & $sample_br & $sample_marg, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)
   
 *BR but for the same time span as us: 1992-2006 (significant), still valid for short-term
reghdfe emr65 lag2_intensity_new if ///
inrange(year, 1992, 2006) & $sample_br , a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)

*BR but for the same time span as us and with weights (no significant)
reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)

*same as before but now only for highly marginalized (significant)
reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
 inrange(year, 1992, 2006) & $sample_br & $sample_marg, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)
 
*1999 interaction + weights 1992 - 2006 
 reghdfe emr65 c.inten1999#i.post if ///
inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
 reghdfe emr65 c.inten1999#i.post [aw=popover65_] if ///
inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

reghdfe emr65 c.inten1999#i.post c.inten2002#i.post [aw=popover65_] if ///
inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)


*results are sensitive and smaller
 reghdfe emr65 c.inten1999##ib6.year_1995   [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
 


