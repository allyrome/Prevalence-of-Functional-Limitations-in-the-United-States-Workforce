
cd "C:\Users\arome\HMS Dropbox\Alexandra Rome\Medical Conditions Affecting Work Capacity" 

use "Data\HFCS\clean_data\hfcs_recodes.dta" , clear

merge m:1 Question using "Papers\Burdens of Functional Limitations\Appendix\restricted_limitations\job_profiles_limitations_education"

* Replace prevalence with 1 for job profile items not in algorithm
replace college_degree = 1 if _merge == 1
replace no_college_degree = 1 if _merge == 1

* Generate indicators for the 56 limitations used in the matching algorithm
gen college_degree56 = 0
gen no_college_degree56 = 0
replace college_degree56 = college_degree if _merge == 3
replace no_college_degree56 = no_college_degree if _merge == 3

* Calculate mean prevalence for each education level (college/no college) across limitations
	preserve 

	collapse (first) college_degree no_college_degree, by(Question)
	sum college_degree
	local prevalence_mean_college = r(mean)
	sum no_college_degree
	local prevalence_mean_no_college = r(mean)

	restore

* Generate weighted prevalence for each education group based on mean prevalence
replace college_degree = college_degree / `prevalence_mean_college'
replace no_college_degree = no_college_degree / `prevalence_mean_no_college'


* Repeat prevalence calculations for the 56-limitations subset
	preserve 
	
	keep if college_degree56 > 0 

	collapse (first) college_degree56 no_college_degree56, by(Question)
	sum college_degree56
	local prevalence_mean_college56 = r(mean)
	sum no_college_degree56
	local prevalence_mean_no_college56 = r(mean)

	restore

* Generate weighted prevalence variables for 56 limitations subset
replace college_degree56 = college_degree56 / `prevalence_mean_college56'
replace no_college_degree56 = no_college_degree56 / `prevalence_mean_no_college56'


collapse (first) college_degree no_college_degree college_degree56 no_college_degree56 , by(Question)

preserve 

// Collapse the dataset to compute summary statistics
collapse (mean) college_degree_mean = college_degree no_college_degree_mean = no_college_degree ///
         (min) college_degree_min = college_degree no_college_degree_min = no_college_degree ///
         (max) college_degree_max = college_degree no_college_degree_max = no_college_degree ///
         (p50) college_degree_median = college_degree no_college_degree_median = no_college_degree ///
         (p10) college_degree_p10 = college_degree no_college_degree_p10 = no_college_degree ///
         (p25) college_degree_p25 = college_degree no_college_degree_p25 = no_college_degree ///
         (p75) college_degree_p75 = college_degree no_college_degree_p75 = no_college_degree ///
         (p90) college_degree_p90 = college_degree no_college_degree_p90 = no_college_degree 


gen id = 1

reshape long college_degree_ no_college_degree_ , i(id) j(Statistic) string

drop id

tempfile 97limits
save `97limits'

restore 


keep if college_degree56 > 0

// Collapse the dataset to compute summary statistics
collapse (mean) college_degree56_mean = college_degree56 no_college_degree56_mean = no_college_degree56 ///
         (min) college_degree56_min = college_degree56 no_college_degree56_min = no_college_degree56 ///
         (max) college_degree56_max = college_degree56 no_college_degree56_max = no_college_degree56 ///
         (p50) college_degree56_median = college_degree56 no_college_degree56_median = no_college_degree56 ///
         (p10) college_degree56_p10 = college_degree56 no_college_degree56_p10 = no_college_degree56 ///
         (p25) college_degree56_p25 = college_degree56 no_college_degree56_p25 = no_college_degree56 ///
         (p75) college_degree56_p75 = college_degree56 no_college_degree56_p75 = no_college_degree56 ///
         (p90) college_degree56_p90 = college_degree56 no_college_degree56_p90 = no_college_degree56 


gen id = 1

reshape long college_degree56_ no_college_degree56_ , i(id) j(Statistic) string

drop id

merge 1:1 Statistic using `97limits' , nogen 

export excel using "C:\Users\arome\HMS Dropbox\Alexandra Rome\Medical Conditions Affecting Work Capacity\Papers\Burdens of Functional Limitations\Appendix\exhibit_s8_weight_distribution.xlsx", firstrow(variables) replace



