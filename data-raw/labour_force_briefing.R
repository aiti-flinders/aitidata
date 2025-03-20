## code to prepare `labour_force_briefing` dataset goes here
library(readabs)
library(dplyr)
library(lubridate)
library(tidyr)


raw <- read_abs(cat_no = "6202.0", tables = c("12", "12a", "19", "19a", "22", "23", "23a"), retain_files = F)

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

labour_force_status <- raw |>
  filter(table_no == "6202012" | table_no == "6202012a") |>
  separate_series(column_names = c("indicator", "sex", "state"), remove_nas = TRUE)



hours_worked <- raw  |>
  filter(table_no == "6202019" | table_no == "6202019a") |>
  separate(series, into = c("indicator", "sex", "state"), sep = ";") |>
  mutate(across(c("indicator", "sex"), ~ trimws(gsub(">", "", .))),
         state = ifelse(sex %in%  states, sex, "Australia"),
         sex = ifelse(sex %in% states, "Persons", sex))

underutilisation_aus <- raw |>
  filter(table_no == 6202022) |>
  separate_series(column_names = c("indicator", "sex", "age"), remove_nas = TRUE)


underutilisation_state <- raw |>
  filter(table_no == "6202023" | table_no == "6202023a",
         grepl("Underemploy|Underutilisation", series)) |>
  separate(col = series, into = c("indicator", "sex", "state"), sep = ";", extra = "drop") |>
  mutate(across(c("indicator", "sex", "state"), ~ trimws(gsub(">", "", .))),
         state = ifelse(state == "", "Australia", state))

labour_force <- bind_rows(list(labour_force_status, underutilisation_aus, underutilisation_state)) |>
  filter(!is.na(value),
         date >= max(date) - years(5),
         series_type == "Seasonally Adjusted")  |>
  mutate(age = ifelse(is.na(age), "Total (age)", age),
         state = ifelse(is.na(state), "Australia", state)) |>
  distinct(date, indicator, sex, state, series_type, unit, age, value, .keep_all = TRUE) |>
  filter(age == "Total (age)") |>
  select(date, indicator, sex, state, value, series_type, unit) |>
  pivot_wider(id_cols = c(date, sex, state, series_type, unit), names_from = indicator, values_from = value) |>
  mutate(`Employed part-time` = case_when(
    is.na(`Employed part-time`) ~ `Employed total` - `Employed full-time`,
    TRUE ~ `Employed part-time`),
    `Underutilised total` = `Underemployed total` + `Unemployed total`) |>
  pivot_longer(cols = "Employed total":"Underutilised total",
               names_to = "indicator",
               values_to = "value",
               values_drop_na = TRUE) |>
  mutate(value = ifelse(unit == "000", value * 1000, value))

hours_worked <- hours_worked |>
  filter(date >= max(date) - years(5),
         series_type == "Seasonally Adjusted") |>
  select(date, indicator, sex, state, series_type, unit, value)

labour_force_briefing <- bind_rows(labour_force, hours_worked)

usethis::use_data(labour_force_briefing, compress = 'xz', overwrite = TRUE)
