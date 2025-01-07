* HFCS - add medical condition data
* Author: Alexandra Rome
* Purpose: Add medical condition labels and groupings to HFCS data, save as medcond_g.dta
*	1. Clean medical condition groupings and save as `med_groups'
*	2. Add variable labels "Q1_*" to `med_groups' and save as `med_labs'
*	3. Tidy HFCS data and add `med_labs' to it

*==================================================================================================

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

******** Tidy dataset of Grouped medical conditions and save in a tempfile ********

* Load Medical conditions grouped by category, these groupings were created by the authors
* This excel sheet is formatted with the name of the Category listed only once in "Category", with multiple rows of conditions listed in "Conditions" that belong to that category which in turn correspond to empty values of Category
import excel "Data\HFCS\clean_data\interim\HFCS Collapsed Medical Condition Categories_04302024.xlsx", cellrange(A3:C107) firstrow clear

* Drop rows in between Categories, where both columns are empty
keep if !missing(Category) | !missing(Conditions)
* Drop empty column B
drop B

* Carry the value of Category down throughout the rows that belong to the Category, but are empty 
replace Category = Category[_n-1] if Category==""

rename Category med_group
rename Conditions med_labs

tempfile med_groups1
save `med_groups1'

import excel "Data\HFCS\clean_data\interim\Broader medical condition categories.xlsx", cellrange(A1:B32) firstrow clear
rename Medicalcondition med_group

merge 1:m med_group using `med_groups1'

drop _merge

tempfile med_groups
save `med_groups'

******** Add HFCS Q# to medical condition labels and groupings and save in tempfile ********

* load HFCS data 
use "Data\HFCS\clean_data\HFCS_CLEAN.dta", clear

* keep only survey questions
keep Q1_bone_1-Q90a_7

* put variables and variable labels as observations
describe, replace clear

* keep only medical conditions, which all come from Question 1
keep if strpos(name, "Q1_") == 1 

* keep medical conditions and variable labels
keep name varlab
rename name med_cond
rename varlab med_labs 

merge 1:m med_labs using `med_groups'

* Everything that is included in Q1 that is not a medical condition, has no assigned medical group, and is only in the master data set 
* This includes:
* med_labs = *_other (free text response questions that ask to list a different condition within that group (for example: Other Lung Disease: [free text])) 
* med_labs = *_fu* (free text cause questions (for example: if you indicate hearing loss, you are asked "Cause of hearing loss: [free text]))
* med_labs =  Q1_bone_15* Q1_nervous_11* Q1_heart_8* Q1_lung_6* Q1_gastro_8* Q1_infectious_4* Q1_mental_14* Q1_other_14* (The final question of each section is "None of these")

drop if _merge != 3
drop _merge

* Rename "Serious Mental Illness" and "Other Mental Illness" to "Mental Illness" so they are grouped together
replace med_group = cond(med_group=="Serious Mental Illness" | med_group=="Other Mental Illness", "Mental Illness" , med_group)

tempfile hfcs_med_labs
save `hfcs_med_labs'

******** Tidy HFCS data and add medical conditions and groupings ********

* Load HFCS data, keep only medical condition data
use "Data\HFCS\clean_data\HFCS_CLEAN.dta" , clear
keep prim_key no_health_problems Q1_* 

* Drop duplicate Q1 variables that are old
drop *old

* Merge in informtaion added in data_prep.do (occupation, industry, ess/tele, etc.)
merge 1:1 prim_key using "Data\HFCS\clean_data\hfcs_recodes_clpsd.dta"
* As noted earlier respondent 11084165:1 is missing from hfcs_recodes_clpsd so they also don't merge in
keep if _merge == 3
drop _merge

* Drop everything from Q1 that is not a medical condition, as described above in line 58-61
drop *_other *_fu* Q1_bone_15* Q1_nervous_11* Q1_heart_8* Q1_lung_6* Q1_gastro_8* Q1_infectious_4* Q1_mental_14* Q1_other_14*

* Replace missing values with no limitation
foreach var of varlist Q1_*{
    replace `var' = 0 if `var' == .s | `var' == .
}

* Rehsape from wide to long
reshape long Q1_ , i(prim_key) j(med_cond) string
rename Q1_ value
replace med_cond = "Q1_" + med_cond

* Merge in medical condition names and groupings on HFCS question number
merge m:1 med_cond using `hfcs_med_labs'
drop _merge

* Each respondent has 72 observations, 1 for each medical condition, where value == 1 if the respondent indicates having that condition, and 0 otherwise
* These 72 conditions belong to 30 groupings created by the authors
* Collapse to the maximum of value within each group to create an indicator for if they have a medical condition within that grouping
collapse (max) value (first) female AGE age_grp3 college college2 college3 isco_1dig isco_1dig_char hand_assign_use2 hand_assign_use2_char Q81 emp_stat weight pass_screener num_limit num_limit_wtd num_limit56 num_limit_wtd56 no_health_problems Broadermedicalcategory, by(prim_key med_group)

replace med_group = subinstr(med_group," ", "_", .)
replace med_group = subinstr(med_group, "/", "_or_",.) 


save "Data\HFCS\clean_data\interim\medcond_g.dta" , replace

collapse (max) value (first) female AGE age_grp3 college college2 college3 isco_1dig isco_1dig_char hand_assign_use2 hand_assign_use2_char Q81 emp_stat weight pass_screener num_limit num_limit_wtd num_limit56 num_limit_wtd56 no_health_problems, by(prim_key Broadermedicalcategory)

rename Broadermedicalcategory med_group

replace med_group = subinstr(med_group," ", "_", .)
replace med_group = subinstr(med_group, "/", "_or_",.) 


save "Data\HFCS\clean_data\interim\medcond_g_broad.dta" , replace