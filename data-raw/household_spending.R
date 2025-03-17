## code to prepare `household_spending` dataset goes here
library(readabs)
library(dplyr)
library(lubridate)
library(usethis)

raw <- read_abs(cat_no = "5682.0", tables = 1:9, retain_files = FALSE) 

household_spending <- raw %>%
  separate_series(column_names = c("indicator", "coicop_division", "state", "price"),
                           remove_nas = TRUE)  |> 
  filter(indicator == "Calendar adjusted household spending - Index")  |> 
  mutate(value = ifelse(unit == "000", 1000 * value, value),
                year = year(date),
                month = month(date, label = TRUE, abbr = FALSE)) |> 
  dplyr::select("date", 
                "year", 
                "month",
                "indicator", 
                "coicop_division",
                "state",
                "series_type",
                "value",
                "unit")

use_data(household_spending, overwrite = TRUE, compress = "xz")

