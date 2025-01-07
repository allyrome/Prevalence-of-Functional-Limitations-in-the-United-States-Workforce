* HFCS - clean data
* Author: Michael Jetupphasuk
* Purpose: Merges hand-coded variables

*==================================================================================================

***************************************************************************************************
* Occupation data
***************************************************************************************************

* load occupation data
tempfile stsh1
tempfile stsh2

import delimited using "Data/HFCS/clean_data/FINAL_OCCUPATIONS.csv", varnames(1) case(preserve) clear
ds certainty_*
foreach v in `r(varlist)' {
	replace `v'="" if `v'=="NA"
	destring `v', replace
}
save `stsh1', replace

import excel using "Data/HFCS/clean_data/occupation_todo.xlsx", first case(preserve) clear
keep prim_key hand_assign certainty
replace hand_assign="" if hand_assign=="NA"
replace certainty="" if certainty=="NA"
destring certainty, replace
replace hand_assign = subinstr(hand_assign, "-", "", .)
replace hand_assign = subinstr(hand_assign, ".", "", .)
save `stsh2', replace

* load main data 
use "Data/HFCS/clean_data/HFCS_CLEAN.dta", clear

* merge in occupation coding
merge 1:1 prim_key using `stsh1'
drop if _merge==2
drop _merge
merge 1:1 prim_key using `stsh2'
drop _merge

* create variables for use
gen hand_assign_use = hand_assign_final
replace hand_assign_use = hand_assign if mi(hand_assign_use)

egen certainty_use = rowmean(certainty_mj certainty_dz) if mismatch==0
replace certainty_use = certainty_mismatch if mismatch==1
replace certainty_use = certainty if mi(mismatch)


***************************************************************************************************
* Disability questions
***************************************************************************************************

* see file "check_disability.xlsx" for source of these changes
replace Q89_7 = 0 if prim_key=="11044252:1"
replace Q89_8 = 1 if prim_key=="11044252:1"

replace Q89_7 = 0 if prim_key=="11094134:1"
replace Q89_8 = 1 if prim_key=="11094134:1"

replace Q89a_7 = 0 if prim_key=="14092019:1"
replace Q89a_3 = 1 if prim_key=="14092019:1"

replace Q89_7 = 0 if prim_key=="14092657:1"
replace Q89_8 = 1 if prim_key=="14092657:1"

replace Q89_7 = 0 if prim_key=="2051095:1"

replace Q89a_7 = 0 if prim_key=="2071032:1"
replace Q89a_5 = 1 if prim_key=="2071032:1"


***************************************************************************************************
* Insurance questions
***************************************************************************************************

* load in manual insurance file
preserve
import excel using "Data/HFCS/clean_data/interim/check_insurance_changed.xlsx", firstrow clear
drop TSCommentsonInsurance Q87_8_other
foreach v in Privateinsurancethroughemploy Privateinsurancethroughfamily Privateinsurancenotthroughe Medicare Medicaid VAHealthCare TRICARE Othernamely Q87_10 {
	replace `v' = "0" if `v'=="No (0)"
	replace `v' = "1" if `v'=="Yes (1)"
	destring `v', replace
}
tempfile stsh_ins
save `stsh_ins'
restore

* merge it in
merge 1:1 prim_key using `stsh_ins', nogen

* integrate changes
replace Q87_1 = Privateinsurancethroughemploy if !mi(Privateinsurancethroughemploy)
replace Q87_2 = Privateinsurancethroughfamily if !mi(Privateinsurancethroughfamily)
replace Q87_3 = Privateinsurancenotthroughe if !mi(Privateinsurancenotthroughe)
replace Q87_4 = Medicare if !mi(Medicare)
replace Q87_5 = Medicaid if !mi(Medicaid)
replace Q87_6 = VAHealthCare if !mi(VAHealthCare)
replace Q87_7 = TRICARE if !mi(TRICARE)
replace Q87_8 = Othernamely if !mi(Othernamely)

* drop unused variables
drop Privateinsurancethroughemploy Privateinsurancethroughfamily Privateinsurancenotthroughe Medicare Medicaid VAHealthCare TRICARE Othernamely

* label new category
lab var Q87_10 "Private insurance, source unknown"

***************************************************************************************************
* Finalize
***************************************************************************************************

* save
save "Data/HFCS/clean_data/HFCS_CLEAN.dta", replace