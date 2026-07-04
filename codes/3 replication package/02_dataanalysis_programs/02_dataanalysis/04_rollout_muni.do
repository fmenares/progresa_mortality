*this program studies rollout patterns*

use "$tempdata/all_municipal_data_1990.dta",clear

d benef9799 benef9705 hog2000 marginado d_im ///
  d_analf d_ovsde d_ovsee d_ovsae d_ovpt d_PO2SM d_sprim d_vhac d_PL_5000

*gen hog1997 = .3*hog1990+.7*hog2000
keep if hog1997<.
gen prop9799=benef9799/hog1997
gen prop9705=benef9705/hog1997
gen prop0005=benef0005/hog1997

//rescale from 0-100 to 0-1
foreach var of varlist d_analf d_ovsde d_ovsee d_ovsae d_ovpt d_PO2SM d_sprim d_vhac d_PL_5000 {
  replace `var' = `var'/100
  }

  /*
//table 1
tab gm
table gm,statistic(mean prop9799) statistic(mean prop0005) statistic(mean prop9705) format(%9.2f)
table gm,statistic(mean d_analf) statistic(mean d_ovsde) statistic(mean d_ovsee) statistic(mean d_ovsae) statistic(mean d_ovpt) format(%9.2f)
table gm,statistic(mean d_PO2SM mean d_sprim mean d_vhac mean d_PL_5000) format(%9.2f)
table gm,statistic(mean muybajo mean bajo mean medio mean alto mean muyalto) format(%9.2f)
*/

bysort marginado: sum prop9799 prop9705 ///
                  d_analf d_PO2SM d_ovsde d_ovsee d_ovsae d_ovpt d_sprim d_vhac d_PL_5000 ///
                  muybajo bajo medio alto muyalto
codebook CVE_EDO_PRE if marginado==0		// ADDED _PRE IN REPLICATION FOR BOTH CODEBOOK COMMANDS//
codebook CVE_EDO_PRE if marginado==1			  	  

//Appendix Table 2//
//how much prop9799 variation is explained by prop9705, municipality %ile dummies, locality %ile shares?
*across all munis
qui reg prop9799 prop9705
di e(r2)
qui reg prop9799 i.margpct
di e(r2)
qui reg prop9799 iml_pc*
di e(r2)
qui reg prop9799 prop9705 i.margpct
di e(r2)
qui reg prop9799 prop9705 iml_pc*
di e(r2)
qui reg prop9799 prop9705 i.margpct iml_pc*
di e(r2)
*across marginado munis
qui reg prop9799 prop9705 if marginado==1
di e(r2)
qui reg prop9799 i.margpct if marginado==1
di e(r2)
qui reg prop9799 iml_pc* if marginado==1
di e(r2)
qui reg prop9799 prop9705 i.margpct if marginado==1
di e(r2)
qui reg prop9799 prop9705 iml_pc* if marginado==1
di e(r2)
qui reg prop9799 prop9705 i.margpct iml_pc* if marginado==1
di e(r2)

//graph: prop vs. ptile//
bysort margpct: egen prop9799_mean = mean(prop9799)
bysort margpct: egen prop0005_mean = mean(prop0005)
bysort margpct: gen plot = (_n==1) //plot only one point per bin
sort d_im
gen ptile = 100*(_n-1)/_N //continuous percentile (instead of 1pt bins)
twoway (scatter prop9799_mean margpct if plot==1,mcolor(dknavy*.5) msymbol(oh)) ///
       (scatter prop0005_mean margpct if plot==1,mcolor(orange_red*.33) msymbol(sh)) ///
	   (lpoly prop9799 ptile,degree(1) bw(2.5) lcolor(dknavy) lwidth(thick)) ///
       (lpoly prop0005 ptile,degree(1) bw(2.5) lcolor(orange_red) lpattern(dash) lwidth(thick)) ///
	   ,legend(off) aspect(1) xsize(4) xline(5 32 51 86,lstyle(dot)) ///
	    ytitle("Newly enrolled households / total households") ///
		xtitle("Municipality marginality pecentile") ylabel(0(.2).6) ///
		text(.41 85 "1997-9",color(dknavy) place(nw)) ///
		text(.17 31 "2000-5",color(orange_red) place(nw)) ///
		saving("$Results/figures/Fig3_muni_rollout_iml.gph",replace)
drop *_mean plot ptile
*collapse data to summarize differences for each percentile bin*	
preserve	
collapse prop9799 prop0005,by(margpct)
list
gen absdiff = abs(prop0005-prop9799)
gen absdiffgt10 = absdiff>.1
sum absdiff*,d
sum absdiff* if margpct>51,d
sum absdiff* if margpct<51,d
restore
		
//graph: gml prop vs. share//
*left*
gen x_bin = ceil(med_alt_muyalt*100)/100-.005
bysort x_bin: egen prop9799_mean = mean(prop9799)
bysort x_bin: egen prop0005_mean = mean(prop0005)
bysort x_bin: replace x_bin=. if _n>1
twoway (scatter prop9799_mean x_bin,mcolor(dknavy*.5) msymbol(oh)) ///
       (scatter prop0005_mean x_bin,mcolor(orange_red*.33) msymbol(sh)) ///
	   (lpoly prop9799 med_alt_muyalt,degree(1) bw(.025) lcolor(dknavy) lwidth(thick)) ///
       (lpoly prop0005 med_alt_muyalt,degree(1) bw(.025) lcolor(orange_red) lpattern(dash) lwidth(thick)) ///
	   ,legend(off) name(left,replace) fysize(50) ///
	    subtitle("A. Medium/high/very high") ///
		ylabel(0(.2).6,grid gstyle(dot)) ytitle("") ///
		xlabel(,grid gstyle(dot)) xtitle("Pop. share in M/H/VH localities") ///
		text(.09 .45 "1997-9",color(dknavy) place(se)) ///
		text(.2 .45 "2000-5",color(orange_red) place(nw))
drop x_bin *_mean		
*middle
gen x_bin = ceil(alt_muyalt*100)/100-.005
bysort x_bin: egen prop9799_mean = mean(prop9799)
bysort x_bin: egen prop0005_mean = mean(prop0005)
bysort x_bin: replace x_bin=. if _n>1
twoway (scatter prop9799_mean x_bin,mcolor(dknavy*.5) msymbol(oh)) ///
       (scatter prop0005_mean x_bin,mcolor(orange_red*.33) msymbol(sh)) ///
	   (lpoly prop9799 alt_muyalt,degree(1) bw(.025) lcolor(dknavy) lwidth(thick)) ///
       (lpoly prop0005 alt_muyalt,degree(1) bw(.025) lcolor(orange_red) lpattern(dash) lwidth(thick)) ///
	   ,legend(off) name(center,replace) fysize(50) ///
	    subtitle("B. High/very high") ///
		ylabel(0 " " .2 " " .4 " " .6 " ",grid tlcolor(none) gstyle(dot)) ytitle("") ///
		xlabel(,grid gstyle(dot)) xtitle("Pop. share in H/VH localities")
drop x_bin *_mean
*right	
gen x_bin = ceil(muyalto*100)/100-.005
bysort x_bin: egen prop9799_mean = mean(prop9799)
bysort x_bin: egen prop0005_mean = mean(prop0005)
bysort x_bin: replace x_bin=. if _n>1 //keep data for only one obs per bin
twoway (scatter prop9799_mean x_bin,mcolor(dknavy*.5) msymbol(oh)) ///
       (scatter prop0005_mean x_bin,mcolor(orange_red*.33) msymbol(sh)) ///
	   (lpoly prop9799 muyalto,degree(1) bw(.025) lcolor(dknavy) lwidth(thick)) ///
       (lpoly prop0005 muyalto,degree(1) bw(.025) lcolor(orange_red) lpattern(dash) lwidth(thick)) ///
	   ,legend(off) name(right,replace) fysize(50) ///
	    subtitle("C. Very high") ///
		ylabel(0 " " .2 " " .4 " " .6 " ",grid tlcolor(none) gstyle(dot)) ytitle("") ///
		xlabel(,grid gstyle(dot)) xtitle("Pop. share in VH localities")
drop x_bin *_mean		
*combine
graph combine left center right ///
     ,rows(1) imargin(0 0 0 0) ycommon ///
	  l1("      Newly enrolled HHs / total HHs",size(small)) ///
//	  saving("$Results/figures/muni_rollout_gml_shares.gph",replace)	  //this graph not in paper//
	  
//upper quantiles of iml_pc variables.
centile iml_pc*,c(90)	
centile iml_pc*,c(95)	      
	  
//graph: kernel density of percentile shares  
twoway (kdensity iml_pc10,bw(.01) lcolor(blue*.25) range(0 .05)) ///
       (kdensity iml_pc25,bw(.01) lcolor(blue*.5) range(0 .05)) ///
       (kdensity iml_pc50,bw(.01) lcolor(blue*.75) range(0 .05)) ///
       (kdensity iml_pc75,bw(.01) lcolor(blue) range(0 .05)) ///
       (kdensity iml_pc90,bw(.01) lcolor(blue*2) range(0 .05)) ///
	   ,legend(off) name(right,replace) ///
	    ylabel(,grid tlcolor(none) gstyle(dot)) ytitle("Density") ///
		xlabel(,grid gstyle(dot)) xtitle("Share of municipal population living in locality at {it:p{sup:th}} percentile of locality marginality distribution") ///
//		saving("$Results/figures/muni_rollout_ptile_density.gph",replace)  //this graph not in paper//
		
//heat plot
preserve
gen id = _n
keep prop9799 prop0005 iml_pc* id
reshape long iml_pc,i(id) j(percentile)
gen share = iml_pc if iml_pc<.05
expand 2,gen(late) //expand so that we can use one set of obs for 9799 and one set for 0005//
label define late 0 "1997-99" 1 "2000-05"
label values late late
gen Ratio = prop9799 if late==0
replace Ratio = prop0005 if late==1
heatplot Ratio percentile share ///
        ,ydiscrete xbwidth(.001) cuts(0(.05)1) hexagon ///
         by(late,compact note("")) color(plasma,reverse) ///
		 ramp(subtitle("Newly enrolled HHs / total HHs") lab(,labsize(small))) ///
		 ytitle("Locality marginality %-ile ({it:p})") ///
		 ylabel(0(25)100) ///
		 xtitle("Share of municipal population living in {it:p{sup:th}} %-ile") ///
		 xlabel(0(.01).05) saving("$Results/figures/Fig4_muni_rollout_heatmap.gph",replace)
		 /*xlabel(0 .01 .02 .03 .04 .05 ".05+") saving("$Results/figures/muni_rollout_heatmap.gph",replace)*/
restore		 
