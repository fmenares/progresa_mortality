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

 if c(username)=="root" {
	global data "/home/user/progresa_mortality/data/"
	global tables "/home/user/progresa_mortality/tables"
	global figures "/home/user/progresa_mortality/figures"
	global deaths "/home/user/progresa_mortality/data/"
	global iter "/home/user/progresa_mortality/data/"
	global SP "/home/user/progresa_mortality/data/"
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

*============================================================
* TABLE 1: Descriptives
* T1_descriptives_b.tex
* Panel A: Progresa enrollment intensity (inten1999, inten2005)
* Panel B: Socioeconomic characteristics — pulled at year==1990
*   (actual census values, not interpolated midpoints)
* Columns: (1) Marginalized (gm_mun_1990=4|5), (2) Non-Marginalized
*============================================================

preserve
keep if year == 1990   // 1990 census cross-section; inten1999/2005 are cross-sectional constants

* Panel A: intensity measures (multiply by 100 to display as %)
foreach var in inten1999 inten2005 {
	sum `var' if gm_mun_1990==4 | gm_mun_1990==5
	local m_`var'_hm:  di %6.1f `r(mean)' * 100
	local sd_`var'_hm: di %6.1f `r(sd)'   * 100
	sum `var' if gm_mun_1990 != 4 & gm_mun_1990 != 5 & gm_mun_1990 != .
	local m_`var'_nm:  di %6.1f `r(mean)' * 100
	local sd_`var'_nm: di %6.1f `r(sd)'   * 100
}

* Panel B: socioeconomic characteristics (1990 census values)
foreach var in analf sprim ovsee ovsae vhac ovpt ovsde pl5000 po2sm {
	sum `var' if gm_mun_1990==4 | gm_mun_1990==5
	local m_`var'_hm:  di %6.1f `r(mean)'
	local sd_`var'_hm: di %6.1f `r(sd)'
	sum `var' if gm_mun_1990 != 4 & gm_mun_1990 != 5 & gm_mun_1990 != .
	local m_`var'_nm:  di %6.1f `r(mean)'
	local sd_`var'_nm: di %6.1f `r(sd)'
}

count if gm_mun_1990==4 | gm_mun_1990==5
local N_hm = r(N)
count if gm_mun_1990 != 4 & gm_mun_1990 != 5 & gm_mun_1990 != .
local N_nm = r(N)

{
	cap file close sm
	file open sm using "$tables/T1_descriptives_b.tex", write replace
	file write sm "\begin{tabular}{lcc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{Marginalized} & \multicolumn{1}{c}{Non-Marginalized} \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} \\ \toprule" _n
	file write sm "\underline{\textit{Panel A: Progresa Enrollment Intensity (\%)}} \\ " _n
	file write sm "Intensity in 1999 & `m_inten1999_hm' & `m_inten1999_nm' \\ " _n
	file write sm "  & (`sd_inten1999_hm') & (`sd_inten1999_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "Intensity in 2005 & `m_inten2005_hm' & `m_inten2005_nm' \\ " _n
	file write sm "  & (`sd_inten2005_hm') & (`sd_inten2005_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\underline{\textit{Panel B: Socioeconomic Characteristics (\%)}} \\ " _n
	file write sm "\% illiterate & `m_analf_hm' & `m_analf_nm' \\ " _n
	file write sm "  & (`sd_analf_hm') & (`sd_analf_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\% without completed primary & `m_sprim_hm' & `m_sprim_nm' \\ " _n
	file write sm "  & (`sd_sprim_hm') & (`sd_sprim_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\% without electricity & `m_ovsee_hm' & `m_ovsee_nm' \\ " _n
	file write sm "  & (`sd_ovsee_hm') & (`sd_ovsee_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\% without piped water & `m_ovsae_hm' & `m_ovsae_nm' \\ " _n
	file write sm "  & (`sd_ovsae_hm') & (`sd_ovsae_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "With crowding & `m_vhac_hm' & `m_vhac_nm' \\ " _n
	file write sm "  & (`sd_vhac_hm') & (`sd_vhac_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\% with dirt floors & `m_ovpt_hm' & `m_ovpt_nm' \\ " _n
	file write sm "  & (`sd_ovpt_hm') & (`sd_ovpt_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\% without drainage & `m_ovsde_hm' & `m_ovsde_nm' \\ " _n
	file write sm "  & (`sd_ovsde_hm') & (`sd_ovsde_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\% in localities \$<\$5,000 & `m_pl5000_hm' & `m_pl5000_nm' \\ " _n
	file write sm "  & (`sd_pl5000_hm') & (`sd_pl5000_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\% in 2+ person households & `m_po2sm_hm' & `m_po2sm_nm' \\ " _n
	file write sm "  & (`sd_po2sm_hm') & (`sd_po2sm_nm') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "Municipalities & `N_hm' & `N_nm' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
restore

*	Restriction (year)
	keep if year >1990 & year <2007

	
	tab post 
	global sample_marg = "gm_mun_1990==4|gm_mun_1990==5"
	global sample_br   = "(inten_start_year==1998|inten_start_year==1999)"
	
	
	
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
graph export "$figures/Figure_1b_inten1999.png", as(png) replace width(1200)

* ---- Map 2: Mortality sample — intensity 2005 ----
spmap inten2005 using "${shp}\municipios_2000_shp.dta", id(_ID) ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/Figure_1c_inten2005.png", as(png) replace width(1200)

 *---- Map 5: Initial rollout 1997 — mortality sample ----
spmap inten1997 using "${shp}\municipios_2000_shp.dta", id(_ID) ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_2c_inten1997_mort.png", as(png) replace width(1200)


restore

}


*============================================================
*Figure 2: Weighted + Seguro Popular — manual event study (pooled / female / male)
*============================================================

{ 
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
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
			local b_`grp'_6    = 0
			local se_`grp'_6   = 0
			local th_`grp'_6   = 0
			local seth_`grp'_6 = 0
		}
		else {
			local b_`grp'_`pos'    = _b[`pos'.year_1995#c.inten1999]
			local se_`grp'_`pos'   = _se[`pos'.year_1995#c.inten1999]
			local th_`grp'_`pos'   = _b[`pos'.year_1995#c.inten2005]
			local seth_`grp'_`pos' = _se[`pos'.year_1995#c.inten2005]
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
	(scatter b_w xpos_w, ///
		mcolor(black) msymbol(circle) msize(vsmall)) ///
	(rcap hi_f lo_f xpos_f, ///
		lcolor(red%60) lwidth(vthin)) ///
	(scatter b_f xpos_f, ///
		mcolor(red) msymbol(square) msize(vsmall)) ///
	(rcap hi_m lo_m xpos_m, ///
		lcolor(blue%60) lwidth(vthin)) ///
	(scatter b_m xpos_m, ///
		mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
	(line b_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin) msymbol(circle) mcolor(black) msize(vsmall)) ///
	(line b_f xpos_f if 1==0, lcolor(red) lpattern(dash) lwidth(thin) msymbol(square) mcolor(red) msize(vsmall)) ///
	(line b_m xpos_m if 1==0, lcolor(blue%80) lpattern(shortdash_dot) lwidth(thin) msymbol(triangle) mcolor(blue%80) msize(vsmall)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(7 "Pooled" 8 "Female" 9 "Male") ///
		cols(3) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/Figure_2_w.pdf", as(pdf) replace
restore

}

*============================================================
* APPENDIX FIGURE: AF_beta1_sex
* Event study for theta_k (Intensity_2005 x year) — weighted + SP
* Pooled / Female / Male — mirrors Figure 2 structure
* Output: $figures/appendix/AF_beta1_sex.pdf
*============================================================

{
preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_w = yr_pos - 0.18
gen xpos_f = yr_pos
gen xpos_m = yr_pos + 0.18
foreach grp in w f m {
	gen th_`grp'  = .
	gen thi_`grp' = .
	gen tlo_`grp' = .
}
forval pos = 1/16 {
	foreach grp in w f m {
		replace th_`grp'  = `th_`grp'_`pos''                              if yr_pos == `pos'
		replace thi_`grp' = `th_`grp'_`pos'' + 1.96 * `seth_`grp'_`pos'' if yr_pos == `pos'
		replace tlo_`grp' = `th_`grp'_`pos'' - 1.96 * `seth_`grp'_`pos'' if yr_pos == `pos'
	}
}
twoway ///
	(rcap thi_w tlo_w xpos_w, ///
		lcolor(black%60) lwidth(vthin)) ///
	(scatter th_w xpos_w, ///
		mcolor(black) msymbol(circle) msize(vsmall)) ///
	(rcap thi_f tlo_f xpos_f, ///
		lcolor(red%60) lwidth(vthin)) ///
	(scatter th_f xpos_f, ///
		mcolor(red) msymbol(square) msize(vsmall)) ///
	(rcap thi_m tlo_m xpos_m, ///
		lcolor(blue%60) lwidth(vthin)) ///
	(scatter th_m xpos_m, ///
		mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
	(line th_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin) msymbol(circle) mcolor(black) msize(vsmall)) ///
	(line th_f xpos_f if 1==0, lcolor(red) lpattern(dash) lwidth(thin) msymbol(square) mcolor(red) msize(vsmall)) ///
	(line th_m xpos_m if 1==0, lcolor(blue%80) lpattern(shortdash_dot) lwidth(thin) msymbol(triangle) mcolor(blue%80) msize(vsmall)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(7 "Pooled" 8 "Female" 9 "Male") ///
		cols(3) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/appendix/AF_beta1_sex.pdf", as(pdf) replace
restore
}

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

* Mean Intensity 1999 for T2 — HM sample, displayed as %
quietly sum inten1999 if $sample_marg & year == 1996
local meanI99_T2: di %6.1f r(mean) * 100

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
	file write sm "\underline{\textit{Panel B: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_f_1' & `b99_f_2' & `b99_f_3' & `b99_f_4' \\ " _n
	file write sm " & (`se99_f_1') & (`se99_f_2') & (`se99_f_3') & (`se99_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_f_1' & `b05_f_2' & `b05_f_3' & `b05_f_4' \\ " _n
	file write sm " & (`se05_f_1') & (`se05_f_2') & (`se05_f_3') & (`se05_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_f_1' & `mean_f_2' & `mean_f_3' & `mean_f_4' \\ " _n
	file write sm "Obs & `N_f_1' & `N_f_2' & `N_f_3' & `N_f_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\underline{\textit{Panel C: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_m_1' & `b99_m_2' & `b99_m_3' & `b99_m_4' \\ " _n
	file write sm " & (`se99_m_1') & (`se99_m_2') & (`se99_m_3') & (`se99_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_m_1' & `b05_m_2' & `b05_m_3' & `b05_m_4' \\ " _n
	file write sm " & (`se05_m_1') & (`se05_m_2') & (`se05_m_3') & (`se05_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_m_1' & `mean_m_2' & `mean_m_3' & `mean_m_4' \\ " _n
	file write sm "Obs & `N_m_1' & `N_m_2' & `N_m_3' & `N_m_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "No. Mun & `Nmun_p_1' & `Nmun_p_2' & `Nmun_p_3' & `Nmun_p_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Seguro Popular & N & Y & N & Y \\ " _n
	file write sm "Weights & N & N & Y & Y \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_T2' & `meanI99_T2' & `meanI99_T2' & `meanI99_T2' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}


*============================================================
* APPENDIX FIGURES: 
*============================================================


*============================================================
* FIGURE 1 (Appendix): Elder Mortality Trends — Highly Marginalized
*   vs Non-Marginalized Municipalities
*============================================================

{
* Collapse marginalized into tempfile
tempfile marg_trend
preserve
keep if $sample_marg
collapse (mean) emr65_marg=emr65 emr65m_marg=emr65m emr65f_marg=emr65f ///
	[aw=popover65_], by(year)
save `marg_trend'
restore

* Collapse non-marginalized, merge, and plot
preserve
keep if !(gm_mun_1990==4 | gm_mun_1990==5)
drop if gm_mun_1990==.
collapse (mean) emr65_nm=emr65 emr65m_nm=emr65m emr65f_nm=emr65f ///
	[aw=popover65_], by(year)

merge 1:1 year using `marg_trend', nogen

twoway (line emr65_marg  year, lcolor(navy)   lpattern(solid)) ///
       (line emr65m_marg year, lcolor(navy)   lpattern(dash)) ///
       (line emr65f_marg year, lcolor(navy)   lpattern(dot)) ///
       (line emr65_nm    year, lcolor(maroon) lpattern(solid)) ///
       (line emr65m_nm   year, lcolor(maroon) lpattern(dash)) ///
       (line emr65f_nm   year, lcolor(maroon) lpattern(dot)), ///
	ytitle("Mortality Rate (65+ per 1,000)") ///
	xtitle("Year") xline(1997, lpattern(dash) lcolor(gs10)) ///
	legend(order(1 "Marg: All" 2 "Marg: Male" 3 "Marg: Female" ///
	             4 "Non-Marg: All" 5 "Non-Marg: Male" 6 "Non-Marg: Female") ///
	cols(3) size(medsmall) position(6) ring(1)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_1_all.pdf", as(pdf) replace
restore
}
*============================================================
* FIGURE 2: Mexican municipality maps — PROGRESA intensity variation *All Municipalities
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

* Save intensity values to tempfile (keep before use clears memory)
keep cve_ent_mun_super inten1997 inten1998 inten1999 inten2000 inten2005
duplicates drop cve_ent_mun_super, force
tempfile inten_data_all
save `inten_data_all'

* Load shapefile attribute file and merge intensity
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
graph export "$figures/appendix/Figure_2a_inten1999_all.png", as(png) replace width(1200)

* ---- Map 2: Mortality sample — intensity 2005 ----
spmap inten2005 using "${shp}\municipios_2000_shp.dta", id(_ID)  ///
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_2b_inten2005_all.png", as(png) replace width(1200)

* ---- Map 5: Initial rollout 1997 — mortality sample (all municipalities) ----
spmap inten1997 using "${shp}\municipios_2000_shp.dta", id(_ID) /// 
	clmethod(custom) clbreaks(`breaks1999') ///
	fcolor(Blues2) ocolor(none ..) osize(vvthin ..) ///
	legend(size(medium) position(7)) ///
	graphregion(fcolor(white))
graph export "$figures/appendix/Figure_2d_inten1997_mort_all.png", as(png) replace width(1200)



restore

}

*============================================================
* APPENDIX FIGURE 3-4: Event Study by Cause of Death (Our Sample, 1991-2006)
* Figure_5_XXX_Marg.pdf — y-axis -9(3)9 for tb_card, -6(3)6 otherwise
*============================================================

{
local yr_labels_cod `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
local samp_cond  "$sample_marg"
local samp_yr_cond ""
local obs_n = 16
local yr_pos_offset = 0
local xscale_range "range(0.5 16.5)"
local pos_start = 1
local pos_end   = 16

foreach cod in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {

	foreach grp in w f m {
		local reg_success_`grp' = 0
		if "`grp'" == "w" {
			local outcome emr65`cod'
			local wvar   popover65_
		}
		else if "`grp'" == "f" {
			local outcome emr65`cod'f
			local wvar   popover65_f
		}
		else {
			local outcome emr65`cod'm
			local wvar   popover65_m
		}
		capture noisily reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
			c.sp_intensity [aw=`wvar'] if `samp_cond', ///
			a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		if _rc == 0 {
			local reg_success_`grp' = 1
			forval pos = `pos_start'/`pos_end' {
				if `pos' == 6 {
					local b_`grp'_`pos'  = 0
					local se_`grp'_`pos' = 0
				}
				else {
					local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999]
					local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999]
				}
			}
		}
		else {
			di "WARNING: Regression failed for `outcome' (`cod', Marg sample) - skipping"
			forval pos = `pos_start'/`pos_end' {
				local b_`grp'_`pos'  = .
				local se_`grp'_`pos' = .
			}
		}
	}

	preserve
	clear
	set obs `obs_n'
	gen yr_pos = _n + `yr_pos_offset'
	gen xpos_w = yr_pos - 0.18
	gen xpos_f = yr_pos
	gen xpos_m = yr_pos + 0.18
	foreach grp in w f m {
		gen b_`grp'  = .
		gen hi_`grp' = .
		gen lo_`grp' = .
	}
	forval pos = `pos_start'/`pos_end' {
		foreach grp in w f m {
			if `reg_success_`grp'' == 1 {
				replace b_`grp'  = `b_`grp'_`pos''                            if yr_pos == `pos'
				replace hi_`grp' = `b_`grp'_`pos'' + 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
				replace lo_`grp' = `b_`grp'_`pos'' - 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
			}
		}
	}

	if inlist("`cod'", "tb_cancer", "tb_diab", "tb_illdef", "tb_infect") {
		local yaxis_range "-6(3)3"
	}
	else if "`cod'" == "tb_card" {
		local yaxis_range "-9(3)9"
	}
	else {
		local yaxis_range "-6(3)6"
	}

	local twoway_cmd "twoway"
	local legend_nums ""
	local legend_labels ""
	local plot_count = 0
	if `reg_success_w' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_w lo_w xpos_w, lcolor(black%60) lwidth(vthin)) (scatter b_w xpos_w, mcolor(black) msymbol(circle) msize(vsmall)) (line b_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Pooled)"
	}
	if `reg_success_f' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_f lo_f xpos_f, lcolor(red%60) lwidth(vthin)) (scatter b_f xpos_f, mcolor(red%60) msymbol(square) msize(vsmall)) (line b_f xpos_f if 1==0, lcolor(red%60) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Female)"
	}
	if `reg_success_m' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_m lo_m xpos_m, lcolor(blue%60) lwidth(vthin)) (scatter b_m xpos_m, mcolor(blue%60) msymbol(triangle) msize(vsmall)) (line b_m xpos_m if 1==0, lcolor(blue%60) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Male)"
	}
	local twoway_cmd "`twoway_cmd', yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) xlabel(`yr_labels_cod', labsize(small) angle(45) labcolor(black)) xscale(`xscale_range') xtitle("") ytitle("Mortality Rate, 65+ (per 1,000): `cod'", size(medsmall)) ylabel(`yaxis_range', grid gmin gmax labsize(small)) legend(order(`legend_nums') `legend_labels' cols(3) size(medsmall) position(6) ring(1) region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) graphregion(color(white)) plotregion(margin(l=1 r=1))"
	`twoway_cmd'
	graph export "$figures/appendix/Figure_3_`cod'_Marg.pdf", as(pdf) replace
	restore

} // end foreach cod
} // end Marg block



*============================================================
* APPENDIX FIGURE 5:
*============================================================

*============================================================
*Appendix Figure 5a: Unweighted + Seguro Popular — manual event study (pooled / female / male)
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
			local b_`grp'_6     = 0
			local se_`grp'_6    = 0
			local thuw_`grp'_6   = 0
			local sethuw_`grp'_6 = 0
		}
		else {
			local b_`grp'_`pos'     = _b[`pos'.year_1995#c.inten1999]
			local se_`grp'_`pos'    = _se[`pos'.year_1995#c.inten1999]
			local thuw_`grp'_`pos'   = _b[`pos'.year_1995#c.inten2005]
			local sethuw_`grp'_`pos' = _se[`pos'.year_1995#c.inten2005]
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
	(scatter b_w xpos_w, ///
		mcolor(black) msymbol(circle) msize(vsmall)) ///
	(rcap hi_f lo_f xpos_f, ///
		lcolor(red%60) lwidth(vthin)) ///
	(scatter b_f xpos_f, ///
		mcolor(red) msymbol(square) msize(vsmall)) ///
	(rcap hi_m lo_m xpos_m, ///
		lcolor(blue%60) lwidth(vthin)) ///
	(scatter b_m xpos_m, ///
		mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
	(line b_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin) msymbol(circle) mcolor(black) msize(vsmall)) ///
	(line b_f xpos_f if 1==0, lcolor(red) lpattern(dash) lwidth(thin) msymbol(square) mcolor(red) msize(vsmall)) ///
	(line b_m xpos_m if 1==0, lcolor(blue%80) lpattern(shortdash_dot) lwidth(thin) msymbol(triangle) mcolor(blue%80) msize(vsmall)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(7 "Pooled" 8 "Female" 9 "Male") ///
		cols(3) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/appendix/Figure_5a_uw.pdf", as(pdf) replace
restore
}

*============================================================
* APPENDIX FIGURE: AF_beta1_wuw
* Event study for theta_k (Intensity_2005 x year) — Pooled only
* Weighted (black circles) vs. Unweighted (blue triangles)
* Output: $figures/appendix/AF_beta1_wuw.pdf
*============================================================

{
preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_wt = yr_pos - 0.18
gen xpos_uw = yr_pos + 0.18
foreach pfx in wt uw {
	gen th_`pfx'  = .
	gen thi_`pfx' = .
	gen tlo_`pfx' = .
}
forval pos = 1/16 {
	replace th_wt  = `th_w_`pos''                              if yr_pos == `pos'
	replace thi_wt = `th_w_`pos'' + 1.96 * `seth_w_`pos''     if yr_pos == `pos'
	replace tlo_wt = `th_w_`pos'' - 1.96 * `seth_w_`pos''     if yr_pos == `pos'
	replace th_uw  = `thuw_w_`pos''                            if yr_pos == `pos'
	replace thi_uw = `thuw_w_`pos'' + 1.96 * `sethuw_w_`pos'' if yr_pos == `pos'
	replace tlo_uw = `thuw_w_`pos'' - 1.96 * `sethuw_w_`pos'' if yr_pos == `pos'
}
twoway ///
	(rcap thi_wt tlo_wt xpos_wt, ///
		lcolor(black%60) lwidth(vthin)) ///
	(scatter th_wt xpos_wt, ///
		mcolor(black) msymbol(circle) msize(vsmall)) ///
	(rcap thi_uw tlo_uw xpos_uw, ///
		lcolor(blue%60) lwidth(vthin)) ///
	(scatter th_uw xpos_uw, ///
		mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
	(line th_wt xpos_wt if 1==0, lcolor(black) lpattern(solid) lwidth(thin) msymbol(circle) mcolor(black) msize(vsmall)) ///
	(line th_uw xpos_uw if 1==0, lcolor(blue%80) lpattern(dash) lwidth(thin) msymbol(triangle) mcolor(blue%80) msize(vsmall)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(5 "Weighted" 6 "Unweighted") ///
		cols(2) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/appendix/AF_beta1_wuw.pdf", as(pdf) replace
restore
}



*==========================================================
* APPENDIX FIGURE 5b: Event Study — AAMR65 (1995 standard population)
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
		(scatter b_w xpos_w, ///
			mcolor(black) msymbol(circle) msize(vsmall)) ///
		(rcap hi_f lo_f xpos_f, ///
			lcolor(red%60) lwidth(vthin)) ///
		(scatter b_f xpos_f, ///
			mcolor(red) msymbol(square) msize(vsmall)) ///
		(rcap hi_m lo_m xpos_m, ///
			lcolor(blue%60) lwidth(vthin)) ///
		(scatter b_m xpos_m, ///
			mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
		(line b_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin) msymbol(circle) mcolor(black) msize(vsmall)) ///
		(line b_f xpos_f if 1==0, lcolor(red) lpattern(dash) lwidth(thin) msymbol(square) mcolor(red) msize(vsmall)) ///
		(line b_m xpos_m if 1==0, lcolor(blue%80) lpattern(shortdash_dot) lwidth(thin) msymbol(triangle) mcolor(blue%80) msize(vsmall)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("AAMR 65+ (per 1,000)", size(medsmall)) ///
		ylabel(, grid gmin gmax labsize(small)) ///
			legend(order(7 "Pooled" 8 "Female" 9 "Male") ///
			cols(3) size(medsmall) position(6) ring(1) ///
			region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))

	graph export "$figures/appendix/Figure_5_aamr_col`col'.pdf", as(pdf) replace
	restore
} // end forval col = 1/4

*First we get the PostxIntensity 1999, getting a negative and significant of 3.9

 
**Event Study (This would be similar to F2) *Unweighted


*============================================================
* APPENDIX FIGURE 7: Event Study by Functional Form
* Three PDFs — one per functional form (Levels / Log / Poisson).
* Each plot overlays Pooled, Female, and Male point estimates + 95% CIs.
* Specification mirrors AT_functional_forms: weighted + Seguro Popular control.
* Sample: highly marginalized municipalities (gm_mun_1990 == 4 | 5).
* Reference year: 1996 (position 6 in year_1995 coding).
* Output:
*   Figure_7_ES_func_form_levels.pdf   — mortality rate in levels (per 1,000)
*   Figure_7_ES_func_form_log.pdf      — log(mortality rate); zeros dropped
*   Figure_7_ES_func_form_poisson.pdf  — death counts, ppmlhdfe, exp(b)-1
*============================================================

{
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

* Log variables and offsets (already generated for AT3; capture avoids duplicate-variable error)
capture g lemr65       = log(emr65)
capture g lemr65m      = log(emr65m)
capture g lemr65f      = log(emr65f)
capture g lpopover65   = log(popover65_)
capture g lpopover65_m = log(popover65_m)
capture g lpopover65_f = log(popover65_f)

foreach ff in levels log poisson {

	*--- Labels and filenames ---
	if "`ff'" == "levels" {
		local ytitle_ff "Mortality Rate, 65+ (per 1,000)"
		local figname   "Figure_7_ES_func_form_levels"
	}
	else if "`ff'" == "log" {
		local ytitle_ff "% Change in Mortality Rate, 65+"
		local figname   "Figure_7_ES_func_form_log"
	}
	else {
		local ytitle_ff "Relative Change in Deaths (%)"
		local figname   "Figure_7_ES_func_form_poisson"
	}

	*--- Regressions: one per sex group ---
	foreach grp in w f m {

		if "`grp'" == "w" {
			local outcome_lvl emr65
			local outcome_log lemr65
			local outcome_poi death65
			local offset_poi  lpopover65
			local wvar        popover65_
		}
		else if "`grp'" == "f" {
			local outcome_lvl emr65f
			local outcome_log lemr65f
			local outcome_poi death65f
			local offset_poi  lpopover65_f
			local wvar        popover65_f
		}
		else {
			local outcome_lvl emr65m
			local outcome_log lemr65m
			local outcome_poi death65m
			local offset_poi  lpopover65_m
			local wvar        popover65_m
		}

		if "`ff'" == "levels" {
			reghdfe `outcome_lvl' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
				c.sp_intensity [pw=`wvar'] if $sample_marg, ///
				a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
			forval pos = 1/16 {
				if `pos' == 6 {
					local b_`grp'_`pos'  = 0
					local se_`grp'_`pos' = 0
				}
				else {
					local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999]
					local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999]
				}
			}
		}
		else if "`ff'" == "log" {
			* Cells where mortality rate = 0 produce missing log values and are dropped automatically
			* Coefficients multiplied by 100: approximate % change in mortality rate per unit intensity
			reghdfe `outcome_log' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
				c.sp_intensity [pw=`wvar'] if $sample_marg, ///
				a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
			forval pos = 1/16 {
				if `pos' == 6 {
					local b_`grp'_`pos'  = 0
					local se_`grp'_`pos' = 0
				}
				else {
					local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999] * 100
					local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999] * 100
				}
			}
		}
		else {
			* Poisson: raw death count outcome with log-population offset and population weights.
			* Coefficients transformed to (exp(b)-1)*100: % change in death counts.
			* SEs via delta method: se_transformed = exp(b) * se_raw * 100.
			ppmlhdfe `outcome_poi' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
				c.sp_intensity [pw=`wvar'] if $sample_marg, ///
				a(year cve_ent_mun_super) offset(`offset_poi') vce(cluster cve_ent_mun_super)
			forval pos = 1/16 {
				if `pos' == 6 {
					local b_`grp'_`pos'  = 0
					local se_`grp'_`pos' = 0
				}
				else {
					local b_raw  = _b[`pos'.year_1995#c.inten1999]
					local se_raw = _se[`pos'.year_1995#c.inten1999]
					local b_`grp'_`pos'  = (exp(`b_raw') - 1) * 100
					local se_`grp'_`pos' = exp(`b_raw') * `se_raw' * 100
				}
			}
		}

	} // end foreach grp

	*--- Build plotting dataset and export ---
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
		(scatter b_w xpos_w, ///
			mcolor(black) msymbol(circle) msize(vsmall)) ///
		(rcap hi_f lo_f xpos_f, ///
			lcolor(red%60) lwidth(vthin)) ///
		(scatter b_f xpos_f, ///
			mcolor(red) msymbol(square) msize(vsmall)) ///
		(rcap hi_m lo_m xpos_m, ///
			lcolor(blue%60) lwidth(vthin)) ///
		(scatter b_m xpos_m, ///
			mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
		(line b_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin) msymbol(circle) mcolor(black) msize(vsmall)) ///
		(line b_f xpos_f if 1==0, lcolor(red) lpattern(dash) lwidth(thin) msymbol(square) mcolor(red) msize(vsmall)) ///
		(line b_m xpos_m if 1==0, lcolor(blue%80) lpattern(shortdash_dot) lwidth(thin) msymbol(triangle) mcolor(blue%80) msize(vsmall)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("`ytitle_ff'", size(medsmall)) ///
		ylabel(, grid gmin gmax labsize(small)) ///
		legend(order(7 "Pooled" 8 "Female" 9 "Male") ///
			cols(3) size(medsmall) position(6) ring(1) ///
			region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))
	graph export "$figures/appendix/`figname'.pdf", as(pdf) replace
	restore

} // end foreach ff
} // end Figure 7 block

*============================================================
* APPENDIX FIGURE 6: Short-term Event Study (Barham & Rowberry sample)
* FA_BR_es_pooled.pdf -- pooled, 2 specs: UW // W+SP and 3 Samples
*============================================================

{
local yr_labels `"2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002""'

* Define sample conditions and labels
local samples br marg brmarg
local sample_label_br "BR"
local sample_label_marg "HighMarg"
local sample_label_brmarg "BR_HighMarg"

foreach samp in `samples' {

    if "`samp'" == "br" {
        local samp_cond = "$sample_br"
    }
    else if "`samp'" == "marg" {
        local samp_cond = "$sample_marg"
    }
    else {
        local samp_cond = "($sample_br & $sample_marg)"
    }

    foreach outcome in emr65 emr65f emr65m aamr65 aamr65f aamr65m {

        if regexm("`outcome'", "f$") {
            local wvar = "popover65_f"
        }
        else if regexm("`outcome'", "m$") {
            local wvar = "popover65_m"
        }
        else {
            local wvar = "popover65_"
        }

        *--- Run three event study regressions (UW, UW+SP, W+SP) ---
        foreach spec in uw uwsp wsp {

            if "`spec'" == "uw" {
                reghdfe `outcome' c.inten1999##ib6.year_1995 ///
                    if inrange(year,1992,2002) & `samp_cond', ///
                    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
            }
            else if "`spec'" == "uwsp" {
                reghdfe `outcome' c.inten1999##ib6.year_1995 c.sp_intensity ///
                    if inrange(year,1992,2002) & `samp_cond', ///
                    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
            }
            else {
                reghdfe `outcome' c.inten1999##ib6.year_1995 c.sp_intensity [aw=`wvar'] ///
                    if inrange(year,1992,2002) & `samp_cond', ///
                    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
            }

            *--- Extract year-by-year coefficients; reference year (pos 6 = 1996) set to 0 ---
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

        *--- Build plotting dataset ---
        preserve
        clear
        set obs 11

        gen yr_pos = _n + 1
        gen xpos_uw   = yr_pos - 0.15
        gen xpos_uwsp = yr_pos
        gen xpos_wsp  = yr_pos + 0.15

        foreach spec in uw uwsp wsp {
            gen b_`spec'  = .
            gen hi_`spec' = .
            gen lo_`spec' = .
        }

        forval pos = 2/12 {
            foreach spec in uw uwsp wsp {
                replace b_`spec'  = `b_`spec'_`pos''                             if yr_pos == `pos'
                replace hi_`spec' = `b_`spec'_`pos'' + 1.96 * `se_`spec'_`pos'' if yr_pos == `pos'
                replace lo_`spec' = `b_`spec'_`pos'' - 1.96 * `se_`spec'_`pos'' if yr_pos == `pos'
            }
        }

        *--- Set color based on outcome (sex) ---
        if regexm("`outcome'", "f$") {
            local col_base = "red"
            local col_uwsp = "red%60"
            local col_wsp = "red%80"
        }
        else if regexm("`outcome'", "m$") {
            local col_base = "blue"
            local col_uwsp = "blue%60"
            local col_wsp = "blue%80"
        }
        else {
            local col_base = "black"
            local col_uwsp = "black%60"
            local col_wsp = "black"
        }

        twoway ///
            (rcap hi_uwsp lo_uwsp xpos_uwsp, lcolor(`col_uwsp') lpattern(dash) lwidth(vthin)) ///
            (scatter b_uwsp xpos_uwsp, mcolor(`col_uwsp') msymbol(square) msize(vsmall)) ///
            (rcap hi_wsp lo_wsp xpos_wsp, lcolor(`col_wsp') lwidth(vthin)) ///
            (scatter b_wsp xpos_wsp, mcolor(`col_wsp') msymbol(triangle) msize(vsmall)) ///
            (line b_uwsp xpos_uwsp if 1==0, lcolor(`col_uwsp') lpattern(dash) lwidth(thin) msymbol(square) mcolor(`col_uwsp') msize(vsmall)) ///
            (line b_wsp xpos_wsp if 1==0, lcolor(`col_wsp') lpattern(solid) lwidth(thin) msymbol(triangle) mcolor(`col_wsp') msize(vsmall)), ///
            yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
            xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
            xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
            xscale(range(1.5 12.5)) ///
            xtitle("") ///
            ytitle("Mortality Rate (per 1,000)", size(medsmall)) ///
            ylabel(-20(5)15, grid gmin gmax labsize(small)) ///
            legend(order(5 "Unweighted" 6 "Weighted") ///
                cols(2) size(medsmall) position(6) ring(1) ///
                region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
            graphregion(color(white)) ///
            plotregion(margin(l=1 r=1))

        graph export "$figures/appendix/Figure_6_`outcome'_`sample_label_`samp''.pdf", as(pdf) replace

        restore
    }
}

di ""
di "Event study figures exported (3 samples x 6 outcomes = 18 figures):"
di "  Pooled:  ES_emr65_*.pdf,  ES_aamr65_*.pdf"
di "  Females: ES_emr65f_*.pdf, ES_aamr65f_*.pdf"
di "  Males:   ES_emr65m_*.pdf, ES_aamr65m_*.pdf"
di "  Sample suffixes: _BR, _HighMarg, _BR_HighMarg"
}


*============================================================
* APPENDIX FIGURE 6: Event Study by Cause of Death (BR Sample, 1992-2002)
* Figure_7_XXX_BR.pdf — y-axis fixed at -3(3)3 for all causes
*============================================================

{
local yr_labels_cod `"2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002""'
local samp_cond  "$sample_br"
local samp_yr_cond "inrange(year,1992,2002)"
local obs_n = 11
local yr_pos_offset = 1
local xscale_range "range(1.5 12.5)"
local pos_start = 2
local pos_end   = 12

foreach cod in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {

	foreach grp in w f m {
		local reg_success_`grp' = 0
		if "`grp'" == "w" {
			local outcome emr65`cod'
			local wvar   popover65_
		}
		else if "`grp'" == "f" {
			local outcome emr65`cod'f
			local wvar   popover65_f
		}
		else {
			local outcome emr65`cod'm
			local wvar   popover65_m
		}
		capture noisily reghdfe `outcome' c.inten1999##ib6.year_1995 c.sp_intensity [aw=`wvar'] ///
			if `samp_yr_cond' & `samp_cond', ///
			a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		if _rc == 0 {
			local reg_success_`grp' = 1
			forval pos = `pos_start'/`pos_end' {
				if `pos' == 6 {
					local b_`grp'_`pos'  = 0
					local se_`grp'_`pos' = 0
				}
				else {
					local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999]
					local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999]
				}
			}
		}
		else {
			di "WARNING: Regression failed for `outcome' (`cod', BR sample) - skipping"
			forval pos = `pos_start'/`pos_end' {
				local b_`grp'_`pos'  = .
				local se_`grp'_`pos' = .
			}
		}
	}

	preserve
	clear
	set obs `obs_n'
	gen yr_pos = _n + `yr_pos_offset'
	gen xpos_w = yr_pos - 0.18
	gen xpos_f = yr_pos
	gen xpos_m = yr_pos + 0.18
	foreach grp in w f m {
		gen b_`grp'  = .
		gen hi_`grp' = .
		gen lo_`grp' = .
	}
	forval pos = `pos_start'/`pos_end' {
		foreach grp in w f m {
			if `reg_success_`grp'' == 1 {
				replace b_`grp'  = `b_`grp'_`pos''                            if yr_pos == `pos'
				replace hi_`grp' = `b_`grp'_`pos'' + 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
				replace lo_`grp' = `b_`grp'_`pos'' - 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
			}
		}
	}

	local yaxis_range "-3(3)3"

	local twoway_cmd "twoway"
	local legend_nums ""
	local legend_labels ""
	local plot_count = 0
	if `reg_success_w' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_w lo_w xpos_w, lcolor(black%60) lwidth(vthin)) (scatter b_w xpos_w, mcolor(black) msymbol(circle) msize(vsmall)) (line b_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Pooled)"
	}
	if `reg_success_f' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_f lo_f xpos_f, lcolor(red%60) lwidth(vthin)) (scatter b_f xpos_f, mcolor(red%60) msymbol(square) msize(vsmall)) (line b_f xpos_f if 1==0, lcolor(red%60) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Female)"
	}
	if `reg_success_m' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_m lo_m xpos_m, lcolor(blue%60) lwidth(vthin)) (scatter b_m xpos_m, mcolor(blue%60) msymbol(triangle) msize(vsmall)) (line b_m xpos_m if 1==0, lcolor(blue%60) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Male)"
	}
	local twoway_cmd "`twoway_cmd', yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) xlabel(`yr_labels_cod', labsize(small) angle(45) labcolor(black)) xscale(`xscale_range') xtitle("") ytitle("Mortality Rate, 65+ (per 1,000)", size(medsmall)) ylabel(`yaxis_range', grid gmin gmax labsize(small)) legend(order(`legend_nums') `legend_labels' cols(3) size(medsmall) position(6) ring(1) region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) graphregion(color(white)) plotregion(margin(l=1 r=1))"
	`twoway_cmd'
	graph export "$figures/appendix/Figure_7_`cod'_BR.pdf", as(pdf) replace
	restore

} // end foreach cod
} // end BR block


*============================================================
* APPENDIX FIGURE: Event Study by Cause of Death
*   Highly Marginalized Sample, 1992-2002 (short-run window)
* Figure_8_XXX_Marg.pdf — y-axis fixed at -3(3)3 for all causes
* Spec: Intensity1999 x year only (no Intensity2005), ref = 1996
*============================================================

{
local yr_labels_cod `"2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002""'
local samp_cond  "$sample_marg"
local samp_yr_cond "inrange(year,1992,2002)"
local obs_n = 11
local yr_pos_offset = 1
local xscale_range "range(1.5 12.5)"
local pos_start = 2
local pos_end   = 12

foreach cod in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {

	foreach grp in w f m {
		local reg_success_`grp' = 0
		if "`grp'" == "w" {
			local outcome emr65`cod'
			local wvar   popover65_
		}
		else if "`grp'" == "f" {
			local outcome emr65`cod'f
			local wvar   popover65_f
		}
		else {
			local outcome emr65`cod'm
			local wvar   popover65_m
		}
		capture noisily reghdfe `outcome' c.inten1999##ib6.year_1995 c.sp_intensity [aw=`wvar'] ///
			if `samp_yr_cond' & `samp_cond', ///
			a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		if _rc == 0 {
			local reg_success_`grp' = 1
			forval pos = `pos_start'/`pos_end' {
				if `pos' == 6 {
					local b_`grp'_`pos'  = 0
					local se_`grp'_`pos' = 0
				}
				else {
					local b_`grp'_`pos'  = _b[`pos'.year_1995#c.inten1999]
					local se_`grp'_`pos' = _se[`pos'.year_1995#c.inten1999]
				}
			}
		}
		else {
			di "WARNING: Regression failed for `outcome' (`cod', Marg short) - skipping"
			forval pos = `pos_start'/`pos_end' {
				local b_`grp'_`pos'  = .
				local se_`grp'_`pos' = .
			}
		}
	}

	preserve
	clear
	set obs `obs_n'
	gen yr_pos = _n + `yr_pos_offset'
	gen xpos_w = yr_pos - 0.18
	gen xpos_f = yr_pos
	gen xpos_m = yr_pos + 0.18
	foreach grp in w f m {
		gen b_`grp'  = .
		gen hi_`grp' = .
		gen lo_`grp' = .
	}
	forval pos = `pos_start'/`pos_end' {
		foreach grp in w f m {
			if `reg_success_`grp'' == 1 {
				replace b_`grp'  = `b_`grp'_`pos''                            if yr_pos == `pos'
				replace hi_`grp' = `b_`grp'_`pos'' + 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
				replace lo_`grp' = `b_`grp'_`pos'' - 1.96 * `se_`grp'_`pos'' if yr_pos == `pos'
			}
		}
	}

	local yaxis_range "-3(3)3"

	local twoway_cmd "twoway"
	local legend_nums ""
	local legend_labels ""
	local plot_count = 0
	if `reg_success_w' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_w lo_w xpos_w, lcolor(black%60) lwidth(vthin)) (scatter b_w xpos_w, mcolor(black) msymbol(circle) msize(vsmall)) (line b_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Pooled)"
	}
	if `reg_success_f' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_f lo_f xpos_f, lcolor(red%60) lwidth(vthin)) (scatter b_f xpos_f, mcolor(red%60) msymbol(square) msize(vsmall)) (line b_f xpos_f if 1==0, lcolor(red%60) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Female)"
	}
	if `reg_success_m' == 1 {
		local twoway_cmd "`twoway_cmd' (rcap hi_m lo_m xpos_m, lcolor(blue%60) lwidth(vthin)) (scatter b_m xpos_m, mcolor(blue%60) msymbol(triangle) msize(vsmall)) (line b_m xpos_m if 1==0, lcolor(blue%60) lpattern(solid) lwidth(thin))"
		local plot_count = `plot_count' + 3
		local legend_nums "`legend_nums' `plot_count'"
		local legend_labels "`legend_labels' label(`plot_count' Male)"
	}
	local twoway_cmd "`twoway_cmd', yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) xlabel(`yr_labels_cod', labsize(small) angle(45) labcolor(black)) xscale(`xscale_range') xtitle("") ytitle("Mortality Rate, 65+ (per 1,000)", size(medsmall)) ylabel(`yaxis_range', grid gmin gmax labsize(small)) legend(order(`legend_nums') `legend_labels' cols(3) size(medsmall) position(6) ring(1) region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) graphregion(color(white)) plotregion(margin(l=1 r=1))"
	`twoway_cmd'
	graph export "$figures/appendix/Figure_8_`cod'_Marg.pdf", as(pdf) replace
	restore

} // end foreach cod
} // end Marg short block


*============================================================
* APPENDIX TABLE 1: Causes of Death (Weighted + SP spec)
* AT1_cod_mortality.tex -- Pooled, Female, Male panels
*============================================================
foreach grp in w f m {
	if "`grp'" == "w" {
		local wvar = "popover65_"
		local suffix = ""
	}
	else if "`grp'" == "f" {
		local wvar = "popover65_f"
		local suffix = "f"
	}
	else {
		local wvar = "popover65_m"
		local suffix = "m"
	}

	foreach cod in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {
		reghdfe emr65`cod'`suffix' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			[aw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) ///
			vce(cluster cve_ent_mun_super)
		local aux: di %12.3f _b[1.post#c.inten1999]
		local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
		if      `t' >= 2.576 local b99_`grp'_`cod' = "`aux'***"
		else if `t' >= 1.96  local b99_`grp'_`cod' = "`aux'**"
		else if `t' >= 1.645 local b99_`grp'_`cod' = "`aux'*"
		else                  local b99_`grp'_`cod' = "`aux'"
		local se99_`grp'_`cod': di %12.3f _se[1.post#c.inten1999]
		local aux: di %12.3f _b[1.post#c.inten2005]
		local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
		if      `t' >= 2.576 local b05_`grp'_`cod' = "`aux'***"
		else if `t' >= 1.96  local b05_`grp'_`cod' = "`aux'**"
		else if `t' >= 1.645 local b05_`grp'_`cod' = "`aux'*"
		else                  local b05_`grp'_`cod' = "`aux'"
		local se05_`grp'_`cod': di %12.3f _se[1.post#c.inten2005]
		sum emr65`cod'`suffix' if e(sample) & post == 2
		local mean_`grp'_`cod': di %12.2fc `r(mean)'
		local N_`grp'_`cod': di %12.0fc `e(N)'
	}
}

*------------------------------------------------------------
* Romano-Wolf step-down correction for AT1_cod_mortality
* Family: 9 CoD outcomes; correction for Intensity1999xPost within each panel.
* Package: ssc install wyoung   (Jones, Molitor & Reif, SJ 2019)
* wyoung uses OUTCOMEVAR as placeholder in cmd(); the weight is embedded
* directly so it varies correctly across pooled/female/male panels.
* r(table): rows = outcomes in varlist order; col 5 = RW adjusted p-value.
*   Verify on first run with: matrix list r(table)
* NOTE: rw_treat99 = inten1999*(post==1) gives same coef as
*       1.post#c.inten1999 in the main reghdfe regressions.
* _hm indicator avoids | in if conditions inside wyoung cmd string.
*------------------------------------------------------------
cap drop rw_treat99 rw_treat05 _hm _br
gen rw_treat99 = inten1999 * (post == 1)
gen rw_treat05 = inten2005 * (post == 1)
gen _hm        = (gm_mun_1990 == 4 | gm_mun_1990 == 5)
gen _br        = (inten_start_year == 1998 | inten_start_year == 1999)

local cod_rw "tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other"
local wy_pval_col = 5   /* verify with: matrix list r(table) after first run */

foreach grp in w f m {
	if "`grp'" == "w" {
		local wvar "popover65_"
		local suffix ""
	}
	else if "`grp'" == "f" {
		local wvar "popover65_f"
		local suffix "f"
	}
	else {
		local wvar "popover65_m"
		local suffix "m"
	}

	* Build outcome varlist
	local outcomes ""
	foreach cod in `cod_rw' {
		local outcomes "`outcomes' emr65`cod'`suffix'"
	}

	* Embed weight and HM filter in command template (long-run window, all years in data)
	local cmd_str "reghdfe OUTCOMEVAR rw_treat99 rw_treat05 sp_intensity [aw=`wvar'] if _hm, absorb(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)"

	wyoung `outcomes', ///
		cmd(`"`cmd_str'"') ///
		familyp(rw_treat99) bootstraps(500) seed(12345) ///
		cluster(cve_ent_mun_super)

	matrix WY99_`grp' = r(table)
	local i = 1
	foreach cod in `cod_rw' {
		local rwp99_`grp'_`cod': di %6.3f WY99_`grp'[`i', `wy_pval_col']
		local i = `i' + 1
	}
}

{
	cap file close sm
	file open sm using "$tables/appendix/AT1_cod_mortality.tex", write replace
	file write sm "\begin{tabular}{lcccccccccc} \hline \hline" _n
	file write sm "& Cancer & Diab. & IllDef & Resp. & Card. & Infect. & Nutri. & Accid. & Other \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}\cmidrule(lr){10-10}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} & \multicolumn{1}{c}{(9)} \\ \toprule" _n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post} & `b99_w_tb_cancer' & `b99_w_tb_diab' & `b99_w_tb_illdef' & `b99_w_tb_resp' & `b99_w_tb_card' & `b99_w_tb_infect' & `b99_w_tb_nutri' & `b99_w_tb_accid' & `b99_w_tb_other' \\ " _n
	file write sm " & (`se99_w_tb_cancer') & (`se99_w_tb_diab') & (`se99_w_tb_illdef') & (`se99_w_tb_resp') & (`se99_w_tb_card') & (`se99_w_tb_infect') & (`se99_w_tb_nutri') & (`se99_w_tb_accid') & (`se99_w_tb_other') \\ " _n
	file write sm "\textit{RW p-value} & [`rwp99_w_tb_cancer'] & [`rwp99_w_tb_diab'] & [`rwp99_w_tb_illdef'] & [`rwp99_w_tb_resp'] & [`rwp99_w_tb_card'] & [`rwp99_w_tb_infect'] & [`rwp99_w_tb_nutri'] & [`rwp99_w_tb_accid'] & [`rwp99_w_tb_other'] \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post} & `b05_w_tb_cancer' & `b05_w_tb_diab' & `b05_w_tb_illdef' & `b05_w_tb_resp' & `b05_w_tb_card' & `b05_w_tb_infect' & `b05_w_tb_nutri' & `b05_w_tb_accid' & `b05_w_tb_other' \\ " _n
	file write sm " & (`se05_w_tb_cancer') & (`se05_w_tb_diab') & (`se05_w_tb_illdef') & (`se05_w_tb_resp') & (`se05_w_tb_card') & (`se05_w_tb_infect') & (`se05_w_tb_nutri') & (`se05_w_tb_accid') & (`se05_w_tb_other') \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "Mean (pre-1997) & `mean_w_tb_cancer' & `mean_w_tb_diab' & `mean_w_tb_illdef' & `mean_w_tb_resp' & `mean_w_tb_card' & `mean_w_tb_infect' & `mean_w_tb_nutri' & `mean_w_tb_accid' & `mean_w_tb_other' \\ " _n
	file write sm "Obs & `N_w_tb_cancer' & `N_w_tb_diab' & `N_w_tb_illdef' & `N_w_tb_resp' & `N_w_tb_card' & `N_w_tb_infect' & `N_w_tb_nutri' & `N_w_tb_accid' & `N_w_tb_other' \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "\underline{\textit{Panel B: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post} & `b99_f_tb_cancer' & `b99_f_tb_diab' & `b99_f_tb_illdef' & `b99_f_tb_resp' & `b99_f_tb_card' & `b99_f_tb_infect' & `b99_f_tb_nutri' & `b99_f_tb_accid' & `b99_f_tb_other' \\ " _n
	file write sm " & (`se99_f_tb_cancer') & (`se99_f_tb_diab') & (`se99_f_tb_illdef') & (`se99_f_tb_resp') & (`se99_f_tb_card') & (`se99_f_tb_infect') & (`se99_f_tb_nutri') & (`se99_f_tb_accid') & (`se99_f_tb_other') \\ " _n
	file write sm "\textit{RW p-value} & [`rwp99_f_tb_cancer'] & [`rwp99_f_tb_diab'] & [`rwp99_f_tb_illdef'] & [`rwp99_f_tb_resp'] & [`rwp99_f_tb_card'] & [`rwp99_f_tb_infect'] & [`rwp99_f_tb_nutri'] & [`rwp99_f_tb_accid'] & [`rwp99_f_tb_other'] \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post} & `b05_f_tb_cancer' & `b05_f_tb_diab' & `b05_f_tb_illdef' & `b05_f_tb_resp' & `b05_f_tb_card' & `b05_f_tb_infect' & `b05_f_tb_nutri' & `b05_f_tb_accid' & `b05_f_tb_other' \\ " _n
	file write sm " & (`se05_f_tb_cancer') & (`se05_f_tb_diab') & (`se05_f_tb_illdef') & (`se05_f_tb_resp') & (`se05_f_tb_card') & (`se05_f_tb_infect') & (`se05_f_tb_nutri') & (`se05_f_tb_accid') & (`se05_f_tb_other') \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "Mean (pre-1997) & `mean_f_tb_cancer' & `mean_f_tb_diab' & `mean_f_tb_illdef' & `mean_f_tb_resp' & `mean_f_tb_card' & `mean_f_tb_infect' & `mean_f_tb_nutri' & `mean_f_tb_accid' & `mean_f_tb_other' \\ " _n
	file write sm "Obs & `N_f_tb_cancer' & `N_f_tb_diab' & `N_f_tb_illdef' & `N_f_tb_resp' & `N_f_tb_card' & `N_f_tb_infect' & `N_f_tb_nutri' & `N_f_tb_accid' & `N_f_tb_other' \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "\underline{\textit{Panel C: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post} & `b99_m_tb_cancer' & `b99_m_tb_diab' & `b99_m_tb_illdef' & `b99_m_tb_resp' & `b99_m_tb_card' & `b99_m_tb_infect' & `b99_m_tb_nutri' & `b99_m_tb_accid' & `b99_m_tb_other' \\ " _n
	file write sm " & (`se99_m_tb_cancer') & (`se99_m_tb_diab') & (`se99_m_tb_illdef') & (`se99_m_tb_resp') & (`se99_m_tb_card') & (`se99_m_tb_infect') & (`se99_m_tb_nutri') & (`se99_m_tb_accid') & (`se99_m_tb_other') \\ " _n
	file write sm "\textit{RW p-value} & [`rwp99_m_tb_cancer'] & [`rwp99_m_tb_diab'] & [`rwp99_m_tb_illdef'] & [`rwp99_m_tb_resp'] & [`rwp99_m_tb_card'] & [`rwp99_m_tb_infect'] & [`rwp99_m_tb_nutri'] & [`rwp99_m_tb_accid'] & [`rwp99_m_tb_other'] \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post} & `b05_m_tb_cancer' & `b05_m_tb_diab' & `b05_m_tb_illdef' & `b05_m_tb_resp' & `b05_m_tb_card' & `b05_m_tb_infect' & `b05_m_tb_nutri' & `b05_m_tb_accid' & `b05_m_tb_other' \\ " _n
	file write sm " & (`se05_m_tb_cancer') & (`se05_m_tb_diab') & (`se05_m_tb_illdef') & (`se05_m_tb_resp') & (`se05_m_tb_card') & (`se05_m_tb_infect') & (`se05_m_tb_nutri') & (`se05_m_tb_accid') & (`se05_m_tb_other') \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "Mean (pre-1997) & `mean_m_tb_cancer' & `mean_m_tb_diab' & `mean_m_tb_illdef' & `mean_m_tb_resp' & `mean_m_tb_card' & `mean_m_tb_infect' & `mean_m_tb_nutri' & `mean_m_tb_accid' & `mean_m_tb_other' \\ " _n
	file write sm "Obs & `N_m_tb_cancer' & `N_m_tb_diab' & `N_m_tb_illdef' & `N_m_tb_resp' & `N_m_tb_card' & `N_m_tb_infect' & `N_m_tb_nutri' & `N_m_tb_accid' & `N_m_tb_other' \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}

*============================================================
* APPENDIX TABLE 2: Functional Form Robustness
*============================================================


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
	* col 5: log mortality rate, weighted; coef x100 = approx % change in mortality rate
	reghdfe `loutcome' c.inten1999#i.post c.inten2005#i.post ///
		[pw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.2f _b[1.post#c.inten1999] * 100
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local bFF99_`pnl'_5 = "`aux'***"
	else if `t' >= 1.96  local bFF99_`pnl'_5 = "`aux'**"
	else if `t' >= 1.645 local bFF99_`pnl'_5 = "`aux'*"
	else                  local bFF99_`pnl'_5 = "`aux'"
	local seFF99_`pnl'_5: di %12.2f _se[1.post#c.inten1999] * 100
	local aux: di %12.2f _b[1.post#c.inten2005] * 100
	local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
	if      `t' >= 2.576 local bFF05_`pnl'_5 = "`aux'***"
	else if `t' >= 1.96  local bFF05_`pnl'_5 = "`aux'**"
	else if `t' >= 1.645 local bFF05_`pnl'_5 = "`aux'*"
	else                  local bFF05_`pnl'_5 = "`aux'"
	local seFF05_`pnl'_5: di %12.2f _se[1.post#c.inten2005] * 100
	sum `loutcome' if e(sample) & post == 2
	local meanFF_`pnl'_5: di %12.2fc `r(mean)'
	local NFF_`pnl'_5:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunFF_`pnl'_5: di %12.0fc `r(ndistinct)'
	* col 6: Poisson, weighted; coef = (exp(b)-1)*100 = % change in death counts
	ppmlhdfe `doutcome' c.inten1999#i.post c.inten2005#i.post ///
		[pw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) offset(`offset') vce(cluster cve_ent_mun_super)
	local aux: di %12.2f (exp(_b[1.post#c.inten1999])-1)*100
	local seFF99_`pnl'_6 : di %12.2f exp(_b[1.post#c.inten1999])*_se[1.post#c.inten1999]*100
	local t = abs(`aux' / `seFF99_`pnl'_6')
	if      `t' >= 2.576 local bFF99_`pnl'_6 = "`aux'***"
	else if `t' >= 1.96  local bFF99_`pnl'_6 = "`aux'**"
	else if `t' >= 1.645 local bFF99_`pnl'_6 = "`aux'*"
	else                  local bFF99_`pnl'_6 = "`aux'"

	local seFF05_`pnl'_6: di %12.2f exp(_b[1.post#c.inten2005])*_se[1.post#c.inten2005]*100
	local aux: di %12.2f (exp(_b[1.post#c.inten2005])-1)*100
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
	* col 7: AAMR, weighted + Seguro Popular (merged into AT2 as col 4)
	if "`pnl'" == "p" local aamr_out aamr65
	else if "`pnl'" == "m" local aamr_out aamr65m
	else local aamr_out aamr65f
	reghdfe `aamr_out' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
		[aw=`wvar'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local bAAMR99_`pnl' = "`aux'***"
	else if `t' >= 1.96  local bAAMR99_`pnl' = "`aux'**"
	else if `t' >= 1.645 local bAAMR99_`pnl' = "`aux'*"
	else                  local bAAMR99_`pnl' = "`aux'"
	local seAAMR99_`pnl': di %12.3f _se[1.post#c.inten1999]
	local aux: di %12.3f _b[1.post#c.inten2005]
	local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
	if      `t' >= 2.576 local bAAMR05_`pnl' = "`aux'***"
	else if `t' >= 1.96  local bAAMR05_`pnl' = "`aux'**"
	else if `t' >= 1.645 local bAAMR05_`pnl' = "`aux'*"
	else                  local bAAMR05_`pnl' = "`aux'"
	local seAAMR05_`pnl': di %12.3f _se[1.post#c.inten2005]
	sum `aamr_out' if e(sample) & post == 2
	local meanAAMR_`pnl': di %12.2fc `r(mean)'
	local NAAMR_`pnl':    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local NmunAAMR_`pnl': di %12.0fc `r(ndistinct)'
}

* Mean Intensity 1999 for AT2 — HM sample, displayed as %
quietly sum inten1999 if $sample_marg & year == 1996
local meanI99_AT2: di %6.1f r(mean) * 100

{
	cap file close sm
	file open sm using "$tables/appendix/AT2_functional_forms.tex", write replace
	file write sm "\begin{tabular}{lcccc} \hline \hline" _n
	file write sm "& Levels & Log & Poisson & AAMR \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `bFF99_p_4' & `bFF99_p_5' & `bFF99_p_6' & `bAAMR99_p' \\ " _n
	file write sm "  & (`seFF99_p_4') & (`seFF99_p_5') & (`seFF99_p_6') & (`seAAMR99_p') \\ " _n
	file write sm "   & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `bFF05_p_4' & `bFF05_p_5' & `bFF05_p_6' & `bAAMR05_p' \\ " _n
	file write sm " & (`seFF05_p_4') & (`seFF05_p_5') & (`seFF05_p_6') & (`seAAMR05_p') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996)  & `meanFF_p_4' & `meanFF_p_5' & `meanFF_p_6' & `meanAAMR_p' \\ " _n
	file write sm "  & & & &  \\ " _n
	file write sm "\underline{\textit{Panel B: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)}  & `bFF99_f_4' & `bFF99_f_5' & `bFF99_f_6' & `bAAMR99_f' \\ " _n
	file write sm "  & (`seFF99_f_4') & (`seFF99_f_5') & (`seFF99_f_6') & (`seAAMR99_f') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `bFF05_f_4' & `bFF05_f_5' & `bFF05_f_6' & `bAAMR05_f' \\ " _n
	file write sm " & (`seFF05_f_4') & (`seFF05_f_5') & (`seFF05_f_6') & (`seAAMR05_f') \\ " _n
	file write sm "   & & & & \\ " _n
	file write sm "Mean (1991-1996)  & `meanFF_f_4' & `meanFF_f_5' & `meanFF_f_6' & `meanAAMR_f' \\ " _n
	file write sm "  & & & &  \\ " _n
	file write sm "\underline{\textit{Panel C: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `bFF99_m_4' & `bFF99_m_5' & `bFF99_m_6' & `bAAMR99_m' \\ " _n
	file write sm "  & (`seFF99_m_4') & (`seFF99_m_5') & (`seFF99_m_6') & (`seAAMR99_m') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `bFF05_m_4' & `bFF05_m_5' & `bFF05_m_6' & `bAAMR05_m' \\ " _n
	file write sm " & (`seFF05_m_4') & (`seFF05_m_5') & (`seFF05_m_6') & (`seAAMR05_m') \\ " _n
	file write sm " & & & & \\ " _n
	file write sm "Mean (1991-1996) & `meanFF_m_4' & `meanFF_m_5' & `meanFF_m_6' & `meanAAMR_m' \\ " _n
	file write sm "  & & & &  \\ " _n
	file write sm "Obs & `NFF_f_4' & `NFF_f_5' & `NFF_f_6' & `NAAMR_f' \\ " _n
	file write sm "No. Mun & `NmunFF_p_4' & `NmunFF_p_5' & `NmunFF_p_6' & `NmunAAMR_p' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Seguro Popular & N & N & N & Y \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_AT2' & `meanI99_AT2' & `meanI99_AT2' & `meanI99_AT2' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
*============================================================
* APPENDIX TABLE 3: Barham & Rowberry (2013) Replication
*============================================================

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

* Mean Intensity 1999 for AT3 — BR sample, displayed as %
quietly sum inten1999 if $sample_br & year == 1996
local meanI99_AT3: di %6.1f r(mean) * 100

{
	cap file close sm
	file open sm using "$tables/appendix/AT3_BR_replication.tex", write replace
	file write sm "\begin{tabular}{lccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{Pooled} & \multicolumn{1}{c}{Females} & \multicolumn{1}{c}{Males} \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}  " _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\ \toprule " _n
	* Panel A: hardcoded BR (2013) original results
	file write sm "\underline{\textit{Panel A: BR (2013)}}  \\ " _n
	file write sm "\textit{2-yr lagged Intensity} & -6.37*** & -6.46*** & -6.42*** \\ " _n
	file write sm " & (1.04) & (1.31) & (1.42) \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean 1996 & 47.5 & 46.0 & 49.3 \\ " _n
	file write sm "Obs & 21,571 & 21,571 & 21,571 \\ " _n
	file write sm "No. Mun & 1,961 & 1,961 & 1,961 \\ " _n
	file write sm "  & & & \\ " _n
	* Panel B: lag2, UW
	file write sm "\underline{\textit{Panel B: Replication (Unweighted)}}  \\ " _n
	file write sm "\textit{2-yr lagged Intensity} & `bBR2_2_p' & `bBR2_2_f' & `bBR2_2_m' \\ " _n
	file write sm " & (`seBR2_2_p') & (`seBR2_2_f') & (`seBR2_2_m') \\ " _n
	file write sm "  & & & \\ " _n
	* Panel C: lag2, W
	file write sm "\underline{\textit{Panel C: Replication (Weighted)}}  \\ " _n
	file write sm "\textit{2-yr lagged Intensity} & `bBR2_3_p' & `bBR2_3_f' & `bBR2_3_m' \\ " _n
	file write sm " & (`seBR2_3_p') & (`seBR2_3_f') & (`seBR2_3_m') \\ " _n
	file write sm "  & & & \\ " _n
	* Panel D: lag1, W
	file write sm "\underline{\textit{Panel D: 1-yr Lag (Weighted)}}  \\ " _n
	file write sm "\textit{1-yr lagged Intensity} & `bBR1_4_p' & `bBR1_4_f' & `bBR1_4_m' \\ " _n
	file write sm " & (`seBR1_4_p') & (`seBR1_4_f') & (`seBR1_4_m') \\ " _n
	file write sm "  & & & \\ " _n
	* Panel E: lag3, W
	file write sm "\underline{\textit{Panel E: 3-yr Lag (Weighted)}}  \\ " _n
	file write sm "\textit{3-yr lagged Intensity} & `bBR3_5_p' & `bBR3_5_f' & `bBR3_5_m' \\ " _n
	file write sm " & (`seBR3_5_p') & (`seBR3_5_f') & (`seBR3_5_m') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean 1996 & `meanBR_5_p' & `meanBR_5_f' & `meanBR_5_m' \\ " _n
	file write sm "Obs & `NBR_5_p' & `NBR_5_f' & `NBR_5_m' \\ " _n
	file write sm "No. Mun & `NmunBR_2_p' & `NmunBR_2_f' & `NmunBR_2_m' \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_AT3' & `meanI99_AT3' & `meanI99_AT3' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}


*============================================================
* APPENDIX TABLE 4: BR Analysis — Table AT3_BR_replication.tex
*============================================================
*============================================================
* BR 2013 Robustness: DD with sample & weighting variations
* Purpose: Test whether Barham & Rowberry (2013) results hold
*          with FE approach, high-marginalization sample,
*          65+ weighting, and SP intensity controls
* Input: same data as 02_mortality.do
* Output: Two tables (emr65 & aamr65) with 9 DD specifications
*============================================================

*============================================================
* Run DD Regressions: 9 specifications for each outcome
*============================================================

* Sample definitions for the table
* 1. sample_br: BR sample (unweighted, UW+SP, W+SP)
* 2. sample_marg: highly marginalized municipalities (UW, UW+SP, W+SP)
* 3. sample_br & sample_marg: BR sample restricted to high marginalization (UW, UW+SP, W+SP)

* Store results in matrices: one matrix per outcome × panel (Pooled, Female, Male)
foreach pnl in p f m {
    matrix results_emr65_`pnl' = J(6, 9, .)
    matrix results_aamr65_`pnl' = J(6, 9, .)
    matrix colnames results_emr65_`pnl' = "br_uw" "br_uwsp" "br_wsp" "marg_uw" "marg_uwsp" "marg_wsp" "brmarg_uw" "brmarg_uwsp" "brmarg_wsp"
    matrix colnames results_aamr65_`pnl' = "br_uw" "br_uwsp" "br_wsp" "marg_uw" "marg_uwsp" "marg_wsp" "brmarg_uw" "brmarg_uwsp" "brmarg_wsp"
    matrix rownames results_emr65_`pnl' = "coef" "se" "t_stat" "n_obs" "n_mun" "mean_pre"
    matrix rownames results_aamr65_`pnl' = "coef" "se" "t_stat" "n_obs" "n_mun" "mean_pre"
}

* Loop: panel × sample × spec; fill all matrices in one pass
foreach pnl in p f m {
    if "`pnl'" == "p" {
        local osfx ""
        local wv "popover65_"
    }
    else if "`pnl'" == "f" {
        local osfx "f"
        local wv "popover65_f"
    }
    else {
        local osfx "m"
        local wv "popover65_m"
    }

    local col = 1
    foreach samp in br marg brmarg {
        if "`samp'" == "br"        local cond "$sample_br"
        else if "`samp'" == "marg" local cond "$sample_marg"
        else                        local cond "$sample_br & $sample_marg"

        foreach spec in uw uwsp wsp {
            foreach out in emr65 aamr65 {
                local depvar `out'`osfx'

                if "`spec'" == "uw" {
                    reghdfe `depvar' c.inten1999#i.post ///
                        if inrange(year,1992,2002) & `cond', ///
                        a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
                }
                else if "`spec'" == "uwsp" {
                    reghdfe `depvar' c.inten1999#i.post c.sp_intensity ///
                        if inrange(year,1992,2002) & `cond', ///
                        a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
                }
                else {
                    reghdfe `depvar' c.inten1999#i.post c.sp_intensity [aw=`wv'] ///
                        if inrange(year,1992,2002) & `cond', ///
                        a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
                }

                matrix results_`out'_`pnl'[1,`col'] = _b[1.post#c.inten1999]
                matrix results_`out'_`pnl'[2,`col'] = _se[1.post#c.inten1999]
                matrix results_`out'_`pnl'[3,`col'] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
                matrix results_`out'_`pnl'[4,`col'] = e(N)
                distinct cve_ent_mun_super if e(sample)
                matrix results_`out'_`pnl'[5,`col'] = r(ndistinct)
                sum `depvar' if e(sample) & post==2
                matrix results_`out'_`pnl'[6,`col'] = r(mean)
            }
            local col = `col' + 1
        }
    }
}

*============================================================
* Display & Export Results
*============================================================

di "=== MORTALITY RATE (EMR65) RESULTS ==="
foreach pnl in p f m {
	di ""
	di "Panel `pnl' (p=Pooled, f=Female, m=Male):"
	matrix list results_emr65_`pnl'
}

di ""
di "=== AGE-ADJUSTED MORTALITY RATE (AAMR65) RESULTS ==="
foreach pnl in p f m {
	di ""
	di "Panel `pnl' (p=Pooled, f=Female, m=Male):"
	matrix list results_aamr65_`pnl'
}

*============================================================
* Build formatted LaTeX tables (3 panels: Pooled, Females, Males)
*============================================================

* Mean Intensity 1999 by sample for AT4 — mirror T1 approach: one obs per municipality
preserve
keep if year == 1996
quietly sum inten1999 if $sample_br
local meanI99_br: di %6.1f r(mean) * 100
quietly sum inten1999 if $sample_marg
local meanI99_hm: di %6.1f r(mean) * 100
restore

foreach out in emr65 aamr65 {
	cap file close tbl
	file open tbl using "$tables/appendix/AT4_BR_robustness_`out'.tex", write replace
	file write tbl "\begin{tabular}{lccccc} \hline \hline" _n
	file write tbl "& \multicolumn{2}{c}{\textit{BR Sample}} " _n
	file write tbl "& \multicolumn{2}{c}{\textit{High Marginalization}} \\ \cmidrule(lr){2-3}\cmidrule(lr){4-5}" _n
	file write tbl "& \multicolumn{1}{c}{Unweighted} & \multicolumn{1}{c}{Weighted} & \multicolumn{1}{c}{Unweighted} & \multicolumn{1}{c}{Weighted} \\ \cmidrule(lr){2-5}" _n
	file write tbl "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n

	foreach pnl in p f m {
		if "`pnl'" == "p"      local plabel "Panel A: Pooled"
		else if "`pnl'" == "f" local plabel "Panel B: Females"
		else                    local plabel "Panel C: Males"

		file write tbl "\underline{\textit{`plabel'}} \\ " _n

		file write tbl "\textit{Intensity x Post (1997-2002)}"
		foreach col in 2 3 5 6 {
			local coef = results_`out'_`pnl'[1,`col']
			local t = results_`out'_`pnl'[3,`col']
			if `t' >= 2.576 file write tbl "& " %9.3f (`coef') "***"
			else if `t' >= 1.96  file write tbl "& " %9.3f (`coef') "**"
			else if `t' >= 1.645 file write tbl "& " %9.3f (`coef') "*"
			else                  file write tbl "& " %9.3f (`coef') ""
		}
		file write tbl " \\ " _n
		file write tbl " "
		foreach col in 2 3 5 6 {
			local se = results_`out'_`pnl'[2,`col']
			file write tbl "& (" %9.3f (`se') ")"
		}
		file write tbl " \\ " _n
		file write tbl "  & & & & \\ " _n
		file write tbl "Mean (1991-1996)"
		foreach col in 2 3 5 6 {
			local mean = results_`out'_`pnl'[6,`col']
			file write tbl "& " %9.2f (`mean') ""
		}
		file write tbl " \\ " _n
		file write tbl "Obs"
		foreach col in 2 3 5 6 {
			local n = results_`out'_`pnl'[4,`col']
			file write tbl "& " %9.0f (`n') ""
		}
		file write tbl " \\ " _n
		file write tbl "No. Mun"
		foreach col in 2 3 5 6 {
			local nmun = results_`out'_`pnl'[5,`col']
			file write tbl "& " %9.0f (`nmun') ""
		}
		if "`pnl'" != "m" {
			file write tbl " \\ " _n
			file write tbl "  & & & & \\ " _n
		}
		else {
			file write tbl " \\ " _n
		}
	}

	file write tbl "  & & & & \\ " _n
	file write tbl "Mean Intensity 1999 (\%) & `meanI99_br' & `meanI99_br' & `meanI99_hm' & `meanI99_hm' \\ " _n
	file write tbl "\bottomrule" _n
	file write tbl "\end{tabular}"
	file close tbl
}

di ""
di "Tables exported to:"
di "  $tables/appendix/AT4_BR_robustness_emr65.tex"
di "  $tables/appendix/AT4_BR_robustness_aamr65.tex"


*============================================================
* APPENDIX TABLE 5: BR Trimming — Municipality Size
* Tests whether the BR unweighted result is driven by smallest
* municipalities. Progressively drops municipalities below
* the 10th, 25th, and 50th percentile of older-adult population.
* Pooled only; same unweighted lag-2 spec as AT3 Panel B.
* Output: $tables/appendix/AT5_BR_trimming.tex
*============================================================

* Step 1: Compute municipality-level mean older-adult population
*         across the BR sample period (used as size proxy for trimming)
capture drop _pop_br_tmp pop_mun_br
bys cve_ent_mun_super: egen _pop_br_tmp = mean(popover65_) ///
    if inrange(year, 1992, 2002) & $sample_br
bys cve_ent_mun_super: egen pop_mun_br = mean(_pop_br_tmp)
drop _pop_br_tmp

* Step 2: Get p10/p25/p50 cutoffs at the municipality level
preserve
    keep if $sample_br & inrange(year, 1992, 2002)
    collapse (mean) pop_mean = popover65_, by(cve_ent_mun_super)
    _pctile pop_mean, p(10 25)
    local p10_br = r(r1)
    local p25_br = r(r2)
restore

di "BR size cutoffs (older adults 65+): p10=`p10_br', p25=`p25_br', p50=`p50_br'"

* Cols 2-3: pooled UW and W replication — self-contained so AT5 does not
*           depend on AT3 locals (mirrors AT3 Panel B and Panel C, pooled)
reghdfe emr65 lag2_intensity_new if inrange(year, 1992, 2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bBR2_2_p = "`aux'***"
else if `t' >= 1.96  local bBR2_2_p = "`aux'**"
else if `t' >= 1.645 local bBR2_2_p = "`aux'*"
else                  local bBR2_2_p = "`aux'"
local seBR2_2_p: di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & year == 1996
local meanBR_2_p: di %12.2fc `r(mean)'
local NBR_2_p:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local NmunBR_2_p: di %12.0fc `r(ndistinct)'

reghdfe emr65 lag2_intensity_new [aw=popover65_] if inrange(year, 1992, 2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bBR2_3_p = "`aux'***"
else if `t' >= 1.96  local bBR2_3_p = "`aux'**"
else if `t' >= 1.645 local bBR2_3_p = "`aux'*"
else                  local bBR2_3_p = "`aux'"
local seBR2_3_p: di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & year == 1996
local meanBR_3_p: di %12.2fc `r(mean)'
local NBR_3_p:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local NmunBR_3_p: di %12.0fc `r(ndistinct)'

* Step 3: Run regressions — same unweighted lag-2 BR spec, pooled only

* Column 2: Drop bottom decile (municipalities with pop_mun_br <= p10)
reghdfe emr65 lag2_intensity_new ///
    if inrange(year,1992,2002) & $sample_br & pop_mun_br > `p10_br', ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bAT5_2 = "`aux'***"
else if `t' >= 1.96  local bAT5_2 = "`aux'**"
else if `t' >= 1.645 local bAT5_2 = "`aux'*"
else                  local bAT5_2 = "`aux'"
local seAT5_2:   di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & year == 1996
local meanAT5_2: di %12.2fc `r(mean)'
local NAT5_2:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local NmunAT5_2: di %12.0fc `r(ndistinct)'

* Column 3: Drop bottom quartile (municipalities with pop_mun_br <= p25)
reghdfe emr65 lag2_intensity_new ///
    if inrange(year,1992,2002) & $sample_br & pop_mun_br > `p25_br', ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[lag2_intensity_new]
local t = abs(_b[lag2_intensity_new] / _se[lag2_intensity_new])
if      `t' >= 2.576 local bAT5_3 = "`aux'***"
else if `t' >= 1.96  local bAT5_3 = "`aux'**"
else if `t' >= 1.645 local bAT5_3 = "`aux'*"
else                  local bAT5_3 = "`aux'"
local seAT5_3:   di %12.3f _se[lag2_intensity_new]
sum emr65 if e(sample) & year == 1996
local meanAT5_3: di %12.2fc `r(mean)'
local NAT5_3:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local NmunAT5_3: di %12.0fc `r(ndistinct)'

* Step 4: Write table
* Cols 2-3 reuse locals from the AT3 block:
*   Col 2 (UW replication):  bBR2_2_p, seBR2_2_p, meanBR_2_p, NBR_2_p, NmunBR_2_p
*   Col 3 (W replication):   bBR2_3_p, seBR2_3_p, meanBR_3_p, NBR_3_p, NmunBR_3_p
{
    cap file close sm
    file open sm using "$tables/appendix/AT5_BR_trimming.tex", write replace
    file write sm "\begin{tabular}{lccccc} \hline \hline" _n
    file write sm "& \multicolumn{1}{c}{} & \multicolumn{2}{c}{\textit{Full Sample}} & \multicolumn{2}{c}{\textit{Progressive Trimming}} \\ \cmidrule(lr){3-4} \cmidrule(lr){5-6}" _n
    file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\ " _n
    file write sm "& \multicolumn{1}{c}{BR Original} & \multicolumn{1}{c}{Replication (UW)} & \multicolumn{1}{c}{Replication (W)} & \multicolumn{1}{c}{Ex.\ bottom 10\%} & \multicolumn{1}{c}{Ex.\ bottom 25\%} \\ \toprule " _n
    file write sm "\textit{2-yr lagged Intensity} & -6.370*** & `bBR2_2_p' & `bBR2_3_p' & `bAT5_2' & `bAT5_3' \\ " _n
    file write sm " & (1.040) & (`seBR2_2_p') & (`seBR2_3_p') & (`seAT5_2') & (`seAT5_3') \\ " _n
    file write sm "  & & & & & \\ " _n
    file write sm "Mean 1996 & 47.5 & `meanBR_2_p' & `meanBR_3_p' & `meanAT5_2' & `meanAT5_3' \\ " _n
    file write sm "Obs & 21,571 & `NBR_2_p' & `NBR_3_p' & `NAT5_2' & `NAT5_3' \\ " _n
    file write sm "No.\ Mun & 1,961 & `NmunBR_2_p' & `NmunBR_3_p' & `NmunAT5_2' & `NmunAT5_3' \\ " _n
    file write sm "\bottomrule" _n
    file write sm "\multicolumn{6}{l}{\footnotesize \textit{Notes:} Column (1) reproduces the BR (2013) original. Column (2) is our close replication} \\ " _n
    file write sm "\multicolumn{6}{l}{\footnotesize (unweighted, AT3 Panel B). Column (3) adds population weights (AT3 Panel C).} \\ " _n
    file write sm "\multicolumn{6}{l}{\footnotesize Columns (4)--(5) re-estimate column (2) excluding municipalities below the 10th and 25th} \\ " _n
    file write sm "\multicolumn{6}{l}{\footnotesize percentile of mean older-adult population (ages 65+), respectively.} \\ " _n
    file write sm "\end{tabular}"
    file close sm
}

drop pop_mun_br
di "Table exported to: $tables/appendix/AT5_BR_trimming.tex"




*============================================================
* APPENDIX TABLE: SES Trend Robustness (Comment 4 — P&V spec 3)
* Weighted + SP baseline; adds municipality-specific linear trends
* interacted with 1990 baseline SES.
* Col 1: Baseline (W+SP, same as T2 col 4)
* Col 2: + Trend × im_mun_1990 (continuous marginalization index)
* Col 3: + Trend × 1990 marginalization-index quintile bins (P&V 2023 style)
* Output: $tables/appendix/AT_ses_trend.tex
*============================================================

* Generate time-invariant 1990 values per municipality for SES components
foreach v of varlist analf sprim ovsee ovsae vhac ovpt ovsde pl5000 {
	cap drop `v'_90
	bys cve_ent_mun_super: gen _tmp = `v' if year == 1990
	bys cve_ent_mun_super: egen `v'_90 = max(_tmp)
	drop _tmp
}

* P&V (2023)-style flexible baseline-SES trend: bin municipalities into
* quintiles of the 1990 marginalization index and interact the bins with a
* year trend. Robust to missing/sparse individual census components (col 3
* previously interacted 8 raw 1990 components, 1-2 of which are mostly null).
* Cutpoints computed on the municipality cross-section (one obs per mun) so
* they are not weighted by panel length.
local nq_ses 5
cap drop im90_bin
egen _mun_tag = tag(cve_ent_mun_super)
xtile im90_bin = im_mun_1990 if _mun_tag, nq(`nq_ses')
bys cve_ent_mun_super: egen _im90_bin = max(im90_bin)
replace im90_bin = _im90_bin
drop _mun_tag _im90_bin
label var im90_bin "1990 marginalization-index quintile (1=least, `nq_ses'=most marginalized)"

* --- Col 1: Baseline (Weighted + Seguro Popular) ---
reghdfe emr65 c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
	[aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local b99_ses_1 = "`aux'***"
else if `t' >= 1.96  local b99_ses_1 = "`aux'**"
else if `t' >= 1.645 local b99_ses_1 = "`aux'*"
else                  local b99_ses_1 = "`aux'"
local se99_ses_1: di %12.3f _se[1.post#c.inten1999]
local aux: di %12.3f _b[1.post#c.inten2005]
local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
if      `t' >= 2.576 local b05_ses_1 = "`aux'***"
else if `t' >= 1.96  local b05_ses_1 = "`aux'**"
else if `t' >= 1.645 local b05_ses_1 = "`aux'*"
else                  local b05_ses_1 = "`aux'"
local se05_ses_1: di %12.3f _se[1.post#c.inten2005]
sum emr65 if e(sample) & year < 1997
local mean_ses_1: di %12.2fc `r(mean)'
local N_ses_1:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local Nmun_ses_1: di %12.0fc `r(ndistinct)'

* --- Col 2: Baseline + Trend × im_mun_1990 ---
reghdfe emr65 c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
	c.im_mun_1990#c.year ///
	[aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local b99_ses_2 = "`aux'***"
else if `t' >= 1.96  local b99_ses_2 = "`aux'**"
else if `t' >= 1.645 local b99_ses_2 = "`aux'*"
else                  local b99_ses_2 = "`aux'"
local se99_ses_2: di %12.3f _se[1.post#c.inten1999]
local aux: di %12.3f _b[1.post#c.inten2005]
local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
if      `t' >= 2.576 local b05_ses_2 = "`aux'***"
else if `t' >= 1.96  local b05_ses_2 = "`aux'**"
else if `t' >= 1.645 local b05_ses_2 = "`aux'*"
else                  local b05_ses_2 = "`aux'"
local se05_ses_2: di %12.3f _se[1.post#c.inten2005]
sum emr65 if e(sample) & year < 1997
local mean_ses_2: di %12.2fc `r(mean)'
local N_ses_2:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local Nmun_ses_2: di %12.0fc `r(ndistinct)'

* --- Col 3: Baseline + Trend × 1990 marginalization-index quintile (P&V 2023) ---
reghdfe emr65 c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
	i.im90_bin#c.year ///
	[aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local b99_ses_3 = "`aux'***"
else if `t' >= 1.96  local b99_ses_3 = "`aux'**"
else if `t' >= 1.645 local b99_ses_3 = "`aux'*"
else                  local b99_ses_3 = "`aux'"
local se99_ses_3: di %12.3f _se[1.post#c.inten1999]
local aux: di %12.3f _b[1.post#c.inten2005]
local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
if      `t' >= 2.576 local b05_ses_3 = "`aux'***"
else if `t' >= 1.96  local b05_ses_3 = "`aux'**"
else if `t' >= 1.645 local b05_ses_3 = "`aux'*"
else                  local b05_ses_3 = "`aux'"
local se05_ses_3: di %12.3f _se[1.post#c.inten2005]
sum emr65 if e(sample) & year < 1997
local mean_ses_3: di %12.2fc `r(mean)'
local N_ses_3:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local Nmun_ses_3: di %12.0fc `r(ndistinct)'

* --- Panel B: Females ---
foreach col in 1 2 3 {
	if `col' == 1 {
		reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 2 {
		reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			c.im_mun_1990#c.year ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else {
		reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			i.im90_bin#c.year ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local b99_ses_`col'_f = "`aux'***"
	else if `t' >= 1.96  local b99_ses_`col'_f = "`aux'**"
	else if `t' >= 1.645 local b99_ses_`col'_f = "`aux'*"
	else                  local b99_ses_`col'_f = "`aux'"
	local se99_ses_`col'_f: di %12.3f _se[1.post#c.inten1999]
	local aux: di %12.3f _b[1.post#c.inten2005]
	local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
	if      `t' >= 2.576 local b05_ses_`col'_f = "`aux'***"
	else if `t' >= 1.96  local b05_ses_`col'_f = "`aux'**"
	else if `t' >= 1.645 local b05_ses_`col'_f = "`aux'*"
	else                  local b05_ses_`col'_f = "`aux'"
	local se05_ses_`col'_f: di %12.3f _se[1.post#c.inten2005]
	sum emr65f if e(sample) & year < 1997
	local mean_ses_`col'_f: di %12.2fc `r(mean)'
	local N_ses_`col'_f:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local Nmun_ses_`col'_f: di %12.0fc `r(ndistinct)'
}

* --- Panel C: Males ---
foreach col in 1 2 3 {
	if `col' == 1 {
		reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 2 {
		reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			c.im_mun_1990#c.year ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else {
		reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			i.im90_bin#c.year ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local b99_ses_`col'_m = "`aux'***"
	else if `t' >= 1.96  local b99_ses_`col'_m = "`aux'**"
	else if `t' >= 1.645 local b99_ses_`col'_m = "`aux'*"
	else                  local b99_ses_`col'_m = "`aux'"
	local se99_ses_`col'_m: di %12.3f _se[1.post#c.inten1999]
	local aux: di %12.3f _b[1.post#c.inten2005]
	local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
	if      `t' >= 2.576 local b05_ses_`col'_m = "`aux'***"
	else if `t' >= 1.96  local b05_ses_`col'_m = "`aux'**"
	else if `t' >= 1.645 local b05_ses_`col'_m = "`aux'*"
	else                  local b05_ses_`col'_m = "`aux'"
	local se05_ses_`col'_m: di %12.3f _se[1.post#c.inten2005]
	sum emr65m if e(sample) & year < 1997
	local mean_ses_`col'_m: di %12.2fc `r(mean)'
	local N_ses_`col'_m:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local Nmun_ses_`col'_m: di %12.0fc `r(ndistinct)'
}

* --- Write table ---
{
	cap file close sm
	file open sm using "$tables/appendix/AT_ses_trend.tex", write replace
	file write sm "\begin{tabular}{lccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\ \toprule" _n
	* Panel A: Pooled
	file write sm "\underline{\textit{Panel A: Pooled}} \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_ses_1' & `b99_ses_2' & `b99_ses_3' \\ " _n
	file write sm " & (`se99_ses_1') & (`se99_ses_2') & (`se99_ses_3') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_ses_1' & `b05_ses_2' & `b05_ses_3' \\ " _n
	file write sm " & (`se05_ses_1') & (`se05_ses_2') & (`se05_ses_3') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_ses_1' & `mean_ses_2' & `mean_ses_3' \\ " _n
	file write sm "Obs & `N_ses_1' & `N_ses_2' & `N_ses_3' \\ " _n
	file write sm "No.\ Mun & `Nmun_ses_1' & `Nmun_ses_2' & `Nmun_ses_3' \\ " _n
	file write sm "  & & & \\ \midrule" _n
	* Panel B: Females
	file write sm "\underline{\textit{Panel B: Females}} \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_ses_1_f' & `b99_ses_2_f' & `b99_ses_3_f' \\ " _n
	file write sm " & (`se99_ses_1_f') & (`se99_ses_2_f') & (`se99_ses_3_f') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_ses_1_f' & `b05_ses_2_f' & `b05_ses_3_f' \\ " _n
	file write sm " & (`se05_ses_1_f') & (`se05_ses_2_f') & (`se05_ses_3_f') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_ses_1_f' & `mean_ses_2_f' & `mean_ses_3_f' \\ " _n
	file write sm "Obs & `N_ses_1_f' & `N_ses_2_f' & `N_ses_3_f' \\ " _n
	file write sm "No.\ Mun & `Nmun_ses_1_f' & `Nmun_ses_2_f' & `Nmun_ses_3_f' \\ " _n
	file write sm "  & & & \\ \midrule" _n
	* Panel C: Males
	file write sm "\underline{\textit{Panel C: Males}} \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_ses_1_m' & `b99_ses_2_m' & `b99_ses_3_m' \\ " _n
	file write sm " & (`se99_ses_1_m') & (`se99_ses_2_m') & (`se99_ses_3_m') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_ses_1_m' & `b05_ses_2_m' & `b05_ses_3_m' \\ " _n
	file write sm " & (`se05_ses_1_m') & (`se05_ses_2_m') & (`se05_ses_3_m') \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_ses_1_m' & `mean_ses_2_m' & `mean_ses_3_m' \\ " _n
	file write sm "Obs & `N_ses_1_m' & `N_ses_2_m' & `N_ses_3_m' \\ " _n
	file write sm "No.\ Mun & `Nmun_ses_1_m' & `Nmun_ses_2_m' & `Nmun_ses_3_m' \\ " _n
	file write sm "  & & & \\ " _n
	* Footer controls rows
	file write sm "Seguro Popular & Y & Y & Y \\ " _n
	file write sm "Weights & Y & Y & Y \\ " _n
	file write sm "Trend x Marg.\ Index (1990) & N & Y & N \\ " _n
	file write sm "Trend x Marg.\ Index Quintile (1990) & N & N & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\multicolumn{4}{l}{\footnotesize \textit{Notes:} All columns weighted by older-adult (65+) population and include} \\ " _n
	file write sm "\multicolumn{4}{l}{\footnotesize municipality and year fixed effects. Column (2) adds the interaction of the} \\ " _n
	file write sm "\multicolumn{4}{l}{\footnotesize 1990 CONAPO continuous marginalization index with a linear year trend.} \\ " _n
	file write sm "\multicolumn{4}{l}{\footnotesize Following Parker \& Vogl (2023), column (3) replaces it with quintile bins of} \\ " _n
	file write sm "\multicolumn{4}{l}{\footnotesize the 1990 marginalization index, each interacted with a linear year trend,} \\ " _n
	file write sm "\multicolumn{4}{l}{\footnotesize allowing baseline-SES trends to vary flexibly (robust to sparse individual} \\ " _n
	file write sm "\multicolumn{4}{l}{\footnotesize census components). Standard errors clustered at the municipality level.} \\ " _n
	file write sm "\end{tabular}"
	file close sm
}
di "Table exported to: $tables/appendix/AT_ses_trend.tex"


*============================================================
* APPENDIX FIGURE: AF_ses_trend
* Pooled event study (beta_k) across 3 SES trend specifications
* Series 1 (black circles):    Baseline (W+SP)
* Series 2 (red squares):      + Trend × im_mun_1990
* Series 3 (blue triangles):   + Trend × 1990 marg.-index quintile (P&V 2023)
* Output: $figures/appendix/AF_ses_trend.pdf
*============================================================

local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

{
* Spec 1: Baseline event study (W+SP) — pooled
reghdfe emr65 c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
	c.sp_intensity [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) ///
	vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
	if `pos' == 6 {
		local bes1_`pos'  = 0
		local sees1_`pos' = 0
	}
	else {
		local bes1_`pos'  = _b[`pos'.year_1995#c.inten1999]
		local sees1_`pos' = _se[`pos'.year_1995#c.inten1999]
	}
}

* Spec 2: + Trend × im_mun_1990
reghdfe emr65 c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
	c.sp_intensity c.im_mun_1990#c.year [aw=popover65_] if $sample_marg, ///
	a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
	if `pos' == 6 {
		local bes2_`pos'  = 0
		local sees2_`pos' = 0
	}
	else {
		local bes2_`pos'  = _b[`pos'.year_1995#c.inten1999]
		local sees2_`pos' = _se[`pos'.year_1995#c.inten1999]
	}
}

* Spec 3: + Trend × 1990 marginalization-index quintile (P&V 2023)
reghdfe emr65 c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
	c.sp_intensity ///
	i.im90_bin#c.year ///
	[aw=popover65_] if $sample_marg, a(cve_ent_mun_super) ///
	vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
	if `pos' == 6 {
		local bes3_`pos'  = 0
		local sees3_`pos' = 0
	}
	else {
		local bes3_`pos'  = _b[`pos'.year_1995#c.inten1999]
		local sees3_`pos' = _se[`pos'.year_1995#c.inten1999]
	}
}

* --- Plot ---
preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_1 = yr_pos - 0.18
gen xpos_2 = yr_pos
gen xpos_3 = yr_pos + 0.18
foreach s in 1 2 3 {
	gen b_s`s'  = .
	gen hi_s`s' = .
	gen lo_s`s' = .
}
forval pos = 1/16 {
	replace b_s1  = `bes1_`pos''                            if yr_pos == `pos'
	replace hi_s1 = `bes1_`pos'' + 1.96 * `sees1_`pos''    if yr_pos == `pos'
	replace lo_s1 = `bes1_`pos'' - 1.96 * `sees1_`pos''    if yr_pos == `pos'
	replace b_s2  = `bes2_`pos''                            if yr_pos == `pos'
	replace hi_s2 = `bes2_`pos'' + 1.96 * `sees2_`pos''    if yr_pos == `pos'
	replace lo_s2 = `bes2_`pos'' - 1.96 * `sees2_`pos''    if yr_pos == `pos'
	replace b_s3  = `bes3_`pos''                            if yr_pos == `pos'
	replace hi_s3 = `bes3_`pos'' + 1.96 * `sees3_`pos''    if yr_pos == `pos'
	replace lo_s3 = `bes3_`pos'' - 1.96 * `sees3_`pos''    if yr_pos == `pos'
}
twoway ///
	(rcap hi_s1 lo_s1 xpos_1, lcolor(black%60) lwidth(vthin)) ///
	(scatter b_s1 xpos_1, mcolor(black) msymbol(circle) msize(vsmall)) ///
	(rcap hi_s2 lo_s2 xpos_2, lcolor(red%60) lwidth(vthin)) ///
	(scatter b_s2 xpos_2, mcolor(red) msymbol(square) msize(vsmall)) ///
	(rcap hi_s3 lo_s3 xpos_3, lcolor(blue%60) lwidth(vthin)) ///
	(scatter b_s3 xpos_3, mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
	(line b_s1 xpos_1 if 1==0, lcolor(black) lpattern(solid) lwidth(thin) msymbol(circle) mcolor(black) msize(vsmall)) ///
	(line b_s2 xpos_2 if 1==0, lcolor(red) lpattern(dash) lwidth(thin) msymbol(square) mcolor(red) msize(vsmall)) ///
	(line b_s3 xpos_3 if 1==0, lcolor(blue%80) lpattern(shortdash_dot) lwidth(thin) msymbol(triangle) mcolor(blue%80) msize(vsmall)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(7 "Baseline (W+SP)" 8 "+ Trend x Marg. Index" 9 "+ Trend x Marg. Index Quintile") ///
		cols(1) size(medsmall) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/appendix/AF_ses_trend.pdf", as(pdf) replace
restore
}

* Clean up generated SES baseline variables
foreach v of varlist analf sprim ovsee ovsae vhac ovpt ovsde pl5000 {
	cap drop `v'_90
}
cap drop im90_bin


*============================================================
* APPENDIX TABLE: Age Sub-Group Mortality (Minor Comment 7)
* T2 col 4 specification: Weighted + Seguro Popular
* Columns: (1) 50-64, (2) 65+, (3) 65-69, (4) 70+
* Panels: Pooled, Females, Males
* Output: $tables/appendix/AT_age_subgroups.tex
*============================================================

* Construct 50-64 mortality rate and population weight
foreach sfx in "" "f" "m" {
	cap drop death5064`sfx' pop5064_`sfx' emr5064`sfx'
	gen death5064`sfx' = death50`sfx' - death65`sfx'
	gen pop5064_`sfx'  = popover50_`sfx' - popover65_`sfx'
	gen emr5064`sfx'   = death5064`sfx' * 1000 / pop5064_`sfx' if pop5064_`sfx' > 0
}

* Loop over panels and age groups
foreach pnl in p f m {
	if "`pnl'" == "p" local gsufx ""
	if "`pnl'" == "f" local gsufx "f"
	if "`pnl'" == "m" local gsufx "m"

	* Define outcome and weight for each age group
	local outcome_a5064 emr5064`gsufx'
	local outcome_a65   emr65`gsufx'
	local outcome_a6569 asr6569`gsufx'
	local outcome_a70   asrover70`gsufx'

	if "`pnl'" == "p" {
		local wvar_a5064 pop5064_
		local wvar_a65   popover65_
		local wvar_a6569 pop6569_
		local wvar_a70   popover70_
	}
	else {
		local wvar_a5064 pop5064_`gsufx'
		local wvar_a65   popover65_`gsufx'
		local wvar_a6569 pop6569_`gsufx'
		local wvar_a70   popover70_`gsufx'
	}

	foreach age in a5064 a65 a6569 a70 {
		reghdfe `outcome_`age'' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			[aw=`wvar_`age''] if $sample_marg, ///
			a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

		local aux: di %12.3f _b[1.post#c.inten1999]
		local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
		if      `t' >= 2.576 local b99_`pnl'_`age' = "`aux'***"
		else if `t' >= 1.96  local b99_`pnl'_`age' = "`aux'**"
		else if `t' >= 1.645 local b99_`pnl'_`age' = "`aux'*"
		else                  local b99_`pnl'_`age' = "`aux'"
		local se99_`pnl'_`age': di %12.3f _se[1.post#c.inten1999]

		local aux: di %12.3f _b[1.post#c.inten2005]
		local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
		if      `t' >= 2.576 local b05_`pnl'_`age' = "`aux'***"
		else if `t' >= 1.96  local b05_`pnl'_`age' = "`aux'**"
		else if `t' >= 1.645 local b05_`pnl'_`age' = "`aux'*"
		else                  local b05_`pnl'_`age' = "`aux'"
		local se05_`pnl'_`age': di %12.3f _se[1.post#c.inten2005]

		sum `outcome_`age'' if e(sample) & post == 2
		local mean_`pnl'_`age': di %12.2fc `r(mean)'
		local N_`pnl'_`age':    di %12.0fc `e(N)'
	}
}

* No. Mun from pooled 65+ regression (same sample across cols 2-4; col 1 may differ slightly)
* No. Mun from pooled 65+ regression
reghdfe emr65 c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
	[aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
distinct cve_ent_mun_super if e(sample)
local Nmun_AT_age: di %12.0fc `r(ndistinct)'

{
	cap file close sm
	file open sm using "$tables/appendix/AT_age_subgroups.tex", write replace
	file write sm "\begin{tabular}{lcccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ " _n
	file write sm "& \multicolumn{1}{c}{Ages 50--64} & \multicolumn{1}{c}{Ages 65+} & \multicolumn{1}{c}{Ages 65--69} & \multicolumn{1}{c}{Ages 70+} \\ \toprule" _n

	file write sm "\underline{\textit{Panel A: Pooled}} \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_p_a5064' & `b99_p_a65' & `b99_p_a6569' & `b99_p_a70' \\ " _n
	file write sm " & (`se99_p_a5064') & (`se99_p_a65') & (`se99_p_a6569') & (`se99_p_a70') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_p_a5064' & `b05_p_a65' & `b05_p_a6569' & `b05_p_a70' \\ " _n
	file write sm " & (`se05_p_a5064') & (`se05_p_a65') & (`se05_p_a6569') & (`se05_p_a70') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_p_a5064' & `mean_p_a65' & `mean_p_a6569' & `mean_p_a70' \\ " _n
	file write sm "Obs & `N_p_a5064' & `N_p_a65' & `N_p_a6569' & `N_p_a70' \\ " _n
	file write sm "  & & & & \\ " _n

	file write sm "\underline{\textit{Panel B: Females}} \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_f_a5064' & `b99_f_a65' & `b99_f_a6569' & `b99_f_a70' \\ " _n
	file write sm " & (`se99_f_a5064') & (`se99_f_a65') & (`se99_f_a6569') & (`se99_f_a70') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_f_a5064' & `b05_f_a65' & `b05_f_a6569' & `b05_f_a70' \\ " _n
	file write sm " & (`se05_f_a5064') & (`se05_f_a65') & (`se05_f_a6569') & (`se05_f_a70') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_f_a5064' & `mean_f_a65' & `mean_f_a6569' & `mean_f_a70' \\ " _n
	file write sm "Obs & `N_f_a5064' & `N_f_a65' & `N_f_a6569' & `N_f_a70' \\ " _n
	file write sm "  & & & & \\ " _n

	file write sm "\underline{\textit{Panel C: Males}} \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_m_a5064' & `b99_m_a65' & `b99_m_a6569' & `b99_m_a70' \\ " _n
	file write sm " & (`se99_m_a5064') & (`se99_m_a65') & (`se99_m_a6569') & (`se99_m_a70') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_m_a5064' & `b05_m_a65' & `b05_m_a6569' & `b05_m_a70' \\ " _n
	file write sm " & (`se05_m_a5064') & (`se05_m_a65') & (`se05_m_a6569') & (`se05_m_a70') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_m_a5064' & `mean_m_a65' & `mean_m_a6569' & `mean_m_a70' \\ " _n
	file write sm "Obs & `N_m_a5064' & `N_m_a65' & `N_m_a6569' & `N_m_a70' \\ " _n
	file write sm "  & & & & \\ " _n

	file write sm "No.\ Mun & \multicolumn{4}{c}{`Nmun_AT_age'} \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Seguro Popular & Y & Y & Y & Y \\ " _n
	file write sm "Weights & Y & Y & Y & Y \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\multicolumn{5}{l}{\footnotesize \textit{Notes:} T2 col.\ (4) specification throughout: weighted by age-group population,} \\ " _n
	file write sm "\multicolumn{5}{l}{\footnotesize Seguro Popular controls, municipality and year fixed effects, standard errors} \\ " _n
	file write sm "\multicolumn{5}{l}{\footnotesize clustered at the municipality level. Column (1) outcome is constructed as} \\ " _n
	file write sm "\multicolumn{5}{l}{\footnotesize (deaths 50--64) / (population 50--64) x 1,000. Columns (3)--(4) decompose} \\ " _n
	file write sm "\multicolumn{5}{l}{\footnotesize the 65+ result into the two age sub-groups available in the vital statistics.} \\ " _n
	file write sm "\end{tabular}"
	file close sm
}
di "Table exported to: $tables/appendix/AT_age_subgroups.tex"

cap drop death5064 death5064f death5064m pop5064_ pop5064_f pop5064_m emr5064 emr5064f emr5064m

