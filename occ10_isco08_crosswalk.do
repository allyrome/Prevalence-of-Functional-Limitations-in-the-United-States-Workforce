* 2010 Census Occupation Code crosswalked to 2008 1 Digit ISCO codes
* Author: Alexandra Rome
* Purpose: 
*	1. Clean up 2010 Census code to 2010 SOC codes crosswalk from census.gov
* 	2. Clean up 2010 SOC code to 2008 ISCO code crosswalk
*	3. Merge the two crosswalks on SOC code to create a crosswalk from cenesus codes to ISCO codes
*		- This is not a 1:1 merge, so we randomly select a 1 digit ISCO code for those that have multiple

*==================================================================================================

* Set working directory
cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

import excel "Data\CPS\cenocc2010.xlsx", sheet("2010") cellrange(B7:C617) firstrow clear

* Drop range observations and blank rows
drop if strmatch(CENSUSCODES, "*–*")
drop if CENSUSCODES == ""

* Remove dashes and spaces from SOC codes
replace SOCCODES = subinstr(SOCCODES, "-", "", .)
replace SOCCODES = subinstr(SOCCODES, " ", "", .)

* Create numeric variables and drop string versions
destring CENSUSCODES , gen(occ)
destring SOCCODES, gen(soc)
keep occ soc

* Save in tempfile to merge with
tempfile soc10_occ10
save `soc10_occ10'

* Load ISCO-SOC xwalk
import excel using "Data\HFCS\raw_data\ISCO_SOC_Crosswalk.xls", sheet("2010 SOC to ISCO-08") cellrange(A7) first case(preserve) clear

* processing
keep SOCCode ISCO08Code
replace SOCCode = regexr(SOCCode, " ", "")
replace SOCCode = regexr(SOCCode, "-", "")

destring SOCCode , gen(soc)

* match to only 1 digit in ISCO
gen isco_1dig = substr(ISCO08Code, 1, 1)
destring isco_1dig, replace
drop ISCO08Code 

* How many unique values
duplicates drop

joinby soc using `soc10_occ10' , unmatched(both)

* There are more specific SOC codes in the ISCO crosswalk than in the SOC/occ crosswalk. These codes in the SOC/occ crosswalk end in zero, so if we sort by SOC we can fill in the missing occupation codes by filling in downwards for the more specif codes
sort soc
replace occ = occ[_n-1] if occ== .
drop if _merge == 2

keep isco_1dig occ

* Drop duplicates
duplicates drop

*Save version where there are all 1-digit ISCO codes that may belong to the same occupation code, when merged in this crosswalk will need to be collapsed down to 1 occupation code
save "Data\CPS\occ10_isco08_xwalk.dta" , replace


* import excel "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity\Data\CPS\occ_isco_crosswalk_HC.xlsx", sheet("Sheet1") firstrow clear

