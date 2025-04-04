These files run our analysis and produce the first 14 exhibits. Table S9 is constructed manually 

## table_1_descr_stats.do 
Produces Table 1, inputs: hfcs_recodes.dta HFCS_CLEAN.dta outputs: summary_stats_stars.csv

## figure_1_prevalence.do 
Produces Figure 1, inputs: hfcs_recodes.dta hfcs_recodes_collapse.dta output: prevalence_by_group.png

## figure_2_mean_limitations.do 
Produces Figure 2, inputs: hfcs_recodes.dta HFCS_CLEAN.dta interim: figure2_stars.xlsx output: mean_limitations_by_demo_job_stars.png

## regressions.do 
Produces Table 2, Table S3, Table S4, and Table S9 inputs: medcond_g.dta interim: medcond_g_reg.dta, med_condition_coefficients.xlsx, boot_results, correlation_matrix.csv, correlation_matrix.xlsx, summary_stats_correlation_matrix.xlsx output: exhibit_s4_demo_reg.csv, exhibit_4.xlsx, exhibit_s5_corr_summ.xlsx, exhibit_s3_full_reg.xlsx 

## table_s1_prevalence.do 
Produces Table S1 inputs: hfcs_recodes.dta, variables_full_fml.xlsx interim: hfcs_recodes_collapse_s1.dta output: common_func_limitations.xlsx

## table_s2_prevalence_occupation.do 
Produces Table S2 inputs: boot_results.dta med_condition_coefficients.xlsx interim: ttest_results_with_starss2.dta output: prevalence_by_occupation

## figure_s1_prevalence_56.do
Produces Figure S1 inputs: hfcs_recodes.dta,  limitations_prevalence_job_profiles_hfcs.xlsx interim: hfcs_recodes_collapse_sensitivity.dta output: prevalence_by_group_sensitivity.png

## figure_s2_mean_limitations_56.do
Produces Figure S2 inputs: hfcs_recodes.dta, limitations_prevalence_job_profiles_hfcs.xlsx, HFCS_CLEAN.dta interim: figure2_stars_sensitivity output: mean_limitations_by_demo_job_stars_sensitivity.png

## table_s6_summary_stats_97_56.do
Produces Table S6 inputs: hfcs_recodes.dta, job_profiles_limitations_education, HFCS_CLEAN.dta output: summary_stats_97_56.xlsx

## table_s7_regressions.do
Produces Table S7 inputs: medcond_g.dta interim: med_condition_coefficients_97wtd.xlsx, med_condition_coefficients_56unwtd.xlsx, med_condition_coefficients_56wtd.xlsx output: exhibit_s7_97wtd, exhibit_s7_56unwtd, exhibit_s7_56wtd.xlsx

## table s8_weight_distribution.do
Produces Table S8 inputs: hfcs_recodes.dta, job_profiles_limitations_education output: exhibit_s8_weight_distribution.xlsx
