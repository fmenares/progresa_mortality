/******************************************************************************
PREVIOUS DO FILES: 0.crosswalk_mun_1995-2018_2020.do
INPUT DATA: 
0.CROSSWALK DATA:
SUPER MUNICIPALITY
use $ensanut/datasets/crosswalk_super_mun_id_2020.dta, clear
SUPER LOCALITY
crosswalk_super_loc_id_1995.dta -- locality-level analogue of
crosswalk_super_mun_id_1990.dta below. NOT used by section 3 (it
harmonizes through 2018, more than this project needs) -- section 3
instead builds its own cutoff-restricted crosswalk directly from
TablaEquivalencia.dta (also in $data); see section 3's own header
for details.

1. Municipality level Margination Indexes (MI) from CONAPO
1.1 Base_Indice_de_marginacion_municipal_90-15.csv 
1.2 IMM_2020.csv
1.3 Base_Indice_de_marginacion_localidad_90-10.csv 
OUTPUT DATA:
1. Interpolation of the Margination Index for all years and municipalities
(1995-2018) recoded back to 1995
1.1 MI_mun_1995-2018vars_ipolate_recoded.dta
2. Interpolation of the Margination Index for all years and localities
(1995-2018) recoded back to 1995
2.1 MI_loc_1995_recoded.dta (one row per locality)
2.2 MI_locshare_1995_mun.dta (P&V (2023) eq.-4 locality-marginality
    percentile shares, super-locality-harmonized, collapsed to the
    municipality -- one row per cve_ent_mun_super)
CODE: Felipe Menares
DATE: 6/24/2021
usefule sources:
1. Base_Indice_de_marginacion_municipal_by_year.do (Susan Parker)
2. linear_interpolation_1990_2015.do (Jorge Peniche/Emma Aguila)
*******************************************************************************/
	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global codes "C:\Users\FELIPEME\Documents\projects\progresa_mortality\codes\"




capture log close
*log using "$ensanut/programs/fmenares/datasets/logs/02_margination_index_interpolation_recoded", replace text

local municipality =1

/***********************************************************
1.1 MARGINATION INDEX RECODING BACK TO 1995 AND INTERPOLATION
WITH THE SUPER MUNICIPALITY ID
*************************************************************/
if `municipality' == 1 {
foreach year in 1995 1990 {
*local year = 1995
*Margination Index data set: 2020
import delimited "$data/IMM_2020.csv", clear
ren (im_2020 gm_2020 sbasc nom_ent nom_mun) (im gm sprim ent mun)
g year = 2020
replace pob_tot=subinstr(pob_tot, " ", "", .)
g ovsdse=.
destring(analf sprim ovsde ovsee ovsae vhac ovpt pl5000 po2sm im pob_tot ///
ovsdse pob_tot), replace
*ovsdse is not for 2020. I might not use it.
tostring(cve_mun), g(cve_ent_mun)
replace cve_ent_mun = "0"+cve_ent_mun if length(cve_ent_mun) == 4
drop cve_mun cve_ent
g cve_ent = substr(cve_ent_mun, 1, 2)
g cve_mun = substr(cve_ent_mun, 3, 3)
tempfile im_2020
save `im_2020' 
*Margination Index data set: 1990 - 2015
import delimited "$data/Base_Indice_de_marginacion_municipal_90-15.csv", clear
count if cve_ent=="-" & cve_mun =="-"
*5 missing
drop if cve_mun == "-"
g year=año
local vars vp analf sprim ovsde ovsee ovsae vhac ovpt pl5000 po2sm ovsd ///
ovsdse im gm ind0a100

*Checking missignes and replacing characters to missing for each of the variables
foreach var in `vars' {
di "`var'"
count if `var'=="-" 
count if `var'=="N. D." 
count if `var'=="" 
replace `var'="." if `var'=="-"
replace `var'="." if `var'=="N. D."
replace `var'="." if `var'==""
}
*The cve_mun variable includes the entity
g cve_ent_mun = cve_mun
replace cve_ent_mun = "0"+cve_mun if length(cve_mun) == 4
drop if cve_ent_mun==""
drop cve_ent cve_mun 
g cve_ent = substr(cve_ent_mun, 1, 2)
g cve_mun = substr(cve_ent_mun, 3, 3)
destring(vp analf sprim ovsde ovsee ovsae vhac ovpt pl5000 ///
po2sm im ovsd ovsdse pob_tot), replace

*We will need to create the GM
bys gm: sum im if year == 1990 & gm!="."

append using `im_2020'

local vars analf sprim ovsde ovsee ovsae vhac ovpt pl5000 po2sm ovsd ovsdse im pob_tot

*Checkin missignes by year
foreach var in `vars' {
di "`var'"
ta year if `var'==. 
}

*this is the national pop
drop if cve_mun == ""

*replacing missing variables with alternatives variables
replace ovsde=ovsdse if ovsdse!=. & ovsde==.
replace ovsde=ovsd if ovsd!=. & ovsde==.

keep cve_ent cve_mun cve_ent_mun year analf sprim ovsde ovsee ovsae vhac ///
ovpt pl5000 po2sm im gm pob_tot

/*STANDARIZATION OF THE IM*/
g im_std = im
*the IM between 1990-2015 is already standaraized to a mean of 0 and sd of 1.
*then, I only need to standaraized 2020
sum im if year == 2020, d
*I have to invert the standarization, because for previous years the order is
*defined from the negative as the very low to the positives as very high margination.
replace im_std = ((im-r(mean))/r(sd))*-1 if year  == 2020
replace gm = "Muy alto" if gm == "Muy Alto"
replace gm = "Muy bajo" if gm == "Muy Bajo"
drop if gm == "."
replace im_std = round(im_std,.001)
label def gm_lbl 1 "Very Low" 2 "Low" 3 "Medium" 4 "High" 5 "Very High", replace
encode gm, g(gm_2)
recode gm_2 (1=4) (5=1) (4=5)
drop gm 
ren gm_2 gm
label val gm gm_lbl
bys gm: sum im im_std if year == 2020
bys gm: sum im_std if year == 1995
/* cutpoints GM 1995 based on IM 1995 */
*CITE THIS from webpage, but this were also compute from the data above
g gm_1995 = "Very Low" if im_std < -1.328
replace gm_1995 = "Low" if inrange(im_std,-1.328, -.767)
replace gm_1995 = "Medium" if inrange(im_std, -.766, .355)
replace gm_1995 = "High" if inrange(im_std, .356, .915)
replace gm_1995 = "Very High" if im_std > .915
encode gm_1995, g(gm_1995_2)
recode gm_1995_2 (1=4) (5=1) (4=5)
drop gm_1995
ren gm_1995_2 gm_1995
label val gm_1995 gm_lbl
ta gm_1995 gm if year!=1990  
bys year: ta gm_1995 gm 
*After the standarization, the GM_1995 looks ok. We will implement this at the
*end of the code, after we are done with the recoding and interpolation.
drop im gm_1995
ren im_std im
sort cve_ent_mun year

/********************************************************
1.2 RECODING MUNICIPALITIES
********************************************************/
*1. This part recodes the new municipalities to the municipalities of origin
*2. For that purpouse, uses a crosswalk in order to recover the mun of origin
*3. Once the mun is recoded, the MI and other variables are weighted in 
*order to recalculate the MI for the municipality of origin
*4. Once we have 1 obs per muni of origin and year we interpolate.
merge m:1 cve_ent cve_mun using ///
$data/crosswalk_super_mun_id_`year'.dta
drop if _==2
replace cve_ent_mun_super = cve_ent_mun  if _!=3

*adding up pob tot by municipality recoded
bys cve_ent_mun_super year: egen pob_tot_recoded =total(pob_tot)
*calculating weight for the MI, using size of the mun of origin and new mun, 
*over the total size of the mun after recoding
g weight = pob_tot/pob_tot_recoded
local vars analf ovsae ovsee ovpt sprim po2sm ovsde pl5000 vhac im
*weighting the MI, and the rest of the variables by the size of the 
*mun of origin, with respect to the total new size. 
foreach var in `vars' {
g  `var'_w = `var'*weight
replace `var'_w=0 if `var'_w==.
drop `var'
ren `var'_w `var'
}

collapse (sum) pob_tot `vars', by(cve_ent_mun_super year)

*I don't have the same number of municipalities for 1990 than the rest. This differ
*in the number of new municipalities created between 1990-1995 (26)
ta year
preserve
	bys cve_ent_mun_super (year): g aux = _n
	bys cve_ent_mun_super: egen index = max(aux)
	keep if index == 6
	keep cve_ent_mun_super 
	duplicates drop
	list
restore
/***************************************************************
1.3 INTERPOLATION 1990-2020
****************************************************************/

preserve
	reshape wide analf sprim ovsde ovsee ovsae vhac ovpt pl5000 po2sm im ///
	pob_tot, i(cve_ent_mun_super) j(year)
	sort cve_ent_mun_super
	tempfile wide_im_1990_2020
	save `wide_im_1990_2020'
restore

destring(cve_ent_mun_super), g(cve_ent_mun_super2)
tsset cve_ent_mun_super2 year
tsfill
sort cve_ent_mun_super2
replace cve_ent_mun_super = cve_ent_mun_super[_n-1] ///
if cve_ent_mun_super == ""
merge m:1 cve_ent_mun_super using `wide_im_1990_2020'
drop _
sort cve_ent_mun_super year
order cve_ent_mun_super year

*Interpolation for all the years between 1990-2000
** Ipolate variables with data in all quinquenal years - IPOLATE 90-95 and 95-00
quiet{
** Ipolate values not included in year 1995 - IPOLATE 1990 - 2000


/*
bys cve_ent_mun_super: ipolate pl5000 year if year <=2000, g(pl5000_1995)
replace pl5000 = pl5000_1995 if year == 1995
drop HH_1995
*/


foreach var2 in sprim vhac ovpt pl5000 po2sm {
    replace `var2' = . if year == 1995
	by cve_ent_mun_super: ipolate `var2' year if inrange(year, 1990, 2000), ///
	g(`var2'_ip)
	replace `var2' = `var2'_ip if `var2' ==.
	drop `var2'_ip
}	



foreach var2 in sprim vhac ovpt pl5000 po2sm {
	by cve_ent_mun_super: ipolate `var2' year if inrange(year, `year', 2000), ///
	g(`var2'_ip)
	replace `var2' = `var2'_ip if `var2' ==.
	drop `var2'_ip
}	
	
	** Ipolate variables with data in all quinquenal years from 2000 onwards

	foreach var2 in analf ovsde ovsee ovsae im sprim vhac ovpt pl5000 po2sm pob_tot {
		by cve_ent_mun_super: ipolate `var2' year, g(`var2'_ip)
		replace `var2' = `var2'_ip if `var2' ==.
	}
	
}

keep cve_ent_mun_super year analf sprim ovsde ovsee ovsae ovpt po2sm vhac pl5000 im pob_tot

sort cve_ent_mun_super year
*I drop variables interpolated after 2018 (Progresa data is until 2018.)
ren im im_mun

drop if year < `year'

preserve
	keep if year == `year'
	ren im_mun im_mun_`year'
	ren pl5000 pl5000_`year'
	keep cve_ent_mun_super im_mun_`year' pl5000_`year'
sort cve_ent_mun_super
	tempfile m_index
	save `m_index'
restore

merge m:1 cve_ent_mun_super using `m_index', nogen
sort cve_ent_mun_super year

if `year' == 1995 {
g gm_1995 = "Very Low" if im_mun_1995 < -1.328
replace gm_1995 = "Low" if inrange(im_mun_1995,-1.328, -.767)
replace gm_1995 = "Medium" if inrange(im_mun_1995, -.766, .35599)
replace gm_1995 = "High" if inrange(im_mun_1995, .356, .915)
replace gm_1995 = "Very High" if im_mun_1995 > .915
encode gm_1995, g(gm_mun_1995)
recode gm_mun_1995 (1=4) (5=1) (4=5)
drop gm_1995
label val gm_mun_1995 gm_lbl
ta year gm_mun_1995, miss
bys gm_mun_1995: sum im_mun_1995
sum im_mun, d
}

if `year' == 1990 {
g gm_1990 = "Very Low" if im_mun_1990 < -1.59
replace gm_1990 = "Low" if inrange(im_mun_1990,-1.586, -.504)
replace gm_1990 = "Medium" if inrange(im_mun_1990, -.5, .042)
replace gm_1990 = "High" if inrange(im_mun_1990, .045, 1.132)
replace gm_1990 = "Very High" if im_mun_1990 > 1.136
encode gm_1990, g(gm_mun_1990)
recode gm_mun_1990 (1=4) (5=1) (4=5)
drop gm_1990
label val gm_mun_1990 gm_lbl
ta year gm_mun_1990, miss
bys gm_mun_1990: sum im_mun_1990
sum im_mun, d
}


*** Labeling
	lab var analf "% illiterate population - mun"
	lab var sprim "% with primary education - mun"
	lab var ovsde "% without sweage nor toilette - mun"
	lab var ovsee "% without electricity - mun"
	lab var ovsae "% without potable/running water - mun"
	lab var vhac "% of houses overcrowded - mun"
	lab var ovpt "% of houses with dirt floor - mun"
	lab var pl5000 "% of pop in localities below 5000 people - mun"
	lab var po2sm "% earning less than 2 min wage - mun"
	lab var im_mun "margination index - mun"
	label var pob_tot "Population (Interpolated)"
	label var im_mun_`year' "margination index - mun - `year' (baseline)"
	label var gm_mun_`year' "Grado de marginacion in `year' (baseline))"
	label var pl5000_`year' "% of pop in localities <5000 - mun - `year' (baseline)"
	
sort cve_ent_mun_super
save "$data/MI_mun_ipolate_recoded_`year'.dta", replace

}
}

/***********************************************************
2. LOCALITY-LEVEL MARGINATION INDEX (CONAPO), 1995 CROSS-SECTION
Mirrors the cleaning spirit of the municipal-level block above (missing-
marker handling, destringing, geographic-code parsing), and follows
Parker & Vogl's (2023) own use of this index in their replication code
(01_create_municipal_level_indicators.do / 04_rollout_locality.do):
raw CVE_LOC packs municipality (3 digits) + locality (4 digits) into a
single numeric ID. P&V use the raw locality/municipality codes directly
and do NOT harmonize locality (or municipality) boundaries themselves --
only the municipality piece is harmonized here, via the crosswalk already
used elsewhere in this project (crosswalk_super_mun_id_1990.dta), so that
downstream code needing to collapse locality-level rows up to our
harmonized municipality id (the iml_loc_mun aggregate; the D0b locality-
composition-share control) has cve_ent_mun_super ready to merge on.

Only the 1995 cross-section is built here -- the baseline year every
current downstream use in 02_mortality.do actually needs (D0b, the
municipality-level iml_loc_mun/iml_loc_mun_bin aggregate, and the
locality-level P&V Figure-2 replication all restrict to year==1995). A
fuller 1995-2018 interpolation, analogous to the municipal block above,
is not built since nothing currently consumes it -- extend this section
the same way (tsset/tsfill/ipolate by cve_ent_mun_super or cve_loc) if a
future use needs additional years.

ASSUMPTION FLAG: the exact raw column names below (CVE_ENT, CVE_MUN,
CVE_LOC, iml, TOT_VIV, POB_TOT, año) match what this project's existing
code in 02_mortality.do already assumed for this file (D0b, iml_loc_mun,
AF_pv_fig2_locality_replication) before this refactor. If `describe`
after the import below shows different names, adjust the renames in this
section only -- everything downstream in 02_mortality.do now reads the
already-cleaned output file and does not need to change.

INPUT: Base_marginacion_localidad_90-10.csv (in $data)
OUTPUT: MI_loc_1995_recoded.dta -- one row per locality (cve_ent, cve_mun,
cve_loc), with iml (locality marginality index), TOT_VIV (1995 dwelling
count), POB_TOT (1995 population), and cve_ent_mun_super (harmonized
municipality id, for collapsing to municipality level).
*************************************************************/
local locality = 1
if `locality' == 1 {

import delimited "$data/Base_marginacion_localidad_90-10.csv", clear varnames(1)

* CONAPO's raw CSVs commonly encode missing as "-" or "N. D." rather than
* a true empty/numeric missing -- same idiom as the municipal file above.
* `import delimited` may read column names in either case depending on
* the file/Stata version; the `cap rename` pairs below normalize both
* possibilities to the CVE_ENT/CVE_MUN/CVE_LOC/TOT_VIV/POB_TOT/año
* spelling the rest of this section (and, before this refactor, the
* inline code in 02_mortality.do) expects.
cap rename cve_ent CVE_ENT
cap rename cve_mun CVE_MUN
cap rename cve_loc CVE_LOC
cap rename tot_viv TOT_VIV
cap rename pob_tot POB_TOT
cap rename ano año

foreach var in iml TOT_VIV POB_TOT {
    cap confirm string variable `var'
    if !_rc {
        replace `var' = "." if `var' == "-"
        replace `var' = "." if `var' == "N. D."
        replace `var' = "." if `var' == ""
        destring `var', replace
    }
}

keep if año == 1995
di "`c(N)' localities in the 1995 cross-section (Base_marginacion_localidad_90-10.csv)"

* CVE_LOC packs municipality (3 digits) + locality (4 digits) into one
* numeric ID -- same field parsing P&V's own 04_rollout_locality.do uses,
* and the same parsing previously applied inline (now removed) in
* 02_mortality.do's D0b/iml_loc_mun/Fig-2-locality blocks.
gen id = string(CVE_LOC, "%12.0f")
gen CVE_MUNICIPIO = real(substr(id, -7, 3))
gen CVE_LOCALIDAD = real(substr(id, -4, 4))
drop CVE_MUN CVE_LOC id
rename CVE_MUNICIPIO CVE_MUN
rename CVE_LOCALIDAD loc

count if missing(iml)
di "`r(N)' localities missing the continuous marginality index (iml)"

rename CVE_ENT cve_ent
rename CVE_MUN cve_mun
rename loc cve_loc
cap tostring cve_ent, replace format(%02.0f)
cap tostring cve_mun, replace format(%03.0f)
cap tostring cve_loc, replace format(%04.0f)
duplicates drop cve_ent cve_mun cve_loc, force

* Harmonized municipality id -- our project's own addition (P&V do not
* harmonize boundaries themselves), needed so downstream code can collapse
* these locality-level rows up to our municipality panel's cve_ent_mun_super.
merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", ///
    keepusing(cve_ent_mun_super) nogenerate
count if missing(cve_ent_mun_super)
di "`r(N)' localities failed to match the cve_ent_mun_super crosswalk on (cve_ent, cve_mun) -- falling back to the raw (unharmonized) cve_ent+cve_mun code for those"

* BUG FIX: the fallback above matches the SAME convention 02_mortality.do's
* own working panel already applies (line ~372/898:
* "replace cve_ent_mun_super = cve_ent + cve_mun if cve_ent_mun_super == \"\"").
* This fallback was previously MISSING here, so unmatched localities were
* left with cve_ent_mun_super == "" -- during section 3's collapse below,
* this would pool MULTIPLE unrelated municipalities' localities into one
* bogus empty-string group, which then could never match the main working
* panel (which never has a truly empty cve_ent_mun_super after its own
* fallback) -- silently producing entirely missing Lshare_pc* for every
* affected municipality once merged in 02_mortality.do. This is very
* likely the source of the huge CIs originally flagged on AF_ses_trend
* Spec 4 -- confirmed as a real merge-coverage bug, not just a modeling
* choice.
replace cve_ent_mun_super = cve_ent + cve_mun if missing(cve_ent_mun_super)

keep cve_ent cve_mun cve_loc cve_ent_mun_super iml TOT_VIV POB_TOT
order cve_ent cve_mun cve_loc cve_ent_mun_super iml TOT_VIV POB_TOT

label var iml "Locality marginality index (1995, CONAPO)"
label var TOT_VIV "Total dwellings (1995)"
label var POB_TOT "Total population (1995)"
label var cve_ent_mun_super "Harmonized municipality id (crosswalk_super_mun_id_1990)"

sort cve_ent cve_mun cve_loc
save "$data/MI_loc_1995_recoded.dta", replace
di "Saved: $data/MI_loc_1995_recoded.dta"

}

/***********************************************************
3. P&V (2023) EQUATION-4 LOCALITY-MARGINALITY PERCENTILE
SHARES (L^p_m) -- FOR THE eq.-4 "LOCALITY-COMPOSITION-SHARE"
TREND CONTROL IN 02_mortality.do's AF_ses_trend.

NOT Figure 2 (the locality-level scatter/lpoly already built via
AF_pv_fig2_locality_replication in 02_mortality.do): this is P&V's
actual Table 2 columns (3)/(7) regression control ("Locality
marg. %-ile shares" in Table 2's footer, equation 4 in the text).
Our earlier iml_loc_mun/iml_loc_mun_bin construct (a single
population-weighted SCALAR, or its quintile, interacted with a
linear year trend) was our own invention, not a P&V replication --
rereading 04_rollout_locality.do confirms there is no year-trend
spec there at all (its Figure 2 is a static 1995 cross-section).
P&V's true eq.-4 control is built entirely differently, in
01_create_municipal_level_indicators.do (lines 358-383):

    egen iml_pctile = cut(iml), group(100)   // 100 national
                                              // percentile bins of
                                              // LOCALITY iml
    tab iml_pctile, gen(iml_pc)              // one 0/1 dummy per bin
    collapse iml_pc* [aw=POB_TOT], by(CVE_EDO CVE_MUN)
      // pop-weighted mean of a 0/1 locality indicator, collapsed to
      // the municipality, IS the population SHARE living in that
      // percentile bin -- this is L^p_m in equation (4).

They enter these shares as an ABSORBED interaction with their
cohort variable, not as explicit reported regressors
(04_analysis2010.do), e.g.:
    a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
i.e. reghdfe's a() partials out cohort-by-share-bin interactions
as high-dimensional fixed effects. 02_mortality.do mirrors this
exactly, substituting our year_1995 event-time variable for their
age97 cohort variable.

HARMONIZATION: the user's pre-built crosswalk_super_loc_id_1995.dta
(id/sl_id/dup, 45,931 obs -- verified via `describe`/`list`) resolves
locality boundary changes all the way through 2018. Per the user, we
instead need to CONTROL the harmonization window ourselves, following
P&V's own approach in 04_rollout_locality.do (lines 50-65): they use
TablaEquivalencia's fecha_act (change date) to restrict to
"only focus on splits between 2000 and 2005" (`keep if year<=2005`),
since their study only needs harmonization through their own rollout
window, not indefinitely into the future. We do the same, but build
our OWN restricted crosswalk directly from TablaEquivalencia.dta
(per the user, also in $data -- 148,259 raw change records, columns
cve_ent_ori/cve_mun_ori/cve_loc_ori [origin code] -> cve_ent_act/
cve_mun_act/cve_loc_act [destination code], fecha_act, cgo_act,
descrip; structure confirmed by inspecting the copy bundled with
P&V's own replication package, "codes/3 replication package/
02_dataanalysis_data/02_dataanalysis/TablaEquivalencia.DTA")
rather than crosswalk_super_loc_id_1995.dta, since the latter has no
date information to restrict by.

CUTOFF: `loc_harmon_cutoff' below is set to 2005, matching P&V's own
choice exactly (04_rollout_locality.do: "keep if year<=2005", per the
user's explicit instruction to use that cutoff).

FILTERING mirrors P&V's exact logic (04_rollout_locality.do lines
66-80): drop records with no destination code (locality disappeared/
was destroyed -- nothing to remap TO), no origin code (newly created/
reactivated -- nothing to remap FROM), and pure name changes (origin
== destination code, no actual reclassification). Verified via direct
inspection of TablaEquivalencia.DTA in this sandbox: within
year<=2005, this leaves 4,921 genuine origin->destination remaps, of
which only 24 origin codes (out of 4,870 distinct) map to MULTIPLE
destinations (genuine 1:many splits) -- these are excluded from the
remap (no single destination is assignable without additional
population-share context, mirroring the ambiguity P&V's own `dup` tag
flags rather than silently resolves) and fall back to the raw code,
same as any locality never reclassified within the window.

OUTPUT: MI_locshare_1995_mun.dta -- one row per cve_ent_mun_super,
with Lshare_pc1 ... Lshare_pc`nq_locshare' (population shares,
summing to 1 within each municipality, of that municipality's
population living in localities in national locality-marginality
percentile bin p).
*************************************************************/
local locshare = 1
if `locshare' == 1 {

cap confirm file "$data/MI_loc_1995_recoded.dta"
if _rc {
    di as error "Locality-share (eq.-4) construction SKIPPED: MI_loc_1995_recoded.dta not found -- run section 2 above first."
}
else {

local loc_harmon_cutoff = 2005

local tablaeq_ok = 0
cap noisily confirm file "$data/TablaEquivalencia.dta"
if _rc {
    di as error "TablaEquivalencia.dta not found in $data -- locality harmonization SKIPPED, falling back to raw (unharmonized) locality codes for this run."
}
else {
    local tablaeq_ok = 1
}

if `tablaeq_ok' {
    preserve
    use "$data/TablaEquivalencia.dta", clear
    gen year = real(substr(fecha_act, 1, 4))
    keep if year <= `loc_harmon_cutoff'

    * Exact P&V filtering (04_rollout_locality.do lines 66-75).
    drop if cve_ent_act == ""
    drop if cve_ent_ori == ""
    drop if cve_ent_ori == cve_ent_act & cve_mun_ori == cve_mun_act & cve_loc_ori == cve_loc_act

    egen id = concat(cve_ent_ori cve_mun_ori cve_loc_ori)
    egen cve_loc_super = concat(cve_ent_act cve_mun_act cve_loc_act)

    * Exclude 1:many splits (a single origin mapping to multiple
    * destinations within the window) -- no single harmonized
    * destination is assignable without additional context.
    duplicates tag id, gen(dup_ori)
    count if dup_ori > 0
    di "`r(N)' TablaEquivalencia rows (year<=`loc_harmon_cutoff'') excluded as 1:many splits -- no single harmonized destination assignable"
    drop if dup_ori > 0

    keep id cve_loc_super
    duplicates drop
    cap noisily isid id
    if _rc {
        di as error "Unexpected duplicate origin ids remain in the restricted TablaEquivalencia remap after filtering (rc=`_rc') -- falling back to unharmonized locality codes for this run."
        local tablaeq_ok = 0
    }
    else {
        tempfile loc_remap
        save `loc_remap'
    }
    restore
}

use "$data/MI_loc_1995_recoded.dta", clear
drop if missing(iml) | missing(POB_TOT)

* --- Harmonize RAW locality codes via P&V's own TablaEquivalencia,
* restricted to year<=`loc_harmon_cutoff' above -- same strategy as
* the municipality panel (crosswalk to a harmonized id, then collapse
* split/merged units together), not dropping unstable units. ---
gen id = cve_ent + cve_mun + cve_loc
if `tablaeq_ok' {
    merge m:1 id using `loc_remap', keep(1 3) nogenerate
    count if missing(cve_loc_super)
    di "`r(N)' localities were never reclassified within year<=`loc_harmon_cutoff'' (or were excluded as a 1:many split) -- keeping their own raw code as cve_loc_super"
    replace cve_loc_super = id if missing(cve_loc_super)
}
else {
    gen cve_loc_super = id
}
drop id

{
    * Pop-weighted collapse to the HARMONIZED (municipality, locality)
    * pair -- same wtsum_iml/POB_TOT logic P&V use after their own
    * TablaEquivalencia merge (04_rollout_locality.do lines 208-211),
    * just cutoff-restricted to year<=`loc_harmon_cutoff' above instead
    * of their own year<=2005.
    gen double wtsum_iml = iml * POB_TOT
    collapse (sum) wtsum_iml POB_TOT, by(cve_ent_mun_super cve_loc_super)
    gen iml = wtsum_iml / POB_TOT
    drop wtsum_iml

    * --- P&V's exact eq.-4 mechanic (01_create_municipal_level_
    * indicators.do lines 358-383), coarsened from their 100 bins to
    * `nq_locshare' -- P&V's 100-bin, ~300k-observation individual-
    * level cross-section with only 5 cohort "time" bins (100x5=500
    * interaction terms) is not comparable to our much smaller
    * municipality-YEAR panel (~1,400 HM municipalities x up to 16
    * years); 100 bins x 16 years = 1,600 terms is not identified at
    * our scale. `nq_locshare' matches the existing quintile convention
    * (nq_ses=5) used for im90_bin/iml_loc_mun_bin in 02_mortality.do --
    * keep the two in sync if either changes.
    local nq_locshare = 5

    egen iml_pctile = cut(iml), group(`nq_locshare')
    tab iml_pctile, gen(Lshare_pc)
    drop iml_pctile iml

    * Pop-weighted mean of each 0/1 percentile-bin indicator, collapsed
    * to the municipality: this IS the population share living in that
    * bin (L^p_m in eq. 4) -- rows sum to 1 across p within each
    * cve_ent_mun_super.
    collapse (mean) Lshare_pc* [aw=POB_TOT], by(cve_ent_mun_super)

    label var Lshare_pc1 "Share of muni. pop. in locality-marginality percentile bin 1 (least marginalized)"
    forval p = 2/`nq_locshare' {
        label var Lshare_pc`p' "Share of muni. pop. in locality-marginality percentile bin `p'"
    }

    sort cve_ent_mun_super
    save "$data/MI_locshare_1995_mun.dta", replace
    di "Saved: $data/MI_locshare_1995_mun.dta (`nq_locshare' locality-marginality percentile-share bins, P&V eq.-4 style)"
}

}
}
