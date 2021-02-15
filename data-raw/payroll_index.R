library(janitor)
library(dplyr)
library(tidyr)
library(forcats)
library(strayr)
library(stringr)
library(readxl)
library(aitidata)


abs_test <- download_data_cube(catalogue_string = "weekly-payroll-jobs-and-wages-australia",
                               cube = "Table 7: Employment size - Payroll jobs index",
                               path = "data-raw")

current_date <- read_xlsx(here::here(abs_test),
                          sheet = 2,
                          skip = 5) %>%
  select(last_col()) %>%
  colnames() %>%
  as.numeric() %>%
  as.Date(origin = "1899-12-30")

if (current_date <= max(aitidata::payroll_index$date)) {
  message("Skipping `payroll_index.rda`: appears to be up-to-date")
  file.remove(abs_test)
} else {
  message("Updating `payroll_index.rda`")
  abs_file <- download_data_cube(catalogue_string = "weekly-payroll-jobs-and-wages-australia",
                     cube = "Table 4: Payroll jobs and wages indexes",
                     path = "data-raw")
  
  payroll_jobs <- read_xlsx(abs_file, sheet = "Payroll jobs index", skip = 5, na = "NA", n_max = 4321) %>%
    clean_names() %>%
    mutate(across(starts_with("x"), as.numeric)) %>%
    pivot_longer(
      cols = c(5:length(.)),
      names_to = "date",
      values_to = "value"
    ) %>%
    mutate(across(1:5, ~ gsub("^[0-9]\\. ", "", .)),
           industry_division = gsub("(0[0-9]|1[0-9])\\. ([A-S]-)", "", industry_division),
           date = gsub("x", "", date),
           date = as.numeric(date),
           date = as.Date(date, origin = "1899-12-30"),
           value = as.numeric(value),
           age_group = as_factor(age_group),
           state_or_territory = strayr(state_or_territory, to = "state_name"),
           industry_division = str_to_title(industry_division),
           industry_division = gsub("&", "and", industry_division),
           indicator = "payroll_jobs"
    ) %>%
    select(date, gender = sex, age = age_group, state = state_or_territory, industry = industry_division, indicator, value)
  
  payroll_wages <- read_xlsx(here::here("data-raw", "6160055001_DO004.xlsx"), sheet = "Total wages index", skip = 5, na = "NA", n_max = 4321) %>%
    clean_names() %>%
    mutate(across(starts_with("x"), as.numeric)) %>%
    pivot_longer(
      cols = c(5:length(.)),
      names_to = "date",
      values_to = "value"
    ) %>%
    mutate(across(1:5, ~ gsub("^[0-9]\\. ", "", .)),
           industry_division = gsub("(0[0-9]|1[0-9])\\. ([A-S]-)", "", industry_division),
           date = gsub("x", "", date),
           date = as.numeric(date),
           date = as.Date(date, origin = "1899-12-30"),
           value = as.numeric(value),
           age_group = as_factor(age_group),
           state_or_territory = strayr(state_or_territory, to = "state_name"),
           industry_division = str_to_title(industry_division),
           industry_division = gsub("&", "and", industry_division),
           indicator = "payroll_wages"
    ) %>%
    select(date, gender = sex, age = age_group, state = state_or_territory, industry = industry_division, indicator, value)
  
  payroll_index <- bind_rows(payroll_jobs, payroll_wages)
  
  save(payroll_index, file = here::here("data", "payroll_index.rda"), compress = "xz")
}