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
	global codes "C:\Users\FELIPEME\Documents\projects\progresa_mortality\codes\"
	global tables  "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\tables"
	global figures "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\figures"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}

 if c(username)=="root" {
	global data "/home/user/progresa_mortality/data/"
	global codes "/home/user/progresa_mortality/codes/"
	global tables "/home/user/progresa_mortality/tables"
	global figures "/home/user/progresa_mortality/figures"
	global deaths "/home/user/progresa_mortality/data/"
	global iter "/home/user/progresa_mortality/data/"
	global SP "/home/user/progresa_mortality/data/"
}

global sample_marg = "(gm_mun_1990==4|gm_mun_1990==5)"
*** BR phase-in sample: which start-year municipalities count as BR?
***   "1998_1999" : strict — only 1998 and 1999 entrants (current default, ~1,422 mun)
***   "1997_1999" : inclusive — adds 1997 entrants (~1,961 mun, matches BR reported N)
	global br_phase "1998_1999"
	*global br_phase "1997_1999"
	if "$br_phase" == "1997_1999" {
		global sample_br = "inrange(inten_start_year,1997,1999)"
	}
	else {
		global sample_br = "(inten_start_year==1998|inten_start_year==1999)"
	}


 *	Interact with one post-dummy=1 - intensity99*post and one for intensity05*post. [MAY 2025]
	use "$data/aamr_regression_municipality_gender_tb.dta", clear

*** Build inten1999/inten2005 directly from intensity_new (this file's own
*** panel), instead of merging the static $data/inten1999.dta /
*** inten2005.dta files. Those two files are NOT produced anywhere in the
*** current 00 -> 01 -> 02 pipeline -- they were built once by the
*** archived codes/archive/aamr_011326.do (keep if year==1999/2005; gen
*** inten1999/inten2005 = intensity_new) and never regenerated since. That
*** means the $benef_source switch in 01_mortality_data.do (mixed vs.
*** fase) changes intensity_new but was SILENTLY NOT propagating into the
*** inten1999/inten2005 used in the main regressions below, which is a
*** distinct bug from the sum-vs-snapshot construction question -- fixing
*** it here guarantees inten1999/inten2005 always reflect whichever
*** $benef_source was active when 01_mortality_data.do last ran. Same
*** snapshot-at-a-single-year definition as before (inten1999 =
*** intensity_new at year==1999), just computed fresh instead of merged
*** from a possibly stale file.
	cap drop inten1999 inten2005
	g aux = intensity_new if year==1999
	bys cve_ent_mun_super: egen inten1999 = min(aux)
	drop aux
	g aux = intensity_new if year==2005
	bys cve_ent_mun_super: egen inten2005 = min(aux)
	drop aux
	count if missing(inten1999) | missing(inten2005)
	di "`r(N)' obs missing inten1999/inten2005 after rebuilding from intensity_new"

*============================================================
* INTENSITY CONSTRUCTION COMPARISON: inten1999/inten2005 above are the
* MIXED / SNAPSHOT construction -- FASE for 1997, then the newProg_98_16
* admin file's beneficiary count taken directly (no summing) for 1998 on.
* This is a point-in-time headcount: it can rise OR fall year-to-year,
* since it reflects who is CURRENTLY enrolled, not who has EVER been
* enrolled (newProg_98_16 does not carry stable household IDs across
* years, so a household that enters and later exits cannot be tracked).
*
* A second, genuinely CUMULATIVE construction (inten1999_fase/
* inten2005_fase -- Parker & Vogl's own method, a running SUM of annual
* FASE beneficiary counts) is built later in this file, right before
* AT_pv_r2_benefsource (~line 4190), and AT_intensity_construction_
* comparison (built immediately after it) compares the two. FASE is the
* only source we have that is genuinely an annual FLOW, so it is the
* only source summing is valid for -- summing newProg_98_16 year over
* year (attempted in an earlier version of this file, as "inten*_summix")
* double-counts continuing beneficiaries and was removed.
*
* A third leg previously merged in archived, no-longer-regenerated static
* files ($data/inten1999.dta/inten2005.dta) -- removed once satisfied it
* tracked the mixed/snapshot construction above exactly (corr = 1.000).
*============================================================

	gen post=.
	replace post=2 if year <1997 & year >1990 & year!=.
	replace post=1 if year >=1997 & year <2007 & year!=.

	lab def post 1"1997-2006" 2"1991-1996"
	lab val post post

* sp_intensity is Seguro Popular cumulative coverage, built in
* 00.programs_beneficiaries_recoded.do from the same crosswalk/HH pipeline
* as Progresa's intensity_new, and carried straight through by
* 01_mortality_data.do -- no merge needed here. A standalone
* $data/SP_2001_2018.dta series was previously merged in alongside it for
* comparison (AT_sp_comparison), confirmed identical (corr = R² = 1.000 on
* the HM, year>=2001 sample), and removed.
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
	file open sm using "$tables/T1_descriptives.tex", write replace
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

* Preferred version: genuine dual y-axis (mortality rate on the left,
* Progresa penetration on the right). This is valid, standard twoway
* syntax, but yaxis()/axis() invoke Stata's object-oriented graph engine
* (axis.class / twowaygraph_g.class); on some Stata installs/consoles
* that engine is broken or incomplete and errors with "Super invalid
* member variable identifier" / "class member function not found"
* regardless of the calling syntax. cap noisily lets the script fall
* back to a single-axis version instead of halting the whole do-file.
cap noisily twoway (line emr65  year, lcolor(black) lpattern(solid)         yaxis(1)) ///
       (line emr65f year, lcolor(red)   lpattern(dash)          yaxis(1)) ///
       (line emr65m year, lcolor(blue)  lpattern(shortdash_dot) yaxis(1)) ///
       (line intensity_new_per year, lcolor(orange) lpattern(longdash) yaxis(2)), ///
	ytitle("Mortality Rate (65+ per 1000)", axis(1)) ///
	ytitle("Progresa Penetration (%)", axis(2)) ///
	xtitle("Year") xline(1997, lpattern(dash) lcolor(gs10)) ///
	legend(order(1 "All" 2 "Female" 3 "Male" 4 "Intensity (right axis)") ///
	cols(4) size(medsmall) position(6) ring(1)) ///
	graphregion(fcolor(white))
if _rc {
	di as error "Dual y-axis graph failed (rc=`_rc'), likely a broken axis.class/twowaygraph_g.class on this Stata install -- falling back to a single-axis version with Progresa penetration rescaled onto the mortality-rate axis."
	summ emr65 emr65f emr65m, meanonly
	local mrt_max = r(max)
	summ intensity_new_per, meanonly
	local pen_max = r(max)
	local pen_scale = `mrt_max' / `pen_max'
	g intensity_new_scaled = intensity_new_per * `pen_scale'
	local pen_scale_lbl : di %4.2f `pen_scale'

	twoway (line emr65  year, lcolor(black) lpattern(solid)) ///
	       (line emr65f year, lcolor(red)   lpattern(dash)) ///
	       (line emr65m year, lcolor(blue)  lpattern(shortdash_dot)) ///
	       (line intensity_new_scaled year, lcolor(orange) lpattern(longdash)), ///
		ytitle("Mortality Rate (65+ per 1000)") ///
		xtitle("Year") xline(1997, lpattern(dash) lcolor(gs10)) ///
		legend(order(1 "All" 2 "Female" 3 "Male" 4 "Intensity (rescaled x`pen_scale_lbl', see notes)") ///
		cols(4) size(medsmall) position(6) ring(1)) ///
		graphregion(fcolor(white))
}
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
* Exported as three separate single-series panels (Figure_2_pooled.pdf,
* Figure_2_female.pdf, Figure_2_male.pdf) rather than one three-series
* overlay -- with three point+CI series sharing the same year axis, the
* combined graph was too dense to read. The three panels are combined
* side by side via \subfigure in figures.tex, keeping the same colors/
* symbols (pooled=black circle, female=red square, male=blue triangle)
* used previously so the panels remain visually consistent with each other.
*============================================================
{
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
foreach grp in w f m {
	if "`grp'" == "w" {
		local outcome emr65
		local wvar   popover65_
		local gcolor black
		local gsym   circle
		local gname  pooled
	}
	else if "`grp'" == "f" {
		local outcome emr65f
		local wvar   popover65_f
		local gcolor red
		local gsym   square
		local gname  female
	}
	else {
		local outcome emr65m
		local wvar   popover65_m
		local gcolor blue
		local gsym   triangle
		local gname  male
	}

	reghdfe `outcome' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
		c.sp_intensity [aw=`wvar'] if $sample_marg, a(cve_ent_mun_super) ///
		vce(cluster cve_ent_mun_super)

	forval pos = 1/16 {
		if `pos' == 6 {
			local b_`pos'  = 0
			local se_`pos' = 0
			local th_`grp'_6    = 0
			local seth_`grp'_6  = 0
		}
		else {
			local b_`pos'  = _b[`pos'.year_1995#c.inten1999]
			local se_`pos' = _se[`pos'.year_1995#c.inten1999]
			* th_`grp'_`pos'/seth_`grp'_`pos' (Intensity_2005 x year
			* coefficients) are consumed by the AF_beta1_sex figure block
			* right below this one -- kept per-group (unlike b_/se_ above,
			* which only need to survive one iteration since each group is
			* exported to its own file) since AF_beta1_sex plots all three
			* groups together after this loop finishes.
			local th_`grp'_`pos'   = _b[`pos'.year_1995#c.inten2005]
			local seth_`grp'_`pos' = _se[`pos'.year_1995#c.inten2005]
		}
	}

	preserve
	clear
	set obs 16
	gen yr_pos = _n
	gen b  = .
	gen hi = .
	gen lo = .
	forval pos = 1/16 {
		replace b  = `b_`pos''                          if yr_pos == `pos'
		replace hi = `b_`pos'' + 1.96 * `se_`pos'' if yr_pos == `pos'
		replace lo = `b_`pos'' - 1.96 * `se_`pos'' if yr_pos == `pos'
	}
	twoway ///
		(rcap hi lo yr_pos, ///
			lcolor(`gcolor'%60) lwidth(vthin)) ///
		(scatter b yr_pos, ///
			mcolor(`gcolor') msymbol(`gsym') msize(vsmall)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
		ylabel(, grid gmin gmax labsize(small)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))
	graph export "$figures/Figure_2_`gname'.pdf", as(pdf) replace
	restore
}
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
		lcolor(black%60) lwidth(vthin) lpattern(solid)) ///
	(scatter th_w xpos_w, ///
		mcolor(black) msymbol(circle) msize(vsmall)) ///
	(rcap thi_f tlo_f xpos_f, ///
		lcolor(red%60) lwidth(vthin) lpattern(solid)) ///
	(scatter th_f xpos_f, ///
		mcolor(red) msymbol(square) msize(vsmall)) ///
	(rcap thi_m tlo_m xpos_m, ///
		lcolor(blue%60) lwidth(vthin) lpattern(solid)) ///
	(scatter th_m xpos_m, ///
		mcolor(blue%80) msymbol(triangle) msize(vsmall)) ///
	(line th_w xpos_w if 1==0, lcolor(black) lpattern(solid) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)) ///
	(line th_f xpos_f if 1==0, lcolor(red) lpattern(solid) lwidth(thin) mcolor(red) msymbol(square) msize(vsmall)) ///
	(line th_m xpos_m if 1==0, lcolor(blue%80) lpattern(solid) lwidth(thin) mcolor(blue%80) msymbol(triangle) msize(vsmall)), ///
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
* TABLE T2_b: Baseline + SES Trend Robustness + Age Subgroups
* Col 1: Baseline (W+SP, emr65)           = T2 col 4
* Col 2: + SES Trend × im_mun_1990 (cont) = AT_ses_trend col 2
* Col 3: Ages 65-69 (baseline W+SP spec)  = AT_age_subgroups col 3
* Col 4: Ages 70+   (baseline W+SP spec)  = AT_age_subgroups col 4
* Output: $tables/T2_b_mortality.tex
*============================================================

foreach pnl in p f m {
	if "`pnl'" == "p" {
		local out65   emr65
		local out6569 asr6569
		local out70   asrover70
		local wt65    popover65_
		local wt6569  pop6569_
		local wt70    popover70_
	}
	else if "`pnl'" == "f" {
		local out65   emr65f
		local out6569 asr6569f
		local out70   asrover70f
		local wt65    popover65_f
		local wt6569  pop6569_f
		local wt70    popover70_f
	}
	else {
		local out65   emr65m
		local out6569 asr6569m
		local out70   asrover70m
		local wt65    popover65_m
		local wt6569  pop6569_m
		local wt70    popover70_m
	}

	foreach col in 1 2 3 4 {
		if `col' == 1 {
			reghdfe `out65' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				[aw=`wt65'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else if `col' == 2 {
			reghdfe `out65' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				c.im_mun_1990#c.year ///
				[aw=`wt65'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else if `col' == 3 {
			reghdfe `out6569' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				[aw=`wt6569'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}
		else {
			reghdfe `out70' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
				[aw=`wt70'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		}

		local aux: di %12.3f _b[1.post#c.inten1999]
		local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
		if      `t' >= 2.576 local b99_2b_`pnl'_`col' = "`aux'***"
		else if `t' >= 1.96  local b99_2b_`pnl'_`col' = "`aux'**"
		else if `t' >= 1.645 local b99_2b_`pnl'_`col' = "`aux'*"
		else                  local b99_2b_`pnl'_`col' = "`aux'"
		local se99_2b_`pnl'_`col': di %12.3f _se[1.post#c.inten1999]
		local aux: di %12.3f _b[1.post#c.inten2005]
		local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
		if      `t' >= 2.576 local b05_2b_`pnl'_`col' = "`aux'***"
		else if `t' >= 1.96  local b05_2b_`pnl'_`col' = "`aux'**"
		else if `t' >= 1.645 local b05_2b_`pnl'_`col' = "`aux'*"
		else                  local b05_2b_`pnl'_`col' = "`aux'"
		local se05_2b_`pnl'_`col': di %12.3f _se[1.post#c.inten2005]

		if `col' <= 2 {
			sum `out65' if e(sample) & year < 1997
		}
		else if `col' == 3 {
			sum `out6569' if e(sample) & year < 1997
		}
		else {
			sum `out70' if e(sample) & year < 1997
		}
		local mean_2b_`pnl'_`col': di %12.2fc `r(mean)'
		local N_2b_`pnl'_`col':    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local Nmun_2b_`pnl'_`col': di %12.0fc `r(ndistinct)'
	}
}

quietly sum inten1999 if $sample_marg & year == 1996
local meanI99_2b: di %6.1f r(mean) * 100

{
	cap file close sm
	file open sm using "$tables/T2_b_mortality.tex", write replace
	file write sm "\begin{tabular}{lcccc} \hline \hline" _n
	file write sm "& \multicolumn{2}{c}{\textit{Ages 65+}} & \multicolumn{1}{c}{\textit{Ages 65--69}} & \multicolumn{1}{c}{\textit{Ages 70+}} \\ \cmidrule(lr){2-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n

	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_2b_p_1' & `b99_2b_p_2' & `b99_2b_p_3' & `b99_2b_p_4' \\ " _n
	file write sm " & (`se99_2b_p_1') & (`se99_2b_p_2') & (`se99_2b_p_3') & (`se99_2b_p_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_2b_p_1' & `b05_2b_p_2' & `b05_2b_p_3' & `b05_2b_p_4' \\ " _n
	file write sm " & (`se05_2b_p_1') & (`se05_2b_p_2') & (`se05_2b_p_3') & (`se05_2b_p_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_2b_p_1' & `mean_2b_p_2' & `mean_2b_p_3' & `mean_2b_p_4' \\ " _n
	file write sm "Obs & `N_2b_p_1' & `N_2b_p_2' & `N_2b_p_3' & `N_2b_p_4' \\ " _n
	file write sm "  & & & & \\ " _n

	file write sm "\underline{\textit{Panel B: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_2b_f_1' & `b99_2b_f_2' & `b99_2b_f_3' & `b99_2b_f_4' \\ " _n
	file write sm " & (`se99_2b_f_1') & (`se99_2b_f_2') & (`se99_2b_f_3') & (`se99_2b_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_2b_f_1' & `b05_2b_f_2' & `b05_2b_f_3' & `b05_2b_f_4' \\ " _n
	file write sm " & (`se05_2b_f_1') & (`se05_2b_f_2') & (`se05_2b_f_3') & (`se05_2b_f_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_2b_f_1' & `mean_2b_f_2' & `mean_2b_f_3' & `mean_2b_f_4' \\ " _n
	file write sm "Obs & `N_2b_f_1' & `N_2b_f_2' & `N_2b_f_3' & `N_2b_f_4' \\ " _n
	file write sm "  & & & & \\ " _n

	file write sm "\underline{\textit{Panel C: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_2b_m_1' & `b99_2b_m_2' & `b99_2b_m_3' & `b99_2b_m_4' \\ " _n
	file write sm " & (`se99_2b_m_1') & (`se99_2b_m_2') & (`se99_2b_m_3') & (`se99_2b_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_2b_m_1' & `b05_2b_m_2' & `b05_2b_m_3' & `b05_2b_m_4' \\ " _n
	file write sm " & (`se05_2b_m_1') & (`se05_2b_m_2') & (`se05_2b_m_3') & (`se05_2b_m_4') \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_2b_m_1' & `mean_2b_m_2' & `mean_2b_m_3' & `mean_2b_m_4' \\ " _n
	file write sm "Obs & `N_2b_m_1' & `N_2b_m_2' & `N_2b_m_3' & `N_2b_m_4' \\ " _n
	file write sm "  & & & & \\ " _n

	file write sm "No.\ Mun & `Nmun_2b_p_1' & `Nmun_2b_p_2' & `Nmun_2b_p_3' & `Nmun_2b_p_4' \\ " _n
	file write sm "  & & & & \\ " _n
	file write sm "SES Trend (Cont.\ Index) & N & Y & N & N \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_2b' & `meanI99_2b' & `meanI99_2b' & `meanI99_2b' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
di "Table exported to: $tables/T2_b_mortality.tex"

*============================================================
* SLIDE TABLE: T2_b_mortality — Pooled, Ages 65-69 and 70+ only
* Same as T2_b but Panel A (Pooled) and cols 3-4 (Ages 65-69 and 70+).
* Output: $tables/T2_slide_age.tex
*============================================================
{
	cap file close sm
	file open sm using "$tables/T2_slide_age.tex", write replace
	file write sm "\begin{tabular}{lcc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{\textit{Ages 65--69}} & \multicolumn{1}{c}{\textit{Ages 70+}} \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} \\ \toprule" _n
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_2b_p_3' & `b99_2b_p_4' \\ " _n
	file write sm " & (`se99_2b_p_3') & (`se99_2b_p_4') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_2b_p_3' & `b05_2b_p_4' \\ " _n
	file write sm " & (`se05_2b_p_3') & (`se05_2b_p_4') \\ " _n
	file write sm "  & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_2b_p_3' & `mean_2b_p_4' \\ " _n
	file write sm "Obs & `N_2b_p_3' & `N_2b_p_4' \\ " _n
	file write sm "  & & \\ " _n
	file write sm "No.\ Mun & `Nmun_2b_p_3' & `Nmun_2b_p_4' \\ " _n
	file write sm "  & & \\ " _n
	file write sm "SES Trend (Cont.\ Index) & N & N \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_2b' & `meanI99_2b' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
di "Table exported to: $tables/T2_slide_age.tex"


*============================================================
* APPENDIX FIGURES:
*============================================================


*============================================================
* FIGURE 1 (Appendix): Elder Mortality Trends + PROGRESA penetration
*   — Highly Marginalized (solid) vs Non-Marginalized (dashed)
*   Mortality colored: All=black, Female=red, Male=blue
*   Intensity (right axis): marg solid, non-marg dashed
*============================================================

{
* Collapse marginalized into tempfile
tempfile marg_trend
preserve
keep if $sample_marg
collapse (mean) emr65_marg=emr65 emr65f_marg=emr65f emr65m_marg=emr65m ///
	inten_marg=intensity_new_per [aw=popover65_], by(year)
save `marg_trend'
restore

* Collapse non-marginalized, merge, and plot
preserve
keep if !(gm_mun_1990==4 | gm_mun_1990==5)
drop if gm_mun_1990==.
collapse (mean) emr65_nm=emr65 emr65f_nm=emr65f emr65m_nm=emr65m ///
	inten_nm=intensity_new_per [aw=popover65_], by(year)

merge 1:1 year using `marg_trend', nogen

* See the analogous fallback in the FIGURE 1a block above: yaxis()/axis()
* invoke Stata's object-oriented graph engine (axis.class /
* twowaygraph_g.class), which can be broken/incomplete on some Stata
* installs regardless of calling syntax. cap noisily + a single-axis
* fallback keeps the script running past this figure either way.
cap noisily twoway (line emr65_marg  year, lcolor(black) lpattern(solid) yaxis(1)) ///
       (line emr65f_marg year, lcolor(red)   lpattern(solid) yaxis(1)) ///
       (line emr65m_marg year, lcolor(blue)  lpattern(solid) yaxis(1)) ///
       (line emr65_nm    year, lcolor(black) lpattern(dash)  yaxis(1)) ///
       (line emr65f_nm   year, lcolor(red)   lpattern(dash)  yaxis(1)) ///
       (line emr65m_nm   year, lcolor(blue)  lpattern(dash)  yaxis(1)) ///
       (line inten_marg  year, lcolor(orange) lpattern(solid) yaxis(2)) ///
       (line inten_nm    year, lcolor(orange) lpattern(dash)  yaxis(2)), ///
	ytitle("Mortality Rate (65+ per 1,000)", axis(1)) ///
	ytitle("Progresa Penetration (%)", axis(2)) ///
	xtitle("Year") xline(1997, lpattern(dash) lcolor(gs10)) ///
	legend(order(1 "Marg: All" 2 "Marg: Female" 3 "Marg: Male" ///
	             4 "Non-Marg: All" 5 "Non-Marg: Female" 6 "Non-Marg: Male" ///
	             7 "Intensity, Marg (right axis)" 8 "Intensity, Non-Marg (right axis)") ///
	cols(3) size(small) position(6) ring(1)) ///
	graphregion(fcolor(white))
if _rc {
	di as error "Dual y-axis graph failed (rc=`_rc'), likely a broken axis.class/twowaygraph_g.class on this Stata install -- falling back to a single-axis version with Progresa penetration rescaled onto the mortality-rate axis."
	summ emr65_marg emr65f_marg emr65m_marg emr65_nm emr65f_nm emr65m_nm, meanonly
	local mrt_max = r(max)
	summ inten_marg inten_nm, meanonly
	local pen_max = r(max)
	local pen_scale = `mrt_max' / `pen_max'
	g inten_marg_scaled = inten_marg * `pen_scale'
	g inten_nm_scaled   = inten_nm   * `pen_scale'
	local pen_scale_lbl : di %4.2f `pen_scale'

	twoway (line emr65_marg  year, lcolor(black) lpattern(solid)) ///
	       (line emr65f_marg year, lcolor(red)   lpattern(solid)) ///
	       (line emr65m_marg year, lcolor(blue)  lpattern(solid)) ///
	       (line emr65_nm    year, lcolor(black) lpattern(dash)) ///
	       (line emr65f_nm   year, lcolor(red)   lpattern(dash)) ///
	       (line emr65m_nm   year, lcolor(blue)  lpattern(dash)) ///
	       (line inten_marg_scaled year, lcolor(orange) lpattern(solid)) ///
	       (line inten_nm_scaled   year, lcolor(orange) lpattern(dash)), ///
		ytitle("Mortality Rate (65+ per 1,000)") ///
		xtitle("Year") xline(1997, lpattern(dash) lcolor(gs10)) ///
		legend(order(1 "Marg: All" 2 "Marg: Female" 3 "Marg: Male" ///
		             4 "Non-Marg: All" 5 "Non-Marg: Female" 6 "Non-Marg: Male" ///
		             7 "Intensity, Marg (rescaled x`pen_scale_lbl')" 8 "Intensity, Non-Marg (rescaled x`pen_scale_lbl')") ///
		cols(3) size(small) position(6) ring(1)) ///
		graphregion(fcolor(white))
}
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
	local twoway_cmd "`twoway_cmd', yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) xlabel(`yr_labels_cod', labsize(small) angle(45) labcolor(black)) xscale(`xscale_range') xtitle("") ytitle("Mortality Rate, 65+ (per 1,000)", size(medsmall)) ylabel(`yaxis_range', grid gmin gmax labsize(small)) legend(order(`legend_nums') `legend_labels' cols(3) size(medsmall) position(6) ring(1) region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) graphregion(color(white)) plotregion(margin(l=1 r=1))"
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
gen xpos_uw = yr_pos - 0.18
gen xpos_wt = yr_pos + 0.18
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
	(rcap thi_uw tlo_uw xpos_uw, ///
		lcolor(black%60) lwidth(vthin) lpattern(dash)) ///
	(scatter th_uw xpos_uw, ///
		mcolor(black) msymbol(triangle) msize(vsmall)) ///
	(rcap thi_wt tlo_wt xpos_wt, ///
		lcolor(black%60) lwidth(vthin) lpattern(solid)) ///
	(scatter th_wt xpos_wt, ///
		mcolor(black) msymbol(circle) msize(vsmall)) ///
	(line th_uw xpos_uw if 1==0, lcolor(black) lpattern(dash) lwidth(thin) mcolor(black) msymbol(triangle) msize(vsmall)) ///
	(line th_wt xpos_wt if 1==0, lcolor(black) lpattern(solid) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(5 "Unweighted" 6 "Weighted") ///
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

/*
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
		distinct cve_ent_mun_super if e(sample)
		local Nmun_`grp'_`cod': di %12.0fc `r(ndistinct)'
	}
}

* Mean Intensity 1999 for AT1_cod -- HM sample, displayed as %
quietly sum inten1999 if $sample_marg & year == 1996
local meanI99_AT1cod: di %6.1f r(mean) * 100

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
gen _br        = ($sample_br)

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
	file write sm "No.\ Mun & `Nmun_w_tb_cancer' & `Nmun_w_tb_diab' & `Nmun_w_tb_illdef' & `Nmun_w_tb_resp' & `Nmun_w_tb_card' & `Nmun_w_tb_infect' & `Nmun_w_tb_nutri' & `Nmun_w_tb_accid' & `Nmun_w_tb_other' \\ " _n
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
	file write sm "No.\ Mun & `Nmun_f_tb_cancer' & `Nmun_f_tb_diab' & `Nmun_f_tb_illdef' & `Nmun_f_tb_resp' & `Nmun_f_tb_card' & `Nmun_f_tb_infect' & `Nmun_f_tb_nutri' & `Nmun_f_tb_accid' & `Nmun_f_tb_other' \\ " _n
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
	file write sm "No.\ Mun & `Nmun_m_tb_cancer' & `Nmun_m_tb_diab' & `Nmun_m_tb_illdef' & `Nmun_m_tb_resp' & `Nmun_m_tb_card' & `Nmun_m_tb_infect' & `Nmun_m_tb_nutri' & `Nmun_m_tb_accid' & `Nmun_m_tb_other' \\ " _n
	file write sm "  & & & & & & & & & \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_AT1cod' & `meanI99_AT1cod' & `meanI99_AT1cod' & `meanI99_AT1cod' & `meanI99_AT1cod' & `meanI99_AT1cod' & `meanI99_AT1cod' & `meanI99_AT1cod' & `meanI99_AT1cod' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
*/
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
	
	* col 4: levels, weighted + Seguro Popular
	reghdfe `outcome' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
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
	* col 5: log mortality rate, weighted + Seguro Popular; coef x100 = approx % change in mortality rate
	reghdfe `loutcome' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
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
	* col 6: Poisson, weighted + Seguro Popular; coef = (exp(b)-1)*100 = % change in death counts
	ppmlhdfe `doutcome' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
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
	* panel  b: lag2, UW  (BR regression window held fixed at 1992-2002; the
	*           $window switch changes only the balanced-panel sample via 01_)
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
	file write tbl "& \multicolumn{1}{c}{Unweighted} & \multicolumn{1}{c}{Weighted} & \multicolumn{1}{c}{Unweighted} & \multicolumn{1}{c}{Weighted} \\ " _n
	file write tbl "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
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

di "BR size cutoffs (older adults 65+): p10=`p10_br', p25=`p25_br' (sample: window $window, BR regression 1992-2002)"

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
    if inrange(year, 1992, 2002) & $sample_br & pop_mun_br > `p10_br', ///
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
    if inrange(year, 1992, 2002) & $sample_br & pop_mun_br > `p25_br', ///
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

* Mean Intensity 1999 by sample (one obs per mun at year==1996)
quietly sum inten1999 if $sample_br & year == 1996
local meanI99_AT5_full: di %6.1f r(mean) * 100
quietly sum inten1999 if $sample_br & year == 1996 & pop_mun_br > `p10_br'
local meanI99_AT5_2: di %6.1f r(mean) * 100
quietly sum inten1999 if $sample_br & year == 1996 & pop_mun_br > `p25_br'
local meanI99_AT5_3: di %6.1f r(mean) * 100

{
    cap file close sm
    file open sm using "$tables/appendix/AT5_BR_trimming.tex", write replace
    file write sm "\begin{tabular}{lccccc} \hline \hline" _n
    file write sm "& \multicolumn{1}{c}{} & \multicolumn{2}{c}{\textit{Full Sample}} & \multicolumn{2}{c}{\textit{Progressive Trimming}} \\ \cmidrule(lr){3-4} \cmidrule(lr){5-6}" _n
    file write sm "& \multicolumn{1}{c}{BR Original} & \multicolumn{1}{c}{Replication (UW)} & \multicolumn{1}{c}{Replication (W)} & \multicolumn{1}{c}{Ex.\ bottom 10\%} & \multicolumn{1}{c}{Ex.\ bottom 25\%} \\ " _n
    file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}" _n
    file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\ \toprule " _n
    file write sm "\textit{2-yr lagged Intensity} & -6.370*** & `bBR2_2_p' & `bBR2_3_p' & `bAT5_2' & `bAT5_3' \\ " _n
    file write sm " & (1.040) & (`seBR2_2_p') & (`seBR2_3_p') & (`seAT5_2') & (`seAT5_3') \\ " _n
    file write sm "  & & & & & \\ " _n
    file write sm "Mean 1996 & 47.5 & `meanBR_2_p' & `meanBR_3_p' & `meanAT5_2' & `meanAT5_3' \\ " _n
    file write sm "Obs & 21,571 & `NBR_2_p' & `NBR_3_p' & `NAT5_2' & `NAT5_3' \\ " _n
    file write sm "No.\ Mun & 1,961 & `NmunBR_2_p' & `NmunBR_3_p' & `NmunAT5_2' & `NmunAT5_3' \\ " _n
    file write sm "Mean Intensity 1999 (\%) & & `meanI99_AT5_full' & `meanI99_AT5_full' & `meanI99_AT5_2' & `meanI99_AT5_3' \\ " _n
    file write sm "\bottomrule" _n
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
* Col 4: Col 3 spec WITHOUT Intensity 2005 × post (quintile trend, no inten2005)
* Col 5: Col 2 spec WITHOUT Intensity 2005 × post (continuous trend, no inten2005)
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

* --- Col 4: Quintile trend, NO inten2005 (Panel A pooled) ---
reghdfe emr65 c.inten1999#i.post c.sp_intensity ///
	i.im90_bin#c.year ///
	[aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local b99_ses_4 = "`aux'***"
else if `t' >= 1.96  local b99_ses_4 = "`aux'**"
else if `t' >= 1.645 local b99_ses_4 = "`aux'*"
else                  local b99_ses_4 = "`aux'"
local se99_ses_4: di %12.3f _se[1.post#c.inten1999]
local b05_ses_4  = ""
local se05_ses_4 = ""
sum emr65 if e(sample) & year < 1997
local mean_ses_4: di %12.2fc `r(mean)'
local N_ses_4:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local Nmun_ses_4: di %12.0fc `r(ndistinct)'

* --- Col 5: Continuous trend, NO inten2005 ---
reghdfe emr65 c.inten1999#i.post c.sp_intensity ///
	c.im_mun_1990#c.year ///
	[aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
local aux: di %12.3f _b[1.post#c.inten1999]
local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
if      `t' >= 2.576 local b99_ses_5 = "`aux'***"
else if `t' >= 1.96  local b99_ses_5 = "`aux'**"
else if `t' >= 1.645 local b99_ses_5 = "`aux'*"
else                  local b99_ses_5 = "`aux'"
local se99_ses_5: di %12.3f _se[1.post#c.inten1999]
local b05_ses_5  = ""
local se05_ses_5 = ""
sum emr65 if e(sample) & year < 1997
local mean_ses_5: di %12.2fc `r(mean)'
local N_ses_5:    di %12.0fc `e(N)'
distinct cve_ent_mun_super if e(sample)
local Nmun_ses_5: di %12.0fc `r(ndistinct)'

* Mean Intensity 1999 for AT_ses_trend — HM sample
quietly sum inten1999 if $sample_marg & year == 1996
local meanI99_ses: di %6.1f r(mean) * 100

* --- Panel B: Females ---
foreach col in 1 2 3 4 5 {
	if `col' == 1 {
		reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 2 {
		reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			c.im_mun_1990#c.year ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 3 {
		reghdfe emr65f c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			i.im90_bin#c.year ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 4 {
		reghdfe emr65f c.inten1999#i.post c.sp_intensity ///
			i.im90_bin#c.year ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else {
		reghdfe emr65f c.inten1999#i.post c.sp_intensity ///
			c.im_mun_1990#c.year ///
			[aw=popover65_f] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local b99_ses_`col'_f = "`aux'***"
	else if `t' >= 1.96  local b99_ses_`col'_f = "`aux'**"
	else if `t' >= 1.645 local b99_ses_`col'_f = "`aux'*"
	else                  local b99_ses_`col'_f = "`aux'"
	local se99_ses_`col'_f: di %12.3f _se[1.post#c.inten1999]
	if `col' < 4 {
		local aux: di %12.3f _b[1.post#c.inten2005]
		local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
		if      `t' >= 2.576 local b05_ses_`col'_f = "`aux'***"
		else if `t' >= 1.96  local b05_ses_`col'_f = "`aux'**"
		else if `t' >= 1.645 local b05_ses_`col'_f = "`aux'*"
		else                  local b05_ses_`col'_f = "`aux'"
		local se05_ses_`col'_f: di %12.3f _se[1.post#c.inten2005]
	}
	else {
		local b05_ses_`col'_f  = ""
		local se05_ses_`col'_f = ""
	}
	sum emr65f if e(sample) & year < 1997
	local mean_ses_`col'_f: di %12.2fc `r(mean)'
	local N_ses_`col'_f:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local Nmun_ses_`col'_f: di %12.0fc `r(ndistinct)'
}

* --- Panel C: Males ---
foreach col in 1 2 3 4 5 {
	if `col' == 1 {
		reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 2 {
		reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			c.im_mun_1990#c.year ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 3 {
		reghdfe emr65m c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			i.im90_bin#c.year ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else if `col' == 4 {
		reghdfe emr65m c.inten1999#i.post c.sp_intensity ///
			i.im90_bin#c.year ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	else {
		reghdfe emr65m c.inten1999#i.post c.sp_intensity ///
			c.im_mun_1990#c.year ///
			[aw=popover65_m] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	}
	local aux: di %12.3f _b[1.post#c.inten1999]
	local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
	if      `t' >= 2.576 local b99_ses_`col'_m = "`aux'***"
	else if `t' >= 1.96  local b99_ses_`col'_m = "`aux'**"
	else if `t' >= 1.645 local b99_ses_`col'_m = "`aux'*"
	else                  local b99_ses_`col'_m = "`aux'"
	local se99_ses_`col'_m: di %12.3f _se[1.post#c.inten1999]
	if `col' < 4 {
		local aux: di %12.3f _b[1.post#c.inten2005]
		local t = abs(_b[1.post#c.inten2005] / _se[1.post#c.inten2005])
		if      `t' >= 2.576 local b05_ses_`col'_m = "`aux'***"
		else if `t' >= 1.96  local b05_ses_`col'_m = "`aux'**"
		else if `t' >= 1.645 local b05_ses_`col'_m = "`aux'*"
		else                  local b05_ses_`col'_m = "`aux'"
		local se05_ses_`col'_m: di %12.3f _se[1.post#c.inten2005]
	}
	else {
		local b05_ses_`col'_m  = ""
		local se05_ses_`col'_m = ""
	}
	sum emr65m if e(sample) & year < 1997
	local mean_ses_`col'_m: di %12.2fc `r(mean)'
	local N_ses_`col'_m:    di %12.0fc `e(N)'
	distinct cve_ent_mun_super if e(sample)
	local Nmun_ses_`col'_m: di %12.0fc `r(ndistinct)'
}

* --- Write tables (one per gender group) ---
local footer_ses ""
local footer_ses "`footer_ses'Intensity 2005 x post & Y & Y & Y & N & N \\ "
local footer_ses "`footer_ses'Trend x Marg.\ Index (1990) & N & Y & N & N & Y \\ "
local footer_ses "`footer_ses'Trend x Marg.\ Index Quintile (1990) & N & N & Y & Y & N \\ "

* Pooled
{
	cap file close sm
	file open sm using "$tables/appendix/AT_ses_trend.tex", write replace
	file write sm "\begin{tabular}{lccccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\ \toprule" _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_ses_1' & `b99_ses_2' & `b99_ses_3' & `b99_ses_4' & `b99_ses_5' \\ " _n
	file write sm " & (`se99_ses_1') & (`se99_ses_2') & (`se99_ses_3') & (`se99_ses_4') & (`se99_ses_5') \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_ses_1' & `b05_ses_2' & `b05_ses_3' & & \\ " _n
	file write sm " & (`se05_ses_1') & (`se05_ses_2') & (`se05_ses_3') & & \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_ses_1' & `mean_ses_2' & `mean_ses_3' & `mean_ses_4' & `mean_ses_5' \\ " _n
	file write sm "Obs & `N_ses_1' & `N_ses_2' & `N_ses_3' & `N_ses_4' & `N_ses_5' \\ " _n
	file write sm "No.\ Mun & `Nmun_ses_1' & `Nmun_ses_2' & `Nmun_ses_3' & `Nmun_ses_4' & `Nmun_ses_5' \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "`footer_ses'" _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}

* Females
{
	cap file close sm
	file open sm using "$tables/appendix/AT_ses_trend_f.tex", write replace
	file write sm "\begin{tabular}{lccccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\ \toprule" _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_ses_1_f' & `b99_ses_2_f' & `b99_ses_3_f' & `b99_ses_4_f' & `b99_ses_5_f' \\ " _n
	file write sm " & (`se99_ses_1_f') & (`se99_ses_2_f') & (`se99_ses_3_f') & (`se99_ses_4_f') & (`se99_ses_5_f') \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_ses_1_f' & `b05_ses_2_f' & `b05_ses_3_f' & & \\ " _n
	file write sm " & (`se05_ses_1_f') & (`se05_ses_2_f') & (`se05_ses_3_f') & & \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_ses_1_f' & `mean_ses_2_f' & `mean_ses_3_f' & `mean_ses_4_f' & `mean_ses_5_f' \\ " _n
	file write sm "Obs & `N_ses_1_f' & `N_ses_2_f' & `N_ses_3_f' & `N_ses_4_f' & `N_ses_5_f' \\ " _n
	file write sm "No.\ Mun & `Nmun_ses_1_f' & `Nmun_ses_2_f' & `Nmun_ses_3_f' & `Nmun_ses_4_f' & `Nmun_ses_5_f' \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "`footer_ses'" _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}

* Males
{
	cap file close sm
	file open sm using "$tables/appendix/AT_ses_trend_m.tex", write replace
	file write sm "\begin{tabular}{lccccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\ \toprule" _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `b99_ses_1_m' & `b99_ses_2_m' & `b99_ses_3_m' & `b99_ses_4_m' & `b99_ses_5_m' \\ " _n
	file write sm " & (`se99_ses_1_m') & (`se99_ses_2_m') & (`se99_ses_3_m') & (`se99_ses_4_m') & (`se99_ses_5_m') \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "\textit{Intensity 2005 x post (1997-2006)} & `b05_ses_1_m' & `b05_ses_2_m' & `b05_ses_3_m' & & \\ " _n
	file write sm " & (`se05_ses_1_m') & (`se05_ses_2_m') & (`se05_ses_3_m') & & \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "Mean (1991-1996) & `mean_ses_1_m' & `mean_ses_2_m' & `mean_ses_3_m' & `mean_ses_4_m' & `mean_ses_5_m' \\ " _n
	file write sm "Obs & `N_ses_1_m' & `N_ses_2_m' & `N_ses_3_m' & `N_ses_4_m' & `N_ses_5_m' \\ " _n
	file write sm "No.\ Mun & `Nmun_ses_1_m' & `Nmun_ses_2_m' & `Nmun_ses_3_m' & `Nmun_ses_4_m' & `Nmun_ses_5_m' \\ " _n
	file write sm "Mean Intensity 1999 (\%) & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' & `meanI99_ses' \\ " _n
	file write sm "  & & & & & \\ " _n
	file write sm "`footer_ses'" _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
di "Tables exported: AT_ses_trend.tex / AT_ses_trend_f.tex / AT_ses_trend_m.tex"


*============================================================
* APPENDIX FIGURE: AF_ses_trend (pooled / female / male)
* Event study (beta_k = Intensity_1999 x year) across 4 SES trend specs:
*   Series 1 (black,  solid):         Baseline (W+SP)
*   Series 2 (red,    dash):          + Trend × im_mun_1990
*   Series 3 (blue,   shortdash_dot): + Trend × 1990 marg.-index quintile (P&V 2023)
*   Series 4 (green,  longdash):      + Quintile trend, EXCLUDING Intensity_2005
* Output: AF_ses_trend.pdf / AF_ses_trend_f.pdf / AF_ses_trend_m.pdf
*============================================================

local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

foreach grp in p f m {
	if "`grp'" == "p" {
		local yout emr65
		local ywt  popover65_
		local gsuf ""
		local scol black
	}
	else if "`grp'" == "f" {
		local yout emr65f
		local ywt  popover65_f
		local gsuf "_f"
		local scol red
	}
	else {
		local yout emr65m
		local ywt  popover65_m
		local gsuf "_m"
		local scol blue
	}

	* Spec 1: Baseline (W+SP)
	reghdfe `yout' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
		c.sp_intensity [aw=`ywt'] if $sample_marg, a(cve_ent_mun_super) ///
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
	reghdfe `yout' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
		c.sp_intensity c.im_mun_1990#c.year [aw=`ywt'] if $sample_marg, ///
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
	reghdfe `yout' c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
		c.sp_intensity i.im90_bin#c.year [aw=`ywt'] if $sample_marg, ///
		a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
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

	* Spec 4: Quintile trend, EXCLUDING Intensity_2005
	reghdfe `yout' c.inten1999##ib6.year_1995 ///
		c.sp_intensity i.im90_bin#c.year [aw=`ywt'] if $sample_marg, ///
		a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	forval pos = 1/16 {
		if `pos' == 6 {
			local bes4_`pos'  = 0
			local sees4_`pos' = 0
		}
		else {
			local bes4_`pos'  = _b[`pos'.year_1995#c.inten1999]
			local sees4_`pos' = _se[`pos'.year_1995#c.inten1999]
		}
	}

	* --- Plot ---
	preserve
	clear
	set obs 16
	gen yr_pos = _n
	gen xpos_1 = yr_pos - 0.27
	gen xpos_2 = yr_pos - 0.09
	gen xpos_3 = yr_pos + 0.09
	gen xpos_4 = yr_pos + 0.27
	foreach s in 1 2 3 4 {
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
		replace b_s4  = `bes4_`pos''                            if yr_pos == `pos'
		replace hi_s4 = `bes4_`pos'' + 1.96 * `sees4_`pos''    if yr_pos == `pos'
		replace lo_s4 = `bes4_`pos'' - 1.96 * `sees4_`pos''    if yr_pos == `pos'
	}
	twoway ///
		(rcap hi_s1 lo_s1 xpos_1, lcolor(`scol'%60) lwidth(vthin) lpattern(solid)) ///
		(scatter b_s1 xpos_1, mcolor(`scol') msymbol(circle) msize(vsmall)) ///
		(rcap hi_s2 lo_s2 xpos_2, lcolor(`scol'%60) lwidth(vthin) lpattern(dash)) ///
		(scatter b_s2 xpos_2, mcolor(`scol') msymbol(square) msize(vsmall)) ///
		(rcap hi_s3 lo_s3 xpos_3, lcolor(`scol'%60) lwidth(vthin) lpattern(shortdash_dot)) ///
		(scatter b_s3 xpos_3, mcolor(`scol') msymbol(triangle) msize(vsmall)) ///
		(rcap hi_s4 lo_s4 xpos_4, lcolor(`scol'%60) lwidth(vthin) lpattern(longdash)) ///
		(scatter b_s4 xpos_4, mcolor(`scol') msymbol(diamond) msize(vsmall)) ///
		(line b_s1 xpos_1 if 1==0, lcolor(`scol') lpattern(solid) lwidth(thin) mcolor(`scol') msymbol(circle) msize(vsmall)) ///
		(line b_s2 xpos_2 if 1==0, lcolor(`scol') lpattern(dash) lwidth(thin) mcolor(`scol') msymbol(square) msize(vsmall)) ///
		(line b_s3 xpos_3 if 1==0, lcolor(`scol') lpattern(shortdash_dot) lwidth(thin) mcolor(`scol') msymbol(triangle) msize(vsmall)) ///
		(line b_s4 xpos_4 if 1==0, lcolor(`scol') lpattern(longdash) lwidth(thin) mcolor(`scol') msymbol(diamond) msize(vsmall)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
		ylabel(-20(5)15, grid gmin gmax labsize(small)) ///
		legend(order(9 "Baseline (W+SP)" 10 "+ Trend x Marg. Index" 11 "+ Trend x Quintile" 12 "+ Quintile, excl. Int. 2005") ///
			cols(2) size(small) position(6) ring(1) ///
			region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))
	graph export "$figures/appendix/AF_ses_trend`gsuf'.pdf", as(pdf) replace
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

quietly sum inten1999 if $sample_marg & year == 1996
local meanI99_age: di %6.1f r(mean) * 100

{
	cap file close sm
	file open sm using "$tables/appendix/AT_age_subgroups.tex", write replace
	file write sm "\begin{tabular}{lcccc} \hline \hline" _n
	file write sm "& \multicolumn{1}{c}{Ages 50--64} & \multicolumn{1}{c}{Ages 65+} & \multicolumn{1}{c}{Ages 65--69} & \multicolumn{1}{c}{Ages 70+} \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n

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
	file write sm "Mean Intensity 1999 (\%) & `meanI99_age' & `meanI99_age' & `meanI99_age' & `meanI99_age' \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
di "Table exported to: $tables/appendix/AT_age_subgroups.tex"

cap drop death5064 death5064f death5064m pop5064_ pop5064_f pop5064_m emr5064 emr5064f emr5064m

*============================================================
* POST-IADB IDENTIFICATION-DEFENSE BLOCK (Bucket 1, minus D0b)
* D0b (locality-marginality-share control) is DEFERRED pending the
* locality-level marginality index data (user constructing separately).
* Everything below uses data already in this panel.
*============================================================

*------------------------------------------------------------
* PREREQUISITE: extend cumulative-intensity snapshots to every year.
* inten1997/1998/2000/2002 already existed (built earlier in this file
* from `intensity_new`, which is itself a genuine year-by-year panel
* variable -- confirmed via its lag_intensity_new/lag2_.../lead_intensity_new
* companions in 01_mortality_data.do). Adding the remaining years makes a
* full year-by-year second-phase snapshot profile possible (D1) with NO
* new data required.
*------------------------------------------------------------
foreach yr in 2001 2003 2004 2006 {
    cap drop aux
    g aux = intensity_new if year == `yr'
    bys cve_ent_mun_super: egen inten`yr' = min(aux)
    drop aux
}
di "Intensity snapshots now available for: 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006"

*============================================================
* D0: PARKER & VOGL (2023) FIGURE 3 ANALOGUE + FN.18 R² (rows 1-2)
* Municipality enrollment ratio vs. municipality marginality percentile,
* split by roll-out phase (1997-99 vs. 2000-05). Answers Conf. Comment 3
* (locality/municipality composition) and pairs with the R² check below
* for Conf. Comment 4 / IADB-2. Uses the FULL (unrestricted) municipality
* cross-section, matching P&V's own Figure 3 (drawn on all municipalities
* nationwide, not just the HM analysis sample, to show the full targeting
* gradient -- vertical category cutoffs are the point of that figure).
* Output: $figures/appendix/AF_pv_fig3_replication.pdf
*------------------------------------------------------------
* ASSUMPTION TO VERIFY: inten1999/inten2005 are CUMULATIVE-through-year
* snapshots (same convention as inten1997/1998/2000/2002 built above from
* intensity_new). The `phase2_new < 0` diagnostic below checks this: if
* cumulative, inten2005 >= inten1999 should hold almost everywhere.
*============================================================
preserve
keep if year == 1996
keep cve_ent_mun_super inten1999 inten2005 im_mun_1990 gm_mun_1990
duplicates drop cve_ent_mun_super, force
di "`c(N)' municipalities in the all-Mexico cross-section"

count if missing(inten1999) | missing(inten2005) | missing(im_mun_1990)
di "`r(N)' municipalities dropped for missing inten1999/inten2005/im_mun_1990"
drop if missing(inten1999) | missing(inten2005) | missing(im_mun_1990)

* Phase-specific (incremental) enrollment ratios, matching P&V's own
* construction (their Figs. 2-3 plot NEW enrollment during each phase,
* not cumulative totals): phase 1 = inten1999 (cumulative through 1999,
* ~= increment since baseline was ~0 pre-1997); phase 2 = the increment
* ADDED after 1999, i.e. inten2005 - inten1999 (NOT cumulative inten2005).
gen phase1_new = inten1999
gen phase2_new = inten2005 - inten1999
count if phase2_new < 0
di "`r(N)' municipalities with inten2005 < inten1999 -- should be ~0 if both are cumulative snapshots of the same process; investigate construction if this count is large"
replace phase2_new = 0 if phase2_new < 0

* Percentile bins of the municipality marginality index (P&V: "each
* scatter point represents a 1-point bin")
xtile marg_pctile = im_mun_1990, nq(100)

* collapse (count) does not accept a string variable (cve_ent_mun_super);
* use a numeric constant instead to count municipalities per bin.
gen byte _one = 1
collapse (mean) phase1_new phase2_new (count) n_mun = _one, by(marg_pctile)
di "`c(N)' percentile bins with data"

label var phase1_new "1997-99 phase"
label var phase2_new "2000-05 phase"

twoway ///
    (connected phase1_new marg_pctile, lcolor(black) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)) ///
    (connected phase2_new marg_pctile, lcolor(red) lwidth(thin) mcolor(red) msymbol(triangle) msize(vsmall)), ///
    xtitle("Municipality marginality percentile") ///
    ytitle("New enrollment ratio", size(medsmall)) ///
    xlabel(0(20)100, labsize(small)) ///
    ylabel(, grid gmin gmax labsize(small)) ///
    legend(order(1 "1997-99" 2 "2000-05") cols(2) size(medsmall) position(6) ring(1) ///
        region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(margin(l=1 r=1))
graph export "$figures/appendix/AF_pv_fig3_replication.pdf", as(pdf) replace
restore
di "Figure exported to: $figures/appendix/AF_pv_fig3_replication.pdf"

*------------------------------------------------------------
* fn.18-style R²: how much of Intensity_1999's variance does Intensity_2005
* explain, alone and with municipality-marginality-percentile controls
* added. Run on the HM analysis sample (matches P&V's own "in sample
* municipalities" wording for their 65%/67%/75% progression).
*------------------------------------------------------------
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999 inten2005 im_mun_1990
duplicates drop cve_ent_mun_super, force
count
local n_r2_mun = r(N)
di "`n_r2_mun' HM municipalities in the correlation cross-section"

xtile marg_pctile_bin_hm = im_mun_1990, nq(10)

reg inten1999 inten2005
local r2_1 : di %5.3f e(r2)
di "R² of inten1999 ~ inten2005 (HM sample): `r2_1'   [P&V fn.18 benchmark: 0.65]"

reg inten1999 inten2005 i.marg_pctile_bin_hm
local r2_2 : di %5.3f e(r2)
di "R² of inten1999 ~ inten2005 + marg-percentile-decile FE (HM sample): `r2_2'   [P&V fn.18 benchmark + muni percentile: 0.67]"
di "NOTE: P&V's third row (+ locality-marginality-share, -> 0.75) is DEFERRED pending locality-level marginality data (D0b)."
* r2_1/r2_2 (and n_r2_mun) are reused below, alongside r2fix_1/r2fix_2 (P&V
* fixed-denominator robustness) and r2fase_yv_*/r2fase_fx_* (FASE-only
* numerator robustness), in the single consolidated
* AT_pv_r2_benefsource table -- see the ROBUSTNESS: FASE-ONLY BENEFICIARY
* SOURCE section for the merged table writer.
restore

*============================================================
* D1: EVENT STUDY (β_k, year-by-year) ON INTENSITY_1999 -- STABILITY
* ACROSS DIFFERENT SECOND-PHASE CONTROLS.
* Per user instruction: NOT a coefplot / spec-comparison summary. Reuses
* the SAME event-study construction already used for AF_ses_trend (four
* overlaid series, offset x-positions, distinguishing line patterns) --
* here the four series vary the SECOND-PHASE CONTROL rather than the SES
* trend. This traces the FULL year-by-year β_k profile on Intensity_1999
* under each control choice, a more complete "mostly flat" check than a
* single Post-interaction summary would be: do the four year-by-year
* profiles overlay closely, or does the choice of second-phase control
* change the dynamic shape of the early-phase effect?
* Output: $figures/appendix/AF_beta0_stability.pdf
*============================================================

local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

* "Mostly flat" descriptive: share of eventual (2005) enrollment added
* after 1999. FLAG: this, like the phase2_new construction in D0 above,
* assumes inten1999/inten2005 are CUMULATIVE-through-year snapshots of
* the same process (so inten2005 - inten1999 = the phase-2 increment).
* Proceeding under this assumption per user instruction; revisit if the
* phase2_new<0 diagnostic in D0 turns up a large count.
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999 inten2005
duplicates drop cve_ent_mun_super, force
gen late_share = (inten2005 - inten1999) / inten2005 if inten2005 > 0
di "--- Share of eventual (2005) enrollment added AFTER 1999, HM sample ---"
su late_share, detail
local flat_mean : di %5.3f r(mean)
local flat_p50   : di %5.3f r(p50)
local flat_p75   : di %5.3f r(p75)
local flat_p90   : di %5.3f r(p90)
restore

*------------------------------------------------------------
* Companion TABLE (not a figure/coefplot): the standard Post-interaction
* beta0 -- not just the year-by-year event-study coefficients above --
* under each of the same four second-phase-control choices, so the
* stability claim can be read as numbers, not only inferred visually from
* AF_beta0_stability. Output: $tables/appendix/AT_beta0_stability.tex
*------------------------------------------------------------
local specname1 "Intensity 2005 (baseline)"
local specname2 "No 2nd-phase control"
local specname3 "Intensity 2000"
local specname4 "Intensity 2002"
local i = 0
foreach spec in 2005 none 2000 2002 {
    local ++i
    if "`spec'" == "none" {
        reghdfe emr65 c.inten1999#i.post c.sp_intensity ///
            [aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
    }
    else {
        reghdfe emr65 c.inten1999#i.post c.inten`spec'#i.post c.sp_intensity ///
            [aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
    }
    local aux : di %9.3f _b[1.post#c.inten1999]
    local tstat = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
    if      `tstat' >= 2.576 local bp_`i' = trim("`aux'") + "***"
    else if `tstat' >= 1.960 local bp_`i' = trim("`aux'") + "**"
    else if `tstat' >= 1.645 local bp_`i' = trim("`aux'") + "*"
    else                     local bp_`i' = trim("`aux'")
    local sep_`i' : di %9.3f _se[1.post#c.inten1999]
    local Np_`i'  : di %12.0fc e(N)
}

{
    cap file close bs
    file open bs using "$tables/appendix/AT_beta0_stability.tex", write replace
    file write bs "\begin{tabular}{lcc} \hline \hline" _n
    file write bs "Second-phase control & Intensity 1999 x Post & Obs \\ \toprule" _n
    file write bs "`specname1' & `bp_1' & `Np_1' \\ " _n
    file write bs " & (`sep_1') & \\ " _n
    file write bs "  & & \\ " _n
    file write bs "`specname2' & `bp_2' & `Np_2' \\ " _n
    file write bs " & (`sep_2') & \\ " _n
    file write bs "  & & \\ " _n
    file write bs "`specname3' & `bp_3' & `Np_3' \\ " _n
    file write bs " & (`sep_3') & \\ " _n
    file write bs "  & & \\ " _n
    file write bs "`specname4' & `bp_4' & `Np_4' \\ " _n
    file write bs " & (`sep_4') & \\ " _n
    file write bs "\bottomrule" _n
    file write bs "Share of eventual (2005) enrollment added after 1999 (mean) & `flat_mean' & \\ " _n
    file write bs "\quad median & `flat_p50' & \\ " _n
    file write bs "\quad p75 & `flat_p75' & \\ " _n
    file write bs "\quad p90 & `flat_p90' & \\ " _n
    file write bs "\end{tabular}"
    file close bs
}
di "Table exported to: $tables/appendix/AT_beta0_stability.tex"

* Spec 1: baseline (current main spec) -- 2nd-phase control = Intensity_2005
reghdfe emr65 c.inten1999##ib6.year_1995 c.inten2005##ib6.year_1995 ///
    c.sp_intensity [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) ///
    vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
    if `pos' == 6 {
        local b1_`pos'  = 0
        local se1_`pos' = 0
    }
    else {
        local b1_`pos'  = _b[`pos'.year_1995#c.inten1999]
        local se1_`pos' = _se[`pos'.year_1995#c.inten1999]
    }
}

* Spec 2: NO second-phase control at all
reghdfe emr65 c.inten1999##ib6.year_1995 ///
    c.sp_intensity [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) ///
    vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
    if `pos' == 6 {
        local b2_`pos'  = 0
        local se2_`pos' = 0
    }
    else {
        local b2_`pos'  = _b[`pos'.year_1995#c.inten1999]
        local se2_`pos' = _se[`pos'.year_1995#c.inten1999]
    }
}

* Spec 3: 2nd-phase control = Intensity_2000 (early intermediate snapshot)
reghdfe emr65 c.inten1999##ib6.year_1995 c.inten2000##ib6.year_1995 ///
    c.sp_intensity [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) ///
    vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
    if `pos' == 6 {
        local b3_`pos'  = 0
        local se3_`pos' = 0
    }
    else {
        local b3_`pos'  = _b[`pos'.year_1995#c.inten1999]
        local se3_`pos' = _se[`pos'.year_1995#c.inten1999]
    }
}

* Spec 4: 2nd-phase control = Intensity_2002 (later intermediate snapshot)
reghdfe emr65 c.inten1999##ib6.year_1995 c.inten2002##ib6.year_1995 ///
    c.sp_intensity [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) ///
    vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
    if `pos' == 6 {
        local b4_`pos'  = 0
        local se4_`pos' = 0
    }
    else {
        local b4_`pos'  = _b[`pos'.year_1995#c.inten1999]
        local se4_`pos' = _se[`pos'.year_1995#c.inten1999]
    }
}

preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_1 = yr_pos - 0.27
gen xpos_2 = yr_pos - 0.09
gen xpos_3 = yr_pos + 0.09
gen xpos_4 = yr_pos + 0.27
foreach s in 1 2 3 4 {
    gen b_s`s'  = .
    gen hi_s`s' = .
    gen lo_s`s' = .
}
forval pos = 1/16 {
    replace b_s1  = `b1_`pos''                          if yr_pos == `pos'
    replace hi_s1 = `b1_`pos'' + 1.96 * `se1_`pos''    if yr_pos == `pos'
    replace lo_s1 = `b1_`pos'' - 1.96 * `se1_`pos''    if yr_pos == `pos'
    replace b_s2  = `b2_`pos''                          if yr_pos == `pos'
    replace hi_s2 = `b2_`pos'' + 1.96 * `se2_`pos''    if yr_pos == `pos'
    replace lo_s2 = `b2_`pos'' - 1.96 * `se2_`pos''    if yr_pos == `pos'
    replace b_s3  = `b3_`pos''                          if yr_pos == `pos'
    replace hi_s3 = `b3_`pos'' + 1.96 * `se3_`pos''    if yr_pos == `pos'
    replace lo_s3 = `b3_`pos'' - 1.96 * `se3_`pos''    if yr_pos == `pos'
    replace b_s4  = `b4_`pos''                          if yr_pos == `pos'
    replace hi_s4 = `b4_`pos'' + 1.96 * `se4_`pos''    if yr_pos == `pos'
    replace lo_s4 = `b4_`pos'' - 1.96 * `se4_`pos''    if yr_pos == `pos'
}
twoway ///
    (rcap hi_s1 lo_s1 xpos_1, lcolor(black%60) lwidth(vthin) lpattern(solid)) ///
    (scatter b_s1 xpos_1, mcolor(black) msymbol(circle) msize(vsmall)) ///
    (rcap hi_s2 lo_s2 xpos_2, lcolor(black%60) lwidth(vthin) lpattern(dash)) ///
    (scatter b_s2 xpos_2, mcolor(black) msymbol(square) msize(vsmall)) ///
    (rcap hi_s3 lo_s3 xpos_3, lcolor(black%60) lwidth(vthin) lpattern(shortdash_dot)) ///
    (scatter b_s3 xpos_3, mcolor(black) msymbol(triangle) msize(vsmall)) ///
    (rcap hi_s4 lo_s4 xpos_4, lcolor(black%60) lwidth(vthin) lpattern(longdash)) ///
    (scatter b_s4 xpos_4, mcolor(black) msymbol(diamond) msize(vsmall)) ///
    (line b_s1 xpos_1 if 1==0, lcolor(black) lpattern(solid) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)) ///
    (line b_s2 xpos_2 if 1==0, lcolor(black) lpattern(dash) lwidth(thin) mcolor(black) msymbol(square) msize(vsmall)) ///
    (line b_s3 xpos_3 if 1==0, lcolor(black) lpattern(shortdash_dot) lwidth(thin) mcolor(black) msymbol(triangle) msize(vsmall)) ///
    (line b_s4 xpos_4 if 1==0, lcolor(black) lpattern(longdash) lwidth(thin) mcolor(black) msymbol(diamond) msize(vsmall)), ///
    yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
    xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
    xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
    xscale(range(0.5 16.5)) ///
    xtitle("") ///
    ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
    ylabel(, grid gmin gmax labsize(small)) ///
    legend(order(9 "Control: Intensity 2005 (baseline)" 10 "No 2nd-phase control" 11 "Control: Intensity 2000" 12 "Control: Intensity 2002") ///
        cols(2) size(small) position(6) ring(1) ///
        region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
    graphregion(color(white)) ///
    plotregion(margin(l=1 r=1))
graph export "$figures/appendix/AF_beta0_stability.pdf", as(pdf) replace
restore
di "Figure exported to: $figures/appendix/AF_beta0_stability.pdf"

*============================================================
* D3: EXACT SATURATION DIAGNOSTICS (year-on-year Δintensity, "stayers",
* first-crossing-15% distribution). With intensity now known for every
* year (not interpolated between sparse snapshots), this settles whether
* a continuous-treatment (dCDH-style) estimator has enough stayer/
* not-yet-treated comparison units to be feasible, and whether a 15%
* binarization threshold produces meaningful cohort spread.
*============================================================
preserve
keep if $sample_marg & inrange(year, 1997, 2006)
sort cve_ent_mun_super year

by cve_ent_mun_super: gen delta_intensity = intensity_new - intensity_new[_n-1] if year == year[_n-1] + 1
gen abs_delta = abs(delta_intensity)

di "--- Year-on-year |Δintensity| distribution, HM sample, 1997-2006 ---"
su abs_delta, detail
local delta_mean : di %6.3f r(mean)
local delta_p50   : di %6.3f r(p50)
local delta_p90   : di %6.3f r(p90)

count if abs_delta < 0.01 & !missing(abs_delta)
local n_stayers = r(N)
count if !missing(abs_delta)
local n_total = r(N)
local stayer_pct : di %5.1f 100*`n_stayers'/`n_total'
di "Municipality-years with |Δintensity| < 1pp ('stayers'): `n_stayers' / `n_total' (`stayer_pct'%)"

di "--- |Δintensity| by year ---"
tabstat abs_delta, by(year) stat(mean p50 p90) format(%6.3f)

* First year each municipality crosses 15% intensity (feeds D2's
* threshold choice and checks cohort spread for any staggered-timing
* estimator)
gen crossed15 = year if intensity_new >= 0.15 & !missing(intensity_new)
bys cve_ent_mun_super: egen first_cross15 = min(crossed15)

* Save the full municipality-year panel before collapsing to one row per
* municipality below -- we are already inside a preserve opened earlier in
* D3, and Stata does not support a second, nested preserve/restore, so use
* a tempfile instead to get back to the full panel afterward.
tempfile d3_panel
save `d3_panel'

duplicates drop cve_ent_mun_super, force
count
local n_mun_hm = r(N)
di "--- Distribution of first year crossing 15% intensity, HM sample ---"
tab first_cross15
count if first_cross15 <= 1999
local n_cross_early = r(N)
count if missing(first_cross15)
local n_never_cross = r(N)
di "`n_never_cross' HM municipalities NEVER cross 15% intensity by 2006"

use `d3_panel', clear

* Any HM municipality with near-zero intensity throughout the post period?
bys cve_ent_mun_super: egen max_intensity_post = max(intensity_new) if inrange(year,1997,2006)
count if max_intensity_post < 0.05 & inrange(year,1997,2006)
local n_near_zero = r(N)
di "`n_near_zero' HM municipality-years with max post-1997 intensity below 5% (near-zero penetration throughout)"

{
    cap file close sat
    file open sat using "$tables/appendix/AT_saturation_diagnostics.tex", write replace
    file write sat "\begin{tabular}{lc} \hline \hline" _n
    file write sat "\multicolumn{2}{l}{\textit{Year-on-year \$|\Delta\$Intensity\$|\$, HM sample, 1997--2006}} \\ \toprule" _n
    file write sat "Mean & `delta_mean' \\ " _n
    file write sat "Median & `delta_p50' \\ " _n
    file write sat "90th percentile & `delta_p90' \\ " _n
    file write sat "Municipality-years, \$|\Delta\$Intensity\$|<\$1pp (\textit{stayers}) & `n_stayers' / `n_total' (`stayer_pct'\%) \\ " _n
    file write sat "  & \\ " _n
    file write sat "\multicolumn{2}{l}{\textit{First year crossing 15\% intensity}} \\ " _n
    file write sat "Municipalities crossing by 1999 & `n_cross_early' / `n_mun_hm' \\ " _n
    file write sat "Municipalities never crossing by 2006 & `n_never_cross' / `n_mun_hm' \\ " _n
    file write sat "  & \\ " _n
    file write sat "Municipality-years with max intensity \$<\$5\% (near-zero penetration) & `n_near_zero' \\ " _n
    file write sat "\bottomrule" _n
    file write sat "\end{tabular}"
    file close sat
}
di "Table exported to: $tables/appendix/AT_saturation_diagnostics.tex"
restore
di "D3 saturation diagnostics complete -- see log above for stayer availability and first-crossing spread."

*============================================================
* D2: BINARY HIGH-VS-LOW EVENT STUDY ON INTENSITY_1999 (Óscar's actual
* final ask -- see the CLARIFICATION note above: he converged on
* binarizing the FIXED 1999 intensity + plain single-break TWFE, not a
* staggered-crossing csdid design). Mimics the current continuous design
* with a binary "high vs low" 1999-intensity indicator instead, testing
* robustness to the dose-response FUNCTIONAL FORM (drops linearity-in-
* intensity). Does NOT itself resolve the forbidden-comparison question
* -- the single 1997 break already does that, continuous or binary --
* this is a transparency/functional-form robustness check, not an
* identification fix.
*
* Threshold sensitivity grid: 15% (Óscar's own suggested cutoff), the
* HM-sample median, and the 75th percentile of Intensity_1999. Under
* saturation there is no meaningful never-treated group, so "control" in
* every spec = below-threshold Intensity_1999 (a HIGH-VS-LOW contrast),
* NOT treated-vs-never -- stated explicitly in the figure/table notes.
* Output: $figures/appendix/AF_binary_es.pdf, $tables/appendix/AT_binary_es.tex
*============================================================

local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

* Determine data-driven thresholds from the HM municipality cross-section
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999
duplicates drop cve_ent_mun_super, force
su inten1999, detail
local thr_p50 = r(p50)
local thr_p75 = r(p75)
di "Median Intensity_1999 (HM sample): " %5.3f `thr_p50'
di "75th percentile Intensity_1999 (HM sample): " %5.3f `thr_p75'
restore

cap drop treated_15 treated_med treated_p75
gen treated_15  = (inten1999 >= 0.15)      if !missing(inten1999)
gen treated_med = (inten1999 >= `thr_p50') if !missing(inten1999)
gen treated_p75 = (inten1999 >= `thr_p75') if !missing(inten1999)

foreach v in treated_15 treated_med treated_p75 {
    count if $sample_marg & year==1996 & `v'==1
    local n1_`v' = r(N)
    count if $sample_marg & year==1996 & `v'==0
    local n0_`v' = r(N)
    di "`v': `n1_`v'' high / `n0_`v'' low (HM municipalities, 1996)"
}

* Spec A: threshold = 15%
reghdfe emr65 c.treated_15##ib6.year_1995 c.sp_intensity ///
    [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
    if `pos' == 6 {
        local ba_`pos'  = 0
        local sea_`pos' = 0
    }
    else {
        local ba_`pos'  = _b[`pos'.year_1995#c.treated_15]
        local sea_`pos' = _se[`pos'.year_1995#c.treated_15]
    }
}

* Spec B: threshold = HM-sample median
reghdfe emr65 c.treated_med##ib6.year_1995 c.sp_intensity ///
    [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
    if `pos' == 6 {
        local bb_`pos'  = 0
        local seb_`pos' = 0
    }
    else {
        local bb_`pos'  = _b[`pos'.year_1995#c.treated_med]
        local seb_`pos' = _se[`pos'.year_1995#c.treated_med]
    }
}

* Spec C: threshold = HM-sample 75th percentile
reghdfe emr65 c.treated_p75##ib6.year_1995 c.sp_intensity ///
    [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
forval pos = 1/16 {
    if `pos' == 6 {
        local bc_`pos'  = 0
        local sec_`pos' = 0
    }
    else {
        local bc_`pos'  = _b[`pos'.year_1995#c.treated_p75]
        local sec_`pos' = _se[`pos'.year_1995#c.treated_p75]
    }
}

preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_a = yr_pos - 0.18
gen xpos_b = yr_pos
gen xpos_c = yr_pos + 0.18
foreach s in a b c {
    gen b_`s'  = .
    gen hi_`s' = .
    gen lo_`s' = .
}
forval pos = 1/16 {
    replace b_a  = `ba_`pos''                       if yr_pos == `pos'
    replace hi_a = `ba_`pos'' + 1.96 * `sea_`pos'' if yr_pos == `pos'
    replace lo_a = `ba_`pos'' - 1.96 * `sea_`pos'' if yr_pos == `pos'
    replace b_b  = `bb_`pos''                       if yr_pos == `pos'
    replace hi_b = `bb_`pos'' + 1.96 * `seb_`pos'' if yr_pos == `pos'
    replace lo_b = `bb_`pos'' - 1.96 * `seb_`pos'' if yr_pos == `pos'
    replace b_c  = `bc_`pos''                       if yr_pos == `pos'
    replace hi_c = `bc_`pos'' + 1.96 * `sec_`pos'' if yr_pos == `pos'
    replace lo_c = `bc_`pos'' - 1.96 * `sec_`pos'' if yr_pos == `pos'
}

twoway ///
    (rcap hi_a lo_a xpos_a, lcolor(black%60) lwidth(vthin) lpattern(solid)) ///
    (scatter b_a xpos_a, mcolor(black) msymbol(circle) msize(vsmall)) ///
    (rcap hi_b lo_b xpos_b, lcolor(red%60) lwidth(vthin) lpattern(dash)) ///
    (scatter b_b xpos_b, mcolor(red) msymbol(square) msize(vsmall)) ///
    (rcap hi_c lo_c xpos_c, lcolor(blue%60) lwidth(vthin) lpattern(shortdash_dot)) ///
    (scatter b_c xpos_c, mcolor(blue) msymbol(triangle) msize(vsmall)) ///
    (line b_a xpos_a if 1==0, lcolor(black) lpattern(solid) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)) ///
    (line b_b xpos_b if 1==0, lcolor(red) lpattern(dash) lwidth(thin) mcolor(red) msymbol(square) msize(vsmall)) ///
    (line b_c xpos_c if 1==0, lcolor(blue) lpattern(shortdash_dot) lwidth(thin) mcolor(blue) msymbol(triangle) msize(vsmall)), ///
    yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
    xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
    xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
    xscale(range(0.5 16.5)) ///
    xtitle("") ///
    ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
    ylabel(, grid gmin gmax labsize(small)) ///
    legend(order(7 "Threshold: 15%" 8 "Threshold: median" 9 "Threshold: p75") ///
        cols(3) size(small) position(6) ring(1) ///
        region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
    graphregion(color(white)) ///
    plotregion(margin(l=1 r=1))
graph export "$figures/appendix/AF_binary_es.pdf", as(pdf) replace
restore
di "Figure exported to: $figures/appendix/AF_binary_es.pdf"

*------------------------------------------------------------
* Companion TABLE: standard Post-interaction estimate for each threshold,
* mirroring the D1 companion-table pattern (point estimates + N + high/low
* municipality counts, to accompany the year-by-year event study above).
* Output: $tables/appendix/AT_binary_es.tex
*------------------------------------------------------------
local thr_p50_pct : di %4.1f `thr_p50'*100
local thr_p75_pct : di %4.1f `thr_p75'*100
local threshname1 "Threshold: 15\%"
local threshname2 "Threshold: median (`thr_p50_pct'\%)"
local threshname3 "Threshold: p75 (`thr_p75_pct'\%)"

local i = 0
foreach v in treated_15 treated_med treated_p75 {
    local ++i
    reghdfe emr65 c.`v'#i.post c.sp_intensity ///
        [aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
    local aux : di %9.3f _b[1.post#c.`v']
    local tstat = abs(_b[1.post#c.`v'] / _se[1.post#c.`v'])
    if      `tstat' >= 2.576 local bt_`i' = trim("`aux'") + "***"
    else if `tstat' >= 1.960 local bt_`i' = trim("`aux'") + "**"
    else if `tstat' >= 1.645 local bt_`i' = trim("`aux'") + "*"
    else                     local bt_`i' = trim("`aux'")
    local set_`i' : di %9.3f _se[1.post#c.`v']
    local Nt_`i'  : di %12.0fc e(N)
}

{
    cap file close bin
    file open bin using "$tables/appendix/AT_binary_es.tex", write replace
    file write bin "\begin{tabular}{lcccc} \hline \hline" _n
    file write bin "Threshold & Intensity 1999 x Post & Obs & High & Low \\ \toprule" _n
    file write bin "`threshname1' & `bt_1' & `Nt_1' & `n1_treated_15' & `n0_treated_15' \\ " _n
    file write bin " & (`set_1') & & & \\ " _n
    file write bin "  & & & & \\ " _n
    file write bin "`threshname2' & `bt_2' & `Nt_2' & `n1_treated_med' & `n0_treated_med' \\ " _n
    file write bin " & (`set_2') & & & \\ " _n
    file write bin "  & & & & \\ " _n
    file write bin "`threshname3' & `bt_3' & `Nt_3' & `n1_treated_p75' & `n0_treated_p75' \\ " _n
    file write bin " & (`set_3') & & & \\ " _n
    file write bin "\bottomrule" _n
    file write bin "\end{tabular}"
    file close bin
}
di "Table exported to: $tables/appendix/AT_binary_es.tex"

*============================================================
* ROBUSTNESS: P&V-STYLE FIXED-DENOMINATOR INTENSITY CONSTRUCTION
* User is worried the R²(Intensity_1999~Intensity_2005)=0.16 (vs P&V's
* 0.65) may reflect a denominator difference: our `intensity_new` divides
* cumulative beneficiaries by `hh_tot` AT EACH YEAR (year-varying), while
* P&V divide by a SINGLE fixed interpolated-1997 household count
* (hog1997 = 0.3*hog1990 + 0.7*hog2000) for BOTH snapshots. This section
* rebuilds Intensity_1999/Intensity_2005 using P&V's exact fixed-
* denominator formula, as a SIDE-BY-SIDE robustness check (does NOT
* replace the main specification), to see how much of the R² gap and the
* main regression coefficients this explains.
*
* Requires the raw numerator/denominator series saved by
* 01_mortality_data.do: hh_tot (year-varying HH count), hh_tot1990
* (fixed 1990 HH count), pgbenef_new (year-varying cumulative
* beneficiaries, saved under its pre-rename name pg_new) -- merged in
* fresh here since it is uncertain whether these raw series survived
* into aamr_regression_municipality_gender_tb.dta, the file this script
* actually loads.
*============================================================
cap drop hh_tot hh_tot1990 pgbenef_new
merge m:1 cve_ent_mun_super year using "$data/Temp_data/hhnum_recoded.dta", keepusing(hh_tot) nogenerate
merge m:1 cve_ent_mun_super using "$data/Temp_data/hhnum_1990.dta", keepusing(hh_tot1990) nogenerate
merge m:1 cve_ent_mun_super year using "$data/Temp_data/Progresa_benef_mun_recoded.dta", keepusing(pg_new) nogenerate
rename pg_new pgbenef_new

count if missing(hh_tot) | missing(hh_tot1990) | missing(pgbenef_new)
di "`r(N)' obs missing hh_tot/hh_tot1990/pgbenef_new after merge -- check the Temp_data paths above if this count is large"

* Fixed 1997 household base, P&V's exact formula (0.3*HH1990 + 0.7*HH2000)
cap drop hh_tot2000
g aux = hh_tot if year == 2000
bys cve_ent_mun_super: egen hh_tot2000 = min(aux)
drop aux
gen hog1997_fixed = 0.3*hh_tot1990 + 0.7*hh_tot2000
count if missing(hog1997_fixed)
di "`r(N)' obs missing the fixed 1997 household base (0.3*HH1990+0.7*HH2000)"

* Cumulative beneficiaries AT the 1999 and 2005 snapshots (same pattern
* used to build inten1997/1998/2000/2002 earlier, applied here to the RAW
* pgbenef_new rather than the already-year-varying-denominator intensity_new)
cap drop pgbenef_1999 pgbenef_2005
g aux = pgbenef_new if year == 1999
bys cve_ent_mun_super: egen pgbenef_1999 = min(aux)
drop aux
g aux = pgbenef_new if year == 2005
bys cve_ent_mun_super: egen pgbenef_2005 = min(aux)
drop aux

cap drop inten1999_fix inten2005_fix
gen inten1999_fix = pgbenef_1999/hog1997_fixed
gen inten2005_fix = pgbenef_2005/hog1997_fixed
replace inten1999_fix = 1 if inten1999_fix > 1 & !missing(inten1999_fix)
replace inten2005_fix = 1 if inten2005_fix > 1 & !missing(inten2005_fix)
label var inten1999_fix "Intensity 1999 (P&V-style fixed 1997 HH denominator)"
label var inten2005_fix "Intensity 2005 (P&V-style fixed 1997 HH denominator)"

di "--- Correlation of current (year-varying-denom) vs. fixed-denom Intensity, HM sample, 1996 cross-section ---"
corr inten1999 inten1999_fix if $sample_marg & year==1996
corr inten2005 inten2005_fix if $sample_marg & year==1996

*------------------------------------------------------------
* Robustness R²: same fn.18-style check as above, but using the
* fixed-denominator Intensity_1999/2005 instead of the year-varying-
* denominator versions. r2fix_1/r2fix_2 (and n_r2fix_mun) feed into the
* single consolidated AT_pv_r2_benefsource table below (ROBUSTNESS:
* FASE-ONLY BENEFICIARY SOURCE section) rather than a separate table here.
*------------------------------------------------------------
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999_fix inten2005_fix im_mun_1990
duplicates drop cve_ent_mun_super, force
count
local n_r2fix_mun = r(N)
di "`n_r2fix_mun' HM municipalities in the fixed-denominator correlation cross-section"

xtile marg_pctile_bin_hm_fix = im_mun_1990, nq(10)

reg inten1999_fix inten2005_fix
local r2fix_1 : di %5.3f e(r2)
di "R² of inten1999_fix ~ inten2005_fix (HM sample, FIXED denominator): `r2fix_1'   [current year-varying-denom version: 0.160; P&V benchmark: 0.65]"

reg inten1999_fix inten2005_fix i.marg_pctile_bin_hm_fix
local r2fix_2 : di %5.3f e(r2)
di "R² + marg-percentile-decile FE (FIXED denominator): `r2fix_2'   [current: 0.275; P&V benchmark: 0.67]"
restore

*============================================================
* ROBUSTNESS: FASE-ONLY BENEFICIARY SOURCE (P&V-style numerator)
* Companion check to the fixed-denominator robustness above: the R² gap
* might also reflect a numerator difference, not just a denominator
* difference. Our default ($benef_source = "mixed" in
* 01_mortality_data.do) switches from the FASE file to the newer admin
* pipeline (newProg_98_16.dta) starting in 1998, while P&V use ONLY the
* FASE file for the entire 1997-2005 window. This section rebuilds
* Intensity_1999/Intensity_2005 using the FASE-only numerator
* (pg_mun*_fase, built in 00.programs_beneficiaries_recoded.do), crossed
* with BOTH denominator choices (year-varying and P&V's fixed 1997
* base), as a SIDE-BY-SIDE robustness check (does NOT replace the main
* specification).
*============================================================
preserve
use "$data/beneficiaries_mun_recoded_1990.dta", clear
keep cve_ent_mun_super pg_mun*_fase
forvalues j = 1997/2018 {
	rename pg_mun`j'_fase pg_fase`j'
}
reshape long pg_fase, i(cve_ent_mun_super) j(year)
tempfile fase_panel
save `fase_panel'
restore

cap drop pg_fase
merge m:1 cve_ent_mun_super year using `fase_panel', nogenerate

cap drop pgbenef_fase_1999 pgbenef_fase_2005 hh_tot1999 hh_tot2005
g aux = pg_fase if year == 1999
bys cve_ent_mun_super: egen pgbenef_fase_1999 = min(aux)
drop aux
g aux = pg_fase if year == 2005
bys cve_ent_mun_super: egen pgbenef_fase_2005 = min(aux)
drop aux
g aux = hh_tot if year == 1999
bys cve_ent_mun_super: egen hh_tot1999 = min(aux)
drop aux
g aux = hh_tot if year == 2005
bys cve_ent_mun_super: egen hh_tot2005 = min(aux)
drop aux

* Year-varying denominator (hh_tot AT each snapshot year) -- same
* construction as the main inten1999/inten2005, just with the FASE-only
* numerator in place of pgbenef_new (mixed).
cap drop inten1999_fase inten2005_fase
gen inten1999_fase = pgbenef_fase_1999/hh_tot1999
gen inten2005_fase = pgbenef_fase_2005/hh_tot2005
replace inten1999_fase = 1 if inten1999_fase > 1 & !missing(inten1999_fase)
replace inten2005_fase = 1 if inten2005_fase > 1 & !missing(inten2005_fase)
label var inten1999_fase "Intensity 1999 (FASE-only numerator, year-varying denom.)"
label var inten2005_fase "Intensity 2005 (FASE-only numerator, year-varying denom.)"

* Fixed 1997 household base (P&V's exact denominator), FASE-only numerator
cap drop inten1999_fase_fix inten2005_fase_fix
gen inten1999_fase_fix = pgbenef_fase_1999/hog1997_fixed
gen inten2005_fase_fix = pgbenef_fase_2005/hog1997_fixed
replace inten1999_fase_fix = 1 if inten1999_fase_fix > 1 & !missing(inten1999_fase_fix)
replace inten2005_fase_fix = 1 if inten2005_fase_fix > 1 & !missing(inten2005_fase_fix)
label var inten1999_fase_fix "Intensity 1999 (FASE-only numerator, fixed P&V denom.)"
label var inten2005_fase_fix "Intensity 2005 (FASE-only numerator, fixed P&V denom.)"

*============================================================
* Correlation between the two beneficiary-numerator constructions (used
* as a bottom-of-table diagnostic in the merged T2_b_mortality_fixeddenom
* table below): inten1999/inten2005 (mixed source, point-in-time
* headcount -- FASE 1997, then newProg_98_16 taken directly for 1998+;
* not guaranteed monotonic since newProg_98_16 carries no stable household
* ID across years) vs. inten1999_fase/inten2005_fase (Parker & Vogl's own
* construction, a genuine running sum of annual FASE beneficiary counts,
* giving a monotonic "ever enrolled by year Y" measure). Only FASE (an
* annual flow) can be validly summed this way; a prior version of this
* file summed the mixed/newProg series instead ("inten*_summix") and was
* removed -- newProg_98_16 is already a status headcount, not a flow, so
* summing it year-over-year double-counts continuing beneficiaries.
*============================================================
corr inten1999 inten1999_fase if $sample_marg & year==1996
local corr99: di %5.3f r(rho)
corr inten2005 inten2005_fase if $sample_marg & year==1996
local corr05: di %5.3f r(rho)
corr inten1999_fix inten1999_fase_fix if $sample_marg & year==1996
local corr99_fix: di %5.3f r(rho)
corr inten2005_fix inten2005_fase_fix if $sample_marg & year==1996
local corr05_fix: di %5.3f r(rho)

*============================================================
* APPENDIX FIGURE: event study for Intensity_1999 x year, ALL FOUR
* intensity constructions overlaid on one set of axes (rather than four
* separate small-multiple panels), so the beta_k profile's movement
* across constructions is directly visible. Same design as Figure 2
* (inten x year_1995 interactions), pooled sample, weighted + SP.
* Crosses the same 2 numerator variants (mixed snapshot vs. FASE
* cumulative) x 2 denominator choices (year-varying vs. fixed P&V-style)
* as the merged T2_b_mortality_fixeddenom table, so each of that table's
* 4 columns has a matching series here. Intensity_2005 is dropped (the
* comparison here is about the construction of Intensity_1999 itself,
* not the second phase).
*   snap     : Mixed numerator,  year-varying denom (current default)
*   cum      : FASE numerator,   year-varying denom (numerator fix alone)
*   snap_fix : Mixed numerator,  fixed 1997 P&V denom (denominator fix alone)
*   cum_fix  : FASE numerator,   fixed 1997 P&V denom (both combined)
* Output: $figures/appendix/Figure_2_all.pdf
*============================================================
{
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
foreach v in snap cum snap_fix cum_fix {
	if "`v'" == "snap" {
		local inten99v inten1999
	}
	else if "`v'" == "cum" {
		local inten99v inten1999_fase
	}
	else if "`v'" == "snap_fix" {
		local inten99v inten1999_fix
	}
	else {
		local inten99v inten1999_fase_fix
	}

	* Default every position to missing first, so a failed regression
	* leaves valid (blank-plotting) locals behind instead of undefined
	* macros that would break the "replace ... if yr_pos == `pos'" step
	* below with an "if not found" error.
	forval pos = 1/16 {
		local b99_`v'_`pos'  = .
		local se99_`v'_`pos' = .
	}
	cap noisily reghdfe emr65 c.`inten99v'##ib6.year_1995 ///
		c.sp_intensity [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	if _rc == 0 {
		forval pos = 1/16 {
			if `pos' == 6 {
				local b99_`v'_`pos'  = 0
				local se99_`v'_`pos' = 0
			}
			else {
				local b99_`v'_`pos'  = _b[`pos'.year_1995#c.`inten99v']
				local se99_`v'_`pos' = _se[`pos'.year_1995#c.`inten99v']
			}
		}
	}
	else {
		di as error "Variant `v': event-study reghdfe failed (rc=`_rc'), leaving cells blank"
	}
}

preserve
clear
set obs 16
gen yr_pos = _n
* Four series dodged +/-0.27/+/-0.09 year-units (same spacing convention
* as AF_ses_trend) so points/CIs don't overlap at each year.
gen xpos_snap     = yr_pos - 0.27
gen xpos_cum      = yr_pos - 0.09
gen xpos_snap_fix = yr_pos + 0.09
gen xpos_cum_fix  = yr_pos + 0.27
foreach v in snap cum snap_fix cum_fix {
	gen b_`v'  = .
	gen hi_`v' = .
	gen lo_`v' = .
}
forval pos = 1/16 {
	foreach v in snap cum snap_fix cum_fix {
		replace b_`v'  = `b99_`v'_`pos''                           if yr_pos == `pos'
		replace hi_`v' = `b99_`v'_`pos'' + 1.96 * `se99_`v'_`pos'' if yr_pos == `pos'
		replace lo_`v' = `b99_`v'_`pos'' - 1.96 * `se99_`v'_`pos'' if yr_pos == `pos'
	}
}
twoway ///
	(rcap hi_snap lo_snap xpos_snap, lcolor(black%60) lwidth(vthin)) ///
	(scatter b_snap xpos_snap, mcolor(black) msymbol(circle) msize(vsmall)) ///
	(rcap hi_cum lo_cum xpos_cum, lcolor(orange%60) lwidth(vthin)) ///
	(scatter b_cum xpos_cum, mcolor(orange) msymbol(square) msize(vsmall)) ///
	(rcap hi_snap_fix lo_snap_fix xpos_snap_fix, lcolor(blue%60) lwidth(vthin)) ///
	(scatter b_snap_fix xpos_snap_fix, mcolor(blue) msymbol(triangle) msize(vsmall)) ///
	(rcap hi_cum_fix lo_cum_fix xpos_cum_fix, lcolor(green%60) lwidth(vthin)) ///
	(scatter b_cum_fix xpos_cum_fix, mcolor(green) msymbol(diamond) msize(vsmall)), ///
	yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
	xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
	xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
	xscale(range(0.5 16.5)) ///
	xtitle("") ///
	ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
	ylabel(, grid gmin gmax labsize(small)) ///
	legend(order(2 "Mixed, year-varying (current)" 4 "FASE, year-varying" ///
		6 "Mixed, fixed P&V" 8 "FASE, fixed P&V") ///
		cols(2) size(small) position(6) ring(1) ///
		region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
	graphregion(color(white)) ///
	plotregion(margin(l=1 r=1))
graph export "$figures/appendix/Figure_2_all.pdf", as(pdf) replace
restore
}

*============================================================
* APPENDIX FIGURE: companion to Figure_2_all.pdf, adding the SES/
* marginality-trend control. Same four intensity constructions, same
* combined-overlay design, but each regression now also includes
* i.im90_bin#c.year (a municipality-specific linear trend interacted
* with 1990 marginalization-index quintiles), following Parker and
* Vogl's (2023) preferred SES-trend specification (spec 3 of
* AF_ses_trend/AT_ses_trend). Comparing this figure to Figure_2_all.pdf
* isolates whether the SES trend, rather than the numerator/denominator
* choice, is driving any divergence across constructions.
* Output: $figures/appendix/Figure_2_all_ses.pdf
*============================================================
{
* im90_bin (built for AF_ses_trend/AT_ses_trend above) is explicitly
* dropped once that block is done with it (see "Clean up generated SES
* baseline variables"), so it no longer exists in the dataset by this
* point in the file -- rebuild it here using the identical construction.
* Guarded with a count check (rather than assumed to succeed) so that if
* cve_ent_mun_super/im_mun_1990 are unexpectedly empty at this exact
* point in a given run (e.g. the dataset in memory does not match what
* this block expects), the SES-trend companion figure is skipped with an
* error message instead of halting the entire do-file.
local nq_ses 5
cap drop im90_bin
cap drop _mun_tag
egen _mun_tag = tag(cve_ent_mun_super)
count if _mun_tag & !missing(im_mun_1990)
local ses_ok = (r(N) > 0)
if `ses_ok' {
	xtile im90_bin = im_mun_1990 if _mun_tag, nq(`nq_ses')
	bys cve_ent_mun_super: egen _im90_bin = max(im90_bin)
	replace im90_bin = _im90_bin
	drop _im90_bin
	label var im90_bin "1990 marginalization-index quintile (1=least, `nq_ses'=most marginalized)"
}
else {
	di as error "cve_ent_mun_super/im_mun_1990 unexpectedly empty at this point -- skipping the SES-trend companion figure (Figure_2_all_ses.pdf)"
}
drop _mun_tag

if `ses_ok' {
	local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
	foreach v in snap cum snap_fix cum_fix {
		if "`v'" == "snap" {
			local inten99v inten1999
		}
		else if "`v'" == "cum" {
			local inten99v inten1999_fase
		}
		else if "`v'" == "snap_fix" {
			local inten99v inten1999_fix
		}
		else {
			local inten99v inten1999_fase_fix
		}

		* Default every position to missing first (see the analogous note
		* in the non-SES Figure_2_all block above) so a failed regression
		* cannot leave an undefined local behind.
		forval pos = 1/16 {
			local bses_`v'_`pos'  = .
			local seses_`v'_`pos' = .
		}
		cap noisily reghdfe emr65 c.`inten99v'##ib6.year_1995 ///
			c.sp_intensity i.im90_bin#c.year [aw=popover65_] if $sample_marg, ///
			a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
		if _rc == 0 {
			forval pos = 1/16 {
				if `pos' == 6 {
					local bses_`v'_`pos'  = 0
					local seses_`v'_`pos' = 0
				}
				else {
					local bses_`v'_`pos'  = _b[`pos'.year_1995#c.`inten99v']
					local seses_`v'_`pos' = _se[`pos'.year_1995#c.`inten99v']
				}
			}
		}
		else {
			di as error "SES-trend variant `v': event-study reghdfe failed (rc=`_rc'), leaving cells blank"
		}
	}

	preserve
	clear
	set obs 16
	gen yr_pos = _n
	gen xpos_snap     = yr_pos - 0.27
	gen xpos_cum      = yr_pos - 0.09
	gen xpos_snap_fix = yr_pos + 0.09
	gen xpos_cum_fix  = yr_pos + 0.27
	foreach v in snap cum snap_fix cum_fix {
		gen b_`v'  = .
		gen hi_`v' = .
		gen lo_`v' = .
	}
	forval pos = 1/16 {
		foreach v in snap cum snap_fix cum_fix {
			replace b_`v'  = `bses_`v'_`pos''                            if yr_pos == `pos'
			replace hi_`v' = `bses_`v'_`pos'' + 1.96 * `seses_`v'_`pos'' if yr_pos == `pos'
			replace lo_`v' = `bses_`v'_`pos'' - 1.96 * `seses_`v'_`pos'' if yr_pos == `pos'
		}
	}
	twoway ///
		(rcap hi_snap lo_snap xpos_snap, lcolor(black%60) lwidth(vthin)) ///
		(scatter b_snap xpos_snap, mcolor(black) msymbol(circle) msize(vsmall)) ///
		(rcap hi_cum lo_cum xpos_cum, lcolor(orange%60) lwidth(vthin)) ///
		(scatter b_cum xpos_cum, mcolor(orange) msymbol(square) msize(vsmall)) ///
		(rcap hi_snap_fix lo_snap_fix xpos_snap_fix, lcolor(blue%60) lwidth(vthin)) ///
		(scatter b_snap_fix xpos_snap_fix, mcolor(blue) msymbol(triangle) msize(vsmall)) ///
		(rcap hi_cum_fix lo_cum_fix xpos_cum_fix, lcolor(green%60) lwidth(vthin)) ///
		(scatter b_cum_fix xpos_cum_fix, mcolor(green) msymbol(diamond) msize(vsmall)), ///
		yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
		xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
		xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
		xscale(range(0.5 16.5)) ///
		xtitle("") ///
		ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
		ylabel(, grid gmin gmax labsize(small)) ///
		legend(order(2 "Mixed, year-varying (current)" 4 "FASE, year-varying" ///
			6 "Mixed, fixed P&V" 8 "FASE, fixed P&V") ///
			cols(2) size(small) position(6) ring(1) ///
			region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
		graphregion(color(white)) ///
		plotregion(margin(l=1 r=1))
	graph export "$figures/appendix/Figure_2_all_ses.pdf", as(pdf) replace
	restore
}
}

*------------------------------------------------------------
* CONSOLIDATED ROBUSTNESS R² TABLE (merges the former AT_pv_fig3_r2,
* AT_pv_fig3_r2_fixeddenom, and AT_pv_r2_benefsource into one table):
* 2 numerator variants (mixed snapshot -- current default; FASE-only
* cumulative, P&V's numerator) x 2 denominator choices (year-varying;
* fixed P&V-style), reusing r2_1/r2_2 (mixed snapshot, year-varying) and
* r2fix_1/r2fix_2 (mixed snapshot, fixed) computed above, plus a
* decomposition of how much of the R² gap to the P&V benchmark each fix
* closes on its own vs. combined, so the numerator vs. denominator
* choice can be judged separately.
* Output: $tables/appendix/AT_pv_r2_benefsource.tex
*------------------------------------------------------------
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999_fase inten2005_fase inten1999_fase_fix inten2005_fase_fix im_mun_1990
duplicates drop cve_ent_mun_super, force
count
local n_r2fase_mun = r(N)
di "`n_r2fase_mun' HM municipalities in the FASE-only correlation cross-section"

xtile marg_pctile_bin_hm_fase = im_mun_1990, nq(10)

reg inten1999_fase inten2005_fase
local r2fase_yv_1 : di %5.3f e(r2)
di "R² of inten1999_fase ~ inten2005_fase (HM sample, FASE-only numerator, year-varying denom): `r2fase_yv_1'   [mixed/year-varying: `r2_1'; P&V benchmark: 0.65]"

reg inten1999_fase inten2005_fase i.marg_pctile_bin_hm_fase
local r2fase_yv_2 : di %5.3f e(r2)

reg inten1999_fase_fix inten2005_fase_fix
local r2fase_fx_1 : di %5.3f e(r2)
di "R² of inten1999_fase_fix ~ inten2005_fase_fix (HM sample, FASE-only numerator, FIXED denom): `r2fase_fx_1'   [mixed/fixed: `r2fix_1'; P&V benchmark: 0.65]"

reg inten1999_fase_fix inten2005_fase_fix i.marg_pctile_bin_hm_fase
local r2fase_fx_2 : di %5.3f e(r2)

* Decomposition: how much of the baseline-to-P&V R² gap does each fix close
* on its own, vs. both combined, relative to the current-default
* (Mixed numerator, year-varying denom) baseline in the top-left cell.
local ddenom_1 : di %5.3f (real("`r2fix_1'")     - real("`r2_1'"))
local ddenom_2 : di %5.3f (real("`r2fix_2'")     - real("`r2_2'"))
local dnum_1   : di %5.3f (real("`r2fase_yv_1'") - real("`r2_1'"))
local dnum_2   : di %5.3f (real("`r2fase_yv_2'") - real("`r2_2'"))
local dboth_1  : di %5.3f (real("`r2fase_fx_1'") - real("`r2_1'"))
local dboth_2  : di %5.3f (real("`r2fase_fx_2'") - real("`r2_2'"))
di "Decomposition of Delta-R^2 vs. baseline (`r2_1'/`r2_2'): denom-fix-alone `ddenom_1'/`ddenom_2'; numerator-fix-alone `dnum_1'/`dnum_2'; both-combined `dboth_1'/`dboth_2'"

{
    cap file close r2b
    file open r2b using "$tables/appendix/AT_pv_r2_benefsource.tex", write replace
    file write r2b "\begin{tabular}{lcccc} \hline \hline" _n
    file write r2b "& \multicolumn{2}{c}{Year-varying denom.} & \multicolumn{2}{c}{Fixed (P\&V) denom.} \\" _n
    file write r2b "Numerator construction & R\textsuperscript{2} & + marg.\ pctile FE & R\textsuperscript{2} & + marg.\ pctile FE \\ \toprule" _n
    file write r2b "Mixed, single-year snapshot (current default) & `r2_1' & `r2_2' & `r2fix_1' & `r2fix_2' \\ " _n
    file write r2b "FASE-only, cumulative (P\&V's numerator) & `r2fase_yv_1' & `r2fase_yv_2' & `r2fase_fx_1' & `r2fase_fx_2' \\ " _n
    file write r2b "  & & & & \\ " _n
    file write r2b "P\&V (2023) benchmark & \multicolumn{2}{c}{0.65} & \multicolumn{2}{c}{0.65} \\ " _n
    file write r2b "\quad + marg.\ pctile FE benchmark & \multicolumn{2}{c}{0.67} & \multicolumn{2}{c}{0.67} \\ " _n
    file write r2b "\bottomrule" _n
    file write r2b "\multicolumn{5}{l}{\textit{Decomposition of \$\Delta R^2\$ vs.\ the current-default baseline (top-left cell):}} \\ " _n
    file write r2b "\quad Denominator fix alone, no marg.\ FE & \multicolumn{4}{c}{`ddenom_1'} \\ " _n
    file write r2b "\quad Denominator fix alone, + marg.\ FE & \multicolumn{4}{c}{`ddenom_2'} \\ " _n
    file write r2b "\quad Numerator fix alone, no marg.\ FE & \multicolumn{4}{c}{`dnum_1'} \\ " _n
    file write r2b "\quad Numerator fix alone, + marg.\ FE & \multicolumn{4}{c}{`dnum_2'} \\ " _n
    file write r2b "\quad Both combined, no marg.\ FE & \multicolumn{4}{c}{`dboth_1'} \\ " _n
    file write r2b "\quad Both combined, + marg.\ FE & \multicolumn{4}{c}{`dboth_2'} \\ " _n
    file write r2b "No.\ HM municipalities & \multicolumn{4}{c}{`n_r2fase_mun'} \\ " _n
    file write r2b "\end{tabular}"
    file close r2b
}
di "Table exported to: $tables/appendix/AT_pv_r2_benefsource.tex"
restore

*============================================================
* MERGED ROBUSTNESS TABLE: T2_b_mortality_fixeddenom
* Merges the former T2_b_mortality_fixeddenom (year-varying vs.\ fixed
* P&V denominator, mixed numerator only, all 3 panels) with the former
* appendix table AT_intensity_construction_comparison (mixed vs.\
* FASE-cumulative numerator, year-varying denom only, pooled panel only)
* into ONE table crossing BOTH choices for all three panels, so the
* denominator fix, the numerator/beneficiary-source fix, and both
* combined can each be judged against the current-default baseline
* (column 1) to see which one dominates the main DiD estimate:
*   Col 1: Mixed numerator,  year-varying denom (current default)
*   Col 2: FASE numerator,   year-varying denom (numerator fix alone)
*   Col 3: Mixed numerator,  fixed 1997 P&V denom (denominator fix alone)
*   Col 4: FASE numerator,   fixed 1997 P&V denom (both combined)
* Output: $tables/T2_b_mortality_fixeddenom.tex
*============================================================
foreach pnl in p f m {
    if "`pnl'" == "p" {
        local out65  emr65
        local wt65   popover65_
    }
    else if "`pnl'" == "f" {
        local out65  emr65f
        local wt65   popover65_f
    }
    else {
        local out65  emr65m
        local wt65   popover65_m
    }

    forval c = 1/4 {
        if `c' == 1 {
            local inten99v inten1999
            local inten05v inten2005
        }
        else if `c' == 2 {
            local inten99v inten1999_fase
            local inten05v inten2005_fase
        }
        else if `c' == 3 {
            local inten99v inten1999_fix
            local inten05v inten2005_fix
        }
        else {
            local inten99v inten1999_fase_fix
            local inten05v inten2005_fase_fix
        }

        local b99_fd_`pnl'_`c'  ""
        local se99_fd_`pnl'_`c' ""
        local b05_fd_`pnl'_`c'  ""
        local se05_fd_`pnl'_`c' ""
        local N_fd_`pnl'_`c'    ""

        cap noisily reghdfe `out65' c.`inten99v'#i.post c.`inten05v'#i.post c.sp_intensity ///
            [aw=`wt65'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
        if _rc == 0 & e(N) > 0 {
            local aux : di %12.3f _b[1.post#c.`inten99v']
            local t = abs(_b[1.post#c.`inten99v'] / _se[1.post#c.`inten99v'])
            if      `t' >= 2.576 local b99_fd_`pnl'_`c' = "`aux'***"
            else if `t' >= 1.96  local b99_fd_`pnl'_`c' = "`aux'**"
            else if `t' >= 1.645 local b99_fd_`pnl'_`c' = "`aux'*"
            else                  local b99_fd_`pnl'_`c' = "`aux'"
            local se99_fd_`pnl'_`c' : di %12.3f _se[1.post#c.`inten99v']

            local aux : di %12.3f _b[1.post#c.`inten05v']
            local t = abs(_b[1.post#c.`inten05v'] / _se[1.post#c.`inten05v'])
            if      `t' >= 2.576 local b05_fd_`pnl'_`c' = "`aux'***"
            else if `t' >= 1.96  local b05_fd_`pnl'_`c' = "`aux'**"
            else if `t' >= 1.645 local b05_fd_`pnl'_`c' = "`aux'*"
            else                  local b05_fd_`pnl'_`c' = "`aux'"
            local se05_fd_`pnl'_`c' : di %12.3f _se[1.post#c.`inten05v']
            local N_fd_`pnl'_`c' : di %12.0fc e(N)
        }
        else {
            di as error "Panel `pnl', construction `c': reghdfe failed or empty sample (rc=`_rc'), leaving cells blank"
        }
    }
}

{
    cap file close fd
    file open fd using "$tables/T2_b_mortality_fixeddenom.tex", write replace
    file write fd "\begin{tabular}{lcccc} \hline \hline" _n
    file write fd "& \multicolumn{2}{c}{Year-varying denom.} & \multicolumn{2}{c}{Fixed 1997 denom.\ (P\&V-style)} \\ " _n
    file write fd "& \multicolumn{1}{c}{Mixed} & \multicolumn{1}{c}{FASE} & \multicolumn{1}{c}{Mixed} & \multicolumn{1}{c}{FASE} \\ " _n
    file write fd "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
    file write fd "\underline{\textit{Panel A: Pooled}} \\ " _n
    file write fd "\textit{Intensity 1999 x post} & `b99_fd_p_1' & `b99_fd_p_2' & `b99_fd_p_3' & `b99_fd_p_4' \\ " _n
    file write fd " & (`se99_fd_p_1') & (`se99_fd_p_2') & (`se99_fd_p_3') & (`se99_fd_p_4') \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "\textit{Intensity 2005 x post} & `b05_fd_p_1' & `b05_fd_p_2' & `b05_fd_p_3' & `b05_fd_p_4' \\ " _n
    file write fd " & (`se05_fd_p_1') & (`se05_fd_p_2') & (`se05_fd_p_3') & (`se05_fd_p_4') \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "Obs & `N_fd_p_1' & `N_fd_p_2' & `N_fd_p_3' & `N_fd_p_4' \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "\underline{\textit{Panel B: Females}} \\ " _n
    file write fd "\textit{Intensity 1999 x post} & `b99_fd_f_1' & `b99_fd_f_2' & `b99_fd_f_3' & `b99_fd_f_4' \\ " _n
    file write fd " & (`se99_fd_f_1') & (`se99_fd_f_2') & (`se99_fd_f_3') & (`se99_fd_f_4') \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "\textit{Intensity 2005 x post} & `b05_fd_f_1' & `b05_fd_f_2' & `b05_fd_f_3' & `b05_fd_f_4' \\ " _n
    file write fd " & (`se05_fd_f_1') & (`se05_fd_f_2') & (`se05_fd_f_3') & (`se05_fd_f_4') \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "Obs & `N_fd_f_1' & `N_fd_f_2' & `N_fd_f_3' & `N_fd_f_4' \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "\underline{\textit{Panel C: Males}} \\ " _n
    file write fd "\textit{Intensity 1999 x post} & `b99_fd_m_1' & `b99_fd_m_2' & `b99_fd_m_3' & `b99_fd_m_4' \\ " _n
    file write fd " & (`se99_fd_m_1') & (`se99_fd_m_2') & (`se99_fd_m_3') & (`se99_fd_m_4') \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "\textit{Intensity 2005 x post} & `b05_fd_m_1' & `b05_fd_m_2' & `b05_fd_m_3' & `b05_fd_m_4' \\ " _n
    file write fd " & (`se05_fd_m_1') & (`se05_fd_m_2') & (`se05_fd_m_3') & (`se05_fd_m_4') \\ " _n
    file write fd "  & & & & \\ " _n
    file write fd "Obs & `N_fd_m_1' & `N_fd_m_2' & `N_fd_m_3' & `N_fd_m_4' \\ " _n
    file write fd "\bottomrule" _n
    file write fd "Corr(Mixed, FASE numerator), 1999 & \multicolumn{2}{c}{`corr99'} & \multicolumn{2}{c}{`corr99_fix'} \\ " _n
    file write fd "Corr(Mixed, FASE numerator), 2005 & \multicolumn{2}{c}{`corr05'} & \multicolumn{2}{c}{`corr05_fix'} \\ " _n
    file write fd "\end{tabular}"
    file close fd
}
di "Table exported to: $tables/T2_b_mortality_fixeddenom.tex"

*============================================================
* ROBUSTNESS FIGURE: Figure 2 analogue (f:es_dd_sex_no_weight) using the
* FIXED-DENOMINATOR (P&V-style) Intensity_1999/2005 in place of the
* current year-varying-denominator construction. Mirrors the main Figure
* 2 code exactly (weighted + Seguro Popular event study, pooled/female/
* male, ib6.year_1995 interactions, reference year 1996) with
* inten1999_fix/inten2005_fix substituted for inten1999/inten2005.
* Output: $figures/Figure_2_female_fixeddenom.pdf / _male_
* Pooled panel (Figure_2_pooled_fixeddenom.pdf) removed: it duplicated
* the pooled/Intensity_1999/fixed-denom series now shown as one of the
* four series in the combined appendix figure af:intensity_construction_
* comparison (Figure_2_all.pdf), so only female/male are exported here.
*============================================================
{
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
foreach grp in f m {
    if "`grp'" == "f" {
        local outcome emr65f
        local wvar   popover65_f
        local gcolor red
        local gsym   square
        local gname  female
    }
    else {
        local outcome emr65m
        local wvar   popover65_m
        local gcolor blue
        local gsym   triangle
        local gname  male
    }

    reghdfe `outcome' c.inten1999_fix##ib6.year_1995 c.inten2005_fix##ib6.year_1995 ///
        c.sp_intensity [aw=`wvar'] if $sample_marg, a(cve_ent_mun_super) ///
        vce(cluster cve_ent_mun_super)

    forval pos = 1/16 {
        if `pos' == 6 {
            local bfd_`pos'  = 0
            local sefd_`pos' = 0
        }
        else {
            local bfd_`pos'  = _b[`pos'.year_1995#c.inten1999_fix]
            local sefd_`pos' = _se[`pos'.year_1995#c.inten1999_fix]
        }
    }

    preserve
    clear
    set obs 16
    gen yr_pos = _n
    gen b  = .
    gen hi = .
    gen lo = .
    forval pos = 1/16 {
        replace b  = `bfd_`pos''                          if yr_pos == `pos'
        replace hi = `bfd_`pos'' + 1.96 * `sefd_`pos'' if yr_pos == `pos'
        replace lo = `bfd_`pos'' - 1.96 * `sefd_`pos'' if yr_pos == `pos'
    }
    twoway ///
        (rcap hi lo yr_pos, ///
            lcolor(`gcolor'%60) lwidth(vthin)) ///
        (scatter b yr_pos, ///
            mcolor(`gcolor') msymbol(`gsym') msize(vsmall)), ///
        yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
        xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
        xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
        xscale(range(0.5 16.5)) ///
        xtitle("") ///
        ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
        ylabel(, grid gmin gmax labsize(small)) ///
        legend(off) ///
        graphregion(color(white)) ///
        plotregion(margin(l=1 r=1))
    graph export "$figures/Figure_2_`gname'_fixeddenom.pdf", as(pdf) replace
    restore
}
}
di "Figures exported to: $figures/Figure_2_{pooled,female,male}_fixeddenom.pdf"

*------------------------------------------------------------
* Diagnostic requested alongside the R^2 discussion: how many
* municipality-years get clipped at Intensity>=1 under each denominator
* construction? Clipping compresses variation and could itself be part
* of why the fixed-denominator R^2 only rose modestly (0.16->0.24)
* rather than closing the gap to P&V's 0.65.
*------------------------------------------------------------
count if inten1999 >= 1 & !missing(inten1999) & $sample_marg
di "`r(N)' HM municipality-year obs with current-construction Intensity_1999 clipped at 1"
count if inten2005 >= 1 & !missing(inten2005) & $sample_marg
di "`r(N)' HM municipality-year obs with current-construction Intensity_2005 clipped at 1"
count if pgbenef_1999/hog1997_fixed >= 1 & !missing(hog1997_fixed) & $sample_marg
di "`r(N)' HM municipality-year obs with FIXED-denominator Intensity_1999 clipped at 1 (before clipping applied)"
count if pgbenef_2005/hog1997_fixed >= 1 & !missing(hog1997_fixed) & $sample_marg
di "`r(N)' HM municipality-year obs with FIXED-denominator Intensity_2005 clipped at 1 (before clipping applied)"

*============================================================
* D0b (PARTIAL): P&V eq.(4) LOCALITY-COMPOSITION-SHARE CONTROL
* Per user: the P&V replication package's raw data (including
* Base_marginacion_localidad_90-10.dta, the 1990-2010 locality-level
* CONAPO marginality index) is available in the user's Dropbox, same as
* every other external data source in this project -- just needs a path.
* SET THIS PATH before running:
*------------------------------------------------------------
global pvdata "$data/01_dataprep"
* ^ best guess, mirroring P&V's own internal "$data/01_dataprep/..."
*   convention reused against our existing $data root. ADJUST if the
*   user's actual folder is elsewhere (e.g. a "3 replication package"
*   subfolder, or a differently-named directory).
*------------------------------------------------------------
*
* Builds L^p_m: the share of each municipality's population living in
* localities at each percentile of the NATIONAL locality-marginality
* distribution, following P&V's own construction in
* "3 replication package/01_dataprep_programs/01_dataprep/
* 01_create_municipal_level_indicators.do" (lines ~358-383):
*   egen iml_pctile = cut(iml), group(100)
*   tab iml_pctile, gen(iml_pc)                      [locality-level 0/1 dummies]
*   collapse iml_pc* [aw=POB_TOT], by(CVE_EDO CVE_MUN) [pop-weighted mean = share]
* This is the deeper fix for Eduardo's endogeneity concern beyond
* AT_ses_trend (which only controls for MUNICIPALITY marginality percentile,
* not the within-municipality DISTRIBUTION of locality-level poverty).
*
* NOTE ON SCOPE: this builds the CONTROL only (does not require locality-
* level Progresa enrollment data). The actual P&V Figure-2 ANALOGUE (a
* scatter/lpoly plot of locality-level enrollment ratio vs. locality
* marginality percentile) additionally requires P&V's own locality-level
* beneficiary panel (fams_fase_20134xloc_f.dta) -- confirm separately
* whether that specific file is also in the copied data folder before
* that companion figure can be built; the control below does not depend
* on it.
*============================================================
* Non-destructive existence check: do NOT exit the whole do-file if the
* path guess is wrong -- just skip this block and let the rest of the
* script (T3, AT6, everything already built above) run normally.
local d0b_ok = 0
cap confirm file "$pvdata/Base_marginacion_localidad_90-10.dta"
if _rc {
    di as error "D0b SKIPPED: could not find $pvdata/Base_marginacion_localidad_90-10.dta -- verify/adjust the global pvdata path above and re-run this block only (nothing else in this file depends on it)."
}
else {
    local d0b_ok = 1
}

if `d0b_ok' {
    preserve
    use "$pvdata/Base_marginacion_localidad_90-10.dta", clear
    di "`c(N)' localities loaded (all years) from Base_marginacion_localidad_90-10.dta"

    keep if año == 1995
    di "`c(N)' localities in the 1995 cross-section"

    * Same field parsing as P&V's own 04_rollout_locality.do: CVE_LOC packs
    * municipality (3 digits) and locality (4 digits) into one numeric ID.
    rename CVE_ENT CVE_EDO
    gen id = string(CVE_LOC, "%12.0f")
    gen CVE_MUNICIPIO = real(substr(id, -7, 3))
    gen CVE_LOCALIDAD = real(substr(id, -4, 4))
    drop CVE_MUN CVE_LOC id
    rename CVE_MUNICIPIO CVE_MUN
    rename CVE_LOCALIDAD loc

    cap confirm string variable TOT_VIV
    if !_rc {
        replace TOT_VIV = "." if TOT_VIV == "-"
        destring TOT_VIV, replace
    }

    count if missing(iml)
    di "`r(N)' localities missing the continuous marginality index (iml) -- dropped from the percentile ranking"
    drop if missing(iml)

    * Percentile dummies over the FULL NATIONAL locality distribution,
    * exactly matching P&V's construction (not restricted to HM localities).
    egen iml_pctile = cut(iml), group(100)
    tab iml_pctile, gen(iml_pc)
    drop iml_pctile

    count if missing(POB_TOT)
    di "`r(N)' localities missing POB_TOT (population weight) -- dropped before the population-weighted collapse"
    drop if missing(POB_TOT)

    * Population-weighted collapse to municipality level: the mean of each
    * 0/1 percentile dummy, weighted by locality population, equals the
    * SHARE of the municipality's population living in that percentile bin.
    collapse (mean) iml_pc* [aw=POB_TOT], by(CVE_EDO CVE_MUN)
    di "`c(N)' municipalities (raw CVE_EDO/CVE_MUN codes) with locality-composition shares built"

    * Cross-walk from raw state/municipality codes to our harmonized
    * cve_ent_mun_super, reusing the SAME crosswalk file already used
    * elsewhere in this project (e.g. the spmap figures above).
    rename CVE_EDO cve_ent
    rename CVE_MUN cve_mun
    cap tostring cve_ent, replace format(%02.0f)
    cap tostring cve_mun, replace format(%03.0f)
    merge m:1 cve_ent cve_mun using "$data/crosswalk_super_mun_id_1990.dta", ///
        keepusing(cve_ent_mun_super) nogenerate
    count if missing(cve_ent_mun_super)
    di "`r(N)' municipalities failed to match the cve_ent_mun_super crosswalk -- inspect cve_ent/cve_mun format (string vs numeric, zero-padding) if this count is large"
    drop if missing(cve_ent_mun_super)

    duplicates drop cve_ent_mun_super, force
    tempfile loc_shares
    save `loc_shares'
    di "`c(N)' municipalities with locality-composition-share controls, ready to merge onto the main panel"
    restore

    merge m:1 cve_ent_mun_super using `loc_shares', nogenerate
    count if missing(iml_pc1) & $sample_marg & year==1996
    di "`r(N)' HM municipalities missing locality-composition shares after merge onto the main panel"

    *------------------------------------------------------------
    * Extend the fn.18-style R² table with P&V's third row: adding the
    * full set of locality-composition-share controls on top of
    * Intensity_2005 and the municipality-marginality-percentile FE.
    * Matches P&V's own 65% -> 67% -> 75% progression (04_rollout_muni.do:
    * "reg prop9799 prop9705 i.margpct iml_pc* if marginado==1").
    *------------------------------------------------------------
    preserve
    keep if year == 1996 & $sample_marg
    keep cve_ent_mun_super inten1999 inten2005 im_mun_1990 iml_pc*
    duplicates drop cve_ent_mun_super, force
    count if missing(iml_pc1)
    local n_missing_locshare = r(N)
    di "`n_missing_locshare' HM municipalities missing locality-composition shares (excluded from row 3 of the R² table)"

    xtile marg_pctile_bin_hm_l4 = im_mun_1990, nq(10)

    reg inten1999 inten2005 i.marg_pctile_bin_hm_l4 iml_pc*
    local r2_3 : di %5.3f e(r2)
    di "R² of inten1999 ~ inten2005 + marg-percentile FE + locality-composition shares (HM sample): `r2_3'   [P&V fn.18 benchmark: 0.75]"
    restore

    di "NOTE: manually add a 'locality marginality-share FE' decomposition row to AT_pv_r2_benefsource.tex (Mixed numerator, year-varying denom, r2_3=`r2_3'; P&V benchmark 0.75) once confirmed -- not auto-written to avoid silently overwriting that table before this block has been validated against real data."
}

