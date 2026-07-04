clear
set more off

use "$data/01_dataprep/fams_fase_20134xloc_f.dta"
egen benef1997=rowtotal(FASE_1-FASE_2)
egen benef1998=rowtotal(FASE_3-FASE_5)
egen benef1999=rowtotal(FASE_7-FASE_10)
egen benef2000=rowtotal(FASE_11-FASE_12)
egen benef2001=rowtotal(FASE_13-FASE_15)
egen benef2002=rowtotal(FASE_16-FASE_17)
egen benef2003=rowtotal(FASE_18-FASE_19)
egen benef2004=rowtotal(FASE_20-FASE_23)
egen benef2005=rowtotal(FASE_24-FASE_25)
egen benef2006=rowtotal(FASE_26-FASE_28)
egen benef2007=rowtotal(FASE_29-FASE_32)
egen benef2008=rowtotal(FASE_33-FASE_35)
egen benef2009=rowtotal(FASE_38-FASE_39)
egen benef2010=rowtotal(FASE_40-FASE_42)
egen benef2011=rowtotal(FASE_44-FASE_47)
egen benef2012=rowtotal(FASE_48-FASE_50)

keep benef*
collapse (sum) benef*
gen i = 1
reshape long benef,i(i) j(year)
drop i

replace benef = benef/1000

twoway (connected benef year,lcolor(black) mcolor(black) msymbol(O)) ///
       (pci 800 1997 800 2000.5,lcolor(black)) ///
	   (pci 800 2000.6 800 2006.5,lcolor(black)) ///
	   (pci 800 2006.6 800 2012,lcolor(black)) ///
       ,xtitle("Year") ytitle("Households enrolled (in 1000s)") ///
	    xlabel(1997(3)2012) legend(off) ///
		text(800 1998.75 "Zedillo",placement(s) size(small)) ///
		text(800 2003.55 "Fox",placement(s) size(small)) ///
		text(800 2009.3 "Calderón",placement(s) size(small)) ///
        saving("$Results/figures/Fig1_time_series.gph",replace)
	


