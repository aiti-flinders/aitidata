## code to prepare `labour_force` dataset goes here
library(readabs)
library(dplyr)
library(tidyr)
library(usethis)

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


raw <- read_abs(cat_no = "6202.0", tables = c("12", "12a", "19", "19a", "22", "23", "23a"), retain_files = FALSE)

labour_force_status <- raw |> 
  filter(table_no == "6202012" | table_no == "6202012a") |> 
  separate_series(column_names = c("indicator", "sex", "state"), 
                  remove_nas = TRUE) 



hours_worked <- raw  |> 
  filter(table_no == "6202019" | table_no == "6202019a") |> 
  separate(series, 
           into = c("indicator", "sex", "state"), 
           sep = ";") |> 
  mutate(across(c("indicator", "sex"), ~ trimws(gsub(">", "", .))),
                state = ifelse(sex %in%  states, sex, "Australia"),
                sex = ifelse(sex %in% states, "Persons", sex))



underutilisation_aus <- raw |> 
  filter(table_no == 6202022) |> 
  separate_series(column_names = c("indicator", "sex", "age"), 
                  remove_nas = TRUE)


underutilisation_state <- raw |> 
  filter(table_no == "6202023" | table_no == "6202023a",
         grepl("Underemploy|Underutilisation", series)) |> 
  separate(series, 
           into = c("indicator", "sex", "state"), 
           sep = ";", 
           extra = "drop") |> 
  mutate(across(c("indicator", "sex", "state"), ~ trimws(gsub(">", "", .))),
         state = ifelse(state == "", "Australia", state))


labour_force <- bind_rows(list(labour_force_status, underutilisation_aus, underutilisation_state)) |> 
  filter(!is.na(value))  |>  
  mutate(age = ifelse(is.na(age), "Total (age)", age),
                state = ifelse(is.na(state), "Australia", state),
                value = ifelse(value == "000", value*1000, value)) |> 
  distinct(date, indicator, sex, state, series_type, unit, age, value) 

use_data(hours_worked, overwrite = TRUE, compress = "xz")
use_data(labour_force, overwrite = TRUE, compress = "xz")
