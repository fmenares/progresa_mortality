********************************
**Set up census IPUMS dataset
********************************

set more off

clear
quietly infix             ///
  double  serial   1-10   ///
  int     pernum   11-13  ///
  double  perwt    14-21  ///
  int     momloc   22-24  ///
  byte    stepmom  25-25  ///
  int     age      26-28  ///
  int     age_mom  29-31  ///
  using "$data/01_dataprep/ipumsi_00034.dat"

replace perwt   = perwt   / 100

format serial  %10.0f
format perwt   %8.2f

label var serial  `"Household serial number"'
label var pernum  `"Person number"'
label var perwt   `"Person weight"'
label var momloc  `"Mother's location in household"'
label var stepmom `"Probable stepmother"'
label var age     `"Age"'
label var age_mom `"Age [of mother]"'

label define stepmom_lbl 0 `"Biological mother or no mother present"'
label define stepmom_lbl 1 `"Mother has no children borne or surviving"', add
label define stepmom_lbl 2 `"Child reports mother is deceased"', add
label define stepmom_lbl 3 `"Explicitly identified step relationship"', add
label define stepmom_lbl 4 `"Mother reports no children in the home"', add
label define stepmom_lbl 5 `"Age difference implausible"', add
label define stepmom_lbl 6 `"Child exceeds known fertility of mother"', add
label values stepmom stepmom_lbl

label define age_lbl 000 `"Less than 1 year"'
label define age_lbl 001 `"1 year"', add
label define age_lbl 002 `"2 years"', add
label define age_lbl 003 `"3"', add
label define age_lbl 004 `"4"', add
label define age_lbl 005 `"5"', add
label define age_lbl 006 `"6"', add
label define age_lbl 007 `"7"', add
label define age_lbl 008 `"8"', add
label define age_lbl 009 `"9"', add
label define age_lbl 010 `"10"', add
label define age_lbl 011 `"11"', add
label define age_lbl 012 `"12"', add
label define age_lbl 013 `"13"', add
label define age_lbl 014 `"14"', add
label define age_lbl 015 `"15"', add
label define age_lbl 016 `"16"', add
label define age_lbl 017 `"17"', add
label define age_lbl 018 `"18"', add
label define age_lbl 019 `"19"', add
label define age_lbl 020 `"20"', add
label define age_lbl 021 `"21"', add
label define age_lbl 022 `"22"', add
label define age_lbl 023 `"23"', add
label define age_lbl 024 `"24"', add
label define age_lbl 025 `"25"', add
label define age_lbl 026 `"26"', add
label define age_lbl 027 `"27"', add
label define age_lbl 028 `"28"', add
label define age_lbl 029 `"29"', add
label define age_lbl 030 `"30"', add
label define age_lbl 031 `"31"', add
label define age_lbl 032 `"32"', add
label define age_lbl 033 `"33"', add
label define age_lbl 034 `"34"', add
label define age_lbl 035 `"35"', add
label define age_lbl 036 `"36"', add
label define age_lbl 037 `"37"', add
label define age_lbl 038 `"38"', add
label define age_lbl 039 `"39"', add
label define age_lbl 040 `"40"', add
label define age_lbl 041 `"41"', add
label define age_lbl 042 `"42"', add
label define age_lbl 043 `"43"', add
label define age_lbl 044 `"44"', add
label define age_lbl 045 `"45"', add
label define age_lbl 046 `"46"', add
label define age_lbl 047 `"47"', add
label define age_lbl 048 `"48"', add
label define age_lbl 049 `"49"', add
label define age_lbl 050 `"50"', add
label define age_lbl 051 `"51"', add
label define age_lbl 052 `"52"', add
label define age_lbl 053 `"53"', add
label define age_lbl 054 `"54"', add
label define age_lbl 055 `"55"', add
label define age_lbl 056 `"56"', add
label define age_lbl 057 `"57"', add
label define age_lbl 058 `"58"', add
label define age_lbl 059 `"59"', add
label define age_lbl 060 `"60"', add
label define age_lbl 061 `"61"', add
label define age_lbl 062 `"62"', add
label define age_lbl 063 `"63"', add
label define age_lbl 064 `"64"', add
label define age_lbl 065 `"65"', add
label define age_lbl 066 `"66"', add
label define age_lbl 067 `"67"', add
label define age_lbl 068 `"68"', add
label define age_lbl 069 `"69"', add
label define age_lbl 070 `"70"', add
label define age_lbl 071 `"71"', add
label define age_lbl 072 `"72"', add
label define age_lbl 073 `"73"', add
label define age_lbl 074 `"74"', add
label define age_lbl 075 `"75"', add
label define age_lbl 076 `"76"', add
label define age_lbl 077 `"77"', add
label define age_lbl 078 `"78"', add
label define age_lbl 079 `"79"', add
label define age_lbl 080 `"80"', add
label define age_lbl 081 `"81"', add
label define age_lbl 082 `"82"', add
label define age_lbl 083 `"83"', add
label define age_lbl 084 `"84"', add
label define age_lbl 085 `"85"', add
label define age_lbl 086 `"86"', add
label define age_lbl 087 `"87"', add
label define age_lbl 088 `"88"', add
label define age_lbl 089 `"89"', add
label define age_lbl 090 `"90"', add
label define age_lbl 091 `"91"', add
label define age_lbl 092 `"92"', add
label define age_lbl 093 `"93"', add
label define age_lbl 094 `"94"', add
label define age_lbl 095 `"95"', add
label define age_lbl 096 `"96"', add
label define age_lbl 097 `"97"', add
label define age_lbl 098 `"98"', add
label define age_lbl 099 `"99"', add
label define age_lbl 100 `"100+"', add
label define age_lbl 999 `"Not reported/missing"', add
label values age age_lbl

label define age_mom_lbl 000 `"Less than 1 year"'
label define age_mom_lbl 001 `"1 year"', add
label define age_mom_lbl 002 `"2 years"', add
label define age_mom_lbl 003 `"3"', add
label define age_mom_lbl 004 `"4"', add
label define age_mom_lbl 005 `"5"', add
label define age_mom_lbl 006 `"6"', add
label define age_mom_lbl 007 `"7"', add
label define age_mom_lbl 008 `"8"', add
label define age_mom_lbl 009 `"9"', add
label define age_mom_lbl 010 `"10"', add
label define age_mom_lbl 011 `"11"', add
label define age_mom_lbl 012 `"12"', add
label define age_mom_lbl 013 `"13"', add
label define age_mom_lbl 014 `"14"', add
label define age_mom_lbl 015 `"15"', add
label define age_mom_lbl 016 `"16"', add
label define age_mom_lbl 017 `"17"', add
label define age_mom_lbl 018 `"18"', add
label define age_mom_lbl 019 `"19"', add
label define age_mom_lbl 020 `"20"', add
label define age_mom_lbl 021 `"21"', add
label define age_mom_lbl 022 `"22"', add
label define age_mom_lbl 023 `"23"', add
label define age_mom_lbl 024 `"24"', add
label define age_mom_lbl 025 `"25"', add
label define age_mom_lbl 026 `"26"', add
label define age_mom_lbl 027 `"27"', add
label define age_mom_lbl 028 `"28"', add
label define age_mom_lbl 029 `"29"', add
label define age_mom_lbl 030 `"30"', add
label define age_mom_lbl 031 `"31"', add
label define age_mom_lbl 032 `"32"', add
label define age_mom_lbl 033 `"33"', add
label define age_mom_lbl 034 `"34"', add
label define age_mom_lbl 035 `"35"', add
label define age_mom_lbl 036 `"36"', add
label define age_mom_lbl 037 `"37"', add
label define age_mom_lbl 038 `"38"', add
label define age_mom_lbl 039 `"39"', add
label define age_mom_lbl 040 `"40"', add
label define age_mom_lbl 041 `"41"', add
label define age_mom_lbl 042 `"42"', add
label define age_mom_lbl 043 `"43"', add
label define age_mom_lbl 044 `"44"', add
label define age_mom_lbl 045 `"45"', add
label define age_mom_lbl 046 `"46"', add
label define age_mom_lbl 047 `"47"', add
label define age_mom_lbl 048 `"48"', add
label define age_mom_lbl 049 `"49"', add
label define age_mom_lbl 050 `"50"', add
label define age_mom_lbl 051 `"51"', add
label define age_mom_lbl 052 `"52"', add
label define age_mom_lbl 053 `"53"', add
label define age_mom_lbl 054 `"54"', add
label define age_mom_lbl 055 `"55"', add
label define age_mom_lbl 056 `"56"', add
label define age_mom_lbl 057 `"57"', add
label define age_mom_lbl 058 `"58"', add
label define age_mom_lbl 059 `"59"', add
label define age_mom_lbl 060 `"60"', add
label define age_mom_lbl 061 `"61"', add
label define age_mom_lbl 062 `"62"', add
label define age_mom_lbl 063 `"63"', add
label define age_mom_lbl 064 `"64"', add
label define age_mom_lbl 065 `"65"', add
label define age_mom_lbl 066 `"66"', add
label define age_mom_lbl 067 `"67"', add
label define age_mom_lbl 068 `"68"', add
label define age_mom_lbl 069 `"69"', add
label define age_mom_lbl 070 `"70"', add
label define age_mom_lbl 071 `"71"', add
label define age_mom_lbl 072 `"72"', add
label define age_mom_lbl 073 `"73"', add
label define age_mom_lbl 074 `"74"', add
label define age_mom_lbl 075 `"75"', add
label define age_mom_lbl 076 `"76"', add
label define age_mom_lbl 077 `"77"', add
label define age_mom_lbl 078 `"78"', add
label define age_mom_lbl 079 `"79"', add
label define age_mom_lbl 080 `"80"', add
label define age_mom_lbl 081 `"81"', add
label define age_mom_lbl 082 `"82"', add
label define age_mom_lbl 083 `"83"', add
label define age_mom_lbl 084 `"84"', add
label define age_mom_lbl 085 `"85"', add
label define age_mom_lbl 086 `"86"', add
label define age_mom_lbl 087 `"87"', add
label define age_mom_lbl 088 `"88"', add
label define age_mom_lbl 089 `"89"', add
label define age_mom_lbl 090 `"90"', add
label define age_mom_lbl 091 `"91"', add
label define age_mom_lbl 092 `"92"', add
label define age_mom_lbl 093 `"93"', add
label define age_mom_lbl 094 `"94"', add
label define age_mom_lbl 095 `"95"', add
label define age_mom_lbl 096 `"96"', add
label define age_mom_lbl 097 `"97"', add
label define age_mom_lbl 098 `"98"', add
label define age_mom_lbl 099 `"99"', add
label define age_mom_lbl 100 `"100+"', add
label define age_mom_lbl 999 `"Not reported/missing"', add
label values age_mom age_mom_lbl

//biological moms only
tab stepmom
replace momloc = 0 if stepmom>0
gen nomom = momloc==0
tab age nomom [aw=perwt],row nofreq

tab nomom if age<=15 [aw=perwt]

drop nomom
drop if momloc==0

//only moms in  sampleage range
tab age_mom
keep if age_mom>=22&age_mom<=33

//only kids born before mom was 20
gen age_at_birth = age_mom-age
tab age_at_birth

//generate binary var for counting kids before age 20, 22
gen kids_0_21 = (age_at_birth<=21)
gen kids_0_19 = (age_at_birth<=19)

//prep for merge
drop pernum
ren momloc pernum

//collapse for counts data
collapse (min) age_at_birth (sum) kids*,by(serial pernum)
label var age_at_birth "Age at first birth (fr coresident kids)"
label var kids_0_21 "Coresident kids born before 22"
label var kids_0_19 "Coresident kids born before 20" 
saveold "$tempdata/mex_2010_kids_ipums.dta",replace version(12)
