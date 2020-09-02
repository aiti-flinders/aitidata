## code to prepare `labour_force` dataset goes here
## code to prepare `labour_force` dataset goes here. It contains data from 4 relevant releases of the 6202.0 series released on the 3rd Thursday of each month.
## Table 12. Labour force status by Sex, State and Territory - Trend, Seasonally adjusted and Original
## Table 19. Monthly hours worked in all jobs by Employed full-time, part-time and Sex and by State and Territory - Trend and Seasonally adjusted
## Table 22. Underutilised persons by Age and Sex - Trend, Seasonally adjusted and Original
## Table 23. Underutilised persons by State and Territory and Sex - Trend, Seasonally adjusted and Original
library(readabs)
library(dplyr)
library(stringr)
library(tidyr)
library(readr)
library(lubridate)

force <- TRUE
states <- strayr::strayr(seq(1,8), to = "state_name")

if(!file.exists("data-raw/labour_force_raw.csv") | force) {
  
  read_abs(cat_no = "6202.0", tables = c(12,19,22,23), retain_files = FALSE) %>%
    write_csv("data-raw/labour_force_raw.csv")
  
}

raw <- read_csv("data-raw/labour_force_raw.csv")

labour_force_12 <- raw %>%
  filter(table_no == 6202012) %>%
  separate_series(column_names = c("indicator", "gender", "state")) %>%
  mutate(
    value = ifelse(unit == "000", (1000*value), (value)),
    year = year(date),
    month = month(date, label = TRUE, abbr = FALSE),
    age = "Total (age)"
  ) %>%
  select(date, year, month, indicator,  gender, age, state, series_type, value, unit)


labour_force_19 <- raw %>%
  filter(table_no == 6202019) %>%
  separate(series, into = c("indicator", "gender", "state"), sep = ";") %>%
  mutate_at(c("indicator", "gender"), ~trimws(str_replace(., ">", ""))) %>%
  mutate(state = ifelse(gender %in% states, gender, "Australia"),
         gender = ifelse(gender %in% states, "Persons", gender),
         unit = "000",
         value = ifelse(unit == "000", 1000*value, value),
         year = year(date),
         month = month(date, label = TRUE, abbr = FALSE),
         age = "Total (age)"
  ) %>%
  select(date, year, month, indicator, gender, age, state, series_type, value, unit)


labour_force_22 <- raw %>%
  filter(table_no == 6202022) %>%
  separate(series, into = c("indicator", "gender", "age"), sep = ";") %>%
  mutate_at(c("indicator", "gender", "age"), ~trimws(str_replace(., ">", ""))) %>%
  mutate(age = ifelse(age == "", "Total (age)", age),
         value = ifelse(unit == "000", (1000*value), value),
         year = lubridate::year(date),
         month = lubridate::month(date, label = T, abbr = F),
         state = "Australia") %>%
  select(date, year, month, indicator, gender, age, state, series_type, value, unit)


labour_force_23 <- raw %>%
  filter(table_no == 6202023) %>%
  separate(series, into = c("indicator", "gender", "state"), sep = ";") %>%
  mutate_at(c("indicator", "gender", "state"), ~trimws(str_replace(.,">", ""))) %>%
  mutate(state = ifelse(state == "", "Australia", state),
         value = ifelse(unit == "000", (1000*value), value),
         year = lubridate::year(date),
         month = lubridate::month(date, label = T, abbr = F),
         age = "Total (age)") %>%
  select(date, year, month, indicator, gender, age, state, series_type, value, unit)

labour_force <- bind_rows(list(labour_force_12, labour_force_19, labour_force_22, labour_force_23)) %>%
  distinct() %>%
  pivot_wider(names_from = indicator, values_from = value) %>%
  mutate("Underutilised total" = `Unemployed total` + `Underemployed total`) %>%
  pivot_longer(cols = c(9:length(.)), names_to = "indicator", values_to = "value", values_drop_na = TRUE)

write_csv(labour_force, "data-raw/labour_force.csv")

usethis::use_data(labour_force, overwrite = TRUE, compress = 'xz')




