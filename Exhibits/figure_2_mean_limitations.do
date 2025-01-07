* Exhibit 3 - Mean number of limitations by Group
* Author: Alexandra Rome
* Purpose: 
* 	Find the mean number of limitations by group and produce plot with significance stars from anova
*==================================================================================================+

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity" 

* Call in EssentialTeleworkable to merge to HFCS data
use "Data\HFCS\clean_data\hfcs_recodes.dta" , clear

destring isco_1dig , replace

***** Create number of limitations variable *****

* Temporarily impute no limitation if did not pass screener
replace value = 0 if pass_screener == 0
drop if missing(value)

* Create interim value that;
*	= 0 if respondent is normal or slightly limited 
*	= 1 if respondent is limited
*	= 2 if they are very limited

gen value2 = 0
replace value2 = 1 if value == 2
replace value2 = 2 if value == 3
bys prim_key: egen num_limit = total(value2>0)

collapse (max) num_limit essential Teleworkable isco_1dig, by(prim_key)
merge 1:1 prim_key using "Data/HFCS/clean_data/HFCS_CLEAN.dta"

* Keep if working and passed screener 
keep if working == 1
keep if pass_screener == 1

* Create male variable 
gen male = (female == 0)

* Create age groups 
gen age_22_34 = (AGE<35)
gen age_35_49 = (AGE>=35 & AGE<50)
gen age_50_64 = (AGE>=50 & AGE<65)
gen age_65_plus = (AGE>=65)

* Create no college
gen no_college = (college == 0)

* Create non-essential and non-teleworkable 
gen non_essential = (essential == 0)
gen non_tele = (Teleworkable == 0)

* Add super-sector information 
gen goods =  (Q81<= 5 & Q81 != 3)
gen service = (Q81 > 5 | Q81 == 3)

tab isco_1dig, gen(isco_1dig)

rename isco_1dig2 managers
rename isco_1dig3 professionals
rename isco_1dig4 technicians
rename isco_1dig5 clerical
rename isco_1dig6 service_sales
rename isco_1dig8 craft
rename isco_1dig9 plant
rename isco_1dig10 elementary


* Add variable for significance stars to export as results to excel
gen stars_gender = ""
gen stars_age = ""
gen stars_education = ""
gen stars_sector = ""
gen stars_occupation = ""
gen stars_essential = ""
gen stars_telework = ""

// ANOVA for male vs female
anova num_limit male [aw=weight]
// Get the F-statistic and degrees of freedom
local Fstat = e(F)
local df_m = e(df_m)
local df_r = e(df_r)

// Calculate the p-value using Ftail()
local pvalue = Ftail(`df_m', `df_r', `Fstat')
if `pvalue' < 0.01 {
    replace stars_gender = "***"
}
else if `pvalue' < 0.05 {
    replace stars_gender = "**"
}
else if `pvalue' < 0.1 {
    replace stars_gender = "*"
}

//  ANOVA for age groups
anova num_limit age_22_34 age_35_49 age_50_64 age_65_plus [aw=weight]
// Get the F-statistic and degrees of freedom
local Fstat = e(F)
local df_m = e(df_m)
local df_r = e(df_r)

// Calculate the p-value using Ftail()
local pvalue = Ftail(`df_m', `df_r', `Fstat')
if `pvalue' < 0.01 {
    replace stars_age = "***"
}
else if `pvalue' < 0.05 {
    replace stars_age = "**"
}
else if `pvalue' < 0.1 {
    replace stars_age = "*"
}

//  ANOVA for college vs no_college
anova num_limit college [aw=weight]
// Get the F-statistic and degrees of freedom
local Fstat = e(F)
local df_m = e(df_m)
local df_r = e(df_r)

// Calculate the p-value using Ftail()
local pvalue = Ftail(`df_m', `df_r', `Fstat')
if `pvalue' < 0.01 {
    replace stars_education = "***"
}
else if `pvalue' < 0.05 {
    replace stars_education = "**"
}
else if `pvalue' < 0.1 {
    replace stars_education = "*"
}

//  ANOVA for service vs goods
anova num_limit goods [aw=weight]
// Get the F-statistic and degrees of freedom
local Fstat = e(F)
local df_m = e(df_m)
local df_r = e(df_r)

// Calculate the p-value using Ftail()
local pvalue = Ftail(`df_m', `df_r', `Fstat')
if `pvalue' < 0.01 {
    replace stars_sector = "***"
}
else if `pvalue' < 0.05 {
    replace stars_sector = "**"
}
else if `pvalue' < 0.1 {
    replace stars_sector = "*"
}

//  ANOVA for occupation groups
anova num_limit managers professionals technicians clerical service_sales craft plant elementary [aw=weight]
// Get the F-statistic and degrees of freedom
local Fstat = e(F)
local df_m = e(df_m)
local df_r = e(df_r)

// Calculate the p-value using Ftail()
local pvalue = Ftail(`df_m', `df_r', `Fstat')
if `pvalue' < 0.01 {
    replace stars_occupation = "***"
}
else if `pvalue' < 0.05 {
    replace stars_occupation = "**"
}
else if `pvalue' < 0.1 {
    replace stars_occupation = "*"
}

//  ANOVA for essential vs non_essential
anova num_limit essential [aw=weight]
// Get the F-statistic and degrees of freedom
local Fstat = e(F)
local df_m = e(df_m)
local df_r = e(df_r)

// Calculate the p-value using Ftail()
local pvalue = Ftail(`df_m', `df_r', `Fstat')
if `pvalue' < 0.01 {
    replace stars_essential = "***"
}
else if `pvalue' < 0.05 {
    replace stars_essential = "**"
}
else if `pvalue' < 0.1 {
    replace stars_essential = "*"
}

//  ANOVA for Teleworkable vs non_tele
anova num_limit Teleworkable [aw=weight]
// Get the F-statistic and degrees of freedom
local Fstat = e(F)
local df_m = e(df_m)
local df_r = e(df_r)

// Calculate the p-value using Ftail()
local pvalue = Ftail(`df_m', `df_r', `Fstat')
if `pvalue' < 0.01 {
    replace stars_telework = "***"
}
else if `pvalue' < 0.05 {
    replace stars_telework = "**"
}
else if `pvalue' < 0.1 {
    replace stars_telework = "*"
}

**** Send significance results to excel to use in graph 
preserve 

keep stars*
keep if  _n ==1

export excel using "Papers\Burdens of Functional Limitations\Exhibit 3\figure2_stars", firstrow(variables) replace

restore

* Find mean limitations of each group

cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity\Code\paper1_AR" 
postfile mean_limitations str27 group mean_limit cilb ciub using mean_limitations , replace

foreach var of varlist male female age_22_34 age_35_49 age_50_64 age_65_plus college no_college service goods managers professionals technicians clerical service_sales craft plant elementary essential non_essential Teleworkable non_tele {
 
 preserve
 
  keep if `var' == 1
  ci mean num_limit [aw=weight]
  post mean_limitations ("`var'") (r(mean)) (r(lb)) (r(ub))
  
  restore
  
}

postclose mean_limitations
use mean_limitations , clear


gen group_num = _n
gen groups_sum = ""
replace groups_sum = "Sex" if inlist(group_num, 1, 2)
replace groups_sum = "Age" if inrange(group_num, 3 , 6 )
replace groups_sum = "Education" if inrange(group_num, 7 , 8 )
replace groups_sum = "Industry" if inrange(group_num, 9 , 10 )
replace groups_sum = "Occupation" if inrange(group_num, 11, 18)
replace groups_sum = "unnamed" if inrange(group_num, 19, 22)

* Create breaks between groups

replace group_num = group_num + 1 if group_num > 2
replace group_num = group_num + 1 if group_num > 7
replace group_num = group_num + 1 if group_num > 10
replace group_num = group_num + 1 if group_num > 13
replace group_num = group_num + 1 if group_num > 22
replace group_num = group_num + 1 if group_num > 25


cd "C:\Users\arome\Dropbox (HMS)\Medical Conditions Affecting Work Capacity"

set scheme cleanplots

graph twoway (scatter group_num mean_limit , mcolor(navy) msymbol(circle) msize(small)) ///
	(rcap cilb ciub group_num, mcolor(navy) lcolor(navy) horizontal) ///
	(scatteri 0.5 15 2.5 15, recast(line) lw(medthick) mc(none) lc(navy) lp(solid))  ///
	(function y= 0.5 , range(14.75 15) lcolor(navy)) (function y= 2.5 , range(14.75 15) lcolor(navy)) ///
	(scatteri 3.5 15 7.5 15, recast(line) lw(medthick) mc(none) lc(navy) lp(solid))  ///
	(function y= 3.5 , range(14.75 15) lcolor(navy)) (function y= 7.5 , range(14.75 15) lcolor(navy)) ///
	(scatteri 8.5 15 10.5 15, recast(line) lw(medthick) mc(none) lc(navy) lp(solid))  ///
	(function y= 8.5 , range(14.75 15) lcolor(navy)) (function y= 10.5 , range(14.75 15) lcolor(navy)) ///
	(scatteri 11.5 15 13.5 15, recast(line) lw(medthick) mc(none) lc(navy) lp(solid))  ///
	(function y= 11.5 , range(14.75 15) lcolor(navy)) (function y= 13.5 , range(14.75 15) lcolor(navy)) ///
	(scatteri 14.5 15 22.5 15, recast(line) lw(medthick) mc(none) lc(navy) lp(solid))  ///
	(function y= 14.5 , range(14.75 15) lcolor(navy)) (function y= 22.5 , range(14.75 15) lcolor(navy)) ///
	(scatteri 23.5 15 25.5 15, recast(line) lw(medthick) mc(none) lc(navy) lp(solid))  ///
	(function y= 23.5 , range(14.75 15) lcolor(navy)) (function y= 25.5 , range(14.75 15) lcolor(navy)) ///
	(scatteri 26.5 15 28.5 15, recast(line) lw(medthick) mc(none) lc(navy) lp(solid))  ///
	(function y= 26.5 , range(14.75 15) lcolor(navy)) (function y= 28.5 , range(14.75 15) lcolor(navy)),  ///
text(1.8 15.5 "**", color(navy)) ///
text(9.7 15.5 "**", color(navy)) ///
text(18.7 15.75 "***", color(navy)) ///
text(24.7 15.75 "***", color(navy)) ///
text(27.7 15.75 "***", color(navy)) ///
title() ///
xtitle("Mean Number of Limitations", size(vsmall)) ///
xlabel(1(1)15, labsize(vsmall) grid) ///
xscale(titlegap(10pt)) ///
ytitle("", height(240pt)) ///
ylabel(1 "Male" 2 "Female" 4 "Ages 22-34" 5 "Ages 35-49" 6 "Ages 50-64" 7 "Ages 65+" 9 "BA" 10 "No BA" 12 "Service-Producing Industry" 13 "Goods-Producing Industry" 15 "Managers" 16 "Professionals" 17 "Technicians and Associate Professionals" 18 "Clerical Support Workers" 19 "Services and Sales Workers" 20 "Craft and Related Trades Workers" 21 "Plant and Machine Operators and Assemblers" 22 "Elementary Occupations" 24 "Essential Occupation" 25 "Non-Essential Occupation" 27 "Teleworkable Occupation" 28"Non-Teleworkable Occupation", angle(0) labsize(vsmall) noticks grid ) ///
yline(3 8 11 14 23 26, lcolor(gs9)) ///
yscale(reverse range(1 28) titlegap(15pt) outergap(-5)) ///
xsize(11) ///
ysize(10) ///
plotregion(fcolor(white)) graphregion(fcolor(white)) ///
legend(off) 


graph export "Papers\Burdens of Functional Limitations\Exhibit 3\mean_limitations_by_demo_job_stars.png" , replace



