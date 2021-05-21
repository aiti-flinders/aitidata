## code to prepare `internet_vacancies_regional` dataset goes here
library(readxl)
library(dplyr)
library(tidyr)

download.file("https://lmip.gov.au/PortalFile.axd?FieldID=2790179&.xlsx",
              destfile = "data-raw/ivi_test.xlsx",
              mode = "wb")

current_date <- read_excel("data-raw/ivi_test.xlsx",
                           sheet = "Trend") %>%
  select(last_col()) %>%
  colnames() %>%
  as.numeric() %>%
  as.Date(origin = "1899-12-30")

if (current_date <= max(aitidata::internet_vacancies_regional$date)) {
  message("Skipping `internet_vacancies_regional.rda`: appears to be up-to-date")
  file.remove("data-raw/ivi_test.xlsx")
} else {
  
  download.file("https://lmip.gov.au/PortalFile.axd?FieldID=2790180&.xlsx",
                destfile = "data-raw/ivi_regional.xlsx",
                mode = "wb")
  
  internet_vacancies_regional <- read_excel("data-raw/ivi_regional.xlsx",
                    sheet = "Averaged") %>%
    pivot_longer(cols = 6:length(.),
                 names_to = "date",
                 values_to = "vacancies") %>%
    mutate(across(date, ~as.Date(x = as.numeric(.x), origin = "1899-12-30")),
           unit = "000") %>%
    select(date,
           occupation_level = Level,
           state = State,
           region, 
           anzsco_code = ANZSCO_CODE,
           anzsco_title = ANZSCO_TITLE,
           vacancies)
  
  file.remove("data-raw/ivi_regional.xlsx")
  
  usethis::use_data(internet_vacancies_regional, overwrite = TRUE)

}
