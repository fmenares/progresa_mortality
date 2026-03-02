clear
set more off
capture log close
set seed 1234


if c(username)=="FELIPEME" {

    global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global output  "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\70ymas\"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"

}

*pob gastos ingresos 
global db = "concen"

foreach b in $db {		
cap use  "${data}/ENIGH/1992/`b'.dta", clear
		decode FOLIO, g(FOLIO_s)
		cap decode CLAVE, g(CLAVE_s)
		cap decode UPM, g(UPM_s)
		cap decode EST_DIS, g(EST_DIS_s)
		drop FOLIO 
		cap drop CLAVE 
		cap drop EST_DIS
		cap drop UPM 
		ren FOLIO_s FOLIO
		cap ren CLAVE_s CLAVE
		cap ren EST_DIS_s EST_DIS
		cap ren UPM_s UPM
		save "$data/ENIGH/1992/`b'", replace
}

global db = "gastos eroga ingresos pob concen"
global years  = "1994 1996 1998 2000"


foreach year in $years {
	foreach b in $db {		
		cap use  "${data}/ENIGH/`year'/`b'.dta", clear
		decode FOLIO, g(FOLIO_s)
		cap decode CLAVE, g(CLAVE_s)
		cap decode NUM_REN, g(NUM_REN_s)	
		drop FOLIO 
		cap drop NUM_REN
		cap drop CLAVE 
		ren (FOLIO_s) (FOLIO)
		cap ren (CLAVE_s) (CLAVE)
		cap ren (NUM_REN_s) (NUM_REN)
		save "$data/ENIGH/`year'/`b'", replace
	}
}


