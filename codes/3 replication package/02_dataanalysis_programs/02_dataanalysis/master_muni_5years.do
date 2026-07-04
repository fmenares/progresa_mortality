*converts municipality codes to 1990 master-municipalities, based on PDFs that detail the creation of new municipalities

*PDF 90-95
replace mun_5years=1 if mun_5years==10 & edo_5years==1
replace mun_5years=1 if mun_5years==11 & edo_5years==1

replace mun_5years=4 if mun_5years==5 & edo_5years==2

replace mun_5years=1 if mun_5years==5 & edo_5years==3

replace mun_5years=72 if mun_5years==76 & edo_5years==12

*When new municipios combine more than one ex-municipios they take a new maste code, where first digit referes to the number of municipios combined and the rest of the code y their own codes in 1990 combined (3 digits per own code). 
replace mun_5years=4025039070029 if mun_5years==122 & edo_5years==15
replace mun_5years=4025039070029 if mun_5years==25 & edo_5years==15
replace mun_5years=4025039070029 if mun_5years==39 & edo_5years==15
replace mun_5years=4025039070029 if mun_5years==70 & edo_5years==15
replace mun_5years=4025039070029 if mun_5years==29 & edo_5years==15

replace mun_5years=1 if mun_5years==8 & edo_5years==23

replace mun_5years=37 if mun_5years==57 & edo_5years==24
replace mun_5years=10 if mun_5years==58 & edo_5years==24

replace mun_5years=20 if mun_5years==45 & edo_5years==29
replace mun_5years=30 if mun_5years==46 & edo_5years==29
replace mun_5years=30 if mun_5years==47 & edo_5years==29
replace mun_5years=2010029 if mun_5years==48 & edo_5years==29
replace mun_5years=2010029 if mun_5years==10 & edo_5years==29
replace mun_5years=2010029 if mun_5years==29 & edo_5years==29

replace mun_5years=32 if mun_5years==49 & edo_5years==29
replace mun_5years=10 if mun_5years==50 & edo_5years==29
replace mun_5years=32 if mun_5years==51 & edo_5years==29
replace mun_5years=38 if mun_5years==52 & edo_5years==29
replace mun_5years=29 if mun_5years==53 & edo_5years==29
replace mun_5years=44 if mun_5years==54 & edo_5years==29
replace mun_5years=40 if mun_5years==55 & edo_5years==29
replace mun_5years=15 if mun_5years==56 & edo_5years==29
replace mun_5years=23 if mun_5years==57 & edo_5years==29
replace mun_5years=44 if mun_5years==58 & edo_5years==29
replace mun_5years=22 if mun_5years==59 & edo_5years==29
replace mun_5years=29 if mun_5years==60 & edo_5years==29

*PDF 95-00
replace mun_5years=2004006 if mun_5years==11 & edo_5years==4
replace mun_5years=2004006 if mun_5years==4 & edo_5years==4
replace mun_5years=2004006 if mun_5years==6 & edo_5years==4


replace mun_5years=3003004009 if mun_5years==10 & edo_5years==4
replace mun_5years=3003004009 if mun_5years==3 & edo_5years==4
replace mun_5years=3003004009 if mun_5years==4 & edo_5years==4
replace mun_5years=3003004009 if mun_5years==9 & edo_5years==4



replace mun_5years=26 if mun_5years==113 & edo_5years==7
replace mun_5years=59 if mun_5years==114 & edo_5years==7
replace mun_5years=52 if mun_5years==115 & edo_5years==7
replace mun_5years=59 if mun_5years==116 & edo_5years==7
replace mun_5years=8 if mun_5years==117 & edo_5years==7
replace mun_5years=81 if mun_5years==118 & edo_5years==7
replace mun_5years=49 if mun_5years==119 & edo_5years==7

replace mun_5years=26 if mun_5years==71 & edo_5years==26
replace mun_5years=29 if mun_5years==72 & edo_5years==26

replace mun_5years=2045054 if mun_5years==208 & edo_5years==30
replace mun_5years=2045054 if mun_5years==45 & edo_5years==30
replace mun_5years=2045054 if mun_5years==54 & edo_5years==30

replace mun_5years=2104149 if mun_5years==209 & edo_5years==30
replace mun_5years=2104149 if mun_5years==104 & edo_5years==30
replace mun_5years=2104149 if mun_5years==149 & edo_5years==30

replace mun_5years=4108091070061 if mun_5years==210 & edo_5years==30
replace mun_5years=4108091070061 if mun_5years==108 & edo_5years==30
replace mun_5years=4108091070061 if mun_5years==91 & edo_5years==30
replace mun_5years=4108091070061 if mun_5years==70 & edo_5years==30
replace mun_5years=4108091070061 if mun_5years==61 & edo_5years==30


replace mun_5years=17 if mun_5years==57 & edo_5years==32


*PDF 00-05
replace mun_5years=2013023 if mun_5years==77 & edo_5years==12
replace mun_5years=2013023 if mun_5years==13 & edo_5years==12
replace mun_5years=2013023 if mun_5years==23 & edo_5years==12

replace mun_5years=43 if mun_5years==78 & edo_5years==12
replace mun_5years=2028010 if mun_5years==79 & edo_5years==12
replace mun_5years=2028010 if mun_5years==28 & edo_5years==12
replace mun_5years=2028010 if mun_5years==10 & edo_5years==12

replace mun_5years=13 if mun_5years==80 & edo_5years==12
replace mun_5years=2041052 if mun_5years==81 & edo_5years==12
replace mun_5years=2041052 if mun_5years==41 & edo_5years==12
replace mun_5years=2041052 if mun_5years==52 & edo_5years==12


replace mun_5years=82 if mun_5years==123 & edo_5years==15
replace mun_5years=74 if mun_5years==124 & edo_5years==15
replace mun_5years=44 if mun_5years==125 & edo_5years==15

replace mun_5years=102 if mun_5years==211 & edo_5years==30
replace mun_5years=130 if mun_5years==212 & edo_5years==30

replace mun_5years=7001003004019023045047 if mun_5years==58 & edo_5years==32
replace mun_5years=7001003004019023045047 if mun_5years==1 & edo_5years==32
replace mun_5years=7001003004019023045047 if mun_5years==3 & edo_5years==32
replace mun_5years=7001003004019023045047 if mun_5years==4 & edo_5years==32
replace mun_5years=7001003004019023045047 if mun_5years==19 & edo_5years==32
replace mun_5years=7001003004019023045047 if mun_5years==23 & edo_5years==32
replace mun_5years=7001003004019023045047 if mun_5years==45 & edo_5years==32
replace mun_5years=7001003004019023045047 if mun_5years==47 & edo_5years==32

*PDF 05-10
replace mun_5years=8 if mun_5years==125 & edo_5years==14

replace mun_5years=8 if mun_5years==9 & edo_5years==23
