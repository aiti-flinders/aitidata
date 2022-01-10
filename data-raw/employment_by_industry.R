## code to prepare `employment_by_industry` dataset goes here.
library(readabs)
library(dplyr)
library(tidyr)
library(lubridate)



abs_test <- aitidata::download_data_cube("labour-force-australia-detailed", "6291023a.xlsx") 

abs_file <- readabs::read_abs_local(filenames = "6291023a.xlsx", path = "data-raw")

if (max(abs_file$date) <= max(aitidata::employment_by_industry$date)) {
  message("Skipping `employment_by_industry.rda`: appears to be up-to-date")
  file.remove(abs_test)
} else {
  message("updating `employment_by_industry`")
  
  raw <- aitidata::download_data_cube("labour-force-australia-detailed", "6291005.xlsx")
  
  employment_by_industry <- readabs::read_abs_local(filenames = raw, path = "data-raw") %>%
    tidyr::separate(series, into = c("state", "industry", "indicator"), sep = ";", extra = "drop") %>%
    dplyr::mutate(dplyr::across(c("state", "industry", "indicator"), ~ gsub(pattern = "> ", x = .x, replacement = "")),
                  dplyr::across(where(is.character), ~trimws(.x)),
                  indicator = ifelse(indicator == "", industry, indicator),
                  industry = ifelse(grepl(x = industry, pattern = "Employed"), "Total (industry)", industry),
                  gender = "Persons",
                  age = "Total (age)",
                  year = lubridate::year(date),
                  month = lubridate::month(date, label = TRUE, abbr = FALSE),
                  value = ifelse(unit == "000", value * 1000, value)) %>%
    dplyr::group_by(date,  indicator, gender, age, state) %>% 
    dplyr::mutate(value_share = 200 * value/sum(value)) %>%
    dplyr::ungroup() %>%
    dplyr::select(date, year, month, indicator, industry, gender, age, state, series_type, value, unit) 
  
  usethis::use_data(employment_by_industry, overwrite = TRUE, compress = "xz")
  file.remove(raw)
  
}
