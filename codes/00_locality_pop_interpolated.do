clear
set more off
capture log close


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
	global data "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/70ymas/data/"
	global output  "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\70ymas\"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}

*\Users\felip\Dropbox\R01_MHAS"

/***********************************
1. Localities that change its composition between 2000 and 2015
************************************/
{

import delimited $data/AGEEML_202474143568, clear
gen year =  substr(fecha_act,1,4)
destring(year), replace
/*
B: creation  45,360
C: eliminate  1,309
D: fusion  2,503
E: conurbation  5,625
F: reactivation  1,728
H: change in municipality  1,357
I: change in state  1,857
J: change of size  235
M: change of municipality  1,626
N: Deconurabtion  430
O: defused 413
R: non existant 8,342
T: destroyed 7,662
W: change of name 23,430
*/
*I kept only those that affects the composition of the pop of localities 
*in the period of study: B, C, D, E, F, N, O, R, T
keep if inlist(cgo_act, "B", "C", "D", "E", "F", "N", "O", "R", "T")
ta year
keep if year <= 2011
destring(cve_ent), replace force
drop if cve_ent == .
keep cve_ent cve_mun cve_loc 
duplicates drop

tostring(cve_ent cve_mun cve_loc), replace
replace cve_ent = "" if cve_ent == "."
replace cve_mun = "" if cve_mun == "."
replace cve_loc = "" if cve_loc == "."
replace cve_ent = "0" + cve_ent if length(cve_ent) == 1
replace cve_mun = "0" + cve_mun if length(cve_mun) == 2
replace cve_mun = "00" + cve_mun if length(cve_mun) == 1
replace cve_loc = "0" + cve_loc if length(cve_loc) == 3
replace cve_loc = "00" + cve_loc if length(cve_loc) == 2
replace cve_loc = "000" + cve_loc if length(cve_loc) == 1
egen id = concat(cve_ent cve_mun cve_loc)
destring(id), g(locality) force

save $data/change_localities, replace
}

/***********************************************************
2. MARGINATION INDEX 
*************************************************************/
{

import delimited "$data\marginality_index\Base_marginacion_localidad_90-10.csv", clear
count if cve_ent==. & cve_mun ==. & cve_loc ==.
*recovering cve_mun and cve_loc
g cve_ent_mun = cve_mun
g double cve_ent_mun_loc = cve_loc
replace cve_mun = mod(cve_ent_mun,1000)
replace cve_loc = mod(cve_ent_mun_loc,10000)
g year=año
keep if year >= 2000

tostring(cve_ent cve_mun cve_loc), replace
replace cve_ent = "" if cve_ent == "."
replace cve_mun = "" if cve_mun == "."
replace cve_loc = "" if cve_loc == "."
replace cve_ent = "0" + cve_ent if length(cve_ent) == 1
replace cve_mun = "0" + cve_mun if length(cve_mun) == 2
replace cve_mun = "00" + cve_mun if length(cve_mun) == 1
replace cve_loc = "0" + cve_loc if length(cve_loc) == 3
replace cve_loc = "00" + cve_loc if length(cve_loc) == 2
replace cve_loc = "000" + cve_loc if length(cve_loc) == 1
egen id = concat(cve_ent cve_mun cve_loc)
destring(id), g(locality) force

drop if locality== .

merge m:1 locality using "$data/change_localities"
keep if _merge==1
drop _merge
count if im == .
count if pob_tot == .
*tot_viv is a string because it has asterik for those below a certain number
*gm, check.
keep locality year pob_tot analf sprim vsaguae vsee vpisot poch2sm vsdye vhac iml gm

label def gm_lbl 1 "Very Low" 2 "Low" 3 "Medium" 4 "High" 5 "Very High", replace
encode gm, g(gm_2)
recode gm_2 (1=4) (5=1) (4=5)
drop gml 
ren gm_2 gm


sort locality year
*how many localities have 3 data poins?
bys locality: g a = _n
bys locality: egen max_loc = max(a)
ta max_loc
drop max_loc a
*I will work only with the 2005 localitites to interpolate the rest of the years.
*We loose around 10k locs in 2000 and 2010. We use the 2005 value for the 2000 and 2010.

preserve
keep locality year
keep if year == 2005
drop year
expand 12
bys locality: g year = _n + 1999
tempfile loc_2005
save `loc_2005', replace
restore

merge 1:1 locality year using `loc_2005', keep(2 3) nogen

global vars = "iml gm pob_tot analf sprim  vsaguae vsee vpisot poch2sm vsdye vhac"

foreach var in $vars {
	bys locality (year): replace `var' = `var'[_n+5] if `var' == . & year == 2000
	bys locality (year): replace `var' = `var'[_n-5] if `var' == . & year == 2010
}

preserve
drop gm
	reshape wide pob_tot analf sprim vsaguae vsee vpisot poch2sm vsdye vhac im, ///
	i(locality) j(year)
	sort locality
	tempfile wide_im_2000_2010
	save `wide_im_2000_2010'
restore

merge m:1 locality using `wide_im_2000_2010'

drop _
sort locality year
order locality year

** Ipolate variables with data in all quinquenal years from 2000 onwards

foreach var in $vars  {
		by locality: ipolate `var' year, g(`var'_ip) epolate
		replace `var' = `var'_ip if `var' ==.
	}


bys locality: g gm2005 = gm if year == 2005
bys locality: egen gm_2005 = min(gm2005)
drop gm2005

sort locality year
ren year yod

keep locality yod pob_tot analf sprim vsaguae vsee vpisot poch2sm vsdye vhac gm_2005 iml iml2005 pob_tot2005

ren pob_tot2005 pob_2005
label val gm_2005 gm_lbl

save "$data/locality_im_interpolated_2000_2011", replace


}
/************************************************************
***1.1 PROGRESA (CCT)**
*************************************************************/
use "$SP\Data_Progresa\Benefdata\OriginalLocalityBeneficiaryFile/fams_fase_20134xloc_f.dta", clear

ren (CVE_EDO CVE_MUN CVE_LOC anio) (cve_ent cve_mun cve_loc year)
sort cve_ent cve_mun cve_loc year
*DEFINE PROGRESA BENEFICIARY IN EACH YEAR BASED ON FASES
egen pgbenef1997_old=rowtotal(FASE_1-FASE_2)
egen pgbenef1998_old=rowtotal(FASE_3-FASE_6)
egen pgbenef1999_old=rowtotal(FASE_7-FASE_10)
egen pgbenef2000_old=rowtotal(FASE_11-FASE_12)
egen pgbenef2001_old=rowtotal(FASE_13-FASE_15)
egen pgbenef2002_old=rowtotal(FASE_16-FASE_17)
egen pgbenef2003_old=rowtotal(FASE_18-FASE_19)
egen pgbenef2004_old=rowtotal(FASE_20-FASE_23)
egen pgbenef2005_old=rowtotal(FASE_24-FASE_25)
egen pgbenef2006_old=rowtotal(FASE_26-FASE_28)
egen pgbenef2007_old=rowtotal(FASE_29-FASE_32)
egen pgbenef2008_old=rowtotal(FASE_33-FASE_35)
egen pgbenef2009_old=rowtotal(FASE_38-FASE_39)
egen pgbenef2010_old=rowtotal(FASE_40-FASE_42)
egen pgbenef2011_old=rowtotal(FASE_44-FASE_47)
egen pgbenef2012_old=rowtotal(FASE_48-FASE_50)
*note 2013 does not include all bimesters*
egen pgbenef2013_old=rowtotal(FASE_55-FASE_59)
sort cve_ent cve_mun cve_loc
keep cve_ent cve_mun cve_loc pgbenef*
tempfile pg_benef_old
save `pg_benef_old' 

use "$SP\Data_Progresa\NewData19982016/newProg_98_16.dta", clear
ren (CVE_EDO CVE_MUN CVE_LOC fams) (cve_ent cve_mun cve_loc pgbenef)
keep cve_ent cve_mun cve_loc year pgbenef
reshape wide pgbenef, i(cve_ent cve_mun cve_loc) j(year)
ren cve_ent cve_edo
*For year 2016 we have to update the beneficiares, because they include 
*with and without corresponsability. Previously, benefits were only those with
*corresposnability. This is the scheme whhen all progresa components work altogether
drop pgbenef2016 
/*UPDATE 2016 variables names*/
preserve
		use "$SP\Data_Progresa\NewData19982016/cierre_2016/prospera_2016_fam.dta", clear
		keep  cve_edo cve_mun cve_loc with_corresp 
		rename with_corresp pgbenef2016
		sort cve_edo cve_mun cve_loc
		tempfile data2016		
	save `data2016'
restore
merge 1:1 cve_edo cve_mun cve_loc using `data2016', nogen

merge 1:1 cve_edo cve_mun cve_loc using "$SP\Data_Progresa\NewData19982016/2017_bim6_Nov-Dec\prospera_2017_fam.dta", nogen
ren with_corresp pgbenef2017_new
drop pgbenef_total
merge 1:1 cve_edo cve_mun cve_loc using "$SP\Data_Progresa\NewData19982016/2018_bim4_Jul-Aug\prospera_2018_fam.dta", nogen
ren with_corresp pgbenef2018_new
drop pgbenef_total
forv i=1998/2016 {
ren pgbenef`i' pgbenef`i'_new
}

ren cve_edo cve_ent
keep cve_ent cve_mun cve_loc pgbenef*
sort cve_ent cve_mun cve_loc
merge 1:1 cve_ent cve_mun cve_loc using `pg_benef_old', nogen
tostring(cve_ent cve_mun cve_loc), replace
replace cve_ent = "0" + cve_ent if length(cve_ent) == 1
replace cve_mun = "0" + cve_mun if length(cve_mun) == 2
replace cve_mun = "00" + cve_mun if length(cve_mun) == 1
replace cve_loc = "0" + cve_loc if length(cve_loc) == 3
replace cve_loc = "00" + cve_loc if length(cve_loc) == 2
replace cve_loc = "000" + cve_loc if length(cve_loc) == 1
drop pgbenef*_old
ren (pgbenef*_new) (pgbenef*)
reshape long pgbenef, i(cve_ent cve_mun cve_loc) j(yod)
compress
tempfile benef_pg_int_mun
save `benef_pg_int_mun' , replace
/****************************
1.2 SEGURO POPULAR DATA FILE (PHI) - 2001-2018
***************************/
use "$SP\Data_SeguroPopular/Seguro_Popular_2001-2018.dta", clear
drop name_edo name_mun _m cve_edo_mun_2 cve_edo cve_mun 
ren (cve_edo_mun) (cve_ent_mun)
g cve_ent = substr(cve_ent_mun,1,2)
g cve_mun = substr(cve_ent_mun, 3,3)
drop if cve_ent=="" | cve_mun==""
sort cve_ent cve_mun
sort cve_ent cve_mun
reshape long spbenef, i(cve_ent cve_mun) j(yod)

merge 1:m cve_ent cve_mun yod using `benef_pg_int_mun'
g sp = (spbenef != 0 & spbenef!=.)
drop _ cve_ent_mun
order cve_ent cve_mun cve_loc yod
save $data/sp_pg_benef, replace
collapse sp, by(cve_ent cve_mun yod)
save $data/sp_muni_indicator, replace
****************
*Infrastructure data
***********8

use "$data/Infraestructure01_14/HealthResources_SecretariaSalud_2001_2020.dta", clear
keep clave_entidad clave_municipio clave_localidad tothosp totmobclinic tothealthbrig totmedres totdoctor totnurse year
tostring(clave_entidad), replace
tostring(clave_municipio), replace
tostring(clave_localidad), replace

g cve_ent = clave_entidad
replace cve_ent =  "0" + clave_entidad if length(clave_entidad) == 1

g cve_mun = clave_municipio
replace cve_mun = "00" + clave_municipio if length(clave_municipio) == 1
replace cve_mun = "0" + clave_municipio if length(clave_municipio) == 2

g cve_loc = clave_localidad
replace cve_loc = "000" + clave_localidad if length(clave_localidad) == 1
replace cve_loc = "00" + clave_localidad if length(clave_localidad) == 2
replace cve_loc = "0" + clave_localidad if length(clave_localidad) == 3

collapse (sum) tothosp totmobclinic tothealthbrig totmedres totdoctor totnurse, ///
by(cve_ent cve_mun year)
g cve_ent_mun = cve_ent + cve_mun
merge m:1 cve_ent cve_mun using ///
$R01/FinalData/crosswalks/municipality_level/crosswalk_super_mun_id_1995.dta
replace cve_ent_mun_super = cve_ent_mun if _!=3
*These are municipalities crated after 2018 or not present in ENSANUT
drop if _==2
collapse (sum) tothosp totmobclinic tothealthbrig totmedres totdoctor totnurse, ///
by(cve_ent_mun_super year)
sort cve_ent_mun_super year
preserve
*There is no info for year 2000.
merge 1:m cve_ent_mun_super year using $ensanut/ensanut_beneficiaries_muni.dta
ta year if _==2
ta year if _==2 & year!=2000
bys cve_ent_mun: g aux = _n
ta year if _==2 & year!=2000 & aux == 1
*39 municipalities doesn't have information after 2000
*I will use 2001.
restore 
replace year = 2000 if year == 2001
merge 1:m cve_ent_mun_super year using $ensanut/ensanut_beneficiaries_muni.dta
bys cve_ent_mun: g aux = _n
ta year if _==2 &  aux == 1
*46 municipalities without info after replacing 2000 info with 2001.
drop if _==1
drop _ aux
order tothosp totmobclinic tothealthbrig totmedres totdoctor totnurse, last
label var tothosp "Hospitals N"
label var totmobclinic "Mobile Clinics N"
label var tothealthbrig "Health Brigades No"
label var totmedres "Medical Residents No"
label var totdoctor "Doctors"
label var totnurse "Nurses"


/*********************************
1.3 ***70YMAS DATA FILE (UCT)*** 2007-2018 
SOURCE: SEDESOL
provided by Jorge Peniche
*********************************/
use "$data/70yMas_benef_2007_2018_loc.dta", clear
ren (sta_code mun_code loc_code code) (cve_ent cve_mun cve_loc locality) 
drop if cve_ent=="" | cve_mun==""
destring locality, replace
keep if year <=2011
merge m:1 locality using "$data/population/iter_00_05_10", keepus(pop00 pop05 pop10) keep(3) nogen
*71 localities are not found in ITER 2005, with totallyuing 2014 beneficiaries
destring(pop00 pop05 pop10), replace
egen totpop = rowmin(pop05 pop10)
drop if totpop == .

g covered = 2007 * (totpop < 2500) + ///
             2008 * (inrange(totpop, 2500, 19999)) + ///
			 2009 * (inrange(totpop, 20000, 29999)) + ///
			 2012 * (inrange(totpop, 30000, 99999)) + ///
			 1 * ((totpop >= 100000)) 
*replace covered= 0 if covered == 2012
 

*table covered year, stat(sum benef70ym totpop)

*table covered year, stat(sum benef70ym totpop) stat(count locality)

g treat_2007 = (year == 2007) 
g treat_2008 = (year == 2008)

g treated_first = 2007 * (year == 2007 & covered == 2007) + ///
			2008 * (year == 2008 & covered == 2008) + ///
			2009 * (year == 2009 & covered == 2009) 			

collapse (max) treat_2007 treat_2008 treated_first (sum) benef70ym, by(locality covered)  

save "$data/benef_70ymas", replace
/*
keep if yod == 2007
keep locality yod
duplicates drop
save "$data/benef_70ymas_2007", replace

1. assign treatment based on actual beneficiaries localitites, true treatment
2. covered localitites will be those that get the benefit initially. I can calculate the penetration
3. I will study only those group of localitites that initially get the benefit in 2007
4. I will disregard all other localitites that received benefits later, whther or not was the 2007 or following expansion
5. i will identify my control group based on those elegibile but without beneficiaries in the window of study
5.1 i could try to identify those below 2.5k using 2005/2010 pop and never got the benefit.
5.2 i could do the same with folliwing years, 2008/2009, and combined them if needed. 

*/




/************************
Population Interpolated at the eligibility level
***********************************/

// Clear the current dataset
clear
local year_range = (2010 - 2000 + 2)
local age_range = (90 - 55 + 1)

set obs `year_range'
// Define the dimensions
g year = _n + 2000 - 1
expand `age_range'
bys year : g age = _n + 54
expand 5

bys year age: g covered = _n - 1
replace covered = 2007 if covered == 2
replace covered = 2008 if covered == 3
replace covered = 2009 if covered == 4

save "$data/population_2000_2010_eligibility_age_empty", replace

use "$data/population_2000_2010_eligibility_age.dta", clear
bys covered age: g pop_growth_b = (log(both[_n+1])-log(both))/5
bys covered age: g pop_growth_m = (log(male[_n+1])-log(male))/5
bys covered age: g pop_growth_f = (log(female[_n+1])-log(female))/5

merge 1:1 year age covered using "$data/population_2000_2010_eligibility_age_empty"
sort covered age year

bys covered age (year) : replace pop_growth_b = pop_growth_b[_n-1] if pop_growth_b == .
bys covered age (year) : replace both = both[_n-1] * exp(pop_growth_b) if both == .

bys covered age (year) : replace pop_growth_f = pop_growth_f[_n-1] if pop_growth_f == .
bys covered age (year) : replace female = female[_n-1] * exp(pop_growth_f) if female == .

bys covered age (year) : replace pop_growth_m = pop_growth_m[_n-1] if pop_growth_m == .
bys covered age (year) : replace male = male[_n-1] * exp(pop_growth_f) if male == .

g both_exp_growth = female + male

ren (year age both_exp female male) (yod age_at_death pop_exp pop_female pop_male)

drop  _merge

label var pop_growth_b "exponential growth both sexes"
label var pop_growth_f "exponential growth females"
label var pop_growth_m "exponential growth males"
label var pop_exp "exponential growth both sexes"
label var pop_female "exponential growth females"
label var pop_male "exponential growth males"



save "$data/population_2000_2010_eligibility_age_interpolated", replace



/************************
Population Interpolated at the locality level for all 
localities and 5 year ages groups (65 - 69 vs 70 - 89)
*2000-2005-2010
***********************************/

global years = "2000 2005"
foreach year in $years {
	
	use "$data/INEGI/population/locality/individual_ages/Population_locality_level_`year'.dta", clear
	keep code age_60_both age_61_both age_62_both age_63_both ///
	age_64_both age_65_both age_66_both age_67_both age_68_both ///
	age_69_both age_70_both age_71_both age_72_both age_73_both age_74_both ///
	age_75_both age_76_both age_77_both age_78_both age_79_both age_80_both ///
	age_81_both age_82_both age_83_both age_84_both age_85_both age_86_both ///
	age_87_both age_88_both age_89_both age_60_male age_61_male age_62_male age_63_male ///
	age_64_male age_65_male age_66_male age_67_male age_68_male ///
	age_69_male age_70_male age_71_male age_72_male age_73_male age_74_male ///
	age_75_male age_76_male age_77_male age_78_male age_79_male age_80_male ///
	age_81_male age_82_male age_83_male age_84_male age_85_male age_86_male ///
	age_87_male age_88_male age_89_male age_60_female age_61_female age_62_female age_63_female ///
	age_64_female age_65_female age_66_female age_67_female age_68_female ///
	age_69_female age_70_female age_71_female age_72_female age_73_female age_74_female ///
	age_75_female age_76_female age_77_female age_78_female age_79_female age_80_female ///
	age_81_female age_82_female age_83_female age_84_female age_85_female age_86_female ///
	age_87_female age_88_female age_89_female

	ren (age_60_both age_61_both age_62_both age_63_both ///
	age_64_both age_65_both age_66_both age_67_both age_68_both ///
	age_69_both age_70_both age_71_both age_72_both age_73_both age_74_both ///
	age_75_both age_76_both age_77_both age_78_both age_79_both age_80_both ///
	age_81_both age_82_both age_83_both age_84_both age_85_both age_86_both ///
	age_87_both age_88_both age_89_both age_60_male age_61_male age_62_male age_63_male ///
	age_64_male age_65_male age_66_male age_67_male age_68_male ///
	age_69_male age_70_male age_71_male age_72_male age_73_male age_74_male ///
	age_75_male age_76_male age_77_male age_78_male age_79_male age_80_male ///
	age_81_male age_82_male age_83_male age_84_male age_85_male age_86_male ///
	age_87_male age_88_male age_89_male ///
	age_60_female age_61_female age_62_female age_63_female ///
	age_64_female age_65_female age_66_female age_67_female age_68_female ///
	age_69_female age_70_female age_71_female age_72_female age_73_female age_74_female ///
	age_75_female age_76_female age_77_female age_78_female age_79_female age_80_female ///
	age_81_female age_82_female age_83_female age_84_female age_85_female age_86_female ///
	age_87_female age_88_female age_89_female) (pop60 pop61 pop62 pop63 pop64 pop65 ///
	pop66 pop67 pop68 pop69 pop70 pop71 pop72 pop73 pop74 pop75 pop76 pop77 ///
	pop78 pop79 pop80 pop81 pop82 pop83 pop84 pop85 pop86 pop87 pop88 pop89 ///
	pop_m60 pop_m61 pop_m62 pop_m63 pop_m64 pop_m65 ///
	pop_m66 pop_m67 pop_m68 pop_m69 pop_m70 pop_m71 pop_m72 pop_m73 pop_m74 pop_m75 pop_m76 pop_m77 ///
	pop_m78 pop_m79 pop_m80 pop_m81 pop_m82 pop_m83 pop_m84 pop_m85 pop_m86 pop_m87 pop_m88 pop_m89 ///
	pop_f60 pop_f61 pop_f62 pop_f63 pop_f64 pop_f65 ///
	pop_f66 pop_f67 pop_f68 pop_f69 pop_f70 pop_f71 pop_f72 pop_f73 pop_f74 pop_f75 pop_f76 pop_f77 ///
	pop_f78 pop_f79 pop_f80 pop_f81 pop_f82 pop_f83 pop_f84 pop_f85 pop_f86 pop_f87 pop_f88 pop_f89)
	
	keep code pop* pop_f* pop_m*
	reshape long pop pop_f pop_m, i(code) j(age)
	ren code locality
	
	preserve
	g age_at_death = 60 * (inrange(age, 60, 69)) + ///
					 70 * (inrange(age, 70, 79)) + ///
					 80 * (inrange(age, 80, 89)) 
					 
	collapse (sum) pop pop_f pop_m, by(age_at_death locality)
	
	g yod = `year'
	save "$data/population/pop_locality_60_89_10yr_`year'", replace
	restore
	keep if age >= 60
	g age_at_death = 60 * (inrange(age, 60, 64)) + ///
					 65 * (inrange(age, 65, 69)) + ///
					 70 * (inrange(age, 70, 74)) + ///
					 75 * (inrange(age, 75, 79)) + ///
					 80 * (inrange(age, 80, 84)) + ///
					 85 * (inrange(age, 85, 89))
	collapse (sum) pop pop_f pop_m , by(age_at_death locality)
	
	g yod = `year'
	save "$data/population/pop_locality_60_89_5yr_`year'", replace
}

*2010
{

*5yr
import delimited "$data/INEGI/population/locality/5year/LM575_2010.csv", clear
*ind
*13: 60-64
*18: 85-89
keep if inrange(ind, 13, 18)
*missing counts for a specific cell locality age
replace total = . if total == -6
ren (entidad mun loc ind total sexo) (cve_ent cve_mun cve_loc age_at_death pop sex)

tostring(cve_ent cve_mun cve_loc), replace
replace cve_ent = "0" + cve_ent if length(cve_ent) == 1
replace cve_mun = "0" + cve_mun if length(cve_mun) == 2
replace cve_mun = "00" + cve_mun if length(cve_mun) == 1
replace cve_loc = "0" + cve_loc if length(cve_loc) == 3
replace cve_loc = "00" + cve_loc if length(cve_loc) == 2
replace cve_loc = "000" + cve_loc if length(cve_loc) == 1
egen locality = concat(cve_ent cve_mun cve_loc)

destring(locality), replace

keep locality age_at_death pop sex

reshape wide pop, i(locality age_at_death) j(sex)
ren (pop0 pop1 pop3) (pop pop_m pop_f)

replace age_at_death = 60 if age_at_death == 13
replace age_at_death = 65 if age_at_death == 14
replace age_at_death = 70 if age_at_death == 15
replace age_at_death = 75 if age_at_death == 16
replace age_at_death = 80 if age_at_death == 17
replace age_at_death = 85 if age_at_death == 18

g yod = 2010
compress
save "$data/population/pop_locality_60_89_5yr_2010", replace


*10 year age group
import delimited "$data/INEGI/population/locality/10year/LM575_20250822.csv", clear
*ind
*7: 60-69
*8: 70 - 79
*9: 80-89
keep if inrange(ind, 7, 9)
*

replace total = . if total == -6
ren (entidad mun loc ind total sexo) (cve_ent cve_mun cve_loc age_at_death pop sex)

tostring(cve_ent cve_mun cve_loc), replace
replace cve_ent = "0" + cve_ent if length(cve_ent) == 1
replace cve_mun = "0" + cve_mun if length(cve_mun) == 2
replace cve_mun = "00" + cve_mun if length(cve_mun) == 1
replace cve_loc = "0" + cve_loc if length(cve_loc) == 3
replace cve_loc = "00" + cve_loc if length(cve_loc) == 2
replace cve_loc = "000" + cve_loc if length(cve_loc) == 1
egen locality = concat(cve_ent cve_mun cve_loc)

destring(locality), replace

keep locality age_at_death pop sex
reshape wide pop, i(locality age_at_death) j(sex)
ren (pop0 pop1 pop3) (pop pop_m pop_f)

replace age_at_death = 60 if age_at_death == 7
replace age_at_death = 70 if age_at_death == 8
replace age_at_death = 80 if age_at_death == 9

g yod = 2010
compress
save "$data/population/pop_locality_60_89_10yr_2010", replace

}


/************************
Population Interpolated at the locality level for all 
localities and 5 year ages groups 
*2000-2005-2010
***********************************/

*******************************
*POPULATION CELLS OF 3 OR MORE in 2010
*AGES 65 to 74 2 age_groups)
*******************************

global age_group = "5yr"

foreach age_g in $age_group {


	use "$data/population/pop_locality_60_89_`age_g'_2000", clear
	append using  "$data/population/pop_locality_60_89_`age_g'_2005"
	append using "$data/population/pop_locality_60_89_`age_g'_2010"

preserve
use "$data/deaths_02_15_did_panel", clear
keep if inrange(age_at_death, 65, 74)
drop if cve_loc == 7777 

keep if inlist(covered, 0, 2007)

keep locality 
duplicates drop
tempfile loc_deaths
save `loc_deaths', replace
restore
merge m:1 locality using `loc_deaths'
keep if _==3
*we restrict the age range before dropping the confidential cells
keep if inrange(age_at_death, 65, 74)

g pop10 = (pop == .  & yod == 2010)
bys locality: egen pop_10 = max(pop10)
drop if pop_10 == 1


*where there are one gender pop, i assign the difference with respect total
replace pop_f = pop - pop_m if pop_f == .
replace pop_m = pop - pop_f if pop_m == .
*assign the average proportion of female in 2000 and 2005 to the 2010
g f_p = pop_f/pop
bys locality age_at_death: egen prop_f_age = mean(f_p)
g pop_f_p = pop * prop_f_age
replace pop_f = round(pop_f_p) if pop_f==.
replace pop_m = pop - pop_f if pop_m == .
*assume that there are more women than men just 108 cells
replace pop_f = pop - 1 if pop_f == . 
replace pop_m = pop - pop_f if pop_m == .

drop pop_f_p prop_f_age f_p  pop10 pop_10 _merge


preserve
		// Clear the current dataset
		keep locality age_at_death
		duplicates drop
		local year_range = (2011 - 2000 +1)

		expand `year_range'
		// Define the dimensions
		bys locality age_at_death: g yod = _n + 2000 - 1
		compress
		tempfile empty_age_yod
		save `empty_age_yod', replace
	restore
	
	merge 1:1 locality yod age_at_death using `empty_age_yod', keep(2 3) nogen

	sort locality age_at_death yod
	
	ipolate pop yod, gen(pop_ipo) by(age_at_death locality) epolate
	ipolate pop_f yod, gen(pop_ipo_f) by(age_at_death locality) epolate
	ipolate pop_m yod, gen(pop_ipo_m) by(age_at_death locality) epolate
	
	*rounding and consistency between pop_f and pop_m with pop tot
	g pop_ipo_b = pop_ipo_f + pop_ipo_m
	g pop_ipo_r = round(pop_ipo)
	g pop_ipo_m_r = round(pop_ipo_m)
	g pop_ipo_f_r = round(pop_ipo_f)
	g pop_ipo_b_r = pop_ipo_m_r + pop_ipo_f_r
	replace pop_ipo_r = pop_ipo_m_r + pop_ipo_f_r if pop_ipo_b_r!=pop_ipo_r
	
	g pop_ipo_miss = (pop_ipo_r == . | pop_ipo_f_r == . | pop_ipo_m_r == .)
	bys locality: egen pop_loc_miss = max(pop_ipo_miss)
	drop if pop_loc_miss == 1
	
	
	replace pop = pop_ipo_r 
	replace pop_m = pop_ipo_m_r
	replace pop_f = pop_ipo_f_r 
	
	drop pop_ipo*
	
	
	g pop_ipo_neg = (pop<0 | pop_f<0 | pop_m<0)
	bys locality: egen pop_loc_neg = max(pop_ipo_neg)
	drop if pop_loc_neg == 1
	
	g pop_zero = (pop_f==0 | pop_m==0)
	bys locality: egen pop_zero_loc = max(pop_zero)
    drop if pop_zero_loc == 1
	drop pop_zero_loc
	
	/* check it out what to do with potential inconsistency to recover 1k localities
	replace pop_f = 0 if pop_f <=0 & pop_m<=0
	replace pop_m = 0 if pop_f <=0 & pop_m<=0
	replace pop = 0 if pop_f <=0 & pop_m<=0
	
	
	replace pop_f = pop_f - pop_m if pop_m <0
	replace pop_m = pop_m - pop_f if pop_f <0
	g pop_b = pop_f + pop_m
	*/	
    drop pop_ipo*
		
	tempfile pop_2000_2011
	save `pop_2000_2011', replace

	use "$data/population/pop_locality_60_89_`age_g'_2000", clear
	keep locality
	duplicates drop
	merge 1:m locality using "$data/population/pop_locality_60_89_`age_g'_2005", keep(3) nogen keepus(locality)
	duplicates drop
	merge 1:m locality using "$data/population/pop_locality_60_89_`age_g'_2010", keep(3) nogen keepus(locality)
	duplicates drop
	count
	merge 1:m locality using `pop_2000_2011'


	*table yod _merge if inlist(yod, 2000, 2005, 2010), stat(sum pop)
	*in 2010 we are capturing 96% (6,460,594/6689782) of the total population, but 88% of elegible in 2007. 
	*keep in mind that localitiets won't match across all censuse, but we are dropping
	*those deaths from our analysis, so should not be a problem. (2%)
	*70k localitites in 2000 are dropped, but represents 2% of the pop
	/*
	----------------------------------------------------
			|          Matching result from merge       
			|  Using only (2)   Matched (3)        Total
	--------+-------------------------------------------
	yod     |                                           
	  2000  |          78,002     4,467,654    4,545,656
	  2005  |          96,049     5,409,191    5,505,240
	  2010  |          82,905     6,377,689    6,460,594
	  Total |         256,956    16,254,534   16,511,490
	----------------------------------------------------
	*/
	*distinct locality if yod == 2000 & _merge==3
	*distinct locality if yod == 2000 & _merge==2

	keep if _==3
	drop _merge
 

bys locality yod: egen tot_pop60 = total(pop)
g aux = tot_pop if yod == 2005
bys locality: egen pop65_05 = min(aux)
keep locality age_at_death yod pop pop_f pop_m pop65_05

save "$data/population/population_locality_interpolated_`age_g'_2000_2011_65_74.dta", replace
}






*******************************
*10 Year Age group Interpolation
*POPULATION CELLS OF 3 OR MORE in 2010
*AGES 60 to 79
*******************************
global age_group = "10yr"

foreach age_g in $age_group {

local age_g = "10yr"
	use "$data/population/pop_locality_60_89_`age_g'_2000", clear
	append using  "$data/population/pop_locality_60_89_`age_g'_2005"
	append using "$data/population/pop_locality_60_89_`age_g'_2010"

preserve
use "$data/deaths_02_15_did_panel", clear
keep if inrange(age_at_death, 60, 79)
drop if cve_loc == 7777 

keep if inlist(covered, 0, 2007)

keep locality 
duplicates drop
tempfile loc_deaths
save `loc_deaths', replace
restore
merge m:1 locality using `loc_deaths'
keep if _==3
*we restrict the age range before dropping the confidential cells
keep if inrange(age_at_death, 60, 79)

g pop10 = (pop == .  & yod == 2010)
bys locality: egen pop_10 = max(pop10)
drop if pop_10 == 1



*where there are one gender pop, i assign the difference with respect total
replace pop_f = pop - pop_m if pop_f == .
replace pop_m = pop - pop_f if pop_m == .
*assign the average proportion of female in 2000 and 2005 to the 2010
g f_p = pop_f/pop
bys locality age_at_death: egen prop_f_age = mean(f_p)
g pop_f_p = pop * prop_f_age
replace pop_f = round(pop_f_p) if pop_f==.
replace pop_m = pop - pop_f if pop_m == .
*assume that there are more women than men just 108 cells
replace pop_f = pop - 1 if pop_f == . 
replace pop_m = pop - pop_f if pop_m == .

drop pop_f_p prop_f_age f_p  pop10 pop_10 _merge

g age = 60 * (inrange(age_at_death, 60, 69)) + ///
		70 * (inrange(age_at_death, 70, 79))

collapse (sum) pop pop_f pop_m, by(locality age yod)
ren age age_at_death 


preserve
		// Clear the current dataset
		keep locality age_at_death
		duplicates drop
		local year_range = (2011 - 2000 +1)

		expand `year_range'
		// Define the dimensions
		bys locality age_at_death: g yod = _n + 2000 - 1
		compress
		tempfile empty_age_yod
		save `empty_age_yod', replace
	restore
	
	merge 1:1 locality yod age_at_death using `empty_age_yod', keep(2 3) nogen

	sort locality age_at_death yod
	
	ipolate pop yod, gen(pop_ipo) by(age_at_death locality) epolate
	ipolate pop_f yod, gen(pop_ipo_f) by(age_at_death locality) epolate
	ipolate pop_m yod, gen(pop_ipo_m) by(age_at_death locality) epolate
	
	*rounding and consistency between pop_f and pop_m with pop tot
	g pop_ipo_b = pop_ipo_f + pop_ipo_m
	g pop_ipo_r = round(pop_ipo)
	g pop_ipo_m_r = round(pop_ipo_m)
	g pop_ipo_f_r = round(pop_ipo_f)
	g pop_ipo_b_r = pop_ipo_m_r + pop_ipo_f_r
	replace pop_ipo_r = pop_ipo_m_r + pop_ipo_f_r if pop_ipo_b_r!=pop_ipo_r
	
	g pop_ipo_miss = (pop_ipo_r == . | pop_ipo_f_r == . | pop_ipo_m_r == .)
	bys locality: egen pop_loc_miss = max(pop_ipo_miss)
	drop if pop_loc_miss == 1
	
	
	replace pop = pop_ipo_r 
	replace pop_m = pop_ipo_m_r
	replace pop_f = pop_ipo_f_r 
	
	drop pop_ipo*
	
	
	g pop_ipo_neg = (pop<0 | pop_f<0 | pop_m<0)
	bys locality: egen pop_loc_neg = max(pop_ipo_neg)
	drop if pop_loc_neg == 1
	
	g pop_zero = (pop_f==0 | pop_m==0)
	bys locality: egen pop_zero_loc = max(pop_zero)
    drop if pop_zero_loc == 1
	drop pop_zero_loc
	
	/* check it out what to do with potential inconsistency to recover 1k localities
	replace pop_f = 0 if pop_f <=0 & pop_m<=0
	replace pop_m = 0 if pop_f <=0 & pop_m<=0
	replace pop = 0 if pop_f <=0 & pop_m<=0
	
	
	replace pop_f = pop_f - pop_m if pop_m <0
	replace pop_m = pop_m - pop_f if pop_f <0
	g pop_b = pop_f + pop_m
	*/	
    drop pop_ipo*
		
	tempfile pop_2000_2011
	save `pop_2000_2011', replace

	use "$data/population/pop_locality_60_89_`age_g'_2000", clear
	keep locality
	duplicates drop
	merge 1:m locality using "$data/population/pop_locality_60_89_`age_g'_2005", keep(3) nogen keepus(locality)
	duplicates drop
	merge 1:m locality using "$data/population/pop_locality_60_89_`age_g'_2010", keep(3) nogen keepus(locality)
	duplicates drop
	count
	merge 1:m locality using `pop_2000_2011'


	*table yod _merge if inlist(yod, 2000, 2005, 2010), stat(sum pop)
	*in 2010 we are capturing 96% (6,460,594/6689782) of the total population, but 88% of elegible in 2007. 
	*keep in mind that localitiets won't match across all censuse, but we are dropping
	*those deaths from our analysis, so should not be a problem. (2%)
	*70k localitites in 2000 are dropped, but represents 2% of the pop
	/*
	----------------------------------------------------
			|          Matching result from merge       
			|  Using only (2)   Matched (3)        Total
	--------+-------------------------------------------
	yod     |                                           
	  2000  |          78,002     4,467,654    4,545,656
	  2005  |          96,049     5,409,191    5,505,240
	  2010  |          82,905     6,377,689    6,460,594
	  Total |         256,956    16,254,534   16,511,490
	----------------------------------------------------
	*/
	*distinct locality if yod == 2000 & _merge==3
	*distinct locality if yod == 2000 & _merge==2

	keep if _==3
	drop _merge
 

bys locality yod: egen tot_pop60 = total(pop)
g aux = tot_pop if yod == 2005
bys locality: egen pop60_05 = min(aux)
keep locality age_at_death yod pop pop_f pop_m pop60_05

save "$data/population/population_locality_interpolated_`age_g'_2000_2011_60_79.dta", replace
}

*ALL 2 age groups
global age_group = "10yr"

foreach age_g in $age_group {

	use "$data/population/pop_locality_60_89_`age_g'_2000", clear
	append using  "$data/population/pop_locality_60_89_`age_g'_2005"
	append using "$data/population/pop_locality_60_89_`age_g'_2010"
*we restrict the age range before dropping the confidential cells
keep if inrange(age_at_death, 60, 79)
g pop10 = (pop == .  & yod == 2010)
bys locality: egen pop_10 = max(pop10)
drop if pop_10 == 1


*where there are one gender pop, i assign the difference with respect total
replace pop_f = pop - pop_m if pop_f == .
replace pop_m = pop - pop_f if pop_m == .
*assign the average proportion of female in 2000 and 2005 to the 2010
g f_p = pop_f/pop
bys locality age_at_death: egen prop_f_age = mean(f_p)
g pop_f_p = pop * prop_f_age
replace pop_f = round(pop_f_p) if pop_f==.
replace pop_m = pop - pop_f if pop_m == .
*assume that there are more women than men just 108 cells
replace pop_f = pop - 1 if pop_f == . 
replace pop_m = pop - pop_f if pop_m == .

drop pop_f_p prop_f_age f_p pop10 pop_10

preserve
		// Clear the current dataset
		keep locality age_at_death
		duplicates drop
		local year_range = (2011 - 2000 +1)

		expand `year_range'
		// Define the dimensions
		bys locality age_at_death: g yod = _n + 2000 - 1
		compress
		tempfile empty_age_yod
		save `empty_age_yod', replace
	restore
	
	merge 1:1 locality yod age_at_death using `empty_age_yod', keep(2 3) nogen

	sort locality age_at_death yod
	
	ipolate pop yod, gen(pop_ipo) by(age_at_death locality) epolate
	ipolate pop_f yod, gen(pop_ipo_f) by(age_at_death locality) epolate
	ipolate pop_m yod, gen(pop_ipo_m) by(age_at_death locality) epolate
	
	*rounding and consistency between pop_f and pop_m with pop tot
	g pop_ipo_b = pop_ipo_f + pop_ipo_m
	g pop_ipo_r = round(pop_ipo)
	g pop_ipo_m_r = round(pop_ipo_m)
	g pop_ipo_f_r = round(pop_ipo_f)
	g pop_ipo_b_r = pop_ipo_m_r + pop_ipo_f_r
	replace pop_ipo_r = pop_ipo_m_r + pop_ipo_f_r if pop_ipo_b_r!=pop_ipo_r
	
	g pop_ipo_miss = (pop_ipo_r == . | pop_ipo_f_r == . | pop_ipo_m_r == .)
	bys locality: egen pop_loc_miss = max(pop_ipo_miss)
	drop if pop_loc_miss == 1
	
	
	replace pop = pop_ipo_r 
	replace pop_m = pop_ipo_m_r
	replace pop_f = pop_ipo_f_r 
	
	drop pop_ipo*
	
	
	g pop_ipo_neg = (pop<0 | pop_f<0 | pop_m<0)
	bys locality: egen pop_loc_neg = max(pop_ipo_neg)
	drop if pop_loc_neg == 1
	
	g pop_zero = (pop_f==0 | pop_m==0)
	bys locality: egen pop_zero_loc = max(pop_zero)
    drop if pop_zero_loc == 1
	drop pop_zero_loc
	/* check it out what to do with potential inconsistency to recover 1k localities
	replace pop_f = 0 if pop_f <=0 & pop_m<=0
	replace pop_m = 0 if pop_f <=0 & pop_m<=0
	replace pop = 0 if pop_f <=0 & pop_m<=0
	
	
	replace pop_f = pop_f - pop_m if pop_m <0
	replace pop_m = pop_m - pop_f if pop_f <0
	g pop_b = pop_f + pop_m
	*/	
    drop pop_ipo*
		
	tempfile pop_2000_2011
	save `pop_2000_2011', replace

	use "$data/population/pop_locality_60_89_`age_g'_2000", clear
	keep locality
	duplicates drop
	merge 1:m locality using "$data/population/pop_locality_60_89_`age_g'_2005", keep(3) nogen keepus(locality)
	duplicates drop
	merge 1:m locality using "$data/population/pop_locality_60_89_`age_g'_2010", keep(3) nogen keepus(locality)
	duplicates drop
	count
	merge 1:m locality using `pop_2000_2011'


	*table yod _merge if inlist(yod, 2000, 2005, 2010), stat(sum pop)
	*in 2010 we are capturing 96% (6,460,594/6689782) of the total population, but 88% of elegible in 2007. 
	*keep in mind that localitiets won't match across all censuse, but we are dropping
	*those deaths from our analysis, so should not be a problem. (2%)
	*70k localitites in 2000 are dropped, but represents 2% of the pop
	/*
	----------------------------------------------------
			|          Matching result from merge       
			|  Using only (2)   Matched (3)        Total
	--------+-------------------------------------------
	yod     |                                           
	  2000  |          78,002     4,467,654    4,545,656
	  2005  |          96,049     5,409,191    5,505,240
	  2010  |          82,905     6,377,689    6,460,594
	  Total |         256,956    16,254,534   16,511,490
	----------------------------------------------------
	*/
	*distinct locality if yod == 2000 & _merge==3
	*distinct locality if yod == 2000 & _merge==2

	keep if _==3
	drop _merge
 

bys locality yod: egen tot_pop60 = total(pop)
g aux = tot_pop if yod == 2005
bys locality: egen pop60_05 = min(aux)
keep locality age_at_death yod pop pop_f pop_m pop60_05

save "$data/population/population_locality_interpolated_`age_g'_2000_2011_60_79_all.dta", replace
}



/************************
INEGI ITER DATA POBTOT
***********************/

*POB TOT FROM ITER
global years = "00 05 10"
foreach year in $years {
	local year = "05"
	use "$data/INEGI/population/ITER_NALDBF`year'", clear
	di `year'
	if (`year'== 05) {
	ren P_TOTAL POBTOT 
	ren (entidad mun loc) (ENTIDAD MUN LOC)
	destring(ENTIDAD), g(cve_ent)
	destring(MUN), g(cve_mun)
	destring(LOC), g(cve_loc)
	destring(POBTOT), g(totpop)
	destring(P_SINDER), g(pop_ui)
	destring(P_DERE), g(pop_i)
	destring(P_SEGPOP), g(pop_sp)
	}
	decode(ENTIDAD), g(cve_ent)
	decode(MUN), g(cve_mun)
	decode(LOC), g(cve_loc)
	decode(POBTOT), g(totpop)
	
	egen locality = concat(cve_ent cve_mun cve_loc)
	destring(locality totpop), replace
	count if cve_loc == "9999"
	*173056
	count if cve_loc == "9998"
	*260087
	drop if cve_ent == "00"
    keep locality cve_ent cve_mun cve_loc totpop
	save "$data/population/iter`year'", replace
}



foreach year in $years {
	local year = "05"
	use "$data/INEGI/population/ITER_NALDBF`year'", clear

	ren P_TOTAL POBTOT 
	ren (entidad mun loc) (cve_ent cve_mun cve_loc)
	
	destring(POBTOT), g(totpop)
	destring(P_SINDER), g(pop_ui) force
	destring(P_DERE), g(pop_i) force
	destring(P_SEGPOP), g(pop_sp) force
	
	egen locality = concat(cve_ent cve_mun cve_loc)
	destring(locality totpop), replace
	count if cve_loc == "9999"
	*173056
	count if cve_loc == "9998"
	*260087
	drop if cve_ent == "00"
    keep locality cve_ent cve_mun cve_loc totpop pop_ui pop_i pop_sp
	save "$data/population/iter`year'", replace
}



