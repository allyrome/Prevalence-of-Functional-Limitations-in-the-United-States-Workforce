* Table S6 - Summary Stats from different weightings of limitations
* Author: Alexandra Rome
* Purpose: Create sum of totoal limitations per respondent with 4 different approaches
* 1. Raw sum of 97 totoal limitations
* 2. Weighted sum from 97 totoal limitations based on how often limitation is considered for job profiles
* 3. Raw sum of 56 totoal limitations included in matching algorithm
* 4. Weighted sum from 56 totoal limitations based on how often limitation is considered for job profiles

*==================================================================================================

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity" 

use "Data\HFCS\clean_data\hfcs_recodes.dta" , clear

* temporarily impute no limitation if did not pass screener
replace value = 0 if pass_screener == 0
drop if missing(value) /// This command ends up dropping respondent 11084165:1 here 

* Create interim value that;
*	= 0 if respondent is normal or slightly limited 
*	= 1 if repsondant is limited
*	= 2 if they are very limited

gen value2 = 0
replace value2 = 1 if value == 2
replace value2 = 1 if value == 3
bys prim_key: egen num_limit = total(value2>0)

* Create number of limitations variable that only totals from the 56 limitations used in the matching algorithm rather than the 97 total limitations 

merge m:1 Question using "Papers\Burdens of Functional Limitations\Appendix\restricted_limitations\job_profiles_limitations_education"

* Impute 100% for questions with conditions that cannot be standardized
replace college_degree = 1 if _merge == 1
replace no_college_degree = 1 if _merge == 1

gen college_degree56 = 0
gen no_college_degree56 = 0
replace college_degree56 = college_degree if _merge == 3
replace no_college_degree56 = no_college_degree if _merge == 3

	preserve 

	collapse (first) college_degree no_college_degree, by(Question)
	sum college_degree
	local prevalence_mean_college = r(mean)
	sum no_college_degree
	local prevalence_mean_no_college = r(mean)

	restore

gen wtd_college = college_degree / `prevalence_mean_college'
gen wtd_no_college = no_college_degree / `prevalence_mean_no_college'


	preserve 
	
	keep if college_degree56 > 0 

	collapse (first) college_degree56 no_college_degree56, by(Question)
	sum college_degree56
	local prevalence_mean_college56 = r(mean)
	sum no_college_degree56
	local prevalence_mean_no_college56 = r(mean)

	restore

gen wtd_college56 = college_degree56 / `prevalence_mean_college56'
gen wtd_no_college56 = no_college_degree56 / `prevalence_mean_no_college56'

gen wtd_prof_prevalence = .
replace wtd_prof_prevalence = wtd_college if ed_ba_or_more == 1
replace wtd_prof_prevalence = wtd_no_college if ed_ba_or_more == 0

gen wtd_prof_prevalence56 = .
replace wtd_prof_prevalence56 = wtd_college56 if ed_ba_or_more == 1
replace wtd_prof_prevalence56 = wtd_no_college56 if ed_ba_or_more == 0

gen value3 = 0 
replace value3 = value2 * wtd_prof_prevalence
bys prim_key: egen num_limit_wtd = sum(value3)

gen value4 = 0
replace value4 = value2 if _merge == 3
bys prim_key: egen num_limit56 = sum(value4)

gen value5 = value4 * wtd_prof_prevalence56
bys prim_key: egen num_limit_wtd56 = sum(value5)


* Collapse to a single row per individual with total number of limitations and teleworkable and essential identifiers and merge to wide HFCS data 
collapse (max) num_limit  num_limit_wtd num_limit56 num_limit_wtd56, by(prim_key)
merge 1:1 prim_key using "Data\HFCS\clean_data\HFCS_CLEAN.dta"

* Keep if working and passed screener 
keep if working == 1
keep if pass_screener == 1

* Create Health Outcome variables
gen one_func_limit = (num_limit >= 1)
gen one_func_limit56 = (num_limit56 >= 1)


* Unweighted Means 
collapse (mean) one_func_limit one_func_limit56 num_limit num_limit_wtd num_limit56 num_limit_wtd56 (median) num_limit_med = num_limit num_limit_wtd_med = num_limit_wtd num_limit56_med = num_limit56 num_limit_wtd56_med = num_limit_wtd56 [aw=weight]

* Transpose from wide to long with variable names in rows
xpose , clear varname
rename v1 weighted


* Create ordering of statistics
gen varname_num = .
replace varname_num = 1 if _varname == "one_func_limit"
replace varname_num = 2 if _varname == "num_limit"
replace varname_num = 3 if _varname == "num_limit_med"
replace varname_num = 4 if _varname == "num_limit_wtd"
replace varname_num = 5 if _varname == "num_limit_wtd_med"
replace varname_num = 6 if _varname == "one_func_limit56"
replace varname_num = 7 if _varname == "num_limit56"
replace varname_num = 8 if _varname == "num_limit56_med"
replace varname_num = 9 if _varname == "num_limit_wtd56"
replace varname_num = 10 if _varname == "num_limit_wtd56_med"


* Label variuable ordering 
label define var_titles 1 "At least one functional limitation (97)" 2 "Mean number of functional limitations (Max 97)" 3 "Median number of functional limitations (Max 97)" 4 "Mean number of weighted functional limitations (Max 97)" 5 "Median number of weighted functional limitations (Max 97)" 6 "At least one functional limitation (56)" 7 "Mean number of functional limitations (Max 56)" 8 "Median number of functional limitations (Max 56)" 9 "Mean number of weighted functional limitations (Max 56)" 10 "Median number of weighted functional limitations (Max 56)" 
label values varname_num var_titles

* Change to percentages
replace weighted = weighted * 100 if _varname == "one_func_limit" | _varname == "one_func_limit56"
drop _varname

** Output to .csv file **
export excel using "Papers\Burdens of Functional Limitations\Appendix\summary_stats_97_56.xlsx", firstrow(variables)

	
