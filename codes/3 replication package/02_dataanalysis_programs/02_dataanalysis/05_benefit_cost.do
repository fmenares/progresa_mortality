//calculates benefit-cost ratios based on our estimates
//and program cost info. we use female earnings impacts
//and overall program costs (for boys and girls).

clear all
*global Tempdata "../Temp"
*global Costdata "../Cost_Data"

//PARAMETERS
local r = 0.02 //discount rate
local T = 45 //length of potential career

//BENEFITS
*use smallest female point estimate for annual earnings impact (Table 3, col. 5)
global ann_impact_f = 236 * 12 /*no discounting within year*/
di $ann_impact_f
*calculate lifetime benefit by assuming constant impact over potential working years
*treat as an annuity with payments starting at end of 7th year (average beneficiary age 11 at rollout, leaves HS at 18)
global lifetime_impact_f = ($ann_impact_f * (1-1/((1+`r')^`T'))/`r') / ((1+`r')^7)
di $lifetime_impact_f
*weighted sum of program exposure for women in fully exposed cohort
*use full sample, so we are extrapolating our estimated effects for marginalized munis to the whole country
use "$tempdata/mex_2010_ipums.dta" if sex==2 & age>=22&age<=26,clear
sum prop9799_hog [aw=perwt]
global tot_exposure_f = r(sum)
*multiply female earnings impact by total female exposure, divide by 1 mil
global benefit = $lifetime_impact_f * $tot_exposure_f / 1000000
*benefit in millions of pesos
di $benefit

//OPPORTUNITY COST OF LOST EARNINGS WHILE IN SCHOOL
*use largest point estimates for impacts on middle and high school (Table 2, cols. 2 & 6)
global sec_m = 0.163
global sec_f = 0.302
global prep_m = 0.088
global prep_f = 0.170
*average sex-specific earnings for dropouts in appropriate age group in 2000 census
*use full sample, weighted by early program exposure (results are similar if we just use marginado munis)
use "$tempdata/mex_2000_ipums.dta",clear
keep if age>=13&age<=18&school==0
replace perwt = perwt*prop9799_hog //rescale survey weights by early program exposure
sum ingtrmen [aw=perwt] if school==0&age>=13&age<=15&sex==1
global earn_1315_m = r(mean)
sum ingtrmen [aw=perwt] if school==0&age>=13&age<=15&sex==2
global earn_1315_f = r(mean)
sum ingtrmen [aw=perwt] if school==0&age>=16&age<=18&sex==1
global earn_1618_m = r(mean)
sum ingtrmen [aw=perwt] if school==0&age>=16&age<=18&sex==2
global earn_1618_f = r(mean)
*compute discounted expected opportunity costs, assuming no dropout in level, with earnings received at end of year
global oppcost_m = 10 * /*number of months per school year*/ ///
                   ( $sec_m * $earn_1315_m / (1+`r') /*lost earnings in grade 7*/ ///
                   + $sec_m * $earn_1315_m / (1+`r')^2 /*lost earnings in grade 8*/ ///
                   + $sec_m * $earn_1315_m / (1+`r')^3 /*lost earnings in grade 9*/ ///
                   + $prep_m * $earn_1618_m / (1+`r')^4 /*lost earnings in grade 10*/ ///
                   + $prep_m * $earn_1618_m / (1+`r')^5 /*lost earnings in grade 11*/ ///
                   + $prep_m * $earn_1618_m / (1+`r')^6 ) /*lost earnings in grade 12*/
global oppcost_f = 10 * /*number of months per school year*/ ///
                   ( $sec_f * $earn_1315_f / (1+`r') /*lost earnings in grade 7*/ ///
                   + $sec_f * $earn_1315_f / (1+`r')^2 /*lost earnings in grade 8*/ ///
                   + $sec_f * $earn_1315_f / (1+`r')^3 /*lost earnings in grade 9*/ ///
                   + $prep_f * $earn_1618_f / (1+`r')^4 /*lost earnings in grade 10*/ ///
                   + $prep_f * $earn_1618_f / (1+`r')^5 /*lost earnings in grade 11*/ ///
                   + $prep_f * $earn_1618_f / (1+`r')^6 ) /*lost earnings in grade 12*/
*weighted sum of program exposure for men in fully exposed cohort from marginal munis (we already have women from above)
use "$tempdata/mex_2010_ipums.dta" if sex==1 & age>=22&age<=26,clear
sum prop9799_hog [aw=perwt]
global tot_exposure_m = r(sum)
*multiply exposure by opportunity cost, then adjust to millions of 2010 pesos
*annual CPI for all goods, OECD, implies 1 2000MXN = 1.579459157 2010MXN
*see: https://fred.stlouisfed.org/series/MEXCPIALLAINMEI
global oppcost = ( $oppcost_m * $tot_exposure_m + $oppcost_f * $tot_exposure_f ) * 1.579459157 / 1000000
di $oppcost

//DIRECT PROGRAM COSTS
*read in program costs data (in millions of 2000 pesos)
insheet using "$data/02_dataanalysis/costs.csv",clear
list
*adjust for inflation, discount to start of 1997 - for consistency with other parts of program, assume costs are born at end of year
gen transfers_edonly = educ_transfers * (cpi2010/cpi2000) / (1+`r')^(year-1996)
gen transfers_tot = (educ_transfers + social_transfers) * (cpi2010/cpi2000) / (1+`r')^(year-1996)
sum transfers_edonly
return list //sum is total education transfers
sum transfers_tot
return list //sum is total education + social transfers
*generate administrative costs (8.9% of transfers), private costs (2.4% of transfers) based on Coady
gen admin_edonly = 0.089*transfers_edonly
gen private_edonly = 0.024*transfers_edonly
gen admin_tot = 0.089*transfers_tot
gen private_tot = 0.024*transfers_tot
*two scenarios for deadweight loss (fraction of total budget), .2 and .4
gen dwl20pct_edonly = .2 * (transfers_edonly + admin_edonly)
gen dwl40pct_edonly = .4 * (transfers_edonly + admin_edonly)
gen dwl20pct_tot = .2 * (transfers_tot + admin_tot)
gen dwl40pct_tot = .4 * (transfers_tot + admin_tot)
*total costs
gen costs20_edonly = admin_edonly+private_edonly+dwl20pct_edonly
gen costs40_edonly = admin_edonly+private_edonly+dwl40pct_edonly
gen costs20_tot = admin_tot+private_tot+dwl20pct_tot
gen costs40_tot = admin_tot+private_tot+dwl40pct_tot
*sum discounted costs from 1997 to 2000
foreach scenario in 20_edonly 40_edonly 20_tot 40_tot {
  qui sum costs`scenario'
  global directcost`scenario' = r(sum)
}

//SUMMARIZE TOTALS
di $benefit
di $oppcost
di $directcost20_edonly
di $directcost40_edonly
di $directcost20_tot
di $directcost40_tot

//benefit-cost ratio with 20% DWL, only education transfers
di $benefit/($oppcost+$directcost20_edonly)
//benefit-cost ratio with 40% DWL, only education transfers
di $benefit/($oppcost+$directcost40_edonly)
//benefit-cost ratio with 20% DWL, education AND social transfers
di $benefit/($oppcost+$directcost20_tot)
//benefit-cost ratio with 40% DWL, education AND social transfers
di $benefit/($oppcost+$directcost40_tot)

		 
