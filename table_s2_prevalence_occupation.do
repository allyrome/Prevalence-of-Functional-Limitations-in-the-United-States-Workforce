* Exhibit 2- Prevalence of any limitation in functional domain
* Author: Alexandra Rome
* Purpose: 
* 	Find prevalence of any limitation within the 16 functional domains and plot
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

* Drop observations for hand preference, it is not a limitation and therefore does not belong to a functional domain 
drop if missing(Functional_Group)

* Take the maximum value within each functional group to create an indicator for if there is any limitation in that group: binary_value
* Take the mean value within each functional group to get the standardized prevalence
 collapse (max) value essential Teleworkable, by(prim_key Functional_Group weight)

rename Teleworkable teleworkable
gen nonessential = (essential == 0)
gen nonteleworkable = (teleworkable == 0)
 
* Survey Set the data
svyset prim_key [pw=weight], strata(Functional_Group)

* Save collapsed data in an iterim folder to call at the top of a loop
save "Data\HFCS\clean_data\interim\hfcs_recodes_collapse.dta" , replace

* Create local of indicators for each functional group
levelsof Functional_Group, local(groups)
local conditions essential nonessential teleworkable nonteleworkable

* Create empty dataset with 1 variable "Functional_Group" to save as a tempfile and append to each loop
clear
gen Functional_Group = ""
tempfile results
save `results' , replace

* Find prevalence of limitations in each functional group with confidence intervals for output and sd and n for t-tests

foreach g of local groups {
	
	use "Data\HFCS\clean_data\interim\hfcs_recodes_collapse.dta" , clear
	
	keep if Functional_Group == "`g'"
	
	foreach subset of local conditions{
		svy, subpop(if value<. & `subset' == 1): mean value
		matrix b = r(table)
	
		gen prevalence_`subset' = b[1,1]
		gen lower_`subset' = b[5,1]
		gen upper_`subset' = b[6,1]
		
		estat sd
		matrix a =r(sd)
		gen sd_`subset' = a[1,1]
		
		count if value < . & `subset' == 1
		gen n_`subset' = r(N)
	}
	
	collapse (first) prevalence_essential upper_essential lower_essential sd_essential n_essential prevalence_nonessential upper_nonessential lower_nonessential sd_nonessential n_nonessential prevalence_teleworkable upper_teleworkable lower_teleworkable  sd_teleworkable n_teleworkable prevalence_nonteleworkable upper_nonteleworkable lower_nonteleworkable sd_nonteleworkable n_nonteleworkable, by(Functional_Group)
	
	append using `results'
	
	save `results' , replace

}


use `results', clear

******* Run t-tests for essential vs. non-essential and teleworkable vs. non-teleworkable

* Create a temporary file to hold variable names and significance stars
tempname starsfile
postfile `starsfile' str45 Functional_Group str5 stars_ess str5 stars_tel using "Code\paper1_AR\ttest_results_with_starss2.dta", replace

levelsof Functional_Group, local(groups)
* Loop through each Functional_Group
foreach group of local groups {

    preserve

    * Filter data for the current Functional_Group
    keep if Functional_Group == "`group'"
    
    // Get values for essential group
    local prevalence_essential = prevalence_essential
    local sd_essential = sd_essential 
    local n_essential = n_essential 

    // Get values for non-essential group
    local prevalence_nonessential = prevalence_nonessential 
    local sd_nonessential = sd_nonessential 
    local n_nonessential = n_nonessential 

    ttesti `n_essential' `prevalence_essential' `sd_essential' `n_nonessential' `prevalence_nonessential' `sd_nonessential'
	
	* Capture p-value from ttest
    local pvalue_ess = r(p)

    * Determine significance stars
    local star_ess = ""
    if `pvalue_ess' < 0.01 {
        local star_ess = "***"
    }
    else if `pvalue_ess' < 0.05 {
        local star_ess = "**"
    }
    else if `pvalue_ess' < 0.1 {
        local star_ess = "*"
    }
	
	// Get values for essential group
    local prevalence_teleworkable = prevalence_teleworkable
    local sd_teleworkable = sd_teleworkable
    local n_teleworkable = n_teleworkable

    // Get values for non-essential group
    local prevalence_nonteleworkable= prevalence_nonteleworkable
    local sd_nonteleworkable = sd_nonteleworkable
    local n_nonteleworkable = n_nonteleworkable

    ttesti `n_teleworkable' `prevalence_teleworkable' `sd_teleworkable' `n_nonteleworkable' `prevalence_nonteleworkable' `sd_nonteleworkable'
	
	* Capture p-value from ttest
    local pvalue_tel = r(p)

    * Determine significance stars
    local star_tel = ""
    if `pvalue_tel' < 0.01 {
        local star_tel = "***"
    }
    else if `pvalue_tel' < 0.05 {
        local star_tel = "**"
    }
    else if `pvalue_tel' < 0.1 {
        local star_tel = "*"
    }
	
	 * Post variable name and stars to the postfile
    post `starsfile' ("`group'") ("`star_ess'") ("`star_tel'")
	
	
	restore
}

* Close the postfile
postclose `starsfile'

* Merge significance stars from t-tests to prevalence estimates
merge 1:1 Functional_Group using "Code\paper1_AR\ttest_results_with_starss2.dta"

* Local of estimates to round
local vars  prevalence_essential upper_essential lower_essential prevalence_nonessential upper_nonessential lower_nonessential prevalence_teleworkable upper_teleworkable lower_teleworkable prevalence_nonteleworkable upper_nonteleworkable lower_nonteleworkable

* Loop over each variable in the list and apply the rounding
foreach var of local vars {
    replace `var' = round(`var', 0.001)
}

* Create formatted means with confidence intervals and significance stars to export
gen mean_ci_ess = string(prevalence_essential, "%9.3f") + stars_ess + " (" + string(lower_essential, "%9.3f") + "-" + string(upper_essential, "%9.3f") + ")"
gen mean_ci_noness = string(prevalence_nonessential, "%9.3f") + " (" + string(lower_nonessential, "%9.3f") + "-" + string(upper_nonessential, "%9.3f") + ")"
gen mean_ci_tele = string(prevalence_teleworkable, "%9.3f") + stars_tel + " (" + string(lower_teleworkable, "%9.3f") + "-" + string(upper_teleworkable, "%9.3f") + ")"
gen mean_ci_nontele = string(prevalence_nonteleworkable, "%9.3f") + " (" + string(lower_nonteleworkable, "%9.3f") + "-" + string(upper_nonteleworkable, "%9.3f") + ")"


export excel Functional_Group mean_ci_ess mean_ci_noness mean_ci_tele mean_ci_nontele using "Papers/Burdens of Functional Limitations/Appendix/prevalence_by_occupation", replace firstrow(variables)


