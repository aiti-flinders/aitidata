library(dplyr)
library(tidyr)
library(readxl)
library(readabs)


abs_test <- download_data_cube(catalogue_string = "weekly-payroll-jobs-and-wages-australia",
                               cube = "6160055001_DO004.xlsx",
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
  
  payroll_jobs <- readabs::read_payrolls("industry_jobs", path = "data-raw") %>%
    rename(gender = sex,
           payroll_jobs = series)
  
  payroll_wages <- readabs::read_payrolls("industry_wages", path = "data-raw") %>%
    rename(gender = sex,
           payroll_wages = series)
  
 
  payroll_index <- dplyr::bind_rows(payroll_jobs, payroll_wages)
  
  file.remove("data-raw/6160055001_DO004.xlsx")
  
  usethis::use_data(payroll_index, overwrite = TRUE, compress = "xz")
}