library(readxl)
library(janitor)
library(dplyr)
library(tidyr)
library(strayr)
library(stringr)

download.file(
  url = "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release/6160055001_do005.xlsx",
  destfile = "data-raw/payroll_substate.xlsx",
  mode = "wb"
)

message("updating `payroll_substate.rda`")

download_data_cube("weekly-payroll-jobs-and-wages-australia",
                       cube = "6160055001_DO005.xlsx",
                       path = "data-raw"
)

payroll_substate <- read_xlsx(here::here("data-raw", "6160055001_DO005.xlsx"), sheet = "Payroll jobs index-SA3", skip = 5, na = "NA") %>%
  janitor::clean_names() %>%
  mutate(across(starts_with("x"), as.numeric)) %>%
  pivot_longer(
    cols = c(4:length(.)),
    names_to = "date",
    values_to = "value"
  ) %>%
  mutate(across(1:4, ~ gsub("^[0-9]. ", "", .)),
         date = gsub("x", "", date),
         date = as.numeric(date),
         date = as.Date(date, origin = "1899-12-30"),
         value = as.numeric(value),
         sa3_code_2016 = ifelse(statistical_area_3 != "All SA4", str_sub(statistical_area_3, start = 1L, end = 5L), NA),
         state_or_territory = strayr(state_or_territory, to = "state_name"),
         indicator = "payroll_index"
  ) %>%
  select(
    state_name_2016 = state_or_territory,
    date,
    value,
    sa3_code_2016,
    indicator
  ) %>%
  filter(
    !is.na(sa3_code_2016),
    !is.na(value)
  ) %>%
  pivot_wider(id_cols = c(-indicator, -value), names_from = indicator, values_from = value)

save(payroll_substate, file = here::here("data", "payroll_substate.rda"), compress = "xz")