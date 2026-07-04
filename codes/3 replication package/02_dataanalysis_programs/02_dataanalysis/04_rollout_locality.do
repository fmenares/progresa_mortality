************************************
**set up progresa beneficiary data**
************************************
use "$data/01_dataprep/fams_fase_20134xloc_f.dta",clear

//unique identifiers
isid CVE_EDO CVE_MUN CVE_LOC
gen loc=CVE_LOC

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

drop FASE* /*benef1996-benef2012*/ cum* anio bimestre
sort CVE_EDO CVE_MUN loc
save "$tempdata/Progresa_localitybenef.dta", replace

****************************************************************************
**equivalencia file for localities who change status between 2000 and 2019**
****************************************************************************

use "$data/02_dataanalysis/TablaEquivalencia.DTA",clear

//note: numeric variables as strings. need to convert
d

//year: only focus on splits between 2000 and 2005
gen year = real(substr(fecha_act,1,4))
tab year
keep if year<=2005

//drop some useless types of transition
tab descrip
tab descrip if cve_ent_act=="" //these are localities that disappeared
drop if cve_ent_act=="" //drop above localities, don't have current code
tab descrip if cve_ent_ori=="" //these are newly created/reactivated localities
drop if cve_ent_ori=="" //drop above localities, don't have past code
tab descrip if cve_ent_ori==cve_ent_act& ///
               cve_mun_ori==cve_mun_act& ///
			   cve_loc_ori==cve_loc_act //these localities have changed name but not code
drop if cve_ent_ori==cve_ent_act& ///
        cve_mun_ori==cve_mun_act& ///
		cve_loc_ori==cve_loc_act //drop above localities
		
//check for duplicates		
duplicates report cve_ent_ori cve_mun_ori cve_loc_ori //will have to combine if merge w progresa data
duplicates tag cve_ent_ori cve_mun_ori cve_loc_ori,gen(dup)
tab descrip dup
				
//convert strings to numerics
foreach var of varlist cve* {
  destring `var',replace
  }

//for merging on current code  
gen CVE_EDO=cve_ent_act
gen CVE_MUN=cve_mun_act
gen loc=cve_loc_act

save "$tempdata/TablaEquivalencia", replace


************************************
**locality level marginality index**
************************************

use "$data/01_dataprep/Base_marginacion_localidad_90-10.dta",clear
keep if año==1995
rename CVE_ENT CVE_EDO
rename long longitud
gen id=string(CVE_LOC, "%12.0f")
gen CVE_MUNICIPIO=real(substr(id, -7, 3))
gen CVE_LOCALIDAD=real(substr(id, -4, 4))
drop CVE_MUN CVE_LOC id
rename CVE_MUNICIPIO CVE_MUN
rename CVE_LOCALIDAD loc
sort CVE_EDO CVE_MUN loc
replace TOT_VIV = "." if TOT_VIV=="-" //destring household count
destring TOT_VIV,replace
sum
foreach var of varlist analf-vsexc { //loop to drop variables with only missing values
  sum `var'
  if r(N)==0 {
    drop `var'
  }
}

//hand match localities w benef9705>250 that did not merge
    replace loc = 99999 if NOM_LOC=="Candelaria"&NOM_ENT=="Campeche"
    replace loc = 99999 if NOM_LOC=="Benemerito De Las Americas"&NOM_ENT=="Chiapas"
    replace loc = 99999 if substr(NOM_LOC,1,5)=="Tulum"&NOM_ENT=="Quintana Roo"
    replace loc = 99999 if NOM_LOC=="Villa Juarez (Irrigacion)"&NOM_ENT=="Sonora"
    replace loc = 99999 if NOM_LOC=="Montecristo De Guerrero"&NOM_ENT=="Chiapas"
    replace loc = 99999 if NOM_LOC=="Trancoso"&NOM_ENT=="Zacatecas"
    replace loc = 99997 if NOM_LOC=="Paredoncito (El Tobari)"&NOM_ENT=="Sonora"
    replace loc = 99998 if NOM_LOC=="Paredon Colorado (Paredon Viejo)"&NOM_ENT=="Sonora"
    replace loc = 99999 if NOM_LOC=="Xpujil"&NOM_ENT=="Campeche"
	
save "$tempdata/Base_marginacion_localidad_1995.dta", replace

*************************************************************************
**merge progresa locality beneficiary with 1995 conapo marginality data**
*************************************************************************

//open Progresa locality beneficiary data
use "$tempdata/Progresa_localitybenef.dta",clear
sum benef9799 benef9705,d
count if benef9705>0
//hand match localities w benef9705>250 that did not merge
	replace loc=20 if CVE_EDO==30&CVE_MUN==209&CVE_LOC==1 //Tatahuicapan, Veracruz (benef9705=1104)
	replace CVE_MUN=104 if CVE_EDO==30&CVE_MUN==209&CVE_LOC==1 //Tatahuicapan, Veracruz (benef9705=1104)
	replace loc=99999 if CVE_EDO==7&CVE_MUN==114&CVE_LOC==1 //Benemerico de las Americas, Chiapas (benef9705=632)
	replace CVE_MUN=59 if CVE_EDO==7&CVE_MUN==114&CVE_LOC==1 //Benemerico de las Americas, Chiapas (benef9705=632)
	replace loc=99999 if CVE_EDO==4&CVE_MUN==11&CVE_LOC==1 //Candeleria, Chiapas (benef9705=533)
	replace CVE_MUN=3 if CVE_EDO==4&CVE_MUN==11&CVE_LOC==1 //Candeleria, Chiapas (benef9705=533)
	replace loc=99999 if CVE_EDO==23&CVE_MUN==9&CVE_LOC==1 //Tulum, Quintana Roo (benef9705=473)
	replace CVE_MUN=8 if CVE_EDO==23&CVE_MUN==9&CVE_LOC==1 //Tulum, Quintana Roo (benef9705=473)
	replace loc=99999 if CVE_EDO==26&CVE_MUN==71&CVE_LOC==1 //Villa Juarez, Sonora (benef9705=461)
	replace CVE_MUN=26 if CVE_EDO==26&CVE_MUN==71&CVE_LOC==1 //Villa Juarez, Sonora (benef9705=461)
	replace loc=99999 if CVE_EDO==7&CVE_MUN==117&CVE_LOC==1 //Montecristo De Guerrero, Chiapas (benef9705=421)
	replace CVE_MUN=8 if CVE_EDO==7&CVE_MUN==117&CVE_LOC==1 //Montecristo De Guerrero, Chiapas (benef9705=421)
 	replace loc=99999 if CVE_EDO==32&CVE_MUN==57&CVE_LOC==1 //Trancoso, Zacatecas (benef9705=347)
 	replace CVE_MUN=17 if CVE_EDO==32&CVE_MUN==57&CVE_LOC==1 //Trancoso, Zacatecas (benef9705=347)
	replace loc=99997 if CVE_EDO==26&CVE_MUN==71&CVE_LOC==141 //Paredoncito, Sonora (benef9705=303)
	replace CVE_MUN=26 if CVE_EDO==26&CVE_MUN==71&CVE_LOC==141 //Paredoncito, Sonora (benef9705=303)
	replace loc=99998 if CVE_EDO==26&CVE_MUN==71&CVE_LOC==139 //Paredon Colorado, Sonora (benef9705=275)
	replace CVE_MUN=26 if CVE_EDO==26&CVE_MUN==71&CVE_LOC==139 //Paredon Colorado, Sonora (benef9705=275)
	replace loc=99999 if CVE_EDO==4&CVE_MUN==10&CVE_LOC==1 //Xpujil, Campeche (benef9705=258)
	replace CVE_MUN=6 if CVE_EDO==4&CVE_MUN==10&CVE_LOC==1 //Xpujil, Campeche (benef9705=258)
	replace loc=1 if CVE_EDO==12&CVE_MUN==71&CVE_LOC==5 //Cozoyoapan, Guerrero used to be Xochistlahuaca, Gerrero (benef9705=312)
 	replace loc=41 if CVE_EDO==1&CVE_MUN==5&CVE_LOC==426 //Jesus Gomez Portugal (Margaritas), Aguascalientes (benef9705=290)
    replace loc=27 if CVE_EDO==16&CVE_MUN==25&CVE_LOC==2 //Acachuen, Michoacan (benef9705=266) part of Chilchota Tres
	replace loc=27 if CVE_EDO==16&CVE_MUN==16&CVE_LOC==16 //Uren, Michoacan (benef9705=152) part of Chilchota Tres
	replace loc=27 if CVE_EDO==16&CVE_MUN==16&CVE_LOC==15 //Tanaquillo, Michoacan (benef9705=142) part of Chilchota Tres
	replace loc=1 if CVE_EDO==12&CVE_MUN==67&CVE_LOC==13 //Nuevo Guerrero, Guerrero used to be part of Tlapehuala, Gerrero (benef9705=259)
//
drop benef1996-benef2012 benef0005_new
//merge locality-level marginality index 1995 file
merge m:1 CVE_EDO CVE_MUN loc using "$tempdata/Base_marginacion_localidad_1995.dta"
//22k didn't merge from marginality data. mostly small localities.
bysort _merge: sum POB_TOT,d
//25k didn't merge from Progresa data. mostly localities with few beneficiaries.
bysort _merge: sum benef9799 benef9705,d
//from unmerged Progresa localities, drop those with no enrollment by 2005
drop if benef9705==0&_merge==1
//now 9k didn't merge from Progresa data
bysort _merge: sum benef9799 benef9705,d
//save dataset with Progresa-only observations
preserve
keep if _merge==1
drop _merge NOM_ENT-año //NOM_ENT-año are variables from the other dataset
save "$tempdata/benef_unmerged.dta",replace
//save dataset with merged and marginality-only obsevations
restore
drop if _merge==1
drop _merge
save "$tempdata/benef_marg.dta",replace
//look for matches: progresa-only to equivalencia table based on CURRENT codes
use "$tempdata/TablaEquivalencia",clear
tab descrip dup
merge m:1 CVE_EDO CVE_MUN loc using "$tempdata/benef_unmerged"
//keep 800 matches
keep if _merge==3
drop dup _merge
duplicates tag cve_ent_ori cve_mun_ori cve_loc_ori,gen(dup)
tab descrip dup //all of the duplicates are from splits
//merge back to marginality data based on ORIGINAL codes
replace CVE_EDO = cve_ent_ori
replace CVE_MUN = cve_mun_ori
replace loc = cve_loc_ori
merge m:m CVE_EDO CVE_MUN loc using "$tempdata/benef_marg.dta"
//collapse splits and resave dataset with merged and marginality-only observations
preserve
keep if _merge==2|_merge==3
drop _merge
gen wtsum_iml = iml*POB_TOT
gen benef_missing = (benef9705==.)
collapse (sum) benef* wtsum_iml TOT_VIV POB_TOT,by(CVE_EDO CVE_MUN loc)
gen iml = wtsum_iml/POB_TOT
drop wtsum_iml
tab benef_missing
replace benef9799 = . if benef_missing==1
replace benef0005 = . if benef_missing==1
replace benef9705 = . if benef_missing==1
drop benef_missing
save "$tempdata/benef_marg.dta",replace
//resave dataset with Progresa-only observations
//(merge the successfully merged obs back onto benef_unmerged, then drop them)
restore
keep if _merge==3
drop _merge
replace CVE_EDO = cve_ent_act 
replace CVE_MUN = cve_mun_act 
replace loc = cve_loc_act
keep CVE_EDO CVE_MUN loc
merge m:m CVE_EDO CVE_MUN loc using "$tempdata/benef_unmerged"
drop if _merge==3
drop _merge
count //down to 8,133 progresa localities that don't merge
sum benef*,d //few beneficiaries
count if benef9705>=10 //1,775 localities with 10-250 beneficiaries don't merge
save "$tempdata/benef_unmerged.dta",replace

//back to merged dataset
use "$tempdata/benef_marg.dta",clear
count
count if benef9705>0&benef9705<.
keep if TOT_VIV>10 //keep only localities with at least 10 dwellings
                   //since the smaller ones are harder to merge and 
				   //more susceptible to measurement error in the
				   //denominator of benef/viv
sum benef*,d //much larger means and medians
//set benef variables to 0 if missing
//(this is correct for rich localities with 0 beneficiaries,
// and incorrect for the 8k localities that did not merge)
foreach var of varlist benef* {
  replace `var' = 0 if `var'==.
  }
//marginality categories: quantiles useful for graph
gen gml = 1 if iml<=-1.59
replace gml = 2 if iml>-1.59&iml<=-1.2
replace gml = 3 if iml>-1.2&iml<=-.61
replace gml = 4 if iml>-.61&iml<=.04
replace gml = 5 if iml>.04
tab gml
//define benef/viv
gen prop9799 = benef9799/TOT_VIV
gen prop0005 = benef0005/TOT_VIV
//should have max of 1 if HH = VIV. but HH != VIV 
//problem is smaller when look at localities with at least 100 dwellings
sum prop*,d 
egen rank = rank(iml),track
gen ptile = 100*rank/_N
gen x_bin = ceil(ptile)-.5
bysort x_bin: egen prop9799_mean = mean(prop9799)
bysort x_bin: egen prop0005_mean = mean(prop0005)
bysort x_bin: replace x_bin = . if _n>1 //so that we only plot one scatterpt per bin
twoway (scatter prop9799_mean x_bin,mcolor(dknavy*.5) msymbol(oh)) ///
       (scatter prop0005_mean x_bin,mcolor(orange_red*.33) msymbol(sh)) ///
	   (lpoly prop9799 ptile,degree(1) bw(2.5) lcolor(dknavy) lwidth(thick)) ///
       (lpoly prop0005 ptile,degree(1) bw(2.5) lcolor(orange_red) lpattern(dash) lwidth(thick)) ///
	   ,legend(off) aspect(1) xsize(4) xline(5 14 32 56,lpattern(dot)) /// 
		ytitle("Newly enrolled households / total dwellings") ///
		xtitle("Locality marginality percentile") ///
		text(.52 80 "1997-9",color(dknavy) place(nw)) ///
		text(.29 80 "2000-5",color(orange_red) place(se)) ///
		saving("$Results/figures/Fig2_loc_rollout_iml.gph",replace)	
gen absdiff = abs(prop0005_mean-prop9799_mean) if x_bin<.
gen absdiffgt10 = absdiff>.1 if absdiff<.
sum absdiff*,d



