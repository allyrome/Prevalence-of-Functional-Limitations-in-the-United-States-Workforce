* Table S1 - Decsriptive Statistics for the HFCS analysis sample
* Author: Alexandra Rome
* Purpose: 
* 	Find prevalence of each functional limitation within the sample and within job profiles by job profile education requirement  
*==================================================================================================

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

use "Data\HFCS\clean_data\hfcs_recodes.dta" , clear

* Keep if working and passed screener
keep if working == 1
keep if pass_screener == 1

* If no limitation data then treat as no limitation (i.e. 0) 
replace value = 0 if missing(value)

* Convert value to binary
replace value = cond(value >= 2, 1, 0)

drop if missing(Question)

collapse (max) value, by(prim_key Question Functional_Group Label weight)
svyset prim_key [pw=weight], strata(Question)

save "Data\HFCS\clean_data\interim\hfcs_recodes_collapse_s1.dta" , replace

levelsof Question, local(groups)

clear
gen Question = ""
tempfile results
save `results' , replace

foreach g of local groups {
	
	use "Data\HFCS\clean_data\interim\hfcs_recodes_collapse_s1.dta" , clear
	
	keep if Question == "`g'"
	
	svy, subpop(if value<.): mean value
	matrix b = r(table)
	
	gen prevalence = b[1,1]
	gen lower = b[5,1]
	gen upper = b[6,1]
	
	collapse (first) prevalence upper lower Functional_Group Label, by(Question)
	
	append using `results'
	
	save `results' , replace

}


import excel "Data\HFCS\clean_data\variables_full_fml.xlsx", sheet("deg_lim") firstrow clear
rename itemvar Question

merge 1:1 Question using `results' , keep(match)
drop _merge

gen num_q = subinstr(Question, "Q", "", .)
replace num_q = subinstr(num_q, "_combo", "", .)
replace num_q = subinstr(num_q, "_combo_", ".", .)
replace num_q = subinstr(num_q, "_", ".", .)
destring num_q , replace

* Question 12 has 12.10 and 12.11, These should come after 12.9, so to order them numerically we will renumber them here
replace num_q = 12.91 if num_q == 12.1
replace num_q = 12.92 if num_q == 12.11

* Local of estimates
local vars prevalence upper lower 

* Loop over each variable in the list and apply the rounding
foreach var of local vars {
    replace `var' = round(`var', 0.001)
}

gen mean_ci = string(prevalence, "%9.3f") + " (" + string(lower, "%9.3f") + "-" + string(upper, "%9.3f") + ")"

* Merge in prevalence of limitation by job profile borken down by education
merge 1:1 Question using "Papers\Burdens of Functional Limitations\Appendix\restricted_limitations\job_profiles_limitations_education" 
drop _merge

* Formatting
sort Functional_Group num_q

keep Label Functional_Group lim_deg mean_ci no_college_degree college_degree

gen period_pos = strpos(Label, ".")
replace Label = substr(Label, period_pos+1, .)

drop period_pos


**** Language Fixes to descriptions ***

* remove excess language
replace Label = subinstr(Label, "Other medical conditions: ", "", .)
replace Label = subinstr(Label, "Difficulties w/ less routine tasks: ", "", .)
replace Label = subinstr(Label, "Supports at work (thinking): ", "", .)
replace Label = subinstr(Label, "Difficulties w/ routine activities: ", "", .)
replace Label = subinstr(Label, "Supports at work (social): ", "", .)
replace Label = subinstr(Label, "w.r.t.", "with regard to", .)

* Correct language in Ambient Environment
replace Label = "Skin contact" if Label == "Skin irritation"
replace Label = "Air quality" if Label == "Particulate matter"
replace Label = "Other medical conditions limiting tolerance to different physical environments" if Label == "Other" & Functional_Group == "Ambient Environment"
replace Label = "Other accommodations needed to work in different physical environments" if Label == "Accomodations (physical-env)"

* Correct language in Body Function, Not elsewhere classified
replace Label = "Localized physical limitations" if Label == "Side of body with difficulties"
replace Label = "Other limitations with regard to static postures" if Label == "Other difficulties w.r.t. static postures "

* Correct language for Hand and Finger Movements
replace Label = "Sphere grip" if lim_deg == "Difficulty grasping round objects (e.g., door knob)"
replace Label = "Pen grip" if lim_deg == "Difficulty handling objects between the tips of 2 fingers and  thumb (e.g., holding a pen)"
replace Label = "Tweezer grip" if lim_deg == "Difficulty handling objects between the top of index finger and thumb (pincer grasp)"
replace Label = "Key grip" if lim_deg == "Limited grip strength with fingers and thumb (e.g., holding and turning a key) "
replace Label = "Squeezing & gripping" if lim_deg == "Limited grip strength in hand (e.g., squeezing objects) "
replace Label = "Cylinder grip" if lim_deg == "Difficulty handling rod-shaped objects (e.g., carrying suitcase by handle) "
replace Label = "Fine Motor Skills" if lim_deg == "Difficulty making accurate, fine movements with fingers and hands (e.g., pulling a thread through eye of needle) "
replace Label = "Repetitive Acts" if lim_deg == "Difficulty making repetitive movements with fingers and hands (e.g., typing) "

replace Label = "Working with a keyboard and mouse" if Label == "Mouse and keyboard"
replace Label = "Twisting movements with hands/arms" if Label == "Twisting movements arms/hands"

* correct language for Head and Neck Movements 
replace Label = "Head movements" if Label == "Limitations head movements"

* Correct language for Memory
replace Label = "Attention span" if Label == "Focus attention (length)"
replace Label = "Dividing Attention" if Label == "Multiple tasks"
replace Label = "Insight into own abilities" if Label == "Estimate abilities/limitations"
replace Label = "Other difficulties with planning and doing simple activities " if Label == "Other" & Functional_Group == "Memory, Attention and Cognition"
replace Label = "Other difficulties in doing activities independently" if Label == "Other " & Functional_Group == "Memory, Attention and Cognition"

* Correct language for Social Skills and Emotional Regulation
replace Label = "Coping with others' emotional problems" if Label == "Others' emotional problems"
replace Label = "Expressing your own feelings" if Label == "Express feelings"
replace Label = "Dealing with conflicts" if Label == "Cope with conflict"
replace Label = "Collaboration" if Label == "Work in teams"
replace Label = "Other accommodations needed due to health and its impacts on interactions with others" if Label == "Other accomodations" & Functional_Group == "Social Skills and Emotional Regulation"

* Correct language for Upper Body Strength and Torso Range of Motion 
replace Label = "Frequently handling light objects" if Label == "Lifting or carrying (frequency)"
replace Label = "Frequently handling heavy loads" if Label == "Handling heavy loads frequently"
replace Label = "Active when bending/twisting" if Label == "Active when bent upper body"

* export excel Functional_Group Label lim_deg mean_ci job_prof_prevalence using "Papers/Burdens of Functional Limitations/Appendix/common_func_limitations", replace firstrow(variables)
export excel Functional_Group Label lim_deg mean_ci no_college_degree college_degree using "Papers/Burdens of Functional Limitations/Appendix/common_func_limitations_education", replace firstrow(variables)

