These files run the analysis and produce the 6 exhibits 

## exhibit_1_descr_stats.do 
Produces Table 1, inputs: hfcs_recodes.dta HFCS_CLEAN.dta outputs: summary_stats_stars.csv

## exhibit_2_prevalence.do 
Produces Figure 1, inputs: hfcs_recodes.dta hfcs_recodes_collapse.dta output: prevalence_by_group.png

## exhibit_3_mean_limitations.do 
Produces Figure 2, inputs: hfcs_recodes.dta HFCS_CLEAN.dta interim: figure2_stars.xlsx output: mean_limitations_by_demo_job_stars.png

## regressions.do 
Produces Table 2, Table S3, Table S4, and Table S5 inputs: medcond_g.dta interim: medcond_g_reg.dta, med_condition_coefficients.xlsx, boot_results, correlation_matrix.csv, correlation_matrix.xlsx, summary_stats_correlation_matrix.xlsx output: exhibit_s4_demo_reg.csv, exhibit_4.xlsx, exhibit_s5_corr_summ.xlsx, exhibit_s3_full_reg.xlsx 

## exhibit_s1_prevalence.do 
Produces Table S1 inputs: hfcs_recodes.dta, variables_full_fml.xlsx interim: hfcs_recodes_collapse_s1.dta output: common_func_limitations.xlsx

## exhibit_s2_full_regression_table.do 
Produces Table S2 inputs: boot_results.dta med_condition_coefficients.xlsx interim: ttest_results_with_starss2.dta output: prevalence_by_occupation
