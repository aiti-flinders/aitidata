## code to prepare `labour_account` dataset goes here

library(tidyr)
library(dplyr)
library(lubridate)

abs_test <- download_data_cube(catalogue_string = "labour-account-australia",
                               cube = "Table 21. Unbalanced: total all industries - original",
                               path = "data-raw")

current_date <- read_xls(here::here(abs_test),
                         sheet = 2,
                         skip = 9) %>%
  select(1) %>%
  pull() %>%
  max() %>%
  as.Date()

if (current_date <= max(labour_account$date)) {
  message("Skipping `labour_account.rda`: appears to be up-to-date")
} else {
  message("Updating `data/labour_account.rda`")
  
  abs_file <- download_data_cube(catalogue_string = "labour-account-australia", 
                                 cube = "Table 1. Total all industries - trend, seasonally adjusted and original", 
                                 path = "data-raw")
  
  labour_account <- readabs::read_abs_local(filenames = abs_file, path = "data-raw") %>%
    mutate(series = ifelse((grepl("Public sector", series) | grepl("Private sector", series)), gsub(x = series, pattern = "; P", replacement = "- P"), series)) %>%
    separate(series,
             into = c("prefix", "indicator", "state", "industry"),
             sep = ";",
             extra = "drop"
    ) %>%
    mutate(across(where(is.character), trimws),
           year = year(date),
           month = month(date, abbr = FALSE, label = TRUE)
    ) %>%
    filter(!grepl(" - Percentage changes", indicator),
           !is.na(value)) %>%
    select(date, month, year, prefix, indicator, state, industry, series_type, value, unit)
  
  
  file.remove(abs_file)
  
  save(labour_account, file = here::here("data", "labour_account.rda"), compress = "xz")
}
