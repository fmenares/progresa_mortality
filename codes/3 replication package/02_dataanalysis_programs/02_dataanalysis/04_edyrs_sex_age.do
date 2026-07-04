*average education by cohort and sex, 
*separately for individuals born in high to very high marg.
*states and individuals born in middle to very low marg.
*states. we use 2010 state level marginality classifications.

*note we already dropped people with unknown state of birth
*or born abroad in 03_mex_2010_ipums.do.
/*
global Tempdata "../Temp"
global Results "../Results"
*/
use marginado years some_sec age agebin sex edo_born perwt using "$tempdata/mex_2010_ipums.dta" if age>=22&age<=51 /*age97 bins 9.5 to 37*/,clear


gen marg = /*very high marg in 2010*/ ///
           (edo_born==7)| /*Chiapas*/ ///
           (edo_born==12)| /*Guerrero*/ ///
           (edo_born==20)| /*Oaxaca*/ ///
		   /*high marg in 2010*/ ///
           (edo_born==4)| /*Campeche*/ ///
           (edo_born==13)| /*Hidalgo*/ ///
           (edo_born==16)| /*Michoacan*/ ///
           (edo_born==21)| /*Puebla*/ ///
           (edo_born==24)| /*San Luis Potosi*/ ///
           (edo_born==27)| /*Tabasco*/ ///
           (edo_born==30)| /*Veracruz*/ ///
           (edo_born==31)| /*Yucatan*/ ///
		   /*other states that split off of the above states*/ ///
		   (edo_born==23) /*Quintana Roo was part of Yucatan before 1974*/
   
		   
label define marg 0 "Born in lower marginality state" ///	
                  1 "Born in higher marginality state"
label values marg marg				  				  

gen age97 = agebin-13	
		
collapse some_sec [aw=perwt],by(age97 sex marg)
twoway (connected some_sec age97 if sex==1&marg==1,color(dknavy) msymbol(O) lpattern(solid) lwidth(thick)) ///
       (connected some_sec age97 if sex==2&marg==1,color(orange_red) msymbol(S) lpattern(solid) lwidth(thick)) ///
	   (connected some_sec age97 if sex==1&marg==0,color(dknavy*.75) msymbol(Oh) lpattern(dash) lwidth(thick)) ///
       (connected some_sec age97 if sex==2&marg==0,color(orange_red*.75) msymbol(Sh) lpattern(dash) lwidth(thick)) ///
	   (pci .825 19.8 .825 28.55,color(black)) ///
	   (pci .625 19.8 .625 28.75,color(black)) ///
	   (pcarrowi .36 13.6 .36 10.4,color(black)) ///
	   ,ytitle("Fraction completing at least 7th grade") xtitle("Age in 1997") ///
        saving("$Results/figures/AFig9_edyrs_sex_age.gph",replace) ///	
	    ylabel(,grid gstyle(dot)) ///
	    xlabel(9.5 "9-10" 12 "11-13" 14.5 "14-15" 17 "16-18" ///
               19.5 "19-20" 22 "21-23" 24.5 "24-25" 27 "26-28" ///
               29.5 "29-30" 32 "31-33" 34.5 "34-35" 37 "36-38" ,valuelabel angle(90) grid gstyle(dot)) ///
	    legend(off) xline(14.5,lcolor(black)) ///
		text(.85 19.5 "Lower marginality states",color(black) placement(e)) ///
		text(.7 34.5 "Men",color(dknavy*.75) placement(e)) ///
		text(.62 34.5 "Women",color(orange_red*.75) placement(e)) ///
		text(.65 19.5 "Higher marginality states",color(black) placement(e)) ///
		text(.51 34.5 "Men",color(dknavy) placement(e)) ///
		text(.41 34.5 "Women",color(orange_red) placement(e)) ///
		text(.4 12 "Progresa",color(black) placement(s))  
		
table age97 sex marg,c(mean some_sec)		
*pre-progresa (16-18 in 1997): men .6515027 - women .5965677 = .054935 diff
*post-progresa (9-10 in 1997): men .7659613 - women .7540588 = .0119025 diff
*absolute convergence is .0430325
		
//how much of gender convergence in h/vh states can be attributed to progresa?
use "$tempdata/all_state_data_1990.dta",clear

/*if want to use marginality category in 2010*/
gen marg = /*very high marg in 2010*/ ///
           (edo_born==7)| /*Chiapas*/ ///
           (edo_born==12)| /*Guerrero*/ ///
           (edo_born==20)| /*Oaxaca*/ ///
		   /*high marg in 2010*/ ///
           (edo_born==4)| /*Campeche*/ ///
           (edo_born==13)| /*Hidalgo*/ ///
           (edo_born==16)| /*Michoacan*/ ///
           (edo_born==21)| /*Puebla*/ ///
           (edo_born==24)| /*San Luis Potosi*/ ///
           (edo_born==27)| /*Tabasco*/ ///
           (edo_born==30)| /*Veracruz*/ ///
           (edo_born==31)| /*Yucatan*/ ///
		   /*other states that split off of the above states*/ ///
		   (edo_born==23) /*Quintana Roo was part of Yucatan before 1974*/
	   
   
gen hog97 = .3*hog1990_state+.7*hog2000_state
gen prop9799_state = benef9799_state/hog97

bysort marg: sum prop9799_state	[aw=hog97]  

*multiply share of HHs receiving bens * m/f diff in program effects on sec schooling -- for now use cols 1&5 from Table 2
di .1530113*(.293-.156)
*.02096255 as a share of absolute convergence: .48713298
di .02096255/.0430325		
*if we use cols 3&7, with marginality controls, then share is: .33779283
di .1530113*(.225-.130) 
di .01453607/.0430325
*so 1/3-1/2 of this final chapter of gender convergence can be attributed to progresa.

