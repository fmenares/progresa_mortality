clear
set more off
capture log close
set seed 1234

if c(username)=="felip" {
    
	global deaths "C:\Users\felip\Dropbox\R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "C:\Users\felip\Dropbox\2024\70ymas\data/"
	
	global output "C:/Users/felip/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global iter "C:\Users\felip\Dropbox\R01_MHAS\Progresa_Locality_Mortality_Project\CensusData_ITER\" 
	global SP "C:\Users\felip\Dropbox\R01_MHAS\SocialProgramBeneficiaries"
}

if c(username)=="fmenares" {
    global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "/data/Dropbox0/fmenares/Dropbox/2024/70ymas/data/"
	global output  "/hdir/0/fmenares/Dropbox/Aplicaciones/Overleaf/70yMas/"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}

if c(username)=="FELIPEME" {
    global deaths "/hdir/0/fmenares/Dropbox/R01_MHAS\Mortality_VitalStatistics_Project\RawData_Mortality_VitalStatistics\"
	global data "C:/Users/FELIPEME/OneDrive - Inter-American Development Bank Group/Documents/personal/progresa_mortality/data/"
	global output  "C:\Users\FELIPEME\OneDrive - Inter-American Development Bank Group\Documents\personal\70ymas\"
	global iter "/hdir/0/fmenares/Dropbox/R01_MHAS/Progresa_Locality_Mortality_Project\CensusData_ITER\"
	global SP "/hdir/0/fmenares/Dropbox/R01_MHAS\SocialProgramBeneficiaries"


}

/*
Total Household Income includes income from all sources (earnings, private and government transfers). 
TRIMESTRAL
 
INGMON

Ingreso Corriente Monetario Σ de las claves P001-P048
	Remuneraciones al Trabajo 
		Σ de las claves P001-P009, P020 y P022
	Ingresos Netos de los Negocios Propios (Renta empresarial)
		Σ de las claves P010-P017, P023
	Ingresos Netos por Cooperativas 
		Σ de las claves P018-P019
	Ingresos netos por renta de la propiedad
		Σ de las claves P021, P024-P036
	Transferencias 
		Σ de las claves P037-P047
	Otros ingresos 
		Σ de las claves P048
		
*2006
Ingreso corriente monetario
Σ de las claves P001-P061 de Ingresos
Remuneraciones por trabajo subordinado
Σ de las claves P001-P009, P019-P027 de Ingresos
Ingresos netos por trabajo independiente
Σ de las claves P010-P016, P017, P018, P029-P038 de ingresos
Renta de la propiedad
Σ de las claves P039-P047, P028 de ingresos
Transferencias
Σ de las claves P048-P060 de ingresos
Otros ingresos
Σ de las claves P061 de ingresos
		
Total Household Expenditures" includes expenditures on food, rent, utilities,
appliances, health care, clothing, transportation, and other items (recreation, education).
 
Gasto Corriente Monetario
GASMON
INGMON GASMON 
Households spend the food budget

Alimentos preparados (para consumir en casa) Σ de claves A194-A198
Gastos relacionados con la elaboración de alimentos Σ de claves A207-A208


32% of on grains/starches/cereals,
30% on dairy and meat, 
11% on sweets, sugars, and soft drinks, 
19% on fruits and vegetables, 
and the remaining 8% on food outside the
home, coffee, spices, and other goods. 
A small percentage of this remainder includes alcohol and tobacco.
*/


global years = "1992 1994 1996 1998 2000"

*in 2002 there is education for everyone, but not in 2004 and so on
foreach year in $years {
local year = 1992
/*
*household
use $data/ENIGH/`year'/hogares.dta, clear
keep FOLIO CONAPO

CONAPO classification is not available for 2005
*household - consolidate
*/


*HH expenditure / spending
{

use "$data/ENIGH/`year'/gastos.dta", clear
rename _all, upper
keep FOLIO CLAVE PRECIO GAS_TRI CANTIDAD
gen code_l = substr(CLAVE, 1,1)
gen code_n = substr(CLAVE, 2, 4)
destring(code_n), replace force

if `year' == 1992 {
	
	replace GAS_TRI = GAS_TRI / 1000
	g cereals_d = (code_l == "A" & inrange(code_n, 1, 20))
	*meat fish shelfish
	g meat_fish_seafood_d = (code_l == "A" & inrange(code_n, 21, 58))

	*eggs and milk
	g dairy_d = (code_l == "A" & (inrange(code_n, 59, 78)))
			   
	g oils_fats_d = (code_l == "A" & inrange(code_n, 79, 83)) 
	g vegg_fruit_d = (code_l == "A" & inrange(code_n, 84, 143)) 

	g sugar_d = (code_l == "A" & inrange(code_n, 144, 146)) 

	g coffe_d = (code_l == "A" & inrange(code_n, 147, 153)) 
	g specias_d = (code_l == "A" & inrange(code_n, 154, 165))

	g baby_food_d = (code_l == "A" & inrange(code_n, 166, 167))

	*prepared food for house intake
	g takeout_d = (code_l == "A" & inrange(code_n, 168, 172))
	*alimentos diversos
	g food_diverse = (code_l == "A" & inrange(code_n, 173, 173))
	*desserts/pastries
	g desserts_d = (code_l == "A" & inrange(code_n, 174, 181))
	*spending related to food elaboration
	g others_d = (code_l == "A" & inrange(code_n, 182, 182))

	g packaged_food_d = 0

	g pet_food_d = (code_l == "A" & inrange(code_n, 183, 184))

	g soft_drink_d = (code_l == "A" & inrange(code_n, 185, 189))

	g alcohol_d = (code_l == "A" & inrange(code_n, 190, 198))

	*food ate outside
	g outside_d = (code_l == "A" & inrange(code_n, 199, 202))

	g tobacco_d = (code_l == "A" & inrange(code_n, 203, 205))
}

if `year' == 1994 {
	g cereals_d = (code_l == "A" & inrange(code_n, 1, 21))
	*meat fish shelfish
	g meat_fish_seafood_d = (code_l == "A" & inrange(code_n, 22, 59))

	*eggs and milk
	g dairy_d = (code_l == "A" & (inrange(code_n, 60, 79)))
			   
	g oils_fats_d = (code_l == "A" & inrange(code_n, 80, 84)) 
	g vegg_fruit_d = (code_l == "A" & inrange(code_n, 85, 145)) 

	g sugar_d = (code_l == "A" & inrange(code_n, 146, 148)) 

	g coffe_d = (code_l == "A" & inrange(code_n, 149, 155)) 
	g specias_d = (code_l == "A" & inrange(code_n, 156, 166))

	g baby_food_d = (code_l == "A" & inrange(code_n, 167, 169))

	*prepared food for house intake
	g takeout_d = (code_l == "A" & inrange(code_n, 170, 175))
	*alimentos diversos
	g food_diverse = (code_l == "A" & inrange(code_n, 176, 176))
	*desserts/pastries
	g desserts_d = (code_l == "A" & inrange(code_n, 177, 183))
	*spending related to food elaboration
	g others_d = (code_l == "A" & inrange(code_n, 184, 185))

	g packaged_food_d = 0

	g pet_food_d = (code_l == "A" & inrange(code_n, 186, 187))

	g soft_drink_d = (code_l == "A" & inrange(code_n, 188, 193))

	g alcohol_d = (code_l == "A" & inrange(code_n, 194, 203))

	*food ate outside
	g outside_d = (code_l == "A" & inrange(code_n, 205, 207))

	g tobacco_d = (code_l == "A" & inrange(code_n, 208, 210))
}
	
else if `year' > 1994 {

	g cereals_d = (code_l == "A" & inrange(code_n, 1, 21))
	*meat fish shelfish
	g meat_fish_seafood_d = (code_l == "A" & inrange(code_n, 22, 59))

	*eggs and milk
	g dairy_d = (code_l == "A" & (inrange(code_n, 60, 79)))
			   
	g oils_fats_d = (code_l == "A" & inrange(code_n, 80, 84)) 
	g vegg_fruit_d = (code_l == "A" & inrange(code_n, 85, 146)) 

	g sugar_d = (code_l == "A" & inrange(code_n, 147, 149)) 

	g coffe_d = (code_l == "A" & inrange(code_n, 150, 156)) 
	g specias_d = (code_l == "A" & inrange(code_n, 157, 167))

	g baby_food_d = (code_l == "A" & inrange(code_n, 168, 170))

	*prepared food for house intake
	g takeout_d = (code_l == "A" & inrange(code_n, 171, 176))
	*alimentos diversos
	g food_diverse = (code_l == "A" & inrange(code_n, 177, 177))
	*desserts/pastries
	g desserts_d = (code_l == "A" & inrange(code_n, 178, 184))
	*spending related to food elaboration
	g others_d = (code_l == "A" & inrange(code_n, 185, 186))

	g packaged_food_d = 0

	g pet_food_d = (code_l == "A" & inrange(code_n, 187, 188))

	g soft_drink_d = (code_l == "A" & inrange(code_n, 189, 194))

	g alcohol_d = (code_l == "A" & inrange(code_n, 195, 204))

	*food ate outside
	g outside_d = (code_l == "A" & inrange(code_n, 205, 208))

	g tobacco_d = (code_l == "A" & inrange(code_n, 209, 211))
}

g cereals = cereals_d * GAS_TRI/ 3
g meat_dairy = (meat_fish_seafood_d + dairy_d) * GAS_TRI/ 3
g sugar_fat_drink = (oils_fats_d + sugar_d + soft_drink_d + desserts_d) * GAS_TRI/3
g vegg_fruit = vegg_fruit_d * GAS_TRI / 3
g coffe_spices_other = (coffe_d + specias_d + others_d) * GAS_TRI /3
g tobacco = tobacco_d * GAS_TRI/3
g outside_food = (takeout_d + outside_d) * GAS_TRI/3
g alcohol = alcohol_d * GAS_TRI /3

g packaged_food = packaged_food_d * GAS_TRI/3
g baby_food = baby_food_d * GAS_TRI/3
g pet_food = pet_food_d * GAS_TRI/3


* HEALTH

if inlist(`year', 1992, 1994) {
	g medical_outpatient_d = (code_l == "J" & (inrange(code_n, 01, 03) | inlist(code_n, 5, 6, 9)))
	g drugs_prescribed_d = (code_l =="J" & (inlist(code_n, 4, 11)))
	g medical_inpatient_d = (code_l == "J" & inlist(code_n, 10, 12, 13, 14, 15))
	g drugs_overcounter_d = (code_l == "J" & inrange(code_n, 30, 36))
	g ortho_d = (code_l == "J" & inrange(code_n, 37, 41))
	g insurance_cost_d = (code_l == "J" & inrange(code_n, 42, 43))
}

else {
	g medical_outpatient_d = (code_l == "J" & (inrange(code_n, 01, 03) | inlist(code_n, 5, 6, 9)))
	g drugs_prescribed_d = (code_l =="J" & (inlist(code_n, 4, 11)))
	g medical_inpatient_d = (code_l == "J" & inlist(code_n, 10, 12, 13, 14, 15))
	g drugs_overcounter_d = (code_l == "J" & inrange(code_n, 34, 38))
	g ortho_d = (code_l == "J" & inrange(code_n, 39, 43))
	g insurance_cost_d = (code_l == "J" & inrange(code_n, 44, 45))
}


g medical_outpatient = medical_outpatient_d * GAS_TRI/3
g drugs_prescribed = drugs_prescribed_d * GAS_TRI/3
g medical_inpatient = medical_inpatient_d * GAS_TRI/3
g drugs_overcounter = drugs_overcounter_d * GAS_TRI/3
g ortho = ortho_d * GAS_TRI/3
g insurance_cost = insurance_cost_d * GAS_TRI/3


}

collapse (sum) cereals meat_dairy sugar_fat_drink vegg_fruit coffe_spices_other ///
tobacco outside_food alcohol packaged_food baby_food pet_food ///
medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ortho ///
insurance_cost, by(FOLIO)

*EXPENDITURE/EROGACIONES (SAVINGS)
if `year' != 1992 {
merge 1:m FOLIO using "$data/ENIGH/`year'/eroga.dta", ///
keepus(FOLIO CLAVE ERO_TRI)

ren (CLAVE ERO_TRI) (clave ero_tri)

 	gen code_l = substr(clave, 1,1)
	gen code_n = substr(clave, 2, 4)
	destring(code_n), replace force


*debits/savings
g savings_d = (code_l == "Q" & code_n  == 1)
*loans to others outside of home
g loans_d = (code_l == "Q" & code_n == 2)
*payment of credit cards, loans, interest, mortgage

g debt_d = (code_l =="Q" & (inrange(code_n, 3, 4) | code_n == 10))	

g currency_d = (code_l == "Q" & code_n == 5)
	

g savings = savings_d * ero_tri/3
g loans = loans_d * ero_tri/3
g debt = debt_d * ero_tri/3
g currency = currency_d * ero_tri/3

collapse (mean) cereals meat_dairy sugar_fat_drink vegg_fruit coffe_spices_other ///
tobacco outside_food alcohol packaged_food baby_food pet_food ///
medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ortho ///
insurance_cost (sum) savings loans debt currency, by(FOLIO)
}

merge 1:1 FOLIO using "$data/ENIGH/`year'/concen.dta", keep(3) nogen ///
keepus(FOLIO ESTRATO UBICA_GEO HOMBRES MUJERES TOT_RESI HOG ///
GASMON INGMON EST_DIS UPM N_OCUP PERING MENORES)

*Education is only availble for head hh

if `year' == 1992 {
			*individuals 
	*only kept primary social security (first job)
	merge 1:m FOLIO using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
	keepus(FOLIO PARENTESCO SEXO EDAD NUM_REN PRESTACION ///
	TRAB_M_P ED_TECNICA ED_FORMAL HR_SEMANA)
	ren (HR_SEMANA) (hrs_worked)  
	decode TRAB_M_P, g(TRABAJO_s)	
	g EDOCONY = 0
	decode PRESTACION, g(presta_1)
	g presta_2 = presta_1
	destring UPM, g(upm)
	drop UPM
	ren upm UPM
	g progresa_benef_ind = 0
}

if `year' == 1994 {
		*individuals 
	*only kept primary social security (first job)
	
	merge 1:m FOLIO using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
	keepus(FOLIO PARENTESCO SEXO EDAD NUM_REN PRESTACIO1 PRESTACIO2 ///
	TRABAJO ED_TECNICA ED_FORMAL HRS_SEM)	
	g EDOCONY = 0
	ren HRS_SEM hrs_worked
	decode TRABAJO, g(TRABAJO_s)	
	decode PRESTACIO1, g(presta_1)
	decode PRESTACIO2, g(presta_2)
	g progresa_benef_ind = 0
	}
	
if inlist(`year', 1996, 1998) {
		*individuals 
	*only kept primary social security (first job)
	merge 1:m FOLIO using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
	keepus(FOLIO PARENTESCO SEXO EDAD EDO_CIVIL NUM_REN PRESTACIO1 PRESTACIO2 ///
	TRABAJO ED_TECNICA ED_FORMAL HRS_SEM)
  
	ren HRS_SEM hrs_worked
	decode TRABAJO, g(TRABAJO_s)	
	decode PRESTACIO1, g(presta_1)
	decode PRESTACIO2, g(presta_2)
	decode EDO_CIVIL, g(EDO_CONY_s)
	destring EDO_CONY_s, g(EDOCONY)
	drop EDO_CONY_s EDO_CIVIL
	g progresa_benef_ind = 0
	}
	
if `year' == 2000 {
		*individuals 
	*only kept primary social security (first job)
	merge 1:m FOLIO using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
	keepus(FOLIO PARENTESCO SEXO EDAD EDO_CIVIL NUM_REN PRESTACIO1 PRESTACIO2 ///
	TRABAJO ED_TECNICA ED_FORMAL HRS_SEM PROP_BECA)
  
	ren HRS_SEM hrs_worked
	decode TRABAJO, g(TRABAJO_s)	
	decode PRESTACIO1, g(presta_1)
	decode PRESTACIO2, g(presta_2)
	decode EDO_CIVIL, g(EDO_CONY_s)
	destring EDO_CONY_s, g(EDOCONY)
	drop EDO_CONY_s EDO_CIVIL
	g progresa_benef_ind = (PROP_BECA == 5)
	}
	
	
		
	* Assume the 40-char string variable is called mystr
	* Create seg01 ... seg20 as 2-character strings
	forvalues k = 1/20 {
		local start = 2*`k' - 1
		gen pres1_`=string(`k',"%02.0f")' = substr(presta_1, `start', 2)
		destring pres1_`=string(`k',"%02.0f")', g(pre1_`=string(`k',"%02.0f")')
		
		gen pres2_`=string(`k',"%02.0f")' = substr(presta_2, `start', 2)
		destring pres2_`=string(`k',"%02.0f")', g(pre2_`=string(`k',"%02.0f")')
	}

	
	
	decode PARENTESCO, g(PARENTESCO_s)
	drop PARENTESCO 

	destring(PARENTESCO_s  TRABAJO_s), g(PARENTESCO  trab)
	drop PARENTESCO_s  TRABAJO_s
	
	g trabajo = int(trab/100)
	replace trabajo = . if trab == 0
	g nivelaprob = 0
	g gradoaprob = 0
	g antec_esc = 0
    g hhh = (inlist(PARENTESCO, 1,2))
	
if `year' == 1996 {
	*education	
replace ED_FORMAL = 11 if ED_FORMAL == 15
replace ED_FORMAL = ED_FORMAL + 1
replace ED_TECNICA = ED_TECNICA + 1

}


g insurance = 0
g ss = 0

	
	forv i = 1/9 {
	 replace insurance = (inrange(pre1_0`i', 1, 7)) if insurance == 0
	 replace ss = (pre1_0`i' == 22) if ss == 0
	}
	forv i = 11/20 {
	 replace insurance = (inrange(pre1_`i', 1, 7)) if insurance == 0
	 replace ss = (pre1_`i' == 22) if ss == 0
	}

	*2
		forv i = 1/9 {
	 replace insurance = (inrange(pre2_0`i', 1, 7)) if insurance == 0
	 replace ss = (pre2_0`i' == 22) if ss == 0
	}
	forv i = 11/20 {
	 replace insurance = (inrange(pre2_`i', 1, 7)) if insurance == 0
	 replace ss = (pre2_`i' == 22) if ss == 0
	}
	


	merge 1:m FOLIO NUM_REN using "$data/ENIGH/`year'/ingresos.dta", ///
	keep(1 3) nogen keepus(CLAVE ING_TRI)
	sort FOLIO NUM_REN
	replace ING_TRI = 0 if ING_TRI == .
	
	if `year' == 1992 {
	replace ING_TRI = ING_TRI / 1000	
	}
	
	
ren ING_TRI ing_tri
	
gen code_l = substr(CLAVE, 1,1)
gen code_n = substr(CLAVE, 2, 4)
destring(code_n), replace force

	
*earnings 

	
if inrange(`year', 1992, 1996) {
	
		*wages from main job
	g wage_d = (code_l == "P" & (inrange(code_n, 1, 5)))
	*earnings from bussines
	g indep_w_d = (code_l == "P"  & (inrange(code_n, 6, 14)))
}

if inlist(`year', 1992) {
*earnings from property (capital) 
	g capital_d = (code_l == "P" & (inlist(code_n, 15) | inrange(code_n, 16, 21)))
	*transfers
	g transfer_d = (code_l == "P" & inrange(code_n, 22, 27))
	*other income
	g other_d = (code_l == "P" & inlist(code_n, 28, 29))
	*financial capital
	g financial_d = (code_l == "Q" & inrange(code_n, 13, 21))	
	
	*transfers

	g pensions_d = (code_l == "P" & code_n == 22)
	g severance_d = (code_l == "P" & inrange(code_n, 23, 24))
	g becas_don_non_gob_d = (code_l == "P" & code_n == 26)
	g becas_don_gob_d = (code_l == "P" & code_n == 25)
	g family_trans_d = 0
	*family trans could be included in ser becas_don_pais_d, but also in becas_don_non_gob
	*highly likely that becas_don_inst = progresa
	*remittances / remesas
	g remit_d = (code_l == "P" & code_n == 27)
	g progresa_d = 0
	*in 2002, donations and scholarships were together by government and non-government
	*thus, the transfer can be overestimated
	g benef_gob_d = (code_l == "P" & code_n == 25)
	
	g procampo_d = 0
	
	g savings_d = (code_l == "Q" & code_n  == 1)
	*loans to others outside of home
	g loans_d = (code_l == "Q" & code_n == 2)
	*payment of credit cards, loans, interest, mortgage
	g debt_d = (code_l =="Q" & (inrange(code_n, 3, 4)))	
	
	g currency_d = (code_l == "Q" & code_n == 5)
	

	g savings = savings_d * ing_tri/3
	g loans = loans_d * ing_tri/3
	g debt = debt_d * ing_tri/3
	g currency = currency_d * ing_tri/3
	

	
	drop savings_d loans_d debt_d currency_d 

	
}





if `year' == 1994 {
	*earnings from property (capital) 
	g capital_d = (code_l == "P" & (inlist(code_n, 15) | inrange(code_n, 16, 22)))
	*transfers
	g transfer_d = ((code_l == "P" & inrange(code_n, 23, 28)) |  (code_l == "P" & code_n == 43) )
	*other income
	g other_d = (code_l == "P" & inlist(code_n, 29, 30))	
	
	*financial capital
	g financial_d = (code_l == "P" & inrange(code_n, 31, 42))
	*transfers

	g pensions_d = (code_l == "P" & code_n == 23)
	g severance_d = (code_l == "P" & inrange(code_n, 24, 25))
	g becas_don_non_gob_d = (code_l == "P" & code_n == 27)
	g becas_don_gob_d = (code_l == "P" & code_n == 26)
	g family_trans_d = 0
	*family trans could be included in ser becas_don_pais_d, but also in becas_don_non_gob
	*highly likely that becas_don_inst = progresa
	*remittances / remesas
	g remit_d = (code_l == "P" & code_n == 28)
	g progresa_d = 0
	*in 2002, donations and scholarships were together by government and non-government
	*thus, the transfer can be overestimated
	g benef_gob_d = (code_l == "P" & code_n == 26)
	g procampo_d = (code_l == "P" & code_n == 43)
	
}

if `year' == 1996 {
		*earnings from property (capital) 
	g capital_d = (code_l == "P" & (inlist(code_n, 15) | inrange(code_n, 16, 22)))
	
	*transfers
	g transfer_d = (code_l == "P" & inrange(code_n, 23, 29))
	
	*other income
	g other_d = (code_l == "P" & inlist(code_n, 30, 31))
	
	*financial capital
	g financial_d = (code_l == "P" & inrange(code_n, 32, 43))		
	
		*transfers

	g pensions_d = (code_l == "P" & code_n == 23)
	g severance_d = (code_l == "P" & inrange(code_n, 24, 25))
	g becas_don_non_gob_d = (code_l == "P" & code_n == 27)
	g becas_don_gob_d = (code_l == "P" & code_n == 26)
	g family_trans_d = 0
	*family trans could be included in ser becas_don_pais_d, but also in becas_don_non_gob
	*highly likely that becas_don_inst = progresa
	*remittances / remesas
	g remit_d = (code_l == "P" & code_n == 28)
	g progresa_d = 0
	*in 2002, donations and scholarships were together by government and non-government
	*thus, the transfer can be overestimated
	g benef_gob_d = (code_l == "P" & code_n == 26)
	g procampo_d = (code_l == "P" & code_n == 29)	
}


	

*year 1998 and 2000

else if `year' > 1996 {

		*wages from main job
	g wage_d = (code_l == "P" & (inrange(code_n, 1, 9)))
	*earnings from bussines
	g indep_w_d = (code_l == "P"  & (inrange(code_n, 10, 18)))
	*earnings from property (capital) 
	g capital_d = (code_l == "P" & (inlist(code_n, 19) | inrange(code_n, 20, 27)))
	*transfers
	g transfer_d = (code_l == "P" & inrange(code_n, 28, 34))
	*other income
	g other_d = (code_l == "P" & inlist(code_n, 35, 36))
	*financial capital
	g financial_d = (code_l == "P" & inrange(code_n, 37, 48))

	*transfers

	g pensions_d = (code_l == "P" & code_n == 28)
	g severance_d = (code_l == "P" & inrange(code_n, 29, 30))
	g becas_don_non_gob_d = (code_l == "P" & code_n == 32)
	g becas_don_gob_d = (code_l == "P" & code_n == 31)
	g family_trans_d = 0
	*family trans could be included in ser becas_don_pais_d, but also in becas_don_non_gob
	*highly likely that becas_don_inst = progresa
	*remittances / remesas
	g remit_d = (code_l == "P" & code_n == 33)
	g progresa_d = (code_l == "P" & code_n == 31)
	*RENGLON P031 "Becas y Donativos provenientes de Instituciones"
/*La Secretaría de Desarrollo Social (SEDESOL) a implementado un mecanismo de ayuda para las familias de escasos
recursos (Programa Progresa).
Cuando los ingresos monetarios sean otorgados por este programa el cual es un apoyo económico que se proporciona
en efectivo en la modalidad de beca o donativo, se registran en este renglón al miembro del hogar responsable del
menor.*/
	g procampo_d = (code_l == "P" & code_n == 34)

	*in 2002, donations and scholarships were together by government and non-government
	*thus, the transfer can be overestimated
	g benef_gob_d = (code_l == "P" & code_n == 31)
}

g wage_ind_aux = wage_d * (ing_tri / 3)  
g indep_w_ind_aux = indep_w_d * (ing_tri / 3) 
gen capital_ind_aux = capital_d * (ing_tri / 3) 
gen transfer_ind_aux = transfer_d * (ing_tri / 3)
gen other_inc_ind_aux = other_d * (ing_tri / 3) 
gen financial_ind_aux = financial_d * (ing_tri / 3)
gen progresa_ind_aux = progresa_d * (ing_tri / 3)
gen benef_gob_ind_aux = benef_gob_d * (ing_tri / 3)
gen remit_ind_aux = remit_d * (ing_tri / 3)
gen family_trans_ind_aux = family_trans_d * (ing_tri / 3)
*gen pensions_ind_aux = pensions_d * (ing_tri / 3)
*gen severance_ind_aux = severance_d * (ing_tri / 3)
gen benef_don_gob_ind_aux = becas_don_gob_d * (ing_tri / 3)
gen benef_don_non_gob_ind_aux = becas_don_non_gob_d * (ing_tri / 3)


bys FOLIO NUM_REN: egen wage_ind = total(wage_ind_aux)
bys FOLIO NUM_REN: egen indep_w_ind = total(indep_w_ind_aux)
bys FOLIO NUM_REN: egen capital_ind = total(capital_ind_aux)
bys FOLIO NUM_REN: egen transfer_ind = total(transfer_ind_aux)
bys FOLIO NUM_REN: egen other_inc_ind = total(other_inc_ind_aux)
bys FOLIO NUM_REN: egen financial_ind = total(financial_ind_aux)
bys FOLIO NUM_REN: egen benef_gob_ind = total(benef_gob_ind_aux)
bys FOLIO NUM_REN: egen progresa_ind = total(progresa_ind_aux)
*bys FOLIO NUM_REN: egen pensions_ind = total(pensions_ind_aux)
bys FOLIO NUM_REN: egen remit_ind = total(remit_ind_aux)
bys FOLIO NUM_REN: egen family_trans_ind = total(family_trans_ind_aux)
bys FOLIO NUM_REN: egen benef_don_gob_ind = total(benef_don_gob_ind_aux)
bys FOLIO NUM_REN: egen benef_don_non_gob_ind = total(benef_don_non_gob_ind_aux)


g wage_hh_aux = wage_d * (ing_tri / 3)  
g indep_w_hh_aux = indep_w_d * (ing_tri / 3) 
g capital_hh_aux = capital_d * (ing_tri / 3) 
g transfer_hh_aux = transfer_d * (ing_tri / 3)
g other_inc_hh_aux = other_d * (ing_tri / 3) 
g financial_hh_aux = financial_d * (ing_tri / 3)
g benef_gob_hh_aux = benef_gob_d * (ing_tri / 3)
g progresa_hh_aux = progresa_d * (ing_tri / 3)
gen remit_hh_aux = remit_d * (ing_tri / 3)
gen family_trans_hh_aux = family_trans_d * (ing_tri / 3)
gen benef_don_gob_hh_aux = becas_don_gob_d * (ing_tri / 3)
gen benef_don_non_gob_hh_aux = becas_don_non_gob_d * (ing_tri / 3)


bys FOLIO: egen wage_hh = total(wage_hh_aux)
bys FOLIO: egen indep_w_hh = total(indep_w_hh_aux)
bys FOLIO: egen capital_hh = total(capital_hh_aux)
bys FOLIO: egen transfer_hh = total(transfer_hh_aux)
bys FOLIO: egen other_inc_hh = total(other_inc_hh_aux)
bys FOLIO: egen financial_hh = total(financial_hh_aux)
bys FOLIO: egen benef_gob_hh = total(benef_gob_hh_aux)
bys FOLIO: egen progresa_hh = total(progresa_hh_aux)
bys FOLIO: egen remit_hh = total(remit_hh_aux)
bys FOLIO: egen family_trans_hh = total(family_trans_hh_aux)
bys FOLIO: egen benef_don_gob_hh = total(benef_don_gob_hh_aux)
bys FOLIO: egen benef_don_non_gob_hh = total(benef_don_non_gob_hh_aux)

drop *_aux
drop financial_d other_d transfer_d capital_d indep_w_d wage_d ///
pensions_d severance_d becas_don_non_gob_d becas_don_gob_d ///
family_trans_d remit_d progresa_d procampo_d  benef_gob_d family_trans_d remit_d

bys FOLIO NUM_REN: keep if _n == 1



	g hhh_insured_aux = insurance * hhh
	g hhh_ss_aux = ss * hhh
	g hhh_age_aux = EDAD  * hhh
	g hhh_female_aux = (SEXO == 2) * hhh
	g hhh_ever_married_aux = (inrange(EDOCONY, 2, 5)) * hhh
	
	label define educ_attainment_lbl ///
1 "No education" ///
2 "Pre-school" ///
3 "Elementary incomplete" ///
4 "Elementary complete" ///
5 "Junior high incomplete" ///
6 "Junior high complete" ///
7 "High school incomplete" ///
8 "High school complete" ///
9 "College incomplete" ///
10 "College complete" ///
11 "Grad school"

if inlist(`year', 1992, 1994) {
	
		*education	
g educ_attainment = 1 * (ED_FORMAL == 0 | ED_TECNICA == 0) + ///
					2 * (ED_FORMAL == 10  | ED_TECNICA == 10) + ///					
					3 * (ED_FORMAL == 1 | ED_TECNICA == 1) + ///
					4 * (ED_FORMAL == 2 | ED_TECNICA == 2) + ///
					5 * (ED_FORMAL == 3 | ED_TECNICA == 3) + ///
					6 * (ED_FORMAL == 4 | ED_TECNICA == 4) + ///
					7 * (ED_FORMAL == 5 | ED_TECNICA == 5) + ///
					8 * (ED_FORMAL == 6 | ED_TECNICA == 6) + ///
                    9 * (ED_FORMAL == 7 | ED_TECNICA == 7) + ///
					10 * (ED_FORMAL == 8 | ED_TECNICA == 8) + ///
					11 * (ED_FORMAL == 9)
}


else if `year' > 1994 {
g educ_attainment = 1 * (ED_FORMAL == 1 | ED_TECNICA == 1) + ///
					2 * (ED_FORMAL == 2 | ED_TECNICA == 2) + ///					
					3 * (inrange(ED_FORMAL,3, 7)) + ///
					4 * ((ED_FORMAL == 8) | ED_TECNICA ==3 | ED_TECNICA ==4) + ///
					5 * (inrange(ED_FORMAL,9, 10)) + ///
					6 * ((ED_FORMAL == 11) | ED_TECNICA == 5 | ED_TECNICA == 6) + ///
					7 * (ED_FORMAL == 12) + ///
					8 * (ED_FORMAL == 13 | ED_TECNICA == 7 | ED_TECNICA == 8) + ///
                    9 * (ED_FORMAL == 14) + ///
					10 * (ED_FORMAL == 15 | ED_TECNICA == 9) + ///
					11 * (ED_FORMAL == 16)
}	

	
g hhh_educ_aux = educ_attainment * hhh 


bys FOLIO: egen progresa_benef_hh = max(progresa_benef_ind)

bys FOLIO: egen hhh_educ = max(hhh_educ_aux)
bys FOLIO: egen hhh_age = max(hhh_age_aux)
bys FOLIO: egen hhh_female = max(hhh_female_aux)
bys FOLIO: egen hhh_ever_married = max(hhh_ever_married_aux)
bys FOLIO: egen hhh_insured = max(hhh_insured_aux)
bys FOLIO: egen hhh_ss = max(hhh_ss_aux)


*I am keeping HH with individuals above 59, with the HH spending
keep if EDAD > 64
bys FOLIO: egen any_old_insured = max(insurance)
bys FOLIO: egen any_old_ss = max(ss)
bys FOLIO: egen max_age = max(EDAD)
bys FOLIO: egen max_age_female_aux = max(EDAD) if SEXO == 2
bys FOLIO: egen max_age_female = max(max_age_female_aux) 
bys FOLIO: egen max_age_male_aux = max(EDAD) if SEXO == 1
bys FOLIO: egen max_age_male = max(max_age_male_aux) 

ren EDAD age
g female = (SEXO == 2)
keep FOLIO EST_DIS UPM HOG ESTRATO HOMBRES MUJERES TOT_RESI INGMON ///
GASMON UBICA_GEO cereals meat_dairy sugar_fat_drink vegg_fruit female ///
coffe_spices_other tobacco outside_food alcohol packaged_food baby_food ///
pet_food N_OCUP PERING MENORES hhh_insured hhh_ever_married ///
hhh_female hhh_age max_age max_age_female max_age_male any_old_insured ///
hhh_ss any_old_ss ss insurance age remit_* family_trans_* ///
wage_* indep_w_* capital_* transfer_* other_inc_* financial_* benef_* progresa* ///
trabajo hhh_educ educ_attainment hrs_worked hhh medical_outpatient ///
drugs_prescribed medical_inpatient drugs_overcounter ///
ortho insurance_cost savings loans debt currency 


decode ESTRATO, g(estrato_s)
decode UBICA_GEO, g(ubica_geo)

if `year'== 1992 {
	ren EST_DIS est_dis
	destring(estrato_s), g(estrato)
	ren FOLIO folio
drop UBICA_GEO ESTRATO estrato_s
	}
	
else if `year' > 1992 {
	tostring EST_DIS, g(est_dis)	
	destring(estrato_s), g(estrato)
	ren FOLIO folio
	drop UBICA_GEO ESTRATO estrato_s EST_DIS
}


*hh_id hh_member strata upm fact_exp loc_size cve_ent_mun n_males n_females n_total 
*female age income spending 


g year = `year'




// Loop over each variable in the dataset
	foreach var of varlist _all {
		// Rename each variable to its uppercase version
		rename `var' `=lower("`var'")'
	}

save "$data/ENIGH/enigh_`year'", replace

}

*In 2002 was the first time progresa was separate from other transfers.

global years = "2002 2004 2005"

*in 2002 there is education for everyone, but not in 2004 and so on
foreach year in $years {
*local year = 2005
/*
*household
use $data/ENIGH/`year'/hogares.dta, clear
keep FOLIO CONAPO

CONAPO classification is not available for 2005
*household - consolidate
*/


*HH expenditure / spending
{

use "$data/ENIGH/`year'/gastos.dta", clear
keep FOLIO CLAVE COSTO DIA PRECIO GASTO GAS_TRI CANTIDAD
gen code_l = substr(CLAVE, 1,1)
gen code_n = substr(CLAVE, 2, 4)
destring(code_n), replace force

if `year' == 2002 {

	g cereals_d = (code_l == "A" & inrange(code_n, 1, 21))
	*meat fish shelfish
	g meat_fish_seafood_d = (code_l == "A" & inrange(code_n, 22, 70))

	*eggs and milk
	g dairy_d = (code_l == "A" & (inrange(code_n, 71, 90)))
			   
	g oils_fats_d = (code_l == "A" & inrange(code_n, 91, 96)) 
	g vegg_fruit_d = (code_l == "A" & inrange(code_n, 97, 168)) 

	g sugar_d = (code_l == "A" & inrange(code_n, 169, 171)) 

	g coffe_d = (code_l == "A" & inrange(code_n, 172, 178)) 
	g specias_d = (code_l == "A" & inrange(code_n, 179, 190))

	g baby_food_d = (code_l == "A" & inrange(code_n, 191, 193))

	*prepared food for house intake
	g takeout_d = (code_l == "A" & inrange(code_n, 194, 198))
	*alimentos diversos
	g food_diverse = (code_l == "A" & inrange(code_n, 199, 200))
	*desserts/pastries
	g desserts_d = (code_l == "A" & inrange(code_n, 201, 206))
	*spending related to food elaboration
	g others_d = (code_l == "A" & inrange(code_n, 207, 208))

	g packaged_food_d = inlist(CLAVE, "A209", "A243")

	g pet_food_d = (code_l == "A" & inrange(code_n, 210, 211))

	g soft_drink_d = (code_l == "A" & inrange(code_n, 212, 218))

	g alcohol_d = (code_l == "A" & inrange(code_n, 219, 234))

	*food ate outside
	g outside_d = (code_l == "A" & inrange(code_n, 235, 239))

	g tobacco_d = (code_l == "A" & inrange(code_n, 240, 242))

}

else {
			
	g cereals_d = (code_l == "A" & inrange(code_n, 1, 22))
	*meat fish shelfish
	g meat_fish_seafood_d = (code_l == "A" & inrange(code_n, 23, 71))

	*eggs and milk
	g dairy_d = (code_l == "A" & (inrange(code_n, 72, 91)))
			   
	g oils_fats_d = (code_l == "A" & inrange(code_n, 92, 97)) 
	g vegg_fruit_d = (code_l == "A" & inrange(code_n, 98, 168)) 

	g sugar_d = (code_l == "A" & inrange(code_n, 170, 172)) 

	g coffe_d = (code_l == "A" & inrange(code_n, 173, 179)) 
	g specias_d = (code_l == "A" & inrange(code_n, 180, 191))


	g baby_food_d = (code_l == "A" & inrange(code_n, 192, 194))

	*prepared food for house intake
	g takeout_d = (code_l == "A" & inrange(code_n, 195, 199))
	*alimentos diversos
	g food_diverse = (code_l == "A" & inrange(code_n, 200, 201))
	*desserts/pastries
	g desserts_d = (code_l == "A" & inrange(code_n, 202, 206))
	*spending related to food elaboration
	g others_d = (code_l == "A" & inrange(code_n, 207, 208))

	g packaged_food_d = inlist(CLAVE, "A209", "A243")

	g pet_food_d = (code_l == "A" & inrange(code_n, 210, 211))

	g soft_drink_d = (code_l == "A" & inrange(code_n, 212, 218))

	g alcohol_d = (code_l == "A" & inrange(code_n, 219, 234))

	*food ate outside
	g outside_d = (code_l == "A" & inrange(code_n, 235, 239))

	g tobacco_d = (code_l == "A" & inrange(code_n, 240, 242))
	
}

g cereals = cereals_d * GAS_TRI/ 3
g meat_dairy = (meat_fish_seafood_d + dairy_d) * GAS_TRI/ 3
g sugar_fat_drink = (oils_fats_d + sugar_d + soft_drink_d + desserts_d) * GAS_TRI/3
g vegg_fruit = vegg_fruit_d * GAS_TRI / 3
g coffe_spices_other = (coffe_d + specias_d + others_d) * GAS_TRI /3
g tobacco = tobacco_d * GAS_TRI/3
g outside_food = (takeout_d + outside_d) * GAS_TRI/3
g alcohol = alcohol_d * GAS_TRI /3

g packaged_food = packaged_food_d * GAS_TRI/3
g baby_food = baby_food_d * GAS_TRI/3
g pet_food = pet_food_d * GAS_TRI/3


* HEALTH

if `year' == 2002 {
	
	*2002
	g medical_outpatient_d = (code_l == "J" & (inrange(code_n, 01, 04)))
	g drugs_prescribed_d = (code_l =="J" & (inrange(code_n, 5, 23)))
	g medical_inpatient_d = (code_l == "J" & inrange(code_n, 26, 30))
	g drugs_overcounter_d = (code_l == "J" & inrange(code_n, 48, 65))
	g ortho_d = (code_l == "J" & inrange(code_n, 70, 75))
	g insurance_cost_d = (code_l == "J" & inrange(code_n, 76, 77))
	
	

}
else {

	g medical_outpatient_d = (code_l == "J" & (inrange(code_n, 16, 19) | code_n == 36))
	g drugs_prescribed_d = (code_l =="J" & (inrange(code_n, 20, 35) | inlist(code_n, 37, 38)))
	g medical_inpatient_d = (code_l == "J" & inrange(code_n, 39, 43))
	g drugs_overcounter_d = (code_l == "J" & inrange(code_n, 44, 59))
	g ortho_d = (code_l == "J" & inrange(code_n, 65, 69))
	g insurance_cost_d = (code_l == "J" & inrange(code_n, 70, 72))



}

	g medical_outpatient = medical_outpatient_d * GAS_TRI/3
	g drugs_prescribed = drugs_prescribed_d * GAS_TRI/3
	g medical_inpatient = medical_inpatient_d * GAS_TRI/3
	g drugs_overcounter = drugs_overcounter_d * GAS_TRI/3
	g ortho = ortho_d * GAS_TRI/3
	g insurance_cost = insurance_cost_d * GAS_TRI/3


}
collapse (sum) cereals meat_dairy sugar_fat_drink vegg_fruit coffe_spices_other ///
tobacco outside_food alcohol packaged_food baby_food pet_food ///
medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ortho ///
insurance_cost, by(FOLIO)

*EXPENDITURE/EROGACIONES (SAVINGS)
merge 1:m FOLIO using "$data/ENIGH/`year'/eroga.dta", ///
keepus(FOLIO CLAVE ERO_TRI)
ren (CLAVE ERO_TRI) (clave ero_tri)

 	gen code_l = substr(clave, 1,1)
	gen code_n = substr(clave, 2, 4)
	destring(code_n), replace force

if `year' == 2002 {
	
	*debits/savings
g savings_d = (code_l == "Q" & code_n  == 1)
*loans to others outside of home
g loans_d = (code_l == "Q" & code_n == 2)
*payment of credit cards, loans, interest, mortgage
g debt_d = (code_l =="Q" & (inrange(code_n, 3, 4) | code_n == 10))
g currency_d = (code_l == "Q" & code_n == 5)

}
	
else {
*debits/savings
g savings_d = (code_l == "Q" & code_n  == 1)
*loans to others outside of home
g loans_d = (code_l == "Q" & code_n == 2)
*payment of credit cards, loans, interest, mortgage
g debt_d = (code_l =="Q" & (inrange(code_n, 3, 5) | code_n == 11))
g currency_d = (code_l == "Q" & code_n == 6)
}	

g savings = savings_d * ero_tri/3
g loans = loans_d * ero_tri/3
g debt = debt_d * ero_tri/3
g currency = currency_d * ero_tri/3

collapse (mean) cereals meat_dairy sugar_fat_drink vegg_fruit coffe_spices_other ///
tobacco outside_food alcohol packaged_food baby_food pet_food ///
medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ortho ///
insurance_cost (sum) savings loans debt currency, by(FOLIO)


merge 1:1 FOLIO using "$data/ENIGH/`year'/concen.dta", keep(3) nogen ///
keepus(FOLIO ESTRATO UBICA_GEO HOMBRES MUJERES TOT_RESI HOG ///
GASMON INGMON EST_DIS UPM N_OCUP PERING MENORES)

*Education is only availble for head hh


if `year' == 2002 {

	*individuals 
	*only kept primary social security (first job)
	merge 1:m FOLIO using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
	keepus(FOLIO PARENTESCO SEXO EDAD EDO_CIVIL NUM_REN PRESTA1_01-PRESTA1_20 ///
	TRABAJO ED_TECNICA ED_FORMAL HRS_SEM BECA)
	ren (EDO_CIVIL HRS_SEM) (EDOCONY hrs_worked)  
	g progresa_benef_ind = (BECA == 5)
	decode TRABAJO, g(TRABAJO_s)
	decode PARENTESCO, g(PARENTESCO_s)
	decode EDOCONY, g(EDOCONY_s)
	
	forv i=1/9 {
	decode PRESTA1_0`i', g(PRESTA1_0`i'_s)    
	drop PRESTA1_0`i'
	destring(PRESTA1_0`i'_s), g(PRESTA1_0`i')
	drop PRESTA1_0`i'_s
	}
	forv i=10/20 {
	decode PRESTA1_`i', g(PRESTA1_`i'_s)    
	drop PRESTA1_`i'
	destring(PRESTA1_`i'_s), g(PRESTA1_`i')
	drop PRESTA1_`i'_s
	}
	
	drop PARENTESCO EDOCONY TRABAJO
	destring(PARENTESCO_s EDOCONY_s TRABAJO_s), g(PARENTESCO EDOCONY trab)
	g trabajo = int(trab/10000)
	replace trabajo = . if trab == 0
	drop PARENTESCO_s EDOCONY_s TRABAJO_s trab


	*technical or commercial who did finsh goes 1 attainment above, those who did 
	*not stay in the approved formal stage
		*education	
g educ_attainment = 1 * (ED_FORMAL == 1 | ED_TECNICA == 1) + ///
					2 * (ED_FORMAL == 2 | ED_TECNICA == 2) + ///					
					3 * (inrange(ED_FORMAL,3, 7)) + ///
					4 * (ED_FORMAL == 8 | ED_TECNICA ==3 | ED_TECNICA ==4) + ///
					5 * (inrange(ED_FORMAL,9, 10) ) + ///
					6 * ((ED_FORMAL == 11) | ED_TECNICA == 5 | ED_TECNICA == 6) + ///
					7 * (inrange(ED_FORMAL, 12, 17)) + ///
					8 * (inrange(ED_FORMAL, 18, 20) | ED_TECNICA == 7 | ED_TECNICA == 8) + ///
                    9 * (inrange(ED_FORMAL, 21, 30)) + ///
					10 * (ED_FORMAL == 31 | ED_TECNICA == 9) + ///
					11 * (inlist(ED_FORMAL, 32, 33))
						
    g hhh = (inlist(PARENTESCO, 10,11,12))


}

else if `year' == 2004  {

	merge 1:m FOLIO using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
	keepus(FOLIO PARENTESCO SEXO EDAD EDOCONY NUM_REN PRESTA1_01-PRESTA1_31 ///
	TRABAJO N_INSTR161 N_INSTR162 ANTEC_ESC HORASTRAB BECAS)
	ren HORASTRAB hrs_worked
	
	decode ANTEC_ESC, g(ANTEC_ESC_s)
	decode EDOCONY, g(EDOCONY_s)
	decode PARENTESCO, g(PARENTESCO_s)
	decode N_INSTR161, g(N_INSTR161_s)
	decode N_INSTR162, g(N_INSTR162_s)
	decode TRABAJO, g(TRABAJO_s)
	g progresa_benef_ind = (BECAS == 1)
	
	forv i=1/9 {
	decode PRESTA1_0`i', g(PRESTA1_0`i'_s)    
	drop PRESTA1_0`i'
	destring(PRESTA1_0`i'_s), g(PRESTA1_0`i')
	drop PRESTA1_0`i'_s
	}
	forv i=10/31 {
	decode PRESTA1_`i', g(PRESTA1_`i'_s)    
	drop PRESTA1_`i'
	destring(PRESTA1_`i'_s), g(PRESTA1_`i')
	drop PRESTA1_`i'_s
	}
	drop PARENTESCO EDOCONY N_INSTR161 N_INSTR162 TRABAJO ANTEC_ESC
	destring(PARENTESCO_s EDOCONY_s N_INSTR161_s N_INSTR162_s TRABAJO_s ANTEC_ESC_s), ///
	g(PARENTESCO EDOCONY nivelaprob gradoaprob trabajo antec_esc)
	drop PARENTESCO_s EDOCONY_s N_INSTR161_s N_INSTR162_s TRABAJO_s ANTEC_ESC_s
	
		*education	
g educ_attainment = 1 * (nivelaprob == 0) + ///
					2 * (nivelaprob == 1) + ///					
					3 * (nivelaprob == 2 & gradoaprob < 6) + ///
					4 * ((nivelaprob == 2 & gradoaprob == 6) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 1)) + ///
					5 * (nivelaprob == 3 & gradoaprob < 3 ) + ///
					6 * ((nivelaprob == 3 & gradoaprob == 3) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 2)) + ///
					7 * (nivelaprob == 4 & gradoaprob < 3) + ///
					8 * ((nivelaprob == 4 & gradoaprob  == 3) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 3)) + ///
                    9 * (nivelaprob == 7 & gradoaprob  < 4) + ///
					10 * ((nivelaprob == 7 & gradoaprob >= 4) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 4)) + ///
					11 * (inlist(nivelaprob, 8, 9) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 5))
	
	g hhh = (inlist(PARENTESCO, 1,100))
	
	
}

else {

	merge 1:m FOLIO using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
	keepus(FOLIO PARENTESCO SEXO EDAD EDOCONY NUM_REN PRESTA1_01-PRESTA1_20 ///
	TRABAJO N_INSTR161 N_INSTR162 ANTEC_ESC HORAS_TRAB BECA)
	
	ren HORAS_TRAB hrs_worked
	
	decode ANTEC_ESC, g(ANTEC_ESC_s)
	decode EDOCONY, g(EDOCONY_s)
	decode PARENTESCO, g(PARENTESCO_s)
	decode N_INSTR161, g(N_INSTR161_s)
	decode N_INSTR162, g(N_INSTR162_s)
	decode TRABAJO, g(TRABAJO_s)
	g progresa_benef_ind = (BECA == 1)
	
	forv i=1/9 {
	decode PRESTA1_0`i', g(PRESTA1_0`i'_s)    
	drop PRESTA1_0`i'
	destring(PRESTA1_0`i'_s), g(PRESTA1_0`i')
	drop PRESTA1_0`i'_s
	}
	forv i=10/20 {
	decode PRESTA1_`i', g(PRESTA1_`i'_s)    
	drop PRESTA1_`i'
	destring(PRESTA1_`i'_s), g(PRESTA1_`i')
	drop PRESTA1_`i'_s
	}
	
	drop PARENTESCO EDOCONY N_INSTR161 N_INSTR162 TRABAJO ANTEC_ESC
	destring(PARENTESCO_s EDOCONY_s N_INSTR161_s N_INSTR162_s TRABAJO_s ANTEC_ESC_s), ///
	g(PARENTESCO EDOCONY nivelaprob gradoaprob trabajo antec_esc)
	drop PARENTESCO_s EDOCONY_s N_INSTR161_s N_INSTR162_s TRABAJO_s ANTEC_ESC_s
	
		*education	
g educ_attainment = 1 * (nivelaprob == 0) + ///
					2 * (nivelaprob == 1) + ///					
					3 * (nivelaprob == 2 & gradoaprob < 6) + ///
					4 * ((nivelaprob == 2 & gradoaprob == 6) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 1)) + ///
					5 * (nivelaprob == 3 & gradoaprob < 3 ) + ///
					6 * ((nivelaprob == 3 & gradoaprob == 3) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 2)) + ///
					7 * (nivelaprob == 4 & gradoaprob < 3) + ///
					8 * ((nivelaprob == 4 & gradoaprob  == 3) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 3)) + ///
                    9 * (nivelaprob == 7 & gradoaprob  < 4) + ///
					10 * ((nivelaprob == 7 & gradoaprob >= 4) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 4)) + ///
					11 * (inlist(nivelaprob, 8, 9) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 5))
					
	g hhh = (inlist(PARENTESCO, 1,100))

}

g insurance = 0
g ss = 0
	
if `year' == 2002 {

	forv i = 1/9 {
	 replace insurance = (inrange(PRESTA1_0`i', 1, 5)) if insurance == 0
	 replace ss = (PRESTA1_0`i' == 9) if ss == 0
	}
	forv i = 11/20 {
	 replace insurance = (inrange(PRESTA1_`i', 1, 5)) if insurance == 0
	 replace ss = (PRESTA1_`i' == 9) if ss == 0
	}
	
}

else if `year' == 2004 {
	
 
	forv i = 1/9 {
		replace insurance = (inrange(PRESTA1_0`i', 1, 6)) if insurance == 0
		replace ss = (PRESTA1_0`i' == 9) if ss == 0
	}
	
		forv i = 10/31 {
		replace insurance = (inrange(PRESTA1_`i', 1, 6)) if insurance == 0
		replace ss = (PRESTA1_`i' == 9) if ss == 0
	}
}

else {
	forv i = 1/9 {
		replace insurance = (inrange(PRESTA1_0`i', 1, 6)) if insurance == 0
		replace ss = (PRESTA1_0`i' == 9) if ss == 0
	}
	
	forv i = 10/20 {
		replace insurance = (inrange(PRESTA1_`i', 1, 6)) if insurance == 0
		replace ss = (PRESTA1_`i' == 9) if ss == 0
	}

	

}


	merge 1:m FOLIO NUM_REN using "$data/ENIGH/`year'/ingresos.dta", ///
	keep(1 3) nogen keepus(CLAVE ING_TRI)
	sort FOLIO NUM_REN
	replace ING_TRI = 0 if ING_TRI == .
ren ING_TRI ing_tri
	
gen code_l = substr(CLAVE, 1,1)
gen code_n = substr(CLAVE, 2, 4)
destring(code_n), replace force

	
*earnings 
if `year' == 2002 {
	
*wages from main job
g wage_d = (code_l == "P" & (inrange(code_n, 1, 9) | inlist(code_n, 20, 22)))
*earnings from bussines
g indep_w_d = (code_l == "P"  & (inrange(code_n, 10, 18) | code_n == 23))
*earnings from property (capital) 
g capital_d = (code_l == "P" & (inlist(code_n, 19, 21) | inrange(code_n, 24, 36)))
*transfers
g transfer_d = (code_l == "P" & inrange(code_n, 37, 47))
*other income
g other_d = (code_l == "P" & code_n == 48)
*financial capital
g financial_d = (code_l == "P" & inrange(code_n, 49, 65))

*transfers

g pensions_d = (code_l == "P" & inrange(code_n, 37, 38))
g severance_d = (code_l == "P" & inrange(code_n, 39, 41))
*in 2000, donations and scholarships were together by government and non-government
*thus, that year the transfer can be overestimated mostly by the donatios from other families (family transfers). 
*it seems that most of this was under the non governmental, and thus associated with those becas_don_non_gob that year. 
g becas_don_non_gob_d = (code_l == "P" & inlist(code_n, 42, 44))
g becas_don_gob_d = (code_l == "P" & code_n == 43)
g family_trans_d = (code_l == "P" & code_n == 44)
*remittances / remesas
g remit_d = (code_l == "P" & code_n == 45)
g progresa_d = (code_l == "P" & code_n == 46)
g procampo_d = (code_l == "P" & code_n == 47)


g benef_gob_d = (code_l == "P" & code_n == 43)


gen benef_don_gob_ind_aux = becas_don_gob_d * (ing_tri / 3)
gen benef_don_non_gob_ind_aux = becas_don_non_gob_d * (ing_tri / 3)

bys FOLIO NUM_REN: egen benef_don_gob_ind = total(benef_don_gob_ind_aux)
bys FOLIO NUM_REN: egen benef_don_non_gob_ind = total(benef_don_non_gob_ind_aux)


gen benef_don_gob_hh_aux = becas_don_gob_d * (ing_tri / 3)
gen benef_don_non_gob_hh_aux = becas_don_non_gob_d * (ing_tri / 3)

bys FOLIO: egen benef_don_gob_hh = total(benef_don_gob_hh_aux)
bys FOLIO: egen benef_don_non_gob_hh = total(benef_don_non_gob_hh_aux)
}



else {
	    	
*wages from main job
g wage_d = (code_l == "P" & inrange(code_n, 1, 9))
*wages from cooperatives, societities/bussines and secondary jobs
g indep_w_d = (code_l == "P"  & (code_n == 17 | inrange(code_n, 19, 27) | inrange(code_n, 29, 37)))
*income from bussines (utilidadeS) and property (rent from capital) 
g capital_d = (code_l == "P" & (inrange(code_n, 10, 16) | inlist(code_n, 18, 28, 38) | inrange(code_n, 39, 47)))

*transfers
g transfer_d = (code_l == "P" & inrange(code_n, 48, 60))
*other income
g other_d = (code_l == "P" & code_n == 61)
*financial capital
g financial_d = (code_l == "P" & inrange(code_n, 62, 76))

*transfers
*there are national and foreign pensions
g pensions_d = (code_l == "P" & inrange(code_n, 48, 49))
g severance_d = (code_l == "P" & inrange(code_n, 50, 52))
g becas_d = (code_l == "P" & inlist(code_n == 53, 54))
g donation_non_gob_d = (code_l == "P" & code_n == 55)
g donation_gob_d = (code_l == "P" & code_n == 56)
g family_trans_d = (code_l == "P" & code_n == 57)
g remit_d = (code_l == "P" & code_n == 58)
g progresa_d = (code_l == "P" & code_n == 59)
g procampo_d = (code_l == "P" & code_n == 60)

*in 2004 and 2005, the government benefits were separate by scholarship and
*donation
g benef_gob_d = (code_l == "P" & code_n== 56)

*just for completio porpuses
g becas_don_gob_d = 0
g becas_don_non_gob_d = 0
gen benef_don_gob_ind_aux = 0 
gen benef_don_non_gob_ind_aux = 0

gen benef_don_gob_ind = 0
gen benef_don_non_gob_ind = 0


gen benef_don_gob_hh_aux = 0
gen benef_don_non_gob_hh_aux = 0


gen benef_don_gob_hh = 0
gen benef_don_non_gob_hh = 0
}

* becas_go donation_gob_d

g wage_ind_aux = wage_d * (ing_tri / 3)  
g indep_w_ind_aux = indep_w_d * (ing_tri / 3) 
gen capital_ind_aux = capital_d * (ing_tri / 3) 
gen transfer_ind_aux = transfer_d * (ing_tri / 3)
gen other_inc_ind_aux = other_d * (ing_tri / 3) 
gen financial_ind_aux = financial_d * (ing_tri / 3)
gen benef_gob_ind_aux = benef_gob_d * (ing_tri / 3)
gen progresa_ind_aux = progresa_d * (ing_tri / 3)
gen remit_ind_aux = remit_d * (ing_tri / 3)
gen family_trans_ind_aux = family_trans_d * (ing_tri / 3)



bys FOLIO NUM_REN: egen wage_ind = total(wage_ind_aux)
bys FOLIO NUM_REN: egen indep_w_ind = total(indep_w_ind_aux)
bys FOLIO NUM_REN: egen capital_ind = total(capital_ind_aux)
bys FOLIO NUM_REN: egen transfer_ind = total(transfer_ind_aux)
bys FOLIO NUM_REN: egen other_inc_ind = total(other_inc_ind_aux)
bys FOLIO NUM_REN: egen financial_ind = total(financial_ind_aux)
bys FOLIO NUM_REN: egen benef_gob_ind = total(benef_gob_ind_aux)
bys FOLIO NUM_REN: egen progresa_ind = total(progresa_ind_aux)
bys FOLIO NUM_REN: egen remit_ind = total(remit_ind_aux)
bys FOLIO NUM_REN: egen family_trans_ind = total(family_trans_ind_aux)




g wage_hh_aux = wage_d * (ing_tri / 3)  
g indep_w_hh_aux = indep_w_d * (ing_tri / 3) 
g capital_hh_aux = capital_d * (ing_tri / 3) 
g transfer_hh_aux = transfer_d * (ing_tri / 3)
g other_inc_hh_aux = other_d * (ing_tri / 3) 
g financial_hh_aux = financial_d * (ing_tri / 3)
g benef_gob_hh_aux = benef_gob_d * (ing_tri / 3)
g progresa_hh_aux = progresa_d * (ing_tri / 3)
gen remit_hh_aux = remit_d * (ing_tri / 3)
gen family_trans_hh_aux = family_trans_d * (ing_tri / 3)


bys FOLIO: egen wage_hh = total(wage_hh_aux)
bys FOLIO: egen indep_w_hh = total(indep_w_hh_aux)
bys FOLIO: egen capital_hh = total(capital_hh_aux)
bys FOLIO: egen transfer_hh = total(transfer_hh_aux)
bys FOLIO: egen other_inc_hh = total(other_inc_hh_aux)
bys FOLIO: egen financial_hh = total(financial_hh_aux)
bys FOLIO: egen benef_gob_hh = total(benef_gob_hh_aux)
bys FOLIO: egen progresa_hh = total(progresa_hh_aux)
bys FOLIO: egen remit_hh = total(remit_hh_aux)
bys FOLIO: egen family_trans_hh = total(family_trans_hh_aux)


drop *_aux
drop financial_d other_d transfer_d capital_d indep_w_d wage_d ///
pensions_d severance_d becas_don_non_gob_d becas_don_gob_d ///
family_trans_d remit_d progresa_d procampo_d  benef_gob_d family_trans_d remit_d
bys FOLIO NUM_REN: keep if _n == 1

	g hhh_insured_aux = insurance * hhh
	g hhh_ss_aux = ss * hhh
	g hhh_age_aux = EDAD  * hhh
	g hhh_female_aux = (SEXO == 2) * hhh
	g hhh_ever_married_aux = (inrange(EDOCONY, 2, 5)) * hhh
	
bys FOLIO: egen progresa_benef_hh = max(progresa_benef_ind)

g hhh_educ_aux = educ_attainment * hhh 
/*
decode BECA, g(BECA_s)
destring(BECA_s), g(beca)
g prog = (beca == 5)
bys FOLIO: egen progresa = max(prog)
*/
bys FOLIO: egen hhh_educ = max(hhh_educ_aux)
bys FOLIO: egen hhh_age = max(hhh_age_aux)
bys FOLIO: egen hhh_female = max(hhh_female_aux)
bys FOLIO: egen hhh_ever_married = max(hhh_ever_married_aux)
bys FOLIO: egen hhh_insured = max(hhh_insured_aux)
bys FOLIO: egen hhh_ss = max(hhh_ss_aux)


*I am keeping HH with individuals above 59, with the HH spending
keep if EDAD > 64
bys FOLIO: egen any_old_insured = max(insurance)
bys FOLIO: egen any_old_ss = max(ss)
bys FOLIO: egen max_age = max(EDAD)
bys FOLIO: egen max_age_female_aux = max(EDAD) if SEXO == 2
bys FOLIO: egen max_age_female = max(max_age_female_aux) 
bys FOLIO: egen max_age_male_aux = max(EDAD) if SEXO == 1
bys FOLIO: egen max_age_male = max(max_age_male_aux) 

ren EDAD age
g female = (SEXO == 2)
keep FOLIO EST_DIS UPM HOG ESTRATO HOMBRES MUJERES TOT_RESI INGMON ///
GASMON UBICA_GEO cereals meat_dairy sugar_fat_drink vegg_fruit female ///
coffe_spices_other tobacco outside_food alcohol packaged_food baby_food ///
pet_food N_OCUP PERING MENORES hhh_insured hhh_ever_married ///
hhh_female hhh_age max_age max_age_female max_age_male any_old_insured ///
hhh_ss any_old_ss ss insurance age remit_* family_trans_* ///
wage_* indep_w_* capital_* transfer_* other_inc_* financial_* benef_* progresa* ///
trabajo hhh_educ educ_attainment hrs_worked hhh medical_outpatient ///
drugs_prescribed medical_inpatient drugs_overcounter ///
ortho insurance_cost savings loans debt currency


decode ESTRATO, g(estrato_s)
decode UBICA_GEO, g(ubica_geo)
decode EST_DIS, g(est_dis)
destring(estrato_s), g(estrato)
ren FOLIO folio
drop UBICA_GEO ESTRATO EST_DIS estrato_s 

*hh_id hh_member strata upm fact_exp loc_size cve_ent_mun n_males n_females n_total 
*female age income spending 

g year = `year'




// Loop over each variable in the dataset
	foreach var of varlist _all {
		// Rename each variable to its uppercase version
		rename `var' `=lower("`var'")'
	}

save "$data/ENIGH/enigh_`year'", replace

}


global years = "2006"
foreach year in $years {
*local year = 2006
/*
*household
use $data/ENIGH/`year'/hogares.dta, clear
keep FOLIO CONAPO

CONAPO classification is not available for 2005
*household - consolidate
*/


*expenditure / spending
{
use  "$data/ENIGH/`year'/gastos.dta", clear
keep folio clave costo dia precio gasto cantidad gas_tri pago_mp
*It seems I should focus in GASTO only

gen code_l = substr(clave, 1,1)
gen code_n = substr(clave, 2, 4)
destring(code_n), replace force

g cereals_d = (code_l == "A" & inrange(code_n, 1, 24))
*meat fish shelfish
g meat_fish_seafood_d = (code_l == "A" & inrange(code_n, 25, 74))

*eggs and milk
g dairy_d = (code_l == "A" & inrange(code_n, 75, 94))
		   
g oils_fats_d = (code_l == "A" & inrange(code_n, 95, 100)) 
g vegg_fruit_d = (code_l == "A" & inrange(code_n, 101, 172)) 

g sugar_d = (code_l == "A" & inrange(code_n, 173, 175)) 

g coffe_d = (code_l == "A" & inrange(code_n, 176, 182)) 
g specias_d = (code_l == "A" & inrange(code_n, 183, 194))

g baby_food_d = (code_l == "A" & inrange(code_n, 195, 197))

*prepared food for house intake
g takeout_d = (code_l == "A" & inrange(code_n, 198, 202))
*alimentos diversos
g food_diverse = (code_l == "A" & inrange(code_n, 203, 204))
*desserts/pastries
g desserts_d = (code_l == "A" & inrange(code_n, 205, 209))
*spending related to food elaboration and diverse food
g others_d = (code_l == "A" & inrange(code_n, 210, 211))

g packaged_food_d = inlist(clave, "A212", "A242")

g pet_food_d = (code_l == "A" & inrange(code_n, 213, 214))

g soft_drink_d = (code_l == "A" & inrange(code_n, 215, 222))

g alcohol_d = (code_l == "A" & inrange(code_n, 223, 238))
*food ate outside
g outside_d = (code_l == "A" & inrange(code_n, 243, 247))

g tobacco_d = (code_l == "A" & inrange(code_n, 239, 241))

* HEALTH
g medical_outpatient_d = (code_l == "J" & (inrange(code_n, 16, 19) | code_n == 36))
g drugs_prescribed_d = (code_l =="J" & (inrange(code_n, 20, 35) | inlist(code_n, 37, 38)))
g medical_inpatient_d = (code_l == "J" & inrange(code_n, 39, 43))
g drugs_overcounter_d = (code_l == "J" & inrange(code_n, 44, 59))
g ortho_d = (code_l == "J" & inrange(code_n, 65, 69))
g insurance_cost_d = (code_l == "J" & inrange(code_n, 70, 72))

g cereals = cereals_d * gas_tri/ 3
g meat_dairy = (meat_fish_seafood_d + dairy_d) * gas_tri/ 3
g sugar_fat_drink = (oils_fats_d + sugar_d + soft_drink_d + desserts_d) * gas_tri/3
g vegg_fruit = vegg_fruit_d * gas_tri / 3
g coffe_spices_other = (coffe_d + specias_d + others_d) * gas_tri /3
g tobacco = tobacco_d * gas_tri/3
g outside_food = (takeout_d + outside_d) * gas_tri/3
g alcohol = alcohol_d * gas_tri /3

g packaged_food = packaged_food_d * gas_tri/3
g baby_food = baby_food_d * gas_tri/3
g pet_food = pet_food_d * gas_tri/3

g medical_outpatient = medical_outpatient_d * gas_tri/3
g drugs_prescribed = drugs_prescribed_d * gas_tri/3
g medical_inpatient = medical_inpatient_d * gas_tri/3
g drugs_overcounter = drugs_overcounter_d * gas_tri/3
g ortho = ortho_d * gas_tri/3
g insurance_cost = insurance_cost_d * gas_tri/3

 
}
collapse (sum) cereals meat_dairy sugar_fat_drink vegg_fruit coffe_spices_other ///
tobacco outside_food alcohol packaged_food baby_food pet_food ///
medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ortho ///
insurance_cost, by(folio)


*EXPENDITURE/EROGACIONES (SAVINGS)
merge 1:m folio using "$data/ENIGH/`year'/eroga.dta", ///
keepus(clave ero_tri)

 	gen code_l = substr(clave, 1,1)
	gen code_n = substr(clave, 2, 4)
	destring(code_n), replace force

*debits/savings
g savings_d = (code_l == "Q" & code_n  == 1)
*loans to others outside of home
g loans_d = (code_l == "Q" & code_n == 2)
*payment of credit cards, loans, interest, mortgage
g debt_d = (code_l =="Q" & (inrange(code_n, 3, 5) | code_n == 11))
g currency_d = (code_l == "Q" & code_n == 6)


g savings = savings_d * ero_tri/3
g loans = loans_d * ero_tri/3
g debt = debt_d * ero_tri/3
g currency = currency_d * ero_tri/3

collapse (mean) cereals meat_dairy sugar_fat_drink vegg_fruit coffe_spices_other ///
tobacco outside_food alcohol packaged_food baby_food pet_food ///
medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ortho ///
insurance_cost (sum) savings loans debt currency, by(folio)


merge 1:1 folio using "$data/ENIGH/`year'/concen.dta", ///
keepus(folio estrato ubica_geo hombres mujeres tot_resi hog ///
ingmon gasmon est_dis upm n_ocup pering menores)




merge 1:m folio using "$data/ENIGH/`year'/pob.dta", keep(3) nogen ///
keepus(folio parentesco sexo edad edocony presta1_01-presta1_20 afiliacion num_ren ///
trabajo horas_trab n_instr141 n_instr142 antec_esc horas_trab beca) 
*sueldo08 sueldo019
ren (afiliacion n_instr141 n_instr142 horas_trab) ///
(segpop nivelaprob gradoaprob hrs_worked) 
destring(sexo parentesco edocony presta1_01-presta1_20 segpop trabajo nivelaprob ///
gradoaprob antec_esc hrs_worked), replace

destring(beca), g(becas)
g progresa_benef_ind = (becas == 1)
	merge 1:m folio num_ren using "$data/ENIGH/`year'/ingresos.dta", ///
	keep(1 3) nogen keepus(clave ing_tri)
	sort folio num_ren
	replace ing_tri = 0 if ing_tri == .

	gen code_l = substr(clave, 1,1)
	gen code_n = substr(clave, 2, 4)
	destring(code_n), replace force

	
	
*earnings 
{
	    
	
*wages from main job
g wage_d = (code_l == "P" & inrange(code_n, 1, 9))
*wages from cooperatives, societities/bussines and secondary jobs
g indep_w_d = (code_l == "P"  & (code_n == 17 | inrange(code_n, 19, 27) | inrange(code_n, 29, 37)))
*income from bussines (utilidadeS) and property (rent from capital) 
g capital_d = (code_l == "P" & (inrange(code_n, 10, 16) | inlist(code_n, 18, 28, 38) | inrange(code_n, 39, 47)))

*transfers
g transfer_d = (code_l == "P" & inrange(code_n, 48, 60))
*other income
g other_d = (code_l == "P" & code_n == 61)
*financial capital
g financial_d = (code_l == "P" & inrange(code_n, 62, 76))

*transfers
*there are national and foreign pensions
g pensions_d = (code_l == "P" & inrange(code_n, 48, 49))
g severance_d = (code_l == "P" & inrange(code_n, 50, 52))
g becas_d = (code_l == "P" & inlist(code_n == 53, 54))
g donation_non_gob_d = (code_l == "P" & code_n == 55)
g donation_gob_d = (code_l == "P" & code_n == 56)
g family_trans_d = (code_l == "P" & code_n == 57)
g remit_d = (code_l == "P" & code_n == 58)
g progresa_d = (code_l == "P" & code_n == 59)
g procampo_d = (code_l == "P" & code_n == 60)
g benef_don_gob_d = 0
g benef_don_non_gob_d = 0

*in 2004 and 2005, the government benefits were separate by scholarship and
*donation
g benef_gob_d = (code_l == "P" & code_n== 56)

g wage_ind_aux = wage_d * (ing_tri / 3)  
g indep_w_ind_aux = indep_w_d * (ing_tri / 3) 
gen capital_ind_aux = capital_d * (ing_tri / 3) 
gen transfer_ind_aux = transfer_d * (ing_tri / 3)
gen other_inc_ind_aux = other_d * (ing_tri / 3) 
gen financial_ind_aux = financial_d * (ing_tri / 3)
gen benef_gob_ind_aux = benef_gob_d * (ing_tri / 3)
gen progresa_ind_aux = progresa_d * (ing_tri / 3)
gen remit_ind_aux = remit_d * (ing_tri / 3)
gen family_trans_ind_aux = family_trans_d * (ing_tri / 3)
gen benef_don_gob_ind_aux = 0
gen benef_don_non_gob_ind_aux = 0


bys folio num_ren: egen wage_ind = total(wage_ind_aux)
bys folio num_ren: egen indep_w_ind = total(indep_w_ind_aux)
bys folio num_ren: egen capital_ind = total(capital_ind_aux)
bys folio num_ren: egen transfer_ind = total(transfer_ind_aux)
bys folio num_ren: egen other_inc_ind = total(other_inc_ind_aux)
bys folio num_ren: egen financial_ind = total(financial_ind_aux)
bys folio num_ren: egen benef_gob_ind = total(benef_gob_ind_aux)
bys folio num_ren: egen progresa_ind = total(progresa_ind_aux)
bys folio num_ren: egen remit_ind = total(remit_ind_aux)
bys folio num_ren: egen family_trans_ind = total(family_trans_ind_aux)
gen benef_don_gob_ind = 0
gen benef_don_non_gob_ind = 0


g wage_hh_aux = wage_d * (ing_tri / 3)  
g indep_w_hh_aux = indep_w_d * (ing_tri / 3) 
g capital_hh_aux = capital_d * (ing_tri / 3) 
g transfer_hh_aux = transfer_d * (ing_tri / 3)
g other_inc_hh_aux = other_d * (ing_tri / 3) 
g financial_hh_aux = financial_d * (ing_tri / 3)
g benef_gob_hh_aux = benef_gob_d * (ing_tri / 3)
g progresa_hh_aux = progresa_d * (ing_tri / 3)
gen remit_hh_aux = remit_d * (ing_tri / 3)
gen family_trans_hh_aux = family_trans_d * (ing_tri / 3)
gen benef_don_gob_hh_aux = 0
gen benef_don_non_gob_hh_aux = 0


bys folio: egen wage_hh = total(wage_hh_aux)
bys folio: egen indep_w_hh = total(indep_w_hh_aux)
bys folio: egen capital_hh = total(capital_hh_aux)
bys folio: egen transfer_hh = total(transfer_hh_aux)
bys folio: egen other_inc_hh = total(other_inc_hh_aux)
bys folio: egen financial_hh = total(financial_hh_aux)
bys folio: egen benef_gob_hh = total(benef_gob_hh_aux)
bys folio: egen progresa_hh = total(progresa_hh_aux)
bys folio: egen remit_hh = total(remit_hh_aux)
bys folio: egen family_trans_hh = total(family_trans_hh_aux)
gen benef_don_gob_hh = 0
gen benef_don_non_gob_hh = 0


drop *_aux
drop financial_d other_d transfer_d capital_d indep_w_d wage_d ///
pensions_d severance_d becas_d  donation_non_gob_d donation_gob_d ///
family_trans_d remit_d progresa_d procampo_d benef_gob_d remit_d family_trans_d

bys folio num_ren: keep if _n == 1
}


g insurance = 0
g ss = 0
forv i = 1/9 {
		replace insurance = (inrange(presta1_0`i', 1, 6)) if insurance == 0
		replace ss = (presta1_0`i' == 9) if ss == 0
	}
	
forv i = 10/20 {
		replace insurance = (inrange(presta1_`i', 1, 6)) if insurance == 0
		replace ss = (presta1_`i' == 9) if ss == 0
	}

g sp = (segpop == 1)
g hhh = (inlist(parentesco, 1,100))

g hhh_age_aux = edad  * hhh
g hhh_female_aux = (sexo == 2) * hhh
g hhh_ever_married_aux = (inrange(edocony,2,5)) * hhh


g hhh_insured_aux = insurance * hhh
g hhh_ss_aux = ss * hhh
g hhh_sp_aux = sp * hhh

*education	
g educ_attainment = 1 * (nivelaprob == 0) + ///
					2 * (nivelaprob == 1) + ///					
					3 * (nivelaprob == 2 & gradoaprob < 6) + ///
					4 * ((nivelaprob == 2 & gradoaprob == 6) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 1)) + ///
					5 * (nivelaprob == 3 & gradoaprob < 3 ) + ///
					6 * ((nivelaprob == 3 & gradoaprob == 3) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 2)) + ///
					7 * (nivelaprob == 4 & gradoaprob < 3) + ///
					8 * ((nivelaprob == 4 & gradoaprob  == 3) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 3)) + ///
                    9 * (nivelaprob == 7 & gradoaprob  < 4) + ///
					10 * ((nivelaprob == 7 & gradoaprob >= 4) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 4)) + ///
					11 * (inlist(nivelaprob, 8, 9) | ///
					(inlist(nivelaprob, 5, 6) & antec_esc == 5))

g hhh_educ_aux = educ_attainment * hhh 

bys folio: egen hhh_age = max(hhh_age_aux)
bys folio: egen hhh_female = max(hhh_female_aux)
bys folio: egen hhh_ever_married = max(hhh_ever_married_aux)
bys folio: egen hhh_insured = max(hhh_insured_aux)
bys folio: egen hhh_ss = max(hhh_ss_aux)
bys folio: egen hhh_sp = max(hhh_sp_aux)
bys folio: egen hhh_educ = max(hhh_educ_aux)
bys folio: egen progresa_benef_hh = max(progresa_benef_ind)

*I am keeping HH with individuals above 59, with the HH spending
keep if edad > 64
bys folio: egen any_old_insured = max(insurance)
bys folio: egen any_old_ss = max(ss)
bys folio: egen any_old_sp = max(sp)
bys folio: egen max_age = max(edad)
bys folio: egen max_age_female_aux = max(edad) if sexo == 2
bys folio: egen max_age_female = min(max_age_female_aux)
bys folio: egen max_age_male_aux = max(edad) if sexo == 1
bys folio: egen max_age_male = min(max_age_male_aux) 


ren edad age
g female = (sexo == 2)
keep folio est_dis upm hog estrato hombres mujeres tot_resi female ///
ingmon gasmon ubica_geo cereals meat_dairy sugar_fat_drink vegg_fruit ///
coffe_spices_other tobacco outside_food alcohol packaged_food baby_food ///
pet_food n_ocup pering menores hhh_insured hhh_ever_married ///
hhh_female hhh_age max_age max_age_female max_age_male any_old_insured remit_* ///
any_old_ss hhh_ss hhh_sp sp ss any_old_sp insurance family_trans_* ///
wage_* indep_w_* capital_* transfer_* other_inc_* financial_* benef_* progresa* age ///
trabajo medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ///
ortho insurance_cost hrs_worked hhh educ_attainment hhh_educ savings loans debt currency

g year = `year'

*
destring(estrato upm pering menores), replace

save "$data/ENIGH/enigh_`year'", replace

}


use "$data/ENIGH/enigh_1992", clear

append using  "$data/ENIGH/enigh_1994"
append using  "$data/ENIGH/enigh_1996"
append using  "$data/ENIGH/enigh_1998"
append using  "$data/ENIGH/enigh_2000"
append using  "$data/ENIGH/enigh_2002"
append using  "$data/ENIGH/enigh_2004"
append using  "$data/ENIGH/enigh_2005"
append using  "$data/ENIGH/enigh_2006"

g id = _n

g employed  = (trabajo == 1)
ren (folio ubica_geo estrato  hog  tot_resi hombres mujeres menores n_ocup ///
pering) ///
(hh_id cve_ent_mun loc_size exp_factor n_hh n_females n_males ///
n_less_12 n_employed n_income)


g cve_ent = substr(cve_ent_mun, 1,2)
g cve_mun = substr(cve_ent_mun, 3,5)


order hh_id id year cve_ent_mun loc_size exp_factor est_dis upm n_hh n_females ///
n_males n_less_12 n_employed n_income hhh_* ///
any_old_ss hhh_ss 

/*I used the individual transfers from donations and governmental instituions between 1998 and 2000 to proxy the progresa beneficiarys
by using the share of the progresa transfer identified in 2002 as the total of government and non government institutions. Most of the
non-government tranfers were from families as shown in 2002. 
*/

sum benef_don_non_gob_ind if year == 2002
local m_benef_non_gob = `r(mean)' 
sum benef_don_gob_ind  if year == 2002
local m_benef_gob = `r(mean)'
sum progresa_ind if year == 2002
local m_progresa = `r(mean)'

local share_2002 = `m_progresa'/(`m_progresa' + `m_benef_gob' + `m_benef_non_gob')
replace progresa_ind = (benef_don_non_gob_ind + benef_don_gob_ind) * `share_2002' if inlist(year, 1998, 2000)

*household
sum benef_don_non_gob_hh if year == 2002
local m_benef_non_gob = `r(mean)' 
sum benef_don_gob_hh  if year == 2002
local m_benef_gob = `r(mean)'
sum progresa_hh if year == 2002
local m_progresa = `r(mean)'

local share_2002 = `m_progresa'/(`m_progresa' + `m_benef_gob' + `m_benef_non_gob')
replace progresa_hh = (benef_don_non_gob_hh + benef_don_gob_hh) * `share_2002' if inlist(year, 1998, 2000)
table year, stat(mean benef_don_non_gob_ind) stat(mean benef_don_gob_ind) stat(mean progresa_ind) stat(mean progresa_hh)
    
bys year: sum progresa_ind, d
/*
g s_prog_ind_aux = progresa_ind/ (benef_don_non_gob_ind + benef_don_gob_ind + progresa_ind) if year == 2002
bys cve_ent_mun: egen s_prog_ind_aux_mun = mean(s_prog_ind_aux)
egen s_prog_ind_aux_2002 = mean(s_prog_ind_aux)

*first assigned the average 2002 municipality level share of progresa to benefits
g s_prog_ind = s_prog_ind_aux_mun 
*second if not available, use the 2002 average.
replace s_prog_ind = s_prog_ind_aux_2002 if s_prog_ind_aux_mun == .
*it seems it only applies for 50

*egen s_prog_ind = min(s_prog_ind_aux2)


g s_prog_hh_aux = progresa_hh/ (benef_don_non_gob_hh + benef_don_gob_hh + progresa_hh) if year == 2002
bys cve_ent_mun: egen s_prog_hh_aux_mun = mean(s_prog_hh_aux)
egen s_prog_hh_aux_2002 = mean(s_prog_hh_aux)

*first assigned the average 2002 municipality level share of progresa to benefits
g s_prog_hh = s_prog_hh_aux_mun 
*second if not available, use the 2002 average.
replace s_prog_hh = s_prog_hh_aux_2002 if s_prog_hh_aux_mun == .
*it seems it only applies for 50

*egen s_prog_hh = min(s_prog_hh_aux2)

replace s_prog_ind = 0  if s_prog_ind == .
replace s_prog_hh = 0  if s_prog_hh == .

g progresa_ind2 = progresa_ind
replace progresa_ind2 = (benef_don_non_gob_ind + benef_don_gob_ind) * s_prog_ind if inlist(year, 1998, 2000)
g progresa_hh2 = progresa_hh
replace progresa_hh2 = (benef_don_non_gob_hh + benef_don_gob_hh) * s_prog_hh if inlist(year, 1998, 2000)

*
table year, stat(mean benef_don_non_gob_ind) stat(mean benef_don_gob_ind) stat(mean progresa_ind) stat(mean progresa_hh)
* 
br cve_ent_mun year id progresa_ind progresa_ind2 s_prog_ind s_prog_ind_aux s_prog_ind_aux_mun s_prog_ind_aux_2002 benef_don_gob_ind benef_don_non_gob_ind  if inrange(year, 1998, 2002)
*sum s_prog_ind s_prog_ind_aux1 s_prog_ind_aux2

drop progresa_ind progresa_hh
ren (progresa_ind2 progresa_hh2) (progresa_ind progresa_hh)
*/
					
label define educ_attainment_lbl ///
1 "No education" ///
2 "Pre-school" ///
3 "Elementary incomplete" ///
4 "Elementary complete" ///
5 "Junior high incomplete" ///
6 "Junior high complete" ///
7 "High school incomplete" ///
8 "High school complete" ///
9 "College incomplete" ///
10 "College complete" ///
11 "Grad school"




*Total Household Expenditures" includes expenditures on food, rent, utilities,
*appliances, health care, clothing, transportation, and other items (recreation, education).
*Total Household Income" includes income
*from all sources (earnings, private and government transfers).

**Income including "rent", but excluding financial capital 
*this is the recalculation of the income from the components excluding financial					

*hh_income_mon = trabajo, negocio, otros_trab, rentas, transfer y otros de esta tabla.
*hh_income_mon = wages + indep_w + other_w + capital + transfer + other
local tri = 3
*total income and expenditure are trimestral
*This is the total income from survey calculations excluding financial capital

g hh_income_mxn_tot = (ingmon  / `tri') 
replace hh_income_mxn_tot = hh_income_mxn_tot / 1000 if year == 1992

egen income_ind_mxn_tot = rowtotal(wage_ind indep_w_ind capital_ind ///
							transfer_ind other_inc_ind)
							
*egen income_ind_mxn_tot = rowtotal(wage_ind indep_w_ind other_w_ind capital_ind ///
*							transfer_ind other_inc_ind)
local tri = 3
g hh_expenditure_mxn_tot = (gasmon / `tri')
replace hh_expenditure_mxn_tot = hh_expenditure_mxn_tot / 1000 if year == 1992


sort year hh_id id


*excluding those from capital gains such as rent and other physical capital				
*and excluding financial capital and transfers
* EARNINGS
egen hh_earnings_mxn = rowtotal(wage_hh indep_w_hh)
*egen hh_earnings_mxn = rowtotal(wage_hh indep_w_hh other_w_hh)

*egen earnings_ind_mxn = rowtotal(wage_ind indep_w_ind other_w_ind)
egen earnings_ind_mxn = rowtotal(wage_ind indep_w_ind)

order hh_id id year 
label var hh_id "household id"
label var id "individual id"
label var year "survey year"
label var cve_ent_mun "state and mun id"
label var cve_ent "state id"
label var cve_mun "mun id"
label var loc_size "locality size"
label define loc_size_lbl 1 "pop>100k" 2 "15k<=pop<100k" 3 "2.5k<=pop<15k" 4 "pop<2.5k"
label value loc_size loc_size_lbl 
label var hrs_worked "hours worked in a week"
label var hhh "household head (=1)"
label var progresa_benef_ind "progresa beneficiary individual (=1)"
label var progresa_benef_hh "progresa beneficiary household (=1)"
label value educ_attainment educ_attainment_lbl
label value hhh_educ educ_attainment_lbl

label var exp_fact "expansion factor"
label var est_dis "strata"
label var upm "primary sample unit"
label var n_hh "number of members in hh"
label var n_females "number of females in hh"
label var n_males "number of males in hh"
label var max_age "max age in hh" 
label var max_age_female "max age for female in hh" 
label var max_age_male "max age for male in hh" 
label var n_less_12 "number of members in hh less than 12"
label var n_employed "number of males in hh employed"
label var n_income "number of people in hh receiving income"
*label var n_wage "number of people in hh receiving wage"
label var hhh_educ "hh head education"
label var hhh_age "hh head age"
label var hhh_female "hh head sex"
label var hhh_ever_married "hh head civil status"
label var hhh_insured "hh head insurance" 
label var hhh_ss "hh head in social security"
label define hhh_insured 0 "not insured" 1 "insured"
label value hhh_insured insurance_lbl
label define hhh_ss 0 "not ss" 1 "with ss"
label value hhh_ss ss_lbl
label var cereals "hh spend in grains, starches and cereals ($USD 2025)"
label var meat_dairy "hh spend in meat and dairy ($USD 2025)"
label var sugar_fat_drink "hh spend in sugars, fats and soft drinks ($USD 2025)"
label var vegg_fruit "hh spend in fruits and vegetables ($USD 2025)"
label var coffe_spices_other "hh spend in coffe, spices, and others ($USD 2025)"
label var tobacco "hh spend in cigarretes ($USD 2025)"
label var alcohol "hh spend in alcohol drinks ($USD 2025)"
label var outside_food "hh spend in food ate outside ($USD 2025)"
label var packaged_food "hh spend in packaged food ($USD 2025)"
label var baby_food "hh spend in baby food ($USD 2025)"
label var pet_food "hh spend in pet_food drinks ($USD 2025)"
label var any_old_insured "any HH member above 59 insurance"
label var any_old_sp "any HH member above 59 with seguro popular"
label var any_old_ss "any HH member above 59 with social security"
label var ss "has social security contributions (=1)"
label var sp "has seguro popular (=1)"
label var insurance "has health insurance (=1)"
label var earnings_ind_mxn "individual earnings (monthly - tri/3)"
label var income_ind_mxn_tot "individual income (monthly - tri/3) includes capital (mimics survey)"
label var hh_earnings_mxn "hh earnings (monthly - tri/3) excludes capital"
label var hh_income_mxn_tot "hh income (monthly - tri/3) total from survey"
label var hh_expenditure_mxn "expenditure (monthly - tri/3) in hh"

label var wage_hh "hh income from wages of main job ($USD 2025)"
label var indep_w_hh "hh income from independent bussines ($USD 2025)"
*label var other_w_hh "hh income from wages of other jobs ($USD 2025)" 

label var capital_hh "hh income from rent ($USD 2025)"
label var transfer_hh "hh income from transfers ($USD 2025)"
label var progresa_hh "hh progresa transfers ($USD 2025)"
label var benef_don_gob_hh "hh benefits from don and gob ($USD 2025)"
label var benef_don_non_gob_hh "hh benefits from don and non-gob ($USD 2025)"
*label var other_inc_hh "hh income from other sources ($USD 2025)"
label var financial_hh "hh income from financial sources ($USD 2025)"

label var wage_ind "individual income from wages of main job ($USD 2025)"
label var indep_w_ind "individual income from independent bussines ($USD 2025)"
*label var other_w_ind "individual income from wages of other jobs ($USD 2025)" 
label var benef_don_gob_ind "individual benefits from don and gob ($USD 2025)"
label var benef_don_non_gob_ind "individual benefits from don and non-gob ($USD 2025)"
label var capital_ind "individual income from rent ($USD 2025)"
label var transfer_ind "individual income from transfers ($USD 2025)"
label var other_inc_ind "individual income from other sources ($USD 2025)"
label var financial_ind "individual income from financial sources ($USD 2025)"
label var progresa_ind "individual progresa transfer ($USD 2025)"

label var medical_outpatient "hh spending on medical outpatient ($USD 2025)"
label var drugs_prescribed "hh spending prescribed drugs ($USD 2025)"
label var medical_inpatient "hh spending on medical inpatient ($USD 2025)"
label var drugs_overcounter "hh spending on over the counter drugs ($USD 2025)"
label var ortho "hh spending on orthopedics and glasses ($USD 2025)"
label var insurance_cost "hh spending in costs from insurance ($USD 2025)"

label var savings "hh expenditure in savings ($USD 2025)"
label var debt "hh expenditure in paying debt ($USD 2025)"
label var loans "hh expenditure in giving loans ($USD 2025)"
label var currency "hh expenditure in currencies ($USD 2025)"




			 
bys year hh_id: g hh_unique = (_n == 1)


global years = "2002 2004 2005 2006 2008 2010 2012" 

foreach year in $years {
	g d_`year' = (year == `year')	
}


g exp_nofactor = 1
		 
*base 100 = july 2018
*inflation at september of each yer to 07/2018
local cpi_1992 = 702.94
local cpi_1994 = 587.32
local cpi_1996 = 268.49
local cpi_1998 = 167.66
local cpi_2000 = 112.3
local cpi_2002 = 90.59
local cpi_2004 = 74.37
local cpi_2005 = 68.46
local cpi_2006 = 61.83

*inflation from 2018/7 to 12/2025
local cpi_2025 = 43.17
*us to mex december 31 2025
local us_mx = 1/20.52

g inf_ex_rate = .

global years = "1992 1994 1996 1998 2000 2002 2004 2005 2006"
foreach year in $years {
	*replace inf_ex_rate3 = (`cpi_2025'/`cpi_`year'')*`us_mx' if year  == `year'	
	replace inf_ex_rate = (1+`cpi_`year''/100)*(1+`cpi_2025'/100)*`us_mx' if year  == `year'	
}


global foods = "cereals meat_dairy sugar_fat_drink vegg_fruit coffe_spices_other tobacco outside_food alcohol packaged_food baby_food pet_food"

foreach food in $foods {
	g `food'_mxn = `food'
	replace `food' = `food' * inf_ex_rate
	g `food'_pc = `food'/n_hh
	g ln_`food'_pc = ln(`food'_pc)
	
}

global income_ind = "wage_ind indep_w_ind capital_ind transfer_ind other_inc_ind remit_ind  benef_gob_ind progresa_ind family_trans_ind benef_don_gob_ind benef_don_non_gob_ind"

foreach income in $income_ind {
	g `income'_mxn = `income'
	replace `income' = `income' * inf_ex_rate
	g ln_`income' = ln(`income')
	
}

global income_hh = "wage_hh indep_w_hh capital_hh transfer_hh other_inc_hh remit_hh benef_gob_hh progresa_hh family_trans_hh benef_don_gob_hh benef_don_non_gob_hh"

foreach income in $income_hh {
	g `income'_mxn = `income'
	replace `income' = `income' * inf_ex_rate
	g ln_`income'_pc = ln(`income'/n_hh)
	
}

global health = "medical_outpatient drugs_prescribed medical_inpatient drugs_overcounter ortho insurance_cost"

foreach health in $health {
	g `health'_mxn = `health'
	replace `health' = `health' * inf_ex_rate
	g `health'_pc = `health'/n_hh
	g ln_`health'_pc = ln(`health'_pc)
	
}

global expanditures = "savings currency loans debt"

foreach exp in $expanditures {
	g `exp'_mxn = `exp'
	replace `exp' = `exp' * inf_ex_rate
	g `exp'_pc = `exp'/n_hh
	g ln_`exp'_pc = ln(`exp'_pc)
	
}


g hh_income_tot = (hh_income_mxn_tot) * inf_ex_rate
g hh_earnings = (hh_earnings_mxn) * inf_ex_rate
g hh_expenditure = (hh_expenditure_mxn) * inf_ex_rate

g ind_income_tot = (income_ind_mxn_tot) * inf_ex_rate
g ind_earnings = (earnings_ind_mxn) * inf_ex_rate

*health vars
egen health_exp = rowtotal(medical_outpatient medical_inpatient drugs_prescribed ///
drugs_overcounter ortho)
egen drugs = rowtotal(drugs_prescribed drugs_overcounter)
egen health_med = rowtotal(medical_outpatient medical_inpatient)

g health_exp_pc = health_exp / n_hh
g drugs_pc = drugs / n_hh
g health_med_pc = health_med / n_hh


*food is already monthly
egen food_exp_mxn = rowtotal(cereals_mxn meat_dairy_mxn sugar_fat_drink_mxn ///
vegg_fruit_mxn coffe_spices_other_mxn outside_food_mxn packaged_food_mxn ///
baby_food_mxn)

*log food expenditure monthly per capita

egen food_exp = rowtotal(cereals meat_dairy sugar_fat_drink vegg_fruit ///
coffe_spices_other outside_food packaged_food baby_food)

g food_exp_pc = food_exp / n_hh

*I disaggregate food expenditure by category: any/all food;
*starches, cereals, and grains (e.g., bread, tortillas, potatoes, rice, other carbohydrates); meat/dairy (e.g.,
*pork, beef, cheese, eggs, milk, poultry, sh); sugars and fats (e.g., cookies, pastries, candy, soda, oils);
*and lastly vegetables and fruits (e.g., mangos, bananas, tomatoes, chard, lettuce).

*I include all sources of income for the household, such as earnings
*and both government and private transfers.26

compress

g ln_ind_earnings = log(ind_earnings)
g ln_ind_income_tot = log(ind_income_tot)

*per capita
g earnings_pc = hh_earnings/n_hh
g income_pc_tot = hh_income_tot/n_hh
g expenditure_pc = hh_expenditure/n_hh

*log of monthly income/spending per capita
g ln_earnings_pc = log(earnings_pc)
g ln_income_pc_tot = log(income_pc_tot)
g ln_exp_pc = log(expenditure_pc)
g ln_food_exp_pc = log(food_exp_pc)

* Inelegibles should not be all, may be up t to loc_size == 2? 

 			 
drop trabajo


save "$data/enigh_panel", replace