/*******************************
PREVIOUS DO FILES:
1. super_municipality_id_and_ITER_data.do
TOPIC: BENEFICIARIES AND PENETRATION VARIABLES RECODED BACK TO 1990
CODE: Felipe Menares
DATE: 7/5/2021
INPUT DATA:
1. Program Beneficiaries from:
	1.1 Progresa (CCT)
		1.1.1 Recoding beneficiaries
	1.2 Seguro Popular (PHI)
		1.2.1 Recoding beneficiaries
2. Denominators for program penetration
	2.1 RECODING ITER DATA 1995-2020
	2.2 INTERPOLATION OF ITER DATA
3. PENETRATION VARIABLES
OUTPUT DATA:
1. BENEFICIARIES AND PENETRATION VARIABLES DATASET RECODED BACK TO 1990
	1.1 beneficiaries_mun_recoded_1990.dta
************************************************************************
*This codes is based on:
/**Social Programs at the Municipality level*/
*create_municipal_level_indicators_MHAS.do (Susan and Tom)
/**Assigning beneficiaries at the municipality level.*/
*all_municipal_data_allprog_v3_upd_benef
******************************************************************************
NOTE (2026 cleanup): the 70 y Mas (UCT) block was removed -- p70_mun*/cc_70_mun*
were never referenced downstream in 01_mortality_data.do or 02_mortality.do, so
they were pure dead weight. Seguro Popular is KEPT (see section 1.2) and its
cumulative-coverage variable (cc_sp_mun*) is now carried through into
01_mortality_data.do as sp_new/c_sp_new/sp_intensity_00, so it survives past
the "keep pg_new* c_pg_new*" step that used to silently drop it. This gives an
embedded SP intensity measure built from the same crosswalk/HH pipeline as
Progresa, which 02_mortality.do compares against the standalone sp_intensity
merged in from $data/SP_2001_2018.dta (a file built outside this repo).
Also: this file used to loop over `foreach year in 1995 1990`, but only the
1990 output (beneficiaries_mun_recoded_1990.dta) is ever loaded downstream --
the 1995 vintage was built and never used. Simplified to a single pass.
******************************************************************************/
if c(username)=="fmenares" global ensanut "/hdir/0/fmenares/Dropbox/R01_MHAS\ENSANUT"
if c(username)=="felipe" global ensanut "C:\Users\felip\Dropbox\R01_MHAS\ENSANUT"

if c(username)=="fmenares" global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"
if c(username)=="felipe" global SP "C:\Users\felip\Dropbox\R01_MHAS\SocialProgramBeneficiaries"

*** Path globals matching the convention used in 01_mortality_data.do /
*** 02_mortality.do: $data is the flat processed-data folder these two
*** scripts read from directly (no $r01/FinalData/... subfolder scheme).
if c(username)=="root" {
	global data "/home/user/progresa_mortality/data/"
	global SP   "/home/user/progresa_mortality/data/"
}
if c(username)=="FELIPEME" {
	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global SP   "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"
}

local year 1990

capture log close
*log using "$ensanut/programs/fmenares/datasets/logs/03_programs_benef_recoded", replace text
/*******************
1. MUNICIPALITY LEVEL
*******************/
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
g cve_ent_mun = cve_ent+cve_mun
*Recoding new municipalities
merge m:1 cve_ent cve_mun using ///
"$data/crosswalk_super_mun_id_`year'.dta"
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
"$data/crosswalk_super_mun_id_`year'.dta"
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

*** 1.3 70 y Mas (UCT) block REMOVED (2026 cleanup): pensbenef/p70_mun*/
*** cc_70_mun* were never referenced in 01_mortality_data.do or
*** 02_mortality.do -- dead weight. Progresa is now the base frame that
*** Seguro Popular merges into (previously 70ymas was the base frame).

use `benef_pg_mun_recoded', clear
merge 1:1 cve_ent_mun_super using `benef_sp_mun_recoded'
drop _
order cve_ent_mun_super
forv i = 1997/2013{
ren pgbenef`i'_old pgbenef_old`i'
}
forv i = 1998/2018{
ren pgbenef`i'_new pgbenef_new`i'
}
reshape long pgbenef_old pgbenef_new spbenef, i(cve_ent_mun_super) j(year)
drop if pgbenef_old==. & pgbenef_new==. & spbenef == .

tempfile benef_mun_recoded
save `benef_mun_recoded'

/***************************************************************
1.4 PROGRAM PENETRATION/INTENSITY VARIABLES 1990-2020
*****************************************************************/
*merge interpolated denominators with the program beneficiaries
merge 1:1 cve_ent_mun_super year using ///
"$data/households_mun_ipolate_recoded_`year'.dta"
drop if _==2
*==2 These are all municipalities without beneficiares.
*==1 78 municipalities doesn't have denominators. I won't be able compute intensity
*for them
drop _
sort cve_ent_mun_super year
*merge with the margination index
merge 1:1 cve_ent_mun_super year using ///
"$data/MI_mun_ipolate_recoded_`year'.dta", keepus(pob_tot)
drop if _==2
drop if _==1
*These are all beneficiaries from municipalities that I won't be able
*to identify, and for the rest are municipalities with 0 beneficiares. So I drop
*Them
drop _

*Looks like with the new data for progresa beneficiares ac = cc
g ac_pg_mun_old = pgbenef_old / HH
g cc_pg_mun_new = pgbenef_new / HH
*Seguro Popular already considered cumulative beneficiaries each year
g cc_sp_mun = spbenef/ pob_tot

bys cve_ent_mun_super: g cc_pg_mun_old = sum(pgbenef_old)/HH
replace cc_pg_mun_old = . if year > 2013
*bys cve_ent cve_mun: g cc_sp_mun = sum(spbenef)/pob_tot

/*Relevant descriptive stats for beneficiares*/

*Annual Coverage
sum ac_*, d
*Cummulative Coverage compared between old and new progresa data
sum cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014), d
bys cve_ent: sum cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014), d
corr cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014)
bys cve_ent: corr cc_pg_mun_old cc_pg_mun_new if inrange(year,2008,2014)

sum cc_sp_mun, d
/*
*Average yearly stats
table year, c(mean pob_tot mean HH) f(%7.0g) 
table year, c(mean cc_pg_mun_old mean cc_pg_mun_new)
table year, c(mean cc_pg_mun_new mean cc_sp_mun)

*Average yearly stats
table cve_ent, c(mean pob_tot mean HH) f(%7.0g) 
table cve_ent, c(mean cc_pg_mun_old mean cc_pg_mun_new)
table cve_ent, c(mean cc_pg_mun_new mean cc_sp_mun)

*Average yearly stats
table cve_ent year, c(mean pob_tot mean HH) f(%7.0g)
table cve_ent year , c(mean cc_pg_mun_old mean cc_pg_mun_new)
table cve_ent year, c(mean cc_pg_mun_new mean cc_sp_mun)
*/

misstable sum pg* sp* ac* cc* pob_tot HH

*POP_ITER DOESN'T HAVE INFO FOR 2015, SO I PREFER TO USE POP COUNTS FROM
*THE MARGINATION INDEX DATASET (CONAPO)
drop pob_tot
reshape wide pgbenef_old pgbenef_new spbenef  ac cc_* HH, i(cve_ent_mun_super) j(year)

*SEGURO POPULAR DATA FILE (PHI) - 2004-2017

drop spbenef199* spbenef2000 ///
cc_sp_mun199* cc_sp_mun2000 ///
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
misstable sum ac* pg* sp* cc*
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


forv i=2001/2018 {
replace spbenef`i'=0 if spbenef`i' == .
replace cc_sp_mun`i' =0 if cc_sp_mun`i' == .
ren spbenef`i' sp_mun`i'
la var sp_mun`i' "SP - mun - benef `i'"
la var cc_sp_mun`i' "SP - mun - cumulative % covered `i'"
}
}
order cve_ent_mun_super pg* ac_pg*  cc_pg* sp* cc_sp*


*consolidating progresa beneficiaries: build BOTH variants side by side so
*01_mortality_data.do can switch between them without re-running this file.
*  _mixed : FASE for 1997, newProg_98_16 from 1998 onward (current default)
*  _fase  : FASE only through 2005, newProg_98_16 from 2006 onward
*           (matches Parker & Vogl 2023, which uses only the FASE file for
*           the entire 1997-2005 period)
g cc_pg_mun1997_mixed = cc_pg_mun1997_old
g pg_mun1997_mixed    = pg_mun1997_old
g cc_pg_mun1997_fase  = cc_pg_mun1997_old
g pg_mun1997_fase     = pg_mun1997_old

forv i=1998/2018 {
g cc_pg_mun`i'_mixed = cc_pg_mun`i'_new
g pg_mun`i'_mixed    = pg_mun`i'_new
}

*** IMPORTANT: pg_mun`i'_old (FASE source) is an ANNUAL flow, not a cumulative
*** count -- unlike pg_mun`i'_new (newProg admin source), which is already a
*** cumulative stock. For 1997 this doesn't matter (1997 is the program's
*** first year, so the annual flow *is* the cumulative total), but for
*** 1998-2005 the _fase variant needs an explicit running sum of the FASE
*** annual flows to produce a genuinely cumulative beneficiary count.
*** cc_pg_mun`i'_old is already cumulative (built as sum(pgbenef_old)/HH
*** earlier in this file) and needs no adjustment.
g pg_mun1997_cumfase = pg_mun1997_old
forv i=1998/2005 {
local j = `i'-1
g pg_mun`i'_cumfase = pg_mun`j'_cumfase + pg_mun`i'_old
}

forv i=1998/2005 {
g cc_pg_mun`i'_fase = cc_pg_mun`i'_old
g pg_mun`i'_fase    = pg_mun`i'_cumfase
}
forv i=2006/2018 {
g cc_pg_mun`i'_fase = cc_pg_mun`i'_new
g pg_mun`i'_fase    = pg_mun`i'_new
}
drop pg_mun*_cumfase

forv i=1997/2018 {
la var pg_mun`i'_mixed "Progresa - mun - benef `i' (mixed: FASE 1997, newProg 1998+)"
la var cc_pg_mun`i'_mixed "Progresa - mun - cumulative % covered `i' (mixed)"
la var pg_mun`i'_fase "Progresa - mun - benef `i' (FASE-only through 2005, matches P&V)"
la var cc_pg_mun`i'_fase "Progresa - mun - cumulative % covered `i' (FASE-only through 2005)"
}

drop pg_mun*_old pg_mun*_new cc_pg_mun*_old cc_pg_mun*_new ac_pg_mun*_old

misstable sum pg_* sp* cc*

save "$data/beneficiaries_mun_recoded_`year'.dta", replace
log close