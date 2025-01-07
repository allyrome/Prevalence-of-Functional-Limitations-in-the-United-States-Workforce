* CBBS - Job Profile Limitations Analysis
* Author: Alexandra Rome
* Purpose: Analyze job profile limitations and their relationship with educational attainment
*  1. Process non-numeric job profile items and save as `non_numeric_positions'
*  2. Process numeric job profile items, clean variable names, and collapse data
*  3. Merge and reshape data to create indicators for limitations by education level
*  4. Map job profile items to HFCS questions

*==================================================================================================

cd "C:\Users\arome\HMS Dropbox\Alexandra Rome\Medical Conditions Affecting Work Capacity" 

* Call non-numeric job requirements(limitations)
use "Data\CBBS job profiles\Intermediate data files\non_numeric_items_wide_by_job_profiles.dta" , clear

* Merge in Education Requirment
merge 1:1 JobId using "Data\CBBS job profiles\Intermediate data files\general_items_by_job_profiles.dta"
drop if _merge != 3
drop _merge

* Create indicator for if a job requires a college degree
gen college_degree = (AbilityEducationLevel == 6 | AbilityEducationLevel == 7)

* Keep variables of interest
keep JobId JobProfileItem_19-JobProfileItem_55 college_degree

*Rehsape from wide to long so each jobprofile item is a row
reshape long JobProfile, i(JobId) j(JobProfileItem) string
rename JobProfile limitation
replace JobProfileItem = "JobProfile" + JobProfileItem

* Create an indicator for whether a limitation is considered for that job profile
gen considered_indicator = 0
replace considered_indicator = 1 if limitation > 0

* Find the prevalence of each non-numeric limitation for all job profiles and education requirement
collapse (mean) considered_indicator ,by(JobProfileItem college_degree)

tempfile non_numeric_positions
save `non_numeric_positions'

* Same process with numeric- but more cleaning since limitations aren't considered in a binary manner

use "Data\CBBS job profiles\Intermediate data files\numeric_items_wide_by_job_profiles.dta" , clear

* Merge in education requirements
merge 1:1 JobId using "Data\CBBS job profiles\Intermediate data files\general_items_by_job_profiles.dta"
drop if _merge != 3
drop _merge

* Create indicator for needing a BA 
gen college_degree = (AbilityEducationLevel == 6 | AbilityEducationLevel == 7)

keep JobId JobProfileItem* college_degree

*Rehspae so each jobprofileitem (limitation) is a row
reshape long JobProfile, i(JobId) j(JobProfileItem) string
rename JobProfile limitation
replace JobProfileItem = "JobProfile" + JobProfileItem

* Create an indicator for whether a limitation is considered
gen considered_indicator = .
replace considered_indicator = 0 if limitation == 0 | missing(limitation)
replace considered_indicator = 1 if limitation > 0 & !missing(limitation) 

* Since there are multiple rows for singular job profile items we need to frst collapse to the job profile item (limitation) itself. (JobProfileItem_3_a_A JobProfileItem_3_a_B JobProfileItem_3_a_C JobProfileItem_3_a_D need to become JobProfileItem_3_a where the limitation indicator is 1 if any are over 0)

* This requires some cleaning of the text first

* Substring the JobProfileItem names
replace JobProfileItem = substr(JobProfileItem, 1, 20)

* Rename 27a and 27b accordingly
replace JobProfileItem = "JobProfileItem_27a" if JobProfileItem == "JobProfileItem_27_vl" | JobProfileItem == "JobProfileItem_27_li"
replace JobProfileItem = "JobProfileItem_27b" if JobProfileItem == "JobProfileItem_27_he" 

*Substring again, with the exception of the few longer Job Profile Item names 
replace JobProfileItem = substr(JobProfileItem, 1, 18) if JobProfileItem != "JobProfileItem_2728" & JobProfileItem != "JobProfileItem_2728_" & JobProfileItem != "JobProfileItem_27a" & JobProfileItem != "JobProfileItem_27b" & JobProfileItem != "JobProfileItem_14_a_" & JobProfileItem != "JobProfileItem_14_b" & JobProfileItem != "JobProfileItem_17_a_" & JobProfileItem != "JobProfileItem_17_b"

* Remove trailing "_"
replace JobProfileItem = regexr(JobProfileItem, "_$", "")

* Clean job profile items 6-8 accordingly
replace JobProfileItem = "JobProfileItem_7" if JobProfileItem == "JobProfileItem_7_4" | JobProfileItem == "JobProfileItem_7_m"
replace JobProfileItem = "JobProfileItem_6" if JobProfileItem == "JobProfileItem_6_4" | JobProfileItem == "JobProfileItem_6_m"
replace JobProfileItem = "JobProfileItem_8a" if JobProfileItem == "JobProfileItem_8_a"
replace JobProfileItem = "JobProfileItem_8b" if JobProfileItem == "JobProfileItem_8_b"

* Collapse by JobProfileItem
collapse (max) considered_indicator (first) college_degree, by(JobId JobProfileItem)

* Sum all positions by limitation
collapse (mean) considered_indicator,by(JobProfileItem college_degree)

append using `non_numeric_positions'

reshape wide considered_indicator, i(JobProfileItem) j(college_degree)
rename considered_indicator0 no_college_degree
rename considered_indicator1 college_degree

* Add HFCS Question numbers
gen Question = ""

	* Sphere handle (19)
	replace Question = "Q37_1" if JobProfileItem == "JobProfileItem_19"
	
	* Pen grip (20)
	replace Question = "Q37_2" if JobProfileItem == "JobProfileItem_20" 
	
	* Tweezer grip (21)
	replace Question = "Q37_3" if JobProfileItem == "JobProfileItem_21" 

	* Key handle (22)
	replace Question = "Q37_4" if JobProfileItem == "JobProfileItem_22" 
	
	* Cylinder handle (23)
	replace Question = "Q37_6" if JobProfileItem == "JobProfileItem_23" 
	
	* Squeezing/gripping force (24)
	replace Question = "Q37_5" if JobProfileItem == "JobProfileItem_24" 
	
	* Fine motor skills (25)
	replace Question = "Q37_7" if JobProfileItem == "JobProfileItem_25" 
	
	* Repetitive acts (26)
	replace Question = "Q37_8" if JobProfileItem == "JobProfileItem_26" 
	
	* Push pull (29) Alternate specification from UWV Matrix 
	replace Question = "Q46" if JobProfileItem == "JobProfileItem_29" 
		
	* Tour (30)
	replace Question = "Q27" if JobProfileItem == "JobProfileItem_30" 
	
	* Dust, Smoke, Gases, Vapors (31)
	replace Question = "Q30" if JobProfileItem == "JobProfileItem_31" 
	
	* Cold (32) Alternate specification from UWV Matrix
	replace Question = "Q26" if JobProfileItem == "JobProfileItem_32" 
	
	* Heat (33) Alternate specification from UWV Matrix
	replace Question = "Q25" if JobProfileItem == "JobProfileItem_33" 
	
	* Skin contact (34)
	replace Question = "Q28" if JobProfileItem == "JobProfileItem_34" 
	
	* Vibrations (35)
	replace Question = "Q32" if JobProfileItem == "JobProfileItem_35" 
	
	* See (36)
	replace Question = "Q20_combo" if JobProfileItem == "JobProfileItem_36" 
	
	* Hearing (37)
	replace Question = "Q21_combo" if JobProfileItem == "JobProfileItem_37" 
	
	* To speak (38)
	replace Question = "Q22_combo" if JobProfileItem == "JobProfileItem_38" 
	
	* Read (39)
	replace Question = "Q24" if JobProfileItem == "JobProfileItem_39" 
	
	* Write (40)
	replace Question = "Q23" if JobProfileItem == "JobProfileItem_40" 
	
	* Noise (41)
	replace Question = "Q31" if JobProfileItem == "JobProfileItem_41" 
	
	* Protective equipment (42)
	replace Question = "Q29" if JobProfileItem == "JobProfileItem_42" 
	
	* Personal risk (43)
	replace Question = "Q12_combo_10" if JobProfileItem == "JobProfileItem_43" 
	
	* Touch sense (44)
	replace Question = "Q38" if JobProfileItem == "JobProfileItem_44" 
	
	* Screw movement (45)
	replace Question = "Q40" if JobProfileItem == "JobProfileItem_45" 
	
	* Rate of action (47)
	replace Question = "Q12_combo_9" if JobProfileItem == "JobProfileItem_47" 
	
	* Deadlines/production peaks (48)
	replace Question = "Q12_combo_8" if JobProfileItem == "JobProfileItem_48" 
	
	* Frequent contact with customers (49)
	replace Question = "Q19_combo_2" if JobProfileItem == "JobProfileItem_49" 
	
	* Managerial aspects (51)
	replace Question = "Q19_combo_5" if JobProfileItem == "JobProfileItem_51" 
	
	* Dealing with conflicts (52)
	replace Question = "Q15" if JobProfileItem == "JobProfileItem_52" 
	
	* Collaborate (53)
	replace Question = "Q19_combo_4" if JobProfileItem == "JobProfileItem_53" 
		* Two HFCS questions map to one job profile item 
		* And there is one job profile item we don't have a question for
		* So chnage that job profile to this one and map to other HFCS
		replace Question = "Q16" if JobProfileItem == "JobProfileItem_55" 
		replace JobProfileItem = "JobProfileItem_53" if JobProfileItem == "JobProfileItem_55" 	
	
	* Dealing with patients (54)
	replace Question = "Q19_combo_3" if JobProfileItem == "JobProfileItem_54" 

	* 3a: Sitting - Consecutive
	replace Question = "Q60" if JobProfileItem == "JobProfileItem_3_a"
		
	* 3b: Sitting - Cumulative 
	replace Question = "Q61" if JobProfileItem == "JobProfileItem_3_b"
			
	* 4a: Standing - Consecutive
	replace Question = "Q62" if JobProfileItem == "JobProfileItem_4_a"
	
	* 4b: Standing - Cumulative 
	replace Question = "Q63" if JobProfileItem == "JobProfileItem_4_b"
		
	* 5a: Walking - Consecutive 
	replace Question = "Q52_combo" if JobProfileItem == "JobProfileItem_5_a"
	
	* 5b: Walking - Cumulative 
	replace Question = "Q53_combo" if JobProfileItem == "JobProfileItem_5_b"
	
	* 6: Climbing Stairs
	replace Question = "Q54" if JobProfileItem == "JobProfileItem_6"
	
	* 7: Climbing
	replace Question = "Q55" if JobProfileItem == "JobProfileItem_7"
	
	* 8a: Kneeling/Squating
	replace Question = "Q57" if JobProfileItem == "JobProfileItem_8a"
	
	* 8b: Active While Kneeling/Squating 
	replace Question = "Q64" if JobProfileItem == "JobProfileItem_8b"
		
* 9: Crawling 
		
	* 11: Active While Bending 
	replace Question = "Q65" if JobProfileItem == "JobProfileItem_11"
	
* 12: Active While Twisting 
	
	* 13: Short-Cycle Twisting 
	replace Question = "Q45" if JobProfileItem == "JobProfileItem_13"
		
	* 14a: Short-Cycle Bending - Degree
	replace Question = "Q43" if JobProfileItem == "JobProfileItem_14_a"
	
	* 14b: Short-Cycle Bending - Frequency
	replace Question = "Q44" if JobProfileItem == "JobProfileItem_14_b"
	
	* 15: Head Movements 
	replace Question = "Q50" if JobProfileItem == "JobProfileItem_15"
	
	* 16: Head Fixation 
	replace Question = "Q67" if JobProfileItem == "JobProfileItem_16"
	
	* 17a: Reaching - Degree
	replace Question = "Q41" if JobProfileItem == "JobProfileItem_17_a"
	
	* 17b: Reaching - Frequency 
	replace Question = "Q42" if JobProfileItem == "JobProfileItem_17_b"
	
	* 18: Active Above Shoulder
	replace Question = "Q66" if JobProfileItem == "JobProfileItem_18"
		
	* 27/28: Lifting/Carrying - Max Weight 
	replace Question = "Q47" if JobProfileItem == "JobProfileItem_2728"

	* 27a: Lifting - Light Weight 
	replace Question = "Q48" if JobProfileItem == "JobProfileItem_27a"

	* 27b: Lifting - Heavy Weight
	replace Question = "Q49" if JobProfileItem == "JobProfileItem_27b"

	* 46: Keyboard/Mouse - Cumulative 
	replace Question = "Q39" if JobProfileItem == "JobProfileItem_46"
	
	save "Papers\Burdens of Functional Limitations\Appendix\restricted_limitations\job_profiles_limitations_education" , replace
