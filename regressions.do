* Exhibit 4 - Regression Results
* Author: Alexandra Rome
* Purpose: 
* 	1. Run regression of number of limitations on demographics for supplementary info
*	2. Run primary analysis:
* 		Find the top ten highest impact medical conditions, ranked by population impact 
* 			Find:
*			1. Increase in number of functional limitations by medical condition
*			2. Find the prevalence of each medical condition
*			3. Multiply (1) * (2) x 100 to get the top 10 highest impact medical conditions
* 		Export table to excel
*	3. Find summary stats of all correlation coefficents between medical conditions and create summary stats table
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

******** Regression of functional limitations on demographic and job characteristics ******

* Create demographic variables 

* Add super-sector information
gen goods =  (Q81<= 5 & Q81 != 3)
gen service = (Q81 > 5 | Q81 == 3)

* Add occupation information
tab isco_1dig, gen(isco_1dig)

rename isco_1dig1 armed_forces 
rename isco_1dig2 managers
rename isco_1dig3 professionals
rename isco_1dig4 technicians
rename isco_1dig5 clerical
rename isco_1dig6 service_sales
rename isco_1dig8 craft
rename isco_1dig9 plant
rename isco_1dig10 elementary

label var female "Female"
label var age35_49 "Age 35 to 49"
label var age50_64 "Age 50 to 64"
label var age65 "Age > 64"
label var college "BA"
label var managers "Managers" 
label var technicians "Technicians and associate professionals" 
label var clerical "Clerical support workers" 
label var service_sales "Services and sales workers" 
label var craft "Craft and related trade workers" 
label var plant "Plant and machine operators and assemblers" 
label var elementary "Elementary occupations" 
label var armed_forces "Armed Forces"
label var goods "Goods-producing" 
label var num_limit "Number of Limitations"

* Regress number of limitations on demographics
svy: reg num_limit female age35_49 age50_64 age65 college managers technicians clerical service_sales craft plant elementary armed_forces goods

* Export regression results to Excel with coefficients, standard errors, and significance stars
esttab using "Papers\Burdens of Functional Limitations\Appendix\exhibit_s4_demo_reg.csv", se label replace


************** Primary specification **************

* Save data for bootstrap 
save "Data\HFCS\clean_data\interim\medcond_g_reg.dta" , replace

global med_groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease 

* Regress number of limitations on demographics
svy: reg num_limit $med_groups age35_49 age50_64 age65 female

*Save correlation matrix for supplementary info
estpost correlate $med_groups [aw=weight], matrix listwise
esttab using "Papers\Burdens of Functional Limitations\Appendix\correlation_matrix.csv", replace unstack not noobs compress nostar

* Create excel sheet to hold results
putexcel set "Papers\Burdens of Functional Limitations\Exhibit 4\med_condition_coefficients.xlsx", replace

putexcel A1 = "condition" 
putexcel B1 = "coeff"
putexcel C1 = "coeff_se"
putexcel D1 = "coeff_p"
putexcel E1 = "prevalence" 
putexcel F1 = "prevalence_se"
putexcel G1 = "increase"

* Regress number of limitations on demographics
svy: reg num_limit $med_groups age35_49 age50_64 age65 female

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

* Run sensitivity analysis- regression with no controls and fill in reults 
putexcel H1 = "coeff_nocontrols"
putexcel I1 = "coeff_se_nocontrols"
putexcel J1 = "coeff_p_nocontrols"

svy: reg num_limit $med_groups 

forvalues i = 1/30 {
   local var : word `i' of `groups'
   local pvalue = 2*ttail(`e(df_r)', abs(_b[`var']/_se[`var']))
   putexcel H`=`i'+1' = _b[`var']
   putexcel I`=`i'+1' = _se[`var']
   putexcel J`=`i'+1' = `pvalue'

}


putexcel close



*************** Bootstrap SE for Beta X Prevalence X 100 *****************

* Reset working directory 
cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity\Data\HFCS\clean_data\interim"

* Create a postfile called boot_results with 2 variables; condition (which is the nam eof the condition the regression coefficients come from and a string) and increase (which is the statistic of interest (Beta X Prevalence X 100))
tempname boot_results
postfile `boot_results' str27 condition increase using bootstrapping_results, replace

* Create local of the 31 conditions we need to calculate increase for
local med_groups Abnormal_heart_rhythm Arthritis_and_other_joint_d Asthma_or_COPD Atherosclerotic_vascular_di Back_pain Blindness Blood_disorder Cancer Chronic_pain Connective_tissue_disorders Deafness Dementia Developmental_disorder Diabetes_and_obesity Fibromyalgia_and_neuropathi HIV_and_other_infectious_di Inflammatory_bowel_disease_ Kidney_or_Bladder_Disease MSK_injuries_and_limb_defor Mental_Illness Migraine Neck_pain Other Other_Lung_Disease Other_Neurologic_Disorder Other_heart_or_circulatory_ Rheumatologic_Disease SUD_and_related_complicatio Spinal_cord_injury Structural_Heart_Disease 

*Set random number seed
set seed 082094


forvalues b = 1/2000 {
	* Preserve data to restore to at the end of each loop and resample from
	preserve 
	
	* Sample with replacement form dataset
	bsample
	
	* Run analysis
	svy: reg num_limit $med_groups age35_49 age50_64 age65 female	
	
	* add variable name and increase in functional limitations to the postfile for 31 conditions
	foreach var of local med_groups{
		qui sum `var' [aw=weight]
		post `boot_results' ("`var'") ((_b[`var'])*(r(mean))*100)
	}
	restore
}

postclose `boot_results'

use bootstrapping_results , clear

*Drop zero results because they were omitted from the regression after resampling 
drop if increase == 0
collapse (sd)  boot_se = increase , by(condition)

tempfile boot_se
save `boot_se'

* Call regression results from excel sheet made above 
cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"
import excel "Papers\Burdens of Functional Limitations\Exhibit 4\med_condition_coefficients.xlsx", cellrange(A1:G31) firstrow clear

* Merge in bootstrapping results 
merge 1:1 condition using `boot_se'
drop _merge
gen boot_z = increase/boot_se
gen boot_p = 2*(normal(-abs(boot_z)))

****************** Prepare table for output **********************
gsort -increase 
gen rank = _n
keep if rank < 11


gen coeff_rnd = string(round(coeff, 0.01), "%9.2f") 
replace coeff_rnd = coeff_rnd + "*" if coeff_p < 0.10 & coeff_p >= 0.05
replace coeff_rnd = coeff_rnd + "**" if coeff_p < 0.05 & coeff_p >= 0.01
replace coeff_rnd = coeff_rnd + "***" if coeff_p < 0.01

gen increase_rnd = string(round(increase, 0.01), "%9.2f") 

replace increase_rnd = increase_rnd + "*" if boot_p < 0.10 & boot_p >= 0.05
replace increase_rnd = increase_rnd + "**" if boot_p < 0.05 & boot_p >= 0.01
replace increase_rnd = increase_rnd + "***" if boot_p < 0.01

gen prevalence_rnd = string(round(prevalence, 0.001), "%9.3f") 

gen coeff_se_rnd = string(round(coeff_se, 0.01), "%9.2f")
replace coeff_se_rnd = "(" + coeff_se_rnd + ")" 

gen prevalence_se_rnd = string(round(prevalence_se, 0.001), "%9.3f") 
replace prevalence_se_rnd = "(" + prevalence_se_rnd + ")"

gen boot_se_rnd = string(round(boot_se, 0.01), "%9.2f")
replace boot_se_rnd = "(" + boot_se_rnd + ")" 

keep condition coeff_rnd coeff_se_rnd prevalence_rnd prevalence_se_rnd increase_rnd boot_se_rnd rank

rename coeff_rnd coeff1
rename coeff_se_rnd coeff2
rename prevalence_rnd prevalence1
rename prevalence_se_rnd prevalence2
rename increase_rnd increase1
rename boot_se_rnd increase2

reshape long coeff prevalence increase , i(condition) j(se_ind)
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
label variable prevalence "Prevalence of Medical Condition"
label variable increase "Increase in Number of Functional Limitations X Prevalence of Medical Condition X 100"

* Export to excel- After exporting to Excel, some additional formatting is doen within excel and word to adjust the text etc.
export excel using "Papers\Burdens of Functional Limitations\Exhibit 4\exhibit_4", replace firstrow(varlabels)


************* Get summary stats of correlation matrix for supplementary info ******************

* Before importing this excel workbook- resave the previously exported .csv as a .xlsx
import excel "Papers\Burdens of Functional Limitations\Appendix\correlation_matrix.xlsx", sheet("correlation_matrix") cellrange(A3:AE33) firstrow clear

* Rename all variables to reshape on a common prefix
foreach var of varlist _all{
	rename `var' v_`var'
}

*Reshape to a single column of correlation coefficients
rename v_A variable1
reshape long v_, i(variable1) j(variable2) string
drop if v_ == "1" | v_ == ""

* Create varaible of the two medical condition names together
replace variable1 = substr(variable1, 1, 10)
replace variable2 = substr(variable2, 1, 10)
gen limitations = variable1  + "_and_" + variable2

drop variable1 variable2
rename v_ corr_coeff

destring corr_coeff , replace

* Sort the dataset based on corr_coeff
sort corr_coeff

* Calculate summary statistics and store them in macros
summarize corr_coeff, detail
local min = r(min)
local p25 = r(p25)
local median = r(p50)
local p75 = r(p75)
local max = r(max)

* Create a temporary Excel file for summary statistics
putexcel set "Papers\Burdens of Functional Limitations\Appendix\summary_stats_correlation_matrix", replace
putexcel A1=("Label") B1=("corr_coeff")

* Write summary statistics to the Excel file
putexcel A2=("Min") B2=(`min')
putexcel A3=("25th Percentile") B3=(`p25')
putexcel A4=("Median") B4=(`median')
putexcel A5=("75th Percentile") B5=(`p75')
putexcel A6=("Max") B6=(`max')

* Create a temporary dataset to store limitations
tempfile limitations_data
save `limitations_data', replace


* Merge limitations data with summary statistics
import excel "Papers\Burdens of Functional Limitations\Appendix\summary_stats_correlation_matrix", firstrow clear
joinby corr_coeff using `limitations_data'

* Save summary stats of correlation coffiients 
export excel using "Papers\Burdens of Functional Limitations\Appendix\exhibit_s5_corr_summ", firstrow(variables) replace

* Export full table fo regression results for supplementary info Table S3
* Reset working directory to where bootstrapping data is 
cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity\Data\HFCS\clean_data\interim"

use bootstrapping_results , clear

*There are zero results in here... I think they should be dropped because they were omitted from the regression after resampling 
drop if increase == 0
collapse (sd)  boot_se = increase , by(condition)

tempfile boot_se
save `boot_se'

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"
import excel "Papers\Burdens of Functional Limitations\Exhibit 4\med_condition_coefficients.xlsx", cellrange(A1:J31) firstrow clear

merge 1:1 condition using `boot_se'
drop _merge
gen boot_z = increase/boot_se
gen boot_p = 2*(normal(-abs(boot_z)))

****************** Prepare table for output **********************
gsort -increase 
gen rank = _n


gen coeff_nc_rnd = string(round(coeff_nocontrols, 0.01), "%9.2f") 
replace coeff_nc_rnd = coeff_nc_rnd + "*" if coeff_p_nocontrols < 0.10 & coeff_p_nocontrols >= 0.05
replace coeff_nc_rnd = coeff_nc_rnd + "**" if coeff_p_nocontrols < 0.05 & coeff_p_nocontrols >= 0.01
replace coeff_nc_rnd = coeff_nc_rnd + "***" if coeff_p_nocontrols < 0.01

gen coeff_rnd = string(round(coeff, 0.01), "%9.2f") 
replace coeff_rnd = coeff_rnd + "*" if coeff_p < 0.10 & coeff_p >= 0.05
replace coeff_rnd = coeff_rnd + "**" if coeff_p < 0.05 & coeff_p >= 0.01
replace coeff_rnd = coeff_rnd + "***" if coeff_p < 0.01

gen increase_rnd = string(round(increase, 0.01), "%9.2f") 
replace increase_rnd = increase_rnd + "*" if boot_p < 0.10 & boot_p >= 0.05
replace increase_rnd = increase_rnd + "**" if boot_p < 0.05 & boot_p >= 0.01
replace increase_rnd = increase_rnd + "***" if boot_p < 0.01

gen prevalence_rnd = string(round(prevalence, 0.001), "%9.3f") 

gen coeff_se_nc_rnd = string(round(coeff_se_nocontrols, 0.01), "%9.2f")
replace coeff_se_nc_rnd = "(" + coeff_se_nc_rnd + ")" 

gen coeff_se_rnd = string(round(coeff_se, 0.01), "%9.2f")
replace coeff_se_rnd = "(" + coeff_se_rnd + ")" 

gen prevalence_se_rnd = string(round(prevalence_se, 0.001), "%9.3f") 
replace prevalence_se_rnd = "(" + prevalence_se_rnd + ")"

gen boot_se_rnd = string(round(boot_se, 0.01), "%9.2f")
replace boot_se_rnd = "(" + boot_se_rnd + ")" 

keep condition coeff_nc_rnd coeff_se_nc_rnd coeff_rnd coeff_se_rnd prevalence_rnd prevalence_se_rnd increase_rnd boot_se_rnd rank

rename coeff_rnd coeff1
rename coeff_se_rnd coeff2
rename prevalence_rnd prevalence1
rename prevalence_se_rnd prevalence2
rename increase_rnd increase1
rename boot_se_rnd increase2
rename coeff_nc_rnd coeff_nc1
rename coeff_se_nc_rnd coeff_nc2

reshape long coeff_nc coeff prevalence increase , i(condition) j(se_ind)
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
replace condition = "Musculoskeletal (MSK) injuries and limb deformities and burns" if condition == "MSK injuries and limb defor"
replace condition = "Inflammatory bowel disease and other gastrointestinal (GI) disorders" if condition == "Inflammatory bowel disease "
replace condition = "Atherosclerotic vascular disease" if condition == "Atherosclerotic vascular di"
replace condition = "HIV and other infectious diseases" if condition == "HIV and other infectious di"
replace condition = "Other heart or circulatory disorder" if condition == "Other heart or circulatory "

label variable condition "Medical Condition"
label variable coeff_nc "No Controls"
label variable coeff "Increase in Number of Functional Limitations"
label variable prevalence "Prevalence of Medical Condition"
label variable increase "Increase in Number of Functional Limitations X Prevalence of Medical Condition X 100"

* After exporting to Excel, some additional formatting is done within excel and word to adjust the text etc.
export excel using "Papers\Burdens of Functional Limitations\Appendix\exhibit_s3", replace firstrow(varlabels)
