* Table S7 - Regressions sensitivity comparisons
* Author: Alexandra Rome
* Purpose: 

*==================================================================================================

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

use "Data\HFCS\clean_data\interim\medcond_g.dta" , clear
drop Broadermedicalcategory

drop if missing(med_group)

keep if pass_screener == 1
keep if emp_stat == 1

gen age22_34 = (age_grp3 == 1)
gen age35_49 = (age_grp3 == 2)
gen age50_64 = (age_grp3 == 3)
gen age65 = (age_grp3 == 4)

replace med_group = substr(med_group, 1, 27)

reshape wide value, i(prim_key) j(med_group) string

foreach v of varlist value* {
  local new = substr("`v'", 6, .) 
  rename `v' `new'
}

svyset [pw=weight], singleunit(certainty) 


************** 97 Total Limitataions - Weighted Limitataions **************


global med_groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease 


* Create excel sheet to hold results
putexcel set "Papers\Burdens of Functional Limitations\Appendix\med_condition_coefficients_97wtd.xlsx", replace

putexcel A1 = "condition" 
putexcel B1 = "coeff"
putexcel C1 = "coeff_se"
putexcel D1 = "coeff_p"
putexcel E1 = "prevalence" 
putexcel F1 = "prevalence_se"
putexcel G1 = "increase"

* Regress number of limitations on medical conditions
svy: reg num_limit_wtd $med_groups age35_49 age50_64 age65 female

local groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease

* Fill in set excel sheet with results
forvalues i = 1/30 {
   local var : word `i' of `groups'
   local pvalue = 2*ttail(`e(df_r)', abs(_b[`var']/_se[`var']))
   putexcel A`=`i'+1' = "`var'"
   putexcel B`=`i'+1' = _b[`var']
   putexcel C`=`i'+1' = _se[`var']
   putexcel D`=`i'+1' = `pvalue'
   
   quietly summarize `var' [aw=weight]
   putexcel E`=`i'+1' = (r(mean)) 
   putexcel F`=`i'+1' = ((r(sd))/sqrt(r(N))) 
   putexcel G`=`i'+1' = ((_b[`var'])*(r(mean))*100)  
}


putexcel close

* Call regression results from excel sheet made above 
import excel "Papers\Burdens of Functional Limitations\Appendix\med_condition_coefficients_97wtd.xlsx", cellrange(A1:G31) firstrow clear


****************** Prepare table for output **********************
gsort -increase 
gen rank = _n
keep if rank < 11


gen coeff_rnd = string(round(coeff, 0.01), "%9.2f") 
replace coeff_rnd = coeff_rnd + "*" if coeff_p < 0.10 & coeff_p >= 0.05
replace coeff_rnd = coeff_rnd + "**" if coeff_p < 0.05 & coeff_p >= 0.01
replace coeff_rnd = coeff_rnd + "***" if coeff_p < 0.01


gen coeff_se_rnd = string(round(coeff_se, 0.01), "%9.2f")
replace coeff_se_rnd = "(" + coeff_se_rnd + ")" 


keep condition coeff_rnd coeff_se_rnd rank

rename coeff_rnd coeff1
rename coeff_se_rnd coeff2

reshape long coeff, i(condition) j(se_ind)
sort rank se_ind

replace condition = "" if se_ind == 2

drop se_ind rank

* Fix condition formatting
replace condition = subinstr(condition, "_", " ", .)
* Fill in missing words
replace condition = "Arthritis and other joint disease" if condition == "Arthritis and other joint d"
replace condition = "Substance use disorder (SUD) and related complications" if condition == "SUD and related complicatio"
replace condition = "Asthma or chronic obstructive pulmonary disease (COPD)" if condition == "Asthma or COPD"
replace condition = "Fibromyalgia and neuropathic pain and fatigue" if condition == "Fibromyalgia and neuropathi"

label variable condition "Medical Condition"
label variable coeff "Increase in Number of Functional Limitations"


* Export to excel- After exporting to Excel, some additional formatting is doen within excel and word to adjust the text etc.
export excel using "Papers\Burdens of Functional Limitations\Appendix\exhibit_s7_97wtd", replace firstrow(varlabels)


************* 56 Total Limitations (Unweighted Limitations) ********

use "Data\HFCS\clean_data\interim\medcond_g.dta" , clear
drop Broadermedicalcategory

drop if missing(med_group)

keep if pass_screener == 1
keep if emp_stat == 1

gen age22_34 = (age_grp3 == 1)
gen age35_49 = (age_grp3 == 2)
gen age50_64 = (age_grp3 == 3)
gen age65 = (age_grp3 == 4)

replace med_group = substr(med_group, 1, 27)

reshape wide value, i(prim_key) j(med_group) string

foreach v of varlist value* {
  local new = substr("`v'", 6, .) 
  rename `v' `new'
}

svyset [pw=weight], singleunit(certainty) 


************** Primary specification **************


global med_groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease 


* Create excel sheet to hold results
putexcel set "Papers\Burdens of Functional Limitations\Appendix\med_condition_coefficients_56unwtd.xlsx", replace

putexcel A1 = "condition" 
putexcel B1 = "coeff"
putexcel C1 = "coeff_se"
putexcel D1 = "coeff_p"
putexcel E1 = "prevalence" 
putexcel F1 = "prevalence_se"
putexcel G1 = "increase"

* Regress number of limitations on medical conditions
svy: reg num_limit56 $med_groups age35_49 age50_64 age65 female

local groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease

* Fill in set excel sheet with results
forvalues i = 1/30 {
   local var : word `i' of `groups'
   local pvalue = 2*ttail(`e(df_r)', abs(_b[`var']/_se[`var']))
   putexcel A`=`i'+1' = "`var'"
   putexcel B`=`i'+1' = _b[`var']
   putexcel C`=`i'+1' = _se[`var']
   putexcel D`=`i'+1' = `pvalue'
   
   quietly summarize `var' [aw=weight]
   putexcel E`=`i'+1' = (r(mean)) 
   putexcel F`=`i'+1' = ((r(sd))/sqrt(r(N))) 
   putexcel G`=`i'+1' = ((_b[`var'])*(r(mean))*100)  
}


putexcel close

* Call regression results from excel sheet made above 
import excel "Papers\Burdens of Functional Limitations\Appendix\med_condition_coefficients_56unwtd.xlsx", cellrange(A1:G31) firstrow clear


****************** Prepare table for output **********************
gsort -increase 
gen rank = _n
keep if rank < 11


gen coeff_rnd = string(round(coeff, 0.01), "%9.2f") 
replace coeff_rnd = coeff_rnd + "*" if coeff_p < 0.10 & coeff_p >= 0.05
replace coeff_rnd = coeff_rnd + "**" if coeff_p < 0.05 & coeff_p >= 0.01
replace coeff_rnd = coeff_rnd + "***" if coeff_p < 0.01


gen coeff_se_rnd = string(round(coeff_se, 0.01), "%9.2f")
replace coeff_se_rnd = "(" + coeff_se_rnd + ")" 


keep condition coeff_rnd coeff_se_rnd rank

rename coeff_rnd coeff1
rename coeff_se_rnd coeff2

reshape long coeff, i(condition) j(se_ind)
sort rank se_ind

replace condition = "" if se_ind == 2

drop se_ind rank

* Fix condition formatting
replace condition = subinstr(condition, "_", " ", .)
* Fill in missing words
replace condition = "Arthritis and other joint disease" if condition == "Arthritis and other joint d"
replace condition = "Substance use disorder (SUD) and related complications" if condition == "SUD and related complicatio"
replace condition = "Asthma or chronic obstructive pulmonary disease (COPD)" if condition == "Asthma or COPD"
replace condition = "Fibromyalgia and neuropathic pain and fatigue" if condition == "Fibromyalgia and neuropathi"

label variable condition "Medical Condition"
label variable coeff "Increase in Number of Functional Limitations"


* Export to excel- After exporting to Excel, some additional formatting is doen within excel and word to adjust the text etc.
export excel using "Papers\Burdens of Functional Limitations\Appendix\exhibit_s7_56unwtd", replace firstrow(varlabels)


****************** 56 Total Limitations (Weighted Limitataions) *****************

use "Data\HFCS\clean_data\interim\medcond_g.dta" , clear
drop Broadermedicalcategory

drop if missing(med_group)

keep if pass_screener == 1
keep if emp_stat == 1

gen age22_34 = (age_grp3 == 1)
gen age35_49 = (age_grp3 == 2)
gen age50_64 = (age_grp3 == 3)
gen age65 = (age_grp3 == 4)

replace med_group = substr(med_group, 1, 27)

reshape wide value, i(prim_key) j(med_group) string

foreach v of varlist value* {
  local new = substr("`v'", 6, .) 
  rename `v' `new'
}

svyset [pw=weight], singleunit(certainty) 


************** Primary specification **************


global med_groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease 


* Create excel sheet to hold results
putexcel set "Papers\Burdens of Functional Limitations\Appendix\med_condition_coefficients_56wtd.xlsx", replace

putexcel A1 = "condition" 
putexcel B1 = "coeff"
putexcel C1 = "coeff_se"
putexcel D1 = "coeff_p"
putexcel E1 = "prevalence" 
putexcel F1 = "prevalence_se"
putexcel G1 = "increase"

* Regress number of limitations on medical conditions
svy: reg num_limit_wtd56 $med_groups age35_49 age50_64 age65 female

local groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease

* Fill in set excel sheet with results
forvalues i = 1/30 {
   local var : word `i' of `groups'
   local pvalue = 2*ttail(`e(df_r)', abs(_b[`var']/_se[`var']))
   putexcel A`=`i'+1' = "`var'"
   putexcel B`=`i'+1' = _b[`var']
   putexcel C`=`i'+1' = _se[`var']
   putexcel D`=`i'+1' = `pvalue'
   
   quietly summarize `var' [aw=weight]
   putexcel E`=`i'+1' = (r(mean)) 
   putexcel F`=`i'+1' = ((r(sd))/sqrt(r(N))) 
   putexcel G`=`i'+1' = ((_b[`var'])*(r(mean))*100)  
}


putexcel close

* Call regression results from excel sheet made above 
import excel "Papers\Burdens of Functional Limitations\Appendix\med_condition_coefficients_56wtd.xlsx", cellrange(A1:G31) firstrow clear


****************** Prepare table for output **********************
gsort -increase 
gen rank = _n
keep if rank < 11


gen coeff_rnd = string(round(coeff, 0.01), "%9.2f") 
replace coeff_rnd = coeff_rnd + "*" if coeff_p < 0.10 & coeff_p >= 0.05
replace coeff_rnd = coeff_rnd + "**" if coeff_p < 0.05 & coeff_p >= 0.01
replace coeff_rnd = coeff_rnd + "***" if coeff_p < 0.01


gen coeff_se_rnd = string(round(coeff_se, 0.01), "%9.2f")
replace coeff_se_rnd = "(" + coeff_se_rnd + ")" 


keep condition coeff_rnd coeff_se_rnd rank

rename coeff_rnd coeff1
rename coeff_se_rnd coeff2

reshape long coeff, i(condition) j(se_ind)
sort rank se_ind

replace condition = "" if se_ind == 2

drop se_ind rank

* Fix condition formatting
replace condition = subinstr(condition, "_", " ", .)
* Fill in missing words
replace condition = "Arthritis and other joint disease" if condition == "Arthritis and other joint d"
replace condition = "Substance use disorder (SUD) and related complications" if condition == "SUD and related complicatio"
replace condition = "Asthma or chronic obstructive pulmonary disease (COPD)" if condition == "Asthma or COPD"
replace condition = "Fibromyalgia and neuropathic pain and fatigue" if condition == "Fibromyalgia and neuropathi"

label variable condition "Medical Condition"
label variable coeff "Increase in Number of Functional Limitations"


* Export to excel- After exporting to Excel, some additional formatting is doen within excel and word to adjust the text etc.
export excel using "Papers\Burdens of Functional Limitations\Appendix\exhibit_s7_56wtd", replace firstrow(varlabels)
