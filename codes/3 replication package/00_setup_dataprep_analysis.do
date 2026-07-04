
// SETUP ---------------------------------------------------------- //

set more off
set varabbrev off
clear all
macro drop _all
version 16

// DIRECTORIES ---------------------------------------------------------------

global main "C:/Users/parke/Dropbox/LT_Impact_Prospera_New/FinalEJSubmission/Revisions_ReplicationPackageMay22023/3 replication package"

// Subdirectories//
local subdirectories ///
    data             ///
    logs             ///
    tempdata         ///
    Results          ///
    programs
foreach folder of local subdirectories {
    cap mkdir "$main/`folder'" // Create folder if it doesn't exist already//
    global `folder' "$main/`folder'"
}

cap mkdir "$Results/figures"
cap mkdir "$Results/tables"
cap mkdir "$data/01_dataprep"
cap mkdir "$data/02_dataanalysis"
cap mkdir "$data/shapefiles"
cap mkdir "$programs/01_dataprep"
cap mkdir "$programs/02_dataanalysis"
cap mkdir "$logs"

// install ado files//
ssc install reghdfe
net install grc1leg,from (http://www.stata.com/users/vwiggins/)  
ssc install heatplot
ssc install palettes
ssc install colrspace
ssc install shp2dta
ssc install spmap

//set up files//
do "$programs/01_dataprep/01_create_municipal_level_indicators.do"
do "$programs/01_dataprep/02_mex_1990_kids_ipums.do"
do "$programs/01_dataprep/02_mex_2010_kids_ipums.do"
do "$programs/01_dataprep/03_mex_1990_ipums.do"
do "$programs/01_dataprep/03_mex_2000_ipums.do"
do "$programs/01_dataprep/03_mex_2010_ipums.do"

log using "$logs/log_file", replace
//programs generating results//

// Tables 1 to 5, Figures 5 to 9, Appendix Tables 3 to 9, Appendix Fig 5 and 7//
do "$programs/02_dataanalysis/04_analysis2010.do"
//Figure 1//
do "$programs/02_dataanalysis/04_rollout_time_series.do"
//Figure 2//
do "$programs/02_dataanalysis/04_rollout_locality.do"
//Figures 3 and 4 and Appendix Table 2//
do "$programs/02_dataanalysis/04_rollout_muni.do"
//Appendix Figure 1//
do "$programs/02_dataanalysis/04_maps.do"
//Appendix Figures 2, 3 and 6//
do "$programs/02_dataanalysis/04_cohortsize.do"
//Appendix Figure 4//
do "$programs/02_dataanalysis/04_enroll2000.do"
//Appendix Figure 8//
do "$programs/02_dataanalysis/04_analysis1990.do"
//Appendix Figure 9//
do "$programs/02_dataanalysis/04_edyrs_sex_age.do"
//Appendix Table 10//
do "$programs/02_dataanalysis/05_benefit_cost.do"

log close