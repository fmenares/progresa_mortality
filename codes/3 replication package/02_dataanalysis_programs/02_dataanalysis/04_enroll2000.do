
*appendix figure on school enrollment by age and sex in 2000*

use "$tempdata/mex_2000_ipums.dta" if marginado==1&some_sec<.&some_prep<.&some_college<.,clear
gen in_pri = (school==1&some_sec==0&some_prep==0&some_college==0)
gen in_sec = (school==1&some_sec==1&some_prep==0)
gen in_prep = (school==1&some_prep==1&some_college==0)
gen in_college = (school==1&some_college==1)
collapse in_pri in_sec in_prep in_college school [aw=perwt],by(sex agebin)
recode in_pri in_sec in_prep in_college (0=.)
gen x = agebin*10
//boys//
twoway (connected in_college x if sex==1,color(dknavy) msymbol(Th) lwidth(medthick) lpattern(solid)) ///
	   (line school x if sex==1,color(dknavy) lwidth(thick) lpattern(solid)) ///
	   (connected in_pri x if sex==1,color(orange_red*.5) msymbol(Oh) lwidth(medthick) lpattern(solid)) ///
       (connected in_sec x if sex==1,color(cranberry*.9) msymbol(Dh) lwidth(medthick) lpattern(solid)) ///
       (connected in_prep x if sex==1,color(navy) msymbol(Sh) lwidth(medthick) lpattern(solid)) ///
	   ,name(boys,replace) subtitle("Boys") ///
	   ylabel(0(.2)1,grid gstyle(dot)) ///
	   ytitle("") xtitle("") ///
	   xlabel(75 "7-8" 100 "9-11" 125 "12-13" 150 "14-16" 175 "17-18" 200 "19-21" 225 "22-23" 250 "24-26" ///
	          ,angle(45) grid gstyle(dot)) ///
	   legend(off)
//girls//
twoway (connected in_college x if sex==2,color(dknavy) msymbol(Th) lwidth(medthick) lpattern(solid)) ///
	   (line school x if sex==2,color(dknavy) lwidth(thick) lpattern(solid)) ///
	   (connected in_pri x if sex==2,color(orange_red*.5) msymbol(Oh) lwidth(medthick) lpattern(solid)) ///
       (connected in_sec x if sex==2,color(cranberry*.9) msymbol(Dh) lwidth(medthick) lpattern(solid)) ///
       (connected in_prep x if sex==2,color(navy) msymbol(Sh) lwidth(medthick) lpattern(solid)) ///
	   ,name(girls,replace) subtitle("Girls") ///
	   ylabel(0 " " .2 " " .4 " " .6 " " .8 " " 1 " ",grid gstyle(dot) tlcolor(none)) ///
	   ytitle("") xtitle("") ///
	   xlabel(75 "7-8" 100 "9-11" 125 "12-13" 150 "14-16" 175 "17-18" 200 "19-21" 225 "22-23" 250 "24-26" ///
	          ,angle(45) grid gstyle(dot)) ///
	   legend(order(3 "Primary" 4 "Middle" 5 "High" 1 "University" 2 "Any level") ///
			  rows(5) symxsize(*.75) region(style(none) margin(zero)) ring(0) pos(2))
//combine//
graph combine boys girls ///
      ,l1("Fraction attending",size(small)) b1("Age in 2000",size(small)) ///
	   imargin(0 0 0 0) saving("$Results/figures/AFig4_school_enrollment_age_2000.gph",replace)	  
