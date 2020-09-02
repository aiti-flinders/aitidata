## code to prepare `payroll_sa4` dataset goes here
library(tidyverse)
library(readxl)
library(sf)
library(absmapsdata)

#Payroll SA4 data comes from 6160.0.55.001, table 5 - called "6160055001_do005"

readabs::download_abs_data_cube("6160.0.55.001", cube = "6160055001_do005", path = "data-raw")
file.rename("data-raw/6160055001_do005.xlsx", "data-raw/payroll_sa4.xlsx")

payroll_sa4 <- read_xlsx("data-raw/payroll_sa4.xlsx", sheet = "Payroll jobs index-SA4", skip = 5, na = "NA") %>%
  janitor::clean_names() %>%
  mutate(across(starts_with("x"), as.numeric)) %>%
  pivot_longer(cols = c(5:length(.)),
               names_to = "date",
               values_to = "value") %>%
  mutate(across(1:4, ~str_remove_all(., "^[0-9]. ")),
         across(date, ~str_remove_all(., "x") %>% as.numeric() %>% as.Date(., origin = "1899-12-30")),
         across(value, ~as.numeric(.)),
         across(age_group, ~as_factor(.)),
         sa4_code_2016 = ifelse(statistical_area_4 != "All SA4", str_sub(statistical_area_4, start = 1L, end = 3L), NA)) %>%
  select(state_name_2016 = state_or_territory,
         gender = sex,
         age = age_group,
         date,
         value,
         sa4_code_2016) %>% 
  mutate(across(state_name_2016, ~strayr::strayr(., to = "state_name")),
         indicator = "payroll_index") %>%
  select(-gender, -age) %>%
  filter(!is.na(sa4_code_2016),
         !is.na(value))

payroll_industry <- read_xlsx("data-raw/payroll_sa4.xlsx", sheet = "Payroll jobs index-Subdivision", skip = 5, na = "NA", n_max = 1041) %>%
  janitor::clean_names() %>%
  pivot_longer(cols = c(5:length(.)),
               names_to = 'date',
               values_to = "value") %>%
  mutate(across(1:4, ~str_remove_all(., "^[0-9]. ")),
         across(date, ~str_remove_all(., "x") %>% as.numeric() %>% as.Date(., origin = "1899-12-30")),
         across(value, ~as.numeric(.)),
         across(age_group, ~as_factor(.)),
         across(industry, ~str_sub(., 7, str_length(.)))) %>%
  filter(sex == "Persons", 
         age_group == "All ages",
         sub_division == "All sub-divisions",
         industry != "dustries", 
         !is.na(value)) %>%
  filter(date == max(.$date)) %>%
  select(industry, value) %>%
  mutate(across(industry, ~str_to_title(.) %>% str_replace_all(., "&", "and"))) 

usethis::use_data(payroll_industry, compress = "xz", overwrite = TRUE)
  

usethis::use_data(payroll_sa4, compress = "xz", overwrite = TRUE)
