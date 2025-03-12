## code to prepare `payroll_data` dataset goes here
library(readabs)
library(purrr)

payroll_index <- map(
  .x = c("industry_jobs", 
         "subindustry_jobs", 
         "empsize_jobs"), 
  .f = function(x) read_payrolls(x, path = "data-raw"))

file.remove(paste0("data-raw/", c("6160055001_DO001.xlsx",
                                  "6160055001_DO002.xlsx",
                                  "6160055001_DO003.xlsx")))

use_data(payroll_index, overwrite = TRUE, compress = "xz")
