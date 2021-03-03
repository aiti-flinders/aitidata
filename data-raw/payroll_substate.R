library(readxl)
library(janitor)
library(dplyr)
library(tidyr)
library(strayr)
library(stringr)
library(aitidata)

abs_test <- download_data_cube(catalogue_string = "weekly-payroll-jobs-and-wages-australia",
                               cube = "Table 5: Sub-state - Payroll jobs indexes",
                               path = "data-raw")

current_date <- read_xlsx(here::here(abs_test),
                          sheet = 2,
                          skip = 5) %>%
  select(last_col()) %>%
  colnames() %>%
  as.numeric() %>%
  as.Date(origin = "1899-12-30")

if (current_date <= max(aitidata::payroll_substate$date)) {
  message("Skipping `payroll_substate.rda`: appears to be up-to-date")
  file.remove(abs_test)
} else {
  message("updating `payroll_substate.rda`")
  
  abs_file <- abs_test
  
  
  payroll_substate <- read_xlsx(here::here(abs_file), sheet = "Payroll jobs index-SA3", skip = 5, na = "NA") %>%
    clean_names() %>%
    mutate(across(starts_with("x"), as.numeric)) %>%
    pivot_longer(
      cols = c(4:length(.)),
      names_to = "date",
      values_to = "value"
    ) %>%
    mutate(across(1:4, ~ gsub("^[0-9]. ", "", .)),
           date = gsub("x", "", date),
           date = as.numeric(date),
           date = as.Date(date, origin = "1899-12-30"),
           value = as.numeric(value),
           sa3_code_2016 = ifelse(statistical_area_3 != "All SA4", str_sub(statistical_area_3, start = 1L, end = 5L), NA),
           state_or_territory = strayr(state_or_territory, to = "state_name"),
           indicator = "payroll_index") %>%
    select(state_name_2016 = state_or_territory, date, value, sa3_code_2016, indicator) %>%
    filter(!is.na(sa3_code_2016), !is.na(value))
  
  save(payroll_substate, file = here::here("data", "payroll_substate.rda"), compress = "xz")
  file.remove(abs_test)
  file.remove(abs_file)
}