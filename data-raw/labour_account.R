## code to prepare `labour_account` dataset goes here
library(tidyverse)
library(readabs)




if (!abs_data_up_to_date("6150.0.55.003") | !file.exists("data/labour_account.rda")) {
  message("updating `data/labour_account.rda`")
  download_abs_data_cube('6150.0.55.003', cube = '6150055003do001_2019202003', path = "data-raw")
  
  file.rename("data-raw/6150055003do001_2019202003.xls", "data-raw/labour_account.xls")

  raw <- read_abs_local(path = "data-raw", filenames = "labour_account.xls")

  labour_account <- raw %>%
    separate(series,
             into = c("prefix", "indicator", "state", "industry"),
             sep = ";",
             extra = "drop") %>%
    mutate_if(is.character, trimws)  %>%
    filter(!is.na(value)) %>%
    mutate(year = lubridate::year(date),
           month = lubridate::month(date, abbr = FALSE, label = TRUE)) %>%
    select(date, month, year, prefix, indicator, state, industry, series_type, value, unit)
  
  file.remove("data-raw/labour_account.xls")
  
  usethis::use_data(labour_account, overwrite = TRUE, compress = 'xz')
} else {
  message("`data/labour_account.rda` is already up to date")
}

