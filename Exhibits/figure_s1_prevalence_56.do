* Figure S1- Prevalence of any limitation in functional domain
* Author: Alexandra Rome
* Purpose: 
* 	Find prevalence of any limitation within the 16 functional domains and plot using only the 56 limitations inlcuded in the automated algorithm
*==================================================================================================

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

* Load HFCS data 
use "Data\HFCS\clean_data\hfcs_recodes.dta" , clear

* Keep if working and passed screener
keep if working == 1
keep if pass_screener == 1

* If no limitation data then treat as no limitation (i.e. 0) 
replace value = 0 if missing(value)

* Convert value to binary;
*	= 0 for Normal/Somewhat Limited 
*	= 1 for Slightly Limited/Limited
replace value = cond(value >= 2, 1, 0)

* Create number of limitations variable that only totals from the 56 limitations used in the matching algorithm rather than the 97 total limitations 

tempfile hfcs_recodes_temp
save `hfcs_recodes_temp'

import excel "Code\job_profiles_matching\limitations_prevalence_job_profiles_hfcs.xlsx", sheet("Algorithm") firstrow clear

merge 1:m Question using `hfcs_recodes_temp'
replace used_in_algorithm = 0 if _merge == 2
drop _merge

gen value3 = 0 
replace value3 = value if used_in_algorithm == 1

* Take the maximum value within each functional group to create an indicator 
 collapse (max) value3, by(prim_key Functional_Group weight)

* Survey Set the data
svyset prim_key [pw=weight], strata(Functional_Group)

* Save collapsed data in an iterim folder to call at the top of a loop
save "Data\HFCS\clean_data\interim\hfcs_recodes_collapse_sensitivity.dta" , replace

* Create local of indicators for each functional group
levelsof Functional_Group, local(groups)
local conditions essential nonessential teleworkable nonteleworkable

* Create empty dataset with 1 variable "Functional_Group" to save as a tempfile and append to each loop
clear
gen Functional_Group = ""
tempfile results_sensitivity
save `results_sensitivity' , replace

* Find prevalence of limitations in each functional group with confidence intervals 

foreach g of local groups {
	
	use "Data\HFCS\clean_data\interim\hfcs_recodes_collapse_sensitivity.dta" , clear
	
	keep if Functional_Group == "`g'"
	
	svy, subpop(if value<.): mean value
	matrix b = r(table)
	gen prevalence = b[1,1]
	gen lower = b[5,1]
	gen upper = b[6,1]
	
	collapse (first) prevalence upper lower, by(Functional_Group)
	
	append using `results_sensitivity'
	
	save `results_sensitivity' , replace

}

egen numvar = group(Functional_Group), label
drop if Functional_Group == "Body Function, Not Elsewhere Classified"

sort prevalence
gen var_order = _n

* If Stata version below 18, will need to ssc install cleanplots 
set scheme cleanplots

graph twoway (bar prevalence var, horizontal barwidth(0.7) color(navy)) (rcap lower upper var, horizontal color(maroon)), ylabel(1 "Immune System " 2 "Pace" 3 "Memory, Attention and Cognition" 4 "Verbal and Written Communication" 5 "Sensory" 6 "Standing" 7 "Social Skills and Emotional Regualtion" 8 "Mobility" 9 "Hand and Finger Movements" 10 "Head and Neck Movements" 11 "Arm Movements" 12 "Sitting" 13 "Knee Movements" 14 "Ambient Environment" 15 "Upper Body Strength and Torso Range of Motion" , angle(0) labsize(small)) xlabel(0 "0%" 0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%") ytitle("") leg(off) 


graph export "Papers\Burdens of Functional Limitations\Exhibit 2\prevalence_by_group_sensitivity.png" , replace

