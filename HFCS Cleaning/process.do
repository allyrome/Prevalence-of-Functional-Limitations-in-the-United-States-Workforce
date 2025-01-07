* HFCS - clean data
* Author: Michael Jetupphasuk
* Purpose: 
*	1. merges in end-of-survey comments
*	2. destrings variables to convert to numeric
*	3. creates useful variables for later use

*==================================================================================================

* PREPARATION

* load data 
use "Data/HFCS/raw_data/ms522_final_public.dta", clear

* initialize a temp file
tempfile stsh

* * merge in end-of-survey comments (this one has been scraped for confidential information)
* preserve
* import excel using "Data/HFCS/raw_data/ms522_final_comments_nontruncated_Oct18.xlsx", first clear 
* save `stsh'
* restore
* merge 1:1 prim_key using `stsh', nogen

* numbers stored as strings; convert
destring, replace

* rename three variables so the names are short enough to be handled by the "fsum, catvar()" command
rename  Q2_limitsActivities_1  Q2_limitsActiv_1 
rename  Q2_limitsActivities_2  Q2_limitsActiv_2  
rename  Q2_limitsActivities_3  Q2_limitsActiv_3

* generate definitions of retired and working and disabled
recode EMPSTAT* (2=0)
egen dis_ret_oth = rowtotal(EMPSTAT_DIS EMPSTAT_RET EMPSTAT_OTH)
replace dis_ret_oth=1 if dis_ret_oth>1
gen retired = EMPSTAT_RET==1
gen working = EMPSTAT_WORK==1
gen disabled = EMPSTAT_DIS==1


*==================================================================================================
* Create variables that count missingness in each module
*==================================================================================================

* HEALTH MODULE

* missing health
gen health_mi = 0

local all_health
foreach var in bone nervous heart lung gastro infectious mental other {
	if "`var'"=="bone" | "`var'"=="nervous" | "`var'"=="mental" | "`var'"=="other" {
		ds Q1_`var'_? Q1_`var'_??
		local store_vlist = "`r(varlist)'"
		local all_health = "`all_health' `r(varlist)'"
	}
	else {
		ds Q1_`var'_?
		local store_vlist = "`r(varlist)'"
		local all_health = "`all_health' `r(varlist)'"
	}

	egen Q1_`var'_zeros = rowtotal(`store_vlist')
	recode `store_vlist' (0=.s) if Q1_`var'_zeros==0
	replace health_mi = health_mi + 1 if Q1_`var'_zeros==0
}

local remove_health "Q1_bone_15 Q1_nervous_11 Q1_heart_8 Q1_lung_6 Q1_gastro_8 Q1_infectious_4 Q1_mental_14 Q1_other_14" 
local all_health2 = "`all_health'"
foreach i in `remove_health' {
	local all_health2 : subinstr local all_health2 "`i'" "", word
}

* total number of health problems per respondent
egen num_health_problems = rowtotal(`all_health2')

egen Q2_nonmi = rowmiss(Q2_textEntry_1 Q2_textEntry_2 Q2_textEntry_3)
replace Q2_nonmi = 3-Q2_nonmi
replace health_mi = health_mi + 1 if Q2_nonmi < num_health_problems & Q2_nonmi<3
replace health_mi = health_mi + 1 if mi(Q3) & num_health_problems>0


* was open-text in "other" responses required?
# delimit ;
local other_qs "Q1_bone_12 Q1_bone_13 Q1_bone_14 Q1_nervous_10 Q1_heart_7 Q1_lung_5 Q1_gastro_6 Q1_gastro_7 
	Q1_infectious_3 Q1_mental_7 Q1_mental_9 Q1_mental_10 Q1_mental_13 Q1_other_11 Q1_other_12 Q1_other_13";
# delimit cr
foreach q in `other_qs' {
	assert !mi(`q'_other) if `q'==1
}

* drop interim variables
drop Q1_*_zeros


* THINKING MODULE

* people who qualify for thinking and social interactions module
gen think_social_qualify = 0
replace think_social_qualify = 1 if (Q1_nervous_2==1 | Q1_nervous_4==1 | Q1_nervous_5==1 | Q1_nervous_10==1 | ///
	Q1_mental_1==1 | Q1_mental_2==1 | Q1_mental_3==1 | Q1_mental_4==1 | Q1_mental_5==1 | Q1_mental_6==1 | ///
	Q1_mental_7==1 | Q1_mental_8==1 | Q1_mental_9==1 | Q1_mental_10==1 | ///
	Q1_other_4==1 | Q1_other_5==1 | Q1_other_12==1 | Q1_other_13==1) & Q4_11==1
egen skip_all_health = rowtotal(`all_health')
replace think_social_qualify = 1 if skip_all_health<=0	// I don't know what the threshold here is supposed to be

* people who qualify for thinking and social modules because of "other health problem"
gen think_social_other = 0
replace think_social_other = 1 if (Q1_nervous_2!=1 & Q1_nervous_4!=1 & Q1_nervous_5!=1 & Q1_nervous_10!=1 & ///
	Q1_mental_1!=1 & Q1_mental_2!=1 & Q1_mental_3!=1 & Q1_mental_4!=1 & Q1_mental_5!=1 & Q1_mental_6!=1 & ///
	Q1_mental_7!=1 & Q1_mental_8!=1 & Q1_mental_9!=1 & Q1_mental_10!=1 & ///
	Q1_other_4!=1 & Q1_other_5!=1 & Q1_other_12!=1 & Q1_other_13==1) & Q4_11==1
replace think_social_other = 1 if skip_all_health<=0	// I don't know what the threshold here is supposed to be

* normal questions
ds Q5-Q9  Q10 Q11_retired Q11
local thinking_qs = "`r(varlist)'"
local thinking_qs_reg : subinstr local thinking_qs "Q11_retired" "", word
local thinking_qs_ret : subinstr local thinking_qs "Q11" "", word
egen thinking_mi_reg = rowmiss(`thinking_qs_reg') if think_social_qualify==1 & dis_ret_oth==0
egen thinking_mi_ret = rowmiss(`thinking_qs_ret') if think_social_qualify==1 & dis_ret_oth==1
gen thinking_mi = thinking_mi_reg if dis_ret_oth==0
replace thinking_mi = thinking_mi_ret if dis_ret_oth==1
drop thinking_mi_*

* select all questions
local var = "Q9a"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if Q9==2
recode `store_vlist' (.=.s) if `var'_nonmi==0 & Q9==2
replace thinking_mi = thinking_mi + 1 if `var'_nonmi==0 & Q9==2

local var = "Q10a"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if Q10==2
recode `store_vlist' (.=.s) if `var'_nonmi==0 & Q10==2
replace thinking_mi = thinking_mi + 1 if `var'_nonmi==0 & Q10==2

local var = "Q12_retired"
ds `var'_? `var'_??
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if dis_ret_oth==1
recode `store_vlist' (.=.s) if `var'_nonmi==0 & dis_ret_oth==1
replace thinking_mi = thinking_mi + 1 if `var'_nonmi==0 & dis_ret_oth==1

local var = "Q12"
ds `var'_? `var'_??
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if dis_ret_oth==0
recode `store_vlist' (.=.s) if `var'_nonmi==0 & dis_ret_oth==0
replace thinking_mi = thinking_mi + 1 if `var'_nonmi==0 & dis_ret_oth==0

* recode to .s
recode `thinking_qs' Q10 (.=.s) if think_social_qualify==1


* SOCIAL INTERACTIONS MODULE

* normal questions
ds Q13-Q18
local social_qs = "`r(varlist)'"
egen social_mi = rowmiss(`social_qs') if think_social_qualify==1

* select all questions
local var = "Q19_retired"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if dis_ret_oth==1
recode `store_vlist' (.=.s) if `var'_nonmi==0 & dis_ret_oth==1
replace social_mi = social_mi + 1 if `var'_nonmi==0 & dis_ret_oth==1

local var = "Q19"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if dis_ret_oth==0
recode `store_vlist' (.=.s) if `var'_nonmi==0 & dis_ret_oth==0
replace social_mi = social_mi + 1 if `var'_nonmi==0 & dis_ret_oth==0

* recode to .s
recode `social_qs' (.=.s) if think_social_qualify==1


* SENSES AND COMMUNICATION MODULE

* normal questions
ds Q20_retired-Q22_retired Q23 Q24
local sense_qs_ret = "`r(varlist)'"
egen senses_mi_ret = rowmiss(`sense_qs_ret') if dis_ret_oth==1

ds Q20-Q22 Q23 Q24
local sense_qs_reg = "`r(varlist)'"
egen senses_mi_reg = rowmiss(`sense_qs_reg') if dis_ret_oth==0

gen senses_mi = senses_mi_reg
replace senses_mi = senses_mi_ret if dis_ret_oth==1
drop senses_mi_*

* recode to .s
ds Q20_retired-Q24
recode `r(varlist)' (.=.s)


* PHYSICAL ENVIRONMENTS

* normal questions
ds Q25-Q32 Q34
local physical_qs = "`r(varlist)'"
egen physical_mi = rowmiss(`physical_qs')

* "select all" questions
foreach var in Q33 {
	ds `var'_?
	local store_vlist = "`r(varlist)'"
	egen `var'_nonmi = rowtotal(`store_vlist')
	recode `store_vlist' (.=.s) if `var'_nonmi==0
	replace physical_mi = physical_mi + 1 if `var'_nonmi==0
}

* recode to .s
recode `physical_qs' (.=.s)

* conditional questions
replace Q33a=.s if mi(Q33a) & working==1
replace Q33b=.s if mi(Q33b) & Q33a==1

replace physical_mi = physical_mi + 1 if Q33a==.s
replace physical_mi = physical_mi + 1 if Q33b==.s


* MOVEMENT

* normal questions
ds Q35-Q37 Q38-Q41 Q43 Q45-Q50 Q51 Q58-Q59
local movement_qs = "`r(varlist)'"
egen movement_mi = rowmiss(`movement_qs')

* select all questions
local var = "Q37a"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if Q37==1
recode `store_vlist' (.=.s) if `var'_nonmi==0 & Q37==1
replace movement_mi = movement_mi + 1 if `var'_nonmi==0 & Q37==1

* recode to .s
recode `movement_qs' (.=.s)

* conditional questions
replace Q42=.s if mi(Q42) & Q41<=3
replace Q44=.s if mi(Q44) & Q43==4
replace Q50a=.s if mi(Q50) & Q50==2
replace Q52wc=.s if mi(Q52wc) & Q51==3
replace Q53wc=.s if mi(Q53wc) & Q51==3
replace Q52=.s if mi(Q52) & Q51<=2
replace Q53=.s if mi(Q53) & Q51<=2
replace Q54=.s if mi(Q54) & Q51!=4
replace Q55=.s if mi(Q55) & Q51!=4
replace Q56=.s if mi(Q56) & Q51!=4
replace Q57=.s if mi(Q57) & Q51!=4 

replace movement_mi = movement_mi + 1 if Q42==.s
replace movement_mi = movement_mi + 1 if Q44==.s
replace movement_mi = movement_mi + 1 if Q50a==.s
replace movement_mi = movement_mi + 1 if Q52wc==.s
replace movement_mi = movement_mi + 1 if Q53wc==.s
replace movement_mi = movement_mi + 1 if Q52==.s
replace movement_mi = movement_mi + 1 if Q53==.s
replace movement_mi = movement_mi + 1 if Q54==.s
replace movement_mi = movement_mi + 1 if Q55==.s
replace movement_mi = movement_mi + 1 if Q56==.s
replace movement_mi = movement_mi + 1 if Q57==.s


* HOLDING POSITIONS

* normal questions
ds Q60-Q62 Q66 Q68
local holding_qs = "`r(varlist)'"
egen holding_mi = rowmiss(`holding_qs')

* recode to .s
recode `holding_qs' (.=.s)

* conditional questions
replace Q63=.s if mi(Q63) & Q62<=4
replace Q64=.s if mi(Q64) & Q57==1
replace Q65=.s if mi(Q65) & Q43<=3
replace Q67=.s if mi(Q67) & (Q50==1 | (Q50==2 & Q50a==1))

replace holding_mi = holding_mi + 1 if Q63==.s
replace holding_mi = holding_mi + 1 if Q64==.s
replace holding_mi = holding_mi + 1 if Q65==.s
replace holding_mi = holding_mi + 1 if Q67==.s


* WORKING HOURS

* normal questions
ds Q69
local working_qs = "`r(varlist)'"
egen working_mi = rowmiss(`working_qs')

* recode to .s
recode Q69 (.=.s)

* conditional questions
replace Q70_retired=.s if mi(Q70_retired) & dis_ret_oth==1
replace Q71_retired=.s if mi(Q71_retired) & dis_ret_oth==1
replace Q72_retired=.s if mi(Q72_retired) & dis_ret_oth==1
replace Q70=.s if mi(Q70) & dis_ret_oth==0
replace Q71=.s if mi(Q71) & dis_ret_oth==0
replace Q72=.s if mi(Q72) & dis_ret_oth==0
replace Q73=.s if mi(Q73) & working==1

replace working_mi = working_mi + 1 if Q70_retired==.s
replace working_mi = working_mi + 1 if Q71_retired==.s
replace working_mi = working_mi + 1 if Q72_retired==.s
replace working_mi = working_mi + 1 if Q70==.s
replace working_mi = working_mi + 1 if Q71==.s
replace working_mi = working_mi + 1 if Q72==.s
replace working_mi = working_mi + 1 if Q73==.s


* EDUCATION, SKILLS, AND WORK EXPERIENCE

* normal questions
ds Q74 Q75 Q76-Q78
local edu_qs = "`r(varlist)'"
egen edu_mi = rowmiss(`edu_qs')

* select all questions
local var = "Q74a"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if Q74>=7 & Q74<=12
recode `store_vlist' (.=.s) if `var'_nonmi==0 & Q74>=7 & Q74<=12
replace edu_mi = edu_mi + 1 if `var'_nonmi==0 & Q74>=7 & Q74<=12

local var = "Q75a"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if Q75==1
recode `store_vlist' (.=.s) if `var'_nonmi==0 & Q75==1
replace edu_mi = edu_mi + 1 if `var'_nonmi==0 & Q75==1

foreach var in Q86 {
	ds `var'_?
	local store_vlist = "`r(varlist)'"
	egen `var'_nonmi = rowtotal(`store_vlist')
	recode `store_vlist' (.=.s) if `var'_nonmi==0
	replace edu_mi = edu_mi + 1 if `var'_nonmi==0
}

* recode to .s
recode `edu_qs' (.=.s)
recode Q82_yearsexperience_1 Q82_yearsexperience_2 Q82_yearsexperience_3 (.=.s)

* conditional questions
replace Q78a=.s if mi(Q78a) & Q78==1
recode Q81 Q83 Q84 Q85 (.=.s) if working==1

replace edu_mi = edu_mi + 1 if Q78a==.s
replace edu_mi = edu_mi + 1 if Q81==.s
replace edu_mi = edu_mi + 1 if Q83==.s
replace edu_mi = edu_mi + 1 if Q84==.s
replace edu_mi = edu_mi + 1 if Q85==.s



* HEALTH AND DISABILITY PROGRAM PARTICIPATION

gen program_mi = 0

* select all questions
local var = "Q89"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if Q88_8==1
recode `store_vlist' (.=.s) if `var'_nonmi==0 & Q88_8==1
replace program_mi = program_mi + 1 if `var'_nonmi==0 & Q88_8==1

local var = "Q89a"
ds `var'_?
local store_vlist = "`r(varlist)'"
egen `var'_nonmi = rowtotal(`store_vlist') if Q88_8==0
recode `store_vlist' (.=.s) if `var'_nonmi==0 & Q88_8==0
replace program_mi = program_mi + 1 if `var'_nonmi==0 & Q88_8==0


* "select all" questions
foreach var in Q87 Q88 {
	ds `var'_?
	local store_vlist = "`r(varlist)'"
	egen `var'_nonmi = rowtotal(`store_vlist')
	recode `store_vlist' (.=.s) if `var'_nonmi==0
	replace program_mi = program_mi + 1 if `var'_nonmi==0
}



*==================================================================================================
* Create demographic variables
*==================================================================================================

gen pass_screener = Q4_11==1
gen wheelchair = Q51==3 if !mi(Q51)

gen age_grp = 1 if AGE<25
replace age_grp = 2 if AGE>=25 & AGE<=34
replace age_grp = 3 if AGE>=35 & AGE<=49
replace age_grp = 4 if AGE>=50 & !mi(AGE)

gen age_grp2=1 if AGE<50
replace age_grp2=2 if AGE>=50 & AGE<65
replace age_grp2=3 if AGE>=65

gen age_grp3=1 if AGE<35
replace age_grp3=2 if AGE>=35 & AGE<50
replace age_grp3=3 if AGE>=50 & AGE<65
replace age_grp3=4 if AGE>=65

gen age50 = age_grp==4

gen female = SEX==2
gen college = Q74>=9 if !mi(Q74)
gen college2 = 1 if !mi(Q74)
replace college2 = 2 if inrange(Q74, 6, 8) & !mi(Q74)
replace college2 = 3 if Q74>=9 & !mi(Q74)
gen college3 = Q74>=6 if !mi(Q74)


*==================================================================================================
* Create "any" impairment indicators
*==================================================================================================

* health conditions that limit daily activities
recode Q2_limitsActiv_1 Q2_limitsActiv_2 Q2_limitsActiv_3 (2=0)
egen Q2_limitsTot = rowtotal(Q2_limitsActiv_1 Q2_limitsActiv_2 Q2_limitsActiv_3) if ///
	!mi(Q2_limitsActiv_1) | !mi(Q2_limitsActiv_2) | !mi(Q2_limitsActiv_3) 
gen Q2_limitsAny = Q2_limitsTot>=1 if !mi(Q2_limitsTot)


* for each module, how many are selecting any impairment at all?

* thinking (excluding Q11)
gen any_impair_thinking = (Q5==2 | Q5==3 | Q6==2 | Q6==3 | Q7==2 | Q7==3 | Q8==2 | Q8==3 | /// 
	Q9==2 | Q10==2 | (Q12_1!=1 & !mi(Q12_1))) if think_social_qualify==1

* social interactions (excluding Q18)
gen any_impair_social = (Q13==2 | Q13==3 | Q14==2 | Q14==3 | Q15==2 | Q15==3 | /// 
	Q16==2 | Q16==3 | (Q19_retired_1!=1 & !mi(Q19_retired_1)) | (Q19_1!=1 & !mi(Q19_1))) if think_social_qualify==1

* senses and communication
gen any_impair_senses = (Q20_retired==1 | Q21_retired==1 | Q22_retired==1 | /// 
	Q20==1 | Q21==1 | Q22==1 | Q23==1 | Q24==1) if pass_screener==1

* physical environments (excluding Q34)
gen any_impair_physical = (Q25==2 | Q26==2 | Q27==2 | Q28==2 | Q29==2 | Q30==2 | ///
	Q31==2 | Q32==2 | (Q33_1!=1 & !mi(Q33_1))) if pass_screener==1

* movement (excluding Q59)
gen any_impair_movement = (Q36<=3 | Q37==1 | Q38==1 | (Q39!=1 & !mi(Q39)) | Q40==1 | ///
	(Q41!=1 & !mi(Q41)) | (Q42!=1 & !mi(Q42)) | (Q43!=1 & !mi(Q43)) | (Q44!=1 & !mi(Q44)) | ///
	Q45==1 | (Q46!=1 & !mi(Q46)) | (Q47!=1 & !mi(Q47)) | (Q48!=1 & !mi(Q48)) | ///
	Q49==2 | Q50==2 | (Q52wc!=1 & !mi(Q52wc)) | (Q53wc!=1 & !mi(Q53wc)) | (Q52!=1 & !mi(Q52)) | (Q53!=1 & !mi(Q53)) | ///
	(Q54!=1 & !mi(Q54)) | (Q55!=1 & !mi(Q55)) | Q56==2 | Q57==2 | Q58==2) if pass_screener==1

* holding (excluding Q68)
gen any_impair_holding = ((Q60!=1 & !mi(Q60)) | (Q61!=1 & !mi(Q61)) | (Q62!=1 & !mi(Q62)) | /// 
	(Q63!=1 & !mi(Q63)) | Q64==1 | Q65==1 | Q66==1 | (Q67!=1 & !mi(Q67))) if pass_screener==1

* working (excluding Q72)
gen any_impair_work = ((Q70_retired!=1 & !mi(Q70_retired)) | (Q71_retired!=1 & !mi(Q71_retired)) | ///
	(Q70!=1 & !mi(Q70)) | (Q71!=1 & !mi(Q71))) if pass_screener==1



*==================================================================================================
* Number of impairments in each module
*==================================================================================================

* compute number of impairments in each module

* thinking
# delimit ;
local temp_vars "Q5==2 Q5==3 Q6==2 Q6==3 Q7==2 Q7==3 Q8==2 Q8==3  
	Q9==2 Q10==2 Q12_retired_1==0 Q12_1==0";
# delimit cr 
local n_temp_vars: list sizeof local(temp_vars)

forvalues i=1/`n_temp_vars' {
	local exp `: word `i' of `temp_vars''
	gen temp_vars`i' = `exp'
}

egen num_impair_thinking = rowtotal(temp_vars*) if think_social_qualify==1
drop temp_vars*


* social
# delimit ;
local temp_vars "Q13==2 Q13==3 Q14==2 Q14==3 Q15==2 Q15==3  
	Q16==2 Q16==3 Q17==2 Q19_retired_1==0 Q19_1==0";
# delimit cr 
local n_temp_vars: list sizeof local(temp_vars)

forvalues i=1/`n_temp_vars' {
	local exp `: word `i' of `temp_vars''
	gen temp_vars`i' = `exp'
}

egen num_impair_social = rowtotal(temp_vars*) if think_social_qualify==1
drop temp_vars*


* senses and communication
# delimit ;
local temp_vars "Q20_retired==1 Q21_retired==1 Q22_retired==1 
	Q20==1 Q21==1 Q22==1 Q23==1 Q24==1";
# delimit cr 
local n_temp_vars: list sizeof local(temp_vars)

forvalues i=1/`n_temp_vars' {
	local exp `: word `i' of `temp_vars''
	gen temp_vars`i' = `exp'
}

egen num_impair_senses = rowtotal(temp_vars*)
drop temp_vars*


* physical environments
# delimit ;
local temp_vars "Q25==2 Q26==2 Q27==2 Q28==2 Q29==2 Q30==2 
	Q31==2 Q32==2 Q33_1==0";
# delimit cr 
local n_temp_vars: list sizeof local(temp_vars)

forvalues i=1/`n_temp_vars' {
	local exp `: word `i' of `temp_vars''
	gen temp_vars`i' = `exp'
}

egen num_impair_physical = rowtotal(temp_vars*)
drop temp_vars*


* movement
# delimit ;
local temp_vars "Q36<=3 Q37==1 Q38==1 (Q39!=1&!mi(Q39)) Q40==1 
	(Q41!=1&!mi(Q41)) (Q43!=1&!mi(Q43))
	Q45==1 (Q46!=1&!mi(Q46)) (Q47!=1&!mi(Q47)) (Q48!=1&!mi(Q48)) 
	Q49==2 Q50==2 (Q52wc!=1&!mi(Q52wc)) (Q53wc!=1&!mi(Q53wc)) (Q52!=1&!mi(Q52)) (Q53!=1&!mi(Q53)) 
	(Q54!=1&!mi(Q54)) (Q55!=1&!mi(Q55)) Q56==2 Q57==2 Q58==2";
# delimit cr 
local n_temp_vars: list sizeof local(temp_vars)

forvalues i=1/`n_temp_vars' {
	local exp `: word `i' of `temp_vars''
	gen temp_vars`i' = `exp'
}

egen num_impair_movement = rowtotal(temp_vars*)
drop temp_vars*


* holding
# delimit ;
local temp_vars "(Q60!=1&!mi(Q60)) (Q61!=1&!mi(Q61)) (Q62!=1&!mi(Q62))  
	(Q63!=1&!mi(Q63)) Q64==1 Q65==1 Q66==1 (Q67!=1&!mi(Q67))";
# delimit cr 
local n_temp_vars: list sizeof local(temp_vars)

forvalues i=1/`n_temp_vars' {
	local exp `: word `i' of `temp_vars''
	gen temp_vars`i' = `exp'
}

egen num_impair_holding = rowtotal(temp_vars*)
drop temp_vars*


* aggregates
egen num_impair_total = rowtotal(num_impair_*)
egen num_impair_socthi = rowtotal(num_impair_thinking num_impair_social) if think_social_qualify==1
* egen num_impair_socthi2 = rowtotal(num_impair_thinking num_impair_social) if think_social_other==1


* how many individuals selecting an impairment in "other health problem" group are selecting the severe form?
ds Q5-Q9  Q10 Q11_retired Q11 Q12_retired_1 Q12_1 Q13-Q18 Q19_1 Q19_retired_1
local thinkingsocial_qs "`r(varlist)'"
egen severe_socthi = anymatch(`thinkingsocial_qs'), values(3)


gen any_impair_socthi = num_impair_socthi > 0 & !mi(num_impair_socthi)



*==================================================================================================
* Miscellaneous
*==================================================================================================

* combine wheelchair / retired questions
gen Q52_combo = Q52 
replace Q52_combo = Q52wc if Q52==.
gen Q53_combo = Q53 
replace Q53_combo = Q53wc if Q53==.

foreach q in Q11 Q20 Q21 Q22 Q70 Q71 Q72 {
	gen `q'_combo = `q'
	replace `q'_combo = `q'_retired if mi(`q')
}

foreach q in Q11 Q12 Q19 Q72 {
	ds `q'_retired_*
	local vars "`r(varlist)'"
	foreach v in `vars' {
		local v2 = subinstr("`v'", "retired", "combo", 1)
		local v_notret = subinstr("`v'", "_retired", "", 1)
		gen `v2' = `v_notret'
		replace `v2' = `v' if mi(`v_notret')
	}
}

* indicator for no health problems reported
gen no_health_problems = num_health_problems==0 if !mi(num_health_problems)

* change negative free-numeric responses to positive
replace Q73 = abs(Q73) if !mi(Q73)
replace Q78a = abs(Q78a) if !mi(Q78a)


*==================================================================================================
* Save
*==================================================================================================

* drop unnecessary variables
drop *_nonmi

* save
save "Data/HFCS/clean_data/interim/interim1.dta", replace
