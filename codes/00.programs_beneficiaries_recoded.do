/*******************************
PREVIOUS DO FILES: 
1. super_municipality_id_and_ITER_data.do
TOPIC: BENEFICIARIES AND PENETRATION VARIABLES RECODED BACK TO 1995
CODE: Felipe Menares
DATE: 7/5/2021
INPUT DATA: 
1. Program Beneficiaries from:
	1.1 Progresa (CCT)
		1.1.1 Recoding beneficiaries
	1.2 Seguro Popular (PHI)
		1.2.1 Recoding beneficiaries
	1.3 70 y Mas (UCT)
		1.3.1 Recoding beneficiaries
2. Denominators for program penetration
	2.1 RECODING ITER DATA 1995-2020
	2.2 INTERPOLATION OF ITER DATA
3. PENETRATION VARIABLES
OUTPUT DATA:
1. BENEFICIARIES AND PENETRATION VARIABLES DATASET RECODED BACK TO 1995
	1.1 beneficiaries_mun_recoded_1995_2018.dta
************************************************************************
*This codes is based on:
/**Social Programs at the Municipality level*/
*create_municipal_level_indicators_MHAS.do (Susan and Tom)
/**Assigning beneficiaries at the municipality level.*/
*all_municipal_data_allprog_v3_upd_benef
******************************************************************************/
if c(username)=="fmenares" global ensanut "/hdir/0/fmenares/Dropbox/R01_MHAS\ENSANUT"
if c(username)=="felipe" global ensanut "C:\Users\felip\Dropbox\R01_MHAS\ENSANUT"

if c(username)=="fmenares" global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"
if c(username)=="felipe" global SP "C:\Users\felip\Dropbox\R01_MHAS\SocialProgramBeneficiaries"


capture log close
*log using "$ensanut/programs/fmenares/datasets/logs/03_programs_benef_recoded", replace text
/*******************
1. MUNICIPALITY LEVEL
*******************/
/************************************************************
***1.1 PROGRESA (CCT)**
*************************************************************/
foreach year in 1995 1990 {
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
g cve_ent_mun = cve_ent+cve_mun 
*Recoding new municipalities 
merge m:1 cve_ent cve_mun using ///
$r01/FinalData/crosswalks/municipality_level/crosswalk_super_mun_id_`year'.dta
drop if _==2
*6 municipality changes occurred after 2018
replace cve_ent_mun_super = cve_ent_mun if _!=3
drop  _
collapse (sum) pgbenef*, by(cve_ent_mun_super)

misstable sum pg*
*NO MISSINGS

tempfile benef_pg_mun_recoded 
save `benef_pg_mun_recoded', replace

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
*Recoding new municipalities 

merge m:1 cve_ent cve_mun using ///
$r01/FinalData/crosswalks/municipality_level/crosswalk_super_mun_id_`year'.dta
drop if _==2
*11 changes in municipalities occured after 2017
replace cve_ent_mun_super = cve_ent_mun if _!=3
drop  _
collapse (sum) spbene* , by(cve_ent_mun_super)


sort cve_ent_mun_super

misstable sum sp*
*NO MISSINGS

tempfile benef_sp_mun_recoded
save `benef_sp_mun_recoded' , replace

/*********************************
1.3 ***70YMAS DATA FILE (UCT)*** 2007-2018 
SOURCE: SEDESOL
provided by Jorge Peniche
*********************************/
use $SP\Linked_admin_records\70ymas\70yMas_benef_2007_2018_loc.dta, clear
collapse (sum) benef70ym, by(year sta_code mun_code)
ren (sta_code mun_code benef70ym) (cve_ent cve_mun pensbenef) 
drop if cve_ent=="" | cve_mun==""
sort cve_ent cve_mun year
reshape wide pensbenef, i(cve_ent cve_mun) j(year)
g cve_ent_mun = cve_ent + cve_mun
*Recoding new municipalities 
merge m:1 cve_ent cve_mun using ///
$r01/FinalData/crosswalks/municipality_level/crosswalk_super_mun_id_`year'.dta
*drop  if _==2
replace cve_ent_mun_super = cve_ent_mun if _!=3
drop _
collapse (sum) pens* , by(cve_ent_mun_super)
sort cve_ent_mun_super

misstable sum pens*
*NO MISSINGS

merge 1:1 cve_ent_mun_super using `benef_pg_mun_recoded' 
drop _
merge 1:1 cve_ent_mun_super using `benef_sp_mun_recoded' 
drop _
order cve_ent_mun_super
forv i = 1997/2013{
ren pgbenef`i'_old pgbenef_old`i'
}
forv i = 1998/2018{
ren pgbenef`i'_new pgbenef_new`i'
}
reshape long pensbenef pgbenef_old pgbenef_new spbenef, i(cve_ent_mun_super) j(year) 
drop if pensbenef ==. & pgbenef_old==. & pgbenef_new==. & spbenef == .
*24

tempfile benef_mun_recoded
save `benef_mun_recoded'

/***************************************************************
1.4 PROGRAM PENETRATION/INTENSITY VARIABLES 1995-2020
*****************************************************************/
*merge interpolated denominators with the program beneficiaries
merge 1:1 cve_ent_mun_super year using /// 
"$r01/FinalData/HH/municipality_level/households_mun_ipolate_recoded_`year'.dta"
drop if _==2
*==2 These are all municipalities without beneficiares. 
*==1 78 municipalities doesn't have denominators. I won't be able compute intensity
*for them
drop _
sort cve_ent_mun_super year
*merge with the margination index
merge 1:1 cve_ent_mun_super year using ///
$r01/FinalData/Margination_Index/municipality_level/MI_mun_ipolate_recoded_`year'.dta, keepus(pob_tot)
drop if _==2
drop if _==1
*These are all beneficiaries from municipalities that I won't be able
*to identify, and for the rest are municipalities with 0 beneficiares. So I drop
*Them
drop _ 

*Looks like with the new data for progresa beneficiares ac = cc
g ac_pg_mun_old = pgbenef_old / HH
g cc_pg_mun_new = pgbenef_new / HH
*Seguro Popular and 70 y mas already considered cumulative beneficiaries each year
g cc_70_mun = pensbenef / pob_tot
g cc_sp_mun = spbenef/ pob_tot

bys cve_ent_mun_super: g cc_pg_mun_old = sum(pgbenef_old)/HH
replace cc_pg_mun_old = . if year > 2013
*bys cve_ent cve_mun: g cc_70_mun = sum(pensbenef)/pob_tot
*bys cve_ent cve_mun: g cc_sp_mun = sum(spbenef)/pob_tot

/*Relevant descriptive stats for beneficiares*/

*Annual Coverage
sum ac_*, d
*Cummulative Coverage compared between old and new progresa data
sum cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014), d
bys cve_ent: sum cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014), d
corr cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014)
bys cve_ent: corr cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014)

sum cc_sp_mun cc_70_mun, d
/*
*Average yearly stats
table year, c(mean pob_tot mean HH) f(%7.0g) 
table year, c(mean cc_pg_mun_old mean cc_pg_mun_new)
table year, c(mean cc_pg_mun_new mean cc_70_mun mean cc_sp_mun)

*Average yearly stats
table cve_ent, c(mean pob_tot mean HH) f(%7.0g) 
table cve_ent, c(mean cc_pg_mun_old mean cc_pg_mun_new)
table cve_ent, c(mean cc_pg_mun_new mean cc_70_mun mean cc_sp_mun)

*Average yearly stats
table cve_ent year, c(mean pob_tot mean HH) f(%7.0g) 
table cve_ent year , c(mean cc_pg_mun_old mean cc_pg_mun_new)
table cve_ent year, c(mean cc_pg_mun_new mean cc_70_mun mean cc_sp_mun)
*/

misstable sum pg* pens sp* ac* cc* pob_tot HH

*POP_ITER DOESN'T HAVE INFO FOR 2015, SO I PREFER TO USE POP COUNTS FROM
*THE MARGINATION INDEX DATASET (CONAPO)
drop pob_tot 
reshape wide pgbenef_old pgbenef_new pensbenef spbenef  ac cc_* HH, i(cve_ent_mun_super) j(year)

*SEGURO POPULAR DATA FILE (PHI) - 2004-2017
***70YMAS DATA FILE (UCT)*** 2007-2018

drop spbenef199* spbenef2000 pensbenef199* pensbenef2000 pensbenef2001 ///
pensbenef2002 pensbenef2003 pensbenef2004 pensbenef2005 pensbenef2006 ///
cc_70_mun2006 cc_sp_mun199* cc_sp_mun2000 cc_70_mun199* cc_70_mun2000 ///
cc_70_mun2001 cc_70_mun2002 cc_70_mun2003 cc_70_mun2004 cc_70_mun2005 ///
cc_pg_mun_new1997 pgbenef_old2014 pgbenef_old2015 pgbenef_old2016 pgbenef_old2017 ///
pgbenef_old2018 ac_pg_mun_old2014 ac_pg_mun_old2015 ac_pg_mun_old2016 ///
ac_pg_mun_old2017 ac_pg_mun_old2018 cc_pg_mun_old2014 cc_pg_mun_old2015 ///
cc_pg_mun_old2016 cc_pg_mun_old2017 cc_pg_mun_old2018 pgbenef_new1997

forv i = 1997/2013 {
ren pgbenef_old`i' pg_mun`i'_old
ren ac_pg_mun_old`i' ac_pg_mun`i'_old
ren cc_pg_mun_old`i' cc_pg_mun`i'_old
}

forv i = 1998/2018 {
ren pgbenef_new`i' pg_mun`i'_new
ren cc_pg_mun_new`i' cc_pg_mun`i'_new
}
/*IMPORTANT
After the reshape wide, in 1 municipality, there are missing values for the number of 
beneficiares for some years. However, this must be 0 because there are not beneficiaries for the same municipalities in all of the years and all programs*/
misstable sum ac* pg* pens* sp* cc*
*30/209
quiet{
forv i=1998/2018 {
replace pg_mun`i'_new =0 if pg_mun`i'_new == .
replace cc_pg_mun`i'_new =0 if cc_pg_mun`i'_new == .

la var pg_mun`i'_new "Progresa (new) - mun - benef `i'"
la var cc_pg_mun`i'_new "Progresa (new) - mun - cumulative % covered `i'"
}

forv i=1997/2013 {

replace pg_mun`i'_old =0 if pg_mun`i'_old == .
replace ac_pg_mun`i'_old =0 if ac_pg_mun`i'_old == .
replace cc_pg_mun`i'_old =0 if cc_pg_mun`i'_old == .

la var pg_mun`i'_old "Progresa (old) - mun - benef `i'"
la var ac_pg_mun`i'_old "Progresa (old) - mun - annual % covered `i'"
la var cc_pg_mun`i'_old "Progresa (old) - mun - cumulative % covered `i'"
}


forv i=2007/2018 {
replace pensbenef`i'=0 if pensbenef`i'==.
replace cc_70_mun`i' =0 if cc_70_mun`i' == .
ren pensbenef`i' p70_mun`i'
la var p70_mun`i' "70+ - mun - benef `i'"
la var cc_70_mun`i' "70+ - mun - cumulative % covered `i'"
}

forv i=2001/2018 {
replace spbenef`i'=0 if spbenef`i' == .
replace cc_sp_mun`i' =0 if cc_sp_mun`i' == .
ren spbenef`i' sp_mun`i'
la var sp_mun`i' "SP - mun - benef `i'"
la var cc_sp_mun`i' "SP - mun - cumulative % covered `i'"
}
}
order cve_ent_mun_super pg* ac_pg*  cc_pg* sp* cc_sp* p70* cc_70*


*consolidating progresa beneficiaries: use ONLY FASE data (pgbenef_old) for 1997-2005
*to match Parker & Vogl (2023) exactly. Switch to newProg_98_16 data after 2005.
forv i=1997/2005 {
g cc_pg_mun`i' = cc_pg_mun`i'_old
g pg_mun`i' = pg_mun`i'_old
}
drop cc_pg_mun*_old pg_mun*_old ac_pg_mun*_old

forv i=2006/2018 {
g cc_pg_mun`i' = cc_pg_mun`i'_new
g pg_mun`i' = pg_mun`i'_new
drop cc_pg_mun`i'_new pg_mun`i'_new
}

forv i=1997/2018 {
la var pg_mun`i' "Progresa - mun - benef `i'"
la var cc_pg_mun`i' "Progresa - mun - cumulative % covered `i'"
}


misstable sum pg_* p70* sp* cc*

save $r01/FinalData/Program/municipality_level/beneficiaries_mun_recoded_`year'.dta, replace
}
log close