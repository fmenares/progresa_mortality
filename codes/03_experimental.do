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
	global dataFolder "/Users/swparker/Dropbox/PROJECTS_CURRENT/Aging_Progresa/ENCASEH_ENCEL_PROGRESA/"
	global tables     "/Users/swparker/Dropbox/PROJECTS_CURRENT/Aging_Progresa/Results"
	global tempFolder "/Users/swparker/Dropbox/PROJECTS_CURRENT/Aging_Progresa/Temp"
}
if "`c(username)'" == "FELIPEME" {
	global dataFolder "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality\data\ENCASEH_ENCEL_PROGRESA"
	global tables     "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\tables"
	global tempFolder "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality\data\Temp_data"
}
if "`c(username)'" == "root" {
	global dataFolder "/home/user/progresa_mortality/data/ENCASEH_ENCEL_PROGRESA"
	global tables     "/home/user/progresa_mortality/tables"
	global tempFolder "/home/user/progresa_mortality/data/Temp_data"
}

cap mkdir "$tables"
cap mkdir "$tempFolder"
cap mkdir "$tables/appendix"

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

*------------------------------------------------------------
* Populate total_visits from 1999 ENCEL socioeconomic file
* nl390Xk = renglon of k-th person who used service X (X=1..4, k=a/b/c)
* nl410Xk = visit count for that person
*------------------------------------------------------------
gen total_visits = .
label var total_visits "Total health facility visits (past 4 weeks)"

di "--- Step 1: loading SPSS file ---"
preserve
import spss using "$dataFolder/Bases97_03/Household/bd_rur_1999_n_socioeconomico_2005-07-06/socioec_encel_99n.sav", clear
keep folio n1390* n1410*
tempfile spss_wide
save `spss_wide'
di "`c(N)' households loaded from SPSS, `c(k)' vars kept"

di "--- Step 2: building person-level visit records ---"
tempfile tv_acc
clear
set obs 0
gen long folio    = .
gen long renglon  = .
gen int  n_visits = .
save `tv_acc'

foreach sn in 1 2 3 4 {
    foreach k in a b c {
        cap use folio n1390`sn'`k' n1410`sn'`k' using `spss_wide', clear
        if _rc { continue }
        di "  slot `sn'`k': `c(N)' rows"
        rename n1390`sn'`k' renglon
        rename n1410`sn'`k' n_visits
        recast long folio renglon
        drop if missing(renglon) | renglon <= 0 | renglon == 9
        replace n_visits = . if n_visits >= 99
        append using `tv_acc'
        save `tv_acc', replace
    }
}

di "--- Step 3: collapsing to one row per person ---"
use `tv_acc', clear
di "`c(N)' raw person-slot records"
drop if missing(folio) | missing(renglon)
replace n_visits = 0 if missing(n_visits)
collapse (sum) total_visits=n_visits, by(folio renglon)
di "`c(N)' unique persons with visit data"
tempfile visits99
save `visits99'

di "--- Step 4: merging into panel ---"
restore
merge m:1 folio renglon using `visits99', keepusing(total_visits) update replace nogenerate
count if !missing(total_visits) & year==99
di "`r(N)' obs in year==99 have non-missing total_visits"

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
    savecsv("$tables/elderly_balance.csv") replace

iebaltab work days_week hours_day live_alone ///
    if age97>=65, ///
    grpvar(contba) control(0) ///
    vce(cluster claveofi) ///
    rowvarlabels ///
    stats(pair(diff)) ///
    savexlsx("$tables/elderly_balance.xlsx") replace


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

*pooled*
local g p
preserve
keep if age97>=65
foreach yvar of local indiv_outcomes {
    summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)
    reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    if "`yvar'" == "weekly_hours" {
        foreach yr in 98 99 {
            local aux : di %9.3f _b[`yr'.year#1.contba]
            local tstat = abs(_b[`yr'.year#1.contba] / _se[`yr'.year#1.contba])
            if `tstat' >= 2.576      local b`yr'_`g'_wh = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b`yr'_`g'_wh = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b`yr'_`g'_wh = trim("`aux'") + "*"
            else                     local b`yr'_`g'_wh = trim("`aux'")
            local se`yr'_`g'_wh : di %9.3f _se[`yr'.year#1.contba]
        }
        local N_`g'_wh   : di %12.0fc e(N)
        local cmn_`g'_wh : di %9.3f `cmean97_elig'
    }
}
foreach yvar of local living {
    summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)
    reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    local col ""
    if "`yvar'" == "live_alone"    local col la
    if "`yvar'" == "with_children" local col wc
    if "`yvar'" == "only_elderly"  local col oe
    if "`col'" != "" {
        foreach yr in 98 99 {
            local aux : di %9.3f _b[`yr'.year#1.contba]
            local tstat = abs(_b[`yr'.year#1.contba] / _se[`yr'.year#1.contba])
            if `tstat' >= 2.576      local b`yr'_`g'_`col' = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b`yr'_`g'_`col' = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b`yr'_`g'_`col' = trim("`aux'") + "*"
            else                     local b`yr'_`g'_`col' = trim("`aux'")
            local se`yr'_`g'_`col' : di %9.3f _se[`yr'.year#1.contba]
        }
        local N_`g'_`col'   : di %12.0fc e(N)
        local cmn_`g'_`col' : di %9.3f `cmean97_elig'
    }
}
restore

*men*
local g m
preserve
keep if gender==1 & age97>=65
* Run DiD/event-study: year FE interacted with treatment
foreach yvar of local indiv_outcomes {

    * Control mean in 1997 (control localities), matching the estimation sample
    summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig

    * Extract locals for T3 (weekly_hours only from this loop)
    if "`yvar'" == "weekly_hours" {
        foreach yr in 98 99 {
            local aux : di %9.3f _b[`yr'.year#1.contba]
            local tstat = abs(_b[`yr'.year#1.contba] / _se[`yr'.year#1.contba])
            if `tstat' >= 2.576      local b`yr'_`g'_wh = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b`yr'_`g'_wh = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b`yr'_`g'_wh = trim("`aux'") + "*"
            else                     local b`yr'_`g'_wh = trim("`aux'")
            local se`yr'_`g'_wh : di %9.3f _se[`yr'.year#1.contba]
        }
        local N_`g'_wh   : di %12.0fc e(N)
        local cmn_`g'_wh : di %9.3f `cmean97_elig'
    }
}


	foreach yvar of local living {

    * Control mean in 1997 (control localities), matching the estimation sample
    summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig

    * Extract locals for T3 (living arrangement outcomes)
    local col ""
    if "`yvar'" == "live_alone"    local col la
    if "`yvar'" == "with_children" local col wc
    if "`yvar'" == "only_elderly"  local col oe
    if "`col'" != "" {
        foreach yr in 98 99 {
            local aux : di %9.3f _b[`yr'.year#1.contba]
            local tstat = abs(_b[`yr'.year#1.contba] / _se[`yr'.year#1.contba])
            if `tstat' >= 2.576      local b`yr'_`g'_`col' = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b`yr'_`g'_`col' = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b`yr'_`g'_`col' = trim("`aux'") + "*"
            else                     local b`yr'_`g'_`col' = trim("`aux'")
            local se`yr'_`g'_`col' : di %9.3f _se[`yr'.year#1.contba]
        }
        local N_`g'_`col'   : di %12.0fc e(N)
        local cmn_`g'_`col' : di %9.3f `cmean97_elig'
    }
}

	
*women*
local g f
restore
preserve
keep if gender==2 & age97>=65
* Run DiD/event-study: year FE interacted with treatment
foreach yvar of local indiv_outcomes {

    * Control mean in 1997 (control localities), matching the estimation sample
    summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig

    * Extract locals for T3 (weekly_hours only from this loop)
    if "`yvar'" == "weekly_hours" {
        foreach yr in 98 99 {
            local aux : di %9.3f _b[`yr'.year#1.contba]
            local tstat = abs(_b[`yr'.year#1.contba] / _se[`yr'.year#1.contba])
            if `tstat' >= 2.576      local b`yr'_`g'_wh = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b`yr'_`g'_wh = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b`yr'_`g'_wh = trim("`aux'") + "*"
            else                     local b`yr'_`g'_wh = trim("`aux'")
            local se`yr'_`g'_wh : di %9.3f _se[`yr'.year#1.contba]
        }
        local N_`g'_wh   : di %12.0fc e(N)
        local cmn_`g'_wh : di %9.3f `cmean97_elig'
    }
}


	foreach yvar of local living {

    * Control mean in 1997 (control localities), matching the estimation sample
    summarize `yvar' if year==97 & contba==0 & !missing(`yvar', year, contba, claveofi)
    local cmean97_all = r(mean)

    * Full sample
    reghdfe `yvar' i.year##i.contba ///
        if !missing(`yvar', year, contba, claveofi), ///
        absorb(pid) ///
        vce(cluster clavemun)
    estadd scalar cmean97 = `cmean97_all'
    eststo `yvar'_all

    * Control mean in 1997 for eligible households
    summarize `yvar' if year==97 & contba==0 & eligible==1 & !missing(`yvar', year, contba, claveofi)
    local cmean97_elig = r(mean)

    * Eligible households only
    reghdfe `yvar' i.year##i.contba ///
        if eligible==1 & !missing(`yvar', year, contba, claveofi), ///
        absorb(clavemun) ///
        vce(cluster claveofi)
    estadd scalar cmean97 = `cmean97_elig'
    eststo `yvar'_elig

    * Extract locals for T3 (living arrangement outcomes)
    local col ""
    if "`yvar'" == "live_alone"    local col la
    if "`yvar'" == "with_children" local col wc
    if "`yvar'" == "only_elderly"  local col oe
    if "`col'" != "" {
        foreach yr in 98 99 {
            local aux : di %9.3f _b[`yr'.year#1.contba]
            local tstat = abs(_b[`yr'.year#1.contba] / _se[`yr'.year#1.contba])
            if `tstat' >= 2.576      local b`yr'_`g'_`col' = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b`yr'_`g'_`col' = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b`yr'_`g'_`col' = trim("`aux'") + "*"
            else                     local b`yr'_`g'_`col' = trim("`aux'")
            local se`yr'_`g'_`col' : di %9.3f _se[`yr'.year#1.contba]
        }
        local N_`g'_`col'   : di %12.0fc e(N)
        local cmn_`g'_`col' : di %9.3f `cmean97_elig'
    }
}
	
	

restore

*------------------------------------------------------------
* Total visits: 1999 cross-section only (no 1997/1998 baseline)
* Run separately for pooled, male, female; store locals for T3 col 5
*------------------------------------------------------------
count if !missing(total_visits) & year==99 & eligible==1
if r(N) > 0 {
    foreach ggrp in p m f {
        if "`ggrp'" == "p"      local gcond "age97>=65"
        else if "`ggrp'" == "m" local gcond "gender==1 & age97>=65"
        else                     local gcond "gender==2 & age97>=65"

        quietly sum total_visits if year==99 & contba==0 & eligible==1 ///
            & `gcond' & !missing(total_visits, contba, claveofi)
        local cmn_`ggrp'_tv : di %9.3f `r(mean)'

        reghdfe total_visits contba ///
            if year==99 & eligible==1 & `gcond' ///
            & !missing(total_visits, contba, claveofi), ///
            absorb(clavemun) vce(cluster claveofi)

        if _rc == 0 {
            local aux : di %9.3f _b[contba]
            local tstat = abs(_b[contba] / _se[contba])
            if      `tstat' >= 2.576 local b99_`ggrp'_tv = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b99_`ggrp'_tv = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b99_`ggrp'_tv = trim("`aux'") + "*"
            else                     local b99_`ggrp'_tv = trim("`aux'")
            local se99_`ggrp'_tv : di %9.3f _se[contba]
            local N_`ggrp'_tv    : di %12.0fc e(N)
        }
        else {
            local b99_`ggrp'_tv  ""
            local se99_`ggrp'_tv ""
            local N_`ggrp'_tv    ""
            local cmn_`ggrp'_tv  ""
        }
    }
}
else {
    di as txt "NOTE: total_visits unavailable — skipping col 5 regressions; T3 col 5 will be blank"
    foreach ggrp in p m f {
        local b99_`ggrp'_tv  ""
        local se99_`ggrp'_tv ""
        local N_`ggrp'_tv    ""
        local cmn_`ggrp'_tv  ""
    }
}

*============================================================
* TABLE 3: Experimental results — Labor Supply and Living Arrangements
* Eligible households only; Panel A: Pooled, Panel B: Females, Panel C: Males
* Output: $tables/T3_experimental.tex
*============================================================

{
    cap file close sm
    file open sm using "$tables/T3_experimental.tex", write replace
    file write sm "\begin{tabular}{lccccc} \hline \hline" _n
    file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\ " _n
    file write sm "& \multicolumn{1}{c}{Weekly Hours} & \multicolumn{1}{c}{Live Alone} & \multicolumn{1}{c}{With Children} & \multicolumn{1}{c}{Only Elderly} & \multicolumn{1}{c}{Total Visits\textsuperscript{$\dagger$}} \\ \toprule" _n
    * Panel A: Pooled
    file write sm "\multicolumn{6}{l}{\textbf{Panel A: Pooled}} \\ \midrule" _n
    file write sm "Treat \$\times\$ 1998 & `b98_p_wh' & `b98_p_la' & `b98_p_wc' & `b98_p_oe' & \\ " _n
    file write sm " & (`se98_p_wh') & (`se98_p_la') & (`se98_p_wc') & (`se98_p_oe') & \\[4pt]" _n
    file write sm "Treat \$\times\$ 1999 & `b99_p_wh' & `b99_p_la' & `b99_p_wc' & `b99_p_oe' & `b99_p_tv' \\ " _n
    file write sm " & (`se99_p_wh') & (`se99_p_la') & (`se99_p_wc') & (`se99_p_oe') & (`se99_p_tv') \\[4pt]" _n
    file write sm "Observations & `N_p_wh' & `N_p_la' & `N_p_wc' & `N_p_oe' & `N_p_tv' \\ " _n
    file write sm "Control Mean (1997) & `cmn_p_wh' & `cmn_p_la' & `cmn_p_wc' & `cmn_p_oe' & \\ " _n
    file write sm "Control Mean (1999) & & & & & `cmn_p_tv' \\ \midrule" _n
    * Panel B: Females
    file write sm "\multicolumn{6}{l}{\textbf{Panel B: Females}} \\ \midrule" _n
    file write sm "Treat \$\times\$ 1998 & `b98_f_wh' & `b98_f_la' & `b98_f_wc' & `b98_f_oe' & \\ " _n
    file write sm " & (`se98_f_wh') & (`se98_f_la') & (`se98_f_wc') & (`se98_f_oe') & \\[4pt]" _n
    file write sm "Treat \$\times\$ 1999 & `b99_f_wh' & `b99_f_la' & `b99_f_wc' & `b99_f_oe' & `b99_f_tv' \\ " _n
    file write sm " & (`se99_f_wh') & (`se99_f_la') & (`se99_f_wc') & (`se99_f_oe') & (`se99_f_tv') \\[4pt]" _n
    file write sm "Observations & `N_f_wh' & `N_f_la' & `N_f_wc' & `N_f_oe' & `N_f_tv' \\ " _n
    file write sm "Control Mean (1997) & `cmn_f_wh' & `cmn_f_la' & `cmn_f_wc' & `cmn_f_oe' & \\ " _n
    file write sm "Control Mean (1999) & & & & & `cmn_f_tv' \\ \midrule" _n
    * Panel C: Males
    file write sm "\multicolumn{6}{l}{\textbf{Panel C: Males}} \\ \midrule" _n
    file write sm "Treat \$\times\$ 1998 & `b98_m_wh' & `b98_m_la' & `b98_m_wc' & `b98_m_oe' & \\ " _n
    file write sm " & (`se98_m_wh') & (`se98_m_la') & (`se98_m_wc') & (`se98_m_oe') & \\[4pt]" _n
    file write sm "Treat \$\times\$ 1999 & `b99_m_wh' & `b99_m_la' & `b99_m_wc' & `b99_m_oe' & `b99_m_tv' \\ " _n
    file write sm " & (`se99_m_wh') & (`se99_m_la') & (`se99_m_wc') & (`se99_m_oe') & (`se99_m_tv') \\[4pt]" _n
    file write sm "Observations & `N_m_wh' & `N_m_la' & `N_m_wc' & `N_m_oe' & `N_m_tv' \\ " _n
    file write sm "Control Mean (1997) & `cmn_m_wh' & `cmn_m_la' & `cmn_m_wc' & `cmn_m_oe' & \\ " _n
    file write sm "Control Mean (1999) & & & & & `cmn_m_tv' \\ \bottomrule" _n
    file write sm "\multicolumn{6}{l}{\footnotesize \textsuperscript{\$\dagger\$} Total visits = \texttt{cons\_hosp} + \texttt{centr\_sal} + \texttt{med\_parti} (visits to hospital,} \\" _n
    file write sm "\multicolumn{6}{l}{\footnotesize public clinic, or private doctor in the past 4 weeks). Data available in 1999 only;} \\" _n
    file write sm "\multicolumn{6}{l}{\footnotesize Treat \$\times\$ 1998 not estimable. Specification: cross-section 1999, municipality FE.} \\" _n
    file write sm "\end{tabular}"
    file close sm
}

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
    savecsv("$tables/balance_HH.csv") replace

iebaltab `balvars' ///
    if elderly97>=1, ///
    grpvar(contba) ///
    vce(cluster claveofi) ///
    rowvarlabels ///
    savecsv("$tables/elderly_balance_HH.csv") replace
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

    * Extract locals for AT6 table
    local col ""
    if "`yvar'" == "food"      local col food
    if "`yvar'" == "porc_food" local col pf
    if "`yvar'" == "medicine"  local col med
    if "`yvar'" == "porc_med"  local col pm
    if "`col'" != "" {
        * Treatment × 1999 for non-elderly HH (base = 1998, elderly97=0)
        local aux : di %9.3f _b[99.year#1.contba]
        local tstat = abs(_b[99.year#1.contba] / _se[99.year#1.contba])
        if `tstat' >= 2.576      local b99_`col' = trim("`aux'") + "***"
        else if `tstat' >= 1.960 local b99_`col' = trim("`aux'") + "**"
        else if `tstat' >= 1.645 local b99_`col' = trim("`aux'") + "*"
        else                     local b99_`col' = trim("`aux'")
        local se99_`col' : di %9.3f _se[99.year#1.contba]
        * Differential for elderly HH (triple interaction)
        local aux : di %9.3f _b[99.year#1.contba#1.elderly97]
        local tstat = abs(_b[99.year#1.contba#1.elderly97] / _se[99.year#1.contba#1.elderly97])
        if `tstat' >= 2.576      local b99e_`col' = trim("`aux'") + "***"
        else if `tstat' >= 1.960 local b99e_`col' = trim("`aux'") + "**"
        else if `tstat' >= 1.645 local b99e_`col' = trim("`aux'") + "*"
        else                     local b99e_`col' = trim("`aux'")
        local se99e_`col' : di %9.3f _se[99.year#1.contba#1.elderly97]
        local N_at6_`col'  : di %12.0fc e(N)
        local cmn98_`col'  : di %9.3f `cmean97_hetelig'
    }
}

*============================================================
* APPENDIX TABLE A.6: HH Expenditures by Elderly Presence, Eligible Households
* Output: $tables/appendix/AT6_expenditures_elderly.tex
*============================================================

{
    cap file close sm
    file open sm using "$tables/appendix/AT6_expenditures_elderly.tex", write replace
    file write sm "\begin{tabular}{lcccc} \hline \hline" _n
    file write sm "& \multicolumn{2}{c}{Food} & \multicolumn{2}{c}{Health} \\ " _n
    file write sm "\cmidrule(lr){2-3}\cmidrule(lr){4-5}" _n
    file write sm "& \multicolumn{1}{c}{Log} & \multicolumn{1}{c}{Share (\%)} & \multicolumn{1}{c}{Log} & \multicolumn{1}{c}{Share (\%)} \\ " _n
    file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
    file write sm "Treatment \$\times\$ 1999 (no elderly) & `b99_food' & `b99_pf' & `b99_med' & `b99_pm' \\ " _n
    file write sm " & (`se99_food') & (`se99_pf') & (`se99_med') & (`se99_pm') \\[4pt]" _n
    file write sm "Differential (elderly HH) & `b99e_food' & `b99e_pf' & `b99e_med' & `b99e_pm' \\ " _n
    file write sm " & (`se99e_food') & (`se99e_pf') & (`se99e_med') & (`se99e_pm') \\[4pt]" _n
    file write sm "Observations & `N_at6_food' & `N_at6_pf' & `N_at6_med' & `N_at6_pm' \\ " _n
    file write sm "Control Mean (1998) & `cmn98_food' & `cmn98_pf' & `cmn98_med' & `cmn98_pm' \\ \bottomrule" _n
    file write sm "\end{tabular}"
    file close sm
}




/*


//keep databases with all ages and all variables including new ones created

save "`root'/Temp/aging_experiment", replace

