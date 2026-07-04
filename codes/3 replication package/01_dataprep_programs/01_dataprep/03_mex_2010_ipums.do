********************************
**Set up census IPUMS dataset
********************************

set more off

clear
quietly infix                         ///
  int     country            1-3      ///
  int     year               4-7      ///
  double  sample             8-16     ///
  double  serial             17-28    ///
  double  hhwt               29-36    ///
  byte    urban              37-37    ///
  int     geo1_mx2010        38-40    ///
  long    geo2_mx2010        41-46    ///
  byte    sizemx             47-47    ///
  byte    ownership          48-48    ///
  int     ownershipd         49-51    ///
  byte    electric           52-52    ///
  byte    watsup             53-54    ///
  byte    sewage             55-56    ///
  byte    cell               57-57    ///
  byte    autos              58-58    ///
  byte    hotwater           59-59    ///
  byte    computer           60-60    ///
  byte    washer             61-61    ///
  byte    refrig             62-62    ///
  byte    tv                 63-64    ///
  byte    rooms              65-66    ///
  byte    bedrooms           67-68    ///
  byte    toilet             69-70    ///
  int     floor              71-73    ///
  int     wall               74-76    ///
  byte    roof               77-78    ///
  byte    mx2010a_persons    79-80    ///
  long    mx2010a_inchome    81-86    ///
  byte    mx2010a_sizepl     87-87    ///
  int     pernum             88-91    ///
  double  perwt              92-99    ///
  int     sploc              100-102  ///
  int     age                103-105  ///
  byte    sex                106-106  ///
  byte    marst              107-107  ///
  int     marstd             108-110  ///
  byte    chborn             111-112  ///
  byte    chsurv             113-114  ///
  byte    bplmx              115-116  ///
  byte    school             117-117  ///
  byte    lit                118-118  ///
  byte    yrschool           119-120  ///
  int     educmx             121-123  ///
  byte    empstat            124-124  ///
  int     empstatd           125-127  ///
  byte    occisco            128-129  ///
  int     indgen             130-132  ///
  byte    classwk            133-133  ///
  int     classwkd           134-136  ///
  int     hrswork1           137-139  ///
  double  incearn            140-147  ///
  byte    migrate5           148-149  ///
  long    mig1_5_mx          150-155  ///
  byte    hlthcov            156-157  ///
  byte    mx2010a_momhh      158-158  ///
  byte    mx2010a_pophh      159-159  ///
  byte    mx2010a_migstat5   160-161  ///
  long    mx2010a_migmuni5   162-166  ///
  long    mx2010a_income     167-172  ///
  int     age_sp             173-175  ///
  byte    chborn_sp          176-177  ///
  byte    chsurv_sp          178-179  ///
  byte    yrschool_sp        180-181  ///
  byte    empstat_sp         182-182  ///
  byte    occisco_sp         183-184  ///
  double  incearn_sp         185-192  ///
  long    mx2010a_income_sp  193-198  ///
  using "$data/01_dataprep/ipumsi_00057.dat"

replace hhwt              = hhwt              / 100
replace perwt             = perwt             / 100

format sample            %9.0f
format serial            %12.0f
format hhwt              %8.2f
format perwt             %8.2f
format incearn           %8.0f
format incearn_sp        %8.0f

label var country           `"Country"'
label var year              `"Year"'
label var sample            `"IPUMS sample identifier"'
label var serial            `"Household serial number"'
label var hhwt              `"Household weight"'
label var urban             `"Urban-rural status"'
label var geo1_mx2010       `"Mexico, State 2010 [Level 1, GIS]"'
label var geo2_mx2010       `"Mexico, Municipality 2010 [Level 2, GIS]"'
label var sizemx            `"Mexico, Size of locality"'
label var ownership         `"Ownership of dwelling [general version]"'
label var ownershipd        `"Ownership of dwelling [detailed version]"'
label var electric          `"Electricity"'
label var watsup            `"Water supply"'
label var sewage            `"Sewage"'
label var cell              `"Cellular phone availability"'
label var autos             `"Automobiles available"'
label var hotwater          `"Hot water heater"'
label var computer          `"Computer"'
label var washer            `"Clothes washing machine"'
label var refrig            `"Refrigerator"'
label var tv                `"Television set"'
label var rooms             `"Number of rooms"'
label var bedrooms          `"Number of bedrooms"'
label var toilet            `"Toilet"'
label var floor             `"Floor material"'
label var wall              `"Wall or building material"'
label var roof              `"Roof material"'
label var mx2010a_persons   `"Number of people in the household"'
label var mx2010a_inchome   `"Household income from work (in pesos)"'
label var mx2010a_sizepl    `"Size of the place"'
label var pernum            `"Person number"'
label var perwt             `"Person weight"'
label var sploc             `"Spouse's location in household"'
label var age               `"Age"'
label var sex               `"Sex"'
label var marst             `"Marital status [general version]"'
label var marstd            `"Marital status [detailed version]"'
label var chborn            `"Children ever born"'
label var chsurv            `"Children surviving"'
label var bplmx             `"State of birth, Mexico"'
label var school            `"School attendance"'
label var lit               `"Literacy"'
label var yrschool          `"Years of schooling"'
label var educmx            `"Educational attainment, Mexico"'
label var empstat           `"Activity status (employment status) [general version]"'
label var empstatd          `"Activity status (employment status) [detailed version]"'
label var occisco           `"Occupation, ISCO general"'
label var indgen            `"Industry, general recode"'
label var classwk           `"Status in employment (class of worker) [general version]"'
label var classwkd          `"Status in employment (class of worker) [detailed version]"'
label var hrswork1          `"Hours worked per week"'
label var incearn           `"Earned income"'
label var migrate5          `"Migration status, 5 years"'
label var mig1_5_mx         `"State of residence 5 years ago, Mexico; consistent boundaries, GIS"'
label var hlthcov           `"Health coverage"'
label var mx2010a_momhh     `"Mother lives in the household"'
label var mx2010a_pophh     `"Father lives in the household"'
label var mx2010a_migstat5  `"State of residence in 2005"'
label var mx2010a_migmuni5  `"Municipality of residence in 2005"'
label var mx2010a_income    `"Monthly income from working (in pesos)"'
label var age_sp            `"Age [of spouse]"'
label var chborn_sp         `"Children ever born [of spouse]"'
label var chsurv_sp         `"Children surviving [of spouse]"'
label var yrschool_sp       `"Years of schooling [of spouse]"'
label var empstat_sp        `"Activity status (employment status) [of spouse; general version]"'
label var occisco_sp        `"Occupation, ISCO general [of spouse]"'
label var incearn_sp        `"Earned income [of spouse]"'
label var mx2010a_income_sp `"Monthly income from working (in pesos) [of spouse]"'

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

label define geo1_mx2010_lbl 001 `"Aguascalientes"'
label define geo1_mx2010_lbl 002 `"Baja California"', add
label define geo1_mx2010_lbl 003 `"Baja California Sur"', add
label define geo1_mx2010_lbl 004 `"Campeche"', add
label define geo1_mx2010_lbl 005 `"Coahuila de Zaragoza"', add
label define geo1_mx2010_lbl 006 `"Colima"', add
label define geo1_mx2010_lbl 007 `"Chiapas"', add
label define geo1_mx2010_lbl 008 `"Chihuahua"', add
label define geo1_mx2010_lbl 009 `"Distrito Federal"', add
label define geo1_mx2010_lbl 010 `"Durango"', add
label define geo1_mx2010_lbl 011 `"Guanajuato"', add
label define geo1_mx2010_lbl 012 `"Guerrero"', add
label define geo1_mx2010_lbl 013 `"Hidalgo"', add
label define geo1_mx2010_lbl 014 `"Jalisco"', add
label define geo1_mx2010_lbl 015 `"México"', add
label define geo1_mx2010_lbl 016 `"Michoacán de Ocampo"', add
label define geo1_mx2010_lbl 017 `"Morelos"', add
label define geo1_mx2010_lbl 018 `"Nayarit"', add
label define geo1_mx2010_lbl 019 `"Nuevo León"', add
label define geo1_mx2010_lbl 020 `"Oaxaca"', add
label define geo1_mx2010_lbl 021 `"Puebla"', add
label define geo1_mx2010_lbl 022 `"Querétaro"', add
label define geo1_mx2010_lbl 023 `"Quintana Roo"', add
label define geo1_mx2010_lbl 024 `"San Luis Potosí"', add
label define geo1_mx2010_lbl 025 `"Sinaloa"', add
label define geo1_mx2010_lbl 026 `"Sonora"', add
label define geo1_mx2010_lbl 027 `"Tabasco"', add
label define geo1_mx2010_lbl 028 `"Tamaulipas"', add
label define geo1_mx2010_lbl 029 `"Tlaxcala"', add
label define geo1_mx2010_lbl 030 `"Veracruz de Ignacio de la Llave"', add
label define geo1_mx2010_lbl 031 `"Yucatán"', add
label define geo1_mx2010_lbl 032 `"Zacatecas"', add
label values geo1_mx2010 geo1_mx2010_lbl

label define geo2_mx2010_lbl 001001 `"Aguascalientes"'
label define geo2_mx2010_lbl 001002 `"Asientos"', add
label define geo2_mx2010_lbl 001003 `"Calvillo"', add
label define geo2_mx2010_lbl 001004 `"Cosío"', add
label define geo2_mx2010_lbl 001005 `"Jesús María"', add
label define geo2_mx2010_lbl 001006 `"Pabellón de Arteaga"', add
label define geo2_mx2010_lbl 001007 `"Rincón de Romos"', add
label define geo2_mx2010_lbl 001008 `"San José de Gracia"', add
label define geo2_mx2010_lbl 001009 `"Tepezalá"', add
label define geo2_mx2010_lbl 001010 `"El Llano"', add
label define geo2_mx2010_lbl 001011 `"San Francisco de los Romo"', add
label define geo2_mx2010_lbl 002001 `"Ensenada"', add
label define geo2_mx2010_lbl 002002 `"Mexicali"', add
label define geo2_mx2010_lbl 002003 `"Tecate"', add
label define geo2_mx2010_lbl 002004 `"Tijuana"', add
label define geo2_mx2010_lbl 002005 `"Playas de Rosarito"', add
label define geo2_mx2010_lbl 003001 `"Comondú"', add
label define geo2_mx2010_lbl 003002 `"Mulegé"', add
label define geo2_mx2010_lbl 003003 `"La Paz"', add
label define geo2_mx2010_lbl 003008 `"Los Cabos"', add
label define geo2_mx2010_lbl 003009 `"Loreto"', add
label define geo2_mx2010_lbl 004001 `"Calkiní"', add
label define geo2_mx2010_lbl 004002 `"Campeche"', add
label define geo2_mx2010_lbl 004003 `"Carmen"', add
label define geo2_mx2010_lbl 004004 `"Champotón"', add
label define geo2_mx2010_lbl 004005 `"Hecelchakán"', add
label define geo2_mx2010_lbl 004006 `"Hopelchén"', add
label define geo2_mx2010_lbl 004007 `"Palizada"', add
label define geo2_mx2010_lbl 004008 `"Tenabo"', add
label define geo2_mx2010_lbl 004009 `"Escárcega"', add
label define geo2_mx2010_lbl 004010 `"Calakmul"', add
label define geo2_mx2010_lbl 004011 `"Candelaria"', add
label define geo2_mx2010_lbl 005001 `"Abasolo"', add
label define geo2_mx2010_lbl 005002 `"Acuña"', add
label define geo2_mx2010_lbl 005003 `"Allende"', add
label define geo2_mx2010_lbl 005004 `"Arteaga"', add
label define geo2_mx2010_lbl 005005 `"Candela"', add
label define geo2_mx2010_lbl 005006 `"Castaños"', add
label define geo2_mx2010_lbl 005007 `"Cuatro Ciénegas"', add
label define geo2_mx2010_lbl 005008 `"Escobedo"', add
label define geo2_mx2010_lbl 005009 `"Francisco I. Madero"', add
label define geo2_mx2010_lbl 005010 `"Frontera"', add
label define geo2_mx2010_lbl 005011 `"General Cepeda"', add
label define geo2_mx2010_lbl 005012 `"Guerrero"', add
label define geo2_mx2010_lbl 005013 `"Hidalgo"', add
label define geo2_mx2010_lbl 005014 `"Jiménez"', add
label define geo2_mx2010_lbl 005015 `"Juárez"', add
label define geo2_mx2010_lbl 005016 `"Lamadrid"', add
label define geo2_mx2010_lbl 005017 `"Matamoros"', add
label define geo2_mx2010_lbl 005018 `"Monclova"', add
label define geo2_mx2010_lbl 005019 `"Morelos"', add
label define geo2_mx2010_lbl 005020 `"Múzquiz"', add
label define geo2_mx2010_lbl 005021 `"Nadadores"', add
label define geo2_mx2010_lbl 005022 `"Nava"', add
label define geo2_mx2010_lbl 005023 `"Ocampo"', add
label define geo2_mx2010_lbl 005024 `"Parras"', add
label define geo2_mx2010_lbl 005025 `"Piedras Negras"', add
label define geo2_mx2010_lbl 005026 `"Progreso"', add
label define geo2_mx2010_lbl 005027 `"Ramos Arizpe"', add
label define geo2_mx2010_lbl 005028 `"Sabinas"', add
label define geo2_mx2010_lbl 005029 `"Sacramento"', add
label define geo2_mx2010_lbl 005030 `"Saltillo"', add
label define geo2_mx2010_lbl 005031 `"San Buenaventura"', add
label define geo2_mx2010_lbl 005032 `"San Juan de Sabinas"', add
label define geo2_mx2010_lbl 005033 `"San Pedro"', add
label define geo2_mx2010_lbl 005034 `"Sierra Mojada"', add
label define geo2_mx2010_lbl 005035 `"Torreón"', add
label define geo2_mx2010_lbl 005036 `"Viesca"', add
label define geo2_mx2010_lbl 005037 `"Villa Unión"', add
label define geo2_mx2010_lbl 005038 `"Zaragoza"', add
label define geo2_mx2010_lbl 006001 `"Armería"', add
label define geo2_mx2010_lbl 006002 `"Colima"', add
label define geo2_mx2010_lbl 006003 `"Comala"', add
label define geo2_mx2010_lbl 006004 `"Coquimatlán"', add
label define geo2_mx2010_lbl 006005 `"Cuauhtémoc"', add
label define geo2_mx2010_lbl 006006 `"Ixtlahuacán"', add
label define geo2_mx2010_lbl 006007 `"Manzanillo"', add
label define geo2_mx2010_lbl 006008 `"Minatitlán"', add
label define geo2_mx2010_lbl 006009 `"Tecomán"', add
label define geo2_mx2010_lbl 006010 `"Villa de Álvarez"', add
label define geo2_mx2010_lbl 007001 `"Acacoyagua"', add
label define geo2_mx2010_lbl 007002 `"Acala"', add
label define geo2_mx2010_lbl 007003 `"Acapetahua"', add
label define geo2_mx2010_lbl 007004 `"Altamirano"', add
label define geo2_mx2010_lbl 007005 `"Amatán"', add
label define geo2_mx2010_lbl 007006 `"Amatenango de la Frontera"', add
label define geo2_mx2010_lbl 007007 `"Amatenango del Valle"', add
label define geo2_mx2010_lbl 007008 `"Angel Albino Corzo"', add
label define geo2_mx2010_lbl 007009 `"Arriaga"', add
label define geo2_mx2010_lbl 007010 `"Bejucal de Ocampo"', add
label define geo2_mx2010_lbl 007011 `"Bella Vista"', add
label define geo2_mx2010_lbl 007012 `"Berriozábal"', add
label define geo2_mx2010_lbl 007013 `"Bochil"', add
label define geo2_mx2010_lbl 007014 `"El Bosque"', add
label define geo2_mx2010_lbl 007015 `"Cacahoatán"', add
label define geo2_mx2010_lbl 007016 `"Catazajá"', add
label define geo2_mx2010_lbl 007017 `"Cintalapa"', add
label define geo2_mx2010_lbl 007018 `"Coapilla"', add
label define geo2_mx2010_lbl 007019 `"Comitán de Domínguez"', add
label define geo2_mx2010_lbl 007020 `"La Concordia"', add
label define geo2_mx2010_lbl 007021 `"Copainalá"', add
label define geo2_mx2010_lbl 007022 `"Chalchihuitán"', add
label define geo2_mx2010_lbl 007023 `"Chamula"', add
label define geo2_mx2010_lbl 007024 `"Chanal"', add
label define geo2_mx2010_lbl 007025 `"Chapultenango"', add
label define geo2_mx2010_lbl 007026 `"Chenalhó"', add
label define geo2_mx2010_lbl 007027 `"Chiapa de Corzo"', add
label define geo2_mx2010_lbl 007028 `"Chiapilla"', add
label define geo2_mx2010_lbl 007029 `"Chicoasén"', add
label define geo2_mx2010_lbl 007030 `"Chicomuselo"', add
label define geo2_mx2010_lbl 007031 `"Chilón"', add
label define geo2_mx2010_lbl 007032 `"Escuintla"', add
label define geo2_mx2010_lbl 007033 `"Francisco León"', add
label define geo2_mx2010_lbl 007034 `"Frontera Comalapa"', add
label define geo2_mx2010_lbl 007035 `"Frontera Hidalgo"', add
label define geo2_mx2010_lbl 007036 `"La Grandeza"', add
label define geo2_mx2010_lbl 007037 `"Huehuetán"', add
label define geo2_mx2010_lbl 007038 `"Huixtán"', add
label define geo2_mx2010_lbl 007039 `"Huitiupán"', add
label define geo2_mx2010_lbl 007040 `"Huixtla"', add
label define geo2_mx2010_lbl 007041 `"La Independencia"', add
label define geo2_mx2010_lbl 007042 `"Ixhuatán"', add
label define geo2_mx2010_lbl 007043 `"Ixtacomitán"', add
label define geo2_mx2010_lbl 007044 `"Ixtapa"', add
label define geo2_mx2010_lbl 007045 `"Ixtapangajoya"', add
label define geo2_mx2010_lbl 007046 `"Jiquipilas"', add
label define geo2_mx2010_lbl 007047 `"Jitotol"', add
label define geo2_mx2010_lbl 007048 `"Juárez"', add
label define geo2_mx2010_lbl 007049 `"Larráinzar"', add
label define geo2_mx2010_lbl 007050 `"La Libertad"', add
label define geo2_mx2010_lbl 007051 `"Mapastepec"', add
label define geo2_mx2010_lbl 007052 `"Las Margaritas"', add
label define geo2_mx2010_lbl 007053 `"Mazapa de Madero"', add
label define geo2_mx2010_lbl 007054 `"Mazatán"', add
label define geo2_mx2010_lbl 007055 `"Metapa"', add
label define geo2_mx2010_lbl 007056 `"Mitontic"', add
label define geo2_mx2010_lbl 007057 `"Motozintla"', add
label define geo2_mx2010_lbl 007058 `"Nicolás Ruíz"', add
label define geo2_mx2010_lbl 007059 `"Ocosingo"', add
label define geo2_mx2010_lbl 007060 `"Ocotepec"', add
label define geo2_mx2010_lbl 007061 `"Ocozocoautla de Espinosa"', add
label define geo2_mx2010_lbl 007062 `"Ostuacán"', add
label define geo2_mx2010_lbl 007063 `"Osumacinta"', add
label define geo2_mx2010_lbl 007064 `"Oxchuc"', add
label define geo2_mx2010_lbl 007065 `"Palenque"', add
label define geo2_mx2010_lbl 007066 `"Pantelhó"', add
label define geo2_mx2010_lbl 007067 `"Pantepec"', add
label define geo2_mx2010_lbl 007068 `"Pichucalco"', add
label define geo2_mx2010_lbl 007069 `"Pijijiapan"', add
label define geo2_mx2010_lbl 007070 `"El Porvenir"', add
label define geo2_mx2010_lbl 007071 `"Villa Comaltitlán"', add
label define geo2_mx2010_lbl 007072 `"Pueblo Nuevo Solistahuacán"', add
label define geo2_mx2010_lbl 007073 `"Rayón"', add
label define geo2_mx2010_lbl 007074 `"Reforma"', add
label define geo2_mx2010_lbl 007075 `"Las Rosas"', add
label define geo2_mx2010_lbl 007076 `"Sabanilla"', add
label define geo2_mx2010_lbl 007077 `"Salto de Agua"', add
label define geo2_mx2010_lbl 007078 `"San Cristóbal de las Casas"', add
label define geo2_mx2010_lbl 007079 `"San Fernando"', add
label define geo2_mx2010_lbl 007080 `"Siltepec"', add
label define geo2_mx2010_lbl 007081 `"Simojovel"', add
label define geo2_mx2010_lbl 007082 `"Sitalá"', add
label define geo2_mx2010_lbl 007083 `"Socoltenango"', add
label define geo2_mx2010_lbl 007084 `"Solosuchiapa"', add
label define geo2_mx2010_lbl 007085 `"Soyaló"', add
label define geo2_mx2010_lbl 007086 `"Suchiapa"', add
label define geo2_mx2010_lbl 007087 `"Suchiate"', add
label define geo2_mx2010_lbl 007088 `"Sunuapa"', add
label define geo2_mx2010_lbl 007089 `"Tapachula"', add
label define geo2_mx2010_lbl 007090 `"Tapalapa"', add
label define geo2_mx2010_lbl 007091 `"Tapilula"', add
label define geo2_mx2010_lbl 007092 `"Tecpatán"', add
label define geo2_mx2010_lbl 007093 `"Tenejapa"', add
label define geo2_mx2010_lbl 007094 `"Teopisca"', add
label define geo2_mx2010_lbl 007096 `"Tila"', add
label define geo2_mx2010_lbl 007097 `"Tonalá"', add
label define geo2_mx2010_lbl 007098 `"Totolapa"', add
label define geo2_mx2010_lbl 007099 `"La Trinitaria"', add
label define geo2_mx2010_lbl 007100 `"Tumbalá"', add
label define geo2_mx2010_lbl 007101 `"Tuxtla Gutiérrez"', add
label define geo2_mx2010_lbl 007102 `"Tuxtla Chico"', add
label define geo2_mx2010_lbl 007103 `"Tuzantán"', add
label define geo2_mx2010_lbl 007104 `"Tzimol"', add
label define geo2_mx2010_lbl 007105 `"Unión Juárez"', add
label define geo2_mx2010_lbl 007106 `"Venustiano Carranza"', add
label define geo2_mx2010_lbl 007107 `"Villa Corzo"', add
label define geo2_mx2010_lbl 007108 `"Villaflores"', add
label define geo2_mx2010_lbl 007109 `"Yajalón"', add
label define geo2_mx2010_lbl 007110 `"San Lucas"', add
label define geo2_mx2010_lbl 007111 `"Zinacantán"', add
label define geo2_mx2010_lbl 007112 `"San Juan Cancuc"', add
label define geo2_mx2010_lbl 007113 `"Aldama"', add
label define geo2_mx2010_lbl 007114 `"Benemérito de las Américas"', add
label define geo2_mx2010_lbl 007115 `"Maravilla Tenejapa"', add
label define geo2_mx2010_lbl 007116 `"Marqués de Comillas"', add
label define geo2_mx2010_lbl 007117 `"Montecristo de Guerrero"', add
label define geo2_mx2010_lbl 007118 `"San Andrés Duraznal"', add
label define geo2_mx2010_lbl 007119 `"Santiago el Pinar"', add
label define geo2_mx2010_lbl 008001 `"Ahumada"', add
label define geo2_mx2010_lbl 008002 `"Aldama"', add
label define geo2_mx2010_lbl 008003 `"Allende"', add
label define geo2_mx2010_lbl 008004 `"Aquiles Serdán"', add
label define geo2_mx2010_lbl 008005 `"Ascensión"', add
label define geo2_mx2010_lbl 008006 `"Bachíniva"', add
label define geo2_mx2010_lbl 008007 `"Balleza"', add
label define geo2_mx2010_lbl 008008 `"Batopilas"', add
label define geo2_mx2010_lbl 008009 `"Bocoyna"', add
label define geo2_mx2010_lbl 008010 `"Buenaventura"', add
label define geo2_mx2010_lbl 008011 `"Camargo"', add
label define geo2_mx2010_lbl 008012 `"Carichí"', add
label define geo2_mx2010_lbl 008013 `"Casas Grandes"', add
label define geo2_mx2010_lbl 008014 `"Coronado"', add
label define geo2_mx2010_lbl 008015 `"Coyame del Sotol"', add
label define geo2_mx2010_lbl 008016 `"La Cruz"', add
label define geo2_mx2010_lbl 008017 `"Cuauhtémoc"', add
label define geo2_mx2010_lbl 008018 `"Cusihuiriachi"', add
label define geo2_mx2010_lbl 008019 `"Chihuahua"', add
label define geo2_mx2010_lbl 008020 `"Chínipas"', add
label define geo2_mx2010_lbl 008021 `"Delicias"', add
label define geo2_mx2010_lbl 008022 `"Dr. Belisario Domínguez"', add
label define geo2_mx2010_lbl 008023 `"Galeana"', add
label define geo2_mx2010_lbl 008024 `"Santa Isabel"', add
label define geo2_mx2010_lbl 008025 `"Gómez Farías"', add
label define geo2_mx2010_lbl 008026 `"Gran Morelos"', add
label define geo2_mx2010_lbl 008027 `"Guachochi"', add
label define geo2_mx2010_lbl 008028 `"Guadalupe"', add
label define geo2_mx2010_lbl 008029 `"Guadalupe y Calvo"', add
label define geo2_mx2010_lbl 008030 `"Guazapares"', add
label define geo2_mx2010_lbl 008031 `"Guerrero"', add
label define geo2_mx2010_lbl 008032 `"Hidalgo del Parral"', add
label define geo2_mx2010_lbl 008033 `"Huejotitán"', add
label define geo2_mx2010_lbl 008034 `"Ignacio Zaragoza"', add
label define geo2_mx2010_lbl 008035 `"Janos"', add
label define geo2_mx2010_lbl 008036 `"Jiménez"', add
label define geo2_mx2010_lbl 008037 `"Juárez"', add
label define geo2_mx2010_lbl 008038 `"Julimes"', add
label define geo2_mx2010_lbl 008039 `"López"', add
label define geo2_mx2010_lbl 008040 `"Madera"', add
label define geo2_mx2010_lbl 008041 `"Maguarichi"', add
label define geo2_mx2010_lbl 008042 `"Manuel Benavides"', add
label define geo2_mx2010_lbl 008043 `"Matachí"', add
label define geo2_mx2010_lbl 008044 `"Matamoros"', add
label define geo2_mx2010_lbl 008045 `"Meoqui"', add
label define geo2_mx2010_lbl 008046 `"Morelos"', add
label define geo2_mx2010_lbl 008047 `"Moris"', add
label define geo2_mx2010_lbl 008048 `"Namiquipa"', add
label define geo2_mx2010_lbl 008049 `"Nonoava"', add
label define geo2_mx2010_lbl 008050 `"Nuevo Casas Grandes"', add
label define geo2_mx2010_lbl 008051 `"Ocampo"', add
label define geo2_mx2010_lbl 008052 `"Ojinaga"', add
label define geo2_mx2010_lbl 008053 `"Praxedis G. Guerrero"', add
label define geo2_mx2010_lbl 008054 `"Riva Palacio"', add
label define geo2_mx2010_lbl 008055 `"Rosales"', add
label define geo2_mx2010_lbl 008056 `"Rosario"', add
label define geo2_mx2010_lbl 008057 `"San Francisco de Borja"', add
label define geo2_mx2010_lbl 008058 `"San Francisco de Conchos"', add
label define geo2_mx2010_lbl 008059 `"San Francisco del Oro"', add
label define geo2_mx2010_lbl 008060 `"Santa Bárbara"', add
label define geo2_mx2010_lbl 008061 `"Satevó"', add
label define geo2_mx2010_lbl 008062 `"Saucillo"', add
label define geo2_mx2010_lbl 008063 `"Temósachic"', add
label define geo2_mx2010_lbl 008064 `"El Tule"', add
label define geo2_mx2010_lbl 008065 `"Urique"', add
label define geo2_mx2010_lbl 008066 `"Uruachi"', add
label define geo2_mx2010_lbl 008067 `"Valle de Zaragoza"', add
label define geo2_mx2010_lbl 009002 `"Azcapotzalco"', add
label define geo2_mx2010_lbl 009003 `"Coyoacán"', add
label define geo2_mx2010_lbl 009004 `"Cuajimalpa de Morelos"', add
label define geo2_mx2010_lbl 009005 `"Gustavo A. Madero"', add
label define geo2_mx2010_lbl 009006 `"Iztacalco"', add
label define geo2_mx2010_lbl 009007 `"Iztapalapa"', add
label define geo2_mx2010_lbl 009008 `"La Magdalena Contreras"', add
label define geo2_mx2010_lbl 009009 `"Milpa Alta"', add
label define geo2_mx2010_lbl 009010 `"Álvaro Obregón"', add
label define geo2_mx2010_lbl 009011 `"Tláhuac"', add
label define geo2_mx2010_lbl 009012 `"Tlalpan"', add
label define geo2_mx2010_lbl 009013 `"Xochimilco"', add
label define geo2_mx2010_lbl 009014 `"Benito Juárez"', add
label define geo2_mx2010_lbl 009015 `"Cuauhtémoc"', add
label define geo2_mx2010_lbl 009016 `"Miguel Hidalgo"', add
label define geo2_mx2010_lbl 009017 `"Venustiano Carranza"', add
label define geo2_mx2010_lbl 010001 `"Canatlán"', add
label define geo2_mx2010_lbl 010002 `"Canelas"', add
label define geo2_mx2010_lbl 010003 `"Coneto de Comonfort"', add
label define geo2_mx2010_lbl 010004 `"Cuencamé"', add
label define geo2_mx2010_lbl 010005 `"Durango"', add
label define geo2_mx2010_lbl 010006 `"General Simón Bolívar"', add
label define geo2_mx2010_lbl 010007 `"Gómez Palacio"', add
label define geo2_mx2010_lbl 010008 `"Guadalupe Victoria"', add
label define geo2_mx2010_lbl 010009 `"Guanaceví"', add
label define geo2_mx2010_lbl 010010 `"Hidalgo"', add
label define geo2_mx2010_lbl 010011 `"Indé"', add
label define geo2_mx2010_lbl 010012 `"Lerdo"', add
label define geo2_mx2010_lbl 010013 `"Mapimí"', add
label define geo2_mx2010_lbl 010014 `"Mezquital"', add
label define geo2_mx2010_lbl 010015 `"Nazas"', add
label define geo2_mx2010_lbl 010016 `"Nombre de Dios"', add
label define geo2_mx2010_lbl 010017 `"Ocampo"', add
label define geo2_mx2010_lbl 010018 `"El Oro"', add
label define geo2_mx2010_lbl 010019 `"Otáez"', add
label define geo2_mx2010_lbl 010020 `"Pánuco de Coronado"', add
label define geo2_mx2010_lbl 010021 `"Peñón Blanco"', add
label define geo2_mx2010_lbl 010022 `"Poanas"', add
label define geo2_mx2010_lbl 010023 `"Pueblo Nuevo"', add
label define geo2_mx2010_lbl 010024 `"Rodeo"', add
label define geo2_mx2010_lbl 010025 `"San Bernardo"', add
label define geo2_mx2010_lbl 010026 `"San Dimas"', add
label define geo2_mx2010_lbl 010027 `"San Juan de Guadalupe"', add
label define geo2_mx2010_lbl 010028 `"San Juan del Río"', add
label define geo2_mx2010_lbl 010029 `"San Luis del Cordero"', add
label define geo2_mx2010_lbl 010030 `"San Pedro del Gallo"', add
label define geo2_mx2010_lbl 010031 `"Santa Clara"', add
label define geo2_mx2010_lbl 010032 `"Santiago Papasquiaro"', add
label define geo2_mx2010_lbl 010033 `"Súchil"', add
label define geo2_mx2010_lbl 010034 `"Tamazula"', add
label define geo2_mx2010_lbl 010035 `"Tepehuanes"', add
label define geo2_mx2010_lbl 010036 `"Tlahualilo"', add
label define geo2_mx2010_lbl 010037 `"Topia"', add
label define geo2_mx2010_lbl 010038 `"Vicente Guerrero"', add
label define geo2_mx2010_lbl 010039 `"Nuevo Ideal"', add
label define geo2_mx2010_lbl 011001 `"Abasolo"', add
label define geo2_mx2010_lbl 011002 `"Acámbaro"', add
label define geo2_mx2010_lbl 011003 `"San Miguel de Allende"', add
label define geo2_mx2010_lbl 011004 `"Apaseo el Alto"', add
label define geo2_mx2010_lbl 011005 `"Apaseo el Grande"', add
label define geo2_mx2010_lbl 011006 `"Atarjea"', add
label define geo2_mx2010_lbl 011007 `"Celaya"', add
label define geo2_mx2010_lbl 011008 `"Manuel Doblado"', add
label define geo2_mx2010_lbl 011009 `"Comonfort"', add
label define geo2_mx2010_lbl 011010 `"Coroneo"', add
label define geo2_mx2010_lbl 011011 `"Cortazar"', add
label define geo2_mx2010_lbl 011012 `"Cuerámaro"', add
label define geo2_mx2010_lbl 011013 `"Doctor Mora"', add
label define geo2_mx2010_lbl 011014 `"Dolores Hidalgo Cuna de la Independencia Nacional"', add
label define geo2_mx2010_lbl 011015 `"Guanajuato"', add
label define geo2_mx2010_lbl 011016 `"Huanímaro"', add
label define geo2_mx2010_lbl 011017 `"Irapuato"', add
label define geo2_mx2010_lbl 011018 `"Jaral del Progreso"', add
label define geo2_mx2010_lbl 011019 `"Jerécuaro"', add
label define geo2_mx2010_lbl 011020 `"León"', add
label define geo2_mx2010_lbl 011021 `"Moroleón"', add
label define geo2_mx2010_lbl 011022 `"Ocampo"', add
label define geo2_mx2010_lbl 011023 `"Pénjamo"', add
label define geo2_mx2010_lbl 011024 `"Pueblo Nuevo"', add
label define geo2_mx2010_lbl 011025 `"Purísima del Rincón"', add
label define geo2_mx2010_lbl 011026 `"Romita"', add
label define geo2_mx2010_lbl 011027 `"Salamanca"', add
label define geo2_mx2010_lbl 011028 `"Salvatierra"', add
label define geo2_mx2010_lbl 011029 `"San Diego de la Unión"', add
label define geo2_mx2010_lbl 011030 `"San Felipe"', add
label define geo2_mx2010_lbl 011031 `"San Francisco del Rincón"', add
label define geo2_mx2010_lbl 011032 `"San José Iturbide"', add
label define geo2_mx2010_lbl 011033 `"San Luis de la Paz"', add
label define geo2_mx2010_lbl 011034 `"Santa Catarina"', add
label define geo2_mx2010_lbl 011035 `"Santa Cruz de Juventino Rosas"', add
label define geo2_mx2010_lbl 011036 `"Santiago Maravatío"', add
label define geo2_mx2010_lbl 011037 `"Silao"', add
label define geo2_mx2010_lbl 011038 `"Tarandacuao"', add
label define geo2_mx2010_lbl 011039 `"Tarimoro"', add
label define geo2_mx2010_lbl 011040 `"Tierra Blanca"', add
label define geo2_mx2010_lbl 011041 `"Uriangato"', add
label define geo2_mx2010_lbl 011042 `"Valle de Santiago"', add
label define geo2_mx2010_lbl 011043 `"Victoria"', add
label define geo2_mx2010_lbl 011044 `"Villagrán"', add
label define geo2_mx2010_lbl 011045 `"Xichú"', add
label define geo2_mx2010_lbl 011046 `"Yuriria"', add
label define geo2_mx2010_lbl 012001 `"Acapulco de Juárez"', add
label define geo2_mx2010_lbl 012002 `"Ahuacuotzingo"', add
label define geo2_mx2010_lbl 012003 `"Ajuchitlán del Progreso"', add
label define geo2_mx2010_lbl 012004 `"Alcozauca de Guerrero"', add
label define geo2_mx2010_lbl 012005 `"Alpoyeca"', add
label define geo2_mx2010_lbl 012006 `"Apaxtla"', add
label define geo2_mx2010_lbl 012007 `"Arcelia"', add
label define geo2_mx2010_lbl 012008 `"Atenango del Río"', add
label define geo2_mx2010_lbl 012009 `"Atlamajalcingo del Monte"', add
label define geo2_mx2010_lbl 012010 `"Atlixtac"', add
label define geo2_mx2010_lbl 012011 `"Atoyac de Álvarez"', add
label define geo2_mx2010_lbl 012012 `"Ayutla de los Libres"', add
label define geo2_mx2010_lbl 012013 `"Azoyú"', add
label define geo2_mx2010_lbl 012014 `"Benito Juárez"', add
label define geo2_mx2010_lbl 012015 `"Buenavista de Cuéllar"', add
label define geo2_mx2010_lbl 012016 `"Coahuayutla de José María Izazaga"', add
label define geo2_mx2010_lbl 012017 `"Cocula"', add
label define geo2_mx2010_lbl 012018 `"Copala"', add
label define geo2_mx2010_lbl 012019 `"Copalillo"', add
label define geo2_mx2010_lbl 012020 `"Copanatoyac"', add
label define geo2_mx2010_lbl 012021 `"Coyuca de Benítez"', add
label define geo2_mx2010_lbl 012022 `"Coyuca de Catalán"', add
label define geo2_mx2010_lbl 012023 `"Cuajinicuilapa"', add
label define geo2_mx2010_lbl 012024 `"Cualác"', add
label define geo2_mx2010_lbl 012025 `"Cuautepec"', add
label define geo2_mx2010_lbl 012026 `"Cuetzala del Progreso"', add
label define geo2_mx2010_lbl 012027 `"Cutzamala de Pinzón"', add
label define geo2_mx2010_lbl 012028 `"Chilapa de Álvarez"', add
label define geo2_mx2010_lbl 012029 `"Chilpancingo de los Bravo"', add
label define geo2_mx2010_lbl 012030 `"Florencio Villarreal"', add
label define geo2_mx2010_lbl 012031 `"General Canuto A. Neri"', add
label define geo2_mx2010_lbl 012032 `"General Heliodoro Castillo"', add
label define geo2_mx2010_lbl 012033 `"Huamuxtitlán"', add
label define geo2_mx2010_lbl 012034 `"Huitzuco de los Figueroa"', add
label define geo2_mx2010_lbl 012035 `"Iguala de la Independencia"', add
label define geo2_mx2010_lbl 012036 `"Igualapa"', add
label define geo2_mx2010_lbl 012037 `"Ixcateopan de Cuauhtémoc"', add
label define geo2_mx2010_lbl 012038 `"Zihuatanejo de Azueta"', add
label define geo2_mx2010_lbl 012039 `"Juan R. Escudero"', add
label define geo2_mx2010_lbl 012040 `"Leonardo Bravo"', add
label define geo2_mx2010_lbl 012041 `"Malinaltepec"', add
label define geo2_mx2010_lbl 012042 `"Mártir de Cuilapan"', add
label define geo2_mx2010_lbl 012043 `"Metlatónoc"', add
label define geo2_mx2010_lbl 012044 `"Mochitlán"', add
label define geo2_mx2010_lbl 012045 `"Olinalá"', add
label define geo2_mx2010_lbl 012046 `"Ometepec"', add
label define geo2_mx2010_lbl 012047 `"Pedro Ascencio Alquisiras"', add
label define geo2_mx2010_lbl 012048 `"Petatlán"', add
label define geo2_mx2010_lbl 012049 `"Pilcaya"', add
label define geo2_mx2010_lbl 012050 `"Pungarabato"', add
label define geo2_mx2010_lbl 012051 `"Quechultenango"', add
label define geo2_mx2010_lbl 012052 `"San Luis Acatlán"', add
label define geo2_mx2010_lbl 012053 `"San Marcos"', add
label define geo2_mx2010_lbl 012054 `"San Miguel Totolapan"', add
label define geo2_mx2010_lbl 012055 `"Taxco de Alarcón"', add
label define geo2_mx2010_lbl 012056 `"Tecoanapa"', add
label define geo2_mx2010_lbl 012057 `"Técpan de Galeana"', add
label define geo2_mx2010_lbl 012058 `"Teloloapan"', add
label define geo2_mx2010_lbl 012059 `"Tepecoacuilco de Trujano"', add
label define geo2_mx2010_lbl 012060 `"Tetipac"', add
label define geo2_mx2010_lbl 012061 `"Tixtla de Guerrero"', add
label define geo2_mx2010_lbl 012062 `"Tlacoachistlahuaca"', add
label define geo2_mx2010_lbl 012063 `"Tlacoapa"', add
label define geo2_mx2010_lbl 012064 `"Tlalchapa"', add
label define geo2_mx2010_lbl 012065 `"Tlalixtaquilla de Maldonado"', add
label define geo2_mx2010_lbl 012066 `"Tlapa de Comonfort"', add
label define geo2_mx2010_lbl 012067 `"Tlapehuala"', add
label define geo2_mx2010_lbl 012068 `"La Unión de Isidoro Montes de Oca"', add
label define geo2_mx2010_lbl 012069 `"Xalpatláhuac"', add
label define geo2_mx2010_lbl 012070 `"Xochihuehuetlán"', add
label define geo2_mx2010_lbl 012071 `"Xochistlahuaca"', add
label define geo2_mx2010_lbl 012072 `"Zapotitlán Tablas"', add
label define geo2_mx2010_lbl 012073 `"Zirándaro"', add
label define geo2_mx2010_lbl 012074 `"Zitlala"', add
label define geo2_mx2010_lbl 012075 `"Eduardo Neri"', add
label define geo2_mx2010_lbl 012076 `"Acatepec"', add
label define geo2_mx2010_lbl 012077 `"Marquelia"', add
label define geo2_mx2010_lbl 012078 `"Cochoapa el Grande"', add
label define geo2_mx2010_lbl 012079 `"José Joaquin de Herrera"', add
label define geo2_mx2010_lbl 012080 `"Juchitán"', add
label define geo2_mx2010_lbl 012081 `"Iliatenco"', add
label define geo2_mx2010_lbl 013001 `"Acatlán"', add
label define geo2_mx2010_lbl 013002 `"Acaxochitlán"', add
label define geo2_mx2010_lbl 013003 `"Actopan"', add
label define geo2_mx2010_lbl 013004 `"Agua Blanca de Iturbide"', add
label define geo2_mx2010_lbl 013005 `"Ajacuba"', add
label define geo2_mx2010_lbl 013006 `"Alfajayucan"', add
label define geo2_mx2010_lbl 013007 `"Almoloya"', add
label define geo2_mx2010_lbl 013008 `"Apan"', add
label define geo2_mx2010_lbl 013009 `"El Arenal"', add
label define geo2_mx2010_lbl 013010 `"Atitalaquia"', add
label define geo2_mx2010_lbl 013011 `"Atlapexco"', add
label define geo2_mx2010_lbl 013012 `"Atotonilco el Grande"', add
label define geo2_mx2010_lbl 013013 `"Atotonilco de Tula"', add
label define geo2_mx2010_lbl 013014 `"Calnali"', add
label define geo2_mx2010_lbl 013015 `"Cardonal"', add
label define geo2_mx2010_lbl 013016 `"Cuautepec de Hinojosa"', add
label define geo2_mx2010_lbl 013017 `"Chapantongo"', add
label define geo2_mx2010_lbl 013018 `"Chapulhuacán"', add
label define geo2_mx2010_lbl 013019 `"Chilcuautla"', add
label define geo2_mx2010_lbl 013020 `"Eloxochitlán"', add
label define geo2_mx2010_lbl 013021 `"Emiliano Zapata"', add
label define geo2_mx2010_lbl 013022 `"Epazoyucan"', add
label define geo2_mx2010_lbl 013023 `"Francisco I. Madero"', add
label define geo2_mx2010_lbl 013024 `"Huasca de Ocampo"', add
label define geo2_mx2010_lbl 013025 `"Huautla"', add
label define geo2_mx2010_lbl 013026 `"Huazalingo"', add
label define geo2_mx2010_lbl 013027 `"Huehuetla"', add
label define geo2_mx2010_lbl 013028 `"Huejutla de Reyes"', add
label define geo2_mx2010_lbl 013029 `"Huichapan"', add
label define geo2_mx2010_lbl 013030 `"Ixmiquilpan"', add
label define geo2_mx2010_lbl 013031 `"Jacala de Ledezma"', add
label define geo2_mx2010_lbl 013032 `"Jaltocán"', add
label define geo2_mx2010_lbl 013033 `"Juárez Hidalgo"', add
label define geo2_mx2010_lbl 013034 `"Lolotla"', add
label define geo2_mx2010_lbl 013035 `"Metepec"', add
label define geo2_mx2010_lbl 013036 `"San Agustín Metzquititlán"', add
label define geo2_mx2010_lbl 013037 `"Metztitlán"', add
label define geo2_mx2010_lbl 013038 `"Mineral del Chico"', add
label define geo2_mx2010_lbl 013039 `"Mineral del Monte"', add
label define geo2_mx2010_lbl 013040 `"La Misión"', add
label define geo2_mx2010_lbl 013041 `"Mixquiahuala de Juárez"', add
label define geo2_mx2010_lbl 013042 `"Molango de Escamilla"', add
label define geo2_mx2010_lbl 013043 `"Nicolás Flores"', add
label define geo2_mx2010_lbl 013044 `"Nopala de Villagrán"', add
label define geo2_mx2010_lbl 013045 `"Omitlán de Juárez"', add
label define geo2_mx2010_lbl 013046 `"San Felipe Orizatlán"', add
label define geo2_mx2010_lbl 013047 `"Pacula"', add
label define geo2_mx2010_lbl 013048 `"Pachuca de Soto"', add
label define geo2_mx2010_lbl 013049 `"Pisaflores"', add
label define geo2_mx2010_lbl 013050 `"Progreso de Obregón"', add
label define geo2_mx2010_lbl 013051 `"Mineral de la Reforma"', add
label define geo2_mx2010_lbl 013052 `"San Agustín Tlaxiaca"', add
label define geo2_mx2010_lbl 013053 `"San Bartolo Tutotepec"', add
label define geo2_mx2010_lbl 013054 `"San Salvador"', add
label define geo2_mx2010_lbl 013055 `"Santiago de Anaya"', add
label define geo2_mx2010_lbl 013056 `"Santiago Tulantepec de Lugo Guerrero"', add
label define geo2_mx2010_lbl 013057 `"Singuilucan"', add
label define geo2_mx2010_lbl 013058 `"Tasquillo"', add
label define geo2_mx2010_lbl 013059 `"Tecozautla"', add
label define geo2_mx2010_lbl 013060 `"Tenango de Doria"', add
label define geo2_mx2010_lbl 013061 `"Tepeapulco"', add
label define geo2_mx2010_lbl 013062 `"Tepehuacán de Guerrero"', add
label define geo2_mx2010_lbl 013063 `"Tepeji del Río de Ocampo"', add
label define geo2_mx2010_lbl 013064 `"Tepetitlán"', add
label define geo2_mx2010_lbl 013065 `"Tetepango"', add
label define geo2_mx2010_lbl 013066 `"Villa de Tezontepec"', add
label define geo2_mx2010_lbl 013067 `"Tezontepec de Aldama"', add
label define geo2_mx2010_lbl 013068 `"Tianguistengo"', add
label define geo2_mx2010_lbl 013069 `"Tizayuca"', add
label define geo2_mx2010_lbl 013070 `"Tlahuelilpan"', add
label define geo2_mx2010_lbl 013071 `"Tlahuiltepa"', add
label define geo2_mx2010_lbl 013072 `"Tlanalapa"', add
label define geo2_mx2010_lbl 013073 `"Tlanchinol"', add
label define geo2_mx2010_lbl 013074 `"Tlaxcoapan"', add
label define geo2_mx2010_lbl 013075 `"Tolcayuca"', add
label define geo2_mx2010_lbl 013076 `"Tula de Allende"', add
label define geo2_mx2010_lbl 013077 `"Tulancingo de Bravo"', add
label define geo2_mx2010_lbl 013078 `"Xochiatipan"', add
label define geo2_mx2010_lbl 013079 `"Xochicoatlán"', add
label define geo2_mx2010_lbl 013080 `"Yahualica"', add
label define geo2_mx2010_lbl 013081 `"Zacualtipán de Ángeles"', add
label define geo2_mx2010_lbl 013082 `"Zapotlán de Juárez"', add
label define geo2_mx2010_lbl 013083 `"Zempoala"', add
label define geo2_mx2010_lbl 013084 `"Zimapán"', add
label define geo2_mx2010_lbl 014001 `"Acatic"', add
label define geo2_mx2010_lbl 014002 `"Acatlán de Juárez"', add
label define geo2_mx2010_lbl 014003 `"Ahualulco de Mercado"', add
label define geo2_mx2010_lbl 014004 `"Amacueca"', add
label define geo2_mx2010_lbl 014005 `"Amatitán"', add
label define geo2_mx2010_lbl 014006 `"Ameca"', add
label define geo2_mx2010_lbl 014007 `"San Juanito de Escobedo"', add
label define geo2_mx2010_lbl 014008 `"Arandas"', add
label define geo2_mx2010_lbl 014009 `"El Arenal"', add
label define geo2_mx2010_lbl 014010 `"Atemajac de Brizuela"', add
label define geo2_mx2010_lbl 014011 `"Atengo"', add
label define geo2_mx2010_lbl 014012 `"Atenguillo"', add
label define geo2_mx2010_lbl 014013 `"Atotonilco el Alto"', add
label define geo2_mx2010_lbl 014014 `"Atoyac"', add
label define geo2_mx2010_lbl 014015 `"Autlán de Navarro"', add
label define geo2_mx2010_lbl 014016 `"Ayotlán"', add
label define geo2_mx2010_lbl 014017 `"Ayutla"', add
label define geo2_mx2010_lbl 014018 `"La Barca"', add
label define geo2_mx2010_lbl 014019 `"Bolaños"', add
label define geo2_mx2010_lbl 014020 `"Cabo Corrientes"', add
label define geo2_mx2010_lbl 014021 `"Casimiro Castillo"', add
label define geo2_mx2010_lbl 014022 `"Cihuatlán"', add
label define geo2_mx2010_lbl 014023 `"Zapotlán el Grande"', add
label define geo2_mx2010_lbl 014024 `"Cocula"', add
label define geo2_mx2010_lbl 014025 `"Colotlán"', add
label define geo2_mx2010_lbl 014026 `"Concepción de Buenos Aires"', add
label define geo2_mx2010_lbl 014027 `"Cuautitlán de García Barragán"', add
label define geo2_mx2010_lbl 014028 `"Cuautla"', add
label define geo2_mx2010_lbl 014029 `"Cuquío"', add
label define geo2_mx2010_lbl 014030 `"Chapala"', add
label define geo2_mx2010_lbl 014031 `"Chimaltitán"', add
label define geo2_mx2010_lbl 014032 `"Chiquilistlán"', add
label define geo2_mx2010_lbl 014033 `"Degollado"', add
label define geo2_mx2010_lbl 014034 `"Ejutla"', add
label define geo2_mx2010_lbl 014035 `"Encarnación de Díaz"', add
label define geo2_mx2010_lbl 014036 `"Etzatlán"', add
label define geo2_mx2010_lbl 014037 `"El Grullo"', add
label define geo2_mx2010_lbl 014038 `"Guachinango"', add
label define geo2_mx2010_lbl 014039 `"Guadalajara"', add
label define geo2_mx2010_lbl 014040 `"Hostotipaquillo"', add
label define geo2_mx2010_lbl 014041 `"Huejúcar"', add
label define geo2_mx2010_lbl 014042 `"Huejuquilla el Alto"', add
label define geo2_mx2010_lbl 014043 `"La Huerta"', add
label define geo2_mx2010_lbl 014044 `"Ixtlahuacán de los Membrillos"', add
label define geo2_mx2010_lbl 014045 `"Ixtlahuacán del Río"', add
label define geo2_mx2010_lbl 014046 `"Jalostotitlán"', add
label define geo2_mx2010_lbl 014047 `"Jamay"', add
label define geo2_mx2010_lbl 014048 `"Jesús María"', add
label define geo2_mx2010_lbl 014049 `"Jilotlán de los Dolores"', add
label define geo2_mx2010_lbl 014050 `"Jocotepec"', add
label define geo2_mx2010_lbl 014051 `"Juanacatlán"', add
label define geo2_mx2010_lbl 014052 `"Juchitlán"', add
label define geo2_mx2010_lbl 014053 `"Lagos de Moreno"', add
label define geo2_mx2010_lbl 014054 `"El Limón"', add
label define geo2_mx2010_lbl 014055 `"Magdalena"', add
label define geo2_mx2010_lbl 014056 `"Santa María del Oro"', add
label define geo2_mx2010_lbl 014057 `"La Manzanilla de la Paz"', add
label define geo2_mx2010_lbl 014058 `"Mascota"', add
label define geo2_mx2010_lbl 014059 `"Mazamitla"', add
label define geo2_mx2010_lbl 014060 `"Mexticacán"', add
label define geo2_mx2010_lbl 014061 `"Mezquitic"', add
label define geo2_mx2010_lbl 014062 `"Mixtlán"', add
label define geo2_mx2010_lbl 014063 `"Ocotlán"', add
label define geo2_mx2010_lbl 014064 `"Ojuelos de Jalisco"', add
label define geo2_mx2010_lbl 014065 `"Pihuamo"', add
label define geo2_mx2010_lbl 014066 `"Poncitlán"', add
label define geo2_mx2010_lbl 014067 `"Puerto Vallarta"', add
label define geo2_mx2010_lbl 014068 `"Villa Purificación"', add
label define geo2_mx2010_lbl 014069 `"Quitupan"', add
label define geo2_mx2010_lbl 014070 `"El Salto"', add
label define geo2_mx2010_lbl 014071 `"San Cristóbal de la Barranca"', add
label define geo2_mx2010_lbl 014072 `"San Diego de Alejandría"', add
label define geo2_mx2010_lbl 014073 `"San Juan de los Lagos"', add
label define geo2_mx2010_lbl 014074 `"San Julián"', add
label define geo2_mx2010_lbl 014075 `"San Marcos"', add
label define geo2_mx2010_lbl 014076 `"San Martín de Bolaños"', add
label define geo2_mx2010_lbl 014077 `"San Martín Hidalgo"', add
label define geo2_mx2010_lbl 014078 `"San Miguel el Alto"', add
label define geo2_mx2010_lbl 014079 `"Gómez Farías"', add
label define geo2_mx2010_lbl 014080 `"San Sebastián del Oeste"', add
label define geo2_mx2010_lbl 014081 `"Santa María de los Ángeles"', add
label define geo2_mx2010_lbl 014082 `"Sayula"', add
label define geo2_mx2010_lbl 014083 `"Tala"', add
label define geo2_mx2010_lbl 014084 `"Talpa de Allende"', add
label define geo2_mx2010_lbl 014085 `"Tamazula de Gordiano"', add
label define geo2_mx2010_lbl 014086 `"Tapalpa"', add
label define geo2_mx2010_lbl 014087 `"Tecalitlán"', add
label define geo2_mx2010_lbl 014088 `"Tecolotlán"', add
label define geo2_mx2010_lbl 014089 `"Techaluta de Montenegro"', add
label define geo2_mx2010_lbl 014090 `"Tenamaxtlán"', add
label define geo2_mx2010_lbl 014091 `"Teocaltiche"', add
label define geo2_mx2010_lbl 014092 `"Teocuitatlán de Corona"', add
label define geo2_mx2010_lbl 014093 `"Tepatitlán de Morelos"', add
label define geo2_mx2010_lbl 014094 `"Tequila"', add
label define geo2_mx2010_lbl 014095 `"Teuchitlán"', add
label define geo2_mx2010_lbl 014096 `"Tizapán el Alto"', add
label define geo2_mx2010_lbl 014097 `"Tlajomulco de Zúñiga"', add
label define geo2_mx2010_lbl 014098 `"Tlaquepaque"', add
label define geo2_mx2010_lbl 014099 `"Tolimán"', add
label define geo2_mx2010_lbl 014100 `"Tomatlán"', add
label define geo2_mx2010_lbl 014101 `"Tonalá"', add
label define geo2_mx2010_lbl 014102 `"Tonaya"', add
label define geo2_mx2010_lbl 014103 `"Tonila"', add
label define geo2_mx2010_lbl 014104 `"Totatiche"', add
label define geo2_mx2010_lbl 014105 `"Tototlán"', add
label define geo2_mx2010_lbl 014106 `"Tuxcacuesco"', add
label define geo2_mx2010_lbl 014107 `"Tuxcueca"', add
label define geo2_mx2010_lbl 014108 `"Tuxpan"', add
label define geo2_mx2010_lbl 014109 `"Unión de San Antonio"', add
label define geo2_mx2010_lbl 014110 `"Unión de Tula"', add
label define geo2_mx2010_lbl 014111 `"Valle de Guadalupe"', add
label define geo2_mx2010_lbl 014112 `"Valle de Juárez"', add
label define geo2_mx2010_lbl 014113 `"San Gabriel"', add
label define geo2_mx2010_lbl 014114 `"Villa Corona"', add
label define geo2_mx2010_lbl 014115 `"Villa Guerrero"', add
label define geo2_mx2010_lbl 014116 `"Villa Hidalgo"', add
label define geo2_mx2010_lbl 014117 `"Cañadas de Obregón"', add
label define geo2_mx2010_lbl 014118 `"Yahualica de González Gallo"', add
label define geo2_mx2010_lbl 014119 `"Zacoalco de Torres"', add
label define geo2_mx2010_lbl 014120 `"Zapopan"', add
label define geo2_mx2010_lbl 014121 `"Zapotiltic"', add
label define geo2_mx2010_lbl 014122 `"Zapotitlán de Vadillo"', add
label define geo2_mx2010_lbl 014123 `"Zapotlán del Rey"', add
label define geo2_mx2010_lbl 014124 `"Zapotlanejo"', add
label define geo2_mx2010_lbl 014125 `"San Ignacio Cerro Gordo"', add
label define geo2_mx2010_lbl 015001 `"Acambay"', add
label define geo2_mx2010_lbl 015002 `"Acolman"', add
label define geo2_mx2010_lbl 015003 `"Aculco"', add
label define geo2_mx2010_lbl 015004 `"Almoloya de Alquisiras"', add
label define geo2_mx2010_lbl 015005 `"Almoloya de Juárez"', add
label define geo2_mx2010_lbl 015006 `"Almoloya del Río"', add
label define geo2_mx2010_lbl 015007 `"Amanalco"', add
label define geo2_mx2010_lbl 015008 `"Amatepec"', add
label define geo2_mx2010_lbl 015009 `"Amecameca"', add
label define geo2_mx2010_lbl 015010 `"Apaxco"', add
label define geo2_mx2010_lbl 015011 `"Atenco"', add
label define geo2_mx2010_lbl 015012 `"Atizapán"', add
label define geo2_mx2010_lbl 015013 `"Atizapán de Zaragoza"', add
label define geo2_mx2010_lbl 015014 `"Atlacomulco"', add
label define geo2_mx2010_lbl 015015 `"Atlautla"', add
label define geo2_mx2010_lbl 015016 `"Axapusco"', add
label define geo2_mx2010_lbl 015017 `"Ayapango"', add
label define geo2_mx2010_lbl 015018 `"Calimaya"', add
label define geo2_mx2010_lbl 015019 `"Capulhuac"', add
label define geo2_mx2010_lbl 015020 `"Coacalco de Berriozábal"', add
label define geo2_mx2010_lbl 015021 `"Coatepec Harinas"', add
label define geo2_mx2010_lbl 015022 `"Cocotitlán"', add
label define geo2_mx2010_lbl 015023 `"Coyotepec"', add
label define geo2_mx2010_lbl 015024 `"Cuautitlán"', add
label define geo2_mx2010_lbl 015025 `"Chalco"', add
label define geo2_mx2010_lbl 015026 `"Chapa de Mota"', add
label define geo2_mx2010_lbl 015027 `"Chapultepec"', add
label define geo2_mx2010_lbl 015028 `"Chiautla"', add
label define geo2_mx2010_lbl 015029 `"Chicoloapan"', add
label define geo2_mx2010_lbl 015030 `"Chiconcuac"', add
label define geo2_mx2010_lbl 015031 `"Chimalhuacán"', add
label define geo2_mx2010_lbl 015032 `"Donato Guerra"', add
label define geo2_mx2010_lbl 015033 `"Ecatepec de Morelos"', add
label define geo2_mx2010_lbl 015034 `"Ecatzingo"', add
label define geo2_mx2010_lbl 015035 `"Huehuetoca"', add
label define geo2_mx2010_lbl 015036 `"Hueypoxtla"', add
label define geo2_mx2010_lbl 015037 `"Huixquilucan"', add
label define geo2_mx2010_lbl 015038 `"Isidro Fabela"', add
label define geo2_mx2010_lbl 015039 `"Ixtapaluca"', add
label define geo2_mx2010_lbl 015040 `"Ixtapan de la Sal"', add
label define geo2_mx2010_lbl 015041 `"Ixtapan del Oro"', add
label define geo2_mx2010_lbl 015042 `"Ixtlahuaca"', add
label define geo2_mx2010_lbl 015043 `"Xalatlaco"', add
label define geo2_mx2010_lbl 015044 `"Jaltenco"', add
label define geo2_mx2010_lbl 015045 `"Jilotepec"', add
label define geo2_mx2010_lbl 015046 `"Jilotzingo"', add
label define geo2_mx2010_lbl 015047 `"Jiquipilco"', add
label define geo2_mx2010_lbl 015048 `"Jocotitlán"', add
label define geo2_mx2010_lbl 015049 `"Joquicingo"', add
label define geo2_mx2010_lbl 015050 `"Juchitepec"', add
label define geo2_mx2010_lbl 015051 `"Lerma"', add
label define geo2_mx2010_lbl 015052 `"Malinalco"', add
label define geo2_mx2010_lbl 015053 `"Melchor Ocampo"', add
label define geo2_mx2010_lbl 015054 `"Metepec"', add
label define geo2_mx2010_lbl 015055 `"Mexicaltzingo"', add
label define geo2_mx2010_lbl 015056 `"Morelos"', add
label define geo2_mx2010_lbl 015057 `"Naucalpan de Juárez"', add
label define geo2_mx2010_lbl 015058 `"Nezahualcóyotl"', add
label define geo2_mx2010_lbl 015059 `"Nextlalpan"', add
label define geo2_mx2010_lbl 015060 `"Nicolás Romero"', add
label define geo2_mx2010_lbl 015061 `"Nopaltepec"', add
label define geo2_mx2010_lbl 015062 `"Ocoyoacac"', add
label define geo2_mx2010_lbl 015063 `"Ocuilan"', add
label define geo2_mx2010_lbl 015064 `"El Oro"', add
label define geo2_mx2010_lbl 015065 `"Otumba"', add
label define geo2_mx2010_lbl 015066 `"Otzoloapan"', add
label define geo2_mx2010_lbl 015067 `"Otzolotepec"', add
label define geo2_mx2010_lbl 015068 `"Ozumba"', add
label define geo2_mx2010_lbl 015069 `"Papalotla"', add
label define geo2_mx2010_lbl 015070 `"La Paz"', add
label define geo2_mx2010_lbl 015071 `"Polotitlán"', add
label define geo2_mx2010_lbl 015072 `"Rayón"', add
label define geo2_mx2010_lbl 015073 `"San Antonio la Isla"', add
label define geo2_mx2010_lbl 015074 `"San Felipe del Progreso"', add
label define geo2_mx2010_lbl 015075 `"San Martín de las Pirámides"', add
label define geo2_mx2010_lbl 015076 `"San Mateo Atenco"', add
label define geo2_mx2010_lbl 015077 `"San Simón de Guerrero"', add
label define geo2_mx2010_lbl 015078 `"Santo Tomás"', add
label define geo2_mx2010_lbl 015079 `"Soyaniquilpan de Juárez"', add
label define geo2_mx2010_lbl 015080 `"Sultepec"', add
label define geo2_mx2010_lbl 015081 `"Tecámac"', add
label define geo2_mx2010_lbl 015082 `"Tejupilco"', add
label define geo2_mx2010_lbl 015083 `"Temamatla"', add
label define geo2_mx2010_lbl 015084 `"Temascalapa"', add
label define geo2_mx2010_lbl 015085 `"Temascalcingo"', add
label define geo2_mx2010_lbl 015086 `"Temascaltepec"', add
label define geo2_mx2010_lbl 015087 `"Temoaya"', add
label define geo2_mx2010_lbl 015088 `"Tenancingo"', add
label define geo2_mx2010_lbl 015089 `"Tenango del Aire"', add
label define geo2_mx2010_lbl 015090 `"Tenango del Valle"', add
label define geo2_mx2010_lbl 015091 `"Teoloyucán"', add
label define geo2_mx2010_lbl 015092 `"Teotihuacán"', add
label define geo2_mx2010_lbl 015093 `"Tepetlaoxtoc"', add
label define geo2_mx2010_lbl 015094 `"Tepetlixpa"', add
label define geo2_mx2010_lbl 015095 `"Tepotzotlán"', add
label define geo2_mx2010_lbl 015096 `"Tequixquiac"', add
label define geo2_mx2010_lbl 015097 `"Texcaltitlán"', add
label define geo2_mx2010_lbl 015098 `"Texcalyacac"', add
label define geo2_mx2010_lbl 015099 `"Texcoco"', add
label define geo2_mx2010_lbl 015100 `"Tezoyuca"', add
label define geo2_mx2010_lbl 015101 `"Tianguistenco"', add
label define geo2_mx2010_lbl 015102 `"Timilpan"', add
label define geo2_mx2010_lbl 015103 `"Tlalmanalco"', add
label define geo2_mx2010_lbl 015104 `"Tlalnepantla de Baz"', add
label define geo2_mx2010_lbl 015105 `"Tlatlaya"', add
label define geo2_mx2010_lbl 015106 `"Toluca"', add
label define geo2_mx2010_lbl 015107 `"Tonatico"', add
label define geo2_mx2010_lbl 015108 `"Tultepec"', add
label define geo2_mx2010_lbl 015109 `"Tultitlán"', add
label define geo2_mx2010_lbl 015110 `"Valle de Bravo"', add
label define geo2_mx2010_lbl 015111 `"Villa de Allende"', add
label define geo2_mx2010_lbl 015112 `"Villa del Carbón"', add
label define geo2_mx2010_lbl 015113 `"Villa Guerrero"', add
label define geo2_mx2010_lbl 015114 `"Villa Victoria"', add
label define geo2_mx2010_lbl 015115 `"Xonacatlán"', add
label define geo2_mx2010_lbl 015116 `"Zacazonapan"', add
label define geo2_mx2010_lbl 015117 `"Zacualpan"', add
label define geo2_mx2010_lbl 015118 `"Zinacantepec"', add
label define geo2_mx2010_lbl 015119 `"Zumpahuacán"', add
label define geo2_mx2010_lbl 015120 `"Zumpango"', add
label define geo2_mx2010_lbl 015121 `"Cuautitlán Izcalli"', add
label define geo2_mx2010_lbl 015122 `"Valle de Chalco Solidaridad"', add
label define geo2_mx2010_lbl 015123 `"Luvianos"', add
label define geo2_mx2010_lbl 015124 `"San José del Rincón"', add
label define geo2_mx2010_lbl 015125 `"Tonanitla"', add
label define geo2_mx2010_lbl 016001 `"Acuitzio"', add
label define geo2_mx2010_lbl 016002 `"Aguililla"', add
label define geo2_mx2010_lbl 016003 `"Álvaro Obregón"', add
label define geo2_mx2010_lbl 016004 `"Angamacutiro"', add
label define geo2_mx2010_lbl 016005 `"Angangueo"', add
label define geo2_mx2010_lbl 016006 `"Apatzingán"', add
label define geo2_mx2010_lbl 016007 `"Aporo"', add
label define geo2_mx2010_lbl 016008 `"Aquila"', add
label define geo2_mx2010_lbl 016009 `"Ario"', add
label define geo2_mx2010_lbl 016010 `"Arteaga"', add
label define geo2_mx2010_lbl 016011 `"Briseñas"', add
label define geo2_mx2010_lbl 016012 `"Buenavista"', add
label define geo2_mx2010_lbl 016013 `"Carácuaro"', add
label define geo2_mx2010_lbl 016014 `"Coahuayana"', add
label define geo2_mx2010_lbl 016015 `"Coalcomán de Vázquez Pallares"', add
label define geo2_mx2010_lbl 016016 `"Coeneo"', add
label define geo2_mx2010_lbl 016017 `"Contepec"', add
label define geo2_mx2010_lbl 016018 `"Copándaro"', add
label define geo2_mx2010_lbl 016019 `"Cotija"', add
label define geo2_mx2010_lbl 016020 `"Cuitzeo"', add
label define geo2_mx2010_lbl 016021 `"Charapan"', add
label define geo2_mx2010_lbl 016022 `"Charo"', add
label define geo2_mx2010_lbl 016023 `"Chavinda"', add
label define geo2_mx2010_lbl 016024 `"Cherán"', add
label define geo2_mx2010_lbl 016025 `"Chilchota"', add
label define geo2_mx2010_lbl 016026 `"Chinicuila"', add
label define geo2_mx2010_lbl 016027 `"Chucándiro"', add
label define geo2_mx2010_lbl 016028 `"Churintzio"', add
label define geo2_mx2010_lbl 016029 `"Churumuco"', add
label define geo2_mx2010_lbl 016030 `"Ecuandureo"', add
label define geo2_mx2010_lbl 016031 `"Epitacio Huerta"', add
label define geo2_mx2010_lbl 016032 `"Erongarícuaro"', add
label define geo2_mx2010_lbl 016033 `"Gabriel Zamora"', add
label define geo2_mx2010_lbl 016034 `"Hidalgo"', add
label define geo2_mx2010_lbl 016035 `"La Huacana"', add
label define geo2_mx2010_lbl 016036 `"Huandacareo"', add
label define geo2_mx2010_lbl 016037 `"Huaniqueo"', add
label define geo2_mx2010_lbl 016038 `"Huetamo"', add
label define geo2_mx2010_lbl 016039 `"Huiramba"', add
label define geo2_mx2010_lbl 016040 `"Indaparapeo"', add
label define geo2_mx2010_lbl 016041 `"Irimbo"', add
label define geo2_mx2010_lbl 016042 `"Ixtlán"', add
label define geo2_mx2010_lbl 016043 `"Jacona"', add
label define geo2_mx2010_lbl 016044 `"Jiménez"', add
label define geo2_mx2010_lbl 016045 `"Jiquilpan"', add
label define geo2_mx2010_lbl 016046 `"Juárez"', add
label define geo2_mx2010_lbl 016047 `"Jungapeo"', add
label define geo2_mx2010_lbl 016048 `"Lagunillas"', add
label define geo2_mx2010_lbl 016049 `"Madero"', add
label define geo2_mx2010_lbl 016050 `"Maravatío"', add
label define geo2_mx2010_lbl 016051 `"Marcos Castellanos"', add
label define geo2_mx2010_lbl 016052 `"Lázaro Cárdenas"', add
label define geo2_mx2010_lbl 016053 `"Morelia"', add
label define geo2_mx2010_lbl 016054 `"Morelos"', add
label define geo2_mx2010_lbl 016055 `"Múgica"', add
label define geo2_mx2010_lbl 016056 `"Nahuatzen"', add
label define geo2_mx2010_lbl 016057 `"Nocupétaro"', add
label define geo2_mx2010_lbl 016058 `"Nuevo Parangaricutiro"', add
label define geo2_mx2010_lbl 016059 `"Nuevo Urecho"', add
label define geo2_mx2010_lbl 016060 `"Numarán"', add
label define geo2_mx2010_lbl 016061 `"Ocampo"', add
label define geo2_mx2010_lbl 016062 `"Pajacuarán"', add
label define geo2_mx2010_lbl 016063 `"Panindícuaro"', add
label define geo2_mx2010_lbl 016064 `"Parácuaro"', add
label define geo2_mx2010_lbl 016065 `"Paracho"', add
label define geo2_mx2010_lbl 016066 `"Pátzcuaro"', add
label define geo2_mx2010_lbl 016067 `"Penjamillo"', add
label define geo2_mx2010_lbl 016068 `"Peribán"', add
label define geo2_mx2010_lbl 016069 `"La Piedad"', add
label define geo2_mx2010_lbl 016070 `"Purépero"', add
label define geo2_mx2010_lbl 016071 `"Puruándiro"', add
label define geo2_mx2010_lbl 016072 `"Queréndaro"', add
label define geo2_mx2010_lbl 016073 `"Quiroga"', add
label define geo2_mx2010_lbl 016074 `"Cojumatlán de Régules"', add
label define geo2_mx2010_lbl 016075 `"Los Reyes"', add
label define geo2_mx2010_lbl 016076 `"Sahuayo"', add
label define geo2_mx2010_lbl 016077 `"San Lucas"', add
label define geo2_mx2010_lbl 016078 `"Santa Ana Maya"', add
label define geo2_mx2010_lbl 016079 `"Salvador Escalante"', add
label define geo2_mx2010_lbl 016080 `"Senguio"', add
label define geo2_mx2010_lbl 016081 `"Susupuato"', add
label define geo2_mx2010_lbl 016082 `"Tacámbaro"', add
label define geo2_mx2010_lbl 016083 `"Tancítaro"', add
label define geo2_mx2010_lbl 016084 `"Tangamandapio"', add
label define geo2_mx2010_lbl 016085 `"Tangancícuaro"', add
label define geo2_mx2010_lbl 016086 `"Tanhuato"', add
label define geo2_mx2010_lbl 016087 `"Taretan"', add
label define geo2_mx2010_lbl 016088 `"Tarímbaro"', add
label define geo2_mx2010_lbl 016089 `"Tepalcatepec"', add
label define geo2_mx2010_lbl 016090 `"Tingambato"', add
label define geo2_mx2010_lbl 016091 `"Tingüindín"', add
label define geo2_mx2010_lbl 016092 `"Tiquicheo de Nicolás Romero"', add
label define geo2_mx2010_lbl 016093 `"Tlalpujahua"', add
label define geo2_mx2010_lbl 016094 `"Tlazazalca"', add
label define geo2_mx2010_lbl 016095 `"Tocumbo"', add
label define geo2_mx2010_lbl 016096 `"Tumbiscatío"', add
label define geo2_mx2010_lbl 016097 `"Turicato"', add
label define geo2_mx2010_lbl 016098 `"Tuxpan"', add
label define geo2_mx2010_lbl 016099 `"Tuzantla"', add
label define geo2_mx2010_lbl 016100 `"Tzintzuntzan"', add
label define geo2_mx2010_lbl 016101 `"Tzitzio"', add
label define geo2_mx2010_lbl 016102 `"Uruapan"', add
label define geo2_mx2010_lbl 016103 `"Venustiano Carranza"', add
label define geo2_mx2010_lbl 016104 `"Villamar"', add
label define geo2_mx2010_lbl 016105 `"Vista Hermosa"', add
label define geo2_mx2010_lbl 016106 `"Yurécuaro"', add
label define geo2_mx2010_lbl 016107 `"Zacapu"', add
label define geo2_mx2010_lbl 016108 `"Zamora"', add
label define geo2_mx2010_lbl 016109 `"Zináparo"', add
label define geo2_mx2010_lbl 016110 `"Zinapécuaro"', add
label define geo2_mx2010_lbl 016111 `"Ziracuaretiro"', add
label define geo2_mx2010_lbl 016112 `"Zitácuaro"', add
label define geo2_mx2010_lbl 016113 `"José Sixto Verduzco"', add
label define geo2_mx2010_lbl 017001 `"Amacuzac"', add
label define geo2_mx2010_lbl 017002 `"Atlatlahucan"', add
label define geo2_mx2010_lbl 017003 `"Axochiapan"', add
label define geo2_mx2010_lbl 017004 `"Ayala"', add
label define geo2_mx2010_lbl 017005 `"Coatlán del Río"', add
label define geo2_mx2010_lbl 017006 `"Cuautla"', add
label define geo2_mx2010_lbl 017007 `"Cuernavaca"', add
label define geo2_mx2010_lbl 017008 `"Emiliano Zapata"', add
label define geo2_mx2010_lbl 017009 `"Huitzilac"', add
label define geo2_mx2010_lbl 017010 `"Jantetelco"', add
label define geo2_mx2010_lbl 017011 `"Jiutepec"', add
label define geo2_mx2010_lbl 017012 `"Jojutla"', add
label define geo2_mx2010_lbl 017013 `"Jonacatepec"', add
label define geo2_mx2010_lbl 017014 `"Mazatepec"', add
label define geo2_mx2010_lbl 017015 `"Miacatlán"', add
label define geo2_mx2010_lbl 017016 `"Ocuituco"', add
label define geo2_mx2010_lbl 017017 `"Puente de Ixtla"', add
label define geo2_mx2010_lbl 017018 `"Temixco"', add
label define geo2_mx2010_lbl 017019 `"Tepalcingo"', add
label define geo2_mx2010_lbl 017020 `"Tepoztlán"', add
label define geo2_mx2010_lbl 017021 `"Tetecala"', add
label define geo2_mx2010_lbl 017022 `"Tetela del Volcán"', add
label define geo2_mx2010_lbl 017023 `"Tlalnepantla"', add
label define geo2_mx2010_lbl 017024 `"Tlaltizapán"', add
label define geo2_mx2010_lbl 017025 `"Tlaquiltenango"', add
label define geo2_mx2010_lbl 017026 `"Tlayacapan"', add
label define geo2_mx2010_lbl 017027 `"Totolapan"', add
label define geo2_mx2010_lbl 017028 `"Xochitepec"', add
label define geo2_mx2010_lbl 017029 `"Yautepec"', add
label define geo2_mx2010_lbl 017030 `"Yecapixtla"', add
label define geo2_mx2010_lbl 017031 `"Zacatepec"', add
label define geo2_mx2010_lbl 017032 `"Zacualpan"', add
label define geo2_mx2010_lbl 017033 `"Temoac"', add
label define geo2_mx2010_lbl 018001 `"Acaponeta"', add
label define geo2_mx2010_lbl 018002 `"Ahuacatlán"', add
label define geo2_mx2010_lbl 018003 `"Amatlán de Cañas"', add
label define geo2_mx2010_lbl 018004 `"Compostela"', add
label define geo2_mx2010_lbl 018005 `"Huajicori"', add
label define geo2_mx2010_lbl 018006 `"Ixtlán del Río"', add
label define geo2_mx2010_lbl 018007 `"Jala"', add
label define geo2_mx2010_lbl 018008 `"Xalisco"', add
label define geo2_mx2010_lbl 018009 `"Del Nayar"', add
label define geo2_mx2010_lbl 018010 `"Rosamorada"', add
label define geo2_mx2010_lbl 018011 `"Ruíz"', add
label define geo2_mx2010_lbl 018012 `"San Blas"', add
label define geo2_mx2010_lbl 018013 `"San Pedro Lagunillas"', add
label define geo2_mx2010_lbl 018014 `"Santa María del Oro"', add
label define geo2_mx2010_lbl 018015 `"Santiago Ixcuintla"', add
label define geo2_mx2010_lbl 018016 `"Tecuala"', add
label define geo2_mx2010_lbl 018017 `"Tepic"', add
label define geo2_mx2010_lbl 018018 `"Tuxpan"', add
label define geo2_mx2010_lbl 018019 `"La Yesca"', add
label define geo2_mx2010_lbl 018020 `"Bahía de Banderas"', add
label define geo2_mx2010_lbl 019001 `"Abasolo"', add
label define geo2_mx2010_lbl 019002 `"Agualeguas"', add
label define geo2_mx2010_lbl 019003 `"Los Aldamas"', add
label define geo2_mx2010_lbl 019004 `"Allende"', add
label define geo2_mx2010_lbl 019005 `"Anáhuac"', add
label define geo2_mx2010_lbl 019006 `"Apodaca"', add
label define geo2_mx2010_lbl 019007 `"Aramberri"', add
label define geo2_mx2010_lbl 019008 `"Bustamante"', add
label define geo2_mx2010_lbl 019009 `"Cadereyta Jiménez"', add
label define geo2_mx2010_lbl 019010 `"Carmen"', add
label define geo2_mx2010_lbl 019011 `"Cerralvo"', add
label define geo2_mx2010_lbl 019012 `"Ciénega de Flores"', add
label define geo2_mx2010_lbl 019013 `"China"', add
label define geo2_mx2010_lbl 019014 `"Dr. Arroyo"', add
label define geo2_mx2010_lbl 019015 `"Dr. Coss"', add
label define geo2_mx2010_lbl 019016 `"Dr. González"', add
label define geo2_mx2010_lbl 019017 `"Galeana"', add
label define geo2_mx2010_lbl 019018 `"García"', add
label define geo2_mx2010_lbl 019019 `"San Pedro Garza García"', add
label define geo2_mx2010_lbl 019020 `"Gral. Bravo"', add
label define geo2_mx2010_lbl 019021 `"Gral. Escobedo"', add
label define geo2_mx2010_lbl 019022 `"Gral. Terán"', add
label define geo2_mx2010_lbl 019023 `"Gral. Treviño"', add
label define geo2_mx2010_lbl 019024 `"Gral. Zaragoza"', add
label define geo2_mx2010_lbl 019025 `"Gral. Zuazua"', add
label define geo2_mx2010_lbl 019026 `"Guadalupe"', add
label define geo2_mx2010_lbl 019027 `"Los Herreras"', add
label define geo2_mx2010_lbl 019028 `"Higueras"', add
label define geo2_mx2010_lbl 019029 `"Hualahuises"', add
label define geo2_mx2010_lbl 019030 `"Iturbide"', add
label define geo2_mx2010_lbl 019031 `"Juárez"', add
label define geo2_mx2010_lbl 019032 `"Lampazos de Naranjo"', add
label define geo2_mx2010_lbl 019033 `"Linares"', add
label define geo2_mx2010_lbl 019034 `"Marín"', add
label define geo2_mx2010_lbl 019035 `"Melchor Ocampo"', add
label define geo2_mx2010_lbl 019036 `"Mier y Noriega"', add
label define geo2_mx2010_lbl 019037 `"Mina"', add
label define geo2_mx2010_lbl 019038 `"Montemorelos"', add
label define geo2_mx2010_lbl 019039 `"Monterrey"', add
label define geo2_mx2010_lbl 019040 `"Parás"', add
label define geo2_mx2010_lbl 019041 `"Pesquería"', add
label define geo2_mx2010_lbl 019042 `"Los Ramones"', add
label define geo2_mx2010_lbl 019043 `"Rayones"', add
label define geo2_mx2010_lbl 019044 `"Sabinas Hidalgo"', add
label define geo2_mx2010_lbl 019045 `"Salinas Victoria"', add
label define geo2_mx2010_lbl 019046 `"San Nicolás de los Garza"', add
label define geo2_mx2010_lbl 019047 `"Hidalgo"', add
label define geo2_mx2010_lbl 019048 `"Santa Catarina"', add
label define geo2_mx2010_lbl 019049 `"Santiago"', add
label define geo2_mx2010_lbl 019050 `"Vallecillo"', add
label define geo2_mx2010_lbl 019051 `"Villaldama"', add
label define geo2_mx2010_lbl 020001 `"Abejones"', add
label define geo2_mx2010_lbl 020002 `"Acatlán de Pérez Figueroa"', add
label define geo2_mx2010_lbl 020003 `"Asunción Cacalotepec"', add
label define geo2_mx2010_lbl 020004 `"Asunción Cuyotepeji"', add
label define geo2_mx2010_lbl 020005 `"Asunción Ixtaltepec"', add
label define geo2_mx2010_lbl 020006 `"Asunción Nochixtlán"', add
label define geo2_mx2010_lbl 020007 `"Asunción Ocotlán"', add
label define geo2_mx2010_lbl 020008 `"Asunción Tlacolulita"', add
label define geo2_mx2010_lbl 020009 `"Ayotzintepec"', add
label define geo2_mx2010_lbl 020010 `"El Barrio de la Soledad"', add
label define geo2_mx2010_lbl 020011 `"Calihualá"', add
label define geo2_mx2010_lbl 020012 `"Candelaria Loxicha"', add
label define geo2_mx2010_lbl 020013 `"Ciénega de Zimatlán"', add
label define geo2_mx2010_lbl 020014 `"Ciudad Ixtepec"', add
label define geo2_mx2010_lbl 020015 `"Coatecas Altas"', add
label define geo2_mx2010_lbl 020016 `"Coicoyán de las Flores"', add
label define geo2_mx2010_lbl 020017 `"La Compañía"', add
label define geo2_mx2010_lbl 020018 `"Concepción Buenavista"', add
label define geo2_mx2010_lbl 020019 `"Concepción Pápalo"', add
label define geo2_mx2010_lbl 020020 `"Constancia del Rosario"', add
label define geo2_mx2010_lbl 020021 `"Cosolapa"', add
label define geo2_mx2010_lbl 020022 `"Cosoltepec"', add
label define geo2_mx2010_lbl 020023 `"Cuilápam de Guerrero"', add
label define geo2_mx2010_lbl 020024 `"Cuyamecalco Villa de Zaragoza"', add
label define geo2_mx2010_lbl 020025 `"Chahuites"', add
label define geo2_mx2010_lbl 020026 `"Chalcatongo de Hidalgo"', add
label define geo2_mx2010_lbl 020027 `"Chiquihuitlán de Benito Juárez"', add
label define geo2_mx2010_lbl 020028 `"Heroica Ciudad de Ejutla de Crespo"', add
label define geo2_mx2010_lbl 020029 `"Eloxochitlán de Flores Magón"', add
label define geo2_mx2010_lbl 020030 `"El Espinal"', add
label define geo2_mx2010_lbl 020031 `"Tamazulápam del Espíritu Santo"', add
label define geo2_mx2010_lbl 020032 `"Fresnillo de Trujano"', add
label define geo2_mx2010_lbl 020033 `"Guadalupe Etla"', add
label define geo2_mx2010_lbl 020034 `"Guadalupe de Ramírez"', add
label define geo2_mx2010_lbl 020035 `"Guelatao de Juárez"', add
label define geo2_mx2010_lbl 020036 `"Guevea de Humboldt"', add
label define geo2_mx2010_lbl 020037 `"Mesones Hidalgo"', add
label define geo2_mx2010_lbl 020038 `"Villa Hidalgo"', add
label define geo2_mx2010_lbl 020039 `"Heroica Ciudad de Huajuapan de León"', add
label define geo2_mx2010_lbl 020040 `"Huautepec"', add
label define geo2_mx2010_lbl 020041 `"Huautla de Jiménez"', add
label define geo2_mx2010_lbl 020042 `"Ixtlán de Juárez"', add
label define geo2_mx2010_lbl 020043 `"Heroica Ciudad de Juchitán de Zaragoza"', add
label define geo2_mx2010_lbl 020044 `"Loma Bonita"', add
label define geo2_mx2010_lbl 020045 `"Magdalena Apasco"', add
label define geo2_mx2010_lbl 020046 `"Magdalena Jaltepec"', add
label define geo2_mx2010_lbl 020047 `"Santa Magdalena Jicotlán"', add
label define geo2_mx2010_lbl 020048 `"Magdalena Mixtepec"', add
label define geo2_mx2010_lbl 020049 `"Magdalena Ocotlán"', add
label define geo2_mx2010_lbl 020050 `"Magdalena Peñasco"', add
label define geo2_mx2010_lbl 020051 `"Magdalena Teitipac"', add
label define geo2_mx2010_lbl 020052 `"Magdalena Tequisistlán"', add
label define geo2_mx2010_lbl 020053 `"Magdalena Tlacotepec"', add
label define geo2_mx2010_lbl 020054 `"Magdalena Zahuatlán"', add
label define geo2_mx2010_lbl 020055 `"Mariscala de Juárez"', add
label define geo2_mx2010_lbl 020056 `"Mártires de Tacubaya"', add
label define geo2_mx2010_lbl 020057 `"Matías Romero Avendaño"', add
label define geo2_mx2010_lbl 020058 `"Mazatlán Villa de Flores"', add
label define geo2_mx2010_lbl 020059 `"Miahuatlán de Porfirio Díaz"', add
label define geo2_mx2010_lbl 020060 `"Mixistlán de la Reforma"', add
label define geo2_mx2010_lbl 020061 `"Monjas"', add
label define geo2_mx2010_lbl 020062 `"Natividad"', add
label define geo2_mx2010_lbl 020063 `"Nazareno Etla"', add
label define geo2_mx2010_lbl 020064 `"Nejapa de Madero"', add
label define geo2_mx2010_lbl 020065 `"Ixpantepec Nieves"', add
label define geo2_mx2010_lbl 020066 `"Santiago Niltepec"', add
label define geo2_mx2010_lbl 020067 `"Oaxaca de Juárez"', add
label define geo2_mx2010_lbl 020068 `"Ocotlán de Morelos"', add
label define geo2_mx2010_lbl 020069 `"La Pe"', add
label define geo2_mx2010_lbl 020070 `"Pinotepa de Don Luis"', add
label define geo2_mx2010_lbl 020071 `"Pluma Hidalgo"', add
label define geo2_mx2010_lbl 020072 `"San José del Progreso"', add
label define geo2_mx2010_lbl 020073 `"Putla Villa de Guerrero"', add
label define geo2_mx2010_lbl 020074 `"Santa Catarina Quioquitani"', add
label define geo2_mx2010_lbl 020075 `"Reforma de Pineda"', add
label define geo2_mx2010_lbl 020076 `"La Reforma"', add
label define geo2_mx2010_lbl 020077 `"Reyes Etla"', add
label define geo2_mx2010_lbl 020078 `"Rojas de Cuauhtémoc"', add
label define geo2_mx2010_lbl 020079 `"Salina Cruz"', add
label define geo2_mx2010_lbl 020080 `"San Agustín Amatengo"', add
label define geo2_mx2010_lbl 020081 `"San Agustín Atenango"', add
label define geo2_mx2010_lbl 020082 `"San Agustín Chayuco"', add
label define geo2_mx2010_lbl 020083 `"San Agustín de las Juntas"', add
label define geo2_mx2010_lbl 020084 `"San Agustín Etla"', add
label define geo2_mx2010_lbl 020085 `"San Agustín Loxicha"', add
label define geo2_mx2010_lbl 020086 `"San Agustín Tlacotepec"', add
label define geo2_mx2010_lbl 020087 `"San Agustín Yatareni"', add
label define geo2_mx2010_lbl 020088 `"San Andrés Cabecera Nueva"', add
label define geo2_mx2010_lbl 020089 `"San Andrés Dinicuiti"', add
label define geo2_mx2010_lbl 020090 `"San Andrés Huaxpaltepec"', add
label define geo2_mx2010_lbl 020091 `"San Andrés Huayápam"', add
label define geo2_mx2010_lbl 020092 `"San Andrés Ixtlahuaca"', add
label define geo2_mx2010_lbl 020093 `"San Andrés Lagunas"', add
label define geo2_mx2010_lbl 020094 `"San Andrés Nuxiño"', add
label define geo2_mx2010_lbl 020095 `"San Andrés Paxtlán"', add
label define geo2_mx2010_lbl 020096 `"San Andrés Sinaxtla"', add
label define geo2_mx2010_lbl 020097 `"San Andrés Solaga"', add
label define geo2_mx2010_lbl 020098 `"San Andrés Teotilálpam"', add
label define geo2_mx2010_lbl 020099 `"San Andrés Tepetlapa"', add
label define geo2_mx2010_lbl 020100 `"San Andrés Yaá"', add
label define geo2_mx2010_lbl 020101 `"San Andrés Zabache"', add
label define geo2_mx2010_lbl 020102 `"San Andrés Zautla"', add
label define geo2_mx2010_lbl 020103 `"San Antonino Castillo Velasco"', add
label define geo2_mx2010_lbl 020104 `"San Antonino el Alto"', add
label define geo2_mx2010_lbl 020105 `"San Antonino Monte Verde"', add
label define geo2_mx2010_lbl 020106 `"San Antonio Acutla"', add
label define geo2_mx2010_lbl 020107 `"San Antonio de la Cal"', add
label define geo2_mx2010_lbl 020108 `"San Antonio Huitepec"', add
label define geo2_mx2010_lbl 020109 `"San Antonio Nanahuatípam"', add
label define geo2_mx2010_lbl 020110 `"San Antonio Sinicahua"', add
label define geo2_mx2010_lbl 020111 `"San Antonio Tepetlapa"', add
label define geo2_mx2010_lbl 020112 `"San Baltazar Chichicápam"', add
label define geo2_mx2010_lbl 020113 `"San Baltazar Loxicha"', add
label define geo2_mx2010_lbl 020114 `"San Baltazar Yatzachi el Bajo"', add
label define geo2_mx2010_lbl 020115 `"San Bartolo Coyotepec"', add
label define geo2_mx2010_lbl 020116 `"San Bartolomé Ayautla"', add
label define geo2_mx2010_lbl 020117 `"San Bartolomé Loxicha"', add
label define geo2_mx2010_lbl 020118 `"San Bartolomé Quialana"', add
label define geo2_mx2010_lbl 020119 `"San Bartolomé Yucuañe"', add
label define geo2_mx2010_lbl 020120 `"San Bartolomé Zoogocho"', add
label define geo2_mx2010_lbl 020121 `"San Bartolo Soyaltepec"', add
label define geo2_mx2010_lbl 020122 `"San Bartolo Yautepec"', add
label define geo2_mx2010_lbl 020123 `"San Bernardo Mixtepec"', add
label define geo2_mx2010_lbl 020124 `"San Blas Atempa"', add
label define geo2_mx2010_lbl 020125 `"San Carlos Yautepec"', add
label define geo2_mx2010_lbl 020126 `"San Cristóbal Amatlán"', add
label define geo2_mx2010_lbl 020127 `"San Cristóbal Amoltepec"', add
label define geo2_mx2010_lbl 020128 `"San Cristóbal Lachirioag"', add
label define geo2_mx2010_lbl 020129 `"San Cristóbal Suchixtlahuaca"', add
label define geo2_mx2010_lbl 020130 `"San Dionisio del Mar"', add
label define geo2_mx2010_lbl 020131 `"San Dionisio Ocotepec"', add
label define geo2_mx2010_lbl 020132 `"San Dionisio Ocotlán"', add
label define geo2_mx2010_lbl 020133 `"San Esteban Atatlahuca"', add
label define geo2_mx2010_lbl 020134 `"San Felipe Jalapa de Díaz"', add
label define geo2_mx2010_lbl 020135 `"San Felipe Tejalápam"', add
label define geo2_mx2010_lbl 020136 `"San Felipe Usila"', add
label define geo2_mx2010_lbl 020137 `"San Francisco Cahuacuá"', add
label define geo2_mx2010_lbl 020138 `"San Francisco Cajonos"', add
label define geo2_mx2010_lbl 020139 `"San Francisco Chapulapa"', add
label define geo2_mx2010_lbl 020140 `"San Francisco Chindúa"', add
label define geo2_mx2010_lbl 020141 `"San Francisco del Mar"', add
label define geo2_mx2010_lbl 020142 `"San Francisco Huehuetlán"', add
label define geo2_mx2010_lbl 020143 `"San Francisco Ixhuatán"', add
label define geo2_mx2010_lbl 020144 `"San Francisco Jaltepetongo"', add
label define geo2_mx2010_lbl 020145 `"San Francisco Lachigoló"', add
label define geo2_mx2010_lbl 020146 `"San Francisco Logueche"', add
label define geo2_mx2010_lbl 020147 `"San Francisco Nuxaño"', add
label define geo2_mx2010_lbl 020148 `"San Francisco Ozolotepec"', add
label define geo2_mx2010_lbl 020149 `"San Francisco Sola"', add
label define geo2_mx2010_lbl 020150 `"San Francisco Telixtlahuaca"', add
label define geo2_mx2010_lbl 020151 `"San Francisco Teopan"', add
label define geo2_mx2010_lbl 020152 `"San Francisco Tlapancingo"', add
label define geo2_mx2010_lbl 020153 `"San Gabriel Mixtepec"', add
label define geo2_mx2010_lbl 020154 `"San Ildefonso Amatlán"', add
label define geo2_mx2010_lbl 020155 `"San Ildefonso Sola"', add
label define geo2_mx2010_lbl 020156 `"San Ildefonso Villa Alta"', add
label define geo2_mx2010_lbl 020157 `"San Jacinto Amilpas"', add
label define geo2_mx2010_lbl 020158 `"San Jacinto Tlacotepec"', add
label define geo2_mx2010_lbl 020159 `"San Jerónimo Coatlán"', add
label define geo2_mx2010_lbl 020160 `"San Jerónimo Silacayoapilla"', add
label define geo2_mx2010_lbl 020161 `"San Jerónimo Sosola"', add
label define geo2_mx2010_lbl 020162 `"San Jerónimo Taviche"', add
label define geo2_mx2010_lbl 020163 `"San Jerónimo Tecóatl"', add
label define geo2_mx2010_lbl 020164 `"San Jorge Nuchita"', add
label define geo2_mx2010_lbl 020165 `"San José Ayuquila"', add
label define geo2_mx2010_lbl 020166 `"San José Chiltepec"', add
label define geo2_mx2010_lbl 020167 `"San José del Peñasco"', add
label define geo2_mx2010_lbl 020168 `"San José Estancia Grande"', add
label define geo2_mx2010_lbl 020169 `"San José Independencia"', add
label define geo2_mx2010_lbl 020170 `"San José Lachiguiri"', add
label define geo2_mx2010_lbl 020171 `"San José Tenango"', add
label define geo2_mx2010_lbl 020172 `"San Juan Achiutla"', add
label define geo2_mx2010_lbl 020173 `"San Juan Atepec"', add
label define geo2_mx2010_lbl 020174 `"Ánimas Trujano"', add
label define geo2_mx2010_lbl 020175 `"San Juan Bautista Atatlahuca"', add
label define geo2_mx2010_lbl 020176 `"San Juan Bautista Coixtlahuaca"', add
label define geo2_mx2010_lbl 020177 `"San Juan Bautista Cuicatlán"', add
label define geo2_mx2010_lbl 020178 `"San Juan Bautista Guelache"', add
label define geo2_mx2010_lbl 020179 `"San Juan Bautista Jayacatlán"', add
label define geo2_mx2010_lbl 020180 `"San Juan Bautista Lo de Soto"', add
label define geo2_mx2010_lbl 020181 `"San Juan Bautista Suchitepec"', add
label define geo2_mx2010_lbl 020182 `"San Juan Bautista Tlacoatzintepec"', add
label define geo2_mx2010_lbl 020183 `"San Juan Bautista Tlachichilco"', add
label define geo2_mx2010_lbl 020184 `"San Juan Bautista Tuxtepec"', add
label define geo2_mx2010_lbl 020185 `"San Juan Cacahuatepec"', add
label define geo2_mx2010_lbl 020186 `"San Juan Cieneguilla"', add
label define geo2_mx2010_lbl 020187 `"San Juan Coatzóspam"', add
label define geo2_mx2010_lbl 020188 `"San Juan Colorado"', add
label define geo2_mx2010_lbl 020189 `"San Juan Comaltepec"', add
label define geo2_mx2010_lbl 020190 `"San Juan Cotzocón"', add
label define geo2_mx2010_lbl 020191 `"San Juan Chicomezúchil"', add
label define geo2_mx2010_lbl 020192 `"San Juan Chilateca"', add
label define geo2_mx2010_lbl 020193 `"San Juan del Estado"', add
label define geo2_mx2010_lbl 020194 `"San Juan del Río"', add
label define geo2_mx2010_lbl 020195 `"San Juan Diuxi"', add
label define geo2_mx2010_lbl 020196 `"San Juan Evangelista Analco"', add
label define geo2_mx2010_lbl 020197 `"San Juan Guelavía"', add
label define geo2_mx2010_lbl 020198 `"San Juan Guichicovi"', add
label define geo2_mx2010_lbl 020199 `"San Juan Ihualtepec"', add
label define geo2_mx2010_lbl 020200 `"San Juan Juquila Mixes"', add
label define geo2_mx2010_lbl 020201 `"San Juan Juquila Vijanos"', add
label define geo2_mx2010_lbl 020202 `"San Juan Lachao"', add
label define geo2_mx2010_lbl 020203 `"San Juan Lachigalla"', add
label define geo2_mx2010_lbl 020204 `"San Juan Lajarcia"', add
label define geo2_mx2010_lbl 020205 `"San Juan Lalana"', add
label define geo2_mx2010_lbl 020206 `"San Juan de los Cués"', add
label define geo2_mx2010_lbl 020207 `"San Juan Mazatlán"', add
label define geo2_mx2010_lbl 020208 `"San Juan Mixtepec - Dto. 08"', add
label define geo2_mx2010_lbl 020209 `"San Juan Mixtepec - Dto. 26"', add
label define geo2_mx2010_lbl 020210 `"San Juan Ñumí"', add
label define geo2_mx2010_lbl 020211 `"San Juan Ozolotepec"', add
label define geo2_mx2010_lbl 020212 `"San Juan Petlapa"', add
label define geo2_mx2010_lbl 020213 `"San Juan Quiahije"', add
label define geo2_mx2010_lbl 020214 `"San Juan Quiotepec"', add
label define geo2_mx2010_lbl 020215 `"San Juan Sayultepec"', add
label define geo2_mx2010_lbl 020216 `"San Juan Tabaá"', add
label define geo2_mx2010_lbl 020217 `"San Juan Tamazola"', add
label define geo2_mx2010_lbl 020218 `"San Juan Teita"', add
label define geo2_mx2010_lbl 020219 `"San Juan Teitipac"', add
label define geo2_mx2010_lbl 020220 `"San Juan Tepeuxila"', add
label define geo2_mx2010_lbl 020221 `"San Juan Teposcolula"', add
label define geo2_mx2010_lbl 020222 `"San Juan Yaeé"', add
label define geo2_mx2010_lbl 020223 `"San Juan Yatzona"', add
label define geo2_mx2010_lbl 020224 `"San Juan Yucuita"', add
label define geo2_mx2010_lbl 020225 `"San Lorenzo"', add
label define geo2_mx2010_lbl 020226 `"San Lorenzo Albarradas"', add
label define geo2_mx2010_lbl 020227 `"San Lorenzo Cacaotepec"', add
label define geo2_mx2010_lbl 020228 `"San Lorenzo Cuaunecuiltitla"', add
label define geo2_mx2010_lbl 020229 `"San Lorenzo Texmelúcan"', add
label define geo2_mx2010_lbl 020230 `"San Lorenzo Victoria"', add
label define geo2_mx2010_lbl 020231 `"San Lucas Camotlán"', add
label define geo2_mx2010_lbl 020232 `"San Lucas Ojitlán"', add
label define geo2_mx2010_lbl 020233 `"San Lucas Quiaviní"', add
label define geo2_mx2010_lbl 020234 `"San Lucas Zoquiápam"', add
label define geo2_mx2010_lbl 020235 `"San Luis Amatlán"', add
label define geo2_mx2010_lbl 020236 `"San Marcial Ozolotepec"', add
label define geo2_mx2010_lbl 020237 `"San Marcos Arteaga"', add
label define geo2_mx2010_lbl 020238 `"San Martín de los Cansecos"', add
label define geo2_mx2010_lbl 020239 `"San Martín Huamelúlpam"', add
label define geo2_mx2010_lbl 020240 `"San Martín Itunyoso"', add
label define geo2_mx2010_lbl 020241 `"San Martín Lachilá"', add
label define geo2_mx2010_lbl 020242 `"San Martín Peras"', add
label define geo2_mx2010_lbl 020243 `"San Martín Tilcajete"', add
label define geo2_mx2010_lbl 020244 `"San Martín Toxpalan"', add
label define geo2_mx2010_lbl 020245 `"San Martín Zacatepec"', add
label define geo2_mx2010_lbl 020246 `"San Mateo Cajonos"', add
label define geo2_mx2010_lbl 020247 `"Capulálpam de Méndez"', add
label define geo2_mx2010_lbl 020248 `"San Mateo del Mar"', add
label define geo2_mx2010_lbl 020249 `"San Mateo Yoloxochitlán"', add
label define geo2_mx2010_lbl 020250 `"San Mateo Etlatongo"', add
label define geo2_mx2010_lbl 020251 `"San Mateo Nejápam"', add
label define geo2_mx2010_lbl 020252 `"San Mateo Peñasco"', add
label define geo2_mx2010_lbl 020253 `"San Mateo Piñas"', add
label define geo2_mx2010_lbl 020254 `"San Mateo Río Hondo"', add
label define geo2_mx2010_lbl 020255 `"San Mateo Sindihui"', add
label define geo2_mx2010_lbl 020256 `"San Mateo Tlapiltepec"', add
label define geo2_mx2010_lbl 020257 `"San Melchor Betaza"', add
label define geo2_mx2010_lbl 020258 `"San Miguel Achiutla"', add
label define geo2_mx2010_lbl 020259 `"San Miguel Ahuehuetitlán"', add
label define geo2_mx2010_lbl 020260 `"San Miguel Aloápam"', add
label define geo2_mx2010_lbl 020261 `"San Miguel Amatitlán"', add
label define geo2_mx2010_lbl 020262 `"San Miguel Amatlán"', add
label define geo2_mx2010_lbl 020263 `"San Miguel Coatlán"', add
label define geo2_mx2010_lbl 020264 `"San Miguel Chicahua"', add
label define geo2_mx2010_lbl 020265 `"San Miguel Chimalapa"', add
label define geo2_mx2010_lbl 020266 `"San Miguel del Puerto"', add
label define geo2_mx2010_lbl 020267 `"San Miguel del Río"', add
label define geo2_mx2010_lbl 020268 `"San Miguel Ejutla"', add
label define geo2_mx2010_lbl 020269 `"San Miguel el Grande"', add
label define geo2_mx2010_lbl 020270 `"San Miguel Huautla"', add
label define geo2_mx2010_lbl 020271 `"San Miguel Mixtepec"', add
label define geo2_mx2010_lbl 020272 `"San Miguel Panixtlahuaca"', add
label define geo2_mx2010_lbl 020273 `"San Miguel Peras"', add
label define geo2_mx2010_lbl 020274 `"San Miguel Piedras"', add
label define geo2_mx2010_lbl 020275 `"San Miguel Quetzaltepec"', add
label define geo2_mx2010_lbl 020276 `"San Miguel Santa Flor"', add
label define geo2_mx2010_lbl 020277 `"Villa Sola de Vega"', add
label define geo2_mx2010_lbl 020278 `"San Miguel Soyaltepec"', add
label define geo2_mx2010_lbl 020279 `"San Miguel Suchixtepec"', add
label define geo2_mx2010_lbl 020280 `"Villa Talea de Castro"', add
label define geo2_mx2010_lbl 020281 `"San Miguel Tecomatlán"', add
label define geo2_mx2010_lbl 020282 `"San Miguel Tenango"', add
label define geo2_mx2010_lbl 020283 `"San Miguel Tequixtepec"', add
label define geo2_mx2010_lbl 020284 `"San Miguel Tilquiápam"', add
label define geo2_mx2010_lbl 020285 `"San Miguel Tlacamama"', add
label define geo2_mx2010_lbl 020286 `"San Miguel Tlacotepec"', add
label define geo2_mx2010_lbl 020287 `"San Miguel Tulancingo"', add
label define geo2_mx2010_lbl 020288 `"San Miguel Yotao"', add
label define geo2_mx2010_lbl 020289 `"San Nicolás"', add
label define geo2_mx2010_lbl 020290 `"San Nicolás Hidalgo"', add
label define geo2_mx2010_lbl 020291 `"San Pablo Coatlán"', add
label define geo2_mx2010_lbl 020292 `"San Pablo Cuatro Venados"', add
label define geo2_mx2010_lbl 020293 `"San Pablo Etla"', add
label define geo2_mx2010_lbl 020294 `"San Pablo Huitzo"', add
label define geo2_mx2010_lbl 020295 `"San Pablo Huixtepec"', add
label define geo2_mx2010_lbl 020296 `"San Pablo Macuiltianguis"', add
label define geo2_mx2010_lbl 020297 `"San Pablo Tijaltepec"', add
label define geo2_mx2010_lbl 020298 `"San Pablo Villa de Mitla"', add
label define geo2_mx2010_lbl 020299 `"San Pablo Yaganiza"', add
label define geo2_mx2010_lbl 020300 `"San Pedro Amuzgos"', add
label define geo2_mx2010_lbl 020301 `"San Pedro Apóstol"', add
label define geo2_mx2010_lbl 020302 `"San Pedro Atoyac"', add
label define geo2_mx2010_lbl 020303 `"San Pedro Cajonos"', add
label define geo2_mx2010_lbl 020304 `"San Pedro Coxcaltepec Cántaros"', add
label define geo2_mx2010_lbl 020305 `"San Pedro Comitancillo"', add
label define geo2_mx2010_lbl 020306 `"San Pedro el Alto"', add
label define geo2_mx2010_lbl 020307 `"San Pedro Huamelula"', add
label define geo2_mx2010_lbl 020308 `"San Pedro Huilotepec"', add
label define geo2_mx2010_lbl 020309 `"San Pedro Ixcatlán"', add
label define geo2_mx2010_lbl 020310 `"San Pedro Ixtlahuaca"', add
label define geo2_mx2010_lbl 020311 `"San Pedro Jaltepetongo"', add
label define geo2_mx2010_lbl 020312 `"San Pedro Jicayán"', add
label define geo2_mx2010_lbl 020313 `"San Pedro Jocotipac"', add
label define geo2_mx2010_lbl 020314 `"San Pedro Juchatengo"', add
label define geo2_mx2010_lbl 020315 `"San Pedro Mártir"', add
label define geo2_mx2010_lbl 020316 `"San Pedro Mártir Quiechapa"', add
label define geo2_mx2010_lbl 020317 `"San Pedro Mártir Yucuxaco"', add
label define geo2_mx2010_lbl 020318 `"San Pedro Mixtepec - Dto. 22"', add
label define geo2_mx2010_lbl 020319 `"San Pedro Mixtepec - Dto. 26"', add
label define geo2_mx2010_lbl 020320 `"San Pedro Molinos"', add
label define geo2_mx2010_lbl 020321 `"San Pedro Nopala"', add
label define geo2_mx2010_lbl 020322 `"San Pedro Ocopetatillo"', add
label define geo2_mx2010_lbl 020323 `"San Pedro Ocotepec"', add
label define geo2_mx2010_lbl 020324 `"San Pedro Pochutla"', add
label define geo2_mx2010_lbl 020325 `"San Pedro Quiatoni"', add
label define geo2_mx2010_lbl 020326 `"San Pedro Sochiápam"', add
label define geo2_mx2010_lbl 020327 `"San Pedro Tapanatepec"', add
label define geo2_mx2010_lbl 020328 `"San Pedro Taviche"', add
label define geo2_mx2010_lbl 020329 `"San Pedro Teozacoalco"', add
label define geo2_mx2010_lbl 020330 `"San Pedro Teutila"', add
label define geo2_mx2010_lbl 020331 `"San Pedro Tidaá"', add
label define geo2_mx2010_lbl 020332 `"San Pedro Topiltepec"', add
label define geo2_mx2010_lbl 020333 `"San Pedro Totolápam"', add
label define geo2_mx2010_lbl 020334 `"Villa de Tututepec de Melchor Ocampo"', add
label define geo2_mx2010_lbl 020335 `"San Pedro Yaneri"', add
label define geo2_mx2010_lbl 020336 `"San Pedro Yólox"', add
label define geo2_mx2010_lbl 020337 `"San Pedro y San Pablo Ayutla"', add
label define geo2_mx2010_lbl 020338 `"Villa de Etla"', add
label define geo2_mx2010_lbl 020339 `"San Pedro y San Pablo Teposcolula"', add
label define geo2_mx2010_lbl 020340 `"San Pedro y San Pablo Tequixtepec"', add
label define geo2_mx2010_lbl 020341 `"San Pedro Yucunama"', add
label define geo2_mx2010_lbl 020342 `"San Raymundo Jalpan"', add
label define geo2_mx2010_lbl 020343 `"San Sebastián Abasolo"', add
label define geo2_mx2010_lbl 020344 `"San Sebastián Coatlán"', add
label define geo2_mx2010_lbl 020345 `"San Sebastián Ixcapa"', add
label define geo2_mx2010_lbl 020346 `"San Sebastián Nicananduta"', add
label define geo2_mx2010_lbl 020347 `"San Sebastián Río Hondo"', add
label define geo2_mx2010_lbl 020348 `"San Sebastián Tecomaxtlahuaca"', add
label define geo2_mx2010_lbl 020349 `"San Sebastián Teitipac"', add
label define geo2_mx2010_lbl 020350 `"San Sebastián Tutla"', add
label define geo2_mx2010_lbl 020351 `"San Simón Almolongas"', add
label define geo2_mx2010_lbl 020352 `"San Simón Zahuatlán"', add
label define geo2_mx2010_lbl 020353 `"Santa Ana"', add
label define geo2_mx2010_lbl 020354 `"Santa Ana Ateixtlahuaca"', add
label define geo2_mx2010_lbl 020355 `"Santa Ana Cuauhtémoc"', add
label define geo2_mx2010_lbl 020356 `"Santa Ana del Valle"', add
label define geo2_mx2010_lbl 020357 `"Santa Ana Tavela"', add
label define geo2_mx2010_lbl 020358 `"Santa Ana Tlapacoyan"', add
label define geo2_mx2010_lbl 020359 `"Santa Ana Yareni"', add
label define geo2_mx2010_lbl 020360 `"Santa Ana Zegache"', add
label define geo2_mx2010_lbl 020361 `"Santa Catalina Quierí"', add
label define geo2_mx2010_lbl 020362 `"Santa Catarina Cuixtla"', add
label define geo2_mx2010_lbl 020363 `"Santa Catarina Ixtepeji"', add
label define geo2_mx2010_lbl 020364 `"Santa Catarina Juquila"', add
label define geo2_mx2010_lbl 020365 `"Santa Catarina Lachatao"', add
label define geo2_mx2010_lbl 020366 `"Santa Catarina Loxicha"', add
label define geo2_mx2010_lbl 020367 `"Santa Catarina Mechoacán"', add
label define geo2_mx2010_lbl 020368 `"Santa Catarina Minas"', add
label define geo2_mx2010_lbl 020369 `"Santa Catarina Quiané"', add
label define geo2_mx2010_lbl 020370 `"Santa Catarina Tayata"', add
label define geo2_mx2010_lbl 020371 `"Santa Catarina Ticuá"', add
label define geo2_mx2010_lbl 020372 `"Santa Catarina Yosonotú"', add
label define geo2_mx2010_lbl 020373 `"Santa Catarina Zapoquila"', add
label define geo2_mx2010_lbl 020374 `"Santa Cruz Acatepec"', add
label define geo2_mx2010_lbl 020375 `"Santa Cruz Amilpas"', add
label define geo2_mx2010_lbl 020376 `"Santa Cruz de Bravo"', add
label define geo2_mx2010_lbl 020377 `"Santa Cruz Itundujia"', add
label define geo2_mx2010_lbl 020378 `"Santa Cruz Mixtepec"', add
label define geo2_mx2010_lbl 020379 `"Santa Cruz Nundaco"', add
label define geo2_mx2010_lbl 020380 `"Santa Cruz Papalutla"', add
label define geo2_mx2010_lbl 020381 `"Santa Cruz Tacache de Mina"', add
label define geo2_mx2010_lbl 020382 `"Santa Cruz Tacahua"', add
label define geo2_mx2010_lbl 020383 `"Santa Cruz Tayata"', add
label define geo2_mx2010_lbl 020384 `"Santa Cruz Xitla"', add
label define geo2_mx2010_lbl 020385 `"Santa Cruz Xoxocotlán"', add
label define geo2_mx2010_lbl 020386 `"Santa Cruz Zenzontepec"', add
label define geo2_mx2010_lbl 020387 `"Santa Gertrudis"', add
label define geo2_mx2010_lbl 020388 `"Santa Inés del Monte"', add
label define geo2_mx2010_lbl 020389 `"Santa Inés Yatzeche"', add
label define geo2_mx2010_lbl 020390 `"Santa Lucía del Camino"', add
label define geo2_mx2010_lbl 020391 `"Santa Lucía Miahuatlán"', add
label define geo2_mx2010_lbl 020392 `"Santa Lucía Monteverde"', add
label define geo2_mx2010_lbl 020393 `"Santa Lucía Ocotlán"', add
label define geo2_mx2010_lbl 020394 `"Santa María Alotepec"', add
label define geo2_mx2010_lbl 020395 `"Santa María Apazco"', add
label define geo2_mx2010_lbl 020396 `"Santa María la Asunción"', add
label define geo2_mx2010_lbl 020397 `"Heroica Ciudad de Tlaxiaco"', add
label define geo2_mx2010_lbl 020398 `"Ayoquezco de Aldama"', add
label define geo2_mx2010_lbl 020399 `"Santa María Atzompa"', add
label define geo2_mx2010_lbl 020400 `"Santa María Camotlán"', add
label define geo2_mx2010_lbl 020401 `"Santa María Colotepec"', add
label define geo2_mx2010_lbl 020402 `"Santa María Cortijo"', add
label define geo2_mx2010_lbl 020403 `"Santa María Coyotepec"', add
label define geo2_mx2010_lbl 020404 `"Santa María Chachoápam"', add
label define geo2_mx2010_lbl 020405 `"Villa de Chilapa de Díaz"', add
label define geo2_mx2010_lbl 020406 `"Santa María Chilchotla"', add
label define geo2_mx2010_lbl 020407 `"Santa María Chimalapa"', add
label define geo2_mx2010_lbl 020408 `"Santa María del Rosario"', add
label define geo2_mx2010_lbl 020409 `"Santa María del Tule"', add
label define geo2_mx2010_lbl 020410 `"Santa María Ecatepec"', add
label define geo2_mx2010_lbl 020411 `"Santa María Guelacé"', add
label define geo2_mx2010_lbl 020412 `"Santa María Guienagati"', add
label define geo2_mx2010_lbl 020413 `"Santa María Huatulco"', add
label define geo2_mx2010_lbl 020414 `"Santa María Huazolotitlán"', add
label define geo2_mx2010_lbl 020415 `"Santa María Ipalapa"', add
label define geo2_mx2010_lbl 020416 `"Santa María Ixcatlán"', add
label define geo2_mx2010_lbl 020417 `"Santa María Jacatepec"', add
label define geo2_mx2010_lbl 020418 `"Santa María Jalapa del Marqués"', add
label define geo2_mx2010_lbl 020419 `"Santa María Jaltianguis"', add
label define geo2_mx2010_lbl 020420 `"Santa María Lachixío"', add
label define geo2_mx2010_lbl 020421 `"Santa María Mixtequilla"', add
label define geo2_mx2010_lbl 020422 `"Santa María Nativitas"', add
label define geo2_mx2010_lbl 020423 `"Santa María Nduayaco"', add
label define geo2_mx2010_lbl 020424 `"Santa María Ozolotepec"', add
label define geo2_mx2010_lbl 020425 `"Santa María Pápalo"', add
label define geo2_mx2010_lbl 020426 `"Santa María Peñoles"', add
label define geo2_mx2010_lbl 020427 `"Santa María Petapa"', add
label define geo2_mx2010_lbl 020428 `"Santa María Quiegolani"', add
label define geo2_mx2010_lbl 020429 `"Santa María Sola"', add
label define geo2_mx2010_lbl 020430 `"Santa María Tataltepec"', add
label define geo2_mx2010_lbl 020431 `"Santa María Tecomavaca"', add
label define geo2_mx2010_lbl 020432 `"Santa María Temaxcalapa"', add
label define geo2_mx2010_lbl 020433 `"Santa María Temaxcaltepec"', add
label define geo2_mx2010_lbl 020434 `"Santa María Teopoxco"', add
label define geo2_mx2010_lbl 020435 `"Santa María Tepantlali"', add
label define geo2_mx2010_lbl 020436 `"Santa María Texcatitlán"', add
label define geo2_mx2010_lbl 020437 `"Santa María Tlahuitoltepec"', add
label define geo2_mx2010_lbl 020438 `"Santa María Tlalixtac"', add
label define geo2_mx2010_lbl 020439 `"Santa María Tonameca"', add
label define geo2_mx2010_lbl 020440 `"Santa María Totolapilla"', add
label define geo2_mx2010_lbl 020441 `"Santa María Xadani"', add
label define geo2_mx2010_lbl 020442 `"Santa María Yalina"', add
label define geo2_mx2010_lbl 020443 `"Santa María Yavesía"', add
label define geo2_mx2010_lbl 020444 `"Santa María Yolotepec"', add
label define geo2_mx2010_lbl 020445 `"Santa María Yosoyúa"', add
label define geo2_mx2010_lbl 020446 `"Santa María Yucuhiti"', add
label define geo2_mx2010_lbl 020447 `"Santa María Zacatepec"', add
label define geo2_mx2010_lbl 020448 `"Santa María Zaniza"', add
label define geo2_mx2010_lbl 020449 `"Santa María Zoquitlán"', add
label define geo2_mx2010_lbl 020450 `"Santiago Amoltepec"', add
label define geo2_mx2010_lbl 020451 `"Santiago Apoala"', add
label define geo2_mx2010_lbl 020452 `"Santiago Apóstol"', add
label define geo2_mx2010_lbl 020453 `"Santiago Astata"', add
label define geo2_mx2010_lbl 020454 `"Santiago Atitlán"', add
label define geo2_mx2010_lbl 020455 `"Santiago Ayuquililla"', add
label define geo2_mx2010_lbl 020456 `"Santiago Cacaloxtepec"', add
label define geo2_mx2010_lbl 020457 `"Santiago Camotlán"', add
label define geo2_mx2010_lbl 020458 `"Santiago Comaltepec"', add
label define geo2_mx2010_lbl 020459 `"Santiago Chazumba"', add
label define geo2_mx2010_lbl 020460 `"Santiago Choápam"', add
label define geo2_mx2010_lbl 020461 `"Santiago del Río"', add
label define geo2_mx2010_lbl 020462 `"Santiago Huajolotitlán"', add
label define geo2_mx2010_lbl 020463 `"Santiago Huauclilla"', add
label define geo2_mx2010_lbl 020464 `"Santiago Ihuitlán Plumas"', add
label define geo2_mx2010_lbl 020465 `"Santiago Ixcuintepec"', add
label define geo2_mx2010_lbl 020466 `"Santiago Ixtayutla"', add
label define geo2_mx2010_lbl 020467 `"Santiago Jamiltepec"', add
label define geo2_mx2010_lbl 020468 `"Santiago Jocotepec"', add
label define geo2_mx2010_lbl 020469 `"Santiago Juxtlahuaca"', add
label define geo2_mx2010_lbl 020470 `"Santiago Lachiguiri"', add
label define geo2_mx2010_lbl 020471 `"Santiago Lalopa"', add
label define geo2_mx2010_lbl 020472 `"Santiago Laollaga"', add
label define geo2_mx2010_lbl 020473 `"Santiago Laxopa"', add
label define geo2_mx2010_lbl 020474 `"Santiago Llano Grande"', add
label define geo2_mx2010_lbl 020475 `"Santiago Matatlán"', add
label define geo2_mx2010_lbl 020476 `"Santiago Miltepec"', add
label define geo2_mx2010_lbl 020477 `"Santiago Minas"', add
label define geo2_mx2010_lbl 020478 `"Santiago Nacaltepec"', add
label define geo2_mx2010_lbl 020479 `"Santiago Nejapilla"', add
label define geo2_mx2010_lbl 020480 `"Santiago Nundiche"', add
label define geo2_mx2010_lbl 020481 `"Santiago Nuyoó"', add
label define geo2_mx2010_lbl 020482 `"Santiago Pinotepa Nacional"', add
label define geo2_mx2010_lbl 020483 `"Santiago Suchilquitongo"', add
label define geo2_mx2010_lbl 020484 `"Santiago Tamazola"', add
label define geo2_mx2010_lbl 020485 `"Santiago Tapextla"', add
label define geo2_mx2010_lbl 020486 `"Villa Tejúpam de la Unión"', add
label define geo2_mx2010_lbl 020487 `"Santiago Tenango"', add
label define geo2_mx2010_lbl 020488 `"Santiago Tepetlapa"', add
label define geo2_mx2010_lbl 020489 `"Santiago Tetepec"', add
label define geo2_mx2010_lbl 020490 `"Santiago Texcalcingo"', add
label define geo2_mx2010_lbl 020491 `"Santiago Textitlán"', add
label define geo2_mx2010_lbl 020492 `"Santiago Tilantongo"', add
label define geo2_mx2010_lbl 020493 `"Santiago Tillo"', add
label define geo2_mx2010_lbl 020494 `"Santiago Tlazoyaltepec"', add
label define geo2_mx2010_lbl 020495 `"Santiago Xanica"', add
label define geo2_mx2010_lbl 020496 `"Santiago Xiacuí"', add
label define geo2_mx2010_lbl 020497 `"Santiago Yaitepec"', add
label define geo2_mx2010_lbl 020498 `"Santiago Yaveo"', add
label define geo2_mx2010_lbl 020499 `"Santiago Yolomécatl"', add
label define geo2_mx2010_lbl 020500 `"Santiago Yosondúa"', add
label define geo2_mx2010_lbl 020501 `"Santiago Yucuyachi"', add
label define geo2_mx2010_lbl 020502 `"Santiago Zacatepec"', add
label define geo2_mx2010_lbl 020503 `"Santiago Zoochila"', add
label define geo2_mx2010_lbl 020504 `"Nuevo Zoquiápam"', add
label define geo2_mx2010_lbl 020505 `"Santo Domingo Ingenio"', add
label define geo2_mx2010_lbl 020506 `"Santo Domingo Albarradas"', add
label define geo2_mx2010_lbl 020507 `"Santo Domingo Armenta"', add
label define geo2_mx2010_lbl 020508 `"Santo Domingo Chihuitán"', add
label define geo2_mx2010_lbl 020509 `"Santo Domingo de Morelos"', add
label define geo2_mx2010_lbl 020510 `"Santo Domingo Ixcatlán"', add
label define geo2_mx2010_lbl 020511 `"Santo Domingo Nuxaá"', add
label define geo2_mx2010_lbl 020512 `"Santo Domingo Ozolotepec"', add
label define geo2_mx2010_lbl 020513 `"Santo Domingo Petapa"', add
label define geo2_mx2010_lbl 020514 `"Santo Domingo Roayaga"', add
label define geo2_mx2010_lbl 020515 `"Santo Domingo Tehuantepec"', add
label define geo2_mx2010_lbl 020516 `"Santo Domingo Teojomulco"', add
label define geo2_mx2010_lbl 020517 `"Santo Domingo Tepuxtepec"', add
label define geo2_mx2010_lbl 020518 `"Santo Domingo Tlatayápam"', add
label define geo2_mx2010_lbl 020519 `"Santo Domingo Tomaltepec"', add
label define geo2_mx2010_lbl 020520 `"Santo Domingo Tonalá"', add
label define geo2_mx2010_lbl 020521 `"Santo Domingo Tonaltepec"', add
label define geo2_mx2010_lbl 020522 `"Santo Domingo Xagacía"', add
label define geo2_mx2010_lbl 020523 `"Santo Domingo Yanhuitlán"', add
label define geo2_mx2010_lbl 020524 `"Santo Domingo Yodohino"', add
label define geo2_mx2010_lbl 020525 `"Santo Domingo Zanatepec"', add
label define geo2_mx2010_lbl 020526 `"Santos Reyes Nopala"', add
label define geo2_mx2010_lbl 020527 `"Santos Reyes Pápalo"', add
label define geo2_mx2010_lbl 020528 `"Santos Reyes Tepejillo"', add
label define geo2_mx2010_lbl 020529 `"Santos Reyes Yucuná"', add
label define geo2_mx2010_lbl 020530 `"Santo Tomás Jalieza"', add
label define geo2_mx2010_lbl 020531 `"Santo Tomás Mazaltepec"', add
label define geo2_mx2010_lbl 020532 `"Santo Tomás Ocotepec"', add
label define geo2_mx2010_lbl 020533 `"Santo Tomás Tamazulapan"', add
label define geo2_mx2010_lbl 020534 `"San Vicente Coatlán"', add
label define geo2_mx2010_lbl 020535 `"San Vicente Lachixío"', add
label define geo2_mx2010_lbl 020536 `"San Vicente Nuñú"', add
label define geo2_mx2010_lbl 020537 `"Silacayoápam"', add
label define geo2_mx2010_lbl 020538 `"Sitio de Xitlapehua"', add
label define geo2_mx2010_lbl 020539 `"Soledad Etla"', add
label define geo2_mx2010_lbl 020540 `"Villa de Tamazulápam del Progreso"', add
label define geo2_mx2010_lbl 020541 `"Tanetze de Zaragoza"', add
label define geo2_mx2010_lbl 020542 `"Taniche"', add
label define geo2_mx2010_lbl 020543 `"Tataltepec de Valdés"', add
label define geo2_mx2010_lbl 020544 `"Teococuilco de Marcos Pérez"', add
label define geo2_mx2010_lbl 020545 `"Teotitlán de Flores Magón"', add
label define geo2_mx2010_lbl 020546 `"Teotitlán del Valle"', add
label define geo2_mx2010_lbl 020547 `"Teotongo"', add
label define geo2_mx2010_lbl 020548 `"Tepelmeme Villa de Morelos"', add
label define geo2_mx2010_lbl 020549 `"Tezoatlán de Segura y Luna"', add
label define geo2_mx2010_lbl 020550 `"San Jerónimo Tlacochahuaya"', add
label define geo2_mx2010_lbl 020551 `"Tlacolula de Matamoros"', add
label define geo2_mx2010_lbl 020552 `"Tlacotepec Plumas"', add
label define geo2_mx2010_lbl 020553 `"Tlalixtac de Cabrera"', add
label define geo2_mx2010_lbl 020554 `"Totontepec Villa de Morelos"', add
label define geo2_mx2010_lbl 020555 `"Trinidad Zaachila"', add
label define geo2_mx2010_lbl 020556 `"La Trinidad Vista Hermosa"', add
label define geo2_mx2010_lbl 020557 `"Unión Hidalgo"', add
label define geo2_mx2010_lbl 020558 `"Valerio Trujano"', add
label define geo2_mx2010_lbl 020559 `"San Juan Bautista Valle Nacional"', add
label define geo2_mx2010_lbl 020560 `"Villa Díaz Ordaz"', add
label define geo2_mx2010_lbl 020561 `"Yaxe"', add
label define geo2_mx2010_lbl 020562 `"Magdalena Yodocono de Porfirio Díaz"', add
label define geo2_mx2010_lbl 020563 `"Yogana"', add
label define geo2_mx2010_lbl 020564 `"Yutanduchi de Guerrero"', add
label define geo2_mx2010_lbl 020565 `"Villa de Zaachila"', add
label define geo2_mx2010_lbl 020566 `"San Mateo Yucutindó"', add
label define geo2_mx2010_lbl 020567 `"Zapotitlán Lagunas"', add
label define geo2_mx2010_lbl 020568 `"Zapotitlán Palmas"', add
label define geo2_mx2010_lbl 020569 `"Santa Inés de Zaragoza"', add
label define geo2_mx2010_lbl 020570 `"Zimatlán de Álvarez"', add
label define geo2_mx2010_lbl 021001 `"Acajete"', add
label define geo2_mx2010_lbl 021002 `"Acateno"', add
label define geo2_mx2010_lbl 021003 `"Acatlán"', add
label define geo2_mx2010_lbl 021004 `"Acatzingo"', add
label define geo2_mx2010_lbl 021005 `"Acteopan"', add
label define geo2_mx2010_lbl 021006 `"Ahuacatlán"', add
label define geo2_mx2010_lbl 021007 `"Ahuatlán"', add
label define geo2_mx2010_lbl 021008 `"Ahuazotepec"', add
label define geo2_mx2010_lbl 021009 `"Ahuehuetitla"', add
label define geo2_mx2010_lbl 021010 `"Ajalpan"', add
label define geo2_mx2010_lbl 021011 `"Albino Zertuche"', add
label define geo2_mx2010_lbl 021012 `"Aljojuca"', add
label define geo2_mx2010_lbl 021013 `"Altepexi"', add
label define geo2_mx2010_lbl 021014 `"Amixtlán"', add
label define geo2_mx2010_lbl 021015 `"Amozoc"', add
label define geo2_mx2010_lbl 021016 `"Aquixtla"', add
label define geo2_mx2010_lbl 021017 `"Atempan"', add
label define geo2_mx2010_lbl 021018 `"Atexcal"', add
label define geo2_mx2010_lbl 021019 `"Atlixco"', add
label define geo2_mx2010_lbl 021020 `"Atoyatempan"', add
label define geo2_mx2010_lbl 021021 `"Atzala"', add
label define geo2_mx2010_lbl 021022 `"Atzitzihuacán"', add
label define geo2_mx2010_lbl 021023 `"Atzitzintla"', add
label define geo2_mx2010_lbl 021024 `"Axutla"', add
label define geo2_mx2010_lbl 021025 `"Ayotoxco de Guerrero"', add
label define geo2_mx2010_lbl 021026 `"Calpan"', add
label define geo2_mx2010_lbl 021027 `"Caltepec"', add
label define geo2_mx2010_lbl 021028 `"Camocuautla"', add
label define geo2_mx2010_lbl 021029 `"Caxhuacan"', add
label define geo2_mx2010_lbl 021030 `"Coatepec"', add
label define geo2_mx2010_lbl 021031 `"Coatzingo"', add
label define geo2_mx2010_lbl 021032 `"Cohetzala"', add
label define geo2_mx2010_lbl 021033 `"Cohuecan"', add
label define geo2_mx2010_lbl 021034 `"Coronango"', add
label define geo2_mx2010_lbl 021035 `"Coxcatlán"', add
label define geo2_mx2010_lbl 021036 `"Coyomeapan"', add
label define geo2_mx2010_lbl 021037 `"Coyotepec"', add
label define geo2_mx2010_lbl 021038 `"Cuapiaxtla de Madero"', add
label define geo2_mx2010_lbl 021039 `"Cuautempan"', add
label define geo2_mx2010_lbl 021040 `"Cuautinchán"', add
label define geo2_mx2010_lbl 021041 `"Cuautlancingo"', add
label define geo2_mx2010_lbl 021042 `"Cuayuca de Andrade"', add
label define geo2_mx2010_lbl 021043 `"Cuetzalan del Progreso"', add
label define geo2_mx2010_lbl 021044 `"Cuyoaco"', add
label define geo2_mx2010_lbl 021045 `"Chalchicomula de Sesma"', add
label define geo2_mx2010_lbl 021046 `"Chapulco"', add
label define geo2_mx2010_lbl 021047 `"Chiautla"', add
label define geo2_mx2010_lbl 021048 `"Chiautzingo"', add
label define geo2_mx2010_lbl 021049 `"Chiconcuautla"', add
label define geo2_mx2010_lbl 021050 `"Chichiquila"', add
label define geo2_mx2010_lbl 021051 `"Chietla"', add
label define geo2_mx2010_lbl 021052 `"Chigmecatitlán"', add
label define geo2_mx2010_lbl 021053 `"Chignahuapan"', add
label define geo2_mx2010_lbl 021054 `"Chignautla"', add
label define geo2_mx2010_lbl 021055 `"Chila"', add
label define geo2_mx2010_lbl 021056 `"Chila de la Sal"', add
label define geo2_mx2010_lbl 021057 `"Honey"', add
label define geo2_mx2010_lbl 021058 `"Chilchotla"', add
label define geo2_mx2010_lbl 021059 `"Chinantla"', add
label define geo2_mx2010_lbl 021060 `"Domingo Arenas"', add
label define geo2_mx2010_lbl 021061 `"Eloxochitlán"', add
label define geo2_mx2010_lbl 021062 `"Epatlán"', add
label define geo2_mx2010_lbl 021063 `"Esperanza"', add
label define geo2_mx2010_lbl 021064 `"Francisco Z. Mena"', add
label define geo2_mx2010_lbl 021065 `"General Felipe Ángeles"', add
label define geo2_mx2010_lbl 021066 `"Guadalupe"', add
label define geo2_mx2010_lbl 021067 `"Guadalupe Victoria"', add
label define geo2_mx2010_lbl 021068 `"Hermenegildo Galeana"', add
label define geo2_mx2010_lbl 021069 `"Huaquechula"', add
label define geo2_mx2010_lbl 021070 `"Huatlatlauca"', add
label define geo2_mx2010_lbl 021071 `"Huauchinango"', add
label define geo2_mx2010_lbl 021072 `"Huehuetla"', add
label define geo2_mx2010_lbl 021073 `"Huehuetlán el Chico"', add
label define geo2_mx2010_lbl 021074 `"Huejotzingo"', add
label define geo2_mx2010_lbl 021075 `"Hueyapan"', add
label define geo2_mx2010_lbl 021076 `"Hueytamalco"', add
label define geo2_mx2010_lbl 021077 `"Hueytlalpan"', add
label define geo2_mx2010_lbl 021078 `"Huitzilan de Serdán"', add
label define geo2_mx2010_lbl 021079 `"Huitziltepec"', add
label define geo2_mx2010_lbl 021080 `"Atlequizayan"', add
label define geo2_mx2010_lbl 021081 `"Ixcamilpa de Guerrero"', add
label define geo2_mx2010_lbl 021082 `"Ixcaquixtla"', add
label define geo2_mx2010_lbl 021083 `"Ixtacamaxtitlán"', add
label define geo2_mx2010_lbl 021084 `"Ixtepec"', add
label define geo2_mx2010_lbl 021085 `"Izúcar de Matamoros"', add
label define geo2_mx2010_lbl 021086 `"Jalpan"', add
label define geo2_mx2010_lbl 021087 `"Jolalpan"', add
label define geo2_mx2010_lbl 021088 `"Jonotla"', add
label define geo2_mx2010_lbl 021089 `"Jopala"', add
label define geo2_mx2010_lbl 021090 `"Juan C. Bonilla"', add
label define geo2_mx2010_lbl 021091 `"Juan Galindo"', add
label define geo2_mx2010_lbl 021092 `"Juan N. Méndez"', add
label define geo2_mx2010_lbl 021093 `"Lafragua"', add
label define geo2_mx2010_lbl 021094 `"Libres"', add
label define geo2_mx2010_lbl 021095 `"La Magdalena Tlatlauquitepec"', add
label define geo2_mx2010_lbl 021096 `"Mazapiltepec de Juárez"', add
label define geo2_mx2010_lbl 021097 `"Mixtla"', add
label define geo2_mx2010_lbl 021098 `"Molcaxac"', add
label define geo2_mx2010_lbl 021099 `"Cañada Morelos"', add
label define geo2_mx2010_lbl 021100 `"Naupan"', add
label define geo2_mx2010_lbl 021101 `"Nauzontla"', add
label define geo2_mx2010_lbl 021102 `"Nealtican"', add
label define geo2_mx2010_lbl 021103 `"Nicolás Bravo"', add
label define geo2_mx2010_lbl 021104 `"Nopalucan"', add
label define geo2_mx2010_lbl 021105 `"Ocotepec"', add
label define geo2_mx2010_lbl 021106 `"Ocoyucan"', add
label define geo2_mx2010_lbl 021107 `"Olintla"', add
label define geo2_mx2010_lbl 021108 `"Oriental"', add
label define geo2_mx2010_lbl 021109 `"Pahuatlán"', add
label define geo2_mx2010_lbl 021110 `"Palmar de Bravo"', add
label define geo2_mx2010_lbl 021111 `"Pantepec"', add
label define geo2_mx2010_lbl 021112 `"Petlalcingo"', add
label define geo2_mx2010_lbl 021113 `"Piaxtla"', add
label define geo2_mx2010_lbl 021114 `"Puebla"', add
label define geo2_mx2010_lbl 021115 `"Quecholac"', add
label define geo2_mx2010_lbl 021116 `"Quimixtlán"', add
label define geo2_mx2010_lbl 021117 `"Rafael Lara Grajales"', add
label define geo2_mx2010_lbl 021118 `"Los Reyes de Juárez"', add
label define geo2_mx2010_lbl 021119 `"San Andrés Cholula"', add
label define geo2_mx2010_lbl 021120 `"San Antonio Cañada"', add
label define geo2_mx2010_lbl 021121 `"San Diego la Mesa Tochimiltzingo"', add
label define geo2_mx2010_lbl 021122 `"San Felipe Teotlalcingo"', add
label define geo2_mx2010_lbl 021123 `"San Felipe Tepatlán"', add
label define geo2_mx2010_lbl 021124 `"San Gabriel Chilac"', add
label define geo2_mx2010_lbl 021125 `"San Gregorio Atzompa"', add
label define geo2_mx2010_lbl 021126 `"San Jerónimo Tecuanipan"', add
label define geo2_mx2010_lbl 021127 `"San Jerónimo Xayacatlán"', add
label define geo2_mx2010_lbl 021128 `"San José Chiapa"', add
label define geo2_mx2010_lbl 021129 `"San José Miahuatlán"', add
label define geo2_mx2010_lbl 021130 `"San Juan Atenco"', add
label define geo2_mx2010_lbl 021131 `"San Juan Atzompa"', add
label define geo2_mx2010_lbl 021132 `"San Martín Texmelucan"', add
label define geo2_mx2010_lbl 021133 `"San Martín Totoltepec"', add
label define geo2_mx2010_lbl 021134 `"San Matías Tlalancaleca"', add
label define geo2_mx2010_lbl 021135 `"San Miguel Ixitlán"', add
label define geo2_mx2010_lbl 021136 `"San Miguel Xoxtla"', add
label define geo2_mx2010_lbl 021137 `"San Nicolás Buenos Aires"', add
label define geo2_mx2010_lbl 021138 `"San Nicolás de los Ranchos"', add
label define geo2_mx2010_lbl 021139 `"San Pablo Anicano"', add
label define geo2_mx2010_lbl 021140 `"San Pedro Cholula"', add
label define geo2_mx2010_lbl 021141 `"San Pedro Yeloixtlahuaca"', add
label define geo2_mx2010_lbl 021142 `"San Salvador el Seco"', add
label define geo2_mx2010_lbl 021143 `"San Salvador el Verde"', add
label define geo2_mx2010_lbl 021144 `"San Salvador Huixcolotla"', add
label define geo2_mx2010_lbl 021145 `"San Sebastián Tlacotepec"', add
label define geo2_mx2010_lbl 021146 `"Santa Catarina Tlaltempan"', add
label define geo2_mx2010_lbl 021147 `"Santa Inés Ahuatempan"', add
label define geo2_mx2010_lbl 021148 `"Santa Isabel Cholula"', add
label define geo2_mx2010_lbl 021149 `"Santiago Miahuatlán"', add
label define geo2_mx2010_lbl 021150 `"Huehuetlán el Grande"', add
label define geo2_mx2010_lbl 021151 `"Santo Tomás Hueyotlipan"', add
label define geo2_mx2010_lbl 021152 `"Soltepec"', add
label define geo2_mx2010_lbl 021153 `"Tecali de Herrera"', add
label define geo2_mx2010_lbl 021154 `"Tecamachalco"', add
label define geo2_mx2010_lbl 021155 `"Tecomatlán"', add
label define geo2_mx2010_lbl 021156 `"Tehuacán"', add
label define geo2_mx2010_lbl 021157 `"Tehuitzingo"', add
label define geo2_mx2010_lbl 021158 `"Tenampulco"', add
label define geo2_mx2010_lbl 021159 `"Teopantlán"', add
label define geo2_mx2010_lbl 021160 `"Teotlalco"', add
label define geo2_mx2010_lbl 021161 `"Tepanco de López"', add
label define geo2_mx2010_lbl 021162 `"Tepango de Rodríguez"', add
label define geo2_mx2010_lbl 021163 `"Tepatlaxco de Hidalgo"', add
label define geo2_mx2010_lbl 021164 `"Tepeaca"', add
label define geo2_mx2010_lbl 021165 `"Tepemaxalco"', add
label define geo2_mx2010_lbl 021166 `"Tepeojuma"', add
label define geo2_mx2010_lbl 021167 `"Tepetzintla"', add
label define geo2_mx2010_lbl 021168 `"Tepexco"', add
label define geo2_mx2010_lbl 021169 `"Tepexi de Rodríguez"', add
label define geo2_mx2010_lbl 021170 `"Tepeyahualco"', add
label define geo2_mx2010_lbl 021171 `"Tepeyahualco de Cuauhtémoc"', add
label define geo2_mx2010_lbl 021172 `"Tetela de Ocampo"', add
label define geo2_mx2010_lbl 021173 `"Teteles de Avila Castillo"', add
label define geo2_mx2010_lbl 021174 `"Teziutlán"', add
label define geo2_mx2010_lbl 021175 `"Tianguismanalco"', add
label define geo2_mx2010_lbl 021176 `"Tilapa"', add
label define geo2_mx2010_lbl 021177 `"Tlacotepec de Benito Juárez"', add
label define geo2_mx2010_lbl 021178 `"Tlacuilotepec"', add
label define geo2_mx2010_lbl 021179 `"Tlachichuca"', add
label define geo2_mx2010_lbl 021180 `"Tlahuapan"', add
label define geo2_mx2010_lbl 021181 `"Tlaltenango"', add
label define geo2_mx2010_lbl 021182 `"Tlanepantla"', add
label define geo2_mx2010_lbl 021183 `"Tlaola"', add
label define geo2_mx2010_lbl 021184 `"Tlapacoya"', add
label define geo2_mx2010_lbl 021185 `"Tlapanalá"', add
label define geo2_mx2010_lbl 021186 `"Tlatlauquitepec"', add
label define geo2_mx2010_lbl 021187 `"Tlaxco"', add
label define geo2_mx2010_lbl 021188 `"Tochimilco"', add
label define geo2_mx2010_lbl 021189 `"Tochtepec"', add
label define geo2_mx2010_lbl 021190 `"Totoltepec de Guerrero"', add
label define geo2_mx2010_lbl 021191 `"Tulcingo"', add
label define geo2_mx2010_lbl 021192 `"Tuzamapan de Galeana"', add
label define geo2_mx2010_lbl 021193 `"Tzicatlacoyan"', add
label define geo2_mx2010_lbl 021194 `"Venustiano Carranza"', add
label define geo2_mx2010_lbl 021195 `"Vicente Guerrero"', add
label define geo2_mx2010_lbl 021196 `"Xayacatlán de Bravo"', add
label define geo2_mx2010_lbl 021197 `"Xicotepec"', add
label define geo2_mx2010_lbl 021198 `"Xicotlán"', add
label define geo2_mx2010_lbl 021199 `"Xiutetelco"', add
label define geo2_mx2010_lbl 021200 `"Xochiapulco"', add
label define geo2_mx2010_lbl 021201 `"Xochiltepec"', add
label define geo2_mx2010_lbl 021202 `"Xochitlán de Vicente Suárez"', add
label define geo2_mx2010_lbl 021203 `"Xochitlán Todos Santos"', add
label define geo2_mx2010_lbl 021204 `"Yaonáhuac"', add
label define geo2_mx2010_lbl 021205 `"Yehualtepec"', add
label define geo2_mx2010_lbl 021206 `"Zacapala"', add
label define geo2_mx2010_lbl 021207 `"Zacapoaxtla"', add
label define geo2_mx2010_lbl 021208 `"Zacatlán"', add
label define geo2_mx2010_lbl 021209 `"Zapotitlán"', add
label define geo2_mx2010_lbl 021210 `"Zapotitlán de Méndez"', add
label define geo2_mx2010_lbl 021211 `"Zaragoza"', add
label define geo2_mx2010_lbl 021212 `"Zautla"', add
label define geo2_mx2010_lbl 021213 `"Zihuateutla"', add
label define geo2_mx2010_lbl 021214 `"Zinacatepec"', add
label define geo2_mx2010_lbl 021215 `"Zongozotla"', add
label define geo2_mx2010_lbl 021216 `"Zoquiapan"', add
label define geo2_mx2010_lbl 021217 `"Zoquitlán"', add
label define geo2_mx2010_lbl 022001 `"Amealco de Bonfil"', add
label define geo2_mx2010_lbl 022002 `"Pinal de Amoles"', add
label define geo2_mx2010_lbl 022003 `"Arroyo Seco"', add
label define geo2_mx2010_lbl 022004 `"Cadereyta de Montes"', add
label define geo2_mx2010_lbl 022005 `"Colón"', add
label define geo2_mx2010_lbl 022006 `"Corregidora"', add
label define geo2_mx2010_lbl 022007 `"Ezequiel Montes"', add
label define geo2_mx2010_lbl 022008 `"Huimilpan"', add
label define geo2_mx2010_lbl 022009 `"Jalpan de Serra"', add
label define geo2_mx2010_lbl 022010 `"Landa de Matamoros"', add
label define geo2_mx2010_lbl 022011 `"El Marqués"', add
label define geo2_mx2010_lbl 022012 `"Pedro Escobedo"', add
label define geo2_mx2010_lbl 022013 `"Peñamiller"', add
label define geo2_mx2010_lbl 022014 `"Querétaro"', add
label define geo2_mx2010_lbl 022015 `"San Joaquín"', add
label define geo2_mx2010_lbl 022016 `"San Juan del Río"', add
label define geo2_mx2010_lbl 022017 `"Tequisquiapan"', add
label define geo2_mx2010_lbl 022018 `"Tolimán"', add
label define geo2_mx2010_lbl 023001 `"Cozumel"', add
label define geo2_mx2010_lbl 023002 `"Felipe Carrillo Puerto"', add
label define geo2_mx2010_lbl 023003 `"Isla Mujeres"', add
label define geo2_mx2010_lbl 023004 `"Othón P. Blanco"', add
label define geo2_mx2010_lbl 023005 `"Benito Juárez"', add
label define geo2_mx2010_lbl 023006 `"José María Morelos"', add
label define geo2_mx2010_lbl 023007 `"Lázaro Cárdenas"', add
label define geo2_mx2010_lbl 023008 `"Solidaridad"', add
label define geo2_mx2010_lbl 023009 `"Tulum"', add
label define geo2_mx2010_lbl 024001 `"Ahualulco"', add
label define geo2_mx2010_lbl 024002 `"Alaquines"', add
label define geo2_mx2010_lbl 024003 `"Aquismón"', add
label define geo2_mx2010_lbl 024004 `"Armadillo de los Infante"', add
label define geo2_mx2010_lbl 024005 `"Cárdenas"', add
label define geo2_mx2010_lbl 024006 `"Catorce"', add
label define geo2_mx2010_lbl 024007 `"Cedral"', add
label define geo2_mx2010_lbl 024008 `"Cerritos"', add
label define geo2_mx2010_lbl 024009 `"Cerro de San Pedro"', add
label define geo2_mx2010_lbl 024010 `"Ciudad del Maíz"', add
label define geo2_mx2010_lbl 024011 `"Ciudad Fernández"', add
label define geo2_mx2010_lbl 024012 `"Tancanhuitz"', add
label define geo2_mx2010_lbl 024013 `"Ciudad Valles"', add
label define geo2_mx2010_lbl 024014 `"Coxcatlán"', add
label define geo2_mx2010_lbl 024015 `"Charcas"', add
label define geo2_mx2010_lbl 024016 `"Ebano"', add
label define geo2_mx2010_lbl 024017 `"Guadalcázar"', add
label define geo2_mx2010_lbl 024018 `"Huehuetlán"', add
label define geo2_mx2010_lbl 024019 `"Lagunillas"', add
label define geo2_mx2010_lbl 024020 `"Matehuala"', add
label define geo2_mx2010_lbl 024021 `"Mexquitic de Carmona"', add
label define geo2_mx2010_lbl 024022 `"Moctezuma"', add
label define geo2_mx2010_lbl 024023 `"Rayón"', add
label define geo2_mx2010_lbl 024024 `"Rioverde"', add
label define geo2_mx2010_lbl 024025 `"Salinas"', add
label define geo2_mx2010_lbl 024026 `"San Antonio"', add
label define geo2_mx2010_lbl 024027 `"San Ciro de Acosta"', add
label define geo2_mx2010_lbl 024028 `"San Luis Potosí"', add
label define geo2_mx2010_lbl 024029 `"San Martín Chalchicuautla"', add
label define geo2_mx2010_lbl 024030 `"San Nicolás Tolentino"', add
label define geo2_mx2010_lbl 024031 `"Santa Catarina"', add
label define geo2_mx2010_lbl 024032 `"Santa María del Río"', add
label define geo2_mx2010_lbl 024033 `"Santo Domingo"', add
label define geo2_mx2010_lbl 024034 `"San Vicente Tancuayalab"', add
label define geo2_mx2010_lbl 024035 `"Soledad de Graciano Sánchez"', add
label define geo2_mx2010_lbl 024036 `"Tamasopo"', add
label define geo2_mx2010_lbl 024037 `"Tamazunchale"', add
label define geo2_mx2010_lbl 024038 `"Tampacán"', add
label define geo2_mx2010_lbl 024039 `"Tampamolón Corona"', add
label define geo2_mx2010_lbl 024040 `"Tamuín"', add
label define geo2_mx2010_lbl 024041 `"Tanlajás"', add
label define geo2_mx2010_lbl 024042 `"Tanquián de Escobedo"', add
label define geo2_mx2010_lbl 024043 `"Tierra Nueva"', add
label define geo2_mx2010_lbl 024044 `"Vanegas"', add
label define geo2_mx2010_lbl 024045 `"Venado"', add
label define geo2_mx2010_lbl 024046 `"Villa de Arriaga"', add
label define geo2_mx2010_lbl 024047 `"Villa de Guadalupe"', add
label define geo2_mx2010_lbl 024048 `"Villa de la Paz"', add
label define geo2_mx2010_lbl 024049 `"Villa de Ramos"', add
label define geo2_mx2010_lbl 024050 `"Villa de Reyes"', add
label define geo2_mx2010_lbl 024051 `"Villa Hidalgo"', add
label define geo2_mx2010_lbl 024052 `"Villa Juárez"', add
label define geo2_mx2010_lbl 024053 `"Axtla de Terrazas"', add
label define geo2_mx2010_lbl 024054 `"Xilitla"', add
label define geo2_mx2010_lbl 024055 `"Zaragoza"', add
label define geo2_mx2010_lbl 024056 `"Villa de Arista"', add
label define geo2_mx2010_lbl 024057 `"Matlapa"', add
label define geo2_mx2010_lbl 024058 `"El Naranjo"', add
label define geo2_mx2010_lbl 025001 `"Ahome"', add
label define geo2_mx2010_lbl 025002 `"Angostura"', add
label define geo2_mx2010_lbl 025003 `"Badiraguato"', add
label define geo2_mx2010_lbl 025004 `"Concordia"', add
label define geo2_mx2010_lbl 025005 `"Cosalá"', add
label define geo2_mx2010_lbl 025006 `"Culiacán"', add
label define geo2_mx2010_lbl 025007 `"Choix"', add
label define geo2_mx2010_lbl 025008 `"Elota"', add
label define geo2_mx2010_lbl 025009 `"Escuinapa"', add
label define geo2_mx2010_lbl 025010 `"El Fuerte"', add
label define geo2_mx2010_lbl 025011 `"Guasave"', add
label define geo2_mx2010_lbl 025012 `"Mazatlán"', add
label define geo2_mx2010_lbl 025013 `"Mocorito"', add
label define geo2_mx2010_lbl 025014 `"Rosario"', add
label define geo2_mx2010_lbl 025015 `"Salvador Alvarado"', add
label define geo2_mx2010_lbl 025016 `"San Ignacio"', add
label define geo2_mx2010_lbl 025017 `"Sinaloa"', add
label define geo2_mx2010_lbl 025018 `"Navolato"', add
label define geo2_mx2010_lbl 026001 `"Aconchi"', add
label define geo2_mx2010_lbl 026002 `"Agua Prieta"', add
label define geo2_mx2010_lbl 026003 `"Alamos"', add
label define geo2_mx2010_lbl 026004 `"Altar"', add
label define geo2_mx2010_lbl 026005 `"Arivechi"', add
label define geo2_mx2010_lbl 026006 `"Arizpe"', add
label define geo2_mx2010_lbl 026007 `"Atil"', add
label define geo2_mx2010_lbl 026008 `"Bacadéhuachi"', add
label define geo2_mx2010_lbl 026009 `"Bacanora"', add
label define geo2_mx2010_lbl 026010 `"Bacerac"', add
label define geo2_mx2010_lbl 026011 `"Bacoachi"', add
label define geo2_mx2010_lbl 026012 `"Bácum"', add
label define geo2_mx2010_lbl 026013 `"Banámichi"', add
label define geo2_mx2010_lbl 026014 `"Baviácora"', add
label define geo2_mx2010_lbl 026015 `"Bavispe"', add
label define geo2_mx2010_lbl 026016 `"Benjamín Hill"', add
label define geo2_mx2010_lbl 026017 `"Caborca"', add
label define geo2_mx2010_lbl 026018 `"Cajeme"', add
label define geo2_mx2010_lbl 026019 `"Cananea"', add
label define geo2_mx2010_lbl 026020 `"Carbó"', add
label define geo2_mx2010_lbl 026021 `"La Colorada"', add
label define geo2_mx2010_lbl 026022 `"Cucurpe"', add
label define geo2_mx2010_lbl 026023 `"Cumpas"', add
label define geo2_mx2010_lbl 026024 `"Divisaderos"', add
label define geo2_mx2010_lbl 026025 `"Empalme"', add
label define geo2_mx2010_lbl 026026 `"Etchojoa"', add
label define geo2_mx2010_lbl 026027 `"Fronteras"', add
label define geo2_mx2010_lbl 026028 `"Granados"', add
label define geo2_mx2010_lbl 026029 `"Guaymas"', add
label define geo2_mx2010_lbl 026030 `"Hermosillo"', add
label define geo2_mx2010_lbl 026031 `"Huachinera"', add
label define geo2_mx2010_lbl 026032 `"Huásabas"', add
label define geo2_mx2010_lbl 026033 `"Huatabampo"', add
label define geo2_mx2010_lbl 026034 `"Huépac"', add
label define geo2_mx2010_lbl 026035 `"Imuris"', add
label define geo2_mx2010_lbl 026036 `"Magdalena"', add
label define geo2_mx2010_lbl 026037 `"Mazatán"', add
label define geo2_mx2010_lbl 026038 `"Moctezuma"', add
label define geo2_mx2010_lbl 026039 `"Naco"', add
label define geo2_mx2010_lbl 026040 `"Nácori Chico"', add
label define geo2_mx2010_lbl 026041 `"Nacozari de García"', add
label define geo2_mx2010_lbl 026042 `"Navojoa"', add
label define geo2_mx2010_lbl 026043 `"Nogales"', add
label define geo2_mx2010_lbl 026044 `"Onavas"', add
label define geo2_mx2010_lbl 026045 `"Opodepe"', add
label define geo2_mx2010_lbl 026046 `"Oquitoa"', add
label define geo2_mx2010_lbl 026047 `"Pitiquito"', add
label define geo2_mx2010_lbl 026048 `"Puerto Peñasco"', add
label define geo2_mx2010_lbl 026049 `"Quiriego"', add
label define geo2_mx2010_lbl 026050 `"Rayón"', add
label define geo2_mx2010_lbl 026051 `"Rosario"', add
label define geo2_mx2010_lbl 026052 `"Sahuaripa"', add
label define geo2_mx2010_lbl 026053 `"San Felipe de Jesús"', add
label define geo2_mx2010_lbl 026054 `"San Javier"', add
label define geo2_mx2010_lbl 026055 `"San Luis Río Colorado"', add
label define geo2_mx2010_lbl 026056 `"San Miguel de Horcasitas"', add
label define geo2_mx2010_lbl 026057 `"San Pedro de la Cueva"', add
label define geo2_mx2010_lbl 026058 `"Santa Ana"', add
label define geo2_mx2010_lbl 026059 `"Santa Cruz"', add
label define geo2_mx2010_lbl 026060 `"Sáric"', add
label define geo2_mx2010_lbl 026061 `"Soyopa"', add
label define geo2_mx2010_lbl 026062 `"Suaqui Grande"', add
label define geo2_mx2010_lbl 026063 `"Tepache"', add
label define geo2_mx2010_lbl 026064 `"Trincheras"', add
label define geo2_mx2010_lbl 026065 `"Tubutama"', add
label define geo2_mx2010_lbl 026066 `"Ures"', add
label define geo2_mx2010_lbl 026067 `"Villa Hidalgo"', add
label define geo2_mx2010_lbl 026068 `"Villa Pesqueira"', add
label define geo2_mx2010_lbl 026069 `"Yécora"', add
label define geo2_mx2010_lbl 026070 `"General Plutarco Elías Calles"', add
label define geo2_mx2010_lbl 026071 `"Benito Juárez"', add
label define geo2_mx2010_lbl 026072 `"San Ignacio Río Muerto"', add
label define geo2_mx2010_lbl 027001 `"Balancán"', add
label define geo2_mx2010_lbl 027002 `"Cárdenas"', add
label define geo2_mx2010_lbl 027003 `"Centla"', add
label define geo2_mx2010_lbl 027004 `"Centro"', add
label define geo2_mx2010_lbl 027005 `"Comalcalco"', add
label define geo2_mx2010_lbl 027006 `"Cunduacán"', add
label define geo2_mx2010_lbl 027007 `"Emiliano Zapata"', add
label define geo2_mx2010_lbl 027008 `"Huimanguillo"', add
label define geo2_mx2010_lbl 027009 `"Jalapa"', add
label define geo2_mx2010_lbl 027010 `"Jalpa de Méndez"', add
label define geo2_mx2010_lbl 027011 `"Jonuta"', add
label define geo2_mx2010_lbl 027012 `"Macuspana"', add
label define geo2_mx2010_lbl 027013 `"Nacajuca"', add
label define geo2_mx2010_lbl 027014 `"Paraíso"', add
label define geo2_mx2010_lbl 027015 `"Tacotalpa"', add
label define geo2_mx2010_lbl 027016 `"Teapa"', add
label define geo2_mx2010_lbl 027017 `"Tenosique"', add
label define geo2_mx2010_lbl 028001 `"Abasolo"', add
label define geo2_mx2010_lbl 028002 `"Aldama"', add
label define geo2_mx2010_lbl 028003 `"Altamira"', add
label define geo2_mx2010_lbl 028004 `"Antiguo Morelos"', add
label define geo2_mx2010_lbl 028005 `"Burgos"', add
label define geo2_mx2010_lbl 028006 `"Bustamante"', add
label define geo2_mx2010_lbl 028007 `"Camargo"', add
label define geo2_mx2010_lbl 028008 `"Casas"', add
label define geo2_mx2010_lbl 028009 `"Ciudad Madero"', add
label define geo2_mx2010_lbl 028010 `"Cruillas"', add
label define geo2_mx2010_lbl 028011 `"Gómez Farías"', add
label define geo2_mx2010_lbl 028012 `"González"', add
label define geo2_mx2010_lbl 028013 `"Güémez"', add
label define geo2_mx2010_lbl 028014 `"Guerrero"', add
label define geo2_mx2010_lbl 028015 `"Gustavo Díaz Ordaz"', add
label define geo2_mx2010_lbl 028016 `"Hidalgo"', add
label define geo2_mx2010_lbl 028017 `"Jaumave"', add
label define geo2_mx2010_lbl 028018 `"Jiménez"', add
label define geo2_mx2010_lbl 028019 `"Llera"', add
label define geo2_mx2010_lbl 028020 `"Mainero"', add
label define geo2_mx2010_lbl 028021 `"El Mante"', add
label define geo2_mx2010_lbl 028022 `"Matamoros"', add
label define geo2_mx2010_lbl 028023 `"Méndez"', add
label define geo2_mx2010_lbl 028024 `"Mier"', add
label define geo2_mx2010_lbl 028025 `"Miguel Alemán"', add
label define geo2_mx2010_lbl 028026 `"Miquihuana"', add
label define geo2_mx2010_lbl 028027 `"Nuevo Laredo"', add
label define geo2_mx2010_lbl 028028 `"Nuevo Morelos"', add
label define geo2_mx2010_lbl 028029 `"Ocampo"', add
label define geo2_mx2010_lbl 028030 `"Padilla"', add
label define geo2_mx2010_lbl 028031 `"Palmillas"', add
label define geo2_mx2010_lbl 028032 `"Reynosa"', add
label define geo2_mx2010_lbl 028033 `"Río Bravo"', add
label define geo2_mx2010_lbl 028034 `"San Carlos"', add
label define geo2_mx2010_lbl 028035 `"San Fernando"', add
label define geo2_mx2010_lbl 028036 `"San Nicolás"', add
label define geo2_mx2010_lbl 028037 `"Soto la Marina"', add
label define geo2_mx2010_lbl 028038 `"Tampico"', add
label define geo2_mx2010_lbl 028039 `"Tula"', add
label define geo2_mx2010_lbl 028040 `"Valle Hermoso"', add
label define geo2_mx2010_lbl 028041 `"Victoria"', add
label define geo2_mx2010_lbl 028042 `"Villagrán"', add
label define geo2_mx2010_lbl 028043 `"Xicoténcatl"', add
label define geo2_mx2010_lbl 029001 `"Amaxac de Guerrero"', add
label define geo2_mx2010_lbl 029002 `"Apetatitlán de Antonio Carvajal"', add
label define geo2_mx2010_lbl 029003 `"Atlangatepec"', add
label define geo2_mx2010_lbl 029004 `"Atltzayanca"', add
label define geo2_mx2010_lbl 029005 `"Apizaco"', add
label define geo2_mx2010_lbl 029006 `"Calpulalpan"', add
label define geo2_mx2010_lbl 029007 `"El Carmen Tequexquitla"', add
label define geo2_mx2010_lbl 029008 `"Cuapiaxtla"', add
label define geo2_mx2010_lbl 029009 `"Cuaxomulco"', add
label define geo2_mx2010_lbl 029010 `"Chiautempan"', add
label define geo2_mx2010_lbl 029011 `"Muñoz de Domingo Arenas"', add
label define geo2_mx2010_lbl 029012 `"Españita"', add
label define geo2_mx2010_lbl 029013 `"Huamantla"', add
label define geo2_mx2010_lbl 029014 `"Hueyotlipan"', add
label define geo2_mx2010_lbl 029015 `"Ixtacuixtla de Mariano Matamoros"', add
label define geo2_mx2010_lbl 029016 `"Ixtenco"', add
label define geo2_mx2010_lbl 029017 `"Mazatecochco de José María Morelos"', add
label define geo2_mx2010_lbl 029018 `"Contla de Juan Cuamatzi"', add
label define geo2_mx2010_lbl 029019 `"Tepetitla de Lardizábal"', add
label define geo2_mx2010_lbl 029020 `"Sanctórum de Lázaro Cárdenas"', add
label define geo2_mx2010_lbl 029021 `"Nanacamilpa de Mariano Arista"', add
label define geo2_mx2010_lbl 029022 `"Acuamanala de Miguel Hidalgo"', add
label define geo2_mx2010_lbl 029023 `"Natívitas"', add
label define geo2_mx2010_lbl 029024 `"Panotla"', add
label define geo2_mx2010_lbl 029025 `"San Pablo del Monte"', add
label define geo2_mx2010_lbl 029026 `"Santa Cruz Tlaxcala"', add
label define geo2_mx2010_lbl 029027 `"Tenancingo"', add
label define geo2_mx2010_lbl 029028 `"Teolocholco"', add
label define geo2_mx2010_lbl 029029 `"Tepeyanco"', add
label define geo2_mx2010_lbl 029030 `"Terrenate"', add
label define geo2_mx2010_lbl 029031 `"Tetla de la Solidaridad"', add
label define geo2_mx2010_lbl 029032 `"Tetlatlahuca"', add
label define geo2_mx2010_lbl 029033 `"Tlaxcala"', add
label define geo2_mx2010_lbl 029034 `"Tlaxco"', add
label define geo2_mx2010_lbl 029035 `"Tocatlán"', add
label define geo2_mx2010_lbl 029036 `"Totolac"', add
label define geo2_mx2010_lbl 029037 `"Ziltlaltépec de Trinidad Sánchez Santos"', add
label define geo2_mx2010_lbl 029038 `"Tzompantepec"', add
label define geo2_mx2010_lbl 029039 `"Xaloztoc"', add
label define geo2_mx2010_lbl 029040 `"Xaltocan"', add
label define geo2_mx2010_lbl 029041 `"Papalotla de Xicohténcatl"', add
label define geo2_mx2010_lbl 029042 `"Xicohtzinco"', add
label define geo2_mx2010_lbl 029043 `"Yauhquemehcan"', add
label define geo2_mx2010_lbl 029044 `"Zacatelco"', add
label define geo2_mx2010_lbl 029045 `"Benito Juárez"', add
label define geo2_mx2010_lbl 029046 `"Emiliano Zapata"', add
label define geo2_mx2010_lbl 029047 `"Lázaro Cárdenas"', add
label define geo2_mx2010_lbl 029048 `"La Magdalena Tlaltelulco"', add
label define geo2_mx2010_lbl 029049 `"San Damián Texóloc"', add
label define geo2_mx2010_lbl 029050 `"San Francisco Tetlanohcan"', add
label define geo2_mx2010_lbl 029051 `"San Jerónimo Zacualpan"', add
label define geo2_mx2010_lbl 029052 `"San José Teacalco"', add
label define geo2_mx2010_lbl 029053 `"San Juan Huactzinco"', add
label define geo2_mx2010_lbl 029054 `"San Lorenzo Axocomanitla"', add
label define geo2_mx2010_lbl 029055 `"San Lucas Tecopilco"', add
label define geo2_mx2010_lbl 029056 `"Santa Ana Nopalucan"', add
label define geo2_mx2010_lbl 029057 `"Santa Apolonia Teacalco"', add
label define geo2_mx2010_lbl 029058 `"Santa Catarina Ayometla"', add
label define geo2_mx2010_lbl 029059 `"Santa Cruz Quilehtla"', add
label define geo2_mx2010_lbl 029060 `"Santa Isabel Xiloxoxtla"', add
label define geo2_mx2010_lbl 030001 `"Acajete"', add
label define geo2_mx2010_lbl 030002 `"Acatlán"', add
label define geo2_mx2010_lbl 030003 `"Acayucan"', add
label define geo2_mx2010_lbl 030004 `"Actopan"', add
label define geo2_mx2010_lbl 030005 `"Acula"', add
label define geo2_mx2010_lbl 030006 `"Acultzingo"', add
label define geo2_mx2010_lbl 030007 `"Camarón de Tejeda"', add
label define geo2_mx2010_lbl 030008 `"Alpatláhuac"', add
label define geo2_mx2010_lbl 030009 `"Alto Lucero de Gutiérrez Barrios"', add
label define geo2_mx2010_lbl 030010 `"Altotonga"', add
label define geo2_mx2010_lbl 030011 `"Alvarado"', add
label define geo2_mx2010_lbl 030012 `"Amatitlán"', add
label define geo2_mx2010_lbl 030013 `"Naranjos Amatlán"', add
label define geo2_mx2010_lbl 030014 `"Amatlán de los Reyes"', add
label define geo2_mx2010_lbl 030015 `"Angel R. Cabada"', add
label define geo2_mx2010_lbl 030016 `"La Antigua"', add
label define geo2_mx2010_lbl 030017 `"Apazapan"', add
label define geo2_mx2010_lbl 030018 `"Aquila"', add
label define geo2_mx2010_lbl 030019 `"Astacinga"', add
label define geo2_mx2010_lbl 030020 `"Atlahuilco"', add
label define geo2_mx2010_lbl 030021 `"Atoyac"', add
label define geo2_mx2010_lbl 030022 `"Atzacan"', add
label define geo2_mx2010_lbl 030023 `"Atzalan"', add
label define geo2_mx2010_lbl 030024 `"Tlaltetela"', add
label define geo2_mx2010_lbl 030025 `"Ayahualulco"', add
label define geo2_mx2010_lbl 030026 `"Banderilla"', add
label define geo2_mx2010_lbl 030027 `"Benito Juárez"', add
label define geo2_mx2010_lbl 030028 `"Boca del Río"', add
label define geo2_mx2010_lbl 030029 `"Calcahualco"', add
label define geo2_mx2010_lbl 030030 `"Camerino Z. Mendoza"', add
label define geo2_mx2010_lbl 030031 `"Carrillo Puerto"', add
label define geo2_mx2010_lbl 030032 `"Catemaco"', add
label define geo2_mx2010_lbl 030033 `"Cazones de Herrera"', add
label define geo2_mx2010_lbl 030034 `"Cerro Azul"', add
label define geo2_mx2010_lbl 030035 `"Citlaltépetl"', add
label define geo2_mx2010_lbl 030036 `"Coacoatzintla"', add
label define geo2_mx2010_lbl 030037 `"Coahuitlán"', add
label define geo2_mx2010_lbl 030038 `"Coatepec"', add
label define geo2_mx2010_lbl 030039 `"Coatzacoalcos"', add
label define geo2_mx2010_lbl 030040 `"Coatzintla"', add
label define geo2_mx2010_lbl 030041 `"Coetzala"', add
label define geo2_mx2010_lbl 030042 `"Colipa"', add
label define geo2_mx2010_lbl 030043 `"Comapa"', add
label define geo2_mx2010_lbl 030044 `"Córdoba"', add
label define geo2_mx2010_lbl 030045 `"Cosamaloapan de Carpio"', add
label define geo2_mx2010_lbl 030046 `"Cosautlán de Carvajal"', add
label define geo2_mx2010_lbl 030047 `"Coscomatepec"', add
label define geo2_mx2010_lbl 030048 `"Cosoleacaque"', add
label define geo2_mx2010_lbl 030049 `"Cotaxtla"', add
label define geo2_mx2010_lbl 030050 `"Coxquihui"', add
label define geo2_mx2010_lbl 030051 `"Coyutla"', add
label define geo2_mx2010_lbl 030052 `"Cuichapa"', add
label define geo2_mx2010_lbl 030053 `"Cuitláhuac"', add
label define geo2_mx2010_lbl 030054 `"Chacaltianguis"', add
label define geo2_mx2010_lbl 030055 `"Chalma"', add
label define geo2_mx2010_lbl 030056 `"Chiconamel"', add
label define geo2_mx2010_lbl 030057 `"Chiconquiaco"', add
label define geo2_mx2010_lbl 030058 `"Chicontepec"', add
label define geo2_mx2010_lbl 030059 `"Chinameca"', add
label define geo2_mx2010_lbl 030060 `"Chinampa de Gorostiza"', add
label define geo2_mx2010_lbl 030061 `"Las Choapas"', add
label define geo2_mx2010_lbl 030062 `"Chocamán"', add
label define geo2_mx2010_lbl 030063 `"Chontla"', add
label define geo2_mx2010_lbl 030064 `"Chumatlán"', add
label define geo2_mx2010_lbl 030065 `"Emiliano Zapata"', add
label define geo2_mx2010_lbl 030066 `"Espinal"', add
label define geo2_mx2010_lbl 030067 `"Filomeno Mata"', add
label define geo2_mx2010_lbl 030068 `"Fortín"', add
label define geo2_mx2010_lbl 030069 `"Gutiérrez Zamora"', add
label define geo2_mx2010_lbl 030070 `"Hidalgotitlán"', add
label define geo2_mx2010_lbl 030071 `"Huatusco"', add
label define geo2_mx2010_lbl 030072 `"Huayacocotla"', add
label define geo2_mx2010_lbl 030073 `"Hueyapan de Ocampo"', add
label define geo2_mx2010_lbl 030074 `"Huiloapan de Cuauhtémoc"', add
label define geo2_mx2010_lbl 030075 `"Ignacio de la Llave"', add
label define geo2_mx2010_lbl 030076 `"Ilamatlán"', add
label define geo2_mx2010_lbl 030077 `"Isla"', add
label define geo2_mx2010_lbl 030078 `"Ixcatepec"', add
label define geo2_mx2010_lbl 030079 `"Ixhuacán de los Reyes"', add
label define geo2_mx2010_lbl 030080 `"Ixhuatlán del Café"', add
label define geo2_mx2010_lbl 030081 `"Ixhuatlancillo"', add
label define geo2_mx2010_lbl 030082 `"Ixhuatlán del Sureste"', add
label define geo2_mx2010_lbl 030083 `"Ixhuatlán de Madero"', add
label define geo2_mx2010_lbl 030084 `"Ixmatlahuacan"', add
label define geo2_mx2010_lbl 030085 `"Ixtaczoquitlán"', add
label define geo2_mx2010_lbl 030086 `"Jalacingo"', add
label define geo2_mx2010_lbl 030087 `"Xalapa"', add
label define geo2_mx2010_lbl 030088 `"Jalcomulco"', add
label define geo2_mx2010_lbl 030089 `"Jáltipan"', add
label define geo2_mx2010_lbl 030090 `"Jamapa"', add
label define geo2_mx2010_lbl 030091 `"Jesús Carranza"', add
label define geo2_mx2010_lbl 030092 `"Xico"', add
label define geo2_mx2010_lbl 030093 `"Jilotepec"', add
label define geo2_mx2010_lbl 030094 `"Juan Rodríguez Clara"', add
label define geo2_mx2010_lbl 030095 `"Juchique de Ferrer"', add
label define geo2_mx2010_lbl 030096 `"Landero y Coss"', add
label define geo2_mx2010_lbl 030097 `"Lerdo de Tejada"', add
label define geo2_mx2010_lbl 030098 `"Magdalena"', add
label define geo2_mx2010_lbl 030099 `"Maltrata"', add
label define geo2_mx2010_lbl 030100 `"Manlio Fabio Altamirano"', add
label define geo2_mx2010_lbl 030101 `"Mariano Escobedo"', add
label define geo2_mx2010_lbl 030102 `"Martínez de la Torre"', add
label define geo2_mx2010_lbl 030103 `"Mecatlán"', add
label define geo2_mx2010_lbl 030104 `"Mecayapan"', add
label define geo2_mx2010_lbl 030105 `"Medellín"', add
label define geo2_mx2010_lbl 030106 `"Miahuatlán"', add
label define geo2_mx2010_lbl 030107 `"Las Minas"', add
label define geo2_mx2010_lbl 030108 `"Minatitlán"', add
label define geo2_mx2010_lbl 030109 `"Misantla"', add
label define geo2_mx2010_lbl 030110 `"Mixtla de Altamirano"', add
label define geo2_mx2010_lbl 030111 `"Moloacán"', add
label define geo2_mx2010_lbl 030112 `"Naolinco"', add
label define geo2_mx2010_lbl 030113 `"Naranjal"', add
label define geo2_mx2010_lbl 030114 `"Nautla"', add
label define geo2_mx2010_lbl 030115 `"Nogales"', add
label define geo2_mx2010_lbl 030116 `"Oluta"', add
label define geo2_mx2010_lbl 030117 `"Omealca"', add
label define geo2_mx2010_lbl 030118 `"Orizaba"', add
label define geo2_mx2010_lbl 030119 `"Otatitlán"', add
label define geo2_mx2010_lbl 030120 `"Oteapan"', add
label define geo2_mx2010_lbl 030121 `"Ozuluama de Mascareñas"', add
label define geo2_mx2010_lbl 030122 `"Pajapan"', add
label define geo2_mx2010_lbl 030123 `"Pánuco"', add
label define geo2_mx2010_lbl 030124 `"Papantla"', add
label define geo2_mx2010_lbl 030125 `"Paso del Macho"', add
label define geo2_mx2010_lbl 030126 `"Paso de Ovejas"', add
label define geo2_mx2010_lbl 030127 `"La Perla"', add
label define geo2_mx2010_lbl 030128 `"Perote"', add
label define geo2_mx2010_lbl 030129 `"Platón Sánchez"', add
label define geo2_mx2010_lbl 030130 `"Playa Vicente"', add
label define geo2_mx2010_lbl 030131 `"Poza Rica de Hidalgo"', add
label define geo2_mx2010_lbl 030132 `"Las Vigas de Ramírez"', add
label define geo2_mx2010_lbl 030133 `"Pueblo Viejo"', add
label define geo2_mx2010_lbl 030134 `"Puente Nacional"', add
label define geo2_mx2010_lbl 030135 `"Rafael Delgado"', add
label define geo2_mx2010_lbl 030136 `"Rafael Lucio"', add
label define geo2_mx2010_lbl 030137 `"Los Reyes"', add
label define geo2_mx2010_lbl 030138 `"Río Blanco"', add
label define geo2_mx2010_lbl 030139 `"Saltabarranca"', add
label define geo2_mx2010_lbl 030140 `"San Andrés Tenejapan"', add
label define geo2_mx2010_lbl 030141 `"San Andrés Tuxtla"', add
label define geo2_mx2010_lbl 030142 `"San Juan Evangelista"', add
label define geo2_mx2010_lbl 030143 `"Santiago Tuxtla"', add
label define geo2_mx2010_lbl 030144 `"Sayula de Alemán"', add
label define geo2_mx2010_lbl 030145 `"Soconusco"', add
label define geo2_mx2010_lbl 030146 `"Sochiapa"', add
label define geo2_mx2010_lbl 030147 `"Soledad Atzompa"', add
label define geo2_mx2010_lbl 030148 `"Soledad de Doblado"', add
label define geo2_mx2010_lbl 030149 `"Soteapan"', add
label define geo2_mx2010_lbl 030150 `"Tamalín"', add
label define geo2_mx2010_lbl 030151 `"Tamiahua"', add
label define geo2_mx2010_lbl 030152 `"Tampico Alto"', add
label define geo2_mx2010_lbl 030153 `"Tancoco"', add
label define geo2_mx2010_lbl 030154 `"Tantima"', add
label define geo2_mx2010_lbl 030155 `"Tantoyuca"', add
label define geo2_mx2010_lbl 030156 `"Tatatila"', add
label define geo2_mx2010_lbl 030157 `"Castillo de Teayo"', add
label define geo2_mx2010_lbl 030158 `"Tecolutla"', add
label define geo2_mx2010_lbl 030159 `"Tehuipango"', add
label define geo2_mx2010_lbl 030160 `"Álamo Temapache"', add
label define geo2_mx2010_lbl 030161 `"Tempoal"', add
label define geo2_mx2010_lbl 030162 `"Tenampa"', add
label define geo2_mx2010_lbl 030163 `"Tenochtitlán"', add
label define geo2_mx2010_lbl 030164 `"Teocelo"', add
label define geo2_mx2010_lbl 030165 `"Tepatlaxco"', add
label define geo2_mx2010_lbl 030166 `"Tepetlán"', add
label define geo2_mx2010_lbl 030167 `"Tepetzintla"', add
label define geo2_mx2010_lbl 030168 `"Tequila"', add
label define geo2_mx2010_lbl 030169 `"José Azueta"', add
label define geo2_mx2010_lbl 030170 `"Texcatepec"', add
label define geo2_mx2010_lbl 030171 `"Texhuacán"', add
label define geo2_mx2010_lbl 030172 `"Texistepec"', add
label define geo2_mx2010_lbl 030173 `"Tezonapa"', add
label define geo2_mx2010_lbl 030174 `"Tierra Blanca"', add
label define geo2_mx2010_lbl 030175 `"Tihuatlán"', add
label define geo2_mx2010_lbl 030176 `"Tlacojalpan"', add
label define geo2_mx2010_lbl 030177 `"Tlacolulan"', add
label define geo2_mx2010_lbl 030178 `"Tlacotalpan"', add
label define geo2_mx2010_lbl 030179 `"Tlacotepec de Mejía"', add
label define geo2_mx2010_lbl 030180 `"Tlachichilco"', add
label define geo2_mx2010_lbl 030181 `"Tlalixcoyan"', add
label define geo2_mx2010_lbl 030182 `"Tlalnelhuayocan"', add
label define geo2_mx2010_lbl 030183 `"Tlapacoyan"', add
label define geo2_mx2010_lbl 030184 `"Tlaquilpa"', add
label define geo2_mx2010_lbl 030185 `"Tlilapan"', add
label define geo2_mx2010_lbl 030186 `"Tomatlán"', add
label define geo2_mx2010_lbl 030187 `"Tonayán"', add
label define geo2_mx2010_lbl 030188 `"Totutla"', add
label define geo2_mx2010_lbl 030189 `"Tuxpan"', add
label define geo2_mx2010_lbl 030190 `"Tuxtilla"', add
label define geo2_mx2010_lbl 030191 `"Ursulo Galván"', add
label define geo2_mx2010_lbl 030192 `"Vega de Alatorre"', add
label define geo2_mx2010_lbl 030193 `"Veracruz"', add
label define geo2_mx2010_lbl 030194 `"Villa Aldama"', add
label define geo2_mx2010_lbl 030195 `"Xoxocotla"', add
label define geo2_mx2010_lbl 030196 `"Yanga"', add
label define geo2_mx2010_lbl 030197 `"Yecuatla"', add
label define geo2_mx2010_lbl 030198 `"Zacualpan"', add
label define geo2_mx2010_lbl 030199 `"Zaragoza"', add
label define geo2_mx2010_lbl 030200 `"Zentla"', add
label define geo2_mx2010_lbl 030201 `"Zongolica"', add
label define geo2_mx2010_lbl 030202 `"Zontecomatlán de López y Fuentes"', add
label define geo2_mx2010_lbl 030203 `"Zozocolco de Hidalgo"', add
label define geo2_mx2010_lbl 030204 `"Agua Dulce"', add
label define geo2_mx2010_lbl 030205 `"El Higo"', add
label define geo2_mx2010_lbl 030206 `"Nanchital de Lázaro Cárdenas del Río"', add
label define geo2_mx2010_lbl 030207 `"Tres Valles"', add
label define geo2_mx2010_lbl 030208 `"Carlos A. Carrillo"', add
label define geo2_mx2010_lbl 030209 `"Tatahuicapan de Juárez"', add
label define geo2_mx2010_lbl 030210 `"Uxpanapa"', add
label define geo2_mx2010_lbl 030211 `"San Rafael"', add
label define geo2_mx2010_lbl 030212 `"Santiago Sochiapan"', add
label define geo2_mx2010_lbl 031001 `"Abalá"', add
label define geo2_mx2010_lbl 031002 `"Acanceh"', add
label define geo2_mx2010_lbl 031003 `"Akil"', add
label define geo2_mx2010_lbl 031004 `"Baca"', add
label define geo2_mx2010_lbl 031005 `"Bokobá"', add
label define geo2_mx2010_lbl 031006 `"Buctzotz"', add
label define geo2_mx2010_lbl 031007 `"Cacalchén"', add
label define geo2_mx2010_lbl 031008 `"Calotmul"', add
label define geo2_mx2010_lbl 031009 `"Cansahcab"', add
label define geo2_mx2010_lbl 031010 `"Cantamayec"', add
label define geo2_mx2010_lbl 031011 `"Celestún"', add
label define geo2_mx2010_lbl 031012 `"Cenotillo"', add
label define geo2_mx2010_lbl 031013 `"Conkal"', add
label define geo2_mx2010_lbl 031014 `"Cuncunul"', add
label define geo2_mx2010_lbl 031015 `"Cuzamá"', add
label define geo2_mx2010_lbl 031016 `"Chacsinkín"', add
label define geo2_mx2010_lbl 031017 `"Chankom"', add
label define geo2_mx2010_lbl 031018 `"Chapab"', add
label define geo2_mx2010_lbl 031019 `"Chemax"', add
label define geo2_mx2010_lbl 031020 `"Chicxulub Pueblo"', add
label define geo2_mx2010_lbl 031021 `"Chichimilá"', add
label define geo2_mx2010_lbl 031022 `"Chikindzonot"', add
label define geo2_mx2010_lbl 031023 `"Chocholá"', add
label define geo2_mx2010_lbl 031024 `"Chumayel"', add
label define geo2_mx2010_lbl 031025 `"Dzán"', add
label define geo2_mx2010_lbl 031026 `"Dzemul"', add
label define geo2_mx2010_lbl 031027 `"Dzidzantún"', add
label define geo2_mx2010_lbl 031028 `"Dzilam de Bravo"', add
label define geo2_mx2010_lbl 031029 `"Dzilam González"', add
label define geo2_mx2010_lbl 031030 `"Dzitás"', add
label define geo2_mx2010_lbl 031031 `"Dzoncauich"', add
label define geo2_mx2010_lbl 031032 `"Espita"', add
label define geo2_mx2010_lbl 031033 `"Halachó"', add
label define geo2_mx2010_lbl 031034 `"Hocabá"', add
label define geo2_mx2010_lbl 031035 `"Hoctún"', add
label define geo2_mx2010_lbl 031036 `"Homún"', add
label define geo2_mx2010_lbl 031037 `"Huhí"', add
label define geo2_mx2010_lbl 031038 `"Hunucmá"', add
label define geo2_mx2010_lbl 031039 `"Ixil"', add
label define geo2_mx2010_lbl 031040 `"Izamal"', add
label define geo2_mx2010_lbl 031041 `"Kanasín"', add
label define geo2_mx2010_lbl 031042 `"Kantunil"', add
label define geo2_mx2010_lbl 031043 `"Kaua"', add
label define geo2_mx2010_lbl 031044 `"Kinchil"', add
label define geo2_mx2010_lbl 031045 `"Kopomá"', add
label define geo2_mx2010_lbl 031046 `"Mama"', add
label define geo2_mx2010_lbl 031047 `"Maní"', add
label define geo2_mx2010_lbl 031048 `"Maxcanú"', add
label define geo2_mx2010_lbl 031049 `"Mayapán"', add
label define geo2_mx2010_lbl 031050 `"Mérida"', add
label define geo2_mx2010_lbl 031051 `"Mocochá"', add
label define geo2_mx2010_lbl 031052 `"Motul"', add
label define geo2_mx2010_lbl 031053 `"Muna"', add
label define geo2_mx2010_lbl 031054 `"Muxupip"', add
label define geo2_mx2010_lbl 031055 `"Opichén"', add
label define geo2_mx2010_lbl 031056 `"Oxkutzcab"', add
label define geo2_mx2010_lbl 031057 `"Panabá"', add
label define geo2_mx2010_lbl 031058 `"Peto"', add
label define geo2_mx2010_lbl 031059 `"Progreso"', add
label define geo2_mx2010_lbl 031060 `"Quintana Roo"', add
label define geo2_mx2010_lbl 031061 `"Río Lagartos"', add
label define geo2_mx2010_lbl 031062 `"Sacalum"', add
label define geo2_mx2010_lbl 031063 `"Samahil"', add
label define geo2_mx2010_lbl 031064 `"Sanahcat"', add
label define geo2_mx2010_lbl 031065 `"San Felipe"', add
label define geo2_mx2010_lbl 031066 `"Santa Elena"', add
label define geo2_mx2010_lbl 031067 `"Seyé"', add
label define geo2_mx2010_lbl 031068 `"Sinanché"', add
label define geo2_mx2010_lbl 031069 `"Sotuta"', add
label define geo2_mx2010_lbl 031070 `"Sucilá"', add
label define geo2_mx2010_lbl 031071 `"Sudzal"', add
label define geo2_mx2010_lbl 031072 `"Suma"', add
label define geo2_mx2010_lbl 031073 `"Tahdziú"', add
label define geo2_mx2010_lbl 031074 `"Tahmek"', add
label define geo2_mx2010_lbl 031075 `"Teabo"', add
label define geo2_mx2010_lbl 031076 `"Tecoh"', add
label define geo2_mx2010_lbl 031077 `"Tekal de Venegas"', add
label define geo2_mx2010_lbl 031078 `"Tekantó"', add
label define geo2_mx2010_lbl 031079 `"Tekax"', add
label define geo2_mx2010_lbl 031080 `"Tekit"', add
label define geo2_mx2010_lbl 031081 `"Tekom"', add
label define geo2_mx2010_lbl 031082 `"Telchac Pueblo"', add
label define geo2_mx2010_lbl 031083 `"Telchac Puerto"', add
label define geo2_mx2010_lbl 031084 `"Temax"', add
label define geo2_mx2010_lbl 031085 `"Temozón"', add
label define geo2_mx2010_lbl 031086 `"Tepakán"', add
label define geo2_mx2010_lbl 031087 `"Tetiz"', add
label define geo2_mx2010_lbl 031088 `"Teya"', add
label define geo2_mx2010_lbl 031089 `"Ticul"', add
label define geo2_mx2010_lbl 031090 `"Timucuy"', add
label define geo2_mx2010_lbl 031091 `"Tinum"', add
label define geo2_mx2010_lbl 031092 `"Tixcacalcupul"', add
label define geo2_mx2010_lbl 031093 `"Tixkokob"', add
label define geo2_mx2010_lbl 031094 `"Tixmehuac"', add
label define geo2_mx2010_lbl 031095 `"Tixpéhual"', add
label define geo2_mx2010_lbl 031096 `"Tizimín"', add
label define geo2_mx2010_lbl 031097 `"Tunkás"', add
label define geo2_mx2010_lbl 031098 `"Tzucacab"', add
label define geo2_mx2010_lbl 031099 `"Uayma"', add
label define geo2_mx2010_lbl 031100 `"Ucú"', add
label define geo2_mx2010_lbl 031101 `"Umán"', add
label define geo2_mx2010_lbl 031102 `"Valladolid"', add
label define geo2_mx2010_lbl 031103 `"Xocchel"', add
label define geo2_mx2010_lbl 031104 `"Yaxcabá"', add
label define geo2_mx2010_lbl 031105 `"Yaxkukul"', add
label define geo2_mx2010_lbl 031106 `"Yobaín"', add
label define geo2_mx2010_lbl 032001 `"Apozol"', add
label define geo2_mx2010_lbl 032002 `"Apulco"', add
label define geo2_mx2010_lbl 032003 `"Atolinga"', add
label define geo2_mx2010_lbl 032004 `"Benito Juárez"', add
label define geo2_mx2010_lbl 032005 `"Calera"', add
label define geo2_mx2010_lbl 032006 `"Cañitas de Felipe Pescador"', add
label define geo2_mx2010_lbl 032007 `"Concepción del Oro"', add
label define geo2_mx2010_lbl 032008 `"Cuauhtémoc"', add
label define geo2_mx2010_lbl 032009 `"Chalchihuites"', add
label define geo2_mx2010_lbl 032010 `"Fresnillo"', add
label define geo2_mx2010_lbl 032011 `"Trinidad García de la Cadena"', add
label define geo2_mx2010_lbl 032012 `"Genaro Codina"', add
label define geo2_mx2010_lbl 032013 `"General Enrique Estrada"', add
label define geo2_mx2010_lbl 032014 `"General Francisco R. Murguía"', add
label define geo2_mx2010_lbl 032015 `"El Plateado de Joaquín Amaro"', add
label define geo2_mx2010_lbl 032016 `"General Pánfilo Natera"', add
label define geo2_mx2010_lbl 032017 `"Guadalupe"', add
label define geo2_mx2010_lbl 032018 `"Huanusco"', add
label define geo2_mx2010_lbl 032019 `"Jalpa"', add
label define geo2_mx2010_lbl 032020 `"Jerez"', add
label define geo2_mx2010_lbl 032021 `"Jiménez del Teul"', add
label define geo2_mx2010_lbl 032022 `"Juan Aldama"', add
label define geo2_mx2010_lbl 032023 `"Juchipila"', add
label define geo2_mx2010_lbl 032024 `"Loreto"', add
label define geo2_mx2010_lbl 032025 `"Luis Moya"', add
label define geo2_mx2010_lbl 032026 `"Mazapil"', add
label define geo2_mx2010_lbl 032027 `"Melchor Ocampo"', add
label define geo2_mx2010_lbl 032028 `"Mezquital del Oro"', add
label define geo2_mx2010_lbl 032029 `"Miguel Auza"', add
label define geo2_mx2010_lbl 032030 `"Momax"', add
label define geo2_mx2010_lbl 032031 `"Monte Escobedo"', add
label define geo2_mx2010_lbl 032032 `"Morelos"', add
label define geo2_mx2010_lbl 032033 `"Moyahua de Estrada"', add
label define geo2_mx2010_lbl 032034 `"Nochistlán de Mejía"', add
label define geo2_mx2010_lbl 032035 `"Noria de Ángeles"', add
label define geo2_mx2010_lbl 032036 `"Ojocaliente"', add
label define geo2_mx2010_lbl 032037 `"Pánuco"', add
label define geo2_mx2010_lbl 032038 `"Pinos"', add
label define geo2_mx2010_lbl 032039 `"Río Grande"', add
label define geo2_mx2010_lbl 032040 `"Sain Alto"', add
label define geo2_mx2010_lbl 032041 `"El Salvador"', add
label define geo2_mx2010_lbl 032042 `"Sombrerete"', add
label define geo2_mx2010_lbl 032043 `"Susticacán"', add
label define geo2_mx2010_lbl 032044 `"Tabasco"', add
label define geo2_mx2010_lbl 032045 `"Tepechitlán"', add
label define geo2_mx2010_lbl 032046 `"Tepetongo"', add
label define geo2_mx2010_lbl 032047 `"Teúl de González Ortega"', add
label define geo2_mx2010_lbl 032048 `"Tlaltenango de Sánchez Román"', add
label define geo2_mx2010_lbl 032049 `"Valparaíso"', add
label define geo2_mx2010_lbl 032050 `"Vetagrande"', add
label define geo2_mx2010_lbl 032051 `"Villa de Cos"', add
label define geo2_mx2010_lbl 032052 `"Villa García"', add
label define geo2_mx2010_lbl 032053 `"Villa González Ortega"', add
label define geo2_mx2010_lbl 032054 `"Villa Hidalgo"', add
label define geo2_mx2010_lbl 032055 `"Villanueva"', add
label define geo2_mx2010_lbl 032056 `"Zacatecas"', add
label define geo2_mx2010_lbl 032057 `"Trancoso"', add
label define geo2_mx2010_lbl 032058 `"Santa María de la Paz"', add
label values geo2_mx2010 geo2_mx2010_lbl

label define sizemx_lbl 1 `"Less than 2,500 inhabitants"'
label define sizemx_lbl 2 `"2,500 to 14,999 inhabitants"', add
label define sizemx_lbl 3 `"15,000 to 99,999 inhabitants"', add
label define sizemx_lbl 4 `"100,000 or more inhabitants"', add
label values sizemx sizemx_lbl

label define ownership_lbl 0 `"NIU (not in universe)"'
label define ownership_lbl 1 `"Owned"', add
label define ownership_lbl 2 `"Not owned"', add
label define ownership_lbl 9 `"Unknown"', add
label values ownership ownership_lbl

label define ownershipd_lbl 000 `"NIU (not in universe)"'
label define ownershipd_lbl 100 `"Owned"', add
label define ownershipd_lbl 110 `"Owned, already paid"', add
label define ownershipd_lbl 120 `"Owned, still paying"', add
label define ownershipd_lbl 130 `"Owned, constructed"', add
label define ownershipd_lbl 140 `"Owned, inherited"', add
label define ownershipd_lbl 190 `"Owned, other"', add
label define ownershipd_lbl 191 `"Owned, house"', add
label define ownershipd_lbl 192 `"Owned, condominium"', add
label define ownershipd_lbl 193 `"Apartment proprietor"', add
label define ownershipd_lbl 194 `"Shared ownership"', add
label define ownershipd_lbl 200 `"Not owned"', add
label define ownershipd_lbl 210 `"Renting, not specified"', add
label define ownershipd_lbl 211 `"Renting, government"', add
label define ownershipd_lbl 212 `"Renting, local authority"', add
label define ownershipd_lbl 213 `"Renting, parastatal"', add
label define ownershipd_lbl 214 `"Renting, private"', add
label define ownershipd_lbl 215 `"Renting, private company"', add
label define ownershipd_lbl 216 `"Renting, individual"', add
label define ownershipd_lbl 217 `"Renting, collective"', add
label define ownershipd_lbl 218 `"Renting, joint state and individual"', add
label define ownershipd_lbl 219 `"Renting, public subsidized"', add
label define ownershipd_lbl 220 `"Renting, private subsidized"', add
label define ownershipd_lbl 221 `"Renting, co-tenant"', add
label define ownershipd_lbl 222 `"Renting, relative of tenant"', add
label define ownershipd_lbl 223 `"Renting, cooperative"', add
label define ownershipd_lbl 224 `"Renting, with a job or business"', add
label define ownershipd_lbl 225 `"Renting, loan-backed habitation"', add
label define ownershipd_lbl 226 `"Renting, mixed contract"', add
label define ownershipd_lbl 227 `"Furnished dwelling"', add
label define ownershipd_lbl 228 `"Sharecropping"', add
label define ownershipd_lbl 230 `"Subletting"', add
label define ownershipd_lbl 231 `"Rent to own"', add
label define ownershipd_lbl 239 `"Renting, other"', add
label define ownershipd_lbl 240 `"Occupied de facto/squatting"', add
label define ownershipd_lbl 250 `"Free/usufruct (no cash rent)"', add
label define ownershipd_lbl 251 `"Free, provided by employer"', add
label define ownershipd_lbl 252 `"Free, without work or services"', add
label define ownershipd_lbl 253 `"Free, provided by family or friend"', add
label define ownershipd_lbl 254 `"Free, private"', add
label define ownershipd_lbl 255 `"Free, public"', add
label define ownershipd_lbl 256 `"Free, condemned"', add
label define ownershipd_lbl 257 `"Free, other"', add
label define ownershipd_lbl 290 `"Not owned, other"', add
label define ownershipd_lbl 999 `"Unknown"', add
label values ownershipd ownershipd_lbl

label define electric_lbl 0 `"NIU (not in universe)"'
label define electric_lbl 1 `"Yes"', add
label define electric_lbl 2 `"No"', add
label define electric_lbl 9 `"Unknown"', add
label values electric electric_lbl

label define watsup_lbl 00 `"NIU (not in universe)"'
label define watsup_lbl 10 `"Yes, piped water"', add
label define watsup_lbl 11 `"Piped inside dwelling"', add
label define watsup_lbl 12 `"Piped, exclusively to this household"', add
label define watsup_lbl 13 `"Piped, shared with other households"', add
label define watsup_lbl 14 `"Piped outside the dwelling"', add
label define watsup_lbl 15 `"Piped outside dwelling, in building"', add
label define watsup_lbl 16 `"Piped within the building or plot of land"', add
label define watsup_lbl 17 `"Piped outside the building or lot"', add
label define watsup_lbl 18 `"Have access to public piped water"', add
label define watsup_lbl 20 `"No piped water"', add
label define watsup_lbl 99 `"Unknown"', add
label values watsup watsup_lbl

label define sewage_lbl 00 `"NIU (not in universe)"'
label define sewage_lbl 10 `"Connected to sewage system or septic tank"', add
label define sewage_lbl 11 `"Sewage system (public sewage disposal)"', add
label define sewage_lbl 12 `"Septic tank (private sewage disposal)"', add
label define sewage_lbl 20 `"Not connected to sewage disposal system"', add
label define sewage_lbl 99 `"Unknown"', add
label values sewage sewage_lbl

label define cell_lbl 0 `"NIU (not in universe)"'
label define cell_lbl 1 `"Yes"', add
label define cell_lbl 2 `"No"', add
label define cell_lbl 9 `"Unknown"', add
label values cell cell_lbl

label define autos_lbl 0 `"No autos"'
label define autos_lbl 1 `"1 auto"', add
label define autos_lbl 2 `"2 autos"', add
label define autos_lbl 3 `"3 autos"', add
label define autos_lbl 4 `"4 autos"', add
label define autos_lbl 5 `"5 autos"', add
label define autos_lbl 6 `"6+ autos"', add
label define autos_lbl 7 `"Have auto, number unspecified"', add
label define autos_lbl 8 `"Unknown"', add
label define autos_lbl 9 `"NIU (not in universe)"', add
label values autos autos_lbl

label define hotwater_lbl 0 `"NIU (not in universe)"'
label define hotwater_lbl 1 `"No"', add
label define hotwater_lbl 2 `"Yes"', add
label define hotwater_lbl 9 `"Unknown/missing"', add
label values hotwater hotwater_lbl

label define computer_lbl 0 `"NIU (not in universe)"'
label define computer_lbl 1 `"No"', add
label define computer_lbl 2 `"Yes"', add
label define computer_lbl 9 `"Unknown/missing"', add
label values computer computer_lbl

label define washer_lbl 0 `"NIU (not in universe)"'
label define washer_lbl 1 `"No"', add
label define washer_lbl 2 `"Yes"', add
label define washer_lbl 3 `"Automatic or semi-automatic"', add
label define washer_lbl 4 `"Wringer or other non-automatic"', add
label define washer_lbl 9 `"Unknown/missing"', add
label values washer washer_lbl

label define refrig_lbl 0 `"NIU (not in universe)"'
label define refrig_lbl 1 `"No"', add
label define refrig_lbl 2 `"Yes"', add
label define refrig_lbl 9 `"Unknown/missing"', add
label values refrig refrig_lbl

label define tv_lbl 00 `"NIU (not in universe)"'
label define tv_lbl 10 `"No"', add
label define tv_lbl 20 `"Yes, color or black-and-white not specified"', add
label define tv_lbl 21 `"1 television"', add
label define tv_lbl 22 `"2 televisions"', add
label define tv_lbl 23 `"3 televisions"', add
label define tv_lbl 24 `"4 televisions"', add
label define tv_lbl 25 `"5 televisions"', add
label define tv_lbl 26 `"6 televisions"', add
label define tv_lbl 27 `"7 televisions"', add
label define tv_lbl 28 `"8 televisions"', add
label define tv_lbl 29 `"9+ televisions"', add
label define tv_lbl 30 `"Yes, at least one color tv"', add
label define tv_lbl 31 `"1 color tv"', add
label define tv_lbl 32 `"2 color tvs"', add
label define tv_lbl 33 `"3+ televisions"', add
label define tv_lbl 40 `"Yes, black-and-white only"', add
label define tv_lbl 41 `"1 black-white tv"', add
label define tv_lbl 42 `"2 black-white tvs"', add
label define tv_lbl 43 `"3+ black-white tvs"', add
label define tv_lbl 99 `"Unknown/missing"', add
label values tv tv_lbl

label define rooms_lbl 00 `"Part of a room; no rooms"'
label define rooms_lbl 01 `"1"', add
label define rooms_lbl 02 `"2"', add
label define rooms_lbl 03 `"3"', add
label define rooms_lbl 04 `"4"', add
label define rooms_lbl 05 `"5"', add
label define rooms_lbl 06 `"6"', add
label define rooms_lbl 07 `"7"', add
label define rooms_lbl 08 `"8"', add
label define rooms_lbl 09 `"9"', add
label define rooms_lbl 10 `"10"', add
label define rooms_lbl 11 `"11"', add
label define rooms_lbl 12 `"12"', add
label define rooms_lbl 13 `"13"', add
label define rooms_lbl 14 `"14"', add
label define rooms_lbl 15 `"15"', add
label define rooms_lbl 16 `"16"', add
label define rooms_lbl 17 `"17"', add
label define rooms_lbl 18 `"18"', add
label define rooms_lbl 19 `"19"', add
label define rooms_lbl 20 `"20"', add
label define rooms_lbl 21 `"21"', add
label define rooms_lbl 22 `"22"', add
label define rooms_lbl 23 `"23"', add
label define rooms_lbl 24 `"24"', add
label define rooms_lbl 25 `"25"', add
label define rooms_lbl 26 `"26"', add
label define rooms_lbl 27 `"27"', add
label define rooms_lbl 28 `"28"', add
label define rooms_lbl 29 `"29"', add
label define rooms_lbl 30 `"30+"', add
label define rooms_lbl 98 `"Unknown"', add
label define rooms_lbl 99 `"NIU (not in universe)"', add
label values rooms rooms_lbl

label define bedrooms_lbl 00 `"No bedrooms"'
label define bedrooms_lbl 01 `"1"', add
label define bedrooms_lbl 02 `"2"', add
label define bedrooms_lbl 03 `"3"', add
label define bedrooms_lbl 04 `"4"', add
label define bedrooms_lbl 05 `"5"', add
label define bedrooms_lbl 06 `"6"', add
label define bedrooms_lbl 07 `"7"', add
label define bedrooms_lbl 08 `"8"', add
label define bedrooms_lbl 09 `"9"', add
label define bedrooms_lbl 10 `"10"', add
label define bedrooms_lbl 11 `"11"', add
label define bedrooms_lbl 12 `"12"', add
label define bedrooms_lbl 13 `"13"', add
label define bedrooms_lbl 14 `"14"', add
label define bedrooms_lbl 15 `"15"', add
label define bedrooms_lbl 16 `"16"', add
label define bedrooms_lbl 17 `"17"', add
label define bedrooms_lbl 18 `"18"', add
label define bedrooms_lbl 19 `"19"', add
label define bedrooms_lbl 20 `"20+"', add
label define bedrooms_lbl 98 `"Unknown"', add
label define bedrooms_lbl 99 `"NIU (not in universe)"', add
label values bedrooms bedrooms_lbl

label define toilet_lbl 00 `"NIU (not in universe)"'
label define toilet_lbl 10 `"No toilet"', add
label define toilet_lbl 11 `"No flush toilet"', add
label define toilet_lbl 20 `"Have toilet, type not specified"', add
label define toilet_lbl 21 `"Flush toilet"', add
label define toilet_lbl 22 `"Non-flush, latrine"', add
label define toilet_lbl 23 `"Non-flush, other and unspecified"', add
label define toilet_lbl 99 `"Unknown"', add
label values toilet toilet_lbl

label define floor_lbl 000 `"NIU (not in universe)"'
label define floor_lbl 100 `"None/unfinished (earth)"', add
label define floor_lbl 110 `"Sand"', add
label define floor_lbl 120 `"Dung"', add
label define floor_lbl 200 `"Finished"', add
label define floor_lbl 201 `"Cement, tile, or brick"', add
label define floor_lbl 202 `"Cement"', add
label define floor_lbl 203 `"Concrete"', add
label define floor_lbl 204 `"Cement screed"', add
label define floor_lbl 205 `"Ceramic tile"', add
label define floor_lbl 206 `"Paving stone, cement tile"', add
label define floor_lbl 207 `"Stone"', add
label define floor_lbl 208 `"Brick"', add
label define floor_lbl 209 `"Brick or stone"', add
label define floor_lbl 210 `"Brick or cement"', add
label define floor_lbl 211 `"Block"', add
label define floor_lbl 212 `"Terrazzo"', add
label define floor_lbl 213 `"Wood"', add
label define floor_lbl 214 `"Palm, bamboo"', add
label define floor_lbl 215 `"Parquet"', add
label define floor_lbl 216 `"Parquet, tile, vinyl"', add
label define floor_lbl 217 `"Parquet, tile, marble"', add
label define floor_lbl 218 `"Ceramic, marble, granite"', add
label define floor_lbl 219 `"Ceramic, marble, tile, or vinyl"', add
label define floor_lbl 220 `"Marble"', add
label define floor_lbl 221 `"Mosaic"', add
label define floor_lbl 222 `"Tile"', add
label define floor_lbl 223 `"Tile, linoleum, ceramic, etc"', add
label define floor_lbl 224 `"Tile, cement"', add
label define floor_lbl 225 `"Tile, stone"', add
label define floor_lbl 226 `"Tile, stone, brick"', add
label define floor_lbl 227 `"Tile, stone, vinyl, brick"', add
label define floor_lbl 228 `"Tile, vinyl, brick"', add
label define floor_lbl 229 `"Tile, vinyl"', add
label define floor_lbl 230 `"Vinyl, linoleum, etc"', add
label define floor_lbl 231 `"Asphalt sheet, vinyl, etc"', add
label define floor_lbl 232 `"Synthetic, plastic"', add
label define floor_lbl 233 `"Cane"', add
label define floor_lbl 234 `"Carpet"', add
label define floor_lbl 235 `"Scrap material"', add
label define floor_lbl 236 `"Other finished, n.e.c."', add
label define floor_lbl 999 `"Unknown/missing"', add
label values floor floor_lbl

label define wall_lbl 000 `"NIU (not in universe)"'
label define wall_lbl 100 `"No walls"', add
label define wall_lbl 200 `"Cardboard, scrap, and miscellaneous materials"', add
label define wall_lbl 201 `"Waste, scrap, or discarded material"', add
label define wall_lbl 202 `"Fabric or discarded material"', add
label define wall_lbl 203 `"Zinc, fabric, cardboard, tins, and waste material"', add
label define wall_lbl 204 `"Cardboard sheet"', add
label define wall_lbl 205 `"Plastic sheeting, cardboard"', add
label define wall_lbl 206 `"Makeshift, salvaged, or improvised materials"', add
label define wall_lbl 207 `"Reused materials"', add
label define wall_lbl 300 `"Wood"', add
label define wall_lbl 310 `"Rough wood"', add
label define wall_lbl 320 `"Wood, fibercement or plywood"', add
label define wall_lbl 330 `"Wood, formica, and other"', add
label define wall_lbl 340 `"Wood or bamboo"', add
label define wall_lbl 350 `"Wood or straw"', add
label define wall_lbl 400 `"Other plant-based materials"', add
label define wall_lbl 401 `"Plantain leaves and similar material"', add
label define wall_lbl 402 `"Bamboo or cane"', add
label define wall_lbl 403 `"Bamboo, sawali, cogon, nipa"', add
label define wall_lbl 404 `"Straw or bamboo"', add
label define wall_lbl 405 `"Grass, straw or reed"', add
label define wall_lbl 406 `"Reed, bamboo, or palm"', add
label define wall_lbl 407 `"Cane, palm leaves, logs"', add
label define wall_lbl 408 `"Palm leaves or palm planks"', add
label define wall_lbl 409 `"Bark, sticks, or cane"', add
label define wall_lbl 500 `"Masonry, stone, cement, adobe, metal, glass, and other fabricated materials (sometimes mixed with wood)"', add
label define wall_lbl 501 `"Brick, block, stone, or cement"', add
label define wall_lbl 502 `"Brick, stone, concrete"', add
label define wall_lbl 503 `"Brick, stone, or substitutes (dividing panels made of reinforced concrete)"', add
label define wall_lbl 504 `"Brick, stone, or substitutes (dividing panels made of wood)"', add
label define wall_lbl 505 `"Brick or tile"', add
label define wall_lbl 506 `"Brick or stone"', add
label define wall_lbl 507 `"Brick or cement block"', add
label define wall_lbl 508 `"Brick with plaster exterior"', add
label define wall_lbl 509 `"Brick without plaster exterior"', add
label define wall_lbl 510 `"Burnt or stabilized brick"', add
label define wall_lbl 511 `"Brick"', add
label define wall_lbl 512 `"Unburnt brick"', add
label define wall_lbl 513 `"Unburnt brick with cement"', add
label define wall_lbl 514 `"Unburnt brick with mud"', add
label define wall_lbl 515 `"Concrete"', add
label define wall_lbl 516 `"Landcrete"', add
label define wall_lbl 517 `"Cement blocks"', add
label define wall_lbl 518 `"Cement blocks or brick"', add
label define wall_lbl 519 `"Cement blocks or brick, unfinished"', add
label define wall_lbl 520 `"Cement and adobe bricks"', add
label define wall_lbl 521 `"Cement and stone block"', add
label define wall_lbl 522 `"Reinforced concrete, pre-cast concrete panels, or steel skeleton framed concrete"', add
label define wall_lbl 523 `"Concrete, reinforced concrete, blocks, panels"', add
label define wall_lbl 524 `"Adobe"', add
label define wall_lbl 525 `"Adobe walls with plaster exterior"', add
label define wall_lbl 526 `"Adobe walls without plaster exterior"', add
label define wall_lbl 527 `"Adobe with cement exterior"', add
label define wall_lbl 528 `"Adobe (tabique, quinche)"', add
label define wall_lbl 529 `"Wood and earth adobe"', add
label define wall_lbl 530 `"Wood and cement adobe"', add
label define wall_lbl 531 `"Mud or adobe"', add
label define wall_lbl 532 `"Pressed dirt"', add
label define wall_lbl 533 `"Clay"', add
label define wall_lbl 534 `"Coated clay/mud with sticks/cane"', add
label define wall_lbl 535 `"Clay or clay-covered sticks"', add
label define wall_lbl 536 `"Netted bamboo or cane with mud"', add
label define wall_lbl 537 `"Bundle of mud, straw, other materials"', add
label define wall_lbl 538 `"Mud with wood/wattle"', add
label define wall_lbl 539 `"Pole and mud"', add
label define wall_lbl 540 `"Mud with cement"', add
label define wall_lbl 541 `"Unfinished lathe and plaster, stucco, etc."', add
label define wall_lbl 542 `"Stone"', add
label define wall_lbl 543 `"Hand-laid stone"', add
label define wall_lbl 544 `"Quarried stone"', add
label define wall_lbl 545 `"Cut stone and concrete"', add
label define wall_lbl 546 `"Cemented stone"', add
label define wall_lbl 547 `"Stone with clay"', add
label define wall_lbl 548 `"Blocks of light material"', add
label define wall_lbl 549 `"Prefabricated material"', add
label define wall_lbl 550 `"Asbestos"', add
label define wall_lbl 551 `"Metal or asbestos sheet"', add
label define wall_lbl 552 `"Metal or iron sheet"', add
label define wall_lbl 553 `"Metal or fibercement sheeting"', add
label define wall_lbl 554 `"Galvanized iron or aluminum"', add
label define wall_lbl 555 `"Tin"', add
label define wall_lbl 556 `"Glass"', add
label define wall_lbl 557 `"Cloth"', add
label define wall_lbl 558 `"Covintec panels"', add
label define wall_lbl 559 `"Mixed material"', add
label define wall_lbl 560 `"Mixed material: part wood; part concrete, brick, or stone"', add
label define wall_lbl 561 `"Wood plastered with clay, adobe, other materials; wood pressed panels; rolled mud bricks; etc."', add
label define wall_lbl 562 `"Mixed material: wood or galvanized metal"', add
label define wall_lbl 570 `"Mainly permanent materials"', add
label define wall_lbl 600 `"Other material"', add
label define wall_lbl 999 `"Unknown/missing"', add
label values wall wall_lbl

label define roof_lbl 00 `"NIU (not in universe)"'
label define roof_lbl 10 `"Masonry, concrete, clay tile, or tiles of unspecified type"', add
label define roof_lbl 11 `"Concrete or cement"', add
label define roof_lbl 12 `"Reinforced concrete (slab)"', add
label define roof_lbl 13 `"Cement or sheet metal"', add
label define roof_lbl 14 `"Tile, unspecified"', add
label define roof_lbl 15 `"Clay tile"', add
label define roof_lbl 16 `"Tile or cement"', add
label define roof_lbl 17 `"Modern tiles, industrial"', add
label define roof_lbl 18 `"Traditional tiles, locally made"', add
label define roof_lbl 19 `"Tile or flat stone"', add
label define roof_lbl 20 `"Fibercement or plastic"', add
label define roof_lbl 21 `"Asphalt or laminate cover"', add
label define roof_lbl 22 `"Tile, cement, asphalt"', add
label define roof_lbl 23 `"Asphalt tile"', add
label define roof_lbl 24 `"Slate or tile"', add
label define roof_lbl 25 `"Slate or asbestos"', add
label define roof_lbl 26 `"Asbestos"', add
label define roof_lbl 27 `"Adobe"', add
label define roof_lbl 28 `"Tiles or wood planks"', add
label define roof_lbl 29 `"Roofing shingles"', add
label define roof_lbl 30 `"Metal"', add
label define roof_lbl 31 `"Sheet metal"', add
label define roof_lbl 32 `"Zinc or tin"', add
label define roof_lbl 33 `"Tin"', add
label define roof_lbl 35 `"Sheet metal or other sheet material"', add
label define roof_lbl 36 `"Sheet metal, tile, slate"', add
label define roof_lbl 40 `"Wood and other plant materials"', add
label define roof_lbl 41 `"Wood"', add
label define roof_lbl 42 `"Wood, including bamboo"', add
label define roof_lbl 43 `"Bamboo"', add
label define roof_lbl 44 `"Cogon, nipa, anahaw"', add
label define roof_lbl 45 `"Thatch (straw, grass, leaves, palm, etc.)"', add
label define roof_lbl 46 `"Cane, wood, straw"', add
label define roof_lbl 47 `"Grass"', add
label define roof_lbl 48 `"Papyrus"', add
label define roof_lbl 49 `"Banana leaves or fiber"', add
label define roof_lbl 50 `"Palm or makuti"', add
label define roof_lbl 51 `"Wood with clay"', add
label define roof_lbl 53 `"Grass and mud"', add
label define roof_lbl 54 `"Straw, bamboo, polythene"', add
label define roof_lbl 55 `"Rustic mat"', add
label define roof_lbl 60 `"Mud or earth"', add
label define roof_lbl 61 `"Clay"', add
label define roof_lbl 70 `"Cardboard, scrap, and miscellaneous materials"', add
label define roof_lbl 71 `"Discarded or scrap material"', add
label define roof_lbl 72 `"Cardboard"', add
label define roof_lbl 73 `"Plastic"', add
label define roof_lbl 80 `"Other, unspecified"', add
label define roof_lbl 90 `"No roof"', add
label define roof_lbl 99 `"Unknown/missing"', add
label values roof roof_lbl

label define mx2010a_persons_lbl 01 `"1"'
label define mx2010a_persons_lbl 02 `"2"', add
label define mx2010a_persons_lbl 03 `"3"', add
label define mx2010a_persons_lbl 04 `"4"', add
label define mx2010a_persons_lbl 05 `"5"', add
label define mx2010a_persons_lbl 06 `"6"', add
label define mx2010a_persons_lbl 07 `"7"', add
label define mx2010a_persons_lbl 08 `"8"', add
label define mx2010a_persons_lbl 09 `"9"', add
label define mx2010a_persons_lbl 10 `"10"', add
label define mx2010a_persons_lbl 11 `"11"', add
label define mx2010a_persons_lbl 12 `"12"', add
label define mx2010a_persons_lbl 13 `"13"', add
label define mx2010a_persons_lbl 14 `"14"', add
label define mx2010a_persons_lbl 15 `"15"', add
label define mx2010a_persons_lbl 16 `"16"', add
label define mx2010a_persons_lbl 17 `"17"', add
label define mx2010a_persons_lbl 18 `"18"', add
label define mx2010a_persons_lbl 19 `"19"', add
label define mx2010a_persons_lbl 20 `"20"', add
label define mx2010a_persons_lbl 21 `"21"', add
label define mx2010a_persons_lbl 22 `"22"', add
label define mx2010a_persons_lbl 23 `"23"', add
label define mx2010a_persons_lbl 24 `"24"', add
label define mx2010a_persons_lbl 25 `"25"', add
label define mx2010a_persons_lbl 26 `"26"', add
label define mx2010a_persons_lbl 27 `"27"', add
label define mx2010a_persons_lbl 28 `"28"', add
label define mx2010a_persons_lbl 29 `"29"', add
label define mx2010a_persons_lbl 30 `"30"', add
label define mx2010a_persons_lbl 31 `"31"', add
label define mx2010a_persons_lbl 32 `"32"', add
label define mx2010a_persons_lbl 33 `"33"', add
label define mx2010a_persons_lbl 34 `"34"', add
label define mx2010a_persons_lbl 35 `"35"', add
label define mx2010a_persons_lbl 38 `"38"', add
label values mx2010a_persons mx2010a_persons_lbl

label define mx2010a_sizepl_lbl 1 `"Fewer than 2,500 inhabitants"'
label define mx2010a_sizepl_lbl 2 `"2,500 to 14,999 inhabitants"', add
label define mx2010a_sizepl_lbl 3 `"15,000 to 99,999 inhabitants"', add
label define mx2010a_sizepl_lbl 4 `"100,000 or more inhabitants"', add
label values mx2010a_sizepl mx2010a_sizepl_lbl

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

label define marst_lbl 0 `"NIU (not in universe)"'
label define marst_lbl 1 `"Single/never married"', add
label define marst_lbl 2 `"Married/in union"', add
label define marst_lbl 3 `"Separated/divorced/spouse absent"', add
label define marst_lbl 4 `"Widowed"', add
label define marst_lbl 9 `"Unknown/missing"', add
label values marst marst_lbl

label define marstd_lbl 000 `"NIU (not in universe)"'
label define marstd_lbl 100 `"Single/never married"', add
label define marstd_lbl 110 `"Engaged"', add
label define marstd_lbl 111 `"Never married and never cohabited"', add
label define marstd_lbl 200 `"Married or consensual union"', add
label define marstd_lbl 210 `"Married, formally"', add
label define marstd_lbl 211 `"Married, civil"', add
label define marstd_lbl 212 `"Married, religious"', add
label define marstd_lbl 213 `"Married, civil and religious"', add
label define marstd_lbl 214 `"Married, civil or religious"', add
label define marstd_lbl 215 `"Married, traditional/customary"', add
label define marstd_lbl 216 `"Married, monogamous"', add
label define marstd_lbl 217 `"Married, polygamous"', add
label define marstd_lbl 219 `"Married, spouse absent (historical samples)"', add
label define marstd_lbl 220 `"Consensual union"', add
label define marstd_lbl 300 `"Separated/divorced/spouse absent"', add
label define marstd_lbl 310 `"Separated or divorced"', add
label define marstd_lbl 320 `"Separated or annulled"', add
label define marstd_lbl 330 `"Separated"', add
label define marstd_lbl 331 `"Separated legally"', add
label define marstd_lbl 332 `"Separated de facto"', add
label define marstd_lbl 333 `"Separated from marriage"', add
label define marstd_lbl 334 `"Separated from consensual union"', add
label define marstd_lbl 335 `"Separated from consensual union or marriage"', add
label define marstd_lbl 340 `"Annulled"', add
label define marstd_lbl 350 `"Divorced"', add
label define marstd_lbl 400 `"Widowed"', add
label define marstd_lbl 410 `"Widowed or divorced"', add
label define marstd_lbl 411 `"Widowed from consensual union or marriage"', add
label define marstd_lbl 412 `"Widowed from marriage"', add
label define marstd_lbl 413 `"Widowed from consensual union"', add
label define marstd_lbl 420 `"Widowed, divorced, or separated"', add
label define marstd_lbl 999 `"Unknown/missing"', add
label values marstd marstd_lbl

label define chborn_lbl 00 `"No children"'
label define chborn_lbl 01 `"1 child"', add
label define chborn_lbl 02 `"2 children"', add
label define chborn_lbl 03 `"3"', add
label define chborn_lbl 04 `"4"', add
label define chborn_lbl 05 `"5"', add
label define chborn_lbl 06 `"6"', add
label define chborn_lbl 07 `"7"', add
label define chborn_lbl 08 `"8"', add
label define chborn_lbl 09 `"9"', add
label define chborn_lbl 10 `"10"', add
label define chborn_lbl 11 `"11"', add
label define chborn_lbl 12 `"12"', add
label define chborn_lbl 13 `"13"', add
label define chborn_lbl 14 `"14"', add
label define chborn_lbl 15 `"15"', add
label define chborn_lbl 16 `"16"', add
label define chborn_lbl 17 `"17"', add
label define chborn_lbl 18 `"18"', add
label define chborn_lbl 19 `"19"', add
label define chborn_lbl 20 `"20"', add
label define chborn_lbl 21 `"21"', add
label define chborn_lbl 22 `"22"', add
label define chborn_lbl 23 `"23"', add
label define chborn_lbl 24 `"24"', add
label define chborn_lbl 25 `"25"', add
label define chborn_lbl 26 `"26"', add
label define chborn_lbl 27 `"27"', add
label define chborn_lbl 28 `"28"', add
label define chborn_lbl 29 `"29"', add
label define chborn_lbl 30 `"30+"', add
label define chborn_lbl 98 `"Unknown"', add
label define chborn_lbl 99 `"NIU (not in universe)"', add
label values chborn chborn_lbl

label define chsurv_lbl 00 `"No children"'
label define chsurv_lbl 01 `"1 child"', add
label define chsurv_lbl 02 `"2 children"', add
label define chsurv_lbl 03 `"3"', add
label define chsurv_lbl 04 `"4"', add
label define chsurv_lbl 05 `"5"', add
label define chsurv_lbl 06 `"6"', add
label define chsurv_lbl 07 `"7"', add
label define chsurv_lbl 08 `"8"', add
label define chsurv_lbl 09 `"9"', add
label define chsurv_lbl 10 `"10"', add
label define chsurv_lbl 11 `"11"', add
label define chsurv_lbl 12 `"12"', add
label define chsurv_lbl 13 `"13"', add
label define chsurv_lbl 14 `"14"', add
label define chsurv_lbl 15 `"15"', add
label define chsurv_lbl 16 `"16"', add
label define chsurv_lbl 17 `"17"', add
label define chsurv_lbl 18 `"18"', add
label define chsurv_lbl 19 `"19"', add
label define chsurv_lbl 20 `"20"', add
label define chsurv_lbl 21 `"21"', add
label define chsurv_lbl 22 `"22"', add
label define chsurv_lbl 23 `"23"', add
label define chsurv_lbl 24 `"24"', add
label define chsurv_lbl 25 `"25"', add
label define chsurv_lbl 26 `"26"', add
label define chsurv_lbl 27 `"27"', add
label define chsurv_lbl 28 `"28"', add
label define chsurv_lbl 29 `"29"', add
label define chsurv_lbl 30 `"30+"', add
label define chsurv_lbl 98 `"Unknown"', add
label define chsurv_lbl 99 `"NIU (not in universe)"', add
label values chsurv chsurv_lbl

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

label define lit_lbl 0 `"NIU (not in universe)"'
label define lit_lbl 1 `"No, illiterate"', add
label define lit_lbl 2 `"Yes, literate"', add
label define lit_lbl 9 `"Unknown/missing"', add
label values lit lit_lbl

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

label define mig1_5_mx_lbl 484001 `"Aguascalientes"'
label define mig1_5_mx_lbl 484002 `"Baja California"', add
label define mig1_5_mx_lbl 484003 `"Baja California Sur"', add
label define mig1_5_mx_lbl 484004 `"Campeche"', add
label define mig1_5_mx_lbl 484005 `"Coahuila"', add
label define mig1_5_mx_lbl 484006 `"Colima"', add
label define mig1_5_mx_lbl 484007 `"Chiapas"', add
label define mig1_5_mx_lbl 484008 `"Chihuahua"', add
label define mig1_5_mx_lbl 484009 `"Distrito Federal"', add
label define mig1_5_mx_lbl 484010 `"Durango"', add
label define mig1_5_mx_lbl 484011 `"Guanajuato"', add
label define mig1_5_mx_lbl 484012 `"Guerrero"', add
label define mig1_5_mx_lbl 484013 `"Hidalgo"', add
label define mig1_5_mx_lbl 484014 `"Jalisco"', add
label define mig1_5_mx_lbl 484015 `"México"', add
label define mig1_5_mx_lbl 484016 `"Michoacán"', add
label define mig1_5_mx_lbl 484017 `"Morelos"', add
label define mig1_5_mx_lbl 484018 `"Nayarit"', add
label define mig1_5_mx_lbl 484019 `"Nuevo León"', add
label define mig1_5_mx_lbl 484020 `"Oaxaca"', add
label define mig1_5_mx_lbl 484021 `"Puebla"', add
label define mig1_5_mx_lbl 484022 `"Querétaro"', add
label define mig1_5_mx_lbl 484023 `"Quintana Roo"', add
label define mig1_5_mx_lbl 484024 `"San Luis Potosí"', add
label define mig1_5_mx_lbl 484025 `"Sinaloa"', add
label define mig1_5_mx_lbl 484026 `"Sonora"', add
label define mig1_5_mx_lbl 484027 `"Tabasco"', add
label define mig1_5_mx_lbl 484028 `"Tamaulipas"', add
label define mig1_5_mx_lbl 484029 `"Tlaxcala"', add
label define mig1_5_mx_lbl 484030 `"Veracruz"', add
label define mig1_5_mx_lbl 484031 `"Yucatán"', add
label define mig1_5_mx_lbl 484032 `"Zacatecas"', add
label define mig1_5_mx_lbl 484097 `"Abroad"', add
label define mig1_5_mx_lbl 484098 `"Unknown"', add
label define mig1_5_mx_lbl 484099 `"NIU (not in universe)"', add
label values mig1_5_mx mig1_5_mx_lbl

label define hlthcov_lbl 10 `"IMSS only"'
label define hlthcov_lbl 20 `"ISSSTE only"', add
label define hlthcov_lbl 30 `"Pemex, military, or naval coverage only"', add
label define hlthcov_lbl 40 `"Public insurance (New Generation)"', add
label define hlthcov_lbl 50 `"Other coverage only"', add
label define hlthcov_lbl 60 `"Multiple sources of coverage"', add
label define hlthcov_lbl 61 `"IMSS and ISSSTE"', add
label define hlthcov_lbl 62 `"IMSS and Pemex, military, or naval"', add
label define hlthcov_lbl 63 `"IMSS and public insurance (New Generation)"', add
label define hlthcov_lbl 64 `"IMSS and other"', add
label define hlthcov_lbl 65 `"ISSSTE and Pemex, military, or naval"', add
label define hlthcov_lbl 66 `"ISSSTE and public insurance (New Generation)"', add
label define hlthcov_lbl 67 `"ISSSTE and other"', add
label define hlthcov_lbl 68 `"Pemex, military, or naval, and public insurance (New Generation)"', add
label define hlthcov_lbl 69 `"Pemex, military, or naval, and other"', add
label define hlthcov_lbl 70 `"Public insurance (New Generation) and other"', add
label define hlthcov_lbl 71 `"Other (multiple sources)"', add
label define hlthcov_lbl 72 `"IMSS, ISSSTE, and Pemex, military, or naval"', add
label define hlthcov_lbl 73 `"IMSS, ISSSTE, and other"', add
label define hlthcov_lbl 74 `"IMSS, ISSSTE, Pemex, military, or naval, and other"', add
label define hlthcov_lbl 90 `"No coverage"', add
label define hlthcov_lbl 99 `"Unknown"', add
label values hlthcov hlthcov_lbl

label define mx2010a_momhh_lbl 1 `"Mother lives in this household"'
label define mx2010a_momhh_lbl 2 `"Mother does not live in this household"', add
label define mx2010a_momhh_lbl 9 `"Unknown"', add
label values mx2010a_momhh mx2010a_momhh_lbl

label define mx2010a_pophh_lbl 1 `"Father lives in this household"'
label define mx2010a_pophh_lbl 2 `"The father does not live in this household"', add
label define mx2010a_pophh_lbl 9 `"Unknown"', add
label values mx2010a_pophh mx2010a_pophh_lbl

label define mx2010a_migstat5_lbl 01 `"Aguascalientes"'
label define mx2010a_migstat5_lbl 02 `"Baja California"', add
label define mx2010a_migstat5_lbl 03 `"Baja California Sur"', add
label define mx2010a_migstat5_lbl 04 `"Campeche"', add
label define mx2010a_migstat5_lbl 05 `"Coahuila de Zaragoza"', add
label define mx2010a_migstat5_lbl 06 `"Colima"', add
label define mx2010a_migstat5_lbl 07 `"Chiapas"', add
label define mx2010a_migstat5_lbl 08 `"Chihuahua"', add
label define mx2010a_migstat5_lbl 09 `"Distrito Federal"', add
label define mx2010a_migstat5_lbl 10 `"Durango"', add
label define mx2010a_migstat5_lbl 11 `"Guanajuato"', add
label define mx2010a_migstat5_lbl 12 `"Guerrero"', add
label define mx2010a_migstat5_lbl 13 `"Hidalgo"', add
label define mx2010a_migstat5_lbl 14 `"Jalisco"', add
label define mx2010a_migstat5_lbl 15 `"México"', add
label define mx2010a_migstat5_lbl 16 `"Michoacán de Ocampo"', add
label define mx2010a_migstat5_lbl 17 `"Morelos"', add
label define mx2010a_migstat5_lbl 18 `"Nayarit"', add
label define mx2010a_migstat5_lbl 19 `"Nuevo León"', add
label define mx2010a_migstat5_lbl 20 `"Oaxaca"', add
label define mx2010a_migstat5_lbl 21 `"Puebla"', add
label define mx2010a_migstat5_lbl 22 `"Querétaro"', add
label define mx2010a_migstat5_lbl 23 `"Quintana Roo"', add
label define mx2010a_migstat5_lbl 24 `"San Luis Potosí"', add
label define mx2010a_migstat5_lbl 25 `"Sinaloa"', add
label define mx2010a_migstat5_lbl 26 `"Sonora"', add
label define mx2010a_migstat5_lbl 27 `"Tabasco"', add
label define mx2010a_migstat5_lbl 28 `"Tamaulipas"', add
label define mx2010a_migstat5_lbl 29 `"Tlaxcala"', add
label define mx2010a_migstat5_lbl 30 `"Veracruz de Ignacio de la Llave"', add
label define mx2010a_migstat5_lbl 31 `"Yucatán"', add
label define mx2010a_migstat5_lbl 32 `"Zacatecas"', add
label define mx2010a_migstat5_lbl 97 `"Abroad"', add
label define mx2010a_migstat5_lbl 98 `"Unknown"', add
label define mx2010a_migstat5_lbl 99 `"NIU (not in universe)"', add
label values mx2010a_migstat5 mx2010a_migstat5_lbl

label define mx2010a_migmuni5_lbl 01001 `"Aguascalientes"'
label define mx2010a_migmuni5_lbl 01002 `"Asientos"', add
label define mx2010a_migmuni5_lbl 01003 `"Calvillo"', add
label define mx2010a_migmuni5_lbl 01004 `"Cosío"', add
label define mx2010a_migmuni5_lbl 01005 `"Jesús María"', add
label define mx2010a_migmuni5_lbl 01006 `"Pabellón de Arteaga"', add
label define mx2010a_migmuni5_lbl 01007 `"Rincón de Romos"', add
label define mx2010a_migmuni5_lbl 01008 `"San José de Gracia"', add
label define mx2010a_migmuni5_lbl 01009 `"Tepezalá"', add
label define mx2010a_migmuni5_lbl 01010 `"El Llano"', add
label define mx2010a_migmuni5_lbl 01011 `"San Francisco de los Romo"', add
label define mx2010a_migmuni5_lbl 01999 `"Aguascalientes entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 02001 `"Ensenada"', add
label define mx2010a_migmuni5_lbl 02002 `"Mexicali"', add
label define mx2010a_migmuni5_lbl 02003 `"Tecate"', add
label define mx2010a_migmuni5_lbl 02004 `"Tijuana"', add
label define mx2010a_migmuni5_lbl 02005 `"Playas de Rosarito"', add
label define mx2010a_migmuni5_lbl 02999 `"Baja California entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 03001 `"Comondú"', add
label define mx2010a_migmuni5_lbl 03002 `"Mulegé"', add
label define mx2010a_migmuni5_lbl 03003 `"La Paz"', add
label define mx2010a_migmuni5_lbl 03008 `"Los Cabos"', add
label define mx2010a_migmuni5_lbl 03009 `"Loreto"', add
label define mx2010a_migmuni5_lbl 03999 `"Baja California Sur entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 04001 `"Calkiní"', add
label define mx2010a_migmuni5_lbl 04002 `"Campeche"', add
label define mx2010a_migmuni5_lbl 04003 `"Carmen"', add
label define mx2010a_migmuni5_lbl 04004 `"Champotón"', add
label define mx2010a_migmuni5_lbl 04005 `"Hecelchakán"', add
label define mx2010a_migmuni5_lbl 04006 `"Hopelchén"', add
label define mx2010a_migmuni5_lbl 04007 `"Palizada"', add
label define mx2010a_migmuni5_lbl 04008 `"Tenabo"', add
label define mx2010a_migmuni5_lbl 04009 `"Escárcega"', add
label define mx2010a_migmuni5_lbl 04010 `"Calakmul"', add
label define mx2010a_migmuni5_lbl 04011 `"Candelaria"', add
label define mx2010a_migmuni5_lbl 04999 `"Campeche entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 05001 `"Abasolo"', add
label define mx2010a_migmuni5_lbl 05002 `"Acuña"', add
label define mx2010a_migmuni5_lbl 05003 `"Allende"', add
label define mx2010a_migmuni5_lbl 05004 `"Arteaga"', add
label define mx2010a_migmuni5_lbl 05005 `"Candela"', add
label define mx2010a_migmuni5_lbl 05006 `"Castaños"', add
label define mx2010a_migmuni5_lbl 05007 `"Cuatro Ciénegas"', add
label define mx2010a_migmuni5_lbl 05008 `"Escobedo"', add
label define mx2010a_migmuni5_lbl 05009 `"Francisco I. Madero"', add
label define mx2010a_migmuni5_lbl 05010 `"Frontera"', add
label define mx2010a_migmuni5_lbl 05011 `"General Cepeda"', add
label define mx2010a_migmuni5_lbl 05012 `"Guerrero"', add
label define mx2010a_migmuni5_lbl 05013 `"Hidalgo"', add
label define mx2010a_migmuni5_lbl 05014 `"Jiménez"', add
label define mx2010a_migmuni5_lbl 05015 `"Juárez"', add
label define mx2010a_migmuni5_lbl 05016 `"Lamadrid"', add
label define mx2010a_migmuni5_lbl 05017 `"Matamoros"', add
label define mx2010a_migmuni5_lbl 05018 `"Monclova"', add
label define mx2010a_migmuni5_lbl 05019 `"Morelos"', add
label define mx2010a_migmuni5_lbl 05020 `"Múzquiz"', add
label define mx2010a_migmuni5_lbl 05021 `"Nadadores"', add
label define mx2010a_migmuni5_lbl 05022 `"Nava"', add
label define mx2010a_migmuni5_lbl 05023 `"Ocampo"', add
label define mx2010a_migmuni5_lbl 05024 `"Parras"', add
label define mx2010a_migmuni5_lbl 05025 `"Piedras Negras"', add
label define mx2010a_migmuni5_lbl 05026 `"Progreso"', add
label define mx2010a_migmuni5_lbl 05027 `"Ramos Arizpe"', add
label define mx2010a_migmuni5_lbl 05028 `"Sabinas"', add
label define mx2010a_migmuni5_lbl 05029 `"Sacramento"', add
label define mx2010a_migmuni5_lbl 05030 `"Saltillo"', add
label define mx2010a_migmuni5_lbl 05031 `"San Buenaventura"', add
label define mx2010a_migmuni5_lbl 05032 `"San Juan de Sabinas"', add
label define mx2010a_migmuni5_lbl 05033 `"San Pedro"', add
label define mx2010a_migmuni5_lbl 05034 `"Sierra Mojada"', add
label define mx2010a_migmuni5_lbl 05035 `"Torreón"', add
label define mx2010a_migmuni5_lbl 05036 `"Viesca"', add
label define mx2010a_migmuni5_lbl 05037 `"Villa Unión"', add
label define mx2010a_migmuni5_lbl 05038 `"Zaragoza"', add
label define mx2010a_migmuni5_lbl 05999 `"Coahuila de Zaragoza entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 06001 `"Armería"', add
label define mx2010a_migmuni5_lbl 06002 `"Colima"', add
label define mx2010a_migmuni5_lbl 06003 `"Comala"', add
label define mx2010a_migmuni5_lbl 06004 `"Coquimatlán"', add
label define mx2010a_migmuni5_lbl 06005 `"Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 06006 `"Ixtlahuacán"', add
label define mx2010a_migmuni5_lbl 06007 `"Manzanillo"', add
label define mx2010a_migmuni5_lbl 06008 `"Minatitlán"', add
label define mx2010a_migmuni5_lbl 06009 `"Tecomán"', add
label define mx2010a_migmuni5_lbl 06010 `"Villa de Álvarez"', add
label define mx2010a_migmuni5_lbl 06999 `"Colima entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 07001 `"Acacoyagua"', add
label define mx2010a_migmuni5_lbl 07002 `"Acala"', add
label define mx2010a_migmuni5_lbl 07003 `"Acapetahua"', add
label define mx2010a_migmuni5_lbl 07004 `"Altamirano"', add
label define mx2010a_migmuni5_lbl 07005 `"Amatán"', add
label define mx2010a_migmuni5_lbl 07006 `"Amatenango de la Frontera"', add
label define mx2010a_migmuni5_lbl 07007 `"Amatenango del Valle"', add
label define mx2010a_migmuni5_lbl 07008 `"Angel Albino Corzo"', add
label define mx2010a_migmuni5_lbl 07009 `"Arriaga"', add
label define mx2010a_migmuni5_lbl 07010 `"Bejucal de Ocampo"', add
label define mx2010a_migmuni5_lbl 07011 `"Bella Vista"', add
label define mx2010a_migmuni5_lbl 07012 `"Berriozábal"', add
label define mx2010a_migmuni5_lbl 07013 `"Bochil"', add
label define mx2010a_migmuni5_lbl 07014 `"El Bosque"', add
label define mx2010a_migmuni5_lbl 07015 `"Cacahoatán"', add
label define mx2010a_migmuni5_lbl 07016 `"Catazajá"', add
label define mx2010a_migmuni5_lbl 07017 `"Cintalapa"', add
label define mx2010a_migmuni5_lbl 07018 `"Coapilla"', add
label define mx2010a_migmuni5_lbl 07019 `"Comitán de Domínguez"', add
label define mx2010a_migmuni5_lbl 07020 `"La Concordia"', add
label define mx2010a_migmuni5_lbl 07021 `"Copainalá"', add
label define mx2010a_migmuni5_lbl 07022 `"Chalchihuitán"', add
label define mx2010a_migmuni5_lbl 07023 `"Chamula"', add
label define mx2010a_migmuni5_lbl 07024 `"Chanal"', add
label define mx2010a_migmuni5_lbl 07025 `"Chapultenango"', add
label define mx2010a_migmuni5_lbl 07026 `"Chenalhó"', add
label define mx2010a_migmuni5_lbl 07027 `"Chiapa de Corzo"', add
label define mx2010a_migmuni5_lbl 07028 `"Chiapilla"', add
label define mx2010a_migmuni5_lbl 07029 `"Chicoasén"', add
label define mx2010a_migmuni5_lbl 07030 `"Chicomuselo"', add
label define mx2010a_migmuni5_lbl 07031 `"Chilón"', add
label define mx2010a_migmuni5_lbl 07032 `"Escuintla"', add
label define mx2010a_migmuni5_lbl 07033 `"Francisco León"', add
label define mx2010a_migmuni5_lbl 07034 `"Frontera Comalapa"', add
label define mx2010a_migmuni5_lbl 07035 `"Frontera Hidalgo"', add
label define mx2010a_migmuni5_lbl 07036 `"La Grandeza"', add
label define mx2010a_migmuni5_lbl 07037 `"Huehuetán"', add
label define mx2010a_migmuni5_lbl 07038 `"Huixtán"', add
label define mx2010a_migmuni5_lbl 07039 `"Huitiupán"', add
label define mx2010a_migmuni5_lbl 07040 `"Huixtla"', add
label define mx2010a_migmuni5_lbl 07041 `"La Independencia"', add
label define mx2010a_migmuni5_lbl 07042 `"Ixhuatán"', add
label define mx2010a_migmuni5_lbl 07043 `"Ixtacomitán"', add
label define mx2010a_migmuni5_lbl 07044 `"Ixtapa"', add
label define mx2010a_migmuni5_lbl 07045 `"Ixtapangajoya"', add
label define mx2010a_migmuni5_lbl 07046 `"Jiquipilas"', add
label define mx2010a_migmuni5_lbl 07047 `"Jitotol"', add
label define mx2010a_migmuni5_lbl 07048 `"Juárez"', add
label define mx2010a_migmuni5_lbl 07049 `"Larráinzar"', add
label define mx2010a_migmuni5_lbl 07050 `"La Libertad"', add
label define mx2010a_migmuni5_lbl 07051 `"Mapastepec"', add
label define mx2010a_migmuni5_lbl 07052 `"Las Margaritas"', add
label define mx2010a_migmuni5_lbl 07053 `"Mazapa de Madero"', add
label define mx2010a_migmuni5_lbl 07054 `"Mazatán"', add
label define mx2010a_migmuni5_lbl 07055 `"Metapa"', add
label define mx2010a_migmuni5_lbl 07056 `"Mitontic"', add
label define mx2010a_migmuni5_lbl 07057 `"Motozintla"', add
label define mx2010a_migmuni5_lbl 07058 `"Nicolás Ruíz"', add
label define mx2010a_migmuni5_lbl 07059 `"Ocosingo"', add
label define mx2010a_migmuni5_lbl 07060 `"Ocotepec"', add
label define mx2010a_migmuni5_lbl 07061 `"Ocozocoautla de Espinosa"', add
label define mx2010a_migmuni5_lbl 07062 `"Ostuacán"', add
label define mx2010a_migmuni5_lbl 07063 `"Osumacinta"', add
label define mx2010a_migmuni5_lbl 07064 `"Oxchuc"', add
label define mx2010a_migmuni5_lbl 07065 `"Palenque"', add
label define mx2010a_migmuni5_lbl 07066 `"Pantelhó"', add
label define mx2010a_migmuni5_lbl 07067 `"Pantepec"', add
label define mx2010a_migmuni5_lbl 07068 `"Pichucalco"', add
label define mx2010a_migmuni5_lbl 07069 `"Pijijiapan"', add
label define mx2010a_migmuni5_lbl 07070 `"El Porvenir"', add
label define mx2010a_migmuni5_lbl 07071 `"Villa Comaltitlán"', add
label define mx2010a_migmuni5_lbl 07072 `"Pueblo Nuevo Solistahuacán"', add
label define mx2010a_migmuni5_lbl 07073 `"Rayón"', add
label define mx2010a_migmuni5_lbl 07074 `"Reforma"', add
label define mx2010a_migmuni5_lbl 07075 `"Las Rosas"', add
label define mx2010a_migmuni5_lbl 07076 `"Sabanilla"', add
label define mx2010a_migmuni5_lbl 07077 `"Salto de Agua"', add
label define mx2010a_migmuni5_lbl 07078 `"San Cristóbal de las Casas"', add
label define mx2010a_migmuni5_lbl 07079 `"San Fernando"', add
label define mx2010a_migmuni5_lbl 07080 `"Siltepec"', add
label define mx2010a_migmuni5_lbl 07081 `"Simojovel"', add
label define mx2010a_migmuni5_lbl 07082 `"Sitalá"', add
label define mx2010a_migmuni5_lbl 07083 `"Socoltenango"', add
label define mx2010a_migmuni5_lbl 07084 `"Solosuchiapa"', add
label define mx2010a_migmuni5_lbl 07085 `"Soyaló"', add
label define mx2010a_migmuni5_lbl 07086 `"Suchiapa"', add
label define mx2010a_migmuni5_lbl 07087 `"Suchiate"', add
label define mx2010a_migmuni5_lbl 07088 `"Sunuapa"', add
label define mx2010a_migmuni5_lbl 07089 `"Tapachula"', add
label define mx2010a_migmuni5_lbl 07090 `"Tapalapa"', add
label define mx2010a_migmuni5_lbl 07091 `"Tapilula"', add
label define mx2010a_migmuni5_lbl 07092 `"Tecpatán"', add
label define mx2010a_migmuni5_lbl 07093 `"Tenejapa"', add
label define mx2010a_migmuni5_lbl 07094 `"Teopisca"', add
label define mx2010a_migmuni5_lbl 07096 `"Tila"', add
label define mx2010a_migmuni5_lbl 07097 `"Tonalá"', add
label define mx2010a_migmuni5_lbl 07098 `"Totolapa"', add
label define mx2010a_migmuni5_lbl 07099 `"La Trinitaria"', add
label define mx2010a_migmuni5_lbl 07100 `"Tumbalá"', add
label define mx2010a_migmuni5_lbl 07101 `"Tuxtla Gutiérrez"', add
label define mx2010a_migmuni5_lbl 07102 `"Tuxtla Chico"', add
label define mx2010a_migmuni5_lbl 07103 `"Tuzantán"', add
label define mx2010a_migmuni5_lbl 07104 `"Tzimol"', add
label define mx2010a_migmuni5_lbl 07105 `"Unión Juárez"', add
label define mx2010a_migmuni5_lbl 07106 `"Venustiano Carranza"', add
label define mx2010a_migmuni5_lbl 07107 `"Villa Corzo"', add
label define mx2010a_migmuni5_lbl 07108 `"Villaflores"', add
label define mx2010a_migmuni5_lbl 07109 `"Yajalón"', add
label define mx2010a_migmuni5_lbl 07110 `"San Lucas"', add
label define mx2010a_migmuni5_lbl 07111 `"Zinacantán"', add
label define mx2010a_migmuni5_lbl 07112 `"San Juan Cancuc"', add
label define mx2010a_migmuni5_lbl 07113 `"Aldama"', add
label define mx2010a_migmuni5_lbl 07114 `"Benemérito de las Américas"', add
label define mx2010a_migmuni5_lbl 07115 `"Maravilla Tenejapa"', add
label define mx2010a_migmuni5_lbl 07116 `"Marqués de Comillas"', add
label define mx2010a_migmuni5_lbl 07117 `"Montecristo de Guerrero"', add
label define mx2010a_migmuni5_lbl 07118 `"San Andrés Duraznal"', add
label define mx2010a_migmuni5_lbl 07119 `"Santiago el Pinar"', add
label define mx2010a_migmuni5_lbl 07999 `"Chiapas entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 08001 `"Ahumada"', add
label define mx2010a_migmuni5_lbl 08002 `"Aldama"', add
label define mx2010a_migmuni5_lbl 08003 `"Allende"', add
label define mx2010a_migmuni5_lbl 08004 `"Aquiles Serdán"', add
label define mx2010a_migmuni5_lbl 08005 `"Ascensión"', add
label define mx2010a_migmuni5_lbl 08006 `"Bachíniva"', add
label define mx2010a_migmuni5_lbl 08007 `"Balleza"', add
label define mx2010a_migmuni5_lbl 08008 `"Batopilas"', add
label define mx2010a_migmuni5_lbl 08009 `"Bocoyna"', add
label define mx2010a_migmuni5_lbl 08010 `"Buenaventura"', add
label define mx2010a_migmuni5_lbl 08011 `"Camargo"', add
label define mx2010a_migmuni5_lbl 08012 `"Carichí"', add
label define mx2010a_migmuni5_lbl 08013 `"Casas Grandes"', add
label define mx2010a_migmuni5_lbl 08014 `"Coronado"', add
label define mx2010a_migmuni5_lbl 08015 `"Coyame del Sotol"', add
label define mx2010a_migmuni5_lbl 08016 `"La Cruz"', add
label define mx2010a_migmuni5_lbl 08017 `"Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 08018 `"Cusihuiriachi"', add
label define mx2010a_migmuni5_lbl 08019 `"Chihuahua"', add
label define mx2010a_migmuni5_lbl 08020 `"Chínipas"', add
label define mx2010a_migmuni5_lbl 08021 `"Delicias"', add
label define mx2010a_migmuni5_lbl 08022 `"Dr. Belisario Domínguez"', add
label define mx2010a_migmuni5_lbl 08023 `"Galeana"', add
label define mx2010a_migmuni5_lbl 08024 `"Santa Isabel"', add
label define mx2010a_migmuni5_lbl 08025 `"Gómez Farías"', add
label define mx2010a_migmuni5_lbl 08026 `"Gran Morelos"', add
label define mx2010a_migmuni5_lbl 08027 `"Guachochi"', add
label define mx2010a_migmuni5_lbl 08028 `"Guadalupe"', add
label define mx2010a_migmuni5_lbl 08029 `"Guadalupe y Calvo"', add
label define mx2010a_migmuni5_lbl 08030 `"Guazapares"', add
label define mx2010a_migmuni5_lbl 08031 `"Guerrero"', add
label define mx2010a_migmuni5_lbl 08032 `"Hidalgo del Parral"', add
label define mx2010a_migmuni5_lbl 08033 `"Huejotitán"', add
label define mx2010a_migmuni5_lbl 08034 `"Ignacio Zaragoza"', add
label define mx2010a_migmuni5_lbl 08035 `"Janos"', add
label define mx2010a_migmuni5_lbl 08036 `"Jiménez"', add
label define mx2010a_migmuni5_lbl 08037 `"Juárez"', add
label define mx2010a_migmuni5_lbl 08038 `"Julimes"', add
label define mx2010a_migmuni5_lbl 08039 `"López"', add
label define mx2010a_migmuni5_lbl 08040 `"Madera"', add
label define mx2010a_migmuni5_lbl 08041 `"Maguarichi"', add
label define mx2010a_migmuni5_lbl 08042 `"Manuel Benavides"', add
label define mx2010a_migmuni5_lbl 08043 `"Matachí"', add
label define mx2010a_migmuni5_lbl 08044 `"Matamoros"', add
label define mx2010a_migmuni5_lbl 08045 `"Meoqui"', add
label define mx2010a_migmuni5_lbl 08046 `"Morelos"', add
label define mx2010a_migmuni5_lbl 08047 `"Moris"', add
label define mx2010a_migmuni5_lbl 08048 `"Namiquipa"', add
label define mx2010a_migmuni5_lbl 08049 `"Nonoava"', add
label define mx2010a_migmuni5_lbl 08050 `"Nuevo Casas Grandes"', add
label define mx2010a_migmuni5_lbl 08051 `"Ocampo"', add
label define mx2010a_migmuni5_lbl 08052 `"Ojinaga"', add
label define mx2010a_migmuni5_lbl 08053 `"Praxedis G. Guerrero"', add
label define mx2010a_migmuni5_lbl 08054 `"Riva Palacio"', add
label define mx2010a_migmuni5_lbl 08055 `"Rosales"', add
label define mx2010a_migmuni5_lbl 08056 `"Rosario"', add
label define mx2010a_migmuni5_lbl 08057 `"San Francisco de Borja"', add
label define mx2010a_migmuni5_lbl 08058 `"San Francisco de Conchos"', add
label define mx2010a_migmuni5_lbl 08059 `"San Francisco del Oro"', add
label define mx2010a_migmuni5_lbl 08060 `"Santa Bárbara"', add
label define mx2010a_migmuni5_lbl 08061 `"Satevó"', add
label define mx2010a_migmuni5_lbl 08062 `"Saucillo"', add
label define mx2010a_migmuni5_lbl 08063 `"Temósachic"', add
label define mx2010a_migmuni5_lbl 08064 `"El Tule"', add
label define mx2010a_migmuni5_lbl 08065 `"Urique"', add
label define mx2010a_migmuni5_lbl 08066 `"Uruachi"', add
label define mx2010a_migmuni5_lbl 08067 `"Valle de Zaragoza"', add
label define mx2010a_migmuni5_lbl 08999 `"Chihuahua entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 09002 `"Azcapotzalco"', add
label define mx2010a_migmuni5_lbl 09003 `"Coyoacán"', add
label define mx2010a_migmuni5_lbl 09004 `"Cuajimalpa de Morelos"', add
label define mx2010a_migmuni5_lbl 09005 `"Gustavo A. Madero"', add
label define mx2010a_migmuni5_lbl 09006 `"Iztacalco"', add
label define mx2010a_migmuni5_lbl 09007 `"Iztapalapa"', add
label define mx2010a_migmuni5_lbl 09008 `"La Magdalena Contreras"', add
label define mx2010a_migmuni5_lbl 09009 `"Milpa Alta"', add
label define mx2010a_migmuni5_lbl 09010 `"Álvaro Obregón"', add
label define mx2010a_migmuni5_lbl 09011 `"Tláhuac"', add
label define mx2010a_migmuni5_lbl 09012 `"Tlalpan"', add
label define mx2010a_migmuni5_lbl 09013 `"Xochimilco"', add
label define mx2010a_migmuni5_lbl 09014 `"Benito Juárez"', add
label define mx2010a_migmuni5_lbl 09015 `"Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 09016 `"Miguel Hidalgo"', add
label define mx2010a_migmuni5_lbl 09017 `"Venustiano Carranza"', add
label define mx2010a_migmuni5_lbl 09999 `"Distrito Federal entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 10001 `"Canatlán"', add
label define mx2010a_migmuni5_lbl 10002 `"Canelas"', add
label define mx2010a_migmuni5_lbl 10003 `"Coneto de Comonfort"', add
label define mx2010a_migmuni5_lbl 10004 `"Cuencamé"', add
label define mx2010a_migmuni5_lbl 10005 `"Durango"', add
label define mx2010a_migmuni5_lbl 10006 `"General Simón Bolívar"', add
label define mx2010a_migmuni5_lbl 10007 `"Gómez Palacio"', add
label define mx2010a_migmuni5_lbl 10008 `"Guadalupe Victoria"', add
label define mx2010a_migmuni5_lbl 10009 `"Guanaceví"', add
label define mx2010a_migmuni5_lbl 10010 `"Hidalgo"', add
label define mx2010a_migmuni5_lbl 10011 `"Indé"', add
label define mx2010a_migmuni5_lbl 10012 `"Lerdo"', add
label define mx2010a_migmuni5_lbl 10013 `"Mapimí"', add
label define mx2010a_migmuni5_lbl 10014 `"Mezquital"', add
label define mx2010a_migmuni5_lbl 10015 `"Nazas"', add
label define mx2010a_migmuni5_lbl 10016 `"Nombre de Dios"', add
label define mx2010a_migmuni5_lbl 10017 `"Ocampo"', add
label define mx2010a_migmuni5_lbl 10018 `"El Oro"', add
label define mx2010a_migmuni5_lbl 10019 `"Otáez"', add
label define mx2010a_migmuni5_lbl 10020 `"Pánuco de Coronado"', add
label define mx2010a_migmuni5_lbl 10021 `"Peñón Blanco"', add
label define mx2010a_migmuni5_lbl 10022 `"Poanas"', add
label define mx2010a_migmuni5_lbl 10023 `"Pueblo Nuevo"', add
label define mx2010a_migmuni5_lbl 10024 `"Rodeo"', add
label define mx2010a_migmuni5_lbl 10025 `"San Bernardo"', add
label define mx2010a_migmuni5_lbl 10026 `"San Dimas"', add
label define mx2010a_migmuni5_lbl 10027 `"San Juan de Guadalupe"', add
label define mx2010a_migmuni5_lbl 10028 `"San Juan del Río"', add
label define mx2010a_migmuni5_lbl 10029 `"San Luis del Cordero"', add
label define mx2010a_migmuni5_lbl 10030 `"San Pedro del Gallo"', add
label define mx2010a_migmuni5_lbl 10031 `"Santa Clara"', add
label define mx2010a_migmuni5_lbl 10032 `"Santiago Papasquiaro"', add
label define mx2010a_migmuni5_lbl 10033 `"Súchil"', add
label define mx2010a_migmuni5_lbl 10034 `"Tamazula"', add
label define mx2010a_migmuni5_lbl 10035 `"Tepehuanes"', add
label define mx2010a_migmuni5_lbl 10036 `"Tlahualilo"', add
label define mx2010a_migmuni5_lbl 10037 `"Topia"', add
label define mx2010a_migmuni5_lbl 10038 `"Vicente Guerrero"', add
label define mx2010a_migmuni5_lbl 10039 `"Nuevo Ideal"', add
label define mx2010a_migmuni5_lbl 10999 `"Durango entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 11001 `"Abasolo"', add
label define mx2010a_migmuni5_lbl 11002 `"Acámbaro"', add
label define mx2010a_migmuni5_lbl 11003 `"San Miguel de Allende"', add
label define mx2010a_migmuni5_lbl 11004 `"Apaseo el Alto"', add
label define mx2010a_migmuni5_lbl 11005 `"Apaseo el Grande"', add
label define mx2010a_migmuni5_lbl 11006 `"Atarjea"', add
label define mx2010a_migmuni5_lbl 11007 `"Celaya"', add
label define mx2010a_migmuni5_lbl 11008 `"Manuel Doblado"', add
label define mx2010a_migmuni5_lbl 11009 `"Comonfort"', add
label define mx2010a_migmuni5_lbl 11010 `"Coroneo"', add
label define mx2010a_migmuni5_lbl 11011 `"Cortazar"', add
label define mx2010a_migmuni5_lbl 11012 `"Cuerámaro"', add
label define mx2010a_migmuni5_lbl 11013 `"Doctor Mora"', add
label define mx2010a_migmuni5_lbl 11014 `"Dolores Hidalgo Cuna de la Independencia Nacional"', add
label define mx2010a_migmuni5_lbl 11015 `"Guanajuato"', add
label define mx2010a_migmuni5_lbl 11016 `"Huanímaro"', add
label define mx2010a_migmuni5_lbl 11017 `"Irapuato"', add
label define mx2010a_migmuni5_lbl 11018 `"Jaral del Progreso"', add
label define mx2010a_migmuni5_lbl 11019 `"Jerécuaro"', add
label define mx2010a_migmuni5_lbl 11020 `"León"', add
label define mx2010a_migmuni5_lbl 11021 `"Moroleón"', add
label define mx2010a_migmuni5_lbl 11022 `"Ocampo"', add
label define mx2010a_migmuni5_lbl 11023 `"Pénjamo"', add
label define mx2010a_migmuni5_lbl 11024 `"Pueblo Nuevo"', add
label define mx2010a_migmuni5_lbl 11025 `"Purísima del Rincón"', add
label define mx2010a_migmuni5_lbl 11026 `"Romita"', add
label define mx2010a_migmuni5_lbl 11027 `"Salamanca"', add
label define mx2010a_migmuni5_lbl 11028 `"Salvatierra"', add
label define mx2010a_migmuni5_lbl 11029 `"San Diego de la Unión"', add
label define mx2010a_migmuni5_lbl 11030 `"San Felipe"', add
label define mx2010a_migmuni5_lbl 11031 `"San Francisco del Rincón"', add
label define mx2010a_migmuni5_lbl 11032 `"San José Iturbide"', add
label define mx2010a_migmuni5_lbl 11033 `"San Luis de la Paz"', add
label define mx2010a_migmuni5_lbl 11034 `"Santa Catarina"', add
label define mx2010a_migmuni5_lbl 11035 `"Santa Cruz de Juventino Rosas"', add
label define mx2010a_migmuni5_lbl 11036 `"Santiago Maravatío"', add
label define mx2010a_migmuni5_lbl 11037 `"Silao"', add
label define mx2010a_migmuni5_lbl 11038 `"Tarandacuao"', add
label define mx2010a_migmuni5_lbl 11039 `"Tarimoro"', add
label define mx2010a_migmuni5_lbl 11040 `"Tierra Blanca"', add
label define mx2010a_migmuni5_lbl 11041 `"Uriangato"', add
label define mx2010a_migmuni5_lbl 11042 `"Valle de Santiago"', add
label define mx2010a_migmuni5_lbl 11043 `"Victoria"', add
label define mx2010a_migmuni5_lbl 11044 `"Villagrán"', add
label define mx2010a_migmuni5_lbl 11045 `"Xichú"', add
label define mx2010a_migmuni5_lbl 11046 `"Yuriria"', add
label define mx2010a_migmuni5_lbl 11999 `"Guanajuato entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 12001 `"Acapulco de Juárez"', add
label define mx2010a_migmuni5_lbl 12002 `"Ahuacuotzingo"', add
label define mx2010a_migmuni5_lbl 12003 `"Ajuchitlán del Progreso"', add
label define mx2010a_migmuni5_lbl 12004 `"Alcozauca de Guerrero"', add
label define mx2010a_migmuni5_lbl 12005 `"Alpoyeca"', add
label define mx2010a_migmuni5_lbl 12006 `"Apaxtla"', add
label define mx2010a_migmuni5_lbl 12007 `"Arcelia"', add
label define mx2010a_migmuni5_lbl 12008 `"Atenango del Río"', add
label define mx2010a_migmuni5_lbl 12009 `"Atlamajalcingo del Monte"', add
label define mx2010a_migmuni5_lbl 12010 `"Atlixtac"', add
label define mx2010a_migmuni5_lbl 12011 `"Atoyac de Álvarez"', add
label define mx2010a_migmuni5_lbl 12012 `"Ayutla de los Libres"', add
label define mx2010a_migmuni5_lbl 12013 `"Azoyú"', add
label define mx2010a_migmuni5_lbl 12014 `"Benito Juárez"', add
label define mx2010a_migmuni5_lbl 12015 `"Buenavista de Cuéllar"', add
label define mx2010a_migmuni5_lbl 12016 `"Coahuayutla de José María Izazaga"', add
label define mx2010a_migmuni5_lbl 12017 `"Cocula"', add
label define mx2010a_migmuni5_lbl 12018 `"Copala"', add
label define mx2010a_migmuni5_lbl 12019 `"Copalillo"', add
label define mx2010a_migmuni5_lbl 12020 `"Copanatoyac"', add
label define mx2010a_migmuni5_lbl 12021 `"Coyuca de Benítez"', add
label define mx2010a_migmuni5_lbl 12022 `"Coyuca de Catalán"', add
label define mx2010a_migmuni5_lbl 12023 `"Cuajinicuilapa"', add
label define mx2010a_migmuni5_lbl 12024 `"Cualác"', add
label define mx2010a_migmuni5_lbl 12025 `"Cuautepec"', add
label define mx2010a_migmuni5_lbl 12026 `"Cuetzala del Progreso"', add
label define mx2010a_migmuni5_lbl 12027 `"Cutzamala de Pinzón"', add
label define mx2010a_migmuni5_lbl 12028 `"Chilapa de Álvarez"', add
label define mx2010a_migmuni5_lbl 12029 `"Chilpancingo de los Bravo"', add
label define mx2010a_migmuni5_lbl 12030 `"Florencio Villarreal"', add
label define mx2010a_migmuni5_lbl 12031 `"General Canuto A. Neri"', add
label define mx2010a_migmuni5_lbl 12032 `"General Heliodoro Castillo"', add
label define mx2010a_migmuni5_lbl 12033 `"Huamuxtitlán"', add
label define mx2010a_migmuni5_lbl 12034 `"Huitzuco de los Figueroa"', add
label define mx2010a_migmuni5_lbl 12035 `"Iguala de la Independencia"', add
label define mx2010a_migmuni5_lbl 12036 `"Igualapa"', add
label define mx2010a_migmuni5_lbl 12037 `"Ixcateopan de Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 12038 `"Zihuatanejo de Azueta"', add
label define mx2010a_migmuni5_lbl 12039 `"Juan R. Escudero"', add
label define mx2010a_migmuni5_lbl 12040 `"Leonardo Bravo"', add
label define mx2010a_migmuni5_lbl 12041 `"Malinaltepec"', add
label define mx2010a_migmuni5_lbl 12042 `"Mártir de Cuilapan"', add
label define mx2010a_migmuni5_lbl 12043 `"Metlatónoc"', add
label define mx2010a_migmuni5_lbl 12044 `"Mochitlán"', add
label define mx2010a_migmuni5_lbl 12045 `"Olinalá"', add
label define mx2010a_migmuni5_lbl 12046 `"Ometepec"', add
label define mx2010a_migmuni5_lbl 12047 `"Pedro Ascencio Alquisiras"', add
label define mx2010a_migmuni5_lbl 12048 `"Petatlán"', add
label define mx2010a_migmuni5_lbl 12049 `"Pilcaya"', add
label define mx2010a_migmuni5_lbl 12050 `"Pungarabato"', add
label define mx2010a_migmuni5_lbl 12051 `"Quechultenango"', add
label define mx2010a_migmuni5_lbl 12052 `"San Luis Acatlán"', add
label define mx2010a_migmuni5_lbl 12053 `"San Marcos"', add
label define mx2010a_migmuni5_lbl 12054 `"San Miguel Totolapan"', add
label define mx2010a_migmuni5_lbl 12055 `"Taxco de Alarcón"', add
label define mx2010a_migmuni5_lbl 12056 `"Tecoanapa"', add
label define mx2010a_migmuni5_lbl 12057 `"Técpan de Galeana"', add
label define mx2010a_migmuni5_lbl 12058 `"Teloloapan"', add
label define mx2010a_migmuni5_lbl 12059 `"Tepecoacuilco de Trujano"', add
label define mx2010a_migmuni5_lbl 12060 `"Tetipac"', add
label define mx2010a_migmuni5_lbl 12061 `"Tixtla de Guerrero"', add
label define mx2010a_migmuni5_lbl 12062 `"Tlacoachistlahuaca"', add
label define mx2010a_migmuni5_lbl 12063 `"Tlacoapa"', add
label define mx2010a_migmuni5_lbl 12064 `"Tlalchapa"', add
label define mx2010a_migmuni5_lbl 12065 `"Tlalixtaquilla de Maldonado"', add
label define mx2010a_migmuni5_lbl 12066 `"Tlapa de Comonfort"', add
label define mx2010a_migmuni5_lbl 12067 `"Tlapehuala"', add
label define mx2010a_migmuni5_lbl 12068 `"La Unión de Isidoro Montes de Oca"', add
label define mx2010a_migmuni5_lbl 12069 `"Xalpatláhuac"', add
label define mx2010a_migmuni5_lbl 12070 `"Xochihuehuetlán"', add
label define mx2010a_migmuni5_lbl 12071 `"Xochistlahuaca"', add
label define mx2010a_migmuni5_lbl 12072 `"Zapotitlán Tablas"', add
label define mx2010a_migmuni5_lbl 12073 `"Zirándaro"', add
label define mx2010a_migmuni5_lbl 12074 `"Zitlala"', add
label define mx2010a_migmuni5_lbl 12075 `"Eduardo Neri"', add
label define mx2010a_migmuni5_lbl 12076 `"Acatepec"', add
label define mx2010a_migmuni5_lbl 12077 `"Marquelia"', add
label define mx2010a_migmuni5_lbl 12078 `"Cochoapa el Grande"', add
label define mx2010a_migmuni5_lbl 12079 `"José Joaquin de Herrera"', add
label define mx2010a_migmuni5_lbl 12080 `"Juchitán"', add
label define mx2010a_migmuni5_lbl 12081 `"Iliatenco"', add
label define mx2010a_migmuni5_lbl 12999 `"Guerrero entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 13001 `"Acatlán"', add
label define mx2010a_migmuni5_lbl 13002 `"Acaxochitlán"', add
label define mx2010a_migmuni5_lbl 13003 `"Actopan"', add
label define mx2010a_migmuni5_lbl 13004 `"Agua Blanca de Iturbide"', add
label define mx2010a_migmuni5_lbl 13005 `"Ajacuba"', add
label define mx2010a_migmuni5_lbl 13006 `"Alfajayucan"', add
label define mx2010a_migmuni5_lbl 13007 `"Almoloya"', add
label define mx2010a_migmuni5_lbl 13008 `"Apan"', add
label define mx2010a_migmuni5_lbl 13009 `"El Arenal"', add
label define mx2010a_migmuni5_lbl 13010 `"Atitalaquia"', add
label define mx2010a_migmuni5_lbl 13011 `"Atlapexco"', add
label define mx2010a_migmuni5_lbl 13012 `"Atotonilco el Grande"', add
label define mx2010a_migmuni5_lbl 13013 `"Atotonilco de Tula"', add
label define mx2010a_migmuni5_lbl 13014 `"Calnali"', add
label define mx2010a_migmuni5_lbl 13015 `"Cardonal"', add
label define mx2010a_migmuni5_lbl 13016 `"Cuautepec de Hinojosa"', add
label define mx2010a_migmuni5_lbl 13017 `"Chapantongo"', add
label define mx2010a_migmuni5_lbl 13018 `"Chapulhuacán"', add
label define mx2010a_migmuni5_lbl 13019 `"Chilcuautla"', add
label define mx2010a_migmuni5_lbl 13020 `"Eloxochitlán"', add
label define mx2010a_migmuni5_lbl 13021 `"Emiliano Zapata"', add
label define mx2010a_migmuni5_lbl 13022 `"Epazoyucan"', add
label define mx2010a_migmuni5_lbl 13023 `"Francisco I. Madero"', add
label define mx2010a_migmuni5_lbl 13024 `"Huasca de Ocampo"', add
label define mx2010a_migmuni5_lbl 13025 `"Huautla"', add
label define mx2010a_migmuni5_lbl 13026 `"Huazalingo"', add
label define mx2010a_migmuni5_lbl 13027 `"Huehuetla"', add
label define mx2010a_migmuni5_lbl 13028 `"Huejutla de Reyes"', add
label define mx2010a_migmuni5_lbl 13029 `"Huichapan"', add
label define mx2010a_migmuni5_lbl 13030 `"Ixmiquilpan"', add
label define mx2010a_migmuni5_lbl 13031 `"Jacala de Ledezma"', add
label define mx2010a_migmuni5_lbl 13032 `"Jaltocán"', add
label define mx2010a_migmuni5_lbl 13033 `"Juárez Hidalgo"', add
label define mx2010a_migmuni5_lbl 13034 `"Lolotla"', add
label define mx2010a_migmuni5_lbl 13035 `"Metepec"', add
label define mx2010a_migmuni5_lbl 13036 `"San Agustín Metzquititlán"', add
label define mx2010a_migmuni5_lbl 13037 `"Metztitlán"', add
label define mx2010a_migmuni5_lbl 13038 `"Mineral del Chico"', add
label define mx2010a_migmuni5_lbl 13039 `"Mineral del Monte"', add
label define mx2010a_migmuni5_lbl 13040 `"La Misión"', add
label define mx2010a_migmuni5_lbl 13041 `"Mixquiahuala de Juárez"', add
label define mx2010a_migmuni5_lbl 13042 `"Molango de Escamilla"', add
label define mx2010a_migmuni5_lbl 13043 `"Nicolás Flores"', add
label define mx2010a_migmuni5_lbl 13044 `"Nopala de Villagrán"', add
label define mx2010a_migmuni5_lbl 13045 `"Omitlán de Juárez"', add
label define mx2010a_migmuni5_lbl 13046 `"San Felipe Orizatlán"', add
label define mx2010a_migmuni5_lbl 13047 `"Pacula"', add
label define mx2010a_migmuni5_lbl 13048 `"Pachuca de Soto"', add
label define mx2010a_migmuni5_lbl 13049 `"Pisaflores"', add
label define mx2010a_migmuni5_lbl 13050 `"Progreso de Obregón"', add
label define mx2010a_migmuni5_lbl 13051 `"Mineral de la Reforma"', add
label define mx2010a_migmuni5_lbl 13052 `"San Agustín Tlaxiaca"', add
label define mx2010a_migmuni5_lbl 13053 `"San Bartolo Tutotepec"', add
label define mx2010a_migmuni5_lbl 13054 `"San Salvador"', add
label define mx2010a_migmuni5_lbl 13055 `"Santiago de Anaya"', add
label define mx2010a_migmuni5_lbl 13056 `"Santiago Tulantepec de Lugo Guerrero"', add
label define mx2010a_migmuni5_lbl 13057 `"Singuilucan"', add
label define mx2010a_migmuni5_lbl 13058 `"Tasquillo"', add
label define mx2010a_migmuni5_lbl 13059 `"Tecozautla"', add
label define mx2010a_migmuni5_lbl 13060 `"Tenango de Doria"', add
label define mx2010a_migmuni5_lbl 13061 `"Tepeapulco"', add
label define mx2010a_migmuni5_lbl 13062 `"Tepehuacán de Guerrero"', add
label define mx2010a_migmuni5_lbl 13063 `"Tepeji del Río de Ocampo"', add
label define mx2010a_migmuni5_lbl 13064 `"Tepetitlán"', add
label define mx2010a_migmuni5_lbl 13065 `"Tetepango"', add
label define mx2010a_migmuni5_lbl 13066 `"Villa de Tezontepec"', add
label define mx2010a_migmuni5_lbl 13067 `"Tezontepec de Aldama"', add
label define mx2010a_migmuni5_lbl 13068 `"Tianguistengo"', add
label define mx2010a_migmuni5_lbl 13069 `"Tizayuca"', add
label define mx2010a_migmuni5_lbl 13070 `"Tlahuelilpan"', add
label define mx2010a_migmuni5_lbl 13071 `"Tlahuiltepa"', add
label define mx2010a_migmuni5_lbl 13072 `"Tlanalapa"', add
label define mx2010a_migmuni5_lbl 13073 `"Tlanchinol"', add
label define mx2010a_migmuni5_lbl 13074 `"Tlaxcoapan"', add
label define mx2010a_migmuni5_lbl 13075 `"Tolcayuca"', add
label define mx2010a_migmuni5_lbl 13076 `"Tula de Allende"', add
label define mx2010a_migmuni5_lbl 13077 `"Tulancingo de Bravo"', add
label define mx2010a_migmuni5_lbl 13078 `"Xochiatipan"', add
label define mx2010a_migmuni5_lbl 13079 `"Xochicoatlán"', add
label define mx2010a_migmuni5_lbl 13080 `"Yahualica"', add
label define mx2010a_migmuni5_lbl 13081 `"Zacualtipán de Ángeles"', add
label define mx2010a_migmuni5_lbl 13082 `"Zapotlán de Juárez"', add
label define mx2010a_migmuni5_lbl 13083 `"Zempoala"', add
label define mx2010a_migmuni5_lbl 13084 `"Zimapán"', add
label define mx2010a_migmuni5_lbl 13999 `"Hidalgo entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 14001 `"Acatic"', add
label define mx2010a_migmuni5_lbl 14002 `"Acatlán de Juárez"', add
label define mx2010a_migmuni5_lbl 14003 `"Ahualulco de Mercado"', add
label define mx2010a_migmuni5_lbl 14004 `"Amacueca"', add
label define mx2010a_migmuni5_lbl 14005 `"Amatitán"', add
label define mx2010a_migmuni5_lbl 14006 `"Ameca"', add
label define mx2010a_migmuni5_lbl 14007 `"San Juanito de Escobedo"', add
label define mx2010a_migmuni5_lbl 14008 `"Arandas"', add
label define mx2010a_migmuni5_lbl 14009 `"El Arenal"', add
label define mx2010a_migmuni5_lbl 14010 `"Atemajac de Brizuela"', add
label define mx2010a_migmuni5_lbl 14011 `"Atengo"', add
label define mx2010a_migmuni5_lbl 14012 `"Atenguillo"', add
label define mx2010a_migmuni5_lbl 14013 `"Atotonilco el Alto"', add
label define mx2010a_migmuni5_lbl 14014 `"Atoyac"', add
label define mx2010a_migmuni5_lbl 14015 `"Autlán de Navarro"', add
label define mx2010a_migmuni5_lbl 14016 `"Ayotlán"', add
label define mx2010a_migmuni5_lbl 14017 `"Ayutla"', add
label define mx2010a_migmuni5_lbl 14018 `"La Barca"', add
label define mx2010a_migmuni5_lbl 14019 `"Bolaños"', add
label define mx2010a_migmuni5_lbl 14020 `"Cabo Corrientes"', add
label define mx2010a_migmuni5_lbl 14021 `"Casimiro Castillo"', add
label define mx2010a_migmuni5_lbl 14022 `"Cihuatlán"', add
label define mx2010a_migmuni5_lbl 14023 `"Zapotlán el Grande"', add
label define mx2010a_migmuni5_lbl 14024 `"Cocula"', add
label define mx2010a_migmuni5_lbl 14025 `"Colotlán"', add
label define mx2010a_migmuni5_lbl 14026 `"Concepción de Buenos Aires"', add
label define mx2010a_migmuni5_lbl 14027 `"Cuautitlán de García Barragán"', add
label define mx2010a_migmuni5_lbl 14028 `"Cuautla"', add
label define mx2010a_migmuni5_lbl 14029 `"Cuquío"', add
label define mx2010a_migmuni5_lbl 14030 `"Chapala"', add
label define mx2010a_migmuni5_lbl 14031 `"Chimaltitán"', add
label define mx2010a_migmuni5_lbl 14032 `"Chiquilistlán"', add
label define mx2010a_migmuni5_lbl 14033 `"Degollado"', add
label define mx2010a_migmuni5_lbl 14034 `"Ejutla"', add
label define mx2010a_migmuni5_lbl 14035 `"Encarnación de Díaz"', add
label define mx2010a_migmuni5_lbl 14036 `"Etzatlán"', add
label define mx2010a_migmuni5_lbl 14037 `"El Grullo"', add
label define mx2010a_migmuni5_lbl 14038 `"Guachinango"', add
label define mx2010a_migmuni5_lbl 14039 `"Guadalajara"', add
label define mx2010a_migmuni5_lbl 14040 `"Hostotipaquillo"', add
label define mx2010a_migmuni5_lbl 14041 `"Huejúcar"', add
label define mx2010a_migmuni5_lbl 14042 `"Huejuquilla el Alto"', add
label define mx2010a_migmuni5_lbl 14043 `"La Huerta"', add
label define mx2010a_migmuni5_lbl 14044 `"Ixtlahuacán de los Membrillos"', add
label define mx2010a_migmuni5_lbl 14045 `"Ixtlahuacán del Río"', add
label define mx2010a_migmuni5_lbl 14046 `"Jalostotitlán"', add
label define mx2010a_migmuni5_lbl 14047 `"Jamay"', add
label define mx2010a_migmuni5_lbl 14048 `"Jesús María"', add
label define mx2010a_migmuni5_lbl 14049 `"Jilotlán de los Dolores"', add
label define mx2010a_migmuni5_lbl 14050 `"Jocotepec"', add
label define mx2010a_migmuni5_lbl 14051 `"Juanacatlán"', add
label define mx2010a_migmuni5_lbl 14052 `"Juchitlán"', add
label define mx2010a_migmuni5_lbl 14053 `"Lagos de Moreno"', add
label define mx2010a_migmuni5_lbl 14054 `"El Limón"', add
label define mx2010a_migmuni5_lbl 14055 `"Magdalena"', add
label define mx2010a_migmuni5_lbl 14056 `"Santa María del Oro"', add
label define mx2010a_migmuni5_lbl 14057 `"La Manzanilla de la Paz"', add
label define mx2010a_migmuni5_lbl 14058 `"Mascota"', add
label define mx2010a_migmuni5_lbl 14059 `"Mazamitla"', add
label define mx2010a_migmuni5_lbl 14060 `"Mexticacán"', add
label define mx2010a_migmuni5_lbl 14061 `"Mezquitic"', add
label define mx2010a_migmuni5_lbl 14062 `"Mixtlán"', add
label define mx2010a_migmuni5_lbl 14063 `"Ocotlán"', add
label define mx2010a_migmuni5_lbl 14064 `"Ojuelos de Jalisco"', add
label define mx2010a_migmuni5_lbl 14065 `"Pihuamo"', add
label define mx2010a_migmuni5_lbl 14066 `"Poncitlán"', add
label define mx2010a_migmuni5_lbl 14067 `"Puerto Vallarta"', add
label define mx2010a_migmuni5_lbl 14068 `"Villa Purificación"', add
label define mx2010a_migmuni5_lbl 14069 `"Quitupan"', add
label define mx2010a_migmuni5_lbl 14070 `"El Salto"', add
label define mx2010a_migmuni5_lbl 14071 `"San Cristóbal de la Barranca"', add
label define mx2010a_migmuni5_lbl 14072 `"San Diego de Alejandría"', add
label define mx2010a_migmuni5_lbl 14073 `"San Juan de los Lagos"', add
label define mx2010a_migmuni5_lbl 14074 `"San Julián"', add
label define mx2010a_migmuni5_lbl 14075 `"San Marcos"', add
label define mx2010a_migmuni5_lbl 14076 `"San Martín de Bolaños"', add
label define mx2010a_migmuni5_lbl 14077 `"San Martín Hidalgo"', add
label define mx2010a_migmuni5_lbl 14078 `"San Miguel el Alto"', add
label define mx2010a_migmuni5_lbl 14079 `"Gómez Farías"', add
label define mx2010a_migmuni5_lbl 14080 `"San Sebastián del Oeste"', add
label define mx2010a_migmuni5_lbl 14081 `"Santa María de los Ángeles"', add
label define mx2010a_migmuni5_lbl 14082 `"Sayula"', add
label define mx2010a_migmuni5_lbl 14083 `"Tala"', add
label define mx2010a_migmuni5_lbl 14084 `"Talpa de Allende"', add
label define mx2010a_migmuni5_lbl 14085 `"Tamazula de Gordiano"', add
label define mx2010a_migmuni5_lbl 14086 `"Tapalpa"', add
label define mx2010a_migmuni5_lbl 14087 `"Tecalitlán"', add
label define mx2010a_migmuni5_lbl 14088 `"Tecolotlán"', add
label define mx2010a_migmuni5_lbl 14089 `"Techaluta de Montenegro"', add
label define mx2010a_migmuni5_lbl 14090 `"Tenamaxtlán"', add
label define mx2010a_migmuni5_lbl 14091 `"Teocaltiche"', add
label define mx2010a_migmuni5_lbl 14092 `"Teocuitatlán de Corona"', add
label define mx2010a_migmuni5_lbl 14093 `"Tepatitlán de Morelos"', add
label define mx2010a_migmuni5_lbl 14094 `"Tequila"', add
label define mx2010a_migmuni5_lbl 14095 `"Teuchitlán"', add
label define mx2010a_migmuni5_lbl 14096 `"Tizapán el Alto"', add
label define mx2010a_migmuni5_lbl 14097 `"Tlajomulco de Zúñiga"', add
label define mx2010a_migmuni5_lbl 14098 `"Tlaquepaque"', add
label define mx2010a_migmuni5_lbl 14099 `"Tolimán"', add
label define mx2010a_migmuni5_lbl 14100 `"Tomatlán"', add
label define mx2010a_migmuni5_lbl 14101 `"Tonalá"', add
label define mx2010a_migmuni5_lbl 14102 `"Tonaya"', add
label define mx2010a_migmuni5_lbl 14103 `"Tonila"', add
label define mx2010a_migmuni5_lbl 14104 `"Totatiche"', add
label define mx2010a_migmuni5_lbl 14105 `"Tototlán"', add
label define mx2010a_migmuni5_lbl 14106 `"Tuxcacuesco"', add
label define mx2010a_migmuni5_lbl 14107 `"Tuxcueca"', add
label define mx2010a_migmuni5_lbl 14108 `"Tuxpan"', add
label define mx2010a_migmuni5_lbl 14109 `"Unión de San Antonio"', add
label define mx2010a_migmuni5_lbl 14110 `"Unión de Tula"', add
label define mx2010a_migmuni5_lbl 14111 `"Valle de Guadalupe"', add
label define mx2010a_migmuni5_lbl 14112 `"Valle de Juárez"', add
label define mx2010a_migmuni5_lbl 14113 `"San Gabriel"', add
label define mx2010a_migmuni5_lbl 14114 `"Villa Corona"', add
label define mx2010a_migmuni5_lbl 14115 `"Villa Guerrero"', add
label define mx2010a_migmuni5_lbl 14116 `"Villa Hidalgo"', add
label define mx2010a_migmuni5_lbl 14117 `"Cañadas de Obregón"', add
label define mx2010a_migmuni5_lbl 14118 `"Yahualica de González Gallo"', add
label define mx2010a_migmuni5_lbl 14119 `"Zacoalco de Torres"', add
label define mx2010a_migmuni5_lbl 14120 `"Zapopan"', add
label define mx2010a_migmuni5_lbl 14121 `"Zapotiltic"', add
label define mx2010a_migmuni5_lbl 14122 `"Zapotitlán de Vadillo"', add
label define mx2010a_migmuni5_lbl 14123 `"Zapotlán del Rey"', add
label define mx2010a_migmuni5_lbl 14124 `"Zapotlanejo"', add
label define mx2010a_migmuni5_lbl 14125 `"San Ignacio Cerro Gordo"', add
label define mx2010a_migmuni5_lbl 14999 `"Jalisco entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 15001 `"Acambay"', add
label define mx2010a_migmuni5_lbl 15002 `"Acolman"', add
label define mx2010a_migmuni5_lbl 15003 `"Aculco"', add
label define mx2010a_migmuni5_lbl 15004 `"Almoloya de Alquisiras"', add
label define mx2010a_migmuni5_lbl 15005 `"Almoloya de Juárez"', add
label define mx2010a_migmuni5_lbl 15006 `"Almoloya del Río"', add
label define mx2010a_migmuni5_lbl 15007 `"Amanalco"', add
label define mx2010a_migmuni5_lbl 15008 `"Amatepec"', add
label define mx2010a_migmuni5_lbl 15009 `"Amecameca"', add
label define mx2010a_migmuni5_lbl 15010 `"Apaxco"', add
label define mx2010a_migmuni5_lbl 15011 `"Atenco"', add
label define mx2010a_migmuni5_lbl 15012 `"Atizapán"', add
label define mx2010a_migmuni5_lbl 15013 `"Atizapán de Zaragoza"', add
label define mx2010a_migmuni5_lbl 15014 `"Atlacomulco"', add
label define mx2010a_migmuni5_lbl 15015 `"Atlautla"', add
label define mx2010a_migmuni5_lbl 15016 `"Axapusco"', add
label define mx2010a_migmuni5_lbl 15017 `"Ayapango"', add
label define mx2010a_migmuni5_lbl 15018 `"Calimaya"', add
label define mx2010a_migmuni5_lbl 15019 `"Capulhuac"', add
label define mx2010a_migmuni5_lbl 15020 `"Coacalco de Berriozábal"', add
label define mx2010a_migmuni5_lbl 15021 `"Coatepec Harinas"', add
label define mx2010a_migmuni5_lbl 15022 `"Cocotitlán"', add
label define mx2010a_migmuni5_lbl 15023 `"Coyotepec"', add
label define mx2010a_migmuni5_lbl 15024 `"Cuautitlán"', add
label define mx2010a_migmuni5_lbl 15025 `"Chalco"', add
label define mx2010a_migmuni5_lbl 15026 `"Chapa de Mota"', add
label define mx2010a_migmuni5_lbl 15027 `"Chapultepec"', add
label define mx2010a_migmuni5_lbl 15028 `"Chiautla"', add
label define mx2010a_migmuni5_lbl 15029 `"Chicoloapan"', add
label define mx2010a_migmuni5_lbl 15030 `"Chiconcuac"', add
label define mx2010a_migmuni5_lbl 15031 `"Chimalhuacán"', add
label define mx2010a_migmuni5_lbl 15032 `"Donato Guerra"', add
label define mx2010a_migmuni5_lbl 15033 `"Ecatepec de Morelos"', add
label define mx2010a_migmuni5_lbl 15034 `"Ecatzingo"', add
label define mx2010a_migmuni5_lbl 15035 `"Huehuetoca"', add
label define mx2010a_migmuni5_lbl 15036 `"Hueypoxtla"', add
label define mx2010a_migmuni5_lbl 15037 `"Huixquilucan"', add
label define mx2010a_migmuni5_lbl 15038 `"Isidro Fabela"', add
label define mx2010a_migmuni5_lbl 15039 `"Ixtapaluca"', add
label define mx2010a_migmuni5_lbl 15040 `"Ixtapan de la Sal"', add
label define mx2010a_migmuni5_lbl 15041 `"Ixtapan del Oro"', add
label define mx2010a_migmuni5_lbl 15042 `"Ixtlahuaca"', add
label define mx2010a_migmuni5_lbl 15043 `"Xalatlaco"', add
label define mx2010a_migmuni5_lbl 15044 `"Jaltenco"', add
label define mx2010a_migmuni5_lbl 15045 `"Jilotepec"', add
label define mx2010a_migmuni5_lbl 15046 `"Jilotzingo"', add
label define mx2010a_migmuni5_lbl 15047 `"Jiquipilco"', add
label define mx2010a_migmuni5_lbl 15048 `"Jocotitlán"', add
label define mx2010a_migmuni5_lbl 15049 `"Joquicingo"', add
label define mx2010a_migmuni5_lbl 15050 `"Juchitepec"', add
label define mx2010a_migmuni5_lbl 15051 `"Lerma"', add
label define mx2010a_migmuni5_lbl 15052 `"Malinalco"', add
label define mx2010a_migmuni5_lbl 15053 `"Melchor Ocampo"', add
label define mx2010a_migmuni5_lbl 15054 `"Metepec"', add
label define mx2010a_migmuni5_lbl 15055 `"Mexicaltzingo"', add
label define mx2010a_migmuni5_lbl 15056 `"Morelos"', add
label define mx2010a_migmuni5_lbl 15057 `"Naucalpan de Juárez"', add
label define mx2010a_migmuni5_lbl 15058 `"Nezahualcóyotl"', add
label define mx2010a_migmuni5_lbl 15059 `"Nextlalpan"', add
label define mx2010a_migmuni5_lbl 15060 `"Nicolás Romero"', add
label define mx2010a_migmuni5_lbl 15061 `"Nopaltepec"', add
label define mx2010a_migmuni5_lbl 15062 `"Ocoyoacac"', add
label define mx2010a_migmuni5_lbl 15063 `"Ocuilan"', add
label define mx2010a_migmuni5_lbl 15064 `"El Oro"', add
label define mx2010a_migmuni5_lbl 15065 `"Otumba"', add
label define mx2010a_migmuni5_lbl 15066 `"Otzoloapan"', add
label define mx2010a_migmuni5_lbl 15067 `"Otzolotepec"', add
label define mx2010a_migmuni5_lbl 15068 `"Ozumba"', add
label define mx2010a_migmuni5_lbl 15069 `"Papalotla"', add
label define mx2010a_migmuni5_lbl 15070 `"La Paz"', add
label define mx2010a_migmuni5_lbl 15071 `"Polotitlán"', add
label define mx2010a_migmuni5_lbl 15072 `"Rayón"', add
label define mx2010a_migmuni5_lbl 15073 `"San Antonio la Isla"', add
label define mx2010a_migmuni5_lbl 15074 `"San Felipe del Progreso"', add
label define mx2010a_migmuni5_lbl 15075 `"San Martín de las Pirámides"', add
label define mx2010a_migmuni5_lbl 15076 `"San Mateo Atenco"', add
label define mx2010a_migmuni5_lbl 15077 `"San Simón de Guerrero"', add
label define mx2010a_migmuni5_lbl 15078 `"Santo Tomás"', add
label define mx2010a_migmuni5_lbl 15079 `"Soyaniquilpan de Juárez"', add
label define mx2010a_migmuni5_lbl 15080 `"Sultepec"', add
label define mx2010a_migmuni5_lbl 15081 `"Tecámac"', add
label define mx2010a_migmuni5_lbl 15082 `"Tejupilco"', add
label define mx2010a_migmuni5_lbl 15083 `"Temamatla"', add
label define mx2010a_migmuni5_lbl 15084 `"Temascalapa"', add
label define mx2010a_migmuni5_lbl 15085 `"Temascalcingo"', add
label define mx2010a_migmuni5_lbl 15086 `"Temascaltepec"', add
label define mx2010a_migmuni5_lbl 15087 `"Temoaya"', add
label define mx2010a_migmuni5_lbl 15088 `"Tenancingo"', add
label define mx2010a_migmuni5_lbl 15089 `"Tenango del Aire"', add
label define mx2010a_migmuni5_lbl 15090 `"Tenango del Valle"', add
label define mx2010a_migmuni5_lbl 15091 `"Teoloyucán"', add
label define mx2010a_migmuni5_lbl 15092 `"Teotihuacán"', add
label define mx2010a_migmuni5_lbl 15093 `"Tepetlaoxtoc"', add
label define mx2010a_migmuni5_lbl 15094 `"Tepetlixpa"', add
label define mx2010a_migmuni5_lbl 15095 `"Tepotzotlán"', add
label define mx2010a_migmuni5_lbl 15096 `"Tequixquiac"', add
label define mx2010a_migmuni5_lbl 15097 `"Texcaltitlán"', add
label define mx2010a_migmuni5_lbl 15098 `"Texcalyacac"', add
label define mx2010a_migmuni5_lbl 15099 `"Texcoco"', add
label define mx2010a_migmuni5_lbl 15100 `"Tezoyuca"', add
label define mx2010a_migmuni5_lbl 15101 `"Tianguistenco"', add
label define mx2010a_migmuni5_lbl 15102 `"Timilpan"', add
label define mx2010a_migmuni5_lbl 15103 `"Tlalmanalco"', add
label define mx2010a_migmuni5_lbl 15104 `"Tlalnepantla de Baz"', add
label define mx2010a_migmuni5_lbl 15105 `"Tlatlaya"', add
label define mx2010a_migmuni5_lbl 15106 `"Toluca"', add
label define mx2010a_migmuni5_lbl 15107 `"Tonatico"', add
label define mx2010a_migmuni5_lbl 15108 `"Tultepec"', add
label define mx2010a_migmuni5_lbl 15109 `"Tultitlán"', add
label define mx2010a_migmuni5_lbl 15110 `"Valle de Bravo"', add
label define mx2010a_migmuni5_lbl 15111 `"Villa de Allende"', add
label define mx2010a_migmuni5_lbl 15112 `"Villa del Carbón"', add
label define mx2010a_migmuni5_lbl 15113 `"Villa Guerrero"', add
label define mx2010a_migmuni5_lbl 15114 `"Villa Victoria"', add
label define mx2010a_migmuni5_lbl 15115 `"Xonacatlán"', add
label define mx2010a_migmuni5_lbl 15116 `"Zacazonapan"', add
label define mx2010a_migmuni5_lbl 15117 `"Zacualpan"', add
label define mx2010a_migmuni5_lbl 15118 `"Zinacantepec"', add
label define mx2010a_migmuni5_lbl 15119 `"Zumpahuacán"', add
label define mx2010a_migmuni5_lbl 15120 `"Zumpango"', add
label define mx2010a_migmuni5_lbl 15121 `"Cuautitlán Izcalli"', add
label define mx2010a_migmuni5_lbl 15122 `"Valle de Chalco Solidaridad"', add
label define mx2010a_migmuni5_lbl 15123 `"Luvianos"', add
label define mx2010a_migmuni5_lbl 15124 `"San José del Rincón"', add
label define mx2010a_migmuni5_lbl 15125 `"Tonanitla"', add
label define mx2010a_migmuni5_lbl 15999 `"México entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 16001 `"Acuitzio"', add
label define mx2010a_migmuni5_lbl 16002 `"Aguililla"', add
label define mx2010a_migmuni5_lbl 16003 `"Álvaro Obregón"', add
label define mx2010a_migmuni5_lbl 16004 `"Angamacutiro"', add
label define mx2010a_migmuni5_lbl 16005 `"Angangueo"', add
label define mx2010a_migmuni5_lbl 16006 `"Apatzingán"', add
label define mx2010a_migmuni5_lbl 16007 `"Aporo"', add
label define mx2010a_migmuni5_lbl 16008 `"Aquila"', add
label define mx2010a_migmuni5_lbl 16009 `"Ario"', add
label define mx2010a_migmuni5_lbl 16010 `"Arteaga"', add
label define mx2010a_migmuni5_lbl 16011 `"Briseñas"', add
label define mx2010a_migmuni5_lbl 16012 `"Buenavista"', add
label define mx2010a_migmuni5_lbl 16013 `"Carácuaro"', add
label define mx2010a_migmuni5_lbl 16014 `"Coahuayana"', add
label define mx2010a_migmuni5_lbl 16015 `"Coalcomán de Vázquez Pallares"', add
label define mx2010a_migmuni5_lbl 16016 `"Coeneo"', add
label define mx2010a_migmuni5_lbl 16017 `"Contepec"', add
label define mx2010a_migmuni5_lbl 16018 `"Copándaro"', add
label define mx2010a_migmuni5_lbl 16019 `"Cotija"', add
label define mx2010a_migmuni5_lbl 16020 `"Cuitzeo"', add
label define mx2010a_migmuni5_lbl 16021 `"Charapan"', add
label define mx2010a_migmuni5_lbl 16022 `"Charo"', add
label define mx2010a_migmuni5_lbl 16023 `"Chavinda"', add
label define mx2010a_migmuni5_lbl 16024 `"Cherán"', add
label define mx2010a_migmuni5_lbl 16025 `"Chilchota"', add
label define mx2010a_migmuni5_lbl 16026 `"Chinicuila"', add
label define mx2010a_migmuni5_lbl 16027 `"Chucándiro"', add
label define mx2010a_migmuni5_lbl 16028 `"Churintzio"', add
label define mx2010a_migmuni5_lbl 16029 `"Churumuco"', add
label define mx2010a_migmuni5_lbl 16030 `"Ecuandureo"', add
label define mx2010a_migmuni5_lbl 16031 `"Epitacio Huerta"', add
label define mx2010a_migmuni5_lbl 16032 `"Erongarícuaro"', add
label define mx2010a_migmuni5_lbl 16033 `"Gabriel Zamora"', add
label define mx2010a_migmuni5_lbl 16034 `"Hidalgo"', add
label define mx2010a_migmuni5_lbl 16035 `"La Huacana"', add
label define mx2010a_migmuni5_lbl 16036 `"Huandacareo"', add
label define mx2010a_migmuni5_lbl 16037 `"Huaniqueo"', add
label define mx2010a_migmuni5_lbl 16038 `"Huetamo"', add
label define mx2010a_migmuni5_lbl 16039 `"Huiramba"', add
label define mx2010a_migmuni5_lbl 16040 `"Indaparapeo"', add
label define mx2010a_migmuni5_lbl 16041 `"Irimbo"', add
label define mx2010a_migmuni5_lbl 16042 `"Ixtlán"', add
label define mx2010a_migmuni5_lbl 16043 `"Jacona"', add
label define mx2010a_migmuni5_lbl 16044 `"Jiménez"', add
label define mx2010a_migmuni5_lbl 16045 `"Jiquilpan"', add
label define mx2010a_migmuni5_lbl 16046 `"Juárez"', add
label define mx2010a_migmuni5_lbl 16047 `"Jungapeo"', add
label define mx2010a_migmuni5_lbl 16048 `"Lagunillas"', add
label define mx2010a_migmuni5_lbl 16049 `"Madero"', add
label define mx2010a_migmuni5_lbl 16050 `"Maravatío"', add
label define mx2010a_migmuni5_lbl 16051 `"Marcos Castellanos"', add
label define mx2010a_migmuni5_lbl 16052 `"Lázaro Cárdenas"', add
label define mx2010a_migmuni5_lbl 16053 `"Morelia"', add
label define mx2010a_migmuni5_lbl 16054 `"Morelos"', add
label define mx2010a_migmuni5_lbl 16055 `"Múgica"', add
label define mx2010a_migmuni5_lbl 16056 `"Nahuatzen"', add
label define mx2010a_migmuni5_lbl 16057 `"Nocupétaro"', add
label define mx2010a_migmuni5_lbl 16058 `"Nuevo Parangaricutiro"', add
label define mx2010a_migmuni5_lbl 16059 `"Nuevo Urecho"', add
label define mx2010a_migmuni5_lbl 16060 `"Numarán"', add
label define mx2010a_migmuni5_lbl 16061 `"Ocampo"', add
label define mx2010a_migmuni5_lbl 16062 `"Pajacuarán"', add
label define mx2010a_migmuni5_lbl 16063 `"Panindícuaro"', add
label define mx2010a_migmuni5_lbl 16064 `"Parácuaro"', add
label define mx2010a_migmuni5_lbl 16065 `"Paracho"', add
label define mx2010a_migmuni5_lbl 16066 `"Pátzcuaro"', add
label define mx2010a_migmuni5_lbl 16067 `"Penjamillo"', add
label define mx2010a_migmuni5_lbl 16068 `"Peribán"', add
label define mx2010a_migmuni5_lbl 16069 `"La Piedad"', add
label define mx2010a_migmuni5_lbl 16070 `"Purépero"', add
label define mx2010a_migmuni5_lbl 16071 `"Puruándiro"', add
label define mx2010a_migmuni5_lbl 16072 `"Queréndaro"', add
label define mx2010a_migmuni5_lbl 16073 `"Quiroga"', add
label define mx2010a_migmuni5_lbl 16074 `"Cojumatlán de Régules"', add
label define mx2010a_migmuni5_lbl 16075 `"Los Reyes"', add
label define mx2010a_migmuni5_lbl 16076 `"Sahuayo"', add
label define mx2010a_migmuni5_lbl 16077 `"San Lucas"', add
label define mx2010a_migmuni5_lbl 16078 `"Santa Ana Maya"', add
label define mx2010a_migmuni5_lbl 16079 `"Salvador Escalante"', add
label define mx2010a_migmuni5_lbl 16080 `"Senguio"', add
label define mx2010a_migmuni5_lbl 16081 `"Susupuato"', add
label define mx2010a_migmuni5_lbl 16082 `"Tacámbaro"', add
label define mx2010a_migmuni5_lbl 16083 `"Tancítaro"', add
label define mx2010a_migmuni5_lbl 16084 `"Tangamandapio"', add
label define mx2010a_migmuni5_lbl 16085 `"Tangancícuaro"', add
label define mx2010a_migmuni5_lbl 16086 `"Tanhuato"', add
label define mx2010a_migmuni5_lbl 16087 `"Taretan"', add
label define mx2010a_migmuni5_lbl 16088 `"Tarímbaro"', add
label define mx2010a_migmuni5_lbl 16089 `"Tepalcatepec"', add
label define mx2010a_migmuni5_lbl 16090 `"Tingambato"', add
label define mx2010a_migmuni5_lbl 16091 `"Tingüindín"', add
label define mx2010a_migmuni5_lbl 16092 `"Tiquicheo de Nicolás Romero"', add
label define mx2010a_migmuni5_lbl 16093 `"Tlalpujahua"', add
label define mx2010a_migmuni5_lbl 16094 `"Tlazazalca"', add
label define mx2010a_migmuni5_lbl 16095 `"Tocumbo"', add
label define mx2010a_migmuni5_lbl 16096 `"Tumbiscatío"', add
label define mx2010a_migmuni5_lbl 16097 `"Turicato"', add
label define mx2010a_migmuni5_lbl 16098 `"Tuxpan"', add
label define mx2010a_migmuni5_lbl 16099 `"Tuzantla"', add
label define mx2010a_migmuni5_lbl 16100 `"Tzintzuntzan"', add
label define mx2010a_migmuni5_lbl 16101 `"Tzitzio"', add
label define mx2010a_migmuni5_lbl 16102 `"Uruapan"', add
label define mx2010a_migmuni5_lbl 16103 `"Venustiano Carranza"', add
label define mx2010a_migmuni5_lbl 16104 `"Villamar"', add
label define mx2010a_migmuni5_lbl 16105 `"Vista Hermosa"', add
label define mx2010a_migmuni5_lbl 16106 `"Yurécuaro"', add
label define mx2010a_migmuni5_lbl 16107 `"Zacapu"', add
label define mx2010a_migmuni5_lbl 16108 `"Zamora"', add
label define mx2010a_migmuni5_lbl 16109 `"Zináparo"', add
label define mx2010a_migmuni5_lbl 16110 `"Zinapécuaro"', add
label define mx2010a_migmuni5_lbl 16111 `"Ziracuaretiro"', add
label define mx2010a_migmuni5_lbl 16112 `"Zitácuaro"', add
label define mx2010a_migmuni5_lbl 16113 `"José Sixto Verduzco"', add
label define mx2010a_migmuni5_lbl 16999 `"Michoacán de Ocampo entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 17001 `"Amacuzac"', add
label define mx2010a_migmuni5_lbl 17002 `"Atlatlahucan"', add
label define mx2010a_migmuni5_lbl 17003 `"Axochiapan"', add
label define mx2010a_migmuni5_lbl 17004 `"Ayala"', add
label define mx2010a_migmuni5_lbl 17005 `"Coatlán del Río"', add
label define mx2010a_migmuni5_lbl 17006 `"Cuautla"', add
label define mx2010a_migmuni5_lbl 17007 `"Cuernavaca"', add
label define mx2010a_migmuni5_lbl 17008 `"Emiliano Zapata"', add
label define mx2010a_migmuni5_lbl 17009 `"Huitzilac"', add
label define mx2010a_migmuni5_lbl 17010 `"Jantetelco"', add
label define mx2010a_migmuni5_lbl 17011 `"Jiutepec"', add
label define mx2010a_migmuni5_lbl 17012 `"Jojutla"', add
label define mx2010a_migmuni5_lbl 17013 `"Jonacatepec"', add
label define mx2010a_migmuni5_lbl 17014 `"Mazatepec"', add
label define mx2010a_migmuni5_lbl 17015 `"Miacatlán"', add
label define mx2010a_migmuni5_lbl 17016 `"Ocuituco"', add
label define mx2010a_migmuni5_lbl 17017 `"Puente de Ixtla"', add
label define mx2010a_migmuni5_lbl 17018 `"Temixco"', add
label define mx2010a_migmuni5_lbl 17019 `"Tepalcingo"', add
label define mx2010a_migmuni5_lbl 17020 `"Tepoztlán"', add
label define mx2010a_migmuni5_lbl 17021 `"Tetecala"', add
label define mx2010a_migmuni5_lbl 17022 `"Tetela del Volcán"', add
label define mx2010a_migmuni5_lbl 17023 `"Tlalnepantla"', add
label define mx2010a_migmuni5_lbl 17024 `"Tlaltizapán"', add
label define mx2010a_migmuni5_lbl 17025 `"Tlaquiltenango"', add
label define mx2010a_migmuni5_lbl 17026 `"Tlayacapan"', add
label define mx2010a_migmuni5_lbl 17027 `"Totolapan"', add
label define mx2010a_migmuni5_lbl 17028 `"Xochitepec"', add
label define mx2010a_migmuni5_lbl 17029 `"Yautepec"', add
label define mx2010a_migmuni5_lbl 17030 `"Yecapixtla"', add
label define mx2010a_migmuni5_lbl 17031 `"Zacatepec"', add
label define mx2010a_migmuni5_lbl 17032 `"Zacualpan"', add
label define mx2010a_migmuni5_lbl 17033 `"Temoac"', add
label define mx2010a_migmuni5_lbl 17999 `"Morelos entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 18001 `"Acaponeta"', add
label define mx2010a_migmuni5_lbl 18002 `"Ahuacatlán"', add
label define mx2010a_migmuni5_lbl 18003 `"Amatlán de Cañas"', add
label define mx2010a_migmuni5_lbl 18004 `"Compostela"', add
label define mx2010a_migmuni5_lbl 18005 `"Huajicori"', add
label define mx2010a_migmuni5_lbl 18006 `"Ixtlán del Río"', add
label define mx2010a_migmuni5_lbl 18007 `"Jala"', add
label define mx2010a_migmuni5_lbl 18008 `"Xalisco"', add
label define mx2010a_migmuni5_lbl 18009 `"Del Nayar"', add
label define mx2010a_migmuni5_lbl 18010 `"Rosamorada"', add
label define mx2010a_migmuni5_lbl 18011 `"Ruíz"', add
label define mx2010a_migmuni5_lbl 18012 `"San Blas"', add
label define mx2010a_migmuni5_lbl 18013 `"San Pedro Lagunillas"', add
label define mx2010a_migmuni5_lbl 18014 `"Santa María del Oro"', add
label define mx2010a_migmuni5_lbl 18015 `"Santiago Ixcuintla"', add
label define mx2010a_migmuni5_lbl 18016 `"Tecuala"', add
label define mx2010a_migmuni5_lbl 18017 `"Tepic"', add
label define mx2010a_migmuni5_lbl 18018 `"Tuxpan"', add
label define mx2010a_migmuni5_lbl 18019 `"La Yesca"', add
label define mx2010a_migmuni5_lbl 18020 `"Bahía de Banderas"', add
label define mx2010a_migmuni5_lbl 18999 `"Nayarit entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 19001 `"Abasolo"', add
label define mx2010a_migmuni5_lbl 19002 `"Agualeguas"', add
label define mx2010a_migmuni5_lbl 19003 `"Los Aldamas"', add
label define mx2010a_migmuni5_lbl 19004 `"Allende"', add
label define mx2010a_migmuni5_lbl 19005 `"Anáhuac"', add
label define mx2010a_migmuni5_lbl 19006 `"Apodaca"', add
label define mx2010a_migmuni5_lbl 19007 `"Aramberri"', add
label define mx2010a_migmuni5_lbl 19008 `"Bustamante"', add
label define mx2010a_migmuni5_lbl 19009 `"Cadereyta Jiménez"', add
label define mx2010a_migmuni5_lbl 19010 `"Carmen"', add
label define mx2010a_migmuni5_lbl 19011 `"Cerralvo"', add
label define mx2010a_migmuni5_lbl 19012 `"Ciénega de Flores"', add
label define mx2010a_migmuni5_lbl 19013 `"China"', add
label define mx2010a_migmuni5_lbl 19014 `"Dr. Arroyo"', add
label define mx2010a_migmuni5_lbl 19015 `"Dr. Coss"', add
label define mx2010a_migmuni5_lbl 19016 `"Dr. González"', add
label define mx2010a_migmuni5_lbl 19017 `"Galeana"', add
label define mx2010a_migmuni5_lbl 19018 `"García"', add
label define mx2010a_migmuni5_lbl 19019 `"San Pedro Garza García"', add
label define mx2010a_migmuni5_lbl 19020 `"Gral. Bravo"', add
label define mx2010a_migmuni5_lbl 19021 `"Gral. Escobedo"', add
label define mx2010a_migmuni5_lbl 19022 `"Gral. Terán"', add
label define mx2010a_migmuni5_lbl 19023 `"Gral. Treviño"', add
label define mx2010a_migmuni5_lbl 19024 `"Gral. Zaragoza"', add
label define mx2010a_migmuni5_lbl 19025 `"Gral. Zuazua"', add
label define mx2010a_migmuni5_lbl 19026 `"Guadalupe"', add
label define mx2010a_migmuni5_lbl 19027 `"Los Herreras"', add
label define mx2010a_migmuni5_lbl 19028 `"Higueras"', add
label define mx2010a_migmuni5_lbl 19029 `"Hualahuises"', add
label define mx2010a_migmuni5_lbl 19030 `"Iturbide"', add
label define mx2010a_migmuni5_lbl 19031 `"Juárez"', add
label define mx2010a_migmuni5_lbl 19032 `"Lampazos de Naranjo"', add
label define mx2010a_migmuni5_lbl 19033 `"Linares"', add
label define mx2010a_migmuni5_lbl 19034 `"Marín"', add
label define mx2010a_migmuni5_lbl 19035 `"Melchor Ocampo"', add
label define mx2010a_migmuni5_lbl 19036 `"Mier y Noriega"', add
label define mx2010a_migmuni5_lbl 19037 `"Mina"', add
label define mx2010a_migmuni5_lbl 19038 `"Montemorelos"', add
label define mx2010a_migmuni5_lbl 19039 `"Monterrey"', add
label define mx2010a_migmuni5_lbl 19040 `"Parás"', add
label define mx2010a_migmuni5_lbl 19041 `"Pesquería"', add
label define mx2010a_migmuni5_lbl 19042 `"Los Ramones"', add
label define mx2010a_migmuni5_lbl 19043 `"Rayones"', add
label define mx2010a_migmuni5_lbl 19044 `"Sabinas Hidalgo"', add
label define mx2010a_migmuni5_lbl 19045 `"Salinas Victoria"', add
label define mx2010a_migmuni5_lbl 19046 `"San Nicolás de los Garza"', add
label define mx2010a_migmuni5_lbl 19047 `"Hidalgo"', add
label define mx2010a_migmuni5_lbl 19048 `"Santa Catarina"', add
label define mx2010a_migmuni5_lbl 19049 `"Santiago"', add
label define mx2010a_migmuni5_lbl 19050 `"Vallecillo"', add
label define mx2010a_migmuni5_lbl 19051 `"Villaldama"', add
label define mx2010a_migmuni5_lbl 19999 `"Nuevo León entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 20001 `"Abejones"', add
label define mx2010a_migmuni5_lbl 20002 `"Acatlán de Pérez Figueroa"', add
label define mx2010a_migmuni5_lbl 20003 `"Asunción Cacalotepec"', add
label define mx2010a_migmuni5_lbl 20004 `"Asunción Cuyotepeji"', add
label define mx2010a_migmuni5_lbl 20005 `"Asunción Ixtaltepec"', add
label define mx2010a_migmuni5_lbl 20006 `"Asunción Nochixtlán"', add
label define mx2010a_migmuni5_lbl 20007 `"Asunción Ocotlán"', add
label define mx2010a_migmuni5_lbl 20008 `"Asunción Tlacolulita"', add
label define mx2010a_migmuni5_lbl 20009 `"Ayotzintepec"', add
label define mx2010a_migmuni5_lbl 20010 `"El Barrio de la Soledad"', add
label define mx2010a_migmuni5_lbl 20011 `"Calihualá"', add
label define mx2010a_migmuni5_lbl 20012 `"Candelaria Loxicha"', add
label define mx2010a_migmuni5_lbl 20013 `"Ciénega de Zimatlán"', add
label define mx2010a_migmuni5_lbl 20014 `"Ciudad Ixtepec"', add
label define mx2010a_migmuni5_lbl 20015 `"Coatecas Altas"', add
label define mx2010a_migmuni5_lbl 20016 `"Coicoyán de las Flores"', add
label define mx2010a_migmuni5_lbl 20017 `"La Compañía"', add
label define mx2010a_migmuni5_lbl 20018 `"Concepción Buenavista"', add
label define mx2010a_migmuni5_lbl 20019 `"Concepción Pápalo"', add
label define mx2010a_migmuni5_lbl 20020 `"Constancia del Rosario"', add
label define mx2010a_migmuni5_lbl 20021 `"Cosolapa"', add
label define mx2010a_migmuni5_lbl 20022 `"Cosoltepec"', add
label define mx2010a_migmuni5_lbl 20023 `"Cuilápam de Guerrero"', add
label define mx2010a_migmuni5_lbl 20024 `"Cuyamecalco Villa de Zaragoza"', add
label define mx2010a_migmuni5_lbl 20025 `"Chahuites"', add
label define mx2010a_migmuni5_lbl 20026 `"Chalcatongo de Hidalgo"', add
label define mx2010a_migmuni5_lbl 20027 `"Chiquihuitlán de Benito Juárez"', add
label define mx2010a_migmuni5_lbl 20028 `"Heroica Ciudad de Ejutla de Crespo"', add
label define mx2010a_migmuni5_lbl 20029 `"Eloxochitlán de Flores Magón"', add
label define mx2010a_migmuni5_lbl 20030 `"El Espinal"', add
label define mx2010a_migmuni5_lbl 20031 `"Tamazulápam del Espíritu Santo"', add
label define mx2010a_migmuni5_lbl 20032 `"Fresnillo de Trujano"', add
label define mx2010a_migmuni5_lbl 20033 `"Guadalupe Etla"', add
label define mx2010a_migmuni5_lbl 20034 `"Guadalupe de Ramírez"', add
label define mx2010a_migmuni5_lbl 20035 `"Guelatao de Juárez"', add
label define mx2010a_migmuni5_lbl 20036 `"Guevea de Humboldt"', add
label define mx2010a_migmuni5_lbl 20037 `"Mesones Hidalgo"', add
label define mx2010a_migmuni5_lbl 20038 `"Villa Hidalgo"', add
label define mx2010a_migmuni5_lbl 20039 `"Heroica Ciudad de Huajuapan de León"', add
label define mx2010a_migmuni5_lbl 20040 `"Huautepec"', add
label define mx2010a_migmuni5_lbl 20041 `"Huautla de Jiménez"', add
label define mx2010a_migmuni5_lbl 20042 `"Ixtlán de Juárez"', add
label define mx2010a_migmuni5_lbl 20043 `"Heroica Ciudad de Juchitán de Zaragoza"', add
label define mx2010a_migmuni5_lbl 20044 `"Loma Bonita"', add
label define mx2010a_migmuni5_lbl 20045 `"Magdalena Apasco"', add
label define mx2010a_migmuni5_lbl 20046 `"Magdalena Jaltepec"', add
label define mx2010a_migmuni5_lbl 20047 `"Santa Magdalena Jicotlán"', add
label define mx2010a_migmuni5_lbl 20048 `"Magdalena Mixtepec"', add
label define mx2010a_migmuni5_lbl 20049 `"Magdalena Ocotlán"', add
label define mx2010a_migmuni5_lbl 20050 `"Magdalena Peñasco"', add
label define mx2010a_migmuni5_lbl 20051 `"Magdalena Teitipac"', add
label define mx2010a_migmuni5_lbl 20052 `"Magdalena Tequisistlán"', add
label define mx2010a_migmuni5_lbl 20053 `"Magdalena Tlacotepec"', add
label define mx2010a_migmuni5_lbl 20054 `"Magdalena Zahuatlán"', add
label define mx2010a_migmuni5_lbl 20055 `"Mariscala de Juárez"', add
label define mx2010a_migmuni5_lbl 20056 `"Mártires de Tacubaya"', add
label define mx2010a_migmuni5_lbl 20057 `"Matías Romero Avendaño"', add
label define mx2010a_migmuni5_lbl 20058 `"Mazatlán Villa de Flores"', add
label define mx2010a_migmuni5_lbl 20059 `"Miahuatlán de Porfirio Díaz"', add
label define mx2010a_migmuni5_lbl 20060 `"Mixistlán de la Reforma"', add
label define mx2010a_migmuni5_lbl 20061 `"Monjas"', add
label define mx2010a_migmuni5_lbl 20062 `"Natividad"', add
label define mx2010a_migmuni5_lbl 20063 `"Nazareno Etla"', add
label define mx2010a_migmuni5_lbl 20064 `"Nejapa de Madero"', add
label define mx2010a_migmuni5_lbl 20065 `"Ixpantepec Nieves"', add
label define mx2010a_migmuni5_lbl 20066 `"Santiago Niltepec"', add
label define mx2010a_migmuni5_lbl 20067 `"Oaxaca de Juárez"', add
label define mx2010a_migmuni5_lbl 20068 `"Ocotlán de Morelos"', add
label define mx2010a_migmuni5_lbl 20069 `"La Pe"', add
label define mx2010a_migmuni5_lbl 20070 `"Pinotepa de Don Luis"', add
label define mx2010a_migmuni5_lbl 20071 `"Pluma Hidalgo"', add
label define mx2010a_migmuni5_lbl 20072 `"San José del Progreso"', add
label define mx2010a_migmuni5_lbl 20073 `"Putla Villa de Guerrero"', add
label define mx2010a_migmuni5_lbl 20074 `"Santa Catarina Quioquitani"', add
label define mx2010a_migmuni5_lbl 20075 `"Reforma de Pineda"', add
label define mx2010a_migmuni5_lbl 20076 `"La Reforma"', add
label define mx2010a_migmuni5_lbl 20077 `"Reyes Etla"', add
label define mx2010a_migmuni5_lbl 20078 `"Rojas de Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 20079 `"Salina Cruz"', add
label define mx2010a_migmuni5_lbl 20080 `"San Agustín Amatengo"', add
label define mx2010a_migmuni5_lbl 20081 `"San Agustín Atenango"', add
label define mx2010a_migmuni5_lbl 20082 `"San Agustín Chayuco"', add
label define mx2010a_migmuni5_lbl 20083 `"San Agustín de las Juntas"', add
label define mx2010a_migmuni5_lbl 20084 `"San Agustín Etla"', add
label define mx2010a_migmuni5_lbl 20085 `"San Agustín Loxicha"', add
label define mx2010a_migmuni5_lbl 20086 `"San Agustín Tlacotepec"', add
label define mx2010a_migmuni5_lbl 20087 `"San Agustín Yatareni"', add
label define mx2010a_migmuni5_lbl 20088 `"San Andrés Cabecera Nueva"', add
label define mx2010a_migmuni5_lbl 20089 `"San Andrés Dinicuiti"', add
label define mx2010a_migmuni5_lbl 20090 `"San Andrés Huaxpaltepec"', add
label define mx2010a_migmuni5_lbl 20091 `"San Andrés Huayápam"', add
label define mx2010a_migmuni5_lbl 20092 `"San Andrés Ixtlahuaca"', add
label define mx2010a_migmuni5_lbl 20093 `"San Andrés Lagunas"', add
label define mx2010a_migmuni5_lbl 20094 `"San Andrés Nuxiño"', add
label define mx2010a_migmuni5_lbl 20095 `"San Andrés Paxtlán"', add
label define mx2010a_migmuni5_lbl 20096 `"San Andrés Sinaxtla"', add
label define mx2010a_migmuni5_lbl 20097 `"San Andrés Solaga"', add
label define mx2010a_migmuni5_lbl 20098 `"San Andrés Teotilálpam"', add
label define mx2010a_migmuni5_lbl 20099 `"San Andrés Tepetlapa"', add
label define mx2010a_migmuni5_lbl 20100 `"San Andrés Yaá"', add
label define mx2010a_migmuni5_lbl 20101 `"San Andrés Zabache"', add
label define mx2010a_migmuni5_lbl 20102 `"San Andrés Zautla"', add
label define mx2010a_migmuni5_lbl 20103 `"San Antonino Castillo Velasco"', add
label define mx2010a_migmuni5_lbl 20104 `"San Antonino el Alto"', add
label define mx2010a_migmuni5_lbl 20105 `"San Antonino Monte Verde"', add
label define mx2010a_migmuni5_lbl 20106 `"San Antonio Acutla"', add
label define mx2010a_migmuni5_lbl 20107 `"San Antonio de la Cal"', add
label define mx2010a_migmuni5_lbl 20108 `"San Antonio Huitepec"', add
label define mx2010a_migmuni5_lbl 20109 `"San Antonio Nanahuatípam"', add
label define mx2010a_migmuni5_lbl 20110 `"San Antonio Sinicahua"', add
label define mx2010a_migmuni5_lbl 20111 `"San Antonio Tepetlapa"', add
label define mx2010a_migmuni5_lbl 20112 `"San Baltazar Chichicápam"', add
label define mx2010a_migmuni5_lbl 20113 `"San Baltazar Loxicha"', add
label define mx2010a_migmuni5_lbl 20114 `"San Baltazar Yatzachi el Bajo"', add
label define mx2010a_migmuni5_lbl 20115 `"San Bartolo Coyotepec"', add
label define mx2010a_migmuni5_lbl 20116 `"San Bartolomé Ayautla"', add
label define mx2010a_migmuni5_lbl 20117 `"San Bartolomé Loxicha"', add
label define mx2010a_migmuni5_lbl 20118 `"San Bartolomé Quialana"', add
label define mx2010a_migmuni5_lbl 20119 `"San Bartolomé Yucuañe"', add
label define mx2010a_migmuni5_lbl 20120 `"San Bartolomé Zoogocho"', add
label define mx2010a_migmuni5_lbl 20121 `"San Bartolo Soyaltepec"', add
label define mx2010a_migmuni5_lbl 20122 `"San Bartolo Yautepec"', add
label define mx2010a_migmuni5_lbl 20123 `"San Bernardo Mixtepec"', add
label define mx2010a_migmuni5_lbl 20124 `"San Blas Atempa"', add
label define mx2010a_migmuni5_lbl 20125 `"San Carlos Yautepec"', add
label define mx2010a_migmuni5_lbl 20126 `"San Cristóbal Amatlán"', add
label define mx2010a_migmuni5_lbl 20127 `"San Cristóbal Amoltepec"', add
label define mx2010a_migmuni5_lbl 20128 `"San Cristóbal Lachirioag"', add
label define mx2010a_migmuni5_lbl 20129 `"San Cristóbal Suchixtlahuaca"', add
label define mx2010a_migmuni5_lbl 20130 `"San Dionisio del Mar"', add
label define mx2010a_migmuni5_lbl 20131 `"San Dionisio Ocotepec"', add
label define mx2010a_migmuni5_lbl 20132 `"San Dionisio Ocotlán"', add
label define mx2010a_migmuni5_lbl 20133 `"San Esteban Atatlahuca"', add
label define mx2010a_migmuni5_lbl 20134 `"San Felipe Jalapa de Díaz"', add
label define mx2010a_migmuni5_lbl 20135 `"San Felipe Tejalápam"', add
label define mx2010a_migmuni5_lbl 20136 `"San Felipe Usila"', add
label define mx2010a_migmuni5_lbl 20137 `"San Francisco Cahuacuá"', add
label define mx2010a_migmuni5_lbl 20138 `"San Francisco Cajonos"', add
label define mx2010a_migmuni5_lbl 20139 `"San Francisco Chapulapa"', add
label define mx2010a_migmuni5_lbl 20140 `"San Francisco Chindúa"', add
label define mx2010a_migmuni5_lbl 20141 `"San Francisco del Mar"', add
label define mx2010a_migmuni5_lbl 20142 `"San Francisco Huehuetlán"', add
label define mx2010a_migmuni5_lbl 20143 `"San Francisco Ixhuatán"', add
label define mx2010a_migmuni5_lbl 20144 `"San Francisco Jaltepetongo"', add
label define mx2010a_migmuni5_lbl 20145 `"San Francisco Lachigoló"', add
label define mx2010a_migmuni5_lbl 20146 `"San Francisco Logueche"', add
label define mx2010a_migmuni5_lbl 20147 `"San Francisco Nuxaño"', add
label define mx2010a_migmuni5_lbl 20148 `"San Francisco Ozolotepec"', add
label define mx2010a_migmuni5_lbl 20149 `"San Francisco Sola"', add
label define mx2010a_migmuni5_lbl 20150 `"San Francisco Telixtlahuaca"', add
label define mx2010a_migmuni5_lbl 20151 `"San Francisco Teopan"', add
label define mx2010a_migmuni5_lbl 20152 `"San Francisco Tlapancingo"', add
label define mx2010a_migmuni5_lbl 20153 `"San Gabriel Mixtepec"', add
label define mx2010a_migmuni5_lbl 20154 `"San Ildefonso Amatlán"', add
label define mx2010a_migmuni5_lbl 20155 `"San Ildefonso Sola"', add
label define mx2010a_migmuni5_lbl 20156 `"San Ildefonso Villa Alta"', add
label define mx2010a_migmuni5_lbl 20157 `"San Jacinto Amilpas"', add
label define mx2010a_migmuni5_lbl 20158 `"San Jacinto Tlacotepec"', add
label define mx2010a_migmuni5_lbl 20159 `"San Jerónimo Coatlán"', add
label define mx2010a_migmuni5_lbl 20160 `"San Jerónimo Silacayoapilla"', add
label define mx2010a_migmuni5_lbl 20161 `"San Jerónimo Sosola"', add
label define mx2010a_migmuni5_lbl 20162 `"San Jerónimo Taviche"', add
label define mx2010a_migmuni5_lbl 20163 `"San Jerónimo Tecóatl"', add
label define mx2010a_migmuni5_lbl 20164 `"San Jorge Nuchita"', add
label define mx2010a_migmuni5_lbl 20165 `"San José Ayuquila"', add
label define mx2010a_migmuni5_lbl 20166 `"San José Chiltepec"', add
label define mx2010a_migmuni5_lbl 20167 `"San José del Peñasco"', add
label define mx2010a_migmuni5_lbl 20168 `"San José Estancia Grande"', add
label define mx2010a_migmuni5_lbl 20169 `"San José Independencia"', add
label define mx2010a_migmuni5_lbl 20170 `"San José Lachiguiri"', add
label define mx2010a_migmuni5_lbl 20171 `"San José Tenango"', add
label define mx2010a_migmuni5_lbl 20172 `"San Juan Achiutla"', add
label define mx2010a_migmuni5_lbl 20173 `"San Juan Atepec"', add
label define mx2010a_migmuni5_lbl 20174 `"Ánimas Trujano"', add
label define mx2010a_migmuni5_lbl 20175 `"San Juan Bautista Atatlahuca"', add
label define mx2010a_migmuni5_lbl 20176 `"San Juan Bautista Coixtlahuaca"', add
label define mx2010a_migmuni5_lbl 20177 `"San Juan Bautista Cuicatlán"', add
label define mx2010a_migmuni5_lbl 20178 `"San Juan Bautista Guelache"', add
label define mx2010a_migmuni5_lbl 20179 `"San Juan Bautista Jayacatlán"', add
label define mx2010a_migmuni5_lbl 20180 `"San Juan Bautista Lo de Soto"', add
label define mx2010a_migmuni5_lbl 20181 `"San Juan Bautista Suchitepec"', add
label define mx2010a_migmuni5_lbl 20182 `"San Juan Bautista Tlacoatzintepec"', add
label define mx2010a_migmuni5_lbl 20183 `"San Juan Bautista Tlachichilco"', add
label define mx2010a_migmuni5_lbl 20184 `"San Juan Bautista Tuxtepec"', add
label define mx2010a_migmuni5_lbl 20185 `"San Juan Cacahuatepec"', add
label define mx2010a_migmuni5_lbl 20186 `"San Juan Cieneguilla"', add
label define mx2010a_migmuni5_lbl 20187 `"San Juan Coatzóspam"', add
label define mx2010a_migmuni5_lbl 20188 `"San Juan Colorado"', add
label define mx2010a_migmuni5_lbl 20189 `"San Juan Comaltepec"', add
label define mx2010a_migmuni5_lbl 20190 `"San Juan Cotzocón"', add
label define mx2010a_migmuni5_lbl 20191 `"San Juan Chicomezúchil"', add
label define mx2010a_migmuni5_lbl 20192 `"San Juan Chilateca"', add
label define mx2010a_migmuni5_lbl 20193 `"San Juan del Estado"', add
label define mx2010a_migmuni5_lbl 20194 `"San Juan del Río"', add
label define mx2010a_migmuni5_lbl 20195 `"San Juan Diuxi"', add
label define mx2010a_migmuni5_lbl 20196 `"San Juan Evangelista Analco"', add
label define mx2010a_migmuni5_lbl 20197 `"San Juan Guelavía"', add
label define mx2010a_migmuni5_lbl 20198 `"San Juan Guichicovi"', add
label define mx2010a_migmuni5_lbl 20199 `"San Juan Ihualtepec"', add
label define mx2010a_migmuni5_lbl 20200 `"San Juan Juquila Mixes"', add
label define mx2010a_migmuni5_lbl 20201 `"San Juan Juquila Vijanos"', add
label define mx2010a_migmuni5_lbl 20202 `"San Juan Lachao"', add
label define mx2010a_migmuni5_lbl 20203 `"San Juan Lachigalla"', add
label define mx2010a_migmuni5_lbl 20204 `"San Juan Lajarcia"', add
label define mx2010a_migmuni5_lbl 20205 `"San Juan Lalana"', add
label define mx2010a_migmuni5_lbl 20206 `"San Juan de los Cués"', add
label define mx2010a_migmuni5_lbl 20207 `"San Juan Mazatlán"', add
label define mx2010a_migmuni5_lbl 20208 `"San Juan Mixtepec - Dto. 08"', add
label define mx2010a_migmuni5_lbl 20209 `"San Juan Mixtepec - Dto. 26"', add
label define mx2010a_migmuni5_lbl 20210 `"San Juan Ñumí"', add
label define mx2010a_migmuni5_lbl 20211 `"San Juan Ozolotepec"', add
label define mx2010a_migmuni5_lbl 20212 `"San Juan Petlapa"', add
label define mx2010a_migmuni5_lbl 20213 `"San Juan Quiahije"', add
label define mx2010a_migmuni5_lbl 20214 `"San Juan Quiotepec"', add
label define mx2010a_migmuni5_lbl 20215 `"San Juan Sayultepec"', add
label define mx2010a_migmuni5_lbl 20216 `"San Juan Tabaá"', add
label define mx2010a_migmuni5_lbl 20217 `"San Juan Tamazola"', add
label define mx2010a_migmuni5_lbl 20218 `"San Juan Teita"', add
label define mx2010a_migmuni5_lbl 20219 `"San Juan Teitipac"', add
label define mx2010a_migmuni5_lbl 20220 `"San Juan Tepeuxila"', add
label define mx2010a_migmuni5_lbl 20221 `"San Juan Teposcolula"', add
label define mx2010a_migmuni5_lbl 20222 `"San Juan Yaeé"', add
label define mx2010a_migmuni5_lbl 20223 `"San Juan Yatzona"', add
label define mx2010a_migmuni5_lbl 20224 `"San Juan Yucuita"', add
label define mx2010a_migmuni5_lbl 20225 `"San Lorenzo"', add
label define mx2010a_migmuni5_lbl 20226 `"San Lorenzo Albarradas"', add
label define mx2010a_migmuni5_lbl 20227 `"San Lorenzo Cacaotepec"', add
label define mx2010a_migmuni5_lbl 20228 `"San Lorenzo Cuaunecuiltitla"', add
label define mx2010a_migmuni5_lbl 20229 `"San Lorenzo Texmelúcan"', add
label define mx2010a_migmuni5_lbl 20230 `"San Lorenzo Victoria"', add
label define mx2010a_migmuni5_lbl 20231 `"San Lucas Camotlán"', add
label define mx2010a_migmuni5_lbl 20232 `"San Lucas Ojitlán"', add
label define mx2010a_migmuni5_lbl 20233 `"San Lucas Quiaviní"', add
label define mx2010a_migmuni5_lbl 20234 `"San Lucas Zoquiápam"', add
label define mx2010a_migmuni5_lbl 20235 `"San Luis Amatlán"', add
label define mx2010a_migmuni5_lbl 20236 `"San Marcial Ozolotepec"', add
label define mx2010a_migmuni5_lbl 20237 `"San Marcos Arteaga"', add
label define mx2010a_migmuni5_lbl 20238 `"San Martín de los Cansecos"', add
label define mx2010a_migmuni5_lbl 20239 `"San Martín Huamelúlpam"', add
label define mx2010a_migmuni5_lbl 20240 `"San Martín Itunyoso"', add
label define mx2010a_migmuni5_lbl 20241 `"San Martín Lachilá"', add
label define mx2010a_migmuni5_lbl 20242 `"San Martín Peras"', add
label define mx2010a_migmuni5_lbl 20243 `"San Martín Tilcajete"', add
label define mx2010a_migmuni5_lbl 20244 `"San Martín Toxpalan"', add
label define mx2010a_migmuni5_lbl 20245 `"San Martín Zacatepec"', add
label define mx2010a_migmuni5_lbl 20246 `"San Mateo Cajonos"', add
label define mx2010a_migmuni5_lbl 20247 `"Capulálpam de Méndez"', add
label define mx2010a_migmuni5_lbl 20248 `"San Mateo del Mar"', add
label define mx2010a_migmuni5_lbl 20249 `"San Mateo Yoloxochitlán"', add
label define mx2010a_migmuni5_lbl 20250 `"San Mateo Etlatongo"', add
label define mx2010a_migmuni5_lbl 20251 `"San Mateo Nejápam"', add
label define mx2010a_migmuni5_lbl 20252 `"San Mateo Peñasco"', add
label define mx2010a_migmuni5_lbl 20253 `"San Mateo Piñas"', add
label define mx2010a_migmuni5_lbl 20254 `"San Mateo Río Hondo"', add
label define mx2010a_migmuni5_lbl 20255 `"San Mateo Sindihui"', add
label define mx2010a_migmuni5_lbl 20256 `"San Mateo Tlapiltepec"', add
label define mx2010a_migmuni5_lbl 20257 `"San Melchor Betaza"', add
label define mx2010a_migmuni5_lbl 20258 `"San Miguel Achiutla"', add
label define mx2010a_migmuni5_lbl 20259 `"San Miguel Ahuehuetitlán"', add
label define mx2010a_migmuni5_lbl 20260 `"San Miguel Aloápam"', add
label define mx2010a_migmuni5_lbl 20261 `"San Miguel Amatitlán"', add
label define mx2010a_migmuni5_lbl 20262 `"San Miguel Amatlán"', add
label define mx2010a_migmuni5_lbl 20263 `"San Miguel Coatlán"', add
label define mx2010a_migmuni5_lbl 20264 `"San Miguel Chicahua"', add
label define mx2010a_migmuni5_lbl 20265 `"San Miguel Chimalapa"', add
label define mx2010a_migmuni5_lbl 20266 `"San Miguel del Puerto"', add
label define mx2010a_migmuni5_lbl 20267 `"San Miguel del Río"', add
label define mx2010a_migmuni5_lbl 20268 `"San Miguel Ejutla"', add
label define mx2010a_migmuni5_lbl 20269 `"San Miguel el Grande"', add
label define mx2010a_migmuni5_lbl 20270 `"San Miguel Huautla"', add
label define mx2010a_migmuni5_lbl 20271 `"San Miguel Mixtepec"', add
label define mx2010a_migmuni5_lbl 20272 `"San Miguel Panixtlahuaca"', add
label define mx2010a_migmuni5_lbl 20273 `"San Miguel Peras"', add
label define mx2010a_migmuni5_lbl 20274 `"San Miguel Piedras"', add
label define mx2010a_migmuni5_lbl 20275 `"San Miguel Quetzaltepec"', add
label define mx2010a_migmuni5_lbl 20276 `"San Miguel Santa Flor"', add
label define mx2010a_migmuni5_lbl 20277 `"Villa Sola de Vega"', add
label define mx2010a_migmuni5_lbl 20278 `"San Miguel Soyaltepec"', add
label define mx2010a_migmuni5_lbl 20279 `"San Miguel Suchixtepec"', add
label define mx2010a_migmuni5_lbl 20280 `"Villa Talea de Castro"', add
label define mx2010a_migmuni5_lbl 20281 `"San Miguel Tecomatlán"', add
label define mx2010a_migmuni5_lbl 20282 `"San Miguel Tenango"', add
label define mx2010a_migmuni5_lbl 20283 `"San Miguel Tequixtepec"', add
label define mx2010a_migmuni5_lbl 20284 `"San Miguel Tilquiápam"', add
label define mx2010a_migmuni5_lbl 20285 `"San Miguel Tlacamama"', add
label define mx2010a_migmuni5_lbl 20286 `"San Miguel Tlacotepec"', add
label define mx2010a_migmuni5_lbl 20287 `"San Miguel Tulancingo"', add
label define mx2010a_migmuni5_lbl 20288 `"San Miguel Yotao"', add
label define mx2010a_migmuni5_lbl 20289 `"San Nicolás"', add
label define mx2010a_migmuni5_lbl 20290 `"San Nicolás Hidalgo"', add
label define mx2010a_migmuni5_lbl 20291 `"San Pablo Coatlán"', add
label define mx2010a_migmuni5_lbl 20292 `"San Pablo Cuatro Venados"', add
label define mx2010a_migmuni5_lbl 20293 `"San Pablo Etla"', add
label define mx2010a_migmuni5_lbl 20294 `"San Pablo Huitzo"', add
label define mx2010a_migmuni5_lbl 20295 `"San Pablo Huixtepec"', add
label define mx2010a_migmuni5_lbl 20296 `"San Pablo Macuiltianguis"', add
label define mx2010a_migmuni5_lbl 20297 `"San Pablo Tijaltepec"', add
label define mx2010a_migmuni5_lbl 20298 `"San Pablo Villa de Mitla"', add
label define mx2010a_migmuni5_lbl 20299 `"San Pablo Yaganiza"', add
label define mx2010a_migmuni5_lbl 20300 `"San Pedro Amuzgos"', add
label define mx2010a_migmuni5_lbl 20301 `"San Pedro Apóstol"', add
label define mx2010a_migmuni5_lbl 20302 `"San Pedro Atoyac"', add
label define mx2010a_migmuni5_lbl 20303 `"San Pedro Cajonos"', add
label define mx2010a_migmuni5_lbl 20304 `"San Pedro Coxcaltepec Cántaros"', add
label define mx2010a_migmuni5_lbl 20305 `"San Pedro Comitancillo"', add
label define mx2010a_migmuni5_lbl 20306 `"San Pedro el Alto"', add
label define mx2010a_migmuni5_lbl 20307 `"San Pedro Huamelula"', add
label define mx2010a_migmuni5_lbl 20308 `"San Pedro Huilotepec"', add
label define mx2010a_migmuni5_lbl 20309 `"San Pedro Ixcatlán"', add
label define mx2010a_migmuni5_lbl 20310 `"San Pedro Ixtlahuaca"', add
label define mx2010a_migmuni5_lbl 20311 `"San Pedro Jaltepetongo"', add
label define mx2010a_migmuni5_lbl 20312 `"San Pedro Jicayán"', add
label define mx2010a_migmuni5_lbl 20313 `"San Pedro Jocotipac"', add
label define mx2010a_migmuni5_lbl 20314 `"San Pedro Juchatengo"', add
label define mx2010a_migmuni5_lbl 20315 `"San Pedro Mártir"', add
label define mx2010a_migmuni5_lbl 20316 `"San Pedro Mártir Quiechapa"', add
label define mx2010a_migmuni5_lbl 20317 `"San Pedro Mártir Yucuxaco"', add
label define mx2010a_migmuni5_lbl 20318 `"San Pedro Mixtepec - Dto. 22"', add
label define mx2010a_migmuni5_lbl 20319 `"San Pedro Mixtepec - Dto. 26"', add
label define mx2010a_migmuni5_lbl 20320 `"San Pedro Molinos"', add
label define mx2010a_migmuni5_lbl 20321 `"San Pedro Nopala"', add
label define mx2010a_migmuni5_lbl 20322 `"San Pedro Ocopetatillo"', add
label define mx2010a_migmuni5_lbl 20323 `"San Pedro Ocotepec"', add
label define mx2010a_migmuni5_lbl 20324 `"San Pedro Pochutla"', add
label define mx2010a_migmuni5_lbl 20325 `"San Pedro Quiatoni"', add
label define mx2010a_migmuni5_lbl 20326 `"San Pedro Sochiápam"', add
label define mx2010a_migmuni5_lbl 20327 `"San Pedro Tapanatepec"', add
label define mx2010a_migmuni5_lbl 20328 `"San Pedro Taviche"', add
label define mx2010a_migmuni5_lbl 20329 `"San Pedro Teozacoalco"', add
label define mx2010a_migmuni5_lbl 20330 `"San Pedro Teutila"', add
label define mx2010a_migmuni5_lbl 20331 `"San Pedro Tidaá"', add
label define mx2010a_migmuni5_lbl 20332 `"San Pedro Topiltepec"', add
label define mx2010a_migmuni5_lbl 20333 `"San Pedro Totolápam"', add
label define mx2010a_migmuni5_lbl 20334 `"Villa de Tututepec de Melchor Ocampo"', add
label define mx2010a_migmuni5_lbl 20335 `"San Pedro Yaneri"', add
label define mx2010a_migmuni5_lbl 20336 `"San Pedro Yólox"', add
label define mx2010a_migmuni5_lbl 20337 `"San Pedro y San Pablo Ayutla"', add
label define mx2010a_migmuni5_lbl 20338 `"Villa de Etla"', add
label define mx2010a_migmuni5_lbl 20339 `"San Pedro y San Pablo Teposcolula"', add
label define mx2010a_migmuni5_lbl 20340 `"San Pedro y San Pablo Tequixtepec"', add
label define mx2010a_migmuni5_lbl 20341 `"San Pedro Yucunama"', add
label define mx2010a_migmuni5_lbl 20342 `"San Raymundo Jalpan"', add
label define mx2010a_migmuni5_lbl 20343 `"San Sebastián Abasolo"', add
label define mx2010a_migmuni5_lbl 20344 `"San Sebastián Coatlán"', add
label define mx2010a_migmuni5_lbl 20345 `"San Sebastián Ixcapa"', add
label define mx2010a_migmuni5_lbl 20346 `"San Sebastián Nicananduta"', add
label define mx2010a_migmuni5_lbl 20347 `"San Sebastián Río Hondo"', add
label define mx2010a_migmuni5_lbl 20348 `"San Sebastián Tecomaxtlahuaca"', add
label define mx2010a_migmuni5_lbl 20349 `"San Sebastián Teitipac"', add
label define mx2010a_migmuni5_lbl 20350 `"San Sebastián Tutla"', add
label define mx2010a_migmuni5_lbl 20351 `"San Simón Almolongas"', add
label define mx2010a_migmuni5_lbl 20352 `"San Simón Zahuatlán"', add
label define mx2010a_migmuni5_lbl 20353 `"Santa Ana"', add
label define mx2010a_migmuni5_lbl 20354 `"Santa Ana Ateixtlahuaca"', add
label define mx2010a_migmuni5_lbl 20355 `"Santa Ana Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 20356 `"Santa Ana del Valle"', add
label define mx2010a_migmuni5_lbl 20357 `"Santa Ana Tavela"', add
label define mx2010a_migmuni5_lbl 20358 `"Santa Ana Tlapacoyan"', add
label define mx2010a_migmuni5_lbl 20359 `"Santa Ana Yareni"', add
label define mx2010a_migmuni5_lbl 20360 `"Santa Ana Zegache"', add
label define mx2010a_migmuni5_lbl 20361 `"Santa Catalina Quierí"', add
label define mx2010a_migmuni5_lbl 20362 `"Santa Catarina Cuixtla"', add
label define mx2010a_migmuni5_lbl 20363 `"Santa Catarina Ixtepeji"', add
label define mx2010a_migmuni5_lbl 20364 `"Santa Catarina Juquila"', add
label define mx2010a_migmuni5_lbl 20365 `"Santa Catarina Lachatao"', add
label define mx2010a_migmuni5_lbl 20366 `"Santa Catarina Loxicha"', add
label define mx2010a_migmuni5_lbl 20367 `"Santa Catarina Mechoacán"', add
label define mx2010a_migmuni5_lbl 20368 `"Santa Catarina Minas"', add
label define mx2010a_migmuni5_lbl 20369 `"Santa Catarina Quiané"', add
label define mx2010a_migmuni5_lbl 20370 `"Santa Catarina Tayata"', add
label define mx2010a_migmuni5_lbl 20371 `"Santa Catarina Ticuá"', add
label define mx2010a_migmuni5_lbl 20372 `"Santa Catarina Yosonotú"', add
label define mx2010a_migmuni5_lbl 20373 `"Santa Catarina Zapoquila"', add
label define mx2010a_migmuni5_lbl 20374 `"Santa Cruz Acatepec"', add
label define mx2010a_migmuni5_lbl 20375 `"Santa Cruz Amilpas"', add
label define mx2010a_migmuni5_lbl 20376 `"Santa Cruz de Bravo"', add
label define mx2010a_migmuni5_lbl 20377 `"Santa Cruz Itundujia"', add
label define mx2010a_migmuni5_lbl 20378 `"Santa Cruz Mixtepec"', add
label define mx2010a_migmuni5_lbl 20379 `"Santa Cruz Nundaco"', add
label define mx2010a_migmuni5_lbl 20380 `"Santa Cruz Papalutla"', add
label define mx2010a_migmuni5_lbl 20381 `"Santa Cruz Tacache de Mina"', add
label define mx2010a_migmuni5_lbl 20382 `"Santa Cruz Tacahua"', add
label define mx2010a_migmuni5_lbl 20383 `"Santa Cruz Tayata"', add
label define mx2010a_migmuni5_lbl 20384 `"Santa Cruz Xitla"', add
label define mx2010a_migmuni5_lbl 20385 `"Santa Cruz Xoxocotlán"', add
label define mx2010a_migmuni5_lbl 20386 `"Santa Cruz Zenzontepec"', add
label define mx2010a_migmuni5_lbl 20387 `"Santa Gertrudis"', add
label define mx2010a_migmuni5_lbl 20388 `"Santa Inés del Monte"', add
label define mx2010a_migmuni5_lbl 20389 `"Santa Inés Yatzeche"', add
label define mx2010a_migmuni5_lbl 20390 `"Santa Lucía del Camino"', add
label define mx2010a_migmuni5_lbl 20391 `"Santa Lucía Miahuatlán"', add
label define mx2010a_migmuni5_lbl 20392 `"Santa Lucía Monteverde"', add
label define mx2010a_migmuni5_lbl 20393 `"Santa Lucía Ocotlán"', add
label define mx2010a_migmuni5_lbl 20394 `"Santa María Alotepec"', add
label define mx2010a_migmuni5_lbl 20395 `"Santa María Apazco"', add
label define mx2010a_migmuni5_lbl 20396 `"Santa María la Asunción"', add
label define mx2010a_migmuni5_lbl 20397 `"Heroica Ciudad de Tlaxiaco"', add
label define mx2010a_migmuni5_lbl 20398 `"Ayoquezco de Aldama"', add
label define mx2010a_migmuni5_lbl 20399 `"Santa María Atzompa"', add
label define mx2010a_migmuni5_lbl 20400 `"Santa María Camotlán"', add
label define mx2010a_migmuni5_lbl 20401 `"Santa María Colotepec"', add
label define mx2010a_migmuni5_lbl 20402 `"Santa María Cortijo"', add
label define mx2010a_migmuni5_lbl 20403 `"Santa María Coyotepec"', add
label define mx2010a_migmuni5_lbl 20404 `"Santa María Chachoápam"', add
label define mx2010a_migmuni5_lbl 20405 `"Villa de Chilapa de Díaz"', add
label define mx2010a_migmuni5_lbl 20406 `"Santa María Chilchotla"', add
label define mx2010a_migmuni5_lbl 20407 `"Santa María Chimalapa"', add
label define mx2010a_migmuni5_lbl 20408 `"Santa María del Rosario"', add
label define mx2010a_migmuni5_lbl 20409 `"Santa María del Tule"', add
label define mx2010a_migmuni5_lbl 20410 `"Santa María Ecatepec"', add
label define mx2010a_migmuni5_lbl 20411 `"Santa María Guelacé"', add
label define mx2010a_migmuni5_lbl 20412 `"Santa María Guienagati"', add
label define mx2010a_migmuni5_lbl 20413 `"Santa María Huatulco"', add
label define mx2010a_migmuni5_lbl 20414 `"Santa María Huazolotitlán"', add
label define mx2010a_migmuni5_lbl 20415 `"Santa María Ipalapa"', add
label define mx2010a_migmuni5_lbl 20416 `"Santa María Ixcatlán"', add
label define mx2010a_migmuni5_lbl 20417 `"Santa María Jacatepec"', add
label define mx2010a_migmuni5_lbl 20418 `"Santa María Jalapa del Marqués"', add
label define mx2010a_migmuni5_lbl 20419 `"Santa María Jaltianguis"', add
label define mx2010a_migmuni5_lbl 20420 `"Santa María Lachixío"', add
label define mx2010a_migmuni5_lbl 20421 `"Santa María Mixtequilla"', add
label define mx2010a_migmuni5_lbl 20422 `"Santa María Nativitas"', add
label define mx2010a_migmuni5_lbl 20423 `"Santa María Nduayaco"', add
label define mx2010a_migmuni5_lbl 20424 `"Santa María Ozolotepec"', add
label define mx2010a_migmuni5_lbl 20425 `"Santa María Pápalo"', add
label define mx2010a_migmuni5_lbl 20426 `"Santa María Peñoles"', add
label define mx2010a_migmuni5_lbl 20427 `"Santa María Petapa"', add
label define mx2010a_migmuni5_lbl 20428 `"Santa María Quiegolani"', add
label define mx2010a_migmuni5_lbl 20429 `"Santa María Sola"', add
label define mx2010a_migmuni5_lbl 20430 `"Santa María Tataltepec"', add
label define mx2010a_migmuni5_lbl 20431 `"Santa María Tecomavaca"', add
label define mx2010a_migmuni5_lbl 20432 `"Santa María Temaxcalapa"', add
label define mx2010a_migmuni5_lbl 20433 `"Santa María Temaxcaltepec"', add
label define mx2010a_migmuni5_lbl 20434 `"Santa María Teopoxco"', add
label define mx2010a_migmuni5_lbl 20435 `"Santa María Tepantlali"', add
label define mx2010a_migmuni5_lbl 20436 `"Santa María Texcatitlán"', add
label define mx2010a_migmuni5_lbl 20437 `"Santa María Tlahuitoltepec"', add
label define mx2010a_migmuni5_lbl 20438 `"Santa María Tlalixtac"', add
label define mx2010a_migmuni5_lbl 20439 `"Santa María Tonameca"', add
label define mx2010a_migmuni5_lbl 20440 `"Santa María Totolapilla"', add
label define mx2010a_migmuni5_lbl 20441 `"Santa María Xadani"', add
label define mx2010a_migmuni5_lbl 20442 `"Santa María Yalina"', add
label define mx2010a_migmuni5_lbl 20443 `"Santa María Yavesía"', add
label define mx2010a_migmuni5_lbl 20444 `"Santa María Yolotepec"', add
label define mx2010a_migmuni5_lbl 20445 `"Santa María Yosoyúa"', add
label define mx2010a_migmuni5_lbl 20446 `"Santa María Yucuhiti"', add
label define mx2010a_migmuni5_lbl 20447 `"Santa María Zacatepec"', add
label define mx2010a_migmuni5_lbl 20448 `"Santa María Zaniza"', add
label define mx2010a_migmuni5_lbl 20449 `"Santa María Zoquitlán"', add
label define mx2010a_migmuni5_lbl 20450 `"Santiago Amoltepec"', add
label define mx2010a_migmuni5_lbl 20451 `"Santiago Apoala"', add
label define mx2010a_migmuni5_lbl 20452 `"Santiago Apóstol"', add
label define mx2010a_migmuni5_lbl 20453 `"Santiago Astata"', add
label define mx2010a_migmuni5_lbl 20454 `"Santiago Atitlán"', add
label define mx2010a_migmuni5_lbl 20455 `"Santiago Ayuquililla"', add
label define mx2010a_migmuni5_lbl 20456 `"Santiago Cacaloxtepec"', add
label define mx2010a_migmuni5_lbl 20457 `"Santiago Camotlán"', add
label define mx2010a_migmuni5_lbl 20458 `"Santiago Comaltepec"', add
label define mx2010a_migmuni5_lbl 20459 `"Santiago Chazumba"', add
label define mx2010a_migmuni5_lbl 20460 `"Santiago Choápam"', add
label define mx2010a_migmuni5_lbl 20461 `"Santiago del Río"', add
label define mx2010a_migmuni5_lbl 20462 `"Santiago Huajolotitlán"', add
label define mx2010a_migmuni5_lbl 20463 `"Santiago Huauclilla"', add
label define mx2010a_migmuni5_lbl 20464 `"Santiago Ihuitlán Plumas"', add
label define mx2010a_migmuni5_lbl 20465 `"Santiago Ixcuintepec"', add
label define mx2010a_migmuni5_lbl 20466 `"Santiago Ixtayutla"', add
label define mx2010a_migmuni5_lbl 20467 `"Santiago Jamiltepec"', add
label define mx2010a_migmuni5_lbl 20468 `"Santiago Jocotepec"', add
label define mx2010a_migmuni5_lbl 20469 `"Santiago Juxtlahuaca"', add
label define mx2010a_migmuni5_lbl 20470 `"Santiago Lachiguiri"', add
label define mx2010a_migmuni5_lbl 20471 `"Santiago Lalopa"', add
label define mx2010a_migmuni5_lbl 20472 `"Santiago Laollaga"', add
label define mx2010a_migmuni5_lbl 20473 `"Santiago Laxopa"', add
label define mx2010a_migmuni5_lbl 20474 `"Santiago Llano Grande"', add
label define mx2010a_migmuni5_lbl 20475 `"Santiago Matatlán"', add
label define mx2010a_migmuni5_lbl 20476 `"Santiago Miltepec"', add
label define mx2010a_migmuni5_lbl 20477 `"Santiago Minas"', add
label define mx2010a_migmuni5_lbl 20478 `"Santiago Nacaltepec"', add
label define mx2010a_migmuni5_lbl 20479 `"Santiago Nejapilla"', add
label define mx2010a_migmuni5_lbl 20480 `"Santiago Nundiche"', add
label define mx2010a_migmuni5_lbl 20481 `"Santiago Nuyoó"', add
label define mx2010a_migmuni5_lbl 20482 `"Santiago Pinotepa Nacional"', add
label define mx2010a_migmuni5_lbl 20483 `"Santiago Suchilquitongo"', add
label define mx2010a_migmuni5_lbl 20484 `"Santiago Tamazola"', add
label define mx2010a_migmuni5_lbl 20485 `"Santiago Tapextla"', add
label define mx2010a_migmuni5_lbl 20486 `"Villa Tejúpam de la Unión"', add
label define mx2010a_migmuni5_lbl 20487 `"Santiago Tenango"', add
label define mx2010a_migmuni5_lbl 20488 `"Santiago Tepetlapa"', add
label define mx2010a_migmuni5_lbl 20489 `"Santiago Tetepec"', add
label define mx2010a_migmuni5_lbl 20490 `"Santiago Texcalcingo"', add
label define mx2010a_migmuni5_lbl 20491 `"Santiago Textitlán"', add
label define mx2010a_migmuni5_lbl 20492 `"Santiago Tilantongo"', add
label define mx2010a_migmuni5_lbl 20493 `"Santiago Tillo"', add
label define mx2010a_migmuni5_lbl 20494 `"Santiago Tlazoyaltepec"', add
label define mx2010a_migmuni5_lbl 20495 `"Santiago Xanica"', add
label define mx2010a_migmuni5_lbl 20496 `"Santiago Xiacuí"', add
label define mx2010a_migmuni5_lbl 20497 `"Santiago Yaitepec"', add
label define mx2010a_migmuni5_lbl 20498 `"Santiago Yaveo"', add
label define mx2010a_migmuni5_lbl 20499 `"Santiago Yolomécatl"', add
label define mx2010a_migmuni5_lbl 20500 `"Santiago Yosondúa"', add
label define mx2010a_migmuni5_lbl 20501 `"Santiago Yucuyachi"', add
label define mx2010a_migmuni5_lbl 20502 `"Santiago Zacatepec"', add
label define mx2010a_migmuni5_lbl 20503 `"Santiago Zoochila"', add
label define mx2010a_migmuni5_lbl 20504 `"Nuevo Zoquiápam"', add
label define mx2010a_migmuni5_lbl 20505 `"Santo Domingo Ingenio"', add
label define mx2010a_migmuni5_lbl 20506 `"Santo Domingo Albarradas"', add
label define mx2010a_migmuni5_lbl 20507 `"Santo Domingo Armenta"', add
label define mx2010a_migmuni5_lbl 20508 `"Santo Domingo Chihuitán"', add
label define mx2010a_migmuni5_lbl 20509 `"Santo Domingo de Morelos"', add
label define mx2010a_migmuni5_lbl 20510 `"Santo Domingo Ixcatlán"', add
label define mx2010a_migmuni5_lbl 20511 `"Santo Domingo Nuxaá"', add
label define mx2010a_migmuni5_lbl 20512 `"Santo Domingo Ozolotepec"', add
label define mx2010a_migmuni5_lbl 20513 `"Santo Domingo Petapa"', add
label define mx2010a_migmuni5_lbl 20514 `"Santo Domingo Roayaga"', add
label define mx2010a_migmuni5_lbl 20515 `"Santo Domingo Tehuantepec"', add
label define mx2010a_migmuni5_lbl 20516 `"Santo Domingo Teojomulco"', add
label define mx2010a_migmuni5_lbl 20517 `"Santo Domingo Tepuxtepec"', add
label define mx2010a_migmuni5_lbl 20518 `"Santo Domingo Tlatayápam"', add
label define mx2010a_migmuni5_lbl 20519 `"Santo Domingo Tomaltepec"', add
label define mx2010a_migmuni5_lbl 20520 `"Santo Domingo Tonalá"', add
label define mx2010a_migmuni5_lbl 20521 `"Santo Domingo Tonaltepec"', add
label define mx2010a_migmuni5_lbl 20522 `"Santo Domingo Xagacía"', add
label define mx2010a_migmuni5_lbl 20523 `"Santo Domingo Yanhuitlán"', add
label define mx2010a_migmuni5_lbl 20524 `"Santo Domingo Yodohino"', add
label define mx2010a_migmuni5_lbl 20525 `"Santo Domingo Zanatepec"', add
label define mx2010a_migmuni5_lbl 20526 `"Santos Reyes Nopala"', add
label define mx2010a_migmuni5_lbl 20527 `"Santos Reyes Pápalo"', add
label define mx2010a_migmuni5_lbl 20528 `"Santos Reyes Tepejillo"', add
label define mx2010a_migmuni5_lbl 20529 `"Santos Reyes Yucuná"', add
label define mx2010a_migmuni5_lbl 20530 `"Santo Tomás Jalieza"', add
label define mx2010a_migmuni5_lbl 20531 `"Santo Tomás Mazaltepec"', add
label define mx2010a_migmuni5_lbl 20532 `"Santo Tomás Ocotepec"', add
label define mx2010a_migmuni5_lbl 20533 `"Santo Tomás Tamazulapan"', add
label define mx2010a_migmuni5_lbl 20534 `"San Vicente Coatlán"', add
label define mx2010a_migmuni5_lbl 20535 `"San Vicente Lachixío"', add
label define mx2010a_migmuni5_lbl 20536 `"San Vicente Nuñú"', add
label define mx2010a_migmuni5_lbl 20537 `"Silacayoápam"', add
label define mx2010a_migmuni5_lbl 20538 `"Sitio de Xitlapehua"', add
label define mx2010a_migmuni5_lbl 20539 `"Soledad Etla"', add
label define mx2010a_migmuni5_lbl 20540 `"Villa de Tamazulápam del Progreso"', add
label define mx2010a_migmuni5_lbl 20541 `"Tanetze de Zaragoza"', add
label define mx2010a_migmuni5_lbl 20542 `"Taniche"', add
label define mx2010a_migmuni5_lbl 20543 `"Tataltepec de Valdés"', add
label define mx2010a_migmuni5_lbl 20544 `"Teococuilco de Marcos Pérez"', add
label define mx2010a_migmuni5_lbl 20545 `"Teotitlán de Flores Magón"', add
label define mx2010a_migmuni5_lbl 20546 `"Teotitlán del Valle"', add
label define mx2010a_migmuni5_lbl 20547 `"Teotongo"', add
label define mx2010a_migmuni5_lbl 20548 `"Tepelmeme Villa de Morelos"', add
label define mx2010a_migmuni5_lbl 20549 `"Tezoatlán de Segura y Luna"', add
label define mx2010a_migmuni5_lbl 20550 `"San Jerónimo Tlacochahuaya"', add
label define mx2010a_migmuni5_lbl 20551 `"Tlacolula de Matamoros"', add
label define mx2010a_migmuni5_lbl 20552 `"Tlacotepec Plumas"', add
label define mx2010a_migmuni5_lbl 20553 `"Tlalixtac de Cabrera"', add
label define mx2010a_migmuni5_lbl 20554 `"Totontepec Villa de Morelos"', add
label define mx2010a_migmuni5_lbl 20555 `"Trinidad Zaachila"', add
label define mx2010a_migmuni5_lbl 20556 `"La Trinidad Vista Hermosa"', add
label define mx2010a_migmuni5_lbl 20557 `"Unión Hidalgo"', add
label define mx2010a_migmuni5_lbl 20558 `"Valerio Trujano"', add
label define mx2010a_migmuni5_lbl 20559 `"San Juan Bautista Valle Nacional"', add
label define mx2010a_migmuni5_lbl 20560 `"Villa Díaz Ordaz"', add
label define mx2010a_migmuni5_lbl 20561 `"Yaxe"', add
label define mx2010a_migmuni5_lbl 20562 `"Magdalena Yodocono de Porfirio Díaz"', add
label define mx2010a_migmuni5_lbl 20563 `"Yogana"', add
label define mx2010a_migmuni5_lbl 20564 `"Yutanduchi de Guerrero"', add
label define mx2010a_migmuni5_lbl 20565 `"Villa de Zaachila"', add
label define mx2010a_migmuni5_lbl 20566 `"San Mateo Yucutindó"', add
label define mx2010a_migmuni5_lbl 20567 `"Zapotitlán Lagunas"', add
label define mx2010a_migmuni5_lbl 20568 `"Zapotitlán Palmas"', add
label define mx2010a_migmuni5_lbl 20569 `"Santa Inés de Zaragoza"', add
label define mx2010a_migmuni5_lbl 20570 `"Zimatlán de Álvarez"', add
label define mx2010a_migmuni5_lbl 20999 `"Oaxaca entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 21001 `"Acajete"', add
label define mx2010a_migmuni5_lbl 21002 `"Acateno"', add
label define mx2010a_migmuni5_lbl 21003 `"Acatlán"', add
label define mx2010a_migmuni5_lbl 21004 `"Acatzingo"', add
label define mx2010a_migmuni5_lbl 21005 `"Acteopan"', add
label define mx2010a_migmuni5_lbl 21006 `"Ahuacatlán"', add
label define mx2010a_migmuni5_lbl 21007 `"Ahuatlán"', add
label define mx2010a_migmuni5_lbl 21008 `"Ahuazotepec"', add
label define mx2010a_migmuni5_lbl 21009 `"Ahuehuetitla"', add
label define mx2010a_migmuni5_lbl 21010 `"Ajalpan"', add
label define mx2010a_migmuni5_lbl 21011 `"Albino Zertuche"', add
label define mx2010a_migmuni5_lbl 21012 `"Aljojuca"', add
label define mx2010a_migmuni5_lbl 21013 `"Altepexi"', add
label define mx2010a_migmuni5_lbl 21014 `"Amixtlán"', add
label define mx2010a_migmuni5_lbl 21015 `"Amozoc"', add
label define mx2010a_migmuni5_lbl 21016 `"Aquixtla"', add
label define mx2010a_migmuni5_lbl 21017 `"Atempan"', add
label define mx2010a_migmuni5_lbl 21018 `"Atexcal"', add
label define mx2010a_migmuni5_lbl 21019 `"Atlixco"', add
label define mx2010a_migmuni5_lbl 21020 `"Atoyatempan"', add
label define mx2010a_migmuni5_lbl 21021 `"Atzala"', add
label define mx2010a_migmuni5_lbl 21022 `"Atzitzihuacán"', add
label define mx2010a_migmuni5_lbl 21023 `"Atzitzintla"', add
label define mx2010a_migmuni5_lbl 21024 `"Axutla"', add
label define mx2010a_migmuni5_lbl 21025 `"Ayotoxco de Guerrero"', add
label define mx2010a_migmuni5_lbl 21026 `"Calpan"', add
label define mx2010a_migmuni5_lbl 21027 `"Caltepec"', add
label define mx2010a_migmuni5_lbl 21028 `"Camocuautla"', add
label define mx2010a_migmuni5_lbl 21029 `"Caxhuacan"', add
label define mx2010a_migmuni5_lbl 21030 `"Coatepec"', add
label define mx2010a_migmuni5_lbl 21031 `"Coatzingo"', add
label define mx2010a_migmuni5_lbl 21032 `"Cohetzala"', add
label define mx2010a_migmuni5_lbl 21033 `"Cohuecan"', add
label define mx2010a_migmuni5_lbl 21034 `"Coronango"', add
label define mx2010a_migmuni5_lbl 21035 `"Coxcatlán"', add
label define mx2010a_migmuni5_lbl 21036 `"Coyomeapan"', add
label define mx2010a_migmuni5_lbl 21037 `"Coyotepec"', add
label define mx2010a_migmuni5_lbl 21038 `"Cuapiaxtla de Madero"', add
label define mx2010a_migmuni5_lbl 21039 `"Cuautempan"', add
label define mx2010a_migmuni5_lbl 21040 `"Cuautinchán"', add
label define mx2010a_migmuni5_lbl 21041 `"Cuautlancingo"', add
label define mx2010a_migmuni5_lbl 21042 `"Cuayuca de Andrade"', add
label define mx2010a_migmuni5_lbl 21043 `"Cuetzalan del Progreso"', add
label define mx2010a_migmuni5_lbl 21044 `"Cuyoaco"', add
label define mx2010a_migmuni5_lbl 21045 `"Chalchicomula de Sesma"', add
label define mx2010a_migmuni5_lbl 21046 `"Chapulco"', add
label define mx2010a_migmuni5_lbl 21047 `"Chiautla"', add
label define mx2010a_migmuni5_lbl 21048 `"Chiautzingo"', add
label define mx2010a_migmuni5_lbl 21049 `"Chiconcuautla"', add
label define mx2010a_migmuni5_lbl 21050 `"Chichiquila"', add
label define mx2010a_migmuni5_lbl 21051 `"Chietla"', add
label define mx2010a_migmuni5_lbl 21052 `"Chigmecatitlán"', add
label define mx2010a_migmuni5_lbl 21053 `"Chignahuapan"', add
label define mx2010a_migmuni5_lbl 21054 `"Chignautla"', add
label define mx2010a_migmuni5_lbl 21055 `"Chila"', add
label define mx2010a_migmuni5_lbl 21056 `"Chila de la Sal"', add
label define mx2010a_migmuni5_lbl 21057 `"Honey"', add
label define mx2010a_migmuni5_lbl 21058 `"Chilchotla"', add
label define mx2010a_migmuni5_lbl 21059 `"Chinantla"', add
label define mx2010a_migmuni5_lbl 21060 `"Domingo Arenas"', add
label define mx2010a_migmuni5_lbl 21061 `"Eloxochitlán"', add
label define mx2010a_migmuni5_lbl 21062 `"Epatlán"', add
label define mx2010a_migmuni5_lbl 21063 `"Esperanza"', add
label define mx2010a_migmuni5_lbl 21064 `"Francisco Z. Mena"', add
label define mx2010a_migmuni5_lbl 21065 `"General Felipe Ángeles"', add
label define mx2010a_migmuni5_lbl 21066 `"Guadalupe"', add
label define mx2010a_migmuni5_lbl 21067 `"Guadalupe Victoria"', add
label define mx2010a_migmuni5_lbl 21068 `"Hermenegildo Galeana"', add
label define mx2010a_migmuni5_lbl 21069 `"Huaquechula"', add
label define mx2010a_migmuni5_lbl 21070 `"Huatlatlauca"', add
label define mx2010a_migmuni5_lbl 21071 `"Huauchinango"', add
label define mx2010a_migmuni5_lbl 21072 `"Huehuetla"', add
label define mx2010a_migmuni5_lbl 21073 `"Huehuetlán el Chico"', add
label define mx2010a_migmuni5_lbl 21074 `"Huejotzingo"', add
label define mx2010a_migmuni5_lbl 21075 `"Hueyapan"', add
label define mx2010a_migmuni5_lbl 21076 `"Hueytamalco"', add
label define mx2010a_migmuni5_lbl 21077 `"Hueytlalpan"', add
label define mx2010a_migmuni5_lbl 21078 `"Huitzilan de Serdán"', add
label define mx2010a_migmuni5_lbl 21079 `"Huitziltepec"', add
label define mx2010a_migmuni5_lbl 21080 `"Atlequizayan"', add
label define mx2010a_migmuni5_lbl 21081 `"Ixcamilpa de Guerrero"', add
label define mx2010a_migmuni5_lbl 21082 `"Ixcaquixtla"', add
label define mx2010a_migmuni5_lbl 21083 `"Ixtacamaxtitlán"', add
label define mx2010a_migmuni5_lbl 21084 `"Ixtepec"', add
label define mx2010a_migmuni5_lbl 21085 `"Izúcar de Matamoros"', add
label define mx2010a_migmuni5_lbl 21086 `"Jalpan"', add
label define mx2010a_migmuni5_lbl 21087 `"Jolalpan"', add
label define mx2010a_migmuni5_lbl 21088 `"Jonotla"', add
label define mx2010a_migmuni5_lbl 21089 `"Jopala"', add
label define mx2010a_migmuni5_lbl 21090 `"Juan C. Bonilla"', add
label define mx2010a_migmuni5_lbl 21091 `"Juan Galindo"', add
label define mx2010a_migmuni5_lbl 21092 `"Juan N. Méndez"', add
label define mx2010a_migmuni5_lbl 21093 `"Lafragua"', add
label define mx2010a_migmuni5_lbl 21094 `"Libres"', add
label define mx2010a_migmuni5_lbl 21095 `"La Magdalena Tlatlauquitepec"', add
label define mx2010a_migmuni5_lbl 21096 `"Mazapiltepec de Juárez"', add
label define mx2010a_migmuni5_lbl 21097 `"Mixtla"', add
label define mx2010a_migmuni5_lbl 21098 `"Molcaxac"', add
label define mx2010a_migmuni5_lbl 21099 `"Cañada Morelos"', add
label define mx2010a_migmuni5_lbl 21100 `"Naupan"', add
label define mx2010a_migmuni5_lbl 21101 `"Nauzontla"', add
label define mx2010a_migmuni5_lbl 21102 `"Nealtican"', add
label define mx2010a_migmuni5_lbl 21103 `"Nicolás Bravo"', add
label define mx2010a_migmuni5_lbl 21104 `"Nopalucan"', add
label define mx2010a_migmuni5_lbl 21105 `"Ocotepec"', add
label define mx2010a_migmuni5_lbl 21106 `"Ocoyucan"', add
label define mx2010a_migmuni5_lbl 21107 `"Olintla"', add
label define mx2010a_migmuni5_lbl 21108 `"Oriental"', add
label define mx2010a_migmuni5_lbl 21109 `"Pahuatlán"', add
label define mx2010a_migmuni5_lbl 21110 `"Palmar de Bravo"', add
label define mx2010a_migmuni5_lbl 21111 `"Pantepec"', add
label define mx2010a_migmuni5_lbl 21112 `"Petlalcingo"', add
label define mx2010a_migmuni5_lbl 21113 `"Piaxtla"', add
label define mx2010a_migmuni5_lbl 21114 `"Puebla"', add
label define mx2010a_migmuni5_lbl 21115 `"Quecholac"', add
label define mx2010a_migmuni5_lbl 21116 `"Quimixtlán"', add
label define mx2010a_migmuni5_lbl 21117 `"Rafael Lara Grajales"', add
label define mx2010a_migmuni5_lbl 21118 `"Los Reyes de Juárez"', add
label define mx2010a_migmuni5_lbl 21119 `"San Andrés Cholula"', add
label define mx2010a_migmuni5_lbl 21120 `"San Antonio Cañada"', add
label define mx2010a_migmuni5_lbl 21121 `"San Diego la Mesa Tochimiltzingo"', add
label define mx2010a_migmuni5_lbl 21122 `"San Felipe Teotlalcingo"', add
label define mx2010a_migmuni5_lbl 21123 `"San Felipe Tepatlán"', add
label define mx2010a_migmuni5_lbl 21124 `"San Gabriel Chilac"', add
label define mx2010a_migmuni5_lbl 21125 `"San Gregorio Atzompa"', add
label define mx2010a_migmuni5_lbl 21126 `"San Jerónimo Tecuanipan"', add
label define mx2010a_migmuni5_lbl 21127 `"San Jerónimo Xayacatlán"', add
label define mx2010a_migmuni5_lbl 21128 `"San José Chiapa"', add
label define mx2010a_migmuni5_lbl 21129 `"San José Miahuatlán"', add
label define mx2010a_migmuni5_lbl 21130 `"San Juan Atenco"', add
label define mx2010a_migmuni5_lbl 21131 `"San Juan Atzompa"', add
label define mx2010a_migmuni5_lbl 21132 `"San Martín Texmelucan"', add
label define mx2010a_migmuni5_lbl 21133 `"San Martín Totoltepec"', add
label define mx2010a_migmuni5_lbl 21134 `"San Matías Tlalancaleca"', add
label define mx2010a_migmuni5_lbl 21135 `"San Miguel Ixitlán"', add
label define mx2010a_migmuni5_lbl 21136 `"San Miguel Xoxtla"', add
label define mx2010a_migmuni5_lbl 21137 `"San Nicolás Buenos Aires"', add
label define mx2010a_migmuni5_lbl 21138 `"San Nicolás de los Ranchos"', add
label define mx2010a_migmuni5_lbl 21139 `"San Pablo Anicano"', add
label define mx2010a_migmuni5_lbl 21140 `"San Pedro Cholula"', add
label define mx2010a_migmuni5_lbl 21141 `"San Pedro Yeloixtlahuaca"', add
label define mx2010a_migmuni5_lbl 21142 `"San Salvador el Seco"', add
label define mx2010a_migmuni5_lbl 21143 `"San Salvador el Verde"', add
label define mx2010a_migmuni5_lbl 21144 `"San Salvador Huixcolotla"', add
label define mx2010a_migmuni5_lbl 21145 `"San Sebastián Tlacotepec"', add
label define mx2010a_migmuni5_lbl 21146 `"Santa Catarina Tlaltempan"', add
label define mx2010a_migmuni5_lbl 21147 `"Santa Inés Ahuatempan"', add
label define mx2010a_migmuni5_lbl 21148 `"Santa Isabel Cholula"', add
label define mx2010a_migmuni5_lbl 21149 `"Santiago Miahuatlán"', add
label define mx2010a_migmuni5_lbl 21150 `"Huehuetlán el Grande"', add
label define mx2010a_migmuni5_lbl 21151 `"Santo Tomás Hueyotlipan"', add
label define mx2010a_migmuni5_lbl 21152 `"Soltepec"', add
label define mx2010a_migmuni5_lbl 21153 `"Tecali de Herrera"', add
label define mx2010a_migmuni5_lbl 21154 `"Tecamachalco"', add
label define mx2010a_migmuni5_lbl 21155 `"Tecomatlán"', add
label define mx2010a_migmuni5_lbl 21156 `"Tehuacán"', add
label define mx2010a_migmuni5_lbl 21157 `"Tehuitzingo"', add
label define mx2010a_migmuni5_lbl 21158 `"Tenampulco"', add
label define mx2010a_migmuni5_lbl 21159 `"Teopantlán"', add
label define mx2010a_migmuni5_lbl 21160 `"Teotlalco"', add
label define mx2010a_migmuni5_lbl 21161 `"Tepanco de López"', add
label define mx2010a_migmuni5_lbl 21162 `"Tepango de Rodríguez"', add
label define mx2010a_migmuni5_lbl 21163 `"Tepatlaxco de Hidalgo"', add
label define mx2010a_migmuni5_lbl 21164 `"Tepeaca"', add
label define mx2010a_migmuni5_lbl 21165 `"Tepemaxalco"', add
label define mx2010a_migmuni5_lbl 21166 `"Tepeojuma"', add
label define mx2010a_migmuni5_lbl 21167 `"Tepetzintla"', add
label define mx2010a_migmuni5_lbl 21168 `"Tepexco"', add
label define mx2010a_migmuni5_lbl 21169 `"Tepexi de Rodríguez"', add
label define mx2010a_migmuni5_lbl 21170 `"Tepeyahualco"', add
label define mx2010a_migmuni5_lbl 21171 `"Tepeyahualco de Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 21172 `"Tetela de Ocampo"', add
label define mx2010a_migmuni5_lbl 21173 `"Teteles de Avila Castillo"', add
label define mx2010a_migmuni5_lbl 21174 `"Teziutlán"', add
label define mx2010a_migmuni5_lbl 21175 `"Tianguismanalco"', add
label define mx2010a_migmuni5_lbl 21176 `"Tilapa"', add
label define mx2010a_migmuni5_lbl 21177 `"Tlacotepec de Benito Juárez"', add
label define mx2010a_migmuni5_lbl 21178 `"Tlacuilotepec"', add
label define mx2010a_migmuni5_lbl 21179 `"Tlachichuca"', add
label define mx2010a_migmuni5_lbl 21180 `"Tlahuapan"', add
label define mx2010a_migmuni5_lbl 21181 `"Tlaltenango"', add
label define mx2010a_migmuni5_lbl 21182 `"Tlanepantla"', add
label define mx2010a_migmuni5_lbl 21183 `"Tlaola"', add
label define mx2010a_migmuni5_lbl 21184 `"Tlapacoya"', add
label define mx2010a_migmuni5_lbl 21185 `"Tlapanalá"', add
label define mx2010a_migmuni5_lbl 21186 `"Tlatlauquitepec"', add
label define mx2010a_migmuni5_lbl 21187 `"Tlaxco"', add
label define mx2010a_migmuni5_lbl 21188 `"Tochimilco"', add
label define mx2010a_migmuni5_lbl 21189 `"Tochtepec"', add
label define mx2010a_migmuni5_lbl 21190 `"Totoltepec de Guerrero"', add
label define mx2010a_migmuni5_lbl 21191 `"Tulcingo"', add
label define mx2010a_migmuni5_lbl 21192 `"Tuzamapan de Galeana"', add
label define mx2010a_migmuni5_lbl 21193 `"Tzicatlacoyan"', add
label define mx2010a_migmuni5_lbl 21194 `"Venustiano Carranza"', add
label define mx2010a_migmuni5_lbl 21195 `"Vicente Guerrero"', add
label define mx2010a_migmuni5_lbl 21196 `"Xayacatlán de Bravo"', add
label define mx2010a_migmuni5_lbl 21197 `"Xicotepec"', add
label define mx2010a_migmuni5_lbl 21198 `"Xicotlán"', add
label define mx2010a_migmuni5_lbl 21199 `"Xiutetelco"', add
label define mx2010a_migmuni5_lbl 21200 `"Xochiapulco"', add
label define mx2010a_migmuni5_lbl 21201 `"Xochiltepec"', add
label define mx2010a_migmuni5_lbl 21202 `"Xochitlán de Vicente Suárez"', add
label define mx2010a_migmuni5_lbl 21203 `"Xochitlán Todos Santos"', add
label define mx2010a_migmuni5_lbl 21204 `"Yaonáhuac"', add
label define mx2010a_migmuni5_lbl 21205 `"Yehualtepec"', add
label define mx2010a_migmuni5_lbl 21206 `"Zacapala"', add
label define mx2010a_migmuni5_lbl 21207 `"Zacapoaxtla"', add
label define mx2010a_migmuni5_lbl 21208 `"Zacatlán"', add
label define mx2010a_migmuni5_lbl 21209 `"Zapotitlán"', add
label define mx2010a_migmuni5_lbl 21210 `"Zapotitlán de Méndez"', add
label define mx2010a_migmuni5_lbl 21211 `"Zaragoza"', add
label define mx2010a_migmuni5_lbl 21212 `"Zautla"', add
label define mx2010a_migmuni5_lbl 21213 `"Zihuateutla"', add
label define mx2010a_migmuni5_lbl 21214 `"Zinacatepec"', add
label define mx2010a_migmuni5_lbl 21215 `"Zongozotla"', add
label define mx2010a_migmuni5_lbl 21216 `"Zoquiapan"', add
label define mx2010a_migmuni5_lbl 21217 `"Zoquitlán"', add
label define mx2010a_migmuni5_lbl 21999 `"Puebla entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 22001 `"Amealco de Bonfil"', add
label define mx2010a_migmuni5_lbl 22002 `"Pinal de Amoles"', add
label define mx2010a_migmuni5_lbl 22003 `"Arroyo Seco"', add
label define mx2010a_migmuni5_lbl 22004 `"Cadereyta de Montes"', add
label define mx2010a_migmuni5_lbl 22005 `"Colón"', add
label define mx2010a_migmuni5_lbl 22006 `"Corregidora"', add
label define mx2010a_migmuni5_lbl 22007 `"Ezequiel Montes"', add
label define mx2010a_migmuni5_lbl 22008 `"Huimilpan"', add
label define mx2010a_migmuni5_lbl 22009 `"Jalpan de Serra"', add
label define mx2010a_migmuni5_lbl 22010 `"Landa de Matamoros"', add
label define mx2010a_migmuni5_lbl 22011 `"El Marqués"', add
label define mx2010a_migmuni5_lbl 22012 `"Pedro Escobedo"', add
label define mx2010a_migmuni5_lbl 22013 `"Peñamiller"', add
label define mx2010a_migmuni5_lbl 22014 `"Querétaro"', add
label define mx2010a_migmuni5_lbl 22015 `"San Joaquín"', add
label define mx2010a_migmuni5_lbl 22016 `"San Juan del Río"', add
label define mx2010a_migmuni5_lbl 22017 `"Tequisquiapan"', add
label define mx2010a_migmuni5_lbl 22018 `"Tolimán"', add
label define mx2010a_migmuni5_lbl 22999 `"Querétaro entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 23001 `"Cozumel"', add
label define mx2010a_migmuni5_lbl 23002 `"Felipe Carrillo Puerto"', add
label define mx2010a_migmuni5_lbl 23003 `"Isla Mujeres"', add
label define mx2010a_migmuni5_lbl 23004 `"Othón P. Blanco"', add
label define mx2010a_migmuni5_lbl 23005 `"Benito Juárez"', add
label define mx2010a_migmuni5_lbl 23006 `"José María Morelos"', add
label define mx2010a_migmuni5_lbl 23007 `"Lázaro Cárdenas"', add
label define mx2010a_migmuni5_lbl 23008 `"Solidaridad"', add
label define mx2010a_migmuni5_lbl 23009 `"Tulum"', add
label define mx2010a_migmuni5_lbl 23999 `"Quintana Roo entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 24001 `"Ahualulco"', add
label define mx2010a_migmuni5_lbl 24002 `"Alaquines"', add
label define mx2010a_migmuni5_lbl 24003 `"Aquismón"', add
label define mx2010a_migmuni5_lbl 24004 `"Armadillo de los Infante"', add
label define mx2010a_migmuni5_lbl 24005 `"Cárdenas"', add
label define mx2010a_migmuni5_lbl 24006 `"Catorce"', add
label define mx2010a_migmuni5_lbl 24007 `"Cedral"', add
label define mx2010a_migmuni5_lbl 24008 `"Cerritos"', add
label define mx2010a_migmuni5_lbl 24009 `"Cerro de San Pedro"', add
label define mx2010a_migmuni5_lbl 24010 `"Ciudad del Maíz"', add
label define mx2010a_migmuni5_lbl 24011 `"Ciudad Fernández"', add
label define mx2010a_migmuni5_lbl 24012 `"Tancanhuitz"', add
label define mx2010a_migmuni5_lbl 24013 `"Ciudad Valles"', add
label define mx2010a_migmuni5_lbl 24014 `"Coxcatlán"', add
label define mx2010a_migmuni5_lbl 24015 `"Charcas"', add
label define mx2010a_migmuni5_lbl 24016 `"Ebano"', add
label define mx2010a_migmuni5_lbl 24017 `"Guadalcázar"', add
label define mx2010a_migmuni5_lbl 24018 `"Huehuetlán"', add
label define mx2010a_migmuni5_lbl 24019 `"Lagunillas"', add
label define mx2010a_migmuni5_lbl 24020 `"Matehuala"', add
label define mx2010a_migmuni5_lbl 24021 `"Mexquitic de Carmona"', add
label define mx2010a_migmuni5_lbl 24022 `"Moctezuma"', add
label define mx2010a_migmuni5_lbl 24023 `"Rayón"', add
label define mx2010a_migmuni5_lbl 24024 `"Rioverde"', add
label define mx2010a_migmuni5_lbl 24025 `"Salinas"', add
label define mx2010a_migmuni5_lbl 24026 `"San Antonio"', add
label define mx2010a_migmuni5_lbl 24027 `"San Ciro de Acosta"', add
label define mx2010a_migmuni5_lbl 24028 `"San Luis Potosí"', add
label define mx2010a_migmuni5_lbl 24029 `"San Martín Chalchicuautla"', add
label define mx2010a_migmuni5_lbl 24030 `"San Nicolás Tolentino"', add
label define mx2010a_migmuni5_lbl 24031 `"Santa Catarina"', add
label define mx2010a_migmuni5_lbl 24032 `"Santa María del Río"', add
label define mx2010a_migmuni5_lbl 24033 `"Santo Domingo"', add
label define mx2010a_migmuni5_lbl 24034 `"San Vicente Tancuayalab"', add
label define mx2010a_migmuni5_lbl 24035 `"Soledad de Graciano Sánchez"', add
label define mx2010a_migmuni5_lbl 24036 `"Tamasopo"', add
label define mx2010a_migmuni5_lbl 24037 `"Tamazunchale"', add
label define mx2010a_migmuni5_lbl 24038 `"Tampacán"', add
label define mx2010a_migmuni5_lbl 24039 `"Tampamolón Corona"', add
label define mx2010a_migmuni5_lbl 24040 `"Tamuín"', add
label define mx2010a_migmuni5_lbl 24041 `"Tanlajás"', add
label define mx2010a_migmuni5_lbl 24042 `"Tanquián de Escobedo"', add
label define mx2010a_migmuni5_lbl 24043 `"Tierra Nueva"', add
label define mx2010a_migmuni5_lbl 24044 `"Vanegas"', add
label define mx2010a_migmuni5_lbl 24045 `"Venado"', add
label define mx2010a_migmuni5_lbl 24046 `"Villa de Arriaga"', add
label define mx2010a_migmuni5_lbl 24047 `"Villa de Guadalupe"', add
label define mx2010a_migmuni5_lbl 24048 `"Villa de la Paz"', add
label define mx2010a_migmuni5_lbl 24049 `"Villa de Ramos"', add
label define mx2010a_migmuni5_lbl 24050 `"Villa de Reyes"', add
label define mx2010a_migmuni5_lbl 24051 `"Villa Hidalgo"', add
label define mx2010a_migmuni5_lbl 24052 `"Villa Juárez"', add
label define mx2010a_migmuni5_lbl 24053 `"Axtla de Terrazas"', add
label define mx2010a_migmuni5_lbl 24054 `"Xilitla"', add
label define mx2010a_migmuni5_lbl 24055 `"Zaragoza"', add
label define mx2010a_migmuni5_lbl 24056 `"Villa de Arista"', add
label define mx2010a_migmuni5_lbl 24057 `"Matlapa"', add
label define mx2010a_migmuni5_lbl 24058 `"El Naranjo"', add
label define mx2010a_migmuni5_lbl 24999 `"San Luis Potosí entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 25001 `"Ahome"', add
label define mx2010a_migmuni5_lbl 25002 `"Angostura"', add
label define mx2010a_migmuni5_lbl 25003 `"Badiraguato"', add
label define mx2010a_migmuni5_lbl 25004 `"Concordia"', add
label define mx2010a_migmuni5_lbl 25005 `"Cosalá"', add
label define mx2010a_migmuni5_lbl 25006 `"Culiacán"', add
label define mx2010a_migmuni5_lbl 25007 `"Choix"', add
label define mx2010a_migmuni5_lbl 25008 `"Elota"', add
label define mx2010a_migmuni5_lbl 25009 `"Escuinapa"', add
label define mx2010a_migmuni5_lbl 25010 `"El Fuerte"', add
label define mx2010a_migmuni5_lbl 25011 `"Guasave"', add
label define mx2010a_migmuni5_lbl 25012 `"Mazatlán"', add
label define mx2010a_migmuni5_lbl 25013 `"Mocorito"', add
label define mx2010a_migmuni5_lbl 25014 `"Rosario"', add
label define mx2010a_migmuni5_lbl 25015 `"Salvador Alvarado"', add
label define mx2010a_migmuni5_lbl 25016 `"San Ignacio"', add
label define mx2010a_migmuni5_lbl 25017 `"Sinaloa"', add
label define mx2010a_migmuni5_lbl 25018 `"Navolato"', add
label define mx2010a_migmuni5_lbl 25999 `"Sinaloa entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 26001 `"Aconchi"', add
label define mx2010a_migmuni5_lbl 26002 `"Agua Prieta"', add
label define mx2010a_migmuni5_lbl 26003 `"Alamos"', add
label define mx2010a_migmuni5_lbl 26004 `"Altar"', add
label define mx2010a_migmuni5_lbl 26005 `"Arivechi"', add
label define mx2010a_migmuni5_lbl 26006 `"Arizpe"', add
label define mx2010a_migmuni5_lbl 26007 `"Atil"', add
label define mx2010a_migmuni5_lbl 26008 `"Bacadéhuachi"', add
label define mx2010a_migmuni5_lbl 26009 `"Bacanora"', add
label define mx2010a_migmuni5_lbl 26010 `"Bacerac"', add
label define mx2010a_migmuni5_lbl 26011 `"Bacoachi"', add
label define mx2010a_migmuni5_lbl 26012 `"Bácum"', add
label define mx2010a_migmuni5_lbl 26013 `"Banámichi"', add
label define mx2010a_migmuni5_lbl 26014 `"Baviácora"', add
label define mx2010a_migmuni5_lbl 26015 `"Bavispe"', add
label define mx2010a_migmuni5_lbl 26016 `"Benjamín Hill"', add
label define mx2010a_migmuni5_lbl 26017 `"Caborca"', add
label define mx2010a_migmuni5_lbl 26018 `"Cajeme"', add
label define mx2010a_migmuni5_lbl 26019 `"Cananea"', add
label define mx2010a_migmuni5_lbl 26020 `"Carbó"', add
label define mx2010a_migmuni5_lbl 26021 `"La Colorada"', add
label define mx2010a_migmuni5_lbl 26022 `"Cucurpe"', add
label define mx2010a_migmuni5_lbl 26023 `"Cumpas"', add
label define mx2010a_migmuni5_lbl 26024 `"Divisaderos"', add
label define mx2010a_migmuni5_lbl 26025 `"Empalme"', add
label define mx2010a_migmuni5_lbl 26026 `"Etchojoa"', add
label define mx2010a_migmuni5_lbl 26027 `"Fronteras"', add
label define mx2010a_migmuni5_lbl 26028 `"Granados"', add
label define mx2010a_migmuni5_lbl 26029 `"Guaymas"', add
label define mx2010a_migmuni5_lbl 26030 `"Hermosillo"', add
label define mx2010a_migmuni5_lbl 26031 `"Huachinera"', add
label define mx2010a_migmuni5_lbl 26032 `"Huásabas"', add
label define mx2010a_migmuni5_lbl 26033 `"Huatabampo"', add
label define mx2010a_migmuni5_lbl 26034 `"Huépac"', add
label define mx2010a_migmuni5_lbl 26035 `"Imuris"', add
label define mx2010a_migmuni5_lbl 26036 `"Magdalena"', add
label define mx2010a_migmuni5_lbl 26037 `"Mazatán"', add
label define mx2010a_migmuni5_lbl 26038 `"Moctezuma"', add
label define mx2010a_migmuni5_lbl 26039 `"Naco"', add
label define mx2010a_migmuni5_lbl 26040 `"Nácori Chico"', add
label define mx2010a_migmuni5_lbl 26041 `"Nacozari de García"', add
label define mx2010a_migmuni5_lbl 26042 `"Navojoa"', add
label define mx2010a_migmuni5_lbl 26043 `"Nogales"', add
label define mx2010a_migmuni5_lbl 26044 `"Onavas"', add
label define mx2010a_migmuni5_lbl 26045 `"Opodepe"', add
label define mx2010a_migmuni5_lbl 26046 `"Oquitoa"', add
label define mx2010a_migmuni5_lbl 26047 `"Pitiquito"', add
label define mx2010a_migmuni5_lbl 26048 `"Puerto Peñasco"', add
label define mx2010a_migmuni5_lbl 26049 `"Quiriego"', add
label define mx2010a_migmuni5_lbl 26050 `"Rayón"', add
label define mx2010a_migmuni5_lbl 26051 `"Rosario"', add
label define mx2010a_migmuni5_lbl 26052 `"Sahuaripa"', add
label define mx2010a_migmuni5_lbl 26053 `"San Felipe de Jesús"', add
label define mx2010a_migmuni5_lbl 26054 `"San Javier"', add
label define mx2010a_migmuni5_lbl 26055 `"San Luis Río Colorado"', add
label define mx2010a_migmuni5_lbl 26056 `"San Miguel de Horcasitas"', add
label define mx2010a_migmuni5_lbl 26057 `"San Pedro de la Cueva"', add
label define mx2010a_migmuni5_lbl 26058 `"Santa Ana"', add
label define mx2010a_migmuni5_lbl 26059 `"Santa Cruz"', add
label define mx2010a_migmuni5_lbl 26060 `"Sáric"', add
label define mx2010a_migmuni5_lbl 26061 `"Soyopa"', add
label define mx2010a_migmuni5_lbl 26062 `"Suaqui Grande"', add
label define mx2010a_migmuni5_lbl 26063 `"Tepache"', add
label define mx2010a_migmuni5_lbl 26064 `"Trincheras"', add
label define mx2010a_migmuni5_lbl 26065 `"Tubutama"', add
label define mx2010a_migmuni5_lbl 26066 `"Ures"', add
label define mx2010a_migmuni5_lbl 26067 `"Villa Hidalgo"', add
label define mx2010a_migmuni5_lbl 26068 `"Villa Pesqueira"', add
label define mx2010a_migmuni5_lbl 26069 `"Yécora"', add
label define mx2010a_migmuni5_lbl 26070 `"General Plutarco Elías Calles"', add
label define mx2010a_migmuni5_lbl 26071 `"Benito Juárez"', add
label define mx2010a_migmuni5_lbl 26072 `"San Ignacio Río Muerto"', add
label define mx2010a_migmuni5_lbl 26999 `"Sonora entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 27001 `"Balancán"', add
label define mx2010a_migmuni5_lbl 27002 `"Cárdenas"', add
label define mx2010a_migmuni5_lbl 27003 `"Centla"', add
label define mx2010a_migmuni5_lbl 27004 `"Centro"', add
label define mx2010a_migmuni5_lbl 27005 `"Comalcalco"', add
label define mx2010a_migmuni5_lbl 27006 `"Cunduacán"', add
label define mx2010a_migmuni5_lbl 27007 `"Emiliano Zapata"', add
label define mx2010a_migmuni5_lbl 27008 `"Huimanguillo"', add
label define mx2010a_migmuni5_lbl 27009 `"Jalapa"', add
label define mx2010a_migmuni5_lbl 27010 `"Jalpa de Méndez"', add
label define mx2010a_migmuni5_lbl 27011 `"Jonuta"', add
label define mx2010a_migmuni5_lbl 27012 `"Macuspana"', add
label define mx2010a_migmuni5_lbl 27013 `"Nacajuca"', add
label define mx2010a_migmuni5_lbl 27014 `"Paraíso"', add
label define mx2010a_migmuni5_lbl 27015 `"Tacotalpa"', add
label define mx2010a_migmuni5_lbl 27016 `"Teapa"', add
label define mx2010a_migmuni5_lbl 27017 `"Tenosique"', add
label define mx2010a_migmuni5_lbl 27999 `"Tabasco entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 28001 `"Abasolo"', add
label define mx2010a_migmuni5_lbl 28002 `"Aldama"', add
label define mx2010a_migmuni5_lbl 28003 `"Altamira"', add
label define mx2010a_migmuni5_lbl 28004 `"Antiguo Morelos"', add
label define mx2010a_migmuni5_lbl 28005 `"Burgos"', add
label define mx2010a_migmuni5_lbl 28006 `"Bustamante"', add
label define mx2010a_migmuni5_lbl 28007 `"Camargo"', add
label define mx2010a_migmuni5_lbl 28008 `"Casas"', add
label define mx2010a_migmuni5_lbl 28009 `"Ciudad Madero"', add
label define mx2010a_migmuni5_lbl 28010 `"Cruillas"', add
label define mx2010a_migmuni5_lbl 28011 `"Gómez Farías"', add
label define mx2010a_migmuni5_lbl 28012 `"González"', add
label define mx2010a_migmuni5_lbl 28013 `"Güémez"', add
label define mx2010a_migmuni5_lbl 28014 `"Guerrero"', add
label define mx2010a_migmuni5_lbl 28015 `"Gustavo Díaz Ordaz"', add
label define mx2010a_migmuni5_lbl 28016 `"Hidalgo"', add
label define mx2010a_migmuni5_lbl 28017 `"Jaumave"', add
label define mx2010a_migmuni5_lbl 28018 `"Jiménez"', add
label define mx2010a_migmuni5_lbl 28019 `"Llera"', add
label define mx2010a_migmuni5_lbl 28020 `"Mainero"', add
label define mx2010a_migmuni5_lbl 28021 `"El Mante"', add
label define mx2010a_migmuni5_lbl 28022 `"Matamoros"', add
label define mx2010a_migmuni5_lbl 28023 `"Méndez"', add
label define mx2010a_migmuni5_lbl 28024 `"Mier"', add
label define mx2010a_migmuni5_lbl 28025 `"Miguel Alemán"', add
label define mx2010a_migmuni5_lbl 28026 `"Miquihuana"', add
label define mx2010a_migmuni5_lbl 28027 `"Nuevo Laredo"', add
label define mx2010a_migmuni5_lbl 28028 `"Nuevo Morelos"', add
label define mx2010a_migmuni5_lbl 28029 `"Ocampo"', add
label define mx2010a_migmuni5_lbl 28030 `"Padilla"', add
label define mx2010a_migmuni5_lbl 28031 `"Palmillas"', add
label define mx2010a_migmuni5_lbl 28032 `"Reynosa"', add
label define mx2010a_migmuni5_lbl 28033 `"Río Bravo"', add
label define mx2010a_migmuni5_lbl 28034 `"San Carlos"', add
label define mx2010a_migmuni5_lbl 28035 `"San Fernando"', add
label define mx2010a_migmuni5_lbl 28036 `"San Nicolás"', add
label define mx2010a_migmuni5_lbl 28037 `"Soto la Marina"', add
label define mx2010a_migmuni5_lbl 28038 `"Tampico"', add
label define mx2010a_migmuni5_lbl 28039 `"Tula"', add
label define mx2010a_migmuni5_lbl 28040 `"Valle Hermoso"', add
label define mx2010a_migmuni5_lbl 28041 `"Victoria"', add
label define mx2010a_migmuni5_lbl 28042 `"Villagrán"', add
label define mx2010a_migmuni5_lbl 28043 `"Xicoténcatl"', add
label define mx2010a_migmuni5_lbl 28999 `"Tamaulipas entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 29001 `"Amaxac de Guerrero"', add
label define mx2010a_migmuni5_lbl 29002 `"Apetatitlán de Antonio Carvajal"', add
label define mx2010a_migmuni5_lbl 29003 `"Atlangatepec"', add
label define mx2010a_migmuni5_lbl 29004 `"Atltzayanca"', add
label define mx2010a_migmuni5_lbl 29005 `"Apizaco"', add
label define mx2010a_migmuni5_lbl 29006 `"Calpulalpan"', add
label define mx2010a_migmuni5_lbl 29007 `"El Carmen Tequexquitla"', add
label define mx2010a_migmuni5_lbl 29008 `"Cuapiaxtla"', add
label define mx2010a_migmuni5_lbl 29009 `"Cuaxomulco"', add
label define mx2010a_migmuni5_lbl 29010 `"Chiautempan"', add
label define mx2010a_migmuni5_lbl 29011 `"Muñoz de Domingo Arenas"', add
label define mx2010a_migmuni5_lbl 29012 `"Españita"', add
label define mx2010a_migmuni5_lbl 29013 `"Huamantla"', add
label define mx2010a_migmuni5_lbl 29014 `"Hueyotlipan"', add
label define mx2010a_migmuni5_lbl 29015 `"Ixtacuixtla de Mariano Matamoros"', add
label define mx2010a_migmuni5_lbl 29016 `"Ixtenco"', add
label define mx2010a_migmuni5_lbl 29017 `"Mazatecochco de José María Morelos"', add
label define mx2010a_migmuni5_lbl 29018 `"Contla de Juan Cuamatzi"', add
label define mx2010a_migmuni5_lbl 29019 `"Tepetitla de Lardizábal"', add
label define mx2010a_migmuni5_lbl 29020 `"Sanctórum de Lázaro Cárdenas"', add
label define mx2010a_migmuni5_lbl 29021 `"Nanacamilpa de Mariano Arista"', add
label define mx2010a_migmuni5_lbl 29022 `"Acuamanala de Miguel Hidalgo"', add
label define mx2010a_migmuni5_lbl 29023 `"Natívitas"', add
label define mx2010a_migmuni5_lbl 29024 `"Panotla"', add
label define mx2010a_migmuni5_lbl 29025 `"San Pablo del Monte"', add
label define mx2010a_migmuni5_lbl 29026 `"Santa Cruz Tlaxcala"', add
label define mx2010a_migmuni5_lbl 29027 `"Tenancingo"', add
label define mx2010a_migmuni5_lbl 29028 `"Teolocholco"', add
label define mx2010a_migmuni5_lbl 29029 `"Tepeyanco"', add
label define mx2010a_migmuni5_lbl 29030 `"Terrenate"', add
label define mx2010a_migmuni5_lbl 29031 `"Tetla de la Solidaridad"', add
label define mx2010a_migmuni5_lbl 29032 `"Tetlatlahuca"', add
label define mx2010a_migmuni5_lbl 29033 `"Tlaxcala"', add
label define mx2010a_migmuni5_lbl 29034 `"Tlaxco"', add
label define mx2010a_migmuni5_lbl 29035 `"Tocatlán"', add
label define mx2010a_migmuni5_lbl 29036 `"Totolac"', add
label define mx2010a_migmuni5_lbl 29037 `"Ziltlaltépec de Trinidad Sánchez Santos"', add
label define mx2010a_migmuni5_lbl 29038 `"Tzompantepec"', add
label define mx2010a_migmuni5_lbl 29039 `"Xaloztoc"', add
label define mx2010a_migmuni5_lbl 29040 `"Xaltocan"', add
label define mx2010a_migmuni5_lbl 29041 `"Papalotla de Xicohténcatl"', add
label define mx2010a_migmuni5_lbl 29042 `"Xicohtzinco"', add
label define mx2010a_migmuni5_lbl 29043 `"Yauhquemehcan"', add
label define mx2010a_migmuni5_lbl 29044 `"Zacatelco"', add
label define mx2010a_migmuni5_lbl 29045 `"Benito Juárez"', add
label define mx2010a_migmuni5_lbl 29046 `"Emiliano Zapata"', add
label define mx2010a_migmuni5_lbl 29047 `"Lázaro Cárdenas"', add
label define mx2010a_migmuni5_lbl 29048 `"La Magdalena Tlaltelulco"', add
label define mx2010a_migmuni5_lbl 29049 `"San Damián Texóloc"', add
label define mx2010a_migmuni5_lbl 29050 `"San Francisco Tetlanohcan"', add
label define mx2010a_migmuni5_lbl 29051 `"San Jerónimo Zacualpan"', add
label define mx2010a_migmuni5_lbl 29052 `"San José Teacalco"', add
label define mx2010a_migmuni5_lbl 29053 `"San Juan Huactzinco"', add
label define mx2010a_migmuni5_lbl 29054 `"San Lorenzo Axocomanitla"', add
label define mx2010a_migmuni5_lbl 29055 `"San Lucas Tecopilco"', add
label define mx2010a_migmuni5_lbl 29056 `"Santa Ana Nopalucan"', add
label define mx2010a_migmuni5_lbl 29057 `"Santa Apolonia Teacalco"', add
label define mx2010a_migmuni5_lbl 29058 `"Santa Catarina Ayometla"', add
label define mx2010a_migmuni5_lbl 29059 `"Santa Cruz Quilehtla"', add
label define mx2010a_migmuni5_lbl 29060 `"Santa Isabel Xiloxoxtla"', add
label define mx2010a_migmuni5_lbl 29999 `"Tlaxcala entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 30001 `"Acajete"', add
label define mx2010a_migmuni5_lbl 30002 `"Acatlán"', add
label define mx2010a_migmuni5_lbl 30003 `"Acayucan"', add
label define mx2010a_migmuni5_lbl 30004 `"Actopan"', add
label define mx2010a_migmuni5_lbl 30005 `"Acula"', add
label define mx2010a_migmuni5_lbl 30006 `"Acultzingo"', add
label define mx2010a_migmuni5_lbl 30007 `"Camarón de Tejeda"', add
label define mx2010a_migmuni5_lbl 30008 `"Alpatláhuac"', add
label define mx2010a_migmuni5_lbl 30009 `"Alto Lucero de Gutiérrez Barrios"', add
label define mx2010a_migmuni5_lbl 30010 `"Altotonga"', add
label define mx2010a_migmuni5_lbl 30011 `"Alvarado"', add
label define mx2010a_migmuni5_lbl 30012 `"Amatitlán"', add
label define mx2010a_migmuni5_lbl 30013 `"Naranjos Amatlán"', add
label define mx2010a_migmuni5_lbl 30014 `"Amatlán de los Reyes"', add
label define mx2010a_migmuni5_lbl 30015 `"Angel R. Cabada"', add
label define mx2010a_migmuni5_lbl 30016 `"La Antigua"', add
label define mx2010a_migmuni5_lbl 30017 `"Apazapan"', add
label define mx2010a_migmuni5_lbl 30018 `"Aquila"', add
label define mx2010a_migmuni5_lbl 30019 `"Astacinga"', add
label define mx2010a_migmuni5_lbl 30020 `"Atlahuilco"', add
label define mx2010a_migmuni5_lbl 30021 `"Atoyac"', add
label define mx2010a_migmuni5_lbl 30022 `"Atzacan"', add
label define mx2010a_migmuni5_lbl 30023 `"Atzalan"', add
label define mx2010a_migmuni5_lbl 30024 `"Tlaltetela"', add
label define mx2010a_migmuni5_lbl 30025 `"Ayahualulco"', add
label define mx2010a_migmuni5_lbl 30026 `"Banderilla"', add
label define mx2010a_migmuni5_lbl 30027 `"Benito Juárez"', add
label define mx2010a_migmuni5_lbl 30028 `"Boca del Río"', add
label define mx2010a_migmuni5_lbl 30029 `"Calcahualco"', add
label define mx2010a_migmuni5_lbl 30030 `"Camerino Z. Mendoza"', add
label define mx2010a_migmuni5_lbl 30031 `"Carrillo Puerto"', add
label define mx2010a_migmuni5_lbl 30032 `"Catemaco"', add
label define mx2010a_migmuni5_lbl 30033 `"Cazones de Herrera"', add
label define mx2010a_migmuni5_lbl 30034 `"Cerro Azul"', add
label define mx2010a_migmuni5_lbl 30035 `"Citlaltépetl"', add
label define mx2010a_migmuni5_lbl 30036 `"Coacoatzintla"', add
label define mx2010a_migmuni5_lbl 30037 `"Coahuitlán"', add
label define mx2010a_migmuni5_lbl 30038 `"Coatepec"', add
label define mx2010a_migmuni5_lbl 30039 `"Coatzacoalcos"', add
label define mx2010a_migmuni5_lbl 30040 `"Coatzintla"', add
label define mx2010a_migmuni5_lbl 30041 `"Coetzala"', add
label define mx2010a_migmuni5_lbl 30042 `"Colipa"', add
label define mx2010a_migmuni5_lbl 30043 `"Comapa"', add
label define mx2010a_migmuni5_lbl 30044 `"Córdoba"', add
label define mx2010a_migmuni5_lbl 30045 `"Cosamaloapan de Carpio"', add
label define mx2010a_migmuni5_lbl 30046 `"Cosautlán de Carvajal"', add
label define mx2010a_migmuni5_lbl 30047 `"Coscomatepec"', add
label define mx2010a_migmuni5_lbl 30048 `"Cosoleacaque"', add
label define mx2010a_migmuni5_lbl 30049 `"Cotaxtla"', add
label define mx2010a_migmuni5_lbl 30050 `"Coxquihui"', add
label define mx2010a_migmuni5_lbl 30051 `"Coyutla"', add
label define mx2010a_migmuni5_lbl 30052 `"Cuichapa"', add
label define mx2010a_migmuni5_lbl 30053 `"Cuitláhuac"', add
label define mx2010a_migmuni5_lbl 30054 `"Chacaltianguis"', add
label define mx2010a_migmuni5_lbl 30055 `"Chalma"', add
label define mx2010a_migmuni5_lbl 30056 `"Chiconamel"', add
label define mx2010a_migmuni5_lbl 30057 `"Chiconquiaco"', add
label define mx2010a_migmuni5_lbl 30058 `"Chicontepec"', add
label define mx2010a_migmuni5_lbl 30059 `"Chinameca"', add
label define mx2010a_migmuni5_lbl 30060 `"Chinampa de Gorostiza"', add
label define mx2010a_migmuni5_lbl 30061 `"Las Choapas"', add
label define mx2010a_migmuni5_lbl 30062 `"Chocamán"', add
label define mx2010a_migmuni5_lbl 30063 `"Chontla"', add
label define mx2010a_migmuni5_lbl 30064 `"Chumatlán"', add
label define mx2010a_migmuni5_lbl 30065 `"Emiliano Zapata"', add
label define mx2010a_migmuni5_lbl 30066 `"Espinal"', add
label define mx2010a_migmuni5_lbl 30067 `"Filomeno Mata"', add
label define mx2010a_migmuni5_lbl 30068 `"Fortín"', add
label define mx2010a_migmuni5_lbl 30069 `"Gutiérrez Zamora"', add
label define mx2010a_migmuni5_lbl 30070 `"Hidalgotitlán"', add
label define mx2010a_migmuni5_lbl 30071 `"Huatusco"', add
label define mx2010a_migmuni5_lbl 30072 `"Huayacocotla"', add
label define mx2010a_migmuni5_lbl 30073 `"Hueyapan de Ocampo"', add
label define mx2010a_migmuni5_lbl 30074 `"Huiloapan de Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 30075 `"Ignacio de la Llave"', add
label define mx2010a_migmuni5_lbl 30076 `"Ilamatlán"', add
label define mx2010a_migmuni5_lbl 30077 `"Isla"', add
label define mx2010a_migmuni5_lbl 30078 `"Ixcatepec"', add
label define mx2010a_migmuni5_lbl 30079 `"Ixhuacán de los Reyes"', add
label define mx2010a_migmuni5_lbl 30080 `"Ixhuatlán del Café"', add
label define mx2010a_migmuni5_lbl 30081 `"Ixhuatlancillo"', add
label define mx2010a_migmuni5_lbl 30082 `"Ixhuatlán del Sureste"', add
label define mx2010a_migmuni5_lbl 30083 `"Ixhuatlán de Madero"', add
label define mx2010a_migmuni5_lbl 30084 `"Ixmatlahuacan"', add
label define mx2010a_migmuni5_lbl 30085 `"Ixtaczoquitlán"', add
label define mx2010a_migmuni5_lbl 30086 `"Jalacingo"', add
label define mx2010a_migmuni5_lbl 30087 `"Xalapa"', add
label define mx2010a_migmuni5_lbl 30088 `"Jalcomulco"', add
label define mx2010a_migmuni5_lbl 30089 `"Jáltipan"', add
label define mx2010a_migmuni5_lbl 30090 `"Jamapa"', add
label define mx2010a_migmuni5_lbl 30091 `"Jesús Carranza"', add
label define mx2010a_migmuni5_lbl 30092 `"Xico"', add
label define mx2010a_migmuni5_lbl 30093 `"Jilotepec"', add
label define mx2010a_migmuni5_lbl 30094 `"Juan Rodríguez Clara"', add
label define mx2010a_migmuni5_lbl 30095 `"Juchique de Ferrer"', add
label define mx2010a_migmuni5_lbl 30096 `"Landero y Coss"', add
label define mx2010a_migmuni5_lbl 30097 `"Lerdo de Tejada"', add
label define mx2010a_migmuni5_lbl 30098 `"Magdalena"', add
label define mx2010a_migmuni5_lbl 30099 `"Maltrata"', add
label define mx2010a_migmuni5_lbl 30100 `"Manlio Fabio Altamirano"', add
label define mx2010a_migmuni5_lbl 30101 `"Mariano Escobedo"', add
label define mx2010a_migmuni5_lbl 30102 `"Martínez de la Torre"', add
label define mx2010a_migmuni5_lbl 30103 `"Mecatlán"', add
label define mx2010a_migmuni5_lbl 30104 `"Mecayapan"', add
label define mx2010a_migmuni5_lbl 30105 `"Medellín"', add
label define mx2010a_migmuni5_lbl 30106 `"Miahuatlán"', add
label define mx2010a_migmuni5_lbl 30107 `"Las Minas"', add
label define mx2010a_migmuni5_lbl 30108 `"Minatitlán"', add
label define mx2010a_migmuni5_lbl 30109 `"Misantla"', add
label define mx2010a_migmuni5_lbl 30110 `"Mixtla de Altamirano"', add
label define mx2010a_migmuni5_lbl 30111 `"Moloacán"', add
label define mx2010a_migmuni5_lbl 30112 `"Naolinco"', add
label define mx2010a_migmuni5_lbl 30113 `"Naranjal"', add
label define mx2010a_migmuni5_lbl 30114 `"Nautla"', add
label define mx2010a_migmuni5_lbl 30115 `"Nogales"', add
label define mx2010a_migmuni5_lbl 30116 `"Oluta"', add
label define mx2010a_migmuni5_lbl 30117 `"Omealca"', add
label define mx2010a_migmuni5_lbl 30118 `"Orizaba"', add
label define mx2010a_migmuni5_lbl 30119 `"Otatitlán"', add
label define mx2010a_migmuni5_lbl 30120 `"Oteapan"', add
label define mx2010a_migmuni5_lbl 30121 `"Ozuluama de Mascareñas"', add
label define mx2010a_migmuni5_lbl 30122 `"Pajapan"', add
label define mx2010a_migmuni5_lbl 30123 `"Pánuco"', add
label define mx2010a_migmuni5_lbl 30124 `"Papantla"', add
label define mx2010a_migmuni5_lbl 30125 `"Paso del Macho"', add
label define mx2010a_migmuni5_lbl 30126 `"Paso de Ovejas"', add
label define mx2010a_migmuni5_lbl 30127 `"La Perla"', add
label define mx2010a_migmuni5_lbl 30128 `"Perote"', add
label define mx2010a_migmuni5_lbl 30129 `"Platón Sánchez"', add
label define mx2010a_migmuni5_lbl 30130 `"Playa Vicente"', add
label define mx2010a_migmuni5_lbl 30131 `"Poza Rica de Hidalgo"', add
label define mx2010a_migmuni5_lbl 30132 `"Las Vigas de Ramírez"', add
label define mx2010a_migmuni5_lbl 30133 `"Pueblo Viejo"', add
label define mx2010a_migmuni5_lbl 30134 `"Puente Nacional"', add
label define mx2010a_migmuni5_lbl 30135 `"Rafael Delgado"', add
label define mx2010a_migmuni5_lbl 30136 `"Rafael Lucio"', add
label define mx2010a_migmuni5_lbl 30137 `"Los Reyes"', add
label define mx2010a_migmuni5_lbl 30138 `"Río Blanco"', add
label define mx2010a_migmuni5_lbl 30139 `"Saltabarranca"', add
label define mx2010a_migmuni5_lbl 30140 `"San Andrés Tenejapan"', add
label define mx2010a_migmuni5_lbl 30141 `"San Andrés Tuxtla"', add
label define mx2010a_migmuni5_lbl 30142 `"San Juan Evangelista"', add
label define mx2010a_migmuni5_lbl 30143 `"Santiago Tuxtla"', add
label define mx2010a_migmuni5_lbl 30144 `"Sayula de Alemán"', add
label define mx2010a_migmuni5_lbl 30145 `"Soconusco"', add
label define mx2010a_migmuni5_lbl 30146 `"Sochiapa"', add
label define mx2010a_migmuni5_lbl 30147 `"Soledad Atzompa"', add
label define mx2010a_migmuni5_lbl 30148 `"Soledad de Doblado"', add
label define mx2010a_migmuni5_lbl 30149 `"Soteapan"', add
label define mx2010a_migmuni5_lbl 30150 `"Tamalín"', add
label define mx2010a_migmuni5_lbl 30151 `"Tamiahua"', add
label define mx2010a_migmuni5_lbl 30152 `"Tampico Alto"', add
label define mx2010a_migmuni5_lbl 30153 `"Tancoco"', add
label define mx2010a_migmuni5_lbl 30154 `"Tantima"', add
label define mx2010a_migmuni5_lbl 30155 `"Tantoyuca"', add
label define mx2010a_migmuni5_lbl 30156 `"Tatatila"', add
label define mx2010a_migmuni5_lbl 30157 `"Castillo de Teayo"', add
label define mx2010a_migmuni5_lbl 30158 `"Tecolutla"', add
label define mx2010a_migmuni5_lbl 30159 `"Tehuipango"', add
label define mx2010a_migmuni5_lbl 30160 `"Álamo Temapache"', add
label define mx2010a_migmuni5_lbl 30161 `"Tempoal"', add
label define mx2010a_migmuni5_lbl 30162 `"Tenampa"', add
label define mx2010a_migmuni5_lbl 30163 `"Tenochtitlán"', add
label define mx2010a_migmuni5_lbl 30164 `"Teocelo"', add
label define mx2010a_migmuni5_lbl 30165 `"Tepatlaxco"', add
label define mx2010a_migmuni5_lbl 30166 `"Tepetlán"', add
label define mx2010a_migmuni5_lbl 30167 `"Tepetzintla"', add
label define mx2010a_migmuni5_lbl 30168 `"Tequila"', add
label define mx2010a_migmuni5_lbl 30169 `"José Azueta"', add
label define mx2010a_migmuni5_lbl 30170 `"Texcatepec"', add
label define mx2010a_migmuni5_lbl 30171 `"Texhuacán"', add
label define mx2010a_migmuni5_lbl 30172 `"Texistepec"', add
label define mx2010a_migmuni5_lbl 30173 `"Tezonapa"', add
label define mx2010a_migmuni5_lbl 30174 `"Tierra Blanca"', add
label define mx2010a_migmuni5_lbl 30175 `"Tihuatlán"', add
label define mx2010a_migmuni5_lbl 30176 `"Tlacojalpan"', add
label define mx2010a_migmuni5_lbl 30177 `"Tlacolulan"', add
label define mx2010a_migmuni5_lbl 30178 `"Tlacotalpan"', add
label define mx2010a_migmuni5_lbl 30179 `"Tlacotepec de Mejía"', add
label define mx2010a_migmuni5_lbl 30180 `"Tlachichilco"', add
label define mx2010a_migmuni5_lbl 30181 `"Tlalixcoyan"', add
label define mx2010a_migmuni5_lbl 30182 `"Tlalnelhuayocan"', add
label define mx2010a_migmuni5_lbl 30183 `"Tlapacoyan"', add
label define mx2010a_migmuni5_lbl 30184 `"Tlaquilpa"', add
label define mx2010a_migmuni5_lbl 30185 `"Tlilapan"', add
label define mx2010a_migmuni5_lbl 30186 `"Tomatlán"', add
label define mx2010a_migmuni5_lbl 30187 `"Tonayán"', add
label define mx2010a_migmuni5_lbl 30188 `"Totutla"', add
label define mx2010a_migmuni5_lbl 30189 `"Tuxpan"', add
label define mx2010a_migmuni5_lbl 30190 `"Tuxtilla"', add
label define mx2010a_migmuni5_lbl 30191 `"Ursulo Galván"', add
label define mx2010a_migmuni5_lbl 30192 `"Vega de Alatorre"', add
label define mx2010a_migmuni5_lbl 30193 `"Veracruz"', add
label define mx2010a_migmuni5_lbl 30194 `"Villa Aldama"', add
label define mx2010a_migmuni5_lbl 30195 `"Xoxocotla"', add
label define mx2010a_migmuni5_lbl 30196 `"Yanga"', add
label define mx2010a_migmuni5_lbl 30197 `"Yecuatla"', add
label define mx2010a_migmuni5_lbl 30198 `"Zacualpan"', add
label define mx2010a_migmuni5_lbl 30199 `"Zaragoza"', add
label define mx2010a_migmuni5_lbl 30200 `"Zentla"', add
label define mx2010a_migmuni5_lbl 30201 `"Zongolica"', add
label define mx2010a_migmuni5_lbl 30202 `"Zontecomatlán de López y Fuentes"', add
label define mx2010a_migmuni5_lbl 30203 `"Zozocolco de Hidalgo"', add
label define mx2010a_migmuni5_lbl 30204 `"Agua Dulce"', add
label define mx2010a_migmuni5_lbl 30205 `"El Higo"', add
label define mx2010a_migmuni5_lbl 30206 `"Nanchital de Lázaro Cárdenas del Río"', add
label define mx2010a_migmuni5_lbl 30207 `"Tres Valles"', add
label define mx2010a_migmuni5_lbl 30208 `"Carlos A. Carrillo"', add
label define mx2010a_migmuni5_lbl 30209 `"Tatahuicapan de Juárez"', add
label define mx2010a_migmuni5_lbl 30210 `"Uxpanapa"', add
label define mx2010a_migmuni5_lbl 30211 `"San Rafael"', add
label define mx2010a_migmuni5_lbl 30212 `"Santiago Sochiapan"', add
label define mx2010a_migmuni5_lbl 30999 `"Veracruz de Ignacio de la Llave entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 31001 `"Abalá"', add
label define mx2010a_migmuni5_lbl 31002 `"Acanceh"', add
label define mx2010a_migmuni5_lbl 31003 `"Akil"', add
label define mx2010a_migmuni5_lbl 31004 `"Baca"', add
label define mx2010a_migmuni5_lbl 31005 `"Bokobá"', add
label define mx2010a_migmuni5_lbl 31006 `"Buctzotz"', add
label define mx2010a_migmuni5_lbl 31007 `"Cacalchén"', add
label define mx2010a_migmuni5_lbl 31008 `"Calotmul"', add
label define mx2010a_migmuni5_lbl 31009 `"Cansahcab"', add
label define mx2010a_migmuni5_lbl 31010 `"Cantamayec"', add
label define mx2010a_migmuni5_lbl 31011 `"Celestún"', add
label define mx2010a_migmuni5_lbl 31012 `"Cenotillo"', add
label define mx2010a_migmuni5_lbl 31013 `"Conkal"', add
label define mx2010a_migmuni5_lbl 31014 `"Cuncunul"', add
label define mx2010a_migmuni5_lbl 31015 `"Cuzamá"', add
label define mx2010a_migmuni5_lbl 31016 `"Chacsinkín"', add
label define mx2010a_migmuni5_lbl 31017 `"Chankom"', add
label define mx2010a_migmuni5_lbl 31018 `"Chapab"', add
label define mx2010a_migmuni5_lbl 31019 `"Chemax"', add
label define mx2010a_migmuni5_lbl 31020 `"Chicxulub Pueblo"', add
label define mx2010a_migmuni5_lbl 31021 `"Chichimilá"', add
label define mx2010a_migmuni5_lbl 31022 `"Chikindzonot"', add
label define mx2010a_migmuni5_lbl 31023 `"Chocholá"', add
label define mx2010a_migmuni5_lbl 31024 `"Chumayel"', add
label define mx2010a_migmuni5_lbl 31025 `"Dzán"', add
label define mx2010a_migmuni5_lbl 31026 `"Dzemul"', add
label define mx2010a_migmuni5_lbl 31027 `"Dzidzantún"', add
label define mx2010a_migmuni5_lbl 31028 `"Dzilam de Bravo"', add
label define mx2010a_migmuni5_lbl 31029 `"Dzilam González"', add
label define mx2010a_migmuni5_lbl 31030 `"Dzitás"', add
label define mx2010a_migmuni5_lbl 31031 `"Dzoncauich"', add
label define mx2010a_migmuni5_lbl 31032 `"Espita"', add
label define mx2010a_migmuni5_lbl 31033 `"Halachó"', add
label define mx2010a_migmuni5_lbl 31034 `"Hocabá"', add
label define mx2010a_migmuni5_lbl 31035 `"Hoctún"', add
label define mx2010a_migmuni5_lbl 31036 `"Homún"', add
label define mx2010a_migmuni5_lbl 31037 `"Huhí"', add
label define mx2010a_migmuni5_lbl 31038 `"Hunucmá"', add
label define mx2010a_migmuni5_lbl 31039 `"Ixil"', add
label define mx2010a_migmuni5_lbl 31040 `"Izamal"', add
label define mx2010a_migmuni5_lbl 31041 `"Kanasín"', add
label define mx2010a_migmuni5_lbl 31042 `"Kantunil"', add
label define mx2010a_migmuni5_lbl 31043 `"Kaua"', add
label define mx2010a_migmuni5_lbl 31044 `"Kinchil"', add
label define mx2010a_migmuni5_lbl 31045 `"Kopomá"', add
label define mx2010a_migmuni5_lbl 31046 `"Mama"', add
label define mx2010a_migmuni5_lbl 31047 `"Maní"', add
label define mx2010a_migmuni5_lbl 31048 `"Maxcanú"', add
label define mx2010a_migmuni5_lbl 31049 `"Mayapán"', add
label define mx2010a_migmuni5_lbl 31050 `"Mérida"', add
label define mx2010a_migmuni5_lbl 31051 `"Mocochá"', add
label define mx2010a_migmuni5_lbl 31052 `"Motul"', add
label define mx2010a_migmuni5_lbl 31053 `"Muna"', add
label define mx2010a_migmuni5_lbl 31054 `"Muxupip"', add
label define mx2010a_migmuni5_lbl 31055 `"Opichén"', add
label define mx2010a_migmuni5_lbl 31056 `"Oxkutzcab"', add
label define mx2010a_migmuni5_lbl 31057 `"Panabá"', add
label define mx2010a_migmuni5_lbl 31058 `"Peto"', add
label define mx2010a_migmuni5_lbl 31059 `"Progreso"', add
label define mx2010a_migmuni5_lbl 31060 `"Quintana Roo"', add
label define mx2010a_migmuni5_lbl 31061 `"Río Lagartos"', add
label define mx2010a_migmuni5_lbl 31062 `"Sacalum"', add
label define mx2010a_migmuni5_lbl 31063 `"Samahil"', add
label define mx2010a_migmuni5_lbl 31064 `"Sanahcat"', add
label define mx2010a_migmuni5_lbl 31065 `"San Felipe"', add
label define mx2010a_migmuni5_lbl 31066 `"Santa Elena"', add
label define mx2010a_migmuni5_lbl 31067 `"Seyé"', add
label define mx2010a_migmuni5_lbl 31068 `"Sinanché"', add
label define mx2010a_migmuni5_lbl 31069 `"Sotuta"', add
label define mx2010a_migmuni5_lbl 31070 `"Sucilá"', add
label define mx2010a_migmuni5_lbl 31071 `"Sudzal"', add
label define mx2010a_migmuni5_lbl 31072 `"Suma"', add
label define mx2010a_migmuni5_lbl 31073 `"Tahdziú"', add
label define mx2010a_migmuni5_lbl 31074 `"Tahmek"', add
label define mx2010a_migmuni5_lbl 31075 `"Teabo"', add
label define mx2010a_migmuni5_lbl 31076 `"Tecoh"', add
label define mx2010a_migmuni5_lbl 31077 `"Tekal de Venegas"', add
label define mx2010a_migmuni5_lbl 31078 `"Tekantó"', add
label define mx2010a_migmuni5_lbl 31079 `"Tekax"', add
label define mx2010a_migmuni5_lbl 31080 `"Tekit"', add
label define mx2010a_migmuni5_lbl 31081 `"Tekom"', add
label define mx2010a_migmuni5_lbl 31082 `"Telchac Pueblo"', add
label define mx2010a_migmuni5_lbl 31083 `"Telchac Puerto"', add
label define mx2010a_migmuni5_lbl 31084 `"Temax"', add
label define mx2010a_migmuni5_lbl 31085 `"Temozón"', add
label define mx2010a_migmuni5_lbl 31086 `"Tepakán"', add
label define mx2010a_migmuni5_lbl 31087 `"Tetiz"', add
label define mx2010a_migmuni5_lbl 31088 `"Teya"', add
label define mx2010a_migmuni5_lbl 31089 `"Ticul"', add
label define mx2010a_migmuni5_lbl 31090 `"Timucuy"', add
label define mx2010a_migmuni5_lbl 31091 `"Tinum"', add
label define mx2010a_migmuni5_lbl 31092 `"Tixcacalcupul"', add
label define mx2010a_migmuni5_lbl 31093 `"Tixkokob"', add
label define mx2010a_migmuni5_lbl 31094 `"Tixmehuac"', add
label define mx2010a_migmuni5_lbl 31095 `"Tixpéhual"', add
label define mx2010a_migmuni5_lbl 31096 `"Tizimín"', add
label define mx2010a_migmuni5_lbl 31097 `"Tunkás"', add
label define mx2010a_migmuni5_lbl 31098 `"Tzucacab"', add
label define mx2010a_migmuni5_lbl 31099 `"Uayma"', add
label define mx2010a_migmuni5_lbl 31100 `"Ucú"', add
label define mx2010a_migmuni5_lbl 31101 `"Umán"', add
label define mx2010a_migmuni5_lbl 31102 `"Valladolid"', add
label define mx2010a_migmuni5_lbl 31103 `"Xocchel"', add
label define mx2010a_migmuni5_lbl 31104 `"Yaxcabá"', add
label define mx2010a_migmuni5_lbl 31105 `"Yaxkukul"', add
label define mx2010a_migmuni5_lbl 31106 `"Yobaín"', add
label define mx2010a_migmuni5_lbl 31999 `"Yucatán entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 32001 `"Apozol"', add
label define mx2010a_migmuni5_lbl 32002 `"Apulco"', add
label define mx2010a_migmuni5_lbl 32003 `"Atolinga"', add
label define mx2010a_migmuni5_lbl 32004 `"Benito Juárez"', add
label define mx2010a_migmuni5_lbl 32005 `"Calera"', add
label define mx2010a_migmuni5_lbl 32006 `"Cañitas de Felipe Pescador"', add
label define mx2010a_migmuni5_lbl 32007 `"Concepción del Oro"', add
label define mx2010a_migmuni5_lbl 32008 `"Cuauhtémoc"', add
label define mx2010a_migmuni5_lbl 32009 `"Chalchihuites"', add
label define mx2010a_migmuni5_lbl 32010 `"Fresnillo"', add
label define mx2010a_migmuni5_lbl 32011 `"Trinidad García de la Cadena"', add
label define mx2010a_migmuni5_lbl 32012 `"Genaro Codina"', add
label define mx2010a_migmuni5_lbl 32013 `"General Enrique Estrada"', add
label define mx2010a_migmuni5_lbl 32014 `"General Francisco R. Murguía"', add
label define mx2010a_migmuni5_lbl 32015 `"El Plateado de Joaquín Amaro"', add
label define mx2010a_migmuni5_lbl 32016 `"General Pánfilo Natera"', add
label define mx2010a_migmuni5_lbl 32017 `"Guadalupe"', add
label define mx2010a_migmuni5_lbl 32018 `"Huanusco"', add
label define mx2010a_migmuni5_lbl 32019 `"Jalpa"', add
label define mx2010a_migmuni5_lbl 32020 `"Jerez"', add
label define mx2010a_migmuni5_lbl 32021 `"Jiménez del Teul"', add
label define mx2010a_migmuni5_lbl 32022 `"Juan Aldama"', add
label define mx2010a_migmuni5_lbl 32023 `"Juchipila"', add
label define mx2010a_migmuni5_lbl 32024 `"Loreto"', add
label define mx2010a_migmuni5_lbl 32025 `"Luis Moya"', add
label define mx2010a_migmuni5_lbl 32026 `"Mazapil"', add
label define mx2010a_migmuni5_lbl 32027 `"Melchor Ocampo"', add
label define mx2010a_migmuni5_lbl 32028 `"Mezquital del Oro"', add
label define mx2010a_migmuni5_lbl 32029 `"Miguel Auza"', add
label define mx2010a_migmuni5_lbl 32030 `"Momax"', add
label define mx2010a_migmuni5_lbl 32031 `"Monte Escobedo"', add
label define mx2010a_migmuni5_lbl 32032 `"Morelos"', add
label define mx2010a_migmuni5_lbl 32033 `"Moyahua de Estrada"', add
label define mx2010a_migmuni5_lbl 32034 `"Nochistlán de Mejía"', add
label define mx2010a_migmuni5_lbl 32035 `"Noria de Ángeles"', add
label define mx2010a_migmuni5_lbl 32036 `"Ojocaliente"', add
label define mx2010a_migmuni5_lbl 32037 `"Pánuco"', add
label define mx2010a_migmuni5_lbl 32038 `"Pinos"', add
label define mx2010a_migmuni5_lbl 32039 `"Río Grande"', add
label define mx2010a_migmuni5_lbl 32040 `"Sain Alto"', add
label define mx2010a_migmuni5_lbl 32041 `"El Salvador"', add
label define mx2010a_migmuni5_lbl 32042 `"Sombrerete"', add
label define mx2010a_migmuni5_lbl 32043 `"Susticacán"', add
label define mx2010a_migmuni5_lbl 32044 `"Tabasco"', add
label define mx2010a_migmuni5_lbl 32045 `"Tepechitlán"', add
label define mx2010a_migmuni5_lbl 32046 `"Tepetongo"', add
label define mx2010a_migmuni5_lbl 32047 `"Teúl de González Ortega"', add
label define mx2010a_migmuni5_lbl 32048 `"Tlaltenango de Sánchez Román"', add
label define mx2010a_migmuni5_lbl 32049 `"Valparaíso"', add
label define mx2010a_migmuni5_lbl 32050 `"Vetagrande"', add
label define mx2010a_migmuni5_lbl 32051 `"Villa de Cos"', add
label define mx2010a_migmuni5_lbl 32052 `"Villa García"', add
label define mx2010a_migmuni5_lbl 32053 `"Villa González Ortega"', add
label define mx2010a_migmuni5_lbl 32054 `"Villa Hidalgo"', add
label define mx2010a_migmuni5_lbl 32055 `"Villanueva"', add
label define mx2010a_migmuni5_lbl 32056 `"Zacatecas"', add
label define mx2010a_migmuni5_lbl 32057 `"Trancoso"', add
label define mx2010a_migmuni5_lbl 32058 `"Santa María de la Paz"', add
label define mx2010a_migmuni5_lbl 32999 `"Zacatecas entity, unknown municipality"', add
label define mx2010a_migmuni5_lbl 99997 `"Abroad"', add
label define mx2010a_migmuni5_lbl 99998 `"Unknown"', add
label define mx2010a_migmuni5_lbl 99999 `"NIU (not in universe)"', add
label values mx2010a_migmuni5 mx2010a_migmuni5_lbl

label define age_sp_lbl 000 `"Less than 1 year"'
label define age_sp_lbl 001 `"1 year"', add
label define age_sp_lbl 002 `"2 years"', add
label define age_sp_lbl 003 `"3"', add
label define age_sp_lbl 004 `"4"', add
label define age_sp_lbl 005 `"5"', add
label define age_sp_lbl 006 `"6"', add
label define age_sp_lbl 007 `"7"', add
label define age_sp_lbl 008 `"8"', add
label define age_sp_lbl 009 `"9"', add
label define age_sp_lbl 010 `"10"', add
label define age_sp_lbl 011 `"11"', add
label define age_sp_lbl 012 `"12"', add
label define age_sp_lbl 013 `"13"', add
label define age_sp_lbl 014 `"14"', add
label define age_sp_lbl 015 `"15"', add
label define age_sp_lbl 016 `"16"', add
label define age_sp_lbl 017 `"17"', add
label define age_sp_lbl 018 `"18"', add
label define age_sp_lbl 019 `"19"', add
label define age_sp_lbl 020 `"20"', add
label define age_sp_lbl 021 `"21"', add
label define age_sp_lbl 022 `"22"', add
label define age_sp_lbl 023 `"23"', add
label define age_sp_lbl 024 `"24"', add
label define age_sp_lbl 025 `"25"', add
label define age_sp_lbl 026 `"26"', add
label define age_sp_lbl 027 `"27"', add
label define age_sp_lbl 028 `"28"', add
label define age_sp_lbl 029 `"29"', add
label define age_sp_lbl 030 `"30"', add
label define age_sp_lbl 031 `"31"', add
label define age_sp_lbl 032 `"32"', add
label define age_sp_lbl 033 `"33"', add
label define age_sp_lbl 034 `"34"', add
label define age_sp_lbl 035 `"35"', add
label define age_sp_lbl 036 `"36"', add
label define age_sp_lbl 037 `"37"', add
label define age_sp_lbl 038 `"38"', add
label define age_sp_lbl 039 `"39"', add
label define age_sp_lbl 040 `"40"', add
label define age_sp_lbl 041 `"41"', add
label define age_sp_lbl 042 `"42"', add
label define age_sp_lbl 043 `"43"', add
label define age_sp_lbl 044 `"44"', add
label define age_sp_lbl 045 `"45"', add
label define age_sp_lbl 046 `"46"', add
label define age_sp_lbl 047 `"47"', add
label define age_sp_lbl 048 `"48"', add
label define age_sp_lbl 049 `"49"', add
label define age_sp_lbl 050 `"50"', add
label define age_sp_lbl 051 `"51"', add
label define age_sp_lbl 052 `"52"', add
label define age_sp_lbl 053 `"53"', add
label define age_sp_lbl 054 `"54"', add
label define age_sp_lbl 055 `"55"', add
label define age_sp_lbl 056 `"56"', add
label define age_sp_lbl 057 `"57"', add
label define age_sp_lbl 058 `"58"', add
label define age_sp_lbl 059 `"59"', add
label define age_sp_lbl 060 `"60"', add
label define age_sp_lbl 061 `"61"', add
label define age_sp_lbl 062 `"62"', add
label define age_sp_lbl 063 `"63"', add
label define age_sp_lbl 064 `"64"', add
label define age_sp_lbl 065 `"65"', add
label define age_sp_lbl 066 `"66"', add
label define age_sp_lbl 067 `"67"', add
label define age_sp_lbl 068 `"68"', add
label define age_sp_lbl 069 `"69"', add
label define age_sp_lbl 070 `"70"', add
label define age_sp_lbl 071 `"71"', add
label define age_sp_lbl 072 `"72"', add
label define age_sp_lbl 073 `"73"', add
label define age_sp_lbl 074 `"74"', add
label define age_sp_lbl 075 `"75"', add
label define age_sp_lbl 076 `"76"', add
label define age_sp_lbl 077 `"77"', add
label define age_sp_lbl 078 `"78"', add
label define age_sp_lbl 079 `"79"', add
label define age_sp_lbl 080 `"80"', add
label define age_sp_lbl 081 `"81"', add
label define age_sp_lbl 082 `"82"', add
label define age_sp_lbl 083 `"83"', add
label define age_sp_lbl 084 `"84"', add
label define age_sp_lbl 085 `"85"', add
label define age_sp_lbl 086 `"86"', add
label define age_sp_lbl 087 `"87"', add
label define age_sp_lbl 088 `"88"', add
label define age_sp_lbl 089 `"89"', add
label define age_sp_lbl 090 `"90"', add
label define age_sp_lbl 091 `"91"', add
label define age_sp_lbl 092 `"92"', add
label define age_sp_lbl 093 `"93"', add
label define age_sp_lbl 094 `"94"', add
label define age_sp_lbl 095 `"95"', add
label define age_sp_lbl 096 `"96"', add
label define age_sp_lbl 097 `"97"', add
label define age_sp_lbl 098 `"98"', add
label define age_sp_lbl 099 `"99"', add
label define age_sp_lbl 100 `"100+"', add
label define age_sp_lbl 999 `"Not reported/missing"', add
label values age_sp age_sp_lbl

label define chborn_sp_lbl 00 `"No children"'
label define chborn_sp_lbl 01 `"1 child"', add
label define chborn_sp_lbl 02 `"2 children"', add
label define chborn_sp_lbl 03 `"3"', add
label define chborn_sp_lbl 04 `"4"', add
label define chborn_sp_lbl 05 `"5"', add
label define chborn_sp_lbl 06 `"6"', add
label define chborn_sp_lbl 07 `"7"', add
label define chborn_sp_lbl 08 `"8"', add
label define chborn_sp_lbl 09 `"9"', add
label define chborn_sp_lbl 10 `"10"', add
label define chborn_sp_lbl 11 `"11"', add
label define chborn_sp_lbl 12 `"12"', add
label define chborn_sp_lbl 13 `"13"', add
label define chborn_sp_lbl 14 `"14"', add
label define chborn_sp_lbl 15 `"15"', add
label define chborn_sp_lbl 16 `"16"', add
label define chborn_sp_lbl 17 `"17"', add
label define chborn_sp_lbl 18 `"18"', add
label define chborn_sp_lbl 19 `"19"', add
label define chborn_sp_lbl 20 `"20"', add
label define chborn_sp_lbl 21 `"21"', add
label define chborn_sp_lbl 22 `"22"', add
label define chborn_sp_lbl 23 `"23"', add
label define chborn_sp_lbl 24 `"24"', add
label define chborn_sp_lbl 25 `"25"', add
label define chborn_sp_lbl 26 `"26"', add
label define chborn_sp_lbl 27 `"27"', add
label define chborn_sp_lbl 28 `"28"', add
label define chborn_sp_lbl 29 `"29"', add
label define chborn_sp_lbl 30 `"30+"', add
label define chborn_sp_lbl 98 `"Unknown"', add
label define chborn_sp_lbl 99 `"NIU (not in universe)"', add
label values chborn_sp chborn_sp_lbl

label define chsurv_sp_lbl 00 `"No children"'
label define chsurv_sp_lbl 01 `"1 child"', add
label define chsurv_sp_lbl 02 `"2 children"', add
label define chsurv_sp_lbl 03 `"3"', add
label define chsurv_sp_lbl 04 `"4"', add
label define chsurv_sp_lbl 05 `"5"', add
label define chsurv_sp_lbl 06 `"6"', add
label define chsurv_sp_lbl 07 `"7"', add
label define chsurv_sp_lbl 08 `"8"', add
label define chsurv_sp_lbl 09 `"9"', add
label define chsurv_sp_lbl 10 `"10"', add
label define chsurv_sp_lbl 11 `"11"', add
label define chsurv_sp_lbl 12 `"12"', add
label define chsurv_sp_lbl 13 `"13"', add
label define chsurv_sp_lbl 14 `"14"', add
label define chsurv_sp_lbl 15 `"15"', add
label define chsurv_sp_lbl 16 `"16"', add
label define chsurv_sp_lbl 17 `"17"', add
label define chsurv_sp_lbl 18 `"18"', add
label define chsurv_sp_lbl 19 `"19"', add
label define chsurv_sp_lbl 20 `"20"', add
label define chsurv_sp_lbl 21 `"21"', add
label define chsurv_sp_lbl 22 `"22"', add
label define chsurv_sp_lbl 23 `"23"', add
label define chsurv_sp_lbl 24 `"24"', add
label define chsurv_sp_lbl 25 `"25"', add
label define chsurv_sp_lbl 26 `"26"', add
label define chsurv_sp_lbl 27 `"27"', add
label define chsurv_sp_lbl 28 `"28"', add
label define chsurv_sp_lbl 29 `"29"', add
label define chsurv_sp_lbl 30 `"30+"', add
label define chsurv_sp_lbl 98 `"Unknown"', add
label define chsurv_sp_lbl 99 `"NIU (not in universe)"', add
label values chsurv_sp chsurv_sp_lbl

label define yrschool_sp_lbl 00 `"None or pre-school"'
label define yrschool_sp_lbl 01 `"1 year"', add
label define yrschool_sp_lbl 02 `"2 years"', add
label define yrschool_sp_lbl 03 `"3 years"', add
label define yrschool_sp_lbl 04 `"4 years"', add
label define yrschool_sp_lbl 05 `"5 years"', add
label define yrschool_sp_lbl 06 `"6 years"', add
label define yrschool_sp_lbl 07 `"7 years"', add
label define yrschool_sp_lbl 08 `"8 years"', add
label define yrschool_sp_lbl 09 `"9 years"', add
label define yrschool_sp_lbl 10 `"10 years"', add
label define yrschool_sp_lbl 11 `"11 years"', add
label define yrschool_sp_lbl 12 `"12 years"', add
label define yrschool_sp_lbl 13 `"13 years"', add
label define yrschool_sp_lbl 14 `"14 years"', add
label define yrschool_sp_lbl 15 `"15 years"', add
label define yrschool_sp_lbl 16 `"16 years"', add
label define yrschool_sp_lbl 17 `"17 years"', add
label define yrschool_sp_lbl 18 `"18 years or more"', add
label define yrschool_sp_lbl 90 `"Not specified"', add
label define yrschool_sp_lbl 91 `"Some primary"', add
label define yrschool_sp_lbl 92 `"Some technical after primary"', add
label define yrschool_sp_lbl 93 `"Some secondary"', add
label define yrschool_sp_lbl 94 `"Some tertiary"', add
label define yrschool_sp_lbl 95 `"Adult literacy"', add
label define yrschool_sp_lbl 96 `"Special education"', add
label define yrschool_sp_lbl 98 `"Unknown/missing"', add
label define yrschool_sp_lbl 99 `"NIU (not in universe)"', add
label values yrschool_sp yrschool_sp_lbl

label define empstat_sp_lbl 0 `"NIU (not in universe)"'
label define empstat_sp_lbl 1 `"Employed"', add
label define empstat_sp_lbl 2 `"Unemployed"', add
label define empstat_sp_lbl 3 `"Inactive"', add
label define empstat_sp_lbl 9 `"Unknown/missing"', add
label values empstat_sp empstat_sp_lbl

label define occisco_sp_lbl 01 `"Legislators, senior officials and managers"'
label define occisco_sp_lbl 02 `"Professionals"', add
label define occisco_sp_lbl 03 `"Technicians and associate professionals"', add
label define occisco_sp_lbl 04 `"Clerks"', add
label define occisco_sp_lbl 05 `"Service workers and shop and market sales"', add
label define occisco_sp_lbl 06 `"Skilled agricultural and fishery workers"', add
label define occisco_sp_lbl 07 `"Crafts and related trades workers"', add
label define occisco_sp_lbl 08 `"Plant and machine operators and assemblers"', add
label define occisco_sp_lbl 09 `"Elementary occupations"', add
label define occisco_sp_lbl 10 `"Armed forces"', add
label define occisco_sp_lbl 11 `"Other occupations, unspecified or n.e.c."', add
label define occisco_sp_lbl 97 `"Response suppressed"', add
label define occisco_sp_lbl 98 `"Unknown"', add
label define occisco_sp_lbl 99 `"NIU (not in universe)"', add
label values occisco_sp occisco_sp_lbl

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

ren geo1_mx2010 CVE_EDO
ren geo2_mx2010 CVE_MUN
replace CVE_MUN = mod(CVE_MUN,1000) /*remove state code from start of muni code*/
do "$programs/01_dataprep/master_munis.do"

ren mx2010a_migstat5 edo_5years
replace edo_5years=. if edo_5years>90

ren mx2010a_migmuni5 mun_5years
replace mun_5years = . if mun_5years>90000|mod(mun_5years,1000)==999
replace mun_5years = mod(mun_5years,1000) /*remove state code from start of muni code*/
do "$programs/01_dataprep/master_muni_5years.do"

tab urban
gen urbanres = urban-1
label var urbanres "Lives in urban area"
drop urban sizemx

drop if edo_born==. | edo_5years==. | mun_5years==. | CVE_EDO==. | CVE_MUN==.

gen migrant=1 if CVE_EDO~=. & edo_born~=. & edo_5years~=.
replace migrant=0 if edo_born==CVE_EDO & edo_born==edo_5years & CVE_MUN==mun_5years
label var migrant "Living in diff muni 5 yrs ago or born in diff state"

tab migrate5
label list migrate5_lbl
gen mig5muni = (migrate5>11) if migrate5>10 /*treat code 10 (154 obs) as missing: municipal migration is unclear*/
label var mig5muni "Living in diff muni 5 yrs ago"
gen mig5edo = (migrate5==20) if migrate5>10 
label var mig5edo "Living in diff state 5 yrs ago"
gen mig5intra = (migrate5==12) if migrate5>10 
label var mig5intra "Living in same state, diff muni 5 yrs ago"
drop migrate5

*generate pre program residence codes for linking benef data
**define program participation based on muni of residence in 2005, irrespective of place of birth**
gen CVE_EDO_PRE=edo_5years
gen CVE_MUN_PRE=mun_5years

*pre program residence =2005 municipality and state for those born in same state as residing 2005
gen CVE_EDO_PRE_alt=CVE_EDO_PRE
gen CVE_MUN_PRE_alt=CVE_MUN_PRE
replace CVE_EDO_PRE_alt=edo_born if edo_5years~=edo_born
replace CVE_MUN_PRE_alt=. if edo_5years~=edo_born

*label
la var CVE_EDO_PRE "2005 state"
la var CVE_MUN_PRE "2005 municipality"
la var CVE_EDO_PRE_alt "Alternate pre-program state"
la var CVE_MUN_PRE_alt "Alternate pre-program municipality"

//housing conditions and appliances
tab autos
gen hascar = (autos==7) if autos<8
label var hascar "Has >=1 auto"
drop autos

tab cell
gen hascell = (cell==1) if cell>0&cell<3
label var hascell "Has >=1 cell phone"
drop cell

tab computer
gen hascomp = (computer==2) if computer>0&computer<3
label var hascomp "Has >=1 computer"
drop computer

tab washer
gen haswasher = (washer==2) if washer>0&washer<3
label var haswasher "Has washer"
drop washer

tab electric
gen haselec = (electric==1) if electric>0&electric<3
label var haselec "Has electricity"
drop electric

tab hotwater
gen hashotwater = (hotwater==2) if hotwater>0&hotwater<3
label var hashotwater "Has water heater"
drop hotwater

tab refrig
gen hasrefrig = (refrig==2) if refrig>0&refrig<3
label var hasrefrig "Has refrigerator"
drop refrig

tab tv
gen hastv = (tv==20) if tv>0&tv<90
label var hastv "Has television"
drop tv

tab ownership
gen ownhome = (ownership<2) if ownership>0&ownership<9
label var ownhome "Owns dwelling"
drop ownership ownershipd

tab rooms
replace rooms = . if bedrooms>25

tab bedrooms
replace bedrooms = . if bedrooms>20

tab floor
gen dirtfloor = (floor==100) if floor>0&floor<999
label var dirtfloor "Dirt floor"
drop floor

tab wall
drop wall /*hard to rank, so don't use for now*/

tab roof
gen modernroof = (roof<45) if roof>0&roof<90
label var modernroof "Modern roofing material"
drop roof

tab sewage
gen hassewage = (sewage<20) if sewage>0&sewage<90
label var hassewage "Sewage"
drop sewage

tab toilet
gen hasflush = (toilet==21) if toilet>0&toilet<99
label var hasflush "Has flush toilet"
drop toilet

tab watsup
gen haspipe = (watsup<20) if watsup>0&watsup<90
label var haspipe "Access to piped water"
drop watsup
  

//fertility and marriage and household composition
tab chborn
recode chborn chborn_sp chsurv chsurv_sp (98/99=.)

tab marst
gen married = (marst==2) if marst<9
label var married "Currently married"
drop marst*

tab age_sp
replace age_sp = . if age_sp>100

tab yrschool_sp
replace yrschool_sp = . if yrschool_sp==98
ren yrschool_sp years_sp

tab empstat_sp
gen trabajo_sp = (empstat_sp==1) if empstat_sp<9
la var trabajo_sp "Working last week [spouse]"
drop empstat_sp

sum incearn_sp mx2010a_income_sp,d /*for some reason, only incearn_sp is non-missing*/
gen ingtrmen_sp = incearn_sp if incearn_sp<99999998
la var ingtrmen_sp "Labor income last month [of spouse]"

drop mx2010a_income_sp

tab occisco_sp /*1-3 high skilled white collar, 4-5 low skilled white collar, 6-7 high blue, 8-9 low blue*/
gen occ_white_sp = (occisco<6) if occisco<98
la var occ_white_sp "White collar occupation"
gen occ_skilled_sp = (occisco<3)|(occisco>5&occisco<8) if occisco<98
la var occ_skilled_sp "Skilled occupation"
drop occisco_sp

tab mx2010a_momhh
gen momhome = (mx2010a_momhh==1) if mx2010a_momhh<9
label var momhome "Mother living in same residence"
drop mx2010a_momhh

tab mx2010a_pophh
gen dadhome = (mx2010a_pophh==1) if mx2010a_pophh<9
label var dadhome "Father living in same residence"
drop mx2010a_pophh

d mx2010a_inchome
ren mx2010a_inchome ingtrmen_hh
recode ingtrmen_hh (999999=.)

d mx2010a_persons
ren mx2010a_persons persons

gen ingtrmen_hh_pc = ingtrmen_hh/persons

drop sploc

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

tab indgen
gen sector_agric = (indgen==10) if indgen>0&indgen<999
la var sector_agric "Agriculture sector"

ren hrswork1 hortra
replace hortra = . if hortra>900


sum incearn mx2010a_income,d
corr incearn mx2010a_income if mx2010a_income<999998 /*same earnings measure, difference in summary stats is due to traetment of missing/DK*/
sum incearn if mx2010a_income==999997
sum incearn if mx2010a_income==999998
sum incearn if mx2010a_income==999999
gen ingtrmen = incearn if incearn<99999998
la var ingtrmen "Labor income last month"
drop mx2010a_income


//health insurance 
tab hlthcov
replace hlthcov = . if hlthcov==99
gen hlthcovimss = (hlthcov==10)|(hlthcov>60&hlthcov<65)|(hlthcov>71&hlthcov<75) if hlthcov<.
gen hlthcovjob = (hlthcov<40)|(hlthcov>=60&hlthcov~=70&hlthcov~=71&hlthcov<90) if hlthcov<.
gen hlthcovpub = (hlthcov==40)|(hlthcov==63)|(hlthcov==66)|(hlthcov==68)|(hlthcov==80) if hlthcov<.
replace hlthcov = (hlthcov<90) if hlthcov<.
label var hlthcovjob "Has health insurance through job"
label var hlthcovpub "Has public health insurance"

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

recode lit (1=0) (2=1) (9=.)
label values lit

tab school
recode school (2=0) (9=.)

order year sample pernum perwt ///
      serial urbanres CVE_EDO CVE_MUN ///
	  edo_born edo_5years mun_5years migrant mig5* CVE_EDO_PRE CVE_MUN_PRE ///
	  age sex ///
	  lit school years some_sec some_prep some_college ///
	  ingtrmen hortra trabajo wage occ_white occ_skilled sector_agric hlthcov* ///
	  chborn chsurv ///
      married age_sp years_sp ingtrmen_sp trabajo_sp occ_white_sp occ_skilled_sp chborn_sp chsurv_sp ///
	  momhome dadhome ingtrmen_hh ///
	  ownhome rooms bedrooms hascar hascell hascomp haswasher haselec hashotwater hasrefrig hastv dirtfloor modernroof hassewage hasflush haspipe     
	      
saveold "$tempdata/mex_2010_ipums.dta",replace version(12)

********************************
**Merge child counts for women**
********************************
merge 1:1 serial pernum using "$tempdata/mex_2010_kids_ipums.dta"
drop if _merge==2 /*only in the kids file.*/
drop _merge
replace kids_0_19 = 0 if age>=22&age<=33&sex==2&kids_0_19==.
replace kids_0_21 = 0 if age>=22&age<=33&sex==2&kids_0_21==.
saveold "$tempdata/mex_2010_ipums.dta",replace version(12)

****************************************************************
**Merge municipal and state level beneficiary and characteristics data 
****************************************************************

sort CVE_EDO_PRE CVE_MUN_PRE
merge CVE_EDO_PRE CVE_MUN_PRE using "$tempdata/all_municipal_data_1990.dta"
tab _merge
drop _merge

sort edo_born 
merge m:1 edo_born using "$tempdata/all_state_data_1990.dta"
tab _merge
drop _merge

egen mun_pre=concat(CVE_EDO_PRE CVE_MUN_PRE)
gen MUN_PRE=real(mun_pre)

saveold "$tempdata/mex_2010_ipums.dta",replace version(12)
