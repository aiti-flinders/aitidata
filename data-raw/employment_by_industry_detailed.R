## code to prepare `employment_by_industry_detailed` dataset goes here

library(tidyverse)
library(readxl)
library(readabs)

download_abs_data_cube("6291.0.55.003", cube = "EQ06", path = "data-raw")


df <- read_excel(path = unzip("data-raw/EQ06.zip"),
                 sheet = "Data 1",
                 skip = 3) %>%
  pivot_longer(cols = 5:8, names_to = "indicator", values_to = "value") %>%
  rename(date = "Mid-quarter month",
         gender = "Sex",
         region = "State and territory (STT): ASGS (2011)",
         group = "Industry group of main job: ANZSIC (2006) Rev.2.0") %>%
  mutate(date = as.Date(date),
         group = str_sub(group, 5)) %>%
  pivot_wider(id_cols = -gender,
              names_from = gender,
              values_from = value) %>%
  mutate(Persons = Males + Females) %>%
  pivot_longer(cols = 5:7,
               names_to = "gender",
               values_to = "value") %>%
  pivot_wider(id_cols = -region,
              names_from = region,
              values_from = value) %>%
  mutate(Australia = pmap_dbl(select(., 5:12), sum, na.rm = T)) %>%
  pivot_longer(5:13,
               names_to = "state",
               values_to = "value") %>%
  replace_na(list(value = 0))

anzsic_c <- daitir::anzsic %>%
  select(-class)

employment_by_industry_detailed <- left_join(df, anzsic_c) %>%
  distinct() %>%
  group_by(date, indicator, gender, state, subdivision, division) %>%
  summarise(value = sum(value)) %>%
  ungroup() %>%
  mutate(value = value*1000,
         indicator = str_replace_all(indicator, "\\('000.+", ""))

file.remove("data-raw/eq06.zip")
usethis::use_data(employment_industry_detailed, overwrite = TRUE, compress = 'xz')
