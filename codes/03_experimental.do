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

*------------------------------------------------------------
* CACHE FLAG: rebuild vs. load the pre-built working dataset.
* The block below (raw Panel import, all recoding/construction, and both
* the November and June SPSS visit-count imports) is slow to re-run every
* time this file is opened. Set $rebuild_experimental_data = 1 the FIRST
* time you run this file, or any time the raw source data / construction
* logic changes; it will rebuild everything and save a cached .dta. Set it
* to 0 on subsequent runs to skip straight past the slow imports/recoding
* and load that cached dataset instead -- only the analysis code below
* (T3, AT6, etc.) will actually re-run.
*------------------------------------------------------------
global rebuild_experimental_data = 1

if $rebuild_experimental_data == 1 {

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

*------------------------------------------------------------
* JUNE 1999 (ronda==4) DEMOGRAPHIC ROSTER -- saved before the round
* restriction below drops it.
*
* ronda==4 is deliberately NOT kept in the main panel: `year' is defined
* only for rondas 1/3/5, and the whole file conditions on year==97/98/99,
* so adding a fourth round here would silently change every other table.
* But the Gertler (2000) Table 6 replication is a POOLED 1999 CROSS-
* SECTION over the June and November waves, and for that each wave needs
* (a) its own contemporaneous age and (b) its own respondent list. Having
* a ronda==4 row IS the record that a person was enumerated in June.
* Without this, the pooled block had to borrow November age as a proxy,
* which left it missing for every June-only respondent.
*------------------------------------------------------------
preserve
    keep if ronda==4
    keep folio renglon edad
    rename edad age_jun99
    label var age_jun99 "Age at the June 1999 (ronda==4) interview"
    gen byte in_june_roster = 1
    label var in_june_roster "Person was enumerated in the June 1999 wave"
    duplicates drop folio renglon, force
    save "$tempFolder/june99_roster.dta", replace
    di "`c(N)' person records in the June 1999 (ronda==4) roster"
restore

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

 * Baseline-fixed version: household composition frozen at 1997 (ronda==1).
 * only_elderly is contemporaneous and itself a treatment outcome (T3 col 5),
 * so conditioning on it risks endogenous-sample bias. Fixing it at baseline
 * removes that concern (composition is pre-treatment).
 bys folio: egen only_elderly_base = max(cond(ronda==1, only_elderly, .))
 label variable only_elderly_base "HH had only elderly members at baseline (1997)"

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
* Cache a .dta mirror of the raw .sav so it can be opened directly in Stata
* for inspection (e.g. `tab renglon`) without re-running the SPSS import.
local sav_99n "$dataFolder/Bases97_03/Household/bd_rur_1999_n_socioeconomico_2005-07-06/socioec_encel_99n.sav"
local dta_99n "$tempFolder/socioec_encel_99n.dta"
if fileexists("`dta_99n'") {
    use "`dta_99n'", clear
    di "loaded cached .dta: `dta_99n'"
}
else {
    import spss using "`sav_99n'", clear
    save "`dta_99n'", replace
    di "converted .sav -> .dta and cached: `dta_99n'"
}
keep folio n1390* n1410*
tempfile spss_wide
save `spss_wide'
di "`c(N)' households loaded from SPSS, `c(k)' vars kept"

* Save unique folio list so we can zero-fill non-visitors after restoring panel
keep folio
duplicates drop folio, force
gen byte in_spss99 = 1
tempfile spss_folios
save `spss_folios'
di "`c(N)' unique folios in SPSS file"

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
        if !_rc {
            di "  slot `sn'`k': `c(N)' rows"
            rename n1390`sn'`k' renglon
            rename n1410`sn'`k' n_visits
            recast long folio renglon
            * NOTE: renglon is the household-roster line number of the person
            * who used the service, NOT the household-level gate question's
            * Yes/No/NR sentinel -- renglon==9 (and higher, up to household
            * size, e.g. 25) is a legitimate roster position and must not be
            * dropped as if it were "no response." Confirmed via
            * `tab renglon` on the raw SPSS file, which shows real values up
            * to 25. Only drop genuinely missing/non-positive renglon.
            drop if missing(renglon) | renglon <= 0
            replace n_visits = . if n_visits >= 99
            append using `tv_acc'
            save `tv_acc', replace
        }
    }
}

di "--- Step 3: collapsing to one row per person ---"
use `tv_acc', clear
di "`c(N)' raw person-slot records"
drop if missing(folio) | missing(renglon)
replace n_visits = 0 if missing(n_visits)
collapse (sum) total_visits=n_visits, by(folio renglon)
di "`c(N)' unique persons with visit data (visitors only)"
tempfile visits99
save `visits99'

di "--- Step 4: merging into panel ---"
restore
merge m:1 folio renglon using `visits99', keepusing(total_visits) update replace nogenerate
count if !missing(total_visits) & year==99
di "`r(N)' obs in year==99 have non-missing total_visits (visitors only)"

* Zero-fill non-visitors: household in SPSS file but no recorded health visit -> 0 visits
merge m:1 folio using `spss_folios', keepusing(in_spss99) nogenerate
replace total_visits = 0 if missing(total_visits) & year==99 & in_spss99==1
drop in_spss99
count if !missing(total_visits) & year==99
di "`r(N)' obs in year==99 have non-missing total_visits (after zero-filling non-visitors)"

*------------------------------------------------------------
* Populate total_visits_june from the JUNE-1999 ENCEL socioeconomic file
* (ENCEL98M; fieldwork ~June 1999, the wave immediately before the November
* 1999 file used above). Gertler (2000) Table 6 pools exactly these "third
* and fourth waves"; this is the second of the two waves needed to approach
* his N=15,399 (age 51+).
*
* m149{XX}{k} = renglon of the k-th household member (k=a/b/c) who used
*               service type XX (XX=01..07) in the last 4 weeks
* m151{XX}{k} = visit COUNT for that same person -- confirmed via
*               `codebook m15106a` (label "...cuantas veces (NOMBRE)
*               acudio...", small-integer values = genuine visit counts).
* Structure verified via `codebook m14901 m14901a m14901b m14901c`: obs
* counts shrink 337->39->9 across person-slots a/b/c (sequential slots,
* filled in order), and value ranges (1-12, 1-10, 2-9) match household-
* member renglon, not visit frequency -- i.e. m149/m151 is the same
* renglon/count PAIR structure as n1390/n1410 in the November file, just
* with 7 service types (01-07) instead of 4, and different stem names.
*
* ASSUMPTIONS carried over from the November block's conventions, not yet
* independently verified for this file -- sanity-check if pooled N looks
* off: n_visits>=90 treated as a top-coded/missing sentinel (no confirmed
* exact cutoff was found in the codebook output shared so far -- only
* values 1-4 were observed in the m15106a sample, so this is a
* conservative guess, not a confirmed code). NOTE: the renglon==9 drop
* that used to be listed here as a carried-over assumption was confirmed
* WRONG (renglon is a roster line number, not the gate question's NR
* sentinel) and has been removed from both this block and the November
* block above.
*------------------------------------------------------------
gen total_visits_june = .
label var total_visits_june "Total health facility visits (past 4 weeks), June 1999 wave"

di "--- June wave Step 1: loading SPSS file ---"
preserve
* Cache a .dta mirror of the raw .sav so it can be opened directly in Stata
* for inspection without re-running the SPSS import.
local sav_99m "$dataFolder/Bases97_03/Household/bd_rur_1999_m_socioeconomico_2005-07-06/socioec_encel_99m.sav"
local dta_99m "$tempFolder/socioec_encel_99m.dta"
if fileexists("`dta_99m'") {
    use "`dta_99m'", clear
    di "loaded cached .dta: `dta_99m'"
}
else {
    import spss using "`sav_99m'", clear
    save "`dta_99m'", replace
    di "converted .sav -> .dta and cached: `dta_99m'"
}
keep folio m149* m151*
tempfile spss_wide_m
save `spss_wide_m'
di "`c(N)' households loaded from SPSS (June), `c(k)' vars kept"

keep folio
duplicates drop folio, force
gen byte in_spss99m = 1
tempfile spss_folios_m
save `spss_folios_m'
di "`c(N)' unique folios in SPSS file (June)"

di "--- June wave Step 2: building person-level visit records ---"
tempfile tv_acc_m
clear
set obs 0
gen long folio    = .
gen long renglon  = .
gen int  n_visits = .
save `tv_acc_m'

foreach sn in 01 02 03 04 05 06 07 {
    foreach k in a b c {
        cap use folio m149`sn'`k' m151`sn'`k' using `spss_wide_m', clear
        if !_rc {
            di "  slot `sn'`k': `c(N)' rows"
            rename m149`sn'`k' renglon
            rename m151`sn'`k' n_visits
            recast long folio renglon
            drop if missing(renglon) | renglon <= 0
            replace n_visits = . if n_visits >= 90
            append using `tv_acc_m'
            save `tv_acc_m', replace
        }
    }
}

di "--- June wave Step 3: collapsing to one row per person ---"
use `tv_acc_m', clear
di "`c(N)' raw person-slot records (June)"
drop if missing(folio) | missing(renglon)
replace n_visits = 0 if missing(n_visits)
collapse (sum) total_visits_june=n_visits, by(folio renglon)
di "`c(N)' unique persons with visit data, June wave (visitors only)"
tempfile visits99m
save `visits99m'

di "--- June wave Step 4: merging into panel ---"
restore
merge m:1 folio renglon using `visits99m', keepusing(total_visits_june) update replace nogenerate
count if !missing(total_visits_june)
di "`r(N)' obs (across all kept rounds, same value replicated per person) have non-missing total_visits_june before zero-fill"

* Zero-fill non-visitors: household in June SPSS file but no recorded visit -> 0
merge m:1 folio using `spss_folios_m', keepusing(in_spss99m) nogenerate
replace total_visits_june = 0 if missing(total_visits_june) & in_spss99m==1
drop in_spss99m
count if !missing(total_visits_june)
di "`r(N)' obs have non-missing total_visits_june after zero-filling non-visitors"

gen post=1 if year==98 | year==99
replace post=0 if year==97

egen claveofi = group(cve_ent cve_mun cve_loc), label
egen clavemun = group(cve_ent cve_mun), label
sort folio

merge m:1 folio using "$tempFolder/HH_char"

* Cache the fully-built dataset so subsequent runs can skip straight to
* the analysis code below (set $rebuild_experimental_data = 0 above).
save "$tempFolder/experimental_built.dta", replace
di "Built dataset cached to: $tempFolder/experimental_built.dta"

}
else {
    di "Loading cached dataset (set \$rebuild_experimental_data = 1 above to rebuild from raw source files)"
    use "$tempFolder/experimental_built.dta", clear
}

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

count if age97>=51 & eligible==1
di "Sample (age 51+, eligible): `r(N)' obs across 3 rounds"
count if age97>=65 & eligible==1
di "Sample (age 65+, eligible): `r(N)' obs across 3 rounds"

*pooled — age 65+*
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
        di "  [weekly_hours, g=`g'] _b[98.year#1.contba] = " _b[98.year#1.contba] "  _b[99.year#1.contba] = " _b[99.year#1.contba]
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
        di "  -> b98_`g'_wh = `b98_`g'_wh'  b99_`g'_wh = `b99_`g'_wh'"
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

*men — age 65+*
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

	
*women — age 65+*
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
di "`r(N)' eligible obs with total_visits in year==99 (col 5 sample before age restriction)"

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

    di "  [total_visits 65+, g=`ggrp'] _b[contba] = " _b[contba] "  N=" e(N)

    local aux : di %9.3f _b[contba]
    local tstat = abs(_b[contba] / _se[contba])
    if      `tstat' >= 2.576 local b99_`ggrp'_tv = trim("`aux'") + "***"
    else if `tstat' >= 1.960 local b99_`ggrp'_tv = trim("`aux'") + "**"
    else if `tstat' >= 1.645 local b99_`ggrp'_tv = trim("`aux'") + "*"
    else                     local b99_`ggrp'_tv = trim("`aux'")
    local se99_`ggrp'_tv : di %9.3f _se[contba]
    local N_`ggrp'_tv    : di %12.0fc e(N)
}

*------------------------------------------------------------
* Total visits in ELDERLY-ONLY households (only_elderly_base==1, age 65+)
* 1999 cross-section, municipality FE — the direct-transfer subsample analog
* of the weekly-hours elderly-only column. Replaces the former age-51+ column.
*------------------------------------------------------------
foreach ggrp in p m f {
    if "`ggrp'" == "p"      local gcondeo "age97>=65"
    else if "`ggrp'" == "m" local gcondeo "gender==1 & age97>=65"
    else                     local gcondeo "gender==2 & age97>=65"

    quietly sum total_visits if year==99 & contba==0 & eligible==1 & only_elderly_base==1 ///
        & `gcondeo' & !missing(total_visits, contba, claveofi)
    local cmn_`ggrp'_tveo : di %9.3f `r(mean)'

    reghdfe total_visits contba ///
        if year==99 & eligible==1 & only_elderly_base==1 & `gcondeo' ///
        & !missing(total_visits, contba, claveofi), ///
        absorb(clavemun) vce(cluster claveofi)

    di "  [total_visits elderly-only, g=`ggrp'] _b[contba] = " _b[contba] "  N=" e(N)

    local aux   : di %9.3f _b[contba]
    local tstat = abs(_b[contba] / _se[contba])
    if      `tstat' >= 2.576 local b99_`ggrp'_tveo = trim("`aux'") + "***"
    else if `tstat' >= 1.960 local b99_`ggrp'_tveo = trim("`aux'") + "**"
    else if `tstat' >= 1.645 local b99_`ggrp'_tveo = trim("`aux'") + "*"
    else                     local b99_`ggrp'_tveo = trim("`aux'")
    local se99_`ggrp'_tveo : di %9.3f _se[contba]
    local N_`ggrp'_tveo    : di %12.0fc e(N)
}

*------------------------------------------------------------
* POOLED 1999 WAVES (June + November): Gertler (2000) Table 6 comparison.
* Stacks total_visits from both 1999 ENCEL waves -- June (total_visits_june)
* and November (total_visits, at year==99) -- into one long person-wave file
* and reruns the cross-sectional treat-vs-control comparison, mirroring
* Gertler's own pooling of the "third and fourth waves."
*
* AGE CUTOFF: each wave uses its OWN contemporaneous interview age
* (age_wave) -- November records from ronda==5, June records from the
* ronda==4 roster saved before the round restriction near the top of this
* file. This replaces an earlier construction that applied November age to
* the June records as a proxy; that proxy was missing for every June
* respondent not re-interviewed in November, and because Stata treats
* missing as larger than any number, those age-less records passed BOTH
* the 51+ and the 65+ filters. Symptom to watch for if this regresses:
* the 65+ N approaching the 51+ N (demographically they should differ by
* roughly a factor of three).
*
* SAMPLE: each wave contributes only the people actually enumerated in
* that wave. Non-visitors among them are genuine zeros (Gertler's Table 6
* outcome is visits over the whole 51+ population, not just visitors), so
* the zero-fill upstream is intentional -- but it must not extend to
* household members who were never interviewed in that wave.
*------------------------------------------------------------
preserve
* Person-level constants for the Nov-wave value and contemporaneous age
* (both currently only populated on year==99 rows); total_visits_june is
* already round-invariant per person since it was merged in by
* folio+renglon with no year condition.
bys pid: egen total_visits_n99 = max(cond(year==99, total_visits, .))
bys pid: egen age_nov99 = max(cond(year==99, age, .))
bys pid: keep if _n==1
keep pid folio renglon age97 age_nov99 eligible contba gender clavemun claveofi ///
    total_visits_n99 total_visits_june

*------------------------------------------------------------
* Attach the June 1999 roster saved before the round restriction, giving
* each wave its OWN contemporaneous age and its OWN respondent list.
* in_june_roster==1 <=> the person actually had a June 1999 (ronda==4)
* interview; in_nov_roster==1 <=> they had a November (ronda==5) one.
*------------------------------------------------------------
capture confirm file "$tempFolder/june99_roster.dta"
if _rc {
    di as error "june99_roster.dta not found -- rerun with \$rebuild_experimental_data = 1"
    exit 601
}
merge 1:1 folio renglon using "$tempFolder/june99_roster.dta", ///
    keepusing(age_jun99 in_june_roster) keep(master match) generate(_mjun)
count if _mjun==3
di "`r(N)' panel persons matched to a June 1999 roster record"
drop _mjun
replace in_june_roster = 0 if missing(in_june_roster)

gen byte in_nov_roster = !missing(age_nov99)
count if in_nov_roster==1
di "`r(N)' panel persons with a November 1999 (ronda==5) record"

* NOTE: Stata does not allow nested preserve/restore -- we are already
* inside one preserve block (opened above), so build both wave files by
* generating/dropping the wave-specific variables in place rather than
* preserving again.
*
* Each wave keeps only its OWN respondents. Previously the June wave
* carried a value for every panel member of any household appearing in
* the June file -- including people last seen in 1997 -- and those had no
* contemporaneous age, which then slipped through the age filter (see
* below). Restricting to the wave's own roster is both the correct
* cross-section and the fix for that leak.
gen total_visits_pooled = total_visits_n99 if in_nov_roster==1
gen age_wave = age_nov99
label var age_wave "Age at this wave's own interview"
gen wave99 = "n"
tempfile wave_n
save `wave_n'

drop total_visits_pooled age_wave wave99
gen total_visits_pooled = total_visits_june if in_june_roster==1
gen age_wave = age_jun99
gen wave99 = "m"
tempfile wave_m
save `wave_m'

use `wave_n', clear
append using `wave_m'
di "`c(N)' person-wave records after stacking June + November 1999"
tab wave99 if !missing(total_visits_pooled)

* IMPORTANT: every age filter below is guarded with !missing(). In Stata a
* missing value compares as LARGER than any number, so a bare
* "age_wave>=51" is TRUE whenever age_wave is missing, which silently
* swept every age-less record into BOTH the 51+ and 65+ samples.
count if !missing(total_visits_pooled, age_wave) & eligible==1 & age_wave>=51
di "`r(N)' eligible obs (own-wave age>=51, both waves stacked) with non-missing pooled total_visits -- compare to Gertler (2000) N=15,399"
count if !missing(total_visits_pooled, age_wave) & eligible==1 & age_wave>=65
di "`r(N)' eligible obs (own-wave age>=65, both waves stacked)"

foreach ggrp in p m f {
    foreach agecut in 65 51 {
        if "`ggrp'" == "p"      local gcondp "!missing(age_wave) & age_wave>=`agecut'"
        else if "`ggrp'" == "m" local gcondp "gender==1 & !missing(age_wave) & age_wave>=`agecut'"
        else                     local gcondp "gender==2 & !missing(age_wave) & age_wave>=`agecut'"

        quietly sum total_visits_pooled if contba==0 & eligible==1 ///
            & `gcondp' & !missing(total_visits_pooled, contba, claveofi)
        local cmn_`ggrp'_tvp`agecut' : di %9.3f `r(mean)'

        reghdfe total_visits_pooled contba ///
            if eligible==1 & `gcondp' & !missing(total_visits_pooled, contba, claveofi), ///
            absorb(clavemun) vce(cluster claveofi)

        di "  [total_visits POOLED `agecut'+, g=`ggrp'] _b[contba] = " _b[contba] "  N=" e(N)

        local aux : di %9.3f _b[contba]
        local tstat = abs(_b[contba] / _se[contba])
        if      `tstat' >= 2.576 local b99_`ggrp'_tvp`agecut' = trim("`aux'") + "***"
        else if `tstat' >= 1.960 local b99_`ggrp'_tvp`agecut' = trim("`aux'") + "**"
        else if `tstat' >= 1.645 local b99_`ggrp'_tvp`agecut' = trim("`aux'") + "*"
        else                     local b99_`ggrp'_tvp`agecut' = trim("`aux'")
        local se99_`ggrp'_tvp`agecut' : di %9.3f _se[contba]
        local N_`ggrp'_tvp`agecut'    : di %12.0fc e(N)
    }
}

* ADDITIONAL, per the user's request: same Ages 51+ Gertler comparison,
* but using BASELINE age (age97, measured at the 1997 interview) instead
* of contemporaneous age_nov99 -- the age definition this table used
* before the contemporaneous-age switch described above. Added as a
* direct check on whether the age definition itself, rather than the
* wave-pooling construction, explains the remaining gap to Gertler's
* (2000) reported N=15,399 and estimates.
* CAVEAT: conditioning on age97 also implicitly conditions on being
* present in the 1997 baseline -- a sample restriction Gertler does not
* impose on a 1999 cross-section. These columns are a diagnostic on the
* age definition, not an alternative specification.
count if !missing(total_visits_pooled, age97) & eligible==1 & age97>=51
di "`r(N)' eligible obs (BASELINE age97>=51, both waves stacked) with non-missing pooled total_visits -- compare to Gertler (2000) N=15,399 and to the contemporaneous-age count above"

foreach ggrp in p m f {
    if "`ggrp'" == "p"      local gcondp97 "!missing(age97) & age97>=51"
    else if "`ggrp'" == "m" local gcondp97 "gender==1 & !missing(age97) & age97>=51"
    else                     local gcondp97 "gender==2 & !missing(age97) & age97>=51"

    quietly sum total_visits_pooled if contba==0 & eligible==1 ///
        & `gcondp97' & !missing(total_visits_pooled, contba, claveofi)
    local cmn_`ggrp'_tvp51age97 : di %9.3f `r(mean)'

    reghdfe total_visits_pooled contba ///
        if eligible==1 & `gcondp97' & !missing(total_visits_pooled, contba, claveofi), ///
        absorb(clavemun) vce(cluster claveofi)

    di "  [total_visits POOLED 51+ baseline age97, g=`ggrp'] _b[contba] = " _b[contba] "  N=" e(N)

    local aux : di %9.3f _b[contba]
    local tstat = abs(_b[contba] / _se[contba])
    if      `tstat' >= 2.576 local b99_`ggrp'_tvp51age97 = trim("`aux'") + "***"
    else if `tstat' >= 1.960 local b99_`ggrp'_tvp51age97 = trim("`aux'") + "**"
    else if `tstat' >= 1.645 local b99_`ggrp'_tvp51age97 = trim("`aux'") + "*"
    else                     local b99_`ggrp'_tvp51age97 = trim("`aux'")
    local se99_`ggrp'_tvp51age97 : di %9.3f _se[contba]
    local N_`ggrp'_tvp51age97    : di %12.0fc e(N)
}
restore

*============================================================
* APPENDIX TABLE: Total health-facility visits, POOLED across the two 1999
* ENCEL waves (June + November), age 65+ and age 51+ -- direct comparison
* to Gertler (2000), Table 6, which pools the same two survey waves.
* Columns (7)-(9) repeat the Ages 51+ Gertler comparison (columns 4-6)
* using baseline age (age97) instead of contemporaneous age (age_nov99),
* per the user's request to isolate whether the age definition explains
* the remaining gap to Gertler's reported N/estimates.
* Output: $tables/appendix/AT_gertler_pooled.tex
*============================================================
{
    cap file close gp
    file open gp using "$tables/appendix/AT_gertler_pooled.tex", write replace
    file write gp "\begin{tabular}{lccccccccc} \hline \hline" _n
    file write gp "& \multicolumn{3}{c}{Ages 65+} & \multicolumn{3}{c}{Ages 51+ (Gertler 2000, contemp.\ age)} & \multicolumn{3}{c}{Ages 51+ (Gertler 2000, baseline age)} \\ \cmidrule(lr){2-4}\cmidrule(lr){5-7}\cmidrule(lr){8-10}" _n
    file write gp "& \multicolumn{1}{c}{Pooled} & \multicolumn{1}{c}{Females} & \multicolumn{1}{c}{Males} & \multicolumn{1}{c}{Pooled} & \multicolumn{1}{c}{Females} & \multicolumn{1}{c}{Males} & \multicolumn{1}{c}{Pooled} & \multicolumn{1}{c}{Females} & \multicolumn{1}{c}{Males} \\ " _n
    file write gp "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}\cmidrule(lr){10-10}" _n
    file write gp "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} & \multicolumn{1}{c}{(9)} \\ \toprule" _n
    file write gp "\textit{Treatment} & `b99_p_tvp65' & `b99_f_tvp65' & `b99_m_tvp65' & `b99_p_tvp51' & `b99_f_tvp51' & `b99_m_tvp51' & `b99_p_tvp51age97' & `b99_f_tvp51age97' & `b99_m_tvp51age97' \\ " _n
    file write gp " & (`se99_p_tvp65') & (`se99_f_tvp65') & (`se99_m_tvp65') & (`se99_p_tvp51') & (`se99_f_tvp51') & (`se99_m_tvp51') & (`se99_p_tvp51age97') & (`se99_f_tvp51age97') & (`se99_m_tvp51age97') \\ " _n
    file write gp "  & & & & & & & & & \\ " _n
    file write gp "Control Mean & `cmn_p_tvp65' & `cmn_f_tvp65' & `cmn_m_tvp65' & `cmn_p_tvp51' & `cmn_f_tvp51' & `cmn_m_tvp51' & `cmn_p_tvp51age97' & `cmn_f_tvp51age97' & `cmn_m_tvp51age97' \\ " _n
    file write gp "Observations & `N_p_tvp65' & `N_f_tvp65' & `N_m_tvp65' & `N_p_tvp51' & `N_f_tvp51' & `N_m_tvp51' & `N_p_tvp51age97' & `N_f_tvp51age97' & `N_m_tvp51age97' \\ " _n
    file write gp "Municipality FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\ \bottomrule" _n
    file write gp "\end{tabular}"
    file close gp
}
di "Table exported to: $tables/appendix/AT_gertler_pooled.tex"

*------------------------------------------------------------
* T3 col 2: Weekly hours in ELDERLY-ONLY households, composition fixed at
* baseline (only_elderly_base==1, 1997 roster). Identifies the "direct-transfer
* only" subsample: a household with no children (and no working-age adults)
* receives ONLY the apoyo alimentario (the fixed, poverty-based food grant paid
* to the titular), NOT the child-conditional apoyo educativo/becas. Contrast with
* col 1 (all eligible elderly, whose household transfer is dominated by the
* indirect becas). Baseline-fixing avoids conditioning on a post-treatment
* household outcome. Same spec as col 1 (DiD, municipality FE, eligible, age 65+).
*------------------------------------------------------------
foreach grp in p f m {
    if "`grp'" == "p"      local gcond_eoh "age97>=65"
    else if "`grp'" == "f" local gcond_eoh "gender==2 & age97>=65"
    else                   local gcond_eoh "gender==1 & age97>=65"

    foreach comp in eob {
        local ccond "only_elderly_base==1"

        preserve
        keep if `gcond_eoh' & `ccond'

        summarize weekly_hours if year==97 & contba==0 & eligible==1 ///
            & !missing(weekly_hours, year, contba, claveofi)
        local cmean97_`comp' = r(mean)

        reghdfe weekly_hours i.year##i.contba ///
            if eligible==1 & !missing(weekly_hours, year, contba, claveofi), ///
            absorb(clavemun) vce(cluster claveofi)

        di "  [weekly_hours `comp', g=`grp'] b98 = " _b[98.year#1.contba] "  b99 = " _b[99.year#1.contba] "  N=" e(N)

        foreach yr in 98 99 {
            local aux : di %9.3f _b[`yr'.year#1.contba]
            local tstat = abs(_b[`yr'.year#1.contba] / _se[`yr'.year#1.contba])
            if      `tstat' >= 2.576 local b`yr'_`grp'_`comp' = trim("`aux'") + "***"
            else if `tstat' >= 1.960 local b`yr'_`grp'_`comp' = trim("`aux'") + "**"
            else if `tstat' >= 1.645 local b`yr'_`grp'_`comp' = trim("`aux'") + "*"
            else                     local b`yr'_`grp'_`comp' = trim("`aux'")
            local se`yr'_`grp'_`comp' : di %9.3f _se[`yr'.year#1.contba]
        }
        local N_`grp'_`comp'   : di %12.0fc e(N)
        local cmn_`grp'_`comp' : di %9.3f `cmean97_`comp''
        restore
    }
}

* diagnostics before writing table
di "--- T3 locals check ---"
di "b98_p_wh  = `b98_p_wh'   |  b99_p_wh  = `b99_p_wh'   |  N_p_wh  = `N_p_wh'"
di "b98_p_eob = `b98_p_eob'  |  b99_p_eob = `b99_p_eob'  |  N_p_eob = `N_p_eob'"
di "b98_p_la = `b98_p_la'  |  b99_p_la = `b99_p_la'  |  N_p_la = `N_p_la'"
di "b99_p_tveo = `b99_p_tveo'  |  N_p_tveo = `N_p_tveo'"

*============================================================
* TABLE 3: Experimental results — Labor Supply and Living Arrangements
* Main sample: age 65+. Col 2 = weekly hours in elderly-only (direct-transfer)
* households. Col 6 adds total visits for age 51+ (Gertler 2000 Table 6 comparison).
* Output: $tables/T3_experimental.tex
*============================================================

{
    cap file close sm
    file open sm using "$tables/T3_experimental.tex", write replace
    file write sm "\begin{tabular}{lccccccc} \hline \hline" _n
    file write sm "& \multicolumn{5}{c}{\textit{All Eligible Older Adults (65+)}} & \multicolumn{2}{c}{\textit{Older-Adults-Only Households}} \\ \cmidrule(lr){2-6}\cmidrule(lr){7-8}" _n
    file write sm "& \multicolumn{1}{c}{\textit{Labor}} & \multicolumn{3}{c}{\textit{Living Arrangements}} & \multicolumn{1}{c}{\textit{Health}} & \multicolumn{1}{c}{\textit{Labor}} & \multicolumn{1}{c}{\textit{Health}} \\ \cmidrule(lr){2-2}\cmidrule(lr){3-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}" _n
    file write sm "& \multicolumn{1}{c}{Weekly Hours} & \multicolumn{1}{c}{Live Alone} & \multicolumn{1}{c}{Live w/ Children} & \multicolumn{1}{c}{Only Elderly} & \multicolumn{1}{c}{Visits\textsuperscript{\$\dagger\$}} & \multicolumn{1}{c}{Weekly Hours} & \multicolumn{1}{c}{Health Visits\textsuperscript{\$\dagger\$}} \\ " _n
    file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}" _n
    file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} \\ \toprule" _n
    * Panel A: Pooled
    file write sm "\underline{\textit{Panel A: Pooled}} \\ " _n
    file write sm "\textit{Treat \$\times\$ 1998} & `b98_p_wh' & `b98_p_la' & `b98_p_wc' & `b98_p_oe' & & `b98_p_eob' & \\ " _n
    file write sm " & (`se98_p_wh') & (`se98_p_la') & (`se98_p_wc') & (`se98_p_oe') & & (`se98_p_eob') & \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "\textit{Treat \$\times\$ 1999} & `b99_p_wh' & `b99_p_la' & `b99_p_wc' & `b99_p_oe' & `b99_p_tv' & `b99_p_eob' & `b99_p_tveo' \\ " _n
    file write sm " & (`se99_p_wh') & (`se99_p_la') & (`se99_p_wc') & (`se99_p_oe') & (`se99_p_tv') & (`se99_p_eob') & (`se99_p_tveo') \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "Control Mean (1997) & `cmn_p_wh' & `cmn_p_la' & `cmn_p_wc' & `cmn_p_oe' & & `cmn_p_eob' & \\ " _n
    file write sm "Control Mean (1999) & & & & & `cmn_p_tv' & & `cmn_p_tveo' \\ " _n
    file write sm "Obs & `N_p_wh' & `N_p_la' & `N_p_wc' & `N_p_oe' & `N_p_tv' & `N_p_eob' & `N_p_tveo' \\ " _n
    file write sm "  & & & & & & & \\ " _n
    * Panel B: Females
    file write sm "\underline{\textit{Panel B: Females}} \\ " _n
    file write sm "\textit{Treat \$\times\$ 1998} & `b98_f_wh' & `b98_f_la' & `b98_f_wc' & `b98_f_oe' & & `b98_f_eob' & \\ " _n
    file write sm " & (`se98_f_wh') & (`se98_f_la') & (`se98_f_wc') & (`se98_f_oe') & & (`se98_f_eob') & \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "\textit{Treat \$\times\$ 1999} & `b99_f_wh' & `b99_f_la' & `b99_f_wc' & `b99_f_oe' & `b99_f_tv' & `b99_f_eob' & `b99_f_tveo' \\ " _n
    file write sm " & (`se99_f_wh') & (`se99_f_la') & (`se99_f_wc') & (`se99_f_oe') & (`se99_f_tv') & (`se99_f_eob') & (`se99_f_tveo') \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "Control Mean (1997) & `cmn_f_wh' & `cmn_f_la' & `cmn_f_wc' & `cmn_f_oe' & & `cmn_f_eob' & \\ " _n
    file write sm "Control Mean (1999) & & & & & `cmn_f_tv' & & `cmn_f_tveo' \\ " _n
    file write sm "Obs & `N_f_wh' & `N_f_la' & `N_f_wc' & `N_f_oe' & `N_f_tv' & `N_f_eob' & `N_f_tveo' \\ " _n
    file write sm "  & & & & & & & \\ " _n
    * Panel C: Males
    file write sm "\underline{\textit{Panel C: Males}} \\ " _n
    file write sm "\textit{Treat \$\times\$ 1998} & `b98_m_wh' & `b98_m_la' & `b98_m_wc' & `b98_m_oe' & & `b98_m_eob' & \\ " _n
    file write sm " & (`se98_m_wh') & (`se98_m_la') & (`se98_m_wc') & (`se98_m_oe') & & (`se98_m_eob') & \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "\textit{Treat \$\times\$ 1999} & `b99_m_wh' & `b99_m_la' & `b99_m_wc' & `b99_m_oe' & `b99_m_tv' & `b99_m_eob' & `b99_m_tveo' \\ " _n
    file write sm " & (`se99_m_wh') & (`se99_m_la') & (`se99_m_wc') & (`se99_m_oe') & (`se99_m_tv') & (`se99_m_eob') & (`se99_m_tveo') \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "Control Mean (1997) & `cmn_m_wh' & `cmn_m_la' & `cmn_m_wc' & `cmn_m_oe' & & `cmn_m_eob' & \\ " _n
    file write sm "Control Mean (1999) & & & & & `cmn_m_tv' & & `cmn_m_tveo' \\ " _n
    file write sm "Obs & `N_m_wh' & `N_m_la' & `N_m_wc' & `N_m_oe' & `N_m_tv' & `N_m_eob' & `N_m_tveo' \\ " _n
    file write sm "\bottomrule" _n
    file write sm "\end{tabular}"
    file close sm
}

*============================================================
* SLIDE TABLE: T3_experimental — Pooled only
* Same as T3_experimental but Panel A (Pooled) only.
* Output: $tables/T3_experimental_slide.tex
*============================================================
{
    cap file close sm
    file open sm using "$tables/T3_experimental_slide.tex", write replace
    file write sm "\begin{tabular}{lccccccc} \hline \hline" _n
    file write sm "& \multicolumn{5}{c}{\textit{All Eligible Older Adults (65+)}} & \multicolumn{2}{c}{\textit{Older-Adults-Only Households}} \\ \cmidrule(lr){2-6}\cmidrule(lr){7-8}" _n
    file write sm "& \multicolumn{1}{c}{\textit{Labor}} & \multicolumn{3}{c}{\textit{Living Arrangements}} & \multicolumn{1}{c}{\textit{Health}} & \multicolumn{1}{c}{\textit{Labor}} & \multicolumn{1}{c}{\textit{Health}} \\ \cmidrule(lr){2-2}\cmidrule(lr){3-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}" _n
    file write sm "& \multicolumn{1}{c}{Weekly Hours} & \multicolumn{1}{c}{Live Alone} & \multicolumn{1}{c}{Live w/ Children} & \multicolumn{1}{c}{Only Elderly} & \multicolumn{1}{c}{Visits\textsuperscript{\$\dagger\$}} & \multicolumn{1}{c}{Weekly Hours} & \multicolumn{1}{c}{Health Visits\textsuperscript{\$\dagger\$}} \\ " _n
    file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}" _n
    file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} \\ \toprule" _n
    file write sm "\textit{Treat \$\times\$ 1998} & `b98_p_wh' & `b98_p_la' & `b98_p_wc' & `b98_p_oe' & & `b98_p_eob' & \\ " _n
    file write sm " & (`se98_p_wh') & (`se98_p_la') & (`se98_p_wc') & (`se98_p_oe') & & (`se98_p_eob') & \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "\textit{Treat \$\times\$ 1999} & `b99_p_wh' & `b99_p_la' & `b99_p_wc' & `b99_p_oe' & `b99_p_tv' & `b99_p_eob' & `b99_p_tveo' \\ " _n
    file write sm " & (`se99_p_wh') & (`se99_p_la') & (`se99_p_wc') & (`se99_p_oe') & (`se99_p_tv') & (`se99_p_eob') & (`se99_p_tveo') \\ " _n
    file write sm "  & & & & & & & \\ " _n
    file write sm "Control Mean (1997) & `cmn_p_wh' & `cmn_p_la' & `cmn_p_wc' & `cmn_p_oe' & & `cmn_p_eob' & \\ " _n
    file write sm "Control Mean (1999) & & & & & `cmn_p_tv' & & `cmn_p_tveo' \\ " _n
    file write sm "Obs & `N_p_wh' & `N_p_la' & `N_p_wc' & `N_p_oe' & `N_p_tv' & `N_p_eob' & `N_p_tveo' \\ " _n
    file write sm "\bottomrule" _n
    file write sm "\end{tabular}"
    file close sm
}
di "Table exported to: $tables/T3_experimental_slide.tex"

* NOTE: T3 layout: cols (1)-(5) are the full eligible age-65+ sample (weekly hours,
* living arrangements, total visits); cols (6)-(7) restrict to OLDER-ADULTS-ONLY
* households (only_elderly_base==1, composition fixed at 1997) -- the direct-transfer
* subsample -- and report weekly hours (_eob) and total visits (_tveo). The two
* sample groups are separated by a spanning header. The former age-51+ visits column
* was removed. All elderly-only locals are computed before the write block.

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

collapse (mean) total_gas food food98 food99 porc_food* porc_med* medicine medicine98 medicine99 p_* contba hhsize kid* eligible only_elderly_base clavemun claveofi hh_* (sum) elderly97, by(hhid year)
replace elderly97=1 if elderly97>1

* Binary eligibility flag for the older-adults-only-household expenditure table
cap drop elig_bin
gen elig_bin = (eligible==1) if !missing(eligible)
label var elig_bin "Eligible (poor) household"

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
    file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
    file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
    file write sm "\textit{Treatment \$\times\$ 1999 (no elderly)} & `b99_food' & `b99_pf' & `b99_med' & `b99_pm' \\ " _n
    file write sm " & (`se99_food') & (`se99_pf') & (`se99_med') & (`se99_pm') \\ " _n
    file write sm "  & & & & \\ " _n
    file write sm "\textit{Differential (elderly HH)} & `b99e_food' & `b99e_pf' & `b99e_med' & `b99e_pm' \\ " _n
    file write sm " & (`se99e_food') & (`se99e_pf') & (`se99e_med') & (`se99e_pm') \\ " _n
    file write sm "  & & & & \\ " _n
    file write sm "Control Mean (1998) & `cmn98_food' & `cmn98_pf' & `cmn98_med' & `cmn98_pm' \\ " _n
    file write sm "Observations & `N_at6_food' & `N_at6_pf' & `N_at6_med' & `N_at6_pm' \\ \bottomrule" _n
    file write sm "\end{tabular}"
    file close sm
}

*============================================================
* APPENDIX TABLE: Same layout as AT6 (HH food/health expenditures) but on
* OLDER-ADULTS-ONLY households (only_elderly_base==1), with the differential
* by ELIGIBILITY (eligible vs. ineligible) instead of elderly presence. Only
* eligible households receive the direct food transfer, so the eligible
* differential isolates its role. DiD (year x treat x elig), base 1998,
* municipality FE, SEs clustered at locality.
* Output: $tables/appendix/AT_elderly_transfer.tex
*============================================================
foreach yvar of local hh_outcomes {
    local col ""
    if "`yvar'" == "food"      local col food
    if "`yvar'" == "porc_food" local col pf
    if "`yvar'" == "medicine"  local col med
    if "`yvar'" == "porc_med"  local col pm
    if "`col'" != "" {
        * Control mean 1998 for the ineligible control group
        summarize `yvar' if year==98 & contba==0 & elig_bin==0 & only_elderly_base==1 ///
            & !missing(`yvar', year, contba, elig_bin, hhid, claveofi)
        local cmn_et_`col' : di %9.3f r(mean)

        reghdfe `yvar' i.year##i.contba##i.elig_bin ///
            if only_elderly_base==1 & !missing(`yvar', year, contba, elig_bin, hhid, claveofi), ///
            absorb(clavemun) vce(cluster claveofi)

        * Treatment × 1999 for ineligible HH (base = 1998, elig_bin=0)
        local aux : di %9.3f _b[99.year#1.contba]
        local tstat = abs(_b[99.year#1.contba] / _se[99.year#1.contba])
        if `tstat' >= 2.576      local b_et_`col' = trim("`aux'") + "***"
        else if `tstat' >= 1.960 local b_et_`col' = trim("`aux'") + "**"
        else if `tstat' >= 1.645 local b_et_`col' = trim("`aux'") + "*"
        else                     local b_et_`col' = trim("`aux'")
        local se_et_`col' : di %9.3f _se[99.year#1.contba]
        * Differential for eligible HH (triple interaction)
        local aux : di %9.3f _b[99.year#1.contba#1.elig_bin]
        local tstat = abs(_b[99.year#1.contba#1.elig_bin] / _se[99.year#1.contba#1.elig_bin])
        if `tstat' >= 2.576      local be_et_`col' = trim("`aux'") + "***"
        else if `tstat' >= 1.960 local be_et_`col' = trim("`aux'") + "**"
        else if `tstat' >= 1.645 local be_et_`col' = trim("`aux'") + "*"
        else                     local be_et_`col' = trim("`aux'")
        local see_et_`col' : di %9.3f _se[99.year#1.contba#1.elig_bin]
        local N_et_`col'  : di %12.0fc e(N)
    }
}

{
    cap file close et
    file open et using "$tables/appendix/AT_elderly_transfer.tex", write replace
    file write et "\begin{tabular}{lcccc} \hline \hline" _n
    file write et "& \multicolumn{2}{c}{Food} & \multicolumn{2}{c}{Health} \\ " _n
    file write et "\cmidrule(lr){2-3}\cmidrule(lr){4-5}" _n
    file write et "& \multicolumn{1}{c}{Log} & \multicolumn{1}{c}{Share (\%)} & \multicolumn{1}{c}{Log} & \multicolumn{1}{c}{Share (\%)} \\ " _n
    file write et "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
    file write et "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
    file write et "\textit{Treatment \$\times\$ 1999 (ineligible)} & `b_et_food' & `b_et_pf' & `b_et_med' & `b_et_pm' \\ " _n
    file write et " & (`se_et_food') & (`se_et_pf') & (`se_et_med') & (`se_et_pm') \\ " _n
    file write et "  & & & & \\ " _n
    file write et "\textit{Differential (eligible)} & `be_et_food' & `be_et_pf' & `be_et_med' & `be_et_pm' \\ " _n
    file write et " & (`see_et_food') & (`see_et_pf') & (`see_et_med') & (`see_et_pm') \\ " _n
    file write et "  & & & & \\ " _n
    file write et "Control Mean (1998) & `cmn_et_food' & `cmn_et_pf' & `cmn_et_med' & `cmn_et_pm' \\ " _n
    file write et "Observations & `N_et_food' & `N_et_pf' & `N_et_med' & `N_et_pm' \\ \bottomrule" _n
    file write et "\end{tabular}"
    file close et
}
di "Table exported to: $tables/appendix/AT_elderly_transfer.tex"




/*


//keep databases with all ages and all variables including new ones created

save "`root'/Temp/aging_experiment", replace

