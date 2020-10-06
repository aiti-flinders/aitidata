## code to prepare `employment_by_industry` dataset goes here.
library(readabs)
library(lubridate)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)

message("updating `employment_by_industry`")

raw <- read_abs("6291.0.55.001", tables = c(5, 19), retain_files = FALSE)

employment_industry_5 <- raw %>%
  filter(table_no == "6291005") %>%
  separate(series, into = c("state", "industry", "indicator"), sep = ";", extra = "drop") %>%
  mutate(across(c("state", "industry", "indicator"), ~ str_remove_all(., "> ")),
    across(where(is.character), ~ trimws(.)),
    indicator = ifelse(indicator == "", industry, indicator),
    industry = ifelse(str_detect(industry, "Employed"), "Total (industry)", industry),
    gender = "Persons",
    age = "Total (age)",
    year = year(date),
    month = month(date, label = TRUE, abbr = FALSE),
    value = ifelse(unit == "000", value * 1000, value)
  ) %>%
  select(date, year, month, indicator, industry, gender, age, state, series_type, value, unit)


employment_industry_19 <- raw %>%
  filter(table_no == "6291019") %>%
  separate(series, into = c("industry", "indicator", "gender"), sep = ";", extra = "drop") %>%
  mutate(across(c("industry", "indicator", "gender"), ~ str_remove_all(., "> ")),
    across(where(is.character), ~ trimws(.)),
    year = year(date),
    month = month(date, label = TRUE, abbr = FALSE),
    value = ifelse(unit == "000", value * 1000, value),
    state = "Australia",
    age = "Total (age)",
    gender = ifelse(gender == "", indicator, gender),
    indicator = ifelse(indicator %in% gender, industry, indicator),
    industry = ifelse(industry %in% indicator, "Total (industry)", industry)
  ) %>%
  filter(!industry %in% c("Managers", "Professionals", "Technicians and Trades Workers", "Community and Personal Service Workers", "Clerical and Administrative Workers", "Sales Workers", "Machinery Operators and Drivers", "Labourers")) %>%
  select(date, year, month, indicator, industry, gender, age, state, series_type, value, unit)


employment_by_industry <- bind_rows(employment_industry_5, employment_industry_19) %>%
  distinct()

save(employment_by_industry, file = here::here("data", "employment_by_industry.rda"), compress = "xz")

message("updating `employment_by_industry_detailed`")

daitir::download_abs_data_cube("labour-force-australia-detailed", cube = "EQ06", path = "data-raw")

df <- read_excel(
  path = "data-raw/EQ06.xlsx",
  sheet = "Data 1",
  skip = 3
) %>%
  pivot_longer(cols = 5:8, names_to = "indicator", values_to = "value") %>%
  rename(
    date = "Mid-quarter month",
    gender = "Sex",
    region = "State and territory (STT): ASGS (2011)",
    group = "Industry group of main job: ANZSIC (2006) Rev.2.0"
  ) %>%
  mutate(
    date = as.Date(date),
    group = str_sub(group, 5)
  ) %>%
  pivot_wider(
    id_cols = -gender,
    names_from = gender,
    values_from = value
  ) %>%
  mutate(Persons = Males + Females) %>%
  pivot_longer(
    cols = 5:7,
    names_to = "gender",
    values_to = "value"
  ) %>%
  pivot_wider(
    id_cols = -region,
    names_from = region,
    values_from = value
  ) %>%
  mutate(Australia = pmap_dbl(select(., 5:12), sum, na.rm = T)) %>%
  pivot_longer(5:13,
    names_to = "state",
    values_to = "value"
  ) %>%
  replace_na(list(value = 0))

anzsic_c <- daitir::anzsic %>%
  select(-class)

employment_by_industry_detailed <- left_join(df, anzsic_c) %>%
  distinct() %>%
  group_by(date, indicator, gender, state, subdivision, division) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  ungroup() %>%
  mutate(
    value = value * 1000,
    indicator = str_replace_all(indicator, "\\('000.+", "") %>% trimws()
  )

file.remove("data-raw/EQ06.xlsx")
save(employment_by_industry_detailed, file = here::here("data", "employment_by_industry_detailed.rda"), compress = "xz")
