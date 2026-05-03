*** ========================================================================
*** PROPOSED: Age-Adjusted Mortality Rate Calculation (using 1995 standard)
*** ========================================================================
*** This code properly calculates AAMR for ages 50+, 65+, and cause-of-death
*** using the 1995 municipality population age structure as the standard.
*** Add this section after age-specific mortality rates are calculated
*** in the main data assembly (aamr_011326.do)
*** ========================================================================

*** ---- Step 1: Save 1995 age structure as the standard population ----
*** Extract the 1995 population distribution (used for all years)
*** and normalize to get weight shares by age group

preserve
keep if year == 1995
keep cve_ent_mun_super pop5054_ pop5559_ pop6064_ popover65_ ///
       pop5054_m pop5559_m pop6064_m popover65_m ///
       pop5054_f pop5559_f pop6064_f popover65_f

rename pop5054_   pop1995_5054
rename pop5559_   pop1995_5559
rename pop6064_   pop1995_6064
rename popover65_ pop1995_over65
rename pop5054_m  pop1995_5054_m
rename pop5559_m  pop1995_5559_m
rename pop6064_m  pop1995_6064_m
rename popover65_m pop1995_over65_m
rename pop5054_f  pop1995_5054_f
rename pop5559_f  pop1995_5559_f
rename pop6064_f  pop1995_6064_f
rename popover65_f pop1995_over65_f

tempfile std_pop_1995
save `std_pop_1995'
restore

merge m:1 cve_ent_mun_super using `std_pop_1995', nogen


*** ---- Step 2: Calculate age-specific death rates (per 100,000) ----
*** These will be multiplied by the standard population structure

foreach grp in 5054 5559 6064 over65 {
	gen asr`grp' = death`grp' * 100000 / pop`grp'_ if pop`grp'_ > 0
	gen asr`grp'_m = death`grp'm * 100000 / pop`grp'_m if pop`grp'_m > 0
	gen asr`grp'_f = death`grp'f * 100000 / pop`grp'_f if pop`grp'_f > 0

	label var asr`grp' "Age-specific death rate, `grp', per 100,000"
	label var asr`grp'_m "Age-specific death rate, `grp', male, per 100,000"
	label var asr`grp'_f "Age-specific death rate, `grp', female, per 100,000"
}


*** ---- Step 3: Age-Adjust Mortality Rates (AAMR) ----
*** AAMR = sum(ASR_i * W_i) where W_i = standard population weight for age group i
***
*** For 65+ AAMR: use only 65+ age groups in the standard population
*** For 50+ AAMR: use all age groups 50-54, 55-59, 60-64, 65+

** Standard population weights (overall, 1995 basis)
gen std_wt_5054 = pop1995_5054 / (pop1995_5054 + pop1995_5559 + pop1995_6064 + pop1995_over65)
gen std_wt_5559 = pop1995_5559 / (pop1995_5054 + pop1995_5559 + pop1995_6064 + pop1995_over65)
gen std_wt_6064 = pop1995_6064 / (pop1995_5054 + pop1995_5559 + pop1995_6064 + pop1995_over65)
gen std_wt_over65 = pop1995_over65 / (pop1995_5054 + pop1995_5559 + pop1995_6064 + pop1995_over65)

** Standard population weights by sex (male, 1995 basis)
gen std_wt_5054_m = pop1995_5054_m / (pop1995_5054_m + pop1995_5559_m + pop1995_6064_m + pop1995_over65_m)
gen std_wt_5559_m = pop1995_5559_m / (pop1995_5054_m + pop1995_5559_m + pop1995_6064_m + pop1995_over65_m)
gen std_wt_6064_m = pop1995_6064_m / (pop1995_5054_m + pop1995_5559_m + pop1995_6064_m + pop1995_over65_m)
gen std_wt_over65_m = pop1995_over65_m / (pop1995_5054_m + pop1995_5559_m + pop1995_6064_m + pop1995_over65_m)

** Standard population weights by sex (female, 1995 basis)
gen std_wt_5054_f = pop1995_5054_f / (pop1995_5054_f + pop1995_5559_f + pop1995_6064_f + pop1995_over65_f)
gen std_wt_5559_f = pop1995_5559_f / (pop1995_5054_f + pop1995_5559_f + pop1995_6064_f + pop1995_over65_f)
gen std_wt_6064_f = pop1995_6064_f / (pop1995_5054_f + pop1995_5559_f + pop1995_6064_f + pop1995_over65_f)
gen std_wt_over65_f = pop1995_over65_f / (pop1995_5054_f + pop1995_5559_f + pop1995_6064_f + pop1995_over65_f)


** AAMR for 50+ (all ages 50-54, 55-59, 60-64, 65+)
gen aamr50 = asr5054 * std_wt_5054 + asr5559 * std_wt_5559 + ///
             asr6064 * std_wt_6064 + asr_over65 * std_wt_over65
gen aamr50_m = asr5054_m * std_wt_5054_m + asr5559_m * std_wt_5559_m + ///
               asr6064_m * std_wt_6064_m + asr_over65_m * std_wt_over65_m
gen aamr50_f = asr5054_f * std_wt_5054_f + asr5559_f * std_wt_5559_f + ///
               asr6064_f * std_wt_6064_f + asr_over65_f * std_wt_over65_f

label var aamr50 "Age-adjusted mortality rate, 50+, per 100,000 (1995 standard pop)"
label var aamr50_m "Age-adjusted mortality rate, 50+, male, per 100,000 (1995 standard pop)"
label var aamr50_f "Age-adjusted mortality rate, 50+, female, per 100,000 (1995 standard pop)"


** AAMR for 65+ (only 65+ age group; normalized by 65+ standard population only)
gen std_wt_over65_norm = pop1995_over65 / pop1995_over65
gen std_wt_over65_m_norm = pop1995_over65_m / pop1995_over65_m
gen std_wt_over65_f_norm = pop1995_over65_f / pop1995_over65_f

gen aamr65 = asr_over65 * std_wt_over65_norm
gen aamr65_m = asr_over65_m * std_wt_over65_m_norm
gen aamr65_f = asr_over65_f * std_wt_over65_f_norm

label var aamr65 "Age-adjusted mortality rate, 65+, per 100,000 (1995 standard pop, 65+ only)"
label var aamr65_m "Age-adjusted mortality rate, 65+, male, per 100,000 (1995 standard pop, 65+ only)"
label var aamr65_f "Age-adjusted mortality rate, 65+, female, per 100,000 (1995 standard pop, 65+ only)"


*** ---- Step 4: AAMR by cause of death (65+) ----
*** Repeat for each cause of death (tb_card, tb_infect, tb_diab, etc.)

foreach k in tb_card tb_infect tb_diab tb_resp tb_nutri tb_cancer tb_accid tb_illdef tb_other {
	gen asr`k'_over65 = `k'over65 * 100000 / popover65_ if popover65_ > 0
	gen asr`k'_over65_m = `k'over65m * 100000 / popover65_m if popover65_m > 0
	gen asr`k'_over65_f = `k'over65f * 100000 / popover65_f if popover65_f > 0

	gen aamr65_`k' = asr`k'_over65 * std_wt_over65_norm
	gen aamr65_`k'_m = asr`k'_over65_m * std_wt_over65_m_norm
	gen aamr65_`k'_f = asr`k'_over65_f * std_wt_over65_f_norm

	label var aamr65_`k' "AAMR 65+, `k', per 100,000 (1995 standard pop)"
	label var aamr65_`k'_m "AAMR 65+, `k', male, per 100,000 (1995 standard pop)"
	label var aamr65_`k'_f "AAMR 65+, `k', female, per 100,000 (1995 standard pop)"
}


*** ---- Step 5: Drop intermediate weight variables (optional cleanup) ----
drop std_wt_* asr*


*** ---- Step 6: Verification checks ----
*** Sanity check: AAMR should be similar in magnitude to EMR for 65+
*** (since we're only using the 65+ age group for AAMR65)
*** For AAMR50, it should be a weighted average of rates from ages 50-64 and 65+

sum emr65 aamr65
sum emr50 aamr50
sum aamr65 aamr65_m aamr65_f
