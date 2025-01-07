* HFCS - clean data
* Author: Michael Jetupphasuk (Updated by Hailey Clark to reflect full FML of limitations/impairments/accomodations)
* Purpose: collapse all impairments into binary and put into same direction

*==================================================================================================

* PREPARATION

* cd "C:/Users/arome/Dropbox (HMS)/Medical Conditions Affecting Work Capacity"

* load data 
use "Data/HFCS/clean_data/HFCS_CLEAN.dta", clear

drop Q89* Q90*
rename (*a_*) (*_*)

* Create education categories 
gen ed_grade9 = (inlist(Q74, 2, 3))
gen ed_no_diploma = (inlist(Q74, 4))
gen ed_less_ba = (inlist(Q74, 5, 6, 7, 8))
gen ed_ba_or_more = (inlist(Q74, 9, 10, 11, 12))


* Craete field question
	* Create field varaibles for those asked field question (must have a degree)
	gen field1 = (Q74_1 == 1)
	gen field2 = (Q74_2 == 1)
	gen field3 = (Q74_3 == 1)
	gen field4 = (Q74_4 == 1)
	gen field5 = (Q74_5 == 1)
	gen field6 = (Q74_6 == 1)
	gen field7 = (Q74_7 == 1)
	gen field8 = (Q74_8 == 1)

	* Assign general field for those without degrees
	replace field8 = 1 if inlist(Q74, 1, 2, 3, 4, 5, 6)

* Create experience categories
	gen max_yrs_exp = . 
	replace max_yrs_exp = (AGE - 16) if inlist(Q74, 1, 2, 3)
	replace max_yrs_exp = (AGE - 17) if Q74 == 4
	replace max_yrs_exp = (AGE - 18) if Q74 == 5
	replace max_yrs_exp = (AGE - 20) if inlist(Q74, 6, 7, 8)
	replace max_yrs_exp = (AGE - 22) if Q74 == 9
	replace max_yrs_exp = (AGE - 22) if Q74 == 10
	replace max_yrs_exp = (AGE - 22) if Q74 == 11
	replace max_yrs_exp = (AGE - 22) if Q74 == 12
	
	gen experience_0 = (max_yrs_exp == 0)
	gen experience_1 = (max_yrs_exp == 1)
	gen experience_2 = (max_yrs_exp == 2)
	gen experience_3 = (max_yrs_exp == 3)
	gen experience_4 = (max_yrs_exp == 4)
	gen experience_5 = (max_yrs_exp == 5)
	gen experience_6 = (max_yrs_exp == 6)
	gen experience_7 = (max_yrs_exp == 7)
	gen experience_8_9 = (max_yrs_exp == 8 | max_yrs_exp == 9)
	gen experience_10 = (max_yrs_exp >= 10 & max_yrs_exp != .)
	
* Create Night work binary

	gen night_work = (Q69 <= 1)

*==================================================================================================
* Collapse impairments and put into same direction
*==================================================================================================

* no impairment: 1=0; impairment level increases from 1 to max
# delimit ;
local temp_vars "Q5 Q6 Q7 Q8 Q13 Q14 Q15 Q16 Q17 
	Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q32 
	Q39 Q41 Q42 Q43 Q44 Q46 Q47 Q48 Q49 Q50 Q54 Q55 Q56 Q57 Q58 
	Q60 Q61 Q62 Q63 Q67 
	Q52_combo Q53_combo
	Q70_combo Q71_combo";
# delimit cr 
recode `temp_vars' (1=0) (2=1) (3=2) (4=3) (5=4)

* no impairment: 1=0; 3rd level is NA
# delimit ; 
local temp_vars1 "
	Q69
"; 
# delimit cr
recode `temp_vars1' (1=0) (2=1) (3=.)

* no impairment: 2=0
# delimit ;
local temp_vars2 "Q18 Q23 Q24 
	Q34 Q38 
	Q40 Q45
	Q59
	Q64 Q65 Q66 Q68  
	Q72
	Q11_combo Q20_combo Q21_combo Q22_combo";
# delimit cr
recode `temp_vars2' (2=0) (1=1)

* custom
recode Q35 (3=0)
recode Q36 (4=0)

* FML item 4.17 is split across two questions Q50 and Q50a; so combine
replace Q50 = 2 if Q50a==2
replace Q50 = 3 if Q50a==3

   
# delimit ;
local use_impair "Q5 Q6 Q7 Q8 Q9_1 Q9_2 Q9_3 Q9_4 Q9_5 Q10_1 Q10_2 Q10_3 Q10_4 Q10_5 Q10_6 Q10_7 Q10_8 Q10_9 Q11_combo Q12_combo_2 Q12_combo_3 Q12_combo_4 Q12_combo_5 Q12_combo_6 Q12_combo_7 Q12_combo_8 Q12_combo_9 Q12_combo_10 Q12_combo_11 Q13 Q14 Q15 Q16 Q17 Q18 Q19_combo_2 Q19_combo_3 Q19_combo_4 Q19_combo_5 Q19_combo_6 Q20_combo Q21_combo Q22_combo Q23 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q32 Q33_2 Q33_3 Q33_4 Q33_5 Q34 Q35 Q36 Q37_1 Q37_2 Q37_3 Q37_4 Q37_5 Q37_6 Q37_7 Q37_8 Q38 Q39 Q40 Q41 Q42 Q43 Q44 Q45 Q46 Q47 Q48 Q49 Q50 Q51 Q52_combo Q53_combo Q54 Q55 Q56 Q57 Q58 Q59 Q60 Q61 Q62 Q63 Q64 Q65 Q66 Q67 Q68 Q69 Q70_combo Q71_combo Q72
";
# delimit cr 
local demo "working retired disabled EMPSTAT_UNEMP EMPSTAT_LO AGE age_grp3 female college college2 college3 hand_assign_use certainty_use Q81 URBAN_RURAL think_social_other"
keep prim_key `demo' pass_screener think_social_qualify weight `use_impair' ed_grade9 ed_no_diploma ed_less_ba ed_ba_or_more field1 field2 field3 field4 field5 field6 field7 field8 experience_0 experience_1 experience_2 experience_3 experience_4 experience_5 experience_6 experience_7 experience_8_9 experience_10 night_work
order prim_key `demo' pass_screener think_social_qualify weight `use_impair' ed_grade9 ed_no_diploma ed_less_ba ed_ba_or_more field1 field2 field3 field4 field5 field6 field7 field8 experience_0 experience_1 experience_2 experience_3 experience_4 experience_5 experience_6 experience_7 experience_8_9 experience_10 night_work

* strip value labels (they don't have interpretation in new coding)
_strip_labels `use_impair'

* save
save "Data/HFCS/clean_data/hfcs_clean_recodes_full_fml.dta", replace