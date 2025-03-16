## code to prepare `labour_force_industry` dataset goes here
library(readabs)
library(dplyr)
library(stringr)
library(usethis)
library(tidyr)
library(lubridate)
library(strayr)


# Industry/Occupation Underemployment -------------------------------------

download_abs_data_cube("labour-force-australia-detailed",
                       cube = "6291019.xlsx",
                       path = "data-raw")

table_19 <- read_abs_local(filenames = "6291019.xlsx",
                           path = "data-raw") |> 
  separate_series(column_names = c("industry", "indicator", "sex"),
                  remove_nas = TRUE)  |> 
  mutate(year = year(date),
         month = month(date, label = TRUE, abbr = FALSE),
         value = ifelse(unit == "000", value * 1000, value),
         state = "Australia",
         age = "Total (age)",
         industry = ifelse(is.na(industry), "Total (industry)", industry)) %>%
  filter(indicator != "Employed total")

industry_underemployment <- table_19 |> 
  filter(industry %in% c("Managers",
                         "Professionals",
                         "Technicians and Trades Workers",
                         "Community and Personal Service Workers",
                         "Clerical and Administrative Workers",
                         "Sales Workers",
                         "Machinery Operators and Drivers",
                         "Labourers")) |> 
  select("date",
         "year",
         "month",
         "indicator",
         "industry",
         "sex",
         "age",
         "state",
         "series_type",
         "value",
         "unit")

occupation_underemployment <- table_19 |> 
  filter(industry %in% c("Managers",
                         "Professionals",
                         "Technicians and Trades Workers",
                         "Community and Personal Service Workers",
                         "Clerical and Administrative Workers",
                         "Sales Workers",
                         "Machinery Operators and Drivers",
                         "Labourers")) |> 
  select("date",
         "year",
         "month",
         occupation = "indicator",
         industry,
         "sex",
         "age",
         "state",
         "series_type",
         "value",
         "unit")

file.remove("data-raw/6291019.xlsx")
use_data(industry_underemployment, overwrite = TRUE, compress = "xz")
use_data(occupation_underemployment, overwrite = TRUE,compress = "xz")


# Industry Employment -----------------------------------------------------

download_abs_data_cube("labour-force-australia-detailed",
                       cube = "6291005.xlsx",
                       path = "data-raw")

industry_employment <- read_abs_local(path = "data-raw",
                                      filenames = "6291005.xlsx") |> 
  separate(series, 
           into = c("state", "industry", "indicator"), 
           sep = ";", 
           extra = "drop") |> 
  mutate(across(c("state", "industry", "indicator"), ~ gsub(pattern = "> ", x = .x, replacement = "")),
         across(where(is.character), ~trimws(.x)),
         indicator = ifelse(indicator == "", industry, indicator),
         industry = ifelse(grepl(x = industry, pattern = "Employed"), "Total (industry)", industry)) |> 
  group_by(date, indicator, state) |> 
  mutate(value_share = 200 * value / sum(value)) |> # Because the total is included, percentages are off by half. 
  ungroup() 

file.remove("data-raw/6291005.xlsx")
use_data(industry_employment, overwrite = TRUE, compress = "xz")

# Detailed Industry Employment --------------------------------------------
download_abs_data_cube("labour-force-australia-detailed",
                       cube = "EQ06",
                       path = "data-raw")

eq6 <- read_excel(path = "data-raw/EQ06.xlsx",
                  sheet = "Data 1",
                  skip = 3) |> 
  pivot_longer(cols = 5:8, 
               names_to = "indicator",
               values_to = "value") |> 
  rename(date = "Mid-quarter month",
         sex = "Sex",
         state = "State and territory (STT): ASGS (2011)",
         anzsic_group = "Industry group of main job: ANZSIC (2006) Rev.2.0") |> 
  mutate(date = as.Date(date),
         anzsic_group = str_sub(anzsic_group, 5)) |>  
  replace_na(list(value = 0)) 

industry_employment_detailed <- left_join(eq6, anzsic2006 |> distinct(anzsic_division, anzsic_subdivision, anzsic_group)) |> 
  distinct() |> 
  group_by(date, indicator, sex, state, anzsic_subdivision, anzsic_division) |> 
  summarise(value = sum(value), 
            .groups = "drop") |> 
  mutate(value = value * 1000,
         indicator = str_replace_all(indicator, "\\('000.+", ""),
                                     indicator = trimws(indicator))
use_data(industry_employment_detailed, compress = "xz", overwrite = TRUE) 

