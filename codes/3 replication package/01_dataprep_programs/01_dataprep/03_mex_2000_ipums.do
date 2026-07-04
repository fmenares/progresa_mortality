
set more off

clear
quietly infix                      ///
  int     country         1-3      ///
  int     year            4-7      ///
  double  sample          8-16     ///
  double  serial          17-28    ///
  double  hhwt            29-36    ///
  byte    urban           37-37    ///
  int     geo1_mx2000     38-40    ///
  long    geo2_mx2000     41-46    ///
  int     pernum          47-50    ///
  double  perwt           51-58    ///
  int     age             59-61    ///
  byte    sex             62-62    ///
  byte    bplmx           63-64    ///
  byte    school          65-65    ///
  byte    yrschool        66-67    ///
  int     educmx          68-70    ///
  byte    empstat         71-71    ///
  int     empstatd        72-74    ///
  byte    occisco         75-76    ///
  int     indgen          77-79    ///
  byte    classwk         80-80    ///
  int     classwkd        81-83    ///
  int     hrswork1        84-86    ///
  byte    migrate5        87-88    ///
  int     mx2000a_resent  89-91    ///
  int     mx2000a_resmun  92-94    ///
  long    mx2000a_incwk   95-101   ///
  using "$data/01_dataprep/ipumsi_00049.dat"

replace hhwt           = hhwt           / 100
replace perwt          = perwt          / 100

format sample         %9.0f
format serial         %12.0f
format hhwt           %8.2f
format perwt          %8.2f

label var country        `"Country"'
label var year           `"Year"'
label var sample         `"IPUMS sample identifier"'
label var serial         `"Household serial number"'
label var hhwt           `"Household weight"'
label var urban          `"Urban-rural status"'
label var geo1_mx2000    `"Mexico, State 2000 [Level 1, GIS]"'
label var geo2_mx2000    `"Mexico, Municipality 2000 [Level 2, GIS]"'
label var pernum         `"Person number"'
label var perwt          `"Person weight"'
label var age            `"Age"'
label var sex            `"Sex"'
label var bplmx          `"State of birth, Mexico"'
label var school         `"School attendance"'
label var yrschool       `"Years of schooling"'
label var educmx         `"Educational attainment, Mexico"'
label var empstat        `"Activity status (employment status) [general version]"'
label var empstatd       `"Activity status (employment status) [detailed version]"'
label var occisco        `"Occupation, ISCO general"'
label var indgen         `"Industry, general recode"'
label var classwk        `"Status in employment (class of worker) [general version]"'
label var classwkd       `"Status in employment (class of worker) [detailed version]"'
label var hrswork1       `"Hours worked per week"'
label var migrate5       `"Migration status, 5 years"'
label var mx2000a_resent `"State or country of residence in 1995"'
label var mx2000a_resmun `"Municipality of residence in 1995"'
label var mx2000a_incwk  `"Monthly income from work"'

label define country_lbl 032 `"Argentina"'
label define country_lbl 051 `"Armenia"', add
label define country_lbl 040 `"Austria"', add
label define country_lbl 050 `"Bangladesh"', add
label define country_lbl 112 `"Belarus"', add
label define country_lbl 204 `"Benin"', add
label define country_lbl 068 `"Bolivia"', add
label define country_lbl 072 `"Botswana"', add
label define country_lbl 076 `"Brazil"', add
label define country_lbl 854 `"Burkina Faso"', add
label define country_lbl 116 `"Cambodia"', add
label define country_lbl 120 `"Cameroon"', add
label define country_lbl 124 `"Canada"', add
label define country_lbl 152 `"Chile"', add
label define country_lbl 156 `"China"', add
label define country_lbl 170 `"Colombia"', add
label define country_lbl 188 `"Costa Rica"', add
label define country_lbl 192 `"Cuba"', add
label define country_lbl 208 `"Denmark"', add
label define country_lbl 214 `"Dominican Republic"', add
label define country_lbl 218 `"Ecuador"', add
label define country_lbl 818 `"Egypt"', add
label define country_lbl 222 `"El Salvador"', add
label define country_lbl 231 `"Ethiopia"', add
label define country_lbl 242 `"Fiji"', add
label define country_lbl 250 `"France"', add
label define country_lbl 276 `"Germany"', add
label define country_lbl 288 `"Ghana"', add
label define country_lbl 300 `"Greece"', add
label define country_lbl 320 `"Guatemala"', add
label define country_lbl 324 `"Guinea"', add
label define country_lbl 332 `"Haiti"', add
label define country_lbl 340 `"Honduras"', add
label define country_lbl 348 `"Hungary"', add
label define country_lbl 352 `"Iceland"', add
label define country_lbl 356 `"India"', add
label define country_lbl 360 `"Indonesia"', add
label define country_lbl 364 `"Iran"', add
label define country_lbl 368 `"Iraq"', add
label define country_lbl 372 `"Ireland"', add
label define country_lbl 376 `"Israel"', add
label define country_lbl 380 `"Italy"', add
label define country_lbl 388 `"Jamaica"', add
label define country_lbl 400 `"Jordan"', add
label define country_lbl 404 `"Kenya"', add
label define country_lbl 417 `"Kyrgyz Republic"', add
label define country_lbl 418 `"Laos"', add
label define country_lbl 426 `"Lesotho"', add
label define country_lbl 430 `"Liberia"', add
label define country_lbl 454 `"Malawi"', add
label define country_lbl 458 `"Malaysia"', add
label define country_lbl 466 `"Mali"', add
label define country_lbl 484 `"Mexico"', add
label define country_lbl 496 `"Mongolia"', add
label define country_lbl 504 `"Morocco"', add
label define country_lbl 508 `"Mozambique"', add
label define country_lbl 524 `"Nepal"', add
label define country_lbl 528 `"Netherlands"', add
label define country_lbl 558 `"Nicaragua"', add
label define country_lbl 566 `"Nigeria"', add
label define country_lbl 578 `"Norway"', add
label define country_lbl 586 `"Pakistan"', add
label define country_lbl 275 `"Palestine"', add
label define country_lbl 591 `"Panama"', add
label define country_lbl 598 `"Papua New Guinea"', add
label define country_lbl 600 `"Paraguay"', add
label define country_lbl 604 `"Peru"', add
label define country_lbl 608 `"Philippines"', add
label define country_lbl 616 `"Poland"', add
label define country_lbl 620 `"Portugal"', add
label define country_lbl 630 `"Puerto Rico"', add
label define country_lbl 642 `"Romania"', add
label define country_lbl 643 `"Russia"', add
label define country_lbl 646 `"Rwanda"', add
label define country_lbl 662 `"Saint Lucia"', add
label define country_lbl 686 `"Senegal"', add
label define country_lbl 694 `"Sierra Leone"', add
label define country_lbl 705 `"Slovenia"', add
label define country_lbl 710 `"South Africa"', add
label define country_lbl 728 `"South Sudan"', add
label define country_lbl 724 `"Spain"', add
label define country_lbl 729 `"Sudan"', add
label define country_lbl 752 `"Sweden"', add
label define country_lbl 756 `"Switzerland"', add
label define country_lbl 834 `"Tanzania"', add
label define country_lbl 764 `"Thailand"', add
label define country_lbl 768 `"Togo"', add
label define country_lbl 780 `"Trinidad and Tobago"', add
label define country_lbl 792 `"Turkey"', add
label define country_lbl 800 `"Uganda"', add
label define country_lbl 804 `"Ukraine"', add
label define country_lbl 826 `"United Kingdom"', add
label define country_lbl 840 `"United States"', add
label define country_lbl 858 `"Uruguay"', add
label define country_lbl 862 `"Venezuela"', add
label define country_lbl 704 `"Vietnam"', add
label define country_lbl 894 `"Zambia"', add
label define country_lbl 716 `"Zimbabwe"', add
label values country country_lbl

label define year_lbl 1703 `"1703"'
label define year_lbl 1729 `"1729"', add
label define year_lbl 1787 `"1787"', add
label define year_lbl 1801 `"1801"', add
label define year_lbl 1819 `"1819"', add
label define year_lbl 1850 `"1850"', add
label define year_lbl 1851 `"1851"', add
label define year_lbl 1852 `"1852"', add
label define year_lbl 1860 `"1860"', add
label define year_lbl 1861 `"1861"', add
label define year_lbl 1865 `"1865"', add
label define year_lbl 1870 `"1870"', add
label define year_lbl 1871 `"1871"', add
label define year_lbl 1875 `"1875"', add
label define year_lbl 1880 `"1880"', add
label define year_lbl 1881 `"1881"', add
label define year_lbl 1890 `"1890"', add
label define year_lbl 1891 `"1891"', add
label define year_lbl 1900 `"1900"', add
label define year_lbl 1901 `"1901"', add
label define year_lbl 1910 `"1910"', add
label define year_lbl 1911 `"1911"', add
label define year_lbl 1960 `"1960"', add
label define year_lbl 1961 `"1961"', add
label define year_lbl 1962 `"1962"', add
label define year_lbl 1963 `"1963"', add
label define year_lbl 1964 `"1964"', add
label define year_lbl 1966 `"1966"', add
label define year_lbl 1968 `"1968"', add
label define year_lbl 1969 `"1969"', add
label define year_lbl 1970 `"1970"', add
label define year_lbl 1971 `"1971"', add
label define year_lbl 1972 `"1972"', add
label define year_lbl 1973 `"1973"', add
label define year_lbl 1974 `"1974"', add
label define year_lbl 1975 `"1975"', add
label define year_lbl 1976 `"1976"', add
label define year_lbl 1977 `"1977"', add
label define year_lbl 1978 `"1978"', add
label define year_lbl 1979 `"1979"', add
label define year_lbl 1980 `"1980"', add
label define year_lbl 1981 `"1981"', add
label define year_lbl 1982 `"1982"', add
label define year_lbl 1983 `"1983"', add
label define year_lbl 1984 `"1984"', add
label define year_lbl 1985 `"1985"', add
label define year_lbl 1986 `"1986"', add
label define year_lbl 1987 `"1987"', add
label define year_lbl 1989 `"1989"', add
label define year_lbl 1990 `"1990"', add
label define year_lbl 1991 `"1991"', add
label define year_lbl 1992 `"1992"', add
label define year_lbl 1993 `"1993"', add
label define year_lbl 1994 `"1994"', add
label define year_lbl 1995 `"1995"', add
label define year_lbl 1996 `"1996"', add
label define year_lbl 1997 `"1997"', add
label define year_lbl 1998 `"1998"', add
label define year_lbl 1999 `"1999"', add
label define year_lbl 2000 `"2000"', add
label define year_lbl 2001 `"2001"', add
label define year_lbl 2002 `"2002"', add
label define year_lbl 2003 `"2003"', add
label define year_lbl 2004 `"2004"', add
label define year_lbl 2005 `"2005"', add
label define year_lbl 2006 `"2006"', add
label define year_lbl 2007 `"2007"', add
label define year_lbl 2008 `"2008"', add
label define year_lbl 2009 `"2009"', add
label define year_lbl 2010 `"2010"', add
label define year_lbl 2011 `"2011"', add
label define year_lbl 2012 `"2012"', add
label define year_lbl 2013 `"2013"', add
label define year_lbl 2014 `"2014"', add
label define year_lbl 2015 `"2015"', add
label define year_lbl 2016 `"2016"', add
label define year_lbl 2017 `"2017"', add
label define year_lbl 2018 `"2018"', add
label values year year_lbl

label define sample_lbl 032197001 `"Argentina 1970"'
label define sample_lbl 032198001 `"Argentina 1980"', add
label define sample_lbl 032199101 `"Argentina 1991"', add
label define sample_lbl 032200101 `"Argentina 2001"', add
label define sample_lbl 032201001 `"Argentina 2010"', add
label define sample_lbl 051200101 `"Armenia 2001"', add
label define sample_lbl 051201101 `"Armenia 2011"', add
label define sample_lbl 040197101 `"Austria 1971"', add
label define sample_lbl 040198101 `"Austria 1981"', add
label define sample_lbl 040199101 `"Austria 1991"', add
label define sample_lbl 040200101 `"Austria 2001"', add
label define sample_lbl 040201101 `"Austria 2011"', add
label define sample_lbl 050199101 `"Bangladesh 1991"', add
label define sample_lbl 050200101 `"Bangladesh 2001"', add
label define sample_lbl 050201101 `"Bangladesh 2011"', add
label define sample_lbl 112199901 `"Belarus 1999"', add
label define sample_lbl 112200901 `"Belarus 2009"', add
label define sample_lbl 204197901 `"Benin 1979"', add
label define sample_lbl 204199201 `"Benin 1992"', add
label define sample_lbl 204200201 `"Benin 2002"', add
label define sample_lbl 204201301 `"Benin 2013"', add
label define sample_lbl 068197601 `"Bolivia 1976"', add
label define sample_lbl 068199201 `"Bolivia 1992"', add
label define sample_lbl 068200101 `"Bolivia 2001"', add
label define sample_lbl 072198101 `"Botswana 1981"', add
label define sample_lbl 072199101 `"Botswana 1991"', add
label define sample_lbl 072200101 `"Botswana 2001"', add
label define sample_lbl 072201101 `"Botswana 2011"', add
label define sample_lbl 076196001 `"Brazil 1960"', add
label define sample_lbl 076197001 `"Brazil 1970"', add
label define sample_lbl 076198001 `"Brazil 1980"', add
label define sample_lbl 076199101 `"Brazil 1991"', add
label define sample_lbl 076200001 `"Brazil 2000"', add
label define sample_lbl 076201001 `"Brazil 2010"', add
label define sample_lbl 854198501 `"Burkina Faso 1985"', add
label define sample_lbl 854199601 `"Burkina Faso 1996"', add
label define sample_lbl 854200601 `"Burkina Faso 2006"', add
label define sample_lbl 116199801 `"Cambodia 1998"', add
label define sample_lbl 116200401 `"Cambodia 2004"', add
label define sample_lbl 116200801 `"Cambodia 2008"', add
label define sample_lbl 116201301 `"Cambodia 2013"', add
label define sample_lbl 120197601 `"Cameroon 1976"', add
label define sample_lbl 120198701 `"Cameroon 1987"', add
label define sample_lbl 120200501 `"Cameroon 2005"', add
label define sample_lbl 124185201 `"Canada 1852"', add
label define sample_lbl 124187101 `"Canada 1871"', add
label define sample_lbl 124188101 `"Canada 1881"', add
label define sample_lbl 124189101 `"Canada 1891"', add
label define sample_lbl 124190101 `"Canada 1901"', add
label define sample_lbl 124191101 `"Canada 1911"', add
label define sample_lbl 124197101 `"Canada 1971"', add
label define sample_lbl 124198101 `"Canada 1981"', add
label define sample_lbl 124199101 `"Canada 1991"', add
label define sample_lbl 124200101 `"Canada 2001"', add
label define sample_lbl 124201101 `"Canada 2011"', add
label define sample_lbl 152196001 `"Chile 1960"', add
label define sample_lbl 152197001 `"Chile 1970"', add
label define sample_lbl 152198201 `"Chile 1982"', add
label define sample_lbl 152199201 `"Chile 1992"', add
label define sample_lbl 152200201 `"Chile 2002"', add
label define sample_lbl 156198201 `"China 1982"', add
label define sample_lbl 156199001 `"China 1990"', add
label define sample_lbl 156200001 `"China 2000"', add
label define sample_lbl 170196401 `"Colombia 1964"', add
label define sample_lbl 170197301 `"Colombia 1973"', add
label define sample_lbl 170198501 `"Colombia 1985"', add
label define sample_lbl 170199301 `"Colombia 1993"', add
label define sample_lbl 170200501 `"Colombia 2005"', add
label define sample_lbl 188196301 `"Costa Rica 1963"', add
label define sample_lbl 188197301 `"Costa Rica 1973"', add
label define sample_lbl 188198401 `"Costa Rica 1984"', add
label define sample_lbl 188200001 `"Costa Rica 2000"', add
label define sample_lbl 188201101 `"Costa Rica 2011"', add
label define sample_lbl 192200201 `"Cuba 2002"', add
label define sample_lbl 208178701 `"Denmark 1787"', add
label define sample_lbl 208180101 `"Denmark 1801"', add
label define sample_lbl 214196001 `"Dominican Republic 1960"', add
label define sample_lbl 214197001 `"Dominican Republic 1970"', add
label define sample_lbl 214198101 `"Dominican Republic 1981"', add
label define sample_lbl 214200201 `"Dominican Republic 2002"', add
label define sample_lbl 214201001 `"Dominican Republic 2010"', add
label define sample_lbl 218196201 `"Ecuador 1962"', add
label define sample_lbl 218197401 `"Ecuador 1974"', add
label define sample_lbl 218198201 `"Ecuador 1982"', add
label define sample_lbl 218199001 `"Ecuador 1990"', add
label define sample_lbl 218200101 `"Ecuador 2001"', add
label define sample_lbl 218201001 `"Ecuador 2010"', add
label define sample_lbl 818198601 `"Egypt 1986"', add
label define sample_lbl 818199601 `"Egypt 1996"', add
label define sample_lbl 818200601 `"Egypt 2006"', add
label define sample_lbl 222199201 `"El Salvador 1992"', add
label define sample_lbl 222200701 `"El Salvador 2007"', add
label define sample_lbl 231198401 `"Ethiopia 1984"', add
label define sample_lbl 231199401 `"Ethiopia 1994"', add
label define sample_lbl 231200701 `"Ethiopia 2007"', add
label define sample_lbl 242196601 `"Fiji 1966"', add
label define sample_lbl 242197601 `"Fiji 1976"', add
label define sample_lbl 242198601 `"Fiji 1986"', add
label define sample_lbl 242199601 `"Fiji 1996"', add
label define sample_lbl 242200701 `"Fiji 2007"', add
label define sample_lbl 242201401 `"Fiji 2014"', add
label define sample_lbl 250196201 `"France 1962"', add
label define sample_lbl 250196801 `"France 1968"', add
label define sample_lbl 250197501 `"France 1975"', add
label define sample_lbl 250198201 `"France 1982"', add
label define sample_lbl 250199001 `"France 1990"', add
label define sample_lbl 250199901 `"France 1999"', add
label define sample_lbl 250200601 `"France 2006"', add
label define sample_lbl 250201101 `"France 2011"', add
label define sample_lbl 276181901 `"Germany 1819 (Mecklenburg)"', add
label define sample_lbl 276197001 `"Germany 1970 (West)"', add
label define sample_lbl 276197101 `"Germany 1971 (East)"', add
label define sample_lbl 276198101 `"Germany 1981 (East)"', add
label define sample_lbl 276198701 `"Germany 1987 (West)"', add
label define sample_lbl 288198401 `"Ghana 1984"', add
label define sample_lbl 288200001 `"Ghana 2000"', add
label define sample_lbl 288201001 `"Ghana 2010"', add
label define sample_lbl 300197101 `"Greece 1971"', add
label define sample_lbl 300198101 `"Greece 1981"', add
label define sample_lbl 300199101 `"Greece 1991"', add
label define sample_lbl 300200101 `"Greece 2001"', add
label define sample_lbl 300201101 `"Greece 2011"', add
label define sample_lbl 320196401 `"Guatemala 1964"', add
label define sample_lbl 320197301 `"Guatemala 1973"', add
label define sample_lbl 320198101 `"Guatemala 1981"', add
label define sample_lbl 320199401 `"Guatemala 1994"', add
label define sample_lbl 320200201 `"Guatemala 2002"', add
label define sample_lbl 324198301 `"Guinea 1983"', add
label define sample_lbl 324199601 `"Guinea 1996"', add
label define sample_lbl 332197101 `"Haiti 1971"', add
label define sample_lbl 332198201 `"Haiti 1982"', add
label define sample_lbl 332200301 `"Haiti 2003"', add
label define sample_lbl 340196101 `"Honduras 1961"', add
label define sample_lbl 340197401 `"Honduras 1974"', add
label define sample_lbl 340198801 `"Honduras 1988"', add
label define sample_lbl 340200101 `"Honduras 2001"', add
label define sample_lbl 348197001 `"Hungary 1970"', add
label define sample_lbl 348198001 `"Hungary 1980"', add
label define sample_lbl 348199001 `"Hungary 1990"', add
label define sample_lbl 348200101 `"Hungary 2001"', add
label define sample_lbl 348201101 `"Hungary 2011"', add
label define sample_lbl 352170301 `"Iceland 1703"', add
label define sample_lbl 352172901 `"Iceland 1729"', add
label define sample_lbl 352180101 `"Iceland 1801"', add
label define sample_lbl 352190101 `"Iceland 1901"', add
label define sample_lbl 352191001 `"Iceland 1910"', add
label define sample_lbl 356198341 `"India 1983"', add
label define sample_lbl 356198741 `"India 1987"', add
label define sample_lbl 356199341 `"India 1993"', add
label define sample_lbl 356199941 `"India 1999"', add
label define sample_lbl 356200441 `"India 2004"', add
label define sample_lbl 356200941 `"India 2009"', add
label define sample_lbl 360197101 `"Indonesia 1971"', add
label define sample_lbl 360197601 `"Indonesia 1976"', add
label define sample_lbl 360198001 `"Indonesia 1980"', add
label define sample_lbl 360198501 `"Indonesia 1985"', add
label define sample_lbl 360199001 `"Indonesia 1990"', add
label define sample_lbl 360199501 `"Indonesia 1995"', add
label define sample_lbl 360200001 `"Indonesia 2000"', add
label define sample_lbl 360200501 `"Indonesia 2005"', add
label define sample_lbl 360201001 `"Indonesia 2010"', add
label define sample_lbl 364200601 `"Iran 2006"', add
label define sample_lbl 364201101 `"Iran 2011"', add
label define sample_lbl 368199701 `"Iraq 1997"', add
label define sample_lbl 372197101 `"Ireland 1971"', add
label define sample_lbl 372197901 `"Ireland 1979"', add
label define sample_lbl 372198101 `"Ireland 1981"', add
label define sample_lbl 372198601 `"Ireland 1986"', add
label define sample_lbl 372199101 `"Ireland 1991"', add
label define sample_lbl 372199601 `"Ireland 1996"', add
label define sample_lbl 372200201 `"Ireland 2002"', add
label define sample_lbl 372200601 `"Ireland 2006"', add
label define sample_lbl 372201101 `"Ireland 2011"', add
label define sample_lbl 376197201 `"Israel 1972"', add
label define sample_lbl 376198301 `"Israel 1983"', add
label define sample_lbl 376199501 `"Israel 1995"', add
label define sample_lbl 380200101 `"Italy 2001"', add
label define sample_lbl 380201101 `"Italy 2011"', add
label define sample_lbl 380201121 `"Italy 2011 Q1 LFS"', add
label define sample_lbl 380201221 `"Italy 2012 Q1 LFS"', add
label define sample_lbl 380201321 `"Italy 2013 Q1 LFS"', add
label define sample_lbl 380201421 `"Italy 2014 Q1 LFS"', add
label define sample_lbl 380201521 `"Italy 2015 Q1 LFS"', add
label define sample_lbl 380201621 `"Italy 2016 Q1 LFS"', add
label define sample_lbl 380201721 `"Italy 2017 Q1 LFS"', add
label define sample_lbl 380201821 `"Italy 2018 Q1 LFS"', add
label define sample_lbl 388198201 `"Jamaica 1982"', add
label define sample_lbl 388199101 `"Jamaica 1991"', add
label define sample_lbl 388200101 `"Jamaica 2001"', add
label define sample_lbl 400200401 `"Jordan 2004"', add
label define sample_lbl 404196901 `"Kenya 1969"', add
label define sample_lbl 404197901 `"Kenya 1979"', add
label define sample_lbl 404198901 `"Kenya 1989"', add
label define sample_lbl 404199901 `"Kenya 1999"', add
label define sample_lbl 404200901 `"Kenya 2009"', add
label define sample_lbl 417199901 `"Kyrgyz Republic 1999"', add
label define sample_lbl 417200901 `"Kyrgyz Republic 2009"', add
label define sample_lbl 418200501 `"Laos 2005"', add
label define sample_lbl 426199601 `"Lesotho 1996"', add
label define sample_lbl 426200601 `"Lesotho 2006"', add
label define sample_lbl 430197401 `"Liberia 1974"', add
label define sample_lbl 430200801 `"Liberia 2008"', add
label define sample_lbl 454198701 `"Malawi 1987"', add
label define sample_lbl 454199801 `"Malawi 1998"', add
label define sample_lbl 454200801 `"Malawi 2008"', add
label define sample_lbl 458197001 `"Malaysia 1970"', add
label define sample_lbl 458198001 `"Malaysia 1980"', add
label define sample_lbl 458199101 `"Malaysia 1991"', add
label define sample_lbl 458200001 `"Malaysia 2000"', add
label define sample_lbl 466198701 `"Mali 1987"', add
label define sample_lbl 466199801 `"Mali 1998"', add
label define sample_lbl 466200901 `"Mali 2009"', add
label define sample_lbl 484196001 `"Mexico 1960"', add
label define sample_lbl 484197001 `"Mexico 1970"', add
label define sample_lbl 484199001 `"Mexico 1990"', add
label define sample_lbl 484199501 `"Mexico 1995"', add
label define sample_lbl 484200001 `"Mexico 2000"', add
label define sample_lbl 484200501 `"Mexico 2005"', add
label define sample_lbl 484201001 `"Mexico 2010"', add
label define sample_lbl 484201501 `"Mexico 2015"', add
label define sample_lbl 496198901 `"Mongolia 1989"', add
label define sample_lbl 496200001 `"Mongolia 2000"', add
label define sample_lbl 504198201 `"Morocco 1982"', add
label define sample_lbl 504199401 `"Morocco 1994"', add
label define sample_lbl 504200401 `"Morocco 2004"', add
label define sample_lbl 508199701 `"Mozambique 1997"', add
label define sample_lbl 508200701 `"Mozambique 2007"', add
label define sample_lbl 524200101 `"Nepal 2001"', add
label define sample_lbl 524201101 `"Nepal 2011"', add
label define sample_lbl 528196001 `"Netherlands 1960"', add
label define sample_lbl 528197101 `"Netherlands 1971"', add
label define sample_lbl 528200101 `"Netherlands 2001"', add
label define sample_lbl 528201101 `"Netherlands 2011"', add
label define sample_lbl 558197101 `"Nicaragua 1971"', add
label define sample_lbl 558199501 `"Nicaragua 1995"', add
label define sample_lbl 558200501 `"Nicaragua 2005"', add
label define sample_lbl 566200621 `"Nigeria 2006"', add
label define sample_lbl 566200721 `"Nigeria 2007"', add
label define sample_lbl 566200821 `"Nigeria 2008"', add
label define sample_lbl 566200921 `"Nigeria 2009"', add
label define sample_lbl 566201021 `"Nigeria 2010"', add
label define sample_lbl 578180101 `"Norway 1801"', add
label define sample_lbl 578186501 `"Norway 1865"', add
label define sample_lbl 578187501 `"Norway 1875"', add
label define sample_lbl 578190001 `"Norway 1900"', add
label define sample_lbl 578191001 `"Norway 1910"', add
label define sample_lbl 586197301 `"Pakistan 1973"', add
label define sample_lbl 586198101 `"Pakistan 1981"', add
label define sample_lbl 586199801 `"Pakistan 1998"', add
label define sample_lbl 275199701 `"Palestine 1997"', add
label define sample_lbl 275200701 `"Palestine 2007"', add
label define sample_lbl 591196001 `"Panama 1960"', add
label define sample_lbl 591197001 `"Panama 1970"', add
label define sample_lbl 591198001 `"Panama 1980"', add
label define sample_lbl 591199001 `"Panama 1990"', add
label define sample_lbl 591200001 `"Panama 2000"', add
label define sample_lbl 591201001 `"Panama 2010"', add
label define sample_lbl 598198001 `"Papua New Guinea 1980"', add
label define sample_lbl 598199001 `"Papua New Guinea 1990"', add
label define sample_lbl 598200001 `"Papua New Guinea 2000"', add
label define sample_lbl 600196201 `"Paraguay 1962"', add
label define sample_lbl 600197201 `"Paraguay 1972"', add
label define sample_lbl 600198201 `"Paraguay 1982"', add
label define sample_lbl 600199201 `"Paraguay 1992"', add
label define sample_lbl 600200201 `"Paraguay 2002"', add
label define sample_lbl 604199301 `"Peru 1993"', add
label define sample_lbl 604200701 `"Peru 2007"', add
label define sample_lbl 608199001 `"Philippines 1990"', add
label define sample_lbl 608199501 `"Philippines 1995"', add
label define sample_lbl 608200001 `"Philippines 2000"', add
label define sample_lbl 608201001 `"Philippines 2010"', add
label define sample_lbl 616197801 `"Poland 1978"', add
label define sample_lbl 616198801 `"Poland 1988"', add
label define sample_lbl 616200201 `"Poland 2002"', add
label define sample_lbl 616201101 `"Poland 2011"', add
label define sample_lbl 620198101 `"Portugal 1981"', add
label define sample_lbl 620199101 `"Portugal 1991"', add
label define sample_lbl 620200101 `"Portugal 2001"', add
label define sample_lbl 620201101 `"Portugal 2011"', add
label define sample_lbl 630197001 `"Puerto Rico 1970"', add
label define sample_lbl 630198001 `"Puerto Rico 1980"', add
label define sample_lbl 630199001 `"Puerto Rico 1990"', add
label define sample_lbl 630200001 `"Puerto Rico 2000"', add
label define sample_lbl 630200501 `"Puerto Rico 2005"', add
label define sample_lbl 630201001 `"Puerto Rico 2010"', add
label define sample_lbl 642197701 `"Romania 1977"', add
label define sample_lbl 642199201 `"Romania 1992"', add
label define sample_lbl 642200201 `"Romania 2002"', add
label define sample_lbl 642201101 `"Romania 2011"', add
label define sample_lbl 643200201 `"Russia 2002"', add
label define sample_lbl 643201001 `"Russia 2010"', add
label define sample_lbl 646199101 `"Rwanda 1991"', add
label define sample_lbl 646200201 `"Rwanda 2002"', add
label define sample_lbl 646201201 `"Rwanda 2012"', add
label define sample_lbl 662198001 `"Saint Lucia 1980"', add
label define sample_lbl 662199101 `"Saint Lucia 1991"', add
label define sample_lbl 686198801 `"Senegal 1988"', add
label define sample_lbl 686200201 `"Senegal 2002"', add
label define sample_lbl 694200401 `"Sierra Leone 2004"', add
label define sample_lbl 705200201 `"Slovenia 2002"', add
label define sample_lbl 710199601 `"South Africa 1996"', add
label define sample_lbl 710200101 `"South Africa 2001"', add
label define sample_lbl 710200701 `"South Africa 2007"', add
label define sample_lbl 710201101 `"South Africa 2011"', add
label define sample_lbl 728200801 `"South Sudan 2008"', add
label define sample_lbl 724198101 `"Spain 1981"', add
label define sample_lbl 724199101 `"Spain 1991"', add
label define sample_lbl 724200101 `"Spain 2001"', add
label define sample_lbl 724201101 `"Spain 2011"', add
label define sample_lbl 724200521 `"Spain 2005 Q1 LFS"', add
label define sample_lbl 724200522 `"Spain 2005 Q2 LFS"', add
label define sample_lbl 724200523 `"Spain 2005 Q3 LFS"', add
label define sample_lbl 724200524 `"Spain 2005 Q4 LFS"', add
label define sample_lbl 724200621 `"Spain 2006 Q1 LFS"', add
label define sample_lbl 724200622 `"Spain 2006 Q2 LFS"', add
label define sample_lbl 724200623 `"Spain 2006 Q3 LFS"', add
label define sample_lbl 724200624 `"Spain 2006 Q4 LFS"', add
label define sample_lbl 724200721 `"Spain 2007 Q1 LFS"', add
label define sample_lbl 724200722 `"Spain 2007 Q2 LFS"', add
label define sample_lbl 724200723 `"Spain 2007 Q3 LFS"', add
label define sample_lbl 724200724 `"Spain 2007 Q4 LFS"', add
label define sample_lbl 724200821 `"Spain 2008 Q1 LFS"', add
label define sample_lbl 724200822 `"Spain 2008 Q2 LFS"', add
label define sample_lbl 724200823 `"Spain 2008 Q3 LFS"', add
label define sample_lbl 724200824 `"Spain 2008 Q4 LFS"', add
label define sample_lbl 724200921 `"Spain 2009 Q1 LFS"', add
label define sample_lbl 724200922 `"Spain 2009 Q2 LFS"', add
label define sample_lbl 724200923 `"Spain 2009 Q3 LFS"', add
label define sample_lbl 724200924 `"Spain 2009 Q4 LFS"', add
label define sample_lbl 724201021 `"Spain 2010 Q1 LFS"', add
label define sample_lbl 724201022 `"Spain 2010 Q2 LFS"', add
label define sample_lbl 724201023 `"Spain 2010 Q3 LFS"', add
label define sample_lbl 724201024 `"Spain 2010 Q4 LFS"', add
label define sample_lbl 724201121 `"Spain 2011 Q1 LFS"', add
label define sample_lbl 724201122 `"Spain 2011 Q2 LFS"', add
label define sample_lbl 724201123 `"Spain 2011 Q3 LFS"', add
label define sample_lbl 724201124 `"Spain 2011 Q4 LFS"', add
label define sample_lbl 724201221 `"Spain 2012 Q1 LFS"', add
label define sample_lbl 724201222 `"Spain 2012 Q2 LFS"', add
label define sample_lbl 724201223 `"Spain 2012 Q3 LFS"', add
label define sample_lbl 724201224 `"Spain 2012 Q4 LFS"', add
label define sample_lbl 724201321 `"Spain 2013 Q1 LFS"', add
label define sample_lbl 724201322 `"Spain 2013 Q2 LFS"', add
label define sample_lbl 724201323 `"Spain 2013 Q3 LFS"', add
label define sample_lbl 724201324 `"Spain 2013 Q4 LFS"', add
label define sample_lbl 724201421 `"Spain 2014 Q1 LFS"', add
label define sample_lbl 724201422 `"Spain 2014 Q2 LFS"', add
label define sample_lbl 724201423 `"Spain 2014 Q3 LFS"', add
label define sample_lbl 724201424 `"Spain 2014 Q4 LFS"', add
label define sample_lbl 724201521 `"Spain 2015 Q1 LFS"', add
label define sample_lbl 724201522 `"Spain 2015 Q2 LFS"', add
label define sample_lbl 724201523 `"Spain 2015 Q3 LFS"', add
label define sample_lbl 724201524 `"Spain 2015 Q4 LFS"', add
label define sample_lbl 724201621 `"Spain 2016 Q1 LFS"', add
label define sample_lbl 724201622 `"Spain 2016 Q2 LFS"', add
label define sample_lbl 724201623 `"Spain 2016 Q3 LFS"', add
label define sample_lbl 724201624 `"Spain 2016 Q4 LFS"', add
label define sample_lbl 724201721 `"Spain 2017 Q1 LFS"', add
label define sample_lbl 724201722 `"Spain 2017 Q2 LFS"', add
label define sample_lbl 724201723 `"Spain 2017 Q3 LFS"', add
label define sample_lbl 724201724 `"Spain 2017 Q4 LFS"', add
label define sample_lbl 724201821 `"Spain 2018 Q1 LFS"', add
label define sample_lbl 724201822 `"Spain 2018 Q2 LFS"', add
label define sample_lbl 724201823 `"Spain 2018 Q3 LFS"', add
label define sample_lbl 724201824 `"Spain 2018 Q4 LFS"', add
label define sample_lbl 729200801 `"Sudan 2008"', add
label define sample_lbl 752188001 `"Sweden 1880"', add
label define sample_lbl 752189001 `"Sweden 1890"', add
label define sample_lbl 752190001 `"Sweden 1900"', add
label define sample_lbl 752191001 `"Sweden 1910"', add
label define sample_lbl 756197001 `"Switzerland 1970"', add
label define sample_lbl 756198001 `"Switzerland 1980"', add
label define sample_lbl 756199001 `"Switzerland 1990"', add
label define sample_lbl 756200001 `"Switzerland 2000"', add
label define sample_lbl 834198801 `"Tanzania 1988"', add
label define sample_lbl 834200201 `"Tanzania 2002"', add
label define sample_lbl 834201201 `"Tanzania 2012"', add
label define sample_lbl 764197001 `"Thailand 1970"', add
label define sample_lbl 764198001 `"Thailand 1980"', add
label define sample_lbl 764199001 `"Thailand 1990"', add
label define sample_lbl 764200001 `"Thailand 2000"', add
label define sample_lbl 768196001 `"Togo 1960"', add
label define sample_lbl 768197001 `"Togo 1970"', add
label define sample_lbl 768201001 `"Togo 2010"', add
label define sample_lbl 780197001 `"Trinidad and Tobago 1970"', add
label define sample_lbl 780198001 `"Trinidad and Tobago 1980"', add
label define sample_lbl 780199001 `"Trinidad and Tobago 1990"', add
label define sample_lbl 780200001 `"Trinidad and Tobago 2000"', add
label define sample_lbl 780201101 `"Trinidad and Tobago 2011"', add
label define sample_lbl 792198501 `"Turkey 1985"', add
label define sample_lbl 792199001 `"Turkey 1990"', add
label define sample_lbl 792200001 `"Turkey 2000"', add
label define sample_lbl 800199101 `"Uganda 1991"', add
label define sample_lbl 800200201 `"Uganda 2002"', add
label define sample_lbl 804200101 `"Ukraine 2001"', add
label define sample_lbl 826185101 `"United Kingdom 1851 (England and Wales)"', add
label define sample_lbl 826185102 `"United Kingdom 1851 (Scotland)"', add
label define sample_lbl 826185103 `"United Kingdom 1851 (2% sample)"', add
label define sample_lbl 826186101 `"United Kingdom 1861 (England and Wales)"', add
label define sample_lbl 826186102 `"United Kingdom 1861 (Scotland)"', add
label define sample_lbl 826187101 `"United Kingdom 1871 (Scotland)"', add
label define sample_lbl 826188101 `"United Kingdom 1881 (England and Wales)"', add
label define sample_lbl 826188102 `"United Kingdom 1881 (Scotland)"', add
label define sample_lbl 826189101 `"United Kingdom 1891 (England and Wales)"', add
label define sample_lbl 826189102 `"United Kingdom 1891 (Scotland)"', add
label define sample_lbl 826190101 `"United Kingdom 1901 (England and Wales)"', add
label define sample_lbl 826190102 `"United Kingdom 1901 (Scotland)"', add
label define sample_lbl 826191101 `"United Kingdom 1911 (England and Wales)"', add
label define sample_lbl 826199101 `"United Kingdom 1991"', add
label define sample_lbl 826200101 `"United Kingdom 2001"', add
label define sample_lbl 840185001 `"United States 1850 (100%)"', add
label define sample_lbl 840185002 `"United States 1850 (1%)"', add
label define sample_lbl 840186001 `"United States 1860 (1%)"', add
label define sample_lbl 840187001 `"United States 1870 (1%)"', add
label define sample_lbl 840188001 `"United States 1880 (100%)"', add
label define sample_lbl 840188002 `"United States 1880 (10%)"', add
label define sample_lbl 840190001 `"United States 1900 (5%)"', add
label define sample_lbl 840191001 `"United States 1910 (1%)"', add
label define sample_lbl 840196001 `"United States 1960"', add
label define sample_lbl 840197001 `"United States 1970"', add
label define sample_lbl 840198001 `"United States 1980"', add
label define sample_lbl 840199001 `"United States 1990"', add
label define sample_lbl 840200001 `"United States 2000"', add
label define sample_lbl 840200501 `"United States 2005"', add
label define sample_lbl 840201001 `"United States 2010"', add
label define sample_lbl 840201501 `"United States 2015"', add
label define sample_lbl 858196301 `"Uruguay 1963"', add
label define sample_lbl 858196302 `"Uruguay 1963 (full count)"', add
label define sample_lbl 858197501 `"Uruguay 1975"', add
label define sample_lbl 858197502 `"Uruguay 1975 (full count)"', add
label define sample_lbl 858198501 `"Uruguay 1985"', add
label define sample_lbl 858198502 `"Uruguay 1985 (full count)"', add
label define sample_lbl 858199601 `"Uruguay 1996"', add
label define sample_lbl 858199602 `"Uruguay 1996 (full count)"', add
label define sample_lbl 858200621 `"Uruguay 2006"', add
label define sample_lbl 858201101 `"Uruguay 2011"', add
label define sample_lbl 858201102 `"Uruguay 2011 (full count)"', add
label define sample_lbl 862197101 `"Venezuela 1971"', add
label define sample_lbl 862198101 `"Venezuela 1981"', add
label define sample_lbl 862199001 `"Venezuela 1990"', add
label define sample_lbl 862200101 `"Venezuela 2001"', add
label define sample_lbl 704198901 `"Vietnam 1989"', add
label define sample_lbl 704199901 `"Vietnam 1999"', add
label define sample_lbl 704200901 `"Vietnam 2009"', add
label define sample_lbl 894199001 `"Zambia 1990"', add
label define sample_lbl 894200001 `"Zambia 2000"', add
label define sample_lbl 894201001 `"Zambia 2010"', add
label define sample_lbl 716201201 `"Zimbabwe 2012"', add
label values sample sample_lbl

label define urban_lbl 1 `"Rural"'
label define urban_lbl 2 `"Urban"', add
label define urban_lbl 9 `"Unknown"', add
label values urban urban_lbl

label define geo1_mx2000_lbl 001 `"Aguascalientes"'
label define geo1_mx2000_lbl 002 `"Baja California"', add
label define geo1_mx2000_lbl 003 `"Baja California Sur"', add
label define geo1_mx2000_lbl 004 `"Campeche"', add
label define geo1_mx2000_lbl 005 `"Coahuila"', add
label define geo1_mx2000_lbl 006 `"Colima"', add
label define geo1_mx2000_lbl 007 `"Chiapas"', add
label define geo1_mx2000_lbl 008 `"Chihuahua"', add
label define geo1_mx2000_lbl 009 `"Distrito Federal"', add
label define geo1_mx2000_lbl 010 `"Durango"', add
label define geo1_mx2000_lbl 011 `"Guanajuato"', add
label define geo1_mx2000_lbl 012 `"Guerrero"', add
label define geo1_mx2000_lbl 013 `"Hidalgo"', add
label define geo1_mx2000_lbl 014 `"Jalisco"', add
label define geo1_mx2000_lbl 015 `"Mexico"', add
label define geo1_mx2000_lbl 016 `"Michoacan"', add
label define geo1_mx2000_lbl 017 `"Morelos"', add
label define geo1_mx2000_lbl 018 `"Nayarit"', add
label define geo1_mx2000_lbl 019 `"Nuevo Leon"', add
label define geo1_mx2000_lbl 020 `"Oaxaca"', add
label define geo1_mx2000_lbl 021 `"Puebla"', add
label define geo1_mx2000_lbl 022 `"Queretaro"', add
label define geo1_mx2000_lbl 023 `"Quintana Roo"', add
label define geo1_mx2000_lbl 024 `"San Luis Potosi"', add
label define geo1_mx2000_lbl 025 `"Sinaloa"', add
label define geo1_mx2000_lbl 026 `"Sonora"', add
label define geo1_mx2000_lbl 027 `"Tabasco"', add
label define geo1_mx2000_lbl 028 `"Tamaulipas"', add
label define geo1_mx2000_lbl 029 `"Tlaxcala"', add
label define geo1_mx2000_lbl 030 `"Veracruz"', add
label define geo1_mx2000_lbl 031 `"Yucatan"', add
label define geo1_mx2000_lbl 032 `"Zacatecas"', add
label values geo1_mx2000 geo1_mx2000_lbl

label define geo2_mx2000_lbl 001001 `"Aguascalientes"'
label define geo2_mx2000_lbl 001002 `"Asientos"', add
label define geo2_mx2000_lbl 001003 `"Calvillo"', add
label define geo2_mx2000_lbl 001004 `"Cosio"', add
label define geo2_mx2000_lbl 001005 `"Jesus Maria"', add
label define geo2_mx2000_lbl 001006 `"Pabellon de Arteaga"', add
label define geo2_mx2000_lbl 001007 `"Rincon de Romos"', add
label define geo2_mx2000_lbl 001008 `"San Jose de Gracia"', add
label define geo2_mx2000_lbl 001009 `"Tepezala"', add
label define geo2_mx2000_lbl 001010 `"Llano, El"', add
label define geo2_mx2000_lbl 001011 `"San Francisco de los Romo"', add
label define geo2_mx2000_lbl 002001 `"Ensenada"', add
label define geo2_mx2000_lbl 002002 `"Mexicali"', add
label define geo2_mx2000_lbl 002003 `"Tecate"', add
label define geo2_mx2000_lbl 002004 `"Tijuana"', add
label define geo2_mx2000_lbl 002005 `"Playas de Rosarito"', add
label define geo2_mx2000_lbl 003001 `"Comondu"', add
label define geo2_mx2000_lbl 003002 `"Mulege"', add
label define geo2_mx2000_lbl 003003 `"Paz, La"', add
label define geo2_mx2000_lbl 003008 `"Cabos, Los"', add
label define geo2_mx2000_lbl 003009 `"Loreto"', add
label define geo2_mx2000_lbl 004001 `"Calkini"', add
label define geo2_mx2000_lbl 004002 `"Campeche"', add
label define geo2_mx2000_lbl 004003 `"Carmen"', add
label define geo2_mx2000_lbl 004004 `"Champoton"', add
label define geo2_mx2000_lbl 004005 `"Hecelchakan"', add
label define geo2_mx2000_lbl 004006 `"Hopelchen"', add
label define geo2_mx2000_lbl 004007 `"Palizada"', add
label define geo2_mx2000_lbl 004008 `"Tenabo"', add
label define geo2_mx2000_lbl 004009 `"Escarcega"', add
label define geo2_mx2000_lbl 004010 `"Calakmul"', add
label define geo2_mx2000_lbl 004011 `"Candelaria"', add
label define geo2_mx2000_lbl 005001 `"Abasolo"', add
label define geo2_mx2000_lbl 005002 `"Acuna"', add
label define geo2_mx2000_lbl 005003 `"Allende"', add
label define geo2_mx2000_lbl 005004 `"Arteaga"', add
label define geo2_mx2000_lbl 005005 `"Candela"', add
label define geo2_mx2000_lbl 005006 `"Castanos"', add
label define geo2_mx2000_lbl 005007 `"Cuatrocienegas"', add
label define geo2_mx2000_lbl 005008 `"Escobedo"', add
label define geo2_mx2000_lbl 005009 `"Francisco I. Madero"', add
label define geo2_mx2000_lbl 005010 `"Frontera"', add
label define geo2_mx2000_lbl 005011 `"General Cepeda"', add
label define geo2_mx2000_lbl 005012 `"Guerrero"', add
label define geo2_mx2000_lbl 005013 `"Hidalgo"', add
label define geo2_mx2000_lbl 005014 `"Jimenez"', add
label define geo2_mx2000_lbl 005015 `"Juarez"', add
label define geo2_mx2000_lbl 005016 `"Lamadrid"', add
label define geo2_mx2000_lbl 005017 `"Matamoros"', add
label define geo2_mx2000_lbl 005018 `"Monclova"', add
label define geo2_mx2000_lbl 005019 `"Morelos"', add
label define geo2_mx2000_lbl 005020 `"Muzquiz"', add
label define geo2_mx2000_lbl 005021 `"Nadadores"', add
label define geo2_mx2000_lbl 005022 `"Nava"', add
label define geo2_mx2000_lbl 005023 `"Ocampo"', add
label define geo2_mx2000_lbl 005024 `"Parras"', add
label define geo2_mx2000_lbl 005025 `"Piedras Negras"', add
label define geo2_mx2000_lbl 005026 `"Progreso"', add
label define geo2_mx2000_lbl 005027 `"Ramos Arizpe"', add
label define geo2_mx2000_lbl 005028 `"Sabinas"', add
label define geo2_mx2000_lbl 005029 `"Sacramento"', add
label define geo2_mx2000_lbl 005030 `"Saltillo"', add
label define geo2_mx2000_lbl 005031 `"San Buenaventura"', add
label define geo2_mx2000_lbl 005032 `"San Juan de Sabinas"', add
label define geo2_mx2000_lbl 005033 `"San Pedro"', add
label define geo2_mx2000_lbl 005034 `"Sierra Mojada"', add
label define geo2_mx2000_lbl 005035 `"Torreon"', add
label define geo2_mx2000_lbl 005036 `"Viesca"', add
label define geo2_mx2000_lbl 005037 `"Villa Union"', add
label define geo2_mx2000_lbl 005038 `"Zaragoza"', add
label define geo2_mx2000_lbl 006001 `"Armeria"', add
label define geo2_mx2000_lbl 006002 `"Colima"', add
label define geo2_mx2000_lbl 006003 `"Comala"', add
label define geo2_mx2000_lbl 006004 `"Coquimatlan"', add
label define geo2_mx2000_lbl 006005 `"Cuauhtemoc"', add
label define geo2_mx2000_lbl 006006 `"Ixtlahuacan"', add
label define geo2_mx2000_lbl 006007 `"Manzanillo"', add
label define geo2_mx2000_lbl 006008 `"Minatitlan"', add
label define geo2_mx2000_lbl 006009 `"Tecoman"', add
label define geo2_mx2000_lbl 006010 `"Villa de Alvarez"', add
label define geo2_mx2000_lbl 007001 `"Acacoyagua"', add
label define geo2_mx2000_lbl 007002 `"Acala"', add
label define geo2_mx2000_lbl 007003 `"Acapetahua"', add
label define geo2_mx2000_lbl 007004 `"Altamirano"', add
label define geo2_mx2000_lbl 007005 `"Amatan"', add
label define geo2_mx2000_lbl 007006 `"Amatenango de la Frontera"', add
label define geo2_mx2000_lbl 007007 `"Amatenango del Valle"', add
label define geo2_mx2000_lbl 007008 `"Angel Albino Corzo"', add
label define geo2_mx2000_lbl 007009 `"Arriaga"', add
label define geo2_mx2000_lbl 007010 `"Bejucal de Ocampo"', add
label define geo2_mx2000_lbl 007011 `"Bella Vista"', add
label define geo2_mx2000_lbl 007012 `"Berriozabal"', add
label define geo2_mx2000_lbl 007013 `"Bochil"', add
label define geo2_mx2000_lbl 007014 `"Bosque, El"', add
label define geo2_mx2000_lbl 007015 `"Cacahoatan"', add
label define geo2_mx2000_lbl 007016 `"Catazaja"', add
label define geo2_mx2000_lbl 007017 `"Cintalapa"', add
label define geo2_mx2000_lbl 007018 `"Coapilla"', add
label define geo2_mx2000_lbl 007019 `"Comitan de Dominguez"', add
label define geo2_mx2000_lbl 007020 `"Concordia, La"', add
label define geo2_mx2000_lbl 007021 `"Copainala"', add
label define geo2_mx2000_lbl 007022 `"Chalchihuitan"', add
label define geo2_mx2000_lbl 007023 `"Chamula"', add
label define geo2_mx2000_lbl 007024 `"Chanal"', add
label define geo2_mx2000_lbl 007025 `"Chapultenango"', add
label define geo2_mx2000_lbl 007026 `"Chenalho"', add
label define geo2_mx2000_lbl 007027 `"Chiapa de Corzo"', add
label define geo2_mx2000_lbl 007028 `"Chiapilla"', add
label define geo2_mx2000_lbl 007029 `"Chicoasen"', add
label define geo2_mx2000_lbl 007030 `"Chicomuselo"', add
label define geo2_mx2000_lbl 007031 `"Chilon"', add
label define geo2_mx2000_lbl 007032 `"Escuintla"', add
label define geo2_mx2000_lbl 007033 `"Francisco Leon"', add
label define geo2_mx2000_lbl 007034 `"Frontera Comalapa"', add
label define geo2_mx2000_lbl 007035 `"Frontera Hidalgo"', add
label define geo2_mx2000_lbl 007036 `"Grandeza, La"', add
label define geo2_mx2000_lbl 007037 `"Huehuetan"', add
label define geo2_mx2000_lbl 007038 `"Huixtan"', add
label define geo2_mx2000_lbl 007039 `"Huitiupan"', add
label define geo2_mx2000_lbl 007040 `"Huixtla"', add
label define geo2_mx2000_lbl 007041 `"Independencia, La"', add
label define geo2_mx2000_lbl 007042 `"Ixhuatan"', add
label define geo2_mx2000_lbl 007043 `"Ixtacomitan"', add
label define geo2_mx2000_lbl 007044 `"Ixtapa"', add
label define geo2_mx2000_lbl 007045 `"Ixtapangajoya"', add
label define geo2_mx2000_lbl 007046 `"Jiquipilas"', add
label define geo2_mx2000_lbl 007047 `"Jitotol"', add
label define geo2_mx2000_lbl 007048 `"Juarez"', add
label define geo2_mx2000_lbl 007049 `"Larrainzar"', add
label define geo2_mx2000_lbl 007050 `"Libertad, La"', add
label define geo2_mx2000_lbl 007051 `"Mapastepec"', add
label define geo2_mx2000_lbl 007052 `"Margaritas, Las"', add
label define geo2_mx2000_lbl 007053 `"Mazapa de Madero"', add
label define geo2_mx2000_lbl 007054 `"Mazatan"', add
label define geo2_mx2000_lbl 007055 `"Metapa"', add
label define geo2_mx2000_lbl 007056 `"Mitontic"', add
label define geo2_mx2000_lbl 007057 `"Motozintla"', add
label define geo2_mx2000_lbl 007058 `"Nicolas Ruiz"', add
label define geo2_mx2000_lbl 007059 `"Ocosingo"', add
label define geo2_mx2000_lbl 007060 `"Ocotepec"', add
label define geo2_mx2000_lbl 007061 `"Ocozocoautla de Espinosa"', add
label define geo2_mx2000_lbl 007062 `"Ostuacan"', add
label define geo2_mx2000_lbl 007063 `"Osumacinta"', add
label define geo2_mx2000_lbl 007064 `"Oxchuc"', add
label define geo2_mx2000_lbl 007065 `"Palenque"', add
label define geo2_mx2000_lbl 007066 `"Pantelho"', add
label define geo2_mx2000_lbl 007067 `"Pantepec"', add
label define geo2_mx2000_lbl 007068 `"Pichucalco"', add
label define geo2_mx2000_lbl 007069 `"Pijijiapan"', add
label define geo2_mx2000_lbl 007070 `"Porvenir, El"', add
label define geo2_mx2000_lbl 007071 `"Villa Comaltitlan"', add
label define geo2_mx2000_lbl 007072 `"Pueblo Nuevo Solistahuacan"', add
label define geo2_mx2000_lbl 007073 `"Rayon"', add
label define geo2_mx2000_lbl 007074 `"Reforma"', add
label define geo2_mx2000_lbl 007075 `"Rosas, Las"', add
label define geo2_mx2000_lbl 007076 `"Sabanilla"', add
label define geo2_mx2000_lbl 007077 `"Salto de Agua"', add
label define geo2_mx2000_lbl 007078 `"San Cristobal de las Casas"', add
label define geo2_mx2000_lbl 007079 `"San Fernando"', add
label define geo2_mx2000_lbl 007080 `"Siltepec"', add
label define geo2_mx2000_lbl 007081 `"Simojovel"', add
label define geo2_mx2000_lbl 007082 `"Sitala"', add
label define geo2_mx2000_lbl 007083 `"Socoltenango"', add
label define geo2_mx2000_lbl 007084 `"Solosuchiapa"', add
label define geo2_mx2000_lbl 007085 `"Soyalo"', add
label define geo2_mx2000_lbl 007086 `"Suchiapa"', add
label define geo2_mx2000_lbl 007087 `"Suchiate"', add
label define geo2_mx2000_lbl 007088 `"Sunuapa"', add
label define geo2_mx2000_lbl 007089 `"Tapachula"', add
label define geo2_mx2000_lbl 007090 `"Tapalapa"', add
label define geo2_mx2000_lbl 007091 `"Tapilula"', add
label define geo2_mx2000_lbl 007092 `"Tecpatan"', add
label define geo2_mx2000_lbl 007093 `"Tenejapa"', add
label define geo2_mx2000_lbl 007094 `"Teopisca"', add
label define geo2_mx2000_lbl 007096 `"Tila"', add
label define geo2_mx2000_lbl 007097 `"Tonala"', add
label define geo2_mx2000_lbl 007098 `"Totolapa"', add
label define geo2_mx2000_lbl 007099 `"Trinitaria, La"', add
label define geo2_mx2000_lbl 007100 `"Tumbala"', add
label define geo2_mx2000_lbl 007101 `"Tuxtla Gutierrez"', add
label define geo2_mx2000_lbl 007102 `"Tuxtla Chico"', add
label define geo2_mx2000_lbl 007103 `"Tuzantan"', add
label define geo2_mx2000_lbl 007104 `"Tzimol"', add
label define geo2_mx2000_lbl 007105 `"Union Juarez"', add
label define geo2_mx2000_lbl 007106 `"Venustiano Carranza"', add
label define geo2_mx2000_lbl 007107 `"Villa Corzo"', add
label define geo2_mx2000_lbl 007108 `"Villaflores"', add
label define geo2_mx2000_lbl 007109 `"Yajalon"', add
label define geo2_mx2000_lbl 007110 `"San Lucas"', add
label define geo2_mx2000_lbl 007111 `"Zinacantan"', add
label define geo2_mx2000_lbl 007112 `"San Juan Cancuc"', add
label define geo2_mx2000_lbl 007113 `"Aldama"', add
label define geo2_mx2000_lbl 007114 `"Benemerito de las Americas"', add
label define geo2_mx2000_lbl 007115 `"Maravilla Tenejapa"', add
label define geo2_mx2000_lbl 007116 `"Marques de Comillas"', add
label define geo2_mx2000_lbl 007117 `"Monte Cristo de Guerrero"', add
label define geo2_mx2000_lbl 007118 `"San Andres Duraznal"', add
label define geo2_mx2000_lbl 007119 `"Santiago el Pinar"', add
label define geo2_mx2000_lbl 008001 `"Ahumada"', add
label define geo2_mx2000_lbl 008002 `"Aldama"', add
label define geo2_mx2000_lbl 008003 `"Allende"', add
label define geo2_mx2000_lbl 008004 `"Aquiles Serdan"', add
label define geo2_mx2000_lbl 008005 `"Ascension"', add
label define geo2_mx2000_lbl 008006 `"Bachiniva"', add
label define geo2_mx2000_lbl 008007 `"Balleza"', add
label define geo2_mx2000_lbl 008008 `"Batopilas"', add
label define geo2_mx2000_lbl 008009 `"Bocoyna"', add
label define geo2_mx2000_lbl 008010 `"Buenaventura"', add
label define geo2_mx2000_lbl 008011 `"Camargo"', add
label define geo2_mx2000_lbl 008012 `"Carichi"', add
label define geo2_mx2000_lbl 008013 `"Casas Grandes"', add
label define geo2_mx2000_lbl 008014 `"Coronado"', add
label define geo2_mx2000_lbl 008015 `"Coyame del Sotol"', add
label define geo2_mx2000_lbl 008016 `"Cruz, La"', add
label define geo2_mx2000_lbl 008017 `"Cuauhtemoc"', add
label define geo2_mx2000_lbl 008018 `"Cusihuiriachi"', add
label define geo2_mx2000_lbl 008019 `"Chihuahua"', add
label define geo2_mx2000_lbl 008020 `"Chinipas"', add
label define geo2_mx2000_lbl 008021 `"Delicias"', add
label define geo2_mx2000_lbl 008022 `"Dr. Belisario Dominguez"', add
label define geo2_mx2000_lbl 008023 `"Galeana"', add
label define geo2_mx2000_lbl 008024 `"Santa Isabel"', add
label define geo2_mx2000_lbl 008025 `"Gomez Farias"', add
label define geo2_mx2000_lbl 008026 `"Gran Morelos"', add
label define geo2_mx2000_lbl 008027 `"Guachochi"', add
label define geo2_mx2000_lbl 008028 `"Guadalupe"', add
label define geo2_mx2000_lbl 008029 `"Guadalupe y Calvo"', add
label define geo2_mx2000_lbl 008030 `"Guazapares"', add
label define geo2_mx2000_lbl 008031 `"Guerrero"', add
label define geo2_mx2000_lbl 008032 `"Hidalgo del Parral"', add
label define geo2_mx2000_lbl 008033 `"Huejotitan"', add
label define geo2_mx2000_lbl 008034 `"Ignacio Zaragoza"', add
label define geo2_mx2000_lbl 008035 `"Janos"', add
label define geo2_mx2000_lbl 008036 `"Jimenez"', add
label define geo2_mx2000_lbl 008037 `"Juarez"', add
label define geo2_mx2000_lbl 008038 `"Julimes"', add
label define geo2_mx2000_lbl 008039 `"Lopez"', add
label define geo2_mx2000_lbl 008040 `"Madera"', add
label define geo2_mx2000_lbl 008041 `"Maguarichi"', add
label define geo2_mx2000_lbl 008042 `"Manuel Benavides"', add
label define geo2_mx2000_lbl 008043 `"Matachi"', add
label define geo2_mx2000_lbl 008044 `"Matamoros"', add
label define geo2_mx2000_lbl 008045 `"Meoqui"', add
label define geo2_mx2000_lbl 008046 `"Morelos"', add
label define geo2_mx2000_lbl 008047 `"Moris"', add
label define geo2_mx2000_lbl 008048 `"Namiquipa"', add
label define geo2_mx2000_lbl 008049 `"Nonoava"', add
label define geo2_mx2000_lbl 008050 `"Nuevo Casas Grandes"', add
label define geo2_mx2000_lbl 008051 `"Ocampo"', add
label define geo2_mx2000_lbl 008052 `"Ojinaga"', add
label define geo2_mx2000_lbl 008053 `"Praxedis G. Guerrero"', add
label define geo2_mx2000_lbl 008054 `"Riva Palacio"', add
label define geo2_mx2000_lbl 008055 `"Rosales"', add
label define geo2_mx2000_lbl 008056 `"Rosario"', add
label define geo2_mx2000_lbl 008057 `"San Francisco de Borja"', add
label define geo2_mx2000_lbl 008058 `"San Francisco de Conchos"', add
label define geo2_mx2000_lbl 008059 `"San Francisco del Oro"', add
label define geo2_mx2000_lbl 008060 `"Santa Barbara"', add
label define geo2_mx2000_lbl 008061 `"Satevo"', add
label define geo2_mx2000_lbl 008062 `"Saucillo"', add
label define geo2_mx2000_lbl 008063 `"Temosachi"', add
label define geo2_mx2000_lbl 008064 `"Tule, El"', add
label define geo2_mx2000_lbl 008065 `"Urique"', add
label define geo2_mx2000_lbl 008066 `"Uruachi"', add
label define geo2_mx2000_lbl 008067 `"Valle de Zaragoza"', add
label define geo2_mx2000_lbl 009002 `"Azcapotzalco"', add
label define geo2_mx2000_lbl 009003 `"Coyoacan"', add
label define geo2_mx2000_lbl 009004 `"Cuajimalpa de Morelos"', add
label define geo2_mx2000_lbl 009005 `"Gustavo A. Madero"', add
label define geo2_mx2000_lbl 009006 `"Iztacalco"', add
label define geo2_mx2000_lbl 009007 `"Iztapalapa"', add
label define geo2_mx2000_lbl 009008 `"Magdalena Contreras, La"', add
label define geo2_mx2000_lbl 009009 `"Milpa Alta"', add
label define geo2_mx2000_lbl 009010 `"Alvaro Obregon"', add
label define geo2_mx2000_lbl 009011 `"Tlahuac"', add
label define geo2_mx2000_lbl 009012 `"Tlalpan"', add
label define geo2_mx2000_lbl 009013 `"Xochimilco"', add
label define geo2_mx2000_lbl 009014 `"Benito Juarez"', add
label define geo2_mx2000_lbl 009015 `"Cuauhtemoc"', add
label define geo2_mx2000_lbl 009016 `"Miguel Hidalgo"', add
label define geo2_mx2000_lbl 009017 `"Venustiano Carranza"', add
label define geo2_mx2000_lbl 010001 `"Canatlan"', add
label define geo2_mx2000_lbl 010002 `"Canelas"', add
label define geo2_mx2000_lbl 010003 `"Coneto de Comonfort"', add
label define geo2_mx2000_lbl 010004 `"Cuencame"', add
label define geo2_mx2000_lbl 010005 `"Durango"', add
label define geo2_mx2000_lbl 010006 `"General Simon Bolivar"', add
label define geo2_mx2000_lbl 010007 `"Gomez Palacio"', add
label define geo2_mx2000_lbl 010008 `"Guadalupe Victoria"', add
label define geo2_mx2000_lbl 010009 `"Guanacevi"', add
label define geo2_mx2000_lbl 010010 `"Hidalgo"', add
label define geo2_mx2000_lbl 010011 `"Inde"', add
label define geo2_mx2000_lbl 010012 `"Lerdo"', add
label define geo2_mx2000_lbl 010013 `"Mapimi"', add
label define geo2_mx2000_lbl 010014 `"Mezquital"', add
label define geo2_mx2000_lbl 010015 `"Nazas"', add
label define geo2_mx2000_lbl 010016 `"Nombre de Dios"', add
label define geo2_mx2000_lbl 010017 `"Ocampo"', add
label define geo2_mx2000_lbl 010018 `"Oro, El"', add
label define geo2_mx2000_lbl 010019 `"Otaez"', add
label define geo2_mx2000_lbl 010020 `"Panuco de Coronado"', add
label define geo2_mx2000_lbl 010021 `"Penon Blanco"', add
label define geo2_mx2000_lbl 010022 `"Poanas"', add
label define geo2_mx2000_lbl 010023 `"Pueblo Nuevo"', add
label define geo2_mx2000_lbl 010024 `"Rodeo"', add
label define geo2_mx2000_lbl 010025 `"San Bernardo"', add
label define geo2_mx2000_lbl 010026 `"San dimas"', add
label define geo2_mx2000_lbl 010027 `"San Juan de Guadalupe"', add
label define geo2_mx2000_lbl 010028 `"San Juan del Rio"', add
label define geo2_mx2000_lbl 010029 `"San Luis del Cordero"', add
label define geo2_mx2000_lbl 010030 `"San Pedro del Gallo"', add
label define geo2_mx2000_lbl 010031 `"Santa Clara"', add
label define geo2_mx2000_lbl 010032 `"Santiago Papasquiaro"', add
label define geo2_mx2000_lbl 010033 `"Suchil"', add
label define geo2_mx2000_lbl 010034 `"Tamazula"', add
label define geo2_mx2000_lbl 010035 `"Tepehuanes"', add
label define geo2_mx2000_lbl 010036 `"Tlahualilo"', add
label define geo2_mx2000_lbl 010037 `"Topia"', add
label define geo2_mx2000_lbl 010038 `"Vicente Guerrero"', add
label define geo2_mx2000_lbl 010039 `"Nuevo Ideal"', add
label define geo2_mx2000_lbl 011001 `"Abasolo"', add
label define geo2_mx2000_lbl 011002 `"Acambaro"', add
label define geo2_mx2000_lbl 011003 `"Allende"', add
label define geo2_mx2000_lbl 011004 `"Apaseo el Alto"', add
label define geo2_mx2000_lbl 011005 `"Apaseo el Grande"', add
label define geo2_mx2000_lbl 011006 `"Atarjea"', add
label define geo2_mx2000_lbl 011007 `"Celaya"', add
label define geo2_mx2000_lbl 011008 `"Manuel Doblado"', add
label define geo2_mx2000_lbl 011009 `"Comonfort"', add
label define geo2_mx2000_lbl 011010 `"Coroneo"', add
label define geo2_mx2000_lbl 011011 `"Cortazar"', add
label define geo2_mx2000_lbl 011012 `"Cueramaro"', add
label define geo2_mx2000_lbl 011013 `"Doctor Mora"', add
label define geo2_mx2000_lbl 011014 `"Dolores Hidalgo"', add
label define geo2_mx2000_lbl 011015 `"Guanajuato"', add
label define geo2_mx2000_lbl 011016 `"Huanimaro"', add
label define geo2_mx2000_lbl 011017 `"Irapuato"', add
label define geo2_mx2000_lbl 011018 `"Jaral del Progreso"', add
label define geo2_mx2000_lbl 011019 `"Jerecuaro"', add
label define geo2_mx2000_lbl 011020 `"Leon"', add
label define geo2_mx2000_lbl 011021 `"Moroleon"', add
label define geo2_mx2000_lbl 011022 `"Ocampo"', add
label define geo2_mx2000_lbl 011023 `"Penjamo"', add
label define geo2_mx2000_lbl 011024 `"Pueblo Nuevo"', add
label define geo2_mx2000_lbl 011025 `"Purisima del Rincon"', add
label define geo2_mx2000_lbl 011026 `"Romita"', add
label define geo2_mx2000_lbl 011027 `"Salamanca"', add
label define geo2_mx2000_lbl 011028 `"Salvatierra"', add
label define geo2_mx2000_lbl 011029 `"San Diego de la Union"', add
label define geo2_mx2000_lbl 011030 `"San Felipe"', add
label define geo2_mx2000_lbl 011031 `"San Francisco del Rincon"', add
label define geo2_mx2000_lbl 011032 `"San Jose Iturbide"', add
label define geo2_mx2000_lbl 011033 `"San Luis de la Paz"', add
label define geo2_mx2000_lbl 011034 `"Santa Catarina"', add
label define geo2_mx2000_lbl 011035 `"Santa Cruz de Juventino Rosas"', add
label define geo2_mx2000_lbl 011036 `"Santiago Maravatio"', add
label define geo2_mx2000_lbl 011037 `"Silao"', add
label define geo2_mx2000_lbl 011038 `"Tarandacuao"', add
label define geo2_mx2000_lbl 011039 `"Tarimoro"', add
label define geo2_mx2000_lbl 011040 `"Tierra Blanca"', add
label define geo2_mx2000_lbl 011041 `"Uriangato"', add
label define geo2_mx2000_lbl 011042 `"Valle de Santiago"', add
label define geo2_mx2000_lbl 011043 `"Victoria"', add
label define geo2_mx2000_lbl 011044 `"Villagran"', add
label define geo2_mx2000_lbl 011045 `"Xichu"', add
label define geo2_mx2000_lbl 011046 `"Yuriria"', add
label define geo2_mx2000_lbl 012001 `"Acapulco de Juarez"', add
label define geo2_mx2000_lbl 012002 `"Ahuacuotzingo"', add
label define geo2_mx2000_lbl 012003 `"Ajuchitlan del Progreso"', add
label define geo2_mx2000_lbl 012004 `"Alcozauca de Guerrero"', add
label define geo2_mx2000_lbl 012005 `"Alpoyeca"', add
label define geo2_mx2000_lbl 012006 `"Apaxtla"', add
label define geo2_mx2000_lbl 012007 `"Arcelia"', add
label define geo2_mx2000_lbl 012008 `"Atenango del Rio"', add
label define geo2_mx2000_lbl 012009 `"Atlamajalcingo del Monte"', add
label define geo2_mx2000_lbl 012010 `"Atlixtac"', add
label define geo2_mx2000_lbl 012011 `"Atoyac de Alvarez"', add
label define geo2_mx2000_lbl 012012 `"Ayutla de los Libres"', add
label define geo2_mx2000_lbl 012013 `"Azoyu"', add
label define geo2_mx2000_lbl 012014 `"Benito Juarez"', add
label define geo2_mx2000_lbl 012015 `"Buenavista de Cuellar"', add
label define geo2_mx2000_lbl 012016 `"Coahuayutla de Jose Maria Izazaga"', add
label define geo2_mx2000_lbl 012017 `"Cocula"', add
label define geo2_mx2000_lbl 012018 `"Copala"', add
label define geo2_mx2000_lbl 012019 `"Copalillo"', add
label define geo2_mx2000_lbl 012020 `"Copanatoyac"', add
label define geo2_mx2000_lbl 012021 `"Coyuca de Benitez"', add
label define geo2_mx2000_lbl 012022 `"Coyuca de Catalan"', add
label define geo2_mx2000_lbl 012023 `"Cuajinicuilapa"', add
label define geo2_mx2000_lbl 012024 `"Cualac"', add
label define geo2_mx2000_lbl 012025 `"Cuautepec"', add
label define geo2_mx2000_lbl 012026 `"Cuetzala del Progreso"', add
label define geo2_mx2000_lbl 012027 `"Cutzamala de Pinzon"', add
label define geo2_mx2000_lbl 012028 `"Chilapa de Alvarez"', add
label define geo2_mx2000_lbl 012029 `"Chilpancingo de los Bravo"', add
label define geo2_mx2000_lbl 012030 `"Florencio Villarreal"', add
label define geo2_mx2000_lbl 012031 `"General Canuto A. Neri"', add
label define geo2_mx2000_lbl 012032 `"General Heliodoro Castillo"', add
label define geo2_mx2000_lbl 012033 `"Huamuxtitlan"', add
label define geo2_mx2000_lbl 012034 `"Huitzuco de los Figueroa"', add
label define geo2_mx2000_lbl 012035 `"Iguala de la Independencia"', add
label define geo2_mx2000_lbl 012036 `"Igualapa"', add
label define geo2_mx2000_lbl 012037 `"Ixcateopan de Cuauhtemoc"', add
label define geo2_mx2000_lbl 012038 `"Jose Azueta"', add
label define geo2_mx2000_lbl 012039 `"Juan R. Escudero"', add
label define geo2_mx2000_lbl 012040 `"Leonardo Bravo"', add
label define geo2_mx2000_lbl 012041 `"Malinaltepec"', add
label define geo2_mx2000_lbl 012042 `"Martir de Cuilapan"', add
label define geo2_mx2000_lbl 012043 `"Metlatonoc"', add
label define geo2_mx2000_lbl 012044 `"Mochitlan"', add
label define geo2_mx2000_lbl 012045 `"Olinala"', add
label define geo2_mx2000_lbl 012046 `"Ometepec"', add
label define geo2_mx2000_lbl 012047 `"Pedro Ascencio Alquisiras"', add
label define geo2_mx2000_lbl 012048 `"Petatlan"', add
label define geo2_mx2000_lbl 012049 `"Pilcaya"', add
label define geo2_mx2000_lbl 012050 `"Pungarabato"', add
label define geo2_mx2000_lbl 012051 `"Quechultenango"', add
label define geo2_mx2000_lbl 012052 `"San Luis Acatlan"', add
label define geo2_mx2000_lbl 012053 `"San Marcos"', add
label define geo2_mx2000_lbl 012054 `"San Miguel Totolapan"', add
label define geo2_mx2000_lbl 012055 `"Taxco de Alarcon"', add
label define geo2_mx2000_lbl 012056 `"Tecoanapa"', add
label define geo2_mx2000_lbl 012057 `"Tecpan de Galeana"', add
label define geo2_mx2000_lbl 012058 `"Teloloapan"', add
label define geo2_mx2000_lbl 012059 `"Tepecoacuilco de Trujano"', add
label define geo2_mx2000_lbl 012060 `"Tetipac"', add
label define geo2_mx2000_lbl 012061 `"Tixtla de Guerrero"', add
label define geo2_mx2000_lbl 012062 `"Tlacoachistlahuaca"', add
label define geo2_mx2000_lbl 012063 `"Tlacoapa"', add
label define geo2_mx2000_lbl 012064 `"Tlalchapa"', add
label define geo2_mx2000_lbl 012065 `"Tlalixtaquilla de Maldonado"', add
label define geo2_mx2000_lbl 012066 `"Tlapa de Comonfort"', add
label define geo2_mx2000_lbl 012067 `"Tlapehuala"', add
label define geo2_mx2000_lbl 012068 `"Union de Isidoro Montes de Oca, La"', add
label define geo2_mx2000_lbl 012069 `"Xalpatlahuac"', add
label define geo2_mx2000_lbl 012070 `"Xochihuehuetlan"', add
label define geo2_mx2000_lbl 012071 `"Xochistlahuaca"', add
label define geo2_mx2000_lbl 012072 `"Zapotitlan Tablas"', add
label define geo2_mx2000_lbl 012073 `"Zirandaro"', add
label define geo2_mx2000_lbl 012074 `"Zitlala"', add
label define geo2_mx2000_lbl 012075 `"Eduardo Neri"', add
label define geo2_mx2000_lbl 012076 `"Acatepec"', add
label define geo2_mx2000_lbl 013001 `"Acatlan"', add
label define geo2_mx2000_lbl 013002 `"Acaxochitlan"', add
label define geo2_mx2000_lbl 013003 `"Actopan"', add
label define geo2_mx2000_lbl 013004 `"Agua Blanca de Iturbide"', add
label define geo2_mx2000_lbl 013005 `"Ajacuba"', add
label define geo2_mx2000_lbl 013006 `"Alfajayucan"', add
label define geo2_mx2000_lbl 013007 `"Almoloya"', add
label define geo2_mx2000_lbl 013008 `"Apan"', add
label define geo2_mx2000_lbl 013009 `"Arenal, El"', add
label define geo2_mx2000_lbl 013010 `"Atitalaquia"', add
label define geo2_mx2000_lbl 013011 `"Atlapexco"', add
label define geo2_mx2000_lbl 013012 `"Atotonilco el Grande"', add
label define geo2_mx2000_lbl 013013 `"Atotonilco de Tula"', add
label define geo2_mx2000_lbl 013014 `"Calnali"', add
label define geo2_mx2000_lbl 013015 `"Cardonal"', add
label define geo2_mx2000_lbl 013016 `"Cuautepec de Hinojosa"', add
label define geo2_mx2000_lbl 013017 `"Chapantongo"', add
label define geo2_mx2000_lbl 013018 `"Chapulhuacan"', add
label define geo2_mx2000_lbl 013019 `"Chilcuautla"', add
label define geo2_mx2000_lbl 013020 `"Eloxochitlan"', add
label define geo2_mx2000_lbl 013021 `"Emiliano Zapata"', add
label define geo2_mx2000_lbl 013022 `"Epazoyucan"', add
label define geo2_mx2000_lbl 013023 `"Francisco I. Madero"', add
label define geo2_mx2000_lbl 013024 `"Huasca de Ocampo"', add
label define geo2_mx2000_lbl 013025 `"Huautla"', add
label define geo2_mx2000_lbl 013026 `"Huazalingo"', add
label define geo2_mx2000_lbl 013027 `"Huehuetla"', add
label define geo2_mx2000_lbl 013028 `"Huejutla de Reyes"', add
label define geo2_mx2000_lbl 013029 `"Huichapan"', add
label define geo2_mx2000_lbl 013030 `"Ixmiquilpan"', add
label define geo2_mx2000_lbl 013031 `"Jacala de Ledezma"', add
label define geo2_mx2000_lbl 013032 `"Jaltocan"', add
label define geo2_mx2000_lbl 013033 `"Juarez Hidalgo"', add
label define geo2_mx2000_lbl 013034 `"Lolotla"', add
label define geo2_mx2000_lbl 013035 `"Metepec"', add
label define geo2_mx2000_lbl 013036 `"San Agustin Metzquititlan"', add
label define geo2_mx2000_lbl 013037 `"Metztitlan"', add
label define geo2_mx2000_lbl 013038 `"Mineral del Chico"', add
label define geo2_mx2000_lbl 013039 `"Mineral del Monte"', add
label define geo2_mx2000_lbl 013040 `"Mision, La"', add
label define geo2_mx2000_lbl 013041 `"Mixquiahuala de Juarez"', add
label define geo2_mx2000_lbl 013042 `"Molango de Escamilla"', add
label define geo2_mx2000_lbl 013043 `"Nicolas Flores"', add
label define geo2_mx2000_lbl 013044 `"Nopala de Villagran"', add
label define geo2_mx2000_lbl 013045 `"Omitlan de Juarez"', add
label define geo2_mx2000_lbl 013046 `"San Felipe Orizatlan"', add
label define geo2_mx2000_lbl 013047 `"Pacula"', add
label define geo2_mx2000_lbl 013048 `"Pachuca de Soto"', add
label define geo2_mx2000_lbl 013049 `"Pisaflores"', add
label define geo2_mx2000_lbl 013050 `"Progreso de Obregon"', add
label define geo2_mx2000_lbl 013051 `"Mineral de La Reforma"', add
label define geo2_mx2000_lbl 013052 `"San Agustin Tlaxiaca"', add
label define geo2_mx2000_lbl 013053 `"San Bartolo Tutotepec"', add
label define geo2_mx2000_lbl 013054 `"San Salvador"', add
label define geo2_mx2000_lbl 013055 `"Santiago de Anaya"', add
label define geo2_mx2000_lbl 013056 `"Santiago Tulantepec de Lugo Guerrero"', add
label define geo2_mx2000_lbl 013057 `"Singuilucan"', add
label define geo2_mx2000_lbl 013058 `"Tasquillo"', add
label define geo2_mx2000_lbl 013059 `"Tecozautla"', add
label define geo2_mx2000_lbl 013060 `"Tenango de Doria"', add
label define geo2_mx2000_lbl 013061 `"Tepeapulco"', add
label define geo2_mx2000_lbl 013062 `"Tepehuacan de Guerrero"', add
label define geo2_mx2000_lbl 013063 `"Tepeji del Rio de Ocampo"', add
label define geo2_mx2000_lbl 013064 `"Tepetitlan"', add
label define geo2_mx2000_lbl 013065 `"Tetepango"', add
label define geo2_mx2000_lbl 013066 `"Villa de Tezontepec"', add
label define geo2_mx2000_lbl 013067 `"Tezontepec de Aldama"', add
label define geo2_mx2000_lbl 013068 `"Tianguistengo"', add
label define geo2_mx2000_lbl 013069 `"Tizayuca"', add
label define geo2_mx2000_lbl 013070 `"Tlahuelilpan"', add
label define geo2_mx2000_lbl 013071 `"Tlahuiltepa"', add
label define geo2_mx2000_lbl 013072 `"Tlanalapa"', add
label define geo2_mx2000_lbl 013073 `"Tlanchinol"', add
label define geo2_mx2000_lbl 013074 `"Tlaxcoapan"', add
label define geo2_mx2000_lbl 013075 `"Tolcayuca"', add
label define geo2_mx2000_lbl 013076 `"Tula de Allende"', add
label define geo2_mx2000_lbl 013077 `"Tulancingo de Bravo"', add
label define geo2_mx2000_lbl 013078 `"Xochiatipan"', add
label define geo2_mx2000_lbl 013079 `"Xochicoatlan"', add
label define geo2_mx2000_lbl 013080 `"Yahualica"', add
label define geo2_mx2000_lbl 013081 `"Zacualtipan de Angeles"', add
label define geo2_mx2000_lbl 013082 `"Zapotlan de Juarez"', add
label define geo2_mx2000_lbl 013083 `"Zempoala"', add
label define geo2_mx2000_lbl 013084 `"Zimapan"', add
label define geo2_mx2000_lbl 014001 `"Acatic"', add
label define geo2_mx2000_lbl 014002 `"Acatlan de Juarez"', add
label define geo2_mx2000_lbl 014003 `"Ahualulco de Mercado"', add
label define geo2_mx2000_lbl 014004 `"Amacueca"', add
label define geo2_mx2000_lbl 014005 `"Amatitan"', add
label define geo2_mx2000_lbl 014006 `"Ameca"', add
label define geo2_mx2000_lbl 014007 `"San Juanito de Escobedo"', add
label define geo2_mx2000_lbl 014008 `"Arandas"', add
label define geo2_mx2000_lbl 014009 `"Arenal, El"', add
label define geo2_mx2000_lbl 014010 `"Atemajac de Brizuela"', add
label define geo2_mx2000_lbl 014011 `"Atengo"', add
label define geo2_mx2000_lbl 014012 `"Atenguillo"', add
label define geo2_mx2000_lbl 014013 `"Atotonilco el Alto"', add
label define geo2_mx2000_lbl 014014 `"Atoyac"', add
label define geo2_mx2000_lbl 014015 `"Autlan de Navarro"', add
label define geo2_mx2000_lbl 014016 `"Ayotlan"', add
label define geo2_mx2000_lbl 014017 `"Ayutla"', add
label define geo2_mx2000_lbl 014018 `"Barca, La"', add
label define geo2_mx2000_lbl 014019 `"Bolanos"', add
label define geo2_mx2000_lbl 014020 `"Cabo Corrientes"', add
label define geo2_mx2000_lbl 014021 `"Casimiro Castillo"', add
label define geo2_mx2000_lbl 014022 `"Cihuatlan"', add
label define geo2_mx2000_lbl 014023 `"Zapotlan el Grande"', add
label define geo2_mx2000_lbl 014024 `"Cocula"', add
label define geo2_mx2000_lbl 014025 `"Colotlan"', add
label define geo2_mx2000_lbl 014026 `"Concepcion de Buenos Aires"', add
label define geo2_mx2000_lbl 014027 `"Cuautitlan de Garcia Barragan"', add
label define geo2_mx2000_lbl 014028 `"Cuautla"', add
label define geo2_mx2000_lbl 014029 `"Cuquio"', add
label define geo2_mx2000_lbl 014030 `"Chapala"', add
label define geo2_mx2000_lbl 014031 `"Chimaltitan"', add
label define geo2_mx2000_lbl 014032 `"Chiquilistlan"', add
label define geo2_mx2000_lbl 014033 `"Degollado"', add
label define geo2_mx2000_lbl 014034 `"Ejutla"', add
label define geo2_mx2000_lbl 014035 `"Encarnacion de Diaz"', add
label define geo2_mx2000_lbl 014036 `"Etzatlan"', add
label define geo2_mx2000_lbl 014037 `"Grullo, El"', add
label define geo2_mx2000_lbl 014038 `"Guachinango"', add
label define geo2_mx2000_lbl 014039 `"Guadalajara"', add
label define geo2_mx2000_lbl 014040 `"Hostotipaquillo"', add
label define geo2_mx2000_lbl 014041 `"Huejucar"', add
label define geo2_mx2000_lbl 014042 `"Huejuquilla el Alto"', add
label define geo2_mx2000_lbl 014043 `"Huerta, La"', add
label define geo2_mx2000_lbl 014044 `"Ixtlahuacan de los Membrillos"', add
label define geo2_mx2000_lbl 014045 `"Ixtlahuacan del Rio"', add
label define geo2_mx2000_lbl 014046 `"Jalostotitlan"', add
label define geo2_mx2000_lbl 014047 `"Jamay"', add
label define geo2_mx2000_lbl 014048 `"Jesus Maria"', add
label define geo2_mx2000_lbl 014049 `"Jilotlan de los Dolores"', add
label define geo2_mx2000_lbl 014050 `"Jocotepec"', add
label define geo2_mx2000_lbl 014051 `"Juanacatlan"', add
label define geo2_mx2000_lbl 014052 `"Juchitlan"', add
label define geo2_mx2000_lbl 014053 `"Lagos de Moreno"', add
label define geo2_mx2000_lbl 014054 `"Limon, El"', add
label define geo2_mx2000_lbl 014055 `"Magdalena"', add
label define geo2_mx2000_lbl 014056 `"Santa Maria del Oro"', add
label define geo2_mx2000_lbl 014057 `"Manzanilla de la Paz, La"', add
label define geo2_mx2000_lbl 014058 `"Mascota"', add
label define geo2_mx2000_lbl 014059 `"Mazamitla"', add
label define geo2_mx2000_lbl 014060 `"Mexticacan"', add
label define geo2_mx2000_lbl 014061 `"Mezquitic"', add
label define geo2_mx2000_lbl 014062 `"Mixtlan"', add
label define geo2_mx2000_lbl 014063 `"Ocotlan"', add
label define geo2_mx2000_lbl 014064 `"Ojuelos de Jalisco"', add
label define geo2_mx2000_lbl 014065 `"Pihuamo"', add
label define geo2_mx2000_lbl 014066 `"Poncitlan"', add
label define geo2_mx2000_lbl 014067 `"Puerto Vallarta"', add
label define geo2_mx2000_lbl 014068 `"Villa Purificacion"', add
label define geo2_mx2000_lbl 014069 `"Quitupan"', add
label define geo2_mx2000_lbl 014070 `"Salto, El"', add
label define geo2_mx2000_lbl 014071 `"San Cristobal de la Barranca"', add
label define geo2_mx2000_lbl 014072 `"San Diego de Alejandria"', add
label define geo2_mx2000_lbl 014073 `"San Juan de los Lagos"', add
label define geo2_mx2000_lbl 014074 `"San Julian"', add
label define geo2_mx2000_lbl 014075 `"San Marcos"', add
label define geo2_mx2000_lbl 014076 `"San Martin de Bolanos"', add
label define geo2_mx2000_lbl 014077 `"San Martin de Hidalgo"', add
label define geo2_mx2000_lbl 014078 `"San Miguel el Alto"', add
label define geo2_mx2000_lbl 014079 `"Gomez Farias"', add
label define geo2_mx2000_lbl 014080 `"San Sebastian del Oeste"', add
label define geo2_mx2000_lbl 014081 `"Santa Maria de los Angeles"', add
label define geo2_mx2000_lbl 014082 `"Sayula"', add
label define geo2_mx2000_lbl 014083 `"Tala"', add
label define geo2_mx2000_lbl 014084 `"Talpa de Allende"', add
label define geo2_mx2000_lbl 014085 `"Tamazula de Gordiano"', add
label define geo2_mx2000_lbl 014086 `"Tapalpa"', add
label define geo2_mx2000_lbl 014087 `"Tecalitlan"', add
label define geo2_mx2000_lbl 014088 `"Tecolotlan"', add
label define geo2_mx2000_lbl 014089 `"Techaluta de Montenegro"', add
label define geo2_mx2000_lbl 014090 `"Tenamaxtlan"', add
label define geo2_mx2000_lbl 014091 `"Teocaltiche"', add
label define geo2_mx2000_lbl 014092 `"Teocuitatlan de Corona"', add
label define geo2_mx2000_lbl 014093 `"Tepatitlan de Morelos"', add
label define geo2_mx2000_lbl 014094 `"Tequila"', add
label define geo2_mx2000_lbl 014095 `"Teuchitlan"', add
label define geo2_mx2000_lbl 014096 `"Tizapan el Alto"', add
label define geo2_mx2000_lbl 014097 `"Tlajomulco de Zuniga"', add
label define geo2_mx2000_lbl 014098 `"Tlaquepaque"', add
label define geo2_mx2000_lbl 014099 `"Toliman"', add
label define geo2_mx2000_lbl 014100 `"Tomatlan"', add
label define geo2_mx2000_lbl 014101 `"Tonala"', add
label define geo2_mx2000_lbl 014102 `"Tonaya"', add
label define geo2_mx2000_lbl 014103 `"Tonila"', add
label define geo2_mx2000_lbl 014104 `"Totatiche"', add
label define geo2_mx2000_lbl 014105 `"Tototlan"', add
label define geo2_mx2000_lbl 014106 `"Tuxcacuesco"', add
label define geo2_mx2000_lbl 014107 `"Tuxcueca"', add
label define geo2_mx2000_lbl 014108 `"Tuxpan"', add
label define geo2_mx2000_lbl 014109 `"Union de San Antonio"', add
label define geo2_mx2000_lbl 014110 `"Union de Tula"', add
label define geo2_mx2000_lbl 014111 `"Valle de Guadalupe"', add
label define geo2_mx2000_lbl 014112 `"Valle de Juarez"', add
label define geo2_mx2000_lbl 014113 `"San Gabriel"', add
label define geo2_mx2000_lbl 014114 `"Villa Corona"', add
label define geo2_mx2000_lbl 014115 `"Villa Guerrero"', add
label define geo2_mx2000_lbl 014116 `"Villa Hidalgo"', add
label define geo2_mx2000_lbl 014117 `"Canadas de Obregon"', add
label define geo2_mx2000_lbl 014118 `"Yahualica de Gonzalez Gallo"', add
label define geo2_mx2000_lbl 014119 `"Zacoalco de Torres"', add
label define geo2_mx2000_lbl 014120 `"Zapopan"', add
label define geo2_mx2000_lbl 014121 `"Zapotiltic"', add
label define geo2_mx2000_lbl 014122 `"Zapotitlan de Vadillo"', add
label define geo2_mx2000_lbl 014123 `"Zapotlan del Rey"', add
label define geo2_mx2000_lbl 014124 `"Zapotlanejo"', add
label define geo2_mx2000_lbl 015001 `"Acambay"', add
label define geo2_mx2000_lbl 015002 `"Acolman"', add
label define geo2_mx2000_lbl 015003 `"Aculco"', add
label define geo2_mx2000_lbl 015004 `"Almoloya de Alquisiras"', add
label define geo2_mx2000_lbl 015005 `"Almoloya de Juarez"', add
label define geo2_mx2000_lbl 015006 `"Almoloya del Rio"', add
label define geo2_mx2000_lbl 015007 `"Amanalco"', add
label define geo2_mx2000_lbl 015008 `"Amatepec"', add
label define geo2_mx2000_lbl 015009 `"Amecameca"', add
label define geo2_mx2000_lbl 015010 `"Apaxco"', add
label define geo2_mx2000_lbl 015011 `"Atenco"', add
label define geo2_mx2000_lbl 015012 `"Atizapan"', add
label define geo2_mx2000_lbl 015013 `"Atizapan de Zaragoza"', add
label define geo2_mx2000_lbl 015014 `"Atlacomulco"', add
label define geo2_mx2000_lbl 015015 `"Atlautla"', add
label define geo2_mx2000_lbl 015016 `"Axapusco"', add
label define geo2_mx2000_lbl 015017 `"Ayapango"', add
label define geo2_mx2000_lbl 015018 `"Calimaya"', add
label define geo2_mx2000_lbl 015019 `"Capulhuac"', add
label define geo2_mx2000_lbl 015020 `"Coacalco de Berriozabal"', add
label define geo2_mx2000_lbl 015021 `"Coatepec Harinas"', add
label define geo2_mx2000_lbl 015022 `"Cocotitlan"', add
label define geo2_mx2000_lbl 015023 `"Coyotepec"', add
label define geo2_mx2000_lbl 015024 `"Cuautitlan"', add
label define geo2_mx2000_lbl 015025 `"Chalco"', add
label define geo2_mx2000_lbl 015026 `"Chapa de Mota"', add
label define geo2_mx2000_lbl 015027 `"Chapultepec"', add
label define geo2_mx2000_lbl 015028 `"Chiautla"', add
label define geo2_mx2000_lbl 015029 `"Chicoloapan"', add
label define geo2_mx2000_lbl 015030 `"Chiconcuac"', add
label define geo2_mx2000_lbl 015031 `"Chimalhuacan"', add
label define geo2_mx2000_lbl 015032 `"Donato Guerra"', add
label define geo2_mx2000_lbl 015033 `"Ecatepec de Morelos"', add
label define geo2_mx2000_lbl 015034 `"Ecatzingo"', add
label define geo2_mx2000_lbl 015035 `"Huehuetoca"', add
label define geo2_mx2000_lbl 015036 `"Hueypoxtla"', add
label define geo2_mx2000_lbl 015037 `"Huixquilucan"', add
label define geo2_mx2000_lbl 015038 `"Isidro Fabela"', add
label define geo2_mx2000_lbl 015039 `"Ixtapaluca"', add
label define geo2_mx2000_lbl 015040 `"Ixtapan de la Sal"', add
label define geo2_mx2000_lbl 015041 `"Ixtapan del Oro"', add
label define geo2_mx2000_lbl 015042 `"Ixtlahuaca"', add
label define geo2_mx2000_lbl 015043 `"Xalatlaco"', add
label define geo2_mx2000_lbl 015044 `"Jaltenco"', add
label define geo2_mx2000_lbl 015045 `"Jilotepec"', add
label define geo2_mx2000_lbl 015046 `"Jilotzingo"', add
label define geo2_mx2000_lbl 015047 `"Jiquipilco"', add
label define geo2_mx2000_lbl 015048 `"Jocotitlan"', add
label define geo2_mx2000_lbl 015049 `"Joquicingo"', add
label define geo2_mx2000_lbl 015050 `"Juchitepec"', add
label define geo2_mx2000_lbl 015051 `"Lerma"', add
label define geo2_mx2000_lbl 015052 `"Malinalco"', add
label define geo2_mx2000_lbl 015053 `"Melchor Ocampo"', add
label define geo2_mx2000_lbl 015054 `"Metepec"', add
label define geo2_mx2000_lbl 015055 `"Mexicaltzingo"', add
label define geo2_mx2000_lbl 015056 `"Morelos"', add
label define geo2_mx2000_lbl 015057 `"Naucalpan de Juarez"', add
label define geo2_mx2000_lbl 015058 `"Nezahualcoyotl"', add
label define geo2_mx2000_lbl 015059 `"Nextlalpan"', add
label define geo2_mx2000_lbl 015060 `"Nicolas Romero"', add
label define geo2_mx2000_lbl 015061 `"Nopaltepec"', add
label define geo2_mx2000_lbl 015062 `"Ocoyoacac"', add
label define geo2_mx2000_lbl 015063 `"Ocuilan"', add
label define geo2_mx2000_lbl 015064 `"Oro, El"', add
label define geo2_mx2000_lbl 015065 `"Otumba"', add
label define geo2_mx2000_lbl 015066 `"Otzoloapan"', add
label define geo2_mx2000_lbl 015067 `"Otzolotepec"', add
label define geo2_mx2000_lbl 015068 `"Ozumba"', add
label define geo2_mx2000_lbl 015069 `"Papalotla"', add
label define geo2_mx2000_lbl 015070 `"Paz, La"', add
label define geo2_mx2000_lbl 015071 `"Polotitlan"', add
label define geo2_mx2000_lbl 015072 `"Rayon"', add
label define geo2_mx2000_lbl 015073 `"San Antonio la Isla"', add
label define geo2_mx2000_lbl 015074 `"San Felipe del Progreso"', add
label define geo2_mx2000_lbl 015075 `"San Martin de las Piramides"', add
label define geo2_mx2000_lbl 015076 `"San Mateo Atenco"', add
label define geo2_mx2000_lbl 015077 `"San Simon de Guerrero"', add
label define geo2_mx2000_lbl 015078 `"Santo Tomas"', add
label define geo2_mx2000_lbl 015079 `"Soyaniquilpan de Juarez"', add
label define geo2_mx2000_lbl 015080 `"Sultepec"', add
label define geo2_mx2000_lbl 015081 `"Tecamac"', add
label define geo2_mx2000_lbl 015082 `"Tejupilco"', add
label define geo2_mx2000_lbl 015083 `"Temamatla"', add
label define geo2_mx2000_lbl 015084 `"Temascalapa"', add
label define geo2_mx2000_lbl 015085 `"Temascalcingo"', add
label define geo2_mx2000_lbl 015086 `"Temascaltepec"', add
label define geo2_mx2000_lbl 015087 `"Temoaya"', add
label define geo2_mx2000_lbl 015088 `"Tenancingo"', add
label define geo2_mx2000_lbl 015089 `"Tenango del Aire"', add
label define geo2_mx2000_lbl 015090 `"Tenango del Valle"', add
label define geo2_mx2000_lbl 015091 `"Teoloyucan"', add
label define geo2_mx2000_lbl 015092 `"Teotihuacan"', add
label define geo2_mx2000_lbl 015093 `"Tepetlaoxtoc"', add
label define geo2_mx2000_lbl 015094 `"Tepetlixpa"', add
label define geo2_mx2000_lbl 015095 `"Tepotzotlan"', add
label define geo2_mx2000_lbl 015096 `"Tequixquiac"', add
label define geo2_mx2000_lbl 015097 `"Texcaltitlan"', add
label define geo2_mx2000_lbl 015098 `"Texcalyacac"', add
label define geo2_mx2000_lbl 015099 `"Texcoco"', add
label define geo2_mx2000_lbl 015100 `"Tezoyuca"', add
label define geo2_mx2000_lbl 015101 `"Tianguistenco"', add
label define geo2_mx2000_lbl 015102 `"Timilpan"', add
label define geo2_mx2000_lbl 015103 `"Tlalmanalco"', add
label define geo2_mx2000_lbl 015104 `"Tlalnepantla de Baz"', add
label define geo2_mx2000_lbl 015105 `"Tlatlaya"', add
label define geo2_mx2000_lbl 015106 `"Toluca"', add
label define geo2_mx2000_lbl 015107 `"Tonatico"', add
label define geo2_mx2000_lbl 015108 `"Tultepec"', add
label define geo2_mx2000_lbl 015109 `"Tultitlan"', add
label define geo2_mx2000_lbl 015110 `"Valle de Bravo"', add
label define geo2_mx2000_lbl 015111 `"Villa de Allende"', add
label define geo2_mx2000_lbl 015112 `"Villa del Carbon"', add
label define geo2_mx2000_lbl 015113 `"Villa Guerrero"', add
label define geo2_mx2000_lbl 015114 `"Villa Victoria"', add
label define geo2_mx2000_lbl 015115 `"Xonacatlan"', add
label define geo2_mx2000_lbl 015116 `"Zacazonapan"', add
label define geo2_mx2000_lbl 015117 `"Zacualpan"', add
label define geo2_mx2000_lbl 015118 `"Zinacantepec"', add
label define geo2_mx2000_lbl 015119 `"Zumpahuacan"', add
label define geo2_mx2000_lbl 015120 `"Zumpango"', add
label define geo2_mx2000_lbl 015121 `"Cuautitlan Izcalli"', add
label define geo2_mx2000_lbl 015122 `"Valle de Chalco Solidaridad"', add
label define geo2_mx2000_lbl 016001 `"Acuitzio"', add
label define geo2_mx2000_lbl 016002 `"Aguililla"', add
label define geo2_mx2000_lbl 016003 `"Alvaro Obregon"', add
label define geo2_mx2000_lbl 016004 `"Angamacutiro"', add
label define geo2_mx2000_lbl 016005 `"Angangueo"', add
label define geo2_mx2000_lbl 016006 `"Apatzingan"', add
label define geo2_mx2000_lbl 016007 `"Aporo"', add
label define geo2_mx2000_lbl 016008 `"Aquila"', add
label define geo2_mx2000_lbl 016009 `"Ario"', add
label define geo2_mx2000_lbl 016010 `"Arteaga"', add
label define geo2_mx2000_lbl 016011 `"Brisenas"', add
label define geo2_mx2000_lbl 016012 `"Buenavista"', add
label define geo2_mx2000_lbl 016013 `"Caracuaro"', add
label define geo2_mx2000_lbl 016014 `"Coahuayana"', add
label define geo2_mx2000_lbl 016015 `"Coalcoman de Vazquez Pallares"', add
label define geo2_mx2000_lbl 016016 `"Coeneo"', add
label define geo2_mx2000_lbl 016017 `"Contepec"', add
label define geo2_mx2000_lbl 016018 `"Copandaro"', add
label define geo2_mx2000_lbl 016019 `"Cotija"', add
label define geo2_mx2000_lbl 016020 `"Cuitzeo"', add
label define geo2_mx2000_lbl 016021 `"Charapan"', add
label define geo2_mx2000_lbl 016022 `"Charo"', add
label define geo2_mx2000_lbl 016023 `"Chavinda"', add
label define geo2_mx2000_lbl 016024 `"Cheran"', add
label define geo2_mx2000_lbl 016025 `"Chilchota"', add
label define geo2_mx2000_lbl 016026 `"Chinicuila"', add
label define geo2_mx2000_lbl 016027 `"Chucandiro"', add
label define geo2_mx2000_lbl 016028 `"Churintzio"', add
label define geo2_mx2000_lbl 016029 `"Churumuco"', add
label define geo2_mx2000_lbl 016030 `"Ecuandureo"', add
label define geo2_mx2000_lbl 016031 `"Epitacio Huerta"', add
label define geo2_mx2000_lbl 016032 `"Erongaricuaro"', add
label define geo2_mx2000_lbl 016033 `"Gabriel Zamora"', add
label define geo2_mx2000_lbl 016034 `"Hidalgo"', add
label define geo2_mx2000_lbl 016035 `"Huacana, La"', add
label define geo2_mx2000_lbl 016036 `"Huandacareo"', add
label define geo2_mx2000_lbl 016037 `"Huaniqueo"', add
label define geo2_mx2000_lbl 016038 `"Huetamo"', add
label define geo2_mx2000_lbl 016039 `"Huiramba"', add
label define geo2_mx2000_lbl 016040 `"Indaparapeo"', add
label define geo2_mx2000_lbl 016041 `"Irimbo"', add
label define geo2_mx2000_lbl 016042 `"Ixtlan"', add
label define geo2_mx2000_lbl 016043 `"Jacona"', add
label define geo2_mx2000_lbl 016044 `"Jimenez"', add
label define geo2_mx2000_lbl 016045 `"Jiquilpan"', add
label define geo2_mx2000_lbl 016046 `"Juarez"', add
label define geo2_mx2000_lbl 016047 `"Jungapeo"', add
label define geo2_mx2000_lbl 016048 `"Lagunillas"', add
label define geo2_mx2000_lbl 016049 `"Madero"', add
label define geo2_mx2000_lbl 016050 `"Maravatio"', add
label define geo2_mx2000_lbl 016051 `"Marcos Castellanos"', add
label define geo2_mx2000_lbl 016052 `"Lazaro Cardenas"', add
label define geo2_mx2000_lbl 016053 `"Morelia"', add
label define geo2_mx2000_lbl 016054 `"Morelos"', add
label define geo2_mx2000_lbl 016055 `"Mugica"', add
label define geo2_mx2000_lbl 016056 `"Nahuatzen"', add
label define geo2_mx2000_lbl 016057 `"Nocupetaro"', add
label define geo2_mx2000_lbl 016058 `"Nuevo Parangaricutiro"', add
label define geo2_mx2000_lbl 016059 `"Nuevo Urecho"', add
label define geo2_mx2000_lbl 016060 `"Numaran"', add
label define geo2_mx2000_lbl 016061 `"Ocampo"', add
label define geo2_mx2000_lbl 016062 `"Pajacuaran"', add
label define geo2_mx2000_lbl 016063 `"Panindicuaro"', add
label define geo2_mx2000_lbl 016064 `"Paracuaro"', add
label define geo2_mx2000_lbl 016065 `"Paracho"', add
label define geo2_mx2000_lbl 016066 `"Patzcuaro"', add
label define geo2_mx2000_lbl 016067 `"Penjamillo"', add
label define geo2_mx2000_lbl 016068 `"Periban"', add
label define geo2_mx2000_lbl 016069 `"Piedad, La"', add
label define geo2_mx2000_lbl 016070 `"Purepero"', add
label define geo2_mx2000_lbl 016071 `"Puruandiro"', add
label define geo2_mx2000_lbl 016072 `"Querendaro"', add
label define geo2_mx2000_lbl 016073 `"Quiroga"', add
label define geo2_mx2000_lbl 016074 `"Cojumatlan de Regules"', add
label define geo2_mx2000_lbl 016075 `"Reyes, Los"', add
label define geo2_mx2000_lbl 016076 `"Sahuayo"', add
label define geo2_mx2000_lbl 016077 `"San Lucas"', add
label define geo2_mx2000_lbl 016078 `"Santa Ana Maya"', add
label define geo2_mx2000_lbl 016079 `"Salvador Escalante"', add
label define geo2_mx2000_lbl 016080 `"Senguio"', add
label define geo2_mx2000_lbl 016081 `"Susupuato"', add
label define geo2_mx2000_lbl 016082 `"Tacambaro"', add
label define geo2_mx2000_lbl 016083 `"Tancitaro"', add
label define geo2_mx2000_lbl 016084 `"Tangamandapio"', add
label define geo2_mx2000_lbl 016085 `"Tangancicuaro"', add
label define geo2_mx2000_lbl 016086 `"Tanhuato"', add
label define geo2_mx2000_lbl 016087 `"Taretan"', add
label define geo2_mx2000_lbl 016088 `"Tarimbaro"', add
label define geo2_mx2000_lbl 016089 `"Tepalcatepec"', add
label define geo2_mx2000_lbl 016090 `"Tingambato"', add
label define geo2_mx2000_lbl 016091 `"Tinguindin"', add
label define geo2_mx2000_lbl 016092 `"Tiquicheo de Nicolas Romero"', add
label define geo2_mx2000_lbl 016093 `"Tlalpujahua"', add
label define geo2_mx2000_lbl 016094 `"Tlazazalca"', add
label define geo2_mx2000_lbl 016095 `"Tocumbo"', add
label define geo2_mx2000_lbl 016096 `"Tumbiscatio"', add
label define geo2_mx2000_lbl 016097 `"Turicato"', add
label define geo2_mx2000_lbl 016098 `"Tuxpan"', add
label define geo2_mx2000_lbl 016099 `"Tuzantla"', add
label define geo2_mx2000_lbl 016100 `"Tzintzuntzan"', add
label define geo2_mx2000_lbl 016101 `"Tzitzio"', add
label define geo2_mx2000_lbl 016102 `"Uruapan"', add
label define geo2_mx2000_lbl 016103 `"Venustiano Carranza"', add
label define geo2_mx2000_lbl 016104 `"Villamar"', add
label define geo2_mx2000_lbl 016105 `"Vista Hermosa"', add
label define geo2_mx2000_lbl 016106 `"Yurecuaro"', add
label define geo2_mx2000_lbl 016107 `"Zacapu"', add
label define geo2_mx2000_lbl 016108 `"Zamora"', add
label define geo2_mx2000_lbl 016109 `"Zinaparo"', add
label define geo2_mx2000_lbl 016110 `"Zinapecuaro"', add
label define geo2_mx2000_lbl 016111 `"Ziracuaretiro"', add
label define geo2_mx2000_lbl 016112 `"Zitacuaro"', add
label define geo2_mx2000_lbl 016113 `"Jose Sixto Verduzco"', add
label define geo2_mx2000_lbl 017001 `"Amacuzac"', add
label define geo2_mx2000_lbl 017002 `"Atlatlahucan"', add
label define geo2_mx2000_lbl 017003 `"Axochiapan"', add
label define geo2_mx2000_lbl 017004 `"Ayala"', add
label define geo2_mx2000_lbl 017005 `"Coatlan del Rio"', add
label define geo2_mx2000_lbl 017006 `"Cuautla"', add
label define geo2_mx2000_lbl 017007 `"Cuernavaca"', add
label define geo2_mx2000_lbl 017008 `"Emiliano Zapata"', add
label define geo2_mx2000_lbl 017009 `"Huitzilac"', add
label define geo2_mx2000_lbl 017010 `"Jantetelco"', add
label define geo2_mx2000_lbl 017011 `"Jiutepec"', add
label define geo2_mx2000_lbl 017012 `"Jojutla"', add
label define geo2_mx2000_lbl 017013 `"Jonacatepec"', add
label define geo2_mx2000_lbl 017014 `"Mazatepec"', add
label define geo2_mx2000_lbl 017015 `"Miacatlan"', add
label define geo2_mx2000_lbl 017016 `"Ocuituco"', add
label define geo2_mx2000_lbl 017017 `"Puente de Ixtla"', add
label define geo2_mx2000_lbl 017018 `"Temixco"', add
label define geo2_mx2000_lbl 017019 `"Tepalcingo"', add
label define geo2_mx2000_lbl 017020 `"Tepoztlan"', add
label define geo2_mx2000_lbl 017021 `"Tetecala"', add
label define geo2_mx2000_lbl 017022 `"Tetela del Volcan"', add
label define geo2_mx2000_lbl 017023 `"Tlalnepantla"', add
label define geo2_mx2000_lbl 017024 `"Tlaltizapan"', add
label define geo2_mx2000_lbl 017025 `"Tlaquiltenango"', add
label define geo2_mx2000_lbl 017026 `"Tlayacapan"', add
label define geo2_mx2000_lbl 017027 `"Totolapan"', add
label define geo2_mx2000_lbl 017028 `"Xochitepec"', add
label define geo2_mx2000_lbl 017029 `"Yautepec"', add
label define geo2_mx2000_lbl 017030 `"Yecapixtla"', add
label define geo2_mx2000_lbl 017031 `"Zacatepec de Hidalgo"', add
label define geo2_mx2000_lbl 017032 `"Zacualpan de Amilpas"', add
label define geo2_mx2000_lbl 017033 `"Temoac"', add
label define geo2_mx2000_lbl 018001 `"Acaponeta"', add
label define geo2_mx2000_lbl 018002 `"Ahuacatlan"', add
label define geo2_mx2000_lbl 018003 `"Amatlan de Canas"', add
label define geo2_mx2000_lbl 018004 `"Compostela"', add
label define geo2_mx2000_lbl 018005 `"Huajicori"', add
label define geo2_mx2000_lbl 018006 `"Ixtlan del Rio"', add
label define geo2_mx2000_lbl 018007 `"Jala"', add
label define geo2_mx2000_lbl 018008 `"Xalisco"', add
label define geo2_mx2000_lbl 018009 `"Del Nayar"', add
label define geo2_mx2000_lbl 018010 `"Rosamorada"', add
label define geo2_mx2000_lbl 018011 `"Ruiz"', add
label define geo2_mx2000_lbl 018012 `"San Blas"', add
label define geo2_mx2000_lbl 018013 `"San Pedro Lagunillas"', add
label define geo2_mx2000_lbl 018014 `"Santa Maria del Oro"', add
label define geo2_mx2000_lbl 018015 `"Santiago Ixcuintla"', add
label define geo2_mx2000_lbl 018016 `"Tecuala"', add
label define geo2_mx2000_lbl 018017 `"Tepic"', add
label define geo2_mx2000_lbl 018018 `"Tuxpan"', add
label define geo2_mx2000_lbl 018019 `"Yesca, La"', add
label define geo2_mx2000_lbl 018020 `"Bahia de Banderas"', add
label define geo2_mx2000_lbl 019001 `"Abasolo"', add
label define geo2_mx2000_lbl 019002 `"Agualeguas"', add
label define geo2_mx2000_lbl 019003 `"Aldamas, Los"', add
label define geo2_mx2000_lbl 019004 `"Allende"', add
label define geo2_mx2000_lbl 019005 `"Anahuac"', add
label define geo2_mx2000_lbl 019006 `"Apodaca"', add
label define geo2_mx2000_lbl 019007 `"Aramberri"', add
label define geo2_mx2000_lbl 019008 `"Bustamante"', add
label define geo2_mx2000_lbl 019009 `"Cadereyta Jimenez"', add
label define geo2_mx2000_lbl 019010 `"Carmen"', add
label define geo2_mx2000_lbl 019011 `"Cerralvo"', add
label define geo2_mx2000_lbl 019012 `"Cienega de Flores"', add
label define geo2_mx2000_lbl 019013 `"China"', add
label define geo2_mx2000_lbl 019014 `"Doctor Arroyo"', add
label define geo2_mx2000_lbl 019015 `"Doctor Coss"', add
label define geo2_mx2000_lbl 019016 `"Doctor Gonzalez"', add
label define geo2_mx2000_lbl 019017 `"Galeana"', add
label define geo2_mx2000_lbl 019018 `"Garcia"', add
label define geo2_mx2000_lbl 019019 `"San Pedro Garza Garcia"', add
label define geo2_mx2000_lbl 019020 `"General Bravo"', add
label define geo2_mx2000_lbl 019021 `"General Escobedo"', add
label define geo2_mx2000_lbl 019022 `"General Teran"', add
label define geo2_mx2000_lbl 019023 `"General Trevino"', add
label define geo2_mx2000_lbl 019024 `"General Zaragoza"', add
label define geo2_mx2000_lbl 019025 `"General Zuazua"', add
label define geo2_mx2000_lbl 019026 `"Guadalupe"', add
label define geo2_mx2000_lbl 019027 `"Herreras, Los"', add
label define geo2_mx2000_lbl 019028 `"Higueras"', add
label define geo2_mx2000_lbl 019029 `"Hualahuises"', add
label define geo2_mx2000_lbl 019030 `"Iturbide"', add
label define geo2_mx2000_lbl 019031 `"Juarez"', add
label define geo2_mx2000_lbl 019032 `"Lampazos de Naranjo"', add
label define geo2_mx2000_lbl 019033 `"Linares"', add
label define geo2_mx2000_lbl 019034 `"Marin"', add
label define geo2_mx2000_lbl 019035 `"Melchor Ocampo"', add
label define geo2_mx2000_lbl 019036 `"Mier y Noriega"', add
label define geo2_mx2000_lbl 019037 `"Mina"', add
label define geo2_mx2000_lbl 019038 `"Montemorelos"', add
label define geo2_mx2000_lbl 019039 `"Monterrey"', add
label define geo2_mx2000_lbl 019040 `"Paras"', add
label define geo2_mx2000_lbl 019041 `"Pesqueria"', add
label define geo2_mx2000_lbl 019042 `"Ramones, Los"', add
label define geo2_mx2000_lbl 019043 `"Rayones"', add
label define geo2_mx2000_lbl 019044 `"Sabinas Hidalgo"', add
label define geo2_mx2000_lbl 019045 `"Salinas Victoria"', add
label define geo2_mx2000_lbl 019046 `"San Nicolas de los Garza"', add
label define geo2_mx2000_lbl 019047 `"Hidalgo"', add
label define geo2_mx2000_lbl 019048 `"Santa Catarina"', add
label define geo2_mx2000_lbl 019049 `"Santiago"', add
label define geo2_mx2000_lbl 019050 `"Vallecillo"', add
label define geo2_mx2000_lbl 019051 `"Villaldama"', add
label define geo2_mx2000_lbl 020001 `"Abejones"', add
label define geo2_mx2000_lbl 020002 `"Acatlan de Perez Figueroa"', add
label define geo2_mx2000_lbl 020003 `"Asuncion Cacalotepec"', add
label define geo2_mx2000_lbl 020004 `"Asuncion Cuyotepeji"', add
label define geo2_mx2000_lbl 020005 `"Asuncion Ixtaltepec"', add
label define geo2_mx2000_lbl 020006 `"Asuncion Nochixtlan"', add
label define geo2_mx2000_lbl 020007 `"Asuncion Ocotlan"', add
label define geo2_mx2000_lbl 020008 `"Asuncion Tlacolulita"', add
label define geo2_mx2000_lbl 020009 `"Ayotzintepec"', add
label define geo2_mx2000_lbl 020010 `"Barrio de la Soledad, El"', add
label define geo2_mx2000_lbl 020011 `"Calihuala"', add
label define geo2_mx2000_lbl 020012 `"Candelaria Loxicha"', add
label define geo2_mx2000_lbl 020013 `"Cienega de Zimatlan"', add
label define geo2_mx2000_lbl 020014 `"Ciudad Ixtepec"', add
label define geo2_mx2000_lbl 020015 `"Coatecas Altas"', add
label define geo2_mx2000_lbl 020016 `"Coicoyan de las Flores"', add
label define geo2_mx2000_lbl 020017 `"Compania, La"', add
label define geo2_mx2000_lbl 020018 `"Concepcion Buenavista"', add
label define geo2_mx2000_lbl 020019 `"Concepcion Papalo"', add
label define geo2_mx2000_lbl 020020 `"Constancia del Rosario"', add
label define geo2_mx2000_lbl 020021 `"Cosolapa"', add
label define geo2_mx2000_lbl 020022 `"Cosoltepec"', add
label define geo2_mx2000_lbl 020023 `"Cuilapam de Guerrero"', add
label define geo2_mx2000_lbl 020024 `"Cuyamecalco Villa de Zaragoza"', add
label define geo2_mx2000_lbl 020025 `"Chahuites"', add
label define geo2_mx2000_lbl 020026 `"Chalcatongo de Hidalgo"', add
label define geo2_mx2000_lbl 020027 `"Chiquihuitlan de Benito Juarez"', add
label define geo2_mx2000_lbl 020028 `"Heroica Ciudad de Ejutla de Crespo"', add
label define geo2_mx2000_lbl 020029 `"Eloxochitlan de Flores Magon"', add
label define geo2_mx2000_lbl 020030 `"Espinal, El"', add
label define geo2_mx2000_lbl 020031 `"Tamazulapam del Espiritu Santo"', add
label define geo2_mx2000_lbl 020032 `"Fresnillo de Trujano"', add
label define geo2_mx2000_lbl 020033 `"Guadalupe Etla"', add
label define geo2_mx2000_lbl 020034 `"Guadalupe de Ramirez"', add
label define geo2_mx2000_lbl 020035 `"Guelatao de Juarez"', add
label define geo2_mx2000_lbl 020036 `"Guevea de Humboldt"', add
label define geo2_mx2000_lbl 020037 `"Mesones Hidalgo"', add
label define geo2_mx2000_lbl 020038 `"Villa Hidalgo"', add
label define geo2_mx2000_lbl 020039 `"Heroica Ciudad de Huajuapan de Leon"', add
label define geo2_mx2000_lbl 020040 `"Huautepec"', add
label define geo2_mx2000_lbl 020041 `"Huautla de Jimenez"', add
label define geo2_mx2000_lbl 020042 `"Ixtlan de Juarez"', add
label define geo2_mx2000_lbl 020043 `"Juchitan de Zaragoza"', add
label define geo2_mx2000_lbl 020044 `"Loma Bonita"', add
label define geo2_mx2000_lbl 020045 `"Magdalena Apasco"', add
label define geo2_mx2000_lbl 020046 `"Magdalena Jaltepec"', add
label define geo2_mx2000_lbl 020047 `"Santa Magdalena Jicotlan"', add
label define geo2_mx2000_lbl 020048 `"Magdalena Mixtepec"', add
label define geo2_mx2000_lbl 020049 `"Magdalena Ocotlan"', add
label define geo2_mx2000_lbl 020050 `"Magdalena Penasco"', add
label define geo2_mx2000_lbl 020051 `"Magdalena Teitipac"', add
label define geo2_mx2000_lbl 020052 `"Magdalena Tequisistlan"', add
label define geo2_mx2000_lbl 020053 `"Magdalena Tlacotepec"', add
label define geo2_mx2000_lbl 020054 `"Magdalena Zahuatlan"', add
label define geo2_mx2000_lbl 020055 `"Mariscala de Juarez"', add
label define geo2_mx2000_lbl 020056 `"Martires de Tacubaya"', add
label define geo2_mx2000_lbl 020057 `"Matias Romero"', add
label define geo2_mx2000_lbl 020058 `"Mazatlan Villa de Flores"', add
label define geo2_mx2000_lbl 020059 `"Miahuatlan de Porfirio Diaz"', add
label define geo2_mx2000_lbl 020060 `"Mixistlan de la Reforma"', add
label define geo2_mx2000_lbl 020061 `"Monjas"', add
label define geo2_mx2000_lbl 020062 `"Natividad"', add
label define geo2_mx2000_lbl 020063 `"Nazareno Etla"', add
label define geo2_mx2000_lbl 020064 `"Nejapa de Madero"', add
label define geo2_mx2000_lbl 020065 `"Ixpantepec Nieves"', add
label define geo2_mx2000_lbl 020066 `"Santiago Niltepec"', add
label define geo2_mx2000_lbl 020067 `"Oaxaca de Juarez"', add
label define geo2_mx2000_lbl 020068 `"Ocotlan de Morelos"', add
label define geo2_mx2000_lbl 020069 `"Pe, La"', add
label define geo2_mx2000_lbl 020070 `"Pinotepa de Don Luis"', add
label define geo2_mx2000_lbl 020071 `"Pluma Hidalgo"', add
label define geo2_mx2000_lbl 020072 `"San Jose del Progreso"', add
label define geo2_mx2000_lbl 020073 `"Putla Villa de Guerrero"', add
label define geo2_mx2000_lbl 020074 `"Santa Catarina Quioquitani"', add
label define geo2_mx2000_lbl 020075 `"Reforma de Pineda"', add
label define geo2_mx2000_lbl 020076 `"Reforma, La"', add
label define geo2_mx2000_lbl 020077 `"Reyes Etla"', add
label define geo2_mx2000_lbl 020078 `"Rojas de Cuauhtemoc"', add
label define geo2_mx2000_lbl 020079 `"Salina Cruz"', add
label define geo2_mx2000_lbl 020080 `"San Agustin Amatengo"', add
label define geo2_mx2000_lbl 020081 `"San Agustin Atenango"', add
label define geo2_mx2000_lbl 020082 `"San Agustin Chayuco"', add
label define geo2_mx2000_lbl 020083 `"San Agustin de las Juntas"', add
label define geo2_mx2000_lbl 020084 `"San Agustin Etla"', add
label define geo2_mx2000_lbl 020085 `"San Agustin Loxicha"', add
label define geo2_mx2000_lbl 020086 `"San Agustin Tlacotepec"', add
label define geo2_mx2000_lbl 020087 `"San Agustin Yatareni"', add
label define geo2_mx2000_lbl 020088 `"San Andres Cabecera Nueva"', add
label define geo2_mx2000_lbl 020089 `"San Andres Dinicuiti"', add
label define geo2_mx2000_lbl 020090 `"San Andres Huaxpaltepec"', add
label define geo2_mx2000_lbl 020091 `"San Andres Huayapam"', add
label define geo2_mx2000_lbl 020092 `"San Andres Ixtlahuaca"', add
label define geo2_mx2000_lbl 020093 `"San Andres Lagunas"', add
label define geo2_mx2000_lbl 020094 `"San Andres Nuxino"', add
label define geo2_mx2000_lbl 020095 `"San Andres Paxtlan"', add
label define geo2_mx2000_lbl 020096 `"San Andres Sinaxtla"', add
label define geo2_mx2000_lbl 020097 `"San Andres Solaga"', add
label define geo2_mx2000_lbl 020098 `"San Andres Teotilalpam"', add
label define geo2_mx2000_lbl 020099 `"San Andres Tepetlapa"', add
label define geo2_mx2000_lbl 020100 `"San Andres Yaa"', add
label define geo2_mx2000_lbl 020101 `"San Andres Zabache"', add
label define geo2_mx2000_lbl 020102 `"San Andres Zautla"', add
label define geo2_mx2000_lbl 020103 `"San Antonino Castillo Velasco"', add
label define geo2_mx2000_lbl 020104 `"San Antonino el Alto"', add
label define geo2_mx2000_lbl 020105 `"San Antonino Monte Verde"', add
label define geo2_mx2000_lbl 020106 `"San Antonio Acutla"', add
label define geo2_mx2000_lbl 020107 `"San Antonio de la Cal"', add
label define geo2_mx2000_lbl 020108 `"San Antonio Huitepec"', add
label define geo2_mx2000_lbl 020109 `"San Antonio Nanahuatipam"', add
label define geo2_mx2000_lbl 020110 `"San Antonio Sinicahua"', add
label define geo2_mx2000_lbl 020111 `"San Antonio Tepetlapa"', add
label define geo2_mx2000_lbl 020112 `"San Baltazar Chichicapam"', add
label define geo2_mx2000_lbl 020113 `"San Baltazar Loxicha"', add
label define geo2_mx2000_lbl 020114 `"San Baltazar Yatzachi el Bajo"', add
label define geo2_mx2000_lbl 020115 `"San Bartolo Coyotepec"', add
label define geo2_mx2000_lbl 020116 `"San Bartolome Ayautla"', add
label define geo2_mx2000_lbl 020117 `"San Bartolome Loxicha"', add
label define geo2_mx2000_lbl 020118 `"San Bartolome Quialana"', add
label define geo2_mx2000_lbl 020119 `"San Bartolome Yucuane"', add
label define geo2_mx2000_lbl 020120 `"San Bartolome Zoogocho"', add
label define geo2_mx2000_lbl 020121 `"San Bartolo Soyaltepec"', add
label define geo2_mx2000_lbl 020122 `"San Bartolo Yautepec"', add
label define geo2_mx2000_lbl 020123 `"San Bernardo Mixtepec"', add
label define geo2_mx2000_lbl 020124 `"San Blas Atempa"', add
label define geo2_mx2000_lbl 020125 `"San Carlos Yautepec"', add
label define geo2_mx2000_lbl 020126 `"San Cristobal Amatlan"', add
label define geo2_mx2000_lbl 020127 `"San Cristobal Amoltepec"', add
label define geo2_mx2000_lbl 020128 `"San Cristobal Lachirioag"', add
label define geo2_mx2000_lbl 020129 `"San Cristobal Suchixtlahuaca"', add
label define geo2_mx2000_lbl 020130 `"San Dionisio del Mar"', add
label define geo2_mx2000_lbl 020131 `"San Dionisio Ocotepec"', add
label define geo2_mx2000_lbl 020132 `"San Dionisio Ocotlan"', add
label define geo2_mx2000_lbl 020133 `"San Esteban Atatlahuca"', add
label define geo2_mx2000_lbl 020134 `"San Felipe Jalapa de Diaz"', add
label define geo2_mx2000_lbl 020135 `"San Felipe Tejalapam"', add
label define geo2_mx2000_lbl 020136 `"San Felipe Usila"', add
label define geo2_mx2000_lbl 020137 `"San Francisco Cahuacua"', add
label define geo2_mx2000_lbl 020138 `"San Francisco Cajonos"', add
label define geo2_mx2000_lbl 020139 `"San Francisco Chapulapa"', add
label define geo2_mx2000_lbl 020140 `"San Francisco Chindua"', add
label define geo2_mx2000_lbl 020141 `"San Francisco del Mar"', add
label define geo2_mx2000_lbl 020142 `"San Francisco Huehuetlan"', add
label define geo2_mx2000_lbl 020143 `"San Francisco Ixhuatan"', add
label define geo2_mx2000_lbl 020144 `"San Francisco Jaltepetongo"', add
label define geo2_mx2000_lbl 020145 `"San Francisco Lachigolo"', add
label define geo2_mx2000_lbl 020146 `"San Francisco Logueche"', add
label define geo2_mx2000_lbl 020147 `"San Francisco Nuxano"', add
label define geo2_mx2000_lbl 020148 `"San Francisco Ozolotepec"', add
label define geo2_mx2000_lbl 020149 `"San Francisco Sola"', add
label define geo2_mx2000_lbl 020150 `"San Francisco Telixtlahuaca"', add
label define geo2_mx2000_lbl 020151 `"San Francisco Teopan"', add
label define geo2_mx2000_lbl 020152 `"San Francisco Tlapancingo"', add
label define geo2_mx2000_lbl 020153 `"San Gabriel Mixtepec"', add
label define geo2_mx2000_lbl 020154 `"San Ildefonso Amatlan"', add
label define geo2_mx2000_lbl 020155 `"San Ildefonso Sola"', add
label define geo2_mx2000_lbl 020156 `"San Ildefonso Villa Alta"', add
label define geo2_mx2000_lbl 020157 `"San Jacinto Amilpas"', add
label define geo2_mx2000_lbl 020158 `"San Jacinto Tlacotepec"', add
label define geo2_mx2000_lbl 020159 `"San Jeronimo Coatlan"', add
label define geo2_mx2000_lbl 020160 `"San Jeronimo Silacayoapilla"', add
label define geo2_mx2000_lbl 020161 `"San Jeronimo Sosola"', add
label define geo2_mx2000_lbl 020162 `"San Jeronimo Taviche"', add
label define geo2_mx2000_lbl 020163 `"San Jeronimo Tecoatl"', add
label define geo2_mx2000_lbl 020164 `"San Jorge Nuchita"', add
label define geo2_mx2000_lbl 020165 `"San Jose Ayuquila"', add
label define geo2_mx2000_lbl 020166 `"San Jose Chiltepec"', add
label define geo2_mx2000_lbl 020167 `"San Jose del Penasco"', add
label define geo2_mx2000_lbl 020168 `"San Jose Estancia Grande"', add
label define geo2_mx2000_lbl 020169 `"San Jose Independencia"', add
label define geo2_mx2000_lbl 020170 `"San Jose Lachiguiri"', add
label define geo2_mx2000_lbl 020171 `"San Jose Tenango"', add
label define geo2_mx2000_lbl 020172 `"San Juan Achiutla"', add
label define geo2_mx2000_lbl 020173 `"San Juan Atepec"', add
label define geo2_mx2000_lbl 020174 `"Animas Trujano"', add
label define geo2_mx2000_lbl 020175 `"San Juan Bautista Atatlahuca"', add
label define geo2_mx2000_lbl 020176 `"San Juan Bautista Coixtlahuaca"', add
label define geo2_mx2000_lbl 020177 `"San Juan Bautista Cuicatlan"', add
label define geo2_mx2000_lbl 020178 `"San Juan Bautista Guelache"', add
label define geo2_mx2000_lbl 020179 `"San Juan Bautista Jayacatlan"', add
label define geo2_mx2000_lbl 020180 `"San Juan Bautista lo de Soto"', add
label define geo2_mx2000_lbl 020181 `"San Juan Bautista Suchitepec"', add
label define geo2_mx2000_lbl 020182 `"San Juan Bautista Tlacoatzintepec"', add
label define geo2_mx2000_lbl 020183 `"San Juan Bautista Tlachichilco"', add
label define geo2_mx2000_lbl 020184 `"San Juan Bautista Tuxtepec"', add
label define geo2_mx2000_lbl 020185 `"San Juan Cacahuatepec"', add
label define geo2_mx2000_lbl 020186 `"San Juan Cieneguilla"', add
label define geo2_mx2000_lbl 020187 `"San Juan Coatzospam"', add
label define geo2_mx2000_lbl 020188 `"San Juan Colorado"', add
label define geo2_mx2000_lbl 020189 `"San Juan Comaltepec"', add
label define geo2_mx2000_lbl 020190 `"San Juan Cotzocon"', add
label define geo2_mx2000_lbl 020191 `"San Juan Chicomezuchil"', add
label define geo2_mx2000_lbl 020192 `"San Juan Chilateca"', add
label define geo2_mx2000_lbl 020193 `"San Juan del Estado"', add
label define geo2_mx2000_lbl 020194 `"San Juan del Rio"', add
label define geo2_mx2000_lbl 020195 `"San Juan Diuxi"', add
label define geo2_mx2000_lbl 020196 `"San Juan Evangelista Analco"', add
label define geo2_mx2000_lbl 020197 `"San Juan Guelavia"', add
label define geo2_mx2000_lbl 020198 `"San Juan Guichicovi"', add
label define geo2_mx2000_lbl 020199 `"San Juan Ihualtepec"', add
label define geo2_mx2000_lbl 020200 `"San Juan Juquila Mixes"', add
label define geo2_mx2000_lbl 020201 `"San Juan Juquila Vijanos"', add
label define geo2_mx2000_lbl 020202 `"San Juan Lachao"', add
label define geo2_mx2000_lbl 020203 `"San Juan Lachigalla"', add
label define geo2_mx2000_lbl 020204 `"San Juan Lajarcia"', add
label define geo2_mx2000_lbl 020205 `"San Juan Lalana"', add
label define geo2_mx2000_lbl 020206 `"San Juan de los Cues"', add
label define geo2_mx2000_lbl 020207 `"San Juan Mazatlan"', add
label define geo2_mx2000_lbl 020208 `"San Juan Mixtepec - distr. 08"', add
label define geo2_mx2000_lbl 020209 `"San Juan Mixtepec - distr. 26"', add
label define geo2_mx2000_lbl 020210 `"San Juan Numi"', add
label define geo2_mx2000_lbl 020211 `"San Juan Ozolotepec"', add
label define geo2_mx2000_lbl 020212 `"San Juan Petlapa"', add
label define geo2_mx2000_lbl 020213 `"San Juan Quiahije"', add
label define geo2_mx2000_lbl 020214 `"San Juan Quiotepec"', add
label define geo2_mx2000_lbl 020215 `"San Juan Sayultepec"', add
label define geo2_mx2000_lbl 020216 `"San Juan Tabaa"', add
label define geo2_mx2000_lbl 020217 `"San Juan Tamazola"', add
label define geo2_mx2000_lbl 020218 `"San Juan Teita"', add
label define geo2_mx2000_lbl 020219 `"San Juan Teitipac"', add
label define geo2_mx2000_lbl 020220 `"San Juan Tepeuxila"', add
label define geo2_mx2000_lbl 020221 `"San Juan Teposcolula"', add
label define geo2_mx2000_lbl 020222 `"San Juan Yaee"', add
label define geo2_mx2000_lbl 020223 `"San Juan Yatzona"', add
label define geo2_mx2000_lbl 020224 `"San Juan Yucuita"', add
label define geo2_mx2000_lbl 020225 `"San Lorenzo"', add
label define geo2_mx2000_lbl 020226 `"San Lorenzo Albarradas"', add
label define geo2_mx2000_lbl 020227 `"San Lorenzo Cacaotepec"', add
label define geo2_mx2000_lbl 020228 `"San Lorenzo Cuaunecuiltitla"', add
label define geo2_mx2000_lbl 020229 `"San Lorenzo Texmelucan"', add
label define geo2_mx2000_lbl 020230 `"San Lorenzo Victoria"', add
label define geo2_mx2000_lbl 020231 `"San Lucas Camotlan"', add
label define geo2_mx2000_lbl 020232 `"San Lucas Ojitlan"', add
label define geo2_mx2000_lbl 020233 `"San Lucas Quiavini"', add
label define geo2_mx2000_lbl 020234 `"San Lucas Zoquiapam"', add
label define geo2_mx2000_lbl 020235 `"San Luis Amatlan"', add
label define geo2_mx2000_lbl 020236 `"San Marcial Ozolotepec"', add
label define geo2_mx2000_lbl 020237 `"San Marcos Arteaga"', add
label define geo2_mx2000_lbl 020238 `"San Martin de los Cansecos"', add
label define geo2_mx2000_lbl 020239 `"San Martin Huamelulpam"', add
label define geo2_mx2000_lbl 020240 `"San Martin Itunyoso"', add
label define geo2_mx2000_lbl 020241 `"San Martin Lachila"', add
label define geo2_mx2000_lbl 020242 `"San Martin Peras"', add
label define geo2_mx2000_lbl 020243 `"San Martin Tilcajete"', add
label define geo2_mx2000_lbl 020244 `"San Martin Toxpalan"', add
label define geo2_mx2000_lbl 020245 `"San Martin Zacatepec"', add
label define geo2_mx2000_lbl 020246 `"San Mateo Cajonos"', add
label define geo2_mx2000_lbl 020247 `"Capulalpam de Mendez"', add
label define geo2_mx2000_lbl 020248 `"San Mateo del Mar"', add
label define geo2_mx2000_lbl 020249 `"San Mateo Yoloxochitlan"', add
label define geo2_mx2000_lbl 020250 `"San Mateo Etlatongo"', add
label define geo2_mx2000_lbl 020251 `"San Mateo Nejapam"', add
label define geo2_mx2000_lbl 020252 `"San Mateo Penasco"', add
label define geo2_mx2000_lbl 020253 `"San Mateo Pinas"', add
label define geo2_mx2000_lbl 020254 `"San Mateo Rio Hondo"', add
label define geo2_mx2000_lbl 020255 `"San Mateo Sindihui"', add
label define geo2_mx2000_lbl 020256 `"San Mateo Tlapiltepec"', add
label define geo2_mx2000_lbl 020257 `"San Melchor Betaza"', add
label define geo2_mx2000_lbl 020258 `"San Miguel Achiutla"', add
label define geo2_mx2000_lbl 020259 `"San Miguel Ahuehuetitlan"', add
label define geo2_mx2000_lbl 020260 `"San Miguel Aloapam"', add
label define geo2_mx2000_lbl 020261 `"San Miguel Amatitlan"', add
label define geo2_mx2000_lbl 020262 `"San Miguel Amatlan"', add
label define geo2_mx2000_lbl 020263 `"San Miguel Coatlan"', add
label define geo2_mx2000_lbl 020264 `"San Miguel Chicahua"', add
label define geo2_mx2000_lbl 020265 `"San Miguel Chimalapa"', add
label define geo2_mx2000_lbl 020266 `"San Miguel del Puerto"', add
label define geo2_mx2000_lbl 020267 `"San Miguel del Rio"', add
label define geo2_mx2000_lbl 020268 `"San Miguel Ejutla"', add
label define geo2_mx2000_lbl 020269 `"San Miguel el Grande"', add
label define geo2_mx2000_lbl 020270 `"San Miguel Huautla"', add
label define geo2_mx2000_lbl 020271 `"San Miguel Mixtepec"', add
label define geo2_mx2000_lbl 020272 `"San Miguel Panixtlahuaca"', add
label define geo2_mx2000_lbl 020273 `"San Miguel Peras"', add
label define geo2_mx2000_lbl 020274 `"San Miguel Piedras"', add
label define geo2_mx2000_lbl 020275 `"San Miguel Quetzaltepec"', add
label define geo2_mx2000_lbl 020276 `"San Miguel Santa Flor"', add
label define geo2_mx2000_lbl 020277 `"Villa Sola de Vega"', add
label define geo2_mx2000_lbl 020278 `"San Miguel Soyaltepec"', add
label define geo2_mx2000_lbl 020279 `"San Miguel Suchixtepec"', add
label define geo2_mx2000_lbl 020280 `"Villa Talea de Castro"', add
label define geo2_mx2000_lbl 020281 `"San Miguel Tecomatlan"', add
label define geo2_mx2000_lbl 020282 `"San Miguel Tenango"', add
label define geo2_mx2000_lbl 020283 `"San Miguel Tequixtepec"', add
label define geo2_mx2000_lbl 020284 `"San Miguel Tilquiapam"', add
label define geo2_mx2000_lbl 020285 `"San Miguel Tlacamama"', add
label define geo2_mx2000_lbl 020286 `"San Miguel Tlacotepec"', add
label define geo2_mx2000_lbl 020287 `"San Miguel Tulancingo"', add
label define geo2_mx2000_lbl 020288 `"San Miguel Yotao"', add
label define geo2_mx2000_lbl 020289 `"San Nicolas"', add
label define geo2_mx2000_lbl 020290 `"San Nicolas Hidalgo"', add
label define geo2_mx2000_lbl 020291 `"San Pablo Coatlan"', add
label define geo2_mx2000_lbl 020292 `"San Pablo Cuatro Venados"', add
label define geo2_mx2000_lbl 020293 `"San Pablo Etla"', add
label define geo2_mx2000_lbl 020294 `"San Pablo Huitzo"', add
label define geo2_mx2000_lbl 020295 `"San Pablo Huixtepec"', add
label define geo2_mx2000_lbl 020296 `"San Pablo Macuiltianguis"', add
label define geo2_mx2000_lbl 020297 `"San Pablo Tijaltepec"', add
label define geo2_mx2000_lbl 020298 `"San Pablo Villa de Mitla"', add
label define geo2_mx2000_lbl 020299 `"San Pablo Yaganiza"', add
label define geo2_mx2000_lbl 020300 `"San Pedro Amuzgos"', add
label define geo2_mx2000_lbl 020301 `"San Pedro Apostol"', add
label define geo2_mx2000_lbl 020302 `"San Pedro Atoyac"', add
label define geo2_mx2000_lbl 020303 `"San Pedro Cajonos"', add
label define geo2_mx2000_lbl 020304 `"San Pedro Coxcaltepec Cantaros"', add
label define geo2_mx2000_lbl 020305 `"San Pedro Comitancillo"', add
label define geo2_mx2000_lbl 020306 `"San Pedro el Alto"', add
label define geo2_mx2000_lbl 020307 `"San Pedro Huamelula"', add
label define geo2_mx2000_lbl 020308 `"San Pedro Huilotepec"', add
label define geo2_mx2000_lbl 020309 `"San Pedro Ixcatlan"', add
label define geo2_mx2000_lbl 020310 `"San Pedro Ixtlahuaca"', add
label define geo2_mx2000_lbl 020311 `"San Pedro Jaltepetongo"', add
label define geo2_mx2000_lbl 020312 `"San Pedro Jicayan"', add
label define geo2_mx2000_lbl 020313 `"San Pedro Jocotipac"', add
label define geo2_mx2000_lbl 020314 `"San Pedro Juchatengo"', add
label define geo2_mx2000_lbl 020315 `"San Pedro Martir"', add
label define geo2_mx2000_lbl 020316 `"San Pedro Martir Quiechapa"', add
label define geo2_mx2000_lbl 020317 `"San Pedro Martir Yucuxaco"', add
label define geo2_mx2000_lbl 020318 `"San Pedro Mixtepec - distr. 22"', add
label define geo2_mx2000_lbl 020319 `"San Pedro Mixtepec - distr. 26"', add
label define geo2_mx2000_lbl 020320 `"San Pedro Molinos"', add
label define geo2_mx2000_lbl 020321 `"San Pedro Nopala"', add
label define geo2_mx2000_lbl 020322 `"San Pedro Ocopetatillo"', add
label define geo2_mx2000_lbl 020323 `"San Pedro Ocotepec"', add
label define geo2_mx2000_lbl 020324 `"San Pedro Pochutla"', add
label define geo2_mx2000_lbl 020325 `"San Pedro Quiatoni"', add
label define geo2_mx2000_lbl 020326 `"San Pedro Sochiapam"', add
label define geo2_mx2000_lbl 020327 `"San Pedro Tapanatepec"', add
label define geo2_mx2000_lbl 020328 `"San Pedro Taviche"', add
label define geo2_mx2000_lbl 020329 `"San Pedro Teozacoalco"', add
label define geo2_mx2000_lbl 020330 `"San Pedro Teutila"', add
label define geo2_mx2000_lbl 020331 `"San Pedro Tidaa"', add
label define geo2_mx2000_lbl 020332 `"San Pedro Topiltepec"', add
label define geo2_mx2000_lbl 020333 `"San Pedro Totolapa"', add
label define geo2_mx2000_lbl 020334 `"Villa de Tututepec de Melchor Ocampo"', add
label define geo2_mx2000_lbl 020335 `"San Pedro Yaneri"', add
label define geo2_mx2000_lbl 020336 `"San Pedro Yolox"', add
label define geo2_mx2000_lbl 020337 `"San Pedro y San Pablo Ayutla"', add
label define geo2_mx2000_lbl 020338 `"Villa de Etla"', add
label define geo2_mx2000_lbl 020339 `"San Pedro y San Pablo Teposcolula"', add
label define geo2_mx2000_lbl 020340 `"San Pedro y San Pablo Tequixtepec"', add
label define geo2_mx2000_lbl 020341 `"San Pedro Yucunama"', add
label define geo2_mx2000_lbl 020342 `"San Raymundo Jalpan"', add
label define geo2_mx2000_lbl 020343 `"San Sebastian Abasolo"', add
label define geo2_mx2000_lbl 020344 `"San Sebastian Coatlan"', add
label define geo2_mx2000_lbl 020345 `"San Sebastian Ixcapa"', add
label define geo2_mx2000_lbl 020346 `"San Sebastian Nicananduta"', add
label define geo2_mx2000_lbl 020347 `"San Sebastian Rio Hondo"', add
label define geo2_mx2000_lbl 020348 `"San Sebastian Tecomaxtlahuaca"', add
label define geo2_mx2000_lbl 020349 `"San Sebastian Teitipac"', add
label define geo2_mx2000_lbl 020350 `"San Sebastian Tutla"', add
label define geo2_mx2000_lbl 020351 `"San Simon Almolongas"', add
label define geo2_mx2000_lbl 020352 `"San Simon Zahuatlan"', add
label define geo2_mx2000_lbl 020353 `"Santa Ana"', add
label define geo2_mx2000_lbl 020354 `"Santa Ana Ateixtlahuaca"', add
label define geo2_mx2000_lbl 020355 `"Santa Ana Cuauhtemoc"', add
label define geo2_mx2000_lbl 020356 `"Santa Ana del Valle"', add
label define geo2_mx2000_lbl 020357 `"Santa Ana Tavela"', add
label define geo2_mx2000_lbl 020358 `"Santa Ana Tlapacoyan"', add
label define geo2_mx2000_lbl 020359 `"Santa Ana Yareni"', add
label define geo2_mx2000_lbl 020360 `"Santa Ana Zegache"', add
label define geo2_mx2000_lbl 020361 `"Santa Catalina Quieri"', add
label define geo2_mx2000_lbl 020362 `"Santa Catarina Cuixtla"', add
label define geo2_mx2000_lbl 020363 `"Santa Catarina Ixtepeji"', add
label define geo2_mx2000_lbl 020364 `"Santa Catarina Juquila"', add
label define geo2_mx2000_lbl 020365 `"Santa Catarina Lachatao"', add
label define geo2_mx2000_lbl 020366 `"Santa Catarina Loxicha"', add
label define geo2_mx2000_lbl 020367 `"Santa Catarina Mechoacan"', add
label define geo2_mx2000_lbl 020368 `"Santa Catarina Minas"', add
label define geo2_mx2000_lbl 020369 `"Santa Catarina Quiane"', add
label define geo2_mx2000_lbl 020370 `"Santa Catarina Tayata"', add
label define geo2_mx2000_lbl 020371 `"Santa Catarina Ticua"', add
label define geo2_mx2000_lbl 020372 `"Santa Catarina Yosonotu"', add
label define geo2_mx2000_lbl 020373 `"Santa Catarina Zapoquila"', add
label define geo2_mx2000_lbl 020374 `"Santa Cruz Acatepec"', add
label define geo2_mx2000_lbl 020375 `"Santa Cruz Amilpas"', add
label define geo2_mx2000_lbl 020376 `"Santa Cruz de Bravo"', add
label define geo2_mx2000_lbl 020377 `"Santa Cruz Itundujia"', add
label define geo2_mx2000_lbl 020378 `"Santa Cruz Mixtepec"', add
label define geo2_mx2000_lbl 020379 `"Santa Cruz Nundaco"', add
label define geo2_mx2000_lbl 020380 `"Santa Cruz Papalutla"', add
label define geo2_mx2000_lbl 020381 `"Santa Cruz Tacache de Mina"', add
label define geo2_mx2000_lbl 020382 `"Santa Cruz Tacahua"', add
label define geo2_mx2000_lbl 020383 `"Santa Cruz Tayata"', add
label define geo2_mx2000_lbl 020384 `"Santa Cruz Xitla"', add
label define geo2_mx2000_lbl 020385 `"Santa Cruz Xoxocotlan"', add
label define geo2_mx2000_lbl 020386 `"Santa Cruz Zenzontepec"', add
label define geo2_mx2000_lbl 020387 `"Santa Gertrudis"', add
label define geo2_mx2000_lbl 020388 `"Santa Ines del Monte"', add
label define geo2_mx2000_lbl 020389 `"Santa Ines Yatzeche"', add
label define geo2_mx2000_lbl 020390 `"Santa Lucia del Camino"', add
label define geo2_mx2000_lbl 020391 `"Santa Lucia Miahuatlan"', add
label define geo2_mx2000_lbl 020392 `"Santa Lucia Monteverde"', add
label define geo2_mx2000_lbl 020393 `"Santa Lucia Ocotlan"', add
label define geo2_mx2000_lbl 020394 `"Santa Maria Alotepec"', add
label define geo2_mx2000_lbl 020395 `"Santa Maria Apazco"', add
label define geo2_mx2000_lbl 020396 `"Santa Maria la Asuncion"', add
label define geo2_mx2000_lbl 020397 `"Heroica Ciudad de Tlaxiaco"', add
label define geo2_mx2000_lbl 020398 `"Ayoquezco de Aldama"', add
label define geo2_mx2000_lbl 020399 `"Santa Maria Atzompa"', add
label define geo2_mx2000_lbl 020400 `"Santa Maria Camotlan"', add
label define geo2_mx2000_lbl 020401 `"Santa Maria Colotepec"', add
label define geo2_mx2000_lbl 020402 `"Santa Maria Cortijo"', add
label define geo2_mx2000_lbl 020403 `"Santa Maria Coyotepec"', add
label define geo2_mx2000_lbl 020404 `"Santa Maria Chachoapam"', add
label define geo2_mx2000_lbl 020405 `"Villa de Chilapa de Diaz"', add
label define geo2_mx2000_lbl 020406 `"Santa Maria Chilchotla"', add
label define geo2_mx2000_lbl 020407 `"Santa Maria Chimalapa"', add
label define geo2_mx2000_lbl 020408 `"Santa Maria del Rosario"', add
label define geo2_mx2000_lbl 020409 `"Santa Maria del Tule"', add
label define geo2_mx2000_lbl 020410 `"Santa Maria Ecatepec"', add
label define geo2_mx2000_lbl 020411 `"Santa Maria Guelace"', add
label define geo2_mx2000_lbl 020412 `"Santa Maria Guienagati"', add
label define geo2_mx2000_lbl 020413 `"Santa Maria Huatulco"', add
label define geo2_mx2000_lbl 020414 `"Santa Maria Huazolotitlan"', add
label define geo2_mx2000_lbl 020415 `"Santa Maria Ipalapa"', add
label define geo2_mx2000_lbl 020416 `"Santa Maria Ixcatlan"', add
label define geo2_mx2000_lbl 020417 `"Santa Maria Jacatepec"', add
label define geo2_mx2000_lbl 020418 `"Santa Maria Jalapa del Marques"', add
label define geo2_mx2000_lbl 020419 `"Santa Maria Jaltianguis"', add
label define geo2_mx2000_lbl 020420 `"Santa Maria Lachixio"', add
label define geo2_mx2000_lbl 020421 `"Santa Maria Mixtequilla"', add
label define geo2_mx2000_lbl 020422 `"Santa Maria Nativitas"', add
label define geo2_mx2000_lbl 020423 `"Santa Maria Nduayaco"', add
label define geo2_mx2000_lbl 020424 `"Santa Maria Ozolotepec"', add
label define geo2_mx2000_lbl 020425 `"Santa Maria Papalo"', add
label define geo2_mx2000_lbl 020426 `"Santa Maria Penoles"', add
label define geo2_mx2000_lbl 020427 `"Santa Maria Petapa"', add
label define geo2_mx2000_lbl 020428 `"Santa Maria Quiegolani"', add
label define geo2_mx2000_lbl 020429 `"Santa Maria Sola"', add
label define geo2_mx2000_lbl 020430 `"Santa Maria Tataltepec"', add
label define geo2_mx2000_lbl 020431 `"Santa Maria Tecomavaca"', add
label define geo2_mx2000_lbl 020432 `"Santa Maria Temaxcalapa"', add
label define geo2_mx2000_lbl 020433 `"Santa Maria Temaxcaltepec"', add
label define geo2_mx2000_lbl 020434 `"Santa Maria Teopoxco"', add
label define geo2_mx2000_lbl 020435 `"Santa Maria Tepantlali"', add
label define geo2_mx2000_lbl 020436 `"Santa Maria Texcatitlan"', add
label define geo2_mx2000_lbl 020437 `"Santa Maria Tlahuitoltepec"', add
label define geo2_mx2000_lbl 020438 `"Santa Maria Tlalixtac"', add
label define geo2_mx2000_lbl 020439 `"Santa Maria Tonameca"', add
label define geo2_mx2000_lbl 020440 `"Santa Maria Totolapilla"', add
label define geo2_mx2000_lbl 020441 `"Santa Maria Xadani"', add
label define geo2_mx2000_lbl 020442 `"Santa Maria Yalina"', add
label define geo2_mx2000_lbl 020443 `"Santa Maria Yavesia"', add
label define geo2_mx2000_lbl 020444 `"Santa Maria Yolotepec"', add
label define geo2_mx2000_lbl 020445 `"Santa Maria Yosoyua"', add
label define geo2_mx2000_lbl 020446 `"Santa Maria Yucuhiti"', add
label define geo2_mx2000_lbl 020447 `"Santa Maria Zacatepec"', add
label define geo2_mx2000_lbl 020448 `"Santa Maria Zaniza"', add
label define geo2_mx2000_lbl 020449 `"Santa Maria Zoquitlan"', add
label define geo2_mx2000_lbl 020450 `"Santiago Amoltepec"', add
label define geo2_mx2000_lbl 020451 `"Santiago Apoala"', add
label define geo2_mx2000_lbl 020452 `"Santiago Apostol"', add
label define geo2_mx2000_lbl 020453 `"Santiago Astata"', add
label define geo2_mx2000_lbl 020454 `"Santiago Atitlan"', add
label define geo2_mx2000_lbl 020455 `"Santiago Ayuquililla"', add
label define geo2_mx2000_lbl 020456 `"Santiago Cacaloxtepec"', add
label define geo2_mx2000_lbl 020457 `"Santiago Camotlan"', add
label define geo2_mx2000_lbl 020458 `"Santiago Comaltepec"', add
label define geo2_mx2000_lbl 020459 `"Santiago Chazumba"', add
label define geo2_mx2000_lbl 020460 `"Santiago Choapam"', add
label define geo2_mx2000_lbl 020461 `"Santiago del Rio"', add
label define geo2_mx2000_lbl 020462 `"Santiago Huajolotitlan"', add
label define geo2_mx2000_lbl 020463 `"Santiago Huauclilla"', add
label define geo2_mx2000_lbl 020464 `"Santiago Ihuitlan Plumas"', add
label define geo2_mx2000_lbl 020465 `"Santiago Ixcuintepec"', add
label define geo2_mx2000_lbl 020466 `"Santiago Ixtayutla"', add
label define geo2_mx2000_lbl 020467 `"Santiago Jamiltepec"', add
label define geo2_mx2000_lbl 020468 `"Santiago Jocotepec"', add
label define geo2_mx2000_lbl 020469 `"Santiago Juxtlahuaca"', add
label define geo2_mx2000_lbl 020470 `"Santiago Lachiguiri"', add
label define geo2_mx2000_lbl 020471 `"Santiago Lalopa"', add
label define geo2_mx2000_lbl 020472 `"Santiago Laollaga"', add
label define geo2_mx2000_lbl 020473 `"Santiago Laxopa"', add
label define geo2_mx2000_lbl 020474 `"Santiago Llano Grande"', add
label define geo2_mx2000_lbl 020475 `"Santiago Matatlan"', add
label define geo2_mx2000_lbl 020476 `"Santiago Miltepec"', add
label define geo2_mx2000_lbl 020477 `"Santiago Minas"', add
label define geo2_mx2000_lbl 020478 `"Santiago Nacaltepec"', add
label define geo2_mx2000_lbl 020479 `"Santiago Nejapilla"', add
label define geo2_mx2000_lbl 020480 `"Santiago Nundiche"', add
label define geo2_mx2000_lbl 020481 `"Santiago Nuyoo"', add
label define geo2_mx2000_lbl 020482 `"Santiago Pinotepa Nacional"', add
label define geo2_mx2000_lbl 020483 `"Santiago Suchilquitongo"', add
label define geo2_mx2000_lbl 020484 `"Santiago Tamazola"', add
label define geo2_mx2000_lbl 020485 `"Santiago Tapextla"', add
label define geo2_mx2000_lbl 020486 `"Villa Tejupam de la Union"', add
label define geo2_mx2000_lbl 020487 `"Santiago Tenango"', add
label define geo2_mx2000_lbl 020488 `"Santiago Tepetlapa"', add
label define geo2_mx2000_lbl 020489 `"Santiago Tetepec"', add
label define geo2_mx2000_lbl 020490 `"Santiago Texcalcingo"', add
label define geo2_mx2000_lbl 020491 `"Santiago Textitlan"', add
label define geo2_mx2000_lbl 020492 `"Santiago Tilantongo"', add
label define geo2_mx2000_lbl 020493 `"Santiago Tillo"', add
label define geo2_mx2000_lbl 020494 `"Santiago Tlazoyaltepec"', add
label define geo2_mx2000_lbl 020495 `"Santiago Xanica"', add
label define geo2_mx2000_lbl 020496 `"Santiago Xiacui"', add
label define geo2_mx2000_lbl 020497 `"Santiago Yaitepec"', add
label define geo2_mx2000_lbl 020498 `"Santiago Yaveo"', add
label define geo2_mx2000_lbl 020499 `"Santiago Yolomecatl"', add
label define geo2_mx2000_lbl 020500 `"Santiago Yosondua"', add
label define geo2_mx2000_lbl 020501 `"Santiago Yucuyachi"', add
label define geo2_mx2000_lbl 020502 `"Santiago Zacatepec"', add
label define geo2_mx2000_lbl 020503 `"Santiago Zoochila"', add
label define geo2_mx2000_lbl 020504 `"Nuevo Zoquiapam"', add
label define geo2_mx2000_lbl 020505 `"Santo Domingo Ingenio"', add
label define geo2_mx2000_lbl 020506 `"Santo Domingo Albarradas"', add
label define geo2_mx2000_lbl 020507 `"Santo Domingo Armenta"', add
label define geo2_mx2000_lbl 020508 `"Santo Domingo Chihuitan"', add
label define geo2_mx2000_lbl 020509 `"Santo Domingo de Morelos"', add
label define geo2_mx2000_lbl 020510 `"Santo Domingo Ixcatlan"', add
label define geo2_mx2000_lbl 020511 `"Santo Domingo Nuxaa"', add
label define geo2_mx2000_lbl 020512 `"Santo Domingo Ozolotepec"', add
label define geo2_mx2000_lbl 020513 `"Santo Domingo Petapa"', add
label define geo2_mx2000_lbl 020514 `"Santo Domingo Roayaga"', add
label define geo2_mx2000_lbl 020515 `"Santo Domingo Tehuantepec"', add
label define geo2_mx2000_lbl 020516 `"Santo Domingo Teojomulco"', add
label define geo2_mx2000_lbl 020517 `"Santo Domingo Tepuxtepec"', add
label define geo2_mx2000_lbl 020518 `"Santo Domingo Tlatayapam"', add
label define geo2_mx2000_lbl 020519 `"Santo Domingo Tomaltepec"', add
label define geo2_mx2000_lbl 020520 `"Santo Domingo Tonala"', add
label define geo2_mx2000_lbl 020521 `"Santo Domingo Tonaltepec"', add
label define geo2_mx2000_lbl 020522 `"Santo Domingo Xagacia"', add
label define geo2_mx2000_lbl 020523 `"Santo Domingo Yanhuitlan"', add
label define geo2_mx2000_lbl 020524 `"Santo Domingo Yodohino"', add
label define geo2_mx2000_lbl 020525 `"Santo Domingo Zanatepec"', add
label define geo2_mx2000_lbl 020526 `"Santos Reyes Nopala"', add
label define geo2_mx2000_lbl 020527 `"Santos Reyes papalo"', add
label define geo2_mx2000_lbl 020528 `"Santos Reyes Tepejillo"', add
label define geo2_mx2000_lbl 020529 `"Santos Reyes Yucuna"', add
label define geo2_mx2000_lbl 020530 `"Santo Tomas Jalieza"', add
label define geo2_mx2000_lbl 020531 `"Santo Tomas Mazaltepec"', add
label define geo2_mx2000_lbl 020532 `"Santo Tomas Ocotepec"', add
label define geo2_mx2000_lbl 020533 `"Santo Tomas Tamazulapan"', add
label define geo2_mx2000_lbl 020534 `"San Vicente Coatlan"', add
label define geo2_mx2000_lbl 020535 `"San Vicente Lachixio"', add
label define geo2_mx2000_lbl 020536 `"San Vicente Nunu"', add
label define geo2_mx2000_lbl 020537 `"Silacayoapam"', add
label define geo2_mx2000_lbl 020538 `"Sitio de Xitlapehua"', add
label define geo2_mx2000_lbl 020539 `"Soledad Etla"', add
label define geo2_mx2000_lbl 020540 `"Villa de Tamazulapam del Progreso"', add
label define geo2_mx2000_lbl 020541 `"Tanetze de Zaragoza"', add
label define geo2_mx2000_lbl 020542 `"Taniche"', add
label define geo2_mx2000_lbl 020543 `"Tataltepec de Valdes"', add
label define geo2_mx2000_lbl 020544 `"Teococuilco de Marcos Perez"', add
label define geo2_mx2000_lbl 020545 `"Teotitlan de Flores Magon"', add
label define geo2_mx2000_lbl 020546 `"Teotitlan del Valle"', add
label define geo2_mx2000_lbl 020547 `"Teotongo"', add
label define geo2_mx2000_lbl 020548 `"Tepelmeme Villa de Morelos"', add
label define geo2_mx2000_lbl 020549 `"Tezoatlan de Segura y Luna"', add
label define geo2_mx2000_lbl 020550 `"San Jeronimo Tlacochahuaya"', add
label define geo2_mx2000_lbl 020551 `"Tlacolula de Matamoros"', add
label define geo2_mx2000_lbl 020552 `"Tlacotepec Plumas"', add
label define geo2_mx2000_lbl 020553 `"Tlalixtac de Cabrera"', add
label define geo2_mx2000_lbl 020554 `"Totontepec Villa de Morelos"', add
label define geo2_mx2000_lbl 020555 `"Trinidad Zaachila"', add
label define geo2_mx2000_lbl 020556 `"Trinidad Vista Hermosa, La"', add
label define geo2_mx2000_lbl 020557 `"Union Hidalgo"', add
label define geo2_mx2000_lbl 020558 `"Valerio Trujano"', add
label define geo2_mx2000_lbl 020559 `"San Juan Bautista Valle Nacional"', add
label define geo2_mx2000_lbl 020560 `"Villa Diaz Ordaz"', add
label define geo2_mx2000_lbl 020561 `"Yaxe"', add
label define geo2_mx2000_lbl 020562 `"Magdalena Yodocono de Porfirio Diaz"', add
label define geo2_mx2000_lbl 020563 `"Yogana"', add
label define geo2_mx2000_lbl 020564 `"Yutanduchi de Guerrero"', add
label define geo2_mx2000_lbl 020565 `"Villa de Zaachila"', add
label define geo2_mx2000_lbl 020566 `"Zapotitlan del Rio"', add
label define geo2_mx2000_lbl 020567 `"Zapotitlan Lagunas"', add
label define geo2_mx2000_lbl 020568 `"Zapotitlan Palmas"', add
label define geo2_mx2000_lbl 020569 `"Santa ines de Zaragoza"', add
label define geo2_mx2000_lbl 020570 `"Zimatlan de Alvarez"', add
label define geo2_mx2000_lbl 021001 `"Acajete"', add
label define geo2_mx2000_lbl 021002 `"Acateno"', add
label define geo2_mx2000_lbl 021003 `"Acatlan"', add
label define geo2_mx2000_lbl 021004 `"Acatzingo"', add
label define geo2_mx2000_lbl 021005 `"Acteopan"', add
label define geo2_mx2000_lbl 021006 `"Ahuacatlan"', add
label define geo2_mx2000_lbl 021007 `"Ahuatlan"', add
label define geo2_mx2000_lbl 021008 `"Ahuazotepec"', add
label define geo2_mx2000_lbl 021009 `"Ahuehuetitla"', add
label define geo2_mx2000_lbl 021010 `"Ajalpan"', add
label define geo2_mx2000_lbl 021011 `"Albino Zertuche"', add
label define geo2_mx2000_lbl 021012 `"Aljojuca"', add
label define geo2_mx2000_lbl 021013 `"Altepexi"', add
label define geo2_mx2000_lbl 021014 `"Amixtlan"', add
label define geo2_mx2000_lbl 021015 `"Amozoc"', add
label define geo2_mx2000_lbl 021016 `"Aquixtla"', add
label define geo2_mx2000_lbl 021017 `"Atempan"', add
label define geo2_mx2000_lbl 021018 `"Atexcal"', add
label define geo2_mx2000_lbl 021019 `"Atlixco"', add
label define geo2_mx2000_lbl 021020 `"Atoyatempan"', add
label define geo2_mx2000_lbl 021021 `"Atzala"', add
label define geo2_mx2000_lbl 021022 `"Atzitzihuacan"', add
label define geo2_mx2000_lbl 021023 `"Atzitzintla"', add
label define geo2_mx2000_lbl 021024 `"Axutla"', add
label define geo2_mx2000_lbl 021025 `"Ayotoxco de Guerrero"', add
label define geo2_mx2000_lbl 021026 `"Calpan"', add
label define geo2_mx2000_lbl 021027 `"Caltepec"', add
label define geo2_mx2000_lbl 021028 `"Camocuautla"', add
label define geo2_mx2000_lbl 021029 `"Caxhuacan"', add
label define geo2_mx2000_lbl 021030 `"Coatepec"', add
label define geo2_mx2000_lbl 021031 `"Coatzingo"', add
label define geo2_mx2000_lbl 021032 `"Cohetzala"', add
label define geo2_mx2000_lbl 021033 `"Cohuecan"', add
label define geo2_mx2000_lbl 021034 `"Coronango"', add
label define geo2_mx2000_lbl 021035 `"Coxcatlan"', add
label define geo2_mx2000_lbl 021036 `"Coyomeapan"', add
label define geo2_mx2000_lbl 021037 `"Coyotepec"', add
label define geo2_mx2000_lbl 021038 `"Cuapiaxtla de Madero"', add
label define geo2_mx2000_lbl 021039 `"Cuautempan"', add
label define geo2_mx2000_lbl 021040 `"Cuautinchan"', add
label define geo2_mx2000_lbl 021041 `"Cuautlancingo"', add
label define geo2_mx2000_lbl 021042 `"Cuayuca de Andrade"', add
label define geo2_mx2000_lbl 021043 `"Cuetzalan del Progreso"', add
label define geo2_mx2000_lbl 021044 `"Cuyoaco"', add
label define geo2_mx2000_lbl 021045 `"Chalchicomula de Sesma"', add
label define geo2_mx2000_lbl 021046 `"Chapulco"', add
label define geo2_mx2000_lbl 021047 `"Chiautla"', add
label define geo2_mx2000_lbl 021048 `"Chiautzingo"', add
label define geo2_mx2000_lbl 021049 `"Chiconcuautla"', add
label define geo2_mx2000_lbl 021050 `"Chichiquila"', add
label define geo2_mx2000_lbl 021051 `"Chietla"', add
label define geo2_mx2000_lbl 021052 `"Chigmecatitlan"', add
label define geo2_mx2000_lbl 021053 `"Chignahuapan"', add
label define geo2_mx2000_lbl 021054 `"Chignautla"', add
label define geo2_mx2000_lbl 021055 `"Chila"', add
label define geo2_mx2000_lbl 021056 `"Chila de la Sal"', add
label define geo2_mx2000_lbl 021057 `"Honey"', add
label define geo2_mx2000_lbl 021058 `"Chilchotla"', add
label define geo2_mx2000_lbl 021059 `"Chinantla"', add
label define geo2_mx2000_lbl 021060 `"Domingo Arenas"', add
label define geo2_mx2000_lbl 021061 `"Eloxochitlan"', add
label define geo2_mx2000_lbl 021062 `"Epatlan"', add
label define geo2_mx2000_lbl 021063 `"Esperanza"', add
label define geo2_mx2000_lbl 021064 `"Francisco Z. Mena"', add
label define geo2_mx2000_lbl 021065 `"General Felipe Angeles"', add
label define geo2_mx2000_lbl 021066 `"Guadalupe"', add
label define geo2_mx2000_lbl 021067 `"Guadalupe Victoria"', add
label define geo2_mx2000_lbl 021068 `"Hermenegildo Galeana"', add
label define geo2_mx2000_lbl 021069 `"Huaquechula"', add
label define geo2_mx2000_lbl 021070 `"Huatlatlauca"', add
label define geo2_mx2000_lbl 021071 `"Huauchinango"', add
label define geo2_mx2000_lbl 021072 `"Huehuetla"', add
label define geo2_mx2000_lbl 021073 `"Huehuetlan el Chico"', add
label define geo2_mx2000_lbl 021074 `"Huejotzingo"', add
label define geo2_mx2000_lbl 021075 `"Hueyapan"', add
label define geo2_mx2000_lbl 021076 `"Hueytamalco"', add
label define geo2_mx2000_lbl 021077 `"Hueytlalpan"', add
label define geo2_mx2000_lbl 021078 `"Huitzilan de Serdan"', add
label define geo2_mx2000_lbl 021079 `"Huitziltepec"', add
label define geo2_mx2000_lbl 021080 `"Atlequizayan"', add
label define geo2_mx2000_lbl 021081 `"Ixcamilpa de Guerrero"', add
label define geo2_mx2000_lbl 021082 `"Ixcaquixtla"', add
label define geo2_mx2000_lbl 021083 `"Ixtacamaxtitlan"', add
label define geo2_mx2000_lbl 021084 `"Ixtepec"', add
label define geo2_mx2000_lbl 021085 `"Izucar de Matamoros"', add
label define geo2_mx2000_lbl 021086 `"Jalpan"', add
label define geo2_mx2000_lbl 021087 `"Jolalpan"', add
label define geo2_mx2000_lbl 021088 `"Jonotla"', add
label define geo2_mx2000_lbl 021089 `"Jopala"', add
label define geo2_mx2000_lbl 021090 `"Juan C. Bonilla"', add
label define geo2_mx2000_lbl 021091 `"Juan Galindo"', add
label define geo2_mx2000_lbl 021092 `"Juan N. Mendez"', add
label define geo2_mx2000_lbl 021093 `"Lafragua"', add
label define geo2_mx2000_lbl 021094 `"Libres"', add
label define geo2_mx2000_lbl 021095 `"Magdalena Tlatlauquitepec, La"', add
label define geo2_mx2000_lbl 021096 `"Mazapiltepec de Juarez"', add
label define geo2_mx2000_lbl 021097 `"Mixtla"', add
label define geo2_mx2000_lbl 021098 `"Molcaxac"', add
label define geo2_mx2000_lbl 021099 `"Canada Morelos"', add
label define geo2_mx2000_lbl 021100 `"Naupan"', add
label define geo2_mx2000_lbl 021101 `"Nauzontla"', add
label define geo2_mx2000_lbl 021102 `"Nealtican"', add
label define geo2_mx2000_lbl 021103 `"Nicolas Bravo"', add
label define geo2_mx2000_lbl 021104 `"Nopalucan"', add
label define geo2_mx2000_lbl 021105 `"Ocotepec"', add
label define geo2_mx2000_lbl 021106 `"Ocoyucan"', add
label define geo2_mx2000_lbl 021107 `"Olintla"', add
label define geo2_mx2000_lbl 021108 `"Oriental"', add
label define geo2_mx2000_lbl 021109 `"Pahuatlan"', add
label define geo2_mx2000_lbl 021110 `"Palmar de Bravo"', add
label define geo2_mx2000_lbl 021111 `"Pantepec"', add
label define geo2_mx2000_lbl 021112 `"Petlalcingo"', add
label define geo2_mx2000_lbl 021113 `"Piaxtla"', add
label define geo2_mx2000_lbl 021114 `"Puebla"', add
label define geo2_mx2000_lbl 021115 `"Quecholac"', add
label define geo2_mx2000_lbl 021116 `"Quimixtlan"', add
label define geo2_mx2000_lbl 021117 `"Rafael Lara Grajales"', add
label define geo2_mx2000_lbl 021118 `"Reyes de Juarez, Los"', add
label define geo2_mx2000_lbl 021119 `"San Andres Cholula"', add
label define geo2_mx2000_lbl 021120 `"San Antonio Canada"', add
label define geo2_mx2000_lbl 021121 `"San Diego la Mesa Tochimiltzingo"', add
label define geo2_mx2000_lbl 021122 `"San Felipe Teotlalcingo"', add
label define geo2_mx2000_lbl 021123 `"San Felipe Tepatlan"', add
label define geo2_mx2000_lbl 021124 `"San Gabriel Chilac"', add
label define geo2_mx2000_lbl 021125 `"San Gregorio Atzompa"', add
label define geo2_mx2000_lbl 021126 `"San Jeronimo Tecuanipan"', add
label define geo2_mx2000_lbl 021127 `"San Jeronimo Xayacatlan"', add
label define geo2_mx2000_lbl 021128 `"San Jose Chiapa"', add
label define geo2_mx2000_lbl 021129 `"San Jose Miahuatlan"', add
label define geo2_mx2000_lbl 021130 `"San Juan Atenco"', add
label define geo2_mx2000_lbl 021131 `"San Juan Atzompa"', add
label define geo2_mx2000_lbl 021132 `"San Martin Texmelucan"', add
label define geo2_mx2000_lbl 021133 `"San Martin Totoltepec"', add
label define geo2_mx2000_lbl 021134 `"San Matias Tlalancaleca"', add
label define geo2_mx2000_lbl 021135 `"San Miguel Ixitlan"', add
label define geo2_mx2000_lbl 021136 `"San Miguel Xoxtla"', add
label define geo2_mx2000_lbl 021137 `"San Nicolas Buenos Aires"', add
label define geo2_mx2000_lbl 021138 `"San Nicolas de los Ranchos"', add
label define geo2_mx2000_lbl 021139 `"San Pablo Anicano"', add
label define geo2_mx2000_lbl 021140 `"San Pedro Cholula"', add
label define geo2_mx2000_lbl 021141 `"San Pedro Yeloixtlahuaca"', add
label define geo2_mx2000_lbl 021142 `"San Salvador el Seco"', add
label define geo2_mx2000_lbl 021143 `"San Salvador el Verde"', add
label define geo2_mx2000_lbl 021144 `"San Salvador Huixcolotla"', add
label define geo2_mx2000_lbl 021145 `"San Sebastian Tlacotepec"', add
label define geo2_mx2000_lbl 021146 `"Santa Catarina Tlaltempan"', add
label define geo2_mx2000_lbl 021147 `"Santa Ines Ahuatempan"', add
label define geo2_mx2000_lbl 021148 `"Santa Isabel Cholula"', add
label define geo2_mx2000_lbl 021149 `"Santiago Miahuatlan"', add
label define geo2_mx2000_lbl 021150 `"Huehuetlan el Grande"', add
label define geo2_mx2000_lbl 021151 `"Santo Tomas Hueyotlipan"', add
label define geo2_mx2000_lbl 021152 `"Soltepec"', add
label define geo2_mx2000_lbl 021153 `"Tecali de Herrera"', add
label define geo2_mx2000_lbl 021154 `"Tecamachalco"', add
label define geo2_mx2000_lbl 021155 `"Tecomatlan"', add
label define geo2_mx2000_lbl 021156 `"Tehuacan"', add
label define geo2_mx2000_lbl 021157 `"Tehuitzingo"', add
label define geo2_mx2000_lbl 021158 `"Tenampulco"', add
label define geo2_mx2000_lbl 021159 `"Teopantlan"', add
label define geo2_mx2000_lbl 021160 `"Teotlalco"', add
label define geo2_mx2000_lbl 021161 `"Tepanco de Lopez"', add
label define geo2_mx2000_lbl 021162 `"Tepango de Rodriguez"', add
label define geo2_mx2000_lbl 021163 `"Tepatlaxco de Hidalgo"', add
label define geo2_mx2000_lbl 021164 `"Tepeaca"', add
label define geo2_mx2000_lbl 021165 `"Tepemaxalco"', add
label define geo2_mx2000_lbl 021166 `"Tepeojuma"', add
label define geo2_mx2000_lbl 021167 `"Tepetzintla"', add
label define geo2_mx2000_lbl 021168 `"Tepexco"', add
label define geo2_mx2000_lbl 021169 `"Tepexi de Rodriguez"', add
label define geo2_mx2000_lbl 021170 `"Tepeyahualco"', add
label define geo2_mx2000_lbl 021171 `"Tepeyahualco de Cuauhtemoc"', add
label define geo2_mx2000_lbl 021172 `"Tetela de Ocampo"', add
label define geo2_mx2000_lbl 021173 `"Teteles de Avila Castillo"', add
label define geo2_mx2000_lbl 021174 `"Teziutlan"', add
label define geo2_mx2000_lbl 021175 `"Tianguismanalco"', add
label define geo2_mx2000_lbl 021176 `"Tilapa"', add
label define geo2_mx2000_lbl 021177 `"Tlacotepec de Benito Juarez"', add
label define geo2_mx2000_lbl 021178 `"Tlacuilotepec"', add
label define geo2_mx2000_lbl 021179 `"Tlachichuca"', add
label define geo2_mx2000_lbl 021180 `"Tlahuapan"', add
label define geo2_mx2000_lbl 021181 `"Tlaltenango"', add
label define geo2_mx2000_lbl 021182 `"Tlanepantla"', add
label define geo2_mx2000_lbl 021183 `"Tlaola"', add
label define geo2_mx2000_lbl 021184 `"Tlapacoya"', add
label define geo2_mx2000_lbl 021185 `"Tlapanala"', add
label define geo2_mx2000_lbl 021186 `"Tlatlauquitepec"', add
label define geo2_mx2000_lbl 021187 `"Tlaxco"', add
label define geo2_mx2000_lbl 021188 `"Tochimilco"', add
label define geo2_mx2000_lbl 021189 `"Tochtepec"', add
label define geo2_mx2000_lbl 021190 `"Totoltepec de Guerrero"', add
label define geo2_mx2000_lbl 021191 `"Tulcingo"', add
label define geo2_mx2000_lbl 021192 `"Tuzamapan de Galeana"', add
label define geo2_mx2000_lbl 021193 `"Tzicatlacoyan"', add
label define geo2_mx2000_lbl 021194 `"Venustiano Carranza"', add
label define geo2_mx2000_lbl 021195 `"Vicente Guerrero"', add
label define geo2_mx2000_lbl 021196 `"Xayacatlan de Bravo"', add
label define geo2_mx2000_lbl 021197 `"Xicotepec"', add
label define geo2_mx2000_lbl 021198 `"Xicotlan"', add
label define geo2_mx2000_lbl 021199 `"Xiutetelco"', add
label define geo2_mx2000_lbl 021200 `"Xochiapulco"', add
label define geo2_mx2000_lbl 021201 `"Xochiltepec"', add
label define geo2_mx2000_lbl 021202 `"Xochitlan de Vicente Suarez"', add
label define geo2_mx2000_lbl 021203 `"Xochitlan Todos Santos"', add
label define geo2_mx2000_lbl 021204 `"Yaonahuac"', add
label define geo2_mx2000_lbl 021205 `"Yehualtepec"', add
label define geo2_mx2000_lbl 021206 `"Zacapala"', add
label define geo2_mx2000_lbl 021207 `"Zacapoaxtla"', add
label define geo2_mx2000_lbl 021208 `"Zacatlan"', add
label define geo2_mx2000_lbl 021209 `"Zapotitlan"', add
label define geo2_mx2000_lbl 021210 `"Zapotitlan de Mendez"', add
label define geo2_mx2000_lbl 021211 `"Zaragoza"', add
label define geo2_mx2000_lbl 021212 `"Zautla"', add
label define geo2_mx2000_lbl 021213 `"Zihuateutla"', add
label define geo2_mx2000_lbl 021214 `"Zinacatepec"', add
label define geo2_mx2000_lbl 021215 `"Zongozotla"', add
label define geo2_mx2000_lbl 021216 `"Zoquiapan"', add
label define geo2_mx2000_lbl 021217 `"Zoquitlan"', add
label define geo2_mx2000_lbl 022001 `"Amealco de Bonfil"', add
label define geo2_mx2000_lbl 022002 `"Pinal de Amoles"', add
label define geo2_mx2000_lbl 022003 `"Arroyo Seco"', add
label define geo2_mx2000_lbl 022004 `"Cadereyta de Montes"', add
label define geo2_mx2000_lbl 022005 `"Colon"', add
label define geo2_mx2000_lbl 022006 `"Corregidora"', add
label define geo2_mx2000_lbl 022007 `"Ezequiel Montes"', add
label define geo2_mx2000_lbl 022008 `"Huimilpan"', add
label define geo2_mx2000_lbl 022009 `"Jalpan de Serra"', add
label define geo2_mx2000_lbl 022010 `"Landa de Matamoros"', add
label define geo2_mx2000_lbl 022011 `"Marques, El"', add
label define geo2_mx2000_lbl 022012 `"Pedro Escobedo"', add
label define geo2_mx2000_lbl 022013 `"Penamiller"', add
label define geo2_mx2000_lbl 022014 `"Queretaro"', add
label define geo2_mx2000_lbl 022015 `"San Joaquin"', add
label define geo2_mx2000_lbl 022016 `"San Juan del Rio"', add
label define geo2_mx2000_lbl 022017 `"Tequisquiapan"', add
label define geo2_mx2000_lbl 022018 `"Toliman"', add
label define geo2_mx2000_lbl 023001 `"Cozumel"', add
label define geo2_mx2000_lbl 023002 `"Felipe Carrillo Puerto"', add
label define geo2_mx2000_lbl 023003 `"Isla Mujeres"', add
label define geo2_mx2000_lbl 023004 `"Othon p. Blanco"', add
label define geo2_mx2000_lbl 023005 `"Benito Juarez"', add
label define geo2_mx2000_lbl 023006 `"Jose Maria Morelos"', add
label define geo2_mx2000_lbl 023007 `"Lazaro Cardenas"', add
label define geo2_mx2000_lbl 023008 `"Solidaridad"', add
label define geo2_mx2000_lbl 024001 `"Ahualulco"', add
label define geo2_mx2000_lbl 024002 `"Alaquines"', add
label define geo2_mx2000_lbl 024003 `"Aquismon"', add
label define geo2_mx2000_lbl 024004 `"Armadillo de los Infante"', add
label define geo2_mx2000_lbl 024005 `"Cardenas"', add
label define geo2_mx2000_lbl 024006 `"Catorce"', add
label define geo2_mx2000_lbl 024007 `"Cedral"', add
label define geo2_mx2000_lbl 024008 `"Cerritos"', add
label define geo2_mx2000_lbl 024009 `"Cerro de San Pedro"', add
label define geo2_mx2000_lbl 024010 `"Ciudad del Maiz"', add
label define geo2_mx2000_lbl 024011 `"Ciudad Fernandez"', add
label define geo2_mx2000_lbl 024012 `"Tancanhuitz de Santos"', add
label define geo2_mx2000_lbl 024013 `"Ciudad Valles"', add
label define geo2_mx2000_lbl 024014 `"Coxcatlan"', add
label define geo2_mx2000_lbl 024015 `"Charcas"', add
label define geo2_mx2000_lbl 024016 `"Ebano"', add
label define geo2_mx2000_lbl 024017 `"Guadalcazar"', add
label define geo2_mx2000_lbl 024018 `"Huehuetlan"', add
label define geo2_mx2000_lbl 024019 `"Lagunillas"', add
label define geo2_mx2000_lbl 024020 `"Matehuala"', add
label define geo2_mx2000_lbl 024021 `"Mexquitic de Carmona"', add
label define geo2_mx2000_lbl 024022 `"Moctezuma"', add
label define geo2_mx2000_lbl 024023 `"Rayon"', add
label define geo2_mx2000_lbl 024024 `"Rioverde"', add
label define geo2_mx2000_lbl 024025 `"Salinas"', add
label define geo2_mx2000_lbl 024026 `"San Antonio"', add
label define geo2_mx2000_lbl 024027 `"San Ciro de Acosta"', add
label define geo2_mx2000_lbl 024028 `"San Luis Potosi"', add
label define geo2_mx2000_lbl 024029 `"San Martin Chalchicuautla"', add
label define geo2_mx2000_lbl 024030 `"San Nicolas Tolentino"', add
label define geo2_mx2000_lbl 024031 `"Santa Catarina"', add
label define geo2_mx2000_lbl 024032 `"Santa Maria del Rio"', add
label define geo2_mx2000_lbl 024033 `"Santo Domingo"', add
label define geo2_mx2000_lbl 024034 `"San Vicente Tancuayalab"', add
label define geo2_mx2000_lbl 024035 `"Soledad de Graciano Sanchez"', add
label define geo2_mx2000_lbl 024036 `"Tamasopo"', add
label define geo2_mx2000_lbl 024037 `"Tamazunchale"', add
label define geo2_mx2000_lbl 024038 `"Tampacan"', add
label define geo2_mx2000_lbl 024039 `"Tampamolon Corona"', add
label define geo2_mx2000_lbl 024040 `"Tamuin"', add
label define geo2_mx2000_lbl 024041 `"Tanlajas"', add
label define geo2_mx2000_lbl 024042 `"Tanquian de Escobedo"', add
label define geo2_mx2000_lbl 024043 `"Tierra Nueva"', add
label define geo2_mx2000_lbl 024044 `"Vanegas"', add
label define geo2_mx2000_lbl 024045 `"Venado"', add
label define geo2_mx2000_lbl 024046 `"Villa de Arriaga"', add
label define geo2_mx2000_lbl 024047 `"Villa de Guadalupe"', add
label define geo2_mx2000_lbl 024048 `"Villa de la Paz"', add
label define geo2_mx2000_lbl 024049 `"Villa de Ramos"', add
label define geo2_mx2000_lbl 024050 `"Villa de Reyes"', add
label define geo2_mx2000_lbl 024051 `"Villa Hidalgo"', add
label define geo2_mx2000_lbl 024052 `"Villa Juarez"', add
label define geo2_mx2000_lbl 024053 `"Axtla de Terrazas"', add
label define geo2_mx2000_lbl 024054 `"Xilitla"', add
label define geo2_mx2000_lbl 024055 `"Zaragoza"', add
label define geo2_mx2000_lbl 024056 `"Villa de Arista"', add
label define geo2_mx2000_lbl 024057 `"Matlapa"', add
label define geo2_mx2000_lbl 024058 `"Naranjo, El"', add
label define geo2_mx2000_lbl 025001 `"Ahome"', add
label define geo2_mx2000_lbl 025002 `"Angostura"', add
label define geo2_mx2000_lbl 025003 `"Badiraguato"', add
label define geo2_mx2000_lbl 025004 `"Concordia"', add
label define geo2_mx2000_lbl 025005 `"Cosala"', add
label define geo2_mx2000_lbl 025006 `"Culiacan"', add
label define geo2_mx2000_lbl 025007 `"Choix"', add
label define geo2_mx2000_lbl 025008 `"Elota"', add
label define geo2_mx2000_lbl 025009 `"Escuinapa"', add
label define geo2_mx2000_lbl 025010 `"Fuerte, El"', add
label define geo2_mx2000_lbl 025011 `"Guasave"', add
label define geo2_mx2000_lbl 025012 `"Mazatlan"', add
label define geo2_mx2000_lbl 025013 `"Mocorito"', add
label define geo2_mx2000_lbl 025014 `"Rosario"', add
label define geo2_mx2000_lbl 025015 `"Salvador Alvarado"', add
label define geo2_mx2000_lbl 025016 `"San Ignacio"', add
label define geo2_mx2000_lbl 025017 `"Sinaloa"', add
label define geo2_mx2000_lbl 025018 `"Navolato"', add
label define geo2_mx2000_lbl 026001 `"Aconchi"', add
label define geo2_mx2000_lbl 026002 `"Agua prieta"', add
label define geo2_mx2000_lbl 026003 `"Alamos"', add
label define geo2_mx2000_lbl 026004 `"Altar"', add
label define geo2_mx2000_lbl 026005 `"Arivechi"', add
label define geo2_mx2000_lbl 026006 `"Arizpe"', add
label define geo2_mx2000_lbl 026007 `"Atil"', add
label define geo2_mx2000_lbl 026008 `"Bacadehuachi"', add
label define geo2_mx2000_lbl 026009 `"Bacanora"', add
label define geo2_mx2000_lbl 026010 `"Bacerac"', add
label define geo2_mx2000_lbl 026011 `"Bacoachi"', add
label define geo2_mx2000_lbl 026012 `"Bacum"', add
label define geo2_mx2000_lbl 026013 `"Banamichi"', add
label define geo2_mx2000_lbl 026014 `"Baviacora"', add
label define geo2_mx2000_lbl 026015 `"Bavispe"', add
label define geo2_mx2000_lbl 026016 `"Benjamin Hill"', add
label define geo2_mx2000_lbl 026017 `"Caborca"', add
label define geo2_mx2000_lbl 026018 `"Cajeme"', add
label define geo2_mx2000_lbl 026019 `"Cananea"', add
label define geo2_mx2000_lbl 026020 `"Carbo"', add
label define geo2_mx2000_lbl 026021 `"Colorada, La"', add
label define geo2_mx2000_lbl 026022 `"Cucurpe"', add
label define geo2_mx2000_lbl 026023 `"Cumpas"', add
label define geo2_mx2000_lbl 026024 `"Divisaderos"', add
label define geo2_mx2000_lbl 026025 `"Empalme"', add
label define geo2_mx2000_lbl 026026 `"Etchojoa"', add
label define geo2_mx2000_lbl 026027 `"Fronteras"', add
label define geo2_mx2000_lbl 026028 `"Granados"', add
label define geo2_mx2000_lbl 026029 `"Guaymas"', add
label define geo2_mx2000_lbl 026030 `"Hermosillo"', add
label define geo2_mx2000_lbl 026031 `"Huachinera"', add
label define geo2_mx2000_lbl 026032 `"Huasabas"', add
label define geo2_mx2000_lbl 026033 `"Huatabampo"', add
label define geo2_mx2000_lbl 026034 `"Huepac"', add
label define geo2_mx2000_lbl 026035 `"Imuris"', add
label define geo2_mx2000_lbl 026036 `"Magdalena"', add
label define geo2_mx2000_lbl 026037 `"Mazatan"', add
label define geo2_mx2000_lbl 026038 `"Moctezuma"', add
label define geo2_mx2000_lbl 026039 `"Naco"', add
label define geo2_mx2000_lbl 026040 `"Nacori Chico"', add
label define geo2_mx2000_lbl 026041 `"Nacozari de Garcia"', add
label define geo2_mx2000_lbl 026042 `"Navojoa"', add
label define geo2_mx2000_lbl 026043 `"Nogales"', add
label define geo2_mx2000_lbl 026044 `"Onavas"', add
label define geo2_mx2000_lbl 026045 `"Opodepe"', add
label define geo2_mx2000_lbl 026046 `"Oquitoa"', add
label define geo2_mx2000_lbl 026047 `"Pitiquito"', add
label define geo2_mx2000_lbl 026048 `"Puerto Penasco"', add
label define geo2_mx2000_lbl 026049 `"Quiriego"', add
label define geo2_mx2000_lbl 026050 `"Rayon"', add
label define geo2_mx2000_lbl 026051 `"Rosario"', add
label define geo2_mx2000_lbl 026052 `"Sahuaripa"', add
label define geo2_mx2000_lbl 026053 `"San Felipe de Jesus"', add
label define geo2_mx2000_lbl 026054 `"San javier"', add
label define geo2_mx2000_lbl 026055 `"San Luis Rio Colorado"', add
label define geo2_mx2000_lbl 026056 `"San Miguel de Horcasitas"', add
label define geo2_mx2000_lbl 026057 `"San Pedro de la Cueva"', add
label define geo2_mx2000_lbl 026058 `"Santa Ana"', add
label define geo2_mx2000_lbl 026059 `"Santa Cruz"', add
label define geo2_mx2000_lbl 026060 `"Saric"', add
label define geo2_mx2000_lbl 026061 `"Soyopa"', add
label define geo2_mx2000_lbl 026062 `"Suaqui Grande"', add
label define geo2_mx2000_lbl 026063 `"Tepache"', add
label define geo2_mx2000_lbl 026064 `"Trincheras"', add
label define geo2_mx2000_lbl 026065 `"Tubutama"', add
label define geo2_mx2000_lbl 026066 `"Ures"', add
label define geo2_mx2000_lbl 026067 `"Villa Hidalgo"', add
label define geo2_mx2000_lbl 026068 `"Villa Pesqueira"', add
label define geo2_mx2000_lbl 026069 `"Yecora"', add
label define geo2_mx2000_lbl 026070 `"General Plutarco Elias Calles"', add
label define geo2_mx2000_lbl 026071 `"Benito Juarez"', add
label define geo2_mx2000_lbl 026072 `"San Ignacio Rio Muerto"', add
label define geo2_mx2000_lbl 027001 `"Balancan"', add
label define geo2_mx2000_lbl 027002 `"Cardenas"', add
label define geo2_mx2000_lbl 027003 `"Centla"', add
label define geo2_mx2000_lbl 027004 `"Centro"', add
label define geo2_mx2000_lbl 027005 `"Comalcalco"', add
label define geo2_mx2000_lbl 027006 `"Cunduacan"', add
label define geo2_mx2000_lbl 027007 `"Emiliano Zapata"', add
label define geo2_mx2000_lbl 027008 `"Huimanguillo"', add
label define geo2_mx2000_lbl 027009 `"Jalapa"', add
label define geo2_mx2000_lbl 027010 `"Jalpa de Mendez"', add
label define geo2_mx2000_lbl 027011 `"Jonuta"', add
label define geo2_mx2000_lbl 027012 `"Macuspana"', add
label define geo2_mx2000_lbl 027013 `"Nacajuca"', add
label define geo2_mx2000_lbl 027014 `"Paraiso"', add
label define geo2_mx2000_lbl 027015 `"Tacotalpa"', add
label define geo2_mx2000_lbl 027016 `"Teapa"', add
label define geo2_mx2000_lbl 027017 `"Tenosique"', add
label define geo2_mx2000_lbl 028001 `"Abasolo"', add
label define geo2_mx2000_lbl 028002 `"Aldama"', add
label define geo2_mx2000_lbl 028003 `"Altamira"', add
label define geo2_mx2000_lbl 028004 `"Antiguo Morelos"', add
label define geo2_mx2000_lbl 028005 `"Burgos"', add
label define geo2_mx2000_lbl 028006 `"Bustamante"', add
label define geo2_mx2000_lbl 028007 `"Camargo"', add
label define geo2_mx2000_lbl 028008 `"Casas"', add
label define geo2_mx2000_lbl 028009 `"Ciudad Madero"', add
label define geo2_mx2000_lbl 028010 `"Cruillas"', add
label define geo2_mx2000_lbl 028011 `"Gomez Farias"', add
label define geo2_mx2000_lbl 028012 `"Gonzalez"', add
label define geo2_mx2000_lbl 028013 `"Guemez"', add
label define geo2_mx2000_lbl 028014 `"Guerrero"', add
label define geo2_mx2000_lbl 028015 `"Gustavo Diaz Ordaz"', add
label define geo2_mx2000_lbl 028016 `"Hidalgo"', add
label define geo2_mx2000_lbl 028017 `"Jaumave"', add
label define geo2_mx2000_lbl 028018 `"Jimenez"', add
label define geo2_mx2000_lbl 028019 `"Llera"', add
label define geo2_mx2000_lbl 028020 `"Mainero"', add
label define geo2_mx2000_lbl 028021 `"Mante, El"', add
label define geo2_mx2000_lbl 028022 `"Matamoros"', add
label define geo2_mx2000_lbl 028023 `"Mendez"', add
label define geo2_mx2000_lbl 028024 `"Mier"', add
label define geo2_mx2000_lbl 028025 `"Miguel Aleman"', add
label define geo2_mx2000_lbl 028026 `"Miquihuana"', add
label define geo2_mx2000_lbl 028027 `"Nuevo Laredo"', add
label define geo2_mx2000_lbl 028028 `"Nuevo Morelos"', add
label define geo2_mx2000_lbl 028029 `"Ocampo"', add
label define geo2_mx2000_lbl 028030 `"Padilla"', add
label define geo2_mx2000_lbl 028031 `"Palmillas"', add
label define geo2_mx2000_lbl 028032 `"Reynosa"', add
label define geo2_mx2000_lbl 028033 `"Rio Bravo"', add
label define geo2_mx2000_lbl 028034 `"San Carlos"', add
label define geo2_mx2000_lbl 028035 `"San Fernando"', add
label define geo2_mx2000_lbl 028036 `"San Nicolas"', add
label define geo2_mx2000_lbl 028037 `"Soto la Marina"', add
label define geo2_mx2000_lbl 028038 `"Tampico"', add
label define geo2_mx2000_lbl 028039 `"Tula"', add
label define geo2_mx2000_lbl 028040 `"Valle Hermoso"', add
label define geo2_mx2000_lbl 028041 `"Victoria"', add
label define geo2_mx2000_lbl 028042 `"Villagran"', add
label define geo2_mx2000_lbl 028043 `"Xicotencatl"', add
label define geo2_mx2000_lbl 029001 `"Amaxac de Guerrero"', add
label define geo2_mx2000_lbl 029002 `"Apetatitlan de Antonio Carvajal"', add
label define geo2_mx2000_lbl 029003 `"Atlangatepec"', add
label define geo2_mx2000_lbl 029004 `"Altzayanca"', add
label define geo2_mx2000_lbl 029005 `"Apizaco"', add
label define geo2_mx2000_lbl 029006 `"Calpulalpan"', add
label define geo2_mx2000_lbl 029007 `"Carmen Tequexquitla, El"', add
label define geo2_mx2000_lbl 029008 `"Cuapiaxtla"', add
label define geo2_mx2000_lbl 029009 `"Cuaxomulco"', add
label define geo2_mx2000_lbl 029010 `"Chiautempan"', add
label define geo2_mx2000_lbl 029011 `"Munoz de Domingo Arenas"', add
label define geo2_mx2000_lbl 029012 `"Espanita"', add
label define geo2_mx2000_lbl 029013 `"Huamantla"', add
label define geo2_mx2000_lbl 029014 `"Hueyotlipan"', add
label define geo2_mx2000_lbl 029015 `"Ixtacuixtla de Mariano Matamoros"', add
label define geo2_mx2000_lbl 029016 `"Ixtenco"', add
label define geo2_mx2000_lbl 029017 `"Mazatecochco de Jose Maria Morelos"', add
label define geo2_mx2000_lbl 029018 `"Contla de Juan cuamatzi"', add
label define geo2_mx2000_lbl 029019 `"Tepetitla de Lardizabal"', add
label define geo2_mx2000_lbl 029020 `"Sanctorum de Lazaro Cardenas"', add
label define geo2_mx2000_lbl 029021 `"Nanacamilpa de Mariano Arista"', add
label define geo2_mx2000_lbl 029022 `"Acuamanala de Miguel Hidalgo"', add
label define geo2_mx2000_lbl 029023 `"Nativitas"', add
label define geo2_mx2000_lbl 029024 `"Panotla"', add
label define geo2_mx2000_lbl 029025 `"San Pablo del Monte"', add
label define geo2_mx2000_lbl 029026 `"Santa Cruz Tlaxcala"', add
label define geo2_mx2000_lbl 029027 `"Tenancingo"', add
label define geo2_mx2000_lbl 029028 `"Teolocholco"', add
label define geo2_mx2000_lbl 029029 `"Tepeyanco"', add
label define geo2_mx2000_lbl 029030 `"Terrenate"', add
label define geo2_mx2000_lbl 029031 `"Tetla de la Solidaridad"', add
label define geo2_mx2000_lbl 029032 `"Tetlatlahuca"', add
label define geo2_mx2000_lbl 029033 `"Tlaxcala"', add
label define geo2_mx2000_lbl 029034 `"Tlaxco"', add
label define geo2_mx2000_lbl 029035 `"Tocatlan"', add
label define geo2_mx2000_lbl 029036 `"Totolac"', add
label define geo2_mx2000_lbl 029037 `"Zitlaltepec de Trinidad Sanchez Santos"', add
label define geo2_mx2000_lbl 029038 `"Tzompantepec"', add
label define geo2_mx2000_lbl 029039 `"Xaloztoc"', add
label define geo2_mx2000_lbl 029040 `"Xaltocan"', add
label define geo2_mx2000_lbl 029041 `"Papalotla de Xicohtencatl"', add
label define geo2_mx2000_lbl 029042 `"Xicohtzinco"', add
label define geo2_mx2000_lbl 029043 `"Yauhquemecan"', add
label define geo2_mx2000_lbl 029044 `"Zacatelco"', add
label define geo2_mx2000_lbl 029045 `"Benito Juarez"', add
label define geo2_mx2000_lbl 029046 `"Emiliano Zapata"', add
label define geo2_mx2000_lbl 029047 `"Lazaro Cardenas"', add
label define geo2_mx2000_lbl 029048 `"Magdalena Tlaltelulco, La"', add
label define geo2_mx2000_lbl 029049 `"San Damian Texoloc"', add
label define geo2_mx2000_lbl 029050 `"San Francisco Tetlanohcan"', add
label define geo2_mx2000_lbl 029051 `"San Jeronimo Zacualpan"', add
label define geo2_mx2000_lbl 029052 `"San Jose Teacalco"', add
label define geo2_mx2000_lbl 029053 `"San Juan Huactzinco"', add
label define geo2_mx2000_lbl 029054 `"San Lorenzo Axocomanitla"', add
label define geo2_mx2000_lbl 029055 `"San Lucas Tecopilco"', add
label define geo2_mx2000_lbl 029056 `"Santa Ana Nopalucan"', add
label define geo2_mx2000_lbl 029057 `"Santa Apolonia Teacalco"', add
label define geo2_mx2000_lbl 029058 `"Santa Catarina Ayometla"', add
label define geo2_mx2000_lbl 029059 `"Santa Cruz Quilehtla"', add
label define geo2_mx2000_lbl 029060 `"Santa Isabel Xiloxoxtla"', add
label define geo2_mx2000_lbl 030001 `"Acajete"', add
label define geo2_mx2000_lbl 030002 `"Acatlan"', add
label define geo2_mx2000_lbl 030003 `"Acayucan"', add
label define geo2_mx2000_lbl 030004 `"Actopan"', add
label define geo2_mx2000_lbl 030005 `"Acula"', add
label define geo2_mx2000_lbl 030006 `"Acultzingo"', add
label define geo2_mx2000_lbl 030007 `"Camaron de Tejeda"', add
label define geo2_mx2000_lbl 030008 `"Alpatlahuac"', add
label define geo2_mx2000_lbl 030009 `"Alto Lucero de Gutierrez Barrios"', add
label define geo2_mx2000_lbl 030010 `"Altotonga"', add
label define geo2_mx2000_lbl 030011 `"Alvarado"', add
label define geo2_mx2000_lbl 030012 `"Amatitlan"', add
label define geo2_mx2000_lbl 030013 `"Naranjos Amatlan"', add
label define geo2_mx2000_lbl 030014 `"Amatlan de los Reyes"', add
label define geo2_mx2000_lbl 030015 `"Angel R. Cabada"', add
label define geo2_mx2000_lbl 030016 `"Antigua, La"', add
label define geo2_mx2000_lbl 030017 `"Apazapan"', add
label define geo2_mx2000_lbl 030018 `"Aquila"', add
label define geo2_mx2000_lbl 030019 `"Astacinga"', add
label define geo2_mx2000_lbl 030020 `"Atlahuilco"', add
label define geo2_mx2000_lbl 030021 `"Atoyac"', add
label define geo2_mx2000_lbl 030022 `"Atzacan"', add
label define geo2_mx2000_lbl 030023 `"Atzalan"', add
label define geo2_mx2000_lbl 030024 `"Tlaltetela"', add
label define geo2_mx2000_lbl 030025 `"Ayahualulco"', add
label define geo2_mx2000_lbl 030026 `"Banderilla"', add
label define geo2_mx2000_lbl 030027 `"Benito Juarez"', add
label define geo2_mx2000_lbl 030028 `"Boca del Rio"', add
label define geo2_mx2000_lbl 030029 `"Calcahualco"', add
label define geo2_mx2000_lbl 030030 `"Camerino Z. Mendoza"', add
label define geo2_mx2000_lbl 030031 `"Carrillo Puerto"', add
label define geo2_mx2000_lbl 030032 `"Catemaco"', add
label define geo2_mx2000_lbl 030033 `"Cazones"', add
label define geo2_mx2000_lbl 030034 `"Cerro azul"', add
label define geo2_mx2000_lbl 030035 `"Citlaltepetl"', add
label define geo2_mx2000_lbl 030036 `"Coacoatzintla"', add
label define geo2_mx2000_lbl 030037 `"Coahuitlan"', add
label define geo2_mx2000_lbl 030038 `"Coatepec"', add
label define geo2_mx2000_lbl 030039 `"Coatzacoalcos"', add
label define geo2_mx2000_lbl 030040 `"Coatzintla"', add
label define geo2_mx2000_lbl 030041 `"Coetzala"', add
label define geo2_mx2000_lbl 030042 `"Colipa"', add
label define geo2_mx2000_lbl 030043 `"Comapa"', add
label define geo2_mx2000_lbl 030044 `"Cordoba"', add
label define geo2_mx2000_lbl 030045 `"Cosamaloapan de Carpio"', add
label define geo2_mx2000_lbl 030046 `"Cosautlan de Carvajal"', add
label define geo2_mx2000_lbl 030047 `"Coscomatepec"', add
label define geo2_mx2000_lbl 030048 `"Cosoleacaque"', add
label define geo2_mx2000_lbl 030049 `"Cotaxtla"', add
label define geo2_mx2000_lbl 030050 `"Coxquihui"', add
label define geo2_mx2000_lbl 030051 `"Coyutla"', add
label define geo2_mx2000_lbl 030052 `"Cuichapa"', add
label define geo2_mx2000_lbl 030053 `"Cuitlahuac"', add
label define geo2_mx2000_lbl 030054 `"Chacaltianguis"', add
label define geo2_mx2000_lbl 030055 `"Chalma"', add
label define geo2_mx2000_lbl 030056 `"Chiconamel"', add
label define geo2_mx2000_lbl 030057 `"Chiconquiaco"', add
label define geo2_mx2000_lbl 030058 `"Chicontepec"', add
label define geo2_mx2000_lbl 030059 `"Chinameca"', add
label define geo2_mx2000_lbl 030060 `"Chinampa de Gorostiza"', add
label define geo2_mx2000_lbl 030061 `"Choapas, Las"', add
label define geo2_mx2000_lbl 030062 `"Chocaman"', add
label define geo2_mx2000_lbl 030063 `"Chontla"', add
label define geo2_mx2000_lbl 030064 `"Chumatlan"', add
label define geo2_mx2000_lbl 030065 `"Emiliano Zapata"', add
label define geo2_mx2000_lbl 030066 `"Espinal"', add
label define geo2_mx2000_lbl 030067 `"Filomeno Mata"', add
label define geo2_mx2000_lbl 030068 `"Fortin"', add
label define geo2_mx2000_lbl 030069 `"Gutierrez Zamora"', add
label define geo2_mx2000_lbl 030070 `"Hidalgotitlan"', add
label define geo2_mx2000_lbl 030071 `"Huatusco"', add
label define geo2_mx2000_lbl 030072 `"Huayacocotla"', add
label define geo2_mx2000_lbl 030073 `"Hueyapan de Ocampo"', add
label define geo2_mx2000_lbl 030074 `"Huiloapan"', add
label define geo2_mx2000_lbl 030075 `"Ignacio de la Llave"', add
label define geo2_mx2000_lbl 030076 `"Ilamatlan"', add
label define geo2_mx2000_lbl 030077 `"Isla"', add
label define geo2_mx2000_lbl 030078 `"Ixcatepec"', add
label define geo2_mx2000_lbl 030079 `"Ixhuacan de los Reyes"', add
label define geo2_mx2000_lbl 030080 `"Ixhuatlan del Cafe"', add
label define geo2_mx2000_lbl 030081 `"Ixhuatlancillo"', add
label define geo2_mx2000_lbl 030082 `"Ixhuatlan del Sureste"', add
label define geo2_mx2000_lbl 030083 `"Ixhuatlan de Madero"', add
label define geo2_mx2000_lbl 030084 `"Ixmatlahuacan"', add
label define geo2_mx2000_lbl 030085 `"Ixtaczoquitlan"', add
label define geo2_mx2000_lbl 030086 `"Jalacingo"', add
label define geo2_mx2000_lbl 030087 `"Xalapa"', add
label define geo2_mx2000_lbl 030088 `"Jalcomulco"', add
label define geo2_mx2000_lbl 030089 `"Jaltipan"', add
label define geo2_mx2000_lbl 030090 `"Jamapa"', add
label define geo2_mx2000_lbl 030091 `"Jesus Carranza"', add
label define geo2_mx2000_lbl 030092 `"Xico"', add
label define geo2_mx2000_lbl 030093 `"Jilotepec"', add
label define geo2_mx2000_lbl 030094 `"Juan Rodriguez Clara"', add
label define geo2_mx2000_lbl 030095 `"Juchique de Ferrer"', add
label define geo2_mx2000_lbl 030096 `"Landero y Coss"', add
label define geo2_mx2000_lbl 030097 `"Lerdo de Tejada"', add
label define geo2_mx2000_lbl 030098 `"Magdalena"', add
label define geo2_mx2000_lbl 030099 `"Maltrata"', add
label define geo2_mx2000_lbl 030100 `"Manlio Fabio Altamirano"', add
label define geo2_mx2000_lbl 030101 `"Mariano Escobedo"', add
label define geo2_mx2000_lbl 030102 `"Martinez de la Torre"', add
label define geo2_mx2000_lbl 030103 `"Mecatlan"', add
label define geo2_mx2000_lbl 030104 `"Mecayapan"', add
label define geo2_mx2000_lbl 030105 `"Medellin"', add
label define geo2_mx2000_lbl 030106 `"Miahuatlan"', add
label define geo2_mx2000_lbl 030107 `"Minas, Las"', add
label define geo2_mx2000_lbl 030108 `"Minatitlan"', add
label define geo2_mx2000_lbl 030109 `"Misantla"', add
label define geo2_mx2000_lbl 030110 `"Mixtla de Altamirano"', add
label define geo2_mx2000_lbl 030111 `"Moloacan"', add
label define geo2_mx2000_lbl 030112 `"Naolinco"', add
label define geo2_mx2000_lbl 030113 `"Naranjal"', add
label define geo2_mx2000_lbl 030114 `"Nautla"', add
label define geo2_mx2000_lbl 030115 `"Nogales"', add
label define geo2_mx2000_lbl 030116 `"Oluta"', add
label define geo2_mx2000_lbl 030117 `"Omealca"', add
label define geo2_mx2000_lbl 030118 `"Orizaba"', add
label define geo2_mx2000_lbl 030119 `"Otatitlan"', add
label define geo2_mx2000_lbl 030120 `"Oteapan"', add
label define geo2_mx2000_lbl 030121 `"Ozuluama de Mascarenas"', add
label define geo2_mx2000_lbl 030122 `"Pajapan"', add
label define geo2_mx2000_lbl 030123 `"Panuco"', add
label define geo2_mx2000_lbl 030124 `"Papantla"', add
label define geo2_mx2000_lbl 030125 `"Paso del Macho"', add
label define geo2_mx2000_lbl 030126 `"Paso de Ovejas"', add
label define geo2_mx2000_lbl 030127 `"Perla, La"', add
label define geo2_mx2000_lbl 030128 `"Perote"', add
label define geo2_mx2000_lbl 030129 `"Platon Sanchez"', add
label define geo2_mx2000_lbl 030130 `"Playa Vicente"', add
label define geo2_mx2000_lbl 030131 `"Poza Rica de Hidalgo"', add
label define geo2_mx2000_lbl 030132 `"Vigas de Ramirez, Las"', add
label define geo2_mx2000_lbl 030133 `"Pueblo Viejo"', add
label define geo2_mx2000_lbl 030134 `"Puente Nacional"', add
label define geo2_mx2000_lbl 030135 `"Rafael Delgado"', add
label define geo2_mx2000_lbl 030136 `"Rafael lucio"', add
label define geo2_mx2000_lbl 030137 `"Reyes, Los"', add
label define geo2_mx2000_lbl 030138 `"Rio Blanco"', add
label define geo2_mx2000_lbl 030139 `"Saltabarranca"', add
label define geo2_mx2000_lbl 030140 `"San Andres Tenejapan"', add
label define geo2_mx2000_lbl 030141 `"San Andres Tuxtla"', add
label define geo2_mx2000_lbl 030142 `"San Juan Evangelista"', add
label define geo2_mx2000_lbl 030143 `"Santiago Tuxtla"', add
label define geo2_mx2000_lbl 030144 `"Sayula de Aleman"', add
label define geo2_mx2000_lbl 030145 `"Soconusco"', add
label define geo2_mx2000_lbl 030146 `"Sochiapa"', add
label define geo2_mx2000_lbl 030147 `"Soledad Atzompa"', add
label define geo2_mx2000_lbl 030148 `"Soledad de Doblado"', add
label define geo2_mx2000_lbl 030149 `"Soteapan"', add
label define geo2_mx2000_lbl 030150 `"Tamalin"', add
label define geo2_mx2000_lbl 030151 `"Tamiahua"', add
label define geo2_mx2000_lbl 030152 `"Tampico Alto"', add
label define geo2_mx2000_lbl 030153 `"Tancoco"', add
label define geo2_mx2000_lbl 030154 `"Tantima"', add
label define geo2_mx2000_lbl 030155 `"Tantoyuca"', add
label define geo2_mx2000_lbl 030156 `"Tatatila"', add
label define geo2_mx2000_lbl 030157 `"Castillo de Teayo"', add
label define geo2_mx2000_lbl 030158 `"Tecolutla"', add
label define geo2_mx2000_lbl 030159 `"Tehuipango"', add
label define geo2_mx2000_lbl 030160 `"Temapache"', add
label define geo2_mx2000_lbl 030161 `"Tempoal"', add
label define geo2_mx2000_lbl 030162 `"Tenampa"', add
label define geo2_mx2000_lbl 030163 `"Tenochtitlan"', add
label define geo2_mx2000_lbl 030164 `"Teocelo"', add
label define geo2_mx2000_lbl 030165 `"Tepatlaxco"', add
label define geo2_mx2000_lbl 030166 `"Tepetlan"', add
label define geo2_mx2000_lbl 030167 `"Tepetzintla"', add
label define geo2_mx2000_lbl 030168 `"Tequila"', add
label define geo2_mx2000_lbl 030169 `"Jose Azueta"', add
label define geo2_mx2000_lbl 030170 `"Texcatepec"', add
label define geo2_mx2000_lbl 030171 `"Texhuacan"', add
label define geo2_mx2000_lbl 030172 `"Texistepec"', add
label define geo2_mx2000_lbl 030173 `"Tezonapa"', add
label define geo2_mx2000_lbl 030174 `"Tierra Blanca"', add
label define geo2_mx2000_lbl 030175 `"Tihuatlan"', add
label define geo2_mx2000_lbl 030176 `"Tlacojalpan"', add
label define geo2_mx2000_lbl 030177 `"Tlacolulan"', add
label define geo2_mx2000_lbl 030178 `"Tlacotalpan"', add
label define geo2_mx2000_lbl 030179 `"Tlacotepec de Mejia"', add
label define geo2_mx2000_lbl 030180 `"Tlachichilco"', add
label define geo2_mx2000_lbl 030181 `"Tlalixcoyan"', add
label define geo2_mx2000_lbl 030182 `"Tlalnelhuayocan"', add
label define geo2_mx2000_lbl 030183 `"Tlapacoyan"', add
label define geo2_mx2000_lbl 030184 `"Tlaquilpa"', add
label define geo2_mx2000_lbl 030185 `"Tlilapan"', add
label define geo2_mx2000_lbl 030186 `"Tomatlan"', add
label define geo2_mx2000_lbl 030187 `"Tonayan"', add
label define geo2_mx2000_lbl 030188 `"Totutla"', add
label define geo2_mx2000_lbl 030189 `"Tuxpam"', add
label define geo2_mx2000_lbl 030190 `"Tuxtilla"', add
label define geo2_mx2000_lbl 030191 `"Ursulo Galvan"', add
label define geo2_mx2000_lbl 030192 `"Vega de Alatorre"', add
label define geo2_mx2000_lbl 030193 `"Veracruz"', add
label define geo2_mx2000_lbl 030194 `"Villa Aldama"', add
label define geo2_mx2000_lbl 030195 `"Xoxocotla"', add
label define geo2_mx2000_lbl 030196 `"Yanga"', add
label define geo2_mx2000_lbl 030197 `"Yecuatla"', add
label define geo2_mx2000_lbl 030198 `"Zacualpan"', add
label define geo2_mx2000_lbl 030199 `"Zaragoza"', add
label define geo2_mx2000_lbl 030200 `"Zentla"', add
label define geo2_mx2000_lbl 030201 `"Zongolica"', add
label define geo2_mx2000_lbl 030202 `"Zontecomatlan de Lopez y Fuentes"', add
label define geo2_mx2000_lbl 030203 `"Zozocolco de Hidalgo"', add
label define geo2_mx2000_lbl 030204 `"Agua Dulce"', add
label define geo2_mx2000_lbl 030205 `"Higo, El"', add
label define geo2_mx2000_lbl 030206 `"Nanchital de Lazaro Cardenas del Rio"', add
label define geo2_mx2000_lbl 030207 `"Tres Valles"', add
label define geo2_mx2000_lbl 030208 `"Carlos A. Carrillo"', add
label define geo2_mx2000_lbl 030209 `"Tatahuicapan de Juarez"', add
label define geo2_mx2000_lbl 030210 `"Uxpanapa"', add
label define geo2_mx2000_lbl 031001 `"Abala"', add
label define geo2_mx2000_lbl 031002 `"Acanceh"', add
label define geo2_mx2000_lbl 031003 `"Akil"', add
label define geo2_mx2000_lbl 031004 `"Baca"', add
label define geo2_mx2000_lbl 031005 `"Bokoba"', add
label define geo2_mx2000_lbl 031006 `"Buctzotz"', add
label define geo2_mx2000_lbl 031007 `"Cacalchen"', add
label define geo2_mx2000_lbl 031008 `"Calotmul"', add
label define geo2_mx2000_lbl 031009 `"Cansahcab"', add
label define geo2_mx2000_lbl 031010 `"Cantamayec"', add
label define geo2_mx2000_lbl 031011 `"Celestun"', add
label define geo2_mx2000_lbl 031012 `"Cenotillo"', add
label define geo2_mx2000_lbl 031013 `"Conkal"', add
label define geo2_mx2000_lbl 031014 `"Cuncunul"', add
label define geo2_mx2000_lbl 031015 `"Cuzama"', add
label define geo2_mx2000_lbl 031016 `"Chacsinkin"', add
label define geo2_mx2000_lbl 031017 `"Chankom"', add
label define geo2_mx2000_lbl 031018 `"Chapab"', add
label define geo2_mx2000_lbl 031019 `"Chemax"', add
label define geo2_mx2000_lbl 031020 `"Chicxulub Pueblo"', add
label define geo2_mx2000_lbl 031021 `"Chichimila"', add
label define geo2_mx2000_lbl 031022 `"Chikindzonot"', add
label define geo2_mx2000_lbl 031023 `"Chochola"', add
label define geo2_mx2000_lbl 031024 `"Chumayel"', add
label define geo2_mx2000_lbl 031025 `"Dzan"', add
label define geo2_mx2000_lbl 031026 `"Dzemul"', add
label define geo2_mx2000_lbl 031027 `"Dzidzantun"', add
label define geo2_mx2000_lbl 031028 `"Dzilam de Bravo"', add
label define geo2_mx2000_lbl 031029 `"Dzilam Gonzalez"', add
label define geo2_mx2000_lbl 031030 `"Dzitas"', add
label define geo2_mx2000_lbl 031031 `"Dzoncauich"', add
label define geo2_mx2000_lbl 031032 `"Espita"', add
label define geo2_mx2000_lbl 031033 `"Halacho"', add
label define geo2_mx2000_lbl 031034 `"Hocaba"', add
label define geo2_mx2000_lbl 031035 `"Hoctun"', add
label define geo2_mx2000_lbl 031036 `"Homun"', add
label define geo2_mx2000_lbl 031037 `"Huhi"', add
label define geo2_mx2000_lbl 031038 `"Hunucma"', add
label define geo2_mx2000_lbl 031039 `"Ixil"', add
label define geo2_mx2000_lbl 031040 `"Izamal"', add
label define geo2_mx2000_lbl 031041 `"Kanasin"', add
label define geo2_mx2000_lbl 031042 `"Kantunil"', add
label define geo2_mx2000_lbl 031043 `"Kaua"', add
label define geo2_mx2000_lbl 031044 `"Kinchil"', add
label define geo2_mx2000_lbl 031045 `"Kopoma"', add
label define geo2_mx2000_lbl 031046 `"Mama"', add
label define geo2_mx2000_lbl 031047 `"Mani"', add
label define geo2_mx2000_lbl 031048 `"Maxcanu"', add
label define geo2_mx2000_lbl 031049 `"Mayapan"', add
label define geo2_mx2000_lbl 031050 `"Merida"', add
label define geo2_mx2000_lbl 031051 `"Mococha"', add
label define geo2_mx2000_lbl 031052 `"Motul"', add
label define geo2_mx2000_lbl 031053 `"Muna"', add
label define geo2_mx2000_lbl 031054 `"Muxupip"', add
label define geo2_mx2000_lbl 031055 `"Opichen"', add
label define geo2_mx2000_lbl 031056 `"Oxkutzcab"', add
label define geo2_mx2000_lbl 031057 `"Panaba"', add
label define geo2_mx2000_lbl 031058 `"Peto"', add
label define geo2_mx2000_lbl 031059 `"Progreso"', add
label define geo2_mx2000_lbl 031060 `"Quintana Roo"', add
label define geo2_mx2000_lbl 031061 `"Rio Lagartos"', add
label define geo2_mx2000_lbl 031062 `"Sacalum"', add
label define geo2_mx2000_lbl 031063 `"Samahil"', add
label define geo2_mx2000_lbl 031064 `"Sanahcat"', add
label define geo2_mx2000_lbl 031065 `"San Felipe"', add
label define geo2_mx2000_lbl 031066 `"Santa Elena"', add
label define geo2_mx2000_lbl 031067 `"Seye"', add
label define geo2_mx2000_lbl 031068 `"Sinanche"', add
label define geo2_mx2000_lbl 031069 `"Sotuta"', add
label define geo2_mx2000_lbl 031070 `"Sucila"', add
label define geo2_mx2000_lbl 031071 `"Sudzal"', add
label define geo2_mx2000_lbl 031072 `"Suma"', add
label define geo2_mx2000_lbl 031073 `"Tahdziu"', add
label define geo2_mx2000_lbl 031074 `"Tahmek"', add
label define geo2_mx2000_lbl 031075 `"Teabo"', add
label define geo2_mx2000_lbl 031076 `"Tecoh"', add
label define geo2_mx2000_lbl 031077 `"Tekal de Venegas"', add
label define geo2_mx2000_lbl 031078 `"Tekanto"', add
label define geo2_mx2000_lbl 031079 `"Tekax"', add
label define geo2_mx2000_lbl 031080 `"Tekit"', add
label define geo2_mx2000_lbl 031081 `"Tekom"', add
label define geo2_mx2000_lbl 031082 `"Telchac Pueblo"', add
label define geo2_mx2000_lbl 031083 `"Telchac Puerto"', add
label define geo2_mx2000_lbl 031084 `"Temax"', add
label define geo2_mx2000_lbl 031085 `"Temozon"', add
label define geo2_mx2000_lbl 031086 `"Tepakan"', add
label define geo2_mx2000_lbl 031087 `"Tetiz"', add
label define geo2_mx2000_lbl 031088 `"Teya"', add
label define geo2_mx2000_lbl 031089 `"Ticul"', add
label define geo2_mx2000_lbl 031090 `"Timucuy"', add
label define geo2_mx2000_lbl 031091 `"Tinum"', add
label define geo2_mx2000_lbl 031092 `"Tixcacalcupul"', add
label define geo2_mx2000_lbl 031093 `"Tixkokob"', add
label define geo2_mx2000_lbl 031094 `"Tixmehuac"', add
label define geo2_mx2000_lbl 031095 `"Tixpehual"', add
label define geo2_mx2000_lbl 031096 `"Tizimin"', add
label define geo2_mx2000_lbl 031097 `"Tunkas"', add
label define geo2_mx2000_lbl 031098 `"Tzucacab"', add
label define geo2_mx2000_lbl 031099 `"Uayma"', add
label define geo2_mx2000_lbl 031100 `"Ucu"', add
label define geo2_mx2000_lbl 031101 `"Uman"', add
label define geo2_mx2000_lbl 031102 `"Valladolid"', add
label define geo2_mx2000_lbl 031103 `"Xocchel"', add
label define geo2_mx2000_lbl 031104 `"Yaxcaba"', add
label define geo2_mx2000_lbl 031105 `"Yaxkukul"', add
label define geo2_mx2000_lbl 031106 `"Yobain"', add
label define geo2_mx2000_lbl 032001 `"Apozol"', add
label define geo2_mx2000_lbl 032002 `"Apulco"', add
label define geo2_mx2000_lbl 032003 `"Atolinga"', add
label define geo2_mx2000_lbl 032004 `"Benito Juarez"', add
label define geo2_mx2000_lbl 032005 `"Calera"', add
label define geo2_mx2000_lbl 032006 `"Canitas de Felipe Pescador"', add
label define geo2_mx2000_lbl 032007 `"Concepcion del Oro"', add
label define geo2_mx2000_lbl 032008 `"Cuauhtemoc"', add
label define geo2_mx2000_lbl 032009 `"Chalchihuites"', add
label define geo2_mx2000_lbl 032010 `"Fresnillo"', add
label define geo2_mx2000_lbl 032011 `"Trinidad Garcia de la Cadena"', add
label define geo2_mx2000_lbl 032012 `"Genaro codina"', add
label define geo2_mx2000_lbl 032013 `"General Enrique Estrada"', add
label define geo2_mx2000_lbl 032014 `"General Francisco R. Murguia"', add
label define geo2_mx2000_lbl 032015 `"Plateado de Joaquin Amaro, El"', add
label define geo2_mx2000_lbl 032016 `"General Panfilo Natera"', add
label define geo2_mx2000_lbl 032017 `"Guadalupe"', add
label define geo2_mx2000_lbl 032018 `"Huanusco"', add
label define geo2_mx2000_lbl 032019 `"Jalpa"', add
label define geo2_mx2000_lbl 032020 `"Jerez"', add
label define geo2_mx2000_lbl 032021 `"Jimenez del Teul"', add
label define geo2_mx2000_lbl 032022 `"Juan aldama"', add
label define geo2_mx2000_lbl 032023 `"Juchipila"', add
label define geo2_mx2000_lbl 032024 `"Loreto"', add
label define geo2_mx2000_lbl 032025 `"Luis Moya"', add
label define geo2_mx2000_lbl 032026 `"Mazapil"', add
label define geo2_mx2000_lbl 032027 `"Melchor Ocampo"', add
label define geo2_mx2000_lbl 032028 `"Mezquital del Oro"', add
label define geo2_mx2000_lbl 032029 `"Miguel Auza"', add
label define geo2_mx2000_lbl 032030 `"Momax"', add
label define geo2_mx2000_lbl 032031 `"Monte Escobedo"', add
label define geo2_mx2000_lbl 032032 `"Morelos"', add
label define geo2_mx2000_lbl 032033 `"Moyahua de Estrada"', add
label define geo2_mx2000_lbl 032034 `"Nochistlan de Mejia"', add
label define geo2_mx2000_lbl 032035 `"Noria de Angeles"', add
label define geo2_mx2000_lbl 032036 `"Ojocaliente"', add
label define geo2_mx2000_lbl 032037 `"Panuco"', add
label define geo2_mx2000_lbl 032038 `"Pinos"', add
label define geo2_mx2000_lbl 032039 `"Rio Grande"', add
label define geo2_mx2000_lbl 032040 `"Sain Alto"', add
label define geo2_mx2000_lbl 032041 `"Salvador, El"', add
label define geo2_mx2000_lbl 032042 `"Sombrerete"', add
label define geo2_mx2000_lbl 032043 `"Susticacan"', add
label define geo2_mx2000_lbl 032044 `"Tabasco"', add
label define geo2_mx2000_lbl 032045 `"Tepechitlan"', add
label define geo2_mx2000_lbl 032046 `"Tepetongo"', add
label define geo2_mx2000_lbl 032047 `"Teul de Gonzalez Ortega"', add
label define geo2_mx2000_lbl 032048 `"Tlaltenango de Sanchez Roman"', add
label define geo2_mx2000_lbl 032049 `"Valparaiso"', add
label define geo2_mx2000_lbl 032050 `"Vetagrande"', add
label define geo2_mx2000_lbl 032051 `"Villa de Cos"', add
label define geo2_mx2000_lbl 032052 `"Villa Garcia"', add
label define geo2_mx2000_lbl 032053 `"Villa Gonzalez Ortega"', add
label define geo2_mx2000_lbl 032054 `"Villa Hidalgo"', add
label define geo2_mx2000_lbl 032055 `"Villanueva"', add
label define geo2_mx2000_lbl 032056 `"Zacatecas"', add
label define geo2_mx2000_lbl 032057 `"Trancoso"', add
label values geo2_mx2000 geo2_mx2000_lbl

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

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label define sex_lbl 9 `"Unknown"', add
label values sex sex_lbl

label define bplmx_lbl 01 `"Aguascalientes"'
label define bplmx_lbl 02 `"Baja California"', add
label define bplmx_lbl 03 `"Baja California Sur"', add
label define bplmx_lbl 04 `"Campeche"', add
label define bplmx_lbl 05 `"Coahuila"', add
label define bplmx_lbl 06 `"Colima"', add
label define bplmx_lbl 07 `"Chiapas"', add
label define bplmx_lbl 08 `"Chihuahua"', add
label define bplmx_lbl 09 `"Distrito Federal"', add
label define bplmx_lbl 10 `"Durango"', add
label define bplmx_lbl 11 `"Guanajuato"', add
label define bplmx_lbl 12 `"Guerrero"', add
label define bplmx_lbl 13 `"Hidalgo"', add
label define bplmx_lbl 14 `"Jalisco"', add
label define bplmx_lbl 15 `"México"', add
label define bplmx_lbl 16 `"Michoacán"', add
label define bplmx_lbl 17 `"Morelos"', add
label define bplmx_lbl 18 `"Nayarit"', add
label define bplmx_lbl 19 `"Nuevo León"', add
label define bplmx_lbl 20 `"Oaxaca"', add
label define bplmx_lbl 21 `"Puebla"', add
label define bplmx_lbl 22 `"Querétaro"', add
label define bplmx_lbl 23 `"Quintana Roo"', add
label define bplmx_lbl 24 `"San Luis Potosí"', add
label define bplmx_lbl 25 `"Sinaloa"', add
label define bplmx_lbl 26 `"Sonora"', add
label define bplmx_lbl 27 `"Tabasco"', add
label define bplmx_lbl 28 `"Tamaulipas"', add
label define bplmx_lbl 29 `"Tlaxcala"', add
label define bplmx_lbl 30 `"Veracruz"', add
label define bplmx_lbl 31 `"Yucatán"', add
label define bplmx_lbl 32 `"Zacatecas"', add
label define bplmx_lbl 98 `"Foreign-born"', add
label define bplmx_lbl 99 `"Missing/unknown"', add
label values bplmx bplmx_lbl

label define school_lbl 0 `"NIU (not in universe)"'
label define school_lbl 1 `"Yes"', add
label define school_lbl 2 `"No, not specified"', add
label define school_lbl 3 `"No, attended in the past"', add
label define school_lbl 4 `"No, never attended"', add
label define school_lbl 9 `"Unknown/missing"', add
label values school school_lbl

label define yrschool_lbl 00 `"None or pre-school"'
label define yrschool_lbl 01 `"1 year"', add
label define yrschool_lbl 02 `"2 years"', add
label define yrschool_lbl 03 `"3 years"', add
label define yrschool_lbl 04 `"4 years"', add
label define yrschool_lbl 05 `"5 years"', add
label define yrschool_lbl 06 `"6 years"', add
label define yrschool_lbl 07 `"7 years"', add
label define yrschool_lbl 08 `"8 years"', add
label define yrschool_lbl 09 `"9 years"', add
label define yrschool_lbl 10 `"10 years"', add
label define yrschool_lbl 11 `"11 years"', add
label define yrschool_lbl 12 `"12 years"', add
label define yrschool_lbl 13 `"13 years"', add
label define yrschool_lbl 14 `"14 years"', add
label define yrschool_lbl 15 `"15 years"', add
label define yrschool_lbl 16 `"16 years"', add
label define yrschool_lbl 17 `"17 years"', add
label define yrschool_lbl 18 `"18 years or more"', add
label define yrschool_lbl 90 `"Not specified"', add
label define yrschool_lbl 91 `"Some primary"', add
label define yrschool_lbl 92 `"Some technical after primary"', add
label define yrschool_lbl 93 `"Some secondary"', add
label define yrschool_lbl 94 `"Some tertiary"', add
label define yrschool_lbl 95 `"Adult literacy"', add
label define yrschool_lbl 96 `"Special education"', add
label define yrschool_lbl 98 `"Unknown/missing"', add
label define yrschool_lbl 99 `"NIU (not in universe)"', add
label values yrschool yrschool_lbl

label define educmx_lbl 000 `"Less than primary"'
label define educmx_lbl 010 `"None, or never attended school"', add
label define educmx_lbl 020 `"Preschool or kindergarten"', add
label define educmx_lbl 021 `"Preschool, 1 year"', add
label define educmx_lbl 022 `"Preschool, 2 years"', add
label define educmx_lbl 023 `"Preschool, 3 years"', add
label define educmx_lbl 029 `"Preschool, unspecified years"', add
label define educmx_lbl 100 `"Primary"', add
label define educmx_lbl 101 `"Primary, 1 year"', add
label define educmx_lbl 102 `"Primary, 2 years"', add
label define educmx_lbl 103 `"Primary, 3 years"', add
label define educmx_lbl 104 `"Primary, 4 years"', add
label define educmx_lbl 105 `"Primary, 5 years"', add
label define educmx_lbl 106 `"Primary, 6 years"', add
label define educmx_lbl 109 `"Primary, years unspecified"', add
label define educmx_lbl 200 `"Lower secondary (middle or junior high school)"', add
label define educmx_lbl 210 `"Lower secondary, tech/commercial"', add
label define educmx_lbl 211 `"Lower secondary, tech/commercial, 1 year"', add
label define educmx_lbl 212 `"Lower secondary, tech/commercial, 2 years"', add
label define educmx_lbl 213 `"Lower secondary, tech/commercial, 3 years"', add
label define educmx_lbl 214 `"Lower secondary, tech/commercial, 4 years"', add
label define educmx_lbl 219 `"Lower secondary, tech/commercial, years unspec"', add
label define educmx_lbl 220 `"Lower secondary, general track"', add
label define educmx_lbl 221 `"Lower secondary, general track, 1 year"', add
label define educmx_lbl 222 `"Lower secondary, general track, 2 years"', add
label define educmx_lbl 223 `"Lower secondary, general track, 3 years"', add
label define educmx_lbl 229 `"Lower secondary, general track, years unspec."', add
label define educmx_lbl 300 `"Secondary (high school)"', add
label define educmx_lbl 310 `"Secondary tech/commercial"', add
label define educmx_lbl 311 `"Secondary tech/commercial, 1 year"', add
label define educmx_lbl 312 `"Secondary tech/commercial, 2 years"', add
label define educmx_lbl 313 `"Secondary tech/commercial, 3 years"', add
label define educmx_lbl 314 `"Secondary tech/commercial, 4 years"', add
label define educmx_lbl 315 `"Secondary tech/commercial, 5 years"', add
label define educmx_lbl 319 `"Secondary tech/commercial, years unspec"', add
label define educmx_lbl 320 `"Secondary, general track"', add
label define educmx_lbl 321 `"Secondary, general track, 1 year"', add
label define educmx_lbl 322 `"Secondary, general track, 2 years"', add
label define educmx_lbl 323 `"Secondary, general track, 3 years"', add
label define educmx_lbl 329 `"Secondary, general track, years unspec"', add
label define educmx_lbl 330 `"Technological track"', add
label define educmx_lbl 331 `"Secondary, technological track, year 1"', add
label define educmx_lbl 332 `"Secondary, technological track, years 2"', add
label define educmx_lbl 333 `"Secondary, technological track, years 3"', add
label define educmx_lbl 339 `"Secondary, technological track, year unspecified"', add
label define educmx_lbl 400 `"Normal school (teacher-training)"', add
label define educmx_lbl 401 `"Normal, 1 year"', add
label define educmx_lbl 402 `"Normal, 2 years"', add
label define educmx_lbl 403 `"Normal, 3 years"', add
label define educmx_lbl 404 `"Normal, 4 years"', add
label define educmx_lbl 409 `"Normal, years unspec"', add
label define educmx_lbl 500 `"Post-secondary technical"', add
label define educmx_lbl 501 `"Post-secondary technical, 1 year"', add
label define educmx_lbl 502 `"Post-secondary technical, 2 years"', add
label define educmx_lbl 503 `"Post-secondary technical, 3 years"', add
label define educmx_lbl 504 `"Post-secondary technical, 4 years"', add
label define educmx_lbl 505 `"Post-secondary technical, 5 years"', add
label define educmx_lbl 509 `"Post-secondary technical, years unspec"', add
label define educmx_lbl 600 `"University"', add
label define educmx_lbl 610 `"University undergraduate"', add
label define educmx_lbl 611 `"University undergraduate, 1 year"', add
label define educmx_lbl 612 `"University undergraduate, 2 years"', add
label define educmx_lbl 613 `"University undergraduate, 3 years"', add
label define educmx_lbl 614 `"University undergraduate, 4 years"', add
label define educmx_lbl 615 `"University undergraduate, 5 years"', add
label define educmx_lbl 616 `"University undergraduate, 6 years"', add
label define educmx_lbl 617 `"University undergraduate, 7 years"', add
label define educmx_lbl 618 `"University undergraduate, 8+ years"', add
label define educmx_lbl 619 `"University undergraduate, years unspec"', add
label define educmx_lbl 620 `"University graduate"', add
label define educmx_lbl 621 `"University graduate, 1 year"', add
label define educmx_lbl 622 `"University graduate, 2 years"', add
label define educmx_lbl 623 `"University graduate, 3 years"', add
label define educmx_lbl 624 `"University graduate, 4 years"', add
label define educmx_lbl 625 `"University graduate, 5 years"', add
label define educmx_lbl 626 `"University graduate, 6 years"', add
label define educmx_lbl 627 `"University graduate, 7 years"', add
label define educmx_lbl 628 `"University graduate, 8+ years"', add
label define educmx_lbl 629 `"University graduate, years unspec"', add
label define educmx_lbl 630 `"Masters degree (2005-2010)"', add
label define educmx_lbl 631 `"Masters, 1 year"', add
label define educmx_lbl 632 `"Masters, 2 years"', add
label define educmx_lbl 633 `"3 years"', add
label define educmx_lbl 639 `"Masters, year unspecified"', add
label define educmx_lbl 640 `"Doctoral degree (2005-2010)"', add
label define educmx_lbl 641 `"Doctoral, 1 year"', add
label define educmx_lbl 642 `"Doctoral, 2 years"', add
label define educmx_lbl 643 `"Doctoral, 3 years"', add
label define educmx_lbl 644 `"Doctoral, 4 years"', add
label define educmx_lbl 645 `"Doctoral, 5 years"', add
label define educmx_lbl 646 `"Doctoral, 6 years"', add
label define educmx_lbl 649 `"Doctoral, years unspecified"', add
label define educmx_lbl 650 `"Specialty degree"', add
label define educmx_lbl 651 `"Specialty, 1 year"', add
label define educmx_lbl 652 `"Specialty, 2 years"', add
label define educmx_lbl 659 `"Specialty, years unspecified"', add
label define educmx_lbl 700 `"Unspecified post-secondary"', add
label define educmx_lbl 701 `"Unspecified post-secondary, 1 year"', add
label define educmx_lbl 702 `"Unspecified post-secondary, 2 years"', add
label define educmx_lbl 703 `"Unspecified post-secondary, 3 years"', add
label define educmx_lbl 704 `"Unspecified post-secondary, 4 years"', add
label define educmx_lbl 705 `"Unspecified post-secondary, 5 years"', add
label define educmx_lbl 706 `"Unspecified post-secondary, 6 years"', add
label define educmx_lbl 707 `"Unspecified post-secondary, 7 years"', add
label define educmx_lbl 708 `"Unspecified post-secondary, 8+ years"', add
label define educmx_lbl 800 `"Unknown/missing"', add
label define educmx_lbl 999 `"NIU (not in universe)"', add
label values educmx educmx_lbl

label define empstat_lbl 0 `"NIU (not in universe)"'
label define empstat_lbl 1 `"Employed"', add
label define empstat_lbl 2 `"Unemployed"', add
label define empstat_lbl 3 `"Inactive"', add
label define empstat_lbl 9 `"Unknown/missing"', add
label values empstat empstat_lbl

label define empstatd_lbl 000 `"NIU (not in universe)"'
label define empstatd_lbl 100 `"Employed, not specified"', add
label define empstatd_lbl 110 `"At work"', add
label define empstatd_lbl 111 `"At work, and 'student'"', add
label define empstatd_lbl 112 `"At work, and 'housework'"', add
label define empstatd_lbl 113 `"At work, and 'seeking work'"', add
label define empstatd_lbl 114 `"At work, and 'retired'"', add
label define empstatd_lbl 115 `"At work, and 'no work'"', add
label define empstatd_lbl 116 `"At work, and other situation"', add
label define empstatd_lbl 117 `"At work, family holding, not specified"', add
label define empstatd_lbl 118 `"At work, family holding, not agricultural"', add
label define empstatd_lbl 119 `"At work, family holding, agricultural"', add
label define empstatd_lbl 120 `"Have job, not at work in reference period"', add
label define empstatd_lbl 130 `"Armed forces"', add
label define empstatd_lbl 131 `"Armed forces, at work"', add
label define empstatd_lbl 132 `"Armed forces, not at work in reference period"', add
label define empstatd_lbl 133 `"Military trainee"', add
label define empstatd_lbl 140 `"Marginally employed"', add
label define empstatd_lbl 200 `"Unemployed, not specified"', add
label define empstatd_lbl 201 `"Unemployed 6 or more months"', add
label define empstatd_lbl 202 `"Worked fewer than 6 months, permanent job"', add
label define empstatd_lbl 203 `"Worked fewer than 6 months, temporary job"', add
label define empstatd_lbl 210 `"Unemployed, experienced worker"', add
label define empstatd_lbl 220 `"Unemployed, new worker"', add
label define empstatd_lbl 230 `"No work available"', add
label define empstatd_lbl 240 `"Inactive unemployed"', add
label define empstatd_lbl 300 `"Inactive (not in labor force)"', add
label define empstatd_lbl 310 `"Housework"', add
label define empstatd_lbl 320 `"Unable to work, disabled or health reasons"', add
label define empstatd_lbl 321 `"Permanent disability"', add
label define empstatd_lbl 322 `"Temporary illness"', add
label define empstatd_lbl 323 `"Disabled or imprisoned"', add
label define empstatd_lbl 330 `"In school"', add
label define empstatd_lbl 340 `"Retirees and living on rent"', add
label define empstatd_lbl 341 `"Living on rents"', add
label define empstatd_lbl 342 `"Living on rents or pension"', add
label define empstatd_lbl 343 `"Retirees/pensioners"', add
label define empstatd_lbl 344 `"Retired"', add
label define empstatd_lbl 345 `"Pensioner"', add
label define empstatd_lbl 346 `"Non-retirement pension"', add
label define empstatd_lbl 347 `"Disability pension"', add
label define empstatd_lbl 348 `"Retired without benefits"', add
label define empstatd_lbl 350 `"Elderly"', add
label define empstatd_lbl 351 `"Elderly or disabled"', add
label define empstatd_lbl 360 `"Institutionalized"', add
label define empstatd_lbl 361 `"Prisoner"', add
label define empstatd_lbl 370 `"Intermittent worker"', add
label define empstatd_lbl 371 `"Not working, seasonal worker"', add
label define empstatd_lbl 372 `"Not working, occasional worker"', add
label define empstatd_lbl 380 `"Other income recipient"', add
label define empstatd_lbl 390 `"Inactive, other reasons"', add
label define empstatd_lbl 391 `"Too young to work"', add
label define empstatd_lbl 392 `"Dependent"', add
label define empstatd_lbl 999 `"Unknown/missing"', add
label values empstatd empstatd_lbl

label define occisco_lbl 01 `"Legislators, senior officials and managers"'
label define occisco_lbl 02 `"Professionals"', add
label define occisco_lbl 03 `"Technicians and associate professionals"', add
label define occisco_lbl 04 `"Clerks"', add
label define occisco_lbl 05 `"Service workers and shop and market sales"', add
label define occisco_lbl 06 `"Skilled agricultural and fishery workers"', add
label define occisco_lbl 07 `"Crafts and related trades workers"', add
label define occisco_lbl 08 `"Plant and machine operators and assemblers"', add
label define occisco_lbl 09 `"Elementary occupations"', add
label define occisco_lbl 10 `"Armed forces"', add
label define occisco_lbl 11 `"Other occupations, unspecified or n.e.c."', add
label define occisco_lbl 97 `"Response suppressed"', add
label define occisco_lbl 98 `"Unknown"', add
label define occisco_lbl 99 `"NIU (not in universe)"', add
label values occisco occisco_lbl

label define indgen_lbl 000 `"NIU (not in universe)"'
label define indgen_lbl 010 `"Agriculture, fishing, and forestry"', add
label define indgen_lbl 020 `"Mining and extraction"', add
label define indgen_lbl 030 `"Manufacturing"', add
label define indgen_lbl 040 `"Electricity, gas, water and waste management"', add
label define indgen_lbl 050 `"Construction"', add
label define indgen_lbl 060 `"Wholesale and retail trade"', add
label define indgen_lbl 070 `"Hotels and restaurants"', add
label define indgen_lbl 080 `"Transportation, storage,  and communications"', add
label define indgen_lbl 090 `"Financial services and insurance"', add
label define indgen_lbl 100 `"Public administration and defense"', add
label define indgen_lbl 110 `"Services, not specified"', add
label define indgen_lbl 111 `"Business services and real estate"', add
label define indgen_lbl 112 `"Education"', add
label define indgen_lbl 113 `"Health and social work"', add
label define indgen_lbl 114 `"Other services"', add
label define indgen_lbl 120 `"Private household services"', add
label define indgen_lbl 130 `"Other industry, n.e.c."', add
label define indgen_lbl 998 `"Response suppressed"', add
label define indgen_lbl 999 `"Unknown"', add
label values indgen indgen_lbl

label define classwk_lbl 0 `"NIU (not in universe)"'
label define classwk_lbl 1 `"Self-employed"', add
label define classwk_lbl 2 `"Wage/salary worker"', add
label define classwk_lbl 3 `"Unpaid worker"', add
label define classwk_lbl 4 `"Other"', add
label define classwk_lbl 9 `"Unknown/missing"', add
label values classwk classwk_lbl

label define classwkd_lbl 000 `"NIU (not in universe)"'
label define classwkd_lbl 100 `"Self-employed"', add
label define classwkd_lbl 101 `"Self-employed, unincorporated"', add
label define classwkd_lbl 102 `"Self-employed, incorporated"', add
label define classwkd_lbl 110 `"Employer"', add
label define classwkd_lbl 111 `"Sharecropper, employer"', add
label define classwkd_lbl 120 `"Working on own account"', add
label define classwkd_lbl 121 `"Own account, agriculture"', add
label define classwkd_lbl 122 `"Domestic worker, self-employed"', add
label define classwkd_lbl 123 `"Subsistence worker, own consumption"', add
label define classwkd_lbl 124 `"Own account, other"', add
label define classwkd_lbl 125 `"Own account, without temporary/unpaid help"', add
label define classwkd_lbl 126 `"Own account, with temporary/unpaid help"', add
label define classwkd_lbl 130 `"Member of cooperative"', add
label define classwkd_lbl 140 `"Sharecropper"', add
label define classwkd_lbl 141 `"Sharecropper, self-employed"', add
label define classwkd_lbl 142 `"Sharecropper, employee"', add
label define classwkd_lbl 150 `"Kibbutz member"', add
label define classwkd_lbl 199 `"Self-employed, not specified"', add
label define classwkd_lbl 200 `"Wage/salary worker"', add
label define classwkd_lbl 201 `"Management"', add
label define classwkd_lbl 202 `"Non-management"', add
label define classwkd_lbl 203 `"White collar (non-manual)"', add
label define classwkd_lbl 204 `"Blue collar (manual)"', add
label define classwkd_lbl 205 `"White or blue collar"', add
label define classwkd_lbl 206 `"Day laborer"', add
label define classwkd_lbl 207 `"Employee, with a permanent job"', add
label define classwkd_lbl 208 `"Employee, occasional, temporary, contract"', add
label define classwkd_lbl 209 `"Employee without legal contract"', add
label define classwkd_lbl 210 `"Wage/salary worker, private employer"', add
label define classwkd_lbl 211 `"Apprentice"', add
label define classwkd_lbl 212 `"Religious worker"', add
label define classwkd_lbl 213 `"Wage/salary worker, non-profit, NGO"', add
label define classwkd_lbl 214 `"White collar, private"', add
label define classwkd_lbl 215 `"Blue collar, private"', add
label define classwkd_lbl 216 `"Paid family worker"', add
label define classwkd_lbl 217 `"Cooperative employee"', add
label define classwkd_lbl 220 `"Wage/salary worker, government"', add
label define classwkd_lbl 221 `"Federal, government employee"', add
label define classwkd_lbl 222 `"State government employee"', add
label define classwkd_lbl 223 `"Local government employee"', add
label define classwkd_lbl 224 `"White collar, public"', add
label define classwkd_lbl 225 `"Blue collar, public"', add
label define classwkd_lbl 226 `"Public companies"', add
label define classwkd_lbl 227 `"Civil servants, local collectives"', add
label define classwkd_lbl 230 `"Domestic worker (work for private household)"', add
label define classwkd_lbl 240 `"Seasonal migrant"', add
label define classwkd_lbl 241 `"Seasonal migrant, no broker"', add
label define classwkd_lbl 242 `"Seasonal migrant, uses broker"', add
label define classwkd_lbl 250 `"Other wage and salary"', add
label define classwkd_lbl 251 `"Canal zone/commission employee"', add
label define classwkd_lbl 252 `"Government employment/training program"', add
label define classwkd_lbl 253 `"Mixed state/private enterprise/parastatal"', add
label define classwkd_lbl 254 `"Government public work program"', add
label define classwkd_lbl 255 `"State enterprise employee"', add
label define classwkd_lbl 256 `"Coordinated and continuous collaboration job"', add
label define classwkd_lbl 300 `"Unpaid worker"', add
label define classwkd_lbl 310 `"Unpaid family worker"', add
label define classwkd_lbl 320 `"Apprentice, unpaid or unspecified"', add
label define classwkd_lbl 330 `"Trainee"', add
label define classwkd_lbl 340 `"Apprentice or trainee"', add
label define classwkd_lbl 350 `"Works for others without wage"', add
label define classwkd_lbl 400 `"Other"', add
label define classwkd_lbl 999 `"Unknown/missing"', add
label values classwkd classwkd_lbl

label define hrswork1_lbl 000 `"0 hours"'
label define hrswork1_lbl 001 `"1 hour"', add
label define hrswork1_lbl 002 `"2 hours"', add
label define hrswork1_lbl 003 `"3 hours"', add
label define hrswork1_lbl 004 `"4 hours"', add
label define hrswork1_lbl 005 `"5 hours"', add
label define hrswork1_lbl 006 `"6 hours"', add
label define hrswork1_lbl 007 `"7 hours"', add
label define hrswork1_lbl 008 `"8 hours"', add
label define hrswork1_lbl 009 `"9 hours"', add
label define hrswork1_lbl 010 `"10 hours"', add
label define hrswork1_lbl 011 `"11 hours"', add
label define hrswork1_lbl 012 `"12 hours"', add
label define hrswork1_lbl 013 `"13 hours"', add
label define hrswork1_lbl 014 `"14 hours"', add
label define hrswork1_lbl 015 `"15 hours"', add
label define hrswork1_lbl 016 `"16 hours"', add
label define hrswork1_lbl 017 `"17 hours"', add
label define hrswork1_lbl 018 `"18 hours"', add
label define hrswork1_lbl 019 `"19 hours"', add
label define hrswork1_lbl 020 `"20 hours"', add
label define hrswork1_lbl 021 `"21 hours"', add
label define hrswork1_lbl 022 `"22 hours"', add
label define hrswork1_lbl 023 `"23 hours"', add
label define hrswork1_lbl 024 `"24 hours"', add
label define hrswork1_lbl 025 `"25 hours"', add
label define hrswork1_lbl 026 `"26 hours"', add
label define hrswork1_lbl 027 `"27 hours"', add
label define hrswork1_lbl 028 `"28 hours"', add
label define hrswork1_lbl 029 `"29 hours"', add
label define hrswork1_lbl 030 `"30 hours"', add
label define hrswork1_lbl 031 `"31 hours"', add
label define hrswork1_lbl 032 `"32 hours"', add
label define hrswork1_lbl 033 `"33 hours"', add
label define hrswork1_lbl 034 `"34 hours"', add
label define hrswork1_lbl 035 `"35 hours"', add
label define hrswork1_lbl 036 `"36 hours"', add
label define hrswork1_lbl 037 `"37 hours"', add
label define hrswork1_lbl 038 `"38 hours"', add
label define hrswork1_lbl 039 `"39 hours"', add
label define hrswork1_lbl 040 `"40 hours"', add
label define hrswork1_lbl 041 `"41 hours"', add
label define hrswork1_lbl 042 `"42 hours"', add
label define hrswork1_lbl 043 `"43 hours"', add
label define hrswork1_lbl 044 `"44 hours"', add
label define hrswork1_lbl 045 `"45 hours"', add
label define hrswork1_lbl 046 `"46 hours"', add
label define hrswork1_lbl 047 `"47 hours"', add
label define hrswork1_lbl 048 `"48 hours"', add
label define hrswork1_lbl 049 `"49 hours"', add
label define hrswork1_lbl 050 `"50 hours"', add
label define hrswork1_lbl 051 `"51 hours"', add
label define hrswork1_lbl 052 `"52 hours"', add
label define hrswork1_lbl 053 `"53 hours"', add
label define hrswork1_lbl 054 `"54 hours"', add
label define hrswork1_lbl 055 `"55 hours"', add
label define hrswork1_lbl 056 `"56 hours"', add
label define hrswork1_lbl 057 `"57 hours"', add
label define hrswork1_lbl 058 `"58 hours"', add
label define hrswork1_lbl 059 `"59 hours"', add
label define hrswork1_lbl 060 `"60 hours"', add
label define hrswork1_lbl 061 `"61 hours"', add
label define hrswork1_lbl 062 `"62 hours"', add
label define hrswork1_lbl 063 `"63 hours"', add
label define hrswork1_lbl 064 `"64 hours"', add
label define hrswork1_lbl 065 `"65 hours"', add
label define hrswork1_lbl 066 `"66 hours"', add
label define hrswork1_lbl 067 `"67 hours"', add
label define hrswork1_lbl 068 `"68 hours"', add
label define hrswork1_lbl 069 `"69 hours"', add
label define hrswork1_lbl 070 `"70 hours"', add
label define hrswork1_lbl 071 `"71 hours"', add
label define hrswork1_lbl 072 `"72 hours"', add
label define hrswork1_lbl 073 `"73 hours"', add
label define hrswork1_lbl 074 `"74 hours"', add
label define hrswork1_lbl 075 `"75 hours"', add
label define hrswork1_lbl 076 `"76 hours"', add
label define hrswork1_lbl 077 `"77 hours"', add
label define hrswork1_lbl 078 `"78 hours"', add
label define hrswork1_lbl 079 `"79 hours"', add
label define hrswork1_lbl 080 `"80 hours"', add
label define hrswork1_lbl 081 `"81 hours"', add
label define hrswork1_lbl 082 `"82 hours"', add
label define hrswork1_lbl 083 `"83 hours"', add
label define hrswork1_lbl 084 `"84 hours"', add
label define hrswork1_lbl 085 `"85 hours"', add
label define hrswork1_lbl 086 `"86 hours"', add
label define hrswork1_lbl 087 `"87 hours"', add
label define hrswork1_lbl 088 `"88 hours"', add
label define hrswork1_lbl 089 `"89 hours"', add
label define hrswork1_lbl 090 `"90 hours"', add
label define hrswork1_lbl 091 `"91 hours"', add
label define hrswork1_lbl 092 `"92 hours"', add
label define hrswork1_lbl 093 `"93 hours"', add
label define hrswork1_lbl 094 `"94 hours"', add
label define hrswork1_lbl 095 `"95 hours"', add
label define hrswork1_lbl 096 `"96 hours"', add
label define hrswork1_lbl 097 `"97 hours"', add
label define hrswork1_lbl 098 `"98 hours"', add
label define hrswork1_lbl 099 `"99 hours"', add
label define hrswork1_lbl 100 `"100 hours"', add
label define hrswork1_lbl 101 `"101 hours"', add
label define hrswork1_lbl 102 `"102 hours"', add
label define hrswork1_lbl 103 `"103 hours"', add
label define hrswork1_lbl 104 `"104 hours"', add
label define hrswork1_lbl 105 `"105 hours"', add
label define hrswork1_lbl 106 `"106 hours"', add
label define hrswork1_lbl 107 `"107 hours"', add
label define hrswork1_lbl 108 `"108 hours"', add
label define hrswork1_lbl 109 `"109 hours"', add
label define hrswork1_lbl 110 `"110 hours"', add
label define hrswork1_lbl 111 `"111 hours"', add
label define hrswork1_lbl 112 `"112 hours"', add
label define hrswork1_lbl 113 `"113 hours"', add
label define hrswork1_lbl 114 `"114 hours"', add
label define hrswork1_lbl 115 `"115 hours"', add
label define hrswork1_lbl 116 `"116 hours"', add
label define hrswork1_lbl 117 `"117 hours"', add
label define hrswork1_lbl 118 `"118 hours"', add
label define hrswork1_lbl 119 `"119 hours"', add
label define hrswork1_lbl 120 `"120 hours"', add
label define hrswork1_lbl 121 `"121 hours"', add
label define hrswork1_lbl 122 `"122 hours"', add
label define hrswork1_lbl 123 `"123 hours"', add
label define hrswork1_lbl 124 `"124 hours"', add
label define hrswork1_lbl 125 `"125 hours"', add
label define hrswork1_lbl 126 `"126 hours"', add
label define hrswork1_lbl 127 `"127 hours"', add
label define hrswork1_lbl 128 `"128 hours"', add
label define hrswork1_lbl 129 `"129 hours"', add
label define hrswork1_lbl 130 `"130 hours"', add
label define hrswork1_lbl 131 `"131 hours"', add
label define hrswork1_lbl 132 `"132 hours"', add
label define hrswork1_lbl 133 `"133 hours"', add
label define hrswork1_lbl 134 `"134 hours"', add
label define hrswork1_lbl 135 `"135 hours"', add
label define hrswork1_lbl 136 `"136 hours"', add
label define hrswork1_lbl 137 `"137 hours"', add
label define hrswork1_lbl 138 `"138 hours"', add
label define hrswork1_lbl 139 `"139 hours"', add
label define hrswork1_lbl 140 `"140+ hours"', add
label define hrswork1_lbl 998 `"Unknown"', add
label define hrswork1_lbl 999 `"NIU (not in universe)"', add
label values hrswork1 hrswork1_lbl

label define migrate5_lbl 00 `"NIU (not in universe)"'
label define migrate5_lbl 10 `"Same major administrative unit"', add
label define migrate5_lbl 11 `"Same major, same minor administrative unit"', add
label define migrate5_lbl 12 `"Same major, different minor administrative unit"', add
label define migrate5_lbl 20 `"Different major administrative unit"', add
label define migrate5_lbl 30 `"Abroad"', add
label define migrate5_lbl 99 `"Unknown/missing"', add
label values migrate5 migrate5_lbl

label define mx2000a_resent_lbl 000 `"NIU (not in universe)"'
label define mx2000a_resent_lbl 001 `"Aguascalientes"', add
label define mx2000a_resent_lbl 002 `"Baja California"', add
label define mx2000a_resent_lbl 003 `"Baja California Sur"', add
label define mx2000a_resent_lbl 004 `"Campeche"', add
label define mx2000a_resent_lbl 005 `"Coahuila"', add
label define mx2000a_resent_lbl 006 `"Colima"', add
label define mx2000a_resent_lbl 007 `"Chiapas"', add
label define mx2000a_resent_lbl 008 `"Chihuahua"', add
label define mx2000a_resent_lbl 009 `"Distrito Federal"', add
label define mx2000a_resent_lbl 010 `"Durango"', add
label define mx2000a_resent_lbl 011 `"Guanajuato"', add
label define mx2000a_resent_lbl 012 `"Guerrero"', add
label define mx2000a_resent_lbl 013 `"Hidalgo"', add
label define mx2000a_resent_lbl 014 `"Jalisco"', add
label define mx2000a_resent_lbl 015 `"Mexico"', add
label define mx2000a_resent_lbl 016 `"Michoacan"', add
label define mx2000a_resent_lbl 017 `"Morelos"', add
label define mx2000a_resent_lbl 018 `"Nayarit"', add
label define mx2000a_resent_lbl 019 `"Nuevo Leon"', add
label define mx2000a_resent_lbl 020 `"Oaxaca"', add
label define mx2000a_resent_lbl 021 `"Puebla"', add
label define mx2000a_resent_lbl 022 `"Queretaro"', add
label define mx2000a_resent_lbl 023 `"Quintana Roo"', add
label define mx2000a_resent_lbl 024 `"San Luis Potosi"', add
label define mx2000a_resent_lbl 025 `"Sinaloa"', add
label define mx2000a_resent_lbl 026 `"Sonora"', add
label define mx2000a_resent_lbl 027 `"Tabasco"', add
label define mx2000a_resent_lbl 028 `"Tamaulipas"', add
label define mx2000a_resent_lbl 029 `"Tlaxcala"', add
label define mx2000a_resent_lbl 030 `"Veracruz"', add
label define mx2000a_resent_lbl 031 `"Yucatan"', add
label define mx2000a_resent_lbl 032 `"Zacatecas"', add
label define mx2000a_resent_lbl 100 `"Africa"', add
label define mx2000a_resent_lbl 101 `"Angola"', add
label define mx2000a_resent_lbl 102 `"Algeria"', add
label define mx2000a_resent_lbl 104 `"Benin"', add
label define mx2000a_resent_lbl 106 `"Burkina Faso"', add
label define mx2000a_resent_lbl 108 `"Cape Verde"', add
label define mx2000a_resent_lbl 109 `"Cameroon"', add
label define mx2000a_resent_lbl 111 `"Ceuta"', add
label define mx2000a_resent_lbl 113 `"Congo"', add
label define mx2000a_resent_lbl 114 `"Ivory Coast"', add
label define mx2000a_resent_lbl 117 `"Egypt"', add
label define mx2000a_resent_lbl 119 `"Ethiopia"', add
label define mx2000a_resent_lbl 120 `"Gabon"', add
label define mx2000a_resent_lbl 121 `"Gambia"', add
label define mx2000a_resent_lbl 122 `"Ghana"', add
label define mx2000a_resent_lbl 123 `"Guinea"', add
label define mx2000a_resent_lbl 126 `"Kenya"', add
label define mx2000a_resent_lbl 135 `"Morocco"', add
label define mx2000a_resent_lbl 139 `"Mozambique"', add
label define mx2000a_resent_lbl 140 `"Namibia"', add
label define mx2000a_resent_lbl 142 `"Nigeria"', add
label define mx2000a_resent_lbl 147 `"Saint Helen"', add
label define mx2000a_resent_lbl 151 `"Sierra Leone"', add
label define mx2000a_resent_lbl 154 `"South Africa"', add
label define mx2000a_resent_lbl 165 `"Uganda"', add
label define mx2000a_resent_lbl 200 `"America"', add
label define mx2000a_resent_lbl 204 `"Argentina"', add
label define mx2000a_resent_lbl 205 `"Aruba"', add
label define mx2000a_resent_lbl 207 `"Barbados"', add
label define mx2000a_resent_lbl 208 `"Belize"', add
label define mx2000a_resent_lbl 210 `"Bolivia"', add
label define mx2000a_resent_lbl 211 `"Brazil"', add
label define mx2000a_resent_lbl 212 `"Cayman Islands"', add
label define mx2000a_resent_lbl 213 `"Canada"', add
label define mx2000a_resent_lbl 214 `"Colombia"', add
label define mx2000a_resent_lbl 215 `"Costa Rica"', add
label define mx2000a_resent_lbl 216 `"Cuba"', add
label define mx2000a_resent_lbl 217 `"Chile"', add
label define mx2000a_resent_lbl 219 `"Ecuador"', add
label define mx2000a_resent_lbl 220 `"El Salvador"', add
label define mx2000a_resent_lbl 221 `"United States of America"', add
label define mx2000a_resent_lbl 222 `"Grenada"', add
label define mx2000a_resent_lbl 224 `"Guadeloupe"', add
label define mx2000a_resent_lbl 225 `"Guatemala"', add
label define mx2000a_resent_lbl 226 `"Guyana"', add
label define mx2000a_resent_lbl 227 `"French Guyana"', add
label define mx2000a_resent_lbl 228 `"Haiti"', add
label define mx2000a_resent_lbl 229 `"Honduras"', add
label define mx2000a_resent_lbl 230 `"Jamaica"', add
label define mx2000a_resent_lbl 232 `"Martinique"', add
label define mx2000a_resent_lbl 234 `"Nicaragua"', add
label define mx2000a_resent_lbl 235 `"Panama"', add
label define mx2000a_resent_lbl 236 `"Paraguay"', add
label define mx2000a_resent_lbl 237 `"Peru"', add
label define mx2000a_resent_lbl 238 `"Puerto Rico"', add
label define mx2000a_resent_lbl 239 `"Dominican Republic"', add
label define mx2000a_resent_lbl 243 `"Saint Lucia"', add
label define mx2000a_resent_lbl 247 `"Uruguay"', add
label define mx2000a_resent_lbl 250 `"Venezuela"', add
label define mx2000a_resent_lbl 300 `"Asia"', add
label define mx2000a_resent_lbl 301 `"Afghanistan"', add
label define mx2000a_resent_lbl 303 `"Armenia"', add
label define mx2000a_resent_lbl 304 `"Azerbaijan"', add
label define mx2000a_resent_lbl 311 `"Korea"', add
label define mx2000a_resent_lbl 313 `"South Korea"', add
label define mx2000a_resent_lbl 314 `"China"', add
label define mx2000a_resent_lbl 315 `"People's Republic of China"', add
label define mx2000a_resent_lbl 316 `"Taiwan (Republic of China)"', add
label define mx2000a_resent_lbl 318 `"Republica De Chipre"', add
label define mx2000a_resent_lbl 321 `"United Arab Emirates"', add
label define mx2000a_resent_lbl 322 `"Philippines"', add
label define mx2000a_resent_lbl 323 `"Georgia"', add
label define mx2000a_resent_lbl 325 `"India"', add
label define mx2000a_resent_lbl 326 `"Indonesia"', add
label define mx2000a_resent_lbl 328 `"Iran"', add
label define mx2000a_resent_lbl 329 `"Israel"', add
label define mx2000a_resent_lbl 330 `"Japan"', add
label define mx2000a_resent_lbl 333 `"Kyrgyzstan"', add
label define mx2000a_resent_lbl 335 `"Lebanon"', add
label define mx2000a_resent_lbl 337 `"Malaysia"', add
label define mx2000a_resent_lbl 343 `"Pakistan"', add
label define mx2000a_resent_lbl 346 `"Singapore"', add
label define mx2000a_resent_lbl 347 `"Syria"', add
label define mx2000a_resent_lbl 349 `"Thailand"', add
label define mx2000a_resent_lbl 352 `"Turkey"', add
label define mx2000a_resent_lbl 354 `"Vietnam"', add
label define mx2000a_resent_lbl 400 `"Europa"', add
label define mx2000a_resent_lbl 401 `"Albania"', add
label define mx2000a_resent_lbl 402 `"Germany"', add
label define mx2000a_resent_lbl 405 `"Austria"', add
label define mx2000a_resent_lbl 408 `"Belgium"', add
label define mx2000a_resent_lbl 410 `"Bulgaria"', add
label define mx2000a_resent_lbl 411 `"Croatia"', add
label define mx2000a_resent_lbl 412 `"Denmark"', add
label define mx2000a_resent_lbl 413 `"Slovakia"', add
label define mx2000a_resent_lbl 415 `"Spain"', add
label define mx2000a_resent_lbl 418 `"Finland"', add
label define mx2000a_resent_lbl 419 `"France"', add
label define mx2000a_resent_lbl 421 `"Greece"', add
label define mx2000a_resent_lbl 422 `"Hungary"', add
label define mx2000a_resent_lbl 423 `"Ireland"', add
label define mx2000a_resent_lbl 425 `"Italy"', add
label define mx2000a_resent_lbl 426 `"Latvia"', add
label define mx2000a_resent_lbl 428 `"Lithuania"', add
label define mx2000a_resent_lbl 429 `"Luxembourg"', add
label define mx2000a_resent_lbl 432 `"Isle of Man"', add
label define mx2000a_resent_lbl 435 `"Norway"', add
label define mx2000a_resent_lbl 436 `"Holand"', add
label define mx2000a_resent_lbl 437 `"Poland"', add
label define mx2000a_resent_lbl 438 `"Portugal"', add
label define mx2000a_resent_lbl 439 `"United Kingdon"', add
label define mx2000a_resent_lbl 440 `"Czech Republic"', add
label define mx2000a_resent_lbl 441 `"Romania"', add
label define mx2000a_resent_lbl 442 `"Russia"', add
label define mx2000a_resent_lbl 445 `"Sweden"', add
label define mx2000a_resent_lbl 446 `"Switzerland"', add
label define mx2000a_resent_lbl 447 `"Ukraine"', add
label define mx2000a_resent_lbl 501 `"Australia"', add
label define mx2000a_resent_lbl 502 `"Baker Island"', add
label define mx2000a_resent_lbl 505 `"Guam Island"', add
label define mx2000a_resent_lbl 514 `"Federated States of Micronesia"', add
label define mx2000a_resent_lbl 515 `"Midway Islands"', add
label define mx2000a_resent_lbl 520 `"New Zealand"', add
label define mx2000a_resent_lbl 525 `"French Polynesia"', add
label define mx2000a_resent_lbl 527 `"Western Samoa"', add
label define mx2000a_resent_lbl 600 `"Foreigner, Other country"', add
label define mx2000a_resent_lbl 999 `"Not specified"', add
label values mx2000a_resent mx2000a_resent_lbl

**cleanup

//age heaping
sum age
gen agebin = round(age,5) if mod(age,5)<=1|mod(age,5)==4 //group age heaps surrounding multiple of 5
replace agebin = age+.5 if mod(age,5)==2 //group non-heap ages
replace agebin = age-.5 if mod(age,5)==3
label var agebin "Age"

//geography
tab bplmx
recode bplmx (98/99=.)
ren bplmx edo_born

ren geo1_mx2000 CVE_EDO
ren geo2_mx2000 CVE_MUN
replace CVE_MUN = mod(CVE_MUN,1000) /*remove state code from start of muni code*/
do "$programs/01_dataprep/master_munis.do"

ren mx2000a_resent edo_5years
replace edo_5years=. if edo_5years>90

ren mx2000a_resmun mun_5years
replace mun_5years = . if mun_5years>900
do "$programs/01_dataprep/master_muni_5years.do"

tab urban
gen urbanres = urban-1
label var urbanres "Lives in urban area"
drop urban

cap tab migrate5
cap drop migrate5 /*use Susan's code for migration*/

drop if edo_born==. | edo_5years==. | mun_5years==. | CVE_EDO==. | CVE_MUN==.

gen migrant=1 if CVE_EDO~=. & edo_born~=. & edo_5years~=.
replace migrant=0 if edo_born==CVE_EDO & edo_born==edo_5years & CVE_MUN==mun_5years
label var migrant "Living in diff muni 5 yrs ago or born in diff state"

gen migrant5yrs=0 if CVE_EDO==edo_5years & CVE_MUN==mun_5years
replace migrant5yrs=1 if CVE_EDO~= edo_5years | CVE_MUN~=mun_5years
label var migrant5yrs "Living in diff muni 5 yrs ago"

*generate pre program residence codes for linking benef data
**define program participation based on muni of residence in 1995, irrespective of place of birth**
gen CVE_EDO_PRE=edo_5years
gen CVE_MUN_PRE=mun_5years

//labor market
tab classwk
gen wage = (classwk==2) if classwk>0&classwk<9
label var wage "Works for wage or salary"
drop classwk classwkd

tab empstat
gen trabajo = (empstat==1) if empstat<9
la var trabajo "Working last week"
drop empstat empstatd

tab occisco /*1-3 high skilled white collar, 4-5 low skilled white collar, 6-7 high blue, 8-9 low blue*/
gen occ_white = (occisco<6) if occisco<98
la var occ_white "White collar occupation"
gen occ_skilled = (occisco<3)|(occisco>5&occisco<8) if occisco<98
la var occ_skilled "Skilled occupation"
drop occisco

tab indgen
gen sector_agric = (indgen==100) if indgen>0&indgen<999
la var sector_agric "Agriculture sector"
drop indgen

ren hrswork1 hortra
replace hortra = . if hortra>900

sum mx2000a_incwk,d
gen ingtrmen = mx2000a_incwk if mx2000a_incwk<999998
/*convert february 2000 prices to june 2010 prices
 feb 2000: CPI = 60.338844724266
 june 2010: CPI = 96.867177425472
*/
replace ingtrmen = ingtrmen*(96.867177425472/60.338844724266)
replace ingtrmen = 0 if trabajo==0
la var ingtrmen "Labor income last month"
drop mx2000a_incwk

//education
tab educmx
gen some_sec = (educmx>=200) if educmx<800
la var some_sec ">6 years schooling"
gen some_prep = (educmx>=300) if educmx<800
la var some_prep ">9 years schooling"
gen some_college = (educmx>=400) if educmx<800
la var some_college ">12 years schooling"
drop educmx

tab yrschool
replace yrschool = . if yrschool==98
ren yrschool years

recode school (2=0) (0=.) (9=.)
label values school


order year sample pernum perwt ///
      serial urbanres CVE_EDO CVE_MUN ///
	  edo_born edo_5years mun_5years migrant migrant5yrs CVE_EDO_PRE CVE_MUN_PRE ///
	  age sex ///
	  school years some_sec some_prep some_college ///
	  ingtrmen hortra trabajo wage occ_white occ_skilled sector_agric

saveold "$tempdata/mex_2000_ipums.dta",replace version(12)

****************************************************************
**Merge municipal and state level beneficiary and characteristics data 
****************************************************************

*to use CURRENT place of residence for merge, not 1995 place, run this code:
replace CVE_EDO_PRE = CVE_EDO
replace CVE_MUN_PRE = CVE_MUN
*we should keep this to make Figure A2 "School Enrollment by Age in 2000"
*easy to explain. don't need to backdate muni of residence in 1995. but
*if we decide to include the effects on enrollment in 2000, we should probably
*backdate.


sort CVE_EDO_PRE CVE_MUN_PRE
merge CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/all_municipal_data_1990.dta"
tab _merge
list CVE_EDO_PRE CVE_MUN_PRE if _merge==2 /*obs with missing geography codes*/
drop if _merge==2
drop _merge

//Generate program impact indicators and prepare control variables
//Use 1997 HH (linear extra between 1990 and 2000) in Census for denominator of proportion beneficiaries
/*
gen prop9799_hog=(benef9799)/(.7*hog2000+.3*hog1990)
gen prop9705_hog=(benef9705)/(.7*hog2000+.3*hog1990)

la var prop9799_hog "Program intensity 97-99"
la var prop9705_hog "Program intensity 97-05"
*/ /* already created, so commented out in replication*/
*gen MUN_PRE=1000*CVE_EDO_PRE+CVE_MUN_PRE
egen mun_pre=concat(CVE_EDO_PRE CVE_MUN_PRE)
gen MUN_PRE=real(mun_pre)

/*Sample=highly marginated municipalities */
/*don't do this now. do it in the analysis files to keep flexibility*/
*keep if marginado==1

saveold "$tempdata/mex_2000_ipums.dta",replace version(12)

		 
