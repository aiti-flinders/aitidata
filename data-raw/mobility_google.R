## code to prepare `mobility_google` dataset goes here
library(dplyr)
library(readr)
library(tidyr)

url <- "https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv"

mobility_google <- read_csv(url,
                            col_types = cols(
                              country_region_code = col_character(),
                              country_region = col_character(),
                              sub_region_1 = col_character(),
                              sub_region_2 = col_character(),
                              date = col_date(format = "%Y-%m-%d"),
                              retail_and_recreation_percent_change_from_baseline = col_double(),
                              grocery_and_pharmacy_percent_change_from_baseline = col_double(),
                              parks_percent_change_from_baseline = col_double(),
                              transit_stations_percent_change_from_baseline = col_double(),
                              workplaces_percent_change_from_baseline = col_double(),
                              residential_percent_change_from_baseline = col_double(),
                              census_fips_code = col_character())) %>%
  filter(country_region == "Australia" & is.na(sub_region_2)) %>%
  pivot_longer(ends_with("_percent_change_from_baseline"),
               names_to = "category",
               values_to = "trend") %>%
  select(state = sub_region_1,
         category = category,
         date = date,
         trend = trend) %>%
  mutate(category = gsub(pattern = "_percent_change_from_baseline", x = category, replacement = ""),
         category = gsub(x = category, pattern = "_", replacement = " "),
         state = ifelse(is.na(state), "Australia", state))



usethis::use_data(mobility_google, overwrite = TRUE)
