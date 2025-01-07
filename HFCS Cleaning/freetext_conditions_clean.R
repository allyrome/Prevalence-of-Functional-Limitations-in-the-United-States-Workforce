# freetext_conditions_clean.R
# Title: Clean free-text conditions fields
# Author: Michael Jetsupphasuk
# Purpose: Clean and process free-text fields in medical conditions section

#==================================================================================================


# Setup -------------------------------------------------------------------


# load libraries
library(readstata13)
library(readr)
library(readxl)
# library(plyr)
library(dplyr)
library(reshape2)
library(stringr)

# set working directory
setwd("C:/Users/michaeljets/Dropbox (HMS)/Medical Conditions Affecting Work Capacity")

# load data
hfcs = read.dta13("Data/HFCS/clean_data/HFCS_CLEAN.dta", convert.factors = F)
vars = read_excel("Data/HFCS/clean_data/variables.xlsx", sheet = 'health_conditions')
extra_terms = read_excel("Data/HFCs/clean_data/variables.xlsx", sheet = 'health_conditions_extra')
filler_terms = read_excel("Data/HFCs/clean_data/variables.xlsx", sheet = 'no_condition') %>% pull(1)
manual_freetext = read_excel("Data/HFCS/clean_data/conditions_freetext.xlsx")  ##switched from csv to excelf format



# Format ------------------------------------------------------------------

# keep only relevant columns
hfcs = hfcs %>% select(prim_key, starts_with('Q1_'), starts_with('Q2_textEntry'))

# get just the text fields we want to search over
hfcs_text = hfcs %>% select(ends_with('other'), starts_with('Q2_textEntry'))
hfcs_text[is.na(hfcs_text)] = ""
hfcs_text = apply(hfcs_text, 2, tolower)
hfcs_text = apply(hfcs_text, 2, str_squish)
hfcs_text = apply(hfcs_text, 2, function(x) gsub("'", "", x))

# remove filler terms
hfcs_text[hfcs_text %in% filler_terms] = ""

# change column names of vars
colnames(vars) = c('variable', 'label', 'group', 'group_2', 'associated_terms', 'exclusion_terms') ##second grouping added

# change NA's to blanks
vars[is.na(vars)] = ""

# add the variable label to the search terms; switch to lower-case
vars = vars %>%
  mutate(associated_terms = paste(label, associated_terms, sep = "; "),
         associated_terms = tolower(associated_terms),
         exclusion_terms = tolower(exclusion_terms))

# create a list with the associated terms per term with names as variable names
srch_terms = strsplit(vars$associated_terms, split = '; ')
names(srch_terms) = vars$label
srch_terms = lapply(srch_terms, unique)

# convert search terms to a regular expression string
srch_terms = lapply(srch_terms, function(x) paste('\\b', x, '\\b', collapse = '|', sep = ''))

# do the same for the exclusion terms
exclsn_terms = strsplit(vars$exclusion_terms, split = '; ')
names(exclsn_terms) = vars$label
exclsn_terms = lapply(exclsn_terms, unique)
exclsn_terms = lapply(exclsn_terms, function(x) ifelse(length(x)>0, paste('\\b', x, '\\b', collapse = '|', sep = ''), NA))



# Match text --------------------------------------------------------------

# iterate through each free-text field and match on srch_terms and exclsn_terms
match_proc <- function(v, srch_terms, exclsn_terms, keep_original=F) {
  conds = c()
  
  # flag search terms where we do not want to allow for an edit distance of 1
  srch_flag = sapply(sapply(srch_terms, strsplit, '\\|'), function(x) any(nchar(x)<=9))
  
  for (j in 1:length(srch_terms)) {
    mtch = srch_terms[[j]]
    mtch_not = exclsn_terms[[j]]
    
    # search for matches (allow for edit distance of 1 if not short word)
    if (j %in% which(srch_flag)) {
      mtch_temp = strsplit(mtch, '\\|')[[1]]
      stsh_logical = logical(length(v))
      for (s in 1:length(mtch_temp)) {
        if (nchar(mtch_temp[s])<=9) (stsh_logical = grepl(mtch_temp[s], v) | stsh_logical)
        else (stsh_logical = agrepl(mtch_temp[s], v, max.distance=1, fixed=F) | stsh_logical)
      }
      match_i = stsh_logical
    }
    else {
      match_i = agrepl(mtch, v, max.distance=1, fixed=F)
    }
    
    # search for exclusion matches, add to list of conditions if no match
    if (any(match_i) & !is.na(mtch_not)) {
      exclude_i = agrepl(mtch_not, v, max.distance=1, fixed=F)
      if (!any(exclude_i) | any(match_i & !exclude_i)) {
        conds = c(conds, names(srch_terms[j]))
      }
    }
    
    # if no exclusions, add to list of conditions
    else if (any(match_i) & is.na(mtch_not)) {
      conds = c(conds, names(srch_terms[j]))
    }
    
  }
  
  # if no matches, then return original string
  if (is.null(conds) & keep_original) {
    return(v)
  }
  
  # return list of conditions
  return(conds)
}

matches = apply(hfcs_text, 1, match_proc, srch_terms, exclsn_terms)
num_found_conditions = sapply(matches, length)
table(num_found_conditions)

# get empties
matches_null = sapply(matches, is.null)
matches[matches_null] = ""

# convert to a character vector, then dataframe
matches = sapply(matches, paste, collapse=', ')
matches[matches=='NA'] = NA
matches = data.frame(prim_key = hfcs$prim_key, code_matches = matches, stringsAsFactors = F)

# matches = left_join(matches, vars %>% select(variable, label), by = c('code_matches'='variable'))
# matches = matches %>%
#   mutate(label = ifelse(is.na(label), "", label)) %>%
#   select(-code_matches, code_matches = label)


# Connect back to data ----------------------------------------------------

# merge into manual free-text spreadsheet
manual_freetext = left_join(manual_freetext, matches, by = 'prim_key')

# how much new information is gathered?
manual_freetext %>% filter(!is.na(code_matches)) %>% nrow()
selected_conditions_split = strsplit(manual_freetext$selected_conditions, ', ')
code_matches_split = strsplit(manual_freetext$code_matches, ', ')
new_matches = c()

for (i in 1:nrow(manual_freetext)) {
  new_matches[i] = any(!(code_matches_split[[i]] %in% selected_conditions_split[[i]])) & !all(is.na(code_matches_split[[i]]))
}
table(new_matches)

manual_freetext = manual_freetext %>% mutate(new_matches = new_matches)




# Clean up Q2 -------------------------------------------------------------

# match also for the common conditions that we did not ask for
common_conditions = strsplit(extra_terms$`Search words`, "; ")
common_exclsn = strsplit(extra_terms$Exclusions, "; ")

names(common_conditions) = extra_terms$Condition
names(common_exclsn) = extra_terms$Condition

common_conditions = lapply(common_conditions, function(x) paste('\\b', x, '\\b', collapse = '|', sep = ''))
common_exclsn = lapply(common_exclsn, function(x) paste('\\b', x, '\\b', collapse = '|', sep = ''))


# match words
matches_q2_1 = apply(as.matrix(hfcs_text[, c('Q2_textEntry_1')]), 1, match_proc, 
                     srch_terms = c(srch_terms, common_conditions), 
                     exclsn_terms = c(exclsn_terms, common_exclsn), 
                     keep_original=T)
matches_q2_2 = apply(as.matrix(hfcs_text[, c('Q2_textEntry_2')]), 1, match_proc, 
                     srch_terms = c(srch_terms, common_conditions), 
                     exclsn_terms = c(exclsn_terms, common_exclsn), 
                     keep_original=T)
matches_q2_3 = apply(as.matrix(hfcs_text[, c('Q2_textEntry_3')]), 1, match_proc, 
                     srch_terms = c(srch_terms, common_conditions), 
                     exclsn_terms = c(exclsn_terms, common_exclsn), 
                     keep_original=T)

# throw it all into a dataframe
matches_q2 = data.frame(prim_key = hfcs$prim_key, 
                        top3_1 = as.character(matches_q2_1), 
                        top3_2 = as.character(matches_q2_2), 
                        top3_3 = as.character(matches_q2_3), 
                        stringsAsFactors = F)

# create an indicator if matched
matches_q2 = matches_q2 %>%
  mutate(matched1 = top3_1 %in% c(vars$label, names(common_conditions)),
         matched2 = top3_2 %in% c(vars$label, names(common_conditions)),
         matched3 = top3_3 %in% c(vars$label, names(common_conditions)))

# look at the un-matched
x = c(matches_q2$top3_1[!matches_q2$matched1], matches_q2$top3_2[!matches_q2$matched2], matches_q2$top3_3[!matches_q2$matched3])
top_unmatched = sort(table(x[x!='']), decreasing=T)
head(top_unmatched, 50)
length(x[x!=''])

# create an indicator if double-entry
matches_q2$double = sapply(matches_q2_1, length)>1 | sapply(matches_q2_2, length)>1 | sapply(matches_q2_3, length)>1

# merge matched top 3
manual_freetext = left_join(manual_freetext, matches_q2, by = 'prim_key')

# write it
write_csv(manual_freetext, "Data/HFCS/clean_data/conditions_freetext_autocode.csv", na='')
write_csv(data.frame(top_unmatched), 'Data/HFCS/clean_data/unmatched.csv')



# Impute values based on code matches -------------------------------------

# map from label to variable name
map = setNames(vars$variable, gsub(' \\(text\\)', '', vars$label))
map = map[!(names(map) %in% colnames(manual_freetext))]
manual_freetext[, map] = NA

for (i in 1:nrow(manual_freetext)) {
  
  # get new matches and the corresponding variable names
  if (!(manual_freetext$new_matches[i])) (next)
  
  # if (manual_freetext$new_matches[i]) {
  #   all_cond = paste(manual_freetext$selected_conditions[i], manual_freetext$code_matches[i], sep = ', ')
  # }
  # else {
  #   all_cond = manual_freetext$selected_conditions[i]
  # }
  
  matches_split = strsplit(manual_freetext$code_matches[i], ', ')[[1]]
  matches_split = map[matches_split]
  
  # iterate through each variable name and impute
  for (j in 1:length(matches_split)) {
    manual_freetext[i, matches_split[j]] = 1
  }
}

# write it
write_csv(manual_freetext %>%
            select(prim_key, starts_with('top3'), starts_with('matched'), starts_with('Q1')),
          'Data/HFCS/clean_data/interim/test.csv',
          na = '')

# # rename old Q1
# colnames(hfcs) = sapply(colnames(hfcs), function(x) ifelse(x %in% map, paste(x, '_old', collapse='', sep=''), x))
# 
# # merge in new Q1
# x = left_join(hfcs, manual_freetext %>% select(prim_key, new_matches, starts_with('top3_'), starts_with('matched'), starts_with('Q1_')))










