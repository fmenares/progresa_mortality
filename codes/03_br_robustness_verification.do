*============================================================
* BR 2013 Robustness: DD with sample & weighting variations
* Purpose: Test whether Barham & Rowberry (2013) results hold
*          with FE approach, high-marginalization sample,
*          65+ weighting, and SP intensity controls
* Input: same data as 02_mortality.do
* Output: Two tables (emr65 & aamr65) with 9 DD specifications
*============================================================

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
global sample_br = "(inten_start_year==1998 |inten_start_year==1999)"

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

*============================================================
* Run DD Regressions: 9 specifications for each outcome
*============================================================

* Sample definitions for the table
* 1. sample_br: BR sample (unweighted, UW+SP, W+SP)
* 2. sample_marg: highly marginalized municipalities (UW, UW+SP, W+SP)
* 3. sample_br & sample_marg: BR sample restricted to high marginalization (UW, UW+SP, W+SP)

* Store results in matrices
matrix results_emr65 = J(6, 9, .)
matrix results_aamr65 = J(6, 9, .)
matrix colnames results_emr65 = "br_uw" "br_uwsp" "br_wsp" "marg_uw" "marg_uwsp" "marg_wsp" "brmarg_uw" "brmarg_uwsp" "brmarg_wsp"
matrix colnames results_aamr65 = "br_uw" "br_uwsp" "br_wsp" "marg_uw" "marg_uwsp" "marg_wsp" "brmarg_uw" "brmarg_uwsp" "brmarg_wsp"
matrix rownames results_emr65 = "coef" "se" "t_stat" "n_obs" "n_mun" "mean_pre"
matrix rownames results_aamr65 = "coef" "se" "t_stat" "n_obs" "n_mun" "mean_pre"

local col_idx = 1

* === SAMPLE 1: sample_br (BR sample) ===
* Col 1: BR, UW
reghdfe emr65 c.inten1999#i.post ///
    if inrange(year,1992,2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,1] = _b[1.post#c.inten1999]
matrix results_emr65[2,1] = _se[1.post#c.inten1999]
matrix results_emr65[3,1] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,1] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,1] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,1] = r(mean)

reghdfe aamr65 c.inten1999#i.post ///
    if inrange(year,1992,2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,1] = _b[1.post#c.inten1999]
matrix results_aamr65[2,1] = _se[1.post#c.inten1999]
matrix results_aamr65[3,1] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,1] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,1] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,1] = r(mean)

* Col 2: BR, UW + SP
reghdfe emr65 c.inten1999#i.post c.sp_intensity ///
    if inrange(year,1992,2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,2] = _b[1.post#c.inten1999]
matrix results_emr65[2,2] = _se[1.post#c.inten1999]
matrix results_emr65[3,2] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,2] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,2] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,2] = r(mean)

reghdfe aamr65 c.inten1999#i.post c.sp_intensity ///
    if inrange(year,1992,2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,2] = _b[1.post#c.inten1999]
matrix results_aamr65[2,2] = _se[1.post#c.inten1999]
matrix results_aamr65[3,2] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,2] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,2] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,2] = r(mean)

* Col 3: BR, W + SP
reghdfe emr65 c.inten1999#i.post c.sp_intensity [aw=popover65_] ///
    if inrange(year,1992,2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,3] = _b[1.post#c.inten1999]
matrix results_emr65[2,3] = _se[1.post#c.inten1999]
matrix results_emr65[3,3] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,3] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,3] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,3] = r(mean)

reghdfe aamr65 c.inten1999#i.post c.sp_intensity [aw=popover65_] ///
    if inrange(year,1992,2002) & $sample_br, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,3] = _b[1.post#c.inten1999]
matrix results_aamr65[2,3] = _se[1.post#c.inten1999]
matrix results_aamr65[3,3] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,3] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,3] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,3] = r(mean)

* === SAMPLE 2: sample_marg (highly marginalized only) ===
* Col 4: Marg, UW
reghdfe emr65 c.inten1999#i.post ///
    if inrange(year,1992,2002) & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,4] = _b[1.post#c.inten1999]
matrix results_emr65[2,4] = _se[1.post#c.inten1999]
matrix results_emr65[3,4] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,4] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,4] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,4] = r(mean)

reghdfe aamr65 c.inten1999#i.post ///
    if inrange(year,1992,2002) & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,4] = _b[1.post#c.inten1999]
matrix results_aamr65[2,4] = _se[1.post#c.inten1999]
matrix results_aamr65[3,4] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,4] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,4] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,4] = r(mean)

* Col 5: Marg, UW + SP
reghdfe emr65 c.inten1999#i.post c.sp_intensity ///
    if inrange(year,1992,2002) & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,5] = _b[1.post#c.inten1999]
matrix results_emr65[2,5] = _se[1.post#c.inten1999]
matrix results_emr65[3,5] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,5] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,5] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,5] = r(mean)

reghdfe aamr65 c.inten1999#i.post c.sp_intensity ///
    if inrange(year,1992,2002) & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,5] = _b[1.post#c.inten1999]
matrix results_aamr65[2,5] = _se[1.post#c.inten1999]
matrix results_aamr65[3,5] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,5] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,5] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,5] = r(mean)

* Col 6: Marg, W + SP
reghdfe emr65 c.inten1999#i.post c.sp_intensity [aw=popover65_] ///
    if inrange(year,1992,2002) & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,6] = _b[1.post#c.inten1999]
matrix results_emr65[2,6] = _se[1.post#c.inten1999]
matrix results_emr65[3,6] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,6] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,6] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,6] = r(mean)

reghdfe aamr65 c.inten1999#i.post c.sp_intensity [aw=popover65_] ///
    if inrange(year,1992,2002) & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,6] = _b[1.post#c.inten1999]
matrix results_aamr65[2,6] = _se[1.post#c.inten1999]
matrix results_aamr65[3,6] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,6] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,6] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,6] = r(mean)

* === SAMPLE 3: sample_br & sample_marg (BR in high marginalization) ===
* Col 7: BR & Marg, UW
reghdfe emr65 c.inten1999#i.post ///
    if inrange(year,1992,2002) & $sample_br & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,7] = _b[1.post#c.inten1999]
matrix results_emr65[2,7] = _se[1.post#c.inten1999]
matrix results_emr65[3,7] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,7] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,7] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,7] = r(mean)

reghdfe aamr65 c.inten1999#i.post ///
    if inrange(year,1992,2002) & $sample_br & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,7] = _b[1.post#c.inten1999]
matrix results_aamr65[2,7] = _se[1.post#c.inten1999]
matrix results_aamr65[3,7] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,7] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,7] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,7] = r(mean)

* Col 8: BR & Marg, UW + SP
reghdfe emr65 c.inten1999#i.post c.sp_intensity ///
    if inrange(year,1992,2002) & $sample_br & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,8] = _b[1.post#c.inten1999]
matrix results_emr65[2,8] = _se[1.post#c.inten1999]
matrix results_emr65[3,8] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,8] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,8] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,8] = r(mean)

reghdfe aamr65 c.inten1999#i.post c.sp_intensity ///
    if inrange(year,1992,2002) & $sample_br & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,8] = _b[1.post#c.inten1999]
matrix results_aamr65[2,8] = _se[1.post#c.inten1999]
matrix results_aamr65[3,8] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,8] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,8] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,8] = r(mean)

* Col 9: BR & Marg, W + SP
reghdfe emr65 c.inten1999#i.post c.sp_intensity [aw=popover65_] ///
    if inrange(year,1992,2002) & $sample_br & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_emr65[1,9] = _b[1.post#c.inten1999]
matrix results_emr65[2,9] = _se[1.post#c.inten1999]
matrix results_emr65[3,9] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_emr65[4,9] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_emr65[5,9] = r(ndistinct)
sum emr65 if e(sample) & post==2
matrix results_emr65[6,9] = r(mean)

reghdfe aamr65 c.inten1999#i.post c.sp_intensity [aw=popover65_] ///
    if inrange(year,1992,2002) & $sample_br & $sample_marg, ///
    a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
matrix results_aamr65[1,9] = _b[1.post#c.inten1999]
matrix results_aamr65[2,9] = _se[1.post#c.inten1999]
matrix results_aamr65[3,9] = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
matrix results_aamr65[4,9] = e(N)
distinct cve_ent_mun_super if e(sample)
matrix results_aamr65[5,9] = r(ndistinct)
sum aamr65 if e(sample) & post==2
matrix results_aamr65[6,9] = r(mean)

*============================================================
* Display & Export Results
*============================================================

di "=== EXCESS MORTALITY RATE (EMR65) RESULTS ==="
matrix list results_emr65

di ""
di "=== AGE-ADJUSTED MORTALITY RATE (AAMR65) RESULTS ==="
matrix list results_aamr65

*============================================================
* Build formatted LaTeX tables
*============================================================

* Table for EMR65
{
	cap file close tbl
	file open tbl using "$tables/T_BR_robustness_emr65.tex", write replace
	file write tbl "\begin{tabular}{lcccccccccc} \hline \hline" _n
	file write tbl "& \multicolumn{3}{c}{\textit{BR Sample}} " _n
	file write tbl "& \multicolumn{3}{c}{\textit{High Marginalization}} " _n
	file write tbl "& \multicolumn{3}{c}{\textit{BR \& High Marg}} \\ \cmidrule(lr){2-4}\cmidrule(lr){5-7}\cmidrule(lr){8-10}" _n
	file write tbl "& \multicolumn{1}{c}{UW} & \multicolumn{1}{c}{UW+SP} & \multicolumn{1}{c}{W+SP} & \multicolumn{1}{c}{UW} & \multicolumn{1}{c}{UW+SP} & \multicolumn{1}{c}{W+SP} & \multicolumn{1}{c}{UW} & \multicolumn{1}{c}{UW+SP} & \multicolumn{1}{c}{W+SP} \\ " _n
	file write tbl "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} & \multicolumn{1}{c}{(9)} \\ \toprule" _n
	file write tbl "\textit{Intensity x Post (1997-2002)}"
	forval i = 1/9 {
		local coef = results_emr65[1,`i']
		local t = results_emr65[3,`i']
		if `t' >= 2.576 file write tbl "& " %9.3f (`coef') "***"
		else if `t' >= 1.96  file write tbl "& " %9.3f (`coef') "**"
		else if `t' >= 1.645 file write tbl "& " %9.3f (`coef') "*"
		else                  file write tbl "& " %9.3f (`coef') ""
	}
	file write tbl " \\ " _n
	file write tbl " "
	forval i = 1/9 {
		local se = results_emr65[2,`i']
		file write tbl "& (" %9.3f (`se') ")"
	}
	file write tbl " \\ " _n
	file write tbl "  & & & & & & & & & \\ " _n
	file write tbl "Mean (1991-1996)"
	forval i = 1/9 {
		local mean = results_emr65[6,`i']
		file write tbl "& " %9.2f (`mean') ""
	}
	file write tbl " \\ " _n
	file write tbl "Obs"
	forval i = 1/9 {
		local n = results_emr65[4,`i']
		file write tbl "& " %9.0f (`n') ""
	}
	file write tbl " \\ " _n
	file write tbl "No. Mun"
	forval i = 1/9 {
		local nmun = results_emr65[5,`i']
		file write tbl "& " %9.0f (`nmun') ""
	}
	file write tbl " \\ \bottomrule" _n
	file write tbl "\end{tabular}"
	file close tbl
}

* Table for AAMR65
{
	cap file close tbl
	file open tbl using "$tables/T_BR_robustness_aamr65.tex", write replace
	file write tbl "\begin{tabular}{lcccccccccc} \hline \hline" _n
	file write tbl "& \multicolumn{3}{c}{\textit{BR Sample}} " _n
	file write tbl "& \multicolumn{3}{c}{\textit{High Marginalization}} " _n
	file write tbl "& \multicolumn{3}{c}{\textit{BR \& High Marg}} \\ \cmidrule(lr){2-4}\cmidrule(lr){5-7}\cmidrule(lr){8-10}" _n
	file write tbl "& \multicolumn{1}{c}{UW} & \multicolumn{1}{c}{UW+SP} & \multicolumn{1}{c}{W+SP} & \multicolumn{1}{c}{UW} & \multicolumn{1}{c}{UW+SP} & \multicolumn{1}{c}{W+SP} & \multicolumn{1}{c}{UW} & \multicolumn{1}{c}{UW+SP} & \multicolumn{1}{c}{W+SP} \\ " _n
	file write tbl "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} & \multicolumn{1}{c}{(9)} \\ \toprule" _n
	file write tbl "\textit{Intensity x Post (1997-2002)}"
	forval i = 1/9 {
		local coef = results_aamr65[1,`i']
		local t = results_aamr65[3,`i']
		if `t' >= 2.576 file write tbl "& " %9.3f (`coef') "***"
		else if `t' >= 1.96  file write tbl "& " %9.3f (`coef') "**"
		else if `t' >= 1.645 file write tbl "& " %9.3f (`coef') "*"
		else                  file write tbl "& " %9.3f (`coef') ""
	}
	file write tbl " \\ " _n
	file write tbl " "
	forval i = 1/9 {
		local se = results_aamr65[2,`i']
		file write tbl "& (" %9.3f (`se') ")"
	}
	file write tbl " \\ " _n
	file write tbl "  & & & & & & & & & \\ " _n
	file write tbl "Mean (1991-1996)"
	forval i = 1/9 {
		local mean = results_aamr65[6,`i']
		file write tbl "& " %9.2f (`mean') ""
	}
	file write tbl " \\ " _n
	file write tbl "Obs"
	forval i = 1/9 {
		local n = results_aamr65[4,`i']
		file write tbl "& " %9.0f (`n') ""
	}
	file write tbl " \\ " _n
	file write tbl "No. Mun"
	forval i = 1/9 {
		local nmun = results_aamr65[5,`i']
		file write tbl "& " %9.0f (`nmun') ""
	}
	file write tbl " \\ \bottomrule" _n
	file write tbl "\end{tabular}"
	file close tbl
}

di ""
di "Tables exported to:"
di "  $tables/T_BR_robustness_emr65.tex"
di "  $tables/T_BR_robustness_aamr65.tex"
