## code to prepare `payroll_index` dataset goes here

if(!daitir::abs_data_up_to_date('6160.0.55.001', 'payroll_index')) {
  library(readabs)
  library(tidyr)
  library(stringr)
  library(forcats)
  library(dplyr)
  library(readxl)
  
  download_abs_data_cube("6160.0.55.001", cube = "6160055001_do004.xlsx", path = here::here("data-raw"))
  file.rename(here::here("data-raw", "6160055001_do004.xlsx"), here::here("data-raw", "payroll_index.xlsx"))
  
  payroll_index <- read_xlsx(here::here("data-raw", "payroll_index.xlsx"), sheet = "Payroll jobs index", skip = 5, na = "NA", n_max = 4321) %>%
    janitor::clean_names() %>%
    mutate(across(starts_with("x"), as.numeric)) %>%
    pivot_longer(cols = c(5:length(.)),
                 names_to = "date",
                 values_to = "value") %>%
    mutate(across(1:5, ~str_remove_all(., "^[0-9]\\. ")),
           across(industry_division, ~str_remove_all(., "(0[0-9]|1[0-9])\\. ([A-S]-)")),
           across(date, ~str_remove_all(., "x") %>% as.numeric() %>% as.Date(., origin = "1899-12-30")),
           across(value, ~as.numeric(.)),
           across(age_group, ~as_factor(.)),
           across(state_or_territory, ~strayr::strayr(., to = "state_name")),
           across(industry_division, ~str_to_title(.) %>% str_replace_all(., "&", "and"))) %>%
    select(date, gender = sex, age = age_group, state = state_or_territory, industry = industry_division, value)
  
  file.remove(here::here("data-raw", "payroll_index.xlsx"))
  
  save(payroll_index, file = here::here("data", "payroll_index.rda"), compress = "xz")
}
