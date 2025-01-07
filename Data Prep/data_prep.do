* HFCS - merge in other relevant data on respondents 
* Author: Alexandra Rome
* Purpose: 
* 	Add the following additional information needed for analysis to the HFCS survey repsonse data
*		1. HFCS question numbers and functional groups
*		2. Essential/Teleworkable status
*		3. 1-digit ISCO codes for 
*		4. Binary limitation indicators
*		5. Weighted and unweighted limitations for 97 and 56 total limitations
*		6. Variables of interest for occupation, industry, etc. 
*==================================================================================================
version 16.1

* Set working directory
cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

******** Tidy FML crosswalk and save it in a tempfile ********

* Load Crosswalk between FML questions and HFCS questions with degree of limitation
import excel using "Data\HFCS\clean_data\variables_full_fml.xlsx" , sheet("fml_xwalk") firstrow clear

* Drop Questions about working hours and FML items that do not have corresponding HFCS items
drop if hfcs_question == "Q69" | hfcs_question == "Q70_combo" | hfcs_question == "Q71_combo" | hfcs_question == "Q72_combo" | hfcs_question == ""

* Rename variables and drop label descriptors
rename hfcs_question Question
rename fml_value value
drop fml_item fml_label

tempfile fml_xwalk
save `fml_xwalk'

******** Tidy essential/teleworkable status by SOC code and save in a tempfile *****
 
* Import data for codes that did not originally have a teleworkable/essential identifier. Values were imputed from the average of related occuaption codes
import excel using "Data\HFCS\clean_data\interim\imputation_missing_ess_tel_fro.xlsx" , sheet("Average") cellrange(A1:D63) firstrow clear

tostring SOC_6_Digit, replace format(%12.0f)

* No information on teleworkable from the 6 digit level down to the 2 digit level for SOC code 552013, we opted not to average occupations at the 1 digit level, and instead keep the original missing value
drop if SOC_6_Digit == "552013"

* Append data on SOC codes with essential and teleworkable identifiers from Dingel and Neiman and CISA 
append using "Data\HFCS\clean_data\status_by_SOC.dta"
drop frontline

* The SOC codes that use the imputed values are now duplicate observations in the data, one with the imputed value, and one with the missingness. We want to drop the duplicate observations with missingness
bysort SOC_6_Digit : gen seq=_N
drop if seq > 1 & Teleworkable == . 
drop seq

tempfile ess_tel_fro
save `ess_tel_fro'


******** Tidy HFCS/FML survey data and save it in a tempfile  ********

* Load HFCS/FML data
use "Data\HFCS\clean_data\hfcs_clean_recodes_full_fml.dta" , clear

* Exclude working hours limitations (Q69-Q72) from all analyses
drop Q69 Q70_combo Q71_combo Q72

* Q36 is only a limitation if no other limitation (limited/severely limited) is reported in movement section. It should also only be coded as 0/1 as the three options are left/right/both, and not degrees of severity

replace Q36 = cond(missing(Q36), . ,cond(Q37_1 == 1 | Q37_2 == 1 | Q37_3 == 1 | Q37_4 == 1 | Q37_5 == 1 | Q37_6 == 1 | Q37_7 == 1 | Q37_8 == 1 | Q38 == 1 | (Q39 > 1 & Q39 != .)| Q40 == 1 | (Q41 > 1  & Q41 != .) | (Q42 > 1  & Q42 != .) | (Q43 > 0   & Q43 != .) | (Q44 > 1  & Q44 != .) | Q45 == 1 | (Q46 > 0  & Q46 != .) | (Q47 > 1  & Q47 != .) | (Q48 > 1  & Q48 != .) | Q49 == 1 | (Q50 > 0  & Q50 != .) | (Q52_combo > 1  & Q52 != .) | (Q53_combo > 1   & Q53 != .) | (Q54 > 1 & Q54 != .) | (Q55 > 1 & Q55 != .)| Q56 == 1 | Q57 == 1 | Q58 == 1 | Q59 == 1, 0, Q36))

* Q68 is only a limitation if no other limitation (limited/severely limited) is reported in holding section
replace Q68= cond(missing(Q68), . , cond((Q60 > 1 & Q60 != .) | (Q61 > 1 & Q61 != .) | (Q62 > 1 & Q62 != .)| (Q63 > 1 & Q63 != .) | Q64 == 1 | Q65 == 1 | Q66 == 1 | (Q67 > 1 & Q67 != . ), 0, Q68))

gen soc_code = substr(hand_assign_use, 1, 6)

tempfile hfcs_wide
save `hfcs_wide'

reshape long Q, i(prim_key) j(Question 5-8 9_1 9_2 9_3 9_4 9_5 10_1 10_2 10_3 10_4 10_5 10_6 10_7 10_8 10_9 11_combo 12_combo_2 12_combo_3 12_combo_4 12_combo_5 12_combo_6 12_combo_7 12_combo_8 12_combo_9 12_combo_10 12_combo_11 13-18 19_combo_2 19_combo_3 19_combo_4 19_combo_5 19_combo_6 20_combo 21_combo 22_combo 23-32 33_2 33_3 33_4 33_5 34 36 37_1 37_2 37_3 37_4 37_5 37_6 37_7 37_8 38-50 52_combo 53_combo 54-68)
rename Q value
replace Question = "Q" + Question

tempfile hfcs
save `hfcs'


******** Add HFCS Question numbers, domains, groups to the tidied HFCS/FML survey data and save as a tempfile ********

* Load HFCS questions, their domain, functional group, and labels
import excel using "Data\HFCS\clean_data\variables_full_fml.xlsx" , sheet("limitations") firstrow clear

replace FunctionalGroup = "Arm Movements" if FunctionalGroup == "Arm Movements "

* Add Question number to labels
replace Label = Question + "." + Label

* Create order of questions
gen Order = _n

* Clean up variables
replace Domain = "Senses and\ncommunication" if Domain == "Senses and communication"
rename FunctionalGroup Functional_Group
drop Combo 

* Merge these groups and labels into the HFCS response data
merge 1:m Question using `hfcs'

* Drop hours variables that don't merge
keep if _merge == 3
drop _merge

* Create 2-digit occupation code
gen hand_assign_use2 = substr(hand_assign_use, 1, 2)
replace hand_assign_use2 = "." if hand_assign_use2 == ""

destring hand_assign_use2, generate(hand_assign_use2_char) force
label define occ2_labels 11 "Management" 13 "Business and Financial Operations" 15 "Computer and Mathematical" 17 "Architecture and Engineering" 19 "Life, Physical, and Social Science" 21 "Community and Social Service" 23 "Legal Occupations" 25 "Education, Training, and Library" 27 "Arts/Design/Entertainment/Sports/Media" 29 "Healthcare Practitioners and Technical" 31 "Healthcare Support Occupations" 33 "Protective Service Occupations" 35 "Food Preparation and Serving Related" 37 "Building/Grounds Cleaning & Maintenance" 39 "Personal Care and Service Occupations" 41 "Sales and Related Occupations" 43 "Office and Administrative Support" 45 "Farming, Fishing, and Forestry" 47 "Construction and Extraction" 49 "Installation, Maintenance, and Repair" 51 "Production Occupations" 53 "Transportation and Material Moving" 55 "Military Specific Occupations"
label values hand_assign_use2_char occ2_labels

tempfile hfcs_2
save `hfcs_2'


******** Add 1 digit Isco codes to the HFCS/FML response data ********

* Load ISCO-SOC xwalk
import excel using "Data\HFCS\raw_data\ISCO_SOC_Crosswalk.xls", sheet("2010 SOC to ISCO-08") cellrange(A7) first case(preserve) clear

* processing
keep SOCCode ISCO08Code
rename SOCCode soc_code
replace soc_code = regexr(soc_code, " ", "")
replace soc_code = regexr(soc_code, "-", "")

* match to only 1 digit in ISCO
gen isco_1dig = substr(ISCO08Code, 1, 1)
drop ISCO08Code 

* Keep only unique values
duplicates drop

* Merge the SOC/ISCO crosswalk to the hfcs data, creating duplicate observations for SOC codes that have multiple 1 digit isco codes associated with them
joinby soc_code using `hfcs_wide' , unmatched(both)
drop if _merge == 1

* Randomly select an isco code if one soc code matches to multiple isco
sort prim_key soc_code isco_1dig
set seed 012767
gen random = runiform()

* Sort using prim_key and random
sort prim_key random 
by prim_key (random), sort: keep if _n == 1


destring isco_1dig, gen(isco_1dig_char)
label define isco_labels 1 "Managers" 2 "Professionals" 3 "Technicians and Associate Professionals" 4 "Clerical Support Workers" 5 "Services and Sales Workers" 6 "Skilled Agricultural, Forestry and Fishery Workers" 7 "Craft and Related Trades Workers" 8 "Plant and Machine Operators and Assemblers" 9 "Elementary Occupations" 0 "Armed Forces Occupations"
label values isco_1dig_char isco_labels

keep prim_key isco_1dig isco_1dig_char

* Merge isco codes associated with each respondent into main data 
merge 1:m prim_key using `hfcs_2'


******** Create variables for industry, occupation, job status ********

* Create SIC industry categories from Q81 NAICS categories https://www.naics.com/history-naics-code/
gen ind_sic = .
replace ind_sic = 1 if Q81 == 1
replace ind_sic = 2 if Q81 == 2
replace ind_sic = 3 if Q81 == 4
replace ind_sic = 4 if Q81 == 5
replace ind_sic = 5 if Q81 == 3 | Q81 == 8 
replace ind_sic = 6 if Q81 == 6
replace ind_sic = 7 if Q81 == 7 | Q81 == 18 
replace ind_sic = 8 if Q81 == 10 | Q81 == 11 
replace ind_sic = 9 if Q81 == 9 | Q81 == 12 | Q81 == 14 | Q81 == 15 | Q81 == 16 | Q81 == 17 | Q81 == 19
replace ind_sic = 10 if Q81 == 20 
replace ind_sic = 11 if Q81 == 13 

label define sic_labels 1 "Agriculture, Forestry & Fishing" 2 "Mining" 3 "Construction" 4"Manufacturing" 5 "Transportation, Communications & Public Utilities" 6 "Wholesale Trade" 7 "Retail Trade" 8 "Finance, Insurance & Real Estate" 9 "Services" 10 "Public Administration" 11 "Management of Companies & Enterprises"
label values ind_sic sic_labels

gen ind_super = .
replace ind_super = 1 if ind_sic == 1 | ind_sic == 2 | ind_sic == 3 | ind_sic == 4
replace ind_super = 2 if ind_sic == 5 | ind_sic == 6 | ind_sic == 7 | ind_sic == 8 | ind_sic == 9 | ind_sic == 10 | ind_sic == 11
label define super_labels 1 "Goods-Producing" 2 "Service-Producing"
label values ind_super super_labels

gen SOC_6_Digit = substr(hand_assign_use, 1, 6)
drop _merge 

* Merge in essential/teleworkable status by SOC code
merge m:1 SOC_6_Digit using `ess_tel_fro'

* Observations only in master (_merge == 1) are respondents without SOC codes 
* Observations only in using (_merge == 2) are SOC codes not present in the data
keep if _merge != 2
drop _merge

******** Data Decisions ********

* Impose hierarchy for employment status to make each category exclusive
* note these categories are not mutually exclusive so the replacement must be run in this order
gen emp_stat = .
replace emp_stat = 4 if retired == 1
replace emp_stat = 3 if disabled == 1 
replace emp_stat = 2 if EMPSTAT_UNEMP == 1 | EMPSTAT_LO == 1
replace emp_stat = 1 if working == 1

* Impute missing as "no limitation" for thinking/social modules if did not qualify for those modules but did pass screener
replace value = cond(missing(value) & think_social_qualify == 0 & pass_screener == 1 & (Domain == "Thinking" | Domain == "Social") , 0 , value)


******** Add limitations values from tidied FML crosswalk above ********

* Merge tidied FML/HFCS crosswalk with limitation values
merge m:1 Question value using `fml_xwalk' 
keep if _merge != 2
drop _merge

rename value value_orig

gen value = .
replace value = 0 if fml_value_label == "Normal"
replace value = 1 if fml_value_label == "Slightly limited"
replace value = 2 if fml_value_label == "Limited"
replace value = 3 if fml_value_label == "Very limited"
label define value_lab 0 "Normal" 1 "Somewhat limited" 2 "Slightly limited" 3 "Limited" 4 "Very limited"
label values value value_lab

replace Functional_Group = "Knee Movements" if Functional_Group == "Knee-Straining Postures"
replace Functional_Group = "Immune System" if Functional_Group == "Weakened Immune System"


* Save data for analysis 
save "Data\HFCS\clean_data\hfcs_recodes.dta" , replace


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

* Create number of limitations variable that only totals from the 56 limitations used in the matching algorithm rather than the 97 total limitations, and created weighted versions of the 97 and 56 versions using job prevalence by education

* Merge job prevalence data by education level for each limitation
merge m:1 Question using "Papers\Burdens of Functional Limitations\Appendix\restricted_limitations\job_profiles_limitations_education"

* Create binary indicators for respondents with or without a college degree
replace college_degree = 1 if _merge == 1
replace no_college_degree = 1 if _merge == 1

* Generate indicators for college degree status restricted to the 56 limitations used in the matching algorithm
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
gen wtd_college = college_degree / `prevalence_mean_college'
gen wtd_no_college = no_college_degree / `prevalence_mean_no_college'


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
gen wtd_college56 = college_degree56 / `prevalence_mean_college56'
gen wtd_no_college56 = no_college_degree56 / `prevalence_mean_no_college56'


* Assign weighted prevalence values based on respondents' education level
gen wtd_prof_prevalence = .
replace wtd_prof_prevalence = wtd_college if ed_ba_or_more == 1
replace wtd_prof_prevalence = wtd_no_college if ed_ba_or_more == 0

gen wtd_prof_prevalence56 = .
replace wtd_prof_prevalence56 = wtd_college56 if ed_ba_or_more == 1
replace wtd_prof_prevalence56 = wtd_no_college56 if ed_ba_or_more == 0

* Create weighted limitation counts using prevalence-adjusted values

* 97 total limitations, weighted by job profile prevalence by education status
gen value3 = 0 
replace value3 = value2 * wtd_prof_prevalence
bys prim_key: egen num_limit_wtd = sum(value3)

* 56 total limitations, unweighted
gen value4 = 0
replace value4 = value2 if _merge == 3
bys prim_key: egen num_limit56 = sum(value4)

* 56 total limitations, weighted
gen value5 = value4 * wtd_prof_prevalence56
bys prim_key: egen num_limit_wtd56 = sum(value5)

* Collapse dataset to one record per respondent, retaining key summary statistics and demographic variables
collapse (max) num_limit num_limit_wtd num_limit56 num_limit_wtd56 (first) female AGE age_grp3 college college2 college3 isco_1dig isco_1dig_char hand_assign_use2 hand_assign_use2_char Q81 emp_stat essential Teleworkable weight pass_screener, by(prim_key)

* Save the final dataset for analysis
save "Data\HFCS\clean_data\hfcs_recodes_clpsd.dta" , replace
