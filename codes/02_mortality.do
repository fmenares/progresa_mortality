*** ============================================================================================================
*** DATA: Municiaplity data, Death data(vital statistics), Total population(Census), Population by age group (Census)
*** TOPIC: Regression AAMR (Municipality level) back to 1990
*** BY: Soomin 
*** ============================================================================================================
cls
clear
set more off


 if c(username)=="Soomin" {
 
 global Project "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS"
 global Data "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS/Progresa_Locality_Mortality_Project"
 global Benefdata "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS/SocialProgramBeneficiaries"
 global Vitaldata "/Users/soominryu/Dropbox (University of Michigan)/R01_MHAS/Mortality_VitalStatistics_Project" 
 cd "/Users/soominryu/Desktop"
}

 if c(username)=="FELIPEME" {
    global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global tables  "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\tables"
	global figures "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\figures"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}

 
 *	Interact with one post-dummy=1 - intensity99*post and one for intensity05*post. [MAY 2025]  
	use "$data/aamr_regression_municipality_gender_tb.dta", clear
	merge m:1 cve_ent_mun_super using "$data/inten1999.dta"
	drop _merge
	merge m:1 cve_ent_mun_super using "$data/inten2005.dta"
	drop _merge

	gen post=.
	replace post=2 if year <1997 & year >1990 & year!=.
	replace post=1 if year >=1997 & year <2007 & year!=.
	
	lab def post 1"1997-2006" 2"1991-1996" 
	lab val post post
	
*	Merge with Seguro Popular data
	merge 1:1 cve_ent_mun_super year using "$data/SP_2001_2018.dta"
	drop _merge
	order year cve_ent_mun_super inten1999 post sp_intensity
	
*	Restriction (year)
	keep if year >1990 & year <2007
	
	tab post 
	global sample_marg = "gm_mun_1990==4|gm_mun_1990==5"
	
	
	
lab var year "year"
	lab var inten1999 " "
	
	gen year_1995=.
	replace year_1995=1 if year==1991
	replace year_1995=2 if year==1992
	replace year_1995=3 if year==1993
	replace year_1995=4 if year==1994
	replace year_1995=5 if year==1995
	replace year_1995=6 if year==1996
	replace year_1995=7 if year==1997
	replace year_1995=8 if year==1998
	replace year_1995=9 if year==1999
	replace year_1995=10 if year==2000
	replace year_1995=11 if year==2001
	replace year_1995=12 if year==2002
	replace year_1995=13 if year==2003
	replace year_1995=14 if year==2004
	replace year_1995=15 if year==2005
	replace year_1995=16 if year==2006
	 
	lab var year_1995 "y"
	lab def year_1995 1"1991" 2"1992" 3"1993" 4"1994" 5"1995" 6"1996" 7"1997" 8"1998" 9"1999" ///
		10"2000" 11"2001" 12"2002" 13"2003" 14 "2004" 15"2005" 16"2006" 
	lab val year_1995 year_1995
	
	g aux = intensity_new if year == 2002
	bys cve_ent_mun_super: egen inten2002 = min(aux)
	drop aux
	g aux = intensity_new if year == 1997
	bys cve_ent_mun_super: egen inten1997 = min(aux)
	drop aux
	g aux = intensity_new if year == 1998
	bys cve_ent_mun_super: egen inten1998 = min(aux)
	drop aux
	g aux = intensity_new if year == 2000
	bys cve_ent_mun_super: egen inten2000 = min(aux)
	drop aux
	preserve

	*Restriction (marginalized areas)
	*keep if gm_mun_1990==4|gm_mun_1990==5
	keep year cve_ent_mun_super im_mun inten15 inten10 inten5 inten1999 ///
	inten2005 lag2_intensity_new intensity_new inten1997 inten1998 inten2000 inten_start_year gm_mun_1990
	
	save "$data/mortality_muni", replace
	restore

*============================================================
* FIGURES:
*============================================================

*============================================================
* FIGURE 1a: Mortality trends and PROGRESA penetration Highly marginalized municipalities
*============================================================


{
g intensity_new_per = intensity_new * 100
preserve
keep if $sample_marg
collapse (mean) emr65 emr65m emr65f intensity_new_per [aw=popover65_], by(year)
twoway (line emr65  year, lcolor(navy)        lpattern(solid)    yaxis(1)) ///
       (line emr65m year, lcolor(maroon)       lpattern(dash)     yaxis(1)) ///
       (line emr65f year, lcolor(forest_green) lpattern(dot)      yaxis(1)) ///
       (line intensity_new_per year, lcolor(orange) lpattern(longdash) yaxis(2)), ///
	ytitle("Mortality Rate (65+ per 1000)", axis(1)) ///
	ytitle("Progresa Penetration (%)", axis(2)) ///
	xtitle("Year") xline(1997, lpattern(dash) lcolor(gs10)) ///
	legend(order(1 "All" 2 "Male" 3 "Female" 4 "Intensity (right axis)") ///
	cols(4) size(medsmall) position(6) ring(1)) ///	
	graphregion(fcolor(white))
graph export "$figures/Figure_1a_marg.pdf", as(pdf) replace
restore
}
*============================================================
* FIGURE 1 b and c: Mexican municipality maps — PROGRESA intensity variation
*============================================================
* Requires: spmap (ssc install spmap)
{
* Setup (run once):
*   spshape2dta "<path/to/mexico_mun_shapefile>", saving("${shp}") replace
*   This creates ${shp}.dta (attribute file with _ID) and ${shp}_shp.dta (coordinates).
*   The attribute file must contain a variable matching cve_ent_mun_super.
*   For INEGI shapefiles the variable is typically CVEGEO (5-char string, e.g. "01001").
*   If cve_ent_mun_super is numeric, convert: tostring cve_ent_mun_super, gen(CVEGEO) format(%05.0f)
*   then merge on CVEGEO.
*

global shp "$data/mgm"   // update path to match local shapefile location

* ---- Step 1: Save intensity values to tempfile ----
* Preserving and restoring here just to extract municipality-level values cleanly.
* ---- Step 2: Build map base from shapefile — keeps _ID unique ----
* Strategy: start from the shapefile (one row per original INEGI polygon, unique _ID),
* add cve_ent_mun_super via the same crosswalk used in 03_descriptives.do,
* then merge intensity m:1 so every polygon in a super-municipality shares its intensity.
* This avoids the "_ID not unique" error that arises when merging the other direction.
*
* The attribute file (${shp}.dta) from spshape2dta typically has CVE_ENT (2-char string)
* and CVE_MUN (3-char string) from the INEGI shapefile — adjust names below if yours differ.



*Highly Marginalized Municipalities


preserve
keep if $sample_marg
keep cve_ent_mun_super inten1997 inten1998 inten1999 inten2000 inten2005
duplicates drop cve_ent_mun_super, force

tempfile inten_data
save `inten_data'
restore


preserve
use "${shp}\municipios_2000.dta", clear
*rename CVE_ENT cve_ent
*rename CVE_MUN cve_mun
merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", ///
	keepusing(cve_ent_mun_super) nogen
* Polygons with no crosswalk entry (no boundary change): build code from raw fields
replace cve_ent_mun_super = cve_ent + cve_mun if cve_ent_mun_super == ""
merge m:1 cve_ent_mun_super using `inten_data', nogen
sort _ID


local breaks1999 0 0.12 0.25 0.40 0.63 1


* ---- Map 1: Mortality sample — intensity 1999 ----
spmap inten1999 using "${shp}\municipios_2000_shp.dta", id(_ID) ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/Figure_1b_inten1999.pdf", as(pdf) replace width(5)

* ---- Map 2: Mortality sample — intensity 2005 ----
spmap inten2005 using "${shp}\municipios_2000_shp.dta", id(_ID) ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/Figure_1c_inten2005.pdf", as(pdf) replace width(2)

 *---- Map 5: Initial rollout 1997 — mortality sample ----
spmap inten1997 using "${shp}\municipios_2000_shp.dta", id(_ID) ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_1d_inten1997_mort.pdf", as(pdf) replace width(20)


restore

}


*============================================================
*Figure 2: Weighted + Seguro Popular — manual event study (pooled / female / male)
*============================================================

{ 
foreach grp in w f m {
	if "`grp'" == "w" {
		local outcome emr65
		local wvar   popover65_
	}
	else if "`grp'" == "f" {
		local outcome emr65f
		local wvar   popover65_f
	}
	else {
		local outcome emr65m
		local wvar   popover65_m
	}

	reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
		c.sp_intensity [aw=`wvar'] if $sample_marg, a(cve_ent_mun_super) ///
		vce(cluster cve_ent_mun_super)

	forval pos = 1/16 {
		if `pos' == 6 {
			local b_`grp'_6  = 0
			local se_`grp'_6 = 0
		}
		else {
			local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999]
			local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999]
		}
	}
}

preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_w = yr_pos - 0.18
gen xpos_f = yr_pos
gen xpos_m = yr_pos + 0.18
foreach grp in w f m {
	gen b_`grp'  = .
	gen hi_`grp' = .
	gen lo_`grp' = .
}
forval pos = 1/16 {
	foreach grp in w f m {
		replace b_`grp'  = `b_`grp'_`pos''                            if yr_pos == `pos'
		replace hi_`grp' = `b_`grp'_`pos'' + 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
		replace lo_`grp' = `b_`grp'_`pos'' - 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
	}
}
twoway ///
	(rcap hi_w lo_w xpos_w, ///
		lcolor(black%60) lwidth(vthin)) ///
	(connected b_w xpos_w, ///
		mcolor(black) lcolor(black) ///
		msymbol(circle) msize(vsmall) lwidth(thin) lpattern(solid)) ///
	(rcap hi_f lo_f xpos_f, ///
		lcolor(red%60) lwidth(vthin)) ///
	(connected b_f xpos_f, ///
		mcolor(red) lcolor(red) ///
		msymbol(square) msize(vsmall) lwidth(thin) lpattern(dash)) ///
	(rcap hi_m lo_m xpos_m, ///
		lcolor(blue%60) lwidth(vthin)) ///
	(connected b_m xpos_m, ///
		mcolor(blue%80) lcolor(blue%80) ///
		msymbol(triangle) msize(vsmall) lwidth(thin) lpattern(shortdash_dot)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	yscale(noline) ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(2 "Pooled" 4 "Female" 6 "Male") ///
		cols(3) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/Figure_2_w.pdf", as(pdf) replace
restore

}

*============================================================
* TABLE 1: Descriptives
*============================================================


*============================================================
* TABLE 2: Main DiD Mortality Results
*============================================================

foreach pnl in p m f {
	if "`pnl'" == "p" {
		local outcome emr65
		local wvar   popover65_
	}
	else if "`pnl'" == "m" {
		local outcome emr65m
		local wvar   popover65_m
	}
	else {
		local outcome emr65f
		local wvar   popover65_f
	}
	forval col = 1/4 {
		if `col' == 1 {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post ///
				if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else if `col' == 2 {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else if `col' == 3 {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post ///
				[aw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				[aw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		local aux: di %12.3f _b[1.post#c.inten1999]
		local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
		if      `t' >= 2.576 local b99_`pnl'_`col' = "`aux'***"
		else if `t' >= 1.96  local b99_`pnl'_`col' = "`aux'**"
		else if `t' >= 1.645 local b99_`pnl'_`col' = "`aux'*"
		else                  local b99_`pnl'_`col' = "`aux'"
		local se99_`pnl'_`col': di %12.3f _se[1.post#c.inten1999]
		local aux: di %12.3f _b[1.post#c.inten2005]
		local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
		if      `t' >= 2.576 local b05_`pnl'_`col' = "`aux'***"
		else if `t' >= 1.96  local b05_`pnl'_`col' = "`aux'**"
		else if `t' >= 1.645 local b05_`pnl'_`col' = "`aux'*"
		else                  local b05_`pnl'_`col' = "`aux'"
		local se05_`pnl'_`col': di %12.3f _se[1.post#c.inten2005]
		sum `outcome' if e(sample) & post == 2
		local mean_`pnl'_`col': di %12.2fc `r(mean)'
		local N_`pnl'_`col':    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local Nmun_`pnl'_`col': di %12.0fc `r(ndistinct)'
	}
}

{
	cap file close sm
	file open sm using "$tables/T2_mortality.tex", write replace
	file write sm "\begin{tabular}{lcccc} \hline \hline" _n
	*file write sm "& UW & UW+SP & W & W+SP \\ " _n
	*file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_p_1' & `b99_p_2' & `b99_p_3' & `b99_p_4' \\ " _n
	file write sm " & (`se99_p_1') & (`se99_p_2') & (`se99_p_3') & (`se99_p_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_p_1' & `b05_p_2' & `b05_p_3' & `b05_p_4' \\ " _n
	file write sm " & (`se05_p_1') & (`se05_p_2') & (`se05_p_3') & (`se05_p_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_p_1' & `mean_p_2' & `mean_p_3' & `mean_p_4' \\ " _n
	file write sm "Obs & `N_p_1' & `N_p_2' & `N_p_3' & `N_p_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\underline{\textit{Panel B: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_m_1' & `b99_m_2' & `b99_m_3' & `b99_m_4' \\ " _n
	file write sm " & (`se99_m_1') & (`se99_m_2') & (`se99_m_3') & (`se99_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_m_1' & `b05_m_2' & `b05_m_3' & `b05_m_4' \\ " _n
	file write sm " & (`se05_m_1') & (`se05_m_2') & (`se05_m_3') & (`se05_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_m_1' & `mean_m_2' & `mean_m_3' & `mean_m_4' \\ " _n
	file write sm "Obs & `N_m_1' & `N_m_2' & `N_m_3' & `N_m_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\underline{\textit{Panel C: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_f_1' & `b99_f_2' & `b99_f_3' & `b99_f_4' \\ " _n
	file write sm " & (`se99_f_1') & (`se99_f_2') & (`se99_f_3') & (`se99_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_f_1' & `b05_f_2' & `b05_f_3' & `b05_f_4' \\ " _n
	file write sm " & (`se05_f_1') & (`se05_f_2') & (`se05_f_3') & (`se05_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_f_1' & `mean_f_2' & `mean_f_3' & `mean_f_4' \\ " _n
	file write sm "Obs & `N_f_1' & `N_f_2' & `N_f_3' & `N_f_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "No. Mun & `Nmun_p_1' & `Nmun_p_2' & `Nmun_p_3' & `Nmun_p_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Year FE & Y & Y & Y & Y \\ " _n
	file write sm "Mun FE & Y & Y & Y & Y \\ " _n
	file write sm "Seguro Popular & N & Y & N & Y \\ " _n
	file write sm "Weights & N & N & Y & Y \\ " _n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}


*============================================================
* APPENDIX FIGURES: 
*============================================================


*============================================================
* FIGURE 1a: Mortality trends and PROGRESA penetration All municipalities
*============================================================

{


preserve
collapse (mean) emr65 emr65m emr65f intensity_new_per [aw=popover65_], by(year)
twoway (line emr65  year, lcolor(navy)        lpattern(solid)    yaxis(1)) ///
       (line emr65m year, lcolor(maroon)       lpattern(dash)     yaxis(1)) ///
       (line emr65f year, lcolor(forest_green) lpattern(dot)      yaxis(1)) ///
       (line intensity_new_per year, lcolor(orange) lpattern(longdash) yaxis(2)), ///
	ytitle("Mortality Rate (65+ per 1000)", axis(1)) ///
	ytitle("Progresa Intensity (%)", axis(2)) ///
	xtitle("Year") xline(1997, lpattern(dash) lcolor(gs10)) ///
	legend(order(1 "All" 2 "Male" 3 "Female" 4 "Intensity (right axis)") ///
	cols(4) size(medsmall) position(6) ring(1)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_1a_all.pdf", as(pdf) replace
restore
}
*============================================================
* FIGURE 1 b c: Mexican municipality maps — PROGRESA intensity variation *All Municipalities
*============================================================
* Requires: spmap (ssc install spmap)
{
* Setup (run once):
*   spshape2dta "<path/to/mexico_mun_shapefile>", saving("${shp}") replace
*   This creates ${shp}.dta (attribute file with _ID) and ${shp}_shp.dta (coordinates).
*   The attribute file must contain a variable matching cve_ent_mun_super.
*   For INEGI shapefiles the variable is typically CVEGEO (5-char string, e.g. "01001").
*   If cve_ent_mun_super is numeric, convert: tostring cve_ent_mun_super, gen(CVEGEO) format(%05.0f)
*   then merge on CVEGEO.
*

global shp "$data/mgm"   // update path to match local shapefile location

* ---- Step 1: Save intensity values to tempfile ----
* Preserving and restoring here just to extract municipality-level values cleanly.
* ---- Step 2: Build map base from shapefile — keeps _ID unique ----
* Strategy: start from the shapefile (one row per original INEGI polygon, unique _ID),
* add cve_ent_mun_super via the same crosswalk used in 03_descriptives.do,
* then merge intensity m:1 so every polygon in a super-municipality shares its intensity.
* This avoids the "_ID not unique" error that arises when merging the other direction.
*
* The attribute file (${shp}.dta) from spshape2dta typically has CVE_ENT (2-char string)
* and CVE_MUN (3-char string) from the INEGI shapefile — adjust names below if yours differ.


preserve
keep cve_ent_mun_super inten1997 inten1998 inten1999 inten2000 inten2005
duplicates drop cve_ent_mun_super, force

tempfile inten_data_all
save `inten_data_all'
restore


preserve
use "${shp}\municipios_2000.dta", clear
*rename CVE_ENT cve_ent
*rename CVE_MUN cve_mun
merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", ///
	keepusing(cve_ent_mun_super) nogen
* Polygons with no crosswalk entry (no boundary change): build code from raw fields
replace cve_ent_mun_super = cve_ent + cve_mun if cve_ent_mun_super == ""
merge m:1 cve_ent_mun_super using `inten_data_all', nogen
sort _ID

local breaks1999 0 0.12 0.25 0.40 0.63 1
* ---- Map 1: Mortality sample — intensity 1999 ----
spmap inten1999 using "${shp}\municipios_2000_shp.dta", id(_ID)  ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_1b_inten1999_all.pdf", as(pdf) replace width(0.7)

* ---- Map 2: Mortality sample — intensity 2005 ----
spmap inten2005 using "${shp}\municipios_2000_shp.dta", id(_ID)  ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_1c_inten2005_all.pdf", as(pdf) replace width(0.5)

* ---- Map 5: Initial rollout 1997 — mortality sample (all municipalities) ----
spmap inten1997 using "${shp}\municipios_2000_shp.dta", id(_ID) /// 
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_1e_inten1997_mort_all.pdf", as(pdf) replace width(1)



restore

}


*============================================================
*Fig 2: Unweighted + Seguro Popular — manual event study (pooled / female / male)
*============================================================
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
{
foreach grp in w f m {
	if "`grp'" == "w" local outcome emr65
	if "`grp'" == "f" local outcome emr65f
	if "`grp'" == "m" local outcome emr65m

	reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
		c.sp_intensity if $sample_marg, a(cve_ent_mun_super) ///
		vce(cluster cve_ent_mun_super)

	forval pos = 1/16 {
		if `pos' == 6 {
			local b_`grp'_6  = 0
			local se_`grp'_6 = 0
		}
		else {
			local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999]
			local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999]
		}
	}
}

preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_w = yr_pos - 0.18
gen xpos_f = yr_pos
gen xpos_m = yr_pos + 0.18
foreach grp in w f m {
	gen b_`grp'  = .
	gen hi_`grp' = .
	gen lo_`grp' = .
}
forval pos = 1/16 {
	foreach grp in w f m {
		replace b_`grp'  = `b_`grp'_`pos''                            if yr_pos == `pos'
		replace hi_`grp' = `b_`grp'_`pos'' + 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
		replace lo_`grp' = `b_`grp'_`pos'' - 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
	}
}
twoway ///
	(rcap hi_w lo_w xpos_w, ///
		lcolor(black%60) lwidth(vthin)) ///
	(connected b_w xpos_w, ///
		mcolor(black) lcolor(black) ///
		msymbol(circle) msize(vsmall) lwidth(thin) lpattern(solid)) ///
	(rcap hi_f lo_f xpos_f, ///
		lcolor(red%60) lwidth(vthin)) ///
	(connected b_f xpos_f, ///
		mcolor(red) lcolor(red) ///
		msymbol(square) msize(vsmall) lwidth(thin) lpattern(dash)) ///
	(rcap hi_m lo_m xpos_m, ///
		lcolor(blue%60) lwidth(vthin)) ///
	(connected b_m xpos_m, ///
		mcolor(blue%80) lcolor(blue%80) ///
		msymbol(triangle) msize(vsmall) lwidth(thin) lpattern(shortdash_dot)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	yscale(noline) ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(2 "Pooled" 4 "Female" 6 "Male") ///
		cols(3) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/appendix/Figure_2_uw.pdf", as(pdf) replace
restore
}
*============================================================
* APPENDIX FIGURE 3: Event Study — AAMR65 (1995 standard population)
*============================================================
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

forval col = 1/4 {

	if `col' == 1 local col_note "Unweighted"
	if `col' == 2 local col_note "Unweighted + Seguro Popular"
	if `col' == 3 local col_note "Weighted"
	if `col' == 4 local col_note "Weighted + Seguro Popular"

	*--- Run three regressions (pooled, female, male) and store coefficients ---
	foreach grp in w f m {

		if "`grp'" == "w" {
			local outcome aamr65
			local wvar   popover65_
		}
		else if "`grp'" == "f" {
			local outcome aamr65f
			local wvar   popover65_f
		}
		else {
			local outcome aamr65m
			local wvar   popover65_m
		}

		if `col' == 1 {
			reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
				if $sample_marg, a(cve_ent_mun_super) ///
				vce(cluster cve_ent_mun_super)
		}
		else if `col' == 2 {
			reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
				c.sp_intensity if $sample_marg, a(cve_ent_mun_super) ///
				vce(cluster cve_ent_mun_super)
		}
		else if `col' == 3 {
			reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
				[aw=`wvar'] if $sample_marg, a(cve_ent_mun_super) ///
				vce(cluster cve_ent_mun_super)
		}
		else {
			reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
				c.sp_intensity [aw=`wvar'] if $sample_marg, a(cve_ent_mun_super) ///
				vce(cluster cve_ent_mun_super)
		}

		*--- Extract year x inten1999 coefficients; reference year (pos 6 = 1996) set to 0 ---
		forval pos = 1/16 {
			if `pos' == 6 {
				local b_`grp'_6  = 0
				local se_`grp'_6 = 0
			}
			else {
				local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999]
				local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999]
			}
		}
	}

	*--- Build plotting dataset and export figure ---
	preserve
	clear
	set obs 16

	gen yr_pos = _n
	gen xpos_w = yr_pos - 0.18
	gen xpos_f = yr_pos
	gen xpos_m = yr_pos + 0.18

	foreach grp in w f m {
		gen b_`grp'  = .
		gen hi_`grp' = .
		gen lo_`grp' = .
	}

	forval pos = 1/16 {
		foreach grp in w f m {
			replace b_`grp'  = `b_`grp'_`pos''                            if yr_pos == `pos'
			replace hi_`grp' = `b_`grp'_`pos'' + 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
			replace lo_`grp' = `b_`grp'_`pos'' - 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
		}
	}

	twoway ///
		(rcap hi_w lo_w xpos_w, ///
			lcolor(black%60) lwidth(vthin)) ///
		(connected b_w xpos_w, ///
			mcolor(black) lcolor(black) ///
			msymbol(circle) msize(vsmall) lwidth(thin) lpattern(solid)) ///
		(rcap hi_f lo_f xpos_f, ///
			lcolor(red%60) lwidth(vthin)) ///
		(connected b_f xpos_f, ///
			mcolor(red) lcolor(red) ///
			msymbol(square) msize(vsmall) lwidth(thin) lpattern(dash)) ///
		(rcap hi_m lo_m xpos_m, ///
			lcolor(blue%60) lwidth(vthin)) ///
		(connected b_m xpos_m, ///
			mcolor(blue%80) lcolor(blue%80) ///
			msymbol(triangle) msize(vsmall) lwidth(thin) lpattern(shortdash_dot)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("AAMR 65+ (per 1,000)", size(medsmall)) ///
		yscale(noline) ylabel(, grid gmin gmax labsize(small)) ///
			legend(order(2 "Pooled" 4 "Female" 6 "Male") ///
			cols(3) size(medsmall) position(6) ring(1) ///
			region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))

	graph export "$figures/appendix/Figure_3_aamr_col`col'.pdf", as(pdf) replace
	restore
} // end forval col = 1/4

*First we get the PostxIntensity 1999, getting a negative and significant of 3.9
 
**Event Study (This would be similar to F2) *Unweighted
*============================================================
* APPENDIX FIGURE: Short-term Event Study (Barham & Rowberry sample)
* FA_BR_es_pooled.pdf -- pooled, 3 specs: UW / W / W+SP
*============================================================
local yr_labels_br `"2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002""'

foreach spec in uw w wsp {
	if "`spec'" == "uw" {
		reghdfe emr65 c.inten1999##ib6.year_1995 if inrange(year,1992,2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if "`spec'" == "w" {
		reghdfe emr65 c.inten1999##ib6.year_1995 [aw=popover65_] if inrange(year,1992,2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else {
		reghdfe emr65 c.inten1999##ib6.year_1995 c.sp_intensity [aw=popover65_] if inrange(year,1992,2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	forval pos = 2/12 {
		if `pos' == 6 {
			local b_`spec'_`pos'  = 0
			local se_`spec'_`pos' = 0
		}
		else {
			local b_`spec'_`pos'  = _b[`pos'.year_1995#c.inten1999]
			local se_`spec'_`pos' = _se[`pos'.year_1995#c.inten1999]
		}
	}
}
preserve
clear
set obs 11
gen yr_pos = _n + 1
gen xpos_uw  = yr_pos
gen xpos_w   = yr_pos - 0.15
gen xpos_wsp = yr_pos + 0.15
foreach spec in uw w wsp {
	gen b_`spec'  = .
	gen hi_`spec' = .
	gen lo_`spec' = .
}
forval pos = 2/12 {
	foreach spec in uw w wsp {
		replace b_`spec'  = `b_`spec'_`pos''                             if yr_pos == `pos'
		replace hi_`spec' = `b_`spec'_`pos'' + 1.96 * `se_`spec'_`pos'' if yr_pos == `pos'
		replace lo_`spec' = `b_`spec'_`pos'' - 1.96 * `se_`spec'_`pos'' if yr_pos == `pos'
	}
}
twoway ///
	(rcap hi_uw lo_uw xpos_uw, lcolor(black%60) lwidth(vthin)) ///
	(connected b_uw xpos_uw, mcolor(black) lcolor(black) msymbol(circle) msize(vsmall) lwidth(thin) lpattern(solid)) ///
	(rcap hi_w lo_w xpos_w, lcolor(blue%60) lwidth(vthin)) ///
	(connected b_w xpos_w, mcolor(blue%80) lcolor(blue%80) msymbol(triangle) msize(vsmall) lwidth(thin) lpattern(shortdash_dot)) ///
	(rcap hi_wsp lo_wsp xpos_wsp, lcolor(red%60) lwidth(vthin)) ///
	(connected b_wsp xpos_wsp, mcolor(red) lcolor(red) msymbol(square) msize(vsmall) lwidth(thin) lpattern(dash)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels_br', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(1.5 12.5)) ///
	xtitle("") ///
	ytitle("Excess Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	yscale(noline) ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(2 "Unweighted" 4 "Weighted" 6 "Weighted + SP") ///
		cols(3) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/FA_BR_es_pooled.pdf", as(pdf) replace
restore

*============================================================
* APPENDIX TABLE: BR Analysis — Table FA_BR_table.tex
*============================================================
* Col 1: BR sample + UW + 1992-2002, inten1999#post + inten2002#post
reghdfe emr65 c.inten1999#i.post c.inten2002#i.post if ///
 inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local bBR_1 = "`aux'***"
else if `t' >= 1.96  local bBR_1 = "`aux'**"
else if `t' >= 1.645 local bBR_1 = "`aux'*"
else                  local bBR_1 = "`aux'"
local seBR_1: di %12.3f _se[1.post#c.inten1999]
sum emr65 if e(sample) & post == 2
local meanBR_1: di %12.2fc `r(mean)'
local NBR_1: di %12.0fc `e(N)'

* Col 2: BR sample + W + 1992-2002, inten1999#post + inten2002#post
reghdfe emr65 c.inten1999#i.post c.inten2002#i.post [aw=popover65_] if ///
 inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local bBR_2 = "`aux'***"
else if `t' >= 1.96  local bBR_2 = "`aux'**"
else if `t' >= 1.645 local bBR_2 = "`aux'*"
else                  local bBR_2 = "`aux'"
local seBR_2: di %12.3f _se[1.post#c.inten1999]
sum emr65 if e(sample) & post == 2
local meanBR_2: di %12.2fc `r(mean)'
local NBR_2: di %12.0fc `e(N)'

* Col 3: BR+marg + UW + 1992-2002, lag2_intensity_new
reghdfe emr65 lag2_intensity_new if ///
 inrange(year, 1992, 2002) & $sample_br & $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bBR_3 = "`aux'***"
else if `t' >= 1.96  local bBR_3 = "`aux'**"
else if `t' >= 1.645 local bBR_3 = "`aux'*"
else                  local bBR_3 = "`aux'"
local seBR_3: di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & post == 2
local meanBR_3: di %12.2fc `r(mean)'
local NBR_3: di %12.0fc `e(N)'

* Col 4: BR+marg + W + 1992-2002, lag2_intensity_new
reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
 inrange(year, 1992, 2002) & $sample_br & $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bBR_4 = "`aux'***"
else if `t' >= 1.96  local bBR_4 = "`aux'**"
else if `t' >= 1.645 local bBR_4 = "`aux'*"
else                  local bBR_4 = "`aux'"
local seBR_4: di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & post == 2
local meanBR_4: di %12.2fc `r(mean)'
local NBR_4: di %12.0fc `e(N)'

* Col 5: BR full period + UW + 1992-2006, lag2_intensity_new
reghdfe emr65 lag2_intensity_new if ///
 inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bBR_5 = "`aux'***"
else if `t' >= 1.96  local bBR_5 = "`aux'**"
else if `t' >= 1.645 local bBR_5 = "`aux'*"
else                  local bBR_5 = "`aux'"
local seBR_5: di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & post == 2
local meanBR_5: di %12.2fc `r(mean)'
local NBR_5: di %12.0fc `e(N)'

* Col 6: BR full period + W + 1992-2006, lag2_intensity_new
reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
 inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bBR_6 = "`aux'***"
else if `t' >= 1.96  local bBR_6 = "`aux'**"
else if `t' >= 1.645 local bBR_6 = "`aux'*"
else                  local bBR_6 = "`aux'"
local seBR_6: di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & post == 2
local meanBR_6: di %12.2fc `r(mean)'
local NBR_6: di %12.0fc `e(N)'

* Col 7: BR+marg + W + 1992-2006, lag2_intensity_new
reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
 inrange(year, 1992, 2006) & $sample_br & $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bBR_7 = "`aux'***"
else if `t' >= 1.96  local bBR_7 = "`aux'**"
else if `t' >= 1.645 local bBR_7 = "`aux'*"
else                  local bBR_7 = "`aux'"
local seBR_7: di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & post == 2
local meanBR_7: di %12.2fc `r(mean)'
local NBR_7: di %12.0fc `e(N)'

* Col 8: inten1999#post + UW + 1992-2006
reghdfe emr65 c.inten1999#i.post if ///
 inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local bBR_8 = "`aux'***"
else if `t' >= 1.96  local bBR_8 = "`aux'**"
else if `t' >= 1.645 local bBR_8 = "`aux'*"
else                  local bBR_8 = "`aux'"
local seBR_8: di %12.3f _se[1.post#c.inten1999]
sum emr65 if e(sample) & post == 2
local meanBR_8: di %12.2fc `r(mean)'
local NBR_8: di %12.0fc `e(N)'

* Col 9: inten1999#post + W + 1992-2006
reghdfe emr65 c.inten1999#i.post [aw=popover65_] if ///
 inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local bBR_9 = "`aux'***"
else if `t' >= 1.96  local bBR_9 = "`aux'**"
else if `t' >= 1.645 local bBR_9 = "`aux'*"
else                  local bBR_9 = "`aux'"
local seBR_9: di %12.3f _se[1.post#c.inten1999]
sum emr65 if e(sample) & post == 2
local meanBR_9: di %12.2fc `r(mean)'
local NBR_9: di %12.0fc `e(N)'

* Col 10: inten1999#post + inten2002#post + W + 1992-2006
reghdfe emr65 c.inten1999#i.post c.inten2002#i.post [aw=popover65_] if ///
 inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local bBR_10 = "`aux'***"
else if `t' >= 1.96  local bBR_10 = "`aux'**"
else if `t' >= 1.645 local bBR_10 = "`aux'*"
else                  local bBR_10 = "`aux'"
local seBR_10: di %12.3f _se[1.post#c.inten1999]
sum emr65 if e(sample) & post == 2
local meanBR_10: di %12.2fc `r(mean)'
local NBR_10: di %12.0fc `e(N)'

{
	cap file close sm
	file open sm using "$tables/FA_BR_table.tex", write replace
	file write sm "\begin{tabular}{lcccccccccc} \hline \hline" _n
	file write sm "& \multicolumn{10}{c}{Main Coefficient (EMR 65+)} \\ " _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} & \multicolumn{1}{c}{(9)} & \multicolumn{1}{c}{(10)} \\ \toprule" _n
	file write sm "\textit{Main coeff} & `bBR_1' & `bBR_2' & `bBR_3' & `bBR_4' & `bBR_5' & `bBR_6' & `bBR_7' & `bBR_8' & `bBR_9' & `bBR_10' \\ " _n
	file write sm " & (`seBR_1') & (`seBR_2') & (`seBR_3') & (`seBR_4') & (`seBR_5') & (`seBR_6') & (`seBR_7') & (`seBR_8') & (`seBR_9') & (`seBR_10') \\ " _n
	file write sm "  & & & & & & & & & & \\ " _n
	file write sm "Mean (pre) & `meanBR_1' & `meanBR_2' & `meanBR_3' & `meanBR_4' & `meanBR_5' & `meanBR_6' & `meanBR_7' & `meanBR_8' & `meanBR_9' & `meanBR_10' \\ " _n
	file write sm "Obs & `NBR_1' & `NBR_2' & `NBR_3' & `NBR_4' & `NBR_5' & `NBR_6' & `NBR_7' & `NBR_8' & `NBR_9' & `NBR_10' \\ " _n
	file write sm "  & & & & & & & & & & \\ " _n
	file write sm "Treatment var & inten99*post & inten99*post & lag2inten & lag2inten & lag2inten & lag2inten & lag2inten & inten99*post & inten99*post & inten99*post \\ " _n
	file write sm "Sample & BR & BR & BR+marg & BR+marg & BR & BR & BR+marg & BR & BR & BR \\ " _n
	file write sm "Period & 92-02 & 92-02 & 92-02 & 92-02 & 92-06 & 92-06 & 92-06 & 92-06 & 92-06 & 92-06 \\ " _n
	file write sm "Weighted & N & Y & N & Y & N & Y & Y & N & Y & Y \\ " _n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
	restore

} // end forval col



*============================================================
* APPENDIX TABLE 1: Barham & Rowberry (2013) Replication
*============================================================

global sample_br = "(inten_start_year==1998 |inten_start_year==1999)"

* Run all 4 specs for each sex; capture mean/N/Nmun per sex per column
foreach pnl in p m f {
	if "`pnl'" == "p" {
		local outcome emr65
		local wvar   popover65_
	}
	else if "`pnl'" == "m" {
		local outcome emr65m
		local wvar   popover65_m
	}
	else {
		local outcome emr65f
		local wvar   popover65_f
	}
	* panel  b: lag2, UW
	reghdfe `outcome' lag2_intensity_new if inrange(year, 1992, 2002) & $sample_br, ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[lag2_intensity_new]
	local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
	if      `t' >= 2.576 local bBR2_2_`pnl' = "`aux'***"
	else if `t' >= 1.96  local bBR2_2_`pnl' = "`aux'**"
	else if `t' >= 1.645 local bBR2_2_`pnl' = "`aux'*"
	else                  local bBR2_2_`pnl' = "`aux'"
	local seBR2_2_`pnl': di %12.3f _se[lag2_intensity_new]
	sum `outcome' if e(sample) & year  == 1996
	local meanBR_2_`pnl': di %12.2fc `r(mean)'
	local NBR_2_`pnl': di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunBR_2_`pnl': di %12.0fc `r(ndistinct)'
	* panel c: lag2, W
	reghdfe `outcome' lag2_intensity_new [aw=`wvar'] if inrange(year, 1992, 2002) & $sample_br, ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[lag2_intensity_new]
	local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
	if      `t' >= 2.576 local bBR2_3_`pnl' = "`aux'***"
	else if `t' >= 1.96  local bBR2_3_`pnl' = "`aux'**"
	else if `t' >= 1.645 local bBR2_3_`pnl' = "`aux'*"
	else                  local bBR2_3_`pnl' = "`aux'"
	local seBR2_3_`pnl': di %12.3f _se[lag2_intensity_new]
	sum `outcome' if e(sample) & year  == 1996
	local meanBR_3_`pnl': di %12.2fc `r(mean)'
	local NBR_3_`pnl': di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunBR_3_`pnl': di %12.0fc `r(ndistinct)'
	* panel d: lag1, W
	reghdfe `outcome' lag_intensity_new [aw=`wvar'] if inrange(year, 1991, 2001) & $sample_br, ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[lag_intensity_new]
	local t = abs(_b[lag_intensity_new] / _se[lag_intensity_new])
	if      `t' >= 2.576 local bBR1_4_`pnl' = "`aux'***"
	else if `t' >= 1.96  local bBR1_4_`pnl' = "`aux'**"
	else if `t' >= 1.645 local bBR1_4_`pnl' = "`aux'*"
	else                  local bBR1_4_`pnl' = "`aux'"
	local seBR1_4_`pnl': di %12.3f _se[lag_intensity_new]
	sum `outcome' if e(sample) & year  == 1996
	local meanBR_4_`pnl': di %12.2fc `r(mean)'
	local NBR_4_`pnl': di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunBR_4_`pnl': di %12.0fc `r(ndistinct)'
	* Col 5: lag3, W
	reghdfe `outcome' lag3_intensity_new [aw=`wvar'] if inrange(year, 1993, 2003) & $sample_br, ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[lag3_intensity_new]
	local t = abs(_b[lag3_intensity_new] / _se[lag3_intensity_new])
	if      `t' >= 2.576 local bBR3_5_`pnl' = "`aux'***"
	else if `t' >= 1.96  local bBR3_5_`pnl' = "`aux'**"
	else if `t' >= 1.645 local bBR3_5_`pnl' = "`aux'*"
	else                  local bBR3_5_`pnl' = "`aux'"
	local seBR3_5_`pnl': di %12.3f _se[lag3_intensity_new]
	sum `outcome' if e(sample) & year  == 1996
	local meanBR_5_`pnl': di %12.2fc `r(mean)'
	local NBR_5_`pnl': di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunBR_5_`pnl': di %12.0fc `r(ndistinct)'
}

{
	cap file close sm
	file open sm using "$tables/appendix/AT1_BR_replication.tex", write replace
	file write sm "\begin{tabular}{lccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{Pooled} & \multicolumn{1}{c}{Males} & \multicolumn{1}{c}{Females} \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}  " _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\ \toprule " _n
	* Panel A: hardcoded BR (2013) original results
	file write sm "\underline{\textit{Panel A: BR (2013)}}  \\ " _n
	file write sm "\textit{2-yr lagged Intensity} & -6.37*** & -6.42*** & -6.46*** \\ " _n
	file write sm " & (1.04) & (1.42) & (1.31) \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean 1996 & 47.5 & 49.3 & 46.0 \\ " _n
	file write sm "Obs & 21,571 & 21,571 & 21,571 \\ " _n
	file write sm "No. Mun & 1,961 & 1,961 & 1,961 \\ " _n
	file write sm "  & & & \\ " _n
	* Panel B: lag2, UW
	file write sm "\underline{\textit{Panel B: Replication (Unweighted)}}  \\ " _n
	file write sm "\textit{2-yr lagged Intensity} & `bBR2_2_p' & `bBR2_2_m' & `bBR2_2_f' \\ " _n
	file write sm " & (`seBR2_2_p') & (`seBR2_2_m') & (`seBR2_2_f') \\ " _n
	file write sm "  & & & \\ " _n
	* Panel C: lag2, W
	file write sm "\underline{\textit{Panel C: Replication (Weighted)}}  \\ " _n
	file write sm "\textit{2-yr lagged Intensity} & `bBR2_3_p' & `bBR2_3_m' & `bBR2_3_f' \\ " _n
	file write sm " & (`seBR2_3_p') & (`seBR2_3_m') & (`seBR2_3_f') \\ " _n
	file write sm "  & & & \\ " _n
	* Panel D: lag1, W
	file write sm "\underline{\textit{Panel D: 1-yr Lag (Weighted)}}  \\ " _n
	file write sm "\textit{1-yr lagged Intensity} & `bBR1_4_p' & `bBR1_4_m' & `bBR1_4_f' \\ " _n
	file write sm " & (`seBR1_4_p') & (`seBR1_4_m') & (`seBR1_4_f') \\ " _n
	file write sm "  & & & \\ " _n
	* Panel E: lag3, W
	file write sm "\underline{\textit{Panel E: 3-yr Lag (Weighted)}}  \\ " _n
	file write sm "\textit{3-yr lagged Intensity} & `bBR3_5_p' & `bBR3_5_m' & `bBR3_5_f' \\ " _n
	file write sm " & (`seBR3_5_p') & (`seBR3_5_m') & (`seBR3_5_f') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean 1996 & `meanBR_5_p' & `meanBR_5_m' & `meanBR_5_f' \\ " _n
	file write sm "Obs & `NBR_5_p' & `NBR_5_m' & `NBR_5_f' \\ " _n
	file write sm "No. Mun & `NmunBR_2_p' & `NmunBR_2_m' & `NmunBR_2_f' \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Year FE & Y & Y & Y \\ " _n
	file write sm "Mun FE & Y & Y & Y \\ " _n
	file write sm "Cluster SE: Mun & Y & Y & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}


*============================================================
* APPENDIX TABLE 2: Functional Form Robustness
*============================================================

g lemr65       = log(emr65)
g lemr65m      = log(emr65m)
g lemr65f      = log(emr65f)
g lpopover65   = log(popover65_)
g lpopover65_m = log(popover65_m)
g lpopover65_f = log(popover65_f)

foreach pnl in p m f {
	if "`pnl'" == "p" {
		local outcome  emr65
		local loutcome lemr65
		local doutcome death65
		local offset   lpopover65
		local wvar     popover65_
	}
	else if "`pnl'" == "m" {
		local outcome  emr65m
		local loutcome lemr65m
		local doutcome death65m
		local offset   lpopover65_m
		local wvar     popover65_m
	}
	else {
		local outcome  emr65f
		local loutcome lemr65f
		local doutcome death65f
		local offset   lpopover65_f
		local wvar     popover65_f
	}
	
	* col 4: levels, weighted
	reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post ///
		[pw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local bFF99_`pnl'_4 = "`aux'***"
	else if `t' >= 1.96  local bFF99_`pnl'_4 = "`aux'**"
	else if `t' >= 1.645 local bFF99_`pnl'_4 = "`aux'*"
	else                  local bFF99_`pnl'_4 = "`aux'"
	local seFF99_`pnl'_4: di %12.3f _se[1.post#c.inten1999]
	local aux: di %12.3f _b[1.post#c.inten2005]
	local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
	if      `t' >= 2.576 local bFF05_`pnl'_4 = "`aux'***"
	else if `t' >= 1.96  local bFF05_`pnl'_4 = "`aux'**"
	else if `t' >= 1.645 local bFF05_`pnl'_4 = "`aux'*"
	else                  local bFF05_`pnl'_4 = "`aux'"
	local seFF05_`pnl'_4: di %12.3f _se[1.post#c.inten2005]
	sum `outcome' if e(sample) & post == 2
	local meanFF_`pnl'_4: di %12.2fc `r(mean)'
	local NFF_`pnl'_4:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunFF_`pnl'_4: di %12.0fc `r(ndistinct)'
	* col 5: log EMR, weighted
	reghdfe `loutcome' c.inten1999#i.post c.inten2005#i.post ///
		[pw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local bFF99_`pnl'_5 = "`aux'***"
	else if `t' >= 1.96  local bFF99_`pnl'_5 = "`aux'**"
	else if `t' >= 1.645 local bFF99_`pnl'_5 = "`aux'*"
	else                  local bFF99_`pnl'_5 = "`aux'"
	local seFF99_`pnl'_5: di %12.3f _se[1.post#c.inten1999]
	local aux: di %12.3f _b[1.post#c.inten2005]
	local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
	if      `t' >= 2.576 local bFF05_`pnl'_5 = "`aux'***"
	else if `t' >= 1.96  local bFF05_`pnl'_5 = "`aux'**"
	else if `t' >= 1.645 local bFF05_`pnl'_5 = "`aux'*"
	else                  local bFF05_`pnl'_5 = "`aux'"
	local seFF05_`pnl'_5: di %12.3f _se[1.post#c.inten2005]
	sum `loutcome' if e(sample) & post == 2
	local meanFF_`pnl'_5: di %12.2fc `r(mean)'
	local NFF_`pnl'_5:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunFF_`pnl'_5: di %12.0fc `r(ndistinct)'
	* col 6: Poisson, weighted
	ppmlhdfe `doutcome' c.inten1999#i.post c.inten2005#i.post ///
		[pw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) offset(`offset') vce(cluster cve_ent_mun_super)
	local aux: di %12.3f exp(_b[1.post#c.inten1999])-1
	*local Poi1 : di %12.4f exp(_b[Post70ymas])-1
	local seFF99_`pnl'_6 : di %12.3f exp(_b[1.post#c.inten1999])*_se[1.post#c.inten1999]
	local t = abs(`aux' / `seFF99_`pnl'_6')
	if      `t' >= 2.576 local bFF99_`pnl'_6 = "`aux'***"
	else if `t' >= 1.96  local bFF99_`pnl'_6 = "`aux'**"
	else if `t' >= 1.645 local bFF99_`pnl'_6 = "`aux'*"
	else                  local bFF99_`pnl'_6 = "`aux'"
	
	local seFF05_`pnl'_6: di %12.3f exp(_b[1.post#c.inten2005])*_se[1.post#c.inten2005]
	local aux: di %12.3f exp(_b[1.post#c.inten2005])-1
	local t = abs(`aux' / `seFF05_`pnl'_6')
	if      `t' >= 2.576 local bFF05_`pnl'_6 = "`aux'***"
	else if `t' >= 1.96  local bFF05_`pnl'_6 = "`aux'**"
	else if `t' >= 1.645 local bFF05_`pnl'_6 = "`aux'*"
	else                  local bFF05_`pnl'_6 = "`aux'"
	
	sum `doutcome' if e(sample) & post == 2
	local meanFF_`pnl'_6: di %12.2fc `r(mean)'
	local NFF_`pnl'_6:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunFF_`pnl'_6: di %12.0fc `r(ndistinct)'
}

{
	cap file close sm
	file open sm using "$tables/appendix/AT2_functional_forms.tex", write replace
	file write sm "\begin{tabular}{lccc} \hline \hline" _n
	file write sm "& Levels & Log & Poisson \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\ \toprule" _n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `bFF99_p_4' & `bFF99_p_5' & `bFF99_p_6' \\ " _n
	file write sm "  & (`seFF99_p_4') & (`seFF99_p_5') & (`seFF99_p_6') \\ " _n
	file write sm "   & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `bFF05_p_4' & `bFF05_p_5' & `bFF05_p_6' \\ " _n
	file write sm " & (`seFF05_p_4') & (`seFF05_p_5') & (`seFF05_p_6') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean (1991-1996)  & `meanFF_p_4' & `meanFF_p_5' & `meanFF_p_6' \\ " _n
	
	file write sm "  & & &  \\ " _n
	file write sm "\underline{\textit{Panel B: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `bFF99_m_4' & `bFF99_m_5' & `bFF99_m_6' \\ " _n
	file write sm "  & (`seFF99_m_4') & (`seFF99_m_5') & (`seFF99_m_6') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} `bFF05_m_3' & `bFF05_m_4' & `bFF05_m_5' & `bFF05_m_6' \\ " _n
	file write sm " & (`seFF05_m_4') & (`seFF05_m_5') & (`seFF05_m_6') \\ " _n
	file write sm " & & & \\ " _n
	file write sm "Mean (1991-1996) & `meanFF_m_4' & `meanFF_m_5' & `meanFF_m_6' \\ " _n
	
	file write sm "  & & &  \\ " _n
	file write sm "\underline{\textit{Panel C: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)}  & `bFF99_f_4' & `bFF99_f_5' & `bFF99_f_6' \\ " _n
	file write sm "  & (`seFF99_f_4') & (`seFF99_f_5') & (`seFF99_f_6') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `bFF05_f_4' & `bFF05_f_5' & `bFF05_f_6' \\ " _n
	file write sm " & (`seFF05_f_4') & (`seFF05_f_5') & (`seFF05_f_6') \\ " _n
	file write sm "   & & & \\ " _n
	file write sm "Mean (1991-1996)  & `meanFF_f_4' & `meanFF_f_5' & `meanFF_f_6' \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Obs & `NFF_f_4' & `NFF_f_5' & `NFF_f_6' \\ " _n
	file write sm "No. Mun & `NmunFF_p_4' & `NmunFF_p_5' & `NmunFF_p_6' \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Year FE & Y & Y & Y \\ " _n
	file write sm "Mun FE  & Y & Y & Y \\ " _n
	file write sm "Weights & Y & Y & Y \\ " _n
	file write sm "Cluster SE: Mun & Y & Y & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
	
*============================================================
* APPENDIX TABLE 3: Main DiD Results — AAMR65 (1995 standard population)
*============================================================

foreach pnl in p m f {
	if "`pnl'" == "p" {
		local outcome aamr65
		local wvar   popover65_
	}
	else if "`pnl'" == "m" {
		local outcome aamr65m
		local wvar   popover65_m
	}
	else {
		local outcome aamr65f
		local wvar   popover65_f
	}
	forval col = 1/4 {
		if `col' == 1 {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post ///
				if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else if `col' == 2 {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else if `col' == 3 {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post ///
				[aw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else {
			reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				[aw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		local aux: di %12.3f _b[1.post#c.inten1999]
		local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
		if      `t' >= 2.576 local b99_`pnl'_`col' = "`aux'***"
		else if `t' >= 1.96  local b99_`pnl'_`col' = "`aux'**"
		else if `t' >= 1.645 local b99_`pnl'_`col' = "`aux'*"
		else                  local b99_`pnl'_`col' = "`aux'"
		local se99_`pnl'_`col': di %12.3f _se[1.post#c.inten1999]
		local aux: di %12.3f _b[1.post#c.inten2005]
		local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
		if      `t' >= 2.576 local b05_`pnl'_`col' = "`aux'***"
		else if `t' >= 1.96  local b05_`pnl'_`col' = "`aux'**"
		else if `t' >= 1.645 local b05_`pnl'_`col' = "`aux'*"
		else                  local b05_`pnl'_`col' = "`aux'"
		local se05_`pnl'_`col': di %12.3f _se[1.post#c.inten2005]
		sum `outcome' if e(sample) & post == 2
		local mean_`pnl'_`col': di %12.2fc `r(mean)'
		local N_`pnl'_`col':    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local Nmun_`pnl'_`col': di %12.0fc `r(ndistinct)'
	}
}

{
	cap file close sm
	file open sm using "$tables/appendix/AT3_aamr_mortality.tex", write replace
	file write sm "\begin{tabular}{lcccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_p_1' & `b99_p_2' & `b99_p_3' & `b99_p_4' \\ " _n
	file write sm " & (`se99_p_1') & (`se99_p_2') & (`se99_p_3') & (`se99_p_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_p_1' & `b05_p_2' & `b05_p_3' & `b05_p_4' \\ " _n
	file write sm " & (`se05_p_1') & (`se05_p_2') & (`se05_p_3') & (`se05_p_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_p_1' & `mean_p_2' & `mean_p_3' & `mean_p_4' \\ " _n
	file write sm "Obs & `N_p_1' & `N_p_2' & `N_p_3' & `N_p_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\underline{\textit{Panel B: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_m_1' & `b99_m_2' & `b99_m_3' & `b99_m_4' \\ " _n
	file write sm " & (`se99_m_1') & (`se99_m_2') & (`se99_m_3') & (`se99_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_m_1' & `b05_m_2' & `b05_m_3' & `b05_m_4' \\ " _n
	file write sm " & (`se05_m_1') & (`se05_m_2') & (`se05_m_3') & (`se05_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_m_1' & `mean_m_2' & `mean_m_3' & `mean_m_4' \\ " _n
	file write sm "Obs & `N_m_1' & `N_m_2' & `N_m_3' & `N_m_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\underline{\textit{Panel C: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_f_1' & `b99_f_2' & `b99_f_3' & `b99_f_4' \\ " _n
	file write sm " & (`se99_f_1') & (`se99_f_2') & (`se99_f_3') & (`se99_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_f_1' & `b05_f_2' & `b05_f_3' & `b05_f_4' \\ " _n
	file write sm " & (`se05_f_1') & (`se05_f_2') & (`se05_f_3') & (`se05_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_f_1' & `mean_f_2' & `mean_f_3' & `mean_f_4' \\ " _n
	file write sm "Obs & `N_f_1' & `N_f_2' & `N_f_3' & `N_f_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "No. Mun & `Nmun_p_1' & `Nmun_p_2' & `Nmun_p_3' & `Nmun_p_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Year FE & Y & Y & Y & Y \\ " _n
	file write sm "Mun FE & Y & Y & Y & Y \\ " _n
	file write sm "Seguro Popular & N & Y & N & Y \\ " _n
	file write sm "Weights & N & N & Y & Y \\ " _n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}


******************************************
*ADDITIONAL APPENDIX NEEDS TO EXPLORE MORE
******************************************

*what about the pre-trends of Barham and Roweberry?

*There is no direct testing because the intesnity/treatment changes over time. 
*Therefore, an adapated method would be considering early cumulative effects 
*and thus adapt their intensity time varying lagged 2 periods for the intensity 
*in 1999 interacted with time dummies.

*First we get the PostxIntensity 1999, getting a negative and significant of 3.9
 
**Event Study (This would be similar to F2) *Unweighted
*a
 reghdfe emr65 c.inten1999##ib6.year_1995 if inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
 		coefplot, drop (*.year_1995 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 	

**b)  Event Study weighted 
 reghdfe emr65 c.inten1999##ib6.year_1995 [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
  		coefplot, drop (*.year_1995 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 
		
**c) Event Study weighted + cp_intensity
 reghdfe emr65 c.inten1999##ib6.year_1995 c.sp_intensity [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
  		coefplot, drop (*.year_1995 _cons inten1999 sp_intensity) omitted base vertical    ///
		coeflabels(, interaction("") wrap(6)) yline(0, lpattern(dash)) xline(6) graphregion (fcolor(white))  ///
		xtitle("Coefficients=Years x Progresa intensity in 1999") ytitle("Adult mortality +65") ///
		  ciopts(lwidth(1.15) lcolor(*.5)) ///
		  yscale(range(-10, 20)) ylabel(-10(10)20,labsize(small)) xlabel(,labsize(small)) 
 
 *IT NEEDS TO GO FOR 99 TO 2002 INTENSISTY
 *However, this strategy requires that in the absence of roll-out, cross- cohort 
 *trends would be parallel in municipalities more and less intensively treated at 
 *the start of the programme. Because initial po v erty predicts enrolment intensity, 
 *this assumption would be violated if, for example, initially poor municipalities 
 *tended to converge toward less poor municipalities across successive cohorts.

 *Adapting BR 2013 to P&V 2023
* As such, we modify the standard specification to ask whether, among municipalities
* with the same cumulative enrolment intensity at the end of the Fox administration 
* (2005), those that saw more intensity during the Zedillo administration (1997–9)
* experienced larger gains in early beneficiary cohorts. Thus, the spatial 
*component of our design focuses on an early-versus-late comparison, rather than everer versus-never.

*Adapting BR to PV does not make much sense because the post period is already 2002. 
*and it looks for short term effects only. if we care about pre-trends, previous
*exercise should be enough
 
*********************************************
 *what if we instead we do BR in our sample
 *********************************************
 *Maybe I can create a Table here: Ask claude for it. based on columns
 *maybe a plot of the different coefficients. 
 
*BR but now only for highly marginalized (significant)
reghdfe emr65 lag2_intensity_new if ///
 inrange(year, 1992, 2002) & $sample_br & $sample_marg, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)

reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
 inrange(year, 1992, 2002) & $sample_br & $sample_marg, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)
   
 *BR but for the same time span as us: 1992-2006 (significant), still valid for short-term
reghdfe emr65 lag2_intensity_new if ///
inrange(year, 1992, 2006) & $sample_br , a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)

*BR but for the same time span as us and with weights (no significant)
reghdfe emr65 lag2_intensity_new [aw=popover65_] if ///
inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super)  vce(cluster cve_ent_mun_super)

	twoway ///
		(rcap hi_w lo_w xpos_w, ///
			lcolor(black%60) lwidth(vthin)) ///
		(connected b_w xpos_w, ///
			mcolor(black) lcolor(black) ///
			msymbol(circle) msize(vsmall) lwidth(thin) lpattern(solid)) ///
		(rcap hi_f lo_f xpos_f, ///
			lcolor(red%60) lwidth(vthin)) ///
		(connected b_f xpos_f, ///
			mcolor(red) lcolor(red) ///
			msymbol(square) msize(vsmall) lwidth(thin) lpattern(dash)) ///
		(rcap hi_m lo_m xpos_m, ///
			lcolor(blue%60) lwidth(vthin)) ///
		(connected b_m xpos_m, ///
			mcolor(blue%80) lcolor(blue%80) ///
			msymbol(triangle) msize(vsmall) lwidth(thin) lpattern(shortdash_dot)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("AAMR 65+ (per 1,000)", size(medsmall)) ///
		yscale(noline) ylabel(, grid gmin gmax labsize(small)) ///
			legend(order(2 "Pooled" 4 "Female" 6 "Male") ///
			cols(3) size(medsmall) position(6) ring(1) ///
			region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))

reghdfe emr65 c.inten1999#i.post c.inten2002#i.post [aw=popover65_] if ///
inrange(year, 1992, 2006) & $sample_br, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)


} // end forval col

*============================================================
* APPENDIX TABLE: Causes of Death (Weighted + SP spec)
* FAT_cod_mortality.tex
*============================================================
foreach cod in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {
	reghdfe emr65`cod' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
		[aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) ///
		vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local b99_`cod' = "`aux'***"
	else if `t' >= 1.96  local b99_`cod' = "`aux'**"
	else if `t' >= 1.645 local b99_`cod' = "`aux'*"
	else                  local b99_`cod' = "`aux'"
	local se99_`cod': di %12.3f _se[1.post#c.inten1999]
	local aux: di %12.3f _b[1.post#c.inten2005]
	local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
	if      `t' >= 2.576 local b05_`cod' = "`aux'***"
	else if `t' >= 1.96  local b05_`cod' = "`aux'**"
	else if `t' >= 1.645 local b05_`cod' = "`aux'*"
	else                  local b05_`cod' = "`aux'"
	local se05_`cod': di %12.3f _se[1.post#c.inten2005]
	sum emr65`cod' if e(sample) & post == 2
	local mean_`cod': di %12.2fc `r(mean)'
	local N_`cod': di %12.0fc `e(N)'
}

{
	cap file close sm
	file open sm using "$tables/FAT_cod_mortality.tex", write replace
	file write sm "\begin{tabular}{lcccccccccc} \hline \hline" _n
	file write sm "& Card. & Infect. & Diab. & Resp. & Nutri. & Cancer & Accid. & IllDef & Other \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}\cmidrule(lr){10-10}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} & \multicolumn{1}{c}{(9)} \\ \toprule" _n
	file write sm "\textit{Intensity 1999 x post} & `b99_tb_card' & `b99_tb_infect' & `b99_tb_diab' & `b99_tb_resp' & `b99_tb_nutri' & `b99_tb_cancer' & `b99_tb_accid' & `b99_tb_illdef' & `b99_tb_other' \\ " _n
	file write sm " & (`se99_tb_card') & (`se99_tb_infect') & (`se99_tb_diab') & (`se99_tb_resp') & (`se99_tb_nutri') & (`se99_tb_cancer') & (`se99_tb_accid') & (`se99_tb_illdef') & (`se99_tb_other') \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post} & `b05_tb_card' & `b05_tb_infect' & `b05_tb_diab' & `b05_tb_resp' & `b05_tb_nutri' & `b05_tb_cancer' & `b05_tb_accid' & `b05_tb_illdef' & `b05_tb_other' \\ " _n
	file write sm " & (`se05_tb_card') & (`se05_tb_infect') & (`se05_tb_diab') & (`se05_tb_resp') & (`se05_tb_nutri') & (`se05_tb_cancer') & (`se05_tb_accid') & (`se05_tb_illdef') & (`se05_tb_other') \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_tb_card' & `mean_tb_infect' & `mean_tb_diab' & `mean_tb_resp' & `mean_tb_nutri' & `mean_tb_cancer' & `mean_tb_accid' & `mean_tb_illdef' & `mean_tb_other' \\ " _n
	file write sm "Obs & `N_tb_card' & `N_tb_infect' & `N_tb_diab' & `N_tb_resp' & `N_tb_nutri' & `N_tb_cancer' & `N_tb_accid' & `N_tb_illdef' & `N_tb_other' \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "Year FE & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "Mun FE & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "Seguro Popular & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "Weights & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "Cluster SE: Mun & Y & Y & Y & Y & Y & Y & Y & Y & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}

*============================================================
* APPENDIX FIGURES: Event Study by Cause of Death
* FA_es_cod_tb_XXX.pdf -- pooled, weighted + SP spec
*============================================================
local yr_labels_cod `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

foreach cod in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {

	reghdfe emr65`cod' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
		c.sp_intensity [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) ///
		vce(cluster cve_ent_mun_super)

	forval pos = 1/16 {
		if `pos' == 6 {
			local b_cod_6  = 0
			local se_cod_6 = 0
		}
		else {
			local b_cod_`pos'  = _b[`pos'.year_1995#c.inten1999]
			local se_cod_`pos' = _se[`pos'.year_1995#c.inten1999]
		}
	}

	preserve
	clear
	set obs 16
	gen yr_pos = _n
	gen xpos_cod = yr_pos
	gen b_cod  = .
	gen hi_cod = .
	gen lo_cod = .
	forval pos = 1/16 {
		replace b_cod  = `b_cod_`pos''                             if yr_pos == `pos'
		replace hi_cod = `b_cod_`pos'' + 1.96 * `se_cod_`pos'' if yr_pos == `pos'
		replace lo_cod = `b_cod_`pos'' - 1.96 * `se_cod_`pos'' if yr_pos == `pos'
	}
	twoway ///
		(rcap hi_cod lo_cod xpos_cod, ///
			lcolor(black%60) lwidth(vthin)) ///
		(connected b_cod xpos_cod, ///
			mcolor(black) lcolor(black) ///
			msymbol(circle) msize(vsmall) lwidth(thin) lpattern(solid)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels_cod', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("EMR 65+ (per 1,000): `cod'", size(medsmall)) ///
		yscale(noline) ylabel(, grid gmin gmax labsize(small)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))
	graph export "$figures/FA_es_cod_`cod'.pdf", as(pdf) replace
	restore

} // end foreach cod
