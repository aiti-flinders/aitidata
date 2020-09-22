## code to prepare `payroll_index` dataset goes here

library(readabs)
library(tidyr)
library(stringr)
library(dplyr)
library(readxl)
library(forcats)

download.file(url = "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release/6160055001_do004.xlsx",
              destfile = "data-raw/payroll_index.xlsx",
              mode = 'wb')

payroll_index <- read_xlsx(here::here("data-raw", "payroll_index.xlsx"), sheet = "Payroll jobs index", skip = 5, na = "NA", n_max = 4321) %>%
  janitor::clean_names() %>%
  mutate(across(starts_with("x"), as.numeric)) %>%
  pivot_longer(cols = c(5:length(.)),
               names_to = "date",
               values_to = "value") %>%
  mutate(across(1:5, ~gsub("^[0-9]\\. ", "", .)),
         industry_division = gsub("(0[0-9]|1[0-9])\\. ([A-S]-)", "", industry_division),
         date = gsub("x", "", date),
         date = as.numeric(date),
         date = as.Date(date, origin = "1899-12-30"),
         value = as.numeric(value),
         age_group = as_factor(age_group),
         state_or_territory = strayr::strayr(state_or_territory, to = "state_name"),
         industry_division = str_to_title(industry_division),
         industry_division = gsub("&", "and", industry_division)) %>%
  select(date, gender = sex, age = age_group, state = state_or_territory, industry = industry_division, value)

file.remove(here::here("data-raw", "payroll_index.xlsx"))

save(payroll_index, file = here::here("data", "payroll_index.rda"), compress = "xz")

