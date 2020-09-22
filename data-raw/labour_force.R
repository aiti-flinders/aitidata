## code to prepare `labour_force` dataset goes here. It contains data from 4 relevant releases of the 6202.0 series released on the 3rd Thursday of each month.
## Table 12. Labour force status by Sex, State and Territory - Trend, Seasonally adjusted and Original
## Table 19. Monthly hours worked in all jobs by Employed full-time, part-time and Sex and by State and Territory - Trend and Seasonally adjusted
## Table 22. Underutilised persons by Age and Sex - Trend, Seasonally adjusted and Original
## Table 23. Underutilised persons by State and Territory and Sex - Trend, Seasonally adjusted and Original

library(readabs)
library(dplyr)
library(tidyr)
library(lubridate)


raw_path <- here::here("data-raw", "abs")
old_lfs_6202_11a <- read_abs_local("6202.0", "11a", path = raw_path)

new_lfs_6202_11a <- read_abs("6202.0", "11a", check_local = FALSE, path = raw_path)

old_date <- max(old_lfs_6202_11a$date)
new_date <- max(new_lfs_6202_11a$date)

if (new_date > old_date) {
  
  states <- c(
    "New South Wales",
    "Victoria",
    "Queensland",
    "South Australia",
    "Western Australia",
    "Tasmania",
    "Northern Territory",
    "Australian Capital Territory"
  )
  
  message("Updating `data/labour_force.rda`")
  
  raw <- read_abs(cat_no = "6202.0", tables = c("12","19","22","23"), retain_files = FALSE)
  
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
    mutate(across(c(indicator, gender), ~trimws(gsub(">", "", .))),
           state = ifelse(gender %in% states, gender, "Australia"),
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
    mutate(across(c(indicator, gender, age), ~trimws(gsub(">", "", .))),
           age = ifelse(age == "", "Total (age)", age),
           value = ifelse(unit == "000", (1000*value), value),
           year = year(date),
           month = month(date, label = T, abbr = F),
           state = "Australia") %>%
    select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  
  labour_force_23 <- raw %>%
    filter(table_no == 6202023) %>%
    separate(series, into = c("indicator", "gender", "state"), sep = ";") %>%
    mutate(across(c(indicator, gender, state), ~trimws(gsub(">", "", .))),
           state = ifelse(state == "", "Australia", state),
           value = ifelse(unit == "000", (1000*value), value),
           year = lubridate::year(date),
           month = lubridate::month(date, label = T, abbr = F),
           age = "Total (age)") %>%
    select(date, year, month, indicator, gender, age, state, series_type, value, unit)

  labour_force <- bind_rows(list(labour_force_12, labour_force_19, labour_force_22, labour_force_23)) %>%
    distinct() %>%
    pivot_wider(names_from = indicator, values_from = value) %>%
    mutate("Underutilised total" = `Unemployed total` + `Underemployed total`) %>%
    janitor::clean_names()
  
  
    pivot_longer(cols = c(9:length(.)), names_to = "indicator", values_to = "value", values_drop_na = TRUE)

  save(labour_force, file = here::here("data", "labour_force.rda"), compress = 'xz')
} else {
  message("`labour_force.rda` is already up to date")
}






