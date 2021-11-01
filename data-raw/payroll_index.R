library(dplyr)
library(tidyr)
library(readxl)
library(readabs)
library(strayr)


abs_test <- readabs::read_payrolls("industry_jobs", path = "data-raw")


if (max(abs_test$date) <= max(aitidata::payroll_index$date)) {
  message("Skipping `payroll_index.rda`: appears to be up-to-date")
  file.remove("data-raw/6160055001_DO004.xlsx")
} else {
  message("Updating `payroll_index.rda`")
  
  payroll_index <- readabs::read_payrolls("industry_jobs", path = "data-raw") %>%
    dplyr::rename(gender = sex,
                  indicator = series) %>%
    dplyr::mutate(indicator = "payroll_jobs",
                  state = strayr::clean_state(state, to = "state_name"))
  
  payroll_wages <- readabs::read_payrolls("industry_wages", path = "data-raw") %>%
    dplyr::rename(gender = sex,
                  indicator = series) %>%
    dplyr::mutate(indicator = "payroll_wages",
                  state = strayr::clean_state(state, to = "state_name"))

  
  payroll_index <- dplyr::bind_rows(payroll_jobs, payroll_wages)
  
  file.remove("data-raw/6160055001_DO004.xlsx")
  
  usethis::use_data(payroll_index, overwrite = TRUE, compress = "xz")
  
}
