*global Tempdata "../Temp"
*global Results "../Results"


//first look at age/sex patterns across marginality categories
use "$tempdata/mex_2010_ipums.dta" if age>=19&age<=51 /*age97 bins 7 to 37*/,clear
gen male = 2-sex
table agebin gm [pw=perwt],c(mean male)
collapse male [pw=perwt],by(gm agebin)
twoway (connected male agebin if gm==1) ///
       (connected male agebin if gm==2) ///
	   (connected male agebin if gm==3) ///
	   (connected male agebin if gm==4) ///
	   (connected male agebin if gm==5) ///
	   ,ytitle("Share male") xtitle("Age bin") scheme(plotplainblind) ///
	    legend(order(1 "Muy bajo" 2 "Bajo" 3 "Medio" 4 "Alto" 5 "Muy alto") ring(0) rows(5))

//age heaping graph
use "$tempdata/mex_2010_ipums.dta" if marginado==1 /*alto-muy alto*/ & age>=19&age<=51 /*age97 bins 7 to 37*/,clear
preserve
collapse years (count) pop=sex [fw=perwt],by(age)
sum pop
replace pop = 100*(pop/r(sum))
tempfile age_heaping
save `age_heaping',replace
restore
collapse years (count) pop=sex [fw=perwt],by(agebin)
sum pop
gen width = 3 if mod(agebin,5)==0 //3-year bins
replace width = 2 if mod(agebin,5)!=0 //2-year bins
replace pop = (100/width)*(pop/r(sum))
append using `age_heaping'
twoway (connected pop age,msymbol(Sh) color(orange_red*.5) lpattern(solid)) ///
       (connected pop agebin,msymbol(O) color(dknavy) lwidth(medthick) lpattern(solid)) ///
       ,xtitle("Age in 2010") xlabel(20(5)50,grid gstyle(dot)) xscale(range(19 51)) ///
        ytitle("Percent per year") ylabel(1(1)5,grid gstyle(dot)) ///
        legend(order(1 "Single-year bins" 2 "Multiple-year bins") ring(0) pos(1) ///
		       symxsize(*.75) rows(2) region(lstyle(none) fcolor(none))) ///
		saving("$Results/figures/AFig2_agebin.gph",replace)

twoway (connected years age,msymbol(Sh) color(orange_red*.5) lpattern(solid)) ///
       (connected years agebin,msymbol(O) color(dknavy) lwidth(medthick) lpattern(solid)) ///
       ,xtitle("Age in 2010") xlabel(20(5)50,grid gstyle(dot)) xscale(range(19 51)) ///
        ytitle("Average years of education in bin") ylabel(,grid gstyle(dot)) ///
        legend(order(1 "Single-year bins" 2 "Multiple-year bins") ring(0) pos(1) ///
		       symxsize(*.75) rows(2) region(lstyle(none) fcolor(none))) ///
		saving("$Results/figures/AFig3_agebin_educ.gph",replace)		

//statistics on school attendance -- 18 percent of 19-21 bin still in school! less than 10 percent of 22-23 bin.
use "$tempdata/mex_2010_ipums.dta" if marginado==1 /*alto-muy alto*/ & age>=19&age<=51 /*age97 bins 7 to 37*/,clear
table agebin sex [aw=perwt],c(mean school) format(%9.3f) col
//don't want to have the 19-21 bin, too many still in school. final sample 22-33.

//cohort size graph
*2010 using 2005 place of residence
use "$tempdata/mex_2010_ipums.dta" if marginado==1 & age>=22&age<=51,clear
gen age97 = floor(agebin-13)
gen male = 2-sex
collapse prop9799_hog prop9705_hog male (count) n=sex [pw=perwt],by(age97 MUN_PRE)
gen year = 2010
tempfile temp
save `temp'
*1990 using 1990 place of residence
use "$tempdata/mex_1990_ipums.dta" if marginado==1 & age>=2&age<=31,clear
gen age97 = floor(agebin+7)
gen male = 2-sex
collapse prop9799_hog prop9705_hog male (count) n=sex [pw=perwt],by(age97 MUN_PRE)
gen year = 1990
append using `temp'
*adjust cohort size for number of single-year cohorts in bin
replace n = n/3 if mod(age97,5)==2 //age97 ending in 7 and 2 are 3-year cohorts
replace n = n/2 if mod(age97,5)==4 //age97 ending in 4 and 9 are 2-year cohorts
gen lnn = ln(n)
*generate cohort * progresa interactions
foreach a97 in 9 12 14 /*omit 17*/ 19 22 24 27 29 32 34 37 {
  gen prop9799_age`a97' = prop9799_hog*(age97==`a97')
  label var prop9799_age`a97' "Program Intensity 97-99 * Cohort"
  gen prop9705_age`a97' = prop9705_hog*(age97==`a97')
  label var prop9705_age`a97' "Program Intensity 97-05 * Cohort"
  }
*set up cohort size event study
gen a = .
foreach a in 9 12 14 17 19 22 24 27 29 32 34 37 {
  replace a = `a' if _n==`a'
  }
recode a (9=95) (12=120) (14=145) (17=170) ///
         (19=195) (22=220) (24=245) (27=270) ///
		 (29=295) (32=320) (34=345) (37=370) /// 
		 ,gen(a_plot) //for plotting: midpoints of intervals, multiply by 10 to maintain integer values
*estimate log cohort size regressions					
gen coef1990 = 0 if a==17
gen lb1990 = .
gen ub1990 = .
reghdfe lnn prop9799_age* prop9705_age* if year==1990,cluster(MUN_PRE) a(MUN_PRE age97)
foreach i in 9 12 14 19 22 24 27 29 32 34 37 {
  cap replace coef1990 = _b[prop9799_age`i'] if a==`i'
  cap replace lb1990 = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
  cap replace ub1990 = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
}				
gen coef2010 = 0 if a==17
gen lb2010 = .
gen ub2010 = .
reghdfe lnn prop9799_age* prop9705_age* if year==2010,cluster(MUN_PRE) a(MUN_PRE age97)
foreach i in 9 12 14 19 22 24 27 29 32 34 37 {
  cap replace coef2010 = _b[prop9799_age`i'] if a==`i'
  cap replace lb2010 = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
  cap replace ub2010 = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
}
*draw log cohort size graph		
gen a_plot1 = a_plot+1
gen a_plot2 = a_plot-1	
twoway (connected coef1990 a_plot1,color(orange_red*.5) msymbol(Sh) lpattern(solid)) ///
	   (rcap lb1990 ub1990 a_plot1,lcolor(orange_red*.5)) ///
	   (connected coef2010 a_plot2,color(dknavy) msymbol(O) lpattern(solid)) ///
	   (rcap lb2010 ub2010 a_plot2,lcolor(dknavy)) ///
	   ,subtitle("Log cohort size") yline(0,lcolor(black)) ///
	    xlabel(95 "9-10" 120 "11-13" 145 "14-15" 170 "16-18" ///
               195 "19-20" 220 "21-23" 245 "24-25" 270 "26-28" ///
               295 "29-30" 320 "31-33" 345 "34-35" 370 "36-38" ,valuelabel angle(90) grid gstyle(dot)) ///
		ylabel(-.3(.3).6,grid gstyle(dot)) yscale(range(-.42 .71)) ///
		ytitle("") xtitle("") ///
		legend(off) name(lnn,replace)
*estimate sex ratio regressions					
reghdfe male prop9799_age* prop9705_age* if year==1990,cluster(MUN_PRE) a(MUN_PRE age97)
foreach i in 9 12 14 19 22 24 27 29 32 34 37 {
  cap replace coef1990 = _b[prop9799_age`i'] if a==`i'
  cap replace lb1990 = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
  cap replace ub1990 = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
}		
reghdfe male prop9799_age* prop9705_age* if year==2010,cluster(MUN_PRE) a(MUN_PRE age97)
foreach i in 9 12 14 19 22 24 27 29 32 34 37 {
  cap replace coef2010 = _b[prop9799_age`i'] if a==`i'
  cap replace lb2010 = _b[prop9799_age`i']-1.96*_se[prop9799_age`i'] if a==`i'
  cap replace ub2010 = _b[prop9799_age`i']+1.96*_se[prop9799_age`i'] if a==`i'
}
*draw sex ratio graph			
twoway (connected coef1990 a_plot1,color(orange_red*.5) msymbol(Sh) lpattern(solid)) ///
	   (rcap lb1990 ub1990 a_plot1,lcolor(orange_red*.5)) ///
	   (connected coef2010 a_plot2,color(dknavy) msymbol(O) lpattern(solid)) ///
	   (rcap lb2010 ub2010 a_plot2,lcolor(dknavy)) ///
	   ,subtitle("Sex ratio (M/F)") yline(0,lcolor(black))  ///
	    xlabel(95 "9-10" 120 "11-13" 145 "14-15" 170 "16-18" ///
               195 "19-20" 220 "21-23" 245 "24-25" 270 "26-28" ///
               295 "29-30" 320 "31-33" 345 "34-35" 370 "36-38" ,valuelabel angle(90) grid gstyle(dot)) ///
		ylabel(-.3 " " 0 " " .3 " " .6 " ",grid gstyle(dot) tlcolor(none)) yscale(range(-.42 .71)) ///
		ytitle("") xtitle("") ///
		legend(order(3 "2005" 1 "1990") rows(2) symxsize(*.75) ///
		       region(style(none) margin(zero)) ring(0) pos(2)) ///
	    name(ratio,replace)
		
graph combine lnn ratio ///
      ,l1("Event study coefficient",size(small)) b1("Age in 1997",size(small)) ///
      imargin(0 0 0 0) saving("$Results/figures/AFig6_cohortcomp.gph",replace)
