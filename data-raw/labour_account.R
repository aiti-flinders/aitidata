## code to prepare `labour_account` dataset goes here
library(readabs)
library(tidyr)
library(dplyr)
library(lubridate)


message("updating `data/labour_account.rda`")
download_abs_data_cube('6150.0.55.003', cube = '6150055003do001_2019202006', path = here::here("data-raw"))

file.rename(here::here("data-raw","6150055003do001_2019202006.xls"), here::here("data-raw","labour_account.xls"))

raw <- read_abs_local(path = here::here("data-raw"), filenames = "labour_account.xls")

labour_account <- raw %>%
  separate(series,
           into = c("prefix", "indicator", "state", "industry"),
           sep = ";",
           extra = "drop") %>%
  mutate_if(is.character, trimws)  %>%
  filter(!is.na(value)) %>%
  mutate(year = year(date),
         month = month(date, abbr = FALSE, label = TRUE)) %>%
  select(date, month, year, prefix, indicator, state, industry, series_type, value, unit)

file.remove(here::here("data-raw", "labour_account.xls"))

save(labour_account, file = here::here("data", "labour_account.rda"), compress = "xz")



