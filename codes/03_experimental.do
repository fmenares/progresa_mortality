*************************************************************************
* PROJECT :         Estimating Progresa effects for aging 
* AUTHOR :          Susan Parker
* MODIFIED BY :		
* PURPOSE :         Use constructed 1997-2017 panel to construct short 
*					panel.
					
*************************************************************************

*****************
*Set directories*
*****************

set more off
clear all

*------------------------------------------------------------
* Packages (run once if needed)
*------------------------------------------------------------
cap which reghdfe
if _rc {
    ssc install reghdfe, replace
}
cap which ftools
if _rc {
    ssc install ftools, replace
}
cap which esttab
if _rc {
    ssc install estout, replace
}


// set root:

if "`c(username)'" == "swparker" {
	local root "/Users/swparker/Dropbox/PROJECTS_CURRENT\Aging_Progresa" 
}

global dataFolder "`root'/ENCASEH_ENCEL_PROGRESA/"
global tempFolder "`root'/Temp"
global resultsFolder "`root'/Results"

cap mkdir "$resultsFolder"

****************
*Read locality level data*
****************
/*
use "$dataFolder/Bases97_03/Community\bd_rur_1998_m_localidad_2006-01-05\bd_rur_1998_m_localidad.dta"
    

gen cve_ent=entidad
gen cve_mun=mpio
gen cve_loc=local


// just keep locality prices 

keep p0101-p3701 cve_ent cve_mun cve_loc
sort cve_ent cve_mun cve_loc

save "$dataFolder\Bases97_03\Community\bd_rur_1998_m_localidad_2006-01-05\bd_rur_1998_m_localidad.dta", replace
*/

*Read panel, select early rounds*
****************
clear

use "$dataFolder/Panel1997_2017/Panel ENCEL 1997-2017 V2 0611.dta", replace

***Characteristics of the HH head****
* Age, education, occupation, ethnicity, gender, marital status*


keep if ronda==1 
gen yrs_edu=0 if nivel==1 | ido_esc==2
replace yrs_edu=1 if nivel==2 & grado==1
replace yrs_edu= 2 if nivel==2 & grado==2
replace yrs_edu=3 if nivel==2 & grado==3
replace yrs_edu=4 if nivel==2 & grado==4
replace yrs_edu=5 if nivel==2 & grado==5
replace yrs_edu=6 if nivel==2 & grado==6
replace yrs_edu=7 if nivel==3 & grado==1
replace yrs_edu=8 if nivel==3 & grado==2
replace yrs_edu=9 if nivel==3 & grado==3
replace yrs_edu=10 if (nivel==4 | nivel==5) & grado==1
replace yrs_edu=11 if (nivel==4 | nivel==5) & grado==2
replace yrs_edu=12 if (nivel==4 | nivel==5) & grado==3
replace yrs_edu=13 if nivel==7 & grado==1
replace yrs_edu=14 if nivel==7 & grado==2
replace yrs_edu=15 if nivel==7 & grado==3
replace yrs_edu=16 if nivel==7 & grado>=4
replace yrs_edu=17 if nivel==8 & grado==1
label var yrs_edu "Grades of completed schooling"

gen hh_educ=yrs_edu if renglon==1
gen hh_age=edad if renglon==1
replace hh_age=. if renglon==1 & hh_age>97

gen hh_gender=sexo if renglon==1
replace hh_gender=. if hh_gender==9

gen hh_indig=dialect if renglon==1
replace hh_indig=. if dialect==9

gen hh_married=0 if edo_civ~=9
replace hh_married=1 if edo_civ==1 | edo_civ==2

keep if renglon==1
keep folio renglon hh_educ hh_age hh_gender hh_indig hh_married
sort folio renglon
save "$tempFolder/HH_char", replace
clear

use "$dataFolder/Panel1997_2017/Panel ENCEL 1997-2017 V2 0611.dta", replace

// keep baseline, fall 1998 and fall 1999 
tab ronda
keep if ronda==1 |ronda==3 |ronda==5

// keep only variables from these first three rounds, delete all variables which only have missing values

missings dropvars, force

//keep only original households/individuals in 1997, exclude new HH and individuals arriving later 
//most are new infants, low folios used for new households

gen double folio_idper97=folio_idper if ronda==1
egen double idper97=mean(folio_idper97), by(folio_idper)
drop folio_idper97
gen newindiv=1 if folio_idper~=idper97
drop if newindiv==1
drop newindiv

//merge in locality level info on schools and wages
sort cve_ent cve_mun cve_loc
merge cve_ent cve_mun cve_loc using "$dataFolder/Bases97_03/Community/bd_rur_1998_m_localidad_2006-01-05\bd_rur_1998_m_localidad.dta"


//all merge
drop _merge


****************

*Create education variables

//construct education level 

gen yrs_edu=0 if nivel==1 | ido_esc==2
replace yrs_edu=1 if nivel==2 & grado==1
replace yrs_edu= 2 if nivel==2 & grado==2
replace yrs_edu=3 if nivel==2 & grado==3
replace yrs_edu=4 if nivel==2 & grado==4
replace yrs_edu=5 if nivel==2 & grado==5
replace yrs_edu=6 if nivel==2 & grado==6
replace yrs_edu=7 if nivel==3 & grado==1
replace yrs_edu=8 if nivel==3 & grado==2
replace yrs_edu=9 if nivel==3 & grado==3
replace yrs_edu=10 if (nivel==4 | nivel==5) & grado==1
replace yrs_edu=11 if (nivel==4 | nivel==5) & grado==2
replace yrs_edu=12 if (nivel==4 | nivel==5) & grado==3
replace yrs_edu=13 if nivel==7 & grado==1
replace yrs_edu=14 if nivel==7 & grado==2
replace yrs_edu=15 if nivel==7 & grado==3
replace yrs_edu=16 if nivel==7 & grado>=4
replace yrs_edu=17 if nivel==8 & grado==1
label var yrs_edu "Grades of completed schooling"
egen educ=mean(yrs_edu), by (folio idper)

egen gender=mean(sexo), by (folio_idper) 
label variable gender "Gender M=1 F=2"


gen enrolled=asis_esc 
replace enrolled=0 if asis_esc==2
replace enrolled=. if asis_esc==9
label variable enrolled "Currently attends =1, doesn't attend=0"

gen ever_enrolled=ido_esc
replace ever_enrolled=0 if ido_esc==2
replace ever_enrolled=. if ido_esc==9
label variable ever_enrolled "Ever attended=1, no=0"

//Treatment and eligibility variables
gen treatment=contba
replace contba=0 if contba==2
label variable treatment "Treatment or control community"

egen eligible=mean(pobre), by (folio)
label variable eligible "Eligible for program"

gen state=cve_ent
label variable state "State of residence"

//community prices
gen p_tomato=p0101
gen p_onions=p0201
gen p_rice=p1601
gen p_tortilla=p1701
gen p_chicken=p2001
gen p_oranges=p0501
gen p_corn=p1101
gen p_whitebread=p1201
gen p_beans=p2601
gen p_eggs=p2701
gen p_leafyveg=p0901

//generate grant family would receive if student enrolled in school by round of survey
//only children who have between 2 and 8 years of completed schooling eligible to receive grant

//1997
gen student_grant=0 if yrs_edu==2 & edad<=18 & ronda==1
replace student_grant=0 if yrs_edu==3 & edad<=18 & ronda==1
replace student_grant=0 if yrs_edu==4 & edad<=18 & ronda==1
replace student_grant=0 if yrs_edu==5 & edad<=18 & ronda==1

replace student_grant=0 if yrs_edu==6 & edad<=18 & gender==1 & ronda==1
replace student_grant=0 if yrs_edu==7 & edad<=18 & gender==1 & ronda==1
replace student_grant=0 if yrs_edu==8 & edad<=18 & gender==1 & ronda==1
replace student_grant=0 if yrs_edu==6 & edad<=18 & gender==2 & ronda==1
replace student_grant=0 if yrs_edu==7 & edad<=18 & gender==2 & ronda==1
replace student_grant=0 if yrs_edu==8 & edad<=18 & gender==2 & ronda==1


//1998
replace student_grant=60 if yrs_edu==2 & edad<=18 & ronda==3
replace student_grant=70 if yrs_edu==3 & edad<=18 & ronda==3
replace student_grant=90 if yrs_edu==4 & edad<=18 & ronda==3
replace student_grant=120 if yrs_edu==5 & edad<=18 & ronda==3

replace student_grant=175 if yrs_edu==6 & edad<=18 & gender==1 & ronda==3
replace student_grant=185 if yrs_edu==7 & edad<=18 & gender==1 & ronda==3
replace student_grant=195 if yrs_edu==8 & edad<=18 & gender==1 & ronda==3
replace student_grant=185 if yrs_edu==6 & edad<=18 & gender==2 & ronda==3
replace student_grant=205 if yrs_edu==7 & edad<=18 & gender==2 & ronda==3
replace student_grant=225 if yrs_edu==8 & edad<=18 & gender==2 & ronda==3

//1999
replace student_grant=75 if yrs_edu==2 & edad<=18 & ronda==5
replace student_grant=90 if yrs_edu==3 & edad<=18 & ronda==5
replace student_grant=115 if yrs_edu==4 & edad<=18 & ronda==5
replace student_grant=150 if yrs_edu==5 & edad<=18 & ronda==5

replace student_grant=220 if yrs_edu==6 & edad<=18 & gender==1 & ronda==5
replace student_grant=235 if yrs_edu==7 & edad<=18 & gender==1 & ronda==5
replace student_grant=245 if yrs_edu==8 & edad<=18 & gender==1 & ronda==5
replace student_grant=235 if yrs_edu==6 & edad<=18 & gender==2 & ronda==5
replace student_grant=260 if yrs_edu==7 & edad<=18 & gender==2 & ronda==5
replace student_grant=285 if yrs_edu==8 & edad<=18 & gender==2 & ronda==5

label variable student_grant "Grant if enrolled and in treatment/eligible"

//construct individual and total monthly household income
//recode missing values

gen work=1 if con_tra==1 | con_tra==2 | con_tra==3
replace work=0 if con_tra==4

replace work=1 if veri_tra==1 | veri_tra==2 | veri_tra==3 | veri_tra==4 | veri_tra==5
label var work "Working"

gen days_week=0 if work~=. 
replace days_week=dia_tra if dia_tra>=1 & dia_tra<=7 & dia_tra~=.
replace days_week=. if dia_tra==9

gen hours_day=0 if work~=.
replace hours_day=hor_tra if hor_tra~=.
replace hours_day=. if hor_tra==99

gen weekly_hours=days_week*hours_day


gen salaried=0 if work~=.
replace salaried=1 if pos_ocu==4 | pos_ocu==6
replace salaried=. if pos_ocu==99 

* Many missing values for income variable *

replace mont_gtra=. if mont_gtra>98000
gen ing_indiv=mont_gtra*30 if peri_gtra==1
replace ing_indiv=mont_gtra*4.3 if peri_gtra==2
replace ing_indiv=mont_gtra*2 if peri_gtra==3
replace ing_indiv=mont_gtra if peri_gtra==4
replace ing_indiv=mont_gtra/12 if peri_gtra==5
replace ing_indiv=0 if work==0
replace ing_indiv=0 if mont_gtra==0
label variable ing_indiv "Monthly labor income"

gen adult_ing=ing_indiv if edad>=21
egen ing_hh=sum(adult_ing), by (folio ronda)
gen aging_ing=ing_indiv if edad>=65

drop adult_ing
label variable ing_hh "HH adult labor income"

//agric variables
 
 
 gen land=n_pred
 replace land=1 if n_pred~=0
 label variable land "HH owns or uses land"
 
 gen owns_animals=tene_anim if tene_anim~=9
 replace owns_animals=0 if tene_anim==2
 egen own_animals97=mean(owns_animals), by (folio)
 drop owns_animals
 label variable own_animals97 "HH owns agric animals in 97"
 
 //demographic 
 gen age=edad
 label variable age "Age in years"
 
 egen pid = group(folio renglon)

 
 gen age65=1 if age>=65
 
 gen age65_97=1 if age>=65 & ronda==1
 
 bys pid: egen age97 = max(cond(ronda==1, age, .))
 
 gen age05=1 if age>=0 & age<=5
 gen age611=1 if age>=6 & age<=11
 gen age1218=1 if age>=12 & age<=18
 
 egen kids05=sum(age05), by (folio ronda)
 egen kids611=sum(age611), by (folio ronda)
 egen kids1218=sum(age1218), by (folio ronda)
 egen aging65=sum(age65), by (folio ronda)
 drop age05 age611 age1218 age65
 
 label variable kids05 "Kids 0-5 in HH"
 label variable kids611 "Kids 6-11 in HH"
 label variable kids1218 "Kids 12-18 in HH"
 label variable aging65  "Indiv +65 in HH"
 
 gen hhsize=son_per
 label variable hhsize "HH size"
 
 bys folio ronda: egen n_adults = total(inrange(age,18,60))
 bys folio ronda: egen n_elderly = total(age >=60)
 bys folio ronda: egen n_children = total(age < 18)
 
 gen live_alone = hhsize==1
 gen with_children = n_children>0
 gen with_adults = n_adults>0
 gen multigen = (n_elderly>0 & n_adults>0 & n_children>0)
 gen only_elderly=(n_adults==0 & n_children==0)
 
 gen hhid=folio
 label variable hhid "Household ID"
 gen persid=idper
 label variable persid "Person # in HH"
 
gen year=97 if ronda==1
replace year=98 if ronda==3
replace year=99 if ronda==5
label variable year "Year of interview"

foreach var of varlist difi6_act act_vig act_mode kil_cam enf6_4se rec_ate per6_dia no6_act dias6_cam {
    replace `var' = . if `var' >= 99
}
foreach var of varlist act_vig act_mode enf6_4se {
    replace `var' = . if `var' == 9
}

gen post=1 if year==98 | year==99
replace post=0 if year==97

egen claveofi = group(cve_ent cve_mun cve_loc), label
egen clavemun = group(cve_ent cve_mun), label
sort folio

merge m:1 folio using "$tempFolder/HH_char" 

*need descriptive table here on treatment comparisons pre program for elderly individuals*
ssc install ietoolkit, replace

label variable work       "Worked"
label variable days_week  "Days worked per week"
label variable hours_day  "Hours worked per day"
label variable live_alone "Lives alone"
label variable weekly_hours "Hours worked weekly"

label variable live_alone "Lives alone"



local balvars work days_week hours_day live_alone

iebaltab `balvars' ///
    if age97>=65, ///
    grpvar(contba) ///
    vce(cluster claveofi) ///
    rowvarlabels ///
    savecsv("$resultsFolder/elderly_balance.csv") replace

iebaltab work days_week hours_day live_alone ///
    if age97>=65, ///
    groupvar(contba) control(0) ///
    vce(cluster claveofi) ///
    rowvarlabels ///
    stats(pair(diff)) ///
    savexlsx("$resultsFolder/elderly_balance.xlsx") replace


*------------------------------------------------------------
* INDIVIDUAL-LEVEL RESULTS (elderly sample: age97>=65)
* Store estimates and export a clean table focused on Progresa effects
*------------------------------------------------------------

cap which eststo
if _rc {
    * eststo comes with estout (installed above)
}

eststo clear

* Outcomes to report (elderly individuals)
local indiv_outcomes work days_week hours_day weekly_hours
local living live_alone with_children only_elderly

*men*
preserve
keep if gender==1 & age97>=65 
* Run DiD/event-study: year FE interacted with treatment
foreach yvar of local indiv_outcomes {

    * Control mean in 1997 (control localities), matching the estimation sample
    quietly summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    quietly reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    quietly summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    quietly reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig
}


* Export (RTF opens nicely in Word)
* Keep only Progresa treatment effects in 1998 and 1999 relative to 1997
esttab work_all work_elig ///
      days_week_all days_week_elig ///
	   hours_day_all hours_day_elig ///
       weekly_hours_all weekly_hours_elig ///
       using "$resultsFolder/progresa_elderly_individual_outcomes_male.rtf", replace ///
    title("Progresa impacts on male elderly individuals (age 65+ in 1997)") ///
    keep(98.year#1.contba 99.year#1.contba) ///
    order(98.year#1.contba 99.year#1.contba) ///
    coeflabels(98.year#1.contba "Treatment x 1998" ///
               99.year#1.contba "Treatment x 1999") ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N cmean97, fmt(%9.0g %9.3f) labels("Observations" "Control mean (1997)")) ///
    compress
	
	
	foreach yvar of local living {

    * Control mean in 1997 (control localities), matching the estimation sample
    quietly summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    quietly reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    quietly summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    quietly reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig
}


* Export (RTF opens nicely in Word)
* Keep only Progresa treatment effects in 1998 and 1999 relative to 1997
esttab live_alone_all live_alone_elig ///
	   with_children_all with_children_elig ///
       only_elderly_all only_elderly_elig ///
       using "$resultsFolder/progresa_elderly_living_outcomes_male.rtf", replace ///
    title("Progresa impacts on male elderly individuals (age 65+ in 1997)") ///
    keep(98.year#1.contba 99.year#1.contba) ///
    order(98.year#1.contba 99.year#1.contba) ///
    coeflabels(98.year#1.contba "Treatment x 1998" ///
               99.year#1.contba "Treatment x 1999") ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N cmean97, fmt(%9.0g %9.3f) labels("Observations" "Control mean (1997)")) ///
    compress
	
	
*women*
restore
preserve
keep if gender==2 & age97>=65
* Run DiD/event-study: year FE interacted with treatment
foreach yvar of local indiv_outcomes {

    * Control mean in 1997 (control localities), matching the estimation sample
    quietly summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    quietly reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    quietly summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    quietly reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig
}


* Export 
* Keep only Progresa treatment effects in 1998 and 1999 relative to 1997
esttab work_all work_elig ///
      days_week_all days_week_elig ///
	   hours_day_all hours_day_elig ///
     weekly_hours_all weekly_hours_elig ///
       using "$resultsFolder/progresa_elderly_individual_outcomes_female.rtf", replace ///
    title("Progresa impacts on female elderly individuals (age 65+ in 1997)") ///
    keep(98.year#1.contba 99.year#1.contba) ///
    order(98.year#1.contba 99.year#1.contba) ///
    coeflabels(98.year#1.contba "Treatment x 1998" ///
               99.year#1.contba "Treatment x 1999") ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N cmean97, fmt(%9.0g %9.3f) labels("Observations" "Control mean (1997)")) ///
    compress
	
	
	foreach yvar of local living {

    * Control mean in 1997 (control localities), matching the estimation sample
    quietly summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    quietly reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    quietly summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    quietly reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig
}


* Export (RTF opens nicely in Word)
* Keep only Progresa treatment effects in 1998 and 1999 relative to 1997
esttab live_alone_all live_alone_elig ///
    	   with_children_all with_children_elig ///
      only_elderly_all only_elderly_elig ///
       using "$resultsFolder/progresa_elderly_living_outcomes_female.rtf", replace ///
    title("Progresa impacts on male elderly individuals (age 65+ in 1997)") ///
    keep(98.year#1.contba 99.year#1.contba) ///
    order(98.year#1.contba 99.year#1.contba) ///
    coeflabels(98.year#1.contba "Treatment x 1998" ///
               99.year#1.contba "Treatment x 1999") ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N cmean97, fmt(%9.0g %9.3f) labels("Observations" "Control mean (1997)")) ///
    compress
	
	

restore

**Household level analysis**
**collapse to household level**
** distinguish between households with aging members and households without**
**also by hh just composied of aging members as they should control expenditure versus other hh**
**or where aging is head of hh*

* maybe check if where elderly live changes with the program* 

**HH expenditures**

*don't have these variables in 97*
* food and medicines *

mvdecode gas*, mv(9888)
mvdecode gas*, mv(999)

egen total_gas = rowtotal(gas*)
replace total_gas=total_gas-gasto

gen food=ln(gast_comi+1)
gen medicine=ln(gasta_med+1) 
gen porc_food=gast_comi/total_gas
gen porc_med=gasta_med/total_gas


gen food98=food if year==98
gen food99=food if year==99
gen medicine98=medicine if year==98
gen medicine99=medicine if year==99

gen porc_food98=porc_food if year==98
gen porc_food99=porc_food if year==99
gen porc_med98=porc_med if year==98
gen porc_med99=porc_med if year==99


gen hh_elderly=1 if hh_age>=65
replace hh_elderly=0 if hh_age<=64

gen elderly97=1 if age97>=65
replace elderly97=0 if age97<65

collapse (mean) total_gas food food98 food99 porc_food* porc_med* medicine medicine98 medicine99 p_* contba hhsize kid* eligible  clavemun claveofi hh_* (sum) elderly97, by(hhid year)
replace elderly97=1 if elderly97>1

local balvars food porc_food medicine porc_med 

iebaltab `balvars' ///
    , ///
    grpvar(contba) ///
    vce(cluster claveofi) ///
    rowvarlabels ///
    savecsv("$resultsFolder/balance_HH.csv") replace

iebaltab `balvars' ///
    if elderly97>=1, ///
    grpvar(contba) ///
    vce(cluster claveofi) ///
    rowvarlabels ///
    savecsv("$resultsFolder/elderly_balance_HH.csv") replace
*------------------------------------------------------------
* HOUSEHOLD-LEVEL RESULTS (expenditures)
* Store estimates and export clean tables focused on Progresa effects
*------------------------------------------------------------

eststo clear
drop if year==97

local hh_outcomes food porc_food medicine porc_med
foreach yvar of local hh_outcomes {

    * Control mean in 1998 (control localities), matching the estimation sample
     summarize `yvar' if year==98 & contba==0 & !missing(`yvar', year, contba, hhid, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, hhid, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    quietly summarize `yvar' if year==98 & contba==0 & eligible==1 & !missing(`yvar', year, contba, hhid, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, hhid, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig

    * Control mean in 1997 for heterogeneity regression (same as full sample)
    * (reported as the overall control mean in 1997; the heterogeneity coefficients are differences relative to this baseline)
     summarize `yvar' if year==98 & contba==0 & !missing(`yvar', year, contba, elderly97, hhid, claveofi)
    local cmean97_het = r(mean)

    * Heterogeneity: households with elderly (elderly97) vs without
     reghdfe `yvar' i.year##i.contba##i.elderly97 ///
        if !missing(`yvar', year, contba, elderly97, hhid, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_het'
    eststo `yvar'_het

    * Control mean in 1997 for eligible households (heterogeneity regression)
     summarize `yvar' if year==98 & contba==0 & eligible==1 & !missing(`yvar', year, contba, elderly97, hhid, claveofi)
    local cmean97_hetelig = r(mean)

     reghdfe `yvar' i.year##i.contba##i.elderly97 ///
        if eligible==1 & !missing(`yvar', year, contba, elderly97, hhid, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_hetelig'
    eststo `yvar'_hetelig
}


* Table 1: main effects (full vs eligible)
esttab food_all food_elig medicine_all medicine_elig ///
       porc_food_all porc_food_elig porc_med_all porc_med_elig ///
    using "$resultsFolder/progresa_household_expenditures_main.rtf", replace ///
    title("Progresa impacts on household expenditures") ///
    keep(98.year#1.contba 99.year#1.contba) ///
    order(98.year#1.contba 99.year#1.contba) ///
    coeflabels(98.year#1.contba "Treatment x 1998" ///
               99.year#1.contba "Treatment x 1999") ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N cmean97, fmt(%9.0g %9.3f) labels("Observations" "Control mean (1997)")) ///
    compress
	
* Table 2: heterogeneity by baseline elderly presence
* Keep both the main treatment-year effects and the DDD terms (treatment-year x elderly97)
esttab food_het food_hetelig medicine_het medicine_hetelig ///
       porc_food_het porc_food_hetelig porc_med_het porc_med_hetelig ///
    using "$resultsFolder/progresa_household_expenditures_elderlyhet.rtf", replace ///
    title("Progresa impacts on household expenditures: heterogeneity by elderly presence (baseline)") ///
    keep(99.year#1.contba 99.year#1.contba#1.elderly97) ///
    order(99.year#1.contba 99.year#1.contba#1.elderly97) ///
    coeflabels(99.year#1.contba "Treatment x 1999 (no elderly)" ///
               99.year#1.contba#1.elderly97 "Diff: elderly hh x 1999") ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N cmean97, fmt(%9.0g %9.3f) labels("Observations" "Control mean (1997)")) ///
    compress




/*


//keep databases with all ages and all variables including new ones created

save "`root'/Temp/aging_experiment", replace

