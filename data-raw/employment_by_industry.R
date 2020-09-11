## code to prepare `employment_by_industry` dataset goes here. 
library(readabs)
library(lubridate)
library(dplyr)
library(tidyr)

raw_path <- here::here("data-raw", "abs")

old_lfs_6291_23a <- read_abs_local("6291.0.55.003", "23a", path = raw_path)

new_lfs_6291_23a <- read_abs("6291.0.55.003", "23a",  check_local = FALSE, path = raw_path)

old_date <- max(old_lfs_6291_23a$date)
new_date <- max(new_lfs_6291_23a$date)

if (new_date > old_date) {
  
  message("updating `employment_by_industry`")
  
  raw <- read_abs("6291.0.55.003", tables = c(5, 19), retain_files = FALSE)
  
  employment_industry_5 <- raw %>%
    filter(table_no == "6291005") %>% 
    separate(series, into = c("state", "industry", "indicator"), sep = ";", extra = "drop") %>%
    mutate(across(c("state", "industry", "indicator"), ~str_remove_all(., "> ")),
           across(where(is.character), ~trimws(.)),
           indicator = ifelse(indicator == "", industry, indicator),
           industry = ifelse(str_detect(industry, "Employed"), "Total (industry)", industry),
           gender = "Persons",
           age = "Total (age)",
           year = year(date),
           month = month(date, label = TRUE, abbr = FALSE),
           value = ifelse(unit == "000", value*1000, value)) %>%
    select(date, year, month, indicator, industry, gender, age, state, series_type, value, unit)
    
    
    
  
  employment_industry_19 <- raw %>%
    filter(table_no == "6291019") %>%
    separate(series, into = c("industry", "indicator", "gender"), sep = ';',extra = 'drop') %>%
    mutate(across(c('industry', 'indicator', 'gender'), ~str_remove_all(., "> ")),
           across(where(is.character), ~trimws(.)),
           year = year(date),
           month = month(date, label = TRUE, abbr = FALSE),
           value = ifelse(unit == "000", value*1000, value),
           state = "Australia",
           age = "Total (age)",
           gender = ifelse(gender == "", indicator, gender),
           indicator = ifelse(indicator %in% gender, industry, indicator),
           industry = ifelse(industry %in% indicator, "Total (industry)", industry)) %>%
    filter(!industry %in% c("Managers", "Professionals", "Technicians and Trades Workers", "Community and Personal Service Workers", "Clerical and Administrative Workers", "Sales Workers", "Machinery Operators and Drivers", "Labourers")) %>%
    select(date, year, month, indicator, industry, gender, age, state, series_type, value, unit)
  
  
  employment_by_industry <- bind_rows(employment_industry_5, employment_industry_19) %>%
    distinct()
  
  save(employment_by_industry, file = here::here("data", "employment_by_industry.rda"), compress = 'xz')
} else {
  message("`employment_by_industry` is up to date")
  
}

