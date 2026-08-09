*** ============================================================================================================
*** TOPIC: Extra robustness / binary-threshold checks and descriptive-
*** diagnostic tables and figures for Progresa Intensity_1999, moved out
*** of 02_mortality.do per the coauthor's requests over several sessions.
*** Renamed from binary_and_descriptives.do to 04_extra_robustness.do.
*** Currently holds: the binary high-vs-low event study (D2/D2b) and the
*** threshold-validation/threshold-categorical design (formerly AF12-15/
*** AT15-17); the intensity-construction time-series figure (former AF3,
*** af:intensity_timeseries); the R^2 decomposition, intensity
*** correlations, power/MDE, crosswalk super-municipality diagnostic, and
*** saturation diagnostics tables (formerly appendix tables A.8-A.12).
*** Loads the working panel checkpointed by 02_mortality.do right before
*** this code used to run, so it needs no separate data-construction pass.
***
*** STATUS: all table (`file open/write/close') and figure
*** (`graph export') output has been commented out below -- this file no
*** longer writes any .tex/.pdf into tables/appendix or figures/appendix.
*** All underlying regressions (reghdfe/reg/corr) and `di' diagnostics
*** still run as before and stream to the log file opened right below, so
*** the numeric results remain available for review without regenerating
*** any paper exhibit. Uncomment a block's `graph export'/`file open...
*** file close' lines to restore that output.
*** ============================================================================================================
cls
clear
set more off

 if c(username)=="FELIPEME" {
	global data "C:\Users\FELIPEME\Dropbox\2026\progresa_mortality/data/"
	global codes "C:\Users\FELIPEME\Documents\projects\progresa_mortality\codes\"
	global tables  "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\tables"
	global figures "C:\Users\FELIPEME\Dropbox\Aplicaciones\Overleaf\progresa_cct\figures"
}

 if c(username)=="root" {
	global data "/home/user/progresa_mortality/data/"
	global codes "/home/user/progresa_mortality/codes/"
	global tables "/home/user/progresa_mortality/tables"
	global figures "/home/user/progresa_mortality/figures"
}

global sample_marg = "(gm_mun_1990==4|gm_mun_1990==5)"

cap log close _all
log using "$codes/04_extra_robustness_log.log", replace text

use "$data/Temp_data/working_panel_for_binary_and_descriptives.dta", clear

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
*
* Uses inten1999_fix (End-of-year numerator, fixed 1997 P&V denominator)
* -- the coauthor-preferred main specification (PART 7), matching column
* 3 of T2_b_mortality_fixeddenom -- rather than inten1999 (year-varying
* denominator), which this block used before that decision.
* Output: $figures/appendix/AF_binary_es.pdf, $tables/appendix/AT_binary_es.tex
*============================================================

local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'

* Determine data-driven thresholds from the HM municipality cross-section
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999_fix
duplicates drop cve_ent_mun_super, force
su inten1999_fix, detail
local thr_p50 = r(p50)
local thr_p75 = r(p75)
di "Median Intensity_1999 (End-of-year, fixed denom, HM sample): " %5.3f `thr_p50'
di "75th percentile Intensity_1999 (End-of-year, fixed denom, HM sample): " %5.3f `thr_p75'
restore

cap drop treated_15 treated_med treated_p75
gen treated_15  = (inten1999_fix >= 0.15)      if !missing(inten1999_fix)
gen treated_med = (inten1999_fix >= `thr_p50') if !missing(inten1999_fix)
gen treated_p75 = (inten1999_fix >= `thr_p75') if !missing(inten1999_fix)

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
* graph export "$figures/appendix/AF_binary_es.pdf", as(pdf) replace
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

/*
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
*/
di "Table exported to: $tables/appendix/AT_binary_es.tex"

*============================================================
* D2b: TWO-BINARY VERSION OF THE THRESHOLD MODEL (ADDITIONAL result
* alongside D2 above -- does not replace it). Addresses the critique in
* research_project.md (PART 6(6)(a) and its "Net recommendation"): a
* single high-vs-low cut on Intensity_1999 alone treats "low" as if it
* were a control group, but under saturation the low group keeps
* enrolling through 2000-2005, so its own later-phase catch-up
* contaminates the high-vs-low mortality gap ("the binarized version
* needs its own later-phase split -- it collapses back to the
* {Early, Late-only, Never} design, not a simpler alternative to it").
* The fix: TWO binary indicators, mirroring the continuous T2
* specification's two intensity variables, instead of one:
*   High_1999 = 1[Intensity_1999_fix >= c]  (= treated_15/treated_med/
*                                              treated_p75 from D2 above)
*   High_2005 = 1[Intensity_2005_fix >= c]  (new: treated05_15/_med/_p75)
* both entered as separate Post-interactions, giving the "low" group an
* explicit later-phase escape route instead of collapsing it into a
* single static contrast.
*
* Uses the SAME threshold grid as D2/AT_binary_es (15% a priori; median
* and 75th percentile of Intensity_1999_fix, HM sample, 1996 cross-
* section -- thr_p50/thr_p75 computed in D2 above), applied to BOTH
* Intensity_1999 and Intensity_2005, matching the convention already
* used in the Early/Late-only/Never/High-Low categorical design
* (AT_threshold_categorical). Appendix Table~at:binary_es
* reports the exact numeric threshold values and the High_1999/Low_1999
* municipality counts; this section's own table cross-references that
* one rather than repeating them, and adds the new High_2005/Low_2005
* counts.
* Output: $figures/appendix/AF_binary_es_2bin_{15,med,p75}.pdf,
*         $tables/appendix/AT_binary_es_2bin.tex
*============================================================
cap drop treated05_15 treated05_med treated05_p75
gen treated05_15  = (inten2005_fix >= 0.15)      if !missing(inten2005_fix)
gen treated05_med = (inten2005_fix >= `thr_p50') if !missing(inten2005_fix)
gen treated05_p75 = (inten2005_fix >= `thr_p75') if !missing(inten2005_fix)

foreach v in treated05_15 treated05_med treated05_p75 {
    count if $sample_marg & year==1996 & `v'==1
    local n1_`v' = r(N)
    count if $sample_marg & year==1996 & `v'==0
    local n0_`v' = r(N)
    di "`v': `n1_`v'' high / `n0_`v'' low (HM municipalities, 1996)"
}

* --- Event study: one combined graph, all 3 thresholds overlaid ---
* High_2005 x year is still estimated in every regression below (it is
* the later-phase/final-enrollment-status control this design needs,
* mirroring Intensity_2005's role in the continuous main spec -- see
* the coauthor's confirmed reading in the table note below), but its
* coefficient is not plotted: like Intensity_2005 x post in the main
* spec, it has no stand-alone interpretation of its own here.
foreach spec in 15 med p75 {
    if "`spec'" == "15" {
        local v99 treated_15
        local v05 treated05_15
    }
    else if "`spec'" == "med" {
        local v99 treated_med
        local v05 treated05_med
    }
    else {
        local v99 treated_p75
        local v05 treated05_p75
    }

    reghdfe emr65 c.`v99'##ib6.year_1995 c.`v05'##ib6.year_1995 c.sp_intensity ///
        [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
    forval pos = 1/16 {
        if `pos' == 6 {
            local b2b_`spec'_`pos'  = 0
            local se2b_`spec'_`pos' = 0
        }
        else {
            local b2b_`spec'_`pos'  = _b[`pos'.year_1995#c.`v99']
            local se2b_`spec'_`pos' = _se[`pos'.year_1995#c.`v99']
        }
    }
}

preserve
clear
set obs 16
gen yr_pos = _n
gen xpos_15  = yr_pos - 0.18
gen xpos_med = yr_pos
gen xpos_p75 = yr_pos + 0.18
foreach spec in 15 med p75 {
    gen b_`spec'  = .
    gen hi_`spec' = .
    gen lo_`spec' = .
}
forval pos = 1/16 {
    foreach spec in 15 med p75 {
        replace b_`spec'  = `b2b_`spec'_`pos''                            if yr_pos == `pos'
        replace hi_`spec' = `b2b_`spec'_`pos'' + 1.96 * `se2b_`spec'_`pos'' if yr_pos == `pos'
        replace lo_`spec' = `b2b_`spec'_`pos'' - 1.96 * `se2b_`spec'_`pos'' if yr_pos == `pos'
    }
}

twoway ///
    (rcap hi_15 lo_15 xpos_15, lcolor(black%60) lwidth(vthin) lpattern(solid)) ///
    (scatter b_15 xpos_15, mcolor(black) msymbol(circle) msize(vsmall)) ///
    (rcap hi_med lo_med xpos_med, lcolor(red%60) lwidth(vthin) lpattern(dash)) ///
    (scatter b_med xpos_med, mcolor(red) msymbol(square) msize(vsmall)) ///
    (rcap hi_p75 lo_p75 xpos_p75, lcolor(blue%60) lwidth(vthin) lpattern(shortdash_dot)) ///
    (scatter b_p75 xpos_p75, mcolor(blue) msymbol(triangle) msize(vsmall)) ///
    (line b_15 xpos_15 if 1==0, lcolor(black) lpattern(solid) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)) ///
    (line b_med xpos_med if 1==0, lcolor(red) lpattern(dash) lwidth(thin) mcolor(red) msymbol(square) msize(vsmall)) ///
    (line b_p75 xpos_p75 if 1==0, lcolor(blue) lpattern(shortdash_dot) lwidth(thin) mcolor(blue) msymbol(triangle) msize(vsmall)), ///
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
* graph export "$figures/appendix/AF_binary_es_2bin.pdf", as(pdf) replace
restore
di "Figure exported to: $figures/appendix/AF_binary_es_2bin.pdf"

*------------------------------------------------------------
* Companion TABLE: two-binary Post-interaction estimates (mirrors D2's
* AT_binary_es point-estimate companion). High_2005xPost is still
* estimated in every regression below (the later-phase/final-enrollment
* control this design needs) but is not printed -- like Intensity_2005 x
* post in the main spec, it has no stand-alone interpretation here.
* Reuses threshname1/2/3 (defined in D2 above) so the threshold labels
* match AT_binary_es exactly. High_1999/Low_1999 counts are NOT repeated
* here -- see Appendix Table~at:binary_es -- only the new High_2005/
* Low_2005 counts are reported.
* Output: $tables/appendix/AT_binary_es_2bin.tex
*------------------------------------------------------------
local i = 0
foreach spec in 15 med p75 {
    local ++i
    if "`spec'" == "15" {
        local v99 treated_15
        local v05 treated05_15
    }
    else if "`spec'" == "med" {
        local v99 treated_med
        local v05 treated05_med
    }
    else {
        local v99 treated_p75
        local v05 treated05_p75
    }
    reghdfe emr65 c.`v99'#i.post c.`v05'#i.post c.sp_intensity ///
        [aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)

    local aux : di %9.3f _b[1.post#c.`v99']
    local tstat = abs(_b[1.post#c.`v99'] / _se[1.post#c.`v99'])
    if      `tstat' >= 2.576 local b99t_`i' = trim("`aux'") + "***"
    else if `tstat' >= 1.960 local b99t_`i' = trim("`aux'") + "**"
    else if `tstat' >= 1.645 local b99t_`i' = trim("`aux'") + "*"
    else                     local b99t_`i' = trim("`aux'")
    local se99t_`i' : di %9.3f _se[1.post#c.`v99']

    local Nt2_`i' : di %12.0fc e(N)
}

/*
{
    cap file close bin2
    file open bin2 using "$tables/appendix/AT_binary_es_2bin.tex", write replace
    file write bin2 "\begin{tabular}{lcccc} \hline \hline" _n
    file write bin2 "Threshold & Intensity 1999 x Post & Obs & High\textsubscript{2005} & Low\textsubscript{2005} \\ \toprule" _n
    file write bin2 "`threshname1' & `b99t_1' & `Nt2_1' & `n1_treated05_15' & `n0_treated05_15' \\ " _n
    file write bin2 " & (`se99t_1') & & & \\ " _n
    file write bin2 "  & & & & \\ " _n
    file write bin2 "`threshname2' & `b99t_2' & `Nt2_2' & `n1_treated05_med' & `n0_treated05_med' \\ " _n
    file write bin2 " & (`se99t_2') & & & \\ " _n
    file write bin2 "  & & & & \\ " _n
    file write bin2 "`threshname3' & `b99t_3' & `Nt2_3' & `n1_treated05_p75' & `n0_treated05_p75' \\ " _n
    file write bin2 " & (`se99t_3') & & & \\ " _n
    file write bin2 "\bottomrule" _n
    file write bin2 "\end{tabular}"
    file close bin2
}
*/
di "Table exported to: $tables/appendix/AT_binary_es_2bin.tex"


*============================================================
* RAW MORTALITY-BY-GROUP-OVER-TIME FIGURE: threshold validation for the
* Early/Late-only/Never categorical design (research_project.md PART 6,
* items 1-4 and 7). This is the raw-data companion the user asked to
* "resurface" -- unmodeled, population-weighted mean emr65 by year, one
* line per group, across a threshold grid, to (a) visually pre-trend-
* test the groups with no modeling, and (b) show directly that the
* low-low ("Never") cell is empty at 15% and only becomes populated at a
* higher threshold, matching the count correction in PART 6(7).
*
* Groups use inten1999_fix / inten2005_fix -- the End-of-year numerator,
* fixed 1997 P&V denominator, the coauthor-preferred main construction
* (PART 7, column 3 of T2_b_mortality_fixeddenom) -- NOT the FASE-
* cumulative construction this block originally used. Switching to
* End-of-year matters here specifically because it is NOT guaranteed
* monotonic (25 HM municipalities have Intensity_2005 < Intensity_1999;
* AT_crosswalk_supermun_diagnostic), so the ORIGINAL three-way sequential
* assignment (each `replace' broadening the condition and overwriting
* the previous one) would have silently mis-classified any municipality
* that is high at 1999 but drops back below c by 2005 as "Never" instead
* of flagging it -- exactly the kind of silent error the FASE-cumulative
* version could not produce (nesting was guaranteed there). Fixed here by
* using a genuine 4-way partition on the mutually-exclusive AND-conditions
* of (Intensity_1999 >= c, Intensity_2005 >= c), adding an explicit
* "High-Low" (non-monotone) cell rather than letting it fall through:
*   Early(c):     Intensity_1999_fix >= c  AND Intensity_2005_fix >= c
*   Late-only(c): Intensity_1999_fix <  c  AND Intensity_2005_fix >= c
*   Never(c):     Intensity_1999_fix <  c  AND Intensity_2005_fix <  c
*   High-Low(c):  Intensity_1999_fix >= c  AND Intensity_2005_fix <  c  (non-monotone)
*
* Thresholds are chosen OUTCOME-BLIND, per the credibility caveat in
* PART 6(7): 15% (the a priori cut used elsewhere in this project), and
* the median and upper-tercile of Intensity_1999_fix in the 1996 HM
* cross-section (distribution-based, not chosen to maximize any visible
* mortality gap). Population-weighted by popover65_, pooled sample only
* for this first build (a female/male split, and an unweighted companion
* panel, are natural extensions -- see PART 6(7) and PART 6(2) on
* weighting -- not built here).
* Output: $figures/appendix/AF_threshold_validation_15.pdf,
*         $figures/appendix/AF_threshold_validation_median.pdf,
*         $figures/appendix/AF_threshold_validation_tercile.pdf
* (the cell counts computed here feed AT_threshold_categorical.tex
* below, not a separate table of their own -- see the note after this
* foreach loop)
*------------------------------------------------------------
preserve
keep if $sample_marg & inrange(year, 1991, 2006)

count if missing(inten1999_fix) | missing(inten2005_fix)
di "`r(N)' HM municipality-years dropped for missing End-of-year fixed-denom intensity in the threshold-validation figure"
drop if missing(inten1999_fix) | missing(inten2005_fix)

* --- Outcome-blind thresholds from the 1996 (pre-period) cross-section ---
* NOTE: `summarize, detail` only stores the fixed percentiles p1/p5/p10/p25/
* p50/p75/p90/p95/p99 in r() -- r(p67) does not exist and silently returns
* missing, which (since Stata treats missing as +infinity in comparisons)
* previously made every municipality satisfy "Intensity_2005 < c" and fall
* into the Never group at the tercile threshold. Use _pctile, which
* accepts arbitrary percentiles, instead.
_pctile inten1999_fix if year == 1996, percentiles(50 67)
local thresh_median  = r(r1)
local thresh_tercile = r(r2)
di "Threshold grid (Intensity_1999, End-of-year fixed-denom, 1996 HM cross-section): 15% (a priori); median = `thresh_median'; upper tercile = `thresh_tercile'"

foreach spec in 15 median tercile {
    if "`spec'" == "15" {
        local c = 0.15
        local clabel_15 "15\%"
    }
    else if "`spec'" == "median" {
        local c = `thresh_median'
        local clabel_median : di %4.3f `thresh_median'
    }
    else {
        local c = `thresh_tercile'
        local clabel_tercile : di %4.3f `thresh_tercile'
    }

    cap drop group_`spec'
    gen byte group_`spec' = .
    replace group_`spec' = 1 if inten1999_fix >= `c' & inten2005_fix >= `c'
    replace group_`spec' = 2 if inten1999_fix <  `c' & inten2005_fix >= `c'
    replace group_`spec' = 3 if inten1999_fix <  `c' & inten2005_fix <  `c'
    replace group_`spec' = 4 if inten1999_fix >= `c' & inten2005_fix <  `c'
    label define group_`spec'_lbl 1 "Early" 2 "Late-only" 3 "Never" 4 "High-Low (non-monotone)", replace
    label values group_`spec' group_`spec'_lbl

    * --- Cell counts (municipality-level, 1996 cross-section) ---
    count if year == 1996 & group_`spec' == 1
    local n_early_`spec' = r(N)
    count if year == 1996 & group_`spec' == 2
    local n_late_`spec' = r(N)
    count if year == 1996 & group_`spec' == 3
    local n_never_`spec' = r(N)
    count if year == 1996 & group_`spec' == 4
    local n_hl_`spec' = r(N)
    di "Threshold `spec': Early=`n_early_`spec'', Late-only=`n_late_`spec'', Never=`n_never_`spec'', High-Low=`n_hl_`spec''"

    * --- Raw population-weighted group means by year ---
    * NOTE: cannot use preserve/restore here -- Stata only allows one
    * active preserve at a time, and the outer block (before this foreach
    * loop) already holds one. Save/use a tempfile instead to return to
    * the municipality-year panel after each iteration's collapse.
    tempfile panel_snapshot_`spec'
    save `panel_snapshot_`spec'', replace

    * --- DOUBLE-THRESHOLD CATEGORICAL REGRESSION (PART 6, Proposal 1) ---
    * Must run BEFORE the collapse below, which destroys the municipality-
    * year panel this needs. Base category = Never; Early/Late-only/
    * High-Low are each read as a contrast against the low-low group.
    * High-Low (non-monotone) is kept as its own category rather than
    * dropped or folded into another group -- same reasoning as the raw-
    * trends figure above: this construction is not guaranteed monotonic
    * (25 HM municipalities per AT_crosswalk_supermun_diagnostic), so
    * silently absorbing it elsewhere would repeat the exact
    * misclassification bug already found and fixed in that block.
    *
    * The groups enter as EXPLICIT 0/1 dummies interacted with post as
    * CONTINUOUS (c.d_g#i.post), with Never omitted as the base (no dummy),
    * NOT as ib3.group#i.post. A factor#factor pure interaction omits the
    * base level of BOTH factors, so the surviving term would be on 2.post
    * (which is the PRE period here -- post is coded 2=pre, 1=post) and
    * 1.post#group would not exist at all -- exactly the extraction pattern
    * that fails silently. c.d_g#i.post matches how T2 (c.inten1999#i.post)
    * and the binary event study (c.treated#i.post) recover 1.post as the
    * post-period DiD coefficient (see the note at ~line 1864).
    cap drop d_early_`spec' d_late_`spec' d_hl_`spec'
    gen byte d_early_`spec' = (group_`spec' == 1)
    gen byte d_late_`spec'  = (group_`spec' == 2)
    gen byte d_hl_`spec'    = (group_`spec' == 4)

    cap noisily reghdfe emr65 c.d_early_`spec'#i.post c.d_late_`spec'#i.post ///
        c.d_hl_`spec'#i.post c.sp_intensity ///
        [aw=popover65_] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
    if _rc == 0 {
        local Nthr_`spec' : di %12.0fc e(N)
        foreach g in 1 2 4 {
            if `g' == 1 local dv d_early_`spec'
            if `g' == 2 local dv d_late_`spec'
            if `g' == 4 local dv d_hl_`spec'
            cap local bcoef = _b[1.post#c.`dv']
            local ok = (_rc == 0)
            cap local scoef = _se[1.post#c.`dv']
            local ok = `ok' & (_rc == 0)
            if `ok' & `scoef' > 0 & `scoef' < . {
                local aux : di %9.3f `bcoef'
                local tstat = abs(`bcoef' / `scoef')
                if      `tstat' >= 2.576 local bthr_`spec'_`g' = trim("`aux'") + "***"
                else if `tstat' >= 1.960 local bthr_`spec'_`g' = trim("`aux'") + "**"
                else if `tstat' >= 1.645 local bthr_`spec'_`g' = trim("`aux'") + "*"
                else                     local bthr_`spec'_`g' = trim("`aux'")
                local sethr_`spec'_`g' : di %9.3f `scoef'
            }
            else {
                local bthr_`spec'_`g'  "n/a"
                local sethr_`spec'_`g' "n/a"
            }
        }
    }
    else {
        di as error "Threshold-categorical regression `spec': reghdfe failed (rc=`_rc'), likely an empty/collinear category (e.g. Never at 15%) -- cells written as n/a"
        foreach g in 1 2 4 {
            local bthr_`spec'_`g'  "n/a"
            local sethr_`spec'_`g' "n/a"
        }
        local Nthr_`spec' "n/a"
    }

    * --- EVENT-STUDY version: Early-vs-Never year-by-year path (the "b0"
    * analog -- the early-adopter group's dynamic coefficient), stored for
    * the 3-threshold overlay figure built after this loop. Full categorical
    * (all three group dummies interacted with year), so Early is measured
    * against the Never base exactly as in the point-estimate table above;
    * only the Early path is extracted/plotted. Mirrors the binary event
    * study's c.treated##ib6.year_1995 construction. ---
    forval pos = 1/16 {
        local bes_`spec'_`pos'  = .
        local sees_`spec'_`pos' = .
    }
    cap noisily reghdfe emr65 c.d_early_`spec'##ib6.year_1995 ///
        c.d_late_`spec'##ib6.year_1995 c.d_hl_`spec'##ib6.year_1995 c.sp_intensity ///
        [aw=popover65_] if $sample_marg, a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
    if _rc == 0 {
        forval pos = 1/16 {
            if `pos' == 6 {
                local bes_`spec'_`pos'  = 0
                local sees_`spec'_`pos' = 0
            }
            else {
                cap local bes_`spec'_`pos'  = _b[`pos'.year_1995#c.d_early_`spec']
                cap local sees_`spec'_`pos' = _se[`pos'.year_1995#c.d_early_`spec']
            }
        }
    }
    else {
        di as error "Threshold-categorical event study `spec': reghdfe failed (rc=`_rc') -- Early path left blank"
    }

    collapse (mean) emr65 [aw=popover65_], by(year group_`spec')

    * Build the plot and legend dynamically: skip empty groups (e.g. "Never"
    * at the 15% threshold, per PART 6(7)'s count correction) rather than
    * plotting an empty series or mislabeling the legend.
    local plotcmd ""
    local legend_order ""
    local nser = 0
    if `n_early_`spec'' > 0 {
        local nser = `nser' + 1
        local plotcmd `"`plotcmd' (connected emr65 year if group_`spec'==1, lcolor(black) mcolor(black) msymbol(circle) msize(small))"'
        local legend_order `"`legend_order' `nser' "Early""'
    }
    if `n_late_`spec'' > 0 {
        local nser = `nser' + 1
        local plotcmd `"`plotcmd' (connected emr65 year if group_`spec'==2, lcolor(blue) mcolor(blue) msymbol(triangle) msize(small))"'
        local legend_order `"`legend_order' `nser' "Late-only""'
    }
    if `n_never_`spec'' > 0 {
        local nser = `nser' + 1
        local plotcmd `"`plotcmd' (connected emr65 year if group_`spec'==3, lcolor(red) mcolor(red) msymbol(square) msize(small))"'
        local legend_order `"`legend_order' `nser' "Never""'
    }
    if `n_hl_`spec'' > 0 {
        local nser = `nser' + 1
        local plotcmd `"`plotcmd' (connected emr65 year if group_`spec'==4, lcolor(orange) mcolor(orange) msymbol(diamond) msize(small))"'
        local legend_order `"`legend_order' `nser' "High-Low""'
    }

    twoway `plotcmd', ///
        xline(1997, lcolor(gs8) lpattern(dash)) ///
        xtitle("Year", size(small)) ///
        ytitle("EMR 65+ (per 1,000)", size(small)) ///
        xlabel(1991(2)2006, labsize(small)) ylabel(, labsize(small)) ///
        legend(order(`legend_order') cols(4) size(small) position(6) ring(1) region(lcolor(none))) ///
        graphregion(color(white)) plotregion(margin(l=1 r=1))
    * graph export "$figures/appendix/AF_threshold_validation_`spec'.pdf", as(pdf) replace
    use `panel_snapshot_`spec'', clear
}

* NOTE: the former separate cell-count companion table
* (AT_threshold_validation_cellcounts.tex) has been removed as redundant
* with AT_threshold_categorical.tex below, which reports the identical
* Early/Late-only/Never/High-Low counts (plus the threshold value row
* added here to preserve that one piece of information this table alone
* used to carry).

di "Figures exported to: $figures/appendix/AF_threshold_validation_15.pdf, AF_threshold_validation_median.pdf, AF_threshold_validation_tercile.pdf"

*------------------------------------------------------------
* DOUBLE-THRESHOLD CATEGORICAL REGRESSION TABLE (PART 6, Proposal 1):
* point-estimate companion to the raw-trends validation figure above,
* using the SAME Early/Late-only/Never/High-Low classification and the
* same 3-threshold grid. Base category = Never; Proposal 2 (drop
* Late-only for a clean 2x2 against Never) is not used as the headline
* here because Never is close to empty at the 15% threshold (n=2) --
* keeping Late-only lets the design degrade gracefully across the grid
* instead of failing at the a priori cutoff.
* Output: $tables/appendix/AT_threshold_categorical.tex
*------------------------------------------------------------
/*
cap file close tc
file open tc using "$tables/appendix/AT_threshold_categorical.tex", write replace
file write tc "\begin{tabular}{lccc} \hline \hline" _n
file write tc "& \multicolumn{1}{c}{15\% (a priori)} & \multicolumn{1}{c}{Median} & \multicolumn{1}{c}{Upper tercile} \\ \toprule" _n
file write tc "\textit{Early x Post} & `bthr_15_1' & `bthr_median_1' & `bthr_tercile_1' \\ " _n
file write tc " & (`sethr_15_1') & (`sethr_median_1') & (`sethr_tercile_1') \\ " _n
file write tc "  & & & \\ " _n
file write tc "\textit{Late-only x Post} & `bthr_15_2' & `bthr_median_2' & `bthr_tercile_2' \\ " _n
file write tc " & (`sethr_15_2') & (`sethr_median_2') & (`sethr_tercile_2') \\ " _n
file write tc "  & & & \\ " _n
file write tc "\textit{High-Low (non-monotone) x Post} & `bthr_15_4' & `bthr_median_4' & `bthr_tercile_4' \\ " _n
file write tc " & (`sethr_15_4') & (`sethr_median_4') & (`sethr_tercile_4') \\ " _n
file write tc "  & & & \\ " _n
file write tc "Obs & `Nthr_15' & `Nthr_median' & `Nthr_tercile' \\ " _n
file write tc "  & & & \\ " _n
file write tc "Threshold value & `clabel_15' & `clabel_median' & `clabel_tercile' \\ " _n
file write tc "Early & `n_early_15' & `n_early_median' & `n_early_tercile' \\ " _n
file write tc "Late-only & `n_late_15' & `n_late_median' & `n_late_tercile' \\ " _n
file write tc "Never (base) & `n_never_15' & `n_never_median' & `n_never_tercile' \\ " _n
file write tc "High-Low (non-monotone) & `n_hl_15' & `n_hl_median' & `n_hl_tercile' \\ " _n
file write tc "\bottomrule" _n
file write tc "\end{tabular}"
file close tc
*/
di "Table written to: $tables/appendix/AT_threshold_categorical.tex"

*------------------------------------------------------------
* EVENT-STUDY OVERLAY: Early-vs-Never year-by-year coefficient (the "b0"
* analog of the double-threshold categorical design), the three thresholds
* (15% / median / upper tercile) overlaid on one figure -- the event-study
* companion to AT_threshold_categorical (which reports the collapsed Post-
* interaction point estimate). Directly parallels AF_binary_es, which does
* the same 3-threshold overlay for the SINGLE-threshold binary design; this
* is its double-threshold (Early = high on both 1999 and 2005 vs. the Never
* base) counterpart. Reference year 1996. The bes_*/sees_* series were
* stored per threshold in the loop above.
*
* Built from the stored locals only (no dependence on the current data), so
* it is safe to clear here: the outer restore below repops the original
* pre-preserve panel regardless of the working data's state.
* Output: $figures/appendix/AF_threshold_categorical_es.pdf
*------------------------------------------------------------
local yr_labels `"1 "1991" 2 "1992" 3 "1993" 4 "1994" 5 "1995" 6 "1996" 7 "1997" 8 "1998" 9 "1999" 10 "2000" 11 "2001" 12 "2002" 13 "2003" 14 "2004" 15 "2005" 16 "2006""'
clear
set obs 16
gen yr_pos = _n
gen xpos_15  = yr_pos - 0.18
gen xpos_med = yr_pos
gen xpos_ter = yr_pos + 0.18
foreach s in 15 med ter {
    gen b_`s'  = .
    gen hi_`s' = .
    gen lo_`s' = .
}
forval pos = 1/16 {
    replace b_15  = `bes_15_`pos''                            if yr_pos == `pos'
    replace hi_15 = `bes_15_`pos'' + 1.96 * `sees_15_`pos''  if yr_pos == `pos'
    replace lo_15 = `bes_15_`pos'' - 1.96 * `sees_15_`pos''  if yr_pos == `pos'
    replace b_med  = `bes_median_`pos''                            if yr_pos == `pos'
    replace hi_med = `bes_median_`pos'' + 1.96 * `sees_median_`pos''  if yr_pos == `pos'
    replace lo_med = `bes_median_`pos'' - 1.96 * `sees_median_`pos''  if yr_pos == `pos'
    replace b_ter  = `bes_tercile_`pos''                            if yr_pos == `pos'
    replace hi_ter = `bes_tercile_`pos'' + 1.96 * `sees_tercile_`pos''  if yr_pos == `pos'
    replace lo_ter = `bes_tercile_`pos'' - 1.96 * `sees_tercile_`pos''  if yr_pos == `pos'
}
twoway ///
    (rcap hi_15 lo_15 xpos_15, lcolor(black%60) lwidth(vthin) lpattern(solid)) ///
    (scatter b_15 xpos_15, mcolor(black) msymbol(circle) msize(vsmall)) ///
    (rcap hi_med lo_med xpos_med, lcolor(red%60) lwidth(vthin) lpattern(dash)) ///
    (scatter b_med xpos_med, mcolor(red) msymbol(square) msize(vsmall)) ///
    (rcap hi_ter lo_ter xpos_ter, lcolor(blue%60) lwidth(vthin) lpattern(shortdash_dot)) ///
    (scatter b_ter xpos_ter, mcolor(blue) msymbol(triangle) msize(vsmall)) ///
    (line b_15 xpos_15 if 1==0, lcolor(black) lpattern(solid) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)) ///
    (line b_med xpos_med if 1==0, lcolor(red) lpattern(dash) lwidth(thin) mcolor(red) msymbol(square) msize(vsmall)) ///
    (line b_ter xpos_ter if 1==0, lcolor(blue) lpattern(shortdash_dot) lwidth(thin) mcolor(blue) msymbol(triangle) msize(vsmall)), ///
    yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
    xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
    xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
    xscale(range(0.5 16.5)) ///
    xtitle("") ///
    ytitle("Mortality Rate 65+ (per 1,000)", size(medsmall)) ///
    ylabel(, grid gmin gmax labsize(small)) ///
    legend(order(7 "Threshold: 15%" 8 "Threshold: median" 9 "Threshold: upper tercile") ///
        cols(3) size(small) position(6) ring(1) ///
        region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
    graphregion(color(white)) ///
    plotregion(margin(l=1 r=1))
* graph export "$figures/appendix/AF_threshold_categorical_es.pdf", as(pdf) replace
di "Figure exported to: $figures/appendix/AF_threshold_categorical_es.pdf"

restore

*============================================================
* APPENDIX FIGURE: Time series of the 4 intensity constructions,
* 1997-2006, population-weighted (65+). Coauthor-requested; corrects an
* earlier mis-specification in this conversation (a first version
* proposed building the "End-of-year" series from the 1999/2005
* snapshots) -- the correct End-of-year series is `intensity_new' itself,
* the genuine year-by-year snapshot, unrelated to which intensity years
* are used downstream. An unweighted companion was considered but
* dropped: the weighted version is the relevant one for the analysis
* sample (regressions are population-weighted throughout), so an
* unweighted panel added a robustness check without a corresponding
* need here.
*
* The 4 series (HM-sample weighted averages, by calendar year):
*   (1) End-of-year, year-varying denom = intensity_new (= pgbenef_new/hh_tot)
*   (2) Cumulative,  year-varying denom = pg_fase/hh_tot
*   (3) End-of-year, fixed denom        = pgbenef_new/hog1997_fixed
*   (4) Cumulative,  fixed denom        = pg_fase/hog1997_fixed
* Output: $figures/appendix/AF_intensity_timeseries_w.pdf
*------------------------------------------------------------
preserve
keep if $sample_marg & inrange(year, 1997, 2006)

gen ts_eoy_yv  = intensity_new
gen ts_cum_yv  = pg_fase / hh_tot
gen ts_eoy_fix = pgbenef_new / hog1997_fixed
gen ts_cum_fix = pg_fase / hog1997_fixed

count if missing(ts_eoy_yv) | missing(ts_cum_yv) | missing(ts_eoy_fix) | missing(ts_cum_fix)
di "`r(N)' HM municipality-years dropped for missing intensity in the time-series figure"
drop if missing(ts_eoy_yv) | missing(ts_cum_yv) | missing(ts_eoy_fix) | missing(ts_cum_fix)

collapse (mean) ts_eoy_yv ts_cum_yv ts_eoy_fix ts_cum_fix [aw=popover65_], by(year)

twoway ///
    (connected ts_eoy_yv year, lcolor(black) mcolor(black) msymbol(circle) msize(small)) ///
    (connected ts_cum_yv year, lcolor(black) mcolor(black) msymbol(circle) msize(small) lpattern(dash)) ///
    (connected ts_eoy_fix year, lcolor(red) mcolor(red) msymbol(triangle) msize(small)) ///
    (connected ts_cum_fix year, lcolor(red) mcolor(red) msymbol(triangle) msize(small) lpattern(dash)), ///
    xtitle("Year", size(small)) ///
    ytitle("Mean Intensity", size(small)) ///
    xlabel(1997(1)2006, labsize(small)) ylabel(, labsize(small)) ///
    legend(order(1 "End-of-year, year-varying denom" 2 "Cumulative, year-varying denom" ///
                 3 "End-of-year, fixed denom" 4 "Cumulative, fixed denom") ///
           cols(2) size(small) position(6) ring(1) region(lcolor(none))) ///
    graphregion(color(white)) plotregion(margin(l=1 r=1))
* graph export "$figures/appendix/AF_intensity_timeseries_w.pdf", as(pdf) replace
restore

di "Figure exported to: $figures/appendix/AF_intensity_timeseries_w.pdf"


*============================================================
* The following blocks (AT8-AT12 in the appendix numbering: R^2
* decomposition, intensity correlations, power/MDE, crosswalk
* super-municipality diagnostic, saturation diagnostics) moved here
* per the coauthor's request. Their content is summarized in
* research_project.md so the key findings survive as citable
* footnote material even with the tables out of the appendix.
*============================================================
*------------------------------------------------------------
* fn.18-style R²: how much of Intensity_1999's variance does Intensity_2005
* explain, unweighted and weighted by the population aged 65 and older
* (matching the weighting used throughout the main regressions). Run on
* the HM analysis sample (matches P&V's own "in sample municipalities"
* wording for their 65%/67%/75% progression).
*------------------------------------------------------------
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999 inten2005 im_mun_1990 popover65_
duplicates drop cve_ent_mun_super, force
count
local n_r2_mun = r(N)
di "`n_r2_mun' HM municipalities in the correlation cross-section"

reg inten1999 inten2005
local r2_1 : di %5.3f e(r2)
di "R² of inten1999 ~ inten2005 (HM sample): `r2_1'   [P&V fn.18 benchmark: 0.65]"

* Signed correlation companion to r2_1 -- coauthor requested a correlation
* table (corr(Intensity_1999, Intensity_2005) within each construction) as
* the "R2 in terms of correlation" complement to the R2 decomposition
* table above. R2 alone loses the sign; take corr directly.
corr inten1999 inten2005
local corr_eoy_yv : di %5.3f r(rho)

corr inten1999 inten2005 [aw=popover65_]
local corr_eoy_yv_w : di %5.3f r(rho)

reg inten1999 inten2005 [aw=popover65_]
local r2_2 : di %5.3f e(r2)
di "R² of inten1999 ~ inten2005, weighted by pop 65+ (HM sample): `r2_2'   [P&V fn.18 benchmark: 0.65]"
* r2_1/r2_2 (and n_r2_mun) are reused below, alongside r2fix_1/r2fix_2 (P&V
* fixed-denominator robustness) and r2fase_yv_*/r2fase_fx_* (FASE-only
* numerator robustness), in the single consolidated
* AT_pv_r2_benefsource table -- see the ROBUSTNESS: FASE-ONLY BENEFICIARY
* SOURCE section for the merged table writer.
restore

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

/*
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
*/
di "Table exported to: $tables/appendix/AT_saturation_diagnostics.tex"
restore
di "D3 saturation diagnostics complete -- see log above for stayer availability and first-crossing spread."

*------------------------------------------------------------
* Robustness R²: same fn.18-style check as above, but using the
* fixed-denominator Intensity_1999/2005 instead of the year-varying-
* denominator versions. r2fix_1/r2fix_2 (and n_r2fix_mun) feed into the
* single consolidated AT_pv_r2_benefsource table below (ROBUSTNESS:
* FASE-ONLY BENEFICIARY SOURCE section) rather than a separate table here.
*------------------------------------------------------------
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999_fix inten2005_fix im_mun_1990 popover65_
duplicates drop cve_ent_mun_super, force
count
local n_r2fix_mun = r(N)
di "`n_r2fix_mun' HM municipalities in the fixed-denominator correlation cross-section"

reg inten1999_fix inten2005_fix
local r2fix_1 : di %5.3f e(r2)
di "R² of inten1999_fix ~ inten2005_fix (HM sample, FIXED denominator): `r2fix_1'   [current year-varying-denom version: 0.160; P&V benchmark: 0.65]"

corr inten1999_fix inten2005_fix
local corr_eoy_fix : di %5.3f r(rho)

corr inten1999_fix inten2005_fix [aw=popover65_]
local corr_eoy_fix_w : di %5.3f r(rho)

reg inten1999_fix inten2005_fix [aw=popover65_]
local r2fix_2 : di %5.3f e(r2)
di "R² of inten1999_fix ~ inten2005_fix, weighted by pop 65+ (FIXED denominator): `r2fix_2'   [P&V benchmark: 0.65]"
restore

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

* Weighted companions (population aged 65+), for AT_intensity_correlations
* Panel B -- same four correlations, weighted to match the main
* regressions' weighting.
corr inten1999 inten1999_fase [aw=popover65_] if $sample_marg & year==1996
local corr99_w: di %5.3f r(rho)
corr inten2005 inten2005_fase [aw=popover65_] if $sample_marg & year==1996
local corr05_w: di %5.3f r(rho)
corr inten1999_fix inten1999_fase_fix [aw=popover65_] if $sample_marg & year==1996
local corr99_fix_w: di %5.3f r(rho)
corr inten2005_fix inten2005_fase_fix [aw=popover65_] if $sample_marg & year==1996
local corr05_fix_w: di %5.3f r(rho)


*============================================================
* CROSSWALK "SUPER-MUNICIPALITY" DIAGNOSTIC
*
* NOTE ON THE SAMPLE-SIZE LADDER: this block reports how many municipalities
* in the HM ANALYSIS SAMPLE are multi-origin harmonized units. It is the
* sample-restricted counterpart to two upstream diagnostics added for the
* Barham-Rowberry municipality-count comparison:
*   - 0.super_municipality_id_and_HH_data.do prints a [CROSSWALK yyyy] line
*     when each crosswalk is built, giving raw codes -> harmonized units
*     nationally;
*   - 000. and 00. write $codes/harmonization_ladder.log, recording the same
*     counts at each collapse of an input series onto cve_ent_mun_super;
*   - 01_mortality_data.do writes $codes/01_sample_ladder.log, recording
*     municipalities surviving each completeness/balance screen plus the
*     final panel's composition by marginality grade and first-enrollment year.
* Together these separate boundary harmonization from panel-completeness
* screening from the phase-in definition as sources of the gap to BR's 1,961.
*
* Original purpose below -- is the A1 non-monotonicity
* (Intensity_2005 < Intensity_1999 under the Mixed construction) a
* crosswalk-aggregation artifact rather than real household attrition?
* research_project.md PART 3 flags municipality-boundary harmonization
* (cve_ent_mun_super, built in 0.super_municipality_id_and_HH_data.do,
* harmonizing ~100+ municipality splits/creations 1990-2020, mostly
* Oaxaca/Chiapas) as an unverified candidate driver of the R2 gap vs.
* Parker & Vogl; the same mechanism could independently produce A1/A3-
* type symptoms if a super-municipality's component (origin) codes are
* inconsistently present across years in the source admin data, with no
* need for any real enrollment change.
*
* Uses the SAME crosswalk file as the map-figure code and the intensity-
* construction blocks above (crosswalk_super_mun_id_1990.dta): one row
* per origin (cve_ent, cve_mun) pair mapped to a harmonized
* cve_ent_mun_super code. A "super-municipality" is one where 2+ distinct
* origin pairs map to the same harmonized code; municipalities absent
* from the crosswalk file had no boundary change and map 1:1 to
* themselves (n_origin_mun = 1 by construction, matching the
* "replace cve_ent_mun_super = cve_ent + cve_mun if ==''" convention
* used elsewhere in this file).
* Output: $tables/appendix/AT_crosswalk_supermun_diagnostic.tex
*------------------------------------------------------------
preserve
use "$data/crosswalk_super_mun_id_1990.dta", clear
keep cve_ent cve_mun cve_ent_mun_super
duplicates drop cve_ent cve_mun cve_ent_mun_super, force
bys cve_ent_mun_super: gen n_origin_mun = _N
duplicates drop cve_ent_mun_super, force
keep cve_ent_mun_super n_origin_mun
tempfile origin_counts
save `origin_counts'
restore

*============================================================
* A1 NON-MONOTONICITY DIAGNOSTIC: identifies HM municipalities where the
* Mixed (snapshot) construction has Intensity_2005 < Intensity_1999
* (research_project.md PART 6, A1 discussion), using the End-of-year
* numerator over the year-varying household denominator (inten1999/
* inten2005), the coauthors' main specification, so only the numerator
* construction (mixed snapshot vs. FASE cumulative sum) differs. Feeds
* the crosswalk "super-municipality" cross-tab below (does the
* non-monotonicity concentrate among municipalities built from 2+ origin
* INEGI codes, i.e. a boundary-aggregation artifact, rather than real
* household attrition/migration?).
* Output: $tables/appendix/AT_crosswalk_supermun_diagnostic.tex
*------------------------------------------------------------
preserve
keep if year == 1996 & $sample_marg
keep cve_ent_mun_super inten1999 inten2005 inten1999_fase inten2005_fase
duplicates drop cve_ent_mun_super, force

count if missing(inten1999) | missing(inten2005) | missing(inten1999_fase) | missing(inten2005_fase)
di "`r(N)' HM municipalities dropped for missing intensity values in the construction-comparison figure"
drop if missing(inten1999) | missing(inten2005) | missing(inten1999_fase) | missing(inten2005_fase)

gen byte nonmonotone_mix = (inten2005 < inten1999)
count if nonmonotone_mix
local n_nonmono = r(N)
local n_tot = _N
di "`n_nonmono' / `n_tot' HM municipalities have Intensity_2005 < Intensity_1999 under the Mixed (snapshot) construction -- candidates for the A1 'drop non-monotone municipalities' robustness trim"

*------------------------------------------------------------
* Crosswalk cross-tab: are the non-monotone-in-Mixed municipalities
* disproportionately crosswalk "super-municipalities" (2+ origin codes
* harmonized into one), suggesting a boundary-aggregation artifact
* rather than real attrition/churn?
*------------------------------------------------------------
merge m:1 cve_ent_mun_super using `origin_counts', keep(master match) nogen
replace n_origin_mun = 1 if missing(n_origin_mun)
gen byte super_mun = (n_origin_mun >= 2)
count if super_mun
local n_super = r(N)
di "`n_super' / `n_tot' HM municipalities are crosswalk 'super-municipalities' (2+ origin INEGI codes harmonized into one)"

count if super_mun
local n_super_tot = r(N)
count if !super_mun
local n_notsuper_tot = r(N)
count if nonmonotone_mix & super_mun
local n_nonmono_super = r(N)
count if nonmonotone_mix & !super_mun
local n_nonmono_notsuper = r(N)
local pct_super    : di %4.1f 100*`n_nonmono_super'/`n_super_tot'
local pct_notsuper : di %4.1f 100*`n_nonmono_notsuper'/`n_notsuper_tot'
di "Non-monotone share among super-municipalities: `n_nonmono_super' / `n_super_tot' (`pct_super'%)"
di "Non-monotone share among non-super municipalities: `n_nonmono_notsuper' / `n_notsuper_tot' (`pct_notsuper'%)"

/*
cap file close fd
file open fd using "$tables/appendix/AT_crosswalk_supermun_diagnostic.tex", write replace
file write fd "\begin{tabular}{lccc} \hline \hline" _n
file write fd "& Non-monotone & Monotone & Total \\ " _n
file write fd "& (Intensity{\textsubscript{2005}} \$<\$ Intensity{\textsubscript{1999}}, Mixed) & & \\ \toprule" _n
file write fd "Super-municipality (2+ origin codes) & `n_nonmono_super' & `=`n_super_tot'-`n_nonmono_super'' & `n_super_tot' (`pct_super'\%) \\ " _n
file write fd "Simple municipality (1 origin code) & `n_nonmono_notsuper' & `=`n_notsuper_tot'-`n_nonmono_notsuper'' & `n_notsuper_tot' (`pct_notsuper'\%) \\ " _n
file write fd "\bottomrule" _n
file write fd "Total & `n_nonmono' & `=`n_tot'-`n_nonmono'' & `n_tot' \\ " _n
file write fd "\end{tabular}" _n
file close fd
*/
di "Table written to: $tables/appendix/AT_crosswalk_supermun_diagnostic.tex"
restore

di "A1 diagnostic: `n_nonmono' of `n_tot' HM municipalities are non-monotone under the Mixed construction"


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
keep cve_ent_mun_super inten1999_fase inten2005_fase inten1999_fase_fix inten2005_fase_fix im_mun_1990 popover65_
duplicates drop cve_ent_mun_super, force
count
local n_r2fase_mun = r(N)
di "`n_r2fase_mun' HM municipalities in the FASE-only correlation cross-section"

reg inten1999_fase inten2005_fase
local r2fase_yv_1 : di %5.3f e(r2)
di "R² of inten1999_fase ~ inten2005_fase (HM sample, FASE-only numerator, year-varying denom): `r2fase_yv_1'   [mixed/year-varying: `r2_1'; P&V benchmark: 0.65]"

corr inten1999_fase inten2005_fase
local corr_cum_yv : di %5.3f r(rho)

corr inten1999_fase inten2005_fase [aw=popover65_]
local corr_cum_yv_w : di %5.3f r(rho)

reg inten1999_fase inten2005_fase [aw=popover65_]
local r2fase_yv_2 : di %5.3f e(r2)

reg inten1999_fase_fix inten2005_fase_fix
local r2fase_fx_1 : di %5.3f e(r2)
di "R² of inten1999_fase_fix ~ inten2005_fase_fix (HM sample, FASE-only numerator, FIXED denom): `r2fase_fx_1'   [mixed/fixed: `r2fix_1'; P&V benchmark: 0.65]"

corr inten1999_fase_fix inten2005_fase_fix
local corr_cum_fix : di %5.3f r(rho)

corr inten1999_fase_fix inten2005_fase_fix [aw=popover65_]
local corr_cum_fix_w : di %5.3f r(rho)

reg inten1999_fase_fix inten2005_fase_fix [aw=popover65_]
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

/*
{
    cap file close r2b
    file open r2b using "$tables/appendix/AT_pv_r2_benefsource.tex", write replace
    file write r2b "\begin{tabular}{lcccc} \hline \hline" _n
    file write r2b "& \multicolumn{2}{c}{Year-varying denom.} & \multicolumn{2}{c}{Fixed (P\&V) denom.} \\" _n
    file write r2b "Numerator construction & R\textsuperscript{2} & + weighted (pop 65+) & R\textsuperscript{2} & + weighted (pop 65+) \\ \toprule" _n
    file write r2b "End-of-year (current default) & `r2_1' & `r2_2' & `r2fix_1' & `r2fix_2' \\ " _n
    file write r2b "Cumulative (P\&V's numerator) & `r2fase_yv_1' & `r2fase_yv_2' & `r2fase_fx_1' & `r2fase_fx_2' \\ " _n
    file write r2b "  & & & & \\ " _n
    file write r2b "P\&V (2023) benchmark & \multicolumn{2}{c}{0.65} & \multicolumn{2}{c}{0.65} \\ " _n
    file write r2b "\bottomrule" _n
    file write r2b "\multicolumn{5}{l}{\textit{Decomposition of \$\Delta R^2\$ vs.\ the current-default baseline (top-left cell):}} \\ " _n
    file write r2b "\quad Denominator fix alone, unweighted & \multicolumn{4}{c}{`ddenom_1'} \\ " _n
    file write r2b "\quad Denominator fix alone, weighted & \multicolumn{4}{c}{`ddenom_2'} \\ " _n
    file write r2b "\quad Numerator fix alone, unweighted & \multicolumn{4}{c}{`dnum_1'} \\ " _n
    file write r2b "\quad Numerator fix alone, weighted & \multicolumn{4}{c}{`dnum_2'} \\ " _n
    file write r2b "\quad Both combined, unweighted & \multicolumn{4}{c}{`dboth_1'} \\ " _n
    file write r2b "\quad Both combined, weighted & \multicolumn{4}{c}{`dboth_2'} \\ " _n
    file write r2b "No.\ HM municipalities & \multicolumn{4}{c}{`n_r2fase_mun'} \\ " _n
    file write r2b "\end{tabular}"
    file close r2b
}
*/
di "Table exported to: $tables/appendix/AT_pv_r2_benefsource.tex"
restore

*============================================================
* APPENDIX TABLE: AT_intensity_correlations -- coauthor-requested
* correlation table, requested as a complement to (not replacement for)
* AT_pv_r2_benefsource's R2 decomposition, after the coauthor meeting
* decision to use the End-of-year (not Cumulative) numerator as the main
* specification. Two objects:
*   Row 1: corr(Intensity_1999, Intensity_2005) WITHIN each of the 4
*          constructions -- "R2 in terms of correlation" per the
*          coauthor's request. This is the SIGNED companion to the
*          unweighted R2 column of AT_pv_r2_benefsource (for a simple
*          bivariate regression, R2 = corr^2, but R2 alone loses the
*          sign, hence the separate `corr' calls added above rather
*          than just taking sqrt(R2)).
*   Rows 2-3: corr(End-of-year, Cumulative) at each snapshot year --
*          relocated from the footer of T2_b_mortality_fixeddenom (per
*          the coauthor's request to move it here), unchanged values
*          (corr99/corr99_fix/corr05/corr05_fix, already computed above).
* Panel A is unweighted; Panel B repeats all three rows weighted by the
* population aged 65 and older, matching the main regressions' weighting
* (corr_*_w/corr99_w/corr05_w/corr99_fix_w/corr05_fix_w, computed above
* alongside their unweighted counterparts).
* Column order matches T2_b_mortality_fixeddenom: (1) year-varying
* denom/End-of-year, (2) year-varying/Cumulative, (3) fixed/End-of-year,
* (4) fixed/Cumulative.
* Output: $tables/appendix/AT_intensity_correlations.tex
*------------------------------------------------------------
/*
cap file close ic
file open ic using "$tables/appendix/AT_intensity_correlations.tex", write replace
file write ic "\begin{tabular}{lcccc} \hline \hline" _n
file write ic "& \multicolumn{2}{c}{Year-varying denom.} & \multicolumn{2}{c}{Fixed 1997 denom.\ (P\&V-style)} \\ " _n
file write ic "& \multicolumn{1}{c}{End-of-year} & \multicolumn{1}{c}{Cumulative} & \multicolumn{1}{c}{End-of-year} & \multicolumn{1}{c}{Cumulative} \\ " _n
file write ic "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\ \toprule" _n
file write ic "\underline{\textit{Panel A: Unweighted}}  \\ " _n
file write ic "Corr(Intensity{\textsubscript{1999}}, Intensity{\textsubscript{2005}}) & `corr_eoy_yv' & `corr_cum_yv' & `corr_eoy_fix' & `corr_cum_fix' \\ " _n
file write ic "  & & & & \\ " _n
file write ic "Corr(End-of-year, Cumulative), 1999 & \multicolumn{2}{c}{`corr99'} & \multicolumn{2}{c}{`corr99_fix'} \\ " _n
file write ic "Corr(End-of-year, Cumulative), 2005 & \multicolumn{2}{c}{`corr05'} & \multicolumn{2}{c}{`corr05_fix'} \\ " _n
file write ic "  & & & & \\ " _n
file write ic "\underline{\textit{Panel B: Weighted (pop 65+)}}  \\ " _n
file write ic "Corr(Intensity{\textsubscript{1999}}, Intensity{\textsubscript{2005}}) & `corr_eoy_yv_w' & `corr_cum_yv_w' & `corr_eoy_fix_w' & `corr_cum_fix_w' \\ " _n
file write ic "  & & & & \\ " _n
file write ic "Corr(End-of-year, Cumulative), 1999 & \multicolumn{2}{c}{`corr99_w'} & \multicolumn{2}{c}{`corr99_fix_w'} \\ " _n
file write ic "Corr(End-of-year, Cumulative), 2005 & \multicolumn{2}{c}{`corr05_w'} & \multicolumn{2}{c}{`corr05_fix_w'} \\ " _n
file write ic "\bottomrule" _n
file write ic "\end{tabular}"
file close ic
*/
di "Table exported to: $tables/appendix/AT_intensity_correlations.tex"


*============================================================
* APPENDIX TABLE: AT_power_mde -- power/Minimum Detectable Effect (MDE)
* summary for the Intensity_1999 x Post coefficient (beta_0 only, per
* coauthor's request -- Intensity_2005 not needed), End-of-year numerator
* over the year-varying household denominator only. The Cumulative
* numerator (former column 2) is dropped per the coauthor's request --
* the End-of-year construction is the coauthors' main specification, so
* only its MDE is informative going forward.
* Self-contained: reruns its own small regression per panel here rather
* than reusing T2_b_mortality_fixeddenom's locals, since that table is
* built in 02_mortality.do and Stata locals do not survive across a
* save/use boundary between do-files.
* Benchmarked against Barham & Rowberry (2013). MDE = (t_power + t_alpha)
* x SE, using the standard 80%-power/5%-two-sided multiplier 2.80. This
* is a "can this design detect an effect of BR's magnitude" statement,
* NOT a formal test that rules BR's estimate out -- BR's own -6.37 comes
* from a different sample/spec (continuously-lagged intensity, BR-
* incorporation sample), so the comparison is a magnitude benchmark, not
* a nested test.
* Output: $tables/appendix/AT_power_mde.tex
*------------------------------------------------------------
local mde_mult = 2.80

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

    reghdfe `out65' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
        [aw=`wt65'] if $sample_marg, a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
    local aux : di %12.3f _b[1.post#c.inten1999]
    local t = abs(_b[1.post#c.inten1999] / _se[1.post#c.inten1999])
    if      `t' >= 2.576 local b99_mde_`pnl' = "`aux'***"
    else if `t' >= 1.96  local b99_mde_`pnl' = "`aux'**"
    else if `t' >= 1.645 local b99_mde_`pnl' = "`aux'*"
    else                  local b99_mde_`pnl' = "`aux'"
    local se99_mde_`pnl' : di %12.3f _se[1.post#c.inten1999]
    local mde_`pnl' : di %12.2f (`mde_mult' * _se[1.post#c.inten1999])
}

/*
cap file close mde
file open mde using "$tables/appendix/AT_power_mde.tex", write replace
file write mde "\begin{tabular}{lc} \hline \hline" _n
file write mde "& \multicolumn{1}{c}{End-of-year} \\ " _n
file write mde "& \multicolumn{1}{c}{(1)} \\ \toprule" _n

foreach pnl in p f m {
    if "`pnl'" == "p"      local plabel "Panel A: Pooled"
    else if "`pnl'" == "f" local plabel "Panel B: Females"
    else                    local plabel "Panel C: Males"

    file write mde "\underline{\textit{`plabel'}} \\ " _n
    file write mde "\textit{Intensity 1999 x post (\$\beta_0\$)} & `b99_mde_`pnl'' \\ " _n
    file write mde " & (`se99_mde_`pnl'') \\ " _n
    file write mde "\textit{MDE (80\% power, two-sided 5\%)} & `mde_`pnl'' \\ " _n
    file write mde "  & \\ " _n
}

file write mde "\bottomrule" _n
file write mde "\end{tabular}"
file close mde
*/
di "Table exported to: $tables/appendix/AT_power_mde.tex"

*============================================================
* T3 (t:did_age_fixeddenom, T2_b_mortality_fixeddenom.tex) moved here
* per the coauthor's request. Its non-monotonicity flag
* (nonmonotone_mix, needed for column 5) is a dataset variable
* already carried in the checkpointed working panel this file loads.
*============================================================
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
*   Col 3: Mixed numerator,  fixed 1997 P&V denom (denominator fix alone,
*          the coauthor-preferred main specification)
*   Col 4: FASE numerator,   fixed 1997 P&V denom (both combined)
*   Col 5: Same as Col 3, but dropping the `nonmonotone_mix' municipalities
*          (Intensity_2005 < Intensity_1999 under this construction; see
*          AT_crosswalk_supermun_diagnostic), since the End-of-year
*          numerator is not guaranteed monotonic -- this checks whether
*          those municipalities are driving the column 3 estimate.
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

    forval c = 1/5 {
        local extracond ""
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
        else if `c' == 4 {
            local inten99v inten1999_fase_fix
            local inten05v inten2005_fase_fix
        }
        else {
            local inten99v inten1999_fix
            local inten05v inten2005_fix
            local extracond "& !nonmonotone_mix"
        }

        local b99_fd_`pnl'_`c'  ""
        local se99_fd_`pnl'_`c' ""
        local b05_fd_`pnl'_`c'  ""
        local se05_fd_`pnl'_`c' ""
        local N_fd_`pnl'_`c'    ""

        cap noisily reghdfe `out65' c.`inten99v'#i.post c.`inten05v'#i.post c.sp_intensity ///
            [aw=`wt65'] if $sample_marg `extracond', a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
        if _rc == 0 & e(N) > 0 {
            local aux : di %12.3f _b[1.post#c.`inten99v']
            * Save the un-starred numeric coefficient under its own name --
            * `aux' gets reused below for the Intensity_2005 coefficient, so
            * a persistent copy is needed for the power/MDE table, which
            * needs the raw number (not the significance-star-annotated
            * display string in b99_fd_`pnl'_`c').
            local b99num_fd_`pnl'_`c' "`aux'"
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

/*
{
    cap file close fd
    file open fd using "$tables/T2_b_mortality_fixeddenom.tex", write replace
    file write fd "\begin{tabular}{lccccc} \hline \hline" _n
    file write fd "& \multicolumn{2}{c}{Year-varying denom.} & \multicolumn{2}{c}{Fixed 1997 denom.\ (P\&V-style)} & \\ " _n
    file write fd "& \multicolumn{1}{c}{End-of-year} & \multicolumn{1}{c}{Cumulative} & \multicolumn{1}{c}{End-of-year} & \multicolumn{1}{c}{Cumulative} & \multicolumn{1}{c}{End-of-year} \\ " _n
    file write fd "& & & & & \multicolumn{1}{c}{Excl.\ non-monotone} \\ " _n
    file write fd "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\ \toprule" _n
    file write fd "\underline{\textit{Panel A: Pooled}} \\ " _n
    file write fd "\textit{Intensity 1999 x post} & `b99_fd_p_1' & `b99_fd_p_2' & `b99_fd_p_3' & `b99_fd_p_4' & `b99_fd_p_5' \\ " _n
    file write fd " & (`se99_fd_p_1') & (`se99_fd_p_2') & (`se99_fd_p_3') & (`se99_fd_p_4') & (`se99_fd_p_5') \\ " _n
    file write fd "  & & & & & \\ " _n
    file write fd "Obs & `N_fd_p_1' & `N_fd_p_2' & `N_fd_p_3' & `N_fd_p_4' & `N_fd_p_5' \\ " _n
    file write fd "  & & & & & \\ " _n
    file write fd "\underline{\textit{Panel B: Females}} \\ " _n
    file write fd "\textit{Intensity 1999 x post} & `b99_fd_f_1' & `b99_fd_f_2' & `b99_fd_f_3' & `b99_fd_f_4' & `b99_fd_f_5' \\ " _n
    file write fd " & (`se99_fd_f_1') & (`se99_fd_f_2') & (`se99_fd_f_3') & (`se99_fd_f_4') & (`se99_fd_f_5') \\ " _n
    file write fd "  & & & & & \\ " _n
    file write fd "Obs & `N_fd_f_1' & `N_fd_f_2' & `N_fd_f_3' & `N_fd_f_4' & `N_fd_f_5' \\ " _n
    file write fd "  & & & & & \\ " _n
    file write fd "\underline{\textit{Panel C: Males}} \\ " _n
    file write fd "\textit{Intensity 1999 x post} & `b99_fd_m_1' & `b99_fd_m_2' & `b99_fd_m_3' & `b99_fd_m_4' & `b99_fd_m_5' \\ " _n
    file write fd " & (`se99_fd_m_1') & (`se99_fd_m_2') & (`se99_fd_m_3') & (`se99_fd_m_4') & (`se99_fd_m_5') \\ " _n
    file write fd "  & & & & & \\ " _n
    file write fd "Obs & `N_fd_m_1' & `N_fd_m_2' & `N_fd_m_3' & `N_fd_m_4' & `N_fd_m_5' \\ " _n
    file write fd "\bottomrule" _n
    file write fd "\end{tabular}"
    file close fd
}
*/
di "Table (commented out) would have been exported to: $tables/T2_b_mortality_fixeddenom.tex"

*============================================================
* MIGRATION ROBUSTNESS -- ported from codes/archive/02_mortality_06_27_26.do,
* where it lived until the file was split into 02/03/04. It was dropped
* from the live pipeline in that split and never re-added, which is why
* the two tables_app.tex entries for it (at:migration_rob,
* at:migration_rob_agefe) and the main.tex "Threats to identification"
* paragraph that cites them have been commented out ever since -- not a
* deliberate decision to drop the check, just an artifact of the split.
* Restored here, in the same "run + diagnose, output left for review"
* spirit as the rest of this file, plus three fixes over the archived
* version documented at each fix below.
*
* AT_migration_robustness: does Progresa intensity predict the SIZE of
* the 65+ population (65+ counts on the LHS, Intensity_1999/2005 x Post
* on the RHS, same inten1999/inten2005 as the main design -- year-varying
* household-count denominator, per-municipality constant across years).
* If Progresa induced differential elderly out-migration from
* high-intensity municipalities, this should be negative and significant.
*
* AT_migration_robustness_ageFE sharpens this into a triple-difference:
* stacks 65+ against a 50-64 within-municipality control band, so a
* municipality-year FE can absorb general population growth and only the
* *differential* trend of the 65+ band survives.
*
* FIX 0: the archived version's "Mean (1991-1996)" / "Mean 65+
* (1991-1996)" row was always blank in both tables' static output. Cause:
* `post' is coded {1 = 1997-2006, 2 = 1991-1996} throughout this
* pipeline (see the `gen post' block in 02_mortality.do), but the
* archived code summarized `if post == 0', which never matches -- r(mean)
* was always missing. Corrected to `post == 2' below, matching the
* convention already used for this exact row elsewhere (e.g.
* AT4_functional_forms' "Mean (1991-1996)" row in 02_mortality.do).
*
* FIX 4 (see the fuller writeup at the DDD table below): the first real
* run of this table (9 Aug 2026) returned "n/a" for the Levels/Log
* columns even though the log shows both regressions completing
* successfully -- an ambient, left-over `_rc' from `reghdfe' was being
* misread as failure. Every `reghdfe'/`ppmlhdfe' call below is now
* `capture'-prefixed so `_rc' is read cleanly.
*============================================================

cap drop lpopover65 lpopover65_m lpopover65_f
g lpopover65   = log(popover65_)
g lpopover65_m = log(popover65_m)
g lpopover65_f = log(popover65_f)

*------------------------------------------------------------
* FIX 1 (REVISED per the coauthor): which INTENSITY DENOMINATOR the
* migration test uses, as a switch.
*
* The earlier version of this fix put the adjustment on the LHS (65+
* population per 100 households). That was the wrong side of the
* regression and is withdrawn: if Progresa induced general out-migration,
* BOTH popover65_ and hh_tot fall together, the ratio is roughly
* unchanged, and the test reports a comforting null precisely in the case
* it is supposed to catch. A common denominator shared with the outcome
* masks migration; it does not control for it.
*
* The contamination this table actually has to worry about is on the
* RHS. Our default treatment variable is a snapshot of
* intensity_new = pgbenef_new/hh_tot (01_mortality_data.do) taken at
* 1999 / 2005 -- so the denominator is a household count measured AFTER
* the program started. Any program-induced change in household counts
* therefore enters the regressor itself, which is circular in a
* regression whose whole purpose is to ask whether the program moved
* population. Fixing the denominator to a pre-determined base removes
* that channel, which is the coauthor's point and is the right fix.
*
* Options ($mig_intensity):
*   "yearvar"  : inten1999/inten2005 -- snapshot-year (post-program)
*                household denominator. The main design's own variable;
*                keep as the default so this table stays comparable to
*                every other exhibit, but it is the contaminated one.
*   "pv_fixed" : inten1999_fix/inten2005_fix -- Parker & Vogl-style single
*                fixed base hog1997_fixed = 0.3*HH1990 + 0.7*HH2000,
*                built in 02_mortality.do and carried in the checkpoint.
*                Same denominator for both snapshots, so it cannot move
*                with the outcome year. CAVEAT: it interpolates using the
*                2000 census, which is already post-program, so it is
*                fixed but not strictly pre-determined.
*   "pre1990"  : pgbenef_*/hh_tot1990 -- the 1990 census household count,
*                seven years before rollout. Strictly pre-determined, so
*                no program-induced population change can enter the
*                regressor at all. This is the cleanest denominator for
*                THIS table specifically (it is not proposed as a change
*                to the main mortality specification).
*------------------------------------------------------------
global mig_intensity "yearvar"
*global mig_intensity "pv_fixed"
*global mig_intensity "pre1990"

*------------------------------------------------------------
* SECOND SWITCH ($mig_years): which YEARS the migration test may use.
*
* This matters more than it looks. The 65+ population series is not
* observed annually -- 01_mortality_data.do builds it by GEOMETRIC
* INTERPOLATION between census anchors (1990, 1995, 2000, 2005), applying
* a constant per-municipality growth multiplier within each inter-census
* segment. Two consequences for this table:
*
*   (i) Within a segment, every municipality's population grows at a
*       constant rate BY CONSTRUCTION. The post-1997 break the DiD looks
*       for falls INSIDE the 1995-2000 segment, where no break can exist
*       in the data-generating process. So an estimated "post-1997
*       population effect" on the annual panel is not picking up anything
*       that happened in 1997; it is a re-expression of the difference
*       between the 1995-2000 and 2000-2005 census growth rates.
*
*  (ii) N is inflated roughly 16-fold relative to the number of genuinely
*       observed population figures, so the standard errors are far too
*       small and significance is close to mechanical. This is the most
*       likely explanation for the very tight, very significant estimates
*       (e.g. 147.996***) the archived run produced.
*
* "census" restricts to years the population is actually MEASURED rather
* than interpolated. Within the 1991-2006 panel those are 1995, 2000 and
* 2005 (1990 falls outside the panel), giving one pre-program and two
* post-program observations per municipality -- thin, and with no scope
* for a pre-trend test, but honest. Treat a disagreement between "all"
* and "census" as evidence that the annual result is interpolation
* artifact, not migration.
*------------------------------------------------------------
global mig_years "all"
*global mig_years "census"

if "$mig_years" == "census" global mig_yrcond "inlist(year,1995,2000,2005)"
else                        global mig_yrcond "inrange(year,1991,2006)"
di "Migration robustness year sample: $mig_years  ->  $mig_yrcond"

if "$mig_intensity" == "pv_fixed" {
	global mig99 inten1999_fix
	global mig05 inten2005_fix
}
else if "$mig_intensity" == "pre1990" {
	cap drop inten1999_fix90 inten2005_fix90
	gen inten1999_fix90 = pgbenef_1999/hh_tot1990
	gen inten2005_fix90 = pgbenef_2005/hh_tot1990
	replace inten1999_fix90 = 1 if inten1999_fix90 > 1 & !missing(inten1999_fix90)
	replace inten2005_fix90 = 1 if inten2005_fix90 > 1 & !missing(inten2005_fix90)
	label var inten1999_fix90 "Intensity 1999 (fixed 1990-census HH denominator)"
	label var inten2005_fix90 "Intensity 2005 (fixed 1990-census HH denominator)"
	global mig99 inten1999_fix90
	global mig05 inten2005_fix90
}
else {
	global mig99 inten1999
	global mig05 inten2005
}
di "Migration robustness intensity construction: $mig_intensity  (99: $mig99 , 05: $mig05 )"

foreach pnl in p m f {
	if "`pnl'" == "p" {
		local outcome  popover65_
		local loutcome lpopover65
	}
	else if "`pnl'" == "m" {
		local outcome  popover65_m
		local loutcome lpopover65_m
	}
	else {
		local outcome  popover65_f
		local loutcome lpopover65_f
	}

	* Pre-initialize every cell this loop can fill, so a failed regression
	* leaves a visible "n/a" rather than a silently blank/misaligned
	* LaTeX cell (matches the _rc-check pattern used elsewhere in this file).
	foreach c in 1 2 3 {
		local bMG99_`pnl'_`c'   "n/a"
		local seMG99_`pnl'_`c'  "n/a"
		local bMG05_`pnl'_`c'   "n/a"
		local seMG05_`pnl'_`c'  "n/a"
		local meanMG_`pnl'_`c'  "n/a"
		local NMG_`pnl'_`c'     "n/a"
		local NmunMG_`pnl'_`c'  "n/a"
	}

	* col 1: Levels (unweighted)
	capture reghdfe `outcome' c.${mig99}#i.post c.${mig05}#i.post ///
		if $sample_marg & $mig_yrcond, ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	if !_rc & e(N) > 0 {
		local aux: di %12.3f _b[1.post#c.${mig99}]
		local t = abs(_b[1.post#c.${mig99}] / _se[1.post#c.${mig99}])
		if      `t' >= 2.576 local bMG99_`pnl'_1 = "`aux'***"
		else if `t' >= 1.96  local bMG99_`pnl'_1 = "`aux'**"
		else if `t' >= 1.645 local bMG99_`pnl'_1 = "`aux'*"
		else                  local bMG99_`pnl'_1 = "`aux'"
		local seMG99_`pnl'_1: di %12.3f _se[1.post#c.${mig99}]
		local aux: di %12.3f _b[1.post#c.${mig05}]
		local t = abs(_b[1.post#c.${mig05}] / _se[1.post#c.${mig05}])
		if      `t' >= 2.576 local bMG05_`pnl'_1 = "`aux'***"
		else if `t' >= 1.96  local bMG05_`pnl'_1 = "`aux'**"
		else if `t' >= 1.645 local bMG05_`pnl'_1 = "`aux'*"
		else                  local bMG05_`pnl'_1 = "`aux'"
		local seMG05_`pnl'_1: di %12.3f _se[1.post#c.${mig05}]
		sum `outcome' if e(sample) & post == 2
		local meanMG_`pnl'_1: di %12.0fc `r(mean)'
		local NMG_`pnl'_1:    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local NmunMG_`pnl'_1: di %12.0fc `r(ndistinct)'
	}
	else di as error "Migration robustness, panel `pnl', col 1 (Levels): reghdfe failed or empty sample (rc=`_rc'), leaving cells n/a"

	* col 2: Log (unweighted)
	capture reghdfe `loutcome' c.${mig99}#i.post c.${mig05}#i.post ///
		if $sample_marg & $mig_yrcond, ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	if !_rc & e(N) > 0 {
		local aux: di %12.3f _b[1.post#c.${mig99}]
		local t = abs(_b[1.post#c.${mig99}] / _se[1.post#c.${mig99}])
		if      `t' >= 2.576 local bMG99_`pnl'_2 = "`aux'***"
		else if `t' >= 1.96  local bMG99_`pnl'_2 = "`aux'**"
		else if `t' >= 1.645 local bMG99_`pnl'_2 = "`aux'*"
		else                  local bMG99_`pnl'_2 = "`aux'"
		local seMG99_`pnl'_2: di %12.3f _se[1.post#c.${mig99}]
		local aux: di %12.3f _b[1.post#c.${mig05}]
		local t = abs(_b[1.post#c.${mig05}] / _se[1.post#c.${mig05}])
		if      `t' >= 2.576 local bMG05_`pnl'_2 = "`aux'***"
		else if `t' >= 1.96  local bMG05_`pnl'_2 = "`aux'**"
		else if `t' >= 1.645 local bMG05_`pnl'_2 = "`aux'*"
		else                  local bMG05_`pnl'_2 = "`aux'"
		local seMG05_`pnl'_2: di %12.3f _se[1.post#c.${mig05}]
		sum `loutcome' if e(sample) & post == 2
		local meanMG_`pnl'_2: di %12.2f `r(mean)'
		local NMG_`pnl'_2:    di %12.0fc `e(N)'
		* FIX 2: the archived version never computed a column-specific
		* Nmun for Log/Poisson and just reused column 1's in the table
		* write -- wrong whenever log(0) (municipality-year cells with
		* zero elderly population) drops observations that Levels/Poisson
		* keep, which changes the underlying set of municipalities.
		distinct cve_ent_mun_super if e(sample)
		local NmunMG_`pnl'_2: di %12.0fc `r(ndistinct)'
	}
	else di as error "Migration robustness, panel `pnl', col 2 (Log): reghdfe failed or empty sample (rc=`_rc'), leaving cells n/a"

	* col 3: Poisson (count outcome)
	capture ppmlhdfe `outcome' c.${mig99}#i.post c.${mig05}#i.post ///
		if $sample_marg & $mig_yrcond, ///
		a(year cve_ent_mun_super) vce(cluster cve_ent_mun_super)
	if !_rc & e(N) > 0 {
		local aux: di %12.3f exp(_b[1.post#c.${mig99}])-1
		local seMG99_`pnl'_3: di %12.3f exp(_b[1.post#c.${mig99}])*_se[1.post#c.${mig99}]
		local t = abs(`aux' / `seMG99_`pnl'_3')
		if      `t' >= 2.576 local bMG99_`pnl'_3 = "`aux'***"
		else if `t' >= 1.96  local bMG99_`pnl'_3 = "`aux'**"
		else if `t' >= 1.645 local bMG99_`pnl'_3 = "`aux'*"
		else                  local bMG99_`pnl'_3 = "`aux'"
		local aux: di %12.3f exp(_b[1.post#c.${mig05}])-1
		local seMG05_`pnl'_3: di %12.3f exp(_b[1.post#c.${mig05}])*_se[1.post#c.${mig05}]
		local t = abs(`aux' / `seMG05_`pnl'_3')
		if      `t' >= 2.576 local bMG05_`pnl'_3 = "`aux'***"
		else if `t' >= 1.96  local bMG05_`pnl'_3 = "`aux'**"
		else if `t' >= 1.645 local bMG05_`pnl'_3 = "`aux'*"
		else                  local bMG05_`pnl'_3 = "`aux'"
		sum `outcome' if e(sample) & post == 2
		local meanMG_`pnl'_3: di %12.0fc `r(mean)'
		local NMG_`pnl'_3:    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local NmunMG_`pnl'_3: di %12.0fc `r(ndistinct)'
	}
	else di as error "Migration robustness, panel `pnl', col 3 (Poisson): reghdfe failed or empty sample (rc=`_rc'), leaving cells n/a"

}

{
	cap file close sm
	file open sm using "$tables/appendix/AT_migration_robustness.tex", write replace
	file write sm "\begin{tabular}{lccc} \hline \hline" _n
	file write sm "& Levels & Log & Poisson \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\ \toprule" _n
	* NOTE: Intensity 2005 x Post is estimated and included as a control in
	* every regression above (needed to isolate the early-phase Intensity
	* 1999 coefficient) but is not printed below, matching the convention
	* already used for Table~\ref{t:did_age} in the main text ("included
	* in every regression as a control but is not reported, as it has no
	* stand-alone interpretation in this specification"). The bMG05_*/
	* seMG05_* locals above are still computed for anyone who wants them.
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `bMG99_p_1' & `bMG99_p_2' & `bMG99_p_3' \\ " _n
	file write sm "  & (`seMG99_p_1') & (`seMG99_p_2') & (`seMG99_p_3') \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Mean (1991-1996)  & `meanMG_p_1' & `meanMG_p_2' & `meanMG_p_3' \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "\underline{\textit{Panel B: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)}  & `bMG99_f_1' & `bMG99_f_2' & `bMG99_f_3' \\ " _n
	file write sm "  & (`seMG99_f_1') & (`seMG99_f_2') & (`seMG99_f_3') \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Mean (1991-1996)  & `meanMG_f_1' & `meanMG_f_2' & `meanMG_f_3' \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "\underline{\textit{Panel C: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post (1997-2006)} & `bMG99_m_1' & `bMG99_m_2' & `bMG99_m_3' \\ " _n
	file write sm "  & (`seMG99_m_1') & (`seMG99_m_2') & (`seMG99_m_3') \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Mean (1991-1996) & `meanMG_m_1' & `meanMG_m_2' & `meanMG_m_3' \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Obs & `NMG_f_1' & `NMG_f_2' & `NMG_f_3' \\ " _n
	file write sm "No. Mun & `NmunMG_p_1' & `NmunMG_p_2' & `NmunMG_p_3' \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
di "Table exported to: $tables/appendix/AT_migration_robustness.tex"

*============================================================
* APPENDIX TABLE: Migration Robustness -- Triple-Difference (DDD)
*   Differential growth of the 65+ population relative to the
*   50-64 population, in high- vs low-intensity municipalities,
*   post vs pre. Stacks 6 five-year age groups (50-54, 55-59,
*   60-64, 65-69, 70-74, 75+). popover75 = popover70 - pop7074.
*   Old65 = 1{age >= 65}.
*
*   Specification (long-run, 1991-2006):
*       pop_{m,t,a} = beta . (Intensity_1999 x Post x Old65)
*                   + gamma . (Intensity_2005 x Post x Old65)
*                   + Mun x Year + Mun x Age + Year x Age FE + e
*   Mun x Year FE absorbs overall municipality-year pop growth;
*   identification rests on the triple interaction.
*
*   3 cols (Levels / Log / Poisson) x 3 panels (Pooled / M / F).
*
*   FIX 3: the archived run of this table printed "0.000***" in every
*   single cell (coefficient AND standard error) with the Mean 65+ row
*   blank, which is not a plausible small-but-real estimate -- SEs do not
*   independently round to exactly zero in every cell. The likely
*   mechanism: `_b[]'/`_se[]' on a coefficient name that reghdfe did not
*   actually estimate return literal 0, and `t' = abs(0/0) evaluates to
*   Stata missing (.), which the `if `t' >= 2.576' comparisons treat as
*   +infinity, so every cell silently gets "0.000***" instead of erroring.
*   Cannot confirm the exact cause without re-running (no Stata/data
*   access in this environment), so this port adds two defenses: (i) an
*   explicit, hand-built triple-interaction variable in place of the
*   `c.inten99#i.post#i.old65' factor syntax, removing any ambiguity in
*   which coefficient name is being pulled; (ii) an `_rc'/`e(N)' check
*   around each regression (as in FIX 2 above) so a failed or degenerate
*   fit leaves "n/a" rather than a fabricated "0.000***". Precision is
*   also widened from 3 to 4 decimals in case the true issue was just
*   under-precision for a genuinely small DDD coefficient.
*
*   FIX 4 (found on the first real run, 9 Aug 2026 log): (ii) above was
*   itself broken. The Levels/Log columns of BOTH migration tables came
*   back "n/a" in that run, but the log shows each underlying `reghdfe'
*   completing normally -- valid coefficient table, correct N, no error
*   -- immediately before the "leaving cells n/a" message fires. The
*   Poisson column (`ppmlhdfe', same guard, same data) came back with
*   real numbers every time. Since a genuine estimation failure with no
*   `capture' prefix would halt the whole do-file rather than fall
*   through to the `else' branch, the only way `else' can ever fire here
*   is a NONZERO `_rc' left over from something that did not abort --
*   apparently a `reghdfe' internal step (plausibly its own handling of
*   the collinear `2.post#...' term it drops and reports as a "note", as
*   seen in the log) does not always reset `_rc' to 0 on exit, even
*   though ppmlhdfe's does. Net effect: the guard was silently discarding
*   correct results and replacing them with "n/a" -- a worse failure mode
*   than the bug it was added to prevent. Fixed by prefixing every
*   `reghdfe'/`ppmlhdfe' call in both migration tables with `capture',
*   so `_rc' reflects exactly that command's own outcome rather than
*   whatever state was already sitting in `_rc' beforehand -- the same
*   pattern already used successfully (and without this problem) in the
*   attrition test (03_experimental.do) and the fixed-offset Poisson
*   table below, both of which returned real numbers on the same run.
*============================================================
destring(cve_ent_mun_super), replace

foreach pnl in p m f {
	foreach c in 1 2 3 {
		local bDDD99_`pnl'_`c'   "n/a"
		local seDDD99_`pnl'_`c'  "n/a"
		local bDDD05_`pnl'_`c'   "n/a"
		local seDDD05_`pnl'_`c'  "n/a"
		local meanDDD_`pnl'_`c'  "n/a"
		local NDDD_`pnl'_`c'     "n/a"
		local NmunDDD_`pnl'_`c'  "n/a"
	}

	preserve
	if "`pnl'" == "p" local sfx "_"
	else              local sfx "_`pnl'"

	keep cve_ent_mun_super year $mig99 $mig05 post gm_mun_1990 ///
		pop5054`sfx' pop5559`sfx' pop6064`sfx' ///
		pop6569`sfx' pop7074`sfx' popover70`sfx'
	keep if $mig_yrcond

	gen popover75`sfx' = popover70`sfx' - pop7074`sfx'
	drop popover70`sfx'

	rename pop5054`sfx'   pop1
	rename pop5559`sfx'   pop2
	rename pop6064`sfx'   pop3
	rename pop6569`sfx'   pop4
	rename pop7074`sfx'   pop5
	rename popover75`sfx' pop6

	reshape long pop, i(cve_ent_mun_super year) j(age_grp)
	gen old65 = (age_grp >= 4)
	gen lpop  = log(pop)

	* FIX 3(i): explicit interaction variables instead of factor syntax
	* NOTE: `post' is coded {1 = 1997-2006, 2 = 1991-1996} in this pipeline,
	* NOT {0,1}. The archived factor syntax (i.post) handled that correctly
	* because `_b[1.post#...]' selects the level; a hand-built interaction
	* must NOT multiply by `post' directly or the pre-period enters with
	* weight 2 instead of 0. Build an explicit 0/1 post dummy first.
	cap drop postd
	gen byte postd = (post == 1) if !missing(post)
	gen triple99 = ${mig99} * postd * old65
	gen triple05 = ${mig05} * postd * old65

	* col 1: Levels DDD
	capture reghdfe pop triple99 triple05 if $sample_marg, ///
		a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
		vce(cluster cve_ent_mun_super)
	if !_rc & e(N) > 0 {
		local aux: di %12.4f _b[triple99]
		local t = abs(_b[triple99] / _se[triple99])
		if      `t' >= 2.576 local bDDD99_`pnl'_1 = "`aux'***"
		else if `t' >= 1.96  local bDDD99_`pnl'_1 = "`aux'**"
		else if `t' >= 1.645 local bDDD99_`pnl'_1 = "`aux'*"
		else                  local bDDD99_`pnl'_1 = "`aux'"
		local seDDD99_`pnl'_1: di %12.4f _se[triple99]
		local aux: di %12.4f _b[triple05]
		local t = abs(_b[triple05] / _se[triple05])
		if      `t' >= 2.576 local bDDD05_`pnl'_1 = "`aux'***"
		else if `t' >= 1.96  local bDDD05_`pnl'_1 = "`aux'**"
		else if `t' >= 1.645 local bDDD05_`pnl'_1 = "`aux'*"
		else                  local bDDD05_`pnl'_1 = "`aux'"
		local seDDD05_`pnl'_1: di %12.4f _se[triple05]
		sum pop if e(sample) & post == 2 & old65 == 1
		local meanDDD_`pnl'_1: di %12.0fc `r(mean)'
		local NDDD_`pnl'_1:    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local NmunDDD_`pnl'_1: di %12.0fc `r(ndistinct)'
	}
	else di as error "Migration DDD, panel `pnl', col 1 (Levels): reghdfe failed or empty sample (rc=`_rc'), leaving cells n/a"

	* col 2: Log DDD
	capture reghdfe lpop triple99 triple05 if $sample_marg, ///
		a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
		vce(cluster cve_ent_mun_super)
	if !_rc & e(N) > 0 {
		local aux: di %12.4f _b[triple99]
		local t = abs(_b[triple99] / _se[triple99])
		if      `t' >= 2.576 local bDDD99_`pnl'_2 = "`aux'***"
		else if `t' >= 1.96  local bDDD99_`pnl'_2 = "`aux'**"
		else if `t' >= 1.645 local bDDD99_`pnl'_2 = "`aux'*"
		else                  local bDDD99_`pnl'_2 = "`aux'"
		local seDDD99_`pnl'_2: di %12.4f _se[triple99]
		local aux: di %12.4f _b[triple05]
		local t = abs(_b[triple05] / _se[triple05])
		if      `t' >= 2.576 local bDDD05_`pnl'_2 = "`aux'***"
		else if `t' >= 1.96  local bDDD05_`pnl'_2 = "`aux'**"
		else if `t' >= 1.645 local bDDD05_`pnl'_2 = "`aux'*"
		else                  local bDDD05_`pnl'_2 = "`aux'"
		local seDDD05_`pnl'_2: di %12.4f _se[triple05]
		sum lpop if e(sample) & post == 2 & old65 == 1
		local meanDDD_`pnl'_2: di %12.2f `r(mean)'
		local NDDD_`pnl'_2:    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local NmunDDD_`pnl'_2: di %12.0fc `r(ndistinct)'
	}
	else di as error "Migration DDD, panel `pnl', col 2 (Log): reghdfe failed or empty sample (rc=`_rc'), leaving cells n/a"

	* col 3: Poisson DDD
	capture ppmlhdfe pop triple99 triple05 if $sample_marg, ///
		a(cve_ent_mun_super#year cve_ent_mun_super#age_grp year#age_grp) ///
		vce(cluster cve_ent_mun_super)
	if !_rc & e(N) > 0 {
		local aux: di %12.4f exp(_b[triple99])-1
		local seDDD99_`pnl'_3: di %12.4f exp(_b[triple99])*_se[triple99]
		local t = abs(`aux' / `seDDD99_`pnl'_3')
		if      `t' >= 2.576 local bDDD99_`pnl'_3 = "`aux'***"
		else if `t' >= 1.96  local bDDD99_`pnl'_3 = "`aux'**"
		else if `t' >= 1.645 local bDDD99_`pnl'_3 = "`aux'*"
		else                  local bDDD99_`pnl'_3 = "`aux'"
		local aux: di %12.4f exp(_b[triple05])-1
		local seDDD05_`pnl'_3: di %12.4f exp(_b[triple05])*_se[triple05]
		local t = abs(`aux' / `seDDD05_`pnl'_3')
		if      `t' >= 2.576 local bDDD05_`pnl'_3 = "`aux'***"
		else if `t' >= 1.96  local bDDD05_`pnl'_3 = "`aux'**"
		else if `t' >= 1.645 local bDDD05_`pnl'_3 = "`aux'*"
		else                  local bDDD05_`pnl'_3 = "`aux'"
		sum pop if e(sample) & post == 2 & old65 == 1
		local meanDDD_`pnl'_3: di %12.0fc `r(mean)'
		local NDDD_`pnl'_3:    di %12.0fc `e(N)'
		distinct cve_ent_mun_super if e(sample)
		local NmunDDD_`pnl'_3: di %12.0fc `r(ndistinct)'
	}
	else di as error "Migration DDD, panel `pnl', col 3 (Poisson): reghdfe failed or empty sample (rc=`_rc'), leaving cells n/a"

	restore
}

{
	cap file close sm
	file open sm using "$tables/appendix/AT_migration_robustness_ageFE.tex", write replace
	file write sm "\begin{tabular}{lccc} \hline \hline" _n
	file write sm "& Levels & Log & Poisson \\ " _n
	file write sm "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}" _n
	file write sm "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\ \toprule" _n
	* NOTE: Intensity 2005 x Post x Old65 is estimated in every regression
	* above but not printed below, matching the display convention used
	* for the simple migration table and for Table~\ref{t:did_age} in the
	* main text. UNLIKE the simple table, this coefficient is NOT purely a
	* nuisance control here -- it is a second, independently meaningful
	* differential-trend test, and on the one real run so far it came back
	* significant in all three panels while Intensity 1999 did not (see
	* migration_robustness_summary.md, Sec. 7.2). Dropping it from the
	* printed table does not make that finding go away; it is still in
	* the bDDD05_*/seDDD05_* locals above and in the run log, and belongs
	* in the text/summary discussion of this table even though it is not
	* shown in the table itself.
	file write sm "\underline{\textit{Panel A: Pooled}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post x Old65} & `bDDD99_p_1' & `bDDD99_p_2' & `bDDD99_p_3' \\ " _n
	file write sm "  & (`seDDD99_p_1') & (`seDDD99_p_2') & (`seDDD99_p_3') \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Mean 65+ (1991-1996)  & `meanDDD_p_1' & `meanDDD_p_2' & `meanDDD_p_3' \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "\underline{\textit{Panel B: Females}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post x Old65}  & `bDDD99_f_1' & `bDDD99_f_2' & `bDDD99_f_3' \\ " _n
	file write sm "  & (`seDDD99_f_1') & (`seDDD99_f_2') & (`seDDD99_f_3') \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Mean 65+ (1991-1996)  & `meanDDD_f_1' & `meanDDD_f_2' & `meanDDD_f_3' \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "\underline{\textit{Panel C: Males}}  \\ " _n
	file write sm "\textit{Intensity 1999 x post x Old65} & `bDDD99_m_1' & `bDDD99_m_2' & `bDDD99_m_3' \\ " _n
	file write sm "  & (`seDDD99_m_1') & (`seDDD99_m_2') & (`seDDD99_m_3') \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Mean 65+ (1991-1996) & `meanDDD_m_1' & `meanDDD_m_2' & `meanDDD_m_3' \\ " _n
	file write sm "  & & &  \\ " _n
	file write sm "Obs & `NDDD_f_1' & `NDDD_f_2' & `NDDD_f_3' \\ " _n
	file write sm "No. Mun & `NmunDDD_p_1' & `NmunDDD_p_2' & `NmunDDD_p_3' \\ " _n
	file write sm "  & & & \\ " _n
	file write sm "\bottomrule" _n
	file write sm "\end{tabular}"
	file close sm
}
di "Table exported to: $tables/appendix/AT_migration_robustness_ageFE.tex"

*============================================================
* MIGRATION EVENT STUDY: 65+ POPULATION, YEAR BY YEAR
* Output: $figures/appendix/AF_migration_es.pdf (levels)
*         $figures/appendix/AF_migration_es_log.pdf (log)
*
* The two tables above report a single post-1997 interaction, which
* cannot distinguish "the program moved population after 1997" from "the
* two groups of municipalities were already on different population
* trajectories". This is the same distinction the paper already insists
* on for mortality, applied to the migration threat: if the apparent
* population effect is present BEFORE 1997, it is not the program, and
* the threat is a pre-existing difference in demographic trends rather
* than program-induced out-migration.
*
* Same construction as the mortality event studies (reference year 1996,
* year_1995 index 1-16, municipality and year FE, clustered at the
* municipality), so the two are read side by side.
*
* Two versions, one per pair of columns in Appendix Table~\ref{at:migration_rob}:
* levels (its column 1) and log population (its column 2), following the
* precedent of Appendix Figure~\ref{af:es_func_form} plotting both a
* levels and a log panel of the same underlying event study. Poisson is
* not plotted as an event study here (a coefficient-per-year Poisson
* profile is a bigger addition, not just a second panel of the same
* graph) -- can be added the same way if wanted.
*
* NOTE: under $mig_years == "census" neither figure is meaningful -- there
* are only three sampled years -- so both are skipped in that case.
*============================================================
if "$mig_years" == "census" {
	di as text "Population event studies skipped: $mig_years leaves too few years to trace a profile."
}
else {
	foreach spec in lvl log {
		if "`spec'" == "lvl" {
			local esout_p popover65_
			local esout_m popover65_m
			local esout_f popover65_f
			local es_ytitle "Population 65+ (count)"
			local es_outfile "$figures/appendix/AF_migration_es.pdf"
		}
		else {
			local esout_p lpopover65
			local esout_m lpopover65_m
			local esout_f lpopover65_f
			local es_ytitle "Log population 65+"
			local es_outfile "$figures/appendix/AF_migration_es_log.pdf"
		}

		foreach pnl in p m f {
			local esout `esout_`pnl''

			capture reghdfe `esout' c.${mig99}##ib6.year_1995 c.sp_intensity ///
				if $sample_marg & $mig_yrcond, ///
				a(cve_ent_mun_super) vce(cluster cve_ent_mun_super)
			if !_rc & e(N) > 0 {
				forval pos = 1/16 {
					if `pos' == 6 {
						local bes_`pnl'_`pos'  = 0
						local sees_`pnl'_`pos' = 0
					}
					else {
						local bes_`pnl'_`pos'  = _b[`pos'.year_1995#c.${mig99}]
						local sees_`pnl'_`pos' = _se[`pos'.year_1995#c.${mig99}]
					}
				}
				local esok_`pnl' = 1
			}
			else {
				di as error "Population event study (`spec'), panel `pnl': reghdfe failed (rc=`_rc'); panel skipped"
				local esok_`pnl' = 0
			}
		}

		if `esok_p' == 1 & `esok_m' == 1 & `esok_f' == 1 {
			preserve
			clear
			set obs 16
			gen yr_pos = _n
			gen xpos_p = yr_pos - 0.18
			gen xpos_m = yr_pos
			gen xpos_f = yr_pos + 0.18
			foreach s in p m f {
				gen b_`s'  = .
				gen hi_`s' = .
				gen lo_`s' = .
			}
			forval pos = 1/16 {
				foreach s in p m f {
					replace b_`s'  = `bes_`s'_`pos''                          if yr_pos == `pos'
					replace hi_`s' = `bes_`s'_`pos'' + 1.96 * `sees_`s'_`pos'' if yr_pos == `pos'
					replace lo_`s' = `bes_`s'_`pos'' - 1.96 * `sees_`s'_`pos'' if yr_pos == `pos'
				}
			}

			twoway ///
				(rcap hi_p lo_p xpos_p, lcolor(black%60) lwidth(vthin) lpattern(solid)) ///
				(scatter b_p xpos_p, mcolor(black) msymbol(circle) msize(vsmall)) ///
				(rcap hi_f lo_f xpos_f, lcolor(red%60) lwidth(vthin) lpattern(dash)) ///
				(scatter b_f xpos_f, mcolor(red) msymbol(square) msize(vsmall)) ///
				(rcap hi_m lo_m xpos_m, lcolor(blue%60) lwidth(vthin) lpattern(shortdash_dot)) ///
				(scatter b_m xpos_m, mcolor(blue) msymbol(triangle) msize(vsmall)) ///
				(line b_p xpos_p if 1==0, lcolor(black) lpattern(solid) lwidth(thin) mcolor(black) msymbol(circle) msize(vsmall)) ///
				(line b_f xpos_f if 1==0, lcolor(red) lpattern(dash) lwidth(thin) mcolor(red) msymbol(square) msize(vsmall)) ///
				(line b_m xpos_m if 1==0, lcolor(blue) lpattern(shortdash_dot) lwidth(thin) mcolor(blue) msymbol(triangle) msize(vsmall)), ///
				yline(0, lcolor(gs8) lpattern(solid) lwidth(vthin)) ///
				xline(6.5, lcolor(yellow) lpattern(dash) lwidth(vthin)) ///
				xlabel(`yr_labels', labsize(small) angle(45) labcolor(black)) ///
				xscale(range(0.5 16.5)) ///
				xtitle("") ///
				ytitle("`es_ytitle'", size(medsmall)) ///
				ylabel(, grid gmin gmax labsize(small)) ///
				legend(order(7 "Pooled" 8 "Female" 9 "Male") ///
					cols(3) size(small) position(6) ring(1) ///
					region(lcolor(none)) symxsize(5) keygap(1) rowgap(0)) ///
				graphregion(color(white)) ///
				plotregion(margin(l=1 r=1))
			graph export "`es_outfile'", as(pdf) replace
			restore
			di "Figure exported to: `es_outfile'"
		}
		else di as error "Population event study (`spec') not plotted: at least one panel failed to estimate."
	}
}

*============================================================
* MORTALITY WITH A PRE-PROGRAM (FIXED) POPULATION OFFSET
* Output: $tables/appendix/AT_fixed_offset_poisson.tex
*
* This is the check that makes the migration threat moot for the paper's
* HEADLINE result rather than merely testing it.
*
* Migration threatens the mortality estimate through the DENOMINATOR: the
* outcome emr65 = death65*1000/popover65_ divides by a contemporaneous,
* post-program population that migration can move. If instead we model
* raw DEATH COUNTS with an offset FIXED at each municipality's 1996
* (pre-program) 65+ population, no post-1997 population change can enter
* the estimate at all -- by construction, not by assumption. Column (2)
* is therefore immune to the entire selective-out-migration story.
*
* Column (1) repeats the standard Poisson with the contemporaneous
* offset (as in AT4_functional_forms) so the two are directly comparable:
* if (1) and (2) agree, migration cannot be driving the mortality null,
* whatever the population tables happen to show.
*============================================================
cap drop popover65_1996 popover65_m1996 popover65_f1996
foreach sfx in "_" "_m" "_f" {
	g aux = popover65`sfx' if year == 1996
	bys cve_ent_mun_super: egen popover65`sfx'1996 = min(aux)
	drop aux
}
cap drop lpop96 lpop96_m lpop96_f
g lpop96   = log(popover65_1996)
g lpop96_m = log(popover65_m1996)
g lpop96_f = log(popover65_f1996)

foreach pnl in p m f {
	if "`pnl'" == "p" {
		local dout death65
		local offc lpopover65
		local offf lpop96
		local wv   popover65_
	}
	else if "`pnl'" == "m" {
		local dout death65m
		local offc lpopover65_m
		local offf lpop96_m
		local wv   popover65_m
	}
	else {
		local dout death65f
		local offc lpopover65_f
		local offf lpop96_f
		local wv   popover65_f
	}

	foreach c in 1 2 {
		local bFO_`pnl'_`c'  "n/a"
		local seFO_`pnl'_`c' "n/a"
		local NFO_`pnl'_`c'  "n/a"
	}

	* col 1: contemporaneous offset (the standard specification)
	* col 2: offset fixed at the 1996 pre-program population
	forval c = 1/2 {
		if `c' == 1 local offset_use `offc'
		else        local offset_use `offf'

		capture ppmlhdfe `dout' c.inten1999#i.post c.inten2005#i.post c.sp_intensity ///
			[pw=`wv'] if $sample_marg, a(year cve_ent_mun_super) ///
			offset(`offset_use') vce(cluster cve_ent_mun_super)
		if !_rc & e(N) > 0 {
			local aux : di %12.2f (exp(_b[1.post#c.inten1999])-1)*100
			local seFO_`pnl'_`c' : di %12.2f exp(_b[1.post#c.inten1999])*_se[1.post#c.inten1999]*100
			local t = abs(`aux' / `seFO_`pnl'_`c'')
			if      `t' >= 2.576 local bFO_`pnl'_`c' = "`aux'***"
			else if `t' >= 1.96  local bFO_`pnl'_`c' = "`aux'**"
			else if `t' >= 1.645 local bFO_`pnl'_`c' = "`aux'*"
			else                  local bFO_`pnl'_`c' = "`aux'"
			local NFO_`pnl'_`c' : di %12.0fc e(N)
		}
		else di as error "Fixed-offset Poisson, panel `pnl', col `c': ppmlhdfe failed or empty sample (rc=`_rc'), leaving cells n/a"
	}
}

{
	cap file close fo
	file open fo using "$tables/appendix/AT_fixed_offset_poisson.tex", write replace
	file write fo "\begin{tabular}{lcc} \hline \hline" _n
	file write fo "& Contemporaneous offset & Fixed 1996 offset \\ " _n
	file write fo "\cmidrule(lr){2-2}\cmidrule(lr){3-3}" _n
	file write fo "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} \\ \toprule" _n
	file write fo "\underline{\textit{Panel A: Pooled}} \\ " _n
	file write fo "\textit{Intensity 1999 x post (1997-2006)} & `bFO_p_1' & `bFO_p_2' \\ " _n
	file write fo " & (`seFO_p_1') & (`seFO_p_2') \\ " _n
	file write fo "Obs & `NFO_p_1' & `NFO_p_2' \\ " _n
	file write fo "  & & \\ " _n
	file write fo "\underline{\textit{Panel B: Females}} \\ " _n
	file write fo "\textit{Intensity 1999 x post (1997-2006)} & `bFO_f_1' & `bFO_f_2' \\ " _n
	file write fo " & (`seFO_f_1') & (`seFO_f_2') \\ " _n
	file write fo "Obs & `NFO_f_1' & `NFO_f_2' \\ " _n
	file write fo "  & & \\ " _n
	file write fo "\underline{\textit{Panel C: Males}} \\ " _n
	file write fo "\textit{Intensity 1999 x post (1997-2006)} & `bFO_m_1' & `bFO_m_2' \\ " _n
	file write fo " & (`seFO_m_1') & (`seFO_m_2') \\ " _n
	file write fo "Obs & `NFO_m_1' & `NFO_m_2' \\ \bottomrule" _n
	file write fo "\end{tabular}"
	file close fo
}
di "Table exported to: $tables/appendix/AT_fixed_offset_poisson.tex"

log close
