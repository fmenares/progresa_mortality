
clear
//set up municipality data with more years of program rollout//
use "$data/01_dataprep/fams_fase_20134xloc_f.dta"
sort CVE_EDO CVE_MUN CVE_LOC
egen benef97=rowtotal(FASE_1-FASE_2)
egen benef98=rowtotal(FASE_3-FASE_5)
egen benef99=rowtotal(FASE_7-FASE_10)
egen benef00=rowtotal(FASE_11-FASE_12)
egen benef01=rowtotal(FASE_13-FASE_15)
egen benef02=rowtotal(FASE_16-FASE_17)
egen benef03=rowtotal(FASE_18-FASE_19)
egen benef04=rowtotal(FASE_20-FASE_23)
egen benef05=rowtotal(FASE_24-FASE_25)
egen benef06=rowtotal(FASE_26-FASE_28)
egen benef07=rowtotal(FASE_29-FASE_32)
egen benef08=rowtotal(FASE_33-FASE_35)
egen benef09=rowtotal(FASE_38-FASE_39)
egen benef10=rowtotal(FASE_40-FASE_42)
egen benef11=rowtotal(FASE_44-FASE_47)

do "$programs/01_dataprep/master_munis.do"
collapse  (sum) benef97 (sum) benef98 (sum) benef99 (sum) benef00  (sum) benef01 (sum) benef02 (sum) benef03 (sum) benef04 (sum) benef05 (sum) benef06 (sum) benef07 (sum) benef08 (sum) benef09 (sum) benef10 (sum) benef11, by (CVE_EDO CVE_MUN)
gen benef9799=benef97+benef98+benef99
gen benef0005=benef00+benef01+benef02+benef03+benef04+benef05
gen benef9705=benef9799+benef0005
gen benef0611=benef06+benef06+benef07+benef08+benef09+benef10+benef11
gen benef9711=benef9705+benef0611
rename CVE_EDO CVE_EDO_PRE
rename CVE_MUN CVE_MUN_PRE
keep benef9799 benef0005 benef9705 benef0611 benef9711 CVE_EDO_PRE CVE_MUN_PRE
sort CVE_EDO_PRE CVE_MUN_PRE

merge 1:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/Censo_hogares_1990_2000.dta"
drop _merge
sort CVE_EDO_PRE CVE_MUN_PRE
save "$tempdata/municipal_map_data.dta", replace

//set up shapefile//
shp2dta using "$data/Shapefiles/geo2_mx2010", data("$data/Shapefiles/data_mx2010") coordinates("$data/Shapefiles/coord_mx2010") replace
use "$data/Shapefiles/data_mx2010",clear
gen CVE_EDO_PRE = real(substr(MUNI2010,1,2)) if length(MUNI2010)==5  /* REMOVE _PRE SO PROGRAM WILL RUN, REPLICATION*/
replace CVE_EDO_PRE = real(substr(MUNI2010,1,1)) if length(MUNI2010)==4
gen CVE_MUN_PRE = real(substr(MUNI2010,-3,3))
gen CVE_MUN=CVE_MUN_PRE  /* added this in replication*/
gen CVE_EDO=CVE_EDO_PRE  /* aded this in replication*/

do "$programs/01_dataprep/master_munis.do"

sort CVE_EDO_PRE CVE_MUN_PRE
merge m:1 CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/municipal_map_data.dta"
drop _merge

gen prop9799=benef9799/(.3*hog1990+.7*hog2000)	
replace prop9799 = 0 if prop9799==. /*fill in zeros (only munis with nonzero program penetration are counted in original dataset)*/	 
*note that there are a couple newly formed municipalities like Tulum that are still not quite right in the merge
spmap prop9799 using "$data/Shapefiles/coord_mx2010",id(_ID) clmethod(custom) clbreaks(0 0.1 .25 .5 .75 10) ///
                                  fcolor(Blues) osize(vvthin ..) ocolor(gs15 ..) ndocolor(none) ndfcolor(black) ///
                                  legend(order(2 3 4 5 6) rows(1) label(2 "<.1") label(3 ".1-.25") ///
								         label(4 ".25-.5") label(5 ".5-.75") label(6 ">.75") size(large))
graph export "$Results/figures/AFig1_map9799.png", as(png) replace								  
										 
					
gen prop0005=benef0005/(.3*hog1990+.7*hog2000)		
replace prop0005 = 0 if prop0005==. 
spmap prop0005 using "$data/Shapefiles/coord_mx2010",id(_ID) clmethod(custom) clbreaks(0 0.1 .25 .5 .75 10) ///
                                  fcolor(Blues) osize(vvthin ..) ocolor(gs15 ..) ndocolor(none) ///
                                  legend(order(2 3 4 5 6) rows(1) label(2 "<.1") label(3 ".1-.25") ///
								         label(4 ".25-.5") label(5 ".5-.75") label(6 ">.75") size(large))
graph export "$Results/figures/AFig1_map0005.png", as(png) replace								  

gen prop0611=benef0611/(.3*hog1990+.7*hog2000)		
replace prop0611 = 0 if prop0611==. 
*spmap prop0611 using "$data/Shapefiles/coord_mx2010",id(_ID) clmethod(custom) clbreaks(0 0.1 .25 .5 .75 10) ///
                                  fcolor(Blues) osize(vvthin ..) ocolor(gs15 ..) ndocolor(none) ///
                                  legend(order(2 3 4 5 6) rows(1) label(2 "<.1") label(3 ".1-.25") ///
								         label(4 ".25-.5") label(5 ".5-.75") label(6 ">.75") size(large))
*graph export "$Results/figures/map0611.png", as(png) replace			// this map we don't include in paper//					  
								
			
*cd "$Programs"	*

	


