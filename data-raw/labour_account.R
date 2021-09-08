## code to prepare `labour_account` dataset goes here
library(tidyr)
library(dplyr)
library(lubridate)

abs_test <- aitidata::download_data_cube(catalogue_string = "labour-account-australia",
                               cube = "6150055003DO001_2020202106.xls",
                               path = "data-raw")

current_date <- readxl::read_xls(abs_test, sheet = 2, skip = 9) %>%
  dplyr::select(1) %>%
  dplyr::pull() %>%
  max() %>%
  as.Date()

if (current_date <= max(aitidata::labour_account$date)) {
  message("Skipping `labour_account.rda`: appears to be up-to-date")
  file.remove(abs_test)
} else {
  message("Updating `data/labour_account.rda`")
  
  abs_file <- abs_test
  
  labour_account <- readabs::read_abs_local(filenames = abs_file, path = "data-raw") %>%
    dplyr::mutate(series = ifelse((grepl("Public sector", series) | grepl("Private sector", series)), 
                                  gsub(x = series, pattern = "; P", replacement = "- P"), 
                                  series)) %>%
    tidyr::separate(series, into = c("prefix", "indicator", "state", "industry"), sep = ";", extra = "drop") %>%
    dplyr::mutate(dplyr::across(where(is.character), trimws),
                  year = lubridate::year(date),
                  month = lubridate::month(date, abbr = FALSE, label = TRUE)) %>%
    dplyr::filter(!grepl(" - Percentage changes", indicator),
                  !is.na(value)) %>%
    dplyr::select(date, month, year, prefix, indicator, state, industry, series_type, value, unit)
  
  file.remove(abs_file)
  
  usethis::use_data(labour_account, overwrite = TRUE, compress = "xz")
}
