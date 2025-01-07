* Essnetial and Teleworkable Occupations crosswalk
* Author: Alexandra Rome
* Purpose: 
* 	1. Crosswalk 2010 Cenesus Occupation codes to 2018 SOC codes
*	2. Pull essential identifiers by SOC code from CISA
* 	3. PUll teleworkable identifiers  by SOC from Dingel & Neiman 
*	4. Create a crosswalk for essential and teleworkable by 2010 occupation code

*==================================================================================================

** Set working directory 
cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

* 2010 SOC/Occ -> 2018 SOC/OCC from census.gov
import excel "Data\CPS\2018-occupation-code-list-and-crosswalk.xlsx", sheet("2010 to 2018 Crosswalk ") cellrange(A4:F1068) firstrow clear

* Rename variables
rename SOCcode soc_10
rename CensusCode occ_10
rename CensusTitle title_10
rename SOCCode soc_18
rename E occ_18
rename F title_18

* Fill in SOC codes that shared the same occupation code in 2010, but received more specific occupation codes in 2018. 
* For example 2010 occupation code 0050, described all SOC codes starting with 11-202X. In 2018 it split into 0051 and 0052 to describe 11-2021 and 11-2022 respectively. We want to map 11-2021 and 11-2022 back to 0050. The crosswalk is structured so if there are empty rows for 2010, the more detailed 2018 information sits below it in a different column. So we can pull it over and then fill in the corresponding occupaiton code
replace soc_10 = soc_18 if soc_10 == ""

* Fill in new, more detailed SOC codes created in 2018 that still map to the same occupation code 
* For example, in 2010 SOC code 11-2031 mapped to occuaption code 0060. In 2018 SOC code 11-2031 split into 11-2032 and 11-2033, these both still map to 0060. We need to extract their values from title_18 and pull them into the missing rows in soc_10.

* Create an indicator for if there is an SOC code listed in the 2018 title
gen code_indicator = strpos(title_18, ")") > 0

* Extract the 7 characters that contain the SOC code
gen soc_groups = substr(title_18, -8 , 7) if code_indicator == 1
drop code_indicator

* From the crosswalk pulled from the Census bureau, the code 17-3012 has an extra space; it is written as Electrical and Electronics Drafters (17-3012 ) therefore, it was substring incorrectly and needs to be fixed
replace soc_groups = "17-3012" if soc_groups == "7-3012 "

* SOC code 53-6030 is Transportation Service Attendants which breaks into 53-6031; Automotive and Watercraft Service Attendants and 53-6032; Aircraft Service Attendants source: https://www.bls.gov/soc/2018/major_groups.htm
* The crosswalk from the census bureau mistankely writes Automotive and Watercraft Service Attendants (56-6031) which is not an exisiting SOC code, so, we correct the typo here
replace soc_groups = "53-6031" if soc_groups == "56-6031"

* Fill in specific SOC codes under the SOC code grouping
replace soc_10 = soc_groups if soc_groups != ""

* Now every row that was empty due to corresponding infomration should be filled, and the remainders are just breaks
drop if soc_10 == ""

* Fill in census codes for SOC codes that were pulled over
replace occ_10 = occ_10[_n-1] if occ_10 == ""

* A small number of SOC codes change from 2010 to 2018 and the 2010 value no longer exists. If the 2010 SOC code directly maps to a different 2018 SOC code, we want to replace the 2010 value with the 2018 value since that is what is in our data
replace soc_10 = soc_18 if soc_18 != ""

* Codes with X's in them are occasionally listed to describe every SOC code within that digit range. When this occurs, the specific list of codes in under the general X code, so we can drop any code with an X
drop if strpos(soc_10, "X")

* Keep only soc_10, which now is now populated with 2018 SOC codes, and occ_10, the corresponding 2010 census codes
keep soc_10 occ_10
rename soc_10 soc_18


drop if soc_18 == "none"
replace soc_18 = subinstr(soc_18, "-", "", .)
replace soc_18 = subinstr(soc_18, " ", "", .)

destring soc_18, gen(soc_code)
destring occ_10, gen(occ) 

keep occ soc_code

save "Data\CPS\occ10_soc18_xwalk.dta", replace

