library(readabs)
library(dplyr)
library(strayr)
library(absmapsdata)
library(sf)

abs_test <- readabs::read_payrolls(series = "sa3_jobs", path = "data-raw")


if (max(abs_test$date) <= max(aitidata::payroll_substate$date)) {
  message("Skipping `payroll_substate.rda`: appears to be up-to-date")
  file.remove("data-raw/6160055001_DO005.xlsx")
} else {
  message("updating `payroll_substate.rda`")
  
  abs_file <- abs_test
  
  
  payroll_substate <- abs_file %>%
    dplyr::mutate(state_name_2016 = strayr(state, to = "state_name"),
           sa3_name_2016 = sa3,
           indicator = "Payroll Index") %>%
    dplyr::left_join(absmapsdata::sa32016) %>%
    dplyr::select(state_name_2016, date, value, sa3_code_2016, indicator) %>%
    dplyr::filter(!is.na(sa3_code_2016), !is.na(value))
  
  usethis::use_data(payroll_substate, overwrite = TRUE, compress = "xz")
  
  file.remove("data-raw/6160055001_DO005.xlsx")
  
}