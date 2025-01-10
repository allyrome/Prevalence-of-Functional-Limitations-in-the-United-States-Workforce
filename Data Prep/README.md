These two files take the cleaned HFCS data and add information needed for analysis

## data_prep.do 
Prepares cleaned HFCS data for analysis and adds additional information
#### inputs: 
variables_full_fml.xlsx : crosswalk between FML questions and HFCS questions with degree of limitation \
imputation_missing_ess_tel_fro.xlsx  : codes that did not originally have a teleworkable/essential identifier. Values were imputed from the average of related occuaption codes \
status_by_SOC.dta : essential and teleworkable identifiers from Dingel and Neiman and CISA \
hfcs_clean_recodes_full_fml.dta : cleaned HFCS data \
ISCO_SOC_Crosswalk.xls : crosswalk between ISCO and SOC codes
#### outputs: 
hfcs_recodes.dta, hfcs_recodes_clpsd.dta 

## medical_conditions.do 
Adds medical condition labels and groupings to HFCS data 
#### inputs: 
HFCS Collapsed Medical Condition Categories_04302024.xlsx: medical conditions grouped by categories created by the authors \
HFCS_CLEAN.dta : Cleaned HFCS data
hfcs_recodes_clpsd.dta : HFCS data with additional information from data_prep.do
#### output: 
medcond_g.dta

## limitations_job_prevalence_ed.do
Finds the number of job profiles that assess each limittaion/job requirement
#### inputs:

#### output:
