* HFCS - clean data
* Authors: - Bastian Ravesteijn
*		   - Michael Jetsupphasuk
* Purpose: add variable and value labels

*==================================================================================================

* load data
use "Data/HFCS/clean_data/interim/interim1.dta", clear


*==================================================================================================
* Label survey questions
*==================================================================================================

* Label health condition questions
lab var Q1_bone_1 "Arthritis"
lab var Q1_bone_2 "Rheumatoid arthritis"
lab var Q1_bone_3 "Back pain due to spinal stenosis"
lab var Q1_bone_4 "Back pain due to other causes"
lab var Q1_bone_5 "Neck pain"
lab var Q1_bone_6 "Fibromyalgia"
lab var Q1_bone_7 "Lupus"
lab var Q1_bone_8 "Ehlers-Danlos syndrome"
lab var Q1_bone_9 "Deformity of limb"
lab var Q1_bone_10 "Amputation of limb"
lab var Q1_bone_11 "Severe burn"
lab var Q1_bone_12 "Other muscle or connective tissue disorder"
lab var Q1_bone_13 "Other bone or joint disorder"
lab var Q1_bone_14 "Other injury"
lab var Q1_bone_15 "None of these (bone)"
lab var Q1_bone_fu1 "Joints affected by arthritis"

lab var Q1_nervous_1 "Spinal cord injury"
lab var Q1_nervous_2 "Multiple sclerosis"
lab var Q1_nervous_3 "Seizure disorder"
lab var Q1_nervous_4 "Parkinson's disease"
lab var Q1_nervous_5 "Stroke (or effects of a prior stroke)"
lab var Q1_nervous_6 "Migraine"
lab var Q1_nervous_7 "Blindness"
lab var Q1_nervous_8 "Deafness"
lab var Q1_nervous_9 "Nerve problem causing numbness or pain"
lab var Q1_nervous_10 "Other nervous system disorder"
lab var Q1_nervous_11 "None of these (nervous)"
lab var Q1_nervous_fu1 "Spinal cord resulted in paralysis; which limbs?"
lab var Q1_nervous_fu2 "Cause of vision loss"
lab var Q1_nervous_fu3 "Cause of hearing loss"

lab var Q1_heart_1 "Heart failure"
lab var Q1_heart_2 "Coronary artery disease"
lab var Q1_heart_3 "Heart valve dysfunction"
lab var Q1_heart_4 "Peripheral arterial disease"
lab var Q1_heart_5 "Abnormal heart rhythm"
lab var Q1_heart_6 "Lymphedema"
lab var Q1_heart_7 "Other heart or circulatory system disorder"
lab var Q1_heart_8 "None of these (heart)"

lab var Q1_lung_1 "Asthma"
lab var Q1_lung_2 "Chronic obstructive pulmonary disease/emphysema"
lab var Q1_lung_3 "Interstitial lung disease/pulmonary fibrosis"
lab var Q1_lung_4 "Pulmonary hypertension"
lab var Q1_lung_5 "Other lung disease"
lab var Q1_lung_6 "None of these (lung)"

lab var Q1_gastro_1 "Crohn's disease"
lab var Q1_gastro_2 "Ulcerative colitis"
lab var Q1_gastro_3 "Liver disease/cirrhosis"
lab var Q1_gastro_4 "Chronic kidney disease not on dialysis"
lab var Q1_gastro_5 "Chronic kidney disease on dialysis"
lab var Q1_gastro_6 "Other gastrointestinal disorder"
lab var Q1_gastro_7 "Other kidney or bladder disorder"
lab var Q1_gastro_8 "None of these (gastro)"

lab var Q1_infectious_1 "HIV"
lab var Q1_infectious_2 "Hepatitis C"
lab var Q1_infectious_3 "Other infectious disease"
lab var Q1_infectious_4 "None of these (infectious)"

lab var Q1_mental_1 "Schizophrenia"
lab var Q1_mental_2 "Bipolar disorder"
lab var Q1_mental_3 "Depression"
lab var Q1_mental_4 "Anxiety"
lab var Q1_mental_5 "ADHD"
lab var Q1_mental_6 "PTSD"
lab var Q1_mental_7 "Personality disorder"
lab var Q1_mental_8 "Alzheimer's disease"
lab var Q1_mental_9 "Other dementia"
lab var Q1_mental_10 "Other mental or cognitive disorder"
lab var Q1_mental_11 "Alcohol dependence"
lab var Q1_mental_12 "Opioid dependence"
lab var Q1_mental_13 "Other substance use disorder"
lab var Q1_mental_14 "None of these (mental)"

lab var Q1_other_1 "Cancer"
lab var Q1_other_2 "Diabetes"
lab var Q1_other_3 "Obesity"
lab var Q1_other_4 "Down syndrome"
lab var Q1_other_5 "Cerebral palsy"
lab var Q1_other_6 "Sleep disorder"
lab var Q1_other_7 "Chronic fatigue syndrome"
lab var Q1_other_8 "Chronic pain"
lab var Q1_other_9 "Sickle cell anemia"
lab var Q1_other_10 "Immune deficiency"
lab var Q1_other_11 "Other blood disorder"
lab var Q1_other_12 "Other developmental disorder"
lab var Q1_other_13 "Other health problem"
lab var Q1_other_14 "None of these (other)"
lab var Q1_other_fu2_1 "Type of cancer"
lab var Q1_other_fu2_2 "Has cancer spread"
lab var Q1_other_fu3 "Where do you have pain?"

lab var Q1_bone_12_other "Other Muscle or Connective Tissue Disorder (text)"
lab var Q1_bone_13_other "Other Bone or Joint Disorder (text)"
lab var Q1_bone_14_other "Other Injury (text)"
lab var Q1_nervous_10_other "Other Nervous System Disorder (text)"
lab var Q1_heart_7_other "Other Heart or Circulatory System Disorder (text)"
lab var Q1_lung_5_other "Other Lung Disease (text)"
lab var Q1_gastro_6_other "Other Gastrointestinal Disorder (text)"
lab var Q1_gastro_7_other "Other Kidney or Bladder Disorder (text)"
lab var Q1_infectious_3_other "Other Infectious Disease (text)"
lab var Q1_mental_7_other "Personality Disorder (text)"
lab var Q1_mental_9_other "Other Dementia (text)"
lab var Q1_mental_10_other "Other Mental or Cognitive Disorder (text)"
lab var Q1_mental_13_other "Other Substance Use Disorder (text)"
lab var Q1_other_11_other "Other Blood Disorder (text)"
lab var Q1_other_12_other "Other Developmental Disorder (text)"
lab var Q1_other_13_other "Other Health Problem (text)"


* Set common labels
lab define noyes 0 "No (0)" 1 "Yes (1)"
lab define yesno 1 "Yes (1)" 2 "No (2)"
lab define yesnamelyno 1 "Yes, namely... (1)" 2 "No (2)"

local noyesvars Q1_bone_1 Q1_bone_2 Q1_bone_3 Q1_bone_4 Q1_bone_5 Q1_bone_6 Q1_bone_7 Q1_bone_8 Q1_bone_9 ///
Q1_bone_10 Q1_bone_11 Q1_bone_12 Q1_bone_13 Q1_bone_14 Q1_bone_15 Q1_bone_fu2_1 ///
Q1_bone_fu2_2 Q1_bone_fu2_3 Q1_bone_fu2_4 Q1_nervous_1 Q1_nervous_2 Q1_nervous_3 ///
Q1_nervous_4 Q1_nervous_5 Q1_nervous_6 Q1_nervous_7 Q1_nervous_8 Q1_nervous_9 ///
Q1_nervous_10 Q1_nervous_11 Q1_heart_1 Q1_heart_2 Q1_heart_3 Q1_heart_4 Q1_heart_5 ///
Q1_heart_6 Q1_heart_7 Q1_heart_8 Q1_lung_1 Q1_lung_2 Q1_lung_3 Q1_lung_4 Q1_lung_5 ///
Q1_lung_6 Q1_gastro_1 Q1_gastro_2 Q1_gastro_3 Q1_gastro_4 Q1_gastro_5 Q1_gastro_6 ///
Q1_gastro_7 Q1_gastro_8 Q1_infectious_1 Q1_infectious_2 Q1_infectious_3 Q1_infectious_4 ///
Q1_mental_1 Q1_mental_2 Q1_mental_3 Q1_mental_4 Q1_mental_5 Q1_mental_6 Q1_mental_7 ///
Q1_mental_8 Q1_mental_9 Q1_mental_10 Q1_mental_11 Q1_mental_12 Q1_mental_13 Q1_mental_14 ///
Q1_other_1 Q1_other_2 Q1_other_3 Q1_other_4 Q1_other_5 Q1_other_6 Q1_other_7 Q1_other_8 ///
Q1_other_9 Q1_other_10 Q1_other_11 Q1_other_12 Q1_other_13 Q1_other_14 Q1_other_fu1 ///
Q2_limitsActiv_1 Q2_limitsActiv_2 Q2_limitsActiv_3 ///
Q4_1-Q4_11 Q9a_1-Q9a_5 Q10a_1-Q10a_9 Q12_retired_1-Q12_retired_11 ///
Q12_1-Q12_11 Q19_retired_1-Q19_retired_6 Q19_1-Q19_6 Q33_2-Q33_5 Q33_1 Q37a_1-Q37a_8 ///
Q74a_1-Q74a_8 Q75a_1-Q75a_8 Q86_1-Q86_9 Q87_1-Q87_8 Q87_9 Q88_1-Q88_7 Q88_8 ///
Q89_1-Q89_7 Q89_8 Q89a_1-Q89a_7 Q89a_8 ///
dis_ret_oth retired working disabled think_social_qualify think_social_other pass_screener ///
wheelchair age50 female college Q2_limitsAny any_impair_thinking any_impair_social ///
any_impair_senses any_impair_physical any_impair_movement any_impair_holding ///
any_impair_work severe_socthi any_impair_socthi no_health_problems
foreach i in `noyesvars'{
	lab val `i' noyes
}

local yesnovars Q20_retired ///
Q21_retired Q22_retired Q20 Q21 Q22 Q23 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q32 Q33a Q37 Q38 ///
Q40 Q45 Q64 Q65 Q66 Q75 Q76 Q78 
foreach i in `yesnovars'{
	lab val `i' yesno
}

* Label variables and values
lab var Q1_bone_fu2_1 "Limb amputated because of traumatic injury"
lab var Q1_bone_fu2_2 "Limb amputated because of diabetes"
lab var Q1_bone_fu2_3 "Limb amputated because of peripheral arterial disease"
lab var Q1_bone_fu2_4 "Limb amputated for other reasons [exclusive]"

lab var Q1_other_fu1 "Nerve damage as a result of diabetes"
lab define Q1_other_fu1 1 "Yes (1)" 2 "No (2)" 3 "Don't know (3)"
lab val Q1_other_fu1 Q1_other_fu1

lab var Q2_limitsActiv_1 "Health problem 1 limits activities"
lab var Q2_limitsActiv_2 "Health problem 2 limits activities"
lab var Q2_limitsActiv_3 "Health problem 3 limits activities"

lab var Q3 "Has your health or function gotten much worse in the past 12 months?"
lab val Q3 yesnamelyno

lab var Q4_1 "Serious mental illness"
lab var Q4_2 "Hospital, nursing home or other medical facility"
lab var Q4_3 "Currently confined to a bed due to medical problems"
lab var Q4_4 "Need help getting in or out bed or chair"
lab var Q4_5 "Need help with dressing"
lab var Q4_6 "Need help with using the toilet"
lab var Q4_7 "Need help with bathing/showering"
lab var Q4_8 "Need help with eating"
lab var Q4_9 "Difficulty with controlling urination bowels"
lab var Q4_10 "Probably not live for more than 1 year"
lab var Q4_11 "None of these statements applies to me [exclusive]"

lab var Q5 "For how long can you focus your attention?"
lab define Q5 1 "At least 30 minutes (1)" 2 "Longer than 5 minutes, but less than 30 minutes (2)" 3 "Less than 5 minutes (3)"
lab val Q5 Q5 

lab var Q6 "How well are you able to do multiple things at once?"
lab define Q6 1 "I can do multiple tasks at the same time (1)" 2 "Difficulty with doing a task if there are other demands (2)" 3 "Not capable of doing more than one task at a time (3)"
lab val Q6 Q6 

lab var Q7 "Which of the following best describes your memory?"
lab define Q7 1 "Can usually remember routine daily activities without difficulty (1)" 2 "Cannot do ANY  daily activities without lists (2)" 3 "Cannot remember what I need to do each day (3)"
lab val Q7 Q7 

lab var Q8 "Which of the following best describes how well you are able to estimate your abilities and limitations?"
lab define Q8 1 "I can usually correctly guess (1)" 2 "Often, I feel certain that I CAN do but it turns out that I cannot (2)" 3 "I feel that I CANNOT do a particular task, others tell me I can (3)"
lab val Q8 Q8 

lab var Q9 "Are you able to plan and do simple routine daily activities? "
lab define Q9 1 "Can perform routine activities by myself (1)" 2 "Have difficulties with simple activities (2)"
lab val Q9 Q9 

lab var Q9a_1 "Cannot correctly estimate how long it will take" 
lab var Q9a_2 "Not able to prioritize, and often don't finish" 
lab var Q9a_3 "Not able to adequately monitor the progress of my activities"
lab var Q9a_4 "Not able to stop activities when I should"
lab var Q9a_5 "Other difficulties with simple activities, namely..."

lab var Q10 "Independently do activities that are less routine"
lab define Q10 1 "Able to independently do activities that are less routine (1)" 2 "Difficulties with independently doing less routine activities (2)" 
lab val Q10 Q10 

lab var Q10a_1 "Usually do not start activities myself"
lab var Q10a_2 "Usually do not set goals for myself"
lab var Q10a_3 "Difficulty sticking with my plan and often stop before the job is done"
lab var Q10a_4 "Unable to think of ways to do it "
lab var Q10a_5 "Unable to decide which way of doing it is the best"
lab var Q10a_6 "Great difficulty realizing when I've made the wrong choice"
lab var Q10a_7 "Difficulty with choosing a different way to do it"
lab var Q10a_8 "Difficulty with asking for help "
lab var Q10a_9 "Other difficulties in doing activities independently, namely..."

lab var Q11_retired "Other difficulties with thinking that affect ability to work (if chose to work)"
lab val Q11_retired  yesnamelyno 

lab var Q12_retired_1 "No special supports needed because of thinking [exclusive]"
lab var Q12_retired_2 "Can only do work that is completely planned out in advance by someone else"
lab var Q12_retired_3 "Can only do work that is mostly planned out in advance by someone else"
lab var Q12_retired_4 "Need constant supervision and guidance to do my job"
lab var Q12_retired_5 "Can only work in an environment without distractions"
lab var Q12_retired_6 "Can only do work that is predictable"
lab var Q12_retired_7 "Can only do work where there are few interruptions"
lab var Q12_retired_8 "Can only do work where deadlines do not occur often"
lab var Q12_retired_9 "Cannot do work that requires a fast pace the majority of the time"
lab var Q12_retired_10 "Cannot do work that places me at high physical risk"
lab var Q12_retired_11 "Other accommodations are needed due to my thinking, namely..."

lab var Q11 "Other difficulties with thinking that affect ability to work )"
lab val Q11 yesnamelyno

lab var Q12_1 "No special supports needed because of thinking [exclusive]"
lab var Q12_2 "Can only do work that is completely planned out in advance by someone else"
lab var Q12_3 "Can only do work that is mostly planned out in advance by someone else"
lab var Q12_4 "Need constant supervision and guidance to do my job"
lab var Q12_5 "Can only work in an environment without distractions"
lab var Q12_6 "Can only do work that is predictable"
lab var Q12_7 "Can only do work where there are few interruptions"
lab var Q12_8 "Can only do work where deadlines do not occur often"
lab var Q12_9 "Cannot do work that requires a fast pace the majority of the time"
lab var Q12_10 "Cannot do work that places me at high physical risk"
lab var Q12_11 "Other accommodations are needed due to my thinking, namely..."

lab var Q13 "How do other peoples' emotional problems affect you?"
lab define Q13 1 "These feelings do not affect my behavior or my ability to complete my activities (1)" 2 "I can still complete my activities, but this requires a great deal of extra effort (2)" 3 "I'm unable to distance myself from them and complete my activities (3)"
lab val Q13 Q13 

lab var Q14 "How do you express your feelings to others?"
lab define Q14 1 "I can express my feelings in a way that is clear and acceptable to others (1)" 2 "I often confuse other people or make them uncomfortable (2)" 3 "I have very little control over how I express my feelings (3)" 
lab val Q14 Q14 

lab var Q15 "How do you cope with conflicts with difficult people? "
lab define Q15 1 "I can handle conflicts with difficult people (1)" 2 "I can only handle these conflicts by telephone, letters, or email (2)" 3 "I can't tolerate or resolve these conflicts on my own (3)"
lab val Q15 Q15 

lab var Q16 "Which of the following best describes your ability to work in teams?"
lab define Q16 1 "I have no difficulties working in teams (1)" 2 "I can work in teams, but only if my tasks are clearly mine (2)" 3 "I am unable to work in teams (3)"
lab val Q16 Q16 

lab var Q17 "Which of the following best describes your ability to get yourself places?"
lab define Q17 1 "Independently (1)" 2 "I need help from others to transport myself (2)"
lab val Q17 Q17 

lab var Q18 "Are there any other ways your medical condition(s) affect your abilities to interact with people?"
lab val Q18 yesnamelyno

lab var Q19_retired_1 "No special supports needed [exclusive]"
lab var Q19_retired_2 "Only work with little to no contact with customers" 
lab var Q19_retired_3 "Only work where I do not have to take care of people"
lab var Q19_retired_4 "Only work where there is little to no contact with colleagues"
lab var Q19_retired_5 "No work that involves managing other people"
lab var Q19_retired_6 "Other accommodations would be needed regarding interactions with others, namely..."

lab var Q19_1 "No special supports needed [exclusive]"
lab var Q19_2 "Only work with little to no contact with customers" 
lab var Q19_3 "Only work where I do not have to take care of people"
lab var Q19_4 "Only work where there is little to no contact with colleagues"
lab var Q19_5 "No work that involves managing other people"
lab var Q19_6 "Other accommodations would be needed regarding interactions with others, namely..."

lab var Q20_retired "Problems with vision that might limit the types of work"

lab var Q21_retired "Problems with hearing that might limit the types of work"

lab var Q22_retired "Problems with speaking that might limit the types of work"

lab var Q20 "Problems with vision that might limit the types of work"

lab var Q21 "Problems with hearing that might limit the types of work"

lab var Q22 "Problems with speaking that might limit the types of work"

lab var Q23 "Problems with writing due to a medical condition"

lab var Q24 "Problems with reading large amounts of material at a regular pace"

lab var Q25 "Exposed to temperatures > 95 degrees Fahrenheit for at least 5 minutes"
 
lab var Q26 "Exposed to temperatures < 5 degrees Fahrenheit for at least 5 minutes"

lab var Q27 "Exposed to drafts or other sudden air movements"

lab var Q28 "Exposed to substances that make skin wet or dirty or cause skin irritation"

lab var Q29 "Able to wear protective equipment"

lab var Q30 "Exposed to dust smoke gas or steam"

lab var Q31 "Exposed to noise levels high enough that protective equipment must be worn"
 
lab var Q32 "Exposed to vibrations or jolts"

lab var Q33_2 "Yes, allergies"
lab var Q33_3 "Yes, higher risk of getting infections"
lab var Q33_4 "Yes, weakened skin"
lab var Q33_5 "Yes, other namely..."
lab var Q33_1 "No [exclusive]"

lab var Q33a "Current job requires to work in physical environments described before"

lab var Q33b "Specific accommodations that you receive to allow you to work in physical environments described before"
lab val Q33b yesnamelyno

lab var Q34 "Other specific accommodations needed to enable you to work in different physical environments"
lab val Q34 yesnamelyno

lab var Q35 "Hand preference"
lab define Q35 1 "Right (1)" 2 "Left (2)" 3 "Neither (3)"
lab val Q35 Q35 

lab var Q36 "Difficulties with functioning in either side of your body"
lab define Q36 1 "Right (1)" 2 "Left (2)" 3 "Both (3)" 4 "Neither (4)"
lab val Q36 Q36

lab var Q37 "Serious difficulties in using your hands and fingers in day-to-day life"

lab var Q37a_1 "Difficulty grasping round objects"
lab var Q37a_2 "Handling objects between the tips of 2 fingers and my thumb"
lab var Q37a_3 "Handling objects between the top of my index finger and my thumb"
lab var Q37a_4 "Limited grip strength with my fingers and thumb"
lab var Q37a_5 "Limited grip strength in my hand"
lab var Q37a_6 "Difficulty handling rod-shaped objects"
lab var Q37a_7 "Difficulty making accurate, fine movements with my fingers and hands"
lab var Q37a_8 "Difficulty making repetitive movements with my fingers and hands"

lab var Q38 "Limitations in your sense of touch"

lab var Q39 "Difficulties working with a mouse and keyboard"
lab define Q39 1 "Can use a mouse and keyboard for the majority of the day (1)" 2 "Can use a mouse and keyboard for approximately 4 hours per day (2)" 3 "can use a mouse and keyboard for approximately 1 hour per day (3)" 4 "can use a mouse and keyboard for no more than 30 minutes per day (4)"
lab val Q39 Q39 

lab var Q40 "Difficulties in making twisting movements with your hands or arms"

lab var Q41 "Difficulties in extending your arms"
lab define Q41 1 "Can fully extend at least one of my arms to reach objects farther than 2 feet (1)" 2 "Cannot fully extend either of my arms, but at least one of my arms can be extended most of the way (2)" 3 "I can extend either of my arms to a 90 degree angle at my elbow (3)" 4 "Cannot extend my arms at all (4)"
lab val Q41 Q41 

lab var Q42 "How many times per minute can you extend your arm"
lab define Q42 1 "At least 20 times per minute (1)" 2 "10 times per minute (2)" 3 "8 times per minute (3)" 4 "5 times per minute (4)"
lab val Q42 Q42 

lab var Q43 "Difficulties bending your upper body forward"
lab define Q43 1 "90 degrees (1)" 2 "60 degrees (2)" 3 "45 degrees (3)" 4 "Cannot bend forward at all (4)"
lab val Q43 Q43 

lab var Q44 "Times per minute you can bend your upper body forward"
lab define Q44 1 "At least 10 (1)" 2 "5 (2)" 3 "3 (3)" 4 "1 (4)"
lab val Q44 Q44 

lab var Q45 "Difficulties rotating your upper body to the side by at least 45 degrees"

lab var Q46 "Difficulties pulling or pushing objects"
lab define Q46 1 "Can pull or push 30 lbs (1)" 2 "Can pull or push 20 lbs (2)" 3 "Can pull or push 10 lbs (3)" 4 "Cannot pull or push at all (4)"
lab val Q46 Q46 

lab var Q47 "Difficulties lifting or carrying objects"
lab define Q47 1 "Can lift/carry 30 lbs (1)" 2 "Can lift/carry 20 lbs (2)" 3 "Can lift/carry 10 lbs (3)" 4 "Can lift/carry 4 lbs (4)"
lab val Q47 Q47 

lab var Q48 "Difficulty frequently handling light objects"
lab define Q48 1 "At least 10 times per munute (1)" 2 "5 times per minute (2)" 3 "3 times per minute (3)" 4 "Once a minute (4)"
lab val Q48 Q48 

lab var Q49 "Difficulties with frequently handling heavy loads"
lab define Q49 1 "Can handle 30 lbs at least 10 times per hour, or 1 hour per day (1)" 2 "unable to handle such loads (2)"
lab val Q49 Q49 

lab var Q50 "Difficulties with head movements"
lab define Q50 1 "No difficulties (1)" 2 "Unable to move my neck or head in these ways (2)"
lab val Q50 Q50 

lab var Q50a "What limitations with head movements"
lab define Q50a 1 "Somewhat limited in moving my head (1)" 2 "Severely limited in flexing or rotating my head to the side (2)" 3 "Severely limited in flexing or rotating my head to the side, and flexing up or down (3)"
lab val Q50a Q50a 

lab var Q51 "How do you move your body from place to place"
lab define Q51 1 "Walk independently (1)" 2 "Walk using a cane or walker for help (2)" 3 "Use a wheelchair without help from others (3)" 4 "unable to move my body from place to place without help from others (4)"
lab val Q51 Q51 

lab var Q52wc "Limitations in how long you can use a wheelchair at one time"
lab define Q52wc 1 "1 hour (1)" 2 "30 minutes (2)" 3 "15 minutes (3)" 4 "5 minutes (4)"
lab val Q52wc Q52wc 

lab var Q53wc "Total amount of wheelchair use you can do in an 8-working day"
lab define Q53wc 1 "Most of an 8-hour working day (1)" 2 "4 hours per day (2)" 3 "1 hour per day (3)" 4 "Less than 30 minutes per day (4)"
lab val Q53wc Q53wc 

lab var Q52 "Limitations in how long you can walk at one time"
lab define Q52 1 "1 hour (1)" 2 "30 minutes (2)" 3 "15 minutes (3)" 4 "5 minutes (4)"
lab val Q52 Q52

lab var Q53 "Total amount of walking you can do in an 8-working day"
lab define Q53 1 "Most of an 8-hour working day (1)" 2 "4 hours per day (2)" 3 "1 hour per day (3)" 4 "Less than 30 minutes per day (4)"
lab val Q53 Q53

lab var Q54 "Difficulties going up and down stairs"
lab define Q54 1 "Up and down at least 2 flights of stairs in one go, at least 4 times per hour (1)" 2 "Up and down at least 1 flight of stairs in one go (2)" 3 "Either up or down at least 1 flight of stairs in one go (3)" 4 "Up or down a few steps at most in one go (4)"
lab val Q54 Q54 

lab var Q55 "Difficulties climbing a ladder or stepladder"
lab define Q55 1 "Up and down a tall ladder (10 feet tall), at least 5 times per hour (1)" 2 "Up and down a stepladder (5 feet tall), at least 5 times per hour (2)" 3 "Up and down a single step or stepstool, at least 5 times per hour (3)" 4 "Unable to go up or down a single step (4)"
lab val Q55 Q55 

lab var Q56 "Difficulties with crawling on hands and knees"
lab define Q56 1 "Can crawl for 1 minute at a time, at least 10 times per hour (1)" 2 "Unable to crawl this much (2)"
lab val Q56 Q56 

lab var Q57 "Difficulties kneeling or squatting?"
lab define Q57 1 "Can kneel or squat briefly at least once an hour, for at least 4 hours a day (1)" 2 "Unable to kneel or squat this much (2)"
lab val Q57 Q57 

lab var Q58 "Pace at which you complete activities"
lab define Q58 1 "At a similar pace as my peers (1)" 2 "More slowly than my peers (2)"
lab val Q58 Q58 

lab var Q59 "Other difficulties with movement due to a medical condition"
lab val Q59 yesnamelyno 

lab var Q60 "Limitations in how long you can sit on a chair without needing to get up"
lab define Q60 1 "2 hours (1)" 2 "1 hour (2)" 3 "30 minutes (3)" 4 "15 minutes (4)"
lab val Q60 Q60 

lab var Q61 "Total amount of sitting you can do in an 8-hour working day "
lab define Q61 1 "At least 8 hours (1)" 2 "Most of the working day, but no more than 8 hours (2)" 3 "At least 4 hours (3)" 4 "Cannot sit for more than 4 hours (4)"
lab val Q61 Q61  

lab var Q62 "Limitations in how long you can stand at one time without resting"
lab define Q62 1 "1 hour (1)" 2 "30 minutes (2)" 3 "15 minutes (3)" 4 "No more than 5 minutes (4)" 5 "Cannot stand (5)"
lab val Q62 Q62 

lab var Q63 "Total amount of standing you can do in an 8-hour working day "
lab define Q63 1 "Most of an 8-hour working day (1)" 2 "Up to 4 hours (2)" 3 "Up to 1 hour (3)" 4 "No more than 30 minutes (4)"
lab val Q63 Q63 

lab var Q64 "Difficulties being active in kneeling/squatting position >=5 minutes at a time twice an hour"

lab var Q65 "Difficulties being active in bent or twisted position >=5 minutes at a time twice an hour"

lab var Q66 "difficulties keeping one arm lifted above shoulder height >=5 minutes at a time twice an hour"

lab var Q67 "Difficulties with holding your head in a specific position "
lab define Q67 1 "Most of an 8-hour working day (1)" 2 "Up to 4 hours (2)" 3 "Up to 1 hour (3)" 4 "No more than 30 minutes (4)"
lab val Q67 Q67 

lab var Q68 "Other difficulties with holding your body in specific positions due to a medical condition"
lab val Q68 yesnamelyno 

lab var Q69 "Current or last job, work at night at least 4 times a year?"
lab define Q69 1 "Yes (1)" 2 "No (2)" 3 "Never worked (3)"
lab val Q69 Q69 

lab var Q70_retired "Limits on the total number of hours you could work each day due to a medical condition"
lab define Q70_retired 1 "At least 8 hours per day on average (1)" 2 "Approximately 6 hours per day on average (2)" 3 "Approximately 4 hours per day on average (3)" 4 "At most 2 hours per day on average (4)"
lab val Q70_retired Q70_retired 

lab var Q71_retired "Limits on the total number of hours you could work each week due to a medical condition"
lab define Q71_retired 1 "At least 40 hours per week on average (1)" 2 "30 hours per week on average (2)" 3 "Approximately 20 hours per week on average (3)" 4 "Approximately 10 hours per week on average (4)"
lab val Q71_retired Q71_retired 

lab var Q72_retired "Other limitations in the hours you could work due to a medical condition"
lab val Q72_retired yesnamelyno

lab var Q70 "Limits on the total number of hours you could work each day due to a medical condition"
lab define Q70 1 "At least 8 hours per day on average (1)" 2 "Approximately 6 hours per day on average (2)" 3 "Approximately 4 hours per day on average (3)" 4 "At most 2 hours per day on average (4)"
lab val Q70 Q70 

lab var Q71 "Limits on the total number of hours you could work each week due to a medical condition"
lab define Q71 1 "At least 40 hours per week on average (1)" 2 "30 hours per week on average (2)" 3 "Approximately 20 hours per week on average (3)" 4 "Approximately 10 hours per week on average (4)"
lab val Q71 Q71 

lab var Q72 "Other limitations in the hours you could work due to a medical condition"
lab val Q72 yesnamelyno 

lab var Q73_1 "In past 12 months how many days absent from work for health-related reasons"

lab var Q74 "Highest educational level/degree"
lab define Q74 1 "Kindergarten (1)" ///
2 "1st, 2nd, 3rd, 4th, 5th, or 6th grade (2)" ///
3 "7th, 8th, or 9th grade (3)" ///
4 "10th, 11th, or 12th grade - but no diploma received (4)" ///
5 "High school diploma or equivalent (GED) (5)" ///
6 "Some college, but no degree (6)" ///
7 "Associate degree in college – Occupational/vocational program (7)" ///
8 "Associate degree in college – Academic program (8)" ///
9 "Bachelor’s Degree (BA, BS, AB) (9)" ///
10 "Master’s Degree (MA, MS, MEng, Med, MSW, MBA) (10)" ///
11 "Doctoral Degree (PhD, ScD, EdD) (11)" ///
12 "Professional School Degree (MD, DDS, DVM, LLB, JD) (12)"
lab val Q74 Q74 

lab var Q74a_1 "Administration"
lab var Q74a_2 "Agriculture"
lab var Q74a_3 "Art and culture"
lab var Q74a_4 "Commercial"
lab var Q74a_5 "Health care"
lab var Q74a_6 "Services"
lab var Q74a_7 "Technical"
lab var Q74a_8 "None of the above, namely..."

lab var Q75 "Certification or license"

lab var Q75a_1 "Administration"
lab var Q75a_2 "Agriculture"
lab var Q75a_3 "Art and culture"
lab var Q75a_4 "Commercial"
lab var Q75a_5 "Health care"
lab var Q75a_6 "Services"
lab var Q75a_7 "Technical"
lab var Q75a_8 "None of the above, namely..."

lab var Q76 "Able to use a computer "

lab var Q77 "Ability to speak English"
lab define Q77 1 "Fully fluent (1)" 2 "Strong accent or cannot express(2)"
lab val Q77 Q77 

lab var Q78 "Active driver’s license"

lab var Q78a "Age obtained driver's license"

lab var Q81 "Industry of main job"
lab define Q81 1 "Agriculture, Forestry, Fishing, and Hunting" ///
2 "Mining, Quarrying, and Oil and Gas Extraction" ///
3 "Utilities" ///
4 "Construction" ///
5 "Manufacturing" ///
6 "Wholesale Trade" ///
7 "Retail Trade" ///
8 "Transportation and Warehousing" ///
9 "Information" ///
10 "Finance and Insurance" ///
11 "Real Estate and Rental and Leasing" ///
12 "Professional, Scientific, and Technical Services" ///
13 "Management of Companies and Enterprises" ///
14 "Administrative and Support and Waste Management and Remediation" ///
15 "Educational Services" ///
16 "Health Care and Social Assistance" ///
17 "Arts, Entertainment, and Recreation" ///
18 "Accommodation and Food Services" ///
19 "Other Services (except Public Administration)" ///
20 "Public Administration"
lab val Q81 Q81 

lab var Q82_yearsexperience_1 "Years of experience in job 1"
lab var Q82_yearsexperience_2 "Years of experience in job 2"
lab var Q82_yearsexperience_3 "Years of experience in job 3"

lab var Q83 "Number of hours worked weekly"

lab var Q84 "Number of weeks worked annually"

lab var Q85 "Earnings main job 12 months"
lab define Q85 1 "Less than $5,000" ///
2 "$5,000 to $7,499" ///
3 "$7,500 to $9,999" ///
4 "$10,000 to $12,499" ///
5 "$12,500 to $14,999" ///
6 "$15,000 to $19,999" ///
7 "$20,000 to $24,999" ///
8 "$25,000 to $29,999" ///
9 "$30,000 to $34,999" ///
10 "$35,000 to $39,999" ///
11 "$40,000 to $49,999" ///
12 "$50,000 to $59,999" ///
13 "$60,000 to $74,999" ///
14 "$75,000 to $99,999" ///
15 "$100,000 to $124,999" ///
16 "$125,000 to $199,999" ///
17 "$200,000 or more"
lab val Q85 Q85 

lab var Q86_1 "Pay for emergency expense of $400: credit card and pay off in full at next statement"
lab var Q86_2 "Pay for emergency expense of $400: credit card and pay off over time"
lab var Q86_3 "Pay for emergency expense of $400: money currently in my bank account, or with cash"
lab var Q86_4 "Pay for emergency expense of $400: loan or other line of credit"
lab var Q86_5 "Pay for emergency expense of $400: borrow from friend or family member"
lab var Q86_6 "Pay for emergency expense of $400: payday loan, deposit advance, or overdraft"
lab var Q86_7 "Pay for emergency expense of $400: sell something"
lab var Q86_8 "Pay for emergency expense of $400: unable to pay for the expense"
lab var Q86_9 "Pay for emergency expense of $400: other, namely..."

lab var Q87_1 "Private insurance through employer or union"
lab var Q87_2 "Private insurance through family member’s employer or union"
lab var Q87_3 "Private insurance, not through employer or union"
lab var Q87_4 "Medicare"
lab var Q87_5 "Medicaid"
lab var Q87_6 "VA Health Care"
lab var Q87_7 "TRICARE"
lab var Q87_8 "Other, namely"
lab var Q87_9 "I do not have health insurance [exclusive]"

lab var Q88_1 "On SSDI"
lab var Q88_2 "On SSI"
lab var Q88_3 "On Veterans’ disability compensation"
lab var Q88_4 "On Military disability benefits"
lab var Q88_5 "On Disability payments from employer"
lab var Q88_6 "On Disability payments from private insurance "
lab var Q88_7 "On Disability benefits from other source, namely"
lab var Q88_8 "Not currently receiving disability benefits [exclusive]"

lab var Q89_1 "Applied for SSDI"
lab var Q89_2 "Applied for SSI"
lab var Q89_3 "Applied for Veterans’ disability compensation"
lab var Q89_4 "Applied for Military disability benefits"
lab var Q89_5 "Applied for Disability payments from employer"
lab var Q89_6 "Applied for Disability payments from private insurance "
lab var Q89_7 "Applied for Disability benefits from other source, namely"
lab var Q89_8 "Did not apply for disability benefits [exclusive]"

lab var Q90_1 "Status of application to SSDI"
lab var Q90_2 "Status of application to SSI"
lab var Q90_3 "Status of application to Veterans’ disability compensation"
lab var Q90_4 "Status of application to Military disability benefits"
lab var Q90_5 "Status of application to Disability payments from employer"
lab var Q90_6 "Status of application to Disability payments from private insurance "
lab var Q90_7 "Status of application to Disability benefits from other source"
lab define Q90 1 "Awaiting decision (1)" 2 " Rejected, planning to appeal (2)" 3 "Rejected, not planning to appeal (3)" 4 "Awarded benefits (4)"
local Q90vars Q90_1-Q90_7
foreach i in `Q90vars'{
	lab val `i' Q90
}

lab var Q89a_1 "Applied for SSDI"
lab var Q89a_2 "Applied for SSI"
lab var Q89a_3 "Applied for Veterans’ disability compensation"
lab var Q89a_4 "Applied for Military disability benefits"
lab var Q89a_5 "Applied for Disability payments from employer"
lab var Q89a_6 "Applied for Disability payments from private insurance "
lab var Q89a_7 "Applied for Disability benefits from other source, namely"
lab var Q89a_8 "Did not apply for disability benefits [exclusive]"

lab var Q90a_1 "Status of application to SSDI"
lab var Q90a_2 "Status of application to SSI"
lab var Q90a_3 "Status of application to Veterans’ disability compensation"
lab var Q90a_4 "Status of application to Military disability benefits"
lab var Q90a_5 "Status of application to Disability payments from employer"
lab var Q90a_6 "Status of application to Disability payments from private insurance "
lab var Q90a_7 "Status of application to Disability benefits from other source"
local Q90avars Q90a_1-Q90a_7
foreach i in `Q90avars'{
	lab val `i' Q90
}

lab var CS_001  "How did you find this interview"
lab define CS_001 1 "Very interesting (1)" 2 "Interesting (2)" 3 "Neither interesting nor uninteresting (3)" 4 "Uninteresting (4)" 5 "Very uninteresting (5)"
lab val CS_001 CS_001

compress

*==================================================================================================
* Label user-defined variables
*==================================================================================================

lab var dis_ret_oth "Disabled, retired, or other"

lab var health_mi "Number of questions missing in health module"
lab var thinking_mi "Number of questions missing in thinking module"
lab var social_mi "Number of questions missing in social module"
lab var senses_mi "Number of questions missing in senses module"
lab var physical_mi "Number of questions missing in physical module"
lab var movement_mi "Number of questions missing in movement module"
lab var holding_mi "Number of questions missing in holding module"
lab var working_mi "Number of questions missing in working module"
lab var edu_mi "Number of questions missing in edu module"
lab var program_mi "Number of questions missing in program module"

lab var num_health_problems "Number of health conditions reported"
lab var think_social_qualify "Indicator for qualify thinking/social modules"
lab var skip_all_health "Indicator for skip all health questions"
lab var think_social_other "Indicator if qualify thinking/social b/c selected other health"
lab var pass_screener "Indicator for pass screener"
lab var wheelchair "Indicator for report using wheelchair"
lab var age_grp "Age group first definition"
lab def age_grpL 1 "under 25" 2 "25-34" 3 "35-49" 4 "50+"
lab val age_grp age_grpL
lab var age_grp2 "Age group second definition"
lab def age_grp2L 1 "under 50" 2 "50-64" 3 "65+" 
lab val age_grp2 age_grp2L
lab var age_grp3 "Age group third definition"
lab def age_grp3L 1 "under 35" 2 "35-49" 3 "50-64" 4 "65+"
lab val age_grp3 age_grp3L
lab def college2L 1 "High school or less" 2 "Some college" 3 "Bachelors+"
lab val college2 college2L

lab var Q2_limitsTot "Total number of limiting health conditions (max 3)"
lab var Q2_limitsAny "Indicator for at least one limiting health condition"

lab var any_impair_thinking "Indicator for at least one impairment in thinking module"
lab var any_impair_social "Indicator for at least one impairment in social module"
lab var any_impair_senses "Indicator for at least one impairment in senses module"
lab var any_impair_physical "Indicator for at least one impairment in physical module"
lab var any_impair_movement "Indicator for at least one impairment in movement module"
lab var any_impair_holding "Indicator for at least one impairment in holding module"
lab var any_impair_work "Indicator for at least one impairment in work module"

lab var Q52_combo "Combination of retired/non-retired versions"
lab var Q70_combo "Combination of retired/non-retired versions"
lab var Q71_combo "Combination of retired/non-retired versions"

lab var num_impair_thinking "Number of reported impairments in thinking module"
lab var num_impair_social "Number of reported impairments in social module"
lab var num_impair_socthi "Number of reported impairments in social/thinking modules"
lab var num_impair_senses "Number of reported impairments in senses module"
lab var num_impair_physical "Number of reported impairments in physical module"
lab var num_impair_movement "Number of reported impairments in movement module"
lab var num_impair_holding "Number of reported impairments in holding module"
lab var num_impair_total "Number of reported impairments in total"

lab var severe_socthi "Indicated at least one severe social/thinking impairment"
lab var no_health_problems "No health problems reported"




*==================================================================================================
* Save
*==================================================================================================

save "Data/HFCS/clean_data/HFCS_CLEAN.dta", replace
