* HFCS - clean data
* Author: Michael Jetupphasuk
* Purpose: Exports variables and variable labels into Excel file

*==================================================================================================

* load data 
use "Data/HFCS/clean_data/HFCS_CLEAN.dta", clear

* keep only survey questions
keep Q1_bone_1-Q90a_7

* put variables and variable labels as observations
describe, replace clear

* keep useful things
keep name varlab type isnumeric
order name varlab type isnumeric
rename name Variable 
rename varlab VarLab 
rename type Type 
rename isnumeric Isnumeric 

* export 
export excel using "Data/HFCS/clean_data/variables.xlsx", first(var) sheet("all_vars") sheetreplace