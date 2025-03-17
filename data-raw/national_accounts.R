## code to prepare `national_accounts` dataset goes here
library(readabs)
library(dplyr)
library(stringr)
library(tidyr)
library(usethis)
library(strayr)

raw <- read_abs("5206.0", tables = c(1, 6), retain_files = FALSE)

national_accounts <- raw |> 
  filter(table_no == "5206006_industry_gva") |> 
  mutate(series = str_replace_all(series, regex("(\\s\\([A-S]\\)\\s)|(\\s;)$", multiline = TRUE), "")) %>%
  separate(series, 
           into = c("industry", "subdivision"), 
           sep = ";", 
           fill = "right") %>%
  mutate(across(where(is.character), ~ trimws(.)),
         industry = clean_anzsic(industry, silent = TRUE)) %>%
  filter(industry %in% anzsic2006$anzsic_division,
         !is.na(value)) %>%
  mutate(subdivision = ifelse(subdivision == "", paste(industry, "(Total)"), subdivision)) %>%
  separate(subdivision, 
           into = c("subdivision", "indicator"), 
           sep = ":", 
           fill = "right") %>%
  select("date", 
         "industry", 
         "subdivision", 
         "value", 
         "series_type", 
         "unit") %>%
  mutate(.after = date, 
         indicator = case_when(
    unit == "$ Millions" ~ "Gross Value Added",
    unit == "Percent" ~ "Percent Changes",
    unit == "Index Points" ~ "Contribution To Growth"),
    indicator = ifelse(indicator == "Percent Changes", paste("Gross value added (Growth)"), indicator),
    subdivision = ifelse(test = subdivision %in% c("Gross Value Added",
                                                         "Percentage Changes",
                                                         "Contributions To Growth",
                                                         "Revision To Percentage Changes"),
                         yes = paste(industry, "(Total)"),
                         no = subdivision),
    indicator = str_to_sentence(indicator))

use_data(national_accounts, overwrite = TRUE, compress = "xz")
