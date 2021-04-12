library(readxl)
library(janitor)
library(dplyr)
library(tidyr)
library(strayr)
library(readabs)
library(stringr)
library(aitidata)
library(absmapsdata)
library(sf)

abs_test <- read_payrolls(series = "sa3_jobs", path = here::here("data-raw"))


if (max(abs_test$date) <= max(aitidata::payroll_substate$date)) {
  message("Skipping `payroll_substate.rda`: appears to be up-to-date")
  file.remove("data-raw/6160055001_DO005.xlsx")
} else {
  message("updating `payroll_substate.rda`")
  
  abs_file <- abs_test
  
  
  payroll_substate <- abs_file %>%
    mutate(state_name_2016 = strayr(state, to = "state_name"),
           sa3_name_2016 = sa3,
           indicator = "Payroll Index") %>%
    left_join(sa32016) %>%
    select(state_name_2016, date, value, sa3_code_2016, indicator) %>%
    filter(!is.na(sa3_code_2016), !is.na(value))
  
  save(payroll_substate, file = here::here("data", "payroll_substate.rda"), compress = "xz")
  
  file.remove(here::here("data-raw/6160055001_DO005.xlsx"))
  
}