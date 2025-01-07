* Table 1 - Decsriptive Statistics for the HFCS analysis sample
* Author: Alexandra Rome
* Purpose: 
* 	Find unweighted and weighted statitcis of the HFCS sample, as well as the weighted statistics of the 2018 CPS popualtion for comparison and output table
*	Run t-tests between the weighted HFCS sample and the CPS sample and add resulting significance stars 

*==================================================================================================

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity" 

* Table 1: Sample Summary Statistics

******* Unweighted Descriptive Statitics *********

* Load recoded HFCS data at the respondent/question level (257,729 observations = 2657 repsondents x 97 possible limitations) to create total number of limitations variable and inlcudes teleworkable/essential identifiers to merge to wide HFCS data at the respondent level 
use "Data\HFCS\clean_data\hfcs_recodes.dta" , clear

destring isco_1dig, replace

***** Create number of limitations variable *****

* Temporarily impute no limitation if did not pass screener
replace value = 0 if pass_screener == 0
drop if missing(value)

* Create interim value that;
*	= 0 if respondent is normal or slightly limited 
*	= 1 if respondent is limited
*	= 2 if they are very limited

gen value2 = 0
replace value2 = 1 if value == 2
replace value2 = 2 if value == 3
bys prim_key: egen num_limit = total(value2>0)

* Collapse to a single row per individual with total number of limitations and teleworkable and essential identifiers and merge to wide HFCS data 
collapse (max) num_limit essential Teleworkable isco_1dig, by(prim_key)
merge 1:1 prim_key using "Data\HFCS\clean_data\HFCS_CLEAN.dta"

* Keep if working and passed screener 
keep if working == 1
keep if pass_screener == 1

* Create male identifier
gen male = (female == 0)

* Create age groups 
gen age_22_34 = (AGE<35)
gen age_35_49 = (AGE>=35 & AGE<50)
gen age_50_64 = (AGE>=50 & AGE<65)
gen age_65_plus = (AGE>=65)

* Create identifier for no college
gen no_college = (college == 0)

* Create Work variables
gen full_time = (Q83>=35)
gen part_time = (Q83<35)

* Create non-essential and non-teleworkable 
gen non_essential = (essential == 0)
gen non_tele = (Teleworkable == 0)

* Create Health Outcome variables
gen one_med_cond = (num_health_problems >= 1)
gen one_func_limit = (num_limit >= 1)

* Add super-sector information to lim_clpsed_screener, 1: goods-producing, 2: service-producing
gen goods =  (Q81<= 5 & Q81 != 3)
gen service = (Q81 > 5 | Q81 == 3)

tab isco_1dig, gen(isco_1dig)

rename isco_1dig2 managers
rename isco_1dig3 professionals
rename isco_1dig4 technicians
rename isco_1dig5 clerical
rename isco_1dig6 service_sales
rename isco_1dig8 craft
rename isco_1dig9 plant
rename isco_1dig10 elementary

* Unweighted Means 
collapse (mean) male female age_22_34 age_35_49 age_50_64 age_65_plus college no_college full_time managers professionals technicians clerical service_sales craft plant elementary goods service essential non_essential Teleworkable non_tele part_time one_med_cond one_func_limit num_limit (median) num_limit_med = num_limit

* Transpose from wide to long with variable names in rows
xpose , clear varname
rename v1 unweighted

tempfile unwtd
save `unwtd'

******* Weighted Descriptive Statitics *********

* Same process as above, but using weights when collapsing to find the mean

* Load recoded HFCS data at the respondent/question level (257,729 observations = 2657 repsondents x 97 possible limitations) to create total number of limitations variable and inlcudes teleworkable/essential identifiers to merge to wide HFCS data at the respondent level 
use "Data\HFCS\clean_data\hfcs_recodes.dta" , clear

destring isco_1dig, replace

* temporarily impute no limitation if did not pass screener
replace value = 0 if pass_screener == 0
drop if missing(value)

* Create interim value that;
*	= 0 if respondent is normal or slightly limited 
*	= 1 if respondent is limited
*	= 2 if they are very limited

gen value2 = 0
replace value2 = 1 if value == 2
replace value2 = 2 if value == 3
bys prim_key: egen num_limit = total(value2>0)

* Collapse to a single row per individual with teleworkable and essential identifiers and merge to wide HFCS data 
collapse (max) num_limit essential Teleworkable isco_1dig, by(prim_key)
merge 1:1 prim_key using "Data\HFCS\clean_data\HFCS_CLEAN.dta"

* Keep if working and passed screener 
keep if working == 1
keep if pass_screener == 1

* Create male variable 
gen male = (female == 0)

* Create age groups 
gen age_22_34 = (AGE<35)
gen age_35_49 = (AGE>=35 & AGE<50)
gen age_50_64 = (AGE>=50 & AGE<65)
gen age_65_plus = (AGE>=65)

* Create no college
gen no_college = (college == 0)

* Create Work variables
gen full_time = (Q83>=35)
gen part_time = (Q83<35)

* Create non-essential and non-teleworkable 
gen non_essential = (essential == 0)
gen non_tele = (Teleworkable == 0)

* Create Health Outcome variables
gen one_med_cond = (num_health_problems >= 1)
gen one_func_limit = (num_limit >= 1)

* Add super-sector information to lim_clpsed_screener, 1: goods-producing, 2: service-producing
gen goods =  (Q81<= 5 & Q81 != 3)
gen service = (Q81 > 5 | Q81 == 3)

tab isco_1dig, gen(isco_1dig)

rename isco_1dig2 managers
rename isco_1dig3 professionals
rename isco_1dig4 technicians
rename isco_1dig5 clerical
rename isco_1dig6 service_sales
rename isco_1dig8 craft
rename isco_1dig9 plant
rename isco_1dig10 elementary


* Save data for ttest's
tempfile hfcs
save `hfcs'

* Weighted Means 
collapse (mean) male female age_22_34 age_35_49 age_50_64 age_65_plus college no_college full_time managers professionals technicians clerical service_sales craft plant elementary goods service essential non_essential Teleworkable non_tele part_time one_med_cond one_func_limit num_limit (median) num_limit_med = num_limit [aw=weight]

xpose , clear varname
rename v1 weighted

merge 1:1 _varname using `unwtd'
drop _merge

tempfile table1 
save `table1'

******* 2018 CPS Working Population *********

use "Data\CPS\cps_2018_22+_working_demo_collapse.dta" , clear
rename ba college
rename noba no_college
rename work_35hrs full_time
rename less_35 part_time 
rename occ_cat1 managers
rename occ_cat2 professionals
rename occ_cat3 technicians
rename occ_cat4 clerical
rename occ_cat5 service_sales
rename occ_cat7 craft
rename occ_cat8 plant
rename occ_cat9 elementary
rename supersector1 goods 
rename supersector2 service

xpose , clear varname
rename v1 cps

* Merge CPS population stats to unweighted and weighted stats 
merge 1:1 _varname using `table1'
drop if _merge == 1
drop _merge

order _varname unweighted weighted cps

* Create ordering of statistics
gen varname_num = .
replace varname_num = 1 if _varname == "male"
replace varname_num = 2 if _varname == "female"
replace varname_num = 3 if _varname == "age_22_34"
replace varname_num = 4 if _varname == "age_35_49"
replace varname_num = 5 if _varname == "age_50_64"
replace varname_num = 6 if _varname == "age_65_plus"
replace varname_num = 7 if _varname == "college"
replace varname_num = 8 if _varname == "no_college"
replace varname_num = 9 if _varname == "full_time"
replace varname_num = 10 if _varname == "part_time"
replace varname_num = 11 if _varname == "managers"
replace varname_num = 12 if _varname == "professionals"
replace varname_num = 13 if _varname == "technicians"
replace varname_num = 14 if _varname == "clerical"
replace varname_num = 15 if _varname == "service_sales"
replace varname_num = 16 if _varname == "craft"
replace varname_num = 17 if _varname == "plant"
replace varname_num = 18 if _varname == "elementary"
replace varname_num = 19 if _varname == "goods"
replace varname_num = 20 if _varname == "service"
replace varname_num = 21 if _varname == "essential"
replace varname_num = 22 if _varname == "non_essential"
replace varname_num = 23 if _varname == "Teleworkable"
replace varname_num = 24 if _varname == "non_tele"
replace varname_num = 25 if _varname == "one_med_cond"
replace varname_num = 26 if _varname == "one_func_limit"
replace varname_num = 27 if _varname == "num_limit"
replace varname_num = 28 if _varname == "num_limit_med"

* Label variuable ordering 
label define var_titles 1 "Male" 2 "Female" 3 "22-34" 4 "35-49" 5 "50-64" 6 "65+" 7 "BA" 8 "No BA" 9 "Full time" 10 "Part time" 11 "Managers" 12 "Professionals" 13 "Technicians and associate professionals" 14 "Clerical support workers" 15 "Services and sales workers" 16 "Craft and related trade workers" 17 "Plant and machine operators and assemblers" 18 "Elementary occupations" 19 "Goods-producing" 20 "Service-producing" 21 "Essential" 22 "Non-essential" 23 "Teleworkable" 24 "Non-teleworkable"  25 "At least one medical condition" 26 "At least one functional limitation" 27 "Mean number of functional limitations (Max 97)" 28 "Median number of functional limitations"
label values varname_num var_titles

* Change to percentages
replace unweighted = unweighted * 100 if _varname != "num_limit" & _varname != "num_limit_med"
replace weighted = weighted * 100 if _varname != "num_limit" & _varname != "num_limit_med"
replace cps = cps * 100 if _varname != "num_limit" & _varname != "num_limit_med"


** Output to .csv file **
estpost tabstat unweighted weighted cps, by(varname_num)
esttab using "Papers\Burdens of Functional Limitations\Exhibit 1\summary statistics.csv", replace ///
	refcat(1 "Sex" 3 "Age" 7 "Education" 9 "Hours of Work" 11 "Occupation" 19 "Industry" 21 "Work" 25 "Health Outcomes", nolabel) ///
	cells("unweighted(fmt(%9.1f)) weighted(fmt(%9.1f)) cps(fmt(%9.1f))") ///
	compress nonumber nomtitle nonote noobs ///
	varlabels(`e(labels)') ///
	collabels("Mean (unweighted)" "Mean (weighted)" "2018 CPS Working Population") ///
	drop(Total) varwidth(45)
	
	

	
* Run t-tests for differences in weighted sample & CPS reference sample for all variables in Table 1

/*
Steps:
	1. Use uncollapsed datasets for HFCS and CPS, then collapse to find the mean, sd, and n of each variable
	2. Merge those datasets together in a wide format so there is only one row that has the means, sd, n's for HFCS (group 1) and CPS (group 2)
	3. Run a loop that displays ttesti for each variable, using the 6 stats present in the wide data
*/


* Find mean, sd and and n for HFCS group
use `hfcs' , clear

* Collapse data for HFCS
collapse (mean) male_mean_1=male female_mean_1=female age_22_34_mean_1=age_22_34 age_35_49_mean_1=age_35_49 age_50_64_mean_1=age_50_64 age_65_plus_mean_1=age_65_plus college_mean_1=college no_college_mean_1=no_college full_time_mean_1=full_time managers_mean_1=managers professionals_mean_1=professionals technicians_mean_1=technicians clerical_mean_1=clerical service_sales_mean_1=service_sales craft_mean_1=craft plant_mean_1=plant elementary_mean_1=elementary goods_mean_1=goods service_mean_1=service essential_mean_1=essential non_essential_mean_1=non_essential Teleworkable_mean_1=Teleworkable non_tele_mean_1=non_tele part_time_mean_1=part_time one_med_cond_mean_1=one_med_cond one_func_limit_mean_1=one_func_limit num_limit_mean_1=num_limit ///
         (sd) male_sd_1=male female_sd_1=female age_22_34_sd_1=age_22_34 age_35_49_sd_1=age_35_49 age_50_64_sd_1=age_50_64 age_65_plus_sd_1=age_65_plus  college_sd_1=college no_college_sd_1=no_college full_time_sd_1=full_time managers_sd_1=managers professionals_sd_1=professionals   technicians_sd_1=technicians clerical_sd_1=clerical service_sales_sd_1=service_sales craft_sd_1=craft plant_sd_1=plant elementary_sd_1=elementary  goods_sd_1=goods service_sd_1=service essential_sd_1=essential non_essential_sd_1=non_essential Teleworkable_sd_1=Teleworkable  non_tele_sd_1=non_tele part_time_sd_1=part_time one_med_cond_sd_1=one_med_cond one_func_limit_sd_1=one_func_limit num_limit_sd_1=num_limit  ///
		 (count) male_n_1=male female_n_1=female age_22_34_n_1=age_22_34 age_35_49_n_1=age_35_49 age_50_64_n_1=age_50_64 age_65_plus_n_1=age_65_plus college_n_1=college no_college_n_1=no_college full_time_n_1=full_time managers_n_1=managers professionals_n_1=professionals technicians_n_1=technicians clerical_n_1=clerical service_sales_n_1=service_sales craft_n_1=craft plant_n_1=plant elementary_n_1=elementary goods_n_1=goods service_n_1=service essential_n_1=essential non_essential_n_1=non_essential Teleworkable_n_1=Teleworkable non_tele_n_1=non_tele part_time_n_1=part_time one_med_cond_n_1=one_med_cond one_func_limit_n_1=one_func_limit num_limit_n_1=num_limit [aw=weight]
		 
gen id = 1

* Save the collapsed data for HFCS
tempfile hfcs_means
save `hfcs_means'

use "Data\CPS\cps_2018_22+_working_demo.dta" , clear

rename ba college
rename noba no_college
rename work_35hrs full_time
rename less_35 part_time 
rename occ_cat1 managers
rename occ_cat2 professionals
rename occ_cat3 technicians
rename occ_cat4 clerical
rename occ_cat5 service_sales
rename occ_cat7 craft
rename occ_cat8 plant
rename occ_cat9 elementary
rename supersector1 goods 
rename supersector2 service

* Collapse dataset for CPS
collapse (mean) male_mean_2=male female_mean_2=female age_22_34_mean_2=age_22_34 age_35_49_mean_2=age_35_49 age_50_64_mean_2=age_50_64 age_65_plus_mean_2=age_65_plus college_mean_2=college no_college_mean_2=no_college full_time_mean_2=full_time managers_mean_2=managers professionals_mean_2=professionals technicians_mean_2=technicians clerical_mean_2=clerical service_sales_mean_2=service_sales craft_mean_2=craft plant_mean_2=plant elementary_mean_2=elementary goods_mean_2=goods service_mean_2=service essential_mean_2=essential non_essential_mean_2=non_essential Teleworkable_mean_2=Teleworkable non_tele_mean_2=non_tele part_time_mean_2=part_time  ///
         (sd) male_sd_2=male female_sd_2=female age_22_34_sd_2=age_22_34 age_35_49_sd_2=age_35_49 age_50_64_sd_2=age_50_64 age_65_plus_sd_2=age_65_plus college_sd_2=college no_college_sd_2=no_college full_time_sd_2=full_time managers_sd_2=managers professionals_sd_2=professionals  technicians_sd_2=technicians clerical_sd_2=clerical service_sales_sd_2=service_sales craft_sd_2=craft plant_sd_2=plant elementary_sd_2=elementary goods_sd_2=goods service_sd_2=service essential_sd_2=essential non_essential_sd_2=non_essential Teleworkable_sd_2=Teleworkable non_tele_sd_2=non_tele part_time_sd_2=part_time  ///
         (count) male_n_2=male female_n_2=female age_22_34_n_2=age_22_34 age_35_49_n_2=age_35_49 age_50_64_n_2=age_50_64 age_65_plus_n_2=age_65_plus college_n_2=college no_college_n_2=no_college full_time_n_2=full_time managers_n_2=managers professionals_n_2=professionals technicians_n_2=technicians clerical_n_2=clerical service_sales_n_2=service_sales craft_n_2=craft plant_n_2=plant elementary_n_2=elementary goods_n_2=goods service_n_2=service essential_n_2=essential non_essential_n_2=non_essential Teleworkable_n_2=Teleworkable non_tele_n_2=non_tele part_time_n_2=part_time [aw=wtfinl]
		 
gen id = 1

* Merge the two collapsed datasets
merge 1:1 id using `hfcs_means'

* Check the merge result and drop merge variable if needed
drop id _merge


* Define the variables you want to test
local vars "male female age_22_34 age_35_49 age_50_64 age_65_plus college no_college full_time managers professionals technicians clerical service_sales craft plant elementary goods service essential non_essential Teleworkable non_tele part_time"

* Create a temporary file to hold variable names and stars
tempname starsfile
postfile `starsfile' str20 varname str5 stars using "Code\paper1_AR\PNAS Final Files\ttest_results_with_stars.dta", replace

* Loop through each variable and run ttesti
foreach var in `vars' {
    local mean1 = `var'_mean_1
    local sd1 = `var'_sd_1
    local n1 = `var'_n_1
    local mean2 = `var'_mean_2
    local sd2 = `var'_sd_2
    local n2 = `var'_n_2

	dis "T-test for `var'"
    ttesti `n1' `mean1' `sd1' `n2' `mean2' `sd2'

    * Capture p-value from ttest
    local pvalue = r(p)

    * Determine significance stars
    local star = ""
    if `pvalue' < 0.01 {
        local star = "***"
    }
    else if `pvalue' < 0.05 {
        local star = "**"
    }
    else if `pvalue' < 0.1 {
        local star = "*"
    }

    * Post variable name and stars to the postfile
    post `starsfile' ("`var'") ("`star'")
}

* Close the postfile
postclose `starsfile'

* The results will now be saved in the file "ttest_results_with_stars.dta"
use "Code\paper1_AR\PNAS Final Files\ttest_results_with_stars.dta", clear

* Define the old and new values as two lists
local old_values "male female age_22_34 age_35_49 age_50_64 age_65_plus college no_college full_time part_time managers professionals technicians clerical service_sales craft plant elementary goods service essential non_essential Teleworkable non_tele"
local new_values "Male Female 22-34 35-49 50-64 65+ BA No_BA Full_time Part_time Managers Professionals Technicians_and_associate_professionals Clerical_support_workers Services_and_sales_workers Craft_and_related_trade_workers Plant_and_machine_operators_and_assemblers Elementary_occupations Goods-producing Service-producing Essential Non-essential Teleworkable Non-teleworkable"

* Loop through each old value and replace it with the new value
local i = 1
foreach old in `old_values' {
    local new : word `i' of `new_values'
    replace var = "`new'" if var == "`old'"
    local i = `i' + 1
}

rename varname v1
replace v1 = subinstr(v1, "_", " ", .)

tempfile stars
save `stars'

import delimited "Papers\Burdens of Functional Limitations\Exhibit 1\summary statistics.csv", delimiter(comma) bindquote(nobind) varnames(1) stripquote(yes) clear 

gen sort = _n

replace v1 = subinstr(v1, "=", "", .)
replace v1 = rtrim(v1)
replace meanunweighted = subinstr(meanunweighted, "=", "", .)
replace meanweighted = subinstr(meanweighted, "=", "", .)
replace v4 = subinstr(v4, "=", "", .)

merge 1:1 v1 using `stars'

replace meanweighted = meanweighted + stars

sort sort
drop sort stars _merge 
label var v1 ""
label var meanunweighted "Percentage (unweighted sample)(1)"
label var meanweighted "Percentage (weighted sample)(2)"
label var v4 "Percentage (2018 CPS Working Population)(3)"


* After exporting, some additional formatting is doen within excel and word to adjust the text etc.
export excel using "Papers\Burdens of Functional Limitations\Exhibit 1\summary_stats_stars", replace firstrow(varlabels)

