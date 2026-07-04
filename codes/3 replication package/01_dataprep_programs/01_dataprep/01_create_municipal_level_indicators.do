clear
set more off

/*THIS PROGRAM CREATES 3 MUNICIPAL DATA SETS TO BE MERGED TO INDIVIDUAL CENSUS 1990 2000 and 2010
1. Prospera program beneficiaries file
2. Number of HH in municipality 1990 and 2000 for denominator of program intensity
3. Municipality level poverty characteristics

Also creates equivalent state level files for 2010-for migrants where we don't know municipality preprogram*/

/*FIRST FILE Construct Prospera program beneficiaries using admin file from Prospera
Aggregate locality level Prospera data to municipal level*/

use "$data/01_dataprep/fams_fase_20134xloc_f.dta"
sort CVE_EDO CVE_MUN CVE_LOC

*** DEFINE BENEFICIARY IN EACH YEAR BASED ON FASES**

gen benef1996=0
egen benef1997=rowtotal(FASE_1-FASE_2)
egen benef1998=rowtotal(FASE_3-FASE_6)
egen benef1999=rowtotal(FASE_7-FASE_10)
egen benef2000=rowtotal(FASE_11-FASE_12)
egen benef2001=rowtotal(FASE_13-FASE_15)
egen benef2002=rowtotal(FASE_16-FASE_17)
egen benef2003=rowtotal(FASE_18-FASE_19)
egen benef2004=rowtotal(FASE_20-FASE_23)
egen benef2005=rowtotal(FASE_24-FASE_25)
egen benef2006=rowtotal(FASE_26-FASE_28)
egen benef2007=rowtotal(FASE_29-FASE_32)
egen benef2008=rowtotal(FASE_33-FASE_35)
egen benef2009=rowtotal(FASE_38-FASE_39)
egen benef2010=rowtotal(FASE_40-FASE_42)
egen benef2011=rowtotal(FASE_44-FASE_47)
egen benef2012=rowtotal(FASE_48-FASE_50)

gen cum1996=0
forvalues i=1997/2012 {
  local j = `i'-1
  gen cum`i' = cum`j'+benef`i'
  }

gen onset_year=.
forvalues i=1997/2012 {
  local k = `i'-1
  replace onset_year = `i' if cum`k'==0&cum`i'>0
  }
tab onset_year,miss //missing values indicate no benefits by 2012

gen benef9799=benef1997+benef1998+benef1999
gen benef0005=benef2000+benef2001+benef2002+benef2003+benef2004+benef2005
gen benef9705=benef9799+benef0005
gen benef0005_new=(benef2000+benef2001+benef2002+benef2003+benef2004+benef2005)*(onset_year>1999)

*** convert to master munis

do "$programs/01_dataprep/master_munis.do" 
  
*** generate municipal and state level data****

collapse (sum) benef9799 benef9705 benef0005 benef0005_new (count) numloc = claveofi ///
         (p25) onset_25 = onset_year (p50) onset_50 = onset_year (p75) onset_75 = onset_year ///
		 (min) onset_min = onset_year, by (CVE_EDO CVE_MUN)
 
la var benef9799 "Total mun benef 1997-1999"
la var benef9705 "Total mun benef 1997-2005"
la var benef0005 "Total mun benef 2000-2005"
la var benef0005_new "Total mun benef 2000-2005 in new localities"
la var numloc "Number of Progresa localities"
la var onset_25 "25th %ile of locality onset year"
la var onset_50 "50th %ile of locality onset year"
la var onset_75 "75th %ile of locality onset year"
la var onset_min "earliest locality onset year"

rename CVE_EDO CVE_EDO_PRE
rename CVE_MUN CVE_MUN_PRE
sort CVE_EDO_PRE CVE_MUN_PRE
save "$tempdata/fams_beneficiary_mun.dta", replace

*create state level file of early beneficiaries
/*drop benef1997-benef2001*/
collapse  (sum) /*pot*/ benef*, by (CVE_EDO_PRE)
rename benef9799 benef9799_state
rename benef9705 benef9705_state
la var benef9799_state "Total State Benef 1997-1999"
keep benef* CVE_EDO_PRE
ren CVE_EDO_PRE edo_born /*will merge to state of birth*/
sort edo_born
save "$tempdata/fams_beneficiary_mun_state.dta", replace

/*SECOND FILE-CREATE 1990 AND 2000 Number of HH per municipality for denominator of program intensity*/

use "$data/01_dataprep/Censo_hogares_1990_downloaded_INEGI.dta"
gen EDO= substr(C1,1,2)
gen CVE_EDO=real(EDO)
gen MUN= substr(C1,4,3)
gen CVE_MUN=real(MUN)
gen hog1990=Total
keep CVE_EDO CVE_MUN hog1990
drop if CVE_EDO==.
do "$programs/01_dataprep/master_munis.do" 
collapse (sum) hog1990,by(CVE_EDO CVE_MUN)
rename CVE_EDO CVE_EDO_PRE
rename CVE_MUN CVE_MUN_PRE
sort CVE_EDO_PRE CVE_MUN_PRE
save "$tempdata/Censo_hogares_1990.dta", replace

use "$data/01_dataprep/Censo_hogares_2000_downloaded_INEGI.dta"
gen EDO= substr(clave,1,2)
gen CVE_EDO=real(EDO)
gen MUN= substr(clave,4,3)
gen CVE_MUN=real(MUN)
drop if CVE_EDO==.
gen hog2000=Total
keep CVE_EDO CVE_MUN hog2000 
do "$programs/01_dataprep/master_munis.do" 
collapse (sum) hog2000,by(CVE_EDO CVE_MUN)
rename CVE_EDO CVE_EDO_PRE
rename CVE_MUN CVE_MUN_PRE
sort CVE_EDO_PRE CVE_MUN_PRE
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/Censo_hogares_1990.dta"
list if _merge<3
//note: none of these can be found in INEGI's pdf lists of municipality creation/absorption
drop _merge
la var hog1990 "Total Mun HH 1990"
la var hog2000 "Total Mun HH 2000"
sort CVE_EDO_PRE CVE_MUN_PRE
save "$tempdata/Censo_hogares_1990_2000.dta", replace

collapse (sum) hog1990 (sum) hog2000, by (CVE_EDO_PRE)
rename hog1990 hog1990_state
rename hog2000 hog2000_state
la var hog1990_state "Total State HH 1990"
la var hog2000_state "Total State HH 2000"
drop if CVE_EDO_PRE==.
ren CVE_EDO_PRE edo_born /*will merge to state of birth*/
sort edo_born
save "$tempdata/Censo_hogares_1990_2000_state.dta", replace

/*THIRD FILE-proportional change in overall cohort size from 1990 to 2005*/
clear
quietly infix                 ///
  int     year         4-7    ///
  int     geo1_mx1990  37-39  ///
  int     geo1_mx2005  40-42  ///
  long    geo2_mx1990  43-48  ///
  long    geo2_mx2005  49-54  ///
  int     pernum       55-58  ///
  double  perwt        59-66  ///
  int     age          67-69  ///
  using "$data/01_dataprep/ipumsi_00068.dat"
gen yob = year-age if age<999 //define year of birth
keep if yob>=1977&yob<=1988 //sample cohorts
replace perwt = perwt/100 //adjust decimals
tab year perwt //both years are 10% samples
tab yob year,row //older cohorts shrink bet censuses (migration?), younger cohorts do not 
preserve
*1990 counts
keep if year==1990
ren geo1_mx1990 CVE_EDO
ren geo2_mx1990 CVE_MUN
replace CVE_MUN = mod(CVE_MUN,1000) //take of two digit state code
do "$programs/01_dataprep/master_munis.do" //use master muni codes
collapse (sum) pop1990=perwt,by(CVE_EDO CVE_MUN) //population estimates
ren CVE_EDO CVE_EDO_PRE
ren CVE_MUN CVE_MUN_PRE
save "$tempdata/changepop.dta", replace
*2005 counts
restore
keep if year==2005
ren geo1_mx2005 CVE_EDO
ren geo2_mx2005 CVE_MUN
replace CVE_MUN = mod(CVE_MUN,1000) //take of two digit state code
do "$programs/01_dataprep/master_munis.do" //use master muni codes
collapse (sum) pop2005=perwt,by(CVE_EDO CVE_MUN) //population estimates
ren CVE_EDO CVE_EDO_PRE
ren CVE_MUN CVE_MUN_PRE
*merge estimated populations
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/changepop.dta"
gen g_pop = (pop2005-pop1990)/pop1990
label var g_pop "Growth in sample cohort municipal population, 1990-05"
drop pop* _merge
*save
save "$tempdata/changepop.dta", replace

/*FOURTH FILE rise in homicides from 2006-2010 (use 2010 population for rates*)*/

insheet using "$data/01_dataprep/Homicidios_1990_2015_INEGI.csv",clear names
replace homicides2010 = 0 if homicides2010==.&name!=""
replace homicides2007 = 0 if homicides2007==.&name!=""
gen d_homicide = homicides2010-homicides2007
gen CVE_MUN = mod(cve_mun,1000)
gen CVE_EDO = floor(cve_mun/1000)
keep if mod(cve_mun,1000)!=0 /*drop state and nat'l level obs, keep muni obs*/
drop if name=="No especificado"
keep name CVE* d_homicide
save "$tempdata/homicides.dta", replace
insheet using "$data/01_dataprep/censo_2010_INEGI.csv",clear names /*locality population data*/
keep if mun!=0
ren entidad CVE_EDO
ren mun CVE_MUN
collapse (sum) pobtot,by(CVE_EDO CVE_MUN nom_mun)
merge 1:1 CVE_EDO CVE_MUN using "$tempdata/homicides.dta"
tab name _merge if _merge==2
replace pobtot = 32759 if name=="Bacalar" /*from census website*/
drop if _merge==2&name!="Bacalar"
tab nom_mun _merge if _merge==1 /*these had no homicides*/
replace d_homicide = 0 if d_homicide==.
drop _merge
do "$programs/01_dataprep/master_munis.do" 
collapse (sum) d_homicide pobtot,by(CVE_EDO CVE_MUN)
replace d_homicide = 100000*(d_homicide/pobtot)
drop pobtot
label var d_homicide "Change in homicide rate per 100k, 2006-10"
ren CVE_MUN CVE_MUN_PRE
ren CVE_EDO CVE_EDO_PRE
save "$tempdata/homicides.dta", replace

/*FIFTH FILE data on school construction (use 2000 population for rates)*/

use "$data/01_dataprep/Schools_1990_2010.dta",clear
ren id_municipio CVE_MUN
ren id_estado CVE_EDO
do "$programs/01_dataprep/master_munis.do" 
collapse (sum) secundaria*,by(CVE_MUN CVE_EDO)
drop if CVE_MUN==.
gen secundaria_95 = secundaria95
gen d_secundaria_9500 = secundaria00-secundaria95
gen d_secundaria_9505 = secundaria05-secundaria95
keep secundaria_95 d_* CVE_*
save "$tempdata/schools.dta", replace
insheet using "$data/01_dataprep/censo_2010_INEGI.csv",clear
drop if entidad==0
gen pob1517=p15a17a /*Susan added this line in replication process*/
replace pob1517 = "" if pob1517=="N/D"
replace pob1517 = "" if pob1517=="*" /* Susan added this line in replication process otherwise variable did not destring*/
destring pob1517,replace
ren mun CVE_MUN
ren entidad CVE_EDO /* Susan changed edo to entidad in replication process*/
do "$programs/01_dataprep/master_munis.do" 
collapse (sum) pob1517,by(CVE_MUN CVE_EDO)
merge 1:1 CVE_EDO CVE_MUN using "$tempdata/schools.dta"
drop if _merge<3
drop _merge
replace secundaria_95 = 100000*(secundaria_95/pob1517)
replace d_secundaria_9500 = 100000*(d_secundaria_9500/pob1517)
replace d_secundaria_9505 = 100000*(d_secundaria_9505/pob1517)
label var secundaria_95 "Secondary schools per 100k aged 15-17, 1995"
label var d_secundaria_9500 "Secondary schools built per 100k aged 15-17, 1995-2000"
label var d_secundaria_9505 "Secondary schools built per 100k aged 15-17, 1995-2005"
ren CVE_MUN CVE_MUN_PRE
ren CVE_EDO CVE_EDO_PRE
save "$tempdata/schools.dta", replace

/*SIXTH FILE: 1994 election outcomes*/
use "$data/01_dataprep/Presidente1994Seccion_municipio.dta",clear
ren ID_ESTADO CVE_EDO
ren ID_MUNICIPIO CVE_MUN
do "$programs/01_dataprep/master_munis.do" 
collapse (sum) PRI TOTAL_VOTOS NUM_VOTOS_NULOS,by(CVE_MUN CVE_EDO)
gen pri94 = PRI/(TOTAL_VOTOS-NUM_VOTOS_NULOS)
label var pri94 "PRI vote share in 1994 presidential election"
keep CVE* pri94
ren CVE_MUN CVE_MUN_PRE
ren CVE_EDO CVE_EDO_PRE
save "$tempdata/election.dta", replace

/*SEVENTH FILE data from CONAPO's municipality margination index***;
***will use to a) identify which municipalities pre program are marginated and b)have some control var pre program*/

use "$data/01_dataprep/Indice_marginacion_censo_new2.dta"

*** pre program margination index and its components***
keep if ano==1990
gen CVE_EDO=real(CVE_ENT)
drop CVE_MUN /*this is the 5 digit code that starts with the state*/
gen CVE_MUN=real(CVEE_MUN) /*this is the 3 digit code*/
drop CVE_ENT CVEE_MUN

gen marginado=1 if gm=="Muy alto" | gm=="Alto"
replace marginado=0 if gm~="Muy alto" & gm~="Alto"
gen pop=subinstr(POB_TOT," ","",.)
gen pobtot=real(pop)
gen pobtot_marg=pobtot if marginado==1

foreach var of varlist im analf ovsde ovsee ovsae ovpt PO2SM sprim vhac PL_5000 {
	gen d_`var'=real(`var') 
}

//thresholds between categoies
*old stata syntax: table gm,c(min d_im max d_im)
*new stata syntax: table gm,statistic(min d_im) statistic(max d_im)
keep d_* CVE* marginado pobtot*  

//master munis
do "$programs/01_dataprep/master_munis.do" 
collapse d_* marginado (rawsum) pobtot* [aw=pobtot],by(CVE_EDO CVE_MUN)

//marg. categories for master muni, using thresholds above
gen gm = 1 if d_im<=-1.59 
replace gm = 2 if gm==.&d_im<=-.5
replace gm = 3 if gm==.&d_im<=.044
replace gm = 4 if gm==.&d_im<=1.135
replace gm = 5 if gm==.
label define gm 1 "Muy bajo" 2 "Bajo" 3 "Medio" 4 "Alto" 5 "Muy alto"
label values gm gm

//marg. percentiles
egen margpct = cut(d_im),group(100)

//note that three combined municipalities have marginado between 0 and 1
//treat these as non-marginalized
tab marginado
replace marginado = 0 if marginado<1

//label vars
la var d_im "Margination index"
la var d_analf "Illiterate population"
la var d_ovsde "Without toilet"
la var d_ovsee "Without electricity"
la var d_ovsae "Without running water"
la var d_ovpt "With dirt floor"
la var d_PO2SM "Earning less than 2 min wage"
la var d_sprim "With primary education"
la var d_vhac "With crowding"
la var d_PL_5000 "In communities less than 5000"
la var pobtot "Total pop in mun"
la var marginado "All munis in master are high/v. high"
la var gm "Marginality level"
la var margpct "Marginality percentile"

rename CVE_EDO CVE_EDO_PRE
rename CVE_MUN CVE_MUN_PRE
sort CVE_EDO_PRE CVE_MUN_PRE
save "$tempdata/Indice_marginacion_1990.dta", replace

***create state level averages for the migrants where don't have pre program municipio***
collapse (rawsum) pobtot_marg (rawsum) pobtot (mean) state_d_im=d_im state_d_analf=d_analf state_d_ovsde=d_ovsde state_d_ovsee=d_ovsee state_d_ovsae=d_ovsae state_d_ovpt=d_ovpt state_d_PO2SM=d_PO2SM state_d_sprim=d_sprim state_d_vhac=d_vhac state_d_PL_5000=d_PL_5000 [aw=pobtot], by (CVE_EDO_PRE) /* replication Susan added _PRE to CVE_EDO*/
gen prop_marg_state=pobtot_marg/pobtot

la var state_d_im "Margination index_state"
la var state_d_analf "Illiterate population_state"
la var state_d_ovsde "Without toilet_state"
la var state_d_ovsee "Without electricity_state"
la var state_d_ovsae "Without running water_state"
la var state_d_ovpt "With dirt floor_state"
la var state_d_PO2SM "Earning less than 2 min wage_state"
la var state_d_sprim "With primary education"
la var state_d_vhac "With crowding"
la var state_d_PL_5000 "In communities less than 5000"
la var prop_marg_state "Prop in state living in marginated muni"
la var pobtot "Total pop in state"
drop pobtot_marg
ren CVE_EDO_PRE edo_born /*will merge to state of birth*/
sort edo_born
save "$tempdata/Indice_marginacion_1990_state.dta", replace

/*EIGHTH FILE locality-level marginality in 1995
**This was the input into Progresa rollout*/
use "$data/01_dataprep/Base_marginacion_localidad_1995.dta", clear
sum iml,d
bysort gml: sum iml //broad margination categories
/*
hist iml,scheme(plotplain) start(-2.6) w(.2) fraction ///
         xline(-1.2,lcolor(black) lpattern(solid)) /*early progresa cutoff*/ ///
		 xline(-1.59 -.61 .04) /*other cutoffs*/ ///
		 xtitle("1995 marginality index") ytitle("Fraction of localities")
*/		 
gen med_alt_muyalt = (gml=="Medio"|gml=="Alto"|gml=="Muy alto") 
gen alt_muyalt = (gml=="Alto"|gml=="Muy alto") 
gen muyalto = (gml=="Muy alto") 
gen alto = (gml=="Alto")
gen medio = (gml=="Medio")
gen bajo = (gml=="Bajo")
gen muybajo = (gml=="Muy bajo")
egen iml_pctile = cut(iml),group(100)
tab iml_pctile,gen(iml_pc)
drop iml_pctile
do "$programs/01_dataprep/master_munis.do" 
collapse med_alt_muyalt alt_muyalt muyalto alto medio bajo muybajo iml_pc* [aw=POB_TOT],by(CVE_EDO CVE_MUN)
rename CVE_EDO CVE_EDO_PRE
rename CVE_MUN CVE_MUN_PRE
save "$tempdata/Localidad_marginacion_1995.dta", replace

/*MERGE FILES TOGETHER TO HAVE 1 MUNICIPAL AND 1 STATE LEVEL FILE*/

*Municipal file
use "$tempdata/fams_beneficiary_mun.dta"
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/Censo_hogares_1990_2000.dta"
tab _merge
drop _merge
sort CVE_EDO_PRE CVE_MUN_PRE
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/Indice_marginacion_1990.dta"
tab _merge
drop _merge pobtot_marg
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/changepop.dta"
tab _merge
drop _merge
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/homicides.dta"
tab _merge
drop _merge
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/schools.dta"
tab _merge
drop _merge
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/election.dta"
tab _merge
drop _merge
merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/Localidad_marginacion_1995.dta"
tab _merge
drop _merge
//fill in municipalities with no program participation (only for muni codes with non-missing d_im) - note these are richer munis, so dropped from the main analysis anyway
foreach var of varlist benef* {
  replace `var' = 0 if `var'==.&d_im<.
  }
//Generate program impact indicators and prepare control variables
gen hog1997 = .3*hog1990 + .7*hog2000
gen prop9799_hog=(benef9799)/hog1997
gen prop9705_hog=(benef9705)/hog1997
la var prop9799_hog "Program intensity 97-99"
la var prop9705_hog "Program intensity 97-05" 

//keep sample with marginality index -- this drops some 2000 municiplity codes, so creates a coherent sample of 1990 municipalities
keep if d_im<.
sort CVE_EDO_PRE CVE_MUN_PRE
save "$tempdata/all_municipal_data_1990.dta", replace

*State file
use "$tempdata/fams_beneficiary_mun_state.dta"
merge 1:1 edo_born using "$tempdata/Censo_hogares_1990_2000_state.dta"
tab _merge
drop _merge
sort edo_born
merge 1:1 edo_born using "$tempdata/Indice_marginacion_1990_state.dta"
keep if _merge==3
drop _merge
//fill in states with no program participation
foreach var of varlist benef* {
  replace `var' = 0 if `var'==.
  }
//generate program impact indicators and prepare control variables
gen hog1997_state = .3*hog1990_state + .7*hog2000_state
gen prop9799_hog_state=(benef9799_state)/hog1997_state
gen prop9705_hog_state=(benef9705_state)/hog1997_state
la var prop9799_hog_state "Program intensity 97-99 - state avg"
la var prop9705_hog_state "Program intensity 97-05 - state avg"
//save
sort edo_born
save "$tempdata/all_state_data_1990.dta", replace

