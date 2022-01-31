## code to prepare `retail_trade` dataset goes here
library(readabs)
library(dplyr)
library(lubridate)

retail_trade <- read_abs("8501.0", tables = 12) %>%
  separate_series(column_names = c("indicator", "state", "industry_group")) %>%
  mutate(year = year(date),
         month = month(date, abbr = FALSE, label = TRUE),
         state = case_when(
           state == "Total (State)" ~ "Australia",
           TRUE ~ state
         )) %>%
  select(date, year, month, state, industry_group, series_type, value, unit)



usethis::use_data(retail_trade, overwrite = TRUE, compress = "xz")
