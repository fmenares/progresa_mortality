
*global Tempdata "../Temp"
*global Results "../Results"

use "$tempdata/mex_2010_ipums.dta" if marginado==1 & age>=22&age<=33 /*age97 bins up 9-19*/,clear

//age in 1997
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

*for diff in diff regression 

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

//////////////////////
//summary statistics//
//for the regression//
//sample (~14-15 yo)//
//////////////////////
preserve
keep if prop9799_hog<.&age97!=14
tab sex
estpost tabstat prop9799_hog prop9705_hog ///
                years some_* ///
                trabajo wage sector_agric ingtrmen ///
				housing_std durable_std inc_pc_hh ///
				mig5* urbanres [aw=perwt] ///
				,listwise statistics(mean sd) columns(statistics) by(sex)
codebook MUN_PRE if sex==1	
codebook MUN_PRE if sex==2			
restore				

//////////////////////
//event study graphs//
//////////////////////

**setup
gen a = .
foreach a in 9 12 14 17 19 {
  replace a = `a' if _n==`a'
  }
recode a (9=95) (12=120) (14=145) (17=170) (19=195) ///
		 ,gen(a_plot_men) //for plotting: midpoints of intervals, multiply by 10 to maintain integer values
label define a_plot_men 95 "9-10" 120 "11-13" 145 "14-15" 170 "16-18" 195 "19-20" /*vals for men*/ ///
                        220 "9-10" 245 "11-13" 270 "14-15" 295 "16-18" 320 "19-20" /*vals for women*/
label values a_plot_men a_plot_men	
recode a (9=220) (12=245) (14=270) (17=295) (19=320) ///
		 ,gen(a_plot_women) //for plotting to the right of the estimates for men
gen coef_men = 0 if a==17
gen lb_men = .
gen ub_men = .
gen coef_women = 0 if a==17
gen lb_women = .
gen ub_women = .

**1 education 
***level -- all same axis scales
//relabel variables
label var years "Grades completed"
label var some_sec "At least some middle"
label var some_prep "At least some high"
label var some_college "At least some university"
foreach var of varlist some_sec some_prep some_college {
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_men = _b[prop9799_age`i'] if a==`i'
    cap replace lb_men = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_men = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'  
  }
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_women = _b[prop9799_age`i'] if a==`i'
    cap replace lb_women = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_women = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
  }	
  twoway (rcap lb_men ub_men a_plot_men,lcolor(dknavy) lwidth(thick)) ///
	     (connected coef_men a_plot_men,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
		 (rcap lb_women ub_women a_plot_women,lcolor(orange_red) lwidth(thick)) ///
	     (connected coef_women a_plot_women,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
		 ,legend(off) yline(0,lcolor(black)) ///
		  ylabel(-.2(.2).4, grid gstyle(dot)) yscale(range(-.2 .42)) ///
		  xlabel(95(25)320,valuelabel angle(45) grid gstyle(dot)) ///
		  ytitle("") xtitle("") ///
		  subtitle("`: variable label `var''") ///
		  text(.42 145 "Men",size(medium) color(dknavy)) ///
	      text(.42 270 "Women",size(medium) color(orange_red)) ///
	      name(`var',replace)
}
***years -- different axis scale
foreach var of varlist years {
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_men = _b[prop9799_age`i'] if a==`i'
    cap replace lb_men = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_men = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'  
  }
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_women = _b[prop9799_age`i'] if a==`i'
    cap replace lb_women = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_women = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
  }	
  twoway (rcap lb_men ub_men a_plot_men,lcolor(dknavy) lwidth(thick)) ///
	     (connected coef_men a_plot_men,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
		 (rcap lb_women ub_women a_plot_women,lcolor(orange_red) lwidth(thick)) ///
	     (connected coef_women a_plot_women,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
		 ,legend(off) yline(0,lcolor(black)) ///
		  ylabel(-1(1)3, grid gstyle(dot)) ///
		  xlabel(95(25)320,valuelabel angle(45) grid gstyle(dot)) ///
		  ytitle("") xtitle("") ///
		  subtitle("`: variable label `var''") ///
		  text(3 145 "Men",size(medium) color(dknavy)) ///
	      text(3 270 "Women",size(medium) color(orange_red)) ///
	      name(`var',replace)
}					
graph combine some_sec some_prep some_college,rows(1) name(bottom,replace) imargin(0 0 0 0) iscale(1)
graph combine years bottom,saving("$Results/figures/Fig5_educ.gph",replace) cols(1) imargin(0 0 0 0) ///
                        l1("Event study coefficient",size(small)) ///
						b1("Age in 1997",size(small))   													
**2 labor market
***binary
foreach var of varlist trabajo wage sector_agric  {
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_men = _b[prop9799_age`i'] if a==`i'
    cap replace lb_men = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_men = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'  
  }
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_women = _b[prop9799_age`i'] if a==`i'
    cap replace lb_women = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_women = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
  }	
  twoway (rcap lb_men ub_men a_plot_men,lcolor(dknavy) lwidth(thick)) ///
	     (connected coef_men a_plot_men,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
		 (rcap lb_women ub_women a_plot_women,lcolor(orange_red) lwidth(thick)) ///
	     (connected coef_women a_plot_women,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
		 ,legend(off) yline(0,lcolor(black)) ytitle("") ///
		  xlabel(95(25)320,valuelabel angle(45) grid gstyle(dot)) xtitle("") ///
		  ylabel(-.3(.15).3, grid gstyle(dot)) ///
		  subtitle("`: variable label `var''") ///
		  text(.3 145 "Men",size(medium) color(dknavy)) ///
	      text(.3 270 "Women",size(medium) color(orange_red)) ///
	      name(`var',replace)
}
***continuous: income
foreach var of varlist ingtrmen {
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_men = _b[prop9799_age`i'] if a==`i'
    cap replace lb_men = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_men = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'  
  }
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_women = _b[prop9799_age`i'] if a==`i'
    cap replace lb_women = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_women = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
  }	
  twoway (rcap lb_men ub_men a_plot_men,lcolor(dknavy) lwidth(thick)) ///
	     (connected coef_men a_plot_men,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
		 (rcap lb_women ub_women a_plot_women,lcolor(orange_red) lwidth(thick)) ///
	     (connected coef_women a_plot_women,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
		 ,legend(off) yline(0,lcolor(black)) ytitle("") xlabel(95(25)320,valuelabel angle(45) grid gstyle(dot)) xtitle("") ///
		  ylabel(-2000 "-2k" -1000 "-1k" 0 1000 "1k" 2000 "2k", grid gstyle(dot)) ///
		  subtitle("`: variable label `var''") ///
		  text(2000 145 "Men",size(medium) color(dknavy)) ///
	      text(2000 270 "Women",size(medium) color(orange_red)) ///
	      name(`var',replace)
}
graph combine trabajo wage sector_agric ingtrmen ///
                         ,saving("$Results/figures/Fig6_labor.gph",replace) cols(2) imargin(0 0 0 0) ///
                          l1("Event study coefficient",size(small)) ///
						  b1("Age in 1997",size(small))   
						  
**3: household
***continuous: standardized indices
foreach var of varlist housing_std durable_std {
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_men = _b[prop9799_age`i'] if a==`i'
    cap replace lb_men = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_men = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'  
  }
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_women = _b[prop9799_age`i'] if a==`i'
    cap replace lb_women = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_women = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
  }	
  twoway (rcap lb_men ub_men a_plot_men,lcolor(dknavy) lwidth(thick)) ///
	     (connected coef_men a_plot_men,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
		 (rcap lb_women ub_women a_plot_women,lcolor(orange_red) lwidth(thick)) ///
	     (connected coef_women a_plot_women,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
		 ,legend(off) yline(0,lcolor(black)) ytitle("") ///
		  xlabel(95(25)320,valuelabel angle(45) grid gstyle(dot)) xtitle("") ///
		  ylabel(-.6(.2).6, grid gstyle(dot) gmax) ///
		  subtitle("`: variable label `var''") ///
		  text(.6 145 "Men",size(medium) color(dknavy)) ///
	      text(.6 270 "Women",size(medium) color(orange_red)) ///
	      name(`var',replace)
}
***continuous: income per capita
foreach var of varlist inc_pc_hh {
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_men = _b[prop9799_age`i'] if a==`i'
    cap replace lb_men = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_men = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'  
  }
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_women = _b[prop9799_age`i'] if a==`i'
    cap replace lb_women = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_women = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
  }	
  twoway (rcap lb_men ub_men a_plot_men,lcolor(dknavy) lwidth(thick)) ///
	     (connected coef_men a_plot_men,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
		 (rcap lb_women ub_women a_plot_women,lcolor(orange_red) lwidth(thick)) ///
	     (connected coef_women a_plot_women,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
		 ,legend(off) yline(0,lcolor(black)) ytitle("") ///
		  xlabel(95(25)320,valuelabel angle(45) grid gstyle(dot)) xtitle("") ///
		  ylabel(-1000(500)1000, grid gstyle(dot)) yscale(range(-1050 1050)) ///
		  subtitle("`: variable label `var''") ///
		  text(1050 145 "Men",size(medium) color(dknavy)) ///
	      text(1050 270 "Women",size(medium) color(orange_red)) ///
	      name(`var',replace)
}
graph combine housing_std durable_std inc_pc_hh ///
                         ,saving("$Results/figures/Fig8_household.gph",replace) rows(1) imargin(0 0 0 0) ///
                          l1("Event study coefficient",size(small)) ///
						  b1("Age in 1997",size(small))
						  
**4: migration
label var mig5muni "Cross-municipal migration"
label var mig5edo "Cross-state migration"
label var mig5intra "Intra-state, cross-municipal migration"
label var urbanres "urbanres residence"
foreach var of varlist mig5* urbanres {
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_men = _b[prop9799_age`i'] if a==`i'
    cap replace lb_men = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_men = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'  
  }
  reghdfe `var' prop9799_age* prop9705_age* [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  foreach i in 9 12 14 19 {
    cap replace coef_women = _b[prop9799_age`i'] if a==`i'
    cap replace lb_women = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
    cap replace ub_women = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
  }	
  twoway (rcap lb_men ub_men a_plot_men,lcolor(dknavy) lwidth(thick)) ///
	     (connected coef_men a_plot_men,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
		 (rcap lb_women ub_women a_plot_women,lcolor(orange_red) lwidth(thick)) ///
	     (connected coef_women a_plot_women,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
		 ,legend(off) yline(0,lcolor(black)) ytitle("") xlabel(95(25)320,valuelabel angle(45) grid gstyle(dot)) xtitle("") ///
		  ylabel(-.3(.15).3, grid gstyle(dot) gmax) ///
		  subtitle("`: variable label `var''") ///
		  text(.3 145 "Men",size(medium) color(dknavy)) ///
	      text(.3 270 "Women",size(medium) color(orange_red)) ///
	      name(`var',replace)
}
graph combine mig5muni mig5edo mig5intra urbanres ///
                         ,saving("$Results/figures/Fig9_migration.gph",replace) cols(2) imargin(0 0 0 0) ///
                          l1("Event study coefficient",size(small)) ///
						  b1("Age in 1997",size(small))   						  
						   

///////////////
//regressions//	
///////////////					  

local i = 1
foreach var of varlist /*schooling*/ years some_sec some_prep some_college ///
                       /*labor*/ trabajo wage sector_agric ingtrmen ///
                       /*HH wellbeing*/ housing_std durable_std inc_pc_hh ///
					   /*migration*/ mig5* urbanres ///
					   /*HH/demographic*/ persons anyparent married /// 
					   /*spousal*/ years_sp age_sp trabajo_sp ingtrmen_sp {
					   
  ///////
  //men//
  ///////
  
  //baseline
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  local p = r(table)[4,1]
  if `i'==1 {
    outreg2 using "$Results/tables/men.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') replace 
	}
  else {
    outreg2 using "$Results/tables/men.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
	}
  //baseline + marginality percentile indicators * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
  local p = r(table)[4,1]
  outreg2 using "$Results/tables/men.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
  //baseline + marginality percentile indicators * cohort indicators + pop share in locality marginality percentile bins * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
  local p = r(table)[4,1]
  outreg2 using "$Results/tables/men.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
		 
  /////////
  //women//
  /////////
 
  //baseline
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  local p = r(table)[4,1]
  if `i'==1 {
    outreg2 using "$Results/tables/women.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') replace 
	}
  else {
    outreg2 using "$Results/tables/women.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
	}
  //baseline + marginality percentile indicators * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
  local p = r(table)[4,1]
  outreg2 using "$Results/tables/women.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
  //baseline + marginality percentile indicators * cohort indicators + pop share in locality marginality percentile bins * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
  local p = r(table)[4,1]
  outreg2 using "$Results/tables/women.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
		 
  local ++i
}

  //fertility for women only//
  
foreach var of varlist kids_0_19 kids_0_21 {
  //baseline
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  local p = r(table)[4,1]
  outreg2 using "$Results/tables/women.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
  //baseline + marginality percentile indicators * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
  local p = r(table)[4,1]
  outreg2 using "$Results/tables/women.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
  //baseline + marginality percentile indicators * cohort indicators + pop share in locality marginality percentile bins * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
  local p = r(table)[4,1]
  outreg2 using "$Results/tables/women.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes addstat(P-value, `p') append 
}

//for footnote in section 3.2: using 1990 population instead of 1997 estimate//
sum hog1990 hog1997
gen growth = hog1997/hog1990
sum growth
//women's years ed//
gen prop9799_post_alt = post*benef9799/hog1990
gen prop9705_post_alt = post*benef9705/hog1990
reghdfe years prop9799_post_alt prop9705_post_alt [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
reghdfe years prop9799_post_alt prop9705_post_alt [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
reghdfe years prop9799_post_alt prop9705_post_alt [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
//so the range of estimates shrinks from 1.03-1.57 to .85-1.31. % shrinkage:
di 1-1.31/1.57
di 1-1.13/1.37
di 1-.85/1.03
//women's secondary//
reghdfe some_sec prop9799_post_alt prop9705_post_alt [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
reghdfe some_sec prop9799_post_alt prop9705_post_alt [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
reghdfe some_sec prop9799_post_alt prop9705_post_alt [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
//so the range of estimates shrinks from 0.23-0.29 to 0.19-0.25. % shrinkage:
di 1-.24/.29
di 1-.25/.30
di 1-.19/.23

//for footnote in section 6.2: are the men's and women's secondary results sig diff? yes//
reghdfe some_sec i.sex#(c.prop9799_post c.prop9705_post) [pw=perwt],cluster(MUN_PRE) a(i.sex##i.MUN_PRE i.sex##i.age97)
lincom _b[2.sex#c.prop9799_post]-_b[1b.sex#c.prop9799_post]
reghdfe some_sec i.sex#(c.prop9799_post c.prop9705_post) [pw=perwt],cluster(MUN_PRE) a(i.sex##MUN_PRE i.sex##i.age97##i.margpct)
lincom _b[2.sex#c.prop9799_post]-_b[1b.sex#c.prop9799_post]
forvalues i=1/100 { //code up cohortXpercentile share interactions because it overloads reghdfe
  gen cht9_iml_pc`i' = (age97==9)*iml_pc`i'
  gen cht12_iml_pc`i' = (age97==12)*iml_pc`i'
  gen cht17_iml_pc`i' = (age97==17)*iml_pc`i'
  gen cht19_iml_pc`i' = (age97==19)*iml_pc`i'
  }
reghdfe some_sec i.sex#(c.prop9799_post c.prop9705_post) [pw=perwt],cluster(MUN_PRE) a(i.sex##MUN_PRE i.sex##i.age97#i.margpct i.sex##c.(cht*))
lincom _b[2.sex#c.prop9799_post]-_b[1b.sex#c.prop9799_post]

///////////////
//income     //	
//threshold  //	
//regressions//	
///////////////					  

gen x = (_n-1)*100 if _n<=51
gen b_fe = .
gen lb_fe = .
gen ub_fe = .
gen b_munimarg = .
gen lb_munimarg = .
gen ub_munimarg = .
gen b_locmarg = .
gen lb_locmarg = .
gen ub_locmarg = .
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
  reghdfe y`i' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
  replace b_munimarg = _b[prop9799_post] if x==`i'
  replace lb_munimarg = _b[prop9799_post]-1.96*_se[prop9799_post] if x==`i'
  replace ub_munimarg = _b[prop9799_post]+1.96*_se[prop9799_post] if x==`i'
  reghdfe y`i' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
  replace b_locmarg = _b[prop9799_post] if x==`i'
  replace lb_locmarg = _b[prop9799_post]-1.96*_se[prop9799_post] if x==`i'
  replace ub_locmarg = _b[prop9799_post]+1.96*_se[prop9799_post] if x==`i'
  }
  
twoway (rarea lb_locmarg ub_locmarg x,color(dknavy%20)) ///
	   (rarea lb_munimarg ub_munimarg x,color(orange_red%20)) ///
	   (rarea lb_fe ub_fe x,color(turquoise%20)) ///
	   (line b_locmarg x,lcolor(dknavy) lwidth(thick) lpattern(shortdash)) ///
       (line b_munimarg x,lcolor(orange_red) lwidth(thick) lpattern(longdash)) ///
       (line b_fe x,lcolor(turquoise) lwidth(thick)) ///
       ,subtitle("Women") name(women_coef,replace) graphregion(margin(zero) color(none)) ///
	    legend(order(6 "Baseline" 5 "+ percentile dummies" 4  "+ percentile shares")) ///
	    xtitle("") xlabel(,noticks nolabels grid gstyle(dot)) ///
	    ytitle("Effect", color(white)) yline(0,lcolor(black)) ///
		ylabel(-.2(.1).2,grid gstyle(dot))

twoway area sh x,color(dknavy%50) ///
        name(women_share,replace) graphregion(margin(zero) color(none)) fysize(25) ///
	    xtitle("Labor income threshold") xlabel(,grid gstyle(dot)) ///
	    ytitle("Share", color(white)) yscale(reverse range(0 0.55)) ///
		ylabel(0(.1).5,grid gstyle(dot))

grc1leg women_coef women_share,graphregion(color(none)) rows(2) imargin(0 0) graphregion(margin(l=22 r=22)) name(women,replace)		
		
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
  reghdfe y`i' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
  replace b_munimarg = _b[prop9799_post] if x==`i'
  replace lb_munimarg = _b[prop9799_post]-1.96*_se[prop9799_post] if x==`i'
  replace ub_munimarg = _b[prop9799_post]+1.96*_se[prop9799_post] if x==`i'
  reghdfe y`i' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
  replace b_locmarg = _b[prop9799_post] if x==`i'
  replace lb_locmarg = _b[prop9799_post]-1.96*_se[prop9799_post] if x==`i'
  replace ub_locmarg = _b[prop9799_post]+1.96*_se[prop9799_post] if x==`i'
  }

twoway (rarea lb_locmarg ub_locmarg x,color(dknavy%20)) ///
	   (rarea lb_munimarg ub_munimarg x,color(orange_red%20)) ///
	   (rarea lb_fe ub_fe x,color(turquoise%20)) ///
	   (line b_locmarg x,lcolor(dknavy) lwidth(thick) lpattern(shortdash)) ///
       (line b_munimarg x,lcolor(orange_red) lwidth(thick) lpattern(longdash)) ///
       (line b_fe x,lcolor(turquoise) lwidth(thick)) ///
       ,subtitle("Men") name(men_coef,replace) graphregion(margin(zero) color(none)) ///
	    legend(order(6 "Baseline" 5 "+ muni. marg. %-ile dummies" 4  "+ locality marg. %-ile shares") ///
	           bmargin(zero) size(vsmall) nobox rows(1)) ///
	    xtitle("") xlabel(,noticks nolabels grid gstyle(dot)) ///
	    ytitle("Effect on probability of exceeding threshold") yline(0,lcolor(black)) ///
		ylabel(-.2(.1).2,grid gstyle(dot))

twoway area sh x,color(dknavy%50) ///
        name(men_share,replace) graphregion(margin(zero) color(none)) fysize(25) ///
	    xtitle("Labor income threshold") xlabel(,grid gstyle(dot)) ///
	    ytitle("Share exceeding threshold") yscale(reverse range(0 0.55)) ///
		ylabel(0(.1).5,grid gstyle(dot))

grc1leg men_coef men_share,graphregion(color(none)) rows(2) imargin(0 0) graphregion(margin(l=22 r=22)) name(men,replace)		

*combine
grc1leg men women,imargin(0 0) saving("$Results/figures/Fig7_threshold.gph",replace) rows(1)


///////////////////////////
//Appendix figure://///////
//density of prop99////////
//conditional on prop05////
///////////////////////////
//individuals
reg prop9799_hog prop9705_hog [aw=perwt]
predict e,resid
kdensity e [aw=perwt],name(individuals,replace) n(1000) k(gaussian) lcolor(dknavy) lwidth(medthick) ///
                      normal normopts(lcolor(orange_red%50)) ///
                      title("") note("") subtitle("A. Individuals") ///
					  xtitle("e(enroll{sup:1999} | enroll{sup:2005})") ///
					  legend(rows(1) size(small))
drop e					  
//municipalities
preserve
bysort MUN_PRE: keep if _n==1
reg prop9799_hog prop9705_hog
predict e,resid
kdensity e [aw=perwt],name(munis,replace) n(1000) k(gaussian) lcolor(dknavy) lwidth(medthick) ///
                      normal normopts(lcolor(orange_red%50)) ///
                      title("") note("") subtitle("B. Municipalities") ///
					  xtitle("e(enroll{sup:1999} | enroll{sup:2005})")
restore
grc1leg individuals munis,rows(1) saving("$Results/figures/AFig5_treatdist.gph",replace) imargin(0 0)

///////////////////////////
//Appendix figure://///////
//Effects on distribution//
//of schooling years///////
///////////////////////////
gen y = _n if _n<=15
gen beta_1_base = .
gen beta_1_muni = .
gen beta_1_loc = .
gen beta_2_base = .
gen beta_2_muni = .
gen beta_2_loc = .
gen outcome = .
forvalues y=1/15 {
  forvalues sex=1/2 {
    replace outcome = years>=`y' if years<.
    reghdfe outcome prop9799_post prop9705_post [pw=perwt] if sex==`sex' ///
	       ,cluster(MUN_PRE) a(MUN_PRE age97)
    replace beta_`sex'_base = _b[prop9799_post] if y==`y'
    reghdfe outcome prop9799_post prop9705_post [pw=perwt] if sex==`sex' ///
	       ,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
    replace beta_`sex'_muni = _b[prop9799_post] if y==`y'
    reghdfe outcome prop9799_post prop9705_post [pw=perwt] if sex==`sex' ///
	       ,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
    replace beta_`sex'_loc = _b[prop9799_post] if y==`y'
  }
}
twoway (connected beta_1_base y,msymbol(O) color(dknavy*.33) lpattern(solid)) ///
       (connected beta_1_muni y,msymbol(D) color(dknavy) lpattern(solid)) ///
	   (connected beta_1_loc y,msymbol(S) color(dknavy*2) lpattern(solid)) ///
	   ,name(men,replace) subtitle("Men") ytitle("") xtitle("") ///
	    yline(0,lcolor(black)) ///
		ylabel(-.1(.1).3) ///
		xline(7 10,lpattern(dot) lcolor(black)) ///
		text(-.1 7 "Start" "middle" "school",place(ne) just(left)) ///  
		text(-.1 10 "Start" "high" "school",place(ne) just(left)) ///  
		legend(order(1 "Baseline" 2 "+ muni. %-ile" ///
		             3  "+ locality %-ile") ///
			   ring(0) position(10) rows(3) symxsize(*.5) region(color(none)))
twoway (connected beta_2_base y,msymbol(O) color(orange_red*.33) lpattern(solid)) ///
       (connected beta_2_muni y,msymbol(D) color(orange_red) lpattern(solid)) ///
	   (connected beta_2_loc y,msymbol(S) color(orange_red*2) lpattern(solid)) ///
	   ,name(women,replace) subtitle("Women") ytitle("") xtitle("") ///
	    yline(0,lcolor(black)) ///
		ylabel(-.1(.1).3) ///
		xline(7 10,lpattern(dot) lcolor(black)) ///
		text(-.1 7 "Start" "middle" "school",place(ne) just(left)) ///  
		text(-.1 10 "Start" "high" "school",place(ne) just(left)) ///  
		legend(order(1 "Baseline" 2 "+ muni. %-ile" ///
		             3  "+ locality %-ile") ///
			   ring(0) position(10) rows(3) symxsize(*.5) region(color(none)))
graph combine men women,saving("$Results/figures/AFig7_eddist.gph",replace) imargin(0 0 0 0)  ///
                        b1("     Grade",size(small)) ///
						l1("Effect on probability of completing grade",size(small))
						
////////////////////////////
//Appendix table: //////////
//program assignment based//
//on state of birth for/////
//migrants//////////////////
////////////////////////////


preserve
use "$tempdata/mex_2010_ipums.dta" if age>=22&age<=33 /*age97 bins up 9-19*/,clear
gen age97 = floor(agebin-13)
gen post = (age97<=12) if (age97>=9&age97<=12)|(age97>=17&age97<=19)
*how many out of state migrants are there, and how many of them are from high marginality states?
*answer: not many migrants from low marginality states.
gen mig_state = (edo_5years!=edo_born)
gen marginado_state = (prop_marg_state>=0.48)
tab mig_state marginado_state
*alt measure: state intensity for out of state migrants
replace prop9799_hog_state = prop9799_hog if edo_5years==edo_born //muni assignment for non-migrants
replace prop9799_hog_state = . if (marginado==0&mig_state==0) | ///
                                  (marginado_state==0&mig_state==1) //apply inclusion cutoff at state level
replace prop9705_hog_state = prop9705_hog if mig_state==0 
replace prop9705_hog_state = . if (marginado==0&mig_state==0) | ///
                                  (marginado_state==0&mig_state==1)
*original measure
replace prop9799_hog = . if marginado==0
replace prop9705_hog = . if marginado==0								
*multiply times post
foreach var of varlist prop*_hog* {
	gen `var'_p = `var'*post
}								
*clean outcomes
foreach var of varlist wage ingtrmen hortra sector_agric occ_white occ_skilled {
    replace `var' = 0 if trabajo==0 
	}
pca dirtfloor modernroof hassewage hasflush haspipe haselec [aw=perwt]
predict housing_pc1,score
sum housing_pc1 [aw=perwt]
gen housing_std = (housing_pc1-r(mean))/r(sd)
pca hascar hascell hascomp haswasher hasrefrig hastv hashotwater [aw=perwt]
predict durable_pc1,score
sum durable_pc1 [aw=perwt]
gen durable_std = (durable_pc1-r(mean))/r(sd)
centile ingtrmen,c(99.9) //trim top 0.1% from income
replace ingtrmen = . if ingtrmen>r(c_1)&ingtrmen<.

local i = 1
foreach var of varlist years some_sec trabajo wage ingtrmen ///
                       housing_std durable_std mig5muni urbanres {  
					   
  ///////
  //men//
  ///////
  
  //baseline
  reg `var' prop9799_hog_p prop9705_hog_p prop9799_hog prop9705_hog i.age97 ///
            [pw=perwt] if sex==1,cluster(CVE_EDO_PRE)  
  if `i'==1 {
    outreg2 using "$Results/tables/men_alt.out" ///
	       ,keep(prop9799_hog_p) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes replace 
  }
  else {
    outreg2 using "$Results/tables/men_alt.out" ///
	       ,keep(prop9799_hog_p) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
  } 
  //state avg
  reg `var' prop9799_hog_state_p prop9705_hog_state_p prop9799_hog_state prop9705_hog_state i.age97 ///
            [pw=perwt] if sex==1,cluster(CVE_EDO_PRE)
  outreg2 using "$Results/tables/men_alt.out" ///
	       ,keep(prop9799_hog_state_p) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
  
  /////////
  //women//
  /////////
 
  //baseline
  reg `var' prop9799_hog_p prop9705_hog_p prop9799_hog prop9705_hog i.age97 ///
            [pw=perwt] if sex==2,cluster(CVE_EDO_PRE)  
  if `i'==1 {
    outreg2 using "$Results/tables/women_alt.out" ///
	       ,keep(prop9799_hog_p) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes replace 
  }
  else {
    outreg2 using "$Results/tables/women_alt.out" ///
	       ,keep(prop9799_hog_p) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
  } 
  //state avg
  reg `var' prop9799_hog_state_p prop9705_hog_state_p prop9799_hog_state prop9705_hog_state i.age97 ///
            [pw=perwt] if sex==2,cluster(CVE_EDO_PRE)
  outreg2 using "$Results/tables/women_alt.out" ///
	       ,keep(prop9799_hog_state_p) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
  
  local ++i
}
restore

////////////////////////////
//Appendix table: //////////
//additional controls///////
////////////////////////////
  
gen d_secundaria_0005 = d_secundaria_9505-d_secundaria_9500
  
local i = 1
foreach var of varlist years some_sec trabajo wage ingtrmen ///
                       housing_std durable_std mig5muni urbanres {  
					   
  ///////
  //men//
  ///////
  
  //marginality components*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* d_analf-d_PL_5000))
  if `i'==1 {
    outreg2 using "$Results/tables/men_controls.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes replace 
	}
  else {
    outreg2 using "$Results/tables/men_controls.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
	}
	
  //pri94*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* pri94))
  outreg2 using "$Results/tables/men_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 

  //school construction*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* d_secundaria_9500 d_secundaria_0005))
  outreg2 using "$Results/tables/men_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 

  //violence*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* d_homicide))
  outreg2 using "$Results/tables/men_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 

  //cohort growth*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* g_pop))
  outreg2 using "$Results/tables/men_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
		 
  /////////
  //women//
  /////////
  
  //marginality components*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* d_analf-d_PL_5000))
  if `i'==1 {
    outreg2 using "$Results/tables/women_controls.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes replace 
	}
  else {
    outreg2 using "$Results/tables/women_controls.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
	}
	
  //pri94*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* pri94))
  outreg2 using "$Results/tables/women_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 

  //school construction*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* d_secundaria_9500 d_secundaria_0005))
  outreg2 using "$Results/tables/women_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 

  //violence*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* d_homicide))
  outreg2 using "$Results/tables/women_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append  
		 
  //cohort growth*cohort
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc* g_pop))
  outreg2 using "$Results/tables/women_controls.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
		 
  local ++i
}

//////////////////////////
//Appendix table://///////
//Outcome indices/////////
//////////////////////////

//keep only regression sample
preserve
keep if prop9799_hog<.&age97!=14

//generate outcome indices -- standardize separately by sex
cap program drop index
program define index
  //the first argument is the name of the index
  //the rest are the component variables
  
  //count the number of arguments
  local k = 1 
  while "``k''" != "" {
  	local ++k
  }
  local --k
  
  //mark the sample
  tempvar touse
  gen `touse' = 1
  forvalue i = 2/`k' {
  	qui replace `touse' = 0 if ``i'' ==.
  }
  
  //standardize the variables (within sex, using pre-policy mean/sd) and sum them in index
  cap drop `1'
  qui gen `1' = 0 if `touse'==1
  forvalue i = 2/`k' {
	cap drop ``i''_std 
	bysort sex: egen ``i''_std = std(``i'') if `touse'==1
	*qui sum ``i'' if `touse'==1&post==0&sex==1
	*qui gen ``i''_std = (``i''-r(mean))/r(sd) if `touse'==1&sex==1
	*qui sum ``i'' if `touse'==1&post==0&sex==2
	*qui replace ``i''_std = (``i''-r(mean))/r(sd) if `touse'==1&sex==2
	qui replace `1' = `1' + ``i''_std
  }
  
  //divide by number of component variables
  qui replace `1' = `1'/(`k'-1)
end


index educ_index years some_sec some_prep some_college
gen sector_nonagric = -sector_agric // so that positive is better
index labor_index trabajo wage sector_nonagric ingtrmen
index hh_index housing_std durable_std inc_pc_hh
index mobility_index mig5muni mig5edo mig5intra urbanres //should we remove mig5muni because it's redundant?

local i = 1
foreach var of varlist educ_index labor_index hh_index mobility_index {
					   
  ///////
  //men//
  ///////
  
  //baseline
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE age97)
  if `i'==1 {
    outreg2 using "$Results/tables/index.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes replace 
	}
  else {
    outreg2 using "$Results/tables/index.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
	}
  //baseline + marginality percentile indicators * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
  outreg2 using "$Results/tables/index.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
  //baseline + marginality percentile indicators * cohort indicators + pop share in locality marginality percentile bins * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==1,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
  outreg2 using "$Results/tables/index.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
		 
  /////////
  //women//
  /////////
 
  //baseline
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE age97)
  outreg2 using "$Results/tables/index.out" ///
	       ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
  //baseline + marginality percentile indicators * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97##i.margpct)
  outreg2 using "$Results/tables/index.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
  //baseline + marginality percentile indicators * cohort indicators + pop share in locality marginality percentile bins * cohort indicators
  reghdfe `var' prop9799_post prop9705_post [pw=perwt] if sex==2,cluster(MUN_PRE) a(MUN_PRE i.age97#i.margpct age97##c.(iml_pc*))
  outreg2 using "$Results/tables/index.out" ///
         ,keep(prop9799_post) se bracket bdec(3) tdec(3) aster(se) nocons nor2 nonotes append 
		 
  local ++i
}

restore
