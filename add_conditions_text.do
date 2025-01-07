* HFCS 
* Author: Michael Jetupphasuk (Updated by Hailey Clark) 
* Purpose: Update standardized medical conditions (Q1 variables) with free text information 
* Must have already run freetext_conditions_clean.R to produce test.csv 

*==================================================================================================

* PREPARATION

* cd "C:/Users/clark/Dropbox (HMS)/Medical Conditions Affecting Work Capacity"

* load main data 
use "Data/HFCS/clean_data/HFCS_CLEAN.dta", clear

* stash it
preserve

* load in imputed conditions data
import delimited using "Data/HFCS/clean_data/interim/test.csv", varnames(1) case(preserve) clear

* stash Q1 variable names
ds Q1*
local stsh_vars = "`r(varlist)'"

* rename variable names to indicate new
foreach v in `stsh_vars' {
	rename `v' `v'_new
}

* stash it
tempfile stsh
save `stsh', replace

* go back to main
restore

* duplicate and rename the Q1 vars to old
foreach v in `stsh_vars' {
	clonevar `v'_old = `v'
}

* merge in new variables
merge 1:1 prim_key using `stsh', nogen

* impute
foreach v in `stsh_vars' {
	replace `v' = 1 if `v'_new==1
	drop `v'_new
}

* Save updated version of clean data 
save "Data/HFCS/clean_data/HFCS_CLEAN.dta", replace 

