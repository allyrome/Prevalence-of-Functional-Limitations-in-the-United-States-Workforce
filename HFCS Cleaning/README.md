These files take the raw data from RAND American Life Panel (ALP) Well Being 522 - Health & Functional Capacity Survey and processes and cleans them to create HFCS_CLEAN.dta and hfcs_clean_recodes_full_fml.dta

## Files run in this order 

process.do : merges in end-of-survey comments, destrings variables to convert to numeric, creates useful variables for later use input: ms522_final_public.dta output: interim1.dta

labeling.do : add variable and value labels, input: interim1.dta output: HFCS_CLEAN.dta

export_variables.do : Exports variables and variable labels into Excel file. input: HFCS_CLEAN.dta output: variables.xlsx

add_conditions_text.do : Update standardized medical conditions (Q1 variables) with free text information (Must have already run freetext_conditions_clean.R to produce test.csv) input: HFCS_CLEAN.dta & test.csv output: HFCS_CLEAN.dta

merge.do : Merges hand-coded variables that are in the 3 .csv files inlcuded in this folder. input: FINAL_OCCUPATIONS.csv, occupation_todo.csv, HFCS_CLEAN.dta, check_insurance_changed.xlsx output: HFCS_CLEAN.dta

recodes_full_fml.do : collapse all impairments into binary and put into same direction, input: HFCS_CLEAN.dta output: hfcs_clean_recodes_full_fml.dta
