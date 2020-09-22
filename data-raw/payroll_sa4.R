#Payroll SA4 data comes from 6160.0.55.001, table 5 - called "6160055001_do005"

  ## code to prepare `payroll_sa4` dataset goes here
  library(dplyr)
  library(tidyr)
  library(janitor)
  library(readxl)
  library(forcats)

  download.file(url = "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release/6160055001_do005.xlsx",
                destfile = "data-raw/payroll_sa4.xlsx",
                mode = 'wb')

  payroll_sa4 <- read_xlsx(here::here("data-raw", "payroll_sa4.xlsx"), sheet = "Payroll jobs index-SA4", skip = 5, na = "NA") %>%
    janitor::clean_names() %>%
    mutate(across(starts_with("x"), as.numeric)) %>%
    pivot_longer(cols = c(5:length(.)),
                 names_to = "date",
                 values_to = "value") %>%
    mutate(across(1:4, ~gsub("^[0-9]. ", "", .)),
           date = gsub("x", "", date),
           date = as.numeric(date),
           date = as.Date(date, origin = "1899-12-30"),
           value = as.numeric(value),
           age_group = as_factor(age_group),
           sa4_code_2016 = ifelse(statistical_area_4 != "All SA4", str_sub(statistical_area_4, start = 1L, end = 3L), NA),
           state_or_territory = strayr::strayr(state_or_territory, to = "state_name"),
           indicator = "payroll_index") %>%
    select(state_name_2016 = state_or_territory,
           date,
           value,
           sa4_code_2016,
           indicator) %>% 
    filter(!is.na(sa4_code_2016),
           !is.na(value))
  
  # payroll_industry <- read_xlsx(here::here("data-raw", "payroll_sa4.xlsx"), sheet = "Payroll jobs index-Subdivision", skip = 5, na = "NA", n_max = 1041) %>%
  #   janitor::clean_names() %>%
  #   pivot_longer(cols = c(5:length(.)),
  #                names_to = 'date',
  #                values_to = "value") %>%
  #   mutate(across(1:4, ~str_remove_all(., "^[0-9]. ")),
  #          across(date, ~str_remove_all(., "x") %>% as.numeric() %>% as.Date(., origin = "1899-12-30")),
  #          across(value, ~as.numeric(.)),
  #          across(age_group, ~as_factor(.)),
  #          across(industry, ~str_sub(., 7, str_length(.)))) %>%
  #   filter(sex == "Persons", 
  #          age_group == "All ages",
  #          sub_division == "All sub-divisions",
  #          industry != "dustries", 
  #          !is.na(value)) %>%
  #   filter(date == max(.$date)) %>%
  #   select(industry, value) %>%
  #   mutate(across(industry, ~str_to_title(.) %>% str_replace_all(., "&", "and"))) 
  
  file.remove(here::here("data-raw", "payroll_sa4.xlsx"))
  
  # save(payroll_industry, file = here::here("data", "payroll_industry.rda"), compress = "xz")
  
  save(payroll_sa4, file = here::here("data", "payroll_sa4.rda"), compress = "xz")



