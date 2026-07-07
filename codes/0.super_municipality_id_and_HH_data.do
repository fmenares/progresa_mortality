/*******************************
THIS DO-FILE creates input data for 01-04 do-files. It needs to be run only once.
TOPIC:  THIS DO-FILE CREATES A CROSSWALK AT THE MUNICIPALITY LEVEL. 
1. CROSSWALK NEW MUNICIPALITIES THAT COMES FROM 1 MUNICIPALITY OF ORIGIN: 1995-2020
2. Super Municipality ID CROSSWALK FOR NEW MUNICIPALITIES THAT COMES FROM 2+ MUNICIPALITY OF ORIGIN 1995-2020
******************************
INPUT DATA: 
1. EQUIVALENCIAS INEGI 
1.1.1 MUNICIPALITY LEVEL: 2000-2020
1.2. CATALOGO HISTORICO 1995-2000 
2 ITER Data 1995-2020 (Municipality Level)
OUTPUT DATA: 
1. CROSSWALK MUNCIPALITY LEVEL 
2. ITER DATA
Based on the following do-files
*Social Programs at the Municipality level
*create_municipal_level_indicators_MHAS.do (Susan and Tom)
*Assigning beneficiaries at the municipality level.
*all_municipal_data_allprog_v3_upd_benef
CODE: Felipe Menares
DATE: 9/14/2021
********************************/
if c(username)=="fmenares" global ensanut "/hdir/0/fmenares/Dropbox/R01_MHAS\ENSANUT"
if c(username)=="felipe" global ensanut "C:\Users\felip\Dropbox\R01_MHAS\ENSANUT"

if c(username)=="fmenares" global r01 "/hdir/0/fmenares/Dropbox/R01_MHAS"
if c(username)=="felipe" global r01 "C:\Users\felip\Dropbox\R01_MHAS"

if c(username)=="fmenares" global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
if c(username)=="felipe" global iter "C:\Users\felip\Dropbox\R01_MHAS\Progresa_Locality_Mortality_Project\CensusData_ITER\" 
*Switch to 1 to create the CROSSWALK dataset
local crosswalk = 0

*Switch to 1 to create the recoded datasets
local recoding = 1
capture log close
*log using "$ensanut/programs/fmenares/datasets/logs/0_crosswalk_mun_and_iter_data", replace text
/************************************************************************
1. CROSS-WALK SUPER MUNICIPALITY ID FOR RECODING 
************************************************************************/
/************************************************************************
1.1 IDENTIFYING NEW MUNICIPALITIES BASED ON THE NUMBER OF MUNICIPALITIES
OF ORIGIN THEY CAME 2000-2020
************************************************************************/
if `crosswalk' == 1 {
foreach year in 1995 1990 {
*changes that ocurred in 1995 are part of the changes between 1990-1995.
	if `year' == 1995{
		local year = 1996
	}
*EQUIVALENCIAS INEGI 2000-2020 MUNICIPALITY LEVEL
	import delimited "$ensanut\datasets/crosswalk_mun\AGEEML_20216141847596.csv", clear
	ta descrip

	keep if descrip =="Nuevo Municipio"
	g year_mun = substr(fecha_act,1,4)
	destring(year), replace

	ta cve_ent_act year
*According to the documentation from the webpage (PDF). There are some changes 
*that might be territorial borders rather than creation of new municipalities. 
*That's why there is no new code for them.
	destring(cve_ent_act), g(cve_ent_act_int) force
	drop if cve_ent_act_int == .
	count if cve_ent_ori!=cve_ent_act
*There are not municipaltes created from one state into another.
	drop nom_ent_ori nom_ent_act nom_mun_ori nom_mun_act fecha_act cgo_act ///
	descrip cve_ent_ori cve_ent_act_int
	tostring(cve_mun_ori cve_mun_act), replace
	replace cve_mun_act = "00"+cve_mun_act if length(cve_mun_act) == 1
	replace cve_mun_act = "0"+cve_mun_act if length(cve_mun_act) == 2
	replace cve_mun_ori = "00"+cve_mun_ori if length(cve_mun_ori) == 1
	replace cve_mun_ori = "0"+cve_mun_ori if length(cve_mun_ori) == 2
/******************************************************************************
1.2 EQUIVALENCIAS AD-HOC 1990-2000 MUNICIPALITY LEVEL
***************************************************************************/
		preserve 
			import delimited "$ensanut\datasets/crosswalk_mun/mun_1990_2000.csv", clear
			ren  ïcve_ent_act cve_ent_act
			tostring(cve_ent_act cve_mun_act cve_mun_ori), replace
			replace cve_ent = "0"+cve_ent if length(cve_ent) == 1
			replace cve_mun_act = "00"+cve_mun_act if length(cve_mun_act) == 1
			replace cve_mun_act = "0"+cve_mun_act if length(cve_mun_act) == 2
			replace cve_mun_ori = "00"+cve_mun_ori if length(cve_mun_ori) == 1
			replace cve_mun_ori = "0"+cve_mun_ori if length(cve_mun_ori) == 2
			drop v*
			sort cve_ent_act cve_mun_act cve_mun_ori
			tempfile mun_equivalences_1990_2000
			save `mun_equivalences_1990_2000', replace
		restore
	append using `mun_equivalences_1990_2000'
*There are 42 new municipalties, and this are created from one or more old 
*municipalities.
	bys cve_ent_act cve_mun_act : g aux=_n
	bys cve_ent_act cve_mun_act : egen n_mun_ori=max(aux)
	ta n_mun_ori if aux == n_mun_ori
	order cve_ent_act cve_mun_act

		preserve
			keep if n_mun_ori ==1
			keep cve_ent_act cve_mun_act cve_mun_ori year_mun
			duplicates drop 
			ren (cve_ent_act cve_mun_act) (cve_ent cve_mun)
			*NEW MUNICIPALITIES THAT COMES FROM 1 MUNICIPALITY OF ORIGIN
			keep if inrange(year_mun,`year', 2020)
			drop year_mun
			g cve_ent_mun_super = cve_ent + cve_mun_ori
			sort cve_ent_mun_super
			drop cve_mun_ori
			tempfile cve_mun_1m
			save `cve_mun_1m' 
		restore
/************************************
1.3 CREATING THE SUPER MUNICIPALITY ID
*************************************/
*We now work only with new municipalities that comes from 2+ Muni of origin.
	drop if n_mun_ori==1 
	*We check if there are new municipalities that creates municipalities later in time.
		preserve
			keep cve_ent_act cve_mun_ori
			sort cve_ent_act cve_mun_ori
			duplicates drop 
			ren cve_mun_ori cve_mun_act
			tempfile cve_mun_ori
			save `cve_mun_ori'
		restore

	drop aux n_mun_ori 
		preserve
			drop cve_mun_ori
			duplicates drop
			merge 1:1 cve_ent_act cve_mun_act using `cve_mun_ori'
			list if _==3
		/*Only 1 case were a new municipality creates another new muni later in time. 
		This case will be included in the super municipality ID.
			 +----------------------------------------------+
			 | cve_en~t   cve_mu~t   year_mun        _merge |
			 |----------------------------------------------|
		  6. |       12         77       2001   matched (3) |
			 +----------------------------------------------+
		*/
		restore
*There are 47 different original municipalities that creates 17. 
*There are 2 new municipalities created from the same municipality of origin, 
*but in different years
	sort cve_ent_act cve_mun_act cve_mun_ori
	ren (cve_ent_act cve_mun_act cve_mun_ori) (ent_act mun_act mun_ori)
	*list
		preserve
			drop mun_ori
			duplicates drop
			list
		restore
	ren (ent_act mun_act mun_ori) (cve_ent_act cve_mun_act cve_mun_ori)
	*NEW MUNICIPALITIES THAT COMES FROM 2+ MUNICIPALITY OF ORIGIN
	keep if inrange(year_mun,`year', 2020)
	*super municipality code id
	*to identify the current muni and the muni of origin with the same code.
	bys cve_ent_act cve_mun_act: g cve_ent_mun_super = cve_ent + cve_mun_act + strofreal(_N)
	sort cve_ent_act cve_mun_act cve_mun_ori

	drop year_mun
	order cve_ent_act cve_mun_act cve_mun_ori
	duplicates tag cve_ent_act cve_mun_ori, g(d_ori)
	*There are duplicates municipalities of origin that are part of more than 1 
	*super_mun_id. I decide to combine all of the mun of both super_mun_id codes,
	*creating an upper level code for those cases (I actually replaced one of 
	*the codes and drop the other).
		preserve
			keep if d!=0
			keep cve_ent_act cve_mun_ori cve_ent_mun_super
			ren cve_ent_mun_super cve_ent_mun_super2 
			duplicates drop
			bys cve_ent_act cve_mun_ori (cve_ent_mun_super2): keep if _n==1
			tempfile aux
			save `aux'
		restore
	merge m:1 cve_ent_act cve_mun_ori using `aux'

*There is only 1 mun sharing the same super mun id
	drop if _==2
	sort cve_ent_mun_super

		preserve
		*I need to include the current municipality as a part of the dataset of the 
		*super_geo_id linked with the municipality of origin. So I need to append them
			keep cve_ent_act cve_mun_act cve_ent_mun_super
			ren cve_mun_act cve_mun_ori
			duplicates drop
			tempfile current_municipality
			save `current_municipality'
		restore
	append using `current_municipality'
*Now I replace the super_mun_id code to make them unique between muni of origin 
*and super_mun_id
	gsort cve_ent_mun_super -cve_ent_mun_super2
	by cve_ent_mun_super: replace cve_ent_mun_super2 = cve_ent_mun_super2[_n-1] if _n>1
	replace cve_ent_mun_super = cve_ent_mun_super2 if cve_ent_mun_super2!=""
	ren (cve_ent_act cve_mun_ori) (cve_ent cve_mun)
	keep cve_ent_mun_super cve_ent cve_mun
	duplicates drop
	sort cve_ent cve_mun cve_ent_mun_super

*I will now include those municipalities that came only from 1 muni of origin 
*in the crosswalk
	append using `cve_mun_1m' 
	sort cve_ent cve_mun cve_ent_mun_super
	label var cve_ent "geographic original unique id for entity"
	label var cve_mun "geographic original unique id for municipality"
	label var cve_ent_mun_super "Super unique id between entity and municipality"
	if `year' == 1996 {
		local year = 1995
	}
	save $r01/FinalData/crosswalks/municipality_level/crosswalk_super_mun_id_`year'.dta, replace
}
}

/***********************************
2. INEGI HOUSEHOLDS (HH)
************************************/
*Households are not available for all the localities because of confidentiality
*(localities with less than 3 HH)
*Population counts are not available in 2015 (I use this from CONAPO)

*Adding HH counts from INEGI census data at the Municipality level
*https://en.www.inegi.org.mx/programas/ccpv/1995/#Tabular_data

foreach year in 1990 2000 2005 2010 2020 {
	import delimited "$ensanut\datasets/other data\HH_`year'", ///
	 clear rowrange(12:) delimiter(",") colrange(1:3)
	g cve_ent = substr(v1, 2, 2)
	g cve_mun = substr(v1, 5, 4)
	g year = `year'
	drop if cve_mun == ""
	g HH = subinstr(v3, ",", "",.)
	drop v*
	destring(HH), replace
	drop if _n==_N
	sort cve_ent cve_mun
	tempfile HH_`year'
	save `HH_`year''
}

append using `HH_2010'
append using `HH_2005' 
append using `HH_2000'
append using `HH_1990'
sort cve_ent cve_mun year

g cve_ent_mun = cve_ent+cve_mun
save $ensanut/datasets/INEGI_HH_1990_2020_municipality, replace

/*******************************************
2.1 RECODING at Municipality Level
******************************************/
*I did this recoding until 2020. This because I needed to recode until the 
*last datapoint I will use to interpolate the denominators, that is 2020. Therefore
*for consistency, I recode municipalities until that year, using a crosswalk 
if `recoding' == 1 {
foreach year in 1990 1995 {
*local year = 1990
	use $ensanut/datasets/INEGI_HH_1990_2020_municipality, clear
	merge m:1 cve_ent cve_mun using ///
	 $r01/FinalData/crosswalks/municipality_level/crosswalk_super_mun_id_`year'.dta
	drop if _==2 

*There are 13 municipalities in the crosswalk not reported in the ITER data
	replace cve_ent_mun_super = cve_ent_mun if _!=3
*combining the recoded municipality (old and new one recoded)
	collapse (sum) HH, by(cve_ent_mun_super year)
/****************************************************************
2.1.1 INTERPOLATION (HOUSEHOLD COUNT) 1995-2020
*****************************************************************/
*There is HH counts for 1990. So I can interpolate the 1995 value using 1990 and 2000. 
replace HH = . if HH == 0

expand 2 if year == 2020, g(year_1995)
replace year = 1995 if year_1995 == 1
drop year_1995
sort cve_ent_mun_super year
replace HH = . if year == 1995

bys cve_ent_mun_super: ipolate HH year if year <=2000, g(HH_1995)
replace HH = HH_1995 if year == 1995
drop HH_1995

expand 2 if year == 2020, g(year_2015)
replace year = 2015 if year_2015 == 1
drop year_2015
sort cve_ent_mun_super year

foreach var in HH {
replace `var' = . if year == 2015

bys cve_ent_mun_super: ipolate `var' year if ///
inrange(year,2010,2020), g(`var'2015)
replace `var' = `var'2015 if year == 2015
drop `var'20*
}

keep if year >= `year'
*Now I can interpolate all of the in-between years.
	preserve
		reshape wide HH, i(cve_ent_mun_super) j(year)
		sort cve_ent_mun_super
		tempfile wide
		save `wide'
	restore

	destring(cve_ent_mun_super), g(cve_ent_mun_super2)
	tsset cve_ent_mun_super2 year
	tsfill

	sort cve_ent_mun_super2 year
	bys cve_ent_mun_super2: replace cve_ent_mun_super = cve_ent_mun_super[_n-1] ///
	if cve_ent_mun_super == ""
	sort cve_ent_mun_super
	merge m:1 cve_ent_mun_super using `wide'
	drop _
	sort cve_ent_mun_super year
	order cve_ent_mun_super year


*Interpolation 

foreach var2 in HH {
	by cve_ent_mun_super: ipolate `var2' year, g(`var2'_ip)
	replace `var2' = `var2'_ip if `var2' ==.
	}

ta year

keep cve_ent_mun_super year HH

sort cve_ent_mun_super year

*** Labeling
label var HH "HH count (Interpolated)"
	
sort cve_ent_mun_super year
save "$r01/FinalData/HH_Pop/municipality_level/households_mun_ipolate_recoded_`year'.dta", replace
}
}

log close
