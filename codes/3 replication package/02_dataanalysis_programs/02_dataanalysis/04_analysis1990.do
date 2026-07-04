
use "$tempdata/mex_1990_ipums.dta" if marginado==1 & age>=22&age<=33,clear

//age in 1977 - still label age97
gen age97 = floor(agebin-13)
tab age age97

//set up interactions
*for event study
foreach a97 in 9 12 14 /*omit 17*/ 19 {
  gen prop9799_age`a97' = prop9799_hog*(age97==`a97')
  label var prop9799_age`a97' "Program Intensity 97-99 * Cohort"
  gen prop9705_age`a97' = prop9705_hog*(age97==`a97')
  label var prop9705_age`a97' "Program Intensity 97-05 * Cohort"
  }

*for diff in diff regression: post 8-13 (bins 9 and 12), pre 16-20 (bins 17 and 19).
*                             omit 14-15 (bin 14).

gen post = (age97<=12) if (age97>=9&age97<=12)|(age97>=17&age97<=19)
label var post "Post Cohort"
gen prop9799_post = prop9799_hog*post
label var prop9799_post "Program Intensity 97-99 * Post Cohort"
gen prop9705_post = prop9705_hog*post
label var prop9705_post "Program Intensity 97-05 * Post Cohort"

//make sure labor market indicators are unconditional on participation
foreach var of varlist wage ingtrmen hortra sector_agric occ_white occ_skilled {
    replace `var' = 0 if trabajo==0 
	}

//generate additional outcomes
pca dirtfloor modernroof hassewage hasflush haspipe haselec [aw=perwt]
predict housing_pc1,score
sum housing_pc1 [aw=perwt]
gen housing_std = (housing_pc1-r(mean))/r(sd)
label var housing_std "Housing index"
gen inc_pc_hh = ingtrmen_hh/persons
label var inc_pc_hh "HH monthly earnings p.c."

//trim top 0.1% from income and hh income pc
//majority of people in top 0.1% have primary education or less.
centile ingtrmen,c(99.9)
gen high = ingtrmen>r(c_1) if ingtrmen<.
tab years high
tab years if high==1 [aw=perwt]
replace ingtrmen = . if high==1
drop high

centile inc_pc_hh,c(99.9)
gen high = inc_pc_hh>r(c_1) if inc_pc_hh<.
tab years high
tab years if high==1 [aw=perwt]
replace inc_pc_hh = . if high==1
drop high

tempfile data1990
save `data1990'

///////////////
//regressions//	
///////////////					  

local i = 1
foreach var of varlist /*schooling*/ years some_sec some_prep some_college ///
                       /*labor*/ trabajo wage sector_agric ingtrmen ///
                       /*HH wellbeing*/ housing_std inc_pc_hh ///
					   /*migration*/ mig5* urbanres ///
					   /*HH/demographic*/ anyparent persons married  /// 
					   /*spousal*/ years_sp age_sp trabajo_sp ingtrmen_sp {
  ///////
  //men//
  ///////
  
  //baseline
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  if `i'==1 {
    outreg2 using "$Results/tables/men1990.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes replace 
	}
  else {
    outreg2 using "$Results/tables/men1990.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
	}
		 
  /////////
  //women//
  /////////
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  if `i'==1 {
    outreg2 using "$Results/tables/women1990.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes replace 
	}
  else {
    outreg2 using "$Results/tables/women1990.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
	}
		 
  local ++i
}

//fertility for women only//
  
foreach var of varlist kids_0_19 kids_0_21 {
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  outreg2 using "$Results/tables/women1990.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
}

///////////////
//compare    //	
//with 2010  //	
//results    //	
///////////////

** set up 2010 data
use "$tempdata/mex_2010_ipums.dta" if marginado==1 & age>=22&age<=33,clear
// generate design variables
gen age97 = floor(agebin-13)
tab age age97
gen post = (age97<=12) if (age97>=9&age97<=12)|(age97>=17&age97<=19)
label var post "Post Cohort"
gen prop9799_post = prop9799_hog*post
label var prop9799_post "Program Intensity 97-99 * Post Cohort"
gen prop9705_post = prop9705_hog*post
label var prop9705_post "Program Intensity 97-05 * Post Cohort"
// modify/generate outcomes
foreach var of varlist wage ingtrmen hortra sector_agric occ_white occ_skilled {
    replace `var' = 0 if trabajo==0 
	}
pca dirtfloor modernroof hassewage hasflush haspipe haselec [aw=perwt]
predict housing_pc1,score
sum housing_pc1 [aw=perwt]
gen housing_std = (housing_pc1-r(mean))/r(sd)
label var housing_std "Housing index"
sum housing_std
pca hascar hascell hascomp haswasher hasrefrig hastv hashotwater [aw=perwt]
predict durable_pc1,score
sum durable_pc1 [aw=perwt]
gen durable_std = (durable_pc1-r(mean))/r(sd)
label var durable_std "Durable goods index"
sum durable_std
gen anyparent = (momhome==1|dadhome==1)
label var anyparent "Lives with parent"
replace ingtrmen_hh = 0 if ingtrmen==0&ingtrmen_hh==. /*households with no working individuals have intrmen_hh=.*/
gen inc_pc_hh = ingtrmen_hh/persons
label var inc_pc_hh "HH monthly earnings p.c."
//trim top 0.1% from income, spousal income, and hh income pc
centile ingtrmen,c(99.9)
gen high = ingtrmen>r(c_1) if ingtrmen<.
tab years high
tab years if high==1 [aw=perwt]
replace ingtrmen = . if high==1
drop high
centile ingtrmen_sp,c(99.9)
gen high = ingtrmen_sp>r(c_1) if ingtrmen_sp<.
tab years high
tab years if high==1 [aw=perwt]
replace ingtrmen_sp = . if high==1
drop high
centile inc_pc_hh,c(99.9)
gen high = inc_pc_hh>r(c_1) if inc_pc_hh<.
tab years high
tab years if high==1 [aw=perwt]
replace inc_pc_hh = . if high==1
drop high

** append to 1990 data
append using `data1990'
gen y2010 = (year==2010)
gen prop9799_post_2010 = prop9799_post*y2010
gen prop9705_post_2010 = prop9705_post*y2010

** stacked regressions
// blank variables to store outcome names and p values for 2010 vs 1990 test
gen outcome = ""
gen p_men = .
gen p_women = .
// regression loops
local i = 1
foreach var of varlist /*schooling*/ years some_sec some_prep some_college ///
                       /*labor*/ trabajo wage sector_agric ingtrmen ///
                       /*HH wellbeing*/ housing_std inc_pc_hh ///
					   /*migration*/ mig5edo urbanres ///
					   /*HH/demographic*/ anyparent persons married  /// 
					   /*spousal*/ years_sp age_sp trabajo_sp ingtrmen_sp {
  replace outcome = "`var'" if _n==`i'
  reghdfe `var' prop9799_post_2010 prop9705_post_2010 prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(i.MUN_PRE##i.y2010 i.age97##i.y2010)
  replace p_men = r(table)[4,1] if _n==`i'
  reghdfe `var' prop9799_post_2010 prop9705_post_2010 prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(i.MUN_PRE##i.y2010 i.age97##i.y2010)
  replace p_women = r(table)[4,1] if _n==`i'
  local ++i
}  
foreach var of varlist kids_0_19 kids_0_21 {
  replace outcome = "`var'" if _n==`i'
  reghdfe `var' prop9799_post_2010 prop9705_post_2010 prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(i.MUN_PRE##i.y2010 i.age97##i.y2010)
  replace p_women = r(table)[4,1] if _n==`i'
  local ++i
}

** list p-values
list outcome p_men p_women if _n<`i'

///////////////
//income     //	
//threshold  //	
//regressions//	
///////////////	
				  
use `data1990', clear

gen x = (_n-1)*100 if _n<=51
gen b_fe = .
gen lb_fe = .
gen ub_fe = .
gen sh = .

  /////////
  //women//
  /////////
  
forvalues i = 0(100)5000 {
  cap drop y`i'
  gen y`i' = ingtrmen>`i'
  qui sum y`i' if sex==2
  replace sh = r(mean) if x==`i'
  reghdfe y`i' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  replace b_fe = _b[prop9799_post] if x==`i'
  replace lb_fe = _b[prop9799_post]-1.96*_se[prop9799_post] if x==`i'
  replace ub_fe = _b[prop9799_post]+1.96*_se[prop9799_post] if x==`i'
  }
  
twoway (rarea lb_fe ub_fe x,color(turquoise%20)) ///
	   (line b_fe x,lcolor(turquoise) lwidth(thick)) ///
       ,subtitle("Women") name(women_coef,replace) graphregion(margin(zero) color(none)) ///
	    legend(off) ///
	    xtitle("") xlabel(,noticks nolabels grid gstyle(dot)) ///
	    ytitle("Effect", color(white)) yline(0,lcolor(black)) ///
		ylabel(-.2(.1).2,grid gstyle(dot))

twoway area sh x,color(dknavy%50) ///
        name(women_share,replace) graphregion(margin(zero) color(none)) fysize(25) ///
	    xtitle("Labor income threshold") xlabel(,grid gstyle(dot)) ///
	    ytitle("Share", color(white)) yscale(reverse) ///
		ylabel(0(.1).7,grid gstyle(dot))

graph combine women_coef women_share,graphregion(color(none)) rows(2) imargin(0 0) graphregion(margin(l=22 r=22)) name(women,replace)		
		
  ///////
  //men//
  ///////
  
forvalues i = 0(100)5000 {
  cap drop y`i'
  gen y`i' = ingtrmen>`i'
  qui sum y`i' if sex==1
  replace sh = r(mean) if x==`i'
  reghdfe y`i' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  replace b_fe = _b[prop9799_post] if x==`i'
  replace lb_fe = _b[prop9799_post]-1.96*_se[prop9799_post] if x==`i'
  replace ub_fe = _b[prop9799_post]+1.96*_se[prop9799_post] if x==`i'
  }

twoway (rarea lb_fe ub_fe x,color(turquoise%20)) ///
	   (line b_fe x,lcolor(turquoise) lwidth(thick)) ///
       ,subtitle("Men") name(men_coef,replace) graphregion(margin(zero) color(none)) ///
	    legend(off) ///
	    xtitle("") xlabel(,noticks nolabels grid gstyle(dot)) ///
	    ytitle("Effect on probability of exceeding threshold") yline(0,lcolor(black)) ///
		ylabel(-.2(.1).2,grid gstyle(dot))

twoway area sh x,color(dknavy%50) ///
        name(men_share,replace) graphregion(margin(zero) color(none)) fysize(25) ///
	    xtitle("Labor income threshold") xlabel(,grid gstyle(dot)) ///
	    ytitle("Share exceeding threshold") yscale(reverse) ylabel(0(.1).7,grid gstyle(dot))

graph combine men_coef men_share,graphregion(color(none)) rows(2) imargin(0 0) graphregion(margin(l=22 r=22)) name(men,replace)		

*combine
graph combine men women,imargin(0 0) saving("$Results/figures/AFig8_threshold1990.gph",replace) rows(1)
