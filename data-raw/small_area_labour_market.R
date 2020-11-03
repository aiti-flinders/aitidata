## code to prepare `small_area_labour_market` dataset goes here
library(tidyverse)
library(sf)

download.file("https://lmip.gov.au/PortalFile.axd?FieldID=3193958&.csv",
  destfile = "data-raw/salm_sa2.csv",
  mode = "wb"
)

raw <- read_csv("data-raw/salm_sa2.csv", skip = 1)

all_sa2 <- absmapsdata::sa22016 %>%
  as_tibble() %>%
  select(sa2_name_2016, sa2_main_2016, state_name_2016)

small_area_labour_market <- raw %>%
  janitor::clean_names() %>%
  mutate(across(where(is.numeric), as.character)) %>%
  pivot_longer(
    cols = c(4:length(.)),
    names_to = "date",
    values_to = "value"
  ) %>%
  rename(
    indicator = data_item,
    sa2_name_2016 = statistical_area_level_2_sa2_2016_asgs,
    sa2_main_2016 = sa2_code_2016_asgs
  ) %>%
  mutate(
    value = as.numeric(gsub(",", "", value)),
    date = as.Date(paste0(date, "_01"), format = "%b_%y_%d"),
    sa2_main_2016 = as.character(sa2_main_2016)
  ) %>%
  right_join(all_sa2) %>%
  complete(indicator, nesting(sa2_name_2016, sa2_main_2016), date) %>%
  filter(
    !is.na(date),
    !is.na(indicator)
  )

usethis::use_data(small_area_labour_market, overwrite = TRUE, compress = "xz")
